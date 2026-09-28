---
lang: it
permalink: /it/blog/cache-semantica-llm/
title: "Cache semantica sulle chiamate LLM: quando risparmi il 40% e quando servi la risposta sbagliata a un altro cliente"
date: 2026-10-25 07:30:00 +0200
author: "Antonio Trento"
description: "Cache semantica LLM in produzione: exact hash vs nearest neighbor, il bug della similarità alta tra clienti diversi, tenant_id obbligatorio nella chiave, TTL e invalidazione, Redis vs Postgres, prompt cache dei vendor e privacy, hit rate vs error rate e il default sicuro."
keywords: ["cache semantica llm", "semantic cache redis", "embedding cache rischio", "prompt cache openai", "multi tenant cache", "cache risposte llm"]
image: /assets/images/posts/cache-semantica-llm.jpg
pillar: modelli-costi-privacy
related: [/it/blog/tco-gpt-4o-vs-llm-self-hosted/, /it/blog/gdpr-chatgpt-crm/]
---

## Il risparmio che nessuno aveva messo in conto come rischio

Un fornitore di software gestionale aggiunge al proprio prodotto un assistente che risponde alle domande degli utenti sui loro dati: "quante fatture ho scadute questo mese?", "qual è il mio piano di abbonamento?", "chi è il referente del mio contratto di assistenza?". Il traffico cresce, la bolletta delle API cresce con lui, e qualcuno propone una soluzione elegante: una **cache semantica**. Si calcola l'embedding di ogni domanda; se una domanda nuova è molto simile a una già vista, si restituisce la risposta salvata invece di chiamare il modello. Nelle prove il tasso di riuso è alto e la spesa scende in modo evidente.

Qualche settimana dopo arriva la segnalazione. Un utente ha chiesto "chi è il referente del mio contratto?" e ha ricevuto nome ed email del referente di **un'altra azienda**. La domanda era identica a quella fatta poco prima da un utente di un altro cliente; la similarità era altissima; la cache ha fatto esattamente ciò per cui era stata progettata. Il risultato è una **violazione di dati personali**, con tutto ciò che ne consegue.

La **cache semantica sulle chiamate LLM** è uno degli interventi più efficaci sui costi e sulla latenza, e uno dei più pericolosi quando il servizio è condiviso tra più clienti. Il problema non è la tecnica: è che "domanda simile" non significa "stessa risposta" appena la risposta dipende da chi chiede, da quando chiede e da quali dati vede.

Questo pezzo ha un angolo preciso: **performance contro isolamento**. Vediamo le due famiglie di cache (hash esatto e vicino più prossimo), come nasce il bug tra clienti, come deve essere fatta la chiave, TTL e invalidazione, Redis contro Postgres, la cache dei fornitori di modelli e cosa implica per la privacy, come misurare insieme hit rate ed **error rate**, e il default che consiglio: **exact match più tenant**, e semantica solo dove è dimostrato che non fa danni.

## Due cache: exact hash vs nearest neighbor

Quando si parla di "cache per LLM" si mescolano tre cose diverse. Conviene separarle subito.

**1. Cache a corrispondenza esatta (exact hash).** Si normalizza la richiesta — modello, parametri, prompt di sistema, messaggi, contesto recuperato — e se ne calcola un hash. Se l'hash è già in cache, si restituisce la risposta salvata. È deterministica: restituisce una risposta salvata solo per una richiesta **identica**. Il tasso di riuso dipende da quanto il traffico è ripetitivo: alto per pipeline batch che rielaborano gli stessi documenti, per domande generate da pulsanti o menu, per test e riesecuzioni; basso per domande libere scritte da persone.

**2. Cache semantica (nearest neighbor).** Si calcola l'embedding della domanda, si cerca la domanda salvata più simile, e se la similarità supera una soglia si restituisce la sua risposta. Riusa anche domande formulate diversamente ("quanto costa la spedizione in Sardegna?" e "spese di spedizione per la Sardegna?"). Il tasso di riuso è più alto, ma introduce un elemento nuovo: **può sbagliare**. Due domande molto simili nelle parole possono richiedere risposte diverse ("posso disdire entro 14 giorni?" e "posso disdire dopo 14 giorni?" hanno embedding vicinissimi e risposte opposte).

**3. Prompt cache del fornitore.** Non memorizza risposte: memorizza il **calcolo** sul prefisso del prompt (la parte iniziale ripetuta, come istruzioni di sistema lunghe o documenti di contesto), così le richieste successive con lo stesso prefisso costano meno e rispondono più velocemente. La risposta viene comunque generata di nuovo. Ne parliamo più avanti: ha implicazioni diverse, e nessun rischio di "risposta sbagliata a un altro".

| Tipo | Cosa riusa | Può restituire una risposta sbagliata? | Riuso tipico | Dove vive |
|------|------------|----------------------------------------|--------------|-----------|
| Exact hash | risposta a richiesta identica | solo se la chiave è incompleta | da basso a alto, dipende dal traffico | tuo (Redis, Postgres) |
| Semantica | risposta a richiesta simile | sì, per costruzione | più alto su domande ricorrenti | tuo (indice vettoriale) |
| Prompt cache vendor | calcolo del prefisso | no, la risposta è rigenerata | alto su prompt con prefisso lungo | fornitore |

La cifra del titolo, il **40%**, va presa per quello che è: un ordine di grandezza plausibile per un assistente con molte domande ricorrenti, non una promessa. Su traffico aperto e personalizzato il riuso reale può essere molto più basso; su pipeline ripetitive molto più alto. L'unico numero che conta è quello misurato sul tuo traffico, e più avanti vediamo come.

## Il bug: similarità alta, cliente diverso

Il caso di leakage dell'introduzione ha una struttura che si ripete in quasi tutti gli incidenti di questo tipo. Vale la pena scomporlo.

**La cache era globale.** Un unico indice vettoriale per tutti i clienti del servizio. La chiave era la domanda; il valore la risposta. Nessun campo diceva *di chi* fosse quella risposta.

**La risposta dipendeva da dati privati.** "Chi è il referente del mio contratto?" non ha una risposta generale: la risposta viene da una query sui dati del cliente che chiede, fatta dall'agente o dalla pipeline RAG prima di chiamare il modello. Ma la cache si guardava **prima** di tutto questo, sulla sola domanda.

**La domanda era generica.** Le domande più ripetute sono proprio quelle formulate in modo standard, identiche tra utenti diversi. Sono quelle con il riuso più alto e, se la risposta è personale, il rischio più alto.

**La soglia era tarata sul risparmio.** Nelle prove, abbassare la soglia di similarità aumentava il riuso, e nessuna metrica misurava gli errori. Quindi la soglia è scesa.

Ecco la sequenza, come la si ricostruisce dai log:

```
10:02:11 tenant=acme    user=u_881 q="chi è il referente del mio contratto?"
         cache MISS -> retrieval(tenant=acme) -> LLM -> "Il referente è Laura R., laura.r@acme…"
         cache SET key=emb(q) value="Il referente è Laura R., …"          <- nessun tenant nella chiave
10:07:45 tenant=beta    user=u_112 q="Chi è il referente del mio contratto"
         cache HIT sim=0.991 -> "Il referente è Laura R., laura.r@acme…"  <- dati di acme a beta
```

Nessun componente si è comportato male secondo la propria specifica. Il difetto è di **progetto**: la cache ignorava tutte le informazioni che rendevano la risposta specifica per un cliente. Varianti dello stesso difetto:

- **Stesso cliente, utenti con permessi diversi**: il responsabile commerciale vede i margini, l'operatore no. Se la cache è per cliente ma non per livello di autorizzazione, l'operatore riceve la risposta calcolata per il responsabile.
- **Stessa domanda, dati cambiati**: "qual è il mio saldo?" ha una risposta diversa ogni giorno. Una cache con TTL lungo restituisce il saldo della settimana scorsa.
- **Stessa domanda, contesto diverso**: in una conversazione, "e quello di marzo?" significa cose diverse a seconda dei messaggi precedenti. Cachare la sola ultima domanda è sbagliato per costruzione.

Il principio che ne discende: **una risposta può essere riusata solo per richieste che avrebbero prodotto la stessa risposta**. Tutto ciò da cui la risposta dipende deve stare nella chiave, oppure la risposta non va cachata.

## Chiave: tenant_id obbligatorio

La chiave della cache è il punto in cui si decide l'isolamento. Ecco lo schema che uso, con la regola che i campi di isolamento **non sono opzionali**: se mancano, la scrittura in cache viene rifiutata.

```python
import hashlib, json, unicodedata

CAMPI_ISOLAMENTO = ("tenant_id", "ambito_permessi")      # obbligatori, sempre

def normalizza(testo: str) -> str:
    t = unicodedata.normalize("NFKC", testo).strip().lower()
    return " ".join(t.split())

def chiave_cache(*, tenant_id: str, ambito_permessi: str, modello: str, versione_prompt: str,
                 versione_policy: str, parametri: dict, messaggi: list[dict],
                 id_fonti: list[str], versione_dati: str) -> str:
    if not tenant_id or not ambito_permessi:
        raise ValueError("cache: tenant_id e ambito_permessi sono obbligatori")
    materiale = {
        "tenant": tenant_id,                     # isolamento tra clienti
        "ambito": ambito_permessi,               # isolamento tra ruoli (es. "vendite:lettura-margini")
        "modello": modello,                      # "gpt-x-2026-05-01", mai un alias mobile
        "prompt": versione_prompt,               # hash del prompt di sistema
        "policy": versione_policy,               # cambia policy -> chiavi nuove
        "parametri": {k: parametri[k] for k in sorted(parametri)},   # temperature, max_tokens…
        "messaggi": [{"r": m["role"], "c": normalizza(m["content"])} for m in messaggi],
        "fonti": sorted(id_fonti),               # documenti/record recuperati (RAG)
        "dati": versione_dati,                   # es. timestamp dell'ultimo aggiornamento rilevante
    }
    h = hashlib.sha256(json.dumps(materiale, sort_keys=True, ensure_ascii=False).encode()).hexdigest()
    return f"llmcache:{tenant_id}:{h}"           # il prefisso tenant permette purge per cliente
```

Qualche dettaglio che conta:

- **Il tenant sta sia nel prefisso sia nell'hash.** Nell'hash per l'isolamento; nel prefisso per poter cancellare tutto ciò che riguarda un cliente con un'operazione (richiesta di cancellazione, fine contratto).
- **L'ambito dei permessi** non è l'utente: è la combinazione di permessi che determina cosa l'utente vede. Due utenti dello stesso cliente con lo stesso ruolo possono condividere la cache; mettere l'id utente riduce il riuso a quasi zero senza aggiungere sicurezza, salvo quando le risposte sono davvero personali (i miei ordini, i miei ticket), e allora l'utente va nella chiave.
- **Le fonti recuperate** entrano nella chiave: se il retrieval restituisce documenti diversi, la risposta può essere diversa. Questo implica che la cache si consulta **dopo** il retrieval, non prima. Si perde una parte del risparmio (il retrieval si fa comunque), ma si guadagna correttezza.
- **La versione del modello** deve essere esplicita. Se usi un alias che il fornitore aggiorna, le risposte cachate con il modello vecchio verrebbero servite come se fossero del nuovo.
- **La conversazione intera**, non solo l'ultimo messaggio. Per le conversazioni lunghe il riuso diventa basso: è corretto così.

Per la **cache semantica** la regola è la stessa, applicata in modo diverso: la ricerca del vicino più prossimo si fa **solo dentro la partizione** del tenant e dell'ambito, con un filtro obbligatorio, mai su un indice globale filtrato dopo.

```sql
-- Postgres + pgvector: la ricerca semantica è SEMPRE vincolata a tenant e ambito
SELECT id, risposta, 1 - (embedding <=> $1) AS similarita
FROM llm_cache_semantica
WHERE tenant_id = $2
  AND ambito_permessi = $3
  AND versione_policy = $4
  AND scade_il > now()
ORDER BY embedding <=> $1
LIMIT 1;
-- l'applicazione accetta l'hit solo se similarita >= soglia E il tipo di domanda è "cachabile"
```

E, come secondo livello di difesa, la **row level security** di Postgres con il tenant impostato dalla sessione, così un errore nel codice applicativo non basta a leggere righe di un altro cliente. È la stessa logica di difesa in profondità che uso per l'isolamento dei dati nei [RAG con pgvector sulle fatture elettroniche]({{ '/it/blog/rag-pgvector-fattura-elettronica/' | relative_url }}).

## Quali domande si possono cachare (e quali mai)

Anche con la chiave giusta, non tutto va messo in cache. Una classificazione pratica:

- **Cachabili senza problemi**: risposte che dipendono solo da contenuti pubblici o comuni a tutti (documentazione del prodotto, condizioni generali, FAQ), da contenuti stabili del singolo cliente (il suo manuale interno), o da elaborazioni deterministiche di un documento (estrazione di campi da una fattura già vista, riassunto di un testo identico).
- **Cachabili con TTL breve e versione dei dati nella chiave**: risposte su dati che cambiano (stato ordini, saldi, scadenze).
- **Da non cachare**: risposte che eseguono azioni (un agente che crea un ticket non deve "ricordarsi" di averlo creato e saltare la chiamata), risposte con dati personali di terzi quando l'ambito non è rigoroso, risposte a richieste in cui il tempo conta ("cosa devo fare oggi?"), risposte generate con temperatura alta dove la variabilità è voluta.

Il tipo di domanda si stabilisce **a monte**, dal percorso applicativo (quale funzione, quale endpoint, quale strumento), non chiedendo al modello di decidere se la sua risposta è cachabile.

## TTL e invalidazione su cambio policy

Una risposta cachata è una fotografia di un momento: modello, prompt, dati e regole di allora. Quando uno di questi cambia, la fotografia è scaduta. Due meccanismi, da usare insieme.

**TTL (time to live).** Ogni voce ha una scadenza, in funzione del tipo di contenuto:

| Tipo di contenuto | TTL indicativo | Motivo |
|-------------------|----------------|--------|
| Documentazione pubblica, FAQ | giorni o settimane | cambia raramente, invalidazione per versione |
| Estrazione da documento identico | lungo, legato all'hash del documento | stesso input, stesso output |
| Dati operativi (ordini, ticket) | minuti | il dato cambia durante la giornata |
| Dati finanziari (saldi, scadenze) | minuti o nessuna cache | una risposta vecchia è una risposta sbagliata |
| Conversazioni | la durata della sessione, se ha senso | il contesto cambia a ogni messaggio |

**Invalidazione per versione.** Il TTL non basta quando cambia qualcosa di strutturale. Per questo nella chiave ci sono la versione del prompt, della policy, del modello e dei dati. Quando:

- **cambia la policy** — per esempio l'assistente non deve più comunicare i prezzi scontati, o una categoria di informazioni diventa riservata — la versione della policy cambia e tutte le chiavi vecchie diventano irraggiungibili **all'istante**, senza attendere la scadenza;
- **cambia il prompt di sistema** o il modello, idem;
- **cambia un documento** della base di conoscenza, cambiano gli id o gli hash delle fonti recuperate e le risposte collegate non vengono più trovate.

L'invalidazione per versione ha un vantaggio decisivo rispetto alla cancellazione esplicita: non bisogna sapere quali voci eliminare. Le voci vecchie restano, irraggiungibili, finché il TTL non le rimuove. Per le situazioni di emergenza — una risposta sbagliata scoperta in produzione, una richiesta di cancellazione di un cliente — serve comunque la **purge** esplicita: per tenant (grazie al prefisso), per voce, o totale.

Un caso tipico da gestire con cura è la richiesta di **cancellazione dei dati** di un cliente o di un interessato. Una cache che contiene risposte con dati personali è un archivio di dati personali come gli altri: va inclusa nel registro dei trattamenti, nei tempi di conservazione e nelle procedure di cancellazione. Ne ho parlato più in generale nel pezzo su [GDPR, ChatGPT e dati del CRM]({{ '/it/blog/gdpr-chatgpt-crm/' | relative_url }}).

## Redis vs Postgres

Dove tenere la cache? Le due scelte ragionevoli per una PMI sono Redis e Postgres, e dipende soprattutto da cosa hai già.

**Redis.** È la scelta naturale per una cache: TTL nativo per chiave, latenze molto basse, eviction automatica quando la memoria è piena. Per la cache esatta è perfetto. Per la semantica serve il supporto alla ricerca vettoriale (il modulo di query e ricerca disponibile nelle distribuzioni recenti di Redis e in Redis Stack), con i filtri per tenant come campi indicizzati. Attenzione a due aspetti: la **persistenza** (una cache in sola memoria si svuota al riavvio, che per una cache va bene, ma va saputo) e il fatto che l'isolamento è interamente affidato alla correttezza delle query applicative. Se usi un Redis gestito, verifica dove risiedono i dati.

**Postgres (con pgvector per la semantica).** Se Postgres è già nel tuo stack, spesso basta. La cache esatta è una tabella con chiave primaria e colonna di scadenza, con un job periodico che elimina le righe scadute; la semantica si fa con pgvector e un indice HNSW. Vantaggi: transazioni, backup già esistenti, **row level security** per il tenant, audit con gli strumenti che già usi. Svantaggi: latenza più alta di Redis (millisecondi invece di frazioni di millisecondo, comunque irrilevanti rispetto ai secondi di una chiamata a un modello) e la necessità di gestire la pulizia delle righe scadute.

La scelta pratica:

- **Hai già Redis, cache esatta, volumi alti**: Redis.
- **Hai già Postgres, vuoi isolamento forte e audit, cache semantica per tenant**: Postgres con pgvector e RLS.
- **Non hai nessuno dei due**: parti da Postgres, che ti serve comunque per molto altro, e aggiungi Redis solo se le misure lo richiedono.

Sul confronto tra database vettoriali più in generale, con i criteri che valgono anche qui, rimando al pezzo su [pgvector, Qdrant e Pinecone]({{ '/it/blog/pgvector-vs-qdrant-vs-pinecone/' | relative_url }}).

## L'architettura di riferimento

```
 richiesta (tenant, utente, messaggi)
        │
        ▼
 ┌──────────────────────────┐
 │ AUTORIZZAZIONE            │  -> tenant_id, ambito_permessi (dal token, mai dal testo)
 └────────────┬─────────────┘
              ▼
 ┌──────────────────────────┐
 │ CLASSIFICA PERCORSO       │  -> cachabile? tipo contenuto? TTL?  (per endpoint/strumento)
 └────────────┬─────────────┘
              ▼
 ┌──────────────────────────┐
 │ RETRIEVAL (se RAG)        │  -> id fonti, versione dati   (filtrato per tenant)
 └────────────┬─────────────┘
              ▼
 ┌──────────────────────────┐     HIT (exact)     ┌──────────────┐
 │ CACHE ESATTA              │────────────────────►│  risposta     │
 │ chiave = tenant+ambito+…  │                     └──────────────┘
 └────────────┬─────────────┘
         MISS │  (semantica solo su percorsi abilitati, dentro la partizione del tenant)
              ▼
 ┌──────────────────────────┐
 │ LLM (prompt cache vendor  │  -> risposta ─► validazione ─► SET cache (se cachabile)
 │ sul prefisso stabile)     │
 └──────────────────────────┘
 log: hit/miss, tipo, similarità, tenant (id), costo evitato — mai il contenuto in chiaro nei log
```

**Cosa non tocca la cache**: le azioni degli agenti (mai saltate per un hit), l'autorizzazione (sempre calcolata a ogni richiesta, mai dedotta da una voce in cache), e i dati di un tenant quando la richiesta arriva da un altro (partizionamento obbligatorio, con RLS come seconda barriera).

## Cache del vendor (prompt cache) e privacy

I principali fornitori di modelli offrono il **prompt caching**: quando più richieste condividono lo stesso prefisso lungo — istruzioni di sistema, esempi, un documento di riferimento — il calcolo su quel prefisso viene riutilizzato, con uno sconto sul costo dei token di input e una latenza inferiore. A seconda del fornitore il meccanismo è automatico (sopra una certa lunghezza del prompt) oppure si attiva marcando esplicitamente le parti da cachare, e la durata è in genere breve, nell'ordine dei minuti, con opzioni più lunghe in alcuni casi. I dettagli — soglie, sconti, durate — cambiano nel tempo: verificali sulla documentazione aggiornata del fornitore prima di farci affidamento nei conti.

Tre punti per inquadrarlo correttamente:

- **Non restituisce risposte salvate.** La risposta è generata ogni volta; si risparmia sul calcolo del prefisso. Quindi non esiste il rischio di "servire la risposta di un altro": è una cache di calcolo, non di contenuto.
- **È isolata secondo le regole del fornitore**, tipicamente per organizzazione o account. Non condividi la cache con altri clienti del fornitore, ma all'interno del tuo account la cache è condivisa tra le tue richieste. Per un servizio multi-tenant questo non crea rischi di contenuto (la risposta non viene riusata), ma è comunque un trattamento temporaneo dei dati presso il fornitore, già coperto — o da coprire — dal contratto e dalla valutazione che fai sull'uso del fornitore stesso.
- **Premia i prompt ben strutturati.** Il prefisso stabile (istruzioni, esempi, documenti comuni) va messo all'inizio; le parti variabili (domanda dell'utente, dati del cliente) alla fine. Se metti i dati del cliente all'inizio, il prefisso cambia a ogni richiesta e non risparmi nulla.

Dal punto di vista della privacy, la prompt cache del fornitore non cambia la natura del rapporto: se i dati vanno al fornitore, ci vanno con o senza cache. Le domande restano quelle di sempre — dove sono trattati, per quanto tempo, con quali garanzie contrattuali. Se la risposta a queste domande non è accettabile per certi dati, la soluzione è un modello self-hosted, e allora la cache del prefisso la gestisce il tuo motore di inferenza: server come vLLM offrono il riuso del prefisso sulla stessa GPU, con lo stesso effetto e i dati che non escono. Per i costi dei due scenari, i conti sono nel pezzo sul [TCO tra GPT-4o e un LLM self-hosted]({{ '/it/blog/tco-gpt-4o-vs-llm-self-hosted/' | relative_url }}).

La combinazione più efficace spesso è: **prompt cache del prefisso** (gratis in termini di rischio) + **cache esatta** con tenant (rischio controllato) + **cache semantica** solo sui percorsi di contenuto comune (FAQ, documentazione), dove una risposta simile è davvero la stessa risposta.

## Misura hit rate vs error rate

La maggior parte delle cache semantiche viene giudicata con una sola metrica: l'**hit rate**, la quota di richieste servite dalla cache. È la metrica sbagliata da sola, perché cresce abbassando la soglia di similarità — cioè accettando più errori. Serve misurare anche l'**error rate**: la quota di hit in cui la risposta servita non era corretta per quella richiesta.

Le metriche minime:

| Metrica | Definizione | Nota |
|---------|-------------|------|
| Hit rate esatto | hit esatti / richieste cachabili | per percorso, non solo globale |
| Hit rate semantico | hit semantici / richieste cachabili | solo sui percorsi abilitati |
| Error rate semantico | hit semantici errati / hit semantici | misurato su campione, vedi sotto |
| Hit cross-partizione | hit con tenant o ambito diverso da chi chiede | **deve essere zero**: allarme se > 0 |
| Costo evitato | somma del costo stimato delle chiamate evitate | meno costo di embedding e ricerca |
| Latenza | p50/p95 per hit e per miss | il miss con lookup è più lento del non-cache |
| Età media delle risposte servite | tempo dalla scrittura all'hit | segnale di TTL troppo lunghi |

**Come si misura l'error rate.** Su un campione di hit semantici (per esempio l'1–2%, o qualche decina al giorno), si esegue **anche** la chiamata al modello, in background, e si confronta la risposta fresca con quella servita dalla cache: in automatico per i campi strutturati, con un giudice a rubrica o con una revisione umana per il testo libero. Il costo del campionamento è piccolo rispetto al risparmio e dà l'unico numero che rende la soglia una decisione informata. È lo stesso metodo di campionamento e confronto che uso per [valutare gli agenti in produzione]({{ '/it/blog/valutazione-agenti-llm-produzione/' | relative_url }}).

**Il controllo cross-partizione** è diverso: non è una statistica, è un **invariante**. A ogni hit, il codice verifica che tenant e ambito della voce trovata coincidano con quelli della richiesta; se no, scarta l'hit, registra un evento critico e fa scattare un allarme. Con una chiave ben fatta non deve mai succedere; il controllo esiste per quando un bug o una migrazione rompono l'ipotesi.

**Il conto del risparmio vero.** Il risparmio netto non è hit rate per costo medio. È:

```
risparmio netto = (hit × costo medio chiamata evitata)
                − (tutte le richieste × costo embedding + lookup)
                − (campionamento di controllo)
                − (costo atteso degli errori serviti)
```

L'ultima voce è la più difficile da stimare e la più importante. Un errore su una FAQ pubblica costa poco. Un dato personale servito al cliente sbagliato può costare molto più di tutto il risparmio di un anno: una notifica di violazione, la gestione dell'incidente, la fiducia del cliente. Se la cache semantica fa risparmiare qualche centinaio di euro al mese su un percorso con dati personali, il conto non torna quasi mai.

Sulla strumentazione di questi numeri — tracce, costi per chiamata, dashboard — vale quanto descritto nel pezzo sull'[osservabilità degli LLM in produzione]({{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}), con un'accortezza: nei log della cache vanno gli **identificativi** (tenant, hash della chiave, similarità), non il contenuto delle domande e delle risposte.

## Tarare la soglia di similarità senza illudersi

Se decidi di usare la cache semantica su qualche percorso, la soglia va tarata sui tuoi dati, non copiata da un esempio. Un procedimento:

1. **Raccogli coppie di domande** dal traffico reale del percorso (anonimizzate), comprese quelle quasi identiche con risposte diverse: negazioni ("posso" / "non posso"), numeri e date diversi, entità diverse ("in Sardegna" / "in Sicilia").
2. **Etichettale**: per ogni coppia, la risposta corretta è la stessa sì o no?
3. **Calcola la similarità** con il modello di embedding che userai.
4. **Traccia la curva**: per ogni soglia possibile, quante coppie "stessa risposta" verrebbero riusate (il riuso) e quante coppie "risposta diversa" verrebbero confuse (l'errore).
5. **Scegli la soglia** in base all'errore accettabile per quel percorso, non in base al riuso desiderato.

Scoprirai quasi sempre due cose. La prima: esistono coppie con similarità altissima e risposta diversa, soprattutto quando cambia un numero, una data o una negazione, perché i modelli di embedding catturano l'argomento più che i dettagli. La seconda: per tenere l'errore vicino allo zero la soglia deve essere così alta che il riuso semantico aggiunge poco rispetto alla cache esatta con normalizzazione. È il motivo per cui il default che consiglio è quello della prossima sezione.

Alcune tecniche riducono l'errore senza abbassare troppo il riuso: estrarre le **entità** (numeri, date, luoghi, codici) e richiedere che coincidano oltre alla similarità; restringere la semantica a un insieme chiuso di domande canoniche (le FAQ), mappando la domanda dell'utente su una di esse e cachando la risposta canonica; usare un modello di embedding sensibile all'italiano, perché quelli addestrati prevalentemente in inglese confondono più facilmente le sfumature. Sul comportamento degli embedding con i testi italiani vale quanto osservato nel pezzo sulla [ricerca ibrida BM25 ed embedding in italiano]({{ '/it/blog/hybrid-search-bm25-embedding-italiano/' | relative_url }}).

## Default sicuro: exact match + tenant

Mettendo insieme tutto, il default che consiglio per un servizio con più clienti o con dati personali:

1. **Prompt cache del fornitore o del motore di inferenza** sempre attiva, con il prompt strutturato in prefisso stabile e parte variabile finale. Nessun rischio di contenuto, risparmio immediato.
2. **Cache esatta** con chiave completa: tenant, ambito dei permessi, modello, versioni di prompt e policy, parametri, conversazione normalizzata, fonti recuperate, versione dei dati. Scrittura rifiutata se mancano i campi di isolamento.
3. **TTL per tipo di contenuto** e invalidazione per versione, più purge per tenant.
4. **Cache semantica disattivata di default**, abilitata solo su percorsi di contenuto comune (documentazione, FAQ, condizioni generali), con partizione per tenant se i contenuti differiscono tra clienti, soglia tarata sui dati e error rate misurato su campione.
5. **Nessuna cache** sulle azioni degli agenti e sui percorsi con dati personali di cui non controlli rigorosamente l'ambito.
6. **Invariante cross-partizione** verificato a ogni hit, con allarme.

Questo default rinuncia a una parte del risparmio teorico. In cambio, l'unico modo in cui la cache può servire una risposta sbagliata è una chiave incompleta — un difetto che si trova con i test — e non una similarità ingannevole, che si scopre dai reclami.

## Percorso di implementazione, a step

1. **Misura prima**: registra per qualche settimana le richieste (in forma di hash e metadati) e calcola quanto sarebbe il riuso esatto e quello semantico per percorso. Spesso il riuso esatto basta a giustificare il lavoro, o dimostra che la cache non serve.
2. **Struttura i prompt** con prefisso stabile per sfruttare la prompt cache: è il guadagno a rischio zero.
3. **Classifica i percorsi**: cachabile, cachabile con TTL breve, mai cachabile.
4. **Implementa la chiave** con i campi di isolamento obbligatori e i test che lo verificano (una scrittura senza tenant deve fallire).
5. **Scegli lo storage** (Redis o Postgres) in base a ciò che hai, con RLS se usi Postgres.
6. **Aggiungi TTL, invalidazione per versione e purge per tenant.**
7. **Metti in dashboard** hit rate per percorso, costo evitato, latenza e l'invariante cross-partizione.
8. **Solo dopo**, valuta la cache semantica sui percorsi di contenuto comune: taratura della soglia su coppie etichettate, campionamento dell'error rate, attivazione graduale.
9. **Aggiorna la documentazione privacy**: la cache è un archivio di dati con tempi di conservazione e procedure di cancellazione.

## Fallimenti tipici e come li riconosci

- **Risposta con dati di un altro cliente.** Segnalazione di un utente, o l'invariante cross-partizione che scatta. Causa: chiave senza tenant o ricerca semantica su indice globale. Correzione: purge totale, chiave ricostruita, test di isolamento in CI.
- **Risposte vecchie.** "Il mio saldo è sbagliato", con età media delle risposte servite alta. TTL troppo lungo o versione dei dati assente nella chiave.
- **Nessun effetto dopo un cambio di policy.** Le risposte continuano a contenere informazioni che non dovrebbero più comparire: la versione della policy non è nella chiave.
- **Risposte opposte a domande quasi uguali.** Error rate semantico che cresce, reclami su negazioni e numeri: soglia troppo bassa o assenza di controllo sulle entità.
- **Hit rate bassissimo con costi del lookup visibili.** Chiave troppo specifica (per esempio l'id utente su contenuti comuni) o traffico poco ripetitivo: la cache aggiunge latenza senza risparmio. Misura prima di insistere.
- **Prompt cache del fornitore che non scatta.** Costo dei token di input invariato: la parte variabile del prompt è all'inizio, o il prefisso è sotto la soglia minima richiesta dal fornitore.
- **Un agente che "non fa" un'azione.** Un ticket o un'email mai creati perché la risposta alla chiamata è arrivata dalla cache: un percorso d'azione era finito tra i cachabili.

## Quando NON farlo

- **Se il traffico non si ripete**, la cache aggiunge complessità, latenza sui miss e un archivio di dati da gestire, senza risparmio. Misura il riuso potenziale prima di costruire.
- **Se il costo delle chiamate è già basso** — modello piccolo, self-hosted, volumi contenuti — il risparmio non giustifica il rischio, soprattutto per la semantica.
- **Se le risposte contengono dati personali e non controlli con rigore l'ambito dei permessi**, non cachare quei percorsi.
- **Se non puoi misurare l'error rate**, non usare la cache semantica: stai scegliendo una soglia al buio.
- **Sulle azioni degli agenti**, mai: una cache può evitare di rigenerare un testo, non di eseguire un'operazione.

## Checklist operativa

- [ ] Riuso potenziale misurato per percorso prima di implementare.
- [ ] Prompt con prefisso stabile all'inizio e parte variabile alla fine.
- [ ] Percorsi classificati: cachabile, TTL breve, mai.
- [ ] Chiave con tenant e ambito dei permessi obbligatori; scrittura rifiutata se mancano.
- [ ] Modello, versione del prompt, della policy e dei dati, parametri e fonti nella chiave.
- [ ] Cache consultata dopo il retrieval, non prima.
- [ ] TTL per tipo di contenuto, invalidazione per versione, purge per tenant.
- [ ] Ricerca semantica solo dentro la partizione del tenant; RLS se su Postgres.
- [ ] Hit rate, error rate su campione, costo evitato e latenza in dashboard.
- [ ] Invariante cross-partizione verificato a ogni hit, con allarme.
- [ ] Cache inclusa nel registro dei trattamenti e nelle procedure di cancellazione.
- [ ] Nessuna cache sulle azioni degli agenti.

## Il verdetto

La **cache semantica sulle chiamate LLM** fa risparmiare davvero, e a volte molto. Ma il risparmio si vede subito nella bolletta, mentre il rischio si vede solo quando qualcuno riceve la risposta destinata a un altro. In un servizio con più clienti, "domanda simile" e "stessa risposta" coincidono solo per i contenuti comuni a tutti; appena la risposta dipende da chi chiede, dai suoi permessi o dai suoi dati, una similarità alta è una trappola.

Per questo il default non è la cache semantica, ma una scala: prima la prompt cache del prefisso, che non riusa contenuti e non ha rischi di questo tipo; poi la cache esatta con tenant e ambito obbligatori nella chiave, versioni per invalidare, TTL per tipo di dato; e solo alla fine la semantica, sui percorsi di contenuto comune, con una soglia tarata sui tuoi dati e un error rate misurato. E una regola che non si negozia: a ogni hit, chi chiede e chi aveva ricevuto quella risposta devono stare nella stessa partizione.

Misura hit rate ed error rate insieme, e decidi con entrambi. Il 40% di risparmio è un buon risultato solo se l'altro numero è zero.

Se stai progettando la cache o l'architettura dei costi di un servizio basato su LLM con più clienti e vuoi farlo senza sorprese sulla privacy, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Si parte misurando quanto del tuo traffico si ripete davvero.

## FAQ

### Cos'è una cache semantica per LLM?
È una cache che restituisce una risposta già generata quando arriva una domanda simile, non necessariamente identica, a una già vista. Si calcola l'embedding della domanda, si cerca la domanda salvata più vicina e, se la similarità supera una soglia, si serve la risposta salvata invece di chiamare il modello. Aumenta il riuso rispetto a una cache esatta, ma per costruzione può servire risposte sbagliate.

### Qual è la differenza tra cache esatta e cache semantica?
La cache esatta riusa una risposta solo per una richiesta identica dopo la normalizzazione (stesso modello, parametri, prompt, messaggi e contesto): è deterministica. La semantica riusa risposte per richieste simili: riusa di più, ma due domande molto simili possono avere risposte diverse, per esempio quando cambia una negazione, un numero o una data.

### Come si evita di servire la risposta di un cliente a un altro?
Mettendo il tenant e l'ambito dei permessi nella chiave della cache come campi obbligatori, rifiutando le scritture che ne sono prive, e facendo la ricerca semantica solo dentro la partizione del tenant, mai su un indice globale. Come seconda barriera: row level security sul database e un controllo a ogni hit che tenant e ambito della voce coincidano con quelli di chi chiede, con allarme se non coincidono.

### La prompt cache di OpenAI o di altri fornitori è rischiosa per la privacy?
Non restituisce risposte salvate: riutilizza il calcolo sul prefisso del prompt, e la risposta viene rigenerata ogni volta, quindi non c'è rischio di servire il contenuto di un altro. È isolata secondo le regole del fornitore, in genere per organizzazione. Resta un trattamento temporaneo presso il fornitore, che non cambia le valutazioni già necessarie sull'invio dei dati a quel fornitore.

### Quanto si risparmia davvero con una cache semantica?
Dipende dal traffico. Su assistenti con molte domande ricorrenti su contenuti comuni si può arrivare a risparmi importanti, anche nell'ordine del 40% delle chiamate; su traffico aperto e personalizzato il riuso sicuro è molto più basso. Il risparmio netto va calcolato togliendo il costo di embedding e ricerca, del campionamento di controllo e il costo atteso degli errori.

### Come si misura l'error rate di una cache semantica?
Su un campione di hit si esegue anche la chiamata al modello in background e si confronta la risposta fresca con quella servita dalla cache: automaticamente per i campi strutturati, con un giudice a rubrica o una revisione umana per il testo libero. La quota di discordanze è l'error rate, da tenere accanto all'hit rate per scegliere la soglia.

### Meglio Redis o Postgres per la cache?
Redis è ideale per una cache esatta ad alto volume, con TTL nativo e latenze minime, e supporta anche la ricerca vettoriale nelle versioni con il modulo di query. Postgres con pgvector è una scelta solida se lo usi già: offre transazioni, backup, row level security per il tenant e audit, con una latenza comunque trascurabile rispetto a quella del modello. Senza nessuno dei due, conviene partire da Postgres.

### Quando va invalidata la cache?
Alla scadenza del TTL, scelto per tipo di contenuto (minuti per dati operativi e finanziari, più a lungo per documentazione), e subito quando cambiano policy, prompt di sistema, modello o documenti di origine. Il modo più robusto è mettere le versioni nella chiave, così le voci vecchie diventano irraggiungibili senza doverle cercare. Per emergenze e richieste di cancellazione serve anche la purge per tenant.

### Si possono cachare le risposte di un agente che esegue azioni?
No. Una cache può evitare di rigenerare un testo, non di eseguire un'operazione: se la risposta a una richiesta di creare un ticket o inviare un'email arriva dalla cache, l'azione non viene eseguita. I percorsi che producono azioni vanno esclusi a monte, in base all'endpoint o allo strumento, non con una decisione del modello.

### Qual è il default più sicuro?
Prompt cache del prefisso sempre attiva, con il prompt strutturato bene; cache esatta con tenant, ambito dei permessi e versioni nella chiave; TTL per tipo di dato e purge per tenant; cache semantica disattivata di default e abilitata solo sui contenuti comuni, con soglia tarata e error rate misurato; nessuna cache sulle azioni e sui percorsi con dati personali non rigorosamente isolati.
