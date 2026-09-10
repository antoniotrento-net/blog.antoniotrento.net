---
lang: it
permalink: /it/blog/fine-tuning-vs-rag-faq-italiane/
title: "Fine-tuning vs RAG per le FAQ aziendali in italiano: quando addestrare è spreco (e quando il retrieval non basta)"
date: 2026-10-12 07:30:00 +0200
author: "Antonio Trento"
description: "Fine-tuning vs RAG per un assistente FAQ aziendale in italiano: perché per i fatti che cambiano ogni mese il fine-tune è già marcio, cosa il RAG non sa fare (tono e formato), il rischio che il modello 'ricordi' uno stipendio, e il default giusto per una PMI."
keywords: ["fine tuning vs rag faq italiane", "lora faq aziendali", "retrieval vs weights", "allucinazione policy interne", "embeddings italiano", "assistente faq aziendale"]
image: /assets/images/posts/fine-tuning-vs-rag-faq-italiane.jpg
pillar: modelli-costi-privacy
related: [/it/blog/rag-pgvector-fattura-elettronica/, /it/blog/vllm-vs-ollama-produzione/]
---

## "Addestriamo un modello sulle nostre FAQ" — di solito è la scelta sbagliata

La richiesta arriva quasi sempre così: "vogliamo un assistente che risponda alle domande interne — ferie, rimborsi, policy IT, procedure — addestriamo un modello sui nostri documenti". La parola "addestriamo" fa scattare in tanti l'idea del **fine-tuning**: prendo un modello, gli faccio digerire le nostre FAQ, e lui le sa. Sembra logico. Nella stragrande maggioranza dei casi è la scelta sbagliata, e costa tempo e soldi per un risultato peggiore.

Il tema è la scelta tra **fine-tuning vs RAG per le FAQ aziendali in italiano**, e la risposta breve — che poi giustifico per bene — è: **per i fatti che cambiano, RAG; per lo stile che resta, semmai un piccolo fine-tune.** Il motivo di fondo sta in una distinzione che quasi nessuno fa esplicita: il fine-tuning mette la conoscenza *dentro i pesi* del modello, il RAG la tiene *fuori*, in una base documentale che interroghi al momento. E le FAQ aziendali — policy HR, procedure IT — **cambiano**. Una policy sulle ferie si aggiorna, un rimborso cambia soglia, una procedura viene rivista. Nel momento in cui finisci di addestrare, il modello è già vecchio.

Questo pezzo è una guida di metodo, con esempi concreti di policy HR/IT italiane: perché il fine-tune è "già marcio" per i fatti mutevoli, cosa il RAG davvero **non** sa fare (tono, formato, "siamo una banca"), cosa serve per una LoRA fatta bene (dati, licenze, eval, GPU), l'ibrido raro e onesto (retrieval + un filo di adattamento di stile), la trappola del dataset (ticket veri vs PDF ufficiali), il rischio serio che il modello "ricordi" uno stipendio, la metrica giusta (citazione esatta della policy), e il default che raccomando a una PMI. Con albero decisionale, esempio di domanda che il RAG deve saper citare, e costi come ordine di grandezza.

È il complemento naturale di come ho costruito un {{ '/it/blog/rag-pgvector-fattura-elettronica/' | relative_url }} (il lato retrieval) e di come si dimensiona il self-hosting dei modelli in {{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }} (il lato costi/GPU, che pesa moltissimo qui).

## Retrieval vs weights: dove vive la conoscenza

Prima della scelta, la distinzione che decide tutto. È una questione di **dove metti la conoscenza**.

- **Fine-tuning:** addestri il modello su esempi, e la conoscenza (o il comportamento) finisce **nei pesi**. Il modello "sa" perché l'hai plasmato. Aggiornare = ri-addestrare. La conoscenza è diffusa, non localizzabile, non citabile.
- **RAG (Retrieval-Augmented Generation):** tieni i fatti in una **base documentale esterna** (le tue policy, procedure, FAQ). A ogni domanda, recuperi i pezzi rilevanti e li dai al modello, che risponde *basandosi su quelli* e **cita la fonte**. La conoscenza vive fuori dai pesi. Aggiornare = cambiare un documento.

La differenza **retrieval vs weights** ha conseguenze pratiche enormi, che riassumo prima di svilupparle:

| Aspetto | Fine-tuning (nei pesi) | RAG (fuori dai pesi) |
|---|---|---|
| Aggiornare un fatto | ri-addestrare | modificare un documento |
| Citare la fonte | no (conoscenza diffusa) | sì (punta al chunk/policy) |
| Fatti che cambiano | invecchia subito | sempre aggiornato |
| Tono / formato / stile | può insegnarlo | non lo garantisce |
| Rischio privacy | memorizza i dati di training | dipende dall'access control |
| Costo di aggiornamento | GPU a ogni cambio | quasi nullo |

Tieni questa tabella a mente: quasi ogni decisione tra i due si riduce a "il contenuto che voglio insegnare **cambia** o **resta**? È un **fatto** o è **stile**?".

## FAQ che cambiano ogni mese: il fine-tune è già marcio

Ecco il primo argomento decisivo, ed è puramente pratico. Le FAQ aziendali sono **fatti che cambiano**: la policy ferie viene aggiornata a inizio anno, la soglia di rimborso pasti cambia, una procedura IT viene rivista dopo un incidente, un nuovo benefit entra in vigore. Su un orizzonte di mesi, una parte non trascurabile del contenuto si muove.

Con il fine-tuning, ogni cambiamento richiede di **ri-addestrare**: raccogliere i nuovi esempi, rifare il training, valutare che non abbia rotto altro, ridistribuire il modello. E finché non lo rifai, il modello risponde con la versione **vecchia** della policy — con la sicurezza di chi "l'ha imparata". Il momento in cui finisci l'addestramento è il momento in cui il modello inizia a invecchiare. Per contenuti che cambiano ogni mese, **il fine-tune è marcio già alla consegna**.

Con il RAG, aggiornare una policy è **sostituire un documento** nella base di conoscenza. Cambi il PDF delle ferie, re-indicizzi quel documento, e da subito l'assistente risponde con la versione nuova — e cita la versione nuova. Nessun training, nessuna GPU, nessun ciclo di eval. L'aggiornamento è un'operazione da minuti, non da giornate.

La regola: **la conoscenza che cambia va tenuta fuori dai pesi, dove puoi aggiornarla senza ri-addestrare.** Mettere fatti mutevoli dentro i pesi è come stampare l'orario dei treni sul muro: bellissimo finché non cambia l'orario. Le FAQ aziendali sono orari dei treni. RAG.

## Cosa il RAG non può fare: tono, formato, "siamo una banca"

Detto questo, sarei disonesto se dipingessi il RAG come la risposta a tutto. Il RAG è bravissimo a portare i **fatti giusti** nel contesto, ma **non** garantisce **come** il modello risponde:

- **Tono di voce.** Se sei uno studio legale o una banca, vuoi un registro formale, prudente, con certe formule. Se sei una startup, un tono diretto. Il RAG inietta i fatti; il *modo* di dirli lo decide il modello di base, che ha il suo stile generico. Puoi guidarlo col prompt, ma su richieste di voce molto specifiche e costanti il solo prompt non basta sempre.
- **Formato della risposta.** Vuoi che ogni risposta abbia una struttura fissa (sintesi + riferimento normativo + "per eccezioni contatta HR")? Il prompt aiuta, ma la coerenza formale su migliaia di risposte è proprio ciò che un piccolo adattamento sa dare meglio.
- **Convenzioni interne.** "Da noi si dice 'nota spese', non 'rimborso'", "citiamo sempre l'articolo del CCNL", "non usiamo mai la parola X". Sfumature di linguaggio aziendale che sono *stile*, non fatti.

Questi sono i casi dove il retrieval, da solo, mostra il limite: non stai cercando *un fatto diverso*, stai cercando *un modo diverso di dire lo stesso fatto*. E lo stile, a differenza dei fatti, **è stabile**: il tono di voce di una banca non cambia ogni mese. Ecco il punto che apre alla forma ibrida: **i fatti (mutevoli) stanno nel RAG, lo stile (stabile) è l'unica cosa che vale forse la pena mettere nei pesi.** Ci torno con l'ibrido — ma tieni la distinzione: RAG per il *cosa*, fine-tune (semmai) per il *come*.

## LoRA per le FAQ aziendali: dati, licenze, eval, GPU

Se decidi che ti serve un adattamento di stile, lo strumento pratico è **LoRA** (Low-Rank Adaptation): invece di ri-addestrare tutti i pesi del modello — costoso e pesante — addestri piccole matrici "adattatrici" che si innestano sul modello base. È il fine-tuning "leggero" che rende la **LoRA per le FAQ aziendali** fattibile anche su hardware modesto. Ma "fattibile" non vuol dire "gratis" o "senza vincoli". Servono quattro cose, e ognuna è un punto dove si sbaglia.

- **Dati.** Coppie domanda→risposta che insegnano lo *stile* (non i fatti). Servono esempi reali e coerenti col tono voluto. Pochi dati incoerenti insegnano incoerenza. E — cruciale — i dati vanno **ripuliti dalla PII** (ci torno: è il rischio numero uno).
- **Licenze.** Due livelli. La licenza del **modello base**: non tutti i modelli permettono il fine-tuning o l'uso commerciale del risultato — verifica prima di investirci. E la licenza/base giuridica dei **dati**: se addestri su ticket reali, quei dati hanno un titolare e una finalità; usarli per addestrare è un trattamento che deve essere legittimo.
- **Eval.** Come fai a sapere che la LoRA ha *migliorato* senza *peggiorare*? Serve un set di valutazione: lo stile è più coerente? E — test di regressione — il modello non ha perso capacità generali, non ha iniziato ad allucinare di più? Un fine-tune senza eval è fede, non ingegneria.
- **GPU.** Con la quantizzazione (QLoRA), l'addestramento di un adattatore di stile su un modello da 7-8B si fa su una GPU consumer in poche ore, con pochi GB di VRAM. Non serve un cluster. Ma è comunque un costo **ricorrente** se lo stile evolve o se cambi modello base. Sul dimensionamento GPU vale quanto ho scritto confrontando le opzioni di serving self-hosted.

Uno scheletro di configurazione QLoRA, per dare concretezza (non un tutorial completo, ma i parametri che contano):

```yaml
# qlora-stile.yaml — adattatore di SOLO stile, non di fatti
base_model: "un-modello-con-licenza-ok-per-fine-tuning"
quantization: 4bit          # QLoRA: gira su GPU consumer
lora:
  r: 16                     # rank basso = adattatore piccolo
  alpha: 32
  dropout: 0.05
  target_modules: ["q_proj", "v_proj"]
training:
  epochs: 2                 # poche: si vuole stile, non memorizzazione
  learning_rate: 2e-4
  max_seq_len: 1024
dataset: "faq_stile_SENZA_PII.jsonl"   # <-- ripulito, vedi sezione rischio
# NB: nessun fatto/policy qui dentro. I fatti stanno nel RAG.
```

Nota `epochs: 2` e la nota sul dataset: si addestra **poco** e su **stile ripulito**, proprio per evitare che il modello memorizzi contenuti. Più epoche + dati grezzi = memorizzazione = il problema della sezione sul rischio.

## L'ibrido raro e onesto: retrieval + un filo di stile

L'architettura che raccomando quando serve *anche* lo stile è ibrida, ma con le proporzioni giuste — ed è raro che serva davvero l'adattamento:

- **RAG per i fatti (sempre):** tutte le policy, procedure, FAQ vivono nella base documentale, versionate, aggiornabili, citabili.
- **LoRA per lo stile (solo se serve):** un piccolo adattatore che insegna *come* rispondere (tono, formato, convenzioni), addestrato su dati **senza PII**, che non contiene **nessun fatto** mutevole.

Il modello di base + LoRA di stile risponde con la voce giusta; il RAG gli mette davanti i fatti giusti e aggiornati; la risposta cita la policy. Aggiornare un fatto = cambiare un documento (nessun re-training). Aggiornare lo stile = ri-addestrare la piccola LoRA (raro).

Perché "raro e onesto": la maggior parte delle PMI **non ha** un requisito di voce così stringente da giustificare il costo e la manutenzione di una LoRA. Un buon prompt di sistema ("rispondi in tono formale, struttura: sintesi + fonte + rimando a HR per eccezioni") copre l'80% dei bisogni di stile senza addestrare niente. La LoRA di stile ha senso quando il tono è un requisito forte e costante — settori regolati, brand voice rigidissima — e quando il prompt da solo non regge la coerenza su volumi alti. Negli altri casi, **RAG + buon prompt**, e basta.

## L'architettura di riferimento

Ecco come dispongo un assistente FAQ, con i confini. Nota dove vive cosa.

```
   Domanda utente ─▶ ┌──────────────────────────────────────┐
                     │ RETRIEVAL (embeddings italiano)        │
                     │ su KB: policy/procedure VERSIONATE      │
                     │ + access control per ruolo             │
                     └───────────────┬────────────────────────┘
                                     │ chunk rilevanti + fonte
                                     ▼
                     ┌──────────────────────────────────────┐
                     │ LLM base (+ eventuale LoRA di STILE)   │
                     │ risponde SOLO dai chunk, CITA la policy│
                     │ se non trova: "non risulta, chiedi HR" │
                     └───────────────┬────────────────────────┘
                                     ▼
                     ┌──────────────────────────────────────┐
                     │ Risposta + citazione (documento, data) │
                     └──────────────────────────────────────┘

   Dove vive la conoscenza:
   - FATTI (mutevoli)  → nella KB del RAG (fuori dai pesi, aggiornabili)
   - STILE (stabile)   → eventuale LoRA (nei pesi), SENZA PII né fatti
```

**Cosa NON fa mai il sistema (i confini):**

- I **fatti mutevoli non stanno nei pesi**: stanno nella KB, aggiornabili senza re-training.
- La **LoRA non contiene PII né policy**: solo stile. Nessun dato personale finisce nei pesi.
- L'assistente **non risponde a una domanda di policy senza citare la fonte**; se non trova, dice "non risulta, rivolgiti a HR", non inventa.
- Il retrieval rispetta l'**access control**: un dipendente non recupera documenti riservati ad HR.

Questo è il RAG-first con adattamento minimo: la stessa filosofia di rigore del retrieval che ho descritto costruendo il RAG su documenti, applicata alle FAQ interne.

## Il dataset: ticket veri vs PDF ufficiali

Se costruisci l'assistente, la domanda "quali dati uso?" ha due risposte, per due scopi diversi — e confonderle è un errore.

- **PDF/documenti ufficiali (per i FATTI, nel RAG):** il regolamento ferie, la procedura rimborsi, la policy IT. Sono la **fonte autorevole**: aggiornati, approvati, citabili. Vanno nella base documentale del RAG. È da qui che l'assistente prende *cosa* è vero.
- **Ticket reali / conversazioni HR-IT (per lo STILE, eventuale LoRA):** mostrano *come* il tuo team risponde davvero — il tono, le formule, la struttura. Utili per insegnare lo stile. Ma sono un campo minato di **dati personali**.

La trappola: usare i ticket reali come fonte di *fatti* (invece dei documenti ufficiali) o addestrarci sopra senza ripulirli. I ticket contengono nomi, situazioni personali, a volte dati sensibili (salute, stipendi, contenziosi). Sono ottimi per lo stile, **pessimi** come fonte di verità (una risposta di un collega in un ticket può essere sbagliata o superata) e **pericolosi** come dati di training grezzi.

La regola: **i fatti dai documenti ufficiali (RAG), lo stile dai ticket ma solo dopo averli ripuliti dalla PII.** Non invertire mai: non addestrare il modello a "sapere" i fatti dai ticket, e non mettere i ticket grezzi nella KB del RAG accessibile a tutti.

## Il rischio che spaventa: il modello che "ricorda" uno stipendio

Questa è la sezione che, da sola, decide molte scelte a favore del RAG. Il fine-tuning ha un rischio che il RAG non ha: **il modello memorizza i dati di training e può rigurgitarli.** Se addestri una LoRA su ticket HR grezzi che contengono "Mario Rossi, stipendio 34.000 €, richiesta anticipo per motivi di salute", quel dato entra nei pesi. E un modello che ha memorizzato può, con la domanda giusta (o anche per caso), **restituire quel dato a un altro utente**. Il collega che chiede "quanto guadagna un impiegato di terzo livello?" potrebbe ricevere lo stipendio reale di Mario.

Perché è grave e specifico del fine-tuning:

- **La memorizzazione è nei pesi, non revocabile facilmente.** Una volta che un dato personale è "imparato", non lo cancelli come cancelli un file: dovresti ri-addestrare senza quel dato. Il diritto all'oblio contro un modello fine-tunato è un incubo tecnico.
- **È imprevedibile.** Non sai quali frammenti il modello ha memorizzato né quando li tirerà fuori. L'"allucinazione" qui non è inventare, è **ricordare troppo**.
- **Viola il GDPR alla radice.** Dati personali finiti nei pesi, usati per una finalità diversa, potenzialmente esposti ad altri: minimizzazione violata, base giuridica dubbia, sicurezza compromessa.

Il RAG, per contrasto, tiene i dati **fuori dai pesi**: la protezione è l'**access control sul retrieval** (chi può recuperare cosa), che è un problema noto e gestibile — dai a ogni ruolo accesso solo ai documenti che gli competono, e i dati sensibili non entrano mai nella KB generale. Cancellare un dato = rimuovere il documento. Reversibile, tracciabile, conforme.

La regola ferrea: **non fare fine-tuning su dati personali non anonimizzati, mai.** Se addestri lo stile, il dataset va ripulito (nomi, importi, dati identificativi rimossi o sostituiti con placeholder) *prima* del training. E i fatti sensibili non si insegnano al modello: si tengono nel RAG con l'access control. Un modello che "ricorda" uno stipendio non è un bug curioso: è un data breach nei pesi.

## La metrica giusta: citazione esatta della policy

Come giudichi se l'assistente è buono? Non dalla fluenza — un modello fine-tunato può suonare fluidissimo mentre cita una policy dell'anno scorso. La metrica che conta per un assistente FAQ è la **citazione esatta della policy**: la risposta punta al documento e alla sezione *corretti e attuali*?

Questo è dove il RAG vince strutturalmente e il fine-tune fallisce:

- **RAG cita.** Recupera il chunk dalla policy versionata e può dire "secondo il Regolamento Ferie 2026, art. 4, il preavviso è di 15 giorni [fonte: ferie-2026.pdf, sez. 4]". Verificabile: l'umano va a controllare.
- **Fine-tune non cita.** La conoscenza è diffusa nei pesi; il modello "sa" ma non sa *da dove*. Può produrre una **allucinazione delle policy interne**: affermare con sicurezza una regola inventata o superata, senza fonte, indistinguibile da una vera. In ambito FAQ aziendali (dove una risposta sbagliata su ferie, sicurezza o rimborsi ha conseguenze reali) è inaccettabile.

La metrica operativa: costruisci un set di domande reali con la risposta corretta e la **fonte attesa** (documento + sezione, validati da HR/IT). Misura due cose: il retrieval ha recuperato la fonte giusta? La risposta cita quella fonte senza aggiungere fatti non presenti? Un assistente FAQ che non cita, o che cita la fonte sbagliata, non è pronto — per quanto fluente sia. La citazione non è un vezzo: è ciò che rende la risposta **verificabile e difendibile**.

## L'albero decisionale: fine-tune o RAG?

Ecco l'albero che uso per decidere, di fronte a un caso reale.

```
1. Il contenuto è un FATTO o è STILE (tono/formato)?
   ├─ FATTO → vai a 2
   └─ STILE → vai a 4

2. Il fatto CAMBIA nel tempo (policy, procedure, listini)?
   ├─ SÌ  → RAG. (Fine-tune = marcio a ogni cambio.)
   └─ NO  → RAG comunque, per la CITABILITÀ (serve verificare la fonte)

3. Serve citare la fonte / verificare la risposta?
   ├─ SÌ  → RAG (il fine-tune non cita)
   └─ NO  → raro nelle FAQ; RAG resta il default sicuro

4. STILE: il prompt di sistema basta a ottenere tono/formato voluti?
   ├─ SÌ  → RAG + buon prompt. NIENTE fine-tune.
   └─ NO (voce fortissima, costante, regolata) → RAG + piccola LoRA di STILE
        └─ dataset SENZA PII, eval di regressione, licenze verificate

REGOLA TRASVERSALE: nessun dato personale nei pesi. Mai.
```

La lettura: per un assistente FAQ aziendale, **si finisce quasi sempre su RAG** (i fatti cambiano e vanno citati), e il fine-tuning entra solo come piccola LoRA di *stile*, solo se il prompt non basta, e solo su dati ripuliti. Il "quasi sempre RAG" non è pigrizia: è la conseguenza logica del fatto che le FAQ sono fatti mutevoli e verificabili.

## Un esempio concreto: la domanda che il RAG deve citare

Rendiamolo tangibile. Domanda di un dipendente: *"Quanti giorni di preavviso devo dare per le ferie estive?"*

Come deve comportarsi l'assistente RAG:

1. **Recupera** dalla KB il documento attuale sulle ferie (embeddings italiano che matchano "preavviso ferie") e trova la sezione pertinente.
2. **Risponde solo da lì, citando:** *"Per le ferie estive il preavviso è di 15 giorni (Regolamento Ferie 2026, art. 4). Per periodi superiori a due settimane consecutive, il preavviso sale a 30 giorni (art. 4, comma 2). Per eccezioni, contatta HR."*
3. **Se la policy fosse cambiata ieri**, la risposta rifletterebbe già la versione nuova, perché il documento nella KB è aggiornato — senza alcun re-training.
4. **Se non trovasse** una policy pertinente, direbbe *"Non risulta una regola specifica nei documenti disponibili: rivolgiti a HR"*, invece di inventare un numero.

Un prompt di sistema che impone questo comportamento:

```text
Sei l'assistente FAQ interno. Rispondi SOLO usando i documenti forniti nel
contesto. Cita SEMPRE il documento e la sezione da cui prendi l'informazione.
Se l'informazione non è nei documenti forniti, rispondi esattamente:
"Non risulta nei documenti disponibili: rivolgiti a HR/IT."
Non inventare policy, numeri o procedure. Tono formale, struttura:
sintesi → riferimento (documento, sezione) → eventuale rimando a HR.
```

Confronta con un modello fine-tunato sulle FAQ: alla stessa domanda risponderebbe "15 giorni" (o quello che ha imparato mesi fa), **senza fonte**, e se la policy fosse cambiata risponderebbe comunque il vecchio numero, con la stessa sicurezza. La differenza tra "15 giorni, verificabile e attuale" e "15 giorni, fidati" è tutta qui.

## Percorso di implementazione, a step

1. **Separa fatti e stile:** elenca cosa è *fatto* (policy, procedure, numeri) e cosa è *stile* (tono, formato). I primi vanno nel RAG, i secondi eventualmente in una LoRA.
2. **Costruisci il RAG** sui documenti ufficiali versionati, con embeddings italiano e access control per ruolo.
3. **Vincola il prompt** a citare la fonte e a dire "non risulta" quando manca. Testa che non inventi.
4. **Misura con un gold set** di domande reali + fonte attesa (validato da HR/IT): retrieval corretto + citazione corretta.
5. **Valuta se lo stile col solo prompt basta.** Nella maggior parte dei casi sì → fermati qui, niente fine-tune.
6. **Solo se serve stile forte:** prepara un dataset di stile **ripulito dalla PII**, verifica le licenze (modello + dati), addestra una piccola LoRA.
7. **Eval della LoRA:** stile migliorato *e* nessuna regressione/allucinazione in più. Se peggiora, scartala.
8. **Access control e retention** sulla KB: dati sensibili solo ai ruoli giusti, cancellabili.
9. **Definisci l'aggiornamento:** cambio di policy = sostituzione documento + re-index. Nessun re-training per i fatti.

## I fallimenti tipici e come li riconosci dai log

- **Risposte con policy vecchia.** L'assistente cita una regola superata: se è fine-tunato, è "marcio" e serve re-training; se è RAG, il documento nella KB non è stato aggiornato. Logga la *data/versione* del documento citato: se è vecchia, sai dove intervenire.
- **Risposte senza citazione.** Se la risposta non contiene documento+sezione, il prompt non sta vincolando o il retrieval non ha trovato nulla e il modello ha risposto "a memoria". Logga la presenza/assenza di citazione e allarma sulle assenze.
- **Allucinazione di policy.** Il modello afferma una regola che non esiste nei documenti. Con RAG ben vincolato è raro; con fine-tune è strutturale. Incrocia le risposte col gold set: le affermazioni senza fonte sono il sintomo.
- **Retrieval che manca la fonte in italiano.** Domanda posta con parole diverse dal documento (sinonimi, dialetto aziendale) e l'embedding non matcha. Logga i casi "nessun chunk recuperato" e arricchisci la KB o l'embedding.
- **PII nelle risposte (fine-tune).** Se un modello fine-tunato restituisce un nome, un importo, un dato personale che non era nella domanda, ha memorizzato dati di training. Allarme rosso: il dataset non era ripulito. Va ritirato.
- **Access control bypassato (RAG).** Un utente recupera un documento che non gli compete: il filtro per ruolo non è applicato al retrieval. Logga chi recupera cosa.

La regola: **logga la fonte citata (documento + versione) e la sua assenza.** Il 90% dei problemi di un assistente FAQ è "ha risposto senza/ con la fonte sbagliata", e lo vedi solo se tracci le citazioni.

## Costi: ordini di grandezza

Stime dichiarate, per un assistente FAQ di una PMI.

- **RAG (una tantum + gestione):** embedding dei documenti (poche centinaia di policy = minuti di calcolo, costo trascurabile), infrastruttura di retrieval (vedi il confronto sui vector DB: spesso Postgres+pgvector, marginale). Aggiornare = re-indicizzare un documento, **secondi**. Il costo dominante è tenere i documenti aggiornati, che è lavoro organizzativo, non tecnico.
- **Fine-tuning LoRA di stile (una tantum, ricorrente sui cambi di stile):** QLoRA su un 7-8B su GPU consumer = poche ore di GPU, come ordine di grandezza pochi euro di elettricità/noleggio per ciclo. Ma va **ripetuto** a ogni evoluzione dello stile o cambio di modello base, più il tempo di preparare il dataset ripulito e di fare l'eval — il costo vero è il **lavoro umano ricorrente**, non le ore GPU.
- **Fine-tuning sui FATTI (l'errore da non fare):** oltre a essere sbagliato, è il più caro: ri-addestri a ogni cambio di policy. Su FAQ che cambiano ogni mese, è un costo ricorrente continuo per un risultato inferiore (non cita, invecchia). È spreco per definizione.
- **Costo del non citare:** una risposta sbagliata su una policy (ferie negate a torto, un rimborso mal gestito, una procedura di sicurezza fraintesa) costa in tempo, contenziosi e fiducia. La citazione verificabile è ciò che riduce questo costo.

La sintesi economica: **il RAG ha costo di aggiornamento quasi nullo; il fine-tuning ha costo di aggiornamento a ogni cambio.** Per contenuti che cambiano, la matematica dice RAG senza appello.

## Quando NON farlo (fine-tuning, in particolare)

- **Non fare fine-tuning sui fatti/policy.** Cambiano e vanno citati: è esattamente ciò per cui il fine-tune è inadatto. RAG.
- **Non fare fine-tuning su dati personali non anonimizzati.** Mai. Il rischio di memorizzazione e rigurgito di PII è un data breach nei pesi, non reversibile. Ripulisci prima, o non addestrare.
- **Non fare una LoRA di stile se il prompt basta.** Nella maggior parte delle PMI il prompt di sistema copre il bisogno di tono/formato. Aggiungere una LoRA è complessità e costo ricorrente per un guadagno marginale.
- **Non usare i ticket come fonte di verità.** Contengono risposte umane potenzialmente sbagliate o superate, e PII. I fatti vengono dai documenti ufficiali.
- **Non saltare l'eval del fine-tune.** Un adattatore che migliora lo stile ma peggiora tutto il resto (più allucinazioni, capacità perse) è un downgrade travestito. Senza eval non lo sai.

## Checklist operativa prima di andare live

- [ ] **Separazione fatti/stile** fatta: fatti nel RAG, stile (se serve) in LoRA.
- [ ] **RAG sui documenti ufficiali versionati**, con embeddings italiano e access control per ruolo.
- [ ] **Prompt che impone la citazione** della fonte e il "non risulta" quando manca.
- [ ] **Gold set** di domande reali + fonte attesa (validato da HR/IT); retrieval e citazione misurati.
- [ ] **Nessun fatto/policy nei pesi**; aggiornamento fatti = sostituzione documento + re-index.
- [ ] **Se LoRA di stile:** dataset **ripulito dalla PII**, licenze (modello + dati) verificate, eval di regressione superata.
- [ ] **Nessun dato personale nei pesi**, verificato (test di memorizzazione sul modello fine-tunato).
- [ ] **Access control e retention** sulla KB: sensibili solo ai ruoli giusti, cancellabili.
- [ ] **Log delle citazioni** (documento + versione) e allarme sulle risposte senza fonte.
- [ ] **Default confermato:** RAG-first; fine-tune solo se giustificato e circoscritto allo stile.

## Il verdetto

Tra **fine-tuning e RAG per le FAQ aziendali in italiano**, il verdetto è netto e controcorrente rispetto all'istinto del "addestriamo un modello sulle nostre FAQ": **RAG per i fatti, quasi sempre; fine-tuning solo, semmai, come piccola LoRA di stile.** Il motivo è strutturale, non ideologico. Le FAQ aziendali sono fatti che cambiano e che vanno citati: metterli nei pesi significa consegnare un modello già vecchio, che non sa dire da dove prende ciò che afferma, e che invecchia a ogni cambio di policy. Il RAG li tiene fuori dai pesi, dove li aggiorni sostituendo un documento e dove ogni risposta punta alla fonte esatta e attuale.

Il RAG non fa tutto: tono, formato e voce sono stile, e lo stile — a differenza dei fatti — è stabile. Lì, e solo lì, un piccolo adattamento può avere senso. Ma nella maggior parte delle PMI un buon prompt di sistema copre il bisogno di stile senza addestrare nulla, e la LoRA resta un'opzione rara, da usare su dati ripuliti dalla PII, con eval seria e licenze verificate. E su un punto non si transige: **nessun dato personale nei pesi.** Il modello che "ricorda" uno stipendio non è una curiosità tecnica, è un data breach non revocabile — il RAG con access control lo evita per costruzione.

Fatto così, hai un assistente FAQ che risponde con i fatti giusti, aggiornati e citati, con la voce dell'azienda quando serve, senza memorizzare ciò che non deve. Fatto "addestrando sulle FAQ", hai un modello fluente che cita policy dell'anno scorso, non sa da dove, e che un giorno rigurgita un dato personale. La differenza non è la potenza del modello: è aver capito dove deve vivere la conoscenza — fuori dai pesi, aggiornabile e citabile.

Se devi costruire un assistente per le FAQ interne e vuoi impostarlo bene dall'inizio — RAG-first, citazioni verificabili, e fine-tune solo dove serve davvero — puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Scelta di metodo, non hype sull'addestramento.

## FAQ

### Per un assistente sulle FAQ interne, meglio fine-tuning o RAG?
Quasi sempre RAG. Le FAQ aziendali sono fatti che cambiano (policy, procedure, numeri) e che vanno citati per essere verificabili. Il RAG tiene questi fatti fuori dai pesi, aggiornabili sostituendo un documento e citabili con la fonte esatta. Il fine-tuning li congela nei pesi, invecchia a ogni cambio e non sa citare. Il fine-tuning entra semmai come piccola LoRA di stile, non per i fatti.

### Perché dici che il fine-tune è "già marcio" per le FAQ?
Perché la conoscenza finisce nei pesi e aggiornarla richiede di ri-addestrare. Nel momento in cui finisci il training, il modello riflette lo stato di allora; appena una policy cambia, risponde la versione vecchia con sicurezza, finché non rifai l'addestramento. Per contenuti che cambiano ogni mese, il modello è vecchio già alla consegna. Il RAG invece si aggiorna cambiando il documento, in secondi.

### Cosa non riesce a fare il RAG?
Il RAG porta i fatti giusti nel contesto ma non garantisce il modo in cui il modello risponde: tono di voce, formato, convenzioni linguistiche interne. Questi sono stile, non fatti, e a differenza dei fatti sono stabili. Puoi guidarli molto col prompt di sistema; se il requisito di voce è fortissimo e costante (settori regolati, brand voice rigida) e il prompt non basta, allora un piccolo adattamento di stile (LoRA) ha senso.

### Cos'è una LoRA e quando ha senso per le FAQ?
LoRA (Low-Rank Adaptation) è un fine-tuning leggero: addestri piccole matrici adattatrici invece di tutti i pesi, fattibile su GPU consumer. Per le FAQ ha senso solo per insegnare lo stile (tono, formato), non i fatti, e solo se il prompt di sistema non basta. Va addestrata su dati ripuliti dalla PII, con licenze verificate e una eval che confermi il miglioramento senza regressioni. Nella maggior parte dei casi non serve.

### Qual è il rischio privacy del fine-tuning?
La memorizzazione: il modello impara i dati di training e può rigurgitarli. Se addestri su ticket HR grezzi con nomi e stipendi, quei dati entrano nei pesi e possono emergere nelle risposte ad altri utenti. È difficile da cancellare (servirebbe ri-addestrare), imprevedibile e viola il GDPR. Il RAG non ha questo problema: i dati stanno fuori dai pesi, protetti dall'access control sul retrieval, e si cancellano rimuovendo il documento.

### Posso addestrare il modello sui nostri ticket di supporto?
Solo per lo stile, e solo dopo aver ripulito i ticket dalla PII (nomi, importi, dati identificativi). Mai come fonte di fatti: i ticket contengono risposte umane potenzialmente sbagliate o superate. I fatti vengono dai documenti ufficiali, nel RAG. E i ticket grezzi non vanno né nei pesi (memorizzazione) né nella KB accessibile a tutti (esposizione di dati personali).

### Come misuro se l'assistente FAQ è affidabile?
Con la citazione esatta della policy: costruisci un set di domande reali con la risposta corretta e la fonte attesa (documento + sezione, validati da HR/IT), e misura se il retrieval recupera la fonte giusta e se la risposta cita quella fonte senza aggiungere fatti non presenti. Non giudicare dalla fluenza: un modello può suonare perfetto mentre cita una policy superata o inventata.

### Cos'è l'allucinazione delle policy interne?
Quando il modello afferma con sicurezza una regola aziendale che non esiste, è superata o è inventata, senza fonte. È tipica dei modelli fine-tunati sui fatti, dove la conoscenza è diffusa nei pesi e non tracciabile. In ambito FAQ è pericolosa perché una risposta sbagliata su ferie, rimborsi o sicurezza ha conseguenze reali. Il RAG ben vincolato la riduce perché risponde solo dai documenti e cita la fonte.

### Serve un embedding speciale per l'italiano?
Serve un buon modello di embedding multilingue che gestisca bene l'italiano, perché la qualità del retrieval dipende da quanto le domande (spesso poste con parole diverse dai documenti) matchano i chunk giusti. Il dialetto aziendale e i sinonimi sono la sfida: se l'embedding non collega "nota spese" e "rimborso", il retrieval manca la fonte. Conta più la qualità del chunking e dell'embedding che la potenza del modello generativo.

### Quanto costa rispetto al fine-tuning?
Il RAG ha costo di aggiornamento quasi nullo: cambiare una policy è sostituire un documento e re-indicizzarlo, secondi. Il fine-tuning ha costo a ogni aggiornamento: preparare il dataset, ri-addestrare, fare l'eval, ridistribuire. Sui fatti che cambiano è spreco continuo. La LoRA di stile costa poche ore di GPU per ciclo, ma il costo vero è il lavoro umano ricorrente di dataset ed eval. Per contenuti mutevoli, la matematica dice RAG senza appello.
