---
lang: en
permalink: /en/blog/document-extraction-field-accuracy/
alt_url: /it/blog/accuratezza-estrazione-documenti-campi/
title: "How you measure 95% accuracy on document extraction (and how you notice it's 95% on headers and 60% on amounts)"
date: 2026-11-14 07:30:00 +0200
author: "Antonio Trento"
description: "Why overall accuracy on document data extraction lies: per-field metrics, micro and macro averages, weights by cost of error, tolerances, sample vs population with confidence intervals, confusion between similar suppliers, uncertainty threshold and human queue, a weekly report and what to write in the contract with whoever supplies the model."
keywords: ["document extraction field accuracy", "field level accuracy ocr", "invoice gold set", "amount confusion", "human review threshold", "weighted extraction score"]
image: /assets/images/posts/accuratezza-estrazione-documenti-campi.jpg
pillar: rag-documenti
related: [/en/blog/company-pdf-search/, /en/blog/imap-pec-invoice-agent/]
---

## "We're at 95%": the number that closes the demo and opens the problems

The demo ends with a slide: "Extraction accuracy: 95%". The vendor — external, or the internal team that built the pipeline — measured it on a few hundred documents: supplier invoices as PDFs, delivery notes, orders, order confirmations. Heads nod in the room. 95% sounds like a great grade: nineteen documents out of twenty right, people think.

Three months later, the finance team has stopped trusting it. Not because the pipeline gets things wrong often, but because it gets them wrong **where it hurts**: total amounts don't add up in one document out of three or four, new suppliers' IBANs are misread, two suppliers with similar names get confused. Meanwhile document number, date and company name are almost always perfect. The 95% was true. It was just the wrong average.

This piece is about **field-level accuracy in document extraction**: how to measure it so that the number tells something useful to whoever has to decide whether to trust it. Per-field metrics instead of an overall grade, weights tied to the cost of error, explicit tolerances, sample versus population with confidence intervals, confusion between similar master-data records, the uncertainty threshold that sends doubtful cases to a person, a report a finance manager reads in two minutes, and the clauses to write into the contract with whoever supplies the model.

If your case is Italian electronic invoices, the first rule is different and I've written it before: the e-invoice XML is the source, the PDF is a fallback. Here we talk about everything else — delivery notes, orders, confirmations, foreign documents, scans — and above all about **how to measure**.

## Is this for you?

It is for you if:

- you have a document extraction pipeline (OCR + rules, vision model, LLM, external service) in production or under evaluation;
- you've been shown an accuracy figure and don't know how to verify it;
- you have to decide how many documents can go through automatically and how many must be checked by a person.

It is not for you if your documents already arrive structured (XML, EDI, supplier API): there's nothing to extract there, just good parsing to do. And it is not for you if you're looking for a comparison of OCR engines: here the engine is irrelevant, what counts is the yardstick you measure it with.

## Overall accuracy vs per field

Let's start with the number on the slide. How do you get to a 95% that hides a 60%?

Take a typical document — a foreign supplier invoice or a delivery note with values — with twelve header fields and, on average, seven line items with four fields each (description, quantity, unit price, line amount): twenty-eight line fields. Forty fields per document.

Here is the accuracy measured on the header fields, on a sample of 200 documents:

| Field | Accuracy |
|---|---|
| Document number | 99% |
| Document date | 99% |
| Supplier company name | 99% |
| Supplier VAT number | 98% |
| Address | 98% |
| Postcode | 99% |
| IBAN | 90% |
| Taxable amount | 70% |
| VAT | 75% |
| Document total | 60% |
| Payment due date | 95% |
| Order reference | 92% |

And the line items are extracted well: 98.5% on average, because they are repetitive text in regular tables.

Now the three ways of averaging:

- **Micro-average** (all fields of all documents counted together): (12 × 89.5% + 28 × 98.5%) / 40 ≈ **96%**. That's the number on the slide. The numerous, easy line items crush the header.
- **Macro-average over header fields** (simple average of per-field accuracies): **89.5%**. Already less reassuring.
- **Document-level accuracy** on critical fields (share of documents in which *all* critical fields are right): if the total is right only 60% of the time, this number is **at most 60%**, and in practice lower.

Three numbers, all "true", for the same system. The first is the one that wins the tender. The last is the one that tells finance how many documents it can post without looking at them.

### Which metric is for whom

- **Per-field accuracy**: for whoever develops and maintains the pipeline. It tells you *where* to intervene.
- **Weighted score** (below): for comparing system versions or different vendors with a single number that accounts for what an error costs.
- **Straight-through rate** (share of documents that can go through automatically with acceptable residual error): for whoever runs the process. It tells you how much manual work remains.
- **Error rate among automatically processed documents**: for whoever is accountable for errors. It tells you how much risk you're accepting.

A simple rule: **never accept a single accuracy figure** without knowing on which fields, with which average, on which documents and with which tolerance.

## Weights: IBAN > address > postcode

Not all errors cost the same. A wrong postcode on a supplier invoice costs almost nothing: the document gets posted anyway, the payment goes out anyway. A wrong IBAN can send a bank transfer to someone else. A wrong total breaks reconciliation, the accounting entry, sometimes the payment.

The way to build this asymmetry into the measurement is to **weight fields by the cost of error**. The weights aren't decided by the developers: they're decided by whoever suffers the error, i.e. finance, in a half-hour conversation.

### Field and weight table

| Field | Weight | Why | Tolerance |
|---|---|---|---|
| IBAN | 10 | Error = payment to the wrong beneficiary | Exact (after normalising spaces/case) |
| Document total | 10 | Reconciliation, posting, payment | Exact to the cent |
| Taxable amount | 8 | VAT posting | Exact to the cent |
| Supplier VAT number | 8 | Link to master data, compliance | Exact |
| VAT | 6 | VAT posting, settlement | Exact to the cent |
| Payment due date | 5 | Late or early payments | Exact to the day |
| Order reference | 4 | Order-invoice matching | Exact after normalisation |
| Document date | 3 | Accrual, registers | Exact to the day |
| Document number | 2 | Identification, duplicates | Exact after normalisation |
| Company name | 2 | Readability (master data comes from the VAT number) | Normalised match |
| Address | 1 | Rarely used in the process | Similarity ≥ 0.9 |
| Postcode | 1 | Rarely used in the process | Exact |

With these weights and the earlier accuracies, the header's **weighted score** drops to 84%. It's not a number that is "stricter" for the sake of it: it measures the system from the point of view of whoever uses it.

### Weighted score formula

Define, for each field *f*:

- *w_f* = field weight;
- *n_f* = number of documents in the sample where the field is present in the gold set;
- *c_f* = number of documents where the extracted value matches the gold, according to the field's tolerance.

Field accuracy: *a_f = c_f / n_f*.

Weighted score:

**S = Σ_f ( w_f · a_f ) / Σ_f w_f**

Two clarifications that make the difference in practice:

1. **A field present in the gold but not extracted counts as an error**; a field absent from the gold but "extracted" (the model invented an IBAN the document doesn't contain) **also counts as an error**, and must be tracked separately, because it is the most dangerous kind of error.
2. **Rare fields must be measured on documents where they are present**, but the score must also report *n_f*: 100% accuracy on five IBANs isn't worth as much as 97% on five hundred.

In code:

```python
from dataclasses import dataclass
from decimal import Decimal
from difflib import SequenceMatcher
import re

@dataclass
class FieldRule:
    weight: float
    tolerance: str          # "exact", "cent", "day", "normalised", "similar"
    similarity_threshold: float = 0.9

def normalise(s: str) -> str:
    return re.sub(r"[\s\.\-_/]", "", s or "").upper()

def matches(extracted, gold, rule: FieldRule) -> bool:
    if gold is None:
        return extracted is None                # inventing a value is an error
    if extracted is None:
        return False
    if rule.tolerance == "cent":
        return abs(Decimal(str(extracted)) - Decimal(str(gold))) < Decimal("0.005")
    if rule.tolerance in ("exact", "day"):
        return str(extracted) == str(gold)
    if rule.tolerance == "normalised":
        return normalise(extracted) == normalise(gold)
    if rule.tolerance == "similar":
        return SequenceMatcher(None, normalise(extracted), normalise(gold)).ratio() >= rule.similarity_threshold
    raise ValueError(rule.tolerance)

def evaluate(pairs, rules: dict[str, FieldRule]):
    """pairs: list of (extracted: dict, gold: dict) per document."""
    stats = {f: {"n": 0, "ok": 0, "invented": 0} for f in rules}
    for extracted, gold in pairs:
        for f, r in rules.items():
            g, e = gold.get(f), extracted.get(f)
            if g is None and e is not None:
                stats[f]["invented"] += 1
            if g is None and e is None:
                continue                        # field not applicable to the document
            stats[f]["n"] += 1
            stats[f]["ok"] += matches(e, g, r)
    acc = {f: (s["ok"] / s["n"] if s["n"] else None) for f, s in stats.items()}
    weights = {f: rules[f].weight for f in rules if acc[f] is not None}
    score = sum(weights[f] * acc[f] for f in weights) / sum(weights.values())
    return score, acc, stats
```

The code is deliberately simple. You don't need a metrics library: you need every comparison rule to be explicit and discussed, and a reliable gold set.

## Tolerance intervals

Tolerance is the most underestimated part of measurement, because it looks like a technical detail. Instead it decides the result. The same system can be at 99% or 85% on the address depending on whether "Via G. Verdi 12" and "Via Giuseppe Verdi, 12" are considered equal or different.

The rules I use:

- **Amounts: exact to the cent.** No "percentage" tolerance. A total wrong by 10 cents breaks reconciliation exactly like one wrong by €1,000; in fact it's sneakier, because nobody notices it by eye. Normalisation (decimal comma or point, thousands separators, currency symbol) happens *before* the comparison, and must be tested separately: "1.234,50" and "1,234.50" must become the same number, and "1.234" must be interpreted according to the document's convention, not guessed.
- **Identifiers (IBAN, VAT number, tax code, document number): exact after normalising** spaces, dots, dashes and case. Nothing else. One different character is a different identifier.
- **Dates: exact to the day**, after normalising the format. Beware foreign documents with month/day format: is "03/04/2026" the 3rd of April or the 4th of March? Tolerance doesn't resolve the ambiguity: the pipeline must, with a rule per country or per supplier.
- **Descriptive text (company name, address, line descriptions): similarity** with a declared threshold, after normalisation. The threshold must be chosen by looking at real examples of "almost the same" and "different", not by feel.
- **Quantities: exact**, paying attention to units of measure (pieces, kg, metres): a right quantity with the wrong unit is an error.

Tolerances must be written in a configuration file versioned together with the gold set. If you change a tolerance, you change the measurement: the score before and after are no longer comparable.

```yaml
# evaluation/fields.yaml — versioned with the gold set
version: 2026-11-01
fields:
  iban:              {weight: 10, tolerance: normalised, critical: true}
  total:             {weight: 10, tolerance: cent,       critical: true}
  taxable:           {weight: 8,  tolerance: cent,       critical: true}
  vat_number:        {weight: 8,  tolerance: normalised, critical: true}
  vat:               {weight: 6,  tolerance: cent,       critical: true}
  due_date:          {weight: 5,  tolerance: day,        critical: true}
  order_reference:   {weight: 4,  tolerance: normalised, critical: false}
  document_date:     {weight: 3,  tolerance: day,        critical: false}
  document_number:   {weight: 2,  tolerance: normalised, critical: false}
  company_name:      {weight: 2,  tolerance: similar, similarity_threshold: 0.92, critical: false}
  address:           {weight: 1,  tolerance: similar, similarity_threshold: 0.90, critical: false}
  postcode:          {weight: 1,  tolerance: exact,      critical: false}
straight_through:
  requires_all_critical_fields_with_confidence_above_threshold: true
```

## Sample vs population

The 95% on the slide was measured on a sample. Two questions to always ask: **how big** and **how much does it resemble the real documents**.

### How big: the confidence interval

An accuracy measured on a sample is an estimate, with a margin of uncertainty. With 200 documents and 190 correct (95%), the 95% confidence interval (Wilson method) runs from about **91.0% to 97.3%**. With 500 documents and 475 correct, it narrows to **92.7%–96.6%**.

The problem gets serious on rare fields. If the IBAN is present in only 40 of the 200 documents and 36 are correct, accuracy is 90%, but the interval runs from **76.9% to 96.0%**. You're deciding whether to send payments through automatically with a number that could be 77% or 96%. With 10 examples and 9 correct, the interval runs from about 60% to 98%: in practice you know nothing.

Practical consequences:

- always report *n* next to every accuracy;
- for rare critical fields, **deliberately enrich the gold set** with documents that contain them, until you have at least a few hundred examples;
- don't compare two system versions if their intervals almost entirely overlap: the difference could be noise.

### How representative: the stratified sample

The demo sample is often made of "comfortable" documents: the main suppliers, the most frequent layouts, the good scans. The real population is different: there's the long tail of suppliers with one document a year, crooked scans, documents in English or German, faxes (yes, still), credit notes with negative amounts.

The sample must be **stratified** along the dimensions that matter:

- by **supplier** (top ten by volume, then the long tail);
- by **document type** (invoice, credit note, delivery note, order, confirmation);
- by **origin** (native PDF, scan, photo, foreign document);
- by **period** (recent documents, because layouts change).

And accuracy must be reported **per stratum**, as well as overall. The typical case: 98% on large suppliers' native PDFs, 70% on long-tail scans. If the real population is 30% scans, the "true" average is much lower than the one measured on a sample that contained 5%.

### The gold set, briefly

The gold set — documents with correct values entered by a person — is the basis of everything. Three rules:

- it's labelled by whoever knows the documents (finance), not by the developers;
- a portion is labelled twice by different people, to measure inter-annotator agreement: if two people disagree on a field's value, that field is ambiguous for the model too;
- the gold set is updated, with new documents every month, and versions are kept.

## Confusion: supplier A vs B with similar names

There's a class of errors that per-field measurement doesn't see well: **association with the wrong master-data record**. The pipeline extracts "Rossi Impianti S.r.l." and associates it with the supplier "Rossi S.r.l." already in master data. Every extracted field can be perfect; but the document ends up on the wrong supplier's record, with its IBAN, its payment terms, its ledger account.

It happens more often than you'd think, because Italian company names resemble each other: families with several companies, groups with almost identical names, "Unipersonale", "S.r.l.s.", "& C.", abbreviations. And it happens above all when the pipeline uses the company name for association instead of the VAT number, or when the VAT number isn't readable and the system "falls back" on the name.

How to measure it:

- the gold set also contains the **correct supplier ID** in master data;
- you build a **confusion matrix** of the association: for each real supplier, which supplier the system associated the documents with;
- you look at off-diagonal cells: every recurring pair (A confused with B) is a specific problem, almost always solvable.

| Real supplier ↓ / associated → | Rossi S.r.l. | Rossi Impianti S.r.l. | Rossi & Figli S.n.c. | None (review) |
|---|---|---|---|---|
| Rossi S.r.l. | 46 | 2 | 0 | 1 |
| Rossi Impianti S.r.l. | 7 | 18 | 0 | 2 |
| Rossi & Figli S.n.c. | 1 | 0 | 9 | 1 |

Seven of Rossi Impianti's twenty-seven documents ended up on Rossi S.r.l.: a 26% error on that supplier, invisible in the overall average.

The countermeasures are deterministic:

- **association by VAT number**, never by name; the name is only a check;
- if the extracted VAT number fails the validity check or doesn't exist in master data, **no association**: human review;
- for known pairs of similar suppliers, an explicit rule requiring human confirmation;
- for new suppliers, never automatic creation of a master-data record from a document.

Validating identifiers with algorithms instead of the model is the second layer of the fence: the schema checks the form, domain validators check the content.

## Uncertainty threshold and human queue

No extraction system is perfect, so the operational question isn't "how accurate is it" but "**which documents can I let through without looking, and at what risk**". The answer goes through an uncertainty threshold.

Almost every pipeline produces some per-field confidence measure: OCR character confidence, the model's probability, the outcome of deterministic checks (valid checksums, taxable + VAT = total, VAT number present in master data). The model's "raw" confidence alone is not very reliable: models are often confident even when wrong. Deterministic checks, on the other hand, are gold: if taxable + VAT ≠ total, at least one of the three fields is wrong, regardless of confidence.

The routing rule I use combines the two:

- a document goes through automatically **only if** all critical fields exceed the confidence threshold **and** all deterministic checks pass;
- otherwise it goes to the review queue, with the fields that caused it highlighted.

### How to choose the threshold

The threshold isn't chosen "at 0.8 because it seems a good number". It's chosen on the gold set, looking at two curves: the share of documents going through automatically and the error rate among those that do.

| Confidence threshold (critical fields) | Documents processed automatically | Errors among automatic documents |
|---|---|---|
| 0.50 | 88% | 6.1% |
| 0.70 | 79% | 2.8% |
| 0.80 | 71% | 1.2% |
| 0.90 | 58% | 0.4% |
| 0.95 | 41% | 0.2% |

(Example numbers, to be redone on your gold set.)

The choice is a business decision, not a technical one: how much manual work you want to remove and how much residual error you accept. With the table in front of them, finance can say "I accept 1% errors on automatic documents if I remove 70% of the work" — or "on payments I want under 0.5%, so threshold at 0.9". There can also be different thresholds per field: higher on the IBAN, lower on the date.

A detail that matters: residual error must be **re-measured in production**, with a spot check on automatically processed documents (for example 2–5% picked at random every week). Without this check, the error rate of automatic documents becomes invisible by definition: nobody looks at them.

## A report that isn't a paper's F1

Academic metrics — precision, recall, F1 — are useful to developers and useless to whoever has to decide. A finance manager has no use for "macro F1 0.87". They do have use for "this week 312 documents, 228 posted automatically, 2 errors found in the spot check, both on amounts from one foreign supplier".

### Example weekly report

> **Document extraction — week 45 (3–9 November)**
>
> **Volume:** 312 documents (foreign invoices 96, delivery notes 141, orders 52, credit notes 23).
>
> **Automatic:** 228 (73%) — last week 70%.
> **In review:** 84 (27%). Main reasons: total doesn't reconcile (31), IBAN invalid or not in master data (18), supplier not associated (14), unreadable scan (12), other (9).
>
> **Spot check on automatic documents:** 12 checked, 0 errors. Last 4 weeks: 47 checked, 1 error (VAT amount on a credit note).
>
> **Corrections made in review:** 84 documents, 61 fields corrected. Most corrected fields: total (19), taxable (14), due date (9).
>
> **To look at:** supplier "Muller GmbH" has 9 of 11 documents in review because of an ambiguous date format — proposal: a per-supplier format rule.
>
> **Status:** 🟢 reliable on critical fields (weighted score 0.93 on October gold set, n = 600; previous week 0.92).

The report answers four questions, in the order the reader asks them: how much work was removed, how much risk there is, what went wrong, what needs doing. The technical numbers (weighted score, *n*) are at the bottom, for those who want them.

The report is generated from a query on the pipeline database and the review logs: it must not be written by hand, otherwise after three weeks it stops existing.

## Contract with the internal/external AI supplier

Whether the pipeline is built by an external vendor or an internal team, you need a **written agreement on how it is measured**. Otherwise every discussion about quality becomes a clash of impressions. The clauses I always include:

1. **Per-field metrics**, not an overall accuracy. List of critical fields, with tolerances and weights attached.
2. **Gold set owned by the client**, built by the client (or together, with client review), never shared to train third-party models without explicit consent. Part of the gold set stays **held out** and is never shown to the vendor, to avoid the system being optimised on the test.
3. **Minimum thresholds per critical field**, with the confidence interval: "IBAN accuracy ≥ 98% measured on at least 300 examples".
4. **Maximum error rate on automatically processed documents**, measured with a spot check in production.
5. **Advance notice of any model or version change** that could alter behaviour, with re-evaluation on the gold set before release.
6. **Right to re-evaluate** periodically (for example quarterly) and on request in case of perceived deterioration.
7. **Handling of invented fields**: a value extracted for a field absent from the document is a serious error, measured separately, with its own threshold close to zero.
8. **Data residency and processing**: where documents are processed, who sees them, how long they are kept. The default I recommend is processing on the client's infrastructure or in the EU, with appointment as data processor.
9. **Remedies**: what happens if thresholds aren't met (correction within a deadline, discount, right of withdrawal).

If the vendor won't accept being measured per field on a client-owned gold set, they're telling you something about their 95%.

## Implementation path, step by step

1. **List the fields** the process needs and, with finance, assign weights and tolerances. Identify the critical fields.
2. **Build the gold set**: 300–600 documents stratified by supplier, type, origin and period, with rare critical fields deliberately enriched. Double labelling on 10–20%.
3. **Write the evaluator** (like the one above) and the versioned field configuration.
4. **Measure the current system** (even if it's manual: how often do people get it wrong?) and the candidates, per field, per stratum, with confidence intervals.
5. **Add deterministic checks**: identifier checksums, amount reconciliation, existence in master data, association by VAT number.
6. **Choose the threshold** on the automatic/error table, with finance.
7. **Turn on the review queue** with problematic fields highlighted and corrections recorded.
8. **Turn on the spot check** on automatic documents.
9. **Generate the weekly report** automatically.
10. **Re-evaluate every month** on the updated gold set, and before every change of model, prompt or rule.

## Typical failures and how to spot them in the logs

**The overall number goes up, the weighted one goes down.**

```text
eval 2026-11-01 micro=0.961 header_macro=0.902 weighted_score=0.861 n_doc=600
eval 2026-11-08 micro=0.966 header_macro=0.899 weighted_score=0.842 n_doc=600
```

A change improved the easy fields and worsened the critical ones. If you only look at the micro average, you release it.

**Invented fields.**

```text
extract doc=DDT-88123 field=iban value=IT60X054281110100000012345 gold=null status=INVENTED
extract doc=DDT-88140 field=iban value=IT02A030690960610000004567 gold=null status=INVENTED
```

The model "completes" an IBAN on documents that don't contain one (a delivery note, for example). Very serious: if that IBAN happens to pass the checksum or gets associated with master data, the payment goes to an account that was never in the document.

**Reconciliations failing in series.**

```text
validate doc=FT-EXT-4471 check=reconciliation taxable=1250.00 vat=275.00 total=1252.75 result=FAIL
```

The total was read with a wrong separator or the value of another line was taken. If it happens on a specific supplier, it's a layout; if it happens everywhere, it's a regression.

**Review queue growing without more volume.** The share in review goes from 25% to 40% in two weeks with the same number of documents: a large supplier changed layout, or the model changed. The weekly report shows it; the log shows which review reason grew.

**A spot check that never finds anything.** Zero errors for twelve weeks on very few checked documents doesn't mean zero error: with 10 checks a week, a real 1% error often goes unnoticed. Increase the sample or focus it on critical fields.

## Costs: orders of magnitude

Indicative estimates for a pipeline handling from a few hundred to a few thousand documents a month.

| Item | Order of magnitude (estimate) | Notes |
|---|---|---|
| Defining fields, weights, tolerances | 1–2 days | With finance, not alone |
| Building the gold set (500 documents) | 5–10 person-days | Depends on fields; the highest and most useful cost |
| Evaluator and configuration | 2–4 person-days | Once, then reused |
| Deterministic checks | 2–5 person-days | Checksums, reconciliations, master data |
| Review queue with evidence | 3–8 person-days | If it doesn't already exist in the ERP |
| Automatic weekly report | 1–3 person-days | Query + sending |
| Maintenance | 1–2 days/month | Gold set updates, re-evaluations |
| Spot check | 30–60 minutes/week | Of a finance team member |

The gold set looks expensive. Compare it with the cost of a single transfer to the wrong IBAN, or a quarter of VAT entries to correct.

## When NOT to do it

- **When documents are few.** With 50 documents a month, a person posts them in less time than it takes to build the gold set. Use extraction as a suggestion, without automatic routing.
- **When the data already exists structured.** XML e-invoices, EDI, supplier portals with exports: before measuring extraction accuracy, ask yourself why you're extracting.
- **When nobody will do the review.** An uncertainty threshold without people looking at the queue is an elegant way of piling up unposted documents.
- **When the vendor won't be measured per field.** It's not a contractual detail: it's the sign that quality isn't verifiable.
- **When the error is very costly and the volume low**: for contracts, deeds, rare legal documents, automatic extraction at most prepares a sheet for the reader, and the metric that counts is "how much time it saves the checker", not accuracy.

## Operational checklist

- [ ] Every accuracy is reported per field, with *n* and confidence interval.
- [ ] Per-field weights and tolerances are decided with finance and versioned.
- [ ] The weighted score is the main number for comparing versions and vendors.
- [ ] Invented fields (value extracted, field absent) are measured separately.
- [ ] The gold set is stratified by supplier, type, origin and period; rare critical fields are enriched.
- [ ] Part of the gold set is double-labelled and part is held out.
- [ ] Association with master data is by VAT number, with the confusion matrix monitored.
- [ ] Deterministic checks (checksums, reconciliation, existence in master data) block automatic processing.
- [ ] The threshold is chosen on the automatic/error table, with an explicit decision by whoever is accountable for errors.
- [ ] There's a weekly spot check on automatically processed documents.
- [ ] The weekly report is generated automatically and read by finance.
- [ ] The vendor contract contains per-field metrics, a client-owned gold set, notice of model changes.

## The verdict

Field-level accuracy in document extraction is not a grade: it's a table. A single number, however high, averages fields that cost nothing when wrong with fields that cost a bank transfer, easy documents with hard ones, a comfortable sample with a messy population. 95% on headers and 60% on amounts can coexist in the same number, and it's the number you get shown.

Measuring well costs little compared with what it protects: fields with weights decided by whoever suffers the error, written tolerances, samples large enough and similar enough to reality, deterministic checks that can't be talked round, a threshold chosen by looking at residual risk, a person spot-checking even what goes through automatically. And a report that tells finance, every week, whether it can trust the system.

If you're evaluating an extraction pipeline — yours or a vendor's — and want to know what it's really worth on the fields that matter, you'll find my background in the [biography]({{ site.main_site }}/biografia/) and the rest of my work on [antoniotrento.net]({{ site.main_site }}/). The other pieces on documents, RAG and extraction are collected in the guide on [RAG and documents]({{ '/en/pillar/rag-documents/' | relative_url }}).

## FAQ

### Why is the overall accuracy of document extraction misleading?

Because it averages fields of very different importance and difficulty. Numerous, easy fields such as line items or dates push the average up and hide errors on critical, hard fields such as amounts and IBANs. A system can have 96% overall accuracy and 60% on the document total.

### What are micro-average and macro-average in per-field accuracy?

The micro-average counts all fields of all documents together, so it weights the most numerous fields more. The macro-average first computes each field's accuracy and then takes the simple average, giving every field the same weight. Neither accounts for the cost of error: that's why you need a weighted score.

### How do you calculate a weighted accuracy score?

You assign each field a weight proportional to the cost of error, compute each field's accuracy on the gold set with its tolerance, and take the weighted average: sum of weight times accuracy, divided by the sum of weights. The weights are decided by whoever suffers the error, typically finance.

### What tolerance should be used for amounts and identifiers?

For amounts, exactness to the cent after normalising separators and currency symbols. For identifiers such as IBAN, VAT number and tax code, exactness after normalising spaces, dots and case. For descriptive text such as addresses and company names, a declared similarity threshold chosen by looking at real examples.

### How many documents do you need to measure accuracy reliably?

It depends on the field. For fields present in every document, a few hundred documents give confidence intervals of a few percentage points. For rare fields, such as an IBAN present only in some documents, you need hundreds of examples of that field: with 40 examples a measured 90% may correspond to a real value between about 77% and 96%.

### What is a gold set and who should build it?

It's a set of real documents with the correct value of every field entered by a person. It must be built by whoever knows the documents, such as finance, with a portion labelled twice to measure inter-annotator agreement and a held-out portion the system's vendor never sees.

### How do you avoid confusing suppliers with similar names?

By associating documents with master data through a validated VAT number, never through the company name. If the VAT number isn't readable or doesn't exist in master data, the document goes to review. A confusion matrix of the association, updated periodically, shows which supplier pairs the system confuses.

### How do you choose the confidence threshold for human review?

On the gold set, building a table that for each threshold shows the share of documents that would go through automatically and the error rate among them. The choice belongs to whoever is accountable for errors: how much manual work to remove and how much residual error to accept. In production, the error rate must be re-measured with spot checks.

### What should an accuracy report for finance contain?

Document volume, how many went through automatically and how many to review with reasons, errors found in spot checks, the most corrected fields in review, flags on problematic suppliers and an overall reliability status. Technical metrics can sit at the bottom for those who want them.

### What should go into the contract with a document extraction vendor?

Per-field metrics with tolerances and weights, a client-owned gold set with a held-out portion, minimum thresholds for critical fields with sample size, a maximum error rate on automatic documents, advance notice of model changes, handling of invented values, data residency and remedies if thresholds aren't met.
