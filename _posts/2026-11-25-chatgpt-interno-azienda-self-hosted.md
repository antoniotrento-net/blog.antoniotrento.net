---
lang: it
permalink: /it/blog/chatgpt-interno-azienda-self-hosted/
alt_url: /en/blog/internal-chatgpt-self-hosted-company/
title: "Come fare un ChatGPT interno per la PMI senza mandare i documenti in America"
date: 2026-11-25 07:30:00 +0200
author: "Antonio Trento"
description: "Il progetto di un ChatGPT interno che lavora sui documenti aziendali, spiegato a un titolare: due strati (chiacchiere e documenti), dove stanno i file e chi li vede, cloud UE o server in ufficio, cosa sa fare e cosa no, permessi, costi per 5, 25 e 80 persone, 10 regole e un piano di 60 giorni."
keywords: ["chatgpt interno azienda self hosted", "gpt aziendale privato", "llm locale pmi", "alternativa copilot 365", "chat interna documenti", "assistente ai documenti aziendali"]
image: /assets/images/posts/chatgpt-interno-azienda-self-hosted.jpg
pillar: chatgpt-azienda
related: [/it/blog/ricerca-documenti-aziendali-pdf/, /it/blog/chatgpt-privato-self-hosted-pmi/]
---

## Cosa intendono i dipendenti per "un ChatGPT nostro"

Quando in una PMI qualcuno dice "vorremmo un ChatGPT nostro", di solito intende due cose diverse, mescolate.

La prima è **uno strumento per scrivere**: sistemare una mail, riassumere un verbale, tradurre una scheda tecnica, preparare la bozza di un'offerta. Esattamente quello che fanno già con ChatGPT sul telefono, ma senza la paura di fare qualcosa di sbagliato con i dati dei clienti.

La seconda, quella che entusiasma di più, è **uno strumento che conosce l'azienda**: "chiedo qual è la procedura per i resi e mi risponde", "chiedo che condizioni abbiamo con il fornitore X e me lo dice", "chiedo come si configura la macchina Y e mi tira fuori il paragrafo giusto del manuale". In altre parole: **ChatGPT, ma sui nostri file**.

Questo pezzo spiega come si costruisce un **ChatGPT interno per l'azienda, self-hosted o comunque sotto il vostro controllo**, partendo da quello che i dipendenti vogliono davvero. È scritto per il titolare o il responsabile che deve decidere, non per il tecnico che lo installerà: niente configurazioni, ma un'architettura "a scatole" comprensibile, cosa può fare e cosa no, i costi per aziende di diverse dimensioni, e un piano di 60 giorni. Il tecnico troverà i dettagli su hardware e modelli nel pezzo su [come montare un ChatGPT privato su due GPU]({{ '/it/blog/chatgpt-privato-self-hosted-pmi/' | relative_url }}).

La premessa, detta subito: il primo strato (scrivere) è relativamente facile. Il secondo (rispondere sui documenti) è dove si fa la differenza, e dove i progetti falliscono quando li si tratta come un'installazione invece che come un lavoro sull'organizzazione dei documenti.

## È per te / non è per te

È per te se:

- hai tra 5 e 100 persone che passano parte della giornata a cercare informazioni in documenti, cartelle e mail;
- hai procedure, manuali, listini, contratti, schede tecniche che esistono ma che nessuno trova al momento giusto;
- non vuoi che quei documenti finiscano sui server di un fornitore americano senza controllo;
- stai valutando Copilot o strumenti simili e ti chiedi se esiste un'alternativa con i dati in casa.

Non è per te se i tuoi documenti sono pochi e tutti in testa a due persone: il problema lì è organizzativo, non tecnologico. E non è per te se cerchi una soluzione da attivare in un pomeriggio: il primo strato sì, il secondo no.

## Due strati: chiacchiere vs documenti aziendali

La cosa più utile da capire, prima di parlare di server e costi, è che un "ChatGPT interno" è fatto di **due strati** con requisiti molto diversi.

### Strato 1: la chat generica

È un assistente che scrive, riassume, traduce, spiega. Lavora su quello che l'utente gli incolla o gli carica in quel momento. Non sa niente dell'azienda finché qualcuno non glielo dice nella conversazione.

- **Cosa serve:** un modello di linguaggio, un'interfaccia simile a ChatGPT, il login con l'account aziendale.
- **Difficoltà:** bassa. Si attiva in pochi giorni (cloud UE con contratto) o in poche settimane (server interno).
- **Rischio principale:** che le persone ci mettano dati che non dovrebbero; si gestisce con regole e formazione.

### Strato 2: le risposte sui documenti aziendali

È l'assistente che, quando chiedi "qual è la procedura per i resi?", **cerca nei documenti dell'azienda**, trova i paragrafi pertinenti, e risponde **citando la fonte** ("dalla procedura PR-07, aggiornata a marzo 2026, paragrafo 3"). Tecnicamente si chiama RAG (generazione aumentata dal recupero): prima si cerca, poi si risponde usando quello che si è trovato.

- **Cosa serve:** oltre allo strato 1, un sistema che legge i documenti dalle loro cartelle, li indicizza per la ricerca, rispetta i permessi, e un modo di mostrare le fonti.
- **Difficoltà:** media o alta. Non per la tecnologia, ma per i documenti: dove sono, quanto sono aggiornati, chi li può vedere.
- **Rischio principale:** che l'assistente risponda con sicurezza usando un documento vecchio, o che mostri a qualcuno un documento che non dovrebbe vedere.

Il consiglio pratico: **partire dallo strato 1 per tutti, e dallo strato 2 su un perimetro piccolo** (per esempio: le procedure qualità, o i manuali tecnici di un reparto). Lo strato 2 su "tutti i documenti dell'azienda" al primo colpo è il modo più sicuro per deludere tutti.

## Architettura a scatole (per non tecnici)

Ecco come è fatto, in sei scatole. Non serve sapere come funziona ogni scatola: serve sapere che esistono, cosa fanno e dove stanno.

```text
        ┌──────────────────────────┐
        │  1. LOGIN AZIENDALE       │  ← entri con l'account di lavoro (Microsoft, Google, interno)
        └────────────┬─────────────┘
                     ▼
        ┌──────────────────────────┐
        │  2. INTERFACCIA CHAT      │  ← la "faccia" simile a ChatGPT, nel browser
        └────────────┬─────────────┘
                     ▼
        ┌──────────────────────────┐
        │  3. REGISTA               │  ← decide: domanda generica o domanda sui documenti?
        │     (+ controllo permessi)│     e controlla cosa TU puoi vedere
        └──────┬─────────────┬─────┘
               ▼             ▼
  ┌──────────────────┐  ┌──────────────────────────┐
  │ 4. MODELLO        │  │ 5. INDICE DEI DOCUMENTI   │  ← copia "cercabile" dei documenti
  │    (il "cervello")│  │    + citazioni            │     autorizzati, aggiornata ogni notte
  └──────────────────┘  └────────────┬─────────────┘
                                     ▲
                        ┌────────────┴─────────────┐
                        │ 6. LE VOSTRE CARTELLE      │  ← NAS, Drive/SharePoint, gestionale
                        │    (restano dove sono)     │     (solo lettura)
                        └──────────────────────────┘
```

Riga per riga:

1. **Login aziendale.** Nessun account nuovo: chi entra lo fa con l'account di lavoro, e quando lascia l'azienda perde l'accesso automaticamente.
2. **Interfaccia chat.** Quello che vedono le persone. Deve essere comoda quanto ChatGPT, o non la useranno.
3. **Regista.** Il pezzo di software che riceve la domanda, capisce se serve cercare nei documenti, controlla quali documenti l'utente può vedere, e passa al modello solo quelli.
4. **Modello.** Il "cervello" che scrive le risposte. Può stare su un server in ufficio, su un server in un datacenter italiano o europeo, o presso un fornitore cloud europeo con contratto.
5. **Indice dei documenti.** Una copia "cercabile" dei documenti autorizzati, con i riferimenti per citare la fonte. Si aggiorna in automatico (per esempio ogni notte).
6. **Le vostre cartelle.** I documenti restano dove sono: il sistema li legge, non li sposta né li modifica.

La cosa da notare: **nessuna scatola manda i documenti fuori**, se il modello e l'indice stanno su infrastruttura vostra o europea sotto contratto. È questa la differenza con "carico i PDF su ChatGPT".

## Dove stanno i file (NAS, Drive, gestionale) e chi li vede

Prima di qualsiasi scelta tecnica, serve una fotografia onesta di **dove stanno i documenti** e **chi li può vedere oggi**. È il lavoro meno spettacolare e quello che decide il risultato.

Le situazioni tipiche:

- **NAS o file server in ufficio**, con cartelle per reparto e permessi (a volte ordinati, spesso no).
- **Drive o SharePoint in cloud**, con cartelle condivise e link "chiunque abbia il link".
- **Gestionale o CRM**, con documenti allegati a clienti, ordini, pratiche.
- **Email**, dove vive una parte enorme della conoscenza aziendale (e che conviene lasciare fuori, almeno all'inizio).
- **Teste delle persone**: procedure mai scritte, che nessun sistema potrà mai indicizzare.

Tre domande da fare per ogni fonte:

1. **È aggiornata?** Una cartella "Procedure" con tre versioni della stessa procedura e nessuna indicazione di quale è valida produrrà risposte sbagliate. L'assistente non sa quale versione è quella buona, a meno che non glielo dica qualcuno.
2. **Chi la può vedere oggi?** Se la cartella HR è accessibile a tutti per errore, l'assistente lo renderà evidente in pochi giorni ("chiedo quanto guadagna il collega e me lo dice"). Meglio scoprirlo prima.
3. **Serve davvero?** Non tutto va indicizzato. Le procedure, i manuali, i listini interni, le FAQ dei clienti sì. Gli archivi di dieci anni di corrispondenza, probabilmente no.

Il risultato di questo lavoro è un elenco di **fonti autorizzate**, con un responsabile per ciascuna. È anche la base per il pezzo su come costruire una [ricerca nei documenti aziendali che funziona]({{ '/it/blog/ricerca-documenti-aziendali-pdf/' | relative_url }}): prima si trova, poi si risponde.

## Cloud UE con contratto vs macchina in ufficio/VPS Italia

Il "modello" e l'"indice" devono girare da qualche parte. Ci sono tre opzioni realistiche per una PMI, ognuna con pregi e limiti.

**1. Fornitore cloud europeo con contratto.** Usi un modello offerto da un fornitore che tratta i dati in UE, con un contratto che lo nomina responsabile del trattamento e esclude l'addestramento sui tuoi dati. L'indice dei documenti può stare presso lo stesso fornitore o su un tuo server.

- Pro: nessun hardware, qualità alta, attivazione rapida.
- Contro: costo che cresce con l'uso, dipendenza dal fornitore, i documenti (o pezzi di essi) passano dai suoi server.

**2. Server in un datacenter italiano o europeo (VPS o server dedicato con GPU).** Installi tu (o il tuo fornitore) modello e indice su un server noleggiato in Italia o in UE.

- Pro: controllo alto, nessun hardware in ufficio, costi prevedibili.
- Contro: i server con GPU a noleggio costano; serve qualcuno che li gestisca.

**3. Macchina in ufficio.** Un server con una o due schede grafiche nella stanza tecnica.

- Pro: massimo controllo, dati che non escono mai dall'edificio, costo fisso.
- Contro: investimento iniziale, energia, guasti da gestire, serve uno spazio adatto e qualcuno che se ne occupi.

Per una PMI senza IT interno, la combinazione più frequente che consiglio è: **modello presso un fornitore europeo con contratto o su un server UE, indice dei documenti su un server sotto il vostro controllo**, permessi gestiti dal "regista". La macchina in ufficio ha senso dalle 20–30 persone in su, quando l'uso è intenso e c'è qualcuno che può gestirla.

Una nota su Copilot e simili: gli assistenti integrati nelle suite d'ufficio fanno una cosa simile allo strato 2 sui documenti già presenti nella suite, con i permessi della suite. Possono essere una buona scelta se tutti i documenti sono lì e i permessi sono ordinati; costano per utente e legano ancora di più alla suite. Il ragionamento su permessi e documenti vecchi vale identico.

## Cosa sa fare bene (bozze, riassunti, Q&A citata) e cosa no

Le aspettative sbagliate uccidono più progetti dei problemi tecnici. Ecco cosa aspettarsi, in modo onesto.

**Cosa sa fare bene:**

- **Bozze**: mail, lettere, offerte, comunicazioni, a partire da indicazioni e documenti forniti.
- **Riassunti**: verbali, contratti lunghi, documentazione tecnica, thread di mail.
- **Domande con risposta citata**: "qual è la procedura per i resi?", "che garanzia diamo sul prodotto X?", "come si fa il cambio formato sulla linea 2?", con il riferimento al documento e al paragrafo.
- **Traduzioni** di testi tecnici e commerciali.
- **Orientamento**: "dove trovo il modulo per le ferie?", "chi si occupa delle spedizioni estere?", se c'è un documento che lo dice.

**Cosa non sa fare (e non deve fingere di saper fare):**

- **Pareri professionali**: legali, fiscali, medici, tecnici con responsabilità. Può riassumere cosa dice un documento, non decidere al posto di chi ne risponde.
- **Numeri senza fonte**: "quanto abbiamo fatturato al cliente X?" non è una domanda per la chat; è una domanda per il gestionale. Se l'assistente risponde con un numero senza poterlo citare da un documento o da un sistema, il numero va considerato inventato.
- **Sapere cose che non sono scritte**: se la procedura non esiste o è nella testa di una persona, l'assistente non la conosce. Il rischio è che ne inventi una plausibile; per questo la regola "niente fonte, niente risposta" è fondamentale.
- **Distinguere da solo la versione giusta**: se nelle cartelle ci sono tre versioni della stessa procedura, l'assistente può citare quella sbagliata. La pulizia delle fonti è un lavoro umano.

La regola che metto in tutti i progetti: **sulle domande aziendali, l'assistente risponde solo se trova una fonte, e la mostra**. Se non la trova, lo dice ("non ho trovato documenti su questo argomento"). Un assistente che dice "non lo so" è molto più utile di uno che risponde sempre.

## Accessi: non tutti vedono gli stipendi

Questo è il punto che trasforma un progetto utile in un incidente. Se l'indice dei documenti contiene la cartella HR, e il regista non controlla i permessi, qualcuno chiederà "quanto guadagna Rossi?" e otterrà una risposta. Succede, e succede quasi sempre nelle prime due settimane.

Le regole:

- **L'assistente vede solo quello che l'utente può già vedere.** Se Mario non ha accesso alla cartella "Amministrazione/Stipendi" sul NAS, l'assistente non deve usare quei documenti per rispondere a Mario. I permessi si ereditano dalle fonti, non si inventano da capo.
- **Alcune cartelle restano fuori dall'indice**, punto: buste paga, valutazioni del personale, documenti sanitari, contenziosi. Non serve che l'assistente le conosca.
- **I permessi si verificano prima di partire**, con una prova semplice: si prendono tre utenti di reparti diversi e si fanno le stesse dieci domande "sensibili". Se qualcuno vede qualcosa che non dovrebbe, il problema è nei permessi delle cartelle, non nell'assistente: va sistemato lì.
- **Il registro tiene traccia** di quali documenti sono stati usati per rispondere a quale utente (senza registrare il contenuto delle conversazioni), così che si possa ricostruire cosa è successo se nasce un dubbio.

Spesso il progetto del ChatGPT interno diventa, di fatto, il progetto che **finalmente mette in ordine i permessi delle cartelle**. È un effetto collaterale ottimo.

## Costi: 5 / 25 / 80 persone (stime)

Ecco tre scenari, con stime indicative. I prezzi di modelli e hardware cambiano rapidamente: usa le cifre come ordine di grandezza.

| Voce (stime) | 5 persone | 25 persone | 80 persone |
|---|---|---|---|
| Soluzione consigliata | Cloud UE con contratto + indice su server piccolo | Server UE o in ufficio per il modello, indice interno | Server in ufficio (o dedicato UE) con GPU, indice interno |
| Setup iniziale (progetto, fonti, permessi, interfaccia) | 3.000–6.000 € | 8.000–15.000 € | 15.000–30.000 € |
| Hardware (se in ufficio) | — | 3.000–5.000 € (opzionale) | 6.000–12.000 € |
| Costo mensile (modello cloud o server noleggiato + energia) | 50–150 €/mese | 150–500 €/mese | 300–900 €/mese |
| Manutenzione e aggiornamento fonti | 0,5 giorni/mese | 1–2 giorni/mese | 2–4 giorni/mese |
| Confronto: licenze di assistenti integrati nelle suite | ~150 €/mese | ~750 €/mese | ~2.400 €/mese |

(Il confronto con le licenze usa circa 30 € per utente al mese, a titolo indicativo; verifica i listini attuali.)

Due osservazioni:

- **Sotto le 10 persone**, il progetto completo con lo strato 2 si giustifica solo se i documenti sono tanti e cercati spesso. Altrimenti basta lo strato 1 con un contratto serio, più una buona organizzazione delle cartelle.
- **Il costo vero non è il modello**: è il lavoro sulle fonti (pulizia, responsabili, permessi). È anche quello che resta di valore se un giorno cambi tecnologia.

## Le 10 regole di utilizzo

Da consegnare a tutti, in una pagina.

1. **Per il lavoro usa l'assistente aziendale**, non account personali di ChatGPT o simili.
2. **Sulle domande aziendali, guarda sempre la fonte** citata. Se non c'è una fonte, la risposta non è affidabile.
3. **Se la fonte è vecchia o sbagliata, segnalalo** al responsabile del documento: è così che l'assistente migliora.
4. **Non chiedere numeri che stanno nel gestionale** (fatturati, giacenze, scadenze): chiedili al gestionale.
5. **Rileggi tutto ciò che invii all'esterno.** L'assistente scrive bene, ma può sbagliare dettagli con molta sicurezza.
6. **Non inserire password, codici di accesso, dati sanitari** o documenti che non hai il diritto di condividere.
7. **Non usarlo per decisioni sulle persone** (valutazioni, selezione, provvedimenti).
8. **Se vedi un documento che non dovresti vedere, fermati e segnala**: è un problema di permessi da correggere subito.
9. **Le tue conversazioni restano tue**: l'azienda registra solo dati tecnici di utilizzo, non le usa per valutare il tuo lavoro.
10. **Proponi miglioramenti**: documenti da aggiungere, domande frequenti senza risposta, prompt utili per il tuo reparto.

## Piano 60 giorni e change management (il divieto non basta)

Il piano che propongo è in due fasi da 30 giorni. Il punto non è solo installare: è far sì che le persone lo usino al posto degli strumenti personali.

### Giorni 1–30: strato 1 e fonti

- **Settimana 1**: questionario anonimo su come le persone usano oggi l'AI e cosa cercano più spesso nei documenti. Scelta della soluzione (cloud UE, server UE, ufficio).
- **Settimana 2**: attivazione dello strato 1 (chat generica) con login aziendale e contratto in regola. Regole d'uso scritte.
- **Settimana 3**: formazione di 45 minuti per reparto, con casi reali. Inventario delle fonti per lo strato 2: quali cartelle, chi è il responsabile di ciascuna, quali restano fuori.
- **Settimana 4**: pulizia delle fonti del primo perimetro (versioni vecchie archiviate, documenti datati, responsabili assegnati). Verifica dei permessi delle cartelle.

### Giorni 31–60: strato 2 su un perimetro piccolo

- **Settimana 5**: indicizzazione del primo perimetro (per esempio procedure qualità + manuali tecnici). Test dei permessi con utenti di reparti diversi.
- **Settimana 6**: pilota con un reparto. Raccolta delle domande senza risposta e delle risposte con fonte sbagliata.
- **Settimana 7**: correzioni sulle fonti (non sul modello). Estensione a un secondo reparto.
- **Settimana 8**: revisione con i numeri: quante persone lo usano, quali domande, quante risposte con fonte, quante "non ho trovato". Decisione sul perimetro successivo.

### Change management, in tre frasi

- **Il divieto non basta**: senza un'alternativa comoda, le persone continueranno a usare il telefono personale.
- **Mostra un errore dal vivo** durante la formazione: niente convince di più a guardare le fonti.
- **Dai un responsabile a ogni fonte**: senza qualcuno che aggiorna i documenti, dopo tre mesi l'assistente risponde con informazioni vecchie e perde credibilità.

## Un caso concreto: l'ufficio tecnico e i manuali delle macchine

Per rendere tutto meno astratto, ecco come va un primo perimetro reale in un'azienda manifatturiera di 30 persone (lo schema è tipico, i dettagli sono semplificati).

**La situazione di partenza.** L'ufficio tecnico e l'assistenza clienti rispondono ogni giorno a domande sulle macchine vendute: come si fa una certa regolazione, qual è il codice di un ricambio, cosa significa un allarme. Le risposte sono nei manuali (PDF di 200–400 pagine, in italiano e in inglese), in una cartella di note tecniche scritte negli anni, e nella testa di due tecnici anziani. Ogni domanda costa dai 5 ai 20 minuti di ricerca, e spesso finisce con "chiedi a Franco".

**Il perimetro scelto.** Solo i manuali delle macchine in produzione e le note tecniche degli ultimi cinque anni. Fuori: contratti, offerte, documenti amministrativi, email. Accesso: ufficio tecnico e assistenza, 8 persone.

**Il lavoro sulle fonti (2 settimane).** È stato il grosso del progetto. Su 340 file nella cartella dei manuali, 90 erano versioni vecchie o duplicati: archiviati. Le note tecniche avevano titoli come "nota_finale_v3_ok.docx": rinominate con macchina, argomento e data. A ogni cartella è stato assegnato un responsabile, con il compito di segnalare quando esce una nuova versione di un manuale.

**Il pilota (3 settimane).** Le 8 persone hanno usato l'assistente per le domande quotidiane, segnando in un foglio le risposte sbagliate o senza fonte. Nella prima settimana circa una risposta su cinque aveva qualcosa da correggere, quasi sempre per colpa delle fonti: un manuale vecchio rimasto in una sottocartella, una nota che contraddiceva il manuale senza dire quale fosse valida. Corrette le fonti, nella terza settimana le segnalazioni erano scese a poche unità.

**Il risultato.** Le domande "da manuale" trovano risposta con il riferimento alla pagina in meno di un minuto. Le domande che richiedono esperienza continuano ad andare a Franco, ma Franco riceve molte meno interruzioni. E, effetto collaterale non previsto, per la prima volta l'azienda sa quali manuali sono validi.

## Cosa si rompe dopo qualche mese (e come te ne accorgi)

Un assistente sui documenti non si guasta come una stampante: peggiora lentamente. I segnali da guardare:

- **Le risposte citano documenti vecchi.** È il segnale più comune: è uscita una nuova versione di una procedura, ma la vecchia è rimasta nella cartella. Rimedio: il responsabile della fonte archivia la versione superata; l'indice si aggiorna la notte stessa.
- **Aumentano i "non ho trovato documenti".** Le persone fanno domande su argomenti nuovi (un prodotto appena lanciato, una procedura appena cambiata) che non sono ancora documentati. Non è un difetto dell'assistente: è l'elenco dei documenti che mancano. Conviene guardarlo una volta al mese.
- **Le persone smettono di usarlo.** Se l'uso cala dopo i primi mesi, chiedi a cinque persone perché. Le risposte tipiche: è lento, le fonti sono vecchie, non trova le cose del mio reparto. Tutte sistemabili, ma solo se qualcuno chiede.
- **Qualcuno vede qualcosa che non dovrebbe.** Di solito perché una cartella è stata spostata o condivisa in modo diverso. Va trattato subito: si toglie la fonte dall'indice, si sistemano i permessi, si verifica chi può aver visto cosa.
- **Il costo cresce.** Se usi un modello in cloud a consumo e l'uso aumenta, il costo mensile sale. È un buon segnale (le persone lo usano), ma va tenuto d'occhio per decidere se passare a una soluzione con costi fissi.

Mezz'ora al mese del referente su questi cinque punti tiene l'assistente utile. Senza, dopo sei mesi diventa uno strumento di cui le persone non si fidano più.

## 3 errori da principiante che costano soldi o dati

**1. Indicizzare "tutto" al primo colpo.** Si collega l'intero NAS e si dà accesso a tutti. Nelle prime due settimane emergono documenti riservati visibili a chi non dovrebbe, risposte basate su versioni vecchie e domande a cui l'assistente risponde inventando. La fiducia si brucia subito ed è difficile recuperarla.

**2. Scegliere la tecnologia prima di guardare i documenti.** Si compra un server o si sottoscrive un servizio, e solo dopo si scopre che le procedure sono in tre versioni, nessuno sa quale è valida, e metà della conoscenza non è scritta. Il lavoro sulle fonti va fatto comunque: farlo prima fa risparmiare mesi.

**3. Lasciare che l'assistente risponda senza fonte.** Per sembrare più utile, l'assistente viene configurato per rispondere sempre. Risultato: risposte plausibili e sbagliate sulle procedure aziendali, prese per vere. Meglio un "non ho trovato documenti" che una procedura inventata.

## Quando NON farlo

- **Quando i documenti sono pochi e chiari**: con venti procedure ben fatte in una cartella ordinata, una buona ricerca e l'abitudine di usarla bastano.
- **Quando nessuno vuole fare il responsabile delle fonti**: senza manutenzione dei documenti, lo strato 2 peggiora ogni mese.
- **Quando la vera esigenza sono i numeri** (fatturati, giacenze, scadenze): quello è un lavoro per un cruscotto collegato al gestionale, non per una chat.
- **Quando i permessi delle cartelle sono un disastro e non c'è tempo per sistemarli**: parti dallo strato 1 e rimanda lo strato 2.
- **Quando tutti i documenti sono già in una suite con assistente integrato** e i permessi sono ordinati: valuta prima quello, con i suoi costi.

## Checklist pratica

- [ ] Ho distinto i due strati: chat generica per tutti, documenti su un perimetro piccolo.
- [ ] Ho l'elenco delle fonti autorizzate, ognuna con un responsabile.
- [ ] Le cartelle riservate (HR, stipendi, sanitarie, contenziosi) restano fuori dall'indice.
- [ ] I permessi sono stati verificati con utenti di reparti diversi.
- [ ] Il modello gira su infrastruttura UE o interna, con contratto adeguato.
- [ ] L'assistente risponde sulle domande aziendali solo con fonte citata.
- [ ] Le 10 regole sono state consegnate e spiegate.
- [ ] La formazione per reparto è stata fatta con casi reali.
- [ ] Il piano di 60 giorni ha date e responsabili.
- [ ] A 60 giorni c'è una revisione con numeri reali.

## Il verdetto

Un **ChatGPT interno per l'azienda, self-hosted o su infrastruttura europea sotto contratto**, è un progetto alla portata di una PMI, a patto di capire che è fatto di due strati. La chat per scrivere si attiva in giorni e risolve il problema dei dipendenti che usano strumenti personali. L'assistente che risponde sui documenti aziendali è un progetto più serio, e il suo successo dipende meno dal modello e più da tre cose molto concrete: fonti aggiornate con un responsabile, permessi in ordine, e la regola che senza fonte non si risponde.

Fatto così, i documenti non vanno in America, le persone trovano le procedure in trenta secondi invece che chiedendo al collega su WhatsApp, e l'azienda scopre — spesso per la prima volta — dove sta davvero la sua conoscenza e chi la può vedere.

Se vuoi impostare un assistente sui documenti della tua azienda partendo dalle fonti giuste, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su come usare ChatGPT in azienda senza perdere il controllo sono nella guida su [ChatGPT in azienda]({{ '/it/pillar/chatgpt-azienda/' | relative_url }}).

## FAQ

### Cos'è un ChatGPT interno per l'azienda?

È un assistente simile a ChatGPT che gira su infrastruttura dell'azienda o di un fornitore europeo con contratto, a cui si accede con l'account di lavoro. Può limitarsi a scrivere, riassumere e tradurre, oppure rispondere alle domande sui documenti aziendali citando la fonte, senza che i documenti vengano inviati a servizi esterni senza controllo.

### Che differenza c'è tra chat generica e assistente sui documenti?

La chat generica lavora solo su ciò che l'utente incolla o carica nella conversazione. L'assistente sui documenti cerca nei documenti aziendali autorizzati, trova i passaggi pertinenti e risponde citando la fonte. Il primo si attiva in pochi giorni; il secondo richiede un lavoro su fonti, aggiornamento e permessi.

### I documenti aziendali vengono mandati all'estero?

Non se il modello e l'indice dei documenti girano su un server dell'azienda, su un server in un datacenter italiano o europeo, o presso un fornitore europeo con contratto che esclude l'addestramento sui dati. I documenti restano nelle loro cartelle; il sistema ne legge una copia per la ricerca.

### Come si evita che un dipendente veda documenti riservati tramite l'assistente?

L'assistente deve usare solo i documenti che l'utente può già vedere nelle cartelle originali, ereditandone i permessi. Le cartelle riservate, come HR e stipendi, devono restare fuori dall'indice. Prima di partire si verificano i permessi facendo le stesse domande con utenti di reparti diversi.

### Cosa non deve fare un ChatGPT aziendale?

Non deve dare pareri legali, fiscali o medici, non deve fornire numeri che stanno nel gestionale senza poterli citare, non deve inventare procedure che non sono scritte e non deve essere usato per decisioni sulle persone. Sulle domande aziendali deve rispondere solo se trova una fonte, e mostrarla.

### Quanto costa un ChatGPT interno per una PMI?

Indicativamente da 3.000 a 6.000 euro di setup per 5 persone, da 8.000 a 15.000 per 25 persone e da 15.000 a 30.000 per 80 persone, più costi mensili da qualche decina a qualche centinaio di euro e una manutenzione delle fonti da mezza giornata a qualche giorno al mese. L'hardware in ufficio è un'opzione per le aziende più grandi.

### Meglio un server in ufficio o un servizio cloud europeo?

Per le aziende piccole e senza IT interno, il cloud europeo con contratto o un server noleggiato in UE sono di solito più semplici. Il server in ufficio dà il massimo controllo e costi fissi, ma richiede un investimento iniziale, uno spazio adatto e qualcuno che lo gestisca: ha senso dalle 20–30 persone in su.

### È un'alternativa a Copilot di Microsoft 365?

Può esserlo. Copilot lavora sui documenti già presenti nella suite, con i permessi della suite, e si paga per utente. Un assistente interno può lavorare su fonti diverse (NAS, gestionale) con i dati sotto il tuo controllo. In entrambi i casi, la qualità delle risposte dipende dall'ordine dei documenti e dei permessi.

### Quanto tempo serve per avere un ChatGPT interno funzionante?

La chat generica si attiva in pochi giorni o poche settimane. L'assistente sui documenti richiede in genere 60 giorni per un primo perimetro: un mese per sistemare fonti e permessi, un mese per il pilota e le correzioni. Estendere a tutta l'azienda è un lavoro progressivo, reparto per reparto.

### Come si convince il personale a usarlo invece di ChatGPT sul telefono?

Rendendolo comodo quanto ChatGPT, con login aziendale e senza passaggi in più; facendo una formazione breve con casi reali del reparto; mostrando dal vivo un errore per spiegare perché guardare le fonti; e mantenendo la promessa che le conversazioni non servono a controllare le persone. Il divieto da solo non funziona.
