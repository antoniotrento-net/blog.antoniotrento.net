---
lang: it
permalink: /it/blog/whatsapp-business-ai-prenotazioni/
alt_url: /en/blog/whatsapp-business-ai-bookings/
title: "WhatsApp Business + AI per prenotazioni: come non regalare la rubrica dei clienti a un SaaS americano"
date: 2026-12-12 07:30:00 +0200
author: "Antonio Trento"
description: "Per attività su appuntamento che vogliono prenotazioni su WhatsApp con un assistente automatico: API ufficiale contro strumenti grigi (ban e termini d'uso), cosa può fare il bot e cosa no, chi è titolare dei numeri dei clienti, flusso di prenotazione con conferma umana, orari e passaggio al telefono, costi di Meta e integratore contro una segretaria."
keywords: ["whatsapp business ai prenotazioni", "chatbot whatsapp pmi", "prenotazioni automatiche whatsapp", "privacy whatsapp api", "assistente whatsapp italia", "whatsapp business platform"]
image: /assets/images/posts/whatsapp-business-ai-prenotazioni.jpg
pillar: automazione-da-dove
related: [/it/blog/chatbot-sito-web-non-converte/, /it/blog/ridurre-no-show-prenotazioni/]
---

## Perché tutti vogliono il bot su WhatsApp

Lo studio dentistico, il centro estetico, la palestra, l'officina, lo studio di fisioterapia: tutti hanno lo stesso problema. Il telefono squilla mentre si sta lavorando, i messaggi su WhatsApp si accumulano ("avete posto giovedì?", "posso spostare l'appuntamento?", "quanto costa una pulizia?"), e qualcuno — spesso il titolare stesso — passa la sera a rispondere dal proprio cellulare. I clienti scrivono su WhatsApp perché è il canale che usano per tutto. E allora l'idea arriva naturale: "mettiamo un bot su WhatsApp che prenota da solo".

L'idea è buona. **WhatsApp Business con un assistente AI per le prenotazioni** può togliere ore di lavoro e far trovare un appuntamento al cliente anche alle undici di sera. Ma il modo in cui viene realizzata di solito no. Il fornitore che lo propone collega il numero dell'attività a una piattaforma americana, spesso con strumenti non ufficiali, carica la rubrica dei clienti sui suoi server, e mette un modello di linguaggio a rispondere su tutto, compresi prezzi e consigli che nessuno ha approvato. Dopo tre mesi il numero viene bloccato da WhatsApp, oppure un cliente riceve una risposta sbagliata sul trattamento, oppure ci si accorge che i dati di centinaia di clienti stanno su un servizio di cui non si sa niente.

Questo pezzo spiega come si fa bene: quale strada tecnica usare per non rischiare il blocco del numero, cosa può fare un assistente su WhatsApp e cosa no, chi è responsabile dei numeri e dei dati dei clienti, come costruire un flusso di prenotazione con conferma umana, come gestire orari, ferie e passaggio al telefono, e quanto costa davvero rispetto a una segretaria part-time.

## È per te / non è per te

È per te se:

- hai un'attività su appuntamento (studio professionale, salute e benessere, servizi alla persona, assistenza tecnica, ristorazione con prenotazioni) e molti clienti ti scrivono su WhatsApp;
- rispondi ai messaggi dal cellulare personale o da un telefono condiviso, con fatica;
- ti hanno proposto un "bot WhatsApp con intelligenza artificiale" e vuoi capire se è sicuro.

Non è per te se i messaggi su WhatsApp sono pochi al giorno: rispondere a mano, con le risposte rapide dell'app Business, costa meno di qualsiasi progetto. E non è per te se cerchi un modo per mandare messaggi promozionali in massa: lì le regole (e i rischi di blocco) sono molto più severe, ed è un altro discorso.

## API ufficiale vs tool grigi (ban, ToS)

La prima scelta, quella da cui dipende tutto il resto, è **come** il sistema si collega a WhatsApp. Ci sono tre strade.

### 1. L'app WhatsApp Business (manuale)

L'app gratuita per le attività: profilo aziendale, orari, catalogo, risposte rapide, messaggi automatici di benvenuto e di assenza, etichette per organizzare le chat. Si usa da un telefono (e da qualche dispositivo collegato). Non permette di collegare un sistema di prenotazione automatica in modo ufficiale.

- Pro: gratuita, immediata, nessun rischio.
- Contro: tutto il lavoro resta manuale; il numero e le chat vivono su un telefono.

### 2. La piattaforma ufficiale per le aziende (API)

Meta offre la **WhatsApp Business Platform**, cioè l'accesso ufficiale tramite API, direttamente o attraverso un fornitore autorizzato (un "Business Solution Provider" o un integratore che usa le API ufficiali). È l'unica strada **legittima** per collegare WhatsApp a un sistema di prenotazione o a un assistente automatico.

- Pro: ufficiale, stabile, con regole chiare; permette automazioni, integrazione con l'agenda, più operatori sullo stesso numero.
- Contro: richiede la verifica dell'azienda, l'approvazione dei messaggi modello per i messaggi che inizi tu, il rispetto delle policy di Meta, e ha dei costi per conversazione o per messaggio.

### 3. Gli strumenti "grigi"

Sono servizi che automatizzano WhatsApp **senza passare dalle API ufficiali**: simulano il telefono o la versione web, collegando il tuo numero a un sistema che legge e risponde ai messaggi. Costano poco, si attivano in dieci minuti, promettono "funziona con il tuo numero di sempre".

- Rischio principale: **violano i termini d'uso** di WhatsApp. Il numero può essere **bloccato**, temporaneamente o definitivamente, senza preavviso. Se quel numero è quello che i tuoi clienti conoscono da anni, perderlo è un danno serio.
- Rischio secondario: il fornitore ha accesso completo alle tue chat e alla tua rubrica, spesso senza un contratto adeguato.

### I rischi di blocco dell'account

Anche con l'API ufficiale, un numero può essere limitato o bloccato. I motivi più comuni:

- **messaggi non richiesti**: scrivere a persone che non hanno dato il consenso a ricevere messaggi dall'attività;
- **troppi blocchi e segnalazioni** da parte dei destinatari (indicatore di spam);
- **contenuti non ammessi** dalle policy commerciali di Meta per certi settori;
- **uso di strumenti non ufficiali** sullo stesso numero;
- **assistenti AI generici**: le regole di Meta per la piattaforma business distinguono tra assistenti legati all'attività (prenotazioni, assistenza clienti, informazioni sui servizi), ammessi, e chatbot di intelligenza artificiale "generici" che rispondono su qualsiasi argomento, che sono stati ristretti. Un assistente che prenota appuntamenti è nel primo gruppo; un modello lasciato libero di chiacchierare su tutto rischia di finire nel secondo. Verifica le policy in vigore con il tuo fornitore.

La regola pratica: **API ufficiale, consenso dei clienti, messaggi utili e attesi**. Niente scorciatoie con strumenti grigi sul numero principale dell'attività.

## Cosa può fare: orari, slot, FAQ, pagamento? (confini)

Un assistente su WhatsApp per un'attività su appuntamento deve fare poche cose, e farle bene.

**Cosa può fare bene:**

- **rispondere alle domande frequenti** con risposte approvate: orari, indirizzo, parcheggio, servizi offerti, cosa portare, prezzi indicativi presi dal listino;
- **proporre gli orari liberi** leggendoli dall'agenda reale e **prenotare** uno slot;
- **spostare o disdire** un appuntamento, secondo le regole dell'attività (per esempio, fino a 24 ore prima);
- **mandare promemoria** prima dell'appuntamento, con la possibilità di confermare o disdire con un tocco;
- **raccogliere le informazioni** che servono prima della visita (motivo, prima volta o no), senza entrare in dettagli delicati;
- **passare la conversazione a una persona** quando la richiesta esce dai confini.

**Cosa non deve fare:**

- **dare consigli professionali**: diagnosi, valutazioni tecniche, consigli su trattamenti o farmaci, pareri legali. Nemmeno "indicativi";
- **promettere prezzi, sconti o disponibilità** che non vengono dal listino o dall'agenda;
- **raccogliere dati sanitari o delicati** in conversazione libera ("mi descriva i sintomi");
- **trattare reclami complessi** da solo: un cliente arrabbiato va passato a una persona;
- **fingere di essere una persona**. Deve essere chiaro che è un assistente automatico.

**E il pagamento?** Chiedere un acconto per confermare la prenotazione (per ridurre i no-show) può avere senso, ma va fatto con un link a una pagina di pagamento sicura del tuo fornitore di pagamenti, non chiedendo dati di carta in chat. E va valutato con attenzione: per alcune attività un acconto riduce le assenze, per altre allontana i clienti.

Il principio è lo stesso che vale per il chatbot sul sito, descritto nel pezzo sul [chatbot che non porta appuntamenti]({{ '/it/blog/chatbot-sito-web-non-converte/' | relative_url }}): l'assistente serve a portare la persona a un appuntamento confermato, non a conversare.

## Rubrica e GDPR: chi è titolare dei numeri

Il titolo di questo pezzo parla di "regalare la rubrica". Vediamo cosa significa.

**Il titolare dei dati sei tu.** I numeri di telefono, i nomi, gli appuntamenti e le conversazioni con i clienti sono dati personali di cui la tua attività è **titolare del trattamento**. Ne rispondi tu, anche se materialmente stanno sui server di altri.

**Chi altro li tratta.** Con un sistema di prenotazione su WhatsApp, i dati passano da:

- **Meta**, che gestisce WhatsApp e, per la piattaforma business, ha condizioni specifiche per il trattamento dei dati delle aziende;
- **il fornitore della piattaforma o l'integratore**, che collega WhatsApp alla tua agenda e spesso conserva le conversazioni;
- **il fornitore del modello AI**, se l'assistente usa un modello di linguaggio;
- **il software di agenda**, dove finiscono gli appuntamenti.

Ognuno di questi deve essere nominato **responsabile del trattamento** con un contratto, e devi sapere **dove** tratta i dati. Se il fornitore della piattaforma è un SaaS americano che conserva tutte le conversazioni dei tuoi clienti senza dirti per quanto tempo e senza un contratto chiaro, è lì che stai "regalando la rubrica".

**Il problema del telefono personale.** Con l'app sul cellulare personale del titolare, i numeri dei clienti finiscono nella rubrica del telefono, mescolati con quelli personali, sincronizzati con il cloud del telefono, e accessibili a chiunque usi quel telefono. Il giorno in cui il collaboratore che gestiva le prenotazioni lascia l'attività, si porta via la rubrica dei clienti.

**Il consenso per i messaggi.** Rispondere a un cliente che ti ha scritto è sempre possibile. Mandare messaggi che inizi tu (promemoria, comunicazioni) richiede che il cliente abbia accettato di riceverli su WhatsApp. Le promozioni e il marketing richiedono un consenso specifico, separato.

### Checklist privacy dei numeri

- [ ] Il numero WhatsApp è **aziendale**, non il cellulare personale di qualcuno.
- [ ] Uso l'**API ufficiale** tramite un fornitore autorizzato, non strumenti grigi.
- [ ] Il fornitore della piattaforma è **nominato responsabile** del trattamento, con contratto.
- [ ] So **dove** il fornitore conserva le conversazioni e **per quanto tempo**; preferibilmente in UE.
- [ ] Se c'è un modello AI, so chi lo fornisce, dove tratta i dati, e che **non usa le conversazioni per l'addestramento**.
- [ ] L'**informativa privacy** spiega che le prenotazioni passano da WhatsApp e da un assistente automatico.
- [ ] Ho il **consenso** dei clienti per i messaggi che inizio io (promemoria); consenso separato per il marketing.
- [ ] L'assistente **non chiede dati sanitari** o delicati in chat.
- [ ] Le conversazioni vengono **cancellate** dopo un periodo definito (per esempio 12 mesi), salvo obblighi diversi.
- [ ] Posso **esportare** i dati (contatti, appuntamenti) se cambio fornitore.

## Flusso prenotazione con conferma umana

Ecco un flusso che funziona per la maggior parte delle attività su appuntamento. L'assistente fa la parte ripetitiva; una persona conferma.

### Il flusso di prenotazione

```text
CLIENTE scrive su WhatsApp: "Avete posto per una pulizia la prossima settimana?"
   │
   ▼
ASSISTENTE: "Ciao! Sono l'assistente automatico dello Studio [nome].
             Posso aiutarti a prenotare. Che servizio ti serve?"
             [Prima visita] [Pulizia/igiene] [Controllo] [Altro / parla con noi]
   │
   ▼ (Pulizia/igiene)
ASSISTENTE legge l'agenda reale e propone 3 orari:
             "Ho questi posti liberi: mar 16 alle 9:30 · mer 17 alle 15:00 · ven 19 alle 11:00"
   │
   ▼ (mer 17 alle 15:00)
ASSISTENTE: "Perfetto. Mi confermi nome e cognome?"
   │
   ▼
ASSISTENTE: "Ho riservato mercoledì 17 alle 15:00 per Mario Rossi.
             La segreteria te lo conferma entro 2 ore lavorative.
             Ti mando un promemoria il giorno prima."
   │
   ▼
SEGRETERIA (in un'unica vista): vede la prenotazione riservata, controlla
             (servizio giusto? cliente noto? note particolari?) → CONFERMA
   │
   ▼
ASSISTENTE: "Confermato! Ti aspettiamo mercoledì 17 alle 15:00. Per spostare
             o disdire rispondi a questo messaggio fino a 24 ore prima."
   │
   ▼ (il giorno prima)
ASSISTENTE: "Promemoria: domani alle 15:00 hai l'appuntamento. Confermi?"
             [Confermo] [Devo spostare] [Devo disdire]
```

Riga per riga, il perché:

- **L'assistente si presenta come automatico** e dice di quale attività è. Niente nomi finti.
- **Le scelte sono pulsanti**, non domande aperte: meno errori, meno tempo.
- **Gli orari vengono dall'agenda vera**, non da una lista statica: niente doppie prenotazioni.
- **I dati si chiedono alla fine**, quando il cliente ha già scelto l'orario.
- **Lo slot è riservato, non confermato**: la segreteria controlla e conferma. È il punto che evita la maggior parte dei problemi (servizio sbagliato, cliente con esigenze particolari, appuntamenti falsi).
- **Il promemoria con conferma** riduce le assenze: chi non può venire lo dice prima, e lo slot si libera. Il tema delle assenze è trattato nel pezzo su [come ridurre i no-show nelle prenotazioni]({{ '/it/blog/ridurre-no-show-prenotazioni/' | relative_url }}).

## Orari, ferie, handover al telefono

Un assistente su WhatsApp lavora 24 ore su 24. Le persone no. Il sistema deve saperlo, e dirlo.

- **Fuori orario**, l'assistente può prenotare (lo slot resta "riservato") ma deve dire quando arriverà la conferma: "La segreteria ti confermerà domattina dalle 9".
- **Durante le ferie** o le chiusure, l'agenda è bloccata e l'assistente lo dice subito, proponendo le prime date disponibili alla riapertura.
- **Il passaggio a una persona** deve essere sempre possibile e visibile: un pulsante "Parla con noi" o una frase chiave. Quando il cliente lo chiede, o quando l'assistente non sa rispondere, la conversazione passa alla segreteria, con tutto lo storico visibile.
- **Il passaggio al telefono**, per le richieste urgenti o delicate: "Per le urgenze chiama il numero [...] dalle 9 alle 18". Un assistente che trattiene in chat un cliente con un problema urgente fa danni.
- **I tempi di risposta umana** vanno dichiarati e rispettati. Se la segreteria risponde entro due ore lavorative, va detto. Se non risponde mai, il sistema perde la fiducia dei clienti più velocemente di prima.

## Un caso concreto: uno studio di fisioterapia con 4 professionisti

Uno studio con 4 fisioterapisti, una segretaria part-time, circa 120 appuntamenti a settimana. Prima del progetto: telefono che squilla durante le sedute, 40–60 messaggi WhatsApp al giorno sul cellulare dello studio, la segretaria che passa metà del suo tempo a rispondere e spostare appuntamenti, circa 8% di assenze.

**Cosa si è fatto.** Numero WhatsApp aziendale collegato alla piattaforma ufficiale tramite un integratore con server in UE e contratto. Assistente con risposte approvate (orari, servizi, prezzi da listino, cosa portare), collegato all'agenda dello studio, con il flusso "riserva → conferma della segreteria". Promemoria il giorno prima con conferma. Pulsante "Parla con noi" sempre visibile. Nessuna domanda sui sintomi in chat: per la prima visita l'assistente chiede solo "è la prima volta?" e la zona del corpo, il resto lo raccoglie il fisioterapista.

**Dopo due mesi.** Circa il 60% delle prenotazioni e degli spostamenti viene gestito dall'assistente, con la sola conferma della segreteria (un clic). La segretaria recupera 8–10 ore a settimana, che usa per richiamare i pazienti in sospeso e gestire le pratiche. Le assenze scendono intorno al 4%, grazie al promemoria con conferma. Il numero dello studio non è mai stato a rischio, perché tutto passa dall'API ufficiale.

**Cosa non ha funzionato all'inizio.** Alcuni pazienti anziani non capivano i pulsanti e scrivevano frasi lunghe. Si è aggiunta una regola: dopo due messaggi non compresi, l'assistente passa alla segreteria. E una parte dei pazienti continua a preferire il telefono: va bene così.

## Cosa si rompe dopo qualche mese

Un sistema di prenotazione su WhatsApp funziona bene i primi mesi e poi, se nessuno lo guarda, comincia a perdere colpi. I segnali tipici:

- **L'agenda e il bot non coincidono più.** Un professionista aggiunge una pausa o un giorno di ferie direttamente sull'agenda di carta, o su un'altra agenda, e il bot continua a proporre quegli orari. Rimedio: una sola agenda, quella collegata, per tutti; e una regola scritta "le assenze si segnano lì, non altrove".
- **Le risposte approvate invecchiano.** Cambiano i prezzi, gli orari estivi, i servizi offerti, e le risposte del bot restano quelle di sei mesi prima. Rimedio: una revisione delle risposte ogni volta che cambia il listino, e comunque ogni tre mesi.
- **La coda delle conferme si allunga.** All'inizio la segreteria conferma in mezz'ora; dopo qualche mese, nei periodi pieni, le prenotazioni restano "riservate" per un giorno intero e i clienti si lamentano. Rimedio: un tempo massimo dichiarato e un avviso interno quando viene superato.
- **I messaggi modello vengono rifiutati o limitati.** Meta può sospendere un modello di messaggio se troppi destinatari lo bloccano o lo segnalano. Di solito succede quando i promemoria diventano troppi o troppo promozionali. Rimedio: promemoria utili e brevi, niente promozioni mescolate.
- **I clienti scrivono cose che il bot non capisce.** Vocali, foto, messaggi lunghi. Dopo qualche mese si vede quali sono i casi più frequenti: alcuni si possono aggiungere ai pulsanti, gli altri passano alla segreteria. Rimedio: guardare una volta al mese le conversazioni passate a una persona.

Quindici minuti al mese su questi punti tengono il sistema affidabile. Senza, dopo un anno il bot propone orari sbagliati e prezzi vecchi, e i clienti tornano a telefonare.

## Costi Meta + integratore vs segretaria

Le cifre seguenti sono **stime** indicative. Meta ha cambiato più volte il modello di prezzo della piattaforma business (per conversazione, poi per messaggio con categorie diverse); verifica il listino in vigore con il tuo fornitore.

| Voce | Stima | Note |
|---|---|---|
| Messaggi WhatsApp (Meta) | da pochi euro a qualche decina di €/mese | Rispondere ai clienti che scrivono è in gran parte gratuito; i messaggi modello che inizi tu (promemoria) hanno un costo per messaggio, basso per quelli "di servizio" |
| Piattaforma / integratore | 30–200 €/mese | Dipende da funzioni, operatori, volumi |
| Setup (agenda, flusso, risposte approvate) | 1.000–4.000 € | Una tantum |
| Modello AI per le risposte libere (opzionale) | 10–80 €/mese | Solo se servono risposte a domande non previste dai pulsanti |
| Tempo della segreteria per conferme e passaggi | 15–30 min/giorno | Invece di diverse ore |
| **Confronto: segretaria part-time aggiuntiva** | 900–1.400 €/mese | Costo indicativo per 20 ore a settimana |

Il confronto onesto non è "il bot sostituisce la segretaria". È: **il bot toglie alla segretaria il lavoro ripetitivo** (proporre orari, spostare, mandare promemoria) e le lascia quello che richiede una persona (conferme, casi particolari, pazienti arrabbiati, telefonate delicate). Per un'attività che sta pensando di assumere qualcuno solo per rispondere ai messaggi, il sistema costa molto meno. Per un'attività con pochi messaggi, non si ripaga.

## Quando un form o una telefonata vincono

- **Clienti anziani o servizi delicati.** Il telefono resta il canale migliore, e va tenuto ben visibile.
- **Prenotazioni complesse** (più servizi in sequenza, più professionisti, attrezzature da riservare): un modulo guidato sul sito o una telefonata gestiscono meglio la complessità.
- **Pochi messaggi.** Sotto i 10–15 messaggi al giorno, le risposte rapide dell'app Business bastano.
- **Richieste di preventivo** con foto e descrizioni: un modulo raccoglie meglio le informazioni strutturate.
- **Clienti aziendali** (B2B): spesso preferiscono email e telefono, e WhatsApp può sembrare poco professionale.

## Percorso 30/60/90 giorni

**Primi 30 giorni — basi**

- passare a un numero aziendale con l'app Business, risposte rapide e messaggi di assenza;
- contare i messaggi al giorno e il tempo speso a rispondere;
- scegliere un integratore che usa l'API ufficiale, con contratto e server in UE;
- scrivere le risposte approvate alle domande frequenti.

**Da 30 a 60 giorni — prenotazioni**

- collegare l'agenda e attivare il flusso "riserva → conferma";
- aggiornare l'informativa privacy e raccogliere il consenso per i promemoria;
- attivare i promemoria con conferma.

**Da 60 a 90 giorni — misura e ritocchi**

- misurare: prenotazioni via WhatsApp, tempo della segreteria, assenze, passaggi a persona;
- aggiungere le domande frequenti che mancano;
- valutare se serve un modello AI per le domande libere, con confini precisi.

## 3 errori da principiante che costano soldi o dati

**1. Usare uno strumento grigio sul numero storico dell'attività.** Costa poco e si attiva in dieci minuti, finché WhatsApp non blocca il numero. Perdere il numero che i clienti usano da anni costa molto più di qualsiasi abbonamento ufficiale.

**2. Lasciare l'assistente libero di rispondere su tutto.** Un modello senza confini che risponde a "posso prendere l'antinfiammatorio prima della seduta?" o "quanto mi costa tutto il ciclo?" inventando una risposta plausibile è un rischio per il cliente e per l'attività. Risposte approvate, confini scritti, passaggio a una persona.

**3. Gestire WhatsApp dal cellulare personale.** La rubrica dei clienti finisce nel telefono di una persona, mescolata con i contatti privati, e se ne va con lei. Numero aziendale, accesso per più operatori, dati esportabili.

## Quando NON farlo

- **Quando i messaggi sono pochi**: l'app Business con risposte rapide basta.
- **Quando non c'è nessuno che conferma**: un sistema che riserva slot senza che nessuno confermi crea doppie prenotazioni e clienti delusi.
- **Quando l'agenda non è digitale**: se gli appuntamenti sono su un'agenda di carta, prima si digitalizza l'agenda.
- **Quando il fornitore non sa dirti dove sono i dati** e non ti offre un contratto: non partire.
- **Quando vuoi usarlo per il marketing di massa**: è un altro progetto, con regole di consenso e rischi di blocco molto più alti.

## Checklist pratica

- [ ] Ho un numero WhatsApp aziendale, non il cellulare personale di qualcuno.
- [ ] Uso l'API ufficiale tramite un fornitore autorizzato, con contratto e dati in UE.
- [ ] L'assistente si presenta come automatico e usa risposte approvate.
- [ ] Gli orari proposti vengono dall'agenda reale.
- [ ] Le prenotazioni vengono riservate e poi confermate da una persona.
- [ ] Il promemoria con conferma parte il giorno prima.
- [ ] Il passaggio a una persona è sempre possibile; dopo due messaggi non compresi avviene da solo.
- [ ] Fuori orario e in ferie, l'assistente dice quando arriverà la risposta umana.
- [ ] Nessun dato sanitario o delicato viene chiesto in chat.
- [ ] L'informativa privacy è aggiornata e i consensi per i messaggi sono raccolti.

## Il verdetto

**WhatsApp Business con un assistente AI per le prenotazioni** è una delle automazioni con il ritorno più immediato per un'attività su appuntamento: i clienti usano già quel canale, e una buona parte delle richieste è ripetitiva. Ma va fatta con l'API ufficiale, con un numero aziendale, con un fornitore che firma un contratto e tiene i dati in Europa, e con un assistente che fa poche cose bene: proporre orari veri, riservare, ricordare, passare a una persona.

Il bot che risponde su tutto, collegato al numero storico con uno strumento grigio e a un SaaS che conserva le conversazioni chissà dove, costa meno all'inizio e molto di più dopo: un numero bloccato, una risposta sbagliata a un cliente, una rubrica che non è più tua. La versione fatta bene è meno spettacolare, e ti lascia i clienti, i loro numeri e la loro fiducia.

Se vuoi impostare le prenotazioni su WhatsApp per la tua attività senza perdere il controllo dei dati dei clienti, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su come avviare l'automazione in una PMI sono nella guida su [automazione in PMI: da dove partire]({{ '/it/pillar/automazione-pmi/' | relative_url }}).

## FAQ

### Si può usare un bot su WhatsApp per prenotare gli appuntamenti?

Sì, usando la piattaforma ufficiale per le aziende di WhatsApp, tramite API e un fornitore autorizzato. Il bot può proporre gli orari liberi letti dall'agenda, riservare uno slot, mandare promemoria e gestire spostamenti e disdette, con la conferma finale di una persona e la possibilità di passare sempre la conversazione alla segreteria.

### Cosa rischio usando strumenti non ufficiali per automatizzare WhatsApp?

Il blocco del numero, temporaneo o definitivo, perché violano i termini d'uso di WhatsApp. Se il numero è quello storico dell'attività, perderlo è un danno serio. Inoltre questi strumenti hanno spesso accesso completo alle chat e alla rubrica senza un contratto adeguato sul trattamento dei dati.

### Chi è responsabile dei dati dei clienti su WhatsApp?

L'attività è titolare del trattamento dei numeri, dei nomi, degli appuntamenti e delle conversazioni con i clienti. I fornitori coinvolti, come la piattaforma o l'integratore e l'eventuale fornitore del modello AI, devono essere nominati responsabili del trattamento con un contratto, e bisogna sapere dove conservano i dati e per quanto tempo.

### Cosa non deve fare un assistente AI su WhatsApp?

Non deve dare consigli professionali come diagnosi o pareri tecnici, non deve promettere prezzi o disponibilità che non vengono dal listino e dall'agenda, non deve chiedere dati sanitari in chat, non deve gestire da solo reclami complessi e non deve fingere di essere una persona.

### Quanto costa un sistema di prenotazione su WhatsApp?

Indicativamente da 1.000 a 4.000 euro di setup, da 30 a 200 euro al mese per la piattaforma o l'integratore, e da pochi euro a qualche decina al mese per i messaggi di Meta, secondo il listino in vigore. Un eventuale modello AI per le domande libere aggiunge qualche decina di euro al mese.

### Serve il consenso dei clienti per mandare promemoria su WhatsApp?

Per rispondere a un cliente che ti ha scritto no. Per i messaggi che inizi tu, come i promemoria, il cliente deve aver accettato di riceverli su WhatsApp. Per le comunicazioni promozionali serve un consenso specifico e separato.

### Il bot su WhatsApp può sostituire la segretaria?

Non del tutto. Può toglierle il lavoro ripetitivo, come proporre orari, spostare appuntamenti e mandare promemoria, liberando diverse ore a settimana. Le conferme, i casi particolari, i clienti scontenti e le telefonate delicate restano lavoro per una persona.

### Posso usare il numero di cellulare personale per WhatsApp Business?

È sconsigliato. I numeri dei clienti finiscono nella rubrica personale, mescolati con i contatti privati e sincronizzati con il cloud del telefono, e se la persona lascia l'attività si porta via i contatti. Conviene un numero aziendale gestibile da più operatori, con dati esportabili.

### I chatbot AI sono ammessi su WhatsApp Business?

Gli assistenti legati all'attività, come quelli per prenotazioni, assistenza clienti e informazioni sui servizi, sono ammessi sulla piattaforma ufficiale. Le policy di Meta hanno invece ristretto i chatbot di intelligenza artificiale generici che rispondono su qualsiasi argomento. Conviene verificare le regole in vigore con il fornitore.

### Quando conviene il telefono invece di WhatsApp?

Con clienti anziani, servizi delicati o urgenti, prenotazioni complesse con più servizi e professionisti, e clienti aziendali che preferiscono canali più formali. Il telefono va comunque sempre lasciato visibile come alternativa.
