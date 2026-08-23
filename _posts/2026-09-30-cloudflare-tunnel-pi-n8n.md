---
lang: en
permalink: /en/blog/cloudflare-tunnel-raspberry-pi-n8n/
alt_url: /it/blog/cloudflare-tunnel-raspberry-pi-n8n/
title: "Cloudflare Tunnel on a Raspberry Pi: expose n8n and the dashboard without opening a port (and without getting your home IP banned)"
date: 2026-09-30 07:30:00 +0200
author: "Antonio Trento"
description: "Ops guide to Cloudflare Tunnel on a Raspberry Pi to expose n8n and a dashboard without port forwarding: cloudflared in Docker, Zero Trust Access, what not to tunnel, and the lesson of residential IPs that get 403."
keywords: ["cloudflare tunnel raspberry pi n8n", "cloudflared docker", "sme reverse proxy", "residential ip 403", "zero trust tunnel", "expose n8n without opening ports"]
image: /assets/images/posts/cloudflare-tunnel-raspberry-pi-n8n.jpg
pillar: stack-sovrano
related: [/en/blog/self-hosted-n8n-openai-privacy/, /en/blog/docker-sme-sovereign-stack/]
---

## The wrong way to expose your Pi (it works until they burn you)

There is a rite of passage for anyone who puts n8n on a Raspberry Pi in the office or at home: you open the modem panel, forward port 5678, set up dynamic DNS, and in five minutes your automation is "online". It works. It still works the next day. Then, in a week or a month, someone finds it — because on the internet *everything* gets found, it is not a matter of if but of when — and you end up with the n8n editor open to the world, login attempts in the logs, and in the worst case a compromised machine sitting inside your home or office network.

**Cloudflare Tunnel on a Raspberry Pi for n8n** solves exactly this: you expose the services you need *without opening a single port* on the modem, with authentication in front, and without showing the world your home IP. The Pi opens an *outbound* connection to Cloudflare, and all inbound traffic goes through there. No port forwarding, no exposed IP, no port 5678 waiting to be found.

This is a concrete ops guide, for the lab and the small office: `cloudflared` in Docker on the Pi, public hostnames vs those protected by Access, what you must *never* tunnel, the lesson — learned the hard way by many — about **residential IPs that eat 403s**, and the maintenance nobody tells you about until the SD card dies. With copy-paste config fragments.

It is part of the path on how to build a sovereign stack on your own hardware, which I started with {{ '/en/blog/self-hosted-n8n-openai-privacy/' | relative_url }} and with the {{ '/en/blog/docker-sme-sovereign-stack/' | relative_url }}. Here we tackle the network piece: how to let the world in, in a controlled way, without throwing the door wide open.

## Why port forwarding on the modem is a terrible idea

Opening a port on the router feels like the most natural thing, and it is the most dangerous. Let's see why, without hedging.

- **You expose the device directly to scans.** The internet is scanned continuously. Engines like Shodan index every IP with open ports. Your port 5678 will land in a database of "exposed n8n" in no time, and bots will try credentials, known exploits, everything on autopilot.
- **You expose your home IP.** Anyone who reaches the service sees your residential address. That is a data point you would rather not give away, and it opens you to DDoS aimed straight at your line (which has no protection).
- **No filter in front.** Traffic arrives raw at the Pi. No WAF, no rate limit, no upstream authentication: if the service has a bug, you are uncovered.
- **Often it does not even work.** Many Italian home connections sit behind **CGNAT** (the ISP shares one public IP among several customers): port forwarding is simply not possible, or it requires a paid public IP. And the dynamic IP changes, breaking DNS.
- **You put the whole LAN at risk.** A compromised Pi is a foothold inside your network, from which to move toward NAS, PCs, printers, cameras.

The underlying point: **port forwarding inverts the right trust model.** It makes your device wait for connections from strangers. The correct model is the opposite: your device decides to connect *outbound* to a trusted point, and nobody can reach it directly. That is exactly what a tunnel does.

## Tunnel vs VPN vs VPS: threat and latency

Before you install, the architecture choice. There are three sensible ways to make a service on a home Pi reachable, and they serve different things. Anyone who skips this reasoning picks at random and regrets it.

| Approach | What it's for | Open ports | Latency | Data sovereignty |
|-----------|--------------|--------------|---------|--------------------|
| **Cloudflare Tunnel** | Public or semi-public services with auth | None | Low (nearby edge) | TLS terminated by Cloudflare |
| **VPN** (WireGuard/Tailscale) | Private access for you/the team | None (or 1 UDP) | Very low | Traffic only yours, E2E encrypted |
| **VPS + reverse proxy** | Public services, full control | On the VPS, not at home | Medium (extra hop) | You control everything (in the EU) |

The rule I use:

- **Is it only for you and your team?** → VPN (WireGuard or Tailscale). Nobody outside needs to see the service, everyone has their own client, minimum latency, and traffic does not go through a third party. It is the most sovereign option.
- **Does the public or external services need it** (e.g. inbound webhooks, a dashboard for a client)? → **Cloudflare Tunnel** with Access. No open port, authentication in front, edge protection.
- **Do you want full control and no intermediary that sees the traffic?** → Your own VPS in the EU with a reverse proxy and WireGuard to the Pi. It costs a few euros a month and more ops, but sovereignty is maximum.

An honest point on sovereignty, because it is the heart of this blog: **with Cloudflare Tunnel, TLS is terminated at Cloudflare's edge.** That means Cloudflare, technically, sees the traffic in the clear at the termination point. For an internal dashboard or non-sensitive webhooks it is an acceptable trade-off in exchange for zero open ports and solid authentication. For highly confidential data, a VPN or your own VPS is more consistent with a sovereign stack. There is no absolute "best": there is the right one for your threat. I cover this better in the "when NOT to do it" section.

## The reference architecture: what comes in and what stays inside

Here is how the whole thing is laid out. The key concept is the **boundary**: very few things cross the tunnel, everything else stays on the internal Docker network, unreachable from outside.

```
   Internet user ──▶ ┌────────────────────────────────────┐
                       │ CLOUDFLARE EDGE                     │
                       │ TLS · Access (Zero Trust) · WAF ·   │
                       │ rate limit                          │
                       └──────────────┬─────────────────────┘
                                      │ tunnel (OUTBOUND only from the Pi)
                                      ▼
                       ┌────────────────────────────────────┐
                       │ cloudflared (Docker container)      │
                       │ ingress rules                       │
                       └──────────────┬─────────────────────┘
                          │           │            │
                   public │    Access │     Access │
                          ▼           ▼            ▼
                  ┌────────────┐ ┌──────────┐ ┌────────────┐
                  │ n8n WEBHOOK│ │ n8n EDIT.│ │ DASHBOARD  │
                  │ /webhook/* │ │  (UI)    │ │            │
                  └────────────┘ └──────────┘ └────────────┘

   ── internal Docker network (does NOT cross the tunnel, ever) ──
   ┌──────────┐  ┌────────┐  ┌────────┐
   │ Postgres │  │ Redis  │  │ Ollama │   ← no public hostname
   └──────────┘  └────────┘  └────────┘
```

**What crosses the tunnel (the bare minimum):**

- The public path of n8n **webhooks**, if you receive events from external services (a Stripe, a form, a CRM). This *must* be public, but only the `/webhook/` path, not the whole app.
- The **n8n editor** and the **dashboard**, but behind Cloudflare Access — never public in the clear.

**What NEVER crosses the tunnel (the boundary you do not violate):**

- **Postgres, Redis, Ollama** and every support service: they live on the internal Docker network, with no public hostname. They have no reason to be reachable from the internet, and they will not be.
- The n8n editor **in the clear** (without Access): exposing the admin interface of an automation tool without upstream authentication is like leaving the keys in the lock.

This is the **reverse proxy for SMEs** done right: one controlled entry point, everything else invisible. The attack surface goes from "the whole Pi" to "three hostnames, two of them behind login".

## Install: cloudflared in Docker compose on the Pi

Let's get concrete. I assume you already have n8n and its services in Docker on the Pi (if not, start from the self-hosted n8n guide linked above). We add `cloudflared` as a container.

The flow: you create the tunnel from the Cloudflare Zero Trust panel, you get a **token**, and you pass it to the container. You manage ingress from the panel (a "remotely-managed" tunnel) — convenient for the Pi, because you update the rules without touching the machine.

```yaml
# docker-compose.yml — cloudflared fragment
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run --token ${CF_TUNNEL_TOKEN}
    networks:
      - proxy            # same network as n8n, to reach it by hostname
    # NO published ports: the connection is outbound only
    # No 'ports:' here. That is the point.

  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    environment:
      - N8N_HOST=n8n.yourdomain.com
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://n8n.yourdomain.com/
      - N8N_EDITOR_BASE_URL=https://n8n.yourdomain.com/
    networks:
      - proxy
      - internal        # to talk to Postgres, not exposed
    # here too: no 'ports:' toward the outside

networks:
  proxy:
    driver: bridge
  internal:
    driver: bridge
    internal: true      # network WITH NO internet access: DBs and the like go here
```

Two details that make the difference:

- **No published `ports:`.** Not on `cloudflared`, not on `n8n`. The tunnel reaches n8n *from inside* the Docker `proxy` network, via the container hostname. Nothing is listening on the Pi's IP toward the LAN or the internet. That is what makes port forwarding unnecessary (and wrong).
- **The `internal: true` network.** Postgres and Redis sit on a Docker network with no gateway to the internet. Even if you wanted to, they cannot be reached from outside nor go out. It is the boundary I talked about, enforced by Docker, not by good intentions.

Ingress rules (from the panel, or in `config.yml` if you prefer a "locally-managed" tunnel) map hostnames to internal services:

```yaml
# config.yml — if you manage the tunnel locally (alternative to the panel)
tunnel: <TUNNEL_ID>
credentials-file: /etc/cloudflared/<TUNNEL_ID>.json

ingress:
  # public webhooks: only the path you need
  - hostname: hooks.yourdomain.com
    path: ^/webhook/.*
    service: http://n8n:5678
  # n8n editor: behind Access (the policy is set in the panel)
  - hostname: n8n.yourdomain.com
    service: http://n8n:5678
  # internal dashboard
  - hostname: dash.yourdomain.com
    service: http://dashboard:3000
  # everything else: refused
  - service: http_status:404
```

Note the last rule: `http_status:404` as catch-all. Any unexpected hostname gets a 404, it does not accidentally land on a service. Default-deny, as it should be.

## Implementation path, step by step

1. **Create the Cloudflare account** and add your domain (or a dedicated subdomain). DNS must be managed by Cloudflare.
2. **Go to Zero Trust → Networks → Tunnels**, create a tunnel, pick "Docker" as the method, copy the **token**.
3. **Put the token in a `.env` file** on the Pi (never in the clear in the compose, never in git) and start the `cloudflared` container.
4. **Configure ingress** (panel or config.yml): map hostnames to internal services, with a 404 catch-all.
5. **Create Access policies** for the sensitive hostnames (editor, dashboard): authorised emails only.
6. **Leave only the webhook path public**, if you really need to receive external events.
7. **Verify from the outside** (mobile network, not your LAN) that protected hostnames ask for login and that Postgres/Redis are unreachable.
8. **Turn on rate limiting and basic WAF rules** at the edge.
9. **Set up monitoring** of the tunnel (up/down status) and Pi maintenance (below).
10. **Document** hostnames, policies, and the fallback plan.

## Public hostnames vs Access-only hostnames

This distinction is where you win or lose security. Not all hostnames are equal.

**Public hostname (no Access):** anyone with the URL reaches the service. It makes sense *only* for endpoints that must be public by nature — typically **inbound webhooks**: a Stripe, a Calendly, a CRM that calls your n8n when something happens. These cannot have a login in front, because the external service would not know how to authenticate. But you limit them to the `/webhook/` path, you do not expose the whole app, and you protect them with the webhook signature (every serious service signs its payloads — verify the signature in n8n).

**Hostname behind Access (Zero Trust):** Cloudflare puts an authentication layer *before* traffic reaches the tunnel. The user must authenticate (email one-time PIN, Google Workspace, etc.) and only if authorised do they pass. This is mandatory for:

- The **n8n editor** (admin access to workflows, credentials, everything).
- Any **dashboard** with company data.
- Management, monitoring, admin endpoints.

An example Access policy, allowing only two emails and requiring email OTP:

```json
{
  "name": "n8n-editor-team-only",
  "decision": "allow",
  "include": [
    { "email": { "email": "antonio@yourdomain.com" } },
    { "email": { "email": "colleague@yourdomain.com" } }
  ],
  "require": [
    { "email_domain": { "domain": "yourdomain.com" } }
  ],
  "session_duration": "8h"
}
```

The logic of the **Zero Trust tunnel**: you do not trust the network (there is no "safe internal network" to defend with a perimeter firewall), you trust **identity**. Every request to a protected hostname is checked against the identity of who is making it, regardless of where it comes from. It is the right model when the "perimeter" no longer exists, as in a small office with people working from home.

## What NEVER to tunnel

I repeat the boundary because this is the section that saves the most people. Some things must not be exposed, in any form, not even behind Access:

- **Postgres (5432), Redis (6379), and every database.** They have no reason to be reachable from the internet. They live on the Docker `internal` network. If you think you need to expose them "for convenience" (a remote SQL client), the answer is: use the VPN for that, not the public tunnel.
- **The n8n editor in the clear.** Never a public hostname pointing at the n8n UI without Access. It is the first target, and it gives access to all the credentials saved in your workflows.
- **Ollama and internal LLM services.** Your self-hosted model talks only to n8n and to the RAG, on the internal network. Exposing it means giving away compute to anyone and potentially exfiltrating data.
- **Admin panels without strong authentication** (Portainer, Grafana in admin mode, etc.): either behind Access with a tight policy, or VPN only.
- **Raw metrics and logs** that can reveal internal structure, versions, paths.

Mnemonic: **expose only what a stranger must be able to reach by force (the webhooks), and what an authorised person must use (behind Access). Everything else stays inside.**

## The public webhook, done safely: it is the only door that is actually open

Behind Access you are protected by identity. But the `/webhook/` path has to be public — it must be callable by an external service that does not log in. It is therefore the **only truly exposed surface** of your setup, and it must be treated carefully, because that is where an attacker will knock.

Three layers of defence, from the most important:

- **Verify the payload signature.** Every serious service (Stripe, GitHub, many CRMs) signs its webhooks with an HMAC and a shared secret. In n8n, the first node after the trigger must **verify that signature** and drop everything that fails it. Without this check, anyone who knows the URL can send you fake events and trigger your automations with arbitrary data.

```javascript
// Function node in n8n: verify HMAC signature before proceeding
const crypto = require('crypto');
const secret = $env.WEBHOOK_SECRET;           // from .env, not hardcoded
const signature = $headers['x-signature'] || '';
const body = JSON.stringify($json);
const expected = crypto.createHmac('sha256', secret)
                     .update(body).digest('hex');
if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) {
  throw new Error('Invalid webhook signature: request discarded');
}
return items;
```

- **Rate limit at the edge.** Configure a Cloudflare rate-limiting rule on the webhook hostname: a legitimate sender does not call you a thousand times a second. The rate limit absorbs flood attempts before they touch the Pi.
- **Restrict the path and, where possible, the origin.** Expose only `^/webhook/.*`, nothing else. Some services publish the IP ranges they send webhooks from: if you know them, a WAF rule that accepts only those almost closes the surface entirely.

The rule: **an unauthenticated webhook that triggers automations is a button you left for anyone to press.** The signature turns it into a button that answers only the right sender. It is the only place anonymous traffic comes in: protect it as such.

## Residential IPs, scraping and bans: don't hammer APIs from home

This is the lesson the title promises, and almost nobody tells you before it happens to you. The tunnel handles *inbound* traffic. But your Pi also does *outbound* traffic — automations call APIs, agents make requests, maybe scraping. And here the **residential IP** burns you.

What happens:

- **Residential IPs are "dirty" for many services.** They are often in CGNAT (shared among users), they land on blocklists because of other people's abuse, and many services treat traffic from residential ranges with suspicion. Result: **403s, captchas, aggressive rate limits** right when you expect everything to go smoothly.
- **If you hammer an API from home, you burn the IP.** An agent that makes a thousand requests a minute to an external service from your home IP: first the rate limit, then the ban. And because the IP is shared (CGNAT) or dynamic, the ban can hit more than you, or move when the IP changes — a nightmare to diagnose.
- **Some APIs block residential ranges on purpose** as policy, regardless of volume. You get a 403 and you do not understand why, until you try the same code from a datacenter IP and it works.

How you behave, as serious ops:

- **Respect rate limits and use exponential backoff.** Do not hammer. Serious APIs publish their limits: stay inside them with margin.
- **Use official APIs, not scraping**, where they exist. Scraping from a residential IP is the fastest way to collect 403s.
- **If you need outbound volume, do not do it from home.** Move the egress work to a small VPS in the EU with a clean datacenter IP, or use a service with dedicated IPs. The Pi orchestrates; massive outbound goes through an IP built for that.
- **Split the loads:** light internal automation (a few calls) is fine on the Pi; scraping or high-volume integrations need a different design.

The principle: **the tunnel does not change the fact that your outbound IP is residential.** Sovereignty and a homelab are beautiful for hosting your data, less suited as a source of aggressive traffic toward third parties. Design egress with the same care as ingress.

## Maintenance: SD card, power, freeze

A Pi in production is not "install and forget". The three ways it dies, in order of frequency:

**1. The SD card wears out.** SD cards have limited write cycles, and Docker + database + logs write continuously. A cheap SD dies in months. Countermeasures:

- **Boot from USB SSD** instead of SD: more reliable and faster. It is the single upgrade that is worth the most.
- If you stay on SD, use **high-endurance cards** (the ones for dashcams/CCTV) and move the "heavy" Docker volumes (Postgres) to a USB disk.
- Reduce writes: `log2ram` to keep logs in RAM and flush them periodically, aggressive `logrotate`.

**2. Unstable power corrupts everything.** The Pi is sensitive to voltage drops. A cheap PSU or a brownout causes filesystem corruption — often the way the SD "dies" is actually a write interrupted halfway.

- Use an **official/quality power supply** with the right amperage.
- A small **UPS** (even one of those made for Pis) avoids corruption from micro-outages. In an office, it is worth the investment.

**3. The silent freeze.** The Pi locks up, or a container goes into a loop, and you only notice when the automation stops running.

- **Hardware watchdog** of the Pi enabled, so a total lock-up causes a reboot.
- **Healthcheck** on Docker containers with `restart: unless-stopped`, so a dead service comes back.
- **External monitoring** of tunnel and service status (an uptime monitor that alerts you if `n8n.yourdomain.com` does not respond). Failure must be notified, not discovered.

This physical part is what distinguishes an experiment from a service. A homelab that holds for six months without being touched is made of SSD, a good PSU, and monitoring — not luck.

## Fallback if Cloudflare is down

Depending on an intermediary means inheriting its outages. If Cloudflare has a problem, or your tunnel disconnects, public services become unreachable. That has to be accounted for and mitigated.

- **`cloudflared` reconnects on its own.** With `restart: unless-stopped` and the internal retry logic, a network blip resolves without intervention. Most "downs" are transient.
- **Emergency access via LAN or VPN.** Always keep a way to reach the Pi that does *not* depend on the tunnel: SSH on the local LAN, or better a VPN (WireGuard/Tailscale) that gives you direct access independent of Cloudflare. When the tunnel is down and you need to diagnose, this is your anchor.
- **Independent monitoring.** The uptime monitor that alerts you must run *off* the Pi and preferably not only on Cloudflare, so you can tell "the Pi is dead" from "the tunnel is down" from "Cloudflare has an outage".
- **Critical webhooks: consider redundancy.** If receiving a webhook is business-critical and you cannot afford to lose one during a down, the external service usually retries (Stripe does it for hours). Check the retry policy of whoever sends you events: often the fallback is already there, free.
- **Documented plan B.** Write what to do when the tunnel is down: how to access, who to notify, what to expect. A two-paragraph runbook is worth more than half an hour of panic.

Honesty: no single-intermediary solution has perfect uptime. If your case tolerates *no* downtime, the right architecture is not a home Pi with a single tunnel — it is real redundancy, which costs. Know where you sit on the scale between "robust hobby" and "mission-critical service".

## Typical failures and how you spot them in the logs

- **`cloudflared` connected but 502 on the hostnames.** The tunnel is up but cannot reach the internal service. In the `cloudflared` logs you see connection errors toward `http://n8n:5678`. Typical cause: container not on the same Docker network, or wrong name/port in ingress.
- **n8n editor reachable without login.** If you open the editor hostname from a mobile network and it does *not* ask for authentication, the Access policy is not active on that hostname. Serious error: fix it immediately.
- **403/captcha on outbound calls.** In the n8n logs you see API requests failing with 403. It is the residential IP (above). It is not a bug in your code: it is your outbound IP.
- **Tunnel disconnecting intermittently.** `cloudflared` logs with frequent reconnects: often an unstable home network, or the Pi under load/freezing. Correlate with CPU use and system logs.
- **Lost webhooks.** If an automation does not start, check whether the webhook arrived: a 404 at the edge means wrong hostname/path in ingress; no trace means the external service did not even try (check its config).
- **Corruption after a reboot.** Filesystem errors or Postgres that does not start after a power drop: it is the SD/power. Classic symptom, physical cause.

Rule: **look at the `cloudflared` logs AND the service logs.** 90% of problems is "the tunnel is up but does not talk to the service" or "the service is up but the outbound IP is blocked": two different things, two different logs.

## Costs: orders of magnitude

Declared estimates, for a homelab/small-office setup.

- **Cloudflare Tunnel + Access:** the plan that covers typical use (tunnel, Access for a contained number of users) falls in the free tier or close. For small teams, **cost near zero**. Check the free-tier limits on the number of Access users.
- **Raspberry Pi hardware:** the Pi itself, plus — strongly recommended — a **USB SSD** and a **quality PSU**, and optionally a small UPS. As an order of magnitude, a few tens/a hundred euros one-off. The SSD is the investment that pays back the most in reliability.
- **Electricity:** a Pi with an SSD draws a few watts. On the bill, as an order of magnitude, **a few euros a year**. It is one of its big advantages versus a server on 24/7.
- **Egress VPS** (if you need it for high-volume outbound traffic): a few euros a month for a small VPS in the EU with a clean IP. Optional, only if you do volume.
- **Cost of not managing it:** a dead SD in the middle of a critical automation, or a punched n8n editor, costs a lot more than the time of doing things properly. Maintenance is cheap; the incident is not.

## When NOT to do it

- **If the data is highly confidential** and you do not accept TLS being terminated by an intermediary, Cloudflare Tunnel is not the most consistent choice. Go VPN (private access) or your own VPS in the EU with your own reverse proxy. Full sovereignty requires not delegating TLS termination.
- **If access is only for you and the team**, do not expose anything to the public: a VPN (WireGuard/Tailscale) is simpler, safer and more sovereign. The public tunnel makes sense when someone or something *must* come in from outside.
- **If the service is mission-critical with no tolerance for downtime**, a home Pi with a single tunnel is not the right infrastructure. You need real redundancy, which is a different budget.
- **If you have to do high volumes of outbound traffic** (scraping, heavy integrations), do not do it from the residential IP: design dedicated egress, or you risk bans and 403s on repeat.
- **If you cannot guarantee physical maintenance** (SSD, power, monitoring), know that the Pi will betray you at the worst moment. Better a small managed VPS than a neglected Pi.

## Hardening checklist before going live

- [ ] **No open ports** on the modem/router. Verify from the outside (scanner) that your IP has no ports listening.
- [ ] **`cloudflared` with no published `ports:`**: outbound connection only.
- [ ] **Postgres, Redis, Ollama** on a Docker `internal: true` network, no public hostname.
- [ ] **n8n editor and dashboard behind Access**, with a policy that allows only authorised emails.
- [ ] **Only the `/webhook/` path public**, with webhook signature verification on.
- [ ] **Catch-all `http_status:404`** in ingress: unexpected hostnames refused.
- [ ] **Tunnel token in `.env`**, never in git, tight file permissions.
- [ ] **Rate limiting and basic WAF** active on the Cloudflare edge.
- [ ] **Verify from the outside** (mobile network): protected ones ask for login, DBs unreachable.
- [ ] **Boot from SSD**, quality PSU, UPS if possible.
- [ ] **Watchdog + healthcheck + restart** on containers and system.
- [ ] **External monitoring** of the tunnel and services, with alerts.
- [ ] **Emergency access via VPN/LAN** independent of the tunnel.
- [ ] **Fallback runbook** written (Cloudflare down, Pi down, SD dead).

## The verdict

**Cloudflare Tunnel on a Raspberry Pi for n8n** is the right way to let the world into your homelab: you invert the trust model, the Pi connects outbound, and nobody can reach it directly. No port forwarding, no exposed home IP, Zero Trust authentication in front of sensitive services, and a sharp boundary between the very little that crosses the tunnel (webhooks and protected UIs) and everything else that stays closed on the Docker network (databases, cache, models). It is a huge security jump versus port 5678 open on the modem, and it costs almost nothing.

But remember the two honest limits. The first: the tunnel does not make your outbound IP less residential — if you hammer APIs from home, the 403s and bans arrive anyway, and high-volume egress has to be designed elsewhere. The second: you are delegating TLS termination to an intermediary, which is fine for an internal dashboard and much less so for highly confidential data, where a VPN or your own VPS is more consistent with a truly sovereign stack.

And above all: a Pi in production is hardware. SSD, a good PSU, monitoring, a fallback runbook. The difference between an experiment that dies with the first power drop and a service that holds six months without thinking about it is not the tunnel. It is the ops care you put around it.

If you are building a sovereign stack on your own hardware and you want to expose it without opening holes — or understand whether for your case a tunnel, a VPN or a VPS is better — you can see how I work on [antoniotrento.net]({{ site.main_site }}/biografia/) or write me from the [contacts]({{ site.main_site }}/contatti/) page. Concrete ops, not slides.

## FAQ

### Is Cloudflare Tunnel actually free?
For typical homelab or small-office use, access to the tunnel and to Access for a contained number of users falls in the free tier. Check the panel for the current limits on Access users and features: some advanced options need a paid plan. But to expose n8n with a few authorised people, the cost is near zero.

### Do I have to open any port on the router?
No, and that is the central point. `cloudflared` opens an *outbound* connection to Cloudflare; no inbound port is opened on the modem. In fact, the correct setup has you close any existing port forwarding. Verify from the outside, with a port scanner, that your IP has nothing listening: that is how it must be.

### Does it work even if I am behind CGNAT?
Yes, and it is one of the bigger advantages. Because the connection is outbound only, you do not need a reachable public IP or port forwarding — which under CGNAT is often impossible. The tunnel works behind CGNAT, behind a dynamic IP, behind almost any network that allows outbound HTTPS.

### Can Cloudflare see my traffic?
In the tunnel model, TLS is terminated at Cloudflare's edge, so technically yes, at the termination point the traffic is in the clear for Cloudflare. For internal dashboards and non-sensitive webhooks it is an acceptable trade-off. For highly confidential data, consider a VPN (traffic only yours) or your own VPS in the EU where you control TLS termination. It is a convenience-versus-sovereignty trade-off to make consciously.

### Why do I get 403s on some APIs even when volume is low?
Because your outbound IP is residential, and some services block or filter residential ranges as policy, regardless of volume. It is not a bug in your code. If you need to call those APIs reliably, route outbound traffic from a clean datacenter IP (a small VPS in the EU), keeping the Pi as orchestrator.

### Can I expose the n8n editor publicly?
No, never in the clear. The editor gives access to all your workflows and saved credentials. Always put it behind Cloudflare Access with a policy that allows only authorised emails. If you need access only for yourself, you can also keep it reachable solely via VPN and not expose it on the tunnel at all.

### What if Cloudflare goes down?
`cloudflared` reconnects on its own after transient blips. For longer downs, always keep emergency access independent of the tunnel (VPN or SSH on the LAN) and external monitoring that alerts you. For webhooks, most external services retry delivery for hours, so you often do not lose events. Document a minimum fallback plan.

### SD card or SSD for a Pi in production?
USB SSD, no doubt, if the Pi does serious work with databases and Docker. SDs wear out with continuous writes and die, often in a sneaky way (corruption after a power drop). The SSD is the upgrade with the highest return in reliability. If you have to stay on SD, use high-endurance cards and move the heavy volumes to an external disk.

### What is the practical difference between tunnel and VPN for my case?
The tunnel is for letting someone or something in from the outside (public webhooks, a dashboard for a client) with authentication in front. The VPN is for giving private access to you and your team, without exposing anything to the public. If nobody outside needs to reach the services, the VPN is simpler and more sovereign. If you need to receive external traffic, the tunnel is the answer. Often you use both.

### Can I put more services on the same tunnel?
Yes. A single tunnel handles multiple hostnames through ingress rules: one for n8n, one for the dashboard, one for webhooks, each mapped to the right internal service, each with its own Access policy. It is the normal pattern: one `cloudflared`, many hostnames, a 404 catch-all for everything else. Keep public only the hostnames that must be, and protect the others with Access.
