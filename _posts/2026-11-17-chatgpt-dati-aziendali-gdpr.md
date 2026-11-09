---
lang: it
permalink: /it/blog/chatgpt-dati-aziendali-gdpr/
alt_url: /en/blog/chatgpt-company-data-gdpr/
title: "I tuoi dipendenti usano ChatGPT sui clienti: cosa rischi in Italia e come dargli un'alternativa interna (senza divieti inutili)"
date: 2026-11-17 07:30:00 +0200
author: "Antonio Trento"
description: "Per titolari e responsabili di PMI: cosa esce davvero dall'azienda quando un dipendente incolla un'offerta su ChatGPT, il GDPR spiegato in italiano semplice, perché il divieto non funziona, l'alternativa interna, una policy di una pagina e un piano di 30 giorni con i costi."
keywords: ["chatgpt dati aziendali gdpr", "chatgpt in azienda italia", "privacy dipendenti llm", "alternativa chatgpt interna", "shadow it openai", "policy uso chatgpt aziendale"]
image: /assets/images/posts/chatgpt-dati-aziendali-gdpr.jpg
pillar: chatgpt-azienda
related: [/it/blog/chatgpt-privato-self-hosted-pmi/, /it/blog/gdpr-chatgpt-crm/]
---

## Lo scenario: il commerciale, l'offerta, il tasto incolla

Sono le sei e mezza di sera. Il commerciale deve mandare entro domattina un'offerta a un cliente importante, e la mail che ha scritto non lo convince. Apre ChatGPT dal suo account personale, quello gratuito, e incolla tutto: il testo della mail, il listino con gli sconti riservati, il nome dell'azienda cliente, il nome e il cellulare del referente, due righe sui problemi che il cliente ha avuto con il fornitore precedente. Scrive: "rendila più professionale". In trenta secondi ha una mail migliore. La manda, va a casa, e domani rifarà la stessa cosa con il contratto di un altro cliente.

Non ha fatto niente di malizioso. Ha usato lo strumento più comodo che aveva per fare meglio il suo lavoro. Ma in quei trenta secondi un pezzo di **dati aziendali è finito su ChatGPT, con implicazioni GDPR** che né lui né l'azienda hanno valutato: dati personali di un cliente, condizioni commerciali riservate, informazioni su un concorrente, tutto su un servizio esterno, con un account personale, con le impostazioni di default.

Se sei il titolare o il responsabile di una PMI italiana e stai leggendo questo pezzo, probabilmente è perché hai scoperto che succede anche da te. O perché sospetti che succeda e non sai quanto. Questo articolo risponde a tre domande, in italiano semplice: **cosa rischi davvero**, perché vietare non basta, e **come dare ai dipendenti un'alternativa** che usino al posto di quella personale, in trenta giorni, con costi chiari.

Non è un trattato legale e non sostituisce il parere del tuo consulente privacy. È il punto di vista di chi costruisce questi sistemi nelle aziende e ha visto cosa funziona e cosa no.

## È per te / non è per te

È per te se:

- hai tra 5 e 200 persone, e una parte di loro scrive mail, offerte, relazioni, documenti per i clienti;
- sai, o sospetti, che qualcuno usa ChatGPT o strumenti simili con dati di lavoro;
- hai già mandato una circolare di divieto, oppure stai per farlo, e ti chiedi se serve;
- vuoi sistemare la questione senza diventare un esperto di privacy o di intelligenza artificiale.

Non è per te se cerchi un'analisi giuridica completa del GDPR: qui c'è quello che serve per decidere, non tutto quello che si potrebbe dire. Non è per te nemmeno se sei un tecnico che cerca come installare un modello su un server: per quello c'è il pezzo su [come montare un ChatGPT privato su due GPU]({{ '/it/blog/chatgpt-privato-self-hosted-pmi/' | relative_url }}). Qui parliamo di decisioni, regole e persone.

## Cosa esce davvero dall'azienda (e perché "è solo un riassunto" non salva)

Quando un dipendente incolla un testo in un chatbot pubblico, il testo viene trasmesso ai server del fornitore, elaborato, e — a seconda del tipo di account e delle impostazioni — conservato nella cronologia, eventualmente rivisto per sicurezza, e in alcuni casi usato per migliorare i modelli. Con gli account personali gratuiti o a pagamento individuale, l'uso delle conversazioni per l'addestramento è spesso attivo di default, e va disattivato a mano nelle impostazioni. Con i piani aziendali, in genere, è disattivato e c'è un contratto sul trattamento dei dati. La differenza tra le due situazioni è enorme, e il dipendente quasi sempre è nella prima.

Le obiezioni che sento più spesso, e perché non reggono:

- **"Ha incollato solo un riassunto."** Un riassunto di un contratto contiene nomi, importi, scadenze, condizioni. Un riassunto di un reclamo contiene il nome del cliente e il problema. Togliere qualche frase non toglie i dati.
- **"Non ha messo il nome del cliente."** Spesso il cliente è identificabile lo stesso: dalla città e dal settore, dal nome del referente nella firma, dal numero d'ordine, dal dominio email. Per il GDPR un dato è personale anche se identifica la persona *indirettamente*.
- **"Tanto sono dati che conosciamo solo noi."** È esattamente il problema: sono dati che l'azienda tratta per conto dei clienti o che i clienti le hanno affidato, e che ora sono anche altrove.
- **"Lo fanno tutti."** Vero. Non è una difesa: è la descrizione del rischio.

Oltre ai dati personali, escono **segreti commerciali**: listini, margini, condizioni riservate, strategie, informazioni sui concorrenti, codice sorgente, progetti. Il GDPR non li protegge, ma il tuo contratto con i clienti spesso sì (clausole di riservatezza), e la loro fuga può costarti più di qualsiasi sanzione.

### Tabella: dati che non devono mai finire in un chatbot cloud non autorizzato

| Tipo di dato | Esempi | Perché |
|---|---|---|
| Dati di salute e altre categorie particolari | certificati medici, infortuni, disabilità, iscrizioni sindacali | Protezione rafforzata dal GDPR; violazione grave |
| Dati giudiziari | carichi pendenti, procedimenti, contestazioni penali | Trattamento consentito solo in casi specifici |
| Credenziali e codici di accesso | password, token, PIN, codici OTP, chiavi di configurazione | Accesso diretto ai sistemi |
| Dati bancari e di pagamento | IBAN di clienti e dipendenti, numeri di carta, estratti conto | Rischio frode, dati finanziari |
| Documenti d'identità e codici fiscali | carte d'identità, passaporti, codici fiscali in elenco | Furto d'identità |
| Anagrafiche clienti in blocco | export del CRM, liste contatti, mailing list | Volume: da errore a violazione di massa |
| Dati dei dipendenti | buste paga, valutazioni, provvedimenti disciplinari | Rapporto di lavoro, rischio contenzioso |
| Condizioni commerciali riservate | listini riservati, sconti, margini, offerte in gara | Segreto commerciale, clausole contrattuali |
| Documenti dei clienti coperti da riservatezza | contratti, progetti, disegni tecnici, codice | Accordi di riservatezza con il cliente |
| Informazioni societarie non pubbliche | bilanci provvisori, operazioni straordinarie, trattative | Danno economico e reputazionale |

Questa tabella vale per gli strumenti **non autorizzati**: account personali, servizi senza contratto, estensioni del browser installate da chiunque. Con uno strumento autorizzato, con un contratto e un'impostazione corretta (vedi sotto), alcune righe si possono gestire. Altre, come le credenziali, mai.

## GDPR in italiano semplice: titolare, responsabile, trasferimento

Per capire il rischio servono tre concetti. Te li spiego senza articoli di legge.

### Il titolare: sei tu

L'azienda che raccoglie e usa i dati dei clienti (o dei dipendenti) per i suoi scopi è il **titolare del trattamento**. Decide perché e come i dati vengono usati, e ne risponde. Se un dipendente usa quei dati in un modo non previsto — per esempio incollandoli in un servizio esterno — la responsabilità verso il cliente e verso il Garante resta dell'azienda. "L'ha fatto lui di sua iniziativa" può contare per i rapporti interni, non verso l'esterno.

### Il responsabile: il fornitore, se c'è un contratto

Quando un fornitore tratta dati per conto tuo (il gestionale in cloud, il servizio di posta, un chatbot aziendale), deve essere nominato **responsabile del trattamento** con un contratto che dice cosa può fare con i dati, come li protegge, dove li tiene, quando li cancella. Si chiama spesso DPA (Data Processing Agreement), e i fornitori seri lo offrono sui piani aziendali.

Con l'account personale del dipendente **non c'è nessun contratto tra l'azienda e il fornitore**. Il fornitore non è un tuo responsabile: tratta quei dati secondo le condizioni che ha accettato il dipendente come privato. Dal punto di vista dell'azienda è come se il dato fosse stato consegnato a un terzo qualsiasi.

### Il trasferimento: dove finiscono i dati

Molti servizi di intelligenza artificiale elaborano i dati fuori dall'Unione europea, spesso negli Stati Uniti. Il GDPR consente questi trasferimenti solo con garanzie precise: per gli Stati Uniti oggi esiste un quadro di adeguatezza per le aziende che vi aderiscono, ma va verificato fornitore per fornitore, ed è un quadro che in passato è già stato annullato due volte. Anche in questo caso, senza un contratto aziendale, non hai nessun controllo su dove e come avviene il trasferimento.

### Cosa può succedere, concretamente

- **Una violazione dei dati personali.** Se dati di clienti finiscono dove non dovrebbero, può trattarsi di un *data breach*, da valutare ed eventualmente notificare al Garante entro 72 ore, e in certi casi da comunicare agli interessati.
- **Sanzioni.** Il GDPR prevede sanzioni fino a 20 milioni di euro o al 4% del fatturato mondiale. Per una PMI le cifre reali sono molto più basse, ma possono comunque arrivare a decine di migliaia di euro, a cui si aggiungono i costi di consulenza e di gestione dell'incidente. Il Garante italiano è stato tra i più attivi in Europa proprio sull'intelligenza artificiale generativa, anche nei confronti dei fornitori.
- **Contestazioni dei clienti.** Un cliente che scopre che il suo contratto è stato incollato in un chatbot può contestare la violazione della riservatezza, chiedere danni, o semplicemente andarsene.
- **Questioni di lavoro.** Sanzionare un dipendente per un uso che l'azienda non ha mai regolato è difficile; controllarlo senza le regole giuste (lo Statuto dei lavoratori pone limiti precisi ai controlli a distanza) può creare un problema in più.

In più, dal 2025 l'AI Act europeo chiede alle aziende che usano sistemi di intelligenza artificiale di garantire un livello sufficiente di **alfabetizzazione** del personale che li usa, e la legge italiana sull'intelligenza artificiale ha introdotto obblighi di informazione verso i lavoratori quando l'AI entra nei processi di lavoro. Non sono obblighi complicati da rispettare, ma presuppongono che l'azienda sappia quali strumenti si usano e come. Con l'uso nascosto, non lo sa. Se vuoi approfondire il lato normativo con un taglio più tecnico, c'è il pezzo su [GDPR, AI Act e ChatGPT nel CRM]({{ '/it/blog/gdpr-chatgpt-crm/' | relative_url }}).

## Il divieto che nessuno rispetta (Shadow IT)

La reazione istintiva, una volta capito il rischio, è la circolare: "È vietato l'uso di ChatGPT e strumenti analoghi". Magari accompagnata dal blocco del sito sulla rete aziendale. Ho visto questa scena molte volte, e quasi sempre finisce allo stesso modo.

**Le persone continuano a usarlo, ma non lo vedi più.** Il sito è bloccato sul PC? C'è il telefono. Il telefono aziendale ha restrizioni? C'è quello personale. La foto del documento con il telefono e il caricamento nell'app sono più veloci del copia-incolla. Il rischio non è diminuito: è aumentato, perché ora i dati passano da dispositivi personali, con account personali, fuori da qualsiasi controllo, e nessuno in azienda ne parla più apertamente.

Questo fenomeno ha un nome: **Shadow IT**, l'informatica ombra. Le persone hanno un bisogno reale, l'azienda non offre uno strumento, e allora se lo procurano da sole. Con l'intelligenza artificiale il bisogno è particolarmente forte, perché il guadagno di tempo è immediato e visibile: una mail difficile scritta in due minuti invece che in venti, un documento lungo riassunto in trenta secondi, una traduzione decente al volo.

Il divieto funziona solo in un caso: quando c'è un'**alternativa autorizzata** che fa la stessa cosa, abbastanza bene. A quel punto il messaggio non è più "non puoi farlo", ma "fallo qui, dove è sicuro". E le persone, nella maggior parte dei casi, scelgono lo strumento ufficiale, perché nessuno ama lavorare nascondendosi.

C'è anche un argomento più pragmatico: un divieto che tutti violano insegna alle persone che le regole aziendali sulla sicurezza sono opzionali. È il messaggio peggiore che puoi dare, proprio su un tema in cui ti serve collaborazione.

## Alternativa interna: chat in azienda, regole su cosa si può incollare

L'alternativa ha due parti, entrambe indispensabili: uno **strumento** e delle **regole**. Lo strumento senza regole sposta il problema; le regole senza strumento producono il divieto che nessuno rispetta.

### Lo strumento: tre strade

**1. Piano aziendale di un fornitore, con contratto.** I principali fornitori di chatbot offrono piani per aziende: account gestiti dall'azienda, login con l'account aziendale, conversazioni non usate per l'addestramento, contratto sul trattamento dei dati, in alcuni casi la possibilità di tenere i dati in Europa. È la strada più rapida: si attiva in giorni. Va scelto il fornitore con attenzione (dove sono i dati, cosa dice il contratto, chi può accedere alle conversazioni), e preferibilmente uno con elaborazione in UE.

**2. Fornitore europeo.** Esistono fornitori europei di modelli e chat aziendali, con dati elaborati in Europa e contratti pensati per il GDPR. Spesso la qualità è vicina a quella dei leader per i compiti d'ufficio (scrivere, riassumere, tradurre in italiano), con meno complicazioni sul trasferimento dei dati.

**3. Chat interna, sui server dell'azienda.** Un modello open-source installato su un server in azienda (o in un datacenter italiano o europeo sotto il tuo controllo), con un'interfaccia simile a ChatGPT, accesso con l'account aziendale, e i dati che non escono mai. Richiede un investimento iniziale e qualcuno che lo mantenga, ma dà il massimo controllo e costi prevedibili. Il progetto tecnico completo — hardware, modelli, quote per ufficio — è nel pezzo sul [ChatGPT privato self-hosted]({{ '/it/blog/chatgpt-privato-self-hosted-pmi/' | relative_url }}).

| | Piano aziendale fornitore extra-UE | Fornitore europeo | Chat interna |
|---|---|---|---|
| Tempo di attivazione | giorni | giorni o settimane | 3–6 settimane |
| Dove stanno i dati | dipende dal piano e dal contratto | in UE | in azienda / datacenter scelto |
| Qualità sui compiti difficili | la più alta | buona | buona sui compiti d'ufficio, inferiore su quelli complessi |
| Costo | 20–30 € per utente al mese (stima) | simile o inferiore (stima) | investimento iniziale + manutenzione |
| Controllo | contrattuale | contrattuale, più semplice | totale |
| Adatto a | aziende che hanno bisogno di partire subito | aziende attente al trasferimento dati | aziende con 20+ persone e dati sensibili |

Non c'è una scelta giusta per tutti. Per molte PMI la strada sensata è **partire con un piano aziendale (meglio se europeo) per avere subito l'alternativa**, e valutare la chat interna quando l'uso è consolidato e si sa quanto e come viene usato lo strumento.

### Le regole: cosa si può incollare

Con uno strumento autorizzato e un contratto, la domanda cambia. Non più "cosa non devo mai incollare" (risposta: quasi tutto), ma "cosa è appropriato per questo strumento". Una regola semplice, a tre livelli, che funziona meglio di un elenco lungo:

- **Verde — sempre consentito:** testi senza dati personali né riservati; bozze di mail generiche; testi pubblici; richieste di spiegazioni, idee, schemi.
- **Giallo — consentito nello strumento aziendale, mai altrove:** documenti di lavoro con dati di clienti e fornitori (mail, offerte, contratti, verbali), riducendo i dati personali a quelli che servono davvero al compito.
- **Rosso — mai, in nessuno strumento di AI senza un'autorizzazione specifica:** le righe della tabella sopra (salute, dati giudiziari, credenziali, documenti d'identità, anagrafiche in blocco, dati dei dipendenti).

Il livello giallo è quello che rende lo strumento utile. Se tutto è rosso, torni al divieto.

## Policy di 1 pagina che i dipendenti firmano

La policy deve stare in una pagina, essere scritta in italiano normale, e dire cosa *si può* fare prima di cosa non si può. Una policy di dodici pagine non la legge nessuno; una di una pagina, presentata in una riunione e firmata, cambia i comportamenti. Ecco una bozza da adattare con il tuo consulente privacy.

> **Uso degli strumenti di intelligenza artificiale — regole aziendali**
>
> **Perché queste regole.** Gli strumenti di intelligenza artificiale aiutano a scrivere, riassumere e tradurre più velocemente, e vogliamo che tu li usi. Ma i dati dei nostri clienti, fornitori e colleghi ci sono stati affidati, e dobbiamo proteggerli.
>
> **1. Usa lo strumento aziendale.** Per il lavoro usa solo [nome dello strumento], a cui accedi con il tuo account aziendale. Non usare account personali di ChatGPT o di altri servizi per attività di lavoro, né da PC né da telefono.
>
> **2. Cosa puoi inserire.** Nello strumento aziendale puoi inserire documenti di lavoro: mail, offerte, contratti, verbali, specifiche. Inserisci solo i dati personali che servono davvero al compito.
>
> **3. Cosa non devi mai inserire.** Password e codici di accesso; dati sulla salute, giudiziari o sindacali; documenti d'identità; IBAN e dati di pagamento; elenchi di clienti o export di anagrafiche; dati dei colleghi (buste paga, valutazioni).
>
> **4. Rileggi sempre.** Lo strumento può sbagliare con molta sicurezza: numeri, date, nomi, riferimenti di legge. Ciò che invii a clienti e fornitori è responsabilità tua: verificalo.
>
> **5. Niente decisioni sulle persone.** Non usare l'AI per valutare, selezionare o sanzionare persone.
>
> **6. Segnala i problemi.** Se pensi di aver inserito per errore dati che non dovevi, o se uno strumento si comporta in modo strano, avvisa subito [riferimento interno]. Segnalare in fretta è più importante che non sbagliare mai: non ci saranno conseguenze per chi segnala in buona fede.
>
> **7. Le tue conversazioni.** Le conversazioni nello strumento aziendale sono conservate per [90] giorni. L'azienda registra solo dati tecnici di utilizzo (data, volume) per gestire il servizio, e non usa questi dati per valutare il tuo lavoro.
>
> **8. Nuovi strumenti.** Se vuoi usare un altro strumento di AI (estensioni del browser, app, servizi online), chiedi prima a [riferimento interno].
>
> Data, nome, firma.

Tre dettagli che fanno la differenza:

- il **punto 6** (segnalare senza paura) è quello che ti permette di intervenire entro le 72 ore se qualcosa va storto. Se le persone temono sanzioni, non segnalano, e scopri l'incidente quando è tardi;
- il **punto 7** deve essere vero. Se dici che non usi i dati per valutare il lavoro, l'impostazione tecnica e i comportamenti dei responsabili devono rispettarlo. Su questo punto, prima di firmare, fai una verifica con il consulente del lavoro: i controlli sugli strumenti di lavoro hanno regole precise;
- la policy si **presenta** in una riunione di mezz'ora con esempi concreti, non si manda per mail con "leggere e firmare".

## Piano 30 giorni: inventory, blocco guidato, alternativa, audit leggero

Ecco il percorso che propongo alle PMI, in quattro settimane. Non serve un progetto: serve una persona che lo segue (il titolare, il responsabile amministrativo, l'IT interno o esterno) e qualche ora a settimana.

### Settimana 1 — Inventario, senza caccia alle streghe

1. **Chiedi, non indagare.** Un questionario anonimo di cinque domande: usi strumenti di AI per lavoro? Quali? Per cosa? Con che tipo di dati? Cosa ti servirebbe? Le risposte ti diranno più di qualsiasi controllo, e manderanno il messaggio giusto: vogliamo capire, non punire.
2. **Guarda i dati aggregati della rete**, se hai un firewall o un DNS che lo permette: volume di traffico verso i principali servizi di AI, senza nomi. Serve a capire l'ordine di grandezza.
3. **Elenca i casi d'uso** emersi: quali uffici, quali compiti, quali dati.

### Settimana 2 — Scelta e attivazione dell'alternativa

4. **Scegli lo strumento** (piano aziendale, fornitore europeo o chat interna) in base ai casi d'uso e ai dati coinvolti.
5. **Verifica il contratto**: nomina a responsabile del trattamento, dove sono i dati, uso per addestramento disattivato, conservazione, cancellazione.
6. **Attivalo** per un primo gruppo pilota (un ufficio, 5–10 persone), con accesso tramite account aziendale.
7. **Prepara la policy** di una pagina e falla rivedere dal consulente privacy.

### Settimana 3 — Comunicazione e "blocco guidato"

8. **Riunione per ufficio** di 30–45 minuti: perché, lo strumento, tre esempi concreti del loro lavoro, le regole, un esempio di errore dell'AI mostrato dal vivo. Firma della policy.
9. **Blocco guidato**: solo dopo che l'alternativa è disponibile, blocca l'accesso ai servizi di AI non autorizzati dalla rete aziendale, con una pagina che dice "per il lavoro usa [strumento aziendale], ecco il link". Il blocco è un cartello stradale, non un muro.
10. **Estendi** lo strumento a tutti gli uffici.

### Settimana 4 — Audit leggero e aggiustamenti

11. **Secondo questionario anonimo**: usi lo strumento aziendale? Usi ancora quelli personali? Perché? Cosa manca?
12. **Metriche aggregate**: quante persone usano lo strumento ogni settimana, traffico verso i servizi esterni in calo o no.
13. **Aggiusta**: prompt o modelli predisposti per gli usi più comuni di ogni ufficio, risposte alle domande emerse, eventuali eccezioni alla policy.
14. **Registra** il tutto nel registro dei trattamenti e nella documentazione privacy.

### Dopo i 30 giorni: 60 e 90

- **A 60 giorni**: rivedi l'uso. Se lo strumento è adottato da oltre metà delle persone che scrivono documenti, sei sulla buona strada. Se è sotto un terzo, il problema è quasi sempre la qualità percepita o la scomodità d'accesso: chiedi a voce a cinque persone perché non lo usano.
- **A 90 giorni**: decidi se restare sul piano scelto o passare a una soluzione interna, in base a volumi, costi e dati trattati. È anche il momento di pensare a usi più strutturati (assistenti per il customer care, ricerca nei documenti aziendali), che sono progetti diversi con regole proprie.

## Quanto costa: l'alternativa contro la multa e la reputazione

Le cifre seguenti sono **stime** indicative per una PMI di 30 persone, da verificare sul tuo caso.

| Voce | Stima | Note |
|---|---|---|
| Piano aziendale di un fornitore (30 utenti) | 600–900 €/mese | 20–30 € per utente; spesso basta abilitare solo chi scrive molto |
| Chat interna (hardware + setup) | 4.000–10.000 € una tantum | Più 1–2 giorni al mese di manutenzione |
| Consulenza privacy per policy e contratto | 500–2.000 € | Una tantum, se non hai già un consulente |
| Tempo interno per il piano 30 giorni | 3–6 giorni/persona | Distribuiti sul mese |
| Formazione (30 minuti per persona) | 15 ore/persona totali | Il costo vero è il tempo, non il formatore |

Dall'altra parte della bilancia:

| Rischio | Stima | Note |
|---|---|---|
| Gestione di un data breach (consulenza, notifiche, comunicazioni) | 3.000–15.000 € | Anche senza sanzione |
| Sanzione del Garante per una PMI | da qualche migliaio a decine di migliaia di € | Dipende da gravità, dati coinvolti, collaborazione |
| Perdita di un cliente importante per violazione della riservatezza | il suo fatturato annuo | Spesso la voce più pesante |
| Tempo perso dalle persone senza strumento (o che lo usano di nascosto) | difficile da stimare | Ma è il motivo per cui lo usano |

Il confronto non è solo economico. L'alternativa autorizzata costa qualche centinaio di euro al mese, e in cambio le persone lavorano più velocemente in modo visibile e controllato. Il rischio evitato è raro, ma quando arriva costa molto di più. È un'assicurazione che, in più, aumenta la produttività.

## 3 errori da principiante che costano soldi o dati

**1. Comprare le licenze e basta.** L'azienda attiva un piano aziendale, manda le credenziali, e considera chiusa la questione. Nessuna policy, nessuna formazione, nessun blocco degli strumenti personali. Risultato: metà delle persone continua a usare l'account personale "perché ci sono abituati", e l'altra metà incolla nello strumento aziendale anche le password. Hai speso, e il rischio è rimasto.

**2. Leggere le conversazioni dei dipendenti "per controllare".** Il titolare, preoccupato, chiede all'IT di poter vedere cosa scrivono le persone nella chat aziendale. Oltre ai problemi con lo Statuto dei lavoratori e con il GDPR, il messaggio che passa è "lo strumento aziendale serve a sorvegliarti". Le persone tornano al telefono personale, e sei peggio di prima. Il controllo si fa sui dati aggregati e sulle regole, non sulle conversazioni.

**3. Usare strumenti "AI" non verificati.** Un'estensione del browser che riassume le mail, un'app che trascrive le riunioni, un servizio che "migliora" i documenti: molti di questi strumenti mandano i contenuti a terzi con condizioni poco chiare, e sono installati dalle persone senza chiedere. Spesso sono più rischiosi di ChatGPT stesso. La policy deve coprire anche loro (punto 8 della bozza), e qualcuno deve rispondere alle richieste in tempi ragionevoli, altrimenti le persone fanno da sole.

## Quando serve un DPO e quando basta ordine interno

Il **DPO** (Responsabile della protezione dei dati) è obbligatorio solo in alcuni casi: enti pubblici, aziende che per attività principale monitorano persone su larga scala o trattano su larga scala dati particolari (salute, per esempio) o giudiziari. Per la maggior parte delle PMI — un'azienda manifatturiera, uno studio tecnico, un'agenzia, un'impresa di servizi — il DPO **non è obbligatorio**.

Questo non significa che non serva niente. Serve **ordine interno**:

- un registro dei trattamenti aggiornato (in cui inserire anche lo strumento di AI);
- le nomine dei fornitori come responsabili del trattamento, con i contratti;
- un'informativa ai dipendenti sugli strumenti che usano;
- una procedura per i data breach (chi decide, entro quanto, chi chiamare);
- un consulente privacy di riferimento, anche esterno e a chiamata.

Conviene un DPO (o un consulente privacy più strutturato) quando:

- tratti dati sanitari, di minori o giudiziari, anche se non come attività principale ma in modo ricorrente;
- vuoi usare l'AI per qualcosa di più della scrittura d'ufficio: analisi di documenti dei clienti, assistenza automatica, valutazioni;
- hai già avuto un incidente, o un cliente importante ti chiede garanzie formali;
- l'azienda supera qualche decina di persone e nessuno, internamente, ha tempo di seguire la privacy.

## Quando NON farlo

Ci sono casi in cui il percorso descritto è sproporzionato, o sbagliato:

- **Se sei in tre e nessuno tratta dati sensibili**, non serve un progetto: un piano aziendale con contratto, impostato bene, e una chiacchierata di dieci minuti sulle regole bastano.
- **Se nessuno in azienda scrive documenti per lavoro** (per esempio un'impresa con poche attività d'ufficio), l'alternativa può non servire: basta la regola chiara e l'informativa.
- **Se tratti dati sanitari o giudiziari in modo strutturato** (studi medici, centri di assistenza, studi legali), non partire da un piano generico: il progetto va impostato con il consulente privacy fin dall'inizio, e spesso la soluzione interna è l'unica ragionevole.
- **Se l'obiettivo vero è controllare i dipendenti**, fermati. Un progetto nato per sorvegliare non produce sicurezza, produce sfiducia e contenzioso.
- **Se pensi di "risolvere con il blocco del sito"** senza alternativa, risparmia la fatica: il problema si sposta sui telefoni personali.

## Checklist pratica

- [ ] Questionario anonimo fatto: so chi usa quali strumenti, per cosa, con quali dati.
- [ ] Strumento autorizzato scelto, con contratto di trattamento dati, dati preferibilmente in UE, addestramento disattivato.
- [ ] Accesso con account aziendale; quando una persona lascia l'azienda, perde l'accesso.
- [ ] Policy di una pagina scritta, rivista dal consulente privacy, presentata in riunione e firmata.
- [ ] Livelli verde / giallo / rosso spiegati con esempi del lavoro di ogni ufficio.
- [ ] Blocco dei servizi non autorizzati attivato **dopo** che l'alternativa era disponibile, con pagina di reindirizzamento.
- [ ] Procedura di segnalazione chiara, senza conseguenze per chi segnala in buona fede.
- [ ] Nessuna lettura delle conversazioni individuali; solo dati aggregati di utilizzo.
- [ ] Registro dei trattamenti e informativa ai dipendenti aggiornati.
- [ ] Revisione a 30, 60 e 90 giorni in calendario.

## Il verdetto

Se i tuoi dipendenti incollano offerte e anagrafiche su ChatGPT, il problema di **dati aziendali, ChatGPT e GDPR** non si risolve con una circolare. Le persone non lo fanno per leggerezza: lo fanno perché lo strumento le aiuta davvero, e l'azienda non ha offerto niente di meglio. Il divieto senza alternativa sposta l'uso sul telefono personale e ti toglie l'unica cosa che avevi, cioè la possibilità di vederlo.

La soluzione è più semplice di quanto sembri, e si fa in un mese: capire chi usa cosa senza fare la caccia alle streghe, dare uno strumento autorizzato con un contratto serio e i dati in Europa o in casa, scrivere una pagina di regole che dica cosa si può fare, spiegarla con esempi veri, e solo allora chiudere la porta agli strumenti personali. Costa qualche centinaio di euro al mese e qualche giorno di lavoro. Ti restituisce il controllo sui dati, e alle persone un modo di lavorare meglio senza doversi nascondere.

Se vuoi impostare questo percorso nella tua azienda — scegliere lo strumento giusto per i tuoi dati, scrivere regole che le persone rispettino, valutare se e quando portare la chat in casa — trovi i progetti che ho seguito nel [portfolio]({{ site.main_site }}/portfolio/) e il mio percorso nella [biografia]({{ site.main_site }}/biografia/). Gli altri pezzi su come usare ChatGPT e strumenti simili in azienda senza perdere il controllo sono nella guida su [ChatGPT in azienda]({{ '/it/pillar/chatgpt-azienda/' | relative_url }}).

## FAQ

### È legale usare ChatGPT in azienda in Italia?

Sì, se l'azienda lo fa in modo regolato: con uno strumento per cui esiste un contratto di trattamento dei dati, regole chiare su cosa si può inserire, informativa ai dipendenti e registrazione nel registro dei trattamenti. Il problema non è lo strumento in sé, ma l'uso di account personali con dati di clienti e dipendenti, senza alcun accordo tra l'azienda e il fornitore.

### Cosa rischia un'azienda se un dipendente incolla dati dei clienti su ChatGPT?

Rischia che l'episodio sia una violazione dei dati personali da valutare ed eventualmente notificare al Garante entro 72 ore, possibili sanzioni, contestazioni da parte dei clienti per violazione della riservatezza e danni reputazionali. La responsabilità verso l'esterno resta dell'azienda, che è titolare del trattamento, anche se il dipendente ha agito di sua iniziativa.

### Basta vietare ChatGPT ai dipendenti?

No. Un divieto senza alternativa sposta l'uso su telefoni e account personali, dove l'azienda non vede più niente: è il fenomeno dello Shadow IT. Il divieto funziona solo se accompagnato da uno strumento autorizzato che risponda allo stesso bisogno, con regole chiare su come usarlo.

### Qual è la differenza tra account personale e piano aziendale?

Con un piano aziendale l'azienda gestisce gli account, le persone accedono con l'account di lavoro, le conversazioni in genere non sono usate per addestrare i modelli e c'è un contratto che nomina il fornitore responsabile del trattamento. Con l'account personale non esiste alcun rapporto tra azienda e fornitore, e i dati sono trattati secondo le condizioni accettate dal dipendente come privato.

### Quali dati non bisogna mai inserire in un chatbot?

In nessuno strumento non autorizzato vanno inseriti dati personali di clienti e dipendenti. In nessuno strumento, autorizzato o no, vanno inseriti credenziali e codici di accesso, e senza un'autorizzazione specifica dati sanitari, giudiziari, documenti d'identità, dati di pagamento, anagrafiche in blocco e dati dei dipendenti come buste paga e valutazioni.

### Cosa deve contenere una policy aziendale sull'uso dell'AI?

Quale strumento usare per il lavoro, cosa si può inserire, cosa non si deve mai inserire, l'obbligo di verificare le risposte, il divieto di usare l'AI per decisioni sulle persone, come segnalare un errore senza conseguenze, come vengono conservate le conversazioni e come chiedere l'autorizzazione per nuovi strumenti. Deve stare in una pagina ed essere presentata con esempi concreti.

### Si possono controllare le conversazioni dei dipendenti con la chat aziendale?

Con molta cautela e solo nei limiti previsti dalla normativa sul lavoro e dal GDPR. L'approccio consigliato è raccogliere solo dati aggregati e tecnici di utilizzo, dichiararlo nell'informativa e non usare le conversazioni per valutare il lavoro delle persone. Prima di qualsiasi controllo serve il parere del consulente del lavoro.

### Serve un DPO per usare l'intelligenza artificiale in azienda?

Nella maggior parte delle PMI il DPO non è obbligatorio: lo è per enti pubblici e per aziende che, come attività principale, monitorano persone su larga scala o trattano su larga scala dati particolari o giudiziari. Serve comunque ordine interno: registro dei trattamenti, contratti con i fornitori, informativa ai dipendenti, procedura per i data breach e un consulente privacy di riferimento.

### Quanto costa dare ai dipendenti un'alternativa a ChatGPT?

Un piano aziendale costa indicativamente 20–30 euro per utente al mese; una chat interna su server dell'azienda richiede un investimento iniziale di alcune migliaia di euro più la manutenzione. A questi si aggiungono qualche giorno di lavoro interno e, se serve, una consulenza privacy per policy e contratti. Sono cifre basse rispetto al costo di un data breach o della perdita di un cliente.

### Quanto tempo serve per mettere in ordine l'uso di ChatGPT in azienda?

Un mese è sufficiente per le PMI: una settimana per capire chi usa cosa, una per scegliere e attivare lo strumento autorizzato e preparare la policy, una per formare le persone e bloccare gli strumenti non autorizzati, una per misurare l'adozione e correggere. Le revisioni a 60 e 90 giorni servono a consolidare e decidere i passi successivi.
