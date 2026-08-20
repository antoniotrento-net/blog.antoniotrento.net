---
lang: en
permalink: /en/blog/before-building-an-app/
alt_url: /it/blog/prima-di-sviluppare-un-app/
title: "You have an app idea and you're about to burn the budget on the wrong prototype: the 8 questions before you spend"
date: 2026-09-08 07:30:00 +0200
author: "Antonio Trento"
description: "Before you sign to build an app, there are 8 questions that are worth more than any quote. Answering them well saves you from burning the budget on the wrong prototype."
keywords: ["before building an app", "validate an app idea", "founder development budget", "questions for the developer", "avoid wasting the mvp"]
image: /assets/images/posts/prima-di-sviluppare-un-app.jpg
pillar: comprare-software
related: [/en/blog/90-day-software-mvp/, /en/blog/failed-ai-proof-of-concept/]
---

## The idea is not the perimeter

You have an app idea. You've been thinking about it for months, maybe you've already sketched it on a sheet, you talk about it with enthusiasm to friends, and now you're ready to spend: you look for a developer, you ask for quotes, you want to see it built. Stop a moment, because this is exactly where budgets burn.

The problem isn't your idea. The idea can even be excellent. The problem is that **the idea is not the perimeter of what has to be built.** In your head "an app that does X" is a clear, simple thing. In reality, "an app that does X" drags behind a hundred decisions you haven't taken yet — who uses it, how often, with which data, who pays, what happens when two people do the same thing together, what the admin sees, what happens if the connection drops. Each of these decisions changes *what* you build, *how much* it costs, and *how long* it takes. And if you don't take them first, the developer will take them on their own while building — guessing. And every wrong guess is time and money thrown at redoing.

The uncomfortable truth is this: most budgets burned in app development **don't die because of the code**. They die earlier, in the gap between "I have an idea" and "I know what has to be built". The founder jumps that gap — because they're impatient, because "the idea is clear, right?", because whoever sells them development has every interest in starting immediately to bill hours — and six months later they find themselves with a prototype that technically works but isn't the thing that was needed, and the money is gone.

This article is the conversation I'd want to have with you *before* you spend a euro. There are 8 questions. Answering them well costs you nothing and shows you the real perimeter of your idea — the one no quote shows you until it's too late. I ask them as someone who builds these things and has seen both endings: the one of whoever answered first, and the one of whoever paid to answer later.

## The 8 questions to answer before you spend

These aren't "technical" questions. They're questions *you* have to be able to answer about your idea. If you answer them well, you already have the perimeter in hand. If you notice you don't know how to answer, you've just discovered where the project risks exploding — and you discovered it for free, instead of at half budget.

**1. Who actually uses it, and how many are they?**
Not "everyone". Who, precisely? One person in the company, a hundred clients, thousands of anonymous users? An app used by three people you know is a different world from one used by ten thousand strangers: everything changes, from robustness to error handling to cost. "An app for everyone" is the answer that guarantees you build the wrong thing for anyone.

**2. How often do they use it, and in which moment?**
Something you open once a month is different from something you use a hundred times a day under pressure. Frequency and context of use — at the computer calmly, or on the phone standing up while doing something else — decide how the interface is made and what has to be extremely fast. An app used in a rush and badly designed for the rush, nobody uses, however rich it is.

**3. What data does it handle, and where does it come from?**
Every app lives on data. Where does it come from? The user types it by hand, it arrives from another system you already have, it generates itself? And above all: **how sensitive is it?** Personal data, payment data, health data radically change what you have to do to keep it safe and compliant. This question, skipped, is the one that presents you the most expensive bill afterwards.

**4. Is there a payment inside? Of what type?**
If the app collects — subscriptions, purchases, bookings with a deposit — you've opened a whole world: payment methods, invoicing, refunds, what happens if a payment fails halfway. Payment isn't "a pay button": it's one of the parts that costs and requires the most attention. Knowing *now* whether and how it's inside changes the perimeter enormously.

**5. Does it need to work offline?**
It looks like a technical detail, it's a founder question. If your app is used where there's no network — a warehouse, a building site, out and about — it has to work even without a connection and sync afterwards. It's one of the things that inflates complexity the most. If it *doesn't* need it, you've just simplified it a lot; if it needs it and you haven't said so, you've just made it explode.

**6. Are there different roles and permissions?**
Are all users equal or is there an administrator, a normal user, a guest, a supervisor who sees different things? Roles look trivial and they aren't: every role is a set of "this they can do, that they can't" that has to be thought and built. An app with five different roles is much more than an app with one role.

**7. What happens if it goes wrong? What's the real risk?**
If the app stops for an hour, what do you lose? An annoyance or a disaster? If it gets a calculation wrong, sends a wrong datum, loses information — what's the damage? The answer decides how much you have to invest in robustness. An app whose error costs little can afford to be simple; one whose error costs a lot cannot. Knowing the risk tells you *where* to really spend and where not.

**8. What do the others who solve the same problem do?**
Almost never is your idea the first in the world to touch that problem. Who already solves it, and how? Not to copy: to understand what people expect, what's already taken for granted, and — very important — **whether something already exists that you could buy instead of build.** This question can save you the entire budget, and whoever makes you ask it is working for you, not against their quote.

Answer these eight, and something happens: the idea in your head becomes a **perimeter on the table**. You see what's big and what's small, where the risks are, what costs. It's the first step of every healthy project, and it's what in [building an MVP in 90 days]({{ '/en/blog/90-day-software-mvp/' | relative_url }}) determines whether the 90 days are enough or the project goes off the road from the first month.

## What NOT to ask ChatGPT (the "easy" competitor)

There's a new temptation today, and it has to be faced because you fall for it easily: "I'll get this stuff told to me by the AI." You open ChatGPT, you describe the idea, and it spits out features, estimates, even pieces of code. It seems you can skip everything — the discovery, the developer, the cost. I have to be honest with you, because I use it and I know it: on this, AI is an excellent assistant and a terrible boss.

Here's what AI does **extremely well** and is worth using it for: being a sparring partner on ideas, helping you put your thoughts in order, generating a first list of things you hadn't thought of, explaining concepts you don't know. Use it to prepare for the 8 questions, so you don't arrive empty-handed. It's a multiplier of your head.

Here's what AI does **extremely badly**, and where it tricks you if you trust it:

- **It always gives you an answer, even when the right answer is "don't do it".** AI is compliant by construction: you ask it how to build your app and it explains how, it doesn't tell you "look, it already exists and costs a tenth" unless you press it. It has no interest in stopping you, and not even the guts to tell you no.
- **It brutally underestimates the real cost.** It shows you the easy 20% — the happy path, the basic feature — and hides the hard 80%: the errors, the edge cases, the permissions, the data security, the "what happens when two people...". It makes a large project look small, and with that impression you sign things that then explode.
- **It doesn't know your real context.** Your constraints, your real users, your dirty data, your company. It reasons on the average textbook case, and your case isn't the average case — the value is all in your details that the AI doesn't have.

The danger isn't using AI: it's **using it as a substitute for judgement** instead of as an assistant to judgement. A prototype generated in a hurry with AI, without having answered the 8 questions, is the fastest way in 2026 to burn time on the wrong perimeter — the modern version of the thrown-together prototype. I wrote about it starting from a case of a [failed artificial intelligence prototype]({{ '/en/blog/failed-ai-proof-of-concept/' | relative_url }}): the technology that generates fast creates the illusion that the hard part has disappeared, while the hard part — deciding *what* to build and why — is exactly the one nobody can do in your place.

## Figma is not a market test

Second delusion, equally common: paying for a nice clickable prototype — the screens drawn, coloured, that open one after another when you press — and believing you've "validated" the idea. It isn't so, and the difference costs you dear.

A drawn prototype is useful, for one thing only: **understanding how it will be made and aligning on what to build.** It serves you and the developer to see the screens before writing them, discuss the flows, avoid misunderstandings. It's an excellent *design* tool. But it's a drawing: there's nothing behind it, the data is fake, the buttons don't do anything real.

The problem is born when you confuse "it's pretty and looks real" with "the market wants it". A clickable prototype answers the question *"how is it made?"*. It doesn't answer at all the question that actually counts: *"will someone use it and pay for it?"*. They're two different questions, and the second you don't solve with any drawing, however careful.

How do you really test the market, before building? With real people, in ways that cost much less than an app:

- **Talk to whoever should use it**, and listen to the problems they have *now* — don't ask "do you like my idea?" (everyone says yes out of politeness), but understand whether the problem you solve is a problem they *feel* and for which they *already today* do something (or pay something).
- **Show the drawn prototype to real people** and watch them while they try: where they get lost, what they don't understand, what they ask. This the prototype can do, and it does it extremely well.
- **Look for the signal of real commitment**: someone who says "when it's ready I'll buy it", a list of interested people, a pre-order. Words are free; commitment is a signal.

The point is: spend *little* to validate the market, spend *a lot* to build. If you invert the order — build a lot to discover afterwards whether the market was there — that's where budgets burn. The drawn prototype sits in the middle: cheap, extremely useful for designing, useless as proof that someone will pay. Don't ask it to be what it isn't.

## "App" doesn't mean one thing: the question that moves the budget

When you say "I want to make an app", in your head there's probably the icon on the phone screen, the one you download from the store. But "app" is a word that covers very different things in cost and complexity, and choosing one without knowing it is one of the quietest ways to inflate the budget. It's worth understanding *before*, because the choice changes the quote enormously.

Simplifying, you have three roads:

- **A web application**: it opens from the browser, you don't download it from any store, it works on any device with internet. It's generally the cheapest and the fastest to evolve, because you update it for everyone in one shot. For a lot of ideas — especially those used at work, by an audience that has a computer or a phone with a connection — it's the right answer, and often the one the founder hadn't considered because they were fixated on the store icon.
- **An app you download from the store** (the "native" one): it lives on the phone, can use its special functions (camera, push notifications, location, real offline working) and gives the most fluid experience. But it costs more, requires going through the stores with their rules, and has to be maintained on different platforms. It makes sense when you *really need* what only it knows how to do.
- **A middle way**: solutions that with a single base cover both the web and the phone. A good compromise in many cases, with its limits.

The point isn't which is "better" in the abstract — there isn't one. The point is that **the choice depends on the answers to the 8 questions**, not on your imaginary. Do you need real offline in a warehouse with no network (question 5)? Then maybe you need what the downloadable app knows how to do. Do they use it at work in front of a computer (question 2)? Then a web application saves you a lot and evolves much faster. Whoever starts from the "icon on the store" by default, without doing this reasoning, risks paying double to have something that could have been simpler, cheaper and easier to improve. It's exactly the kind of decision a discovery puts on the table *before* you sign, instead of discovering it at half budget.

## How much to keep for after the MVP

A founder error I see ruining even good projects: **spending the whole budget to get to launch, and keeping nothing for afterwards.** It's like building a house and running out of money on moving day, before you can live in it.

Here's the truth that nobody who sells you development likes to tell you: **launch isn't the end, it's the beginning.** The day the app goes live is the day you discover what you'd got wrong — because finally there are real users who use it in ways you hadn't predicted. And what you discover has to be fixed, immediately, while interest is hot. If you've finished the money at launch, you're stuck: you have an app that *almost* works, users who bang into it, and nothing to fix it with. It's the worst moment to be left without budget.

The healthy rule is brutal but it saves projects: **don't spend everything to get to day one.** Keep a concrete reserve for the weeks and months *after* launch — to fix what emerges, for maintenance, for the second wave of improvements made on real data and not on hypotheses. An MVP is by definition the minimum version that stands up: it's born on purpose to learn from real users, and learning without budget to act on what you learn is useless.

How do you split it, in practice? Don't take a precise figure as gospel, but the principle is: think about what you need to build the MVP, and then make sure you still have a significant part *beyond* that figure for afterwards. If the total budget barely covers launch, you have a budget that's too small for the project you're imagining — better to know it now, and maybe start from a smaller perimeter that leaves you margin, rather than crash at the finish line. On what "afterwards" really means — maintenance, evolution, the cost of keeping a thing alive — it's worth understanding *before* you sign, and it's the theme of [what happens after go-live]({{ '/en/blog/90-day-software-mvp/' | relative_url }}).

## How to tell whether you have a developer in front of you or a slide salesperson

This is the part that protects your wallet, because when you look for whoever builds your app you'll meet two very different species, and at the start they look the same. Learning to tell them apart is worth more than any quote.

**The slide salesperson** makes you feel great. They love your idea, they find it brilliant, they show you glossy presentations, they talk about how beautiful it will be, they project success. They always say yes. To everything. Every feature you name, "sure, it can be done, no problem". They give you a precise, optimistic estimate at the first meeting, without having understood anything about the perimeter. They rush you to sign. And above all: **they never ask you uncomfortable questions.**

**The real developer** — the one who suits you — does the opposite, and at the start it's less pleasant. They ask you the hard questions (those eight, and others). They say "it depends" when the answer is it depends, instead of inventing a certainty. They warn you about the risks instead of hiding them. Sometimes they tell you things you don't want to hear — "this part is more complex than you imagine", "I'd leave this feature for later", or even "maybe you don't need to build, it already exists". And if they give you an estimate, they give it to you *after* understanding the perimeter, not before.

The signals to recognise the slide salesperson, concrete:

- **They always say yes.** No feature is a problem, nothing worries them. Reality is made of trade-offs; whoever doesn't name any either hasn't understood or isn't telling you.
- **A precise estimate too early.** They fire a figure and a date at the first conversation, with no discovery. It's impossible to estimate seriously without having understood the perimeter — so either they're guessing, or they're anchoring low to get you to sign, knowing they'll inflate later.
- **They don't ask you questions.** If in an hour of conversation they haven't asked you anything uncomfortable about your users, your data, your risks, they aren't thinking about your project: they're thinking about closing the contract.
- **They sell the fashionable technology, not the solution.** They fill up with buzzwords and trends instead of talking about *your* problem. If the "how" arrives before the "what" and the "why", you're buying smoke.
- **They put you in a hurry.** Artificial urgency ("offer valid until…", "we have to start immediately") is a sales technique, not a way of working well.

I tell you all this knowing I'm also describing how *I* should behave with you — and that's intended. Someone who builds for real isn't afraid to tell you "don't start" or "you need less than you think", because their real interest is that your project goes well, not that you sign today. That's the whole point of an honest discovery, and it's the heart of how I approach [buying custom software]({{ '/en/pillar/buying-custom-software/' | relative_url }}): trust is built by asking the right questions, not by promising everything.

## The deliverable of a discovery (and it stays yours)

At this point the right question is: "fine, but then how do you start *well*?". The answer is: you start with a **discovery** — a short phase, paid but inexpensive, in which before building anything you answer the questions and define the real perimeter. And the crucial point, the one you have to demand, is: **from a discovery a concrete deliverable comes out, and that deliverable is yours.**

What you have to have in your hands after a discovery done well:

- **The written perimeter**: what the app does and what it does *not* do (the boundaries are as important as the content), who uses it, what the main flows are. In black and white, not spoken.
- **The answers to the 8 questions**, explicit: who, frequency, data, payments, offline, roles, risks, existing alternatives. Documented, so they aren't rediscussed every month.
- **The decisions taken and the alternatives discarded**, with the why. In six months you'll remember *why* you'd decided that way, instead of redoing the same discussions.
- **A serious estimate** — at this point possible, because the perimeter exists — with the phases and what to keep for after the MVP.
- **A drawn prototype**, if needed, of the main flows, to align everyone on how it's made.

And here the non-negotiable thing: **this deliverable is your property.** It isn't "internal material" of whoever prepares it for you. It's yours, and if after the discovery you decide to have the app built by someone else — or not to build it at all — you take it with you and you use it. A discovery done honestly gives you value *even if you don't continue* with whoever did it: you have the perimeter, the answers, the estimate, and you can go to anyone with clear ideas. Whoever ties the discovery to themselves (or leaves you nothing concrete in hand) is tying you to themselves, not serving you.

This, for me, is the honesty test of whoever proposes to work together: **they give you something that stays yours, useful even if you then don't choose me.** It's the opposite of the slide salesperson, who keeps you attached with vagueness. If someone proposes a discovery whose result is yours and serves you anyway, you've found someone who thinks as your ally.

## When NOT to start

I close with the part that nobody who sells you development will ever tell you, and which instead is the most precious: **the times when the right answer is not to build.** Because sometimes it is, and telling you so is the sign that whoever you have in front of you is working for you.

Don't start — or stop and rethink — if:

- **You don't know how to answer who will use it and why they'd pay.** If the first two questions are fog, you don't have a project: you have an intuition to validate *first*, talking to people, not building.
- **Something already exists that does what you need, and it's fine for you.** If there's a ready-made product that solves your problem at a tenth of the cost, buying it is the intelligent choice. Building custom makes sense for the 20% of *your* needs that the ready-made doesn't cover — not to redo from scratch the 80% that already exists and works. Honesty: many "app ideas" are already solved by a subscription of a few tens of euro a month.
- **The budget barely covers launch.** If you have no margin for afterwards, either you start from a smaller perimeter, or you wait until you have the reserve. Starting undercapitalised is the surest way to waste what you spend.
- **You're building out of conviction, not for a problem felt by others.** "I know it's needed" with no signal from the market is the classic premise of the product nobody uses. Look for the signal before, not after.
- **You don't have the time to follow it.** An app isn't an object you buy and forget: it has to be followed, decided, corrected. If you don't have the head to stay on it in the months after launch, even the best development goes dark.

Saying "don't start" when it's right isn't losing a client: it's being the one you come back to the next time, and the one you recommend to others. If you have an idea and you want to understand, before spending, whether it stands up and what the real perimeter is, it's exactly from here that you start — with the questions, not with the quote.

## It's for you if / it isn't for you if

**It's for you if:** you have an app idea and you're about to spend; you haven't yet answered the 8 questions on paper (who uses it, data, payments, offline, roles, risk); you want a short discovery whose deliverable stays yours even if you then choose someone else; you need to tell a developer from a slide salesperson before you sign.

**It isn't for you if:** you already know who uses it and why they'd pay, with facts not hunches, and the perimeter is written (then you've already done the discovery yourself, and you can start building); a ready-made product already does what you need and it's fine; the budget barely covers launch and you have no reserve for afterwards; you're building because "I know it's needed" with no signal from the market.

## Frequently asked questions

**How much does a discovery cost compared to building immediately?**
A fraction. It's a short phase whose purpose is to define the perimeter and answer the questions, not to build. It costs little precisely because it stops you spending a lot on the wrong perimeter — it's the cheapest insurance on the project.

**But if I already have the ideas extremely clear, can't I skip the discovery?**
Answer the 8 questions yourself. If you know them all, with data and not with hunches, you've already done the discovery on your own: excellent, you can start building. If you notice that on three of those questions you're going by instinct, you've just discovered why you need the discovery.

**Can't I make the prototype with AI and bring it to you already done?**
Bring me whatever the AI helped you put in order, it's useful as a starting point. But a prototype generated in a hurry isn't a validated perimeter: the AI shows you the easy and hides the hard, and it doesn't know your real context. Use it to prepare, not to decide.

**Does the drawn prototype tell me if the idea will work?**
It tells you *how it's made* and it's extremely useful to align and design. It doesn't tell you if the market wants it: that you discover by talking to real people and looking for signals of real commitment, things that cost much less than an app.

**How much budget should I keep for after launch?**
A significant part, beyond what you need to build the MVP. Launch is the beginning, not the end: it's when you discover what to fix with real users. If the budget barely covers day one, it's better to start from a smaller perimeter that leaves you margin.

**How do I trust whoever builds?**
Look at whether they ask you the uncomfortable questions instead of always saying yes, whether they give you an estimate *after* understanding the perimeter and not before, whether they warn you about the risks, and whether the result of the discovery stays yours even if you then choose someone else. Whoever keeps you attached with vagueness and hurry is a slide salesperson.

**And if from the discovery it comes out that it isn't worth building?**
It's one of the possible and useful outcomes: you saved yourself burning the budget. Maybe a product already exists that fits, maybe the perimeter has to be rethought, maybe you need to validate with the market first. Discovering it with a small spend is a victory, not a defeat.

**Can I use the discovery material with another developer?**
Yes, it has to stay yours: perimeter, answers, decisions, estimate. An honest discovery gives you value even if you don't continue with whoever did it. If someone denies you that or leaves you nothing concrete in hand, they're tying you to themselves instead of serving you.

## In one line

An **app idea is not the perimeter**: budgets don't die because of the code, they die in the gap between "I have an idea" and "I know what to build". Answer 8 questions before you spend (who uses it, how often, data, payments, offline, roles, risk, what already exists), don't let ChatGPT decide for you, don't confuse a Figma prototype with a market test, and don't spend the whole budget getting to launch. A discovery done well leaves you a deliverable that's yours — useful even if you then don't build, or you build with someone else.

If you have an idea and you want to understand, before spending, whether it stands up and what the real perimeter is, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/): we start from the questions, not from the quote, including to tell you honestly whether and how it makes sense to start.
