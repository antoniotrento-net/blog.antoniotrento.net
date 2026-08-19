---
lang: en
permalink: /en/blog/case-management-software/
alt_url: /it/blog/software-gestione-pratiche/
title: "Cases stuck three weeks in an inbox: the software that moves dossiers (not another email)"
date: 2026-08-26 07:30:00 +0200
author: "Antonio Trento"
description: "«Where is my case?» and nobody can answer. If you manage cases by email, cycle time stretches and clients leave. Here's the software that moves dossiers: states, owners, deadlines and status visible to the client."
keywords: ["case management software", "stuck client dossiers", "case workflow", "insurance broker software", "visible case status"]
image: /assets/images/posts/software-gestione-pratiche.jpg
pillar: documenti-flussi
related: [/en/blog/credit-dossier-portal/, /en/blog/internal-app-copy-paste/]
---

## «Where is my case?» and nobody knows

There's a question that, if you work with cases — a practice, an insurance broker, an agency, an office that instructs dossiers — you hear every day: «where is my case?». And there's a scene that repeats: to answer, someone has to open the inbox, search the last exchange with that client, ask a colleague «did you work this one?», check if an attachment is missing. Five minutes to answer a question a serious system would answer in a second. And often the real answer is embarrassing: «it's been stuck for three weeks, and nobody had noticed».

This is the heart of the problem. It isn't that goodwill is missing: it's that cases live in **email**, and email isn't made to manage a workflow. A case changes hands, waits for a document, gets approved, comes back for an integration, expires — and all of this, in an inbox, is invisible. You don't know which cases are stuck and why, who has them now, what's missing, which are about to expire. The result is that cases get bogged down, **cycle time** (from when they arrive to when they close) stretches, and every day of delay is a more nervous client and, sometimes, a lost client.

This article is for anyone who manages **cases** and feels the flow jamming in email. Let's see why email as a database is a disaster, what a "state machine" is (the concept that makes dossiers move), why you need to make **case status visible** — to the client and to the owner — and where AI actually helps (classify and extract) and where it must not stick its nose (decide). The goal: turn a pile of emails into a flow that moves.

## Email as a database: the disaster you can see coming

Let's stop on why email, for managing cases, is the wrong tool — even though it's the one everyone uses, because "it's already there". Email was born to *communicate*, not to *manage a state*. And a case is, first of all, a state that changes over time: it arrives, it gets worked, it waits, it gets approved, it closes. Email knows nothing about that state.

What happens when you use email as the database of cases? Information **fragments** across dozens of scattered messages, some in one inbox, some in another, some in copy to someone. The state of a case **doesn't exist** anywhere: to know it, you have to reconstruct it by reading the thread. **Responsibility is confused**: a case in copy to three people is a case nobody owns, because each thinks someone else is on it. **Deadlines are invisible**: nobody warns you that case X expires tomorrow, until it's too late. And **attachments get lost**: the right document is in one of twenty emails, to be searched.

The result is what you see: cases that stop without anyone noticing, because in an inbox "stuck" and "in progress" look the same — a read email. It's the same disaster as [when documents travel by email instead of living in a system]({{ '/en/blog/credit-dossier-portal/' | relative_url }}): as long as information "travels" instead of "sitting" in a place with rules, chaos is guaranteed. Email is an excellent cable to communicate; it's a terrible place to make a process live.

## The state machine: what makes dossiers move

Now the concept that changes everything, explained in plain language without jargon: the **state machine**. It's the idea that every case, at every moment, is in *one* precise, known state, and that from each state it can only move to certain later states, with clear rules. It sounds obvious, and it's exactly what email doesn't have.

Let's take a concrete example. A case can be in these states: **received** → **under review** → **waiting for documents** → **ready for approval** → **approved** (or **rejected**) → **closed**. Each state has a precise meaning, an owner (who is working it now), and rules on what's needed to move to the next state. When a case is "waiting for documents", the system knows what's missing and who has to provide it; when it's "ready for approval", it knows who has to approve it. There's no ambiguity: at every moment, for every case, you know *where* it is, *who* has it, *what* is needed to move it forward.

Around the state machine live the four things email doesn't manage: **states** (where the case is), **owners** (who has it in hand — one, not three in copy), **deadlines** (when something has to be done, with the warning *before* it expires), and **attachments** (the documents, tied to the case, not lost in a thread). This structure is what **moves dossiers**: a case can no longer "stop without anyone noticing", because the system knows it's been stuck in a state too long and flags it. The flow, instead of bogging down in the silence of email, moves — and when it jams, you see it.

It's the same modelling work that sits under [every internal app that mirrors the real process]({{ '/en/pillar/internal-apps/' | relative_url }}): the value isn't "digitising emails", it's understanding how your case flow actually works — states and exceptions included — and modelling it well, so the software makes it flow instead of just storing it.

## Deadlines and attachments: the two things email makes you lose

Two pieces of the state machine deserve a separate word, because they're exactly what email loses and what costs most: deadlines and attachments.

**Deadlines.** Many cases have terms: a reply within so many days, a document that expires, a regulatory window, a commitment made to the client. In email, the deadline is invisible: there's nothing that warns you case X has to be done by tomorrow, until it's too late and the term has been missed — with the damage that follows (a case rejected for delay, a lost client, a penalty). A case-management system instead *knows* the deadlines: it ties them to the case, warns the owner *before* they expire, and highlights those at risk. The chase is no longer entrusted to one person's memory (who forgets, goes on holiday, has a thousand things): it's the system that doesn't forget. This single function, in sectors where terms count, pays for the tool on its own — because a missed deadline costs much more than any software.

**Attachments.** A case is also made of its documents, and in email they live scattered across twenty messages: the right document is "in one of those emails", to search and download every time. In a system, attachments are **tied to the case**: you open the case and they're all there, ordered, with their version, who uploaded them and when. No more hunting for the document, no more "but you sent me the updated version?". And attachments follow the state: when a case is "waiting for documents", the system knows which are missing. It's the same document order I talk about for [portals where documents live in a place with rules instead of travelling by email]({{ '/en/blog/credit-dossier-portal/' | relative_url }}): the document tied to the case, not scattered in an inbox, is half the work of making the flow move.

## Visible status: to the client and to the owner

Once every case has a known state, something powerful happens: you can **make it visible**. And that changes two relationships.

The first is with the **client**. Instead of getting twenty phone calls a day "where is my case?", you give them a place — a portal — where they see the **status of their case** in real time: where it stands, what's missing, what they have to do. The calls collapse, because the answer is there, always, without disturbing anyone. And the client is calmer, because they have visibility instead of silence — the anxiety of waiting, which today dumps on you as chases, shrinks when the person can see for themselves where their case is. It's the same principle of client UX I cover for [portals where the client follows their case]({{ '/en/blog/credit-dossier-portal/' | relative_url }}): visible status is respect for the client and less work for you, together.

The second relationship is with the **owner**, and it's perhaps even more valuable. When every case has a state, the owner sees the **bottlenecks**: how many cases are stuck in each state, for how long, where they pile up. They discover that cases always bog down at the same point (approval? waiting for documents? a certain handoff?), and that's the point to intervene on to shorten cycle time. Without states, the owner navigates blind ("it feels like we're behind"); with states, they have an X-ray of the flow and know exactly where the plug is. It's the same jump from "it feels like" to "the data say" that a dashboard gives in other domains: here the dashboard is on the case flow.

## The bill: cycle time is money and clients

Let's put some numbers, because "cases get bogged down" stays vague until you tie it to money. The cost hides in three items.

**Time spent answering "where is it?"**: if your office gets, say, 30 status requests a day (clients, colleagues) and each costs 5 minutes between searching and answering, that's 2.5 hours a day — over **500 hours a year**, around **€12,000** of time, spent only to say where the cases are.

**Stretched cycle time**: every day a case stays stuck without reason is time you don't bill (if you invoice on close) and the client gets more nervous. If you shorten average cycle time, you close more cases in the same period with the same staff — that is, you increase capacity without hiring.

**Lost clients**: a case stuck too long, a client left in the dark, is a client who sometimes leaves — or who doesn't come back and doesn't recommend you. This item is invisible but real, and in services where the relationship counts, it's often the largest.

| Item | Estimate |
|---|---|
| "Where is it?" requests handled by hand | ~30/day → ~500 h/year (~€12,000) |
| Stretched cycle time | fewer cases closed at equal staff |
| Clients lost/unhappy from stuck cases and silence | invisible, often the largest item |

The point is that cycle time isn't an operational detail: it's directly **money and clients**. A flow that moves closes more cases, faster, with happier clients; a flow bogged down in email does the opposite, in silence.

## AI: classify and extract, not decide

The question about artificial intelligence always arrives, and here the answer is precise. In case software, AI **helps** in two concrete points. The first is **classify**: an incoming case or document can be recognised and routed automatically (what type it is, which flow it belongs to, who it should be assigned to), taking away the manual triage work. The second is **extract**: from an attached document, AI can pull out the data that's needed (dates, amounts, references) and pre-fill the case, instead of making a person retype everything. Both save real time on boring work.

Where AI **must not** enter is the **decision**: whether a case should be approved or rejected, under which conditions, whether a case is eligible. Those are evaluations with precise responsibility, and you don't delegate them to a model that "usually" gets it right — especially in regulated sectors like insurance or finance, where an error is damage to a real person and to you. The rule is the usual one, and protecting it is in your interest: **AI classifies, extracts and prepares; the human decides.** AI tells you "this case is type X, here are the data, it looks complete"; the decision is taken by whoever has the responsibility. Whoever sells you "the AI that adjudicates cases" is selling you a risk, not a function — it's the same boundary I talk about for [every document process where AI meets decisions that count]({{ '/en/pillar/documents-workflows/' | relative_url }}).

## The client portal vs the phone every day

It's worth insisting on the client portal, because it's the part that gives the most immediate, visible return. Today, without a system, the client has one way to know where their case is: call you or write to you. And they do, often, because they're anxious (the case maybe concerns something important to them). Every call is your office's time, and multiplied by clients it becomes a mountain of interruptions.

A portal where the client sees the status of their case flips the situation: the client goes in, sees where it stands, what's missing, what they have to do, and they don't call. Status requests collapse, your office frees up, and — paradoxically — the client is *more* satisfied, because they have more visibility than before, not less. It isn't "an extra service to maintain": it's less work for you and more peace of mind for them. And the portal, to work, needs exactly the state machine underneath: if the case has a known state, you can show it; if it lives in an email thread, you have nothing to show. Portal and state machine are two faces of the same thing.

## Go-live by team, not big bang

How do you introduce a system like this without trauma? Not all at once (big bang), but **one team at a time**. The error is switching the new system on for all offices and all case types the same day: it's the best way to generate chaos and refusal, because every team has its habits and its cases, and you discover them all together at the worst moment.

The healthy way is to start with **one team or one pilot case type**: you model their flow, you put it into production, you work on real cases, and you fix the exceptions that emerge (because they always emerge — the odd case the model didn't foresee). When that team works well on the new system, you move to the next, bringing the experience already gained. This gradual rollout reduces risk and builds trust: when the first team says "finally I can see where the cases are", the others want it. It's the same adoption principle of [every internal tool people actually have to use]({{ '/en/blog/internal-app-copy-paste/' | relative_url }}): you validate with a group, you adjust, you expand — you don't drop it from above on everyone hoping it works.

## When a generic CRM is enough (rare)

The honesty I owe you: sometimes a generic CRM or an ERP with a "cases" module can be enough, and it's right to evaluate it before thinking about something custom. If your flow is simple and standard — few states, few exceptions, one linear case type — a ready-made tool that manages tasks and states might cover you, at contained cost.

But in my experience, for whoever lives on cases, this case is **rare**, and the reason is that the value sits precisely in the specificities: *your* states, *your* transition rules, *your* deadlines, *your* type of documents, the portal with *your* logic. A generic CRM manages "tasks" and "opportunities", not the precise flow of your cases with their rules; it takes you to 80% and stops exactly on the part that counts. The question is always the same: how much of your flow sits in that 20% the generic doesn't do? If your work *is* managing cases with their rules, almost always the heart sits there, and the generic is too tight. If instead cases are a marginal piece of a job that's mainly something else, the CRM you already have can be enough — and in that case don't spend more.

## A typical case: from the inbox to a flow that moves

A typical profile, architectural, no names. An office that instructed cases for clients managed everything via email and shared folders: every case was a thread, attachments scattered, and the state lived in the head of whoever was working it. Clients called constantly to know where they stood; the office spent half-days answering «I'm checking». Every so often a case stuck for weeks emerged that nobody had picked up, with the client now furious. Nobody could say where the flow bogged down most, because nobody measured it.

What was done. First the real flow was mapped: which states a case actually goes through, who works it in each, what's needed to move to the next state, which deadlines. Then the state machine was built: every case with its state, its owner (one), its deadlines with warning, its attachments tied. A portal where the client saw the status of their case. And a view for the owner that showed how many cases were stuck in each state and for how long. AI used to classify incoming cases and extract data from documents, but the decision stayed human. Go-live one team at a time.

At regime, the difference wasn't "we have software": it was that cases stopped stopping in silence. The client saw the status and didn't call; the office no longer acted as the status switchboard; the owner saw the bottleneck (in their case, an approval step that piled up cases) and intervened, shortening cycle time. Forgotten cases disappeared, because the system flagged those stuck too long. The honest note: the value came from having modelled *their* real flow well, exceptions included — not from a magic function.

## It's for you if / it isn't for you if

**It's for you if:** you manage cases/dossiers that pass through more hands and more phases (practice, broker, agency, instruction office); cases live in email and nobody knows at a glance where they stand; you get constant "where is my case?" requests; some cases stop without anyone noticing; you want to see where the flow bogs down and shorten cycle time.

**It isn't for you if:** you have very few very simple cases, with one linear state and no exceptions, where email or a generic CRM really is enough (then you don't need a dedicated system); cases are a marginal piece of a job that's mainly something else; you aren't willing to model and put order in your flow — because a state system requires making the process explicit, and if you prefer improvising case by case, you won't adopt it.

## Frequently asked questions

**Why isn't email enough for cases?**
Because email was born to communicate, not to manage a state. A case is a state that changes (arrives, gets worked, waits, closes); email knows nothing about that state. The result is fragmented information, confused responsibility (a case in copy to three is nobody's), invisible deadlines and lost attachments. Cases stop in silence, because in an inbox "stuck" and "in progress" look the same.

**What is a "state machine"?**
It's the idea that every case, at every moment, is in one precise, known state (received, under review, waiting for documents, ready for approval, closed…), with an owner and clear rules to move to the next state. It's what makes dossiers move: you always know where every case is, who has it, what's needed to move it forward — and the system flags those stuck too long.

**Will the client be able to see the status of their case?**
Yes, with a portal where they see where it stands, what's missing, what they have to do — in real time. "Where is it?" calls collapse and the client is calmer, because they have visibility instead of silence. The portal works precisely because underneath there's the state machine: if the case has a known state, you can show it.

**Can AI manage the cases?**
AI helps classify incoming cases (route them, assign them) and extract data from documents (pre-fill instead of retype): boring work taken away. It must not decide whether a case is approved or rejected: that's evaluation with responsibility, especially in regulated sectors, and it stays human. AI prepares and classifies, the person decides.

**Isn't the CRM I already have enough?**
Rarely, if you live on cases. A generic CRM manages tasks and opportunities, not the precise flow of your cases with your states, rules and deadlines: it takes you to 80% and stops on the part that counts. It's worth evaluating, but if your work is managing cases with their rules, the generic is almost always too tight. If cases are marginal, instead, it can be enough.

**How do I see where cases get stuck?**
With the states: the owner sees how many cases are stuck in each state and for how long, and discovers where they pile up (the bottleneck). From there they intervene on the right point to shorten cycle time. Without states, you navigate blind; with states, you have an X-ray of the flow.

**How do you introduce it without stopping the office?**
One team or one case type at a time, not everything in a big bang. You model a pilot group's flow, put it into production, fix the real exceptions, and when it works you expand. Gradual rollout reduces risk and builds trust, instead of dropping the system on everyone hoping it works.

**How much do you gain by shortening cycle time?**
A lot: you close more cases in the same period with the same staff (more capacity without hiring), you cut the hours spent answering "where is it?" (often over €12,000 a year of time), and you don't lose clients to stuck cases and silence. Cycle time isn't an operational detail: it's directly money and clients.

## In one line

If your **cases** live in email, they stop in silence and nobody can answer «where is my case?», you're stretching **cycle time** — that is, losing money and clients. Email is a cable to communicate, not a place to make a flow live. Serious **case-management software** is a state machine: every case in a known state, with an owner, deadlines and attachments, status visible to the client (fewer calls) and to the owner (the bottlenecks). AI classifies and extracts; the decision stays human. And you introduce it one team at a time, not with a big bang.

If your cases bog down in email and you want a flow that moves, look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/): we start from your real flow — the actual states a case goes through at yours — not from a catalogue ERP.
