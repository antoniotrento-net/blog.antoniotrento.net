---
lang: it
permalink: /it/blog/secrets-agenti-llm-vault/
title: "Segreti degli agenti: perché il .env nel compose non è un vault (e come non far finire il token Salesforce nel log dell'LLM)"
date: 2026-10-20 07:30:00 +0200
author: "Antonio Trento"
description: "Gestione dei segreti in uno stack di agenti AI self-hosted: dove vivono davvero (.env, credenziali n8n, memoria dell'LLM, trace, crash dump), Docker secrets vs systemd vs vault, rotazione, redaction nei log e runbook per un token finito nella chat history."
keywords: ["secrets agenti llm vault", "docker secrets vs env", "infisical self-hosted", "token salesforce log", "redaction prompt", "gestione segreti agenti ai"]
image: /assets/images/posts/secrets-agenti-llm-vault.jpg
pillar: stack-sovrano
related: [/it/blog/salesforce-jwt-export-csv-docker/, /it/blog/osservabilita-llm-produzione/]
---

## Il token nella chat history

Il caso che mi ha fatto scrivere questo pezzo è banale, ed è per questo che è pericoloso. Un agente interno aiuta il reparto commerciale a interrogare Salesforce. Una sera la chiamata all'API fallisce, lo strumento restituisce l'errore così com'è, e l'errore contiene la richiesta completa — compreso l'header `Authorization: Bearer 00D…`. Il modello, gentile, riassume il problema all'utente: "la chiamata con il token 00D… è stata rifiutata". Da quel momento il token è **nella cronologia della conversazione** (salvata per la "memoria" dell'agente), **nei trace** dello strumento di osservabilità, e **nei log del fornitore del modello**, se il modello non è self-hosted. Nessuno ha rubato niente. Il segreto è semplicemente uscito da solo, attraverso cinque porte che nessuno aveva chiuso.

Uno stack di agenti AI moltiplica i posti in cui un segreto può finire. Non è più solo "non committare il `.env`": il modello legge risultati di strumenti, ricorda conversazioni, produce trace, genera errori verbosi, e — se qualcuno riesce a iniettargli istruzioni — può essere convinto a ripetere ciò che ha visto. La gestione dei **secret per agenti LLM**, con un **vault** o almeno con qualcosa di meglio di un file di variabili d'ambiente, diventa un requisito di base, non un'ottimizzazione per aziende grandi.

L'angolo è **security ops**, concreto: dove vivono davvero i segreti in uno stack agentico self-hosted, cosa può finire nel contesto del modello e come impedirlo, **Docker secrets vs `.env`** vs systemd vs un vault vero, la rotazione di chiavi JWT e segreti dei webhook, la **redaction** in prompt e trace, la separazione tra sviluppo e produzione, e il runbook per quando un segreto è già uscito.

## La superficie: .env, credenziali n8n, memoria dell'LLM, crash dump

Prima di scegliere uno strumento, bisogna fare l'inventario di **dove i segreti esistono**, in chiaro o quasi, nello stack. In un tipico stack sovrano — Docker Compose con n8n, Postgres, un LLM servito in locale, qualche servizio Python, un reverse proxy — la mappa è questa:

| Dove | Cosa ci finisce | Chi lo può leggere | Rischio tipico |
|------|-----------------|--------------------|----------------|
| File `.env` sul server | password DB, chiavi API, token | chi ha accesso al filesystem o a un backup | backup non cifrati, copie su laptop, commit accidentali |
| Variabili d'ambiente del container | tutto ciò che passi con `environment:` | chi può fare `docker inspect`, chi ha accesso al socket Docker, processi figli | esposte in chiaro, ereditate, stampate in pagine di errore o dump |
| Credenziali di n8n | token di CRM, email, API | chi ha il DB **e** la chiave di cifratura; utenti dell'editor che le usano nei workflow | chiave di cifratura nel `.env` accanto al DB |
| Contesto del modello (prompt) | risultati di strumenti, messaggi utente, errori | il modello, il fornitore (se esterno), chiunque legga i log di inferenza | token dentro errori o output di strumenti |
| Memoria dell'agente | cronologia delle conversazioni | chi accede allo store della memoria; il modello nelle conversazioni future | segreto "ricordato" e ripetuto |
| Trace e log di osservabilità | prompt, risposte, input/output dei tool | chi ha accesso allo strumento di tracing | segreti persistiti per mesi |
| Crash dump e stack trace | memoria del processo, variabili locali | chi riceve i dump, il servizio di error tracking | dump inviati a servizi esterni |
| Repository Git | `.env` committati, chiavi in esempi | chiunque abbia accesso al repo e alla sua storia | la storia di Git è per sempre |
| Laptop degli sviluppatori | copie del `.env` di produzione | chiunque abbia quel laptop | laptop persi, sincronizzati su cloud personali |
| Chat e ticket | token incollati "per fare prima" | tutti i partecipanti, la piattaforma | segreti in strumenti fuori dal perimetro |

Questa è la **matrice di dove vivono i secret**, ed è il primo documento da scrivere per il tuo stack. Due osservazioni che di solito sorprendono:

- **Il `.env` non è il problema principale.** Il problema è tutto ciò che il `.env` alimenta: variabili d'ambiente leggibili dall'esterno del processo, credenziali cifrate con una chiave che sta nello stesso file, e segreti che viaggiano dentro i dati che l'agente elabora.
- **Le righe nuove sono quelle legate all'AI**: contesto del modello, memoria, trace. Sono posti in cui i segreti finiscono **per effetto collaterale**, senza che nessuno li abbia messi lì volontariamente.

## Cosa può finire nel contesto del modello

La regola fondamentale è semplice: **un segreto non deve mai entrare nel contesto del modello.** Una volta dentro, puoi perdere il controllo di dove va: nella risposta all'utente, nella memoria, nei trace, nei log del fornitore, e — con una prompt injection — verso un destinatario ostile. Ho descritto come un documento malevolo può ordinare a un agente di inviare dati a un server esterno nel pezzo sulla prompt injection nei documenti aziendali; un token nel contesto è esattamente il tipo di dato che un attaccante vuole esfiltrare.

Le strade tipiche per cui un segreto entra nel contesto:

- **Errori verbosi degli strumenti.** Un client HTTP che in caso di errore restituisce la richiesta completa, header inclusi. Un driver di database che mette la stringa di connessione (con password) nel messaggio d'eccezione.
- **Strumenti che leggono file.** Un agente con uno strumento "leggi file" e accesso alla cartella del progetto può leggere il `.env`, un file di configurazione, una chiave privata.
- **Output di comandi.** Uno strumento che esegue comandi di sistema e restituisce l'output: `env`, `docker inspect`, `cat config.yml`.
- **L'utente stesso.** "Ecco la mia chiave API, usala per questa chiamata": incollata in chat, finisce nella cronologia.
- **Configurazione passata al modello.** Prompt costruiti includendo "per contesto" la configurazione dell'integrazione, con l'URL del webhook che contiene un token nella query string.

L'architettura che lo impedisce è di **separare chi usa le credenziali da chi ragiona**:

- Il modello vede **nomi di strumenti e parametri di business** ("cerca opportunità per il cliente X"), mai credenziali.
- L'**esecutore degli strumenti** — codice deterministico, fuori dal modello — risolve le credenziali dal vault al momento della chiamata, esegue, e restituisce al modello **solo il risultato utile, ripulito**.
- Gli **errori vengono sanitizzati** prima di tornare al modello: codice di errore, messaggio generico, mai la richiesta completa.
- Gli strumenti che leggono file o eseguono comandi hanno **allowlist di percorsi e comandi**; i file di configurazione e le cartelle dei segreti non ci sono.

Questo è lo stesso principio della costituzione dell'agente in YAML che ho descritto nel pezzo sulla {{ '/it/blog/yaml-costituzione-agente-ai/' | relative_url }}: la configurazione nomina una credenziale (`credential_ref: crm_readonly`), il runtime la risolve, il modello non la vede mai.

## Docker secrets, systemd, vault: a confronto

Vediamo le opzioni in ordine di maturità, con onestà su cosa proteggono davvero.

### Variabili d'ambiente da `.env`

È il default di quasi ogni tutorial: un file `.env` accanto al `docker-compose.yml`, variabili interpolate e passate ai container. Problemi:

- I valori sono visibili a chiunque possa eseguire `docker inspect` sul container, o abbia accesso al socket Docker (che equivale ad avere il controllo dell'host).
- Sono ereditati da tutti i processi figli del container.
- Molti framework li stampano in pagine di debug, messaggi di errore o dump.
- Il file vive in chiaro sul disco, finisce nei backup, viene copiato "per comodità".

Va bene per configurazione non sensibile (porte, nomi di host, livelli di log). Non per i segreti.

### Docker secrets (con file)

Docker Compose permette di dichiarare `secrets:` che vengono montati come file in `/run/secrets/<nome>` dentro il container. Una precisazione importante: **in Compose senza Swarm**, un secret definito con `file:` è sostanzialmente un **file montato nel container**, non cifrato a riposo dal motore; in modalità Swarm, invece, i secret sono conservati cifrati nel cluster e montati in memoria. In entrambi i casi il vantaggio concreto rispetto alle variabili d'ambiente è reale:

- il valore **non compare** tra le variabili d'ambiente del container né in `docker inspect`;
- non viene ereditato automaticamente dai processi figli;
- puoi controllare permessi e proprietario del file sorgente sull'host.

Molte immagini ufficiali supportano la convenzione del suffisso `_FILE`: invece di `POSTGRES_PASSWORD` passi `POSTGRES_PASSWORD_FILE=/run/secrets/pg_password`, e il processo legge il valore dal file. Anche n8n supporta il suffisso `_FILE` per le sue variabili d'ambiente.

```yaml
# docker-compose.yml — segreti come file, non come variabili d'ambiente
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD_FILE: /run/secrets/pg_password      # letto da file
    secrets: [pg_password]

  n8n:
    image: n8nio/n8n:1.XX.X
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD_FILE: /run/secrets/pg_password  # suffisso _FILE
      N8N_ENCRYPTION_KEY_FILE: /run/secrets/n8n_enc_key      # la chiave che cifra le credenziali
    secrets: [pg_password, n8n_enc_key]

secrets:
  pg_password:
    file: /etc/stack/secrets/pg_password      # fuori dalla cartella del progetto, permessi 600
  n8n_enc_key:
    file: /etc/stack/secrets/n8n_enc_key
```

Nota la posizione dei file: **fuori dalla cartella del progetto** (quindi fuori dal repository e dalle copie "di comodo" della cartella), con permessi restrittivi. E la chiave di cifratura di n8n trattata come il segreto più importante: le credenziali salvate in n8n sono cifrate con quella chiave, quindi chi ha il database **e** la chiave ha tutte le credenziali in chiaro. Tenerle nello stesso file `.env`, o nello stesso backup non cifrato, annulla la cifratura.

### systemd credentials

Se i servizi girano direttamente sull'host con systemd (senza container, o per i processi di supporto), le versioni recenti di systemd offrono un meccanismo di credenziali: con direttive come `LoadCredential=` o `SetCredentialEncrypted=` il servizio riceve i segreti come file in una directory dedicata (indicata dalla variabile `CREDENTIALS_DIRECTORY`), accessibile solo a quel servizio, invece che come variabili d'ambiente. Lo strumento `systemd-creds` permette di cifrare le credenziali legandole alla macchina (anche tramite TPM, dove disponibile), così un file di credenziale copiato su un'altra macchina è inutile. Per server singoli con pochi servizi è un'opzione solida e spesso ignorata.

### Vault (Infisical, OpenBao, HashiCorp Vault)

Un vault vero aggiunge ciò che nessuna delle opzioni precedenti ha:

- **Audit log**: chi ha letto quale segreto, quando, da dove.
- **Controllo d'accesso per identità**: ogni servizio ha la sua identità e legge solo i segreti che gli servono.
- **Rotazione** gestita, e in alcuni casi **segreti dinamici**: credenziali di database create al volo con scadenza breve, che non esistono prima e non valgono dopo.
- **Versioning**: sai qual era il valore precedente, puoi tornare indietro.
- **Revoca centralizzata**: un segreto compromesso si disattiva in un punto.

Opzioni self-hostable: **Infisical** (open source, pensato anche per team piccoli, con interfaccia comoda e integrazioni), **OpenBao** (fork open source di HashiCorp Vault, nato dopo il cambio di licenza di Vault), e **HashiCorp Vault** stesso (licenza da valutare per il tuo uso). Per uno stack sovrano, il vault gira sui tuoi server, in UE, come ogni altro componente.

Il confronto riassunto:

| Opzione | Esposto in `docker inspect`/env | Cifratura a riposo | Audit | Rotazione | Complessità |
|---------|----------------------------------|--------------------|-------|-----------|-------------|
| `.env` + variabili d'ambiente | sì | no | no | manuale | minima |
| Docker secrets con file (Compose) | no | dipende dal filesystem | no | manuale | bassa |
| Docker secrets (Swarm) | no | sì | no | manuale | media |
| systemd credentials | no | sì (con `systemd-creds`) | no | manuale | bassa-media |
| Vault self-hosted | no | sì | **sì** | **gestita** | media-alta |

La mia raccomandazione pragmatica: **per uno stack piccolo, parti da Docker secrets con file fuori dal repository** (o systemd credentials) — è un miglioramento enorme a costo quasi zero. Passa a un **vault** quando hai più servizi, più persone, requisiti di audit, o segreti da ruotare spesso. Il vault non è un traguardo da raggiungere subito; il `.env` in chiaro con i segreti dentro è da abbandonare subito.

## Rotazione: chiavi JWT e segreti dei webhook

Un segreto che non ruoti mai è un segreto che, prima o poi, sarà compromesso senza che tu lo sappia. La rotazione è il modo per limitare la durata del danno. Negli stack agentici, due tipi di segreti meritano attenzione particolare.

**Chiavi di firma (JWT).** Se un agente si autentica verso un CRM con il flusso JWT Bearer — come ho descritto per l'{{ '/it/blog/salesforce-jwt-export-csv-docker/' | relative_url }} — la chiave privata che firma i token è il segreto più prezioso dell'integrazione. La rotazione si fa **senza interruzione** così:

1. Generi una nuova coppia di chiavi e carichi il nuovo certificato sul lato che verifica (per esempio la Connected App), **accanto** a quello vecchio se la piattaforma lo consente, o in una finestra concordata.
2. Aggiorni il segreto nel vault; i servizi iniziano a firmare con la nuova chiave.
3. Verifichi dai log che non ci siano più richieste firmate con la vecchia.
4. Rimuovi il vecchio certificato.

Se sei tu a verificare JWT (per esempio token emessi dal tuo sistema per autenticare servizi interni), usa un identificativo di chiave (`kid`) nell'header, accetta per un periodo limitato sia la chiave vecchia sia quella nuova, poi ritira la vecchia.

**Segreti dei webhook.** Molti servizi firmano i webhook con un segreto condiviso (HMAC). Se il segreto trapela, chiunque può inviare webhook falsi al tuo n8n o al tuo agente. La rotazione con **sovrapposizione**:

```python
import hmac, hashlib

def firma_valida(body: bytes, firma_ricevuta: str, segreti_attivi: list[bytes]) -> bool:
    """Durante la rotazione accetta la firma con il segreto nuovo O con quello vecchio."""
    for segreto in segreti_attivi:                 # [nuovo, vecchio] fino a fine finestra
        attesa = hmac.new(segreto, body, hashlib.sha256).hexdigest()
        if hmac.compare_digest(attesa, firma_ricevuta):
            return True
    return False
```

Finestra di sovrapposizione breve (ore o pochi giorni), poi il segreto vecchio si rimuove dall'elenco. E nota il `compare_digest`: il confronto a tempo costante evita che un attaccante deduca la firma giusta misurando i tempi di risposta.

Una tabella di cadenze indicative, da adattare al rischio:

| Segreto | Cadenza di rotazione indicativa | Note |
|---------|--------------------------------|------|
| Chiavi API di servizi esterni | 90 giorni o al cambio di personale | subito se compaiono in log/chat |
| Chiave privata JWT | 6–12 mesi, o alla scadenza del certificato | rotazione senza downtime con sovrapposizione |
| Segreti dei webhook | 90–180 giorni | sovrapposizione breve |
| Password di database | con un vault, credenziali dinamiche a scadenza breve | senza vault, 90–180 giorni |
| Chiave di cifratura di n8n | raramente, con procedura (richiede ri-cifrare le credenziali) | protezione > rotazione |
| Token personali degli sviluppatori | brevi, per progetto | mai condivisi |

## Redaction in tracing e nei prompt

Anche con un'architettura corretta, qualcosa sfugge: un errore non sanitizzato, un utente che incolla una chiave, uno strumento nuovo scritto di fretta. La **redaction** è la rete di sicurezza: prima che un testo venga salvato in un trace, in un log o nella memoria dell'agente — e, idealmente, prima che venga passato al modello — si cercano e si mascherano i segreti.

Due tecniche complementari:

1. **Riconoscimento per pattern.** Molti segreti hanno forme riconoscibili: header `Authorization: Bearer …`, token JWT (tre blocchi base64 separati da punti, il primo che inizia tipicamente con `eyJ`), blocchi di chiavi private (`-----BEGIN … PRIVATE KEY-----`), stringhe di connessione con password (`postgres://utente:password@host`), prefissi noti di chiavi di alcuni fornitori, parametri `token=`, `key=`, `secret=` negli URL.
2. **Corrispondenza esatta con i segreti noti.** La tecnica più affidabile: il servizio di redaction conosce (dal vault) i valori dei segreti attivi — o meglio i loro hash e prefissi — e cerca quei valori esatti nel testo. Un token che non ha un formato riconoscibile viene comunque trovato perché è *quel* token.

Un esempio di redaction applicata prima di salvare trace e memoria:

```python
import re, hashlib

PATTERN = [
    (re.compile(r"(?i)(authorization:\s*bearer\s+)[A-Za-z0-9\-._~+/!]+=*"), r"\1[REDACTED]"),
    (re.compile(r"eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+"), "[REDACTED_JWT]"),
    (re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----.*?-----END [A-Z ]*PRIVATE KEY-----", re.S),
     "[REDACTED_PRIVATE_KEY]"),
    (re.compile(r"(?i)\b([a-z][a-z0-9+.-]*://[^:/\s]+:)([^@\s]+)(@)"), r"\1[REDACTED]\3"),  # user:pass@host
    (re.compile(r"(?i)([?&](token|key|secret|signature|sig|access_token)=)[^&\s]+"), r"\1[REDACTED]"),
]

class Redattore:
    def __init__(self, segreti_attivi: list[str]):
        # conserva solo i valori, mai loggati; ordinati per lunghezza (i più lunghi prima)
        self.noti = sorted({s for s in segreti_attivi if len(s) >= 12}, key=len, reverse=True)

    def pulisci(self, testo: str) -> str:
        for s in self.noti:                       # 1) corrispondenza esatta: la più affidabile
            if s in testo:
                testo = testo.replace(s, f"[REDACTED:{hashlib.sha256(s.encode()).hexdigest()[:8]}]")
        for pat, sost in PATTERN:                  # 2) pattern per ciò che non conosciamo
            testo = pat.sub(sost, testo)
        return testo
```

Il marcatore `[REDACTED:ab12cd34]` con un frammento dell'hash è utile: nei log vedi che un segreto *è comparso*, e quale (confrontando l'hash con quello dei segreti attivi), senza vederne il valore. È il segnale per far partire il runbook.

Dove applicare la redaction, in ordine di importanza:

- **Sui risultati e sugli errori degli strumenti**, prima che tornino al modello.
- **Su tutto ciò che viene salvato**: trace, log applicativi, memoria dell'agente, ticket generati automaticamente.
- **Sui messaggi degli utenti**, prima che entrino in memoria persistente (con un avviso all'utente: "hai incollato quello che sembra un token; non verrà salvato, e ti consiglio di rigenerarlo").
- **Sui report di errore** inviati a strumenti di error tracking.

La redaction per i dati personali nei trace segue la stessa logica e l'ho trattata nel pezzo sull'{{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}: stessa pipeline, stesso punto di applicazione, cataloghi diversi.

## L'architettura di riferimento

```
  ┌──────────────────────────────────────────────────────────────┐
  │ VAULT (self-hosted, UE)  ── audit log · rotazione · revoca    │
  └───────────────┬──────────────────────────────────────────────┘
                  │ identità per servizio, solo i segreti necessari
     ┌────────────┼────────────────────────────┐
     ▼            ▼                            ▼
  ┌────────┐  ┌──────────────────────┐   ┌─────────────────────┐
  │ n8n    │  │ ESECUTORE STRUMENTI   │   │ servizi (DB, proxy) │
  │ (_FILE)│  │ risolve credential_ref│   │ Docker secrets/_FILE│
  └────────┘  │ esegue la chiamata    │   └─────────────────────┘
              │ sanitizza errori      │
              └──────────┬───────────┘
                         │ solo risultati utili, ripuliti
                         ▼
              ┌──────────────────────┐
              │ MODELLO (LLM)         │  ← non vede MAI credenziali
              └──────────┬───────────┘
                         ▼
              ┌──────────────────────┐
              │ REDATTORE             │  pattern + segreti noti
              └──────────┬───────────┘
                         ▼
        trace · log · memoria agente · error tracking
```

**Cosa non tocca l'agente**: il vault, i file dei segreti, le variabili d'ambiente dei servizi, gli strumenti che leggono cartelle di configurazione. Il modello chiede azioni; l'esecutore, con le sue credenziali, le compie e restituisce solo ciò che serve.

## Sviluppo vs produzione: niente segreti di prod sul laptop

Una fonte di fughe sottovalutata è la comodità dello sviluppo. "Per testare mi copio il `.env` di produzione", "per vedere i dati veri punto l'agente in locale sul CRM di produzione", "ti mando la chiave su WhatsApp così provi". Ogni copia di un segreto di produzione su una macchina di sviluppo è una copia che non controlli: il laptop viene perso, la cartella è sincronizzata su un cloud personale, il file finisce in un commit.

Le regole che applico:

- **Ambienti separati con credenziali separate.** Il CRM ha una sandbox, il database ha una copia di sviluppo, le API esterne hanno chiavi di test. Lo sviluppo usa quelle.
- **Nessun segreto di produzione sulle macchine di sviluppo.** Se serve un'operazione in produzione, si fa da un ambiente controllato (un server di amministrazione, una pipeline), non dal laptop.
- **Dati di produzione in sviluppo solo anonimizzati.** Se il test richiede dati realistici, si usa una copia ripulita dei dati personali.
- **Il repository contiene un `.env.example`** con i nomi delle variabili e valori fittizi; il `.env` vero è nel `.gitignore` e — meglio ancora — non esiste, perché i valori arrivano dal vault.
- **Scansione automatica dei segreti**: un hook pre-commit e un controllo in CI (strumenti come gitleaks) bloccano i commit che contengono chiavi. È la stessa rete di sicurezza che ho messo nella pipeline della costituzione dell'agente.
- **Segreti mai in chat, email o ticket.** Se una persona deve ricevere un segreto, lo riceve tramite il vault (con un link a scadenza o un accesso nominativo), non in un messaggio che resta per sempre in un sistema di terze parti.

## Incident: il runbook quando un segreto è uscito

Prima o poi succede: un token nella chat history, una chiave in un commit, una password in un trace, un laptop perso. La differenza tra un incidente contenuto e un disastro sta quasi tutta nella **velocità** e nell'**ordine** delle azioni. Il **runbook leak** che uso:

**1. Revoca prima, indaga dopo.** Il riflesso sbagliato è "vediamo prima se è stato usato". Il riflesso giusto è **revocare o ruotare subito** il segreto esposto. Se il segreto è una chiave API, la disattivi; se è un token di sessione, lo invalidi; se è una password, la cambi. Un segreto revocato non può più fare danni, qualunque cosa sia successa prima.

**2. Ruota i segreti collegati.** Se il segreto esposto dava accesso ad altri segreti (una password di database che contiene le credenziali di n8n, una chiave che firma altri token), ruota anche quelli. Chiediti: *con questo segreto, cos'altro si poteva leggere?*

**3. Delimita la diffusione.** Dove è finito il segreto? Elenca tutti i posti: storia di Git (inclusi i fork e le copie locali), log applicativi, trace, memoria dell'agente, log del fornitore del modello, strumenti di error tracking, backup, chat, email. Anche se pulisci questi posti, **considera il segreto compromesso**: la pulizia riduce l'esposizione futura, non annulla quella passata.

**4. Verifica l'uso.** Cerca nei log del sistema protetto se il segreto è stato usato da dove non ti aspetti: accessi da IP insoliti, chiamate API fuori orario, volumi anomali. Molte piattaforme (CRM compresi) offrono una cronologia degli accessi e dell'uso delle API: è la prima fonte da consultare.

**5. Pulisci le copie.** Rimuovi il segreto da trace, memoria, log e storia di Git (riscrivere la storia di Git è possibile ma invasivo; la priorità resta la revoca). Chiedi ai fornitori coinvolti le procedure di cancellazione, se il segreto è finito nei loro sistemi.

**6. Comunica.** Se il segreto dava accesso a dati personali e c'è il dubbio che siano stati letti, valuta con il DPO gli obblighi di notifica: il GDPR prevede tempi stretti per la notifica all'autorità di controllo nei casi di violazione dei dati personali.

**7. Postmortem.** Come è uscito? Quale controllo mancava? Cosa impedirà che succeda di nuovo? Tipicamente l'esito è un pattern di redaction in più, un errore da sanitizzare, uno strumento da restringere, un segreto da spostare nel vault.

Una versione compatta da tenere appesa al muro (o nel wiki):

```text
RUNBOOK LEAK SEGRETO
[ ] T+0     Revoca/ruota il segreto esposto (non aspettare l'indagine)
[ ] T+15m   Ruota i segreti raggiungibili con quello esposto
[ ] T+30m   Elenca dove è finito: git, log, trace, memoria agente, fornitore LLM, chat, backup
[ ] T+1h    Controlla i log di accesso/uso del sistema protetto (IP, orari, volumi)
[ ] T+2h    Pulisci copie in trace/memoria/log; apri richieste ai fornitori se serve
[ ] T+24h   Valuta con il DPO eventuali obblighi di notifica (dati personali)
[ ] T+72h   Postmortem: causa, controllo mancante, azione correttiva, test
```

## Percorso di implementazione, a step

1. **Scrivi la matrice** di dove vivono i segreti nel tuo stack, riga per riga come quella sopra.
2. **Sposta i segreti fuori dalle variabili d'ambiente**: Docker secrets con file fuori dal repository, suffisso `_FILE` dove supportato, oppure systemd credentials.
3. **Separa la chiave di cifratura di n8n** dal database e dai suoi backup.
4. **Rimuovi le credenziali dal percorso del modello**: esecutore degli strumenti che risolve i riferimenti, errori sanitizzati, allowlist per strumenti di lettura file e comandi.
5. **Installa il redattore** su risultati degli strumenti, trace, log, memoria ed error tracking, con pattern e corrispondenza esatta.
6. **Aggiungi scansione dei segreti** in pre-commit e in CI.
7. **Separa gli ambienti**: sandbox e credenziali di sviluppo, nessun segreto di produzione sui laptop.
8. **Definisci le cadenze di rotazione** e prova una rotazione senza downtime per JWT e webhook.
9. **Scrivi il runbook** e fai una simulazione: "questo token è finito in un trace, cosa facciamo?".
10. **Valuta il vault** quando crescono servizi, persone o requisiti di audit.

## Fallimenti tipici e come li riconosci dai log

- **`[REDACTED:…]` nei trace.** Il redattore ha trovato un segreto: bene che l'abbia mascherato, male che ci sia arrivato. Parti dal runbook e trova da quale strumento o errore proviene.
- **Header di autorizzazione nei messaggi d'errore.** Nei log applicativi, eccezioni HTTP che includono la richiesta completa. Sanitizza gli errori alla fonte, non solo con la redaction.
- **Stringhe di connessione con password negli stack trace.** Driver di database che loggano l'URL completo. Stesso rimedio.
- **Variabili d'ambiente sensibili visibili con `docker inspect`.** Segreti ancora passati con `environment:`. Spostali su file.
- **Credenziali n8n inutilizzabili dopo un ripristino.** Il backup del database è stato ripristinato con una chiave di cifratura diversa: sintomo che la chiave non è gestita come segreto con il suo backup separato e protetto.
- **Commit bloccati dalla scansione.** Funziona. Se succede spesso, gli sviluppatori hanno bisogno di un modo comodo per ottenere i segreti di sviluppo, altrimenti li copieranno a mano.
- **Accessi all'API del CRM da IP insoliti.** Nella cronologia degli accessi della piattaforma: un token potrebbe essere in circolazione. Runbook.
- **Firme di webhook rifiutate dopo una rotazione.** Il mittente non ha ancora il nuovo segreto e la finestra di sovrapposizione non è stata prevista.

## Costi: ordini di grandezza

Stime indicative.

- **Docker secrets e systemd credentials**: costo praticamente nullo, qualche ora di lavoro per migrare lo stack.
- **Vault self-hosted**: un piccolo server o container (e il suo database), nell'ordine di **pochi euro fino a qualche decina al mese** di infrastruttura; il costo vero è la gestione (aggiornamenti, backup, procedura di sblocco in caso di riavvio).
- **Redaction**: overhead di calcolo trascurabile rispetto all'inferenza; il costo è scrivere e mantenere i pattern.
- **Scansione in CI**: gratuita con strumenti open source, pochi secondi per esecuzione.
- **Energia**: irrilevante.
- **Il costo di un incidente**: ore o giorni di lavoro per revocare, ruotare, verificare, pulire e comunicare — e, se il segreto dava accesso a dati personali, la gestione della violazione. Molto più di qualsiasi investimento preventivo in questa lista.

## Quando NON farlo (o farlo in modo più semplice)

- **Non introdurre un vault complesso per un solo servizio con due segreti.** Docker secrets o systemd credentials, ben fatti, sono sufficienti e hanno meno parti da gestire. Un vault mal gestito (senza backup, senza procedura di sblocco) è un punto di rottura in più.
- **Non affidarti solo alla redaction.** È una rete di sicurezza, non l'architettura. Se i segreti arrivano regolarmente al redattore, il problema è a monte: strumenti che restituiscono troppo, errori non sanitizzati, credenziali nel percorso del modello.
- **Non ruotare segreti senza sovrapposizione** su integrazioni in produzione: rischi un'interruzione peggiore del problema che vuoi prevenire. Prima prova la procedura in sviluppo.
- **Non usare un servizio di gestione segreti esterno** se l'obiettivo dello stack è la sovranità: i segreti sono i dati più sensibili che hai, e un vault self-hosted in UE è coerente con il resto.
- **Non riscrivere la storia di Git come prima mossa** dopo un leak: la priorità è la revoca. Riscrivere la storia serve a ridurre l'esposizione futura, non a rimediare a quella passata.

## Checklist prima del go-live

- [ ] Matrice di dove vivono i segreti scritta e aggiornata.
- [ ] Nessun segreto passato come variabile d'ambiente in chiaro; file con permessi restrittivi fuori dal repository.
- [ ] Chiave di cifratura di n8n separata dal database e dai suoi backup, con un suo backup protetto.
- [ ] Il modello non vede mai credenziali; esecutore degli strumenti con riferimenti risolti a runtime.
- [ ] Errori degli strumenti sanitizzati prima di tornare al modello.
- [ ] Strumenti di lettura file e comandi con allowlist; cartelle di configurazione e segreti escluse.
- [ ] Redattore attivo su risultati degli strumenti, trace, log, memoria, error tracking.
- [ ] Scansione dei segreti in pre-commit e in CI.
- [ ] Ambienti separati; nessun segreto di produzione sui laptop.
- [ ] Cadenze di rotazione definite; rotazione senza downtime provata per JWT e webhook.
- [ ] Verifica delle firme dei webhook con confronto a tempo costante.
- [ ] Runbook leak scritto, con responsabili, e simulato almeno una volta.

## Il verdetto

In uno stack di agenti AI, i segreti non escono solo perché qualcuno committa un `.env`. Escono perché un errore verboso finisce nel contesto del modello, perché la memoria dell'agente ricorda ciò che ha visto, perché i trace conservano per mesi ogni input e output, perché una chiave incollata in chat resta nella cronologia. Il **`.env` nel compose non è un vault**, e non è nemmeno il problema principale: il problema è tutto ciò che quei valori attraversano.

La difesa ha tre strati. **Custodia**: segreti fuori dalle variabili d'ambiente, file con permessi stretti o un vault self-hosted con audit e rotazione. **Architettura**: il modello non vede mai una credenziale, l'esecutore degli strumenti le risolve e restituisce solo risultati ripuliti. **Rete di sicurezza**: redaction su tutto ciò che viene salvato, scansione nei commit, e un runbook che parte dalla revoca, non dall'indagine.

Fatto questo, il token Salesforce resta dove deve stare: nel vault, letto da un solo servizio, mai scritto in un log. E il giorno in cui qualcosa sfugge comunque, trovi un `[REDACTED:ab12cd34]` nel trace invece di un token in chiaro — e sai esattamente quale segreto ruotare.

Se vuoi mettere in ordine i segreti del tuo stack agentico prima che ne esca uno, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Si parte dalla matrice: dove vivono oggi i tuoi segreti.

## FAQ

### Perché il file .env non è sufficiente per i segreti?
Perché i valori finiscono in variabili d'ambiente visibili a chi può ispezionare il container o accedere al socket Docker, vengono ereditati dai processi figli, possono comparire in pagine di errore e dump, e il file stesso vive in chiaro su disco, nei backup e nelle copie "di comodo". Va bene per la configurazione non sensibile; per i segreti conviene passare a file montati con permessi restrittivi, a systemd credentials o a un vault.

### Che differenza c'è tra Docker secrets e variabili d'ambiente?
Con i Docker secrets il valore viene montato come file in `/run/secrets/` invece di comparire tra le variabili d'ambiente: non si vede con `docker inspect` e non viene ereditato automaticamente dai processi figli. In Docker Compose senza Swarm, un secret definito da file è sostanzialmente un file montato, non cifrato a riposo dal motore; in Swarm i secret sono conservati cifrati. Molte immagini, n8n compreso, supportano il suffisso `_FILE` per leggere i valori da file.

### Come faccio a non far finire un token nel contesto del modello?
Separando chi ragiona da chi usa le credenziali: il modello vede solo nomi di strumenti e parametri di business, mentre un esecutore deterministico risolve le credenziali dal vault, esegue la chiamata e restituisce al modello solo il risultato utile. Gli errori vanno sanitizzati prima di tornare al modello (niente richieste complete con header), e gli strumenti che leggono file o eseguono comandi devono avere allowlist che escludono configurazioni e segreti.

### Serve davvero un vault per una piccola azienda?
Non sempre subito. Per uno stack piccolo, Docker secrets con file fuori dal repository o systemd credentials sono un miglioramento enorme a costo quasi zero. Il vault diventa utile quando crescono i servizi, le persone che accedono ai segreti, i requisiti di audit o la frequenza di rotazione. Soluzioni come Infisical o OpenBao si possono ospitare sui propri server, coerentemente con uno stack sovrano.

### Dove va conservata la chiave di cifratura di n8n?
Separata dal database e dai suoi backup, come segreto a sé. Le credenziali salvate in n8n sono cifrate con quella chiave: chi possiede sia il database sia la chiave può leggerle tutte in chiaro. Tenerle nello stesso file o nello stesso backup non cifrato annulla la protezione. Serve anche un backup protetto della chiave, altrimenti un ripristino del database la renderebbe inutilizzabile.

### Come ruoto una chiave senza interrompere le integrazioni?
Con una finestra di sovrapposizione: carichi la nuova chiave o il nuovo certificato accanto a quello vecchio, aggiorni i servizi perché usino la nuova, verifichi dai log che la vecchia non venga più usata, poi la ritiri. Per i segreti dei webhook il ricevente accetta per un periodo breve le firme calcolate con entrambi i segreti. Conviene provare la procedura in un ambiente di sviluppo prima di farla in produzione.

### Cosa deve fare la redaction nei trace?
Cercare e mascherare i segreti prima che vengano salvati in trace, log, memoria dell'agente e sistemi di error tracking. La tecnica più affidabile è la corrispondenza esatta con i valori dei segreti attivi; i pattern (header Bearer, JWT, chiavi private, stringhe di connessione con password, parametri di URL come token o key) coprono ciò che non conosci. Un marcatore con un frammento di hash ti permette di sapere quale segreto è comparso senza vederne il valore.

### Cosa faccio se un token è finito nella chat history dell'agente?
Revocalo o ruotalo subito, senza aspettare di capire se è stato usato. Poi ruota i segreti raggiungibili con quel token, elenca tutti i posti in cui può essere finito (memoria, trace, log, fornitore del modello, backup), controlla i log di accesso del sistema protetto, pulisci le copie e, se c'erano dati personali in gioco, valuta con il DPO gli obblighi di notifica. Chiudi con un postmortem su come è uscito.

### Posso usare i segreti di produzione in sviluppo, anche solo per un test?
È meglio di no. Ogni copia di un segreto di produzione su un laptop è una copia che non controlli: laptop persi, cartelle sincronizzate su cloud personali, file finiti in un commit. Usa sandbox e credenziali di sviluppo separate, dati anonimizzati se servono dati realistici, e per le operazioni in produzione un ambiente controllato. Un `.env.example` con valori fittizi documenta cosa serve senza esporre nulla.

### Come impedisco che una chiave finisca in un commit?
Con una scansione automatica dei segreti sia in un hook pre-commit sia nella pipeline di CI, il `.env` nel `.gitignore` e un `.env.example` con valori fittizi. Se una chiave finisce comunque nella storia, la priorità è revocarla e ruotarla: riscrivere la storia di Git riduce l'esposizione futura ma non annulla quella passata, perché cloni e fork possono già contenerla.
