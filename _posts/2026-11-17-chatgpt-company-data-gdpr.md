---
lang: en
permalink: /en/blog/chatgpt-company-data-gdpr/
alt_url: /it/blog/chatgpt-dati-aziendali-gdpr/
title: "Your employees use ChatGPT on clients: what you risk in Italy and how to give them an internal alternative (without pointless bans)"
date: 2026-11-17 07:30:00 +0200
author: "Antonio Trento"
description: "For owners and managers of SMEs: what really leaves the company when an employee pastes an offer into ChatGPT, the GDPR explained in plain language, why bans don't work, the internal alternative, a one-page policy and a 30-day plan with costs."
keywords: ["chatgpt company data gdpr", "chatgpt at work italy", "employee privacy llm", "internal chatgpt alternative", "shadow it openai", "company chatgpt policy"]
image: /assets/images/posts/chatgpt-dati-aziendali-gdpr.jpg
pillar: chatgpt-azienda
related: [/en/blog/private-chatgpt-self-hosted-sme/, /en/blog/gdpr-chatgpt-crm/]
---

## The scenario: the salesperson, the offer, the paste key

It's half past six in the evening. The salesperson has to send an offer to an important client by tomorrow morning, and the email they've written doesn't convince them. They open ChatGPT on their personal, free account and paste everything: the email text, the price list with the reserved discounts, the client company's name, the contact person's name and mobile number, two lines about the problems the client had with the previous supplier. They type: "make it more professional". In thirty seconds they have a better email. They send it, go home, and tomorrow they'll do the same with another client's contract.

They did nothing malicious. They used the handiest tool they had to do their job better. But in those thirty seconds a piece of **company data ended up in ChatGPT, with GDPR implications** that neither they nor the company assessed: a client's personal data, confidential commercial terms, information about a competitor, all on an external service, with a personal account, with default settings.

If you're the owner or manager of an Italian SME reading this piece, it's probably because you've found out it happens in your company too. Or because you suspect it does and don't know how much. This article answers three questions, in plain language: **what you actually risk**, why banning isn't enough, and **how to give employees an alternative** they'll use instead of the personal one, in thirty days, with clear costs.

It isn't a legal treatise and doesn't replace your privacy adviser's opinion. It's the view of someone who builds these systems in companies and has seen what works and what doesn't.

## Is this for you?

It is for you if:

- you have between 5 and 200 people, and some of them write emails, offers, reports, documents for clients;
- you know, or suspect, that someone uses ChatGPT or similar tools with work data;
- you've already sent a ban memo, or are about to, and wonder whether it helps;
- you want to sort the matter out without becoming an expert in privacy or artificial intelligence.

It is not for you if you're looking for a complete legal analysis of the GDPR: here there's what you need to decide, not everything that could be said. It's also not for you if you're a technician looking for how to install a model on a server: for that there's the piece on [how to build a private ChatGPT on two GPUs]({{ '/en/blog/private-chatgpt-self-hosted-sme/' | relative_url }}). Here we talk about decisions, rules and people.

## What really leaves the company (and why "it's only a summary" doesn't save you)

When an employee pastes text into a public chatbot, the text is transmitted to the provider's servers, processed, and — depending on the type of account and settings — kept in the history, possibly reviewed for safety, and in some cases used to improve the models. With free or individually paid personal accounts, use of conversations for training is often on by default, and must be switched off by hand in the settings. With business plans, it's generally off and there's a data processing contract. The difference between the two situations is huge, and the employee is almost always in the first.

The objections I hear most often, and why they don't hold:

- **"They only pasted a summary."** A summary of a contract contains names, amounts, deadlines, conditions. A summary of a complaint contains the client's name and the problem. Removing a few sentences doesn't remove the data.
- **"They didn't include the client's name."** The client is often identifiable anyway: from city and sector, from the contact's name in the signature, from the order number, from the email domain. For the GDPR, data is personal even if it identifies the person *indirectly*.
- **"It's data only we know anyway."** That's exactly the problem: it's data the company processes on behalf of clients or that clients entrusted to it, and which is now somewhere else too.
- **"Everybody does it."** True. It's not a defence: it's a description of the risk.

Besides personal data, **trade secrets** leave too: price lists, margins, confidential terms, strategies, information on competitors, source code, projects. The GDPR doesn't protect them, but your contract with clients often does (confidentiality clauses), and their leakage can cost you more than any fine.

### Table: data that must never end up in an unauthorised cloud chatbot

| Type of data | Examples | Why |
|---|---|---|
| Health data and other special categories | medical certificates, injuries, disabilities, union membership | Enhanced protection under the GDPR; serious breach |
| Criminal-record data | pending charges, proceedings, criminal disputes | Processing allowed only in specific cases |
| Credentials and access codes | passwords, tokens, PINs, OTP codes, configuration keys | Direct access to systems |
| Banking and payment data | clients' and employees' IBANs, card numbers, statements | Fraud risk, financial data |
| Identity documents and tax codes | ID cards, passports, lists of tax codes | Identity theft |
| Bulk client records | CRM exports, contact lists, mailing lists | Volume: from mistake to mass breach |
| Employee data | payslips, appraisals, disciplinary measures | Employment relationship, litigation risk |
| Confidential commercial terms | reserved price lists, discounts, margins, tender offers | Trade secret, contractual clauses |
| Client documents under confidentiality | contracts, projects, technical drawings, code | Confidentiality agreements with the client |
| Non-public corporate information | provisional accounts, extraordinary transactions, negotiations | Economic and reputational damage |

This table applies to **unauthorised** tools: personal accounts, services without a contract, browser extensions installed by anyone. With an authorised tool, with a contract and a correct setup (see below), some rows can be handled. Others, like credentials, never.

## The GDPR in plain language: controller, processor, transfer

To understand the risk you need three concepts. I'll explain them without legal articles.

### The controller: that's you

The company that collects and uses clients' (or employees') data for its own purposes is the **data controller**. It decides why and how the data is used, and is accountable for it. If an employee uses that data in an unforeseen way — for example by pasting it into an external service — responsibility towards the client and towards the data protection authority remains the company's. "They did it on their own initiative" may count for internal relations, not towards the outside world.

### The processor: the provider, if there's a contract

When a provider processes data on your behalf (the cloud ERP, the email service, a company chatbot), it must be appointed as **data processor** with a contract saying what it may do with the data, how it protects it, where it keeps it, when it deletes it. It's often called a DPA (Data Processing Agreement), and serious providers offer it on business plans.

With the employee's personal account **there's no contract between the company and the provider**. The provider isn't your processor: it processes that data under the terms the employee accepted as a private individual. From the company's point of view it's as if the data had been handed to any third party.

### The transfer: where the data ends up

Many artificial-intelligence services process data outside the European Union, often in the United States. The GDPR allows these transfers only with precise safeguards: for the United States there is currently an adequacy framework for companies that sign up to it, but it must be checked provider by provider, and it's a framework that has already been struck down twice in the past. In this case too, without a business contract, you have no control over where and how the transfer happens.

### What can happen, concretely

- **A personal data breach.** If clients' data ends up where it shouldn't, it may be a *data breach*, to be assessed and possibly notified to the authority within 72 hours, and in some cases communicated to the people concerned.
- **Fines.** The GDPR provides for fines up to €20 million or 4% of worldwide turnover. For an SME the real figures are much lower, but they can still reach tens of thousands of euros, plus consultancy and incident-management costs. The Italian data protection authority has been among the most active in Europe precisely on generative AI, including towards providers.
- **Client complaints.** A client who finds out their contract was pasted into a chatbot may claim a breach of confidentiality, ask for damages, or simply leave.
- **Employment issues.** Sanctioning an employee for a use the company never regulated is difficult; monitoring it without the right rules (Italy's Workers' Statute sets precise limits on remote monitoring) can create one more problem.

On top of that, since 2025 the European AI Act asks companies that use AI systems to ensure a sufficient level of **AI literacy** among the staff using them, and the Italian law on artificial intelligence introduced obligations to inform workers when AI enters work processes. They aren't complicated obligations to meet, but they presuppose that the company knows which tools are used and how. With hidden use, it doesn't. If you want to go deeper into the regulatory side with a more technical angle, there's the piece on [GDPR, the AI Act and ChatGPT in the CRM]({{ '/en/blog/gdpr-chatgpt-crm/' | relative_url }}).

## The ban nobody respects (Shadow IT)

The instinctive reaction, once the risk is understood, is the memo: "The use of ChatGPT and similar tools is forbidden". Perhaps with the site blocked on the company network. I've seen this scene many times, and it almost always ends the same way.

**People keep using it, but you can't see it any more.** The site is blocked on the PC? There's the phone. The company phone has restrictions? There's the personal one. Photographing the document with the phone and uploading it to the app is faster than copy-paste. The risk hasn't decreased: it has increased, because now data passes through personal devices, with personal accounts, outside any control, and nobody in the company talks about it openly any more.

This phenomenon has a name: **Shadow IT**. People have a real need, the company doesn't offer a tool, so they get one themselves. With artificial intelligence the need is particularly strong, because the time saved is immediate and visible: a difficult email written in two minutes instead of twenty, a long document summarised in thirty seconds, a decent translation on the fly.

A ban works only in one case: when there's an **authorised alternative** that does the same thing, well enough. At that point the message is no longer "you can't do it", but "do it here, where it's safe". And people, in most cases, choose the official tool, because nobody enjoys working in hiding.

There's also a more pragmatic argument: a ban everybody breaks teaches people that company security rules are optional. It's the worst message you can send, precisely on a topic where you need cooperation.

## Internal alternative: an in-house chat, rules on what may be pasted

The alternative has two parts, both essential: a **tool** and **rules**. The tool without rules moves the problem; rules without the tool produce the ban nobody respects.

### The tool: three paths

**1. A provider's business plan, with a contract.** The main chatbot providers offer plans for companies: company-managed accounts, login with the work account, conversations not used for training, a data processing contract, in some cases the option to keep data in Europe. It's the fastest path: it's activated in days. The provider must be chosen carefully (where the data is, what the contract says, who can access conversations), preferably one with processing in the EU.

**2. A European provider.** There are European providers of models and company chat, with data processed in Europe and contracts designed for the GDPR. Quality is often close to the leaders' for office tasks (writing, summarising, translating into Italian), with fewer complications on data transfer.

**3. An internal chat, on company servers.** An open-source model installed on a server in the company (or in an Italian or European data centre under your control), with an interface similar to ChatGPT, access with the company account, and data that never leaves. It requires an initial investment and someone to maintain it, but gives maximum control and predictable costs. The complete technical project — hardware, models, per-department quotas — is in the piece on the [self-hosted private ChatGPT]({{ '/en/blog/private-chatgpt-self-hosted-sme/' | relative_url }}).

| | Non-EU provider business plan | European provider | Internal chat |
|---|---|---|---|
| Activation time | days | days or weeks | 3–6 weeks |
| Where the data is | depends on plan and contract | in the EU | in the company / chosen data centre |
| Quality on hard tasks | the highest | good | good on office tasks, lower on complex ones |
| Cost | €20–30 per user per month (estimate) | similar or lower (estimate) | initial investment + maintenance |
| Control | contractual | contractual, simpler | total |
| Suited to | companies that need to start immediately | companies careful about data transfer | companies with 20+ people and sensitive data |

There's no right choice for everyone. For many SMEs the sensible path is **to start with a business plan (preferably European) to have the alternative right away**, and consider the internal chat once use is established and you know how much and how the tool is used.

### The rules: what may be pasted

With an authorised tool and a contract, the question changes. No longer "what must I never paste" (answer: almost everything), but "what is appropriate for this tool". A simple three-level rule works better than a long list:

- **Green — always allowed:** texts without personal or confidential data; generic email drafts; public texts; requests for explanations, ideas, outlines.
- **Yellow — allowed in the company tool, never elsewhere:** work documents with client and supplier data (emails, offers, contracts, minutes), reducing personal data to what the task really needs.
- **Red — never, in any AI tool without specific authorisation:** the rows of the table above (health, criminal records, credentials, identity documents, bulk records, employee data).

The yellow level is what makes the tool useful. If everything is red, you're back to the ban.

## A one-page policy employees sign

The policy must fit on one page, be written in plain language, and say what *can* be done before what can't. A twelve-page policy is read by nobody; a one-page one, presented in a meeting and signed, changes behaviour. Here's a draft to adapt with your privacy adviser.

> **Use of artificial intelligence tools — company rules**
>
> **Why these rules.** Artificial intelligence tools help write, summarise and translate faster, and we want you to use them. But the data of our clients, suppliers and colleagues has been entrusted to us, and we must protect it.
>
> **1. Use the company tool.** For work use only [tool name], which you access with your company account. Don't use personal ChatGPT accounts or other services for work, from PC or phone.
>
> **2. What you may enter.** In the company tool you may enter work documents: emails, offers, contracts, minutes, specifications. Enter only the personal data the task really needs.
>
> **3. What you must never enter.** Passwords and access codes; health, criminal or union data; identity documents; IBANs and payment data; client lists or record exports; colleagues' data (payslips, appraisals).
>
> **4. Always reread.** The tool can be wrong with great confidence: numbers, dates, names, legal references. What you send to clients and suppliers is your responsibility: check it.
>
> **5. No decisions about people.** Don't use AI to evaluate, select or sanction people.
>
> **6. Report problems.** If you think you've entered data you shouldn't have by mistake, or a tool behaves strangely, tell [internal contact] immediately. Reporting quickly matters more than never making a mistake: there will be no consequences for good-faith reports.
>
> **7. Your conversations.** Conversations in the company tool are kept for [90] days. The company records only technical usage data (date, volume) to run the service, and does not use this data to evaluate your work.
>
> **8. New tools.** If you want to use another AI tool (browser extensions, apps, online services), ask [internal contact] first.
>
> Date, name, signature.

Three details that make the difference:

- **point 6** (report without fear) is what lets you act within 72 hours if something goes wrong. If people fear sanctions, they don't report, and you find out about the incident when it's too late;
- **point 7** must be true. If you say you don't use the data to evaluate work, the technical setup and managers' behaviour must respect that. On this point, before signing, check with the employment adviser: monitoring of work tools has precise rules;
- the policy is **presented** in a half-hour meeting with concrete examples, not emailed with "read and sign".

## 30-day plan: inventory, guided blocking, alternative, light audit

Here's the path I propose to SMEs, in four weeks. You don't need a project: you need one person to follow it (the owner, the finance manager, internal or external IT) and a few hours a week.

### Week 1 — Inventory, without a witch hunt

1. **Ask, don't investigate.** A five-question anonymous questionnaire: do you use AI tools for work? Which ones? For what? With what kind of data? What would you need? The answers will tell you more than any check, and send the right message: we want to understand, not punish.
2. **Look at aggregated network data**, if you have a firewall or DNS that allows it: traffic volume to the main AI services, without names. It tells you the order of magnitude.
3. **List the use cases** that emerged: which departments, which tasks, which data.

### Week 2 — Choosing and activating the alternative

4. **Choose the tool** (business plan, European provider or internal chat) based on use cases and data involved.
5. **Check the contract**: appointment as data processor, where the data is, training disabled, retention, deletion.
6. **Activate it** for a first pilot group (one department, 5–10 people), with access through the company account.
7. **Prepare the one-page policy** and have your privacy adviser review it.

### Week 3 — Communication and "guided blocking"

8. **A meeting per department** of 30–45 minutes: why, the tool, three concrete examples from their work, the rules, an AI mistake shown live. The policy gets signed.
9. **Guided blocking**: only once the alternative is available, block access to unauthorised AI services from the company network, with a page saying "for work use [company tool], here's the link". The block is a road sign, not a wall.
10. **Extend** the tool to all departments.

### Week 4 — Light audit and adjustments

11. **Second anonymous questionnaire**: do you use the company tool? Do you still use personal ones? Why? What's missing?
12. **Aggregated metrics**: how many people use the tool each week, traffic to external services down or not.
13. **Adjust**: prompts or models prepared for each department's most common uses, answers to questions that came up, any policy exceptions.
14. **Record** everything in the record of processing activities and the privacy documentation.

### After 30 days: 60 and 90

- **At 60 days**: review usage. If the tool is adopted by more than half of the people who write documents, you're on the right track. If it's under a third, the problem is almost always perceived quality or awkward access: ask five people, in person, why they don't use it.
- **At 90 days**: decide whether to stay on the chosen plan or move to an internal solution, based on volumes, costs and data processed. It's also the time to think about more structured uses (assistants for customer care, search over company documents), which are different projects with their own rules.

## How much it costs: the alternative versus the fine and reputation

The figures below are indicative **estimates** for a 30-person SME, to be checked against your case.

| Item | Estimate | Notes |
|---|---|---|
| A provider's business plan (30 users) | €600–900/month | €20–30 per user; often enabling only heavy writers is enough |
| Internal chat (hardware + setup) | €4,000–10,000 one-off | Plus 1–2 days a month of maintenance |
| Privacy consultancy for policy and contract | €500–2,000 | One-off, if you don't already have an adviser |
| Internal time for the 30-day plan | 3–6 person-days | Spread over the month |
| Training (30 minutes per person) | 15 person-hours in total | The real cost is time, not the trainer |

On the other side of the scale:

| Risk | Estimate | Notes |
|---|---|---|
| Handling a data breach (consultancy, notifications, communications) | €3,000–15,000 | Even without a fine |
| Data protection authority fine for an SME | from a few thousand to tens of thousands of € | Depends on seriousness, data involved, cooperation |
| Losing an important client over a confidentiality breach | their annual revenue | Often the heaviest item |
| Time lost by people without the tool (or using it in hiding) | hard to estimate | But it's why they use it |

The comparison isn't only economic. The authorised alternative costs a few hundred euros a month, and in return people work faster in a visible, controlled way. The risk avoided is rare, but when it comes it costs much more. It's insurance that, on top of that, raises productivity.

## 3 beginner mistakes that cost money or data

**1. Buying the licences and that's it.** The company activates a business plan, sends the credentials, and considers the matter closed. No policy, no training, no blocking of personal tools. Result: half the people keep using their personal account "because they're used to it", and the other half paste even passwords into the company tool. You've spent money, and the risk remains.

**2. Reading employees' conversations "to check".** The owner, worried, asks IT to be able to see what people write in the company chat. Besides the problems with the Workers' Statute and the GDPR, the message that comes across is "the company tool is for watching you". People go back to their personal phone, and you're worse off than before. Control is done on aggregated data and rules, not on conversations.

**3. Using unvetted "AI" tools.** A browser extension that summarises emails, an app that transcribes meetings, a service that "improves" documents: many of these tools send content to third parties under unclear terms, and are installed by people without asking. They're often riskier than ChatGPT itself. The policy must cover them too (point 8 of the draft), and someone must answer requests in reasonable time, otherwise people do it themselves.

## When you need a DPO and when internal order is enough

The **DPO** (Data Protection Officer) is mandatory only in some cases: public bodies, companies whose core activity is monitoring people on a large scale or processing special categories of data (health, for example) or criminal-record data on a large scale. For most SMEs — a manufacturer, a technical firm, an agency, a services business — a DPO is **not mandatory**.

That doesn't mean nothing is needed. You need **internal order**:

- an up-to-date record of processing activities (including the AI tool);
- appointments of providers as data processors, with contracts;
- a notice to employees about the tools they use;
- a data breach procedure (who decides, within what time, whom to call);
- a reference privacy adviser, even external and on call.

A DPO (or a more structured privacy adviser) pays off when:

- you process health, minors' or criminal-record data, even if not as your core activity but on a recurring basis;
- you want to use AI for more than office writing: analysing clients' documents, automated support, evaluations;
- you've already had an incident, or an important client asks you for formal guarantees;
- the company exceeds a few dozen people and nobody internally has time to look after privacy.

## When NOT to do it

There are cases where the path described is disproportionate, or wrong:

- **If you're three people and nobody handles sensitive data**, you don't need a project: a business plan with a contract, set up well, and a ten-minute chat about the rules are enough.
- **If nobody in the company writes documents for work** (for example a business with little office activity), the alternative may not be needed: a clear rule and the notice are enough.
- **If you process health or criminal-record data in a structured way** (medical practices, care centres, law firms), don't start from a generic plan: the project must be set up with the privacy adviser from the start, and often the internal solution is the only reasonable one.
- **If the real goal is monitoring employees**, stop. A project born to surveil doesn't produce security, it produces distrust and litigation.
- **If you think you can "solve it by blocking the site"** without an alternative, save yourself the effort: the problem moves to personal phones.

## Practical checklist

- [ ] Anonymous questionnaire done: I know who uses which tools, for what, with which data.
- [ ] Authorised tool chosen, with a data processing contract, data preferably in the EU, training disabled.
- [ ] Access with company account; when a person leaves the company, they lose access.
- [ ] One-page policy written, reviewed by the privacy adviser, presented in a meeting and signed.
- [ ] Green / yellow / red levels explained with examples from each department's work.
- [ ] Blocking of unauthorised services turned on **after** the alternative was available, with a redirect page.
- [ ] Clear reporting procedure, with no consequences for good-faith reports.
- [ ] No reading of individual conversations; only aggregated usage data.
- [ ] Record of processing activities and employee notice updated.
- [ ] Reviews at 30, 60 and 90 days in the calendar.

## The verdict

If your employees paste offers and client records into ChatGPT, the problem of **company data, ChatGPT and the GDPR** isn't solved with a memo. People don't do it out of carelessness: they do it because the tool really helps them, and the company hasn't offered anything better. A ban without an alternative moves use to the personal phone and takes away the only thing you had, the ability to see it.

The solution is simpler than it seems, and takes a month: find out who uses what without a witch hunt, provide an authorised tool with a serious contract and data in Europe or in-house, write a page of rules that says what can be done, explain it with real examples, and only then close the door on personal tools. It costs a few hundred euros a month and a few days of work. It gives you back control over the data, and gives people a way to work better without having to hide.

If you want to set up this path in your company — choosing the right tool for your data, writing rules people respect, assessing whether and when to bring the chat in-house — you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on using ChatGPT and similar tools at work without losing control are in the guide on [ChatGPT at work]({{ '/en/pillar/chatgpt-at-work/' | relative_url }}).

## FAQ

### Is it legal to use ChatGPT at work in Italy?

Yes, if the company does it in a regulated way: with a tool for which there's a data processing contract, clear rules on what may be entered, a notice to employees and an entry in the record of processing activities. The problem isn't the tool itself, but the use of personal accounts with client and employee data, without any agreement between the company and the provider.

### What does a company risk if an employee pastes client data into ChatGPT?

It risks the episode being a personal data breach to be assessed and possibly notified to the authority within 72 hours, possible fines, client complaints for breach of confidentiality and reputational damage. Responsibility towards the outside world remains with the company, which is the data controller, even if the employee acted on their own initiative.

### Is it enough to ban ChatGPT for employees?

No. A ban without an alternative moves use to personal phones and accounts, where the company sees nothing any more: it's the Shadow IT phenomenon. A ban works only if accompanied by an authorised tool that meets the same need, with clear rules on how to use it.

### What's the difference between a personal account and a business plan?

With a business plan the company manages the accounts, people log in with their work account, conversations are generally not used to train the models and there's a contract appointing the provider as data processor. With a personal account there's no relationship between company and provider, and data is processed under the terms the employee accepted as a private individual.

### Which data must never be entered into a chatbot?

No personal data of clients and employees goes into any unauthorised tool. In no tool, authorised or not, do credentials and access codes go, and without specific authorisation neither do health data, criminal-record data, identity documents, payment data, bulk records and employee data such as payslips and appraisals.

### What should a company AI-use policy contain?

Which tool to use for work, what may be entered, what must never be entered, the obligation to check answers, the ban on using AI for decisions about people, how to report a mistake without consequences, how conversations are kept and how to request authorisation for new tools. It must fit on one page and be presented with concrete examples.

### Can employees' conversations with the company chat be monitored?

With great caution and only within the limits set by employment law and the GDPR. The recommended approach is to collect only aggregated, technical usage data, declare it in the notice and not use conversations to evaluate people's work. Before any monitoring you need the employment adviser's opinion.

### Do you need a DPO to use artificial intelligence at work?

In most SMEs a DPO isn't mandatory: it is for public bodies and companies whose core activity is monitoring people on a large scale or processing special or criminal-record data on a large scale. You still need internal order: record of processing activities, contracts with providers, notice to employees, a data breach procedure and a reference privacy adviser.

### How much does it cost to give employees an alternative to ChatGPT?

A business plan costs roughly €20–30 per user per month; an internal chat on company servers requires an initial investment of a few thousand euros plus maintenance. On top of that, a few days of internal work and, if needed, privacy consultancy for policy and contracts. These are small figures compared with the cost of a data breach or losing a client.

### How long does it take to get ChatGPT use at work in order?

A month is enough for SMEs: one week to understand who uses what, one to choose and activate the authorised tool and prepare the policy, one to train people and block unauthorised tools, one to measure adoption and correct. Reviews at 60 and 90 days consolidate and decide the next steps.
