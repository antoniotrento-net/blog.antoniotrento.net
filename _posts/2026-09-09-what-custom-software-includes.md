---
lang: en
permalink: /en/blog/what-custom-software-includes/
alt_url: /it/blog/cosa-include-software-su-misura/
title: "What you're buying when you sign a custom build (and why it isn't 'a 3,000-euro website')"
date: 2026-09-09 07:30:00 +0200
author: "Antonio Trento"
description: "An honest guide to what's really inside a custom development quote: the line items that count, the ones missing from quotes that are too low, who owns what, and the maintenance nobody wants to hear about."
keywords: ["what custom software includes", "application development quote", "website vs software difference", "application maintenance", "code ownership"]
image: /assets/images/posts/cosa-include-software-su-misura.jpg
pillar: comprare-software
related: [/en/blog/before-building-an-app/, /en/blog/90-day-software-mvp/]
---

## Website, e-commerce, gestionale, app: four different trades

The misunderstanding that ruins more development negotiations than any other starts from a word used in the wrong place. The client says "I need a website" and means one of four completely different things. Then they receive a quote of 3,000 euro for one, they compare it with a quote of 40,000 for another, and they conclude that "the second one wants to rip me off". It isn't so: they're selling two different trades, and the client doesn't know because nobody has ever explained it to them honestly. Let's do it here.

When we talk about "custom digital stuff", there are at least **four trades**, and they cost differently because they *are* different:

- **The showcase site.** It tells who you are, what you do, how to contact you. It's made mostly of content and presentation. The visitor *reads and looks*, they almost never "do" anything. It's the simplest and the cheapest, and that's fine — if that's what you need. A good showcase site can really cost a few thousand euro, and that's right.
- **The e-commerce.** Here the visitor *does*: they choose, they put in the cart, they pay. Underneath there are products, warehouse, payments, shipping, orders to manage. It's already another planet compared to the showcase: there's a machine that has to run, not only pages to read.
- **The gestionale.** It's the tool with which *you and your company work*: you manage orders, clients, production, files, whatever your trade is. The public doesn't see it, you use it every day, and it has to fit with how you actually work. It's made of logic, rules, flows — the invisible part, but where the value sits.
- **The app / the application.** A tool that solves a specific problem for whoever uses it — clients or employees — often from the phone, often with data that moves, roles, payments. It's a product of its own, with a complexity that depends entirely on what it has to do.

The point isn't "which is better": it's that **comparing their prices without knowing what you're talking about is like comparing the price of a bicycle with that of a van because "both have wheels".** A showcase site and a gestionale aren't the same object at two prices: they're two different jobs. The first error not to make, even before reading a quote, is to have clear *which of the four* you're buying. If you don't know, every figure will seem random — too high or too low — because you're missing the metre. This guide is there to give you the metre.

## What's inside a serious quote

A well-made custom development quote **isn't a line with a total.** It's a document that shows you *what* you're buying, piece by piece. And the pieces that count, the ones that distinguish a serious quote from a number thrown out, are these:

- **The analysis (the discovery).** Before building, someone has to understand what has to be built: who uses it, which flows, which data, which rules. A serious quote has this item *explicit*, because that's where you avoid building the wrong thing. If it's missing entirely, whoever quotes you is guessing the perimeter — and guessing badly, you'll pay later. It's the phase I talk about in [what to do before building an app]({{ '/en/blog/before-building-an-app/' | relative_url }}): without it, the rest is air.
- **The interface design (UI/UX).** How what the user sees and uses will be made: the screens, the flows, the experience. Not "a bought theme", but the drawing of how it will actually be used. It's a work item, not a gift.
- **The data.** Where it comes from, how it's structured, how you migrate what you already have (from the old system, from Excel sheets), how you keep it safe. In real software the data is half the work, and a quote that doesn't name it is hiding half the project.
- **The actual development.** The backend (the engine, the logic), the frontend (the face), the integrations with the things you already have. This is the item everyone expects, and it's right that it's there — but it's only *one* of the items, not the whole quote.
- **Go-live.** Taking the thing online for real: putting it in production, the final tests, the passage from "it works on the computer of whoever made it" to "it works for your real users". It isn't automatic and it isn't free.
- **The warranty and the running-in period.** What happens in the first weeks, when the problems that you only see with real use emerge. A serious quote says what's covered and for how long.
- **Maintenance afterwards.** An honest mention of what's needed *after* launch — I'll talk about it in a moment, because it's the item everyone makes disappear.

You don't need to understand the technical details of each. You need to **see them**: a quote that names them is a quote that's showing you the real work. A quote that's a single line with a number is hiding where the money is — and what's hidden jumps out later, as an extra cost or as a thing not done.

## What's missing in 3,000-euro quotes

Now the uncomfortable part, the one that saves you from disasters. A quote arrives that's much lower than the others — the famous "I'll do it for 3,000" for a thing others quote you ten times as much. It isn't (only) that one is more expensive: it's that **the low quote, almost always, is quoting a different and smaller thing**, and you discover the differences later. Here's what is usually missing in a quote that's too low for what you think you're buying:

- **The analysis is missing.** You start building without having understood the perimeter. Result: halfway it emerges that "this was needed too", and every "this too" is an extra outside the quote. The low starting price becomes a high price at the end, in instalments of surprises.
- **Handling of the real cases is missing.** The low quote prices the *happy path*: everything goes well, the data is right, the user does what they should. But real software is made 80% of the *crooked* cases — the errors, the empties, the permissions, the "what happens if two people together". That work, in the 3k quote, isn't there. And without it, you have a thing that works in the demo and collapses the first day.
- **The data, for real, is missing.** Migrating your real data, keeping it in order, safe, compliant: it's work the low quote skips. Then you find yourself re-entering everything by hand or with data that doesn't add up.
- **The afterwards is missing.** No real warranty, no maintenance. The day after launch you're alone — and launch, as we'll see, is when problems *start*, not when they end.
- **Clear ownership is missing.** Often the low price hides that you don't really own what you paid for (the next chapter is all about this).

Careful: **I'm not saying expensive is right and cheap is a scam.** Sometimes the low quote is honest — because you really only need the showcase site, and then 3,000 euro is correct. The problem is when you buy "3,000 euro of showcase" believing you're buying "the gestionale that changes the company". The right question in front of a quote that's too good isn't "how can it cost so little?", but "**what isn't in here that is in the others?**". Get them to tell you, item by item. If they can't answer, you have the answer.

## Ownership: who owns the code, the graphics, the accounts, the data

This chapter is worth, on its own, the price of a rude awakening. When you pay for a custom build, **what do you actually own, at the end?** The question seems obvious ("I paid for it, it's mine, right?") and the answer, too often, is: it depends on what's written in the contract, and often it's written against you.

The things you have to check *before* signing, because afterwards it's late:

- **The code.** Is it yours, or is it "licensed" by whoever made it? The difference is enormous: if it's yours, tomorrow you can change supplier and take the work with you; if it's only licensed, you're tied for life to whoever made it, and if they vanish or raise prices, you're trapped. A custom build *should* leave you ownership of the code: demand it in writing.
- **The graphics and the content.** The design, the texts, the images you paid for: are they yours? It seems obvious, often it isn't.
- **The accounts and the domains.** The site domain, the accounts of the services it runs on, the access: are they in your name or the supplier's? I've seen companies discover they don't even own their own domain, registered to the agency that had then vanished. If the accounts aren't yours, you don't own your own online presence.
- **The data.** *Your* data — clients, orders, everything the software accumulates while working — has to be yours and you have to be able to **take it away** in a usable format. A system that holds your data hostage, from which you can't export it, keeps you tied to it even when you want to leave. The possibility of exporting your data isn't a technical detail: it's your freedom.

The principle, simple: **you paid, it has to be yours, and you have to be able to change your mind.** Ownership of the code, the data, the accounts isn't lawyerly nitpicking: it's what decides whether in three years you're free or a prisoner. An honest supplier puts it in black and white without you having to ask, because they aren't afraid you might leave — they work to keep you with value, not with chains. Someone who dances around the question "is the code mine?" is telling you something, listen to them.

## Maintenance: the 15–25% a year that nobody wants to hear

Here's the item that makes every client wrinkle their nose and that no salesperson puts in the spotlight: after building the software, **you need to maintain it**, and it isn't free. As an order of magnitude — not a fixed rule, but an honest reference — maintenance of a piece of software is typically something like **15–25% a year** of what it cost to build. I can already hear the objection: "but how, I paid for it, why do I have to pay again?". Because software isn't a painting hung on the wall: it's a **living** thing, and living things have to be kept alive.

What you actually pay for with maintenance:

- **The world around it changes, and it drags your software with it.** Phones update, browsers change, the services your software talks to (payments, banks, other systems) modify their rules. Without maintenance, software that works today starts breaking on its own in a year — not because it was made badly, but because the ground underneath has moved.
- **Security.** New vulnerabilities emerge continuously. Software that isn't updated becomes, over time, an open door. Maintenance is also keeping that door closed.
- **The small changes.** Using it, you discover things to fix, a flow to improve, a feature to add. Software that *can't* evolve with your company quickly becomes a cage. Maintenance is also the possibility of adapting it while you change.
- **Someone who's there when something goes wrong.** Perhaps the biggest value: knowing that if one day something breaks, there's a person who knows your system and fixes it — instead of you desperately looking for someone who understands work done by others.

The real cost isn't maintenance: it's **skipping it**. Software left without maintenance is the "finished project that dies in six months" — it works at launch, then it degrades, then one day it breaks and there's nobody left who knows how to put their hands on it. At that point either you redo it from scratch (spending everything again) or you stay stuck. The 15–25% a year isn't a tax: it's the insurance that your investment keeps returning instead of rotting. Whoever sells you the build without saying *a word* about maintenance is preparing exactly that ending — and it's worth choosing from the start someone who puts the "afterwards" in the clear from day one.

## How you pay: on progress, not "everything at the start"

*How* you pay also tells you a lot about the seriousness of whoever you have in front of you, and it protects you. The healthy rule is: **you pay on progress** — a piece at the start, then other pieces tied to concrete results as the work proceeds — not everything in advance, and not everything at the end.

Why it's the right way, for both:

- **It protects you.** If you pay everything at the start, you've given away every power: if the supplier slows down or vanishes, you've lost the money and you have nothing in hand. Paying in stages, every payment corresponds to something delivered and verifiable. Your risk is always limited to the current stage, not to everything.
- **It also protects whoever builds**, and that's right: nobody serious works for months without intermediate receipts, and a client who doesn't pay the first stage is a signal. A good mechanism protects both, and that's healthy.
- **It keeps everyone honest.** Tying payments to concrete results ("when this piece is ready and verified") means you both stay focused on delivering real things, not on postponing.

The two extremes to distrust: whoever asks you for **everything in advance** (you give away every protection) and whoever tells you **"you only pay at the end, when you're happy"** (it sounds generous, but either they have no structure, or there's a hidden catch, because nobody works months for free risking everything). The right sits in the middle: stages, results, payments tied to those. If whoever you have in front spontaneously proposes payment on progress, it's a good sign: they're thinking of a balanced collaboration, not of cashing in and disappearing.

## The red flags to recognise immediately

Let's put the alarm bells together, so you have them in your pocket when you talk to anyone. If you see one, prick up your ears; if you see three, run.

- **The quote is a single line with a total.** No items, no detail of what it includes. They're hiding where the money is and what's missing.
- **No analysis, they start building immediately.** It means they guess the perimeter, and you pay the extras.
- **They say yes to everything, with no trade-offs.** Reality is made of choices; whoever doesn't name any hasn't understood or isn't telling you.
- **They dance around ownership.** To the question "are the code and the data mine, and can I take them with me?" they answer vaguely. Vagueness here is an answer.
- **They don't mention maintenance.** They sell you the "finished" and stay silent on the afterwards. They're preparing the project that dies in six months.
- **They want everything paid at the start.** All the risk on you.
- **They put you in a hurry.** Artificial urgency is a sales technique, not a way of working.
- **They talk about fashionable technology, not your problem.** If the "how cool" arrives before the "what you need and why", you're buying smoke. It's the same signal as the slide salesperson I talk about elsewhere.

None of these, on its own, is proof of a scam. But they're the points on which to **ask questions** — and the way they answer is worth more than the answers themselves. A serious supplier is glad you ask: it means you know what you're buying, and with someone who knows what they buy you work better. Whoever gets annoyed at your questions is telling you they'd rather you didn't look too closely.

## When you need custom, and when ready-made is enough

Before spending on a custom build, the most honest question — and the one that saves you the most — is: **do you really need it, or is something ready-made enough?** I tell you this as someone who lives on custom, so listen precisely because it goes against my immediate interest: very often ready-made is the right choice, and building from scratch would be throwing money away.

**Ready-made is enough when** your need is the standard one lots of people have: a normal showcase site, an e-commerce with common needs, appointment management in a sector where excellent vertical products already exist, invoicing, accounting. For these things ready-made tools exist — often as a subscription of a few tens of euro a month — well made, maintained by others, that cover 80% of cases. If you're in that 80%, buy the ready-made and be happy: don't have custom-built what already exists and is fine for you. It's the intelligent choice, not a fallback.

**You need custom when** you have that 20% of *your* needs that the ready-made doesn't cover: a particular workflow that distinguishes you, the fit between systems you already have that no ready-made product knows how to talk to, rules that are your competitive advantage and that a standard tool would force you to bend. Custom isn't there to redo the 80% that already exists: it's there *precisely* for that 20% that's worth the money it's worth, because that's where your way of working sits — the part that makes you earn and that no bought software knows.

The error in both directions costs. Building custom what you could have bought ready-made is pure waste. But the opposite is a cost too: forcing your company into a ready-made tool that doesn't fit, adapting *your* work to *its* logic, costs you in efficiency every day, silently. The skill isn't "selling custom" nor "saving with ready-made": it's **understanding which of the two cases you're in**, item by item, function by function. Often the best answer is mixed — ready-made for the standard 80%, custom stitched on top for your 20% — and that's the solution an honest supplier proposes even when it would suit them more to sell you everything to build.

## What buying badly costs you, in euro

So far we've talked about what's in a quote. But the bill that really weighs isn't the price written on the quote: it's the **cost of buying the wrong thing**, which you don't see on any invoice and which you pay all the same. Let's put it in numbers, with declared estimates — not promises, orders of magnitude to adapt to your case.

- **The low quote that becomes high.** You sign at 8,000 what others quoted at 20,000, happy with the deal. But the analysis was missing, the real cases were missing, the data migration was missing. In the following months the extras arrive — "this wasn't planned", "this other thing is needed too" — and at the end of the project you've spent 18,000 for a thing that barely holds, against the 20,000 that would have given you something solid. You paid **almost the same, for much less**, plus the months lost.
- **The project that dies and has to be redone.** You buy without maintenance, the software degrades, in a year or two it's unusable and nobody knows how to put their hands on it any more. You redo it from scratch: you've paid **twice** for the same software, instead of spending 15–20% a year to keep it alive. On a 20,000 job, redoing it means throwing away 20,000 and spending another 20,000 — when 3,000–4,000 a year of maintenance would have avoided it.
- **The supplier prison.** You don't own the code or the data. The supplier raises prices, or vanishes, or doesn't answer any more. You're stuck: every small change costs what they say, and changing means starting from scratch. The cost here isn't a single figure: it's a **continuous tax** on your lack of freedom, for years.

Add these scenarios and you understand why "how much does it cost?" is the wrong question to ask first. The right question is "**what does buying badly cost me?**" — and the answer is almost always much more than the saving you thought you were making by choosing the lowest quote or skipping the uncomfortable items.

There's then a structural reason why custom projects go badly, and it's the way they're split: one does the "site", another "the gestionale", a third "the payment integration", a fourth "the app". Four suppliers, four pieces that have to fit and don't fit, and when something doesn't add up each blames the others. You, in the middle, pay in months and in nerves for the lack of a direction. It's why a **single pair of hands** that holds together data, backend, frontend and — where needed — the AI, beats four suppliers who bounce blame: not because it's cheaper on the single piece, but because it eliminates the biggest hidden cost, that of stitching together pieces thought separately. When you evaluate a quote, ask yourself this too: who holds the picture together? If the answer is "nobody, they're four different suppliers", each one's low quote hides the high cost of the whole.

## How to use this page while you talk to anyone (me included)

I close with the most honest thing I can tell you: **use this guide even against me.** It isn't a figure of speech. If one day you write to me for a project, I want you to arrive with these questions in hand, because with a client who knows what they're buying I work better, and the result is better for both.

Here's how to use it, in practice, with anyone who will give you a quote:

1. **First understand which of the four trades you need** — showcase, e-commerce, gestionale, app. If it isn't even clear to you, start there: that's the analysis phase, and it has to be done before any price.
2. **Ask for the quote by items**, not a total. Get them to show you analysis, interface, data, development, go-live, warranty, maintenance. What isn't there, ask why.
3. **Compare at equal trade.** Don't compare the bicycle to the van. If two quotes are miles apart, almost always they're quoting two different things: get the difference explained item by item.
4. **Ask about ownership**, in writing: code, data, accounts, and the possibility of exporting your data and leaving.
5. **Ask about maintenance** and payment on progress. The answers to these two questions separate whoever thinks of a relationship from whoever thinks of cashing in and disappearing.

This is the logic of the whole [buying custom software]({{ '/en/pillar/buying-custom-software/' | relative_url }}) cluster: not to sell you something, but to put you in a position to buy well — because a client who understands what they buy is a client who's then happy, and happy clients are the only marketing that actually counts.

## It's for you if / it isn't for you if

**It's for you if:** you're about to sign a custom quote and you want to understand what you're actually buying; you received a 3,000-euro quote and a 40,000-euro one and you don't know why; you need to check ownership of code, data and accounts before you sign; nobody has talked to you about the 15–25% a year of maintenance.

**It isn't for you if:** you really only need a showcase site and 3,000 euro is the right trade (then this guide has already told you that's fine); you're looking for the cheapest total without comparing items; you want someone who says yes to everything and doesn't ask about perimeter, ownership or afterwards.

## Frequently asked questions

**Why are two quotes for "the same job" so different?**
Almost always because it *isn't* the same job: one quotes a showcase, the other a gestionale, or one includes analysis, data, real cases and maintenance while the other only the happy path. Compare at equal trade and get the items detailed: the difference jumps out immediately.

**How do I know if a low quote is honest or incomplete?**
Don't ask "how can it cost so little?", ask "what isn't in here that is in the others?". Get them to tell you item by item: analysis, handling of crooked cases, data migration, warranty, maintenance, ownership. What's missing you'll pay later, as an extra or as a problem.

**Is the code I pay for mine?**
It has to be, and it has to be written in the contract. If it's only "licensed" by whoever made it, you're tied to them for life. Demand ownership of the code, the graphics, the accounts and the data, and the possibility of exporting the data and changing supplier.

**Do I really have to pay maintenance every year?**
Yes, and it's the most underestimated item. Software is alive: the world around it changes, security has to be kept, small changes are needed and someone who is there when it breaks. As an order of magnitude it is 15–25% a year of the build cost. Skipping it is like building the "finished project" that dies in six months.

**Is it normal to pay everything in advance?**
No. The healthy way is on progress: payments tied to concrete results as you go. Everything in advance takes away every protection; "everything at the end" usually hides something. The right sits in the middle and protects both.

**What's the real difference between a website and gestionale software?**
A website people *look at*; a gestionale *you work in*. The first is content and presentation, the second is logic, data and rules that fit with how you actually work. They're two different trades, and they cost differently because they are.

**What has to be in an analysis phase?**
Understanding who will use the thing, which flows, which data, which rules and risks — before building. It serves to define the perimeter and avoid building the wrong thing. It has to be an explicit item of the quote: if it's missing, they're guessing the perimeter.

**How do I use this guide without offending whoever quotes me?**
Whoever is serious is glad you ask: it means you know what you buy. Use the questions on items, ownership, maintenance and payments with anyone — me included. Whoever gets annoyed at your questions is telling you they'd rather you didn't look too closely, and that's already an answer.

## In one line

When you sign a custom build you are **not buying "a 3,000-euro website"**: a showcase, an e-commerce, a gestionale and an app are four different trades, and comparing them by total is comparing a bicycle to a van. A serious quote names analysis, interface, data, development, go-live, warranty and the 15–25% a year of maintenance; a quote that's too low is almost always quoting a smaller thing. Demand ownership of code, data and accounts, pay on progress, and ask yourself first whether ready-made is enough — custom is for your 20%, not to redo the 80% that already exists.

If you have a project in your head and you want to reason it through with someone who starts from the questions and not from the quote, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/) — and bring this list.
