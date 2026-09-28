---
lang: it
permalink: /it/blog/backup-docker-postgres-n8n/
title: "Backup e restore di uno stack Docker con Postgres, n8n e volumi LLM: il drill mensile che nessuno fa (finché perde le esecuzioni)"
date: 2026-10-28 07:30:00 +0200
author: "Antonio Trento"
description: "Disaster recovery per uno stack Docker di PMI con Postgres, n8n e modelli LLM: RPO e RTO spiegati semplici, cosa è irriproducibile, dump vs snapshot, la encryption key di n8n, modelli da riscaricare, restore di prova mensile su VPS vuoto, 3-2-1 adattato e runbook da una pagina."
keywords: ["backup docker postgres n8n", "restore drill postgres", "volumi docker backup", "disaster recovery pmi", "n8n executions", "n8n encryption key backup"]
image: /assets/images/posts/backup-docker-postgres-n8n.jpg
pillar: stack-sovrano
related: [/it/blog/docker-pmi-stack-sovrano/, /it/blog/n8n-queue-mode-postgres/]
---

## Il backup c'era. Il restore no.

Il server dell'azienda ospita lo stack che negli ultimi mesi è diventato indispensabile: Postgres con i dati dell'applicazione interna e l'indice vettoriale dei documenti, n8n con una quarantina di workflow che collegano PEC, gestionale e CRM, un modello linguistico locale per classificare i documenti, un reverse proxy davanti. Un giovedì il disco del server si guasta. Nessun panico: "abbiamo i backup". Ogni notte uno script copia la cartella dei volumi Docker su un disco esterno.

Il restore inizia il venerdì mattina e finisce il martedì. Nel frattempo si scopre che:

- i file di Postgres copiati mentre il database era in funzione non sono utilizzabili: il database non parte, o parte con errori;
- per fortuna c'è anche un dump settimanale, vecchio di cinque giorni;
- n8n si avvia, i workflow ci sono, ma **tutte le credenziali risultano illeggibili**: la chiave di cifratura era nel filesystem del container, non nel backup, e senza chiave le credenziali salvate non si decifrano;
- nessuno ricorda con esattezza le variabili d'ambiente, le versioni delle immagini, la configurazione del proxy e del tunnel;
- le esecuzioni di n8n degli ultimi cinque giorni — incluse quelle in attesa di approvazione e quelle fallite da ripetere — sono perse, e con loro la traccia di quali PEC erano già state elaborate.

Il backup c'era. Quello che mancava era la prova che si potesse **ripristinare**. Questo pezzo è scritto con il tono di un runbook: niente teoria del disaster recovery per grandi aziende, ma ciò che serve a una PMI con uno stack Docker **per sapere, e non sperare, di poter ripartire**. Vediamo RPO e RTO in italiano semplice, cosa è davvero irriproducibile, dump contro snapshot per Postgres, n8n e la sua chiave di cifratura, cosa fare con i modelli LLM, il **drill mensile** di restore su una macchina vuota, la regola 3-2-1 adattata e il runbook da una pagina da stampare.

Lo stack di riferimento è quello descritto nel pezzo sullo [stack sovrano Docker per PMI]({{ '/it/blog/docker-pmi-stack-sovrano/' | relative_url }}); il metodo vale per qualsiasi composizione simile.

## RPO/RTO in italiano semplice

Due sigle che sembrano gergo da consulenti, ma che sono le due domande più importanti del disaster recovery.

**RPO (Recovery Point Objective): quanti dati puoi permetterti di perdere?** Se il server muore adesso, fino a quale momento nel passato devi poter tornare? Con un backup ogni notte, nel caso peggiore perdi quasi 24 ore di lavoro. Se in quelle 24 ore sono arrivate PEC, sono state registrate fatture, sono state eseguite automazioni, quel lavoro va ricostruito a mano, o è perso.

**RTO (Recovery Time Objective): quanto tempo puoi restare fermo?** Dal momento del guasto al momento in cui i sistemi funzionano di nuovo. Un'ora? Un giorno? Una settimana, come nell'esempio?

Queste due cifre **non le decide chi fa i backup**: le decide chi conosce il costo di un fermo e di una perdita di dati. La conversazione giusta con la direzione è concreta: "Se perdiamo le ultime 24 ore di PEC elaborate e di movimenti registrati, quanto ci costa ricostruirle? Se restiamo senza automazioni per tre giorni, cosa si ferma?". Le risposte fissano gli obiettivi, e gli obiettivi determinano la tecnica:

| Obiettivo dichiarato | Cosa serve, indicativamente |
|----------------------|-----------------------------|
| RPO 24 h, RTO 1–2 giorni | dump notturno, copia fuori sede, restore documentato e provato |
| RPO 1 h, RTO mezza giornata | dump frequenti o archiviazione continua dei WAL, restore automatizzato |
| RPO minuti, RTO ore | backup continuo con point-in-time recovery, macchina di riserva pronta |
| RPO ~0, RTO minuti | replica in tempo reale e failover: altra categoria di costo e complessità |

Per la maggior parte delle PMI con uno stack di automazione, un obiettivo realistico e sostenibile è **RPO di un'ora e RTO di mezza giornata**, o anche RPO 24 ore e RTO un giorno, purché **dichiarati per iscritto e verificati**. Un RPO di pochi minuti dichiarato senza essere mai stato provato vale meno di un RPO di 24 ore provato ogni mese.

## Cosa è irriproducibile (DB, volumi, credenziali)

Il primo passo pratico è distinguere ciò che si può **ricostruire** da ciò che, se perso, è perso per sempre. Si fa l'inventario degli artefatti dello stack e si classifica ciascuno.

### Elenco artefatti

| Artefatto | Esempio | Riproducibile? | Come si protegge |
|-----------|---------|----------------|------------------|
| Dati di Postgres | tabelle applicative, embedding, database di n8n | **no** | dump + (opzionale) WAL, copia fuori sede |
| Chiave di cifratura di n8n | `N8N_ENCRYPTION_KEY` | **no** | gestore di segreti + copia offline sigillata |
| Altri segreti | password DB, token API, credenziali PEC, chiavi del tunnel | **no** (rigenerabili solo in parte) | gestore di segreti con backup |
| Volumi con file utente | allegati, documenti caricati, dati binari di n8n | **no** | backup dei file, coerente con il DB |
| Configurazione | `docker-compose.yml`, `.env` senza segreti, config del proxy | sì, se versionata | repository git |
| Versioni delle immagini | `postgres:16.4`, `n8nio/n8n:1.x.y` | sì, se fissate | tag espliciti o digest nel compose |
| Modelli LLM | pesi scaricati da Ollama o Hugging Face | sì, **se versionati** | elenco con versioni/hash; backup solo se non riscaricabili |
| Indici derivati | indici vettoriali ricalcolabili, cache | sì, ma con costo | di norma si ricalcolano; backup se il ricalcolo è lungo |
| Log e metriche | log di container, dashboard | parzialmente | secondo policy di conservazione |
| Certificati TLS | emessi automaticamente dal proxy | sì | si rigenerano (attenzione ai limiti di emissione) |

Tre voci meritano una sottolineatura, perché sono quelle che fanno fallire i restore reali:

- **La chiave di cifratura di n8n** (ne parliamo sotto): senza, le credenziali salvate sono illeggibili.
- **I segreti in generale**: un backup del database senza le password per accedervi e i token per i servizi esterni ricostruisce i dati ma non il funzionamento. Il modo corretto di custodirli è un gestore di segreti con il proprio backup, come descritto nel pezzo sulla [gestione dei secrets per agenti LLM]({{ '/it/blog/secrets-agenti-llm-vault/' | relative_url }}).
- **La configurazione non versionata**: le variabili d'ambiente modificate "al volo" sul server, i file di configurazione del proxy editati a mano. Se non sono in un repository, al momento del restore saranno ricordi imprecisi.

## Postgres: dump vs snapshot

Postgres è quasi sempre il cuore dello stack: dati applicativi, spesso l'indice vettoriale con pgvector, e il database di n8n. Ci sono tre modi di proteggerlo, e uno sbagliato.

**Il modo sbagliato: copiare i file del volume a database acceso.** Un `tar` o un `rsync` della directory dei dati mentre Postgres scrive produce una copia incoerente: file copiati in momenti diversi, transazioni a metà. A volte il database riparte, spesso no, e non lo sai finché non ci provi. È esattamente ciò che è successo nell'esempio.

**Dump logico (`pg_dump`).** Esporta il contenuto del database in un formato portabile, coerente a un istante preciso (il dump lavora dentro una transazione). È il metodo più semplice e robusto per database fino a qualche decina di gigabyte:

- formato custom (`-Fc`), compresso, che permette restore selettivi e paralleli;
- indipendente dalla versione minore e dall'architettura: si può ripristinare su una macchina diversa;
- limite: l'RPO è l'intervallo tra un dump e l'altro, e per database grandi dump e restore richiedono tempo.

Attenzione: `pg_dump` salva **un database**. Ruoli, utenti e permessi sono **globali** al cluster e si salvano a parte con `pg_dumpall --globals-only`. Dimenticarli significa ripristinare i dati e scoprire che l'applicazione non riesce a collegarsi.

**Backup fisico con archiviazione dei WAL.** Un backup di base del cluster (con `pg_basebackup` o strumenti dedicati come pgBackRest o WAL-G) più l'archiviazione continua dei file WAL, il registro delle modifiche di Postgres. Permette il **point-in-time recovery**: ripristinare il database a qualsiasi istante, per esempio "alle 10:41, un minuto prima che qualcuno lanciasse la query sbagliata". RPO di minuti, al prezzo di una configurazione più complessa da impostare e da provare.

**Snapshot del filesystem o del disco.** Se il volume sta su un filesystem o su uno storage che supporta snapshot **atomici** (ZFS, LVM, i dischi di molti provider cloud), uno snapshot preso in un istante è equivalente, per Postgres, a un'interruzione di corrente: al riavvio il database esegue il recupero dai WAL e riparte coerente. Condizione essenziale: dati e WAL nello **stesso** snapshot atomico. Gli snapshot sono ottimi per ripartire in fretta sulla stessa infrastruttura, ma di solito **non sono fuori sede**: vanno affiancati da un dump o da un backup fisico copiato altrove.

La scelta pratica per una PMI:

- **Base**: `pg_dump -Fc` di ogni database più `pg_dumpall --globals-only`, ogni notte o ogni ora secondo l'RPO, copiati fuori sede e cifrati.
- **Se serve un RPO di minuti**: pgBackRest o WAL-G con archiviazione continua dei WAL su storage esterno.
- **In aggiunta, se l'infrastruttura li offre**: snapshot atomici per il ripristino rapido.

```bash
#!/usr/bin/env bash
# backup-db.sh — dump coerenti dei database + ruoli, cifrati e copiati fuori sede
set -euo pipefail
TS=$(date +%Y%m%d-%H%M)
DEST=/srv/backup/pg/$TS
mkdir -p "$DEST"

# ruoli e permessi (globali al cluster)
docker compose exec -T postgres pg_dumpall -U postgres --globals-only > "$DEST/globals.sql"

# un dump per database, formato custom
for DB in app n8n; do
  docker compose exec -T postgres pg_dump -U postgres -Fc "$DB" > "$DEST/$DB.dump"
  # verifica minima: il dump è leggibile e contiene oggetti
  docker compose exec -T postgres pg_restore --list < "$DEST/$DB.dump" | grep -q "TABLE" \
    || { echo "DUMP $DB NON VALIDO"; exit 1; }
done

# copia fuori sede cifrata (restic: repository e password da gestore di segreti)
restic backup "$DEST" --tag pg --host "$(hostname)"
restic forget --tag pg --keep-hourly 24 --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune

# segnale di vita per il monitor (se questo non arriva, allarme)
curl -fsS -m 10 "$HEARTBEAT_URL_BACKUP_DB" > /dev/null
```

L'ultima riga non è un dettaglio. Un backup che fallisce in silenzio è la regola, non l'eccezione: il disco di destinazione si riempie, una password cambia, un container viene rinominato. Ogni job di backup deve inviare un **segnale di completamento** a un sistema di monitoraggio che allarma quando il segnale **non** arriva.

## n8n: DB + encryption key

n8n merita un capitolo a parte, perché è il componente in cui un backup apparentemente completo si rivela inutile più spesso.

**Cosa contiene il database di n8n.** Con Postgres come database (la configurazione consigliata per un uso serio, e obbligatoria in modalità coda, come spiegato nel pezzo su [n8n in queue mode con Postgres]({{ '/it/blog/n8n-queue-mode-postgres/' | relative_url }})), il database contiene i workflow, le credenziali (cifrate), gli utenti, le impostazioni, e la **cronologia delle esecuzioni**: comprese quelle fallite, quelle in attesa (per esempio i workflow fermi su un nodo di attesa o di approvazione) e i dati che hanno elaborato, secondo le impostazioni di conservazione.

**La chiave di cifratura.** n8n cifra le credenziali salvate con una chiave. Se non viene fornita esplicitamente con la variabile `N8N_ENCRYPTION_KEY`, n8n la genera al primo avvio e la salva nella propria cartella di configurazione dentro il container (tipicamente in un file di configurazione sotto `/home/node/.n8n`). Se quella cartella non è su un volume persistente incluso nel backup, o se la chiave non è custodita altrove, **dopo un restore su una macchina nuova le credenziali non si decifrano più**. I workflow ci sono, ma ogni nodo che usa una credenziale fallisce, e bisogna reinserire a mano ogni password e ogni token — ammesso di averli ancora.

Le regole:

1. **Imposta `N8N_ENCRYPTION_KEY` esplicitamente**, con un valore generato e custodito nel gestore di segreti. Non lasciare che n8n la generi da solo.
2. **Custodiscine una copia offline**: stampata o in un supporto sigillato, insieme alle altre credenziali di emergenza. È la chiave che, se persa, rende inutile il backup.
3. **Includi nel backup il volume di n8n** (`/home/node/.n8n`), che oltre alla configurazione può contenere dati binari se n8n è configurato per salvarli su filesystem.
4. **Esporta periodicamente i workflow** in formato JSON (n8n offre un comando di esportazione da CLI) e versionali in git: non sostituisce il backup del database, ma permette di recuperare un singolo workflow o di vedere cosa è cambiato.

**Le esecuzioni.** Il titolo parla di "perdere le esecuzioni", e non è un caso. Con un RPO di 24 ore, dopo un restore n8n riparte con lo stato di ieri: le esecuzioni di oggi non esistono. Questo significa che:

- i trigger su email, PEC o webhook arrivati dopo il backup **non risultano elaborati** in n8n, ma i loro effetti esterni (un record creato nel CRM, un'email inviata) **esistono**;
- i workflow in attesa creati dopo il backup sono persi;
- al riavvio, alcuni trigger potrebbero **rielaborare** messaggi già elaborati, generando duplicati.

La mitigazione sta nel disegno dei workflow più che nel backup: stato di avanzamento nei **tuoi** dati (quale PEC è stata elaborata, per UID, come descritto nel pezzo su [IMAP IDLE e polling sulla PEC]({{ '/it/blog/imap-idle-vs-polling-pec/' | relative_url }})), azioni esterne **idempotenti**, e una procedura post-restore che riconcilia i sistemi esterni con lo stato ripristinato prima di riattivare i trigger.

## Modelli LLM: si riscaricano, non si backuppano sempre

Un modello linguistico locale può pesare da qualche gigabyte a decine di gigabyte. Metterlo nel backup notturno, con le sue copie fuori sede e la sua conservazione, costa spazio e tempo. Nella maggior parte dei casi **non serve**: i pesi sono pubblici e si possono riscaricare.

Ma "si possono riscaricare" è vero solo a due condizioni:

- **Sai esattamente quale versione usavi.** Un tag generico come "l'ultima versione del modello X" può puntare, domani, a pesi diversi, con comportamento diverso. Nel repository vanno registrati nome, versione e, dove possibile, l'hash o il digest dei pesi. Per Ollama, il nome completo del modello con il tag specifico; per modelli scaricati da Hugging Face, l'identificativo del repository e la revisione (il commit).
- **La fonte esiste ancora.** Un modello può essere ritirato, spostato, reso accessibile solo con autorizzazione. Per i modelli da cui dipende il funzionamento del sistema, conviene tenere **una copia** in uno storage economico, fuori dal backup quotidiano: si aggiorna solo quando cambia il modello.

Vanno invece **sempre** nel backup:

- i **modelli su cui hai fatto fine-tuning** o gli adattatori (LoRA): sono il frutto di un lavoro tuo, non riscaricabili;
- i **file di configurazione** del motore di inferenza (parametri, template di prompt, quantizzazione scelta);
- gli **indici vettoriali** se ricalcolarli richiede molte ore di calcolo; altrimenti basta poter rigenerare gli embedding dai documenti di origine, che invece vanno salvati.

Sul confronto tra motori di inferenza e sulle loro esigenze di storage, vale quanto scritto nel pezzo su [vLLM e Ollama in produzione]({{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }}).

## Ordine di restore

Il restore non si improvvisa: si segue un ordine, perché ogni componente dipende dai precedenti. Questo è l'ordine per lo stack di riferimento.

1. **Macchina e sistema**: nuovo server (o VPS) con sistema operativo, Docker e Docker Compose alle versioni documentate, firewall configurato.
2. **Segreti**: accesso al gestore di segreti (o alla copia di emergenza) e ricostruzione del file `.env` con password del database, `N8N_ENCRYPTION_KEY`, token API, credenziali del repository di backup.
3. **Configurazione**: clone del repository con `docker-compose.yml`, configurazioni del proxy e degli altri servizi, alle versioni di immagine fissate.
4. **Postgres vuoto**: avvio del **solo** container del database.
5. **Ruoli**: ripristino di `globals.sql` (utenti, ruoli, permessi).
6. **Database**: ripristino dei dump con `pg_restore` (o del backup fisico fino al punto desiderato), poi verifica delle estensioni (pgvector) e di qualche conteggio di controllo.
7. **Volumi di file**: ripristino dei file utente e del volume di n8n, coerenti con l'istante del database.
8. **Modelli**: download dei modelli alle versioni registrate (o copia dalla riserva), avvio del motore di inferenza e test di una richiesta.
9. **n8n con trigger disattivati**: avvio di n8n impedendo l'esecuzione automatica dei trigger (per esempio disattivando i workflow attivi prima di avviare, o con un'istanza che non esegue i trigger), verifica che le credenziali si decifrino aprendone una.
10. **Riconciliazione**: confronto tra lo stato ripristinato e i sistemi esterni (PEC elaborate, record creati nel CRM, pagamenti) per l'intervallo tra il backup e il guasto.
11. **Proxy, tunnel e DNS**: avvio del reverse proxy, del tunnel o aggiornamento del DNS verso la nuova macchina.
12. **Riattivazione graduale** dei trigger, a partire dai meno rischiosi, con controllo dei primi cicli.
13. **Verifica finale** con la checklist e annotazione dei tempi effettivi.

```bash
# restore-db.sh — passi 4-6 (estratto)
docker compose up -d postgres
until docker compose exec -T postgres pg_isready -U postgres; do sleep 2; done
docker compose exec -T postgres psql -U postgres < globals.sql
for DB in app n8n; do
  docker compose exec -T postgres createdb -U postgres -O "${DB}_owner" "$DB"
  docker compose exec -T postgres pg_restore -U postgres -d "$DB" --no-owner --role="${DB}_owner" \
    --exit-on-error < "$DB.dump"
done
docker compose exec -T postgres psql -U postgres -d app -c "SELECT extname, extversion FROM pg_extension;"
docker compose exec -T postgres psql -U postgres -d n8n -c "SELECT count(*) FROM workflow_entity;"
```

(Per database grandi conviene il restore parallelo con l'opzione `-j`, che però richiede di leggere il dump da un file e non da standard input: nello script reale si monta la cartella dei dump nel container. L'estratto mostra la sequenza, non l'ottimizzazione.)

## Drill: restore su VPS vuoto ogni mese

Ecco la parte che nessuno fa. Un backup non provato è un'ipotesi. L'unico modo per sapere se il restore funziona, quanto dura e cosa manca è **farlo**, regolarmente, su una macchina vuota.

**Perché una macchina vuota.** Ripristinare sullo stesso server, dove i segreti, le configurazioni e le immagini sono già presenti, nasconde esattamente ciò che manca. Il drill si fa su un VPS nuovo, creato per l'occasione e distrutto alla fine: costa pochi euro per qualche ora di utilizzo.

**Perché ogni mese.** Lo stack cambia: nuovi workflow, nuove variabili d'ambiente, un nuovo servizio aggiunto, una versione aggiornata. Un drill trimestrale lascia tre mesi di cambiamenti non verificati. Un drill mensile, dopo le prime volte, richiede una o due ore ed è in gran parte automatizzabile.

**Chi lo fa.** Idealmente, **non** chi ha costruito lo stack, seguendo solo il runbook. Se ci riesce, il runbook è completo. Se si blocca, hai trovato il buco prima che serva davvero.

### Checklist drill

- [ ] VPS nuovo creato, con sistema operativo alla versione documentata.
- [ ] Accesso ai segreti ottenuto seguendo **solo** la procedura di emergenza del runbook.
- [ ] Backup più recente scaricato dallo storage fuori sede (non dalla copia locale).
- [ ] Ruoli e database ripristinati senza errori; conteggi di controllo coerenti con la produzione al momento del backup.
- [ ] Estensioni presenti (pgvector) e una query vettoriale di prova eseguita.
- [ ] Volumi di file ripristinati; un documento a caso aperto e leggibile.
- [ ] n8n avviato con trigger disattivati; **una credenziale aperta e decifrata** correttamente.
- [ ] Un workflow di prova eseguito manualmente fino alla fine (su sistemi di test).
- [ ] Modello LLM scaricato alla versione registrata; una richiesta di prova con risposta sensata.
- [ ] Proxy avviato con certificato valido (anche di staging) sulla macchina di prova.
- [ ] **RPO effettivo** misurato: istante dell'ultimo dato presente nel restore rispetto al momento del drill.
- [ ] **RTO effettivo** misurato: dall'inizio alla fine della checklist.
- [ ] Ogni blocco o passaggio mancante annotato e il runbook aggiornato.
- [ ] VPS distrutto e dati di prova eliminati.

Il risultato del drill è un breve verbale: data, chi l'ha eseguito, RPO e RTO effettivi, problemi trovati, correzioni fatte. Dopo qualche mese, la serie di verbali è la prova più solida che lo stack è gestito seriamente, e un elemento utile anche per le verifiche di sicurezza e di conformità.

## Offsite e 3-2-1 adattato a PMI

La regola classica del backup è **3-2-1**: tre copie dei dati, su due supporti diversi, di cui una fuori sede. Per una PMI con uno stack Docker, un adattamento sensato:

- **Copia 1**: i dati in produzione.
- **Copia 2**: backup locale recente (dump e file) su un disco diverso da quello dei dati, o su un NAS in ufficio, per restore rapidi di errori banali ("ho cancellato un workflow").
- **Copia 3**: backup **fuori sede, cifrato**, su uno storage a oggetti di un provider europeo o su un server in un'altra sede, con conservazione storica (orari, giornalieri, settimanali, mensili).

A cui si aggiungono due accorgimenti che la regola originale non prevedeva, ma che oggi sono indispensabili:

- **Immutabilità o almeno separazione delle credenziali.** Un ransomware che cifra il server e trova le credenziali del backup cancella anche il backup. Lo storage fuori sede deve essere scrivibile dal server ma **non cancellabile** con le stesse credenziali: blocco degli oggetti (object lock) dove disponibile, oppure un account separato per la gestione della conservazione, o un sistema che "tira" i backup dal server invece di farseli "spingere".
- **Cifratura lato client.** I backup contengono tutti i dati dell'azienda, spesso personali. Vanno cifrati prima di uscire dal server, con chiavi custodite nel gestore di segreti e in copia di emergenza. Strumenti come restic o Borg lo fanno nativamente.

Sui costi, un ordine di grandezza dichiarato come stima: per uno stack tipico con qualche decina di gigabyte di dati, lo storage fuori sede con conservazione di un anno costa nell'ordine di **pochi euro o qualche decina di euro al mese**, e un VPS per il drill mensile qualche euro per poche ore. Il costo vero è il tempo: impostazione iniziale di qualche giornata, poi una o due ore al mese per il drill. Confrontato con i quattro giorni di fermo dell'esempio, è una delle spese più facili da giustificare.

## Runbook da una pagina stampabile

Il documento che serve il giorno del guasto non è un manuale di trenta pagine: è **una pagina**, stampata e custodita anche fuori dai sistemi (il giorno in cui il server è giù, potrebbe esserlo anche il wiki). Contiene solo ciò che serve per partire, e rimanda al repository per i dettagli.

```
RUNBOOK DR — STACK AUTOMAZIONE                         versione 2026-10 · ultimo drill: gg/mm
─────────────────────────────────────────────────────────────────────────────────────────────
OBIETTIVI      RPO 1 h (dump orari)   ·   RTO 4 h
CONTATTI       responsabile: ________  tel ________   ·   supporto provider VPS: ________
SEGRETI        gestore segreti: ________   ·   copia emergenza: busta sigillata, cassaforte ___
BACKUP         repository fuori sede: ________   ·   locale: NAS ufficio /backup/stack
CONFIG         repo git: ________ (tag = versione in produzione)

ORDINE DI RESTORE
 1  nuovo server: OS ___, Docker ___                  8  modelli: vedi models.lock nel repo
 2  segreti -> .env (N8N_ENCRYPTION_KEY!)             9  n8n con trigger OFF; apri 1 credenziale
 3  git clone + checkout tag                         10  riconcilia PEC/CRM dal backup al guasto
 4  up postgres                                       11  proxy / tunnel / DNS
 5  globals.sql                                      12  riattiva trigger, dai meno rischiosi
 6  pg_restore app, n8n + verifica conteggi          13  checklist finale, annota tempi
 7  restore volumi file + n8n

NON FARE       non riattivare i trigger prima della riconciliazione · non ripristinare sopra
               il server guasto senza copia dello stato attuale · non disattivare TLS "per fare prima"
DOPO           verbale: cause, RPO/RTO effettivi, dati persi, azioni correttive
```

Il runbook si aggiorna **dopo ogni drill** e dopo ogni modifica rilevante dello stack. La data dell'ultimo drill in testa al foglio è un promemoria brutale: se è di sei mesi fa, il foglio non è più affidabile.

## Architettura di riferimento

```
  SERVER PRODUZIONE                                   FUORI SEDE (UE)
  ┌───────────────────────────────────────┐          ┌──────────────────────────────┐
  │ postgres (app, n8n)  ──pg_dump/WAL──┐  │          │ storage a oggetti            │
  │ n8n (+volume .n8n)  ──file──────────┤  │  restic  │ cifrato, conservazione       │
  │ volumi file utente  ──file──────────┼──┼────────► │ oggetti non cancellabili     │
  │ inferenza LLM (modelli: models.lock)│  │          │ dal server                   │
  │ proxy / tunnel                      │  │          └──────────────────────────────┘
  └─────────────────────────────────────┼──┘
                                        ▼                        ▲ mensile
                                  NAS ufficio                   │
                                  (copia locale recente)   VPS VUOTO: DRILL
  git: compose, config, models.lock, export workflow        (restore, checklist, distruzione)
  gestore segreti: password, token, N8N_ENCRYPTION_KEY  + copia di emergenza offline
  monitor: heartbeat di ogni job di backup -> allarme se manca
```

**Cosa non tocca il backup**: i pesi dei modelli pubblici (riscaricabili alle versioni registrate), i certificati TLS (rigenerabili), le cache e gli indici ricalcolabili in tempi accettabili. **Cosa non deve mai mancare**: dati di Postgres coerenti, file utente, segreti e la chiave di cifratura di n8n, configurazione versionata.

## Fallimenti tipici e come li riconosci

- **Database che non riparte dopo il restore.** Errori di file mancanti o di checkpoint: i file erano stati copiati a caldo. Serve un dump o un backup fisico corretto.
- **Credenziali di n8n illeggibili.** Errori di decifratura all'apertura di una credenziale: manca la `N8N_ENCRYPTION_KEY` originale.
- **L'applicazione non si collega al database ripristinato.** Errori di autenticazione per ruoli inesistenti: dimenticato `pg_dumpall --globals-only`.
- **Backup vuoti o vecchi da settimane.** Nessuno se ne accorge finché non servono: manca il monitoraggio del segnale di completamento.
- **Duplicati dopo il restore.** PEC rielaborate, record creati due volte: trigger riattivati prima della riconciliazione, azioni non idempotenti.
- **Comportamento diverso del modello.** Classificazioni che cambiano dopo il restore: il modello riscaricato non era la stessa versione.
- **Backup cancellati insieme al server.** Dopo un attacco, anche il repository di backup è stato svuotato: le credenziali del server permettevano la cancellazione.
- **Restore riuscito solo a chi l'ha costruito.** Il drill si blocca quando lo esegue qualcun altro: il runbook dà per scontati passaggi che esistono solo nella testa di una persona.

## Quando NON farlo (o farlo più semplice)

- **Se lo stack è in prova** e nessun processo reale dipende da esso, un dump giornaliero fuori sede e la chiave di n8n custodita bastano; il drill può aspettare che diventi indispensabile. Ma fissa una data: gli stack "in prova" diventano indispensabili senza avvisare.
- **Se usi servizi gestiti** (database gestito dal provider, n8n in cloud), una parte del backup è responsabilità del fornitore: verifica cosa copre davvero, per quanto tempo e se puoi esportare i dati in autonomia. Il drill resta utile, sull'esportazione.
- **Non inseguire un RPO di minuti** se nessuno ha dichiarato che serve: la complessità dell'archiviazione continua va giustificata da un costo della perdita di dati che la richiede.
- **Non fare backup dei modelli pubblici** ogni notte: registra le versioni e tieni una copia di riserva solo di quelli critici.

## Checklist operativa

- [ ] RPO e RTO dichiarati per iscritto da chi conosce il costo del fermo.
- [ ] Inventario degli artefatti con classificazione riproducibile / irriproducibile.
- [ ] Dump coerenti di ogni database più ruoli globali; nessuna copia a caldo dei file di Postgres.
- [ ] Archiviazione dei WAL se l'RPO lo richiede.
- [ ] `N8N_ENCRYPTION_KEY` impostata esplicitamente, nel gestore di segreti e in copia offline.
- [ ] Volume di n8n e file utente nel backup; workflow esportati in git.
- [ ] Versioni di immagini e modelli fissate e registrate nel repository.
- [ ] Copia fuori sede cifrata, non cancellabile con le credenziali del server.
- [ ] Heartbeat di ogni job di backup con allarme sull'assenza.
- [ ] Ordine di restore documentato, con trigger disattivati e riconciliazione prima della ripartenza.
- [ ] Drill mensile su VPS vuoto, eseguito seguendo solo il runbook, con verbale.
- [ ] Runbook da una pagina stampato e aggiornato dopo ogni drill.

## Il verdetto

Uno stack Docker con Postgres, n8n e un modello locale è facile da mettere in piedi e facile da perdere. I backup, quasi sempre, ci sono: una copia notturna dei volumi, un dump ogni tanto. Quello che manca è la risposta alla domanda che conta: **se il server muore adesso, in quanto tempo ripartiamo e cosa perdiamo?** Senza un restore provato, la risposta è una speranza. E n8n senza backup della sua chiave di cifratura e del suo database è **teatro**: sembra protetto finché non serve.

Il metodo è semplice, anche se richiede disciplina: dichiarare **RPO e RTO**, fare l'inventario di ciò che è irriproducibile, usare dump coerenti invece di copie a caldo, custodire segreti e chiave di n8n come il bene più prezioso, registrare le versioni dei modelli invece di salvarli ogni notte, portare i backup fuori sede cifrati e al riparo dalla cancellazione, e soprattutto **provare il restore ogni mese su una macchina vuota**, seguendo un runbook da una pagina.

Il drill mensile è l'attività che nessuno fa, perché non produce niente di visibile. Produce una cosa sola: la certezza, verificata, che il giorno del guasto sarà una giornata difficile e non una settimana persa.

Se il tuo stack di automazione è cresciuto più in fretta delle procedure per proteggerlo, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Si parte dal primo drill su una macchina vuota: in genere, è lì che si scopre cosa manca.

## FAQ

### Cosa significano RPO e RTO?
L'RPO (Recovery Point Objective) è la quantità massima di dati che si può accettare di perdere, espressa in tempo: con un backup ogni notte, fino a circa 24 ore. L'RTO (Recovery Time Objective) è il tempo massimo di fermo accettabile, dal guasto alla ripartenza. Li decide chi conosce il costo di una perdita di dati e di un fermo, e determinano la tecnica di backup necessaria.

### Posso fare il backup di Postgres copiando il volume Docker?
Non a database acceso con una semplice copia dei file: si ottiene una copia incoerente che spesso non riparte. Si possono usare dump logici con pg_dump, backup fisici con pg_basebackup o strumenti come pgBackRest e WAL-G, oppure snapshot atomici del filesystem che includano dati e WAL nello stesso istante.

### Meglio pg_dump o backup con WAL?
pg_dump è semplice, portabile e sufficiente per database fino a qualche decina di gigabyte con un RPO di ore. Il backup fisico con archiviazione continua dei WAL permette di ripristinare a qualsiasi istante, con RPO di minuti, ma è più complesso da configurare e provare. Molte PMI partono dai dump e passano ai WAL solo se l'RPO dichiarato lo richiede.

### Perché dopo il restore n8n non riesce a leggere le credenziali?
Perché n8n cifra le credenziali con una chiave che, se non impostata con la variabile N8N_ENCRYPTION_KEY, viene generata al primo avvio e salvata nella cartella di configurazione del container. Se quella chiave non è stata salvata, le credenziali ripristinate non si decifrano. La chiave va impostata esplicitamente, custodita in un gestore di segreti e in copia di emergenza.

### Cosa succede alle esecuzioni di n8n dopo un restore?
n8n riparte con lo stato del momento del backup: le esecuzioni successive, comprese quelle in attesa, non esistono più, mentre i loro effetti esterni restano. Per questo, prima di riattivare i trigger, bisogna riconciliare lo stato con i sistemi esterni, e i workflow dovrebbero usare azioni idempotenti e tenere lo stato di avanzamento nei propri dati.

### Devo fare il backup dei modelli LLM?
Dei modelli pubblici di norma no: basta registrare nome, versione e hash e riscaricarli. Conviene tenere una copia di riserva, fuori dal backup quotidiano, dei modelli critici che potrebbero diventare irreperibili. I modelli con fine-tuning, gli adattatori e le configurazioni del motore di inferenza vanno invece sempre inclusi nel backup.

### Ogni quanto va provato il restore?
Ogni mese è una frequenza ragionevole per uno stack che cambia: dopo le prime volte richiede una o due ore. Il drill va fatto su una macchina vuota, seguendo solo il runbook, possibilmente da una persona diversa da chi ha costruito lo stack, misurando RPO e RTO effettivi e annotando ogni problema.

### Come si applica la regola 3-2-1 a una PMI?
Tre copie dei dati: produzione, un backup locale recente su un supporto diverso e un backup fuori sede cifrato con conservazione storica. In più, la copia fuori sede non deve essere cancellabile con le credenziali del server, per resistere a un ransomware, e i dati vanno cifrati prima di uscire dal server.

### Quanto costa un disaster recovery serio per una PMI?
Come stima, per qualche decina di gigabyte, lo storage fuori sede con un anno di conservazione costa da pochi euro a qualche decina di euro al mese, e un VPS per il drill mensile qualche euro per poche ore. La voce principale è il tempo: qualche giornata per l'impostazione iniziale e una o due ore al mese per il drill.

### Cosa deve contenere il runbook di disaster recovery?
Una pagina con obiettivi RPO e RTO, contatti, dove trovare segreti, backup e configurazione, l'ordine di restore, le cose da non fare e cosa annotare dopo. Va stampata e custodita anche fuori dai sistemi, riportare la data dell'ultimo drill ed essere aggiornata dopo ogni drill e ogni modifica rilevante dello stack.
