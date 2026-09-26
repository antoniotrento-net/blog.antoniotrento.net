---
lang: it
permalink: /it/blog/human-in-the-loop-pec-sepa/
title: "Human-in-the-loop che funziona: una coda di approvazione (non \"scrivi OK in chat\") prima che l'agente spedisca PEC o SEPA"
date: 2026-10-21 07:30:00 +0200
author: "Antonio Trento"
description: "Dual control per le azioni irreversibili di un agente AI in Italia: PEC con valore legale, bonifici SEPA non revocabili, pubblicazioni e cancellazioni. Coda immutabile con hash del payload, ruoli separati, scadenze, approvazione da mobile senza phishing e audit da conservare per anni."
keywords: ["human in the loop pec sepa", "approvazione agente ai", "coda review", "dual control pagamenti", "pec automatica rischi", "quattro occhi pagamenti"]
image: /assets/images/posts/human-in-the-loop-pec-sepa.jpg
pillar: agenti-esecuzione
related: [/it/blog/kill-switch-agente-salesforce/, /it/blog/agente-imap-pec-fatture/]
---

## Irreversibile: PEC, SEPA, post, delete

Ci sono azioni che un agente può sbagliare e tu puoi correggere: un campo aggiornato male nel CRM, una bozza scritta male, un ticket assegnato alla persona sbagliata. E ci sono azioni che, una volta fatte, **non tornano indietro**. In un'azienda italiana, le più comuni sono quattro:

- **Una PEC inviata.** La posta elettronica certificata ha valore legale: il sistema genera una ricevuta di accettazione e una di consegna, che attestano che *quel* messaggio, con *quegli* allegati, è stato consegnato in *quel* momento. Non esiste il "richiama messaggio". Una diffida inviata per errore, un preavviso di recesso al fornitore sbagliato, un allegato con i dati di un altro cliente: sono fatti compiuti, opponibili, e nel terzo caso anche una potenziale violazione di dati personali.
- **Un bonifico SEPA eseguito.** Un bonifico ordinario, una volta eseguito dalla banca, non è revocabile dall'ordinante: esiste una procedura di richiamo, ma il suo esito dipende dalla banca del beneficiario e spesso dal consenso del beneficiario stesso. Con il **bonifico istantaneo** i fondi arrivano in pochi secondi: nella pratica, irreversibile. Un bonifico verso l'IBAN sbagliato — magari quello che un fornitore "ha comunicato di aver cambiato" — è denaro che probabilmente non rivedrai.
- **Un post pubblicato.** Sui social, una pubblicazione dura il tempo di uno screenshot: puoi cancellarla, non puoi cancellare chi l'ha già vista e salvata.
- **Una cancellazione.** Un record eliminato, un documento distrutto, un account chiuso: i backup aiutano, quando ci sono e quando il ripristino è possibile senza danni collaterali.

Quando un agente AI inizia a preparare queste azioni — e sta succedendo: agenti che gestiscono la PEC, che preparano i pagamenti delle fatture, che pubblicano contenuti — la domanda non è se l'agente sbaglierà, ma **cosa si frappone tra il suo errore e il mondo reale**. La risposta seria si chiama **human-in-the-loop con dual control**, e non ha niente a che fare con l'agente che ti chiede "confermi? scrivi OK".

Questo pezzo è sulla progettazione di quella barriera, con l'**angolo delle operazioni irreversibili in Italia**: la coda di approvazione con record immutabile e hash del payload, la separazione tra chi propone e chi approva, cosa succede quando nessuno clicca, l'approvazione dal telefono senza farsi rubare il consenso con un phishing, e cosa conservare per anni come evidenza. È il seguito naturale del pezzo sul [kill switch per agenti che scrivono su Salesforce]({{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }}), dove ho descritto dry-run e coda per le scritture su un CRM: qui la posta è più alta, perché l'errore non si corregge con un altro aggiornamento.

## Perché il messaggio in chat non è dual control

Il **dual control** (o principio dei quattro occhi) è una regola antica, nata per i pagamenti: un'operazione rischiosa richiede che **due persone diverse** la vedano e la autorizzino, e che ciascuna risponda della propria decisione. È il motivo per cui in molte aziende un bonifico sopra una certa cifra richiede due firme.

L'agente che scrive in chat "Sto per inviare la PEC di diffida alla Rossi Srl. Confermi?" e l'utente che risponde "OK" **non è dual control**, per ragioni strutturali:

- **Non c'è legame con il contenuto esatto.** "OK" a cosa? Al riassunto che l'agente ha scritto, non al messaggio, agli allegati e al destinatario che verranno effettivamente inviati. Tra il riassunto e l'azione, il contenuto può cambiare.
- **È lo stesso canale dell'agente.** La conversazione è lo spazio in cui l'agente legge input esterni. Un'istruzione iniettata in un documento può far scrivere all'agente un riassunto rassicurante per un'azione diversa — ne ho parlato a proposito della prompt injection nei documenti che cambia l'IBAN in fattura.
- **Chi chiede è spesso chi conferma.** L'utente che ha chiesto all'agente di preparare il pagamento è lo stesso che scrive "OK". Una sola persona, non due.
- **Nessuna identità verificata.** "OK" arriva da chiunque abbia accesso a quella sessione di chat.
- **Nessuna scadenza.** Un "OK" dato due ore fa vale ancora per un'azione rimodulata nel frattempo?
- **Nessuna evidenza.** Tra sei mesi, quando il revisore chiederà chi ha autorizzato quel bonifico, avrai una riga di chat in un sistema di terzi, forse.

Il dual control vero ha tre proprietà: **legame crittografico con il payload esatto**, **identità verificata e distinta** di chi propone e chi approva, **evidenza immutabile** della decisione. Il resto dell'articolo è come costruirle.

## L'architettura di riferimento

```
  ┌──────────────┐
  │ AGENTE (LLM)  │  propone, non esegue. Nessuna credenziale PEC/banca.
  └──────┬───────┘
         │ proposta: payload strutturato (JSON)
         ▼
  ┌───────────────────────────────────────────────┐
  │ VALIDATORE (deterministico)                    │
  │ schema · IBAN checksum · IBAN = anagrafica?    │
  │ PEC destinatario in rubrica? · allegati ok?     │
  │ soglie · orari · freeze                         │
  └──────┬────────────────────────────────────────┘
         ▼
  ┌───────────────────────────────────────────────┐
  │ CODA DI APPROVAZIONE (record immutabile)       │
  │ payload canonico + hash SHA-256 + versione      │
  │ stato · scadenza · ruoli richiesti              │
  └──────┬────────────────────────────────────────┘
         │ notifica SENZA link d'azione
         ▼
  ┌───────────────────────────────────────────────┐
  │ APP/PORTALE DI APPROVAZIONE (MFA/passkey)      │
  │ mostra il payload dal server, evidenzia novità │
  │ approvatore ≠ proponente; 2° approvatore sopra │
  │ soglia                                          │
  └──────┬────────────────────────────────────────┘
         ▼
  ┌───────────────────────────────────────────────┐
  │ ESECUTORE (unico con le credenziali)           │
  │ ricalcola hash · verifica scadenza e freeze    │
  │ → gateway PEC / API bancaria                    │
  └──────┬────────────────────────────────────────┘
         ▼
  AUDIT LOG append-only, catena di hash, conservazione pluriennale
  (ricevute PEC, riferimenti bancari, decisioni, identità)
```

**Cosa non tocca l'agente**: le credenziali della casella PEC e dell'home banking o dell'API bancaria, lo stato della coda, le soglie, le rubriche di destinatari e le anagrafiche degli IBAN. L'agente prepara; un validatore deterministico controlla; due persone decidono; un esecutore, l'unico con le chiavi, esegue esattamente ciò che è stato approvato.

## La coda: record immutabile, hash del payload

Il cuore del sistema è la **coda di approvazione**, e il cuore della coda è una regola: **si approva un payload, non una descrizione**. Il payload è la rappresentazione completa e strutturata dell'azione:

- per una PEC: mittente, destinatari, oggetto, corpo, elenco degli allegati con il loro hash;
- per un bonifico: ordinante, beneficiario, IBAN, importo, valuta, causale, data di esecuzione, riferimento alla fattura;
- per un post: canale, testo, media con il loro hash, data di pubblicazione.

Il payload viene serializzato in forma **canonica** (JSON con chiavi ordinate, senza spazi superflui, codifica fissa) e se ne calcola l'**hash SHA-256**. Quell'hash è l'identità dell'azione: l'approvatore approva quell'hash, e l'esecutore, prima di agire, ricalcola l'hash del payload che sta per eseguire e verifica che coincida con quello approvato. Se anche un carattere della causale o un byte di un allegato è cambiato, l'hash non coincide e l'esecuzione si blocca.

Le regole della coda:

- **Record immutabili.** Una proposta non si modifica: se serve una correzione, si crea una **nuova versione**, con un nuovo hash, e tutte le approvazioni della versione precedente decadono.
- **Stati espliciti** con transizioni ammesse, niente scorciatoie.
- **Ogni transizione è un evento** nell'audit log, con chi, quando, come.

Gli **stati della coda**:

```
DRAFT ──(validazione ok)──► PENDING_REVIEW ──(approva 1)──► APPROVED_1
  ▲                            │    │                           │
  │ (nuova versione)           │    │ rifiuta                   │ sopra soglia?
  └──── CHANGES_REQUESTED ◄────┘    ▼                           ├── sì ──► PENDING_SECOND
                                 REJECTED                       │              │ (approva 2)
                                                                │              ▼
  PENDING_* ──(scadenza)──► EXPIRED                             └── no ──► READY ◄──┘
                                                                              │
                                        (freeze attivo / hash non valido) ◄──┤
                                                    BLOCKED                   ▼
                                                                         EXECUTING
                                                                          │     │
                                                                     EXECUTED  FAILED
                                                              (ricevute/riferimenti)
```

E il nucleo dell'esecutore, che applica le regole senza eccezioni:

```python
import hashlib, json
from datetime import datetime, timezone

def canonico(payload: dict) -> bytes:
    return json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()

def hash_payload(payload: dict) -> str:
    return hashlib.sha256(canonico(payload)).hexdigest()

TRANSIZIONI = {
    "DRAFT": {"PENDING_REVIEW"},
    "PENDING_REVIEW": {"APPROVED_1", "REJECTED", "CHANGES_REQUESTED", "EXPIRED"},
    "APPROVED_1": {"PENDING_SECOND", "READY"},
    "PENDING_SECOND": {"READY", "REJECTED", "EXPIRED"},
    "READY": {"EXECUTING", "BLOCKED", "EXPIRED"},
    "EXECUTING": {"EXECUTED", "FAILED"},
}

def esegui(azione, store, esecutori, freeze):
    if azione.stato != "READY":
        raise RuntimeError(f"stato non eseguibile: {azione.stato}")
    if freeze.attivo(azione.tipo):
        return store.transizione(azione, "BLOCKED", motivo="freeze")
    if datetime.now(timezone.utc) > azione.scadenza:
        return store.transizione(azione, "EXPIRED", motivo="scaduta prima dell'esecuzione")
    payload = store.payload_versione(azione.id, azione.versione)
    if hash_payload(payload) != azione.hash_approvato:            # ciò che esegui = ciò che è stato approvato
        return store.transizione(azione, "BLOCKED", motivo="hash non corrispondente")
    if not store.approvazioni_complete(azione):                   # 1 o 2 approvatori secondo la soglia
        return store.transizione(azione, "BLOCKED", motivo="approvazioni insufficienti")
    store.transizione(azione, "EXECUTING")
    try:
        ricevuta = esecutori[azione.tipo].invia(payload, chiave_idempotenza=azione.id)
        return store.transizione(azione, "EXECUTED", evidenza=ricevuta)
    except Exception as e:
        return store.transizione(azione, "FAILED", motivo=type(e).__name__)
```

Nota la **chiave di idempotenza** passata al gateway: se la connessione cade dopo l'invio e l'esecutore ritenta, il sistema a valle deve riconoscere che è la stessa operazione. Una PEC inviata due volte o un bonifico duplicato sono esattamente il tipo di errore che la coda dovrebbe impedire, non causare.

## Validazione prima della coda: non far perdere tempo agli umani

Un approvatore stanco di proposte sbagliate inizia ad approvare senza guardare. Per questo, prima che una proposta arrivi a un umano, un **validatore deterministico** scarta ciò che è certamente sbagliato e segnala ciò che è anomalo:

- **Schema e formati**: campi obbligatori, IBAN con checksum valido, importi positivi con due decimali, indirizzi PEC ben formati. Ho descritto il contratto dati tra agente e strumenti nel pezzo sul JSON Schema e sull'IBAN inventato: vale integralmente qui.
- **Coerenza con l'anagrafica**: l'IBAN è quello registrato per quel fornitore? Se è **nuovo o diverso**, la proposta non viene scartata ma **marcata ad alto rischio** e richiede sempre due approvatori, più una verifica fuori banda (vedi sotto).
- **Coerenza con il documento sorgente**: l'importo del bonifico corrisponde al totale della fattura elettronica da cui è stato generato? Il riferimento alla fattura esiste e non è già stato pagato?
- **Destinatari PEC**: il destinatario è in rubrica, è l'indirizzo PEC ufficiale della controparte? Gli allegati contengono solo documenti di quel cliente?
- **Soglie e orari**: sopra soglia, doppia approvazione; fuori orario, niente esecuzioni automatiche.

Se l'agente lavora sulle fatture passive che arrivano via PEC — come nel pezzo sull'[agente IMAP per PEC e fatture]({{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}) — il validatore è il punto in cui il pagamento proposto viene riconciliato con la fattura e con l'anagrafica, prima che un umano debba farlo a occhio.

## Ruoli: proponente vs approvatore

Il dual control ha senso solo se i ruoli sono **separati e verificati**:

- **Il proponente** è chi ha originato l'azione: l'agente (registrato con la sua identità tecnica, il modello e la versione della sua configurazione) e l'eventuale utente che gliel'ha chiesta.
- **Il primo approvatore** è una persona con il ruolo adeguato (per i pagamenti, chi ha la delega in amministrazione; per le PEC legali, chi ha la responsabilità di quel tipo di comunicazione).
- **Il secondo approvatore**, sopra soglia o per le azioni ad alto rischio (IBAN nuovo, PEC di diffida o recesso), è un'altra persona, con un ruolo uguale o superiore.

Le regole che il sistema impone, non la buona volontà:

- **Chi ha chiesto l'azione all'agente non può approvarla.** Se Mario chiede all'agente di preparare il pagamento, Mario non è un approvatore valido per quel pagamento.
- **I due approvatori sono persone diverse**, verificate con autenticazione forte.
- **Le deleghe sono esplicite e temporanee.** Se la responsabile amministrativa è in ferie, delega un sostituto per un periodo definito; la delega è registrata, visibile, e non trasferisce il ruolo in modo permanente.
- **Nessun "super-approvatore" tecnico.** L'amministratore di sistema non approva pagamenti: gestisce il sistema. Separare chi mantiene lo strumento da chi decide le operazioni evita che una sola persona possa sia configurare sia autorizzare.

## Timeout: cosa succede se nessuno clicca

Ogni proposta ha una **scadenza**, e la regola d'oro è semplice: **alla scadenza, l'azione non viene eseguita.** Mai "se nessuno risponde entro un'ora, procedo". Il silenzio non è consenso, soprattutto per un'azione irreversibile.

Ma una scadenza che fa semplicemente "sparire" le proposte crea un altro rischio: operazioni necessarie che non avvengono. Alcune hanno **termini legali o contrattuali** — una PEC di contestazione entro un termine, un pagamento con scadenza e penale di mora. Per queste, il timeout deve **scalare**, non tacere:

- **Promemoria** all'approvatore a metà del tempo disponibile.
- **Escalation al delegato** se il titolare del ruolo non risponde entro una soglia.
- **Allarme alla responsabile di processo** prima della scadenza, se l'azione ha un termine legale.
- **Stato EXPIRED visibile** in una dashboard: un'azione scaduta non è un'azione dimenticata, è un'azione che qualcuno deve decidere di riproporre o di chiudere.

Considera anche gli **orari operativi**: le banche hanno orari limite per i bonifici con esecuzione in giornata; una PEC legale inviata alle 23:58 dell'ultimo giorno utile è un rischio che nessuno vuole. La coda conosce questi vincoli e li mostra all'approvatore ("se approvi dopo le 15:30, il bonifico sarà eseguito domani").

## Mobile: approvazione da telefono con rischio phishing

Gli approvatori sono persone impegnate, e vorranno approvare dal telefono. È giusto permetterlo, ma è anche il punto in cui un attaccante proverà a **rubare l'approvazione**: una email o un SMS che imita la notifica della coda, con un link a una pagina identica che chiede le credenziali, o che mostra un pagamento diverso da quello reale. Se il tuo sistema di approvazione funziona "clicca sul link nella email e conferma", hai costruito il bersaglio perfetto per un phishing.

Le regole **anti-phishing dell'approvazione**:

1. **Le notifiche non contengono link d'azione.** La notifica dice solo "hai un'approvazione in attesa", senza importi, IBAN o pulsanti. L'approvatore apre **l'app o il portale** che conosce, non un link ricevuto.
2. **Autenticazione resistente al phishing.** L'approvazione richiede un'autenticazione forte al momento della decisione, preferibilmente con **passkey** (standard WebAuthn/FIDO2), che per costruzione non funzionano su un sito falso perché sono legate al dominio. I codici via SMS sono meglio di niente, ma intercettabili e inseribili in una pagina di phishing.
3. **Il contenuto viene dal server, non dal messaggio.** L'app mostra il payload recuperato dalla coda: beneficiario, IBAN completo, importo, causale, allegati. Mai informazioni prese da un parametro nell'URL o dal testo di una notifica.
4. **Le novità sono evidenziate.** Se l'IBAN è diverso da quello registrato per quel fornitore, lo schermo lo mostra in modo impossibile da ignorare: "IBAN NUOVO rispetto all'anagrafica — verifica telefonica richiesta".
5. **Conferma attiva, non un tap.** Per le azioni ad alto rischio, l'approvatore digita un elemento del payload (per esempio le ultime quattro cifre dell'IBAN o l'importo), che non può fare "a occhi chiusi".
6. **Verifica fuori banda per gli IBAN nuovi.** Una variazione delle coordinate bancarie di un fornitore si conferma **telefonando** al fornitore a un numero già noto (non a quello indicato nella comunicazione che annuncia il cambio). È la contromisura più efficace contro le frodi sul cambio IBAN, ed è un gesto umano, non tecnologico.
7. **Anomalie segnalate.** Approvazioni da un dispositivo nuovo, da un paese insolito, alle tre di notte, o una raffica di approvazioni in pochi secondi: il sistema le segnala e, per le azioni sopra soglia, le blocca in attesa di conferma.

## Forensics: cosa tieni per dieci anni

Un'operazione irreversibile genera responsabilità che durano. Tra un anno, o tra cinque, qualcuno potrebbe chiedere: chi ha autorizzato quel bonifico? Quale versione della PEC è stata approvata? Chi aveva proposto l'azione, e sulla base di quale documento? Le risposte devono esistere, essere complete e non essere alterabili.

**Quanto conservare** dipende dal tipo di operazione e va definito con il commercialista e con il consulente legale — non è un parere legale. Come riferimento: le scritture contabili e i documenti collegati hanno in Italia obblighi di conservazione pluriennali (il codice civile prevede dieci anni per le scritture contabili), e le evidenze delle PEC con valore legale vanno conservate almeno quanto i rapporti a cui si riferiscono. Per questo tipo di audit, **dieci anni** è un orizzonte prudente per la parte che riguarda i pagamenti.

I **campi dell'audit log**, per ogni evento:

```json
{
  "evento_id": "evt_01J9ZK...",
  "azione_id": "act_2026_10_000482",
  "versione": 2,
  "tipo": "sepa_credit_transfer",
  "transizione": "APPROVED_1 -> PENDING_SECOND",
  "timestamp_utc": "2026-10-21T08:14:37.412Z",
  "payload_hash": "9f2c1a...e41b",
  "payload_ref": "vault://audit/act_2026_10_000482/v2.json.enc",
  "sintesi": { "beneficiario": "Fornitore Esempio Srl", "iban_mascherato": "IT60X054281...3456",
               "iban_hash": "5d1e...", "importo": "4880.00", "valuta": "EUR",
               "iban_in_anagrafica": false, "rif_documento": "FE 2026/1187" },
  "proponente": { "tipo": "agente", "id": "agente-contabilita", "modello": "llm-locale-8b-q5",
                  "config_versione": "2.3.0", "trace_id": "tr_7c1f...", "richiesto_da": "u_1042" },
  "attore": { "user_id": "u_2210", "ruolo": "responsabile_amministrativo", "delega_da": null,
              "auth": "passkey", "device_id": "dev_ab91", "ip": "93.xx.xx.xx" },
  "decisione": "approva", "commento": "IBAN verificato telefonicamente al numero in anagrafica",
  "verifica_fuori_banda": true,
  "scadenza": "2026-10-21T15:30:00Z",
  "hash_evento_precedente": "a71b...09cd",
  "hash_evento": "c30e...77f2"
}
```

Alcune scelte da notare:

- **Il payload completo è conservato**, ma cifrato e referenziato; nell'evento c'è una sintesi con l'IBAN mascherato e un suo hash. Chi consulta il log non vede dati bancari completi, ma l'evidenza completa esiste e si può verificare.
- **Il proponente include l'identità tecnica dell'agente**: quale modello, quale versione della configurazione, quale trace. Se tra un anno emerge un errore sistematico, sai quali azioni sono state proposte con quella configurazione.
- **La catena di hash**: ogni evento contiene l'hash del precedente. Modificare o cancellare un evento rompe la catena, e la verifica periodica lo rileva. È la stessa idea di un registro a prova di manomissione, senza bisogno di tecnologie esotiche.
- **Le evidenze dell'esecuzione** (identificativi delle ricevute PEC di accettazione e consegna, riferimento end-to-end del bonifico o riferimento della banca) vengono aggiunte come evento finale.

Lo storage dell'audit deve essere **append-only**: il servizio che scrive gli eventi non ha permessi di modifica o cancellazione, e le copie vanno su un supporto che impedisce la riscrittura per il periodo di conservazione. In Postgres, per esempio, l'utente applicativo ha solo il permesso di inserire, e la verifica della catena gira periodicamente:

```sql
-- L'applicazione può solo aggiungere eventi, mai modificarli o cancellarli
REVOKE UPDATE, DELETE, TRUNCATE ON audit_eventi FROM app_coda;
GRANT INSERT, SELECT ON audit_eventi TO app_coda;

-- Verifica periodica della catena: ogni evento deve puntare all'hash del precedente
SELECT e.evento_id
FROM audit_eventi e
JOIN audit_eventi p ON p.seq = e.seq - 1
WHERE e.hash_evento_precedente <> p.hash_evento;   -- deve restituire zero righe
```

Il valore di tutto questo emerge il giorno in cui serve: un contenzioso con un fornitore, una verifica fiscale, un'indagine interna su un pagamento anomalo. Con questo audit, la risposta a "chi ha autorizzato cosa, quando e su quali basi" è una query, non una ricostruzione da email e chat.

## MVP: solo PEC e pagamenti sopra soglia

Un sistema di dual control completo per ogni azione dell'agente è un progetto grande, e rischia di rallentare tutto al punto che le persone lo aggirano. L'MVP che consiglio parte da ciò che è davvero irreversibile e costoso:

- **PEC in uscita**: tutte in coda, con un approvatore; le PEC con valore di contestazione, diffida, recesso o messa in mora con doppia approvazione.
- **Bonifici sopra soglia** (la soglia la decide l'amministrazione, per esempio sopra qualche migliaio di euro) e **qualsiasi bonifico verso un IBAN nuovo o modificato**, indipendentemente dall'importo: doppia approvazione e verifica telefonica.
- **Tutto il resto dell'agente resta in modalità bozza**: prepara, e un umano esegue nel suo strumento abituale (il gestionale, l'home banking con i suoi controlli). Non tutto deve passare dalla coda il primo giorno.
- **Pubblicazioni social e cancellazioni** nella seconda fase, con le stesse regole.

Fuori dall'MVP, e per un buon motivo: l'**esecuzione automatica dei pagamenti ricorrenti** (stipendi, F24, utenze). Hanno già processi e controlli propri nei sistemi bancari e gestionali; farli passare da un agente aggiunge rischio senza aggiungere valore.

## Percorso di implementazione, a step

1. **Elenca le azioni irreversibili** che l'agente prepara o potrebbe preparare, e classificale per rischio: PEC ordinarie, PEC legali, bonifici sotto e sopra soglia, IBAN nuovi, pubblicazioni, cancellazioni.
2. **Togli all'agente le credenziali** di PEC e banca: le avrà solo l'esecutore.
3. **Definisci il payload canonico** per ogni tipo di azione, con l'hash di ogni allegato.
4. **Scrivi il validatore**: schema, checksum IBAN, confronto con anagrafica e rubrica, riconciliazione con il documento sorgente, soglie, orari.
5. **Costruisci la coda** con stati, transizioni ammesse, versioni immutabili, scadenze e regole di escalation.
6. **Configura ruoli e deleghe**: chi può approvare cosa, regola "chi chiede non approva", secondo approvatore sopra soglia.
7. **Realizza l'app di approvazione** con autenticazione a passkey, payload dal server, novità evidenziate, conferma attiva per l'alto rischio, notifiche senza link.
8. **Implementa l'esecutore** con verifica dell'hash, della scadenza e del freeze, e chiavi di idempotenza verso i gateway.
9. **Metti l'audit append-only** con catena di hash, payload cifrati e verifica periodica; definisci con il commercialista la durata di conservazione.
10. **Parti con l'MVP** (PEC e pagamenti sopra soglia) e misura: tempi di approvazione, scadute, rifiuti e motivi.

## Fallimenti tipici e come li riconosci dai log

- **Approvazioni in pochi secondi, sempre.** Tempo medio tra apertura e approvazione di due o tre secondi su bonifici importanti: l'approvatore non sta guardando. È un segnale di sovraccarico (troppe proposte, molte banali) o di abitudine. Riduci il volume in coda e introduci la conferma attiva.
- **Molte proposte scadute.** Le approvazioni non arrivano in tempo: approvatori non raggiungibili, deleghe mancanti, notifiche inefficaci. Con azioni a termine legale, è un rischio da trattare subito.
- **Esecuzioni bloccate per hash non corrispondente.** Qualcosa ha modificato il payload dopo l'approvazione: un bug (serializzazione non canonica, per esempio un ordine delle chiavi diverso) o un tentativo di manomissione. In entrambi i casi il blocco ha funzionato; va capita la causa.
- **Stesso utente come proponente e approvatore.** Il sistema dovrebbe impedirlo; se compare nei log, la regola non è applicata.
- **IBAN nuovi approvati senza verifica fuori banda.** Nei log, `iban_in_anagrafica: false` con `verifica_fuori_banda: false` su un'azione eseguita: il processo è stato saltato.
- **Tentativi di approvazione da dispositivi o luoghi insoliti.** Possibile furto di credenziali o phishing in corso.
- **Doppie esecuzioni dopo un errore di rete.** Due ricevute per la stessa azione: manca o non funziona la chiave di idempotenza.
- **Catena di hash rotta.** La verifica periodica trova un evento che non punta al precedente: qualcuno ha modificato o cancellato record. Incidente di sicurezza.

## Costi: ordini di grandezza

Stime indicative.

- **Sviluppo**: coda, validatore, app di approvazione, esecutore e audit per l'MVP (PEC e pagamenti sopra soglia) richiedono nell'ordine di **alcune settimane** di lavoro. È la voce principale.
- **Canali**: la casella PEC e il suo gateway hanno costi annuali contenuti per volumi da PMI; l'accesso programmatico ai pagamenti (tramite i servizi della propria banca o fornitori che espongono le API previste dalla normativa europea sui servizi di pagamento) ha costi variabili a seconda del fornitore e dei volumi.
- **Infrastruttura**: la coda e l'audit girano sullo stesso stack self-hosted (Postgres, un servizio applicativo), con costi marginali. Lo storage degli audit per dieci anni, a volumi da PMI, è nell'ordine dei **gigabyte**, non di più.
- **Autenticazione**: le passkey sono supportate dai principali sistemi operativi e browser senza costi di licenza; eventuali chiavi hardware per gli approvatori costano poche decine di euro ciascuna.
- **Tempo delle persone**: ogni approvazione costa qualche minuto. È il prezzo del controllo, e va speso sulle azioni che lo meritano: per questo l'MVP limita la coda a PEC e pagamenti rilevanti.
- **Il costo di un errore**: un bonifico sull'IBAN sbagliato o una PEC con gli allegati di un altro cliente costano più di tutto il resto della lista messo insieme.

## Quando NON farlo

- **Se l'agente non esegue azioni irreversibili**, non costruire una coda di approvazione: basta la modalità bozza, con l'umano che esegue nei suoi strumenti.
- **Se il volume è basso** (poche PEC e pochi bonifici al mese), la soluzione più sicura è che l'agente prepari la bozza e l'umano la invii dal client PEC o dall'home banking, che hanno già i loro controlli. La coda ha senso quando il volume rende il processo manuale lento o incoerente.
- **Se non ci sono due persone** che possano approvare, il dual control non esiste: con un solo decisore, meglio la modalità bozza e l'esecuzione manuale consapevole.
- **Se l'approvazione diventa un timbro**, il sistema dà una falsa sicurezza peggiore di nessun sistema. Tieni in coda solo ciò che merita attenzione.
- **Non automatizzare l'esecuzione dei pagamenti** finché validatore, anagrafica e verifica fuori banda degli IBAN non sono solidi: la frode sul cambio IBAN è uno degli attacchi più diffusi contro le PMI, e un agente che paga in automatico è il suo bersaglio ideale.

## Checklist operativa

- [ ] Elenco delle azioni irreversibili, classificate per rischio.
- [ ] Agente senza credenziali di PEC e banca; esecutore unico con le credenziali.
- [ ] Payload canonico con hash, inclusi gli hash degli allegati.
- [ ] Validatore: schema, checksum IBAN, anagrafica, rubrica PEC, riconciliazione con il documento, soglie, orari.
- [ ] Coda con stati espliciti, versioni immutabili, nuova versione = approvazioni decadute.
- [ ] Regola "chi chiede non approva"; secondo approvatore sopra soglia e per IBAN nuovi; deleghe temporanee registrate.
- [ ] Scadenza = nessuna esecuzione; escalation per azioni con termini legali.
- [ ] Notifiche senza link; app con passkey; payload dal server; novità evidenziate; conferma attiva per l'alto rischio.
- [ ] Verifica telefonica fuori banda per ogni IBAN nuovo o modificato.
- [ ] Esecutore che verifica hash, scadenza, freeze; idempotenza verso i gateway.
- [ ] Audit append-only con catena di hash, payload cifrati, evidenze di esecuzione, verifica periodica.
- [ ] Durata di conservazione definita con commercialista e consulente legale.

## Il verdetto

Quando un agente AI prepara una PEC o un bonifico, il "confermi? scrivi OK" in chat non è un controllo: è una formalità che lega il consenso a un riassunto, nello stesso canale in cui l'agente può essere manipolato, dato spesso dalla stessa persona che ha chiesto l'azione, senza identità verificata e senza evidenza. Per le **operazioni irreversibili** — la PEC con valore legale, il bonifico che non torna indietro, il post già visto, il record cancellato — serve un dual control vero.

La sua forma è precisa: l'agente propone un payload strutturato, un validatore deterministico lo controlla contro anagrafiche e documenti, una coda immutabile lo identifica con un hash, due persone diverse lo approvano con un'autenticazione che un phishing non può rubare, un esecutore esegue esattamente quell'hash e nient'altro, e ogni passaggio finisce in un audit append-only che potrai consultare tra dieci anni. Alla scadenza, nulla parte; per le novità pericolose — un IBAN mai visto prima — si prende il telefono.

Non è burocrazia: è il modo in cui un agente può preparare il lavoro più delicato di un ufficio amministrativo senza che un suo errore, o un attacco, diventi un fatto compiuto. L'automazione fa risparmiare tempo sulla preparazione; il controllo resta alle persone, con gli strumenti giusti per esercitarlo davvero.

Se stai portando un agente vicino alla PEC o ai pagamenti e vuoi progettare la barriera prima del primo errore, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Partiamo dall'elenco delle azioni irreversibili: di solito è più lungo di quanto si pensi.

## FAQ

### Perché "scrivi OK in chat" non basta come approvazione?
Perché non lega il consenso al contenuto esatto dell'azione (si conferma un riassunto, non il messaggio o il pagamento che verrà eseguito), avviene nello stesso canale in cui l'agente può essere manipolato, spesso viene dato dalla stessa persona che ha chiesto l'azione, non verifica l'identità e non lascia un'evidenza affidabile. Il dual control richiede legame con il payload, identità distinte e verificate, ed evidenza immutabile.

### Cos'è il dual control e quando serve?
È il principio dei quattro occhi: un'operazione rischiosa richiede che due persone diverse la vedano e la autorizzino, ciascuna responsabile della propria decisione. Serve per le azioni irreversibili o costose: PEC con valore legale, bonifici sopra soglia o verso IBAN nuovi, pubblicazioni pubbliche, cancellazioni. Per le azioni correggibili basta di solito una bozza che un umano esegue.

### Perché serve l'hash del payload?
Perché garantisce che ciò che viene eseguito sia esattamente ciò che è stato approvato. Il payload viene serializzato in forma canonica e se ne calcola l'hash; l'approvazione si riferisce a quell'hash, e l'esecutore lo ricalcola prima di agire. Se cambia anche un carattere della causale o un allegato, l'hash non corrisponde e l'esecuzione si blocca. Ogni modifica crea una nuova versione e annulla le approvazioni precedenti.

### Cosa succede se nessuno approva in tempo?
L'azione non viene eseguita: alla scadenza passa allo stato "scaduta". Il silenzio non vale mai come consenso. Per le azioni con termini legali o contrattuali, però, la scadenza non deve essere silenziosa: servono promemoria, escalation al delegato e un allarme alla responsabile di processo prima del termine, così che l'azione necessaria venga decisa da qualcuno.

### Si può approvare dal telefono in modo sicuro?
Sì, se il sistema è progettato contro il phishing: notifiche senza link d'azione né dati sensibili, approvazione solo dentro l'app o il portale noto, autenticazione con passkey (legate al dominio, quindi inutilizzabili su siti falsi), contenuto mostrato dal server e non dal messaggio, novità come un IBAN nuovo evidenziate, e una conferma attiva (per esempio digitare le ultime cifre dell'IBAN) per le operazioni ad alto rischio.

### Come mi difendo dalla frode del cambio IBAN?
Con tre livelli: un validatore che confronta ogni IBAN con quello in anagrafica e marca ad alto rischio qualsiasi variazione; la doppia approvazione obbligatoria per i bonifici verso IBAN nuovi, indipendentemente dall'importo; e una verifica fuori banda, telefonando al fornitore a un numero già noto e non a quello indicato nella comunicazione che annuncia il cambio. L'ultimo passaggio è umano ed è il più efficace.

### Una PEC inviata si può annullare?
No. La PEC produce ricevute di accettazione e di consegna che attestano l'invio e la consegna di quel messaggio con quegli allegati, con valore legale. Non esiste un richiamo. Per questo le PEC in uscita preparate da un agente dovrebbero passare da un'approvazione, e quelle con valore di contestazione, diffida o recesso da una doppia approvazione, con controllo dei destinatari e degli allegati.

### Cosa devo conservare nell'audit e per quanto?
Per ogni evento: azione, versione, hash del payload, payload completo cifrato, sintesi con dati sensibili mascherati, identità tecnica dell'agente proponente (modello, versione della configurazione, trace), identità e ruolo di chi approva, metodo di autenticazione, dispositivo, orario, decisione e motivazione, evidenze dell'esecuzione (ricevute PEC, riferimenti bancari) e l'hash dell'evento precedente. La durata va definita con commercialista e consulente legale; per i pagamenti, dieci anni è un orizzonte prudente in linea con gli obblighi di conservazione delle scritture contabili.

### Chi può approvare le azioni proposte da un agente?
Persone con il ruolo adeguato per quel tipo di azione, diverse da chi ha chiesto l'azione all'agente, autenticate con metodi forti. Sopra soglia o per le azioni ad alto rischio serve un secondo approvatore distinto. Le deleghe devono essere esplicite, temporanee e registrate. L'amministratore tecnico del sistema non dovrebbe approvare le operazioni: separare chi gestisce lo strumento da chi decide riduce il rischio che una sola persona controlli tutto.

### Da dove parto se oggi l'agente prepara pagamenti e PEC senza controlli?
Togli all'agente le credenziali di PEC e banca e riportalo in modalità bozza: prepara, e un umano invia dagli strumenti abituali. Poi costruisci l'MVP: coda con hash, validatore, doppia approvazione per PEC legali, bonifici sopra soglia e IBAN nuovi, app di approvazione con passkey e audit append-only. Solo quando questo funziona e le persone lo usano davvero, valuta di estendere la coda ad altre azioni.
