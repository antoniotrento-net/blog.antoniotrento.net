---
lang: it
permalink: /it/blog/n8n-credentials-vault-infisical/
title: "n8n credentials vs Infisical/Vault: quando il database delle credenziali di n8n diventa il tuo unico punto di fallimento"
date: 2026-11-16 07:30:00 +0200
author: "Antonio Trento"
description: "Come n8n cifra le credenziali e cosa succede se perdi N8N_ENCRYPTION_KEY, come fare il backup della chiave, quando passare a un vault esterno (Infisical, Vault/OpenBao), come ruotare i token senza fermare i flow, modello a tre ambienti, audit di chi ha visto un segreto e procedura di disaster della chiave."
keywords: ["n8n credentials vault infisical", "n8n encryption key", "secret management pmi", "backup credenziali automazione", "infisical docker", "rotazione token n8n"]
image: /assets/images/posts/n8n-credentials-vault-infisical.jpg
pillar: stack-sovrano
related: [/it/blog/secrets-agenti-llm-vault/, /it/blog/backup-docker-postgres-n8n/]
---

## Il server è ripartito. Le credenziali no.

Un venerdì sera il disco del VPS che ospita n8n si riempie, il container va in crash, qualcuno lo ricrea con un `docker compose up` "pulito" dopo aver liberato spazio. Il database Postgres è intatto, montato su un volume separato. I workflow ci sono tutti: si vedono nell'editor, con i loro nodi e le loro connessioni. Ma ogni esecuzione fallisce con lo stesso errore: le credenziali non si possono decifrare.

Il motivo è una riga che nessuno aveva mai guardato. La chiave con cui n8n cifra le credenziali non era impostata come variabile d'ambiente: n8n l'aveva generata da solo al primo avvio e salvata in un file dentro la cartella dati del container. La cartella non era su un volume persistente. Ricreando il container, la chiave è sparita. Con lei, la possibilità di leggere quaranta credenziali: token del CRM, password SMTP, chiavi API, accessi al gestionale, la PEC.

Il lunedì successivo è stato speso a ricreare credenziali una per una, chiedendo password a colleghi, fornitori, consulenti. Alcune non le aveva più nessuno.

Questo pezzo parla di **credenziali di n8n e vault esterni come Infisical o Vault**: come n8n conserva i segreti, perché la chiave di cifratura è il vero punto di fallimento, come si fa il backup di quella chiave, quando ha senso spostare i segreti in un vault esterno, come si ruotano i token senza fermare i flow, come si separano gli ambienti, come si capisce chi ha avuto accesso a un segreto, e cosa fare il giorno in cui la chiave si perde o esce.

Il discorso generale sui segreti degli agenti (`.env`, Docker secrets, vault, redaction) l'ho fatto nel pezzo sui [segreti degli agenti LLM]({{ '/it/blog/secrets-agenti-llm-vault/' | relative_url }}). Qui scendo nel caso specifico di n8n, che ha regole sue e un errore tipico tutto suo.

## È per te / non è per te

È per te se:

- hai n8n self-hosted in produzione, con credenziali verso sistemi che contano (CRM, ERP, email, banche, PA);
- non sai, a memoria, dove sta la tua `N8N_ENCRYPTION_KEY`;
- il team che costruisce workflow sta crescendo, o hai più ambienti (sviluppo, test, produzione).

Non è per te se usi n8n in cloud gestito: lì la cifratura e la chiave le gestisce il fornitore, e il tuo problema è un altro (chi ha accesso al workspace). E non è per te se hai tre workflow personali senza credenziali sensibili: la sezione sul backup della chiave ti serve comunque, il resto no.

## Dove stanno le credenziali e con quale chiave

In n8n self-hosted, le credenziali — tutto ciò che crei nella sezione Credentials: token OAuth, chiavi API, utenti e password — sono salvate **nel database di n8n** (SQLite di default, Postgres nelle installazioni serie), in una tabella dedicata. Il campo con i dati sensibili è **cifrato** con una chiave simmetrica: la **encryption key** dell'istanza.

La chiave arriva da una di due fonti:

1. **la variabile d'ambiente `N8N_ENCRYPTION_KEY`**, se impostata;
2. altrimenti, **un file di configurazione nella cartella dati di n8n** (nel container, tipicamente nella cartella `.n8n` della home dell'utente `node`), dove n8n scrive una chiave casuale generata al primo avvio.

La seconda opzione è quella di default, ed è quella che fa danni. Se la cartella dati è su un volume persistente e ne fai il backup, va bene, finché qualcuno non cambia il volume. Se non è persistente, la chiave vive quanto il container.

Tre cose da sapere subito:

- **I workflow non sono cifrati.** La definizione dei workflow (nodi, connessioni, parametri) è in chiaro nel database. Nei workflow c'è solo un riferimento alla credenziale (ID e nome), non il segreto.
- **I dati delle esecuzioni non sono cifrati** con quella chiave. Se un nodo riceve un token in una risposta HTTP e lo passa avanti, quel token può finire in chiaro nello storico delle esecuzioni. È un problema diverso, ma reale: limita il salvataggio dei dati di esecuzione sui workflow che maneggiano segreti.
- **Tutte le istanze che condividono un database devono avere la stessa chiave.** In queue mode, main e worker leggono le stesse credenziali: una chiave diversa su un worker produce errori di decifratura solo sulle esecuzioni che finiscono su quel worker, il tipo di guasto intermittente più odioso da diagnosticare. Ne ho parlato nel pezzo su [n8n in queue mode con Postgres]({{ '/it/blog/n8n-queue-mode-postgres/' | relative_url }}).

## Perdere N8N_ENCRYPTION_KEY = perdere i flow

Il titolo della sezione è volutamente brutale, e va precisato. Se perdi la chiave non perdi i workflow come definizioni: restano nel database, li puoi aprire, esportare, leggere. Perdi **tutte le credenziali**: diventano dati cifrati che nessuno può più leggere. E un workflow senza credenziali, in un'installazione che parla con dieci sistemi esterni, è un disegno.

Recuperare significa:

- per ogni credenziale, ritrovare il segreto originale (o generarne uno nuovo dal sistema di origine);
- ricrearla in n8n, possibilmente con lo stesso nome, e riassociarla ai workflow che la usavano;
- per le credenziali OAuth, ripetere il flusso di autorizzazione, spesso con un amministratore del sistema esterno;
- verificare ogni workflow, perché qualche associazione salterà.

Con 10 credenziali è una giornata storta. Con 80, distribuite su sistemi di fornitori diversi, è una settimana di lavoro e qualche flusso che resta fermo finché un fornitore non risponde.

> **Avvertenza sulla encryption key.** La `N8N_ENCRYPTION_KEY` è l'unica cosa che permette di leggere le credenziali salvate in n8n. Non esiste un meccanismo di recupero: senza la chiave, le credenziali sono perse. Va impostata esplicitamente prima del primo avvio in produzione, conservata fuori dal server in almeno due posti, mai committata in un repository, e identica su tutte le istanze (main e worker) che usano lo stesso database. Chi ha la chiave e una copia del database ha **tutti** i segreti dell'automazione in chiaro.

L'ultima frase è l'altra faccia della medaglia: la chiave non va solo protetta dalla perdita, va protetta dalla fuga. Un backup del database e un file `.env` nella stessa cartella sono un pacchetto completo per chiunque lo trovi.

## Backup della chiave: procedure

La chiave è una stringa. Il suo backup è banale tecnicamente e difficile organizzativamente: deve sopravvivere al server, alle persone che cambiano, ai traslochi di infrastruttura, e allo stesso tempo non deve finire dove non deve.

### Impostarla esplicitamente

Primo passo, prima di tutto: la chiave va **impostata**, non lasciata generare. Se l'istanza è già in produzione con una chiave auto-generata, si recupera quella dal file di configurazione e la si imposta come variabile, così smette di dipendere dal file.

```bash
# recupero della chiave auto-generata da un'istanza esistente (container in esecuzione)
docker compose exec n8n sh -c 'cat /home/node/.n8n/config'
# {"encryptionKey":"..."}  ← questo valore va salvato come segreto e impostato in modo esplicito

# generazione di una chiave nuova per un'installazione nuova (prima del primo avvio!)
openssl rand -base64 48 > ./secrets/n8n_encryption_key
chmod 600 ./secrets/n8n_encryption_key
```

E nel compose, come Docker secret invece che come variabile in chiaro nel file. n8n supporta il suffisso `_FILE` per leggere il valore di molte variabili da un file: verifica sulla documentazione della tua versione l'elenco esatto, e dopo il primo avvio controlla che una credenziale si apra davvero.

```yaml
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:1.x.y     # versione fissata
    environment:
      N8N_ENCRYPTION_KEY_FILE: /run/secrets/n8n_encryption_key
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PASSWORD_FILE: /run/secrets/n8n_db_password
    secrets:
      - n8n_encryption_key
      - n8n_db_password
    volumes:
      - n8n_data:/home/node/.n8n

secrets:
  n8n_encryption_key:
    file: ./secrets/n8n_encryption_key
  n8n_db_password:
    file: ./secrets/n8n_db_password

volumes:
  n8n_data: {}
```

### Dove conservarla

Le regole che uso, adattate a una PMI:

- **Due copie fuori dal server**, in luoghi indipendenti: per esempio il password manager aziendale (in una cassaforte accessibile a due persone) e una copia cifrata stampata o su supporto offline in cassaforte fisica.
- **Mai nello stesso posto del backup del database.** Il backup notturno di Postgres va offsite; la chiave va in un posto diverso, con accessi diversi. Se un attaccante ruba il bucket dei backup, non deve trovarci anche la chiave.
- **Due custodi.** Due persone (per esempio il titolare o un responsabile e chi gestisce l'infrastruttura) sanno dove sta e possono recuperarla. Nessuna delle due da sola deve essere il punto di fallimento umano.
- **Cifrata a riposo** se sta su file: un semplice file cifrato con una passphrase custodita separatamente.

```bash
# copia cifrata della chiave per l'archivio offline (age: strumento semplice e moderno)
age -p -o n8n_encryption_key.age ./secrets/n8n_encryption_key
# la passphrase va nel password manager aziendale, NON accanto al file .age

# verifica periodica (trimestrale): la copia d'archivio decifra e coincide con quella in uso
age -d n8n_encryption_key.age | diff - ./secrets/n8n_encryption_key && echo "copia OK"
```

### Il test che nessuno fa

Un backup della chiave non verificato non è un backup. Il test è lo stesso del pezzo sul [backup e restore di uno stack Docker con Postgres e n8n]({{ '/it/blog/backup-docker-postgres-n8n/' | relative_url }}): una volta al trimestre, su una macchina vuota, si ripristina il database dall'ultimo backup, si avvia n8n con la chiave recuperata **dall'archivio** (non da quella in uso), e si esegue un workflow di prova che usa una credenziale vera. Se parte, la catena funziona. Se non parte, l'hai scoperto in un giorno tranquillo.

### Esportare le credenziali: con molta cautela

n8n ha comandi da riga di comando per esportare e importare credenziali. L'esportazione può essere fatta in forma **cifrata** (utile come backup aggiuntivo, ma leggibile solo con la stessa chiave) o **decifrata** (tutti i segreti in chiaro in un file JSON). La seconda è uno strumento per migrazioni e disaster recovery, non per i backup di routine: un file con tutti i segreti in chiaro è il bersaglio più prezioso dell'intera infrastruttura. Se serve, si fa su una macchina controllata, il file vive minuti, e si cancella in modo sicuro subito dopo l'import.

## Vault esterno: quando il team cresce

Con due persone che costruiscono workflow, le credenziali dentro n8n vanno benissimo, purché chiave e backup siano fatti bene. Le cose cambiano quando:

- **più persone creano e usano credenziali**, e non è chiaro chi ha accesso a cosa;
- **gli stessi segreti servono anche fuori da n8n** (script, altre applicazioni, agenti), e vivono in tre copie che divergono;
- **la rotazione diventa frequente** o imposta da policy, e aggiornarla a mano in n8n, negli script e nei `.env` è un rito che qualcuno salta;
- **ci sono più ambienti**, con segreti diversi per ognuno;
- **serve un audit** di chi ha letto o modificato un segreto, per un cliente, un audit interno o un incidente.

A quel punto conviene spostare la **fonte di verità** dei segreti in un vault esterno, e lasciare a n8n il ruolo di consumatore.

### Le opzioni self-hosted

- **Infisical**: secret manager open source, si installa con Docker, ha un'interfaccia web comprensibile anche a chi non è un sistemista, gestisce progetti, ambienti, versioni dei segreti, accessi per persona e per macchina. Per una PMI è spesso il compromesso migliore tra potenza e semplicità. Alcune funzioni avanzate sono nella versione a pagamento: verifica cosa ti serve.
- **HashiCorp Vault**: lo standard di fatto nelle aziende più strutturate, potentissimo (segreti dinamici, PKI, cifratura come servizio), ma più complesso da gestire (unseal, policy, alta disponibilità). Dal 2023 la licenza non è più open source in senso stretto: chi vuole restare su una licenza aperta guarda a **OpenBao**, il fork comunitario.
- **Il gestore di segreti del tuo cloud europeo**, se sei già su un provider con un servizio equivalente: va bene se il resto dello stack è lì.

### Come si collega n8n

Le strade sono due, con differenze importanti.

**1. Funzione "external secrets" di n8n.** Nelle edizioni a pagamento, n8n si collega nativamente a vari secret manager (tra cui Vault e Infisical) e permette di usare i segreti del vault dentro i campi delle credenziali con un'espressione del tipo `$secrets.<provider>.<nome>`. Il segreto non viene salvato nel database di n8n: viene letto dal vault e tenuto in una cache che si aggiorna periodicamente. È la soluzione più pulita, ma richiede la licenza.

**2. Iniezione dei segreti all'avvio.** Con l'edizione community, si usa il vault per popolare le variabili d'ambiente o i file dei Docker secrets all'avvio del container (con la CLI del vault o un agente sidecar), e si limitano le credenziali in n8n a ciò che può leggere variabili d'ambiente, oppure si continua a salvarle in n8n ma generandole e aggiornandole via API a partire dal vault. Funziona, ma è più artigianale, e il database di n8n torna a contenere i segreti.

Per molte PMI la scelta pragmatica è intermedia: la **chiave di cifratura di n8n** e i segreti dell'infrastruttura (password del database, chiavi dei backup) stanno nel vault e vengono iniettati all'avvio; le **credenziali applicative** restano in n8n, con un registro nel vault di quali esistono, chi le possiede e quando vanno ruotate. Il vault diventa il posto dove sta la verità, anche quando n8n tiene una copia operativa.

## Rotazione token API nei nodi

Ruotare un segreto senza fermare i flow è un problema di sequenza, non di tecnologia. La regola chiave in n8n: **una credenziale ha un ID, e i workflow fanno riferimento a quell'ID**. Se aggiorni il valore dentro la stessa credenziale, tutti i workflow che la usano prendono il nuovo valore alla prossima esecuzione, senza modifiche.

### Runbook rotazione

Per un token API classico (chiave statica):

1. **Inventario**: quali workflow usano quella credenziale (nell'interfaccia, o interrogando il database per i riferimenti all'ID), e se lo stesso segreto è usato anche fuori da n8n.
2. **Genera il nuovo token** sul sistema di origine, **senza revocare il vecchio**. Quasi tutti i sistemi permettono due chiavi attive contemporaneamente; se non lo permettono, serve una finestra di manutenzione.
3. **Aggiorna la credenziale esistente** in n8n (stesso ID, nuovo valore). Se usi un vault con external secrets, aggiorna il segreto nel vault e attendi (o forza) l'aggiornamento della cache.
4. **Esegui un workflow di prova** che usa la credenziale, o la funzione di test della credenziale.
5. **Osserva le esecuzioni reali** per un periodo adeguato alla frequenza dei flussi (un'ora per quelli frequenti, un giorno per quelli giornalieri): nessun errore 401/403.
6. **Revoca il vecchio token** sul sistema di origine.
7. **Osserva ancora**: se qualcosa fallisce ora, c'era un uso del vecchio token che non era nell'inventario (uno script, un'altra istanza, un collega). Annotalo.
8. **Registra la rotazione**: data, chi, motivo, prossima scadenza.

Per le credenziali **OAuth2** la rotazione è diversa: il token di accesso si rinnova da solo, ma il client secret dell'applicazione OAuth va ruotato sul provider e aggiornato nella credenziale; a volte il cambio richiede di rifare l'autorizzazione. Va pianificato con chi amministra il sistema esterno.

Per le **password di servizio** (SMTP, database esterni, PEC) vale lo stesso schema, ma raramente ci sono due password attive: serve una breve finestra, fuori dagli orari in cui i flussi girano.

Un dettaglio che fa risparmiare ore: dai alle credenziali **nomi parlanti e una nota** (sistema, ambiente, proprietario, data di scadenza o di prossima rotazione). "HTTP Header Auth account 3" non dice niente a nessuno tra sei mesi.

## Ambienti: dev/staging/prod e credenziali miste

L'errore che vedo più spesso nelle installazioni n8n cresciute in fretta: **un'unica istanza** in cui convivono workflow di prova e di produzione, con credenziali di produzione usate per "provare velocemente". Il workflow di test che manda una mail a tutti i clienti con l'SMTP vero è un classico.

### Modello a 3 ambienti

| | Sviluppo | Staging | Produzione |
|---|---|---|---|
| Istanza n8n | separata (anche locale) | separata | separata |
| Encryption key | propria | propria | propria, con backup e custodi |
| Credenziali | sandbox dei sistemi esterni, account di test | sandbox o copie dedicate, mai di produzione | di produzione, accesso ristretto |
| Chi crea workflow | sviluppatori | nessuno a mano: arrivano da sviluppo | nessuno a mano: arrivano da staging |
| Dati | finti o sintetici | finti o anonimizzati | reali |
| Segreti nel vault | progetto/ambiente "dev" | ambiente "staging" | ambiente "prod", accessi nominativi |

Le regole che rendono il modello reale:

- **Nomi delle credenziali identici** nei tre ambienti (per esempio `crm-api`), con valori diversi. Quando un workflow passa da un ambiente all'altro, le credenziali si riassociano per nome.
- **Promozione dei workflow** via esportazione/importazione JSON o via sincronizzazione con Git (nelle edizioni che la supportano), **senza** credenziali: i file esportati contengono i riferimenti, non i segreti.
- **Le chiavi di cifratura sono diverse** per ambiente. Una copia del database di staging, anche se finisce nel posto sbagliato, non apre niente di produzione.
- **Nessuna credenziale di produzione in sviluppo**, nemmeno "per un attimo". Se un caso si riproduce solo con i dati veri, si fa in produzione con un workflow controllato, o si costruisce un dataset di test che lo riproduca.

Per una PMI con un solo automatizzatore, tre istanze possono sembrare troppe. Il minimo sindacale sono due: una di prova con credenziali sandbox, una di produzione. L'importante è che la produzione non sia il posto dove si prova.

## Audit: chi ha visto il secret

"Chi ha visto il segreto?" è la domanda che arriva il giorno dopo un sospetto di fuga: un token usato da un IP sconosciuto, una mail anomala partita dalla casella di servizio. Con le credenziali dentro n8n, la risposta onesta è spesso "non lo sappiamo con precisione", per tre motivi.

1. **n8n non mostra il valore delle credenziali dopo il salvataggio**, ma chiunque possa *usare* una credenziale in un workflow può, di fatto, farla uscire: basta un nodo HTTP che manda una richiesta autenticata a un endpoint che controlla lui. "Non può vedere la password" non significa "non può usarla per quello che vuole".
2. **La condivisione delle credenziali** tra utenti (nelle versioni che la gestiscono) è un permesso di uso, e spesso si allarga nel tempo senza che nessuno la rivegga.
3. **Il database e la chiave** danno accesso a tutto, a chiunque li abbia: amministratori del server, chi ha accesso ai backup, chi ha accesso alla macchina.

Cosa si può fare, in ordine di costo:

- **Inventario dei permessi**: chi è proprietario di ogni credenziale, con chi è condivisa, rivisto ogni trimestre. Il comando di audit di sicurezza di n8n aiuta a trovare credenziali e nodi rischiosi.
- **Principio del minimo privilegio sulle credenziali stesse**: un token con permessi di sola lettura sul CRM fa meno danni di uno amministrativo, anche se esce.
- **Eventi di n8n**: creazione, modifica, cancellazione di credenziali e workflow sono eventi registrabili (nelle edizioni con streaming dei log verso un sistema esterno), e vanno conservati fuori dall'istanza.
- **Log del vault**: se la fonte di verità è un vault, ogni lettura di un segreto da parte di una persona o di una macchina è registrata. È la ragione principale per cui, oltre una certa dimensione, il vault vale il suo costo.
- **Log dei sistemi esterni**: spesso la risposta vera a "chi ha usato il token" sta nei log del sistema di destinazione (IP, user agent, orari). Sapere dove sono prima dell'incidente fa risparmiare ore.

## Procedura di disaster della chiave

Due scenari, con due procedure diverse: la chiave **persa** e la chiave **esposta**.

### Chiave persa

1. **Fermati prima di peggiorare.** Non ricreare container, non sovrascrivere volumi, non cancellare niente: se la chiave era in un file nella cartella dati, potrebbe essere ancora recuperabile da un volume, da uno snapshot del disco, da un backup della macchina.
2. **Cerca in tutti i posti noti**: archivio offline, password manager, backup della cartella dati, snapshot del VPS, macchine vecchie da cui è stata fatta la migrazione.
3. **Se la trovi**: impostala esplicitamente, verifica una credenziale, e poi rimedia alla causa (variabile esplicita, backup in due posti).
4. **Se non la trovi**, accetta la perdita e ricostruisci in modo ordinato:
   - esporta i workflow (non sono cifrati) e fai l'elenco delle credenziali referenziate, per nome e tipo;
   - genera una nuova chiave, salvala subito nei due posti e nei due custodi;
   - ricrea le credenziali partendo dai sistemi più critici, **generando nuovi segreti** dove possibile invece di cercare quelli vecchi;
   - riassocia e prova i workflow uno per uno, partendo da quelli che toccano clienti e soldi;
   - annota quanto tempo ci è voluto: è il numero che giustifica il backup della chiave.

### Chiave esposta

Se la chiave è uscita (committata in un repository, finita in un ticket, presente in un backup rubato), devi assumere che **chiunque abbia anche una copia del database abbia tutti i segreti**. Cambiare la chiave non basta: i segreti vecchi sono già compromessi.

1. **Valuta l'esposizione**: dove è finita la chiave, chi può averla vista, se anche un backup del database è esposto.
2. **Ruota i segreti alla fonte**, partendo dai più critici: token con permessi di scrittura, accessi bancari e PEC, credenziali amministrative. Usa il runbook di rotazione sopra, accorciando i tempi di osservazione.
3. **Cambia la chiave di n8n**: su una macchina controllata, esporta le credenziali in forma decifrata con la chiave vecchia, avvia un'istanza con la chiave nuova, importa le credenziali (vengono cifrate con la nuova), cancella in modo sicuro il file decifrato. Poiché hai già ruotato i segreti, quello che importi è il nuovo.
4. **Ripulisci la fonte dell'esposizione**: rimuovi la chiave dalla storia del repository (non basta un commit che la cancella), dai ticket, dai backup esposti.
5. **Controlla i log dei sistemi esterni** per accessi anomali nel periodo di esposizione.
6. **Scrivi cosa è successo** e cosa cambia nel processo.

```text
# disaster-chiave.md — una pagina, stampabile, nella stessa cartella dei runbook di backup

CHIAVE PERSA
[ ] stop: non ricreare container / volumi
[ ] cercare: archivio offline (cassaforte), password manager (cassaforte "infrastruttura"),
            backup cartella dati, snapshot VPS, vecchio server
[ ] trovata → impostare N8N_ENCRYPTION_KEY_FILE, test credenziale, aggiornare le due copie
[ ] non trovata → export workflow, elenco credenziali, nuova chiave (2 copie, 2 custodi),
                  ricreare credenziali dai sistemi critici, test workflow per priorità

CHIAVE ESPOSTA
[ ] valutare: dove, chi, anche il DB è esposto?
[ ] ruotare alla fonte: banca/PEC → token in scrittura → admin → resto
[ ] cambiare chiave: export decifrato su macchina controllata → nuova istanza → import → wipe
[ ] ripulire: storia Git, ticket, backup esposti
[ ] controllare i log dei sistemi esterni nel periodo di esposizione
[ ] relazione dell'incidente

Custodi: [nome 1] [nome 2]     Ultima verifica restore con chiave d'archivio: [data]
```

## L'architettura di riferimento

Per una PMI con n8n in produzione e un team che cresce, la configurazione che consiglio:

- **n8n** (main e, se serve, worker) in Docker su server interno o VPS UE, con Postgres, versioni fissate.
- **Encryption key** impostata esplicitamente via Docker secret (`N8N_ENCRYPTION_KEY_FILE`), identica su main e worker, mai in `.env` committati.
- **Vault self-hosted** (Infisical, o Vault/OpenBao per chi ha già le competenze) come fonte di verità per: chiave di n8n, password del database, chiavi dei backup, e — progressivamente — le credenziali applicative.
- **Tre ambienti** (o almeno due) con istanze, chiavi e credenziali separate; promozione dei workflow senza segreti.
- **Backup**: database cifrato offsite ogni notte; chiave in due posti diversi dal backup, con due custodi; restore trimestrale con la chiave d'archivio.
- **Credenziali applicative** con nomi parlanti, proprietario, data di rotazione; permessi minimi sui sistemi esterni.
- **Storico delle esecuzioni** limitato sui workflow che maneggiano segreti o dati sensibili.
- **Eventi e audit**: log degli eventi di n8n e del vault conservati fuori dalle rispettive istanze.

**Cosa non deve succedere mai:** la chiave nello stesso bucket del backup, la chiave in un repository, credenziali di produzione nell'istanza di sviluppo, un'esportazione decifrata lasciata su disco.

## Percorso di implementazione, a step

1. **Scopri dove sta oggi la tua chiave.** Variabile d'ambiente o file? Su volume persistente? Copiata da qualche parte?
2. **Rendila esplicita**: recuperala, mettila in un Docker secret, imposta `N8N_ENCRYPTION_KEY_FILE`, riavvia, verifica una credenziale.
3. **Fai le due copie** fuori dal server, con due custodi, separate dal backup del database.
4. **Fai il primo test di restore** su macchina vuota con la chiave d'archivio.
5. **Inventario delle credenziali**: nome, sistema, proprietario, permessi, condivisioni, ultima rotazione. Rinomina quelle illeggibili.
6. **Separa gli ambienti**: almeno un'istanza di prova con credenziali sandbox.
7. **Scrivi il runbook di rotazione** e fai la prima rotazione su una credenziale poco critica, per provarlo.
8. **Valuta il vault**: se hai più di due-tre persone che toccano credenziali, segreti condivisi con altri sistemi o esigenze di audit, installa un vault self-hosted e spostaci prima i segreti d'infrastruttura.
9. **Scrivi e stampa** la procedura di disaster della chiave.
10. **Metti in calendario** restore trimestrale, revisione trimestrale dei permessi, rotazioni secondo scadenza.

## Fallimenti tipici e come li riconosci dai log

**Chiave diversa o mancante.**

```text
n8n  | Error: Credentials could not be decrypted. The likely reason is that a different "encryptionKey" was used to encrypt the data.
```

Il messaggio è esplicito. Se compare dopo un riavvio, la chiave in uso non è quella con cui sono state cifrate le credenziali: chiave non esplicita e file perso, oppure variabile sbagliata. Non creare nuove credenziali finché non hai capito quale chiave è quella giusta.

**Errori intermittenti in queue mode.**

```text
worker-2 | Credentials could not be decrypted ...  (execution 18233)
worker-1 | Execution 18234 finished successfully
```

Solo alcuni worker falliscono: hanno una chiave diversa dal main. Succede quando i worker sono stati aggiunti con un compose diverso o senza il secret.

**Rotazione incompleta.**

```text
2026-11-16T09:00:12 workflow="sync-ordini" node="HTTP Request" 401 Unauthorized
2026-11-16T09:00:12 workflow="report-giornaliero" node="CRM" success
```

Dopo la revoca del vecchio token, un solo workflow fallisce: usa una credenziale diversa (duplicata, con un altro nome) che conteneva lo stesso segreto. L'inventario non era completo.

**Segreti nelle esecuzioni.** Una ricerca nello storico delle esecuzioni (o nel database) di prefissi tipici dei token trova valori in chiaro: un nodo che restituisce il token in una risposta o un workflow che lo logga. Riduci il salvataggio dei dati di esecuzione su quel workflow e ripulisci lo storico.

**Il test di restore che non parte.** È il fallimento più utile di tutti: la copia d'archivio della chiave non coincide con quella in uso (qualcuno l'ha cambiata e non ha aggiornato l'archivio). Meglio scoprirlo così.

## Costi: ordini di grandezza

Stime indicative.

| Voce | Ordine di grandezza (stima) | Note |
|---|---|---|
| Rendere esplicita la chiave + Docker secrets | 0,5–1 giorno | Il lavoro con il miglior rapporto costo/beneficio di questo articolo |
| Backup della chiave + test di restore | 0,5–1 giorno, poi 1–2 ore a trimestre | Il test è la parte che si salta, e non va saltata |
| Inventario e rinomina credenziali | 0,5–2 giorni | Dipende da quante sono |
| Istanza di sviluppo/staging separata | 1–3 giorni + 5–20 €/mese | Un piccolo VPS o una macchina interna |
| Vault self-hosted (Infisical) | 1–3 giorni di setup + 5–20 €/mese di infrastruttura | Più la manutenzione: aggiornamenti, backup del vault stesso |
| Vault/OpenBao con alta disponibilità | 5–15 giorni + competenze dedicate | Per contesti più strutturati |
| Licenza n8n con external secrets | variabile | Valuta se serve rispetto all'iniezione all'avvio |
| Perdita della chiave senza backup | da 1 giorno a 1–2 settimane di lavoro | Più i flussi fermi nel frattempo |

Una nota: anche il vault ha bisogno di backup, chiavi di unseal o di recupero, custodi. Spostare i segreti in un vault non elimina il problema della chiave: lo **concentra** in un sistema progettato per gestirlo. Se non sei pronto a gestire bene quel sistema, resta su n8n con la chiave fatta bene.

## Quando NON farlo

- **Non installare un vault** se sei una o due persone, con poche decine di credenziali usate solo da n8n. Chiave esplicita, backup in due posti, test di restore, ambienti separati: sei già meglio della media, senza un sistema in più da mantenere.
- **Non usare l'esportazione decifrata come backup** di routine. È uno strumento di migrazione, non una strategia.
- **Non costruire tre ambienti** se nessuno promuoverà davvero i workflow da uno all'altro: diventeranno tre istanze disallineate. Meglio due, usate con disciplina.
- **Non migrare tutte le credenziali al vault in un colpo solo**: inizia dai segreti d'infrastruttura e da quelli condivisi con altri sistemi. Le credenziali usate solo in n8n possono aspettare.
- **Non rimandare il backup della chiave** per fare prima il progetto vault: sono settimane in cui un `docker compose down -v` sbagliato ti costa tutto.

## Checklist operativa

- [ ] `N8N_ENCRYPTION_KEY` impostata esplicitamente (via `_FILE` e Docker secret), non auto-generata.
- [ ] Stessa chiave su main e tutti i worker.
- [ ] Due copie della chiave fuori dal server, separate dal backup del database, con due custodi.
- [ ] Copia d'archivio cifrata; passphrase conservata altrove.
- [ ] Test di restore trimestrale con la chiave d'archivio, superato e datato.
- [ ] Nessuna chiave o `.env` con segreti in repository o ticket.
- [ ] Inventario delle credenziali: nome parlante, sistema, proprietario, permessi, condivisioni, prossima rotazione.
- [ ] Almeno due ambienti, con chiavi e credenziali separate; nessuna credenziale di produzione in sviluppo.
- [ ] Runbook di rotazione scritto e provato.
- [ ] Storico delle esecuzioni limitato sui workflow con segreti.
- [ ] Eventi di n8n e del vault conservati fuori dall'istanza.
- [ ] Procedura di disaster della chiave stampata, con custodi e data dell'ultima verifica.

## Il verdetto

Le credenziali di n8n non sono un problema finché la chiave che le cifra è dove deve essere. Quando non lo è — perché nessuno l'ha mai impostata, perché viveva in un file in un container, perché il backup del database c'era ma la chiave no — diventano il punto di fallimento unico di tutta l'automazione aziendale: i workflow restano, ma non parlano più con niente.

La parte che risolve il novanta per cento del rischio costa una giornata: chiave esplicita, due copie fuori dal server, due custodi, un test di restore a trimestre. Il vault esterno — Infisical per la maggior parte delle PMI, Vault o OpenBao per chi ha già le competenze — arriva dopo, quando il team cresce, i segreti escono da n8n e serve sapere chi ha letto cosa. In quel momento vale il suo costo. Prima, è un sistema in più da tenere in piedi.

Se il tuo n8n è diventato il sistema nervoso dell'azienda e vuoi metterlo al riparo da un venerdì sera sbagliato, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e il resto del lavoro su [antoniotrento.net]({{ site.main_site }}/). Gli altri pezzi sull'infrastruttura self-hosted sono raccolti nella guida allo [stack sovrano]({{ '/it/pillar/stack-sovrano/' | relative_url }}).

## FAQ

### Dove salva n8n le credenziali?

Nel proprio database (SQLite di default, Postgres nelle installazioni di produzione), in una tabella dedicata, con i dati sensibili cifrati tramite la encryption key dell'istanza. Le definizioni dei workflow, invece, non sono cifrate e contengono solo un riferimento alla credenziale.

### Cosa succede se perdo la N8N_ENCRYPTION_KEY?

Le credenziali salvate non sono più leggibili e non esiste un modo per recuperarle. I workflow restano nel database, ma ogni credenziale va ricreata, spesso generando nuovi segreti sui sistemi di origine e ripetendo le autorizzazioni OAuth. Per questo la chiave va impostata esplicitamente e conservata fuori dal server.

### Dove si trova la encryption key se non l'ho impostata?

Se la variabile `N8N_ENCRYPTION_KEY` non è impostata, n8n genera una chiave al primo avvio e la salva in un file di configurazione nella cartella dati (nel container, sotto la cartella `.n8n` della home dell'utente). Se quella cartella non è su un volume persistente, la chiave si perde quando il container viene ricreato.

### Come si fa il backup della chiave di n8n?

Impostandola esplicitamente come Docker secret, conservandone due copie fuori dal server in luoghi diversi da quello del backup del database (per esempio il password manager aziendale e un archivio offline cifrato), affidandola a due custodi, e verificando ogni trimestre un restore completo con la copia d'archivio.

### Quando conviene usare Infisical o Vault con n8n?

Quando più persone creano e usano credenziali, quando gli stessi segreti servono anche fuori da n8n, quando la rotazione è frequente, quando ci sono più ambienti o serve un audit di chi ha letto un segreto. Per una o due persone con poche credenziali usate solo in n8n, una chiave gestita bene è sufficiente.

### Come si collega n8n a un vault esterno?

Con la funzione external secrets delle edizioni a pagamento, che legge i segreti dal vault e li rende disponibili nei campi delle credenziali senza salvarli nel database. Con l'edizione community si possono iniettare i segreti come variabili d'ambiente o Docker secrets all'avvio, o aggiornare le credenziali in n8n via API partendo dal vault.

### Come si ruota un token API in n8n senza fermare i workflow?

Si genera il nuovo token senza revocare il vecchio, si aggiorna il valore nella credenziale esistente (stesso ID, così tutti i workflow lo usano), si testa, si osservano le esecuzioni reali per un periodo adeguato, poi si revoca il vecchio token e si osserva di nuovo per scoprire eventuali usi non inventariati.

### Come si gestiscono le credenziali tra sviluppo, staging e produzione?

Con istanze separate, ognuna con la propria encryption key e le proprie credenziali, usando gli stessi nomi di credenziale nei tre ambienti con valori diversi. I workflow si promuovono da un ambiente all'altro senza segreti, e le credenziali di produzione non vengono mai usate nell'ambiente di sviluppo.

### Si può sapere chi ha visto una credenziale in n8n?

Solo in parte. n8n non mostra il valore dopo il salvataggio, ma chi può usare una credenziale in un workflow può farla uscire verso un endpoint esterno. Servono un inventario dei permessi, credenziali con privilegi minimi, la registrazione degli eventi su credenziali e workflow, e — per un audit completo delle letture — un vault come fonte di verità.

### Cosa fare se la encryption key di n8n è stata esposta?

Assumere che chi ha anche una copia del database abbia tutti i segreti. Si ruotano i segreti alla fonte partendo dai più critici, si cambia la chiave esportando le credenziali in forma decifrata su una macchina controllata e reimportandole in un'istanza con chiave nuova, si cancella in modo sicuro il file intermedio, si ripulisce la fonte dell'esposizione e si controllano i log dei sistemi esterni.
