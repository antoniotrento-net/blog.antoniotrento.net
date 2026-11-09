---
lang: en
permalink: /en/blog/microsoft-365-vs-self-hosted-cost/
alt_url: /it/blog/microsoft-365-vs-self-hosted-costi/
title: "Microsoft 365 vs a self-hosted stack: what you spend in 3 years (licences, lock-in, and the exit nobody calculates)"
date: 2026-12-21 07:30:00 +0200
author: "Antonio Trento"
description: "For owners and finance managers: the real cost of Microsoft 365 over 36 months versus a self-hosted stack, with add-ons (Copilot, storage, backup), hidden costs, what self-hosted means for email, files and identity, what leaving 365 costs, a table for 10, 25 and 80 users, the hybrid route and when 365 remains the right choice."
keywords: ["microsoft 365 vs self hosted cost", "microsoft 365 cost sme", "office 365 vendor lock-in", "self hosted email alternative", "nextcloud vs sharepoint", "microsoft 365 tco"]
image: /assets/images/posts/microsoft-365-vs-self-hosted-costi.jpg
pillar: integrazioni-selfhosted
related: [/en/blog/docker-sme-sovereign-stack/, /en/blog/n8n-vs-zapier-vs-make-cost/]
---

## The licence that's "only 12 euros" for 20 people

The conversation always starts with a small number. "Microsoft 365 costs a dozen euros a month per person, it's nothing." For 20 people that's about €240 a month, less than €3,000 a year. Indeed it's not much, for email, documents, storage, video calls and an office suite everybody knows how to use.

Then the other items arrive. Backup, because the included one isn't enough to protect against deletions and ransomware. Advanced security, because someone clicked a phishing link. Extra space. Copilot, because the sales director saw it in a presentation. And time: who manages accounts, SharePoint permissions, shared folders nobody understands any more. After three years, "only 12 euros" has become a very different figure. And above all, all the company's documents, all emails and all identities sit in one place that's complicated to leave.

This piece does the maths of **Microsoft 365 versus a self-hosted stack** over three years, without ideological wars. For an owner or finance manager who wants to know what they really spend, how tied they are to the vendor, and what leaving would cost. With a table for 10, 25 and 80 users, a hybrid route that's often the most sensible, and the cases where 365 honestly remains the right choice.

## Is this for you?

It is for you if:

- your company uses Microsoft 365 (or is about to adopt it) and you want to understand the real cost over several years;
- you're worried about depending on a single vendor for email, documents and access;
- you're evaluating Copilot and the bill looks high;
- someone suggested you "bring everything in-house" and you want numbers before deciding.

It is not for you if you're looking for a technical installation guide to open-source alternatives: here we talk about costs and decisions. And it is not for you if your company is 3 people with one mailbox each: for you the answer is almost certainly "stay on a cloud suite and don't overthink it".

## What's included and what becomes an add-on (Copilot, storage, backup)

Microsoft 365 for business is sold in plans of increasing level (generally Basic, Standard, Premium for small and medium businesses, plus Enterprise plans). Prices change periodically — they've risen in recent years — and depend on annual or monthly commitment: think **roughly €6 to €25 per user per month** for business plans, and check the price list in force.

### What business plans usually include

- **Email** with generous mailboxes and shared calendar;
- **file storage** (personal OneDrive and SharePoint for shared sites);
- **Teams** for chat and video calls;
- **office apps** on web and mobile, and on higher plans desktop apps too;
- **identity** (accounts, single sign-on for Microsoft apps);
- on higher plans, more advanced **security and device management** features.

### List of typical add-ons

Here are the items most often added over time, which should be counted from the start:

1. **Copilot**: the AI assistant built into the suite, sold as a per-user add-on (in the order of **a few tens of euros per user per month**, with offers and bundles that change). It often costs more than the base licence.
2. **Third-party backup**: the suite stores data and has recovery features, but isn't designed as an independent long-term backup against deletions, ransomware or admin mistakes. Many companies add an external backup service, **€1–4 per user per month**.
3. **Advanced security**: threat protection, data loss prevention, conditional access. Included in higher plans, paid add-ons in lower ones.
4. **Extra storage**: more SharePoint space when the included space runs out, mailbox archiving.
5. **Telephony** (Teams Phone) and **meeting rooms**, if needed.
6. **Licences for shared or special mailboxes**, in some cases.
7. **Third-party tools** for email signatures, compliant archiving, printer management: often small subscriptions that add up.

The point isn't that add-ons are useless: many are genuinely needed. The point is that **the starting price isn't the steady-state price**.

## Hidden cost: time, integrations, "it's already there"

Beyond licences, there are costs that appear on no invoice.

**Admin time.** Creating and closing accounts, managing licences, groups, SharePoint and Teams permissions, devices, security policies. In an SME without IT, it's often done by an external supplier by the hour or an internal collaborator "good with computers". Either way it costs. And complexity grows: after three years, the structure of SharePoint sites and teams is often a maze nobody can explain any more.

**The "it's already there" effect.** Since Teams, SharePoint, Forms, Power Automate and the other tools are included, they get used even where they're not the best choice: a business process built on a shared spreadsheet and a few fragile automated flows, a document archive built on SharePoint folders without rules. It works, until it needs to integrate with the ERP or be moved. The cost comes later, as work to fix it.

**Integrations.** Connecting the suite to the ERP, CRM, website, production systems takes work. In the Microsoft ecosystem it's often simple for standard things and complicated for those specific to Italian companies (local ERPs, e-invoicing, PEC certified email).

**Dependence.** Email, documents, identity, chat, telephony in the same place means that a vendor decision (a price increase, a licence change, an outage) affects the whole company at once. It's not a cost paid every month: it's a risk that accumulates.

## Self-hosted: email, files, identity — pieces, not one monster

"Bringing everything in-house" is scary, and rightly so, if you picture it as one huge system to replace. In reality the self-hosted (or "sovereign", on European infrastructure under your control) stack is made of **independent pieces**, which can be chosen one at a time.

**Email.** It's the most delicate piece. Running your own mail server is possible, but delivery (not landing in recipients' spam), security and reliability require specific skills. For most SMEs the sensible choice isn't a mail server in the office, but a **European email provider** with a contract, or a solution managed by a partner. "Self-hosted" here means "under your contractual and geographic control", not necessarily "on your own server".

**Files and collaboration.** Solutions like Nextcloud (with integrated office suites such as Collabora or OnlyOffice) offer storage, sharing, document editing in the browser, calendars. They can run on an office server, on a server in an Italian data centre or with a European provider that manages them.

**Identity.** A single sign-on system (like Keycloak or Authentik) managing accounts for all applications: when a person joins or leaves the company, they're enabled or disabled in one place.

**Chat and video calls.** There are self-hosted or European alternatives (Matrix, Mattermost, Jitsi and others). They work, but it's the piece where users notice the difference with Teams most.

**Office suite.** The alternatives (LibreOffice locally, web suites integrated into file systems) cover daily work well; compatibility with complex Word and Excel files, macros and company templates is the point to check with the company's real documents.

The principle, described in the piece on the [sovereign Docker stack for SMEs]({{ '/en/blog/docker-sme-sovereign-stack/' | relative_url }}): **you don't need to replace everything**. You can choose the piece where control matters most and leave the rest where it is.

## Leaving 365: what it really costs (mailboxes, SharePoint, Teams)

It's the cost nobody calculates when they go in, and the one that decides how free you are afterwards. Leaving Microsoft 365 means moving four things, of very different difficulty.

**1. Mailboxes.** Migrating mailboxes (messages, folders, calendars, contacts) to another provider is a known operation, with dedicated tools. It costs in the order of **a few tens of euros per mailbox** between tools and work, plus planning the switch (DNS records, coexistence period). For 25 mailboxes, a few thousand euros.

**2. OneDrive and SharePoint files.** Copying files is easy; rebuilding structure, permissions and shares isn't. After years, SharePoint contains sites, libraries, versions, metadata and shared links pointing to Microsoft URLs. Migration requires deciding what to bring, how to reorganise it, how to redo permissions. It's the most expensive piece in time: from **several days to a few weeks** of work depending on quantity and mess.

**3. Teams.** Chats and channel conversations are the hardest to export in a usable form. In practice they're almost always archived (for retention obligations) and you start from scratch on the new platform. The real cost is in changing habits.

**4. Identity and integrations.** All applications using Microsoft login (ERP, CRM, third-party tools) must be reconnected to a new identity system. Each integration is a small project.

On top of this come **training** and **lost productivity** in the first weeks. An honest estimate for a 25-person company leaving 365 completely: **€15,000–40,000 between work and time**, highly variable with the accumulated mess. That's why it pays to calculate the exit **before** going in, and to keep order and rules along the way.

## Table: 10 / 25 / 80 users over 36 months (estimates)

Here's a three-year comparison, with declared assumptions. They're **estimates**: use the price lists in force and your supplier's labour cost.

**Assumptions:**

- Microsoft 365 at about €12 per user per month (intermediate business plan), external backup €2 per user per month, external administration at €400 a day;
- Copilot shown separately, for a share of users, at about €30 per user per month;
- self-hosted stack: email with a European provider (€3 per mailbox per month), files, collaboration and identity on a managed EU server, with initial setup and maintenance;
- 365 exit costs (see above) aren't included, to be added to the self-hosted scenario if starting from 365.

| Item (36 months, estimates) | 365 — 10 users | Self-hosted — 10 users | 365 — 25 users | Self-hosted — 25 users | 365 — 80 users | Self-hosted — 80 users |
|---|---|---|---|---|---|---|
| Licences / subscriptions | €4,300 | €1,100 (EU email) | €10,800 | €2,700 | €34,600 | €8,600 |
| Backup | €700 | included in server | €1,800 | included in server | €5,800 | included in server |
| Infrastructure (EU server, storage) | — | €1,400 | — | €2,900 | — | €7,200 |
| Initial setup | €500 | €6,000 | €1,000 | €10,000 | €2,000 | €20,000 |
| Administration / maintenance | €2,400 | €7,200 | €4,800 | €14,400 | €9,600 | €28,800 |
| **Total 36 months** | **€7,900** | **€15,700** | **€18,400** | **€30,000** | **€52,000** | **€64,600** |
| Copilot for 30% of users | +€3,200 | — | +€8,100 | — | +€25,900 | — |
| Equivalent internal AI (if needed) | — | +€4,000–8,000 | — | +€8,000–15,000 | — | +€15,000–30,000 |

What the table says, without beating about the bush:

- **For 10 and 25 users, Microsoft 365 costs less** than a complete self-hosted stack, even over three years. Complete self-hosting, at these sizes, is justified only by data-control reasons, not by savings.
- **At 80 users the gap narrows**: with Copilot on a third of users, the 365 total approaches that of a self-hosted stack with internal AI. At that point cost no longer decides: data control and the skills you have available do.
- **Maintenance is the deciding item.** Self-hosting doesn't cost in licences, it costs in people. If you already have someone (internal or partner) managing infrastructure, the maths changes a lot.
- **The exit cost** must be added to self-hosted if starting from 365: that's why a complete migration rarely pays for purely economic reasons.

## Hybrid: keep 365, take the critical data out

For most SMEs, the answer isn't "365 yes" or "365 no". It's **hybrid**: keep the suite for what it does well (email, calendar, office documents, video calls) and take out, or keep out, the critical data and processes.

### Criteria for hybrid

A piece of data or a process deserves to sit outside 365, under your direct control, when:

- **it's the heart of the company**: project archive, technical documentation, contracts, client data that's the real asset;
- **it has specific obligations**: compliant retention, health data, minors' data, industrial secrets with contractual clauses;
- **it must integrate with non-Microsoft systems**: ERP, production, Italian systems (e-invoicing, PEC);
- **it risks lock-in**: processes built on suite tools that would be expensive to rebuild elsewhere;
- **it needs AI on the data**: if you want an assistant on company documents with data in-house, it makes sense for those documents to sit on a system you control, as described in the piece on the [internal ChatGPT for SMEs]({{ '/en/blog/internal-chatgpt-self-hosted-company/' | relative_url }}).

And data can happily stay in 365 when:

- it's **daily work** that changes often (drafts, working documents, presentations);
- it's **communication** (email, calendar, chat);
- it **has no special** retention or integration requirements.

Three rules make hybrid sustainable:

1. **Independent backup** of what stays in 365, on a non-Microsoft system.
2. **Order rules** on SharePoint and Teams from the start (who creates sites, how they're named, who's responsible), so a possible future exit isn't archaeology.
3. **Identity under control**: even if you use Microsoft accounts, document which applications depend on them.

## A concrete case: a 25-person engineering firm

A design firm with 25 people, on Microsoft 365 for five years. Annual licence spend about €3,600, plus an external supplier for administration. The reseller's proposal: move to the higher plan for security and add Copilot for everyone, with roughly a threefold increase.

**The analysis.** Email, calendars and Teams work well and people are used to them: there's no reason to change them. The real problem is the project archive: 2 TB of drawings, reports and documents on SharePoint, with a structure that grew without rules, inconsistent permissions, and some clients (public bodies, large commissioning clients) asking for precise guarantees on where their documents are. And interest in AI is mainly about "searching past projects".

**The choice.** Hybrid. Email, calendars, Teams and working documents stay on 365, on the current plan with a security add-on for the functions really needed. The archive of closed projects moves to a file system on the firm's European server, with a per-job structure and group permissions, independent backup. On top of the archive, an assistant that searches past projects citing sources, with the model on European infrastructure. Copilot is switched on for 5 people (management and finance), not 25.

**The result.** Annual spend rose much less than the initial proposal, the project archive is finally tidy and under control, there are clear answers to clients on document location, and an exit from 365 is much simpler if one day it's needed.

## What breaks after a few years (either way)

Both Microsoft 365 and a self-hosted stack age badly if nobody looks after them. The typical problems, in fairness, on both sides.

**With Microsoft 365:**

- **SharePoint and Teams become a maze.** Every project created a team, every team has a site, permissions were given "by hand" for years. After three years nobody knows who sees what. Remedy: rules on who creates teams and sites, annual permission review, archiving closed teams.
- **Licences don't follow people.** Active licences for people who left, high plans assigned to people who only use email. Remedy: quarterly licence review, tied to staff joiners and leavers.
- **The price changes.** List price increases and package changes arrive with little notice and affect all users together. Remedy: keep the three-year cost estimate and exit cost up to date, so you always have a measured alternative.

**With a self-hosted stack:**

- **Updates get postponed.** The system works and nobody wants to touch it; after a year it's several versions behind, with known security problems. Remedy: scheduled updates, with a test environment.
- **The backup isn't tested.** It exists, runs every night, but nobody ever tried restoring it. The day it's needed, a piece is missing. Remedy: a restore test every three months.
- **The person who knew leaves.** The system was built by a technician or partner who's no longer around, and documentation is thin. Remedy: mandatory minimum documentation and at least two people (or a contract) who know how to manage it.
- **Users find shortcuts.** If the new file solution is less convenient, people go back to emailing attachments or using personal services. Remedy: ask users what doesn't work in the first weeks, and fix it.

The moral is the same: neither path is "install and forget". The cost of care belongs in the calculation either way.

## When 365 remains the right choice

It needs saying clearly, because there's a lot of rhetoric around:

- **Small companies** (under 15–20 people) without IT: the cloud suite costs little, works well and doesn't require managing servers. Control is obtained with a good external backup and some order.
- **Companies that work a lot with Microsoft-based clients and suppliers**: exchanging complex documents, Teams meetings, frequent sharing. Compatibility is worth a lot.
- **Companies with nobody to manage infrastructure**, neither internal nor a reliable partner: self-hosting without maintenance is a bigger risk than vendor dependence.
- **When there's no critical data**: if the company has no particular document asset or specific obligations, the control advantage is small.

In these cases, the right move isn't leaving: it's **using the suite well**, with independent backup, order rules, the right licences (not the highest for everyone) and add-ons chosen for those who really need them.

## 30/60/90-day path

**First 30 days — snapshot**

- list of active licences, plans, add-ons and real costs over the last 12 months;
- list of what's in SharePoint and Teams, and which applications use Microsoft login;
- check the backup: is there an independent backup? Has a restore ever been tested?

**Days 30 to 60 — optimisation**

- the right licences for the right people (not everyone needs the highest plan);
- add-ons only for those who use them (Copilot on a pilot group, not everyone);
- independent backup active;
- order rules on sites and teams.

**Days 60 to 90 — hybrid decision**

- identify critical data according to the criteria above;
- if needed, plan moving that data to a system under your control;
- calculate the exit cost to have a real number, even if you don't intend to leave.

## 3 beginner mistakes that cost money

**1. Buying Copilot for everyone.** An add-on costing more than the base licence, switched on for the whole company "to see". After three months a third of people really use it. Start from a pilot group, measure use, extend only where needed.

**2. Considering backup "included".** The suite's recovery features aren't an independent backup. The day an admin account is compromised, or ransomware encrypts synced files, or someone deletes a site by mistake, the difference between having and not having an external backup is the difference between a day of work and a disaster.

**3. Migrating everything out to save money.** With 10 or 25 people, leaving 365 completely for economic reasons almost never pays: exit cost and maintenance exceed the licence saving. You leave for control reasons, on specific pieces, not on principle.

## When NOT to do it (the complete migration)

- when the company is small and has nobody to manage infrastructure;
- when the reason is only licence cost, without having calculated maintenance and exit;
- when daily work depends on intensive exchanges with clients and suppliers on Microsoft;
- when you're in the middle of other big changes (ERP, organisation, premises).

## Practical checklist

- [ ] I know the real cost of 365 over the last 12 months, add-ons included.
- [ ] Each person has the right plan, not the highest by default.
- [ ] Add-ons (Copilot included) are active only for those who really use them.
- [ ] There's a backup independent of Microsoft, with a tested restore.
- [ ] There are order rules for SharePoint and Teams (who creates, how it's named, who's responsible).
- [ ] I know which applications depend on Microsoft login.
- [ ] I've identified critical data according to the hybrid criteria.
- [ ] I have an estimate of the exit cost, even if I don't intend to leave.
- [ ] If I'm evaluating self-hosting, I've counted maintenance, not just licences.

## The verdict

The **Microsoft 365 versus self-hosted cost** comparison has no absolute winner. For small companies, 365 costs less than a complete self-hosted stack even over three years, because self-hosting is paid in people, not licences. As users and add-ons grow — Copilot for everyone above all — the gap narrows, and the risk of depending on a single vendor weighs more.

The sensible answer, for most SMEs, is hybrid: keep the suite for communication and daily work, with licences and add-ons chosen for those who need them and an independent backup; keep under your own control the data that is the company's real asset or that has specific obligations; and calculate today what leaving would cost, so as not to find out the day it's needed.

If you want to do the real maths on your suite and understand which data it pays to keep under your control, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on integrations and self-hosted systems are in the guide on [ERP integrations and self-hosted systems]({{ '/en/pillar/erp-integrations-selfhosted/' | relative_url }}).

## FAQ

### What does Microsoft 365 really cost an SME?

Business plan licences range roughly from about €6 to about €25 per user per month, depending on the plan and price list in force. To the real cost you must add external backup, any advanced security features, extra storage, add-ons like Copilot and admin time. Over three years, the total is often much higher than the starting price.

### Is it worth moving from Microsoft 365 to a self-hosted stack?

For purely economic reasons, rarely in small companies: with 10 or 25 users, setup and maintenance of a self-hosted stack exceed the licence saving. It pays for reasons of data control, specific obligations or vendor dependence, often on specific pieces rather than everything.

### What does it cost to leave Microsoft 365?

It depends on the quantity and order of data. Mailboxes migrate at contained cost per mailbox; SharePoint and OneDrive files require rebuilding structure and permissions; Teams chats are usually archived; integrations with Microsoft login must be redone. For a 25-person company, an indicative estimate is between €15,000 and €40,000 between work and time.

### Is Copilot worth its price?

It depends on use. It costs per user, often more than the base licence, and its value depends on how much people really use it and how tidy the documents it works on are. It's worth switching it on for a pilot group, measuring use and extending it only where needed.

### Is the backup included in Microsoft 365 enough?

The suite's retention and recovery features aren't designed as an independent long-term backup. To protect against deletions, compromised accounts and ransomware, many companies add a backup on a non-Microsoft system, at an indicative cost of €1–4 per user per month, and periodically test restoring it.

### What does self-hosted mean for email?

Running your own mail server is complex in terms of delivery, security and reliability. For most SMEs, a European email provider with a contract, or a solution managed by a partner, makes more sense: control is contractual and geographic, not necessarily on your own server.

### Can Nextcloud replace SharePoint and OneDrive?

For storage, sharing and editing documents in the browser, solutions like Nextcloud with integrated office suites cover many SMEs' needs well. Compatibility with complex files, macros and company templates must be checked with real documents, and who manages the system must be considered.

### What is the hybrid approach between Microsoft 365 and self-hosted?

Keeping the suite for email, calendars, video calls and daily working documents, and moving under your own control critical data: project archives, contracts, documentation with specific obligations or that must integrate with non-Microsoft systems. With independent backup and order rules on what stays in the suite.

### When does Microsoft 365 remain the best choice?

For small companies with nobody to manage infrastructure, for those working intensively with clients and suppliers on Microsoft tools, and when there's no critical data or particular obligations. In these cases it pays to use it well: the right licences, targeted add-ons, independent backup and order.

### How do you reduce lock-in with Microsoft 365?

With an independent backup on a different system, order rules on SharePoint and Teams from the start, an up-to-date list of applications depending on Microsoft login, critical data kept on systems under your control, and a periodic estimate of the exit cost.
