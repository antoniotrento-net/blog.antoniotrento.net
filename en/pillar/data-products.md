---
layout: pillar
lang: en
permalink: /en/pillar/data-products/
pillar_key: prodotti-dati
section: software-su-misura
title: "Dashboards, KPIs & data decisions"
description: "Numbers scattered across six tools, late reports, gut-feel calls: how to get ONE dashboard and data products the owner actually opens."
image: /assets/images/pillars/prodotti-dati.jpg
alt_url: /it/pillar/prodotti-dati/
---

Your company's numbers exist. The problem is they live in six different places — ERP, e-commerce, spreadsheets, the bank, ads, people's heads — and none of those places talks to the others. So every simple question («how are we doing?») becomes a small investigation, and every important decision ends up being made on last month instead of yesterday. This guide collects the articles on how to turn those scattered data into **a dashboard and data products** the owner actually opens, every morning, in twenty seconds.

## It's not a software problem. It's a product problem

The temptation, facing this pain, is to buy a tool: Power BI, Looker, yet another dashboard «with AI». But the tool assumes the data are already clean, up to date and agreed upon — and they never are. The real work sits *under* the dashboard: agreeing on definitions, connecting the sources, keeping them alive, noticing when one breaks.

The difference that runs through this whole guide is a single one: **tool versus product**. A tool is powerful and generic, and someone has to configure it and keep it alive; when nobody does, it becomes the dashboard nobody opens anymore. A product does a few things, always, reliably: it opens on its own, the numbers are already there, and if something doesn't add up it tells you with an alert instead of showing you a wrong chart with a straight face. Every article below starts from this distinction.

## The four questions that matter

Before filling a screen with charts, the question is: *which decisions does this dashboard change?* A dashboard that doesn't change any decision is a poster. In most companies the questions that matter are four — are we selling enough, are we collecting what we sell, what's changing right now, where is the problem or the opportunity — and every metric should hook onto one of these. The rest is noise. The piece that opens this guide, [the dashboard the owner actually opens]({{ '/en/blog/owner-dashboard/' | relative_url }}), starts right here: from the Monday morning when nobody can answer, and from what the owner needs to see in twenty seconds.

## The symptoms (and the article that addresses them)

Every company arrives at this topic from a different symptom. Here are the most common ones, and where we treat them in depth:

- **«The report arrives on the 20th of the month»** — deciding well into the month is deciding on the past. The problem isn't the tool, it's the person who compiles by hand; and hiring a junior doesn't fix the sources. We talk about it in [how to have yesterday's numbers without hiring a data office]({{ '/en/blog/late-sales-report/' | relative_url }}).
- **«We decide by gut feel because the numbers are in six tools»** — the classic case, the cost of inertia in euros and how you build the screen: it's the [dashboard for the owner]({{ '/en/blog/owner-dashboard/' | relative_url }}).
- **«The dashboard is all green but the bank account is in the red»** — when you optimise the wrong metric: vanity metrics, KPIs that deceive, and how to redo the definitions. We talk about it in [wrong KPIs while the dashboard is green]({{ '/en/blog/wrong-kpis/' | relative_url }}).
- **«Three branches, three Excel files, I don't know which location is selling»** — the group consolidation, permissions by site, the common definitions nobody ever wrote down: it's the [multi-location dashboard]({{ '/en/blog/multi-location-dashboard/' | relative_url }}).
- **«We have the dashboards but nobody uses them»** — why self-service BI is a myth and what you actually need: the questions, not the charts. In [dashboards nobody uses]({{ '/en/blog/dashboards-nobody-uses/' | relative_url }}).
- **«Should I hire a data analyst?»** — why one person alone drowns in data cleaning and never gets to the product: you need a system, not just headcount. In [hiring a data analyst is not enough]({{ '/en/blog/hiring-a-data-analyst-is-not-enough/' | relative_url }}).

As the articles come out, you'll find them all listed at the bottom of this page.

## How it's built, in practice

The common thread of all this work is that a data product lives on two layers that have to be held together. Underneath, **the data layer**: taking the numbers from the sources, cleaning them, agreeing on what «sale» means (invoice issued? cash collected? VAT included? return booked against which date?), building the history, and putting in alerts that fire when a source changes. On top, **the interface layer**: the screen that opens in twenty seconds, the colours that are a language (green = don't think about it, red = today someone deals with it), the alert that reaches you without you asking.

When these two layers are done by two different vendors, they blame each other and you pay two invoices for a dashboard you don't use. That's why I insist on someone who does **data + backend + interface** together: the data definitions and the way you show them are the same decision.

And there's a piece that looks boring and is actually everything: **definitions have to be written down and signed**. «In our dashboard, sale = invoice issued, VAT excluded, return booked to the order date.» From that moment there is one number, and whoever disagrees argues about the definition, not the chart. Without the single number, the most beautiful dashboard in the world is just a more expensive way to argue.

## How to use this guide

If you're an owner or a director and you recognise yourself in one of the symptoms above, start from the article that describes *your* pain — you don't need to read them in order. If instead you're evaluating a project and want to understand what you're buying (and what's fluff), every piece includes cost estimates in euros, honest timelines and the «it's for you if / it's not for you if» section.

When you want to see what it would look like to solve it for real on *your* numbers, the starting point is the [project portfolio]({{ site.main_site }}/portfolio/) or two lines in [contacts]({{ site.main_site }}/contatti/): we start from the data you have, not from a demo.

Below you'll find all the articles in this guide.
