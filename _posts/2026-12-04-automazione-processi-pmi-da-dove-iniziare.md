---
lang: it
permalink: /it/blog/automazione-processi-pmi-da-dove-iniziare/
alt_url: /en/blog/sme-process-automation-where-to-start/
title: "Automazione per PMI senza ufficio IT: da dove si parte in 30 giorni (senza comprare 4 software nuovi)"
date: 2026-12-04 07:30:00 +0200
author: "Antonio Trento"
description: "Guida d'ingresso all'automazione dei processi per PMI senza IT: mappare dove va il tempo in una settimana, 3 quick win e 3 trappole, collegare gli strumenti che hai prima di sostituirli, il referente interno, un piano di 30 giorni settimana per settimana, budget onesto e come capire se ha funzionato."
keywords: ["automazione processi pmi da dove iniziare", "digitalizzazione pmi italia", "automazione senza it", "workflow aziendali piccoli", "n8n pmi", "inventario processi aziendali"]
image: /assets/images/posts/automazione-processi-pmi-da-dove-iniziare.jpg
pillar: automazione-da-dove
related: [/it/blog/costo-non-digitalizzare-processi/, /it/blog/n8n-vs-zapier-vs-make-costi/]
---

## Automazione non è "mettere l'AI su tutto"

Il titolare ha partecipato a un convegno. Tre relatori su quattro hanno parlato di intelligenza artificiale, agenti, automazione. Torna in azienda con la sensazione di essere indietro e una domanda: "**da dove si parte con l'automazione dei processi in una PMI come la nostra**, senza un ufficio IT?". Il rischio, a quel punto, è comprare la prima cosa che gli viene proposta: un CRM nuovo, un software per le fatture, un chatbot, una piattaforma di automazione. Quattro abbonamenti, quattro password, e sei mesi dopo le persone lavorano come prima, con quattro schede in più aperte sul browser.

Automatizzare non significa mettere l'intelligenza artificiale su tutto. Significa **togliere alle persone il lavoro ripetitivo che non richiede giudizio**: copiare dati da un posto all'altro, mandare promemoria, smistare documenti, preparare report che qualcuno compila a mano ogni lunedì. La maggior parte di questo lavoro si automatizza con strumenti semplici, collegando quello che l'azienda ha già, e l'AI serve solo in pochi punti precisi.

Questo pezzo è una guida d'ingresso, per titolari e responsabili di PMI tra 5 e 50 persone senza un reparto informatico. Ti porta dalla domanda "da dove parto?" a un piano di 30 giorni, con un modo concreto di capire dove va il tempo, tre interventi che quasi sempre funzionano, tre trappole da evitare, chi coinvolgere, quanto costa e come capire dopo un mese se è servito.

## È per te / non è per te

È per te se:

- hai una PMI o uno studio da 5 a 50 persone, senza un IT interno (o con un IT "di fortuna": il collega bravo con i computer);
- senti che si perde troppo tempo in attività ripetitive, ma non sai quantificarlo;
- hai ricevuto proposte di software e piattaforme e non sai quale sia la priorità;
- vuoi partire con poco e vedere risultati prima di investire di più.

Non è per te se hai già un reparto IT con un piano di digitalizzazione: troverai cose che sai. E non è per te se cerchi il confronto tra strumenti di automazione specifici: per quello c'è il pezzo su [n8n, Zapier e Make con i costi a confronto]({{ '/it/blog/n8n-vs-zapier-vs-make-costi/' | relative_url }}). Qui parliamo del prima: capire cosa automatizzare.

## Mappa di una settimana: dove va il tempo

Il primo passo non è scegliere uno strumento. È **sapere dove va il tempo**. Quasi nessuna PMI lo sa con precisione: si ha la sensazione che "le fatture portano via un sacco di tempo" o che "si perde tempo con le email", ma senza numeri.

Il modo più semplice per scoprirlo è una mappa di una settimana. Non serve un consulente: serve chiedere a ogni persona (o almeno a una per ruolo) di annotare, per cinque giorni, le attività ripetitive che fa, quanto tempo prendono e quanto spesso si ripetono.

### Canvas inventario processi

Ecco il canvas che uso. Si compila su un foglio di calcolo, una riga per attività.

| Attività | Chi la fa | Quante volte a settimana | Minuti ogni volta | Ore a settimana | Da dove prende i dati | Dove li mette | Richiede giudizio? | Errori frequenti? |
|---|---|---|---|---|---|---|---|---|
| Registrare fatture passive | Amministrazione | 80 | 3 | 4,0 | PEC / cassetto fiscale | Gestionale | Poco | Sì, IVA e fornitori |
| Copiare contatti dal sito al CRM | Commerciale | 25 | 4 | 1,7 | Email del modulo | CRM | No | Sì, dati incompleti |
| Mandare promemoria scadenze ai clienti | Amministrazione | 15 | 6 | 1,5 | Foglio Excel | Email | No | Sì, dimenticanze |
| Report vendite del lunedì | Titolare | 1 | 90 | 1,5 | Gestionale + Excel | Email | Poco | Numeri diversi ogni volta |
| Smistare richieste dalla casella info@ | Segreteria | 60 | 2 | 2,0 | Email | Altre caselle | Un po' | Richieste perse |
| Preparare DDT e conferme d'ordine | Logistica | 30 | 5 | 2,5 | Gestionale | PDF + email | No | Sì, indirizzi sbagliati |

Per ogni riga, tre domande decidono se l'attività è candidata all'automazione:

1. **Quante ore a settimana?** Sotto la mezz'ora, raramente vale la pena.
2. **Richiede giudizio?** Se la persona deve decidere qualcosa di non banale, l'automazione può aiutare (preparare i dati) ma non sostituire.
3. **I dati sono già digitali?** Se arrivano su carta o al telefono, prima bisogna digitalizzarli; se sono in un sistema, si possono collegare.

Alla fine della settimana avrai una lista di 15–30 attività con le ore. Quasi sempre emerge che **tre o quattro attività valgono metà del tempo ripetitivo**. Sono quelle da cui partire. E quasi sempre emergono anche costi che nessuno aveva visto: il tempo perso a cercare documenti, le telefonate per sapere a che punto è un ordine, le correzioni degli errori di copia. È il tema del pezzo sul [costo di non digitalizzare i processi]({{ '/it/blog/costo-non-digitalizzare-processi/' | relative_url }}).

## 3 quick win tipici e 3 trappole

### Tre quick win che funzionano quasi sempre

**1. Contatti e richieste dal sito al posto giusto.** Le richieste dal modulo del sito o dalla casella info@ arrivano in una casella email, qualcuno le copia nel CRM o nel gestionale, qualcun altro (forse) le richiama. Automatizzarle significa: la richiesta crea da sola il contatto, assegna un responsabile, manda una conferma al cliente e un avviso al commerciale. Risultato tipico: nessuna richiesta persa, tempi di risposta dimezzati, un'ora o due a settimana risparmiate. È anche il quick win con l'effetto più visibile sulle vendite.

**2. Promemoria automatici.** Scadenze di contratti, rinnovi, pagamenti, appuntamenti, documenti da rinnovare. Oggi vivono in un foglio Excel che qualcuno deve ricordarsi di aprire. Automatizzati, partono da soli: al cliente (il rinnovo tra 30 giorni), all'interno (il pagamento scaduto da 7 giorni). Risultato tipico: meno dimenticanze, meno soldi persi, meno telefonate imbarazzate.

**3. Il report che si fa da solo.** Il report del lunedì che il titolare o un collaboratore compila a mano copiando dati dal gestionale. Automatizzato, arriva per email ogni lunedì alle 8, sempre con gli stessi criteri. Risultato tipico: un'ora e mezza a settimana risparmiata e, soprattutto, numeri coerenti da una settimana all'altra.

Questi tre hanno caratteristiche comuni: dati già digitali, nessun giudizio richiesto, effetto visibile in pochi giorni, rischio basso se qualcosa va storto.

### Tre trappole

**1. Partire dal processo più complicato.** "Automatizziamo la gestione delle commesse dall'offerta alla fattura." È il processo più importante, ed è quello giusto da migliorare un giorno, ma come primo progetto è troppo: tante eccezioni, tante persone coinvolte, alto rischio di fallire e di bruciare la fiducia nell'automazione. Si parte dai bordi, non dal cuore.

**2. Automatizzare un processo che non funziona.** Se oggi le richieste dei clienti si perdono perché nessuno sa chi deve occuparsene, automatizzarne l'arrivo nel CRM non risolve niente: le richieste si perderanno nel CRM invece che nella casella. Prima si decide chi fa cosa, poi si automatizza.

**3. Mettere l'AI dove basta una regola.** "Usiamo l'intelligenza artificiale per decidere a chi assegnare la richiesta." Se la regola è "le richieste dalla Lombardia a Marco, il resto a Giulia", è una regola, non un lavoro per l'AI. L'intelligenza artificiale serve dove c'è testo da interpretare (una mail scritta liberamente, un documento da leggere), non dove c'è una tabella di regole.

## Strumenti: fogli, gestionale, mail, calendario — collega prima di sostituire

Il riflesso più costoso, quando si parla di automazione, è **sostituire**: "il nostro gestionale è vecchio, prendiamone uno nuovo", "Excel non basta, ci serve un CRM", "le mail sono un caos, ci serve una piattaforma". A volte è necessario. Molto più spesso, il primo passo è **collegare** gli strumenti che hai già.

Una PMI tipica ha:

- un **gestionale** (fatture, ordini, magazzino, anagrafiche);
- **email** e magari una PEC;
- **fogli di calcolo** con le cose che il gestionale non fa (scadenze, listini particolari, pianificazione);
- un **calendario** condiviso;
- forse un **CRM**, a volte usato a metà;
- il **sito** con un modulo di contatto.

Il lavoro ripetitivo sta quasi sempre **tra** questi strumenti: copiare dal modulo al CRM, dal gestionale al foglio, dal foglio alla mail. Uno strumento di automazione (n8n, Make, Zapier, o le automazioni già incluse nei software che hai) serve proprio a costruire questi ponti, senza sostituire nessuno degli strumenti.

### Lista delle trappole software

Prima di comprare un nuovo software, controlla di non stare cadendo in una di queste trappole:

- **Il software che duplica i dati.** Un nuovo strumento con la sua anagrafica clienti, diversa da quella del gestionale. Dopo tre mesi hai due versioni della verità e qualcuno che le allinea a mano.
- **Il software che nessuno apre.** Comprato per un'esigenza reale, ma richiede di entrare in un'altra applicazione che non fa parte della giornata delle persone. Se non è dove le persone lavorano già, non verrà usato.
- **L'abbonamento per utente su tutto il personale.** Licenze per 30 persone quando lo usano davvero in 5.
- **La funzione che c'era già.** Molti gestionali e CRM hanno automazioni incluse (promemoria, flussi, importazioni) che nessuno ha mai attivato. Prima di comprare, chiedi al fornitore del tuo gestionale cosa fa già.
- **Il lock-in non dichiarato.** Uno strumento da cui non puoi esportare i dati o i flussi in un formato standard. Il giorno in cui vuoi cambiare, ricominci da zero.
- **L'AI come argomento di vendita.** "Con l'intelligenza artificiale integrata" non è un motivo per comprare. Chiedi cosa fa, con quali dati, dove li tratta, e quanto lavoro toglie davvero.

## Chi è il referente interno (anche part-time)

L'automazione in una PMI senza IT fallisce quasi sempre per lo stesso motivo: **nessuno se ne occupa** dopo l'installazione. I flussi si rompono (un software cambia, una password scade, un modulo viene modificato) e nessuno se ne accorge per settimane.

Serve un **referente interno**. Non deve essere un informatico, e non deve farlo a tempo pieno. Le caratteristiche giuste:

- **conosce i processi** dell'azienda (sa come funzionano davvero, non come dovrebbero);
- **è preciso e curioso**, ha voglia di imparare uno strumento nuovo;
- **ha tempo riservato**: due-quattro ore a settimana all'inizio, una-due a regime, scritte nel suo orario e non "quando avanza tempo";
- **ha un mandato** dal titolare: può chiedere ai colleghi come lavorano, proporre cambiamenti, dire di no a un software.

Spesso è una persona dell'amministrazione o un commerciale con attitudine. Va affiancato, all'inizio, da un **partner esterno** (un professionista o una piccola società) che costruisce i primi flussi, gli insegna a gestirli, e resta disponibile per i problemi più tecnici. L'obiettivo è che dopo qualche mese il referente sappia modificare e sistemare i flussi semplici da solo.

## Piano 30 giorni settimana per settimana

Ecco il piano che propongo alle PMI che partono da zero.

### Settimana 1 — Mappa

- Il titolare presenta l'iniziativa in una riunione di 20 minuti: obiettivo (togliere lavoro ripetitivo, non persone), referente, tempi.
- Ogni ruolo compila il canvas inventario per cinque giorni.
- Il referente raccoglie l'elenco degli strumenti in uso, con chi li usa e chi li paga.

### Settimana 2 — Scelta

- Il referente, con il titolare (e il partner esterno, se c'è), ordina le attività per ore a settimana e facilità.
- Si scelgono **tre quick win**: dati già digitali, nessun giudizio, effetto visibile, rischio basso.
- Per ognuno si scrive su mezza pagina: cosa succede oggi, cosa succederà dopo, chi se ne accorge se si rompe.
- Si sceglie lo strumento per collegare (spesso uno strumento di automazione in cloud per partire; si valuta il self-hosted se i dati sono delicati o i volumi alti).

### Settimana 3 — Costruzione

- Si costruisce il primo quick win, il più semplice.
- Si fa girare **in parallelo** al modo attuale per qualche giorno: il flusso automatico lavora, ma la persona continua a fare il suo lavoro e confronta.
- Se va bene, si spegne il lavoro manuale per quell'attività. Poi si passa al secondo.

### Settimana 4 — Consolidamento

- Si completano il secondo e (se possibile) il terzo quick win.
- Si impostano gli **avvisi**: se un flusso fallisce, il referente riceve una notifica.
- Si scrive una pagina per ogni flusso: cosa fa, da dove prende i dati, dove li mette, cosa fare se si rompe.
- Riunione di 30 minuti con chi è coinvolto: cosa è cambiato, cosa non va, cosa automatizzare dopo.

Un esempio di come descrivere un flusso, su una pagina, in modo che chiunque lo capisca:

```text
FLUSSO: Richieste dal sito → CRM
Cosa fa:      Quando arriva una richiesta dal modulo "Contatti" del sito, crea il contatto
              nel CRM, lo assegna al commerciale di zona, manda una mail di conferma al
              cliente e un avviso al commerciale.
Da dove:      Modulo del sito (email a info@)
Dove:         CRM (scheda contatto) + email
Regola zona:  Nord → Marco; Centro-Sud → Giulia; Estero → titolare
Se si rompe:  Il referente riceve un avviso. Nel frattempo le richieste restano
              nella casella info@: controllarla a mano finché non è sistemato.
Referente:    Laura (amministrazione)        Partner esterno: [nome, telefono]
Ultima modifica: 2026-12-18
```

## Budget onesto (stime)

Le cifre seguenti sono **stime** indicative per una PMI di 10–30 persone che parte con tre quick win.

| Voce | Stima | Note |
|---|---|---|
| Strumento di automazione | 0–100 €/mese | Molti hanno piani gratuiti o economici per volumi bassi |
| Partner esterno per i primi flussi | 1.500–5.000 € | Dipende dal numero e dalla complessità dei flussi |
| Tempo del referente interno | 2–4 ore/settimana nel primo mese, poi 1–2 | Il costo più sottovalutato |
| Tempo delle persone per la mappa | 1–2 ore a testa nella prima settimana | Una tantum |
| Manutenzione | 0–200 €/mese | Supporto del partner a chiamata o con canone |
| Nuovi software | possibilmente 0 | Prima si collega quello che c'è |

Per confronto: se i tre quick win tolgono 5–8 ore a settimana di lavoro ripetitivo, a 30 € l'ora sono 600–1.000 € al mese di tempo restituito. L'investimento iniziale si ripaga in pochi mesi, e il tempo liberato va su attività che richiedono le persone: clienti, qualità, vendite.

## Come capire dopo 30 giorni se ha funzionato

Alla fine del mese, tre domande con risposte misurabili:

1. **Quante ore a settimana sono state tolte?** Rifai il canvas solo per le attività automatizzate e confronta con la prima settimana. Se il risparmio è sotto le due ore a settimana, i quick win erano scelti male o i flussi non sono usati.
2. **Quanti errori o dimenticanze in meno?** Richieste perse, promemoria non mandati, report con numeri diversi. Chiedi a chi li subiva.
3. **I flussi sono stabili?** Quante volte si sono rotti, quanto tempo è servito per sistemarli, il referente li sa gestire.

E una quarta domanda, meno misurabile ma importante: **le persone ne vogliono altre?** Se dopo un mese i colleghi arrivano dal referente con "si potrebbe automatizzare anche questo?", il progetto ha funzionato. Se nessuno ne parla, o se le persone hanno ricominciato a fare le cose a mano "perché è più sicuro", c'è qualcosa da capire prima di andare avanti.

## Percorso 30/60/90 giorni

- **0–30 giorni**: mappa, tre quick win, referente, avvisi, documentazione. (Il piano sopra.)
- **30–60 giorni**: altri due o tre flussi dalla lista, scelti tra quelli con più ore; prima formazione del referente per modificare i flussi da solo; primo controllo dei costi reali.
- **60–90 giorni**: si valuta un processo più centrale (per esempio dal preventivo all'ordine), con più persone coinvolte; si decide se servono strumenti nuovi o se bastano quelli collegati; si valuta dove l'AI può davvero aiutare (smistamento di email libere, lettura di documenti).

## Un caso concreto: un'impresa di installazioni con 15 persone

Ecco come va il primo mese in un caso tipico: un'impresa che fa installazioni e manutenzioni, 15 persone tra ufficio e tecnici, nessun IT interno. I numeri sono semplificati ma realistici.

**La mappa.** Dalla settimana di inventario escono 22 attività ripetitive per circa 31 ore a settimana in tutto. Quattro di queste valgono 17 ore: preparare i rapportini di intervento a partire dagli appunti dei tecnici (6 ore), richiamare i clienti per le manutenzioni periodiche in scadenza (4 ore), copiare le richieste dal sito e dalla mail nel gestionale (3,5 ore), compilare il report settimanale degli interventi per il titolare (3,5 ore, sommando chi raccoglie i dati e chi li impagina).

**La scelta.** I rapportini sono il punto più costoso, ma richiedono di cambiare il modo di lavorare dei tecnici (un'app o un modulo da compilare in cantiere): troppo per il primo mese, va nella lista dei 60–90 giorni. Si scelgono invece i tre quick win: promemoria delle manutenzioni, richieste dal sito al gestionale, report settimanale automatico.

**La costruzione.** Il referente è l'impiegata dell'ufficio, con 3 ore a settimana riservate, affiancata da un partner esterno per 4 giornate in tutto. Le scadenze delle manutenzioni erano in un foglio Excel: si collegano a un flusso che ogni lunedì manda al cliente una mail con la proposta di due date e all'ufficio l'elenco di chi chiamare se non risponde entro tre giorni. Le richieste dal sito creano la scheda nel gestionale e un avviso al responsabile tecnico. Il report settimanale arriva al titolare il lunedì alle 8, preso direttamente dal gestionale.

**Il risultato dopo 30 giorni.** Circa 8 ore a settimana tolte all'ufficio, nessuna richiesta dal sito persa (prima, secondo l'ufficio, "un paio al mese"), e un aumento delle manutenzioni confermate, perché il promemoria parte sempre e non solo quando qualcuno si ricorda di aprire il foglio. Il titolare, per la prima volta, guarda lo stesso report ogni settimana con gli stessi criteri. Il referente, al secondo mese, modifica da sola il testo delle mail e le regole di assegnazione.

## Cosa si rompe dopo qualche mese

Le automazioni semplici sono robuste, ma non eterne. I guasti tipici dopo qualche mese:

- **Una password o un accesso scade.** Un software collegato chiede di rinnovare l'autorizzazione, o la persona che l'aveva collegata con il suo account lascia l'azienda. Il flusso si ferma. Rimedio: collegare i software con account aziendali di servizio, non personali, e avere avvisi attivi.
- **Qualcuno cambia il modulo del sito o il foglio Excel.** Un campo rinominato, una colonna spostata: il flusso continua a girare ma scrive dati sbagliati o vuoti. Rimedio: una regola semplice, "prima di modificare un modulo o un foglio collegato, avvisa il referente".
- **Il flusso fa la cosa giusta nel modo sbagliato.** Il promemoria parte anche ai clienti che hanno già prenotato, perché nessuno aggiorna il foglio delle scadenze. Non è un guasto tecnico: è un pezzo di processo che manca. Si sistema chiedendo chi aggiorna cosa.
- **Nessuno guarda più gli avvisi.** Gli avvisi arrivano alla casella del referente, che è in ferie o ha cambiato ruolo. Rimedio: almeno due persone ricevono gli avvisi, e una volta al mese il referente fa un giro di controllo di tutti i flussi.
- **Il numero di flussi cresce senza ordine.** Dopo un anno ci sono 25 flussi costruiti da persone diverse, alcuni doppi, alcuni inutili. La pagina di documentazione per ogni flusso, e una revisione semestrale, evitano il caos.

## 3 errori da principiante che costano soldi o tempo

**1. Comprare prima di mappare.** Si sottoscrive un software perché "serve", e solo dopo si scopre che l'attività che doveva risolvere vale un'ora al mese, mentre quella che ne vale dieci a settimana non era stata vista. La settimana di mappa costa poco ed evita di investire nel posto sbagliato.

**2. Non dare tempo al referente.** "Se ne occupa Laura quando ha tempo." Laura non ha mai tempo, i flussi si rompono, nessuno se ne accorge, e dopo tre mesi l'automazione "non funziona". Due ore a settimana scritte in agenda fanno la differenza.

**3. Spegnere il lavoro manuale troppo presto.** Il flusso nuovo parte, sembra funzionare, e il giorno dopo si smette di controllare la casella info@. Una settimana dopo si scopre che le richieste con un allegato non venivano gestite. Il periodo in parallelo, anche breve, è l'assicurazione più economica che ci sia.

## Quando NON farlo (ancora)

- **Quando l'azienda è nel mezzo di un cambiamento grosso** (cambio di gestionale, trasloco, riorganizzazione): automatizzare processi che cambieranno tra due mesi è lavoro buttato.
- **Quando i processi non sono chiari a nessuno**: se nessuno sa dire chi fa cosa in un processo, prima va scritto come funziona, poi si automatizza.
- **Quando nessuno può fare il referente**: senza una persona che se ne occupa, meglio rimandare o affidare tutto a un partner esterno con un contratto chiaro.
- **Quando il lavoro ripetitivo è poco**: se la mappa mostra che le attività ripetitive valgono un paio d'ore a settimana in tutta l'azienda, ci sono probabilmente priorità più importanti.

## Checklist pratica

- [ ] Ho fatto (o fatto fare) la mappa di una settimana con il canvas inventario.
- [ ] Conosco le tre-quattro attività che valgono metà del tempo ripetitivo.
- [ ] Ho scelto tre quick win: dati digitali, nessun giudizio, effetto visibile, rischio basso.
- [ ] Ho un referente interno con ore riservate e un mandato chiaro.
- [ ] Ho verificato cosa fanno già gli strumenti che ho, prima di comprarne di nuovi.
- [ ] Ogni flusso gira in parallelo al lavoro manuale per qualche giorno prima di sostituirlo.
- [ ] Ci sono avvisi se un flusso si rompe.
- [ ] Ogni flusso ha una pagina che spiega cosa fa e cosa fare se si rompe.
- [ ] Dopo 30 giorni ho misurato ore risparmiate, errori evitati e stabilità.

## Il verdetto

La risposta alla domanda "**da dove parto con l'automazione dei processi in una PMI**" non è un software: è una settimana passata a capire dove va il tempo. Da lì escono quasi sempre tre o quattro attività ripetitive che valgono metà del lavoro inutile, e quasi sempre si possono automatizzare collegando gli strumenti che l'azienda ha già, senza comprarne di nuovi e senza bisogno dell'intelligenza artificiale.

Il resto è disciplina: un referente con tempo vero, tre quick win scelti bene, un periodo in parallelo prima di spegnere il lavoro manuale, avvisi quando qualcosa si rompe, e una misura onesta dopo trenta giorni. Non è spettacolare come un convegno, ma è il modo in cui le PMI senza IT iniziano davvero a lavorare meglio, e trovano la fiducia per fare il passo successivo.

Se vuoi impostare i primi trenta giorni di automazione nella tua azienda partendo dai numeri, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su come avviare l'automazione in una PMI sono nella guida su [automazione in PMI: da dove partire]({{ '/it/pillar/automazione-pmi/' | relative_url }}).

## FAQ

### Da dove si parte con l'automazione dei processi in una PMI?

Da una mappa di una settimana: ogni ruolo annota le attività ripetitive, quante volte le fa e quanto tempo prendono. Di solito emergono tre o quattro attività che valgono metà del tempo ripetitivo; tra queste si scelgono tre quick win con dati già digitali, nessun giudizio richiesto ed effetto visibile.

### Serve un ufficio IT per automatizzare i processi?

No. Serve un referente interno che conosca i processi e abbia qualche ora a settimana dedicata, affiancato all'inizio da un partner esterno che costruisce i primi flussi e gli insegna a gestirli. Il referente non deve essere un informatico.

### Quali sono i primi processi da automatizzare?

Tipicamente l'arrivo delle richieste dal sito nel CRM con assegnazione e conferma, i promemoria automatici di scadenze e rinnovi, e i report periodici che oggi qualcuno compila a mano. Sono attività con dati già digitali, senza decisioni complesse e con un effetto visibile in pochi giorni.

### Bisogna comprare un nuovo software per automatizzare?

Spesso no. Il lavoro ripetitivo sta quasi sempre tra gli strumenti che l'azienda ha già: gestionale, email, fogli di calcolo, calendario, CRM. Uno strumento di automazione serve a collegarli. Prima di comprare, conviene verificare quali automazioni sono già incluse nei software in uso.

### Quanto costa iniziare con l'automazione in una PMI?

Indicativamente da 0 a 100 euro al mese per lo strumento di automazione, da 1.500 a 5.000 euro per un partner esterno che costruisce i primi flussi, e qualche ora a settimana del referente interno. Se i primi flussi tolgono 5–8 ore di lavoro ripetitivo a settimana, l'investimento si ripaga in pochi mesi.

### Quando serve l'intelligenza artificiale nell'automazione?

Quando c'è testo da interpretare: email scritte liberamente da smistare, documenti da leggere, note da riassumere. Dove esiste una regola chiara, come l'assegnazione per zona o una scadenza calcolata, basta una regola e l'AI aggiunge solo costo e rischio.

### Come si evita che le automazioni si rompano senza che nessuno se ne accorga?

Impostando avvisi che notificano il referente quando un flusso fallisce, documentando ogni flusso su una pagina con cosa fare se si rompe, e facendo girare ogni nuovo flusso in parallelo al lavoro manuale per qualche giorno prima di sostituirlo.

### Quali sono le trappole più comuni?

Partire dal processo più complicato, automatizzare un processo che non funziona già a mano, usare l'AI dove basta una regola, e comprare software che duplicano i dati, che nessuno apre o che hanno funzioni già presenti negli strumenti esistenti.

### Come si misura se l'automazione ha funzionato?

Dopo 30 giorni si confrontano le ore spese sulle attività automatizzate con quelle della settimana di mappa, si contano gli errori e le dimenticanze evitate, si verifica quante volte i flussi si sono rotti e se il referente li sa gestire. Un buon segnale è che i colleghi propongano altre attività da automatizzare.

### Quando è meglio rimandare l'automazione?

Quando l'azienda sta cambiando gestionale o si sta riorganizzando, quando i processi non sono chiari a nessuno, quando non c'è nessuno che possa fare da referente, o quando la mappa mostra che il lavoro ripetitivo è poco. In questi casi ci sono priorità che vengono prima.
