---
lang: it
permalink: /it/blog/vllm-vs-ollama-produzione/
alt_url: /en/blog/vllm-vs-ollama-in-production/
title: "Ollama in produzione è una trappola: quando serve vLLM (e come scegliere la GPU usata senza bruciare il budget)"
date: 2026-09-21 07:30:00 +0200
author: "Antonio Trento"
description: "Ollama è perfetto per sviluppare e per un utente. Con 15 dipendenti in contemporanea collassa: code, timeout, latenza. Quando serve vLLM, quale GPU comprare usata, e il TCO reale su 12 mesi."
keywords: ["vllm vs ollama produzione", "ollama produzione", "vllm gpu", "llm self-hosted pmi", "throughput token"]
image: /assets/images/posts/vllm-vs-ollama-produzione.jpg
pillar: modelli-costi-privacy
related: [/it/blog/n8n-self-hosted-openai-privacy/, /it/blog/rag-pgvector-fattura-elettronica/]
---

## La trappola: Ollama funziona benissimo finché sei uno solo

Hai messo su Ollama sul tuo server, hai scaricato un modello, funziona. Lo colleghi al tuo workflow, provi, risponde bene. Sei convinto: "ho il mio LLM in casa, sono a posto". Poi metti il sistema in produzione, quindici dipendenti cominciano a usarlo nella stessa mezz'ora, e succede il disastro: le risposte impiegano trenta secondi, poi un minuto, poi vanno in timeout, la coda si allunga, e qualcuno ti scrive "l'AI non funziona". Non è rotta. È che **Ollama non è nato per la produzione multi-utente**, e l'hai scoperto nel modo peggiore — con gli utenti veri addosso.

Questo è il confronto `vLLM vs Ollama` in produzione, senza recensioni da YouTube: architettura e numeri. Ollama è uno strumento eccellente — per sviluppare, per prototipare, per un singolo utente. Ma sotto **concorrenza reale** smette di essere un server e diventa un collo di bottiglia. vLLM è costruito per il problema opposto: servire molti utenti insieme con throughput alto. In questo articolo vediamo dove Ollama smette di reggere e perché, cosa fa vLLM di diverso (paged attention, batching continuo, API compatibile OpenAI), quanta VRAM serve davvero per i modelli che puoi far girare in Italia/UE, come scegliere la quantizzazione, e — la parte che tocca il portafoglio — quale GPU usata comprare e qual è il costo totale su 12 mesi rispetto al cloud. Con il `compose` di produzione, la tabella del TCO, e il criterio preciso per capire quando uscire da Ollama. Perché "funziona sul mio portatile" e "regge quindici persone insieme" sono due mondi diversi.

## Cosa promette Ollama e dove smette di essere un server

Diamo a Ollama quel che è di Ollama, perché è un ottimo strumento nel suo dominio. Ollama è costruito su llama.cpp, usa i modelli in formato **GGUF**, e ha un pregio enorme: **la semplicità.** Un comando per scaricare un modello, un comando per farlo girare, un'API pronta. Per lo sviluppo, per provare modelli, per un assistente personale, per un singolo utente o pochissimi, è perfetto — e non c'è niente di male a usarlo lì. Il [primo recinto di uno stack sovrano parte spesso proprio da Ollama]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}), ed è la scelta giusta per iniziare.

Il problema è cosa succede sotto **concorrenza**. Ollama, di base, serve bene *una richiesta alla volta*. Puoi aumentare il parallelismo (con variabili come `OLLAMA_NUM_PARALLEL`), ma il modello di esecuzione non è ottimizzato per spremere una GPU con tanti utenti insieme. Quando arrivano richieste concorrenti, cosa succede:

- **Le richieste si accodano.** Chi arriva quarto aspetta che finiscano i primi tre. La latenza percepita esplode: non è il modello lento, è la coda.
- **La GPU è usata male.** Servendo poche richieste per volta, gran parte della potenza di calcolo della GPU resta inutilizzata mentre gli utenti aspettano. Paghi una GPU e ne sfrutti una frazione.
- **I timeout.** Se la coda è lunga, le richieste in fondo scadono prima di essere servite. L'utente vede un errore, non una risposta lenta.

Il punto architetturale è questo: **Ollama è un runtime, non un server di produzione multi-utente.** Non è un difetto — è un'altra categoria di strumento. Confondere "gira sul mio server" con "regge la mia azienda" è la trappola. Il segnale che l'hai toccata è chiaro: appena più persone lo usano insieme, la latenza diventa inaccettabile. Da lì, o accetti che sia uno strumento per pochi, o passi a qualcosa costruito per la concorrenza. Quel qualcosa, oggi, è vLLM.

## vLLM: paged attention, batching continuo, API compatibile OpenAI

vLLM risolve esattamente il problema dove Ollama si ferma: **servire molte richieste insieme, sfruttando la GPU al massimo.** Lo fa con due innovazioni tecniche che vale la pena capire, perché sono la ragione dei numeri.

- **PagedAttention.** Il collo di bottiglia nel servire un LLM è la memoria della GPU occupata dalla "KV cache" — lo stato che il modello tiene per ogni conversazione in corso. Gestita in modo ingenuo, spreca tantissima VRAM e limita quante richieste puoi servire insieme. PagedAttention gestisce questa memoria come fa un sistema operativo con la RAM (a "pagine"), riducendo lo spreco enormemente. Risultato: **molte più richieste concorrenti nella stessa VRAM.**
- **Continuous batching (batching continuo).** Invece di aspettare che un gruppo di richieste finisca prima di iniziare il prossimo, vLLM aggiunge e rimuove richieste dal "batch" in esecuzione di continuo, mano a mano che arrivano e finiscono. La GPU non resta mai ferma ad aspettare: lavora sempre a pieno su tutte le richieste attive. È qui che il **throughput** (token al secondo totali serviti) fa un salto rispetto a servire una richiesta alla volta.

In più, vLLM espone un'**API compatibile con quella di OpenAI** (`/v1/chat/completions`): questo significa che il codice e i tool che parlano con OpenAI possono puntare al tuo vLLM locale cambiando solo l'URL, senza riscrivere niente. È un vantaggio pratico enorme per migrare da cloud a locale.

Il prezzo di tutto questo è la **complessità**: vLLM richiede una configurazione più impegnativa di Ollama, gira su GPU NVIDIA con driver adeguati, e usa formati di quantizzazione diversi (AWQ/GPTQ invece di GGUF). Non è "un comando e via". Ma è ciò che trasforma una GPU in un vero server LLM di produzione. La regola pratica: **Ollama per sviluppare e per pochi utenti; vLLM quando la concorrenza è reale.**

## VRAM: 8, 12, 24 GB e quali modelli reggono davvero

La domanda che decide tutto, prima ancora di Ollama vs vLLM, è: **quanta VRAM hai?** Perché la VRAM determina quale modello puoi far girare e con quanta concorrenza. Facciamo chiarezza con ordini di grandezza (stime, dipendono da quantizzazione, lunghezza del contesto e batch).

| VRAM | Cosa ci fai girare | Note |
|---|---|---|
| **8 GB** | Modelli **7-8B quantizzati** a 4-bit (~5-6 GB pesi) | Ok per un utente o pochi, contesto corto. Poco margine per KV cache e batch. Embedding: comodi. |
| **12 GB** | **7-8B** con più agio, **13-14B** stretti (4-bit) | Un modello 8B con contesto decente e un po' di concorrenza. Il minimo sindacale "serio" per un piccolo team. |
| **24 GB** (3090/4090/A5000) | **14B** comodi, **32B quantizzati** stretti, **7-8B** con batch grande e contesto lungo | La fascia dove la produzione multi-utente con vLLM diventa realistica. Il "sweet spot" per una PMI. |

Due cose da capire, perché sono le fonti di sorpresa più comuni:

- **La VRAM non serve solo per i "pesi" del modello.** Serve anche per la **KV cache** di ogni richiesta in corso e per il **contesto** (più token in ingresso/uscita = più memoria). Un modello che "sta" in 6 GB da fermo può non reggere quindici richieste concorrenti con contesto lungo nella stessa scheda. Ecco perché per la produzione multi-utente si punta a 24 GB anche per modelli che "starebbero" in meno.
- **Modelli italiani/EU.** Per lavorare bene sull'italiano puoi usare sia buoni modelli multilingua open (che ormai reggono bene l'italiano) sia modelli specializzati EU. Il punto sovrano non è "quale bandiera ha il modello", ma che **i pesi girino sulla tua GPU** e i dati non escano. Un ottimo modello multilingua 8-14B, quantizzato, sulla tua scheda, è una base solida per la maggior parte dei task PMI.

La regola: **dimensiona il modello sulla VRAM che hai, non sul modello che vorresti.** Un 8B che gira fluido e regge la concorrenza batte un 32B che va in swap e fa timeout. E per la produzione multi-utente, 24 GB è la fascia da cui partire.

## Quantizzazione: GGUF contro AWQ/GPTQ, qualità contro velocità

La quantizzazione è il modo di far stare un modello in meno VRAM riducendo la precisione dei suoi numeri (da 16 bit a 8, 4 o meno). È ciò che ti permette di far girare un 14B su una scheda "consumer". Ma non tutte le quantizzazioni sono uguali, ed è legata alla scelta Ollama/vLLM.

- **GGUF** (il formato di llama.cpp, quindi di **Ollama**). Flessibile: può splittare il modello tra GPU e CPU, gira anche su hardware modesto, ha molti livelli di quantizzazione (Q4_K_M, Q5, Q8…). Ottimo per la flessibilità e per il singolo utente. Ma non è pensato per il throughput massimo su GPU sotto concorrenza.
- **AWQ / GPTQ** (i formati che **vLLM** usa bene). Quantizzazioni a 4-bit pensate per l'inferenza veloce su GPU, "consapevoli" di quali pesi contano di più per preservare la qualità. Sono la scelta per il throughput di produzione con vLLM.

Il compromesso qualità/velocità/VRAM, in pratica:

- **4-bit** (Q4 / AWQ): il miglior rapporto per la maggior parte dei casi. Fai stare modelli più grandi, con una perdita di qualità piccola e spesso trascurabile sui task pratici.
- **8-bit**: più vicino alla qualità piena, ma occupa più VRAM. Ha senso se hai margine e il task è delicato.
- **Precisione piena (FP16)**: massima qualità, massima VRAM. Raramente necessaria in una PMI se la 4-bit fa il lavoro.

La scelta onesta: **parti dalla 4-bit** (AWQ per vLLM in produzione, Q4 per Ollama in sviluppo), e sali di precisione solo se, sul *tuo* set di valutazione, noti una perdita di qualità che conta. Non pagare VRAM (e quindi GPU più costose) per una precisione che sui tuoi task non fa differenza misurabile. Come per il RAG, il criterio è sempre **misurare sui tuoi dati**, non seguire il numero più grande.

## Un utente contro 15 in contemporanea: code, timeout e throughput

Torniamo al cuore del problema, perché è la ragione economica di tutto. La differenza tra un utente e quindici non è lineare: è un cambio di regime.

Con **un utente**, quello che conta è la **latenza**: quanto ci mette una singola risposta. Ollama qui va benissimo: serve la tua richiesta usando la GPU, e la risposta arriva. Nessuna coda, nessun problema.

Con **quindici utenti in contemporanea**, quello che conta è il **throughput**: quanti token al secondo *totali* la GPU riesce a servire distribuendoli tra tutti. E qui:

- **Con Ollama**, le richieste si accodano. Se una risposta impiega 10 secondi e ne arrivano 15 insieme, l'ultimo aspetta oltre due minuti — e probabilmente va in timeout. La GPU serve pochi alla volta e resta sottoutilizzata tra un turno e l'altro.
- **Con vLLM**, il batching continuo serve tutte e quindici *insieme*, spremendo la GPU. La latenza della singola risposta sale un po' rispetto al caso isolato (la GPU è condivisa), ma **nessuno aspetta in coda due minuti** e nessuno va in timeout. Il throughput totale è molte volte superiore.

Il numero che devi tenere d'occhio in produzione non è "quanto è veloce una risposta da sola", ma **quante richieste concorrenti reggo prima che la latenza diventi inaccettabile.** È il tuo vero limite di capacità. E si presidia con due parametri: quanti "posti" concorrenti configuri (`max-num-seqs` in vLLM) e quanto contesto permetti (`max-model-len`) — perché più contesto per richiesta significa meno richieste concorrenti nella stessa VRAM. Dimensionare questi due numeri sulla tua GPU e sul tuo carico è metà del lavoro di mettere un LLM in produzione.

## Un esempio di dimensionamento, in concreto

Mettiamo i numeri su un caso tipo: un'azienda con **15 dipendenti** che usano un assistente interno (RAG sui documenti aziendali + qualche estrazione), non tutti insieme di continuo ma con **picchi di 5-8 richieste concorrenti** nelle ore centrali, con risposte da poche centinaia di token e contesti medi. Come lo dimensioni.

1. **Modello e VRAM.** Un buon modello multilingua 8-14B quantizzato a 4-bit è più che adeguato per questi task. Su una **RTX 3090 (24 GB)** ci sta con margine per la KV cache dei picchi concorrenti e un contesto di ~8k token.
2. **Runtime.** Con picchi di 5-8 richieste insieme, Ollama accoderebbe e farebbe salire la latenza: è un caso da **vLLM**. Imposti `--max-num-seqs 8` (copre il picco) e `--max-model-len 8192` (contesto adeguato senza sprecare VRAM).
3. **Capacità.** Con questi parametri sulla 3090, il picco di 8 richieste viene servito in batch continuo senza code inaccettabili. Se i picchi crescessero a 15-20 concorrenti stabili, valuteresti una seconda scheda o una GPU più capiente.
4. **Costo.** ~800 € una tantum per la 3090 usata + elettricità: su 12 mesi, una frazione di un canone cloud continuo — e i documenti aziendali non escono di casa.

Il punto del walkthrough è che il dimensionamento **non è a naso**: parti dagli utenti concorrenti reali e dal contesto, scegli VRAM e modello di conseguenza, e tari `max-num-seqs`/`max-model-len` su quei numeri. Cambia il carico (più utenti, contesti più lunghi, task più pesanti) e rifai il conto — è un calcolo, non una scommessa.

## Il compose di produzione: healthcheck, reverse proxy, limiti

Ecco un `docker-compose.yml` di vLLM pensato per la produzione, con i pezzi che Ollama-and-go non ti dà: healthcheck, porta chiusa dietro reverse proxy, limiti espliciti.

```yaml
services:
  vllm:
    image: vllm/vllm-openai:latest
    command: >
      --model TheOrg/modello-istruito-AWQ
      --quantization awq
      --max-model-len 8192
      --gpu-memory-utilization 0.90
      --max-num-seqs 16
    environment:
      HUGGING_FACE_HUB_TOKEN: ${HF_TOKEN}
    ports:
      - "127.0.0.1:8000:8000"   # solo loopback: dietro reverse proxy
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
```

I parametri che contano, e perché:

- **`--max-num-seqs 16`**: quante richieste concorrenti al massimo. Il tuo limite di capacità: tararlo sulla VRAM e sul carico reale.
- **`--max-model-len 8192`**: la lunghezza massima del contesto. Più alto = più memoria per richiesta = meno concorrenza. Non metterlo enorme "per sicurezza": costa VRAM che toglie ai posti concorrenti.
- **`--gpu-memory-utilization 0.90`**: quanta VRAM vLLM può usare. Lasciare un margine evita crash da memoria piena.
- **Porta su `127.0.0.1`**: come per tutto lo stack sovrano, non esposta direttamente. Davanti ci va un reverse proxy (Caddy/Nginx) con HTTPS e autenticazione.
- **`healthcheck`**: fondamentale in produzione. Se vLLM si pianta, Docker (o l'orchestratore) lo sa e lo riavvia, invece di lasciare gli utenti a sbattere contro un servizio morto.

Questo è il livello di cura che separa "ho fatto girare un LLM" da "ho un servizio LLM in produzione": limiti espliciti, salute monitorata, accesso controllato. Gli stessi principi del [recinto chiuso di uno stack sovrano]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}) applicati al servire il modello.

## GPU usata contro cloud GPU: il TCO su 12 mesi

Ora i soldi, che è il motivo per cui questo articolo esiste. Comprare una GPU costa; affittarla nel cloud costa in modo diverso. Qual è il **costo totale (TCO)** su 12 mesi? Ordini di grandezza, stime dichiarate, prezzi del mercato dell'usato che variano.

| Opzione | Costo iniziale | Costo mensile | Note |
|---|---|---|---|
| **RTX 3090 usata (24 GB)** | ~700-900 € | elettricità (decine di €) | Il miglior rapporto VRAM/prezzo per iniziare seriamente. 24 GB a prezzo consumer. |
| **RTX 4090 (24 GB)** | ~1.500-1.900 € | elettricità | Più veloce della 3090; stessa VRAM. Ha senso se la latenza conta e il budget c'è. |
| **RTX A5000 (24 GB, workstation)** | ~1.500-2.500 € | elettricità | Blower (raffreddamento adatto ai rack), spesso più "da datacenter". Per chi la mette in un server vero. |
| **Cloud GPU 24 GB (L4/A10 e simili)** | 0 | ~150-500 €/mese se acceso di continuo | Zero CapEx, ma il canone continuo si somma: su 12 mesi può superare il costo di una scheda comprata. |

Il ragionamento del TCO su 12 mesi:

- **Uso continuo (il servizio è sempre acceso per l'azienda):** l'on-premise vince quasi sempre. Una 3090 usata a ~800 € più l'elettricità, su 12 mesi, costa molto meno di un canone cloud di qualche centinaio di euro al mese moltiplicato per dodici. Dopo il primo anno, la scheda è ammortizzata e continui a pagare solo l'elettricità.
- **Uso intermittente o a picchi (serve solo qualche ora al giorno o per batch occasionali):** il cloud GPU può convenire, perché paghi solo quando accendi. Tenere una scheda ferma il 90% del tempo è spreco di CapEx.
- **Fase di test/incertezza:** il cloud è ottimo per *provare* senza impegnarti, poi valuti se il carico giustifica l'acquisto.

La regola economica: **se l'LLM serve di continuo all'azienda, compra (usato va benissimo); se serve a sprazzi o stai ancora validando, affitta.** E ricorda il vantaggio non contabile dell'on-premise sovrano: i dati non escono, il che per certi contesti vale più della differenza di TCO. Il conto onesto mette in conto anche il rischio, non solo gli euro — come per tutta la [guida allo stack sovrano e ai costi]({{ '/it/pillar/modelli-costi-privacy/' | relative_url }}).

## Il piano di rollback: quando il modello sbaglia i JSON

Ecco un fallimento specifico e frequente che manda in crisi la produzione, e che né Ollama né vLLM risolvono da soli: **il modello che sbaglia l'output strutturato.** Molti workflow chiedono all'LLM di restituire un JSON (per passarlo a un altro sistema). I modelli locali, specie i più piccoli o molto quantizzati, ogni tanto restituiscono un JSON malformato, con un campo in più, o con testo intorno. Se il tuo sistema si aspetta un JSON valido e ne riceve uno rotto, il workflow si spezza.

Il piano di rollback, a strati:

1. **Vincola l'output all'origine.** vLLM (e altri) supportano output vincolato a uno schema (grammar/guided decoding): il modello è *forzato* a produrre un JSON valido secondo lo schema. È la prima e migliore difesa: previeni invece di correggere.
2. **Valida sempre, non fidarti mai.** Dopo la risposta, valida il JSON contro lo schema atteso. Se è valido, procedi. Se no, non passare oltre roba rotta.
3. **Retry con prompt più stretto.** Se la validazione fallisce, ritenta una volta con un prompt che ribadisce il formato (e magari con temperatura più bassa). Spesso al secondo tentativo esce pulito.
4. **Fallback a un modello più capace.** Se anche il retry fallisce, fai *fallback* a un modello più grande (o, per quel singolo caso non sensibile, a un modello cloud con le dovute cautele). Meglio una risposta lenta e giusta che un workflow rotto.
5. **Coda per l'umano come ultima rete.** Se nulla funziona, metti il caso in una coda per revisione umana invece di procedere con dati sbagliati. Il sistema degrada con grazia, non si schianta.

Questo piano a strati — vincola, valida, ritenta, fallback, umano — è ciò che rende un LLM locale **affidabile in produzione** nonostante la sua fallibilità. Un sistema che assume che il modello faccia sempre JSON perfetti è un sistema che si romperà; uno che prevede il fallimento e ha un piano, no. È la stessa filosofia dell'idempotenza e delle reti di sicurezza che regge gli [agenti che eseguono azioni reali]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}): progetta per quando sbaglia, non per quando va bene.

## Cosa si rompe in produzione (e come lo leggi dai log)

I guasti di un LLM self-hosted non sono misteriosi: sono quasi sempre memoria, concorrenza o caricamento. Ecco come li riconosci dai log prima che gli utenti se ne accorgano.

- **`CUDA out of memory` all'avvio o sotto carico.** Sintomo: vLLM non parte, o crasha quando arrivano richieste concorrenti con contesto lungo. Causa: `max-model-len` o `max-num-seqs` troppo alti per la VRAM, o `gpu-memory-utilization` al massimo senza margine. Rimedio: abbassa uno dei due limiti; la KV cache di tante richieste lunghe non ci stava. È il guasto numero uno di chi dimensiona con ottimismo.
- **Throughput che crolla sotto picco (preemption).** Sintomo: con molte richieste insieme la velocità cala di colpo; nei log di vLLM compaiono messaggi di preemption/recompute. Causa: la KV cache si riempie e vLLM deve "sfrattare" e ricalcolare richieste. Rimedio: meno concorrenza (`max-num-seqs`), contesto più corto, o più VRAM. È il segnale che sei al limite di capacità della scheda.
- **Coda infinita e timeout (Ollama).** Sintomo: la latenza sale linearmente col numero di utenti finché scadono. Causa: le richieste si accodano perché il runtime serve pochi alla volta. Rimedio: è *il* motivo per passare a vLLM — non c'è tuning di Ollama che risolva un problema di architettura.
- **Cold start lentissimo.** Sintomo: la prima richiesta dopo un riavvio impiega molto. Causa: il modello viene caricato in VRAM al primo uso. Rimedio: precarica il modello (warm-up all'avvio) e usa l'healthcheck per non mandare traffico prima che sia pronto.
- **Errore di quantizzazione/formato al load.** Sintomo: vLLM rifiuta di partire lamentando il formato del modello. Causa: hai puntato a un modello GGUF con vLLM (che vuole AWQ/GPTQ/FP16) o viceversa. Rimedio: usa il formato giusto per il runtime giusto.
- **Restart loop.** Sintomo: il container si riavvia in ciclo. Nei log vedi il crash che si ripete. Causa: spesso OOM al load o config errata. L'healthcheck aiuta a rilevarlo, ma la causa va letta nei log del crash, non ignorata coi retry.

Il principio: **monitora la VRAM occupata, la lunghezza della coda e i tempi di risposta.** La stragrande maggioranza dei guasti è VRAM o concorrenza, e si legge nei log e nelle metriche se le stai guardando — non se aspetti che sia un utente a dirti "non funziona".

## Il criterio di uscita da Ollama

Riassumiamo in un criterio operativo netto — quello che il titolo promette. **Resta su Ollama finché:**

- Gli utenti concorrenti sono **pochi** (uno, o una manciata non simultanea).
- Sei in **sviluppo o prototipo**, e la semplicità vale più del throughput.
- La **latenza sotto carico** non è ancora un problema perché il carico non c'è.

**Esci da Ollama e passa a vLLM quando ricorre anche solo uno di questi:**

- **Più utenti in contemporanea** cominciano a vedere latenza alta o timeout: è il segnale numero uno.
- Ti serve **throughput** (tanti token serviti al secondo distribuiti su molti utenti), non solo la velocità di una singola risposta.
- Vuoi **spremere davvero la GPU** che hai pagato, invece di usarne una frazione.
- Ti serve un servizio con **healthcheck, limiti e API OpenAI-compatibile** solida per integrarci sopra in produzione.

Il criterio in una frase: **quando smetti di essere l'unico utente e diventi un servizio, esci da Ollama.** Non è "Ollama è brutto" — è che è lo strumento giusto per la fase sbagliata. Usalo per costruire e provare; passa a vLLM quando metti in produzione per un team. Sbagliare questa transizione è la trappola da cui parte l'articolo: mettere in produzione multi-utente uno strumento nato per un utente solo, e scoprirlo con gli utenti addosso.

## Checklist operativa prima della produzione

- [ ] Ho stimato gli **utenti concorrenti** reali e la latenza accettabile.
- [ ] Ho scelto il runtime giusto: **Ollama** per dev/pochi, **vLLM** per produzione multi-utente.
- [ ] Il **modello sta nella VRAM** con margine per KV cache e contesto (24 GB per multi-utente).
- [ ] **Quantizzazione 4-bit** come default (AWQ per vLLM), salgo solo se la qualità sul mio set lo richiede.
- [ ] `max-num-seqs` e `max-model-len` **tarati** sulla GPU e sul carico.
- [ ] Porta **dietro reverse proxy** con HTTPS e auth; `healthcheck` attivo.
- [ ] **Output strutturato vincolato** allo schema + validazione + retry + fallback.
- [ ] **TCO calcolato** su 12 mesi: compro (uso continuo) o affitto (uso a sprazzi/test).
- [ ] So **come monitoro** latenza, code e salute del servizio.
- [ ] I **dati non escono**: il modello gira in casa, coerente con lo stack sovrano.

## Il verdetto: Ollama per costruire, vLLM per servire

Ollama in produzione multi-utente è una trappola non perché sia scarso, ma perché è lo strumento giusto per la fase sbagliata: perfetto per sviluppare e per un utente, collassa in code e timeout quando quindici persone lo usano insieme. vLLM è nato per l'altro problema — servire molti con throughput alto, grazie a paged attention e batching continuo — e con la sua API compatibile OpenAI si integra dove prima c'era il cloud. La VRAM decide cosa puoi far girare (24 GB il sweet spot per una PMI), la quantizzazione 4-bit è il default sensato, e sul TCO a 12 mesi una GPU usata da 24 GB batte quasi sempre il canone cloud per l'uso continuo. Il criterio è semplice: **quando smetti di essere un utente e diventi un servizio, esci da Ollama.** E qualunque runtime scegli, i dati restano in casa: è il punto dello stack sovrano.

Questo è un mattone della [guida a modelli, costi e privacy dell'AI in casa]({{ '/it/pillar/modelli-costi-privacy/' | relative_url }}). Se vuoi dimensionare GPU e runtime sul *tuo* carico reale — quanti utenti, quali modelli, comprare o affittare — parti da [chi sono e come lavoro]({{ site.main_site }}/biografia/) o scrivimi due righe in [contatti]({{ site.main_site }}/contatti/).

## FAQ

**1. Ollama è scarso, allora?**
No, è ottimo — nel suo dominio: sviluppo, prototipazione, singolo utente o pochissimi. La sua semplicità è impareggiabile per iniziare. Il problema nasce solo quando lo metti in produzione multi-utente, dove non è nato per operare: lì accoda le richieste e la latenza esplode.

**2. Cosa fa vLLM che Ollama non fa?**
Serve molte richieste concorrenti spremendo la GPU, grazie a PagedAttention (gestisce la memoria della KV cache in modo efficiente) e al continuous batching (aggiunge e toglie richieste dal batch di continuo, senza lasciare la GPU ferma). Ha anche un'API compatibile OpenAI, comoda per migrare dal cloud.

**3. Quanta VRAM mi serve davvero?**
Per un utente o pochi, 8-12 GB bastano per un modello 7-8B quantizzato. Per la produzione multi-utente punta a 24 GB (3090/4090/A5000): serve non solo per i pesi ma per la KV cache di ogni richiesta concorrente e per il contesto. Dimensiona il modello sulla VRAM, non il contrario.

**4. GGUF o AWQ/GPTQ?**
GGUF è il formato di Ollama/llama.cpp: flessibile, gira anche su hardware modesto, ideale per dev e singolo utente. AWQ/GPTQ sono quantizzazioni pensate per l'inferenza veloce su GPU con vLLM: la scelta per il throughput di produzione. Come regola, 4-bit come default, si sale di precisione solo se la qualità sul tuo set lo richiede.

**5. Quale GPU usata compro?**
La RTX 3090 usata (24 GB, ~700-900 €) è il miglior rapporto VRAM/prezzo per iniziare seriamente. La 4090 è più veloce a parità di VRAM se la latenza conta e il budget c'è. La A5000 ha raffreddamento più adatto ai server. Per una PMI, 24 GB è la fascia da cui partire.

**6. Conviene comprare la GPU o usare il cloud?**
Se l'LLM serve di continuo all'azienda, compra (anche usato): su 12 mesi una scheda da ~800 € più elettricità costa meno di un canone cloud continuo, e dopo è ammortizzata. Se serve a sprazzi o stai ancora validando, affitta nel cloud e paghi solo quando accendi. In più, l'on-premise tiene i dati in casa.

**7. Cosa succede se il modello mi restituisce JSON rotti?**
Prevedilo con un piano a strati: vincola l'output allo schema all'origine (guided decoding), valida sempre il JSON, ritenta con prompt più stretto se fallisce, fai fallback a un modello più capace, e come ultima rete metti il caso in coda per un umano. Un sistema che assume JSON sempre perfetti si romperà; uno che prevede il fallimento no.

**8. Quanti utenti concorrenti regge una GPU da 24 GB con vLLM?**
Dipende dal modello, dalla quantizzazione, dalla lunghezza del contesto e dai parametri (`max-num-seqs`, `max-model-len`). Non c'è un numero fisso: si misura sul tuo carico. Il punto è che vLLM ne regge *molti di più* di Ollama sulla stessa scheda, perché usa la GPU in modo efficiente invece di accodare.

**9. Posso usare vLLM con l'italiano?**
Sì: vLLM serve il modello che gli dai, e ci sono ottimi modelli multilingua open che reggono bene l'italiano, oltre a modelli EU. Il punto "sovrano" non è la nazionalità del modello, ma che giri sulla tua GPU con i dati che non escono. Valuta la qualità sull'italiano con il tuo set di prova.

**10. Devo per forza scegliere uno solo?**
No: è comune usare **Ollama in sviluppo** (semplice, veloce da iterare) e **vLLM in produzione** (per reggere gli utenti). L'importante è non fare l'errore inverso — mettere Ollama in produzione multi-utente — che è la trappola da cui parte tutto. Sviluppa con l'uno, servi con l'altro.
