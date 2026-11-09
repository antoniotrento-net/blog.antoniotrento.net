---
layout: pillar
lang: it
permalink: /it/pillar/stack-sovrano/
pillar_key: stack-sovrano
section: stack-sovrano-ai
title: "Stack sovrano & DevOps"
description: "Docker, reverse proxy, backup, secret e n8n in produzione: l'ecosistema self-hosted che tiene i dati in casa e non ti tradisce alle 3 di notte."
image: /assets/images/pillars/stack-sovrano.jpg
alt_url: /en/pillar/sovereign-stack/
sitemap: false

---

"Self-hosted" è una parola che piace molto finché il server non si spegne di notte. Tenere i dati in azienda (o in un datacenter europeo sotto il tuo controllo) invece di affidarli a una manciata di SaaS americani è una scelta sensata per molte PMI: costi prevedibili, dati che non escono, nessun fornitore che cambia le condizioni da un giorno all'altro. Ma è una scelta che ha un prezzo: qualcuno deve occuparsi di container, certificati, segreti, backup, aggiornamenti. E deve farlo bene, perché quando qualcosa si rompe non c'è un supporto da chiamare.

Questa guida raccoglie gli articoli sull'**infrastruttura self-hosted che regge**: Docker per PMI, reverse proxy e tunnel, n8n in produzione, segreti e chiavi, backup provati, container blindati per gli agenti, e il galateo verso le fonti esterne. Il punto non è avere tutto in casa. È avere in casa solo quello che sai gestire.

## Il principio: sovrano non vuol dire artigianale

Il filo che lega questi articoli è che **la sovranità sui dati si misura alle tre di notte**. Uno stack che tiene i dati in azienda ma non ha backup provati, segreti in un `.env` committato e un container che gira come root non è sovrano. È fragile, e i dati li perdi in un altro modo. La differenza tra un'infrastruttura self-hosted seria e un insieme di container accesi a mano sta in poche abitudini: versioni fissate, segreti fuori dai file di configurazione, privilegi minimi, backup con restore provato, log che dicono cosa è successo.

L'altro filo è il **realismo sulle dimensioni**. Una PMI non ha bisogno di Kubernetes, di tre zone di disponibilità o di un team di sistemisti. Ha bisogno di un compose leggibile, di un server (o due) dimensionati con onestà, e di runbook di una pagina che anche chi non ha costruito il sistema possa seguire.

## I temi (e l'articolo che li affronta)

**Le fondamenta**

- **«Vogliamo uscire da Microsoft 365 e dai SaaS»** — ERP, BI e agenti sulla stessa compose, con dati in casa: [lo stack Docker sovrano per PMI]({{ '/it/blog/docker-pmi-stack-sovrano/' | relative_url }}).
- **«Il workflow n8n manda i dati dei clienti a OpenAI»** — come accorgersene e come chiuderlo in Docker: [n8n self-hosted e privacy]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}).
- **«Traefik, Caddy o Cloudflare Tunnel?»** — certificati, autenticazione e esposizione per un'app self-hosted: [il confronto tra reverse proxy]({{ '/it/blog/traefik-vs-caddy-vs-cloudflare-tunnel/' | relative_url }}).
- **«Vogliamo esporre n8n senza aprire porte»** — Cloudflare Tunnel su Raspberry Pi, e come non farsi bannare l'IP: [il tunnel sul Raspberry Pi]({{ '/it/blog/cloudflare-tunnel-raspberry-pi-n8n/' | relative_url }}).

**n8n in produzione**

- **«L'automazione ogni tanto non parte»** — queue mode con Postgres e il dimensionamento dei worker: [n8n in queue mode]({{ '/it/blog/n8n-queue-mode-postgres/' | relative_url }}).
- **«Il server è ripartito, le credenziali no»** — la encryption key di n8n, il suo backup, quando serve un vault e come ruotare i token: [credenziali n8n e vault]({{ '/it/blog/n8n-credentials-vault-infisical/' | relative_url }}).

**Sicurezza e resilienza**

- **«Il token è nel .env del compose»** — perché il `.env` non è un vault, e come tenere i segreti fuori dal contesto del modello: [i segreti degli agenti]({{ '/it/blog/secrets-agenti-llm-vault/' | relative_url }}).
- **«L'agente gira come root»** — user namespace, filesystem in sola lettura, reti interne e test di fuga: [l'agente senza root]({{ '/it/blog/agente-ai-privilegi-docker/' | relative_url }}).
- **«Il backup c'era, il restore no»** — Postgres, n8n, volumi e il drill mensile su un server vuoto: [backup e restore dello stack]({{ '/it/blog/backup-docker-postgres-n8n/' | relative_url }}).

**Verso l'esterno**

- **«Una fonte dati ci ha bloccato l'IP»** — rate limit delle API pubbliche, cache, jitter e user-agent onesto: [rate limit e cache delle API pubbliche]({{ '/it/blog/rate-limit-api-pubbliche-cache/' | relative_url }}).

## Il pezzo che decide tutto: il restore, non il backup

In quasi tutti questi articoli, prima o poi, si arriva alla stessa prova. Non conta quanto è elegante lo stack: conta se, partendo da un server vuoto, **sai rimetterlo in piedi** con i dati di ieri. Questo include il dump del database, i volumi, la encryption key di n8n, i certificati, i segreti, l'ordine giusto in cui far ripartire i servizi. Il drill di restore è l'esame che rivela tutto il resto: il segreto che stava solo sul server, la chiave che nessuno aveva copiato, il volume che non era nel backup.

Una volta al mese, su una macchina vuota, con il runbook stampato. È il singolo controllo che separa uno stack sovrano da uno che lo sembra.

## Cosa ci gira sopra

Questa infrastruttura è la base su cui girano modelli, agenti e integrazioni. Per i modelli in casa e i loro costi c'è la guida su [modelli, costi e privacy]({{ '/it/pillar/modelli-costi-privacy/' | relative_url }}). Per gli agenti che agiscono sui sistemi c'è quella sugli [agenti che eseguono]({{ '/it/pillar/agenti-esecuzione/' | relative_url }}). Per collegare PEC, CRM e gestionali c'è quella su [integrazioni e dati legacy]({{ '/it/pillar/integrazioni-dati/' | relative_url }}).

## Come usare questa guida

Parti dal punto in cui il tuo stack è più fragile oggi. Spesso sono i backup mai provati o i segreti nei file di configurazione. Ogni articolo ha un'architettura di riferimento, file di configurazione copiabili, i fallimenti tipici con le righe di log che li rivelano, i costi in ordine di grandezza e una sezione onesta su quando conviene una soluzione più semplice, o un servizio gestito.

Se vuoi portare dati e automazioni in casa senza trasformarti in un sistemista a tempo pieno, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi da [contatti]({{ site.main_site }}/contatti/).

Qui sotto trovi tutti gli articoli di questa guida.
