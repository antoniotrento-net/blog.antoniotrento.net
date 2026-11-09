---
lang: en
permalink: /en/blog/sme-process-automation-where-to-start/
alt_url: /it/blog/automazione-processi-pmi-da-dove-iniziare/
title: "Automation for SMEs without an IT department: where to start in 30 days (without buying 4 new pieces of software)"
date: 2026-12-04 07:30:00 +0200
author: "Antonio Trento"
description: "An entry guide to process automation for SMEs without IT: mapping where time goes in a week, 3 quick wins and 3 traps, connecting the tools you have before replacing them, the internal owner, a week-by-week 30-day plan, an honest budget and how to tell whether it worked."
keywords: ["sme process automation where to start", "sme digitalisation", "automation without it", "small business workflows", "n8n sme", "business process inventory"]
image: /assets/images/posts/automazione-processi-pmi-da-dove-iniziare.jpg
pillar: automazione-da-dove
related: [/en/blog/cost-of-not-digitizing/, /en/blog/n8n-vs-zapier-vs-make-cost/]
---

## Automation isn't "putting AI on everything"

The owner went to a conference. Three speakers out of four talked about artificial intelligence, agents, automation. They come back to the company feeling behind, with a question: "**where do we start with process automation in an SME like ours**, without an IT department?". The risk, at that point, is buying the first thing offered: a new CRM, invoicing software, a chatbot, an automation platform. Four subscriptions, four passwords, and six months later people work as before, with four more tabs open in the browser.

Automating doesn't mean putting artificial intelligence on everything. It means **taking away from people the repetitive work that requires no judgement**: copying data from one place to another, sending reminders, sorting documents, preparing reports someone compiles by hand every Monday. Most of this work can be automated with simple tools, connecting what the company already has, and AI is needed only in a few precise places.

This piece is an entry guide for owners and managers of SMEs with 5 to 50 people and no IT department. It takes you from "where do I start?" to a 30-day plan, with a concrete way to find out where time goes, three interventions that almost always work, three traps to avoid, who to involve, what it costs and how to tell after a month whether it helped.

## Is this for you?

It is for you if:

- you have an SME or firm of 5 to 50 people, without internal IT (or with "makeshift" IT: the colleague who's good with computers);
- you feel too much time goes on repetitive activities, but can't quantify it;
- you've received proposals for software and platforms and don't know which is the priority;
- you want to start small and see results before investing more.

It is not for you if you already have an IT department with a digitalisation plan: you'll find things you know. And it is not for you if you're looking for a comparison of specific automation tools: for that there's the piece on [n8n, Zapier and Make with costs compared]({{ '/en/blog/n8n-vs-zapier-vs-make-cost/' | relative_url }}). Here we talk about what comes before: understanding what to automate.

## Map one week: where the time goes

The first step isn't choosing a tool. It's **knowing where the time goes**. Almost no SME knows precisely: there's a feeling that "invoices take a lot of time" or that "we waste time on email", but no numbers.

The simplest way to find out is a one-week map. You don't need a consultant: you need to ask each person (or at least one per role) to note, for five days, the repetitive activities they do, how long they take and how often they recur.

### Process inventory canvas

Here's the canvas I use. Fill it in a spreadsheet, one row per activity.

| Activity | Who does it | Times per week | Minutes each time | Hours per week | Where data comes from | Where it goes | Requires judgement? | Frequent errors? |
|---|---|---|---|---|---|---|---|---|
| Posting supplier invoices | Finance | 80 | 3 | 4.0 | PEC / tax portal | ERP | Little | Yes, VAT and suppliers |
| Copying contacts from the website to the CRM | Sales | 25 | 4 | 1.7 | Form email | CRM | No | Yes, incomplete data |
| Sending deadline reminders to clients | Finance | 15 | 6 | 1.5 | Excel sheet | Email | No | Yes, forgotten |
| Monday sales report | Owner | 1 | 90 | 1.5 | ERP + Excel | Email | Little | Different numbers every time |
| Sorting requests from the info@ mailbox | Reception | 60 | 2 | 2.0 | Email | Other mailboxes | Some | Lost requests |
| Preparing delivery notes and order confirmations | Logistics | 30 | 5 | 2.5 | ERP | PDF + email | No | Yes, wrong addresses |

For each row, three questions decide whether the activity is a candidate for automation:

1. **How many hours a week?** Below half an hour, it's rarely worth it.
2. **Does it require judgement?** If the person has to decide something non-trivial, automation can help (prepare data) but not replace.
3. **Is the data already digital?** If it arrives on paper or by phone, it must be digitised first; if it's in a system, it can be connected.

At the end of the week you'll have a list of 15–30 activities with hours. Almost always it turns out that **three or four activities account for half the repetitive time**. Those are where to start. And almost always costs nobody had seen emerge too: time lost looking for documents, phone calls to find out where an order is, corrections of copying errors. It's the subject of the piece on the [cost of not digitising processes]({{ '/en/blog/cost-of-not-digitizing/' | relative_url }}).

## 3 typical quick wins and 3 traps

### Three quick wins that almost always work

**1. Contacts and requests from the website to the right place.** Requests from the website form or the info@ mailbox arrive in an inbox, someone copies them into the CRM or ERP, someone else (maybe) calls them back. Automating them means: the request creates the contact by itself, assigns an owner, sends the client a confirmation and the salesperson an alert. Typical result: no lost requests, response times halved, one or two hours a week saved. It's also the quick win with the most visible effect on sales.

**2. Automatic reminders.** Contract deadlines, renewals, payments, appointments, documents to renew. Today they live in an Excel sheet someone has to remember to open. Automated, they go out by themselves: to the client (renewal in 30 days), internally (payment overdue for 7 days). Typical result: fewer forgotten items, less money lost, fewer awkward phone calls.

**3. The report that builds itself.** The Monday report the owner or a collaborator compiles by hand by copying data from the ERP. Automated, it arrives by email every Monday at 8, always with the same criteria. Typical result: an hour and a half a week saved and, above all, consistent numbers from one week to the next.

These three share features: data already digital, no judgement required, visible effect in a few days, low risk if something goes wrong.

### Three traps

**1. Starting from the most complicated process.** "Let's automate job management from offer to invoice." It's the most important process, and the right one to improve one day, but as a first project it's too much: many exceptions, many people involved, high risk of failing and burning trust in automation. Start at the edges, not at the heart.

**2. Automating a process that doesn't work.** If today client requests get lost because nobody knows who should handle them, automating their arrival in the CRM solves nothing: requests will get lost in the CRM instead of the inbox. First decide who does what, then automate.

**3. Putting AI where a rule is enough.** "Let's use artificial intelligence to decide who to assign the request to." If the rule is "requests from Lombardy to Marco, the rest to Giulia", it's a rule, not a job for AI. Artificial intelligence is needed where there's text to interpret (a freely written email, a document to read), not where there's a table of rules.

## Tools: sheets, ERP, email, calendar — connect before replacing

The most expensive reflex, when talking about automation, is **replacing**: "our ERP is old, let's get a new one", "Excel isn't enough, we need a CRM", "email is chaos, we need a platform". Sometimes it's necessary. Much more often, the first step is **connecting** the tools you already have.

A typical SME has:

- an **ERP** (invoices, orders, stock, master data);
- **email** and perhaps a PEC certified mailbox;
- **spreadsheets** for what the ERP doesn't do (deadlines, special price lists, planning);
- a shared **calendar**;
- perhaps a **CRM**, sometimes half-used;
- the **website** with a contact form.

Repetitive work almost always sits **between** these tools: copying from the form to the CRM, from the ERP to the sheet, from the sheet to email. An automation tool (n8n, Make, Zapier, or the automations already included in the software you have) serves precisely to build these bridges, without replacing any of the tools.

### Software trap list

Before buying new software, check you're not falling into one of these traps:

- **Software that duplicates data.** A new tool with its own client master data, different from the ERP's. After three months you have two versions of the truth and someone aligning them by hand.
- **Software nobody opens.** Bought for a real need, but requiring people to go into another application that isn't part of their day. If it isn't where people already work, it won't be used.
- **Per-user subscription for the whole staff.** Licences for 30 people when 5 really use it.
- **The feature that was already there.** Many ERPs and CRMs include automations (reminders, flows, imports) nobody ever switched on. Before buying, ask your ERP vendor what it already does.
- **Undeclared lock-in.** A tool from which you can't export data or flows in a standard format. The day you want to change, you start from scratch.
- **AI as a sales argument.** "With integrated artificial intelligence" isn't a reason to buy. Ask what it does, with which data, where it processes it, and how much work it really removes.

## Who's the internal owner (even part-time)

Automation in an SME without IT almost always fails for the same reason: **nobody looks after it** after installation. Flows break (software changes, a password expires, a form is modified) and nobody notices for weeks.

You need an **internal owner**. They don't need to be an IT person, nor do it full-time. The right traits:

- **knows the company's processes** (how they really work, not how they should);
- **is precise and curious**, willing to learn a new tool;
- **has reserved time**: two to four hours a week at first, one or two at steady state, written into their schedule and not "when there's time";
- **has a mandate** from the owner: can ask colleagues how they work, propose changes, say no to software.

Often it's someone from finance or a salesperson with the right attitude. At first they should be supported by an **external partner** (a professional or a small firm) who builds the first flows, teaches them to manage them, and remains available for the more technical issues. The goal is that after a few months the owner can change and fix simple flows by themselves.

## 30-day plan, week by week

Here's the plan I propose to SMEs starting from zero.

### Week 1 — Map

- The owner presents the initiative in a 20-minute meeting: goal (remove repetitive work, not people), owner, timing.
- Each role fills in the inventory canvas for five days.
- The internal owner collects the list of tools in use, with who uses them and who pays for them.

### Week 2 — Choice

- The internal owner, with the business owner (and the external partner, if there is one), ranks activities by hours per week and ease.
- **Three quick wins** are chosen: digital data, no judgement, visible effect, low risk.
- For each, half a page: what happens today, what will happen after, who notices if it breaks.
- The connecting tool is chosen (often a cloud automation tool to start; self-hosted is considered if data is sensitive or volumes high).

### Week 3 — Build

- The first, simplest quick win is built.
- It runs **in parallel** with the current way for a few days: the automatic flow works, but the person keeps doing their job and compares.
- If it goes well, the manual work for that activity is switched off. Then on to the second.

### Week 4 — Consolidation

- The second and (if possible) the third quick wins are completed.
- **Alerts** are set up: if a flow fails, the internal owner gets a notification.
- One page per flow is written: what it does, where it takes data from, where it puts it, what to do if it breaks.
- A 30-minute meeting with those involved: what changed, what isn't working, what to automate next.

An example of how to describe a flow on one page, so anyone understands it:

```text
FLOW: Website requests → CRM
What it does:  When a request arrives from the website's "Contact" form, it creates the contact
               in the CRM, assigns it to the area salesperson, sends a confirmation email to the
               client and an alert to the salesperson.
From:          Website form (email to info@)
To:            CRM (contact record) + email
Area rule:     North → Marco; Centre-South → Giulia; Abroad → owner
If it breaks:  The internal owner gets an alert. Meanwhile requests stay
               in the info@ mailbox: check it by hand until it's fixed.
Owner:         Laura (finance)        External partner: [name, phone]
Last change:   2026-12-18
```

## Honest budget (estimates)

The figures below are indicative **estimates** for an SME of 10–30 people starting with three quick wins.

| Item | Estimate | Notes |
|---|---|---|
| Automation tool | €0–100/month | Many have free or cheap plans for low volumes |
| External partner for the first flows | €1,500–5,000 | Depends on number and complexity of flows |
| Internal owner's time | 2–4 hours/week in the first month, then 1–2 | The most underestimated cost |
| People's time for the map | 1–2 hours each in the first week | One-off |
| Maintenance | €0–200/month | Partner support on call or by retainer |
| New software | ideally €0 | Connect what exists first |

For comparison: if the three quick wins remove 5–8 hours a week of repetitive work, at €30 an hour that's €600–1,000 a month of time given back. The initial investment pays back in a few months, and the freed time goes to activities that need people: clients, quality, sales.

## How to tell after 30 days whether it worked

At the end of the month, three questions with measurable answers:

1. **How many hours a week were removed?** Redo the canvas only for the automated activities and compare with the first week. If the saving is under two hours a week, the quick wins were badly chosen or the flows aren't used.
2. **How many fewer errors or forgotten items?** Lost requests, reminders not sent, reports with different numbers. Ask those who suffered them.
3. **Are the flows stable?** How often they broke, how long it took to fix them, whether the internal owner can manage them.

And a fourth question, less measurable but important: **do people want more?** If after a month colleagues come to the internal owner with "could we automate this too?", the project worked. If nobody talks about it, or people have started doing things by hand again "because it's safer", there's something to understand before going on.

## 30/60/90-day path

- **0–30 days**: map, three quick wins, internal owner, alerts, documentation. (The plan above.)
- **30–60 days**: two or three more flows from the list, chosen among those with the most hours; first training for the internal owner to change flows alone; first check of real costs.
- **60–90 days**: consider a more central process (for example from quote to order), with more people involved; decide whether new tools are needed or the connected ones are enough; consider where AI can really help (sorting free-text emails, reading documents).

## A concrete case: an installation company with 15 people

Here's how the first month goes in a typical case: a company doing installations and maintenance, 15 people between office and technicians, no internal IT. The numbers are simplified but realistic.

**The map.** The inventory week produces 22 repetitive activities totalling about 31 hours a week. Four of them account for 17 hours: preparing job reports from technicians' notes (6 hours), calling clients for upcoming periodic maintenance (4 hours), copying requests from the website and email into the ERP (3.5 hours), compiling the owner's weekly job report (3.5 hours, adding up who collects the data and who formats it).

**The choice.** Job reports are the costliest point, but they require changing how technicians work (an app or a form to fill in on site): too much for the first month, it goes on the 60–90-day list. Instead the three quick wins are chosen: maintenance reminders, website requests to the ERP, automatic weekly report.

**The build.** The internal owner is the office clerk, with 3 hours a week reserved, supported by an external partner for 4 days in total. Maintenance deadlines were in an Excel sheet: they're connected to a flow that every Monday sends the client an email proposing two dates and gives the office a list of who to call if there's no reply within three days. Website requests create the record in the ERP and an alert to the technical manager. The weekly report reaches the owner on Monday at 8, taken directly from the ERP.

**The result after 30 days.** About 8 hours a week removed from the office, no website request lost (before, according to the office, "a couple a month"), and more maintenance confirmed, because the reminder always goes out and not only when someone remembers to open the sheet. The owner, for the first time, looks at the same report every week with the same criteria. The internal owner, in the second month, edits the email text and assignment rules on her own.

## What breaks after a few months

Simple automations are robust, but not eternal. Typical failures after a few months:

- **A password or access expires.** Connected software asks to renew the authorisation, or the person who connected it with their account leaves. The flow stops. Remedy: connect software with company service accounts, not personal ones, and keep alerts on.
- **Someone changes the website form or the Excel sheet.** A renamed field, a moved column: the flow keeps running but writes wrong or empty data. Remedy: a simple rule, "before changing a connected form or sheet, tell the internal owner".
- **The flow does the right thing the wrong way.** The reminder goes out even to clients who've already booked, because nobody updates the deadlines sheet. It's not a technical failure: it's a missing piece of process. Fix it by asking who updates what.
- **Nobody looks at the alerts any more.** Alerts go to the internal owner's mailbox, who's on holiday or has changed role. Remedy: at least two people receive alerts, and once a month the internal owner does a check round of all flows.
- **The number of flows grows without order.** After a year there are 25 flows built by different people, some duplicated, some useless. The documentation page for each flow, and a six-monthly review, prevent chaos.

## 3 beginner mistakes that cost money or time

**1. Buying before mapping.** Software is subscribed because "it's needed", and only afterwards does it emerge that the activity it was meant to solve is worth an hour a month, while the one worth ten a week hadn't been seen. The mapping week costs little and avoids investing in the wrong place.

**2. Not giving the internal owner time.** "Laura will handle it when she has time." Laura never has time, flows break, nobody notices, and after three months automation "doesn't work". Two hours a week in the calendar make the difference.

**3. Switching off manual work too early.** The new flow starts, seems to work, and the next day people stop checking the info@ mailbox. A week later it emerges that requests with an attachment weren't handled. The parallel period, even short, is the cheapest insurance there is.

## When NOT to do it (yet)

- **When the company is in the middle of a big change** (new ERP, move, reorganisation): automating processes that will change in two months is wasted work.
- **When processes aren't clear to anyone**: if nobody can say who does what in a process, first write down how it works, then automate.
- **When nobody can be the internal owner**: without a person looking after it, better to postpone or hand everything to an external partner with a clear contract.
- **When there's little repetitive work**: if the map shows repetitive activities are worth a couple of hours a week across the company, there are probably more important priorities.

## Practical checklist

- [ ] I've done (or had done) the one-week map with the inventory canvas.
- [ ] I know the three or four activities worth half the repetitive time.
- [ ] I've chosen three quick wins: digital data, no judgement, visible effect, low risk.
- [ ] I have an internal owner with reserved hours and a clear mandate.
- [ ] I've checked what my existing tools already do before buying new ones.
- [ ] Every flow runs in parallel with manual work for a few days before replacing it.
- [ ] There are alerts if a flow breaks.
- [ ] Every flow has a page explaining what it does and what to do if it breaks.
- [ ] After 30 days I've measured hours saved, errors avoided and stability.

## The verdict

The answer to "**where do I start with process automation in an SME**" isn't software: it's a week spent understanding where time goes. From it almost always come three or four repetitive activities worth half the useless work, and almost always they can be automated by connecting the tools the company already has, without buying new ones and without needing artificial intelligence.

The rest is discipline: an internal owner with real time, three well-chosen quick wins, a parallel period before switching off manual work, alerts when something breaks, and an honest measurement after thirty days. It isn't as spectacular as a conference, but it's how SMEs without IT really start working better, and find the confidence to take the next step.

If you want to set up the first thirty days of automation in your company starting from the numbers, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on getting automation started in an SME are in the guide on [SME automation: where to start]({{ '/en/pillar/sme-automation/' | relative_url }}).

## FAQ

### Where do you start with process automation in an SME?

With a one-week map: each role notes repetitive activities, how often they do them and how long they take. Usually three or four activities emerge that account for half the repetitive time; among them you choose three quick wins with data already digital, no judgement required and a visible effect.

### Do you need an IT department to automate processes?

No. You need an internal owner who knows the processes and has a few hours a week dedicated, supported at first by an external partner who builds the first flows and teaches them to manage them. The owner doesn't have to be an IT person.

### Which processes should be automated first?

Typically incoming website requests into the CRM with assignment and confirmation, automatic reminders for deadlines and renewals, and periodic reports someone compiles by hand today. They're activities with data already digital, no complex decisions and a visible effect within days.

### Do you need to buy new software to automate?

Often not. Repetitive work almost always sits between the tools the company already has: ERP, email, spreadsheets, calendar, CRM. An automation tool serves to connect them. Before buying, check which automations are already included in the software in use.

### How much does it cost to start automating in an SME?

Roughly €0 to €100 a month for the automation tool, €1,500 to €5,000 for an external partner building the first flows, and a few hours a week of the internal owner. If the first flows remove 5–8 hours of repetitive work a week, the investment pays back in a few months.

### When is artificial intelligence needed in automation?

When there's text to interpret: freely written emails to sort, documents to read, notes to summarise. Where there's a clear rule, such as assignment by area or a calculated deadline, a rule is enough and AI only adds cost and risk.

### How do you stop automations breaking without anyone noticing?

By setting up alerts that notify the internal owner when a flow fails, documenting each flow on a page with what to do if it breaks, and running every new flow in parallel with manual work for a few days before replacing it.

### What are the most common traps?

Starting from the most complicated process, automating a process that doesn't already work by hand, using AI where a rule is enough, and buying software that duplicates data, that nobody opens or whose features already exist in current tools.

### How do you measure whether automation worked?

After 30 days, compare the hours spent on automated activities with those of the mapping week, count errors and forgotten items avoided, check how often flows broke and whether the internal owner can manage them. A good sign is colleagues proposing more activities to automate.

### When is it better to postpone automation?

When the company is changing ERP or reorganising, when processes aren't clear to anyone, when nobody can act as internal owner, or when the map shows there's little repetitive work. In these cases there are priorities that come first.
