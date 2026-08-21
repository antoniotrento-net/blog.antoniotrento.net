---
lang: it
permalink: /it/blog/langgraph-vs-n8n-vs-python/
title: "LangGraph o n8n o uno script Python: quale orchestratore per un agente che deve davvero eseguire (non chiacchierare)"
date: 2026-09-25 07:30:00 +0200
author: "Antonio Trento"
description: "Non è una guerra di tool: è un framework di decisione. n8n, LangGraph e Python puro sullo stesso caso reale (prenotazione + scrittura CRM), con i criteri che contano davvero: stato, retry, test, e chi lo mantiene tra 12 mesi."
keywords: ["langgraph vs n8n vs python", "orchestrazione agenti", "tool calling produzione", "n8n limiti", "langgraph stato"]
image: /assets/images/posts/langgraph-vs-n8n-vs-python.jpg
pillar: agenti-esecuzione
related: [/it/blog/mcp-salesforce-agente-produzione/, /it/blog/n8n-self-hosted-openai-privacy/]
---

## Eseguire non è chiacchierare: la definizione che cambia tutto

Prima di scegliere tra `LangGraph vs n8n vs Python`, bisogna essere onesti su cosa vuol dire "agente che esegue". Un chatbot che genera testo non ha conseguenze: se sbaglia una parola, la riscrivi. Un agente che **esegue** produce **side effect nel mondo reale**: prenota un appuntamento, scrive un record nel CRM, manda una comunicazione, muove dei soldi. E i side effect non si annullano riscrivendo: una prenotazione doppia è una prenotazione doppia, un record scritto due volte è un dato corrotto. Questa è la differenza che rende la scelta dell'orchestratore una decisione seria e non un capriccio di moda.

Perché quando un agente esegue, l'orchestratore — lo strumento che coordina i passi, chiama i tool, gestisce lo stato — deve reggere cose che a un chatbot non servono: **lo stato** (dove sono arrivato nel processo), i **retry** senza raddoppiare i side effect (idempotenza), l'**osservabilità** (cosa ha fatto e perché), i **test** (verificare prima di mandarlo in produzione), e — il criterio che tutti dimenticano — **chi lo manterrà tra 12 mesi**. In questo articolo non faccio la guerra dei tool: costruisco un **framework di decisione**. Mettiamo lo stesso caso reale — una prenotazione con scrittura nel CRM — nei tre approcci (n8n, LangGraph, Python puro), vediamo pro e contro concreti di ognuno, e ricaviamo i criteri per scegliere il tuo. Perché non esiste "il migliore": esiste quello giusto per il *tuo* caso, il *tuo* team e la *tua* manutenzione.

## Il caso di prova: prenotazione più scrittura CRM

Per confrontare seriamente, serve un caso concreto uguale per tutti. Il nostro: **un agente che riceve una richiesta ("prenota una consulenza per il cliente X giovedì pomeriggio"), verifica la disponibilità, crea la prenotazione, e scrive l'attività nel CRM.** Ha tutti gli ingredienti che contano:

- **Side effect reali**: crea una prenotazione e scrive nel CRM. Sbagliare ha conseguenze.
- **Passi con dipendenze**: non puoi scrivere nel CRM prima di aver confermato la prenotazione.
- **Punti di fallimento**: la disponibilità può mancare, il CRM può rifiutare, la rete può cadere a metà.
- **Bisogno di idempotenza**: se qualcosa va storto e si ritenta, non deve creare due prenotazioni.
- **Un momento di giudizio**: se l'orario chiesto non è libero, l'agente propone alternative (e magari un umano conferma).

Questo caso lo useremo come metro. Ogni orchestratore lo può fare — ma *come* lo fa, e cosa ti costa in stato, test e manutenzione, è dove si vede la differenza. Ed è anche il caso che mostra perché l'esecuzione va progettata con le reti di sicurezza degli [agenti che scrivono sui sistemi di produzione]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}): idempotenza, approvazione, audit.

## n8n: veloce, visibile, debole su stato lungo e test

n8n è l'orchestratore visuale: costruisci il flusso trascinando nodi, lo vedi a colpo d'occhio, parte in fretta. Per molti agenti è un'ottima scelta, e va detto senza snobismo.

**Dove n8n vince:**

- **Velocità di partenza.** Un flusso "ricevi richiesta → controlla disponibilità → crea prenotazione → scrivi CRM" lo monti in poche ore, con i nodi già pronti per le integrazioni comuni.
- **Visibilità per i non sviluppatori.** Il flusso è un diagramma: un responsabile operativo, non solo un dev, capisce cosa fa e dove si è fermato. È un vantaggio enorme per la manutenzione da parte di team misti.
- **Integrazioni pronte.** Nodi per centinaia di servizi, senza scrivere il codice di connessione.
- **Self-hosting sovrano.** Gira in casa tua, con il [modello locale al posto del cloud]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}).

**Dove n8n fatica:**

- **Lo stato lungo.** Un agente che deve mantenere un contesto complesso attraverso molti passi, con cicli e decisioni ramificate, mette in difficoltà il modello lineare-visuale. n8n è nato per i workflow (A→B→C), non per gli agenti che ragionano in loop.
- **I cicli e le decisioni complesse.** Si possono fare, ma diventano diagrammi ingarbugliati, difficili da leggere quando la logica è ricca. Il vantaggio della visibilità si perde quando il flusso è un labirinto.
- **I test automatici.** Testare un workflow visuale in modo automatico è scomodo: non hai i test unitari che hai col codice. Verifichi "a mano", eseguendo. Su un agente che ha side effect reali, questa è una debolezza seria.
- **Il versionamento.** Un workflow n8n è un JSON. Metterlo in git funziona, ma i diff sono illeggibili: capire "cosa è cambiato tra due versioni" guardando un JSON è doloroso. Il code review vero è difficile.

n8n è ideale quando il flusso è **relativamente lineare, le integrazioni contano, e vuoi che anche i non-dev lo vedano e lo tocchino.** Diventa scomodo quando la logica dell'agente si fa complessa, hai bisogno di test seri, o il versionamento pulito è importante.

## LangGraph: stato, cicli, checkpoint, e una curva di debug

LangGraph è un framework (in codice) pensato **apposta per gli agenti con stato**. Modella l'agente come un grafo: nodi (i passi), archi (le transizioni, anche condizionali), e uno stato che scorre attraverso il grafo. È l'opposto filosofico di n8n: non visuale, ma potentissimo sulla logica complessa.

**Dove LangGraph vince:**

- **Lo stato esplicito.** Lo stato dell'agente è una struttura dati chiara che passa di nodo in nodo. Sai sempre "cosa so finora", ed è la cosa giusta per agenti che ragionano su più passi.
- **I cicli.** Un agente che prova, valuta, riprova, cambia strategia: i cicli sono nativi nel grafo. "Decidi → esegui → torna a decidi" è naturale, dove in n8n sarebbe un groviglio.
- **I checkpoint.** LangGraph può **salvare lo stato** a ogni passo e riprendere da lì. Questo abilita due cose d'oro: riprendere dopo un crash senza ricominciare, e il **human-in-the-loop** — l'agente si ferma, aspetta l'approvazione di un umano, e riprende. Perfetto per il "conferma la prenotazione" del nostro caso.
- **È codice, quindi testabile e versionabile.** Unit test veri, diff git leggibili, code review normale.

**Dove LangGraph costa:**

- **La curva di apprendimento e di debug.** È un framework con i suoi concetti (stato, nodi, archi condizionali, checkpointer). Debuggarlo quando la logica è complessa richiede di capire come il grafo esegue. Non è "apri e vedi" come n8n.
- **Serve un dev che lo conosce.** Non è per i non sviluppatori. E non è per un dev qualsiasi al primo giorno: c'è da imparare il framework.
- **Overhead per casi semplici.** Per un flusso lineare, LangGraph è sovraingegneria: tutta la potenza sullo stato e i cicli è sprecata se il tuo agente fa tre passi in fila.

Ecco lo scheletro del nostro caso in stile LangGraph — nota lo stato che scorre, il ciclo e il checkpoint:

```python
from langgraph.graph import StateGraph, END

def decidi(state):
    # l'LLM sceglie il prossimo tool in base allo stato corrente
    state["prossima_azione"] = llm_scegli_azione(state)
    return state

def esegui(state):
    # esegue il tool con idempotenza; niente doppie prenotazioni
    state = esegui_tool(state, idempotency_key=state["chiave"])
    return state

def instrada(state):
    return "fine" if state.get("completato") else "esegui"

g = StateGraph(StatoAgente)
g.add_node("decidi", decidi)
g.add_node("esegui", esegui)
g.add_edge("esegui", "decidi")          # ciclo: dopo aver eseguito, ridecide
g.add_conditional_edges("decidi", instrada, {"esegui": "esegui", "fine": END})
g.set_entry_point("decidi")

# checkpointer = salva lo stato → riprendi dopo crash + human-in-the-loop
app = g.compile(checkpointer=checkpointer)
```

LangGraph è la scelta quando l'agente ha **logica complessa, stato lungo, cicli, o bisogno di pause per l'approvazione umana** — e hai un dev che lo mantiene.

## Python puro: massimo controllo, minimo teatro

La terza strada, spesso la più sottovalutata: **scriverlo in Python puro**, con la libreria del modello e basta, senza framework di orchestrazione. Tu scrivi il loop, tu gestisci lo stato, tu chiami i tool.

**Dove Python puro vince:**

- **Controllo massimo.** Niente magia del framework: ogni riga fa quello che vedi. Quando qualcosa va storto, non devi capire cosa fa il framework sotto — è tutto tuo.
- **Minimo teatro.** Nessuna dipendenza pesante, nessun concetto astratto da imparare. Un dev Python legge il codice e capisce tutto subito.
- **Testabilità totale.** È codice normale: unit test su ogni pezzo, mock dei tool, test dei casi limite. Su un agente con side effect reali, poter testare tutto è oro.
- **Versionamento pulito.** Codice in git, diff leggibili, code review vero.
- **Nessun lock-in di framework.** Non sei legato all'evoluzione (o all'abbandono) di un framework di terzi.

**Dove Python puro costa:**

- **Costruisci tutto tu.** Lo stato, i retry, l'idempotenza, l'osservabilità: nessuno te li regala. Per casi complessi, rischi di reimplementare (peggio) quello che LangGraph ti darebbe già fatto.
- **Nessuna UI.** Nessun diagramma per i non-dev; è codice, punto.
- **Disciplina richiesta.** Con tutto il controllo viene tutta la responsabilità: se non sei disciplinato su stato e idempotenza, ti fai male da solo.

Ecco il nostro caso in Python puro — semplice, esplicito, testabile:

```python
MAX_STEP = 8

def esegui_agente(richiesta, stato):
    for _ in range(MAX_STEP):
        azione = llm_scegli_azione(richiesta, stato)   # cosa fare adesso
        if azione.tipo == "fine":
            return stato
        # esecuzione idempotente: retry non raddoppia i side effect
        risultato = esegui_tool(azione.tool, azione.args,
                                idempotency_key=stato.chiave)
        stato = aggiorna_stato(stato, risultato)
        if azione.richiede_umano:                      # human-in-the-loop
            return in_attesa_approvazione(stato)
    raise TimeoutAgente(stato)   # niente loop infiniti: ci si ferma e si logga
```

Nota il `MAX_STEP`: un agente che decide da solo può entrare in loop; il tetto ai passi è la rete di sicurezza che, in Python puro, metti tu esplicitamente. Python puro è la scelta quando la **logica è chiara, vuoi controllo e testabilità totali, e hai un dev che lo tiene** — senza il peso di un framework che non ti serve.

## Lo stesso caso nei tre stack: pro e contro a confronto

Mettiamo il nostro caso (prenotazione + scrittura CRM) nei tre, faccia a faccia, sui criteri che contano davvero:

| Criterio | n8n | LangGraph | Python puro |
|---|---|---|---|
| **Velocità di partenza** | Alta (ore) | Media | Media |
| **Visibilità per non-dev** | Alta (visuale) | Bassa | Bassa |
| **Stato lungo / cicli** | Debole | Forte (nativo) | Forte (lo scrivi tu) |
| **Checkpoint / human-in-loop** | Limitato | Nativo | Manuale |
| **Test automatici** | Difficile | Buono | Pieno |
| **Versionamento git** | Scomodo (JSON) | Pulito (codice) | Pulito (codice) |
| **Integrazioni pronte** | Tantissime | Da scrivere | Da scrivere |
| **Controllo fine** | Medio | Alto | Massimo |
| **Chi lo mantiene** | Anche non-dev | Dev con framework | Dev |

Come si legge questa tabella per decidere:

- **Se il flusso è lineare, le integrazioni sono tante, e vuoi che i non-dev lo vedano** → n8n. La velocità e la visibilità battono la debolezza sui test, *se* la logica resta semplice.
- **Se l'agente ha logica complessa, stato lungo, cicli, e serve il human-in-the-loop** → LangGraph. La potenza sullo stato ripaga la curva di apprendimento, *se* hai il dev.
- **Se la logica è chiara, vuoi controllo e test totali, e non ti serve la UI né la complessità del framework** → Python puro. La semplicità e la testabilità battono la "comodità" del framework, *se* hai la disciplina.

Nessuna riga di questa tabella dice "il migliore in assoluto". Dice "il migliore *per certe condizioni*". Ed è il punto: la scelta dell'orchestratore è un incrocio tra il tuo caso, il tuo team e la tua manutenzione.

## Il caso difficile: l'orario chiesto non è libero

Il caso lineare (l'orario è libero, si prenota, si scrive nel CRM) lo fanno bene tutti e tre. La differenza si vede nel **caso difficile**, quello con il momento di giudizio: *l'orario chiesto non è disponibile.* Ora l'agente deve proporre alternative, e la scelta finale la conferma un umano. Vediamo come reagiscono i tre.

- **n8n.** Va gestito con un ramo condizionale: "se non disponibile → cerca alternative → manda una richiesta di conferma → aspetta". Il problema è l'attesa: n8n deve *sospendere* il flusso finché l'umano non risponde, e la ripresa di un flusso in pausa per ore o giorni non è il suo forte. Diventa un flusso con webhook e stato esterno — fattibile, ma il diagramma si complica e la parte "aspetta l'umano" è la più fragile.
- **LangGraph.** È il suo terreno. Il nodo "verifica disponibilità" porta, con un arco condizionale, o al nodo "prenota" o al nodo "proponi alternative". Quest'ultimo salva un **checkpoint** e si ferma: l'umano riceve le alternative, sceglie, e l'agente **riprende dal checkpoint** con la scelta. La pausa per l'approvazione, anche lunga, è nativa. Il caso difficile qui è quasi banale.
- **Python puro.** Lo gestisci esplicitamente: la funzione ritorna uno stato `in_attesa_approvazione` (persistito), e una seconda entry-point riprende quando arriva la risposta umana. Massimo controllo, ma la logica di "salva stato e riprendi" la scrivi tu — che è esattamente ciò che LangGraph ti darebbe già fatto.

Il caso difficile è il rivelatore: **se i tuoi agenti hanno spesso momenti di attesa e ripresa (human-in-the-loop, processi lunghi), LangGraph ti regala ciò che negli altri due devi costruire.** Se invece i tuoi casi sono per lo più lineari e le attese rare, quella potenza è peso inutile, e n8n o Python bastano. È il caso reale, non il caso da demo, a dirti quale strumento ti serve — perché è il caso reale che dovrai mantenere.

## Osservabilità e replay: vedere cosa ha fatto l'agente

Qualunque orchestratore scegli, c'è una capacità non negoziabile per un agente che esegue: **l'osservabilità.** Quando un agente ha side effect reali, devi poter rispondere a "cosa ha fatto, in che ordine, con quali dati, e perché?" — sia per il debug (qualcosa è andato storto) sia per la fiducia (dimostrare cosa è successo).

Cosa serve:

- **Il log di ogni passo.** Ogni decisione dell'agente e ogni tool eseguito, con input e output. Non "l'agente ha fatto la prenotazione", ma "alle 10:32 ha chiamato `crea_prenotazione` con questi parametri e ha ricevuto questo risultato".
- **Lo stato a ogni passo.** Com'era lo stato prima e dopo ogni azione. Per ricostruire il ragionamento.
- **Il replay.** Poter **rieseguire** una sessione dell'agente (sui log, o in modo controllato) per capire dove ha sbagliato. È il debug degli agenti: senza, indaghi al buio.

Come se la cavano i tre:

- **n8n** ti dà una cronologia visuale delle esecuzioni: comoda per vedere dove si è fermato un flusso, meno per ricostruire il ragionamento di un agente complesso.
- **LangGraph**, avendo lo stato esplicito e i checkpoint, è ottimo per l'osservabilità e il replay: puoi riprendere da un checkpoint e vedere lo stato a ogni nodo.
- **Python puro** ti dà l'osservabilità che ti costruisci: se logghi bene ogni passo e stato, hai tutto; se non lo fai, non hai niente. Massima libertà, massima responsabilità.

Il principio: **un agente che esegue senza osservabilità è ingestibile.** Il primo giorno in cui qualcosa va storto in produzione — e succederà — la differenza tra "vedo cosa ha fatto e lo sistemo" e "non ho idea di cosa sia successo" è tutta qui. È lo stesso audit trail che rende governabili gli [agenti sul CRM]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}).

## Il criterio che decide tutto: chi lo mantiene tra 12 mesi

Ecco il criterio che pesa più di ogni feature, e che quasi nessuno mette al centro della scelta: **chi manterrà questo sistema tra dodici mesi?** Perché un agente in produzione non è "fatto e finito": va aggiornato, corretto, esteso. E lo strumento giusto dipende da *chi* farà quel lavoro.

- **Se lo manterrà un team misto, con persone non-dev che devono capirci qualcosa** → n8n. La visibilità visuale è impagabile quando chi mette mano non è solo uno sviluppatore. Un flusso che un responsabile operativo capisce si mantiene meglio di un codice che solo l'autore capisce.
- **Se lo manterrà un team di sviluppo con esigenze di logica complessa** → LangGraph, *a patto che* il team conosca il framework. Attenzione: scegliere LangGraph e poi non avere nessuno che lo sa mantenere è un lock-in verso la conoscenza di una persona sola.
- **Se lo manterrà uno o più dev che vogliono controllo e test, senza dipendere da un framework** → Python puro. Il codice semplice e testato è il più facile da riprendere per un dev nuovo, perché non deve prima imparare un framework: legge Python e capisce.

Il tranello più comune è scegliere lo strumento **per come è comodo costruirlo oggi**, non per come sarà mantenerlo domani. n8n è comodissimo da costruire, ma se poi la logica cresce e i test mancano, tra un anno è un labirinto fragile. LangGraph è potente, ma se l'unico che lo capiva se ne va, sei bloccato. Python puro richiede disciplina oggi, ma è il più facile da riprendere domani *se* è scritto bene. La domanda "chi lo mantiene tra 12 mesi?" va fatta **prima** di scegliere, non dopo — è la stessa lucidità sulla manutenzione che serve per [non ritrovarsi ostaggio di un software dopo il go-live]({{ '/it/blog/manutenzione-software-dopo-go-live/' | relative_url }}).

## L'architettura di riferimento (indipendente dall'orchestratore)

Qualunque dei tre scegli, l'architettura di un agente che esegue ha gli stessi confini:

- **L'orchestratore** (n8n / LangGraph / Python) coordina i passi.
- **Il modello** (locale, dallo stack sovrano) decide le azioni.
- **I tool** con idempotenza: ogni azione con side effect ha una idempotency key e non raddoppia.
- **Lo stato** persistito: dove è arrivato il processo, per riprendere dopo un crash.
- **L'osservabilità**: log di ogni passo e stato, per debug e replay.
- **Il human-in-the-loop** sulle azioni che pesano: la conferma della prenotazione passa da un umano.

**Cosa l'agente NON fa mai**, in tutti e tre:

- **Non esegue side effect senza idempotenza** (niente doppie prenotazioni).
- **Non entra in loop infiniti** (tetto ai passi).
- **Non prende da solo le decisioni che pesano** (human-in-the-loop dove serve).
- **Non esegue senza lasciare traccia** (osservabilità sempre).

Questi confini sono indipendenti dallo strumento: sono ciò che rende un agente *sicuro da mettere in produzione*, che tu lo scriva in n8n, LangGraph o Python. Lo strumento cambia la comodità; i confini restano.

## Cosa si rompe in produzione (e come lo leggi dai log)

- **Doppio side effect (n8n/Python senza idempotenza).** Sintomo: due prenotazioni, due record CRM. Nei log vedi due esecuzioni dello stesso tool a distanza di secondi. Causa: un retry senza idempotency key. Rimedio: idempotenza obbligatoria su ogni azione con effetto reale.
- **Loop infinito (agente che non chiude).** Sintomo: l'agente cicla, i costi salgono, non finisce mai. Nei log, la stessa sequenza di decisioni che si ripete. Causa: nessun tetto ai passi o una condizione di uscita mai raggiunta. Rimedio: `MAX_STEP` e condizioni di fine chiare.
- **Stato perso dopo un crash.** Sintomo: l'agente riparte da zero e rifà cose già fatte. Causa: stato non persistito (in n8n o Python fatti in fretta). Rimedio: checkpoint (LangGraph) o persistenza esplicita dello stato.
- **Workflow n8n illeggibile.** Sintomo: nessuno capisce più cosa fa il flusso, i cambiamenti fanno paura. Causa: logica complessa forzata nel visuale. Segnale che il caso ha superato n8n e va portato in codice.
- **Framework che cambia sotto i piedi (LangGraph).** Sintomo: un aggiornamento rompe il codice. Causa: dipendenza da un framework in evoluzione rapida. Rimedio: fissa le versioni, aggiorna con test.

Il filo: **i guasti degli agenti sono quasi sempre idempotenza, loop, stato e osservabilità** — gli stessi quattro, in tutti e tre gli stack. Chi li presidia (con qualsiasi strumento) ha agenti stabili; chi li ignora si fa male, per quanto bello sia il tool.

## I costi

Ordini di grandezza, stime dichiarate:

- **Costo di costruzione**: n8n il più basso (visuale, veloce); LangGraph e Python più alti (codice), ma con test che ripagano in stabilità.
- **Costo di manutenzione**: dipende da "chi lo mantiene" — n8n basso se il team è misto ma alto se la logica cresce senza test; Python/LangGraph prevedibile se il team è di dev.
- **Costo di esecuzione**: dominato dal modello (locale dallo stack sovrano: la GPU già discussa; niente costo a token se locale) e dalle chiamate ai sistemi esterni (occhio ai [governor limits di Salesforce]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}) se scrivi lì). L'orchestratore in sé pesa poco: gira su un server modesto.
- **Costo nascosto**: il tempo perso a debuggare un agente non osservabile, o a mantenere un workflow illeggibile. È il costo più alto e il meno visibile — si abbatte scegliendo per la manutenzione, non per la comodità iniziale.

## Quando NON usarne nessuno (cioè: niente agente)

L'onestà più importante: **spesso non ti serve un agente affatto.** Prima di scegliere l'orchestratore, chiediti se il problema richiede davvero un LLM che decide, o se è una logica deterministica travestita.

- **Se la logica è una sequenza fissa** ("quando arriva X, fai sempre Y e Z"), non ti serve un agente: ti serve un'automazione normale (un workflow n8n *senza* LLM, o uno script). Mettere un LLM a "decidere" quello che è già deciso aggiunge costo, latenza e imprevedibilità per nulla.
- **Se le regole sono chiare e finite**, il codice normale (o le regole del gestionale) le fa meglio: affidabile, gratis, senza allucinazioni.
- **L'agente ha senso solo quando c'è vera ambiguità da interpretare**: una richiesta in linguaggio naturale, casi non previsti, decisioni con sfumature. Lì l'LLM aggiunge valore.

La domanda a monte è: *questo problema ha bisogno di un LLM che decide, o è una regola che sto complicando?* Se è una regola, nessuno dei tre orchestratori-agente è la risposta: lo è una semplice automazione. Saper dire "qui non serve un agente" è parte del mestiere di chi costruisce sul serio — la stessa lucidità del [quando restare su un Flow invece di mettere l'AI in mezzo]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}).

## Checklist operativa prima della produzione

- [ ] Ho verificato che **serva davvero un agente** (vera ambiguità), non una regola.
- [ ] Ho scelto l'orchestratore su **caso + team + manutenzione a 12 mesi**, non sulla moda.
- [ ] Ogni azione con **side effect è idempotente** (niente doppie prenotazioni).
- [ ] C'è un **tetto ai passi**: nessun loop infinito.
- [ ] Lo **stato è persistito**: si riprende dopo un crash.
- [ ] C'è **osservabilità** completa: log di ogni passo e stato, replay possibile.
- [ ] Le **azioni che pesano** passano da un umano (human-in-the-loop).
- [ ] Il modello gira **in locale** (stack sovrano); i dati non escono.
- [ ] So **chi lo manterrà** e lo strumento è adatto a quella persona/team.
- [ ] Versioni **fissate** (specie con framework in evoluzione); test automatici dove possibile.

## Il verdetto: lo strumento segue il caso, non il contrario

`LangGraph vs n8n vs Python` non è una guerra da vincere: è una decisione da prendere sui criteri giusti. n8n vince quando il flusso è lineare, le integrazioni contano e i non-dev devono vederlo; LangGraph quando l'agente ha stato lungo, cicli e serve il human-in-the-loop, e hai chi lo mantiene; Python puro quando vuoi controllo e test totali senza il peso di un framework. Ma sotto qualsiasi scelta ci sono gli stessi confini non negoziabili — idempotenza, tetto ai passi, stato persistito, osservabilità, umano sulle decisioni che pesano — perché "eseguire" significa side effect nel mondo reale, e i side effect non si annullano riscrivendo. E il criterio che pesa più di tutti resta uno: **chi lo manterrà tra 12 mesi.** Scegli per quello, non per come è comodo costruire oggi.

Questo è un mattone della [guida agli agenti che eseguono davvero]({{ '/it/pillar/agenti-esecuzione/' | relative_url }}), dove l'automazione tocca i sistemi con giudizio. Se vuoi scegliere l'orchestratore giusto per il *tuo* caso e il *tuo* team, parti da [chi sono e come lavoro]({{ site.main_site }}/biografia/) o scrivimi due righe in [contatti]({{ site.main_site }}/contatti/).

## FAQ

**1. Qual è il migliore tra LangGraph, n8n e Python?**
Nessuno in assoluto. n8n per flussi lineari, integrazioni e visibilità ai non-dev; LangGraph per agenti con stato lungo, cicli e human-in-the-loop (se hai chi lo mantiene); Python puro per controllo e test totali senza framework. Il "migliore" dipende dal tuo caso, dal tuo team e da chi lo manterrà.

**2. Cosa vuol dire "eseguire" per un agente?**
Produrre side effect nel mondo reale: prenotare, scrivere nel CRM, mandare comunicazioni, muovere soldi. A differenza del chiacchierare (generare testo), i side effect non si annullano riscrivendo — una doppia prenotazione resta. Per questo un agente che esegue ha bisogno di stato, idempotenza e osservabilità che a un chatbot non servono.

**3. n8n non va bene per gli agenti?**
Va benissimo per flussi relativamente lineari con tante integrazioni, e ha il grande vantaggio della visibilità per i non-dev. Fatica quando la logica si fa complessa (cicli, stato lungo), quando servono test automatici, e sul versionamento pulito (è un JSON). Diventa scomodo se l'agente supera il flusso lineare.

**4. Quando conviene LangGraph?**
Quando l'agente ha logica complessa, stato lungo, cicli, o serve il human-in-the-loop (fermarsi per un'approvazione e riprendere), grazie ai checkpoint. Il costo è la curva di apprendimento e il bisogno di un dev che conosca il framework. Per casi semplici è sovraingegneria.

**5. Perché scegliere Python puro invece di un framework?**
Per controllo e testabilità totali, senza magia né lock-in di framework. Scrivi il loop, lo stato, i retry: tutto tuo, tutto testabile, diff git puliti. Il costo è che costruisci tutto tu (stato, idempotenza, osservabilità) e non hai UI. Ideale quando la logica è chiara e hai la disciplina.

**6. Come evito le doppie prenotazioni?**
Con l'idempotenza: ogni azione con side effect porta una idempotency key, e il sistema non riesegue un'azione già fatta. Vale in tutti e tre gli stack — è un confine indipendente dall'orchestratore. Senza, un retry crea due prenotazioni, ed è il guasto numero uno degli agenti che eseguono.

**7. Come tengo un umano nelle decisioni importanti?**
Con il human-in-the-loop: l'agente si ferma prima di un'azione che pesa (es. confermare la prenotazione) e aspetta l'approvazione. LangGraph lo fa nativamente coi checkpoint; in Python e n8n lo implementi (l'agente mette in attesa e riprende dopo l'ok). È il confine tra automazione utile e delega pericolosa.

**8. Qual è il criterio più importante nella scelta?**
Chi manterrà il sistema tra 12 mesi. Un team misto con non-dev → n8n (visibilità). Un team di sviluppo con logica complessa → LangGraph (se lo conoscono). Dev che vogliono controllo e test → Python. Scegliere per la comodità di costruzione oggi, ignorando la manutenzione, è l'errore più costoso.

**9. E l'osservabilità?**
Non negoziabile per un agente che esegue: devi poter vedere cosa ha fatto, in che ordine, con quali dati, e rieseguire (replay) per il debug. n8n dà una cronologia visuale; LangGraph è ottimo grazie a stato e checkpoint; Python te la costruisci (se logghi bene, hai tutto). Un agente senza osservabilità è ingestibile al primo problema.

**10. E se non mi serve affatto un agente?**
Succede spesso: se la logica è una sequenza fissa o regole chiare, non ti serve un LLM che decide — ti serve un'automazione normale (workflow senza LLM, o script). L'agente ha senso solo con vera ambiguità da interpretare. Mettere un LLM dove basta una regola aggiunge costo, latenza e imprevedibilità per niente.

**11. Posso combinare gli approcci invece di sceglierne uno?**
Sì, ed è spesso la scelta più saggia. Un pattern comune: **n8n per l'orchestrazione esterna e le integrazioni** (riceve gli eventi, parla coi sistemi, dà visibilità ai non-dev) che chiama, per il pezzo di logica complessa, un **servizio in Python o LangGraph** dove vive il ragionamento dell'agente con stato, test e idempotenza. Così prendi la visibilità e le integrazioni pronte di n8n *e* il controllo e la testabilità del codice, ognuno dove è più forte. Il confine tra i due va tenuto pulito (n8n non deve reimplementare la logica dell'agente, e il servizio Python non deve rifare le integrazioni), ma è un ibrido che in produzione funziona bene — e riflette il principio di fondo: lo strumento segue il pezzo di problema, non il contrario.
