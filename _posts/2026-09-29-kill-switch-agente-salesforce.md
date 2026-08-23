---
lang: it
permalink: /it/blog/kill-switch-agente-salesforce/
title: "Kill switch per agenti che scrivono su Salesforce: dry-run, coda di approvazione e perché \"conferma in chat\" non è un controllo"
date: 2026-09-29 07:30:00 +0200
author: "Antonio Trento"
description: "Come progettare un kill switch per agenti che scrivono su Salesforce: dry-run del payload, coda di approvazione con link firmati, soglie, freeze globale e rollback. Perché il 'sì in chat' non è un controllo di sicurezza."
keywords: ["kill switch agente salesforce", "human in the loop crm", "dry-run llm", "approvazione tool call", "agente produzione sicurezza", "coda di approvazione agente"]
image: /assets/images/posts/kill-switch-agente-salesforce.jpg
pillar: agenti-esecuzione
related: [/it/blog/mcp-salesforce-agente-produzione/, /it/blog/prompt-injection-documenti-aziendali/]
---

## Il "sì in chat" non è un controllo, è un teatro

Il pattern che vedo più spesso, e che più spesso esplode: un agente che sta per scrivere su Salesforce chiede in chat *"Confermo l'aggiornamento di 340 opportunità a 'Closed Lost'? (rispondi SÌ)"*, qualcuno digita SÌ, e l'agente esegue. Sembra un controllo umano. Non lo è. È teatro della sicurezza — l'apparenza del controllo senza la sostanza.

Perché non è un controllo? Perché il "SÌ" arriva **sullo stesso canale non fidato** in cui l'agente opera. Un documento con una [prompt injection]({{ '/it/blog/prompt-injection-documenti-aziendali/' | relative_url }}) può produrre da solo la stringa di conferma, o manipolare *cosa* viene mostrato all'umano prima del SÌ. Non c'è un log di audit separato, non c'è separazione dei ruoli, non c'è la garanzia che il payload eseguito sia quello mostrato, non c'è scadenza. È un bottone che sembra rosso ma non è collegato a niente.

Questo pezzo è sul **kill switch per agenti che scrivono su Salesforce**, e il punto di vista è preciso: **control theory applicata ai side effect, non UX del bot.** Non mi interessa quanto è carina la conversazione. Mi interessa che ogni scrittura verso il CRM passi per un controllo *reale* — un controllo che regge anche quando il modello viene ingannato, anche quando qualcuno digita SÌ senza guardare, anche quando devi fermare tutto alle tre di notte.

Costruiamolo pezzo per pezzo: dry-run, coda di approvazione con link firmati, soglie, freeze globale, rollback dove possibile, separazione dei ruoli, e — la parte che quasi tutti dimenticano — come **testare** che il kill switch funzioni davvero. Questo articolo è il seguito operativo di quando ho descritto come mettere {{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}: lì l'architettura generale, qui il meccanismo di controllo in dettaglio.

## Side effect: la chat non è un log di audit

Partiamo dal principio di fondo. Un agente che ragiona, riassume o propone è a basso rischio: se sbaglia, hai un testo sbagliato. Un agente che **scrive** — crea record, aggiorna campi, cambia owner, chiude opportunità — produce **side effect**: cambiamenti di stato persistenti nel mondo reale. E i side effect sono la cosa da controllare, non le parole.

La chat è pessima come punto di controllo per tre ragioni strutturali:

- **Non è un log di audit.** Un log di audit è immutabile, separato, con chi/cosa/quando/perché. Una conversazione è effimera, mescolata al rumore, e nessuno la userà come prova in un post-mortem.
- **È lo stesso canale dell'attaccante.** Se l'agente legge contenuti esterni (email, documenti, record), quel contenuto è nella stessa finestra della "conferma". Un payload può fabbricare la conferma o alterare la preview.
- **Non garantisce cosa viene eseguito.** Tra "l'agente mostra un riassunto" e "l'agente esegue" non c'è nessun vincolo che i due coincidano. Il riassunto dice "aggiorno 3 record", l'esecuzione ne tocca 340. La chat non lo impedisce.

La regola che applico: **il controllo deve stare sul side effect, non sulla conversazione.** Cioè: l'agente non chiama mai direttamente l'API di scrittura di Salesforce. Produce una *proposta di scrittura* — un oggetto dati preciso — che passa per un sistema di controllo deterministico prima di toccare il CRM. Il resto dell'articolo è come è fatto quel sistema.

## Dry-run: l'agente propone, il sistema serializza il PATCH

Il primo mattone è il **dry-run**. L'agente non esegue: produce una descrizione esatta di *cosa* farebbe, che il sistema serializza in un payload strutturato e verificabile. Niente linguaggio naturale, niente "aggiorno le opportunità in ritardo": un PATCH concreto, record per record, campo per campo.

Un payload di dry-run ben fatto contiene: l'oggetto Salesforce, gli ID esatti dei record, i campi da modificare con valore *precedente* e valore *nuovo*, e un conteggio. Il valore precedente è cruciale: serve per la preview all'umano e per il rollback.

```json
{
  "action_id": "act_2026_09_29_a1b2c3",
  "agent": "opp-hygiene-bot",
  "object": "Opportunity",
  "operation": "update",
  "records": [
    {
      "id": "0065g00000ABcDeEAA",
      "changes": {
        "StageName": {"old": "Negotiation", "new": "Closed Lost"},
        "Loss_Reason__c": {"old": null, "new": "No response 90d"}
      }
    }
  ],
  "count": 340,
  "reason": "Opportunità senza attività da 90+ giorni",
  "created_at": "2026-09-29T09:12:04+02:00",
  "expires_at": "2026-09-29T10:12:04+02:00"
}
```

Nota che `records` mostra la struttura ma `count` dice 340: nella preview all'umano mostri i primi N per esteso *e* il totale, così l'aggiornamento di massa non si nasconde dietro un esempio innocuo. È la differenza tra "aggiorno un'opportunità" e "ne aggiorno 340": il dry-run lo rende impossibile da mascherare.

Il **dry-run LLM** ha un secondo vantaggio: puoi eseguirlo davvero "a vuoto" contro una sandbox Salesforce, verificando che il PATCH sia valido (campi esistenti, valori ammessi dalle picklist, permessi) *prima* che un umano lo veda. Un payload che fallirebbe comunque non arriva nemmeno in coda: sprechi meno tempo umano e riduci gli errori.

Il confine è netto: **l'agente produce il payload, non lo esegue.** Tra la proposta e l'esecuzione c'è tutto il sistema di controllo. Questa separazione — cervello che propone, mani che eseguono sotto regole — è la stessa che uso per la sicurezza contro le injection: l'output del modello è non fidato finché un controllo deterministico non lo valida.

## La coda di approvazione: link firmati, non "reply YES"

Il payload di dry-run entra in una **coda di approvazione**. Questa coda è il cuore del sistema, ed è un componente deterministico, persistente, con un log immutabile. Ecco lo schema della coda:

| Campo | Tipo | Descrizione |
|-------|------|-------------|
| `action_id` | string | ID univoco dell'azione proposta |
| `agent` | string | Quale agente l'ha proposta |
| `object` / `operation` | string | Es. Opportunity / update |
| `payload` | json | Il PATCH completo (dry-run) |
| `payload_hash` | string | SHA-256 del payload: garantisce integrità |
| `count` | int | Numero record impattati |
| `risk` | enum | low / medium / high (dal policy engine) |
| `status` | enum | pending / approved / rejected / expired / executed / failed |
| `approver` | string | Chi ha approvato (ruolo + identità) |
| `approved_at` | ts | Quando |
| `expires_at` | ts | Scadenza: dopo, non è più eseguibile |
| `executed_at` | ts | Quando eseguito |
| `result` | json | Esito + eventuali errori |
| `snapshot_ref` | string | Riferimento allo stato precedente (rollback) |

L'approvazione avviene **fuori banda**: non nella chat dell'agente, ma tramite una notifica (Slack, email) che porta a una **UI minima** dove l'approvatore vede il diff esatto e clicca Approva/Rifiuta. Il link è **firmato**, non un "rispondi YES".

Perché il link firmato e non il "reply YES"? Perché:

- **Il "reply YES" è nel canale non fidato** e può essere fabbricato da un'injection. Il link firmato porta a un sistema separato, autenticato, che l'attaccante non controlla.
- **Il link firmato lega l'approvazione al payload esatto** tramite l'hash. Se il payload cambia tra preview ed esecuzione, la firma non torna e l'esecuzione si blocca. Il "reply YES" non lega niente: approvi un'idea, non un payload.
- **Il link firmato ha un'identità e un ruolo.** Sai *chi* ha approvato, in che veste. Il "reply YES" in un canale condiviso non ti dice nulla di legalmente o operativamente utile.

Ecco come firmi il payload, così la coda e l'esecutore possono verificare che nulla sia stato manomesso:

```python
import hmac, hashlib, json, time

SECRET = load_secret("APPROVAL_HMAC_KEY")   # in vault, non in codice

def firma_payload(payload: dict) -> str:
    """Firma canonica del payload: lega approvazione ed esecuzione."""
    canonico = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hmac.new(SECRET, canonico.encode(), hashlib.sha256).hexdigest()

def link_approvazione(action_id: str, payload: dict) -> str:
    sig = firma_payload(payload)
    exp = int(time.time()) + 3600            # scadenza 1h
    return f"https://approvals.interno.local/a/{action_id}?exp={exp}&sig={sig}"

def verifica(action_id: str, payload: dict, exp: int, sig: str) -> bool:
    if time.time() > exp:
        return False                          # scaduto
    atteso = firma_payload(payload)
    return hmac.compare_digest(atteso, sig)    # confronto a tempo costante
```

Questa è **approvazione della tool call** fatta bene: si approva un payload firmato, verificabile, scaduto dopo un'ora, non una frase in una chat. È **human in the loop CRM** reale, non decorativo.

## La UI minima di approvazione: cosa deve vedere l'umano

Il link firmato porta a una pagina. Se quella pagina è fatta male, hai ricostruito il "reply YES" con più passaggi: l'approvatore clicca senza capire. La preview è dove l'approvazione diventa reale o resta finta, e va progettata con la stessa cura del resto.

Cosa deve mostrare, in ordine di importanza:

- **Il conteggio, grande e in cima.** "Stai per modificare **340 opportunità**". Non nascosto, non in fondo. Il numero è la prima difesa contro il mass update accidentale.
- **I campi toccati, con quelli protetti evidenziati.** Se tra i campi c'è `OwnerId` o `Amount`, vanno in rosso: l'approvatore deve sapere che sta autorizzando qualcosa di sensibile, non un aggiornamento di routine.
- **Il diff vecchio → nuovo, su un campione reale.** Non un esempio inventato: le prime 5-10 righe vere del payload, con valore precedente e nuovo affiancati. E un link per vedere l'elenco completo degli ID impattati.
- **La motivazione dell'agente.** Perché propone questo? "Opportunità senza attività da 90+ giorni". Aiuta a giudicare se ha senso.
- **La scadenza, visibile.** "Questa approvazione scade tra 47 minuti". Comunica che è una decisione, non un timbro eterno.
- **Due bottoni distinti e asimmetrici:** Approva e Rifiuta, con Approva che richiede magari un secondo click di conferma sulle azioni ad alto rischio. La frizione va dosata sul rischio, non tolta del tutto.

Cosa **non** deve fare la preview: mostrare solo un riassunto in linguaggio naturale generato dall'agente. Quel riassunto è testo non fidato, e può non corrispondere al payload. La preview mostra il **payload serializzato**, la fonte di verità, non la sua parafrasi. L'umano approva ciò che verrà eseguito, non ciò che l'agente dice che verrà eseguito.

La misura del successo di questa UI è brutale ma onesta: **un approvatore che, guardandola tre secondi, si accorge che "340" è troppo e clicca Rifiuta.** Se la tua preview non permette quel rifiuto a colpo d'occhio, non stai facendo human in the loop, stai facendo decorazione.

## Soglie: importo, numero record, campi protetti

Non tutto merita la stessa frizione. Se ogni singola nota richiede un'approvazione umana, l'approvatore si abitua e timbra tutto — e sei tornato al teatro. Il policy engine calibra il livello di controllo sul **rischio del side effect**, in modo deterministico.

Le dimensioni di rischio che uso per Salesforce:

- **Numero di record.** Un update su 1 record è routine; su 340 è un'operazione di massa che può devastare il forecast. Sopra una soglia (es. 10 record) → approvazione obbligatoria; sopra una seconda soglia (es. 100) → approvazione di un ruolo senior.
- **Campi protetti.** Alcuni campi non si toccano in automatico, mai: `OwnerId` (cambio proprietà = ridistribuzione commissioni), `Amount`, `StageName` verso stati chiusi, IBAN/dati di pagamento, campi che scatenano automazioni a valle. Modifica di un campo protetto → sempre approvazione, a qualsiasi conteggio.
- **Importo economico.** Se l'update tocca `Amount` o campi che muovono soldi/forecast, la soglia in euro alza il livello.
- **Irreversibilità.** Operazioni che scatenano email ai clienti, flussi, sincronizzazioni esterne → sempre approvazione, perché il rollback è impossibile (vedi sotto).

```python
CAMPI_PROTETTI = {"OwnerId", "Amount", "IBAN__c", "StageName"}
SOGLIA_RECORD = 10
SOGLIA_RECORD_SENIOR = 100

def valuta_rischio(payload: dict) -> str:
    campi = {c for r in payload["records"] for c in r["changes"]}
    n = payload["count"]

    if campi & CAMPI_PROTETTI:
        return "high"                    # campo protetto: sempre umano
    if n > SOGLIA_RECORD_SENIOR:
        return "high"                    # massa grande: ruolo senior
    if n > SOGLIA_RECORD:
        return "medium"                  # massa piccola: approvazione
    return "low"                         # routine: auto (loggato)
```

La logica: **la decisione se serve un umano non la prende mai il modello.** La prende il codice, guardando conteggio e campi. Anche se il payload "urla" che è urgente e già approvato, il policy engine legge solo i numeri e i nomi dei campi. Il testo persuasivo dell'agente (o di un'injection) è irrilevante per la decisione di sicurezza.

## Freeze globale: il vero kill switch

Le soglie regolano il flusso normale. Il **freeze globale** è il freno d'emergenza: un interruttore che ferma *tutte* le scritture, subito, senza deploy. È la definizione stessa di kill switch, ed è sorprendentemente spesso assente nei sistemi che vedo.

Requisiti di un freeze che funziona:

- **Immediato e senza deploy.** Una flag in un posto veloce da cambiare (una tabella, una chiave in Redis, un record di config), che l'esecutore controlla **prima di ogni singola scrittura**. Non un redeploy che richiede 10 minuti mentre l'agente continua a scrivere.
- **A grana fine.** Freeze globale (tutto), per agente (solo `opp-hygiene-bot`), per oggetto (solo Opportunity). Così puoi fermare il colpevole senza spegnere tutto.
- **Basato su tempo.** Le scritture in automatico avvengono solo in orario lavorativo, quando qualcuno può accorgersi di un problema. Fuori orario → coda, non esecuzione.
- **Protetto.** Attivare il freeze deve poterlo fare chiunque noti un problema (è un freno, meglio un falso allarme che un disastro). Disattivarlo deve richiedere un ruolo autorizzato — altrimenti l'agente stesso, o un'injection, potrebbe "sbloccarsi".

L'esecutore controlla il freeze come prima cosa, sempre:

```python
def esegui(action) -> dict:
    # 1. FREEZE: prima di TUTTO, a ogni scrittura, senza eccezioni.
    stato = leggi_freeze()               # veloce: redis/tabella
    if stato.attivo(agent=action.agent, obj=action.object):
        log_audit("blocked_by_freeze", action_id=action.action_id)
        return {"status": "blocked", "reason": "freeze attivo"}

    # 2. Orario consentito?
    if not in_orario_operativo():
        return {"status": "deferred", "reason": "fuori orario"}

    # 3. Firma ancora valida? (payload non manomesso)
    if not verifica(action.action_id, action.payload,
                    action.exp, action.sig):
        log_audit("blocked_bad_signature", action_id=action.action_id)
        return {"status": "blocked", "reason": "firma non valida"}

    # 4. Idempotenza: già eseguito? (no doppioni su replay)
    if gia_eseguito(action.action_id):
        return {"status": "skipped", "reason": "già eseguito"}

    # 5. Snapshot per rollback, poi esecuzione.
    snapshot = salva_stato_precedente(action)
    return applica_su_salesforce(action, snapshot_ref=snapshot.ref)
```

Questo `esegui` è deterministico, versionato e testato. È il collo di bottiglia obbligato di ogni scrittura. Se non passa da qui, non tocca Salesforce.

### Runbook del freeze

Un kill switch senza un runbook è un pulsante che nessuno sa usare sotto stress. Il runbook che consegno, scritto e provato:

1. **Sintomo:** aggiornamenti anomali, forecast impazzito, alert dai log (vedi sotto), o segnalazione utente.
2. **Attiva il freeze globale:** `POST /admin/freeze {"scope":"global"}` o dal pannello. Chiunque del team ops può farlo. Effetto immediato.
3. **Verifica:** controlla che i log mostrino `blocked_by_freeze` per le nuove azioni. Se le scritture continuano, il freeze non funziona → escalation.
4. **Diagnostica:** dai log identifica agente, azione, payload responsabili.
5. **Contieni:** se serve rollback, usa gli snapshot (vedi sezione rollback). Valuta cosa è reversibile e cosa no.
6. **Sblocca a grana fine:** riattiva prima gli agenti sani (`scope: agent`), tieni fermo il colpevole finché non è risolto. Lo sblocco richiede ruolo autorizzato.
7. **Post-mortem:** cosa è passato, quale soglia mancava, quale test aggiungere.

## L'architettura di riferimento

Mettiamo insieme i pezzi. Nota il confine: l'agente non ha mai le credenziali di scrittura di Salesforce. Le ha solo l'esecutore.

```
   Agente LLM ──▶ ┌─────────────────────────────────────┐
   (propone)      │ DRY-RUN: serializza il PATCH        │
                  │ (validazione in sandbox)            │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ POLICY ENGINE: rischio da conteggio, │
                  │ campi protetti, importo, orario      │
                  └───────┬───────────────────┬──────────┘
                     low  │              medium/high
                          ▼                   ▼
              ┌──────────────────┐  ┌──────────────────────────┐
              │ (auto, loggato)  │  │ CODA + link firmato       │
              │                  │  │ approvazione fuori banda  │
              └────────┬─────────┘  └───────────┬──────────────┘
                       │                        │ approvato (ruolo)
                       └───────────┬────────────┘
                                   ▼
                  ┌─────────────────────────────────────┐
                  │ ESECUTORE (unico con credenziali):   │
                  │ 1.freeze? 2.orario? 3.firma? 4.idemp.│
                  │ 5.snapshot → 6.scrittura Salesforce  │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ AUDIT LOG immutabile + snapshot      │
                  └─────────────────────────────────────┘
```

**Cosa NON tocca mai l'agente:**

- Le credenziali di scrittura Salesforce (le ha solo l'esecutore).
- La flag di freeze (non può sbloccarsi).
- I campi protetti senza approvazione.
- La propria configurazione (soglie, campi protetti, ruoli).

Questo è il senso di **agente produzione sicurezza**: non un modello "bravo", ma un perimetro deterministico attorno a un modello che si assume fallibile.

## Replay e rollback su Salesforce (non sempre possibile)

Il rollback è dove l'ottimismo incontra la realtà di un CRM. Puoi ripristinare i valori dei campi grazie agli snapshot (`old` nel payload), ma **non tutto è reversibile.**

Cosa puoi annullare:

- **Modifiche di campo dirette:** hai i valori `old`, li riscrivi. Semplice, se nessun'altra automazione è intervenuta nel frattempo.

Cosa **non** puoi annullare facilmente, o affatto:

- **Automazioni a valle scatenate dalla scrittura:** Flow, trigger, Process Builder che al cambio di `StageName` hanno inviato email, creato task, notificato clienti. La riscrittura del campo non "richiama" l'email già partita.
- **Sincronizzazioni esterne:** se un cambio ha propagato a un sistema collegato (ERP, marketing automation), il rollback su Salesforce non tocca l'altro sistema.
- **Record cancellati:** recuperabili dal cestino per un periodo limitato, poi no. Le operazioni di delete meritano sempre la soglia massima.

Da qui due principi:

1. **Idempotenza sempre.** Ogni azione ha un `action_id`; l'esecutore rifiuta di eseguire due volte lo stesso ID. Così un replay (dopo un crash, un retry) non raddoppia i side effect. È l'unico modo per rendere sicuro il retry.
2. **Lo snapshot prima della scrittura, sempre.** Anche se il rollback non sarà sempre possibile, lo stato precedente ti serve per capire cosa è cambiato e per ripristinare ciò che è ripristinabile. Costa poco spazio, vale tantissimo in un incidente.

E il vincolo tecnico di Salesforce da non ignorare: i **governor limit** e la Bulk API. Un update su 340 record non si fa con 340 chiamate singole (esaurisci i limiti e sei lento): si usa la Bulk API in batch. Ma la Bulk API rende il rollback più complesso, perché un batch può fallire parzialmente. L'esecutore deve gestire i risultati per-record e sapere esattamente quali scritture sono andate a buon fine, per uno snapshot coerente. Ne ho parlato tra i vincoli di {{ '/it/pillar/agenti-esecuzione/' | relative_url }}: i limiti della piattaforma non sono un dettaglio, sono parte del design.

## Chi approva: separazione dei ruoli

Un controllo dove chi costruisce l'agente è anche chi approva le sue scritture non è un controllo: è un conflitto di interessi. La **separazione dei ruoli** (separation of duties) è un principio di sicurezza vecchio e valido.

- **Chi configura l'agente** (l'integratore, l'IT) definisce soglie, campi protetti, flussi. Non approva le singole scritture.
- **Chi approva le scritture** è un ruolo di business con l'autorità sul dato: il sales manager approva i cambi sulle opportunità, l'amministrazione approva i cambi sui dati di pagamento.
- **Chi può togliere il freeze** è un ruolo definito, distinto dall'agente e da chi lo ha costruito.

Perché conta: se un'injection compromette l'agente e l'agente potesse anche approvare, non avresti difesa. La separazione garantisce che un umano *diverso*, con un interesse *diverso*, guardi il payload prima che diventi realtà. E in caso di audit, sai chi ha approvato cosa, in che ruolo — informazione che il "reply YES" in un canale condiviso non ti dà mai.

Un dettaglio operativo che quasi tutti scoprono nel modo peggiore: **cosa succede quando l'approvatore è assente?** Il sales manager va in ferie, e la coda si riempie di azioni pending che scadono senza esecuzione. Due errori opposti da evitare. Il primo: nessun sostituto, e il lavoro si blocca finché non torna — le soglie erano tarate su una persona sola. Il secondo, peggiore: un "approvatore di riserva" onnipotente che accetta tutto per sbloccare la coda, vanificando la separazione. La soluzione sana è una **delega esplicita e temporanea**: un sostituto nominato per il periodo di assenza, con lo stesso ruolo e gli stessi limiti, tracciato nel log (chi ha delegato a chi, da quando a quando). La delega è un'informazione di audit, non una scorciatoia. Se non la progetti, la scoprirai come un buco il primo lunedì di agosto.

## Testare il kill switch: chaos, non fiducia

Ecco la parte che separa i sistemi veri dai giocattoli, e che quasi nessuno fa: **testare che il kill switch funzioni.** Un freeze che non hai mai provato è, statisticamente, un freeze rotto. Sotto stress scoprirai che la flag non era letta, o l'esecutore la ignorava in un percorso, o nessuno sapeva come attivarla.

Il test è di tipo chaos: **introduci deliberatamente un agente che si comporta male e verifica che il sistema lo fermi.**

```python
def test_freeze_ferma_le_scritture():
    attiva_freeze(scope="global")
    azione = costruisci_azione_di_test(object="Opportunity", count=5)
    esito = esegui(azione)
    assert esito["status"] == "blocked", "FREEZE NON FUNZIONA"
    assert conta_scritture_salesforce_sandbox() == 0

def test_agente_ribelle_ignora_freeze():
    """Simula un agente che PROVA a scrivere durante il freeze."""
    attiva_freeze(scope="global")
    esito = agente_malevolo_prova_scrittura_diretta()
    # deve fallire: l'agente non ha credenziali, solo l'esecutore.
    assert esito["status"] in ("blocked", "unauthorized")

def test_payload_manomesso_non_esegue():
    azione = azione_approvata_valida()
    azione.payload["count"] = 9999          # manomissione post-firma
    esito = esegui(azione)
    assert esito["status"] == "blocked"     # firma non torna
```

I test da avere, come minimo:

- **Il freeze blocca davvero** ogni tipo di scrittura (update, create, delete, bulk).
- **Un agente non può scrivere direttamente** (non ha credenziali): la separazione regge.
- **Un payload manomesso dopo la firma non esegue** (hash/firma non tornano).
- **Un'azione scaduta non esegue** (expires_at rispettato).
- **Un replay non raddoppia** (idempotenza).
- **Fuori orario le scritture sono differite**, non eseguite.

E soprattutto: **una prova periodica in produzione**, tipo antincendio. Una volta al trimestre, qualcuno attiva il freeze reale, verifica dai log che le scritture si fermano, e lo disattiva. Se non lo provi, non sai di averlo.

## Percorso di implementazione, a step

1. **Togli le credenziali di scrittura all'agente.** Solo l'esecutore le ha. Questo da solo elimina la classe di attacchi "l'agente scrive direttamente".
2. **Implementa il dry-run:** l'agente produce il PATCH strutturato, non esegue.
3. **Costruisci la coda** con lo schema sopra, log immutabile, payload hash.
4. **Aggiungi il policy engine:** soglie per conteggio, campi protetti, importo, orario.
5. **Implementa l'approvazione fuori banda** con link firmati e UI minima del diff.
6. **Metti il freeze globale** letto dall'esecutore prima di ogni scrittura, a grana fine.
7. **Aggiungi snapshot e idempotenza** per rollback e replay sicuro.
8. **Definisci la separazione dei ruoli:** chi configura, chi approva, chi sblocca.
9. **Scrivi il runbook del freeze** e la chaos test suite.
10. **Fai la prova antincendio** in produzione prima di alzare i volumi.

## I fallimenti tipici e come li riconosci dai log

- **Scritture senza `action_id` in coda.** Se vedi modifiche su Salesforce che non hanno un `action_id` corrispondente nella coda, l'agente sta scrivendo fuori dal sistema di controllo. Allarme rosso: qualcuno ha dato le credenziali all'agente.
- **Approvazioni troppo veloci.** Logga il `delta_t` tra notifica e approvazione. Due secondi su un update di 300 record = l'approvatore ha timbrato senza guardare. La sorveglianza è finta.
- **`blocked_bad_signature` in aumento.** Qualcuno (o qualcosa) sta provando a eseguire payload manomessi. Indaga la fonte.
- **Bulk update non previsti.** Un picco nel `count` medio delle azioni. Un agente che di solito tocca 1-2 record e improvvisamente ne propone 300 → o un bug o un'injection. Logga la distribuzione dei conteggi.
- **Azioni eseguite dopo `expires_at`.** Non dovrebbe mai succedere; se accade, l'esecutore ignora la scadenza — bug critico.
- **Freeze attivo ma scritture che continuano.** Il peggiore: il kill switch non funziona. Deve esserci un alert dedicato che confronta "freeze attivo" con "scritture avvenute" e urla se coesistono.

La regola di sempre: **logga la decisione, non solo l'azione.** Non "aggiornati 340 record", ma "aggiornati 340 record, azione act_..., rischio high, approvata da [ruolo] alle 09:15, firma valida, freeze inattivo". Quando qualcosa va storto, questa catena è la differenza tra capire in cinque minuti e non capire mai.

## Costi: ordini di grandezza

Stime dichiarate, per un agente che scrive su Salesforce in una PMI.

- **Sviluppo del sistema di controllo** (dry-run, coda, policy, freeze, approvazione firmata, snapshot, chaos test): come ordine di grandezza **1–2 settimane/uomo** su un'integrazione agente già esistente. È lavoro di ingegneria deterministica, non serve GPU.
- **Costo computazionale ricorrente:** trascurabile. La coda, il policy engine e il freeze sono operazioni CPU da millisecondi. Nessun costo di token aggiuntivo rilevante: il dry-run è lo stesso output che l'agente produrrebbe comunque, solo non eseguito.
- **Governor limit Salesforce:** la Bulk API ha limiti giornalieri; per volumi alti verifica il tuo edition. Non è un costo in euro diretto, ma un vincolo di throughput da progettare.
- **Costo umano dell'approvazione:** il tempo degli approvatori. Va calibrato con le soglie: se approvano troppo, il sistema è mal tarato. Poche approvazioni mirate al giorno, non centinaia.
- **Costo del non farlo:** un mass update sbagliato su centinaia di opportunità può falsare il forecast, richiedere giorni di bonifica manuale, e minare la fiducia nel dato. Un cambio owner errato tocca le commissioni. Il conto di un incidente supera di gran lunga le due settimane di sviluppo.

## Quando NON farlo

- **Se l'agente deve solo leggere e proporre**, non serve tutto questo: senza side effect non c'è nulla da controllare. Il sistema di controllo scatta quando l'agente *scrive*.
- **Se non puoi togliere le credenziali di scrittura all'agente**, fermati: è il primo mattone. Un agente con le credenziali di scrittura dirette non è controllabile, punto.
- **Se non hai qualcuno che approva davvero** (con tempo e autorità), non abilitare le scritture ad alto rischio. Meglio un agente che prepara e un umano che esegue in Salesforce, che un'approvazione finta.
- **Se il caso d'uso richiede scritture massive in tempo reale senza supervisione possibile**, ripensa l'automazione: forse quel processo non è adatto a un agente, o va spezzato in passi più piccoli e reversibili.
- **Se non puoi mantenere e testare il kill switch nel tempo**, sappi che degraderà. Un freeze non testato è un freeze rotto: meglio saperlo prima dell'incidente.

## Checklist operativa prima di andare live

- [ ] L'agente **non ha credenziali di scrittura** Salesforce (solo l'esecutore).
- [ ] **Dry-run** attivo: l'agente propone un PATCH serializzato, non esegue.
- [ ] **Coda di approvazione** con log immutabile, payload + hash.
- [ ] **Approvazione fuori banda** con link firmati e UI del diff — mai "reply YES".
- [ ] **Soglie** per conteggio record, campi protetti, importo, orario.
- [ ] **Freeze globale** letto prima di ogni scrittura, a grana fine, immediato senza deploy.
- [ ] **Snapshot** dello stato precedente prima di ogni scrittura.
- [ ] **Idempotenza** per `action_id`: nessun doppione su replay.
- [ ] **Separazione dei ruoli:** chi configura ≠ chi approva ≠ chi sblocca.
- [ ] **Runbook del freeze** scritto e accessibile.
- [ ] **Chaos test** del kill switch nella suite + prova antincendio periodica in produzione.
- [ ] **Log di decisione** completi e alert su "freeze attivo + scrittura avvenuta".

## Il verdetto

Il **kill switch per agenti che scrivono su Salesforce** non è un bottone che aggiungi alla fine. È un modo di pensare l'intera pipeline: i side effect sono la cosa da controllare, e il controllo deve stare nel codice deterministico attorno al modello, non nella conversazione. Il "sì in chat" fallisce perché è nello stesso canale non fidato, non lega l'approvazione al payload, non lascia audit e non si può fermare. È teatro.

Il controllo vero ha una forma precisa: l'agente propone (dry-run), il sistema serializza il PATCH, il policy engine misura il rischio da conteggio e campi protetti, l'approvazione avviene fuori banda su un payload firmato e scaduto, l'esecutore controlla il freeze prima di ogni scrittura, e ogni azione lascia uno snapshot e un log immutabile. Chi approva è un ruolo diverso da chi costruisce. E il kill switch si testa, come un antincendio, perché uno che non hai mai provato è uno che non hai.

Fatto così, un agente che scrive sul CRM ti fa risparmiare ore e riduce gli errori umani, restando sotto controllo anche quando il modello viene ingannato. Fatto con il "reply YES", è un collega troppo entusiasta con le chiavi del database e nessuno che guardi. La differenza non è quanto è intelligente l'agente. È dove hai messo i freni, e se hai verificato che funzionino.

Se stai per dare a un agente le chiavi di scrittura del tuo CRM e vuoi che i freni ci siano davvero prima del primo mass update, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Control theory sui side effect, non UX del bot.

## FAQ

### Perché il "conferma in chat" non è sufficiente?
Perché la conferma arriva sullo stesso canale non fidato in cui l'agente opera: una prompt injection può fabbricarla o alterare la preview mostrata prima del sì. Inoltre non lega l'approvazione al payload esatto, non lascia un audit separato, non ha scadenza e non identifica il ruolo di chi approva. Sembra un controllo, ma non regge quando serve davvero.

### Cos'è il dry-run in questo contesto?
È la modalità in cui l'agente produce una descrizione esatta e strutturata di cosa farebbe — oggetto, ID record, campi, valori vecchi e nuovi, conteggio — senza eseguirla. Il sistema serializza questo PATCH, lo valida (anche contro una sandbox) e lo mette in coda. Nulla tocca Salesforce finché non c'è un'approvazione valida. Rende impossibile mascherare un update di massa dietro un esempio innocuo.

### Come fa il link firmato a proteggermi?
Il link porta a un sistema di approvazione separato e autenticato, fuori dal canale dell'agente, quindi non fabbricabile da un'injection. La firma HMAC lega l'approvazione al payload esatto: se il payload cambia tra preview ed esecuzione, la firma non torna e l'esecutore blocca. Ha anche una scadenza, così un'approvazione vecchia non resta eseguibile a tempo indefinito.

### Quali campi dovrei proteggere sempre?
Come minimo: OwnerId (cambio proprietà e commissioni), Amount e i campi che muovono il forecast, StageName verso stati chiusi, qualsiasi dato di pagamento (IBAN), e i campi che scatenano automazioni a valle o comunicazioni ai clienti. Modifiche a questi campi dovrebbero richiedere sempre approvazione umana, indipendentemente dal numero di record.

### Il rollback su Salesforce è sempre possibile?
No. Puoi ripristinare i valori dei campi grazie agli snapshot, ma non puoi annullare i side effect scatenati dalla scrittura: email già inviate, Flow e trigger già eseguiti, sincronizzazioni verso sistemi esterni. Per questo le operazioni irreversibili meritano sempre la soglia di approvazione massima, e conviene progettare le azioni per essere il più reversibili possibile.

### Come gestisco gli aggiornamenti di massa senza esaurire i governor limit?
Con la Bulk API in batch, non con chiamate singole per record. Attenzione però: un batch può fallire parzialmente, quindi l'esecutore deve gestire i risultati per-record e sapere esattamente quali scritture sono riuscite, per mantenere uno snapshot coerente e permettere il rollback di ciò che è ripristinabile. I limiti della piattaforma vanno progettati, non scoperti in produzione.

### Chi dovrebbe approvare le azioni dell'agente?
Un ruolo di business con autorità sul dato, diverso da chi ha costruito l'agente. Il sales manager per le opportunità, l'amministrazione per i dati di pagamento. La separazione dei ruoli garantisce che un umano con un interesse diverso guardi il payload, e che un'eventuale compromissione dell'agente non possa anche auto-approvarsi. In audit, sai chi ha approvato cosa e in che veste.

### Come testo che il kill switch funzioni davvero?
Con test di tipo chaos: attivi il freeze e verifichi che le scritture vengano bloccate, simuli un agente che prova a scrivere durante il freeze, provi payload manomessi e azioni scadute. E fai una "prova antincendio" periodica in produzione: qualcuno attiva il freeze reale, controlla dai log che le scritture si fermano, poi lo disattiva. Un kill switch mai provato è statisticamente rotto.

### Questo vale solo per Salesforce?
No, il principio vale per qualsiasi agente che produce side effect: scritture su un ERP, invio di pagamenti, modifiche a un database, chiamate ad API esterne che cambiano stato. Salesforce ha specificità (governor limit, automazioni a valle, Bulk API), ma il pattern — dry-run, coda, soglie, freeze, snapshot, separazione dei ruoli, test del kill switch — è generale. Cambia il target, non la teoria del controllo.

### Da dove parto se ho già un agente che scrive senza controlli?
In quest'ordine: (1) togli subito le credenziali di scrittura all'agente e mettile solo in un esecutore; (2) aggiungi il freeze globale letto prima di ogni scrittura; (3) introduci il dry-run e la coda; (4) definisci soglie e campi protetti; (5) sposta l'approvazione fuori banda con link firmati; (6) aggiungi snapshot, idempotenza e chaos test. I primi due passi si fanno in poco tempo e coprono la maggior parte del rischio immediato.
