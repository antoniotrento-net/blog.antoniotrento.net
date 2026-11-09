---
lang: it
permalink: /it/blog/rate-limit-api-pubbliche-cache/
alt_url: /en/blog/public-api-rate-limit-cache/
title: "Rate limit delle API pubbliche (FRED, SEC, RSS): jitter, cache 24h e perché --force in loop dal PC di casa ti brucia l'IP"
date: 2026-11-11 07:30:00 +0200
author: "Antonio Trento"
description: "Galateo da data pipeline per chi consuma API pubbliche: limiti di FRED e SEC EDGAR, user-agent onesto, cache con ETag e TTL, backoff con jitter che rispetta Retry-After, cron sparpagliati, il problema del --force da laptop, quando smettere di scrapare, seed vs live in UI e runbook per il 429."
keywords: ["rate limit api pubbliche cache", "fred api rate limit", "sec edgar educata", "jitter cron", "cache 24h", "backoff esponenziale 429"]
image: /assets/images/posts/rate-limit-api-pubbliche-cache.jpg
pillar: stack-sovrano
related: [/it/blog/margin-debt-fred-vs-finra/, /it/blog/n8n-queue-mode-postgres/]
---

## Il lunedì in cui il router di casa è finito in blacklist

Il copione è sempre lo stesso. Qualcuno costruisce un piccolo cruscotto: tassi, inflazione, qualche serie macro da FRED, i depositi recenti di qualche società da SEC EDGAR, un paio di feed RSS di notizie. Lo fa sul suo PC, perché è un progetto personale o perché "per ora è un prototipo". Lo script ha un'opzione `--force` che ignora la cache e riscarica tutto, comoda mentre si sviluppa. Poi il prototipo diventa utile, qualcuno lo mette in un cron ogni cinque minuti, e il `--force` resta lì perché "così i dati sono sempre freschi".

Una mattina il cruscotto è vuoto. I log sono pieni di `429 Too Many Requests` da una fonte e di `403 Forbidden` da un'altra. Il problema non è solo lo script: è l'**indirizzo IP**. È quello di casa, o dell'ufficio, condiviso con tutto il resto. Per qualche ora — a volte qualche giorno — quella fonte non risponde più a nessuno da quella rete. Se l'IP è quello di una connessione con CGNAT, magari hai anche peggiorato la giornata di qualche sconosciuto che condivide il tuo indirizzo pubblico.

Questo pezzo parla di **rate limit delle API pubbliche e di cache**: come si consumano dati pubblici in modo civile, senza farsi bloccare e senza trattare un servizio gratuito come se fosse il proprio cluster. Non c'è niente di esotico: user-agent onesto, cache con regole esplicite, backoff con jitter che rispetta `Retry-After`, job pianificati che non partono tutti allo stesso secondo, e una regola che sembra ovvia finché non la violi: se una fonte ti risponde 403 sull'HTML, smetti e cambia fonte.

## È per te / non è per te

È per te se:

- hai una pipeline (Python, n8n, cron, un job in Docker) che scarica dati da API pubbliche o semi-pubbliche: statistiche, prezzi, depositi societari, feed, open data;
- l'hai vista funzionare per settimane e poi rompersi senza che il codice fosse cambiato;
- stai per spostare un prototipo dal laptop a un server e vuoi farlo senza portarti dietro le cattive abitudini.

Non è per te se consumi un'API commerciale con contratto e SLA: lì i limiti sono scritti nel contratto e il galateo è sostituito dalla fattura. Non è per te nemmeno se il tuo problema è fare scraping di siti che non vogliono essere letti: qui la risposta è "non farlo", e il pezzo non ti aiuterà a farlo meglio.

## Le API pubbliche non sono il tuo cluster

La prima cosa da togliersi dalla testa è l'idea che un endpoint pubblico sia una risorsa infinita. Dietro FRED c'è un team della Federal Reserve Bank di St. Louis; dietro EDGAR ci sono i server della SEC; dietro un feed RSS spesso c'è un piccolo editore con un hosting normale. Servono milioni di utenti gratis. Lo fanno con regole di accesso che non sono capricci: sono il modo per non dover chiudere il servizio a tutti per colpa di pochi.

Tre principi che regolano tutto il resto:

1. **Tu sei un ospite.** I limiti dichiarati sono un tetto, non un obiettivo. Se FRED ti consente un certo numero di richieste al minuto, la tua pipeline dovrebbe stare comodamente sotto, non danzarci intorno.
2. **I dati pubblici cambiano lentamente.** Una serie macro mensile si aggiorna una volta al mese. Un deposito SEC, una volta pubblicato, non cambia. Un feed RSS di un blog si aggiorna qualche volta al giorno. Riscaricare ogni cinque minuti dati che cambiano una volta al mese non è "freschezza": è rumore che paghi tu (in blocchi) e loro (in banda).
3. **L'identità del chiamante conta.** Le fonti serie vogliono sapere chi sei, per contattarti prima di bloccarti. Un user-agent anonimo o finto ("Mozilla/5.0…" da uno script Python) è il modo più rapido per passare da "utente da avvisare" a "traffico da bloccare".

Il default che uso per questo tipo di pipeline è semplice: un **piccolo servizio di raccolta** in Docker su un VPS in UE o su un server interno, con una cache locale (file o Postgres), che è l'unico processo autorizzato a parlare con le fonti esterne. Cruscotti, notebook, agenti e flussi n8n leggono dalla cache, mai direttamente dalla fonte. Questo da solo elimina metà dei problemi: non ci sono dieci client che scaricano la stessa serie, c'è uno che la scarica e dieci che la leggono.

## FRED e simili: chiavi, limiti, cache

FRED è un buon esempio di API pubblica fatta bene: registri un account, ottieni una chiave API gratuita, ogni richiesta porta la chiave, e il servizio applica limiti per chiave. La documentazione dichiara un tetto di richieste per unità di tempo (nell'ordine di un centinaio al minuto per chiave, al momento in cui scrivo: verifica sempre la pagina ufficiale, perché sono numeri che cambiano). Oltre il tetto ricevi un 429.

Cosa significa in pratica:

- **Una chiave per applicazione, non una per sviluppatore incollata ovunque.** La chiave identifica la tua applicazione. Se la stessa chiave è usata dal cruscotto in produzione, dal notebook di un collega e da un test in CI, il limite è condiviso e il primo che esagera blocca gli altri. La chiave sta in un segreto, non nel repository — vale lo stesso discorso dei [segreti degli agenti tra .env, Docker secrets e vault]({{ '/it/blog/secrets-agenti-llm-vault/' | relative_url }}).
- **Le richieste si raggruppano.** Molte API statistiche permettono di chiedere una serie intera con un intervallo di date, invece di un'osservazione per volta. Una richiesta per serie al giorno è quasi sempre sufficiente.
- **I metadati dicono quando ha senso riscaricare.** FRED espone per ogni serie la frequenza e l'ultimo aggiornamento. Se la serie è mensile e l'ultimo aggiornamento è di dieci giorni fa, non serve chiederla di nuovo ogni ora. Una richiesta leggera ai metadati, una volta al giorno, ti dice se la serie è cambiata; solo allora scarichi le osservazioni.
- **Vintage e revisioni.** Le serie macro vengono riviste. Se il tuo uso richiede di sapere *quale versione* del dato avevi in un certo giorno (backtest, report storici), devi salvare le versioni, non sovrascrivere. È uno dei temi del pezzo sul [margin debt tra FRED e FINRA]({{ '/it/blog/margin-debt-fred-vs-finra/' | relative_url }}): la data di riferimento del dato e la data in cui l'hai scaricato sono due colonne diverse.

### Politica di cache

La cache non è "salvo la risposta e la riuso finché non mi ricordo di cancellarla". È una politica scritta, per fonte e per tipo di dato, con un TTL, un criterio di invalidazione e una regola per quando la fonte non risponde.

| Fonte / tipo di dato | TTL di base | Invalidazione | Se la fonte non risponde |
|---|---|---|---|
| FRED, serie giornaliere | 24 h | metadati `last_updated` cambiati | servi la cache, marca "stale" dopo 48 h |
| FRED, serie mensili / trimestrali | 24 h sui metadati, osservazioni solo se cambiate | `last_updated` cambiato | servi la cache, nessun allarme prima di 7 giorni |
| SEC EDGAR, indice depositi per società | 6–24 h | nuovo deposito nell'indice | servi la cache, allarme dopo 48 h |
| SEC EDGAR, documento di un deposito | per sempre (immutabile) | mai | servi la cache |
| Feed RSS di editori | 1–6 h, con richiesta condizionale | `ETag` / `Last-Modified` | servi la cache, nessun retry aggressivo |
| Open data PA (CSV/JSON pubblicati) | 24 h – 7 giorni | `ETag` / data di pubblicazione | servi la cache |
| Tassi e quotazioni "quasi live" | minuti, solo se servono davvero | — | mostra chiaramente l'età del dato |

Due note. Primo: il TTL di 24 ore è un buon default per quasi tutto ciò che è statistico, e quasi nessuno ha davvero bisogno di meno. Secondo: la colonna più importante è l'ultima. Quando la fonte è giù, la pipeline deve **servire l'ultimo dato buono con la sua età**, non svuotare il cruscotto e non martellare la fonte nel tentativo di "recuperare".

## SEC/RSS: rispetto e parsing robusto

La SEC è il caso da manuale di fonte che ti spiega le regole. La politica di accesso equo di EDGAR chiede due cose esplicite: un tetto di richieste al secondo (10 al momento in cui scrivo) e un **user-agent che dichiari chi sei**, con un nome e un contatto email. Chi supera il tetto viene limitato per un periodo; chi non si identifica rischia di essere trattato come traffico automatico anonimo. La SEC offre anche archivi in blocco e indici giornalieri pensati proprio per evitare che tutti scarichino tutto un documento alla volta.

### User-agent onesto

Il user-agent è una riga, e dice molto di te. Quello giusto contiene il nome dell'applicazione, una versione e un contatto reale:

```python
import httpx

USER_AGENT = "Cruscotto-Macro/1.4 (contatto: dati@esempio-azienda.it)"

client = httpx.Client(
    headers={
        "User-Agent": USER_AGENT,
        "Accept-Encoding": "gzip, deflate",
    },
    timeout=httpx.Timeout(20.0, connect=5.0),
    follow_redirects=True,
)
```

Cosa non fare: copiare il user-agent di Chrome per "sembrare un browser". Non sei un browser, e chi gestisce la fonte lo capisce in tre secondi da come richiedi le risorse. Fingere di esserlo è il passo che trasforma un problema di quota in un problema di fiducia. E il contatto deve essere una casella che qualcuno legge: se la SEC o un editore ti scrive "state esagerando", vuoi saperlo prima del blocco.

### RSS e richieste condizionali

Per i feed RSS e Atom, il galateo ha un nome tecnico preciso: **richieste condizionali**. La prima volta che scarichi un feed, il server ti restituisce (se è configurato bene) un header `ETag` e/o `Last-Modified`. Le volte successive li rimandi con `If-None-Match` e `If-Modified-Since`. Se il feed non è cambiato, il server risponde `304 Not Modified` con un corpo vuoto: zero banda, zero parsing, zero rischio di sembrare un crawler.

```python
def fetch_conditional(client, url, cache):
    entry = cache.get(url)  # dict con body, etag, last_modified, fetched_at
    headers = {}
    if entry:
        if entry.get("etag"):
            headers["If-None-Match"] = entry["etag"]
        if entry.get("last_modified"):
            headers["If-Modified-Since"] = entry["last_modified"]
    r = client.get(url, headers=headers)
    if r.status_code == 304 and entry:
        cache.touch(url)  # aggiorna solo fetched_at
        return entry["body"], "not_modified"
    r.raise_for_status()
    cache.put(url, body=r.text,
              etag=r.headers.get("ETag"),
              last_modified=r.headers.get("Last-Modified"))
    return r.text, "updated"
```

### Parsing robusto

Il rispetto non è solo quanto chiedi: è anche cosa fai quando la risposta è strana. I feed RSS sono il regno dell'XML malformato, delle codifiche dichiarate male, delle date in formati creativi. EDGAR ha documenti con strutture diverse a seconda dell'epoca e del tipo di deposito. Due regole:

- **Un errore di parsing non è un motivo per riscaricare.** Se il documento è malformato, riscaricarlo dieci volte ti darà dieci volte lo stesso documento malformato. Salva la risposta grezza, registra l'errore, vai avanti. Molti loop di retry "misteriosi" sono in realtà parser che falliscono e un `except` che ritenta il download.
- **Valida lo schema minimo, non la perfezione.** Per un feed bastano titolo, link e data; per un indice di depositi bastano identificativo, tipo e data. Il resto è opzionale e non deve far fallire l'intero lotto.

## Jitter: non 50 job alle 00:00:00

Il secondo modo più comune per farsi notare da una fonte pubblica è puntuale come un orologio: letteralmente. Scrivi un cron `0 * * * *` per ogni serie, ne hai cinquanta, e allo scoccare di ogni ora la tua macchina fa cinquanta richieste nello stesso secondo. Moltiplica per tutti quelli che hanno avuto la stessa idea, e capisci perché molte fonti hanno picchi di traffico al minuto zero di ogni ora, e perché ci mettono limiti più severi proprio lì.

Il rimedio si chiama **jitter**: un ritardo casuale che sparpaglia le esecuzioni.

- **Jitter sull'avvio del job.** Il job parte "intorno" all'orario, non esattamente all'orario. Con systemd è un'opzione del timer; con cron si fa con uno `sleep` casuale.
- **Jitter tra le richieste dentro il job.** Le cinquanta serie non partono in parallelo: partono in sequenza, con una pausa base e un po' di casualità.
- **Orari non tondi.** Se il dato si aggiorna di mattina, scarica alle 06:47, non alle 06:00.

Con systemd:

```ini
# /etc/systemd/system/raccolta-macro.timer
[Unit]
Description=Raccolta serie macro (una volta al giorno, sparpagliata)

[Timer]
OnCalendar=*-*-* 06:40:00
RandomizedDelaySec=20min
Persistent=true

[Install]
WantedBy=timers.target
```

Con cron, se non hai alternative:

```bash
# m h dom mon dow  comando
47 6 * * * sleep $((RANDOM % 900)); /opt/raccolta/bin/raccogli --fonte fred >> /var/log/raccolta/fred.log 2>&1
```

E dentro il job, tra una richiesta e l'altra, una pausa che rispetta il limite con un margine:

```python
import random, time

def pausa_tra_richieste(limite_al_secondo: float, margine: float = 0.5):
    """Sta sotto il limite dichiarato con un margine, e aggiunge casualità."""
    base = 1.0 / (limite_al_secondo * margine)   # es. 10 req/s, margine 0.5 → 0.2 s
    time.sleep(base + random.uniform(0, base))
```

Se la pipeline gira in n8n, valgono le stesse regole: niente trigger "Every hour" su cinquanta workflow separati, piuttosto un unico workflow che itera con un nodo di attesa e un orario non tondo. Se hai già un'installazione in [queue mode con Postgres]({{ '/it/blog/n8n-queue-mode-postgres/' | relative_url }}), ricordati che più worker significano più parallelismo verso l'esterno: il limite va applicato per fonte, non per worker.

## --force e i loop da laptop

Torniamo al `--force`. È un'opzione legittima in sviluppo: vuoi vedere cosa restituisce la fonte adesso, senza cache. Diventa un problema per tre motivi che si sommano.

**1. Il laptop non è un server.** Va in sospensione, si risveglia, il cron recupera tutte le esecuzioni perse in un colpo. Cambia rete (casa, ufficio, hotspot del telefono), e a ogni cambio la cache può risultare "vecchia". Se lo script ha una logica del tipo "se sono passate più di N ore, riscarica tutto", al risveglio dopo un weekend fa il pieno.

**2. L'IP residenziale è condiviso e fragile.** Il tuo IP di casa è condiviso con la famiglia, i dispositivi smart, magari con altri clienti del provider (CGNAT). Quando una fonte blocca quell'IP, blocca tutti. E al contrario, molte fonti guardano con sospetto il traffico automatico da IP residenziali, perché è anche il profilo tipico delle botnet. Un VPS con IP fisso, user-agent chiaro e volumi bassi è, paradossalmente, un cittadino più rispettabile del tuo PC.

**3. Il `--force` in un loop è un attacco involontario.** Uno script di debug che riprova "finché non funziona", con `--force`, senza pausa: in un minuto hai fatto centinaia di richieste. Se la fonte risponde 429, il loop ritenta subito, e la situazione peggiora.

Regole che applico sempre:

- `--force` agisce su **una** risorsa per volta (`--force --serie DGS10`), mai su tutto.
- `--force` rispetta comunque il rate limiter. La cache si salta; il limite no.
- In produzione il `--force` non esiste: il job di produzione legge la configurazione, non argomenti a riga di comando.
- Sul laptop, la pipeline legge dalla **cache del server** (via un endpoint interno o una copia del database), non dalla fonte.

Spostare la raccolta su un piccolo server non è un lusso: è il passo che rende la pipeline prevedibile. Un container sul server interno o su un VPS europeo, come quelli descritti nello [stack Docker per PMI]({{ '/it/blog/docker-pmi-stack-sovrano/' | relative_url }}), costa pochi euro al mese e ti toglie dal problema dell'IP di casa.

## Backoff: cosa fare quando la fonte dice "basta"

Un 429 è un messaggio chiaro: hai chiesto troppo, rallenta. Spesso arriva con un header `Retry-After` che dice quanti secondi aspettare (o fino a che ora). Un 503 durante una manutenzione può portare lo stesso header. La risposta corretta ha quattro elementi:

1. **Rispetta `Retry-After`** se c'è. È la fonte che ti dice quanto aspettare: usalo, anche se è più lungo di quanto vorresti.
2. **Backoff esponenziale con jitter** se non c'è: aspetta 2, 4, 8, 16 secondi, ma con una componente casuale, così cento client bloccati nello stesso momento non ritornano tutti nello stesso momento.
3. **Un numero massimo di tentativi**, dopo il quale smetti e servi la cache.
4. **Un circuit breaker per fonte**: se una fonte ha dato errori ripetuti, la pipeline smette di interrogarla per un periodo, invece di ricominciare a ogni job.

### Esempio di backoff

```python
import random, time
from email.utils import parsedate_to_datetime
from datetime import datetime, timezone

RITENTABILI = {429, 500, 502, 503, 504}

def attesa_da_retry_after(valore: str | None) -> float | None:
    if not valore:
        return None
    if valore.isdigit():
        return float(valore)
    try:
        quando = parsedate_to_datetime(valore)
        return max(0.0, (quando - datetime.now(timezone.utc)).total_seconds())
    except (TypeError, ValueError):
        return None

def get_con_backoff(client, url, max_tentativi=5, base=2.0, tetto=300.0, **kw):
    for tentativo in range(1, max_tentativi + 1):
        r = client.get(url, **kw)
        if r.status_code not in RITENTABILI:
            return r
        attesa = attesa_da_retry_after(r.headers.get("Retry-After"))
        if attesa is None:
            # "full jitter": attesa casuale tra 0 e il tetto esponenziale
            attesa = random.uniform(0, min(tetto, base ** tentativo))
        log.warning("fonte_limitata", extra={
            "url": url, "status": r.status_code,
            "tentativo": tentativo, "attesa_s": round(attesa, 1)})
        if tentativo == max_tentativi:
            break
        time.sleep(attesa)
    raise FonteNonDisponibile(url)
```

Il circuit breaker può essere banale: una riga in una tabella con fonte, numero di errori consecutivi e "non interrogare fino a". Il job, prima di partire, controlla quella riga. Se la fonte è in pausa, salta e lascia la cache dov'è.

### Un errore da non fare: ritentare i 4xx

`400`, `401`, `403`, `404` **non si ritentano** in automatico. Una richiesta malformata resta malformata, una chiave scaduta resta scaduta, un 404 resta un 404. Ritentarli è l'equivalente di bussare più forte a una porta che ti hanno detto essere chiusa. L'unica eccezione è il 429, che è proprio "riprova più tardi".

## 403 da HTML: smetti, cambia fonte

C'è una scena ricorrente: una fonte non ha API (o ce l'ha ma è a pagamento), allora qualcuno scarica la pagina HTML e la "parsa". Funziona per un po'. Poi arriva un 403, o una pagina di verifica anti-bot, o un captcha. La reazione istintiva è cambiare user-agent, aggiungere header da browser, ruotare IP, usare un browser headless.

Fermati lì. Un 403 su una pagina HTML dopo un periodo in cui funzionava significa quasi sempre una cosa: **il proprietario del sito ha deciso che quel tipo di accesso non lo vuole**. Aggirarlo vuol dire:

- violare probabilmente i termini d'uso del sito;
- entrare in una corsa agli armamenti che perderai (e che ti costerà manutenzione ogni settimana);
- esporre la tua organizzazione a contestazioni, perché il tuo IP o il tuo user-agent onesto ti identificano;
- costruire un prodotto su una fonte che può sparire domani.

Cosa fare invece:

1. **Cercare l'API ufficiale** o i dataset in blocco. Molte fonti che sembrano "solo HTML" hanno un endpoint dati, un CSV scaricabile, un feed.
2. **Cercare la fonte primaria.** Spesso la pagina che stai leggendo ripubblica dati di un'altra istituzione che li distribuisce in forma aperta.
3. **Valutare una licenza.** Se il dato ha valore commerciale per te, pagare un fornitore con licenza chiara è meno costoso di mantenere uno scraper che si rompe.
4. **Accettare di non avere quel dato**, o di averlo con meno frequenza, inserito a mano da una persona.

Nel pezzo sul margin debt ho fatto lo stesso ragionamento per i dati finanziari: niente scraper contro le protezioni anti-bot, solo API e download ufficiali, e se una fonte non ha una via lecita e stabile si rinuncia all'indicatore. È la scelta noiosa, ed è quella giusta.

## Seed vs live: dichiaralo in UI

Una pipeline civile accetta che a volte non avrà dati freschi. A quel punto la domanda diventa: cosa mostra il cruscotto? La risposta sbagliata è "l'ultimo dato, come se niente fosse". La risposta giusta è mostrare **l'origine e l'età di ogni numero**.

Distinguo tre stati:

- **Live**: il dato è stato scaricato dalla fonte entro il TTL previsto.
- **Stale**: il dato viene dalla cache, è più vecchio del previsto perché la fonte non ha risposto o è in pausa. Si mostra, con l'età in chiaro.
- **Seed**: il dato viene da un dataset di partenza (un file caricato a mano, un'esportazione storica, un dato di esempio per lo sviluppo). Non è mai stato verificato contro la fonte live.

Il terzo stato è quello che fa più danni quando non è dichiarato. Succede così: per sviluppare il cruscotto si carica un CSV di esempio; poi la pipeline live non parte mai davvero per un problema di chiave; il cruscotto continua a mostrare i dati di esempio per settimane, e nessuno se ne accorge perché "i numeri ci sono".

In pratica, ogni valore mostrato porta tre metadati: `fonte`, `as_of` (la data a cui il dato si riferisce) e `fetched_at` (quando l'hai preso). La UI li usa:

```json
{
  "serie": "DGS10",
  "valore": 4.21,
  "as_of": "2026-11-06",
  "fetched_at": "2026-11-09T06:52:11+01:00",
  "fonte": "FRED",
  "stato": "live",
  "nota": null
}
```

Accanto al numero, in piccolo: "FRED, dato al 6 nov, aggiornato stamattina". Se lo stato è `stale`: "ultimo aggiornamento riuscito 3 giorni fa". Se è `seed`: un'etichetta che non lasci dubbi, tipo "dato di esempio, non live". È la stessa disciplina che serve per qualsiasi [cruscotto aziendale che il titolare apre davvero]({{ '/it/blog/cruscotto-aziendale-titolare/' | relative_url }}): un numero senza data è un'opinione.

## L'architettura di riferimento

Mettiamo insieme il quadro.

**Componenti:**

- **Collettore** (container Python o workflow n8n dedicato) su server interno o VPS UE: unico componente che parla con le fonti esterne. Ha il rate limiter per fonte, il backoff, il circuit breaker, il user-agent onesto.
- **Configurazione delle fonti** in un file versionato: per ogni fonte l'URL base, il limite dichiarato, il margine, il TTL, la politica di invalidazione, il contatto.
- **Cache / store** in Postgres (o SQLite per volumi piccoli): risposte grezze, dati normalizzati, metadati (`etag`, `last_modified`, `as_of`, `fetched_at`, `stato`), versioni per i dati che vengono rivisti.
- **Stato delle fonti**: errori consecutivi, pausa del circuit breaker, ultimo successo.
- **Consumatori** (cruscotti, notebook, agenti, report): leggono solo dallo store, mai dalla fonte.
- **Log e metriche**: richieste per fonte, risposte per codice, 304 vs 200, attese da backoff, età dei dati.

**Cosa non tocca la fonte esterna:**

- il laptop degli sviluppatori (lavorano su una copia dello store);
- gli agenti LLM (se un agente ha bisogno di un dato, lo chiede allo store tramite un tool; non ha un tool "scarica URL" verso fonti esterne);
- la CI (i test usano fixture registrate, non chiamate live).

Quest'ultimo punto merita una riga in più: un test suite che chiama FRED a ogni push consuma la quota della chiave di produzione e fallisce in modo casuale quando la fonte è lenta. Le risposte si registrano una volta e si riusano.

```yaml
# fonti.yaml — versionato, letto dal collettore
fonti:
  fred:
    base_url: https://api.stlouisfed.org/fred
    limite_richieste_al_minuto: 100     # verifica sul sito ufficiale
    margine: 0.4                        # usiamo il 40% del limite
    ttl_ore: 24
    invalidazione: metadati_last_updated
    chiave_da_segreto: fred_api_key
  sec_edgar:
    base_url: https://data.sec.gov
    limite_richieste_al_secondo: 10     # fair access policy, verifica sul sito ufficiale
    margine: 0.3
    ttl_ore: 12
    user_agent_obbligatorio: true
  rss_editori:
    ttl_ore: 3
    richieste_condizionali: true
    max_feed_per_esecuzione: 40
contatto_user_agent: "dati@esempio-azienda.it"
circuit_breaker:
  errori_consecutivi_per_pausa: 5
  pausa_minuti: 60
```

## Percorso di implementazione, a step

1. **Inventario delle fonti.** Per ognuna: URL, termini d'uso, limiti dichiarati, frequenza reale di aggiornamento del dato, chi la usa in azienda.
2. **Leggi i termini d'uso.** Sembra ovvio. Non lo fa quasi nessuno. Molte fonti dicono esplicitamente cosa puoi fare, con che frequenza e con che identificazione.
3. **Scegli dove gira il collettore.** Server interno o VPS UE con IP fisso. Non il laptop, non il PC dell'ufficio che si spegne la sera.
4. **Scrivi `fonti.yaml`** con limiti, margini, TTL, invalidazione.
5. **Implementa il client comune**: user-agent, timeout, rate limiter per fonte, richieste condizionali, backoff con `Retry-After`, circuit breaker. Un solo modulo, usato da tutte le raccolte.
6. **Implementa lo store** con i metadati di stato (`live`, `stale`, `seed`) e le versioni dove servono.
7. **Pianifica con jitter**: un timer per fonte, orari non tondi, ritardo casuale.
8. **Sposta i consumatori sullo store.** Cruscotti, notebook, agenti: nessuno chiama più la fonte direttamente.
9. **Metti in UI età e stato** di ogni dato.
10. **Aggiungi metriche e allarmi**: tasso di 429, fonti in pausa, dati stale oltre soglia.
11. **Registra le fixture** per i test e togli le chiamate live dalla CI.
12. **Scrivi il runbook del 429** (sotto) e mettilo dove lo trova chi è di turno.

## Runbook 429

Quando una fonte inizia a rispondere 429 (o 403 dopo un periodo di 429), il runbook è breve e va seguito nell'ordine.

1. **Ferma i job verso quella fonte.** Metti il circuit breaker in pausa manuale. Non "proviamo ancora una volta".
2. **Verifica che i consumatori servano la cache** e che la UI mostri lo stato `stale`. Nessun cruscotto vuoto.
3. **Guarda i log delle ultime 24 ore**: quante richieste verso quella fonte, da quali job, con che distribuzione nel tempo. Cerca picchi al minuto zero, loop di retry, job duplicati.
4. **Controlla da dove arrivano le richieste.** Un solo IP (il collettore) o anche altri (laptop, CI, un vecchio cron dimenticato)? Se la chiave API è stata usata da altri, ruotala.
5. **Leggi la risposta della fonte.** Un `Retry-After`, un corpo con un messaggio, una mail arrivata alla casella del contatto nel user-agent. A volte la fonte ti dice esattamente cosa hai sbagliato.
6. **Correggi la causa**, non il sintomo: TTL troppo corto, jitter assente, `--force` in produzione, job duplicati dopo un deploy.
7. **Riparti piano**: riattiva la fonte con un margine più basso (es. dal 40% al 20% del limite) per qualche giorno.
8. **Se il blocco è sull'IP e non si risolve in 24–48 ore**, contatta il gestore della fonte dalla casella dichiarata, spiegando cosa è successo e cosa hai corretto. Non cambiare IP per aggirare il blocco.
9. **Annota l'incidente**: causa, durata, correzione. Al terzo incidente sulla stessa fonte, rivedi l'intera politica di cache per quella fonte.

## Fallimenti tipici e come li riconosci dai log

**Picco al minuto zero.**

```text
2026-11-09T07:00:00.112 GET fred/series/observations?series_id=CPIAUCSL 200
2026-11-09T07:00:00.118 GET fred/series/observations?series_id=UNRATE 200
2026-11-09T07:00:00.121 GET fred/series/observations?series_id=DGS10 200
...
2026-11-09T07:00:01.004 GET fred/series/observations?series_id=M2SL 429
```

Decine di richieste nello stesso secondo: cron senza jitter, job paralleli. Il 429 arriva alla fine del burst.

**Loop di retry sul parser.**

```text
06:52:10 GET feed.esempio.it/rss 200 bytes=48211
06:52:10 parse_error feed.esempio.it/rss "not well-formed (invalid token): line 312"
06:52:11 GET feed.esempio.it/rss 200 bytes=48211
06:52:11 parse_error feed.esempio.it/rss "not well-formed (invalid token): line 312"
```

Stessa dimensione, stesso errore: il retry è sul download, ma il problema è il contenuto. Separare i due rami.

**Nessun 304.** Se un feed viene scaricato dieci volte al giorno e non vedi mai un `304`, o non stai mandando gli header condizionali o il server non li supporta. Nel secondo caso, alza il TTL.

**Retry sui 4xx.**

```text
GET data.sec.gov/... 403 attempt=1
GET data.sec.gov/... 403 attempt=2
GET data.sec.gov/... 403 attempt=3
```

Un 403 ritentato tre volte è un 403 che hai peggiorato. Spesso la causa è un user-agent mancante o generico.

**Dati seed in produzione.** Nessuna richiesta verso la fonte negli ultimi giorni, ma il cruscotto mostra numeri. Cerca `stato=seed` nello store: se lo trovi su dati che dovrebbero essere live, la pipeline non è mai partita.

**Esecuzioni recuperate dopo il risveglio.**

```text
2026-11-09T08:14:02 job=raccolta-fred avvio (recuperato: 3 esecuzioni perse)
```

Classico del laptop o di `Persistent=true` dopo uno spegnimento lungo. Il job deve accorgersene e fare **una** esecuzione, non tre.

## Costi: ordini di grandezza

Stime indicative, da verificare sul tuo caso.

| Voce | Ordine di grandezza (stima) | Note |
|---|---|---|
| VPS UE per il collettore | 5–15 €/mese | 2 vCPU, 4 GB RAM bastano per decine di fonti |
| Storage per cache e versioni | trascurabile – pochi €/mese | Serie macro e indici occupano poco; i documenti EDGAR in blocco di più |
| Sviluppo client comune + store + config | 4–8 giorni/uomo | Una volta, poi lo riusi per ogni fonte |
| Aggiunta di una nuova fonte | 0,5–2 giorni/uomo | Se il client comune esiste |
| UI con stato e età del dato | 1–3 giorni/uomo | Dipende dal cruscotto |
| Manutenzione di uno scraper HTML | 0,5–2 giorni/mese | Il costo che eviti cambiando fonte |
| Costo di un IP bloccato | ore o giorni senza dati | Più il tempo per capire cosa è successo |

Il conto più interessante è l'ultimo confronto: un client fatto bene costa una settimana, una volta. Uno scraper che combatte con le difese anti-bot costa giorni ogni mese, per sempre, e si rompe sempre nel momento meno opportuno.

## Quando NON farlo

- **Quando ti serve un dato davvero real-time con SLA.** Prezzi di mercato in tempo reale, dati per decisioni operative al minuto: lì una fonte pubblica gratuita è la scelta sbagliata a prescindere dal galateo. Serve un fornitore con contratto.
- **Quando i dati sono pochi e statici.** Se ti servono cinque serie aggiornate una volta al mese, un collettore con circuit breaker è sovradimensionato. Basta uno script giornaliero con cache e user-agent, oppure il download manuale.
- **Quando la fonte vieta l'uso automatico.** Se i termini d'uso escludono l'accesso automatizzato, non c'è architettura che lo renda accettabile.
- **Quando nessuno guarderà gli allarmi.** Una pipeline con circuit breaker e stato `stale` è utile solo se qualcuno si accorge che una fonte è in pausa da due settimane. Altrimenti hai solo un modo più elegante di mostrare dati vecchi.
- **Quando stai costruendo un prodotto commerciale sopra dati con licenza non chiara.** Prima la licenza, poi la pipeline.

## Checklist operativa

- [ ] Ogni fonte ha termini d'uso letti, limiti dichiarati annotati e un margine scelto.
- [ ] Il collettore gira su un server con IP fisso, non su un laptop.
- [ ] Il user-agent contiene nome dell'applicazione, versione e un contatto reale e letto.
- [ ] Le chiavi API sono in un segreto, una per applicazione, mai nel repository.
- [ ] Esiste una politica di cache scritta per fonte, con TTL, invalidazione e comportamento in caso di errore.
- [ ] I feed usano richieste condizionali e vedi `304` nei log.
- [ ] I job hanno jitter all'avvio e pause tra le richieste; nessun orario tondo.
- [ ] Il backoff rispetta `Retry-After`, usa jitter e ha un massimo di tentativi.
- [ ] I 4xx (eccetto 429) non vengono ritentati.
- [ ] C'è un circuit breaker per fonte, con stato consultabile.
- [ ] `--force` agisce su una risorsa per volta e rispetta comunque il rate limiter; in produzione non esiste.
- [ ] I consumatori leggono solo dallo store; CI e laptop non chiamano le fonti.
- [ ] La UI mostra fonte, `as_of`, `fetched_at` e stato (`live`, `stale`, `seed`).
- [ ] Il runbook del 429 è scritto e raggiungibile.

## Il verdetto

Gestire bene i rate limit delle API pubbliche con una cache seria non è una finezza da ingegneri pignoli: è la differenza tra una pipeline che funziona per anni e una che si rompe ogni volta che la fonte si stanca di te. Le regole sono poche e banali — chiediti quanto spesso il dato cambia davvero, dichiara chi sei, non partire tutti allo stesso secondo, ascolta il 429, smetti al 403 — ma vanno scritte nel codice e nella configurazione, non lasciate alla buona volontà di chi lancia lo script.

Il premio non è solo non essere bloccati. È avere un sistema in cui ogni numero ha una provenienza e un'età, in cui la fonte che va giù non svuota il cruscotto, in cui il laptop di uno sviluppatore non può bruciare l'IP dell'ufficio. È data engineering civile: rispettoso verso chi ti dà i dati gratis, e onesto verso chi legge i tuoi numeri.

Se stai portando una raccolta dati da prototipo a servizio stabile e vuoi impostarla senza dipendere da un laptop o da un SaaS, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e il resto del lavoro su [antoniotrento.net]({{ site.main_site }}/). Gli altri pezzi sull'infrastruttura self-hosted sono raccolti nella guida allo [stack sovrano]({{ '/it/pillar/stack-sovrano/' | relative_url }}).

## FAQ

### Qual è il rate limit dell'API di FRED?

FRED applica limiti per chiave API, nell'ordine di un centinaio di richieste al minuto al momento in cui scrivo, ma il valore esatto va verificato sulla documentazione ufficiale perché può cambiare. In pratica, una pipeline ben fatta resta molto al di sotto: con una cache di 24 ore e il controllo dei metadati di aggiornamento, bastano poche richieste al giorno per serie.

### Cosa chiede la SEC per l'accesso automatico a EDGAR?

La politica di accesso equo della SEC chiede di non superare un certo numero di richieste al secondo (10 al momento in cui scrivo) e di dichiarare nel user-agent il nome dell'applicazione o dell'organizzazione e un contatto email. Chi supera i limiti viene limitato temporaneamente. Per grandi volumi la SEC mette a disposizione archivi in blocco e indici.

### Cos'è il jitter e perché serve nei cron?

Il jitter è un ritardo casuale aggiunto all'avvio di un job o tra le richieste. Serve a evitare che molti job partano nello stesso istante, creando picchi che fanno scattare i rate limit della fonte. Con systemd si usa `RandomizedDelaySec`, con cron uno `sleep` casuale prima del comando.

### Quanto deve durare la cache dei dati da API pubbliche?

Dipende da quanto spesso cambia il dato. Per serie statistiche giornaliere o più lente, 24 ore sono un buon default; per i documenti immutabili, come un deposito SEC già pubblicato, la cache può essere permanente; per i feed RSS, poche ore con richieste condizionali. La regola è non riscaricare più spesso di quanto il dato si aggiorni.

### Come si gestisce un errore 429?

Si smette di inviare richieste, si rispetta l'header `Retry-After` se presente, altrimenti si applica un backoff esponenziale con jitter e un numero massimo di tentativi. Nel frattempo si serve la cache. Se i 429 si ripetono, si attiva un circuit breaker per quella fonte e si cerca la causa (picchi, retry, TTL troppo corti).

### Perché non bisogna ritentare un errore 403?

Perché un 403 significa che l'accesso è negato, non che il server è momentaneamente sovraccarico. Ritentarlo non cambia l'esito e può peggiorare la situazione, facendo sembrare il tuo traffico ostile. Su una pagina HTML, un 403 arrivato dopo un periodo in cui funzionava è spesso il segnale che il gestore non vuole quel tipo di accesso: la risposta corretta è cercare un'API ufficiale o un'altra fonte.

### È un problema eseguire una pipeline dati dal PC di casa?

Sì, per diversi motivi: il PC va in sospensione e recupera le esecuzioni perse tutte insieme, l'IP residenziale è condiviso con la famiglia o con altri clienti del provider, e molte fonti guardano con sospetto il traffico automatico da IP domestici. Un piccolo VPS in UE o un server interno con IP fisso rende la pipeline più prevedibile e la tua identità più chiara.

### Cosa sono le richieste condizionali con ETag?

Sono richieste in cui il client rimanda al server gli identificativi della versione che ha già (`If-None-Match` con l'ETag, `If-Modified-Since` con la data). Se il contenuto non è cambiato, il server risponde `304 Not Modified` senza corpo. Per feed e file pubblicati è il modo più efficiente e rispettoso di controllare gli aggiornamenti.

### Come si mostra in un cruscotto che un dato non è aggiornato?

Associando a ogni valore la fonte, la data a cui si riferisce e il momento in cui è stato scaricato, e uno stato esplicito: live, stale o seed. La UI mostra queste informazioni accanto al numero, con un'evidenza diversa quando il dato è vecchio o è un dato di esempio mai verificato contro la fonte.

### Che user-agent devo usare per uno script che scarica dati?

Uno che dica la verità: nome dell'applicazione, versione e un contatto reale, per esempio `NomeApp/1.2 (contatto: dati@tuodominio.it)`. Non usare il user-agent di un browser per mimetizzarti: le fonti se ne accorgono, e un'identità chiara è ciò che permette loro di contattarti prima di bloccarti.
