---
lang: en
permalink: /en/blog/failed-ai-proof-of-concept/
alt_url: /it/blog/poc-intelligenza-artificiale-fallito/
title: "You spent tens of thousands on an AI PoC that ended in a drawer. How (not) to do it again"
date: 2026-08-23 07:30:00 +0200
author: "Antonio Trento"
description: "The €40,000 workshop, the demo that stunned, and then a notebook nobody opens any more. Why AI PoCs die, how to evaluate a second attempt without burning more budget, and the clauses to demand in the contract."
keywords: ["failed ai proof of concept", "ai project in a drawer", "proof of concept vs production", "wasted ai budget", "ai agent go live"]
image: /assets/images/posts/poc-intelligenza-artificiale-fallito.jpg
pillar: comprare-software
related: [/en/blog/launch-white-label-ai-product/, /en/blog/hiring-a-data-analyst-is-not-enough/]
---

## The €40,000 workshop and the notebook nobody opens

You've been through it, or you know someone who has. A company, or a consultant, arrived with a convincing speech about artificial intelligence. Workshop, analysis, a proof of concept. You signed for a few tens of thousands of euro. After a few weeks they showed you a demo that worked: it did the promised thing, everyone said «wow», leadership was satisfied. And then? Then nothing. That PoC ended in a drawer — or rather, in a technical notebook on a computer, that nobody opens any more. Nothing changed in the company, except the budget, which disappeared.

This is the fate of the majority of **AI proofs of concept**: they're born to "prove it can be done", they prove it, and they die there. Because "it can be done" and "we actually use it, every day, in production" are two different planets, and between the two sits all the real work — the work the PoC, by definition, skips. The result is that you're left with proof that a thing is possible, and zero things that work. It's **wasted AI budget**, and it leaves you with a bitter taste and the temptation to conclude that "AI isn't for us".

This article is for anyone who got burned by an **AI project that ended in a drawer** and doesn't want to repeat the error — nor throw away the idea that AI can actually help. Let's see why PoCs die (with a precise list of causes of death), how you evaluate a second attempt without burning more budget, what has to be true *before* you write a line of code, and the clauses to demand in a contract so this time it ends in production and not in a drawer.

## PoC vs product: the planet the demo doesn't show you

The root of the problem is a confusion, often in good faith: you mistake a **PoC for a product**. A proof of concept proves that a certain thing is technically possible — that the model, on a clean example, produces the right result. It's useful to remove a doubt. But a product is something else: it's something real people use, on their real data, every day, inside their hours and their processes. And between the PoC and the product sits everything the demo doesn't show.

The demo works because it runs in ideal conditions: a clean datum, chosen on purpose, a normal case, no real user, no error, no load. The product lives in the real world, where data is dirty, cases are strange, users do unexpected things, things go wrong at three in the morning, and volumes put everything under pressure. It's exactly the same distinction that holds when you want to [turn an AI demo into a sellable product]({{ '/en/blog/launch-white-label-ai-product/' | relative_url }}): the «wow» was the tip, underneath is the iceberg. The PoC shows you the tip and makes you believe you've seen the mountain.

What's missing, concretely, between the PoC and the product? **Users** (who uses it, how they get in, what they can do). **Permissions** (who sees what). **Error handling** (what happens when the model is wrong or doesn't know — and it happens). **Hours** and reliability (it works always, not "when the technician launches it"). Integration with **real data** and existing systems. **Cost control** when volumes go up. These are all pieces the PoC skips because "they're only there to prove it can be done" — and they are, as it happens, most of the work and the value.

## Who sold you the demo: the model, not the process

It's worth understanding *why* they sold you a PoC they knew (or should have known) would end in a drawer. It isn't always bad faith; often it's that whoever sold it to you knows how to do **the model, not the process**. They're good with AI technology — the models, the prompts, the algorithms — but they've never put software into production inside a real company, with its users, its dirty data, its operations. So they sell you what they know how to do (a technical demonstration) calling it by the name of what you need (a solution).

The signal you recognise with hindsight: they talked a lot about *technology* (which model, how advanced it is, what it can do) and very little about your *process* (who will use it on Tuesday morning, how it integrates with what you have, what happens when it gets it wrong). A project that ends in production starts from the process and uses technology as a means; a drawer PoC starts from the technology and never arrives at the process. It's the same reason [hiring a data analyst isn't enough to fix the data]({{ '/en/blog/hiring-a-data-analyst-is-not-enough/' | relative_url }}): isolated technical competence, without the system and the process around it, doesn't produce results that stay.

## The causes of death of a PoC (the list)

If you look at PoCs that die, the causes repeat. Keep them in mind, because they're also the checklist of what to avoid on the second attempt:

- **Born to stun, not to be used.** The goal was the demo to leadership, not the operator who uses it every day. Mission accomplished (the «wow»), and end.
- **Fake or hand-cleaned data.** It worked on data chosen for the demo; on real data, dirty and full of exceptions, it jams. The jump to real data was never made.
- **No real user involved.** Built without whoever will use it, so unstuck from how work actually happens. When it was put in an operator's hands, they didn't recognise themselves in it.
- **No error handling.** The model sometimes gets it wrong or doesn't know; the PoC didn't foresee what to do in those cases, so in production it was unreliable and trust collapsed at the first visible error.
- **No integration.** It ran on the side, isolated; to use it for real you had to connect it to company systems, and that work wasn't planned or budgeted.
- **No internal owner.** Once the consultant left, nobody in the company owned it, maintained it, evolved it. It died of abandonment.
- **Costs not planned at regime.** In demo it cost little; at real volumes the model or infrastructure cost was unsustainable, and they stopped.

If your PoC died, you almost certainly recognise two or three of these causes. It isn't bad luck: it's that the project was structured to demonstrate, not to last.

## The bill: what you actually spent

Let's do honest sums, because the cost of a failed PoC isn't only the invoice. There's the **direct invoice** (the tens of thousands of euro of the workshop and the PoC), but there are at least two other items. There's the **internal time** burned: the meetings, the people involved, leadership's attention, all spent to arrive at a drawer. And there's the worst **opportunity cost**: distrust. After a failed PoC, "we tried it, AI isn't for us" spreads in the company, and that conviction also blocks the projects that would have worked. You paid to prove a possibility, and you got a wrong conviction of the opposite.

| Item | Reality |
|---|---|
| PoC / workshop invoice | tens of thousands of € |
| Internal time (meetings, people, leadership) | rarely counted, real |
| Worst cost: distrust | "AI isn't for us" blocks good projects |
| What changed in the company | nothing |

This bill serves one thing: on the second attempt, evaluate the cost not on the price of the PoC but on the **value it brings in production**. A project that costs more but arrives in production and saves hours every month is infinitely more valuable than a cheap PoC that proves and dies. The right metre isn't "how much the proof costs", it's "how much the thing is worth when we actually use it".

## How to evaluate a second attempt without burning more

You got burned once and you're rightly wary. But throwing the idea away would be the opposite error. The way to make a second attempt without risking another drawer is to change the criteria with which you choose and set up the project. Here are the criteria of the second attempt:

**Start from the process, not the technology.** The first question isn't "which AI model do we use", it's "which expensive, repetitive problem do we solve, for whom, and how does Tuesday's user use it". If whoever proposes the project starts from the technology, it's the same signal as before.

**Demand real users from the start.** The project has to involve whoever will use it from day one, and work on real, dirty data, not a clean example. If the plan is "first we prove on test data, then we'll see", you're remaking the drawer PoC.

**Ask that error be faced.** What does the system do when the model is wrong or doesn't know? If the answer is vague, the project is still a PoC in disguise. In production, error handling is half the work.

**Define "done".** Not "a demo that works", but "an operator uses this thing, in production, on real data, and it saves us X". The success criterion has to be real use, not approval in a meeting.

**Ask who owns it afterwards.** Once the project is finished, who maintains it, who evolves it, with which code and which data (yours). If there isn't an answer, you already have the seed of the next drawer.

## What has to be true before you write a line

Even before you sign, some things have to be true, or the project starts already lame. It's the boring part everyone wants to skip to "start immediately", and it's exactly the part that separates a project that arrives in production from one that dies.

**The problem and its value** have to be clear: how much the thing we want to solve costs today (in hours, euro, errors). If you don't know how much it's worth, you won't know if the project succeeded. **The real data** has to be accessible: where it lives, what state it's in, who owns it. An AI project lives on data, and if it's an unaddressed swamp, the project gets stuck too. There has to be **an internal person** who believes in it and follows it — the "owner" who afterwards will keep the thing alive. And there has to be agreement on **what it does NOT do**: the limits, where AI helps and where a human decides.

On that last point the rule I repeat everywhere holds: AI prepares, checks, proposes; the human decides where the decision has consequences. It's the boundary that keeps an AI project inside the rails of responsibility, the same one I talk about for [processes where AI meets decisions that count]({{ '/en/blog/credit-dossier-portal/' | relative_url }}). A project that promises "the AI that decides everything" is a project that promises trouble.

## The MVP an operator uses on Tuesday

What's the healthy alternative to the PoC? An **MVP an operator uses on Tuesday**. Not a demo that stuns leadership, but the minimum version of a real thing: one flow, done well, that a real person uses in their real work, on real data, and that saves them time or takes an error off them. Small, but real — with users, basic permissions, error handling, the minimum integration with the data. A product in miniature, not a demonstration.

The difference is substantial. The PoC says "look, it can be done" and ends there. The MVP says "look, Maria has been using it for two weeks and it takes her half the time" — and from there you expand. The MVP creates a proof that *stays* (a piece of production that works) instead of a proof that *evaporates* (an archived demo). As with [anything that has to be put in the hands of people who actually work]({{ '/en/pillar/internal-apps/' | relative_url }}), it's real use in the field that validates a project, not applause in the meeting room. If the second attempt produces an MVP someone uses on Tuesday, you're on the right road; if it produces another demo, you're heading for the drawer again.

## A typical case: the second attempt done well

A typical profile, architectural, no names. A company had been burned by an expensive AI PoC: a tech company had shown a brilliant demo on a chosen case, leadership had applauded, and then the whole thing had ended in a notebook nobody opened. In the company the "we tried it, it doesn't work" was spreading. The real problem — repetitive, expensive document work — was however real and still there, unsolved.

What was done differently on the second attempt. First they put technological enthusiasm aside and quantified the problem: how many hours, how many errors, how much it actually cost every month. Then they started from the real data (dirty, with the exceptions) and from an operator who did that work every day, involved from day one. Not a demo for leadership, but an MVP: a single flow, with the real interface, handling of cases where the AI wasn't sure (which went to the operator instead of producing a wrong result), and the minimum integration with company data. In the contract: ownership of the code, declared maintenance, and phases with exit points.

At regime, the difference wasn't "we have AI": it was that the operator started using the thing on Tuesday, for real, saving time on that work — and from there it expanded with trust, because there was a proof that *stayed* instead of a demo that had evaporated. The honest note: it cost more than the initial PoC, but it produced a piece of production that works, instead of a drawer. The metre wasn't the price of the proof, but the value of the thing in real use.

## Who builds it: a single pair of hands

A recurring reason PoCs die and second attempts succeed sits in *who* builds. An AI project that arrives in production is **data + backend + interface + AI** together: the model is worth little if the data isn't connected and clean, if there isn't an interface an operator uses, if there isn't the logic that handles error and permissions. Whoever sold you the PoC often only knew how to do the AI piece (the model, the prompt) and had never put software into production: that's why the demo was brilliant and production impossible.

A serious project is done by a head (or a tight team) that holds all four layers together, because the decisions are tangled: how I handle the model's error depends on how the interface is made, which depends on how the data is structured. If you split the project among "the AI people", "the backend people" and "the interface people", you get three worlds that don't talk and, again, something that doesn't arrive in production. You need a single end-to-end direction — the same logic that holds for [turning a demo into a real product]({{ '/en/blog/launch-white-label-ai-product/' | relative_url }}).

## The contract: ownership, maintenance, exit criteria

Let's talk about the contract, because that's where you protect yourself from the second drawer. There are precise clauses to demand, and the supplier's willingness to accept them is already a test in itself: whoever builds real things has no problem with these requests; whoever sells demos stiffens.

**Ownership.** Code, data and model (in the part that's yours) stay yours. No vendor lock-in: if tomorrow you change supplier, you take everything with you and someone else can continue. A project where the code stays with the supplier is a project that holds you hostage.

**Maintenance.** Who keeps the thing alive after go-live, with which timelines and at which costs. An AI project doesn't "finish": data changes, models evolve, company rules update. Without declared maintenance, even a successful MVP dies in instalments.

**Success and exit criteria.** What it means that the project worked (real use, measured saving), and what happens if it doesn't: how you stop, what stays yours, without leftovers. Defining *beforehand* how you exit is what keeps you from getting stuck in a project that doesn't take off.

**Phases with exit points.** The project has to be split into phases with real checks between one and the next, so you can stop after a phase if the results aren't there, without having committed the whole budget. Whoever asks you to sign everything in a block "because AI has to be seen as a whole" is taking away exactly the protection you need.

## When it's better to stop

The honesty I owe you: sometimes the right answer is not to do it. If the problem isn't expensive enough to justify the project, if the data is a swamp nobody wants to fix, if there isn't an internal person willing to own it, if the only push is "everyone is doing AI so we should too" — then stopping is the intelligent choice, and it saves you the second drawer. Not every problem needs AI, and not every company, at this moment, has the conditions for a project to take.

Stopping consciously is very different from failing: it's deciding not to spend where the conditions aren't there, and maybe fix the foundations first (the data, a process, a person) so you can try again when it makes sense. Whoever always says "yes, it can be done" is selling you; whoever sometimes says "wait, this doesn't make sense" is advising you.

## It's for you if / it isn't for you if

**It's for you if:** you've already burned budget on an AI PoC that ended in a drawer and you don't want to repeat the error; you have an expensive, repetitive problem that AI could actually help with, and real people who would use it; you're willing to start from the process and from real data, not from the technology; you want an MVP someone uses on Tuesday, with clear ownership and maintenance.

**It isn't for you if:** you're looking again for a demo that stuns leadership (that's the road to the drawer); you don't have a defined expensive problem, only the "we have to do AI"; the data is a swamp nobody wants to face; there isn't an internal person willing to own the thing afterwards. In these cases, better to stop or fix the foundations first.

## Frequently asked questions

**Why did our PoC end in a drawer?**
Almost certainly because it was born to demonstrate, not to be used: hand-cleaned data, no real user, no error handling, no integration, no internal owner afterwards. Those are the typical causes of death. It isn't bad luck: it was structured for the demo, not for production.

**Does that mean AI isn't for us?**
No, and that's the most dangerous wrong conclusion. It means *that* project was set up badly. A second attempt that starts from the process, from real data and from an MVP an operator actually uses can work very well. Don't throw the idea away because of a PoC made to stun.

**How do I avoid burning more budget?**
By changing the criteria: start from the process not the technology, demand users and real data from the start, ask how error is handled, define "done" as real use (not demo), and split the project into phases with exit points. And put ownership, maintenance and exit criteria in the contract.

**What's the difference between PoC and MVP?**
The PoC proves a thing is possible, in ideal conditions, and then dies. The MVP is the minimum version of a real product: a flow a real person uses in production, on real data, with permissions and error handling. The PoC evaporates; the MVP stays and expands. You want the second, not the first.

**Which clauses should I demand in the contract?**
Ownership of code and data (no lock-in), declared maintenance (who keeps the thing alive, how, at what cost), success and exit criteria (what success means, what happens if it doesn't work), and phases with exit points (so you can stop without having committed everything). The supplier's willingness to accept them is already a test.

**How do I trust a new supplier after getting burned?**
Look at what they talk about: if they talk mainly about technology and models, be wary; if they start from your process, your data, who will use the thing and how error is handled, that's a good sign. And test them with the clauses: whoever builds real things accepts them, whoever sells demos stiffens.

**Can we reuse the PoC we paid for?**
Sometimes a piece yes (a validated idea, a piece of logic), but often the PoC has to be rethought for production, because it was built to demonstrate, not to last. Don't start from the assumption "we already have half the work": that half was the tip of the iceberg. Evaluate what's actually reusable without getting attached to the budget already spent.

**When is it better not to do the project?**
When the problem isn't expensive enough, when the data is a swamp nobody wants to fix, when an internal person to own the thing is missing, or when the only push is "everyone is doing it". In those cases stopping (or fixing the foundations first) is the right choice and it saves you the second drawer.

## In one line

An **AI PoC that ended in a drawer** doesn't mean AI isn't for you: it means the project was made to stun, not to last — hand-cleaned data, no real user, no error handling, no owner afterwards. On the second attempt, change the criteria: start from the process and from real data, aim at an MVP an operator uses on Tuesday (not another demo), and put ownership, maintenance and exit criteria in the contract. And if the conditions aren't there — problem not expensive enough, data a swamp, no owner — stopping is the right choice, not a failure.

If you got burned by a PoC and you want to understand whether and how to actually get it into production, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/): we start from the problem, the real data and who will use the thing on Tuesday, not from a demo for leadership.
