---
lang: it
permalink: /it/blog/n8n-queue-mode-postgres/
title: "n8n in queue mode con Postgres: perché la tua automazione \"ogni tanto non parte\" (e come dimensionare i worker)"
date: 2026-10-11 07:30:00 +0200
author: "Antonio Trento"
description: "n8n in queue mode con Postgres e Redis: perché i webhook rispondono 200 ma le run non partono, come dimensionare i worker, il pruning delle executions, la persistenza di Redis e l'upgrade senza perdere la coda."
keywords: ["n8n queue mode postgres", "n8n worker docker", "redis bull queue", "webhook perso n8n", "scalare n8n", "n8n executions pruning"]
image: /assets/images/posts/n8n-queue-mode-postgres.jpg
pillar: stack-sovrano
related: [/it/blog/n8n-self-hosted-openai-privacy/, /it/blog/cloudflare-tunnel-raspberry-pi-n8n/]
---

## Il webhook risponde 200, ma la run non parte mai

Il sintomo che porta la gente a scrivermi è sempre lo stesso, e all'inizio sembra impossibile: "n8n riceve il webhook — vedo il 200 nei log — ma l'automazione ogni tanto non parte". Non sempre: *ogni tanto*. E quando non parte, non c'è nemmeno un errore. Il chiamante è contento (ha ricevuto 200), tu non vedi niente di rotto, e intanto un ordine non è stato processato, una notifica non è partita, un record non è stato scritto. Il classico bug che ti fa impazzire perché è intermittente e silenzioso.

Nove volte su dieci, la causa è che stai girando in **queue mode** senza averne capito il modello. In **n8n queue mode con Postgres** e Redis, il processo che riceve il webhook (il *main*) **non esegue** il workflow: lo mette in coda, e a eseguirlo è un altro processo (il *worker*). Se il worker non c'è, è morto, o è saturo, il webhook risponde 200 (il main l'ha accettato) ma la run resta in coda a marcire. "Ogni tanto non parte" è quasi sempre "il worker ogni tanto non c'è o non ce la fa".

Questo pezzo è ops n8n avanzato: come funziona davvero il queue mode (main vs worker, Redis/Bull, Postgres), perché le run spariscono, come si dimensionano i worker (e la differenza enorme tra carico CPU-bound e I/O-bound quando ci sono chiamate LLM di mezzo), il pruning delle executions che altrimenti gonfiano il DB, la persistenza di Redis e cosa perdi se lo perdi, l'idempotenza dei webhook, l'upgrade senza buttare la coda, e l'alerting. Con le variabili d'ambiente rilevanti, le query di pruning e la checklist "non parte".

È il seguito operativo di come ho montato [n8n self-hosted con attenzione alla privacy]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}): lì il setup base, qui cosa succede quando quel setup deve scalare e regge il traffico vero.

## Main vs worker: chi fa cosa (e perché conta)

n8n ha due modalità di esecuzione. In **regular mode** un solo processo fa tutto: serve l'interfaccia, riceve i webhook, fa scattare i trigger a tempo, e **esegue** i workflow. Semplice, va bene per pochi carichi. Ma un'esecuzione pesante blocca tutto il resto, e non scala oltre un processo.

In **queue mode** i ruoli si separano:

- Il **main** serve l'interfaccia, riceve i webhook, gestisce i trigger a tempo (cron/schedule) — e invece di eseguire, **mette il lavoro in coda** su Redis.
- I **worker** (uno o più processi `n8n worker`) prendono i job dalla coda Redis ed **eseguono** i workflow, leggendo e scrivendo su Postgres.
- Redis fa da **coda** (la libreria Bull sotto il cofano): tiene lo stato dei job in attesa e in corso.
- Postgres è la **fonte di verità persistente**: i workflow, le credenziali e le esecuzioni (executions) stanno lì.

La tabella dei ruoli, perché è la mappa mentale che risolve metà dei problemi:

| Componente | Fa | NON fa |
|-----------|-----|--------|
| **Main** | UI, webhook in ingresso, trigger a tempo, enqueue | non esegue i workflow di produzione |
| **Worker** | esegue i workflow, legge/scrive Postgres | non serve UI né riceve webhook |
| **Redis (Bull)** | coda dei job, stato in attesa/in corso | non conserva i workflow (transiente) |
| **Postgres** | workflow, credenziali, executions | non fa da coda |

Il punto che sblocca la comprensione: **il main accetta e mette in coda, il worker esegue.** Quando "il webhook risponde ma non parte niente", stai guardando il main (che ha fatto il suo lavoro: 200 + enqueue) e non stai guardando il worker (che non ha fatto il suo: eseguire). Il 200 non significa "eseguito": significa "accettato e messo in coda". Sono due cose diverse, ed è la fonte di gran parte della confusione.

## I sintomi: webhook 200 ma nessuna run, coda che cresce

Vediamo i sintomi tipici e cosa dicono, perché riconoscerli è metà della diagnosi.

- **Webhook 200 ma nessuna esecuzione.** Il chiamante riceve 200 (il main ha accettato ed enqueued), ma nella lista executions non compare nulla, o compare in ritardo. Causa: nessun worker attivo, worker crashato, o worker che non riesce a raggiungere Redis/Postgres. Il lavoro è nella coda, ma nessuno lo prende.
- **La coda Redis cresce senza scendere.** Se monitori la profondità della coda Bull e vedi il numero dei job "in attesa" salire e non tornare giù, i worker non stanno consumando abbastanza in fretta (o non consumano affatto). È il segnale più chiaro di un problema di worker.
- **Run in forte ritardo.** Le esecuzioni partono, ma minuti dopo il webhook. Significa che i worker sono saturi: la concorrenza è insufficiente per il picco di carico, e i job aspettano il loro turno.
- **Executions "in corso" che non finiscono mai (orphan).** Un worker è morto a metà esecuzione; il job resta in stato ambiguo. Servono il recovery dei job orfani e l'idempotenza per non fare danni al retry.
- **UI lenta, lista executions lentissima.** Il DB Postgres si è riempito di milioni di executions vecchie non prunate: le query dell'interfaccia rallentano. Sintomo di DB, non di coda.
- **I workflow schedulati non scattano.** I trigger a tempo girano sul main: se il main è mal configurato o ci sono più main che duplicano i trigger, gli schedule saltano o partono doppi.

La regola diagnostica di partenza: **separa "accettato" da "eseguito".** Il webhook 200 ti dice solo che il main ha accettato. Per sapere se è stato eseguito, guardi la coda Redis (è ancora lì in attesa?) e i worker (sono vivi? saturi?). Il 90% dei "non parte" si risolve capendo in quale di questi due punti si è fermato.

## L'architettura di riferimento

Ecco come dispongo n8n in queue mode, con i confini. Nota che main e worker sono lo *stesso* immagine Docker, avviata con comandi diversi.

```
   Webhook/Trigger ─▶ ┌───────────────────────────────┐
                      │ MAIN (n8n)                     │
                      │ UI · webhook · cron · ENQUEUE  │
                      └───────────────┬────────────────┘
                                      │ enqueue
                                      ▼
                      ┌───────────────────────────────┐
                      │ REDIS (coda Bull)              │
                      │ job in attesa / in corso       │
                      └───────┬───────────────┬────────┘
                        pull  │          pull │
                              ▼               ▼
                  ┌───────────────┐   ┌───────────────┐
                  │ WORKER 1       │   │ WORKER N       │
                  │ esegue workflow│   │ esegue workflow│
                  └───────┬───────┘   └───────┬────────┘
                          └────────┬──────────┘
                                   ▼
                      ┌───────────────────────────────┐
                      │ POSTGRES                       │
                      │ workflow · credenziali ·        │
                      │ executions (con pruning)        │
                      └───────────────────────────────┘
   Dati binari grandi → filesystem (NON nel DB)
```

**Cosa NON fa ciascun pezzo (i confini):**

- Il **main** non esegue i workflow di produzione: solo accetta ed enqueue. (In pratica è il broker.)
- I **worker** non servono UI né ricevono webhook: solo eseguono.
- **Redis** non è la fonte di verità: è coda transiente. Se lo perdi, perdi i job *in coda*, non i workflow (che sono in Postgres).
- **Postgres** non fa da coda e non deve tenere i dati binari grandi (vanno su filesystem).

Questa separazione è ciò che permette di **scalare n8n**: aggiungi worker quando serve più capacità di esecuzione, senza toccare main, Redis o Postgres.

## Le variabili d'ambiente rilevanti + docker-compose

Il queue mode si attiva e si governa con poche variabili chiave. Ecco un `docker-compose` con main, un worker, Redis e Postgres — la base da cui parto sempre.

```yaml
# docker-compose.yml — n8n queue mode (main + worker + redis + postgres)
x-n8n-env: &n8n-env
  DB_TYPE: postgresdb
  DB_POSTGRESDB_HOST: postgres
  DB_POSTGRESDB_DATABASE: n8n
  DB_POSTGRESDB_USER: n8n
  DB_POSTGRESDB_PASSWORD: ${PG_PASSWORD}
  EXECUTIONS_MODE: queue                 # <-- attiva il queue mode
  QUEUE_BULL_REDIS_HOST: redis
  QUEUE_BULL_REDIS_PORT: 6379
  N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}   # UGUALE su main e worker!
  # pruning executions (vedi sezione Postgres)
  EXECUTIONS_DATA_PRUNE: "true"
  EXECUTIONS_DATA_MAX_AGE: "336"         # ore (14 giorni)
  EXECUTIONS_DATA_PRUNE_MAX_COUNT: "50000"
  # binari fuori dal DB
  N8N_DEFAULT_BINARY_DATA_MODE: filesystem

services:
  main:
    image: n8nio/n8n:1.XX.X            # <-- versione FISSA, uguale ai worker
    command: start
    environment:
      <<: *n8n-env
      N8N_HOST: n8n.tuodominio.it
      WEBHOOK_URL: https://n8n.tuodominio.it/
    depends_on: [postgres, redis]

  worker:
    image: n8nio/n8n:1.XX.X            # <-- stessa versione del main
    command: worker --concurrency=10   # <-- job in parallelo per worker
    environment: *n8n-env
    depends_on: [postgres, redis, main]
    deploy:
      replicas: 2                       # <-- quanti worker (vedi dimensionamento)

  redis:
    image: redis:7
    command: redis-server --appendonly yes   # persistenza (vedi sezione Redis)
    volumes: [redis_data:/data]

  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: n8n
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: ${PG_PASSWORD}
    volumes: [pg_data:/var/lib/postgresql/data]

volumes: { redis_data: {}, pg_data: {} }
```

Due dettagli che, se sbagli, ti causano problemi subdoli:

- **`N8N_ENCRYPTION_KEY` deve essere identica su main e worker.** È la chiave con cui n8n cifra le credenziali. Se il worker ha una chiave diversa dal main, **non riesce a decifrare le credenziali** e le esecuzioni falliscono con errori di credenziali "sbagliate" che ti fanno impazzire. Stessa chiave ovunque.
- **`WEBHOOK_URL` corretto sul main.** È l'URL pubblico con cui n8n registra i webhook. Se è sbagliato, i servizi esterni chiamano un URL che non arriva. (Sul fronte HTTPS e i webhook pubblici, vedi il pezzo sul reverse proxy.)

## Postgres: executions, pruning, vacuum

Il problema di Postgres in n8n non è la coda (quella è Redis): è che **n8n salva ogni esecuzione nel DB**, e senza pruning il DB si gonfia fino a rendere l'interfaccia lentissima e le query pesanti. Un'installazione che gira da mesi senza pruning ha milioni di righe in `execution_entity`.

Il pruning si governa con le variabili viste sopra:

- `EXECUTIONS_DATA_PRUNE=true`: attiva la pulizia automatica.
- `EXECUTIONS_DATA_MAX_AGE`: età massima in **ore** delle executions da tenere (es. 336 = 14 giorni).
- `EXECUTIONS_DATA_PRUNE_MAX_COUNT`: numero massimo di executions da conservare.

Ma c'è una trappola specifica di Postgres che il pruning da solo non risolve: **il VACUUM.** Quando n8n prune (cancella) milioni di righe, Postgres non restituisce subito lo spazio: le righe cancellate diventano "dead tuple" finché l'autovacuum non passa. Se il DB era già enorme, servono un `VACUUM` (o `VACUUM FULL` per recuperare spazio su disco, ma blocca la tabella) e la verifica che l'**autovacuum** sia attivo e tarato. Diagnosi e pulizia manuale:

```sql
-- Quanto pesa la tabella delle executions e quante righe morte ha
SELECT
  pg_size_pretty(pg_total_relation_size('execution_entity')) AS peso,
  n_live_tup AS righe_vive,
  n_dead_tup AS righe_morte,
  last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'execution_entity';

-- Conteggio executions per stato (per capire cosa occupa)
SELECT status, COUNT(*) FROM execution_entity GROUP BY status;

-- Dopo un pruning massiccio: recupera spazio (VACUUM FULL blocca la tabella!)
-- Eseguire in finestra di manutenzione, non in orario di punta.
VACUUM (ANALYZE) execution_entity;
```

Un'altra mossa che alleggerisce molto il DB: **`N8N_DEFAULT_BINARY_DATA_MODE=filesystem`**. Di default n8n può salvare i dati binari (file, allegati, immagini che passano nei workflow) nel DB, gonfiandolo. Metterli su filesystem tiene il DB snello e veloce. Su volumi seri è quasi obbligatorio.

La regola: **il pruning tiene le executions sotto controllo, ma su Postgres devi anche pensare al VACUUM e ai binari.** Un DB n8n lento è quasi sempre executions non prunate + autovacuum che non tiene il passo + binari nel DB. Sistemati questi tre, l'UI torna reattiva.

## Redis: persistenza, e cosa succede se lo perdi

Redis è la coda. La domanda che nessuno si fa finché non succede: **cosa perdi se Redis va giù o si riavvia?**

La risposta dipende dalla persistenza:

- **Senza persistenza** (Redis in memoria pura): se Redis si riavvia o crasha, **perdi i job in coda** — quelli accettati (webhook 200) ma non ancora eseguiti. I workflow e le esecuzioni già salvate sono al sicuro in Postgres, ma il lavoro *in attesa nella coda* svanisce. Per molti casi è tollerabile (i chiamanti ritentano); per altri no.
- **Con persistenza** (AOF `--appendonly yes` e/o RDB): Redis ricostruisce la coda dopo un riavvio, riducendo la perdita. Non è perfetta (l'AOF ha una finestra di fsync), ma abbatte il rischio.

Cosa tenere a mente:

- **I workflow non sono in Redis.** Stanno in Postgres. Perdere Redis non ti fa perdere le automazioni, solo i job *in transito*.
- **La persistenza ha un costo** (I/O su disco). Per la maggior parte delle PMI, l'AOF è un buon compromesso.
- **Se perdere un job in coda è inaccettabile** (un pagamento, un ordine), la vera difesa non è solo la persistenza di Redis, ma l'**idempotenza** e il fatto che il chiamante ritenti: così anche se un job si perde, la ripetizione lo recupera senza duplicare.

Il punto onesto: **Redis è transiente per natura.** Puoi ridurre la perdita con la persistenza, ma il design robusto assume che un job in coda *possa* perdersi e si protegge con retry idempotenti a monte, non con la sola speranza che Redis non cada mai.

## Quanti worker: CPU, I/O degli LLM, concorrenza

Ecco la domanda pratica del titolo: **quanti worker, e con quale concorrenza?** La risposta dipende da *che tipo* di lavoro fanno i tuoi workflow, ed è qui che si sbaglia di più.

Due regimi opposti:

- **Carico CPU-bound** (trasformazioni dati pesanti, elaborazioni in un Function node, parsing di file grossi): il worker usa CPU davvero. La concorrenza utile è limitata dai **core** disponibili. Troppa concorrenza su pochi core = i job si contendono la CPU e vanno tutti più lenti. Regola grezza: concorrenza totale ≈ numero di core.
- **Carico I/O-bound** (il workflow chiama un LLM, un'API esterna, un DB, e **aspetta** la risposta): il worker per lo più **non fa niente, aspetta**. Qui puoi alzare molto la concorrenza, perché mentre un job aspetta la risposta dell'LLM il worker può portarne avanti altri. Un singolo worker con concorrenza alta gestisce molti job in attesa senza saturare la CPU.

La distinzione è cruciale per gli agenti: **una run che chiama un LLM passa gran parte del tempo ad aspettare il modello.** Se tratti quel carico come CPU-bound e metti concorrenza bassa, sprechi capacità: i worker stanno fermi ad aspettare mentre la coda cresce. Alzi la concorrenza (`--concurrency`) e lo stesso worker regge molti più job in attesa.

Come si dimensiona in pratica:

- La **parallelizzazione totale** = numero di worker × concorrenza per worker. Tara questo numero sul tuo **picco** di job simultanei, non sulla media.
- **Osserva la profondità della coda** sotto carico reale: se cresce e non scende, aumenta capacità (più concorrenza per I/O-bound, più worker/core per CPU-bound).
- **Attento ai limiti a valle.** Se i workflow chiamano un'API con rate limit (o un LLM self-hosted con VRAM limitata che serve poche richieste in parallelo), alzare la concorrenza oltre quel limite non aiuta: sposti solo la coda da n8n al servizio a valle, che inizia a dare 429. La concorrenza va tarata sul collo di bottiglia reale.

La regola: **conta i core per il CPU-bound, conta le attese per l'I/O-bound, e in entrambi i casi guarda la profondità della coda per validare.** Non esiste un "numero di worker giusto" universale: esiste quello giusto per il tuo mix di carico e per i limiti dei servizi che chiami.

## Idempotenza dei webhook

Torna il tema che attraversa tutta l'automazione seria: **l'idempotenza.** In queue mode, un webhook può portare a un'esecuzione ripetuta per più motivi: il chiamante ritenta (non ha ricevuto la risposta in tempo), un worker muore a metà e il job viene ripreso, o un problema di rete duplica la consegna. Se il tuo workflow ha side effect (scrive un record, invia un'email, muove soldi), la ripetizione fa danni: doppio ordine, doppia email, doppio pagamento.

La difesa: **ogni evento ha un identificatore stabile, e il workflow controlla se l'ha già processato prima di agire.**

- Il chiamante manda un **ID evento** (o lo derivi da campi stabili del payload).
- Il primo nodo del workflow verifica in una tabella/cache se quell'ID è già stato processato. Se sì, esce senza rifare il side effect.
- Se no, processa e registra l'ID come "fatto".

Questo rende l'esecuzione **sicura da ripetere**, che è esattamente ciò che serve quando la coda, per sua natura, può consegnare un job più di una volta. È lo stesso principio che ho descritto per le scritture su CRM e per i retry degli agenti: in un sistema con code e retry, l'idempotenza non è un extra, è un requisito. Senza, ogni riavvio di worker o ritentativo del chiamante è una potenziale duplicazione.

## Upgrade delle versioni senza perdere la coda

Aggiornare n8n in queue mode ha una trappola: se lo fai male, perdi i job in coda o rompi la compatibilità tra main e worker. Le regole:

- **Main e worker devono avere la STESSA versione.** Una versione disallineata tra chi enqueue e chi esegue può causare job che il worker non sa processare, o errori sottili. Aggiorni tutto insieme, alla stessa versione fissata.
- **Fissa la versione dell'immagine** (`n8nio/n8n:1.XX.X`), non `latest`. Con `latest`, un `docker compose pull` può portarti main e worker a versioni diverse in momenti diversi, o aggiornarti a una major con breaking change senza volerlo.
- **Drena la coda prima dell'upgrade.** La sequenza pulita: smetti di accettare nuovo lavoro (ferma il main o metti in pausa i trigger), lascia che i worker finiscano i job in corso (coda che scende a zero), poi aggiorna tutto e riavvia. Così nessun job resta a metà tra due versioni.
- **Le migrazioni del DB girano all'avvio del main.** Postgres viene migrato quando il main parte con la nuova versione: assicurati che il main parta *per primo* e completi le migrazioni prima che i worker (nuova versione) si colleghino. Fai un **backup di Postgres prima** di ogni upgrade di versione: le migrazioni sono raramente reversibili.

La sequenza che uso:

1. Backup di Postgres (e, se ti importa, snapshot del volume Redis).
2. Metti in pausa i trigger / ferma l'ingresso di nuovi webhook.
3. Aspetta che la coda scenda a zero (worker che finiscono).
4. Ferma worker e main.
5. Aggiorna l'immagine (stessa versione fissa per tutti).
6. Avvia il main → completa le migrazioni DB.
7. Avvia i worker → riprendi i trigger.

Fatto così, l'upgrade non perde lavoro e non lascia job orfani tra versioni diverse. Fatto "aggiorno e riavvio tutto insieme con latest", prima o poi perdi una coda o ti ritrovi con un breaking change in produzione.

## Percorso di implementazione, a step

1. **Passa a queue mode:** `EXECUTIONS_MODE=queue`, con Redis e Postgres configurati; main con `start`, worker con `worker`.
2. **Chiave di cifratura uguale** su main e worker (`N8N_ENCRYPTION_KEY`), e `WEBHOOK_URL` corretto sul main.
3. **Avvia almeno un worker** e verifica che le run partano davvero (non solo il 200 del webhook).
4. **Configura il pruning** delle executions (età + conteggio massimo) e metti i binari su filesystem.
5. **Verifica l'autovacuum** di Postgres e fai un VACUUM se il DB era già gonfio.
6. **Attiva la persistenza di Redis** (AOF) se perdere job in coda è un problema.
7. **Dimensiona worker e concorrenza** sul tuo mix di carico (CPU vs I/O), validando con la profondità della coda.
8. **Rendi idempotenti i workflow con side effect**, con un ID evento e un controllo di deduplica.
9. **Fissa le versioni delle immagini** e definisci la procedura di upgrade con drenaggio della coda.
10. **Metti l'alerting** su profondità coda, liveness dei worker e crescita del DB.

## I fallimenti tipici e come li riconosci dai log

- **Webhook 200, nessuna run.** Guarda i worker: sono avviati? Nei loro log vedi "started"? Se non ci sono worker o sono in crash loop, i job restano in coda. Controlla la profondità della coda Redis: se cresce, è confermato.
- **Worker con errori di credenziali.** Nei log del worker, errori di decifratura o "credential not found": quasi sempre `N8N_ENCRYPTION_KEY` diversa tra main e worker. Allineala.
- **Worker non si collega a Redis/Postgres.** Log con connection refused/timeout verso Redis o Postgres: rete Docker, host o password sbagliati. Il worker parte ma non prende job (o non li salva).
- **Coda che cresce sotto carico.** Concorrenza insufficiente per il picco, o collo di bottiglia a valle (rate limit dell'API/LLM che i workflow chiamano). Aumenta concorrenza/worker oppure risolvi il limite a valle — guardando *dove* si accumula.
- **UI e lista executions lentissime.** DB gonfio: executions non prunate, autovacuum indietro, binari nel DB. Controlla `pg_stat_user_tables` per `execution_entity` e le righe morte.
- **Executions "running" che non finiscono.** Worker morto a metà: job orfani. Servono recovery e idempotenza per il retry. Log del worker che si interrompe bruscamente (OOM?) sono l'indizio.
- **Schedule doppi o mancanti.** Più main attivi che duplicano i trigger, o main mal configurato. In queue mode i trigger a tempo devono avere un solo main responsabile.

La regola: **quando "non parte", guarda in quest'ordine — worker vivo? coda che cresce? worker collegato a Redis e Postgres? chiave di cifratura allineata?** In quest'ordine risolvi la stragrande maggioranza dei casi.

## Alerting sulle code

Un sistema a coda senza alerting è un sistema che scopri rotto quando si lamenta un cliente. Le metriche da sorvegliare, con la soglia che conta:

- **Profondità della coda (job in attesa).** La metrica regina. Se cresce e non torna giù, i worker non tengono il passo (morti, saturi, o collo di bottiglia a valle). Allarme se supera una soglia per più di N minuti.
- **Liveness dei worker.** Almeno un worker deve essere vivo e connesso. Zero worker attivi con webhook in arrivo = tutte le run in coda a marcire. Allarme immediato.
- **Tasso di fallimento delle executions.** Un picco di executions fallite segnala un problema a valle o un workflow rotto.
- **Job orfani / "running" da troppo tempo.** Esecuzioni ferme in stato "running" oltre una durata plausibile = worker morto a metà.
- **Crescita del DB Postgres.** Se la dimensione di `execution_entity` cresce oltre soglia, il pruning non sta funzionando.

```sql
-- Segnale per alerting: executions in attesa/bloccate e failure recenti
SELECT
  COUNT(*) FILTER (WHERE status = 'running'
                   AND "startedAt" < now() - interval '15 min') AS running_troppo,
  COUNT(*) FILTER (WHERE status = 'error'
                   AND "stoppedAt" > now() - interval '1 hour')  AS errori_ultima_ora
FROM execution_entity;
```

La profondità della coda Bull la leggi da Redis (i job in stato "wait"/"active"); un semplice check periodico che conta i job in attesa e allerta oltre soglia è il singolo indicatore più utile per "l'automazione non parte". Come per l'osservabilità degli agenti: **allarma sulla tendenza aggregata (coda che cresce), non sul singolo evento**, e includi nel messaggio quale coda e quanto è profonda.

## Costi: ordini di grandezza

Stime dichiarate.

- **Infrastruttura:** main + worker + Redis + Postgres girano bene su un singolo server/VPS di fascia media in UE per i carichi di una PMI. Come ordine di grandezza, decine di euro al mese di server; scala aggiungendo core/RAM o worker quando il carico cresce.
- **Redis:** consumo di RAM proporzionale ai job in coda (tipicamente modesto) più il disco per l'AOF se attivi la persistenza. Trascurabile per volumi normali.
- **Postgres:** con il pruning attivo e i binari su filesystem, resta contenuto. Senza pruning cresce senza limite: il "costo" è l'UI che rallenta e il disco che si riempie.
- **Worker aggiuntivi:** ogni worker è un processo con il suo consumo di RAM/CPU. Il costo di scalare è lineare e prevedibile: più worker/core = più capacità di esecuzione. Per carichi I/O-bound (LLM) spesso basta alzare la concorrenza senza aggiungere hardware.
- **Costo del non farlo bene:** run perse silenziosamente (ordini non processati), UI inutilizzabile per DB gonfio, o duplicazioni da mancanza di idempotenza. Tutti costi operativi e di fiducia superiori al tempo di configurare il queue mode come si deve.

## Quando NON farlo

- **Se hai pochi workflow e poco traffico**, il queue mode è complessità inutile: il regular mode (processo singolo) è più semplice da gestire e ti basta. Passa a queue mode quando il carico o il bisogno di scalare lo giustificano, non per moda.
- **Se non puoi gestire Redis e Postgres** come componenti seri (backup, persistenza, monitoraggio), il queue mode aggiunge pezzi che, trascurati, diventano punti di rottura. Meglio un regular mode ben tenuto che un queue mode abbandonato.
- **Se i tuoi workflow non sono idempotenti** e hanno side effect, non scalare i worker prima di aver risolto l'idempotenza: aumenteresti solo la probabilità di duplicazioni sotto carico.
- **Se il collo di bottiglia è a valle** (un'API con rate limit stretto, un LLM che serve poche richieste in parallelo), aggiungere worker non risolve: sposti solo la coda. Prima allarga il collo di bottiglia reale.
- **Se non metti l'alerting sulla coda**, il queue mode ti nasconde i problemi (il 200 ti illude che vada tutto bene). Senza visibilità sulla coda, stai peggio che in regular mode.

## Checklist "non parte" (quando il webhook risponde 200 ma la run manca)

- [ ] **C'è almeno un worker vivo?** Log del worker: avviato e connesso.
- [ ] **La coda Redis cresce?** Conta i job in attesa: se salgono, i worker non consumano.
- [ ] **Il worker raggiunge Redis e Postgres?** Nessun connection refused/timeout nei log.
- [ ] **`N8N_ENCRYPTION_KEY` è uguale** su main e worker? (Errori di credenziali = quasi sempre questo.)
- [ ] **`EXECUTIONS_MODE=queue`** impostato su tutti i processi?
- [ ] **Concorrenza sufficiente** per il picco? La coda scende dopo i picchi?
- [ ] **Collo di bottiglia a valle?** L'API/LLM che il workflow chiama sta dando 429/timeout?
- [ ] **Job orfani** in stato "running" da un worker morto? Recovery + idempotenza.
- [ ] **Trigger a tempo** gestiti da un solo main (no schedule duplicati o mancanti)?

## Checklist operativa prima di andare in produzione

- [ ] **Queue mode** attivo con Redis e Postgres; main (`start`) e worker (`worker`) separati.
- [ ] **Chiave di cifratura identica** su main e worker; `WEBHOOK_URL` corretto.
- [ ] **Almeno un worker** verificato: le run partono, non solo il 200.
- [ ] **Pruning executions** configurato (età + max count); **binari su filesystem**.
- [ ] **Autovacuum** attivo; VACUUM fatto se il DB era gonfio.
- [ ] **Persistenza Redis** (AOF) se i job in coda non possono perdersi.
- [ ] **Worker e concorrenza dimensionati** sul mix di carico (CPU vs I/O), validati con la profondità coda.
- [ ] **Workflow idempotenti** dove ci sono side effect.
- [ ] **Versioni immagini fissate**; procedura di upgrade con drenaggio della coda e backup DB.
- [ ] **Alerting** su profondità coda, liveness worker, failure rate, crescita DB.

## Il verdetto

Il **queue mode di n8n con Postgres** è ciò che trasforma n8n da giocattolo a piattaforma di automazione che regge il traffico vero — ma porta con sé un modello mentale che, se non lo capisci, ti fa impazzire. Il main accetta ed enqueue; il worker esegue. Il webhook che risponde 200 non significa "eseguito": significa "messo in coda". Quando "ogni tanto non parte", quasi sempre è il worker che ogni tanto non c'è, è morto, o è saturo — e lo scopri guardando la coda Redis e i worker, non il main.

Il resto è disciplina ops: pruning delle executions e VACUUM per non far gonfiare Postgres, binari fuori dal DB, persistenza di Redis calibrata sul rischio, worker e concorrenza dimensionati sul *tipo* di carico (conta i core per il CPU-bound, conta le attese per l'I/O-bound degli LLM), idempotenza per sopravvivere ai retry che una coda inevitabilmente produce, upgrade con drenaggio e versioni allineate, e alerting sulla profondità della coda perché è il primo indicatore che qualcosa non gira. Con questi in ordine, l'automazione parte sempre, scala quando serve, e non ti nasconde i problemi dietro un 200 rassicurante.

Fatto così, hai una piattaforma sovrana che processa il tuo lavoro in modo affidabile e osservabile. Fatto senza capire main vs worker, hai un sistema che risponde 200 e perde silenziosamente le run — il tipo di bug che erode la fiducia nell'automazione. La differenza non è n8n: è se hai capito chi accetta e chi esegue, e hai messo gli occhi sulla coda in mezzo.

Se hai n8n in produzione che "ogni tanto non parte", o stai per passare al queue mode per scalare, e vuoi dimensionarlo e renderlo affidabile, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Ops n8n concreta, non slide.

## FAQ

### Perché il webhook risponde 200 ma il workflow non parte?
Perché in queue mode il processo che riceve il webhook (il main) non esegue il workflow: lo mette in coda su Redis. Il 200 significa "accettato e messo in coda", non "eseguito". A eseguire è il worker. Se non c'è un worker attivo, è crashato, o è saturo, il job resta in coda e la run non parte, pur avendo risposto 200. Guarda i worker e la profondità della coda, non il main.

### Qual è la differenza tra main e worker?
Il main serve l'interfaccia, riceve i webhook, fa scattare i trigger a tempo e mette il lavoro in coda. Il worker prende i job dalla coda ed esegue i workflow, leggendo e scrivendo su Postgres. Sono la stessa immagine Docker avviata con comandi diversi (`start` vs `worker`). In queue mode il main non esegue i workflow di produzione: fa il broker. Questa separazione è ciò che permette di scalare aggiungendo worker.

### Cosa perdo se Redis va giù?
I job in coda, cioè quelli accettati ma non ancora eseguiti. I workflow, le credenziali e le esecuzioni già salvate sono in Postgres e restano al sicuro. Con la persistenza di Redis (AOF) riduci la perdita, perché la coda si ricostruisce dopo un riavvio. Ma il design robusto assume che un job in coda possa perdersi e si protegge con retry idempotenti a monte: se un job si perde, la ripetizione del chiamante lo recupera senza duplicare.

### Quanti worker mi servono?
Dipende dal tipo di carico. Per lavori CPU-bound (trasformazioni pesanti), la concorrenza utile è limitata dai core: concorrenza totale ≈ numero di core. Per lavori I/O-bound (il workflow aspetta un LLM o un'API), puoi alzare molto la concorrenza, perché il worker per lo più aspetta e può portare avanti più job insieme. Dimensiona sul picco, non sulla media, e valida guardando se la profondità della coda scende dopo i picchi.

### Come dimensiono la concorrenza per i workflow che chiamano LLM?
Le run che chiamano un LLM passano gran parte del tempo ad aspettare la risposta, quindi sono I/O-bound: alza la concorrenza per worker così lo stesso worker regge molti job in attesa senza saturare la CPU. Attenzione però al limite a valle: se l'LLM self-hosted serve poche richieste in parallelo (VRAM limitata) o l'API ha un rate limit, alzare la concorrenza oltre quel limite sposta solo la coda sul servizio a valle, che inizia a dare 429. Tara sul collo di bottiglia reale.

### Perché l'interfaccia di n8n è diventata lentissima?
Quasi sempre perché il database Postgres si è gonfiato di executions vecchie non prunate. Attiva il pruning (`EXECUTIONS_DATA_PRUNE` con età e conteggio massimo), verifica che l'autovacuum di Postgres tenga il passo (dopo grandi cancellazioni servono VACUUM e ANALYZE), e sposta i dati binari su filesystem invece che nel DB. Questi tre interventi riportano l'UI reattiva. Controlla `execution_entity` in `pg_stat_user_tables` per righe vive e morte.

### Devo attivare la persistenza di Redis?
Se perdere i job in coda (accettati ma non ancora eseguiti) è un problema, sì: attiva l'AOF. Se i chiamanti ritentano e i workflow sono idempotenti, puoi anche tollerare la perdita di qualche job in coda, perché la ripetizione lo recupera. Ricorda che i workflow non sono in Redis ma in Postgres, quindi perdere Redis non ti fa perdere le automazioni, solo il lavoro in transito. Per la maggior parte delle PMI l'AOF è un buon compromesso.

### Come aggiorno n8n senza perdere la coda?
Fissa la versione dell'immagine (non `latest`) e tieni main e worker sulla stessa versione. La sequenza pulita: backup di Postgres, metti in pausa i trigger e l'ingresso di nuovi webhook, aspetta che la coda scenda a zero mentre i worker finiscono, ferma tutto, aggiorna all'immagine nuova, avvia prima il main (che esegue le migrazioni del DB), poi i worker. Così nessun job resta a metà tra due versioni e non perdi lavoro.

### Perché i miei workflow schedulati partono doppi (o non partono)?
I trigger a tempo girano sul main. Se hai più processi main attivi, possono duplicare gli schedule; se il main è mal configurato, gli schedule saltano. In queue mode assicurati che ci sia un solo main responsabile dei trigger a tempo. I worker non gestiscono i trigger: eseguono soltanto i job che il main mette in coda.

### Il queue mode serve sempre?
No. Se hai pochi workflow e poco traffico, il regular mode (processo singolo) è più semplice e ti basta. Il queue mode ha senso quando devi scalare l'esecuzione, isolare i carichi pesanti dall'interfaccia, o reggere picchi di webhook. Porta con sé Redis, worker e più pezzi da gestire: adottalo quando il carico lo giustifica, non per moda. Un regular mode ben tenuto batte un queue mode trascurato.
