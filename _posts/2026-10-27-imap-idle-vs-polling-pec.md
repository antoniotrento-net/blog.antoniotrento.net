---
lang: it
permalink: /it/blog/imap-idle-vs-polling-pec/
title: "IMAP IDLE vs polling ogni 30 secondi: come non farti chiudere la PEC dal provider mentre l'agente “ascolta” la posta"
date: 2026-10-27 07:30:00 +0200
author: "Antonio Trento"
description: "IMAP IDLE vs polling per agenti che leggono la PEC: cosa fa IDLE e quando il server lo taglia, costi del polling, limiti dei provider, reconnect e duplicati, una o quaranta caselle, backoff con jitter, monitor last_idle_at, state machine ed errori IMAP comuni."
keywords: ["imap idle vs polling pec", "imap connection limit", "pec timeout", "backoff email agent", "aruba imap", "imap idle python"]
image: /assets/images/posts/imap-idle-vs-polling-pec.jpg
pillar: integrazioni-dati
related: [/it/blog/agente-imap-pec-fatture/, /it/blog/human-in-the-loop-pec-sepa/]
---

## L'agente che "ascolta" e la casella che smette di rispondere

Il sistema funziona da un mese. Un piccolo servizio legge la casella PEC dello studio, riconosce fatture, avvisi, comunicazioni di enti e notifiche, e le passa all'agente che le classifica e prepara le bozze di lavoro. Per essere reattivo, il servizio controlla la casella **ogni 30 secondi**: si collega, fa login, cerca i messaggi nuovi, si scollega. Poi, una mattina, niente: nessun messaggio elaborato dalla notte. Nei log, una fila di errori di autenticazione e poi di connessione rifiutata. Il provider ha rilevato un comportamento anomalo — migliaia di login al giorno dallo stesso indirizzo — e ha applicato un blocco temporaneo. Nel frattempo, in quella casella, è arrivata una comunicazione con una scadenza.

In un secondo studio, il servizio usa **IMAP IDLE**, la modalità in cui il server avvisa il client quando arriva un messaggio. Niente login continui. Ma dopo qualche giorno qualcuno nota che le PEC vengono elaborate con ore di ritardo. Il processo è vivo, la connessione risulta aperta, il log non mostra errori: la connessione era stata chiusa in silenzio da qualche parte nella rete, e il client aspettava notifiche che non sarebbero mai arrivate.

Sono i due modi classici di sbagliare la stessa cosa: far "ascoltare" la posta a un agente. Questo pezzo è molto stretto, e volutamente: è **email ops**. Parliamo di come funziona IDLE e quando il server lo interrompe, quanto costa davvero il polling, dei limiti che i provider PEC applicano (spesso senza documentarli), di reconnect e duplicati, di come gestire una casella o quaranta, di backoff con jitter, di come monitorare che l'ascolto sia davvero vivo e di quale scelta fare nei due casi estremi. Con una state machine di riconnessione, valori di timeout di esempio e gli errori IMAP che vedrai più spesso.

Sul resto della pipeline — riconoscere e processare fatture e comunicazioni PEC — rimando al pezzo sull'[agente IMAP che legge PEC e fatture]({{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}). Qui ci occupiamo solo del tubo.

## Cosa fa IDLE e quando il server lo taglia

IMAP è un protocollo a sessione: il client apre una connessione (per la PEC sempre cifrata, tipicamente IMAPS sulla porta 993), si autentica, seleziona una cartella e invia comandi. Senza estensioni, il server risponde ai comandi ma non prende iniziative: per sapere se ci sono messaggi nuovi, il client deve chiedere.

L'estensione **IDLE** (RFC 2177), supportata dalla grande maggioranza dei server moderni, cambia le cose. Il client invia il comando `IDLE`; il server risponde con una conferma di continuazione e da quel momento può inviare **notifiche non richieste** quando lo stato della cartella cambia: `* 23 EXISTS` quando arriva un messaggio, `* 5 EXPUNGE` quando uno viene eliminato, `* 7 FETCH (FLAGS ...)` quando cambiano i flag. Il client resta in ascolto; quando vuole fare altro, invia `DONE`, il server chiude il comando IDLE, e il client può inviare altri comandi (per esempio scaricare il messaggio nuovo) prima di rientrare in IDLE.

```
C: a1 LOGIN ...                 S: a1 OK
C: a2 SELECT INBOX              S: * 22 EXISTS ... a2 OK [READ-WRITE]
C: a3 IDLE                      S: + idling
                                   ... (minuti di silenzio) ...
                                S: * 23 EXISTS                <- è arrivato un messaggio
C: DONE                         S: a3 OK IDLE terminated
C: a4 UID SEARCH UID 1045:*     S: * SEARCH 1045   a4 OK
C: a5 UID FETCH 1045 (BODY.PEEK[])  ...
C: a6 IDLE                      S: + idling                   <- si rientra in ascolto
```

IDLE è efficiente: una sola connessione aperta, nessun login ripetuto, notifica quasi immediata. Ma **una connessione aperta a lungo può essere chiusa** da diversi soggetti, e non sempre in modo visibile:

- **Il server**, per timeout di inattività. La specifica IMAP prevede che un server possa disconnettere un client inattivo dopo almeno 30 minuti; per questo la RFC di IDLE raccomanda al client di **interrompere e rinnovare l'IDLE almeno ogni 29 minuti**. Molti server applicano limiti più brevi, o chiudono le sessioni per manutenzione, riavvii, bilanciamento del carico.
- **Il provider**, per politica: durata massima della sessione, numero massimo di connessioni simultanee, limiti per indirizzo IP.
- **La rete in mezzo**: firewall, NAT, router domestici e bilanciatori che eliminano le connessioni TCP "silenziose" dopo un certo tempo, spesso senza inviare nulla a nessuna delle due parti. È il caso peggiore: il client crede di essere connesso, il server ha già dimenticato la sessione.

Quando il server chiude in modo pulito, il client riceve qualcosa come `* BYE Autologout; idle for too long` e poi la chiusura della connessione: facile da gestire. Quando la connessione muore a metà strada, il client **non riceve niente**. Da qui la regola più importante di tutto l'articolo: **un client IDLE non deve mai aspettare notifiche all'infinito**. Deve avere un proprio timer, interrompere l'IDLE periodicamente con `DONE`, verificare che la sessione risponda (anche con un semplice `NOOP`) e rientrare in ascolto. Se la risposta non arriva entro un timeout, la connessione è morta: si chiude e si riconnette.

### Valori di timeout di esempio

Valori ragionevoli da cui partire, da adattare dopo aver osservato il comportamento del tuo provider:

| Parametro | Valore di esempio | Motivo |
|-----------|-------------------|--------|
| Rinnovo IDLE (DONE + NOOP + IDLE) | ogni 9–14 minuti | ampio margine sotto i 29 minuti e sotto i timeout tipici di NAT e firewall |
| Timeout di lettura durante IDLE | rinnovo + 60 s | se non arriva nulla nemmeno al rinnovo, la connessione è morta |
| Timeout per comandi normali | 30–60 s | un `FETCH` di una PEC con allegati può richiedere qualche secondo |
| Timeout di connessione TCP/TLS | 15–20 s | oltre, il server è irraggiungibile o sovraccarico |
| TCP keepalive del sistema | attivo, primo probe dopo 60–120 s | aiuta a tenere viva la connessione nei NAT e a rilevare peer morti |
| Riconciliazione completa | ogni 15–30 minuti e a ogni riconnessione | recupera ciò che una notifica persa non ha segnalato |

Il valore di rinnovo di 29 minuti suggerito dalla RFC è un **massimo**, non un obiettivo: nella pratica, con NAT e firewall in mezzo, rinnovare più spesso evita la maggior parte delle disconnessioni silenziose.

## Polling: CPU, rate, ritardo di classificazione

L'alternativa a IDLE è il **polling**: a intervalli regolari il client controlla se ci sono messaggi nuovi. Ci sono due modi molto diversi di farlo, e la differenza è decisiva.

**Polling con login a ogni ciclo** (quello del primo studio): connessione, TLS, login, SELECT, ricerca, logout. Ogni 30 secondi sono **2.880 login al giorno** per una sola casella. Per il provider è indistinguibile da un tentativo di forzare la password o da un client impazzito, e i sistemi antiabuso reagiscono: rallentamenti, blocchi temporanei, a volte la sospensione dell'accesso IMAP per la casella o per l'indirizzo IP. È il modo più rapido per farsi chiudere la PEC.

**Polling su sessione persistente**: una connessione resta aperta, e a intervalli regolari il client invia un `NOOP` (che su molti server fa emergere le notifiche di nuovi messaggi) o una ricerca per UID superiori all'ultimo visto. Nessun login ripetuto, carico modesto. È una scelta perfettamente rispettabile, soprattutto quando IDLE non è disponibile o non è affidabile.

I costi del polling, in concreto:

- **Carico**: minimo sul client, ma moltiplicato per il numero di caselle e per la frequenza; sul server, ogni ciclo è una ricerca sulla cartella.
- **Ritardo**: in media metà dell'intervallo. Con un polling ogni 5 minuti, una PEC arriva all'agente dopo 2,5 minuti in media, 5 nel caso peggiore.
- **Il ritardo di classificazione conta meno di quanto sembri.** Una PEC di un ente o una fattura non richiede una reazione in secondi: richiede di non essere persa e di essere elaborata entro minuti o ore. Un polling ogni 2–5 minuti su sessione persistente è, per la maggior parte degli studi e delle PMI, più che sufficiente.

La domanda da porsi non è "come faccio ad avere le PEC in tempo reale?", ma "qual è il ritardo massimo accettabile tra l'arrivo di una PEC e la sua presa in carico?". Se la risposta è "qualche minuto", il polling ben fatto è una scelta legittima e più semplice da rendere robusta. Se è "pochi secondi" — raro, per la PEC — serve IDLE.

## Limiti tipici dei provider PEC

I provider PEC italiani — Aruba, InfoCert Legalmail, Namirial, Register e gli altri gestori accreditati — offrono accesso IMAP e POP3 alle caselle, con server e porte indicati nella loro documentazione (per esempio `imaps.pec.aruba.it` sulla porta 993 per Aruba). I **limiti** che applicano, invece, sono raramente documentati in modo completo, e possono cambiare. Le categorie da conoscere:

- **Connessioni simultanee per casella**: spesso poche. Un client di posta sul PC, uno sul telefono e il servizio dell'agente possono già esaurirle, e la connessione in eccesso viene rifiutata o provoca la chiusura di un'altra.
- **Connessioni per indirizzo IP**: rilevanti quando da un solo server si gestiscono molte caselle. Quaranta caselle su un IP possono superare una soglia che per una casella non si vedrebbe mai.
- **Frequenza di login**: il limite che colpisce il polling con login continui.
- **Tentativi di autenticazione falliti**: dopo alcuni errori (password cambiata e non aggiornata nel servizio, per esempio), blocchi temporanei della casella o dell'IP.
- **Durata massima della sessione e timeout di inattività**, che interrompono anche un IDLE ben gestito.
- **Volume di download**: scaricare ripetutamente messaggi con allegati pesanti può incontrare limiti di banda.

Dato che i valori precisi non sono sempre pubblici, la strategia corretta è **comportarsi come un buon client**: una connessione per casella, nessun login inutile, riconnessioni con backoff, niente tempeste di tentativi dopo un errore. E osservare: i log del servizio ti diranno, dopo qualche settimana, quanto dura in media una sessione con il tuo provider e con quali errori si chiude. Se hai un contratto business, chiedere al supporto del provider i limiti applicati è una domanda legittima e spesso ottiene una risposta.

Due particolarità della PEC da tenere presenti:

- **La casella contiene anche le ricevute**: accettazione, consegna, eventuali mancate consegne dei messaggi inviati. Possono essere molte, e vanno elaborate o almeno filtrate, non ignorate.
- **La conservazione**: molti gestori prevedono uno spazio limitato e procedure di archiviazione. Un servizio che scarica ma non gestisce la cartella non deve spostare o cancellare messaggi senza una politica chiara: la PEC ha valore legale, e la sua conservazione va progettata, non subita.

## La state machine di riconnessione

Il cuore di un "ascoltatore" robusto è una macchina a stati esplicita. Scriverla così, invece che come un ciclo con qualche `try/except`, rende evidenti i casi che altrimenti si dimenticano.

```
                ┌──────────────┐
      avvio ───►│ DISCONNESSO  │◄──────────────────────────────────────────┐
                └──────┬───────┘                                            │
                       │ connetti (timeout 20s)                             │
                       ▼                                                    │
                ┌──────────────┐  errore auth ──► BLOCCATO_AUTH (stop +     │
                │ AUTENTICANDO │                   allarme, NESSUN retry)   │
                └──────┬───────┘                                            │
                       │ ok                                                 │
                       ▼                                                    │
                ┌──────────────┐  UIDVALIDITY cambiata ──► RISINCRONIZZA    │
                │ SINCRONIZZA  │  (UID > ultimo_uid, per casella)           │
                └──────┬───────┘                                            │
                       │ fatto                                              │
                       ▼                                                    │
                ┌──────────────┐  EXISTS ──► DONE ──► SINCRONIZZA           │
                │    IDLE      │  timer rinnovo ──► DONE ──► NOOP ──► IDLE  │
                └──────┬───────┘                                            │
                       │ BYE / EOF / timeout / errore rete                  │
                       ▼                                                    │
                ┌──────────────┐                                            │
                │   ATTESA     │ backoff esponenziale + jitter ─────────────┘
                │   BACKOFF    │ (1s, 2s, 4s … max 5 min; reset dopo 10 min stabili)
                └──────────────┘
```

Tre stati meritano attenzione:

- **BLOCCATO_AUTH**: un errore di autenticazione **non** va ritentato in loop. Se la password è cambiata o scaduta, ogni tentativo è un login fallito in più, e dopo pochi tentativi il provider blocca la casella. Si ferma tutto e si avvisa una persona.
- **SINCRONIZZA**: dopo ogni (ri)connessione, prima di entrare in IDLE, si recupera tutto ciò che è arrivato mentre si era disconnessi. Le notifiche di IDLE valgono solo per ciò che accade **durante** la sessione.
- **ATTESA BACKOFF**: tra un tentativo fallito e il successivo si aspetta un tempo crescente, con una componente casuale. Ne parliamo tra poco.

Un'implementazione compatta in Python, con la libreria `imapclient` (che espone IDLE in modo comodo; nelle versioni più recenti anche la libreria standard `imaplib` ha aggiunto il supporto a IDLE):

```python
import random, socket, time, logging
from imapclient import IMAPClient
from imapclient.exceptions import LoginError

log = logging.getLogger("pec")
RINNOVO_IDLE = 12 * 60          # secondi
TIMEOUT_CMD = 60
BACKOFF_MAX = 300

class AuthBloccata(Exception): ...

def ascolta(casella, stato, elabora):
    tentativi = 0
    while True:
        try:
            with IMAPClient(casella.host, port=993, ssl=True, timeout=TIMEOUT_CMD) as c:
                c.socket().setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
                try:
                    c.login(casella.utente, casella.password())
                except LoginError as e:
                    raise AuthBloccata(str(e))
                info = c.select_folder("INBOX")
                sincronizza(c, casella, stato, info[b"UIDVALIDITY"], elabora)
                connesso_dal = time.monotonic()
                while True:
                    c.idle()
                    risposte = c.idle_check(timeout=RINNOVO_IDLE)   # ritorna su notifica o timeout
                    c.idle_done()
                    stato.segna_idle(casella.id)                   # -> last_idle_at
                    if any(r[1] == b"EXISTS" for r in risposte if len(r) > 1):
                        sincronizza(c, casella, stato, info[b"UIDVALIDITY"], elabora)
                    else:
                        c.noop()                                   # la sessione risponde?
                    if time.monotonic() - connesso_dal > 600:
                        tentativi = 0                              # connessione stabile: reset backoff
        except AuthBloccata as e:
            log.critical("auth fallita su %s: STOP, serve intervento umano (%s)", casella.id, e)
            stato.segna_bloccata(casella.id, str(e))
            return
        except (OSError, EOFError, TimeoutError, IMAPClient.AbortError, IMAPClient.Error) as e:
            tentativi += 1
            attesa = min(BACKOFF_MAX, 2 ** min(tentativi, 9)) * random.uniform(0.5, 1.0)
            log.warning("%s: %s — riconnessione tra %.0fs (tentativo %d)",
                        casella.id, type(e).__name__, attesa, tentativi)
            stato.segna_errore(casella.id, type(e).__name__)
            time.sleep(attesa)
```

Il codice è volutamente semplice: una casella, una connessione, un ciclo. La funzione `sincronizza` è quella che evita i duplicati e le perdite, ed è l'argomento della prossima sezione.

## Reconnect e duplicati

Ogni riconnessione porta con sé due rischi opposti: **perdere** messaggi arrivati durante la disconnessione, ed **elaborare due volte** messaggi già visti. Entrambi si evitano con lo stesso strumento: uno stato persistente basato sugli **UID**.

In IMAP ogni messaggio in una cartella ha un **UID**, un identificativo numerico che il server assegna in ordine crescente e che non cambia finché resta valida la **UIDVALIDITY** della cartella (un valore che il server comunica alla SELECT e che cambia solo in casi eccezionali, come la ricostruzione della casella). La coppia (UIDVALIDITY, UID) identifica un messaggio in modo stabile.

La logica di sincronizzazione:

1. Per ogni casella si memorizzano, in un database, **UIDVALIDITY** e **ultimo UID elaborato**.
2. Alla (ri)connessione e a ogni notifica, si cercano i messaggi con UID maggiore dell'ultimo elaborato (`UID SEARCH UID n+1:*`; attenzione: se non ci sono messaggi nuovi, molti server restituiscono comunque l'ultimo messaggio esistente, che va scartato perché già visto).
3. Ogni messaggio si registra come elaborato **in modo idempotente**: una tabella con chiave unica (casella, UIDVALIDITY, UID) — e, per sicurezza, anche l'identificativo del messaggio, che nelle PEC è presente nei dati di certificazione (il file `daticert.xml` della busta di trasporto) oltre al `Message-ID`. Se l'inserimento fallisce per chiave duplicata, il messaggio è già stato preso in carico.
4. L'ultimo UID si aggiorna **dopo** che il messaggio è stato messo in coda di elaborazione, non prima.
5. Se la **UIDVALIDITY cambia**, gli UID vecchi non valgono più: si esegue una risincronizzazione completa, confrontando gli identificativi dei messaggi con quelli già elaborati, invece di rielaborare tutto o, peggio, di non elaborare nulla.

Un errore frequente è usare il flag **\Seen** (letto) come stato: "elaboro i messaggi non letti e li segno come letti". Funziona finché nessuno apre la casella con un client di posta: basta che un collaboratore legga una PEC dal webmail perché il servizio la ignori. Lo stato dell'agente deve stare **nel tuo database**, non nei flag della casella. Per scaricare i messaggi senza modificarli, si usa `BODY.PEEK[]`, che non imposta il flag \Seen.

La separazione tra **ascolto** e **elaborazione** chiude il cerchio: il processo che ascolta la casella fa il minimo indispensabile (scaricare, registrare, mettere in coda) e l'elaborazione vera — parsing, classificazione, agente — avviene in un worker separato. Così un'elaborazione lenta non tiene la connessione IMAP bloccata fuori da IDLE, e un errore dell'agente non fa perdere messaggi. Una coda su Postgres o un orchestratore come n8n in modalità coda vanno bene, come descritto nel pezzo su [n8n in queue mode con Postgres]({{ '/it/blog/n8n-queue-mode-postgres/' | relative_url }}).

## Errori IMAP comuni (e cosa fare)

Gli errori che vedrai più spesso, e la reazione corretta:

| Errore (come appare) | Significato probabile | Reazione |
|----------------------|------------------------|----------|
| `* BYE Autologout; idle for too long` | il server ha chiuso per inattività | riconnetti; riduci l'intervallo di rinnovo IDLE |
| `* BYE ... server shutting down` / `[UNAVAILABLE]` | manutenzione o sovraccarico | backoff, poi riconnetti |
| connessione chiusa senza BYE (`EOF`, `socket error`, `ConnectionResetError`) | caduta di rete, NAT, bilanciatore | riconnetti con backoff; controlla keepalive |
| nessuna risposta fino al timeout | connessione morta in silenzio | chiudi e riconnetti; è il motivo del timer |
| `NO [AUTHENTICATIONFAILED]` / `LOGIN failed` | credenziali errate o scadute | **stop**, nessun retry automatico, allarme |
| `NO [LIMIT]`, "too many connections" | superato il limite di connessioni | chiudi connessioni duplicate; non aprirne altre; backoff lungo |
| `NO [UNAVAILABLE]` al login | blocco temporaneo o servizio non disponibile | backoff lungo, allarme se persiste |
| `NO [OVERQUOTA]` (su append/copy) | casella piena | allarme: la casella potrebbe non ricevere più PEC |
| `BAD` su un comando | errore del client (sintassi, stato sbagliato) | bug: registra e correggi, non ritentare in loop |
| UIDVALIDITY diversa da quella salvata | la cartella è stata ricostruita | risincronizzazione completa per identificativo |
| errori TLS (`SSLError`, certificato non valido) | problema di certificati o intercettazione | **stop** e verifica: non disabilitare la verifica del certificato |

I codici tra parentesi quadre (`[AUTHENTICATIONFAILED]`, `[LIMIT]`, `[UNAVAILABLE]`, `[OVERQUOTA]`) sono codici di risposta standardizzati che molti server usano; il testo libero che li accompagna varia da provider a provider. Conviene decidere la reazione sul **codice**, quando c'è, e registrare sempre il testo completo per le indagini.

## Più caselle: un processo vs pool

Finché la casella è una, l'architettura è semplice: un processo, una connessione, la state machine. Quando le caselle diventano decine — uno studio con molti clienti di cui gestisce le PEC, un'azienda con caselle per sede o per funzione — le scelte cambiano.

IDLE, per come è definito, osserva **una cartella per connessione**. Quaranta caselle in IDLE significano quaranta connessioni aperte in modo permanente. Esiste un'estensione, **NOTIFY** (RFC 5465), che permette di ricevere notifiche su più cartelle con una sola connessione, ma è supportata da pochi server e comunque non aiuta per caselle di utenti diversi. Le opzioni realistiche:

- **Un processo con molte connessioni** (asincrono o con thread): ogni casella ha la sua connessione IDLE, gestita da un unico servizio. Efficiente in risorse, ma un bug o un blocco può colpire tutte le caselle insieme, e tutte le connessioni partono dallo stesso IP.
- **Un pool di worker**: più processi, ciascuno responsabile di un gruppo di caselle, con un supervisore che assegna le caselle e riavvia i worker che muoiono. Isola i guasti e permette di distribuire il carico.
- **Modello misto IDLE + polling**: IDLE sulle caselle che richiedono reattività (poche), polling su sessione persistente, a intervalli di qualche minuto, sulle altre. Riduce il numero di connessioni permanenti.

Qualunque sia la scelta, alcune regole restano:

- **Una sola connessione attiva per casella** in tutto il sistema. Due processi che ascoltano la stessa casella raddoppiano il consumo del limite di connessioni e generano duplicati. Serve un meccanismo di assegnazione esclusiva (un lock nel database con scadenza, per esempio).
- **Distribuire le riconnessioni**: dopo un riavvio del servizio o un'interruzione di rete, quaranta caselle che si riconnettono nello stesso secondo sono un picco di login che il provider può interpretare come attacco. Serve il jitter anche all'avvio.
- **Credenziali separate e custodite**: quaranta password PEC sono un patrimonio sensibile. Vanno in un gestore di segreti, non in un file di configurazione, come descritto nel pezzo sulla [gestione dei secrets per agenti LLM]({{ '/it/blog/secrets-agenti-llm-vault/' | relative_url }}).

## Backoff e jitter (non martellare)

Quando qualcosa va storto — il server non risponde, la rete è caduta, il provider rifiuta connessioni — la reazione istintiva di un programma scritto in fretta è riprovare subito. E poi di nuovo, e di nuovo. Se il problema dura qualche minuto, sono centinaia di tentativi: esattamente il comportamento che i sistemi antiabuso sono fatti per bloccare. E se le caselle sono quaranta, moltiplicato per quaranta.

La regola è il **backoff esponenziale con jitter**:

- dopo il primo errore si attende, per esempio, 1 secondo; dopo il secondo 2, poi 4, 8, 16… fino a un **massimo** (per esempio 5 minuti);
- a ogni attesa si applica una componente **casuale** (il jitter), per esempio tra il 50% e il 100% del valore calcolato, così caselle e processi diversi non si riconnettono tutti nello stesso istante;
- il contatore dei tentativi **si azzera** solo dopo che una connessione è rimasta stabile per un po' (per esempio 10 minuti), non al primo login riuscito — altrimenti una connessione che cade subito dopo il login produce un ciclo rapido infinito;
- alcuni errori **non si ritentano** affatto: autenticazione fallita, errori di certificato, errori `BAD` del client.

Il backoff si applica anche **al lavoro, non solo alle connessioni**: se l'elaborazione a valle è in errore (l'agente non risponde, il database è pieno), l'ascoltatore continua a registrare i messaggi in coda ma non deve moltiplicare i tentativi di elaborazione. Sono due circuiti separati.

## Monitor: last_idle_at

Il secondo studio dell'introduzione aveva un processo vivo che non ascoltava più nulla. Il monitoraggio classico — "il processo è in esecuzione?" — non se ne accorge. Serve un indicatore che dica se **l'ascolto è vivo**, non se il programma è acceso.

L'indicatore più utile è **`last_idle_at`**: l'istante dell'ultimo ciclo IDLE completato con successo (rinnovo o notifica, seguito da una risposta del server). Il servizio lo aggiorna a ogni ciclo, per ogni casella, nel database o in una metrica. Il controllo diventa:

- se `now - last_idle_at` supera **due volte l'intervallo di rinnovo** (per esempio 25 minuti con rinnovo a 12), l'ascolto di quella casella è morto o bloccato: allarme;
- per le caselle in polling, l'equivalente è `last_poll_ok_at`.

Accanto a questo, poche altre metriche per casella:

- **stato** della state machine (connessa, in backoff, bloccata per autenticazione);
- **riconnessioni nelle ultime 24 ore** e causa (BYE, EOF, timeout): una crescita improvvisa è il primo segnale di un cambio di comportamento del provider;
- **età del messaggio più vecchio in coda** non ancora elaborato;
- **ultimo UID elaborato** e numero di messaggi presenti in casella, per verificare che non restino indietro messaggi.

Un controllo di **fine a fine** completa il quadro: una volta al giorno, un messaggio PEC di prova inviato a ciascuna casella (o almeno a quelle critiche) deve comparire elaborato entro un tempo stabilito. È l'unico test che verifica davvero l'intera catena, provider compreso. Su come raccogliere queste metriche insieme a quelle del resto della pipeline vale quanto scritto nel pezzo sull'[osservabilità degli LLM in produzione]({{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}).

## Scelta per 1 casella vs 40 caselle

Mettendo insieme tutto, le due configurazioni tipiche.

**Una casella (lo studio o la PMI con una PEC principale):**

- IDLE su una sessione persistente, con rinnovo ogni 10–14 minuti, keepalive TCP attivo e timeout di lettura.
- Riconciliazione per UID a ogni riconnessione e ogni 15–30 minuti.
- Backoff con jitter, stop su errori di autenticazione.
- `last_idle_at` con allarme, messaggio di prova giornaliero.
- Se IDLE si rivela instabile con il tuo provider o la tua rete, **polling su sessione persistente** ogni 2–5 minuti è un'alternativa perfettamente adeguata. Mai polling con login a ogni ciclo.

**Quaranta caselle (lo studio che gestisce le PEC dei clienti, o un gruppo con molte sedi):**

- Pool di worker con assegnazione esclusiva delle caselle e supervisore.
- IDLE solo sulle caselle che richiedono reattività; le altre in polling su sessione persistente ogni 3–10 minuti, con partenze sfalsate.
- Attenzione ai limiti per indirizzo IP: se si avvicinano, distribuire i worker su più indirizzi o ridurre le connessioni permanenti con più polling.
- Avvii e riconnessioni con jitter per evitare picchi di login.
- Credenziali in un gestore di segreti, rotazione gestita, allarme per ogni casella bloccata.
- Dashboard per casella con `last_idle_at` o `last_poll_ok_at`, riconnessioni, coda.

| Aspetto | 1 casella | 40 caselle |
|---------|-----------|------------|
| Modalità | IDLE (o polling persistente) | misto: IDLE per poche, polling persistente per le altre |
| Processi | uno | pool con assegnazione esclusiva |
| Connessioni permanenti | 1 | da poche a 40, secondo il mix |
| Rischio principale | disconnessione silenziosa | picchi di login e limiti per IP |
| Monitor | last_idle_at + prova giornaliera | per casella, con dashboard e allarmi aggregati |

## Percorso di implementazione, a step

1. **Definisci il ritardo massimo accettabile** tra arrivo della PEC e presa in carico: decide tra IDLE e polling.
2. **Separa ascolto ed elaborazione**: l'ascoltatore scarica e mette in coda, i worker elaborano.
3. **Implementa la state machine** con stati espliciti, compreso lo stop su errori di autenticazione.
4. **Aggiungi lo stato per UID** con UIDVALIDITY e tabella idempotente dei messaggi presi in carico.
5. **Configura i timeout**: rinnovo IDLE, lettura, comandi, connessione, keepalive.
6. **Implementa backoff esponenziale con jitter** e reset solo dopo stabilità.
7. **Pubblica `last_idle_at`** e le altre metriche per casella, con allarmi.
8. **Attiva il messaggio di prova** giornaliero di fine a fine.
9. **Osserva per qualche settimana** durata delle sessioni ed errori, e regola i valori sul comportamento reale del provider.
10. **Per più caselle**, introduci il pool con assegnazione esclusiva e partenze sfalsate.

## Fallimenti tipici e come li riconosci

- **Casella bloccata dal provider.** Login falliti in serie dopo un periodo di funzionamento regolare: polling con login a ogni ciclo, o retry immediati dopo un errore. Serve la sessione persistente e il backoff.
- **Ritardi di ore senza errori.** `last_idle_at` fermo mentre il processo è vivo: connessione morta in silenzio, nessun timer di rinnovo o timeout di lettura.
- **PEC saltate.** Messaggi presenti in casella ma mai elaborati: stato basato su \Seen, o sincronizzazione assente dopo la riconnessione.
- **PEC elaborate due volte.** Doppie bozze o doppie registrazioni: due processi sulla stessa casella, o mancanza della tabella idempotente.
- **"Too many connections".** Connessioni aperte e mai chiuse dopo errori, processi duplicati, client di posta degli utenti che consumano il limite.
- **Tempesta di login dopo un riavvio.** Tutte le caselle si riconnettono insieme: manca il jitter all'avvio.
- **Password cambiata, casella bloccata.** Retry automatici su errore di autenticazione: lo stato BLOCCATO_AUTH manca.

## Quando NON farlo (o farlo più semplice)

- **Se la PEC riceve pochi messaggi e nessuno è urgente**, un polling su sessione persistente ogni 5–10 minuti, con le stesse regole di stato e monitor, è più semplice di IDLE e altrettanto utile.
- **Se il gestore offre notifiche o integrazioni dedicate** adatte al tuo caso, valutale prima di costruire un ascoltatore IMAP: meno codice da mantenere. Verifica però che non introducano un intermediario indesiderato sui dati.
- **Se la casella è gestita principalmente a mano** da persone che spostano, cancellano e archiviano messaggi, chiarisci prima le regole: un agente che legge una casella che altri modificano senza criteri produrrà comportamenti imprevedibili.
- **Non costruire un ascoltatore senza monitor**: un servizio che può smettere di ascoltare senza che nessuno se ne accorga è peggio di un controllo manuale quotidiano.

## Checklist operativa

- [ ] Ritardo massimo accettabile definito per ogni casella.
- [ ] Sessione persistente: nessun login a ogni ciclo.
- [ ] IDLE rinnovato ogni 10–14 minuti con NOOP, timeout di lettura e keepalive.
- [ ] State machine con stop su autenticazione fallita e su errori TLS.
- [ ] Stato per UID e UIDVALIDITY nel database; nessun uso di \Seen come stato; download con BODY.PEEK.
- [ ] Tabella idempotente dei messaggi presi in carico.
- [ ] Riconciliazione a ogni riconnessione e periodica.
- [ ] Ascolto ed elaborazione separati da una coda.
- [ ] Backoff esponenziale con jitter, reset solo dopo stabilità, jitter anche all'avvio.
- [ ] Una sola connessione attiva per casella in tutto il sistema.
- [ ] `last_idle_at` / `last_poll_ok_at` con allarme e messaggio di prova giornaliero.
- [ ] Credenziali in un gestore di segreti.

## Il verdetto

Far "ascoltare" la PEC a un agente sembra la parte facile del progetto, e per questo viene fatta in fretta. Ma è il punto in cui si perdono comunicazioni con valore legale, o in cui il provider chiude l'accesso alla casella. La scelta tra **IMAP IDLE e polling** conta meno di come la si implementa: il polling con login ogni 30 secondi è il modo più rapido per farsi bloccare, e un IDLE senza timer di rinnovo è il modo più silenzioso per smettere di ricevere.

Ciò che rende affidabile l'ascolto è sempre lo stesso insieme di pratiche: una sessione persistente, IDLE rinnovato ben prima dei timeout di server e rete, una state machine che distingue gli errori da ritentare da quelli che richiedono una persona, uno stato basato su UID nel tuo database invece che nei flag della casella, backoff con jitter per non martellare il provider, e un indicatore come `last_idle_at` che dica se l'ascolto è davvero vivo. Con una casella, IDLE ben fatto o un polling persistente ogni pochi minuti; con quaranta, un pool con assegnazione esclusiva e un mix di IDLE e polling.

Nessuna di queste cose è intelligenza artificiale. Sono il tubo. Ma un agente brillante collegato a un tubo che perde è un agente che non vede le PEC importanti.

Se devi collegare una o molte caselle PEC a un sistema di elaborazione automatica e vuoi farlo senza sorprese, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Si parte dal ritardo accettabile e dal numero di caselle.

## FAQ

### Meglio IMAP IDLE o polling per leggere la PEC?
Dipende dal ritardo accettabile. IDLE dà notifiche quasi immediate con una sola connessione, ma richiede di gestire bene rinnovi e disconnessioni silenziose. Il polling su sessione persistente ogni 2–5 minuti è più semplice da rendere robusto ed è sufficiente per la maggior parte degli usi della PEC. Da evitare in ogni caso il polling con login a ogni ciclo.

### Perché il provider può bloccare la mia casella PEC?
Perché un servizio che fa login migliaia di volte al giorno, o che ritenta subito e ripetutamente dopo un errore, somiglia a un attacco o a un client malfunzionante. I sistemi antiabuso reagiscono con rallentamenti o blocchi temporanei. Una sessione persistente, il backoff con jitter e lo stop sugli errori di autenticazione evitano il problema.

### Ogni quanto va rinnovato IMAP IDLE?
La RFC di IDLE raccomanda di rinnovarlo almeno ogni 29 minuti, perché i server possono disconnettere i client inattivi dopo 30. Nella pratica conviene rinnovarlo ogni 10–14 minuti, con un NOOP per verificare che la sessione risponda, perché firewall e NAT possono chiudere le connessioni silenziose molto prima.

### Come si evita di perdere messaggi dopo una disconnessione?
Memorizzando nel proprio database la UIDVALIDITY della cartella e l'ultimo UID elaborato, e a ogni riconnessione cercando i messaggi con UID successivo. Le notifiche IDLE valgono solo durante la sessione, quindi la sincronizzazione dopo la riconnessione è indispensabile. Una riconciliazione periodica aggiunge un ulteriore margine.

### Come si evitano le elaborazioni doppie?
Con una tabella idempotente dei messaggi presi in carico, con chiave unica su casella, UIDVALIDITY e UID, e per maggiore sicurezza sull'identificativo del messaggio presente nei dati di certificazione della PEC. E garantendo che una sola connessione ascolti ogni casella in tutto il sistema.

### Posso usare il flag "letto" per sapere cosa ho già elaborato?
Meglio di no. Basta che una persona apra la PEC dal webmail o da un client di posta perché il messaggio risulti letto e il servizio lo ignori. Lo stato dell'elaborazione va tenuto nel proprio database, e i messaggi vanno scaricati con BODY.PEEK per non modificare i flag.

### Quali sono gli errori IMAP più comuni?
Chiusure per inattività (BYE Autologout), connessioni interrotte senza avviso (EOF, reset, timeout), errori di autenticazione (AUTHENTICATIONFAILED), limiti di connessioni (LIMIT o "too many connections"), servizio non disponibile (UNAVAILABLE), casella piena (OVERQUOTA), errori del client (BAD) e cambi di UIDVALIDITY. Le prime vanno gestite con riconnessione e backoff; autenticazione, TLS e BAD richiedono uno stop e un intervento.

### Come si gestiscono molte caselle PEC?
Con un pool di worker e un'assegnazione esclusiva delle caselle, per avere una sola connessione per casella; con IDLE solo sulle caselle che richiedono reattività e polling su sessione persistente per le altre; con avvii e riconnessioni sfalsati dal jitter; con attenzione ai limiti di connessioni per indirizzo IP e con le credenziali custodite in un gestore di segreti.

### Cos'è last_idle_at e perché serve?
È l'istante dell'ultimo ciclo IDLE completato con risposta del server, aggiornato per ogni casella. Serve a capire se l'ascolto è davvero vivo, non solo se il processo è in esecuzione: se il valore supera circa il doppio dell'intervallo di rinnovo, la connessione è morta o bloccata e deve scattare un allarme.

### IMAP NOTIFY può sostituire IDLE su più caselle?
NOTIFY permette di ricevere notifiche su più cartelle con una sola connessione, ma è supportato da pochi server e non risolve il caso di caselle appartenenti a utenti diversi, come le PEC di più clienti. Nella pratica, con più caselle PEC si usa una connessione per casella, combinando IDLE e polling.
