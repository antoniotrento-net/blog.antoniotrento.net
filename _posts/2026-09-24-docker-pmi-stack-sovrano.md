---
lang: it
permalink: /it/blog/docker-pmi-stack-sovrano/
alt_url: /en/blog/docker-sme-sovereign-stack/
title: "Stack Docker sovrano per PMI: ERP, BI e agenti AI sulla stessa compose (senza Microsoft 365 che ti tiene in ostaggio)"
date: 2026-09-24 07:30:00 +0200
author: "Antonio Trento"
description: "Sovranità non è uno slogan, è architettura: reti Docker, confini tra servizi, backup testati, offboarding possibile. Come far convivere ERP, BI e agenti AI su un tuo stack senza dipendere da Microsoft o Google."
keywords: ["docker pmi stack sovrano", "self-hosted erp", "docker compose produzione", "vendor lock-in saas", "bi postgres"]
image: /assets/images/posts/docker-pmi-stack-sovrano.jpg
pillar: stack-sovrano
related: [/it/blog/n8n-self-hosted-openai-privacy/, /it/blog/vllm-vs-ollama-produzione/]
---

## Il conto che non guardi: Microsoft e Google a tre anni

Fai un conto che quasi nessuno fa. Prendi quanto paghi al mese per utente di Microsoft 365 o Google Workspace, aggiungi il CRM in abbonamento, il tool di BI, lo storage, l'automazione, il "copilot" che ti hanno appena venduto. Moltiplica per il numero di dipendenti. Poi moltiplica per **36 mesi**. La cifra che esce sorprende sempre — e non è nemmeno il problema più grande. Il problema è che alla fine di quei tre anni **non possiedi niente**: i tuoi dati, la tua identità, i tuoi flussi vivono a casa loro, e se un giorno vuoi andartene scopri che l'offboarding è un incubo, perché tutto è stato costruito per tenerti dentro. Questo è il **vendor lock-in**: paghi per anni e resti ostaggio.

C'è un'alternativa, e non è "buttare tutto e diventare eremiti digitali": è costruire uno **stack Docker sovrano** dove ERP, BI, automazione e agenti AI girano su infrastruttura che controlli tu — un rack in ufficio o un VPS in UE — con i dati, l'identità e i backup nelle tue mani. Ma attenzione, ed è il punto di tutto l'articolo: **sovranità non è uno slogan, è architettura.** Non basta scaricare qualche container per essere "sovrani": serve progettare i confini tra i servizi, le reti interne, i backup testati, i permessi, e — sì — la possibilità di andartene. In questo pezzo vediamo cosa significa davvero sovrano (dati, identità, DNS, backup, offboarding), la mappa dei servizi di uno stack per PMI, la scelta tra un compose unico e tanti (il "blast radius"), i backup che si testano davvero, gli aggiornamenti senza il "lunedì morto", i permessi (l'agente AI non deve vedere l'ERP intero), e il percorso di migrazione a scaglioni. Con il diagramma dei confini, le reti Docker interne, e la checklist di restore. Perché la sovranità o è nell'architettura, o è marketing.

## Cosa significa "sovrano" davvero: dati, identità, DNS, backup, offboarding

"Sovrano" è una parola abusata. Chiariamo cosa significa in concreto, perché sono cinque cose precise, e se ne manca una non sei sovrano — sei solo self-hosted a metà.

- **I dati.** I tuoi dati vivono su infrastruttura che controlli, in UE, e puoi **esportarli** in qualsiasi momento in un formato utilizzabile. Se non puoi tirarli fuori, non sono tuoi.
- **L'identità.** Chi accede a cosa lo decide un tuo sistema di identità (un IdP tuo, tipo Authentik o Keycloak), non l'account Microsoft/Google. L'identità è la chiave di tutto: se dipende da un fornitore, dipendi da lui per l'accesso ai tuoi stessi sistemi.
- **Il DNS e i domini.** I tuoi domini sono intestati a te, il DNS lo controlli tu. Sembra un dettaglio: è la differenza tra poter spostare tutto domani e restare bloccato perché non possiedi il tuo stesso indirizzo.
- **I backup.** Copie dei dati che *tu* possiedi e sai ripristinare — non "il fornitore ha i backup" (che è la sua assicurazione, non la tua). Un backup che non sai ripristinare non è un backup: è una speranza.
- **L'offboarding.** La prova del nove della sovranità: **puoi andartene?** Se domani vuoi cambiare tutto, quanto è doloroso? In uno stack sovrano ben fatto, l'offboarding è possibile perché niente è costruito per intrappolarti. Nel lock-in, è progettato per non farti uscire.

Il test mentale è semplice: *"se il mio fornitore raddoppiasse i prezzi domani, o chiudesse, o mi bloccasse l'account, cosa succederebbe alla mia azienda?"* Se la risposta è "sarei paralizzato", non sei sovrano. Se è "sposterei, con fatica ma potrei", lo sei. La sovranità è questa libertà — la stessa che difendo quando parlo di [possedere il codice, gli accessi e i dati di un software su misura]({{ '/it/blog/manutenzione-software-dopo-go-live/' | relative_url }}): non è ideologia, è non essere in trappola.

## La mappa dei servizi: reverse proxy, IdP, DB, code, worker AI

Uno stack sovrano per PMI non è "un container magico": è un insieme di servizi con ruoli precisi. Ecco la mappa dei pezzi che compongono l'ecosistema:

- **Il reverse proxy** (Caddy, Traefik, Nginx): l'unico punto esposto a internet. Gestisce HTTPS, instrada le richieste ai servizi giusti, mette l'autenticazione davanti. Tutto entra da qui, niente altro è esposto.
- **L'IdP** (Authentik, Keycloak): il sistema di identità. Un login unico per tutti i servizi, gestito da te. Chi entra, chi vede cosa.
- **Il database** (PostgreSQL): il cuore dei dati. ERP, BI, automazione ci appoggiano. Postgres da solo copre database relazionale, e con pgvector anche gli embedding (come nel [RAG sulle fatture]({{ '/it/blog/rag-pgvector-fattura-elettronica/' | relative_url }})).
- **La coda / cache** (Redis): per i lavori asincroni, le code, le sessioni.
- **L'ERP / gestionale** (uno self-hosted adatto alla tua attività): il gestionale vero.
- **La BI** (Metabase o simili): i cruscotti sui dati, appoggiati sullo stesso Postgres.
- **L'automazione** (n8n): i workflow che legano i pezzi.
- **Il worker AI** (Ollama o [vLLM per la produzione]({{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }})): i modelli linguistici in locale.
- **Lo storage file** (un servizio di file self-hosted): documenti e allegati.

Il punto architetturale non è "quali software", ma **come si parlano e chi vede chi.** Ed è qui che entra il diagramma dei confini:

```text
                    INTERNET
                       │  (solo 443)
                 ┌─────▼─────┐
                 │  REVERSE  │   rete: frontend
                 │   PROXY   │   (esposta)
                 │  + TLS    │
                 └─────┬─────┘
        ┌──────────┬───┴────┬──────────┐
     ┌──▼──┐   ┌───▼──┐  ┌──▼──┐    ┌──▼───┐
     │ IdP │   │ ERP  │  │ BI  │    │ n8n  │   rete: frontend
     └──┬──┘   └───┬──┘  └──┬──┘    └──┬───┘
        └──────────┴────────┴──────────┘
                       │   rete: backend (INTERNA, no internet)
        ┌──────────┬───┴────┬──────────┐
   ┌────▼───┐  ┌───▼───┐ ┌──▼───┐  ┌───▼────┐
   │Postgres│  │ Redis │ │worker│  │ storage│   rete: backend
   │        │  │       │ │  AI  │  │  file  │
   └────────┘  └───────┘ └──────┘  └────────┘
```

La regola d'oro: **solo il reverse proxy tocca internet.** Tutto il resto vive dietro, su reti che non sono raggiungibili da fuori. E i dati "pesanti" (database, worker AI, storage) stanno su una rete **interna** che nemmeno i servizi web possono esporre. Questo è il confine, ed è ciò che rende lo stack difendibile.

## Le reti Docker interne: il confine che ti protegge

Il diagramma sopra si traduce in **reti Docker segmentate**, ed è una delle cose più importanti e più trascurate. Mettere tutti i container sulla stessa rete "così si parlano" è comodo e pericoloso: se uno viene compromesso, vede tutti gli altri. La segmentazione limita il danno.

```yaml
networks:
  frontend:
    driver: bridge
    # esposta al reverse proxy; i servizi web stanno qui
  backend:
    driver: bridge
    internal: true
    # INTERNA: nessuna connettività verso internet.
    # Database, worker AI e storage vivono qui e NON sono
    # raggiungibili da fuori, nemmeno se qualcosa si buca.
```

L'assegnazione dei servizi alle reti segue il diagramma:

```yaml
services:
  reverse-proxy:
    networks: [frontend]
    ports: ["443:443"]        # l'UNICO con porte esposte

  erp:
    networks: [frontend, backend]   # web (frontend) + accesso al DB (backend)

  postgres:
    networks: [backend]         # SOLO interna: nessun accesso da internet
    # niente 'ports:' — non esposto all'host

  worker-ai:
    networks: [backend]         # il modello AI sta dietro, non davanti
```

Due principi che questa configurazione impone:

- **Il database non ha porte esposte.** Nessun `ports:` sul Postgres: ci si arriva solo dai servizi sulla rete `backend`, mai da internet. È l'errore di sicurezza più comune negli stack fatti in fretta — il Postgres con la porta 5432 aperta al mondo — e qui è impossibile per costruzione.
- **La rete `backend` è `internal: true`.** Non ha via d'uscita verso internet. Anche se un container su quella rete venisse compromesso, non può "telefonare a casa" verso l'esterno. È il recinto dentro il recinto.

Questa segmentazione è la traduzione concreta di "sovranità come architettura": non uno slogan, ma reti, confini e porte chiuse. È lo stesso rigore del [recinto n8n + modello locale]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}), applicato all'intero ecosistema aziendale.

## Un compose o tanti compose: la questione del blast radius

Domanda architetturale vera: metti tutto in **un** `docker-compose.yml` o lo spezzi in **tanti**? La risposta dipende da un concetto: il **blast radius** — quanto danno fa un problema quando succede.

- **Un compose unico** è più semplice da gestire e da capire: tutto in un posto, si tira su con un comando. Ma il blast radius è ampio: un aggiornamento sbagliato, un errore di configurazione, un riavvio, e rischi di toccare *tutto* insieme. Se un servizio va giù male, può portarsi dietro gli altri.
- **Tanti compose** (per gruppi logici: uno per i dati/DB, uno per l'ERP, uno per l'AI, uno per il proxy) isolano i problemi. Aggiorni l'AI senza toccare l'ERP; riavvii l'automazione senza rischiare il database. Il blast radius di ogni operazione è più piccolo. Il costo è più complessità di coordinamento (le reti vanno condivise tra compose, i servizi devono trovarsi).

La scelta pratica per una PMI:

- **I servizi "fondamentali e stabili"** (Postgres, reverse proxy, IdP) — che cambi di rado e da cui dipende tutto — hanno senso in un compose loro, tenuto stabile.
- **I servizi "che iteri"** (n8n, worker AI, ERP che aggiorni) in compose separati, così li muovi senza rischiare i fondamentali.

Il principio: **isola ciò che cambia da ciò che deve stare fermo.** Il database e l'identità sono le fondamenta: non li vuoi toccare ogni volta che aggiorni un workflow. Separare per blast radius significa poter lavorare su un pezzo senza tremare per gli altri. È l'equivalente infrastrutturale del non mettere tutte le uova nello stesso paniere — e in produzione, dove un "lunedì morto" costa caro, conta.

## I backup che si testano davvero (non quelli che speri esistano)

Ecco la sezione che separa chi "ha i backup" da chi è davvero al sicuro. Avere i backup non serve a niente se non sai ripristinarli. Il backup è un'illusione finché non l'hai **testato**.

Cosa va salvato, in uno stack sovrano:

- **Il dump del database.** Un `pg_dump` regolare di Postgres: è il cuore dei dati. Automatizzato, versionato, portato **fuori** dalla macchina (un backup sulla stessa macchina che si rompe non ti salva).
- **I volumi Docker.** I dati persistenti dei servizi (storage file, configurazioni, stato). Non basta il DB: certi servizi tengono dati nei volumi.
- **I segreti.** Le chiavi, le password, i certificati (in un secret manager o almeno cifrati e backuppati a parte). Se ripristini i dati ma hai perso le chiavi di cifratura, i dati sono inservibili.
- **Le configurazioni.** I compose, le regole, le configurazioni dei servizi: versionate in git. Sono la "ricetta" per ricostruire lo stack.

Ma il pezzo che quasi nessuno fa, ed è quello che conta: **il test di restore mensile.** Una volta al mese, prendi i backup e prova a **ricostruire** lo stack da zero su una macchina di prova. Se non ci riesci, i tuoi backup non valgono niente — e l'hai scoperto durante un test, non durante un disastro. Ecco la checklist di restore:

```text
CHECKLIST RESTORE (mensile, su macchina di prova)
[ ] Recupero l'ultimo pg_dump dal backup esterno
[ ] Recupero i volumi e i segreti
[ ] Tiro su lo stack dai compose versionati (git)
[ ] Ripristino il database dal dump
[ ] Verifico: i servizi partono? l'IdP autentica?
[ ] Verifico: i dati ci sono e sono coerenti (conteggi, ultimi record)?
[ ] Verifico: l'ERP apre? la BI mostra i dati? l'AI risponde?
[ ] Cronometro: quanto ci ho messo? (è il tuo RTO reale)
[ ] Annoto cosa è mancato/rotto e lo sistemo nel processo
```

Quel cronometro è prezioso: ti dice il tuo **tempo di ripristino reale** (RTO), cioè quanto resterebbe ferma l'azienda in un disastro. Se è "non lo so", non hai un piano di continuità, hai una speranza. Il test di restore trasforma la speranza in una capacità dimostrata.

## Gli aggiornamenti senza il "lunedì morto"

Il terrore di ogni stack self-hosted: aggiorni qualcosa il venerdì, il lunedì niente funziona e l'azienda è ferma. Il "lunedì morto" è ciò che spaventa dal self-hosting — ma si evita con metodo, non con la fortuna.

- **Fissa le versioni (pin).** Non usare `latest` in produzione: un `latest` che si aggiorna da solo è una roulette. Fissa versioni precise dei container, e aggiorna quando *decidi* tu, non quando capita.
- **Aggiorna un pezzo alla volta.** Grazie alla separazione per blast radius: aggiorni il worker AI, verifichi, poi passi ad altro. Mai "aggiorno tutto insieme e speriamo".
- **Prova prima su staging.** Un ambiente di prova (anche minimale) dove testi l'aggiornamento prima di metterlo in produzione. Costa poco e salva lunedì.
- **Aggiorna quando puoi rollbackare.** Prima di aggiornare, assicurati di poter **tornare indietro** (backup fresco, versione precedente a portata). Un aggiornamento senza via di ritorno è un azzardo.
- **Non aggiornare il venerdì.** Regola d'oro operativa: aggiorna quando hai il tempo e le persone per gestire un problema, non prima del weekend o di un ponte.

Il metodo trasforma gli aggiornamenti da roulette a routine. Il self-hosting non è pericoloso *di per sé*: è pericoloso quando lo fai senza disciplina. Con versioni fissate, blast radius contenuto, staging e rollback, il "lunedì morto" non capita — capita a chi mette `latest` ovunque e aggiorna tutto insieme sperando bene.

## I permessi: l'agente AI non vede l'ERP intero

Un tema di sicurezza specifico e cruciale quando metti un'AI nello stack: **l'agente AI non deve avere accesso a tutto.** La tentazione, per farlo "funzionare subito", è dargli le chiavi del database intero o l'accesso completo all'ERP. È l'errore che trasforma un assistente in una falla.

Il principio del **minimo privilegio**, applicato all'AI nello stack:

- **Accesso ai soli dati che gli servono.** Se l'agente AI deve rispondere a domande sui documenti, gli dai accesso all'indice dei documenti, non all'intero database HR e contabilità. Un utente di database dedicato, con permessi di sola lettura sulle *sole* tabelle/viste necessarie.
- **Viste, non tabelle grezze.** Esponi all'AI delle **viste** che contengono solo ciò che può vedere (e già filtrate/mascherate dove serve), non le tabelle complete con tutti i campi sensibili.
- **Nessuna scrittura non mediata.** Se l'agente deve *fare* qualcosa (non solo leggere), passa dai tool controllati con idempotenza e approvazione, come per gli [agenti che eseguono azioni sui sistemi]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}) — non con accesso diretto in scrittura al DB.
- **Sulla rete `backend`, ma isolato nei permessi.** Il worker AI vive sulla rete interna (giusto), ma questo non significa che possa leggere tutto ciò che c'è su quella rete: i permessi applicativi (utenti DB, viste) sono un secondo livello oltre alla rete.

L'errore da evitare è confondere "l'AI gira in casa mia" con "l'AI può vedere tutto ciò che ho in casa". Sono due cose diverse: la prima è sovranità (i dati non escono), la seconda è una falla (l'agente ha troppo accesso). Uno stack sovrano ben fatto ha **entrambi** i confini: i dati non escono *e* ogni servizio, AI compresa, vede solo il suo pezzo.

## Il percorso di migrazione a scaglioni

Non si passa da Microsoft 365 allo stack sovrano in un weekend — chi te lo promette mente. Si migra **a scaglioni**, un pezzo alla volta, con il vecchio e il nuovo che convivono nella transizione. L'ordine sensato, dal più facile e a rischio basso al più delicato:

1. **La posta / PEC.** Spesso il primo scaglione: una casella e l'[inbox agent per PEC e fatture]({{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}) portano valore subito, con rischio contenuto.
2. **I file.** Lo storage documenti self-hosted: sposti le cartelle condivise su un servizio tuo. Migrazione dei file, permessi, e via.
3. **L'automazione.** n8n che comincia a legare i pezzi, sostituendo automazioni sparse in SaaS diversi.
4. **La BI.** I cruscotti su Metabase appoggiati al tuo Postgres: cominci a vedere i tuoi dati con strumenti tuoi.
5. **Il CRM / ERP.** Lo scaglione più delicato, quello che tocca l'operatività quotidiana. Si fa per ultimo, quando gli altri pezzi sono solidi e hai preso confidenza con lo stack.

Ogni scaglione:

- **Porta valore da solo** (non devi aspettare la fine per vedere benefici).
- **Convive col vecchio** durante la transizione (nessun vuoto operativo).
- **Riduce il lock-in** un pezzo alla volta, invece di un big-bang rischioso.

Questo approccio graduale è ciò che rende la migrazione **sopportabile e reversibile**: se uno scaglione dà problemi, lo sistemi senza aver buttato giù tutto. È lo stesso principio del [digitalizzare uno studio a pezzi senza fermarlo]({{ '/it/blog/software-studio-professionale-completo/' | relative_url }}): il big-bang è il modo migliore di fallire in grande, gli scaglioni il modo di vincere in piccolo e poi in grande.

## Un esempio concreto: cosa sostituisce cosa

Per rendere tangibile lo stack, ecco una mappatura "SaaS → sovrano" di una PMI tipo, con cosa sostituisce cosa. Non è l'unica combinazione possibile, ma dà l'idea di come i pezzi coprono i bisogni reali senza i canoni per-utente.

| Bisogno | SaaS tipico | Alternativa sovrana (self-hosted) |
|---|---|---|
| **Identità / login unico** | Account Microsoft/Google | IdP proprio (Authentik/Keycloak) |
| **Posta / PEC** | Exchange / Gmail | Casella IMAP + [inbox agent]({{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}) |
| **File condivisi** | OneDrive / Drive | Storage file self-hosted |
| **Database** | DB gestito cloud | PostgreSQL (con pgvector per l'AI) |
| **Automazione** | Zapier / Power Automate | n8n |
| **BI / cruscotti** | Power BI / Looker | Metabase su Postgres |
| **Assistente AI** | Copilot (per-utente) | Ollama / vLLM in locale |
| **Reverse proxy / TLS** | (gestito dal SaaS) | Caddy / Traefik |

Il punto non è che *devi* usare esattamente questi software: è che **per ogni pezzo del "pacchetto ostaggio" esiste un equivalente self-hosted**, e che appoggiandosi tutti sullo stesso Postgres e dietro lo stesso proxy formano un ecosistema coerente invece di dieci abbonamenti scollegati. La BI legge gli stessi dati dell'ERP; l'automazione lega la posta al gestionale; l'AI risponde sui documenti che stanno nel tuo storage. È la coerenza, oltre alla sovranità, il vantaggio: un sistema solo, non dieci silos in affitto che qualcuno deve far parlare a mano.

## Cosa si rompe in produzione (e come lo leggi)

- **Postgres non parte dopo un aggiornamento.** Sintomo: i servizi che dipendono dal DB falliscono; nei log di Postgres, errori di versione dei dati. Causa: aggiornamento major del DB senza migrazione. Rimedio: aggiornamenti major pianificati con dump/restore, non "in place" alla cieca. È il motivo per cui il DB sta in un compose stabile che tocchi con cura.
- **Il reverse proxy non rinnova i certificati.** Sintomo: HTTPS scaduto, servizi irraggiungibili dal browser. Causa: rinnovo automatico fallito (DNS, rate limit della CA). Rimedio: monitora la scadenza dei certificati; il proxy deve loggare i rinnovi.
- **Un servizio riempie il disco.** Sintomo: tutto rallenta, scritture falliscono. Causa: log non ruotati, dati di esecuzione accumulati (n8n!), volumi cresciuti. Rimedio: rotazione log, retention, monitoraggio spazio disco.
- **Rete sbagliata: il servizio "non trova" il DB.** Sintomo: errori di connessione tra container. Causa: un servizio non è sulla rete `backend`, o il nome del servizio è sbagliato. Rimedio: verifica l'assegnazione alle reti nel compose.
- **Backup che gira ma non ripristina.** Sintomo: lo scopri solo al test di restore (per questo si fa). Causa: dump parziale, segreti mancanti, volume dimenticato. Rimedio: la checklist di restore mensile è fatta apposta per stanarlo prima del disastro.

Il filo: **i guasti di uno stack sovrano sono di infrastruttura (dischi, reti, certificati, versioni), e si leggono nei log dei servizi e nel monitoraggio.** Non sono misteri: sono le cose che un sysadmin conosce, ed è il motivo per cui uno stack sovrano ha bisogno di qualcuno che lo curi (vedi "quando non farlo").

## I costi: il rack o il VPS contro il canone perpetuo

Ordini di grandezza, stime dichiarate, su 3 anni:

| Voce | Stack sovrano | SaaS (M365/Google + CRM + BI + …) |
|---|---|---|
| **Infrastruttura** | VPS UE (~50-200 €/mese) o rack in ufficio (~1.500-4.000 € una tantum + elettricità) | incluso nei canoni |
| **Canoni per utente** | zero (i software self-hosted sono spesso open) | per-utente-per-mese, ×N dipendenti, ×36 mesi |
| **GPU per l'AI** (se serve) | ~800 € usata + elettricità | costo a token / add-on "copilot" per utente |
| **Manutenzione** | qualcuno che lo cura (interno o esterno) | "inclusa" (ma non controlli nulla) |
| **A fine 3 anni possiedi** | tutto: dati, sistema, libertà | niente: continui a pagare o resti bloccato |

Il conto puro degli euro spesso pende verso il sovrano già a medio termine, soprattutto crescendo il numero di utenti (i canoni per-utente scalano, l'infrastruttura no). Ma la voce che pesa di più non è in tabella: è **cosa possiedi alla fine** e **quanto sei libero.** Il SaaS è comodo e ha senso in molti casi; ma quando l'azienda cresce, i canoni scalano e il lock-in stringe, lo stack sovrano diventa non solo più economico ma più *tuo*. Il conto onesto mette in conto la libertà, non solo la fattura — come in tutta la [guida allo stack sovrano]({{ '/it/pillar/stack-sovrano/' | relative_url }}).

## Quando NON farlo

Onestà, sempre. Lo stack sovrano **non fa per te se:**

- **Non hai chi lo cura.** È la condizione numero uno. Uno stack self-hosted ha bisogno di manutenzione: aggiornamenti, backup, monitoraggio, i guasti di cui sopra. Senza qualcuno (interno o un partner esterno) che se ne occupa, uno stack trascurato diventa un rischio di sicurezza e un disastro in attesa. Meglio un SaaS ben gestito di un self-hosted abbandonato.
- **Sei piccolissimo e il SaaS ti basta.** Se sei in tre e Microsoft 365 copre tutto senza attriti, costruire uno stack sovrano è sovraingegneria. La sovranità conta quando i dati, i costi o il lock-in diventano un problema reale.
- **Ti serve tutto subito, senza transizione.** Se non puoi permetterti una migrazione a scaglioni e vuoi tutto operativo domani, il self-hosting non è la strada per partire (anche se può esserlo dove arrivare).
- **Il lock-in non ti preoccupa e i conti tornano.** Se il SaaS costa poco per la tua dimensione e non hai esigenze di sovranità sui dati, va benissimo restare. La sovranità è una risposta a un problema; se non hai quel problema, non ti serve la risposta.

La proporzione conta: lo stack sovrano è per chi ha **dati da proteggere, costi SaaS che scalano, o un lock-in che stringe** — e qualcuno che lo curi. Fuori da lì, il SaaS ben scelto è una scelta legittima, e dirlo fa parte del mestiere.

## Checklist operativa prima della produzione

- [ ] **Solo il reverse proxy** è esposto a internet; tutto il resto dietro.
- [ ] Reti Docker **segmentate**: `backend` `internal: true`, DB senza porte esposte.
- [ ] **IdP** proprio per l'identità; login unico gestito da te.
- [ ] **Domini e DNS** intestati a te.
- [ ] **Backup**: pg_dump + volumi + segreti + configurazioni, portati **fuori** dalla macchina.
- [ ] **Test di restore mensile** fatto, con RTO cronometrato.
- [ ] Versioni **fissate** (no `latest`); aggiornamenti a scaglioni con rollback possibile.
- [ ] **Staging** per provare gli aggiornamenti; mai aggiornare il venerdì.
- [ ] **Minimo privilegio**: l'agente AI vede solo viste dedicate, non l'ERP intero.
- [ ] Blast radius gestito: fondamenta stabili separate da ciò che iteri.
- [ ] Piano di **migrazione a scaglioni** definito, col vecchio che convive col nuovo.
- [ ] Qualcuno **cura** lo stack (interno o partner).

## Il verdetto: la sovranità è nell'architettura o non c'è

Uscire dall'ostaggio Microsoft/Google non è scaricare qualche container e sperare: è **architettura**. Sovrano vuol dire cinque cose concrete — dati esportabili, identità tua, DNS tuo, backup testati, offboarding possibile — e si costruisce con reti Docker segmentate (solo il proxy esposto, il DB su rete interna senza porte), blast radius gestito, backup che si ripristinano davvero (col test mensile), aggiornamenti disciplinati che evitano il lunedì morto, permessi al minimo (l'AI non vede l'ERP intero), e una migrazione a scaglioni che non ferma l'azienda. Il conto a tre anni spesso pende verso il sovrano già in euro; ma la voce che conta di più è la libertà — a fine corsa, o possiedi il tuo sistema o continui a pagare l'affitto restando in trappola. La sovranità o è nell'architettura, o è uno slogan.

Questo è il quadro d'insieme della [guida allo stack sovrano e all'AI in casa]({{ '/it/pillar/stack-sovrano/' | relative_url }}), di cui gli altri articoli sono i mattoni. Se vuoi disegnare lo stack sovrano sulla *tua* azienda — cosa migrare, in che ordine, con quali confini — parti da [chi sono e come lavoro]({{ site.main_site }}/biografia/) o scrivimi due righe in [contatti]({{ site.main_site }}/contatti/).

## FAQ

**1. "Sovrano" non è solo una parola di moda?**
Lo diventa se resta uno slogan. È sostanza se si traduce in architettura: dati esportabili, identità e DNS tuoi, backup testati, offboarding possibile, reti segmentate. Il test è concreto: se il tuo fornitore raddoppiasse i prezzi o chiudesse domani, saresti paralizzato o potresti spostarti? La risposta dice se sei sovrano davvero.

**2. Devo mettere tutto in un solo docker-compose?**
Meglio separare per blast radius: i fondamentali stabili (Postgres, proxy, IdP) in un compose che tocchi di rado, i servizi che iteri (n8n, AI, ERP) in compose separati. Così aggiorni un pezzo senza rischiare gli altri. Un compose unico è più semplice ma ha un raggio di danno più ampio.

**3. Perché il database non deve avere porte esposte?**
Perché un Postgres con la porta aperta su internet è uno degli errori di sicurezza più gravi e comuni. Nello stack sovrano il DB vive su una rete Docker `internal: true`, raggiungibile solo dai servizi interni, mai da fuori. Anche se un container venisse compromesso, il DB non è esposto.

**4. I backup non li fa già il sistema?**
Fare i backup e saperli ripristinare sono due cose diverse. Un backup non testato è una speranza. Serve salvare dump del DB, volumi, segreti e configurazioni *fuori* dalla macchina, e fare un **test di restore mensile** su una macchina di prova, cronometrando il tempo: è il tuo tempo di ripristino reale. Se non l'hai mai testato, non sai se funziona.

**5. Come evito il "lunedì morto" dopo un aggiornamento?**
Con metodo: versioni fissate (mai `latest`), aggiornamenti un pezzo alla volta, prova su staging prima della produzione, capacità di rollback, e la regola di non aggiornare il venerdì. Il self-hosting non è pericoloso di per sé: lo è senza disciplina. Con questi accorgimenti gli aggiornamenti diventano routine.

**6. L'AI nello stack può vedere tutti i miei dati?**
Non deve. "L'AI gira in casa" (sovranità) è diverso da "l'AI vede tutto" (falla). Dai al worker AI un utente di database con permessi di sola lettura sulle sole viste che gli servono, già filtrate/mascherate — non l'accesso all'ERP intero. La rete interna è un confine, i permessi applicativi sono il secondo.

**7. Quanto costa rispetto a Microsoft 365?**
Su 3 anni, spesso lo stack sovrano costa meno, soprattutto crescendo gli utenti: i canoni SaaS scalano per-utente, l'infrastruttura no. Ma la voce che pesa di più non è in fattura: a fine 3 anni, con il sovrano possiedi il sistema e sei libero; col SaaS continui a pagare e resti nel lock-in. Il conto onesto include la libertà.

**8. Da dove comincio la migrazione?**
A scaglioni, dal più facile: prima la posta/PEC, poi i file, poi l'automazione, poi la BI, e per ultimo il CRM/ERP (il più delicato). Ogni scaglione porta valore da solo e convive col vecchio durante la transizione. Il big-bang è il modo migliore di fallire; gli scaglioni rendono la migrazione reversibile e sopportabile.

**9. Serve un rack in ufficio o basta un VPS?**
Dipende. Un VPS in UE (poche decine-centinaia di € al mese) è ottimo per iniziare, senza hardware da gestire fisicamente. Un rack in ufficio ha senso per volumi alti, dati che vuoi fisicamente in sede, o quando l'ammortamento conviene. Molti partono da VPS e valutano il rack dopo. Per l'AI, la GPU può stare on-premise anche se il resto è su VPS.

**10. E se non ho nessuno che lo gestisca?**
Allora non farlo da solo, o non farlo ancora: uno stack self-hosted senza manutenzione è un rischio, peggio di un SaaS ben gestito. Le opzioni sono due: qualcuno all'interno che lo cura, o un partner esterno che se ne occupa. La sovranità richiede qualcuno che tenga le chiavi e faccia i tagliandi — dirlo onestamente fa parte del mestiere.
