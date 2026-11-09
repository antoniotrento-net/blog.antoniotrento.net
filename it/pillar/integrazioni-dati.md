---
layout: pillar
lang: it
permalink: /it/pillar/integrazioni-dati/
pillar_key: integrazioni-dati
section: stack-sovrano-ai
title: "Integrazioni e dati legacy"
description: "IMAP/PEC, Salesforce, Oracle, voce e fonti sporche: collegare mondi che non si parlano senza fare danni in produzione."
image: /assets/images/pillars/integrazioni-dati.jpg
alt_url: /en/pillar/integrations-legacy-data/
sitemap: false

---

Ogni PMI ha almeno un sistema che non parla con gli altri. La casella PEC da cui arrivano fatture e comunicazioni che qualcuno smista a mano. Il CRM che esporta solo se un amministratore preme un pulsante. Il gestionale su Oracle di cui nessuno ha più lo schema. Le telefonate, i vocali, le fonti dati esterne che si rompono senza preavviso. Collegare questi mondi è il lavoro meno spettacolare e più redditizio dell'integrazione: è lì che si recuperano ore ogni settimana. Ed è anche il posto dove si fanno i danni peggiori, perché si tocca la produzione di sistemi che non hai progettato tu.

Questa guida raccoglie gli articoli su come si fanno **integrazioni che reggono**: agenti e flussi che leggono da sistemi vecchi e scomodi senza romperli, senza consegnare password a un SaaS, e senza fingere che il dato sporco sia pulito.

## Il principio: leggere molto, scrivere poco, dimostrare tutto

Il filo che lega questi articoli è un'asimmetria. **Leggere** da un sistema legacy è quasi sempre sicuro, se lo fai con un utente dedicato, permessi minimi e un ritmo che il sistema regge. **Scrivere** è dove si rompono le cose: un record sovrascritto, una PEC partita, un campo aggiornato su diecimila righe. Per questo le architetture che propongo partono sempre dalla sola lettura, scrivono in punti precisi e piccoli, e lasciano una traccia di ogni scrittura che permetta di dimostrare cosa è successo.

L'altro filo è il **dato onesto**. Una fonte esterna che non risponde, un valore vecchio di tre giorni, una colonna di cui non sei sicuro: il sistema lo deve dire, non nascondere. Un cruscotto che mostra un numero vecchio come se fosse di oggi fa più danni di uno che mostra "dato non disponibile".

## Le integrazioni (e l'articolo che le affronta)

**Posta, PEC e identità**

- **«Le fatture e le PEC le smista una persona ogni mattina»** — un agente che legge la casella via IMAP, classifica e prepara, senza Gmail API e senza dare la password a un servizio esterno: [l'agente IMAP per PEC e fatture]({{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}).
- **«Il provider ci ha chiuso la casella per troppe connessioni»** — come ascoltare la PEC senza farsi bloccare, con IMAP IDLE invece del polling aggressivo: [IMAP IDLE vs polling sulla PEC]({{ '/it/blog/imap-idle-vs-polling-pec/' | relative_url }}).
- **«Facciamo fare all'agente anche il login SPID e l'invio della PEC»** — dove sta il confine tra preparare e firmare, e come costruire il dossier per chi firma davvero: [SPID, PEC e i limiti dell'agente]({{ '/it/blog/agente-ai-spid-pec-limiti/' | relative_url }}).

**CRM, gestionali e database senza documentazione**

- **«Per avere i dati del CRM serve l'amministratore»** — export notturno da Salesforce con JWT in Docker, con un utente di integrazione che non è l'Administrator: [l'export Salesforce con JWT]({{ '/it/blog/salesforce-jwt-export-csv-docker/' | relative_url }}).
- **«Il gestionale è su Oracle e nessuno sa dove sta l'IBAN»** — reverse engineering di uno schema senza documentazione, dal catalogo alla colonna giusta, senza fare danni: [reverse engineering su Oracle]({{ '/it/blog/reverse-engineering-oracle-iban/' | relative_url }}).

**Voce, desktop e ambienti chiusi**

- **«Trascriviamo le riunioni con un servizio cloud»** — quando la trascrizione offline su una GPU locale costa meno e tiene l'audio in azienda: [trascrizione audio offline su Windows]({{ '/it/blog/trascrizione-audio-offline-windows/' | relative_url }}).
- **«Vogliamo un assistente vocale al centralino»** — latenza, interruzioni e GDPR, cioè perché non è un centralino più furbo: [l'assistente vocale in PMI]({{ '/it/blog/assistente-vocale-pmi-gdpr-latenza/' | relative_url }}).
- **«Il cliente vuole l'AI ma i PC non escono su internet»** — distribuire un'app desktop con modello locale senza che antivirus e policy la blocchino: [l'app AI offline con Electron]({{ '/it/blog/electron-ai-offline-windows/' | relative_url }}).

**Regole dell'agente e fonti dati esterne**

- **«Il prompt dell'agente è lungo dodici pagine»** — spostare tono, divieti e canali in un file YAML che legge il codice, non il modello: [YAML come costituzione dell'agente]({{ '/it/blog/yaml-costituzione-agente-ai/' | relative_url }}).
- **«Il backtest dice Sharpe 2,4»** — perché un modello su dati storici mente, e come accorgersene con il walk-forward: [walk-forward e overfitting nei bot di trading]({{ '/it/blog/walk-forward-overfitting-trading-bot/' | relative_url }}).
- **«Il cruscotto dice rischio contenuto»** — quando l'indicatore è un bug di aggregazione tra due fonti che non misurano la stessa cosa: [margin debt tra FRED e FINRA]({{ '/it/blog/margin-debt-fred-vs-finra/' | relative_url }}).

## Il pezzo che decide tutto: l'utente di integrazione e la traccia

In quasi tutti questi articoli ritornano due scelte, e da queste due dipende se l'integrazione regge per anni o si rompe al primo audit.

La prima è l'**utente di integrazione**. Ogni sistema che colleghi deve vedere arrivare un'identità dedicata, con i permessi minimi per quel compito: sola lettura dove basta leggere, scrittura solo sui campi che servono, mai l'account dell'amministratore "perché tanto funziona". Quando qualcosa va storto, l'utente dedicato ti dice subito da dove è partito; quando cambi fornitore o spegni l'integrazione, lo disattivi senza toccare le persone.

La seconda è la **traccia**. Ogni lettura importante e ogni scrittura lasciano un segno: cosa, quando, con quale versione del flusso, con quale esito. Non per burocrazia, ma perché le integrazioni falliscono in silenzio. Una PEC non scaricata, un export che ha saltato una pagina, una colonna rinominata dal fornitore del gestionale: senza traccia, te ne accorgi quando un cliente chiama.

## Quando l'integrazione non è il problema

Una parte di questi articoli dice anche quando **non** integrare. Se una fonte non ha un canale lecito e stabile, si cambia fonte invece di costruire uno scraper. Se una pratica richiede identità e firma di una persona, l'agente prepara e la persona decide. Se il sistema legacy sta per essere sostituito, a volte conviene un export manuale settimanale invece di un'integrazione che vivrà sei mesi. Dirlo fa parte del lavoro, tanto quanto scrivere il connettore.

Quando l'integrazione richiede anche agenti che agiscono sui sistemi (scrivere sul CRM, aprire ticket, spedire), il discorso continua nella guida sugli [agenti che eseguono]({{ '/it/pillar/agenti-esecuzione/' | relative_url }}). L'infrastruttura su cui far girare tutto questo — Docker, reverse proxy, segreti, backup — è nella guida allo [stack sovrano]({{ '/it/pillar/stack-sovrano/' | relative_url }}).

## Come usare questa guida

Parti dall'articolo che descrive il sistema che oggi ti fa perdere più tempo. Ognuno ha un'architettura di riferimento con quello che l'agente o il flusso **non** tocca, un percorso a step, i fallimenti tipici con le righe di log da cui riconoscerli, i costi in ordine di grandezza e una sezione onesta su quando non farlo.

Se vuoi capire come collegare i *tuoi* sistemi — la tua PEC, il tuo CRM, il tuo gestionale — senza consegnarli a un servizio esterno, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi da [contatti]({{ site.main_site }}/contatti/).

Qui sotto trovi tutti gli articoli di questa guida.
