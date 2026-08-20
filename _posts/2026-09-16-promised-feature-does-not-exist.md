---
lang: en
permalink: /en/blog/promised-feature-does-not-exist/
alt_url: /it/blog/feature-promessa-non-esiste/
title: "Sales promised a feature the software doesn't have: how to close the gap before it costs you a client"
date: 2026-09-16 07:30:00 +0200
author: "Antonio Trento"
description: "Sales says 'yes, we do that' to close the deal, and the software doesn't do that thing. Now you have a client waiting on a promise and a team that knew nothing. How you close the gap between sales and product."
keywords: ["promised feature does not exist", "sales scope vs product", "dangerous customization", "saying no to the client", "software roadmap"]
image: /assets/images/posts/feature-promessa-non-esiste.jpg
pillar: comprare-software
related: [/en/blog/how-to-answer-software-rfi/, /en/blog/what-custom-software-includes/]
---

## The "yes, we do that" email

There's an email that, if you have software and someone who sells it, sooner or later arrives and makes your blood run cold. Sales sends it, all pleased, and it says roughly this: *"Great news, I closed client X! I told them the software also does [something the software doesn't do]. When can we have it ready?"*. In one line, sales has sold a feature that **doesn't exist**, committed the company to something nobody on the product team knew about, and put you in front of a fork where both roads lose: either you rush-build something that wasn't planned, or you tell a freshly acquired client they were promised a lie.

This is the **gap between sales and delivery**, and it's one of the most frequent and most underestimated pains of every company that has a software product — from software houses to SMEs with an internal product they sell to clients. Sales is paid and wired to **close**: their instinct is to say yes, because every yes gets the signature closer. The product team is responsible for **delivering**: their instinct is caution, because every yes is real work. When these two worlds don't talk, sales promises and product discovers the promises after the fact — and in the middle there's you, with a client waiting and a team that knew nothing.

The damage isn't just the single feature to rush-build. It's worse, and it's double. On one side, if you **don't** keep the promise, the client feels cheated the moment you've just won them — the worst way to start a relationship, and the fastest way to lose them before you've even served them. On the other, if you **keep** every promise by building everything sales sells, your product fills up with features made for one client only, the team is always in emergency, and the roadmap is decided by whoever shouts loudest instead of by a strategy. Both roads, walked long enough, hurt you.

This article is about how you close that gap — not with magic, but with **process and product**: how you say no in a way that strengthens the relationship instead of breaking it, how you tell the promise to throw away from the one that's worth it, how you put order between what you sell and what you build. Because the problem isn't having an enthusiastic salesperson: it's not having a way to turn their enthusiasm into commitments product can keep.

## The cost of a custom for a single client

Before talking process, you have to understand *why* saying yes to every promise is dangerous — because until you see it in its full gravity, you'll keep giving in "it's a small thing anyway". The point is the **real cost of a feature built for a single client**, which is much higher than it looks.

When you build a custom to please client X, you don't just pay the time to build it. You pay a long tail of hidden costs:

- **You build it once, you maintain it forever.** Every feature added to the product then has to be maintained, updated, kept compatible with everything else — even if only one client uses it. The cost of building is the tip of the iceberg; underneath is lifetime maintenance, as it is for [everything you add to software after go-live]({{ '/en/blog/software-maintenance-after-go-live/' | relative_url }}).
- **It complicates the product for everyone.** Every specific feature stuffed into the product makes it a bit more complex, a bit harder to use, a bit more fragile — for *all* clients, not just the one who asked for it. Client X's custom is a weight that clients Y and Z pay too, in the form of a more tangled product.
- **It slows everything else.** Time spent on a custom for one client is time *not* spent on what many people need. Every yes to the client who shouts is a silent no to everyone else and to the strategy.
- **It opens the door.** Once you've granted a custom to X, why not to Y? The "yes" becomes a precedent, and the product slides toward a heap of one-client-only features that's unmanageable.

The healthy rule you already know, and it's the 80/20 that always comes back: **the product lives on the 80% common to many; the 20% specific to one client, almost always, shouldn't be stuffed into the product.** A feature is worth building if it serves *many* clients (then it's real product, and that's right). If it serves *one only*, putting it in the product is almost always a mistake — and if it really has to be done, it has to be handled as a separate job, paid separately, and not passed off as "product evolution". The distinction between "this feature is the product" and "this feature is one client's whim" is the heart of everything, and I'll come back to it in a moment. But first you need the process so you don't find the promise already made.

## The process: how you say no, how you put it on the roadmap

The gap between sales and product doesn't close by hoping the salesperson becomes cautious. It closes with a **process**: an agreed way of turning what the client asks into a commitment product can keep — *before* the promise is made. The key is to move the moment of decision from "sales promises and product discovers" to "sales asks and together you decide".

How a healthy process works:

- **Sales doesn't promise features that don't exist. Period.** This is the base rule, and it has to be set clearly: in front of a request for something the product doesn't do, the salesperson's answer isn't "yes, we do that", but "**interesting, I'll check and get back to you**". It isn't commercial weakness: it's professionalism. A confident "I'll confirm by tomorrow" sells as well as a reckless "yes", and it doesn't land you in trouble.
- **There's a fast sales→product channel.** When a new request arrives, sales takes it to product *before* committing, and gets a quick answer: can it be done? does it serve many or one? how much does it cost? is it already planned? This exchange has to be fast — a salesperson can't wait a week to answer a hot client — but it has to exist. The speed of this channel is what makes the process livable.
- **The three possible answers.** To a request, product answers in one of three ways: **"it's already there"** (maybe sales didn't know — and that says product training is needed); **"it isn't there but it makes sense, we'll put it on the roadmap"** (it serves many, you schedule it with real timelines); **"it isn't there and we won't do it"** (it serves one only, or it goes against the product's direction). Sales, with this answer in hand, can tell the client something **true**.

The most delicate piece is **saying no to the client without losing them**, and it's an art that's worth the article. The no that breaks the relationship is the blunt and final one ("no, it can't be done"). The no that *strengthens* the relationship is the honest and constructive one: *"This specific thing the product doesn't do today, and I'll tell you the truth about why and what we can do instead."* Often behind the client's request there's a **need** the product already knows how to satisfy another way — and then the no to the feature becomes a yes to the need ("we don't do it exactly like that, but we solve your problem this other way, look"). A client almost always prefers a supplier who tells them the truth and proposes the real solution, to one who promises everything and then doesn't deliver. The same lucidity it takes [not to sign impossible promises in an RFI]({{ '/en/blog/how-to-answer-software-rfi/' | relative_url }}) is needed here, every day, on every request.

## When the feature really is the product (and it has to be built properly)

Watch out, though, not to flip the error. The message isn't "always say no to every new request": that would be another way of getting it wrong, the entrenched company that never evolves the product because "it wasn't on the roadmap". Sometimes the feature sales spotted while selling is **exactly what the product needs** — and recognising that is as important as knowing how to say no.

How do you tell the whim-request (one client only, to refuse) from the gold-request (the future of the product)? The criterion is always the same: **how many clients would benefit?**

- **If more clients ask for the same thing**, independently, the market is telling you it's a real product feature. In this case sales hasn't made a reckless promise: they've acted as an **antenna on the market**, they've heard before you where demand is going. That request should be taken in, put on the roadmap with priority, and built **properly** — not rushed for one client, but with care because it will serve many.
- **If only one person asks and nobody else**, it's probably specific to them: handle it as a separate custom (paid separately) or refuse it gracefully.

Sales, in a healthy company, isn't the enemy of product: it's a **valuable sensor** of what the market wants, because they're the ones in front of clients every day. The process I was talking about isn't there to shut them up — it's there to **separate signal from noise** in their promises. Requests that come back from more clients are signal, and they should be listened to so the product evolves in the right direction. Isolated requests are noise (for the product), and they should be handled without polluting it. A company that listens to sales *as an antenna* but decides with product's head *what to build*, has found the balance: it evolves the product toward what many need, without filling it with the whims of a few. When the feature really is the product, it has to be built seriously — with the right UI, the right data, the edge cases handled — not sketched to keep one client quiet.

## The frontend: expectations versus reality

There's a recurring technical reason why sales promises become delivery disasters, and it concerns the **frontend** — the face of the product. Sales, when they sell, shows and describes what the user *sees*: the screens, the buttons, the "then you click here and this happens". It's natural: it's the part you can show. But what you see is the tip of the iceberg, and sales, in good faith, promises on the tip while ignoring everything underneath.

The client hears "we'll add a button that does X" and imagines it simple — a button, exactly. Sales, thinking like the client, promises it as simple. But behind that button is all the invisible work that makes the thing function: what happens when you press it, where the data comes from, what happens if something goes wrong, who has permission to press it, what people without permission see. The distance between "the button you see" and "everything needed for that button to actually work" is huge — and it's exactly that distance sales doesn't see and therefore underestimates, promising in one sentence what is weeks of work.

This is the same phenomenon I describe in [what a serious frontend actually does]({{ '/en/blog/frontend-for-software-houses/' | relative_url }}): the happy path (the button that works when everything goes well) is 20% of the work; the 80% is the states, the errors, the permissions, the edge cases. Sales promises on the visible 20%; product has to deliver 100%, invisible 80% included. That's why a promise that to sales looks like "a little thing" to the product team looks like "a week of work": it isn't that the team exaggerates or makes it difficult — it's that they see the whole iceberg, while sales has only seen the tip. Closing this gap also means **educating sales** to understand that behind every visible thing there's invisible work, so their promises become more cautious and more true.

## The data and edge cases sales doesn't see

If the frontend is the visible iceberg that's underestimated, **data and edge cases** are the iceberg sales doesn't see at all — and they're the source of the most dangerous promises, the ones that look harmless and are actually chasms.

Sales reasons on the **pretty case**: the client enters the right data, everything is in order, the feature does its thing. And that's natural, because that's how you demonstrate something in a demo. But real software lives in the **ugly cases**, the ones sales doesn't even imagine:

- **Dirty data.** Sales promises "the system calculates X automatically". But X is calculated on the client's data, and the client's data is incomplete, inconsistent, in weird formats. The promised "automatic" feature actually requires enormous work to handle real data, which is never like in the demo.
- **Edge cases.** "And if two users do the same thing at once? And if the value is zero, or negative, or huge? And if a piece is missing?" These are the questions the product team asks and sales doesn't, because they have the linear flow of the sale in their head, not the thousand detours of reality.
- **Integrations with the client's systems.** "Yes, we integrate with your ERP" — an easy promise to say, that depends entirely on what that ERP exposes, how it's built, how collaborative it is. Sales promises the integration as if it were a tick; product knows it can be an abyss.

The point is that **sales doesn't see this part not from incompetence, but because it isn't their job** — and it doesn't have to become it. Their job is to understand the client and sell; product's job is to know where the dirty data and the edge cases are. The gap closes not by asking sales to become technical, but by running promises *through* whoever sees the invisible part *before* they become commitments. It's another reason you need someone with an overview — who understands data, backend and frontend — to act as a filter between what you sell and what you build: because they're the only one who sees the whole iceberg and can say "this promise costs ten times what it looks like".

## The root: often sales doesn't know the product

Before locking down processes and contracts, it's worth looking at a root of the problem almost nobody addresses: **many promises of features "that don't exist" are born because sales doesn't really know what the product does — or doesn't do.** Not from bad faith: from lack of knowledge. And this is, in a way, good news, because it's the easiest part to fix.

Think how many times product's answer to sales's request is **"but that thing is already there!"**. Sales promised to *build* a feature the product has always had, simply because they didn't know. In that case you don't have a scope problem or reckless promises: you have a **product training** problem. And the cost of not solving it is double and concrete:

- **On one side you promise (and maybe build) things you already had** — pure waste: weeks of development to redo something that existed, that could have been zero hours and a demo done well.
- **On the other you *don't* sell things the product does extremely well**, because sales doesn't know they're there and doesn't tell them. This is the biggest invisible cost: valuable features, already built and paid for, that don't generate an extra penny of revenue only because whoever sells ignores them. A product full of capabilities sales doesn't know is a warehouse of unused value.

Do the rough numbers: if a salesperson twice a year promises a "new" feature that was already there, and each one costs the team a few weeks of work redone for nothing, that's person-months a year thrown away — thousands of euros — to fill a knowledge gap that an afternoon of product training would have closed. And that's *without* counting the sales lost on features never told.

The cure is simple and underestimated: **sales has to actually know the product** — what it does, what it doesn't, and how you tell what it does. They don't need to become technical (we've said data and edge cases aren't their job), but they need an up-to-date map of the product's capabilities, so they sell what's there instead of promising what's missing. Keeping this map alive and shared — it's the internal training the company needs here too — is one of the most profitable and least-done investments: it reduces empty promises *and* increases sales of what already exists. Before process and contract, close the stupidest gap: the one of whoever sells without knowing what they sell.

## The contract: change requests

So far we've talked about internal process. But there's a tool that protects everyone — you, the team and the relationship with the client — and it has to go down in black and white: managing **change requests**, that is requests for change.

The principle is simple and liberating: **what's been agreed is agreed; what gets added afterwards is a change request, with its time and its cost.** Not to be rigid with clients, but to make explicit and manageable what otherwise becomes the bottomless hole of scope creep — that continuous swelling of "while we're at it" requests that eats the margin and wears the team out.

How it works, in practice:

- **You define what's included.** At the start, in black and white: the product does these things, the project includes these. It's the baseline against which you measure everything that comes after.
- **Every addition is a change request.** When the client (or sales on the client's behalf) asks for something beyond what was agreed, it isn't a "favour" to stuff in for free: it's a change request, which you evaluate (can it be done? how much does it cost? how long?) and agree separately. This *isn't* being hostile: it's being clear, and clarity protects the relationship more than unregulated generosity does.
- **The client decides with the costs in front of them.** Put this way, the request goes back to the client with a price and a time. Often the client themselves, seeing the cost, understands that thing isn't worth that much to them — and scope creep deflates on its own. Other times they really want it, they pay for it, and that's right.

The change request is the tool that turns the reckless "yes we do that" into an **honest conversation about costs**. It takes away from sales the temptation to promise for free (because they know every addition has a price tag) and gives the client control of their spend (because they decide what is worth adding). It's the same mechanism, from the builder's side, that protects the buyer when I explain [what has to be in a serious quote]({{ '/en/blog/what-custom-software-includes/' | relative_url }}): clear boundaries aren't enemies of the relationship, they're its foundation.

## The dashboard: promises versus backlog

I close with the tool that makes visible and governable everything we've talked about: a place where you see, at any moment, **what's been promised versus what's scheduled to be built.** Call it a dashboard, a backlog, a shared list: the name doesn't matter, what matters is that it exists and that sales and product look at it *together*.

What it has to show, and why you need it:

- **What's been promised to clients**, by whom and with what timelines. If promises live only in sales emails, scattered and invisible, product doesn't see them until it's late. Putting them in one place makes them governable.
- **What's scheduled to be built** (the roadmap, the backlog), with priorities. That way you see immediately whether a promise has a match in the plans or is hanging in the air.
- **The comparison between the two.** And that's the point: where promises and plans **don't match**, there's a gap to manage *before* it blows up. A feature promised to a client but not on the roadmap is a red alarm: either it goes on the roadmap (if it makes sense) or it gets renegotiated with the client (if it doesn't) — but immediately, not at a faded deadline.

This dashboard does for sales-product alignment what [a good management dashboard does for the owner]({{ '/en/blog/owner-dashboard/' | relative_url }}): it makes visible a problem that otherwise stays submerged until it does damage. The gap between promises and reality is invisible as long as promises sit in sales emails and plans sit in the product team's head. Putting them side by side, looking at them together regularly, is what turns "we discover the promises when it's too late" into "we see the misalignments in time to manage them". It's the last piece that closes the gap: first the process (promises go through product), then the contract (additions are change requests), finally the visibility (promises and backlog in the same picture).

If you live this pain — sales promising, product discovering, clients in the middle — the first step is to put the channel and the visibility in place between whoever sells and whoever builds. Look at the [projects I've built]({{ site.main_site }}/portfolio/) or [drop me a line]({{ site.main_site }}/contatti/) and we'll see how to close the gap in your case. All of this lives in the [buying (and building) custom software]({{ '/en/pillar/buying-custom-software/' | relative_url }}) cluster: because software lives or dies also by how those who sell it and those who make it stay aligned.

## It's for you if / it isn't for you if

**It's for you if:**
- you have **software and someone who sells it**, and you've already received the email "I told them we also do...";
- your product is filling up with **features made for one client only** that nobody else uses;
- the product team discovers **promises after the fact** and is always in emergency;
- you don't have a **channel** between sales and product to validate requests before committing;
- promises to clients live **scattered in emails**, with no place to compare them with the roadmap.

**It isn't for you if:**
- you're **on your own** selling and building: the sales-product gap doesn't exist (even if the risk of promising too much to yourself remains);
- you sell a **completely standard** product with never a change request: rare, but if that's you the topic barely touches you;
- your problem is that sales **doesn't sell enough**, not that it promises too much: it's the opposite, and it comes first.

## 8 questions from people living the sales-product gap

**1. How do I say no to a client without losing them?**
With an honest and constructive no, not a blunt one: "this specific thing the product doesn't do today, here's why and what we can do instead". Often behind the request there's a need the product already knows how to solve another way — and then the no to the feature becomes a yes to the need. The client prefers the truth with a solution to the promise you won't keep.

**2. Do I have to build every feature sales promises?**
No, and it's dangerous: a feature for one client only you build once and maintain forever, it complicates the product for everyone and slows the rest. The rule is 80/20: build what serves many, handle as a separate custom (paid separately) what serves one only.

**3. And if the request is actually a great idea for the product?**
Then sales has acted as an antenna on the market, and should be listened to. The criterion is: how many clients would benefit? If more clients ask for the same thing, it's a real product feature — it goes on the roadmap and gets built properly. If only one person asks, it's specific. Sales is a valuable sensor; the decision stays with product.

**4. Why does something that looks small to sales look huge to the team?**
Because sales sees the tip of the iceberg (the button, the screen) and promises on that; product has to deliver the invisible 80% as well: the states, the errors, the permissions, the dirty data, the edge cases. It isn't that the team exaggerates — they see the whole iceberg, which sales doesn't imagine.

**5. How do I put order between sales and product?**
With a process: sales doesn't promise features that don't exist, but takes them to product through a fast channel *before* committing. Product answers in one of three ways (it's already there / we'll put it on the roadmap / we won't do it), and sales tells the client something true. The speed of the channel is what makes it usable.

**6. What's a change request and why does it protect me?**
It's the handling of requests that arrive after what was agreed: what's been defined is defined, what gets added is evaluated and agreed separately, with time and cost. It isn't hostility: it's clarity. It takes away from sales the temptation to promise for free and gives the client control of spend — often scope creep deflates on its own when there's a price in front of it.

**7. How do I stop discovering promises too late?**
With one place — a dashboard, a shared backlog — where you see side by side the promises made to clients and what's scheduled to be built. Where they don't match, there's a gap to manage immediately. As long as promises sit scattered in emails and plans sit in the team's head, the misalignment is invisible until the damage.

**8. Is sales the problem?**
No: an enthusiastic salesperson is an asset, they're your antenna on the market. The problem is not having a way to turn their enthusiasm into commitments product can keep. The solution isn't to shut them up, it's to give them a process (to validate before promising), a contract (change requests) and visibility (promises versus backlog).
