---
lang: it
permalink: /it/blog/manutenzione-software-dopo-go-live/
title: "Il progetto 'finito' che muore in sei mesi: manutenzione, piccole modifiche e perché il fornitore sparisce"
date: 2026-09-10 07:30:00 +0200
author: "Antonio Trento"
description: "Il go-live non è il traguardo, è la partenza. Cosa serve dopo il lancio perché il software non muoia in sei mesi: piccole modifiche, chi ha le chiavi, il contratto di manutenzione e come non restare ostaggio di un fornitore che sparisce."
keywords: ["manutenzione software dopo go live", "software morto dopo rilascio", "contratto manutenzione applicativa", "chi aggiorna l'app", "fornitore sparito"]
image: /assets/images/posts/manutenzione-software-dopo-go-live.jpg
pillar: comprare-software
related: [/it/blog/cosa-include-software-su-misura/, /it/blog/mvp-software-90-giorni/]
---

## Il giorno dopo il go-live inizia il vero uso

C'è una fotografia che riassume come muoiono i progetti software: la festa del lancio. Tutti contenti, il fornitore che consegna, il cliente che paga il saldo, strette di mano, "che bello, è finito". Sei mesi dopo, quella stessa cosa è un rudere: piena di piccoli fastidi mai sistemati, con un campo che serviva e non è mai arrivato, l'export che si è rotto quando è cambiata l'aliquota, e il fornitore che non risponde più al telefono. Il software non è morto per un difetto tecnico. È morto perché tutti hanno creduto che **il go-live fosse la fine.**

Il go-live non è la fine. È **la partenza.** Il giorno del lancio è il primo giorno in cui il software incontra la realtà vera — gli utenti veri, i dati veri, i casi che nessuno aveva previsto perché in fase di test non c'erano. È il momento in cui scopri cosa avevi capito bene e cosa no. Un software appena lanciato è come un negozio appena aperto: il taglio del nastro non è il traguardo, è il minuto zero del lavoro vero. Da lì in poi comincia l'uso, e l'uso porta cose da aggiustare, da migliorare, da aggiungere. Sempre. Non perché è stato fatto male: perché è **vivo**.

Questa idea che "finito = consegnato" è la trappola culturale più costosa nel comprare software. Nasce da un fraintendimento: pensare al software come a un oggetto — compro una sedia, la sedia è finita, la uso per dieci anni senza toccarla. Ma il software non è una sedia. È più simile a un'automobile: la compri finita, sì, ma se non fai il tagliando, non cambi l'olio, non la porti dal meccanico quando fa un rumore strano, dopo un po' ti pianta in mezzo alla strada. Nessuno si stupisce che un'auto vada mantenuta. Con il software, invece, ci si stupisce sempre — e in quello stupore si consumano i progetti.

Questo articolo è su cosa succede *dopo* il lancio, e su come si evita che il tuo software diventi il rudere di cui sopra. È la faccia complementare della [guida a cosa comprare quando firmi uno sviluppo su misura]({{ '/it/blog/cosa-include-software-su-misura/' | relative_url }}): lì abbiamo visto cosa c'è nel preventivo; qui vediamo cosa c'è — o dovrebbe esserci — nel *dopo*, che è la parte dove i progetti vivono o muoiono.

## Piccole modifiche: l'IVA, un campo, un export

Partiamo dalle cose piccole, perché sono quelle che uccidono per prime. Non è il grande guasto a mandare in rovina un software: sono le **piccole modifiche mai fatte**, che si accumulano finché lo strumento diventa inutilizzabile.

Facciamo esempi concreti, di quelli che capitano a tutti:

- **Cambia un'aliquota, cambia una regola fiscale.** Il legislatore modifica qualcosa — un'aliquota, un obbligo, un formato — e il tuo software, che quella regola ce l'ha scritta dentro, va aggiornato. Se non c'è nessuno che lo fa, da un giorno all'altro emette documenti sbagliati. Non è un capriccio: è manutenzione obbligata dalla realtà.
- **Serve un campo in più.** Usando il software scopri che ti serve registrare un'informazione che all'inizio non avevi previsto — un dato del cliente, una nota, una categoria. Piccola cosa. Ma se non c'è nessuno che la aggiunge, cominci a tenerla "a parte", su un foglio, e il software comincia a diventare inutile perché non contiene più tutto.
- **Serve un export diverso.** Il commercialista ti chiede i dati in un altro formato, o devi mandarli a un nuovo partner, e ti serve tirarli fuori in un modo che prima non c'era. Piccola modifica. Ma senza qualcuno che la faccia, ricominci a copiare a mano — e hai appena vanificato metà del motivo per cui avevi comprato il software.

Il punto è che **queste modifiche non sono difetti: sono la vita normale di uno strumento che usi davvero.** Un software che non le riceve non è "finito e stabile": è **fermo mentre il mondo intorno si muove**, e uno strumento fermo mentre tu cambi diventa in fretta una zavorra. Ogni piccola modifica saltata è un pezzetto di lavoro che torni a fare a mano, un pezzetto di fiducia che perdi nello strumento, un passo verso il "tanto vale non usarlo". La morte del software non è un evento, è una lenta erosione fatta di piccole cose non fatte — ed è esattamente ciò che un buon rapporto di manutenzione impedisce.

## Chi ha le chiavi: hosting, store, DNS, backup

Adesso una domanda che sembra tecnica e invece è pura sopravvivenza: **chi ha le chiavi di casa tua digitale?** Perché il tuo software, per funzionare, vive in dei posti e ha degli accessi, e se quelle chiavi non le hai tu, non possiedi davvero la tua stessa attività online.

Le "chiavi" che devi assolutamente controllare:

- **L'hosting** — il posto dove il software gira, i server, i servizi cloud. Se l'account è intestato al fornitore e non a te, il giorno che lui sparisce o litigate, il tuo software è ospitato in casa di qualcun altro che può chiuderti fuori.
- **Il dominio e il DNS** — l'indirizzo del tuo sito e il sistema che lo fa puntare dove deve. Ho visto aziende scoprire di non possedere il proprio dominio, intestato all'agenzia sparita: significa non possedere il proprio indirizzo, e non poter fare niente senza chi ne ha il controllo.
- **Gli account degli store**, se hai un'app pubblicata — gli account da cui l'app viene distribuita. Se sono del fornitore, la tua app sta sul suo scaffale, non sul tuo.
- **I backup** — le copie di sicurezza dei tuoi dati e del sistema. Dove sono? Chi li fa? Puoi accedervi? Un backup che esiste solo nel computer del fornitore non è un tuo backup: è una speranza intestata a qualcun altro.

La regola è semplice e non negoziabile: **le chiavi devono essere intestate a te.** Il fornitore le usa per lavorare, con i tuoi permessi, ma la proprietà è tua. Non è sfiducia: è la differenza tra avere un inquilino a cui dai le chiavi e affittare una casa di cui non possiedi nemmeno la serratura. Se oggi non sai rispondere a "di chi sono l'hosting, il dominio, gli account, i backup del mio software?", hai appena trovato la cosa più urgente da sistemare — prima ancora della prossima modifica. Perché senza le chiavi, tutto il resto (manutenzione, cambio fornitore, persino accedere ai tuoi dati) dipende dalla buona volontà di qualcun altro.

## Il contratto di manutenzione: ore, SLA e cosa è "extra", spiegato semplice

"Contratto di manutenzione" suona come una fregatura per far pagare ancora. In realtà, fatto bene, è ciò che ti garantisce che lo strumento resti vivo e che qualcuno risponda quando serve. Vediamo cosa contiene, in parole povere, senza termini da iniziati.

Un contratto di manutenzione serio mette in chiaro tre cose:

- **Cosa è incluso e cosa è extra.** La distinzione fondamentale è tra *tenere in vita* e *far crescere*. Tenere in vita — che il software continui a funzionare, gli aggiornamenti di sicurezza, sistemare quello che si rompe, le piccole correzioni — è la manutenzione vera e propria, di solito coperta dal canone. Far crescere — funzioni nuove, cambiamenti grossi, moduli in più — è sviluppo aggiuntivo, e si paga a parte. Un buon contratto disegna questa linea con chiarezza, così sai in anticipo cosa rientra e cosa no, e non ti trovi conti a sorpresa né discussioni su "questa è manutenzione o è nuova?".
- **Quanto tempo hai a disposizione.** Spesso la manutenzione include un monte di ore o di interventi: le piccole modifiche di cui sopra rientrano lì. Sapere quante ne hai ti fa pianificare, e sapere cosa succede se le superi (si comprano ore extra, a che prezzo) ti evita sorprese.
- **Con che velocità ti rispondono — lo SLA, in parole umane.** SLA è una sigla che vuol dire, in concreto: *se qualcosa si rompe, in quanto tempo ti mettono le mani sopra?* E la risposta non è "subito" per tutto, perché non tutto è uguale. Un buon accordo distingue:
  - *Il software è fermo, non lavori più*: è un'emergenza, e deve avere una risposta rapida — ore, non giorni. Questo è il caso che ti costa di più (vedi dopo), quindi deve essere il più protetto.
  - *Qualcosa non funziona ma puoi lavorare lo stesso*: importante ma non emergenza, si interviene in un tempo ragionevole concordato.
  - *Una piccola modifica, un miglioramento*: si programma, si fa quando c'è spazio.

Il senso dello SLA non è la sigla: è mettere per iscritto **cosa ti aspetti quando le cose vanno male**, così che nel momento del panico non ci sia da discutere. "Se il gestionale si pianta un lunedì mattina, entro quanto qualcuno ci lavora?" — la risposta a questa domanda, scritta prima, è metà del valore di un contratto di manutenzione. L'altra metà è sapere che quel qualcuno **esiste e conosce il tuo sistema**, che è esattamente il contrario del prossimo scenario.

## Il fornitore che sparisce (e il codice è sul suo PC)

Ecco l'incubo, quello vero, quello che sento raccontare più spesso: il fornitore **sparisce**. Non risponde più alle mail, il telefono squilla a vuoto, ha cambiato lavoro, ha chiuso, o semplicemente ha perso interesse per il tuo progetto piccolo mentre ne insegue di più grossi. E tu resti con un software che usi tutti i giorni e nessuno che sappia metterci mano.

Il ghosting del fornitore fa così male per una ragione precisa: **il software è una scatola che, senza chi l'ha costruita, nessun altro sa aprire facilmente.** Se il codice sta "sul PC del fornitore", se non c'è documentazione, se gli accessi li aveva solo lui, quando sparisce si porta via le chiavi di comprensione di tutto. Un nuovo fornitore, messo davanti a quel software, deve prima capire da zero come è fatto — un lavoro lungo e costoso, ammesso che il codice sia recuperabile. Nel frattempo tu sei bloccato: niente modifiche, e se si rompe qualcosa, il panico.

Come ci si protegge da questo scenario? Non sperando che il fornitore sia una brava persona (magari lo è, ma non ci scommetti l'azienda), ma **pretendendo in partenza le cose che ti rendono indipendente da lui.** Ci arriviamo tra un attimo con la lista di cosa farti consegnare, perché è il cuore della difesa. Ma il principio è questo: un fornitore serio *lavora perché tu possa fare a meno di lui.* Ti lascia il codice, gli accessi, la documentazione, i dati esportabili — non perché voglia perderti, ma perché sa che il modo giusto di tenere un cliente è il valore, non il ricatto dell'insostituibilità. Chi invece tiene tutto per sé, chi rende oscuro apposta, chi ti fa capire che "senza di me sei perso", non ti sta proteggendo: ti sta preparando la trappola. È la stessa logica che vale quando devi [riscrivere un gestionale legacy]({{ '/it/blog/riscrivere-software-gestionale-legacy/' | relative_url }}) ereditato da chi non c'è più — solo che lì il danno è già fatto, mentre qui puoi evitarlo scegliendo bene *prima*.

## Cosa pretendere in consegna: la lista che ti rende libero

Questa è la sezione da tenere sottomano, letteralmente. Al momento della consegna di un software — al go-live, o quando chiudi un contratto — ci sono delle cose che **devi** ricevere, e riceverle è la differenza tra possedere il tuo software ed essere ospite in casa sua. Pretendile, per iscritto, fin dall'inizio.

La lista di consegna che ti rende libero:

- **Il codice sorgente, in un posto che è tuo.** Non "sul PC del fornitore": in un archivio (un repository) intestato a te, a cui hai accesso. È la ricetta del tuo software: senza, non possiedi niente di riproducibile.
- **Tutti gli accessi, intestati a te.** Hosting, dominio, DNS, account dei servizi, store, database. Le chiavi di cui sopra, tutte, nelle tue mani.
- **I backup, e il modo di farli.** Dove sono le copie di sicurezza, come si accede, con che frequenza si fanno. E la certezza di poter recuperare i tuoi dati anche da solo.
- **I tuoi dati, esportabili.** La possibilità concreta di tirare fuori tutti i tuoi dati in un formato utilizzabile. Se non puoi esportarli, sono in ostaggio.
- **La documentazione viva.** Non un tomo che nessuno legge, ma le informazioni essenziali per capire com'è fatto il sistema e come si mette mano: dove sono le cose, come si aggiorna, come si riparte se cade. "Viva" significa aggiornata quando il software cambia, non scritta una volta e dimenticata.

Il test per capire se questa lista è a posto è brutale e liberatorio: **"se domani il mio fornitore sparisce, un altro tecnico competente può prendere in mano il mio software e portarlo avanti?"** Se la risposta è sì, sei libero: hai un fornitore per scelta, non per prigionia. Se la risposta è no, non importa quanto sia bravo o simpatico chi ce l'hai adesso — sei in trappola, e la trappola scatterà nel momento peggiore. Pretendere questa lista *non* è mancanza di fiducia: è la cosa che ti permette di fidarti serenamente, perché sai che se qualcosa va storto non sei finito. E un fornitore che te la dà volentieri è, di per sé, il segnale che è quello giusto.

## Il costo del fermo contro il costo del canone

Torniamo ai soldi, perché è lì che l'obiezione "la manutenzione costa" si scioglie. La domanda giusta non è "quanto costa il canone di manutenzione?", ma "**quanto mi costa quando il software si ferma e non c'è nessuno?**". Mettiamoli a confronto onestamente.

Il **canone di manutenzione** è un costo prevedibile, pianificabile, che come ordine di grandezza sta in quel 15-25% annuo del valore del software. Lo metti a budget, lo sai, non ti sorprende. In cambio hai: lo strumento che resta vivo, le piccole modifiche fatte, la sicurezza aggiornata, e — soprattutto — qualcuno che conosce il tuo sistema e risponde quando chiami.

Il **costo del fermo** è imprevedibile e spesso molto più alto. Pensa a cosa succede se il software su cui gira la tua attività si pianta un martedì mattina e non c'è nessuno:

- **Non lavori.** Se il gestionale è fermo, l'azienda è ferma o va a mano, male, di corsa. Ogni ora di fermo è lavoro perso, clienti che aspettano, ordini che non partono. Fai un conto grezzo: se in azienda ci sono cinque persone che dipendono da quello strumento e restano bloccate mezza giornata, sono decine di ore di lavoro pagato e produttività a zero, più gli ordini slittati e i clienti spazientiti — per molte realtà una singola giornata di fermo vale, tra costo del personale fermo e mancato fatturato, quanto o più del canone annuale di manutenzione che si voleva risparmiare.
- **Paghi l'emergenza a caro prezzo.** Trovare qualcuno che risolva *adesso*, di corsa, un problema su un software che non conosce, costa molto più che avere un rapporto continuativo con chi lo conosce già. L'intervento d'emergenza è sempre la tariffa più cara.
- **Perdi dati o fiducia.** Nei casi peggiori un fermo mal gestito significa dati persi o clienti che smettono di fidarsi. Danni che non si misurano solo in euro.

Messi in fila, il conto è netto: **il canone di manutenzione non è un costo, è il prezzo di non avere il costo del fermo.** È un'assicurazione, e come tutte le assicurazioni sembra soldi buttati finché non serve — poi, il giorno che serve, vale dieci volte quello che è costata. Chi taglia la manutenzione per risparmiare sta scommettendo che non si romperà mai niente e che non gli servirà mai una modifica: è una scommessa che si perde sempre, perché il software è vivo e la vita porta cambiamenti. Questo è anche il motivo per cui il "budget per il dopo" va previsto fin dall'inizio, come spiego parlando del [cosa succede dopo un MVP]({{ '/it/blog/mvp-software-90-giorni/' | relative_url }}): chi spende tutto per arrivare al lancio resta senza benzina proprio quando il viaggio comincia.

## Quanta manutenzione ti serve davvero: né troppa, né zero

Attenzione, perché sul tema manutenzione si sbaglia in due direzioni opposte, e la seconda te la nascondo di meno proprio perché va contro chi vende manutenzione. La prima è quella di cui abbiamo parlato: **zero manutenzione**, il software abbandonato che muore. La seconda è l'opposto: farsi vendere **più manutenzione di quella che serve**, un canone gonfiato per un software che non ha bisogno di tutta quell'attenzione. Il giusto sta nel dimensionare onestamente, ed è una cosa che dipende da *cosa* è il tuo software.

Alcune coordinate per capire quanta te ne serve davvero:

- **Quanto è critico?** Se il software è il cuore della tua operatività — se fermo significa azienda ferma — allora ti serve una manutenzione seria, con risposta rapida garantita: qui non si risparmia. Se invece è uno strumento comodo ma non vitale, il cui fermo di un giorno è un fastidio e non un disastro, puoi permetterti un accordo più leggero, con tempi di risposta più rilassati.
- **Quanto tocca il mondo esterno?** Un software che parla con pagamenti, banche, enti, servizi esterni ha più bisogno di manutenzione, perché quel mondo cambia le regole in continuazione e lui deve stargli dietro. Un software chiuso, che fa i suoi conti per conto suo, cambia meno e ha bisogno di meno interventi.
- **Quanto cambia la tua azienda?** Se sei in una fase di crescita e cambiamento, il software ti seguirà con tante piccole modifiche: la manutenzione sarà più attiva. Se sei stabile e i processi non cambiano, servirà soprattutto il "tenere in vita", con poche modifiche.

**Un contratto di manutenzione serio è per te se** il tuo software è vivo, lo usi ogni giorno e un suo fermo o un suo blocco ti costa lavoro, clienti o soldi. **Non ti serve un contratto pesante se** lo strumento è secondario, poco esposto al mondo esterno, e stabile — lì basta un accordo leggero o anche solo la certezza di poter chiamare qualcuno all'occorrenza. Quello che *non* è mai un'opzione sensata è **zero**: anche il software più tranquillo ha bisogno, ogni tanto, di sicurezza aggiornata e di qualcuno che sappia dove mettere le mani.

Un fornitore onesto ti dimensiona la manutenzione sul tuo caso vero, e ti dice tranquillamente "a te ne basta poca" quando è così — perché il suo interesse è che tu paghi il giusto ed sia contento, non che tu firmi il canone più alto possibile. Se qualcuno ti vuole vendere un contratto di manutenzione enorme per uno strumento che non lo giustifica, è la stessa musica del venditore di slide, cambiata di verso. La misura, anche qui, è la regola.

## Come cambiare cavallo senza morire

E se il fornitore che hai adesso non va bene? Non sparisce, ma non risponde in tempo, o è diventato caro, o semplicemente non ti dà più il servizio che serve. Puoi cambiare — ma va fatto con testa, perché è il momento più delicato, quello in cui sei più vulnerabile.

Le regole per cambiare fornitore senza restare a piedi:

- **Prima recupera le chiavi, poi molla.** Non annunciare che cambi finché non hai in mano codice, accessi, backup e dati esportati. Se lo dici prima e le chiavi ce le ha ancora lui, ti sei messo in una posizione debole. Recupera tutto *mentre* il rapporto è ancora buono, poi decidi.
- **Non spegnere il vecchio prima di aver acceso il nuovo.** Il passaggio si fa in sovrapposizione: il nuovo fornitore studia, prende in mano, verifica di poter gestire tutto, e *solo allora* si stacca il vecchio. Mai un vuoto in mezzo in cui nessuno è responsabile.
- **Fai fare al nuovo un "esame" del sistema.** Prima di impegnarti, chiedi al nuovo fornitore di guardare il codice e la documentazione e dirti onestamente in che stato è e cosa comporta prenderlo in carico. Se il lavoro precedente era una scatola nera senza documentazione, meglio saperlo prima.
- **Documenta il passaggio.** Ciò che si scopre e si sistema durante il cambio va scritto, così il nuovo rapporto parte con la documentazione viva che magari mancava.

La verità è che **cambiare fornitore è facile o impossibile a seconda di cosa hai preteso all'inizio.** Se hai la lista di consegna a posto — codice tuo, accessi tuoi, dati esportabili, documentazione — cambiare è un progetto gestibile. Se non ce l'hai, cambiare è quasi rifare da zero, e resti prigioniero non per scelta ma per mancanza di alternative. Ecco perché tutto torna al principio: la libertà nel *dopo* si costruisce nel *prima*, pretendendo le cose giuste quando ancora hai potere contrattuale. È il filo che lega tutto il cluster [comprare software su misura]({{ '/it/pillar/comprare-software/' | relative_url }}): comprare bene non è solo scegliere il fornitore giusto oggi, è restare liberi di sceglierne un altro domani.

Se hai un software che ti sta a cuore e vuoi capire se sei libero o prigioniero — se hai le chiavi, se potresti cambiare, se sei coperto quando si rompe — è un controllo che vale la pena fare *prima* che serva. [Guarda come lavoro]({{ site.main_site }}/portfolio/) o [scrivimi]({{ site.main_site }}/contatti/) e lo verifichiamo sul tuo caso.

## 8 domande da chi sta per firmare

**1. Perché devo pagare la manutenzione se il software è "finito"?**
Perché non è finito: è vivo. Il mondo intorno cambia (regole, aliquote, sicurezza, servizi collegati) e l'uso vero porta sempre piccole modifiche. Un software non mantenuto non resta stabile, si degrada: è il "progetto finito che muore in sei mesi". Il canone tiene lo strumento vivo e ti garantisce qualcuno che risponde.

**2. Cosa rientra nella manutenzione e cosa si paga a parte?**
In genere il *tenere in vita* (funzionamento, sicurezza, correzioni, piccole modifiche) è nel canone; il *far crescere* (funzioni nuove, moduli, grandi cambiamenti) è sviluppo aggiuntivo a parte. Un buon contratto disegna questa linea in chiaro, così non ci sono sorprese né discussioni.

**3. Cos'è lo SLA, in parole semplici?**
È la promessa scritta di *con che velocità ti rispondono quando qualcosa va male*. Un buon accordo distingue l'emergenza (software fermo, risposta in ore) da ciò che è importante ma non bloccante (tempo ragionevole concordato) e dalle piccole modifiche (si programmano). Serve a non dover discutere nel momento del panico.

**4. Come faccio a sapere se ho "le chiavi" del mio software?**
Chiediti di chi sono, intestati, l'hosting, il dominio e DNS, gli account dei servizi e degli store, i backup. Se la risposta è "del fornitore", non possiedi la tua presenza digitale. Devono essere intestati a te: lui li usa per lavorare, ma la proprietà è tua.

**5. Cosa devo farmi consegnare per non restare prigioniero?**
Il codice sorgente in un archivio tuo, tutti gli accessi intestati a te, i backup e come farli, i tuoi dati esportabili, e una documentazione viva. Il test: "se il fornitore sparisce, un altro tecnico può prendere in mano il mio software?". Se sì, sei libero; se no, sei in trappola.

**6. E se il mio fornitore è già sparito e non ho niente in mano?**
Si può recuperare, ma è più costoso: un nuovo tecnico deve prima capire da zero un sistema senza documentazione. Prima cosa, recupera ogni accesso e ogni copia che riesci; poi fai valutare lo stato del codice a qualcuno di competente. È lo scenario del gestionale legacy ereditato: gestibile, ma è il motivo per cui conviene pretendere le cose giuste *prima*.

**7. Quanto costa davvero non fare manutenzione?**
Molto più del canone. Il costo del fermo (non lavori, l'azienda si blocca), il costo dell'emergenza (far risolvere di corsa a chi non conosce il sistema costa la tariffa più cara), e nei casi peggiori dati o clienti persi. Il canone di manutenzione è l'assicurazione che eviti questi costi: sembra spesa finché non serve, poi vale dieci volte.

**8. Posso cambiare fornitore senza bloccare tutto?**
Sì, se hai le chiavi. Recupera codice, accessi, backup e dati *mentre* il rapporto è ancora buono, fai studiare il sistema al nuovo fornitore, e stacca il vecchio solo quando il nuovo è pronto — mai un vuoto in mezzo. Se hai preteso la lista di consegna all'inizio, cambiare è gestibile; se non ce l'hai, è quasi rifare da zero.
