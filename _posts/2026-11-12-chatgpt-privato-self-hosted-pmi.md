---
lang: it
permalink: /it/blog/chatgpt-privato-self-hosted-pmi/
alt_url: /en/blog/private-chatgpt-self-hosted-sme/
title: "Come montare un \"ChatGPT privato\" su due GPU usate: modelli, coda, rete interna e cosa dire ai dipendenti al posto del divieto inutile"
date: 2026-11-12 07:30:00 +0200
author: "Antonio Trento"
description: "Progetto interno per una PMI: chat aziendale self-hosted su due GPU usate, dietro SSO, con modelli open-weight su vLLM, gateway con quote per ufficio, dati che restano in LAN, policy in 10 regole, formazione di 45 minuti e metriche di adozione al posto del divieto di ChatGPT."
keywords: ["chatgpt privato self hosted pmi", "vllm dual gpu", "llm interno azienda", "alternativa chatgpt", "policy shadow it", "open webui sso"]
image: /assets/images/posts/chatgpt-privato-self-hosted-pmi.jpg
pillar: modelli-costi-privacy
related: [/it/blog/vllm-vs-ollama-produzione/, /it/blog/gdpr-chatgpt-crm/]
---

## Il divieto di ChatGPT crea Shadow IT

La circolare arriva un lunedì: "È vietato l'utilizzo di ChatGPT e di strumenti analoghi con dati aziendali". La motivazione è sensata — contratti, listini, dati di clienti incollati in un servizio esterno senza nessun accordo — e l'effetto, nella maggior parte delle PMI che ho visto, è sempre lo stesso: l'uso non si ferma, si sposta. Dal PC aziendale al telefono personale. Dall'account aziendale (che magari nessuno aveva) all'account privato gratuito, con le impostazioni di default. Dalla scrivania al bagno, letteralmente: la foto del contratto fatta col telefono e caricata nell'app.

Il divieto non ha tolto il rischio. Ha tolto la **visibilità** sul rischio. Prima l'IT poteva almeno sapere che lo strumento veniva usato; dopo, l'uso è diventato invisibile e quindi ingestibile. È Shadow IT da manuale: le persone hanno un problema reale (scrivere più in fretta, riassumere, tradurre, sistemare una mail difficile), lo strumento ufficiale non c'è, e allora usano quello che hanno in tasca.

La risposta che propongo a molte PMI non è "sbloccate ChatGPT" e non è "vietatelo meglio". È dare alle persone un'alternativa interna che sia **abbastanza buona** da rendere inutile quella personale: un **ChatGPT privato self-hosted per la PMI**, che gira su un server in azienda con due GPU usate, dietro il login aziendale, con i dati che non escono dalla rete, e con una policy di dieci regole scritte in italiano normale.

Questo pezzo è il progetto completo: requisiti, hardware, scelta tra un modello grande su due GPU o due modelli separati, interfaccia, coda e quote tra uffici, cosa è permesso incollare, la formazione da 45 minuti e le metriche che ti dicono se sta funzionando. Con i costi veri e con una sezione onesta su quando non conviene.

## È per te / non è per te

È per te se:

- hai tra 15 e 150 persone che scrivono, leggono e riassumono documenti tutto il giorno (amministrazione, commerciale, customer care, uffici tecnici, studi professionali);
- hai già vietato o stai per vietare ChatGPT, oppure sai che lo usano comunque;
- hai una stanza server, anche piccola, o un rack in un'unità di colocation in Italia, e qualcuno che sa amministrare Linux e Docker.

Non è per te se ti serve la qualità del miglior modello di frontiera su compiti di ragionamento complesso: un modello open-weight su due GPU da gaming non è quello, e prometterlo sarebbe disonesto. Non è per te nemmeno se sei in cinque: un account business di un fornitore con un buon accordo sul trattamento dei dati costa meno e ti toglie l'hardware dal problema. Ne ho parlato nel pezzo su [GDPR, ChatGPT e dati del CRM]({{ '/it/blog/gdpr-chatgpt-crm/' | relative_url }}).

## Requisiti: auth, audit, no training sui dati

Prima dell'hardware, i requisiti. Sono questi a decidere l'architettura, non il contrario.

**Autenticazione aziendale.** Ogni utente entra con l'account aziendale (Microsoft Entra ID, Google Workspace, o un identity provider interno come Keycloak o Authentik) via OIDC, con secondo fattore. Niente account locali creati a mano, niente password condivise. Quando una persona lascia l'azienda e il suo account viene disattivato, perde l'accesso anche alla chat, senza che nessuno debba ricordarselo.

**Dati in LAN.** I prompt, le risposte, i documenti caricati e le conversazioni salvate restano su storage aziendale. Il server di inferenza non ha uscita verso internet: aggiornamenti e nuovi modelli entrano da una finestra controllata, non da un'immagine Docker che telefona a casa quando vuole.

**Nessun addestramento sui dati.** Con un modello self-hosted questo è vero per costruzione: i pesi non cambiano con l'uso. Ma va verificato anche sul resto: l'interfaccia web non deve mandare telemetria, le funzioni di ricerca web devono essere disattivate o controllate, nessun "connettore" verso servizi esterni deve essere attivo di default.

**Audit proporzionato.** Qui c'è una tensione tutta italiana che va presa sul serio. Vuoi poter ricostruire un incidente (chi ha caricato quel file? da quale ufficio è partita quella richiesta anomala?), ma registrare in modo sistematico il contenuto delle conversazioni dei dipendenti ti porta dritto sul terreno dei controlli a distanza dei lavoratori (art. 4 dello Statuto dei lavoratori) e del GDPR. La strada che consiglio:

- registrare **metadati** (utente, ora, ufficio, modello, token in ingresso e uscita, esito) nel gateway;
- lasciare le **conversazioni** nella disponibilità dell'utente, con una conservazione definita (es. 90 giorni) e la possibilità di cancellarle;
- non usare i log per valutare la prestazione delle persone, e scriverlo nell'informativa;
- far validare impostazione e informativa dal DPO o dal consulente del lavoro, ed eventualmente passare dall'accordo sindacale dove serve.

Non è burocrazia: è ciò che rende lo strumento accettabile per le persone che dovrebbero usarlo. Se il messaggio percepito è "ti diamo una chat così ti controlliamo meglio", torneranno al telefono personale.

**Disponibilità ragionevole.** Non serve un cluster ad alta disponibilità: serve che il servizio sia su in orario d'ufficio, che si riavvii da solo, che un guasto si risolva in ore, non in settimane. Un singolo server con un piano di ripristino scritto va bene per quasi tutte le PMI.

## Due GPU: tensor parallel vs due modelli

Due GPU usate da 24 GB (la scelta tipica sono due schede di fascia alta della generazione precedente) ti danno 48 GB di VRAM complessivi. Il dilemma è come usarli. Ci sono due strade, con compromessi diversi.

### Opzione A: un modello più grande su entrambe (tensor parallel)

Con vLLM e `--tensor-parallel-size 2`, un singolo modello viene diviso tra le due schede: ogni strato è spezzato a metà e le GPU lavorano insieme su ogni token. Ti permette di servire un modello da 30–35 miliardi di parametri quantizzato a 4 bit (AWQ o GPTQ), con abbastanza VRAM residua per la cache KV di una decina di conversazioni contemporanee con contesti di qualche migliaio di token.

Pro:
- un solo modello, di qualità più alta: migliori risposte su scrittura, sintesi, italiano, istruzioni lunghe;
- un solo endpoint, una sola configurazione.

Contro:
- le schede consumer di solito non hanno un collegamento veloce dedicato tra loro: comunicano via PCIe. Funziona, ma il parallelismo ha un costo e la latenza del primo token cresce un po';
- se una GPU si guasta, il servizio è giù finché non la sostituisci (o non riparti in modalità degradata con un modello più piccolo);
- tutto il traffico compete per lo stesso modello.

### Opzione B: due modelli separati, una GPU ciascuno

GPU 0 serve un modello generalista da 12–24 miliardi di parametri quantizzato; GPU 1 serve un secondo modello (per esempio uno più piccolo e veloce per i compiti brevi, o uno specializzato nel codice) più il modello di embedding per la ricerca nei documenti.

Pro:
- isolamento: un guasto o un sovraccarico su una scheda non ferma l'altra;
- puoi dirottare i compiti brevi (riscrivi questa mail, traduci questo paragrafo) sul modello veloce e lasciare quello grande ai compiti lunghi;
- aggiornamenti più semplici: cambi un modello alla volta.

Contro:
- ogni modello è più piccolo, quindi la qualità massima è più bassa;
- due endpoint da gestire, e l'utente deve capire quale scegliere (o lo sceglie un router).

### La scelta che faccio di solito

| Criterio | Tensor parallel (A) | Due modelli (B) |
|---|---|---|
| Qualità massima della risposta | Più alta | Più bassa |
| Utenti contemporanei sostenibili | Buona, su un solo modello | Buona, distribuita su due |
| Latenza primo token | Leggermente più alta | Più bassa sul modello piccolo |
| Resilienza a un guasto GPU | Bassa | Media |
| Semplicità per l'utente | Alta (un solo modello) | Media (due scelte) |
| Spazio per embedding e RAG | Ridotto | Sulla seconda GPU |
| Complessità operativa | Media | Media |

Per una PMI con 20–60 utenti che usano la chat soprattutto per scrivere e riassumere in italiano, parto quasi sempre dall'**opzione A**: la qualità percepita è il fattore che decide se le persone abbandonano il telefono personale, e un modello da ~30B si sente. Passo all'opzione B quando ci sono molti utenti contemporanei con richieste brevi, o quando la ricerca nei documenti aziendali è un requisito importante dal primo giorno.

Sulla scelta del motore di inferenza non mi dilungo: per più di qualche utente contemporaneo serve un server con batching continuo come vLLM, non uno strumento pensato per il singolo sviluppatore. Il confronto completo è nel pezzo su [vLLM vs Ollama in produzione]({{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }}).

Sui modelli: scegli tra le famiglie open-weight con **licenza chiara per uso commerciale** e buon italiano, verificando la licenza della versione specifica (alcune hanno clausole sul numero di utenti o sull'uso). Prova almeno due candidati sullo stesso set di 30–50 compiti reali presi dagli uffici (mail, sintesi di verbali, risposte a clienti, traduzioni), valutati da chi farà quel lavoro, non da un benchmark.

### Hardware di esempio

Una configurazione realistica, con prezzi indicativi del mercato dell'usato e del nuovo nel 2026 (stime da verificare):

| Componente | Scelta di esempio | Costo indicativo |
|---|---|---|
| 2 × GPU usate da 24 GB | Schede di fascia alta generazione precedente | 1.300–1.800 € in totale |
| Scheda madre | Piattaforma workstation con due slot PCIe x16 elettrici (o x8/x8) ben distanziati | 300–600 € |
| CPU | 12–16 core | 300–500 € |
| RAM | 128 GB DDR4/DDR5 | 250–450 € |
| Storage | 2 × NVMe 2 TB in mirror (modelli, DB, conversazioni) | 250–350 € |
| Alimentatore | 1.200–1.600 W, certificazione alta | 200–300 € |
| Case / raffreddamento | Rack 4U o tower con flusso d'aria serio | 150–300 € |
| UPS | Adeguato al picco di consumo | 300–500 € |
| **Totale** | | **circa 3.000–4.800 €** |

Tre avvertenze pratiche sulle GPU usate: verifica la provenienza (schede usate per il mining h24 possono avere ventole e pad termici consumati), fai un test di stress di qualche ora prima di metterle in produzione, e misura le temperature della memoria, non solo del chip. Due schede da 350 W una accanto all'altra in un case chiuso sono un piccolo forno: lo spazio tra gli slot e il flusso d'aria contano più della marca.

## Architettura LAN

Ecco come metto insieme i pezzi. Tutto in Docker Compose su un singolo server, rete interna, nessuna esposizione su internet.

**Componenti:**

1. **Reverse proxy** (Caddy o Traefik) con certificato interno, unico punto di ingresso dalla LAN. Il confronto tra le opzioni è nel pezzo su [Traefik, Caddy e Cloudflare Tunnel]({{ '/it/blog/traefik-vs-caddy-vs-cloudflare-tunnel/' | relative_url }}); qui il tunnel non serve, perché il servizio è solo interno.
2. **Interfaccia chat** (Open WebUI o un'alternativa simile) collegata all'identity provider via OIDC. Salva conversazioni e documenti caricati su Postgres e su un volume locale.
3. **Gateway LLM** (LiteLLM o un proxy equivalente): riceve tutte le richieste dalla UI, applica quote e limiti per ufficio, registra i metadati, inoltra al motore di inferenza. È il punto dove si decide il fair share.
4. **Motore di inferenza** (vLLM) sulle due GPU, con API compatibile OpenAI, raggiungibile **solo** dal gateway.
5. **Postgres** per UI e gateway, con backup notturno.
6. **Embedding e indice documenti** (opzionale): modello di embedding e indice vettoriale per la ricerca su documenti caricati o su una base documentale interna.

**Confini:**

- la UI non parla direttamente con vLLM: passa sempre dal gateway;
- vLLM e gateway sono su una rete Docker interna senza uscita verso internet;
- la UI ha uscita bloccata a livello di firewall: niente ricerca web, niente download di modelli, niente telemetria;
- i modelli entrano sul server da una cartella preparata dall'amministratore, verificata con hash;
- nessun componente ha accesso ai file server o al gestionale aziendale: chi vuole lavorare su un documento lo carica esplicitamente.

Quest'ultimo punto è una scelta di prudenza per la prima fase. Collegare la chat ai sistemi aziendali (CRM, gestionale, cartelle condivise) è un progetto diverso, con permessi per documento e rischi di prompt injection: lo si fa dopo, con un'architettura RAG pensata apposta.

```yaml
# docker-compose.yml (estratto) — server chat interna
services:
  vllm:
    image: vllm/vllm-openai:v0.x   # versione fissata, non "latest"
    command: >
      --model /models/modello-30b-awq
      --served-model-name chat-aziendale
      --tensor-parallel-size 2
      --max-model-len 16384
      --gpu-memory-utilization 0.90
      --max-num-seqs 24
    volumes:
      - /srv/models:/models:ro
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 2
              capabilities: [gpu]
    ipc: host
    networks: [inferenza]
    restart: unless-stopped

  gateway:
    image: ghcr.io/berriai/litellm:v1.x   # versione fissata
    command: ["--config", "/app/config.yaml", "--port", "4000"]
    volumes:
      - ./litellm/config.yaml:/app/config.yaml:ro
    environment:
      DATABASE_URL_FILE: /run/secrets/litellm_db_url
    secrets: [litellm_db_url, litellm_master_key]
    networks: [inferenza, applicazione]
    restart: unless-stopped

  chat-ui:
    image: ghcr.io/open-webui/open-webui:v0.x   # versione fissata, verifica la licenza
    environment:
      ENABLE_OAUTH_SIGNUP: "true"
      OAUTH_PROVIDER_NAME: "Account aziendale"
      OPENID_PROVIDER_URL: "https://idp.interno.esempio/.well-known/openid-configuration"
      OPENAI_API_BASE_URL: "http://gateway:4000/v1"
      ENABLE_WEB_SEARCH: "false"
      ENABLE_SIGNUP: "false"
    volumes:
      - chatdata:/app/backend/data
    networks: [applicazione]
    restart: unless-stopped

networks:
  inferenza:
    internal: true
  applicazione: {}

volumes:
  chatdata: {}

secrets:
  litellm_db_url:
    file: ./secrets/litellm_db_url
  litellm_master_key:
    file: ./secrets/litellm_master_key
```

I nomi delle variabili di configurazione cambiano tra le versioni di questi progetti: prendi lo schema come struttura, e verifica le opzioni esatte sulla documentazione della versione che installi. La regola che non cambia è fissare le versioni delle immagini e aggiornarle a mano dopo averle provate.

## UI: Open WebUI o simile, dietro SSO

L'interfaccia è la parte che decide l'adozione. Se è più scomoda del ChatGPT personale, non la userà nessuno, indipendentemente da quanto sia sicura.

Cosa deve avere, al minimo:

- **login con l'account aziendale**, un clic, senza registrazioni;
- **conversazioni salvate** e ricercabili dall'utente;
- **caricamento di documenti** (PDF, Word, testo) con estrazione del testo e possibilità di chiedere sul contenuto;
- **prompt salvati e condivisi per ufficio**: "risposta a reclamo cliente", "sintesi di un verbale", "traduzione tecnica IT→EN" — sono questi a far risparmiare tempo vero, perché incorporano il modo di lavorare dell'azienda;
- **un banner sobrio e sempre visibile** con il promemoria delle regole principali (vedi sotto).

Cosa disattivare all'inizio:

- ricerca web e plugin che chiamano servizi esterni;
- la possibilità per gli utenti di aggiungere modelli o endpoint propri;
- la condivisione pubblica delle conversazioni tramite link;
- la registrazione libera di nuovi utenti.

Su Open WebUI in particolare: è il progetto più diffuso per questo uso, ma negli ultimi tempi ha cambiato più volte licenza e condizioni sul branding. Prima di adottarlo, leggi la licenza della versione che installi e verifica che sia compatibile con il tuo uso interno. Se non lo è, esistono alternative con licenze più permissive: l'architettura sopra non cambia, perché parla con il gateway tramite un'API standard.

## Coda e fair share tra uffici

Con 40 utenti e una capacità di 15–25 conversazioni contemporanee, nella maggior parte del tempo non c'è contesa. Ma ci sono momenti — il lunedì mattina, la fine del mese in amministrazione — in cui un ufficio può saturare il servizio. Peggio: una sola persona che carica un PDF da 300 pagine e chiede "riassumi tutto" può occupare il modello per minuti.

Il fair share si fa nel gateway, con tre leve:

1. **Una chiave virtuale per ufficio** (o per gruppo dell'identity provider), con limiti di richieste al minuto e di token al minuto.
2. **Limiti per singola richiesta**: dimensione massima del contesto in ingresso, numero massimo di token in uscita. Il PDF da 300 pagine va gestito con la ricerca nei documenti, non incollato intero nel contesto.
3. **Priorità**: i compiti interattivi brevi hanno precedenza su quelli lunghi. vLLM supporta politiche di scheduling con priorità; in alternativa, un secondo modello più piccolo (opzione B) assorbe le richieste brevi.

```yaml
# litellm/config.yaml (estratto)
model_list:
  - model_name: chat-aziendale
    litellm_params:
      model: openai/chat-aziendale
      api_base: http://vllm:8000/v1
      api_key: "non-usata-in-rete-interna"
      max_tokens: 2048

general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY

litellm_settings:
  # nessun callback verso servizi esterni
  success_callback: []
  failure_callback: []

# le chiavi per ufficio si creano via API del gateway, con limiti espliciti, ad esempio:
#   amministrazione: rpm 60,  tpm 120000, max_parallel_requests 6
#   commerciale:     rpm 60,  tpm 120000, max_parallel_requests 6
#   ufficio_tecnico: rpm 40,  tpm 200000, max_parallel_requests 4
#   direzione:       rpm 20,  tpm  60000, max_parallel_requests 2
```

I numeri vanno tarati sui primi due mesi di uso reale: parti larghi, guarda i log, stringi dove serve. L'obiettivo non è razionare, è evitare che un ufficio renda la chat inutilizzabile per gli altri nel momento sbagliato.

Una nota sull'esperienza utente: quando un limite scatta, il messaggio deve essere comprensibile ("Il servizio è molto usato in questo momento, riprova tra un minuto" oppure "Il documento è troppo lungo per essere incollato intero, usa il caricamento documenti"), non un errore HTTP. Le persone tollerano un'attesa spiegata; abbandonano un errore incomprensibile.

## Cosa è permesso incollare

Qui c'è il cambio di prospettiva più importante rispetto al divieto. Con una chat interna, la domanda non è più "cosa NON devo mai incollare" — perché la risposta onesta, con un servizio esterno senza accordi, era "quasi tutto" — ma "cosa è adatto a questo strumento". La chat interna può ricevere molto di più, ma non tutto.

### La policy in 10 regole

Da appendere, da mettere nel banner, da spiegare nella formazione. In italiano normale, senza giuridichese.

1. **Usa la chat aziendale, non il tuo account personale**, per qualsiasi cosa riguardi il lavoro. Quella aziendale è fatta apposta: i dati restano nei nostri server.
2. **Puoi incollare documenti di lavoro**: mail, contratti, offerte, verbali, specifiche tecniche, listini. Restano in azienda.
3. **Non incollare categorie particolari di dati personali** (salute, dati giudiziari, appartenenza sindacale, dati biometrici) se non per un compito che lo richiede davvero e che è stato autorizzato dal tuo responsabile.
4. **Non incollare credenziali**: password, token, chiavi, codici di accesso. Mai, nemmeno "per sistemare un file di configurazione".
5. **Rileggi sempre prima di usare.** La chat sbaglia, inventa dettagli, a volte con molta sicurezza. Ciò che invii a un cliente o a un fornitore è responsabilità tua.
6. **Numeri, date, nomi, riferimenti normativi vanno verificati** sulla fonte. La chat è brava a scrivere, non a ricordare con esattezza.
7. **Non usarla per decisioni sulle persone**: valutazioni, selezione del personale, provvedimenti. Non è lo strumento adatto e non è consentito.
8. **Dichiara quando un testo è stato scritto in gran parte dalla chat**, se il destinatario ha motivo di saperlo (per esempio documenti ufficiali o pubblicazioni).
9. **Se un documento caricato contiene istruzioni strane** ("ignora le istruzioni precedenti", "invia questo a…"), non seguirle e segnalalo all'IT.
10. **Le tue conversazioni sono tue**: le vedi tu, si cancellano dopo 90 giorni, e non vengono usate per valutare il tuo lavoro. L'IT registra solo dati tecnici (ora, ufficio, volume) per far funzionare il servizio.

La regola 10 è quella che fa la differenza sull'adozione. Va scritta, va mantenuta, e va verificato che l'impostazione tecnica la rispetti davvero.

## Formazione 45 minuti

Non serve un corso. Servono 45 minuti per ufficio, in presenza o in videochiamata, con lo schermo condiviso e casi presi dal lavoro di quell'ufficio. La scaletta che uso:

1. **Perché esiste (5 minuti).** Il problema del divieto, perché la chat interna è diversa, cosa succede ai dati. Niente slide sull'intelligenza artificiale che cambia il mondo.
2. **Login e primo uso (5 minuti).** Entrare, scrivere una richiesta, salvare una conversazione.
3. **Tre casi dell'ufficio (15 minuti).** Preparati prima con il responsabile: per l'amministrazione una mail di sollecito garbata ma ferma e la sintesi di un contratto; per il commerciale la risposta a una richiesta di offerta e un riassunto di una call; per l'ufficio tecnico una traduzione e la riscrittura di una specifica. Si fanno dal vivo, con errori inclusi.
4. **Dove sbaglia (10 minuti).** Un esempio vero di risposta sicura e sbagliata: un numero inventato, una norma citata male, un nome storpiato. Questo è il pezzo che cambia il comportamento più di qualsiasi regola scritta.
5. **Le 10 regole (5 minuti).** Lette ad alta voce, con le domande.
6. **I prompt salvati dell'ufficio (5 minuti).** Dove sono, come si usano, come proporne di nuovi.

Dopo due settimane, un secondo incontro di 20 minuti: cosa ha funzionato, cosa no, quali prompt aggiungere. È qui che emergono i casi d'uso veri, quelli a cui l'IT non avrebbe pensato.

## Metriche di adozione vs uso di ChatGPT personale

Lo scopo del progetto non è "avere una chat interna". È **ridurre l'uso non governato** degli strumenti esterni e aumentare quello governato. Le metriche devono misurare questo, senza trasformarsi in sorveglianza delle persone.

**Metriche di adozione (dal gateway, aggregate per ufficio):**

- utenti attivi settimanali, in percentuale degli abilitati;
- richieste per utente attivo a settimana;
- distribuzione per tipo di compito (se usi i prompt salvati, sai quali sono usati);
- tempo di risposta medio e percentile 95, per capire se la capacità basta.

**Metriche di sostituzione (aggregate, non per persona):**

- volume di traffico dalla rete aziendale verso i principali servizi di chat esterni, misurato a livello di proxy o DNS **in forma aggregata**: l'andamento nel tempo è ciò che conta, non chi;
- risposte a un breve questionario anonimo dopo un mese: "usi ancora strumenti personali per il lavoro? per cosa?". Le risposte ti dicono cosa manca alla chat interna.

**Metriche di qualità:**

- un pulsante "risposta utile / non utile" nella UI, con commento facoltativo;
- revisione mensile di un campione di feedback negativi (con il consenso dell'utente, o su conversazioni che l'utente sceglie di condividere).

Un obiettivo realistico, che ho visto raggiungere più volte, è superare il 60–70% di utenti attivi settimanali entro tre mesi negli uffici che scrivono molto. Se dopo tre mesi sei sotto il 30%, il problema è quasi sempre uno di questi: modello troppo debole per l'italiano dell'ufficio, interfaccia lenta nelle ore di punta, o il sospetto che le conversazioni siano lette da qualcuno.

## Percorso di implementazione, a step

1. **Raccogli 30–50 compiti reali** dagli uffici (anonimizzati dove serve): sono il tuo banco di prova per modelli e prompt.
2. **Definisci i requisiti** con il responsabile privacy: autenticazione, conservazione delle conversazioni, metadati registrati, informativa ai dipendenti.
3. **Compra o recupera l'hardware**, fai lo stress test delle GPU, installa il sistema operativo, i driver e il runtime per container.
4. **Prova due o tre modelli** con vLLM sul banco di prova, con valutazione fatta dagli utenti finali. Scegli la configurazione (tensor parallel o due modelli).
5. **Monta il gateway** con chiavi per ufficio e limiti iniziali larghi.
6. **Monta la UI** dietro SSO, con ricerca web e connettori esterni disattivati, e l'uscita internet bloccata dal firewall.
7. **Prepara i prompt salvati** per i primi due uffici.
8. **Pilota con un ufficio** per due settimane. Misura tempi di risposta, feedback, problemi.
9. **Formazione** ufficio per ufficio, con la scaletta da 45 minuti.
10. **Comunica la policy** e, solo a quel punto, aggiorna la circolare: non "è vietato ChatGPT", ma "per il lavoro si usa la chat aziendale".
11. **Backup e ripristino**: Postgres, volumi della UI, configurazione. Prova il ripristino su un'altra macchina; il metodo è quello del pezzo su [backup e restore di uno stack Docker con Postgres]({{ '/it/blog/backup-docker-postgres-n8n/' | relative_url }}).
12. **Revisione a 30 e 90 giorni** su adozione, quote, modello.

## Fallimenti tipici e come li riconosci dai log

**Memoria GPU esaurita sotto carico.**

```text
vllm  | WARNING scheduler: Sequence group 3f1a… is preempted by PreemptionMode.RECOMPUTE because not enough KV cache space
vllm  | WARNING scheduler: Sequence group 91bc… is preempted by PreemptionMode.RECOMPUTE ...
```

Le richieste vengono sospese e ricalcolate perché la cache KV è piena: troppi utenti con contesti lunghi. Rimedi: ridurre `--max-model-len`, abbassare `--max-num-seqs`, limitare la lunghezza dei prompt nel gateway, spostare i documenti lunghi sulla ricerca.

**Un ufficio che satura.**

```text
litellm | 429 key_alias=commerciale rpm_limit_reached current_rpm=61 limit=60
litellm | 429 key_alias=commerciale rpm_limit_reached current_rpm=63 limit=60
```

Se capita ogni giorno alla stessa ora, il limite è troppo stretto o c'è un uso automatico (qualcuno ha collegato uno script alla chiave dell'ufficio). Guarda il client che fa le richieste.

**Latenza alta del primo token.** Il percentile 95 del tempo al primo token supera i 5–8 secondi nelle ore di punta: gli utenti percepiscono il servizio come lento e tornano al telefono. Va letto insieme al numero di richieste in coda. È il segnale per valutare il secondo modello piccolo per le richieste brevi.

**Temperature delle GPU.**

```text
nvidia-smi | GPU 1  Temp 87C  Mem Temp 104C  Power 342W / 350W  Clocks throttled: HW_THERMAL
```

La seconda scheda, quella che respira l'aria calda della prima, va in throttling. Non è un problema software: è flusso d'aria. Se non lo sistemi, prima rallenta e poi si rompe.

**Tentativi di uscita bloccati.**

```text
firewall | DROP src=172.20.0.5 (chat-ui) dst=… dport=443
```

La UI sta cercando di contattare un servizio esterno: telemetria, controllo aggiornamenti, una funzione attivata per errore. Va capito cosa e disattivato a configurazione, non solo bloccato.

**Adozione che cala dopo il primo mese.** Non è nei log del server, è nelle metriche: utenti attivi settimanali in discesa costante. Quasi sempre è qualità percepita o velocità. Chiedi a cinque persone, a voce, perché hanno smesso.

## Costi: ordini di grandezza

Stime indicative per 40 utenti, da verificare sul tuo caso.

| Voce | Ordine di grandezza (stima) | Note |
|---|---|---|
| Hardware (vedi tabella sopra) | 3.000–4.800 € una tantum | Ammortizzato su 3 anni: 85–135 €/mese |
| Energia | 40–80 €/mese | Media 200–350 W sulle 24 ore ≈ 150–250 kWh/mese a ~0,30 €/kWh |
| Setup iniziale (modelli, gateway, UI, SSO, rete) | 8–15 giorni/uomo | Dipende dall'identity provider e dalla rete |
| Formazione e prompt per ufficio | 1–2 giorni/uomo per ufficio | Incluso il secondo incontro |
| Manutenzione | 1–2 giorni/uomo al mese | Aggiornamenti, modelli, quote, supporto |
| Alternativa: account business di un servizio esterno | 20–30 €/utente/mese | 40 utenti ≈ 800–1.200 €/mese |

Il confronto puramente economico, su 40 utenti e tre anni, è spesso favorevole alla soluzione interna anche contando la manutenzione; ma la differenza non è enorme, e non è il motivo principale. I motivi principali sono il controllo dei dati e la possibilità di adattare lo strumento all'azienda (prompt, documenti, integrazioni future). Se l'unico argomento fosse il costo, ti direi di rifare il conto con il pezzo sul [TCO di un LLM self-hosted contro un'API]({{ '/it/blog/tco-gpt-4o-vs-llm-self-hosted/' | relative_url }}).

## Quando NON farlo

- **Quando sei sotto le 15 persone** e non hai nessuno che amministri un server. Un servizio business esterno con accordo sul trattamento dei dati, configurato bene, è più semplice e più sicuro di un server che nessuno aggiorna.
- **Quando il lavoro richiede il ragionamento dei modelli di frontiera** (analisi complesse, codice difficile, problemi matematici): due GPU usate non ci arrivano. Valuta un servizio esterno per quei casi specifici, con regole precise su quali dati possono uscire.
- **Quando non c'è sponsor in direzione.** Senza qualcuno che dica "per il lavoro si usa questa", la chat interna diventa un'opzione in più e il telefono personale resta più comodo.
- **Quando l'impostazione privacy è "registriamo tutto, poi vediamo".** Meglio non partire che partire con lo strumento percepito come strumento di controllo: brucia la fiducia per anni.
- **Quando il vero bisogno è un'integrazione** (rispondere ai clienti dal CRM, leggere le fatture, cercare nei contratti). Una chat generalista non risolve quei problemi: servono flussi dedicati.

## Checklist operativa

- [ ] Banco di prova di 30–50 compiti reali, valutato da chi farà quel lavoro.
- [ ] Licenze di modello e interfaccia verificate per l'uso interno commerciale.
- [ ] GPU testate sotto stress con temperature della memoria nella norma.
- [ ] Login solo via identity provider aziendale, con secondo fattore; registrazione libera disattivata.
- [ ] vLLM raggiungibile solo dal gateway, su rete interna senza uscita.
- [ ] Uscita internet della UI bloccata dal firewall; ricerca web e connettori esterni disattivati.
- [ ] Versioni delle immagini fissate; aggiornamenti manuali dopo prova.
- [ ] Chiavi per ufficio nel gateway con limiti di richieste, token e parallelismo.
- [ ] Limiti di lunghezza del contesto e messaggi d'errore comprensibili.
- [ ] Conservazione delle conversazioni definita (es. 90 giorni) e cancellazione possibile per l'utente.
- [ ] Solo metadati nei log del gateway; informativa ai dipendenti validata da DPO o consulente del lavoro.
- [ ] Policy in 10 regole pubblicata e visibile nella UI.
- [ ] Formazione da 45 minuti fatta per ogni ufficio, con casi reali.
- [ ] Backup di Postgres e dei volumi, con ripristino provato.
- [ ] Metriche di adozione e di sostituzione definite, revisione a 30 e 90 giorni in calendario.

## Il verdetto

Il divieto di ChatGPT è la risposta che sembra prudente e produce l'effetto opposto: sposta l'uso dove non lo vedi più. Un ChatGPT privato self-hosted per la PMI, su due GPU usate e un server ben configurato, non è il miglior modello del mondo — ed è giusto dirlo alle persone — ma è abbastanza buono per scrivere, riassumere, tradurre e sistemare documenti in italiano, con i dati che restano in azienda e un'impostazione che le persone possono accettare.

La parte tecnica è la più facile: vLLM sulle due schede, un gateway con quote per ufficio, un'interfaccia dietro SSO, una rete senza uscita. La parte che decide il successo è tutta umana: una policy di dieci regole che dice cosa *si può* fare, quarantacinque minuti di formazione con casi veri e un errore mostrato dal vivo, e la promessa mantenuta che le conversazioni non diventano uno strumento di controllo.

Se stai valutando un'alternativa interna al divieto e vuoi dimensionarla sul tuo numero di persone e sui tuoi documenti, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e il resto del lavoro su [antoniotrento.net]({{ site.main_site }}/). Il quadro su modelli, costi e privacy è raccolto nella guida su [modelli, costi e privacy]({{ '/it/pillar/modelli-costi-privacy/' | relative_url }}).

## FAQ

### Cos'è un ChatGPT privato self-hosted?

È un'interfaccia di chat simile a quelle dei servizi pubblici, ma che gira su server dell'azienda con un modello open-weight. Le richieste, le risposte e i documenti caricati restano nella rete aziendale, l'accesso avviene con l'account aziendale e l'azienda decide regole, conservazione e limiti di utilizzo.

### Bastano due GPU usate per una PMI?

Per 20–60 utenti che usano la chat per scrivere, riassumere e tradurre, due GPU da 24 GB sono in genere sufficienti per servire un modello da circa 30 miliardi di parametri quantizzato, con una decina o più di conversazioni contemporanee. Non bastano per offrire la qualità dei modelli di frontiera su compiti di ragionamento complesso.

### Meglio un modello grande su due GPU o due modelli separati?

Un modello grande in tensor parallel offre risposte di qualità più alta e un'esperienza più semplice; due modelli separati offrono più resilienza e permettono di dedicare una GPU alle richieste brevi o alla ricerca nei documenti. Per un uso prevalentemente di scrittura in italiano, di solito conviene partire dal modello unico più grande.

### Quale interfaccia usare per la chat interna?

Open WebUI è la scelta più diffusa e supporta il login via OIDC, ma va verificata la licenza della versione che si installa, perché è cambiata nel tempo. Esistono alternative: l'importante è che l'interfaccia parli con un gateway tramite API standard, così si può sostituire senza rifare il resto.

### Come si evita che un ufficio monopolizzi il servizio?

Con un gateway LLM che assegna una chiave a ogni ufficio, con limiti di richieste al minuto, di token al minuto e di richieste parallele, e con limiti sulla lunghezza dei singoli prompt. In alternativa o in aggiunta, un secondo modello più piccolo può servire le richieste brevi con priorità.

### Si possono registrare le conversazioni dei dipendenti?

Con molta cautela. Registrare sistematicamente il contenuto delle conversazioni può configurare un controllo a distanza dei lavoratori e richiede una base giuridica e un'informativa adeguate. L'approccio prudente è registrare solo metadati tecnici nel gateway, lasciare le conversazioni all'utente con una conservazione limitata e far validare l'impostazione dal DPO o dal consulente del lavoro.

### Il modello self-hosted impara dai dati aziendali?

No: i pesi di un modello self-hosted non cambiano con l'uso. Bisogna però verificare che il resto dello stack non mandi dati all'esterno, per esempio tramite telemetria dell'interfaccia, ricerca web o connettori verso servizi terzi, e bloccare l'uscita internet a livello di firewall.

### Quanto costa una chat aziendale interna?

Indicativamente 3.000–4.800 euro di hardware una tantum, 40–80 euro al mese di energia, 8–15 giorni di setup e uno o due giorni al mese di manutenzione. Per 40 utenti, un servizio business esterno costa nell'ordine di 800–1.200 euro al mese: il confronto economico è spesso favorevole alla soluzione interna, ma il motivo principale resta il controllo dei dati.

### Cosa devono sapere i dipendenti prima di usarla?

Le regole essenziali: usare la chat aziendale invece degli account personali, non incollare credenziali né dati particolarmente sensibili senza autorizzazione, rileggere e verificare numeri e riferimenti, non usarla per decisioni sulle persone, e sapere chi può vedere le loro conversazioni. Una formazione di 45 minuti con casi del proprio ufficio è più efficace di qualsiasi documento.

### Come si misura se il progetto funziona?

Con metriche aggregate per ufficio: utenti attivi settimanali, richieste per utente, tempi di risposta e feedback sulla qualità. Per capire se sta sostituendo gli strumenti personali, si osserva l'andamento aggregato del traffico verso i servizi di chat esterni e si raccolgono risposte anonime su cosa manca allo strumento interno.
