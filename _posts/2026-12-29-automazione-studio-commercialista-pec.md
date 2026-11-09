---
lang: it
permalink: /it/blog/automazione-studio-commercialista-pec/
alt_url: /en/blog/accounting-firm-pec-automation/
title: "PEC, fatture e scadenze: come automatizzare uno studio (commercialista, consulente, agenzia) senza sostituire il professionista"
date: 2026-12-29 07:30:00 +0200
author: "Antonio Trento"
description: "Per studi professionali da 3 a 10 persone: cosa si può smistare in automatico (PEC, fatture, scadenze, richieste ripetute) e cosa non si tocca (parere, firma, SPID, responsabilità), il flusso arrivo → classifica → cartella → promemoria → professionista, riservatezza dei clienti, gestionale prima del chatbot, costi contro una segretaria part-time e un piano di 60 giorni."
keywords: ["automazione studio commercialista pec", "automazione studio professionale", "pec automatica", "scadenze fiscali software", "ai per commercialisti", "smistamento pec studio"]
image: /assets/images/posts/automazione-studio-commercialista-pec.jpg
pillar: integrazioni-selfhosted
related: [/it/blog/agente-ai-spid-pec-limiti/, /it/blog/ai-lettura-fatture-errori/]
---

## Lo studio annega in PEC e PDF, non in "mancanza di AI"

Lunedì mattina, studio di commercialisti con sei persone. Nella casella PEC dello studio ci sono 140 messaggi arrivati dal venerdì: avvisi dell'Agenzia delle Entrate per i clienti, comunicazioni dell'INPS, notifiche della Camera di Commercio, fatture dei fornitori dello studio, ricevute di consegna di invii fatti venerdì, richieste dei clienti, newsletter certificate di enti vari. Nelle caselle email ordinarie, altre decine di messaggi con allegati: estratti conto, ricevute, scontrini fotografati, "ti giro la fattura del telefono". Qualcuno — spesso la persona più esperta della segreteria, a volte un professionista — passa la mattina ad aprire, capire, rinominare, salvare nella cartella del cliente giusto, segnare le scadenze.

Il problema di questo studio non è che "non usa l'intelligenza artificiale". È che **annega in PEC e PDF** da smistare, e il tempo dei professionisti se ne va in lavoro che non richiede un professionista. Le proposte che arrivano allo studio, però, parlano quasi sempre d'altro: "un assistente AI che risponde ai clienti", "un ChatGPT per le domande fiscali". Strumenti che, nel migliore dei casi, non risolvono il problema vero; nel peggiore, toccano proprio la parte che deve restare al professionista.

Questo pezzo spiega come si fa l'**automazione di uno studio professionale**, commercialista, consulente del lavoro, agenzia di pratiche, partendo dalla PEC e dai documenti: cosa si può smistare in automatico, cosa non si tocca, come è fatto il flusso dall'arrivo al professionista, come si protegge la riservatezza dei clienti, perché il gestionale dello studio viene prima di qualsiasi chatbot, quanto costa rispetto a una segretaria part-time, e un piano di 60 giorni per uno studio da 3 a 10 persone.

## È per te / non è per te

È per te se:

- sei titolare o socio di uno studio professionale (commercialista, consulente del lavoro, CAF, agenzia di pratiche, consulente aziendale) con 3–10 persone;
- la PEC dello studio e le caselle email ricevono ogni giorno decine di documenti da smistare;
- le scadenze dei clienti vivono in un gestionale, in un foglio Excel e nella memoria delle persone;
- ti hanno proposto strumenti di AI e non sai da dove cominciare.

Non è per te se lo studio ha già un sistema documentale integrato che smista tutto e funziona: troverai cose che sai. E non è per te se cerchi un assistente che dia pareri fiscali ai clienti: questo pezzo spiega perché non è una buona idea.

## Cosa si può smistare (fatture, scadenze, richieste ripetute)

Il lavoro ripetitivo di uno studio, quello che si può automatizzare con buoni risultati, sta quasi tutto **ai bordi** dell'attività professionale: prima che il documento arrivi al professionista, e dopo che il professionista ha deciso.

**Prima del professionista (smistamento):**

- **PEC in arrivo**: riconoscere il mittente (Agenzia delle Entrate, INPS, INAIL, Camera di Commercio, tribunale, cliente, fornitore), il tipo di comunicazione (avviso, cartella, ricevuta, richiesta), il cliente a cui si riferisce (dal codice fiscale o dalla partita IVA nel testo o nell'allegato), e salvare il documento nella cartella giusta;
- **documenti dei clienti**: fatture, estratti conto, ricevute, scontrini inviati per email o caricati su un portale, classificati per cliente, tipo e periodo;
- **fatture passive dello studio**: lette dall'XML e registrate, come per qualsiasi azienda;
- **ricevute di consegna** degli invii fatti dallo studio, abbinate all'invio originale e archiviate.

**Dopo il professionista (esecuzione e promemoria):**

- **scadenze**: calcolo delle scadenze dei clienti a partire dalle regole e dai dati del gestionale, promemoria interni ai professionisti e promemoria ai clienti per i documenti da consegnare;
- **richieste ripetute ai clienti**: "ci mandi gli estratti conto del trimestre", "ci mandi le ricevute delle spese mediche", inviate in automatico con il modello giusto e il sollecito se non arrivano;
- **preparazione di pratiche ricorrenti**: raccolta dei documenti necessari, controllo di completezza, preparazione della bozza per il professionista;
- **comunicazioni standard**: conferma di ricezione dei documenti, avviso che la pratica è stata presentata, con i riferimenti.

In tutti questi casi l'automazione **prepara, smista, ricorda**. Non decide, non firma, non consiglia.

## Cosa non si tocca: parere, firma, SPID, responsabilità

Ci sono attività che restano del professionista, per legge, per deontologia e per buon senso.

- **Il parere.** Interpretare una norma, valutare la posizione di un cliente, decidere come impostare una dichiarazione o rispondere a un avviso: è il lavoro del professionista, ed è ciò per cui il cliente paga. Un modello di linguaggio può aiutare a cercare documenti o riassumere una circolare; non può dare il parere, né al cliente né al posto del professionista. La legge italiana sull'intelligenza artificiale lo dice chiaramente per le professioni intellettuali: l'AI può essere solo strumento di supporto, e il professionista deve informare il cliente del suo utilizzo.
- **La firma.** Dichiarazioni, istanze, deleghe, comunicazioni firmate digitalmente: la firma esprime la volontà e la responsabilità di chi firma. Non si delega a un sistema automatico.
- **SPID, CIE e le credenziali degli intermediari.** L'accesso ai portali della pubblica amministrazione con l'identità del professionista o le abilitazioni dello studio come intermediario è personale e tracciato. Un agente che entra con quelle credenziali crea un'attribuzione falsa. Ne ho scritto in dettaglio nel pezzo sui [limiti dell'agente con SPID e PEC]({{ '/it/blog/agente-ai-spid-pec-limiti/' | relative_url }}).
- **L'invio con effetti.** La risposta a un avviso, la presentazione di un'istanza, una comunicazione all'ente con valore legale: il sistema prepara il pacchetto, il professionista controlla e invia (o approva l'invio su quel pacchetto preciso).
- **La responsabilità verso il cliente.** Se una scadenza viene mancata, la responsabilità è dello studio, non del software. L'automazione deve rendere le scadenze più visibili, non spostare la responsabilità.

### Matrice automatizzabile / non automatizzabile

| Attività | Automatizzabile | Chi decide / controlla | Note |
|---|---|---|---|
| Riconoscere mittente e tipo di PEC | Sì | Revisione a campione | Regole sui mittenti + classificazione del testo |
| Associare la PEC al cliente | Sì, se c'è CF/P.IVA | Revisione se incerto | Mai "indovinare" il cliente dal nome |
| Salvare nella cartella del cliente | Sì | — | Nome file standard: cliente, tipo, data |
| Segnare la scadenza collegata | Sì, come proposta | Professionista conferma | Le scadenze calcolate vanno verificate |
| Abbinare ricevute di consegna agli invii | Sì | — | Deterministico |
| Registrare le fatture passive dello studio | Sì, dall'XML | Revisione dei casi particolari | Come in qualsiasi azienda |
| Classificare i documenti inviati dai clienti | Sì | Revisione a campione | Per cliente, tipo, periodo |
| Chiedere documenti ai clienti e sollecitarli | Sì | — | Modelli approvati dallo studio |
| Controllare la completezza di una pratica | Sì | Professionista | Checklist come file, non come prompt |
| Riassumere una comunicazione lunga dell'ente | Sì, come aiuto | Professionista legge l'originale | Il riassunto non sostituisce il documento |
| Interpretare l'avviso e decidere la risposta | **No** | Professionista | È il parere |
| Rispondere al cliente su questioni fiscali | **No** | Professionista | Nessun chatbot che dà pareri |
| Firmare dichiarazioni e istanze | **No** | Professionista | Firma = responsabilità |
| Accedere ai portali con SPID / abilitazioni | **No** | Professionista | Identità personale |
| Inviare comunicazioni con effetti legali | **No** in autonomia | Professionista invia o approva | Pacchetto preparato dal sistema |

## Flusso: arrivo → classifica → cartella → reminder → umano

Ecco il flusso tipo per la PEC dello studio, che è il punto da cui conviene partire perché è dove si perde più tempo.

### Il flusso PEC

```text
1. ARRIVO
   La casella PEC dello studio riceve il messaggio.
   Un servizio interno la legge (senza cancellare né spostare niente sul server PEC).
        │
        ▼
2. CLASSIFICA
   - Mittente: ente noto (AdE, INPS, INAIL, CCIAA, tribunale), cliente, fornitore, altro
   - Tipo: avviso / comunicazione / cartella / ricevuta / richiesta / fattura / newsletter
   - Cliente: cercato per codice fiscale o partita IVA nel testo e negli allegati
     → se trovato con certezza: associato
     → se non trovato o ambiguo: va in "da smistare" (umano)
        │
        ▼
3. CARTELLA
   Il messaggio completo (.eml) e gli allegati vengono salvati nella cartella del cliente,
   con nome standard: [cliente]_[tipo]_[ente]_[data].pdf
   e registrati nel gestionale dello studio (scheda cliente → documenti).
        │
        ▼
4. PROMEMORIA
   Se il tipo prevede una scadenza (es. avviso con termine di risposta):
   - il sistema PROPONE la scadenza calcolata
   - crea un'attività per il professionista responsabile del cliente
   - avvisa: "Nuovo avviso AdE per Rossi Srl, termine proposto: 20/01. Da verificare."
        │
        ▼
5. UMANO
   Il professionista apre l'attività, legge il documento originale,
   conferma o corregge la scadenza, decide cosa fare.
   Il sistema non risponde, non firma, non invia.
```

Due dettagli importanti:

- **La lettura della PEC non deve disturbare il server**: niente collegamenti ogni dieci secondi che fanno bloccare la casella dal gestore, niente cancellazioni. Le tecniche per ascoltare la PEC senza farsi limitare dal provider sono descritte nel pezzo sull'[agente che legge PEC e fatture]({{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}).
- **Il cliente si associa solo con un identificativo certo** (codice fiscale o partita IVA validati), mai dal nome: due clienti con lo stesso cognome sono la norma, non l'eccezione.

## Clienti e riservatezza

Uno studio professionale tratta i dati più riservati dei suoi clienti: redditi, patrimoni, debiti, situazioni familiari, salute (per le detrazioni), dipendenti. Qualsiasi automazione deve partire da qui.

- **Dove girano i dati.** Il servizio che legge la PEC, classifica e salva deve girare su infrastruttura dello studio o di un fornitore con contratto e dati in UE. Se usa un modello di linguaggio per classificare il testo, il modello deve essere locale o fornito con contratto, senza addestramento sui dati, preferibilmente in UE.
- **Niente ChatGPT personale.** Il collaboratore che incolla l'avviso dell'Agenzia delle Entrate del cliente su ChatGPT per "capire cosa vuole" sta trasferendo dati fiscali di un cliente a un servizio esterno senza garanzie. Serve uno strumento autorizzato, e regole chiare. Il quadro normativo è nel pezzo su [ChatGPT in azienda e la legge italiana]({{ '/it/blog/chatgpt-legale-in-azienda-italia/' | relative_url }}).
- **Permessi per cliente.** Non tutti nello studio devono vedere tutti i clienti. Se lo studio ha professionisti con portafogli distinti, i permessi delle cartelle e del gestionale vanno rispettati anche dall'automazione.
- **Informativa e lettera d'incarico.** Se lo studio usa strumenti di intelligenza artificiale nel lavoro sui documenti dei clienti, va detto: una clausola nella lettera d'incarico e nell'informativa privacy.
- **Conservazione.** I documenti dei clienti hanno tempi di conservazione precisi; l'automazione deve salvare nei posti giusti (gestionale, archivio a norma dove richiesto), non creare copie sparse.

## Strumenti: gestionale dello studio prima di un chatbot

La maggior parte degli studi ha già un **gestionale professionale** (per contabilità, dichiarazioni, paghe, scadenzario, archivio documenti). Molti di questi software hanno funzioni che lo studio non usa: importazione automatica delle fatture elettroniche dei clienti, scadenzario, archivio documentale, portale per i clienti, invio di richieste di documenti.

La regola è semplice: **prima si usa al massimo il gestionale, poi si aggiunge quello che manca**. Le domande da fare al fornitore del gestionale:

- importa in automatico le fatture elettroniche dei clienti dal canale dell'intermediario?
- ha uno scadenzario che genera attività per i professionisti e promemoria per i clienti?
- ha un archivio documentale per cliente, con possibilità di caricamento automatico?
- ha un portale clienti per lo scambio di documenti (al posto delle email)?
- ha un modo (API, cartelle monitorate, importazioni) per ricevere documenti da sistemi esterni?

Quello che di solito manca, e che si aggiunge con un'automazione esterna, è proprio il pezzo **PEC → classifica → gestionale**, perché la PEC dello studio riceve di tutto e il gestionale non sa leggerla. Un piccolo servizio interno (con uno strumento di automazione o un programma dedicato) fa da ponte. Un chatbot che risponde ai clienti, se mai, arriva molto dopo, e con confini molto stretti (orari, documenti da inviare, stato della pratica), mai sulle questioni professionali.

## Un caso concreto: uno studio di commercialisti con 7 persone

Tre professionisti, quattro collaboratori, circa 250 clienti tra società, ditte individuali e persone fisiche. La casella PEC dello studio riceve in media 70 messaggi al giorno, con picchi oltre i 150 nei periodi di scadenze. Una collaboratrice esperta passa circa 2–3 ore al giorno a smistare PEC e documenti dei clienti.

**La situazione di partenza.** Il gestionale dello studio ha uno scadenzario e un archivio documenti, usati a metà. I documenti dei clienti arrivano per email e vengono salvati a mano in cartelle sul server. Le scadenze collegate agli avvisi vengono segnate a mano nello scadenzario, quando qualcuno se ne ricorda.

**Cosa si è fatto in 60 giorni.** Primo mese: attivate le funzioni del gestionale che non si usavano (importazione automatica delle fatture elettroniche dei clienti, portale clienti per l'invio dei documenti al posto dell'email). Secondo mese: un servizio interno, su un server dello studio, che legge la PEC, classifica mittente e tipo con regole e un modello locale per i testi non standard, associa il cliente tramite codice fiscale o partita IVA, salva il messaggio completo e gli allegati nell'archivio del gestionale e propone le scadenze come attività per il professionista. I messaggi incerti vanno in una coda "da smistare".

**Dopo tre mesi.** Circa l'80% delle PEC viene smistato in automatico; il 20% finisce nella coda (soprattutto comunicazioni con clienti non identificabili o mittenti nuovi). La collaboratrice passa 30–45 minuti al giorno sulla coda invece di 2–3 ore, e il tempo recuperato va sulle pratiche. Nessuna scadenza da avviso persa nel trimestre, perché ogni avviso genera un'attività per il professionista responsabile, con la scadenza proposta da confermare.

### Stima dei tempi

| Attività | Prima (al giorno) | Dopo (al giorno) | Note |
|---|---|---|---|
| Smistamento PEC | 1,5–2 ore | 20–30 minuti | Solo la coda dei casi incerti |
| Salvataggio documenti dei clienti | 45–60 minuti | 10–15 minuti | Portale clienti + classificazione |
| Inserimento scadenze da avvisi | 20–30 minuti | 5–10 minuti | Conferma delle scadenze proposte |
| Richieste di documenti e solleciti | 20–30 minuti | 5 minuti | Modelli e solleciti automatici |
| **Totale** | **3–4 ore** | **40–60 minuti** | Per uno studio di 6–8 persone |

(Stime indicative, variano con il numero di clienti e il tipo di attività dello studio.)

## Costi vs una segretaria part-time (stime oneste)

| Voce | Stima | Note |
|---|---|---|
| Attivazione funzioni del gestionale (portale clienti, importazioni) | 0–2.000 € + eventuale canone | Dipende dal gestionale; spesso è già incluso |
| Servizio PEC → classifica → gestionale | 4.000–12.000 € di setup | Su server dello studio o UE; dipende dalle integrazioni del gestionale |
| Server o infrastruttura | 0–60 €/mese | Spesso basta il server già presente o un piccolo server UE |
| Modello locale per la classificazione dei testi | incluso nel server o 20–80 €/mese | Solo per i testi non standard |
| Manutenzione | 0,5–1 giorno al mese | Nuovi mittenti, nuovi tipi di documento, aggiornamenti |
| **Confronto: segretaria part-time aggiuntiva** | 900–1.400 €/mese | Indicativo per 20 ore a settimana |

Il confronto onesto: per uno studio di 6–8 persone che sta pensando di assumere qualcuno per lo smistamento, l'automazione costa meno nel primo anno e molto meno negli anni successivi. Ma non sostituisce le persone dello studio: libera la collaboratrice esperta dallo smistamento e la riporta sul lavoro in cui serve la sua esperienza. Per uno studio di 3 persone con poche PEC al giorno, l'investimento si ripaga solo se attivi prima le funzioni del gestionale, che costano poco o niente.

## Piano 60 giorni per uno studio da 3–10 persone

### Giorni 1–30: gestionale e ordine

- **Settimana 1**: contare PEC e documenti per tipo per una settimana; elenco dei mittenti più frequenti; tempo speso oggi nello smistamento.
- **Settimana 2**: incontro con il fornitore del gestionale per attivare quello che c'è già (importazioni, portale clienti, scadenzario, archivio).
- **Settimana 3**: regole di nomina dei file e struttura delle cartelle per cliente, uguali per tutti; regole d'uso degli strumenti di AI scritte e condivise (niente account personali con documenti dei clienti).
- **Settimana 4**: avvio del portale clienti per l'invio dei documenti; comunicazione ai clienti con istruzioni semplici.

### Giorni 31–60: automazione della PEC

- **Settimana 5**: installazione del servizio di lettura PEC su infrastruttura dello studio o UE, in modalità "solo osservazione": classifica e propone, ma non salva.
- **Settimana 6**: confronto tra le proposte del sistema e lo smistamento manuale; correzione delle regole sui mittenti e sui tipi.
- **Settimana 7**: attivazione del salvataggio automatico per i casi certi; coda "da smistare" per gli incerti; proposte di scadenza come attività per i professionisti.
- **Settimana 8**: misura dei tempi; aggiornamento della lettera d'incarico e dell'informativa sull'uso degli strumenti; decisione sui passi successivi (solleciti automatici, controllo di completezza delle pratiche).

## Cosa si rompe dopo qualche mese

Anche uno smistamento ben impostato peggiora se nessuno lo guarda. I segnali tipici in uno studio:

- **Nuovi mittenti e nuovi formati.** Un ente cambia il formato delle sue comunicazioni, o arriva un mittente mai visto prima (un nuovo ente, una nuova piattaforma). Il sistema non lo riconosce e i messaggi finiscono in coda. Non è un guasto: è il segnale che una regola va aggiunta. Rimedio: una volta al mese si guardano i mittenti più frequenti nella coda.
- **La coda "da smistare" cresce.** Se passa dal 20% al 35% dei messaggi, qualcosa è cambiato: un nuovo tipo di comunicazione, clienti nuovi non ancora in anagrafica con codice fiscale, allegati in un formato diverso. Rimedio: guardare il motivo più frequente e correggerlo.
- **Le scadenze proposte non vengono confermate.** Le attività si accumulano nello scadenzario del professionista senza conferma, perché "tanto le vedo dopo". È il rischio più serio: una scadenza proposta e mai confermata non è una scadenza gestita. Rimedio: un riepilogo settimanale delle scadenze non confermate al titolare dello studio.
- **La casella PEC si riempie.** Lo smistamento salva i documenti nell'archivio, ma la casella PEC sul server del gestore continua a crescere fino al limite di spazio, e a quel punto i messaggi in arrivo vengono rifiutati. Rimedio: una regola di archiviazione della casella, dopo che i messaggi sono stati salvati e verificati.
- **I clienti tornano all'email.** Dopo qualche mese, alcuni clienti ricominciano a mandare documenti via email invece che dal portale. Rimedio: una risposta automatica cortese che ricorda il portale, e un controllo che i documenti arrivati per email vengano comunque classificati.

Mezz'ora al mese della collaboratrice esperta su questi punti mantiene lo smistamento affidabile.

## 3 errori da principiante che costano tempo o clienti

**1. Partire dal chatbot per i clienti.** È la proposta più visibile e la meno utile: un assistente che risponde alle domande dei clienti rischia di dare pareri che spettano al professionista, e non toglie nulla del lavoro di smistamento che pesa davvero. Si parte dalla PEC.

**2. Associare i documenti al cliente dal nome.** "Rossi" in uno studio con 250 clienti significa tre o quattro clienti diversi. L'associazione si fa con codice fiscale o partita IVA validati; se mancano, il documento va in coda, non nella cartella più probabile.

**3. Lasciare che il sistema confermi le scadenze da solo.** Una scadenza calcolata male da un avviso non letto da un professionista è una responsabilità dello studio. Il sistema propone, il professionista conferma: è una regola, non un'opzione.

## Quando NON farlo

- **Quando le PEC sono poche** (una decina al giorno): le funzioni del gestionale e un po' di ordine bastano.
- **Quando il gestionale sta per essere cambiato**: prima si sceglie il nuovo, poi si automatizza intorno a quello.
- **Quando nessuno nello studio può seguire il progetto**: serve almeno una persona (anche la collaboratrice esperta) che controlli la coda e segnali i casi da correggere.
- **Quando lo studio vuole uno strumento che "risponda ai clienti al posto nostro"**: è l'obiettivo sbagliato, e ha rischi professionali e deontologici.

## Checklist pratica

- [ ] Ho contato PEC e documenti per tipo e il tempo speso a smistarli.
- [ ] Ho attivato le funzioni del gestionale che non usavamo (importazioni, portale clienti, scadenzario).
- [ ] Le cartelle e i nomi dei file seguono regole uguali per tutti.
- [ ] Il servizio di lettura PEC gira su infrastruttura dello studio o UE, con contratto se esterno.
- [ ] Il cliente viene associato solo con codice fiscale o partita IVA; i casi incerti vanno in coda.
- [ ] Le scadenze vengono proposte come attività e confermate dal professionista.
- [ ] Il sistema non risponde ai clienti su questioni professionali, non firma, non accede ai portali, non invia comunicazioni con effetti.
- [ ] Nessun collaboratore usa account personali di AI con documenti dei clienti.
- [ ] Lettera d'incarico e informativa citano l'uso di strumenti di AI.
- [ ] A 60 giorni ho misurato il tempo risparmiato e le scadenze gestite.

## Il verdetto

L'**automazione di uno studio professionale** non comincia da un'intelligenza artificiale che risponde ai clienti. Comincia dalla PEC e dai documenti: riconoscere chi scrive e cosa manda, associarlo al cliente giusto con un identificativo certo, salvarlo nel posto giusto, proporre la scadenza al professionista. È lavoro di bordo, ripetitivo, che oggi consuma ore delle persone più esperte dello studio.

Il cuore del lavoro — il parere, la firma, l'accesso ai portali, la responsabilità verso il cliente — resta del professionista, e deve restarci. Fatta così, l'automazione non sostituisce nessuno: restituisce allo studio le ore che oggi vanno nello smistamento, con i dati dei clienti che restano dove devono stare.

Se vuoi impostare l'automazione della PEC e dei documenti nel tuo studio, partendo dal gestionale che hai già, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su integrazioni e sistemi self-hosted sono nella guida su [integrazioni e sistemi self-hosted]({{ '/it/pillar/integrazioni-selfhosted/' | relative_url }}).

## FAQ

### Cosa si può automatizzare in uno studio commercialista?

Lo smistamento della PEC (mittente, tipo di comunicazione, cliente), il salvataggio dei documenti nelle cartelle dei clienti, l'importazione delle fatture elettroniche, la proposta delle scadenze collegate agli avvisi, le richieste di documenti ai clienti con solleciti, il controllo di completezza delle pratiche e le comunicazioni standard di conferma.

### Cosa non deve essere automatizzato in uno studio professionale?

Il parere professionale, la firma di dichiarazioni e istanze, l'accesso ai portali con SPID o con le abilitazioni dello studio, l'invio autonomo di comunicazioni con effetti legali e le risposte ai clienti su questioni fiscali o di lavoro. Sono attività che restano del professionista per legge e per deontologia.

### Come si automatizza lo smistamento della PEC?

Con un servizio che legge la casella senza modificarla, riconosce mittente e tipo di comunicazione con regole e, dove serve, un modello di linguaggio locale, associa il cliente tramite codice fiscale o partita IVA, salva messaggio e allegati nell'archivio del cliente e propone eventuali scadenze come attività per il professionista. I casi incerti finiscono in una coda per una persona.

### Si può usare ChatGPT per leggere gli avvisi dell'Agenzia delle Entrate dei clienti?

Non con account personali: significherebbe trasferire dati fiscali dei clienti a un servizio esterno senza garanzie. Si può usare uno strumento autorizzato dallo studio, con contratto, senza addestramento sui dati e preferibilmente in UE, come aiuto alla lettura. L'interpretazione resta del professionista.

### Lo studio deve dire ai clienti che usa l'intelligenza artificiale?

Sì. La legge italiana sull'intelligenza artificiale prevede che il professionista informi il cliente dell'uso di sistemi di AI, che possono essere solo di supporto all'attività intellettuale. Una clausola nella lettera d'incarico e nell'informativa privacy è il modo più semplice.

### Meglio un gestionale nuovo o un'automazione esterna?

Prima si usano al massimo le funzioni del gestionale che lo studio ha già: importazioni automatiche, portale clienti, scadenzario, archivio. L'automazione esterna serve per quello che il gestionale non fa, di solito il collegamento tra la PEC dello studio e l'archivio dei clienti.

### Quanto tempo si risparmia automatizzando la PEC?

Per uno studio di 6–8 persone con qualche decina di PEC al giorno, lo smistamento può scendere da 3–4 ore al giorno a 40–60 minuti, dedicati alla coda dei casi incerti. Le stime variano con il numero di clienti e il tipo di attività.

### Quanto costa automatizzare uno studio professionale?

Indicativamente da 4.000 a 12.000 euro di setup per il servizio di smistamento della PEC collegato al gestionale, più costi di infrastruttura contenuti e mezza giornata o una giornata al mese di manutenzione. L'attivazione delle funzioni già presenti nel gestionale spesso costa poco o niente.

### Come si evita di salvare un documento nella cartella del cliente sbagliato?

Associando il documento al cliente solo tramite codice fiscale o partita IVA validati, presenti nel testo o negli allegati. Se l'identificativo manca o corrisponde a più clienti, il documento va in una coda per una persona, invece che nella cartella più probabile.

### Un chatbot per i clienti dello studio è una buona idea?

Raramente come primo passo. Rischia di dare indicazioni che spettano al professionista e non riduce il lavoro di smistamento. Se si introduce, deve avere confini molto stretti: orari, documenti da inviare, stato della pratica, mai risposte su questioni fiscali o di lavoro.
