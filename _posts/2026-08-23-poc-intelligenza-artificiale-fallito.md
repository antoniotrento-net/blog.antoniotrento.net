---
lang: it
permalink: /it/blog/poc-intelligenza-artificiale-fallito/
alt_url: /en/blog/failed-ai-proof-of-concept/
title: "Hai speso decine di migliaia in un PoC di AI finito in un cassetto. Come (non) rifarlo"
date: 2026-08-23 07:30:00 +0200
author: "Antonio Trento"
description: "Il workshop da 40.000 euro, la demo che stupiva, e poi un notebook che nessuno apre più. Perché i PoC di AI muoiono, come valutare un secondo tentativo senza bruciare altro budget, e le clausole da pretendere nel contratto."
keywords: ["poc intelligenza artificiale fallito", "progetto ai cassetto", "proof of concept vs produzione", "budget ai sprecato", "go live agente ai"]
image: /assets/images/posts/poc-intelligenza-artificiale-fallito.jpg
pillar: comprare-software
related: [/it/blog/lanciare-prodotto-ai-white-label/, /it/blog/data-analyst-non-basta/]
---

## Il workshop da 40.000 euro e il notebook che nessuno apre

Ci sei passato, o conosci chi ci è passato. È arrivata una società, o un consulente, con un discorso convincente sull'intelligenza artificiale. Workshop, analisi, un proof of concept. Hai firmato per qualche decina di migliaia di euro. Dopo qualche settimana ti hanno mostrato una demo che funzionava: faceva la cosa promessa, tutti hanno detto «wow», la direzione era soddisfatta. E poi? Poi niente. Quel PoC è finito in un cassetto — o meglio, in un notebook tecnico su un computer, che nessuno apre più. In azienda non è cambiato nulla, tranne il budget, che è sparito.

Questo è il destino della maggioranza dei **PoC di intelligenza artificiale**: nascono per "dimostrare che si può fare", lo dimostrano, e muoiono lì. Perché "si può fare" e "lo usiamo davvero, ogni giorno, in produzione" sono due pianeti diversi, e tra i due c'è tutto il lavoro vero — quello che il PoC, per definizione, salta. Il risultato è che ti ritrovi con la prova che una cosa è possibile, e zero cose che funzionano. È **budget AI sprecato**, e ti lascia con l'amaro in bocca e la tentazione di concludere che "l'AI non fa per noi".

Questo articolo è per chi si è bruciato con un **progetto AI finito in un cassetto** e non vuole rifare l'errore — né buttare via l'idea che l'AI possa servire davvero. Vediamo perché i PoC muoiono (con una lista precisa delle cause di morte), come si valuta un secondo tentativo senza bruciare altro budget, cosa deve essere vero *prima* di scrivere una riga di codice, e le clausole da pretendere in un contratto perché stavolta finisca in produzione e non in un cassetto.

## PoC vs prodotto: il pianeta che la demo non ti mostra

La radice del problema è una confusione, spesso in buona fede: si scambia un **PoC per un prodotto**. Un proof of concept dimostra che una certa cosa è tecnicamente possibile — che il modello, su un esempio pulito, produce il risultato giusto. È utile per togliere un dubbio. Ma un prodotto è un'altra cosa: è qualcosa che persone reali usano, sui loro dati veri, tutti i giorni, dentro i loro orari e i loro processi. E tra il PoC e il prodotto c'è tutto ciò che la demo non mostra.

La demo funziona perché gira in condizioni ideali: un dato pulito, scelto apposta, un caso normale, nessun utente vero, nessun errore, nessun carico. Il prodotto vive nel mondo reale, dove i dati sono sporchi, i casi sono strani, gli utenti fanno cose impreviste, le cose vanno storte alle tre di notte, e i volumi mettono sotto pressione tutto. È esattamente la stessa distinzione che vale quando si vuole [trasformare una demo AI in un prodotto vendibile]({{ '/it/blog/lanciare-prodotto-ai-white-label/' | relative_url }}): il «wow» era la punta, sotto c'è l'iceberg. Il PoC ti mostra la punta e ti fa credere di aver visto la montagna.

Cosa manca, in concreto, tra il PoC e il prodotto? Gli **utenti** (chi lo usa, come entra, cosa può fare). I **permessi** (chi vede cosa). La gestione degli **errori** (cosa succede quando il modello sbaglia o non sa — e succede). Gli **orari** e l'affidabilità (funziona sempre, non "quando lo lancia il tecnico"). L'integrazione con i **dati veri** e i sistemi esistenti. Il **controllo dei costi** quando i volumi salgono. Sono tutti pezzi che il PoC salta perché "servono solo a dimostrare che si può" — e sono, guarda caso, la maggior parte del lavoro e del valore.

## Chi ti ha venduto la demo: il modello, non il processo

Vale la pena capire *perché* ti hanno venduto un PoC che sapevano (o dovevano sapere) sarebbe finito nel cassetto. Non sempre è malafede; spesso è che chi te l'ha venduto sa fare **il modello, non il processo**. Sono bravi con la tecnologia AI — i modelli, i prompt, gli algoritmi — ma non hanno mai messo un software in produzione dentro un'azienda vera, con i suoi utenti, i suoi dati sporchi, la sua operatività. Così ti vendono ciò che sanno fare (una dimostrazione tecnica) chiamandolo con il nome di ciò che ti serve (una soluzione).

Il segnale che riconosci col senno di poi: hanno parlato tanto di *tecnologia* (quale modello, quanto è avanzato, cosa può fare) e pochissimo del tuo *processo* (chi lo userà il martedì mattina, come si integra con quello che hai, cosa succede quando sbaglia). Un progetto che finisce in produzione parte dal processo e usa la tecnologia come mezzo; un PoC da cassetto parte dalla tecnologia e non arriva mai al processo. È lo stesso motivo per cui [assumere un data analyst non basta a sistemare i dati]({{ '/it/blog/data-analyst-non-basta/' | relative_url }}): la competenza tecnica isolata, senza il sistema e il processo attorno, non produce risultati che restano.

## Le cause di morte di un PoC (la lista)

Se guardi i PoC che muoiono, le cause si ripetono. Tienile a mente, perché sono anche la checklist di cosa evitare al secondo tentativo:

- **Nato per stupire, non per essere usato.** L'obiettivo era la demo alla direzione, non l'operatore che lo usa ogni giorno. Missione compiuta (il «wow»), e fine.
- **Dati finti o puliti a mano.** Funzionava sui dati scelti per la demo; sui dati veri, sporchi e pieni di eccezioni, si inceppa. Il salto ai dati veri non è stato mai fatto.
- **Nessun utente vero coinvolto.** Costruito senza chi lo userà, quindi scollato da come si lavora davvero. Quando lo si è messo in mano a un operatore, non ci si è ritrovato.
- **Nessuna gestione dell'errore.** Il modello a volte sbaglia o non sa; il PoC non prevedeva cosa fare in quei casi, quindi in produzione era inaffidabile e la fiducia è crollata al primo errore visibile.
- **Nessuna integrazione.** Girava a lato, isolato; per usarlo davvero bisognava collegarlo ai sistemi aziendali, e quel lavoro non era previsto né budgetato.
- **Nessun proprietario interno.** Finito il consulente, nessuno in azienda lo possedeva, lo manteneva, lo faceva evolvere. È morto per abbandono.
- **Costi non previsti a regime.** In demo costava poco; ai volumi veri il costo del modello o dell'infrastruttura era insostenibile, e ci si è fermati.

Se il tuo PoC è morto, quasi certamente riconosci due o tre di queste cause. Non è sfortuna: è che il progetto era strutturato per dimostrare, non per durare.

## Il conto: cosa hai speso davvero

Facciamo i conti onesti, perché il costo di un PoC fallito non è solo la fattura. C'è la **fattura diretta** (le decine di migliaia di euro del workshop e del PoC), ma ci sono almeno altre due voci. C'è il **tempo interno** bruciato: le riunioni, le persone coinvolte, l'attenzione della direzione, tutto speso per arrivare a un cassetto. E c'è il **costo di opportunità** peggiore: la sfiducia. Dopo un PoC fallito, in azienda si diffonde il "l'abbiamo provato, l'AI non fa per noi", e quella convinzione blocca anche i progetti che avrebbero funzionato. Hai pagato per dimostrare una possibilità, e hai ottenuto una convinzione sbagliata sul contrario.

| Voce | Realtà |
|---|---|
| Fattura PoC / workshop | decine di migliaia di € |
| Tempo interno (riunioni, persone, direzione) | raramente contato, reale |
| Costo peggiore: la sfiducia | "l'AI non fa per noi" blocca i progetti buoni |
| Cosa è cambiato in azienda | nulla |

Questo conto serve a una cosa: al secondo tentativo, valutare il costo non sul prezzo del PoC ma sul **valore che porta in produzione**. Un progetto che costa di più ma arriva in produzione e fa risparmiare ore ogni mese vale infinitamente più di un PoC economico che dimostra e muore. Il metro giusto non è "quanto costa la prova", è "quanto vale la cosa quando la usiamo davvero".

## Come valutare un secondo tentativo senza bruciare altro

Ti sei bruciato una volta e giustamente sei diffidente. Ma buttare l'idea sarebbe l'errore opposto. Il modo per fare un secondo tentativo senza rischiare un altro cassetto è cambiare i criteri con cui scegli e imposti il progetto. Ecco i criteri del secondo tentativo:

**Parti dal processo, non dalla tecnologia.** La prima domanda non è "quale modello AI usiamo", è "quale problema costoso e ripetitivo risolviamo, per chi, e come lo usa il martedì". Se chi ti propone il progetto parte dalla tecnologia, è il segnale di prima.

**Pretendi utenti veri dall'inizio.** Il progetto deve coinvolgere chi lo userà fin da subito, e lavorare sui dati veri, sporchi, non su un esempio pulito. Se il piano è "prima dimostriamo su dati di test, poi vedremo", stai rifacendo il PoC da cassetto.

**Chiedi che si affronti l'errore.** Cosa fa il sistema quando il modello sbaglia o non sa? Se la risposta è vaga, il progetto è ancora un PoC travestito. In produzione, la gestione dell'errore è metà del lavoro.

**Definisci il "fatto".** Non "una demo che funziona", ma "un operatore usa questa cosa, in produzione, sui dati veri, e ci risparmia X". Il criterio di successo dev'essere l'uso reale, non l'approvazione in riunione.

**Chiedi chi lo possiede dopo.** Finito il progetto, chi lo mantiene, chi lo fa evolvere, con quale codice e quali dati (tuoi). Se non c'è una risposta, hai già il seme del prossimo cassetto.

## Cosa deve essere vero prima di scrivere una riga

Prima ancora di firmare, alcune cose devono essere vere, o il progetto parte già zoppo. È la parte noiosa che tutti vogliono saltare per "iniziare subito", ed è proprio quella che separa un progetto che arriva in produzione da uno che muore.

Deve essere chiaro **il problema e il suo valore**: quanto costa oggi (in ore, euro, errori) la cosa che vogliamo risolvere. Se non sai quanto vale, non saprai se il progetto ha avuto successo. Devono essere accessibili **i dati veri**: dove stanno, in che stato sono, chi li possiede. Un progetto AI vive sui dati, e se sono un pantano non affrontato, si impantana anche il progetto. Deve esserci **una persona interna** che ci crede e lo segue — il "proprietario" che dopo terrà viva la cosa. E deve esserci accordo su **cosa NON fa**: i limiti, dove l'AI aiuta e dove decide un umano.

Su quest'ultimo punto vale la regola che ripeto ovunque: l'AI prepara, controlla, propone; l'essere umano decide dove la decisione ha conseguenze. È il confine che tiene un progetto AI dentro i binari della responsabilità, lo stesso di cui parlo per [i processi dove l'AI incontra decisioni che contano]({{ '/it/blog/portale-dossier-credito/' | relative_url }}). Un progetto che promette "l'AI che decide tutto" è un progetto che promette guai.

## L'MVP che un operatore usa il martedì

Qual è l'alternativa sana al PoC? Un **MVP che un operatore usa il martedì**. Non una demo che stupisce la direzione, ma la versione minima di una cosa vera: un flusso, fatto bene, che una persona reale usa nel suo lavoro reale, sui dati veri, e che le fa risparmiare tempo o le toglie un errore. Piccolo, ma vero — con gli utenti, i permessi base, la gestione dell'errore, l'integrazione minima coi dati. Un prodotto in miniatura, non una dimostrazione.

La differenza è sostanziale. Il PoC dice "guarda, si può fare" e finisce lì. L'MVP dice "guarda, Maria lo sta usando da due settimane e ci mette la metà del tempo" — e da lì si allarga. L'MVP crea una prova che *resta* (un pezzo di produzione che funziona) invece di una prova che *evapora* (una demo archiviata). Come per [ogni cosa che va messa in mano a chi lavora davvero]({{ '/it/pillar/app-interne/' | relative_url }}), è l'uso reale sul campo che valida un progetto, non l'applauso in sala riunioni. Se il secondo tentativo produce un MVP che qualcuno usa il martedì, sei sulla strada giusta; se produce un'altra demo, sei di nuovo verso il cassetto.

## Un caso tipo: il secondo tentativo fatto bene

Un profilo tipico, architetturale, senza nomi. Un'azienda si era bruciata con un PoC di AI costato parecchio: una società tecnologica aveva mostrato una demo brillante su un caso scelto, la direzione aveva applaudito, e poi il tutto era finito in un notebook che nessuno apriva. In azienda serpeggiava il "l'abbiamo provato, non funziona". Il problema vero — un lavoro documentale ripetitivo e costoso — era però reale e ancora lì, irrisolto.

Cosa si è fatto di diverso al secondo tentativo. Prima si è messo da parte l'entusiasmo tecnologico e si è quantificato il problema: quante ore, quanti errori, quanto costava davvero ogni mese. Poi si è partiti dai dati veri (sporchi, con le eccezioni) e da un operatore che quel lavoro lo faceva ogni giorno, coinvolto fin dal primo giorno. Non una demo per la direzione, ma un MVP: un solo flusso, con l'interfaccia vera, la gestione dei casi in cui l'AI non era sicura (che passavano all'operatore invece di produrre un risultato sbagliato), e l'integrazione minima coi dati aziendali. Nel contratto: proprietà del codice, manutenzione dichiarata, e fasi con punti di uscita.

A regime, la differenza non è stata "abbiamo l'AI": è stata che l'operatore ha cominciato a usare la cosa il martedì, davvero, risparmiando tempo su quel lavoro — e da lì si è allargato con fiducia, perché c'era una prova che *restava* invece di una demo che era evaporata. La nota onesta: è costato più del PoC iniziale, ma ha prodotto un pezzo di produzione che funziona, invece di un cassetto. Il metro non era il prezzo della prova, ma il valore della cosa in uso reale.

## Chi lo costruisce: una mano sola

Un motivo ricorrente per cui i PoC muoiono e i secondi tentativi riescono sta nel *chi* costruisce. Un progetto AI che arriva in produzione è **dati + backend + interfaccia + AI** insieme: il modello serve a poco se i dati non sono collegati e puliti, se non c'è un'interfaccia che un operatore usa, se non c'è la logica che gestisce l'errore e i permessi. Chi ti ha venduto il PoC spesso sapeva fare solo il pezzo AI (il modello, il prompt) e non aveva mai messo un software in produzione: per questo la demo era brillante e la produzione impossibile.

Un progetto serio lo fa una testa (o un team affiatato) che tiene insieme tutti e quattro gli strati, perché le decisioni sono intrecciate: come gestisco l'errore del modello dipende da come è fatta l'interfaccia, che dipende da come sono strutturati i dati. Se spezzi il progetto tra "quelli dell'AI", "quelli del backend" e "quelli dell'interfaccia", ottieni tre mondi che non si parlano e, di nuovo, qualcosa che non arriva in produzione. Serve una regia unica end-to-end — la stessa logica che vale per [trasformare una demo in un prodotto vero]({{ '/it/blog/lanciare-prodotto-ai-white-label/' | relative_url }}).

## Il contratto: proprietà, manutenzione, criteri di uscita

Parliamo del contratto, perché è lì che ti proteggi dal secondo cassetto. Ci sono clausole precise da pretendere, e la disponibilità del fornitore ad accettarle è già di per sé un test: chi costruisce cose vere non ha problemi con queste richieste; chi vende demo si irrigidisce.

**La proprietà.** Codice, dati e modello (nella parte che è tua) restano tuoi. Nessun vendor lock-in: se domani cambi fornitore, ti porti via tutto e qualcun altro può proseguire. Un progetto dove il codice resta del fornitore è un progetto che ti tiene in ostaggio.

**La manutenzione.** Chi tiene viva la cosa dopo il go-live, con quali tempi e a quali costi. Un progetto AI non "finisce": i dati cambiano, i modelli evolvono, le regole aziendali si aggiornano. Senza manutenzione dichiarata, anche un MVP riuscito muore a rate.

**I criteri di successo e di uscita.** Cosa vuol dire che il progetto ha funzionato (l'uso reale, il risparmio misurato), e cosa succede se non funziona: come ci si ferma, cosa resta a te, senza strascichi. Definire *prima* come si esce è ciò che ti evita di restare invischiato in un progetto che non decolla.

**Le fasi con punti di uscita.** Il progetto va spezzato in fasi con verifiche reali tra una e l'altra, così puoi fermarti dopo una fase se i risultati non ci sono, senza aver impegnato tutto il budget. Chi ti chiede di firmare tutto in blocco "perché l'AI va vista nel suo insieme" ti sta togliendo proprio la protezione che ti serve.

## Quando è meglio fermarsi

L'onestà che ti devo: a volte la risposta giusta è non farlo. Se il problema non è abbastanza costoso da giustificare il progetto, se i dati sono un pantano che nessuno vuole sistemare, se non c'è una persona interna disposta a possederlo, se l'unica spinta è "tutti fanno l'AI e allora anche noi" — allora fermarsi è la scelta intelligente, e ti fa risparmiare il secondo cassetto. Non ogni problema ha bisogno di AI, e non ogni azienda, in questo momento, ha le condizioni perché un progetto attecchisca.

Fermarsi consapevolmente è molto diverso dal fallire: è decidere di non spendere dove non ci sono le condizioni, e magari sistemare prima le fondamenta (i dati, un processo, una persona) per poi riprovare quando ha senso. Chi ti dice sempre "sì, si può fare" ti sta vendendo; chi ogni tanto ti dice "aspetta, così non ha senso" ti sta consigliando.

## È per te se / non è per te se

**È per te se:** hai già bruciato budget in un PoC di AI finito in un cassetto e non vuoi rifare l'errore; hai un problema costoso e ripetitivo che l'AI potrebbe davvero aiutare, e persone vere che lo userebbero; sei disposto a partire dal processo e dai dati veri, non dalla tecnologia; vuoi un MVP che qualcuno usa il martedì, con proprietà e manutenzione chiare.

**Non è per te se:** cerchi di nuovo una demo che stupisca la direzione (è la strada del cassetto); non hai un problema costoso definito, solo il "dobbiamo fare l'AI"; i dati sono un pantano che nessuno vuole affrontare; non c'è una persona interna disposta a possedere la cosa dopo. In questi casi, meglio fermarsi o sistemare prima le fondamenta.

## Domande frequenti

**Perché il nostro PoC è finito in un cassetto?**
Quasi certamente perché era nato per dimostrare, non per essere usato: dati puliti a mano, nessun utente vero, nessuna gestione dell'errore, nessuna integrazione, nessun proprietario interno dopo. Sono le cause di morte tipiche. Non è sfortuna: era strutturato per la demo, non per la produzione.

**Vuol dire che l'AI non fa per noi?**
No, ed è la conclusione sbagliata più pericolosa. Vuol dire che *quel* progetto era impostato male. Un secondo tentativo che parte dal processo, dai dati veri e da un MVP che un operatore usa davvero può funzionare benissimo. Non buttare l'idea per colpa di un PoC fatto per stupire.

**Come evito di bruciare altro budget?**
Cambiando i criteri: parti dal processo non dalla tecnologia, pretendi utenti e dati veri dall'inizio, chiedi come si gestisce l'errore, definisci il "fatto" come uso reale (non demo), e spezza il progetto in fasi con punti di uscita. E metti nel contratto proprietà, manutenzione e criteri di uscita.

**Qual è la differenza tra PoC e MVP?**
Il PoC dimostra che una cosa è possibile, in condizioni ideali, e poi muore. L'MVP è la versione minima di un prodotto vero: un flusso che una persona reale usa in produzione, sui dati veri, con permessi e gestione dell'errore. Il PoC evapora; l'MVP resta e si allarga. Vuoi il secondo, non il primo.

**Che clausole devo pretendere nel contratto?**
Proprietà di codice e dati (niente lock-in), manutenzione dichiarata (chi tiene viva la cosa, come, a che costo), criteri di successo e di uscita (cosa vuol dire riuscito, cosa succede se non funziona), e fasi con punti di uscita (per fermarti senza aver impegnato tutto). La disponibilità del fornitore ad accettarle è già un test.

**Come faccio a fidarmi di un nuovo fornitore dopo la fregatura?**
Guarda di cosa parla: se parla soprattutto di tecnologia e modelli, diffida; se parte dal tuo processo, dai tuoi dati, da chi userà la cosa e da come si gestisce l'errore, è un buon segno. E metti alla prova con le clausole: chi costruisce cose vere le accetta, chi vende demo si irrigidisce.

**Possiamo riusare il PoC che abbiamo pagato?**
A volte un pezzo sì (un'idea validata, un pezzo di logica), ma spesso il PoC va ripensato per la produzione, perché era costruito per dimostrare, non per durare. Non partire dal presupposto "abbiamo già metà del lavoro": quella metà era la punta dell'iceberg. Valuta cosa è davvero riusabile senza affezionarti al budget già speso.

**Quando è meglio non fare il progetto?**
Quando il problema non è abbastanza costoso, quando i dati sono un pantano che nessuno vuole sistemare, quando manca una persona interna che possieda la cosa, o quando l'unica spinta è "lo fanno tutti". In quei casi fermarsi (o sistemare prima le fondamenta) è la scelta giusta e ti risparmia il secondo cassetto.

## In una riga

Un **PoC di AI finito in un cassetto** non significa che l'AI non fa per te: significa che il progetto era fatto per stupire, non per durare — dati puliti a mano, nessun utente vero, nessuna gestione dell'errore, nessun proprietario dopo. Al secondo tentativo, cambia i criteri: parti dal processo e dai dati veri, punta a un MVP che un operatore usa il martedì (non a un'altra demo), e metti nel contratto proprietà, manutenzione e criteri di uscita. E se le condizioni non ci sono — problema poco costoso, dati un pantano, nessun proprietario — fermarsi è la scelta giusta, non un fallimento.

Se ti sei bruciato con un PoC e vuoi capire se e come farlo arrivare davvero in produzione, guarda i [progetti che ho costruito]({{ site.main_site }}/portfolio/) o [scrivimi due righe]({{ site.main_site }}/contatti/): partiamo dal problema, dai dati veri e da chi userà la cosa il martedì, non da una demo per la direzione.
