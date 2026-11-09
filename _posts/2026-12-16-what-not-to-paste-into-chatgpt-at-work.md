---
lang: en
permalink: /en/blog/what-not-to-paste-into-chatgpt-at-work/
alt_url: /it/blog/cosa-non-incollare-su-chatgpt-lavoro/
title: "9 things a salesperson must never paste into ChatGPT (with real damage examples, not movie plots)"
date: 2026-12-16 07:30:00 +0200
author: "Antonio Trento"
description: "A concrete list for sales teams: price lists, NDAs, CVs, code, passwords, health data, minors, strategies, financial data. The damage they really do, what you can safely ask AI, how to anonymise in two minutes, a 45-minute workshop script, what to provide instead of ChatGPT and proportionate internal sanctions."
keywords: ["what not to paste into chatgpt at work", "chatgpt client data", "offer confidentiality", "nda and llm", "employee ai training", "anonymise data chatgpt"]
image: /assets/images/posts/cosa-non-incollare-su-chatgpt-lavoro.jpg
pillar: chatgpt-azienda
related: [/en/blog/chatgpt-company-data-gdpr/, /en/blog/is-chatgpt-legal-at-work-italy/]
---

## Why "everybody uses it anyway" isn't a policy

In 2023 some engineers at a large Korean electronics multinational pasted proprietary source code and internal meeting notes into ChatGPT, to get help fixing errors and writing minutes. The news went round the world, the company restricted the use of generative AI tools, and since then that episode is quoted in every security course. Not because those engineers were naïve: because they were doing exactly what thousands of people do every day, in companies of every size.

In sales teams the same thing happens, with different material: the offer for the important client, the price list with reserved discounts, the deal notes, the contract with negotiated clauses, the candidate's CV to present to the client. "Everybody uses it anyway" is true, and that's exactly the problem: **a widespread behaviour without rules isn't a policy, it's distributed risk**.

This piece is meant to be read and shared in a sales team. It lists the **9 things never to paste into ChatGPT at work** (or into similar tools with personal accounts), explains what damage they really do — without movie scenarios —, shows what you can safely ask AI, how to anonymise a text in two minutes, and offers a 45-minute workshop script to train the team. Plus two things that are often missing: what to give salespeople instead of ChatGPT, and how to handle mistakes without theatre.

## Is this for you?

It is for you if:

- you lead or belong to a sales, customer care, recruitment or consulting team;
- you know colleagues use ChatGPT, Gemini or similar tools, and nobody has ever clearly said what's allowed;
- you need to prepare short training on AI use and want concrete material.

It is not for you if you're looking for the full legal framework (it's in the piece on [whether ChatGPT is legal at work]({{ '/en/blog/is-chatgpt-legal-at-work-italy/' | relative_url }})) or the project to give the company an internal tool (it's in the piece on the [internal ChatGPT for SMEs]({{ '/en/blog/internal-chatgpt-self-hosted-company/' | relative_url }})). Here we talk about daily behaviour.

## The 9 categories: price lists, NDAs, CVs, code, passwords, health, minors, strategies, financial data

A premise: the list applies to **ChatGPT and similar tools used with personal accounts**, i.e. without a contract between the company and the provider. With an authorised company tool, under contract and without training on data, some of these categories become manageable with rules. Others stay forbidden everywhere.

### Table of the 9 things

| # | What not to paste | Typical salesperson example | Why it does damage | With an authorised company tool |
|---|---|---|---|---|
| 1 | **Confidential price lists and terms** | "Here's the reseller price list with discounts, make me a table" | Trade secret; if it leaks, clients compare and competitors align | Yes, with caution |
| 2 | **Documents under NDA** | "Summarise the specification the client sent us" | Contract breach: the NDA forbids sharing with third parties | Only if the NDA allows it |
| 3 | **CVs and candidate data** | "Compare these three CVs for the client's position" | Personal data (sometimes sensitive), high-risk use, discrimination | Only with a structured project |
| 4 | **Source code and configurations** | "Why doesn't the client's import script work?" | Intellectual property, often the client's; forgotten credentials inside | Yes, without credentials and if the contract allows |
| 5 | **Passwords, tokens, access codes** | "Fix this configuration file" (with the password in it) | Direct access to systems | **Never** |
| 6 | **Health data** | "Write to the client that their colleague is off sick for…" | GDPR special category, enhanced protection | Only after a specific assessment |
| 7 | **Minors' data** | "Prepare the summer course list with ages and allergies" | Enhanced protection, often with health data | Only after a specific assessment |
| 8 | **Strategies and non-public information** | "Here's the 2027 sales plan and the list of clients at risk" | Competitive damage, privileged information | With great caution |
| 9 | **Clients' tax and financial data** | "Analyse the client's accounts to see if they're solvent" | Confidential data, often under confidentiality agreements | With caution, if authorised by the client |

### The nine, briefly explained

**1. Confidential price lists and terms.** The public price list isn't a problem. The one with reseller discounts, terms for strategic clients, margins, is. It's a trade secret: its value lies in nobody else knowing it.

**2. Documents under NDA.** Specifications, designs, projects, offers received from clients often come with a confidentiality agreement. Almost always the NDA forbids sharing them with unauthorised third parties. An AI service used with a personal account is a third party.

**3. CVs and candidate data.** In teams doing recruitment or staffing, it's the strongest temptation: comparing CVs, writing profiles, a first screening. CVs contain personal and sometimes sensitive data (health, affiliations), and selecting people with AI is a use the European regulation considers high-risk.

**4. Source code and configurations.** For those selling software or technical services: the client's script, their server configuration, the proprietary piece of code. Beyond intellectual property, code often contains forgotten credentials, internal addresses, system names.

**5. Passwords, tokens, access codes.** Never, in any tool. Not "for a moment", not inside a configuration file to fix. If a password ended up in a chat, it must be changed.

**6. Health data.** Illnesses, injuries, disabilities, certificates. Even indirectly ("their contact is in hospital"). They're a GDPR special category, with enhanced protection.

**7. Minors' data.** For those working with schools, courses, sports activities, family services: lists of children, ages, allergies, notes. Enhanced protection, often combined with health data.

**8. Strategies and non-public information.** The sales plan, the list of clients at risk of leaving, negotiations for an acquisition, quarterly results before they're public. The damage is competitive and, in some cases, legal.

**9. Clients' tax and financial data.** Accounts, tax returns, bank statements, debt position, received to assess credit or prepare an offer. Confidential by definition.

## Damage: leak, contract, reputation, competitor advantage in the model

"But in the end what happens?" is the right question. Let's look at the real damage, in order of probability.

**1. Loss of control (always).** The most certain and most underestimated damage. Once pasted, the text is on an external service, in a personal account. The company doesn't know it's there, can't delete it, can't prove what left. If one day a client asks "where did our documents end up?", there's no answer.

**2. Contract breach (often).** Many contracts and NDAs explicitly forbid sharing information with third parties without authorisation. A client only needs to find out — through an audit, a direct question, a salesperson who leaves and talks — for the relationship to be at risk. In regulated sectors (finance, health, public administration) the issue is even more serious.

**3. Privacy problem (often).** If there's personal data inside, the company has processed it without the required safeguards. It can be a breach to assess and, in the most serious cases, to notify to the authority. The full picture is in the piece on [ChatGPT, company data and the GDPR]({{ '/en/blog/chatgpt-company-data-gdpr/' | relative_url }}).

**4. Reputational damage (sometimes).** The day it becomes known that "company X puts clients' contracts into ChatGPT", the damage isn't measured in fines but in trust. For a service company, it's the most expensive thing.

**5. "Competitor advantage in the model" (rarely, but not zero).** With personal accounts, conversations may be used to train models, if the user hasn't switched the option off. That a specific detail of your price list "resurfaces" in an answer to a competitor is unlikely, and providers declare measures to prevent it. But it's not a risk a company should choose to run, and the real point remains the first: you have no control.

That's the honest list. No movie scenarios with hackers stealing company strategy from ChatGPT. The real damage is more banal and more likely: a breached contract, an angry client, a data breach to handle.

## What you CAN ask (anonymised text, structure, tone)

The message must not be "don't use AI". It must be "use it like this". Here's what a salesperson can ask without risk, even with a generic tool:

- **Structure**: "How do you structure an offer for an annual maintenance service? Which sections should it have?"
- **Tone**: "Rewrite this sentence more politely but firmly: 'we can't apply the requested discount'."
- **Generic templates**: "Write a follow-up email template after a trade fair, with blanks to fill."
- **Objections**: "What are a purchasing manager's typical objections to a 5% price increase, and how to answer?"
- **Explanations**: "Explain in simple words what reverse charge is, I need to explain it to a client."
- **Anonymised text**: the client's email, after removing names, companies, amounts and references (see below).
- **Public text**: the company presentation published on the website, the public product sheet.

With the **authorised company tool** (contract, training disabled, data in the EU or in-house), you can do much more: work on real client documents, summarise deals, prepare offers. Categories 5 (passwords), 6 and 7 (health and minors) stay excluded unless specifically assessed.

## How to anonymise in 2 minutes (and when it isn't enough)

Anonymising doesn't mean changing the client's name and leaving everything else. It means removing **everything that lets you work out who it's about** and **everything that's confidential**. Here's a practical example.

### Anonymisation example

The original text, which the salesperson would like to paste to get help replying:

```text
Good morning Andrea,
as I mentioned to Giulia Ferri last week, Officine Ferri S.r.l. of Lumezzane
cannot accept the 7% increase on the 2027 maintenance contract (currently €18,400/year).
Your competitor TecnoService has offered us the same service for €16,900.
If you don't revise the terms by 15 January we'll consider changing supplier.
Kind regards, Marco Ferri – Technical Director – 335 1234567
```

The anonymised version:

```text
Good morning [CONTACT],
as I mentioned to your colleague last week, [CLIENT], a medium-sized manufacturing
company, cannot accept the [X]% increase on the annual maintenance contract.
A competitor has offered us the same service at a price about 8% lower.
If you don't revise the terms by [DATE] we'll consider changing supplier.
Kind regards, [NAME] – [ROLE]
```

What was done, in order:

1. **People's names** replaced with a placeholder (Andrea, Giulia Ferri, Marco Ferri).
2. **Company name and place** replaced with a generic description (name and town together identify the client with certainty).
3. **Exact amounts** removed; the **proportion** remains (about 8% less), which is what's needed to write the reply.
4. **Competitor's name** removed: it's confidential information and not needed.
5. **Contacts** (phone) removed.
6. **Precise dates** replaced, if they identify the contract.

To ask AI "how do I reply so as to keep the client without giving in on the whole price?", the anonymised version works perfectly. The answer comes back with placeholders, and the salesperson fills them in.

### When anonymising isn't enough

- **When the content itself is the secret**: a price list remains a price list even without the client's name; a specification under NDA remains confidential even without the logo.
- **When details identify anyway**: "the only company in the district making valves for the naval industry" identifies the client even without a name.
- **When there's too much text**: anonymising a 40-page contract is long work and easy to get wrong. There you need the company tool, not anonymisation.
- **When it's health or minors' data**: the risk of leaving an identifying detail is too high.

## 45-minute workshop for the sales team

Here's the script I use to train a sales team. It works in person or on a video call, with 5–20 people. You need a projector and the company AI tool (or, if not yet available, ChatGPT with invented texts).

### Workshop script

```text
WORKSHOP "AI YES, BUT LIKE THIS" — 45 minutes

[0–5]   OPENING (sales manager)
        "We all use AI and that's fine. Today we decide together how to use it without
         getting ourselves and our clients into trouble." No sermons.

[5–12]  THE CASE (trainer)
        A realistic case: the offer pasted with names, amounts and competitor.
        Question to the room: "what left the company?"
        Listed together: names, client, prices, competitor, strategy.

[12–20] THE 9 THINGS (trainer)
        Table projected. For each, a question: "has this happened to you?"
        Goal: recognise your own cases, not memorise a list.

[20–30] ANONYMISATION EXERCISE (in pairs)
        Each pair gets an invented but realistic client email.
        5 minutes to anonymise it. Comparison: what identifying detail remained?

[30–38] WHAT YOU CAN DO (live demo)
        With the company tool: tone of a difficult reply, structure of an offer,
        handling a price objection. An AI MISTAKE is also shown (an invented
        figure) to explain why you always reread.

[38–43] THE RULES AND THE TOOL (manager)
        Which tool to use, where to find it, the 9 things, what to do if you make a
        mistake (report it the same day, without fear).

[43–45] QUESTIONS AND SIGNATURE
        Signing the rules sheet. Collecting use cases to improve.
```

Three details that make the workshop work:

- **The sales manager opens and closes**: if only IT or privacy do it, the message is "rules imposed from outside".
- **The anonymisation exercise is the key moment**: people discover by themselves how easy it is to leave an identifying detail.
- **The AI mistake shown live** convinces people to reread what they send to clients more than any slide.

## What to provide instead: internal tool or vendor with a DPA

Banning without an alternative doesn't work: people will keep using ChatGPT from their phone. The workshop makes sense only if, at the end, you can say "**use this**".

The alternatives, in brief:

- **A provider's business plan**, with a data processing agreement (DPA), conversations not used for training, company-managed accounts, possibly with data in Europe. Switched on in a few days.
- **A European provider** with processing in the EU and a contract designed for the GDPR.
- **An internal tool**, on company servers or in a European data centre under your control, possibly connected to company documents with the right permissions. The project is described in the piece on the [internal ChatGPT for SMEs]({{ '/en/blog/internal-chatgpt-self-hosted-company/' | relative_url }}).
- **AI features inside the CRM**, for those already working in a CRM: deal summaries, email drafts, without data leaving the system. I covered it in the piece on [Salesforce automations before AI]({{ '/en/blog/salesforce-automation-sme/' | relative_url }}).

With one of these tools, the list of 9 things shortens: categories 1, 2, 4, 8 and 9 become manageable with rules, 3, 6 and 7 need specific assessments, 5 stays forbidden always.

## Proportionate internal sanctions (without theatre)

Sooner or later someone will make a mistake. How the company reacts decides whether people keep reporting mistakes or hide them.

A proportionate scale, to be agreed with whoever handles HR and employment:

- **Mistake reported spontaneously** (I pasted something I shouldn't have, I'm telling you): no sanction. Assess the damage, change passwords if needed, handle any data breach. It's exactly the behaviour you want to encourage.
- **First mistake discovered by others**, without intent, before training: a conversation and the training.
- **Mistake after training and signing the rules**: formal warning, according to internal rules and the applicable contract.
- **Serious, deliberate breach** (exporting the whole client archive to an external service, sharing health data, deliberately bypassing the company tool): disciplinary measure according to employment contract rules.

What to avoid: security "theatre". Threatening memos, surprise checks on chats, exemplary sanctions for a small mistake. They work for a week, then people stop reporting and keep using AI in secret. Remember too that monitoring of work tools in Italy has precise rules: before any check, get an employment adviser's opinion.

## A concrete case: a distributor's sales team

An industrial components distributor with 12 salespeople, no rules on AI. An anonymous questionnaire reveals that 10 out of 12 use ChatGPT with their personal account, at least a few times a week, to write offers and reply to clients. Seven admit pasting price lists or client emails with names and prices.

**What was done in a month.** A business plan with a contract and EU data for the 12 salespeople. Rules written on one page, with the 9 things. The 45-minute workshop, opened by the sales director. Access to personal ChatGPT blocked from the company network, but only after the company tool was available, with a page pointing to the new tool. Five request templates prepared together with the salespeople for the most frequent cases (reply to a price objection, follow-up after a visit, presenting a new product, polite reminder, deal summary).

**After three months.** The second anonymous questionnaire says 11 out of 12 use the company tool, one still doesn't use AI. Two salespeople spontaneously reported pasting by mistake a client's data into the company tool (the right place, but with more data than necessary): no sanction, a chat about minimisation. The sales director notices offers are more polished and go out sooner.

## 30/60/90-day path

**First 30 days**: anonymous questionnaire, choice of the authorised tool, one-page rules, workshop with the sales team.

**Days 30 to 60**: blocking unauthorised tools with redirection, request templates prepared with salespeople, extension to other teams (customer care, finance).

**Days 60 to 90**: second anonymous questionnaire, review of the rules on emerging cases, decision on the most sensitive uses (recruitment, client data in volume).

## 3 beginner mistakes that cost money or data

**1. Running the training without providing the tool.** The workshop explains what not to do, and then salespeople go back to their desks with no alternative. After a week they use ChatGPT as before, just with a bit of guilt.

**2. Believing removing the name is enough.** "I removed the client's name" while town, sector, amounts, the competitor's name and a signature with a mobile number remain. The anonymisation exercise in the workshop exists precisely to show how much remains.

**3. Punishing whoever reports.** The first salesperson who admits a mistake and gets a formal warning teaches everyone else never to report again. From then on mistakes still happen, but the company doesn't know about them.

## When NOT to do it (or do it differently)

- **If the team is 2–3 people**, you don't need a workshop: a 15-minute chat with the table and the company tool is enough.
- **If salespeople handle health data** (medical reps, medical device sales, social care services), the training must be prepared with the privacy adviser and the tool chosen more carefully.
- **If there's no authorised tool yet**, postpone the workshop a few weeks and switch one on meanwhile. Training without an alternative is not very effective.

## Practical checklist

- [ ] I've run an anonymous questionnaire to know who uses what.
- [ ] There's an authorised AI tool, with a contract and training disabled.
- [ ] The 9 things are on one page, with examples from our work.
- [ ] The 45-minute workshop has been done, opened by the sales manager.
- [ ] The anonymisation exercise has been done in pairs.
- [ ] Salespeople have request templates for the most frequent cases.
- [ ] There's a procedure to report a mistake the same day, with no sanctions for whoever reports.
- [ ] The scale of sanctions is proportionate and agreed with whoever manages staff.
- [ ] Unauthorised tools are blocked only after the alternative is available.
- [ ] At 90 days there's a second questionnaire to measure the change.

## The verdict

The **things not to paste into ChatGPT at work** are nine, and none is surprising: confidential price lists and terms, documents under NDA, CVs, code, passwords, health data, minors' data, strategies, clients' financial data. The problem isn't knowing them: it's that nobody ever clearly told a team that uses AI every day to work better.

The solution isn't banning and threatening. It's providing an authorised tool, one page of rules, 45 minutes of training with a real exercise, and a climate in which whoever makes a mistake says so straight away. That way AI stays what it should be for a salesperson — help to write better and faster — without becoming the channel through which client data leaves.

If you want to prepare your sales team to use AI without risk, with the right tool and rules that get respected, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on ChatGPT at work are in the guide on [ChatGPT at work]({{ '/en/pillar/chatgpt-at-work/' | relative_url }}).

## FAQ

### What should never be pasted into ChatGPT at work?

With a personal account: confidential price lists and terms, documents covered by confidentiality agreements, CVs and candidate data, proprietary source code, passwords and access codes, health data, minors' data, strategies and non-public information, clients' tax and financial data. Passwords and access codes must not be entered into any tool.

### What happens if an employee pastes client data into ChatGPT?

The company loses control over that data, which ends up on an external service without a contract. There may be a breach of confidentiality agreements with the client, a personal data breach to assess and possibly notify to the authority, and reputational damage if it becomes known.

### Is removing the client's name enough to use ChatGPT safely?

No. You must remove everything that identifies the person or company, such as names, places, exact amounts, competitors' names, contacts and dates, and everything confidential. In some cases, such as price lists, documents under NDA or health data, anonymisation isn't enough and an authorised company tool is needed.

### What can a salesperson safely ask AI?

The structure of an offer, the tone of a difficult reply, generic email templates, handling objections, explanations of concepts, work on anonymised or public text. With an authorised company tool you can also work on real documents, within internal rules.

### Are ChatGPT conversations used to train the model?

With personal accounts, often yes, unless the user switches the option off in settings. With business plans and APIs, generally not, by default and by contract. That's why use with company data should go through company tools.

### How do you organise AI training for salespeople?

45 minutes are enough: an opening by the sales manager, a realistic case, the table of things not to paste, an anonymisation exercise in pairs, a live demo of what can be done and of an AI mistake, the rules and the authorised tool, and signing the rules.

### What should employees be given instead of ChatGPT?

A provider's business plan with a data processing contract, a European provider, an internal tool on company infrastructure or AI features built into the CRM. What matters is that it's as convenient as ChatGPT, otherwise people will keep using personal accounts.

### How should an employee who pasted confidential data be sanctioned?

Proportionately: no sanction for whoever reports the mistake spontaneously, a conversation and training for a first mistake without intent, a formal warning for mistakes after training, disciplinary measures only for serious, deliberate breaches, according to the employment contract. Punishing whoever reports leads people to hide mistakes.

### Can ChatGPT and similar tools be used to compare CVs?

It's not advisable with generic tools and without a structured project. CVs contain personal data, sometimes sensitive, and selecting people with artificial intelligence is considered a high-risk use by the European regulation, with specific oversight and documentation obligations.

### What should you do if a password ended up in a chat with AI?

Change it immediately, along with any other credential in the same text, and report it to the internal contact. Passwords must never be entered into AI tools, not even inside configuration files to fix.
