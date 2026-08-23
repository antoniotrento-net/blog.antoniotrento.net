---
lang: it
permalink: /it/blog/eu-ai-act-pmi-agenti-2026/
title: "EU AI Act per chi monta agenti in PMI nel 2026: sei ad alto rischio o stai solo automatizzando l'inbox?"
date: 2026-09-27 07:30:00 +0200
author: "Antonio Trento"
description: "Guida operativa all'EU AI Act per PMI che montano agenti nel 2026: albero decisionale alto rischio sì/no, dossier minimo, registro degli usi AI e sorveglianza umana. Niente panico da LinkedIn, solo classificazione pratica."
keywords: ["eu ai act pmi agenti 2026", "ai act classificazione rischio", "obblighi gpt interni", "trasparenza llm", "registro usi ai", "sorveglianza umana ai"]
image: /assets/images/posts/eu-ai-act-pmi-agenti-2026.jpg
pillar: modelli-costi-privacy
related: [/it/blog/gdpr-chatgpt-crm/, /it/blog/mcp-salesforce-agente-produzione/]
---

## Prima di tutto: probabilmente non sei ad alto rischio (ma devi dimostrarlo)

Su LinkedIn l'EU AI Act è raccontato in due modi, entrambi sbagliati. Il primo: "non cambia niente, è roba per le big tech". Il secondo: "multe da 35 milioni, chiudete tutto". La verità operativa per chi monta agenti in una PMI italiana nel 2026 sta in mezzo, ed è molto più noiosa: **quasi sempre il tuo agente non è "alto rischio", ma devi essere in grado di dimostrarlo con un minimo di documentazione, e ci sono un paio di obblighi che scattano comunque anche per l'automazione più banale.**

Questo pezzo è una guida pratica all'**EU AI Act per PMI che montano agenti nel 2026**: come classificare quello che hai costruito, cosa documentare, cosa è davvero "alto rischio" e cosa no, e come tenere un registro degli usi AI che un auditor possa leggere in dieci minuti. Angolo dichiarato: classificazione + dossier minimo, non panico.

**Disclaimer serio, non di facciata:** non sono un avvocato e questo non è un parere legale. È il punto di vista di chi mette in produzione agenti, RAG e integrazioni, e deve renderli difendibili. Per la classificazione formale, i contratti e le decisioni al limite, coinvolgi un legale che conosce il Regolamento (UE) 2024/1689 e un DPO. Quello che ti do qui è la mappa per arrivare da lui con le idee chiare, non con l'ansia.

## Cosa è in vigore nel 2026 per un deployer italiano

Prima cosa da capire: **che ruolo hai.** L'AI Act distingue soprattutto tra chi *produce* un sistema di AI (provider) e chi lo *usa* nella propria attività (deployer, in italiano "utilizzatore"). La stragrande maggioranza delle PMI che montano agenti sono **deployer**: prendi un modello (via API o self-hosted), lo colleghi a n8n, al CRM, all'inbox, e lo usi. Non hai addestrato un foundation model. Questo cambia tutto, perché gli obblighi pesanti sui modelli general-purpose ricadono su chi li produce, non su di te.

Attenzione al confine: **puoi diventare provider senza accorgertene** se metti il tuo marchio su un sistema ad alto rischio, se lo modifichi in modo sostanziale, o se lo destini a una finalità ad alto rischio diversa da quella prevista. Per un uso interno normale (automazione, assistenza, RAG documentale) resti deployer. Ma se rivendi un agente ai tuoi clienti come prodotto, la conversazione cambia: lì diventi provider e gli obblighi si moltiplicano.

La timeline che conta, in ordine di applicazione:

| Data | Cosa si applica | Riguarda te? |
|------|-----------------|--------------|
| 2 feb 2025 | Divieto pratiche vietate + obbligo alfabetizzazione AI (staff) | **Sì**, sempre |
| 2 ago 2025 | Obblighi modelli general-purpose (GPAI) + governance + sanzioni | Il GPAI riguarda i provider dei modelli, non te |
| 2 ago 2026 | Obblighi sistemi ad **alto rischio** (Allegato III) | **Sì, se sei alto rischio** |
| 2 ago 2027 | Alto rischio legato a prodotti (Allegato I) + coda | Di norma no per una PMI software |

Siamo a settembre 2026. Questo significa che, ad oggi: le **pratiche vietate** sono fuorilegge da oltre un anno, l'obbligo di **alfabetizzazione AI** del personale è attivo, e da poche settimane sono in vigore gli **obblighi per i sistemi ad alto rischio**. Quindi la domanda "sono ad alto rischio?" non è più teorica: se lo sei, gli obblighi ti si applicano *adesso*.

Due obblighi valgono per (quasi) tutti, anche se il tuo agente è banale:

1. **Alfabetizzazione AI (Art. 4).** Chi opera i sistemi deve avere competenza sufficiente su cosa fa l'AI, i suoi limiti e i rischi. Per una PMI è realistico: una policy interna, un breve training documentato, e la consapevolezza che il modello può sbagliare. Non serve un master; serve una traccia scritta che le persone sanno cosa stanno usando.
2. **Trasparenza verso chi interagisce con un bot (Art. 50).** Se un cliente chatta con il tuo agente, deve sapere che sta parlando con una macchina. Ne parlo tra poco.

## Il test: alto rischio vs uso interno di produttività

Qui sta il cuore. La maggior parte degli agenti che monto per le PMI sono strumenti di **produttività interna**: leggono documenti, preparano bozze, smistano l'inbox, arricchiscono record nel CRM, propongono risposte. Questi **non sono alto rischio** per l'AI Act. L'alto rischio è definito in modo abbastanza preciso (Allegato III), e riguarda usi che incidono su diritti e opportunità delle persone.

Le categorie dell'Allegato III che una PMI può realmente incrociare:

- **Occupazione e gestione del personale:** sistemi usati per il *reclutamento* (screening di CV, selezione), per *decisioni* su promozioni/licenziamenti, per assegnare compiti o *monitorare e valutare* le persone al lavoro. → **Alto rischio.**
- **Accesso a servizi essenziali:** valutazione del **merito creditizio** / scoring per concedere credito (esclusa la rilevazione frodi). → **Alto rischio.**
- Altre categorie (biometria, infrastrutture critiche, istruzione, giustizia, migrazione, forze dell'ordine): raramente toccano una PMI software.

Il punto che ripeto sempre: **è l'uso a essere ad alto rischio, non la tecnologia.** Lo stesso identico agente LLM che smista email è a basso rischio; se lo punti a "leggi i CV e scarta i candidati", diventa alto rischio. Non cambia il codice, cambia la finalità e chi ne subisce le conseguenze.

### Albero decisionale: alto rischio sì / no

Questo è l'albero che uso per una prima classificazione. Non sostituisce il parere legale, ma ti dice subito se sei in zona tranquilla o se devi chiamare l'avvocato.

```
1. Il sistema è una "pratica vietata"? (manipolazione subliminale,
   social scoring, sfruttamento vulnerabilità, scraping massivo di
   volti, emotion recognition sul lavoro/scuola…)
   ├─ SÌ  → STOP. Non si fa. È vietato, punto.
   └─ NO  → vai a 2

2. L'output del sistema incide su una persona in uno di questi ambiti?
   - reclutamento / selezione / valutazione dipendenti
   - merito creditizio / accesso al credito
   - accesso a servizi essenziali, istruzione, sanità, giustizia
   ├─ SÌ  → probabile ALTO RISCHIO → vai a 3
   └─ NO  → basso rischio / rischio limitato → vai a 4

3. È solo un compito accessorio e ristretto (non decide, non profila,
   non sostituisce la valutazione umana)?
   ├─ SÌ  → possibile esenzione, ma DOCUMENTA il perché → legale
   └─ NO  → ALTO RISCHIO: obblighi pieni del deployer → legale + DPO

4. Il sistema interagisce direttamente con persone (chatbot) o genera
   contenuti sintetici?
   ├─ SÌ  → obblighi di TRASPARENZA (Art. 50) + registro
   └─ NO  → rischio minimo: registro + alfabetizzazione, avanti
```

La regola d'oro dietro l'albero: **se automatizzi processi interni e nessuna persona esterna subisce una decisione automatizzata su lavoro, credito o servizi essenziali, quasi certamente sei fuori dall'alto rischio.** Ma "quasi certamente" va scritto, non pensato. Ecco perché serve il dossier.

## Obblighi di trasparenza se l'utente parla con un bot

Questo scatta anche per l'agente più innocuo, ed è facile da rispettare — ma va fatto. L'Art. 50 impone la **trasparenza LLM** in tre situazioni tipiche per una PMI:

- **Chatbot / agente conversazionale:** la persona deve sapere che sta interagendo con un sistema di AI, a meno che non sia palesemente ovvio. In pratica: una riga chiara all'inizio della conversazione. Non nascosta nei termini di servizio.
- **Contenuti generati o manipolati (immagini, audio, video sintetici):** vanno marcati come artificiali.
- **Testi generati da AI destinati a informare il pubblico** su temi di interesse: vanno dichiarati (con eccezioni per contenuti con revisione umana editoriale).

Per un agente su inbox o WhatsApp business, la trasparenza è una frase, non un progetto:

```python
DISCLAIMER_BOT = (
    "Ciao, sono l'assistente virtuale di [Azienda]. "
    "Rispondo io in automatico; per un operatore umano scrivi "
    "«operatore» o chiama il numero in firma."
)

def apri_conversazione(canale: str) -> str:
    # La trasparenza va data all'inizio, in modo visibile,
    # e loggata (data/ora, versione del testo) per dimostrarla.
    log_evento("disclaimer_mostrato", canale=canale,
               versione="v1", ts=now_iso())
    return DISCLAIMER_BOT
```

Nota il `log_evento`: la trasparenza non basta darla, devi poter **dimostrare** di averla data. Un log con timestamp e versione del disclaimer è la prova che, alla data X, chi scriveva sapeva di parlare con un bot. Sembra pignoleria; è esattamente ciò che un auditor chiede.

Se il tuo agente scrive nel CRM o gestisce dati personali, la trasparenza dell'AI Act si somma agli obblighi GDPR — informativa, base giuridica, minimizzazione. Ho trattato quel lato nel pezzo su {{ '/it/blog/gdpr-chatgpt-crm/' | relative_url }}: i due regolamenti non si sostituiscono, si sommano, e vanno affrontati insieme.

## L'architettura di riferimento di un agente "difendibile"

L'AI Act non ti chiede uno stack tecnico particolare. Ti chiede di poter dire, con carta alla mano, **cosa fa l'agente, cosa decide, cosa NON tocca, e chi sorveglia.** Ecco l'architettura che rende un deployment difendibile — funziona per un agente su inbox come per uno sul CRM.

```
                        ┌───────────────────────────────────┐
   Input (email,    ──▶ │  AGENTE LLM                        │
   documenti, CRM)      │  - legge, classifica, propone      │
                        │  - NON decide su persone           │
                        │  - NON esegue azioni irreversibili │
                        └───────────────┬───────────────────┘
                                        │ PROPOSTA (strutturata + log)
                                        ▼
                        ┌───────────────────────────────────┐
                        │  SORVEGLIANZA UMANA                │
                        │  - vede input, output, motivazione │
                        │  - può correggere / rifiutare      │
                        │  - decide nei casi che incidono    │
                        │    su persone (HR, credito)        │
                        └───────────────┬───────────────────┘
                                        ▼
                        ┌───────────────────────────────────┐
                        │  AZIONE + LOG DECISIONE            │
                        │  chi/cosa/quando/perché, tracciato │
                        └───────────────────────────────────┘
```

I confini che rendono il sistema difendibile, e che scrivi nel dossier:

- **Cosa fa l'agente:** legge, classifica, riassume, propone. Verbi che non decidono destini.
- **Cosa NON tocca mai l'agente:** decisioni su persone (assunzione, licenziamento, concessione credito), azioni irreversibili senza conferma, modifica delle proprie regole. Queste restano a un umano o a codice deterministico.
- **Chi sorveglia:** un ruolo umano nominato, con potere reale di correggere e fermare — non un "supervisore" che clicca "approva" a occhi chiusi.

Questa separazione tra "l'AI propone, l'umano dispone" è la stessa che uso per la sicurezza operativa degli agenti: kill switch, coda di approvazione, log delle decisioni. L'ho descritta in {{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}, e non è un caso: **ciò che rende un agente sicuro è anche ciò che lo rende conforme.** La sorveglianza umana non è un adempimento burocratico appiccicato sopra; è architettura.

## Documentazione tecnica minima che un auditor può capire

Se non sei alto rischio, non ti serve la documentazione tecnica formale dell'Allegato IV. Ma ti serve comunque un **dossier minimo** che dimostri la classificazione e il controllo. Se sei alto rischio, questo dossier è il punto di partenza di quello vero (che curerai con il legale).

L'errore da non fare: documenti tecnici scritti per altri ingegneri. L'auditor non è un ingegnere. Vuole capire in dieci pagine cosa fa il sistema e perché è sotto controllo.

### Indice di un dossier da 10 pagine

1. **Scheda sistema** (1 pag): nome, versione, finalità in due righe, chi è provider e chi deployer, data di messa in servizio.
2. **Classificazione del rischio** (1 pag): l'albero decisionale compilato, l'esito, e *perché*. Se rivendichi un'esenzione, motivala qui.
3. **Architettura e confini** (1–2 pag): il diagramma sopra, cosa fa e cosa NON tocca l'agente, dove sta la sorveglianza umana.
4. **Dati** (1 pag): quali dati entrano, dove sono ospitati (self-hosted / UE), base giuridica GDPR, retention. Nessun dato di training tuo se usi un modello di terzi: dillo esplicitamente.
5. **Sorveglianza umana** (1 pag): ruolo nominato, cosa vede, cosa può fare, in quali casi la decisione è sempre umana.
6. **Trasparenza** (1 pag): dove e come informi gli utenti che è un'AI, con screenshot del disclaimer.
7. **Log e monitoraggio** (1 pag): cosa logghi, per quanto, come rilevi i malfunzionamenti.
8. **Gestione incidenti** (1 pag): cosa fai se l'agente sbaglia, chi avvisi, tempi.
9. **Registro degli usi AI** (1 pag): la tabella (sotto), aggiornata.
10. **Alfabetizzazione** (1 pag): chi è stato formato, quando, su cosa.

Dieci pagine, non trecento. Se il tuo sistema è a basso rischio e non riesci a descriverlo in dieci pagine, il problema non è la documentazione: è che non hai capito cosa hai messo in produzione.

## Qualità dei dati di training vs RAG: non hai un foundation model tuo

Un equivoco che genera panico inutile: gli obblighi dell'AI Act sulla **qualità e governance dei dati di training** riguardano chi *addestra* il modello. Se usi GPT via API, o un Llama/Mistral self-hosted, o Claude, **tu non hai addestrato niente.** Gli obblighi sul training dataset ricadono sul provider del foundation model. Tu sei un deployer che usa un modello pre-addestrato.

Cosa fai tu, invece? **RAG.** Recuperi i tuoi documenti e li dai in contesto al modello. Questo non è "training": è retrieval a runtime. Ma attenzione, un vincolo pratico resta tuo:

- **La qualità del RAG è responsabilità tua.** Se il tuo indice contiene dati errati, obsoleti o discriminatori, le risposte lo saranno. Non è "qualità dei dati di training" ai sensi dell'Allegato IV, ma è comunque parte del tuo dovere di far funzionare il sistema in modo corretto e non lesivo.
- **I dati personali nel RAG** sono soggetti al GDPR: minimizzazione, base giuridica, diritto alla cancellazione (che deve poter rimuovere un documento dall'indice). Ne ho parlato costruendo il {{ '/it/pillar/modelli-costi-privacy/' | relative_url }} lato privacy: il RAG conserva, e ciò che conserva va governato.

La distinzione da mettere nel dossier (punto 4): *"Non addestriamo né mettiamo a punto modelli. Utilizziamo il modello [X] tramite [API/self-hosted]. I nostri dati sono usati solo a runtime via RAG, non per l'addestramento, e non lasciano l'infrastruttura [UE/self-hosted]."* Una frase così chiude metà delle domande di un auditor.

## Sorveglianza umana: non è un checkbox

L'errore più comune, e il più pericoloso in caso di controllo: mettere un umano "nominale" che approva tutto senza guardare. Si chiama *automation bias* — la tendenza a fidarsi ciecamente della macchina — ed è esattamente ciò che l'AI Act vuole evitare. La sorveglianza umana (Art. 14 per l'alto rischio, ma è buona prassi ovunque) deve essere **effettiva**:

- La persona **vede** l'input, l'output e — dove possibile — il perché (le fonti citate dal RAG, la motivazione).
- La persona **può** correggere, rifiutare, fermare. Ha il potere reale, non solo il bottone.
- La persona **ha tempo e competenza** per farlo. Se deve approvare 500 proposte in un'ora, non sta sorvegliando: sta timbrando.
- Nei casi che incidono su persone (HR, credito), la **decisione finale è umana**, non un "override" teorico dell'automatico.

Come lo rendi vero, non finto? Con soglie e frizione mirata:

```python
def instrada(proposta) -> str:
    """
    Sorveglianza umana calibrata sul rischio della decisione,
    non uguale per tutto (o l'umano si abitua e timbra).
    """
    if proposta.incide_su_persona:          # HR, credito, servizi
        return "DECISIONE_UMANA"            # l'umano decide, non approva
    if proposta.irreversibile:              # invio esterno, pagamento
        return "CONFERMA_UMANA"
    if proposta.confidenza < 0.75:          # il modello è incerto
        return "REVISIONE_UMANA"
    return "AUTO_CON_LOG"                   # basso rischio, tracciato
```

Il segreto è **non chiedere sorveglianza per tutto.** Se ogni cosa richiede un clic umano, l'umano smette di guardare. Concentra l'attenzione dove il rischio è reale, e lascia scorrere in automatico (ma loggato) ciò che è banale. Una sorveglianza selettiva e vera batte una sorveglianza totale e finta.

## I fallimenti tipici e come li riconosci dai log

L'AI Act non ti multa perché il modello ha allucinato. Ti mette nei guai se **non puoi dimostrare** cosa è successo e che avevi il controllo. Ecco cosa cerco nei log per capire se un deployment è difendibile o è una bomba a orologeria.

- **Approvazioni umane troppo veloci.** Se il tempo medio tra "proposta mostrata" e "approvata" è di due secondi su decisioni che incidono su persone, la sorveglianza è finta. Logga il `delta_t` di approvazione: è la prova (a favore o contro) che qualcuno guardava davvero.
- **Disclaimer mancante nei log delle conversazioni.** Se apri i log di una chat e non trovi l'evento `disclaimer_mostrato`, hai una violazione di trasparenza documentata. Cerca la sua *assenza*.
- **Decisioni senza motivazione tracciata.** Un'azione che incide su una persona senza un record di input+output+chi ha deciso è indifendibile. In caso di reclamo, non puoi ricostruire nulla.
- **Uso "fuori finalità".** Un agente nato per smistare email che qualcuno inizia a usare per valutare candidati. Nei log lo vedi come un cambio di pattern: nuovi tipi di input, nuovi output. È il momento in cui un sistema a basso rischio diventa alto rischio *senza che nessuno abbia aggiornato il dossier*.
- **Assenza di versioning.** Se cambi prompt o modello e non lo logghi, non puoi dire quale versione era attiva quando è successo qualcosa. Logga sempre `modello`, `versione_prompt`, `ts` a ogni chiamata.

La regola: **il log non serve solo al debug, serve alla difendibilità.** Un sistema che logga input, output, chi ha deciso, quando e con quale versione, è un sistema che in caso di controllo racconta una storia coerente. Un sistema che non logga è colpevole per default, perché non può dimostrare la propria innocenza.

## Sanzioni: ordini di grandezza e cosa succede prima

Qui il panico da LinkedIn nasce dai numeri massimi, citati senza contesto. Mettiamoli in ordine (Art. 99), come stime degli ordini di grandezza:

| Violazione | Tetto | Chi rischia davvero |
|-----------|-------|---------------------|
| Pratiche vietate | fino a 35 M€ o 7% fatturato mondiale | chi fa cose vietate (non tu, si spera) |
| Obblighi alto rischio / trasparenza | fino a 15 M€ o 3% fatturato | deployer alto rischio negligenti |
| Info false/fuorvianti alle autorità | fino a 7,5 M€ o 1% fatturato | chi mente al controllo |

Due cose che il panico omette:

1. **Per le PMI, si applica il tetto più basso** tra l'importo fisso e la percentuale, e le sanzioni devono essere proporzionate. Il "35 milioni" non è la multa per la PMI che ha dimenticato il disclaimer sul chatbot.
2. **Prima della sanzione c'è un percorso.** L'autorità di sorveglianza del mercato non arriva con la multa massima al primo errore. C'è tipicamente: richiesta di informazioni, contestazione, **diffida** con richiesta di misure correttive, tempo per adeguarsi, e solo in caso di violazioni gravi o reiterate la sanzione pecuniaria pesante. Se sei in buona fede, hai un dossier e ti adegui quando richiesto, lo scenario realistico è "sistema tuoi la casa", non "fallimento".

Questo non è un invito a ignorare le regole. È un invito a **non spendere in panico** ciò che devi spendere in preparazione. Un dossier minimo e onesto ti protegge molto più di un consulente che ti vende terrore.

## Template di registro degli usi AI in azienda

Questo è il documento più utile e più trascurato. Il **registro usi AI** è l'inventario di tutti i sistemi di AI che usi, con la loro classificazione. Serve a te (per sapere cosa hai), all'auditor (per verificare), e al legale (per ragionare). Tienilo come file versionato, non in un foglio sparso.

Formato tabellare, per la lettura umana:

| ID | Sistema | Finalità | Ruolo | Classe rischio | Sorveglianza | Dati / hosting |
|----|---------|----------|-------|----------------|--------------|----------------|
| AI-01 | Agente inbox | Smista e bozza risposte email | Deployer | Minimo | Umano su invio esterno | Self-hosted UE |
| AI-02 | RAG documenti | Q&A su manuali interni | Deployer | Minimo | Nessuna decisione | Self-hosted UE |
| AI-03 | Assist. CRM | Arricchisce record, propone note | Deployer | Limitato (no decisione) | Revisione a campione | UE |

E lo stesso in formato macchina, per tenerlo aggiornato via codice/CI e generare la pagina 9 del dossier:

```yaml
# registro-usi-ai.yml — versionato in git, una entry per sistema
- id: AI-01
  sistema: "Agente inbox"
  finalita: "Smistamento e bozza risposte email interne/clienti"
  ruolo: deployer          # deployer | provider
  classe_rischio: minimo   # vietato | alto | limitato | minimo
  incide_su_persone: false
  trasparenza: "disclaimer bot v1 a inizio conversazione"
  sorveglianza: "conferma umana su invio verso esterni"
  modello: "llama-3.x self-hosted"
  training_proprio: false  # usiamo il modello, non lo addestriamo
  dati: "email; nessun dato speciale; hosting UE self-hosted"
  base_giuridica_gdpr: "legittimo interesse / esecuzione contratto"
  data_messa_in_servizio: "2026-03-01"
  responsabile: "IT manager"
  ultimo_riesame: "2026-09-01"
```

Regola pratica: **ogni nuovo agente che va in produzione aggiunge una riga qui, prima del go-live.** Se non è nel registro, non va in produzione. È la disciplina più economica che esista e ti salva quando qualcuno chiede "ma quanti sistemi di AI usate?" e la risposta onesta, senza registro, sarebbe "non lo so con certezza".

## Cosa NON fare: HR scraping selvaggio e affini

L'elenco delle cose che ti mettono nei guai per davvero, non per burocrazia:

- **Screening massivo di candidati con scarto automatico.** Un agente che legge i CV e *decide* chi passa è alto rischio, e se lo fai senza sorveglianza reale, base giuridica e trasparenza verso i candidati, sei nel mirino sia dell'AI Act sia del GDPR. Assistere un recruiter umano è un conto; sostituire la sua decisione è un altro.
- **Scraping selvaggio di dati personali** (profili social, volti) per alimentare il sistema. La raccolta indiscriminata di immagini facciali è tra le pratiche vietate. Non farlo, nemmeno "solo per test".
- **Emotion recognition sul posto di lavoro.** Analizzare le emozioni dei dipendenti (tono voce, espressioni) è tra le pratiche vietate in ambito lavorativo e scolastico. Vietato, non "rischioso".
- **Credit scoring fai-da-te** con un LLM che decide chi merita credito senza le tutele previste. È alto rischio pieno.
- **Usare l'agente "fuori finalità"** senza aggiornare la classificazione. Il sistema nato per l'inbox che inizia a valutare le persone ha cambiato classe di rischio: se non lo ri-classifichi, sei scoperto.
- **Nascondere che è un bot.** Far credere a un cliente di parlare con una persona quando parla con l'AI viola la trasparenza. Costa una frase evitarlo.

## Un caso al limite: l'agente che "aiuta" il recruiter

La teoria è chiara, il confine no. Il punto dove sbaglia quasi tutti è HR, quindi lavoriamolo con un caso concreto. Una PMI vuole un agente che gestisca le candidature. Ci sono tre versioni dello stesso strumento, e cadono in tre classi di rischio diverse — con lo stesso identico modello sotto.

**Versione A — l'assistente.** L'agente legge i CV, ne estrae un riepilogo strutturato (anni di esperienza, competenze, lingue), e li presenta al recruiter in una lista ordinata. Non scarta nessuno, non assegna punteggi decisivi, non nasconde candidati. Il recruiter vede *tutti* i CV e decide lui. → **Rischio limitato/minimo.** L'agente è un cannocchiale, non un giudice. Basta trasparenza interna e registro.

**Versione B — il filtro con override.** L'agente assegna un punteggio e "consiglia" di scartare i sotto-soglia, ma il recruiter può vederli tutti e ribaltare. Zona grigia pericolosa: se in pratica il recruiter guarda solo i "consigliati" e ignora gli scartati, l'override è teorico e la decisione è di fatto della macchina. → **Trattalo come alto rischio** finché non dimostri, con i log, che gli scartati vengono davvero riesaminati. Il `delta_t` di revisione degli scartati è la prova: se è zero, è la macchina che decide.

**Versione C — lo scarto automatico.** L'agente elimina i candidati sotto soglia prima che un umano li veda. → **Alto rischio pieno.** Scattano sorveglianza umana effettiva, trasparenza verso i candidati, base giuridica GDPR, valutazione d'impatto. Qui non si va in produzione senza legale e DPO.

La morale operativa: **il codice è lo stesso, la classe di rischio la decide chi vede cosa e chi decide davvero.** Nel dossier non scrivi "usiamo l'AI per l'HR": scrivi *quale* delle tre versioni hai costruito, e lo dimostri con i log di chi ha guardato e deciso. La differenza tra la Versione A e la Versione C non è tecnica. È dove metti l'essere umano.

## Quando NON farlo (l'automazione di sé stessa)

Onestà, di nuovo contro il mio interesse. Ci sono casi in cui la risposta giusta è "non automatizzare questa cosa con l'AI", o "non ancora":

- **Se l'uso è chiaramente alto rischio e non puoi permetterti sorveglianza umana reale**, non farlo. Un credit scoring o uno screening HR automatizzato senza le tutele è un rischio legale e reputazionale che nessun risparmio di tempo giustifica per una PMI.
- **Se non puoi mantenere il registro e i log nel tempo**, stai costruendo un debito di conformità. Meglio meno agenti, ben documentati, che dieci non tracciati.
- **Se la finalità cambia di continuo** e non riesci a fissare cosa fa il sistema, non è pronto per la produzione: un sistema che non sai descrivere non lo sai nemmeno classificare.
- **Se stai automatizzando una decisione che, sbagliata, fa un danno serio a una persona**, tieni l'umano al centro. L'AI propone, l'umano decide. Sempre, in questi casi.

Automatizzare bene, nel perimetro giusto, è legittimo e conveniente. Automatizzare dove incidi su diritti delle persone senza tutele è il modo più veloce per trasformare un progetto di efficienza in un problema legale.

## Costi: quanto ti costa essere in regola

Ordini di grandezza, dichiarati come stime, per PMI deployer non ad alto rischio.

- **Classificazione + dossier minimo (10 pagine):** lavoro una tantum, come ordine di grandezza **2–5 giornate** tra chi conosce il sistema e una revisione legale mirata. Non è un progetto da mesi se il sistema è a basso rischio.
- **Alfabetizzazione AI del personale:** un training interno breve + policy scritta, **1 giornata** di preparazione + un'ora a persona. Ricorrente in forma leggera (aggiornamenti).
- **Log e registro:** costo di ingegneria marginale se li integri fin dall'inizio; qualche giornata se devi aggiungerli a posteriori. Costo computazionale trascurabile: sono metadati.
- **Revisione legale/DPO:** se sei a basso rischio, una consulenza mirata per validare la classificazione. Se sei alto rischio, un impegno serio e continuativo — ma a quel punto è il costo di fare quel business, non un'opzione.
- **Costo del non farlo:** una diffida che ti obbliga a fermare un sistema in produzione, il tempo di rifare tutto sotto pressione, e nei casi gravi la sanzione. Confrontato con 2–5 giornate di preparazione, non c'è partita.

La sintesi: **per la PMI media, essere in regola con l'AI Act su agenti a basso rischio costa giorni, non mesi.** Il costo esplode solo se sei davvero alto rischio — e in quel caso è il prezzo giusto per un'attività che incide sulla vita delle persone.

## Checklist operativa prima di andare live

- [ ] **Ruolo definito:** sei deployer o provider? (Se rivendi l'agente, sei provider — cambia tutto.)
- [ ] **Albero decisionale compilato** e allegato al dossier, con esito motivato.
- [ ] Se **alto rischio** (HR, credito): fermati e coinvolgi legale + DPO prima del go-live.
- [ ] **Trasparenza attiva:** disclaimer bot visibile e **loggato** (con versione e timestamp).
- [ ] **Sorveglianza umana reale** dove serve: chi, cosa vede, cosa può fare — e non timbra.
- [ ] **Registro usi AI** aggiornato: una riga per ogni sistema, prima della messa in servizio.
- [ ] **Dossier minimo** (10 pagine) pronto e leggibile da un non-ingegnere.
- [ ] **Log di decisione** completi: input, output, chi decide, `delta_t` approvazione, modello, versione prompt.
- [ ] **Nessun addestramento proprio** dichiarato esplicitamente (usi RAG, non training).
- [ ] **Dati in UE / self-hosted**, base giuridica GDPR chiara, retention definita.
- [ ] **Alfabetizzazione AI** del personale fatta e documentata.
- [ ] **Nessuna pratica vietata** (scraping volti, emotion recognition sul lavoro, ecc.).

## Il verdetto

L'**EU AI Act per le PMI che montano agenti nel 2026** non è l'apocalisse che LinkedIn racconta, e non è nemmeno il "non riguarda noi" degli ottimisti. È un regolamento che premia chi sa spiegare cosa ha costruito e dimostrare di averne il controllo. Se automatizzi processi interni — inbox, RAG, assistenza, arricchimento CRM — quasi certamente sei a basso rischio, e la conformità è una questione di disciplina: classifica, documenta in dieci pagine, tieni il registro, logga le decisioni, forma le persone, e sii trasparente quando un utente parla con un bot.

Diventa serio solo quando l'agente incide su **persone** in ambiti sensibili: lavoro, credito, servizi essenziali. Lì la sorveglianza umana non è un checkbox, la decisione finale resta umana, e serve un legale. In tutti gli altri casi, la buona notizia è che **ciò che rende un agente sicuro — confini chiari, umano al posto giusto, log completi — è esattamente ciò che lo rende conforme.** Non stai facendo due lavori. Ne stai facendo uno bene.

Non spendere in panico ciò che devi spendere in preparazione. Un dossier onesto batte un consulente che vende terrore.

Se stai mettendo agenti in produzione in una PMI e vuoi classificarli bene, disegnare i confini giusti e arrivare dal tuo legale con un dossier già pronto invece che con l'ansia, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Architettura e confini, non slide sull'AI Act.

## FAQ

### La mia PMI usa ChatGPT per scrivere email: sono soggetto all'AI Act?
Come deployer sì, ma con obblighi minimi: alfabetizzazione del personale e, se l'AI parla con clienti, trasparenza. Non sei alto rischio se automatizzi produttività interna e nessuna decisione automatizzata incide su lavoro, credito o servizi essenziali di una persona. Documenta la classificazione nel registro e vai avanti.

### Sono "provider" o "deployer"?
Se usi un sistema di AI nella tua attività, sei deployer. Diventi provider se lo sviluppi, ci metti il tuo marchio per rivenderlo, lo modifichi in modo sostanziale o lo destini a una finalità ad alto rischio. La maggior parte delle PMI che montano agenti per uso interno sono deployer. Se rivendi l'agente ai clienti come prodotto, sei provider e gli obblighi crescono.

### Un chatbot sul mio sito è ad alto rischio?
Quasi mai. Un chatbot di assistenza è tipicamente a rischio limitato: l'unico obbligo rilevante è la trasparenza (dire che è un'AI). Diventa alto rischio solo se usato per finalità dell'Allegato III, ad esempio se decide l'accesso a un servizio essenziale. Un bot che risponde a domande o prende appuntamenti non lo è.

### Uso GPT via API: devo preoccuparmi degli obblighi sui dati di training?
No. Quegli obblighi ricadono sul provider del foundation model, non su di te che lo usi. Tu fai RAG, cioè fornisci documenti a runtime: non è addestramento. Dichiaralo nel dossier ("non addestriamo modelli, usiamo il modello X via API/self-hosted"). Resta tua la responsabilità della qualità del RAG e del rispetto del GDPR sui dati che indicizzi.

### Cos'è concretamente la "sorveglianza umana"?
Una persona reale che vede input e output, capisce cosa ha fatto l'agente, e ha il potere di correggere, rifiutare o fermare. Nei casi che incidono su persone, decide lei, non "approva" e basta. Il rischio da evitare è l'automation bias: un umano che timbra tutto in due secondi non è sorveglianza, ed è visibile nei log dal tempo di approvazione.

### Cosa succede se sbaglio la classificazione?
Non arriva la multa massima al primo errore. Il percorso tipico è: richiesta di informazioni, contestazione, diffida con misure correttive e tempo per adeguarsi. Se sei in buona fede, hai un dossier e ti adegui, lo scenario realistico è la correzione, non la sanzione pesante. Ecco perché avere un dossier — anche imperfetto — vale più del panico.

### Devo tenere un registro degli usi AI per legge?
Il registro formale è un obbligo pieno per i sistemi ad alto rischio. Per gli altri è fortemente consigliato come buona prassi e come prova di controllo. In pratica: tienilo comunque. Una tabella versionata con una riga per sistema costa pochissimo e ti salva ogni volta che qualcuno chiede "quanti sistemi di AI usate e come sono classificati?".

### Posso usare l'AI per fare screening dei CV?
Assistere un recruiter umano (riassumere, ordinare) è un conto; far *decidere* all'AI chi scartare è alto rischio pieno, con obblighi di sorveglianza, trasparenza verso i candidati, base giuridica e valutazione d'impatto. Se vuoi automatizzare l'HR, tieni la decisione umana e coinvolgi un legale prima di partire. Lo scarto automatico senza tutele è il classico errore che ti mette nei guai.

### Quanto costa mettersi in regola?
Per una PMI deployer a basso rischio, come ordine di grandezza 2–5 giornate una tantum per classificazione e dossier, più il training di alfabetizzazione e la manutenzione leggera di registro e log. Diventa un impegno serio solo se sei davvero alto rischio. Il costo del non farlo — una diffida che ferma un sistema in produzione — è quasi sempre più alto.

### Da dove parto se ho già cinque agenti in produzione senza nulla di tutto questo?
In quest'ordine: (1) fai l'inventario e compila il registro, una riga per agente; (2) passa ognuno nell'albero decisionale e segna la classe di rischio; (3) per quelli a basso rischio, aggiungi disclaimer e log dove mancano; (4) per eventuali alto rischio, fermati e chiama legale + DPO; (5) scrivi il dossier da dieci pagine per ciascuno; (6) forma il personale. I primi due passi si fanno in un giorno e ti danno la mappa di dove sei davvero esposto.
