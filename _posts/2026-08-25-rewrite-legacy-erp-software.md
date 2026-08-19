---
lang: en
permalink: /en/blog/rewrite-legacy-erp-software/
alt_url: /it/blog/riscrivere-software-gestionale-legacy/
title: "Your internal software is a 2008 Access: when rewriting it pays (and when it's suicide)"
date: 2026-08-25 07:30:00 +0200
author: "Antonio Trento"
description: "An .mdb file on a single PC holds the company up, and every day you're more afraid it will break. When rewriting a legacy ERP pays, what to keep, and why a total rewrite in one go is suicide."
keywords: ["rewrite legacy erp software", "migrate access", "obsolete company application", "modernise erp", "software rewrite cost"]
image: /assets/images/posts/riscrivere-software-gestionale-legacy.jpg
pillar: comprare-software
related: [/en/blog/internal-app-copy-paste/, /en/blog/showcase-site-vs-digital-product/]
---

## The .mdb file that holds the company up

There's a file, in a lot of Italian companies, that's worth more than everything else put together and sits on a single computer. It's the internal ERP made years ago — a 2008 Access, a Visual Basic program, an application a consultant now unreachable built custom when the company was smaller. Inside is everything: customers, orders, warehouse, the rules of how the company works. And every day that passes, the fear grows: that that PC will break, that the file will corrupt, that the person who "knows how it works" will leave. Because if it happens, the company stops.

It's a more common situation than it seems, and it has a paradoxical characteristic: **the legacy software works** — that's why it's still there. It does its job, the company has run on it for years, the operators know it by heart. The problem isn't that it doesn't work: it's that it's **fragile and captive**. It runs on a single PC (or on a network nobody would dare touch), one person understands it, the backup is "the copy of the file on the USB stick", and you can't grow it because whoever made it isn't there any more or the technology is dead. It's a time bomb that keeps telling the right time — until it explodes.

This article is for anyone who has **legacy ERP software** and wonders whether the moment to rewrite it has arrived. It's a serious decision, with a part of fear (what if it breaks?) and one of opportunity (we could finally do it properly). Let's see the symptoms that say "it's time", what to keep and what to throw away, why a total **rewrite** in one go is almost always suicide, and how you instead make a layered plan that doesn't stop the company. With honest cost and time ranges, not promises.

## The symptoms: when it's really time to rewrite

Not all old software has to be rewritten. "Old" isn't a defect if it works, it's reliable and it's enough for you. The rewrite is needed when certain **symptoms of fragility or blockage** appear, and it's worth recognising them, because that's the difference between a necessary intervention and one done for fashion.

- **One PC, one person.** The software runs on a single machine, and if it breaks the company stops. Or only one person understands it, and when they're on holiday or (worse) they leave, nobody can touch it. You've built operations on a single point of failure, human or technical.
- **The backup is "the USB stick".** There isn't a serious, automatic, verified backup. There's a manual copy someone makes when they remember. The day the file corrupts (and files corrupt), you discover the last good copy is three weeks old.
- **You can't grow it.** You need a new function, access from outside, a connection with another system, and the answer is always "you can't", because whoever made it isn't there, or the technology is dead and nobody touches it any more.
- **It runs on things that no longer exist.** It requires an old version of Windows, a component no longer supported, a PC you can't replace because the software doesn't run on the new ones. You're hostage to a computing museum.
- **Nobody can maintain it.** The author is unreachable, the code isn't there or is indecipherable, and every small change is a lottery. You're stuck on what it does today, forever.

If you recognise two or three of these symptoms, it isn't "old but it works": it's a **fragility that costs you** — in risk and in missed opportunity. If instead the software is old but runs on a healthy base, has serious backups, someone maintains it and it's enough for you, then leave it alone: rewriting for fashion is throwing money away.

## The cost of doing nothing (and the risk)

Before talking about the cost of the rewrite, let's talk about the cost of *not* doing it, because that's the one that's usually underestimated. It has two faces.

The visible face is **missed opportunity**: all the things you can't do because the software doesn't allow it. The access from outside you'd need, the integration with e-commerce, the datum you should extract and can't, the function that would speed up the work. Every "you can't" is a piece of efficiency or revenue you leave on the table because you're captive to software that doesn't evolve.

The invisible face, and more dangerous, is **risk**: the probability, which grows every year, that something breaks catastrophically. The PC that dies, the file that corrupts without a good backup, the person who leaves taking the knowledge with them. It isn't an "if", it's a "when", and the cost when it happens isn't gradual: it's the company stopped for days, data lost, operations to rebuild in a panic. It's the same reasoning on hidden risk that holds for [processes that live in a single person's head]({{ '/en/blog/internal-app-copy-paste/' | relative_url }}): as long as the person (or the PC) is there, everything seems fine; the cost shows up all at once when they're missing. Rewriting isn't only "modernising": it's defusing a bomb before it explodes.

## What to keep: the business rules, not the grey screens

Here's the most important and most misunderstood point of the rewrite: **what you keep and what you throw away**. The classic error is thinking "let's redo it the same, but modern" — reproduce the same grey screens, the same flows, the same logic, only with new technology. It's a double waste: you carry all the old defects with you, and you don't use the occasion to do better.

What has value, inside a legacy ERP, isn't the screens: it's the **business rules**. Years of company logic have sedimented in there — how a discount is calculated, how a special case is handled, which checks are made, which exceptions are treated. Those rules are an estate, often not written anywhere else, and they have to be **understood and kept**. The grey 2000s screens, instead, have to be thrown away without regret: they were the way those rules were *shown then*, not the rules themselves.

So a rewrite done well does two distinct jobs: **extracts and keeps the rules** (often it's archaeology work: understand what the old software actually does, exceptions included, because that's where the value sits), and **throws the interface away** to rebuild it on how work happens today. The result isn't "the old ERP but modern": it's a product that does the same important things in a better way, without the constraints of thirty years ago. Distinguishing the rule (to keep) from the screen (to redo) is what separates an intelligent rewrite from an expensive photocopy.

## The new interface operators accept

A concrete risk of the rewrite: the operators who know the old software by heart and hate the new one. It's a serious risk, because a technically perfect rewrite that operators refuse is a failure. The key is that the new interface isn't only "prettier", but **faster** for whoever works on it all day.

Legacy operators have their fingers on automatic: they know that to do a thing they press tab-tab-enter, they know the shortcuts, they're extremely fast even on an ugly screen. If the new software is pretty but slows them down — more clicks, fewer shortcuts, different flows "because it's modern" — they live it as a worsening, and they're right. The new interface has to be designed *with* them, looking at how they actually work, keeping (or improving) speed on the frequent gestures, with keyboard shortcuts for whoever enters at speed. Modernity isn't the mouse and the colours: it's removing friction, as with [every internal app people accept only if it saves them time]({{ '/en/pillar/internal-apps/' | relative_url }}).

The message to operators has to be concrete: the new software does the same things *at least* at the same speed, and on top it takes away the old defects (the crashes, the limits, the things that "couldn't be done"). If they perceive it as an upgrade of their day and not as a whim of leadership, they adopt it. If they perceive it as "they changed the software and now I'm slower", they sabotage it — and no beauty of the interface saves the project.

## Total rewrite vs tearing off a piece

We arrive at the strategic decision: do you rewrite everything, or tear off a piece at a time? In most cases, the right answer is the second, and understanding why saves you the "suicide" I talk about in a moment.

The **total rewrite** (redo everything from scratch and replace the old with the new in one go) is fascinating on paper and disastrous in practice, for a simple reason: while you do it, the company keeps working on the old, and the old keeps changing (new needs, corrections). You find yourself chasing a moving target for months or years, with new software that is never "ready" because the old doesn't stay still, and a terrifying "cutover" day (the switch from old to new), where everything has to work first time or the company stops.

**Tearing off a piece at a time** is less heroic and much healthier: you identify a module or a function, you redo that well, you put it into production next to the old, and when it works you move to the next piece. Old and new coexist for a while, with data staying aligned, and replacement happens in layers instead of with a jump into the void. Every piece that works reduces risk and builds trust; if something goes wrong, it goes wrong on a piece, not on the whole company. It's the same principle of gradual rollout that holds for [every product that has to be put in real users' hands]({{ '/en/blog/showcase-site-vs-digital-product/' | relative_url }}): you validate a piece, then you expand, instead of switching everything on together and hoping.

## The suicide: redo everything without cutover, while you work as before

It's worth being explicit about what the wrong way is, because it's the one a lot of companies choose by instinct and that sinks rewrite projects. The **suicide** is this: decide to rewrite the whole ERP from scratch, in a project lasting months or years, while the company keeps working exactly as before on the old, and postpone the switch (the cutover) to a single big day at the end.

Why is it suicide? Because it accumulates all the risk in a single point, at the end, when you've already spent the whole budget. For months you don't see results in production — only new software "almost ready" that nobody actually uses. The old in the meantime changes, and the new chases. And on cutover day, you have to switch the old off and the new on for everything, at once, hoping it works: data migrated well, all functions in place, all operators ready. If something goes wrong — and something always goes wrong — the company stops, and you don't have an old one to go back to easily because you built the cutover on top of it. Many failed rewrites died exactly like that: not from technical inability, but from having chosen the jump into the void instead of the layered plan.

## The layered plan

The healthy alternative has a name: **layered plan** (or incremental migration). Instead of replacing everything in one go, you proceed by successive layers, each of which brings value and reduces risk. Roughly it works like this.

First you secure the **base**: the data. You take the information estate of the old software (customers, orders, history) into a modern, solid database, with serious automatic backups — even if the functions still run on the old. This, on its own, immediately takes away the biggest risk (the file on the USB stick) and prepares the ground.

Then you **tear off the first piece**: you pick a function — maybe the one that hurts most, or the one most at risk — and you redo it well, in production, connected to the new database. Operators use the new piece for that function and the old for the rest. When the new piece is solid, you move to the next. Layer after layer, the new grows and the old empties, until the old isn't needed any more and you switch it off — without a terrifying cutover, because the switch already happened piece by piece.

This approach has three huge advantages: **you bring value immediately** (every layer improves something, you don't wait for the end), **you reduce risk** (if a piece goes wrong, it's a piece), and **you can stop** (if after some layers you decide that's enough, you've still improved, you don't have a half-finished building site that's unusable). It's slower and less spectacular than "let's redo everything", but it's how rewrites arrive at the end instead of dying.

## Cost and time: honest ranges

What does it cost and how long does it take? I won't give you precise numbers (whoever gives them without having seen your software is lying), but honest qualitative ranges. The cost of a rewrite depends mainly on two things: **how complex the logic** sedimented in the old is (how many rules, how many exceptions to understand and keep) and **how accessible the data and code** of the old are (a documented Access is one thing, an executable nobody has the source for is another).

In terms of time, a layered rewrite isn't "a week" nor "six months and the problem disappears": it's a path of months, in which however you see results along the way (every layer), not only at the end. The longest and most underestimated part isn't writing the new code: it's **understanding the old** — the archaeology of the business rules, especially when they aren't documented and live only in the software's behaviour and in the head of whoever uses it. Whoever promises you a fast rewrite probably hasn't understood how much logic there is to extract, and will discover it halfway, overrunning.

The right way to evaluate the cost isn't in absolute, but against the cost of *not* doing it: the risk that grows every year and the opportunities you lose. On how you evaluate what you're buying when you commission a build — what's included, maintenance, how not to get ripped off — everything I say in the [guide to buying custom software]({{ '/en/pillar/buying-custom-software/' | relative_url }}) holds.

## Why you need whoever can do the archaeology and the new

A rewrite has a double competence not everyone has: you have to know how to **read the old** (understand an Access, a VB, an outdated application, extract the rules and the data) and know how to **build the new** (modern data, backend, interface). Whoever only knows how to do the new risks throwing away precious rules because they don't understand the old; whoever only knows how to read the old remakes a modern photocopy of its defects. You need whoever holds the two things together: the archaeology of the existing logic and the building of a new product that keeps that logic and runs it better.

And you need, as always, a single pair of hands on the three layers — data, backend, interface — because in a rewrite they're tangled in a particular way: the migration of the old data, the extracted logic and the new interface have to match, and if different suppliers do them the migrated data doesn't match the logic, or the interface doesn't reflect the rules. A rewrite split among suppliers who blame each other is the most expensive way to turn a time bomb into an endless building site.

## A typical case: the bomb defused in layers

A typical profile, architectural, no names. A company had run for over fifteen years on an internal ERP made custom by a consultant now gone: customers, orders, warehouse, all the logic of the activity inside an outdated application on a couple of networked PCs, with a backup done by hand when someone remembered. It worked — that was the problem: it worked so well nobody dared touch it, and in the meantime the fear grew at every "what if one day it breaks?". You couldn't connect it to e-commerce, you couldn't access from outside, and the person who really knew it was approaching retirement.

What was done, and in what order. First the archaeology: understand what the old software actually did, rule by rule, exception by exception — because that's where the estate sat. Then the base was secured: data taken into a modern database with serious automatic backups, while functions still ran on the old. That alone immediately took away the biggest risk. Then, one layer at a time: the first function was torn off (the one most at risk), redone well, in production next to the old; when it was solid, the next. Old and new coexisted for months, with data aligned, until the old wasn't needed any more.

At regime, the difference wasn't "we have new, pretty software": it was that the bomb was defused (data safe, no more single PC, no more irreplaceable person), the business rules were kept and finally written, and you could do the things that were previously impossible (access from outside, connection with other systems). Operators accepted the new because it was at least as fast as the old on everyday gestures. The honest note: it was a path of months, not a week, and the long part was understanding the old, not writing the new — but it never stopped the company, because it happened in layers and not with a jump into the void.

## It's for you if / it isn't for you if

**It's for you if:** your internal ERP is fragile legacy software (one PC, one person who understands it, backup on the USB stick, it runs on dead technologies); you can't grow it and every "you can't" costs you efficiency or revenue; you have a justified fear that a failure or a person leaving will stop the company; you want to keep the business rules inside it but free yourself from the old constraints.

**It isn't for you if:** the software is old but healthy — it runs on a solid base, has serious backups, someone maintains it and that's enough (then don't rewrite for fashion, it's throwing money away); you aren't willing to face the rewrite in layers and you want to "redo everything in one go" (that's the suicide road); you don't have the patience for the archaeology of the rules and you'd only like a modern photocopy of the old screens (a waste dressed as a project).

## Frequently asked questions

**My ERP still works: why should I rewrite it?**
Not because it's old, but if it's *fragile*: one PC, one person who understands it, no serious backup, you can't grow it, it runs on dead technologies. In those cases it works until it explodes, and the cost when it explodes (company stopped, data lost) is huge. If instead it's old but healthy and it's enough, leave it alone.

**Do I have to redo everything or can I start from a piece?**
Almost always it's better to start from a piece (layered plan): secure the data, then redo one function at a time, with old and new coexisting. Redoing everything in one go, with a single cutover at the end, accumulates all the risk in one point and is the most common way to make a rewrite fail.

**What do you keep from the old software?**
The business rules — years of logic on how the company works, often not written elsewhere — have to be understood and kept. The 2000s screens and interface have to be thrown away and redone on how work happens today. The error is "let's redo it the same but modern": you carry the defects with you and waste the occasion to do better.

**Will operators accept the new software?**
Only if it's at least as fast as the old on the gestures they do a hundred times a day. Legacy operators are extremely fast even on ugly screens, because they know them by heart. The new has to be designed with them, keeping the shortcuts and the speed, or they'll live it as a worsening. Modernity is removing friction, not adding clicks.

**What does it cost and how long does it take?**
It depends on how much logic there is to extract and how accessible the old data and code are. It's a path of months, not days, but in layers you see results along the way. The longest part is understanding the old (the archaeology of the rules), not writing the new. Evaluate the cost against the growing risk of doing nothing, not in absolute.

**And if we don't have the source code of the old?**
You can still, but it's harder and longer, because the rules have to be reconstructed by observing the software's behaviour and the data, instead of reading the code. It's one more reason not to wait for the situation to get worse (the author more and more unreachable, the person who knows leaving): the sooner you intervene, the more material there is to understand the old.

**Do we risk stopping the company during the rewrite?**
With the layered plan, no: old and new coexist, you replace a piece at a time, and if a piece goes wrong it's a piece, not everything. With the total rewrite and the single cutover, yes, that's exactly the risk: a day when everything has to work first time. It's the main reason to prefer layers.

**Can we buy a ready-made ERP instead of rewriting?**
Sometimes yes, and it's right to evaluate it: if a market ERP covers your need, it often wins. Custom (or the rewrite) makes sense when your business rules are particular and no ready-made respects them — that is, when those rules sedimented in the legacy *are* your way of working. The criterion is how much of your workings sit in the 20% the ready-made doesn't do.

## In one line

If your company runs on a **legacy ERP** — a 2008 Access on a single PC, with the backup on the USB stick and one person who understands it — you don't have old software: you have a time bomb. Rewriting it makes sense when the symptoms of fragility appear, and it has to be done keeping the **business rules** (the real estate) and throwing away the grey screens. But the way counts more than the decision: a total rewrite in one go, with a single cutover at the end, is suicide; the **layered plan** — first the data secured, then a piece at a time, old and new coexisting — is how rewrites arrive at the end instead of dying.

If you have fragile legacy and you want to understand whether and how to rewrite it without stopping the company, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/): we start from the real symptoms and from the rules inside your old software, not from a rewrite in the dark.
