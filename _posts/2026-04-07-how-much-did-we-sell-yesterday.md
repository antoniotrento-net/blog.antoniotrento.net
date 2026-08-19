---
lang: en
permalink: /en/blog/how-much-did-we-sell-yesterday/
alt_url: /it/blog/quanto-abbiamo-venduto-ieri/
title: "The owner asks 'how much did we sell yesterday' and nobody answers in 10 minutes: this is the real software you're missing"
date: 2026-04-07 07:30:00 +0200
author: "Antonio Trento"
description: "'How much did we sell yesterday?' should be the easiest question in the company — and nobody answers quickly. Why, what actually counts as sold, and the screen that answers in twenty seconds."
keywords: ["how much did we sell yesterday", "daily sme sales", "owner dashboard", "real-time data small business", "daily sales report"]
image: /assets/images/posts/quanto-abbiamo-venduto-ieri.jpg
pillar: prodotti-dati
services: [portfolio, contatti]
related: [/en/blog/owner-dashboard/, /en/blog/late-sales-report/]
---

## The simplest question in the world, and nobody can answer

"How much did we sell yesterday?"

It's the most natural question an owner can ask. They don't ask for an analysis, they don't ask for a forecast, they don't ask for a model. They ask for a fact, one only, about a day that has just passed. And yet, try asking it in any company at nine in the morning, and watch what happens: a small treasure hunt starts. Someone opens the ERP/gestionale but "the day isn't closed yet". Someone else looks at the e-commerce, which however is only a piece. The admin lead says "wait, I'll check". And after ten minutes, if you're lucky, you have a number nobody is entirely sure of.

If you search Google for "**how much did we sell yesterday**" — and more and more owners do, maybe by voice from the phone — it's because you've understood something: that number should be there, ready, every morning, and it isn't. You're not missing a nicer report, you're not missing a data office. You're missing **the** software that answers the most elementary question in your company in twenty seconds, from the phone, while you drink the first coffee. This article is about that missing software: why ten minutes is already too much, what actually goes into the definition of "sold" (the piece everyone underestimates), how you put the channels together, and what the screen you need looks like.

If your problem is broader — not only "yesterday", but numbers scattered across six tools and decisions taken by gut — you're better off starting from the article on [how to have a dashboard when the data is in six different places]({{ '/en/blog/owner-dashboard/' | relative_url }}). Here we stay focused on the spoken question, the everyday one.

## Why ten minutes is already too much

"Come on, in ten minutes the number comes out, where's the problem?" The problem is deeper than those ten minutes, and it's worth understanding.

First: **ten minutes means the number is not a fact, it's a search.** Every time someone has to *go looking* for how much you sold yesterday, they're reconstructing a piece of information that should already be there. And every reconstruction by hand is an opportunity for error, for forgetting, for "ah, I hadn't counted that channel". A number you search for is a number you can't entirely trust.

Second: **friction kills the habit.** If to know how yesterday went you have to bother someone and wait ten minutes, you won't ask every day. You'll ask when you have a doubt, which is too late. The value of knowing "how much did we sell yesterday" isn't in the single number: it's in *looking at it every day*, so that the anomaly — the drop, the spike, the strange day — jumps out at you immediately, not at month-end. But you only look every day at what's at thumb's reach. Ten minutes of friction and the habit never forms.

Third, the subtlest: **if it takes ten minutes, it means behind it there isn't a system, there's a person.** And people have holidays, sick days, other priorities. The day that person isn't there, the question stays unanswered. You've built the knowledge of your daily numbers on a fragile balance. That's the same reason why [reports always arrive late]({{ '/en/blog/late-sales-report/' | relative_url }}): behind the delay there isn't laziness, there's manual work that no system does in people's place.

The truth is that "how much did we sell yesterday" is the most honest test of the health of your data. If the answer arrives in twenty seconds, from the phone, the same for everyone, then your numbers are in order. If it takes ten minutes and three people, you have a problem that goes well beyond that single number.

## What actually goes into the definition of "sold"

Here's the piece almost everyone skips, and it's the one that makes the difference between a true number and a number that generates arguments. It looks like a trivial question — "sold is sold, right?" — and instead "sold" is one of the most ambiguous words in the company. Before you can answer in twenty seconds, you have to have decided, once and for all, what you count.

Look how many choices hide behind a single word:

- **Order, invoice or collection?** Did you "sell" yesterday when the customer ordered, when you issued the invoice, or when the money arrived? They're three different days and three different numbers. Sales thinks of the order, admin of the invoice, the bank of the collection. If you don't choose, each one will give you theirs.
- **With or without IVA/VAT?** "Yesterday we did 12,000" — gross or net? It changes the number by over 20%. Half the arguments about "how much we sold" are born here.
- **Returns, when do you take them off?** A return today on an order from yesterday: do you deduct it from yesterday's sold (which therefore changes after the fact) or from today's? Both choices are legitimate, but they have to be decided.
- **Giveaways, employee discounts, samples?** A product that went out at zero cost is "sold"? In quantity yes, in value no. It depends on what you want to see.
- **Credit notes, deposits, subscriptions?** Is a deposit on a future order sold yesterday? Does an annual subscription paid yesterday all count yesterday or does it get spread? Every business model has its traps.

None of these has a universally "right" answer. It has *your* answer, which depends on what you want that number to mean. The solution isn't technological, it's a **written and signed decision**: "In our dashboard, sold = orders received yesterday, IVA/VAT excluded, returns deducted on the order date, giveaways excluded from the value." One line. But from that moment there is *one* number, and whoever disagrees argues the definition, they don't contest the screen.

This is the invisible work that makes the "twenty seconds" possible. The number appears quickly because the effort was done before, once: deciding what sold means. Whoever promises you the dashboard without asking you this question is building you a faster argument-generator.

## The channels: store, web, reps, marketplace

There's a second reason why "how much did we sell yesterday" is hard, and it has to do with the *channels*. In a modern company, even a small one, you sell in more than one place at the same time, and each one tells its sales in a different way and with a different timing.

Think of a typical company:

- The **physical store** records at the till, in near real time, but maybe the data only "enters" the ERP/gestionale at evening close.
- The **e-commerce** has its orders, immediately available via API, but with the snag of returns and cancelled orders that arrive later.
- The **reps / agents** send orders with a delay — at end of day, at end of week, sometimes by email in a spreadsheet — so their "yesterday" is out of phase.
- The **marketplace** (Amazon and the like) has rules, timings and commissions all its own, and the gross "sold" there is not at all the "sold" you collect.

The result is that "how much did we sell yesterday" is not *one* number to read in one place: it's *four* numbers to put together, each with a different format and a different delay. That's why the person takes ten minutes: they're doing by hand a channel-consolidation job that a system should do, every night, automatically.

An example of the timing mess: Monday morning you ask for the sold of "yesterday", Sunday. The store was closed (zero, correct), the e-commerce sold all night (data ready), the agents don't work on Sunday but will load Saturday's orders on Monday (so "Saturday" isn't complete yet). Whoever adds up by hand risks saying "Sunday we did little" without noticing they're mixing days with different completeness. A system that knows the timings of each channel doesn't make this mistake: it knows what's final and what's still incoming, and it tells you.

And here there's an important product choice: the dashboard must tell you both the **total** (how much we sold yesterday, all channels together) and the **detail by channel** (how much the store, how much the web, how much the agents). The total tells you how it went; the detail tells you *where*. A drop in the total can hide a store growing and an e-commerce collapsed because of a technical problem: without the detail by channel, you only see that "yesterday went badly" and you don't understand why. Putting the channels together with the same yardstick — the same definition of sold for everyone — is half the work, and it's exactly what a spreadsheet filled in a rush doesn't do.

## Why "we already have it in the ERP/gestionale" isn't enough

A frequent objection: "but yesterday's sold, the ERP/gestionale has it, you just have to look at it". In part that's true, and in part that's exactly the problem. The gestionale knows *its* sold — what goes through it — but it almost never knows everything. The e-commerce is often a world apart; the agents load with delay; the marketplace has its own accounts. So the gestionale's number is a piece, not the total, and reading a piece thinking it's the whole is worse than reading nothing, because it gives you false confidence.

Then there's a usability problem. Even when the ERP/gestionale has the data, to pull it out you have to go in, navigate menus, launch a report, filter the dates, export. It isn't something you do from the phone in the car at eight: it's something someone sitting at a computer does — and in fact we're back to the ten minutes. The gestionale was born to *record*, not to *answer a question in twenty seconds*. They're two different jobs. A dashboard doesn't replace the ERP/gestionale: it reads on top of it (and on top of the other channels), agrees the definitions and serves you the answer ready. Whoever tells you "use the gestionale you already have" hasn't understood the question: it isn't "where the data lives", it's "how do I get the answer without sitting down to look for it".

## The screen from the phone, in the car, at eight

Now the concrete part: what the software that answers "how much did we sell yesterday" looks like. I'll describe it from the moment you'll actually use it, because that's where you understand if it's done well.

It's eight, you're in the car (or at the bar, or still at home). You open the phone. Not a complicated app, not a login to re-enter every time, not twenty charts: **one big number, at the top.** Sold yesterday. Next to it, the comparison that gives it meaning: "yesterday" versus the same day of last week (because comparing a Monday with a Sunday says nothing), with the variation in percentage and a colour. Green if on track, yellow if below, red if well below.

Under that number, three things and no more:

- The **detail by channel**: store, web, agents, marketplace, each with its slice and its arrow.
- The **month up to yesterday** compared with the same period last month — because "yesterday" also has to be read inside the month's trend.
- An **alarm**, if there's something to know: "yesterday the web is at zero, possible technical problem", "the store is at −40% for three days".

That's all. In twenty seconds you know whether to sleep easy or pick up the phone. If you want to go into the detail — the best-selling products, the customers, the receipts — it's a tap away, but it isn't the first thing you see. The first thing you see is the answer to the question you asked yourself: how much did we sell yesterday, and how is the month going.

Notice what *isn't* there: nothing to fill in, no file to open, nothing to ask anyone. The dashboard is already ready when you open it, because overnight it already took the data from the channels, cleaned it with your definitions, put it together. That's the difference between a number you *search for* and a number that *waits for you*. And that's why "real-time data small business" almost never needs to be to the second: you need yesterday to be ready this morning, not now to be updated instantly. True real time costs ten times as much and is useful to very few.

## The same number for everyone (no more different versions)

A collateral benefit, but anything but secondary: when "how much did we sell yesterday" comes out of a system with a signed definition, the number is one only, the same for everyone. The owner, sales, admin look at the same yesterday's sold, calculated the same way. It looks obvious and it isn't: today, in many companies, everyone has "their" version — sales counts the orders, admin the invoices — and meetings start with ten minutes of "no, my data says something else".

A single number isn't only more convenient: it changes the climate. You stop arguing about who's right on the numbers and you start arguing about what to do. It's a small change with a large effect, because it moves the energy from defending your own sheets to the shared decision. And it holds for yesterday's number as for any other: the first function of a good dashboard isn't to show, it's to get people to agree.

## Alarms: when "yesterday" is anomalous (even if the total looks fine)

There's a function that turns this dashboard from "nice to look at" to "indispensable", and it's the anomaly alarm. Because the problem with looking at a number every morning is that the eye gets used to it, and slow or localised drops slip through. The alarm looks in your place.

A good alarm system on "how much did we sell yesterday" flags two kinds of things. The **business anomalies**: a product dropping for three days, a channel slowing down, a regular customer who no longer buys, a day well below the norm for that day of the week. And — this everyone underestimates — the **technical anomalies**: if the e-commerce yesterday shows zero sales, it's almost never a commercial collapse; usually it's a broken integration, a payment that isn't working, a site down for a few hours. Without the alarm, you discover the technical problem days later, counting the missed collections. With the alarm, you get a message in the morning and you fix it the same day.

There's something important to understand: a total can look fine and hide an anomaly. Yesterday you sold as usual, all green — but the store did double (there was an event) and the web collapsed (it was broken). The total is normal, the situation isn't. That's why the alarm must also look *inside* the channels and the products, not only the big number at the top. The average, as always, hides the worlds.

## Who maintains the definitions (or the number starts lying)

Let's pretend we've built it: the definitions are decided, the channels connected, the screen works, the alarm fires. Finished? No, and this is the part almost nobody tells you before you sign. A dashboard lives only if someone **maintains the definitions**.

Because things change, continuously. You open a new channel (the marketplace) and "sold" has to be redefined to include it. The ERP/gestionale updates a field and the pipeline that was reading it breaks. You launch subscriptions and you have to decide how to count them. You change the way you discount. Every time, if nobody updates the rules, the number starts lying — and it lies *in silence*, which is worse than a delay, because a delay you know, a wrong number that looks fresh makes you decide badly with confidence.

That's why two things are needed. A **maintenance** (who puts their hands on it when something changes, with what timings) and an internal **owner**: someone whose number it is, who looks at it every morning and notices when it's strange. A dashboard without an owner is a dashboard that, the day a definition needs updating, nobody updates — and you're back to not trusting the numbers, only with a nicer interface. The good news: owner doesn't mean a new full-time person. It means the number has a name next to it, and a channel to get it fixed when needed.

## The habit that changes the days

There's a value in all this that you don't see in a quote, and that is perhaps the largest: the habit. When "how much did we sell yesterday" is at thumb's reach, without friction, you start looking at it every morning — not because you imposed it on yourself, but because it's there, like the notifications. And looking every day changes the way you run the company. You no longer wait for the month-end meeting to discover a trend: you feel it being born day by day. A three-day drop puts you on alert on the fourth, not at month-end. A spike makes you ask "what did we do differently?" while you still remember.

It's the difference between driving looking at the road and driving looking in the rear-view mirror. Yesterday's number, every morning, keeps your hands on the wheel of the present. And this daily closeness to the numbers, for an owner, is worth more than any perfect report that arrives late: because the best decisions aren't the ones taken with the most precise data, but the ones taken *in time*. The software that answers "how much did we sell yesterday" doesn't only give you a number: it gives you the habit of looking at it, and it's the habit that changes the results.

## Small vs medium: two depths of project

A fair question is: "but how big is a project like this?". It depends, and it's worth distinguishing two depths, because the honest solution isn't the same for a shop and for a small industry.

**For the small** (a shop, an e-commerce, a business with one or two channels and an orderly ERP/gestionale), the project is light. The definitions are few, the channels few, and often in a few weeks you have your "how much did we sell yesterday" on the phone with the alarms. Sometimes, for very simple cases, even a good connection between two tools you already have can be enough. The important thing is not to let yourself be sold a multinational-scale project for a one-channel problem.

**For the medium** (more channels, agents, warehouse, maybe more sites, more intricate definitions), the real work is agreeing the sources and the definitions, and there the project is more substantial — but the value is also much higher, because every day of delay and every wrong number costs more. Here "how much did we sell yesterday" is often the entry door to a broader dashboard, which then grows towards margin, cash, warehouse.

The advice, in both cases, is to **start from this question** and not from a big abstract project. "How much did we sell yesterday, all channels, on my phone, with an alarm" is a small, concrete, verifiable objective. If you bring it home, you've already changed your days; and from there, if anything, it widens. Better a true number tomorrow than a perfect platform in a year.

## A typical case: from ten minutes to twenty seconds

A typical profile, architectural, no names. A company with a store, e-commerce and a small network of agents. Every morning the owner called admin to know how it had gone: five–ten minutes, the ERP/gestionale number (which excluded the web), and a "for the rest I'll tell you later". The web they checked themselves, when they remembered; the agents they discovered at end of week. They never had, at a glance, the real sold of yesterday.

What was done. First the definitions: sold = yesterday's orders, IVA/VAT excluded, returns deducted on the order, the same for all channels. Then the connection of the three channels in one place, every night, with the handling of the agents' delays (their "yesterday" arrives out of phase, and the dashboard declares it instead of pretending otherwise). Then the screen on the phone: total, three channels, month up to yesterday, one alarm.

After: the owner no longer calls anyone. At eight they have the number, all channels together, with the comparison arrow. Two weeks after go-live, the alarm flagged the e-commerce at zero: not a collapse, a payment plugin broken the evening before. Fixed by nine, instead of discovering it on Monday counting the missed orders. That single episode, on its own, had already paid back a slice of the project. The value wasn't "a nice app": it was stopping chasing a number that now waits for them.

## What it costs not to know yesterday

Let's put a number on not knowing it, because it looks free and it isn't. The cost isn't (only) the time of the ten minutes — though that's real: five–ten minutes a day of two people make hours every month. The true cost is in the things you don't see in time.

A channel that breaks and stays broken for days: every day of e-commerce down is lost sales that don't come back. A drop that starts on Monday and that you only notice at month-end, when you could have reacted in three days. A product that's moving and that you reorder late because you didn't look. One of these episodes every few months is enough, on its own, to exceed any cost of the project. And they're episodes that, without yesterday's number under your eyes every morning, you simply don't catch: they don't leave a line in accounting labelled "I didn't notice in time", they only leave a lower number than it could have been. Knowing yesterday, every morning, isn't a manager's tic: it's the cheapest way to notice problems while they're still small.

## From yesterday's number to the rest: the entry door

"How much did we sell yesterday" has a quality that makes it the ideal starting point: it's small and concrete, and once solved it naturally opens the next doors. Because the moment you've agreed the definitions and connected the channels to answer *this* question, you've already built a good part of the foundations to answer the others.

From yesterday's sold, the natural step is sold by product and by customer (what's moving, who buys). Then the margin, not only the revenue (how much we keep, not how much we turn over). Then cash (collected next to sold). Then the warehouse (what's running out of what sells). Each step reuses the sources and the definitions of the first. That's why it pays not to start from a big abstract project but from this specific question: it's the most useful right away, and it's also the brick on which you build everything else. Whoever starts from the "perfect platform" often never gets to answering yesterday's question; whoever starts from yesterday's question finds themselves, almost without noticing, with the foundations of a real dashboard. That complete path — from dashboards to KPIs to dashboards people actually use — is in the [guide to dashboards and data products]({{ '/en/pillar/data-products/' | relative_url }}).

## It's for you if / it isn't for you if

**It's for you if:** you ask "how much did we sell yesterday" and the answer arrives late, uncertain, or different depending on who gives it; you sell on more than one channel that don't talk to each other; you'd like to look at how things are going every morning but you don't because it's inconvenient; you've noticed more than once a problem (a broken channel, a drop) too late.

**It isn't for you if:** you have a single simple channel and yesterday's number you already have clear and reliable; you need a one-off figure, not a daily tool; your data at the source doesn't exist yet (if you record sales in a notebook, that gets fixed first); you're looking for "the AI that decides in your place" — here automation puts things together and flags, the decision stays yours.

## Frequently asked questions

**Why can nobody tell me quickly how much we sold yesterday?**
Because behind that number there isn't a system, there's a person who puts together by hand more than one channel with more than one definition. As long as it's manual work, it will always be slow, uncertain and dependent on whoever does it. The solution is to automate the consolidation and lock the definitions.

**What exactly does "sold" mean?**
It means what you decide: orders or invoices, with or without IVA/VAT, returns deducted when, giveaways included or not. There isn't a universal answer, there's *yours*, which has to be written and signed once. It's the most important piece of work and the most skipped.

**Do I need real time to the second?**
Almost never. You need "yesterday" to be ready this morning, not "now" to be updated instantly. True real time costs a lot more and is for a few particular cases (for example large events or flash sales). To decide, yesterday is more than enough.

**Does it work if I also sell on Amazon or on marketplaces?**
Yes, but with care: a marketplace's gross "sold" isn't what you collect, because of commissions and returns. A good dashboard keeps the channels with the same yardstick and shows you both the gross sold and what actually counts for you. It has to be decided in the definitions phase.

**How much does it cost and how long does it take?**
It depends on the channels and how orderly the data is at the source. For a small with one–two channels, a few weeks and a light project. For a medium with more channels and agents, more — but "how much did we sell yesterday" is still an excellent small starting point, from which to widen.

**And if my data is a disaster?**
That's the norm, not the exception. Part of the work is writing the rules to clean it and put it together. But nobody invents data that doesn't exist: if a channel doesn't record sales reliably, the collection gets fixed first.

**Do the data and the system stay mine?**
Yes. Code, definitions and data stay your property, no lock-in. Your "how much did we sell yesterday" must not depend on a vendor who holds the keys.

**Can I have the number via message instead of opening an app?**
Yes, and it's often the best solution for an owner: every morning a message (email, Telegram, whatever you use) with yesterday's sold, the channels and any alarm. Zero friction, you read it like any message. The app stays for when you want to go into the detail.

**How do you handle channels that arrive late, like the agents?**
The dashboard declares it instead of hiding it: it shows yesterday's sold with a note like "agents updated as of the day before yesterday" until the data arrives. Better an honest number with its uncertainty than a fake total that looks complete and isn't.

**Do I need to change ERP/gestionale or e-commerce?**
Almost never. A good dashboard reads from what you already have and puts the pieces together. If someone proposes rebuilding the gestionale to give you yesterday's sold, stay away: it's like demolishing the kitchen to know what time it is.

**Can't I just ask someone every morning?**
You can, and that's exactly what you do now: it's the problem, not the solution. Depending on a person for a number that should be automatic means slowness, uncertainty and a hole every time that person isn't there. The goal is that the number waits for you, not that you chase it every day.

## In one line

If you ask "how much did we sell yesterday" and in ten minutes nobody answers with certainty, you're not missing a report: you're missing **the most elementary software a company should have** — one number, all channels together, with a definition decided once, on your phone every morning, with an alarm when yesterday was anomalous. It's the most honest test of the health of your data, and it's also the most concrete starting point to put things back in order.

If you want "how much did we sell yesterday" to become a twenty-second answer instead of a treasure hunt, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a couple of lines]({{ site.main_site }}/contatti/): we start from your channels and from your definition of "sold", not from a demo.
