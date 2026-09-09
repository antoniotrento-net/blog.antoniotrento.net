---
lang: it
permalink: /it/blog/osservabilita-llm-produzione/
title: "Osservabilità degli LLM in produzione: tracce, costo per run, retry e perché \"guarda la chat\" non è un monitoraggio"
date: 2026-10-04 07:30:00 +0200
author: "Antonio Trento"
description: "Osservabilità degli LLM in produzione con l'occhio dell'SRE: tracce e span, costo per run, retry idempotenti, budget per agente, redaction della PII prima dello storage e retention. Perché leggere la chat non è monitorare."
keywords: ["osservabilità llm produzione", "tracing langfuse", "costo token per agente", "retry backoff openai", "logging pii", "sre per agenti ai"]
image: /assets/images/posts/osservabilita-llm-produzione.jpg
pillar: modelli-costi-privacy
related: [/it/blog/kill-switch-agente-salesforce/, /it/blog/vllm-vs-ollama-produzione/]
---

## "Ho guardato la chat e sembrava a posto" non è monitoraggio

La scena che vedo in ogni azienda che ha messo un agente in produzione senza pensarci: qualcosa non va — l'agente risponde male, i costi salgono, un cliente si lamenta — e la reazione è "apro la conversazione e guardo". Leggi la chat, ti sembra a posto o no, chiudi. Questo non è monitoraggio. È aneddoto. Non ti dice quanto costa quell'agente al mese, quante volte è andato in loop questa settimana, qual è la sua latenza al 95° percentile, quante volte un umano ha dovuto correggerlo, e se ieri notte ha bruciato token in un ciclo infinito mentre nessuno guardava.

L'**osservabilità degli LLM in produzione** è la disciplina che trasforma "sembrava a posto" in "so esattamente cosa è successo, quanto è costato, e ho un allarme che mi avvisa prima del disastro". È SRE — Site Reliability Engineering — applicato agli agenti: tracce strutturate invece di conversazioni da rileggere, metriche aggregabili invece di impressioni, allarmi automatici invece di clienti arrabbiati come sistema di notifica.

In questo pezzo ti do lo stack completo, da ingegnere che li mette in piedi: cosa misurare davvero, la differenza tra traccia e log (parent run e span), come **non loggare la PII** nei prompt, il budget per agente con kill sullo sforamento, i retry che non ti fanno pagare due volte, le dashboard che legge anche chi non è sviluppatore, gli allarmi che contano, e la retention con il diritto all'oblio. Con lo schema della tabella `runs`, le metriche e la policy di retention copiabili. Default sovrano, come sempre: **OpenTelemetry più uno strumento self-hosted (Langfuse) o un Postgres casalingo**, non un SaaS che si tiene i tuoi prompt.

## Cosa misurare: latenza, token, errori dei tool, override umani

Prima degli strumenti, le grandezze. Se non sai cosa misurare, nessun tool ti salva. Per un agente in produzione, le metriche che contano sono queste — e nota che nessuna si legge "guardando la chat":

- **Latenza (per percentile).** Non la media — la media mente. I percentili: p50 (l'esperienza tipica), p95 e p99 (i casi lenti che l'utente sente). Un agente con p50 di 2 secondi ma p99 di 40 secondi ha un problema che la media (che magari dice 5 secondi) nasconde.
- **Token in / token out, per run.** Sono il **costo**. Ogni chiamata al modello consuma token in ingresso (prompt + contesto + storia) e in uscita (risposta). Tracciarli per run è l'unico modo per sapere quanto costa davvero un processo.
- **Errori dei tool.** Un agente che esegue azioni chiama strumenti (query, API, scritture). Il tasso di errore dei tool — quante volte una tool call fallisce — è un indicatore di salute primario. Se sale, qualcosa a valle si è rotto.
- **Override umani.** Quante volte un umano ha corretto, rifiutato o rifatto ciò che l'agente ha proposto. È la metrica di *qualità* più onesta che hai: se gli override crescono, l'agente sta peggiorando (o il mondo è cambiato sotto di lui). Un agente di cui nessuno corregge mai nulla, o ci si fida ciecamente, o è ottimo: gli override ti dicono quale.
- **Retry e step per run.** Quante volte una chiamata è stata ritentata, e quanti passi ha fatto l'agente in un run. Un numero di step che esplode è il sintomo di un loop.

Queste sono le grandezze. Il resto dell'articolo è come catturarle senza loggare dati che non dovresti, come aggregarle in qualcosa di leggibile, e come farci scattare allarmi.

## Traccia vs log: parent run, span del tool, span del modello

Qui sta l'errore concettuale più comune. Un **log** è un evento piatto: "alle 10:03 l'agente ha chiamato il modello". Utile, ma per un agente che fa cinque passi — pensa, chiama un tool, pensa ancora, chiama un altro tool, risponde — una sequenza di log piatti è illeggibile. Non capisci *quale* passo è stato lento, *quale* tool è fallito, *quanto* è costato il singolo passo.

Serve una **traccia**: una struttura ad albero che rispecchia il flusso dell'agente.

- Il **parent run** è il run completo: una richiesta dell'utente, dall'inizio alla fine. Ha un `run_id`, l'agente, il processo/cliente a cui appartiene, il costo totale, lo stato finale.
- Sotto il parent, gli **span**: ogni chiamata al modello è uno span (modello, token in/out, latenza, costo), ogni chiamata a un tool è uno span (nome tool, argomenti, risultato, errore). Gli span hanno un parent, così ricostruisci l'albero.

Con la traccia, quando qualcosa va storto apri *un run* e vedi l'intero albero: questo passo è costato 3.000 token, questo tool ha fallito, questo span ha preso 20 secondi. È la differenza tra "so cosa è successo" e "leggo la chat e indovino".

Lo standard per farlo è **OpenTelemetry** (span, attributi, propagazione del contesto): aperto, non proprietario, e supportato ovunque. Sopra, uno strumento specifico per LLM come **Langfuse** — che è **self-hostable** e open source, quindi coerente con uno stack sovrano — aggiunge la vista LLM (prompt, token, costi, valutazioni). In alternativa, per iniziare, una coppia di tabelle Postgres fatte in casa basta e avanza. Il **tracing con Langfuse** self-hosted è la mia scelta quando il progetto cresce; il Postgres casalingo quando voglio zero dipendenze.

L'istrumentazione, con span annidati e — nota da subito — la **redaction prima di salvare**:

```python
import time, uuid
from contextlib import contextmanager

@contextmanager
def run_span(store, agent: str, process: str):
    run_id = str(uuid.uuid4())
    t0 = time.time()
    ctx = {"run_id": run_id, "agent": agent, "process": process,
           "cost_eur": 0.0, "tokens_in": 0, "tokens_out": 0,
           "steps": 0, "retries": 0, "status": "ok"}
    try:
        yield ctx
    except Exception:
        ctx["status"] = "error"
        raise
    finally:
        ctx["latency_ms"] = int((time.time() - t0) * 1000)
        store.save_run(ctx)             # solo dati aggregati + redatti

@contextmanager
def tool_span(store, ctx: dict, tool: str, args: dict):
    t0 = time.time()
    ctx["steps"] += 1
    span = {"span_id": str(uuid.uuid4()), "run_id": ctx["run_id"],
            "type": "tool", "name": tool,
            "args_redacted": redact(args),   # MAI args grezzi con PII
            "status": "ok"}
    try:
        yield span
    except Exception as e:
        span["status"] = "error"; span["error"] = str(e)[:200]
        raise
    finally:
        span["latency_ms"] = int((time.time() - t0) * 1000)
        store.save_span(span)
```

Il pattern è quello dell'SRE: **strumenti il codice una volta, e ogni run produce una traccia strutturata**, non un muro di testo da rileggere.

## La PII nei prompt: redaction prima dello storage

Questa sezione ti evita un problema GDPR serio, ed è quella che quasi tutti saltano. I prompt e le risposte di un agente aziendale sono pieni di **dati personali**: nomi, email, telefoni, IBAN, codici fiscali, contenuti di documenti. Se salvi le tracce con i prompt grezzi, stai creando un archivio di dati personali — spesso più sensibile del sistema che stai monitorando — e ti stai prendendo tutti gli obblighi che ne derivano.

La regola: **la PII si redige *prima* dello storage, non dopo.** Non salvi il prompt grezzo "poi lo pulisco": lo pulisci nel percorso, prima che tocchi il disco. Ciò che non è mai stato scritto non va cancellato, non va protetto, non può trapelare.

Cosa redigere, come minimo, per l'italiano:

- **Email, telefoni, IBAN, codici fiscali, partite IVA** (pattern riconoscibili).
- **Nomi propri** dove possibile (più difficile, ma almeno nei campi noti).
- **Contenuti di documenti** allegati al contesto: non li salvi interi nella traccia, salvi un riferimento.

Una redaction di base, deterministica, da mettere nel percorso di storage:

```python
import re

PATTERNS = {
    "EMAIL": re.compile(r"[\w.\-]+@[\w.\-]+\.\w+"),
    "IBAN":  re.compile(r"\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b"),
    "CF":    re.compile(r"\b[A-Z]{6}\d{2}[A-Z]\d{2}[A-Z]\d{3}[A-Z]\b", re.I),
    "TEL":   re.compile(r"\b(?:\+39\s?)?3\d{2}\s?\d{6,7}\b"),
    "PIVA":  re.compile(r"\b\d{11}\b"),
}

def redact(obj):
    """Redige la PII PRIMA di salvare. Ciò che non salvi non devi proteggerlo."""
    if isinstance(obj, dict):
        return {k: redact(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [redact(v) for v in obj]
    if isinstance(obj, str):
        s = obj
        for tag, pat in PATTERNS.items():
            s = pat.sub(f"[{tag}]", s)
        return s[:2000]        # tronca: non serve l'intero documento nel log
    return obj
```

Onestà: la redaction con regex non è perfetta (i nomi propri sfuggono, i pattern hanno falsi negativi). Ma è enormemente meglio di niente, e per i dati strutturati ad alto rischio (IBAN, CF, email) è molto efficace. La strategia migliore, dove puoi, è **non far entrare la PII nella traccia in primo luogo**: logga il *riferimento* al dato (l'ID del documento, l'ID del cliente), non il dato. Il **logging della PII** è un problema che si risolve al 90% decidendo di non loggarla.

Questo si lega direttamente alla difesa contro l'esfiltrazione e alla disciplina dei dati che ho descritto altrove: meno dati sensibili tocchi e conservi, meno superficie di rischio hai.

## L'architettura di riferimento

Ecco come dispongo il livello di osservabilità. Il confine chiave: **il layer di osservabilità non conserva mai PII grezza, e non altera il comportamento dell'agente — lo osserva.**

```
   Agente (run) ──▶ ┌────────────────────────────────────┐
                    │ ISTRUMENTAZIONE (OpenTelemetry)     │
                    │  parent run + span modello + span   │
                    │  tool                               │
                    └───────────────┬────────────────────┘
                                    ▼
                    ┌────────────────────────────────────┐
                    │ REDACTION (prima dello storage)     │
                    │  PII → [EMAIL]/[IBAN]/[CF]...        │
                    └───────────────┬────────────────────┘
                                    ▼
                    ┌────────────────────────────────────┐
                    │ STORE self-hosted:                  │
                    │  Langfuse | Postgres (runs+spans)   │
                    └──────┬──────────────────┬───────────┘
                           ▼                  ▼
              ┌────────────────────┐  ┌────────────────────────┐
              │ AGGREGAZIONE →      │  │ ENFORCEMENT:            │
              │ dashboard + metriche│  │ budget/kill, allarmi    │
              └────────────────────┘  └────────────────────────┘

   Confini: niente PII grezza salvata · l'osservabilità NON modifica
   l'agente · il budget-killer è deterministico, fuori dal modello
```

**Cosa NON fa il layer di osservabilità (i confini):**

- Non salva PII grezza: tutto passa dalla redaction.
- Non altera la logica dell'agente: osserva, non decide (tranne l'enforcement del budget, che è un controllo deterministico separato).
- Non manda le tracce a un servizio esterno non controllato: store self-hosted, dati in UE.

Nota che l'**enforcement** (budget/kill, allarmi) è un componente a parte che *usa* i dati di osservabilità ma è deterministico — la stessa filosofia del kill switch che ho descritto per {{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }}: il controllo sta nel codice, non nel modello.

## Lo schema della tabella runs

Se parti dal Postgres casalingo (ottima scelta per iniziare senza dipendenze), queste due tabelle bastano. La prima, `runs`, è il cuore:

```sql
CREATE TABLE runs (
    run_id       uuid PRIMARY KEY,
    agent        text        NOT NULL,      -- quale agente
    process      text        NOT NULL,      -- cliente/processo (per attribuire i costi)
    started_at   timestamptz NOT NULL,
    ended_at     timestamptz,
    status       text        NOT NULL,      -- ok | error | killed
    model        text,
    tokens_in    int         DEFAULT 0,
    tokens_out   int         DEFAULT 0,
    cost_eur     numeric(10,4) DEFAULT 0,
    steps        int         DEFAULT 0,      -- passi dell'agente (loop guard)
    retries      int         DEFAULT 0,
    human_override boolean    DEFAULT false, -- un umano ha corretto?
    latency_ms   int,
    error        text                        -- redatto, troncato
);
CREATE INDEX ON runs (agent, started_at);
CREATE INDEX ON runs (process, started_at);

CREATE TABLE spans (
    span_id      uuid PRIMARY KEY,
    run_id       uuid REFERENCES runs(run_id) ON DELETE CASCADE,
    parent_id    uuid,
    type         text        NOT NULL,       -- model | tool
    name         text        NOT NULL,       -- nome modello o tool
    tokens_in    int,
    tokens_out   int,
    cost_eur     numeric(10,4),
    latency_ms   int,
    status       text,
    payload_redacted jsonb                   -- MAI grezzo: redatto
);
CREATE INDEX ON spans (run_id);
```

Con queste due tabelle rispondi già a quasi tutte le domande che contano: quanto costa un agente al mese (`SUM(cost_eur) GROUP BY agent`), qual è la latenza p95 (`percentile_cont`), quanti run sono finiti in `error` o `killed`, quante volte c'è stato un override. Il `ON DELETE CASCADE` sui span è pensato per il diritto all'oblio: cancelli il run, spariscono i suoi span.

## Esempio di metriche: le query che rispondono alle domande vere

Le metriche non sono astratte: sono le query che rispondono alle domande che ti fai. Ecco quelle che uso ogni settimana.

```sql
-- Costo per agente, questa settimana (attribuzione dei costi)
SELECT agent, COUNT(*) AS run, ROUND(SUM(cost_eur),2) AS costo_eur,
       ROUND(AVG(tokens_in+tokens_out)) AS token_medi
FROM runs
WHERE started_at >= now() - interval '7 days'
GROUP BY agent ORDER BY costo_eur DESC;

-- Latenza per percentile (p50/p95/p99), non la media bugiarda
SELECT agent,
       percentile_cont(0.50) WITHIN GROUP (ORDER BY latency_ms) AS p50,
       percentile_cont(0.95) WITHIN GROUP (ORDER BY latency_ms) AS p95,
       percentile_cont(0.99) WITHIN GROUP (ORDER BY latency_ms) AS p99
FROM runs WHERE started_at >= now() - interval '7 days'
GROUP BY agent;

-- Salute: tasso di errore, kill, override, retry medi
SELECT agent,
       ROUND(100.0*AVG((status='error')::int),1) AS pct_errore,
       ROUND(100.0*AVG((status='killed')::int),1) AS pct_killed,
       ROUND(100.0*AVG(human_override::int),1)    AS pct_override,
       ROUND(AVG(retries),2)                      AS retry_medi
FROM runs WHERE started_at >= now() - interval '7 days'
GROUP BY agent;
```

La metrica che sottolineo, perché è la più trascurata, è il **costo dei token per agente**. Senza `process` nel record, sai solo "l'AI ci costa X al mese" — inutile. Con l'attribuzione per agente e processo, sai *quale* agente e *quale* cliente/flusso consuma, e puoi intervenire dove serve. È la differenza tra una bolletta indistinta e un centro di costo governabile. Sul costo del modello sottostante e sulle scelte self-hosted vale quanto ho scritto confrontando {{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }}: l'osservabilità è ciò che ti dice se quelle scelte stanno pagando.

## Budget per agente e kill sullo sforamento

Tracciare il costo è metà dell'opera. L'altra metà è **agire** quando sfora. Un agente in loop, o con un prompt che è cresciuto a dismisura, può bruciare token — e quindi euro — a velocità impressionante mentre nessuno guarda. Il budget per agente con kill automatico è la rete di sicurezza.

Il meccanismo, deterministico (non chiede permesso al modello):

- Ogni agente/processo ha un **budget** (giornaliero o per-run): un tetto di token o di euro.
- Un **enforcer** controlla la spesa accumulata prima di ogni chiamata costosa. Se il budget è sforato, **ferma il run** (`status = killed`) e allerta.
- Un **guard sui passi**: se un run supera N step, è quasi certamente in loop → kill. Un agente sano fa pochi passi; uno che ne fa cinquanta sta girando a vuoto.

```python
class BudgetExceeded(Exception): ...

def check_budget(store, agent: str, ctx: dict,
                 max_eur_giorno: float, max_step: int):
    # 1. loop guard: troppi step = quasi certo loop
    if ctx["steps"] > max_step:
        ctx["status"] = "killed"
        raise BudgetExceeded(f"{agent}: superati {max_step} step (loop?)")
    # 2. budget giornaliero
    speso_oggi = store.costo_giornaliero(agent)   # SUM(cost_eur) oggi
    if speso_oggi + ctx["cost_eur"] > max_eur_giorno:
        ctx["status"] = "killed"
        alert(f"BUDGET: {agent} ha sforato {max_eur_giorno} €/giorno")
        raise BudgetExceeded(f"{agent}: budget giornaliero sforato")
```

Il valore di questo controllo non è tanto il risparmio nell'uso normale, quanto la protezione contro il caso patologico: il loop notturno, il prompt runaway, il bug che moltiplica le chiamate. Senza budget-killer, li scopri dalla bolletta a fine mese. Con, li fermi in tempo reale e ricevi un allarme. **È l'assicurazione contro il costo che esplode senza che nessuno se ne accorga.**

## Retry: idempotenza contro il doppio pagamento

I retry sono necessari — le API dei modelli danno 429 (rate limit) e 5xx transitori, e ritentare con **backoff** esponenziale è la prassi corretta. Ma c'è una trappola che trasforma una buona pratica in un disastro: **ritentare un'azione con side effect senza idempotenza.**

Il caso da manuale: l'agente chiama un tool che esegue un pagamento. Il tool va a buon fine, ma la risposta si perde per un timeout di rete. Il tuo codice di retry, vedendo "nessuna risposta", ritenta. Secondo pagamento. Il **retry con backoff** ha appena pagato due volte.

La distinzione da incidere nel codice:

- **Chiamate al modello e tool di sola lettura:** ritentabili liberamente con backoff. Un `429` o un `5xx` → aspetta e riprova. Nessun danno a ripetere una lettura.
- **Tool con side effect** (pagamento, scrittura, invio): ritentabili **solo con chiave di idempotenza.** Ogni azione ha un `idempotency_key`; il servizio a valle (o un tuo registro) riconosce la chiave e non esegue due volte. Senza chiave, un side effect **non si ritenta mai** in automatico: si segnala e si lascia decidere a un umano.

```python
import time, random

def retry_lettura(fn, tentativi=4, base=0.5):
    """Backoff esponenziale SOLO per chiamate senza side effect."""
    for i in range(tentativi):
        try:
            return fn()
        except RateLimitOrTransient as e:
            if i == tentativi - 1:
                raise
            attesa = base * (2 ** i) + random.uniform(0, 0.3)  # jitter
            time.sleep(attesa)

def esegui_side_effect(tool, args, idempotency_key):
    # NIENTE retry cieco: la chiave garantisce esecuzione singola.
    if store.gia_eseguito(idempotency_key):
        return store.risultato(idempotency_key)   # non ri-eseguire
    res = tool(**args, idempotency_key=idempotency_key)
    store.registra(idempotency_key, res)
    return res
```

La regola SRE: **il backoff è per i fallimenti transitori delle letture; l'idempotenza è per i side effect.** Confonderli è come mettere il retry automatico su un bonifico: la prima volta che la rete fa i capricci, paghi due volte. Ne ho parlato anche a proposito del controllo delle scritture su CRM: i retry e i side effect vanno progettati insieme, mai separati.

## Dashboard minime che un non-dev legge

Le query SQL servono a te. Ma chi convive con l'agente — il titolare, il responsabile operativo — deve poter capire lo stato senza leggere SQL né tracce. La dashboard minima efficace risponde a poche domande, con semafori, non con grafici astrusi:

- **Quanto ci costa questa settimana**, per agente, con il confronto sulla scorsa. Un numero e una freccia su/giù.
- **Va tutto bene?** Un semaforo per agente: verde (errori e override sotto soglia), giallo (in aumento), rosso (qualcosa è rotto).
- **Quanti interventi umani** sono serviti: se gli override crescono, l'agente sta peggiorando.
- **Ci sono stati kill o allarmi?** Un elenco degli eventi anomali della settimana, in italiano leggibile ("Agente fatture: fermato per loop martedì notte").

Il principio: **la dashboard traduce le metriche in fiducia.** Un responsabile che vede "questa settimana l'agente è costato 40 €, verde su tutto, zero interventi" si fida e lascia lavorare. Uno che non ha visibilità o si fida ciecamente (male) o diffida e aggira lo strumento (peggio). La trasparenza operativa non è un lusso: è ciò che rende un agente adottabile in azienda. Le dashboard di Langfuse self-hosted danno molto di questo pronto; con il Postgres casalingo, poche query dietro una paginetta bastano per iniziare.

## Allarmi: loop, 429, schema JSON rotto

Le dashboard le guardi quando le guardi. Gli allarmi ti trovano loro, ed è quello che serve quando qualcosa si rompe alle tre di notte. Gli allarmi che contano per un agente:

- **Loop / step che esplodono.** Un run che supera il guard sugli step, o un agente che fa molti più run del solito in poco tempo. È il segnale di un ciclo che brucia token. Allarme immediato + kill.
- **Picco di 429 (rate limit).** Se l'API del modello inizia a restituire tanti `429`, l'agente rallenta o fallisce, e i retry si accumulano. Un picco di 429 nei log significa "stai sbattendo contro il rate limit": va gestito (backoff, code, o capacità self-hosted).
- **Schema JSON rotto.** Se usi output strutturato (l'agente deve restituire JSON valido per uno schema) e le validazioni iniziano a fallire, il modello sta producendo output malformato — spesso dopo un cambio di modello o di prompt. Un tasso di "schema non valido" in crescita è un allarme di regressione. (È un tema a sé, così importante da meritare un pezzo dedicato sul come vincolare l'output.)
- **Costo sopra soglia.** Il budget-killer ferma il run; l'allarme avvisa te. Se un agente sfora ripetutamente, non è un incidente: è un problema di configurazione o un bug da indagare.
- **Tasso di errore dei tool in salita.** Se un tool inizia a fallire spesso, qualcosa a valle (un'API, il DB) si è rotto. L'agente è spesso il primo a "sentirlo".

La regola: **gli allarmi si basano su metriche aggregate, non su singoli eventi.** Non vuoi un allarme per ogni 429 (ne arrivano di normali); vuoi un allarme quando il *tasso* di 429 supera la norma. La differenza tra un sistema di allarme utile e uno che ignori (perché grida troppo) è tutta qui.

## Retention e diritto all'oblio sui log

Le tracce di osservabilità, anche redatte, sono spesso **dati personali** (contengono ID di clienti, riferimenti a persone, a volte PII sfuggita alla redaction). Quindi cadono sotto il GDPR, e servono retention e cancellabilità. È la parte che chi costruisce l'osservabilità dimentica, creando un archivio-ombra di dati che nessuno governa.

La **policy di retention** che applico:

| Dato | Retention | Motivazione |
|------|-----------|-------------|
| Payload redatti negli span | Breve (es. 30–90 gg) | Utili per il debug recente, non a vita |
| Metriche aggregate (costo, latenza, errori) | Lunga (es. 12–24 mesi) | Servono per trend, non contengono PII |
| Run con `error`/`killed` | Media, poi archiviati | Utili per post-mortem, poi si aggregano |
| Riferimenti a persone/clienti | Legati alla finalità | Cancellabili su richiesta |

I principi operativi:

- **Separa metriche e payload.** Le metriche aggregate (quanti token, quanta latenza) non contengono PII e si conservano a lungo per i trend. I payload (anche redatti) si conservano poco: servono per il debug immediato, non per sempre.
- **Cancellazione automatica per età.** Un job periodico elimina i payload oltre la retention. Ciò che non serve più non deve restare.
- **Diritto all'oblio.** Devi poter cancellare tutto ciò che riguarda una persona/cliente su richiesta. Ecco perché il `process` e gli ID nel record sono importanti: ti permettono di trovare ed eliminare in modo mirato (il `ON DELETE CASCADE` fa il resto).
- **Accesso ristretto.** Le tracce sono dati operativi sensibili: non tutta l'azienda ci accede.

Il vantaggio del self-hosting (Langfuse o Postgres tuo) è che **questa policy la applichi tu, sui tuoi dischi.** Con un SaaS di osservabilità LLM, i tuoi prompt e le tue tracce stanno da un terzo, e la retention e la cancellazione dipendono dalle sue garanzie. Per dati aziendali sensibili, l'osservabilità sovrana è coerente con tutto il resto dello stack.

## Percorso di implementazione, a step

1. **Definisci le metriche** che ti servono: latenza (percentili), token/costo per run, errori tool, override, step/retry.
2. **Strumenta il codice** con span annidati (parent run → model span → tool span), usando OpenTelemetry o un wrapper tuo.
3. **Metti la redaction nel percorso di storage:** la PII si redige prima di salvare, sempre.
4. **Scegli lo store:** Postgres casalingo (tabelle `runs`/`spans`) per iniziare, Langfuse self-hosted quando cresci.
5. **Attribuisci i costi** per agente e processo: il campo `process` è ciò che rende governabile la spesa.
6. **Aggiungi il budget-killer** (budget giornaliero + guard sugli step) come controllo deterministico.
7. **Distingui i retry:** backoff per le letture, idempotenza obbligatoria per i side effect.
8. **Costruisci le dashboard minime** leggibili da un non-dev (costo, semaforo, override, eventi).
9. **Configura gli allarmi** su metriche aggregate (loop, tasso 429, schema rotto, costo, errori tool).
10. **Definisci retention e cancellazione**, con job automatici e procedura per il diritto all'oblio.

## I fallimenti tipici e come li riconosci dai log

- **Costo che sale senza spiegazione.** Se la spesa cresce ma i run no, il prompt è cresciuto (contesto/storia che si accumula): i `tokens_in` per run salgono. Logga i token in ingresso per run: un trend in salita a parità di run è il colpevole.
- **Loop notturni.** Run con `steps` altissimi, spesso a orari in cui nessuno guarda. Il guard sugli step li ferma; il grafico degli step per run li rende visibili. Senza questa metrica, li scopri dalla bolletta.
- **Latenza p99 fuori controllo, media ok.** Se guardi solo la media, non vedi i run che impiegano 40 secondi. I percentili li rivelano. Logga sempre p95/p99.
- **Doppi side effect.** Se vedi due esecuzioni dello stesso pagamento/scrittura con dati identici a distanza di secondi, è un retry senza idempotenza. Logga l'`idempotency_key`: la sua assenza o duplicazione è il sintomo.
- **Override in crescita silenziosa.** Se il tasso di override sale settimana dopo settimana, l'agente sta peggiorando o il mondo è cambiato. È un segnale di qualità che nessun errore tecnico ti dà: monitoralo.
- **Schema JSON che si rompe dopo un cambio.** Un picco di validazioni fallite subito dopo aver cambiato modello o prompt: regressione. Logga il tasso di output non valido.
- **Tracce piene di PII.** Se apri uno span e vedi un IBAN in chiaro, la redaction non ha coperto quel campo. Audita periodicamente un campione di span per PII sfuggita.

La regola di sempre, qui più che mai: **logga la metrica, non l'aneddoto.** "L'agente sembrava lento" non è azionabile; "p99 dell'agente fatture salito da 8 a 30 secondi da lunedì" lo è.

## Costi: ordini di grandezza

Stime dichiarate.

- **Osservabilità self-hosted:** Langfuse o un Postgres girano su risorse modeste. Come ordine di grandezza, un piccolo container/VPS: pochi/decine di euro al mese, o nulla se sfrutti il Postgres che hai già. Il costo di calcolo dell'istrumentazione è trascurabile.
- **Storage delle tracce:** le metriche aggregate sono minuscole. I payload redatti pesano di più ma con retention breve restano contenuti. Con la retention giusta, lo storage non è un problema di costo.
- **Costo di sviluppo:** l'istrumentazione con span, la redaction, il budget-killer e le dashboard minime sono, come ordine di grandezza, **qualche giornata/uomo** su un'app agentica esistente. Investimento una tantum.
- **Il risparmio che ripaga tutto:** l'attribuzione dei costi per agente ti fa vedere dove spendi e tagliare gli sprechi; il budget-killer previene i loop che bruciano euro. Spesso l'osservabilità **si ripaga** con il primo loop notturno evitato o il primo agente-spreca-token individuato.
- **Costo del non averla:** scoprire un loop dalla bolletta a fine mese, non sapere quale processo consuma, non accorgersi che la qualità cala. Il costo dell'ignoranza operativa è sempre più alto di quello dell'osservabilità.

## Quando NON farla (o farla leggera)

- **Se hai un solo agente semplice a bassissimo volume**, l'osservabilità completa è sovradimensionata: bastano log strutturati con costo e stato, senza tracce elaborate. Cresci la strumentazione con la complessità.
- **Se non puoi garantire la redaction della PII**, non salvare i prompt grezzi "per ora": è proprio il "per ora" che crea l'archivio-problema. Meglio loggare solo metriche e riferimenti finché la redaction non è pronta.
- **Se scegli un SaaS di osservabilità per comodità**, sappi che i tuoi prompt (spesso con PII) vanno da un terzo: per dati sensibili è incoerente con uno stack sovrano. Valuta Langfuse self-hosted o Postgres.
- **Se non agisci sui dati**, l'osservabilità è teatro: raccogliere metriche che nessuno guarda e su cui nessun allarme scatta è lavoro sprecato. Meglio poche metriche con allarmi veri che cento grafici ignorati.
- **Se non definisci la retention**, stai costruendo un debito GDPR: un archivio di tracce che cresce e che nessuno sa cancellare. La retention si decide prima, non dopo.

## Checklist operativa prima di andare live

- [ ] **Metriche definite:** latenza per percentile, token/costo per run, errori tool, override, step/retry.
- [ ] **Tracce con span annidati** (parent run, model span, tool span), non log piatti.
- [ ] **Redaction della PII prima dello storage:** nessun prompt grezzo salvato.
- [ ] **Attribuzione dei costi** per agente e processo (campo `process`).
- [ ] **Budget-killer** attivo: budget giornaliero + guard sugli step contro i loop.
- [ ] **Retry distinti:** backoff per le letture, **idempotenza obbligatoria** per i side effect.
- [ ] **Dashboard minima** leggibile da un non-dev (costo, semaforo, override, eventi).
- [ ] **Allarmi su metriche aggregate:** loop, tasso 429, schema JSON rotto, costo, errori tool.
- [ ] **Store self-hosted** (Langfuse o Postgres), dati in UE.
- [ ] **Retention definita** e job di cancellazione automatica per età.
- [ ] **Diritto all'oblio** implementato: cancellazione mirata per persona/cliente.
- [ ] **Accesso ristretto** alle tracce; audit periodico della PII sfuggita.

## Il verdetto

L'**osservabilità degli LLM in produzione** è ciò che separa un agente che *gestisci* da uno che *speri* funzioni. "Guardare la chat" è un aneddoto: non ti dice il costo, la latenza reale, i loop notturni, il calo di qualità. Le tracce strutturate sì. Con parent run e span, sai esattamente cosa è successo in ogni run e quanto è costato. Con l'attribuzione per agente e processo, la spesa AI diventa un centro di costo governabile invece di una bolletta indistinta. Con il budget-killer, i loop che bruciano euro si fermano in tempo reale invece di comparire a fine mese.

E lo fai da SRE, con i confini giusti: la PII si redige prima dello storage (ciò che non salvi non devi proteggere), i retry distinguono le letture — ritentabili con backoff — dai side effect, che senza idempotenza non si ritentano mai, pena il doppio pagamento. Le dashboard traducono le metriche in fiducia per chi non è sviluppatore, gli allarmi si basano su tendenze aggregate e non su singoli eventi, e la retention con il diritto all'oblio evita di trasformare l'osservabilità in un archivio-ombra di dati personali. Tutto self-hosted, perché mandare i tuoi prompt a un SaaS di monitoraggio vanifica la sovranità del resto dello stack.

Fatto così, hai un agente di cui conosci il costo, la salute e la qualità, e che si ferma da solo quando impazzisce. Fatto senza, hai una scatola nera che ti presenta il conto quando è troppo tardi. La differenza non è il modello. È se hai gli strumenti per vedere cosa fa davvero, invece di leggere la chat e sperare.

Se hai agenti in produzione e non sai dirmi quanto costano, quanto sono affidabili e quante volte vanno in loop, è il momento dell'osservabilità. Puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). SRE per agenti, non slide.

## FAQ

### Perché leggere la conversazione non basta come monitoraggio?
Perché è un aneddoto, non un dato. La chat non ti dice il costo del run, la latenza al 95° percentile, quante volte l'agente è andato in loop questa settimana, quanti override umani sono serviti, o se ieri notte ha bruciato token a vuoto. L'osservabilità raccoglie queste grandezze in modo strutturato e aggregabile, così puoi rispondere a "quanto costa e sta bene?" con numeri, non con impressioni.

### Qual è la differenza tra traccia e log?
Un log è un evento piatto ("ha chiamato il modello alle 10:03"). Una traccia è un albero: un parent run con sotto gli span di ogni chiamata al modello e a ogni tool. Per un agente che fa più passi, la traccia ti fa vedere quale passo è stato lento, quale tool è fallito e quanto è costato ciascuno. I log piatti, su un agente multi-step, sono illeggibili; la traccia ricostruisce il flusso.

### Devo usare Langfuse o mi basta Postgres?
Dipende dalla scala. Per iniziare, due tabelle Postgres (`runs` e `spans`) coprono l'80% del valore senza dipendenze: costo per agente, latenza, errori, override. Langfuse self-hosted aggiunge la vista LLM pronta (prompt, valutazioni, dashboard) ed è comodo quando il progetto cresce. Entrambi restano sovrani se self-hosted. Evita i SaaS che si tengono i tuoi prompt se hai dati sensibili.

### Come evito di loggare dati personali nei prompt?
Con la redaction *prima* dello storage: pattern per email, IBAN, codici fiscali, telefoni sostituiti con segnaposto, e troncamento dei testi lunghi. Meglio ancora, non far entrare la PII nella traccia: logga il riferimento (ID cliente, ID documento), non il dato. Ciò che non salvi non devi proteggerlo né cancellarlo. La regex non è perfetta sui nomi propri, ma sui dati strutturati ad alto rischio è molto efficace.

### Come attribuisco i costi a un singolo processo o cliente?
Aggiungendo un campo `process` (o tenant/cliente) a ogni run, insieme a token in/out e costo. Poi una query `GROUP BY agent, process` ti dice esattamente chi consuma. Senza questo campo sai solo "l'AI costa X al mese", che è inutile per intervenire. Con l'attribuzione, la spesa diventa un centro di costo governabile e puoi tagliare dove serve.

### Come impedisco a un agente di bruciare token in un loop?
Con un budget-killer deterministico: un tetto di spesa (giornaliero o per-run) e un guard sul numero di step. Prima di ogni chiamata costosa, l'enforcer controlla la spesa accumulata e i passi; se sfora, ferma il run (`killed`) e allerta. Un agente sano fa pochi passi; uno che ne fa cinquanta sta girando a vuoto. È l'assicurazione contro il costo che esplode di notte senza che nessuno guardi.

### I retry non risolvono da soli i problemi?
Solo per i fallimenti transitori delle letture (429, 5xx), dove il backoff esponenziale è corretto. Per i tool con side effect — pagamenti, scritture, invii — ritentare alla cieca è pericoloso: se la risposta si perde ma l'azione è andata, il retry paga due volte. I side effect si ritentano solo con una chiave di idempotenza che garantisce esecuzione singola; senza, non si ritentano in automatico, si segnalano a un umano.

### Che allarmi dovrei configurare?
Su metriche aggregate, non su singoli eventi: loop/step che esplodono, tasso di 429 sopra la norma, validazioni di schema JSON che iniziano a fallire (regressione), costo sopra soglia, tasso di errore dei tool in salita. L'errore da evitare è allarmare su ogni singolo evento normale: gli allarmi che gridano troppo vengono ignorati. Meglio pochi allarmi su tendenze reali che rumore continuo.

### Le tracce sono soggette al GDPR?
Spesso sì: anche redatte, contengono riferimenti a persone e clienti, e talvolta PII sfuggita. Vanno quindi trattate come dati personali: retention definita (payload a vita breve, metriche aggregate più a lungo), cancellazione automatica per età, e capacità di cancellare su richiesta tutto ciò che riguarda una persona. Il self-hosting rende tutto questo governabile sui tuoi dischi, senza dipendere dalle garanzie di un fornitore.

### Da dove parto se ho già agenti in produzione senza osservabilità?
In quest'ordine: (1) aggiungi una tabella `runs` con costo, token, stato e `process`, e strumenta il parent run; (2) metti la redaction prima di salvare; (3) aggiungi il budget-killer e il guard sugli step, che ti proteggono subito dai loop; (4) crea due o tre query per costo, latenza p95 e override; (5) configura gli allarmi essenziali; (6) definisci retention e cancellazione. I primi tre passi si fanno in poco tempo e coprono i rischi più cari (costo che esplode, PII loggata).
