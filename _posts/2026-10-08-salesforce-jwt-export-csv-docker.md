---
lang: it
permalink: /it/blog/salesforce-jwt-export-csv-docker/
title: "Export notturno Salesforce → CSV con JWT in Docker: field mapping, paginazione e perché l'utente \"Administrator\" è una bomba"
date: 2026-10-08 07:30:00 +0200
author: "Antonio Trento"
description: "Ricetta di un exporter Salesforce → CSV di produzione: Connected App con JWT Bearer, utente di integrazione a permessi minimi (non admin), Bulk API e paginazione, mapping campi e formati italiani, Docker più cron con lock file e alert."
keywords: ["salesforce jwt export csv docker", "salesforce connected app jwt", "bulk api paginazione", "field mapping crm", "cron docker", "utente integrazione salesforce"]
image: /assets/images/posts/salesforce-jwt-export-csv-docker.jpg
pillar: integrazioni-dati
related: [/it/blog/agente-imap-pec-fatture/, /it/blog/mcp-salesforce-agente-produzione/]
---

## Il Data Loader aperto a mano alle tre di notte non è un processo

Conosco la scena perché me la raccontano in tanti: c'è "l'export di Salesforce" che serve ogni notte per alimentare il gestionale, il datawarehouse o un report. E "l'export" è una persona che, ogni tanto, apre il Data Loader sul suo PC, fa login, seleziona i campi a memoria, clicca Export, e salva un CSV su una cartella condivisa. Funziona finché quella persona c'è, si ricorda i campi giusti, e il suo PC è acceso. Poi va in ferie, cambia un campo, sbaglia l'encoding, e il gestionale a valle si rompe senza che nessuno capisca perché.

Quello non è un processo: è un rito che dipende da un umano e da una macchina. Un processo di **export Salesforce → CSV con JWT in Docker** è un'altra cosa: un container che ogni notte si autentica da solo (senza password, senza login interattivo), interroga solo gli oggetti che gli servono con un utente a permessi minimi, mappa i campi e i formati come deve, scrive un CSV pulito, e urla se qualcosa va storto. Nessun umano, nessun PC acceso, nessun campo dimenticato.

Questo pezzo è la ricetta di quell'exporter, con l'onestà di un'integrazione batch reale — **niente AI qui, è integrazione pura, verticale CRM.** Vedremo il JWT Bearer flow (e perché l'orologio e l'audience ti fregano), l'utente di integrazione con permessi per oggetto (e perché usare l'"Administrator" è una bomba), la paginazione con la Bulk API per non farti throttlare alle tre di notte, il mapping dei formati italiani (date, valuta, booleani), il CSV fatto bene (encoding, separatore, escaping, PII), Docker più cron con lock file e alert, e l'audit di chi ha scaricato cosa. Con gli scheletri copiabili.

È lo stesso rigore d'integrazione con cui ho costruito l'[agente IMAP per PEC e fatture]({{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}): autenticazione robusta, permessi minimi, idempotenza, alert. Cambia la sorgente (Salesforce invece della PEC), non la disciplina.

## JWT Bearer: rotazione, orologio, audience

Il primo problema di un export automatico è l'autenticazione. Non puoi mettere username e password in uno script che gira di notte: è fragile (la password scade, la MFA la blocca) e insicuro. La soluzione corretta per l'accesso *server-to-server* non presidiato è il **JWT Bearer flow** di OAuth 2.0.

Come funziona, in breve: crei una **Connected App** in Salesforce configurata con firma digitale (carichi un certificato X.509). Il tuo exporter firma un piccolo token JWT con la **chiave privata** corrispondente; Salesforce lo verifica con il certificato che ha, e — se tutto torna e l'utente è pre-autorizzato — restituisce un access token. Niente password, niente login interattivo, niente MFA da gestire. Solo una chiave privata che custodisci tu.

Il JWT ha quattro claim che devono essere giusti, e sono esattamente i quattro punti dove la gente sbaglia:

- **`iss` (issuer):** la Consumer Key (client_id) della Connected App.
- **`sub` (subject):** lo username dell'**utente di integrazione** per conto del quale ti autentichi.
- **`aud` (audience):** l'URL di login. `https://login.salesforce.com` per produzione, `https://test.salesforce.com` per sandbox. **Sbagliare qui è l'errore #1:** punti l'audience a produzione mentre l'utente è in sandbox (o viceversa) e ricevi un `invalid_grant` criptico che ti fa perdere ore.
- **`exp` (expiration):** una scadenza **brevissima** (pochi minuti). E qui il secondo trabocchetto: se l'**orologio** del container è disallineato rispetto a quello di Salesforce, l'`exp` risulta già scaduto o nel futuro, e il JWT viene rifiutato. Un container senza sincronizzazione NTP è una fonte inesauribile di `invalid_grant` misteriosi.

Il codice per costruire e scambiare il JWT, in Python:

```python
import jwt, time, requests   # pip install pyjwt cryptography requests

def ottieni_access_token() -> tuple[str, str]:
    """JWT Bearer flow: firma un JWT con la chiave privata, ottiene il token."""
    consumer_key = os.environ["SF_CONSUMER_KEY"]
    username     = os.environ["SF_INTEGRATION_USER"]   # NON admin
    login_url    = os.environ["SF_LOGIN_URL"]          # login o test .salesforce.com
    private_key  = open(os.environ["SF_PRIVATE_KEY_PATH"]).read()  # da secret

    now = int(time.time())
    claims = {
        "iss": consumer_key,
        "sub": username,
        "aud": login_url,          # DEVE combaciare con l'ambiente
        "exp": now + 180,          # 3 minuti: breve, ma serve l'orologio giusto
    }
    assertion = jwt.encode(claims, private_key, algorithm="RS256")

    r = requests.post(f"{login_url}/services/oauth2/token", data={
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": assertion,
    }, timeout=15)
    r.raise_for_status()
    d = r.json()
    return d["access_token"], d["instance_url"]   # instance_url per le query
```

Sulla **rotazione**: la chiave privata sta in un secret manager (o un secret mount di Docker), **mai** dentro l'immagine o in git. Il certificato caricato in Salesforce ha una scadenza: pianificane la rotazione *prima* che scada, o una notte l'export smette di funzionare in silenzio. La coppia chiave/certificato va trattata come la credenziale più preziosa dell'integrazione, perché lo è: chi ha la chiave privata può autenticarsi come quell'utente.

## Errori JWT comuni (la tabella che ti fa risparmiare ore)

Il JWT Bearer flow, quando non va, dà errori laconici. Ecco la mappa causa → sintomo, che vale l'intero articolo se ti trovi bloccato:

| Errore Salesforce | Causa reale | Fix |
|-------------------|-------------|-----|
| `invalid_grant` (generico) | `aud` sbagliato (login vs test) | usa l'URL dell'ambiente giusto |
| `invalid_grant` | orologio del container disallineato | sincronizza NTP, `exp` breve ma valido |
| `invalid_grant` | utente non pre-autorizzato alla Connected App | approva l'app per l'utente/permission set |
| `invalid_grant` | certificato/chiave non corrispondenti | verifica che la chiave firmi il cert caricato |
| `inactive user` | utente di integrazione disattivato | riattiva / verifica licenza |
| `user hasn't approved this consumer` | policy della Connected App | imposta "Admin approved users are pre-authorized" |

La regola diagnostica: **quasi tutti gli `invalid_grant` sono una di tre cose — audience, orologio, o pre-autorizzazione dell'utente.** Controlla quelle tre prima di impazzire. Logga il claim `aud` che stai inviando e l'ora del container: metà dei problemi si vedono subito.

## L'utente di integrazione: perché "Administrator" è una bomba

Questa è la sezione che il titolo promette, ed è la più importante per la sicurezza. La tentazione, quando configuri l'export, è usare un utente potente — magari il tuo, che è amministratore — "così ha sicuramente i permessi". È l'errore che trasforma un export innocuo in una bomba a orologeria.

Perché l'**utente Administrator è una bomba** per un'integrazione:

- **Raggio d'azione totale.** Un utente admin vede e modifica *tutto*: tutti gli oggetti, tutti i campi, tutti i record, più le impostazioni dell'org. Se la chiave privata dell'integrazione trapela (un log, un backup, un errore), chi la trova si autentica come amministratore e ha in mano l'intera organizzazione Salesforce.
- **Nessun limite agli errori.** Una query sbagliata, un bug nell'exporter: con un admin, il danno potenziale è su tutto. Con un utente a permessi minimi, il danno massimo è "ha letto gli oggetti che poteva già leggere".
- **Audit inutile.** Se l'integrazione gira come "l'admin", nei log di Salesforce non distingui le sue azioni da quelle vere dell'amministratore umano. Perdi tracciabilità.

La strada giusta: un **utente di integrazione dedicato**, con un **permission set** che concede il **solo necessario**:

- **Sola lettura** sugli oggetti che l'export deve leggere (Account, Contact, Opportunity… solo quelli).
- **Solo i campi necessari** (field-level security): se esporti nome, email e importo, l'utente non deve vedere note riservate o campi sensibili non richiesti.
- **Nessun permesso amministrativo**, nessuna modifica, nessuna cancellazione.
- **Restrizioni IP** se possibile (l'integrazione gira da un IP noto).
- **Un nome parlante** (`integrazione.export@…`) così nei log e nell'audit è riconoscibile.

Il principio è il least privilege, identico a quello del token per le issue o per qualsiasi agente che tocca un sistema esterno: **l'utente dell'export deve poter fare solo l'export.** Sola lettura, solo quegli oggetti, solo quei campi. Così una chiave che trapela è un incidente contenibile, non la fine del mondo. Configurare un utente dedicato costa mezz'ora; usarne uno admin costa, il giorno sbagliato, l'intera org.

## Paginazione e limiti API: non farti throttlare alle 3 di notte

Salesforce non ti lascia scaricare un milione di record con una singola chiamata, e ha **limiti giornalieri di API** per org (variano per edition). Se il tuo export fa migliaia di piccole chiamate REST, rischi due cose: la lentezza e il `REQUEST_LIMIT_EXCEEDED` che ti blocca — magari alle tre di notte, quando nessuno se ne accorge fino al mattino.

Due strategie, a seconda del volume:

- **REST query con paginazione** (`nextRecordsUrl`): per volumi piccoli/medi. La prima query torna un batch e un puntatore alla pagina successiva; segui il puntatore fino alla fine. Semplice, ma ogni pagina è una chiamata API: su grandi volumi consumi il budget in fretta.
- **Bulk API 2.0** (la scelta per i volumi seri): crei un *job* di query, Salesforce lo elabora in modo asincrono, poi scarichi i risultati a blocchi. Un job invece di migliaia di chiamate: è pensato apposta per l'export massivo e pesa pochissimo sul limite di API. È la **paginazione con Bulk API** corretta per un export notturno.

Il loop di paginazione REST, per capire il pattern:

```python
def query_paginata(access_token: str, instance_url: str, soql: str):
    h = {"Authorization": f"Bearer {access_token}"}
    url = f"{instance_url}/services/data/v60.0/query"
    params = {"q": soql}
    while url:
        r = requests.get(url, headers=h, params=params, timeout=30)
        r.raise_for_status()
        d = r.json()
        yield from d["records"]
        # pagina successiva: nextRecordsUrl è un path assoluto, niente params
        url = (instance_url + d["nextRecordsUrl"]) if not d["done"] else None
        params = None
```

Per la Bulk API il flusso è: `POST` per creare il job di query → *poll* dello stato finché non è `JobComplete` → `GET` dei risultati (con paginazione via header `Sforce-Locator`). Più codice, ma per volumi grandi è l'unica strada che non ti fa throttlare.

La regola operativa: **stima il volume e scegli di conseguenza.** Poche migliaia di record: REST paginata va bene. Decine o centinaia di migliaia: Bulk API, sempre. E in entrambi i casi, gestisci il `REQUEST_LIMIT_EXCEEDED` con un backoff e un alert — non con un retry cieco che peggiora il consumo. Il budget API è una risorsa condivisa dell'org: un export ingordo può affamare le altre integrazioni.

## Export incrementale: solo ciò che è cambiato

C'è un modo per ridurre drasticamente volume, tempo e consumo di API: non esportare tutto ogni notte, ma **solo i record cambiati** dall'ultimo giro. Salesforce mette a disposizione i campi di sistema `LastModifiedDate` e `SystemModstamp` proprio per questo: filtri la query su "modificato dopo l'ultima esecuzione riuscita" e scarichi il delta, non l'intero oggetto.

Il pattern del **delta export**:

1. Salvi il timestamp dell'ultima esecuzione riuscita (in UTC, come lo tratta Salesforce), in modo persistente (un file, una riga di DB).
2. La query filtra: `... WHERE SystemModstamp > {ultimo_run_utc}`.
3. Se il run va a buon fine, aggiorni il timestamp; se fallisce, **non** lo aggiorni, così il giro dopo riprende dal punto giusto e non perdi record.

```python
def soql_incrementale(base: str, oggetto: str, ultimo_run_utc: str) -> str:
    # SystemModstamp è in UTC: confronta con l'ultimo run in UTC
    return (f"{base} FROM {oggetto} "
            f"WHERE SystemModstamp > {ultimo_run_utc}")  # es. 2026-10-07T05:30:00Z
```

Due avvertenze oneste, perché il delta ha delle trappole:

- **Le cancellazioni non si vedono.** Un record eliminato in Salesforce non compare più nella query incrementale: a valle resta "fantasma". Se ti servono anche le cancellazioni, usa le API apposite (getDeleted) o periodicamente un **full export di riconciliazione** (es. settimanale) che riallinea tutto.
- **La finestra e il fuso.** Confronta timestamp UTC con UTC, con un piccolo margine di sovrapposizione (rileggi da qualche minuto prima dell'ultimo run) per non perdere record modificati proprio al confine. Meglio riesportare qualche record in più (idempotente a valle) che perderne uno.

La regola pratica: **delta ogni notte, full di riconciliazione periodico.** L'incrementale tiene bassi volume e carico API nel quotidiano; il full periodico cattura cancellazioni e ripara eventuali buchi. È lo stesso principio di idempotenza visto altrove — riesportare un record già visto non deve fare danni a valle, così puoi permetterti il margine di sicurezza sulla finestra.

## Mapping e formati italiani: date, valuta, booleani

Qui si annidano i bug silenziosi che rompono il sistema a valle senza un errore evidente. Salesforce ha i suoi formati interni; il tuo gestionale o report italiano ne vuole altri. Il **field mapping del CRM** non è solo "quale campo va in quale colonna": è anche *come si trasforma il valore*.

I punti dolenti:

- **Date e datetime.** Salesforce memorizza i datetime in **UTC**. Un report italiano li vuole in ora locale (`Europe/Roma`) e nel formato giusto (`gg/mm/aaaa`). Esportare l'UTC come fosse ora locale sfasa tutto di un'ora o due, e nessuno se ne accorge finché un orario non torna.
- **Valuta e decimali.** Salesforce usa il punto decimale (`1234.50`); l'Excel italiano si aspetta spesso la **virgola** (`1234,50`). Sbagliare qui fa leggere "1234.50" come testo o come numero errato.
- **Booleani.** `true`/`false` di Salesforce vanno spesso tradotti in `Sì`/`No`, `1`/`0`, o ciò che il sistema a valle vuole.
- **Valori nulli e picklist.** Un campo vuoto è stringa vuota o `NULL`? Le picklist esportano il valore API o l'etichetta? Vanno decisi, non lasciati al caso.

La soluzione pulita è un **mapping dichiarativo** in JSON, separato dal codice: definisci per ogni campo sorgente la colonna di destinazione e la trasformazione. Così cambiare un campo è modificare la configurazione, non il codice.

```json
{
  "oggetto": "Opportunity",
  "soql": "SELECT Id, Name, Amount, CloseDate, IsWon FROM Opportunity WHERE ...",
  "colonne": [
    { "sf": "Id",        "csv": "id_opportunita", "tipo": "string" },
    { "sf": "Name",      "csv": "nome",            "tipo": "string" },
    { "sf": "Amount",    "csv": "importo",         "tipo": "valuta_it" },
    { "sf": "CloseDate", "csv": "data_chiusura",   "tipo": "data_it" },
    { "sf": "IsWon",     "csv": "vinta",           "tipo": "bool_si_no" }
  ]
}
```

```python
from datetime import datetime
from zoneinfo import ZoneInfo

def trasforma(valore, tipo: str) -> str:
    if valore is None:
        return ""
    if tipo == "valuta_it":
        return f"{float(valore):.2f}".replace(".", ",")        # 1234,50
    if tipo == "data_it":
        # Salesforce datetime UTC -> ora locale IT, formato gg/mm/aaaa
        dt = datetime.fromisoformat(valore.replace("Z", "+00:00"))
        return dt.astimezone(ZoneInfo("Europe/Rome")).strftime("%d/%m/%Y")
    if tipo == "bool_si_no":
        return "Sì" if valore else "No"
    return str(valore)
```

Il mapping dichiarativo ha un vantaggio operativo enorme: **quando a valle chiedono "aggiungi la colonna X", modifichi il JSON, non il codice.** E il JSON versionato è la documentazione di cosa contiene il CSV — utile quando fra un anno nessuno ricorda perché quella colonna si chiama così.

## Il CSV fatto bene: encoding, separatore, escaping, PII

Il CSV sembra banale ed è dove muoiono le integrazioni. Un CSV scritto male rompe il sistema a valle o corrompe i dati in modo subdolo.

- **Encoding.** UTF-8 è lo standard giusto, ma l'Excel italiano a volte vuole UTF-8 **con BOM** per mostrare bene gli accenti (à, è, ò), o addirittura un encoding legacy se il sistema a valle è vecchio. Concordalo col destinatario e dichiaralo, non tirare a indovinare.
- **Separatore.** Il CSV "italiano" per Excel usa spesso il **punto e virgola** (`;`), non la virgola, proprio perché la virgola è il separatore decimale. Sbagliare il separatore rende il file una singola colonna illeggibile.
- **Escaping (RFC 4180).** I campi che contengono il separatore, virgolette o a-capo vanno racchiusi tra virgolette, e le virgolette interne raddoppiate. Un nome come `Rossi, Mario` o una nota con un a-capo, senza escaping, spostano tutte le colonne. Usa una libreria CSV seria, non concatenazioni a mano.
- **PII.** Il CSV di un export CRM è pieno di **dati personali**: nomi, email, telefoni, a volte dati sensibili. Il file va trattato come tale: storage cifrato, accesso ristretto, retention definita, e cancellazione quando non serve più. Un CSV di clienti dimenticato su una cartella condivisa è un data breach in attesa.

```python
import csv

def scrivi_csv(path: str, righe: list[dict], colonne: list[str]):
    # newline="" + BOM utf-8-sig per compatibilità Excel IT; separatore ';'
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=colonne, delimiter=";",
                           quoting=csv.QUOTE_MINIMAL)  # escaping RFC 4180
        w.writeheader()
        w.writerows(righe)
```

La regola: **il CSV è un contratto con il sistema a valle.** Encoding, separatore ed escaping vanno concordati e rispettati, non "di solito funziona". E il file, contenendo PII, è un dato da proteggere come tale — non un output tecnico neutro.

## L'architettura di riferimento

Ecco come dispongo l'exporter, con i confini. Nota: nessuna AI, è integrazione batch pura.

```
   Cron (in Docker) ──notte──▶ ┌────────────────────────────────┐
                               │ EXPORTER (container)            │
                               │ 1. JWT Bearer → access token    │
                               │    (chiave privata da secret)   │
                               │ 2. query Bulk API / REST paginata│
                               │    su oggetti CONSENTITI         │
                               │ 3. mapping + formati IT + tz     │
                               │ 4. CSV (encoding/sep/escaping)   │
                               └───────────────┬─────────────────┘
                                               ▼
                    ┌────────────────────┐  ┌──────────────────────┐
                    │ DESTINAZIONE:       │  │ AUDIT LOG:            │
                    │ storage cifrato,    │  │ chi/cosa/quando/righe │
                    │ retention           │  └──────────────────────┘
                    └────────────────────┘
                    LOCK FILE (no run sovrapposti) · ALERT su fail
```

**Cosa NON fa mai l'exporter (i confini):**

- L'utente di integrazione è **sola lettura** su oggetti/campi specifici: l'exporter non scrive né cancella nulla in Salesforce.
- La **chiave privata** non sta mai nell'immagine Docker: arriva da un secret a runtime.
- Il CSV con PII va **solo** alla destinazione controllata (storage cifrato), non su cartelle aperte.
- Non gira **due volte in parallelo**: il lock file lo impedisce.

Questa impostazione — credenziale a privilegio minimo, sola lettura, secret fuori dall'immagine, audit — è la stessa disciplina d'integrazione del pezzo su come scrive un [agente MCP su Salesforce in produzione]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}): là l'agente *scrive* con controlli fortissimi, qui l'exporter *legge* con permessi minimi. In entrambi i casi, il raggio del danno da una credenziale compromessa è ridotto al minimo per progetto.

## Docker + cron: lock file e alert su fallimento

L'exporter gira in un container, schedulato. Due cose lo trasformano da script fragile a processo affidabile: il **lock file** e l'**alert**.

- **Lock file.** Se una notte l'export impiega più del previsto (volume cresciuto, Salesforce lento) e nel frattempo parte il run successivo, hai due export sovrapposti che si pestano i piedi, raddoppiano il carico API e magari scrivono lo stesso file. Un lock file impedisce l'avvio se un run è già in corso.
- **Alert su fallimento.** Un export che fallisce in silenzio è peggio di nessun export: il sistema a valle usa dati vecchi credendoli freschi. Il job **deve** notificare quando fallisce (email, webhook, messaggio), con l'errore. Il fallimento va scoperto la mattina da un alert, non dal cliente che chiede perché i numeri sono di ieri.

Lo scheletro `docker-compose` + cron + lock:

```yaml
# docker-compose.yml
services:
  sf-exporter:
    build: .
    restart: unless-stopped
    environment:
      - SF_CONSUMER_KEY=${SF_CONSUMER_KEY}
      - SF_INTEGRATION_USER=${SF_INTEGRATION_USER}
      - SF_LOGIN_URL=https://login.salesforce.com
    secrets:
      - sf_private_key            # chiave privata come SECRET, non in immagine
    volumes:
      - ./output:/data/output     # destinazione CSV (poi su storage cifrato)
      - ./locks:/data/locks
secrets:
  sf_private_key:
    file: ./secrets/sf_private_key.pem
```

```bash
#!/bin/sh
# entrypoint con cron + lock file. Alert su fallimento.
LOCK=/data/locks/export.lock
if [ -e "$LOCK" ]; then
  echo "run precedente ancora attivo, salto"; exit 0
fi
touch "$LOCK"
trap 'rm -f "$LOCK"' EXIT           # rilascia il lock sempre, anche su errore

if ! python /app/export.py; then
  # ALERT: non fallire in silenzio
  curl -s -X POST "$ALERT_WEBHOOK" -d "export Salesforce FALLITO $(date)"
  exit 1
fi
```

Nota il `trap ... EXIT`: il lock si rilascia sempre, anche se lo script muore, così un crash non blocca per sempre i run futuri. E l'alert scatta sul fallimento reale, non su ogni singolo warning. Il **cron in Docker** ben fatto è questo: schedulazione, lock, rilascio garantito, notifica sul fallimento.

## Percorso di implementazione, a step

1. **Crea l'utente di integrazione** dedicato, con un permission set sola-lettura sugli oggetti/campi necessari. Mai un admin.
2. **Configura la Connected App** con firma digitale (carica il certificato), scope OAuth minimi, e pre-autorizza l'utente ("admin approved users").
3. **Metti la chiave privata in un secret** (secret manager o secret Docker), mai nell'immagine né in git.
4. **Implementa il JWT Bearer flow**, verificando audience (ambiente giusto) e sincronizzazione NTP del container.
5. **Scegli la strategia di lettura:** REST paginata per volumi piccoli, Bulk API per i grandi; gestisci `REQUEST_LIMIT_EXCEEDED`.
6. **Definisci il mapping dichiarativo** (JSON) con i formati italiani e la timezone.
7. **Scrivi il CSV** con encoding/separatore/escaping concordati col sistema a valle.
8. **Metti la destinazione su storage cifrato** con retention, e tratta il CSV come dato personale.
9. **Impacchetta in Docker con cron**, lock file e alert su fallimento.
10. **Aggiungi l'audit log** (chi/cosa/quante righe/quando) e testa un giro completo end-to-end.

## I fallimenti tipici e come li riconosci dai log

- **`invalid_grant` all'autenticazione.** Nel 90% dei casi: audience sbagliato (login vs test), orologio del container disallineato, o utente non pre-autorizzato. Logga il claim `aud` e l'ora del container: la causa salta fuori subito (vedi la tabella sopra).
- **`REQUEST_LIMIT_EXCEEDED`.** Hai consumato il budget API dell'org, spesso perché usi REST paginata su grandi volumi invece della Bulk API. Nei log lo vedi come errore su una pagina a metà export. Passa alla Bulk API e aggiungi backoff.
- **CSV illeggibile a valle.** Colonne tutte in una, accenti sbagliati: separatore o encoding non concordati. Il sistema a valle si lamenta o importa dati sballati. Verifica separatore (`;` per Excel IT) e BOM.
- **Orari sfasati di un'ora o due.** I datetime sono stati esportati in UTC senza conversione a `Europe/Roma`. Subdolo perché "quasi giusto". Controlla la trasformazione delle date.
- **Import a valle corrotto su nomi con virgola.** Manca l'escaping RFC 4180: `Rossi, Mario` ha spostato le colonne. Usa una libreria CSV, non concatenazioni.
- **Export che non parte / doppio.** Lock file non rilasciato (crash senza `trap`) o assente (run sovrapposti). Verifica la gestione del lock.
- **Fallimento silenzioso.** Il peggiore: l'export fallisce, il file non si aggiorna, e a valle usano dati vecchi credendoli nuovi. Se non c'è l'alert, lo scopri dal cliente. L'alert su fallimento non è opzionale.

La regola: **logga l'esito di ogni run** (successo/fallimento, righe esportate, durata, oggetto) e allarma sul fallimento. Un export che non dice come è andato è un export di cui non ti puoi fidare.

## Audit: chi ha scaricato cosa

Un export CRM muove **dati personali** fuori da Salesforce. Serve un audit: non solo per compliance, ma per poter rispondere a "chi ha estratto i dati dei clienti, quando, e quali". Due livelli:

- **Lato Salesforce:** siccome l'export gira come utente di integrazione dedicato (non come admin), nei log di Salesforce le sue letture sono riconoscibili e attribuibili a quell'utente. È un altro motivo per non usare l'admin: l'audit di Salesforce distingue l'integrazione dalle persone.
- **Lato exporter:** un log applicativo che registra ogni run — quando, quale oggetto, quante righe, dove è finito il file, con quale mapping/versione. Questo è il tuo registro di "chi ha scaricato cosa" dal lato tuo.

```python
def audit(store, oggetto: str, righe: int, destinazione: str, esito: str):
    store.append({
        "ts": datetime.now(ZoneInfo("Europe/Rome")).isoformat(),
        "utente_integrazione": os.environ["SF_INTEGRATION_USER"],
        "oggetto": oggetto,
        "righe": righe,
        "destinazione": destinazione,     # dove, non il contenuto
        "esito": esito,                   # ok | fail
    })
```

L'audit non salva i dati esportati (sarebbe un altro archivio di PII da proteggere): salva i **metadati** dell'operazione. Basta a ricostruire chi/cosa/quando, che è ciò che serve in caso di verifica o di richiesta di un interessato. È lo stesso principio dell'osservabilità: traccia l'operazione, non il dato sensibile.

## Costi: ordini di grandezza

Stime dichiarate.

- **API Salesforce:** l'export rientra nei limiti di API inclusi nella tua edition; la Bulk API pesa pochissimo. Nessun costo per chiamata di norma; il vincolo è il budget giornaliero, non l'euro. Un export ben fatto (Bulk) lascia margine per le altre integrazioni.
- **Infrastruttura:** un container che gira una volta a notte consuma quasi nulla. Può stare sullo stesso piccolo server/VPS in UE dove hai il resto dello stack. Come ordine di grandezza, costo infrastrutturale trascurabile.
- **Sviluppo:** JWT + lettura paginata/Bulk + mapping + CSV + Docker/cron + audit, come ordine di grandezza **due-quattro giornate/uomo** per un exporter di produzione robusto. Investimento una tantum, più poca manutenzione (rotazione certificato, nuovi campi nel mapping).
- **Il risparmio:** niente più persona che apre il Data Loader a mano, niente errori umani sui campi, niente notti in cui l'export non parte perché il PC era spento. Il processo automatico si ripaga in affidabilità e tempo liberato.
- **Costo del non farlo:** un export manuale che salta o sbaglia alimenta a valle dati errati, con decisioni prese su numeri sbagliati. E un utente admin usato per l'integrazione è un rischio di sicurezza che, il giorno sbagliato, costa molto più di qualche giornata di sviluppo.

## Quando NON farlo (o farlo diversamente)

- **Se ti serve la sincronizzazione in tempo reale**, un export batch notturno non è la risposta: valuta eventi/webhook (Salesforce Platform Events, streaming) o un'integrazione push. Il batch è per gli aggiornamenti periodici, non per il "subito".
- **Se il volume è enorme e cresce**, non insistere con la REST paginata: passa alla Bulk API o valuta strumenti di data integration dedicati. Forzare la REST su milioni di record ti fa throttlare e basta.
- **Se non puoi creare un utente di integrazione a permessi minimi**, fermati sulla configurazione prima che sul codice: usare un admin "per ora" è il rischio che questo articolo ti dice di non correre.
- **Se il dato a valle è sensibile e il canale non è sicuro**, non esportare su una cartella condivisa aperta: storage cifrato, accesso ristretto, retention. Il CSV di clienti è un data breach in attesa se trattato con leggerezza.
- **Se un prodotto standard fa già questo** (un connettore ETL supportato che rispetta i tuoi requisiti di sovranità), valutalo: non reinventare un exporter se una soluzione mantenuta copre il caso in modo sicuro e sotto il tuo controllo.

## Checklist operativa prima di andare live

- [ ] **Utente di integrazione dedicato**, sola lettura su oggetti/campi necessari — mai admin.
- [ ] **Connected App** con firma digitale, scope minimi, utente pre-autorizzato.
- [ ] **Chiave privata in un secret**, mai nell'immagine né in git; rotazione pianificata.
- [ ] **JWT Bearer** con `aud` dell'ambiente giusto e **NTP** sul container.
- [ ] **Strategia di lettura** adeguata al volume (REST paginata vs Bulk API), con gestione `REQUEST_LIMIT_EXCEEDED`.
- [ ] **Mapping dichiarativo** con formati italiani (data `gg/mm/aaaa`, valuta con virgola, booleani) e timezone `Europe/Rome`.
- [ ] **CSV** con encoding, separatore ed escaping concordati col sistema a valle.
- [ ] **Destinazione su storage cifrato**, retention definita, CSV trattato come PII.
- [ ] **Docker + cron** con **lock file** (rilasciato con `trap`) e **alert su fallimento**.
- [ ] **Audit log** dei run (chi/cosa/righe/quando), senza salvare i dati esportati.
- [ ] **Test end-to-end** e verifica del CSV a valle prima di affidarsi al processo.

## Il verdetto

Un **export Salesforce → CSV con JWT in Docker** fatto bene è la differenza tra un rito fragile e un processo affidabile. Il Data Loader aperto a mano dipende da una persona, da un PC acceso e da una memoria; l'exporter automatico si autentica da solo con JWT Bearer, legge con un utente a permessi minimi, mappa i formati come deve, scrive un CSV pulito e urla quando fallisce. Nessun umano nel ciclo notturno, nessun campo dimenticato, nessun dato vecchio spacciato per fresco.

I punti dove si vince o si perde sono precisi. Il JWT ti frega su tre cose — audience, orologio, pre-autorizzazione — e conoscerle ti risparmia ore di `invalid_grant`. La Bulk API ti evita di throttlare alle tre di notte. Il mapping dichiarativo con i formati italiani (date in ora locale, valuta con la virgola) evita i bug silenziosi a valle. Il CSV con encoding, separatore ed escaping giusti è un contratto, non un "di solito funziona". E Docker con cron, lock file e alert trasforma lo script in un processo che non si sovrappone e non fallisce in silenzio.

Ma la cosa che conta più di tutte è l'utente di integrazione. **L'Administrator usato per un'integrazione è una bomba:** se la chiave trapela, chi la trova ha in mano l'intera org. Un utente dedicato, sola lettura, solo su quegli oggetti e campi, riduce il raggio del danno a un incidente contenibile. Costa mezz'ora di configurazione; usarne uno admin costa, il giorno sbagliato, tutto. La differenza tra un exporter professionale e uno improvvisato non è la difficoltà del codice: è il privilegio minimo, l'affidabilità del processo e il rispetto dei dati che sposti.

Se hai un export Salesforce che oggi dipende da qualcuno che apre il Data Loader a mano, e vuoi trasformarlo in un processo automatico, sicuro e sovrano, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Integrazione batch fatta da ingegnere, non a mano.

## FAQ

### Perché il JWT Bearer e non username e password?
Perché un export automatico non presidiato non può dipendere da una password (scade, la blocca la MFA) né da un login interattivo. Il JWT Bearer flow autentica server-to-server firmando un token con una chiave privata che custodisci tu, verificata da Salesforce tramite un certificato. Niente password nello script, niente MFA da gestire: è il metodo corretto per le integrazioni non presidiate.

### Cosa causa la maggior parte degli errori invalid_grant?
Tre cose, quasi sempre: l'audience sbagliato nel JWT (produzione `login.salesforce.com` vs sandbox `test.salesforce.com`), l'orologio del container disallineato (che rende l'`exp` non valido — serve NTP), e l'utente di integrazione non pre-autorizzato alla Connected App. Logga il claim `aud` e l'ora del container e controlla la pre-autorizzazione: risolvi il grosso dei casi in pochi minuti.

### Perché non usare un utente Administrator per l'export?
Perché un admin vede e modifica tutto: se la chiave privata dell'integrazione trapela, chi la trova controlla l'intera org. Un utente di integrazione dedicato, in sola lettura sui soli oggetti e campi necessari, riduce il raggio del danno a "ha letto ciò che poteva leggere". In più rende l'audit possibile: nei log di Salesforce distingui l'integrazione dalle persone. È least privilege applicato al CRM.

### REST paginata o Bulk API?
Dipende dal volume. Per poche migliaia di record la REST con `nextRecordsUrl` va bene ed è semplice. Per decine o centinaia di migliaia, la Bulk API 2.0: crei un job asincrono e scarichi i risultati a blocchi, con un impatto minimo sul budget di API. Forzare la REST su grandi volumi consuma il limite giornaliero e ti fa throttlare, magari di notte quando nessuno se ne accorge.

### Che formati devo usare nel CSV per l'Italia?
Concordali col sistema a valle, ma tipicamente: encoding UTF-8 (con BOM se il destinatario è Excel italiano e vuole gli accenti giusti), separatore punto e virgola (`;`, perché la virgola è il separatore decimale), date in `gg/mm/aaaa` convertite da UTC a `Europe/Roma`, valuta con la virgola decimale, booleani tradotti (Sì/No). E sempre l'escaping RFC 4180 per i campi con separatori o a-capo.

### Come evito che due export girino insieme?
Con un lock file: all'avvio, se il lock esiste, il run salta; altrimenti lo crea e lo rilascia alla fine, anche in caso di crash (con un `trap ... EXIT` nello script). Così se una notte l'export dura più del previsto e nel frattempo parte lo schedule successivo, il secondo non parte e non pesti i piedi al primo, evitando doppio carico API e file corrotti.

### Dove metto la chiave privata?
In un secret manager o in un secret di Docker montato a runtime, mai dentro l'immagine e mai in git. La chiave privata è la credenziale più preziosa dell'integrazione: chi la possiede si autentica come l'utente di integrazione. Pianifica anche la rotazione del certificato prima che scada, o una notte l'export smette di funzionare senza preavviso.

### Come gestisco l'audit di un export che muove dati personali?
Su due livelli: lato Salesforce, l'utente di integrazione dedicato rende le letture attribuibili a lui nei log (un altro motivo per non usare l'admin); lato exporter, un log applicativo che registra ogni run con metadati — quando, quale oggetto, quante righe, dove è finito il file, con quale versione del mapping. Salvi i metadati dell'operazione, non i dati esportati, così hai la tracciabilità senza creare un altro archivio di PII.

### E se l'export fallisce di notte?
Deve avvisarti: un alert (email, webhook) sul fallimento reale, con l'errore, è obbligatorio. Il fallimento silenzioso è il rischio peggiore, perché a valle usano dati vecchi credendoli aggiornati e prendono decisioni su numeri sbagliati. Meglio scoprire il problema da un alert la mattina che dal cliente che chiede perché i numeri sono di ieri. Logga sempre l'esito di ogni run.

### Questo vale solo per Salesforce?
Il pattern è generale per gli export batch da un CRM/gestionale cloud: autenticazione server-to-server a privilegio minimo, lettura paginata rispettando i limiti API, mapping dichiarativo con i formati locali, CSV come contratto, container schedulato con lock e alert, audit dei run. Cambiano i dettagli (il tipo di token, gli endpoint, i limiti), ma i principi — least privilege, affidabilità del processo, rispetto dei dati — restano gli stessi.
