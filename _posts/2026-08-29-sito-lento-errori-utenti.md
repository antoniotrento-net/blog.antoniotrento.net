---
lang: it
permalink: /it/blog/sito-lento-errori-utenti/
alt_url: /en/blog/slow-site-user-errors/
title: "Il sito è bello e al secondo click si rompe: perché i clienti se ne vanno (e non è «un problema di hosting»)"
date: 2026-08-29 07:30:00 +0200
author: "Antonio Trento"
description: "Il sito è bello, ma quando l'utente prova a fare login, riempire il carrello, prenotare o pagare, si rompe: timeout, doppi invii, dati spariti. Non è l'hosting: è frontend e backend disallineati. Ecco come si misura, e quando riparare o rifare."
keywords: ["sito lento errori utenti", "ux che perde clienti", "frontend backend disallineati", "app instabile", "conversione sito rotto"]
image: /assets/images/posts/sito-lento-errori-utenti.jpg
pillar: web-prodotto
related: [/it/blog/sito-vetrina-vs-prodotto-digitale/, /it/blog/portale-b2b-clienti/]
---

## Il secondo click: dove i clienti se ne vanno

Il tuo sito è bello. Si apre veloce, le foto sono curate, la home fa la sua figura. Il primo click va liscio. È il **secondo** click il problema — quello dove l'utente prova a *fare* qualcosa: accedere alla sua area, riempire il carrello, prenotare uno slot, completare un pagamento. Lì il sito bello si inceppa: gira all'infinito, dà un errore incomprensibile, "si è verificato un problema, riprova più tardi", oppure sembra funzionare ma il dato che hai inserito è sparito. E l'utente, che era pronto a comprare o a registrarsi, se ne va. Non torna, e non ti dice perché.

Questo è il buco che ti costa più di tutti e che non vedi, perché avviene in silenzio: nessuno ti scrive "ho abbandonato il carrello perché il pulsante paga girava a vuoto". Semplicemente, la **conversione** è più bassa di quanto dovrebbe, e tu non sai perché. La tentazione è dire "è un problema di hosting, mettiamo un server più veloce". Quasi mai è così. Il problema, nella stragrande maggioranza dei casi, è che **il sito è bello ma non funzionante** — la facciata è curata, ma sotto, nel momento in cui deve fare qualcosa di reale, si rompe.

Questo articolo è per chi ha un sito o un'applicazione che perde clienti al secondo click e non capisce perché. Non è un tutorial su come ottimizzare i punteggi di velocità (quello è un altro discorso). È su dove si perde davvero la **conversione**: nei punti in cui l'utente agisce e il sistema lo tradisce. Vediamo i sintomi veri (timeout, doppi invii, dati spariti), perché nascono da **frontend e backend disallineati**, perché avere tre fornitori e nessun padrone garantisce il disastro, e cosa misurare prima di buttare via tutto e ridisegnare.

## Bello ≠ funzionante

Partiamo da un equivoco che costa caro: **bello non vuol dire funzionante.** Sono due cose diverse, fatte da competenze diverse, e un sito può essere splendido e rotto allo stesso tempo. La bellezza è la superficie: il design, i colori, le animazioni, l'aspetto. Il funzionamento è sotto: cosa succede quando l'utente clicca "paga", se il dato si salva, se l'azione va a buon fine, se il sistema regge quando più persone lo usano insieme.

Il problema è che la bellezza si vede subito (basta un'occhiata alla home) e il funzionamento no — emerge solo quando qualcuno prova a *usare* il sito davvero, al secondo click. Così è facile essere contenti di un sito appena consegnato ("che bello!") e scoprire mesi dopo, guardando i numeri, che converte male perché nei punti d'azione si rompe. Il bello ti ha ingannato: hai valutato la facciata e non il motore.

È la stessa distinzione tra [un sito vetrina e un prodotto che tiene lo stato]({{ '/it/blog/sito-vetrina-vs-prodotto-digitale/' | relative_url }}), ma qui c'è un'aggravante: qui il sito *dovrebbe* funzionare (ha un carrello, un login, un pagamento), solo che lo fa male. Non è che manca il motore: è che il motore è montato male, e si spegne nelle curve. E ogni volta che si spegne, un cliente che stava per convertire se ne va. La bellezza senza il funzionamento, quando c'è un'azione da compiere, non è un mezzo successo: è un fallimento ben vestito.

## I sintomi: timeout, doppi invii, dati spariti

Diamo un nome ai sintomi, perché riconoscerli è il primo passo per capire che non è "l'hosting" ma qualcosa di più profondo. Questi sono i segnali che il tuo sito perde clienti nei punti d'azione:

- **Timeout e caricamenti infiniti.** L'utente clicca "paga" o "invia" e la rotellina gira, gira, gira. Dopo dieci secondi (un'eternità, online) o si arrende o riclicca — creando altri problemi. Il timeout nei punti d'azione è spesso segno di un backend che non regge o di una comunicazione mal fatta tra frontend e backend, non di un server lento in generale.
- **Doppi invii.** L'utente clicca "conferma ordine", non succede niente di visibile, riclicca, e si ritrova con due ordini (o due addebiti). È un classico di un sistema che non gestisce bene lo stato: il frontend non dice all'utente "sto lavorando, aspetta", e il backend non si protegge dai click ripetuti. Risultato: clienti arrabbiati e rimborsi.
- **Dati spariti.** L'utente compila un modulo lungo, clicca invia, e "si è verificato un errore" — e tutto quello che aveva scritto è perso. Deve ricominciare, e la seconda volta spesso non lo fa: se ne va. Il dato sparito è la frustrazione che converte peggio in assoluto.
- **Errori incomprensibili.** "Errore 500", "qualcosa è andato storto", una pagina bianca. L'utente non capisce, non sa cosa fare, e nel dubbio abbandona. Un errore non gestito è un cliente perso.
- **Funziona a me, non a te.** Il sito va bene sul tuo computer e si rompe su un altro dispositivo, un altro browser, una connessione più lenta. È instabilità: il sistema non è robusto alle condizioni reali, che sono varie.

Nota che nessuno di questi è "il sito è lento a caricare la home". Sono tutti nel momento dell'**azione**, ed è lì che si perde la conversione. Un utente perdona una home un po' lenta; non perdona un pagamento che gira a vuoto o un ordine addebitato due volte.

## Il conto: quanto vale la conversione persa

Mettiamo dei numeri, perché "perdi clienti al secondo click" resta astratto finché non lo colleghi ai soldi — e la conversione persa è tra le voci più costose e più invisibili che esistano. Facciamo un esempio, come sempre dichiarato come stima ma facile da rifare sul tuo caso.

Diciamo che il tuo sito riceve 10.000 visite al mese di persone potenzialmente interessate, e che di queste una buona parte arriva fino al punto d'azione (carrello, prenotazione, registrazione). Se anche solo il **10% di chi ci prova si perde** per un timeout, un doppio invio, un errore, un dato sparito, e se ogni conversione vale, poniamo, 50 €, il conto è impietoso: sono clienti persi ogni mese non per il prodotto o il prezzo, ma perché il sistema li ha traditi nel momento in cui volevano darti i soldi.

| Voce | Esempio |
|---|---|
| Utenti che arrivano al punto d'azione / mese | 2.000 |
| Quota che si perde per errori tecnici | ~10% = 200 |
| Valore medio di una conversione | 50 € |
| **Perso al mese** | **~10.000 €** |
| **Perso all'anno** | **~120.000 €** |

Cambia i numeri sui tuoi, ma il punto resta: la conversione persa per problemi tecnici è un buco che spesso vale più di quanto costerebbe ripararlo molte volte. Ed è particolarmente doloroso perché sono clienti **già convinti** — avevano deciso di comprare, prenotare, registrarsi — persi sull'ultimo metro. Recuperare anche solo metà di quel buco, riparando i due-tre punti che perdono di più, ha un ritorno immediato e misurabile. È il motivo per cui vale la pena misurare e intervenire, invece di considerare "fisiologica" una conversione bassa.

## Non è l'hosting: è frontend e backend disallineati

Ora la causa vera, quella che sta sotto quasi tutti quei sintomi: **frontend e backend disallineati.** Un'applicazione web è fatta di due metà che devono lavorare insieme. Il **frontend** è quello che l'utente vede e tocca (le schermate, i pulsanti, i moduli). Il **backend** è quello che sta dietro (la logica, i dati, i pagamenti). Quando l'utente clicca "paga", il frontend deve parlare col backend, il backend deve fare il suo lavoro, e i due devono coordinarsi bene — anche quando qualcosa va storto o ci mette tempo.

Quando queste due metà sono state fatte male o da persone che non si sono parlate, si disallineano, ed è lì che nascono i sintomi. Il frontend manda una richiesta e non gestisce l'attesa (rotellina infinita). Il backend è lento o si inceppa e il frontend non lo sa (timeout). L'utente riclicca perché il frontend non gli ha detto "aspetta" e il backend non si protegge (doppi invii). Il backend dà errore e il frontend non lo gestisce con grazia (dati persi, pagina bianca). Non è un problema di *quanto è potente il server*: è un problema di *come le due metà comunicano e gestiscono i casi non ideali* — l'attesa, l'errore, il click ripetuto.

Ecco perché "mettiamo un hosting più veloce" quasi mai risolve: il server più potente fa caricare la home un pelo prima, ma non sistema il coordinamento rotto tra frontend e backend nel momento del pagamento. Stai curando il sintomo sbagliato. Il vero lavoro è sull'**app instabile**: rendere robusta la comunicazione tra le due metà, gestire l'attesa, gli errori, i click ripetuti — tutto ciò che nel mondo reale (connessioni ballerine, utenti impazienti, casi limite) succede e che una demo su un computer veloce non mostra mai. È lo stesso rigore che serve sotto [un checkout o un portale che deve tenere lo stato]({{ '/it/blog/portale-b2b-clienti/' | relative_url }}): il momento dell'azione è sacro, e va costruito perché non si rompa.

## Tre fornitori e nessun padrone

C'è un motivo organizzativo, dietro il disallineamento tecnico, ed è quasi sempre lo stesso: **tre fornitori e nessun padrone.** Il sito è nato così: un'agenzia (o un freelance) ha fatto la **grafica**, qualcun altro l'ha messa su **WordPress** con un tema e dei plugin, e poi "lo sviluppatore" ha appiccicato le funzioni che servivano (il carrello, il booking, il pagamento) con altri plugin o pezzi di codice. Tre mani diverse, in momenti diversi, senza che nessuno avesse in testa il sistema *intero*.

Il risultato è prevedibile: nessuno è padrone del funzionamento. Quando al secondo click si rompe, chiami l'agenzia della grafica e ti dice "è un problema di sviluppo"; chiami lo sviluppatore e ti dice "è un plugin"; chiami chi ha messo su WordPress e ti dice "è l'hosting". Ognuno ha ragione sul suo pezzo e nessuno si prende la responsabilità del tutto, perché il tutto non è di nessuno. Tu, in mezzo, hai un sito che perde clienti e un cerchio di fornitori che si rimpallano la colpa. È lo stesso problema della [mano sola contro i fornitori scollegati]({{ '/it/pillar/web-prodotto/' | relative_url }}) che è il filo di tutto ciò che scrivo: quando frontend, backend e infrastruttura sono di tre soggetti diversi, il disallineamento non è un incidente, è la conseguenza inevitabile.

La soluzione organizzativa è avere **un unico responsabile tecnico** del funzionamento: qualcuno che possiede il sistema intero — frontend, backend, come comunicano, come gestiscono gli errori — e a cui puoi dire "il pagamento si rompe" avendo una sola persona che risponde, invece di tre che si accusano. Non serve che una persona faccia tutto da sola, serve che *qualcuno sia responsabile del tutto*. Senza quel responsabile unico, ogni riparazione è una guerra di rimpalli e il sito resta rotto.

## Cosa si misura prima di ridisegnare

L'errore che tanti fanno quando il sito converte male è: "rifacciamolo, più bello". Ma se non sai *dove* si perde la conversione, rischi di rifare bello un sito che si romperà negli stessi punti, spendendo per il problema sbagliato. Prima di ridisegnare o rifare qualsiasi cosa, si **misura**. Non i punteggi di velocità astratti: si misura dove gli utenti veri si perdono.

Due cose vanno guardate. Il **funnel**: il percorso che l'utente fa per convertire (arriva → guarda → mette nel carrello → login → paga), con quante persone passano da ogni passo al successivo. È qui che vedi il buco: se il 40% arriva al carrello e solo il 5% completa il pagamento, il problema è tra carrello e pagamento — quello è il punto da guardare, non la home. Il funnel ti dice *dove* si perdono i clienti, in modo oggettivo, invece che a sensazione.

E gli **errori**: quanti e quali errori tecnici capitano agli utenti veri, in quei punti. Non "a me funziona", ma quanti utenti, sui loro dispositivi e connessioni reali, incontrano un timeout, un errore, un doppio invio. Questi dati esistono o si possono raccogliere, e trasformano il "mi sembra che si rompa a volte" in "il 12% degli utenti che clicca paga riceve un errore". Con il funnel e gli errori in mano, sai esattamente cosa aggiustare — e scopri quasi sempre che non serve rifare tutto, ma sistemare i due o tre punti dove si perde il grosso. Misurare prima di ridisegnare è ciò che ti evita di spendere per il problema sbagliato, lo stesso principio del [misurare dove si perde prima di intervenire]({{ '/it/blog/cruscotto-aziendale-titolare/' | relative_url }}) che vale ovunque.

## Riparare vs rifare

Con i dati in mano, la decisione diventa concreta: si ripara o si rifà? Dipende, e va deciso sui numeri, non d'impulso.

**Riparare** ha senso quando i problemi sono localizzati: due o tre punti d'azione che si rompono (il pagamento, il login, un modulo), su una base per il resto sana. In quel caso si sistemano quei punti — si rende robusta la comunicazione frontend-backend lì, si gestiscono attesa ed errori, si tolgono i doppi invii — e la conversione risale senza rifare tutto. È più veloce, costa meno, e spesso è la risposta giusta. Molti "il sito converte male" si risolvono riparando i pochi punti che perdono il grosso dei clienti.

**Rifare** ha senso quando la base è marcia: un accrocco di plugin che si rompono a vicenda, un sistema così fragile e disallineato che ogni riparazione ne rompe un'altra, nessuno che lo capisce, impossibile da far evolvere. In quel caso rattoppare è buttare soldi in un pozzo, e conviene ricostruire su basi sane — semmai tenendo la grafica se è buona, ma rifacendo il sotto perché funzioni. È l'analisi riparare-vs-rifare che vale per [ogni sistema legacy fragile]({{ '/it/blog/riscrivere-software-gestionale-legacy/' | relative_url }}): se i rattoppi costano più del rifare e si rompono a catena, la base è il problema.

La regola: **misura prima, decidi dopo.** Se il buco è in due-tre punti su una base sana, ripara. Se la base è un castello di carte, rifai. Chi ti dice "rifacciamo tutto" senza aver misurato dove si perde, o "basta un ritocco" senza guardare la base, sta indovinando — e con i tuoi soldi.

## L'audit di una settimana

Come si parte, in pratica, senza impegnarsi subito in un rifacimento? Con un **audit di una settimana**: un intervento breve e delimitato che ti dà la diagnosi prima della cura. In pochi giorni, chi sa guardare un sistema web può dirti dove stai perdendo i clienti e perché, e se serve riparare o rifare.

Cosa produce un audit fatto bene? La **mappa del funnel** con i buchi (dove gli utenti si perdono, con i numeri). L'elenco degli **errori** che gli utenti veri incontrano nei punti d'azione. Una diagnosi del **perché** (frontend e backend disallineati? plugin in conflitto? backend che non regge?). E una **raccomandazione onesta**: cosa riparare subito (i due-tre punti che perdono di più), cosa può aspettare, se la base regge o va rifatta, con forchette di costo. Una settimana di lavoro che ti fa spendere bene i soldi dopo, invece di rifare al buio.

Quando cerchi chi te lo fa, il segnale giusto è che parta dai **dati** (voglio vedere il funnel, gli errori, dove si perde) e non dall'estetica ("rifacciamo il design"). Chi guarda dove si perdono i clienti prima di proporti una cura sta facendo il tuo interesse; chi ti propone di rifare tutto bello prima di aver misurato sta vendendo un progetto, non risolvendo il tuo problema di conversione.

## Un caso tipo: il carrello che perdeva i clienti

Un profilo tipico, architetturale, senza nomi. Un'attività con un sito curato — davvero bello, fatto da una brava agenzia di design — vedeva una conversione molto più bassa delle attese. Sospettava l'hosting e stava per cambiarlo. Il sito era nato dai soliti tre pezzi: grafica da un'agenzia, messa su una piattaforma con plugin, e le funzioni di vendita appiccicate da uno sviluppatore esterno. Nessuno era padrone del funzionamento intero.

Cosa si è fatto. Prima si è misurato invece di rifare: si è guardato il funnel e sono emersi i buchi veri — una quota rilevante di utenti arrivava al pagamento e non completava. Guardando gli errori reali, si è visto che nel momento del pagamento il frontend e il backend si disallineavano: su connessioni lente il pulsante girava a vuoto, alcuni utenti riccliccavano generando doppi ordini, altri ricevevano un errore e abbandonavano con il carrello perso. Non era l'hosting: era il coordinamento rotto nel punto d'azione.

Cosa si è deciso: riparare, non rifare, perché la base per il resto era sana e i problemi erano localizzati nel checkout. Si sono sistemati quei punti — gestione dell'attesa (l'utente vede "sto elaborando" e non riclicca), protezione dai doppi invii, gestione pulita degli errori senza perdere i dati. La conversione è risalita senza rifare il sito. E si è messo un unico responsabile tecnico del funzionamento, così il prossimo problema avrebbe avuto una persona che risponde invece di tre che si accusano. La nota onesta: non serviva il sito nuovo che stavano per commissionare — serviva misurare dove si perdevano i clienti e riparare i due punti giusti.

## È per te se / non è per te se

**È per te se:** hai un sito o un'app bella che converte male e non capisci perché; gli utenti si perdono nei punti d'azione (login, carrello, prenotazione, pagamento) con timeout, doppi invii, dati persi; hai tre fornitori che si rimpallano la colpa e nessuno padrone del funzionamento; stai per "rifare tutto più bello" senza aver misurato dove si perde davvero; sospetti l'hosting ma il problema si manifesta solo quando l'utente agisce.

**Non è per te se:** il tuo è davvero solo un sito vetrina senza azioni da compiere (allora non c'è un funnel da riparare, semmai un discorso diverso); il problema è davvero e solo di velocità di caricamento generale (raro, ma esiste, e si affronta diversamente); non sei disposto a misurare prima di decidere e vuoi rifare tutto d'istinto — perché senza misurare, rischi di rifare bello un sito che si romperà negli stessi punti.

## Domande frequenti

**Il sito è lento: non basta un hosting migliore?**
Quasi mai. Un hosting più potente fa caricare la home un po' prima, ma non sistema i sintomi veri — timeout al pagamento, doppi invii, dati persi — che nascono da frontend e backend disallineati, non dalla potenza del server. Stai curando il sintomo sbagliato. Il lavoro è sul coordinamento tra le due metà nei punti d'azione, non sull'hardware.

**Perché il sito è bello ma converte male?**
Perché bello e funzionante sono due cose diverse. La bellezza si vede subito (la home), il funzionamento emerge solo quando l'utente prova a fare qualcosa (il secondo click). Un sito può essere splendido e rompersi nel momento del pagamento. Hai valutato la facciata; il motore, montato male, si spegne nelle curve — e lì perdi i clienti.

**Cosa sono i "doppi invii"?**
Quando l'utente clicca "conferma", non vede succedere niente, riclicca, e si ritrova con due ordini o due addebiti. Nasce da un sistema che non gestisce lo stato: il frontend non dice "sto lavorando, aspetta" e il backend non si protegge dai click ripetuti. Genera clienti arrabbiati e rimborsi, ed è uno dei sintomi più comuni di frontend e backend disallineati.

**Perché ho tre fornitori che si danno la colpa?**
Perché il sito è nato a pezzi: grafica da uno, piattaforma e plugin da un altro, funzioni appiccicate da un terzo, senza che nessuno avesse in testa il sistema intero. Quando si rompe, ognuno ha ragione sul suo pezzo e nessuno è responsabile del tutto. Serve un unico responsabile tecnico del funzionamento, o ogni riparazione è una guerra di rimpalli.

**Devo rifare il sito?**
Non prima di aver misurato. Se il buco è in due-tre punti d'azione su una base sana, si ripara (più veloce, meno caro, spesso risolutivo). Se la base è un accrocco di plugin che si rompono a vicenda e nessuno capisce, si rifà. La decisione va presa sui dati (funnel, errori), non d'impulso: rifare bello un sito senza sapere dove si perde rischia di riprodurre gli stessi problemi.

**Cosa si misura, di preciso?**
Il funnel (quante persone passano da ogni passo al successivo: arriva, carrello, login, paga) per vedere *dove* si perdono; e gli errori tecnici che gli utenti veri incontrano in quei punti (quanti timeout, doppi invii, errori, sui loro dispositivi e connessioni). Insieme trasformano il "mi sembra si rompa" in "il 12% di chi clicca paga riceve un errore" — e ti dicono esattamente cosa aggiustare.

**Cos'è un audit di una settimana?**
Un intervento breve che ti dà la diagnosi prima della cura: la mappa del funnel con i buchi, l'elenco degli errori reali, il perché tecnico, e una raccomandazione onesta (cosa riparare subito, se la base regge o va rifatta, con forchette di costo). Una settimana per spendere bene i soldi dopo, invece di rifare al buio. Cerca chi parte dai dati, non dall'estetica.

**Quanto costa riparare rispetto a rifare?**
Riparare i punti che perdono di più è molto meno caro che rifare, ed è spesso sufficiente. Rifare ha senso solo se la base è marcia. Il modo di deciderlo è l'audit: se i problemi sono localizzati su una base sana, si ripara; se sono strutturali, si rifà. Chi ti dà un preventivo di rifacimento senza aver misurato dove si perde sta indovinando con i tuoi soldi.

## In una riga

Se il tuo sito è **bello e al secondo click si rompe** — timeout, doppi invii, dati spariti quando l'utente fa login, riempie il carrello, prenota o paga — stai perdendo clienti in silenzio, e non è "un problema di hosting": è **frontend e backend disallineati**, quasi sempre figli di tre fornitori e nessun padrone. Prima di rifare tutto più bello, **misura**: il funnel (dove si perdono) e gli errori reali (perché). Con i dati, decidi se riparare i due-tre punti giusti (spesso basta) o rifare la base (se è marcia). E metti un unico responsabile tecnico del funzionamento, o resterai nel rimpallo delle colpe.

Se il tuo sito converte male e vuoi sapere dove perdi i clienti prima di spendere per rifarlo, guarda i [progetti che ho costruito]({{ site.main_site }}/portfolio/) o [scrivimi due righe]({{ site.main_site }}/contatti/): partiamo da un audit del tuo funnel e degli errori veri, non da un preventivo di restyling al buio.
