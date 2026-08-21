---
lang: it
permalink: /it/blog/n8n-self-hosted-openai-privacy/
title: "Perché il tuo workflow n8n con GPT-4o sta inviando i dati dei clienti a OpenAI (e come chiuderlo in Docker in 90 minuti)"
date: 2026-09-18 07:30:00 +0200
author: "Antonio Trento"
description: "Self-hosti n8n sul tuo VPS e pensi di essere a posto col GDPR. Ma il nodo OpenAI manda body, allegati e PII in chiaro fuori dall'UE. Ecco cosa esce davvero e come chiudere il recinto in Docker."
keywords: ["n8n self-hosted openai privacy", "n8n docker", "gdpr llm", "dati clienti openai", "workflow n8n produzione"]
image: /assets/images/posts/n8n-self-hosted-openai-privacy.jpg
pillar: stack-sovrano
related: [/it/blog/poc-intelligenza-artificiale-fallito/, /it/blog/prodotto-llm-vs-chatbot/]
---

## Il malinteso che ti costa una segnalazione al Garante

Hai installato n8n sul tuo VPS, magari in Docker, magari con un bel dominio dietro HTTPS. Ti sei detto: "i dati sono a casa mia, sto rispettando il GDPR". È il malinteso più diffuso e più pericoloso di chi costruisce automazioni con l'AI in Italia, ed è il motivo per cui **n8n self-hosted con un nodo OpenAI non ti mette al riparo da niente**. Perché il workflow gira sul tuo server, sì — ma nel momento esatto in cui il nodo OpenAI (o Anthropic, o qualunque LLM cloud) parte, il contenuto che gli passi — il testo della mail del cliente, l'allegato, il nome, l'IBAN, il codice fiscale — **esce dal tuo recinto e viaggia verso gli Stati Uniti.** Self-hostare l'orchestratore e poi mandare i dati in chiaro a un modello cloud è come mettere una porta blindata e lasciare la finestra spalancata.

Questo articolo smonta il mito e mostra il recinto vero. Parlo a chi monta roba in produzione — founder, CTO, responsabili IT di PMI italiane — non a chi fa slide. Vediamo, con precisione tecnica: cosa esce davvero da un nodo LLM cloud, quali nodi di n8n esfiltrano dati senza che tu te ne accorga, come si fa la *redaction* prima del modello, e come si chiude tutto in un'architettura Docker sovrana — n8n + Ollama + Postgres sulla stessa rete — in circa 90 minuti. Con il `docker-compose`, un filtro PII di esempio, e la checklist che puoi mettere sul tavolo di un DPO. Perché "è sul mio VPS" non è una risposta: è l'inizio del problema.

## "È sul mio VPS, quindi è GDPR-ok": perché è falso

Rompiamo subito l'illusione, perché è la radice di tutto. Il ragionamento sbagliato è: *il software gira su un server che controllo io, quindi i dati sono sotto il mio controllo.* Vero per n8n in sé. Falso per ciò che n8n **manda fuori**.

Un workflow n8n è un orchestratore: prende dati da qualche parte, li fa passare attraverso dei nodi, e li manda da qualche altra parte. Se uno di quei nodi è "OpenAI" o "Anthropic" o "HTTP Request verso api.openai.com", allora quel nodo **fa una chiamata di rete verso un server americano**, e nel corpo di quella chiamata ci sono i tuoi dati. Il fatto che n8n giri sul tuo VPS è irrilevante per quella chiamata: è come dire che una lettera è privata perché l'hai scritta a casa tua, mentre la stai imbucando verso un altro continente.

Dal punto di vista del GDPR, quando mandi dati personali a un LLM cloud stai facendo un **trasferimento di dati verso un responsabile del trattamento** (il fornitore del modello), spesso **fuori dall'UE**. Questo richiede una base giuridica, un accordo sul trattamento dei dati (DPA), garanzie sul trasferimento extra-UE, e — soprattutto — che tu *sappia e possa dimostrare* cosa esce. "Self-hosted n8n" non ti dà nessuna di queste cose per la parte LLM. Ti dà solo il controllo dell'orchestratore, che è la metà che *non* è il problema.

Il punto pratico è questo: **il confine dei tuoi dati non è dove gira n8n, è dove gira il modello.** Se il modello è cloud, il confine è a casa loro. Se vuoi il confine a casa tua, il modello deve girare a casa tua — ed è tutto il senso di uno stack sovrano, di cui questo articolo è il primo mattone. È la stessa lucidità che serve a non farsi abbagliare quando [un PoC di AI promette tutto e finisce nel cassetto]({{ '/it/blog/poc-intelligenza-artificiale-fallito/' | relative_url }}): conta l'architettura reale, non l'etichetta "self-hosted" appiccicata sopra.

## Cosa esce davvero da un nodo OpenAI/Anthropic

Andiamo sul concreto. Quando un nodo LLM cloud parte, cosa lascia davvero il tuo server? Più di quanto immagini.

- **Il body completo del prompt.** Tutto il testo che componi — istruzioni + dati. Se nel prompt hai infilato "riassumi questa mail del cliente: [testo con nome, azienda, importo, IBAN]", tutto quel testo parte. Il modello non "vede solo la parte che gli serve": riceve il payload intero.
- **Gli allegati e i file.** Se usi le funzioni di visione o di analisi documenti, il PDF, l'immagine, il file viaggiano interi. Una fattura, un contratto, una carta d'identità caricata da un cliente: parte tutto.
- **Gli header e i metadati.** La chiamata porta con sé header, a volte identificativi, e viene loggata lato vendor con timestamp e riferimenti.
- **I retry.** Ecco il dettaglio che quasi nessuno considera: se la chiamata fallisce e n8n fa retry, i dati escono **più volte**. Un errore transitorio significa lo stesso payload sensibile inviato due, tre volte.
- **I log del vendor.** Il fornitore, per policy, può conservare gli input per un periodo (per abuso/monitoraggio), a meno che tu non abbia un accordo specifico che lo esclude. Quindi i tuoi dati non solo transitano: possono **restare** loggati altrove per un tempo che non controlli.

La domanda da porsi, davanti a ogni workflow, è brutale: *se il contenuto di questa chiamata finisse in un data breach del vendor, o su un tavolo di un'ispezione, cosa ci sarebbe dentro?* Se la risposta include dati personali dei tuoi clienti, hai un problema — indipendentemente da dove gira n8n. Il valore di un output AI, del resto, sta nel **processo controllato** che lo produce, non nel modello in sé: è la tesi che sviluppo in [perché non ti serve "un modello" ma un processo affidabile]({{ '/it/blog/prodotto-llm-vs-chatbot/' | relative_url }}). E un processo controllato comincia dal sapere cosa esce.

## La mappa dei nodi n8n che esfiltrano senza che tu te ne accorga

Il nodo OpenAI è quello ovvio. Ma in un workflow n8n ci sono altri punti di fuga meno evidenti, ed è lì che ci si fa male perché non li si guarda. Ecco la mappa dei sospetti:

- **I nodi LLM diretti**: OpenAI, Anthropic, Google Gemini, Mistral (endpoint cloud), Cohere. Ovvi: mandano il prompt al vendor.
- **Il nodo "AI Agent" / chains di LangChain** dentro n8n: se il modello configurato è cloud, ogni step di ragionamento dell'agente è una chiamata che esce — e un agente fa *molte* chiamate, moltiplicando l'esfiltrazione.
- **I nodi di embedding cloud**: per fare RAG spesso si generano embedding. Se usi l'embedding di OpenAI, **ogni chunk di ogni documento** che indicizzi viene mandato al vendor. Indicizzi 10.000 fatture? Sono 10.000 pezzi di documento in uscita.
- **Il nodo HTTP Request**: il jolly. Chiama qualunque API esterna. Facile da dimenticare che quella "innocua" chiamata a un servizio di arricchimento dati, di traduzione, di OCR cloud, sta mandando fuori il payload.
- **I nodi di terze parti** (traduzione, transcription, OCR, "enrichment"): ognuno è un endpoint esterno che riceve i tuoi dati.
- **La telemetria di n8n stesso**: n8n di default può inviare dati diagnostici e di utilizzo. Non è il body dei clienti, ma è comunque traffico in uscita da spegnere in un contesto sovrano (le variabili per farlo sono nel compose più avanti).

Il metodo per trovarli è semplice e va fatto **una volta per ogni workflow in produzione**: apri il workflow, elenca ogni nodo che fa una chiamata di rete verso un host che non controlli, e per ognuno chiediti *cosa gli passo nel body*. Se la risposta contiene dati personali o riservati, quel nodo è un punto di fuga da chiudere — o con la redaction (prossima sezione) o sostituendolo con un equivalente locale (sezione dopo).

## Redaction prima del modello: PII, IBAN, CF, PEC, allegati

La prima linea di difesa, e quella che puoi mettere subito anche se per ora resti su un LLM cloud per certi task, è la **redaction**: rimuovere o mascherare i dati sensibili *prima* che il testo raggiunga il modello. L'idea è che il modello lavori su un testo "ripulito" dove nome, IBAN, codice fiscale, email, PEC e numeri di telefono sono sostituiti da segnaposto, e — se serve — reinserisci i valori veri nell'output dopo, in locale.

Ecco un esempio di filtro PII in Python, pensato per girare come piccolo sidecar (un microservizio che n8n chiama sulla rete Docker interna) o come riferimento per un Function node. Copre i casi italiani più comuni:

```python
import re

# Redaction minima per payload in italiano PRIMA di un LLM.
# NON e' esaustiva: e' una base di partenza da estendere sul tuo dominio.
PATTERNS = {
    "IBAN":  re.compile(r"\bIT\d{2}[A-Z]\d{10}[0-9A-Z]{12}\b"),
    "CF":    re.compile(r"\b[A-Z]{6}\d{2}[A-EHLMPRST]\d{2}[A-Z]\d{3}[A-Z]\b"),
    "PIVA":  re.compile(r"\b\d{11}\b"),
    "EMAIL": re.compile(r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b"),
    "TEL":   re.compile(r"\b(?:\+39\s?)?3\d{2}[\s.\-]?\d{6,7}\b"),
}

def redigi(testo: str) -> tuple[str, dict]:
    mappa = {}
    for tag, pat in PATTERNS.items():
        for i, m in enumerate(pat.findall(testo)):
            token = f"[{tag}_{i}]"
            mappa[token] = m
            testo = testo.replace(m, token, 1)
    return testo, mappa   # 'mappa' resta in locale per il re-inserimento

def reinserisci(output: str, mappa: dict) -> str:
    for token, valore in mappa.items():
        output = output.replace(token, valore)
    return output
```

La logica: `redigi()` sostituisce i dati sensibili con token e tiene la corrispondenza in una `mappa` che **non lascia mai il tuo server**; mandi al modello solo il testo con i token; quando torna la risposta, `reinserisci()` rimette i valori veri in locale. Il modello cloud non ha mai visto un IBAN o un codice fiscale vero.

Due avvertenze oneste, perché la redaction non è una bacchetta magica:

- **Non è mai completa.** Un nome proprio ("Mario Rossi") è molto più difficile da individuare di un IBAN con un pattern fisso; servono liste, NER (riconoscimento entità), e comunque qualcosa sfugge. La redaction riduce il rischio, non lo azzera.
- **Gli allegati sono il buco grande.** Redigere il testo è fattibile; redigere un PDF o un'immagine prima di mandarli a un modello di visione è molto più complesso. Per gli allegati con dati personali, la risposta seria non è "redigo il PDF": è "il modello che li legge gira in locale".

Ed è proprio per questo che la redaction è un cerotto utile ma parziale. La soluzione strutturale è un'altra: **portare il modello dentro il recinto.**

## L'architettura chiusa: n8n + Ollama + Postgres sulla stessa rete Docker

Ecco il recinto vero. Invece di mandare i dati a un modello cloud, fai girare il modello **in locale**, sulla stessa rete Docker di n8n, così che il payload non lasci mai il tuo server. I componenti:

- **n8n** — l'orchestratore dei workflow.
- **Ollama** — il runtime che serve modelli linguistici in locale (Llama, Mistral, Qwen e simili), con un'API compatibile che n8n può chiamare via HTTP. Per carichi seri o multi-utente si passa a **vLLM**, ma per iniziare Ollama è il più veloce da mettere in piedi.
- **Postgres** — il database di n8n (e, quando aggiungi il RAG, la base con `pgvector` per gli embedding).

La chiave è la **rete Docker interna**: n8n parla con Ollama e Postgres tramite nomi di servizio interni (`http://ollama:11434`), su una rete che non è esposta a internet. Il traffico dei dati resta *dentro* la macchina. Ecco un `docker-compose.yml` di partenza:

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: n8n
    volumes:
      - pgdata:/var/lib/postgresql/data
    networks: [sovrano]
    restart: unless-stopped

  ollama:
    image: ollama/ollama:latest
    volumes:
      - ollama:/root/.ollama
    networks: [sovrano]
    # GPU (opzionale, consigliata per latenza decente):
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities: [gpu]
    restart: unless-stopped

  n8n:
    image: n8nio/n8n:latest
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD}
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}
      # Spegni telemetria e chiamate in uscita non necessarie:
      N8N_DIAGNOSTICS_ENABLED: "false"
      N8N_VERSION_NOTIFICATIONS_ENABLED: "false"
      N8N_TEMPLATES_ENABLED: "false"
      # Ollama raggiungibile a http://ollama:11434
    ports:
      - "127.0.0.1:5678:5678"   # SOLO loopback: si arriva via reverse proxy
    depends_on: [postgres, ollama]
    networks: [sovrano]
    restart: unless-stopped

volumes:
  pgdata:
  ollama:

networks:
  sovrano:
    driver: bridge
```

Due dettagli che fanno la differenza tra "sembra chiuso" e "è chiuso":

- **La porta di n8n è legata a `127.0.0.1`**, non esposta su tutte le interfacce. Ci si arriva solo tramite un reverse proxy (Caddy/Nginx) con HTTPS e autenticazione davanti — non direttamente da internet.
- **La telemetria di n8n è spenta** (`N8N_DIAGNOSTICS_ENABLED: "false"`). Piccola cosa, ma in un contesto sovrano ogni chiamata in uscita va giustificata o chiusa.

Nel workflow, invece del nodo OpenAI, usi un nodo HTTP Request (o il nodo Ollama, se preferisci) verso `http://ollama:11434/api/generate`. Il payload va da n8n a Ollama sulla rete `sovrano` e **non tocca internet**. Il modello legge il nome, l'IBAN, l'allegato — ma sono a casa tua, sotto il tuo controllo, senza retry che escono e senza log di terzi.

## Quando il cloud LLM è accettabile (perché a volte lo è)

Sarei disonesto se dicessi "cloud LLM mai". Non è vero, e il fanatismo non aiuta nessuno. Il modello cloud è più capace, più veloce da integrare, e per certi task il locale non regge il confronto sulla qualità. Il punto non è bandirlo: è **usarlo con cognizione**, sapendo quando è accettabile.

Il cloud LLM è accettabile quando ricorre almeno una di queste condizioni:

| Condizione | Perché rende accettabile il cloud |
|---|---|
| **Dati non personali** | Se il payload non contiene dati personali né riservati (es. testo pubblico, contenuto sintetico), il problema GDPR non si pone. |
| **Dati sintetici o anonimizzati** | Se lavori su dati finti o irreversibilmente anonimizzati, non stai trattando dati personali. |
| **DPA + regione UE + no-training** | Se hai un contratto (DPA) col vendor, i dati restano in regione UE, ed è escluso il training sui tuoi input, il rischio è governato (non zero, ma governato e documentabile). |
| **Redaction robusta a monte** | Se ciò che esce è già ripulito dai dati sensibili (con i limiti visti sopra), l'esposizione è ridotta. |

La regola pratica che uso: **default locale, cloud per eccezione motivata.** Non "cloud di default e locale se qualcuno protesta", ma il contrario. Ogni volta che un workflow usa un LLM cloud, deve esserci una riga che spiega *perché* è accettabile per *quei* dati — una delle condizioni sopra. Se non riesci a scriverla, il task va sul modello locale. Questa inversione del default è tutta la differenza tra uno stack sovrano e uno stack che manda i dati fuori "perché era più comodo".

## Il playbook dei 90 minuti

Ecco il percorso per passare da "n8n che esfiltra" a "recinto chiuso", in circa 90 minuti su una macchina già pronta con Docker.

1. **Prepara l'ambiente (10 min).** Crea una cartella di progetto, il file `docker-compose.yml` di sopra e un `.env` con `POSTGRES_PASSWORD` e `N8N_ENCRYPTION_KEY` (genera chiavi robuste, non "password123").
2. **Avvia lo stack (10 min).** `docker compose up -d`. Verifica che i tre servizi siano su e in salute (`docker compose ps`, controlla i log con `docker compose logs -f`).
3. **Scarica un modello locale (15 min).** `docker compose exec ollama ollama pull llama3.1:8b` (o un modello adatto alla tua VRAM). Testa che risponda: una `curl` a `http://localhost:11434/api/generate` dall'interno.
4. **Metti n8n dietro un reverse proxy (15 min).** Caddy o Nginx con HTTPS e autenticazione davanti alla porta `127.0.0.1:5678`. Nessun accesso diretto da internet.
5. **Riscrivi il workflow critico (20 min).** Sostituisci il nodo OpenAI con una chiamata HTTP a `http://ollama:11434`. Se un task deve restare su cloud, aggiungi prima il nodo di redaction (il sidecar Python o un Function node).
6. **Testa con un payload finto (15 min).** Fondamentale: prova il workflow con un payload che contiene dati **finti ma realistici** (un IBAN finto, un CF finto, una mail finta) e verifica — con i log e con uno sniff del traffico in uscita — che *nulla* di quei dati lasci la macchina per i task che devono restare locali.
7. **Documenta i confini (5 min).** Scrivi cosa gira dove e cosa (eventualmente) esce ancora e perché. Ti serve per il DPO (prossima sezione) e per te stesso tra sei mesi.

Novanta minuti sono per la *prima chiusura* di un workflow su una macchina pronta. Non è "tutto lo stack aziendale sovrano in un'ora e mezza": è il primo recinto, quello che ferma l'emorragia più grave. Il resto — GPU, vLLM per il multi-utente, RAG locale — si costruisce dopo, sopra queste fondamenta.

## Come dimostrarlo a un DPO: la checklist dei confini

Un recinto che non sai dimostrare, ai fini della conformità, è come non averlo. Il DPO (o il consulente privacy) non guarda il tuo `docker-compose`: guarda se sai rispondere a domande precise su *dove vanno i dati*. Ecco la checklist da preparare — è anche un ottimo modo per accorgerti dei buchi che ti restano.

- **Diagramma dei confini.** Un disegno semplice: quali componenti girano dove, quale traffico resta interno (rete `sovrano`) e quale — se esiste — esce, verso chi e con che dati.
- **Inventario dei nodi che escono.** Per ogni workflow in produzione, l'elenco dei nodi che fanno chiamate esterne, con: host di destinazione, tipo di dati nel body, base giuridica/motivo.
- **Registro dei trattamenti aggiornato.** Se un LLM cloud è ancora in uso per qualche task, deve comparire come responsabile del trattamento, con DPA, regione, e clausola sul training.
- **Prova della redaction (dove applicata).** Esempi di payload prima/dopo la redaction, per i task cloud residui.
- **Log di test con payload finto.** La dimostrazione che, per i task locali, i dati finti non sono usciti.
- **Politica di retention.** Dove restano i dati in n8n/Postgres, per quanto, e come si cancellano.
- **Gestione dei segreti.** Dove stanno le chiavi/credenziali (non in chiaro nel workflow), chi vi accede.

Se sai spuntare questa lista, non stai "sperando" di essere a posto: hai le prove. Ed è la differenza tra una frase ("usiamo n8n self-hosted") e una postura difendibile davanti a un'ispezione. Chi ti vende automazioni AI senza mai nominare questa checklist ti sta preparando esattamente il problema da cui questo articolo parte.

## Cosa si rompe in produzione (e come lo riconosci dai log)

Il recinto chiuso funziona, ma in produzione ci sono guasti tipici che è meglio conoscere prima di incontrarli alle due di notte. Ecco i più comuni e come li riconosci dai log.

- **Ollama va in OOM (out of memory) sulla GPU.** Sintomo: la chiamata al modello fallisce o si blocca, e nei log di Ollama compaiono errori di allocazione memoria CUDA. Causa: hai caricato un modello troppo grande per la VRAM, o troppi modelli insieme, o un contesto (numero di token) enorme. Rimedio: modello più piccolo/quantizzato, un solo modello caldo alla volta, contesto più corto. È il guasto numero uno di chi parte con la GPU sottodimensionata.
- **Latenza che esplode sotto carico.** Sintomo: i workflow rallentano, n8n accumula esecuzioni in coda, i tempi di risposta salgono. Causa: Ollama serve una richiesta alla volta bene, ma sotto concorrenza si ingolfa. È il segnale che è ora di passare a **vLLM** (fatto per il throughput e il batching) o di aggiungere GPU. Lo vedi dai tempi di esecuzione crescenti nella cronologia di n8n.
- **n8n va in retry-storm su un nodo che fallisce.** Sintomo pericolosissimo in ottica privacy: un nodo cloud fallisce e n8n ritenta, mandando lo **stesso payload sensibile fuori più volte**. Nei log vedi esecuzioni ripetute ravvicinate sullo stesso item. Rimedio: limita i retry sui nodi che escono, e — meglio — spostali in locale così il retry non esfiltra.
- **Postgres si riempie di execution data.** Sintomo: lo spazio disco cala, n8n rallenta, i log segnalano scritture lente. Causa: n8n salva i dati di ogni esecuzione, e su workflow ad alto volume con payload grossi il database cresce in fretta — e ricorda che quei dati salvati includono i payload dei clienti. Rimedio: configura la retention delle esecuzioni (pruning) e non salvare i dati di esecuzione dove non serve; è anche un tema di minimizzazione GDPR, non solo di disco.
- **Il modello locale "allucina" più del cloud su un task.** Sintomo: output di qualità peggiore su compiti complessi. Non è un bug, è il limite del modello che sta nella tua VRAM. Rimedio onesto: per quel task specifico, o redaction + cloud, o accetti il limite, o aspetti hardware migliore — non fingi che il locale faccia tutto.

Il principio: **monitora i log di Ollama (memoria, latenza) e la cronologia di n8n (retry, tempi, coda).** La maggior parte dei guasti di uno stack sovrano non è misteriosa — è VRAM, concorrenza o retry — e si legge nei log se sai cosa cercare.

## I costi reali (in euro, VRAM, kWh)

Parliamo di numeri, perché "sovrano" non deve voler dire "cieco sui costi". Ordini di grandezza, dichiarati come stime, da adattare al tuo caso.

| Voce | Ordine di grandezza | Note |
|---|---|---|
| **VPS/server per lo stack (CPU)** | ~20-60 €/mese | Regge n8n + Postgres e un LLM piccolo su CPU, con latenza alta. Ok per volumi bassi. |
| **Server con GPU (in cloud UE)** | ~150-600 €/mese | Una GPU con abbastanza VRAM per un modello 7-8B quantizzato (~8-16 GB) o 14B+ (~24 GB). Latenza accettabile. |
| **GPU on-premise (una tantum)** | ~500-2.000 € | Una scheda con 16-24 GB VRAM per far girare in locale modelli 8-14B. Ammortizzata su mesi, spesso più economica del cloud GPU a regime. |
| **Consumo elettrico (on-prem)** | qualche decina di €/mese | Una GPU sotto carico consuma centinaia di watt; a uso intermittente sono kWh contenuti. |
| **LLM cloud (per confronto)** | a token | Comodo e senza CapEx, ma paghi per uso *e* mandi fuori i dati: il costo vero include il rischio, non solo i token. |

Il ragionamento economico onesto: per **volumi bassi e task non critici**, un LLM cloud con le giuste garanzie può costare meno in denaro. Per **volumi alti, dati sensibili, o uso continuo**, lo stack locale con GPU si ripaga — sia in euro (niente costo a token che scala) sia in rischio (i dati non escono). La VRAM è il vincolo che decide quali modelli puoi far girare: un 8B quantizzato sta in ~8 GB, un 14B in ~16-24 GB, oltre servono schede serie o vLLM su più GPU. Dimensiona il modello sulla VRAM che hai, non sul modello che vorresti.

## Quando NON farlo (o non ancora)

Lo stack sovrano non è la risposta a ogni situazione, e forzarlo dove non serve è sprecare soldi e tempo. **Non farlo, o rimandalo, se:**

- **Non tratti dati personali né riservati.** Se i tuoi workflow lavorano su contenuti pubblici o non sensibili, il recinto locale è una complicazione senza beneficio. Un LLM cloud con le garanzie base basta.
- **I volumi sono minimi.** Se fai poche chiamate al giorno su dati poco delicati, l'overhead di gestire GPU, modelli locali e aggiornamenti può non valere il risparmio di rischio. Meglio redaction + cloud con DPA.
- **Non hai chi lo mantiene.** Uno stack self-hosted va aggiornato, monitorato, tenuto in salute. Se non hai (né vuoi) qualcuno che se ne occupi, un self-hosted trascurato diventa un rischio di sicurezza peggiore del cloud. Meglio un cloud ben governato di un locale abbandonato.
- **La qualità del modello locale non regge il task.** Per certi compiti complessi, i modelli locali che stanno nella tua VRAM non sono all'altezza. In quel caso: o redaction robusta + cloud, o si aspetta hardware/modelli migliori — non si sacrifica il risultato per principio.

La regola, ancora una volta: **default locale per i dati sensibili, ma con onestà su quando il gioco non vale la candela.** Uno stack sovrano fatto per dogma, senza qualcuno che lo mantiene e senza un vero problema di dati da proteggere, è teatro quanto il "self-hosted = GDPR-ok" da cui siamo partiti.

## Checklist operativa prima di andare in produzione

Prima di considerare "chiuso" un workflow, spunta questa lista:

- [ ] Ho elencato **ogni nodo** che fa chiamate esterne e so cosa gli passo nel body.
- [ ] I task su **dati sensibili** girano su modello **locale** (Ollama/vLLM sulla rete interna).
- [ ] I task su cloud residui hanno una **motivazione scritta** (dati sintetici / DPA+UE / redaction).
- [ ] La **redaction** è attiva dove serve e l'ho testata con payload finto.
- [ ] La **telemetria di n8n è spenta**; nessuna chiamata in uscita non giustificata.
- [ ] n8n è **dietro reverse proxy** con HTTPS e auth; porta non esposta direttamente.
- [ ] I **segreti** non sono in chiaro nel workflow; chiavi robuste in `.env`.
- [ ] Ho il **diagramma dei confini** e la **checklist DPO** pronti.
- [ ] Ho una politica di **retention e cancellazione** dei dati in n8n/Postgres.
- [ ] So **come aggiorno** lo stack e chi lo mantiene.

## Il verdetto: il confine è dove gira il modello

Se ti porti a casa una sola frase, sia questa: **self-hostare n8n non protegge nulla se l'LLM è cloud.** Il confine dei tuoi dati non è dove gira l'orchestratore, è dove gira il modello. Finché il nodo OpenAI parte, i dati dei tuoi clienti — body, allegati, PII, retry compresi — escono dal recinto, e "è sul mio VPS" non è una difesa che regge davanti a un DPO o a un'ispezione. La buona notizia è che chiudere il recinto non è un progetto da mesi: è un `docker-compose` con n8n + Ollama + Postgres sulla stessa rete, la redaction dove serve, e la disciplina del "default locale, cloud per eccezione motivata". Novanta minuti per la prima chiusura, e da lì si costruisce lo stack sovrano vero.

Questo è il primo mattone di un tema più ampio — modelli locali, RAG sui tuoi documenti, agenti che eseguono senza mandare i dati fuori — che trovi nella [guida allo stack sovrano e all'AI in casa]({{ '/it/pillar/stack-sovrano/' | relative_url }}). Se vuoi vedere com'è fatto un recinto sul *tuo* stack, sui *tuoi* workflow e sui *tuoi* dati, il punto di partenza è [chi sono e come lavoro]({{ site.main_site }}/biografia/) o due righe in [contatti]({{ site.main_site }}/contatti/).

## FAQ

**1. Ma se uso n8n self-hosted, i dati non sono già al sicuro?**
No. n8n self-hosted mette al sicuro l'orchestratore, non ciò che manda fuori. Nel momento in cui un nodo LLM cloud (OpenAI, Anthropic…) parte, il payload — testo, allegati, PII — viaggia verso i server del vendor. Il confine dei dati è dove gira il modello, non dove gira n8n.

**2. Cosa esce esattamente da un nodo OpenAI?**
Il body completo del prompt (istruzioni + dati), gli eventuali allegati/file, gli header, e — dettaglio spesso ignorato — i dati vengono rispediti a ogni retry. Lato vendor gli input possono restare loggati per un periodo, salvo accordi specifici.

**3. La redaction basta a mettermi a posto col GDPR?**
Aiuta ma non basta da sola. Riduce l'esposizione mascherando IBAN, CF, email, telefoni prima del modello, ma i nomi propri sfuggono facilmente e gli allegati (PDF, immagini) sono difficili da ripulire. Per i dati sensibili, la soluzione strutturale è il modello locale, non la sola redaction.

**4. Ollama o vLLM?**
Ollama è il più rapido per iniziare e per volumi bassi/singolo utente. vLLM regge meglio il multi-utente e i carichi seri (throughput, batching), a costo di una configurazione più impegnativa. Parti da Ollama, passa a vLLM quando i volumi lo richiedono.

**5. Quanta VRAM mi serve?**
Dipende dal modello: un 8B quantizzato sta in ~8 GB, un 14B in ~16-24 GB, modelli più grandi richiedono schede serie o più GPU con vLLM. Dimensiona il modello sulla VRAM disponibile, non il contrario: meglio un modello che gira bene di uno grande che va in swap.

**6. Il modello locale è all'altezza di GPT-4o?**
Per molti task aziendali (estrazione, classificazione, riassunto, risposte su documenti tuoi) i modelli locali 8-14B fanno un ottimo lavoro. Per ragionamenti complessi il divario col cloud top può contare. La scelta onesta: locale dove regge (la maggior parte dei task PMI), cloud con garanzie dove serve davvero più capacità.

**7. Posso tenere alcuni workflow su cloud?**
Sì, con criterio: dati non personali, dati sintetici/anonimizzati, oppure DPA + regione UE + esclusione del training + redaction a monte. La regola è "default locale, cloud per eccezione motivata": ogni uso cloud deve avere una ragione scritta per *quei* dati.

**8. Come lo dimostro a un DPO o in un'ispezione?**
Con un diagramma dei confini, l'inventario dei nodi che escono (host, dati, motivo), il registro dei trattamenti aggiornato, esempi di redaction, i log di test con payload finto, e le politiche di retention e gestione segreti. Un recinto che non sai dimostrare, ai fini della conformità, è come non averlo.

**9. Quanto costa davvero uno stack locale?**
Ordini di grandezza: un VPS CPU per volumi bassi ~20-60 €/mese; un server GPU in cloud UE ~150-600 €/mese; una GPU on-premise ~500-2.000 € una tantum più qualche decina di € di elettricità al mese. Per volumi alti e dati sensibili si ripaga in euro e in rischio; per volumi minimi il cloud con garanzie può costare meno in denaro.

**10. Da dove comincio se ho già dieci workflow in produzione?**
Da un audit: per ogni workflow, elenca i nodi che escono e cosa gli passi. Poi chiudi per primo quello che manda fuori i dati più sensibili, con il playbook dei 90 minuti. Non serve rifare tutto insieme: si mette in sicurezza un workflow alla volta, dal più rischioso.
