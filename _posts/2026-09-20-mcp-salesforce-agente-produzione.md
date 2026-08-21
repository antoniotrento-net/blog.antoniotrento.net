---
lang: it
permalink: /it/blog/mcp-salesforce-agente-produzione/
title: "MCP su Salesforce: perché un chatbot sul CRM non basta e come far eseguire l'agente senza bruciare i governor limits"
date: 2026-09-20 07:30:00 +0200
author: "Antonio Trento"
description: "Un chatbot che 'legge gli opportunity' non conclude niente. Per far eseguire azioni sul CRM serve uno strato di tool MCP progettato con idempotenza, minimo privilegio e rispetto dei governor limits di Salesforce."
keywords: ["mcp salesforce agente produzione", "model context protocol salesforce", "governor limits", "agente crm", "salesforce api jwt"]
image: /assets/images/posts/mcp-salesforce-agente-produzione.jpg
pillar: agenti-esecuzione
related: [/it/blog/prodotto-llm-vs-chatbot/, /it/blog/n8n-self-hosted-openai-privacy/]
---

## Il chatbot che "legge gli opportunity" e non conclude nulla

Hai visto la demo: un chatbot collegato a Salesforce che risponde "hai 14 opportunity aperte per 340.000 €, la più grossa è ferma da 20 giorni". Bello. Poi chiedi "spostala allo stage successivo e crea un task di follow-up" e il chatbot ti risponde... con un bel paragrafo su *come faresti tu* a spostarla. Non l'ha spostata. Non ha creato niente. Ha **letto** e ha **chiacchierato**, ma non ha **eseguito**. È il limite strutturale del chatbot sul CRM: sa leggere, non sa agire — e un CRM dove non concludi niente è un CRM che guardi, non che usi.

Far *eseguire* azioni a un agente su Salesforce in produzione è un problema completamente diverso dal farlo chiacchierare, e non è un problema di "AI per le vendite": è un problema di **integrazione**. Protocollo, quote, permessi, idempotenza, audit. Qui entra **MCP** (Model Context Protocol) come strato d'azione: un modo standard di dare a un agente dei *tool* — funzioni che compie sul CRM — con dei confini precisi su cosa può e non può fare. In questo articolo vediamo come si progetta un agente MCP su Salesforce che esegue davvero, senza combinare disastri: quali tool sono sicuri e quali sono armi, come non bruciare i governor limits, come rendere ogni azione idempotente e reversibile, come dare all'utente di integrazione il minimo privilegio, e cosa non far fare **mai** a un LLM. Con l'esempio JSON di un tool, la tabella dei limiti, e il kill-switch. Perché tra "leggere gli opportunity" e "toccare i dati di produzione" c'è un abisso, ed è tutto ingegneria.

## Cosa è MCP in pratica (tool, resources, auth) senza hype

MCP, tolto l'hype, è un **protocollo per dare a un modello degli strumenti in modo standard**. Invece di infilare la logica di integrazione dentro il prompt o dentro codice sparso, esponi un "server MCP" che dichiara tre cose:

- **Tool**: le azioni che il modello può *chiedere* di eseguire. Ognuno ha un nome, una descrizione, e uno schema preciso degli input (cosa serve per chiamarlo). Esempio: `get_opportunity`, `update_opportunity_stage`, `create_task`. Il modello non esegue direttamente: *chiede* di eseguire un tool con certi parametri, e il tuo server decide se e come farlo.
- **Resources**: i dati che il modello può *leggere* (in sola lettura), esposti in modo controllato.
- **Auth**: come il server si autentica verso il sistema di destinazione (qui, Salesforce) — ed è il punto dove si gioca la sicurezza.

La cosa importante da capire, e che l'hype nasconde, è questa: **il modello non ha accesso diretto a Salesforce. Ha accesso ai tool che tu decidi di esporgli.** MCP è uno strato in mezzo che tu controlli. Se non esponi un tool "cancella opportunity", il modello *non può* cancellare opportunity, per quanto glielo chieda l'utente o per quanto "decida" di volerlo fare. Questo ribalta il problema di sicurezza: non devi fidarti del modello, devi progettare bene lo strato di tool. Il modello propone; **il tuo server MCP dispone**, con le regole che ci metti tu. È la stessa logica del [prodotto affidabile costruito attorno all'LLM invece del chatbot che promette tutto]({{ '/it/blog/prodotto-llm-vs-chatbot/' | relative_url }}): il valore e la sicurezza stanno nel processo attorno al modello, non nel modello.

## La mappa dei tool: sicuri, guardati, e armi

Il cuore della progettazione è **classificare i tool per pericolosità** e trattarli di conseguenza. Non tutti i tool sono uguali: alcuni li puoi lasciare fare all'agente, altri richiedono un guardiano, altri non vanno esposti mai a un LLM.

- **Tool sicuri (sola lettura).** `get_opportunity`, `list_open_opportunities`, `get_account`. Leggono e basta. Il rischio è al più esporre dati a chi non dovrebbe (gestito dai permessi), ma non *rompono* niente. L'agente li può usare liberamente.
- **Tool guardati (scrittura mirata e reversibile).** `create_task`, `add_note`, `update_single_field` con filtri stretti. Modificano, ma in modo circoscritto e reversibile. Vanno esposti con paletti: schema rigido, un solo record alla volta, campi limitati, e — come vedremo — idempotenza.
- **Tool-arma (mai autonomi).** `delete`, `mass_update` senza filtro, `convertLead`, cancellazioni in bulk. Questi non vanno **mai** dati a un LLM in esecuzione autonoma. Un `delete` massivo lanciato da un modello che ha frainteso una richiesta è un disastro irreversibile sui dati di produzione. Se proprio servono, passano da una **coda di approvazione umana** (più avanti), mai direttamente.

La regola di design è: **esponi il minimo indispensabile, e per ogni tool chiediti "cosa succede se il modello lo chiama con i parametri sbagliati?".** Se la risposta è "un danno reversibile e circoscritto", ok. Se è "un disastro irreversibile", quel tool non si espone all'agente — o si trasforma in una *proposta* che un umano approva. Questa mappa dei tool è il documento di sicurezza più importante del progetto, più di qualsiasi configurazione: è dove decidi, esplicitamente, cosa l'agente **non** può toccare.

Ecco come appare la definizione di un tool guardato, in JSON — nota lo schema rigido e i vincoli:

```json
{
  "name": "update_opportunity_stage",
  "description": "Sposta UNA opportunity a uno stage tra quelli ammessi. Non chiude, non cancella, non tocca l'importo.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "opportunity_id": {
        "type": "string",
        "pattern": "^006[A-Za-z0-9]{15}$",
        "description": "ID Salesforce dell'opportunity (prefisso 006)"
      },
      "new_stage": {
        "type": "string",
        "enum": ["Qualification", "Proposal", "Negotiation"],
        "description": "Stage di destinazione: solo avanzamenti intermedi, non Closed"
      },
      "idempotency_key": {
        "type": "string",
        "description": "Chiave univoca per evitare doppie esecuzioni sul retry"
      }
    },
    "required": ["opportunity_id", "new_stage", "idempotency_key"],
    "additionalProperties": false
  }
}
```

Tre difese in questo solo schema: il `pattern` sull'ID (non accetta ID malformati o di altri oggetti), l'`enum` sugli stage (non può portare a "Closed Won" da solo — quello è una decisione umana), e la `idempotency_key` obbligatoria. `additionalProperties: false` impedisce di infilare campi non previsti. Lo schema *è* la sicurezza.

## Governor limits, concurrent API, bulk vs REST: i numeri che ti fermano

Ecco il vincolo che chi viene dal mondo "AI" non conosce e che fa esplodere gli agenti su Salesforce in produzione: i **governor limits**. Salesforce non è un database aperto: ha quote rigide su quante chiamate API puoi fare, quante in parallelo, quanto grandi. Un agente che *cicla* — legge, ragiona, chiama, rilegge, richiama — moltiplica le chiamate, e brucia la quota giornaliera in fretta.

I limiti rilevanti per un agente (ordini di grandezza — **verifica sempre sulla tua org**, dipendono da edizione e licenze):

| Limite | Ordine di grandezza | Impatto sull'agente |
|---|---|---|
| **Chiamate API / 24h** | da migliaia a milioni (per edizione + n. licenze) | Un agente che cicla su molti record le brucia: ogni "pensa e richiama" è una chiamata |
| **Richieste concorrenti long-running (>20s)** | ~25 in parallelo | Query pesanti simultanee si bloccano a vicenda; l'agente va serializzato o ottimizzato |
| **Righe per query SOQL** | limiti per query/transazione | Su grandi set serve paginazione, non "prendi tutto" |
| **Bulk API vs REST API** | Bulk per grandi volumi a lotti; REST per transazioni singole | Import/update massivi → Bulk (asincrono, a batch); azioni puntuali → REST |
| **Rate limit a breve termine** | soglie per finestra temporale | Raffiche di chiamate ravvicinate vengono rifiutate: serve throttling |

Le strategie per non schiantarti contro questi limiti:

- **Batching invece di loop.** Se devi aggiornare 500 record, non fare 500 chiamate REST in un ciclo dell'agente: usa una singola operazione bulk o composite. Un agente ingenuo fa un loop e brucia 500 chiamate; un agente progettato ne fa una.
- **Leggi una volta, ragiona in locale.** Non far rileggere all'agente lo stesso dato dieci volte durante il ragionamento. Carica il contesto necessario una volta, lascialo ragionare, poi esegui.
- **Serializza le operazioni pesanti.** Rispetta il limite di concorrenza: meglio una coda ordinata che venticinque query pesanti che si strozzano.
- **Monitora la quota residua.** Salesforce espone quante chiamate ti restano nelle 24h. L'agente (o lo strato attorno) deve saperlo e **fermarsi** prima di esaurirla, non scoprirlo quando le chiamate iniziano a fallire.

Il punto è che un agente su Salesforce vive dentro un **budget di chiamate finito**, e progettarlo significa spendere quel budget con parsimonia. Chi ignora i governor limits scopre in produzione che l'agente ha esaurito la quota API dell'intera azienda a metà mattina, bloccando *tutte* le integrazioni — non solo la sua.

## Idempotenza: idempotency key, dry-run, preview per l'umano

Gli agenti sbagliano, i retry accadono, le reti cadono a metà operazione. Su un sistema di *lettura* non è grave. Su un sistema che *esegue* azioni sui dati di produzione, è la fonte dei danni più insidiosi: l'azione eseguita **due volte**. Un task creato due volte è fastidio; uno stage avanzato due volte, o un importo modificato due volte, è un errore nei dati. La difesa è l'**idempotenza**: fare in modo che eseguire la stessa azione due volte abbia lo stesso effetto di eseguirla una volta.

Tre meccanismi, tutti necessari:

- **Idempotency key.** Ogni azione di scrittura porta una chiave univoca (l'hai vista nello schema del tool). Il tuo server MCP tiene traccia delle chiavi già eseguite: se arriva una chiamata con una chiave già vista (un retry), non la riesegue, restituisce il risultato precedente. Così un retry non raddoppia l'effetto.
- **Dry-run (modalità prova).** Prima di eseguire davvero, l'agente può chiamare il tool in modalità "dry-run" che restituisce *cosa succederebbe* senza farlo: "sposterei l'opportunity 006... da Proposal a Negotiation". Utile per far ragionare l'agente sulle conseguenze e per i test.
- **Preview per l'umano.** Per le azioni che pesano, il tool non esegue: produce una **preview** che un umano approva prima dell'esecuzione. "L'agente propone di spostare queste 8 opportunity: confermi?". È l'anticamera della coda di approvazione.

L'idempotenza non è un optional da aggiungere "dopo": è parte del design del tool, come la `idempotency_key` obbligatoria nello schema. Un agente che esegue azioni senza idempotenza è una bomba a orologeria: prima o poi un retry o un doppio invio combina il pasticcio, e tu passi ore a capire perché quel record è stato modificato due volte. È lo stesso rigore sui retry che rende pericoloso un [nodo che esce senza controllo in un workflow]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}): ciò che si ripete, se non è idempotente, fa danni.

## JWT e utente di integrazione: minimo privilegio, mai admin

Come si autentica l'agente verso Salesforce? Con il **JWT bearer flow**: una Connected App configurata per l'autenticazione server-to-server tramite un certificato, senza password interattiva e senza token che scadono di continuo. È lo standard per le integrazioni non presidiate.

Ma l'autenticazione è metà del discorso. L'altra metà, più importante, è: **con quali permessi?** Ed è qui che si fanno i danni peggiori, per pigrizia. La tentazione è far girare l'agente come **System Administrator** — "così funziona tutto e non devo pensarci". È l'errore di sicurezza numero uno: un agente admin può fare *qualsiasi cosa* su *qualsiasi* dato, e se sbaglia (o se qualcuno compromette l'integrazione) il danno è totale.

La regola è il **minimo privilegio**:

- **Crea un utente di integrazione dedicato**, non riusare un utente umano né l'admin. Così le sue azioni sono tracciabili e i suoi permessi isolati.
- **Dagli solo i permessi che gli servono**, tramite un permission set stretto: accesso ai *soli* oggetti e campi che i suoi tool toccano (Opportunity, Task, non tutto il CRM), e solo le operazioni necessarie (leggere, creare task, aggiornare certi campi — non cancellare).
- **Niente permessi pericolosi.** Nessun "Modify All Data", nessun accesso a oggetti sensibili non necessari, nessuna capacità di cancellazione massiva.

Così, anche se il modello "impazzisse" o venisse manipolato con un prompt malevolo, **non può fare più di quello che l'utente di integrazione ha il permesso di fare** — e quell'utente ha i permessi ridotti all'osso. La sicurezza non poggia sulla speranza che il modello si comporti bene: poggia sul fatto che, per costruzione, non *può* fare danni fuori dal suo perimetro. Il minimo privilegio sull'utente di integrazione è la seconda linea di difesa dopo la mappa dei tool, e insieme rendono l'agente sicuro anche quando sbaglia.

## Osservabilità: ogni tool call è un audit trail

Un agente che esegue azioni sui dati di produzione senza lasciare traccia è ingestibile e indifendibile. Quando qualcosa va storto — e andrà — devi poter rispondere a: *cosa ha fatto l'agente, quando, su quale record, con quali parametri, e com'era il dato prima?* Se non puoi, non hai un agente in produzione: hai un problema in attesa di manifestarsi.

Ogni **tool call deve essere un evento di audit**, registrato con:

- **Chi**: l'utente di integrazione e, se l'azione nasce da una richiesta umana, chi l'ha chiesta.
- **Cosa**: quale tool, con quali parametri esatti.
- **Quando**: timestamp.
- **Su cosa**: quale record (ID).
- **Prima/dopo**: lo stato del dato prima e dopo, dove ha senso, per poter ricostruire e — se serve — annullare.
- **Correlation ID**: un identificativo che lega tutte le azioni di una stessa "sessione" dell'agente, per seguirne il ragionamento.

Questo audit trail serve a tre cose: **debug** (quando un dato è cambiato, sai chi e perché), **sicurezza** (rilevi comportamenti anomali dell'agente prima che facciano danni sistematici), e **conformità** (dimostri il controllo sulle azioni automatiche sui dati). È anche il posto dove leggi i **fallimenti tipici**: dai log delle tool call vedi se l'agente sta ciclando (troppe chiamate ravvicinate = rischio governor limits), se un tool fallisce ripetutamente (schema sbagliato o permesso mancante), se un retry ha ritentato un'azione (verifica che l'idempotenza abbia retto). Un agente osservabile è un agente governabile; uno opaco è un incidente che aspetta.

## Il kill-switch e la coda di approvazione

Due meccanismi di sicurezza che ogni agente in produzione deve avere, e che spesso mancano finché non succede il disastro.

**Il kill-switch.** Un interruttore che **disabilita all'istante tutti i tool di scrittura**. Se ti accorgi che l'agente sta facendo qualcosa di sbagliato — sta ciclando, sta modificando record che non dovrebbe, un prompt l'ha portato fuori strada — devi poterlo fermare *subito*, senza spegnere l'intero sistema o aspettare un deploy. Concretamente è un flag (in una config, una variabile, una riga di database) che il server MCP controlla prima di ogni azione di scrittura: se è attivo, i tool-arma e i tool guardati rifiutano di eseguire e rispondono "sistema in sola lettura". I tool di lettura continuano a funzionare. È il freno di emergenza: speri di non usarlo mai, ma senza non sali in macchina.

**La coda di approvazione.** Per le azioni che pesano — quelle che hai classificato come guardate-importanti o come armi — l'agente non esegue: **mette in coda una proposta** che un umano approva o rifiuta. In pratica:

1. L'agente decide che andrebbe fatta un'azione (es. avanzare 8 opportunity).
2. Invece di eseguirla, crea una **richiesta di approvazione** con i dettagli (cosa, su quali record, effetto previsto — la preview di prima).
3. Un umano la vede, la controlla, e **approva o rifiuta**.
4. Solo se approvata, il server MCP esegue davvero — con l'idempotency key, l'audit, e tutto il resto.

La coda di approvazione è ciò che tiene l'umano nel loop sulle decisioni che contano, senza rinunciare all'automazione su quelle che non contano. L'agente fa da solo le cose reversibili e a basso rischio (creare un task, aggiungere una nota); propone all'umano quelle a rischio. È il confine che ripeto in tutto il mio lavoro: **la macchina prepara ed esegue il banale, l'umano decide ciò che pesa.** Un agente senza coda di approvazione sulle azioni pesanti è un agente a cui hai delegato decisioni che non dovrebbe prendere da solo.

## Cosa si rompe in produzione (e come lo leggi dai log)

I guasti tipici di un agente MCP su Salesforce non sono misteriosi: sono quasi sempre limiti, permessi o retry. Ecco come li riconosci dall'audit trail e dai log, prima che diventino un problema serio.

- **`REQUEST_LIMIT_EXCEEDED`: quota API esaurita.** Sintomo: da un certo momento *tutte* le chiamate falliscono con questo errore, e non solo per l'agente — per tutte le integrazioni dell'org. Causa: l'agente ha ciclato bruciando la quota giornaliera. Nei log lo vedi come un'impennata di tool call ravvicinate poco prima del blocco. Rimedio: batching, throttling, e il monitoraggio della quota residua con stop preventivo.
- **`INSUFFICIENT_ACCESS` / `FIELD_INTEGRITY_EXCEPTION`: permesso mancante.** Sintomo: un tool fallisce sistematicamente su una certa operazione o campo. Causa: il permission set dell'utente di integrazione non copre quell'oggetto/campo — spesso emerge quando aggiungi un tool nuovo. È un errore *sano*: il minimo privilegio sta funzionando. Rimedio: concedi il permesso specifico che serve, non "Modify All".
- **Azione applicata due volte.** Sintomo: un record risulta modificato due volte (stage avanzato di due passi, due task identici). Causa: un retry senza idempotenza, o un doppio invio. Nell'audit lo vedi come due tool call con parametri identici a distanza di secondi. Rimedio: verifica che l'idempotency key sia obbligatoria e tracciata — se è successo, non lo era davvero.
- **Concorrenza strozzata.** Sintomo: le operazioni pesanti rallentano o vanno in timeout sotto carico. Causa: troppe richieste long-running in parallelo contro il limite di concorrenza. Rimedio: serializza, o sposta i volumi su Bulk API.
- **L'agente "decide male" su un caso ambiguo.** Sintomo: nell'audit vedi una sequenza di tool call che non ha senso rispetto alla richiesta. Causa: il modello ha frainteso. Rimedio: è esattamente perché le azioni pesanti passano dalla coda di approvazione — l'umano intercetta la proposta sbagliata prima che diventi un fatto. Se non c'era la coda, il kill-switch e l'audit ti permettono almeno di fermare e ricostruire.

Sul fronte **costi** (stime dichiarate): il costo dei token dell'LLM è spesso la voce minore. Le due che contano davvero sono la **quota API di Salesforce** — finita, e se la bruci blocchi l'azienda: vale più di qualsiasi token — e, se fai girare il modello in locale per non mandare i dati del CRM fuori, la **GPU** (un modello 8-14B in ~8-24 GB VRAM, come per lo stack sovrano). Il conto onesto di un agente non è "quanto costano i token", ma "quante chiamate API spende e dove gira il modello".

## Il percorso di implementazione, passo per passo

1. **Mappa i tool** che servono davvero, classificandoli (sicuri / guardati / armi). Parti dal minimo: cosa deve *concludere* l'agente?
2. **Progetta gli schemi** dei tool con vincoli rigidi (pattern sugli ID, enum sui valori, `additionalProperties: false`, idempotency key obbligatoria).
3. **Crea l'utente di integrazione** dedicato e il permission set a minimo privilegio (solo gli oggetti/campi/azioni necessari). Mai admin.
4. **Configura il JWT bearer flow** con la Connected App e il certificato.
5. **Implementa il server MCP** che espone i tool, applica l'idempotenza, controlla il kill-switch, e scrive l'audit trail per ogni chiamata.
6. **Aggiungi la coda di approvazione** per i tool guardati-importanti e le armi.
7. **Metti i limiti**: throttling delle chiamate, controllo della quota API residua, serializzazione delle operazioni pesanti.
8. **Testa in sandbox** con la dry-run e con scenari avversi (l'agente che fraintende, il retry, il prompt malevolo) prima di toccare la produzione.
9. **Vai in produzione con il kill-switch pronto** e l'audit sotto osservazione per i primi giorni.

## Una sessione reale, passo per passo

Vediamo i pezzi insieme su una richiesta vera: un commerciale scrive all'agente *"le opportunity ferme da più di due settimane in fase Proposal, mandagli un promemoria e spostale a Negotiation se il cliente ha risposto"*. Come si comporta un agente progettato bene.

1. **Legge** (tool sicuro): `list_open_opportunities` filtrato per stage "Proposal" e ultima attività > 14 giorni. Una sola chiamata, con paginazione se il set è grande — non un loop.
2. **Ragiona in locale** sul contesto caricato: quali hanno risposte del cliente, quali no. Non rilegge dieci volte gli stessi record.
3. **Per le azioni reversibili e a basso rischio** (creare un task di promemoria): usa il tool guardato `create_task`, una per opportunity, ognuna con la sua idempotency key. Le fa da solo, e ogni chiamata finisce nell'audit.
4. **Per l'azione che pesa** (spostare lo stage): *non esegue*. Produce una preview — "sposterei queste 5 opportunity da Proposal a Negotiation" — e la mette nella **coda di approvazione**.
5. **Il commerciale approva** (o toglie due opportunity che sa non pronte). Solo allora il server MCP esegue gli `update_opportunity_stage`, con idempotency key e audit.

Nota l'equilibrio: l'agente ha *concluso* qualcosa (i promemoria partiti, gli stage aggiornati) — a differenza del chatbot che chiacchiera — ma le decisioni che pesano sono passate da un umano, le chiamate API sono state poche e mirate, e ogni azione è tracciata e reversibile. Se a metà il commerciale avesse visto qualcosa di strano, il kill-switch avrebbe fermato le scritture all'istante. Questo è "l'agente che esegue senza fare disastri": non un modello lasciato libero sul CRM, ma un modello dentro un recinto di tool, permessi e approvazioni.

## Quando restare su Flow/Apex e non mettere l'LLM in mezzo

Onestà tecnica, la più importante di questo articolo: **spesso l'LLM non serve affatto.** Salesforce ha già gli strumenti per automatizzare — **Flow** (automazione dichiarativa) e **Apex** (codice) — e per moltissimi compiti sono la risposta giusta, non un agente AI.

Resta su Flow/Apex, e non mettere l'LLM in mezzo, quando:

- **La logica è deterministica.** "Quando un'opportunity supera 50.000 €, crea un task per il manager." Questa è una regola fissa: un Flow la fa in modo affidabile, veloce, gratuito e senza allucinazioni. Metterci un LLM aggiunge costo, latenza e imprevedibilità per zero beneficio.
- **Il volume è alto e ripetitivo.** Elaborazioni massive e regolari si fanno con Apex e batch, che rispettano i governor limits per design. Un agente LLM che cicla su grandi volumi è il modo peggiore e più costoso di farlo.
- **Non serve interpretare linguaggio o ambiguità.** L'LLM ha senso quando c'è da *interpretare* qualcosa di non strutturato — una richiesta in linguaggio naturale, un testo da capire, una decisione con sfumature. Se l'input è strutturato e la regola è chiara, l'LLM è sovraingegneria.

L'LLM (via MCP) ha senso quando c'è **interpretazione + azione**: capire una richiesta ambigua in linguaggio naturale e tradurla in una sequenza di azioni sul CRM, con giudizio su casi non previsti. Fuori da lì, Flow e Apex vincono. Chi mette un agente AI dove bastava un Flow ha aggiunto un motore a reazione a una bicicletta: più costoso, più fragile, e non arriva prima. Saper dire "qui l'LLM non serve" è parte del mestiere di chi integra sul serio.

## Checklist operativa prima della produzione

- [ ] Tool **classificati** (sicuri / guardati / armi); le armi non sono esposte all'agente.
- [ ] Schemi dei tool con **vincoli rigidi** (pattern, enum, `additionalProperties: false`).
- [ ] **Idempotency key** obbligatoria su ogni scrittura; retry non raddoppiano l'effetto.
- [ ] **Utente di integrazione** dedicato con permission set a **minimo privilegio**; mai admin.
- [ ] **JWT bearer flow** configurato; nessuna credenziale in chiaro.
- [ ] **Kill-switch** che disabilita all'istante le scritture.
- [ ] **Coda di approvazione** per le azioni pesanti; l'umano nel loop dove conta.
- [ ] **Audit trail** completo per ogni tool call (chi/cosa/quando/record/prima-dopo).
- [ ] **Governor limits** presidiati: throttling, quota residua monitorata, operazioni pesanti serializzate/bulk.
- [ ] Testato in **sandbox** con scenari avversi prima della produzione.
- [ ] Verificato che i compiti deterministici stiano su **Flow/Apex**, non sull'LLM.

## Il verdetto: l'agente è integrazione, non magia

Un chatbot che legge gli opportunity e non conclude niente è una demo. Un agente MCP su Salesforce in produzione è **ingegneria di integrazione**: tool progettati con schemi rigidi, classificati per pericolosità, con le armi mai in mano al modello; idempotenza su ogni scrittura; un utente di integrazione a minimo privilegio; governor limits presidiati; audit su ogni azione; kill-switch e coda di approvazione per tenere l'umano sulle decisioni che pesano. Il modello propone, il tuo strato MCP dispone — e la sicurezza non poggia sulla speranza che l'LLM si comporti bene, ma sul fatto che, per costruzione, non può fare danni fuori dal suo perimetro. E spesso, la risposta più professionale è "qui basta un Flow": saperlo è ciò che distingue chi integra da chi mette l'AI ovunque per moda.

Questo è un mattone della [guida agli agenti che eseguono davvero]({{ '/it/pillar/agenti-esecuzione/' | relative_url }}), dove l'automazione tocca i sistemi di produzione con giudizio invece che con entusiasmo. Se vuoi vedere com'è fatto un agente sicuro sul *tuo* CRM e sui *tuoi* processi, parti da [chi sono e come lavoro]({{ site.main_site }}/biografia/) o scrivimi due righe in [contatti]({{ site.main_site }}/contatti/).

## FAQ

**1. Perché un chatbot sul CRM non basta?**
Perché sa leggere e chiacchierare, non eseguire. Ti dice cosa faresti tu, ma non sposta l'opportunity, non crea il task, non aggiorna il record. Far *eseguire* azioni è un problema di integrazione (protocollo, permessi, idempotenza, limiti), non di conversazione.

**2. Cos'è MCP, in due parole?**
Un protocollo per dare a un modello degli strumenti (tool) in modo standard, con schemi di input precisi e autenticazione controllata. Il modello non tocca Salesforce direttamente: chiede di eseguire un tool, e il tuo server MCP decide se e come. Tu controlli lo strato in mezzo.

**3. Come impedisco all'agente di cancellare o modificare tutto?**
Con due difese combinate: non esponi i tool-arma (delete, mass update senza filtro, convertLead) all'esecuzione autonoma, e dai all'utente di integrazione il minimo privilegio (permission set stretto, mai admin). Così, anche se il modello sbaglia o viene manipolato, non può fare più di quel poco che il suo utente ha il permesso di fare.

**4. Cosa sono i governor limits e perché mi riguardano?**
Sono le quote rigide di Salesforce su chiamate API giornaliere, richieste concorrenti, dimensione delle query. Un agente che cicla brucia la quota in fretta, bloccando tutte le integrazioni dell'azienda. Si presidiano con batching invece di loop, lettura unica del contesto, serializzazione delle operazioni pesanti e monitoraggio della quota residua.

**5. Cos'è l'idempotenza e perché è obbligatoria?**
È la garanzia che eseguire la stessa azione due volte abbia lo stesso effetto di eseguirla una volta. Serve perché retry e doppi invii accadono: senza idempotenza, un'azione si applica due volte e corrompe i dati. Si ottiene con una idempotency key tracciata dal server, più dry-run e preview per le azioni pesanti.

**6. Devo far girare l'agente come amministratore?**
Assolutamente no: è l'errore di sicurezza numero uno. Crea un utente di integrazione dedicato con un permission set che concede solo gli oggetti, i campi e le operazioni necessari ai suoi tool. Il minimo privilegio è ciò che limita il danno quando (non se) qualcosa va storto.

**7. Cos'è il kill-switch e quando lo uso?**
Un interruttore che disabilita all'istante tutte le scritture dell'agente, lasciando attive le letture. Lo usi quando ti accorgi che l'agente sta sbagliando — cicla, modifica cose che non dovrebbe, un prompt l'ha portato fuori strada. È il freno di emergenza: senza, non dovresti mettere un agente in produzione.

**8. Come tengo un umano nelle decisioni importanti?**
Con una coda di approvazione: per le azioni che pesano, l'agente non esegue ma propone (cosa, su quali record, effetto previsto), e un umano approva o rifiuta prima dell'esecuzione. L'agente fa da solo il reversibile e a basso rischio; propone l'importante. È il confine tra automazione utile e delega pericolosa.

**9. Quando NON dovrei usare un agente LLM su Salesforce?**
Quando la logica è deterministica (una regola fissa → Flow), quando il volume è alto e ripetitivo (→ Apex/batch), o quando non c'è linguaggio naturale né ambiguità da interpretare. L'LLM ha senso solo dove serve interpretare l'ambiguo e tradurlo in azioni. Altrove è costo, latenza e imprevedibilità per zero beneficio.

**10. Quanto costa in pratica?**
Dipende da dove gira il modello (locale o cloud) e dai volumi, ma il costo vero da tenere d'occhio non è solo quello dei token: è la **quota API** di Salesforce, che è finita. Un agente mal progettato che cicla può "costare" più in chiamate API bruciate (bloccando l'azienda) che in token. Progettare per spendere poche chiamate è parte del budget, quanto scegliere il modello.
