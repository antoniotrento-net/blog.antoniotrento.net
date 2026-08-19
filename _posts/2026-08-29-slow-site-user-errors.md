---
lang: en
permalink: /en/blog/slow-site-user-errors/
alt_url: /it/blog/sito-lento-errori-utenti/
title: "The site is pretty and on the second click it breaks: why customers leave (and it isn't «a hosting problem»)"
date: 2026-08-29 07:30:00 +0200
author: "Antonio Trento"
description: "The site is pretty, but when the user tries to log in, fill the cart, book or pay, it breaks: timeouts, double submits, vanished data. It isn't hosting: it's frontend and backend out of sync. Here's how you measure, and when to repair or rebuild."
keywords: ["slow site user errors", "ux that loses customers", "frontend backend out of sync", "unstable app", "broken site conversion"]
image: /assets/images/posts/sito-lento-errori-utenti.jpg
pillar: web-prodotto
related: [/en/blog/showcase-site-vs-digital-product/, /en/blog/b2b-customer-portal/]
---

## The second click: where customers leave

Your site is pretty. It opens fast, the photos are careful, the home makes a figure. The first click goes smoothly. It's the **second** click that's the problem — the one where the user tries to *do* something: access their area, fill the cart, book a slot, complete a payment. There the pretty site jams: it spins forever, it gives an incomprehensible error, "a problem occurred, try again later", or it looks like it works but the datum you entered has vanished. And the user, who was ready to buy or register, leaves. They don't come back, and they don't tell you why.

This is the hole that costs you more than all the others and that you don't see, because it happens in silence: nobody writes you "I abandoned the cart because the pay button spun in the void". Simply, **conversion** is lower than it should be, and you don't know why. The temptation is to say "it's a hosting problem, let's put a faster server". Almost never. The problem, in the vast majority of cases, is that **the site is pretty but not working** — the façade is careful, but underneath, the moment it has to do something real, it breaks.

This article is for whoever has a site or an application that loses customers on the second click and doesn't understand why. It isn't a tutorial on how to optimise speed scores (that's another conversation). It's about where **conversion** is actually lost: in the points where the user acts and the system betrays them. Let's see the real symptoms (timeouts, double submits, vanished data), why they come from **frontend and backend out of sync**, why having three suppliers and no owner guarantees disaster, and what to measure before throwing everything away and redesigning.

## Pretty ≠ working

Let's start from a misunderstanding that costs dearly: **pretty doesn't mean working.** They're two different things, done by different skills, and a site can be splendid and broken at the same time. Beauty is the surface: the design, the colours, the animations, the look. Working is underneath: what happens when the user clicks "pay", whether the datum saves, whether the action goes through, whether the system holds when more people use it together.

The problem is that beauty is seen immediately (one glance at the home is enough) and working isn't — it only emerges when someone tries to *use* the site for real, on the second click. So it's easy to be happy with a newly delivered site ("how pretty!") and discover months later, looking at the numbers, that it converts badly because at the action points it breaks. Pretty deceived you: you evaluated the façade and not the engine.

It's the same distinction as [a showcase site versus a product that holds state]({{ '/en/blog/showcase-site-vs-digital-product/' | relative_url }}), but here there's an aggravating factor: here the site *should* work (it has a cart, a login, a payment), it just does it badly. It isn't that the engine is missing: it's that the engine is poorly assembled, and it cuts out in the corners. And every time it cuts out, a customer who was about to convert leaves. Beauty without working, when there's an action to take, isn't a half success: it's a well-dressed failure.

## The symptoms: timeouts, double submits, vanished data

Let's name the symptoms, because recognising them is the first step to understanding that it isn't "hosting" but something deeper. These are the signals that your site loses customers at the action points:

- **Timeouts and infinite loading.** The user clicks "pay" or "submit" and the spinner spins, spins, spins. After ten seconds (an eternity, online) they either give up or click again — creating other problems. Timeout at action points is often a sign of a backend that doesn't hold or of badly made communication between frontend and backend, not of a generally slow server.
- **Double submits.** The user clicks "confirm order", nothing visible happens, they click again, and they end up with two orders (or two charges). It's a classic of a system that doesn't handle state well: the frontend doesn't tell the user "I'm working, wait", and the backend doesn't protect itself from repeated clicks. Result: angry customers and refunds.
- **Vanished data.** The user fills a long form, clicks submit, and "an error occurred" — and everything they had written is lost. They have to start again, and the second time they often don't: they leave. Vanished data is the frustration that converts worst of all.
- **Incomprehensible errors.** "Error 500", "something went wrong", a white page. The user doesn't understand, doesn't know what to do, and in doubt they abandon. An unhandled error is a lost customer.
- **It works for me, not for you.** The site is fine on your computer and breaks on another device, another browser, a slower connection. That's instability: the system isn't robust to real conditions, which vary.

Note that none of these is "the site is slow to load the home". They're all in the moment of **action**, and that's where conversion is lost. A user forgives a slightly slow home; they don't forgive a payment that spins in the void or an order charged twice.

## The bill: what lost conversion is worth

Let's put some numbers, because "you lose customers on the second click" stays abstract until you tie it to money — and lost conversion is among the most expensive and most invisible items there are. Let's take an example, as always declared as an estimate but easy to redo on your case.

Say your site gets 10,000 visits a month from potentially interested people, and that a good part of them arrives at the action point (cart, booking, registration). If even only **10% of those who try it get lost** to a timeout, a double submit, an error, vanished data, and if each conversion is worth, say, €50, the bill is pitiless: those are customers lost every month not for the product or the price, but because the system betrayed them the moment they wanted to give you money.

| Item | Example |
|---|---|
| Users who arrive at the action point / month | 2,000 |
| Share lost to technical errors | ~10% = 200 |
| Average value of a conversion | €50 |
| **Lost a month** | **~€10,000** |
| **Lost a year** | **~€120,000** |

Change the numbers on yours, but the point remains: conversion lost to technical problems is a hole that often is worth more than what it would cost to repair it many times. And it's particularly painful because they're customers **already convinced** — they had decided to buy, book, register — lost on the last metre. Recovering even only half of that hole, by repairing the two or three points that lose most, has an immediate, measurable return. That's why it's worth measuring and intervening, instead of considering a low conversion "physiological".

## It isn't hosting: it's frontend and backend out of sync

Now the real cause, the one that sits under almost all those symptoms: **frontend and backend out of sync.** A web application is made of two halves that have to work together. The **frontend** is what the user sees and touches (the screens, the buttons, the forms). The **backend** is what sits behind (the logic, the data, the payments). When the user clicks "pay", the frontend has to talk to the backend, the backend has to do its job, and the two have to coordinate well — even when something goes wrong or takes time.

When these two halves have been done badly or by people who didn't talk, they go out of sync, and that's where the symptoms are born. The frontend sends a request and doesn't handle the wait (infinite spinner). The backend is slow or jams and the frontend doesn't know (timeout). The user clicks again because the frontend didn't tell them "wait" and the backend doesn't protect itself (double submits). The backend errors and the frontend doesn't handle it with grace (lost data, white page). It isn't a problem of *how powerful the server is*: it's a problem of *how the two halves communicate and handle non-ideal cases* — the wait, the error, the repeated click.

That's why "let's put faster hosting" almost never solves it: the more powerful server makes the home load a bit sooner, but it doesn't fix the broken coordination between frontend and backend at the moment of payment. You're treating the wrong symptom. The real work is on the **unstable app**: making communication between the two halves robust, handling the wait, the errors, the repeated clicks — everything that in the real world (bouncy connections, impatient users, edge cases) happens and that a demo on a fast computer never shows. It's the same rigour needed under [a checkout or a portal that has to hold state]({{ '/en/blog/b2b-customer-portal/' | relative_url }}): the moment of action is sacred, and it has to be built so it doesn't break.

## Three suppliers and no owner

There's an organisational reason, behind the technical misalignment, and it's almost always the same: **three suppliers and no owner.** The site was born like this: an agency (or a freelancer) did the **graphics**, someone else put it on **WordPress** with a theme and plugins, and then "the developer" stuck on the functions that were needed (the cart, the booking, the payment) with other plugins or pieces of code. Three different hands, at different moments, without anyone having the *whole* system in their head.

The result is predictable: nobody owns the working. When it breaks on the second click, you call the graphics agency and they tell you "it's a development problem"; you call the developer and they tell you "it's a plugin"; you call whoever put it on WordPress and they tell you "it's hosting". Each is right on their piece and nobody takes responsibility for the whole, because the whole isn't anyone's. You, in the middle, have a site that loses customers and a circle of suppliers who bounce the blame. It's the same problem of [a single pair of hands versus disconnected suppliers]({{ '/en/pillar/web-ux-product/' | relative_url }}) that's the thread of everything I write: when frontend, backend and infrastructure belong to three different subjects, the misalignment isn't an accident, it's the inevitable consequence.

The organisational solution is to have **one technical owner** of the working: someone who owns the whole system — frontend, backend, how they communicate, how they handle errors — and to whom you can say "the payment breaks" having one person who answers, instead of three who accuse each other. One person doesn't have to do everything alone; *someone has to be responsible for the whole*. Without that single owner, every repair is a bounce war and the site stays broken.

## What you measure before you redesign

The error many make when the site converts badly is: "let's redo it, prettier". But if you don't know *where* conversion is lost, you risk redoing pretty a site that will break at the same points, spending on the wrong problem. Before redesigning or rebuilding anything, you **measure**. Not abstract speed scores: you measure where real users get lost.

Two things have to be looked at. The **funnel**: the path the user takes to convert (arrives → looks → puts in the cart → login → pays), with how many people pass from each step to the next. That's where you see the hole: if 40% arrive at the cart and only 5% complete payment, the problem is between cart and payment — that's the point to look at, not the home. The funnel tells you *where* customers get lost, objectively, instead of by feeling.

And the **errors**: how many and which technical errors happen to real users, at those points. Not "it works for me", but how many users, on their real devices and connections, hit a timeout, an error, a double submit. This data exists or can be collected, and it turns "it seems to break sometimes" into "12% of users who click pay get an error". With the funnel and the errors in hand, you know exactly what to fix — and you almost always discover that you don't need to redo everything, but to fix the two or three points where the bulk is lost. Measuring before redesigning is what keeps you from spending on the wrong problem, the same principle of [measuring where you lose before intervening]({{ '/en/blog/owner-dashboard/' | relative_url }}) that holds everywhere.

## Repair vs rebuild

With the data in hand, the decision becomes concrete: do you repair or rebuild? It depends, and it has to be decided on the numbers, not on impulse.

**Repairing** makes sense when the problems are localised: two or three action points that break (payment, login, a form), on a base that's otherwise healthy. In that case you fix those points — you make frontend-backend communication robust there, you handle wait and errors, you take away double submits — and conversion comes back up without redoing everything. It's faster, it costs less, and it's often the right answer. Many "the site converts badly" are solved by repairing the few points that lose the bulk of customers.

**Rebuilding** makes sense when the base is rotten: a tangle of plugins that break each other, a system so fragile and out of sync that every repair breaks another, nobody who understands it, impossible to evolve. In that case patching is throwing money down a well, and it's better to rebuild on healthy bases — maybe keeping the graphics if they're good, but redoing the underneath so it works. It's the repair-vs-rebuild analysis that holds for [every fragile legacy system]({{ '/en/blog/rewrite-legacy-erp-software/' | relative_url }}): if the patches cost more than rebuilding and they break in a chain, the base is the problem.

The rule: **measure first, decide after.** If the hole is in two or three points on a healthy base, repair. If the base is a house of cards, rebuild. Whoever tells you "let's redo everything" without having measured where you lose, or "a tweak is enough" without looking at the base, is guessing — and with your money.

## A one-week audit

How do you start, in practice, without committing immediately to a rebuild? With a **one-week audit**: a short, bounded intervention that gives you the diagnosis before the cure. In a few days, whoever knows how to look at a web system can tell you where you're losing customers and why, and whether you need to repair or rebuild.

What does a well-done audit produce? The **funnel map** with the holes (where users get lost, with the numbers). The list of **errors** real users hit at the action points. A diagnosis of the **why** (frontend and backend out of sync? conflicting plugins? a backend that doesn't hold?). And an **honest recommendation**: what to repair immediately (the two or three points that lose most), what can wait, whether the base holds or has to be rebuilt, with cost ranges. A week of work that makes you spend the money well afterwards, instead of rebuilding in the dark.

When you look for whoever does it for you, the right signal is that they start from the **data** (I want to see the funnel, the errors, where you lose) and not from aesthetics ("let's redo the design"). Whoever looks at where customers get lost before proposing a cure is acting in your interest; whoever proposes to redo everything pretty before measuring is selling a project, not solving your conversion problem.

## A typical case: the cart that was losing customers

A typical profile, architectural, no names. A business with a careful site — truly pretty, made by a good design agency — was seeing conversion much lower than expected. They suspected hosting and were about to change it. The site had been born from the usual three pieces: graphics from an agency, put on a platform with plugins, and the sales functions stuck on by an external developer. Nobody owned the whole working.

What was done. First they measured instead of rebuilding: they looked at the funnel and the real holes emerged — a relevant share of users arrived at payment and didn't complete. Looking at the real errors, it was seen that at the moment of payment frontend and backend went out of sync: on slow connections the button spun in the void, some users clicked again generating double orders, others got an error and abandoned with the cart lost. It wasn't hosting: it was the broken coordination at the action point.

What was decided: repair, not rebuild, because the base was otherwise healthy and the problems were localised in checkout. Those points were fixed — wait handling (the user sees "I'm processing" and doesn't click again), protection from double submits, clean error handling without losing data. Conversion came back up without redoing the site. And a single technical owner of the working was put in place, so the next problem would have one person who answers instead of three who accuse each other. The honest note: they didn't need the new site they were about to commission — they needed to measure where customers got lost and repair the two right points.

## It's for you if / it isn't for you if

**It's for you if:** you have a pretty site or app that converts badly and you don't understand why; users get lost at the action points (login, cart, booking, payment) with timeouts, double submits, lost data; you have three suppliers who bounce the blame and no owner of the working; you're about to "redo everything prettier" without having measured where you actually lose; you suspect hosting but the problem shows only when the user acts.

**It isn't for you if:** yours is really only a showcase site with no actions to take (then there isn't a funnel to repair, maybe a different conversation); the problem is really and only general loading speed (rare, but it exists, and it's faced differently); you aren't willing to measure before deciding and you want to redo everything by instinct — because without measuring, you risk redoing pretty a site that will break at the same points.

## Frequently asked questions

**The site is slow: isn't better hosting enough?**
Almost never. More powerful hosting makes the home load a bit sooner, but it doesn't fix the real symptoms — timeout at payment, double submits, lost data — which come from frontend and backend out of sync, not from server power. You're treating the wrong symptom. The work is on the coordination between the two halves at the action points, not on the hardware.

**Why is the site pretty but converting badly?**
Because pretty and working are two different things. Beauty is seen immediately (the home), working only emerges when the user tries to do something (the second click). A site can be splendid and break at the moment of payment. You evaluated the façade; the engine, poorly assembled, cuts out in the corners — and there you lose the customers.

**What are "double submits"?**
When the user clicks "confirm", they don't see anything happen, they click again, and they end up with two orders or two charges. It comes from a system that doesn't handle state: the frontend doesn't say "I'm working, wait" and the backend doesn't protect itself from repeated clicks. It generates angry customers and refunds, and it's one of the most common symptoms of frontend and backend out of sync.

**Why do I have three suppliers who blame each other?**
Because the site was born in pieces: graphics from one, platform and plugins from another, functions stuck on by a third, without anyone having the whole system in their head. When it breaks, each is right on their piece and nobody is responsible for the whole. You need one technical owner of the working, or every repair is a bounce war.

**Do I have to rebuild the site?**
Not before measuring. If the hole is in two or three action points on a healthy base, you repair (faster, cheaper, often decisive). If the base is a tangle of plugins that break each other and nobody understands, you rebuild. The decision has to be taken on the data (funnel, errors), not on impulse: redoing pretty a site without knowing where you lose risks reproducing the same problems.

**What do you measure, precisely?**
The funnel (how many people pass from each step to the next: arrives, cart, login, pays) to see *where* they get lost; and the technical errors real users hit at those points (how many timeouts, double submits, errors, on their devices and connections). Together they turn "it seems to break" into "12% of whoever clicks pay gets an error" — and they tell you exactly what to fix.

**What's a one-week audit?**
A short intervention that gives you the diagnosis before the cure: the funnel map with the holes, the list of real errors, the technical why, and an honest recommendation (what to repair immediately, whether the base holds or has to be rebuilt, with cost ranges). A week to spend the money well afterwards, instead of rebuilding in the dark. Look for whoever starts from the data, not from aesthetics.

**What does repairing cost versus rebuilding?**
Repairing the points that lose most is much cheaper than rebuilding, and it's often enough. Rebuilding only makes sense if the base is rotten. The way to decide is the audit: if the problems are localised on a healthy base, you repair; if they're structural, you rebuild. Whoever gives you a rebuild quote without having measured where you lose is guessing with your money.

## In one line

If your site is **pretty and on the second click it breaks** — timeouts, double submits, vanished data when the user logs in, fills the cart, books or pays — you're losing customers in silence, and it isn't "a hosting problem": it's **frontend and backend out of sync**, almost always children of three suppliers and no owner. Before redoing everything prettier, **measure**: the funnel (where they get lost) and the real errors (why). With the data, decide whether to repair the two or three right points (often enough) or rebuild the base (if it's rotten). And put one technical owner of the working, or you'll stay in the bounce of blame.

If your site converts badly and you want to know where you lose customers before spending to rebuild it, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/): we start from an audit of your funnel and the real errors, not from a restyle quote in the dark.
