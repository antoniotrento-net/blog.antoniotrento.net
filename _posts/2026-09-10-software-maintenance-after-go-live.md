---
lang: en
permalink: /en/blog/software-maintenance-after-go-live/
alt_url: /it/blog/manutenzione-software-dopo-go-live/
title: "The 'finished' project that dies in six months: maintenance, small changes and why the supplier vanishes"
date: 2026-09-10 07:30:00 +0200
author: "Antonio Trento"
description: "Go-live isn't the finish line, it's the start. What's needed after launch so the software doesn't die in six months: small changes, who holds the keys, the maintenance contract, and how not to stay hostage to a supplier who disappears."
keywords: ["software maintenance after go live", "software dead after release", "application maintenance contract", "who updates the app", "vanished supplier"]
image: /assets/images/posts/manutenzione-software-dopo-go-live.jpg
pillar: comprare-software
related: [/en/blog/what-custom-software-includes/, /en/blog/90-day-software-mvp/]
---

## The day after go-live, real use begins

There's a photograph that sums up how software projects die: the launch party. Everyone happy, the supplier delivering, the client paying the balance, handshakes, "how nice, it's finished". Six months later, that same thing is a ruin: full of small annoyances never fixed, with a field that was needed and never arrived, the export that broke when the rate changed, and the supplier who doesn't answer the phone any more. The software didn't die from a technical defect. It died because everyone believed that **go-live was the end.**

Go-live isn't the end. It's **the start.** Launch day is the first day the software meets real reality — real users, real data, the cases nobody had predicted because in the test phase they weren't there. It's the moment you discover what you'd understood well and what you hadn't. Software just launched is like a shop just opened: cutting the ribbon isn't the finish line, it's minute zero of the real work. From there on, use begins, and use brings things to fix, to improve, to add. Always. Not because it was made badly: because it's **alive**.

This idea that "finished = delivered" is the most expensive cultural trap in buying software. It comes from a misunderstanding: thinking of software as an object — I buy a chair, the chair is finished, I use it for ten years without touching it. But software isn't a chair. It's more like a car: you buy it finished, yes, but if you don't do the service, don't change the oil, don't take it to the mechanic when it makes a strange noise, after a while it leaves you in the middle of the road. Nobody is surprised that a car has to be maintained. With software, instead, people are always surprised — and in that surprise projects get consumed.

This article is about what happens *after* launch, and how you avoid your software becoming the ruin above. It's the complementary face of the [guide to what you're buying when you sign a custom build]({{ '/en/blog/what-custom-software-includes/' | relative_url }}): there we saw what's in the quote; here we see what's in — or should be in — the *afterwards*, which is the part where projects live or die.

## Small changes: VAT, a field, an export

Let's start from the small things, because they're the ones that kill first. It isn't the big breakdown that ruins a piece of software: it's the **small changes never made**, that accumulate until the tool becomes unusable.

Let's take concrete examples, the kind that happen to everyone:

- **A rate changes, a tax rule changes.** The legislator modifies something — a rate, an obligation, a format — and your software, which has that rule written inside, has to be updated. If there's nobody who does it, from one day to the next it issues wrong documents. It isn't a whim: it's maintenance forced by reality.
- **You need one more field.** Using the software you discover you need to record a piece of information you hadn't predicted at the start — a client datum, a note, a category. Small thing. But if there's nobody who adds it, you start keeping it "on the side", on a sheet, and the software starts becoming useless because it no longer contains everything.
- **You need a different export.** The accountant asks you for the data in another format, or you have to send it to a new partner, and you need to pull it out in a way that wasn't there before. Small change. But without someone who does it, you start copying by hand again — and you've just voided half the reason you bought the software.

The point is that **these changes aren't defects: they're the normal life of a tool you actually use.** Software that doesn't receive them isn't "finished and stable": it's **still while the world around it moves**, and a tool that's still while you change quickly becomes ballast. Every skipped small change is a piece of work you go back to doing by hand, a piece of trust you lose in the tool, a step towards "might as well not use it". The death of software isn't an event, it's a slow erosion made of small things not done — and that's exactly what a good maintenance relationship prevents.

## Who holds the keys: hosting, store, DNS, backups

Now a question that looks technical and is instead pure survival: **who holds the keys of your digital house?** Because your software, to work, lives in places and has accesses, and if those keys aren't yours, you don't really own your own online activity.

The "keys" you absolutely have to check:

- **Hosting** — the place where the software runs, the servers, the cloud services. If the account is in the supplier's name and not yours, the day they vanish or you fight, your software is hosted in someone else's house who can lock you out.
- **The domain and DNS** — the address of your site and the system that makes it point where it should. I've seen companies discover they don't own their own domain, registered to the vanished agency: it means not owning your own address, and not being able to do anything without whoever has control.
- **The store accounts**, if you have a published app — the accounts from which the app is distributed. If they're the supplier's, your app sits on their shelf, not yours.
- **Backups** — the safety copies of your data and of the system. Where are they? Who makes them? Can you access them? A backup that exists only on the supplier's computer isn't your backup: it's a hope registered to someone else.

The rule is simple and non-negotiable: **the keys have to be in your name.** The supplier uses them to work, with your permissions, but ownership is yours. It isn't distrust: it's the difference between having a tenant you give the keys to and renting a house of which you don't even own the lock. If today you don't know how to answer "whose are the hosting, the domain, the accounts, the backups of my software?", you've just found the most urgent thing to fix — even before the next change. Because without the keys, everything else (maintenance, changing supplier, even accessing your data) depends on someone else's goodwill.

## The maintenance contract: hours, SLA and what's "extra", explained simply

"Maintenance contract" sounds like a trick to make you pay again. In reality, done well, it's what guarantees you the tool stays alive and that someone answers when it's needed. Let's see what it contains, in plain words, without insider jargon.

A serious maintenance contract makes three things clear:

- **What's included and what's extra.** The fundamental distinction is between *keeping it alive* and *making it grow*. Keeping it alive — that the software continues to work, security updates, fixing what breaks, small corrections — is maintenance proper, usually covered by the retainer. Making it grow — new features, big changes, extra modules — is additional development, and it's paid separately. A good contract draws this line with clarity, so you know in advance what falls in and what doesn't, and you don't find surprise bills or arguments over "is this maintenance or is it new?".
- **How much time you have available.** Often maintenance includes a pool of hours or of interventions: the small changes above fall in there. Knowing how many you have lets you plan, and knowing what happens if you go over (you buy extra hours, at what price) avoids surprises.
- **How fast they respond — the SLA, in human words.** SLA is an acronym that means, in concrete: *if something breaks, in how much time do they put their hands on it?* And the answer isn't "immediately" for everything, because not everything is equal. A good agreement distinguishes:
  - *The software is down, you don't work any more*: it's an emergency, and it has to have a fast response — hours, not days. This is the case that costs you the most (see later), so it has to be the most protected.
  - *Something doesn't work but you can still work*: important but not an emergency, they intervene in a reasonable agreed time.
  - *A small change, an improvement*: it gets scheduled, it's done when there's space.

The point of the SLA isn't the acronym: it's putting in writing **what you expect when things go badly**, so that in the moment of panic there's nothing to argue about. "If the gestionale dies on a Monday morning, within how long does someone work on it?" — the answer to this question, written beforehand, is half the value of a maintenance contract. The other half is knowing that that someone **exists and knows your system**, which is exactly the opposite of the next scenario.

## The supplier who vanishes (and the code is on their PC)

Here's the nightmare, the real one, the one I hear told most often: the supplier **vanishes**. They don't answer emails any more, the phone rings into the void, they changed job, they closed, or they simply lost interest in your small project while they chase bigger ones. And you're left with software you use every day and nobody who knows how to put their hands on it.

Supplier ghosting hurts so much for a precise reason: **software is a box that, without whoever built it, nobody else can easily open.** If the code sits "on the supplier's PC", if there's no documentation, if only they had the accesses, when they vanish they take away the keys of understanding of everything. A new supplier, put in front of that software, first has to understand from scratch how it's made — a long, expensive job, assuming the code is recoverable. Meanwhile you're stuck: no changes, and if something breaks, panic.

How do you protect yourself from this scenario? Not by hoping the supplier is a good person (maybe they are, but you don't bet the company on it), but **demanding from the start the things that make you independent of them.** We'll get there in a moment with the list of what to have delivered, because it's the heart of the defence. But the principle is this: a serious supplier *works so that you can do without them.* They leave you the code, the accesses, the documentation, the exportable data — not because they want to lose you, but because they know the right way to keep a client is value, not the blackmail of being irreplaceable. Whoever instead keeps everything for themselves, whoever makes it obscure on purpose, whoever makes you understand that "without me you're lost", isn't protecting you: they're preparing the trap. It's the same logic that holds when you have to [rewrite a legacy gestionale]({{ '/en/blog/rewrite-legacy-erp-software/' | relative_url }}) inherited from whoever is no longer there — only there the damage is already done, while here you can avoid it by choosing well *before*.

## What to demand at delivery: the list that makes you free

This is the section to keep at hand, literally. At the moment of delivery of a piece of software — at go-live, or when you close a contract — there are things you **must** receive, and receiving them is the difference between owning your software and being a guest in its house. Demand them, in writing, from the start.

The delivery list that makes you free:

- **The source code, in a place that's yours.** Not "on the supplier's PC": in an archive (a repository) in your name, that you have access to. It's the recipe of your software: without it, you own nothing reproducible.
- **All the accesses, in your name.** Hosting, domain, DNS, service accounts, store, database. The keys above, all of them, in your hands.
- **The backups, and how to make them.** Where the safety copies are, how you access them, how often they're made. And the certainty of being able to recover your data even on your own.
- **Your data, exportable.** The concrete possibility of pulling out all your data in a usable format. If you can't export it, it's hostage.
- **Living documentation.** Not a tome nobody reads, but the essential information to understand how the system is made and how you put your hands on it: where things are, how you update, how you restart if it falls. "Living" means updated when the software changes, not written once and forgotten.

The test to understand if this list is in order is brutal and liberating: **"if tomorrow my supplier vanishes, can another competent technician take my software in hand and carry it forward?"** If the answer is yes, you're free: you have a supplier by choice, not by prison. If the answer is no, it doesn't matter how good or likeable whoever you have now is — you're trapped, and the trap will spring at the worst moment. Demanding this list is *not* a lack of trust: it's the thing that lets you trust serenely, because you know that if something goes wrong you're not finished. And a supplier who gives it to you gladly is, in itself, the signal that they're the right one.

## The cost of downtime versus the cost of the retainer

Back to the money, because that's where the objection "maintenance costs" dissolves. The right question isn't "how much does the maintenance retainer cost?", but "**how much does it cost me when the software stops and there's nobody?**". Let's put them in comparison honestly.

The **maintenance retainer** is a predictable, plannable cost, which as an order of magnitude sits in that 15–25% a year of the value of the software. You put it in the budget, you know it, it doesn't surprise you. In exchange you have: the tool that stays alive, the small changes done, security updated, and — above all — someone who knows your system and answers when you call.

The **cost of downtime** is unpredictable and often much higher. Think about what happens if the software your activity runs on dies on a Tuesday morning and there's nobody:

- **You don't work.** If the gestionale is down, the company is down or goes by hand, badly, in a rush. Every hour of downtime is lost work, clients waiting, orders that don't leave. Do a rough count: if in the company there are five people who depend on that tool and they stay blocked half a day, that's tens of hours of paid work and zero productivity, plus the slipped orders and the impatient clients — for many businesses a single day of downtime is worth, between the cost of idle staff and missed revenue, as much as or more than the annual maintenance retainer they wanted to save.
- **You pay for the emergency at a high price.** Finding someone who solves *now*, in a rush, a problem on software they don't know, costs much more than having a continuous relationship with whoever already knows it. The emergency intervention is always the most expensive rate.
- **You lose data or trust.** In the worst cases, badly handled downtime means lost data or clients who stop trusting. Damages that aren't measured only in euro.

Lined up, the account is clear: **the maintenance retainer isn't a cost, it's the price of not having the cost of downtime.** It's insurance, and like all insurance it looks like thrown-away money until you need it — then, the day you need it, it's worth ten times what it cost. Whoever cuts maintenance to save is betting that nothing will ever break and that they'll never need a change: it's a bet you always lose, because software is alive and life brings changes. This is also why the "budget for afterwards" has to be planned from the start, as I explain talking about [what happens after an MVP]({{ '/en/blog/90-day-software-mvp/' | relative_url }}): whoever spends everything to get to launch is left without fuel precisely when the journey begins.

## How much maintenance you actually need: neither too much, nor zero

Careful, because on the maintenance theme you get it wrong in two opposite directions, and I hide the second less precisely because it goes against whoever sells maintenance. The first is the one we've talked about: **zero maintenance**, abandoned software that dies. The second is the opposite: getting sold **more maintenance than you need**, an inflated retainer for software that doesn't need all that attention. The right sits in sizing honestly, and it's something that depends on *what* your software is.

Some coordinates to understand how much you actually need:

- **How critical is it?** If the software is the heart of your operations — if down means the company is down — then you need serious maintenance, with a guaranteed fast response: here you don't save. If instead it's a convenient but not vital tool, whose one-day downtime is an annoyance and not a disaster, you can afford a lighter agreement, with more relaxed response times.
- **How much does it touch the outside world?** Software that talks to payments, banks, authorities, external services needs more maintenance, because that world changes the rules continuously and it has to keep up. Closed software, that does its own calculations on its own, changes less and needs fewer interventions.
- **How much does your company change?** If you're in a growth and change phase, the software will follow you with lots of small changes: maintenance will be more active. If you're stable and processes don't change, you'll mostly need "keeping it alive", with few changes.

**A serious maintenance contract is for you if** your software is alive, you use it every day and a stop or a block costs you work, clients or money. **You don't need a heavy contract if** the tool is secondary, little exposed to the outside world, and stable — there a light agreement is enough, or even just the certainty of being able to call someone when needed. What is *never* a sensible option is **zero**: even the quietest software needs, now and then, updated security and someone who knows where to put their hands.

An honest supplier sizes the maintenance on your real case, and calmly tells you "you only need a little" when that's so — because their interest is that you pay the right amount and are happy, not that you sign the highest possible retainer. If someone wants to sell you an enormous maintenance contract for a tool that doesn't justify it, it's the same music as the slide salesperson, played the other way. Measure, here too, is the rule.

## How to change horses without dying

And if the supplier you have now isn't working? They don't vanish, but they don't answer in time, or they've become expensive, or they simply no longer give you the service that's needed. You can change — but it has to be done with a head, because it's the most delicate moment, the one where you're most vulnerable.

The rules for changing supplier without being left on foot:

- **First recover the keys, then let go.** Don't announce that you're changing until you have in hand code, accesses, backups and exported data. If you say it first and they still have the keys, you've put yourself in a weak position. Recover everything *while* the relationship is still good, then decide.
- **Don't switch off the old before you've switched on the new.** The passage is done in overlap: the new supplier studies, takes it in hand, verifies they can manage everything, and *only then* you detach the old. Never a gap in the middle where nobody is responsible.
- **Have the new one do an "exam" of the system.** Before you commit, ask the new supplier to look at the code and the documentation and tell you honestly what state it's in and what taking it on involves. If the previous work was a black box with no documentation, better to know it first.
- **Document the passage.** What you discover and fix during the change gets written, so the new relationship starts with the living documentation that maybe was missing.

The truth is that **changing supplier is easy or impossible depending on what you demanded at the start.** If you have the delivery list in order — your code, your accesses, exportable data, documentation — changing is a manageable project. If you don't have it, changing is almost redoing from scratch, and you stay a prisoner not by choice but for lack of alternatives. That's why everything comes back to the principle: freedom in the *afterwards* is built in the *before*, demanding the right things when you still have bargaining power. It's the thread that ties the whole [buying custom software]({{ '/en/pillar/buying-custom-software/' | relative_url }}) cluster: buying well isn't only choosing the right supplier today, it's staying free to choose another tomorrow.

## It's for you if / it isn't for you if

**It's for you if:** you have software going live or already live without a plan for afterwards; you don't know in whose name hosting, domain, store and backups are; you're afraid the supplier will vanish and take the code with them; a day of downtime would stop the company and you have no one who answers.

**It isn't for you if:** you want to treat software like a chair you never touch (then this article has already told you how that ends); the tool is secondary, little exposed, stable, and a light on-call agreement is enough; you're looking for whoever sells you the biggest retainer possible instead of sizing it on your real case.

## Frequently asked questions

**Why do I have to pay maintenance if the software is "finished"?**
Because it isn't finished: it's alive. The world around it changes (rules, rates, security, connected services) and real use always brings small changes. Software that isn't maintained doesn't stay stable, it degrades: it's the "finished project that dies in six months". The retainer keeps the tool alive and guarantees you someone who answers.

**What falls into maintenance and what is paid separately?**
Generally *keeping it alive* (working, security, corrections, small changes) is in the retainer; *making it grow* (new features, modules, big changes) is additional development on the side. A good contract draws this line in the clear, so there are no surprises or arguments.

**What's the SLA, in simple words?**
It's the written promise of *how fast they respond when something goes wrong*. A good agreement distinguishes the emergency (software down, response in hours) from what's important but not blocking (reasonable agreed time) and from the small changes (they're scheduled). It serves so you don't have to argue in the moment of panic.

**How do I know if I have "the keys" of my software?**
Ask yourself whose they are, registered to, the hosting, the domain and DNS, the service and store accounts, the backups. If the answer is "the supplier's", you don't own your digital presence. They have to be in your name: they use them to work, but ownership is yours.

**What do I have to have delivered so I don't stay a prisoner?**
The source code in an archive of yours, all the accesses in your name, the backups and how to make them, your exportable data, and living documentation. The test: "if the supplier vanishes, can another technician take my software in hand?". If yes, you're free; if no, you're trapped.

**And if my supplier has already vanished and I have nothing in hand?**
You can recover, but it's more expensive: a new technician first has to understand from scratch a system with no documentation. First thing, recover every access and every copy you can; then have the state of the code evaluated by someone competent. It's the scenario of the inherited legacy gestionale: manageable, but it's the reason it's worth demanding the right things *before*.

**How much does not doing maintenance really cost?**
Much more than the retainer. The cost of downtime (you don't work, the company blocks), the cost of the emergency (having it solved in a rush by whoever doesn't know the system costs the most expensive rate), and in the worst cases lost data or clients. The maintenance retainer is the insurance that avoids these costs: it looks like spend until you need it, then it's worth ten times.

**Can I change supplier without blocking everything?**
Yes, if you have the keys. Recover code, accesses, backups and data *while* the relationship is still good, have the new supplier study the system, and detach the old only when the new is ready — never a gap in the middle. If you demanded the delivery list at the start, changing is manageable; if you don't have it, it's almost redoing from scratch.

## In one line

**Go-live isn't the finish line, it's the start**: the "finished" project dies in six months because of small changes never made (a VAT rate, a field, an export), keys that aren't yours, and a supplier who vanishes with the code on their PC. Demand at delivery source code in a place of yours, accesses in your name, backups, exportable data and living documentation. The 15–25% a year retainer isn't a tax: it's the insurance against downtime that, for many companies, in a single day is worth more than the annual fee.

If you have software you care about and you want to understand whether you're free or a prisoner — whether you have the keys, whether you could change, whether you're covered when it breaks — look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/) and we check it on your case.
