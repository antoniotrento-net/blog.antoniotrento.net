---
lang: en
permalink: /en/blog/hiring-a-data-analyst-is-not-enough/
alt_url: /it/blog/data-analyst-non-basta/
title: "Hiring a data analyst doesn't fix the sources: why KPIs stay a fight (and you need a pipeline, not one person)"
date: 2026-03-27 07:30:00 +0200
author: "Antonio Trento"
description: "About to hire a data analyst to tidy up the numbers? Here's why one person isn't enough if the sources are dirty, and what you actually need before you open a role."
keywords: ["hiring a data analyst is not enough", "company data pipeline", "dirty data sources", "misaligned kpis", "sme data team"]
image: /assets/images/posts/data-analyst-non-basta.jpg
pillar: prodotti-dati
related: [/en/blog/late-sales-report/, /en/blog/owner-dashboard/]
---

## "We're looking for a data analyst": the move that looks obvious and is almost always premature

At some point it happens in almost every company that is growing. The numbers are a mess, meetings end in arguments over who is right, the owner is tired of not trusting the reports. And the decision arrives that looks like the most logical thing in the world: "let's hire someone to put the data in order". The posting goes out: *we're looking for a data analyst*. Junior, maybe, to keep costs down. Someone who "knows Power BI and SQL".

I'll tell you the uncomfortable thesis of this article right away: in most cases, **a data analyst isn't enough** — and hiring them *now*, before you've fixed the sources, is one of the most expensive ways not to solve the problem. Not because data analysts aren't useful: because you're asking one person to solve a problem that is **structural**, not a matter of extra hands. It's like hiring an excellent driver for a car you haven't built yet, hoping they'll build it in their spare time between laps.

This piece is for anyone about to open that role, or who has just opened it and is wondering why after two months the numbers are still a fight. Let's see what actually happens when you hire, why the KPIs stay *misaligned*, what you need *before* the person, and — important — when hiring does make complete sense.

## The first month: cleaning, not insight

Imagine you've hired. Day one, enthusiasm, "finally someone who shows us the numbers". What does the person actually do in the first month? Not analysis. **Cleaning.**

Because before they can analyse anything they have to get hold of the data, and the data is scattered across six places that don't talk to each other. So they spend the first days chasing access (that nobody knows where to find), then figuring out how the gestionale/ERP is structured (badly, like all of them), then discovering that the e-commerce calls "order" something the gestionale/ERP calls something else, then reconciling by hand customers written in five variants. At the end of the month they've produced... a clean spreadsheet. Not an insight: a spreadsheet. The same spreadsheet admin already used to produce, only now you pay more for it.

This isn't a failing of the person: it's the inevitable consequence of putting them downstream of a problem that sits upstream. *Dirty data sources* aren't cleaned by the intelligence of whoever looks at them: they're cleaned with written, repeatable rules that run every night automatically. If those rules don't exist, whoever you hire remakes them by hand every time — and it's Sisyphus work, because the month after the sources are dirty again.

There's a toxic side effect too: the good person, frustrated at never reaching the interesting part, leaves after a few months. And they take with them all of "how I made the numbers add up", which lived in their head and in a spreadsheet on their computer. You start from scratch. I've written a whole piece on this mechanism — [why the report always arrives late and it isn't the fault of the person who makes it]({{ '/en/blog/late-sales-report/' | relative_url }}) — because it's the exact same mistake seen from another angle.

## A typical case: the analyst hired for the numbers, stuck on cleaning

A typical profile, architectural, no names. Distribution company, growing, numbers getting more chaotic. They decide to hire: a junior data analyst, capable, motivated. What happens, month by month.

**Month 1–2:** access to recover, gestionale/ERP to understand, e-commerce that names things differently, customers written in five variants to merge by hand. They produce a clean spreadsheet. The owner starts asking "but the insights?".

**Month 3:** first dashboard. At the meeting, sales contests the sales figure ("for me it's higher"), accounts contests another one. The person doesn't have the authority to close the discussion, and every department stops trusting "their" number shown by the dashboard.

**Month 5:** frustrated at spending the days reconciling instead of analysing, and tired of refereeing fights that aren't theirs, the person accepts another offer. They leave with all of "how I made the numbers add up": it was in their head and in a spreadsheet on their computer. The company starts from scratch, plus the distrust ("we tried with a person, it didn't work").

Then they did it in the right order. First a table with leadership, sales and accounts to decide the definitions. Then a pipeline that cleans the sources and applies those definitions every night, automatically. Then a dashboard with alerts. **At that point** they hired someone again — this time with a business head, not a jack-of-all-trades — who found a system ready and could actually do the analyst job. They stayed. The difference wasn't "finding the good one": it was building first the ground they could work on.

## The KPI fight: two "sales" that will never add up

Here's the heart of the problem, and the reason *misaligned KPIs* aren't solved by hiring. Let's take a concrete example, the kind I see in every company.

Monday, meeting. The sales director says: "in September we did 520,000". The accounts manager looks at them and says: "no, 470,000". Embarrassed silence. Who is right? **Both of them.** Because they're measuring two different things with the same word:

- Sales counts **signed orders** in the month, VAT (IVA) included, including things that still have to be delivered and invoiced.
- Accounts counts **invoices issued** in the month, VAT (IVA) excluded, with returns already deducted.

They're two legitimate numbers, two different "sales". Until someone decides *which* is THE sale for the company, every meeting starts from this fight again, and no data analyst can resolve it — because it isn't a calculation problem, it's an **agreement** problem. The person can produce both numbers perfectly well; they don't have the authority to decide which one counts. And if they try to decide it themselves, the department that "loses" its number no longer trusts the dashboard. End of project.

This is the point that escapes anyone who thinks data is a technical problem. Company data is a **political and organisational** problem before it's a technical one. The KPI fight is a fight over definitions, and definitions are decided by the company, not the analyst. You need someone who brings everyone to the table and gets the answer written down — and then a system that applies it always, the same way, without anyone being able to "tweak" it by hand.

## Not just sales: the other words that fight

"Sale" is only the most visible fight. Scratch underneath and you find others, and each one stalls a different meeting:

- **Active customer.** After how many days without orders does someone stop being "active"? 60, 90, 180? The threshold instantly changes how many customers "you're losing" — and therefore whether the problem is serious or normal. Without a decided threshold, everyone uses their own.
- **Margin.** On list price or on the discounted net? With or without shipping, commissions, return costs? Two people can declare two different "margins" on the same order, both in good faith.
- **New customer.** Does it count from the first order or from the first payment? And if they come back after two years of silence, are they "new" or "reactivated"? The answer changes the marketing numbers.
- **Conversion rate.** Numerator and denominator of *what*? Quotes on contacts, orders on quotes, orders on visits? Three different numbers, all called "conversion".

None of these has a universal right answer: it has *your* answer, which has to be decided and written once and for all. A data analyst can calculate them all perfectly, but they can't *decide* which one counts: that's a business choice. And that's why hiring before you've decided the definitions moves the problem, it doesn't solve it — the person inherits the fights, they don't close them.

## Why one person alone can't be enough

Let's summarise the structural why, so it's clear this isn't a matter of finding "the good one".

A data analyst on their own hits three walls that no individual skill knocks down:

1. **Dirty sources** have to be cleaned with automatic, repeatable rules, not by hand every month. That's data engineering work (a *pipeline*), not analysis.
2. **Definitions** have to be decided by the company, not the analyst. You need authority and a table, not SQL.
3. **Continuity**: if the knowledge lives in the person, when the person leaves the problem comes back. It needs to live in a documented system.

One person alone can, at best, patch all three walls with heroism and overtime. But it's a fragile balance that holds as long as they hold. The day they get sick, go on holiday or change jobs, you discover you bought a dependency, not a solution. It's the same reason [deciding by gut when the numbers live in six pieces of software]({{ '/en/blog/owner-dashboard/' | relative_url }}) isn't solved with a pretty dashboard: without the system underneath, it's all scenery.

There's a human aspect that matters too, beyond the technical one: putting one person alone against these three walls is unfair, not just ineffective. You're setting them up to fail. Even the best data analyst in the world, without a pipeline underneath and without definitions decided above, can only choose which wall to hit first. And when a good person realises they've been put in an impossible position, the healthiest reaction they can have is to leave. You're not losing because you chose the wrong person: you're losing because you asked one person to be, on their own, an entire system.

## What a hire made too early actually costs

Salary is only the tip. The real cost of hiring before you have the system is made of items nobody puts in the estimate, but that weigh.

| Item | What it really costs |
|---|---|
| Gross salary (RAL) + contributions + workstation | ~30,000–40,000 € the first year for a junior |
| Onboarding of others | weeks of accounts and IT time to grant access and explain the sources |
| Opportunity cost | for months you still *don't* have trusted numbers: decisions stay in the dark |
| Turnover | if the person leaves frustrated, you start from scratch and lose their unwritten knowledge |
| Internal distrust | "we tried, it didn't work": they look at the next proposal with suspicion |

Add these items up and compare them with the cost of building the system first (pipeline + definitions + dashboard), which is a one-off spend plus maintenance and starts delivering value in weeks. In most SMEs the account is clear: the system first, the person after. Not because people cost too much, but because a person put downstream of a structural problem can't solve it, and in the meantime you pay them. It's the same "speed versus headcount" reasoning I made talking about [reports that always arrive late]({{ '/en/blog/late-sales-report/' | relative_url }}): hiring looks like the prudent move, and it's often the most expensive.

## Who needs to sit at the table (and it isn't IT alone)

If the KPI fight is organisational, its solution is organisational. Before you write a line of code or hire anyone, you need a table with the right people. Here's who, and why.

| Role | Why they're at the table | What they bring |
|---|---|---|
| **Owner / leadership** | has the authority to close discussions on definitions | decides which number is "the" number |
| **Sales** | knows how orders, discounts, promises are born | the real exceptions of the sales world |
| **Accounts** | knows invoices, returns, VAT (IVA), collections | the fiscal and cash truth |
| **Whoever knows the data/IT** | knows where the data lives and what state it's in | feasibility and sources |
| **Whoever builds (internal or external)** | translates decisions into automatic rules | the pipeline and the product |

Note who *can't* hold the table alone: IT. The classic mistake is "give the data to IT and they'll make us the dashboards". IT knows where the data is, but they don't have the authority to decide what a sale is, and they shouldn't have it. If the definitions are chosen by IT (or an analyst) without sales and accounts at the table, you get technically correct numbers that nobody in the company trusts. And a dashboard nobody trusts is worse than no dashboard, because it adds discussions instead of closing them.

## The three job postings that reveal the problem

The fastest way to see if you're about to get this wrong is to read the posting you've written. There are three typical versions, and all three reveal that what's missing is the system, not the person.

- **"We're looking for a data jack-of-all-trades."** Translation: we don't have a pipeline, so we need someone who cleans by hand, makes the charts, talks to the departments and maybe also fixes the gestionale/ERP. It's a description of three different jobs dumped on one person, usually junior. They won't do all three well, and they'll burn out trying.
- **"Must know Power BI and SQL."** Translation: we're thinking about the tool, not the problem. Technical skill is useful, but it's the last thing that's missing. First the definitions and the clean sources are missing; without those, Power BI shows wrong numbers with beautiful charts.
- **"They will put our numbers in order."** Translation: we're delegating to one person an organisational decision (what a sale is) that belongs to leadership. No analyst can "put order" in a fight they don't have the authority to referee.

What would a healthy posting look like? One that starts *after* the system: "We're looking for someone who, on an already consolidated data base with shared definitions, can read the numbers, spot anomalies and bring questions to the business." That's a feasible job, attractive, and you find the right person. The other is a trap with a salary inside.

## What a person does vs what a system does

Let's clarify the division of labour, because this is where you understand what to buy and in what order.

| | A person does this (well) | A system does this (well) |
|---|---|---|
| Clean the sources every night | no: it's repetitive and has to be automated | yes: rules written once, applied always |
| Apply the agreed definitions | risky: they can "tweak" by hand | yes: always the same, verifiable |
| Notice an anomaly at 3 in the morning | no: they're asleep | yes: automatic alert |
| Understand *why* a line is dropping | yes: you need a head and context | no: it shows the fact, not the why |
| Bring a new question to the business | yes: that's the real value | no |
| Tell the numbers to whoever decides | yes | no |

Look at the two columns: the system does the *boring and repeatable* work (cleaning, rules, alerts), the person does the *thinking* work (interpretation, questions, narrative). If you hire a person without the system, you force them to do the right-hand column by hand — that is, you make them do the system's job, wasting exactly what you hired them for. First the system, then the person who thinks on top of it. Never the other way round.

## The pipeline: contracts on the numbers, not charts

The word missing from almost every discussion about "let's hire for the data" is **pipeline**. A *company data pipeline* isn't a chart and isn't a person: it's the piece of engineering that, every night, takes data from the sources, applies the cleaning rules and the agreed definitions, builds the history and sets the alerts. It's the invisible "underneath" that any dashboard sits on.

The right way to think of it is as a series of **contracts on the numbers**. A contract says: "a sale is calculated like this, from this source, with this rule on returns; if the source doesn't respond, the number is marked incomplete instead of being falsified". They're contracts because once signed they aren't changed in secret: they're written in code, verifiable, and if they change everyone knows. This is what makes numbers *trusted* — not the beauty of the chart on top, but the solidity of the contract underneath.

A dashboard without a pipeline is a dress without a body: it stands up as long as the person holds it up by hand. A pipeline without a dashboard is useful but mute. You need both, and they have to be designed together, by the same head, because the definition of a number and the way you show it are the same decision. That's why I rarely hand "the data" to one supplier and "the interface" to another: they blame each other and you pay twice.

An example of what changes, in concrete terms. **Before** the pipeline: every Monday someone downloads three files, pastes them, subtracts returns from memory, corrects duplicate names, and towards Wednesday the number is ready (maybe right). **After** the pipeline: at 6 in the morning the three files have already been taken, cleaned with the written rules, returns deducted according to the signed definition, duplicates merged with a repeatable logic; at 8 the number is on the screen, the same for everyone, and if a file hasn't arrived it says "incomplete data" instead of a false total. The difference isn't just speed: it's that the number no longer depends on the memory and mood of whoever compiles it. It has become a fact, not a weekly opinion.

## The signal that you've already hired too early

Maybe you've already hired the person, and you're reading this article with a certain discomfort. Here are the signals, at 60–90 days, that you've put them downstream of a problem that sits upstream:

- They still spend most of their time **cleaning and reconciling**, not analysing.
- At meetings you **still fight** over which number is right: the definitions haven't been decided, they've been delegated to them.
- Dashboards exist, but **nobody opens them**, because nobody trusts the numbers.
- The person starts to be **frustrated** ("this isn't the job I thought I'd been hired for").

If you recognise yourself, the good news is you didn't get the hire wrong: you got the order wrong. The move isn't to fire, it's to **build now the system that's missing** — the definitions table, the pipeline, the alerts — and shift the person onto the right role as the system takes the dirty work off them. Whoever was hired as "compiler by force" often becomes an excellent interpreter, as soon as they stop drowning.

## When to hire AFTER (and take the right person)

I'm not saying "never hire". I'm saying hire **in the right order**, and the difference is huge.

First you build the system: the definitions table, the pipeline that cleans and applies the rules, the dashboard that updates itself with the alerts. At that point — and only at that point — hiring a person makes sense, for three reasons:

- They no longer drown in cleaning: the system does that. They can devote themselves to the part that counts.
- They watch the dashboard: they notice when a number is strange, understand why a line is dropping, bring new questions.
- They do the real analyst job, not the compiler job. And it's finally a job a good person wants to do (and stays for).

*Who* you hire also changes. Before the system you desperately look for a jack-of-all-trades who "can do everything" (read: who cleans by hand and doesn't complain). After the system you look for someone with a business head, who can read the numbers and talk to the departments — a different profile, more useful, and easier to find because you're offering a sensible job instead of a nightmare of reconciliations. If you want to understand this distinction better between whoever *cleans reports* and whoever *builds product*, I go into it further talking about [dashboards nobody uses because the right questions are missing]({{ '/en/pillar/data-products/' | relative_url }}).

## The myth of "we'll do it in-house with Power BI"

The DIY version of "let's hire an analyst" is "we'll buy Power BI and do it in-house". It's the same illusion in a different outfit. Power BI — or Looker, or Metabase, or any tool — is excellent, but it's the top layer: it connects to the data and shows it. If the data underneath is dirty and the definitions don't exist, the tool only lets you produce wrong charts faster, and with a more professional look. Which is even worse: an ugly chart you doubt, a beautiful glossy one you believe.

Almost all the real work of a dashboard sits *before* the tool: agreeing the definitions, connecting the sources, cleaning them, keeping them updated, putting alerts on the breaks. The tool is the last 20%, the part you see. Buying the tool and giving someone the job of "making dashboards with it" means dumping on them the invisible 80% — cleaning and definitions — that no tool does for them. And here we are again with one person against the three walls, only with an extra software licence to pay.

A note: I'm not saying Power BI is the problem. It's an excellent presentation layer. The problem is thinking that *buying the tool is buying the solution*. The tool without the system underneath is an expensive camera in the hands of someone who hasn't yet decided what to photograph.

## The deliverables an owner signs

If you open this table for real, what should you have in your hands at the end — that is, what are you buying, whether it's done by an internal or a supplier? Here are the concrete deliverables an owner can read and sign, without being technical:

1. **The definitions document.** A few pages: what a sale is, an active customer, a margin, a return, with the date and the signature of whoever decided. It's the most important document of all.
2. **The map of sources.** What they are, what state they're in, who has access, what happens when one changes.
3. **The documented pipeline.** Not the code line by line, but what it does, how often, and how you notice if it breaks.
4. **The dashboard.** A few metrics that respect the definitions, with the alerts, that works from the phone too.
5. **The maintenance plan.** Who puts their hands on it when a source changes, with what timescales, at what cost.

If you're evaluating a hire and nobody talks to you about these five deliverables but only about "Power BI and SQL skills", you're buying a tool with legs, not a solution. Technical skill is needed, but it's the last thing that's missing: what is missing first are the definitions, the table and the pipeline.

## How you start, without hiring right away

If you're convinced the right order is "the system first", here are the first concrete steps, none of which requires opening a role.

1. **Call the table.** Leadership, sales, accounts, whoever knows the data. A couple of hours, one goal: decide the first five definitions that count (sale, active customer, margin, return, the KPI you look at most).
2. **Write the definitions.** A few lines, with the date and who decided. From that moment they're law: whoever disagrees argues the definition, not the chart.
3. **Map the sources.** What they are, what state they're in, who has access, how dirty they are. You need this to understand where it will be easy and where you'll sweat.
4. **Have the pipeline built on one source.** Start from the one that weighs most (usually the gestionale/ERP) and bring home a real dashboard in a few weeks, with the alerts. Then widen.
5. **Only now evaluate the person.** With the system standing, you understand what *type* of person you actually need — almost always one with a business head, not a technical jack-of-all-trades — and you offer them a sensible job they'll stay for.

The first three steps you can even do yourself, this week. They're free, and they're worth more than any job posting.

## One last misunderstanding: "our data is too particular"

There's an objection that comes up when you propose fixing the sources before hiring: "but our data is too particular, only someone who lives in here can understand it". It's half true, and it's a trap. It's true that every company has its exceptions: that customer who pays their own way, that line that's discounted differently, that gestionale/ERP bent over the years until it does things the manual doesn't cover.

But the right consequence isn't "you need a person who keeps them in their head": it's "those exceptions have to be *written*, not remembered". A rule written in the pipeline holds every night, even when the person who knew it is on holiday or has left. A rule "in Maria's head" holds as long as Maria is there. The more particular your data is, the more you need a system that locks the particularities into verifiable rules — not a person who balances them by hand every month. The particularity of your data is an argument *for* the system, not against: it's exactly why you can't afford it to live in one head only.

## It's for you if / it isn't for you if

**It's for you if:** you're about to open a "data analyst" role to put the numbers in order; meetings end in arguments over which number is right; you've already tried with a person and after months they produce spreadsheets, not insight; you have multiple sources that don't talk to each other and definitions that live in people's heads.

**It isn't for you if:** you have a single clean source and the numbers are already clear and shared; you're a large enough organisation to *already* have a solid pipeline and definitions, and you really only need more analysis capacity (then yes, hire); you're looking for someone to "make the charts" for a one-off presentation, not to run the company.

## And if I wait and carry on like this in the meantime?

The temptation, faced with "the system first, then the person", is to postpone: "for now we carry on as always, we'll think about it later". It's legitimate, but it's worth being honest about the cost of as-always. Every month without shared definitions is a month of meetings that start from the same fight over the numbers. Every month without a pipeline is a month in which a good person wastes days pasting files instead of thinking. Every decision taken on the wrong number — a reorder, a discount, a customer not called back in time — is a cost you don't see but you pay.

Waiting isn't free: it's only a cost that doesn't appear on an invoice. And the good news is the alternative isn't "a big project or nothing". The first steps — calling the table, writing five definitions, mapping the sources — don't require budget or hires: they require a couple of hours and the will to close a few discussions once and for all. You can start from there, from the piece that costs nothing and is worth most, and decide the rest when your ideas are clearer. What it's worth avoiding is the one truly expensive move: opening a role to solve a problem that, as it stands, no one person alone can solve.

## Frequently asked questions

**So I should never hire a data analyst?**
On the contrary: hire them, but after you've built the system. Before the system, one person alone drowns in cleaning and produces spreadsheets. After, they finally do the analyst job and stay because the work makes sense. It's a question of order, not of yes/no.

**Does an external day-rate consultant solve it?**
Same problem as the internal junior: if their work is cleaning by hand every month, you've bought a recurring patch, not a solution. An external is useful to *build the system* (the pipeline, the definitions), not to remake the report by hand every time.

**Who decides the right definition of "sale"?**
The company, at the table, with the authority of leadership. Not the analyst, not IT. Their job is to make the decision feasible and then automatic, not to take it.

**We already have Power BI and a person who uses it: why isn't that enough?**
Because Power BI is the top layer. If underneath there isn't a pipeline that cleans the sources and applies agreed definitions, the person remakes them by hand every time, and the numbers stay fragile and contested. The tool isn't the problem; it's the lack of the system underneath.

**How long does it take to build the system before hiring?**
For an SME with typical sources, a useful system in a few weeks and seasoned in a few months. The most valuable phase is the definitions table at the start: that's where you decide whether the numbers will be trusted or contested.

**And if I have nobody in the company who understands the data?**
That's fine: the system is built with a supplier, and day-to-day watch can be light (an hour a day of someone who looks at the alerts). The important thing is not to start by hiring a junior hoping they'll "figure out how to do it": that's the path that ends with a clean spreadsheet and a frustrated person.

**Better a data engineer or a data analyst?**
They're two different trades. The data engineer builds the pipeline (the "underneath"); the data analyst reads and interprets the numbers (the "on top"). In the right order, first you need whoever builds the system (often a supplier or an engineer), then eventually whoever interprets it every day. Hiring an analyst and asking them to do the engineer job is the recipe for the failure I describe here.

**How big is the team you actually need?**
Smaller than you think. In an SME, you often don't need a "data team": you need a well-built system (once) and a person who watches it part-time, plus a maintenance agreement. The large team is needed when volumes and questions really grow — and at that point you build it on a solid base, not on chaos.

**Can't AI do the analyst job for us?**
It can help at the edges (summarise, group notes, write a readable comment on top of numbers already calculated), but it doesn't solve the underlying problem: the definitions and the dirty sources. If you give a model contested, dirty data, it gives you plausible and wrong answers, with more confidence than before. First the system, then — if needed — AI on top.

## In one line

If you're about to hire a data analyst to put the numbers in order, stop a moment: **the problem is almost never the lack of a person, it's the lack of a system**. First the definitions table, then the pipeline that cleans the sources and applies the rules, then the dashboard with the alerts. Once that's done, the right person becomes valuable — and stays, because they finally do the analyst job instead of the compiler job.

If you want to understand where to start on *your* numbers and your sources, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/): you start from the definitions and the sources you have, not from a job posting.
