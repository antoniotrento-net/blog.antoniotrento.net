---
lang: it
permalink: /it/blog/tco-gpt-4o-vs-llm-self-hosted/
title: "Quanto costa davvero GPT-4o vs un Qwen self-hosted su 100.000 documenti/mese (TCO con elettricità, persone e scarti)"
date: 2026-10-22 07:30:00 +0200
author: "Antonio Trento"
description: "TCO di un LLM in cloud contro uno self-hosted su 100.000 documenti al mese: token di input e output, cache, batch, GPU, kWh in Italia, ore di manutenzione, retry e correzioni umane. Ipotesi esplicite, break-even e sensibilità al prezzo del token."
keywords: ["tco gpt-4o vs llm self hosted", "costo token aziendale", "qwen vllm", "elettricità gpu", "break even llm", "costo llm per documento"]
image: /assets/images/posts/tco-gpt-4o-vs-llm-self-hosted.jpg
pillar: modelli-costi-privacy
related: [/it/blog/vllm-vs-ollama-produzione/, /it/blog/osservabilita-llm-produzione/]
---

## Due preventivi, due bugie

Il CFO riceve due numeri. Il primo, dal team che usa un modello in cloud: "l'API ci costa circa mille euro al mese". Il secondo, dal sistemista che vuole portare tutto in casa: "con una GPU da ottomila euro, in tre anni ci ripaghiamo e poi è gratis". Entrambi sono veri. Entrambi sono sbagliati, perché contano solo una parte del costo.

Il primo dimentica le persone che gestiscono l'integrazione, le chiamate fallite e ripetute, e le correzioni umane quando il modello sbaglia. Il secondo dimentica l'elettricità, il raffreddamento, chi rianima il server alle due di notte, il tempo per aggiornare modelli e runtime, e — soprattutto — che un modello più piccolo che sbaglia l'1% in più può costare, in correzioni manuali, più di tutto l'hardware.

Questo pezzo mette i due preventivi sullo stesso foglio: il **TCO di GPT-4o contro un LLM self-hosted** (prendiamo come riferimento un modello open della famiglia Qwen servito con vLLM) su uno scenario concreto di **100.000 documenti al mese**. È scritto per il **CFO e il CTO insieme**, con una regola: **ogni numero è una stima dichiarata**, con le ipotesi esplicite, così puoi sostituirle con le tue. Il risultato non è "vince il cloud" o "vince il self-hosted": è una mappa di quando vince l'uno o l'altro, e di quali variabili decidono davvero.

Spoiler, che vale per chi legge solo l'inizio: su 100.000 documenti al mese il costo di calcolo delle due soluzioni è **dello stesso ordine di grandezza**. A decidere sono le **persone** e la **qualità**. E il prezzo del token, che negli ultimi anni è sceso in modo marcato, è la variabile che sposta il break-even più di qualsiasi altra.

## Le unità: documento, pagina, token, run dell'agente

Il primo errore nei confronti di costo è mescolare le unità. Il fornitore cloud fattura in **token**; l'hardware si paga in **euro al mese**; il business ragiona in **documenti** (o pratiche, o ticket). Per confrontare serve una catena di conversione esplicita:

- **Documento → pagine**: quante pagine ha in media un documento del tuo flusso? Una fattura, un DDT, un contratto hanno lunghezze molto diverse.
- **Pagine → token**: un testo italiano da una pagina A4 di densità normale sta nell'ordine di alcune centinaia di token, spesso intorno a 600–900 a seconda di formattazione e tokenizer. Misuralo sui tuoi documenti con il tokenizer del modello che userai.
- **Token per chiamata**: oltre al documento, ogni chiamata porta le **istruzioni** (prompt di sistema, schema dell'output, esempi). In un'estrazione strutturata possono pesare quanto il documento stesso.
- **Chiamate per documento (run dell'agente)**: un'estrazione semplice è una chiamata; un agente che classifica, estrae, valida e riassume può farne quattro o cinque. È qui che i costi si moltiplicano senza che nessuno se ne accorga.
- **Token di output**: in un'estrazione strutturata sono pochi; in un riassunto o in una risposta discorsiva sono molti di più. Nel cloud costano **molto più** dei token di input.

Senza questa catena, "costa mille euro al mese" non si può confrontare con niente. Con la catena, puoi dire "costa 0,9 centesimi a documento", e quel numero lo puoi confrontare con un server, con un'altra API, o con il costo di una persona che fa lo stesso lavoro.

## Le ipotesi esplicite dello scenario

Lo scenario è volutamente semplice e realistico per una PMI o un ufficio amministrativo: **estrazione strutturata** (campi in JSON, più una breve nota) da documenti di due pagine in italiano. Tutte le ipotesi sono qui, per essere discusse e sostituite:

```yaml
# ipotesi-tco.yml — cambia questi numeri con i tuoi prima di prendere decisioni
volume:
  documenti_mese: 100000
  pagine_medie: 2
token_per_documento:
  istruzioni_sistema: 800        # prompt + schema output: identico per ogni documento
  contenuto: 1500                # ~750 token/pagina italiana (da misurare sui tuoi documenti)
  output: 400                    # JSON estratto + nota breve
scarti:
  moltiplicatore: 1.15           # retry, output non validi da rifare, run di eval e regressione
cloud:
  prezzo_input_usd_per_M: 2.50   # listino indicativo GPT-4o al momento della scrittura: VERIFICA
  prezzo_input_cache_usd_per_M: 1.25
  prezzo_output_usd_per_M: 10.00
  sconto_batch: 0.50             # elaborazione asincrona entro 24 ore
  cambio_usd_eur: 0.92
  persone_ore_mese: 3            # gestione chiavi, monitoraggio costi, cambi di versione
  infrastruttura_eur_mese: 20    # piccolo server di orchestrazione
self_hosted:
  server_gpu_eur: 9000           # server con una GPU da 48 GB di classe professionale
  ammortamento_mesi: 36
  potenza_media_kw: 0.35         # media tra carico e inattività
  prezzo_kwh_eur: 0.25           # tariffa business indicativa, da verificare in bolletta
  sovrappiu_raffreddamento: 0.15
  persone_ore_mese: 12           # aggiornamenti, monitoraggio, incidenti, cambio modello
  altro_eur_mese: 30             # UPS, ricambi, spazio
  noleggio_alternativo_eur_mese: 600   # server GPU in datacenter UE, energia inclusa
persone:
  costo_orario_tecnico_eur: 60
qualita:
  errore_cloud: 0.02             # quota di documenti da correggere a mano (da MISURARE)
  errore_self_hosted: 0.02       # scenario "qualità pari"; poi +1 punto
  minuti_correzione: 3
  costo_orario_operatore_eur: 30
```

Tre avvertenze sulle ipotesi:

- **I prezzi del cloud cambiano spesso** e tendono a scendere; i valori qui sopra sono un riferimento del listino pubblico di GPT-4o al momento della scrittura. Verifica sempre il listino corrente, gli sconti contrattuali e le condizioni del fornitore che userai, incluse le opzioni di elaborazione in UE.
- **I tassi di errore non si ipotizzano: si misurano.** Li ho messi uguali per partire, poi vedremo cosa succede se il modello self-hosted sbaglia di più. Il numero vero viene da un gold set sui tuoi documenti.
- **L'hardware è dimensionato per l'uso reale**: 100.000 documenti al mese, come vedremo, non saturano una singola GPU moderna con un modello di taglia media servito in modo efficiente.

## Cloud: listino, sconti, output e input in cache

Con le ipotesi sopra, i token del mese sono:

- **Input**: 100.000 × 2.300 × 1,15 ≈ **264,5 milioni** di token, di cui circa **92 milioni** sono le istruzioni di sistema ripetute identiche in ogni chiamata.
- **Output**: 100.000 × 400 × 1,15 ≈ **46 milioni** di token.

Tre modi di pagarli:

1. **Listino pieno, senza cache**: 264,5 M × 2,50 $ + 46 M × 10 $ ≈ 1.121 $ → circa **1.030 €** al mese.
2. **Con input in cache**: le istruzioni di sistema identiche vengono riconosciute come prefisso ripetuto e fatturate a prezzo ridotto. Il costo scende a circa **925 €** al mese. Per beneficiarne, il prompt va costruito con la parte fissa **all'inizio** e il documento alla fine.
3. **Elaborazione batch**: se i documenti non devono essere elaborati in tempo reale (ed è spesso il caso: fatture ricevute oggi, registrate domani), l'elaborazione asincrona ha uno sconto del 50%. Il costo scende a circa **515 €** al mese.

Due cose saltano all'occhio. La prima: l'**output costa quattro volte l'input** per token. Nel nostro scenario i token di output sono un sesto dei token di input, ma pesano per circa il 40% del costo. Ogni parola inutile nella risposta del modello (spiegazioni, cortesie, ripetizioni del documento) è denaro. La seconda: **la stessa API, usata meglio, costa la metà**. Prima di confrontare il cloud con qualsiasi alternativa, ottimizza l'uso del cloud: prompt con prefisso stabile, output minimale e strutturato, batch dove la latenza non conta.

Alla spesa per i token vanno aggiunte le voci che il preventivo "l'API costa mille euro" dimentica: qualche ora al mese di una persona (chiavi, monitoraggio della spesa, adeguamento ai cambi di versione del modello) e un piccolo server che orchestra le chiamate. Nel nostro scenario, circa **200 €** al mese.

## Self-host: GPU, ammortamento, energia, raffreddamento

Il lato self-hosted ha un profilo opposto: costi quasi tutti **fissi**, indipendenti dal volume fino a quando l'hardware regge.

**Hardware.** Per un modello open di taglia media (le famiglie Qwen, ad esempio, offrono modelli da pochi miliardi a decine di miliardi di parametri; verifica sempre la licenza della specifica taglia che scegli) servito con un runtime efficiente come vLLM, un server con una GPU da 48 GB di classe professionale permette di far girare modelli fino a qualche decina di miliardi di parametri quantizzati, con margine per il batching. Nell'ipotesi: **9.000 €** ammortizzati su 36 mesi, cioè **250 €** al mese. In alternativa, un server GPU a noleggio in un datacenter europeo, nell'ordine di **600 €** al mese con energia e raffreddamento inclusi. Sul confronto tra runtime e sulla scelta del motore di serving ho scritto in dettaglio in {{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }}.

**Il server è sottoutilizzato, e va bene così.** 100.000 documenti al mese sono circa 3.300 al giorno, cioè poco più di un milione e mezzo di token di output al giorno. Un modello di taglia media servito con batching su una GPU moderna produce, in aggregato, centinaia o migliaia di token al secondo: il lavoro di un giorno si completa in un'ora o poco più. La GPU passa gran parte del tempo inattiva. Questo abbassa il costo energetico, ma significa anche che **stai pagando capacità che non usi**: il self-hosted conviene di più quando il volume cresce e riempie la macchina.

**Energia.** Con una potenza media di 0,35 kW (media tra le ore di lavoro e l'inattività, server completo), il consumo è di circa **255 kWh al mese**. A una tariffa business indicativa di 0,25 €/kWh, più un 15% per il raffreddamento dell'ambiente (in un ufficio, d'estate, il calore di un server si paga due volte), fanno circa **73 €** al mese. Non è la voce che decide, ma non è zero, ed è quella che il preventivo "poi è gratis" dimentica sempre.

**Altro.** Un gruppo di continuità, un disco di ricambio, lo spazio: una trentina di euro al mese, come stima.

## Persone: chi rianima il box alle 2 di notte

Ecco la voce che sposta davvero il risultato. Un server self-hosted non si gestisce da solo:

- **aggiornamenti** del sistema operativo, dei driver GPU, del runtime di inferenza e del modello;
- **monitoraggio**: la coda di lavoro, la memoria GPU, gli errori, lo spazio disco;
- **incidenti**: il servizio che si blocca, il driver che dopo un aggiornamento non riconosce la GPU, il disco che si riempie di log;
- **cambi di modello**: quando esce un modello migliore, va provato sul gold set, confrontato, messo in produzione con un rollback pronto.

Nell'ipotesi, **12 ore al mese** di una figura tecnica a 60 €/h: **720 €** al mese. Sembra tanto? Per un sistema in produzione è una stima prudente, non pessimista. E c'è una domanda che il CFO deve fare esplicitamente: **chi interviene se il server si ferma alle due di notte?**

La risposta ragionevole per quasi tutte le PMI è: **nessuno, e il sistema deve essere progettato per sopportarlo**. I documenti entrano in una coda; se l'inferenza si ferma, la coda cresce; al mattino un allarme avvisa, qualcuno interviene, e la coda si smaltisce in un'ora perché la macchina è sovradimensionata. Nessuna reperibilità notturna, nessun costo di guardia. Se invece il processo richiede risposte in tempo reale a qualunque ora, il costo delle persone raddoppia (reperibilità) oppure il self-hosted smette di essere una buona idea.

Nel cloud la voce persone non sparisce: si riduce. Qualcuno deve comunque sorvegliare la spesa, gestire le chiavi, reagire ai cambi di versione del modello che possono alterare i risultati. Ma non deve rianimare un server.

## Scarti: retry, eval, gold set — e le correzioni umane

Il moltiplicatore 1,15 sui token rappresenta gli **scarti di calcolo**: chiamate fallite e ripetute, output che non rispettano lo schema e vanno rifatti, documenti rielaborati dopo una correzione del prompt, e le esecuzioni periodiche sul **gold set** per verificare che la qualità non sia peggiorata. Sono costi che esistono in entrambe le soluzioni, e che nei preventivi spariscono sempre.

Ma lo scarto che pesa davvero è un altro: **l'errore del modello che una persona deve correggere**. Nel nostro scenario, un documento estratto male richiede in media tre minuti di un operatore per essere individuato e corretto, a 30 €/h: 1,50 € a documento. Con un tasso di errore del 2%, sono 2.000 documenti al mese: **3.000 € di correzioni**. È più di tutta la spesa per token e hardware messa insieme.

Questo cambia completamente la domanda. Non è "quale soluzione costa meno di calcolo", ma **"quale soluzione produce meno lavoro umano di correzione per euro speso"**. Un punto percentuale di errore in più, su 100.000 documenti, sono 1.000 correzioni in più: **1.500 € al mese**. Più di quanto costi l'intera infrastruttura self-hosted.

Per questo il tasso di errore non si ipotizza: si misura, con un gold set di documenti reali su cui confronti le due soluzioni prima di decidere. Ho descritto come costruirlo e come misurare l'accuratezza campo per campo nel pezzo sull'estrazione dalle fatture elettroniche; e come tracciare costo e qualità per ogni esecuzione in produzione in {{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}.

## Lo scenario da 100.000 documenti al mese: il foglio di calcolo narrato

Mettiamo tutto insieme. Ecco la **tabella TCO** mensile, con le ipotesi della sezione precedente (valori arrotondati, stime):

| Voce (€/mese) | Cloud, listino con cache | Cloud, batch | Self-hosted di proprietà | Self-hosted a noleggio |
|---------------|--------------------------|--------------|--------------------------|------------------------|
| Token / calcolo | 926 | 516 | — | — |
| Hardware (ammortamento o noleggio) | — | — | 250 | 600 |
| Energia + raffreddamento | — | — | 73 | inclusa |
| Infrastruttura di contorno / altro | 20 | 20 | 30 | — |
| Persone tecniche | 180 | 180 | 720 | 720 |
| **Subtotale tecnico** | **1.126** | **716** | **1.073** | **1.320** |
| Correzioni umane (errore 2%) | 3.000 | 3.000 | 3.000 | 3.000 |
| **Totale, qualità pari** | **4.126** | **3.716** | **4.073** | **4.320** |
| Correzioni se self-hosted al 3% | — | — | 4.500 | 4.500 |
| **Totale, self-hosted −1 punto qualità** | — | — | **5.573** | **5.820** |

Come leggerla:

- **A qualità pari**, il self-hosted di proprietà e il cloud a listino **si equivalgono**: circa 4.100 € al mese entrambi. Il cloud in batch è la soluzione più economica, di circa 350–400 € al mese.
- **Il self-hosted a noleggio** costa un po' di più di quello di proprietà, ma non richiede investimento iniziale né gestione fisica dell'hardware: è spesso il modo giusto di provare il self-hosted prima di comprare.
- **Se il modello self-hosted sbaglia un punto percentuale in più**, il vantaggio sparisce: circa 1.450–1.850 € al mese in più del cloud. Nessuna ottimizzazione hardware recupera questa differenza.
- **Le correzioni umane sono la voce più grande in ogni colonna.** Il modo migliore per ridurre il TCO non è scegliere tra cloud e self-hosted: è ridurre il tasso di errore, con prompt migliori, validazioni deterministiche e un confronto rigoroso sul gold set.

Il calcolo, in forma di codice, per rifarlo con i tuoi numeri:

```python
def tco_mensile(docs, tin=2300, tcache=800, tout=400, scrap=1.15,
                p_in=2.50, p_cache=1.25, p_out=10.00, usd_eur=0.92, batch=False,
                err=0.02, min_corr=3, eur_h_oper=30):
    M = 1e6
    t_in, t_cache, t_out = docs*tin*scrap/M, docs*tcache*scrap/M, docs*tout*scrap/M
    if batch:
        token = (t_in*p_in + t_out*p_out) * 0.5 * usd_eur
    else:
        token = ((t_in - t_cache)*p_in + t_cache*p_cache + t_out*p_out) * usd_eur
    correzioni = docs * err * (min_corr/60) * eur_h_oper
    return {"token": round(token), "correzioni": round(correzioni)}

def self_hosted_fisso(server=9000, mesi=36, kw=0.35, eur_kwh=0.25, raffr=0.15,
                      ore=12, eur_h=60, altro=30):
    energia = kw * 730 * eur_kwh * (1 + raffr)
    return round(server/mesi + energia + ore*eur_h + altro)

def break_even_docs(costo_token_per_doc, fisso_self, fisso_cloud=200):
    """Volume oltre il quale il self-hosted costa meno (a qualità pari)."""
    return round((fisso_self - fisso_cloud) / costo_token_per_doc)

per_doc = tco_mensile(100_000)["token"] / 100_000          # ~0,009 € a documento
print(break_even_docs(per_doc, self_hosted_fisso()))        # ~94.000 documenti/mese
```

## Break-even: dove il self-hosted inizia a convenire

Il self-hosted ha costi fissi, il cloud costi variabili. Esiste quindi un volume oltre il quale il self-hosted costa meno — a parità di qualità. Con le nostre ipotesi:

- **Contro il cloud a listino con cache** (circa 0,93 centesimi di token per documento): il break-even è intorno a **94.000 documenti al mese**. Il nostro scenario da 100.000 è appena sopra: siamo esattamente nella zona grigia.
- **Contro il cloud in batch** (circa 0,52 centesimi a documento): il break-even sale a circa **169.000 documenti al mese**.
- **Se il costo delle persone è condiviso** — per esempio perché hai già un sistemista che gestisce altri server e il carico aggiuntivo è la metà — il costo fisso self-hosted scende a circa 710 € e il break-even a circa **55.000** documenti contro il listino, e circa **100.000** contro il batch.

Oltre il break-even, ogni documento in più costa quasi zero al self-hosted (un po' di energia), finché l'hardware regge; e il nostro server, come abbiamo visto, ha ampio margine. È qui che il self-hosted diventa nettamente vantaggioso: a 300.000 o 500.000 documenti al mese la differenza sul calcolo diventa di migliaia di euro al mese — sempre a patto che la qualità sia equivalente.

## Sensibilità al prezzo del token

La variabile che sposta di più il break-even non è l'hardware né l'energia: è il **prezzo del token**. E il prezzo del token cambia, di solito verso il basso, a ogni nuova generazione di modelli e a ogni revisione dei listini. Ecco cosa succede al nostro scenario (cloud con cache, qualità pari, persone non condivise):

| Prezzo del token rispetto all'ipotesi | Costo token cloud (100k doc) | Break-even self-hosted |
|---------------------------------------|------------------------------|------------------------|
| ×0,25 (un modello molto più economico) | ~230 €/mese | ~377.000 doc/mese |
| ×0,5 | ~460 €/mese | ~189.000 doc/mese |
| ×1 (ipotesi) | ~926 €/mese | ~94.000 doc/mese |
| ×2 (un modello più grande o più caro) | ~1.850 €/mese | ~47.000 doc/mese |

La lettura per il CFO: **una decisione di acquisto hardware presa oggi su un break-even calcolato con il listino di oggi può invecchiare in un trimestre**. Se il fornitore dimezza i prezzi, o esce un modello più piccolo ed economico con qualità sufficiente per il tuo compito, il break-even raddoppia e il server comprato diventa meno conveniente. Vale anche il contrario: se il compito richiede un modello più capace e più caro, il self-hosted conviene prima.

Per questo, se decidi per il self-hosted solo per ragioni di costo, conviene iniziare **a noleggio**: il costo è un po' più alto, ma la decisione è reversibile in un mese invece che in tre anni.

## L'architettura di riferimento

Qualunque sia la scelta, l'architettura che rende il confronto possibile — e la scelta reversibile — è la stessa:

```
  Documenti ──► CODA ──► ORCHESTRATORE ──► ┌──────────────────────────┐
                              │            │ ADATTATORE DEL MODELLO    │
                              │            │  ├─ API cloud (UE, DPA)   │
                              │            │  └─ vLLM self-hosted      │
                              │            └──────────────────────────┘
                              ▼
                    VALIDAZIONE deterministica (schema, checksum, coerenza)
                              │
                     ┌────────┴─────────┐
                     ▼                  ▼
               OK → gestionale    KO/incerto → correzione umana
                              │
                              ▼
          OSSERVABILITÀ: token, costo, latenza, esito per documento
          GOLD SET: stessa suite eseguita su entrambi i backend
```

**Cosa non tocca la scelta del modello**: la coda, la validazione, il flusso verso il gestionale, il gold set. Il modello è un componente intercambiabile dietro un adattatore. Questo permette di misurare entrambe le opzioni sugli stessi documenti, di spostare il traffico gradualmente, e di tornare indietro se i numeri cambiano. Il lock-in è il costo nascosto più alto di tutti, ed è quello che nessun preventivo mostra.

## Quando restare sul cloud (picchi, qualità, time-to-first)

Anche quando i numeri sembrano favorire il self-hosted, ci sono situazioni in cui il cloud resta la scelta giusta:

- **Picchi di volume.** Se a fine mese arrivano in tre giorni i documenti di due settimane, il self-hosted deve essere dimensionato per il picco (o accettare una coda di qualche giorno), mentre il cloud scala da solo. Se i picchi sono forti e imprevedibili, il cloud o un modello ibrido (base in casa, picchi in cloud) è più efficiente.
- **Qualità su compiti difficili.** Per estrazioni semplici e strutturate, i modelli open di taglia media sono spesso sufficienti. Per compiti con ragionamento complesso, documenti molto eterogenei o lingue e formati rari, i modelli di frontiera possono avere un vantaggio di qualità che, come abbiamo visto, vale più di qualsiasi risparmio sul calcolo.
- **Time-to-first.** Con il cloud, un progetto parte in giorni. Con il self-hosted servono settimane per hardware, installazione, tuning e test. Nella fase di esplorazione, quando non sai ancora se il progetto funziona, il cloud è quasi sempre la scelta giusta.
- **Nessuna competenza interna.** Senza una persona in grado di gestire un server GPU, il self-hosted è un rischio operativo, non un risparmio.

E, all'opposto, casi in cui il self-hosted si sceglie **indipendentemente dal TCO**: documenti con dati sanitari, legali o particolarmente riservati, vincoli contrattuali dei clienti sulla localizzazione dei dati, requisiti di sovranità. Esistono anche fornitori cloud con elaborazione in UE e garanzie contrattuali serie; ma se il requisito è che i dati non escano dalla tua infrastruttura, la domanda sul costo diventa secondaria.

## Come rivedere il TCO ogni trimestre

Il TCO non è un calcolo da fare una volta: è un cruscotto da aggiornare. Ogni trimestre:

1. **Costo reale per documento**, dall'osservabilità: token effettivi (inclusi retry), costo per esecuzione, per tipo di documento. Confrontalo con l'ipotesi iniziale.
2. **Tasso di errore reale**, dalle correzioni umane registrate e dal gold set. È la voce più importante.
3. **Utilizzo dell'hardware** (se self-hosted): quante ore al giorno la GPU lavora davvero. Un utilizzo molto basso indica sovradimensionamento; uno vicino alla saturazione indica che serve pianificare.
4. **Ore di manutenzione effettive**, non stimate. Se sono il doppio dell'ipotesi, il break-even si sposta.
5. **Listini e modelli nuovi**: il prezzo del token è cambiato? È uscito un modello open più piccolo con qualità sufficiente? Rilancia il gold set e ricalcola.
6. **Volume**: il flusso di documenti è cresciuto o calato? Rispetto al break-even, dove sei?

Con l'adattatore del modello e il gold set in piedi, rivedere la scelta costa un pomeriggio. Senza, costa un progetto.

## Percorso di implementazione, a step

1. **Definisci l'unità** (documento, pratica, ticket) e misura su un campione reale pagine, token di input, token di output e chiamate per unità.
2. **Scrivi le ipotesi** in un file condiviso tra CFO e CTO, come quello sopra.
3. **Costruisci il gold set**: un centinaio di documenti rappresentativi con i risultati attesi.
4. **Ottimizza l'uso del cloud** prima di confrontarlo: prefisso stabile per la cache, output minimale, batch dove possibile.
5. **Metti un adattatore** tra orchestratore e modello, così i due backend sono intercambiabili.
6. **Prova il self-hosted a noleggio** per un mese sullo stesso flusso (o su una sua parte), con la stessa validazione.
7. **Misura su entrambi**: costo per documento, tasso di errore, latenza, ore di gestione effettive.
8. **Calcola il TCO reale** con le correzioni umane incluse e il break-even con i tuoi numeri.
9. **Decidi**, e scrivi le condizioni che ti farebbero cambiare idea (prezzo del token, volume, qualità).
10. **Rivedi ogni trimestre** con i dati di produzione.

## Fallimenti tipici e come li riconosci

- **Costo cloud molto sopra la stima.** Nei log: token di output molto più alti del previsto (il modello "spiega" invece di restituire solo il JSON), o chiamate per documento più numerose (retry, agenti che fanno più passaggi). Limita l'output e controlla i retry.
- **La cache non si attiva.** Il costo non scende nonostante le istruzioni ripetute: il prefisso non è stabile (una data, un identificativo o il documento stesso all'inizio del prompt). Metti la parte fissa all'inizio, sempre identica.
- **GPU inattiva per il 95% del tempo.** Il self-hosted è sovradimensionato per il volume attuale: valuta il noleggio di una macchina più piccola o di concentrare altri carichi sullo stesso server.
- **Ore di manutenzione in crescita.** Aggiornamenti che rompono driver o runtime, incidenti ricorrenti: il costo persone sta superando l'ipotesi. Stabilizza versioni e procedure, o riconsidera il cloud.
- **Correzioni umane in aumento dopo un cambio di modello.** Il nuovo modello, più economico, sbaglia di più: il risparmio sul calcolo si è trasformato in un costo di persone più alto. Il gold set lo avrebbe mostrato prima.
- **Code che crescono a fine mese.** Picchi non previsti nel dimensionamento: coda di qualche giorno o capacità aggiuntiva temporanea in cloud.

## Quando NON fare questo esercizio (o farlo in piccolo)

- **Se il volume è di poche migliaia di documenti al mese**, il cloud costa poche decine di euro: non serve un TCO dettagliato, serve un buon uso dell'API e un gold set per la qualità.
- **Se il requisito di sovranità è vincolante**, il TCO serve a dimensionare il self-hosted, non a scegliere tra le due strade.
- **Se non hai ancora dimostrato che il progetto funziona**, non comprare hardware: prova in cloud (o in self-hosted a noleggio), misura, poi decidi.
- **Se nessuno può gestire un server GPU**, il self-hosted non è un'opzione di costo: è un rischio. Resta in cloud, eventualmente con un fornitore che elabora in UE.

## Checklist prima di decidere

- [ ] Unità di costo definita e misurata su documenti reali (pagine, token in/out, chiamate).
- [ ] Ipotesi scritte e condivise tra CFO e CTO, con fonti e date dei prezzi.
- [ ] Uso del cloud ottimizzato: prefisso stabile per la cache, output minimale, batch dove possibile.
- [ ] Scarti inclusi: retry, output non validi, esecuzioni di eval.
- [ ] Energia, raffreddamento e ammortamento inclusi nel self-hosted.
- [ ] Ore di persone stimate con onestà, e risposta scritta a "chi interviene di notte?".
- [ ] Tasso di errore misurato su un gold set per entrambe le soluzioni, e correzioni umane nel TCO.
- [ ] Break-even calcolato con i tuoi numeri e sensibilità al prezzo del token.
- [ ] Adattatore del modello per rendere la scelta reversibile.
- [ ] Revisione trimestrale pianificata con i dati di produzione.

## Il verdetto

Su **100.000 documenti al mese**, il confronto tra **GPT-4o in cloud e un LLM open self-hosted** non ha un vincitore sul costo di calcolo: con ipotesi realistiche, siamo esattamente intorno al break-even, e il cloud usato bene — cache e batch — resta la soluzione più economica per il solo calcolo. Chi ti dice che il self-hosted "poi è gratis" dimentica energia, persone e il server che si ferma alle due di notte; chi ti dice che il cloud "costa solo mille euro" dimentica le persone e gli scarti.

La voce che decide davvero è quella che nessuno dei due preventivi contiene: **il lavoro umano per correggere gli errori del modello**. Un punto percentuale di errore in più vale, in questo scenario, più dell'intera infrastruttura. Per questo la scelta si fa con un gold set sui tuoi documenti, non con un listino; si fa con un adattatore che la renda reversibile; e si rivede ogni trimestre, perché il prezzo del token cambia più in fretta dell'ammortamento di un server.

Il self-hosted diventa nettamente conveniente quando il volume cresce oltre il break-even, quando le persone che lo gestiscono sono già in casa, o quando la sovranità dei dati è un requisito e non un'opzione. In tutti gli altri casi, il cloud ben usato — magari con elaborazione in UE — è spesso la risposta più sensata. Ciò che non è mai sensato è decidere con metà dei numeri.

Se vuoi rifare questo conto con i tuoi documenti, i tuoi volumi e i tuoi vincoli, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Si parte da cento documenti reali e da un foglio di ipotesi condiviso.

## FAQ

### Conviene di più un LLM in cloud o self-hosted?
Dipende soprattutto dal volume, dalla qualità ottenuta sul tuo compito e dal costo delle persone. Con ipotesi realistiche, su 100.000 documenti al mese le due soluzioni costano cifre simili per il calcolo, e il cloud con cache e batch resta la più economica. Il self-hosted conviene nettamente oltre il break-even, quando il personale tecnico è già disponibile, o quando la sovranità dei dati è un requisito indipendente dal costo.

### Come si calcola il costo per documento di un LLM in cloud?
Si misura su documenti reali quanti token di input (istruzioni più contenuto) e di output genera ogni documento, e quante chiamate servono. Si moltiplica per il volume e per un fattore di scarto (retry, output non validi, esecuzioni di valutazione), poi per i prezzi del listino, distinguendo input normale, input in cache e output. Nel nostro scenario, con prezzi di listino indicativi, il risultato è intorno a un centesimo a documento.

### Perché i token di output pesano così tanto?
Perché nel listino dei principali modelli in cloud costano diverse volte i token di input. In un'estrazione strutturata l'output è una piccola parte dei token totali, ma può valere una quota rilevante del costo. Chiedere al modello solo il JSON necessario, senza spiegazioni né ripetizioni del documento, è uno dei modi più semplici per ridurre la spesa.

### Quanta elettricità consuma un server GPU per un LLM?
Dipende da GPU, carico e ore di utilizzo. Per un server con una GPU professionale che lavora qualche ora al giorno e resta inattivo il resto del tempo, una potenza media di qualche centinaio di watt porta a qualche centinaio di kWh al mese: con tariffe business indicative, qualche decina di euro, più il raffreddamento. Non è la voce che decide, ma va inclusa.

### Qual è il costo nascosto più grande?
Le correzioni umane degli errori del modello. Se un documento estratto male richiede qualche minuto di un operatore, anche un tasso di errore del 2% su 100.000 documenti genera migliaia di euro al mese di lavoro, più di token e hardware messi insieme. Un modello più economico che sbaglia di più può far salire il costo totale. Per questo il tasso di errore va misurato su un gold set prima di decidere.

### Cos'è il break-even tra cloud e self-hosted?
È il volume oltre il quale i costi fissi del self-hosted (hardware, energia, persone) diventano inferiori ai costi variabili del cloud, a parità di qualità. Con le ipotesi di questo articolo, è intorno a 94.000 documenti al mese contro il cloud a listino con cache e intorno a 170.000 contro l'elaborazione batch. Cambia molto con il prezzo del token e con il costo delle persone.

### Quanto è sensibile il risultato al prezzo del token?
Molto: è la variabile che sposta di più il break-even. Se il prezzo del token si dimezza, il volume di pareggio raddoppia; se raddoppia, il pareggio si dimezza. Poiché i listini cambiano spesso, una decisione di acquisto hardware basata solo sul costo può invecchiare in fretta: per questo conviene iniziare il self-hosted a noleggio e rivedere il TCO ogni trimestre.

### Chi deve gestire un LLM self-hosted?
Una persona con competenze su Linux, driver GPU, runtime di inferenza e monitoraggio, con qualche ora al mese dedicata ad aggiornamenti, incidenti e cambi di modello. Per le PMI, la scelta più sensata è progettare il flusso con una coda che tolleri i fermi notturni, così non serve reperibilità: se il server si ferma di notte, i documenti aspettano e vengono elaborati al mattino.

### Quando conviene restare sul cloud anche con volumi alti?
Quando ci sono picchi forti e imprevedibili, quando il compito richiede la qualità dei modelli più capaci, quando serve partire in fretta, o quando non ci sono competenze interne per gestire un server GPU. Un approccio ibrido — carico base in casa e picchi in cloud — può combinare i vantaggi, a patto di avere un adattatore che renda i due backend intercambiabili.

### Posso usare un modello open come Qwen senza problemi di licenza?
Molti modelli open sono distribuiti con licenze permissive, ma le condizioni possono variare tra famiglie e anche tra taglie diverse della stessa famiglia. Prima di usarli in produzione, verifica la licenza della specifica versione che scegli, in particolare per l'uso commerciale e per eventuali limiti di scala o di attribuzione.
