---
lang: it
permalink: /it/blog/microsoft-365-vs-self-hosted-costi/
alt_url: /en/blog/microsoft-365-vs-self-hosted-cost/
title: "Microsoft 365 vs stack self-hosted: quanto spendi in 3 anni (licenze, lock-in, e l'uscita che nessuno calcola)"
date: 2026-12-21 07:30:00 +0200
author: "Antonio Trento"
description: "Per titolari e responsabili amministrativi: il costo vero di Microsoft 365 su 36 mesi contro uno stack self-hosted, con add-on (Copilot, archiviazione, backup), costi nascosti, cosa significa self-hosted per email, file e identità, quanto costa uscire da 365, una tabella per 10, 25 e 80 utenti, la via ibrida e quando 365 resta la scelta giusta."
keywords: ["microsoft 365 vs self hosted costi", "costo microsoft 365 pmi", "vendor lock-in office 365", "alternativa self hosted email", "nextcloud vs sharepoint", "tco microsoft 365"]
image: /assets/images/posts/microsoft-365-vs-self-hosted-costi.jpg
pillar: integrazioni-selfhosted
related: [/it/blog/docker-pmi-stack-sovrano/, /it/blog/n8n-vs-zapier-vs-make-costi/]
---

## La licenza che "è solo 12 euro" per 20 persone

La conversazione inizia sempre con un numero piccolo. "Microsoft 365 costa una dozzina di euro al mese a persona, è niente." Per 20 persone sono circa 240 euro al mese, meno di 3.000 euro l'anno. Effettivamente non è tanto, per avere posta, documenti, archiviazione, videochiamate e una suite d'ufficio che tutti sanno usare.

Poi arrivano le altre voci. Il backup, perché quello incluso non basta a proteggere da cancellazioni e ransomware. La sicurezza avanzata, perché qualcuno ha cliccato su un link di phishing. Lo spazio in più. Copilot, perché il direttore commerciale l'ha visto in una presentazione. E il tempo: chi gestisce gli account, i permessi di SharePoint, le cartelle condivise che nessuno capisce più. Dopo tre anni, il "solo 12 euro" è diventato una cifra molto diversa. E soprattutto, tutti i documenti dell'azienda, tutte le email e tutte le identità stanno in un unico posto da cui uscire è complicato.

Questo pezzo fa i conti di **Microsoft 365 contro uno stack self-hosted** su tre anni, senza guerre ideologiche. Per un titolare o un responsabile amministrativo che vuole sapere quanto spende davvero, quanto è legato al fornitore, e quanto costerebbe andarsene. Con una tabella per 10, 25 e 80 utenti, una strada ibrida che spesso è la più sensata, e i casi in cui 365 resta, onestamente, la scelta giusta.

## È per te / non è per te

È per te se:

- la tua azienda usa Microsoft 365 (o sta per adottarlo) e vuoi capire il costo vero su più anni;
- ti preoccupa la dipendenza da un unico fornitore per email, documenti e accessi;
- stai valutando Copilot e il conto ti sembra alto;
- qualcuno ti ha proposto di "portare tutto in casa" e vuoi numeri prima di decidere.

Non è per te se cerchi una guida tecnica all'installazione di alternative open source: qui parliamo di costi e decisioni. E non è per te se la tua azienda è di 3 persone con una casella email a testa: per voi la risposta è quasi certamente "restate su una suite in cloud e non pensateci troppo".

## Cosa è incluso e cosa diventa add-on (Copilot, storage, backup)

Microsoft 365 per le aziende si vende in piani di livello crescente (in genere Basic, Standard, Premium per le piccole e medie imprese, più i piani Enterprise). I prezzi cambiano periodicamente — negli ultimi anni sono saliti — e dipendono da impegno annuale o mensile: considera **da circa 6 a circa 25 € per utente al mese** per i piani business, e verifica il listino in vigore.

### Cosa trovi di solito nei piani business

- **Email** con caselle di dimensione generosa e calendario condiviso;
- **archiviazione dei file** (OneDrive personale e SharePoint per i siti condivisi);
- **Teams** per chat e videochiamate;
- **applicazioni d'ufficio** web e mobili, e nei piani più alti anche quelle desktop;
- **identità** (gli account, il login unico per le app Microsoft);
- nei piani più alti, **funzioni di sicurezza e gestione dei dispositivi** più avanzate.

### Elenco degli add-on tipici

Ecco le voci che più spesso si aggiungono nel tempo, e che vanno messe nel conto fin dall'inizio:

1. **Copilot**: l'assistente AI integrato nella suite, venduto come componente aggiuntivo per utente (nell'ordine di **qualche decina di euro per utente al mese**, con offerte e pacchetti che cambiano). Spesso costa più della licenza di base.
2. **Backup di terze parti**: la suite conserva i dati e ha funzioni di recupero, ma non è pensata come backup indipendente a lungo termine contro cancellazioni, ransomware o errori di amministrazione. Molte aziende aggiungono un servizio di backup esterno, **1–4 € per utente al mese**.
3. **Sicurezza avanzata**: protezione dalle minacce, prevenzione della perdita di dati, accesso condizionato. Inclusa nei piani più alti, a pagamento come aggiunta in quelli più bassi.
4. **Archiviazione aggiuntiva**: spazio SharePoint extra quando lo spazio incluso finisce, archiviazione delle caselle.
5. **Telefonia** (Teams Phone) e **sale riunioni**, se servono.
6. **Licenze per le caselle condivise o speciali**, in certi casi.
7. **Strumenti di terze parti** per firme email, archiviazione a norma, gestione delle stampanti: spesso piccoli abbonamenti che si sommano.

Il punto non è che gli add-on siano inutili: molti servono davvero. Il punto è che **il prezzo di partenza non è il prezzo a regime**.

## Costo nascosto: tempo, integrazioni, "tanto è già lì"

Oltre alle licenze, ci sono costi che non compaiono in nessuna fattura.

**Il tempo di amministrazione.** Creare e chiudere account, gestire licenze, gruppi, permessi di SharePoint e Teams, dispositivi, criteri di sicurezza. In una PMI senza IT, lo fa spesso un fornitore esterno a ore o un collaboratore interno "bravo con i computer". In ogni caso costa. E la complessità cresce: dopo tre anni, la struttura dei siti SharePoint e dei team è spesso un labirinto che nessuno sa più spiegare.

**L'effetto "tanto è già lì".** Siccome Teams, SharePoint, Forms, Power Automate e gli altri strumenti sono inclusi, vengono usati anche dove non sono la scelta migliore: un processo aziendale costruito su un foglio di calcolo condiviso e qualche flusso automatico fragile, un archivio documentale costruito su cartelle SharePoint senza regole. Funziona, finché non serve integrarlo con il gestionale o spostarlo. Il costo arriva dopo, sotto forma di lavoro per sistemare.

**Le integrazioni.** Collegare la suite al gestionale, al CRM, al sito, ai sistemi di produzione richiede lavoro. Nell'ecosistema Microsoft è spesso semplice per le cose standard e complicato per quelle specifiche delle aziende italiane (gestionali locali, fatturazione elettronica, PEC).

**La dipendenza.** Email, documenti, identità, chat, telefonia nello stesso posto significa che una decisione del fornitore (un aumento di prezzo, un cambio di licenza, un'interruzione) riguarda tutta l'azienda contemporaneamente. Non è un costo che si paga ogni mese: è un rischio che si accumula.

## Self-hosted: email, file, identità — pezzi, non un mostro unico

"Portare tutto in casa" spaventa, e a ragione, se lo si immagina come un unico enorme sistema da sostituire. In realtà lo stack self-hosted (o "sovrano", su infrastruttura europea sotto il tuo controllo) è fatto di **pezzi indipendenti**, che si possono scegliere uno alla volta.

**Email.** È il pezzo più delicato. Gestire in proprio un server di posta è possibile, ma la consegna dei messaggi (non finire nello spam dei destinatari), la sicurezza e l'affidabilità richiedono competenze specifiche. Per la maggior parte delle PMI la scelta sensata non è un server di posta in ufficio, ma un **fornitore di posta europeo** con contratto, o una soluzione gestita da un partner. "Self-hosted" qui significa "sotto il tuo controllo contrattuale e geografico", non necessariamente "su un server tuo".

**File e collaborazione.** Soluzioni come Nextcloud (con suite d'ufficio integrate come Collabora o OnlyOffice) offrono archiviazione, condivisione, modifica dei documenti nel browser, calendari. Possono girare su un server in ufficio, su un server in un datacenter italiano o presso un fornitore europeo che le gestisce.

**Identità.** Un sistema di login unico (come Keycloak o Authentik) che gestisce gli account per tutte le applicazioni: quando una persona entra o esce dall'azienda, si attiva o disattiva in un solo posto.

**Chat e videochiamate.** Esistono alternative self-hosted o europee (Matrix, Mattermost, Jitsi e altre). Funzionano, ma sono il pezzo dove gli utenti notano di più la differenza rispetto a Teams.

**Suite d'ufficio.** Le alternative (LibreOffice in locale, le suite web integrate nei sistemi di file) coprono bene il lavoro quotidiano; la compatibilità con file complessi di Word ed Excel, macro e modelli aziendali è il punto da verificare con i documenti veri dell'azienda.

Il principio, che ho descritto nel pezzo sullo [stack Docker sovrano per le PMI]({{ '/it/blog/docker-pmi-stack-sovrano/' | relative_url }}): **non serve sostituire tutto**. Si può scegliere il pezzo dove il controllo conta di più e lasciare il resto dov'è.

## Uscita da 365: quanto costa davvero (mailbox, SharePoint, Teams)

È il costo che nessuno calcola quando entra, e che decide quanto sei libero dopo. Uscire da Microsoft 365 significa spostare quattro cose, con difficoltà molto diverse.

**1. Le caselle email.** Migrare le caselle (messaggi, cartelle, calendari, contatti) verso un altro fornitore è un'operazione nota, con strumenti dedicati. Costa nell'ordine di **qualche decina di euro per casella** tra strumenti e lavoro, più la pianificazione del passaggio (record DNS, periodo di convivenza). Per 25 caselle, qualche migliaio di euro.

**2. I file di OneDrive e SharePoint.** Copiare i file è facile; ricostruire la struttura, i permessi e le condivisioni no. Dopo anni, SharePoint contiene siti, librerie, versioni, metadati e link condivisi che puntano a URL Microsoft. La migrazione richiede di decidere cosa portare, come riorganizzarlo, come rifare i permessi. È il pezzo più costoso in tempo: da **alcuni giorni a qualche settimana** di lavoro secondo la quantità e il disordine.

**3. Teams.** Le chat e le conversazioni nei canali sono le più difficili da esportare in una forma utilizzabile. Nella pratica, quasi sempre si archiviano (per obblighi di conservazione) e si riparte da zero sulla nuova piattaforma. Il costo vero è nel cambio di abitudini.

**4. Identità e integrazioni.** Tutte le applicazioni che usano il login Microsoft (gestionale, CRM, strumenti di terze parti) vanno ricollegate a un nuovo sistema di identità. Ogni integrazione è un piccolo progetto.

A questo si aggiungono **formazione** e **produttività persa** nelle prime settimane. Una stima onesta per un'azienda di 25 persone che esce completamente da 365: **15.000–40.000 € tra lavoro e tempo**, molto variabili con il disordine accumulato. È il motivo per cui conviene calcolare l'uscita **prima** di entrare, e mantenere ordine e regole durante.

## Tabella 10 / 25 / 80 utenti su 36 mesi (stime)

Ecco un confronto su tre anni, con ipotesi dichiarate. Sono **stime**: usa i listini in vigore e il costo del lavoro del tuo fornitore.

**Ipotesi:**

- Microsoft 365 a circa 12 € per utente al mese (piano business intermedio), backup esterno 2 € per utente al mese, amministrazione esterna a 400 € al giorno;
- Copilot indicato a parte, per una quota di utenti, a circa 30 € per utente al mese;
- stack self-hosted: email presso fornitore europeo (3 € per casella al mese), file e collaborazione e identità su server UE gestito, con setup iniziale e manutenzione;
- non sono inclusi i costi di uscita da 365 (vedi sopra), da aggiungere nello scenario self-hosted se si parte da 365.

| Voce (36 mesi, stime) | 365 — 10 utenti | Self-hosted — 10 utenti | 365 — 25 utenti | Self-hosted — 25 utenti | 365 — 80 utenti | Self-hosted — 80 utenti |
|---|---|---|---|---|---|---|
| Licenze / abbonamenti | 4.300 € | 1.100 € (email UE) | 10.800 € | 2.700 € | 34.600 € | 8.600 € |
| Backup | 700 € | incluso nel server | 1.800 € | incluso nel server | 5.800 € | incluso nel server |
| Infrastruttura (server UE, storage) | — | 1.400 € | — | 2.900 € | — | 7.200 € |
| Setup iniziale | 500 € | 6.000 € | 1.000 € | 10.000 € | 2.000 € | 20.000 € |
| Amministrazione / manutenzione | 2.400 € | 7.200 € | 4.800 € | 14.400 € | 9.600 € | 28.800 € |
| **Totale 36 mesi** | **7.900 €** | **15.700 €** | **18.400 €** | **30.000 €** | **52.000 €** | **64.600 €** |
| Copilot per il 30% degli utenti | +3.200 € | — | +8.100 € | — | +25.900 € | — |
| AI interna equivalente (se serve) | — | +4.000–8.000 € | — | +8.000–15.000 € | — | +15.000–30.000 € |

Cosa dice la tabella, senza girarci intorno:

- **Per 10 e 25 utenti, Microsoft 365 costa meno** di uno stack self-hosted completo, anche su tre anni. Il self-hosted completo, a queste dimensioni, si giustifica solo con motivi di controllo dei dati, non di risparmio.
- **A 80 utenti la distanza si riduce**: con Copilot su un terzo degli utenti, il totale di 365 si avvicina a quello di uno stack self-hosted con un'AI interna. A quel punto il costo non decide più: decidono il controllo dei dati e le competenze che hai a disposizione.
- **La manutenzione è la voce che decide.** Il self-hosted non costa in licenze, costa in persone. Se hai già qualcuno (interno o partner) che gestisce l'infrastruttura, il conto cambia molto.
- **Il costo di uscita** va aggiunto al self-hosted se si parte da 365: per questo la migrazione completa conviene raramente per motivi solo economici.

## Ibrido: tieni 365, tira fuori i dati critici

Per la maggior parte delle PMI, la risposta non è "365 sì" o "365 no". È **ibrido**: si tiene la suite per quello che fa bene (email, calendario, documenti d'ufficio, videochiamate) e si tirano fuori, o si tengono fuori, i dati e i processi critici.

### Criteri per l'ibrido

Un dato o un processo merita di stare fuori da 365, sotto il tuo controllo diretto, quando:

- **è il cuore dell'azienda**: archivio progetti, documentazione tecnica, contratti, dati dei clienti che sono il vero patrimonio;
- **ha obblighi specifici**: conservazione a norma, dati sanitari, dati di minori, segreti industriali con clausole contrattuali;
- **deve integrarsi con sistemi non Microsoft**: gestionale, produzione, sistemi italiani (fatturazione elettronica, PEC);
- **rischia il lock-in**: processi costruiti su strumenti della suite che sarebbero costosi da ricostruire altrove;
- **ha bisogno di AI sui dati**: se vuoi un assistente sui documenti aziendali con i dati in casa, ha senso che quei documenti stiano su un sistema che controlli, come descritto nel pezzo sul [ChatGPT interno per la PMI]({{ '/it/blog/chatgpt-interno-azienda-self-hosted/' | relative_url }}).

E un dato può restare tranquillamente in 365 quando:

- è **lavoro quotidiano** che cambia spesso (bozze, documenti di lavoro, presentazioni);
- è **comunicazione** (email, calendario, chat);
- **non ha requisiti particolari** di conservazione o integrazione.

Tre regole che rendono l'ibrido sostenibile:

1. **Backup indipendente** di quello che resta in 365, su un sistema non Microsoft.
2. **Regole d'ordine** su SharePoint e Teams fin da subito (chi crea siti, come si chiamano, chi è il responsabile), così che un'eventuale uscita futura non sia un'archeologia.
3. **Identità sotto controllo**: anche se usi gli account Microsoft, documenta quali applicazioni ne dipendono.

## Un caso concreto: uno studio tecnico con 25 persone

Uno studio di progettazione con 25 persone, su Microsoft 365 da cinque anni. Spesa annua in licenze circa 3.600 €, più un fornitore esterno per l'amministrazione. Proposta del rivenditore: passare al piano superiore per la sicurezza e aggiungere Copilot per tutti, con un aumento di circa il triplo.

**L'analisi.** Le email, i calendari e Teams funzionano bene e le persone sono abituate: non c'è motivo di cambiarli. Il problema vero è l'archivio dei progetti: 2 TB di disegni, relazioni e documenti su SharePoint, con una struttura cresciuta senza regole, permessi incoerenti, e la richiesta di alcuni clienti (enti pubblici, grandi committenti) di garanzie precise su dove stanno i loro documenti. In più, l'interesse per l'AI riguarda soprattutto "cercare nei progetti passati".

**La scelta.** Ibrido. Email, calendari, Teams e documenti di lavoro restano su 365, sul piano attuale con un'aggiunta di sicurezza per le funzioni davvero necessarie. L'archivio dei progetti chiusi si sposta su un sistema di file su server europeo dello studio, con struttura per commessa e permessi per gruppo, backup indipendente. Sopra l'archivio, un assistente che cerca nei progetti passati citando le fonti, con il modello su infrastruttura europea. Copilot viene attivato per 5 persone (direzione e amministrazione), non per 25.

**Il risultato.** Spesa annua cresciuta molto meno della proposta iniziale, archivio dei progetti finalmente ordinato e sotto controllo, risposte chiare ai clienti sulla localizzazione dei documenti, e una via d'uscita da 365 molto più semplice se un giorno servirà.

## Cosa si rompe dopo qualche anno (con l'una e con l'altra strada)

Sia Microsoft 365 sia uno stack self-hosted invecchiano male se nessuno li cura. I problemi tipici, per onestà, da entrambe le parti.

**Con Microsoft 365:**

- **SharePoint e Teams diventano un labirinto.** Ogni progetto ha creato un team, ogni team ha un sito, i permessi sono stati dati "a mano" per anni. Dopo tre anni nessuno sa chi vede cosa. Rimedio: regole su chi crea team e siti, revisione annuale dei permessi, archiviazione dei team chiusi.
- **Le licenze non seguono le persone.** Licenze attive per persone che hanno lasciato l'azienda, piani alti assegnati a chi usa solo la posta. Rimedio: revisione trimestrale delle licenze, collegata alle entrate e uscite del personale.
- **Il prezzo cambia.** Gli aumenti di listino e i cambi di pacchetto arrivano con poco preavviso e riguardano tutti gli utenti insieme. Rimedio: tenere aggiornata la stima del costo a tre anni e del costo di uscita, per avere sempre un'alternativa misurata.

**Con uno stack self-hosted:**

- **Gli aggiornamenti si rimandano.** Il sistema funziona e nessuno vuole toccarlo; dopo un anno è indietro di diverse versioni, con problemi di sicurezza noti. Rimedio: aggiornamenti in calendario, con un ambiente di prova.
- **Il backup non viene provato.** Esiste, gira ogni notte, ma nessuno ha mai provato a ripristinarlo. Il giorno che serve, manca un pezzo. Rimedio: una prova di ripristino ogni tre mesi.
- **La persona che sapeva se ne va.** Il sistema è stato costruito da un tecnico o da un partner che ora non c'è più, e la documentazione è scarsa. Rimedio: documentazione minima obbligatoria e almeno due persone (o un contratto) che sanno gestirlo.
- **Gli utenti trovano scorciatoie.** Se la nuova soluzione per i file è meno comoda, le persone tornano a mandarsi allegati via email o a usare servizi personali. Rimedio: chiedere agli utenti cosa non funziona nelle prime settimane, e sistemarlo.

La morale è la stessa: nessuna delle due strade è "installa e dimentica". Il costo di cura va messo nel conto in entrambi i casi.

## Quando 365 resta la scelta giusta

Va detto chiaramente, perché c'è molta retorica in giro:

- **Aziende piccole** (sotto le 15–20 persone) senza IT: la suite in cloud costa poco, funziona bene e non richiede di gestire server. Il controllo si ottiene con un buon backup esterno e un po' di ordine.
- **Aziende che lavorano molto con clienti e fornitori su Microsoft**: scambio di documenti complessi, riunioni su Teams, condivisioni frequenti. La compatibilità vale molto.
- **Aziende senza nessuno che possa gestire un'infrastruttura**, né interno né partner affidabile: il self-hosted senza manutenzione è un rischio maggiore della dipendenza da un fornitore.
- **Quando i dati critici non ci sono**: se l'azienda non ha un patrimonio documentale particolare o obblighi specifici, il vantaggio del controllo è piccolo.

In questi casi, la mossa giusta non è uscire: è **usare bene** la suite, con backup indipendente, regole d'ordine, licenze adeguate (non quella più alta per tutti) e add-on scelti per chi ne ha davvero bisogno.

## Percorso 30/60/90 giorni

**Primi 30 giorni — fotografia**

- elenco delle licenze attive, dei piani, degli add-on e dei costi reali degli ultimi 12 mesi;
- elenco di cosa c'è in SharePoint e Teams, e di quali applicazioni usano il login Microsoft;
- verifica del backup: c'è un backup indipendente? è mai stato provato un ripristino?

**Da 30 a 60 giorni — ottimizzazione**

- licenze giuste per le persone giuste (non tutti hanno bisogno del piano più alto);
- add-on solo per chi li usa (Copilot su un gruppo pilota, non per tutti);
- backup indipendente attivo;
- regole d'ordine su siti e team.

**Da 60 a 90 giorni — decisione sull'ibrido**

- identificare i dati critici secondo i criteri sopra;
- se servono, progettare lo spostamento di quei dati su un sistema sotto il tuo controllo;
- calcolare il costo di uscita per avere un numero vero, anche se non hai intenzione di uscire.

## 3 errori da principiante che costano soldi

**1. Comprare Copilot per tutti.** Un componente aggiuntivo che costa più della licenza di base, attivato per tutta l'azienda "per vedere". Dopo tre mesi lo usa davvero un terzo delle persone. Si parte da un gruppo pilota, si misura l'uso, si estende solo dove serve.

**2. Considerare il backup "incluso".** Le funzioni di recupero della suite non sono un backup indipendente. Il giorno in cui un account amministratore viene compromesso, o un ransomware cifra i file sincronizzati, o qualcuno cancella per errore un sito, la differenza tra avere e non avere un backup esterno è la differenza tra un giorno di lavoro e un disastro.

**3. Migrare tutto fuori per risparmiare.** Con 10 o 25 persone, uscire completamente da 365 per motivi economici quasi sempre non conviene: il costo di uscita e la manutenzione superano il risparmio sulle licenze. Si esce per motivi di controllo, su pezzi specifici, non per principio.

## Quando NON farlo (la migrazione completa)

- quando l'azienda è piccola e senza nessuno che gestisca un'infrastruttura;
- quando il motivo è solo il costo delle licenze, senza aver calcolato manutenzione e uscita;
- quando il lavoro quotidiano dipende da scambi intensi con clienti e fornitori su Microsoft;
- quando si è nel mezzo di altri cambiamenti grossi (gestionale, organizzazione, sede).

## Checklist pratica

- [ ] Conosco il costo reale di 365 degli ultimi 12 mesi, add-on compresi.
- [ ] Ogni persona ha il piano adeguato, non il più alto per default.
- [ ] Gli add-on (Copilot incluso) sono attivi solo per chi li usa davvero.
- [ ] Esiste un backup indipendente da Microsoft, con un ripristino provato.
- [ ] Ci sono regole d'ordine per SharePoint e Teams (chi crea, come si chiama, chi è responsabile).
- [ ] So quali applicazioni dipendono dal login Microsoft.
- [ ] Ho identificato i dati critici secondo i criteri per l'ibrido.
- [ ] Ho una stima del costo di uscita, anche se non intendo uscire.
- [ ] Se valuto il self-hosted, ho contato la manutenzione, non solo le licenze.

## Il verdetto

Il confronto **Microsoft 365 contro self-hosted sui costi** non ha un vincitore assoluto. Per le aziende piccole, 365 costa meno di uno stack self-hosted completo anche su tre anni, perché il self-hosted si paga in persone, non in licenze. Con la crescita degli utenti e degli add-on — Copilot su tutti in testa — la distanza si riduce, e il rischio della dipendenza da un unico fornitore pesa di più.

La risposta sensata, per la maggior parte delle PMI, è ibrida: tenere la suite per comunicazione e lavoro quotidiano, con licenze e add-on scelti per chi ne ha bisogno e un backup indipendente; tenere sotto il proprio controllo i dati che sono il vero patrimonio dell'azienda o che hanno obblighi specifici; e calcolare oggi quanto costerebbe uscire, così da non scoprirlo il giorno in cui servirà.

Se vuoi fare i conti veri sulla tua suite e capire quali dati conviene tenere sotto il tuo controllo, trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su integrazioni e sistemi self-hosted sono nella guida su [integrazioni e sistemi self-hosted]({{ '/it/pillar/integrazioni-selfhosted/' | relative_url }}).

## FAQ

### Quanto costa davvero Microsoft 365 per una PMI?

Le licenze dei piani business vanno indicativamente da circa 6 a circa 25 euro per utente al mese, secondo il piano e il listino in vigore. Al costo vero vanno aggiunti backup esterno, eventuali funzioni di sicurezza avanzata, spazio aggiuntivo, add-on come Copilot e il tempo di amministrazione. Su tre anni, il totale è spesso molto superiore al prezzo di partenza.

### Conviene passare da Microsoft 365 a uno stack self-hosted?

Per motivi solo economici, raramente nelle aziende piccole: con 10 o 25 utenti, setup e manutenzione di uno stack self-hosted superano il risparmio sulle licenze. Conviene per motivi di controllo dei dati, obblighi specifici o dipendenza dal fornitore, spesso su pezzi specifici e non su tutto.

### Quanto costa uscire da Microsoft 365?

Dipende da quantità e ordine dei dati. Le caselle email si migrano con costi contenuti per casella; i file di SharePoint e OneDrive richiedono di ricostruire struttura e permessi; le chat di Teams in genere si archiviano; le integrazioni con il login Microsoft vanno rifatte. Per un'azienda di 25 persone, una stima indicativa è tra 15.000 e 40.000 euro tra lavoro e tempo.

### Copilot vale il suo prezzo?

Dipende dall'uso. Costa per utente, spesso più della licenza di base, e il valore dipende da quanto le persone lo usano davvero e da quanto sono ordinati i documenti su cui lavora. Conviene attivarlo per un gruppo pilota, misurare l'uso e estenderlo solo dove serve.

### Il backup incluso in Microsoft 365 è sufficiente?

Le funzioni di conservazione e recupero della suite non sono pensate come backup indipendente a lungo termine. Per proteggersi da cancellazioni, account compromessi e ransomware, molte aziende aggiungono un backup su un sistema non Microsoft, con un costo indicativo di 1–4 euro per utente al mese, e ne provano periodicamente il ripristino.

### Cosa significa self-hosted per l'email?

Gestire in proprio un server di posta è complesso per consegna dei messaggi, sicurezza e affidabilità. Per la maggior parte delle PMI ha più senso un fornitore di posta europeo con contratto, o una soluzione gestita da un partner: il controllo è contrattuale e geografico, non necessariamente su un server proprio.

### Nextcloud può sostituire SharePoint e OneDrive?

Per archiviazione, condivisione e modifica dei documenti nel browser, soluzioni come Nextcloud con suite d'ufficio integrate coprono bene le esigenze di molte PMI. Vanno verificate con i documenti reali la compatibilità con file complessi, macro e modelli aziendali, e va considerato chi gestisce il sistema.

### Cos'è l'approccio ibrido tra Microsoft 365 e self-hosted?

Tenere la suite per email, calendari, videochiamate e documenti di lavoro quotidiano, e spostare sotto il proprio controllo i dati critici: archivi di progetto, contratti, documentazione con obblighi specifici o che deve integrarsi con sistemi non Microsoft. Con backup indipendente e regole d'ordine su quello che resta nella suite.

### Quando Microsoft 365 resta la scelta migliore?

Per le aziende piccole senza nessuno che possa gestire un'infrastruttura, per quelle che lavorano intensamente con clienti e fornitori su strumenti Microsoft, e quando non ci sono dati critici o obblighi particolari. In questi casi conviene usarlo bene: licenze adeguate, add-on mirati, backup indipendente e ordine.

### Come si riduce il lock-in con Microsoft 365?

Con un backup indipendente su un sistema diverso, regole d'ordine su SharePoint e Teams fin dall'inizio, un elenco aggiornato delle applicazioni che dipendono dal login Microsoft, i dati critici tenuti su sistemi sotto il proprio controllo, e una stima periodica del costo di uscita.
