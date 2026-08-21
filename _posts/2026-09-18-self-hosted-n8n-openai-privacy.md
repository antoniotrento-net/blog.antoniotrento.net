---
lang: en
permalink: /en/blog/self-hosted-n8n-openai-privacy/
alt_url: /it/blog/n8n-self-hosted-openai-privacy/
title: "Why your n8n workflow with GPT-4o is sending client data to OpenAI (and how to close it in Docker in 90 minutes)"
date: 2026-09-18 07:30:00 +0200
author: "Antonio Trento"
description: "You self-host n8n on your VPS and think you're GDPR-ok. But the OpenAI node sends body, attachments and PII in the clear outside the EU. Here's what actually leaves, and how to close the fence in Docker."
keywords: ["self-hosted n8n openai privacy", "n8n docker", "gdpr llm", "client data openai", "n8n production workflow"]
image: /assets/images/posts/n8n-self-hosted-openai-privacy.jpg
pillar: stack-sovrano
related: [/en/blog/failed-ai-proof-of-concept/, /en/blog/llm-product-vs-chatbot/]
---

## The misunderstanding that costs you a report to the Garante

You installed n8n on your VPS, maybe in Docker, maybe behind a nice domain with HTTPS. You told yourself: "the data is at home, I'm complying with GDPR". It's the most widespread — and most dangerous — misunderstanding among people who build AI automations in Italy, and it's why **self-hosted n8n with an OpenAI node doesn't protect you from anything**. Because the workflow runs on your server, yes — but the exact moment the OpenAI node (or Anthropic, or any cloud LLM) fires, the content you pass it — the text of the client's email, the attachment, the name, the IBAN, the codice fiscale — **leaves your fence and travels to the United States.** Self-hosting the orchestrator and then sending data in the clear to a cloud model is like putting in a steel door and leaving the window wide open.

This article takes the myth apart and shows the real fence. I'm talking to people who ship stuff in production — founders, CTOs, IT leads at Italian SMEs — not people who make slides. We'll go through, with technical precision: what actually leaves a cloud LLM node, which n8n nodes exfiltrate data without you noticing, how you do *redaction* before the model, and how you close everything in a sovereign Docker architecture — n8n + Ollama + Postgres on the same network — in about 90 minutes. With the `docker-compose`, a sample PII filter, and the checklist you can put on a DPO's table. Because "it's on my VPS" is not an answer: it's the start of the problem.

## "It's on my VPS, so it's GDPR-ok": why that's false

Let's break the illusion immediately, because it's the root of everything. The wrong reasoning is: *the software runs on a server I control, therefore the data is under my control.* True for n8n itself. False for what n8n **sends out**.

An n8n workflow is an orchestrator: it takes data from somewhere, runs it through nodes, and sends it somewhere else. If one of those nodes is "OpenAI" or "Anthropic" or "HTTP Request to api.openai.com", then that node **makes a network call to an American server**, and in the body of that call are your data. The fact that n8n runs on your VPS is irrelevant to that call: it's like saying a letter is private because you wrote it at home, while you're dropping it in a mailbox headed for another continent.

From a GDPR point of view, when you send personal data to a cloud LLM you are doing a **transfer of data to a processor** (the model vendor), often **outside the EU**. That requires a legal basis, a data processing agreement (DPA), safeguards for the extra-EU transfer, and — above all — that you *know and can demonstrate* what leaves. "Self-hosted n8n" gives you none of those things for the LLM part. It only gives you control of the orchestrator, which is the half that *isn't* the problem.

The practical point is this: **the boundary of your data is not where n8n runs, it's where the model runs.** If the model is cloud, the boundary is at their house. If you want the boundary at your house, the model has to run at your house — and that's the whole point of a sovereign stack, of which this article is the first brick. It's the same clarity you need so you don't get dazzled when [an AI PoC promises everything and ends up in a drawer]({{ '/en/blog/failed-ai-proof-of-concept/' | relative_url }}): what counts is the real architecture, not the "self-hosted" label stuck on top.

## What actually leaves an OpenAI/Anthropic node

Let's get concrete. When a cloud LLM node fires, what actually leaves your server? More than you think.

- **The full prompt body.** All the text you compose — instructions + data. If you stuffed into the prompt "summarise this client email: [text with name, company, amount, IBAN]", all of that text leaves. The model doesn't "only see the part it needs": it receives the entire payload.
- **Attachments and files.** If you use vision or document-analysis features, the PDF, the image, the file travel whole. An invoice, a contract, an ID card a client uploaded: all of it leaves.
- **Headers and metadata.** The call carries headers, sometimes identifiers, and gets logged on the vendor side with timestamps and references.
- **Retries.** Here's the detail almost nobody considers: if the call fails and n8n retries, the data leaves **more than once**. A transient error means the same sensitive payload sent two, three times.
- **Vendor logs.** The vendor, by policy, may retain inputs for a period (abuse/monitoring), unless you have a specific agreement that excludes it. So your data doesn't just transit: it can **stay** logged elsewhere for a time you don't control.

The question to ask, in front of every workflow, is brutal: *if the content of this call ended up in a vendor data breach, or on an inspection table, what would be inside?* If the answer includes personal data of your clients, you have a problem — regardless of where n8n runs. The value of an AI output, after all, sits in the **controlled process** that produces it, not in the model itself: that's the thesis I develop in [why you don't need "a model" but a reliable process]({{ '/en/blog/llm-product-vs-chatbot/' | relative_url }}). And a controlled process starts with knowing what leaves.

## The map of n8n nodes that exfiltrate without you noticing

The OpenAI node is the obvious one. But in an n8n workflow there are other, less visible leak points, and that's where you get hurt because you don't look at them. Here's the map of suspects:

- **Direct LLM nodes**: OpenAI, Anthropic, Google Gemini, Mistral (cloud endpoint), Cohere. Obvious: they send the prompt to the vendor.
- **The "AI Agent" node / LangChain chains** inside n8n: if the configured model is cloud, every reasoning step of the agent is a call that leaves — and an agent makes *many* calls, multiplying the exfiltration.
- **Cloud embedding nodes**: to do RAG you often generate embeddings. If you use OpenAI embeddings, **every chunk of every document** you index gets sent to the vendor. Indexing 10,000 invoices? That's 10,000 pieces of document going out.
- **The HTTP Request node**: the wildcard. It calls any external API. Easy to forget that that "harmless" call to a data-enrichment, translation, or cloud OCR service is sending the payload out.
- **Third-party nodes** (translation, transcription, OCR, "enrichment"): each one is an external endpoint that receives your data.
- **n8n's own telemetry**: n8n by default can send diagnostic and usage data. It isn't the clients' body, but it's still outbound traffic to turn off in a sovereign context (the variables to do that are in the compose further down).

The method to find them is simple and has to be done **once for every workflow in production**: open the workflow, list every node that makes a network call to a host you don't control, and for each one ask yourself *what I pass it in the body*. If the answer contains personal or confidential data, that node is a leak to close — either with redaction (next section) or by replacing it with a local equivalent (the section after).

## Redaction before the model: PII, IBAN, CF, PEC, attachments

The first line of defence, and the one you can put in place immediately even if for now you stay on a cloud LLM for certain tasks, is **redaction**: remove or mask sensitive data *before* the text reaches the model. The idea is that the model works on a "cleaned" text where name, IBAN, codice fiscale, email, PEC and phone numbers are replaced by placeholders, and — if needed — you put the real values back into the output afterwards, locally.

Here's a sample PII filter in Python, meant to run as a small sidecar (a microservice that n8n calls on the internal Docker network) or as a reference for a Function node. It covers the most common Italian cases:

```python
import re

# Redaction minima per payload in italiano PRIMA di un LLM.
# NON e' esaustiva: e' una base di partenza da estendere sul tuo dominio.
PATTERNS = {
    "IBAN":  re.compile(r"\bIT\d{2}[A-Z]\d{10}[0-9A-Z]{12}\b"),
    "CF":    re.compile(r"\b[A-Z]{6}\d{2}[A-EHLMPRST]\d{2}[A-Z]\d{3}[A-Z]\b"),
    "PIVA":  re.compile(r"\b\d{11}\b"),
    "EMAIL": re.compile(r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b"),
    "TEL":   re.compile(r"\b(?:\+39\s?)?3\d{2}[\s.\-]?\d{6,7}\b"),
}

def redigi(testo: str) -> tuple[str, dict]:
    mappa = {}
    for tag, pat in PATTERNS.items():
        for i, m in enumerate(pat.findall(testo)):
            token = f"[{tag}_{i}]"
            mappa[token] = m
            testo = testo.replace(m, token, 1)
    return testo, mappa   # 'mappa' resta in locale per il re-inserimento

def reinserisci(output: str, mappa: dict) -> str:
    for token, valore in mappa.items():
        output = output.replace(token, valore)
    return output
```

The logic: `redigi()` replaces sensitive data with tokens and keeps the mapping in a `mappa` that **never leaves your server**; you send the model only the text with tokens; when the reply comes back, `reinserisci()` puts the real values back in locally. The cloud model never saw a real IBAN or codice fiscale.

Two honest caveats, because redaction is not a magic wand:

- **It is never complete.** A proper name ("Mario Rossi") is much harder to catch than an IBAN with a fixed pattern; you need lists, NER (named-entity recognition), and something still slips through. Redaction reduces the risk, it doesn't zero it.
- **Attachments are the big hole.** Redacting text is doable; redacting a PDF or an image before sending them to a vision model is much more complex. For attachments with personal data, the serious answer is not "I redact the PDF": it's "the model that reads them runs locally".

And that's exactly why redaction is a useful but partial plaster. The structural solution is another: **bring the model inside the fence.**

## The closed architecture: n8n + Ollama + Postgres on the same Docker network

Here's the real fence. Instead of sending data to a cloud model, you run the model **locally**, on the same Docker network as n8n, so the payload never leaves your server. The components:

- **n8n** — the workflow orchestrator.
- **Ollama** — the runtime that serves language models locally (Llama, Mistral, Qwen and similar), with a compatible API that n8n can call over HTTP. For serious or multi-user loads you move to **vLLM**, but to start Ollama is the fastest to stand up.
- **Postgres** — n8n's database (and, when you add RAG, the store with `pgvector` for embeddings).

The key is the **internal Docker network**: n8n talks to Ollama and Postgres via internal service names (`http://ollama:11434`), on a network that is not exposed to the internet. Data traffic stays *inside* the machine. Here's a starting `docker-compose.yml`:

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: n8n
    volumes:
      - pgdata:/var/lib/postgresql/data
    networks: [sovrano]
    restart: unless-stopped

  ollama:
    image: ollama/ollama:latest
    volumes:
      - ollama:/root/.ollama
    networks: [sovrano]
    # GPU (opzionale, consigliata per latenza decente):
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities: [gpu]
    restart: unless-stopped

  n8n:
    image: n8nio/n8n:latest
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD}
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}
      # Spegni telemetria e chiamate in uscita non necessarie:
      N8N_DIAGNOSTICS_ENABLED: "false"
      N8N_VERSION_NOTIFICATIONS_ENABLED: "false"
      N8N_TEMPLATES_ENABLED: "false"
      # Ollama raggiungibile a http://ollama:11434
    ports:
      - "127.0.0.1:5678:5678"   # SOLO loopback: si arriva via reverse proxy
    depends_on: [postgres, ollama]
    networks: [sovrano]
    restart: unless-stopped

volumes:
  pgdata:
  ollama:

networks:
  sovrano:
    driver: bridge
```

Two details that make the difference between "looks closed" and "is closed":

- **n8n's port is bound to `127.0.0.1`**, not exposed on all interfaces. You reach it only through a reverse proxy (Caddy/Nginx) with HTTPS and authentication in front — not directly from the internet.
- **n8n telemetry is off** (`N8N_DIAGNOSTICS_ENABLED: "false"`). Small thing, but in a sovereign context every outbound call has to be justified or closed.

In the workflow, instead of the OpenAI node, you use an HTTP Request node (or the Ollama node, if you prefer) to `http://ollama:11434/api/generate`. The payload goes from n8n to Ollama on the `sovrano` network and **doesn't touch the internet**. The model reads the name, the IBAN, the attachment — but they're at your house, under your control, with no retries that leave and no third-party logs.

## When a cloud LLM is acceptable (because sometimes it is)

I'd be dishonest if I said "cloud LLM never". It isn't true, and fanaticism helps nobody. The cloud model is more capable, faster to integrate, and for certain tasks local doesn't match the quality. The point isn't to ban it: it's to **use it with a head**, knowing when it's acceptable.

A cloud LLM is acceptable when at least one of these conditions holds:

| Condition | Why it makes the cloud acceptable |
|---|---|
| **Non-personal data** | If the payload contains neither personal nor confidential data (e.g. public text, synthetic content), the GDPR problem doesn't arise. |
| **Synthetic or anonymised data** | If you work on fake data or irreversibly anonymised data, you aren't processing personal data. |
| **DPA + EU region + no-training** | If you have a contract (DPA) with the vendor, the data stays in an EU region, and training on your inputs is excluded, the risk is governed (not zero, but governed and documentable). |
| **Robust redaction upstream** | If what leaves is already cleaned of sensitive data (with the limits above), exposure is reduced. |

The practical rule I use: **local by default, cloud for a motivated exception.** Not "cloud by default and local if someone complains", but the opposite. Every time a workflow uses a cloud LLM, there must be a line explaining *why* it's acceptable for *those* data — one of the conditions above. If you can't write it, the task goes on the local model. That inversion of the default is the whole difference between a sovereign stack and a stack that sends data out "because it was more convenient".

## The 90-minute playbook

Here's the path from "n8n that exfiltrates" to "closed fence", in about 90 minutes on a machine already ready with Docker.

1. **Prepare the environment (10 min).** Create a project folder, the `docker-compose.yml` above and a `.env` with `POSTGRES_PASSWORD` and `N8N_ENCRYPTION_KEY` (generate strong keys, not "password123").
2. **Start the stack (10 min).** `docker compose up -d`. Check that the three services are up and healthy (`docker compose ps`, check logs with `docker compose logs -f`).
3. **Pull a local model (15 min).** `docker compose exec ollama ollama pull llama3.1:8b` (or a model that fits your VRAM). Test that it replies: a `curl` to `http://localhost:11434/api/generate` from inside.
4. **Put n8n behind a reverse proxy (15 min).** Caddy or Nginx with HTTPS and authentication in front of port `127.0.0.1:5678`. No direct access from the internet.
5. **Rewrite the critical workflow (20 min).** Replace the OpenAI node with an HTTP call to `http://ollama:11434`. If a task has to stay on cloud, add the redaction node first (the Python sidecar or a Function node).
6. **Test with a fake payload (15 min).** Essential: run the workflow with a payload that contains **fake but realistic** data (a fake IBAN, a fake CF, a fake email) and verify — with logs and with a sniff of outbound traffic — that *none* of that data leaves the machine for the tasks that must stay local.
7. **Document the boundaries (5 min).** Write what runs where and what (if anything) still leaves and why. You need it for the DPO (next section) and for yourself in six months.

Ninety minutes are for the *first close* of one workflow on a ready machine. It isn't "the whole company sovereign stack in an hour and a half": it's the first fence, the one that stops the worst haemorrhage. The rest — GPU, vLLM for multi-user, local RAG — you build afterwards, on top of these foundations.

## How to prove it to a DPO: the boundary checklist

A fence you can't demonstrate, for compliance purposes, is like not having one. The DPO (or the privacy consultant) doesn't look at your `docker-compose`: they look at whether you can answer precise questions about *where the data goes*. Here's the checklist to prepare — it's also an excellent way to notice the holes you still have.

- **Boundary diagram.** A simple drawing: which components run where, which traffic stays internal (`sovrano` network) and which — if any — leaves, toward whom and with what data.
- **Inventory of nodes that leave.** For every workflow in production, the list of nodes that make external calls, with: destination host, type of data in the body, legal basis/reason.
- **Updated record of processing.** If a cloud LLM is still in use for some task, it must appear as a processor, with DPA, region, and the training clause.
- **Proof of redaction (where applied).** Before/after payload examples, for residual cloud tasks.
- **Test logs with a fake payload.** The demonstration that, for local tasks, the fake data did not leave.
- **Retention policy.** Where data stays in n8n/Postgres, for how long, and how it gets deleted.
- **Secrets management.** Where keys/credentials live (not in the clear in the workflow), who can access them.

If you can tick this list, you aren't "hoping" you're fine: you have the evidence. And that's the difference between a sentence ("we use self-hosted n8n") and a defensible posture in front of an inspection. Anyone selling you AI automations without ever naming this checklist is preparing exactly the problem this article starts from.

## What breaks in production (and how you spot it in the logs)

The closed fence works, but in production there are typical failures it's better to know before you meet them at two in the morning. Here are the most common and how you recognise them from the logs.

- **Ollama goes OOM (out of memory) on the GPU.** Symptom: the call to the model fails or hangs, and in Ollama's logs you see CUDA memory-allocation errors. Cause: you loaded a model too big for the VRAM, or too many models at once, or a huge context (token count). Fix: smaller/quantised model, one hot model at a time, shorter context. It's failure number one for anyone starting with an undersized GPU.
- **Latency that explodes under load.** Symptom: workflows slow down, n8n piles up queued executions, response times climb. Cause: Ollama serves one request at a time well, but under concurrency it clogs. That's the signal it's time to move to **vLLM** (built for throughput and batching) or add GPU. You see it from rising execution times in n8n's history.
- **n8n goes into a retry-storm on a failing node.** Dangerously bad symptom from a privacy angle: a cloud node fails and n8n retries, sending the **same sensitive payload out more than once**. In the logs you see repeated executions close together on the same item. Fix: limit retries on nodes that leave, and — better — move them local so the retry doesn't exfiltrate.
- **Postgres fills up with execution data.** Symptom: disk space drops, n8n slows down, logs flag slow writes. Cause: n8n saves data for every execution, and on high-volume workflows with fat payloads the database grows fast — and remember those saved data include client payloads. Fix: configure execution retention (pruning) and don't save execution data where you don't need it; it's also a GDPR minimisation issue, not just a disk one.
- **The local model "hallucinates" more than the cloud on a task.** Symptom: worse-quality output on complex jobs. It isn't a bug, it's the limit of the model that fits in your VRAM. Honest fix: for that specific task, either redaction + cloud, or you accept the limit, or you wait for better hardware — you don't pretend local does everything.

The principle: **monitor Ollama's logs (memory, latency) and n8n's history (retries, times, queue).** Most failures of a sovereign stack aren't mysterious — they're VRAM, concurrency or retries — and they read in the logs if you know what to look for.

## The real costs (in euros, VRAM, kWh)

Let's talk numbers, because "sovereign" must not mean "blind on costs". Orders of magnitude, declared as estimates, to adapt to your case.

| Item | Order of magnitude | Notes |
|---|---|---|
| **VPS/server for the stack (CPU)** | ~20-60 €/month | Holds n8n + Postgres and a small LLM on CPU, with high latency. OK for low volumes. |
| **Server with GPU (in EU cloud)** | ~150-600 €/month | A GPU with enough VRAM for a quantised 7-8B model (~8-16 GB) or 14B+ (~24 GB). Acceptable latency. |
| **On-premise GPU (one-off)** | ~500-2.000 € | A card with 16-24 GB VRAM to run 8-14B models locally. Amortised over months, often cheaper than cloud GPU at steady state. |
| **Electricity (on-prem)** | a few tens of €/month | A GPU under load burns hundreds of watts; at intermittent use the kWh stay contained. |
| **Cloud LLM (for comparison)** | per token | Convenient and no CapEx, but you pay for use *and* you send data out: the real cost includes the risk, not just the tokens. |

The honest economic reasoning: for **low volumes and non-critical tasks**, a cloud LLM with the right safeguards can cost less in money. For **high volumes, sensitive data, or continuous use**, the local stack with GPU pays for itself — both in euros (no per-token cost that scales) and in risk (the data doesn't leave). VRAM is the constraint that decides which models you can run: a quantised 8B fits in ~8 GB, a 14B in ~16-24 GB, beyond that you need serious cards or vLLM on multiple GPUs. Size the model to the VRAM you have, not to the model you wish you had.

## When NOT to do it (or not yet)

The sovereign stack is not the answer to every situation, and forcing it where it isn't needed wastes money and time. **Don't do it, or postpone it, if:**

- **You don't process personal or confidential data.** If your workflows work on public or non-sensitive content, the local fence is a complication with no benefit. A cloud LLM with the basic safeguards is enough.
- **Volumes are minimal.** If you make a few calls a day on not-very-delicate data, the overhead of managing GPU, local models and updates may not be worth the risk saving. Better redaction + cloud with a DPA.
- **You don't have anyone to maintain it.** A self-hosted stack has to be updated, monitored, kept healthy. If you don't have (and don't want) someone who owns it, a neglected self-hosted setup becomes a worse security risk than the cloud. Better a well-governed cloud than an abandoned local.
- **Local model quality doesn't hold the task.** For certain complex jobs, the local models that fit in your VRAM aren't up to it. In that case: either robust redaction + cloud, or you wait for better hardware/models — you don't sacrifice the result on principle.

The rule, once again: **local by default for sensitive data, but honest about when the game isn't worth the candle.** A sovereign stack done as dogma, with nobody maintaining it and no real data problem to protect, is theatre just like the "self-hosted = GDPR-ok" we started from.

## Operational checklist before going to production

Before you consider a workflow "closed", tick this list:

- [ ] I listed **every node** that makes external calls and I know what I pass it in the body.
- [ ] Tasks on **sensitive data** run on a **local** model (Ollama/vLLM on the internal network).
- [ ] Residual cloud tasks have a **written justification** (synthetic data / DPA+EU / redaction).
- [ ] **Redaction** is on where needed and I tested it with a fake payload.
- [ ] **n8n telemetry is off**; no unjustified outbound call.
- [ ] n8n is **behind a reverse proxy** with HTTPS and auth; port not exposed directly.
- [ ] **Secrets** are not in the clear in the workflow; strong keys in `.env`.
- [ ] I have the **boundary diagram** and the **DPO checklist** ready.
- [ ] I have a **retention and deletion** policy for data in n8n/Postgres.
- [ ] I know **how I update** the stack and who maintains it.

## The verdict: the boundary is where the model runs

If you take home a single sentence, let it be this: **self-hosting n8n protects nothing if the LLM is cloud.** The boundary of your data is not where the orchestrator runs, it's where the model runs. As long as the OpenAI node fires, your clients' data — body, attachments, PII, retries included — leaves the fence, and "it's on my VPS" is not a defence that holds in front of a DPO or an inspection. The good news is that closing the fence isn't a months-long project: it's a `docker-compose` with n8n + Ollama + Postgres on the same network, redaction where needed, and the discipline of "local by default, cloud for a motivated exception". Ninety minutes for the first close, and from there you build the real sovereign stack.

This is the first brick of a broader theme — local models, RAG on your documents, agents that act without sending data out — which you'll find in the [guide to the sovereign stack and AI at home]({{ '/en/pillar/sovereign-stack/' | relative_url }}). If you want to see what a fence looks like on *your* stack, *your* workflows and *your* data, the starting point is [who I am and how I work]({{ site.main_site }}/biografia/) or two lines in [contacts]({{ site.main_site }}/contatti/).

## FAQ

**1. But if I use self-hosted n8n, isn't the data already safe?**
No. Self-hosted n8n secures the orchestrator, not what it sends out. The moment a cloud LLM node (OpenAI, Anthropic…) fires, the payload — text, attachments, PII — travels to the vendor's servers. The data boundary is where the model runs, not where n8n runs.

**2. What exactly leaves an OpenAI node?**
The full prompt body (instructions + data), any attachments/files, the headers, and — a detail often ignored — the data gets resent on every retry. On the vendor side inputs may stay logged for a period, unless you have a specific agreement.

**3. Is redaction enough to put me right with GDPR?**
It helps but it isn't enough on its own. It reduces exposure by masking IBAN, CF, email, phones before the model, but proper names slip through easily and attachments (PDFs, images) are hard to clean. For sensitive data, the structural solution is the local model, not redaction alone.

**4. Ollama or vLLM?**
Ollama is the fastest to start and for low volumes/single user. vLLM holds multi-user and serious loads better (throughput, batching), at the cost of a heavier setup. Start with Ollama, move to vLLM when volumes require it.

**5. How much VRAM do I need?**
Depends on the model: a quantised 8B fits in ~8 GB, a 14B in ~16-24 GB, larger models need serious cards or more GPUs with vLLM. Size the model to available VRAM, not the other way around: better a model that runs well than a big one that swaps.

**6. Is the local model up to GPT-4o?**
For many business tasks (extraction, classification, summary, answers on your documents) local 8-14B models do an excellent job. For complex reasoning the gap with top-tier cloud can matter. The honest choice: local where it holds (most SME tasks), cloud with safeguards where you really need more capability.

**7. Can I keep some workflows on cloud?**
Yes, with criteria: non-personal data, synthetic/anonymised data, or DPA + EU region + training excluded + redaction upstream. The rule is "local by default, cloud for a motivated exception": every cloud use must have a written reason for *those* data.

**8. How do I prove it to a DPO or in an inspection?**
With a boundary diagram, the inventory of nodes that leave (host, data, reason), the updated record of processing, redaction examples, test logs with a fake payload, and retention and secrets-management policies. A fence you can't demonstrate, for compliance purposes, is like not having one.

**9. What does a local stack actually cost?**
Orders of magnitude: a CPU VPS for low volumes ~20-60 €/month; a GPU server in EU cloud ~150-600 €/month; an on-premise GPU ~500-2.000 € one-off plus a few tens of € of electricity a month. For high volumes and sensitive data it pays for itself in euros and in risk; for minimal volumes cloud with safeguards can cost less in money.

**10. Where do I start if I already have ten workflows in production?**
From an audit: for every workflow, list the nodes that leave and what you pass them. Then close first the one that sends out the most sensitive data, with the 90-minute playbook. You don't need to redo everything at once: you secure one workflow at a time, from the riskiest.
