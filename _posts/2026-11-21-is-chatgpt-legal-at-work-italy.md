---
lang: en
permalink: /en/blog/is-chatgpt-legal-at-work-italy/
alt_url: /it/blog/chatgpt-legale-in-azienda-italia/
title: "Is ChatGPT legal at work in Italy in 2026? A practical guide for business owners (not a talk show)"
date: 2026-11-21 07:30:00 +0200
author: "Antonio Trento"
description: "Using ChatGPT at work in Italy is legal under certain conditions: it depends on the data, the type of account, the contract and the use. Personal vs business account vs API, DPAs and transfers, the AI Act, the record of processing, concrete cases, a yes/no matrix and a printable checklist."
keywords: ["is chatgpt legal at work italy", "gdpr chatgpt 2026", "ai act sme italy", "employee use of openai", "chatgpt dpa", "chatgpt record of processing"]
image: /assets/images/posts/chatgpt-legale-in-azienda-italia.jpg
pillar: chatgpt-azienda
related: [/en/blog/chatgpt-company-data-gdpr/, /en/blog/eu-ai-act-sme-agents-2026/]
---

## The wrong question: "is it legal?" vs "for which data?"

"So in the end, **is ChatGPT legal at work in Italy**, yes or no?" It's the question business owners ask me most often, usually after reading an alarmed headline or hearing a colleague say "the data protection authority banned it". The honest answer disappoints anyone looking for a yes or a no: **it depends on which data you put in, with which type of account, under which contract and to do what**.

That's not dodging the question. It's the same reasoning that applies to any tool that processes data: using a cloud email service is legal, but if you send patients' medical records through it without the right safeguards you're breaking the rules. ChatGPT, Gemini, Claude, Copilot and the like are neither legal nor illegal in the abstract: they are tools, and their use is lawful or not depending on the conditions.

So the useful question isn't "is it legal?", but three more precise ones:

1. **What data goes in?** Text without personal data, ordinary personal data of clients, special categories (health, union membership), employee data, trade secrets.
2. **Through which channel?** Free personal account, business plan with a contract, API built into software, model installed in-house.
3. **To do what?** Write an email, summarise a contract, screen CVs, decide who is entitled to a discount.

This guide is written for owners and managers of SMEs, not for lawyers. It takes you from "legal yes/no" to "**under which conditions**", with a matrix by data type, the most common cases and a checklist to print and take to your accountant, privacy adviser or DPO.

> **Disclaimer.** This article is not legal advice. It describes a practical approach based on European and Italian rules in force in November 2026, seen by someone who designs these systems in companies. Rules change (especially the AI Act deadlines) and every case has specifics: for decisions that expose the company, have the approach validated by a privacy adviser or a lawyer.

## Is this for you?

It is for you if:

- you're the owner, director or manager of an Italian SME and must decide whether and how to allow ChatGPT or similar tools;
- someone in the company already uses it and you want to know whether you're at risk;
- your accountant or adviser asked "how are you handling it?" and you don't know what to answer.

It is not for you if you're looking for an in-depth legal analysis of the AI Act or the GDPR: here you'll find what you need to decide and to ask the right questions of whoever advises you. And it is not for you if your problem is practical rather than legal — "employees use it secretly, how do I give them an alternative?" — because then the right piece is the one on [ChatGPT with company data and the internal alternative]({{ '/en/blog/chatgpt-company-data-gdpr/' | relative_url }}).

## Personal account vs business account vs API

The first variable, the one that changes the answer most, is **the channel** through which the company uses the model. There are four typical situations, very different from each other.

### 1. The employee's personal account

The employee uses their free or individually paid account, registered with their personal email. For the company it's the worst situation:

- **there's no contract** between the company and the provider: the provider is not a data processor for the company;
- conversations may be **used to train models**, unless the employee has switched the option off;
- the company **doesn't know** what goes in, can't delete it, can't prove anything;
- when the employee leaves, the conversations with company data stay in their account.

Using clients' or employees' personal data through this channel is, in the vast majority of cases, **processing without the safeguards the GDPR requires**. Text without personal data and without confidential information (a generic email, an explanation, an idea) creates no privacy problem, but remains a matter of company confidentiality.

### 2. Business plan (Team, Business, Enterprise and similar)

The company subscribes to a business plan. Accounts are managed by the company, access is via the work account, and generally:

- there's a **data processing agreement** (DPA) appointing the provider as data processor;
- conversations are **not used for training** by default;
- there are admin controls: who has access, retention, export, deletion;
- on some plans you can choose **data residency in Europe**.

It's the channel that makes use **legitimate for most ordinary data**, provided you do the rest of the homework (notice, record, internal rules).

### 3. API built into software

The company (or its supplier) uses the model's API inside an application: an ERP that summarises case files, a CRM that classifies emails, an automation flow. APIs generally come with "business" terms (no training on submitted data, contract available, limited retention), but the chain is longer: between you and the model sits the software supplier, which in turn must be appointed processor and must declare which sub-processors it uses.

The question to ask the software supplier is simple: "**which model do you use, where, under which contract, and what happens to the data we send?**". If they can't answer, the problem isn't the model.

### 4. A model installed in-house (or on an EU server under your control)

The company uses an open-weight model installed on its own servers or on European infrastructure it controls. Data doesn't go to an AI provider: processing stays internal (or with the infrastructure provider, under its contract). It's the solution with maximum control, which doesn't remove obligations (notice, record, usage rules) but removes the transfer problem. The full project is described in the piece on the [self-hosted private ChatGPT]({{ '/en/blog/private-chatgpt-self-hosted-sme/' | relative_url }}).

| Channel | Contract with the company | Training on data | Company control | Suitable for clients' personal data |
|---|---|---|---|---|
| Personal account | No | Often yes, unless switched off | None | No |
| Business plan | Yes (DPA) | No, by default | Good | Yes, with the other conditions |
| API in software | Yes, through the supplier | Usually no | Depends on the supplier | Yes, if the chain is documented |
| In-house model | Not needed towards an AI provider | No | Total | Yes, with the other conditions |

## Non-EU transfers and DPAs: what to actually read

Once you've chosen a "business" channel, you still need to understand **where the data goes** and **what the contract promises**. You don't need to read forty pages: you need six points.

### The six points to look for in the DPA

1. **The provider's role.** It must be named as *data processor* for the data you enter. If the contract qualifies it as an independent controller for your content, ask for an explanation.
2. **Permitted purposes.** The provider may use the data only to deliver the service (and for security and abuse), **not to train** models without your explicit consent.
3. **Retention and deletion.** How long conversations and files are kept, and how they're deleted. Deletion must be possible, and timings declared.
4. **Sub-processors.** The list of providers the service relies on (cloud, moderation, support), with the right to be informed of changes.
5. **Place of processing and transfers.** Where the servers are; if there's a transfer outside the EU, on what basis (adequacy decision, standard contractual clauses). If data residency in Europe is available, turn it on.
6. **Security and breaches.** Declared security measures and a commitment to notify you of breaches without delay, so you can meet your own obligations (notification to the authority within 72 hours, where required).

### Transfers to the United States, in brief

Many providers are American. The GDPR allows transfers to non-EU countries only with adequate safeguards. For the United States there's currently an adequacy framework (for US companies that sign up to it), and alternatively standard contractual clauses are used. It's ground that has already shifted several times in the last ten years: a prudent approach is to **prefer EU data residency** when available, or European providers, especially for sensitive data. It's not a ban: it's risk reduction.

## The AI Act: internal use vs systems that decide about people

The European AI Act is often invoked as if it banned ChatGPT at work. It doesn't. The regulation classifies uses of artificial intelligence by risk level, and most office uses in an SME fall into the lowest band.

### What concerns SMEs that "use" ChatGPT

For the AI Act, a company that uses an AI system in its business is a **deployer**, not a provider. Obligations depend on **what you do** with the system:

- **General office use** (writing, summarising, translating, drafting): minimal risk. The main obligation is **AI literacy**: since 2025 companies must ensure that those who use these systems have sufficient training to use them knowingly. Half a day of documented training already goes in the right direction.
- **Generated content shown to the public** (chatbot on the website, synthetic text or images): **transparency** obligations. Whoever talks to a chatbot must know it's an automated system; certain generated content must be disclosed.
- **Decisions about people** — recruitment, employee evaluation, task allocation, promotions, dismissals, access to credit, essential services: here you enter **high-risk** systems, with heavy obligations for those who use them (human oversight, informing workers, keeping logs, assessments). The application dates of these obligations have been subject to postponement proposals at European level: check the date in force with your adviser, but don't use the postponement as an excuse to start without rules.
- **Prohibited practices**: some applications are banned, including emotion recognition in the workplace (with medical or safety exceptions). If a supplier offers to "analyse the tone of calls to assess employees' mood", stop.

I covered this in more detail in the piece on the [AI Act for SMEs using agents]({{ '/en/blog/eu-ai-act-sme-agents-2026/' | relative_url }}). The message for the owner is simple: **as long as you use AI to write and summarise, the AI Act mostly asks for training and transparency; when you use it to decide about people, everything changes**.

### The Italian law on artificial intelligence

Since 2025 Italy also has a national law on artificial intelligence, alongside the AI Act. For SMEs the two most relevant points are:

- the employer's obligation to **inform workers** when using AI systems that concern them;
- for professionals (accountants, lawyers, advisers, engineers), the principle that AI can only be a **support tool** for intellectual work, and the duty to **inform the client** of its use.

If you're a professional firm, the second point concerns you directly: a line in the engagement letter or the client privacy notice is the minimum.

## Record of processing and employee notice

Using an AI tool with personal data is processing, and must be documented like any other. Two documents matter.

### The record of processing activities

Almost all companies must keep one (the exemption for those under 250 employees applies only to occasional processing without special categories, which is rare in practice). For the AI tool, the record's entry must say:

```text
Processing:         Support for drafting and summarising documents via an AI assistant
Purpose:            Drafting communications, summarising documents, translations
Data subjects:      clients, suppliers, employees (in the documents processed)
Data categories:    identification and contact data, contractual and commercial data
                    EXCLUDED: special categories (Art. 9), criminal data, credentials
Tool:               [service name], [business] plan, company-managed accounts
Processor:          [provider], appointed with DPA dated [date]
Place of processing: [EU / non-EU with legal basis: ...]
Retention:          conversations [90] days, then deleted
Measures:           access with company account and 2FA, signed usage rules,
                    documented training, training on data disabled
```

Line by line: the purpose says what it's for (and so what isn't allowed); the data categories say what may and may not go in; processor and place say who processes the data and where; retention and measures say how you protect it. If you can't fill in one of these fields, you've found the point to fix.

### The employee notice

Employees must know:

- which tool is authorised and for what;
- which data they may and may not enter;
- what the company records about their use (and what it doesn't);
- that use of the tool is **not used to evaluate** their performance (if that's the case; and it should be, save specific agreed arrangements);
- whom to contact with doubts or to report a mistake.

Careful with monitoring: in Italy the Workers' Statute limits remote monitoring. Systematically reading employees' conversations with the company tool is slippery ground. The prudent approach is to record only aggregated technical data, and have it validated by an employment adviser.

## Cases: marketing copy vs client records vs CVs vs code

Theory becomes clear only with cases. Here are the most common in SMEs, with the practical answer.

### Case 1 — Marketing copy

"Write me three versions of the post for the new product launch." No personal data, no confidential information (if the launch is already public). **Yes, even with any account**, though it's still better to use the business one out of habit. Two cautions: if you publish generated images or text that could mislead (fake testimonials, non-existent people), you enter transparency obligations and consumer law; and check the facts the text states.

### Case 2 — Client records and documents

"Summarise this contract with client Rossi" or "write a reply to this complaint". Contains clients' personal data and contractual information. **Yes, with the business plan or an internal solution**, contract in order, entry in the record, usage rules. **No with a personal account.** And never bulk record exports ("here are 2,000 clients, split them by sector"): there are better tools for that job, and the risk of a mistake grows with volume.

### Case 3 — CVs and recruitment

"Read these 80 CVs and tell me the 10 best." It's the case where the practical answer is **no, unless there's a structured project**. Reasons: personal data, even special categories (health, affiliations), often appear in CVs; a decision affecting people (GDPR on automated decisions); a use classified **high-risk** by the AI Act; a concrete risk of discrimination hidden in the model. Using AI to write the job ad is perfectly fine; using it to reject candidates without a framework of oversight, documentation and information is not.

### Case 4 — Source code

"Find the bug in this function." Code can contain trade secrets, forgotten credentials, real test data. **Yes with the business plan or an internal solution**, after removing credentials and real data; **no with a personal account** if the code is proprietary or the client's (many development contracts forbid sharing code with third parties). If you develop for clients, check confidentiality clauses first.

### Case 5 — Employee data

"Write the disciplinary letter for Mario" or "summarise the annual appraisals". Employment data, often sensitive. **Only with business or internal solutions**, with great caution, and never to decide (the decision stays with the responsible person, reasoned and documented).

### Case 6 — Health data or minors' data

Medical practices, care centres, schools, gyms with health data. **No with generic tools**, even business ones, without an impact assessment and a dedicated project. It's the territory where you need the privacy adviser from the start, and where often an internal solution is the only reasonable one.

### Yes/no matrix by data type

| Data type | Personal account | Business plan with DPA | API in documented software | In-house model |
|---|---|---|---|---|
| Text without personal or confidential data | Yes | Yes | Yes | Yes |
| Public text / marketing | Yes | Yes | Yes | Yes |
| Ordinary personal data of clients/suppliers | **No** | Yes, with rules | Yes, with rules | Yes, with rules |
| Trade secrets (reserved price lists, offers, strategies) | **No** | Yes, with caution | Yes, with caution | Yes |
| Proprietary or client code | **No** | Depends on contracts | Depends on contracts | Yes, with caution |
| Employee data | **No** | With great caution | With great caution | With caution |
| CVs for recruitment | **No** | Only with a structured project | Only with a structured project | Only with a structured project |
| Health, criminal, minors' data | **No** | Only after an impact assessment | Only after an impact assessment | Only after an impact assessment |
| Credentials, passwords, keys | **No** | **No** | **No** | **No** |
| Automated decisions about people | **No** | **No** without a high-risk framework | **No** without a high-risk framework | **No** without a high-risk framework |

"With rules" means: entry in the record, notice, written usage rules, training, minimisation (enter only the data the task needs).

## A printable checklist for your accountant/DPO

This is the checklist to take to the meeting with whoever advises you on privacy. Tick what you have, and the rest becomes the to-do list.

```text
CHATGPT AND AI TOOLS AT WORK — CHECKLIST            Date: ______  Completed by: ______

TOOL AND CONTRACT
[ ] We have chosen an authorised tool (name: ________________)
[ ] We use a business plan / API / internal solution, NOT personal accounts
[ ] We have a signed or accepted DPA, with the provider as data processor
[ ] Training on our data is disabled (checked in the settings)
[ ] We know where data is processed (EU / non-EU: legal basis ________)
[ ] We have the list of sub-processors

DOCUMENTATION
[ ] Entry added to the record of processing activities
[ ] Employee notice updated (tool, allowed data, what we record)
[ ] Written usage rules (max 1 page), presented and signed
[ ] If we're a professional firm: client notice about the use of AI

PEOPLE
[ ] Training done and documented (date, participants, content)
[ ] An internal contact for doubts and reports
[ ] Procedure to report data entered by mistake (within 24 hours)

USES TO EXCLUDE OR ASSESS SEPARATELY
[ ] Recruitment / employee evaluation: excluded or a dedicated project
[ ] Health, criminal, minors' data: excluded or an impact assessment
[ ] Client-facing chatbot: transparency ("you are talking to an automated system")
[ ] No analysis of employees' emotions or moods

MONITORING
[ ] Only aggregated technical usage data; no systematic reading of conversations
[ ] Review of the rules scheduled in 6 months (date: ______)
```

Print it, fill it in honestly, and bring it. A serious adviser will appreciate a checklist with half the boxes empty but true more than a generic statement that "everything's fine".

## Alternatives if the answer is no

There are cases where, after the checks, the answer for a certain use is no: the provider doesn't offer an adequate contract, the data is too sensitive, a non-EU transfer isn't acceptable to your clients, or the use touches decisions about people. The concrete alternatives:

1. **Change channel, don't give up.** Moving from the personal account to the business plan solves most common cases.
2. **A European provider.** There are providers of models and chat with processing in the EU and contracts designed for the GDPR, with quality adequate for office tasks.
3. **An internal solution.** An open-weight model on a company server or in a European data centre you control. Initial investment, but data that doesn't leave.
4. **Anonymise first.** For some uses (reviewing the style of a document, structuring a text), you can remove every identifying detail before entering it. It works only if done well, and not for documents where identity is part of the content.
5. **Restrict use.** Allow the tool only for green activities (generic text, marketing, explanations) and forbid it for the rest, until an adequate solution is in place.
6. **Don't use it for that task.** For recruitment or decisions about people, often the right answer today is simply: AI helps write, not decide.

## 30/60/90-day path

**First 30 days — regularise what exists**

- find out who uses what (an anonymous questionnaire is the fastest way);
- choose the authorised tool and channel (business plan, EU provider or internal solution);
- read the DPA on the six points, turn on EU residency and switch off training;
- update the record and notice, write the usage rules.

**Days 30 to 60 — people**

- documented training for each department, with concrete cases;
- usage rules presented and signed;
- blocking unauthorised tools only once the alternative is available.

**Days 60 to 90 — sensitive uses**

- assess separately uses involving special categories or decisions about people;
- if you're a professional firm, update engagement letters and client notices;
- first review: what works, what's missing, what should be forbidden or allowed.

## Costs: estimates

Indicative estimates for an SME of 15–30 people.

| Item | Estimate | Notes |
|---|---|---|
| A provider's business plan | €20–30 per user per month | Often enabling only the heaviest writers is enough |
| Privacy consultancy (DPA, record, notice, rules) | €500–2,000 one-off | Less if you already have a reference adviser |
| Documented training | half a day per department | Internal or external |
| Impact assessment for sensitive uses | €1,000–4,000 | Only if you process special categories or decide about people |
| Internal solution (alternative to the plan) | €4,000–10,000 + maintenance | For companies with sensitive data and at least 20 people |

On the other side: a data breach to handle costs thousands of euros even without a fine, and a client lost over a confidentiality breach can cost much more.

## 3 beginner mistakes that cost money or data

**1. Thinking the business plan "solves everything".** The contract is necessary, not sufficient. Without an entry in the record, a notice, usage rules and training, you're just slightly less exposed. And without rules, the business plan ends up receiving what it shouldn't (credentials, CVs, health data).

**2. Using AI to screen CVs "just as a first filter".** It's exactly the use the AI Act considers high-risk and the GDPR watches most closely. "Just a first filter" means someone was rejected by an automated system without a person reading their CV. If it happens, and the candidate asks for an explanation, you have no answers.

**3. Monitoring employees through the tool.** Reading conversations "to understand how they work" or using usage statistics to assess productivity exposes you to problems with the Workers' Statute and burns trust. Controls are done on rules and aggregated data.

## When NOT to do it (or not yet)

- **When your work is processing health, minors' or criminal data** and you don't yet have a privacy adviser involved: start there, not with the tool.
- **When you want to use it to decide about people** (recruitment, appraisals, sanctions) without a structured project: today the prudent answer is no.
- **When your contracts with clients forbid sharing** their documents or code with third parties: renegotiate first or choose an internal solution.
- **When nobody in the company takes responsibility** for rules, training and reviews: the tool without a reference person becomes no-man's land.

## Practical checklist

- [ ] I've stopped asking "is it legal?" and listed which data and which uses.
- [ ] No personal or confidential data goes through personal accounts.
- [ ] There's a business channel with a DPA, training disabled and, if possible, data in the EU.
- [ ] The record of processing contains the entry for the AI tool.
- [ ] The employee notice is updated; the usage rules are signed.
- [ ] Training has been done and documented.
- [ ] Recruitment and special categories are excluded or handled with a dedicated project.
- [ ] Public-facing chatbots declare they're automated.
- [ ] If I'm a professional firm, clients are informed about the use of AI.
- [ ] The checklist has been shared with the privacy adviser or DPO.

## The verdict

**ChatGPT at work is legal in Italy**, in 2026, under the right conditions: a business channel with a real contract, data preferably processed in Europe, use documented in the record, employees informed and trained, and clear rules on what doesn't go in. It isn't legal — or rather, it isn't defensible — to use personal accounts with clients' data, to decide about people with a model without an adequate framework, or to put health data into a generic tool.

The difference between the two situations isn't the tool, but the work you put around it: a few days to sort out contract, record and rules, half a day of training, an honest checklist taken to whoever advises you. It's little, and it turns a grey area into a use you can explain to a client, an employee or the data protection authority.

If you want to set up the use of AI in your company so that it stands up to scrutiny, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on using ChatGPT at work without losing control are collected in the guide on [ChatGPT at work]({{ '/en/pillar/chatgpt-at-work/' | relative_url }}).

## FAQ

### Is it legal to use ChatGPT at work in Italy?

Yes, under certain conditions: use a business channel (business plan, API or internal solution) with a contract appointing the provider as data processor, document the use in the record of processing, inform and train employees, and set rules on which data may be entered. Using personal accounts with client or employee data is not defensible.

### Did the Italian data protection authority ban ChatGPT?

No, there is currently no general ban. In the past the authority acted against the provider, with temporary restrictions and fines, but business use is lawful if it complies with the GDPR. What matters is how you use it: with which data, under which contract and with which safeguards.

### What's the legal difference between a personal account and a business plan?

With the business plan there's a contract between company and provider appointing it data processor, conversations aren't used for training by default and the company controls the accounts. With an employee's personal account there's no contractual relationship with the company, and data is processed under the terms the employee accepted as a private individual.

### What should I check in the provider's DPA?

Six points: that the provider is named as data processor, that data is used only to deliver the service and not to train models, retention and deletion times, the list of sub-processors, the place of processing and legal basis for any non-EU transfers, and the commitment to notify breaches.

### Does the AI Act ban the use of ChatGPT in SMEs?

No. For office uses such as writing, summarising and translating, the AI Act mainly asks that staff be adequately trained and, for content shown to the public, transparency obligations. The heavy obligations concern high-risk systems, such as those used to select or evaluate people, and some practices are banned, such as emotion recognition at work.

### Can I use ChatGPT to screen CVs?

It's not advisable without a structured project. Recruitment is a high-risk use under the AI Act, CVs often contain sensitive data, and the GDPR protects people from decisions based solely on automated processing. Using AI to write the job ad is fine; using it to reject candidates without oversight and documentation is not.

### Do I need to record the use of ChatGPT in the record of processing?

Yes, if the tool processes personal data. The entry must state purpose, categories of data subjects and data (and those excluded), the tool and the provider appointed as processor, the place of processing, retention and the measures adopted.

### What do I need to tell employees?

Which tool is authorised and for what, which data they may and may not enter, what the company records about their use, that use doesn't serve to evaluate their performance and whom to contact for doubts or reports. The Italian law on artificial intelligence also requires employers to inform workers when using AI systems that concern them.

### Does a professional firm have to tell clients it uses AI?

Yes, the Italian law on artificial intelligence requires professionals to inform clients about the use of AI systems, which may only support intellectual work. A clause in the engagement letter or the client privacy notice is the simplest way to do it.

### What do I do if the answer for a certain use is no?

You can change channel (from personal to business), choose a European provider, adopt an internal solution, anonymise data before entering it where possible, restrict use to activities without personal data, or simply not use AI for that task, as is often right for decisions about people.
