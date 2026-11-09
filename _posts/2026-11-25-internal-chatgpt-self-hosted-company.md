---
lang: en
permalink: /en/blog/internal-chatgpt-self-hosted-company/
alt_url: /it/blog/chatgpt-interno-azienda-self-hosted/
title: "How to build an internal ChatGPT for an SME without sending your documents to America"
date: 2026-11-25 07:30:00 +0200
author: "Antonio Trento"
description: "The project for an internal ChatGPT that works on company documents, explained to an owner: two layers (chat and documents), where files live and who sees them, EU cloud or office server, what it does well and what it doesn't, permissions, costs for 5, 25 and 80 people, 10 rules and a 60-day plan."
keywords: ["internal chatgpt self hosted company", "private company gpt", "local llm sme", "copilot 365 alternative", "internal document chat", "ai assistant company documents"]
image: /assets/images/posts/chatgpt-interno-azienda-self-hosted.jpg
pillar: chatgpt-azienda
related: [/en/blog/company-pdf-search/, /en/blog/private-chatgpt-self-hosted-sme/]
---

## What employees mean by "our own ChatGPT"

When someone in an SME says "we'd like our own ChatGPT", they usually mean two different things, mixed together.

The first is **a writing tool**: fixing an email, summarising minutes, translating a datasheet, drafting an offer. Exactly what they already do with ChatGPT on their phone, but without the fear of doing something wrong with clients' data.

The second, the one that excites people most, is **a tool that knows the company**: "I ask what the returns procedure is and it tells me", "I ask what terms we have with supplier X and it tells me", "I ask how to set up machine Y and it pulls out the right paragraph of the manual". In other words: **ChatGPT, but on our files**.

This piece explains how to build an **internal ChatGPT for the company, self-hosted or at least under your control**, starting from what employees really want. It's written for the owner or manager who has to decide, not for the technician who'll install it: no configurations, but a "boxes" architecture anyone can follow, what it can and can't do, costs for companies of different sizes, and a 60-day plan. The technician will find the details on hardware and models in the piece on [how to build a private ChatGPT on two GPUs]({{ '/en/blog/private-chatgpt-self-hosted-sme/' | relative_url }}).

The premise, stated upfront: the first layer (writing) is relatively easy. The second (answering on documents) is where the difference is made, and where projects fail when treated as an installation rather than as work on how documents are organised.

## Is this for you?

It is for you if:

- you have between 5 and 100 people who spend part of the day looking for information in documents, folders and emails;
- you have procedures, manuals, price lists, contracts, datasheets that exist but that nobody finds at the right moment;
- you don't want those documents ending up on an American provider's servers without control;
- you're considering Copilot or similar tools and wonder whether there's an alternative with the data in-house.

It is not for you if your documents are few and all in two people's heads: the problem there is organisational, not technological. And it is not for you if you want something to switch on in an afternoon: the first layer yes, the second no.

## Two layers: chat vs company documents

The most useful thing to understand, before talking about servers and costs, is that an "internal ChatGPT" is made of **two layers** with very different requirements.

### Layer 1: general chat

An assistant that writes, summarises, translates, explains. It works on what the user pastes or uploads at that moment. It knows nothing about the company until someone tells it in the conversation.

- **What it needs:** a language model, a ChatGPT-like interface, login with the company account.
- **Difficulty:** low. It's switched on in a few days (EU cloud with a contract) or a few weeks (internal server).
- **Main risk:** people putting in data they shouldn't; handled with rules and training.

### Layer 2: answers on company documents

The assistant that, when you ask "what's the returns procedure?", **searches the company's documents**, finds the relevant paragraphs, and answers **citing the source** ("from procedure PR-07, updated March 2026, paragraph 3"). Technically it's called RAG (retrieval-augmented generation): first search, then answer using what was found.

- **What it needs:** on top of layer 1, a system that reads documents from their folders, indexes them for search, respects permissions, and a way to show sources.
- **Difficulty:** medium or high. Not because of the technology, but because of the documents: where they are, how up to date, who may see them.
- **Main risk:** the assistant answering confidently from an old document, or showing someone a document they shouldn't see.

The practical advice: **start with layer 1 for everyone, and with layer 2 on a small scope** (for example: quality procedures, or one department's technical manuals). Layer 2 on "all the company's documents" at the first attempt is the surest way to disappoint everyone.

## Boxes architecture (for non-technical people)

Here's how it's built, in six boxes. You don't need to know how each box works: you need to know they exist, what they do and where they sit.

```text
        ┌──────────────────────────┐
        │  1. COMPANY LOGIN         │  ← you sign in with your work account (Microsoft, Google, internal)
        └────────────┬─────────────┘
                     ▼
        ┌──────────────────────────┐
        │  2. CHAT INTERFACE        │  ← the ChatGPT-like "face", in the browser
        └────────────┬─────────────┘
                     ▼
        ┌──────────────────────────┐
        │  3. DIRECTOR              │  ← decides: general question or question on documents?
        │     (+ permission check)  │     and checks what YOU may see
        └──────┬─────────────┬─────┘
               ▼             ▼
  ┌──────────────────┐  ┌──────────────────────────┐
  │ 4. MODEL          │  │ 5. DOCUMENT INDEX         │  ← "searchable" copy of authorised
  │    (the "brain")  │  │    + citations            │     documents, refreshed every night
  └──────────────────┘  └────────────┬─────────────┘
                                     ▲
                        ┌────────────┴─────────────┐
                        │ 6. YOUR FOLDERS            │  ← NAS, Drive/SharePoint, ERP
                        │    (stay where they are)   │     (read-only)
                        └──────────────────────────┘
```

Line by line:

1. **Company login.** No new accounts: people sign in with their work account, and when they leave the company they lose access automatically.
2. **Chat interface.** What people see. It must be as convenient as ChatGPT, or they won't use it.
3. **Director.** The piece of software that receives the question, works out whether it needs to search documents, checks which documents the user may see, and passes only those to the model.
4. **Model.** The "brain" that writes answers. It can sit on an office server, on a server in an Italian or European data centre, or with a European cloud provider under contract.
5. **Document index.** A "searchable" copy of authorised documents, with the references needed to cite the source. It updates automatically (for example every night).
6. **Your folders.** Documents stay where they are: the system reads them, it doesn't move or change them.

The thing to notice: **no box sends documents outside**, if the model and the index sit on your own or European infrastructure under contract. That's the difference with "I upload the PDFs to ChatGPT".

## Where files live (NAS, Drive, ERP) and who sees them

Before any technical choice, you need an honest snapshot of **where documents are** and **who can see them today**. It's the least glamorous work and the one that decides the outcome.

Typical situations:

- **NAS or file server in the office**, with folders per department and permissions (sometimes tidy, often not).
- **Cloud Drive or SharePoint**, with shared folders and "anyone with the link" links.
- **ERP or CRM**, with documents attached to clients, orders, cases.
- **Email**, where a huge part of company knowledge lives (and which is best left out, at least at first).
- **People's heads**: procedures never written down, which no system will ever index.

Three questions to ask for each source:

1. **Is it up to date?** A "Procedures" folder with three versions of the same procedure and no indication of which is valid will produce wrong answers. The assistant doesn't know which version is the good one, unless someone tells it.
2. **Who can see it today?** If the HR folder is accessible to everyone by mistake, the assistant will make that obvious within a few days ("I ask how much my colleague earns and it tells me"). Better to find out first.
3. **Is it really needed?** Not everything should be indexed. Procedures, manuals, internal price lists, client FAQs yes. Ten years of correspondence archives, probably not.

The outcome of this work is a list of **authorised sources**, each with an owner. It's also the basis for building a [company document search that works]({{ '/en/blog/company-pdf-search/' | relative_url }}): find first, then answer.

## EU cloud with a contract vs office machine / Italian VPS

The "model" and the "index" must run somewhere. There are three realistic options for an SME, each with pros and limits.

**1. European cloud provider with a contract.** You use a model offered by a provider that processes data in the EU, with a contract appointing it data processor and excluding training on your data. The document index can sit with the same provider or on your own server.

- Pros: no hardware, high quality, quick activation.
- Cons: cost grows with use, dependence on the provider, documents (or pieces of them) pass through its servers.

**2. Server in an Italian or European data centre (VPS or dedicated server with GPU).** You (or your supplier) install model and index on a rented server in Italy or the EU.

- Pros: high control, no hardware in the office, predictable costs.
- Cons: rented GPU servers are expensive; someone has to manage them.

**3. A machine in the office.** A server with one or two graphics cards in the technical room.

- Pros: maximum control, data never leaves the building, fixed cost.
- Cons: initial investment, energy, failures to manage, you need a suitable space and someone to look after it.

For an SME without internal IT, the combination I most often recommend is: **model with a European provider under contract or on an EU server, document index on a server under your control**, permissions managed by the "director". The office machine makes sense from 20–30 people upwards, when use is heavy and someone can manage it.

A note on Copilot and similar: assistants built into office suites do something similar to layer 2 on documents already in the suite, with the suite's permissions. They can be a good choice if all documents are there and permissions are tidy; they cost per user and tie you even more to the suite. The reasoning about permissions and old documents applies identically.

## What it does well (drafts, summaries, cited Q&A) and what it doesn't

Wrong expectations kill more projects than technical problems. Here's what to expect, honestly.

**What it does well:**

- **Drafts**: emails, letters, offers, communications, from instructions and documents provided.
- **Summaries**: minutes, long contracts, technical documentation, email threads.
- **Questions with cited answers**: "what's the returns procedure?", "what warranty do we give on product X?", "how do you change format on line 2?", with the reference to the document and paragraph.
- **Translations** of technical and commercial text.
- **Orientation**: "where do I find the holiday request form?", "who handles foreign shipments?", if there's a document that says so.

**What it doesn't do (and mustn't pretend to):**

- **Professional opinions**: legal, tax, medical, technical with liability. It can summarise what a document says, not decide on behalf of whoever is accountable.
- **Numbers without a source**: "how much have we invoiced client X?" isn't a question for the chat; it's a question for the ERP. If the assistant answers with a number it can't cite from a document or system, consider the number invented.
- **Knowing things that aren't written**: if the procedure doesn't exist or is in one person's head, the assistant doesn't know it. The risk is that it invents a plausible one; that's why the "no source, no answer" rule is essential.
- **Telling the right version by itself**: if the folders contain three versions of the same procedure, the assistant may cite the wrong one. Cleaning up sources is human work.

The rule I put in every project: **on company questions, the assistant answers only if it finds a source, and shows it**. If it doesn't find one, it says so ("I found no documents on this topic"). An assistant that says "I don't know" is far more useful than one that always answers.

## Access: not everyone sees salaries

This is the point that turns a useful project into an incident. If the document index contains the HR folder, and the director doesn't check permissions, someone will ask "how much does Rossi earn?" and get an answer. It happens, and it almost always happens in the first two weeks.

The rules:

- **The assistant sees only what the user can already see.** If Mario has no access to the "Administration/Salaries" folder on the NAS, the assistant must not use those documents to answer Mario. Permissions are inherited from sources, not reinvented.
- **Some folders stay out of the index**, full stop: payslips, staff appraisals, health documents, disputes. The assistant doesn't need to know them.
- **Permissions are checked before going live**, with a simple test: take three users from different departments and ask the same ten "sensitive" questions. If someone sees something they shouldn't, the problem is in the folder permissions, not in the assistant: fix it there.
- **The log records** which documents were used to answer which user (without recording conversation content), so you can reconstruct what happened if a doubt arises.

Often the internal ChatGPT project becomes, in practice, the project that **finally tidies up folder permissions**. It's an excellent side effect.

## Costs: 5 / 25 / 80 people (estimates)

Here are three scenarios, with indicative estimates. Model and hardware prices change quickly: use the figures as orders of magnitude.

| Item (estimates) | 5 people | 25 people | 80 people |
|---|---|---|---|
| Recommended solution | EU cloud with contract + index on a small server | EU or office server for the model, internal index | Office (or dedicated EU) server with GPU, internal index |
| Initial setup (project, sources, permissions, interface) | €3,000–6,000 | €8,000–15,000 | €15,000–30,000 |
| Hardware (if in the office) | — | €3,000–5,000 (optional) | €6,000–12,000 |
| Monthly cost (cloud model or rented server + energy) | €50–150/month | €150–500/month | €300–900/month |
| Maintenance and source updates | 0.5 days/month | 1–2 days/month | 2–4 days/month |
| Comparison: licences for suite-integrated assistants | ~€150/month | ~€750/month | ~€2,400/month |

(The licence comparison uses about €30 per user per month, as an indication; check current price lists.)

Two observations:

- **Under 10 people**, the full project with layer 2 is justified only if documents are many and searched often. Otherwise layer 1 with a serious contract is enough, plus good folder organisation.
- **The real cost isn't the model**: it's the work on sources (cleanup, owners, permissions). It's also what keeps its value if one day you change technology.

## The 10 usage rules

To hand to everyone, on one page.

1. **For work use the company assistant**, not personal ChatGPT or similar accounts.
2. **On company questions, always look at the cited source.** If there's no source, the answer isn't reliable.
3. **If the source is old or wrong, report it** to the document's owner: that's how the assistant improves.
4. **Don't ask for numbers that live in the ERP** (revenue, stock, deadlines): ask the ERP.
5. **Reread everything you send outside.** The assistant writes well, but can get details wrong very confidently.
6. **Don't enter passwords, access codes, health data** or documents you have no right to share.
7. **Don't use it for decisions about people** (appraisals, recruitment, disciplinary measures).
8. **If you see a document you shouldn't, stop and report it**: it's a permissions problem to fix at once.
9. **Your conversations stay yours**: the company records only technical usage data and doesn't use it to evaluate your work.
10. **Suggest improvements**: documents to add, frequent questions without answers, useful prompts for your department.

## A concrete case: the technical office and the machine manuals

To make this less abstract, here's how a real first scope goes in a 30-person manufacturer (the pattern is typical, details simplified).

**The starting point.** The technical office and customer support answer questions every day about machines sold: how to make a certain adjustment, what a spare part's code is, what an alarm means. The answers are in the manuals (200–400-page PDFs, in Italian and English), in a folder of technical notes written over the years, and in two senior technicians' heads. Each question costs 5 to 20 minutes of searching, and often ends with "ask Franco".

**The chosen scope.** Only manuals of machines in production and technical notes from the last five years. Out: contracts, offers, admin documents, email. Access: technical office and support, 8 people.

**The work on sources (2 weeks).** It was the bulk of the project. Of 340 files in the manuals folder, 90 were old versions or duplicates: archived. Technical notes had titles like "note_final_v3_ok.docx": renamed with machine, topic and date. Each folder got an owner, tasked with reporting when a new version of a manual comes out.

**The pilot (3 weeks).** The 8 people used the assistant for daily questions, noting in a sheet wrong answers or answers without a source. In the first week about one answer in five had something to correct, almost always because of the sources: an old manual left in a subfolder, a note contradicting the manual without saying which was valid. Once sources were fixed, by the third week reports had dropped to a handful.

**The result.** "Manual" questions get an answer with the page reference in under a minute. Questions requiring experience still go to Franco, but Franco gets far fewer interruptions. And, an unplanned side effect, for the first time the company knows which manuals are valid.

## What breaks after a few months (and how you notice)

An assistant on documents doesn't break like a printer: it slowly gets worse. The signs to watch:

- **Answers cite old documents.** The most common sign: a new version of a procedure came out, but the old one stayed in the folder. Remedy: the source owner archives the superseded version; the index updates that night.
- **"I found no documents" answers increase.** People ask about new topics (a product just launched, a procedure just changed) that aren't documented yet. It's not an assistant defect: it's the list of missing documents. Worth looking at once a month.
- **People stop using it.** If use drops after the first months, ask five people why. Typical answers: it's slow, sources are old, it doesn't find my department's things. All fixable, but only if someone asks.
- **Someone sees something they shouldn't.** Usually because a folder was moved or shared differently. Deal with it immediately: remove the source from the index, fix permissions, check who may have seen what.
- **Cost grows.** If you use a pay-per-use cloud model and use increases, the monthly cost rises. It's a good sign (people use it), but worth watching to decide whether to move to a fixed-cost solution.

Half an hour a month from the reference person on these five points keeps the assistant useful. Without it, after six months it becomes a tool people no longer trust.

## 60-day plan and change management (a ban isn't enough)

The plan I propose is in two 30-day phases. The point isn't just installing: it's getting people to use it instead of personal tools.

### Days 1–30: layer 1 and sources

- **Week 1**: anonymous questionnaire on how people use AI today and what they search for most in documents. Choice of solution (EU cloud, EU server, office).
- **Week 2**: layer 1 (general chat) switched on with company login and a proper contract. Written usage rules.
- **Week 3**: 45-minute training per department, with real cases. Inventory of sources for layer 2: which folders, who owns each, which stay out.
- **Week 4**: cleanup of the first scope's sources (old versions archived, documents dated, owners assigned). Folder permissions checked.

### Days 31–60: layer 2 on a small scope

- **Week 5**: indexing of the first scope (for example quality procedures + technical manuals). Permission tests with users from different departments.
- **Week 6**: pilot with one department. Collection of unanswered questions and answers with the wrong source.
- **Week 7**: fixes on the sources (not on the model). Extension to a second department.
- **Week 8**: review with numbers: how many people use it, which questions, how many answers with a source, how many "not found". Decision on the next scope.

### Change management, in three sentences

- **A ban isn't enough**: without a convenient alternative, people will keep using their personal phone.
- **Show a mistake live** during training: nothing convinces people more to look at sources.
- **Give every source an owner**: without someone updating documents, after three months the assistant answers with old information and loses credibility.

## 3 beginner mistakes that cost money or data

**1. Indexing "everything" at the first attempt.** The whole NAS is connected and everyone is given access. In the first two weeks confidential documents become visible to people who shouldn't see them, answers are based on old versions, and the assistant answers some questions by inventing. Trust burns immediately and is hard to win back.

**2. Choosing the technology before looking at the documents.** A server is bought or a service subscribed, and only afterwards does it emerge that procedures exist in three versions, nobody knows which is valid, and half the knowledge isn't written down. The work on sources has to be done anyway: doing it first saves months.

**3. Letting the assistant answer without a source.** To seem more useful, the assistant is configured to always answer. Result: plausible, wrong answers on company procedures, taken as true. Better an "I found no documents" than an invented procedure.

## When NOT to do it

- **When documents are few and clear**: with twenty well-written procedures in a tidy folder, good search and the habit of using it are enough.
- **When nobody wants to own the sources**: without document maintenance, layer 2 gets worse every month.
- **When the real need is numbers** (revenue, stock, deadlines): that's a job for a dashboard connected to the ERP, not for a chat.
- **When folder permissions are a mess and there's no time to fix them**: start with layer 1 and postpone layer 2.
- **When all documents are already in a suite with a built-in assistant** and permissions are tidy: evaluate that first, with its costs.

## Practical checklist

- [ ] I've separated the two layers: general chat for everyone, documents on a small scope.
- [ ] I have the list of authorised sources, each with an owner.
- [ ] Confidential folders (HR, salaries, health, disputes) stay out of the index.
- [ ] Permissions have been checked with users from different departments.
- [ ] The model runs on EU or internal infrastructure, with an adequate contract.
- [ ] On company questions the assistant answers only with a cited source.
- [ ] The 10 rules have been handed out and explained.
- [ ] Training per department has been done with real cases.
- [ ] The 60-day plan has dates and owners.
- [ ] At 60 days there's a review with real numbers.

## The verdict

An **internal ChatGPT for the company, self-hosted or on European infrastructure under contract**, is within reach of an SME, provided you understand it's made of two layers. The writing chat is switched on in days and solves the problem of employees using personal tools. The assistant that answers on company documents is a more serious project, and its success depends less on the model and more on three very concrete things: up-to-date sources with an owner, tidy permissions, and the rule that without a source there's no answer.

Done this way, documents don't go to America, people find procedures in thirty seconds instead of asking a colleague on WhatsApp, and the company discovers — often for the first time — where its knowledge really lives and who can see it.

If you want to set up an assistant on your company's documents starting from the right sources, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on using ChatGPT at work without losing control are in the guide on [ChatGPT at work]({{ '/en/pillar/chatgpt-at-work/' | relative_url }}).

## FAQ

### What is an internal company ChatGPT?

It's an assistant similar to ChatGPT that runs on the company's infrastructure or a European provider's under contract, accessed with the work account. It can just write, summarise and translate, or answer questions on company documents citing the source, without documents being sent to external services without control.

### What's the difference between general chat and a document assistant?

General chat works only on what the user pastes or uploads in the conversation. The document assistant searches authorised company documents, finds the relevant passages and answers citing the source. The first is switched on in a few days; the second requires work on sources, updates and permissions.

### Are company documents sent abroad?

Not if the model and the document index run on a company server, on a server in an Italian or European data centre, or with a European provider under a contract that excludes training on the data. Documents stay in their folders; the system reads a copy for search.

### How do you stop an employee seeing confidential documents through the assistant?

The assistant must use only documents the user can already see in the original folders, inheriting their permissions. Confidential folders, such as HR and salaries, must stay out of the index. Before going live, permissions are checked by asking the same questions as users from different departments.

### What must a company ChatGPT not do?

It must not give legal, tax or medical opinions, must not provide numbers that live in the ERP without being able to cite them, must not invent procedures that aren't written and must not be used for decisions about people. On company questions it must answer only if it finds a source, and show it.

### How much does an internal ChatGPT cost an SME?

Roughly €3,000 to €6,000 of setup for 5 people, €8,000 to €15,000 for 25 and €15,000 to €30,000 for 80, plus monthly costs from a few tens to a few hundred euros and source maintenance from half a day to a few days a month. Office hardware is an option for larger companies.

### Better an office server or a European cloud service?

For small companies without internal IT, a European cloud under contract or a rented EU server are usually simpler. The office server gives maximum control and fixed costs, but requires an initial investment, a suitable space and someone to manage it: it makes sense from 20–30 people upwards.

### Is it an alternative to Microsoft 365 Copilot?

It can be. Copilot works on documents already in the suite, with the suite's permissions, and is paid per user. An internal assistant can work on different sources (NAS, ERP) with data under your control. In both cases, answer quality depends on how tidy documents and permissions are.

### How long does it take to have a working internal ChatGPT?

General chat is switched on in a few days or weeks. The document assistant typically takes 60 days for a first scope: a month to fix sources and permissions, a month for the pilot and corrections. Extending to the whole company is progressive work, department by department.

### How do you get staff to use it instead of ChatGPT on their phone?

By making it as convenient as ChatGPT, with company login and no extra steps; with short training using real cases from the department; by showing a mistake live to explain why to look at sources; and by keeping the promise that conversations aren't used to monitor people. A ban alone doesn't work.
