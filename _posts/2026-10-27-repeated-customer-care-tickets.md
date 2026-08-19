---
lang: en
permalink: /en/blog/repeated-customer-care-tickets/
alt_url: /it/blog/customer-care-ticket-ripetuti/
title: "40 identical tickets a day: the customer care that has no knowledge base (and the AI that copies the wrong answers)"
date: 2026-10-27 07:30:00 +0200
author: "Antonio Trento"
description: "If your customer care answers the same questions 40 times by copying old answers, the problem isn't a lack of AI: it's a lack of a knowledge base. Here's how it's built, and why AI without citation is dangerous."
keywords: ["repeated customer care tickets", "support knowledge base", "helpdesk ai risks", "sme ticket software", "standard customer answers"]
image: /assets/images/posts/customer-care-ticket-ripetuti.jpg
pillar: app-interne
related: [/en/blog/internal-app-copy-paste/, /en/blog/misaligned-warehouse-stock/]
---

## The same forty questions, every day, forever

Look at your customer care inbox on any given day. Out of forty requests, how many are truly new? Few. The rest are the usual: "where is my order?", "how do I change the size?", "what are the delivery times?", "I can't make a return", "I didn't receive the invoice". The same questions, every day, to which your operators reply... how? By copying the answer they gave yesterday to another customer, searching for it in their sent box, or rewriting it from memory. Every time.

This is customer care with **repeated tickets** without a knowledge base: an endless copy-paste of answers that someone, somewhere, has already written — but which do not live in any shared place. The cost is double. There is time: hours spent every day rewriting what has already been written a thousand times. And there is quality: every operator answers in their own way, with different words, sometimes with different (or wrong) information, because there is no *one* official answer, there are as many as there are people in support.

This article is for those who have a customer care drowning in repeated questions, and maybe are thinking "let's put an AI on it that answers by itself". I'll tell you the most important thing right away: **before the knowledge base, any AI is dangerous**. If you put an AI chatbot on top of a chaos of unofficial answers, you get a parrot that copies — quickly and with confidence — even the wrong answers. Let's see why you start from the knowledge base, what a ticket software for an SME really needs to do, how AI can help *by citing* instead of inventing, and what is the mistake that makes you lose the big customer.

## First the knowledge base, then (possibly) the AI

The temptation, faced with forty repeated tickets, is to jump straight to AI: "an assistant that answers frequently asked questions on its own". But this skips the step that counts, and which makes the difference between support that improves and one that worsens with a modern flair.

The step is the **knowledge base**: a single place where the *official* answers to recurring questions live. Not the personal versions of each operator, but the right, approved, updated answer: "Delivery times are X. The return is done like this. The invoice can be downloaded from here." One single source, which all operators use, so the answer to the customer is the same regardless of who replies, and it's the correct one.

Why does the knowledge base come *before* the AI, always? Because an AI is nothing but something that answers by fishing from a knowledge base. If that base does not exist, or is a chaos of old emails and contradictory answers, the AI fishes from the chaos and produces plausible and wrong answers — with the confidence that makes its wrong answers even more dangerous than those of an uncertain operator. **AI amplifies the quality of your knowledge base: if it's good, it helps; if it isn't there, it multiplies errors.** First build the right source, then (if needed) put the AI on top of it. Never the other way around.

It's the same principle as the [data model under every internal app]({{ '/en/blog/internal-app-copy-paste/' | relative_url }}): the part you see (the AI, the interface) works only if the part you don't see (the knowledge base, the data) is solid. Whoever sells you "AI for customer care" without asking you where your knowledge base is, is selling you the spectacular part while skipping the one that makes the answers true.

## The ticket as an object: statuses, SLAs, who the customer is

Even before the knowledge base, there is a basic problem in many customer cares: requests **are not tickets**, they are emails in an inbox. And an inbox is not a support tool: it's a hole where things get lost. You don't know which requests are open, which are waiting, which are forgotten; if two operators reply to the same one; how long a customer has been waiting; if something fell through the cracks.

A real ticket software, even a minimal one, turns requests into **objects with a state**:

- **Statuses**: open, in progress, waiting on customer, resolved. At a glance you know what needs to be done and what is waiting.
- **Assignment**: every ticket has a responsible person, so it doesn't happen that two people reply to the same one or that nobody takes it.
- **SLA (times)**: how long a ticket has been open, which ones are exceeding the response time you set yourself. The forgotten old ticket no longer exists, because the system flags it.
- **Who the customer is**: the card with the history — what they bought, what they already asked, if they are a €10 customer or a €100,000 customer. Answering knowing who is in front of you changes everything.

This is the skeleton. It's the same principle of the [visible queue, applied to support instead of orders or interventions]({{ '/en/blog/misaligned-warehouse-stock/' | relative_url }}): stopping keeping the state in an inbox and in your head, and putting it in a place where everything is seen. Without this, the knowledge base and the AI rest on nothing, because you don't even know what you're answering and for whom.

There is also a benefit for you managing: with real tickets, for the first time you see the **support picture**. How many requests arrive, about what, how long you take, what accumulates. An email inbox doesn't tell you; a ticket queue does. And that picture is the basis for improving not only support, but the product: if 30% of tickets are "I don't understand how to do a return", maybe the problem isn't the support, it's that the return process on the site is unclear. Customer care, read correctly, tells you where your product or process has friction.

## AI that cites the procedure, not that invents the refund

Now yes, AI — but done right, because here the difference between useful and disastrous is huge, and concerns one word: **citation**.

An AI for customer care done poorly works like this: it reads the question, "knows" something from who knows where, and generates an answer. The problem is that it *invents*: if it doesn't find the information, it doesn't say "I don't know", it produces it anyway, with a confident tone. And in customer care this is extremely dangerous, because the AI can invent a return policy that doesn't exist, promise a refund that isn't due, give wrong delivery times. The customer believes it (it's the official voice of the company), and you find yourself tied to a promise your bot made and you won't keep.

An AI done well works the opposite way: it answers **only by fishing from the official knowledge base, and cites the source**. "According to our returns procedure [link], you have 30 days to..." If the information isn't in the knowledge base, it says "I don't have an official answer, I'm passing you to an operator" — instead of inventing it. This is the golden rule of *AI risks in helpdesk*: **no answer without citation**. AI is not an oracle that knows: it's an engine that *finds* in your knowledge base and presents, with the reference to what it used. This way, if it makes a mistake, the error is verifiable (you can trace back to the source), and above all it doesn't invent company policies out of nowhere.

The practical consequence: AI becomes useful and safe only *after* you have a good knowledge base, and serves mainly two honest things — suggesting the right answer to the operator (who verifies and sends it), and answering truly simple questions covered by the knowledge base on its own, passing all the rest to a human. Not "AI that replaces support", but "AI that cites the knowledge base and knows when to keep quiet".

A concrete example of the difference. Customer: "can I return a product on sale?". *Inventing-AI*: "Sure, you have 30 days for returns" — and maybe sale items are excluded by your policy, so you just promised a return you won't do. *Citing-AI*: "According to our returns policy [link], products on sale follow these rules..." — and if the policy on sales isn't in the knowledge base, "I don't have an official answer on this, I'm passing you an operator". The first creates a problem; the second avoids it. That's the whole difference between an AI that is a risk and one that is a help.

## The living knowledge base: who updates it

A knowledge base is not a document you write once and forget: if you don't keep it alive, it ages and starts giving wrong answers — which is worse than not having one. Delivery times change, a new product is born, a return policy changes. Every time, the official answer must be updated in **one place only** — and everyone, operators, AI and customers, immediately sees the right version.

For this you need an **owner** of the knowledge base and a simple gesture to update it: when an operator notices an answer has changed or is missing, they must be able to flag it and fix it quickly, not open a project. A good system does even more: from incoming tickets it understands which new questions are emerging (a repeated question that isn't in the knowledge base is an answer to be written), so the knowledge base grows guided by what customers actually ask. It's the same principle of signed data definitions: written once, updated when they change, equal for everyone.

## Agent interface vs customer portal

As with other internal apps, there isn't just one screen: there are two sides, and they must be thought out differently.

**The agent side** is the working tool of whoever answers: the ticket queue, the state, the customer card with the history, the knowledge base a click away (or suggested by AI), and the possibility to answer quickly using official answers instead of rewriting them. The goal is to let the operator close more tickets, better, with less effort — and with coherent answers.

**The customer side** is the portal (or help center) where the customer finds the answers to the most common questions on their own, checks the status of their request, opens a ticket without sending an email into the void. A good self-service, fed by the same knowledge base, **eliminates the volume of repeated tickets at the root**: if the customer finds "where is my order" and "how do I return it" on their own, that question doesn't even arrive. It's the most effective way to reduce the 40 tickets a day — not answering faster, but making sure half don't arrive.

Notice the thread: single knowledge base underneath, two faces on top — the operator answering by citing, the customer serving themselves. Same source, two uses.

## Deflection: making tickets disappear before they arrive

There is a concept worth more than any answer automation: **deflection**, that is, making sure the ticket doesn't even arrive. Every question the customer finds an answer to on their own — in the help center, on the "where is my order" page, in a well-written FAQ — is a ticket that doesn't enter the queue, doesn't occupy an operator, doesn't wait for an answer. It's the most powerful way to reduce the 40 tickets a day, because you don't manage them faster: you eliminate them at the source.

The paradox is that good deflection also improves satisfaction: the customer doesn't like opening a ticket and waiting, they like finding the answer right away. A clear help center, fed by the knowledge base, with the top questions highlighted and maybe the order status accessible on their own, gives the customer what they want (the answer, now) and you what you want (fewer tickets). It's not putting a wall between you and customers: it's giving them the shortest route to what they seek, keeping support people for the cases where people are really needed.

## A single channel: email, chat, WhatsApp, social in one place

Another piece of the chaos: requests arrive from a thousand places — email, site form, chat, WhatsApp, social messages — and each lives in its own inbox. So a customer writes on Instagram and then sends an email, and nobody connects the two things; or a request on WhatsApp goes unanswered because only one person looks at that phone. The minimum useful is to make **all channels flow into one place**, where every request becomes a ticket regardless of where it arrived from.

You don't need to manage twenty channels: you need yours, the ones customers actually write from, in a single queue. This way no request falls through the cracks just because it entered through the wrong door, and a customer's history is one, not scattered across five apps.

## When you are "too small" for an enterprise helpdesk

There is a fair objection: "serious helpdesk software is for large companies, it costs and is complicated; we are three people in support". True, and you don't have to buy enterprise Zendesk with a hundred features to answer forty tickets. But "too small for enterprise" doesn't mean "stay on the email inbox": it means you need **the right minimum for your size**.

The minimum, for an SME, is: requests as tickets with a state, a shared knowledge base, a self-service for customers on top questions, and — if the volume justifies it — an AI help that cites. No hundred-branch workflows, no automations for a thousand-person call center. An enterprise helpdesk dropped on a small team is like the fifty-mask ERP: it does everything except help you answer quickly, because the simple thing is buried under the rest. The right product for you is small, targeted, and grows with you — not a monster to configure for six months.

## Metrics: repeated, time, escalation

How do you know if your support is improving, and what to act on? Three numbers, above all.

- **Repeated tickets**: how many requests are the same recurring questions. It's the number that tells you how much self-service and knowledge base you need: if 80% of tickets are ten questions, those ten answers, put in a portal, remove 80% of the work.
- **Response and resolution time**: how long a customer waits, how long it takes to close. But be careful not to optimize only speed (we'll come back to this): closing quickly by dismissing is not resolving.
- **Escalation and first contact rate**: how many requests are resolved on the first try and how many bounce between people. A high escalation signals that the knowledge base isn't enough or that the right cases don't reach the right person immediately.

These numbers, before, you didn't have because an email inbox doesn't measure them. With real tickets they become the support dashboard — and it's the same leap from managing by gut to [deciding on numbers]({{ '/en/blog/owner-dashboard/' | relative_url }}) I talk about for dashboards, applied to care.

## The mistake that makes you lose the big customer

There is a mistake that deserves its own section, because it's the one that costs the most: **treating all tickets equally, and optimizing only volume**. When the pressure is "close as many tickets as possible", operators (or worse, AI) learn to dismiss quickly. And that's fine for the trivial question from the €10 customer. But the ticket from the €100,000 customer — the one with a serious problem, maybe already angry — treated with the same fast standard response, is a lost customer. And a lost big customer is worth more than a thousand quickly closed tickets.

This is why the "who the customer is" card and statuses matter so much: they serve to **not treat everyone the same**. The system must make important tickets emerge — strategic customer, serious problem, dragging request — and bring them immediately to a real person, with context. AI and automation handle repetitive volume; people handle cases that matter, with all the time needed. A customer care that optimizes only "tickets closed per day" is measuring the speed with which it gets rid of customers, not the quality with which it helps them. It's the classic trap of the [wrong KPI that looks like efficiency and hides lost customers]({{ '/en/blog/wrong-company-kpis/' | relative_url }}).

## A typical case: from five questions to the help center

A typical profile, architectural, no names. E-commerce with three people in support, requests via email and social messages, all in different inboxes. 80% of questions were five: where is the order, how do I return it, delivery times, invoice, size change. Every operator answered in their own way, fishing from old emails, with different times and words — and occasionally a wrong piece of information (an outdated delivery time).

What was done. First the **knowledge base**: the twenty most frequent questions were taken and the official answers written, in one place. Then **real tickets**: every request, from any channel, becomes a ticket with state and assignment. Then a **help center** for customers with the top five questions, and a help for operators that suggests the answer from the knowledge base, citing it.

After: repeated tickets plummeted, because half the customers find the answer on their own in the help center. Operators answer faster and — above all — in the same way, the right one, because they fish from the knowledge base instead of memory. And important cases (the angry customer, the serious problem) emerge instead of drowning in the pile. With the usual note: the value wasn't "ticket software", it was the knowledge base — official answers written once — that didn't exist before.

## Where to start

If we decided to start, the first step isn't choosing ticket software: it's **writing the answers**. Take your 20-30 most frequent questions — you already know them, you receive them every day — and for each write the official, correct, updated answer. This is the knowledge base, and it's 80% of the value. You can start it today, in a document, for free.

The second step is looking at the numbers: which questions repeat the most? How many tickets a day? How much time to answer? That light audit tells you which answers to put first in the help center (those remove the most work) and if the volume justifies an AI help or if the knowledge base plus self-service is enough. You start from real questions, not from a software demo.

## It's for you if / it's not for you if

**It's for you if:** your customer care answers the same questions every day by copying old answers; you manage support from an email inbox where things get lost; every operator answers in their own way; you are thinking of an AI for support but fear (rightly) it will invent; you have big customers you don't want to treat like everyone else.

**It's not for you if:** you receive very few requests and manage them perfectly by hand; your tickets are all different and complex, with no repetition to automate (rare); you are looking for "the AI that makes customer care disappear" — because the right support uses AI for volume and people for cases that count, it doesn't eliminate the human.

## Frequently asked questions

**Do I have to buy expensive helpdesk software?**
No. You need the right minimum for your size: tickets with state, shared knowledge base, self-service for customers, and possibly an AI help that cites. An enterprise helpdesk from a large company is almost always oversized and slows you down instead of helping.

**Can AI answer customers on its own?**
Yes, but only simple questions covered by the knowledge base, and citing the source. Everything else it must pass to a human. The rule is: no answer without citation, and when it doesn't know, it says so and calls a person. An AI that invents answers in customer care is a risk, not a saving.

**How do I build the knowledge base?**
Starting from the questions you already receive: collect the 20-30 most frequent, write the official and updated answer for each, and put them in one place. They are probably 80% of your tickets. You don't need to document everything: you need to document what they actually ask.

**Do I really reduce tickets or just manage them better?**
Both. Self-service (the customer finds out alone) *reduces* repeated tickets at the root; the knowledge base and real tickets let you *manage better* those that remain. The number to watch is repeated tickets: when it drops, you're winning.

**What if I have large and delicate customers?**
Precisely for them you need not to treat everyone the same: the system must highlight important tickets and bring them immediately to a person, with the customer's history in front of them. Automation frees up time *to* dedicate it to cases that count, not to dismiss them like the others.

**Requests arrive from many different channels, is that a problem?**
It's a problem if each lives in a separate inbox. The solution is to merge them into a single ticket queue: emails, forms, chat, WhatsApp, social all become tickets in one place, with a single history per customer. You don't need to manage every channel in the world: you need yours.

**How long to get started?**
You start the knowledge base immediately (it's writing the answers you already give). The ticket system plus self-service is set up in a few weeks. The citing AI, if needed, is added later, on the already good knowledge base. You start from the piece that gives the most value: almost always the knowledge base and self-service on top questions.

**Do the data (knowledge base, ticket history) stay mine?**
Yes. The knowledge base, ticket history and customer cards remain yours, no lock-in. They are an asset: the knowledge base is the memory of your support, and the ticket history tells you what to improve in the product and process.

## In one line

If your customer care answers the same questions 40 times a day by copying old answers, you aren't missing "an AI": you are missing a **knowledge base** — the official, single, updated answer — and **real tickets** (statuses, SLAs, who the customer is). On that foundation, a self-service eliminates repeats at the root and AI can help *by citing* instead of inventing. And above all: don't treat all tickets equally, or by optimizing volume you lose the customer who matters.

If you want to understand how to build the knowledge base and right tickets for your size — without a multinational helpdesk — look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a couple of lines]({{ site.main_site }}/contatti/): we start from the questions you actually receive, not from catalog software.
