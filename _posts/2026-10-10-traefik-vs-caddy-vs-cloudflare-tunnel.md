---
lang: it
permalink: /it/blog/traefik-vs-caddy-vs-cloudflare-tunnel/
title: "Traefik vs Caddy vs Cloudflare Tunnel: quale reverse proxy per un'agentic app self-hosted (certificati, auth, e blast radius)"
date: 2026-10-10 07:30:00 +0200
author: "Antonio Trento"
description: "Traefik vs Caddy vs Cloudflare Tunnel per il fronte HTTPS di n8n, UI interne e API di agenti self-hosted: TLS con Let's Encrypt, auth oltre il Basic, blast radius di una misconfigurazione e una matrice di scelta per la PMI."
keywords: ["traefik vs caddy vs cloudflare tunnel", "reverse proxy docker", "let's encrypt self-hosted", "zero trust", "n8n https", "reverse proxy pmi"]
image: /assets/images/posts/traefik-vs-caddy-vs-cloudflare-tunnel.jpg
pillar: stack-sovrano
related: [/it/blog/cloudflare-tunnel-raspberry-pi-n8n/, /it/blog/docker-pmi-stack-sovrano/]
---

## Il fronte HTTPS è il pezzo che, se sbagli, esponi tutto

Hai il tuo stack self-hosted: n8n, un paio di UI interne, l'API di un agente, magari una dashboard. Gira in Docker, i dati sono tuoi, sei contento. Poi arriva la domanda che decide la sicurezza dell'intera baracca: **come lo esponi?** Chi fa da fronte HTTPS, gestisce i certificati, mette l'autenticazione davanti alle interfacce di amministrazione, e decide cosa è raggiungibile e cosa no? È il **reverse proxy**, ed è il singolo componente con il *blast radius* più alto del tuo stack: fatto bene, è il portone blindato; fatto male, è la porta lasciata aperta con scritto "servizi interni, prego".

Questo pezzo è un confronto **Traefik vs Caddy vs Cloudflare Tunnel** dal punto di vista di chi deve *decidere* per una PMI o un'agenzia, non dal punto di vista del benchmark. Angolo dichiarato: **networking da PMI, decisione.** Alla fine avrai una matrice per scegliere, non una lista di feature. Anticipo la sintesi, perché non amo farti aspettare: **per la maggior parte delle PMI, Caddy è il default giusto** (HTTPS automatico, pochi pezzi, poca superficie di errore); **Traefik** quando hai molti servizi dinamici in Docker e ti serve l'auto-discovery; **Cloudflare Tunnel** quando non hai un IP pubblico pulito o non vuoi aprire porte — spesso in combinazione con uno degli altri due, non in alternativa.

Vedremo cosa deve fare davvero il fronte (TLS, auth, log, limiti), i tre approcci con i loro compromessi onesti, perché il **Basic auth non basta** e cosa mettere al suo posto, il blast radius di una misconfigurazione, i log con la questione GDPR degli indirizzi IP, gli errori di certificato più comuni, e la matrice finale. Con un Caddyfile completo e le label Traefik equivalenti.

Il Cloudflare Tunnel l'ho già sviscerato nel dettaglio per esporre n8n senza aprire porte in {{ '/it/blog/cloudflare-tunnel-raspberry-pi-n8n/' | relative_url }}: qui lo metto a confronto con le altre due opzioni, senza ripetere la guida. E il contesto dello stack Docker sovrano è quello di {{ '/it/blog/docker-pmi-stack-sovrano/' | relative_url }}.

## Cosa deve fare davvero il fronte: TLS, auth, log, limiti

Prima dei nomi, i requisiti. Un reverse proxy per un'app agentica self-hosted deve fare quattro cose, e la scelta tra i tre si gioca su quanto bene e quanto semplicemente ciascuno le copre:

- **TLS (HTTPS).** Terminare l'HTTPS con certificati validi, rinnovati automaticamente. Nessuno deve gestire certificati a mano nel 2026: il rinnovo automatico via ACME/Let's Encrypt è il minimo.
- **Auth.** Mettere l'autenticazione *davanti* ai servizi che non devono essere pubblici — l'editor di n8n, le dashboard, gli endpoint di amministrazione. Il proxy è il punto giusto dove imporre il login, perché protegge il servizio anche se il servizio stesso ha un'autenticazione debole.
- **Log.** Registrare chi accede a cosa, per diagnosi e sicurezza. Con l'avvertenza GDPR sugli IP (ci arrivo).
- **Limiti (rate limiting).** Assorbire i tentativi di abuso e i flood prima che raggiungano i servizi interni, specie sugli endpoint pubblici come i webhook.

E — punto cruciale — deve **instradare solo ciò che deve**, tenendo tutto il resto invisibile. Il proxy è l'unico punto di ingresso: dietro di lui, database, cache e servizi interni non devono essere raggiungibili. Se il proxy instrada per errore verso Postgres o verso l'editor di n8n senza auth, hai spalancato la porta. Questa è l'essenza del **reverse proxy in Docker** fatto con criterio: un fronte controllato, tutto il resto chiuso.

## Caddy: semplice, HTTPS automatico, meno pezzi

Partiamo da quello che consiglio come default, perché la semplicità è una feature di sicurezza. **Caddy** ha una qualità che lo rende speciale: **HTTPS automatico e per default.** Gli dai un dominio, e lui ottiene e rinnova il certificato Let's Encrypt da solo, senza che tu scriva una riga di configurazione ACME. Meno pezzi, meno cose che si rompono, meno superficie per sbagliare.

La configurazione è un **Caddyfile**, dichiarativo e leggibile. Ecco un esempio completo per un fronte con n8n dietro auth, un webhook pubblico e header di sicurezza:

```caddyfile
# Caddyfile — fronte HTTPS per stack agentico self-hosted
# HTTPS automatico via Let's Encrypt: nessuna config ACME necessaria

# Editor n8n: DIETRO autenticazione (forward-auth verso SSO self-hosted)
n8n.tuodominio.it {
    # header di sicurezza sensati
    header {
        Strict-Transport-Security "max-age=31536000;"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
    }
    # delega l'auth a un servizio SSO interno (Authelia/Authentik)
    forward_auth sso:9091 {
        uri /api/verify?rd=https://sso.tuodominio.it
        copy_headers Remote-User Remote-Groups
    }
    reverse_proxy n8n:5678
}

# Webhook pubblici: SOLO il path necessario, senza auth (serve firma a valle)
hooks.tuodominio.it {
    @webhook path /webhook/*
    handle @webhook {
        rate_limit {                 # assorbe i flood sugli endpoint pubblici
            zone webhook { key {remote_host}  events 60  window 1m }
        }
        reverse_proxy n8n:5678
    }
    handle {
        respond "Not found" 404      # tutto il resto: chiuso
    }
}
```

Quello che rende Caddy la scelta pragmatica per la PMI:

- **HTTPS senza pensarci:** ottiene e rinnova i certificati da solo. Un problema in meno che si trasforma in un incidente a mezzanotte quando un certificato scade.
- **Config leggibile:** il Caddyfile lo capisce anche chi non è un esperto di networking. Meno criptico = meno errori.
- **Pochi pezzi:** un binario, una config. Poca superficie di attacco e di errore.

I limiti onesti: Caddy è meno flessibile di Traefik per i setup Docker molto dinamici (dove i container nascono e muoiono di continuo e vuoi che il proxy si riconfiguri da solo). Per uno stack PMI relativamente stabile — n8n, qualche servizio, una dashboard — questa flessibilità non ti serve, e la semplicità di Caddy vince. **Se non hai un motivo specifico per Traefik, parti da Caddy.**

## Traefik: label Docker, dashboard, più corda per impiccarti

**Traefik** è più potente e più dinamico. La sua caratteristica distintiva: si configura tramite **label sui container Docker**. Aggiungi un container con le label giuste, e Traefik lo scopre e lo instrada automaticamente, senza toccare una config centrale. Per un ambiente con molti servizi che vanno e vengono, è comodissimo.

Le stesse regole del Caddyfile, espresse come label Docker su Traefik:

```yaml
# docker-compose.yml — n8n dietro Traefik con label
services:
  n8n:
    image: n8nio/n8n:latest
    labels:
      - "traefik.enable=true"
      # router per l'editor: HTTPS + middleware auth
      - "traefik.http.routers.n8n.rule=Host(`n8n.tuodominio.it`)"
      - "traefik.http.routers.n8n.entrypoints=websecure"
      - "traefik.http.routers.n8n.tls.certresolver=letsencrypt"
      - "traefik.http.routers.n8n.middlewares=sso-auth@file"
      - "traefik.http.services.n8n.loadbalancer.server.port=5678"
    networks: [proxy, internal]

  traefik:
    image: traefik:v3.1
    command:
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"   # NIENTE esposto per default!
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.email=tu@dominio.it"
      - "--certificatesresolvers.letsencrypt.acme.storage=/acme/acme.json"
      - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
    ports: ["443:443", "80:80"]
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro   # ⚠️ vedi blast radius
      - ./acme:/acme
    networks: [proxy]
```

Nota due dettagli critici che sono anche i suoi rischi:

- **`exposedbydefault=false`.** Fondamentale. Se lo lasci a `true` (o dimentichi di impostarlo), Traefik espone *ogni* container con una porta, inclusi quelli che non dovevano mai essere pubblici. È una delle misconfigurazioni più pericolose: un database che diventa raggiungibile perché "Traefik lo ha scoperto". Default-deny, sempre.
- **`docker.sock` montato.** Traefik legge il socket Docker per scoprire i container. Ma il socket Docker è **il controllo totale sull'host**: chi lo controlla può fare qualsiasi cosa. Montarlo (anche in read-only) è una concentrazione di potere che va valutata — è parte del blast radius.

Traefik ti dà più potere: middleware componibili (auth, rate limit, header, retry), una dashboard, l'auto-discovery. Ma "più potere" significa **più corda per impiccarti**: più superficie di configurazione, più modi di sbagliare, più cose da capire. La dashboard stessa, se esposta senza auth, è un problema. Traefik è la scelta giusta quando la sua dinamicità ti serve davvero (molti servizi, ambienti che cambiano); è sovradimensionato, e più rischioso, per uno stack piccolo e stabile dove Caddy farebbe lo stesso lavoro con metà dei modi di sbagliare.

## Cloudflare Tunnel: niente porta 443 in ingresso

La terza via è diversa in natura. **Cloudflare Tunnel** non apre alcuna porta in ingresso sul tuo server: è il server che stabilisce una connessione *in uscita* verso l'edge di Cloudflare, e tutto il traffico entrante passa da lì. Niente `443` aperta, niente IP pubblico esposto, funziona anche dietro CGNAT.

Quando è la risposta giusta:

- **Non hai un IP pubblico pulito** (CGNAT, IP residenziale, IP dinamico): il tunnel funziona comunque, perché la connessione è in uscita.
- **Non vuoi/non puoi aprire porte** sul router o sul firewall: il tunnel non ne richiede.
- **Vuoi l'auth Zero Trust davanti** (Cloudflare Access) senza montartela tu.

Il trade-off onesto, che ho discusso a fondo nella guida dedicata: **con il tunnel, il TLS è terminato all'edge di Cloudflare**, che quindi vede il traffico nel punto di terminazione. Per una dashboard interna o webhook non sensibili è un compromesso accettabile in cambio di zero porte aperte; per dati altamente riservati è un punto da valutare rispetto alla sovranità piena.

E il punto che chiarisce la "vs" del titolo: **Cloudflare Tunnel non è sempre in alternativa a Caddy/Traefik.** Spesso convivono: il tunnel porta il traffico dentro senza aprire porte, e dietro di lui Caddy o Traefik fanno il routing tra i vari servizi interni. Il tunnel risolve l'*ingresso*; Caddy/Traefik risolvono l'*instradamento e il TLS interno*. La scelta "vs" è netta solo quando il setup è semplice (un servizio, un dominio): lì il tunnel da solo basta. Su stack più articolati, la domanda non è "tunnel *o* Caddy", ma "tunnel *e* Caddy, o Caddy con le porte aperte".

## Auth: il Basic non basta, servono SSO e allowlist

Qui si commette l'errore che vanifica tutto il resto. Molti mettono l'HTTPS con Caddy o Traefik, poi proteggono l'editor di n8n con **HTTP Basic auth** — utente e password nel proxy — e si sentono a posto. Non lo sono. Il **Basic auth non basta**, per ragioni concrete:

- **Nessuna identità reale.** Un utente e una password condivisi, non "chi è entrato". Nessuna tracciabilità di chi ha fatto cosa.
- **Nessuna MFA.** Solo la password. Se trapela (e le password trapelano), sei dentro.
- **Credenziali in ogni richiesta.** Il Basic auth manda le credenziali a ogni chiamata; più superficie per intercettarle o loggarle per errore.
- **Nessuna gestione di sessione, revoca, scadenza** seria.

Cosa mettere al suo posto, in ordine di robustezza:

- **Forward-auth verso un SSO self-hosted** (Authelia, Authentik): il proxy delega l'autenticazione a un servizio di identità che tu controlli, con login vero, MFA, sessioni, e — punto chiave per la sovranità — **ospitato da te**. È la scelta che tiene insieme sicurezza e controllo dei dati.
- **Cloudflare Access (Zero Trust)** se usi il tunnel: l'autenticazione avviene all'edge prima che il traffico entri. Robusta, ma l'identità la gestisce Cloudflare.
- **IP allowlist** come strato *aggiuntivo*, non sostitutivo: se accedi sempre da IP noti (ufficio, VPN), limitare l'accesso a quegli IP riduce moltissimo la superficie. Ma da solo non basta (gli IP cambiano, si spoofano), quindi si somma all'auth, non la rimpiazza.

Il principio è **Zero Trust**: non ti fidi della rete, ti fidi dell'identità verificata. Ogni servizio sensibile — l'editor di n8n su HTTPS, le dashboard, gli endpoint admin — sta dietro un'autenticazione vera, imposta dal fronte. L'unico che può restare pubblico è ciò che *deve* esserlo per natura (i webhook in ingresso), e quello si protegge con la firma del payload e il rate limit, non con un login.

## Il blast radius: se il proxy cade o è mal configurato

Il reverse proxy è il componente a **blast radius più alto** dello stack, e va progettato sapendolo. Due scenari, entrambi da mettere in conto:

**Il proxy cade.** È l'unico punto di ingresso: se va giù, *tutto* ciò che sta dietro diventa irraggiungibile. Non è una perdita di dati, ma è un'interruzione totale del servizio. Mitigazioni: `restart: unless-stopped`, healthcheck, monitoraggio esterno che ti avvisa se il fronte non risponde, e un accesso di emergenza indipendente (SSH sulla LAN, VPN) per intervenire quando il fronte è giù.

**Il proxy è mal configurato.** Più insidioso, perché non è un'interruzione visibile ma un'esposizione silenziosa:

- Una regola di routing sbagliata che **espone un servizio interno** (l'editor di n8n senza auth, una dashboard, peggio un database).
- Il `exposedbydefault=true` di Traefik che pubblica container non previsti.
- Un middleware di auth che non si applica per un errore di label o di sintassi: il servizio è raggiungibile ma senza login.
- Il `docker.sock` montato che, se il proxy è compromesso, dà il controllo dell'host.

La misconfigurazione del fronte è tra gli errori più costosi perché **espone senza fare rumore**: tutto sembra funzionare, ma un servizio che doveva essere protetto è aperto al mondo. Le difese sono di processo:

- **Default-deny:** niente è esposto se non lo dichiari esplicitamente (`exposedbydefault=false`, catch-all 404).
- **Verifica dall'esterno:** dopo ogni modifica, controlla *da fuori* (rete mobile, non la tua LAN) che i servizi protetti chiedano il login e che quelli interni siano irraggiungibili. Non fidarti della config: verifica il comportamento.
- **Minimo privilegio al proxy:** valuta con attenzione il `docker.sock`; instrada solo i servizi che devono esserlo.
- **Config versionata:** il Caddyfile o le label in git, così ogni modifica è tracciata e reversibile.

Il proxy merita lo stesso rispetto del kill switch di un agente: è il punto dove un errore ha conseguenze sproporzionate, quindi la sua configurazione va trattata con cura, testata e versionata.

## L'architettura di riferimento

Ecco come dispongo il fronte, indipendentemente da quale dei tre scegli. Il confine è netto: il proxy instrada verso i servizi previsti, tutto il resto resta chiuso nella rete interna.

```
   Internet / LAN ──▶ ┌─────────────────────────────────────┐
                      │ FRONTE (uno di):                     │
                      │  Caddy  |  Traefik  |  CF Tunnel     │
                      │  TLS · auth (SSO/Access) · rate       │
                      │  limit · access log                  │
                      └───────────────┬─────────────────────┘
                          │           │            │
                   public │    auth   │     auth    │
                          ▼           ▼             ▼
                  ┌────────────┐ ┌──────────┐ ┌────────────┐
                  │ webhook    │ │ n8n UI   │ │ dashboard  │
                  │ /webhook/* │ │ (SSO)    │ │ (SSO)      │
                  └────────────┘ └──────────┘ └────────────┘

   ── rete Docker interna (il proxy NON instrada qui) ──
   ┌──────────┐  ┌────────┐  ┌────────┐  ┌──────────┐
   │ Postgres │  │ Redis  │  │ Ollama │  │ SSO int. │
   └──────────┘  └────────┘  └────────┘  └──────────┘
```

**Cosa NON fa mai il fronte (i confini):**

- Non instrada verso **database, cache, servizi interni**: quelli vivono su una rete Docker interna, mai pubblicati.
- Non lascia servizi di amministrazione **senza auth**: l'editor di n8n e le dashboard stanno dietro SSO.
- Non espone nulla **per default**: si dichiara esplicitamente cosa è raggiungibile, il resto è 404.
- Non tiene i **log con IP grezzi** oltre la retention (vedi sotto).

Questa è la stessa disciplina di confine dello stack Docker sovrano: una rete interna `internal: true` per DB e servizi di supporto, il fronte come unico varco controllato. Il proxy cambia (Caddy/Traefik/Tunnel), il principio no.

## Errori di certificato comuni

L'HTTPS automatico via **Let's Encrypt self-hosted** (il client ACME gira nel tuo Caddy/Traefik) è comodo finché non si inceppa, e quando si inceppa gli errori sono ricorrenti. La tabella che risolve il 90% dei casi:

| Sintomo | Causa | Fix |
|---------|-------|-----|
| Certificato non emesso, timeout challenge | porta 80 non raggiungibile (HTTP-01) | apri/instrada :80, o usa DNS-01 |
| `too many certificates already issued` | rate limit di Let's Encrypt (retry in loop) | usa lo **staging** in test, non ripetere in loop |
| Cert per wildcard non emesso | wildcard richiede DNS-01, non HTTP-01 | configura il provider DNS per la challenge |
| `unauthorized` sulla challenge | DNS non punta al server / propagazione | verifica il record A/AAAA e attendi la propagazione |
| Cert valido ma browser lamenta | catena incompleta o clock del server errato | verifica la fullchain e sincronizza NTP |
| Rinnovo fallito silenziosamente | :80 chiuso dopo il primo rilascio | tieni :80 raggiungibile per i rinnovi |

Due regole d'oro sui certificati:

1. **Usa l'endpoint di staging di Let's Encrypt durante i test.** Il rate limit di produzione è severo: se sbagli la config e ritenti in loop sull'endpoint di produzione, ti blocchi per giorni. Lo staging non ha quel limite. Passi a produzione solo quando la config funziona.
2. **Tieni la porta 80 raggiungibile anche dopo il primo rilascio**, se usi la challenge HTTP-01: i *rinnovi* la usano di nuovo. Un firewall che chiude :80 dopo il setup fa fallire il rinnovo mesi dopo, in silenzio, e il certificato scade quando meno te lo aspetti.

Con Cloudflare Tunnel la questione certificati è diversa: il TLS lo gestisce l'edge di Cloudflare, quindi non hai il problema ACME lato tuo — un punto a favore del tunnel in termini di semplicità, a fronte del trade-off di sovranità.

## Log e GDPR: gli IP sono dati personali

Un access log registra gli indirizzi IP di chi si connette. E gli **indirizzi IP sono dati personali** ai sensi del GDPR: loggarli e conservarli è un trattamento, con i suoi obblighi. Non è un cavillo, è un aspetto che va gestito nel fronte.

Le regole pratiche:

- **Definisci una retention.** I log di accesso servono per diagnosi e sicurezza, non per sempre. Una retention breve (es. giorni/settimane, o quanto serve alla finalità dichiarata) e cancellazione automatica.
- **Valuta l'anonimizzazione.** Per molte finalità (statistiche, diagnosi aggregata) puoi mascherare l'ultimo ottetto dell'IP, riducendo l'identificabilità pur mantenendo l'utilità. Il proxy può essere configurato per farlo.
- **Dichiara la finalità e proteggi l'accesso.** I log sono dati: accesso ristretto, storage sicuro, e menzione nell'informativa se necessario.
- **Attenzione ai log che finiscono altrove.** Se spedisci i log a un servizio esterno di aggregazione, gli IP vanno lì: stesso problema di sovranità del resto dello stack. Preferisci un logging self-hosted.

Il punto: **il fronte è anche il punto dove nasce un trattamento di dati personali** (gli IP di tutti quelli che si connettono). Gestirlo con retention e minimizzazione fa parte del fare le cose per bene, esattamente come per i log applicativi e l'osservabilità.

## La matrice di scelta

Ecco la matrice che uso per decidere, sulle dimensioni che contano per una PMI:

| Dimensione | Caddy | Traefik | Cloudflare Tunnel |
|-----------|-------|---------|-------------------|
| Semplicità di config | ★★★ altissima | ★ media/bassa | ★★ media |
| HTTPS automatico | ★★★ nativo | ★★ via configresolver | edge (nessun ACME tuo) |
| Auto-discovery Docker | ★ limitato | ★★★ label dinamiche | n/a |
| Porte in ingresso | serve :80/:443 | serve :80/:443 | ★★★ nessuna |
| Funziona dietro CGNAT | no (serve IP/porte) | no | ★★★ sì |
| Sovranità del traffico | ★★★ tutto tuo | ★★★ tutto tuo | ★ TLS all'edge CF |
| Superficie di errore | ★★★ bassa | ★ alta (più corda) | ★★ media |
| Blast radius config | basso | alto (sock, discovery) | medio |

Come leggerla e decidere:

- **Caddy** se hai un IP pubblico (o porte apribili), pochi servizi relativamente stabili, e vuoi la minima superficie di errore. **È il default per la maggior parte delle PMI.**
- **Traefik** se hai molti servizi dinamici in Docker, un team che sa gestirne la complessità, e ti serve davvero l'auto-discovery e i middleware avanzati. Più potente, più modi di sbagliare.
- **Cloudflare Tunnel** se non hai un IP pubblico pulito, sei dietro CGNAT, non vuoi aprire porte, e accetti il trade-off del TLS all'edge. Spesso in combinazione con Caddy/Traefik dietro per il routing interno.

Non esiste "il migliore": esiste il giusto per la tua rete, il tuo team e il tuo profilo di rischio. La matrice serve a scegliere consapevolmente, non a seguire la moda.

## Percorso di implementazione, a step

1. **Definisci cosa esporre:** elenca i servizi, e per ciascuno decidi pubblico (webhook) o dietro auth (UI, dashboard, admin). Il resto resta interno.
2. **Scegli il fronte** con la matrice: Caddy come default, Traefik se serve dinamicità, Tunnel se non hai IP/porte.
3. **Metti DB, cache e servizi interni** su una rete Docker interna, mai instradati dal proxy.
4. **Configura il TLS:** ACME automatico (Caddy/Traefik) con staging in test, o edge (Tunnel).
5. **Metti l'auth vera davanti** ai servizi sensibili: forward-auth a un SSO self-hosted, o Access col tunnel. Niente Basic auth.
6. **Aggiungi rate limit** sugli endpoint pubblici e header di sicurezza.
7. **Imposta default-deny:** `exposedbydefault=false` su Traefik, catch-all 404 su Caddy.
8. **Verifica dall'esterno** (rete mobile) che i protetti chiedano login e gli interni siano irraggiungibili.
9. **Configura i log** con retention breve e valuta l'anonimizzazione degli IP.
10. **Versiona la config** e predisponi monitoraggio del fronte + accesso di emergenza indipendente.

## I fallimenti tipici e come li riconosci dai log

- **Servizio interno esposto senza accorgersene.** Il caso peggiore e silenzioso: una regola sbagliata rende pubblico l'editor di n8n o una dashboard. Lo riconosci solo verificando *dall'esterno*, o notando accessi da IP sconosciuti nei log del servizio. Verifica sempre da fuori dopo ogni modifica.
- **Certificato scaduto / rinnovo fallito.** Il browser mostra l'errore TLS. Nei log del proxy vedi i fallimenti ACME. Causa frequente: :80 chiuso dopo il setup. Monitora la scadenza dei certificati, non aspettare l'errore dell'utente.
- **Rate limit di Let's Encrypt raggiunto.** Nei log ACME: `too many certificates`. Hai ritentato in loop su produzione. Usa lo staging in test e non ripetere l'emissione in loop.
- **Auth che non si applica.** Un errore di label Traefik o di sintassi Caddy fa sì che il middleware di auth non venga applicato: il servizio è raggiungibile senza login. Verifica *comportamentalmente* (prova ad accedere senza credenziali da fuori), non solo leggendo la config.
- **`exposedbydefault=true` dimenticato.** Traefik pubblica container non previsti. Controlla la dashboard/log di Traefik per i router creati automaticamente che non ti aspetti.
- **Proxy giù = tutto giù.** Se il monitoraggio esterno segnala che il fronte non risponde, tutto dietro è irraggiungibile. Da qui l'importanza dell'accesso di emergenza indipendente per rialzarlo.
- **Loop di redirect HTTPS.** Config TLS incoerente tra proxy e servizio a valle (doppia terminazione): il browser cicla. Verifica chi termina il TLS e che il servizio a valle parli HTTP sulla rete interna.

La regola: **dopo ogni modifica al fronte, verifica il comportamento dall'esterno.** La config può sembrare giusta e comportarsi diversamente; è il comportamento osservato, non la config letta, che ti dice se un servizio è protetto.

## Costi: ordini di grandezza

Stime dichiarate.

- **Caddy e Traefik:** software libero, costo di licenza **zero**. Girano in un container leggero accanto al resto dello stack; consumo di risorse trascurabile per una PMI. I certificati Let's Encrypt sono gratuiti.
- **Cloudflare Tunnel:** per l'uso tipico di una PMI (un tunnel, Access per pochi utenti) rientra nel tier gratuito o quasi; verifica i limiti aggiornati sugli utenti Access.
- **SSO self-hosted** (Authelia/Authentik): software libero, un container in più da gestire. Costo di licenza zero, costo operativo la sua gestione (aggiornamenti, backup della config).
- **Sviluppo/setup:** configurare il fronte con TLS, auth e default-deny, come ordine di grandezza **una-due giornate/uomo** per uno stack PMI, di più con Traefik per la sua complessità. Manutenzione leggera (rinnovi automatici, aggiornamenti immagine).
- **Costo del farlo male:** un servizio interno esposto = potenziale data breach; un certificato scaduto non monitorato = disservizio e allarme dai clienti; una misconfigurazione del `docker.sock` = compromissione dell'host. Tutti costi molto superiori alla cura nella configurazione del fronte.

## Quando NON farlo (o scegliere diversamente)

- **Non scegliere Traefik "perché è potente"** se hai tre servizi stabili: la sua complessità è superficie d'errore che non ti serve. Caddy fa lo stesso lavoro con metà dei modi di sbagliare.
- **Non usare il Basic auth** come protezione seria per l'editor di n8n o le dashboard: è insufficiente. Se non puoi montare un SSO, almeno combina Access/tunnel o un'allowlist IP forte, ma sappi che il Basic da solo non è una difesa.
- **Non montare il `docker.sock` con leggerezza:** se non ti serve l'auto-discovery dinamico di Traefik, non esporre il socket. È una concentrazione di potere che allarga il blast radius.
- **Non scegliere il tunnel per dati altamente riservati** senza valutare il TLS all'edge: per quei casi, un fronte self-hosted (Caddy/Traefik) o una VPN mantengono la sovranità piena.
- **Non esporre nulla** che possa stare su una VPN: se un servizio serve solo a te e al team, una VPN è più semplice e più sicura di qualsiasi fronte pubblico con auth. Il fronte pubblico ha senso quando *deve* entrare qualcuno o qualcosa da fuori.

## Checklist operativa prima di andare live

- [ ] **Elenco dei servizi** con classificazione pubblico/protetto/interno.
- [ ] **DB, cache, servizi interni** su rete Docker interna, mai instradati dal proxy.
- [ ] **Fronte scelto con la matrice** (Caddy default; Traefik se serve dinamicità; Tunnel se no IP/porte).
- [ ] **TLS automatico** con staging Let's Encrypt in test, produzione solo a config funzionante.
- [ ] **:80 raggiungibile** per i rinnovi (se HTTP-01), o DNS-01 configurato.
- [ ] **Auth vera** (forward-auth SSO self-hosted o Access) davanti a UI/dashboard/admin — niente Basic.
- [ ] **Rate limit** sugli endpoint pubblici; header di sicurezza impostati.
- [ ] **Default-deny:** `exposedbydefault=false` (Traefik) / catch-all 404 (Caddy).
- [ ] **Verifica dall'esterno** (rete mobile) di protetti e interni.
- [ ] **`docker.sock`** valutato consapevolmente (montarlo solo se serve, read-only).
- [ ] **Log con retention breve** e IP anonimizzati/gestiti secondo GDPR.
- [ ] **Config versionata**, monitoraggio del fronte, accesso di emergenza indipendente.

## Il verdetto

La scelta **Traefik vs Caddy vs Cloudflare Tunnel** non è una gara a chi ha più feature: è una decisione di rete che dipende dal tuo IP, dal tuo team e dal tuo profilo di rischio. Per la maggior parte delle PMI la risposta è **Caddy**: HTTPS automatico, config leggibile, pochi pezzi, poca superficie per sbagliare — e in sicurezza la semplicità è una feature, non un compromesso. **Traefik** guadagna il suo posto quando hai molti servizi dinamici in Docker e un team capace di gestirne la complessità, accettando che "più potere" significa "più corda per impiccarti". **Cloudflare Tunnel** è la risposta quando non hai un IP pubblico pulito o non vuoi aprire porte, spesso in combinazione con gli altri due, al prezzo del TLS terminato all'edge.

Ma qualunque fronte tu scelga, le cose che contano sono le stesse. L'auth vera davanti ai servizi sensibili — mai il Basic auth, sì a un SSO self-hosted o a Zero Trust. Il default-deny, così niente è esposto se non lo dichiari. La verifica dall'esterno dopo ogni modifica, perché la config può mentire e solo il comportamento osservato dice la verità. La gestione dei certificati con lo staging in test e la porta 80 aperta per i rinnovi. E la consapevolezza che il proxy è il componente a blast radius più alto: se cade, tutto è giù; se è mal configurato, esponi tutto in silenzio.

Fatto così, il fronte è il portone blindato del tuo stack sovrano: un solo varco controllato, tutto il resto invisibile, i dati sotto il tuo controllo. Fatto male, è la porta aperta che nessuno vede finché non entra qualcuno. La differenza non è quale dei tre hai scelto: è la disciplina con cui hai deciso cosa esporre, cosa proteggere, e cosa tenere per sempre dietro la rete interna.

Se stai mettendo online un'app agentica self-hosted e vuoi scegliere il fronte giusto — con l'auth al posto giusto e il blast radius sotto controllo — puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Networking da PMI, decisione, non slide.

## FAQ

### Qual è il reverse proxy giusto per una PMI?
Nella maggior parte dei casi Caddy: HTTPS automatico, configurazione leggibile e pochi pezzi da gestire, quindi poca superficie di errore. Passa a Traefik solo se hai molti servizi dinamici in Docker e ti serve davvero l'auto-discovery con i middleware. Scegli Cloudflare Tunnel se non hai un IP pubblico pulito o non vuoi aprire porte. Non esiste il migliore in assoluto: usa la matrice sulle tue esigenze reali.

### Perché il Basic auth non basta per proteggere n8n?
Perché non dà identità reale (utente e password condivisi, nessuna tracciabilità di chi entra), non ha MFA, manda le credenziali a ogni richiesta e non ha gestione seria di sessione e revoca. Se la password trapela sei dentro. Metti davanti un SSO self-hosted (Authelia/Authentik) con forward-auth, o Cloudflare Access col tunnel, ed eventualmente una IP allowlist come strato aggiuntivo. L'editor di n8n dà accesso a tutte le credenziali dei workflow: merita auth vera.

### Caddy e Traefik gestiscono i certificati da soli?
Sì, entrambi supportano ACME/Let's Encrypt con rinnovo automatico. Caddy lo fa per default senza configurazione; Traefik richiede di configurare un certresolver. Attenzione a due cose: usa lo staging di Let's Encrypt durante i test per non sbattere contro il rate limit, e tieni la porta 80 raggiungibile per i rinnovi se usi la challenge HTTP-01. Con Cloudflare Tunnel il TLS lo gestisce l'edge, quindi non hai il problema ACME lato tuo.

### Cloudflare Tunnel sostituisce Caddy o Traefik?
Non sempre. Il tunnel risolve l'ingresso (niente porte aperte, funziona dietro CGNAT), ma dietro di lui puoi comunque avere Caddy o Traefik che fanno il routing tra i servizi interni. Su un setup semplice (un servizio, un dominio) il tunnel da solo basta; su stack articolati spesso convivono. La scelta "vs" è netta solo quando decidi come far entrare il traffico; il routing interno è un'altra questione.

### Cos'è il blast radius di un reverse proxy?
È l'entità del danno se il proxy cade o è mal configurato. Se cade, tutto ciò che sta dietro diventa irraggiungibile (interruzione totale). Se è mal configurato, può esporre silenziosamente un servizio interno (l'editor di n8n senza auth, o peggio un database), o dare il controllo dell'host se il `docker.sock` montato viene compromesso. È il componente a rischio più alto dello stack: config versionata, default-deny, verifica dall'esterno e monitoraggio sono obbligatori.

### Perché montare docker.sock su Traefik è rischioso?
Perché il socket Docker dà il controllo totale sull'host: chi lo controlla può avviare container, montare filesystem, fare qualsiasi cosa. Traefik lo usa per scoprire i container e configurarsi da solo, ma se Traefik viene compromesso, il socket montato (anche in read-only) è una porta verso l'host. Montalo solo se ti serve davvero l'auto-discovery dinamico; se hai pochi servizi stabili, Caddy senza socket è più sicuro.

### Gli access log del proxy sono un problema GDPR?
Sì, perché contengono indirizzi IP, che sono dati personali. Vanno gestiti: definisci una retention breve con cancellazione automatica, valuta di anonimizzare l'ultimo ottetto dell'IP dove la finalità lo consente, proteggi l'accesso ai log e, se li mandi a un servizio esterno, ricorda che gli IP vanno lì (preferisci un logging self-hosted). Il fronte è anche il punto dove nasce un trattamento di dati personali.

### Come evito di esporre per errore un servizio interno?
Con il default-deny e la verifica dall'esterno. Su Traefik imposta `exposedbydefault=false` così nessun container è pubblico se non lo dichiari; su Caddy usa un catch-all che risponde 404 a ciò che non è previsto. E dopo ogni modifica, verifica *da fuori* (rete mobile, non la tua LAN) che i servizi protetti chiedano il login e quelli interni siano irraggiungibili. La config può sembrare giusta e comportarsi diversamente: fidati del comportamento osservato.

### Quali sono gli errori di certificato più comuni?
Porta 80 non raggiungibile per la challenge HTTP-01 (o dopo il setup, che fa fallire i rinnovi); il rate limit di Let's Encrypt raggiunto per aver ritentato in loop su produzione (usa lo staging in test); i wildcard che richiedono la challenge DNS-01; il DNS che non punta al server; il clock del server disallineato. La regola: staging durante i test, porta 80 aperta anche per i rinnovi, e monitora la scadenza invece di aspettare l'errore dell'utente.

### Meglio esporre i servizi con un proxy o con una VPN?
Dipende da chi deve accedere. Se un servizio serve solo a te e al team, una VPN (WireGuard/Tailscale) è più semplice e più sicura: non esponi nulla al pubblico. Il reverse proxy con auth ha senso quando qualcuno o qualcosa deve entrare da fuori (webhook pubblici, una dashboard per un cliente). Spesso si usano entrambi: VPN per l'accesso privato del team, proxy per ciò che deve essere pubblico. Esporre pubblicamente ciò che potrebbe stare su VPN è superficie di rischio inutile.
