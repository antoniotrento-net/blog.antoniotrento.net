---
lang: it
permalink: /it/blog/salesforce-flow-vs-agente-mcp/
title: "Salesforce Flow vs agente MCP: quando il clic automatico di Flow è più sicuro (e quando l'LLM serve davvero a leggere il disordine)"
date: 2026-11-13 07:30:00 +0200
author: "Antonio Trento"
description: "Dove finisce l'automazione deterministica e dove serve un modello linguistico in Salesforce: Flow per le regole se-allora, LLM per testo libero ed eccezioni. Schema ibrido in cui Flow chiama un servizio di classificazione, error handling, costi di manutenzione a 18 mesi, governance e una matrice per 10 automazioni tipiche."
keywords: ["salesforce flow vs agente mcp", "flow orchestrator vs llm", "automazione deterministica crm", "eccezioni salesforce", "tool llm", "classificazione email salesforce"]
image: /assets/images/posts/salesforce-flow-vs-agente-mcp.jpg
pillar: agenti-esecuzione
related: [/it/blog/mcp-salesforce-agente-produzione/, /it/blog/kill-switch-agente-salesforce/]
---

## La riunione in cui qualcuno propone di "mettere l'AI nel CRM"

La proposta arriva di solito con una slide e un verbo: *sostituire*. "Sostituiamo i Flow con un agente che capisce cosa fare." L'idea è seducente: invece di decine di automazioni con condizioni, decisioni e rami, un agente collegato a Salesforce via MCP legge il record, capisce il contesto e agisce. Niente più admin che passa le giornate nel Flow Builder, niente più regole che si rompono al primo caso non previsto.

Poi qualcuno fa la domanda giusta: "E quando l'agente decide che quel cliente ha diritto allo sconto del 15% invece che del 10%, chi se ne accorge?" Silenzio. Perché la risposta onesta è: nessuno, finché il cliente non lo fa notare (se lo sconto era troppo basso) o finché il controllo di gestione non lo trova a fine trimestre (se era troppo alto).

Questo pezzo è sul confine tra **Salesforce Flow e un agente MCP**: quando l'automazione deterministica di Flow è non solo sufficiente ma *più sicura*, e quando un modello linguistico serve davvero, perché c'è da leggere testo disordinato che nessuna regola se-allora riesce a gestire. La tesi è anti-hype e pratica: Flow per le regole, LLM per il linguaggio, e quando servono entrambi **Flow chiama un servizio di classificazione, non il contrario**. Con una matrice per dieci automazioni tipiche, lo schema ibrido completo, gli anti-pattern e i costi di manutenzione a diciotto mesi.

## È per te / non è per te

È per te se:

- hai un'org Salesforce con un certo numero di Flow in produzione e qualcuno sta proponendo di introdurre un agente o un LLM;
- sei l'admin, l'architetto o il CTO che deve decidere dove mettere il modello e dove no;
- hai già un caso concreto di testo libero (email, note, allegati) che oggi richiede una persona a smistarlo.

Non è per te se stai cercando come costruire un agente MCP completo su Salesforce: quello l'ho descritto nel pezzo sull'[agente MCP su Salesforce in produzione]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}). Qui la domanda è a monte: *se* e *dove* mettere un modello linguistico in un processo CRM.

## Flow è codice visuale con contratti

Partiamo da un equivoco: Flow viene spesso trattato come "lo strumento per chi non sa programmare", quindi qualcosa di inferiore al codice. È il contrario. Un Flow ben fatto è **codice visuale con contratti espliciti**:

- **input e output tipizzati**: un campo è un numero, una data, una picklist con valori definiti, un riferimento a un record;
- **condizioni deterministiche**: a parità di record, il Flow prende sempre la stessa strada;
- **transazioni**: un record-triggered flow vive dentro la transazione del salvataggio; se qualcosa va storto, la transazione si annulla;
- **versioni**: ogni modifica è una nuova versione, attivabile e disattivabile, con la possibilità di tornare indietro;
- **fault path**: ogni elemento che può fallire ha un ramo di errore esplicito;
- **test**: Flow supporta test automatici sui record-triggered flow, e comunque il comportamento è verificabile con dati di prova.

Queste proprietà sono esattamente quelle che servono quando l'automazione tocca soldi, contratti, scadenze, assegnazioni, permessi. Se un'opportunità passa a "Chiusa vinta" quando il contratto è firmato, vuoi che succeda *sempre*, *solo* in quel caso e in modo *verificabile*. Un modello linguistico non ti dà nessuna di queste garanzie per costruzione: ti dà una probabilità alta, che non è la stessa cosa.

I limiti di Flow sono altrettanto chiari:

- non sa leggere testo libero se non con confronti di stringhe fragili ("contiene la parola *reclamo*");
- non sa estrarre informazioni da un PDF o da un'immagine;
- diventa ingestibile quando le regole sono troppe e si sovrappongono (il famoso Flow con quaranta decisioni annidate che nessuno osa toccare);
- è vincolato ai governor limits della piattaforma: numero di query, di DML, di callout per transazione, tempo di CPU.

Il primo e il secondo limite sono il territorio dell'LLM. Il terzo è un problema di progettazione, non di strumento: un Flow ingestibile si rifattorizza, non si sostituisce con un modello. Il quarto vale per qualsiasi cosa giri sulla piattaforma, LLM incluso.

## L'LLM è per testo e ambiguità, non per IVA al 22%

Il modo più rapido per capire dove *non* mettere un modello linguistico è chiedersi: "esiste una regola scritta che dà la risposta giusta?". Se sì, quella regola va scritta in Flow (o in Apex, o in una formula), non affidata a un modello.

L'esempio che uso sempre è l'IVA. Nessuno chiederebbe a un LLM di calcolare l'IVA al 22% di un importo: è una moltiplicazione. Eppure lo stesso errore, travestito, compare continuamente:

- "l'agente decide a quale commerciale assegnare il lead" — quando esiste una tabella di territori;
- "l'agente valuta se lo sconto richiesto è approvabile" — quando esiste una matrice di sconti per livello di cliente;
- "l'agente aggiorna lo stato dell'opportunità" — quando la transizione dipende da campi precisi;
- "l'agente calcola la data di rinnovo" — quando è la data di inizio più la durata.

In tutti questi casi il modello non aggiunge niente, e toglie tre cose: determinismo, verificabilità e velocità. In più aggiunge un costo per chiamata e una dipendenza esterna.

Il modello linguistico serve quando l'input è **linguaggio non strutturato** e la domanda è **interpretativa**:

- "questa email è un reclamo, una richiesta di informazioni o un ordine?";
- "in queste note di una call, quali sono i prossimi passi concordati?";
- "questo PDF allegato è un ordine d'acquisto, e se sì, qual è il numero d'ordine e l'importo?";
- "il cliente in questa mail sta minacciando di disdire?";
- "questi due account con nomi diversi sono probabilmente la stessa azienda?".

Nessuna regola se-allora risponde bene a queste domande. Una persona sì, e un modello abbastanza bene da essere utile — con un livello di confidenza, e con una persona dietro quando la confidenza è bassa.

## Eccezioni: email libere, note, allegati

Il motivo per cui le automazioni CRM "non funzionano" quasi mai sta nelle regole. Sta nelle **eccezioni**: tutto ciò che arriva in una forma che le regole non prevedono. In Salesforce le eccezioni hanno tre forme ricorrenti.

**Email libere.** Email-to-Case o Email-to-Lead creano un record con oggetto e corpo. Il Flow che le smista si basa su indirizzo di provenienza, parole chiave nell'oggetto, forse il dominio del mittente. Funziona per il 60–70% dei casi. Il resto finisce in una coda "Da smistare" che una persona svuota a mano, ogni mattina, leggendo una per una.

**Note e campi descrittivi.** I commerciali scrivono note sulle call, i tecnici scrivono descrizioni degli interventi, il customer care annota le telefonate. Dentro c'è informazione preziosa (scadenze promesse, problemi ricorrenti, segnali di abbandono) che nessun report riesce a usare perché è testo.

**Allegati.** Ordini in PDF, preventivi firmati scansionati, documenti dei clienti. Il Flow vede che c'è un file, non cosa c'è dentro.

Queste tre categorie sono dove un LLM, usato bene, **toglie lavoro manuale ripetitivo** senza toccare le regole. Il punto chiave è "usato bene": il modello non deve decidere cosa fare del record; deve **trasformare il disordine in campi strutturati**, che poi le regole usano. È la differenza tra un modello che agisce e un modello che classifica.

## Ibrido: classifica → campo → Flow

Ecco lo schema che propongo per quasi tutti i casi in cui un modello linguistico entra in un processo Salesforce. È semplice, ed è proprio la semplicità a renderlo robusto.

### Lo schema ibrido

1. **Un evento in Salesforce** (nuovo Case da email, nuova nota, nuovo allegato su un'opportunità) attiva un record-triggered flow.
2. Il Flow, in un **percorso asincrono**, chiama un **servizio di classificazione** esterno tramite un'azione HTTP (o un'azione invocabile Apex), con una Named Credential.
3. Il servizio di classificazione (self-hosted, in UE) prepara il testo, chiama il modello, valida l'output contro uno schema e restituisce un **JSON con categoria, campi estratti e confidenza**.
4. Il Flow scrive il risultato in **campi dedicati** (`AI_Categoria__c`, `AI_Confidenza__c`, `AI_Estratto_NumeroOrdine__c`, `AI_Versione_Modello__c`), mai nei campi di business.
5. **Un secondo Flow deterministico** (o un ramo del primo) legge quei campi e applica le regole: se la confidenza supera la soglia e la categoria è X, assegna alla coda X; altrimenti, coda di revisione umana.
6. **Una persona conferma o corregge** i casi sotto soglia; la correzione viene salvata e usata per misurare l'accuratezza del modello nel tempo.

In questo schema il modello non ha credenziali Salesforce, non sceglie quali record modificare, non decide assegnazioni né stati. Fa una cosa sola: legge testo e restituisce una classificazione con una confidenza. **Flow chiama il servizio, il servizio non chiama Flow.** L'orchestrazione resta nella piattaforma, dove ci sono transazioni, versioni, permessi e audit.

```text
  Email-to-Case / Nota / Allegato
              │
              ▼
  Record-triggered Flow (percorso asincrono)
              │  HTTP callout (Named Credential)
              ▼
  Servizio di classificazione (UE, self-hosted)
     ├─ pulizia testo, taglio firme e citazioni
     ├─ chiamata al modello con output strutturato
     ├─ validazione schema + regole deterministiche
     └─ { categoria, campi, confidenza, versione }
              │
              ▼
  Flow scrive campi AI_*  (mai campi di business)
              │
              ▼
  Flow deterministico: soglia? ──sì──► routing automatico
                         │
                         no
                         ▼
               Coda revisione umana ──► correzione salvata (metrica)
```

### Il contratto del servizio

Il contratto tra Flow e servizio è un JSON piccolo e stabile. Il Flow non deve sapere nulla del modello che c'è dietro.

```json
{
  "request": {
    "record_id": "500Qy00000AbCdE",
    "tipo": "case_email",
    "oggetto": "R: ordine 4471 consegna parziale",
    "testo": "Buongiorno, vi segnalo che dell'ordine 4471 sono arrivati solo 3 colli su 5...",
    "lingua_attesa": "it"
  },
  "response": {
    "categoria": "reclamo_consegna",
    "confidenza": 0.91,
    "campi": {
      "numero_ordine": "4471",
      "urgenza": "media",
      "rischio_disdetta": false
    },
    "motivazione_breve": "Segnala consegna incompleta di un ordine identificato.",
    "versione_modello": "classificatore-case-v7",
    "versione_prompt": "2026-11-02",
    "esito_validazione": "ok"
  }
}
```

E il servizio, ridotto all'osso, con la parte che conta: categorie chiuse, validazione, soglia gestita come dato e non come prompt.

```python
from enum import Enum
from pydantic import BaseModel, Field, ValidationError
from fastapi import FastAPI

class Categoria(str, Enum):
    reclamo_consegna = "reclamo_consegna"
    reclamo_qualita = "reclamo_qualita"
    richiesta_info = "richiesta_info"
    ordine = "ordine"
    amministrazione = "amministrazione"
    altro = "altro"

class Classificazione(BaseModel):
    categoria: Categoria
    confidenza: float = Field(ge=0, le=1)
    numero_ordine: str | None = Field(default=None, pattern=r"^\d{3,8}$")
    urgenza: str = Field(pattern=r"^(bassa|media|alta)$")
    rischio_disdetta: bool
    motivazione_breve: str = Field(max_length=200)

app = FastAPI()

@app.post("/classifica/case")
def classifica(req: dict):
    testo = pulisci(req["testo"])               # via firme, citazioni, disclaimer
    grezzo = chiama_modello(testo, schema=Classificazione.model_json_schema())
    try:
        c = Classificazione.model_validate_json(grezzo)
    except ValidationError:
        return {"categoria": "altro", "confidenza": 0.0,
                "esito_validazione": "schema_non_valido",
                "versione_modello": VERSIONE_MODELLO}
    if c.numero_ordine and not ordine_esiste(c.numero_ordine):
        c.numero_ordine = None                  # mai un riferimento inventato
        c.confidenza = min(c.confidenza, 0.5)
    return {**c.model_dump(), "esito_validazione": "ok",
            "versione_modello": VERSIONE_MODELLO, "versione_prompt": VERSIONE_PROMPT}
```

Notare `ordine_esiste`: il numero d'ordine estratto viene verificato contro una fonte. Se non esiste, non viene scritto. È lo stesso principio del pezzo su [JSON Schema e tool calling con gli IBAN]({{ '/it/blog/json-schema-tool-calling-iban/' | relative_url }}): lo schema garantisce la forma, la validazione di dominio garantisce il contenuto.

### Due vincoli Salesforce da conoscere prima

- **Callout e transazioni.** In un record-triggered flow, il callout HTTP va nel **percorso asincrono** (o in un'azione che gira dopo il commit). Fare un callout dopo un'operazione DML nella stessa transazione produce il classico errore di "uncommitted work pending". Il percorso asincrono risolve il problema e, in più, non fa aspettare l'utente.
- **Limiti per transazione.** Ogni transazione ha un tetto di callout e un timeout complessivo. Un import di 10.000 Case che attiva 10.000 callout sincroni è un problema di progettazione: in quei casi conviene un'elaborazione in batch fuori piattaforma (il servizio legge i record nuovi via API e scrive i risultati con un utente di integrazione con permessi limitati ai soli campi `AI_*`).

## Anti-pattern: l'LLM dentro ogni Flow

Una volta che il servizio di classificazione funziona, arriva la tentazione: "già che c'è, usiamolo anche per…". È il momento in cui un'architettura sana diventa un problema. Gli anti-pattern che vedo più spesso:

**1. L'LLM come motore di regole.** Un'azione "chiedi al modello cosa fare" al posto di un elemento Decision. Il modello riceve il record e restituisce "assegna a Mario" o "applica sconto 10%". Hai sostituito una regola verificabile con un'opinione probabilistica.

**2. Un callout al modello in ogni Flow.** Ogni record-triggered flow dell'org ha una sua chiamata al modello: per riassumere, per arricchire, per "dare un punteggio". Risultato: latenza su ogni salvataggio, costi che crescono con il volume di record e non con il valore, decine di prompt sparsi nell'org senza versione né test.

**3. Il modello che scrive nei campi di business.** La risposta del modello finisce direttamente in `Status`, `Owner`, `Amount`, `CloseDate`. Non c'è più modo di distinguere ciò che ha deciso una persona, ciò che ha deciso una regola e ciò che ha ipotizzato un modello.

**4. L'agente che orchestra Salesforce.** L'agente MCP riceve un compito ("gestisci i nuovi Case di oggi") e decide da solo quali tool chiamare, in che ordine, su quali record. Per alcuni casi d'uso assistiti da una persona va bene; come sostituto dell'automazione di processo è fragile, difficile da testare e costoso. Se devi farlo, servono permessi minimi, coda di approvazione e un [kill switch per l'agente su Salesforce]({{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }}).

**5. Il prompt come documentazione del processo.** Le regole di business vivono dentro il prompt ("se il cliente è Gold e l'ordine supera 10.000 euro, allora…"). Nessun admin le vede, nessun test le copre, nessun change set le traccia.

**6. Nessuna soglia di confidenza.** Il modello classifica tutto, e tutto viene instradato automaticamente. Il 5% di errori diventa invisibile, fino a quando un reclamo grave finisce nella coda "richieste informazioni" e nessuno lo vede per una settimana.

La regola che uso per sintetizzare: **il modello produce dati, le regole producono azioni**. Se un elemento del processo produce un'azione (assegnare, approvare, cambiare stato, inviare), deve essere deterministico. Se produce un dato da un testo, può essere un modello, con confidenza e revisione.

## Error handling e retry diversi

Flow e servizio di classificazione falliscono in modi diversi, e vanno gestiti in modi diversi. Confonderli è una delle cause più comuni di comportamenti strani in produzione.

**Errori di Flow** (deterministici): un campo obbligatorio vuoto, un record bloccato da un altro processo, una validation rule che scatta, un limite di governor superato. Si gestiscono con i **fault path**: registrare l'errore in un oggetto di log, notificare l'admin, e — se ha senso — riprovare più tardi con un job pianificato. Ritentare subito un errore deterministico non serve: fallirà di nuovo.

**Errori del servizio** (probabilistici o infrastrutturali):

- **timeout o servizio non raggiungibile**: si ritenta, con backoff, un numero limitato di volte; poi il record va in revisione umana con il motivo "classificazione non disponibile";
- **output non valido** (JSON malformato, categoria inesistente): non si ritenta all'infinito sperando in una risposta migliore; al massimo un secondo tentativo, poi `altro` con confidenza zero e revisione umana;
- **confidenza bassa**: non è un errore, è un esito. Il record va in revisione umana, ed è normale che succeda.

La regola d'oro: **un errore del servizio non deve mai bloccare il salvataggio del record**. Il Case deve esistere anche se la classificazione fallisce. Per questo il callout sta nel percorso asincrono e scrive solo campi `AI_*`: nel caso peggiore, il record resta senza classificazione e finisce nella coda manuale, esattamente come prima che il modello esistesse.

Sul lato idempotenza: se il servizio viene chiamato due volte per lo stesso record (un retry, un aggiornamento del record che riattiva il Flow), deve restituire lo stesso risultato o almeno non creare effetti doppi. Visto che scrive solo campi di classificazione, l'effetto doppio è innocuo; ma conviene comunque registrare nel record la versione e l'ora della classificazione, e non riclassificare se il testo non è cambiato.

## Costi di manutenzione a 18 mesi

La decisione "Flow o LLM" viene quasi sempre presa guardando il costo di costruzione. Il costo vero sta nei diciotto mesi successivi. Ecco cosa ho visto succedere, con stime indicative.

**Flow ben progettato:**

- costruzione: da poche ore a qualche giorno per un processo medio;
- manutenzione: modifiche quando cambiano le regole di business, fatte da un admin, testate in sandbox, rilasciate con le procedure dell'org;
- rischio principale: accumulo di Flow sovrapposti e poco documentati, che rende ogni modifica lenta. Si combatte con convenzioni di naming, un Flow per oggetto e per momento (prima/dopo il salvataggio), documentazione minima;
- costo a 18 mesi: prevedibile, legato al numero di cambi di regole.

**Servizio di classificazione con LLM:**

- costruzione: da qualche giorno a due settimane per il primo caso d'uso (servizio, prompt, schema, validazioni, integrazione, set di valutazione);
- manutenzione continua: aggiornamenti del modello (che cambiano il comportamento anche se il prompt non cambia), revisione del set di valutazione, analisi delle correzioni umane, aggiustamenti di soglia, nuove categorie quando il business cambia;
- rischio principale: **deriva silenziosa**. Il comportamento peggiora lentamente (nuovi tipi di email, un modello aggiornato, un cambio nei template dei clienti) e nessuno se ne accorge finché le correzioni in coda manuale non raddoppiano;
- costo a 18 mesi: meno prevedibile, legato alla qualità del monitoraggio. Con un set di valutazione e metriche sulle correzioni, è gestibile; senza, è un debito che cresce.

| Voce (stima, 18 mesi) | Flow per regole | Servizio LLM di classificazione |
|---|---|---|
| Costruzione iniziale | 1–5 giorni | 5–15 giorni |
| Manutenzione ricorrente | 0,5–2 giorni/mese, a seconda dei cambi di regole | 1–3 giorni/mese (valutazione, soglie, deriva) |
| Costo di esecuzione | incluso nella licenza | 20–200 €/mese (inferenza self-hosted o API UE, dipende dal volume) |
| Competenze richieste | admin Salesforce | admin + sviluppatore + chi valuta la qualità |
| Rischio principale | complessità accumulata | deriva silenziosa |

Il confronto non dice "Flow è meglio". Dice che il modello va usato **dove il suo costo è ripagato dal lavoro manuale che toglie**: smistare 300 email al giorno a mano costa molto più di un servizio di classificazione, anche con la sua manutenzione. Calcolare la data di rinnovo con un modello costa più di una formula e non toglie niente.

## Governance: change set vs prompt

Un'org Salesforce matura ha una governance per le modifiche: sandbox, test, rilascio con change set o con una pipeline basata sui metadati, approvazione, finestra di rilascio. Un Flow non arriva in produzione senza passare da lì.

Il prompt di un servizio LLM, nella maggior parte dei progetti che ho visto, arriva in produzione con un "ho cambiato due parole nel prompt, ora funziona meglio". Senza test, senza versione, senza che nessuno nell'org sappia che il comportamento della classificazione è cambiato.

La regola è semplice: **il prompt è codice, e segue lo stesso processo**. Concretamente:

- prompt, schema di output e soglie stanno in un repository, versionati;
- ogni modifica passa da un **set di valutazione** (qualche centinaio di testi reali anonimizzati con la classificazione corretta) e non viene rilasciata se l'accuratezza su categorie critiche scende;
- la versione del prompt e del modello viene scritta nel record Salesforce insieme alla classificazione (`AI_Versione_Modello__c`), così puoi sempre ricostruire chi ha classificato cosa e con quale versione;
- l'aggiornamento del modello sottostante è una modifica come le altre, anche se il prompt non cambia;
- le soglie di confidenza sono configurazione (Custom Metadata in Salesforce, o configurazione del servizio), non costanti nel prompt.

```yaml
# classificatore-case/release.yaml — gate di rilascio
versione_prompt: "2026-11-02"
modello: classificatore-case-v7
set_valutazione: eval/case-email-2026q3.jsonl   # 600 email anonimizzate, etichettate a mano
soglie_rilascio:
  accuratezza_globale_min: 0.88
  per_categoria_min:
    reclamo_consegna: 0.90
    reclamo_qualita: 0.90
    ordine: 0.93
  falsi_negativi_rischio_disdetta_max: 0.05
soglia_confidenza_routing: 0.80      # sotto: revisione umana
approvato_da: responsabile_customer_care
```

Come si costruisce e si mantiene un set di valutazione è un argomento a sé: ne ho scritto nel pezzo sulla [valutazione degli agenti LLM in produzione]({{ '/it/blog/valutazione-agenti-llm-produzione/' | relative_url }}).

## Matrice di scelta per 10 automazioni tipiche

Ecco dieci automazioni che compaiono in quasi tutte le org che ho visto, con la scelta che farei e il motivo.

| # | Automazione | Scelta | Perché |
|---|---|---|---|
| 1 | Calcolo di importi, IVA, sconti da listino | **Flow / formula** | Regola esatta; un modello aggiunge solo rischio |
| 2 | Assegnazione lead per territorio, settore, dimensione | **Flow** | Tabella di regole; deve essere verificabile e spiegabile |
| 3 | Promemoria di rinnovo a 60/30/7 giorni | **Flow pianificato** | Date e campi strutturati; nessun testo da interpretare |
| 4 | Smistamento email in arrivo (Email-to-Case) per tipo di richiesta | **Ibrido** | Testo libero → classificazione → routing deterministico con soglia |
| 5 | Estrazione di numero d'ordine e importo da PDF allegato | **Ibrido** | Il modello estrae, la validazione verifica contro l'anagrafica, Flow aggiorna |
| 6 | Individuazione di account duplicati con nomi diversi | **Ibrido, con revisione** | Regole per i casi ovvi (P.IVA uguale), modello per i casi ambigui, sempre conferma umana prima del merge |
| 7 | Passaggio opportunità a "Chiusa vinta" alla firma del contratto | **Flow** | Evento preciso (contratto firmato), effetto economico; nessuna ambiguità ammessa |
| 8 | Sintesi delle note di una call con prossimi passi | **LLM (assistito)** | Testo libero, output per la persona; il commerciale conferma prima che diventi un'attività |
| 9 | Approvazione di uno sconto fuori standard | **Flow / processo di approvazione** | Decisione con responsabilità; il modello al massimo prepara il riepilogo per chi approva |
| 10 | Segnalazione di rischio disdetta da email e note | **Ibrido** | Il modello segnala con confidenza, la regola decide l'escalation, una persona contatta il cliente |

Lo schema che emerge è netto. Dove l'input è strutturato e l'output è un'azione, Flow. Dove l'input è testo e l'output è un dato, modello, con validazione. Dove servono entrambi, ibrido, con il modello che produce campi e Flow che decide. Nessuna delle dieci righe richiede un agente che orchestri Salesforce in autonomia.

## Percorso di implementazione, a step

1. **Inventario delle code manuali.** Dove, oggi, una persona legge testo e decide a mano? Quante volte al giorno? Quanto tempo per caso? Questi sono i candidati, non "i Flow che potremmo sostituire".
2. **Scegli un solo caso** con volume alto e rischio contenuto (tipicamente lo smistamento delle email in arrivo).
3. **Costruisci il set di valutazione**: 300–600 esempi reali anonimizzati, etichettati da chi oggi fa il lavoro.
4. **Definisci categorie chiuse e campi** con lo stesso responsabile. Una categoria "altro" è obbligatoria.
5. **Costruisci il servizio** (self-hosted o endpoint in UE), con schema di output, validazioni di dominio e versione.
6. **Misura sul set di valutazione** prima di toccare Salesforce. Se l'accuratezza sulle categorie critiche non è sufficiente, fermati qui.
7. **Crea i campi `AI_*`** e i permessi: solo l'utente di integrazione (o il Flow) li scrive, gli utenti li vedono.
8. **Crea il Flow** con percorso asincrono, callout con Named Credential, fault path e scrittura dei campi.
9. **Fase ombra** di 2–4 settimane: la classificazione viene scritta ma il routing resta manuale. Le persone vedono il suggerimento e lo confermano o correggono.
10. **Attiva il routing automatico** sopra soglia, con coda di revisione sotto soglia.
11. **Monitora** le correzioni e l'accuratezza per categoria; rivedi soglie e prompt con il gate di rilascio.

## Fallimenti tipici e come li riconosci dai log

**Callout nella transazione sbagliata.**

```text
FLOW_ELEMENT_ERROR  Case_Classifica_Email | HTTP_Classifica
System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
```

Il callout è nel percorso sincrono dopo un aggiornamento di record. Spostalo nel percorso asincrono.

**Classificazioni sempre sotto soglia.**

```text
2026-11-13T09:12:44 classify record=500Qy… categoria=altro confidenza=0.00 esito=schema_non_valido
2026-11-13T09:12:51 classify record=500Qy… categoria=altro confidenza=0.00 esito=schema_non_valido
```

Il modello restituisce output che non rispetta lo schema: aggiornamento del modello, cambio del prompt non testato, oppure testi più lunghi del previsto che vengono troncati. La coda manuale si riempie: è il sistema che degrada in sicurezza, ma va sistemato.

**Deriva lenta.** Non c'è una riga di log che la mostri: la vedi nella metrica settimanale delle correzioni umane. Se la percentuale di classificazioni corrette a mano passa dal 6% al 14% in due mesi, qualcosa è cambiato negli input (nuovo template di un cliente grande, nuovo tipo di richieste) o nel modello.

**Riclassificazioni a cascata.**

```text
2026-11-13T10:01:02 classify record=500Qy…AbC version=7 (trigger: update)
2026-11-13T10:01:09 classify record=500Qy…AbC version=7 (trigger: update)
2026-11-13T10:01:15 classify record=500Qy…AbC version=7 (trigger: update)
```

Il Flow scrive i campi `AI_*`, l'aggiornamento riattiva il Flow, che richiama il servizio. Serve una condizione d'ingresso che escluda gli aggiornamenti dei soli campi di classificazione, o un controllo "testo non cambiato".

**Campi estratti inventati.** Il numero d'ordine estratto non esiste in anagrafica. Se nel log vedi `numero_ordine_non_trovato` con frequenza, il modello sta "completando" riferimenti incompleti: la validazione li sta fermando, ma conviene rivedere il prompt.

## Quando NON farlo

- **Quando la coda manuale è piccola.** Venti email al giorno da smistare sono dieci minuti di una persona. Non giustificano un servizio, un set di valutazione e una manutenzione mensile.
- **Quando il problema vero sono regole mal fatte.** Se il routing sbaglia perché le regole sono vecchie o sovrapposte, sistemare il Flow costa meno e risolve di più.
- **Quando non c'è nessuno che etichetta.** Senza un set di valutazione costruito da chi conosce il lavoro, non sai se il modello funziona. E se non lo sai, non dovresti instradare niente in automatico.
- **Quando l'azione ha effetti economici diretti.** Prezzi, sconti, crediti, fatture: lì il modello al massimo prepara un riepilogo per una persona.
- **Quando i testi contengono dati che non possono uscire dall'org** e non hai un'opzione di inferenza self-hosted o in UE con garanzie adeguate. Prima la questione dei dati, poi l'architettura: il quadro è nel pezzo su [GDPR, ChatGPT e dati del CRM]({{ '/it/blog/gdpr-chatgpt-crm/' | relative_url }}).

## Checklist operativa

- [ ] Il caso d'uso nasce da una coda manuale misurata (volume, tempo per caso), non da "mettiamo l'AI".
- [ ] Le regole esatte (calcoli, assegnazioni, transizioni di stato) restano in Flow, formula o Apex.
- [ ] Il modello produce solo dati in campi `AI_*`, mai azioni né campi di business.
- [ ] Categorie chiuse, con "altro" obbligatoria; schema di output validato dal servizio.
- [ ] Validazione di dominio sui campi estratti (riferimenti verificati contro l'anagrafica).
- [ ] Callout nel percorso asincrono, con Named Credential e fault path.
- [ ] Un errore del servizio non blocca mai il salvataggio del record.
- [ ] Soglia di confidenza come configurazione; sotto soglia, coda di revisione umana.
- [ ] Versione di modello e prompt scritta nel record.
- [ ] Set di valutazione e gate di rilascio per ogni modifica di prompt o modello.
- [ ] Metrica settimanale delle correzioni umane, per categoria.
- [ ] Condizioni di ingresso del Flow che evitano riclassificazioni a cascata.
- [ ] Fase ombra conclusa con numeri prima di attivare il routing automatico.

## Il verdetto

La domanda "Salesforce Flow o agente MCP?" è posta male, perché mette in competizione due strumenti che fanno cose diverse. Flow è codice con contratti: deterministico, versionato, verificabile, ed è *più sicuro* di qualsiasi modello quando la regola esiste. Il modello linguistico è l'unico strumento ragionevole quando c'è da leggere disordine — email libere, note, allegati — e trasformarlo in qualcosa che le regole possano usare.

L'architettura che regge nel tempo li mette in fila, non in alternativa: l'evento in Salesforce, il Flow che chiama un servizio di classificazione, il servizio che restituisce dati con una confidenza, il Flow che decide con regole e soglie, una persona che guarda i casi incerti. Il modello produce dati, le regole producono azioni. Tutto il resto — l'LLM dentro ogni Flow, l'agente che orchestra l'org, le regole di business nascoste in un prompt — è debito tecnico con una bella demo.

Se stai decidendo dove mettere un modello linguistico nei tuoi processi CRM e vuoi farlo senza smontare ciò che già funziona, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e il resto del lavoro su [antoniotrento.net]({{ site.main_site }}/). Gli altri pezzi sugli agenti che agiscono su sistemi reali sono raccolti nella guida sugli [agenti che eseguono]({{ '/it/pillar/agenti-esecuzione/' | relative_url }}).

## FAQ

### Quando usare Salesforce Flow invece di un agente AI?

Quando esiste una regola che dà la risposta giusta: calcoli, assegnazioni per territorio, transizioni di stato, promemoria su date, approvazioni secondo una matrice. In questi casi Flow è deterministico, versionato e verificabile, e un modello linguistico aggiunge solo costo, latenza e rischio di errori non spiegabili.

### Quando serve davvero un LLM in Salesforce?

Quando l'input è testo non strutturato e la domanda è interpretativa: smistare email libere, estrarre dati da allegati, sintetizzare note di call, segnalare un rischio di disdetta. In questi casi il modello trasforma il disordine in campi strutturati, che poi le regole usano.

### Cos'è lo schema ibrido "classifica → campo → Flow"?

È un'architettura in cui un Flow, all'arrivo di un record, chiama un servizio esterno di classificazione; il servizio restituisce categoria, campi estratti e confidenza; il Flow li scrive in campi dedicati e poi applica regole deterministiche, instradando in automatico sopra una soglia di confidenza e verso una revisione umana sotto soglia.

### Perché Flow deve chiamare il servizio e non il contrario?

Perché l'orchestrazione deve restare dove ci sono transazioni, versioni, permessi e audit. Se è il servizio con il modello a decidere quali record modificare e come, il processo diventa difficile da testare, da spiegare e da fermare. Con Flow come orchestratore, il modello è solo un fornitore di dati.

### Come si gestisce un errore del servizio di classificazione?

Il callout va nel percorso asincrono, così un errore non blocca mai il salvataggio del record. Timeout e indisponibilità si ritentano con backoff per un numero limitato di volte; output non validi producono una classificazione "altro" con confidenza zero. In entrambi i casi il record finisce nella coda di revisione manuale, come prima dell'introduzione del modello.

### Perché non bisogna mettere un LLM in ogni Flow?

Perché ogni chiamata aggiunge latenza, costo e una dipendenza esterna, e porta con sé un prompt da versionare e testare. Distribuire chiamate al modello in tutti i Flow dell'org crea decine di comportamenti probabilistici non documentati. Il modello va usato solo dove toglie lavoro manuale reale su testo non strutturato.

### Come si versionano i prompt in un'org Salesforce?

Trattandoli come codice: prompt, schema e soglie in un repository, ogni modifica valutata su un set di esempi etichettati con soglie minime di accuratezza per categoria, versione di prompt e modello scritta nel record classificato. Le soglie di confidenza stanno in configurazione, non nel testo del prompt.

### Quanto costa mantenere un servizio di classificazione LLM?

Indicativamente da 5 a 15 giorni di costruzione per il primo caso d'uso, uno-tre giorni al mese di manutenzione per valutazione, soglie e deriva, e da qualche decina a qualche centinaio di euro al mese di inferenza a seconda del volume. Si ripaga quando toglie lavoro manuale consistente, come lo smistamento di centinaia di email al giorno.

### Un agente MCP può sostituire i Flow di Salesforce?

Non come motore di processo. Un agente MCP è utile per compiti assistiti da una persona, con permessi minimi e approvazioni, ma non offre il determinismo, la verificabilità e la governance necessari per le automazioni che toccano soldi, stati e assegnazioni. Per queste, Flow resta la scelta più sicura.

### Come si accorge di una deriva del modello?

Misurando ogni settimana la percentuale di classificazioni corrette a mano dalle persone, per categoria, e ripetendo periodicamente la valutazione sul set di riferimento. Un aumento costante delle correzioni indica che sono cambiati gli input o il modello, e che prompt o soglie vanno rivisti.
