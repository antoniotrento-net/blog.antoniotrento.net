---
lang: it
permalink: /it/blog/chatgpt-legale-in-azienda-italia/
alt_url: /en/blog/is-chatgpt-legal-at-work-italy/
title: "ChatGPT in azienda è legale in Italia nel 2026? Guida pratica per titolari (non da talk show)"
date: 2026-11-21 07:30:00 +0200
author: "Antonio Trento"
description: "Usare ChatGPT in azienda in Italia è legale a certe condizioni: dipende dai dati, dal tipo di account, dal contratto e dall'uso. Account personale vs aziendale vs API, DPA e trasferimenti, AI Act, registro dei trattamenti, casi concreti, matrice sì/no e checklist da stampare."
keywords: ["chatgpt legale in azienda italia", "gdpr chatgpt 2026", "ai act pmi italia", "uso openai dipendenti", "dpa chatgpt", "chatgpt registro trattamenti"]
image: /assets/images/posts/chatgpt-legale-in-azienda-italia.jpg
pillar: chatgpt-azienda
related: [/it/blog/chatgpt-dati-aziendali-gdpr/, /it/blog/eu-ai-act-pmi-agenti-2026/]
---

## La domanda sbagliata: "è legale?" vs "per quali dati?"

"Ma alla fine, **ChatGPT in azienda è legale in Italia**, sì o no?" È la domanda che mi fanno più spesso i titolari, di solito dopo aver letto un titolo allarmato o aver sentito un collega dire che "il Garante l'ha vietato". La risposta onesta delude chi cerca un sì o un no: **dipende da quali dati ci metti, con quale tipo di account, con quale contratto e per fare cosa**.

Non è un modo di girarci intorno. È lo stesso discorso che vale per qualsiasi strumento che tratta dati: usare un servizio di posta elettronica in cloud è legale, ma se ci mandi le cartelle cliniche dei pazienti senza le garanzie giuste stai violando la normativa. ChatGPT, Gemini, Claude, Copilot e simili non sono né legali né illegali in astratto: sono strumenti, e il loro uso è lecito o meno a seconda delle condizioni.

Per questo la domanda utile non è "è legale?", ma tre domande più precise:

1. **Che dati entrano?** Testi senza dati personali, dati personali comuni di clienti, dati particolari (salute, sindacato), dati di dipendenti, segreti commerciali.
2. **Con quale canale?** Account personale gratuito, piano aziendale con contratto, API integrata in un software, modello installato in casa.
3. **Per fare cosa?** Scrivere una mail, riassumere un contratto, selezionare dei curriculum, decidere chi ha diritto a uno sconto.

Questa guida è scritta per titolari e responsabili di PMI, non per giuristi. Ti porta da "è legale sì/no" a "**sotto quali condizioni**", con una matrice per tipo di dato, i casi più comuni e una checklist da stampare e portare al commercialista, al consulente privacy o al DPO.

> **Disclaimer.** Questo articolo non è un parere legale. Descrive un'impostazione pratica basata sulla normativa europea e italiana in vigore a novembre 2026, vista da chi progetta questi sistemi nelle aziende. Le regole cambiano (soprattutto sulle scadenze dell'AI Act) e ogni caso ha specificità: per decisioni che espongono l'azienda, fai validare l'impostazione da un consulente privacy o da un avvocato.

## È per te / non è per te

È per te se:

- sei titolare, amministratore o responsabile di una PMI italiana e devi decidere se e come permettere l'uso di ChatGPT o strumenti simili;
- qualcuno in azienda lo usa già e vuoi sapere se state rischiando;
- il tuo commercialista o consulente ti ha chiesto "come lo state gestendo?" e non sai cosa rispondere.

Non è per te se cerchi un'analisi giuridica approfondita dell'AI Act o del GDPR: qui trovi quello che serve per decidere e per fare le domande giuste a chi ti assiste. E non è per te se il tuo problema è pratico più che legale — "i dipendenti lo usano di nascosto, come gli do un'alternativa?" — perché in quel caso il pezzo giusto è quello su [ChatGPT con i dati aziendali e l'alternativa interna]({{ '/it/blog/chatgpt-dati-aziendali-gdpr/' | relative_url }}).

## Account personale vs account aziendale vs API

La prima variabile, quella che cambia di più la risposta, è **il canale** con cui l'azienda usa il modello. Ci sono quattro situazioni tipiche, molto diverse tra loro.

### 1. Account personale del dipendente

Il dipendente usa il suo account gratuito o a pagamento individuale, registrato con la sua email personale. Per l'azienda è la situazione peggiore:

- **non c'è nessun contratto** tra l'azienda e il fornitore: il fornitore non è un responsabile del trattamento dell'azienda;
- le conversazioni possono essere **usate per addestrare i modelli**, a meno che il dipendente non abbia disattivato l'opzione;
- l'azienda **non sa** cosa viene inserito, non può cancellarlo, non può dimostrare niente;
- quando il dipendente se ne va, le conversazioni con i dati aziendali restano nel suo account.

Usare dati personali di clienti o dipendenti in questo canale è, nella grande maggioranza dei casi, **un trattamento senza le garanzie richieste dal GDPR**. Testi senza dati personali e senza informazioni riservate (una mail generica, una spiegazione, un'idea) non creano problemi di privacy, ma restano una questione di riservatezza aziendale.

### 2. Piano aziendale (Team, Business, Enterprise e simili)

L'azienda sottoscrive un piano per aziende. Gli account sono gestiti dall'azienda, l'accesso avviene con l'account di lavoro, e in genere:

- c'è un **contratto per il trattamento dei dati** (DPA) che nomina il fornitore responsabile del trattamento;
- le conversazioni **non vengono usate per l'addestramento** per impostazione predefinita;
- ci sono controlli amministrativi: chi accede, conservazione, esportazione, cancellazione;
- su alcuni piani è possibile scegliere la **residenza dei dati in Europa**.

È il canale che rende l'uso **legittimo per la maggior parte dei dati comuni**, a patto di fare il resto dei compiti (informativa, registro, regole interne).

### 3. API integrata in un software

L'azienda (o un suo fornitore) usa le API del modello all'interno di un'applicazione: un gestionale che riassume le pratiche, un CRM che classifica le email, un flusso di automazione. Le API hanno in genere condizioni da "business" (niente addestramento sui dati inviati, contratto disponibile, conservazione limitata), ma la catena è più lunga: tra te e il modello c'è il fornitore del software, che a sua volta deve essere nominato responsabile e deve dichiarare quali sub-responsabili usa.

La domanda da fare al fornitore del software è semplice: "**quale modello usate, dove, con quale contratto, e cosa succede ai dati che mandiamo?**". Se non sa rispondere, il problema non è il modello.

### 4. Modello installato in casa (o su server UE sotto il tuo controllo)

L'azienda usa un modello open-weight installato sui propri server o su un'infrastruttura europea che controlla. I dati non escono verso un fornitore di AI: il trattamento resta interno (o presso il fornitore dell'infrastruttura, con il suo contratto). È la soluzione con il massimo controllo, che non elimina gli obblighi (informativa, registro, regole d'uso) ma elimina il problema del trasferimento. Il progetto completo è descritto nel pezzo sul [ChatGPT privato self-hosted]({{ '/it/blog/chatgpt-privato-self-hosted-pmi/' | relative_url }}).

| Canale | Contratto con l'azienda | Addestramento sui dati | Controllo dell'azienda | Adatto a dati personali di clienti |
|---|---|---|---|---|
| Account personale | No | Spesso sì, se non disattivato | Nessuno | No |
| Piano aziendale | Sì (DPA) | No, di default | Buono | Sì, con le altre condizioni |
| API in un software | Sì, tramite il fornitore | Di solito no | Dipende dal fornitore | Sì, se la catena è documentata |
| Modello in casa | Non serve verso un fornitore AI | No | Totale | Sì, con le altre condizioni |

## Trasferimento extra-UE e DPA: cosa leggere davvero

Una volta scelto un canale "aziendale", resta da capire **dove vanno i dati** e **cosa promette il contratto**. Non serve leggere quaranta pagine: servono sei punti.

### I sei punti da cercare nel DPA

1. **Ruolo del fornitore.** Deve essere indicato come *responsabile del trattamento* (processor) per i dati che inserisci. Se il contratto lo qualifica come titolare autonomo per i tuoi contenuti, chiedi spiegazioni.
2. **Finalità consentite.** Il fornitore può usare i dati solo per erogare il servizio (e per sicurezza e abusi), **non per addestrare** i modelli senza il tuo consenso esplicito.
3. **Conservazione e cancellazione.** Per quanto tempo restano conversazioni e file, e come si cancellano. Deve essere possibile cancellare, e i tempi devono essere dichiarati.
4. **Sub-responsabili.** L'elenco dei fornitori a cui il servizio si appoggia (cloud, moderazione, assistenza), con il diritto di essere informato delle modifiche.
5. **Luogo del trattamento e trasferimenti.** Dove sono i server; se c'è un trasferimento fuori dall'UE, su quale base (decisione di adeguatezza, clausole contrattuali standard). Se è disponibile la residenza dei dati in Europa, attivala.
6. **Sicurezza e violazioni.** Misure di sicurezza dichiarate e impegno a notificarti le violazioni senza ritardo, così che tu possa rispettare i tuoi obblighi (notifica al Garante entro 72 ore, quando dovuta).

### Il trasferimento verso gli Stati Uniti, in breve

Molti fornitori sono americani. Il GDPR consente i trasferimenti verso paesi extra-UE solo con garanzie adeguate. Per gli Stati Uniti esiste oggi un quadro di adeguatezza (per le aziende americane che vi aderiscono), e in alternativa si usano le clausole contrattuali standard. È un terreno che è già cambiato più volte negli ultimi dieci anni: un'impostazione prudente è **preferire la residenza dei dati in UE** quando disponibile, o fornitori europei, soprattutto per dati delicati. Non è un divieto: è riduzione del rischio.

## AI Act: uso interno vs sistemi che decidono sulle persone

L'AI Act europeo viene spesso evocato come se vietasse ChatGPT in azienda. Non è così. Il regolamento classifica gli usi dell'intelligenza artificiale per livello di rischio, e la maggior parte degli usi da ufficio di una PMI rientra nella fascia più bassa.

### Cosa riguarda le PMI che "usano" ChatGPT

Per l'AI Act, l'azienda che usa un sistema di AI nella propria attività è un **deployer** (utilizzatore), non un fornitore. Gli obblighi dipendono da **cosa fai** con il sistema:

- **Uso generale da ufficio** (scrivere, riassumere, tradurre, preparare bozze): rischio minimo. L'obbligo principale è l'**alfabetizzazione**: dal 2025 le aziende devono garantire che chi usa questi sistemi abbia una formazione sufficiente a usarli in modo consapevole. Mezza giornata di formazione documentata va già nella direzione giusta.
- **Contenuti generati mostrati al pubblico** (chatbot sul sito, testi o immagini sintetici): obblighi di **trasparenza**. Chi parla con un chatbot deve sapere che è un sistema automatico; certi contenuti generati vanno dichiarati.
- **Decisioni sulle persone** — selezione del personale, valutazione dei dipendenti, assegnazione dei compiti, promozioni, licenziamenti, accesso al credito, servizi essenziali: qui si entra nei sistemi **ad alto rischio**, con obblighi pesanti per chi li usa (supervisione umana, informazione ai lavoratori, conservazione dei log, valutazioni). Le scadenze di applicazione di questi obblighi sono state oggetto di proposte di rinvio a livello europeo: verifica la data in vigore con chi ti assiste, ma non usare il rinvio come scusa per partire senza regole.
- **Pratiche vietate**: alcune applicazioni sono proibite, tra cui il riconoscimento delle emozioni sul luogo di lavoro (con eccezioni mediche o di sicurezza). Se un fornitore ti propone di "analizzare il tono delle chiamate per valutare l'umore dei dipendenti", fermati.

Ne ho parlato con più dettaglio nel pezzo sull'[AI Act per le PMI che usano agenti]({{ '/it/blog/eu-ai-act-pmi-agenti-2026/' | relative_url }}). Il messaggio per il titolare è semplice: **finché usi l'AI per scrivere e riassumere, l'AI Act ti chiede soprattutto formazione e trasparenza; quando la usi per decidere sulle persone, cambia tutto**.

### La legge italiana sull'intelligenza artificiale

Dal 2025 l'Italia ha anche una legge nazionale sull'intelligenza artificiale, che si affianca all'AI Act. Per le PMI i due punti più rilevanti sono:

- l'obbligo per il datore di lavoro di **informare i lavoratori** quando utilizza sistemi di AI che li riguardano;
- per i professionisti (commercialisti, avvocati, consulenti, tecnici), l'indicazione che l'AI può essere solo **strumento di supporto** all'attività intellettuale, e il dovere di **informare il cliente** del suo utilizzo.

Se sei uno studio professionale, il secondo punto ti riguarda direttamente: una riga nella lettera d'incarico o nell'informativa al cliente è il minimo.

## Registro dei trattamenti e informativa dipendenti

L'uso di uno strumento di AI con dati personali è un trattamento, e va documentato come gli altri. Due documenti contano.

### Il registro dei trattamenti

Quasi tutte le aziende devono tenerlo (l'esenzione per chi ha meno di 250 dipendenti vale solo per trattamenti occasionali e senza dati particolari, cosa rara nella pratica). Per lo strumento di AI, la riga del registro deve dire:

```text
Trattamento:        Supporto alla redazione e sintesi di documenti tramite assistente AI
Finalità:           Redazione di comunicazioni, sintesi di documenti, traduzioni
Categorie di interessati: clienti, fornitori, dipendenti (nei documenti trattati)
Categorie di dati:  dati anagrafici e di contatto, dati contrattuali e commerciali
                    ESCLUSI: dati particolari (art. 9), dati giudiziari, credenziali
Strumento:          [nome servizio], piano [aziendale], account gestiti dall'azienda
Responsabile:       [fornitore], nominato con DPA del [data]
Luogo del trattamento: [UE / extra-UE con base giuridica: ...]
Conservazione:      conversazioni [90] giorni, poi cancellazione
Misure:             accesso con account aziendale e 2FA, regole d'uso firmate,
                    formazione documentata, addestramento sui dati disattivato
```

Riga per riga: la finalità dice a cosa serve (e quindi cosa non è ammesso); le categorie di dati dicono cosa si può inserire e cosa no; il responsabile e il luogo dicono chi tratta i dati e dove; conservazione e misure dicono come li proteggi. Se uno di questi campi non lo sai compilare, hai trovato il punto da sistemare.

### L'informativa ai dipendenti

I dipendenti devono sapere:

- quale strumento è autorizzato e per cosa;
- quali dati possono e non possono inserire;
- cosa registra l'azienda del loro utilizzo (e cosa no);
- che l'uso dello strumento **non viene utilizzato per valutare** la loro prestazione (se è così; e deve esserlo, salvo percorsi specifici concordati);
- a chi rivolgersi per dubbi o per segnalare un errore.

Attenzione ai controlli: in Italia lo Statuto dei lavoratori limita i controlli a distanza. Leggere sistematicamente le conversazioni dei dipendenti con lo strumento aziendale è un terreno scivoloso. L'impostazione prudente è registrare solo dati tecnici aggregati, e farla validare dal consulente del lavoro.

## Casi: marketing copy vs anagrafiche vs CV vs codice

La teoria diventa chiara solo con i casi. Ecco i più comuni nelle PMI, con la risposta pratica.

### Caso 1 — Testi di marketing

"Scrivimi tre versioni del post per il lancio del nuovo prodotto." Nessun dato personale, nessuna informazione riservata (se il lancio è già pubblico). **Sì, anche con un account qualsiasi**, ma conviene comunque usare quello aziendale per abitudine. Due attenzioni: se pubblichi immagini o testi generati che potrebbero ingannare (testimonianze finte, persone inesistenti), entri negli obblighi di trasparenza e nel diritto dei consumatori; e verifica i dati di fatto che il testo afferma.

### Caso 2 — Anagrafiche e documenti di clienti

"Riassumi questo contratto con il cliente Rossi" o "scrivi una risposta a questo reclamo". Contiene dati personali di clienti e informazioni contrattuali. **Sì, con il piano aziendale o una soluzione interna**, contratto in regola, riga nel registro, regole d'uso. **No con l'account personale.** E mai export di anagrafiche in blocco ("ecco i 2.000 clienti, dividili per settore"): per quel lavoro esistono strumenti più adatti, e il rischio di un errore cresce con il volume.

### Caso 3 — Curriculum e selezione del personale

"Leggi questi 80 CV e dimmi i 10 migliori." È il caso in cui la risposta pratica è **no, a meno di un progetto strutturato**. Motivi: dati personali anche particolari (salute, appartenenze) che spesso compaiono nei CV; decisione che incide sulle persone (GDPR sulle decisioni automatizzate); uso classificato **ad alto rischio** dall'AI Act; rischio concreto di discriminazioni nascoste nel modello. Usare l'AI per scrivere l'annuncio di lavoro va benissimo; usarla per scartare candidati senza un impianto di supervisione, documentazione e informazione no.

### Caso 4 — Codice sorgente

"Trova il bug in questa funzione." Il codice può contenere segreti commerciali, credenziali dimenticate, dati di test reali. **Sì con il piano aziendale o una soluzione interna**, dopo aver tolto credenziali e dati reali; **no con l'account personale** se il codice è proprietario o del cliente (molti contratti di sviluppo vietano di condividere il codice con terzi). Se sviluppi per conto di clienti, controlla le clausole di riservatezza prima di tutto.

### Caso 5 — Dati dei dipendenti

"Scrivi la lettera di contestazione disciplinare per Mario" o "riassumi le valutazioni annuali". Dati del rapporto di lavoro, spesso delicati. **Solo con soluzioni aziendali o interne**, con molta cautela, e mai per decidere (la decisione resta della persona responsabile, motivata e documentata).

### Caso 6 — Dati sanitari o di minori

Studi medici, centri di assistenza, scuole, palestre con dati sanitari. **No con strumenti generici**, anche aziendali, senza una valutazione d'impatto e un progetto dedicato. È il territorio dove serve il consulente privacy dall'inizio, e dove spesso la soluzione interna è l'unica ragionevole.

### Matrice sì/no per tipo di dato

| Tipo di dato | Account personale | Piano aziendale con DPA | API in software documentato | Modello in casa |
|---|---|---|---|---|
| Testi senza dati personali né riservati | Sì | Sì | Sì | Sì |
| Testi pubblici / marketing | Sì | Sì | Sì | Sì |
| Dati personali comuni di clienti/fornitori | **No** | Sì, con regole | Sì, con regole | Sì, con regole |
| Segreti commerciali (listini riservati, offerte, strategie) | **No** | Sì, con cautela | Sì, con cautela | Sì |
| Codice proprietario o del cliente | **No** | Dipende dai contratti | Dipende dai contratti | Sì, con cautela |
| Dati dei dipendenti | **No** | Con molta cautela | Con molta cautela | Con cautela |
| Curriculum per selezione | **No** | Solo con progetto strutturato | Solo con progetto strutturato | Solo con progetto strutturato |
| Dati sanitari, giudiziari, di minori | **No** | Solo dopo valutazione d'impatto | Solo dopo valutazione d'impatto | Solo dopo valutazione d'impatto |
| Credenziali, password, chiavi | **No** | **No** | **No** | **No** |
| Decisioni automatiche sulle persone | **No** | **No** senza impianto alto rischio | **No** senza impianto alto rischio | **No** senza impianto alto rischio |

"Con regole" significa: riga nel registro, informativa, regole d'uso scritte, formazione, minimizzazione (inserire solo i dati che servono al compito).

## Checklist da stampare per il commercialista/DPO

Questa è la checklist da portare all'incontro con chi ti assiste sulla privacy. Spunta quello che hai, e il resto diventa la lista dei compiti.

```text
CHATGPT E STRUMENTI DI AI IN AZIENDA — CHECKLIST          Data: ______  Compilata da: ______

STRUMENTO E CONTRATTO
[ ] Abbiamo scelto uno strumento autorizzato (nome: ________________)
[ ] Usiamo un piano aziendale / API / soluzione interna, NON account personali
[ ] Abbiamo il DPA firmato o accettato, con il fornitore come responsabile del trattamento
[ ] L'addestramento sui nostri dati è disattivato (verificato nelle impostazioni)
[ ] Sappiamo dove sono trattati i dati (UE / extra-UE: base giuridica ________)
[ ] Abbiamo l'elenco dei sub-responsabili

DOCUMENTAZIONE
[ ] Riga aggiunta al registro dei trattamenti
[ ] Informativa ai dipendenti aggiornata (strumento, dati ammessi, cosa registriamo)
[ ] Regole d'uso scritte (max 1 pagina), presentate e firmate
[ ] Se siamo uno studio professionale: informativa ai clienti sull'uso dell'AI

PERSONE
[ ] Formazione fatta e documentata (data, partecipanti, contenuti)
[ ] Un referente interno per dubbi e segnalazioni
[ ] Procedura per segnalare un inserimento errato di dati (entro 24 ore)

USI DA ESCLUDERE O VALUTARE A PARTE
[ ] Selezione del personale / valutazione dipendenti: esclusa o progetto dedicato
[ ] Dati sanitari, giudiziari, di minori: esclusi o valutazione d'impatto
[ ] Chatbot verso clienti: trasparenza ("stai parlando con un sistema automatico")
[ ] Nessuna analisi di emozioni o stati d'animo dei dipendenti

CONTROLLI
[ ] Solo dati tecnici aggregati di utilizzo; nessuna lettura sistematica delle conversazioni
[ ] Revisione delle regole fissata tra 6 mesi (data: ______)
```

Stampala, compilala con onestà, e portala. Un consulente serio apprezzerà più una checklist con metà caselle vuote ma vera che una dichiarazione generica "è tutto a posto".

## Alternative se la risposta è no

Ci sono casi in cui, fatte le verifiche, la risposta per un certo uso è no: il fornitore non offre un contratto adeguato, i dati sono troppo delicati, il trasferimento extra-UE non è accettabile per i tuoi clienti, o l'uso tocca decisioni sulle persone. Le alternative concrete:

1. **Cambiare canale, non rinunciare.** Passare dall'account personale al piano aziendale risolve la maggior parte dei casi comuni.
2. **Fornitore europeo.** Esistono fornitori di modelli e chat con trattamento in UE e contratti pensati per il GDPR, con qualità adeguata ai compiti d'ufficio.
3. **Soluzione interna.** Un modello open-weight su un server aziendale o in un datacenter europeo che controlli. Investimento iniziale, ma dati che non escono.
4. **Anonimizzare prima.** Per alcuni usi (rivedere lo stile di un documento, strutturare un testo), si può togliere ogni dato identificativo prima di inserirlo. Funziona solo se fatto bene, e non per documenti in cui l'identità è parte del contenuto.
5. **Restringere l'uso.** Consentire lo strumento solo per le attività verdi (testi generici, marketing, spiegazioni) e vietarlo per il resto, finché non c'è una soluzione adeguata.
6. **Non usarlo per quel compito.** Per la selezione del personale o le decisioni sulle persone, spesso la risposta giusta oggi è semplicemente: l'AI aiuta a scrivere, non a decidere.

## Percorso 30/60/90 giorni

**Primi 30 giorni — mettere in regola l'esistente**

- capire chi usa cosa (un questionario anonimo è il modo più rapido);
- scegliere lo strumento autorizzato e il canale (piano aziendale, fornitore UE o soluzione interna);
- leggere il DPA sui sei punti, attivare residenza UE e disattivare l'addestramento;
- aggiornare registro e informativa, scrivere le regole d'uso.

**Da 30 a 60 giorni — persone**

- formazione documentata per ogni ufficio, con casi concreti;
- regole d'uso presentate e firmate;
- blocco degli strumenti non autorizzati solo dopo che l'alternativa è disponibile.

**Da 60 a 90 giorni — usi delicati**

- valutare a parte gli usi che toccano dati particolari o decisioni sulle persone;
- se sei uno studio professionale, aggiornare lettere d'incarico e informative ai clienti;
- prima revisione: cosa funziona, cosa manca, cosa va vietato o permesso.

## Costi: stime

Stime indicative per una PMI di 15–30 persone.

| Voce | Stima | Note |
|---|---|---|
| Piano aziendale di un fornitore | 20–30 € per utente al mese | Spesso basta abilitare chi scrive di più |
| Consulenza privacy (DPA, registro, informativa, regole) | 500–2.000 € una tantum | Meno se hai già un consulente di riferimento |
| Formazione documentata | mezza giornata per ufficio | Interna o esterna |
| Valutazione d'impatto per usi delicati | 1.000–4.000 € | Solo se tratti dati particolari o decidi sulle persone |
| Soluzione interna (alternativa al piano) | 4.000–10.000 € + manutenzione | Per aziende con dati sensibili e almeno 20 persone |

Dall'altra parte: una violazione dei dati da gestire costa migliaia di euro anche senza sanzione, e un cliente perso per una violazione di riservatezza può costare molto di più.

## 3 errori da principiante che costano soldi o dati

**1. Pensare che il piano aziendale "risolva tutto".** Il contratto è necessario, non sufficiente. Senza riga nel registro, informativa, regole d'uso e formazione, sei solo un po' meno esposto. E senza regole, il piano aziendale finisce per ricevere anche ciò che non dovrebbe (credenziali, CV, dati sanitari).

**2. Usare l'AI per selezionare i curriculum "solo come primo filtro".** È esattamente l'uso che l'AI Act considera ad alto rischio e che il GDPR guarda con più attenzione. "Solo un primo filtro" significa che qualcuno è stato scartato da un sistema automatico senza che una persona abbia letto il suo CV. Se succede, e il candidato chiede spiegazioni, non hai risposte.

**3. Controllare i dipendenti attraverso lo strumento.** Leggere le conversazioni "per capire come lavorano" o usare le statistiche d'uso per valutare la produttività espone a problemi con lo Statuto dei lavoratori e brucia la fiducia. I controlli si fanno sulle regole e sui dati aggregati.

## Quando NON farlo (o non ancora)

- **Quando il tuo lavoro è trattare dati sanitari, di minori o giudiziari** e non hai ancora un consulente privacy coinvolto: parti da lì, non dallo strumento.
- **Quando vuoi usarlo per decidere sulle persone** (selezione, valutazioni, sanzioni) senza un progetto strutturato: oggi la risposta prudente è no.
- **Quando i contratti con i tuoi clienti vietano la condivisione con terzi** dei loro documenti o del codice: prima rinegozia o scegli una soluzione interna.
- **Quando nessuno in azienda si prende la responsabilità** di regole, formazione e revisioni: lo strumento senza un referente diventa terra di nessuno.

## Checklist pratica

- [ ] Ho smesso di chiedermi "è legale?" e ho elencato quali dati e per quali usi.
- [ ] Nessun dato personale o riservato passa da account personali.
- [ ] C'è un canale aziendale con DPA, addestramento disattivato e, se possibile, dati in UE.
- [ ] Il registro dei trattamenti contiene la riga per lo strumento di AI.
- [ ] L'informativa ai dipendenti è aggiornata; le regole d'uso sono firmate.
- [ ] La formazione è fatta e documentata.
- [ ] Selezione del personale e dati particolari sono esclusi o gestiti con un progetto dedicato.
- [ ] I chatbot verso il pubblico dichiarano di essere automatici.
- [ ] Se sono uno studio professionale, i clienti sono informati dell'uso dell'AI.
- [ ] La checklist è stata condivisa con il consulente privacy o il DPO.

## Il verdetto

**ChatGPT in azienda è legale in Italia**, nel 2026, alle condizioni giuste: un canale aziendale con un contratto vero, dati preferibilmente trattati in Europa, l'uso documentato nel registro, i dipendenti informati e formati, e regole chiare su cosa non entra. Non è legale — o meglio, non è difendibile — usare account personali con i dati dei clienti, decidere sulle persone con un modello senza un impianto adeguato, o inserire dati sanitari in uno strumento generico.

La differenza tra le due situazioni non sta nello strumento, ma nel lavoro che ci metti intorno: qualche giorno per sistemare contratto, registro e regole, mezza giornata di formazione, una checklist onesta portata a chi ti assiste. È poco, e trasforma una zona grigia in un uso che puoi spiegare a un cliente, a un dipendente o al Garante.

Se vuoi impostare l'uso dell'AI nella tua azienda in modo che regga a una verifica, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su come usare ChatGPT al lavoro senza perdere il controllo sono raccolti nella guida su [ChatGPT in azienda]({{ '/it/pillar/chatgpt-azienda/' | relative_url }}).

## FAQ

### È legale usare ChatGPT in azienda in Italia?

Sì, a certe condizioni: usare un canale aziendale (piano per aziende, API o soluzione interna) con un contratto che nomini il fornitore responsabile del trattamento, documentare l'uso nel registro dei trattamenti, informare e formare i dipendenti e stabilire regole su quali dati si possono inserire. Non è difendibile usare account personali con dati di clienti o dipendenti.

### Il Garante privacy ha vietato ChatGPT?

No, oggi non esiste un divieto generale. In passato il Garante è intervenuto nei confronti del fornitore, con limitazioni temporanee e sanzioni, ma l'uso aziendale è lecito se rispetta il GDPR. Ciò che conta è come lo usi: con quali dati, con quale contratto e con quali garanzie.

### Che differenza c'è tra account personale e piano aziendale dal punto di vista legale?

Con il piano aziendale esiste un contratto tra azienda e fornitore che lo nomina responsabile del trattamento, le conversazioni non sono usate per l'addestramento di default e l'azienda controlla gli account. Con l'account personale del dipendente non c'è alcun rapporto contrattuale con l'azienda, e i dati vengono trattati secondo le condizioni accettate dal dipendente come privato.

### Cosa devo controllare nel DPA del fornitore?

Sei punti: che il fornitore sia indicato come responsabile del trattamento, che i dati siano usati solo per erogare il servizio e non per addestrare i modelli, i tempi di conservazione e cancellazione, l'elenco dei sub-responsabili, il luogo del trattamento e la base giuridica degli eventuali trasferimenti extra-UE, e l'impegno a notificare le violazioni.

### L'AI Act vieta l'uso di ChatGPT nelle PMI?

No. Per gli usi da ufficio, come scrivere, riassumere e tradurre, l'AI Act chiede soprattutto che il personale sia formato in modo adeguato e, per i contenuti mostrati al pubblico, obblighi di trasparenza. Gli obblighi pesanti riguardano i sistemi ad alto rischio, come quelli usati per selezionare o valutare le persone, e alcune pratiche sono vietate, come il riconoscimento delle emozioni sul lavoro.

### Posso usare ChatGPT per selezionare i curriculum?

È sconsigliato senza un progetto strutturato. La selezione del personale è un uso ad alto rischio secondo l'AI Act, i CV contengono spesso dati delicati e il GDPR tutela le persone dalle decisioni basate unicamente su trattamenti automatizzati. Usare l'AI per scrivere l'annuncio va bene; usarla per scartare candidati senza supervisione e documentazione no.

### Devo scrivere l'uso di ChatGPT nel registro dei trattamenti?

Sì, se lo strumento tratta dati personali. La riga deve indicare finalità, categorie di interessati e di dati (e quelle escluse), lo strumento e il fornitore nominato responsabile, il luogo del trattamento, la conservazione e le misure adottate.

### Cosa devo dire ai dipendenti?

Quale strumento è autorizzato e per cosa, quali dati possono e non possono inserire, cosa registra l'azienda del loro utilizzo, che l'uso non serve a valutare la loro prestazione e a chi rivolgersi per dubbi o segnalazioni. La legge italiana sull'intelligenza artificiale prevede inoltre che il datore di lavoro informi i lavoratori quando utilizza sistemi di AI che li riguardano.

### Uno studio professionale deve dire ai clienti che usa l'AI?

Sì, la legge italiana sull'intelligenza artificiale prevede che il professionista informi il cliente dell'uso di sistemi di AI, che possono essere solo di supporto all'attività intellettuale. Una clausola nella lettera d'incarico o nell'informativa al cliente è il modo più semplice per farlo.

### Cosa faccio se per un certo uso la risposta è no?

Puoi cambiare canale (dal personale all'aziendale), scegliere un fornitore europeo, adottare una soluzione interna, anonimizzare i dati prima di inserirli quando possibile, restringere l'uso alle attività senza dati personali, oppure semplicemente non usare l'AI per quel compito, come spesso è giusto fare per le decisioni sulle persone.
