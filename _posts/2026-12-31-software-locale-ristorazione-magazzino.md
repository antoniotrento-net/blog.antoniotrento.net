---
lang: it
permalink: /it/blog/software-locale-ristorazione-magazzino/
alt_url: /en/blog/local-software-restaurant-inventory/
title: "Comande, magazzino e fatture: il locale che perde margine tra sala e amministrazione"
date: 2026-12-31 07:30:00 +0200
author: "Antonio Trento"
description: "Nel tuo locale lo scontrino c'è ma il food cost no: tra sala, cucina, magazzino e commercialista il margine si perde. Ecco il filo ricetta-scarico-fattura che ti dice quale piatto perde — senza rifare la cassa."
keywords: ["software locale ristorazione magazzino", "costo del venduto ristorante", "giacenze cucina", "integrazione cassa fatture", "food cost"]
image: /assets/images/posts/software-locale-ristorazione-magazzino.jpg
pillar: app-interne
related: [/it/blog/giacenze-magazzino-disallineate/, /it/blog/cruscotto-aziendale-titolare/]
---

## Lo scontrino c'è, il food cost no

In un ristorante, in una pizzeria, in un bar, una cosa la sai con precisione: quanto hai incassato. La cassa te lo dice al centesimo, a fine serata. Ma prova a fare l'altra domanda, quella che decide se guadagni o lavori per il fornitore: **quanto ti è costato quello che hai venduto?** Qual è il tuo food cost? Quale piatto ti fa margine e quale te lo mangia? Qui, nella stragrande maggioranza dei locali, cala il silenzio. Lo scontrino c'è; il food cost no.

Il margine, in un locale, non si perde in sala: si perde nel buco tra la sala che incassa, la cucina che consuma, il magazzino che si svuota e l'amministrazione che paga le fatture dei fornitori. Quattro mondi che non si parlano. Così puoi avere il locale pieno tutte le sere e chiudere l'anno con poco in tasca, senza capire dove è finito — perché tra un incasso che conosci e un costo che non conosci, il margine è una sorpresa, non una scelta.

Questo articolo è per chi ha un locale — ristorazione, bar, pizzeria, piccola catena — e sa quanto incassa ma non quanto guadagna davvero, piatto per piatto. Vediamo il filo che manca (**ricetta → scarico → fattura fornitore**), perché il gestionale che «ce l'abbiamo» non ti dà comunque i numeri, che aspetto ha uno strumento che un cuoco o un cameriere usa davvero, e — importante — perché **non devi rifare la cassa** se funziona: devi collegarla al resto.

## Quattro mondi che non si parlano

Il problema è strutturale, ed è fatto di quattro mondi separati che raccontano ognuno un pezzo della storia, senza che nessuno la veda intera.

- **La sala** (la cassa) sa cosa hai venduto: dieci carbonare, quindici pizze margherita, venti caffè. Il ricavo, per piatto, ce l'hai.
- **La cucina** sa cosa ha consumato: la carbonara ha portato via guanciale, uova, pecorino, pasta. Ma questo consumo non è scritto da nessuna parte in modo collegato alla vendita.
- **Il magazzino** sa (a fatica) cosa c'è e cosa manca: quanto guanciale è rimasto, cosa va riordinato. Spesso a occhio, con l'inventario che «lo facciamo quando possiamo».
- **L'amministrazione** (o il commercialista) sa quanto hai pagato i fornitori: le fatture del macellaio, del grossista, del fruttivendolo. Il costo, in totale, ce l'ha — a mesi di distanza.

Ognuno di questi quattro sa una cosa vera. Ma il **food cost** — il costo di ciò che vendi, per capire il margine per piatto — vive solo nell'incrocio di tutti e quattro, e quell'incrocio non lo fa nessuno. È lo stesso schema delle [informazioni prigioniere in sistemi che non si parlano]({{ '/it/blog/giacenze-magazzino-disallineate/' | relative_url }}): i dati ci sono tutti, ma sparsi, e la verità che ti serve sta nella differenza tra loro — che nessuno calcola.

## Il filo che manca: ricetta → scarico → fattura

Il pezzo che trasforma quattro mondi separati in un numero utile è un filo, ed è più semplice di quanto sembri: collegare la **ricetta** allo **scarico di magazzino** e alla **fattura del fornitore**.

Funziona così. Ogni piatto ha una ricetta: la carbonara è tot grammi di guanciale, tot uova, tot pasta, tot pecorino. Quando la sala vende una carbonara, il sistema **scarica dal magazzino** gli ingredienti di quella ricetta — automaticamente, senza che nessuno pesi niente. Così il magazzino si aggiorna da solo mentre vendi, e sai cosa consumi davvero. E gli ingredienti hanno un costo, che viene dalle **fatture dei fornitori**: se il guanciale è costato X al chilo, e la carbonara ne usa tot grammi, sai quanto ti costa una carbonara. Ricavo (dalla cassa) meno costo (da ricetta × prezzi fattura) = **margine per piatto**.

Questo filo è tutto. Una volta che c'è, il food cost non è più un mistero annuale: è un numero che vedi per ogni piatto, ogni settimana. Sai che la carbonara rende e che quel piatto elaborato del menù, che sembra premium, in realtà ti fa margine zero perché gli ingredienti costano troppo per il prezzo a cui lo vendi. E puoi decidere: alzare il prezzo, cambiare la ricetta, togliere il piatto, o tenerlo come richiamo sapendo che non guadagni. Decidere, invece di scoprire a fine anno che non torna.

## Perché il gestionale «ce l'abbiamo» non basta

«Ma noi il gestionale ce l'abbiamo.» Sì, e probabilmente non ti dà comunque il food cost. Il motivo è che avere i pezzi non vuol dire che siano collegati. Molti locali hanno una cassa (che registra le vendite), magari un gestionale di magazzino (che qualcuno aggiorna a mano), e il commercialista che tiene le fatture. Tre cose che esistono, ma che non parlano tra loro — e il food cost vive proprio nel collegamento, che non c'è.

È lo stesso equivoco del [«Power BI ce l'abbiamo» che non dà i numeri]({{ '/it/blog/cruscotto-aziendale-titolare/' | relative_url }}): avere lo strumento non è avere il risultato. Se la ricetta non è collegata allo scarico, il magazzino non si aggiorna con le vendite; se le fatture non alimentano i costi degli ingredienti, i prezzi che il sistema usa sono vecchi o inventati. Il gestionale «c'è», ma il numero che ti serve — quanto guadagno su ogni piatto — non lo produce, perché nessuno ha costruito il filo tra i pezzi. Il lavoro vero non è comprare un altro software: è collegare ciò che hai in modo che il food cost esca da solo.

## Uno strumento che un cuoco (o un cameriere) usa davvero

Qui c'è il solito scoglio delle app interne: se lo strumento è scomodo per chi ci lavora, non viene usato, e i dati sono spazzatura. E in un locale, chi ci lavora è un cuoco con le mani in pasta e un cameriere che corre tra i tavoli — non gente che compila maschere.

Quindi le parti che toccano il personale devono essere **invisibili o semplicissime**. Lo scarico dal magazzino deve avvenire **da solo** quando la sala batte la comanda: il cuoco non deve registrare niente, cucina e basta. La ricetta si imposta una volta (con lo chef, che sa i grammi veri), non a ogni piatto. L'inventario fisico, quando serve per correggere gli scostamenti, deve essere veloce — contare e confermare da un telefono, non compilare un foglione. E i pochi gesti manuali che restano (registrare un carico dal fornitore, segnare uno scarto o un pasto del personale) devono essere pochi tap.

La regola è quella di sempre per le [app interne: se è più lenta e scomoda del metodo attuale, il personale la aggira]({{ '/it/blog/app-interna-aziendale-copia-incolla/' | relative_url }}). In un locale il metodo attuale è «non registrare niente e sperare»: la tua app deve chiedere meno di così, spostando il lavoro sull'automazione (lo scarico dalla comanda) invece che sulle persone. Se chiedi al cuoco di pesare e registrare ogni ingrediente, hai già perso.

## I dati per il titolare: qual è il piatto che perde

Tutto questo filo serve a una schermata sola, quella che il titolare guarda: **il margine per piatto**, e la salute del food cost complessivo. È qui che si prendono le decisioni che spostano i soldi.

Cosa deve vedere il titolare, in modo semplice:

- **Il food cost complessivo** (costo del venduto in percentuale sul ricavo): il numero che ti dice se il locale è sano. Se sale, qualcosa sta erodendo il margine — i prezzi dei fornitori, gli sprechi, i cali.
- **Il margine per piatto**: quali piatti rendono, quali no. Spesso ci sono sorprese — il piatto «povero» che rende benissimo, il piatto «di prestigio» che perde.
- **Gli scostamenti**: dove il consumo teorico (da ricetta) non torna con il consumo reale (da inventario). Un guanciale che sparisce più di quanto le carbonare vendute giustifichino è uno spreco, un errore di porzionatura, o peggio.
- **L'impatto dei prezzi fornitore**: quando il costo di un ingrediente sale, quali piatti ne soffrono, e di quanto va corretto il menù.

Questa è la vera dashboard di un locale, ed è lo stesso salto dal decidere a sensazione al [decidere sui numeri]({{ '/it/blog/cruscotto-aziendale-titolare/' | relative_url }}) di cui parlo per i cruscotti — applicato al piatto. Con questi numeri, il menù smette di essere una lista di piatti che ti piacciono e diventa uno strumento di margine: sai cosa spingere, cosa ritoccare, cosa togliere.

## Quanto costa non sapere il food cost

Vale la pena mettere a fuoco cosa costa navigare a vista, perché in un locale i margini sono sottili e un paio di punti percentuali fanno la differenza tra guadagnare e tirare avanti. Se il tuo food cost reale è al 35% quando pensavi fosse al 30%, su un locale che fattura, poniamo, 600.000 € l'anno, sono **30.000 € di margine** che credevi di avere e non hai — spariti nel non-sapere. E non è un numero fisso: è un'emorragia che continua finché non la vedi, perché i prezzi dei fornitori salgono e i tuoi menù restano fermi, e ogni settimana il buco si allarga un po'.

Poi ci sono i costi puntuali: il piatto che vendi in perdita a ogni ordine (più lo spingi, più perdi), lo spreco in cucina che nessuno quantifica, l'ingrediente rincarato del 20% che non hai ribaltato sul prezzo. Nessuno di questi lo vedi finché non colleghi i quattro mondi. Il locale pieno che guadagna poco è quasi sempre un locale che non conosce il proprio food cost: incassa tanto e non sa quanto di quell'incasso resta.

## Gli scostamenti: dove sparisce la merce (e il margine)

C'è un numero che vale oro e che solo questo filo ti dà: lo **scostamento** tra consumo teorico e consumo reale. Il sistema, dalle ricette e dalle vendite, sa quanto guanciale *avresti dovuto* consumare per le carbonare vendute. L'inventario fisico dice quanto ne è *davvero* sparito. La differenza tra i due è il tuo spreco — e in un locale lo spreco è margine che evapora.

Uno scostamento alto su un ingrediente costoso è un segnale da leggere: porzioni troppo abbondanti (il cuoco «va a occhio» e abbonda), sprechi e scarti eccessivi, errori, o — capita — merce che esce dalla porta di servizio. Non serve fare la guardia: serve vedere il numero. Quando lo scostamento su un ingrediente costoso salta all'occhio, vai a capire perché, e spesso si sistema con una porzionatura più precisa o una procedura. Senza il filo, questo spreco è invisibile e continua per anni; con il filo, è un numero che puoi ridurre.

## Il menù come leva di margine

Una volta che hai il margine per piatto, il menù smette di essere una lista e diventa una leva. È quello che nella ristorazione si chiama *menu engineering*, e non serve un master per usarlo: incroci due cose, quanto un piatto **vende** e quanto **rende**. I piatti che vendono molto e rendono bene sono le tue stelle: mettili in evidenza. Quelli che vendono molto ma rendono poco: ritocca il prezzo o la ricetta, perché ogni ordine ti costa. Quelli che rendono ma vendono poco: spingili (posizione nel menù, consiglio del cameriere). Quelli che non vendono e non rendono: fuori dal menù.

Senza il food cost per piatto, queste decisioni le prendi a naso, e di solito sbagli — tieni in menù il piatto che ami e che perde, togli quello «povero» che invece reggeva il margine. Con i numeri, il menù diventa uno strumento di redditività, non un elenco di ciò che ti piace cucinare.

## Non rifare la cassa: collegala

Un punto fondamentale, perché è l'errore che spaventa (giustamente) i ristoratori: **non devi rifare la cassa**. Se hai un sistema di cassa che funziona, che il personale conosce, che gestisce le comande e i pagamenti — tienilo. Cambiare la cassa è invasivo, costoso, e rischia di rompere ciò che già gira nelle sere piene. Chi ti propone di sostituire tutto con «la sua cassa che fa anche il food cost» spesso ti sta vendendo un problema più grande di quello che risolve.

Quello che serve non è una cassa nuova: è **collegare la cassa che hai** al magazzino e alle fatture, così le vendite che già registri alimentano lo scarico e il food cost. La cassa resta il cuore della sala; sopra ci si aggancia il filo che mancava. È la stessa logica di [non rifare il gestionale ma collegarlo]({{ '/it/blog/giacenze-magazzino-disallineate/' | relative_url }}): parti da ciò che funziona e aggiungi il pezzo mancante, invece di ribaltare tutto. Se poi la cassa attuale è davvero un problema è un altro discorso, ma il food cost non è un buon motivo per cambiarla.

## Piccolo locale vs catena: due profondità

Quanto in profondità spingere dipende dalla tua scala, e vale la pena essere onesti.

Per un **piccolo locale**, spesso non serve tracciare ogni grammo di ogni ingrediente. Basta il filo sui piatti e sugli ingredienti che pesano — quelli costosi, quelli ad alto volume — per avere il food cost dove conta, senza appesantire nessuno. L'80% del margine si gioca sul 20% degli ingredienti: concentrarsi lì dà quasi tutto il valore con poca fatica.

Per una **catena o un locale strutturato**, il discorso si allarga: food cost confrontato tra locali (perché quello di Milano ha 4 punti più alto di quello di Roma con lo stesso menù?), controllo centralizzato delle ricette, acquisti aggregati. Qui il tema diventa anche il [confronto tra sedi]({{ '/it/blog/cruscotto-multi-sede/' | relative_url }}), applicato alla ristorazione: stesse definizioni di food cost, viste per locale, per capire dove si perde margine e replicare chi lo tiene basso.

In entrambi i casi la regola è la stessa: parti dal filo essenziale (ricetta-scarico-fattura) sui piatti e ingredienti che contano, e approfondisci solo dove il valore lo giustifica.

## Un caso tipo: dal locale pieno al piatto che perde

Un profilo tipico, architetturale, senza nomi. Ristorante con buon giro, sempre pieno il weekend, ma margine deludente a fine anno e nessuno che sapesse spiegarlo. Cassa funzionante, magazzino tenuto a occhio, fatture dal commercialista a trimestre. Il food cost? «Sarà intorno al 30%», a sensazione.

Cosa si è fatto. Prima le ricette dei piatti principali, con lo chef, per avere il consumo teorico. Poi il collegamento: la cassa esistente (non toccata) alimenta lo scarico di magazzino tramite le ricette, e le fatture fornitori alimentano i costi degli ingredienti. Infine la schermata del titolare: food cost complessivo e margine per piatto.

Dopo: il food cost reale non era il 30% immaginato, era più alto, e soprattutto era **molto diverso da piatto a piatto**. Due piatti «di punta» del menù rendevano quasi zero perché gli ingredienti erano rincarati e il prezzo non era mai stato aggiornato. Ritoccati quei due prezzi e riviste due ricette, il margine è migliorato senza toccare i volumi. E gli scostamenti hanno fatto emergere uno spreco in cucina su un ingrediente costoso. Con la solita nota: il valore non è stato «un software di food cost», è stato collegare quattro mondi che c'erano già ma non si parlavano — e far uscire un numero che prima si tirava a indovinare.

## Da dove si parte

Se decidessimo di partire, il primo passo non è comprare software: è **scrivere le ricette dei piatti che contano**. Prendi i venti-trenta piatti che vendi di più e i più costosi, e con lo chef metti giù le ricette standard — grammature vere, non teoriche. Questo, più i prezzi degli ingredienti dalle ultime fatture, ti dà già una prima stima del food cost per piatto, anche prima di collegare la cassa. Spesso bastano queste due cose per scoprire il piatto che perde.

Il secondo passo è guardare i numeri che hai: qual è l'incidenza delle materie prime sul fatturato negli ultimi mesi (te la dà il commercialista)? È il tuo food cost complessivo grezzo, e ti dice se il problema è grave. Da lì si decide dove approfondire. Si parte dal menù e dalla cassa che hai, non da una demo di software.

## È per te se / non è per te se

**È per te se:** hai un locale e sai quanto incassi ma non quanto guadagni per piatto; sospetti che alcuni piatti perdano margine ma non sai quali; il magazzino lo tieni a occhio e l'inventario non torna mai; le fatture dei fornitori le vedi a mesi di distanza, quando è tardi per reagire.

**Non è per te se:** hai un menù piccolissimo e fisso e controlli tutto a mente senza problemi; sei disposto a cambiare la cassa e ribaltare la sala (non serve, ed è controproducente); cerchi «solo una cassa nuova» — perché il food cost non nasce dalla cassa, nasce dal filo tra cassa, magazzino e fatture.

## Domande frequenti

**Devo cambiare la cassa?**
No, ed è il punto chiave. Se la cassa funziona, si collega — non si sostituisce. Le vendite che già registri alimentano lo scarico e il food cost. Cambiare la cassa è invasivo e rischioso, e il food cost non è un buon motivo per farlo.

**Il cuoco dovrà registrare gli ingredienti?**
No: lo scarico avviene da solo quando la sala batte la comanda, tramite la ricetta impostata una volta. Il personale non deve pesare né registrare nulla nel servizio. Gli unici gesti manuali (carico dal fornitore, scarti, pasti del personale) sono pochi tap, non un secondo lavoro.

**E se le ricette variano o lo chef «va a occhio»?**
Si parte da ricette standard sui piatti principali, che coprono la maggior parte del food cost. Le variazioni e i piatti speciali si gestiscono con un margine di approssimazione: meglio un food cost «abbastanza giusto» sui piatti che contano che una precisione perfetta impossibile da mantenere. L'obiettivo è decidere meglio, non la contabilità industriale al grammo.

**Come si collegano le fatture dei fornitori?**
I prezzi degli ingredienti vengono aggiornati dalle fatture (inserite o importate), così il costo dei piatti riflette i prezzi reali e attuali, non listini vecchi. Quando un fornitore rincara, vedi subito quali piatti ne soffrono e di quanto ritoccare il menù.

**Funziona per bar e pizzerie, non solo ristoranti?**
Sì. Il principio (ricetta-scarico-fattura → margine per prodotto) vale per qualsiasi locale che trasforma ingredienti in prodotti venduti: pizzeria, bar, gelateria, pasticceria. Cambiano i prodotti, non la logica.

**Ogni quanto vedo il food cost?**
Con il filo collegato, in continuo: il magazzino si scarica con le vendite, i costi si aggiornano dalle fatture. Non è più il rito dell'inventario annuale, è un numero che guardi ogni settimana e correggi quando serve — un prezzo, una ricetta, uno spreco.

**Serve anche se cambio menù spesso?**
Sì, anzi di più: se cambi menù di frequente (stagionale, del giorno), sapere al volo il food cost di un nuovo piatto ti dice a che prezzo metterlo per avere margine, invece di deciderlo a intuito e scoprire dopo che perdevi. Le ricette nuove si impostano in fretta, se il sistema è fatto bene.

**I dati (ricette, food cost, storico) restano miei?**
Sì. Ricette, costi, storico del food cost restano tuoi, niente lock-in. Le ricette con i costi sono un asset del locale: la base per decidere prezzi e menù nel tempo.

## In una riga

Se nel tuo locale conosci l'incasso ma non il food cost, il margine si perde nel buco tra sala, cucina, magazzino e fatture — quattro mondi che non si parlano. Non ti serve una cassa nuova: ti serve il **filo** che collega ricetta, scarico di magazzino e fatture fornitori, così esce da solo il margine per piatto e scopri quale piatto rende e quale perde. Lo scarico automatico dalla comanda (niente lavoro per il cuoco), la cassa che hai collegata invece che sostituita, e una schermata che ti dice dove il locale guadagna davvero.

Se vuoi capire dove si perde il tuo margine e come collegare la cassa che hai al magazzino e alle fatture, guarda i [progetti che ho costruito]({{ site.main_site }}/portfolio/) o [scrivimi due righe]({{ site.main_site }}/contatti/): partiamo dal tuo menù e dalla tua cassa, non da un software da rifare tutto.
