---
lang: en
permalink: /en/blog/accounting-firm-pec-automation/
alt_url: /it/blog/automazione-studio-commercialista-pec/
title: "PEC, invoices and deadlines: how to automate a professional firm (accountant, adviser, agency) without replacing the professional"
date: 2026-12-29 07:30:00 +0200
author: "Antonio Trento"
description: "For professional firms of 3 to 10 people: what can be sorted automatically (PEC certified email, invoices, deadlines, repeated requests) and what's off-limits (opinion, signature, SPID, responsibility), the arrival → classify → folder → reminder → professional flow, client confidentiality, practice software before a chatbot, costs versus a part-time assistant and a 60-day plan."
keywords: ["accounting firm pec automation", "professional firm automation", "automatic pec sorting", "tax deadline software", "ai for accountants", "pec sorting firm"]
image: /assets/images/posts/automazione-studio-commercialista-pec.jpg
pillar: integrazioni-selfhosted
related: [/en/blog/ai-agent-spid-pec-limits/, /en/blog/ai-invoice-reading-errors/]
---

## The firm is drowning in PEC and PDFs, not in "lack of AI"

Monday morning, an accounting firm with six people. The firm's PEC mailbox (Italy's certified email, with legal value) holds 140 messages arrived since Friday: notices from the Revenue Agency for clients, communications from INPS, notifications from the Chamber of Commerce, invoices from the firm's suppliers, delivery receipts for sends made on Friday, client requests, certified newsletters from various bodies. In the ordinary email inboxes, dozens more messages with attachments: bank statements, receipts, photographed till slips, "forwarding you the phone bill". Someone — often the most experienced assistant, sometimes a professional — spends the morning opening, understanding, renaming, saving to the right client's folder, noting deadlines.

This firm's problem isn't that it "doesn't use artificial intelligence". It's that it's **drowning in PEC and PDFs** to sort, and the professionals' time goes on work that doesn't need a professional. The proposals the firm receives, however, almost always talk about something else: "an AI assistant that answers clients", "a ChatGPT for tax questions". Tools that, at best, don't solve the real problem; at worst, touch exactly the part that must stay with the professional.

This piece explains how to **automate a professional firm** — accountant, labour consultant, administrative agency — starting from PEC and documents: what can be sorted automatically, what's off-limits, how the flow from arrival to professional works, how to protect client confidentiality, why the firm's practice software comes before any chatbot, what it costs compared with a part-time assistant, and a 60-day plan for a firm of 3 to 10 people.

## Is this for you?

It is for you if:

- you're the owner or partner of a professional firm (accountant, labour consultant, tax assistance centre, administrative agency, business consultant) with 3–10 people;
- the firm's PEC and email inboxes receive dozens of documents to sort every day;
- clients' deadlines live in practice software, an Excel sheet and people's memory;
- you've been offered AI tools and don't know where to start.

It is not for you if the firm already has an integrated document system that sorts everything and works: you'll find things you know. And it is not for you if you're looking for an assistant that gives clients tax opinions: this piece explains why that's not a good idea.

## What can be sorted (invoices, deadlines, repeated requests)

A firm's repetitive work, the kind that can be automated with good results, sits almost entirely **at the edges** of professional work: before the document reaches the professional, and after the professional has decided.

**Before the professional (sorting):**

- **incoming PEC**: recognising the sender (Revenue Agency, INPS, INAIL, Chamber of Commerce, court, client, supplier), the type of communication (notice, tax bill, receipt, request), the client it refers to (from the tax code or VAT number in the text or attachment), and saving the document in the right folder;
- **client documents**: invoices, bank statements, receipts, till slips sent by email or uploaded to a portal, classified by client, type and period;
- **the firm's supplier invoices**: read from the XML and posted, as in any company;
- **delivery receipts** for sends made by the firm, matched to the original send and archived.

**After the professional (execution and reminders):**

- **deadlines**: computing clients' deadlines from rules and practice-software data, internal reminders to professionals and reminders to clients for documents to deliver;
- **repeated requests to clients**: "send us the quarter's bank statements", "send us the receipts for medical expenses", sent automatically with the right template and a reminder if they don't arrive;
- **preparing recurring cases**: collecting the necessary documents, checking completeness, preparing the draft for the professional;
- **standard communications**: confirming receipt of documents, notifying that a filing has been submitted, with references.

In all these cases automation **prepares, sorts, reminds**. It doesn't decide, doesn't sign, doesn't advise.

## What's off-limits: opinion, signature, SPID, responsibility

Some activities remain the professional's, by law, by professional ethics and by common sense.

- **The opinion.** Interpreting a rule, assessing a client's position, deciding how to set up a return or answer a notice: it's the professional's work, and what the client pays for. A language model can help find documents or summarise a circular; it can't give the opinion, neither to the client nor on the professional's behalf. Italy's law on artificial intelligence says so clearly for intellectual professions: AI can only be a support tool, and the professional must inform the client of its use.
- **The signature.** Returns, applications, delegations, digitally signed communications: the signature expresses the will and responsibility of the signer. It isn't delegated to an automated system.
- **SPID, CIE and intermediaries' credentials.** Access to public administration portals with the professional's identity or the firm's intermediary authorisations is personal and traced. An agent logging in with those credentials creates a false attribution. I wrote about it in detail in the piece on [the agent's limits with SPID and PEC]({{ '/en/blog/ai-agent-spid-pec-limits/' | relative_url }}).
- **Sending with effects.** The reply to a notice, submitting an application, a communication to a body with legal value: the system prepares the package, the professional checks and sends (or approves sending that precise package).
- **Responsibility towards the client.** If a deadline is missed, responsibility lies with the firm, not the software. Automation must make deadlines more visible, not shift responsibility.

### Automatable / not automatable matrix

| Activity | Automatable | Who decides / checks | Notes |
|---|---|---|---|
| Recognising PEC sender and type | Yes | Spot review | Sender rules + text classification |
| Associating the PEC with the client | Yes, if there's a tax code/VAT number | Review if uncertain | Never "guess" the client from the name |
| Saving to the client's folder | Yes | — | Standard file name: client, type, date |
| Noting the related deadline | Yes, as a proposal | Professional confirms | Computed deadlines must be verified |
| Matching delivery receipts to sends | Yes | — | Deterministic |
| Posting the firm's supplier invoices | Yes, from the XML | Review special cases | As in any company |
| Classifying documents sent by clients | Yes | Spot review | By client, type, period |
| Requesting documents from clients and chasing | Yes | — | Templates approved by the firm |
| Checking a case's completeness | Yes | Professional | Checklist as a file, not a prompt |
| Summarising a long communication from a body | Yes, as an aid | Professional reads the original | The summary doesn't replace the document |
| Interpreting the notice and deciding the reply | **No** | Professional | It's the opinion |
| Answering clients on tax matters | **No** | Professional | No chatbot giving opinions |
| Signing returns and applications | **No** | Professional | Signature = responsibility |
| Accessing portals with SPID / authorisations | **No** | Professional | Personal identity |
| Sending communications with legal effects | **No** on its own | Professional sends or approves | Package prepared by the system |

## Flow: arrival → classify → folder → reminder → human

Here's the typical flow for the firm's PEC, which is where to start because it's where most time is lost.

### The PEC flow

```text
1. ARRIVAL
   The firm's PEC mailbox receives the message.
   An internal service reads it (without deleting or moving anything on the PEC server).
        │
        ▼
2. CLASSIFY
   - Sender: known body (Revenue Agency, INPS, INAIL, Chamber of Commerce, court), client, supplier, other
   - Type: notice / communication / tax bill / receipt / request / invoice / newsletter
   - Client: looked up by tax code or VAT number in the text and attachments
     → if found with certainty: associated
     → if not found or ambiguous: goes to "to sort" (human)
        │
        ▼
3. FOLDER
   The complete message (.eml) and attachments are saved in the client's folder,
   with a standard name: [client]_[type]_[body]_[date].pdf
   and registered in the firm's practice software (client record → documents).
        │
        ▼
4. REMINDER
   If the type implies a deadline (e.g. a notice with a reply period):
   - the system PROPOSES the computed deadline
   - creates a task for the professional responsible for the client
   - alerts: "New Revenue Agency notice for Rossi Srl, proposed deadline: 20/01. To verify."
        │
        ▼
5. HUMAN
   The professional opens the task, reads the original document,
   confirms or corrects the deadline, decides what to do.
   The system doesn't reply, doesn't sign, doesn't send.
```

Two important details:

- **Reading the PEC mustn't disturb the server**: no connections every ten seconds that get the mailbox blocked by the provider, no deletions. Techniques for listening to the PEC mailbox without being throttled by the provider are described in the piece on the [agent that reads PEC and invoices]({{ '/en/blog/imap-pec-invoice-agent/' | relative_url }}).
- **The client is associated only with a certain identifier** (validated tax code or VAT number), never from the name: two clients with the same surname are the norm, not the exception.

## Clients and confidentiality

A professional firm processes its clients' most confidential data: income, assets, debts, family situations, health (for deductions), employees. Any automation must start from here.

- **Where data runs.** The service that reads PEC, classifies and saves must run on the firm's infrastructure or a provider's under contract with data in the EU. If it uses a language model to classify text, the model must be local or provided under contract, without training on data, preferably in the EU.
- **No personal ChatGPT.** The collaborator who pastes a client's Revenue Agency notice into ChatGPT to "understand what it wants" is transferring a client's tax data to an external service without safeguards. You need an authorised tool, and clear rules. The regulatory framework is in the piece on [whether ChatGPT is legal at work in Italy]({{ '/en/blog/is-chatgpt-legal-at-work-italy/' | relative_url }}).
- **Permissions per client.** Not everyone in the firm needs to see all clients. If the firm has professionals with separate portfolios, folder and practice-software permissions must be respected by automation too.
- **Notice and engagement letter.** If the firm uses AI tools in working on clients' documents, it must say so: a clause in the engagement letter and the privacy notice.
- **Retention.** Clients' documents have precise retention periods; automation must save in the right places (practice software, compliant archive where required), not create scattered copies.

## Tools: practice software before a chatbot

Most firms already have **professional practice software** (for bookkeeping, returns, payroll, deadline calendar, document archive). Many of these packages have features the firm doesn't use: automatic import of clients' e-invoices, deadline calendar, document archive, client portal, sending document requests.

The rule is simple: **use the practice software to the full first, then add what's missing**. Questions to ask the software vendor:

- does it automatically import clients' e-invoices from the intermediary's channel?
- does it have a deadline calendar generating tasks for professionals and reminders for clients?
- does it have a per-client document archive, with automatic upload?
- does it have a client portal for exchanging documents (instead of email)?
- does it have a way (API, monitored folders, imports) to receive documents from external systems?

What's usually missing, and what's added with external automation, is precisely the **PEC → classify → practice software** piece, because the firm's PEC receives everything and the practice software can't read it. A small internal service (with an automation tool or a dedicated program) acts as a bridge. A chatbot answering clients, if ever, comes much later, and with very tight limits (hours, documents to send, case status), never on professional questions.

## A concrete case: an accounting firm with 7 people

Three professionals, four collaborators, about 250 clients among companies, sole traders and individuals. The firm's PEC mailbox receives on average 70 messages a day, with peaks above 150 around deadlines. An experienced collaborator spends about 2–3 hours a day sorting PEC and client documents.

**Starting point.** The practice software has a deadline calendar and a document archive, half-used. Client documents arrive by email and are saved by hand into folders on the server. Deadlines tied to notices are noted by hand in the calendar, when someone remembers.

**What was done in 60 days.** First month: switching on practice-software features that weren't used (automatic import of clients' e-invoices, a client portal for sending documents instead of email). Second month: an internal service, on a firm server, that reads the PEC, classifies sender and type with rules and a local model for non-standard text, associates the client via tax code or VAT number, saves the complete message and attachments into the practice software archive and proposes deadlines as tasks for the professional. Uncertain messages go into a "to sort" queue.

**After three months.** About 80% of PEC messages are sorted automatically; 20% end up in the queue (mainly communications with unidentifiable clients or new senders). The collaborator spends 30–45 minutes a day on the queue instead of 2–3 hours, and the time recovered goes on cases. No notice deadline was missed in the quarter, because every notice generates a task for the responsible professional, with a proposed deadline to confirm.

### Time estimates

| Activity | Before (per day) | After (per day) | Notes |
|---|---|---|---|
| PEC sorting | 1.5–2 hours | 20–30 minutes | Only the queue of uncertain cases |
| Saving client documents | 45–60 minutes | 10–15 minutes | Client portal + classification |
| Entering deadlines from notices | 20–30 minutes | 5–10 minutes | Confirming proposed deadlines |
| Document requests and chasers | 20–30 minutes | 5 minutes | Templates and automatic chasers |
| **Total** | **3–4 hours** | **40–60 minutes** | For a firm of 6–8 people |

(Indicative estimates, varying with number of clients and the firm's type of work.)

## What breaks after a few months

Even well-set-up sorting gets worse if nobody watches it. The typical signs in a firm:

- **New senders and new formats.** A body changes the format of its communications, or a never-seen sender arrives (a new body, a new platform). The system doesn't recognise it and messages end up in the queue. It's not a failure: it's the sign a rule needs adding. Remedy: once a month, look at the most frequent senders in the queue.
- **The "to sort" queue grows.** If it goes from 20% to 35% of messages, something changed: a new type of communication, new clients not yet in master data with a tax code, attachments in a different format. Remedy: look at the most frequent reason and fix it.
- **Proposed deadlines aren't confirmed.** Tasks pile up in the professional's calendar unconfirmed, because "I'll look later". It's the most serious risk: a deadline proposed and never confirmed isn't a managed deadline. Remedy: a weekly summary of unconfirmed deadlines to the firm's owner.
- **The PEC mailbox fills up.** Sorting saves documents to the archive, but the PEC mailbox on the provider's server keeps growing until it hits the space limit, and at that point incoming messages are rejected. Remedy: an archiving rule for the mailbox, after messages have been saved and verified.
- **Clients go back to email.** After a few months, some clients start sending documents by email again instead of through the portal. Remedy: a polite automatic reply reminding them of the portal, and a check that documents arriving by email still get classified.

Half an hour a month from the experienced collaborator on these points keeps sorting reliable.

## Costs vs a part-time assistant (honest estimates)

| Item | Estimate | Notes |
|---|---|---|
| Switching on practice-software features (client portal, imports) | €0–2,000 + any fee | Depends on the software; often already included |
| PEC → classify → practice software service | €4,000–12,000 setup | On a firm or EU server; depends on the practice software's integrations |
| Server or infrastructure | €0–60/month | Often the existing server or a small EU server is enough |
| Local model for text classification | included in the server or €20–80/month | Only for non-standard text |
| Maintenance | 0.5–1 day a month | New senders, new document types, updates |
| **Comparison: an additional part-time assistant** | €900–1,400/month | Indicative for 20 hours a week |

The honest comparison: for a firm of 6–8 people thinking of hiring someone for sorting, automation costs less in the first year and much less in following years. But it doesn't replace the firm's people: it frees the experienced collaborator from sorting and brings her back to work where her experience is needed. For a 3-person firm with few PEC messages a day, the investment pays back only if you first switch on the practice-software features, which cost little or nothing.

## 60-day plan for a firm of 3–10 people

### Days 1–30: practice software and order

- **Week 1**: count PEC and documents by type for a week; list of the most frequent senders; time spent on sorting today.
- **Week 2**: meeting with the practice-software vendor to switch on what already exists (imports, client portal, deadline calendar, archive).
- **Week 3**: file naming rules and per-client folder structure, the same for everyone; usage rules for AI tools written and shared (no personal accounts with client documents).
- **Week 4**: launch of the client portal for sending documents; communication to clients with simple instructions.

### Days 31–60: PEC automation

- **Week 5**: installation of the PEC reading service on firm or EU infrastructure, in "observe only" mode: it classifies and proposes, but doesn't save.
- **Week 6**: comparison between the system's proposals and manual sorting; correcting sender and type rules.
- **Week 7**: switching on automatic saving for certain cases; "to sort" queue for uncertain ones; deadline proposals as tasks for professionals.
- **Week 8**: measuring times; updating the engagement letter and notice on the use of tools; decision on next steps (automatic chasers, case completeness checks).

## 3 beginner mistakes that cost time or clients

**1. Starting from the client chatbot.** It's the most visible proposal and the least useful: an assistant answering clients' questions risks giving advice that belongs to the professional, and removes none of the sorting work that really weighs. Start from the PEC.

**2. Associating documents with the client by name.** "Rossi" in a firm with 250 clients means three or four different clients. Association is done with a validated tax code or VAT number; if missing, the document goes to the queue, not to the most likely folder.

**3. Letting the system confirm deadlines by itself.** A deadline computed wrongly from a notice not read by a professional is the firm's responsibility. The system proposes, the professional confirms: it's a rule, not an option.

## When NOT to do it

- **When PEC messages are few** (a dozen a day): practice-software features and some order are enough.
- **When the practice software is about to be changed**: choose the new one first, then automate around it.
- **When nobody in the firm can follow the project**: you need at least one person (even the experienced collaborator) to check the queue and report cases to fix.
- **When the firm wants a tool that "answers clients for us"**: it's the wrong goal, with professional and ethical risks.

## Practical checklist

- [ ] I've counted PEC and documents by type and the time spent sorting them.
- [ ] I've switched on practice-software features we weren't using (imports, client portal, deadline calendar).
- [ ] Folders and file names follow the same rules for everyone.
- [ ] The PEC reading service runs on firm or EU infrastructure, under contract if external.
- [ ] The client is associated only via tax code or VAT number; uncertain cases go to the queue.
- [ ] Deadlines are proposed as tasks and confirmed by the professional.
- [ ] The system doesn't answer clients on professional matters, doesn't sign, doesn't access portals, doesn't send communications with effects.
- [ ] No collaborator uses personal AI accounts with client documents.
- [ ] The engagement letter and notice mention the use of AI tools.
- [ ] At 60 days I've measured time saved and deadlines handled.

## The verdict

**Automating a professional firm** doesn't start from an artificial intelligence answering clients. It starts from PEC and documents: recognising who's writing and what they're sending, associating it with the right client via a certain identifier, saving it in the right place, proposing the deadline to the professional. It's edge work, repetitive, that today consumes hours of the firm's most experienced people.

The heart of the work — the opinion, the signature, portal access, responsibility towards the client — stays with the professional, and must stay there. Done this way, automation replaces nobody: it gives the firm back the hours that today go into sorting, with clients' data staying where it belongs.

If you want to set up automation of PEC and documents in your firm, starting from the practice software you already have, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on integrations and self-hosted systems are in the guide on [ERP integrations and self-hosted systems]({{ '/en/pillar/erp-integrations-selfhosted/' | relative_url }}).

## FAQ

### What can be automated in an accounting firm?

Sorting PEC (sender, type of communication, client), saving documents into clients' folders, importing e-invoices, proposing deadlines tied to notices, requesting documents from clients with chasers, checking case completeness and standard confirmation communications.

### What must not be automated in a professional firm?

The professional opinion, signing returns and applications, accessing portals with SPID or the firm's authorisations, autonomously sending communications with legal effects and answering clients on tax or employment matters. These activities remain the professional's by law and professional ethics.

### How do you automate PEC sorting?

With a service that reads the mailbox without changing it, recognises sender and type of communication with rules and, where needed, a local language model, associates the client via tax code or VAT number, saves message and attachments in the client's archive and proposes any deadlines as tasks for the professional. Uncertain cases end up in a queue for a person.

### Can ChatGPT be used to read clients' Revenue Agency notices?

Not with personal accounts: it would mean transferring clients' tax data to an external service without safeguards. A tool authorised by the firm can be used, under contract, without training on data and preferably in the EU, as a reading aid. Interpretation stays with the professional.

### Must the firm tell clients it uses artificial intelligence?

Yes. Italy's law on artificial intelligence requires professionals to inform clients of the use of AI systems, which may only support intellectual work. A clause in the engagement letter and privacy notice is the simplest way.

### Better new practice software or external automation?

First use to the full the features of the practice software the firm already has: automatic imports, client portal, deadline calendar, archive. External automation is for what the software doesn't do, usually the link between the firm's PEC and the client archive.

### How much time is saved by automating PEC?

For a firm of 6–8 people with a few dozen PEC messages a day, sorting can drop from 3–4 hours a day to 40–60 minutes, spent on the queue of uncertain cases. Estimates vary with the number of clients and type of work.

### How much does it cost to automate a professional firm?

Roughly €4,000 to €12,000 of setup for the PEC sorting service connected to the practice software, plus contained infrastructure costs and half a day to a day a month of maintenance. Switching on features already present in the practice software often costs little or nothing.

### How do you avoid saving a document in the wrong client's folder?

By associating the document with the client only via a validated tax code or VAT number, present in the text or attachments. If the identifier is missing or matches several clients, the document goes to a queue for a person, instead of the most likely folder.

### Is a chatbot for the firm's clients a good idea?

Rarely as a first step. It risks giving guidance that belongs to the professional and doesn't reduce the sorting work. If introduced, it must have very tight limits: hours, documents to send, case status, never answers on tax or employment matters.
