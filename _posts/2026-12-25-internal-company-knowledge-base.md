---
lang: en
permalink: /en/blog/internal-company-knowledge-base/
alt_url: /it/blog/knowledge-base-aziendale-interna/
title: "An internal knowledge base employees actually use (not a Confluence opened in 2019 and never again)"
date: 2026-12-25 07:30:00 +0200
author: "Antonio Trento"
description: "Why company wikis die and how to build one that lives: what to put in (procedures, internal price lists, how-tos) and what not, one page one owner one date, search before AI, Q&A with mandatory citations, permissions per department, a 30-minute monthly clean-up ritual and the metrics that show whether it works."
keywords: ["internal company knowledge base", "company wiki that works", "ai on internal documents", "sme procedure search", "onboarding knowledge base", "business procedure documentation"]
image: /assets/images/posts/knowledge-base-aziendale-interna.jpg
pillar: documenti-fatture-ai
related: [/en/blog/company-pdf-search/, /en/blog/internal-chatgpt-self-hosted-company/]
---

## The ghost wiki and the colleague's WhatsApp

In 2019 someone in the company had a good idea: "let's put all procedures in a wiki". A tool was chosen, a week was spent writing pages, there was a presentation at a meeting. For a few months it worked. Then the person who cared about it changed role, procedures changed without anyone updating the pages, and today the wiki is a place you only go to discover that what's written there is no longer true.

Meanwhile the company's knowledge found another home: **the expert colleague's WhatsApp**. "How do you do a return for a foreign client?" "What's the code for the reseller discount?" "Where do I find the travel form?" The answer comes, almost always right, but every question interrupts someone, and the day that colleague goes on holiday (or leaves) half the company stops.

This piece explains how to build an **internal company knowledge base** people actually use: what to put in and what not, the ownership rule that keeps it alive, why search comes before artificial intelligence, how to use AI without letting it invent procedures, permissions per department, a thirty-minute monthly clean-up ritual and the metrics that tell you whether it's working. It's not a tool question: wikis die for organisational reasons, and are kept alive with simple rules.

## Is this for you?

It is for you if:

- you have between 10 and 200 people, and the same questions are asked every week;
- you have a wiki, a "Procedures" folder or an intranet nobody opens;
- onboarding a new colleague takes weeks of "ask so-and-so";
- you're thinking of putting an AI assistant on internal documents and want it to answer well.

It is not for you if your company is 5 people working in the same room: knowledge passes by word of mouth and that's fine. And it is not for you if you're looking for a comparison of wiki software: the tool matters much less than the rules.

## What to look for: procedures, internal price lists, how-tos, not "everything"

The first mistake, the one that kills most knowledge bases, is wanting to put **everything** in it. "Let's upload all the company's documents." The result is a huge archive in which useful information is buried among old versions, drafts, personal documents and material nobody will ever look for.

A useful knowledge base contains **what people actually look for, often**. To find out, the simplest method is to ask: for two weeks, every time someone asks a colleague "how do I" or "where do I find", note it down. At the end you'll have a concrete list, and you'll discover the recurring questions are a few dozen.

They almost always fall into five categories:

1. **Operating procedures**: how to do a return, open a case, handle a complaint, close the month in finance.
2. **Internal reference information**: internal price lists, terms per client type, codes, supplier contacts, who does what.
3. **Technical how-tos**: how to configure a device, use an ERP function, solve a recurring problem.
4. **Forms and templates**: holiday form, expense claim, offer template, letter template.
5. **Onboarding new colleagues**: what to do in the first week, whom to meet, which tools to use.

What **not** to put in (at least at first):

- historical archives of documents nobody consults;
- documents of ongoing projects (they live better in their own tools);
- communications and meeting minutes (they get lost and age immediately);
- personal documents and drafts;
- confidential data that mustn't be accessible to everyone (salaries, appraisals, disputes).

A knowledge base with 80 up-to-date pages is worth infinitely more than one with 2,000 documents of which nobody knows which are valid.

## Ownership: every page has an owner and a date

This is the rule that decides whether the knowledge base lives or dies. **Every page has an owner and a review date.** Without an owner, a page ages; without a date, nobody knows it has aged.

### Ownership rules

1. **Every page has a named owner**, not "finance" or "the technical office". A person who answers if the page is wrong.
2. **The owner is whoever does that work**, not whoever writes well. The returns procedure belongs to the logistics manager; expense claims to finance.
3. **Every page has a visible last-review date** at the top, and a **review deadline** (for example 6 or 12 months, depending on how fast the subject changes).
4. **When the procedure changes, the page changes the same day.** It's part of the change, not a task "for when there's time".
5. **Anyone can report an error**, with a button or comment on the page; the owner has a week to fix or reply.
6. **An expired page is flagged** (for example with a "to be verified" notice), not left as if it were valid.
7. **When an owner changes role or leaves**, their pages pass to a new owner before they go, like the office keys.
8. **Pages without an owner get archived.** Better one page fewer than a false page.

### Procedure template

A common template makes pages easier to write and read. Here's the one I use:

```text
TITLE:         Returning goods from a foreign (EU) client
OWNER:         Laura Bianchi – Logistics
LAST REVIEW:   2026-11-30        NEXT REVIEW: 2027-05-30
FOR:           Customer care, logistics, finance

WHEN TO USE IT
A client in an EU country asks to return goods already delivered.

WHAT YOU NEED BEFORE STARTING
- Order number and delivery note number
- Reason for return (defect, shipping error, change of mind)
- Photos of the goods if the reason is a defect

STEPS
1. Check in the ERP that the order is within 30 days of delivery.
2. Open the return case in the ERP (menu Sales > Returns > New).
3. If the reason is a defect: attach the photos and notify the quality manager.
4. Generate the pickup label from the courier portal (company account).
5. Send the client the "EU Return" email template with the label.
6. On arrival of the goods: warehouse check within 2 working days.
7. If the check is positive: finance issues the credit note.

EXCEPTIONS
- Over 30 days: requires the sales manager's approval.
- Customised goods: returns for change of mind are not accepted.

DOCUMENTS AND LINKS
- "EU Return" email template → [link]
- Terms of sale, art. 9 → [link]

FREQUENT QUESTIONS
- Who pays for shipping? We do if the reason is a defect or our error; the client otherwise.
```

Line by line, why it's built this way: a **title** as a person would search for it; **owner and dates** at the top, visible; **who it's for**, so the reader knows whether it concerns them; **when to use it** in one sentence; **what you need** before starting, so you don't stop halfway; **numbered steps**, one per action; **exceptions** separate, because they're what generate questions to colleagues; **links** to documents instead of copying them (so they stay up to date); **frequent questions** at the bottom, gathered from real questions.

## Search before AI (if it can't be found, AI invents)

Today the temptation is to jump straight to artificial intelligence: "let's put a ChatGPT on the documents and it'll answer". It's a good idea, but only if it comes after something simpler: **search must work**.

The reason is technical but fits in a sentence: an AI assistant on documents works by **searching** for relevant passages and then **writing** an answer based on them. If search doesn't find the right page — because the title is wrong, because the page is buried among old versions, because it uses different words from the ones people use — the assistant answers anyway, with what it found, or by inventing something plausible. Either way, the answer is wrong and looks right.

So, before AI:

- **titles as questions or as people search**: "Returning goods from a foreign client", not "PR-LOG-07 rev. 3";
- **synonyms and trade words**: if the warehouse calls it "DDT" and finance "delivery note", the page must contain both;
- **one page per topic**, not three pages saying slightly different things;
- **old versions archived**, not left next to the new ones;
- **a test**: take the 30 most frequent questions collected at the start and search for them. If the right page doesn't appear among the first results, fix the page (title, words, structure), not the search engine.

The subject of search in company documents, even when they're thousands of PDFs, is covered in the piece on [company document search]({{ '/en/blog/company-pdf-search/' | relative_url }}).

## Q&A with mandatory document citation

When search works and pages are tidy, an AI assistant becomes very useful: people ask in natural language ("how do I do a return for a French client?") and get a short answer, with the reference to the page. It's the fastest way to get even those who can't be bothered to search to use the knowledge base.

The rule, with no exceptions: **every answer cites the page it comes from, with its review date**. Example:

> For a return from an EU client: check the order is within 30 days of delivery, open the case in the ERP (Sales > Returns > New), generate the label from the courier portal and send the client the "EU Return" template. Over 30 days you need the sales manager's approval.
>
> *Source: "Returning goods from a foreign (EU) client" — owner Laura Bianchi — reviewed 30/11/2026.*

And the related rules:

- **if it finds no relevant page, it says so**: "I found no procedure on this topic. You can ask [area owner] or report it as a missing page." No invented answer;
- **if the page has expired, it flags it**: "Note: this procedure hasn't been reviewed for more than 12 months";
- **unanswered questions are logged** (without personal data) and become the list of pages to write.

If you want to build the assistant with documents that stay in the company, the project is described in the piece on the [internal ChatGPT for SMEs]({{ '/en/blog/internal-chatgpt-self-hosted-company/' | relative_url }}).

## Permissions: HR ≠ sales ≠ production

Not everything is for everyone. A company knowledge base must respect permissions, and an AI assistant makes them even more important: if a confidential page is indexed and the assistant doesn't check who's asking, the answer reaches anyone.

Practical rules:

- **Spaces per department**, with pages visible to all and pages reserved to the department. HR procedures on payslips aren't needed by production; terms reserved for strategic clients aren't needed by payroll.
- **A common space** with information for everyone: who does what, forms, onboarding, company rules.
- **Outside the knowledge base**: salaries, appraisals, health data, disputes, information about individual employees. They're not needed, and the risk is high.
- **The assistant inherits permissions**: it answers each person using only pages that person can see.
- **Periodic check**: twice a year, someone checks who can see what, especially after role changes.

## Monthly clean-up ritual (30 minutes)

Knowledge bases don't die from an event: they die from lack of maintenance. The remedy is a short, fixed ritual, in the calendar. Thirty minutes a month, the first Monday, with a knowledge base coordinator (it doesn't need to be a full-time role).

What you do:

1. **Expired pages** (5 minutes): the list of pages past their review date. Sent to owners with a request: confirm, update or archive within two weeks.
2. **Open reports** (5 minutes): errors reported by people and not yet fixed. Owners are chased.
3. **Searches without results** (10 minutes): questions people asked that search or the assistant couldn't answer. Decide which become new pages and who writes them.
4. **Most-read pages** (5 minutes): they're the ones that matter most; check they're up to date and clear.
5. **Owners** (5 minutes): are there pages without an owner? People who changed role? Reassign.

Thirty minutes a month is little. But done every month, it's the difference between a knowledge base that lives and one that in 2028 will be the new ghost wiki.

## How to write the first 10 pages in a week

The hardest moment is the start: the blank page, people who "don't have time to write". Here's a method that works for getting started without stopping work.

1. **Pick the 10 most frequent questions** from the two-week collection. Not the most important in absolute terms: the most asked.
2. **For each, identify who usually answers** (the WhatsApp colleague). They're the page's natural owner.
3. **Interview, don't ask them to write.** A 15-minute interview, recorded or with notes: "explain how it's done, step by step, as you'd explain it to a new colleague". People who "can't write" can explain perfectly well out loud.
4. **The coordinator writes the draft** using the template, starting from the interview. It doesn't need perfect style: it needs clear steps and exceptions.
5. **The owner rereads and corrects** in 10 minutes. Correcting is much faster than writing from scratch.
6. **Field test.** Ask someone who doesn't know the procedure to follow it. Where they get stuck, the page needs improving.
7. **Publish with date and owner.** And tell everyone: "from today there's this page for foreign returns; if something's missing, report it here".

With this method, ten pages take about two and a half hours of the expert colleagues' time (interviews and rereading) and one or two days of the coordinator's. After the first ten, the pace picks up: people see the pages being used and start proposing new ones themselves.

A detail that helps a lot: **publish the most-asked pages immediately and announce them**. The first colleague who answers a question with a link to the page instead of a voice message is the moment the knowledge base starts to live.

## Metrics: empty searches, repeated tickets

How do you tell whether the knowledge base works? Not from the number of pages. From these indicators:

- **Empty searches**: share of searches (or questions to the assistant) without a useful result. At first it can be high; it must fall over time. If it rises, pages are missing or written with different words from people's.
- **Repeated questions to colleagues**: ask the "expert colleagues" (the WhatsApp ones) how many interruptions they get a week, before and after. It's the most concrete measure of value.
- **Repeated tickets or requests**: for those with an internal helpdesk (IT, finance), identical requests repeated every week. If a question has a page and keeps arriving as a ticket, the page can't be found or isn't understood.
- **Pages updated on time**: share of pages within their review date. Under 80%, the monthly ritual isn't being done.
- **Use**: people opening the knowledge base or using the assistant at least once a week. Not everyone needs to: those who need it do.
- **New hire onboarding time**: how long a new colleague takes to work independently. It's often the biggest benefit, and measurable by asking managers.

## A concrete case: a services company with 45 people

A technical services company with 45 people between office and field technicians. A wiki opened years earlier with 300 pages, nobody knowing how many were valid. Two expert colleagues receiving, by their account, "about twenty questions a day". Onboarding a new technician took about two months before they worked alone.

**The first four weeks.** Questions collected for two weeks: 140 questions noted, boiling down to about 50 distinct topics. Of the old wiki's 300 pages, 60 covered those topics and were salvageable; the others were archived. For the 50 topics, pages were written or rewritten with the template, each assigned an owner. Titles rewritten as people searched for them.

**The next four weeks.** A search test with the 50 questions: for 12 the right page didn't appear among the first results; titles and words fixed. Then the AI assistant on top of the knowledge base, with mandatory citation and "not found" when appropriate, accessible from technicians' phones too.

**After three months.** The two expert colleagues estimate questions received dropped to 5–6 a day, almost all on genuinely new cases. Empty searches went from about 30% in the first weeks to under 10%. The monthly ritual produced 15 new pages from unanswered questions. The technician hired meanwhile worked independently in about three weeks.

## What breaks after a few months

- **The ritual gets skipped.** It's the first sign: one month is skipped "because there's a lot of work", the second too, and expired pages pile up. Remedy: ritual in the calendar, with a stand-in if the coordinator is away.
- **Procedures change without updating pages.** A meeting decides a change, and nobody remembers the page. Remedy: in the minutes of any decision changing a way of working, a line "page to update: [title], owner [name]".
- **People go back to WhatsApp.** If the knowledge base's answers are old or hard to find, people go back to the colleague. Metrics show it; the solution is on the pages, not the tool.
- **The knowledge base bloats.** Little by little documents are added "for completeness". Remedy: the question "who'll look for this?" before every new page.
- **Permissions go wrong after a reorganisation.** New departments, people changing role: the six-monthly permission check catches it.

## Costs: estimates

| Item | Estimate | Notes |
|---|---|---|
| Wiki / knowledge base tool | €0–8 per user per month | There are excellent free and self-hosted solutions; many suites include one |
| Collecting questions and rewriting the first 50 pages | 10–20 person-days spread out | The highest and most useful cost; mostly owners' time |
| Knowledge base coordinator | 2–4 hours a month | Monthly ritual and coordination |
| AI assistant on top of the knowledge base (optional) | €3,000–10,000 setup + €50–300/month | With data in the EU or in-house, mandatory citations |

The main cost is the time of the people who write and maintain pages. Compare it with the time lost today: if two expert colleagues get twenty interruptions a day, that's hours every week, plus the time of whoever waits for the answer.

## 3 beginner mistakes that cost time

**1. Uploading everything.** Two thousand documents without order aren't a knowledge base: they're an archive in which search and AI find the wrong version. Start from real questions, not existing documents.

**2. Giving the writing to one person.** "The intern will handle it for three months." Pages come out, but without real owners they age as soon as she leaves. Whoever does the work owns the page; the coordinator coordinates.

**3. Putting AI before search.** An assistant on messy pages confidently answers with the old version of a procedure. Trust burns in the first weeks and doesn't come back.

## 30/60/90-day path

- **0–30 days**: collect questions for two weeks, choose the tool, template, first 20–30 pages on the most frequent topics, owners assigned.
- **30–60 days**: complete pages for the main topics, archive the old wiki, search test with the collected questions, first monthly ritual.
- **60–90 days**: AI assistant with mandatory citation (if needed), permissions checked, first metrics (empty searches, questions to colleagues), second and third rituals.

## When NOT to do it

- **When the company is very small** and everyone works together: knowledge passes by word of mouth.
- **When processes are about to change radically** (new ERP, reorganisation): writing procedures that will change in two months is wasted work; better to write them for the new setup.
- **When nobody wants to own pages**: without ownership, the knowledge base dies. Solve that first.

## Practical checklist

- [ ] I've collected for two weeks the questions people ask colleagues.
- [ ] The knowledge base contains answers to those questions, not "everything".
- [ ] Every page has a named owner and a visible review date.
- [ ] Pages follow a common template.
- [ ] Titles are written as people search.
- [ ] Search finds the right page for the most frequent questions.
- [ ] If there's an AI assistant, it always cites the page and says "not found" when appropriate.
- [ ] Permissions separate departments and confidential information.
- [ ] There's a 30-minute monthly ritual in the calendar.
- [ ] I measure empty searches, questions to colleagues and up-to-date pages.

## The verdict

An **internal company knowledge base** doesn't die because the tool was wrong: it dies because nobody was responsible for it. The version that works is smaller than you'd think — answers to the questions people actually ask, a few dozen topics — and more disciplined: every page has an owner and a date, search is tested with real questions, AI comes after and always cites the source, and thirty minutes a month are enough to keep it alive.

The result isn't a pretty intranet. It's fewer interruptions for expert colleagues, new hires independent in weeks instead of months, and a company that doesn't stop when one person goes on holiday.

If you want to build a knowledge base people actually use, possibly with an AI assistant on top, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on documents and AI are in the guide on [documents, invoices and AI]({{ '/en/pillar/documents-invoices-ai/' | relative_url }}).

## FAQ

### Why do company wikis stop being used?

Because nobody is responsible for the pages: procedures change, pages don't, and after a few months people discover that what's written is no longer true. At that point they go back to asking colleagues. The problem is organisational, not the tool.

### What should go into a company knowledge base?

Answers to the questions people really ask, often: operating procedures, internal reference information such as price lists and contacts, technical instructions, forms and templates, material for onboarding new colleagues. Not the whole company archive.

### How do you keep a knowledge base up to date?

By giving every page a named owner and a review date, updating the page the day the procedure changes, letting everyone report errors, and running a 30-minute monthly ritual to check expired pages, reports and searches without results.

### Is artificial intelligence needed for an internal knowledge base?

Not at first. Search must work first: titles written as people search, one page per topic, old versions archived. Afterwards, an AI assistant makes the knowledge base more convenient, as long as it always cites the page the answer comes from and says when it finds nothing.

### Why must the AI assistant cite the source?

So the reader can check the answer, see whether the procedure is up to date and know who's responsible for it. Without a citation, an assistant can answer with an old version or invent a plausible procedure, and nobody notices.

### How are permissions handled in a knowledge base?

With spaces per department and a common space for everyone, keeping confidential information such as salaries, appraisals and health data out. If there's an AI assistant, it must use for each person only the pages that person can see. Permissions should be checked periodically, especially after role changes.

### How do you measure whether the knowledge base works?

With the share of searches without results, the number of questions expert colleagues receive, repeated requests to the internal helpdesk, the share of pages updated on time, weekly use and the time a new hire needs to work independently.

### What does a company knowledge base cost?

The tool can cost little or nothing. The real cost is the time to collect questions and write the first pages, roughly 10–20 person-days spread among owners, plus 2–4 hours a month of a coordinator. An optional AI assistant adds a few thousand euros of setup and a monthly cost.

### How do you write a good procedure page?

With a title as a person would search for it, owner and dates at the top, who it's for, when to use it, what you need before starting, numbered steps, separate exceptions, links to documents instead of copies and frequent questions at the bottom.

### Where do you start building a knowledge base?

By collecting for two weeks the questions people ask colleagues about how to do things and where to find them. They usually boil down to a few dozen topics: from those you write the first pages with an owner each, before thinking about tools or artificial intelligence.
