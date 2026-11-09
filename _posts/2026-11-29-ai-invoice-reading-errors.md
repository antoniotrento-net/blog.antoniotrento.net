---
lang: en
permalink: /en/blog/ai-invoice-reading-errors/
alt_url: /it/blog/ai-lettura-fatture-errori/
title: "AI that reads invoices: 7 cases where it gets VAT wrong (and how not to be fooled by \"99% accuracy\")"
date: 2026-11-29 07:30:00 +0200
author: "Antonio Trento"
description: "For owners and finance staff evaluating software that reads invoices with AI: why the Italian e-invoice XML comes before the PDF, the 7 classic VAT errors (split payment, reverse charge, stamp duty, rounding, similar names, foreign invoices, wrong attachment), what a person must check, how to measure and what it costs."
keywords: ["ai invoice reading errors", "electronic invoice ocr", "pdf invoice data extraction", "ai accounting", "xml vs pdf invoice", "supplier invoice automation"]
image: /assets/images/posts/ai-lettura-fatture-errori.jpg
pillar: documenti-fatture-ai
related: [/en/blog/document-extraction-field-accuracy/, /en/blog/imap-pec-invoice-agent/]
---

## The vendor promising 99%

The presentation is always convincing. "You upload invoices, our artificial intelligence reads them, extracts supplier, amounts, VAT and due dates, and posts them in the ERP. 99% accuracy." Then a demo on ten clean invoices, all correct. The finance team, which spends hours every week posting supplier invoices, starts to hope.

Three months later, the accountant calls: the quarter's VAT settlement doesn't add up. Digging in, out come an invoice to a public body posted as if we had collected the VAT, two foreign invoices with Italian VAT calculated on top, a €2 stamp duty that ended up in the taxable amount, and a handful of cents that don't reconcile across dozens of documents. Nothing catastrophic, taken one by one. Taken together, a day's work to fix and some embarrassment.

If you're evaluating software that uses **AI to read invoices**, this piece will help you not be fooled by the number on the slide. We're not talking about technology but about **money and VAT**: why in Italy the XML e-invoice comes before any "smart" reading of the PDF, the **7 classic errors** an automated system makes on VAT, what a person must keep checking, how accuracy is really measured, and what all this costs compared with the finance clerk's hours.

## Is this for you?

It is for you if:

- you're the owner, finance manager or accountant of an SME that receives from a few dozen to a few thousand supplier invoices a month;
- you're evaluating (or have already bought) software that "reads" invoices with AI;
- you want to understand where automation really saves time and where it creates extra work for the accountant.

It is not for you if you're looking for a technical comparison of OCR engines or models: the point here is accounting. And it is not for you if you receive ten invoices a month: posting them by hand costs less than any project (but read the section on the 7 errors anyway: they apply to manual posting too).

## E-invoices: the XML already exists, the PDF is plan B

The first thing to know, and the one many sellers keep quiet about: in Italy **almost all invoices between domestic businesses are electronic**, in XML format, and pass through the national exchange system (SDI). Since 2024 the obligation covers flat-rate taxpayers too. That means for the vast majority of your supplier invoices **the data is already structured**: supplier, VAT number, taxable amount, rates, the nature of exempt operations, VAT chargeability, due dates, IBAN, stamp duty. Precise fields, written by the supplier, signed and transmitted.

Reading that data from a PDF with AI, when the XML exists, is like photographing an Excel sheet and then asking a system to copy the numbers from the photo. It can work, but it introduces errors that weren't in the original.

### The XML-first flow, explained to a finance clerk

1. **Invoices arrive from the SDI** at your receiving channel: the tax portal, the accountant's software, the intermediary, or a PEC certified mailbox. In every case the "real" file is the XML (sometimes signed, with a `.p7m` extension).
2. **The software reads the XML**, not the PDF. Every piece of data has its field: nothing to "guess". The courtesy PDF, if any, is only for viewing.
3. **Automatic checks** on the data read: does the VAT number match a supplier in master data? Do the line totals match the VAT summary? Is there a special chargeability (split payment)? Is there an exemption nature or reverse charge?
4. **A proposed entry** in the ERP, with the account, VAT code and due date.
5. **Only for documents without XML** — foreign invoices, receipts, documents not passing through the SDI — does AI reading of the PDF come into play, and these documents **always** go to review.

If a piece of software proposes reading Italian e-invoices too with AI, starting from the PDF, the question to ask is: "**why don't you use the XML?**". If the answer is vague, you've learnt a lot about the product.

## 7 classic VAT errors

These are the errors I see most often in systems that read invoices automatically. Some come from reading the PDF, others from automatic posting even when data is read correctly from the XML. All end up, sooner or later, on the accountant's desk.

### Table of the 7 errors

| # | Error | What happens | How to avoid it |
|---|---|---|---|
| 1 | **Split payment** | On invoices to public bodies and some companies, the customer pays the VAT to the Treasury, not the supplier. If the system treats it as ordinary VAT, the settlement is wrong | Read the chargeability field from the XML; a specific rule in the ERP |
| 2 | **Reverse charge** | The invoice shows no VAT, but has a "nature" that requires adding it. The system posts the taxable amount without VAT and forgets the integration | Read the operation's nature from the XML and apply the right VAT code |
| 3 | **Stamp duty** | The €2 stamp duty on exempt invoices above a threshold ends up in the taxable amount or the VAT | Stamp duty field read from the XML and posted separately |
| 4 | **Rounding** | Line total and VAT summary differ by a few cents; the system "adjusts" at random or picks the wrong value | Use the XML's VAT summary as the source; flag differences instead of correcting them |
| 5 | **Supplier with a similar name** | Two suppliers with similar names; the invoice ends up on the wrong record with the wrong IBAN and accounts | Associate by VAT number, never by company name |
| 6 | **Foreign invoice** | A PDF invoice from an EU or non-EU supplier: the system reads "VAT 19%" and posts Italian VAT, or doesn't handle the integration | Always reviewed; rules for intra-EU and non-EU purchases; integrative documents via SDI where required |
| 7 | **Wrong attachment** | The attached PDF doesn't match the XML (pro forma, credit note, a different month's document); the system reads the PDF and ignores the XML | XML as the single source; the PDF only for viewing; consistency check between the two |

### The seven cases, one by one

**1. Split payment.** When you invoice (or receive invoices) under the split-payment regime — typical towards public bodies and some listed or controlled companies — the VAT shown on the invoice isn't collected by the supplier: the customer pays it directly. The XML has a field saying so (VAT chargeability). If the system reads only "taxable 1,000, VAT 220, total 1,220" from the PDF and posts it as an ordinary invoice, payments and settlement go wrong. From the PDF, by eye, the difference often isn't visible.

**2. Reverse charge.** In many cases (construction subcontracting, certain sectors, purchases from abroad) the invoice arrives without VAT, indicating a "nature" that signals reverse charge. The recipient must add the VAT and post it in both purchases and sales. A system that reads "VAT 0" and posts a purchase without VAT has done 50% of the job, and the remaining 50% is the part that matters for tax.

**3. Stamp duty.** On exempt or non-taxable invoices above a certain threshold (€77.47) a €2 stamp duty applies, often charged to the customer. The XML has a dedicated field. From the PDF, the "2.00" appears as an extra line, and the system may add it to the taxable amount or, worse, treat it as VAT.

**4. Rounding.** The total computed by summing lines and the total of the VAT summary can differ by one or two cents, depending on how the supplier rounds. It's normal. The problem arises when the system "corrects" by itself, picking a value at random, or when, reading the PDF, it confuses a line total with the document total. A cent per invoice, across a thousand invoices, is a mismatch someone will have to explain.

**5. Supplier with a similar name.** "Rossi S.r.l.", "Rossi Impianti S.r.l.", "Rossi & Figli": if the system associates the invoice with a supplier based on the name, sooner or later it gets it wrong. And when it does, the invoice inherits the other supplier's IBAN, payment terms and ledger account. The only reliable identifier is the **VAT number**, verified with its check digit and looked up in master data.

**6. Foreign invoice.** A German supplier sends a PDF with "MwSt. 19%" or "VAT 0% — reverse charge". A system reading the PDF doesn't know that for an intra-EU purchase of goods or services Italian VAT must be added by the customer, nor that since 2022 these purchases are reported through integrative documents sent to the SDI. Foreign invoices are the case where AI reading is genuinely useful (there's no XML), but they're also the ones that must **always** be checked by a person.

**7. Wrong attachment.** The e-invoice arrives with a PDF attached. Sometimes the PDF is the courtesy copy; sometimes it's a pro forma, a quote, a credit note, a document from another month. If the system reads the attachment instead of the XML, it posts a document different from the one that's valid for tax. Simple rule: **the XML is the document, the rest is garnish**.

## What the human must do, and above which threshold

No system should post all invoices automatically. The right question is: **which invoices can go through without a person looking, and which can't?**

Invoices that can go through automatically (with a spot check) are those meeting **all** of these conditions:

- they arrive as **XML from the SDI** and data is read from the XML;
- the supplier is **already in master data**, associated by VAT number;
- the IBAN is **the same already registered** for that supplier;
- there are no special natures (split payment, reverse charge, exemptions) **or** there are but a rule for that supplier has already been verified;
- totals **reconcile** (lines, VAT summary, document total);
- the amount is **below a threshold** set by finance (for example €5,000).

Everything else goes to **review**, with the reason highlighted:

- foreign invoices and documents without XML;
- new suppliers;
- IBAN different from the registered one (note: it's also the typical sign of fraud);
- first invoices with special natures;
- differences in totals;
- amounts above the threshold.

On these invoices AI remains useful: it prepares the data, proposes the entry, highlights what doesn't add up. But a person decides. The typical ratio, in companies where I've seen these systems work, is 60–80% of invoices automatic and 20–40% in review. If a vendor promises 100% automatic, they're promising that nobody will ever look at foreign invoices and changed IBANs.

## How to measure field by field (VAT is worth more than the address)

The famous "99% accuracy" must be dismantled with one question: **99% of what?** Often it's the percentage of characters read correctly, or the average over all fields of all invoices. In that average, the street name and postcode count as much as VAT and IBAN. But a wrong postcode costs nothing; wrong VAT costs a settlement to redo.

### An honest definition of accuracy

For a finance team, the accuracy that matters is measured like this:

- **per field**, separately: VAT number, taxable amount, VAT, total, nature/chargeability, due date, IBAN, document number and date;
- **with zero tolerance on amounts**: a one-cent difference is an error;
- **weighted by the cost of error**: VAT and IBAN weigh ten times the address;
- **by document type**: Italian e-invoices, foreign invoices, scanned documents, separately. 99% on the first and 70% on the second make an average that describes neither;
- **on a sample of your own real invoices**, not the demo's ten: at least a few hundred, chosen among large and small suppliers, Italian and foreign.

And the most important question: **among invoices processed automatically, how many had an error?** That's the number that tells you how much risk you're accepting. It's measured by spot-checking, every week, a small share of automatically posted invoices.

The full method — weights, tolerances, samples, confidence intervals — is described in the piece on [field-level extraction accuracy]({{ '/en/blog/document-extraction-field-accuracy/' | relative_url }}). Here it's enough to remember: **ask for per-field numbers, on your documents, with VAT at the top of the list**.

## Integration with the ERP: not another silo

A frequent mistake is buying software that reads invoices beautifully but lives on its own: one more portal, where invoices are "processed" and then exported to a file someone imports by hand into the ERP. You've added a step, not removed one.

Before choosing, check:

- **where it gets invoices from**: it must connect to your receiving channel (tax portal, intermediary, PEC), not ask you to upload them by hand;
- **where it posts them**: it must write to your ERP (or the accountant's software), with the chart of accounts and VAT codes you already use;
- **what it uses as master data**: it must use the ERP's supplier master data, not create its own that then drifts;
- **how it handles corrections**: if the clerk corrects an entry in the ERP, the system should "learn" the rule for that supplier, or at least not repeat the error;
- **who sees what**: invoices contain supplier and client data; the system must process it under an adequate contract and preferably in the EU.

If invoices arrive by PEC, an agent that reads the mailbox and sorts documents can be the first piece of the flow: I described it in the piece on the [agent that reads PEC and invoices]({{ '/en/blog/imap-pec-invoice-agent/' | relative_url }}).

## Costs: clerk hours vs licence vs errors

Let's do a realistic calculation for an SME receiving **400 supplier invoices a month**, of which 340 Italian e-invoices and 60 foreign or without XML. The figures are **estimates**.

| Item | Without automation | With XML-first automation + AI on the rest |
|---|---|---|
| Average time per Italian invoice | 3–4 minutes | 0.5 minutes (spot check) + review for 20–30% |
| Average time per foreign / non-XML invoice | 6–8 minutes | 3–4 minutes (review with pre-filled data) |
| Hours per month | 25–30 hours | 8–12 hours |
| Cost of time (at €30/hour) | €750–900/month | €240–360/month |
| Licence / service | — | €100–400/month (by volume and vendor) |
| Setup and ERP integration | — | €2,000–8,000 one-off |
| VAT errors to fix | depends on the person | few, if rules are right; many, if the system reads PDFs and has no review |

The net saving, in this scenario, is in the order of a few hundred euros a month plus time freed for higher-value work. Not a revolution, a good investment. But the saving disappears, and turns into a cost, if the system introduces VAT errors the accountant has to find and fix at the end of the quarter: an hour of the accountant costs more than an hour of the clerk, and an error in the settlement costs more than both.

## A concrete case: a week of supplier invoices

To see how it really works, let's follow a typical week at a trading SME receiving about 100 supplier invoices a week (the numbers are a realistic example, not a specific case).

**Monday morning.** Over the weekend the system downloaded 22 e-invoices from the receiving channel and 3 PDFs arriving by email from foreign suppliers. Of the 22 e-invoices, 17 go through automatically: known suppliers, unchanged IBANs, totals reconciling, no special natures or rules already verified. They're proposed as posted in the ERP. The other 5 go to review: a new supplier, an invoice with reverse charge from a subcontractor never seen before, one with stamp duty, one with a 2-cent difference between lines and summary, and one with an IBAN different from the registered one.

**Monday, review (20 minutes).** The clerk opens the queue. The new supplier: checks the VAT number, creates the master record, confirms. The reverse charge: checks the nature, confirms the entry with VAT integration, and activates the rule for that supplier so next time it goes through on its own. The stamp duty: confirmed, posted separately. The 2 cents: accepts the XML's VAT summary as the correct value. The changed IBAN: **does not confirm**. She calls the supplier on the number already in master data (not the one written on the invoice): the supplier hasn't changed bank. It was a fraud attempt. The invoice is blocked and reported.

**The three foreign PDFs (15 minutes).** The system read supplier, amounts and dates with AI, and proposed posting as an intra-EU purchase. The clerk checks the reading is right (on one she corrects a date read in American format) and confirms. The integrative documents to transmit are prepared according to rules agreed with the accountant.

**Friday, spot check (10 minutes).** Of the 80 invoices processed automatically in the week, 4 are picked at random and checked by hand against the XML: all correct.

**The week's balance.** About an hour and a half of work on invoices, versus 6–7 hours before. And one fraudulent transfer avoided, which alone is worth more than a year of licence. That's why the review of changed IBANs is never removed.

## What breaks after a few months

Even a well-set-up system gets worse if nobody watches it. The typical signs:

- **The review queue grows without invoices growing.** A large supplier changed invoicing software and now sends invoices with a different structure, or with natures the system didn't know. Look at the most frequent review reason and add the rule.
- **Per-supplier rules pile up.** After a year there are dozens of "for that supplier" exceptions, some no longer valid. A six-monthly review with the accountant prevents old rules from posting new invoices wrongly.
- **The spot check stops being done.** After months without errors, it seems pointless. That's exactly when a silent change (a system update, a new large supplier) can introduce errors nobody sees.
- **Master data gets dirty again.** Suppliers created in a hurry, duplicates, IBANs not updated. The system associates by VAT number, but if master data has two records with the same VAT number, the error comes back.
- **Tax rules change.** New codes, new natures, new thresholds. The software vendor should keep up, but it's worth asking explicitly how and when, and checking at the first settlement after the change.

## When NOT to automate (low volume, total chaos)

- **Low volume.** Under 50–80 invoices a month, setup and licence costs hardly pay back. Better to make good use of the XML import functions almost every ERP already has.
- **Chaos in master data.** If supplier master data has duplicates, missing VAT numbers and old IBANs, any automation will amplify the mess. Clean master data first, then automate.
- **Nobody doing the review.** A system putting 25% of invoices in review is useful only if someone empties the queue. Otherwise you've just moved the problem.
- **Mostly foreign or scanned documents.** If most of your documents have no XML, automation is harder, review heavier and savings lower. It can be done, but with different expectations.
- **Outsourced bookkeeping without agreement.** If the accountant's firm does the posting, the project must be done with the firm, not against it. Otherwise you create two versions of the truth.

## 3 beginner mistakes that cost money

**1. Buying "99%" without asking on which fields.** It's the mistake all others come from. Always ask for per-field numbers, on your documents, separating Italian and foreign invoices, and ask how many automatically processed invoices had an error.

**2. Reading PDFs when the XML exists.** Many systems do it because it's the easiest way to "show the AI". But it introduces errors that don't exist in the XML, especially on split payment, reverse charge and stamp duty. XML first, AI only where there's no XML.

**3. Removing review to "save time".** After a few months without visible problems, the temptation is to let everything through automatically. That's when the first invoice arrives with an IBAN changed by a fraudster, or the first foreign invoice with VAT handled badly. Review of risky cases isn't a cost: it's why automation is safe.

## 30/60/90-day path

**First 30 days — measure the situation**

- count supplier invoices by type (Italian XML, foreign, scanned) and time spent today;
- clean supplier master data: duplicates, VAT numbers, IBANs;
- check what the ERP already does with XML import (often more than you think);
- ask software vendors for a trial on **your** documents, with per-field results.

**Days 30 to 60 — start from the XML**

- turn on the XML-first flow for Italian invoices, with rules for split payment, reverse charge and stamp duty agreed with the accountant;
- define thresholds and review reasons;
- start the weekly spot check.

**Days 60 to 90 — add the rest**

- add AI reading for documents without XML, always in review;
- measure: hours saved, invoices in review, errors found in spot checks;
- review the rules with the accountant after the first VAT settlement.

## Practical checklist

- [ ] I know how many invoices I receive a month, by type, and how much time they cost today.
- [ ] Supplier master data is clean: no duplicates, verified VAT numbers, updated IBANs.
- [ ] The system reads the XML for Italian e-invoices, not the PDF.
- [ ] There are verified rules for split payment, reverse charge, stamp duty and exemptions.
- [ ] Association with the supplier is by VAT number.
- [ ] Foreign invoices, new suppliers, changed IBANs and amounts above threshold always go to review.
- [ ] Differences in totals are flagged, not corrected automatically.
- [ ] Accuracy is measured per field, on my documents, with VAT at the top.
- [ ] There's a weekly spot check on automatically posted invoices.
- [ ] The system writes to the ERP, not to a separate portal.
- [ ] The accountant knows and has validated the rules.

## The verdict

**AI that reads invoices gets VAT wrong** mainly when it's asked to do a job it shouldn't: read a PDF when the XML exists, decide on its own about split payment and reverse charge, recognise a supplier by name. The "99% accuracy" is almost always an average lumping together postcode and tax, easy invoices and hard ones.

Automating supplier invoices works, and really saves time, when it follows a precise order: first the e-invoice XML, with tax rules agreed with the accountant; then AI for documents that have no XML; always a person on risky cases; always a spot check on what goes through automatically. Less spectacular than a demo, much calmer at the end of the quarter.

If you're evaluating how to automate invoice posting without surprises in the VAT settlement, you'll find the projects I've worked on in the [portfolio]({{ site.main_site }}/portfolio/) and my background in the [biography]({{ site.main_site }}/biografia/). The other pieces on documents, invoices and AI are in the guide on [documents, invoices and AI]({{ '/en/pillar/documents-invoices-ai/' | relative_url }}).

## FAQ

### Can artificial intelligence post supplier invoices by itself?

It can for part of the invoices, under precise conditions: e-invoice read from the XML, supplier already in master data and associated by VAT number, unchanged IBAN, totals that reconcile, no special tax nature without a verified rule, and an amount below threshold. Foreign invoices, new suppliers, changed IBANs and special cases must go through a person.

### Why is it better to read the invoice XML rather than the PDF?

Because in the XML the data is already structured and transmitted by the supplier through the SDI: taxable amount, rates, nature of operations, VAT chargeability, stamp duty, due dates. Reading the PDF with AI means reconstructing, with a margin of error, data that already exists in exact form. The PDF is only for documents that have no XML.

### What are the most common AI errors on invoices?

The most frequent involve split payment treated as ordinary VAT, reverse charge without VAT integration, stamp duty added to the taxable amount, rounding corrected at random, suppliers with similar names confused, foreign invoices with VAT handled badly, and the PDF attachment read instead of the XML.

### What does "99% accuracy" really mean for invoice-reading software?

Often it's an average over all fields or over characters read, in which the address weighs as much as VAT. Useful accuracy is measured per field, with zero tolerance on amounts, separating Italian and foreign invoices, on a sample of the company's real documents, and stating how many automatically processed invoices contained an error.

### How are foreign invoices handled with AI?

AI is useful for reading data from the PDF, since there's no Italian XML, but these invoices must always go to review. The rules for intra-EU and non-EU purchases must be applied, including VAT integration and integrative documents sent to the SDI where required, agreed with the accountant.

### How many invoices can go through automatically without checks?

In companies where these systems work well, typically between 60% and 80% of supplier invoices: Italian e-invoices without peculiarities from known suppliers. The rest goes to review. Even on automatic invoices, a weekly spot check is worth doing to measure residual error.

### How much do you save by automating invoice posting?

For an SME with about 400 supplier invoices a month, time can drop from 25–30 hours to 8–12 hours a month, with a net saving of a few hundred euros a month after the licence, plus an initial integration cost. The saving disappears if the system introduces VAT errors the accountant has to fix.

### Below what volume isn't automation worth it?

Roughly under 50–80 supplier invoices a month: setup and licence costs hardly pay back. In these cases it pays to make good use of the XML import most ERPs already offer.

### Is a changed IBAN on an invoice a problem?

Yes, it must always be checked by a person. An IBAN different from the one registered for the supplier may be a legitimate change, but it's also the typical sign of payment fraud. The check must be done by contacting the supplier through an already known channel, not the one indicated on the invoice.

### Should the accountant be involved?

Yes. Rules on split payment, reverse charge, exemptions, stamp duty and foreign invoices must be agreed with whoever keeps or checks the books. Automation that posts differently from what the accountant expects creates extra work at period end instead of removing it.
