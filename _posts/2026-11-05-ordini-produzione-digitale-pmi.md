---
lang: it
permalink: /it/blog/ordini-produzione-digitale-pmi/
alt_url: /en/blog/sme-digital-production-orders/
title: "Ordini di produzione ancora su carta: la piccola manifattura che non sa se è in ritardo (finché il cliente chiama)"
date: 2026-05-21 07:30:00 +0200
author: "Antonio Trento"
description: "Se in officina si lavora su fogli di carta e in ufficio su un Excel, non sai se una commessa è in ritardo finché il cliente non chiama. Ecco l'avanzamento commessa digitale per la piccola manifattura — senza un SAP."
keywords: ["ordini produzione digitale pmi", "mes piccola manifattura", "avanzamento commessa", "software officina", "ritardi produzione"]
image: /assets/images/posts/ordini-produzione-digitale-pmi.jpg
pillar: app-interne
related: [/it/blog/giacenze-magazzino-disallineate/, /it/blog/app-interna-aziendale-copia-incolla/]
---

## «A che punto è la commessa?» — e nessuno lo sa davvero

In tante piccole manifatture la scena è questa. In officina, gli ordini di produzione sono **fogli di carta**: il traveller che accompagna il pezzo, l'ordine appeso a una lavagna, il quaderno del capo reparto. In ufficio, c'è un **Excel** che qualcuno aggiorna quando ha tempo, di solito in ritardo e a memoria. E tra i due mondi — l'officina che produce e l'ufficio che vende e pianifica — c'è un muro: nessuno sa, in tempo reale, a che punto sono davvero le commesse.

Così, quando il titolare o il commerciale chiede «a che punto è l'ordine del cliente X?», la risposta è un giro: qualcuno va in officina, chiede al capo reparto, che guarda il foglio, che magari non è aggiornato, e torna con un «dovrebbe essere quasi pronto». *Dovrebbe.* La verità è che non sai se una commessa è in ritardo **finché il cliente non chiama** per reclamarla — e a quel punto è tardi per rimediare, e in ballo ci sono una penale e la reputazione.

Questo articolo è per la piccola e media manifattura — officine, laboratori, produzioni su commessa — che lavora ancora tra carta e Excel e vuole sapere, in ogni momento, come stanno andando le commesse. Vediamo cosa deve vedere il capo reparto e cosa il titolare (sono due schermate diverse), come si modellano gli stati di una commessa, perché **non è un SAP ma un flusso**, come questi dati salvano il commerciale dall'over-promettere, e come si parte da un reparto pilota senza fermare la produzione.

## Il foglio in officina e l'Excel in ufficio: due mondi che non si parlano

La radice del problema è la disconnessione tra chi produce e chi pianifica. In officina il dato è vero ma **prigioniero della carta**: il capo reparto sa perfettamente a che punto è ogni pezzo, ma quella conoscenza vive sul traveller e nella sua testa, non arriva in ufficio se non quando qualcuno va a chiedere. In ufficio il dato è accessibile ma **vecchio e a memoria**: l'Excel dice quello che qualcuno ci ha scritto l'ultima volta, che non è quello che sta succedendo adesso in reparto.

Il risultato è che l'azienda ha due versioni della realtà, sfasate. E ogni decisione — accettare un nuovo ordine, promettere una data, dire a un cliente «è pronto giovedì» — viene presa sull'Excel vecchio, mentre la verità è in officina, sulla carta. È lo stesso schema del [dato prigioniero della carta che vediamo per i tecnici sul campo]({{ '/it/blog/app-tecnici-sul-campo/' | relative_url }}) o delle [giacenze che dicono cose diverse in sistemi diversi]({{ '/it/blog/giacenze-magazzino-disallineate/' | relative_url }}): la conoscenza c'è, ma non è dove serve, quando serve.

La soluzione non è un mostro gestionale. È far sì che **l'avanzamento venga registrato dove accade** — in reparto, dal capo reparto o dall'operatore, con pochi tap — e diventi subito visibile in ufficio. Il pezzo passa da una fase all'altra? Un tap, e l'ufficio lo sa. Niente più giro a chiedere, niente più Excel a memoria.

## Le due schermate: il capo reparto e il titolare

Come ogni cosa che tocca l'operatività, non c'è una schermata sola. Chi sta in reparto e chi sta in ufficio guardano cose diverse, e servono due viste sulla stessa verità.

**La schermata del reparto** è essenziale e robusta, pensata per l'officina — dove ci sono le mani sporche, il rumore, poco tempo. Mostra le commesse in lavorazione in quel reparto, in che fase sono, cosa è in coda, e permette di far avanzare un ordine (fase completata, pezzo passato al reparto dopo) con pochi tap, magari da un tablet a bordo macchina. Al capo reparto non serve il quadro dell'intera azienda: gli serve il *suo* reparto, chiaro e veloce da aggiornare. Se aggiornare è più lento che scrivere sul foglio, tornerà al foglio — la stessa regola di ogni [app interna: se è più lenta della carta, ha perso]({{ '/it/blog/app-interna-aziendale-copia-incolla/' | relative_url }}).

**La schermata del titolare (e del commerciale)** è di visione: tutte le commesse, a che punto sono, quali sono in ritardo o a rischio, quando saranno pronte. In venti secondi il titolare sa se la settimana è sotto controllo o se c'è un ordine che sta scivolando. E il commerciale, prima di promettere una data a un cliente, guarda il carico reale della produzione invece di sparare una data a sensazione.

Stessa verità sotto — l'avanzamento delle commesse — due viste sopra: operativa per il reparto, di controllo per la direzione. È il pattern che torna in tutte le app interne, dai [cruscotti]({{ '/it/blog/cruscotto-aziendale-titolare/' | relative_url }}) al magazzino: una fonte, tante viste.

C'è spesso una terza vista che vale la pena citare: quella del **cliente**. In alcune produzioni ha senso dargli la possibilità di vedere lo stato della sua commessa — «in lavorazione», «in collaudo», «in spedizione» — senza dover telefonare. È lo stesso self-service del portale cliente: toglie chiamate all'ufficio e dà al cliente la tranquillità di sapere, che in un rapporto di fornitura vale molto. Non serve sempre, ma quando i clienti chiamano di continuo per sapere «a che punto siamo», è un modo elegante di far sparire quelle chiamate.

## Gli stati della commessa: il flusso, i fermi, i ricambi

Il cuore di un sistema di avanzamento sono gli **stati**: le fasi attraverso cui passa una commessa, dall'ordine alla consegna. Modellarli bene è il vero lavoro, perché devono rispecchiare *come produci davvero tu*, non un flusso teorico da manuale.

Gli stati tipici: da fare, in lavorazione (per reparto/fase), in attesa (di un materiale, di un'approvazione, di un pezzo da un terzista), completata, spedita. Ma il valore vero è nella gestione delle **eccezioni**, perché la produzione reale è fatta di intoppi:

- **I fermi**: la commessa ferma perché manca un materiale, perché una macchina è guasta, perché aspetta il pezzo da un fornitore esterno. Un fermo tracciato è un problema che vedi *mentre* accade e puoi gestire; un fermo non tracciato è un ritardo che scopri alla fine.
- **I ricambi e i materiali**: cosa serve per quella commessa, cosa c'è, cosa manca. Sapere che manca un materiale *prima* di iniziare (non a metà) evita di bloccare un pezzo a lavorazione avviata.
- **Le priorità**: quali commesse vengono prima, e cosa succede quando arriva un'urgenza. Un sistema che mostra le code aiuta a decidere cosa spostare senza mandare in caos il reparto.

Un'osservazione dal campo: nella maggior parte delle piccole manifatture, il grosso del ritardo non è nel tempo di *lavorazione* — è nel tempo di *attesa*. La commessa passa più tempo ferma (in coda per un reparto, in attesa di un materiale, dal terzista, in attesa di un'approvazione) che in lavorazione vera. Ecco perché tracciare i fermi e le attese, non solo le lavorazioni, è così importante: è lì che si nasconde il ritardo, ed è lì che, una volta visibile, puoi intervenire. Un sistema che traccia solo «in lavorazione / fatto» e ignora le attese vede metà del problema.

Modellare questi stati e queste eccezioni bene è ciò che rende il sistema utile invece che un altro posto da aggiornare. È lo stesso principio del modello dei dati sotto ogni app: se gli stati non rispecchiano la tua produzione reale, con le sue eccezioni, il capo reparto trova il caso che non ci sta e torna al foglio.

## Cosa registrare in reparto (e cosa no)

Un avvertimento importante, perché è l'errore che fa fallire questi progetti: **non tracciare tutto**. C'è sempre qualcuno che, entusiasta, vuole registrare ogni singola operazione, ogni minuto, ogni movimento — il sogno del «dato totale». In una piccola manifattura è la ricetta del fallimento: se al capo reparto chiedi di registrare venti cose per ogni pezzo, non lo farà, o lo farà male e in ritardo, e i dati saranno peggiori della carta.

La regola è registrare il **minimo che serve** a rispondere alle domande che contano: a che punto è la commessa, è ferma e perché, quando sarà pronta. Pochi stati, pochi tap; il resto si aggiunge solo se serve davvero e se non appesantisce chi registra. Meglio un avanzamento a grana grossa che tutti aggiornano, che un tracciamento fine che nessuno tiene. È lo stesso principio delle poche schermate che tolgono attrito: la precisione perfetta che nessuno mantiene vale meno di un'approssimazione onesta sempre aggiornata.

## Non è un SAP: è un flusso

Qui va sciolto il timore più grande: «per gestire la produzione serve un MES, un ERP di produzione, roba enorme e costosa». Per una piccola manifattura, quasi sempre **no**. Un MES enterprise è pensato per stabilimenti con centinaia di macchine, integrazione con i PLC, schedulazione automatica sofisticata. Se il tuo problema è sapere a che punto sono le commesse e non scoprire i ritardi dal cliente, un MES è un bazooka per una zanzara: costa moltissimo, richiede mesi (a volte anni) di implementazione, e ti obbliga a cambiare come lavori per adattarti a lui.

Quello che ti serve non è un sistema che *controlla* la produzione: è un sistema che la **rende visibile**. Un flusso semplice — le commesse, gli stati, l'avanzamento registrato in reparto e visibile in ufficio — risolve il 90% del dolore (i ritardi che non vedi) senza la complessità del MES. È la stessa logica del [WMS prematuro per il magazzino]({{ '/it/blog/giacenze-magazzino-disallineate/' | relative_url }}): prima la visibilità, poi — se e quando i volumi lo giustificheranno — l'ottimizzazione avanzata, su una base già ordinata. Partire dal MES è mettere il carro davanti ai buoi (e spendere dieci volte tanto per problemi che non hai ancora).

## I dati che salvano il commerciale dall'over-promettere

C'è un punto in cui questo sistema si ripaga da solo: la **data di consegna**. Oggi, senza visibilità sulla produzione, il commerciale promette date a sensazione — o peggio, promette quello che il cliente vuole sentire, per chiudere l'ordine. Poi quella data arriva in officina come un fatto compiuto, si scontra con un reparto già pieno, e diventa un ritardo. Il commerciale ha «venduto», ma ha venduto un ritardo, che si trasforma in un cliente arrabbiato e a volte in una penale.

Con l'avanzamento commessa visibile, il commerciale ha sotto gli occhi il **carico reale** della produzione prima di promettere: quante commesse ci sono, quando si libera la capacità, quanto ci vuole davvero per un ordine come quello. Può ancora accettare un'urgenza, ma sapendo cosa comporta (cosa slitta, cosa va in straordinario), non al buio. Promettere una data diventa una decisione informata, non una scommessa. E questo cambia il rapporto con i clienti: meglio dire «te lo consegno il 15» e rispettarlo, che dire «il 5» per far contento il cliente oggi e deluderlo il 6.

Questo è il ROI più concreto: **meno ritardi, meno penali, meno figuracce**, perché le date promesse sono ancorate alla realtà della produzione invece che alle speranze del commerciale.

Un esempio concreto: arriva un ordine urgente. Senza visibilità, il commerciale dice sì e promette dieci giorni, sperando. Con l'avanzamento sotto gli occhi, vede che il reparto chiave è pieno per due settimane e ha una scelta *informata*: dire onestamente «quindici giorni», oppure accettare i dieci sapendo esattamente cosa deve slittare o andare in straordinario per farcela. In entrambi i casi decide con i fatti, non con la speranza — e il cliente riceve una promessa che verrà mantenuta, che vale infinitamente più di una promessa ottimista puntualmente tradita.

## Quanto costa non vedere i ritardi

Vale la pena mettere a fuoco quanto costa non vedere i ritardi, perché è un costo che si nasconde bene. C'è la **penale** contrattuale, la più visibile: molti clienti industriali la prevedono, ed è denaro che esce diretto. C'è la **reputazione**: un fornitore che consegna in ritardo, ripetutamente, è un fornitore che il cliente comincia a sostituire — e perdere un cliente industriale vale molto più di una penale. C'è lo **straordinario d'emergenza**: la commessa che scopri in ritardo all'ultimo la recuperi facendo lavorare qualcuno di corsa, spesso in straordinario, a costo maggiorato. E c'è il costo delle **scelte sbagliate**: senza vedere il carico, accetti ordini che non puoi onorare nei tempi, e ogni sì di troppo diventa un ritardo a catena.

Il punto è che nessuno di questi costi compare in una riga di contabilità con scritto «ritardo produzione». Si nascondono nelle penali sparse, nei clienti che pian piano ordinano meno, negli straordinari. Renderli visibili — con il KPI del rispetto data — è già metà del valore: quando misuri quante commesse consegni in orario, cominci a poterlo migliorare.

## Un caso tipo: dal traveller cartaceo alle date rispettate

Un profilo tipico, architetturale, senza nomi. Piccola manifattura su commessa, una ventina di persone, tre reparti. Ordini di produzione su traveller cartacei, avanzamento su un Excel aggiornato a fine giornata (quando c'era tempo). Il titolare scopriva i ritardi dai clienti; il commerciale prometteva date guardando l'Excel vecchio, e un paio di volte l'anno arrivava una penale per una consegna saltata.

Cosa si è fatto. Prima si sono mappati gli stati reali con i capi reparto: le fasi, i fermi tipici (materiale mancante, terzista, approvazione). Poi un flusso semplice: ogni commessa con il suo stato, l'avanzamento registrato in reparto da un tablet con pochi tap, e due schermate — una per il reparto, una per il titolare e il commerciale. Partiti da un reparto pilota.

Dopo: l'ufficio sa in tempo reale a che punto sono le commesse, senza andare a chiedere. Il commerciale promette date guardando il carico vero, e i ritardi «a sorpresa» sono quasi spariti — quando una commessa scivola, si vede prima e si avvisa il cliente, invece di scoprirlo alla scadenza. Con la solita nota: il valore non è stato «digitalizzare la produzione», è stato rendere visibile un'informazione (a che punto siamo) che prima era prigioniera della carta e della testa dei capi reparto.

## Go-live in un reparto pilota

Il modo di introdurre un sistema del genere segue la regola di sempre: niente big bang su tutta la fabbrica. Si parte da **un reparto pilota** — meglio uno con un capo reparto collaborativo — e lì si mette a punto tutto: gli stati giusti, la schermata veloce da aggiornare, le eccezioni tipiche. Quando quel reparto funziona e l'avanzamento arriva davvero in ufficio, si aggiunge il reparto successivo, portandosi dietro le lezioni imparate.

Questo approccio ha due vantaggi. Primo, non fermi la produzione: il pilota gira in parallelo al metodo vecchio finché non è solido. Secondo, trasformi il capo reparto del pilota in un alleato — è lui che, avendo contribuito a tararlo, lo racconta bene agli altri. In una fabbrica, l'adozione la fanno i capi reparto: se il primo lo vive come un aiuto (meno telefonate dall'ufficio, meno «a che punto siamo?»), gli altri lo accettano; se lo vivono come sorveglianza calata dall'alto, lo sabotano registrando male.

## L'integrazione con gestionale e magazzino

Un sistema di avanzamento non vive isolato: il valore pieno arriva quando si collega a due cose. Al **gestionale**, perché la commessa nasce da un ordine cliente e finisce in una consegna e una fattura: se l'avanzamento e l'ordine sono scollegati, ricrei il doppio lavoro di ritrascrizione. E al **magazzino/scorte**, perché una commessa consuma materiali: sapere cosa serve, cosa c'è e cosa manca prima di iniziare è ciò che evita i fermi per materiale mancante. È lo stesso tema delle [giacenze come verità unica]({{ '/it/blog/giacenze-magazzino-disallineate/' | relative_url }}): la produzione e il magazzino sono due facce dello stesso flusso, e vanno collegati o restano due bugie separate.

Non serve integrare tutto il primo giorno — si può partire dalla sola visibilità dell'avanzamento e collegare gestionale e magazzino a strati. Ma il disegno deve tenerne conto dall'inizio, o costruisci un altro silo isolato.

## KPI: rispetto della data e code

Come sai se stai migliorando? Due numeri, su tutti.

- **Rispetto della data di consegna** (on-time delivery): quante commesse consegni entro la data promessa. È il numero che i tuoi clienti sentono, ed è quello che protegge la reputazione e ti evita le penali. Prima, probabilmente, non lo misuravi nemmeno; con l'avanzamento, lo vedi e lo migliori.
- **Le code e i tempi di attraversamento**: quanto tempo una commessa passa in lavorazione e quanto ferma in attesa. Spesso si scopre che il grosso del ritardo non è lavorazione, è *attesa* — di un materiale, di un'approvazione, di un reparto occupato. E l'attesa, una volta visibile, si può ridurre.

Questi numeri trasformano la produzione da «speriamo di farcela» a governata: sai dove si accumulano i ritardi, su cosa agire, se la settimana è sotto controllo. È lo stesso salto dal decidere a sensazione al [decidere sui numeri]({{ '/it/blog/cruscotto-aziendale-titolare/' | relative_url }}) di cui parlo per i cruscotti, portato in officina.

## Da dove si parte

Se decidessimo di partire, il primo passo non è comprare software: è **mappare gli stati reali con chi produce**. Siediti con i capi reparto e disegna il flusso vero di una commessa: le fasi, i punti dove si ferma di solito, le eccezioni che capitano. Questo — non un manuale — è il modello su cui si costruisce il sistema, e nessuno lo conosce meglio di chi sta in reparto.

Il secondo passo è guardare gli ultimi mesi: quante commesse hai consegnato in ritardo? Quante penali? Quante volte hai scoperto un ritardo dal cliente invece che in anticipo? Quell'audit leggero ti dice se il problema è reale e quanto pesa, ed è la baseline per capire, dopo, se il sistema ha funzionato. Si parte da come produci, reparto per reparto — non da una demo di software.

## È per te se / non è per te se

**È per te se:** produci su commessa e gestisci gli ordini di produzione tra carta in officina ed Excel in ufficio; scopri i ritardi quando il cliente chiama; il commerciale promette date che la produzione non riesce a rispettare; nessuno sa in tempo reale a che punto sono le commesse.

**Non è per te se:** hai pochissime commesse e le tieni benissimo a mente; produci a magazzino con pochi prodotti standard e senza commesse (altro tema); sei una fabbrica grande con centinaia di macchine che ha davvero bisogno di un MES completo con schedulazione automatica — lì il discorso è un altro.

## Domande frequenti

**Serve un MES o un ERP di produzione?**
Quasi mai, per una piccola manifattura. Un MES è pensato per stabilimenti grandi e costa e pesa di conseguenza. A te serve la visibilità dell'avanzamento — un flusso semplice di stati registrati in reparto e visibili in ufficio — non un sistema che controlla ogni macchina. Il MES, se mai, arriva dopo, su una base già ordinata.

**Il capo reparto aggiornerà davvero il sistema?**
Sì, se aggiornare è più veloce e utile che tenere il foglio: pochi tap, da un tablet in reparto, e in cambio meno telefonate dall'ufficio che chiede «a che punto siamo?». Se è più lento del foglio, no. Per questo la schermata di reparto va disegnata con lui, per la sua realtà, e va rodata su un pilota.

**Come gestisco i terzisti e le lavorazioni esterne?**
Come uno stato di «attesa esterna»: la commessa esce, è tracciata come fuori per lavorazione, e rientra. Così un pezzo dal terzista non «sparisce» dalla vista, e sai quali commesse dipendono da un rientro esterno — spesso una delle cause principali di ritardo.

**Quanto tempo per partire?**
Un reparto pilota si mette in piedi in poche settimane, se gli stati e il flusso sono chiari. Poi si aggiungono gli altri reparti e si collegano gestionale e magazzino a strati. Meglio un reparto che funziona che tutta la fabbrica a metà.

**E se ogni commessa è diversa dall'altra?**
È la norma nella produzione su commessa, e non è un problema: gli stati (da fare, in lavorazione, in attesa, completata) sono gli stessi anche se il contenuto cambia. Il sistema traccia l'avanzamento attraverso le fasi, non i dettagli tecnici di ogni pezzo — quelli restano nel disegno e nel traveller. Serve la visibilità del «a che punto siamo», non la digitalizzazione di ogni lavorazione.

**Devo riempire l'officina di tablet e schermi?**
Spesso basta un tablet condiviso per reparto, o il telefono del capo reparto. Non serve tappezzare l'officina di terminali: serve un modo comodo, a portata di mano di chi lavora, per far avanzare le commesse con pochi tap. L'investimento è nel flusso, non nell'hardware.

**Come coinvolgo i capi reparto senza che lo vivano come controllo?**
Presentandolo per quello che è: meno telefonate dall'ufficio che chiede «a che punto siamo?», e le loro stime finalmente rispettate perché il commerciale promette sul carico vero. Coinvolgili nel disegnare gli stati (conoscono la produzione meglio di chiunque) e parti dal reparto del più collaborativo. Un capo reparto che vede meno interruzioni e meno colpe ingiuste per ritardi non suoi lo adotta volentieri.

**I dati (commesse, avanzamento, storico) restano miei?**
Sì. Commesse, stati, storico e i tempi di produzione restano tuoi, niente lock-in. Lo storico dell'avanzamento è prezioso: ti dice dove si accumulano i ritardi e quanto costa davvero produrre una certa cosa.

## In una riga

Se gli ordini di produzione vivono tra la carta in officina e l'Excel in ufficio, non sai se una commessa è in ritardo finché il cliente non chiama — e a quel punto ci sono penale e reputazione in gioco. Non ti serve un MES: ti serve un **flusso** che renda visibile l'avanzamento, registrato in reparto e visibile in ufficio, con due viste (capo reparto e titolare), gli stati e i fermi che rispecchiano la tua produzione, e i dati che salvano il commerciale dal promettere date impossibili. Si parte da un reparto pilota, senza fermare niente.

Se vuoi capire come rendere visibili le tue commesse — senza un sistema da grande fabbrica — guarda i [progetti che ho costruito]({{ site.main_site }}/portfolio/) o [scrivimi due righe]({{ site.main_site }}/contatti/): partiamo da come produci davvero, reparto per reparto, non da un software da fiera.
