---
lang: en
permalink: /en/blog/booking-cart-abandonment/
alt_url: /it/blog/abbandono-prenotazione-carrello/
title: "UX that makes people abandon the booking (or the cart): you don't need 'more traffic', you need a flow that closes"
date: 2026-09-05 07:30:00 +0200
author: "Antonio Trento"
description: "You pay for ads, you bring people to the site, and you lose them at the form. The problem is almost never traffic: it's the flow that doesn't close. How you find it and fix it, for real."
keywords: ["booking cart abandonment", "checkout ux", "forms too long", "mobile conversion", "rebuild product interface"]
image: /assets/images/posts/abbandono-prenotazione-carrello.jpg
pillar: web-prodotto
related: [/en/blog/slow-site-user-errors/, /en/blog/showcase-site-vs-digital-product/]
---

## You pay for ads and you lose them at the form

Let's do the sum almost nobody does all the way. Say you spend €2,000 a month on campaigns. They bring, say, 4,000 visits to the site. Of those, 400 arrive at the moment of truth — the cart, the booking form, checkout. And there, of those 400, 80 "close". The other 320 leave.

Now, the question everyone asks you — the agency, the marketing consultant, the brother-in-law who's a Facebook expert — is: *how do you bring more traffic?* More budget, more campaigns, more visits. But look at the numbers again. You have a funnel that loses 80% of people **in the last metre**, the one that costs you most, the one you'd already paid to fill. Doubling traffic means doubling the budget to keep throwing away four people out of five right when they were about to give you the money.

Traffic is the wrong lever because it's the most expensive and the most visible. The right lever, almost always, is invisible: **the flow that doesn't close**. If from 80% abandonment you go down to 60% — not a miracle, a cleanup job — you've doubled conversions *without spending one more euro on advertising*. The same 400 people at the last metre, but 160 who complete instead of 80. It's the same sum, read from the other side: every point of abandonment you recover is worth free traffic.

This article is about that: why people abandon right when they were about to buy or book, how you discover *where* you're losing them (not by gut), and when it's worth fixing three obstacles instead of redoing everything. It's the point of view of someone who builds these flows and sees them fail always at the same points — points the marketing office doesn't see, because whoever designed the form is never the person filling it with their thumb, in the rain, on 12% battery.

## Mobile: the finger, the keyboard, the 12 fields

First uncomfortable truth: **most of your users are on the phone, and you tested the form on the 27-inch monitor**. They're two different worlds, and the form that looks "clean and complete" on desktop, on mobile is torture.

On the phone three things change that nobody considers when they design:

- **The finger isn't a mouse.** It's big, imprecise, it covers what it touches. Small fields, buttons stuck together, tiny checkboxes: every target too small is a tap error, and every error is a micro-annoyance that brings abandonment closer.
- **The keyboard eats half the screen.** When the user taps a field, the keyboard comes up and covers the bottom. If the "continue" button ends up under the keyboard, or if the field they're filling gets covered, the person doesn't understand if they've finished, where they have to scroll, what to do. Confusion = exit.
- **The wrong keyboard type.** A phone field that opens the letter keyboard instead of the numeric pad. An email field that puts automatic capital at the start. These are details that scream "this form isn't thought for you", and each one adds friction.

Then there's the capital sin: **the 12 fields**. First name, last name, email, phone, address, city, postcode, province, company name, VAT number, notes, and the consent here and there. Each one taken on its own looks like "it's needed". All together, on the phone, they're a wall. And you don't jump the wall: you go around it by closing the tab.

The healthy rule is brutal: **every field has to justify its existence at the moment you ask for it**. Not "it might be useful to accounts", not "while we're at it". *Is it needed now, to do this thing here?* If the answer is no, that field doesn't come out of the database — it gets moved *after*, when the person is already in, they've already said yes, and asking for something extra doesn't cost them the escape. I'll come back to this in two paragraphs, because it's the technical point that separates whoever understands UX from whoever stacks fields.

## Steps: what's mandatory now, what can wait until after

The secret of a flow that closes isn't "fewer fields" in the abstract. It's **the right sequence**: ask for the indispensable minimum to trigger the "yes", and postpone everything else until after the yes has triggered.

Think about what you *really* need to complete the action, now:

- **For a booking:** when, for what, and how I reach you. Service, date/time, a contact. Period. VAT number, billing address, detailed preferences — needed? Sure. Needed *to book*? No. Needed after, to invoice, and at that point the person is already a client and gives them to you gladly.
- **For a cart:** what they buy, where I send it, how they pay. The rest — create an account, subscribe to the newsletter, say how they found you — is your stuff, not theirs. Every thing of yours you stuff in before payment is a piece of friction you pay in abandonments.

The great classic to avoid is **the mandatory account before buying**. "Register to continue." It's the fastest way to lose whoever only wanted to give you the money quickly. Whoever wants the account, you offer it *after* the purchase ("want to save these details for next time?"), when they've already converted and the proposal sounds like a favour, not a toll.

The logic is that of "**progressive disclosure**": you reveal the requests a bit at a time, as the person commits, instead of slamming the whole wall in front of them at the first step. Every small "yes" makes the next more likely. A wall of 12 fields at the first blow asks for one big cold "yes", and cold, people say no.

Careful: this is *not* a manipulation technique. It's respect for the time of whoever is buying. You ask for what you need when you need it, and not a second before. It's the same philosophy with which I distinguish [a showcase site from a digital product]({{ '/en/blog/showcase-site-vs-digital-product/' | relative_url }}): the showcase shows you and that's it; the product **makes whoever arrives do** something, and "making them do" well means taking every stone off the path between intention and the fact.

## Errors: "something went wrong"

There's a moment when abandonment isn't the length's fault or mobile's: it's how you handle the **error**. And here you do serious damage, because the user in error is someone who *was* buying — you lost them right at the best moment.

The screen that kills more sales than any other is this: **"Something went wrong. Try again later."** It doesn't say what went wrong. It doesn't say what the user has to do. It doesn't say if their data is saved or lost. It's a dead end with a vaguely blaming tone too. The person doesn't "try again later": they close and go to the competitor, and you paid the ads to bring them there.

Errors split into two families, and they have to be treated in opposite ways:

- **User error** (they mistyped the email, they left a field empty, the card is expired). Here the error has to appear **next to the right field, immediately, and say how to fix it.** Not "form invalid" at the top of the page, but "the @ is missing in the email" right there, under that field, while they're filling it. The user fixes in two seconds and goes on. A clear, local error isn't an obstacle: it's help.
- **System error** (payment doesn't go through for a technical problem, the server hiccupped). Here the golden rule is: **never make the user lose what they've already entered**, and tell them something true and useful. "Payment didn't go through, we haven't charged you anything, try again or use another card — your details are here, you don't have to re-enter them." Reassurance + clear action + no work redone. This turns a potential abandonment into a second attempt.

The difference between the two handlings isn't "aesthetics of the little message". It's architecture: because the frontend can say *what* went wrong and *what to do*, the backend has to have passed it an error that means something. And it's exactly here that the bridge falls, in the next point.

## The backend that refuses and the frontend that doesn't explain

Here's the structural defect that generates half of the "mysterious" abandonments, and the reason why it matters who builds your thing.

Very often the flow is split between two worlds that don't talk. There's whoever made **the interface** (the agency, the template, the bought theme) and there's whoever made **the engine** (the ERP, the payment system, the logic behind). The frontend sends the data; the backend, for a rule of its own, **refuses** them — the date is no longer available, the discount code has expired, that item is out of stock, the VAT number isn't in the right format. But the refusal comes back to the frontend as a generic error, often a technical code. And the frontend, which doesn't know *why* it was refused, can do nothing but show... "something went wrong".

The result for the user: they did everything right (according to them), they press confirm, and they get a wall. They don't know that choosing another time would have been enough, or that the discount code expired yesterday. They leave convinced that "the site doesn't work". And technically they aren't wrong.

This problem **isn't fixed with a prettier frontend**. It's fixed only if whoever does the interface and whoever does the engine are, if not the same person, at least under the same direction — if the backend is designed to **explain why** it refuses ("date not available", not "error 409") and the frontend is designed to **translate** that why into an action ("that slot was just taken, these nearby ones are free"). It's the moment when you see the value of **one hand** that holds data, backend and frontend together: when the flow jams, there isn't the agency saying "it's the ERP's fault" and the ERP supplier saying "it's how they call our APIs". There's a head that sees the whole chain and fixes the right point. This is the same dynamic I describe in [why a slow site makes users err]({{ '/en/blog/slow-site-user-errors/' | relative_url }}): the most expensive conversion problems live in the **seam** between the pieces, and it's the seam that no single supplier feels responsible for fixing.

Ready-made checkout SaaS and the booking plugin give you the 80%: the form, the steps, the button. The last 20% — making *your* backend rules talk to *your* frontend so that errors become actions instead of walls — is your specific logic, and it isn't in the plugin settings. It's the piece that decides whether the flow closes or loses people at the last metre.

## Test: 5 real users beat 50 internal opinions

Now the part that flips the way most companies decide on UX.

When it's time to understand why the form doesn't convert, the meeting starts. The owner thinks one thing, sales another, the designer defends their layout, someone cites an article they read somewhere. Fifty internal opinions, all plausible, all useless — because none of those people **is** the user. They already know where to click. They already know the terms. They've already decided to trust. They're the last people in the world who can tell you where a stranger gets lost.

There's a fact, by now old and rock-solid, on usability research: **with 5 real users you find the large majority of a flow's problems.** You don't need a statistical sample of hundreds of people to *discover where people get stuck*. You need five, taken one at a time, put in front of your site with a task ("book an appointment for Thursday", "buy this and have it shipped") and the instruction to **think out loud** while they do it. You stay quiet and watch.

What happens in those five sessions is worth more than any meeting:

- You see *where* they stop — the field they reread three times, the button they don't find, the point where they say "and now?".
- You hear *what they think* at the moment it happens — "what does this want?", "I already put the email before", "I don't trust putting the card here".
- You discover that the three problems costing you 80% of abandonments are **always the same three**, and you see them repeat already from the second or third user.

It isn't university-lab research. It's something you do in an afternoon, with five people who don't know the site (not your employees, not your wife: new people, as similar as possible to real clients). It costs almost nothing and it tells you, with facts, where to intervene — so you stop redoing by gut and start fixing with a sure shot. It's the same principle of the [5 users who beat 50 opinions] that holds anywhere you design something that has to *work* for someone who isn't you: the only judge is the real user, everything else is opinion.

## When to redesign everything and when three obstacles are enough

Practical question, the one that weighs on the budget: *do I have to redo the interface from scratch or fix what's there?* The honest answer, almost always, is: **first fix the three obstacles, then see.**

The temptation (pushed also by whoever wants to sell you a redesign) is "let's redo everything, modern, pretty". But a full redesign is expensive, long, and — serious risk — **it can move the problems without solving them**, or create new ones. If you don't know *where* you're losing people, redoing everything is shooting in the dark with an expensive rifle.

The healthy method is the other way round:

1. **Find the three real obstacles** with the 5 users (not with meetings).
2. **Fix them in a targeted way**: the extra field you move to after, the mute error that becomes speaking, the button hidden under the keyboard you bring back into view. Small, surgical interventions.
3. **Measure whether the flow closes more** (next paragraph).
4. **Only then** decide if you need more.

In the large majority of cases, fixing three specific obstacles moves the numbers more than a redesign from scratch — and at a fraction of the cost and the risk. The real redesign is needed when the problems aren't three points but **the whole scaffolding** is wrong: the flow conceived badly at the root, the technology underneath that doesn't hold, the thing born as a showcase and now squeezed to act as a product. In that case patching is putting patches on patches, and it's worth redoing — but it's a decision you take *after* understanding, with facts, that the three obstacles aren't enough. This distinction — when fixing is enough, when you need to rebuild — is the heart of the reasoning on [the showcase site versus the digital product]({{ '/en/blog/showcase-site-vs-digital-product/' | relative_url }}): not everything has to be redone, but what was born for another purpose sooner or later presents the bill.

## How you measure that the flow has closed

You can't improve what you don't measure, and "it seems better" isn't a measure. The flow is watched with few numbers, but you have to look at the right ones.

The number that counts more than all is the **completion rate of the final step**: of those who *start* the cart or the booking, how many *finish* it? That's where the loss hides, and that's where you see if your interventions worked. Not traffic, not visits: the percentage that gets to the end.

Right under, you need to know **at which step they get lost**. A flow has steps — choice, details, payment, confirmation. Measuring how many pass each step tells you *where* people fall: if 40% leave between "details" and "payment", the problem is in the form or in trust, not in the assortment. This is called looking at the funnel by steps, and it's the difference between knowing you lose and knowing *where* you lose.

Two warnings from someone who has seen these numbers lie:

- **Segment mobile and desktop.** A "decent" average completion rate can hide a disastrous mobile masked by a good desktop. Given that the majority is on mobile, the average fools you. Look at them separately.
- **Distrust the vanity metric.** Visits go up, the boss is happy, but if completion stays flat you're only paying more ads to fill a leaking bucket. The honest number is the one at the bottom of the funnel, not the one at the top.

Put together — completion rate, where they fall, split by device — these numbers turn UX from a matter of taste ("I like it better like this") into a matter of facts ("since we took those three fields off, on mobile it closes 14% more"). And it's only with facts that you stop arguing in meetings and start earning.

## Trust: why people freeze at payment (even with a perfect form)

There's an obstacle that no field optimisation solves, because it isn't technical: it's **trust**. You can have the slimmest form in the world, but if at the moment of putting the card the person feels a shiver of "and if these aren't serious?", they close. And this shiver you trigger, without noticing, with the wrong signals.

The most common trust killers, the ones I see knocking conversions down right at the last step:

- **The surprise on price.** The user arrives at payment and *there* discovers shipping, the service fee, VAT that wasn't shown. The surprise cost at the bottom of the funnel is among the very first causes of abandonment, because it isn't only a money issue: it's that the person feels **taken for a ride**, and whoever feels taken for a ride runs. The real total has to be shown **early**, not revealed at the end like a plot twist.
- **No seriousness signal where it's needed.** At the moment of the card, people unconsciously look for the signs that you're a real business: that the connection is secure, that there's a human contact if something goes wrong, that you can tell who's behind it. The absence of these signs doesn't reassure them, and in doubt the instinct is not to give the money.
- **The payment method that isn't there.** If the person only pays one way and you don't have that way, they don't "fall back": they leave. Offering the methods your clients actually use isn't a technical whim, it's taking away the last reason to flee.
- **No reassuring way out.** "And if I get it wrong?", "and if I want to cancel?". If it isn't clear what happens *after* — the confirmation, the possibility to change, who to talk to — uncertainty weighs as much as an extra field.

The point is that trust isn't built with a badge stuck at the bottom. It's built by **not betraying the user along the whole flow**: no surprises, honest price and early, a visible human contact, the payment they expect. It's the same pact that holds for any digital product — whoever arrives is lending you their attention and their data, and every small betrayal along the way reminds them they can leave. At payment, where past betrayals present the bill, this weighs double.

## What you find in your hands, concretely

Not code: **behaviours**. At the end of a job done like this you have:

- A booking or checkout flow that on the **phone** you fill with your thumb without cursing: large fields, right keyboards, button always in view.
- **Fewer fields before the yes**, the rest moved to after conversion, where it no longer does damage.
- **Errors that speak**: local, clear, that say what to do; and on system problems, the user's data never lost.
- A backend and a frontend that **explain themselves to each other**, so "date not available" becomes "choose another time" instead of a wall.
- Three or four **real numbers** you look at every week to know if you're closing more, split by mobile and desktop.

And, behind the scenes, the most precious thing: **you know why it converts**. It isn't luck or agency magic any more. It's a flow you've understood, measured and adjusted, and that you can keep improving because you know every step. All of this lives in the [web and digital product]({{ '/en/pillar/web-ux-product/' | relative_url }}) cluster, because a flow that closes isn't "a prettier page": it's a product that makes whoever arrives do a thing, and makes them do it all the way.

If you're paying for ads and you lose people at the last metre, the first step isn't spending more: it's **watching five real users** cross your flow and seeing where they stumble. Look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/) and we look at it together.

## It's for you if / it isn't for you if

**It's for you if:**
- you **spend on advertising** and you have the feeling (or the numbers) that lots of people arrive and few finish;
- a large part of your traffic is **from mobile** and you thought the form looking at the desktop;
- you get complaints like "the site doesn't work", "I couldn't book", "it gave me an error";
- you have a **cart or a booking** and you don't know at which step you lose people;
- your site and your ERP/payments were made by **different suppliers** who, when something doesn't add up, bounce the blame.

**It isn't for you if:**
- you don't have **traffic** yet: if three people a month arrive, the problem is earlier, it's getting found — checkout UX comes after;
- you sell **one thing only, in person, with a phone call**: here there isn't an online flow to close;
- your real problem is the **price or the offer**, not the flow: no UX saves a proposal that doesn't convince (and I tell you that honestly, before you spend fixing the wrong form).

## An honest timeline and what happens after

No "let's redo everything in two weeks". Here's how it actually goes, for a job on the flow.

**Days 1-5 — understand where you lose.** The 5 real users, the funnel looked at by steps, mobile and desktop separate. At the end you have the list of the three or four real obstacles, with facts, not with opinions. This is the most important phase and the cheapest.

**Weeks 2-4 — fix the obstacles.** Targeted interventions: fields moved, errors made speaking, mobile made usable, the backend-frontend seam fixed at the points where it refused in silence. Small interventions, large effect.

**Weeks 4-6 — measure and refine.** You look at whether completion goes up, where it goes up, and you refine. Here you also decide if the three obstacles were enough or if a deeper intervention is needed.

Realistic total for the "I fix, I don't redo" case: **four-six weeks**, with a first measurable effect already after the first interventions. A full redesign is another project, longer, that only makes sense *after* understanding that patching isn't enough.

**After** it isn't finished, and that's right: a sales flow is alive. You change the offer, you add a payment method, a new browser arrives, habits change. The numbers have to be watched continuously, and every so often you go back to the 5 users. A flow that converts today has to be kept in shape, like everything that touches money. And it's another reason why having **one hand** that knows the whole chain beats three suppliers: when something changes, you know who to call, and that person knows where to put their hands without doing the investigation from scratch.

## Frequently asked questions

**Wouldn't it be better to just raise the ads budget?**
Only if the flow already converts well. If you lose 80% at the last metre, more budget means paying to bring more people to a leaking funnel. First you plug the hole, then you open the tap: recovering conversion points is worth free traffic.

**How many fields should I have in the form?**
The minimum to trigger the "yes" now; everything else moved to after conversion. It isn't a fixed number: it's the discipline of making every field justify why you ask for it *at that moment*. The mandatory account before buying is almost always to take off.

**Do I have to redo the whole site?**
Almost never as a first move. First you find the three real obstacles with 5 users and you fix them in a targeted way: it usually moves the numbers more than a redesign, at a fraction of the cost. The redesign is only needed if the whole scaffolding is wrong, and you decide that *after* understanding.

**How do I know where I lose people?**
In two complementary ways: looking at the funnel by steps (how many pass each step, splitting mobile and desktop) and putting 5 real users in front of the flow thinking out loud. The numbers tell you *where*, the users tell you *why*.

**Are 5 users really enough?**
To *discover* the problems, yes: five new people find the large majority of obstacles, and you see them repeat already from the third. It isn't a statistical sample to measure percentages — that's what the funnel numbers do — but to understand *where people get stuck* five are more than enough.

**Why does my site say "error" and nobody understands why?**
Almost always because the backend refuses for a rule of its own (slot taken, code expired, item out of stock) but passes the frontend a generic error, and the frontend doesn't know how to translate it into an action. It's fixed by making the two sides talk — which takes a single direction, not a prettier frontend.

**How long does it take and how much does it cost?**
For the "I fix the obstacles" case, four-six weeks, with a first measurable effect soon and a cost much lower than a rebuild. A full redesign is another project, to evaluate only if the three obstacles aren't enough.

**Why don't I use a ready-made checkout/booking plugin?**
You can, and it gives you the 80%: the form and the steps. The 20% that decides whether the flow closes — *your* backend rules talking to *your* frontend, errors that become actions, the right fields at the right moment — is your specific logic, and it isn't in the plugin settings. It's exactly the piece to build.

## In one line

If you **pay for ads** and you lose people at the form, you don't need more traffic: you need a **flow that closes**. Most users are on the phone, the 12 fields are a wall, mute errors ("something went wrong") kill whoever *was* buying, and half the mysterious abandonments come from a backend that refuses and a frontend that doesn't explain. Five real users beat fifty internal opinions: find the three obstacles, fix them, measure completion (mobile and desktop separate). A redesign from scratch is almost never the first move.

If you're paying for ads and losing people at the last metre, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/): we start from five real users on your flow, not from a restyle quote.
