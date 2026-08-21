---
lang: en
permalink: /en/blog/docker-sme-sovereign-stack/
alt_url: /it/blog/docker-pmi-stack-sovrano/
title: "Sovereign Docker stack for SMEs: ERP, BI and AI agents on the same compose (without Microsoft 365 holding you hostage)"
date: 2026-09-24 07:30:00 +0200
author: "Antonio Trento"
description: "Sovereignty isn't a slogan, it's architecture: Docker networks, service boundaries, tested backups, possible offboarding. How to run ERP, BI and AI agents on your stack without depending on Microsoft or Google."
keywords: ["docker sme sovereign stack", "self-hosted erp", "docker compose production", "saas vendor lock-in", "postgres bi"]
image: /assets/images/posts/docker-pmi-stack-sovrano.jpg
pillar: stack-sovrano
related: [/en/blog/self-hosted-n8n-openai-privacy/, /en/blog/vllm-vs-ollama-in-production/]
---

## The bill you don't look at: Microsoft and Google over three years

Do a sum almost nobody does. Take what you pay per user per month for Microsoft 365 or Google Workspace, add the subscription CRM, the BI tool, storage, automation, the "copilot" they just sold you. Multiply by the number of employees. Then multiply by **36 months**. The number that comes out always surprises — and it isn't even the bigger problem. The problem is that at the end of those three years **you own nothing**: your data, your identity, your flows live at their house, and if one day you want to leave you discover that offboarding is a nightmare, because everything was built to keep you in. That is **vendor lock-in**: you pay for years and you stay hostage.

There is an alternative, and it isn't "throw everything away and become a digital hermit": it is building a **sovereign Docker stack** where ERP, BI, automation and AI agents run on infrastructure you control — a rack in the office or a VPS in the EU — with data, identity and backups in your hands. But watch this, and it is the point of the whole article: **sovereignty isn't a slogan, it's architecture.** Downloading a few containers does not make you "sovereign": you have to design the boundaries between services, the internal networks, the tested backups, the permissions, and — yes — the possibility of leaving. In this piece we look at what sovereign actually means (data, identity, DNS, backup, offboarding), the service map of a stack for SMEs, the choice between one compose and many (the "blast radius"), backups you actually test, updates without "dead Monday", permissions (the AI agent must not see the whole ERP), and the staged migration path. With the boundary diagram, the internal Docker networks, and the restore checklist. Because sovereignty is in the architecture, or it is marketing.

## What "sovereign" actually means: data, identity, DNS, backup, offboarding

"Sovereign" is an abused word. Let's make it concrete, because these are five precise things, and if one is missing you are not sovereign — you are only half self-hosted.

- **The data.** Your data lives on infrastructure you control, in the EU, and you can **export it** at any time in a usable format. If you can't pull it out, it isn't yours.
- **Identity.** Who accesses what is decided by *your* identity system (your own IdP, Authentik or Keycloak), not the Microsoft/Google account. Identity is the key to everything: if it depends on a vendor, you depend on them for access to your own systems.
- **DNS and domains.** Your domains are registered to you, you control the DNS. It looks like a detail: it is the difference between being able to move everything tomorrow and being stuck because you don't even own your own address.
- **Backups.** Copies of the data that *you* own and know how to restore — not "the vendor has backups" (that is their insurance, not yours). A backup you don't know how to restore is not a backup: it is a hope.
- **Offboarding.** The acid test of sovereignty: **can you leave?** If tomorrow you want to change everything, how painful is it? In a well-built sovereign stack, offboarding is possible because nothing is built to trap you. In lock-in, it is designed so you can't get out.

The mental test is simple: *"if my vendor doubled prices tomorrow, or shut down, or locked my account, what would happen to my company?"* If the answer is "I'd be paralysed", you are not sovereign. If it is "I'd move, with effort but I could", you are. Sovereignty is that freedom — the same one I defend when I talk about [owning the code, the access and the data of custom software]({{ '/en/blog/software-maintenance-after-go-live/' | relative_url }}): it isn't ideology, it is not being trapped.

## The service map: reverse proxy, IdP, DB, queues, AI worker

A sovereign stack for SMEs is not "one magic container": it is a set of services with precise roles. Here is the map of the pieces that make up the ecosystem:

- **The reverse proxy** (Caddy, Traefik, Nginx): the only point exposed to the internet. It handles HTTPS, routes requests to the right services, puts authentication in front. Everything enters here, nothing else is exposed.
- **The IdP** (Authentik, Keycloak): the identity system. One login for all services, managed by you. Who gets in, who sees what.
- **The database** (PostgreSQL): the heart of the data. ERP, BI, automation sit on it. Postgres alone covers the relational database, and with pgvector also the embeddings (as in the [RAG on invoices]({{ '/en/blog/pgvector-rag-electronic-invoices/' | relative_url }})).
- **The queue / cache** (Redis): for async jobs, queues, sessions.
- **The ERP / management system** (a self-hosted one that fits your business): the real operational system.
- **The BI** (Metabase or similar): the dashboards on the data, sitting on the same Postgres.
- **Automation** (n8n): the workflows that tie the pieces together.
- **The AI worker** (Ollama or [vLLM for production]({{ '/en/blog/vllm-vs-ollama-in-production/' | relative_url }})): the language models locally.
- **File storage** (a self-hosted file service): documents and attachments.

The architectural point is not "which software", but **how they talk to each other and who sees whom.** And that is where the boundary diagram comes in:

```text
                    INTERNET
                       │  (443 only)
                 ┌─────▼─────┐
                 │  REVERSE  │   network: frontend
                 │   PROXY   │   (exposed)
                 │  + TLS    │
                 └─────┬─────┘
        ┌──────────┬───┴────┬──────────┐
     ┌──▼──┐   ┌───▼──┐  ┌──▼──┐    ┌──▼───┐
     │ IdP │   │ ERP  │  │ BI  │    │ n8n  │   network: frontend
     └──┬──┘   └───┬──┘  └──┬──┘    └──┬───┘
        └──────────┴────────┴──────────┘
                       │   network: backend (INTERNAL, no internet)
        ┌──────────┬───┴────┬──────────┐
   ┌────▼───┐  ┌───▼───┐ ┌──▼───┐  ┌───▼────┐
   │Postgres│  │ Redis │ │worker│  │ storage│   network: backend
   │        │  │       │ │  AI  │  │  file  │
   └────────┘  └───────┘ └──────┘  └────────┘
```

The golden rule: **only the reverse proxy touches the internet.** Everything else lives behind it, on networks that are not reachable from outside. And the "heavy" data (database, AI worker, storage) sits on an **internal** network that even the web services cannot expose. That is the boundary, and it is what makes the stack defensible.

## Internal Docker networks: the boundary that protects you

The diagram above translates into **segmented Docker networks**, and it is one of the most important and most neglected things. Putting every container on the same network "so they can talk" is convenient and dangerous: if one is compromised, it sees all the others. Segmentation limits the damage.

```yaml
networks:
  frontend:
    driver: bridge
    # exposed to the reverse proxy; web services live here
  backend:
    driver: bridge
    internal: true
    # INTERNAL: no connectivity to the internet.
    # Database, AI worker and storage live here and are NOT
    # reachable from outside, even if something is breached.
```

Service assignment to networks follows the diagram:

```yaml
services:
  reverse-proxy:
    networks: [frontend]
    ports: ["443:443"]        # the ONLY one with exposed ports

  erp:
    networks: [frontend, backend]   # web (frontend) + access to the DB (backend)

  postgres:
    networks: [backend]         # INTERNAL only: no access from the internet
    # no 'ports:' — not exposed on the host

  worker-ai:
    networks: [backend]         # the AI model sits behind, not in front
```

Two principles this configuration enforces:

- **The database has no exposed ports.** No `ports:` on Postgres: you reach it only from services on the `backend` network, never from the internet. It is the most common security mistake in stacks thrown together in a hurry — Postgres with port 5432 open to the world — and here it is impossible by construction.
- **The `backend` network is `internal: true`.** It has no way out to the internet. Even if a container on that network were compromised, it cannot "phone home" to the outside. It is the fence inside the fence.

This segmentation is the concrete translation of "sovereignty as architecture": not a slogan, but networks, boundaries and closed ports. It is the same rigour as the [n8n + local model fence]({{ '/en/blog/self-hosted-n8n-openai-privacy/' | relative_url }}), applied to the whole company ecosystem.

## One compose or many compose: the blast-radius question

A real architectural question: do you put everything in **one** `docker-compose.yml` or split it into **many**? The answer depends on one concept: the **blast radius** — how much damage a problem does when it happens.

- **A single compose** is simpler to manage and to understand: everything in one place, you bring it up with one command. But the blast radius is wide: a bad update, a config error, a restart, and you risk touching *everything* at once. If one service goes down badly, it can take the others with it.
- **Many compose files** (by logical groups: one for data/DB, one for the ERP, one for AI, one for the proxy) isolate problems. You update AI without touching the ERP; you restart automation without risking the database. The blast radius of every operation is smaller. The cost is more coordination complexity (networks have to be shared across compose files, services have to find each other).

The practical choice for an SME:

- **The "foundational and stable" services** (Postgres, reverse proxy, IdP) — the ones you change rarely and that everything depends on — belong in a compose of their own, kept stable.
- **The "services you iterate"** (n8n, AI worker, the ERP you update) in separate compose files, so you move them without risking the foundations.

The principle: **isolate what changes from what must stay still.** The database and identity are the foundations: you don't want to touch them every time you update a workflow. Separating by blast radius means you can work on one piece without trembling for the others. It is the infrastructure equivalent of not putting all your eggs in one basket — and in production, where a "dead Monday" costs dearly, it counts.

## Backups you actually test (not the ones you hope exist)

This is the section that separates people who "have backups" from people who are actually safe. Having backups is useless if you don't know how to restore them. A backup is an illusion until you have **tested** it.

What needs saving, in a sovereign stack:

- **The database dump.** A regular `pg_dump` of Postgres: it is the heart of the data. Automated, versioned, taken **off** the machine (a backup on the same machine that dies does not save you).
- **Docker volumes.** Persistent data of the services (file storage, configs, state). The DB is not enough: some services keep data in volumes.
- **Secrets.** Keys, passwords, certificates (in a secret manager, or at least encrypted and backed up separately). If you restore the data but you have lost the encryption keys, the data is unusable.
- **Configurations.** The compose files, the rules, the service configs: versioned in git. They are the "recipe" to rebuild the stack.

But the piece almost nobody does, and it is the one that counts: **the monthly restore test.** Once a month, take the backups and try to **rebuild** the stack from scratch on a test machine. If you can't, your backups are worth nothing — and you found out during a test, not during a disaster. Here is the restore checklist:

```text
RESTORE CHECKLIST (monthly, on a test machine)
[ ] Retrieve the latest pg_dump from the off-machine backup
[ ] Retrieve the volumes and the secrets
[ ] Bring the stack up from the versioned compose files (git)
[ ] Restore the database from the dump
[ ] Check: do the services start? does the IdP authenticate?
[ ] Check: is the data there and consistent (counts, latest records)?
[ ] Check: does the ERP open? does the BI show data? does the AI answer?
[ ] Stopwatch: how long did it take? (this is your real RTO)
[ ] Note what was missing/broken and fix it in the process
```

That stopwatch is precious: it tells you your **real recovery time** (RTO), meaning how long the company would sit still in a disaster. If it is "I don't know", you don't have a continuity plan, you have a hope. The restore test turns hope into a demonstrated capability.

## Updates without "dead Monday"

The terror of every self-hosted stack: you update something on Friday, on Monday nothing works and the company is down. "Dead Monday" is what scares people off self-hosting — but you avoid it with method, not with luck.

- **Pin the versions.** Don't use `latest` in production: a `latest` that updates itself is a roulette wheel. Pin precise container versions, and update when *you* decide, not when it happens.
- **Update one piece at a time.** Thanks to the blast-radius split: you update the AI worker, you verify, then you move on. Never "I update everything together and hope".
- **Try it on staging first.** A test environment (even a minimal one) where you test the update before production. It costs little and it saves Monday.
- **Update when you can roll back.** Before updating, make sure you can **go back** (fresh backup, previous version within reach). An update with no way back is a gamble.
- **Don't update on Friday.** Operational golden rule: update when you have the time and the people to handle a problem, not before the weekend or a holiday.

The method turns updates from roulette into routine. Self-hosting is not dangerous *in itself*: it is dangerous when you do it without discipline. With pinned versions, contained blast radius, staging and rollback, "dead Monday" doesn't happen — it happens to people who put `latest` everywhere and update everything together hoping for the best.

## Permissions: the AI agent does not see the whole ERP

A specific and crucial security theme when you put AI in the stack: **the AI agent must not have access to everything.** The temptation, to make it "work right away", is to give it the keys to the whole database or full access to the ERP. That is the mistake that turns an assistant into a hole.

The **least privilege** principle, applied to AI in the stack:

- **Access only to the data it needs.** If the AI agent has to answer questions on documents, you give it access to the document index, not the entire HR and accounting database. A dedicated database user, with read-only permissions on *only* the tables/views it needs.
- **Views, not raw tables.** Expose to the AI **views** that contain only what it can see (already filtered/masked where needed), not the full tables with every sensitive field.
- **No unmediated writes.** If the agent has to *do* something (not only read), it goes through controlled tools with idempotency and approval, as for [agents that execute actions on systems]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}) — not with direct write access to the DB.
- **On the `backend` network, but isolated in permissions.** The AI worker lives on the internal network (correct), but that does not mean it can read everything on that network: application permissions (DB users, views) are a second layer beyond the network.

The mistake to avoid is confusing "the AI runs in my house" with "the AI can see everything I have in the house". They are two different things: the first is sovereignty (the data doesn't leave), the second is a hole (the agent has too much access). A well-built sovereign stack has **both** boundaries: the data doesn't leave *and* every service, AI included, sees only its piece.

## The staged migration path

You don't go from Microsoft 365 to the sovereign stack in a weekend — anyone who promises you that is lying. You migrate **in stages**, one piece at a time, with the old and the new coexisting in the transition. The sensible order, from easiest and lowest risk to most delicate:

1. **Mail / PEC.** Often the first stage: a mailbox and the [inbox agent for PEC and invoices]({{ '/en/blog/imap-pec-invoice-agent/' | relative_url }}) deliver value immediately, with contained risk.
2. **Files.** Self-hosted document storage: you move the shared folders onto a service of yours. File migration, permissions, done.
3. **Automation.** n8n starts tying the pieces together, replacing automations scattered across different SaaS tools.
4. **BI.** Dashboards on Metabase sitting on your Postgres: you start seeing your data with your own tools.
5. **CRM / ERP.** The most delicate stage, the one that touches daily operations. You do it last, when the other pieces are solid and you have got comfortable with the stack.

Each stage:

- **Delivers value on its own** (you don't have to wait until the end to see benefits).
- **Coexists with the old** during the transition (no operational vacuum).
- **Reduces lock-in** one piece at a time, instead of a risky big bang.

This gradual approach is what makes the migration **bearable and reversible**: if one stage gives you trouble, you fix it without having torn everything down. It is the same principle as [digitising a professional practice in pieces without stopping it]({{ '/en/blog/complete-professional-practice-software/' | relative_url }}): the big bang is the best way to fail big, stages are the way to win small and then big.

## A concrete example: what replaces what

To make the stack tangible, here is a "SaaS → sovereign" mapping for a typical SME, with what replaces what. It is not the only possible combination, but it gives you the idea of how the pieces cover real needs without per-user fees.

| Need | Typical SaaS | Sovereign alternative (self-hosted) |
|---|---|---|
| **Identity / single login** | Microsoft/Google account | Your own IdP (Authentik/Keycloak) |
| **Mail / PEC** | Exchange / Gmail | IMAP mailbox + [inbox agent]({{ '/en/blog/imap-pec-invoice-agent/' | relative_url }}) |
| **Shared files** | OneDrive / Drive | Self-hosted file storage |
| **Database** | Managed cloud DB | PostgreSQL (with pgvector for AI) |
| **Automation** | Zapier / Power Automate | n8n |
| **BI / dashboards** | Power BI / Looker | Metabase on Postgres |
| **AI assistant** | Copilot (per-user) | Ollama / vLLM locally |
| **Reverse proxy / TLS** | (handled by the SaaS) | Caddy / Traefik |

The point is not that you *must* use exactly these software products: it is that **for every piece of the "hostage package" there is a self-hosted equivalent**, and that sitting on the same Postgres and behind the same proxy they form a coherent ecosystem instead of ten disconnected subscriptions. The BI reads the same data as the ERP; automation ties mail to the management system; the AI answers on the documents that sit in your storage. Coherence, beyond sovereignty, is the advantage: one system, not ten rented silos that someone has to wire together by hand.

## What breaks in production (and how you read it)

- **Postgres doesn't start after an update.** Symptom: services that depend on the DB fail; in the Postgres logs, data version errors. Cause: a major DB upgrade without a migration. Fix: planned major upgrades with dump/restore, not "in place" blindly. That is why the DB lives in a stable compose you touch with care.
- **The reverse proxy doesn't renew certificates.** Symptom: HTTPS expired, services unreachable from the browser. Cause: automatic renewal failed (DNS, CA rate limit). Fix: monitor certificate expiry; the proxy must log renewals.
- **A service fills the disk.** Symptom: everything slows down, writes fail. Cause: logs not rotated, execution data accumulating (n8n!), volumes grown. Fix: log rotation, retention, disk-space monitoring.
- **Wrong network: the service "can't find" the DB.** Symptom: connection errors between containers. Cause: a service is not on the `backend` network, or the service name is wrong. Fix: check network assignment in the compose.
- **Backup that runs but doesn't restore.** Symptom: you only discover it at the restore test (that's why you do it). Cause: partial dump, missing secrets, forgotten volume. Fix: the monthly restore checklist exists specifically to catch this before the disaster.

The thread: **failures of a sovereign stack are infrastructure (disks, networks, certificates, versions), and you read them in the service logs and in monitoring.** They are not mysteries: they are the things a sysadmin knows, and that is why a sovereign stack needs someone who looks after it (see "when not to do it").

## Costs: the rack or the VPS versus the perpetual subscription

Orders of magnitude, declared estimates, over 3 years:

| Item | Sovereign stack | SaaS (M365/Google + CRM + BI + …) |
|---|---|---|
| **Infrastructure** | EU VPS (~€50-200/month) or office rack (~€1,500-4,000 one-off + electricity) | included in the fees |
| **Per-user fees** | zero (self-hosted software is often open) | per-user-per-month, ×N employees, ×36 months |
| **GPU for AI** (if needed) | ~€800 used + electricity | token cost / "copilot" add-on per user |
| **Maintenance** | someone who looks after it (in-house or external) | "included" (but you control nothing) |
| **At the end of 3 years you own** | everything: data, system, freedom | nothing: you keep paying or you stay stuck |

The pure euro sum often already tilts toward sovereign in the medium term, especially as user count grows (per-user fees scale, infrastructure does not). But the line that weighs most is not in the table: it is **what you own at the end** and **how free you are.** SaaS is convenient and it makes sense in many cases; but when the company grows, the fees scale and the lock-in tightens, the sovereign stack becomes not only cheaper but more *yours*. The honest sum puts freedom on the bill, not only the invoice — as throughout the [guide to the sovereign stack]({{ '/en/pillar/sovereign-stack/' | relative_url }}).

## When NOT to do it

Honesty, always. The sovereign stack **is not for you if:**

- **You don't have anyone to look after it.** Condition number one. A self-hosted stack needs maintenance: updates, backups, monitoring, the failures above. Without someone (in-house or an external partner) who takes care of it, a neglected stack becomes a security risk and a disaster waiting. A well-managed SaaS is better than an abandoned self-hosted stack.
- **You are tiny and SaaS is enough.** If you are three people and Microsoft 365 covers everything without friction, building a sovereign stack is over-engineering. Sovereignty matters when data, costs or lock-in become a real problem.
- **You need everything immediately, with no transition.** If you can't afford a staged migration and you want everything operational tomorrow, self-hosting is not the way to start (even if it can be the place to arrive).
- **Lock-in doesn't worry you and the numbers work.** If SaaS is cheap for your size and you have no data-sovereignty needs, staying is fine. Sovereignty is an answer to a problem; if you don't have that problem, you don't need the answer.

Proportion matters: the sovereign stack is for whoever has **data to protect, SaaS costs that scale, or a lock-in that is tightening** — and someone to look after it. Outside that, a well-chosen SaaS is a legitimate choice, and saying so is part of the job.

## Operational checklist before production

- [ ] **Only the reverse proxy** is exposed to the internet; everything else behind it.
- [ ] Docker networks **segmented**: `backend` `internal: true`, DB with no exposed ports.
- [ ] Your own **IdP** for identity; single login managed by you.
- [ ] **Domains and DNS** registered to you.
- [ ] **Backups**: pg_dump + volumes + secrets + configurations, taken **off** the machine.
- [ ] **Monthly restore test** done, with timed RTO.
- [ ] Versions **pinned** (no `latest`); staged updates with rollback possible.
- [ ] **Staging** to try updates; never update on Friday.
- [ ] **Least privilege**: the AI agent sees only dedicated views, not the whole ERP.
- [ ] Blast radius managed: stable foundations separated from what you iterate.
- [ ] **Staged migration** plan defined, with the old coexisting with the new.
- [ ] Someone **looks after** the stack (in-house or partner).

## The verdict: sovereignty is in the architecture or it isn't

Getting out of the Microsoft/Google hostage situation is not downloading a few containers and hoping: it is **architecture**. Sovereign means five concrete things — exportable data, your identity, your DNS, tested backups, possible offboarding — and you build it with segmented Docker networks (only the proxy exposed, the DB on an internal network with no ports), managed blast radius, backups that actually restore (with the monthly test), disciplined updates that avoid dead Monday, least privilege (the AI does not see the whole ERP), and a staged migration that doesn't stop the company. The three-year sum often already tilts toward sovereign in euros; but the line that counts most is freedom — at the finish, either you own your system or you keep paying rent and staying trapped. Sovereignty is in the architecture, or it is a slogan.

This is the overall picture of the [guide to the sovereign stack and in-house AI]({{ '/en/pillar/sovereign-stack/' | relative_url }}), of which the other articles are the bricks. If you want to design the sovereign stack on *your* company — what to migrate, in what order, with which boundaries — start from [who I am and how I work]({{ site.main_site }}/biografia/) or drop me a line in [contacts]({{ site.main_site }}/contatti/).

## FAQ

**1. Isn't "sovereign" just a fashionable word?**
It becomes one if it stays a slogan. It is substance if it translates into architecture: exportable data, your identity and DNS, tested backups, possible offboarding, segmented networks. The test is concrete: if your vendor doubled prices or shut down tomorrow, would you be paralysed or could you move? The answer tells you whether you are actually sovereign.

**2. Do I have to put everything in a single docker-compose?**
Better to split by blast radius: the stable foundations (Postgres, proxy, IdP) in a compose you touch rarely, the services you iterate (n8n, AI, ERP) in separate compose files. That way you update one piece without risking the others. A single compose is simpler but has a wider damage radius.

**3. Why must the database have no exposed ports?**
Because a Postgres with the port open on the internet is one of the most serious and common security mistakes. In the sovereign stack the DB lives on a Docker network with `internal: true`, reachable only from internal services, never from outside. Even if a container were compromised, the DB is not exposed.

**4. Doesn't the system already do backups?**
Doing backups and knowing how to restore them are two different things. An untested backup is a hope. You need to save DB dumps, volumes, secrets and configurations *off* the machine, and run a **monthly restore test** on a test machine, timing it: that is your real recovery time. If you have never tested it, you don't know whether it works.

**5. How do I avoid "dead Monday" after an update?**
With method: pinned versions (never `latest`), updates one piece at a time, try on staging before production, ability to roll back, and the rule of not updating on Friday. Self-hosting is not dangerous in itself: it is without discipline. With these precautions, updates become routine.

**6. Can the AI in the stack see all my data?**
It must not. "The AI runs in-house" (sovereignty) is different from "the AI sees everything" (a hole). Give the AI worker a database user with read-only permissions on only the views it needs, already filtered/masked — not access to the whole ERP. The internal network is one boundary, application permissions are the second.

**7. How much does it cost compared to Microsoft 365?**
Over 3 years, the sovereign stack often costs less, especially as users grow: SaaS fees scale per-user, infrastructure does not. But the line that weighs most is not on the invoice: at the end of 3 years, with the sovereign stack you own the system and you are free; with SaaS you keep paying and stay in the lock-in. The honest sum includes freedom.

**8. Where do I start the migration?**
In stages, from the easiest: first mail/PEC, then files, then automation, then BI, and last the CRM/ERP (the most delicate). Each stage delivers value on its own and coexists with the old during the transition. The big bang is the best way to fail; stages make the migration reversible and bearable.

**9. Do I need an office rack or is a VPS enough?**
It depends. An EU VPS (a few tens to a few hundreds of euros a month) is excellent to start, with no hardware to manage physically. An office rack makes sense for high volumes, data you want physically on-site, or when the amortisation pays off. Many start from a VPS and evaluate the rack later. For AI, the GPU can sit on-premise even if the rest is on a VPS.

**10. And if I have nobody to manage it?**
Then don't do it alone, or don't do it yet: a self-hosted stack without maintenance is a risk, worse than a well-managed SaaS. The options are two: someone inside who looks after it, or an external partner who takes care of it. Sovereignty requires someone who holds the keys and does the servicing — saying that honestly is part of the job.
