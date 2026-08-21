---
lang: it
permalink: /it/blog/agente-imap-pec-fatture/
alt_url: /en/blog/imap-pec-invoice-agent/
title: "Come costruire un agente IMAP che classifica PEC e fatture (senza Gmail API e senza dare la password a un SaaS)"
date: 2026-09-23 07:30:00 +0200
author: "Antonio Trento"
description: "Un inbox agent che smista PEC, fatture e comunicazioni legali senza mandare la tua posta a un SaaS americano. Architettura IMAP IDLE self-hosted, classificazione locale, gestione allegati XML FatturaPA."
keywords: ["agente imap pec fatture", "imap idle python", "pec aruba", "classificazione email ai", "inbox agent self-hosted"]
image: /assets/images/posts/agente-imap-pec-fatture.jpg
pillar: integrazioni-dati
related: [/it/blog/rag-pgvector-fattura-elettronica/, /it/blog/n8n-self-hosted-openai-privacy/]
---

## La posta è il sistema nervoso dell'azienda, e la stai regalando a un SaaS

Nella casella di posta di una PMI italiana passa tutto: le fatture dei fornitori, le PEC con valore legale, le comunicazioni degli enti, gli ordini dei clienti, le diffide, gli estratti conto. È il sistema nervoso dell'azienda. E la soluzione che ti propongono tutti per "metterci l'AI sopra" è collegare un SaaS — un assistente, un Copilot, un tool che si aggancia via Gmail API — che legge *tutta* quella posta e la manda ai suoi server per classificarla. Cioè: regali a un fornitore terzo, spesso americano, l'accesso completo al flusso più sensibile che hai. Per molte PMI italiane questo è semplicemente un **non-starter**, e non per paranoia: per PEC, dati fiscali e obblighi GDPR.

C'è un altro modo, ed è il tema di questo articolo: costruire un **agente IMAP** che smista PEC e fatture **in casa tua**, senza Gmail API e senza dare la password della posta a nessun SaaS. Un inbox agent che si connette alla casella con il protocollo IMAP standard, riceve le mail in tempo reale con IDLE, le classifica (con un modello che gira in locale sul solo testo che serve), estrae gli allegati — comprese le fatture XML FatturaPA — e le mette nelle cartelle giuste, lasciando all'umano solo i casi incerti. In questo pezzo vediamo l'architettura completa: IMAP contro le API proprietarie, IDLE contro il polling, la tassonomia delle cartelle, come e dove classificare, la gestione degli allegati e dei virus, l'idempotenza per non riclassificare le stesse mail all'infinito, e il runbook operativo (password dedicate, fail2ban, backup delle regole). Con lo snippet Python di IMAP IDLE, lo schema delle cartelle, e la lista degli errori dei provider PEC. Perché la posta è troppo importante per darla in mano a qualcun altro.

## Perché Gmail API e Copilot sulla posta sono un non-starter per molte PMI

Chiariamo perché la strada "facile" non va bene, così si capisce cosa stiamo evitando.

- **Danno accesso totale a un terzo.** Un assistente che si collega via Gmail API o Microsoft Graph, o un Copilot sulla posta, per funzionare deve poter **leggere tutta la casella**. Gli stai dando le chiavi del tuo sistema nervoso. E quel terzo processa i contenuti sui suoi server — nome dei clienti, importi, PEC legali, tutto.
- **La PEC non vive lì.** La posta elettronica certificata è un mondo italiano: caselle su Aruba, Legalmail, e altri gestori, che parlano IMAP/SMTP standard, non le API di Google o Microsoft. Un "Gmail AI assistant" con la PEC non c'entra niente — e la PEC è proprio la posta con valore legale che devi presidiare di più.
- **Il problema GDPR è lo stesso di sempre.** Mandare il contenuto della posta aziendale a un SaaS è un trattamento di dati personali (spesso extra-UE) affidato a un responsabile esterno, con tutto quello che comporta — esattamente il tema del [ChatGPT nel CRM che diventa un data leak]({{ '/it/blog/gdpr-chatgpt-crm/' | relative_url }}). Sulla posta, che contiene *tutto*, il rischio è massimo.
- **Il lock-in.** Costruire il tuo smistamento dentro l'ecosistema di un fornitore ti lega a lui: cambi provider e rifai tutto.

Il non-starter non è "l'AI sulla posta". È **l'AI sulla posta gestita da un terzo che se la porta a casa sua**. L'alternativa non è rinunciare all'automazione: è farla in casa, sul protocollo aperto che la posta già parla. Che è IMAP.

## IMAP contro Graph e Gmail: cosa tieni in casa

La scelta del "come ti connetti alla posta" decide chi controlla i dati. Tre strade:

- **Gmail API / Microsoft Graph**: API proprietarie dei due giganti. Potenti, ma ti legano al loro ecosistema, richiedono i loro flussi di autorizzazione, e presuppongono che la posta viva lì. Per la PEC italiana non sono nemmeno un'opzione.
- **IMAP**: il **protocollo standard** della posta, che *qualsiasi* casella parla — Aruba, Legalmail, il tuo server, Google e Microsoft stessi. Ti connetti direttamente alla casella, scarichi le mail, le sposti tra cartelle. Nessun intermediario, nessun ecosistema: **i dati passano solo tra la tua casella e il tuo agente.** È la scelta sovrana.

Con IMAP, l'architettura è pulita: il tuo agente (che gira su un tuo server, in Docker) si connette alla casella via IMAP su TLS, legge le mail nuove, le classifica *in locale*, e le sposta nelle cartelle. Il provider della posta vede solo un client IMAP che si collega — come farebbe Outlook o Thunderbird. Nessun contenuto va a un SaaS di classificazione, perché il SaaS di classificazione non esiste: è il tuo agente, a casa tua. È lo stesso principio del [recinto chiuso di uno stack sovrano]({{ '/it/pillar/stack-sovrano/' | relative_url }}): il confine dei dati è dove gira la logica, e qui la logica gira da te.

Un dettaglio pratico: molte caselle (PEC comprese) richiedono, per l'accesso IMAP programmatico, una **password dedicata** o l'abilitazione esplicita dell'IMAP. Non usare la password personale del titolare: si crea una credenziale apposita per l'agente (ne parliamo nel runbook).

## IDLE contro polling: CPU, ban del provider, backoff

Come fa l'agente ad accorgersi che è arrivata una mail nuova? Due modi, e la scelta ha conseguenze concrete su carico e stabilità.

- **Il polling**: l'agente controlla la casella ogni tot secondi/minuti ("ci sono mail nuove? no. E adesso? no. E adesso?"). Semplice, ma spreca risorse e — soprattutto — **irrita il provider**: interrogare la casella troppo spesso può far scattare rate limit o ban temporanei, perché sembra un comportamento abusivo. E se metti l'intervallo lungo per evitare il ban, la posta viene smistata in ritardo.
- **IMAP IDLE**: il modo giusto. L'agente apre una connessione e dice al server "avvisami tu quando arriva qualcosa" (IDLE). Poi **aspetta**, senza interrogare di continuo: il server manda una notifica *push* quando c'è posta nuova. Basso carico di CPU, nessun martellamento del provider, e smistamento in tempo reale.

Ecco lo scheletro di un loop IMAP IDLE in Python (con la libreria IMAPClient, che rende IDLE pulito):

```python
from imapclient import IMAPClient
import time, logging

HOST = "imaps.pec.aruba.it"          # esempio: host IMAP del provider PEC
USER = "azienda@pec.esempio.it"
APP_PASSWORD = "PASSWORD_DEDICATA"   # NON la password personale

def loop_idle():
    while True:
        try:
            with IMAPClient(HOST, ssl=True) as server:
                server.login(USER, APP_PASSWORD)
                server.select_folder("INBOX")
                processa_nuovi(server)          # smaltisci l'arretrato
                while True:
                    server.idle()
                    # i server chiudono l'IDLE ~ ogni 29 min: rinnova prima
                    responses = server.idle_check(timeout=5 * 60)
                    server.idle_done()
                    if responses:
                        processa_nuovi(server)
        except Exception as e:
            logging.warning("Connessione persa: %s — backoff", e)
            time.sleep(30)                       # BACKOFF prima di riconnettere

def processa_nuovi(server):
    for uid in server.search(["UNSEEN"]):
        raw = server.fetch([uid], ["RFC822"])[uid][b"RFC822"]
        smista(server, uid, raw)                 # classifica e sposta
```

Due dettagli che separano il giocattolo dalla produzione:

- **Il rinnovo dell'IDLE.** I server chiudono la sessione IDLE dopo circa 29 minuti. Vai in `idle_check` con un timeout più corto (5 minuti nell'esempio), poi rinnovi. Se non lo fai, la connessione muore in silenzio e smetti di ricevere notifiche senza accorgertene.
- **Il backoff sulla riconnessione.** La rete cade, il provider ti butta fuori: l'agente deve **aspettare** prima di riconnettere (backoff), non ritentare all'infinito a raffica — che è esattamente il comportamento che fa scattare il ban. Un `sleep` crescente sugli errori ripetuti è la difesa.

## La tassonomia delle cartelle: dove finisce ogni mail

L'agente non "risponde" alle mail: le **smista**. E lo smistamento ha senso solo se le cartelle di destinazione sono pensate bene. Una tassonomia che funziona in una PMI italiana:

```text
INBOX
├── 00-da-leggere      → arrivate, non ancora classificate (default)
├── 10-fatture         → contengono fattura (XML FatturaPA o PDF)
├── 20-pec-legale      → PEC con valore legale: notifiche, diffide, enti
├── 30-ordini-clienti  → richieste e ordini da clienti
├── 40-spam            → posta indesiderata
├── 50-da-umano        → INCERTO: l'agente non è sicuro → revisione
└── 99-archiviato      → processato e chiuso
```

Le due cartelle che fanno la differenza, e che il "AI email assistant" generico non ti dà:

- **`20-pec-legale`**: le PEC non sono mail come le altre. Hanno valore legale, spesso scadenze (una diffida, una notifica, una comunicazione di un ente), e vanno viste da un umano *presto*. Separarle dal rumore è metà del valore dell'agente: non perdi più una PEC importante in mezzo a duecento mail.
- **`50-da-umano`**: la cartella più importante, e quella che i sistemi ingenui non hanno. **Quando l'agente non è sicuro, non indovina: mette da parte per la revisione umana.** Una mail ambigua, un caso strano, una classificazione a bassa confidenza vanno qui, non forzate in una cartella a caso. È la rete di sicurezza che rende l'automazione affidabile: meglio dieci mail "da guardare" che una fattura finita nello spam o una diffida persa.

Il principio: **l'agente automatizza il chiaro e scala all'umano l'incerto.** Le mail ovvie (una FatturaPA riconoscibile, uno spam palese) le smista da solo; su tutto il resto, nel dubbio, chiede aiuto. È lo stesso confine — macchina sul banale, umano sull'importante — che regge gli [agenti che eseguono azioni sui sistemi di produzione]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}).

## Dove classificare: modello locale sul solo body, già ripulito

Come decide l'agente in quale cartella va una mail? Con una combinazione di **segnali strutturali** e **classificazione linguistica**, in questo ordine (dal più affidabile al più costoso):

1. **Regole deterministiche prima di tutto.** Molto si decide senza AI: se c'è un allegato XML FatturaPA, è una fattura (cartella `10-fatture`), punto. Se il mittente è un dominio PEC certificato e l'oggetto contiene certe parole, è probabile PEC legale. Le regole chiare e verificabili vanno prima del modello: sono gratis, veloci e non allucinano.
2. **Il modello linguistico per l'ambiguo.** Quando le regole non bastano (una mail di testo che potrebbe essere un ordine o una richiesta generica), interviene la classificazione con un LLM — che gira **in locale** (Ollama o vLLM, come nello [stack sovrano dei modelli]({{ '/it/pillar/modelli-costi-privacy/' | relative_url }})).

E qui il punto GDPR cruciale: **al modello passi il minimo indispensabile, già ripulito.** Non l'intera mail con nomi, IBAN e allegati: solo il testo del *body* che serve a classificare, con i dati sensibili mascherati (la stessa redaction vista per gli [altri nodi che escono]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }})). E poiché il modello gira in locale, anche il body ripulito non lascia comunque il tuo server. Doppia difesa: minimizzi *e* tieni in casa.

Il modello risponde con una **classificazione e una confidenza**. Se la confidenza è alta, l'agente smista. Se è bassa, va in `50-da-umano`. Questo numero di confidenza è ciò che rende l'automazione onesta: l'agente sa quando non sa, e lo dice, invece di forzare ogni mail in una casella con sicurezza ingiustificata.

## Gli allegati: XML FatturaPA, PDF, zip, virus

Gli allegati sono dove la posta diventa pericolosa e preziosa insieme. L'agente deve gestirli con cura, perché è lì che arrivano le fatture (valore) e i malware (rischio).

- **Scansione antivirus, sempre e per prima.** Prima di aprire *qualsiasi* allegato, passalo a un antivirus locale (ClamAV, in un container). La posta è il vettore numero uno di malware: un agente che apre allegati senza scansionarli è una porta spalancata. Se l'allegato è infetto, in quarantena e segnalazione — mai processato.
- **XML FatturaPA.** L'allegato che ti interessa di più. Attenzione ai formati: la fattura può essere un `.xml` semplice, un `.xml.p7m` (firmato digitalmente, formato CAdES — va prima "sbustato" per estrarre l'XML), o dentro un `.zip`. Un agente serio riconosce tutti e tre. Estratto l'XML, hai i dati strutturati (numero, fornitore, importo) — che poi possono alimentare il [RAG sulle fatture con pgvector]({{ '/it/blog/rag-pgvector-fattura-elettronica/' | relative_url }}): l'inbox agent è l'ingresso, il RAG è l'interrogazione.
- **PDF.** Fatture in PDF (fornitori esteri, vecchie), documenti, comunicazioni. Vanno gestiti sapendo che il testo va estratto (o OCR se scansionati), con meno affidabilità dell'XML.
- **ZIP e archivi.** Da aprire con cautela (anche per il rischio "zip bomb"), scansionando il contenuto, e gestendo il caso di più file dentro.

La regola sugli allegati: **scansiona prima, apri dopo, e riconosci i formati italiani veri** (il `.p7m` firmato è quello che i tutorial generici ignorano e che in Italia trovi di continuo sulle PEC e sulle fatture). Un agente che non sa sbustare un `.xml.p7m` non serve a niente sulle fatture italiane.

## Idempotenza: il Message-ID, per non riclassificare all'infinito

Ecco il bug che manda in loop gli inbox agent ingenui, e come si evita. Se l'agente si riconnette (dopo un backoff, un riavvio, un crash) e riscansiona la casella, rischia di **riprocessare mail già smistate**, spostandole di nuovo, riclassificandole, magari all'infinito. Il risultato: cartelle che si scombinano, la stessa fattura processata dieci volte, log che esplodono.

La difesa è l'**idempotenza basata sul Message-ID**. Ogni email ha un header `Message-ID` univoco a livello mondiale. L'agente tiene un registro dei Message-ID già processati (in un piccolo database, o in un file). Prima di processare una mail:

- Se il suo `Message-ID` è **già nel registro** → è già stata smistata, salta.
- Se è **nuovo** → processala, e registra il Message-ID a fine lavoro.

```python
import sqlite3, email

db = sqlite3.connect("processate.db")
db.execute("CREATE TABLE IF NOT EXISTS visti (message_id TEXT PRIMARY KEY, ts TEXT)")

def gia_processata(raw_bytes) -> bool:
    msg = email.message_from_bytes(raw_bytes)
    mid = msg.get("Message-ID", "").strip()
    if not mid:
        return False                     # senza Message-ID: gestisci con cautela
    cur = db.execute("SELECT 1 FROM visti WHERE message_id = ?", (mid,))
    return cur.fetchone() is not None

def segna_processata(raw_bytes):
    msg = email.message_from_bytes(raw_bytes)
    mid = msg.get("Message-ID", "").strip()
    if mid:
        db.execute("INSERT OR IGNORE INTO visti VALUES (?, datetime('now'))", (mid,))
        db.commit()
```

Così, riscansionare la casella dopo un riavvio non ricrea il caos: le mail viste vengono saltate, le nuove vengono processate una volta sola. È lo stesso principio di idempotenza che rende sicuri i [retry di un agente che scrive sui sistemi]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}): ciò che si ripete non deve raddoppiare l'effetto. Nota il caso limite: alcune mail (rare, malformate) possono non avere Message-ID — vanno gestite con una regola prudente (es. hash del contenuto) invece di assumere che ci sia sempre.

## Due mail, due percorsi: come l'agente decide davvero

Vediamo i pezzi insieme su due mail reali, per capire come lavora l'agente istante per istante.

**Mail 1 — una fattura di un fornitore.** Arriva una PEC con un allegato `IT01234567890_00042.xml.p7m`.

1. L'IDLE notifica; l'agente scarica la mail nuova.
2. Controllo idempotenza: il `Message-ID` è nuovo → si processa.
3. Antivirus sull'allegato: pulito.
4. L'estrattore riconosce il `.p7m`, lo sbusta, trova l'XML FatturaPA valido.
5. **Regola deterministica**: allegato FatturaPA valido → è una fattura, confidenza massima. Nessun modello serve.
6. La mail va in `10-fatture`; i dati strutturati (fornitore, numero, importo) vengono estratti e resi disponibili all'archivio/RAG. Message-ID registrato.

Tempo: istantaneo, zero AI, zero dati usciti. La maggior parte della posta "importante" si smista così, con le sole regole.

**Mail 2 — una comunicazione ambigua.** Arriva una PEC da un dominio certificato, oggetto "Riscontro alla vostra del 12", corpo di testo, nessun allegato strutturato.

1. IDLE, idempotenza, antivirus (niente allegati rischiosi): ok.
2. Le regole deterministiche non decidono: è una PEC (dominio certificato → probabile area legale), ma il contenuto potrebbe essere una diffida, un sollecito o una comunicazione neutra.
3. Interviene il **classificatore locale**: riceve il body *ripulito* (mascherati eventuali nomi/riferimenti), risponde "possibile comunicazione legale, confidenza media".
4. Confidenza media + natura PEC → l'agente **non forza**: la mette in `20-pec-legale` *e* la segnala per revisione. Se la confidenza fosse stata bassa, sarebbe andata in `50-da-umano`.
5. Un umano la vede presto, nella cartella giusta, e decide. Message-ID registrato.

Il contrasto è il punto: sul chiaro (la fattura) l'agente è deterministico, veloce e senza AI; sull'ambiguo (la PEC di testo) usa il modello locale ma **con umiltà**, scalando all'umano quando la confidenza non basta. Nessuno dei due percorsi ha mandato dati fuori, e nessuna PEC importante è finita persa nel mucchio. Questo è l'inbox agent fatto bene: automatismo dove è sicuro, prudenza dove non lo è.

## Cosa si rompe in produzione: la lista degli errori dei provider PEC

I guasti di un inbox agent sono quasi sempre di connessione e autenticazione, e i provider PEC hanno le loro particolarità. Ecco cosa vedrai e come lo riconosci.

| Errore (tipico) | Causa | Rimedio |
|---|---|---|
| `AUTHENTICATIONFAILED` | Password sbagliata, o serve una password dedicata / IMAP non abilitato | Crea la credenziale apposita, abilita l'accesso IMAP nel pannello del provider |
| Connessione rifiutata / timeout | Host o porta errati, o IP dell'agente bloccato | Verifica host IMAPS e porta 993 (TLS); controlla eventuali blocchi lato provider |
| `Too many connections` | Troppe connessioni simultanee alla stessa casella | Una sola connessione IDLE per casella; non aprirne una per ogni operazione |
| Blocco temporaneo / rate limit | Polling troppo aggressivo o riconnessioni a raffica | Usa IDLE, metti il backoff, riduci la frequenza |
| Disconnessione dopo ~29 min | Timeout naturale dell'IDLE non rinnovato | Rinnova l'IDLE con timeout più corto (5 min) |
| Errore certificato TLS | Catena di certificati o CA | Verifica la configurazione TLS del client |
| Quota casella piena | La PEC ha quote di spazio; se piena, non riceve | Monitora lo spazio; archivia/scarica per liberare |

Il filo comune: **la stragrande maggioranza dei problemi si legge nei log come errori di login o di connessione**, e si risolve con una password dedicata, l'IDLE al posto del polling, il backoff, e il rinnovo della sessione. Se l'agente "smette di ricevere" senza errori evidenti, il sospetto numero uno è l'IDLE morto e non rinnovato: controlla lì per primo.

## Il runbook operativo: password dedicate, fail2ban, backup delle regole

Un inbox agent in produzione va gestito, non solo scritto. Il runbook minimo:

- **Password dedicata, mai quella personale.** L'agente usa una credenziale creata apposta per lui, revocabile senza toccare l'accesso umano alla casella. Se l'agente viene compromesso, revochi quella e basta.
- **Segreti fuori dal codice.** Password e host in variabili d'ambiente / secret, non scritti nel sorgente né nei log.
- **fail2ban sul server dell'agente.** Il server che ospita l'agente è esposto: fail2ban (o equivalente) blocca i tentativi di accesso ostili. Igiene di base di ogni macchina che sta in rete.
- **Backup delle regole di classificazione.** La logica di smistamento (le regole deterministiche, la tassonomia, le soglie di confidenza) è un asset: va versionata e backuppata. Se la perdi, ricostruirla è dolore.
- **Monitoraggio del "sono vivo".** L'agente deve segnalare che sta funzionando (un heartbeat, un log periodico). Un inbox agent morto in silenzio è peggio di nessun agente: pensi che smisti e invece la posta si accumula in `00-da-leggere`.
- **Revisione periodica di `50-da-umano`.** La cartella dell'incerto va svuotata da una persona con regolarità, e i casi ricorrenti diventano nuove regole. È il ciclo che rende l'agente più bravo nel tempo.

## L'architettura di riferimento

Mettendo insieme i pezzi:

- **L'agente IMAP** (in Docker) connesso alla casella via IMAP IDLE su TLS, con backoff e rinnovo.
- **Il classificatore**: regole deterministiche prima, modello **locale** poi (sul solo body ripulito) per l'ambiguo, con soglia di confidenza.
- **L'antivirus** (ClamAV, in container) che scansiona ogni allegato prima di aprirlo.
- **L'estrattore allegati** che riconosce `.xml`, `.xml.p7m`, `.zip`, PDF.
- **Il registro dei Message-ID** (SQLite/DB) per l'idempotenza.
- **Le cartelle IMAP** della tassonomia, incluse `20-pec-legale` e `50-da-umano`.

**Cosa l'agente NON fa mai:**

- **Non risponde** alle mail da solo (specie le PEC: una risposta con valore legale non la manda un LLM).
- **Non cancella** mail: al massimo sposta in cartelle; la cancellazione è decisione umana.
- **Non manda** il contenuto a un SaaS esterno: classifica in locale.
- **Non forza** le mail incerte in una cartella: le mette in revisione.

I passi per costruirlo:

1. **Crea la credenziale dedicata** e abilita l'IMAP sulla casella.
2. **Definisci la tassonomia** delle cartelle e creale.
3. **Scrivi le regole deterministiche** (FatturaPA → fatture, dominio PEC → pec-legale, ecc.).
4. **Aggiungi il classificatore locale** per l'ambiguo, con soglia di confidenza e fallback a `50-da-umano`.
5. **Metti l'antivirus** e l'estrazione allegati (con il `.p7m`).
6. **Aggiungi l'idempotenza** sul Message-ID.
7. **Metti IDLE con backoff e rinnovo**, il monitoraggio, il runbook.
8. **Rodalo in parallelo** all'uso umano prima di fidartene, guardando cosa finisce in `50-da-umano`.

## I costi

Ordini di grandezza, stime dichiarate:

- **L'agente in sé**: gira su un server modesto o un VPS (poche decine di € al mese, o su hardware che già hai). Il carico è basso: IDLE non consuma quasi nulla in attesa.
- **La classificazione locale**: se usi un LLM per l'ambiguo, vale il discorso GPU dello stack sovrano (una scheda da 24 GB usata ~800 € se serve, ma per la sola classificazione di testo corto anche una GPU piccola o modelli leggeri bastano; molte mail si classificano con le sole regole, senza modello).
- **ClamAV**: gratuito, gira in container, costo trascurabile.
- **Il confronto**: un SaaS di inbox AI ha un canone per casella/utente — comodo ma manda fuori la posta. L'agente self-hosted ha un costo di costruzione una tantum e poi gira quasi gratis, tenendo i dati in casa. Su più caselle e nel tempo, l'in-casa vince — e in più non hai il rischio di regalare il tuo sistema nervoso.

## Quando NON farlo

Onestà, come sempre. **Non costruire questo agente se:**

- **Hai poca posta e poche PEC.** Se ricevi una manciata di mail al giorno e le PEC sono rare, smistarle a mano è più economico che costruire e mantenere un agente. L'automazione ha senso sul volume.
- **Non hai chi mantiene un servizio self-hosted.** L'agente va tenuto vivo (connessioni, aggiornamenti, la cartella `da-umano` da svuotare). Senza qualcuno che se ne occupa, un agente trascurato accumula posta in silenzio — peggio del nulla.
- **Il tuo provider offre già uno smistamento adeguato e in-UE.** Se il gestore della tua PEC/posta ha già regole di smistamento che ti bastano e tiene i dati in UE sotto contratto, forse non ti serve costruire.
- **Ti serve solo cercare, non smistare.** Se il bisogno è "ritrovare le mail", quello è un problema di ricerca, non un inbox agent.

La proporzione: l'inbox agent brilla su **volumi alti di posta eterogenea, con PEC e fatture da presidiare, e la necessità di non regalare la posta a un terzo.** Fuori da lì, valuta se il gioco vale la candela — dirlo fa parte del mestiere.

## Checklist operativa prima della produzione

- [ ] **Credenziale dedicata** per l'agente; IMAP abilitato; password fuori dal codice.
- [ ] Connessione **IMAP su TLS** (porta 993), con **IDLE**, **backoff** e **rinnovo** della sessione.
- [ ] **Tassonomia cartelle** definita, incluse `pec-legale` e `da-umano`.
- [ ] **Regole deterministiche** prima del modello (FatturaPA, domini PEC).
- [ ] **Classificazione locale** sul solo body ripulito, con **soglia di confidenza** → incerto a `da-umano`.
- [ ] **Antivirus** su ogni allegato prima di aprirlo.
- [ ] Estrazione allegati che gestisce **`.xml`, `.xml.p7m`, `.zip`, PDF**.
- [ ] **Idempotenza** sul Message-ID; nessuna riclassificazione infinita.
- [ ] **fail2ban** e igiene di sicurezza sul server dell'agente.
- [ ] **Heartbeat/monitoraggio**: sai se l'agente è vivo.
- [ ] **Backup** delle regole di classificazione.
- [ ] L'agente **non risponde, non cancella, non manda fuori**: solo smista, e scala l'incerto.

## Il verdetto: la posta si presidia in casa

Mettere l'AI sulla posta non deve voler dire regalare il tuo sistema nervoso a un SaaS. Un agente IMAP self-hosted classifica PEC e fatture in casa tua, sul protocollo standard che ogni casella parla, con IDLE per il tempo reale e il backoff per non farti bannare, la classificazione in locale sul solo testo ripulito, la gestione seria degli allegati italiani (il `.p7m` firmato, l'XML FatturaPA), l'idempotenza sul Message-ID per non impazzire, e la cartella `da-umano` che tiene l'automazione onesta. Non è "un AI email assistant": è un pezzo di integrazione verticale sulla posta italiana, PEC compresa, che tiene i dati dove devono stare — da te. La posta è troppo importante, e troppo piena di dati sensibili, per darla in mano ad altri.

Questo è un mattone della [guida alle integrazioni dei dati in casa]({{ '/it/pillar/integrazioni-dati/' | relative_url }}), dove i flussi aziendali si automatizzano senza uscire dal recinto. Se vuoi un inbox agent sulla *tua* posta e sulle *tue* PEC, parti da [chi sono e come lavoro]({{ site.main_site }}/biografia/) o scrivimi due righe in [contatti]({{ site.main_site }}/contatti/).

## FAQ

**1. Perché non uso un assistente AI collegato a Gmail o Outlook?**
Perché per funzionare deve leggere tutta la casella e processarla sui suoi server: stai dando a un terzo l'accesso al flusso più sensibile che hai. In più la PEC italiana non vive nelle API di Google/Microsoft. L'agente IMAP self-hosted fa lo stesso lavoro tenendo i dati in casa.

**2. IMAP non è vecchio? Perché non le API moderne?**
IMAP è "vecchio" nel senso di standard, universale e stabile: qualsiasi casella lo parla, PEC comprese, senza legarti all'ecosistema di un gigante. È proprio questa apertura che lo rende la scelta sovrana: ti connetti direttamente, senza intermediari che si portano via i dati.

**3. Cos'è IMAP IDLE e perché non fare polling?**
IDLE è la modalità in cui il server ti *notifica* quando arriva posta, invece di farti chiedere di continuo ("c'è posta? c'è posta?"). Il polling spreca CPU e può farti bannare dal provider per comportamento abusivo. IDLE è a basso carico, in tempo reale, e non irrita il provider. Va rinnovato ogni ~29 minuti e accompagnato da un backoff sulle riconnessioni.

**4. L'agente legge le mail con un LLM? Non è di nuovo un problema privacy?**
No, se fatto bene: gran parte dello smistamento si fa con regole deterministiche (un allegato FatturaPA è una fattura, senza AI). Il modello linguistico interviene solo sull'ambiguo, gira **in locale**, e riceve solo il body ripulito dai dati sensibili. I dati non escono dal tuo server.

**5. Come gestisce le fatture elettroniche?**
Riconosce gli allegati XML FatturaPA nei loro formati reali: `.xml`, `.xml.p7m` (firmato, va sbustato) e dentro `.zip`. Estratto l'XML, ha i dati strutturati della fattura, che possono alimentare un RAG per interrogarle. Un agente che non sa gestire il `.p7m` firmato è inutile sulle fatture italiane.

**6. E i virus negli allegati?**
Ogni allegato passa da un antivirus locale (ClamAV in container) *prima* di essere aperto. La posta è il vettore numero uno di malware: se l'allegato è infetto, va in quarantena e non viene processato. Aprire allegati senza scansionarli è una porta spalancata.

**7. Cosa succede se l'agente si riavvia? Riprocessa tutto?**
No, grazie all'idempotenza sul Message-ID: l'agente tiene un registro delle mail già processate e salta quelle viste. Senza questo, dopo un riavvio riclassificherebbe le stesse mail all'infinito, scombinando le cartelle. È la difesa chiave contro i loop.

**8. Cosa fa l'agente quando non è sicuro di come classificare una mail?**
La mette nella cartella `da-umano`, non la forza in una casella a caso. Questa è la rete di sicurezza che rende l'automazione affidabile: l'agente smista da solo il chiaro e scala all'umano l'incerto. Meglio dieci mail da rivedere che una diffida persa o una fattura nello spam.

**9. Può rispondere alle PEC al posto mio?**
No, ed è una scelta di sicurezza: l'agente smista, non risponde. Una risposta con valore legale (com'è una PEC) non la manda un LLM. L'agente ti mette le PEC importanti davanti, presto, nella loro cartella; la risposta la scrivi tu.

**10. Quanto costa rispetto a un SaaS di inbox AI?**
L'agente self-hosted ha un costo di costruzione una tantum e poi gira quasi gratis (IDLE consuma pochissimo, ClamAV è gratuito, la classificazione spesso è a sole regole). Un SaaS ha un canone per casella e manda fuori la posta. Su più caselle e nel tempo l'in-casa conviene, e in più non regali il tuo sistema nervoso a un terzo.
