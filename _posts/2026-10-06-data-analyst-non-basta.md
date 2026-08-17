---
lang: it
permalink: /it/blog/data-analyst-non-basta/
alt_url: /en/
title: "Assumere un data analyst non sistema le fonti: perché i KPI restano una rissa (e serve una pipeline, non una persona sola)"
date: 2026-10-06 07:30:00 +0200
author: "Antonio Trento"
description: "Stai per assumere un data analyst per mettere ordine nei numeri? Ecco perché una persona sola non basta se le fonti sono sporche, e cosa serve davvero prima di aprire una posizione."
keywords: ["data analyst non basta", "pipeline dati aziendale", "fonti dati sporche", "kpi non allineati", "team data pmi"]
pillar: prodotti-dati
related: [/it/blog/report-vendite-in-ritardo/, /it/blog/cruscotto-aziendale-titolare/]
---

## «Cerchiamo un data analyst»: la mossa che sembra ovvia e quasi sempre è prematura

A un certo punto succede in quasi tutte le aziende che crescono. I numeri sono un caos, le riunioni finiscono a litigare su chi ha ragione, il titolare è stanco di non fidarsi dei report. E arriva la decisione che sembra la più logica del mondo: «assumiamo qualcuno che ci metta ordine nei dati». Parte l'annuncio: *cerchiamo un data analyst*. Junior, magari, per contenere i costi. Qualcuno che «sappia usare Power BI e SQL».

Ti dico subito la tesi scomoda di questo articolo: nella maggior parte dei casi, **un data analyst non basta** — e assumerlo *adesso*, prima di aver sistemato le fonti, è uno dei modi più cari per non risolvere il problema. Non perché i data analyst non servano: perché stai chiedendo a una persona di risolvere un problema che è **strutturale**, non di braccia. È come assumere un pilota bravissimo per un'auto che non hai ancora costruito, sperando che la costruisca lui nel tempo libero tra un giro e l'altro.

Questo pezzo è per chi sta per aprire quella posizione, o l'ha appena aperta e si sta chiedendo perché dopo due mesi i numeri sono ancora una rissa. Vediamo cosa succede davvero quando assumi, perché i KPI restano *non allineati*, cosa serve *prima* della persona, e — importante — quando invece assumere ha tutto il senso del mondo.

## Il primo mese: pulizia, non insight

Immagina di aver assunto. Primo giorno, entusiasmo, «finalmente qualcuno che ci fa vedere i numeri». Cosa fa davvero la persona nel primo mese? Non analisi. **Pulizia.**

Perché prima di analizzare qualsiasi cosa deve procurarsi i dati, e i dati sono sparsi in sei posti che non si parlano. Quindi passa i primi giorni a farsi dare gli accessi (che nessuno sa dove sono), poi a capire come è fatto il gestionale (male, come tutti), poi a scoprire che l'e-commerce chiama «ordine» una cosa che il gestionale chiama in un altro modo, poi a riconciliare a mano i clienti scritti in cinque varianti. A fine mese ha prodotto... un foglio pulito. Non un insight: un foglio. Lo stesso foglio che faceva già l'amministrazione, solo che ora lo paghi di più.

Questo non è un difetto della persona: è la conseguenza inevitabile di averla messa a valle di un problema che sta a monte. Le *fonti dati sporche* non si puliscono con l'intelligenza di chi le guarda: si puliscono con regole scritte, ripetibili, che valgono ogni notte in automatico. Se quelle regole non esistono, chiunque assumi le rifà a mano ogni volta — ed è un lavoro di Sisifo, perché il mese dopo le fonti sono di nuovo sporche.

C'è anche un effetto secondario tossico: la persona brava, frustrata dal non arrivare mai alla parte interessante, dopo qualche mese se ne va. E porta con sé tutto il «come ho fatto a far tornare i numeri», che era nella sua testa e in un foglio sul suo computer. Riparti da zero. Ho scritto un pezzo intero su questo meccanismo — [perché il report arriva sempre in ritardo e non è colpa della persona che lo fa]({{ '/it/blog/report-vendite-in-ritardo/' | relative_url }}) — perché è lo stesso identico errore visto da un'altra angolazione.

## Un caso tipo: l'analyst assunto per i numeri, rimasto sulla pulizia

Un profilo tipico, architetturale, senza nomi. Azienda di distribuzione, in crescita, numeri sempre più caotici. Decidono di assumere: un data analyst junior, bravo, motivato. Cosa succede, mese per mese.

**Mese 1–2:** accessi da recuperare, gestionale da capire, e-commerce che chiama le cose in modo diverso, clienti scritti in cinque varianti da unire a mano. Produce un foglio pulito. Il titolare comincia a chiedersi «ma gli insight?».

**Mese 3:** prima dashboard. Alla riunione, il commerciale contesta il numero delle vendite («per me è di più»), l'amministrazione ne contesta un altro. La persona non ha l'autorità per chiudere la discussione, e ogni reparto smette di fidarsi del «suo» numero mostrato dalla dashboard.

**Mese 5:** frustrata di passare le giornate a riconciliare invece che ad analizzare, e stanca di fare da arbitro in liti che non le competono, la persona accetta un'altra offerta. Se ne va con tutto il «come ho fatto a far tornare i numeri»: era nella sua testa e in un foglio sul suo computer. L'azienda riparte da zero, con in più la sfiducia («abbiamo provato con una persona, non è servito»).

Poi lo hanno rifatto nell'ordine giusto. Prima un tavolo con direzione, commerciale e amministrazione per decidere le definizioni. Poi una pipeline che pulisce le fonti e applica quelle definizioni ogni notte, in automatico. Poi un cruscotto con gli allarmi. **A quel punto** hanno ripreso una persona — questa volta con testa di business, non un tuttofare — che ha trovato un sistema pronto e ha potuto fare davvero l'analista. È rimasta. La differenza non è stata «trovare quello bravo»: è stato costruire prima il terreno su cui potesse lavorare.

## La rissa sui KPI: due «vendite» che non torneranno mai

Ecco il cuore del problema, e il motivo per cui i *kpi non allineati* non si risolvono assumendo. Facciamo un esempio concreto, di quelli che vedo in ogni azienda.

Lunedì, riunione. Il direttore commerciale dice: «a settembre abbiamo fatto 520.000». La responsabile amministrativa lo guarda e dice: «no, 470.000». Silenzio imbarazzato. Chi ha ragione? **Tutti e due.** Perché stanno misurando due cose diverse con la stessa parola:

- Il commerciale conta gli **ordini firmati** nel mese, IVA inclusa, comprese le cose che devono ancora essere consegnate e fatturate.
- L'amministrazione conta le **fatture emesse** nel mese, IVA esclusa, con i resi già scalati.

Sono due numeri legittimi, due «vendite» diverse. Finché nessuno decide *quale* è LA vendita per l'azienda, ogni riunione riparte da questa rissa, e nessun data analyst la può risolvere — perché non è un problema di calcolo, è un problema di **accordo**. La persona può fare entrambi i numeri benissimo; non ha l'autorità per decidere quale conta. E se prova a deciderlo lei, il reparto che «perde» il proprio numero non si fida più della dashboard. Fine del progetto.

Questo è il punto che sfugge a chi pensa che i dati siano un problema tecnico. I dati aziendali sono un problema **politico e organizzativo** prima che tecnico. La rissa sui KPI è una rissa sulle definizioni, e le definizioni le decide l'azienda, non l'analista. Serve qualcuno che porti tutti al tavolo e faccia mettere per iscritto la risposta — e poi un sistema che la applichi sempre, uguale, senza che nessuno possa «aggiustarla» a mano.

## Non solo le vendite: le altre parole che litigano

La «vendita» è solo la rissa più visibile. Appena gratti sotto, ne trovi altre, e ognuna manda in stallo una riunione diversa:

- **Cliente attivo.** Dopo quanti giorni senza ordini uno smette di essere «attivo»? 60, 90, 180? La soglia cambia di colpo quanti clienti «stai perdendo» — e quindi se il problema è grave o normale. Senza una soglia decisa, ognuno usa la sua.
- **Margine.** Sul listino o sul netto scontato? Con o senza spedizioni, provvigioni, costi di reso? Due persone possono dichiarare due «marginalità» diverse sullo stesso ordine, entrambe in buona fede.
- **Nuovo cliente.** Conta dal primo ordine o dal primo pagamento? E se torna dopo due anni di silenzio, è «nuovo» o «riattivato»? La risposta cambia i numeri del marketing.
- **Tasso di conversione.** Numeratore e denominatore di *cosa*? Preventivi su contatti, ordini su preventivi, ordini su visite? Tre numeri diversi, tutti chiamati «conversione».

Nessuna di queste ha una risposta giusta universale: ha una risposta *tua*, che va decisa e scritta una volta per tutte. Un data analyst può calcolarle tutte perfettamente, ma non può *decidere* quale conta: quella è una scelta di business. Ed è per questo che assumere prima di aver deciso le definizioni sposta il problema, non lo risolve — la persona eredita le risse, non le chiude.

## Perché una persona sola non può bastare

Riassumiamo il perché strutturale, così è chiaro che non è una questione di trovare «quello bravo».

Un data analyst da solo si scontra con tre muri che nessuna competenza individuale abbatte:

1. **Le fonti sporche** vanno pulite con regole automatiche e ripetibili, non a mano ogni mese. Questo è lavoro di ingegneria dei dati (una *pipeline*), non di analisi.
2. **Le definizioni** vanno decise dall'azienda, non dall'analista. Serve autorità e un tavolo, non SQL.
3. **La continuità**: se il sapere vive nella persona, quando la persona va via il problema torna. Serve che viva in un sistema documentato.

Una persona sola può, nella migliore delle ipotesi, tamponare tutti e tre i muri con eroismo e straordinari. Ma è un equilibrio fragile che regge finché lei regge. Il giorno che si ammala, va in ferie o cambia lavoro, scopri che avevi comprato una dipendenza, non una soluzione. È lo stesso motivo per cui [decidere a naso quando i numeri sono in sei software]({{ '/it/blog/cruscotto-aziendale-titolare/' | relative_url }}) non si risolve con una dashboard bella: senza il sistema sotto, è tutto scenografia.

C'è anche un aspetto umano che conta, oltre a quello tecnico: mettere una persona sola contro questi tre muri è ingiusto, non solo inefficace. La stai preparando al fallimento. Anche il miglior data analyst del mondo, senza una pipeline sotto e senza definizioni decise sopra, può solo scegliere quale muro sbattere per primo. E quando una persona brava capisce di essere stata messa in una posizione impossibile, la reazione più sana che può avere è andarsene. Non stai perdendo perché hai scelto male la persona: stai perdendo perché hai chiesto a una persona di essere, da sola, un intero sistema.

## Quanto costa davvero un'assunzione fatta troppo presto

Lo stipendio è solo la punta. Il costo vero di assumere prima di avere il sistema è fatto di voci che nessuno mette nel conto, ma che pesano.

| Voce | Cosa pesa davvero |
|---|---|
| RAL + contributi + postazione | ~30.000–40.000 € il primo anno per un junior |
| Onboarding degli altri | settimane di tempo di amministrazione e IT per dare accessi e spiegare le fonti |
| Costo-opportunità | per mesi continui a *non* avere numeri fidati: le decisioni restano al buio |
| Turnover | se la persona se ne va frustrata, ricominci da zero e perdi il suo sapere non scritto |
| Sfiducia interna | «abbiamo provato, non è servito»: la prossima proposta la guardano con sospetto |

Somma queste voci e confrontale con il costo di costruire prima il sistema (pipeline + definizioni + cruscotto), che è una spesa una tantum più manutenzione e comincia a dare valore in settimane. Nella maggior parte delle PMI il conto è netto: il sistema prima, la persona dopo. Non perché le persone costino troppo, ma perché una persona messa a valle di un problema strutturale non lo può risolvere, e nel frattempo la paghi. È lo stesso ragionamento «velocità contro headcount» che ho fatto parlando dei [report che arrivano sempre in ritardo]({{ '/it/blog/report-vendite-in-ritardo/' | relative_url }}): assumere sembra la mossa prudente, ed è spesso la più cara.

## Chi deve stare al tavolo (e non è l'IT da solo)

Se la rissa sui KPI è organizzativa, la sua soluzione è organizzativa. Prima ancora di scrivere una riga di codice o assumere qualcuno, serve un tavolo con le persone giuste. Ecco chi, e perché.

| Ruolo | Perché è al tavolo | Cosa porta |
|---|---|---|
| **Titolare / direzione** | ha l'autorità di chiudere le discussioni sulle definizioni | decide quale numero è «il» numero |
| **Commerciale** | conosce come nascono ordini, sconti, promesse | le eccezioni vere del mondo vendite |
| **Amministrazione** | conosce fatture, resi, IVA, incassi | la verità fiscale e di cassa |
| **Chi conosce i dati/IT** | sa dove vivono i dati e in che stato sono | fattibilità e fonti |
| **Chi costruisce (interno o esterno)** | traduce le decisioni in regole automatiche | la pipeline e il prodotto |

Nota chi *non* può reggere il tavolo da solo: l'IT. L'errore classico è «diamo i dati all'IT che ci fa le dashboard». L'IT sa dove sono i dati, ma non ha l'autorità per decidere cos'è una vendita, e non dovrebbe averla. Se le definizioni le sceglie l'IT (o un analista) senza il commerciale e l'amministrazione al tavolo, ottieni numeri tecnicamente corretti di cui nessuno in azienda si fida. E una dashboard di cui nessuno si fida è peggio di nessuna dashboard, perché aggiunge discussioni invece di chiuderle.

## I tre annunci di lavoro che rivelano il problema

Il modo più veloce per capire se stai per sbagliare è leggere l'annuncio che hai scritto. Ce ne sono tre versioni tipiche, e tutte e tre rivelano che manca il sistema, non la persona.

- **«Cerchiamo un tuttofare dei dati.»** Traduzione: non abbiamo una pipeline, quindi ci serve qualcuno che pulisca a mano, faccia i grafici, parli con i reparti e magari sistemi anche il gestionale. È una descrizione di tre lavori diversi buttati su una persona sola, di solito junior. Non li farà bene tutti e tre, e si brucerà provandoci.
- **«Deve conoscere Power BI e SQL.»** Traduzione: stiamo pensando allo strumento, non al problema. La competenza tecnica è utile, ma è l'ultima cosa che manca. Prima mancano le definizioni e le fonti pulite; senza quelle, Power BI mostra numeri sbagliati con grafici bellissimi.
- **«Metterà ordine nei nostri numeri.»** Traduzione: stiamo delegando a una persona una decisione organizzativa (cos'è una vendita) che spetta alla direzione. Nessun analista può «mettere ordine» in una rissa di cui non ha l'autorità di essere arbitro.

Come sarebbe un annuncio sano? Uno che parte *dopo* il sistema: «Cerchiamo qualcuno che, su una base dati già consolidata e con definizioni condivise, sappia leggere i numeri, individuare anomalie e portare domande al business.» Quello è un lavoro fattibile, attraente, e trovi la persona giusta. L'altro è una trappola con lo stipendio dentro.

## Cosa fa una persona vs cosa fa un sistema

Chiariamo la divisione del lavoro, perché è qui che si capisce cosa comprare e in che ordine.

| | Lo fa (bene) una persona | Lo fa (bene) un sistema |
|---|---|---|
| Pulire le fonti ogni notte | no: è ripetitivo e va automatizzato | sì: regole scritte una volta, applicate sempre |
| Applicare le definizioni concordate | rischioso: può «aggiustare» a mano | sì: sempre uguale, verificabile |
| Accorgersi di un'anomalia alle 3 di notte | no: dorme | sì: allarme automatico |
| Capire *perché* una linea cala | sì: serve testa e contesto | no: mostra il fatto, non il perché |
| Portare una domanda nuova al business | sì: è il valore vero | no |
| Raccontare i numeri a chi decide | sì | no |

Guarda le due colonne: il sistema fa il lavoro *noioso e ripetibile* (pulizia, regole, allarmi), la persona fa il lavoro *di testa* (interpretazione, domande, racconto). Se assumi una persona senza il sistema, la costringi a fare la colonna di destra a mano — cioè le fai fare il lavoro del sistema, sprecando esattamente ciò per cui l'hai presa. Prima il sistema, poi la persona che ci ragiona sopra. Mai il contrario.

## La pipeline: contratti sui numeri, non grafici

La parola che manca in quasi tutte le discussioni su «assumiamo per i dati» è **pipeline**. Una *pipeline dati aziendale* non è un grafico e non è una persona: è il pezzo di ingegneria che, ogni notte, prende i dati dalle fonti, applica le regole di pulizia e le definizioni concordate, costruisce lo storico e mette gli allarmi. È il «sotto» invisibile su cui poggia qualsiasi dashboard.

Il modo giusto di pensarla è come una serie di **contratti sui numeri**. Un contratto dice: «la vendita si calcola così, da questa fonte, con questa regola sui resi; se la fonte non risponde, il numero è marcato incompleto invece di essere falsato». Sono contratti perché una volta firmati non si cambiano di nascosto: sono scritti nel codice, verificabili, e se cambiano lo sanno tutti. Questo è ciò che rende i numeri *fidati* — non la bellezza del grafico sopra, ma la solidità del contratto sotto.

Una dashboard senza pipeline è un vestito senza corpo: sta in piedi finché la persona lo tiene su a mano. Una pipeline senza dashboard è utile ma muta. Servono entrambe, e devono essere pensate insieme, dalla stessa testa, perché la definizione di un numero e il modo di mostrarlo sono la stessa decisione. È il motivo per cui affido raramente «i dati» a un fornitore e «l'interfaccia» a un altro: si incolpano a vicenda e tu paghi due volte.

Un esempio di cosa cambia, in concreto. **Prima** della pipeline: ogni lunedì qualcuno scarica tre file, li incolla, toglie i resi a memoria, corregge i nomi doppi, e verso mercoledì il numero è pronto (forse giusto). **Dopo** la pipeline: alle 6 del mattino i tre file sono già stati presi, puliti con le regole scritte, i resi scalati secondo la definizione firmata, i doppioni uniti con una logica ripetibile; alle 8 il numero è sullo schermo, uguale per tutti, e se un file non è arrivato c'è scritto «dati incompleti» invece di un totale falso. La differenza non è solo la velocità: è che il numero non dipende più dalla memoria e dall'umore di chi lo compila. È diventato un fatto, non un'opinione settimanale.

## Il segnale che hai già assunto troppo presto

Magari la persona l'hai già presa, e stai leggendo questo articolo con un certo disagio. Ecco i segnali, a 60–90 giorni, che l'hai messa a valle di un problema che sta a monte:

- Passa ancora la maggior parte del tempo a **pulire e riconciliare**, non ad analizzare.
- Alle riunioni **si litiga ancora** su quale numero è giusto: le definizioni non sono state decise, sono state delegate a lei.
- Esistono delle dashboard, ma **non le apre nessuno**, perché nessuno si fida dei numeri.
- La persona comincia a essere **frustrata** («non è questo il lavoro per cui pensavo di essere stata presa»).

Se ti riconosci, la buona notizia è che non hai sbagliato ad assumere: hai sbagliato l'ordine. La mossa non è licenziare, è **costruire ora il sistema che manca** — il tavolo delle definizioni, la pipeline, gli allarmi — e spostare la persona sul ruolo giusto man mano che il sistema le toglie il lavoro sporco. Chi era assunto come «compilatore per forza» spesso diventa un ottimo interprete, appena smette di annegare.

## Quando assumere DOPO (e prendere la persona giusta)

Non sto dicendo «non assumere mai». Sto dicendo di assumere **nell'ordine giusto**, e la differenza è enorme.

Prima costruisci il sistema: il tavolo delle definizioni, la pipeline che pulisce e applica le regole, il cruscotto che si aggiorna da solo con gli allarmi. A quel punto — e solo a quel punto — assumere una persona ha senso, per tre motivi:

- Non annega più nella pulizia: quella la fa il sistema. Può dedicarsi alla parte che vale.
- Presidia il cruscotto: si accorge quando un numero è strano, capisce perché una linea cala, porta domande nuove.
- Fa l'analista vero, non il compilatore. Ed è finalmente un lavoro che una persona brava vuole fare (e per cui resta).

Cambia anche *chi* assumi. Prima del sistema cerchi disperatamente un tuttofare che «sappia fare tutto» (leggi: che pulisca a mano e non si lamenti). Dopo il sistema cerchi qualcuno con testa di business, che sappia leggere i numeri e parlare con i reparti — un profilo diverso, più utile, e che trovi più facilmente perché gli offri un lavoro sensato invece di un incubo di riconciliazioni. Se vuoi capire meglio questa distinzione tra chi *pulisce report* e chi *costruisce prodotto*, la approfondisco anche parlando di [dashboard che nessuno usa perché mancano le domande giuste]({{ '/it/pillar/prodotti-dati/' | relative_url }}).

## Il mito del «ce lo facciamo in casa con Power BI»

La versione fai-da-te di «assumiamo un analyst» è «compriamo Power BI e ce lo facciamo in casa». È la stessa illusione con un altro vestito. Power BI — o Looker, o Metabase, o qualsiasi tool — è ottimo, ma è lo strato di sopra: si collega ai dati e li mostra. Se i dati sotto sono sporchi e le definizioni non esistono, il tool ti permette solo di produrre grafici sbagliati più in fretta, e con un'aria più professionale. Il che è persino peggio: un grafico brutto lo metti in dubbio, uno bello e patinato ci credi.

Quasi tutto il lavoro vero di un cruscotto sta *prima* del tool: mettere d'accordo le definizioni, collegare le fonti, pulirle, tenerle aggiornate, mettere gli allarmi sulle rotture. Il tool è l'ultimo 20%, quello che si vede. Comprare il tool e dare a qualcuno il compito di «farci le dashboard» significa scaricargli addosso l'80% invisibile — pulizia e definizioni — che nessun tool fa al posto suo. Ed eccoci di nuovo alla persona sola contro i tre muri, solo con una licenza software in più da pagare.

Attenzione: non sto dicendo che Power BI sia il problema. È un ottimo strato di presentazione. Il problema è pensare che *comprare il tool sia comprare la soluzione*. Il tool senza il sistema sotto è una macchina fotografica costosa in mano a chi non ha ancora deciso cosa fotografare.

## I deliverable che un titolare firma

Se questo tavolo lo apri sul serio, cosa dovresti avere in mano alla fine — cioè cosa stai comprando, che sia fatto da un interno o da un fornitore? Ecco i deliverable concreti che un titolare può leggere e firmare, senza essere tecnico:

1. **Il documento delle definizioni.** Poche pagine: cos'è una vendita, un cliente attivo, un margine, un reso, con la data e la firma di chi ha deciso. È il documento più importante di tutti.
2. **La mappa delle fonti.** Quali sono, in che stato, chi ha gli accessi, cosa succede quando una cambia.
3. **La pipeline documentata.** Non il codice riga per riga, ma cosa fa, ogni quanto, e come ti accorgi se si rompe.
4. **Il cruscotto.** Poche metriche che rispettano le definizioni, con gli allarmi, che funziona anche dal telefono.
5. **Il piano di manutenzione.** Chi mette le mani quando una fonte cambia, con quali tempi, a quale costo.

Se stai valutando di assumere e nessuno ti parla di questi cinque deliverable ma solo di «competenze in Power BI e SQL», stai comprando uno strumento con le gambe, non una soluzione. La competenza tecnica serve, ma è l'ultima cosa che manca: quello che manca prima sono le definizioni, il tavolo e la pipeline.

## Come si parte, senza assumere subito

Se ti sei convinto che l'ordine giusto è «prima il sistema», ecco i primi passi concreti, nessuno dei quali richiede di aprire una posizione.

1. **Convoca il tavolo.** Direzione, commerciale, amministrazione, chi conosce i dati. Un paio d'ore, un obiettivo: decidere le prime cinque definizioni che contano (vendita, cliente attivo, margine, reso, il KPI che guardate di più).
2. **Scrivi le definizioni.** Poche righe, con la data e chi ha deciso. Da quel momento sono legge: chi non è d'accordo discute la definizione, non il grafico.
3. **Mappa le fonti.** Quali sono, in che stato, chi ha gli accessi, quanto sono sporche. Serve a capire dove sarà facile e dove si sudano le camicie.
4. **Fai costruire la pipeline su una fonte.** Parti da quella che pesa di più (di solito il gestionale) e porta a casa un cruscotto vero in poche settimane, con gli allarmi. Poi allarga.
5. **Solo adesso valuta la persona.** Con il sistema in piedi, capisci che *tipo* di persona ti serve davvero — quasi sempre una con testa di business, non un tuttofare tecnico — e le offri un lavoro sensato per cui resterà.

I primi tre passi puoi farli anche da solo, questa settimana. Sono gratis, e valgono più di qualsiasi annuncio di lavoro.

## Un ultimo malinteso: «i nostri dati sono troppo particolari»

C'è un'obiezione che salta fuori quando proponi di sistemare le fonti prima di assumere: «ma i nostri dati sono troppo particolari, solo una persona che vive qui dentro può capirli». È vera a metà, ed è una trappola. È vero che ogni azienda ha le sue eccezioni: quel cliente che paga a modo suo, quella linea che si sconta diversamente, quel gestionale piegato negli anni fino a fare cose che il manuale non prevede.

Ma la conseguenza giusta non è «serve una persona che le tenga a mente»: è «quelle eccezioni vanno *scritte*, non ricordate». Una regola scritta nella pipeline vale ogni notte, anche quando la persona che la conosceva è in ferie o se n'è andata. Una regola «nella testa di Maria» vale finché c'è Maria. Più i tuoi dati sono particolari, più hai bisogno di un sistema che ne fissi le particolarità in regole verificabili — non di una persona che le tenga in equilibrio a mano ogni mese. La particolarità dei tuoi dati è un argomento *a favore* del sistema, non contro: è esattamente la ragione per cui non puoi permetterti che viva solo in una testa.

## È per te se / non è per te se

**È per te se:** stai per aprire una posizione «data analyst» per mettere ordine nei numeri; le riunioni finiscono a litigare su quale numero è giusto; hai già provato con una persona e dopo mesi produce fogli, non insight; hai fonti multiple che non si parlano e definizioni che vivono nelle teste.

**Non è per te se:** hai una sola fonte pulita e i numeri sono già chiari e condivisi; sei una realtà abbastanza grande da avere *già* pipeline e definizioni solide, e ti serve davvero solo più capacità di analisi (allora sì, assumi pure); cerchi qualcuno che «faccia i grafici» per una presentazione una tantum, non per guidare l'azienda.

## E se aspetto e intanto continuo così?

La tentazione, davanti a «prima il sistema, poi la persona», è rimandare: «per ora andiamo avanti come sempre, ci penseremo più avanti». È legittimo, ma vale la pena essere onesti sul costo del così-come-sempre. Ogni mese senza definizioni condivise è un mese di riunioni che ripartono dalla stessa rissa sui numeri. Ogni mese senza pipeline è un mese in cui una persona brava spreca giornate a incollare file invece di ragionare. Ogni decisione presa sul numero sbagliato — un riordino, uno sconto, un cliente non richiamato in tempo — è un costo che non vedi ma paghi.

Aspettare non è gratis: è solo un costo che non compare in fattura. E la buona notizia è che l'alternativa non è «un grande progetto o niente». I primi passi — convocare il tavolo, scrivere cinque definizioni, mappare le fonti — non richiedono budget né assunzioni: richiedono un paio d'ore e la volontà di chiudere qualche discussione una volta per tutte. Puoi cominciare da lì, dal pezzo che costa zero e vale di più, e decidere il resto quando hai le idee più chiare. Quello che conviene evitare è l'unica mossa davvero cara: aprire una posizione per risolvere un problema che, così com'è, nessuna persona da sola può risolvere.

## Domande frequenti

**Quindi non devo mai assumere un data analyst?**
Al contrario: assumilo, ma dopo aver costruito il sistema. Prima del sistema, una persona sola annega nella pulizia e produce fogli. Dopo, fa finalmente l'analista e resta perché il lavoro ha senso. È una questione di ordine, non di sì/no.

**Un consulente esterno a giornata risolve?**
Stesso problema del junior interno: se il suo lavoro è pulire a mano ogni mese, hai comprato un tampone ricorrente, non una soluzione. Un esterno serve per *costruire il sistema* (la pipeline, le definizioni), non per rifare a mano il report ogni volta.

**Chi decide qual è la definizione giusta di «vendita»?**
L'azienda, al tavolo, con l'autorità della direzione. Non l'analista, non l'IT. Il loro compito è rendere fattibile e poi automatica la decisione, non prenderla.

**Abbiamo già Power BI e una persona che lo usa: perché non basta?**
Perché Power BI è lo strato di sopra. Se sotto non c'è una pipeline che pulisce le fonti e applica definizioni concordate, la persona le rifà a mano ogni volta, e i numeri restano fragili e contestati. Lo strumento non è il problema; è la mancanza del sistema sotto.

**Quanto ci vuole a costruire il sistema prima di assumere?**
Per una PMI con le fonti tipiche, un sistema utile in poche settimane e rodato in qualche mese. La fase più preziosa è il tavolo delle definizioni all'inizio: è lì che si decide se i numeri saranno fidati o contestati.

**E se non ho nessuno in azienda che capisce i dati?**
Va benissimo: il sistema si costruisce con un fornitore, e il presidio quotidiano può essere leggero (un'ora al giorno di qualcuno che guarda gli allarmi). L'importante è non partire assumendo un junior sperando che «capisca lui come fare»: quello è il percorso che finisce con un foglio pulito e una persona frustrata.

**Meglio un data engineer o un data analyst?**
Sono due mestieri diversi. Il data engineer costruisce la pipeline (il «sotto»); il data analyst legge e interpreta i numeri (il «sopra»). Nell'ordine giusto, prima ti serve chi costruisce il sistema (spesso un fornitore o un engineer), poi eventualmente chi lo interpreta ogni giorno. Assumere un analyst chiedendogli di fare l'engineer è la ricetta del fallimento che descrivo qui.

**Quanto è grande il team che serve davvero?**
Meno di quanto pensi. In una PMI, spesso non serve un «team data»: serve un sistema costruito bene (una volta) e una persona che lo presidia part-time, più un accordo di manutenzione. Il team grande serve quando i volumi e le domande crescono davvero — e a quel punto lo costruisci su una base solida, non sul caos.

**L'AI non può fare l'analista al posto nostro?**
Può aiutare ai bordi (riassumere, raggruppare note, scrivere un commento leggibile sopra numeri già calcolati), ma non risolve il problema di fondo: le definizioni e le fonti sporche. Se dai a un modello dati contesi e sporchi, ti dà risposte plausibili e sbagliate, con più sicurezza di prima. Prima il sistema, poi — se serve — l'AI sopra.

## In una riga

Se stai per assumere un data analyst per mettere ordine nei numeri, fermati un attimo: **il problema quasi mai è la mancanza di una persona, è la mancanza di un sistema**. Prima il tavolo delle definizioni, poi la pipeline che pulisce le fonti e applica le regole, poi il cruscotto con gli allarmi. Fatto questo, la persona giusta diventa preziosa — e resta, perché finalmente fa l'analista invece del compilatore.

Se vuoi capire da dove partire sui *tuoi* numeri e le tue fonti, guarda i [progetti che ho costruito](https://antoniotrento.net/portfolio/) o [scrivimi due righe](https://antoniotrento.net/contatti/): si parte dalle definizioni e dalle fonti che hai, non da un annuncio di lavoro.
