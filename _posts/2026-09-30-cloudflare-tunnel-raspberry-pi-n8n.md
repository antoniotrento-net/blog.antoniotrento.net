---
lang: it
permalink: /it/blog/cloudflare-tunnel-raspberry-pi-n8n/
alt_url: /en/blog/cloudflare-tunnel-raspberry-pi-n8n/
title: "Cloudflare Tunnel su Raspberry Pi: esporre n8n e la dashboard senza aprire una porta (e senza farsi bannare l'IP di casa)"
date: 2026-09-30 07:30:00 +0200
author: "Antonio Trento"
description: "Guida ops a Cloudflare Tunnel su Raspberry Pi per esporre n8n e una dashboard senza port forwarding: cloudflared in Docker, Zero Trust Access, cosa non tunnelare, e la lezione degli IP residenziali che prendono 403."
keywords: ["cloudflare tunnel raspberry pi n8n", "cloudflared docker", "reverse proxy pmi", "ip residenziale 403", "zero trust tunnel", "esporre n8n senza aprire porte"]
image: /assets/images/posts/cloudflare-tunnel-raspberry-pi-n8n.jpg
pillar: stack-sovrano
related: [/it/blog/n8n-self-hosted-openai-privacy/, /it/blog/docker-pmi-stack-sovrano/]
---

## Il modo sbagliato di esporre il tuo Pi (che funziona finché non ti bruciano)

C'è un rito di passaggio per chi mette n8n su un Raspberry Pi in ufficio o a casa: entri nel pannello del modem, apri la porta 5678, fai un DNS dinamico, e in cinque minuti la tua automazione è "online". Funziona. Funziona anche il giorno dopo. Poi, in una settimana o in un mese, qualcuno la trova — perché su internet *tutto* viene trovato, non è questione di se ma di quando — e ti ritrovi l'editor di n8n aperto al mondo, i tentativi di login nei log, e nel caso peggiore la macchina compromessa dentro la tua rete di casa o d'ufficio.

Il **Cloudflare Tunnel su Raspberry Pi per n8n** risolve esattamente questo: esponi i servizi che ti servono *senza aprire una sola porta* sul modem, con autenticazione davanti, e senza mostrare al mondo l'indirizzo IP di casa tua. Il Pi apre una connessione *in uscita* verso Cloudflare, e tutto il traffico entrante passa da lì. Niente port forwarding, niente IP esposto, niente porta 5678 che aspetta di essere trovata.

Questa è una guida ops concreta, da laboratorio e da ufficio piccolo: `cloudflared` in Docker sul Pi, gli hostname pubblici vs quelli protetti da Access, cosa non devi *mai* tunnelare, la lezione — imparata a caro prezzo da molti — sugli **IP residenziali che si beccano i 403**, e la manutenzione che nessuno ti racconta finché la SD card non muore. Con i frammenti di configurazione copiabili.

Fa parte del percorso su come costruire uno stack sovrano su hardware tuo, che ho iniziato con [n8n self-hosted con OpenAI e privacy]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}) e con lo [stack sovrano in Docker per PMI]({{ '/it/blog/docker-pmi-stack-sovrano/' | relative_url }}). Qui affrontiamo il pezzo di rete: come far entrare il mondo, in modo controllato, senza spalancare la porta.

## Perché il port forwarding sul modem è una pessima idea

Aprire una porta sul router sembra la cosa più naturale, ed è la più pericolosa. Vediamo perché, senza giri di parole.

- **Esponi il dispositivo direttamente alle scansioni.** Internet è scansionato in continuazione. Motori come Shodan indicizzano ogni IP con porte aperte. La tua porta 5678 finirà in un database di "n8n esposti" in tempi brevissimi, e i bot proveranno credenziali, exploit noti, tutto in automatico.
- **Esponi il tuo IP di casa.** Chiunque raggiunga il servizio vede il tuo indirizzo residenziale. È un dato che preferiresti non regalare, e apre a DDoS diretti contro la tua linea (che non ha nessuna protezione).
- **Nessun filtro davanti.** Il traffico arriva grezzo al Pi. Nessun WAF, nessun rate limit, nessuna autenticazione a monte: se il servizio ha un bug, sei scoperto.
- **Spesso non funziona nemmeno.** Molte connessioni domestiche italiane sono in **CGNAT** (l'operatore condivide un IP pubblico tra più clienti): il port forwarding semplicemente non è possibile, o richiede IP pubblico a pagamento. E l'IP dinamico cambia, rompendo il DNS.
- **Metti a rischio l'intera LAN.** Un Pi compromesso è un piede dentro la tua rete, da cui muoversi verso NAS, PC, stampanti, telecamere.

Il punto di fondo: **il port forwarding inverte il modello di fiducia giusto.** Fa aspettare al tuo dispositivo connessioni da estranei. Il modello corretto è l'opposto: è il tuo dispositivo che decide di connettersi *in uscita* verso un punto fidato, e nessuno può raggiungerlo direttamente. È esattamente ciò che fa un tunnel.

## Tunnel vs VPN vs VPS: minaccia e latenza

Prima di installare, la scelta d'architettura. Ci sono tre modi sensati per rendere raggiungibile un servizio su un Pi domestico, e servono a cose diverse. Chi salta questo ragionamento sceglie a caso e se ne pente.

| Approccio | A cosa serve | Porte aperte | Latenza | Sovranità dei dati |
|-----------|--------------|--------------|---------|--------------------|
| **Cloudflare Tunnel** | Servizi pubblici o semi-pubblici con auth | Nessuna | Bassa (edge vicino) | TLS terminato da Cloudflare |
| **VPN** (WireGuard/Tailscale) | Accesso privato tuo/del team | Nessuna (o 1 UDP) | Bassissima | Traffico solo tuo, cifrato E2E |
| **VPS + reverse proxy** | Servizi pubblici, controllo totale | Sul VPS, non a casa | Media (hop extra) | Tu controlli tutto (in UE) |

La regola che uso:

- **Serve solo a te e al tuo team?** → VPN (WireGuard o Tailscale). Nessuno all'esterno deve vedere il servizio, ognuno ha il suo client, latenza minima, e il traffico non passa da terzi. È l'opzione più sovrana.
- **Serve al pubblico o a servizi esterni** (es. webhook in ingresso, una dashboard per un cliente)? → **Cloudflare Tunnel** con Access. Nessuna porta aperta, autenticazione davanti, protezione dell'edge.
- **Vuoi controllo totale e nessun intermediario che veda il traffico?** → VPS tuo in UE con reverse proxy e WireGuard verso il Pi. Costa qualche euro al mese e più gestione, ma la sovranità è massima.

Un punto onesto sulla sovranità, perché è il cuore di questo blog: **con Cloudflare Tunnel, il TLS viene terminato all'edge di Cloudflare.** Significa che Cloudflare, tecnicamente, vede il traffico in chiaro nel punto di terminazione. Per una dashboard interna o webhook non sensibili è un compromesso accettabile in cambio di zero porte aperte e autenticazione robusta. Per dati altamente riservati, la VPN o il VPS proprio sono più coerenti con uno stack sovrano. Non esiste "il migliore" in assoluto: esiste il giusto per la tua minaccia. Ne parlo meglio nella sezione "quando NON farlo".

## L'architettura di riferimento: cosa entra e cosa resta dentro

Ecco come si dispone il tutto. Il concetto chiave è il **confine**: pochissime cose attraversano il tunnel, tutto il resto resta nella rete interna di Docker, irraggiungibile da fuori.

```
   Utente internet ──▶ ┌────────────────────────────────────┐
                       │ CLOUDFLARE EDGE                     │
                       │ TLS · Access (Zero Trust) · WAF ·   │
                       │ rate limit                          │
                       └──────────────┬─────────────────────┘
                                      │ tunnel (SOLO in uscita dal Pi)
                                      ▼
                       ┌────────────────────────────────────┐
                       │ cloudflared (container Docker)      │
                       │ ingress rules                       │
                       └──────────────┬─────────────────────┘
                          │           │            │
                   public │    Access │     Access │
                          ▼           ▼            ▼
                  ┌────────────┐ ┌──────────┐ ┌────────────┐
                  │ n8n WEBHOOK│ │ n8n EDIT.│ │ DASHBOARD  │
                  │ /webhook/* │ │  (UI)    │ │            │
                  └────────────┘ └──────────┘ └────────────┘

   ── rete Docker interna (NON attraversa il tunnel, mai) ──
   ┌──────────┐  ┌────────┐  ┌────────┐
   │ Postgres │  │ Redis  │  │ Ollama │   ← nessun hostname pubblico
   └──────────┘  └────────┘  └────────┘
```

**Cosa attraversa il tunnel (il minimo indispensabile):**

- Il path pubblico dei **webhook** di n8n, se ricevi eventi da servizi esterni (uno Stripe, un form, un CRM). Questo *deve* essere pubblico, ma solo il path `/webhook/`, non tutta l'app.
- L'**editor di n8n** e la **dashboard**, ma dietro Cloudflare Access — mai pubblici in chiaro.

**Cosa NON attraversa mai il tunnel (il confine da non violare):**

- **Postgres, Redis, Ollama** e ogni servizio di supporto: vivono nella rete interna di Docker, senza alcun hostname pubblico. Non hanno motivo di essere raggiungibili da internet, e non lo saranno.
- L'editor di n8n **in chiaro** (senza Access): esporre l'interfaccia di amministrazione di uno strumento di automazione senza autenticazione a monte è come lasciare le chiavi nella toppa.

Questo è il **reverse proxy per PMI** fatto bene: un solo punto di ingresso controllato, tutto il resto invisibile. La superficie d'attacco passa da "tutto il Pi" a "tre hostname, due dei quali dietro login".

## Installazione: cloudflared in Docker compose sul Pi

Passiamo al concreto. Assumo che tu abbia già n8n e i suoi servizi in Docker sul Pi (se no, parti dalla guida su n8n self-hosted linkata sopra). Aggiungiamo `cloudflared` come container.

Il flusso: crei il tunnel dal pannello Cloudflare Zero Trust, ottieni un **token**, e lo passi al container. La configurazione degli ingress la gestisci dal pannello (tunnel "remotely-managed") — comodo per il Pi, perché aggiorni le regole senza toccare la macchina.

```yaml
# docker-compose.yml — frammento cloudflared
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run --token ${CF_TUNNEL_TOKEN}
    networks:
      - proxy            # stessa rete di n8n, per raggiungerlo via hostname
    # NESSUNA porta pubblicata: la connessione è solo in uscita
    # Nessun 'ports:' qui. È il punto.

  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    environment:
      - N8N_HOST=n8n.tuodominio.it
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://n8n.tuodominio.it/
      - N8N_EDITOR_BASE_URL=https://n8n.tuodominio.it/
    networks:
      - proxy
      - internal        # per parlare con Postgres, non esposto
    # anche qui: niente 'ports:' verso l'esterno

networks:
  proxy:
    driver: bridge
  internal:
    driver: bridge
    internal: true      # rete SENZA accesso a internet: DB e simili qui
```

Due dettagli che fanno la differenza:

- **Nessun `ports:` pubblicato.** Né su `cloudflared` né su `n8n`. Il tunnel raggiunge n8n *dall'interno* della rete Docker `proxy`, via hostname del container. Non c'è nulla in ascolto sull'IP del Pi verso la LAN o internet. È questo che rende superfluo (e sbagliato) il port forwarding.
- **La rete `internal: true`.** Postgres e Redis stanno su una rete Docker senza gateway verso internet. Anche volendo, non possono essere raggiunti da fuori né uscire. È il confine di cui parlavo, imposto da Docker, non dalla buona volontà.

Le regole di ingress (dal pannello, o in `config.yml` se preferisci il tunnel "locally-managed") mappano gli hostname ai servizi interni:

```yaml
# config.yml — se gestisci il tunnel localmente (alternativa al pannello)
tunnel: <TUNNEL_ID>
credentials-file: /etc/cloudflared/<TUNNEL_ID>.json

ingress:
  # webhook pubblici: solo il path necessario
  - hostname: hooks.tuodominio.it
    path: ^/webhook/.*
    service: http://n8n:5678
  # editor n8n: dietro Access (la policy si mette nel pannello)
  - hostname: n8n.tuodominio.it
    service: http://n8n:5678
  # dashboard interna
  - hostname: dash.tuodominio.it
    service: http://dashboard:3000
  # tutto il resto: rifiutato
  - service: http_status:404
```

Nota l'ultima regola: `http_status:404` come catch-all. Qualsiasi hostname non previsto riceve un 404, non finisce per sbaglio su un servizio. Default-deny, come si deve.

## Percorso di implementazione, a step

1. **Crea l'account Cloudflare** e aggiungi il tuo dominio (o un sottodominio dedicato). Il DNS deve essere gestito da Cloudflare.
2. **Vai su Zero Trust → Networks → Tunnels**, crea un tunnel, scegli "Docker" come metodo, copia il **token**.
3. **Metti il token in un file `.env`** sul Pi (mai in chiaro nel compose, mai in git) e avvia il container `cloudflared`.
4. **Configura gli ingress** (pannello o config.yml): mappa gli hostname ai servizi interni, con catch-all 404.
5. **Crea le policy Access** per gli hostname sensibili (editor, dashboard): solo email autorizzate.
6. **Lascia pubblico solo il path webhook**, se davvero ti serve ricevere eventi esterni.
7. **Verifica dall'esterno** (rete mobile, non la tua LAN) che gli hostname protetti chiedano login e che Postgres/Redis siano irraggiungibili.
8. **Attiva rate limiting e regole WAF** di base sull'edge.
9. **Configura il monitoraggio** del tunnel (stato up/down) e la manutenzione del Pi (sotto).
10. **Documenta** hostname, policy, e il piano di fallback.

## Hostname pubblici vs hostname solo Access

Questa distinzione è dove si vince o si perde la sicurezza. Non tutti gli hostname sono uguali.

**Hostname pubblico (senza Access):** chiunque con l'URL raggiunge il servizio. Ha senso *solo* per endpoint che devono essere pubblici per natura — tipicamente i **webhook in ingresso**: uno Stripe, un Calendly, un CRM che chiama il tuo n8n quando succede qualcosa. Questi non possono avere un login davanti, perché il servizio esterno non saprebbe autenticarsi. Ma li limiti al path `/webhook/`, non esponi l'intera app, e li proteggi con la firma del webhook (ogni servizio serio firma i suoi payload — verifica la firma in n8n).

**Hostname dietro Access (Zero Trust):** Cloudflare mette un layer di autenticazione *prima* che il traffico raggiunga il tunnel. L'utente deve autenticarsi (email one-time-PIN, Google Workspace, ecc.) e solo se autorizzato passa. Questo è d'obbligo per:

- L'**editor di n8n** (accesso amministrativo ai workflow, credenziali, tutto).
- Qualsiasi **dashboard** con dati aziendali.
- Endpoint di gestione, monitoraggio, admin.

Una policy Access di esempio, che consente solo due email e richiede l'OTP via email:

```json
{
  "name": "n8n-editor-solo-team",
  "decision": "allow",
  "include": [
    { "email": { "email": "antonio@tuodominio.it" } },
    { "email": { "email": "collega@tuodominio.it" } }
  ],
  "require": [
    { "email_domain": { "domain": "tuodominio.it" } }
  ],
  "session_duration": "8h"
}
```

La logica dello **Zero Trust tunnel**: non ti fidi della rete (non c'è una "rete interna sicura" da difendere con un firewall perimetrale), ti fidi dell'**identità**. Ogni richiesta a un hostname protetto è verificata sull'identità di chi la fa, indipendentemente da dove arriva. È il modello giusto quando il "perimetro" non esiste più, come in un ufficio piccolo con persone che lavorano da casa.

## Cosa NON tunnelare, mai

Ripeto il confine perché è la sezione che salva più gente. Alcune cose non vanno esposte, in nessuna forma, nemmeno dietro Access:

- **Postgres (5432), Redis (6379), e ogni database.** Non hanno motivo di essere raggiungibili da internet. Vivono nella rete Docker `internal`. Se pensi di doverli esporre "per comodità" (un client SQL da remoto), la risposta è: usa la VPN per quello, non il tunnel pubblico.
- **L'editor di n8n in chiaro.** Mai un hostname pubblico che punta all'UI di n8n senza Access. È il primo bersaglio, e dà accesso a tutte le tue credenziali salvate nei workflow.
- **Ollama e i servizi LLM interni.** Il tuo modello self-hosted parla solo con n8n e con il RAG, sulla rete interna. Esporlo significa regalare calcolo a chiunque e potenzialmente esfiltrare dati.
- **Pannelli di amministrazione senza autenticazione forte** (Portainer, Grafana in modalità admin, ecc.): o dietro Access con policy stretta, o solo via VPN.
- **Metriche e log grezzi** che possono rivelare struttura interna, versioni, path.

Regola mnemonica: **esponi solo ciò che un estraneo deve poter raggiungere per forza (i webhook), e ciò che una persona autorizzata deve usare (dietro Access). Tutto il resto resta dentro.**

## Il webhook pubblico in sicurezza: è l'unica porta davvero aperta

Dietro Access sei protetto dall'identità. Ma il path `/webhook/` è per forza pubblico — deve poter essere chiamato da un servizio esterno che non fa login. È quindi l'**unica superficie davvero esposta** del tuo setup, e va trattata con cura, perché è dove un attaccante busserà.

Tre livelli di difesa, dal più importante:

- **Verifica la firma del payload.** Ogni servizio serio (Stripe, GitHub, molti CRM) firma i suoi webhook con un HMAC e un segreto condiviso. In n8n, il primo nodo dopo il trigger deve **verificare quella firma** e scartare tutto ciò che non la supera. Senza questa verifica, chiunque conosca l'URL può inviarti eventi falsi e innescare le tue automazioni con dati arbitrari.

```javascript
// Nodo Function in n8n: verifica firma HMAC prima di procedere
const crypto = require('crypto');
const secret = $env.WEBHOOK_SECRET;           // dal .env, non hardcoded
const firma = $headers['x-signature'] || '';
const corpo = JSON.stringify($json);
const atteso = crypto.createHmac('sha256', secret)
                     .update(corpo).digest('hex');
if (!crypto.timingSafeEqual(Buffer.from(firma), Buffer.from(atteso))) {
  throw new Error('Firma webhook non valida: richiesta scartata');
}
return items;
```

- **Rate limit sull'edge.** Configura una regola di rate limiting su Cloudflare per l'hostname dei webhook: un mittente legittimo non ti chiama mille volte al secondo. Il rate limit assorbe i tentativi di flood prima che tocchino il Pi.
- **Restringi il path e, dove possibile, l'origine.** Esponi solo `^/webhook/.*`, non altro. Alcuni servizi pubblicano i range IP da cui inviano i webhook: se li conosci, una regola WAF che accetta solo quelli chiude quasi del tutto la superficie.

La regola: **un webhook non autenticato che innesca automazioni è un pulsante che hai lasciato premere a chiunque.** La firma lo trasforma in un pulsante che risponde solo al mittente giusto. È l'unico posto dove il traffico anonimo entra: proteggilo come tale.

## IP residenziale, scrape e ban: non martellare le API da casa

Questa è la lezione che il titolo promette, e che quasi nessuno ti dice prima che ti succeda. Il tunnel gestisce il traffico *in ingresso*. Ma il tuo Pi fa anche traffico *in uscita* — le automazioni chiamano API, gli agenti fanno richieste, magari scraping. E qui l'**IP residenziale** ti frega.

Cosa succede:

- **Gli IP residenziali sono "sporchi" per molti servizi.** Sono spesso in CGNAT (condivisi tra utenti), finiscono in blocklist per abusi di altri, e molti servizi trattano il traffico da range residenziali con sospetto. Risultato: **403, captcha, rate limit aggressivi** proprio quando ti aspetti che vada tutto liscio.
- **Se martelli un'API da casa, ti bruci l'IP.** Un agente che fa mille richieste al minuto a un servizio esterno dal tuo IP di casa: prima il rate limit, poi il ban. E siccome l'IP è condiviso (CGNAT) o dinamico, il ban può colpire più di te, o spostarsi quando l'IP cambia — un incubo da diagnosticare.
- **Alcune API bloccano proprio i range residenziali** per policy, indipendentemente dal volume. Ricevi 403 e non capisci perché, finché non provi dallo stesso codice su un IP datacenter e funziona.

Come ci si comporta, da ops seri:

- **Rispetta i rate limit e usa backoff esponenziale.** Non martellare. Le API serie pubblicano i loro limiti: stacci dentro con margine.
- **Usa le API ufficiali, non lo scraping**, dove esistono. Lo scraping da IP residenziale è il modo più rapido per collezionare 403.
- **Se devi fare volumi in uscita, non farli da casa.** Sposta il lavoro di egress su un piccolo VPS in UE con IP datacenter pulito, o usa un servizio con IP dedicati. Il Pi orchestra; l'uscita massiva passa da un IP fatto per quello.
- **Distingui i carichi:** l'automazione interna leggera (poche chiamate) sta bene sul Pi; lo scraping o le integrazioni ad alto volume vanno progettati diversamente.

Il principio: **il tunnel non cambia il fatto che il tuo IP di uscita è residenziale.** Sovranità e homelab sono bellissimi per ospitare i tuoi dati, meno adatti a fare da sorgente di traffico aggressivo verso terzi. Progetta l'egress con la stessa cura dell'ingress.

## Manutenzione: SD card, alimentazione, freeze

Un Pi in produzione non è "installa e dimentica". I tre modi in cui muore, in ordine di frequenza:

**1. La SD card si consuma.** Le schede SD hanno cicli di scrittura limitati, e Docker + database + log scrivono in continuazione. Una SD economica muore in mesi. Contromisure:

- **Boot da SSD USB** invece che da SD: più affidabile e più veloce. È l'upgrade singolo che vale di più.
- Se resti su SD, usa **schede high-endurance** (quelle per dashcam/videosorveglianza) e sposta i volumi Docker "pesanti" (Postgres) su un disco USB.
- Riduci le scritture: `log2ram` per tenere i log in RAM e scriverli periodicamente, `logrotate` aggressivo.

**2. L'alimentazione instabile corrompe tutto.** Il Pi è sensibile a cali di tensione. Un alimentatore scadente o un brownout causa corruzione del filesystem — spesso il modo in cui la SD "muore" è in realtà una scrittura interrotta a metà.

- Usa un **alimentatore ufficiale/di qualità** con l'amperaggio giusto.
- Un piccolo **UPS** (anche uno di quelli per Pi) evita corruzioni da microinterruzioni. In un ufficio, vale l'investimento.

**3. Il freeze silenzioso.** Il Pi si pianta, o un container va in loop, e te ne accorgi solo quando l'automazione non gira più.

- **Watchdog hardware** del Pi abilitato, così un blocco totale causa un riavvio.
- **Healthcheck** sui container Docker con `restart: unless-stopped`, così un servizio morto riparte.
- **Monitoraggio esterno** dello stato del tunnel e dei servizi (un uptime monitor che ti avvisa se `n8n.tuodominio.it` non risponde). Il fallimento va notificato, non scoperto.

Questa parte fisica è ciò che distingue un esperimento da un servizio. Un homelab che regge sei mesi senza toccarlo è fatto di SSD, buon alimentatore, e monitoraggio — non di fortuna.

## Fallback se Cloudflare è down

Dipendere da un intermediario significa ereditarne i disservizi. Se Cloudflare ha un problema, o il tuo tunnel si disconnette, i servizi pubblici diventano irraggiungibili. Va messo in conto e mitigato.

- **`cloudflared` si riconnette da solo.** Con `restart: unless-stopped` e la logica di retry interna, un blip di rete si risolve senza intervento. La maggior parte dei "down" sono transitori.
- **Accesso di emergenza via LAN o VPN.** Tieni sempre un modo per raggiungere il Pi che *non* dipenda dal tunnel: SSH sulla LAN locale, o meglio una VPN (WireGuard/Tailscale) che ti dà accesso diretto indipendente da Cloudflare. Quando il tunnel è giù e devi diagnosticare, questa è la tua ancora.
- **Monitoraggio indipendente.** L'uptime monitor che ti avvisa deve girare *fuori* dal Pi e possibilmente non solo su Cloudflare, così sai distinguere "il Pi è morto" da "il tunnel è giù" da "Cloudflare ha un disservizio".
- **Webhook critici: valuta la ridondanza.** Se ricevere un webhook è business-critical e non puoi permetterti di perderne durante un down, il servizio esterno di solito ritenta (Stripe lo fa per ore). Verifica la policy di retry di chi ti manda gli eventi: spesso il fallback è già lì, gratis.
- **Piano B documentato.** Scrivi cosa fare quando il tunnel è giù: come accedere, chi avvisare, cosa aspettarsi. Un runbook di due paragrafi vale più di mezz'ora di panico.

Onestà: nessuna soluzione a intermediario singolo ha uptime perfetto. Se il tuo caso non tollera *nessun* down, l'architettura giusta non è un Pi domestico con un tunnel — è ridondanza vera, che costa. Sappi dove sei sulla scala tra "hobby robusto" e "servizio mission-critical".

## I fallimenti tipici e come li riconosci dai log

- **`cloudflared` connesso ma 502 sugli hostname.** Il tunnel è su ma non raggiunge il servizio interno. Nei log di `cloudflared` vedi errori di connessione verso `http://n8n:5678`. Causa tipica: container non sulla stessa rete Docker, o nome/porta sbagliati nell'ingress.
- **Editor n8n raggiungibile senza login.** Se apri l'hostname dell'editor da rete mobile e *non* ti chiede l'autenticazione, la policy Access non è attiva su quell'hostname. Errore grave: correggi subito.
- **403/captcha sulle chiamate in uscita.** Nei log di n8n vedi le richieste API fallire con 403. È l'IP residenziale (sopra). Non è un bug del tuo codice: è il tuo IP di uscita.
- **Tunnel che si disconnette a intermittenza.** Log di `cloudflared` con reconnect frequenti: spesso è la rete di casa instabile, o il Pi sotto carico/che va in freeze. Correla con l'uso di CPU e con i log di sistema.
- **Webhook persi.** Se un'automazione non parte, controlla se il webhook è arrivato: un 404 sull'edge significa hostname/path sbagliato nell'ingress; nessuna traccia significa che il servizio esterno non ha nemmeno provato (verifica la sua config).
- **Corruzione dopo un riavvio.** Errori del filesystem o Postgres che non parte dopo un calo di corrente: è la SD/alimentazione. Sintomo classico, causa fisica.

Regola: **guarda i log di `cloudflared` E quelli del servizio.** Il 90% dei problemi è "il tunnel è su ma non parla col servizio" oppure "il servizio è su ma l'IP di uscita è bloccato": due cose diverse, due log diversi.

## Costi: ordini di grandezza

Stime dichiarate, per un setup homelab/ufficio piccolo.

- **Cloudflare Tunnel + Access:** il piano che copre l'uso tipico (tunnel, Access per un numero contenuto di utenti) rientra nel tier gratuito o quasi. Per team piccoli, **costo vicino a zero**. Verifica i limiti del free tier sul numero di utenti Access.
- **Hardware Raspberry Pi:** il Pi stesso, più — fortemente consigliato — un **SSD USB** e un **alimentatore di qualità**, e opzionalmente un piccolo UPS. Come ordine di grandezza, poche decine/centinaio di euro una tantum. L'SSD è l'investimento che ripaga di più in affidabilità.
- **Consumo elettrico:** un Pi con SSD consuma pochi watt. In bolletta, come ordine di grandezza, **pochi euro l'anno**. È uno dei suoi grandi vantaggi rispetto a un server acceso h24.
- **VPS di egress** (se ti serve per il traffico in uscita ad alto volume): qualche euro al mese per un piccolo VPS in UE con IP pulito. Opzionale, solo se fai volumi.
- **Costo del non gestirlo:** una SD morta a metà di un'automazione critica, o un editor n8n bucato, costano molto più del tempo di fare le cose per bene. La manutenzione è economica; l'incidente no.

## Quando NON farlo

- **Se i dati sono altamente riservati** e non accetti che il TLS sia terminato da un intermediario, il Cloudflare Tunnel non è la scelta più coerente. Vai di VPN (accesso privato) o VPS proprio in UE con reverse proxy tuo. La sovranità piena richiede di non delegare la terminazione TLS.
- **Se serve accesso solo a te e al team**, non esporre nulla al pubblico: una VPN (WireGuard/Tailscale) è più semplice, più sicura e più sovrana. Il tunnel pubblico ha senso quando *deve* entrare qualcuno o qualcosa da fuori.
- **Se il servizio è mission-critical senza tolleranza ai down**, un Pi domestico con tunnel singolo non è l'infrastruttura giusta. Serve ridondanza vera, che è un altro budget.
- **Se devi fare volumi elevati di traffico in uscita** (scraping, integrazioni pesanti), non farlo dall'IP residenziale: progetta un egress dedicato, o rischi ban e 403 a ripetizione.
- **Se non puoi garantire la manutenzione fisica** (SSD, alimentazione, monitoraggio), sappi che il Pi ti tradirà nel momento peggiore. Meglio un piccolo VPS gestito che un Pi trascurato.

## Checklist hardening prima di andare live

- [ ] **Nessuna porta aperta** sul modem/router. Verifica dall'esterno (scanner) che il tuo IP non abbia porte in ascolto.
- [ ] **`cloudflared` senza `ports:`** pubblicati: connessione solo in uscita.
- [ ] **Postgres, Redis, Ollama** su rete Docker `internal: true`, nessun hostname pubblico.
- [ ] **Editor n8n e dashboard dietro Access**, con policy che consente solo email autorizzate.
- [ ] **Solo il path `/webhook/` pubblico**, con verifica firma dei webhook attiva.
- [ ] **Catch-all `http_status:404`** negli ingress: hostname non previsti rifiutati.
- [ ] **Token del tunnel in `.env`**, mai in git, permessi file stretti.
- [ ] **Rate limiting e WAF** di base attivi sull'edge Cloudflare.
- [ ] **Verifica dall'esterno** (rete mobile): protetti chiedono login, DB irraggiungibili.
- [ ] **Boot da SSD**, alimentatore di qualità, UPS se possibile.
- [ ] **Watchdog + healthcheck + restart** su container e sistema.
- [ ] **Monitoraggio esterno** del tunnel e dei servizi, con alert.
- [ ] **Accesso di emergenza via VPN/LAN** indipendente dal tunnel.
- [ ] **Runbook di fallback** scritto (Cloudflare down, Pi down, SD morta).

## Il verdetto

Il **Cloudflare Tunnel su Raspberry Pi per n8n** è il modo giusto di far entrare il mondo nel tuo homelab: inverti il modello di fiducia, il Pi si connette in uscita, e nessuno può raggiungerlo direttamente. Niente port forwarding, niente IP di casa esposto, autenticazione Zero Trust davanti ai servizi sensibili, e un confine netto tra il pochissimo che attraversa il tunnel (webhook e UI protette) e tutto il resto che resta chiuso nella rete Docker (database, cache, modelli). È un salto di sicurezza enorme rispetto alla porta 5678 aperta sul modem, e costa quasi nulla.

Ma ricordati i due limiti onesti. Il primo: il tunnel non rende il tuo IP di uscita meno residenziale — se martelli le API da casa, i 403 e i ban arrivano lo stesso, e l'egress ad alto volume va progettato altrove. Il secondo: stai delegando la terminazione TLS a un intermediario, il che va benissimo per una dashboard interna e molto meno per dati altamente riservati, dove VPN o VPS proprio sono più coerenti con uno stack davvero sovrano.

E soprattutto: un Pi in produzione è hardware. SSD, buon alimentatore, monitoraggio, runbook di fallback. La differenza tra un esperimento che muore col primo calo di corrente e un servizio che regge sei mesi senza pensarci non è il tunnel. È la cura ops che ci metti attorno.

Se stai costruendo uno stack sovrano su hardware tuo e vuoi esporlo senza aprire falle — o capire se per il tuo caso è meglio tunnel, VPN o VPS — puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Ops concreta, non slide.

## FAQ

### Cloudflare Tunnel è davvero gratis?
Per l'uso tipico di un homelab o ufficio piccolo, l'accesso al tunnel e ad Access per un numero contenuto di utenti rientra nel tier gratuito. Verifica sul pannello i limiti aggiornati sul numero di utenti Access e sulle funzionalità: alcune opzioni avanzate richiedono un piano a pagamento. Ma per esporre n8n con qualche persona autorizzata, il costo è vicino a zero.

### Devo aprire qualche porta sul router?
No, ed è il punto centrale. `cloudflared` apre una connessione *in uscita* verso Cloudflare; nessuna porta in ingresso viene aperta sul modem. Anzi, il setup corretto ti fa chiudere qualsiasi port forwarding esistente. Verifica dall'esterno, con uno scanner di porte, che il tuo IP non abbia nulla in ascolto: dev'essere così.

### Funziona anche se sono in CGNAT?
Sì, ed è uno dei vantaggi maggiori. Siccome la connessione è solo in uscita, non ti serve un IP pubblico raggiungibile né il port forwarding — che in CGNAT spesso è impossibile. Il tunnel funziona anche dietro CGNAT, dietro IP dinamico, dietro quasi qualsiasi rete che permetta traffico HTTPS in uscita.

### Cloudflare può vedere il mio traffico?
Nel modello tunnel, il TLS viene terminato all'edge di Cloudflare, quindi tecnicamente sì, nel punto di terminazione il traffico è in chiaro per Cloudflare. Per dashboard interne e webhook non sensibili è un compromesso accettabile. Per dati altamente riservati, considera una VPN (traffico solo tuo) o un VPS proprio in UE dove controlli tu la terminazione TLS. È un trade-off tra comodità e sovranità da fare consapevolmente.

### Perché prendo 403 su alcune API anche se il volume è basso?
Perché il tuo IP di uscita è residenziale, e alcuni servizi bloccano o filtrano i range residenziali per policy, indipendentemente dal volume. Non è un bug del tuo codice. Se ti serve chiamare quelle API in modo affidabile, instrada il traffico in uscita da un IP datacenter pulito (un piccolo VPS in UE), tenendo il Pi come orchestratore.

### Posso esporre l'editor di n8n pubblicamente?
No, mai in chiaro. L'editor dà accesso a tutti i tuoi workflow e alle credenziali salvate. Mettilo sempre dietro Cloudflare Access con una policy che consente solo email autorizzate. Se ti serve accesso solo per te, puoi anche tenerlo raggiungibile unicamente via VPN e non esporlo affatto sul tunnel.

### E se Cloudflare va down?
`cloudflared` si riconnette da solo dopo blip transitori. Per i down più lunghi, tieni sempre un accesso di emergenza indipendente dal tunnel (VPN o SSH sulla LAN) e un monitoraggio esterno che ti avvisi. Per i webhook, la maggior parte dei servizi esterni ritenta l'invio per ore, quindi spesso non perdi eventi. Documenta un piano di fallback minimo.

### SD card o SSD per il Pi in produzione?
SSD USB, senza dubbi, se il Pi fa lavoro serio con database e Docker. Le SD si consumano con le scritture continue e muoiono, spesso in modo subdolo (corruzione dopo un calo di corrente). L'SSD è l'upgrade che dà il maggior ritorno in affidabilità. Se resti su SD per forza, usa schede high-endurance e sposta i volumi pesanti su disco esterno.

### Qual è la differenza pratica tra tunnel e VPN per il mio caso?
Il tunnel serve a far entrare qualcuno o qualcosa dall'esterno (webhook pubblici, una dashboard per un cliente) con autenticazione davanti. La VPN serve a dare accesso privato a te e al tuo team, senza esporre nulla al pubblico. Se nessuno all'esterno deve raggiungere i servizi, la VPN è più semplice e più sovrana. Se devi ricevere traffico esterno, il tunnel è la risposta. Spesso si usano entrambi.

### Posso mettere più servizi sullo stesso tunnel?
Sì. Un singolo tunnel gestisce più hostname tramite le regole di ingress: uno per n8n, uno per la dashboard, uno per i webhook, ognuno mappato al servizio interno giusto, ciascuno con la sua policy Access. È il pattern normale: un `cloudflared`, molti hostname, un catch-all 404 per tutto il resto. Tieni pubblici solo gli hostname che devono esserlo e proteggi gli altri con Access.
