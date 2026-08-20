---
lang: it
permalink: /it/blog/feature-promessa-non-esiste/
alt_url: /en/blog/promised-feature-does-not-exist/
title: "Il commerciale promette una feature che il software non ha: come chiudere il buco prima che ti costi un cliente"
date: 2026-09-16 07:30:00 +0200
author: "Antonio Trento"
description: "Il commerciale dice 'sì, lo facciamo' per chiudere la vendita, e il software quella cosa non la fa. Ora hai un cliente che aspetta una promessa e un team che non sapeva niente. Come si chiude il buco tra vendite e prodotto."
keywords: ["feature promessa non esiste", "scope commerciale vs prodotto", "customizzazione pericolosa", "dire no al cliente", "roadmap software"]
image: /assets/images/posts/feature-promessa-non-esiste.jpg
pillar: comprare-software
related: [/it/blog/rfi-software-come-rispondere/, /it/blog/cosa-include-software-su-misura/]
---

## La mail "sì, lo facciamo"

C'è una mail che, se hai un software e qualcuno che lo vende, prima o poi ti arriva e ti gela il sangue. La manda il commerciale, tutto contento, e dice più o meno così: *"Ottima notizia, ho chiuso il cliente X! Gli ho detto che il software fa anche [una cosa che il software non fa]. Quando possiamo averla pronta?"*. In una riga, il commerciale ha venduto una funzione che **non esiste**, ha impegnato l'azienda su qualcosa che nessuno del team di prodotto sapeva, e ha messo te davanti a un bivio tutto in perdita: o costruisci di corsa una cosa non pianificata, o dici a un cliente appena acquisito che gli è stata promessa una bugia.

Questo è il **buco tra vendite e delivery**, ed è uno dei dolori più frequenti e sottovalutati di ogni azienda che ha un prodotto software — dalle software house alle PMI con un software interno che vendono ai clienti. Il commerciale è pagato e portato per **chiudere**: il suo istinto è dire sì, perché ogni sì avvicina la firma. Il team di prodotto è responsabile di **consegnare**: il suo istinto è la prudenza, perché ogni sì è lavoro vero. Quando questi due mondi non si parlano, il commerciale promette e il prodotto scopre le promesse a cose fatte — e in mezzo ci sei tu, con un cliente che aspetta e un team che non sapeva niente.

Il danno non è solo la singola funzione da costruire di corsa. È peggio, ed è doppio. Da un lato, se **non** mantieni la promessa, il cliente si sente ingannato appena acquisito — il modo peggiore per cominciare un rapporto, e il modo più veloce per perderlo prima ancora di averlo servito. Dall'altro, se **mantieni** ogni promessa costruendo tutto quello che il commerciale vende, il tuo prodotto si riempie di funzioni fatte per un cliente solo, il team è sempre in emergenza, e la roadmap la decide chi urla di più invece di una strategia. Entrambe le strade, percorse abbastanza a lungo, ti fanno male.

Questo articolo è su come si chiude quel buco — non con la magia, ma con **processo e prodotto**: come si dice no in modo che rafforzi il rapporto invece di romperlo, come si distingue la promessa da buttare da quella che vale, come si mette ordine tra ciò che si vende e ciò che si costruisce. Perché il problema non è avere un commerciale entusiasta: è non avere un modo di trasformare il suo entusiasmo in impegni che il prodotto può mantenere.

## Il costo di una custom per un solo cliente

Prima di parlare di processo, bisogna capire *perché* dire sì a ogni promessa è pericoloso — perché finché non lo vedi in tutta la sua gravità, continuerai a cedere "tanto è una cosa piccola". Il punto è il **costo vero di una funzione costruita per un solo cliente**, che è molto più alto di quanto sembra.

Quando costruisci una custom per accontentare il cliente X, non paghi solo il tempo di costruirla. Paghi una coda lunga di costi nascosti:

- **La costruisci una volta, la mantieni per sempre.** Ogni funzione aggiunta al prodotto va poi mantenuta, aggiornata, tenuta compatibile con tutto il resto — anche se la usa un cliente solo. Il costo di costruzione è la punta dell'iceberg; sotto c'è la manutenzione a vita, come vale per [tutto ciò che si aggiunge a un software dopo il go-live]({{ '/it/blog/manutenzione-software-dopo-go-live/' | relative_url }}).
- **Complica il prodotto per tutti.** Ogni funzione specifica infilata nel prodotto lo rende un po' più complesso, un po' più difficile da usare, un po' più fragile — per *tutti* i clienti, non solo per quello che l'ha chiesta. La custom del cliente X è un peso che pagano anche i clienti Y e Z, sotto forma di prodotto più ingarbugliato.
- **Rallenta tutto il resto.** Il tempo speso sulla custom per un cliente è tempo *non* speso su ciò che serve a molti. Ogni sì al cliente che urla è un no silenzioso a tutti gli altri e alla strategia.
- **Apre la porta.** Concessa una custom a X, perché non a Y? Il "sì" diventa un precedente, e il prodotto scivola verso un ammasso di funzioni-per-un-cliente-solo che è ingestibile.

La regola sana la conosci già, ed è quella dell'80/20 che torna sempre: **il prodotto vive dell'80% comune a molti; il 20% specifico di un cliente, quasi sempre, non va infilato nel prodotto.** Una funzione ha senso costruirla se serve a *tanti* clienti (allora è prodotto vero, ed è giusto). Se serve a *uno solo*, quasi sempre è un errore metterla nel prodotto — e se proprio va fatta, va gestita come un lavoro a parte, pagato a parte, e non spacciato per "evoluzione del prodotto". La distinzione tra "questa funzione è il prodotto" e "questa funzione è un capriccio di un cliente" è il cuore di tutto, e ci torno tra poco. Ma prima serve il processo per non trovarsi la promessa già fatta.

## Il processo: come si dice no, come si mette in roadmap

Il buco tra vendite e prodotto non si chiude sperando che il commerciale diventi prudente. Si chiude con un **processo**: un modo concordato di trasformare ciò che il cliente chiede in un impegno che il prodotto può mantenere — *prima* che la promessa venga fatta. La chiave è spostare il momento della decisione da "il commerciale promette e il prodotto scopre" a "il commerciale chiede e insieme si decide".

Come funziona un processo sano:

- **Il commerciale non promette funzioni che non esistono. Punto.** Questa è la regola di base, e va stabilita chiaramente: davanti a una richiesta di qualcosa che il prodotto non fa, la risposta del commerciale non è "sì, lo facciamo", ma "**interessante, lo verifico e ti dico**". Non è debolezza commerciale: è professionalità. Un "ti confermo entro domani" detto con sicurezza vende quanto un "sì" avventato, e non ti mette nei guai.
- **C'è un canale veloce vendite→prodotto.** Quando arriva una richiesta nuova, il commerciale la porta al prodotto *prima* di impegnarsi, e ottiene una risposta rapida: si può fare? serve a tanti o a uno? quanto costa? è già in programma? Questo scambio deve essere veloce — un commerciale non può aspettare una settimana per rispondere a un cliente caldo — ma deve esistere. La velocità di questo canale è ciò che rende il processo vivibile.
- **Le tre risposte possibili.** A una richiesta, il prodotto risponde in uno di tre modi: **"c'è già"** (magari il commerciale non lo sapeva — e questo dice che serve formazione sul prodotto); **"non c'è ma ha senso, lo mettiamo in roadmap"** (serve a tanti, si programma con tempi veri); **"non c'è e non lo faremo"** (serve a uno solo, o è contro la direzione del prodotto). Il commerciale, con questa risposta in mano, può dire al cliente qualcosa di **vero**.

Il pezzo più delicato è **dire no al cliente senza perderlo**, ed è un'arte che vale l'articolo. Il no che rompe il rapporto è quello brusco e finale ("no, non si può"). Il no che *rafforza* il rapporto è quello onesto e costruttivo: *"Questa cosa specifica oggi il prodotto non la fa, e ti dico la verità sul perché e su cosa possiamo fare invece."* Spesso dietro la richiesta del cliente c'è un **bisogno** che il prodotto sa già soddisfare in un altro modo — e allora il no alla funzione diventa un sì al bisogno ("non facciamo esattamente così, ma risolviamo il tuo problema in quest'altro modo, guarda"). Un cliente preferisce quasi sempre un fornitore che gli dice la verità e gli propone la soluzione vera, a uno che gli promette tutto e poi non mantiene. La stessa lucidità che serve a [non firmare promesse impossibili in un RFI]({{ '/it/blog/rfi-software-come-rispondere/' | relative_url }}) serve qui, tutti i giorni, a ogni richiesta.

## Quando la feature è davvero il prodotto (e va costruita bene)

Attenzione, però, a non ribaltare l'errore. Il messaggio non è "dì sempre no a ogni richiesta nuova": sarebbe un altro modo di sbagliare, quello dell'azienda arroccata che non evolve mai il prodotto perché "non era in roadmap". A volte la funzione che il commerciale ha intravisto vendendo è **esattamente ciò di cui il prodotto ha bisogno** — e riconoscerlo è tanto importante quanto saper dire no.

Come distingui la richiesta-capriccio (di un cliente solo, da rifiutare) dalla richiesta-oro (che è il futuro del prodotto)? Il criterio è sempre lo stesso: **quanti clienti ne beneficerebbero?**

- **Se la stessa cosa la chiedono più clienti**, indipendentemente, il mercato ti sta dicendo che è una funzione di prodotto vera. Il commerciale, in questo caso, non ha fatto una promessa avventata: ha fatto da **antenna sul mercato**, ha sentito prima di te dove va la domanda. Quella richiesta va accolta, messa in roadmap con priorità, e costruita **bene** — non di corsa per un cliente, ma con cura perché servirà a molti.
- **Se la chiede uno solo e nessun altro**, è probabilmente specifica di lui: va gestita come custom a parte (pagata a parte) o rifiutata con garbo.

Il commerciale, in un'azienda sana, non è il nemico del prodotto: è un **sensore prezioso** di cosa il mercato vuole, perché è lui che sta davanti ai clienti tutti i giorni. Il processo di cui parlavo non serve a zittirlo — serve a **distinguere il segnale dal rumore** nelle sue promesse. Le richieste che tornano da più clienti sono segnale, e vanno ascoltate per far evolvere il prodotto nella direzione giusta. Le richieste isolate sono rumore (per il prodotto), e vanno gestite senza inquinarlo. Un'azienda che ascolta il commerciale *come antenna* ma decide con la testa del prodotto *cosa costruire*, ha trovato l'equilibrio: evolve il prodotto verso ciò che serve a molti, senza riempirlo dei capricci di pochi. Quando la funzione è davvero il prodotto, va costruita seriamente — con la UI giusta, i dati giusti, i casi limite gestiti — non abbozzata per tenere buono un cliente.

## Il frontend: aspettative contro realtà

C'è un motivo tecnico ricorrente per cui le promesse commerciali diventano disastri di delivery, e riguarda il **frontend** — la faccia del prodotto. Il commerciale, quando vende, mostra e descrive quello che l'utente *vede*: le schermate, i pulsanti, il "poi clicchi qui e succede questo". È naturale: è la parte che si può far vedere. Ma quello che si vede è la punta dell'iceberg, e il commerciale, in buona fede, promette sulla punta ignorando tutto ciò che c'è sotto.

Il cliente sente "aggiungiamo un pulsante che fa X" e lo immagina semplice — un pulsante, appunto. Il commerciale, che pensa come il cliente, lo promette come semplice. Ma dietro quel pulsante c'è tutto il lavoro invisibile che fa funzionare la cosa: cosa succede quando lo premi, da dove arrivano i dati, cosa succede se qualcosa va storto, chi ha il permesso di premerlo, cosa vede chi non ce l'ha. La distanza tra "il pulsante che si vede" e "tutto ciò che serve perché quel pulsante funzioni davvero" è enorme — ed è proprio quella distanza che il commerciale non vede e quindi sottostima, promettendo in una frase ciò che è settimane di lavoro.

Questo è lo stesso fenomeno che descrivo in [cosa fa davvero un frontend serio]({{ '/it/blog/frontend-per-software-house/' | relative_url }}): il caso ideale (il pulsante che funziona quando tutto va bene) è il 20% del lavoro; l'80% sono gli stati, gli errori, i permessi, i casi limite. Il commerciale promette sul 20% visibile; il prodotto deve consegnare il 100%, 80% invisibile compreso. Ecco perché una promessa che al commerciale sembra "una cosina" al team di prodotto sembra "una settimana di lavoro": non è che il team esagera o fa il difficile — è che vede l'iceberg intero, mentre il commerciale ha visto solo la punta. Chiudere questo buco significa anche **educare il commerciale** a capire che dietro ogni cosa visibile c'è del lavoro invisibile, così che le sue promesse diventino più caute e più vere.

## I dati e i casi limite che il commerciale non vede

Se il frontend è l'iceberg visibile sottostimato, i **dati e i casi limite** sono l'iceberg che il commerciale non vede proprio — e sono la fonte delle promesse più pericolose, quelle che sembrano innocue e invece sono voragini.

Il commerciale ragiona sul **caso bello**: il cliente inserisce i dati giusti, tutto è in ordine, la funzione fa la sua cosa. Ed è naturale, perché è così che si dimostra una cosa in una demo. Ma il software vero vive nei **casi brutti**, quelli che il commerciale non immagina nemmeno:

- **I dati sporchi.** Il commerciale promette "il sistema calcola X automaticamente". Ma X si calcola sui dati del cliente, e i dati del cliente sono incompleti, incoerenti, in formati strani. La funzione promessa "automatica" richiede in realtà un lavoro enorme per gestire i dati reali, che non sono mai come nella demo.
- **I casi limite.** "E se due utenti fanno la stessa cosa insieme? E se il valore è zero, o negativo, o enorme? E se manca un pezzo?" Sono le domande che il team di prodotto si pone e il commerciale no, perché lui ha in testa il flusso lineare della vendita, non le mille deviazioni della realtà.
- **Le integrazioni con i sistemi del cliente.** "Sì, ci integriamo col vostro gestionale" — promessa facile a dirsi, che dipende però interamente da cosa quel gestionale espone, com'è fatto, quanto è collaborativo. Il commerciale promette l'integrazione come se fosse una spunta; il prodotto sa che può essere un abisso.

Il punto è che **il commerciale non vede questa parte non per incompetenza, ma perché non è il suo mestiere** — e non deve diventarlo. Il suo mestiere è capire il cliente e vendere; il mestiere del prodotto è sapere dove sono i dati sporchi e i casi limite. Il buco si chiude non chiedendo al commerciale di diventare tecnico, ma facendo passare le promesse *attraverso* chi vede la parte invisibile *prima* che diventino impegni. È un altro motivo per cui serve qualcuno con una visione d'insieme — che capisca dati, backend e frontend — a fare da filtro tra ciò che si vende e ciò che si costruisce: perché è l'unico che vede l'iceberg intero e può dire "questa promessa costa dieci volte quello che sembra".

## La radice: spesso il commerciale non conosce il prodotto

Prima di blindare processi e contratti, vale la pena guardare una radice del problema che quasi nessuno affronta: **molte promesse su funzioni "che non esistono" nascono perché il commerciale non sa bene cosa il prodotto fa — o non fa.** Non per malafede: per mancanza di conoscenza. E questa è, in un certo senso, una buona notizia, perché è la parte più facile da sistemare.

Pensa a quante volte la risposta del prodotto alla richiesta del commerciale è **"ma quella cosa c'è già!"**. Il commerciale ha promesso di *costruire* una funzione che il prodotto ha da sempre, semplicemente perché non lo sapeva. In quel caso non hai un problema di scope o di promesse avventate: hai un problema di **formazione sul prodotto**. E il costo di non risolverlo è doppio e concreto:

- **Da un lato prometti (e magari costruisci) cose che avevi già** — puro spreco: settimane di sviluppo per rifare qualcosa che esisteva, che poteva essere zero ore e una demo fatta bene.
- **Dall'altro *non* vendi cose che il prodotto fa benissimo**, perché il commerciale non sa che ci sono e non le racconta. Questo è il costo invisibile più grande: funzioni di valore, già costruite e pagate, che non generano una lira in più di fatturato solo perché chi vende le ignora. Un prodotto pieno di capacità che il commerciale non conosce è un magazzino di valore inutilizzato.

Fai il conto grezzo: se un commerciale promette due volte l'anno una funzione "nuova" che in realtà c'era già, e ognuna costa al team qualche settimana di lavoro rifatto inutilmente, sono mesi-uomo l'anno buttati — migliaia di euro — per colmare un buco di conoscenza che un pomeriggio di formazione sul prodotto avrebbe chiuso. E questo *senza* contare le vendite perse per le funzioni mai raccontate.

La cura è semplice e sottovalutata: **il commerciale deve conoscere il prodotto davvero** — cosa fa, cosa non fa, e come si racconta ciò che fa. Non serve che diventi tecnico (abbiamo detto che i dati e i casi limite non sono il suo mestiere), ma deve avere una mappa aggiornata delle capacità del prodotto, così da vendere ciò che c'è invece di promettere ciò che manca. Tenere questa mappa viva e condivisa — è la formazione interna di cui l'azienda ha bisogno anche qui — è uno degli investimenti più redditizi e meno fatti: riduce le promesse a vuoto *e* aumenta le vendite di ciò che già esiste. Prima ancora del processo e del contratto, chiudi il buco più stupido: quello di chi vende senza sapere cosa vende.

## Il contratto: le change request

Finora abbiamo parlato di processo interno. Ma c'è uno strumento che protegge tutti — te, il team e il rapporto col cliente — e va messo nero su bianco: la gestione delle **change request**, cioè le richieste di modifica.

Il principio è semplice e liberatorio: **ciò che è stato concordato è concordato; ciò che si aggiunge dopo è una change request, con il suo tempo e il suo costo.** Non per essere rigidi coi clienti, ma per rendere esplicito e gestibile quello che altrimenti diventa il buco senza fondo dello scope creep — quel gonfiarsi continuo delle richieste "già che ci siamo" che divora il margine e sfianca il team.

Come funziona, in pratica:

- **Si definisce cosa è compreso.** All'inizio, nero su bianco: il prodotto fa queste cose, il progetto comprende queste. È la base contro cui si misura tutto ciò che viene dopo.
- **Ogni aggiunta è una change request.** Quando il cliente (o il commerciale a nome del cliente) chiede qualcosa oltre il concordato, non è un "favore" da infilare gratis: è una richiesta di modifica, che si valuta (si può fare? quanto costa? quanto tempo?) e si concorda a parte. Questo *non* è essere ostili: è essere chiari, e la chiarezza protegge il rapporto più di quanto lo protegga la generosità sregolata.
- **Il cliente decide con i costi davanti.** Messa così, la richiesta torna al cliente con un prezzo e un tempo. Spesso il cliente stesso, vedendo il costo, capisce che quella cosa non gli serve così tanto — e lo scope creep si sgonfia da solo. Altre volte la vuole davvero, la paga, ed è giusto così.

La change request è lo strumento che trasforma il "sì lo facciamo" avventato in una **conversazione onesta sui costi**. Toglie al commerciale la tentazione di promettere gratis (perché sa che ogni aggiunta ha un cartellino) e dà al cliente il controllo delle sue spese (perché decide lui cosa vale la pena aggiungere). È lo stesso meccanismo, dal lato di chi costruisce, che protegge il compratore quando gli spiego [cosa deve esserci in un preventivo serio]({{ '/it/blog/cosa-include-software-su-misura/' | relative_url }}): i confini chiari non sono nemici del rapporto, ne sono la base.

## Il cruscotto: promesse contro backlog

Chiudo con lo strumento che rende visibile e governabile tutto quello di cui abbiamo parlato: un posto dove si vede, in ogni momento, **cosa è stato promesso contro cosa è in programma di costruire.** Chiamalo cruscotto, backlog, lista condivisa: il nome non conta, conta che esista e che vendite e prodotto lo guardino *insieme*.

Cosa deve mostrare, e perché serve:

- **Cosa è stato promesso ai clienti**, da chi e con quali tempi. Se le promesse vivono solo nelle mail dei commerciali, sparse e invisibili, il prodotto non le vede finché non è tardi. Metterle in un posto solo le rende governabili.
- **Cosa è in programma di costruire** (la roadmap, il backlog), con le priorità. Così si vede subito se una promessa ha una corrispondenza nei piani o è campata in aria.
- **Il confronto tra i due.** Ed è il punto: dove le promesse e i piani **non coincidono**, c'è un buco da gestire *prima* che esploda. Una funzione promessa a un cliente ma non in roadmap è un allarme rosso: o entra in roadmap (se ha senso) o va rinegoziata col cliente (se non ce l'ha) — ma subito, non a scadenza sfumata.

Questo cruscotto fa per l'allineamento vendite-prodotto quello che [un buon cruscotto direzionale fa per il titolare]({{ '/it/blog/cruscotto-aziendale-titolare/' | relative_url }}): rende visibile un problema che altrimenti resta sommerso finché non fa danni. Il buco tra promesse e realtà è invisibile finché le promesse stanno nelle mail dei commerciali e i piani nella testa del team di prodotto. Metterli fianco a fianco, guardarli insieme con regolarità, è ciò che trasforma "scopriamo le promesse quando è troppo tardi" in "vediamo i disallineamenti in tempo per gestirli". È l'ultimo pezzo che chiude il buco: prima il processo (le promesse passano dal prodotto), poi il contratto (le aggiunte sono change request), infine la visibilità (promesse e backlog nello stesso quadro).

Se vivi questo dolore — il commerciale che promette, il prodotto che scopre, i clienti in mezzo — il primo passo è mettere in piedi il canale e la visibilità tra chi vende e chi costruisce. [Guarda come lavoro]({{ site.main_site }}/portfolio/) o [scrivimi]({{ site.main_site }}/contatti/) e vediamo come chiudere il buco nel tuo caso. Tutto questo vive nel cluster [comprare (e costruire) software su misura]({{ '/it/pillar/comprare-software/' | relative_url }}): perché un software vive o muore anche da come si allineano quelli che lo vendono e quelli che lo fanno.

## È per te se / non è per te se

**È per te se:**
- hai un **software e qualcuno che lo vende**, e ti è già arrivata la mail "gli ho detto che facciamo anche...";
- il tuo prodotto si sta riempiendo di **funzioni fatte per un cliente solo** che nessun altro usa;
- il team di prodotto scopre le **promesse a cose fatte** ed è sempre in emergenza;
- non hai un **canale** tra vendite e prodotto per validare le richieste prima di impegnarsi;
- le promesse ai clienti vivono **sparse nelle mail**, senza un posto dove confrontarle con la roadmap.

**Non è per te se:**
- sei tu **da solo** a vendere e costruire: il buco vendite-prodotto non esiste (anche se il rischio di promettere troppo a te stesso resta);
- vendi un prodotto **completamente standard** senza mai richieste di modifica: raro, ma se è così il tema ti tocca poco;
- il tuo problema è che il commerciale **non vende abbastanza**, non che promette troppo: è l'opposto, e viene prima.

## 8 domande da chi vive il buco vendite-prodotto

**1. Come dico no a un cliente senza perderlo?**
Con un no onesto e costruttivo, non brusco: "questa cosa specifica oggi il prodotto non la fa, ecco perché e cosa possiamo fare invece". Spesso dietro la richiesta c'è un bisogno che il prodotto sa già risolvere in altro modo — e allora il no alla funzione diventa un sì al bisogno. Il cliente preferisce la verità con una soluzione alla promessa che non manterrai.

**2. Devo costruire ogni funzione che il commerciale promette?**
No, ed è pericoloso: una funzione per un cliente solo la costruisci una volta e la mantieni per sempre, complica il prodotto per tutti e rallenta il resto. La regola è l'80/20: costruisci ciò che serve a molti, gestisci come custom a parte (pagata a parte) ciò che serve a uno solo.

**3. E se la richiesta è invece un'ottima idea per il prodotto?**
Allora il commerciale ha fatto da antenna sul mercato, e va ascoltato. Il criterio è: quanti clienti ne beneficerebbero? Se la stessa cosa la chiedono più clienti, è una funzione di prodotto vera — va messa in roadmap e costruita bene. Se la chiede uno solo, è specifica. Il commerciale è un sensore prezioso; la decisione resta del prodotto.

**4. Perché una cosa che al commerciale sembra piccola per il team è enorme?**
Perché il commerciale vede la punta dell'iceberg (il pulsante, la schermata) e promette su quella; il prodotto deve consegnare anche l'80% invisibile: gli stati, gli errori, i permessi, i dati sporchi, i casi limite. Non è che il team esagera — vede l'iceberg intero, che il commerciale non immagina.

**5. Come metto ordine tra vendite e prodotto?**
Con un processo: il commerciale non promette funzioni che non esistono, ma le porta al prodotto tramite un canale veloce *prima* di impegnarsi. Il prodotto risponde in uno di tre modi (c'è già / la mettiamo in roadmap / non la faremo), e il commerciale dice al cliente qualcosa di vero. La velocità del canale è ciò che lo rende usabile.

**6. Cos'è una change request e perché mi protegge?**
È la gestione delle richieste che arrivano dopo il concordato: ciò che era stato definito è definito, ciò che si aggiunge si valuta e si concorda a parte, con tempo e costo. Non è ostilità: è chiarezza. Toglie al commerciale la tentazione di promettere gratis e dà al cliente il controllo delle spese — spesso lo scope creep si sgonfia da solo quando c'è un prezzo davanti.

**7. Come faccio a non scoprire le promesse troppo tardi?**
Con un posto solo — un cruscotto, un backlog condiviso — dove si vedono fianco a fianco le promesse fatte ai clienti e ciò che è in programma di costruire. Dove non coincidono, c'è un buco da gestire subito. Finché le promesse stanno sparse nelle mail e i piani nella testa del team, il disallineamento è invisibile fino al danno.

**8. Il commerciale è il problema?**
No: il commerciale entusiasta è una risorsa, è la tua antenna sul mercato. Il problema è non avere un modo di trasformare il suo entusiasmo in impegni che il prodotto può mantenere. La soluzione non è zittirlo, è dargli un processo (per validare prima di promettere), un contratto (le change request) e visibilità (promesse contro backlog).
