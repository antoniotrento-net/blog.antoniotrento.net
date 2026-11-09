---
lang: en
permalink: /en/blog/n8n-vs-zapier-vs-make-cost/
alt_url: /it/blog/n8n-vs-zapier-vs-make-costi/
title: "Zapier or Make at €400 a month: when self-hosted n8n pays off (and when you're just shifting the problem onto IT)"
date: 2026-11-18 07:30:00 +0200
author: "Antonio Trento"
description: "An honest comparison for SMEs between Zapier, Make and self-hosted n8n: what you actually pay for, lock-in, privacy, who maintains the flows if you have no IT, 12-month TCO across three scenarios, ten typical automations, how to migrate without breaking anything and when to stay on Make or Zapier without shame."
keywords: ["n8n vs zapier vs make cost", "self hosted n8n sme", "zapier alternative", "no-code automation costs", "make.com pricing", "automation tco"]
image: /assets/images/posts/n8n-vs-zapier-vs-make-costi.jpg
pillar: automazione-da-dove
related: [/en/blog/no-code-limits-company/, /en/blog/self-hosted-n8n-openai-privacy/]
---

## The no-code bill that grows with tasks

At first it was twenty euros a month. One automation to copy contacts from the website form to the CRM, one to send a welcome email, one to post a chat alert when an order comes in. Then the automations became thirty, some run every five minutes, one syncs the warehouse with the e-commerce store, another generates delivery notes. One day the email arrives: "You've exceeded your plan's limit". You move up a plan. Six months later, the "automations" line in the accounts is worth €400 a month, sometimes more in peak months, and nobody knows exactly which flows are driving it.

That's when someone searches "n8n" on Google, reads that it's free if you install it on your own server, and proposes migrating everything. Sometimes it's a great idea. Sometimes it's a way to save €400 a month by spending €600 of IT time, with a server to keep running and updated thrown in.

This piece is an honest comparison of **n8n vs Zapier vs Make on cost** and on everything else that matters to an SME: what you're really buying, where the data ends up, who keeps the flows alive if you have no IT department, total cost over twelve months across three realistic scenarios, how to migrate without breaking anything, and when the right choice is to stay where you are.

## Is this for you?

It is for you if:

- you pay a Zapier or Make subscription and the figure grows every quarter;
- you have at least ten automations that, if they stop, someone notices;
- you're wondering whether "bringing everything in-house" really pays, and you want numbers, not opinions.

**It is not for you if**:

- you have five automations and spend less than €50 a month: the time you'd spend migrating is worth more than the saving;
- nobody in the company (nor a trusted supplier) has ever managed a server and you don't intend to pay someone to do it;
- your automations touch only US SaaS tools (CRM, email marketing, cloud spreadsheets) and you don't handle sensitive data: the privacy advantage of an in-house installation is small, because the data is already outside.

## What you're buying: connectors, runs, people

When you pay for an automation tool, you buy three different things, and it pays to separate them to understand the bill.

**1. Connectors.** The ability to connect one application to another without writing code: "when an email with an attachment arrives, save the file in a folder and create a record in the CRM". Zapier has thousands of ready connectors, Make hundreds of well-made apps, n8n a few hundred nodes plus a generic node to call any service with an API. For the most common tools all three cover almost everything. Differences emerge on niche software and Italian software (ERPs, e-invoicing, PEC certified email): often none of the three has a ready connector, and you go through an API anyway.

**2. Executions.** This is where the price difference lies, and it must be understood well because the three tools count differently:

- **Zapier** counts **tasks**: every action successfully executed in a flow. An automation with a trigger and five actions, running a hundred times a day, consumes about 500 tasks a day, 15,000 a month.
- **Make** counts **operations** (or credits, depending on the plan): every module executed, trigger included, consumes operations. The price per operation is generally lower than Zapier's tasks, but complex flows consume many.
- **n8n** in the cloud counts **executions** of the whole workflow, regardless of the number of steps; self-hosted, the community edition **has no execution limits**: you pay for the server, not the volume.

This difference explains almost everything. Flows with many steps that run often (syncs, polling, row-by-row processing of a file) are the ones that blow up the Zapier and Make bill, and the ones where self-hosted n8n pays off most.

**3. People.** It's the line that appears in no price list. Someone builds the flows, someone fixes them when a connected application changes, someone notices when they stop working. With Zapier and Make, part of this work (updating connectors, keeping the infrastructure up) is done by the provider. With self-hosted n8n, you do it, or you pay someone to.

The serious comparison isn't between Zapier's subscription and n8n's server cost. It's between **subscription + people** on one side and **server + people (more of them)** on the other.

## Zapier/Make: fast, expensive, data outside

Zapier and Make are excellent products, and that should be said before criticising them.

**What they do well:**

- you start in an afternoon, without installing anything;
- a sales manager or a sharp office worker can build a simple flow on their own;
- ready connectors maintained by the provider: when an application changes its APIs, they usually deal with it;
- no server to update, no backups to make, no certificates to renew.

**Where they hurt:**

- **the price grows with use**, and grows unpredictably. A badly written flow (too-frequent polling, a loop over a large file) can consume a month's budget in a day;
- **data passes through their servers.** Every email, order, record crossing a flow is processed by an external provider, often with infrastructure outside the European Union. For Italian clients' data you need an adequate data processing contract and a transfer assessment; for sensitive data, often, it's not the right path;
- **lock-in.** Flows built in Zapier don't export to Make or n8n: they're rebuilt. The more flows you have, the more it costs to leave, and the provider knows it;
- **limited debugging** on complex flows: when something goes wrong halfway through a long chain, understanding why is often harder than in a tool you control.

Between the two, **Make generally costs less than Zapier** for the same volume and handles complex flows better (branches, loops, data transformations), with a slightly steeper learning curve. Zapier is more immediate and has more connectors. For many SMEs, moving from Zapier to Make is already a significant saving, without touching servers.

## Self-hosted n8n: control, maintenance, learning curve

n8n is an automation tool with a visual interface similar to Make, which you can use in the cloud (managed by the German company that develops it) or install on your own server. The self-installed version is distributed under a "fair-code" licence: you can use it for free to automate your company's processes, with some limits if you want to resell it as a service to others. Some advanced features (managing several environments, integration with secret-management systems, finer access control) are in the paid editions.

**What it gives you:**

- **cost that doesn't grow with use**: a thousand or a hundred thousand executions a month cost the same, as long as the server copes;
- **data in-house**: flows run on your server, in the company or in a European data centre you choose; data doesn't pass through third parties, except towards the services the flows explicitly call;
- **flexibility**: when a connector is missing, a generic node calls any API, and when you need a bit of logic you write two lines of code inside the flow;
- **no vendor lock-in**: flows are files you export, version, move.

**What it costs you:**

- **a server to manage**: updates, backups, certificates, monitoring. It's not hard, but it must be done, and done consistently;
- **a steeper learning curve** than Zapier: n8n reasons in lists of data and expressions, and people coming from Zapier take a few weeks to feel at ease;
- **responsibility for failures**: when n8n stops at three in the morning, there's no company to open a ticket with (unless you have a contract with someone).

On one point in particular I want to be clear, because it's where I've seen the most damage: the **credentials encryption key** and **backups**. An n8n installation done in a hurry, without tested backups and without the key saved elsewhere, can lose all its credentials in one wrong restart. It's not a theoretical risk, and the piece on [n8n credentials and vaults]({{ '/en/blog/n8n-credentials-vault-infisical/' | relative_url }}) tells exactly how it happens and how to avoid it.

There's also an advantage of self-hosted n8n that numbers don't show well: when flows call AI models, you decide where data goes, even using models installed in-house. With cloud tools, the client's email passes through the automation provider *and* the model provider. The typical case is described in the piece on [self-hosted n8n and data privacy towards OpenAI]({{ '/en/blog/self-hosted-n8n-openai-privacy/' | relative_url }}).

## Who keeps it alive if you have no IT

It's the decisive question, and the one asked last. A self-hosted n8n installation needs someone who:

- applies updates (n8n releases them often, some important for security);
- checks that backups really work, by occasionally trying to restore them;
- notices when a flow fails (with an alerting system, not by looking by hand);
- fixes flows when a connected application changes;
- manages credentials when a person leaves the company or a token expires.

In hours, for a medium-complexity installation, that's **half a day to a day and a half a month**, plus emergencies. The realistic options for an SME without internal IT:

1. **An external partner with a maintenance contract**: a professional or a small company that installs, monitors, updates and intervenes. It's the most common path, and must be assessed as a fixed monthly cost.
2. **n8n in the cloud** instead of self-hosted: you lose the fixed-cost advantage and part of the control over data, but the provider manages the server. Pricing is tied to executions, not individual steps, so it's often still cheaper than Zapier.
3. **A trained internal person**, not necessarily an IT specialist: someone sharp in finance or sales, who builds the flows, with an external partner for server and updates. It's the combination that works best in companies where automations grow.

The option that **doesn't** work is "the owner's nephew installs it one Saturday". It works for three months, then the nephew has other things to do, and the company's flows run on a server nobody knows how to manage any more.

## 12-month TCO table across 3 scenarios (small, medium, peaks)

Here's the total cost over twelve months in three realistic scenarios. The figures are **estimates**, with declared assumptions: check the providers' current price lists (they change often) and adapt the hourly cost to your case.

**Common assumptions:**

- cost of a day of technical work (internal or external): €400;
- self-hosted n8n on a virtual server in a European data centre;
- migration is the work to rebuild existing flows in n8n;
- maintenance includes updates, backups, failure checks, small fixes.

**Scenario A — Small:** 10 simple automations, about 5,000 tasks a month.

**Scenario B — Medium:** 30 automations, some with many steps, about 50,000 tasks a month.

**Scenario C — Peaks:** 40 automations, strong seasonality (e-commerce, tourism), from 50,000 to 200,000 tasks a month in peak months.

| Item (12 months, estimates) | A — Zapier | A — Make | A — self-hosted n8n | B — Zapier | B — Make | B — self-hosted n8n | C — Zapier | C — Make | C — self-hosted n8n |
|---|---|---|---|---|---|---|---|---|---|
| Subscription / server | €600 | €250 | €120 | €5,400 | €1,800 | €300 | €10,800 | €3,600 | €480 |
| Initial setup | — | — | €400 | — | — | €1,600 | — | — | €1,600 |
| Flow migration | — | — | €800 | — | — | €2,000 | — | — | €3,200 |
| Maintenance | €200 | €200 | €1,200 | €800 | €800 | €2,400 | €1,200 | €1,200 | €3,600 |
| **Total year 1** | **€800** | **€450** | **€2,520** | **€6,200** | **€2,600** | **€6,300** | **€12,000** | **€4,800** | **€8,880** |
| **Total year 2** | **€800** | **€450** | **€1,320** | **€6,200** | **€2,600** | **€2,700** | **€12,000** | **€4,800** | **€4,080** |

What the table says, without beating about the bush:

- **In the small scenario, self-hosted n8n doesn't pay.** It costs more in the first year and in the second. Stay on Make (or Zapier, if you're happy with it) and reconsider when volumes grow.
- **In the medium scenario, the real comparison is with Make, not Zapier.** Moving from Zapier to Make halves spending without touching servers. Self-hosted n8n breaks even with Make from the second year: it pays if, at equal cost, you care about data control and no lock-in, not to save money.
- **In the peaks scenario, self-hosted n8n wins from the second year even against Make**, and above all removes unpredictability: the peak month costs the same as the others.

Two factors the table doesn't show that shift the decision:

- **data**: if flows process client, employee or patient data, the value of keeping it in-house can exceed any cost difference;
- **growth**: if automations are doubling every year, today's scenario isn't next year's. Over a three-year horizon, n8n's fixed cost becomes more attractive.

## 10 typical SME automations

To make the comparison concrete, here are ten automations I find in almost every SME, with the tool I'd choose thinking about cost and data.

1. **Contacts from the website to the CRM**, with a confirmation email. Few steps, low volume: fine anywhere.
2. **Internal chat notification for new orders or requests.** Trivial, medium volume: fine anywhere.
3. **Supplier invoices from PEC to the right folder and the ERP.** Sensitive data, connection to PEC mailboxes and Italian ERPs: self-hosted n8n.
4. **Warehouse sync between ERP and e-commerce.** Many steps, frequent, peaks: self-hosted n8n (or Make, watching consumption).
5. **Deadline and renewal reminders to clients.** Low volume, client data: cost-neutral, better in-house if the data is sensitive.
6. **Automatic weekly report** from ERP and CRM by email. Few steps, low volume: fine anywhere.
7. **Classification of incoming emails** with an AI model and routing to departments. Client data and model calls: self-hosted n8n, preferably with an in-house or EU model.
8. **Onboarding a new employee** (accounts, folders, notifications). Very low volume: fine anywhere, but watch personal data.
9. **Collecting reviews or feedback after a purchase.** Medium volume, low-sensitivity data: Make or Zapier are perfectly fine.
10. **Generating documents** (offers, delivery notes, contracts) from templates and CRM data. Many steps, commercial data: self-hosted n8n or Make.

As you can see, no tool wins everywhere. In companies with many automations, the best configuration is often **mixed**: simple, low-sensitivity flows stay on a cloud tool, those with sensitive data or high volumes move to n8n in-house.

## Migration: where to start without breaking flows

If you decide to migrate, the rule is one: **never all at once**. One flow at a time, with the old one on until the new one has proved it works. Here's the procedure I follow.

1. **Inventory.** List all active flows: what they do, how often they run, how many tasks they consume a month, who notices if they stop, what data they handle. Forgotten flows nobody uses any more often turn up: switching them off is the first saving.
2. **Classification.** For each flow: stays where it is, moves to n8n, gets switched off. Criteria: task consumption, data sensitivity, complexity.
3. **A properly done n8n installation**: server in the EU, automatic backups with a tested restore, encryption key saved off the server, protected access, failure alerts. This step isn't skipped to go faster.
4. **First test flow**: pick a low-risk but real one (for example the order notification in chat). Rebuild it in n8n.
5. **Parallel running** for one or two weeks: both flows run together, the new one in "check only" mode (it writes to a test location, or sends the notification to a single person). You compare results.
6. **Switch-over**: when the new flow has run without differences, switch off the old one (but don't delete it for a month).
7. **Repeat** starting from the flows that consume most tasks: they're the ones that pay back migration first.
8. **Cancel or downgrade** the old tool's plan only once the main flows are migrated and stable.

A pseudo-flow of the inventory, to understand what information to collect:

```text
Flow: "E-commerce orders → ERP"
  Current tool: Zapier
  Frequency: every new order (~80/day, peaks of 400/day in December)
  Steps: 7 (trigger + 6 actions)  → tasks/month: ~16,800, in December ~84,000
  Data: client's name, address, phone, amount, products
  Who notices if it stops: warehouse, within 2 hours
  Decision: migrate to n8n (high volume, client data, peaks)
  Priority: 1
```

What it means, line by line: how often the flow runs tells you how much it costs; steps times frequency give the month's tasks; the data tells you how sensitive it is; "who notices" tells you how quickly you must be able to step in if it breaks; decision and priority follow from the rest. With this sheet for every flow, migration becomes a list of jobs, not a leap in the dark.

## What breaks in production (with any tool)

Something automation sellers rarely say: flows break, whatever the tool. What changes is who notices and how long it takes. Typical failures are always the same, and it pays to know them before choosing.

- **Expired credentials.** A connected application expires the access token after 60 or 90 days, or the person who connected their own account leaves the company. The flow stops with an authorisation error. In Zapier and Make a warning email arrives (often landing in the inbox of someone who's gone); in n8n you need an alert you configure yourself. Common remedy: connect applications with company service accounts, not personal ones.
- **The application changes.** The CRM renames a field, the ERP updates its APIs, the e-commerce store changes its order format. The flow keeps running but writes wrong or empty data. It's the sneakiest failure, because it gives no errors: you find out when someone notices that new contacts have been arriving without a phone number for three weeks.
- **Limits of connected applications.** Many services limit requests per minute. A flow processing a large file or an order spike exceeds the limit, and the excess requests fail. Cloud tools handle some of these cases themselves; in n8n they must be planned in the flow (pauses, batch processing).
- **Double executions.** After an error, a flow is re-run and creates the same record twice, or sends the client the same email twice. It happens with every tool, and it's why flows that write important data must first check whether the data already exists.
- **Silent failures.** The flow doesn't start at all, because the trigger doesn't fire: the website form changed, the mailbox stopped receiving, the server was off. No error, no warning. The only remedy is a "reverse" check: an alert if a flow that should run every day hasn't run.

The difference between the tools, on this front, is in basic monitoring: Zapier and Make give you an execution history and some warnings without doing anything, self-hosted n8n gives you more powerful tools but you have to configure them. In all three cases, a person who once a week looks at failed flows and flows that didn't run is worth more than any automatic feature.

## 3 beginner mistakes that cost money or data

**1. Migrating everything in a weekend.** The temptation is "they're the same flows anyway". They aren't: each tool handles errors, delays and empty data differently. A flow that in Zapier silently ignored a missing field stops in n8n, or vice versa. Migrating everything together, on Monday morning you have ten broken flows and don't know where to start.

**2. Installing n8n without backups and without alerts.** The server works, the flows run, and nobody checks. The day the disk fills up or an update goes wrong, you find out there was no recent backup, or there was but nobody had ever tried restoring it. Worse: for weeks a flow failed silently, and data didn't arrive where it should.

**3. Comparing only the subscription price.** "Zapier costs €400, the n8n server €20: we save €380 a month." People's time is missing, and it's almost always the highest item. Doing the maths without maintenance is the fastest way to end up with a system that's cheaper on paper and dearer in reality.

## When to stay on Make/Zapier without shame

There's a certain technical rhetoric according to which "real professionals self-host everything". It's not true. There are situations where staying on Make or Zapier is the best choice, and it should be said clearly:

- **Low, stable volumes.** Below €100–150 a month, the saving doesn't justify a server to manage.
- **Nobody to maintain it.** If you have neither an internal person nor a partner with a contract, a self-hosted installation becomes a risk, not a saving.
- **Flows between cloud SaaS only.** If you connect the cloud CRM to cloud email marketing and a cloud spreadsheet, the data is already outside: bringing the middle piece in-house changes little for privacy.
- **Prototypes and trials.** To check whether an automation is really needed, building it in an hour on Zapier is perfect. If it proves its value and grows, you migrate it.
- **Non-technical people building on their own.** If the value lies in the sales manager building flows independently, Zapier's simplicity is worth the price.

And an intermediate option many don't consider: **moving from Zapier to Make** often cuts spending by half or more without any server, and is a good first step before deciding whether to go further. For a broader picture on when no-code tools start to feel tight, there's the piece on the [limits of no-code in a company]({{ '/en/blog/no-code-limits-company/' | relative_url }}).

## 30/60/90-day path

**First 30 days — understand and save without migrating**

- full inventory of flows with tasks consumed, data handled, criticality;
- switching off useless flows and optimising those that consume too much (less frequent polling, filters at the start of the flow);
- decision: stay, move to Make, go (partly) to n8n.

**Days 30 to 60 — prepare**

- if going to n8n: choose who maintains it (internal + partner, partner, cloud), a properly done installation, backups and alerts;
- migration of the first two or three low-risk flows, with parallel running;
- training the internal person who'll build flows.

**Days 60 to 90 — migrate the bulk**

- migration of the flows consuming most tasks and those with sensitive data;
- downgrading the cloud tool's plan;
- first check of real costs (server, maintenance hours) against estimates.

## When NOT to do it

Summing up the cases where migrating to self-hosted n8n is a bad idea:

- you spend less than €100–150 a month and volumes are stable;
- you have neither an internal person nor a partner taking responsibility for the server;
- the motivation is just "so we don't pay the subscription", without having counted the hours;
- flows connect only cloud services and don't handle sensitive data;
- you're in the middle of a peak period or an ERP change: migrate when things are calm.

## Practical checklist

- [ ] Flow inventory with tasks per month, data handled, who notices if they stop.
- [ ] Useless flows switched off, expensive flows optimised.
- [ ] 12- and 24-month maths done including maintenance hours, not just the subscription.
- [ ] Decision taken between: stay, move to Make, n8n cloud, self-hosted n8n, mixed configuration.
- [ ] If self-hosted: who maintains it is written down (person or contract), with response times.
- [ ] Server in the EU, automatic backups with tested restore, encryption key saved elsewhere, failure alerts.
- [ ] Migration one flow at a time, with parallel running before switch-over.
- [ ] Old plan downgraded only after the main flows are stable.
- [ ] Check of real costs at 90 days.

## The verdict

The **n8n vs Zapier vs Make cost** comparison has no absolute winner, and be wary of whoever sells you one. Zapier is the fastest and the most expensive, Make is often the best compromise for those who don't want servers, self-hosted n8n is unbeatable when volumes are high, data is sensitive and someone keeps it alive. Below a certain level of spending, bringing everything in-house just means moving the cost from the subscription to IT's time.

The right question isn't "which tool costs least", but "how much does each flow cost me, what data does it handle, and who takes care of it when it breaks". With a well-done inventory and maths that include people, the decision takes an afternoon. And often the answer is a combination: simple flows where they are, heavy or sensitive ones in-house, migrated one at a time.

If you're paying a growing automation bill and want to understand where it really pays to act, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on setting up automation in an SME are in the guide on [SME automation: where to start]({{ '/en/pillar/sme-automation/' | relative_url }}).

## FAQ

### Is n8n really free?

The community version to install on your own server is free for automating your own company's processes, with no execution limits. It's distributed under a "fair-code" licence that sets limits if you want to resell it as a service to others. Server costs remain and, above all, the time of whoever installs and maintains it. Some advanced features are in the paid editions.

### Why does Zapier get so expensive?

Because it counts tasks, i.e. every action executed in every flow. A flow with many steps that runs often consumes thousands of tasks a month, and plans grow in tiers. Sync, polling and row-by-row file-processing flows are the ones that drive spending up most.

### Does Make cost less than Zapier?

Generally yes, for the same volume, and it handles complex flows better. It counts operations (every module executed), so Make also becomes expensive with very long, frequent flows. For many SMEs, moving from Zapier to Make is a significant saving without having to manage a server.

### When does it pay to move to self-hosted n8n?

When automation spending exceeds a few hundred euros a month or has unpredictable peaks, when flows handle client or employee data that is better kept in-house, and when there's an internal person or partner looking after the server. Below €100–150 a month, with stable volumes, it usually doesn't pay.

### Who maintains n8n if the company has no IT department?

The realistic options are an external partner with a maintenance contract, n8n in the cloud managed by the provider, or a trained internal person who builds the flows supported by a partner for server and updates. It takes half a day to a day and a half a month, plus emergencies.

### How much does migrating from Zapier to n8n cost?

It depends on the number and complexity of flows. For about thirty automations, between a properly done installation and rebuilding the flows, we're talking roughly 5–10 days of technical work. The cost is recovered in months or years depending on how much you spent on the subscription: with low volumes, sometimes it's never recovered.

### Is data safer with self-hosted n8n?

It can be, because flows run on a server you control, in the company or in a European data centre, and data doesn't pass through the automation tool's provider. But security depends on how the server is managed: updates, access, backups, credentials. A neglected installation is less secure than a good cloud service.

### Can Zapier and n8n be used together?

Yes, and it's often the best solution in companies with many automations: simple, low-sensitivity flows stay on a cloud tool, those with high volumes or sensitive data move to n8n in-house. What matters is having a clear inventory of what runs where.

### How do you migrate without stopping automations?

One flow at a time. You rebuild the flow in n8n, run it in parallel with the old one for one or two weeks in check mode, compare results and only then switch off the old one, without deleting it for a month. Start with low-risk flows, then those consuming the most tasks.

### Which automations should an SME do first?

Those that save time every day and have clear rules: contacts from the website to the CRM, order notifications, routing invoices from PEC, deadline reminders, automatic reports. Automations with artificial intelligence, such as email classification, come later, when the basics work.
