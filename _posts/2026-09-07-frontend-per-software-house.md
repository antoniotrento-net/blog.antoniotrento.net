---
lang: it
permalink: /it/blog/frontend-per-software-house/
alt_url: /en/blog/frontend-for-software-houses/
title: "Software house senza frontend: stai consegnando API e il cliente vede un deserto. Perché ti serve qualcuno che chiude il prodotto"
date: 2026-09-07 07:30:00 +0200
author: "Antonio Trento"
description: "Il backend è solido, le API funzionano, ma il cliente apre lo schermo e non sa dove cliccare. Il prodotto è la faccia: senza un frontend serio, stai consegnando un motore senza macchina."
keywords: ["frontend per software house", "ui ux per backend team", "consegnare prodotto completo", "app interfaccia cliente", "partnership sviluppo"]
image: /assets/images/posts/frontend-per-software-house.jpg
pillar: web-prodotto
related: [/it/blog/sito-vetrina-vs-prodotto-digitale/, /it/blog/lanciare-prodotto-ai-white-label/]
---

## L'API "è pronta" e il cliente non sa dove cliccare

C'è una scena che conosci se hai una software house o un team che vive di backend. Il progetto è tecnicamente finito. Le API sono documentate, testate, veloci. Gli endpoint fanno esattamente quello che devono. Il team è orgoglioso, e ha ragione: sotto il cofano c'è un motore serio. Poi arriva il momento della demo al cliente, qualcuno apre lo schermo, e cala il gelo. Il cliente guarda, non capisce dove cliccare, chiede "ma... è questo?", e nella sua testa si forma un pensiero che tu non senti ma che vale il contratto: *"ho pagato per un deserto."*

Non è colpa del cliente. È che il cliente **non compra le API**. Non le vede, non le tocca, non sa nemmeno cosa siano. Il cliente compra la cosa che apre sullo schermo e usa. Per lui, il prodotto *è* l'interfaccia — e se l'interfaccia è quattro campi buttati su una pagina, un menù grezzo, delle tabelle spoglie con scritto "loading..." che non finisce mai, allora per lui il prodotto è *quello*. Tutto il lavoro sotto, la solidità dell'architettura, l'eleganza del backend: invisibile. Non esiste. Il cliente giudica quello che vede, e quello che vede è un deserto.

Questa è la ferita silenziosa di tante software house brave: **motore da corsa, carrozzeria mancante**. E il paradosso è che spesso il team lo *sa*, ma non ha né le persone né la testa per chiudere quel pezzo — perché fare frontend serio non è "mettere un po' di CSS sopra", è una disciplina diversa, e chiedere a un ottimo backend developer di farlo di malavoglia produce quello che produce sempre: qualcosa che tecnicamente c'è ma che nessuno userebbe.

Scrivo questo pezzo per chi sta da questo lato: hai il backend, ti manca la faccia, e ogni volta al momento di consegnare senti che il valore che hai costruito non arriva al cliente perché si perde nell'ultimo miglio. Parliamo di cos'è davvero il frontend che manca, perché non è il lavoro che credi, e come si lavora in due — il tuo team sul motore, qualcuno sulla carrozzeria — senza passare le giornate a rimpallarsi le colpe.

## Il prodotto è il contratto visibile

Partiamo da una definizione, perché è il fraintendimento alla radice di tutto: **il prodotto è la parte visibile del contratto tra te e il cliente.** È il posto dove tutto il valore che hai costruito diventa qualcosa che una persona può vedere, capire e usare. Se resta invisibile, per il cliente non è stato costruito.

Pensa a cosa vende davvero il tuo lavoro. Non vendi "endpoint REST". Vendi la promessa che il cliente potrà fare una certa cosa — gestire i suoi ordini, vedere i suoi dati, far lavorare i suoi utenti. Quella promessa il cliente la può verificare in un solo posto: l'interfaccia. Il frontend è dove il contratto diventa **visibile e verificabile**. È lì che il cliente dice "sì, fa quello che mi avevi detto" oppure "non capisco, non funziona, mi avete fregato". Non c'è appello: qualunque cosa ci sia sotto, il verdetto si emette guardando la faccia.

Questo ha una conseguenza che i team backend faticano ad accettare: **il frontend non è la fase finale opzionale, è dove nasce o muore il valore percepito.** Puoi avere il backend più elegante del mondo, ma se il cliente non riesce a usarlo, per lui vale zero — anzi, meno di zero, perché ha pagato e non ottiene. Al contrario, un backend anche modesto ma vestito da un prodotto chiaro e usabile, per il cliente vale molto, perché *ottiene quello che voleva*. Il valore percepito non segue la qualità del codice: segue la qualità dell'esperienza.

È la stessa distinzione che faccio parlando di [sito vetrina contro prodotto digitale]({{ '/it/blog/sito-vetrina-vs-prodotto-digitale/' | relative_url }}), rovesciata: lì il problema è chi ha solo la vetrina e non il motore; qui è chi ha il motore e non la faccia. Sono i due lati dello stesso errore — pensare che il prodotto sia solo metà di sé stesso. Un prodotto è *sia* il motore *sia* la faccia, e chi ne consegna solo metà consegna qualcosa che il cliente non può usare né apprezzare.

## Cosa fa davvero un frontend serio (e perché non è "un po' di CSS")

Qui sta il malinteso che rovina i progetti. Chi non fa frontend pensa che sia "far vedere i dati": prendi la risposta dell'API, la metti in una tabella, aggiungi due colori, fatto. Se fosse questo, avresti ragione a trattarlo come un dettaglio. Ma un frontend *serio* — quello che fa la differenza tra "il cliente ci lavora contento" e "il cliente si lamenta ogni giorno" — è fatto soprattutto delle cose che **non** sono il caso ideale. È fatto degli stati.

Un'interfaccia vera deve gestire, per ogni singola cosa che mostra:

- **Lo stato di caricamento.** Cosa vede l'utente *mentre* l'API risponde? Se vede una pagina bianca o un blocco fermo, pensa che sia rotto. Un frontend serio mostra che sta lavorando, in modo che l'attesa sia sopportabile e chiara.
- **Lo stato di errore.** L'API risponde male, la rete cade, il permesso manca. Cosa vede l'utente? Se vede "undefined" o una schermata che esplode o il classico "qualcosa è andato storto", hai perso. Un frontend serio traduce l'errore in qualcosa di **comprensibile e azionabile**: cosa è successo, cosa può fare. Questa è la parte dove più spesso il prodotto crolla, ed è esattamente la stessa dinamica che descrivo negli [errori che fanno abbandonare un flusso]({{ '/it/blog/abbandono-prenotazione-carrello/' | relative_url }}): un errore muto è un utente perso.
- **Lo stato vuoto.** Il cliente entra la prima volta e non ha ancora dati. Cosa vede? Se vede una tabella vuota e basta, si sente perso e pensa "non funziona". Un frontend serio usa lo stato vuoto per **guidare**: "non hai ancora nessun ordine, comincia da qui". Lo stato vuoto è il primo momento del cliente col prodotto, ed è dove decide se ci si raccapezza o no. I team backend lo dimenticano *sempre*, perché nei loro test i dati ci sono già.
- **I permessi.** Utenti diversi vedono e possono fare cose diverse. Un frontend serio non mostra bottoni che poi danno errore "non autorizzato": mostra a ciascuno solo quello che può fare, e lo fa in modo coerente in tutta l'app.

Ecco perché "un po' di CSS" è un'illusione. Il caso ideale — dati presenti, API che risponde bene, utente con tutti i permessi — è il 20% del lavoro. L'altro 80% sono gli stati: caricamento, errori, vuoti, permessi, casi limite. È lì che vive l'esperienza vera, ed è lì che un backend developer messo a fare frontend controvoglia taglia gli angoli, perché sono proprio i casi che nei suoi test non vede. Il risultato è un'interfaccia che "funziona nella demo" e crolla il primo giorno vero, quando un utente reale fa la cosa reale che nessuno aveva previsto.

## Design system, non "la pagina bella fatta una volta"

C'è un secondo errore, opposto ma altrettanto costoso: chiamare un grafico o un freelance UI per fare "la pagina bella". Ne esce una schermata curata, magari splendida, consegnata come un'immagine o una pagina isolata. E poi? Poi il prodotto ha altre trenta schermate, e ognuna va fatta da capo, e nessuna assomiglia alle altre, e ogni volta che aggiungi una funzione ricominci a discutere che colore ha il bottone. Hai comprato **un quadro**, non un modo di costruire.

Quello che serve a un prodotto che vive e cresce non è la pagina bella una tantum: è un **design system**. Cioè un insieme coerente di componenti riutilizzabili — come sono fatti i bottoni, i campi, le tabelle, i messaggi di errore, gli stati vuoti — e delle regole per usarli. Con un design system, la trentesima schermata si costruisce in un giorno usando pezzi che già esistono e già funzionano, invece che in una settimana di discussioni. E soprattutto: l'intero prodotto sembra **una cosa sola**, coerente, professionale, invece di un patchwork di pagine fatte in momenti diversi da mani diverse.

La differenza è tra un costo che si ripaga e uno che si ripete. La pagina bella una tantum è un costo che paghi ogni volta, perché non lascia niente dietro di sé. Il design system è un investimento che paghi una volta e che *accelera* tutto quello che viene dopo: ogni nuova funzione costa meno da vestire, ogni nuovo sviluppatore capisce come costruire, ogni schermata è coerente con le altre senza sforzo. Per una software house che consegna prodotti a ripetizione, questa è la differenza tra il frontend come collo di bottiglia perenne e il frontend come macchina che gira.

E — punto che tocca il tuo margine — un design system fatto bene si **riusa tra progetti**. Il modo di gestire tabelle, form, errori che costruisci per un cliente diventa la base per il prossimo. Il che ci porta dritti al perché tutto questo, per te, non è un costo ma una leva commerciale.

## Come si lavora in due team senza passare la giornata a rimpallarsi

La paura legittima, quando pensi di affiancare qualcuno al tuo team per il frontend, è il **rimpallo**. La conosci: "è colpa del frontend che chiama male l'API", "no, è l'API che risponde in modo assurdo", e in mezzo ci sei tu che fai da arbitro mentre il progetto è fermo. Se la collaborazione produce questo, meglio niente. Quindi la domanda vera non è "mi serve un frontend?" ma "**come si lavora in due senza che diventi una guerra di confine?**".

La risposta sta in poche cose, e sono tutte gestibili:

- **Il contratto dell'API è la frontiera, e va scritto.** Il punto dove i due mondi si toccano è la forma dei dati che l'API espone. Se questa forma è chiara, documentata e stabile, i due team lavorano ai due lati del confine senza pestarsi i piedi: il backend garantisce quella forma, il frontend la consuma. Il rimpallo nasce quando il confine è vago o cambia senza avvisare (ne parlo tra poco). Con un contratto chiaro, il 90% dei litigi non nasce nemmeno.
- **Si lavora in parallelo, non in sequenza.** L'errore classico è "prima finiamo il backend, poi chiamiamo il frontend". Così il frontend arriva a cose fatte, scopre problemi tardi, e ogni modifica costa il triplo. Chi fa frontend serio può lavorare *insieme* al backend fin dall'inizio, lavorando su dati finti (mock) che rispettano il contratto concordato, così quando l'API è pronta l'interfaccia è già lì ad aspettarla. E i problemi di design dei dati emergono *prima*, quando costano poco.
- **Qualcuno deve capire entrambi i lati.** Ed è il cuore di tutto. Il rimpallo esplode quando il frontend è uno che "sa solo CSS" e non capisce cosa fa un'API, e il backend è uno che non ha idea di cosa serva al frontend. Quando invece dall'altro lato hai qualcuno che **capisce sia i dati sia l'interfaccia** — che sa leggere il tuo contratto API, che sa dirti "questo dato mi serve in quest'altra forma, e ha senso perché sennò l'utente deve fare tre click", che parla la tua lingua tecnica — allora non c'è arbitro da fare. C'è un dialogo tra pari.

Questo è il punto in cui il mio modo di lavorare fa la differenza rispetto a prendere un freelance UI qualsiasi: io vengo dal fare **dati, backend, frontend e LLM** tutti insieme. Quando mi affianco al tuo team, non sono "il tipo del CSS" che ti tratta l'API come una scatola nera. Capisco cosa c'è sotto, discuto il contratto con te da tecnico, e chiudo la faccia del prodotto sapendo cosa succede dietro. È la stessa logica della **mano sola** che porto ovunque — solo che qui la mano si aggiunge alla tua, non la sostituisce: tu tieni il motore che sai fare benissimo, io chiudo la carrozzeria parlando la tua lingua.

## Se i dati e i contratti API cambiano ogni giorno, l'UI muore

Devo dirti la cosa più scomoda, quella che decide se una collaborazione frontend funziona o si trasforma in un incubo: **se il contratto dell'API cambia in continuazione senza disciplina, nessun frontend può reggere.**

L'interfaccia è costruita *sopra* la forma dei dati che le passi. Se oggi un campo si chiama così, domani cambia nome, dopodomani sparisce e diventa due campi, e nessuno lo dice — l'UI si rompe di continuo, il frontend passa le giornate a rincorrere modifiche invece di costruire, e nasce esattamente quel rimpallo che volevi evitare. Non perché il frontend sia scarso: perché sta costruendo su sabbie mobili. È come chiedere a un carrozziere di finire l'auto mentre gli cambi il telaio ogni mattina.

Questo *non* significa che il backend non può evolvere — ci mancherebbe, evolve sempre. Significa che l'evoluzione va **governata**, e sono cose che sai già fare da software house seria:

- **Il contratto si versiona.** Se una modifica rompe la forma dei dati, non la si cambia sotto i piedi: se ne fa una nuova versione, e il frontend migra quando è pronto. Le rotture annunciate sono gestibili; quelle a sorpresa no.
- **Si comunica il cambiamento.** Anche solo un messaggio: "domani cambia questo endpoint, ecco come". Il frontend si prepara invece di scoprirlo quando tutto esplode in produzione.
- **Si distingue ciò che è stabile da ciò che è in movimento.** Le parti dell'API che il frontend usa tanto vanno tenute ferme; si sperimenta dove non fa danno.

Ti dico questo con franchezza perché è il vero test di compatibilità tra il tuo team e chi fa il frontend. Se il tuo backend è disciplinato sul contratto, la collaborazione vola. Se invece l'API è un cantiere che cambia ogni notte senza regole, allora il problema da risolvere *prima* non è "trovare un frontend": è mettere ordine nel contratto. E chi capisce entrambi i lati te lo dice subito, invece di accettare il lavoro e poi lamentarsi — perché sa che un'UI costruita su un'API caotica è tempo bruciato per entrambi.

## White-label: la faccia diventa la *loro* faccia (e il tuo margine)

Ora la parte che trasforma il frontend da costo a leva di business per una software house. Molti dei tuoi clienti non vogliono solo usare il prodotto: vogliono metterlo davanti ai **loro** clienti, con il **loro** marchio. Vogliono rivendere quello che tu costruisci come se fosse loro. Questo è il **white-label**, ed è oro — ma funziona solo se la faccia del prodotto è fatta per essere ri-marchiata.

Se il frontend è costruito bene — con il design system di cui sopra, con colori, logo e stile che si cambiano da un punto solo — allora lo stesso prodotto può indossare venti facce diverse per venti clienti diversi, senza rifarlo venti volte. Il tuo cliente lo vende come suo, i suoi utenti vedono il suo marchio, e tu dietro hai *un solo prodotto* da mantenere. Questo moltiplica il valore di quello che hai costruito: da "un progetto per un cliente" a "una piattaforma che tanti clienti rivendono". È un modello che cambia i conti di una software house, e lo approfondisco in [lanciare un prodotto AI white-label]({{ '/it/blog/lanciare-prodotto-ai-white-label/' | relative_url }}).

Ma — e qui torna tutto insieme — il white-label è *possibile* solo se il frontend è stato pensato per esserlo fin dall'inizio: componenti coerenti, stile centralizzato, niente colori sparsi a mano nelle trenta schermate. Se invece hai la "pagina bella fatta una volta" con il marchio incollato dentro, il white-label è un rifacimento a ogni cliente, e il modello non sta in piedi. È l'ennesima ragione per cui il frontend serio non è un accessorio da attaccare alla fine: è **infrastruttura di prodotto**, e come è fatto decide quali modelli di business puoi permetterti. Tutto questo vive nel cluster [web e prodotto digitale]({{ '/it/pillar/web-prodotto/' | relative_url }}), perché la faccia di un prodotto non è estetica: è ciò che determina se e come lo puoi vendere.

## La velocità percepita è un lavoro di frontend

C'è un ultimo pezzo che i team backend sottovalutano perché "riguarda la performance, e la performance la facciamo noi": la **velocità percepita**. Ed è, in gran parte, un lavoro di frontend.

Ecco il paradosso che vedo spesso: il backend è velocissimo, le API rispondono in millisecondi, e ciononostante il prodotto *sembra* lento e pesante da usare. Perché? Perché la velocità che conta per il cliente non è quella misurata dal tuo monitoraggio: è quella che **sente col dito**. E quella dipende da come il frontend è costruito.

Un'interfaccia può buttare via tutta la velocità del tuo backend in modi che dal lato server non vedi nemmeno:

- **Carica tutto insieme quando non serve.** Scarica migliaia di righe per mostrarne venti, o tira giù mezzo mondo all'avvio invece di prendere le cose quando servono davvero. Il backend risponde in fretta, ma il browser dell'utente arranca sotto il peso. Un frontend serio prende **solo quello che serve, quando serve**.
- **Non dà mai il senso che sta lavorando.** Tra il click e la risposta, se lo schermo resta fermo e muto, l'utente percepisce lentezza e lag anche quando i dati arrivano in fretta. Un frontend serio reagisce **subito** al gesto — un segnale, un cambiamento immediato — così l'attesa, anche breve, è vissuta come fluida invece che come blocco.
- **Ricarica cose che aveva già.** Se ogni navigazione rifà da capo il lavoro già fatto, il prodotto sembra impantanato. Un frontend serio ricorda quello che ha già, e non fa rifare al server (e all'utente) la stessa fatica due volte.

Il punto è che la velocità è un'esperienza, non solo un numero sul tuo dashboard. Un backend da corsa vestito da un frontend pesante consegna al cliente la sensazione di un'auto lenta — e il cliente giudica la sensazione, non il benchmark. È esattamente il fenomeno che analizzo in [perché un sito lento fa sbagliare gli utenti]({{ '/it/blog/sito-lento-errori-utenti/' | relative_url }}): la lentezza percepita erode la fiducia e fa abbandonare, e gran parte di quella lentezza si guadagna o si perde nell'ultimo miglio, sulla faccia. Buttare via la velocità del tuo motore in una carrozzeria pesante è uno spreco doppio: hai pagato per un backend veloce e lo consegni come se fosse lento.

## Il costo di consegnare "il deserto"

Facciamo i conti dell'inerzia, perché è concreto e lo vivi. Cosa ti costa, davvero, consegnare backend senza una faccia seria?

- **Trattative perse alla demo.** Quante volte un cliente tecnicamente convinto si è raffreddato vedendo l'interfaccia grezza? Ogni contratto perso lì è un progetto intero che se ne va, e la causa non era il tuo lavoro — era l'ultimo miglio non fatto. Un solo deal recuperato all'anno ripaga con abbondanza l'investimento sulla faccia.
- **Ore dei tuoi developer bravi bruciate a fare frontend controvoglia.** I tuoi backend developer costano, e sono bravi a fare backend. Ogni giornata che passano a litigare con il CSS e a fare interfacce che non sanno fare è tempo pagato caro, prodotto male, e sottratto a ciò in cui sono forti. È il peggior uso possibile delle tue risorse migliori.
- **Manutenzione infinita del patchwork.** Un frontend fatto di pagine scollegate, senza design system, è un debito che paghi a ogni modifica: ogni cambiamento tocca dieci punti diversi, ogni funzione nuova costa una discussione. Il costo non è la costruzione, è il **trascinamento** di una cosa fatta senza struttura.
- **Modelli di business che non puoi cogliere.** Niente white-label serio, niente prodotto rivendibile, niente scala. Resti a vendere progetti a ore invece di costruire piattaforme che si moltiplicano.

Sommati, sono cifre che superano di molto il costo di chiudere il prodotto per bene. Il "deserto" non è gratis: lo paghi in deal persi, ore sprecate e crescita che non arriva — solo che non lo vedi in fattura, e per questo lo sottovaluti.

## È per te se / non è per te se

**È per te se:**
- hai una **software house o un team backend** solido e ti manca sistematicamente la faccia del prodotto;
- alle **demo** senti che il valore che hai costruito non arriva al cliente perché l'interfaccia è grezza;
- i tuoi **backend developer** perdono tempo a fare frontend che non è il loro mestiere;
- vuoi offrire ai clienti prodotti **white-label**, rivendibili, ma il frontend attuale non è pensato per esserlo;
- il tuo contratto API è **disciplinato** (o sei disposto a renderlo tale): è la condizione perché la collaborazione funzioni.

**Non è per te se:**
- ti serve solo **una pagina bella una tantum**, una landing isolata: lì basta un grafico, non un partner di prodotto, e te lo dico onesto;
- il tuo backend è un **cantiere che cambia ogni notte senza regole**: prima va messo ordine nel contratto API, altrimenti qualunque frontend è tempo bruciato;
- cerchi qualcuno che tratti l'API come una **scatola nera** e non faccia domande: io le domande le faccio, perché è così che il prodotto viene bene — se vuoi un esecutore muto, non sono la persona giusta.

## Il modello di collaborazione, senza sorprese

Concretamente, come lavoriamo insieme. Non "vi mando un preventivo e sparisco fino alla consegna", ma un modello pensato per due team che devono incastrarsi.

**Prima si allinea il confine.** Guardiamo insieme il contratto delle tue API, cosa espongono, quanto sono stabili. Definiamo la forma dei dati al punto di contatto. Questa fase è tecnica e onesta: se emerge che il contratto va sistemato prima, te lo dico, perché costruirci sopra senza sarebbe uno spreco per entrambi.

**Poi si costruisce in parallelo.** Io lavoro sulla faccia — design system, stati (caricamento, errori, vuoti, permessi), le schermate — mentre il tuo team lavora sul motore, sui dati concordati. Non aspetto che abbiate finito: costruisco sui dati concordati e mi aggancio all'API vera man mano che è pronta. I problemi emergono presto, quando costano poco.

**Il confine resta pulito.** Tu resti il proprietario del backend e del rapporto col cliente. Io chiudo il prodotto. Quando qualcosa non torna, si guarda il contratto: è la frontiera concordata, e dice a chi tocca — senza rimpalli, perché il confine è scritto.

Il modello può essere un progetto singolo ("chiudiamo *questo* prodotto"), una collaborazione ricorrente ("siete il mio frontend per i progetti che lo richiedono"), o la costruzione di un design system riusabile che poi il tuo team porta avanti. Dipende da cosa ti serve, e lo decidiamo guardando i tuoi progetti, non un listino. Se hai un backend che merita una faccia all'altezza, [guarda come lavoro]({{ site.main_site }}/portfolio/) o [scrivimi due righe]({{ site.main_site }}/contatti/) e vediamo se ha senso lavorare insieme.

## 8 domande da chi sta valutando la collaborazione

**1. Non posso far fare il frontend ai miei backend developer?**
Puoi, ma paghi le tue risorse migliori per fare male un lavoro che non è il loro, sottraendole a ciò in cui sono forti. Il frontend serio — stati, errori, vuoti, design system — è una disciplina diversa dal backend, e "un po' di CSS sopra" produce interfacce che crollano al primo utente vero.

**2. Come evitiamo il classico rimpallo frontend-backend?**
Con un contratto API chiaro e versionato come frontiera concordata, lavorando in parallelo invece che in sequenza, e con qualcuno dal lato frontend che capisce davvero i dati e le API — non uno che le tratta da scatola nera. Il rimpallo nasce dal confine vago, non dalla collaborazione in sé.

**3. Cosa succede se le nostre API cambiano spesso?**
Evolvere va bene, cambiare a sorpresa no: se il contratto muta ogni notte senza disciplina, nessun frontend regge e si costruisce su sabbie mobili. La soluzione è versionare le rotture e comunicarle. Se serve, sistemare il contratto viene prima di costruire la faccia — e te lo dico subito.

**4. Mi serve una pagina bella o un design system?**
Se hai un prodotto che vive e cresce, un design system: componenti riusabili che rendono coerenti trenta schermate e fanno costare meno ogni funzione nuova. La pagina bella una tantum è un costo che ripaghi ogni volta; il design system è un investimento che accelera tutto il resto e abilita il white-label.

**5. Potrò rivendere il prodotto white-label ai miei clienti?**
Sì, se il frontend è pensato per esserlo: stile centralizzato, marchio cambiabile da un punto solo. Così lo stesso prodotto indossa molte facce senza rifarlo ogni volta, e tu mantieni una piattaforma sola. Ma va progettato così dall'inizio — col patchwork non funziona.

**6. Chi resta proprietario del backend e del cliente?**
Tu. Il modello è collaborativo: tu tieni il motore che sai fare e il rapporto col cliente, io chiudo la faccia del prodotto. Il contratto API è la frontiera pulita tra i due mondi.

**7. Lavoriamo a progetto singolo o in modo continuativo?**
Come serve a te: un prodotto singolo da chiudere, una collaborazione ricorrente come frontend dei tuoi progetti, o un design system riusabile che poi porti avanti tu. Lo decidiamo sui tuoi progetti reali.

**8. Perché tu e non un freelance UI qualsiasi?**
Perché vengo dal fare dati, backend, frontend e LLM insieme: capisco cosa c'è sotto la tua API e parlo la tua lingua tecnica, invece di trattarla da scatola nera. Questo elimina il rimpallo e fa venire bene il prodotto, perché discuto il contratto da pari, non da esecutore muto del CSS.
