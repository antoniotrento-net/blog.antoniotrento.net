---
lang: en
permalink: /en/blog/how-to-answer-software-rfi/
alt_url: /it/blog/rfi-software-come-rispondere/
title: "The big client's RFI: what your software actually has to do (and how not to sign a 40-page suicide)"
date: 2026-09-14 07:30:00 +0200
author: "Antonio Trento"
description: "A large client sends you 40 pages of requirements and asks you to answer. Between enthusiastic yeses and cautious nos sits the difference between winning a deal and signing a disaster. How you read an RFI like an adult."
keywords: ["how to answer software rfi", "software supply tender", "enterprise client requirements", "scope creep", "development contract"]
image: /assets/images/posts/rfi-software-come-rispondere.jpg
pillar: comprare-software
related: [/en/blog/what-custom-software-includes/, /en/blog/before-building-an-app/]
---

## The RFI written to scare you

The email you've been waiting months for arrives: the big client, the one who could change your year, sends you the RFI — the document asking whether your software can do what they need. You open it. Forty pages. Hundreds of requirements, tables to fill with "yes/no/partial", questions on security, integrations, certifications, timelines. You read it and a mix of excitement and panic hits: *"if I say yes to everything maybe I win, but then how do I deliver?"*.

Here's the first thing to know, because it frees you: **a 40-page RFI is, for the most part, written to scare you** — or rather, to filter. It is not a precise description of what the client will actually use. It is a defensive document, often copied from a template, inflated by whoever wrote it to cover themselves ("put everything in, so if something is missing later it isn't our fault"), full of requirements nobody will ever use and of asks put there to see who backs out. Whoever reads it as if every line were a life-or-death obligation either says no to everything and excludes themselves, or says yes to everything and signs a suicide.

The skill is not answering "yes" to as many rows as possible. It is **reading the RFI like an adult**: understanding what is a real requirement, what is a wish, what is pure theatre; answering honestly where you are strong and with caution where you are not; and — the thing almost nobody does — understanding when that contract, as written, is a trap you *don't want* to fall into, however big the client is. Because a deal won on the wrong terms is not a victory: it is the start of a year of hell that eats your margin, your reputation and your health.

This article is for you who answer these tenders — freelancer, small software house, supplier — and find yourself in front of those bricks. I'll give you a way to read them with a clear head: separate the wheat from the chaff, answer without promising the impossible, break the scope so it doesn't devour you, and recognise when walking away is the smartest move. Not to lose tenders: to **win the right ones on the right terms**, and escape the wrong ones.

## What's a requirement, what's a wish, what's theatre

The first operation, in front of an RFI, is a **classification**. Every line of that document belongs to one of three categories, and treating them all the same is the mistake that gets you. Learn to tell them apart and half the panic disappears.

- **The real requirement.** It's the thing the client will actually use, every day, and without which the project makes no sense for them. Usually a few lines, the heart of the need. On these you have to be solid: they are the reason the tender exists. If you can't do *these*, it isn't the tender for you, and there's no point going on.
- **The wish.** It's the thing the client "would like to have", the nice-to-have. Maybe they put it in because a competing supplier has it, or because "you never know". It isn't vital: if it isn't there, the project still stands. On these you can answer with graded honesty ("this yes, this can be added, this isn't planned") without it being a no to the tender.
- **The theatre.** It's the line put there to fill space, to cover themselves, or copied from a template nobody cleaned up. Generic requirements, asks out of all proportion to the project, things even the client doesn't know why they're there. Nobody will ever use them. Theatre is not to be taken literally: it is to be handled with honest, reasonable answers, not with real commitments on things that don't exist in practice.

How do you tell them apart, if the client doesn't tell you? By asking, and by watching. **The questions you ask on the RFI are half the work**: asking "this requirement — in which real usage scenario do you need it?" does two things at once — it tells you whether it's a requirement or theatre, and it shows the client you are reasoning about their real need instead of just ticking boxes. A serious client appreciates it; and their answers reveal what actually counts. If you can't ask questions (closed tender, no contact), use common sense: what is repeated, detailed and coherent with the purpose is probably real; what is generic, disproportionate and isolated is probably theatre.

This reading is the same skill, seen from the supplier's side, that the buyer needs when they have to [understand what's really in a quote]({{ '/en/blog/what-custom-software-includes/' | relative_url }}): knowing how to tell substance from form. Only here the stakes, for you, are not committing to 400 lines when the real project is worth 40.

## Security, backups, roles: answering like an adult without overclaiming

There's a section that scares more than any other in big-client RFIs: the one on **security, backups, data protection, access management**. Pages of technical questions that look written to exclude anyone who isn't a multinational. Here people make two opposite mistakes, both fatal: the **overclaim** (saying yes to everything, promising bank-grade security you don't have) and the **panic** (getting scared and walking away even when the asks are reasonable and within your reach).

The adult path sits in the middle, and it is made of **technical honesty**:

- **On backups and continuity:** these are serious, legitimate things, and largely within reach of a competent supplier. The client wants to know that if something goes wrong their data isn't lost and the service comes back. Answer with what you *actually do* — regular copies, restore capability, what happens if something falls over — without inflating. A concrete, true answer is worth more than a loud promise.
- **On roles and permissions:** who sees what, who can do what. It's a healthy, reasonable ask, the bread of every serious system. Answer by showing you know how to manage differentiated access, without inventing certification levels you don't have.
- **On security in general:** distinguish what is **standard and within your reach** (protecting data, encrypting where it matters, managing access in a sensible way) from what requires **formal certifications or heavy infrastructure** you may not have. On the first group, answer with solidity. On the second, be honest: "we don't have this formal certification; here is what we guarantee in concrete terms". Honesty here doesn't lose you points with serious clients: it gains you some, because whoever is evaluating has seen plenty of suppliers promise the moon and then not deliver.

The golden rule is: **don't promise a security you can't guarantee.** An overclaim on security is the kind of lie that blows up in your hands at the worst moment — an incident, an audit — and at that point you've lost the client *and* the reputation. Better a "no, we don't do this, we do this other thing" said beforehand, than a "yes" that won't hold. Answering like an adult means exactly this: telling the truth about what you do and what you don't, with the confidence of someone who knows their trade and doesn't need to inflate it.

## What NOT to promise: the AI, infinite integrations, the dates

There are three categories of promises that, in an RFI, are the most tempting and the most lethal. They're the ones where "saying yes" makes you look extremely strong on paper and sets up the disaster in reality. Learn to treat them with extreme caution.

- **The AI that works miracles.** In today's RFIs there's always the "artificial intelligence capabilities" section, and the temptation to promise that "the AI will do everything automatically, decide, predict". Don't. AI *assists, prepares, finds* — it does not decide the things that matter on its own, and it is not 100% reliable on numbers and critical decisions. Promising an omnipotent AI means committing to something you then don't deliver, with a big client holding you under contract. Promise what AI *actually* does — it speeds things up, it suggests, with the person staying at the wheel on decisions — and that's already a lot. Whoever promises the magic signs their own sentence, as I explain talking about the [LLM-based product versus the chatbot that promises everything]({{ '/en/blog/llm-product-vs-chatbot/' | relative_url }}).
- **Infinite integrations.** "Do you integrate with all our systems?" — and the temptation is to say "yes, with everything". Every integration with an external system is however work that depends on *that* system, on its documentation, on its cooperation, on its changes. Promising infinite integrations means committing to work you don't control. Answer by distinguishing: "with these standard systems, yes; with your specific systems, it has to be assessed case by case what they expose". An integration promised sight unseen is a black hole of hours.
- **The dates.** The timelines section is where the most spectacular suicides get signed. "Do you deliver by X?" — and to win, you say yes to an impossible date. Then the date isn't met, penalties kick in, and the project is born already late and already at a loss. Don't promise dates you can't keep: give realistic timelines, maybe in phases, and explain *what they depend on*. A serious client prefers a true date to a promise that will break — and whoever only accepts the impossible promise is a client you don't want to work with.

The common thread: **every "yes" in an RFI is a contractual commitment, not a commercial courtesy.** What you write in there, if you win, becomes what you have to deliver, and the big client has the lawyers to remind you. The discipline of *not promising* what you can't keep is not commercial weakness: it is what distinguishes whoever delivers from whoever ends up in court. It's the same clarity on the perimeter you need [before you even start building anything]({{ '/en/blog/before-building-an-app/' | relative_url }}): knowing what you are actually committing to do.

## How to break the scope so it doesn't eat you

Here's the strategic move that turns an RFI from a trap into a manageable opportunity: **break the scope.** A big client often describes in the RFI the *complete final system* — everything they'd like, in the end, in two years. Committing to deliver all of it in one block is the suicide: too big, too risky, too many things that will change along the way. The intelligent answer isn't "I'll do everything", it's "**we do it like this, in pieces**".

Breaking the scope means proposing to build the system **in phases**, each with value of its own:

- **First phase: the heart.** Those few real requirements, the core without which the project makes no sense. Small, doable, deliverable on a certain timeline. The client sees something that works soon, you commit to something controllable.
- **Later phases: the rest, one piece at a time.** The wishes, the integrations, the extra functions — added afterwards, when the base is solid and you've learned from real use. Each phase is a separate commitment, with its own perimeter and its own timelines.

Why this is powerful for *both*:

- **For you:** you don't commit in one block to a two-year monster. Each phase is controllable, the risk is broken, and if something changes (it always does) it doesn't blow up everything. You reduce *scope creep* — that continuous swelling of the project that eats the margin — because every addition is a new phase, negotiated, not a "while we're at it" for free.
- **For the client:** they see results soon instead of waiting two years for a big bang that maybe never arrives. It reduces their risk: if the first phase goes well, they trust you for the next ones; if it doesn't, they haven't thrown the whole budget in at once.

Breaking the scope is also the elegant way to answer theatre-requirements and wishes: you don't refuse them ("no, we don't do that") nor promise them in a block ("yes, everything at once"), you **place them in the right phases** ("the heart now, this in phase two, that other one to be assessed when we get there"). You turn a terrifying list into a reasonable path. This is the logic of starting from a core and growing in phases that sits behind every healthy project, like [building an MVP before everything else]({{ '/en/blog/90-day-software-mvp/' | relative_url }}): the big bang is the best way to fail at scale, the phases are the way to win small and then win big.

## Who should write the answer (not just sales)

The mistake that sinks many RFI answers: **only sales writes it.** Sales is inclined to say yes — their job is to excite and close. But if the only person answering a document full of technical commitments is whoever wants to win the tender and not whoever will have to *deliver*, the result is a pile of "yeses" that someone else will then have to keep, and they won't manage it.

A well-made RFI answer is written by **at least two heads together**:

- **Sales**, who knows the client, understands what they really want behind the lines, knows how to position the answer and holds the relationship.
- **Whoever builds**, meaning whoever will actually have to do the work, who knows what is doable, what it costs, what is a requirement and what is theatre, and — above all — where the technical traps are that you shouldn't commit to.

Sales alone signs promises the technician can't keep. The technician alone writes a cautious, dry answer that doesn't win tenders. Together, they produce an answer that is **ambitious where it can be and honest where it must be** — that wins the right tender without signing the suicide. This is the point where having a **single hand** that understands data and backend and frontend and AI becomes a huge advantage: whoever answers the RFI *really* knows what every "yes" entails, because they know how to do that work, and they don't have to trust third-party estimates or promise things they'll later discover are impossible. There isn't the salesperson who promises and the technician who then despairs: there's a head that knows what it's signing.

And there's a third eye that you need on the more committing answers: someone who reads the **contract and the terms**, not only the technical requirements. Because — and this is the next point — the worst traps in an RFI often aren't in the requirements, but in the clauses.

## Answering costs: qualify before you invest days

There's a cost almost nobody accounts for: **answering a serious RFI costs.** Reading 40 pages, understanding them, asking the questions, classifying the requirements, breaking the scope, writing a reasoned answer with two heads (sales and technical), getting the clauses checked — that's days of work from your best people. And those are days **taken away** from work that invoices, or from other clients. If you spend three days answering a tender you had no chance of winning, those three days are money thrown away — and if you do it on every tender that comes by, the year becomes a colander of empty answers.

That's why the first question in front of an RFI isn't "how do I answer?", but "**is it worth answering?**". An honest qualification, done *before* investing the days, saves you a lot of wasted effort. A few decisive questions:

- **Is the heart of the project in my wheelhouse?** If the real requirements are things you do well, it makes sense to go on. If the core is out of reach, stop here: no beautiful answer compensates for a heart you can't deliver.
- **Do I have a real chance, or am I the decoy supplier?** Sometimes a tender already has a designated winner and you're only there to make up the numbers and legitimise the procedure. Signals: the tender looks written to measure for a specific competitor, the time to answer is absurdly short, nobody answers your questions. If you're the spare horse for show, you're giving days away.
- **Do the commercial terms make sense for me?** If even winning, the margin would be laughable or negative given how it's set up, the victory is a loss. Better to find that out before writing the answer than after signing.
- **Can I afford to win it?** If my structure can't hold that job without exploding, maybe it isn't the right tender regardless of how good I am at answering.

Qualifying *beforehand* isn't laziness: it's respect for your time. A supplier who answers a few **right** tenders, with careful answers, wins more than one who answers everything in a rush — and they put in less effort. The discipline of saying "I'm not answering this one" is the same, upstream, as the "I'm walking away from this one" we talk about in a moment: both come from seeing the hidden cost that others don't see.

## The red flags in the tender

Before you fall in love with a big job, learn to read the **danger signals** — the ones that tell you this tender, as it's set up, is a trap regardless of how well you can do the work. The most common red flags:

- **Disproportionate penalties.** Clauses that punish you in an exaggerated way for every delay or problem, maybe on dates they themselves make impossible by not providing on time what they need to provide. A disproportionate penalty turns a small hitch into an economic disaster.
- **Undefined scope but a fixed price.** They ask you for a locked price on a vague perimeter or "everything that will be needed". It's the perfect recipe for scope creep at your expense: you sign a price, and then every "but we also needed this" is free for them and a loss for you.
- **All the responsibility on one side.** Contracts where every risk is yours and every protection is theirs: if something goes wrong because of *them* (they don't give you the accesses, they change their mind, they delay decisions), the fault remains yours anyway. A healthy relationship has distributed responsibilities.
- **No contact, no questions allowed.** If you can't ask questions on the RFI, you can't tell a requirement from theatre, and you're answering blind. A tender that forbids you from understanding what's actually needed is a tender that puts you in a position to get it wrong.
- **The client who has already burned through three suppliers.** If you discover that before you others have come through (and fled), the cause is rarely that they were all incompetent: more often the client is impossible, or the RFI is badly written, or the terms are poisoned. The story repeats.

None of these, on its own, is necessarily a no. But they are the points on which to **negotiate before you sign**: a penalty can be resized, a scope can be defined, responsibilities can be balanced. If the client is willing to discuss them, that's a good sign. If they're non-negotiable and all against you, you have the answer — and that's the theme of the last, crucial point.

## When walking away is winning

The most counterintuitive and most valuable thing I can tell you: **sometimes the winning move is not to take part.** Walking away from a wrong tender isn't losing: it's winning, because you avoid a disaster that would have cost you much more than the missed job.

There are situations where walking away is the clear-headed choice:

- **When the heart of the project isn't in your wheelhouse.** If the *real* requirements (not the theatre) are things you don't do well, forcing it to win means committing to deliver something you don't know how to deliver. Better a clean no now than a humiliation later. Honesty with yourself before honesty with the client.
- **When the terms are poisoned and non-negotiable.** If the red flags above are all there and the client doesn't negotiate — absurd penalties, undefined scope at a fixed price, every risk on you — that job is a loss dressed up as a victory. You win it, and then you lose money, nights and reputation for a year.
- **When the client wants the magic.** If from the RFI and the conversations you understand that the client expects the impossible — omnipotent AI, delivery on unreal timelines, infinite integrations for free — and there's no way to bring them back to reality, that's a relationship destined to end badly. Better not to start it.
- **When winning would blow up everything else.** A job too big for your structure, that to serve it you'd have to neglect every other client and stress the team until it breaks, can kill you with success. A "yes" you can't sustain is worse than a "no".

Walking away with a clear head requires something few people have: the **discipline to say no to money that looks like a lot**, because you see the hidden cost. It's the same discipline I recommend to the buyer when I tell them that sometimes the right choice is not to build — only seen from the other side. The supplier who knows how to walk away from the wrong tenders is the one who survives and thrives, because they don't let themselves be killed by a poisoned victory. The one who says yes to everything, sooner or later, signs the job that sinks them.

If you're in front of a big RFI and you want to read it with a clear head — separate the real from the theatre, understand where to commit and where not to, break the scope and recognise the traps — that's exactly the kind of reading I do, because I know both sides: the one who builds and the one who buys. [See how I work]({{ site.main_site }}/portfolio/) or [write to me]({{ site.main_site }}/contatti/) and we look at it together, even just to decide whether it's worth taking part. All of this lives in the cluster [buying (and selling) custom software]({{ '/en/pillar/buying-custom-software/' | relative_url }}): from both sides of the table, clarity on the perimeter is what separates the projects that succeed from the ones that sink.

## This is for you if / this isn't for you if

**This is for you if:**
- **you answer tenders or RFIs** from big clients and find yourself in front of bricks of requirements that scare you;
- you have the temptation to **say yes to everything** to win, and the fear of signing something you can't keep;
- you've already **won a job and regretted it**, eaten by scope creep and penalties;
- you want to learn to **break the scope** and to negotiate the terms before you sign;
- you want the clarity to understand **when to walk away** instead of chasing every tender.

**This isn't for you if:**
- you don't deal with **structured clients** who run formal tenders: if you work with small clients by word of mouth, the RFI isn't your world;
- your problem is **finding clients**, not answering their tenders: that comes first;
- you're looking for the trick to **win every tender**: here the message is the opposite — win the right ones and escape the wrong ones, not win them all.

## 8 questions from someone about to answer an RFI

**1. Do I have to answer "yes" to as many requirements as possible to win?**
No: every "yes" is a contractual commitment you'll have to keep. Winning by saying yes to everything means signing things you won't deliver, with penalties and lawsuits to follow. Answer with graded honesty, strong where you're strong and cautious where you're not.

**2. How do I tell a real requirement from theatre?**
The real requirement is what the client will use every day and without which the project makes no sense — usually a few lines. Theatre is generic, disproportionate, isolated, often copied from a template. The questions you ask on the RFI ("in which real use do you need this?") are the best way to tell them apart.

**3. What do I answer to questions on security and backups?**
Like an adult: what you actually do, without inflating. Distinguish what is standard and within your reach (protecting data, managing access, doing backups and restores) from what requires formal certifications you may not have — and on that be honest. An overclaim on security blows up in your hands at the first audit.

**4. What should I never promise?**
Omnipotent AI (AI assists, it doesn't decide on its own), infinite integrations (they depend on systems you don't control), and impossible dates (penalties on delays sink projects). Promise what you actually do: that's already enough to win the right tenders.

**5. How do I avoid scope creep?**
By breaking the scope into phases: first the heart (few real requirements, deliverable soon), then the rest one piece at a time, each phase with its own perimeter and timelines. That way every addition is a negotiated phase, not a "while we're at it" for free that eats your margin.

**6. Who should write the answer?**
Not only sales, who tend to say yes. You also need whoever builds, who knows what's doable and where the traps are — plus an eye on the contract and the clauses. Sales alone signs impossible promises; the technician alone writes answers that don't win. Together it works.

**7. What are the signals that a tender is a trap?**
Disproportionate penalties, undefined scope at a fixed price, all the responsibilities on you, no possibility of asking questions, and a client who has already burned through other suppliers. None is an automatic no: they're the points to negotiate before you sign. If they're non-negotiable and all against you, it's a no.

**8. When does it make sense to walk away?**
When the heart of the project isn't in your wheelhouse, when the terms are poisoned and the client doesn't negotiate, when they demand the magic, or when the job is too big and would blow up everything else. Walking away from a wrong tender isn't losing: it's avoiding a disaster that costs more than the job. Whoever says yes to everything, sooner or later, signs the one that sinks them.
