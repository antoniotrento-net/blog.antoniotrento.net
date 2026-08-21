---
lang: en
permalink: /en/blog/imap-pec-invoice-agent/
alt_url: /it/blog/agente-imap-pec-fatture/
title: "How to build an IMAP agent that classifies PEC and invoices (without the Gmail API and without giving the password to a SaaS)"
date: 2026-09-23 07:30:00 +0200
author: "Antonio Trento"
description: "An inbox agent that sorts PEC, invoices and legal mail without sending your post to a US SaaS. Self-hosted IMAP IDLE architecture, local classification, FatturaPA XML attachments."
keywords: ["imap pec invoice agent", "imap idle python", "aruba pec", "ai email classification", "self-hosted inbox agent"]
image: /assets/images/posts/agente-imap-pec-fatture.jpg
pillar: integrazioni-dati
related: [/en/blog/pgvector-rag-electronic-invoices/, /en/blog/self-hosted-n8n-openai-privacy/]
---

## Mail is the company's nervous system, and you're giving it away to a SaaS

In the inbox of an Italian SME, everything passes through: supplier invoices, PEC with legal value, communications from public bodies, customer orders, formal notices, bank statements. It is the company's nervous system. And the solution everyone proposes to "put AI on top of it" is to connect a SaaS — an assistant, a Copilot, a tool that hooks in via the Gmail API — that reads *all* of that mail and sends it to its servers to classify it. In other words: you gift a third-party vendor, often American, full access to the most sensitive flow you have. For many Italian SMEs this is simply a **non-starter**, and not out of paranoia: because of PEC, fiscal data and GDPR obligations.

There is another way, and that is the subject of this article: build an **IMAP agent** that sorts PEC and invoices **in your house**, without the Gmail API and without giving the mailbox password to any SaaS. An inbox agent that connects to the mailbox with the standard IMAP protocol, receives mail in real time with IDLE, classifies it (with a model that runs locally on only the text it needs), extracts attachments — including FatturaPA XML invoices — and puts them in the right folders, leaving the human only the uncertain cases. In this piece we look at the complete architecture: IMAP versus proprietary APIs, IDLE versus polling, the folder taxonomy, how and where to classify, handling of attachments and viruses, idempotency so you don't reclassify the same mails forever, and the operational runbook (dedicated passwords, fail2ban, backup of the rules). With the Python snippet for IMAP IDLE, the folder schema, and the list of PEC provider errors. Because mail is too important to hand over to someone else.

## Why Gmail API and Copilot on mail are a non-starter for many SMEs

Let's be clear why the "easy" road doesn't work, so you understand what we are avoiding.

- **They give a third party total access.** An assistant that connects via Gmail API or Microsoft Graph, or a Copilot on mail, to work must be able to **read the entire mailbox**. You are handing it the keys to your nervous system. And that third party processes the contents on its servers — client names, amounts, legal PEC, everything.
- **PEC does not live there.** Certified electronic mail is an Italian world: mailboxes on Aruba, Legalmail, and other operators, that speak standard IMAP/SMTP, not Google's or Microsoft's APIs. A "Gmail AI assistant" has nothing to do with PEC — and PEC is exactly the mail with legal value that you have to watch most closely.
- **The GDPR problem is the same as always.** Sending the contents of company mail to a SaaS is a processing of personal data (often extra-EU) entrusted to an external processor, with everything that entails — exactly the theme of [ChatGPT in the CRM that becomes a data leak]({{ '/en/blog/gdpr-chatgpt-crm/' | relative_url }}). On mail, which contains *everything*, the risk is maximum.
- **The lock-in.** Building your sorting inside a vendor's ecosystem ties you to them: you change provider and you redo everything.

The non-starter is not "AI on mail". It is **AI on mail run by a third party that takes it home**. The alternative is not giving up automation: it is doing it in-house, on the open protocol that mail already speaks. Which is IMAP.

## IMAP versus Graph and Gmail: what you keep in-house

The choice of "how you connect to mail" decides who controls the data. Three paths:

- **Gmail API / Microsoft Graph**: proprietary APIs of the two giants. Powerful, but they tie you to their ecosystem, require their authorization flows, and assume that the mail lives there. For Italian PEC they are not even an option.
- **IMAP**: the **standard protocol** of mail, which *any* mailbox speaks — Aruba, Legalmail, your own server, Google and Microsoft themselves. You connect directly to the mailbox, download the mails, move them between folders. No intermediary, no ecosystem: **the data only passes between your mailbox and your agent.** It is the sovereign choice.

With IMAP, the architecture is clean: your agent (running on a server of yours, in Docker) connects to the mailbox via IMAP over TLS, reads the new mails, classifies them *locally*, and moves them into folders. The mail provider sees only an IMAP client connecting — as Outlook or Thunderbird would. No content goes to a classification SaaS, because the classification SaaS does not exist: it is your agent, in your house. It is the same principle as the [closed fence of a sovereign stack]({{ '/en/pillar/sovereign-stack/' | relative_url }}): the data boundary is where the logic runs, and here the logic runs with you.

A practical detail: many mailboxes (PEC included) require, for programmatic IMAP access, a **dedicated password** or explicit enabling of IMAP. Do not use the owner's personal password: you create a credential purpose-built for the agent (we cover that in the runbook).

## IDLE versus polling: CPU, provider bans, backoff

How does the agent notice that a new mail has arrived? Two ways, and the choice has concrete consequences on load and stability.

- **Polling**: the agent checks the mailbox every so many seconds/minutes ("any new mail? no. And now? no. And now?"). Simple, but it wastes resources and — above all — **irritates the provider**: querying the mailbox too often can trigger rate limits or temporary bans, because it looks like abusive behaviour. And if you stretch the interval to avoid the ban, mail gets sorted late.
- **IMAP IDLE**: the right way. The agent opens a connection and tells the server "you notify me when something arrives" (IDLE). Then it **waits**, without querying continuously: the server sends a *push* notification when there is new mail. Low CPU load, no hammering the provider, and real-time sorting.

Here is the skeleton of an IMAP IDLE loop in Python (with the IMAPClient library, which makes IDLE clean):

```python
from imapclient import IMAPClient
import time, logging

HOST = "imaps.pec.aruba.it"          # esempio: host IMAP del provider PEC
USER = "azienda@pec.esempio.it"
APP_PASSWORD = "PASSWORD_DEDICATA"   # NON la password personale

def loop_idle():
    while True:
        try:
            with IMAPClient(HOST, ssl=True) as server:
                server.login(USER, APP_PASSWORD)
                server.select_folder("INBOX")
                processa_nuovi(server)          # smaltisci l'arretrato
                while True:
                    server.idle()
                    # i server chiudono l'IDLE ~ ogni 29 min: rinnova prima
                    responses = server.idle_check(timeout=5 * 60)
                    server.idle_done()
                    if responses:
                        processa_nuovi(server)
        except Exception as e:
            logging.warning("Connessione persa: %s — backoff", e)
            time.sleep(30)                       # BACKOFF prima di riconnettere

def processa_nuovi(server):
    for uid in server.search(["UNSEEN"]):
        raw = server.fetch([uid], ["RFC822"])[uid][b"RFC822"]
        smista(server, uid, raw)                 # classifica e sposta
```

Two details that separate the toy from production:

- **Renewing IDLE.** Servers close the IDLE session after about 29 minutes. You go into `idle_check` with a shorter timeout (5 minutes in the example), then you renew. If you don't, the connection dies silently and you stop receiving notifications without noticing.
- **Backoff on reconnect.** The network drops, the provider kicks you out: the agent must **wait** before reconnecting (backoff), not retry forever in a burst — which is exactly the behaviour that triggers the ban. A growing `sleep` on repeated errors is the defence.

## The folder taxonomy: where every mail ends up

The agent does not "reply" to mails: it **sorts** them. And sorting only makes sense if the destination folders are well thought out. A taxonomy that works in an Italian SME:

```text
INBOX
├── 00-da-leggere      → arrivate, non ancora classificate (default)
├── 10-fatture         → contengono fattura (XML FatturaPA o PDF)
├── 20-pec-legale      → PEC con valore legale: notifiche, diffide, enti
├── 30-ordini-clienti  → richieste e ordini da clienti
├── 40-spam            → posta indesiderata
├── 50-da-umano        → INCERTO: l'agente non è sicuro → revisione
└── 99-archiviato      → processato e chiuso
```

The two folders that make the difference, and that the generic "AI email assistant" does not give you:

- **`20-pec-legale`**: PEC are not mail like the others. They have legal value, often deadlines (a formal notice, a notification, a communication from a public body), and they need to be seen by a human *soon*. Separating them from the noise is half the value of the agent: you no longer lose an important PEC in the middle of two hundred mails.
- **`50-da-umano`**: the most important folder, and the one naive systems don't have. **When the agent is not sure, it does not guess: it sets it aside for human review.** An ambiguous mail, a strange case, a low-confidence classification go here, not forced into a random folder. It is the safety net that makes automation reliable: better ten mails "to look at" than an invoice ending up in spam or a formal notice lost.

The principle: **the agent automates the clear and escalates the uncertain to a human.** Obvious mails (a recognisable FatturaPA, blatant spam) it sorts on its own; on everything else, in doubt, it asks for help. It is the same boundary — machine on the banal, human on the important — that holds up [agents that execute actions on production systems]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}).

## Where to classify: a local model on the body only, already cleaned

How does the agent decide which folder a mail goes into? With a combination of **structural signals** and **linguistic classification**, in this order (from most reliable to most expensive):

1. **Deterministic rules first of all.** A lot is decided without AI: if there is a FatturaPA XML attachment, it is an invoice (folder `10-fatture`), period. If the sender is a certified PEC domain and the subject contains certain words, it is probably legal PEC. Clear, verifiable rules go before the model: they are free, fast and they don't hallucinate.
2. **The language model for the ambiguous.** When the rules are not enough (a text mail that could be an order or a generic request), linguistic classification with an LLM steps in — running **locally** (Ollama or vLLM, as in the [sovereign stack of models]({{ '/en/pillar/models-cost-privacy/' | relative_url }})).

And here the crucial GDPR point: **you pass the model the indispensable minimum, already cleaned.** Not the entire mail with names, IBANs and attachments: only the *body* text needed to classify, with sensitive data masked (the same redaction seen for [other nodes that go outside]({{ '/en/blog/self-hosted-n8n-openai-privacy/' | relative_url }})). And because the model runs locally, even the cleaned body still does not leave your server. Double defence: you minimise *and* you keep it in-house.

The model answers with a **classification and a confidence**. If confidence is high, the agent sorts. If it is low, it goes to `50-da-umano`. That confidence number is what makes the automation honest: the agent knows when it doesn't know, and it says so, instead of forcing every mail into a box with unjustified certainty.

## Attachments: FatturaPA XML, PDF, zip, viruses

Attachments are where mail becomes dangerous and valuable at the same time. The agent has to handle them with care, because that is where invoices arrive (value) and malware (risk).

- **Antivirus scan, always and first.** Before opening *any* attachment, pass it to a local antivirus (ClamAV, in a container). Mail is malware vector number one: an agent that opens attachments without scanning them is an open door. If the attachment is infected, quarantine and alert — never processed.
- **FatturaPA XML.** The attachment you care about most. Watch the formats: the invoice can be a plain `.xml`, an `.xml.p7m` (digitally signed, CAdES format — you have to "unwrap" it first to extract the XML), or inside a `.zip`. A serious agent recognises all three. Once the XML is extracted, you have the structured data (number, supplier, amount) — which can then feed [RAG on invoices with pgvector]({{ '/en/blog/pgvector-rag-electronic-invoices/' | relative_url }}): the inbox agent is the intake, the RAG is the query.
- **PDF.** Invoices in PDF (foreign suppliers, old ones), documents, communications. They have to be handled knowing that the text must be extracted (or OCR if scanned), with less reliability than XML.
- **ZIP and archives.** Open with caution (also for the "zip bomb" risk), scanning the contents, and handling the case of multiple files inside.

The rule on attachments: **scan first, open after, and recognise the real Italian formats** (the signed `.p7m` is the one generic tutorials ignore and that in Italy you find constantly on PEC and invoices). An agent that cannot unwrap an `.xml.p7m` is useless on Italian invoices.

## Idempotency: the Message-ID, so you don't reclassify forever

Here is the bug that sends naive inbox agents into a loop, and how you avoid it. If the agent reconnects (after a backoff, a restart, a crash) and rescans the mailbox, it risks **reprocessing mails already sorted**, moving them again, reclassifying them, maybe forever. The result: folders that get scrambled, the same invoice processed ten times, logs that explode.

The defence is **idempotency based on the Message-ID**. Every email has a `Message-ID` header unique worldwide. The agent keeps a register of Message-IDs already processed (in a small database, or in a file). Before processing a mail:

- If its `Message-ID` is **already in the register** → it has already been sorted, skip.
- If it is **new** → process it, and record the Message-ID at the end of the work.

```python
import sqlite3, email

db = sqlite3.connect("processate.db")
db.execute("CREATE TABLE IF NOT EXISTS visti (message_id TEXT PRIMARY KEY, ts TEXT)")

def gia_processata(raw_bytes) -> bool:
    msg = email.message_from_bytes(raw_bytes)
    mid = msg.get("Message-ID", "").strip()
    if not mid:
        return False                     # senza Message-ID: gestisci con cautela
    cur = db.execute("SELECT 1 FROM visti WHERE message_id = ?", (mid,))
    return cur.fetchone() is not None

def segna_processata(raw_bytes):
    msg = email.message_from_bytes(raw_bytes)
    mid = msg.get("Message-ID", "").strip()
    if mid:
        db.execute("INSERT OR IGNORE INTO visti VALUES (?, datetime('now'))", (mid,))
        db.commit()
```

That way, rescanning the mailbox after a restart does not recreate the chaos: seen mails are skipped, new ones are processed once. It is the same idempotency principle that makes the [retries of an agent that writes to systems]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}) safe: what repeats must not double the effect. Note the edge case: some mails (rare, malformed) may have no Message-ID — they need a cautious rule (e.g. a hash of the content) instead of assuming there is always one.

## Two mails, two paths: how the agent actually decides

Let's put the pieces together on two real mails, to see how the agent works moment by moment.

**Mail 1 — a supplier invoice.** A PEC arrives with an attachment `IT01234567890_00042.xml.p7m`.

1. IDLE notifies; the agent downloads the new mail.
2. Idempotency check: the `Message-ID` is new → process it.
3. Antivirus on the attachment: clean.
4. The extractor recognises the `.p7m`, unwraps it, finds valid FatturaPA XML.
5. **Deterministic rule**: valid FatturaPA attachment → it is an invoice, maximum confidence. No model needed.
6. The mail goes to `10-fatture`; the structured data (supplier, number, amount) are extracted and made available to the archive/RAG. Message-ID recorded.

Time: instantaneous, zero AI, zero data left. Most of the "important" mail sorts this way, with rules alone.

**Mail 2 — an ambiguous communication.** A PEC arrives from a certified domain, subject "Riscontro alla vostra del 12", body of text, no structured attachment.

1. IDLE, idempotency, antivirus (no risky attachments): ok.
2. Deterministic rules do not decide: it is a PEC (certified domain → likely legal area), but the content could be a formal notice, a reminder or a neutral communication.
3. The **local classifier** steps in: it receives the *cleaned* body (any names/references masked), answers "possible legal communication, medium confidence".
4. Medium confidence + PEC nature → the agent **does not force**: it puts it in `20-pec-legale` *and* flags it for review. If confidence had been low, it would have gone to `50-da-umano`.
5. A human sees it soon, in the right folder, and decides. Message-ID recorded.

The contrast is the point: on the clear (the invoice) the agent is deterministic, fast and without AI; on the ambiguous (the text PEC) it uses the local model but **with humility**, escalating to a human when confidence is not enough. Neither path sent data outside, and no important PEC ended up lost in the pile. This is the inbox agent done well: automation where it is safe, caution where it is not.

## What breaks in production: the PEC provider error list

Inbox agent failures are almost always connection and authentication, and PEC providers have their peculiarities. Here is what you will see and how you recognise it.

| Error (typical) | Cause | Remedy |
|---|---|---|
| `AUTHENTICATIONFAILED` | Wrong password, or you need a dedicated password / IMAP not enabled | Create the purpose-built credential, enable IMAP access in the provider panel |
| Connection refused / timeout | Wrong host or port, or the agent's IP blocked | Verify IMAPS host and port 993 (TLS); check any blocks on the provider side |
| `Too many connections` | Too many simultaneous connections to the same mailbox | One IDLE connection per mailbox; don't open one for every operation |
| Temporary block / rate limit | Polling too aggressive or burst reconnects | Use IDLE, put in backoff, reduce frequency |
| Disconnect after ~29 min | Natural IDLE timeout not renewed | Renew IDLE with a shorter timeout (5 min) |
| TLS certificate error | Certificate chain or CA | Verify the client's TLS configuration |
| Mailbox quota full | PEC has space quotas; if full, it does not receive | Monitor space; archive/download to free it |

The common thread: **the vast majority of problems read in the logs as login or connection errors**, and they are solved with a dedicated password, IDLE instead of polling, backoff, and session renewal. If the agent "stops receiving" with no obvious errors, suspicion number one is IDLE dead and not renewed: check there first.

## The operational runbook: dedicated passwords, fail2ban, backup of the rules

An inbox agent in production has to be operated, not just written. The minimum runbook:

- **Dedicated password, never the personal one.** The agent uses a credential created on purpose for it, revocable without touching human access to the mailbox. If the agent is compromised, you revoke that one and that's it.
- **Secrets out of the code.** Passwords and hosts in environment variables / secrets, not written in the source or in the logs.
- **fail2ban on the agent's server.** The server that hosts the agent is exposed: fail2ban (or equivalent) blocks hostile access attempts. Basic hygiene of any machine that sits on the network.
- **Backup of the classification rules.** The sorting logic (the deterministic rules, the taxonomy, the confidence thresholds) is an asset: it gets versioned and backed up. If you lose it, rebuilding it is pain.
- **Monitoring of "I am alive".** The agent must signal that it is working (a heartbeat, a periodic log). A silently dead inbox agent is worse than no agent: you think it sorts and instead mail piles up in `00-da-leggere`.
- **Periodic review of `50-da-umano`.** The uncertain folder has to be emptied by a person regularly, and recurring cases become new rules. It is the cycle that makes the agent better over time.

## The reference architecture

Putting the pieces together:

- **The IMAP agent** (in Docker) connected to the mailbox via IMAP IDLE over TLS, with backoff and renewal.
- **The classifier**: deterministic rules first, then a **local** model (on the cleaned body only) for the ambiguous, with a confidence threshold.
- **The antivirus** (ClamAV, in a container) that scans every attachment before opening it.
- **The attachment extractor** that recognises `.xml`, `.xml.p7m`, `.zip`, PDF.
- **The Message-ID register** (SQLite/DB) for idempotency.
- **The IMAP folders** of the taxonomy, including `20-pec-legale` and `50-da-umano`.

**What the agent NEVER does:**

- **Does not reply** to mails on its own (especially PEC: a reply with legal value is not sent by an LLM).
- **Does not delete** mail: at most it moves to folders; deletion is a human decision.
- **Does not send** the content to an external SaaS: it classifies locally.
- **Does not force** uncertain mails into a folder: it puts them in review.

The steps to build it:

1. **Create the dedicated credential** and enable IMAP on the mailbox.
2. **Define the folder taxonomy** and create them.
3. **Write the deterministic rules** (FatturaPA → invoices, PEC domain → pec-legale, etc.).
4. **Add the local classifier** for the ambiguous, with a confidence threshold and fallback to `50-da-umano`.
5. **Put in the antivirus** and attachment extraction (with `.p7m`).
6. **Add idempotency** on the Message-ID.
7. **Put in IDLE with backoff and renewal**, monitoring, the runbook.
8. **Run it in parallel** with human use before you trust it, watching what ends up in `50-da-umano`.

## The costs

Orders of magnitude, stated estimates:

- **The agent itself**: runs on a modest server or a VPS (a few tens of € a month, or on hardware you already have). The load is low: IDLE consumes almost nothing while waiting.
- **Local classification**: if you use an LLM for the ambiguous, the GPU argument of the sovereign stack applies (a used 24 GB card ~€800 if needed, but for classification of short text alone even a small GPU or light models are enough; many mails classify with rules alone, without a model).
- **ClamAV**: free, runs in a container, negligible cost.
- **The comparison**: an inbox AI SaaS has a per-mailbox/user fee — convenient but it sends the mail outside. The self-hosted agent has a one-off build cost and then runs almost for free, keeping the data in-house. Across more mailboxes and over time, in-house wins — and on top of that you don't have the risk of gifting your nervous system.

## When NOT to do it

Honesty, as always. **Do not build this agent if:**

- **You have little mail and few PEC.** If you receive a handful of mails a day and PEC are rare, sorting them by hand is cheaper than building and maintaining an agent. Automation makes sense on volume.
- **You don't have anyone who maintains a self-hosted service.** The agent has to be kept alive (connections, updates, the `da-umano` folder to empty). Without someone who takes care of it, a neglected agent silently accumulates mail — worse than nothing.
- **Your provider already offers adequate sorting, in-EU.** If your PEC/mail operator already has sorting rules that are enough for you and keeps the data in the EU under contract, maybe you don't need to build.
- **You only need to search, not sort.** If the need is "find the mails again", that is a search problem, not an inbox agent.

The proportion: the inbox agent shines on **high volumes of heterogeneous mail, with PEC and invoices to watch, and the need not to gift the mail to a third party.** Outside that, weigh whether the game is worth the candle — saying so is part of the job.

## Operational checklist before production

- [ ] **Dedicated credential** for the agent; IMAP enabled; password out of the code.
- [ ] **IMAP over TLS** connection (port 993), with **IDLE**, **backoff** and session **renewal**.
- [ ] **Folder taxonomy** defined, including `pec-legale` and `da-umano`.
- [ ] **Deterministic rules** before the model (FatturaPA, PEC domains).
- [ ] **Local classification** on the cleaned body only, with a **confidence threshold** → uncertain to `da-umano`.
- [ ] **Antivirus** on every attachment before opening it.
- [ ] Attachment extraction that handles **`.xml`, `.xml.p7m`, `.zip`, PDF**.
- [ ] **Idempotency** on the Message-ID; no infinite reclassification.
- [ ] **fail2ban** and security hygiene on the agent's server.
- [ ] **Heartbeat/monitoring**: you know whether the agent is alive.
- [ ] **Backup** of the classification rules.
- [ ] The agent **does not reply, does not delete, does not send outside**: it only sorts, and escalates the uncertain.

## The verdict: mail is guarded in-house

Putting AI on mail must not mean gifting your nervous system to a SaaS. A self-hosted IMAP agent classifies PEC and invoices in your house, on the standard protocol that every mailbox speaks, with IDLE for real time and backoff so you don't get banned, classification locally on the cleaned text only, serious handling of Italian attachments (the signed `.p7m`, FatturaPA XML), idempotency on the Message-ID so you don't go mad, and the `da-umano` folder that keeps the automation honest. It is not "an AI email assistant": it is a piece of vertical integration on Italian mail, PEC included, that keeps the data where it should stay — with you. Mail is too important, and too full of sensitive data, to hand over to others.

This is a brick of the [guide to integrating data in-house]({{ '/en/pillar/integrations-legacy-data/' | relative_url }}), where company flows get automated without leaving the fence. If you want an inbox agent on *your* mail and *your* PEC, start from [who I am and how I work]({{ site.main_site }}/biografia/) or drop me a couple of lines in [contacts]({{ site.main_site }}/contatti/).

## FAQ

**1. Why don't I use an AI assistant connected to Gmail or Outlook?**
Because to work it has to read the entire mailbox and process it on its servers: you are giving a third party access to the most sensitive flow you have. On top of that, Italian PEC does not live in Google/Microsoft APIs. The self-hosted IMAP agent does the same job keeping the data in-house.

**2. Isn't IMAP old? Why not modern APIs?**
IMAP is "old" in the sense of standard, universal and stable: any mailbox speaks it, PEC included, without tying you to a giant's ecosystem. It is exactly that openness that makes it the sovereign choice: you connect directly, with no intermediaries that walk off with the data.

**3. What is IMAP IDLE and why not poll?**
IDLE is the mode in which the server *notifies* you when mail arrives, instead of making you ask continuously ("is there mail? is there mail?"). Polling wastes CPU and can get you banned by the provider for abusive behaviour. IDLE is low-load, real-time, and does not irritate the provider. It has to be renewed every ~29 minutes and accompanied by backoff on reconnects.

**4. Does the agent read mails with an LLM? Isn't that a privacy problem again?**
No, if done well: most of the sorting is done with deterministic rules (a FatturaPA attachment is an invoice, without AI). The language model steps in only on the ambiguous, runs **locally**, and receives only the body cleaned of sensitive data. The data does not leave your server.

**5. How does it handle electronic invoices?**
It recognises FatturaPA XML attachments in their real formats: `.xml`, `.xml.p7m` (signed, has to be unwrapped) and inside `.zip`. Once the XML is extracted, it has the invoice's structured data, which can feed a RAG to query them. An agent that cannot handle the signed `.p7m` is useless on Italian invoices.

**6. And viruses in attachments?**
Every attachment goes through a local antivirus (ClamAV in a container) *before* being opened. Mail is malware vector number one: if the attachment is infected, it goes to quarantine and is not processed. Opening attachments without scanning them is an open door.

**7. What happens if the agent restarts? Does it reprocess everything?**
No, thanks to Message-ID idempotency: the agent keeps a register of mails already processed and skips the ones it has seen. Without this, after a restart it would reclassify the same mails forever, scrambling the folders. It is the key defence against loops.

**8. What does the agent do when it is not sure how to classify a mail?**
It puts it in the `da-umano` folder, it does not force it into a random box. This is the safety net that makes automation reliable: the agent sorts the clear on its own and escalates the uncertain to a human. Better ten mails to review than a formal notice lost or an invoice in spam.

**9. Can it reply to PEC in my place?**
No, and it is a security choice: the agent sorts, it does not reply. A reply with legal value (as a PEC is) is not sent by an LLM. The agent puts the important PEC in front of you, soon, in their folder; the reply you write.

**10. How much does it cost compared to an inbox AI SaaS?**
The self-hosted agent has a one-off build cost and then runs almost for free (IDLE consumes very little, ClamAV is free, classification is often rules only). A SaaS has a per-mailbox fee and sends the mail outside. Across more mailboxes and over time in-house pays off, and on top of that you don't gift your nervous system to a third party.
