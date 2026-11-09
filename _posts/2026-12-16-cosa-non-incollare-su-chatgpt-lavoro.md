---
lang: it
permalink: /it/blog/cosa-non-incollare-su-chatgpt-lavoro/
alt_url: /en/blog/what-not-to-paste-into-chatgpt-at-work/
title: "9 cose che un commerciale non deve mai incollare su ChatGPT (con esempi di danni veri, non da film)"
date: 2026-12-16 07:30:00 +0200
author: "Antonio Trento"
description: "Una lista concreta per i team commerciali: listini, NDA, CV, codice, password, dati sanitari, minori, strategie, dati fiscali. Che danni fanno davvero, cosa si può chiedere all'AI senza rischi, come anonimizzare in due minuti, uno script di workshop da 45 minuti, cosa dare al posto di ChatGPT e sanzioni interne proporzionate."
keywords: ["cosa non incollare su chatgpt lavoro", "chatgpt dati clienti", "riservatezza offerte", "nda e llm", "formazione dipendenti ai", "anonimizzare dati chatgpt"]
image: /assets/images/posts/cosa-non-incollare-su-chatgpt-lavoro.jpg
pillar: chatgpt-azienda
related: [/it/blog/chatgpt-dati-aziendali-gdpr/, /it/blog/chatgpt-legale-in-azienda-italia/]
---

## Perché "tanto lo usano tutti" non è una policy

Nel 2023 alcuni ingegneri di una grande multinazionale coreana dell'elettronica incollarono su ChatGPT pezzi di codice sorgente proprietario e appunti di riunioni interne, per farsi aiutare a correggere errori e a scrivere verbali. La notizia fece il giro del mondo, l'azienda limitò l'uso degli strumenti di AI generativa, e da allora quell'episodio viene citato in ogni corso sulla sicurezza. Non perché quegli ingegneri fossero sprovveduti: perché stavano facendo esattamente quello che fanno ogni giorno migliaia di persone, in aziende di ogni dimensione.

Nei team commerciali succede lo stesso, con materiale diverso: l'offerta per il cliente importante, il listino con gli sconti riservati, le note della trattativa, il contratto con le clausole negoziate, il CV del candidato da presentare al cliente. "Tanto lo usano tutti" è vero, ed è esattamente il problema: **un comportamento diffuso senza regole non è una policy, è un rischio distribuito**.

Questo pezzo è pensato per essere letto e condiviso in un team commerciale. Elenca le **9 cose da non incollare mai su ChatGPT al lavoro** (o su strumenti simili con account personali), spiega che danni fanno davvero — senza scenari da film —, mostra cosa si può chiedere all'AI in modo sicuro, come anonimizzare un testo in due minuti, e propone uno script di workshop da 45 minuti per formare il team. Più due cose che spesso mancano: cosa dare ai commerciali al posto di ChatGPT, e come gestire chi sbaglia senza fare teatro.

## È per te / non è per te

È per te se:

- guidi o fai parte di un team commerciale, di customer care, di selezione del personale o di consulenza;
- sai che i colleghi usano ChatGPT, Gemini o strumenti simili, e nessuno ha mai detto chiaramente cosa si può fare;
- devi preparare una formazione breve sull'uso dell'AI e cerchi materiale concreto.

Non è per te se cerchi l'inquadramento legale completo (è nel pezzo su [ChatGPT in azienda è legale?]({{ '/it/blog/chatgpt-legale-in-azienda-italia/' | relative_url }})) o il progetto per dare all'azienda uno strumento interno (è nel pezzo sul [ChatGPT interno per la PMI]({{ '/it/blog/chatgpt-interno-azienda-self-hosted/' | relative_url }})). Qui parliamo di comportamenti quotidiani.

## Le 9 categorie: listini, NDA, CV, codice, password, sanitari, minori, strategie, dati fiscali

Una premessa: la lista vale per **ChatGPT e strumenti simili usati con account personali**, cioè senza un contratto tra l'azienda e il fornitore. Con uno strumento aziendale autorizzato, con contratto e senza addestramento sui dati, alcune di queste categorie diventano gestibili con regole. Altre restano vietate ovunque.

### Tabella delle 9 cose

| # | Cosa non incollare | Esempio tipico del commerciale | Perché fa danni | Con strumento aziendale autorizzato |
|---|---|---|---|---|
| 1 | **Listini e condizioni riservate** | "Ecco il listino con gli sconti per i rivenditori, fammi una tabella" | Segreto commerciale; se esce, i clienti confrontano e i concorrenti si allineano | Sì, con cautela |
| 2 | **Documenti sotto NDA** | "Riassumimi il capitolato che il cliente ci ha mandato" | Violazione contrattuale: l'NDA vieta di condividere con terzi | Solo se l'NDA lo consente |
| 3 | **CV e dati di candidati** | "Confronta questi tre CV per la posizione del cliente" | Dati personali (a volte delicati), uso ad alto rischio, discriminazioni | Solo con progetto strutturato |
| 4 | **Codice sorgente e configurazioni** | "Perché non funziona lo script di importazione del cliente?" | Proprietà intellettuale, spesso del cliente; credenziali dimenticate dentro | Sì, senza credenziali e se il contratto lo consente |
| 5 | **Password, token, codici di accesso** | "Sistemami questo file di configurazione" (con la password dentro) | Accesso diretto ai sistemi | **Mai** |
| 6 | **Dati sanitari** | "Scrivi al cliente che il suo collaboratore è in malattia per…" | Categoria particolare del GDPR, tutela rafforzata | Solo dopo valutazione specifica |
| 7 | **Dati di minori** | "Prepara la lista iscritti al corso estivo con età e allergie" | Tutela rafforzata, spesso con dati sanitari | Solo dopo valutazione specifica |
| 8 | **Strategie e informazioni non pubbliche** | "Ecco il piano commerciale 2027 e la lista dei clienti a rischio" | Danno competitivo, informazioni privilegiate | Con molta cautela |
| 9 | **Dati fiscali e finanziari di clienti** | "Analizza il bilancio del cliente per capire se è solvibile" | Dati riservati, spesso sotto accordi di riservatezza | Con cautela, se autorizzato dal cliente |

### Le nove, spiegate in breve

**1. Listini e condizioni riservate.** Il listino pubblico non è un problema. Quello con gli sconti per i rivenditori, le condizioni per i clienti strategici, i margini, sì. È un segreto commerciale: il suo valore sta nel fatto che non lo conosce nessun altro.

**2. Documenti sotto NDA.** Capitolati, specifiche, progetti, offerte ricevute dai clienti spesso arrivano con un accordo di riservatezza. Quasi sempre l'NDA vieta di condividerli con terzi non autorizzati. Un servizio di AI usato con un account personale è un terzo.

**3. CV e dati di candidati.** Nei team che fanno selezione o somministrazione, è la tentazione più forte: confrontare CV, scrivere profili, fare una prima scrematura. I CV contengono dati personali e a volte delicati (salute, appartenenze), e la selezione delle persone con l'AI è un uso che il regolamento europeo considera ad alto rischio.

**4. Codice sorgente e configurazioni.** Per chi vende software o servizi tecnici: lo script del cliente, la configurazione del suo server, il pezzo di codice proprietario. Oltre alla proprietà intellettuale, dentro il codice spesso ci sono credenziali dimenticate, indirizzi interni, nomi di sistemi.

**5. Password, token, codici di accesso.** Mai, in nessuno strumento. Nemmeno "per un attimo", nemmeno dentro un file di configurazione da sistemare. Se una password è finita in una chat, va cambiata.

**6. Dati sanitari.** Malattie, infortuni, disabilità, certificati. Anche in forma indiretta ("il suo referente è in ospedale"). Sono una categoria particolare del GDPR, con tutele rafforzate.

**7. Dati di minori.** Per chi lavora con scuole, corsi, attività sportive, servizi per famiglie: elenchi di bambini, età, allergie, note. Tutela rafforzata, spesso combinata con dati sanitari.

**8. Strategie e informazioni non pubbliche.** Il piano commerciale, l'elenco dei clienti a rischio di abbandono, le trattative in corso con un'acquisizione, i risultati del trimestre prima che siano pubblici. Il danno è competitivo e, in alcuni casi, legale.

**9. Dati fiscali e finanziari dei clienti.** Bilanci, dichiarazioni, estratti conto, situazione debitoria, ricevuti per valutare un affidamento o preparare un'offerta. Riservati per definizione.

## Danno: fuga, contratto, reputazione, vantaggio al competitor nel modello

"Ma alla fine cosa succede?" è la domanda giusta. Vediamo i danni reali, in ordine di probabilità.

**1. Perdita di controllo (sempre).** Il danno più certo e più sottovalutato. Una volta incollato, il testo è su un servizio esterno, in un account personale. L'azienda non sa che c'è, non può cancellarlo, non può dimostrare cosa è uscito. Se un giorno un cliente chiede "dove sono finiti i nostri documenti?", non c'è una risposta.

**2. Violazione contrattuale (spesso).** Molti contratti e NDA vietano esplicitamente di condividere informazioni con terzi senza autorizzazione. Basta che un cliente lo scopra — per un audit, per una domanda diretta, per un commerciale che se ne va e racconta — perché il rapporto sia a rischio. Nei settori regolati (finanza, sanità, pubblica amministrazione) la questione è ancora più seria.

**3. Problema privacy (spesso).** Se dentro ci sono dati personali, l'azienda ha fatto un trattamento senza le garanzie richieste. Può essere una violazione da valutare e, nei casi più seri, da notificare al Garante. Il quadro completo è nel pezzo su [ChatGPT, dati aziendali e GDPR]({{ '/it/blog/chatgpt-dati-aziendali-gdpr/' | relative_url }}).

**4. Danno reputazionale (a volte).** Il giorno in cui si viene a sapere che "l'azienda X mette i contratti dei clienti su ChatGPT", il danno non si misura in sanzioni ma in fiducia. Per un'azienda di servizi, è la cosa più costosa.

**5. "Vantaggio al competitor nel modello" (raramente, ma non zero).** Con gli account personali, le conversazioni possono essere usate per addestrare i modelli, se l'utente non ha disattivato l'opzione. Che un dettaglio specifico del tuo listino "riemerga" in una risposta a un concorrente è improbabile, e i fornitori dichiarano misure per evitarlo. Ma non è un rischio che un'azienda dovrebbe scegliere di correre, e il punto vero resta il primo: non hai nessun controllo.

Questa è la lista onesta. Niente scenari da film con hacker che rubano la strategia aziendale da ChatGPT. I danni reali sono più banali e più probabili: un contratto violato, un cliente che si arrabbia, una violazione dei dati da gestire.

## Cosa SI può chiedere (testo anonimizzato, struttura, tono)

Il messaggio non deve essere "non usate l'AI". Deve essere "usatela così". Ecco cosa un commerciale può chiedere senza rischi, anche con uno strumento generico:

- **Struttura**: "Come si struttura un'offerta per un servizio di manutenzione annuale? Quali sezioni deve avere?"
- **Tono**: "Riscrivi questa frase in modo più cortese ma fermo: 'non possiamo applicare lo sconto richiesto'."
- **Modelli generici**: "Scrivi un modello di email di follow-up dopo una fiera, con spazi da riempire."
- **Obiezioni**: "Quali sono le obiezioni tipiche di un responsabile acquisti su un aumento di prezzo del 5%, e come rispondere?"
- **Spiegazioni**: "Spiegami in parole semplici cos'è il reverse charge, devo spiegarlo a un cliente."
- **Testi anonimizzati**: la mail del cliente, dopo aver tolto nomi, aziende, importi e riferimenti (vedi sotto).
- **Testi pubblici**: la presentazione aziendale pubblicata sul sito, la scheda prodotto pubblica.

Con lo **strumento aziendale autorizzato** (contratto, addestramento disattivato, dati in UE o in casa), si possono fare molte più cose: lavorare sui documenti reali dei clienti, riassumere trattative, preparare offerte. Le categorie 5 (password), 6 e 7 (sanitari e minori) restano escluse salvo valutazioni specifiche.

## Come anonimizzare in 2 minuti (e quando non basta)

Anonimizzare non significa cambiare il nome del cliente e lasciare tutto il resto. Significa togliere **tutto ciò che permette di capire di chi si parla** e **tutto ciò che è riservato**. Ecco un esempio pratico.

### Esempio di anonimizzazione

Il testo originale, che il commerciale vorrebbe incollare per farsi aiutare a rispondere:

```text
Buongiorno Andrea,
come anticipato a Giulia Ferri la scorsa settimana, Officine Ferri S.r.l. di Lumezzane
non può accettare l'aumento del 7% sul contratto di manutenzione 2027 (attuale 18.400 €/anno).
Il vostro concorrente TecnoService ci ha offerto lo stesso servizio a 16.900 €.
Se non rivedete le condizioni entro il 15 gennaio valuteremo il cambio fornitore.
Cordiali saluti, Marco Ferri – Direttore tecnico – 335 1234567
```

La versione anonimizzata:

```text
Buongiorno [REFERENTE],
come anticipato alla nostra collega la scorsa settimana, [CLIENTE], azienda manifatturiera
di medie dimensioni, non può accettare l'aumento del [X]% sul contratto di manutenzione
annuale. Un concorrente ci ha offerto lo stesso servizio a un prezzo inferiore di circa l'8%.
Se non rivedete le condizioni entro [DATA] valuteremo il cambio fornitore.
Cordiali saluti, [NOME] – [RUOLO]
```

Cosa è stato fatto, in ordine:

1. **Nomi di persone** sostituiti con un segnaposto (Andrea, Giulia Ferri, Marco Ferri).
2. **Nome dell'azienda e luogo** sostituiti con una descrizione generica (nome e città insieme identificano il cliente con certezza).
3. **Importi esatti** tolti; resta la **proporzione** (circa 8% in meno), che è ciò che serve per scrivere la risposta.
4. **Nome del concorrente** tolto: è un'informazione riservata e non serve.
5. **Contatti** (telefono) tolti.
6. **Date precise** sostituite, se identificano il contratto.

Per chiedere all'AI "come rispondo in modo da tenere il cliente senza cedere su tutto il prezzo?", la versione anonimizzata funziona benissimo. La risposta torna con i segnaposto, e il commerciale la completa.

### Quando anonimizzare non basta

- **Quando il contenuto stesso è il segreto**: un listino resta un listino anche senza il nome del cliente; un capitolato sotto NDA resta riservato anche senza il logo.
- **Quando i dettagli identificano comunque**: "l'unica azienda del distretto che produce valvole per l'industria navale" identifica il cliente anche senza nome.
- **Quando c'è troppo testo**: anonimizzare un contratto di 40 pagine è un lavoro lungo e facile da sbagliare. Lì serve lo strumento aziendale, non l'anonimizzazione.
- **Quando si tratta di dati sanitari o di minori**: il rischio di lasciare un dettaglio identificativo è troppo alto.

## Workshop 45 minuti per il team commerciale

Ecco lo script che uso per formare un team commerciale. Funziona in presenza o in videochiamata, con 5–20 persone. Serve un proiettore e lo strumento di AI aziendale (o, se non c'è ancora, ChatGPT con testi inventati).

### Script del workshop

```text
WORKSHOP "AI SÌ, MA COSÌ" — 45 minuti

[0–5]   APERTURA (responsabile commerciale)
        "Usiamo tutti l'AI e va bene. Oggi decidiamo insieme come usarla senza
         mettere nei guai noi e i clienti." Niente prediche.

[5–12]  IL CASO (formatore)
        Racconto di un caso realistico: l'offerta incollata con nomi, importi e
        concorrente. Domanda alla sala: "cosa è uscito dall'azienda?"
        Si elencano insieme: nomi, cliente, prezzi, concorrente, strategia.

[12–20] LE 9 COSE (formatore)
        Tabella proiettata. Per ognuna, una domanda: "vi è mai capitato?"
        Obiettivo: riconoscere i casi propri, non memorizzare una lista.

[20–30] ESERCIZIO DI ANONIMIZZAZIONE (a coppie)
        Ogni coppia riceve una mail di cliente inventata ma realistica.
        5 minuti per anonimizzarla. Confronto: cosa è rimasto di identificativo?

[30–38] COSA SI PUÒ FARE (dimostrazione dal vivo)
        Con lo strumento aziendale: tono di una risposta difficile, struttura di
        un'offerta, gestione di un'obiezione sul prezzo. Si mostra anche un ERRORE
        dell'AI (un dato inventato) per spiegare perché si rilegge sempre.

[38–43] LE REGOLE E LO STRUMENTO (responsabile)
        Quale strumento usare, dove si trova, le 9 cose, cosa fare se si sbaglia
        (segnalare entro la giornata, senza paura).

[43–45] DOMANDE E FIRMA
        Firma del foglio con le regole. Raccolta di casi d'uso da migliorare.
```

Tre dettagli che fanno funzionare il workshop:

- **Il responsabile commerciale apre e chiude**: se lo fa solo l'IT o la privacy, il messaggio è "regole imposte da fuori".
- **L'esercizio di anonimizzazione è il momento chiave**: le persone scoprono da sole quanto è facile lasciare un dettaglio identificativo.
- **L'errore dell'AI mostrato dal vivo** convince più di qualsiasi slide a rileggere quello che si manda ai clienti.

## Cosa mettere al posto: strumento interno o vendor con DPA

Vietare senza alternativa non funziona: le persone continueranno a usare ChatGPT dal telefono. Il workshop ha senso solo se, alla fine, si può dire "**usate questo**".

Le alternative, in breve:

- **Piano aziendale di un fornitore**, con contratto per il trattamento dei dati (DPA), conversazioni non usate per l'addestramento, account gestiti dall'azienda, possibilmente con dati in Europa. Si attiva in pochi giorni.
- **Fornitore europeo** con trattamento in UE e contratto pensato per il GDPR.
- **Strumento interno**, su server dell'azienda o in un datacenter europeo sotto il vostro controllo, eventualmente collegato ai documenti aziendali con i permessi giusti. Il progetto è descritto nel pezzo sul [ChatGPT interno per la PMI]({{ '/it/blog/chatgpt-interno-azienda-self-hosted/' | relative_url }}).
- **Funzioni di AI dentro il CRM**, per chi lavora già su un CRM: riassunti delle trattative, bozze di email, senza far uscire i dati dal sistema. Ne ho parlato nel pezzo sulle [automazioni di Salesforce prima dell'AI]({{ '/it/blog/automazione-salesforce-pmi/' | relative_url }}).

Con uno di questi strumenti, la lista delle 9 cose si accorcia: le categorie 1, 2, 4, 8 e 9 diventano gestibili con regole, le 3, 6 e 7 richiedono valutazioni specifiche, la 5 resta vietata sempre.

## Sanzioni interne proporzionate (senza teatro)

Prima o poi qualcuno sbaglierà. Come reagisce l'azienda decide se le persone continueranno a segnalare gli errori o li nasconderanno.

Una scala proporzionata, da concordare con chi si occupa delle risorse umane e del lavoro:

- **Errore segnalato spontaneamente** (ho incollato qualcosa che non dovevo, ve lo dico): nessuna sanzione. Si valuta il danno, si cambiano le password se serve, si gestisce l'eventuale violazione dei dati. È esattamente il comportamento che si vuole incoraggiare.
- **Primo errore scoperto da altri**, senza dolo, prima della formazione: un colloquio e la formazione.
- **Errore dopo la formazione e la firma delle regole**: richiamo formale, secondo il regolamento interno e il contratto applicato.
- **Violazione grave e consapevole** (esportare l'intero archivio clienti su un servizio esterno, condividere dati sanitari, aggirare deliberatamente lo strumento aziendale): provvedimento disciplinare secondo le regole del contratto di lavoro.

Cosa evitare: il "teatro" della sicurezza. Circolari minacciose, controlli a sorpresa sulle chat, sanzioni esemplari per un errore piccolo. Funzionano per una settimana, poi le persone smettono di segnalare e continuano a usare l'AI di nascosto. Ricorda anche che i controlli sugli strumenti di lavoro in Italia hanno regole precise: prima di qualsiasi controllo, serve il parere del consulente del lavoro.

## Un caso concreto: il team commerciale di un distributore

Un distributore di componenti industriali con 12 commerciali, nessuna regola sull'AI. Un questionario anonimo rivela che 10 su 12 usano ChatGPT con l'account personale, almeno qualche volta a settimana, per scrivere offerte e rispondere ai clienti. Sette ammettono di aver incollato listini o mail di clienti con nomi e prezzi.

**Cosa si è fatto in un mese.** Attivato un piano aziendale con contratto e dati in UE per i 12 commerciali. Scritte le regole su una pagina, con le 9 cose. Fatto il workshop di 45 minuti, aperto dal direttore commerciale. Bloccato l'accesso a ChatGPT personale dalla rete aziendale, ma solo dopo che lo strumento aziendale era disponibile, con una pagina che rimanda al nuovo strumento. Preparati, insieme ai commerciali, cinque modelli di richiesta per i casi più frequenti (risposta a un'obiezione di prezzo, follow-up dopo una visita, presentazione di un nuovo prodotto, sollecito garbato, riassunto di una trattativa).

**Dopo tre mesi.** Il secondo questionario anonimo dice che 11 su 12 usano lo strumento aziendale, uno continua a non usare l'AI. Due commerciali hanno segnalato spontaneamente di aver incollato per errore dati di un cliente nello strumento aziendale (che era il posto giusto, ma con più dati del necessario): nessuna sanzione, una chiacchierata sulla minimizzazione. Il direttore commerciale nota che le offerte sono più curate e arrivano prima.

## Percorso 30/60/90 giorni

**Primi 30 giorni**: questionario anonimo, scelta dello strumento autorizzato, regole su una pagina, workshop con il team commerciale.

**Da 30 a 60 giorni**: blocco degli strumenti non autorizzati con reindirizzamento, modelli di richiesta preparati con i commerciali, estensione ad altri team (customer care, amministrazione).

**Da 60 a 90 giorni**: secondo questionario anonimo, revisione delle regole sui casi emersi, decisione sugli usi più delicati (selezione, dati dei clienti in volume).

## 3 errori da principiante che costano soldi o dati

**1. Fare la formazione senza dare lo strumento.** Il workshop spiega cosa non fare, e poi i commerciali tornano alla scrivania senza alternativa. Dopo una settimana usano ChatGPT come prima, solo con un po' di senso di colpa.

**2. Credere che togliere il nome basti.** "Ho tolto il nome del cliente" mentre restano città, settore, importi, nome del concorrente e firma con il cellulare. L'esercizio di anonimizzazione nel workshop serve proprio a far vedere quanto resta.

**3. Punire chi segnala.** Il primo commerciale che ammette un errore e riceve un richiamo formale insegna a tutti gli altri a non segnalare mai più. Da quel momento gli errori ci sono comunque, ma l'azienda non li conosce.

## Quando NON farlo (o farlo diversamente)

- **Se il team è di 2–3 persone**, non serve un workshop: una chiacchierata di 15 minuti con la tabella e lo strumento aziendale bastano.
- **Se i commerciali trattano dati sanitari** (informatori, vendita di dispositivi medici, servizi socio-sanitari), la formazione va preparata con il consulente privacy e lo strumento va scelto con più attenzione.
- **Se non c'è ancora uno strumento autorizzato**, rimanda il workshop di qualche settimana e intanto attivalo. Una formazione senza alternativa è poco efficace.

## Checklist pratica

- [ ] Ho fatto un questionario anonimo per sapere chi usa cosa.
- [ ] C'è uno strumento di AI autorizzato, con contratto e addestramento disattivato.
- [ ] Le 9 cose sono su una pagina, con esempi del nostro lavoro.
- [ ] Il workshop di 45 minuti è stato fatto, aperto dal responsabile commerciale.
- [ ] L'esercizio di anonimizzazione è stato fatto a coppie.
- [ ] I commerciali hanno modelli di richiesta per i casi più frequenti.
- [ ] Esiste una procedura per segnalare un errore entro la giornata, senza sanzioni per chi segnala.
- [ ] La scala di sanzioni è proporzionata e concordata con chi gestisce il personale.
- [ ] Gli strumenti non autorizzati sono bloccati solo dopo che l'alternativa è disponibile.
- [ ] A 90 giorni c'è un secondo questionario per misurare il cambiamento.

## Il verdetto

Le **cose da non incollare su ChatGPT al lavoro** sono nove, e nessuna è sorprendente: listini e condizioni riservate, documenti sotto NDA, CV, codice, password, dati sanitari, dati di minori, strategie, dati fiscali dei clienti. Il problema non è conoscerle: è che nessuno le ha mai dette chiaramente a un team che usa l'AI ogni giorno per lavorare meglio.

La soluzione non è vietare e minacciare. È dare uno strumento autorizzato, una pagina di regole, 45 minuti di formazione con un esercizio vero, e un clima in cui chi sbaglia lo dice subito. Così l'AI resta quello che dovrebbe essere per un commerciale — un aiuto a scrivere meglio e più in fretta — senza diventare il canale da cui escono i dati dei clienti.

Se vuoi preparare il tuo team commerciale a usare l'AI senza rischi, con lo strumento giusto e regole che vengano rispettate, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su ChatGPT al lavoro sono nella guida su [ChatGPT in azienda]({{ '/it/pillar/chatgpt-azienda/' | relative_url }}).

## FAQ

### Cosa non bisogna mai incollare su ChatGPT al lavoro?

Con un account personale: listini e condizioni riservate, documenti coperti da accordi di riservatezza, CV e dati di candidati, codice sorgente proprietario, password e codici di accesso, dati sanitari, dati di minori, strategie e informazioni non pubbliche, dati fiscali e finanziari dei clienti. Password e codici di accesso non vanno inseriti in nessuno strumento.

### Cosa succede se un dipendente incolla dati di clienti su ChatGPT?

L'azienda perde il controllo su quei dati, che finiscono su un servizio esterno senza contratto. Può esserci una violazione di accordi di riservatezza con il cliente, una violazione dei dati personali da valutare ed eventualmente notificare al Garante, e un danno reputazionale se il fatto diventa noto.

### Basta togliere il nome del cliente per usare ChatGPT in sicurezza?

No. Bisogna togliere tutto ciò che permette di identificare la persona o l'azienda, come nomi, luoghi, importi esatti, nomi di concorrenti, contatti e date, e tutto ciò che è riservato. In alcuni casi, come listini, documenti sotto NDA o dati sanitari, l'anonimizzazione non basta e serve uno strumento aziendale autorizzato.

### Cosa può chiedere un commerciale all'AI senza rischi?

Struttura di un'offerta, tono di una risposta difficile, modelli generici di email, gestione delle obiezioni, spiegazioni di concetti, lavoro su testi anonimizzati o pubblici. Con uno strumento aziendale autorizzato si può lavorare anche sui documenti reali, nel rispetto delle regole interne.

### Le conversazioni su ChatGPT vengono usate per addestrare il modello?

Con gli account personali, spesso sì, a meno che l'utente non disattivi l'opzione nelle impostazioni. Con i piani aziendali e le API, generalmente no, per impostazione predefinita e per contratto. Per questo l'uso con dati aziendali dovrebbe passare da strumenti aziendali.

### Come si organizza una formazione sull'uso dell'AI per i commerciali?

Bastano 45 minuti: un'apertura del responsabile commerciale, un caso realistico, la tabella delle cose da non incollare, un esercizio di anonimizzazione a coppie, una dimostrazione dal vivo di cosa si può fare e di un errore dell'AI, le regole e lo strumento autorizzato, la firma delle regole.

### Cosa dare ai dipendenti al posto di ChatGPT?

Un piano aziendale di un fornitore con contratto per il trattamento dei dati, un fornitore europeo, uno strumento interno su infrastruttura dell'azienda o funzioni di AI integrate nel CRM. L'importante è che sia comodo quanto ChatGPT, altrimenti le persone continueranno a usare gli account personali.

### Come sanzionare un dipendente che ha incollato dati riservati?

In modo proporzionato: nessuna sanzione per chi segnala spontaneamente l'errore, colloquio e formazione per un primo errore senza dolo, richiamo formale per errori successivi alla formazione, provvedimenti disciplinari solo per violazioni gravi e consapevoli, secondo il contratto di lavoro. Punire chi segnala porta le persone a nascondere gli errori.

### Si possono usare ChatGPT e strumenti simili per confrontare CV?

È sconsigliato con strumenti generici e senza un progetto strutturato. I CV contengono dati personali, a volte delicati, e la selezione delle persone con l'intelligenza artificiale è considerata un uso ad alto rischio dal regolamento europeo, con obblighi specifici di supervisione e documentazione.

### Cosa fare se una password è finita in una chat con l'AI?

Cambiarla subito, insieme a qualsiasi altra credenziale presente nello stesso testo, e segnalarlo al referente interno. Le password non devono mai essere inserite in strumenti di AI, nemmeno dentro file di configurazione da correggere.
