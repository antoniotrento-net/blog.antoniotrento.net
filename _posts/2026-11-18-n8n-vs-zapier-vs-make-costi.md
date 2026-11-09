---
lang: it
permalink: /it/blog/n8n-vs-zapier-vs-make-costi/
alt_url: /en/blog/n8n-vs-zapier-vs-make-cost/
title: "Zapier o Make a 400€ al mese: quando n8n self-hosted conviene (e quando stai solo spostando il problema sull'IT)"
date: 2026-11-18 07:30:00 +0200
author: "Antonio Trento"
description: "Confronto onesto per PMI tra Zapier, Make e n8n self-hosted: cosa paghi davvero, lock-in, privacy, chi mantiene i flussi se non hai un IT, TCO a 12 mesi su tre scenari, dieci automazioni tipiche, come migrare senza rompere niente e quando restare su Make o Zapier senza vergogna."
keywords: ["n8n vs zapier vs make costi", "n8n self hosted pmi", "alternativa zapier italia", "automazione no-code costi", "make.com prezzo", "tco automazione"]
image: /assets/images/posts/n8n-vs-zapier-vs-make-costi.jpg
pillar: automazione-da-dove
related: [/it/blog/limiti-no-code-azienda/, /it/blog/n8n-self-hosted-openai-privacy/]
---

## La bolletta no-code che cresce con i task

All'inizio erano venti euro al mese. Un'automazione per copiare i contatti dal modulo del sito al CRM, una per mandare una mail di benvenuto, una per avvisare in chat quando arriva un ordine. Poi le automazioni sono diventate trenta, qualcuna gira ogni cinque minuti, una sincronizza il magazzino con l'e-commerce, un'altra genera i documenti di trasporto. Un giorno arriva la mail: "Hai superato il limite del tuo piano". Si passa al piano superiore. Sei mesi dopo, la voce "automazioni" in contabilità vale 400 euro al mese, a volte di più nei mesi di picco, e nessuno sa esattamente quali flussi la fanno crescere.

È a quel punto che qualcuno cerca "n8n" su Google, legge che è gratuito se lo installi sul tuo server, e propone di migrare tutto. A volte è un'ottima idea. A volte è il modo di risparmiare 400 euro al mese spendendone 600 in tempo dell'IT, con l'aggiunta di un server da tenere acceso e aggiornato.

Questo pezzo è un confronto onesto, **n8n vs Zapier vs Make sui costi** e su tutto il resto che conta per una PMI: cosa stai comprando davvero, dove finiscono i dati, chi tiene in vita i flussi se non hai un reparto IT, il costo totale a dodici mesi su tre scenari realistici, come si migra senza rompere niente, e quando la scelta giusta è restare dove sei.

## È per te / non è per te

È per te se:

- paghi un abbonamento a Zapier o Make e la cifra cresce ogni trimestre;
- hai almeno una decina di automazioni che, se si fermano, qualcuno se ne accorge;
- ti stai chiedendo se "portare tutto in casa" conviene davvero, e vuoi numeri, non opinioni.

**Non è per te se**:

- hai cinque automazioni e spendi meno di 50 euro al mese: il tempo che passeresti a migrare vale più del risparmio;
- nessuno in azienda (né un fornitore di fiducia) ha mai gestito un server e non hai intenzione di pagare qualcuno che lo faccia;
- le tue automazioni toccano solo strumenti SaaS americani (CRM, mail marketing, fogli di calcolo in cloud) e non tratti dati delicati: il vantaggio sulla privacy di un'installazione in casa è piccolo, perché i dati sono già fuori.

## Cosa stai comprando: connettori, run, persone

Quando paghi uno strumento di automazione, compri tre cose diverse, e conviene separarle per capire il conto.

**1. I connettori.** La possibilità di collegare un'applicazione a un'altra senza scrivere codice: "quando arriva una mail con allegato, salva il file in una cartella e crea un record nel CRM". Zapier ha migliaia di connettori pronti, Make centinaia di app ben fatte, n8n alcune centinaia di nodi più un nodo generico per chiamare qualsiasi servizio che abbia un'API. Per gli strumenti più diffusi tutti e tre coprono quasi tutto. Le differenze emergono sui software di nicchia e su quelli italiani (gestionali, fatturazione elettronica, PEC): spesso nessuno dei tre ha un connettore pronto, e si passa comunque da un'API.

**2. Le esecuzioni.** Qui sta la differenza di prezzo, e va capita bene perché i tre strumenti contano in modo diverso:

- **Zapier** conta i **task**: ogni azione eseguita con successo in un flusso. Un'automazione con un trigger e cinque azioni, che gira cento volte al giorno, consuma circa 500 task al giorno, 15.000 al mese.
- **Make** conta le **operazioni** (o crediti, a seconda del piano): ogni modulo eseguito, trigger incluso, consuma operazioni. Il prezzo per operazione è generalmente più basso dei task di Zapier, ma i flussi complessi ne consumano tante.
- **n8n** in cloud conta le **esecuzioni** dell'intero workflow, indipendentemente dal numero di passi; in versione self-hosted, l'edizione community **non ha limiti di esecuzione**: paghi il server, non il volume.

Questa differenza spiega quasi tutto. I flussi con molti passi, che girano spesso (sincronizzazioni, polling, elaborazione riga per riga di un file), sono quelli che fanno esplodere la bolletta di Zapier e Make, e quelli su cui n8n self-hosted conviene di più.

**3. Le persone.** È la voce che non compare in nessun listino. Qualcuno costruisce i flussi, qualcuno li sistema quando un'applicazione cambia, qualcuno si accorge quando smettono di funzionare. Con Zapier e Make, una parte di questo lavoro (aggiornare i connettori, tenere in piedi l'infrastruttura) la fa il fornitore. Con n8n self-hosted, la fai tu, o paghi qualcuno che la faccia.

Il confronto serio non è tra l'abbonamento di Zapier e il costo del server di n8n. È tra **abbonamento + persone** da una parte e **server + persone (di più)** dall'altra.

## Zapier/Make: veloci, cari, dati fuori

Zapier e Make sono ottimi prodotti, e conviene dirlo prima di parlarne male.

**Cosa fanno bene:**

- si parte in un pomeriggio, senza installare niente;
- un responsabile commerciale o un'impiegata sveglia può costruire un flusso semplice da sola;
- connettori pronti e mantenuti dal fornitore: quando un'applicazione cambia le sue API, di solito ci pensano loro;
- nessun server da aggiornare, nessun backup da fare, nessun certificato da rinnovare.

**Dove fanno male:**

- **il prezzo cresce con l'uso**, e cresce in modo poco prevedibile. Un flusso scritto male (un polling troppo frequente, un ciclo su un file grande) può consumare in un giorno il budget di un mese;
- **i dati passano dai loro server.** Ogni mail, ordine, anagrafica che attraversa un flusso viene elaborata da un fornitore esterno, spesso con infrastruttura fuori dall'Unione europea. Per dati di clienti italiani serve un contratto di trattamento adeguato e una valutazione dei trasferimenti; per dati sensibili, spesso, non è la strada giusta;
- **lock-in.** I flussi costruiti in Zapier non si esportano in Make o in n8n: si ricostruiscono. Più flussi hai, più costa andarsene, e questo il fornitore lo sa;
- **debug limitato** sui flussi complessi: quando qualcosa va storto a metà di una catena lunga, capire perché è spesso più difficile che in uno strumento che controlli.

Tra i due, in genere **Make costa meno di Zapier** a parità di volume e gestisce meglio i flussi complessi (rami, cicli, trasformazioni di dati), con una curva di apprendimento un po' più ripida. Zapier è più immediato e ha più connettori. Per molte PMI, passare da Zapier a Make è già un risparmio significativo, senza toccare server.

## n8n self-hosted: controllo, manutenzione, curva

n8n è uno strumento di automazione con un'interfaccia visuale simile a Make, che puoi usare in cloud (gestito dall'azienda tedesca che lo sviluppa) o installare sul tuo server. La versione da installare in casa è distribuita con una licenza "fair-code": puoi usarla gratuitamente per automatizzare i processi della tua azienda, con alcune limitazioni se vuoi rivenderla come servizio ad altri. Alcune funzioni avanzate (gestione di più ambienti, integrazione con sistemi di gestione dei segreti, controllo accessi più fine) sono nelle edizioni a pagamento.

**Cosa ti dà:**

- **costo che non cresce con l'uso**: mille o centomila esecuzioni al mese costano uguale, finché il server regge;
- **dati in casa**: i flussi girano sul tuo server, in azienda o in un datacenter europeo che scegli tu; i dati non passano da terzi, se non verso i servizi che i flussi chiamano esplicitamente;
- **flessibilità**: quando un connettore non c'è, un nodo generico chiama qualsiasi API, e quando serve un pezzo di logica si scrive due righe di codice dentro il flusso;
- **nessun lock-in sul fornitore**: i flussi sono file che esporti, versioni, sposti.

**Cosa ti costa:**

- **un server da gestire**: aggiornamenti, backup, certificati, monitoraggio. Non è difficile, ma va fatto, e va fatto con continuità;
- **una curva di apprendimento** più ripida di Zapier: n8n ragiona su elenchi di dati e espressioni, e chi viene da Zapier ci mette qualche settimana a sentirsi a suo agio;
- **la responsabilità dei guasti**: quando n8n si ferma alle tre di notte, non c'è un'azienda a cui aprire un ticket (a meno che tu non abbia un contratto con qualcuno).

Su un punto in particolare voglio essere chiaro, perché è dove ho visto più danni: la **chiave di cifratura delle credenziali** e i **backup**. Un'installazione di n8n fatta in fretta, senza backup provati e senza la chiave salvata altrove, può perdere tutte le credenziali in un riavvio sbagliato. Non è un rischio teorico, e il pezzo su [credenziali n8n e vault]({{ '/it/blog/n8n-credentials-vault-infisical/' | relative_url }}) racconta esattamente come succede e come evitarlo.

C'è anche un vantaggio di n8n self-hosted che i numeri non mostrano bene: quando i flussi chiamano modelli di intelligenza artificiale, puoi decidere tu dove vanno i dati, anche usando modelli installati in casa. Con gli strumenti in cloud, la mail del cliente passa dal fornitore di automazione *e* dal fornitore del modello. Il caso tipico è descritto nel pezzo su [n8n self-hosted e la privacy dei dati verso OpenAI]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}).

## Chi lo tiene in vita se non hai un IT

È la domanda decisiva, e quella che si fa per ultima. Un'installazione di n8n self-hosted ha bisogno di qualcuno che:

- applichi gli aggiornamenti (n8n ne rilascia spesso, alcuni importanti per la sicurezza);
- controlli che i backup funzionino davvero, provando ogni tanto a ripristinarli;
- si accorga quando un flusso fallisce (con un sistema di allarmi, non guardando a mano);
- sistemi i flussi quando un'applicazione collegata cambia;
- gestisca le credenziali quando una persona lascia l'azienda o un token scade.

In ore, per un'installazione di media complessità, sono **da mezza giornata a una giornata e mezza al mese**, più le emergenze. Le opzioni realistiche per una PMI senza IT interno:

1. **Un partner esterno con un contratto di manutenzione**: un professionista o una piccola società che installa, monitora, aggiorna e interviene. È la strada più comune, e va valutata come un costo fisso mensile.
2. **n8n in cloud** invece che self-hosted: perdi il vantaggio del costo fisso e parte del controllo sui dati, ma il server lo gestisce il fornitore. Il prezzo è legato alle esecuzioni, non ai singoli passi, quindi resta spesso più conveniente di Zapier.
3. **Una persona interna formata**, non necessariamente un informatico: qualcuno di sveglio in amministrazione o nel commerciale, che costruisce i flussi, con un partner esterno per server e aggiornamenti. È la combinazione che funziona meglio nelle aziende in cui le automazioni crescono.

L'opzione che **non** funziona è "lo installa il nipote del titolare un sabato". Funziona per tre mesi, poi il nipote ha altro da fare, e i flussi dell'azienda girano su un server che nessuno sa più gestire.

## Tabella TCO 12 mesi su 3 scenari (piccola, media, picchi)

Ecco il costo totale a dodici mesi in tre scenari realistici. Le cifre sono **stime**, con ipotesi dichiarate: verifica i listini attuali dei fornitori (cambiano spesso) e adatta il costo orario al tuo caso.

**Ipotesi comuni:**

- costo di una giornata di lavoro tecnico (interno o esterno): 400 €;
- n8n self-hosted su un server virtuale in un datacenter europeo;
- la migrazione è il lavoro per ricostruire i flussi esistenti in n8n;
- la manutenzione include aggiornamenti, backup, controllo dei fallimenti, piccole correzioni.

**Scenario A — Piccola:** 10 automazioni semplici, circa 5.000 task al mese.

**Scenario B — Media:** 30 automazioni, alcune con molti passi, circa 50.000 task al mese.

**Scenario C — Picchi:** 40 automazioni, stagionalità forte (e-commerce, turismo), da 50.000 a 200.000 task al mese nei mesi di punta.

| Voce (12 mesi, stime) | A — Zapier | A — Make | A — n8n self-hosted | B — Zapier | B — Make | B — n8n self-hosted | C — Zapier | C — Make | C — n8n self-hosted |
|---|---|---|---|---|---|---|---|---|---|
| Abbonamento / server | 600 € | 250 € | 120 € | 5.400 € | 1.800 € | 300 € | 10.800 € | 3.600 € | 480 € |
| Setup iniziale | — | — | 400 € | — | — | 1.600 € | — | — | 1.600 € |
| Migrazione dei flussi | — | — | 800 € | — | — | 2.000 € | — | — | 3.200 € |
| Manutenzione | 200 € | 200 € | 1.200 € | 800 € | 800 € | 2.400 € | 1.200 € | 1.200 € | 3.600 € |
| **Totale anno 1** | **800 €** | **450 €** | **2.520 €** | **6.200 €** | **2.600 €** | **6.300 €** | **12.000 €** | **4.800 €** | **8.880 €** |
| **Totale anno 2** | **800 €** | **450 €** | **1.320 €** | **6.200 €** | **2.600 €** | **2.700 €** | **12.000 €** | **4.800 €** | **4.080 €** |

Cosa dice la tabella, senza girarci intorno:

- **Nello scenario piccolo, n8n self-hosted non conviene.** Costa di più il primo anno e anche il secondo. Resta su Make (o su Zapier, se ti trovi bene) e ripensaci quando i volumi crescono.
- **Nello scenario medio, il confronto vero è con Make, non con Zapier.** Passare da Zapier a Make dimezza la spesa senza toccare server. n8n self-hosted pareggia Make dal secondo anno: conviene se a parità di costo ti interessano controllo dei dati e assenza di lock-in, non per risparmiare.
- **Nello scenario con picchi, n8n self-hosted vince dal secondo anno anche su Make**, e soprattutto elimina l'imprevedibilità: il mese di punta costa come gli altri.

Due fattori che la tabella non mostra e che spostano la decisione:

- **i dati**: se i flussi trattano dati di clienti, dipendenti o pazienti, il valore di tenerli in casa può superare qualsiasi differenza di costo;
- **la crescita**: se le automazioni stanno raddoppiando ogni anno, lo scenario di oggi non è quello dell'anno prossimo. Su un orizzonte di tre anni, il costo fisso di n8n diventa più interessante.

## Le 10 automazioni tipiche di una PMI

Per dare concretezza al confronto, ecco dieci automazioni che trovo in quasi tutte le PMI, con lo strumento che sceglierei pensando a costo e dati.

1. **Contatti dal sito al CRM**, con mail di conferma. Pochi passi, volume basso: va bene ovunque.
2. **Notifica in chat interna per ordini o richieste nuove.** Banale, volume medio: va bene ovunque.
3. **Fatture passive dalla PEC alla cartella giusta e al gestionale.** Dati sensibili, connessione a caselle PEC e gestionali italiani: n8n self-hosted.
4. **Sincronizzazione magazzino tra gestionale ed e-commerce.** Molti passi, frequente, picchi: n8n self-hosted (o Make con attenzione ai consumi).
5. **Promemoria scadenze e rinnovi ai clienti.** Volume basso, dati dei clienti: indifferente sul costo, meglio in casa se i dati sono delicati.
6. **Report settimanale automatico** da gestionale e CRM via mail. Pochi passi, volume basso: va bene ovunque.
7. **Classificazione delle mail in arrivo** con un modello di intelligenza artificiale e smistamento agli uffici. Dati dei clienti e chiamate al modello: n8n self-hosted, possibilmente con modello in casa o in UE.
8. **Onboarding di un nuovo dipendente** (account, cartelle, avvisi). Volume bassissimo: va bene ovunque, ma attenzione ai dati personali.
9. **Raccolta di recensioni o feedback dopo un acquisto.** Volume medio, dati poco sensibili: Make o Zapier vanno benissimo.
10. **Generazione di documenti** (offerte, DDT, contratti) da modelli e dati del CRM. Molti passi, dati commerciali: n8n self-hosted o Make.

Come si vede, non c'è uno strumento che vince ovunque. Nelle aziende dove le automazioni sono tante, spesso la configurazione migliore è **mista**: i flussi semplici e poco sensibili restano su uno strumento in cloud, quelli con dati delicati o volumi alti vanno su n8n in casa.

## Migrazione: da dove si parte senza spezzare i flow

Se decidi di migrare, la regola è una: **mai tutto insieme**. Un flusso alla volta, con quello vecchio acceso finché il nuovo non ha dimostrato di funzionare. Ecco la procedura che seguo.

1. **Inventario.** Elenca tutti i flussi attivi: cosa fanno, quanto spesso girano, quanti task consumano al mese, chi se ne accorge se si fermano, che dati trattano. Spesso escono flussi dimenticati che nessuno usa più: spegnerli è il primo risparmio.
2. **Classificazione.** Per ogni flusso: resta dov'è, va su n8n, va spento. Criteri: consumo di task, sensibilità dei dati, complessità.
3. **Installazione di n8n fatta bene**: server in UE, backup automatici con un ripristino provato, chiave di cifratura salvata fuori dal server, accesso protetto, allarmi sui fallimenti. Questo passo non si salta per andare più veloci.
4. **Primo flusso di prova**: scegli uno a basso rischio ma reale (per esempio la notifica degli ordini in chat). Ricostruiscilo in n8n.
5. **Esecuzione in parallelo** per una o due settimane: i due flussi girano insieme, il nuovo in modalità "solo controllo" (scrive in un posto di prova, o manda la notifica a una sola persona). Confronti i risultati.
6. **Passaggio**: quando il nuovo flusso ha funzionato senza differenze, spegni quello vecchio (ma non cancellarlo per un mese).
7. **Ripeti** partendo dai flussi che consumano più task: sono quelli che ripagano prima la migrazione.
8. **Disdici o riduci il piano** del vecchio strumento solo quando i flussi principali sono migrati e stabili.

Un pseudo-flusso dell'inventario, per capire che informazioni raccogliere:

```text
Flusso: "Ordini e-commerce → gestionale"
  Strumento attuale: Zapier
  Frequenza: ogni nuovo ordine (~80/giorno, picchi 400/giorno a dicembre)
  Passi: 7 (trigger + 6 azioni)  → task/mese: ~16.800, a dicembre ~84.000
  Dati: nome, indirizzo, telefono del cliente, importo, prodotti
  Chi se ne accorge se si ferma: magazzino, entro 2 ore
  Decisione: migrare su n8n (volume alto, dati clienti, picchi)
  Priorità: 1
```

Cosa significa, riga per riga: quante volte gira il flusso ti dice quanto costa; i passi moltiplicati per la frequenza danno i task del mese; i dati ti dicono quanto è delicato; "chi se ne accorge" ti dice quanto rapidamente devi poter intervenire se si rompe; la decisione e la priorità derivano da tutto il resto. Con questa scheda per ogni flusso, la migrazione diventa un elenco di lavori, non un salto nel buio.

## Cosa si rompe in produzione (con qualsiasi strumento)

Una cosa che chi vende automazioni dice poco: i flussi si rompono, qualunque sia lo strumento. Cambia solo chi se ne accorge e quanto ci mette. I guasti tipici sono sempre gli stessi, e conviene conoscerli prima di scegliere.

- **Credenziali scadute.** Un'applicazione collegata fa scadere il token di accesso dopo 60 o 90 giorni, oppure la persona che aveva collegato il proprio account lascia l'azienda. Il flusso si ferma con un errore di autorizzazione. In Zapier e Make arriva una mail di avviso (che spesso finisce nella casella di chi non c'è più); in n8n serve un allarme configurato da te. Rimedio comune: collegare le applicazioni con account di servizio aziendali, non personali.
- **L'applicazione cambia.** Il CRM rinomina un campo, il gestionale aggiorna le sue API, l'e-commerce cambia il formato degli ordini. Il flusso continua a girare ma scrive dati sbagliati o vuoti. È il guasto più subdolo, perché non dà errori: lo scopri quando qualcuno nota che i nuovi contatti arrivano senza telefono da tre settimane.
- **Limiti delle applicazioni collegate.** Molti servizi limitano il numero di richieste al minuto. Un flusso che elabora un file grande o un picco di ordini supera il limite, e le richieste in eccesso falliscono. Gli strumenti in cloud gestiscono parte di questi casi da soli; in n8n vanno previsti nel flusso (pause, elaborazione a blocchi).
- **Esecuzioni doppie.** Dopo un errore, un flusso viene rieseguito e crea due volte lo stesso record, o manda due volte la stessa mail al cliente. Succede con tutti gli strumenti, ed è il motivo per cui i flussi che scrivono dati importanti devono controllare prima se il dato esiste già.
- **Fallimenti silenziosi.** Il flusso non parte proprio, perché il trigger non scatta: il modulo del sito è cambiato, la casella non riceve più, il server era spento. Nessun errore, nessun avviso. L'unico rimedio è un controllo "al contrario": un allarme se un flusso che dovrebbe girare ogni giorno non ha girato.

La differenza tra gli strumenti, su questo fronte, è nel monitoraggio di base: Zapier e Make ti danno una cronologia delle esecuzioni e qualche avviso senza fare niente, n8n self-hosted ti dà strumenti più potenti ma devi configurarli tu. In tutti e tre i casi, una persona che una volta alla settimana guarda i flussi falliti e i flussi che non hanno girato vale più di qualsiasi funzione automatica.

## 3 errori da principiante che costano soldi o dati

**1. Migrare tutto in un weekend.** La tentazione è "tanto sono gli stessi flussi". Non lo sono: ogni strumento gestisce in modo diverso gli errori, i ritardi, i dati vuoti. Un flusso che in Zapier ignorava silenziosamente un campo mancante in n8n si ferma, o viceversa. Migrando tutto insieme, il lunedì mattina hai dieci flussi rotti e non sai da dove partire.

**2. Installare n8n senza backup e senza allarmi.** Il server funziona, i flussi girano, e nessuno controlla. Il giorno in cui il disco si riempie o un aggiornamento va storto, scopri che non c'era un backup recente, o che c'era ma nessuno aveva mai provato a ripristinarlo. Peggio: per settimane un flusso è fallito in silenzio, e i dati non sono arrivati dove dovevano. Il metodo per evitarlo è nel pezzo sul [backup e restore di Postgres e n8n]({{ '/it/blog/backup-docker-postgres-n8n/' | relative_url }}).

**3. Confrontare solo il prezzo dell'abbonamento.** "Zapier costa 400 euro, il server di n8n 20: risparmiamo 380 euro al mese." Manca il tempo delle persone, che è quasi sempre la voce più alta. Fare il conto senza manutenzione è il modo più rapido per ritrovarsi con un sistema più economico sulla carta e più caro nella realtà.

## Quando restare su Make/Zapier senza vergogna

C'è una certa retorica tecnica secondo cui "il vero professionista fa tutto self-hosted". Non è vero. Ci sono situazioni in cui restare su Make o Zapier è la scelta migliore, e va detto con chiarezza:

- **Volumi bassi e stabili.** Sotto i 100–150 euro al mese, il risparmio non giustifica un server da gestire.
- **Nessuno che mantenga.** Se non hai una persona interna né un partner con un contratto, un'installazione self-hosted diventa un rischio, non un risparmio.
- **Flussi tra soli SaaS in cloud.** Se colleghi il CRM in cloud al mail marketing in cloud e al foglio di calcolo in cloud, i dati sono già fuori: portare in casa il pezzo in mezzo cambia poco sulla privacy.
- **Prototipi e prove.** Per verificare se un'automazione serve davvero, costruirla in un'ora su Zapier è perfetto. Se dimostra il suo valore e cresce, la migri.
- **Persone non tecniche che costruiscono da sole.** Se il valore sta nel fatto che il responsabile commerciale si costruisce i flussi in autonomia, la semplicità di Zapier vale il prezzo.

E un'opzione intermedia che molti non considerano: **passare da Zapier a Make** riduce spesso la spesa di metà o più senza nessun server, ed è un buon primo passo prima di decidere se andare oltre. Per un quadro più ampio su quando gli strumenti no-code iniziano a stare stretti, c'è il pezzo sui [limiti del no-code in azienda]({{ '/it/blog/limiti-no-code-azienda/' | relative_url }}).

## Percorso 30/60/90 giorni

**Primi 30 giorni — capire e risparmiare senza migrare**

- inventario completo dei flussi con task consumati, dati trattati, criticità;
- spegnimento dei flussi inutili e ottimizzazione di quelli che consumano troppo (polling meno frequente, filtri all'inizio del flusso);
- decisione: resto, passo a Make, vado (in parte) su n8n.

**Da 30 a 60 giorni — preparare**

- se si va su n8n: scelta di chi lo mantiene (interno + partner, partner, cloud), installazione fatta bene, backup e allarmi;
- migrazione dei primi due o tre flussi a basso rischio, con esecuzione in parallelo;
- formazione della persona interna che costruirà i flussi.

**Da 60 a 90 giorni — migrare il grosso**

- migrazione dei flussi che consumano più task e di quelli con dati sensibili;
- riduzione del piano dello strumento in cloud;
- primo controllo dei costi reali (server, ore di manutenzione) rispetto alle stime.

## Quando NON farlo

Riassumendo i casi in cui la migrazione a n8n self-hosted è una cattiva idea:

- spendi meno di 100–150 euro al mese e i volumi sono stabili;
- non hai né una persona interna né un partner che si prenda la responsabilità del server;
- la motivazione è solo "così non paghiamo l'abbonamento", senza aver contato le ore;
- i flussi collegano solo servizi in cloud e non trattano dati delicati;
- sei nel mezzo di un periodo di picco o di un cambio di gestionale: migra quando le acque sono calme.

## Checklist pratica

- [ ] Inventario dei flussi con task al mese, dati trattati, chi se ne accorge se si fermano.
- [ ] Flussi inutili spenti, flussi costosi ottimizzati.
- [ ] Conto a 12 e 24 mesi fatto con le ore di manutenzione, non solo con l'abbonamento.
- [ ] Decisione presa tra: restare, passare a Make, n8n in cloud, n8n self-hosted, configurazione mista.
- [ ] Se self-hosted: chi lo mantiene è scritto (persona o contratto), con tempi di intervento.
- [ ] Server in UE, backup automatici con ripristino provato, chiave di cifratura salvata altrove, allarmi sui fallimenti.
- [ ] Migrazione un flusso alla volta, con esecuzione in parallelo prima del passaggio.
- [ ] Vecchio piano ridotto solo dopo che i flussi principali sono stabili.
- [ ] Controllo dei costi reali a 90 giorni.

## Il verdetto

Il confronto **n8n vs Zapier vs Make sui costi** non ha un vincitore assoluto, e diffida di chi te ne vende uno. Zapier è il più rapido e il più caro, Make è spesso il miglior compromesso per chi non vuole server, n8n self-hosted è imbattibile quando i volumi sono alti, i dati sono delicati e c'è qualcuno che lo tiene in vita. Sotto una certa soglia di spesa, portare tutto in casa significa solo spostare il costo dall'abbonamento al tempo dell'IT.

La domanda giusta non è "quale strumento costa meno", ma "quanto mi costa ogni flusso, che dati tratta, e chi se ne occupa quando si rompe". Con un inventario fatto bene e un conto che include le persone, la decisione si prende in un pomeriggio. E spesso la risposta è una combinazione: i flussi semplici dove sono, quelli pesanti o delicati in casa, migrati uno alla volta.

Se stai pagando una bolletta di automazioni che cresce e vuoi capire dove conviene davvero intervenire, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su come impostare le automazioni in una PMI sono nella guida su [automazione in PMI: da dove partire]({{ '/it/pillar/automazione-pmi/' | relative_url }}).

## FAQ

### n8n è davvero gratuito?

La versione community da installare sul proprio server è gratuita per automatizzare i processi della propria azienda, senza limiti di esecuzioni. È distribuita con una licenza "fair-code" che pone limiti se vuoi rivenderla come servizio ad altri. Restano i costi del server e, soprattutto, del tempo di chi lo installa e lo mantiene. Alcune funzioni avanzate sono nelle edizioni a pagamento.

### Perché Zapier diventa così caro?

Perché conta i task, cioè ogni azione eseguita in ogni flusso. Un flusso con molti passi che gira spesso consuma migliaia di task al mese, e i piani crescono a scaglioni. I flussi di sincronizzazione, polling e elaborazione di file riga per riga sono quelli che fanno salire di più la spesa.

### Make costa meno di Zapier?

In genere sì, a parità di volume, e gestisce meglio i flussi complessi. Il conteggio è per operazioni (ogni modulo eseguito), quindi anche Make diventa costoso con flussi molto lunghi e frequenti. Per molte PMI, passare da Zapier a Make è un risparmio significativo senza dover gestire un server.

### Quando conviene passare a n8n self-hosted?

Quando la spesa per le automazioni supera qualche centinaio di euro al mese o ha picchi imprevedibili, quando i flussi trattano dati di clienti o dipendenti che è meglio tenere in casa, e quando c'è una persona interna o un partner che si occupa del server. Sotto i 100–150 euro al mese, con volumi stabili, di solito non conviene.

### Chi mantiene n8n se l'azienda non ha un reparto IT?

Le opzioni realistiche sono un partner esterno con un contratto di manutenzione, n8n in cloud gestito dal fornitore, oppure una persona interna formata che costruisce i flussi affiancata da un partner per server e aggiornamenti. Servono da mezza giornata a una giornata e mezza al mese, più le emergenze.

### Quanto costa migrare da Zapier a n8n?

Dipende dal numero e dalla complessità dei flussi. Per una trentina di automazioni, tra installazione fatta bene e ricostruzione dei flussi, si parla indicativamente di 5–10 giorni di lavoro tecnico. Il costo si recupera in mesi o anni a seconda di quanto spendevi di abbonamento: con i volumi bassi, a volte non si recupera mai.

### I dati sono più al sicuro con n8n self-hosted?

Possono esserlo, perché i flussi girano su un server che controlli, in azienda o in un datacenter europeo, e i dati non passano dal fornitore dello strumento di automazione. Ma la sicurezza dipende da come è gestito il server: aggiornamenti, accessi, backup, credenziali. Un'installazione trascurata è meno sicura di un buon servizio in cloud.

### Si possono usare Zapier e n8n insieme?

Sì, ed è spesso la soluzione migliore nelle aziende con molte automazioni: i flussi semplici e poco sensibili restano su uno strumento in cloud, quelli con volumi alti o dati delicati vanno su n8n in casa. L'importante è avere un inventario chiaro di cosa gira dove.

### Come si migra senza fermare le automazioni?

Un flusso alla volta. Si ricostruisce il flusso in n8n, lo si fa girare in parallelo a quello vecchio per una o due settimane in modalità di controllo, si confrontano i risultati e solo allora si spegne il vecchio, senza cancellarlo per un mese. Si parte dai flussi a basso rischio, poi da quelli che consumano più task.

### Quali automazioni conviene fare per prime in una PMI?

Quelle che fanno risparmiare tempo ogni giorno e hanno regole chiare: contatti dal sito al CRM, notifiche degli ordini, smistamento delle fatture dalla PEC, promemoria delle scadenze, report automatici. Le automazioni con intelligenza artificiale, come la classificazione delle mail, vengono dopo, quando le basi funzionano.
