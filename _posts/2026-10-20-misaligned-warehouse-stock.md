---
lang: en
permalink: /en/blog/misaligned-warehouse-stock/
alt_url: /it/blog/giacenze-magazzino-disallineate/
title: "Three warehouses, one e-commerce, the reps: three 'truths' about remaining stock and orders you can't fulfill"
date: 2026-10-20 07:30:00 +0200
author: "Antonio Trento"
description: "If the site, the ERP and the reps state three different stock levels, you sell what you don't have and block what is there. Here's how to build a single truth on stock, with honest availability in every channel."
keywords: ["misaligned warehouse stock", "multichannel ecommerce stock", "wrong inventory levels", "sme warehouse software", "product availability"]
pillar: app-interne
related: [/en/blog/field-technician-app/, /en/blog/internal-app-copy-paste/]
---

## You sold what isn't there (and you didn't sell what was there)

There is a phone call nobody wants to make: the one to the customer to tell them that the order they just paid for online cannot be fulfilled, because the product isn't actually there. The site said "available", the warehouse says "finished three days ago". The customer is angry, you look bad, and sometimes you also lose the future sale. This is **overselling**: selling what you don't have.

And there is its silent twin, even more insidious because you don't see it: **underselling**. The product is there, in a warehouse, but the site shows it as "out of stock" because it only looks at the remainder of another depot. So you say no to a customer who would have bought, and the goods sit there gathering dust. Nobody calls you angry about this — you simply don't collect the money, and you don't notice.

The root of both is the same: **misaligned warehouse stock**. The site says one thing, the ERP/gestionale another, the rep visiting the customer says a third looking at their spreadsheet from yesterday. Three systems, three "truths" about the remainder, and each channel sells (or doesn't sell) on a wrong number. This article is for those who sell in multiple places — store, e-commerce, agents, marketplace — and have more than one warehouse or depot. Let's see why the remainders never match on their own, what each channel needs to see, the three mechanisms almost everyone gets wrong (returns, transfers, order commitment), and how to arrive at **honest availability in every channel** without buying a multinational WMS you don't need yet.

## Three systems, three remainders: why they will never align on their own

Let's take an inventory of the disaster. In a company that sells on multiple channels, the same quantity of product is recounted by different systems, each with its delay and its rules:

- The **ERP/gestionale** has the "official" remainder, but it updates when someone records the movements — often at end of day, sometimes the day after.
- The **e-commerce** has its stock, which deducts when an online order arrives, but knows nothing about what was sold in the store two minutes ago.
- The **physical store** deducts at the till, but that data enters the ERP only at closing.
- The **reps** work on an availability-price list that was sent to them yesterday (or last week) and take orders on already old numbers.
- The **marketplace** (Amazon and the like) has its own copy of the stock, which you update with its timings and its rules.

Each of these is right from its point of view, and they are all wrong together, because nobody sees the complete picture. The true remainder — how much is really there, available to be sold, right now — doesn't live in any of these systems: it lives in the difference between them all, and that's why we "take inventory" once a year and it never adds up.

The key point to understand is that **these numbers will never align on their own**, however good the people are. As long as each channel keeps its copy and updates them by hand with different delays, the divergence is mathematical: two systems deducting the same product at different times, without talking to each other, always diverge. It's not a problem of attention, it's a problem of architecture. It's the same principle as the numbers scattered across multiple softwares that I talk about for [company dashboards]({{ '/en/blog/owner-dashboard/' | relative_url }}): as long as there are multiple copies of the same truth, the truth does not exist.

## Marketplaces: you play by their rules

Marketplaces deserve a separate chapter, because there you don't decide the rules. Amazon and the like keep their copy of your stock, update it with their timings, and penalise you heavily if you sell something you can't ship. Overselling on a marketplace isn't just a disappointed customer: it's a hit to your seller reputation, which on those platforms is worth your survival. That's why the marketplace is often the channel where most prudence is needed — a buffer stock, more frequent updates, and the certainty that the availability you send them is already net of what you have committed elsewhere. It's exactly the kind of problem a single source solves: sending every marketplace a number you can trust, instead of a copy that diverges on its own.

## The single truth: one source, many views

The solution is not "synchronising better" five copies: it's having **a single source of truth on stock**, and having all channels read that. One place, only one, that knows how much of each product is in each warehouse, in near real time, and to which the site, the store, the agents and the marketplace ask for availability instead of each keeping their own copy.

When there is a single source, overselling and underselling disappear at the root, because there are no longer "three truths" to reconcile: there is one number, and everyone looks at that. The question "how much is there?" finally has **one** answer, the same for the customer on the site, for the visiting agent and for whoever prepares the shipment.

There is also a less obvious benefit: with a single source, inventory stops being a traumatic annual ritual. If the truth updates continuously with real movements, the physical count only serves to verify small discrepancies, not to reconstruct from scratch what's there. You go from "we close for three days for inventory" to spot checks during the year, and the number is always right enough to be able to sell on it.

But beware — "one source" does not mean "an identical number shown to everyone". And here is the interesting part: the truth underneath is single, but what each channel *sees* can (and must) be different.

## What the site, the agent and the warehouse must see

Here is the piece almost everyone gets wrong: showing the raw remainder to everyone. It doesn't work, because every channel needs a different view *on the same truth*.

- **The site** must not show the exact number, it must show a **reliable promise**: "available", "last few items", "available in 3 days". The customer doesn't care if there are 4 or 47; they care to know if they'll receive it and when. And above all, the site must see the availability *net* of what has already been committed by other orders not yet fulfilled (we'll get there).
- **The visiting agent** must see what they can *really* promise the customer in that moment — real availability, not yesterday's spreadsheet — and maybe know if a product finished here is available in another depot, so they don't lose the sale.
- **The warehouse** must see the real physical remainder, by department and location, to prepare shipments and know what's missing. They need the raw, operational number.
- **Management** must see the big picture: what's about to run out, what's been sitting for months, where the holes are.

Same truth underneath, four views on top, each calibrated to whoever is using it. It's the same principle of [internal apps with a few right screens for each role]({{ '/en/blog/internal-app-copy-paste/' | relative_url }}): not a single number shown identical to everyone, but a single source read in the right way by each.

A mistake I see often is showing the agent or the customer the same raw number as the warehouse worker. To the agent the remainder by location is useless and confuses them; to the customer the exact number creates rigid expectations ("there were 4 items an hour ago!"). Every view must be designed for the *decision* of whoever is looking at it: a promise for the customer, real availability and alternatives for the agent, physical operational for the warehouse.

## The three mechanisms almost everyone gets wrong

Having a single source isn't enough if you don't manage well three things that look like details and instead are the cause of 90% of misalignments: order commitment, transfers and returns.

**Order commitment (the most important).** When a customer orders a product but it hasn't shipped yet, that item *is physically still there* in the warehouse, but *it is no longer available* to sell: it is committed. If the system doesn't distinguish between "physical remainder" and "available to sell" (physical minus committed), disaster happens: two customers buy the last item, because for both it showed as "available". The availability the channels must see is not how much is there, it's **how much is there minus how much is already promised**. This concept — availability net of committed — is the single thing that, on its own, eliminates most overselling. A trivial but decisive example: you have 3 physical items, 2 have already been ordered and not yet shipped. The physical remainder is 3, but the available-to-sell is 1. If the site looks at the 3, it sells up to 3 and you promise 5 in total on 3 real ones: guaranteed overselling. If the site looks at the 1 (net committed), it promises only what you can really deliver. It looks obvious written like this, and it's exactly the distinction that is missing in most of the misalignments I see.

**Transfers between warehouses.** Goods that move from one depot to another, for hours or days, are in a limbo: they have left here but haven't yet arrived there. If you don't treat them well, they "disappear" from the first warehouse and don't yet "appear" in the second, or they end up counted twice. In a serious multi-warehouse, goods in transit are a precise, tracked status, not a hole.

**Returns.** A return that comes back is goods that become available again — but when? The moment it arrives, or after quality control? And in which warehouse? A badly managed return is ghost merchandise: it's physically there but the system doesn't count it, or the system counts it but it's broken and unsellable. The rules on returns must be decided and written, like the definitions I always talk about.

Whoever sells you "let's synchronise the stock" without talking to you about committed, transits and returns is selling you half a solution — the one that seems to work in the demo and breaks in the first real week.

## The agent's van is a moving warehouse

It's worth noting a special case of "warehouse": the agent's or technician's van. Whoever sells on a visit, or whoever repairs in the field, carries goods with them — samples, spare parts, products to deliver. That van is, to all intents and purposes, a moving warehouse, and if you don't treat it as such you have a hole in the stock: the goods "leave" the central warehouse and disappear from sight until a hand-written report comes back.

It's the same topic I discuss for [the field technician app]({{ '/en/blog/field-technician-app/' | relative_url }}): when the technician uses a spare part from the van, that must be deducted from the single source, or their vehicle's remainder is always wrong. In a serious multi-warehouse, vans are warehouses like the others — small, mobile, but real — and go into the same truth.

## Why a trade-fair WMS is (often) premature

At this point the temptation is: "let's buy a WMS", a complete warehouse management system, the kind you see at trade fairs with the 3D map of the shelves and the radiofrequency terminals. Stop, because for most SMEs it's **premature and oversized**.

An enterprise WMS solves problems that you perhaps don't have yet: optimisation of picking routes in a huge warehouse, management of hundreds of operators, sophisticated storage logic. If your problem is that the site and the ERP don't agree on the remainder, a WMS is a bazooka for a mosquito: it costs a fortune, requires months of implementation, and forces you to change how you work to adapt to it. And most of the time it doesn't even solve your real problem, which is the *misalignment between channels*, not the *internal optimisation of the warehouse*.

What is needed first, almost always, is simpler and more targeted: a single source of stock, order commitment managed well, and each channel reading the right availability. A focused product that solves the misalignment, not a giant system that solves problems you'll perhaps have in five years. The real WMS, if and when needed, will arrive on a base that is already orderly — and it will be a much easier decision.

## How much misalignment costs you

Let's put an order of magnitude on the damage, because misalignment looks like an annoyance and instead is a leak on three fronts. **Overselling**: every order you can't fulfill is a disappointed customer, a refund, often a negative review and a future lost sale — the cost is not the single order, it's trust. **Underselling**: every fake "out of stock" is a sale you don't make, and you don't even see it; on a large catalogue these are percentages of turnover slipping away silently. And **tied-up capital**: goods that show as "not there" while sitting in a depot are blocked capital that doesn't rotate, sometimes until obsolescence and zero-margin clearance.

Put the three together and the bill, even conservatively, is almost always much higher than the cost of fixing the stock. The uncomfortable point is that today you don't see this damage in any accounting line: overselling is paid by customers in trust, underselling is unborn revenue, tied-up capital is idle cash. Making them visible — with the KPIs of stockout and overselling — is already half the value of the project.

## A typical case: from non-matching inventory to the single truth

A typical profile, architectural, no names. Company selling technical items on three channels — store, e-commerce, agent network — with two warehouses. Recurring overselling on the site (customers ordering the item just sold in store) and agents losing orders because they took as out-of-stock what was in the other depot. The year-end inventory never added up, with differences nobody could explain.

What was done. First, the stock of the two warehouses was brought into a single source, with the clear distinction between physical and available-to-sell (physical minus committed). Then the channels were connected to read that source: the site shows "available / last items" net of committed, the agents see the real availability on both depots. Order commitment, transits and returns managed as precise statuses.

After: overselling collapsed (the site no longer sells what has already been promised) and sales recovered by the agents, who now see the other warehouse. Inventory began to add up, because there was a single truth updating with movements instead of three copies diverging. With the usual honest note: the first alignment brought to light that the starting numbers were wrong on dozens of codes — uncomfortable, but it was the moment they stopped selling on fake data.

## Rollout: one warehouse at a time

As with anything touching operations, the worst way to start is the "big bang": turning everything off and turning on the new system on all warehouses and all channels the same day. Too much risk, too many fronts open together, and if something goes wrong you block shipments — that is, revenue.

The way that works is in layers. You start from **one warehouse** (or one channel) as a pilot: you bring its stock into the single source, verify that the inventory matches, connect a channel and check that the availability shown is right. When that piece is solid, you add the second warehouse, then the third, then the other channels. Every step is verifiable and reversible; if something doesn't add up, you notice on one warehouse, not on the whole company.

A delicate step is the **initial alignment**: the first inventory that brings the single source to match physical reality. Almost always, when you do it, you discover that the starting numbers were wrong — goods that showed up and weren't there, and vice versa. It's uncomfortable but precious: it's the moment you stop building on fake data.

Another advantage of the layered rollout: it allows you to discover your company's weird rules one piece at a time. Almost every warehouse has its exception — the depot serving only one channel, goods on consignment, items "blocked" for a customer. Tackling them one warehouse at a time is manageable; tackling them all together on big bang day is chaos.

## Where to start

If we decided to start, the first step is not buying software: it is **photographing the truth**. Take a day and count, on a sample of the products you sell most, what the ERP says, what the site says, what is physically on the shelf. Almost always the three numbers do not coincide, and the size of the gap tells you how serious the problem is.

Then look at the last few months: how many times did you have to cancel an order for missing goods? How many times did a customer ask for something marked as out of stock that you then found? That light audit — three numbers compared and two counts of episodes — is your business case, and is worth more than any warehouse software demo. It tells you if the problem is real, how much it weighs, and which warehouse or channel to start from.

## KPIs: stockout and overselling, the numbers that matter

How do you know if the problem is there, how much it weighs, and if the project is working? Two numbers, above all.

- **Overselling**: how many times you sold something you couldn't fulfill, in a period. Every episode is a disappointed customer and often a lost sale. If you don't measure it, you don't know what it costs you — but your customers do.
- **Stockout**: how many times a product was out of stock (or shown as out of stock) when a customer wanted it. It includes hidden underselling: the goods were somewhere but you didn't sell them.

To these are added the **value of tied-up idle stock** (goods that don't rotate, blocked capital) and **inventory accuracy** (how much the single source matches physical reality). These numbers, before, you didn't have because you didn't have a single source to calculate them from; with the single source they become the warehouse dashboard — and it's the same leap from deciding by gut to [deciding on real numbers]({{ '/en/blog/owner-dashboard/' | relative_url }}), applied to stock.

## Who keeps the single source updated

A fair question: if there's a single source, who keeps it true? The answer is that a large part of the updating becomes **automatic** — every sale, every receipt, every transfer deducts or adds from the source the moment it happens, instead of at end of day by hand. But human points remain: whoever records a receipt from the supplier, whoever confirms a sellable return, whoever does spot checks. The secret is that these gestures be few, easy and *inside* the workflow (not a separate "update the warehouse" that nobody does), and that the system flags anomalies — a remainder going negative, a product moving strangely — instead of waiting for annual inventory to discover holes.

A good stock product doesn't eliminate people from the warehouse: it eliminates the job of reconciling by hand between different copies, and turns inventory from a traumatic annual event to a continuous, light check.

## It's for you if / it's not for you if

**It's for you if:** you sell on the same stock from multiple channels (site, store, agents, marketplace); you have more than one warehouse or depot; you happen to sell what isn't there (or to mark as out-of-stock what is in another depot); you take inventory and it never adds up.

**It's not for you if:** you have a single channel and a single warehouse, and the ERP/gestionale is enough for you (then keep it); your volume is so low that you check everything by eye without errors; you genuinely need to optimise a huge warehouse with hundreds of operators (there the topic is a real WMS, not the misalignment between channels).

## Frequently asked questions

**Isn't it enough to synchronise the site with the ERP?**
Two-way synchronisation is already better than nothing, but it breaks as soon as you add a channel, and above all it doesn't solve order commitment and transfers. The problem is not connecting two copies: it's stopping having copies. A single source that everyone reads is structurally different from two systems passing numbers.

**How much time is needed for an SME with 2-3 warehouses?**
It depends on how many channels and how dirty the starting data is. Bringing in the single source and connecting the first channel takes a few weeks; then every additional warehouse and channel is quicker. The most valuable phase is the initial inventory alignment.

**Do I have to change my ERP/gestionale?**
Almost never. The single source of stock can read and write to the ERP you have; the important thing is that *it* becomes the truth on availability, with the ERP as one of the connected systems, not as the diverging copy.

**What about returns and goods in transit?**
They must be managed as precise statuses, with written rules (when a return becomes available again, in which warehouse; how goods in transit are counted). It's precisely the details that, ignored, recreate misalignment. A serious project starts from here, it doesn't leave them "for later".

**Must the site show the exact number of items?**
No, and often it's better not to. The customer needs a reliable promise ("available", "last items", "in 3 days"), not the raw number. The exact number, net of committed, is needed by the system to decide what to promise — not necessarily by the customer to see it.

**And if a channel doesn't allow real-time reads?**
Some marketplaces or older systems update at intervals, not in real time. In those cases you work with a safety margin (an unsold "buffer" stock) on the slowest channel, so as not to promise it twice. It's not as perfect as real time, but with a single source underneath it is manageable and honest.

**How do I manage products available to order?**
With a promise of *time* instead of stock: "available in X days". The single source must not only say how much is there now, but also what is incoming from suppliers and when — so the channel promises a reliable date instead of an "out of stock" that loses the sale.

**Is the problem that I have the wrong ERP?**
Rarely. Even a good ERP manages multichannel badly, because it was born to be the truth of itself, not to orchestrate multiple channels selling on the same stock. The problem is not which ERP you have: it's that there is a missing layer on top acting as a single truth for all channels.

**How much does "perfect" accuracy matter?**
Less than you think. Precision to the single item on everything is not needed: you need to be right enough on products that rotate, with committed managed well, so you don't promise what you don't have. Chasing absolute perfection on codes you sell twice a year is wasted time; the focus goes on best-sellers.

**Do the data and the system stay mine?**
Yes. The single source of stock, the rules and the connections stay yours, no lock-in. It's the most delicate asset of operations: it must be yours.

## In one line

If the site, the ERP and the reps state three different stock levels, you don't need to "synchronise better" five copies: you need **a single source of truth on stock**, with availability calculated net of committed, read by every channel in the right view. So you stop selling what you don't have and saying no to what you do have — without buying a multinational WMS that (for now) you don't need.

If you want to understand where your misalignments are born and what a single source would look like on your channels and warehouses, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a couple of lines]({{ site.main_site }}/contatti/): we start from your real channels and depots, not from trade-fair software.
