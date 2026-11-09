---
lang: it
permalink: /it/blog/ai-lettura-fatture-errori/
alt_url: /en/blog/ai-invoice-reading-errors/
title: "AI che legge le fatture: 7 casi in cui sbaglia l'IVA (e come non farti fregare dal \"99% di accuratezza\")"
date: 2026-11-29 07:30:00 +0200
author: "Antonio Trento"
description: "Per titolari e amministrativi che valutano un software che legge le fatture con l'AI: perché l'XML della fattura elettronica viene prima del PDF, i 7 errori classici sull'IVA (split payment, reverse charge, bollo, arrotondamenti, omonimi, estero, allegato sbagliato), cosa deve controllare una persona, come misurare e quanto costa."
keywords: ["ai lettura fatture errori", "ocr fatture elettroniche", "estrazione dati pdf fattura", "intelligenza artificiale contabilità", "fattura xml vs pdf", "automazione fatture passive"]
image: /assets/images/posts/ai-lettura-fatture-errori.jpg
pillar: documenti-fatture-ai
related: [/it/blog/ocr-fattura-elettronica-accuratezza/, /it/blog/accuratezza-estrazione-documenti-campi/]
---

## Il vendor che promette il 99%

La presentazione è sempre convincente. "Carichi le fatture, la nostra intelligenza artificiale le legge, estrae fornitore, importi, IVA e scadenze, e le registra nel gestionale. Accuratezza del 99%." Segue una demo su dieci fatture pulite, tutte giuste. L'amministrazione, che passa ore ogni settimana a registrare fatture passive, comincia a sperare.

Tre mesi dopo, il commercialista chiama: la liquidazione IVA del trimestre non torna. Scavando, saltano fuori una fattura a una pubblica amministrazione registrata come se l'IVA l'avessimo incassata, due fatture estere con l'IVA italiana calcolata sopra, un bollo da 2 euro finito nell'imponibile, e una manciata di centesimi che non quadrano su decine di documenti. Niente di catastrofico, preso uno per uno. Messi insieme, una giornata di lavoro per sistemare e un po' di imbarazzo.

Se stai valutando un software che usa l'**AI per leggere le fatture**, questo pezzo ti serve a non farti fregare dal numero sulla slide. Non parliamo di tecnologia ma di **soldi e IVA**: perché in Italia la fattura elettronica XML viene prima di qualsiasi lettura "intelligente" del PDF, quali sono i **7 errori classici** che un sistema automatico commette sull'IVA, cosa deve continuare a controllare una persona, come si misura davvero l'accuratezza, e quanto costa tutto questo rispetto alle ore dell'amministrativo.

## È per te / non è per te

È per te se:

- sei titolare, responsabile amministrativo o contabile di una PMI che riceve da qualche decina a qualche migliaio di fatture passive al mese;
- stai valutando (o hai già comprato) un software che "legge" le fatture con l'AI;
- vuoi capire dove l'automazione fa risparmiare davvero e dove crea lavoro in più per il commercialista.

Non è per te se cerchi un confronto tecnico tra motori OCR o modelli: qui il punto è contabile. E non è per te se ricevi dieci fatture al mese: registrarle a mano costa meno di qualsiasi progetto (ma leggi comunque la sezione sui 7 errori: valgono anche per chi registra a mano).

## Fattura elettronica: il XML c'è già, il PDF è il piano B

La prima cosa da sapere, e quella che molti venditori tacciono: in Italia **la quasi totalità delle fatture tra operatori nazionali è elettronica**, in formato XML, e passa dal Sistema di Interscambio (SDI). Dal 2024 l'obbligo riguarda anche i forfettari. Questo significa che per la grande maggioranza delle tue fatture passive **i dati sono già strutturati**: fornitore, partita IVA, imponibile, aliquote, natura delle operazioni esenti, esigibilità dell'IVA, scadenze, IBAN, bollo. Sono campi precisi, scritti dal fornitore, firmati e trasmessi.

Leggere quei dati da un PDF con l'AI, quando l'XML esiste, è come fotografare un foglio Excel e poi chiedere a un sistema di ricopiare i numeri dalla foto. Può funzionare, ma introduce errori che nell'originale non c'erano.

### Il flusso XML-first, spiegato a un amministrativo

1. **Le fatture arrivano dallo SDI** al tuo canale di ricezione: il cassetto fiscale, il software del commercialista, l'intermediario, o una casella PEC. In ogni caso il file "vero" è l'XML (a volte firmato, con estensione `.p7m`).
2. **Il software legge l'XML**, non il PDF. Ogni dato ha il suo campo: non c'è niente da "indovinare". Il PDF di cortesia, se c'è, serve solo per la consultazione a vista.
3. **Controlli automatici** sui dati letti: la partita IVA corrisponde a un fornitore in anagrafica? La somma delle righe torna con il riepilogo IVA? C'è un'esigibilità particolare (scissione dei pagamenti)? C'è una natura di esenzione o di inversione contabile?
4. **Registrazione proposta** nel gestionale, con il conto, il codice IVA e la scadenza.
5. **Solo per i documenti senza XML** — fatture estere, ricevute, documenti che non passano dallo SDI — entra in gioco la lettura del PDF con l'AI, e questi documenti vanno **sempre** in revisione.

Se un software ti propone di leggere con l'AI anche le fatture elettroniche italiane, partendo dal PDF, la domanda da fare è: "**perché non usate l'XML?**". Se la risposta è vaga, hai capito molto del prodotto. Il ragionamento tecnico completo, su come si misura la differenza, è nel pezzo su [fattura elettronica XML e OCR]({{ '/it/blog/ocr-fattura-elettronica-accuratezza/' | relative_url }}).

## 7 errori classici sull'IVA

Questi sono gli errori che vedo più spesso nei sistemi che leggono le fatture in automatico. Alcuni nascono dalla lettura del PDF, altri dalla registrazione automatica anche quando i dati sono letti bene dall'XML. Tutti finiscono, prima o poi, sulla scrivania del commercialista.

### Tabella dei 7 errori

| # | Errore | Cosa succede | Come lo eviti |
|---|---|---|---|
| 1 | **Split payment** (scissione dei pagamenti) | Su fatture verso PA e alcune società, l'IVA la versa il cliente all'Erario, non il fornitore. Se il sistema la tratta come IVA ordinaria, la liquidazione sbaglia | Leggere il campo di esigibilità dall'XML; regola specifica nel gestionale |
| 2 | **Reverse charge** (inversione contabile) | La fattura non espone IVA, ma ha una "natura" che obbliga a integrarla. Il sistema registra imponibile senza IVA e si dimentica l'integrazione | Leggere la natura dell'operazione dall'XML e applicare il codice IVA corretto |
| 3 | **Bollo** | Il bollo da 2 € su fatture esenti sopra una certa soglia finisce nell'imponibile o nell'IVA | Campo bollo letto dall'XML e registrato a parte |
| 4 | **Arrotondamenti** | Totale delle righe e riepilogo IVA differiscono di qualche centesimo; il sistema "aggiusta" a caso o sceglie il valore sbagliato | Usare il riepilogo IVA dell'XML come fonte; segnalare le differenze invece di correggerle |
| 5 | **Fornitore omonimo** | Due fornitori con nomi simili; la fattura finisce sulla scheda sbagliata con IBAN e conti sbagliati | Associazione per partita IVA, mai per ragione sociale |
| 6 | **Fattura estera** | Fattura di un fornitore UE o extra-UE in PDF: il sistema legge "VAT 19%" e registra IVA italiana, o non gestisce l'integrazione | Sempre in revisione; regole per acquisti intra-UE ed extra-UE; documenti integrativi via SDI dove previsti |
| 7 | **Allegato sbagliato** | Il PDF allegato non corrisponde all'XML (proforma, nota di credito, documento di un altro mese); il sistema legge il PDF e ignora l'XML | XML come fonte unica; il PDF serve solo a vista; controllo di coerenza tra i due |

### I sette casi, uno per uno

**1. Split payment.** Quando fatturi (o ricevi fatture) in regime di scissione dei pagamenti — tipico verso pubbliche amministrazioni e alcune società quotate o controllate — l'IVA esposta in fattura non la incassa il fornitore: la versa direttamente il cliente. Nell'XML c'è un campo che lo dice (l'esigibilità dell'IVA). Se il sistema legge solo "imponibile 1.000, IVA 220, totale 1.220" dal PDF e registra come una fattura ordinaria, i pagamenti e la liquidazione vengono sbagliati. Dal PDF, a occhio, la differenza spesso non si vede.

**2. Reverse charge.** In molti casi (subappalti in edilizia, certi settori, acquisti dall'estero) la fattura arriva senza IVA, con l'indicazione di una "natura" che segnala l'inversione contabile. Chi riceve deve integrare la fattura con l'IVA e registrarla sia negli acquisti sia nelle vendite. Un sistema che legge "IVA 0" e registra un acquisto senza IVA ha fatto il 50% del lavoro, e il restante 50% è quello che conta per il fisco.

**3. Bollo.** Sulle fatture esenti o non imponibili sopra una certa soglia (77,47 €) si applica il bollo da 2 €, spesso addebitato al cliente. Nell'XML c'è un campo apposito. Dal PDF, il "2,00" compare come una riga in più, e il sistema lo può sommare all'imponibile o, peggio, trattare come IVA.

**4. Arrotondamenti.** Il totale calcolato sommando le righe e il totale del riepilogo IVA possono differire di uno o due centesimi, per come il fornitore arrotonda. È normale. Il problema nasce quando il sistema "corregge" da solo, scegliendo un valore a caso, o quando, leggendo il PDF, confonde un totale di riga con il totale del documento. Un centesimo per fattura, su mille fatture, è un disallineamento che qualcuno dovrà spiegare.

**5. Fornitore omonimo.** "Rossi S.r.l.", "Rossi Impianti S.r.l.", "Rossi & Figli": se il sistema associa la fattura al fornitore partendo dal nome, prima o poi sbaglia. E quando sbaglia, la fattura eredita l'IBAN, le condizioni di pagamento e il conto contabile dell'altro fornitore. L'unico identificativo affidabile è la **partita IVA**, verificata con il suo codice di controllo e cercata in anagrafica.

**6. Fattura estera.** Un fornitore tedesco manda un PDF con "MwSt. 19%" o "VAT 0% — reverse charge". Il sistema che legge il PDF non sa che per un acquisto intracomunitario di beni o servizi l'IVA italiana va integrata dal cliente, né che dal 2022 questi acquisti si comunicano tramite documenti integrativi trasmessi allo SDI. Le fatture estere sono il caso in cui la lettura con l'AI è davvero utile (non c'è XML), ma sono anche quelle che vanno **sempre** controllate da una persona.

**7. Allegato sbagliato.** La fattura elettronica arriva con un PDF allegato. A volte il PDF è la copia di cortesia; a volte è una proforma, un preventivo, una nota di credito, il documento di un altro mese. Se il sistema legge l'allegato invece dell'XML, registra un documento diverso da quello fiscalmente valido. Regola semplice: **l'XML è il documento, il resto è contorno**.

## Cosa deve fare l'umano e sopra quale soglia

Nessun sistema dovrebbe registrare in automatico tutte le fatture. La domanda giusta è: **quali fatture possono passare senza che una persona le guardi, e quali no?**

Le fatture che possono passare in automatico (con un controllo a campione) sono quelle che rispettano **tutte** queste condizioni:

- arrivano come **XML dallo SDI** e i dati sono letti dall'XML;
- il fornitore è **già in anagrafica**, associato per partita IVA;
- l'IBAN è **lo stesso già registrato** per quel fornitore;
- non ci sono nature particolari (split payment, reverse charge, esenzioni) **oppure** ci sono ma esiste una regola già verificata per quel fornitore;
- i totali **quadrano** (righe, riepilogo IVA, totale documento);
- l'importo è **sotto una soglia** decisa dall'amministrazione (per esempio 5.000 €).

Tutto il resto va in **revisione**, con il motivo in evidenza:

- fatture estere e documenti senza XML;
- fornitori nuovi;
- IBAN diverso da quello registrato (attenzione: è anche il segnale tipico di una truffa);
- prime fatture con nature particolari;
- differenze nei totali;
- importi sopra soglia.

Su queste fatture l'AI resta utile: prepara i dati, propone la registrazione, evidenzia cosa non torna. Ma la decisione la prende una persona. Il rapporto tipico, nelle aziende in cui ho visto questi sistemi funzionare, è 60–80% delle fatture in automatico e 20–40% in revisione. Se un fornitore ti promette il 100% in automatico, sta promettendo che nessuno guarderà mai le fatture estere e gli IBAN cambiati.

## Come misurare campo per campo (l'IVA vale più dell'indirizzo)

Il famoso "99% di accuratezza" va smontato con una domanda: **99% di cosa?** Spesso è la percentuale di caratteri letti correttamente, o la media su tutti i campi di tutte le fatture. In questa media, il nome della via e il CAP contano quanto l'IVA e l'IBAN. Ma un CAP sbagliato non costa niente; un'IVA sbagliata costa una liquidazione da rifare.

### Una definizione onesta di accuratezza

Per un'amministrazione, l'accuratezza che conta si misura così:

- **per campo**, separatamente: partita IVA, imponibile, IVA, totale, natura/esigibilità, scadenza, IBAN, numero e data del documento;
- **con tolleranza zero sugli importi**: un centesimo di differenza è un errore;
- **pesata per il costo dell'errore**: l'IVA e l'IBAN pesano dieci volte l'indirizzo;
- **per tipo di documento**: fatture elettroniche italiane, fatture estere, documenti scansionati, separatamente. Il 99% sulle prime e il 70% sulle seconde fanno una media che non descrive nessuna delle due;
- **su un campione di fatture vere tue**, non sulle dieci della demo: almeno qualche centinaio, scelte tra fornitori grandi e piccoli, italiani ed esteri.

E la domanda più importante: **tra le fatture passate in automatico, quante avevano un errore?** È questo il numero che dice quanto rischio stai accettando. Si misura facendo controllare a campione, ogni settimana, una piccola parte delle fatture registrate in automatico.

Il metodo completo — pesi, tolleranze, campioni, intervalli di confidenza — è descritto nel pezzo sull'[accuratezza dell'estrazione per campo]({{ '/it/blog/accuratezza-estrazione-documenti-campi/' | relative_url }}). Qui basta ricordare: **chiedi i numeri per campo, sui tuoi documenti, con l'IVA in cima alla lista**.

## Integrazione col gestionale: non un altro silos

Un errore frequente è comprare un software che legge le fatture benissimo ma vive per conto suo: un portale in più, dove le fatture vengono "lavorate" e poi esportate in un file che qualcuno importa a mano nel gestionale. Hai aggiunto un passaggio, non ne hai tolto uno.

Prima di scegliere, verifica:

- **da dove prende le fatture**: deve collegarsi al tuo canale di ricezione (cassetto fiscale, intermediario, PEC), non chiederti di caricarle a mano;
- **dove le registra**: deve scrivere nel tuo gestionale (o nel software del commercialista), con il piano dei conti e i codici IVA che usate già;
- **cosa usa come anagrafica**: deve usare l'anagrafica fornitori del gestionale, non crearne una sua che poi diverge;
- **come gestisce le correzioni**: se l'amministrativo corregge una registrazione nel gestionale, il sistema deve "imparare" la regola per quel fornitore, o almeno non ripetere l'errore;
- **chi vede cosa**: le fatture contengono dati di fornitori e clienti; il sistema deve trattarli con un contratto adeguato e preferibilmente in UE.

Se le fatture arrivano via PEC, un agente che legge la casella e smista i documenti può essere il primo pezzo del flusso: l'ho descritto nel pezzo sull'[agente che legge PEC e fatture]({{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}).

## Costi: ore dell'amministrativo vs licenza vs errori

Facciamo un conto realistico per una PMI che riceve **400 fatture passive al mese**, di cui 340 elettroniche italiane e 60 estere o senza XML. Le cifre sono **stime**.

| Voce | Senza automazione | Con automazione XML-first + AI sul resto |
|---|---|---|
| Tempo medio per fattura italiana | 3–4 minuti | 0,5 minuti (controllo a campione) + revisione per il 20–30% |
| Tempo medio per fattura estera / senza XML | 6–8 minuti | 3–4 minuti (revisione con dati pre-compilati) |
| Ore al mese | 25–30 ore | 8–12 ore |
| Costo del tempo (a 30 €/ora) | 750–900 €/mese | 240–360 €/mese |
| Licenza / servizio | — | 100–400 €/mese (secondo volumi e fornitore) |
| Setup e integrazione col gestionale | — | 2.000–8.000 € una tantum |
| Errori IVA da sistemare | dipende dalla persona | pochi, se le regole sono giuste; molti, se il sistema legge PDF e non ha revisione |

Il risparmio netto, in questo scenario, è nell'ordine di qualche centinaio di euro al mese più il tempo liberato per lavori a maggior valore. Non è una rivoluzione, è un buon investimento. Ma il risparmio sparisce, e si trasforma in costo, se il sistema introduce errori IVA che il commercialista deve scovare e correggere a fine trimestre: un'ora del commercialista costa più di un'ora dell'amministrativo, e un errore nella liquidazione costa più di entrambe.

## Un caso concreto: una settimana di fatture passive

Per vedere come funziona davvero, seguiamo una settimana tipo in una PMI commerciale che riceve circa 100 fatture passive a settimana (i numeri sono un esempio realistico, non un caso specifico).

**Lunedì mattina.** Il sistema ha scaricato durante il fine settimana 22 fatture elettroniche dal canale di ricezione e 3 PDF arrivati via email da fornitori esteri. Delle 22 elettroniche, 17 passano in automatico: fornitori noti, IBAN invariati, totali che quadrano, nessuna natura particolare o regole già verificate. Vengono proposte come registrate nel gestionale. Le altre 5 vanno in revisione: un fornitore nuovo, una fattura con reverse charge di un subappaltatore mai visto prima, una con il bollo, una con 2 centesimi di differenza tra righe e riepilogo, e una con un IBAN diverso da quello registrato.

**Lunedì, revisione (20 minuti).** L'amministrativa apre la coda. Il fornitore nuovo: verifica la partita IVA, crea l'anagrafica, conferma. Il reverse charge: controlla la natura, conferma la registrazione con integrazione dell'IVA, e attiva la regola per quel fornitore così la prossima volta passa da sola. Il bollo: confermato, registrato a parte. I 2 centesimi: accetta il riepilogo IVA dell'XML come valore corretto. L'IBAN cambiato: **non conferma**. Telefona al fornitore al numero già in anagrafica (non a quello scritto in fattura): il fornitore non ha cambiato banca. Era un tentativo di truffa. La fattura viene bloccata e segnalata.

**I tre PDF esteri (15 minuti).** Il sistema ha letto con l'AI fornitore, importi e date, e ha proposto la registrazione come acquisto intracomunitario. L'amministrativa controlla che la lettura sia giusta (su uno corregge una data letta in formato americano) e conferma. I documenti integrativi da trasmettere sono preparati secondo le regole concordate con il commercialista.

**Venerdì, controllo a campione (10 minuti).** Su 80 fatture passate in automatico nella settimana, ne vengono estratte 4 a caso e controllate a mano contro l'XML: tutte corrette.

**Il bilancio della settimana.** Circa un'ora e mezza di lavoro sulle fatture, contro le 6–7 ore di prima. E un bonifico truffaldino evitato, che da solo vale più di un anno di licenza. È il motivo per cui la revisione sugli IBAN cambiati non si toglie mai.

## Cosa si rompe dopo qualche mese

Anche un sistema ben impostato peggiora se nessuno lo guarda. I segnali tipici:

- **La coda di revisione cresce senza che crescano le fatture.** Un fornitore importante ha cambiato software di fatturazione e ora manda fatture con una struttura diversa, o con nature che il sistema non conosceva. Si guarda il motivo di revisione più frequente e si aggiunge la regola.
- **Le regole per fornitore si accumulano.** Dopo un anno ci sono decine di eccezioni "per quel fornitore", alcune non più valide. Una revisione semestrale con il commercialista evita che regole vecchie registrino male fatture nuove.
- **Il controllo a campione smette di essere fatto.** Dopo mesi senza errori, sembra inutile. È esattamente il momento in cui un cambiamento silenzioso (un aggiornamento del sistema, un nuovo fornitore grande) può introdurre errori che nessuno vede.
- **L'anagrafica si sporca di nuovo.** Fornitori creati in fretta, duplicati, IBAN non aggiornati. Il sistema associa per partita IVA, ma se in anagrafica ci sono due schede con la stessa partita IVA, l'errore torna.
- **Cambiano le regole fiscali.** Nuovi codici, nuove nature, nuove soglie. Il fornitore del software dovrebbe aggiornarsi, ma conviene chiedere esplicitamente come e quando, e verificarlo alla prima liquidazione dopo il cambiamento.

## Quando NON automatizzare (volume basso, caos totale)

- **Volume basso.** Sotto le 50–80 fatture al mese, il costo del setup e della licenza difficilmente si ripaga. Meglio usare bene le funzioni di importazione XML che quasi tutti i gestionali hanno già.
- **Caos in anagrafica.** Se l'anagrafica fornitori ha duplicati, partite IVA mancanti e IBAN vecchi, qualsiasi automazione amplificherà il disordine. Prima si pulisce l'anagrafica, poi si automatizza.
- **Nessuno che fa la revisione.** Un sistema che mette in revisione il 25% delle fatture è utile solo se qualcuno svuota la coda. Altrimenti hai solo spostato il problema.
- **Prevalenza di documenti esteri o scansionati.** Se la maggior parte dei tuoi documenti non ha XML, l'automazione è più difficile, la revisione più pesante e il risparmio più basso. Si può fare, ma con aspettative diverse.
- **Contabilità esternalizzata senza accordo.** Se le registrazioni le fa lo studio del commercialista, il progetto va fatto con lo studio, non contro. Altrimenti crei due versioni della verità.

## 3 errori da principiante che costano soldi

**1. Comprare il "99%" senza chiedere su quali campi.** È l'errore da cui nascono tutti gli altri. Chiedi sempre i numeri per campo, sui tuoi documenti, separando fatture italiane ed estere, e chiedi quante fatture passate in automatico avevano un errore.

**2. Leggere i PDF quando c'è l'XML.** Molti sistemi lo fanno perché è il modo più semplice di "far vedere l'AI". Ma introduce errori che nell'XML non esistono, soprattutto su split payment, reverse charge e bollo. XML prima, AI solo dove l'XML non c'è.

**3. Togliere la revisione per "risparmiare tempo".** Dopo qualche mese senza problemi visibili, la tentazione è far passare tutto in automatico. È il momento in cui arriva la prima fattura con l'IBAN cambiato da un truffatore, o la prima fattura estera con un'IVA trattata male. La revisione sui casi a rischio non è un costo: è il motivo per cui l'automazione è sicura.

## Percorso 30/60/90 giorni

**Primi 30 giorni — misurare la situazione**

- contare le fatture passive per tipo (italiane XML, estere, scansionate) e il tempo speso oggi;
- pulire l'anagrafica fornitori: duplicati, partite IVA, IBAN;
- verificare cosa fa già il gestionale con l'importazione XML (spesso più di quanto si pensi);
- chiedere ai fornitori di software una prova sui **tuoi** documenti, con risultati per campo.

**Da 30 a 60 giorni — partire dall'XML**

- attivare il flusso XML-first per le fatture italiane, con le regole per split payment, reverse charge e bollo concordate con il commercialista;
- definire soglie e motivi di revisione;
- avviare il controllo a campione settimanale.

**Da 60 a 90 giorni — aggiungere il resto**

- aggiungere la lettura con AI per i documenti senza XML, sempre in revisione;
- misurare: ore risparmiate, fatture in revisione, errori trovati nei controlli a campione;
- rivedere le regole con il commercialista dopo la prima liquidazione IVA.

## Checklist pratica

- [ ] So quante fatture ricevo al mese, per tipo, e quanto tempo costano oggi.
- [ ] L'anagrafica fornitori è pulita: niente duplicati, partite IVA verificate, IBAN aggiornati.
- [ ] Il sistema legge l'XML per le fatture elettroniche italiane, non il PDF.
- [ ] Ci sono regole verificate per split payment, reverse charge, bollo ed esenzioni.
- [ ] L'associazione al fornitore avviene per partita IVA.
- [ ] Fatture estere, fornitori nuovi, IBAN cambiati e importi sopra soglia vanno sempre in revisione.
- [ ] Le differenze nei totali vengono segnalate, non corrette in automatico.
- [ ] L'accuratezza è misurata per campo, sui miei documenti, con l'IVA in cima.
- [ ] C'è un controllo a campione settimanale sulle fatture registrate in automatico.
- [ ] Il sistema scrive nel gestionale, non in un portale separato.
- [ ] Il commercialista conosce e ha validato le regole.

## Il verdetto

L'**AI che legge le fatture sbaglia l'IVA** soprattutto quando le si chiede di fare un lavoro che non dovrebbe fare: leggere un PDF quando c'è l'XML, decidere da sola su split payment e reverse charge, riconoscere un fornitore dal nome. Il "99% di accuratezza" è quasi sempre una media che mette insieme il CAP e l'imposta, le fatture facili e quelle difficili.

L'automazione delle fatture passive funziona, e fa risparmiare davvero, quando segue un ordine preciso: prima l'XML della fattura elettronica, con regole fiscali concordate con il commercialista; poi l'AI per i documenti che l'XML non ce l'hanno; sempre una persona sui casi a rischio; sempre un controllo a campione su ciò che passa in automatico. Meno spettacolare di una demo, molto più tranquillo a fine trimestre.

Se stai valutando come automatizzare la registrazione delle fatture senza sorprese nella liquidazione IVA, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su documenti, fatture e AI sono nella guida su [documenti, fatture e AI]({{ '/it/pillar/documenti-fatture-ai/' | relative_url }}).

## FAQ

### L'intelligenza artificiale può registrare le fatture passive da sola?

Può farlo per una parte delle fatture, a condizioni precise: fattura elettronica letta dall'XML, fornitore già in anagrafica e associato per partita IVA, IBAN invariato, totali che quadrano, nessuna natura fiscale particolare senza regola verificata e importo sotto soglia. Fatture estere, fornitori nuovi, IBAN cambiati e casi particolari devono passare da una persona.

### Perché è meglio leggere l'XML della fattura invece del PDF?

Perché nell'XML i dati sono già strutturati e trasmessi dal fornitore tramite lo SDI: imponibile, aliquote, natura delle operazioni, esigibilità dell'IVA, bollo, scadenze. Leggere il PDF con l'AI significa ricostruire con un margine di errore dati che esistono già in forma esatta. Il PDF serve solo per i documenti che non hanno un XML.

### Quali sono gli errori più comuni dell'AI sulle fatture?

I più frequenti riguardano lo split payment trattato come IVA ordinaria, il reverse charge senza integrazione dell'IVA, il bollo sommato all'imponibile, gli arrotondamenti corretti a caso, i fornitori con nomi simili confusi tra loro, le fatture estere con l'IVA gestita male e l'allegato PDF letto al posto dell'XML.

### Cosa significa davvero "99% di accuratezza" per un software che legge fatture?

Spesso è una media su tutti i campi o sui caratteri letti, in cui l'indirizzo pesa quanto l'IVA. Un'accuratezza utile si misura per campo, con tolleranza zero sugli importi, separando fatture italiane ed estere, su un campione di documenti reali dell'azienda, e indicando quante fatture passate in automatico contenevano un errore.

### Come si gestiscono le fatture estere con l'AI?

L'AI è utile per leggere i dati dal PDF, visto che non c'è un XML italiano, ma queste fatture devono andare sempre in revisione. Vanno applicate le regole per gli acquisti intracomunitari ed extra-UE, compresa l'integrazione dell'IVA e i documenti integrativi trasmessi allo SDI dove previsti, concordate con il commercialista.

### Quante fatture possono passare in automatico senza controllo?

Nelle aziende in cui questi sistemi funzionano bene, tipicamente tra il 60% e l'80% delle fatture passive, quelle elettroniche italiane senza particolarità da fornitori noti. Il resto va in revisione. Anche sulle fatture automatiche conviene un controllo a campione settimanale per misurare l'errore residuo.

### Quanto si risparmia automatizzando la registrazione delle fatture?

Per una PMI con circa 400 fatture passive al mese, il tempo può scendere da 25–30 ore a 8–12 ore al mese, con un risparmio netto di qualche centinaio di euro al mese dopo la licenza, più un costo iniziale di integrazione. Il risparmio sparisce se il sistema introduce errori IVA che il commercialista deve correggere.

### Sotto quale volume non conviene automatizzare?

Indicativamente sotto le 50–80 fatture passive al mese: il costo del setup e della licenza difficilmente si ripaga. In questi casi conviene sfruttare bene l'importazione XML che la maggior parte dei gestionali offre già.

### L'IBAN cambiato su una fattura è un problema?

Sì, va sempre controllato da una persona. Un IBAN diverso da quello registrato per il fornitore può essere un cambio legittimo, ma è anche il segnale tipico delle truffe sui pagamenti. La verifica va fatta contattando il fornitore attraverso un canale già noto, non quello indicato nella fattura.

### Il commercialista deve essere coinvolto?

Sì. Le regole su split payment, reverse charge, esenzioni, bollo e fatture estere vanno concordate con chi tiene la contabilità o la controlla. Un'automazione che registra in un modo diverso da quello atteso dal commercialista crea lavoro in più a fine periodo invece di toglierlo.
