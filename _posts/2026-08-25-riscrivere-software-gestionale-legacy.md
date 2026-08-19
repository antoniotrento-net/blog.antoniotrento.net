---
lang: it
permalink: /it/blog/riscrivere-software-gestionale-legacy/
title: "Il tuo software interno è un Access del 2008: quando conviene riscriverlo (e quando è un suicidio)"
date: 2026-08-25 07:30:00 +0200
author: "Antonio Trento"
description: "Un file .mdb su un solo PC tiene in piedi l'azienda, e ogni giorno hai più paura che si rompa. Quando conviene riscrivere un gestionale legacy, cosa conservare, e perché il rewrite totale in un colpo solo è un suicidio."
keywords: ["riscrivere software gestionale legacy", "migrare access", "applicazione obsoleta azienda", "modernizzare gestionale", "costo rewrite software"]
image: /assets/images/posts/riscrivere-software-gestionale-legacy.jpg
pillar: comprare-software
related: [/it/blog/app-interna-aziendale-copia-incolla/, /it/blog/sito-vetrina-vs-prodotto-digitale/]
---

## Il file .mdb che tiene in piedi l'azienda

C'è un file, in tante aziende italiane, che vale più di tutto il resto messo insieme e sta su un solo computer. È il gestionale interno fatto anni fa — un Access del 2008, un programma in Visual Basic, un applicativo che un consulente ormai irreperibile ha costruito su misura quando l'azienda era più piccola. Dentro c'è tutto: i clienti, gli ordini, il magazzino, le regole di come lavora l'azienda. E ogni giorno che passa, la paura cresce: che quel PC si rompa, che il file si corrompa, che la persona che "sa come funziona" se ne vada. Perché se succede, l'azienda si ferma.

È una situazione più comune di quanto sembri, e ha una caratteristica paradossale: **il software legacy funziona** — è per questo che è ancora lì. Fa il suo lavoro, l'azienda ci gira sopra da anni, gli operatori lo conoscono a memoria. Il problema non è che non funziona: è che è **fragile e prigioniero**. Gira su un solo PC (o su una rete che nessuno oserebbe toccare), lo capisce una persona sola, il backup è "la copia del file sulla chiavetta", e non si può far crescere perché chi l'ha fatto non c'è più o la tecnologia è morta. È una bomba a orologeria che continua a segnare l'ora giusta — finché non esplode.

Questo articolo è per chi ha un **software gestionale legacy** e si chiede se sia arrivato il momento di riscriverlo. È una decisione seria, con una parte di paura (e se si rompe?) e una di opportunità (potremmo finalmente farlo bene). Vediamo i sintomi che dicono "è ora", cosa va conservato e cosa buttato, perché il **rewrite** totale in un colpo solo è quasi sempre un suicidio, e come si fa invece un piano a strati che non ferma l'azienda. Con forchette di costo e tempo oneste, non promesse.

## I sintomi: quando è davvero ora di riscrivere

Non tutti i software vecchi vanno riscritti. "Vecchio" non è un difetto se funziona, è affidabile e ti basta. Il rewrite serve quando compaiono certi **sintomi di fragilità o di blocco**, e vale la pena riconoscerli, perché è la differenza tra un intervento necessario e uno fatto per moda.

- **Un solo PC, una sola persona.** Il software gira su una macchina sola, e se si rompe l'azienda si ferma. Oppure lo capisce una persona sola, e quando è in ferie o (peggio) se ne va, nessuno sa metterci mano. Hai costruito l'operatività su un punto singolo di rottura, umano o tecnico.
- **Il backup è "la chiavetta".** Non c'è un backup serio, automatico, verificato. C'è una copia manuale che qualcuno fa quando si ricorda. Il giorno che il file si corrompe (e i file si corrompono), scopri che l'ultima copia buona è di tre settimane fa.
- **Non si può far crescere.** Ti serve una funzione nuova, un accesso da fuori, un collegamento con un altro sistema, e la risposta è sempre "non si può", perché chi l'ha fatto non c'è, o la tecnologia è morta e nessuno la tocca più.
- **Gira su cose che non esistono più.** Richiede una versione vecchia di Windows, un componente non più supportato, un PC che non puoi sostituire perché il software non gira su quelli nuovi. Sei ostaggio di un museo dell'informatica.
- **Nessuno lo può mantenere.** L'autore è irreperibile, il codice non c'è o è indecifrabile, e ogni piccola modifica è un terno al lotto. Sei bloccato su ciò che fa oggi, per sempre.

Se riconosci due o tre di questi sintomi, non è "vecchio ma funziona": è una **fragilità che ti costa** — in rischio e in opportunità mancate. Se invece il software è vecchio ma gira su una base sana, ha backup seri, qualcuno lo mantiene e ti basta, allora lascialo stare: riscrivere per moda è buttare soldi.

## Il costo di non fare niente (e il rischio)

Prima di parlare del costo del rewrite, parliamo del costo di *non* farlo, perché è quello che di solito si sottovaluta. Ha due facce.

La faccia visibile è l'**opportunità mancata**: tutte le cose che non puoi fare perché il software non lo permette. L'accesso da fuori che ti servirebbe, l'integrazione con l'e-commerce, il dato che dovresti estrarre e non riesci, la funzione che velocizzerebbe il lavoro. Ogni "non si può" è un pezzo di efficienza o di fatturato che lasci sul tavolo perché sei prigioniero di un software che non evolve.

La faccia invisibile, e più pericolosa, è il **rischio**: la probabilità, che cresce ogni anno, che qualcosa si rompa in modo catastrofico. Il PC che muore, il file che si corrompe senza backup buono, la persona che se ne va portandosi via la conoscenza. Non è un "se", è un "quando", e il costo quando succede non è graduale: è l'azienda ferma per giorni, dati persi, operatività da ricostruire nel panico. È lo stesso ragionamento sul rischio nascosto che vale per [i processi che vivono nella testa di una persona sola]({{ '/it/blog/app-interna-aziendale-copia-incolla/' | relative_url }}): finché la persona (o il PC) c'è, sembra tutto a posto; il costo si manifesta tutto insieme quando manca. Riscrivere non è solo "modernizzare": è togliere una bomba prima che esploda.

## Cosa conservare: le regole di business, non le maschere grigie

Ecco il punto più importante e più frainteso del rewrite: **cosa si conserva e cosa si butta**. L'errore classico è pensare "rifacciamo uguale, ma moderno" — riprodurre le stesse maschere grigie, gli stessi flussi, la stessa logica, solo con una tecnologia nuova. È uno spreco doppio: ti porti dietro tutti i difetti del vecchio, e non sfrutti l'occasione per fare meglio.

La cosa che vale, dentro un gestionale legacy, non sono le maschere: sono le **regole di business**. Anni di logica aziendale ci sono sedimentati dentro — come si calcola uno sconto, come si gestisce un caso particolare, quali controlli si fanno, quali eccezioni si trattano. Quelle regole sono un patrimonio, spesso non scritto da nessun'altra parte, e vanno **capite e conservate**. Le maschere grigie degli anni 2000, invece, vanno buttate senza rimpianti: erano il modo in cui *allora* si mostravano quelle regole, non le regole stesse.

Quindi il rewrite fatto bene fa due lavori distinti: **estrae e conserva le regole** (spesso è un lavoro di archeologia: capire cosa fa davvero il vecchio software, eccezioni comprese, perché è lì che sta il valore), e **ributta via l'interfaccia** per rifarla su come si lavora oggi. Il risultato non è "il vecchio gestionale ma moderno": è un prodotto che fa le stesse cose importanti in un modo migliore, senza i vincoli di trent'anni fa. Distinguere la regola (da tenere) dalla maschera (da rifare) è ciò che separa un rewrite intelligente da una fotocopia costosa.

## L'interfaccia nuova che gli operatori accettano

Un rischio concreto del rewrite: gli operatori che il vecchio software lo conoscono a memoria e odiano il nuovo. È un rischio serio, perché un rewrite tecnicamente perfetto che gli operatori rifiutano è un fallimento. La chiave è che l'interfaccia nuova non sia solo "più bella", ma **più veloce** per chi ci lavora tutto il giorno.

Gli operatori del legacy hanno le dita in automatico: sanno che per fare una cosa premono tab-tab-invio, conoscono le scorciatoie, sono velocissimi anche su una maschera brutta. Se il nuovo software è bello ma li rallenta — più clic, meno scorciatoie, flussi diversi "perché è moderno" — lo vivono come un peggioramento, e hanno ragione. L'interfaccia nuova va progettata *con* loro, guardando come lavorano davvero, mantenendo (o migliorando) la velocità sui gesti frequenti, con le scorciatoie da tastiera per chi inserisce a raffica. La modernità non è il mouse e i colori: è togliere attrito, come per [ogni app interna che le persone accettano solo se le fa risparmiare tempo]({{ '/it/pillar/app-interne/' | relative_url }}).

Il messaggio agli operatori dev'essere concreto: il nuovo software fa le stesse cose *almeno* alla stessa velocità, e in più toglie i difetti del vecchio (i crash, i limiti, le cose che "non si potevano fare"). Se lo percepiscono come un upgrade della loro giornata e non come un capriccio della direzione, lo adottano. Se lo percepiscono come "ci hanno cambiato il software e ora sono più lento", lo sabotano — e nessuna bellezza dell'interfaccia salva il progetto.

## Rewrite totale vs strappare un pezzo

Arriviamo alla decisione strategica: si riscrive tutto, o si strappa via un pezzo alla volta? Nella maggior parte dei casi, la risposta giusta è la seconda, e capire perché ti risparmia il "suicidio" di cui parlo tra poco.

Il **rewrite totale** (rifare tutto da zero e sostituire il vecchio con il nuovo in un colpo solo) è affascinante sulla carta e disastroso nella pratica, per un motivo semplice: mentre lo fai, l'azienda continua a lavorare sul vecchio, e il vecchio continua a cambiare (nuove esigenze, correzioni). Ti ritrovi a inseguire un bersaglio mobile per mesi o anni, con un nuovo software che non è mai "pronto" perché il vecchio non sta fermo, e un giorno di "cutover" (il passaggio dal vecchio al nuovo) terrificante, dove tutto deve funzionare al primo colpo o l'azienda si ferma.

**Strappare un pezzo alla volta** è meno eroico e molto più sano: si identifica un modulo o una funzione, si rifà quello bene, lo si mette in produzione accanto al vecchio, e quando funziona si passa al pezzo successivo. Il vecchio e il nuovo convivono per un po', con i dati che restano allineati, e la sostituzione avviene per strati invece che con un salto nel vuoto. Ogni pezzo che funziona riduce il rischio e crea fiducia; se qualcosa va storto, va storto su un pezzo, non su tutta l'azienda. È lo stesso principio del rollout graduale che vale per [ogni prodotto che va messo in mano a utenti veri]({{ '/it/blog/sito-vetrina-vs-prodotto-digitale/' | relative_url }}): si valida un pezzo, poi si allarga, invece di accendere tutto insieme e sperare.

## Il suicidio: rifare tutto senza cutover, mentre si lavora come prima

Vale la pena essere espliciti su qual è il modo sbagliato, perché è quello che tante aziende scelgono d'istinto e che manda a monte i progetti di rewrite. Il **suicidio** è questo: decidere di riscrivere tutto il gestionale da zero, in un progetto lungo mesi o anni, mentre l'azienda continua a lavorare esattamente come prima sul vecchio, e rimandare il passaggio (il cutover) a un unico grande giorno alla fine.

Perché è un suicidio? Perché accumula tutto il rischio in un punto solo, alla fine, quando hai già speso tutto il budget. Per mesi non vedi risultati in produzione — solo un nuovo software "quasi pronto" che nessuno usa davvero. Il vecchio nel frattempo cambia, e il nuovo insegue. E il giorno del cutover, devi spegnere il vecchio e accendere il nuovo su tutto, in una volta, sperando che funzioni: i dati migrati bene, tutte le funzioni al loro posto, tutti gli operatori pronti. Se qualcosa non va — e qualcosa non va sempre — l'azienda si ferma, e non hai un vecchio a cui tornare facilmente perché ci hai costruito il cutover sopra. Molti rewrite falliti sono morti esattamente così: non per incapacità tecnica, ma per aver scelto il salto nel vuoto invece del piano a strati.

## Il piano a strati

L'alternativa sana ha un nome: **piano a strati** (o migrazione incrementale). Invece di sostituire tutto in un colpo, si procede per strati successivi, ognuno dei quali porta valore e riduce rischio. Grosso modo funziona così.

Prima si mette in sicurezza la **base**: i dati. Si porta il patrimonio informativo del vecchio software (clienti, ordini, storico) in una base dati moderna, solida, con backup automatici seri — anche se le funzioni girano ancora sul vecchio. Questo, da solo, toglie subito il rischio più grosso (il file sulla chiavetta) e prepara il terreno.

Poi si **strappa il primo pezzo**: si sceglie una funzione — magari quella che fa più male, o quella più a rischio — e la si rifà bene, in produzione, collegata alla base dati nuova. Gli operatori usano il pezzo nuovo per quella funzione e il vecchio per il resto. Quando il pezzo nuovo è solido, si passa al successivo. Strato dopo strato, il nuovo cresce e il vecchio si svuota, finché il vecchio non serve più e lo si spegne — senza un cutover terrificante, perché il passaggio è già avvenuto pezzo per pezzo.

Questo approccio ha tre vantaggi enormi: **porti valore subito** (ogni strato migliora qualcosa, non aspetti la fine), **riduci il rischio** (se un pezzo va storto, è un pezzo), e **puoi fermarti** (se dopo alcuni strati decidi che basta, hai comunque migliorato, non hai un cantiere a metà inutilizzabile). È più lento e meno spettacolare del "rifacciamo tutto", ma è il modo in cui i rewrite arrivano in fondo invece di morire.

## Costo e tempo: forchette oneste

Quanto costa e quanto ci vuole? Non ti darò numeri precisi (chi te li dà senza aver visto il tuo software mente), ma delle forchette qualitative oneste. Il costo di un rewrite dipende soprattutto da due cose: **quanto è complessa la logica** sedimentata nel vecchio (quante regole, quante eccezioni da capire e conservare) e **quanto sono accessibili i dati e il codice** del vecchio (un Access documentato è un conto, un eseguibile di cui nessuno ha il sorgente è un altro).

In termini di tempo, un rewrite a strati non è "una settimana" né "sei mesi e sparisce il problema": è un percorso di mesi, in cui però vedi risultati lungo la strada (ogni strato), non solo alla fine. La parte più lunga e sottovalutata non è scrivere il nuovo codice: è **capire il vecchio** — l'archeologia delle regole di business, specialmente quando non sono documentate e vivono solo nel comportamento del software e nella testa di chi lo usa. Chi ti promette un rewrite rapido probabilmente non ha capito quanta logica c'è da estrarre, e la scoprirà a metà strada, sforando.

Il modo giusto di valutare il costo non è in assoluto, ma contro il costo di *non* farlo: il rischio che cresce ogni anno e le opportunità che perdi. Su come si valuta cosa stai comprando quando commissioni uno sviluppo — cosa è incluso, la manutenzione, come non farti fregare — vale tutto quello che dico nella [guida a comprare software su misura]({{ '/it/pillar/comprare-software/' | relative_url }}).

## Perché serve chi sa fare l'archeologia e il nuovo

Un rewrite ha una competenza doppia che non tutti hanno: bisogna saper **leggere il vecchio** (capire un Access, un VB, un applicativo datato, estrarne le regole e i dati) e saper **costruire il nuovo** (dati, backend, interfaccia moderni). Chi sa solo fare il nuovo rischia di buttare via regole preziose perché non capisce il vecchio; chi sa solo leggere il vecchio rifà una fotocopia moderna dei suoi difetti. Serve chi tiene insieme le due cose: l'archeologia della logica esistente e la costruzione di un prodotto nuovo che quella logica la conserva e la fa girare meglio.

E serve, come sempre, una mano sola sui tre strati — dati, backend, interfaccia — perché in un rewrite sono intrecciati in modo particolare: la migrazione dei dati vecchi, la logica estratta e la nuova interfaccia devono combaciare, e se le fanno fornitori diversi i dati migrati non tornano con la logica, o l'interfaccia non riflette le regole. Un rewrite spezzato tra fornitori che si incolpano è il modo più caro di trasformare una bomba a orologeria in un cantiere infinito.

## Un caso tipo: la bomba disinnescata a strati

Un profilo tipico, architetturale, senza nomi. Un'azienda girava da oltre quindici anni su un gestionale interno fatto su misura da un consulente ormai sparito: clienti, ordini, magazzino, tutta la logica dell'attività dentro un applicativo datato su un paio di PC in rete, con un backup fatto a mano quando qualcuno se ne ricordava. Funzionava — era il problema: funzionava così bene che nessuno osava toccarlo, e intanto la paura cresceva a ogni "e se un giorno si rompe?". Non si poteva collegare all'e-commerce, non si poteva accedere da fuori, e la persona che lo conosceva davvero si avvicinava alla pensione.

Cosa si è fatto, e in che ordine. Prima l'archeologia: capire cosa faceva davvero il vecchio software, regola per regola, eccezione per eccezione — perché lì stava il patrimonio. Poi si è messa in sicurezza la base: i dati portati in un database moderno con backup automatici seri, mentre le funzioni giravano ancora sul vecchio. Solo questo ha tolto di colpo il rischio più grosso. Poi, uno strato alla volta: si è strappata la prima funzione (quella più a rischio), rifatta bene, in produzione accanto al vecchio; quando è stata solida, la successiva. Il vecchio e il nuovo hanno convissuto per mesi, con i dati allineati, finché il vecchio non è servito più.

A regime, la differenza non è stata "abbiamo un software nuovo e bello": è stata che la bomba era disinnescata (dati al sicuro, niente più singolo PC, niente più persona insostituibile), le regole di business erano conservate e finalmente scritte, e si potevano fare le cose prima impossibili (l'accesso da fuori, il collegamento con altri sistemi). Gli operatori hanno accettato il nuovo perché era veloce almeno quanto il vecchio sui gesti di ogni giorno. La nota onesta: è stato un percorso di mesi, non una settimana, e la parte lunga è stata capire il vecchio, non scrivere il nuovo — ma non ha mai fermato l'azienda, perché è avvenuto a strati e non con un salto nel vuoto.

## È per te se / non è per te se

**È per te se:** il tuo gestionale interno è un software legacy fragile (un solo PC, una sola persona che lo capisce, backup sulla chiavetta, gira su tecnologie morte); non puoi farlo crescere e ogni "non si può" ti costa efficienza o fatturato; hai paura, giustificata, che un guasto o una persona che se ne va fermino l'azienda; vuoi conservare le regole di business che ci sono dentro ma liberarti dei vincoli del vecchio.

**Non è per te se:** il software è vecchio ma sano — gira su una base solida, ha backup seri, qualcuno lo mantiene e ti basta così (allora non riscrivere per moda, è buttare soldi); non sei disposto ad affrontare il rewrite a strati e vuoi "rifare tutto in un colpo" (è la strada del suicidio); non hai la pazienza per l'archeologia delle regole e vorresti solo una fotocopia moderna delle vecchie maschere (uno spreco travestito da progetto).

## Domande frequenti

**Il mio gestionale funziona ancora: perché dovrei riscriverlo?**
Non per il fatto che è vecchio, ma se è *fragile*: un solo PC, una sola persona che lo capisce, nessun backup serio, non si può far crescere, gira su tecnologie morte. In quei casi funziona finché non esplode, e il costo quando esplode (azienda ferma, dati persi) è enorme. Se invece è vecchio ma sano e ti basta, lascialo stare.

**Devo rifare tutto o posso partire da un pezzo?**
Quasi sempre conviene partire da un pezzo (piano a strati): mettere in sicurezza i dati, poi rifare una funzione alla volta, con vecchio e nuovo che convivono. Rifare tutto in un colpo solo, con un unico cutover alla fine, accumula tutto il rischio in un punto ed è il modo più comune di far fallire un rewrite.

**Cosa si conserva del vecchio software?**
Le regole di business — anni di logica su come lavora l'azienda, spesso non scritte altrove — vanno capite e conservate. Le maschere e l'interfaccia degli anni 2000 vanno buttate e rifatte su come si lavora oggi. L'errore è "rifacciamo uguale ma moderno": ti porti dietro i difetti e sprechi l'occasione di fare meglio.

**Gli operatori accetteranno il nuovo software?**
Solo se è almeno veloce quanto il vecchio sui gesti che fanno cento volte al giorno. Gli operatori del legacy sono velocissimi anche su maschere brutte, perché le conoscono a memoria. Il nuovo va progettato con loro, mantenendo le scorciatoie e la velocità, o lo vivranno come un peggioramento. La modernità è togliere attrito, non aggiungere clic.

**Quanto costa e quanto ci vuole?**
Dipende da quanta logica c'è da estrarre e da quanto sono accessibili dati e codice del vecchio. È un percorso di mesi, non giorni, ma a strati vedi risultati lungo la strada. La parte più lunga è capire il vecchio (l'archeologia delle regole), non scrivere il nuovo. Valuta il costo contro il rischio crescente di non fare niente, non in assoluto.

**E se non abbiamo il codice sorgente del vecchio?**
Si può comunque, ma è più difficile e più lungo, perché le regole vanno ricostruite osservando il comportamento del software e i dati, invece che leggendo il codice. È un motivo in più per non aspettare che la situazione peggiori (l'autore sempre più irreperibile, la persona che sa se ne va): prima si interviene, più materiale c'è per capire il vecchio.

**Rischiamo di fermare l'azienda durante il rewrite?**
Con il piano a strati, no: vecchio e nuovo convivono, si sostituisce un pezzo alla volta, e se un pezzo va storto è un pezzo, non tutto. Con il rewrite totale e il cutover unico, sì, è proprio il rischio: un giorno in cui tutto deve funzionare al primo colpo. È la ragione principale per preferire gli strati.

**Possiamo comprare un gestionale pronto invece di riscrivere?**
A volte sì, ed è giusto valutarlo: se un gestionale di mercato copre il tuo bisogno, spesso conviene. Il su misura (o il rewrite) ha senso quando le tue regole di business sono particolari e nessun pronto le rispetta — cioè quando proprio quelle regole sedimentate nel legacy sono il tuo modo di lavorare. Il criterio è quanto del tuo funzionamento sta nel 20% che i pronti non fanno.

## In una riga

Se la tua azienda gira su un **gestionale legacy** — un Access del 2008 su un solo PC, con il backup sulla chiavetta e una sola persona che lo capisce — non hai un software vecchio: hai una bomba a orologeria. Riscriverlo ha senso quando compaiono i sintomi di fragilità, e va fatto conservando le **regole di business** (il patrimonio vero) e buttando le maschere grigie. Ma il modo conta più della decisione: il rewrite totale in un colpo solo, con un cutover unico alla fine, è un suicidio; il **piano a strati** — prima i dati in sicurezza, poi un pezzo alla volta, vecchio e nuovo che convivono — è come i rewrite arrivano in fondo invece di morire.

Se hai un legacy fragile e vuoi capire se e come riscriverlo senza fermare l'azienda, guarda i [progetti che ho costruito]({{ site.main_site }}/portfolio/) o [scrivimi due righe]({{ site.main_site }}/contatti/): partiamo dai sintomi reali e dalle regole dentro il tuo vecchio software, non da una riscrittura al buio.
