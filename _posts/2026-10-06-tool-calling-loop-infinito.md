---
lang: it
permalink: /it/blog/tool-calling-loop-infinito/
title: "L'agente che gira in loop sulle tool call: come riconoscerlo dai log e come spezzarlo (senza spegnere tutto)"
date: 2026-10-06 07:30:00 +0200
author: "Antonio Trento"
description: "Il runaway agent che gira in loop sulle tool call è un incident da produzione: fattura API a tre zeri, CPU al 100%. Come riconoscerlo dai log, spezzarlo con max iterations, circuit breaker per tool, dedup e watchdog esterno — senza spegnere tutta la piattaforma."
keywords: ["tool calling loop infinito", "agente llm retry loop", "max iterations langgraph", "circuit breaker ai", "runaway agent", "agente ai in produzione"]
image: /assets/images/posts/tool-calling-loop-infinito.jpg
pillar: agenti-esecuzione
related: [/it/blog/osservabilita-llm-produzione/, /it/blog/kill-switch-agente-salesforce/]
---

## Lunedì mattina, fattura API a tre zeri

L'incident type che spaventa di più chi ha un agente in produzione non è il crash: è il contrario. L'agente **non si ferma**. Arrivi lunedì mattina, apri la dashboard del provider del modello e la fattura del weekend ha uno zero in più del solito — a volte tre. La CPU del container n8n è stata al 100% per ore. La coda dei job è ingolfata. E nei log, la stessa scena ripetuta migliaia di volte: l'agente chiama un tool, riceve un errore, "ci ripensa", richiama lo stesso tool, riceve lo stesso errore, all'infinito. Nessuno l'ha fermato perché era notte e perché nessun sistema era progettato per fermarlo.

Questo è il **tool calling loop infinito**, il *runaway agent*: un agente che entra in un ciclo di chiamate senza convergere, bruciando token, CPU ed euro finché qualcuno non se ne accorge o finché non si esaurisce un limite esterno. È uno degli incident più costosi e più prevenibili degli agenti in produzione, ed è il tema di oggi — raccontato come si racconta un incident vero: sintomi, cause, e i meccanismi per spezzarlo **senza spegnere tutta la piattaforma per tutti**.

Vedremo come riconoscerlo dai log, perché "max iterations a 25 è già tanto", il circuit breaker per tool con error budget, la deduplicazione delle chiamate identiche, e — il pezzo che quasi tutti dimenticano — il **watchdog esterno al grafo**, perché non puoi affidare a ciò-che-sta-andando-in-loop il compito di fermarsi da solo. Con contatore di step, allarme su tool/minuto e checklist di incident. È il seguito operativo dell'[osservabilità degli LLM in produzione]({{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}) (che ti dà gli occhi per vedere il loop) e del [kill switch per agenti che scrivono su Salesforce]({{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }}) (che ti dà il freno).

## I sintomi: come si presenta il runaway agent

Un loop non arriva con un cartello. Arriva coi sintomi, e riconoscerli in fretta è la differenza tra un fastidio e una fattura a tre zeri.

- **La fattura API che esplode.** Il segnale più caro. Un agente in loop fa centinaia o migliaia di chiamate al modello in poco tempo. Se paghi a token, la bolletta cresce in proporzione. Se sei self-hosted, non paghi il token ma paghi in GPU occupata e latenza per tutti gli altri.
- **CPU e memoria a saturazione.** Il processo dell'orchestratore (n8n, il tuo runtime di agenti) gira a vuoto a pieno carico. Su un Raspberry Pi o un server modesto, questo può mettere in ginocchio l'intero stack.
- **Coda piena, latenza per tutti.** Se l'agente in loop occupa i worker, gli altri job aspettano. Un singolo run impazzito degrada l'esperienza di tutti — è il motivo per cui "spegnere tutto" sembra l'unica opzione, e perché invece serve granularità.
- **Log ripetitivi.** La stessa tripletta (chiamata modello → tool → errore) che si ripete identica. Se scorri i log e vedi lo stesso tool con gli stessi argomenti quaranta volte in un run, hai trovato il loop.
- **Nessun output finale.** Il run non termina mai con un risultato: o va avanti finché non lo fermi, o muore per un timeout esterno (se ce l'hai).

Il punto: **questi sintomi sono osservabili solo se hai l'osservabilità.** Senza tracce e metriche, il primo sintomo che noti è la fattura, giorni dopo. Con le metriche giuste (chiamate al minuto, step per run, costo per run), lo vedi mentre succede e puoi agire. Il loop è un problema di controllo, ma prima ancora è un problema di visibilità.

## Le cause: perché un agente entra in loop

Capire le cause serve a prevenirle, non solo a spegnerle. Nella mia esperienza, un **agente LLM in retry loop** ha quasi sempre una di queste radici.

### Schema rotto (il modello produce ciò che il tool rifiuta)

L'agente chiama un tool con un payload che non rispetta lo schema (un IBAN malformato, un campo mancante). Il tool rifiuta. Il modello riceve l'errore, "corregge", ma produce di nuovo un payload che il tool rifiuta — magari lo stesso. Ciclo. È il legame diretto con il data contract: senza validazione e senza una policy di reject che a un certo punto *si arrende* invece di ritentare, lo schema rotto diventa un loop. (Ne ho parlato nel pezzo su [JSON Schema e tool calling contro l'IBAN inventato]({{ '/it/blog/json-schema-tool-calling-iban/' | relative_url }}): il retry-finché-passa è proprio uno dei modi in cui si innesca.)

### Tool che restituisce 500 (errore che sembra transitorio)

Un tool a valle (un'API, un DB) restituisce un errore 500 o va in timeout. Il modello lo interpreta come "riprova più tardi" e ritenta. Ma se l'errore è *persistente* (il servizio è giù, non transitorio), riprovare non risolve mai. L'agente distingue male tra "errore transitorio, ha senso ritentare" ed "errore permanente, inutile insistere", e in dubbio insiste.

### Il prompt che dice "insisti"

La causa più autoinflitta. Un prompt tipo *"non fermarti finché non hai completato il compito"*, *"riprova in tutti i modi possibili"*, *"sii tenace"*. Sembra motivazionale, è una ricetta per il loop: hai esplicitamente detto al modello di non arrendersi, e lui ti obbedisce anche quando arrendersi (o chiedere aiuto a un umano) sarebbe la cosa giusta. Un prompt che scoraggia il fallimento produce agenti che non falliscono mai — girano a vuoto invece.

### L'obiettivo impossibile

L'agente ha un compito che non può soddisfare (un dato che non esiste, un'azione non permessa) ma la sua logica non prevede "questo non è possibile" come esito. Continua a provare strade alternative all'infinito.

La tabella causa → sintomo → contromisura:

| Causa | Come la vedi nei log | Contromisura primaria |
|-------|---------------------|----------------------|
| Schema rotto | stesso tool, errore di validazione ripetuto | validazione + policy reject che si arrende |
| Tool 500 persistente | stesso tool, errore 5xx ripetuto | circuit breaker per tool |
| Prompt "insisti" | step che crescono, nessuna convergenza | max iterations + prompt che ammette il fallimento |
| Chiamate identiche | stesso tool + stessi args ripetuti | dedup delle chiamate |
| Obiettivo impossibile | esplorazione infinita di alternative | max iterations + esito "non possibile" |

## Max iterations, e perché 25 è già tanto

La prima difesa, la più semplice e la più trascurata: **un tetto al numero di passi che un agente può fare in un run.** Se il ciclo pensa→agisci→osserva non converge entro N passi, si ferma. Punto.

Molti runtime lo offrono: in LangGraph è il `recursion_limit`, con un default intorno a 25. E qui il punto contro-intuitivo del titolo: **25 è già tanto.** Un agente sano, su un compito ben definito, converge in **pochi passi** — tipicamente da 2 a 8. Prenota, scrivi nel CRM, rispondi: sono manciate di step. Se un agente arriva a 25 passi, nella grande maggioranza dei casi non sta "lavorando sodo": sta **girando a vuoto**. Il default alto è pensato per non interrompere casi legittimi complessi, ma per la maggior parte degli agenti di una PMI un tetto più basso (8–12) è più sano, e cattura il loop molto prima che diventi costoso.

Il contatore di step, in pseudo-codice, dentro il ciclo dell'agente:

```python
class LimiteStepSuperato(Exception): ...

def esegui_agente(task, max_step: int = 10):
    stato = init(task)
    for step in range(1, max_step + 1):
        azione = modello_decide(stato)          # think
        if azione.tipo == "risposta_finale":
            return azione.risultato              # convergenza sana
        risultato = esegui_tool(azione)          # act
        stato = aggiorna(stato, risultato)       # observe
        log_step(run_id=stato.run_id, step=step,
                 tool=azione.tool, esito=risultato.esito)
    # se arrivi qui, NON hai convertito entro max_step
    log_loop_sospetto(run_id=stato.run_id, step=max_step)
    raise LimiteStepSuperato(
        f"Agente non convergente in {max_step} step: possibile loop")
```

Nota due cose. Primo: il tetto è **basso di default** e lo alzi solo per compiti che dimostrabilmente ne hanno bisogno, non "per sicurezza" (la sicurezza è il tetto basso). Secondo: quando scatta, **non è un successo silenzioso**: logga il sospetto loop e solleva un'eccezione gestita, così l'incident è visibile, non nascosto.

Il max iterations è la rete minima. Ferma il loop, ma è grezzo: non distingue *perché* l'agente non converge. Per quello servono i meccanismi mirati che seguono.

## Circuit breaker per tool: l'error budget

Il max iterations ferma il singolo run. Ma se **dieci run diversi** chiamano tutti lo stesso tool che è giù, ognuno ci sbatterà fino al suo tetto di step, moltiplicando il danno. La difesa mirata è il **circuit breaker** — un pattern classico dell'SRE, applicato ai tool dell'agente.

L'idea: ogni tool ha un **error budget**. Se fallisce troppe volte in una finestra di tempo, il circuito si "apre": per un periodo, le chiamate a quel tool **falliscono subito**, senza nemmeno provare, restituendo un errore veloce all'agente. Così non martelli un servizio che è già a terra, e l'agente riceve un "non disponibile" immediato invece di aspettare timeout su timeout.

I tre stati del circuit breaker:

- **Chiuso (closed):** funzionamento normale, le chiamate passano. Si conta il tasso di errore.
- **Aperto (open):** troppi errori nella finestra → il circuito si apre. Le chiamate falliscono immediatamente per un tempo di "raffreddamento". Nessuno spreco.
- **Semiaperto (half-open):** dopo il raffreddamento, si lascia passare **una** chiamata di prova. Se va, il circuito si richiude; se fallisce, si riapre.

```python
import time

class CircuitBreaker:
    def __init__(self, soglia_errori=5, finestra_s=60, raffreddamento_s=120):
        self.soglia = soglia_errori
        self.finestra = finestra_s
        self.raffreddamento = raffreddamento_s
        self.errori = []          # timestamp degli errori recenti
        self.aperto_fino = 0

    def chiama(self, tool_fn, *args):
        ora = time.time()
        # circuito APERTO: fallisci subito, non sprecare
        if ora < self.aperto_fino:
            raise CircuitoAperto(f"tool non disponibile, riprova più tardi")
        try:
            r = tool_fn(*args)
            self.errori.clear()          # successo: resetta
            return r
        except Exception:
            self.errori = [t for t in self.errori if ora - t < self.finestra]
            self.errori.append(ora)
            if len(self.errori) >= self.soglia:
                self.aperto_fino = ora + self.raffreddamento   # APRI
                alert(f"circuit breaker APERTO su {tool_fn.__name__}")
            raise
```

Il valore per il loop: quando un tool è giù, il circuit breaker **trasforma un errore lento e ripetuto in un errore veloce e dichiarato.** L'agente riceve subito "non disponibile", la sua logica di gestione errori può prendere una strada diversa (o arrendersi), e soprattutto **non stai facendo mille chiamate a un servizio morto.** È il **circuit breaker per l'AI** preso pari pari dall'SRE classico, perché il problema è lo stesso: non insistere contro un componente rotto.

## Dedup: non richiamare lo stesso GET 40 volte

Un pattern di loop specifico e frequente: l'agente chiama **lo stesso tool con gli stessi identici argomenti**, ripetutamente. Un `GET` sullo stesso record, la stessa query, la stessa lettura — quaranta volte in un run. Non perché il risultato cambi (è idempotente, torna sempre uguale), ma perché il modello è bloccato e ripropone la stessa mossa.

La contromisura è la **deduplicazione a livello di run**: se una chiamata identica (stesso tool, stessi argomenti) è già stata fatta in questo run, non la ri-esegui — restituisci il risultato in cache, e **conti la ripetizione come segnale di loop**.

```python
class DedupRun:
    def __init__(self, max_ripetizioni=3):
        self.cache = {}          # chiave -> risultato
        self.conteggi = {}       # chiave -> quante volte richiesta
        self.max_rip = max_ripetizioni

    def chiave(self, tool: str, args: dict) -> str:
        import json, hashlib
        raw = tool + json.dumps(args, sort_keys=True)
        return hashlib.sha256(raw.encode()).hexdigest()[:16]

    def chiama(self, tool_name, args, esegui_fn):
        k = self.chiave(tool_name, args)
        self.conteggi[k] = self.conteggi.get(k, 0) + 1
        if self.conteggi[k] > self.max_rip:
            # stessa identica chiamata troppe volte = loop
            raise LoopRilevato(
                f"{tool_name} chiamato {self.conteggi[k]}x con stessi args")
        if k in self.cache:
            return self.cache[k]           # servi dalla cache, non ri-eseguire
        r = esegui_fn(tool_name, args)
        self.cache[k] = r
        return r
```

Due benefici in uno: **risparmi** (non ripeti chiamate identiche, specie quelle a pagamento o pesanti) e **rilevi il loop** (la stessa chiamata oltre soglia è un segnale inequivocabile). Attenzione al confine: la dedup vale per le chiamate **idempotenti** (letture, GET). Sui tool con side effect (scritture, pagamenti) la dedup basata su idempotency key è ancora più importante — ma lì il tema è "non eseguire due volte l'azione", che è la difesa contro il doppio pagamento vista altrove. Per il loop, la dedup delle letture identiche è il colpo secco che spezza il ciclo più comune.

## Il watchdog esterno al grafo (non fidarti del loop per fermarsi)

Ora il principio più importante, quello che quasi tutte le implementazioni sbagliano: **non puoi affidare all'agente il compito di fermarsi da solo.** Il max iterations, il circuit breaker, la dedup vivono *dentro* la logica dell'agente/grafo. Ma se è proprio quella logica ad essere rotta — un bug nel ciclo, un'eccezione ingoiata, un contatore che non si incrementa — il meccanismo interno può non scattare. Chi sta andando in loop non è il guardiano affidabile di sé stesso.

Serve un **watchdog esterno**: un processo (o thread, o servizio) **separato** dal ciclo dell'agente, che sorveglia ogni run dall'esterno e lo uccide se supera limiti oggettivi, indipendentemente da cosa "pensa" l'agente:

- **Timeout di wall-clock:** un run non può durare più di X minuti. Punto. Non importa a che step è.
- **Budget di step:** ridondante col contatore interno, ma controllato *da fuori*, così regge anche se quello interno fallisce.
- **Budget di costo/chiamate:** se il run ha già speso più di X (token/euro) o fatto più di N chiamate, si uccide.

```python
# Watchdog: gira SEPARATO dall'agente. Uccide i run fuori limite.
def watchdog(store, max_durata_s=300, max_chiamate=40, max_eur=2.0):
    for run in store.run_attivi():
        motivo = None
        if run.durata_s() > max_durata_s:      motivo = "timeout wall-clock"
        elif run.n_chiamate > max_chiamate:    motivo = "troppe chiamate"
        elif run.costo_eur > max_eur:          motivo = "budget costo"
        if motivo:
            store.uccidi_run(run.id, motivo)   # kill dall'ESTERNO
            alert(f"WATCHDOG: run {run.id} ucciso - {motivo}")
```

Il watchdog è la cintura *sopra* le bretelle. I meccanismi interni fermano i loop "normali"; il watchdog ferma anche i casi in cui i meccanismi interni non hanno funzionato. È l'applicazione all'agente della lezione del kill switch: **il controllo deve stare fuori dalla cosa che potrebbe essere rotta.**

E qui il "**senza spegnere tutto**" del titolo. Il watchdog uccide **il singolo run** impazzito, non l'intera piattaforma. Il circuit breaker apre **il singolo tool** che è giù, non tutti. La granularità è il punto: un incident di loop non deve costringerti a fermare gli agenti di tutti. Fermi il colpevole (quel run, quel tool), lasci lavorare il resto. Lo "spegni tutto" è il gesto della disperazione di chi non ha controlli granulari.

## L'architettura di riferimento

Ecco come dispongo le difese, a strati, dal ciclo interno al guardiano esterno.

```
   ┌──────────────────────────────────────────────────────────┐
   │ CICLO AGENTE (ReAct: think → act → observe)              │
   │  • contatore step / max_iterations (basso: 8–12)         │
   │  • dedup chiamate idempotenti (stesso tool+args)         │
   │                                                          │
   │   ogni tool call passa da ▼                              │
   │  ┌────────────────────────────────────────────────────┐ │
   │  │ CIRCUIT BREAKER per tool (error budget)             │ │
   │  │  closed → open → half-open                          │ │
   │  └────────────────────────────────────────────────────┘ │
   └───────────────────────────┬──────────────────────────────┘
                                │ tracce (chiamate, step, costo)
                                ▼
   ┌──────────────────────────────────────────────────────────┐
   │ OSSERVABILITÀ: metriche + allarme su N tool/min           │
   └───────────────────────────┬──────────────────────────────┘
                                ▼
   ┌──────────────────────────────────────────────────────────┐
   │ WATCHDOG ESTERNO (processo separato)                      │
   │  timeout wall-clock · budget step · budget costo/chiamate │
   │  → uccide il SINGOLO run, non tutta la piattaforma        │
   └──────────────────────────────────────────────────────────┘
```

**Cosa NON fa il sistema (i confini):**

- Non si fida del ciclo dell'agente per fermarsi: il watchdog è **esterno**.
- Non martella un tool giù: il circuit breaker lo isola.
- Non "spegne tutto" a ogni loop: uccide il run e il tool colpevoli, con granularità.
- Non nasconde il loop: ogni intervento (max step, breaker aperto, kill) è loggato e allarmato.

Le tracce che alimentano osservabilità e watchdog sono le stesse dell'[osservabilità degli LLM in produzione]({{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}): step per run, chiamate al minuto, costo per run. Il loop è, prima di tutto, una cosa che *vedi* nelle metriche; poi una cosa che *fermi* coi controlli.

## L'allarme su N tool/minuto

Il watchdog uccide i run fuori limite, ma vuoi anche essere **avvisato** quando un loop sta partendo, per capirne la causa. L'allarme più efficace è sul **tasso di chiamate ai tool per minuto**, per run e aggregato.

Un run sano fa poche chiamate al minuto. Un run in loop ne fa tante, tutte simili. La soglia la tari sulla norma dei tuoi agenti:

```python
# Allarme sul tasso di tool call per run (loop in corso)
def controlla_tasso(store, max_tool_per_min=15):
    for run in store.run_attivi():
        tool_ultimo_min = store.conta_tool(run.id, finestra_s=60)
        if tool_ultimo_min > max_tool_per_min:
            alert(f"LOOP? run {run.id}: {tool_ultimo_min} tool/min "
                  f"(tool più frequente: {store.tool_top(run.id)})")
```

Nota che l'allarme include il **tool più frequente**: ti dice subito *dove* gira il loop (quale tool, quale causa probabile). Un allarme che dice solo "loop" ti fa perdere tempo; uno che dice "loop su `verifica_iban`, 40 chiamate/min" ti porta dritto alla causa. La regola dell'osservabilità vale anche qui: allarma sull'aggregato (tasso), non sul singolo evento, e includi il contesto che rende l'allarme azionabile.

## Percorso di implementazione, a step

1. **Metti un tetto di step basso** (8–12) sul ciclo dell'agente, che solleva un'eccezione gestita e logga il sospetto loop.
2. **Rivedi i prompt:** togli gli "insisti / non fermarti", aggiungi esplicitamente "se non è possibile o un dato manca, fermati e segnala".
3. **Avvolgi ogni tool in un circuit breaker** con error budget, così un tool giù viene isolato invece che martellato.
4. **Aggiungi la dedup** delle chiamate idempotenti a livello di run, con soglia di ripetizione che rileva il loop.
5. **Costruisci il watchdog esterno**, in un processo separato, con timeout wall-clock, budget step e budget costo/chiamate.
6. **Configura l'allarme** sul tasso di tool/minuto, con il tool più frequente nel messaggio.
7. **Garantisci la granularità:** kill del singolo run e apertura del singolo tool, mai spegnimento globale come prima risposta.
8. **Prepara il chaos test** (sotto) e il template di postmortem.
9. **Verifica** che ogni difesa scatti davvero, con un tool che fallisce sempre.

## Chaos test: il tool che fallisce sempre

Le difese non testate sono difese immaginarie. Il test decisivo per il loop è il **chaos test**: introduci deliberatamente un tool che **fallisce sempre** (restituisce 500, o output che non passa lo schema) e verifichi che l'agente **non giri all'infinito**.

```python
def tool_che_fallisce_sempre(*args, **kwargs):
    raise RuntimeError("500: guasto simulato per chaos test")

def test_loop_non_infinito():
    # 1. il max iterations deve fermare il run
    try:
        esegui_agente(task="usa lo strumento guasto", max_step=10)
        assert False, "doveva fermarsi al tetto di step"
    except LimiteStepSuperato:
        pass

    # 2. il circuit breaker deve aprirsi dopo N errori
    cb = CircuitBreaker(soglia_errori=5)
    aperti = 0
    for _ in range(10):
        try: cb.chiama(tool_che_fallisce_sempre)
        except CircuitoAperto: aperti += 1
        except Exception: pass
    assert aperti > 0, "il circuit breaker non si è aperto"

    # 3. il watchdog deve uccidere un run che sfora il tempo
    #    (test con un run simulato lungo oltre la soglia)
    assert watchdog_uccide_run_lungo()
```

I casi da coprire nel chaos test:

- **Tool che dà 500 sempre:** max iterations ferma il run, circuit breaker si apre, watchdog uccide se necessario.
- **Tool che dà output non valido sempre:** la policy di reject non ritenta all'infinito, il run si ferma.
- **Prompt "insisti" + tool guasto:** verifica che i controlli *strutturali* vincano sul prompt (il tetto di step ferma comunque, anche se il prompt dice di insistere).
- **Watchdog contro logica interna rotta:** simula un ciclo dove il contatore interno *non* scatta e verifica che il watchdog esterno uccida comunque.

Il criterio di successo: **con un tool che fallisce sempre, nessun run gira più di N step / X minuti / Y euro.** Se questo test passa, il loop infinito non è più un rischio aperto. Se non l'hai mai eseguito, il tuo sistema *probabilmente* va in loop — non lo sai perché non l'hai provato.

## Il postmortem: il template

Ogni incident di loop, anche piccolo, merita un postmortem breve. Non per cercare colpevoli — l'agente ha fatto ciò che gli agenti fanno — ma per capire quale difesa mancava. Il template che uso:

- **Cosa è successo:** quale agente, quale run, quando è iniziato e quando è stato fermato, e da cosa (max step? watchdog? un umano?).
- **Impatto:** quante chiamate, quanto costo bruciato, quali altri job rallentati, per quanto tempo.
- **Causa radice:** schema rotto? tool 500 persistente? prompt "insisti"? obiettivo impossibile? (usa la tabella cause).
- **Cosa ha funzionato / cosa no:** il circuit breaker si è aperto? il watchdog ha ucciso in tempo? l'allarme è scattato? Se qualcosa non ha funzionato, è la priorità.
- **Azioni:** la contromisura da aggiungere/aggiustare, e il caso da mettere nel chaos test perché non si ripeta.

Il valore del postmortem è cumulativo: **ogni loop reale diventa un test permanente.** Dopo qualche incident, la tua chaos suite copre tutti i modi in cui i tuoi agenti sono davvero andati in loop, e quel modo specifico non ripassa. È così che un sistema diventa robusto: non prevedendo tutto in anticipo, ma non ripetendo mai lo stesso errore.

## Costi: ordini di grandezza

Stime dichiarate.

- **Il costo di un loop non fermato:** è il costo che tutto il resto previene. Un agente in loop per una notte su un modello a pagamento può fare migliaia di chiamate: come ordine di grandezza, da decine a **centinaia di euro** in una singola notte, a seconda del modello e della frequenza. Self-hosted, "paghi" in GPU occupata e servizio degradato per tutti.
- **Il costo delle difese:** max iterations, circuit breaker, dedup e watchdog sono codice deterministico. Sviluppo, come ordine di grandezza, **qualche giornata/uomo** su un'app agentica esistente; esecuzione a costo trascurabile (CPU, nessun token aggiuntivo). La dedup, anzi, **riduce** i costi eliminando chiamate ripetute.
- **Il watchdog:** un piccolo processo separato, consumo trascurabile. Il suo valore è tutto nel disastro che previene.
- **Il ritorno:** la prima notte di loop evitata ripaga, di solito, l'intero investimento nelle difese. È una delle poche cose in cui l'ingegneria difensiva ha un ROI immediato e misurabile: la fattura che *non* esplode.

## Quando NON farlo (o farlo diversamente)

- **Non alzare il max iterations "per sicurezza".** La sicurezza è il tetto basso. Alzarlo a 50 "così non si interrompe" è esattamente come togliere il freno perché frena troppo. Alza solo per compiti che dimostrabilmente convergono in più passi, e con un watchdog di costo a proteggere.
- **Non affidarti solo ai controlli interni al grafo.** Se l'unica difesa è dentro l'agente, il giorno che quella logica ha un bug il loop non si ferma. Il watchdog esterno non è opzionale per la produzione.
- **Non risolvere il loop rendendo il prompt più insistente.** È il contrario: un prompt che ammette il fallimento ("se non riesci, fermati e segnala") previene loop; uno che spinge a insistere li causa.
- **Non spegnere tutta la piattaforma come prima risposta.** Se l'unico modo che hai per fermare un loop è staccare tutto, ti manca la granularità (kill per run, breaker per tool). Aggiungila: spegnere tutto danneggia gli innocenti.
- **Se l'agente non fa side effect e gira in locale a costo nullo**, un loop è meno grave (nessuna fattura), ma occupa comunque risorse: tieni almeno il max iterations e il watchdog di tempo. Il "costo zero" del self-hosted non è zero se il servizio è degradato per tutti.

## Checklist di incident: quando un loop è in corso

- [ ] **Identifica il run** dal tasso di tool/minuto e dall'allarme (quale run, quale tool).
- [ ] **Uccidi il singolo run** col watchdog/kill, non l'intera piattaforma.
- [ ] **Apri il circuito** sul tool colpevole se il problema è a valle (evita che altri run ci sbattano).
- [ ] **Verifica l'impatto:** chiamate fatte, costo bruciato, altri job rallentati.
- [ ] **Identifica la causa** con la tabella (schema, 500, prompt, obiettivo impossibile).
- [ ] **Applica la contromisura** mirata (validazione, breaker, prompt, esito "non possibile").
- [ ] **Scrivi il postmortem** breve col template.
- [ ] **Aggiungi il caso al chaos test** perché non si ripeta.

## Checklist operativa prima di andare live

- [ ] **Tetto di step basso** (8–12) sul ciclo, con eccezione gestita e log del sospetto loop.
- [ ] **Prompt che ammettono il fallimento**, nessun "insisti / non fermarti".
- [ ] **Circuit breaker per tool** con error budget (closed/open/half-open).
- [ ] **Dedup** delle chiamate idempotenti con soglia di rilevamento loop.
- [ ] **Watchdog esterno** al grafo: timeout wall-clock, budget step, budget costo/chiamate.
- [ ] **Granularità:** kill del singolo run, apertura del singolo tool — mai "spegni tutto" come default.
- [ ] **Allarme sul tasso di tool/minuto**, con il tool più frequente nel messaggio.
- [ ] **Chaos test** con un tool che fallisce sempre, eseguito a ogni deploy.
- [ ] **Template di postmortem** pronto e usato a ogni incident.
- [ ] **Osservabilità** (step, chiamate, costo per run) attiva: senza, il loop lo scopri dalla fattura.

## Il verdetto

Il **tool calling loop infinito** è l'incident più prevenibile che ci sia, eppure colpisce chi non l'ha previsto perché ha un difetto insidioso: non fallisce con un crash, fallisce *continuando*. E ciò che continua, di notte, senza controlli, presenta il conto lunedì mattina. La buona notizia è che le difese sono note, deterministiche, ed economiche rispetto al danno che prevengono.

La ricetta è a strati e ha un ordine. Un tetto di step basso, perché un agente sano converge in pochi passi e 25 è già il segno che sta girando a vuoto. Prompt che ammettono il fallimento, invece di spingere a insistere. Un circuit breaker per ogni tool, per isolare ciò che è giù invece di martellarlo. La deduplicazione delle chiamate identiche, che spezza il loop più comune e risparmia. E sopra tutto, il **watchdog esterno al grafo**, perché la regola d'oro è che non puoi affidare alla cosa che sta andando in loop il compito di fermarsi da sola: il freno sta fuori.

E la parola chiave del titolo — *senza spegnere tutto* — è il segno della maturità: un incident di loop si spezza con granularità, uccidendo il run e il tool colpevoli, non staccando la piattaforma per tutti. Chi può solo "spegnere tutto" non ha controlli, ha un interruttore generale. Aggiungi i controlli, testali con un tool che fallisce sempre, e scrivi il postmortem quando succede: così ogni loop reale diventa un test che impedisce al prossimo di ripetersi.

Fatto così, un agente che incontra un errore si ferma, isola, segnala — e tu la mattina trovi un allarme gestito, non una fattura a tre zeri. Fatto senza, hai un processo instancabile che brucia risorse a vuoto mentre dormi. La differenza non è l'intelligenza del modello. È se hai messo i freni, dentro e soprattutto fuori.

Se hai agenti in produzione e non sai dirmi cosa succede quando un tool va giù o uno schema si rompe alle tre di notte, è il momento di mettere questi freni. Puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Incident engineering, non slide.

## FAQ

### Cos'è di preciso un "runaway agent"?
È un agente che entra in un ciclo di chiamate ai tool senza convergere verso un risultato: chiama uno strumento, riceve un errore o un risultato che non lo soddisfa, riprova, e così via, spesso all'infinito. Consuma token, CPU ed euro finché qualcosa non lo ferma. Non è un crash — è il contrario, un processo che non si ferma — ed è per questo che è insidioso e costoso.

### Perché dici che max iterations a 25 è già tanto?
Perché un agente sano, su un compito ben definito, converge in pochi passi — tipicamente da 2 a 8. Se arriva a 25, quasi sempre non sta lavorando: sta girando a vuoto. Il default alto di alcuni runtime serve a non interrompere casi complessi legittimi, ma per la maggior parte degli agenti di una PMI un tetto di 8–12 cattura il loop molto prima che diventi costoso. Alza solo per compiti che dimostrabilmente ne hanno bisogno.

### Come funziona il circuit breaker per un tool?
Come nell'SRE classico: ogni tool ha un budget di errori. Se fallisce troppe volte in una finestra, il circuito si "apre" e per un periodo le chiamate a quel tool falliscono subito, senza nemmeno provare. Dopo un raffreddamento, una chiamata di prova decide se richiudere. Serve a non martellare un servizio già a terra e a dare all'agente un "non disponibile" immediato invece di timeout ripetuti.

### Perché il watchdog deve essere esterno all'agente?
Perché non puoi affidare alla cosa che sta andando in loop il compito di fermarsi da sola. Se la logica interna dell'agente ha un bug — un contatore che non scatta, un'eccezione ingoiata — i controlli interni possono non attivarsi. Un watchdog in un processo separato sorveglia ogni run dall'esterno e lo uccide se supera tempo, step o costo, indipendentemente da cosa fa l'agente. È il controllo che regge anche quando il resto è rotto.

### Cosa significa "spezzare il loop senza spegnere tutto"?
Significa avere la granularità per fermare solo il colpevole: uccidere il singolo run impazzito e aprire il circuito sul singolo tool guasto, lasciando lavorare tutti gli altri agenti e job. Chi non ha questi controlli granulari ha come unica opzione "staccare tutto", che ferma il loop ma danneggia anche gli innocenti. La granularità è il segno di un sistema maturo.

### Il prompt può causare il loop?
Sì, ed è una delle cause più comuni e autoinflitte. Un prompt che dice "non fermarti finché non riesci", "insisti", "riprova in ogni modo" spinge esplicitamente il modello a non arrendersi, anche quando arrendersi o chiedere aiuto a un umano sarebbe corretto. La cura è un prompt che ammette il fallimento: "se non è possibile o un dato manca, fermati e segnala". Ma il prompt non basta: servono comunque i controlli strutturali.

### Come riconosco un loop dai log prima che costi troppo?
Dal tasso di chiamate ai tool per minuto e dagli step per run: un run sano fa poche chiamate e converge in pochi passi. Un allarme che scatta quando le tool call al minuto superano la norma — e che ti dice quale tool è il più frequente — ti porta al loop mentre succede, non alla fattura giorni dopo. Serve avere l'osservabilità: senza tracce e metriche, il primo segnale è il costo.

### La deduplicazione non rischia di rompere agenti legittimi?
No, se applicata alle chiamate idempotenti (letture, GET) a livello di singolo run. Un agente legittimo non ha motivo di fare la stessa identica lettura quaranta volte nello stesso run: se lo fa, è bloccato. La dedup serve dalla cache le ripetizioni identiche e conta le ripetizioni come segnale di loop. Sui tool con side effect il tema è diverso (idempotency key per non eseguire due volte), ma per il loop la dedup delle letture è efficace e sicura.

### Come testo che le mie difese contro il loop funzionino?
Con un chaos test: introduci un tool che fallisce sempre (500 o output non valido) e verifichi che nessun run giri oltre il tetto di step, che il circuit breaker si apra, e che il watchdog uccida i run fuori tempo. Copri anche il caso "prompt insisti + tool guasto" (i controlli strutturali devono vincere sul prompt) e "logica interna rotta" (il watchdog esterno deve uccidere comunque). Se questo test passa, il loop infinito non è più un rischio aperto.

### Da dove parto se ho già agenti in produzione senza queste difese?
In quest'ordine: (1) metti un tetto di step basso e un watchdog esterno di tempo/costo — questi due, da soli, fermano la fattura a tre zeri; (2) rivedi i prompt togliendo gli "insisti"; (3) avvolgi i tool nel circuit breaker; (4) aggiungi la dedup; (5) configura l'allarme sul tasso di tool/minuto; (6) scrivi il chaos test. I primi due si fanno in fretta e coprono il rischio economico immediato del loop notturno.
