---
lang: en
permalink: /en/blog/salesforce-flow-vs-mcp-agent/
alt_url: /it/blog/salesforce-flow-vs-agente-mcp/
title: "Salesforce Flow vs MCP agent: when Flow's automatic click is safer (and when the LLM is really needed to read the mess)"
date: 2026-11-13 07:30:00 +0200
author: "Antonio Trento"
description: "Where deterministic automation ends and a language model is needed in Salesforce: Flow for if-then rules, LLM for free text and exceptions. A hybrid pattern in which Flow calls a classification service, error handling, 18-month maintenance costs, governance and a matrix for 10 typical automations."
keywords: ["salesforce flow vs mcp agent", "flow orchestrator vs llm", "deterministic crm automation", "salesforce exceptions", "llm tool", "salesforce email classification"]
image: /assets/images/posts/salesforce-flow-vs-agente-mcp.jpg
pillar: agenti-esecuzione
related: [/en/blog/salesforce-mcp-production-agent/, /en/blog/salesforce-agent-kill-switch/]
---

## The meeting where someone proposes to "put AI in the CRM"

The proposal usually arrives with a slide and a verb: *replace*. "Let's replace the Flows with an agent that understands what to do." The idea is seductive: instead of dozens of automations with conditions, decisions and branches, an agent connected to Salesforce via MCP reads the record, understands the context and acts. No more admins spending their days in Flow Builder, no more rules breaking at the first unforeseen case.

Then someone asks the right question: "And when the agent decides that client is entitled to a 15% discount instead of 10%, who notices?" Silence. Because the honest answer is: nobody, until the client points it out (if the discount was too low) or until management control finds it at the end of the quarter (if it was too high).

This piece is about the line between **Salesforce Flow and an MCP agent**: when Flow's deterministic automation is not only sufficient but *safer*, and when a language model is really needed, because there is messy text to read that no if-then rule can handle. The thesis is anti-hype and practical: Flow for rules, LLM for language, and when you need both, **Flow calls a classification service, not the other way round**. With a matrix for ten typical automations, the complete hybrid pattern, the anti-patterns and the 18-month maintenance costs.

## Is this for you?

It is for you if:

- you have a Salesforce org with a number of Flows in production and someone is proposing to introduce an agent or an LLM;
- you are the admin, architect or CTO who has to decide where to put the model and where not;
- you already have a concrete case of free text (emails, notes, attachments) that today needs a person to sort it.

It is not for you if you are looking for how to build a complete MCP agent on Salesforce: I described that in the piece on the [MCP agent on Salesforce in production]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}). Here the question is upstream: *whether* and *where* to put a language model in a CRM process.

## Flow is visual code with contracts

Let's start with a misconception: Flow is often treated as "the tool for those who can't code", hence something inferior to code. It's the opposite. A well-made Flow is **visual code with explicit contracts**:

- **typed inputs and outputs**: a field is a number, a date, a picklist with defined values, a record reference;
- **deterministic conditions**: for the same record, the Flow always takes the same path;
- **transactions**: a record-triggered flow lives inside the save transaction; if something goes wrong, the transaction rolls back;
- **versions**: every change is a new version, activatable and deactivatable, with the ability to go back;
- **fault paths**: every element that can fail has an explicit error branch;
- **tests**: Flow supports automated tests on record-triggered flows, and in any case behaviour is verifiable with test data.

These properties are exactly what you need when automation touches money, contracts, deadlines, assignments, permissions. If an opportunity moves to "Closed Won" when the contract is signed, you want it to happen *always*, *only* in that case and in a *verifiable* way. A language model gives you none of these guarantees by construction: it gives you a high probability, which is not the same thing.

Flow's limits are equally clear:

- it can't read free text except through fragile string comparisons ("contains the word *complaint*");
- it can't extract information from a PDF or an image;
- it becomes unmanageable when rules are too many and overlap (the famous Flow with forty nested decisions that nobody dares touch);
- it is bound by the platform's governor limits: number of queries, DML, callouts per transaction, CPU time.

The first and second limits are LLM territory. The third is a design problem, not a tool problem: an unmanageable Flow gets refactored, not replaced with a model. The fourth applies to anything running on the platform, LLM included.

## The LLM is for text and ambiguity, not for 22% VAT

The quickest way to understand where *not* to put a language model is to ask: "is there a written rule that gives the right answer?". If yes, that rule belongs in Flow (or Apex, or a formula), not entrusted to a model.

The example I always use is VAT. Nobody would ask an LLM to calculate 22% VAT on an amount: it's a multiplication. Yet the same mistake, in disguise, comes up all the time:

- "the agent decides which salesperson to assign the lead to" — when there is a territory table;
- "the agent assesses whether the requested discount can be approved" — when there is a discount matrix by client tier;
- "the agent updates the opportunity stage" — when the transition depends on precise fields;
- "the agent calculates the renewal date" — when it's the start date plus the term.

In all these cases the model adds nothing, and takes away three things: determinism, verifiability and speed. It also adds a per-call cost and an external dependency.

The language model is needed when the input is **unstructured language** and the question is **interpretive**:

- "is this email a complaint, a request for information or an order?";
- "in these call notes, what are the agreed next steps?";
- "is this attached PDF a purchase order, and if so, what is the order number and amount?";
- "is the client in this email threatening to cancel?";
- "are these two accounts with different names probably the same company?".

No if-then rule answers these questions well. A person does, and a model does well enough to be useful — with a confidence level, and with a person behind it when confidence is low.

## Exceptions: free emails, notes, attachments

The reason CRM automations "don't work" almost never lies in the rules. It lies in the **exceptions**: everything that arrives in a form the rules don't foresee. In Salesforce exceptions take three recurring forms.

**Free emails.** Email-to-Case or Email-to-Lead create a record with subject and body. The Flow sorting them relies on the sender address, keywords in the subject, perhaps the sender's domain. It works for 60–70% of cases. The rest ends up in a "To sort" queue that a person empties by hand, every morning, reading them one by one.

**Notes and description fields.** Salespeople write call notes, technicians write job descriptions, customer care annotates phone calls. Inside there is valuable information (promised deadlines, recurring problems, churn signals) that no report can use because it is text.

**Attachments.** Orders as PDFs, scanned signed quotes, clients' documents. The Flow sees there is a file, not what is in it.

These three categories are where an LLM, used well, **removes repetitive manual work** without touching the rules. The key point is "used well": the model must not decide what to do with the record; it must **turn the mess into structured fields**, which the rules then use. It's the difference between a model that acts and a model that classifies.

## Hybrid: classify → field → Flow

Here is the pattern I propose for almost all cases where a language model enters a Salesforce process. It is simple, and its simplicity is what makes it robust.

### The hybrid pattern

1. **An event in Salesforce** (new Case from email, new note, new attachment on an opportunity) triggers a record-triggered flow.
2. The Flow, on an **asynchronous path**, calls an external **classification service** through an HTTP action (or an invocable Apex action), with a Named Credential.
3. The classification service (self-hosted, in the EU) prepares the text, calls the model, validates the output against a schema and returns a **JSON with category, extracted fields and confidence**.
4. The Flow writes the result into **dedicated fields** (`AI_Category__c`, `AI_Confidence__c`, `AI_Extracted_OrderNumber__c`, `AI_Model_Version__c`), never into business fields.
5. **A second deterministic Flow** (or a branch of the first) reads those fields and applies the rules: if confidence exceeds the threshold and the category is X, assign to queue X; otherwise, human review queue.
6. **A person confirms or corrects** cases below threshold; the correction is saved and used to measure model accuracy over time.

In this pattern the model has no Salesforce credentials, doesn't choose which records to modify, doesn't decide assignments or stages. It does one thing: reads text and returns a classification with a confidence. **Flow calls the service, the service doesn't call Flow.** Orchestration stays in the platform, where there are transactions, versions, permissions and audit.

```text
  Email-to-Case / Note / Attachment
              │
              ▼
  Record-triggered Flow (asynchronous path)
              │  HTTP callout (Named Credential)
              ▼
  Classification service (EU, self-hosted)
     ├─ text cleanup, strip signatures and quotes
     ├─ model call with structured output
     ├─ schema validation + deterministic rules
     └─ { category, fields, confidence, version }
              │
              ▼
  Flow writes AI_* fields  (never business fields)
              │
              ▼
  Deterministic Flow: threshold? ──yes──► automatic routing
                         │
                         no
                         ▼
               Human review queue ──► correction saved (metric)
```

### The service contract

The contract between Flow and service is a small, stable JSON. The Flow must know nothing about the model behind it.

```json
{
  "request": {
    "record_id": "500Qy00000AbCdE",
    "type": "case_email",
    "subject": "RE: order 4471 partial delivery",
    "text": "Good morning, I'm writing to let you know that of order 4471 only 3 of 5 parcels arrived...",
    "expected_language": "it"
  },
  "response": {
    "category": "delivery_complaint",
    "confidence": 0.91,
    "fields": {
      "order_number": "4471",
      "urgency": "medium",
      "churn_risk": false
    },
    "short_reason": "Reports incomplete delivery of an identified order.",
    "model_version": "case-classifier-v7",
    "prompt_version": "2026-11-02",
    "validation_result": "ok"
  }
}
```

And the service, stripped to the bone, with the part that matters: closed categories, validation, threshold handled as data and not as prompt.

```python
from enum import Enum
from pydantic import BaseModel, Field, ValidationError
from fastapi import FastAPI

class Category(str, Enum):
    delivery_complaint = "delivery_complaint"
    quality_complaint = "quality_complaint"
    info_request = "info_request"
    order = "order"
    accounting = "accounting"
    other = "other"

class Classification(BaseModel):
    category: Category
    confidence: float = Field(ge=0, le=1)
    order_number: str | None = Field(default=None, pattern=r"^\d{3,8}$")
    urgency: str = Field(pattern=r"^(low|medium|high)$")
    churn_risk: bool
    short_reason: str = Field(max_length=200)

app = FastAPI()

@app.post("/classify/case")
def classify(req: dict):
    text = clean(req["text"])                    # strip signatures, quotes, disclaimers
    raw = call_model(text, schema=Classification.model_json_schema())
    try:
        c = Classification.model_validate_json(raw)
    except ValidationError:
        return {"category": "other", "confidence": 0.0,
                "validation_result": "invalid_schema",
                "model_version": MODEL_VERSION}
    if c.order_number and not order_exists(c.order_number):
        c.order_number = None                    # never an invented reference
        c.confidence = min(c.confidence, 0.5)
    return {**c.model_dump(), "validation_result": "ok",
            "model_version": MODEL_VERSION, "prompt_version": PROMPT_VERSION}
```

Note `order_exists`: the extracted order number is checked against a source. If it doesn't exist, it isn't written. The schema guarantees the form, domain validation guarantees the content.

### Two Salesforce constraints to know beforehand

- **Callouts and transactions.** In a record-triggered flow, the HTTP callout goes on the **asynchronous path** (or in an action that runs after commit). Making a callout after a DML operation in the same transaction produces the classic "uncommitted work pending" error. The asynchronous path solves the problem and, on top of that, doesn't keep the user waiting.
- **Per-transaction limits.** Each transaction has a cap on callouts and an overall timeout. An import of 10,000 Cases triggering 10,000 synchronous callouts is a design problem: in those cases batch processing outside the platform is better (the service reads new records via API and writes results with an integration user whose permissions are limited to the `AI_*` fields).

## Anti-pattern: the LLM inside every Flow

Once the classification service works, the temptation arrives: "while it's there, let's also use it for…". That's the moment a healthy architecture becomes a problem. The anti-patterns I see most often:

**1. The LLM as rules engine.** An "ask the model what to do" action instead of a Decision element. The model receives the record and returns "assign to Mario" or "apply 10% discount". You've replaced a verifiable rule with a probabilistic opinion.

**2. A model callout in every Flow.** Every record-triggered flow in the org has its own model call: to summarise, to enrich, to "score". Result: latency on every save, costs growing with record volume rather than value, dozens of prompts scattered across the org with no version or test.

**3. The model writing into business fields.** The model's answer goes straight into `Status`, `Owner`, `Amount`, `CloseDate`. There's no longer any way to tell what a person decided, what a rule decided and what a model guessed.

**4. The agent orchestrating Salesforce.** The MCP agent receives a task ("handle today's new Cases") and decides by itself which tools to call, in what order, on which records. For some person-assisted use cases it's fine; as a replacement for process automation it's fragile, hard to test and expensive. If you must do it, you need minimal permissions, an approval queue and a [kill switch for the Salesforce agent]({{ '/en/blog/salesforce-agent-kill-switch/' | relative_url }}).

**5. The prompt as process documentation.** Business rules live inside the prompt ("if the client is Gold and the order exceeds €10,000, then…"). No admin sees them, no test covers them, no change set tracks them.

**6. No confidence threshold.** The model classifies everything, and everything is routed automatically. The 5% of errors becomes invisible, until a serious complaint lands in the "information requests" queue and nobody sees it for a week.

The rule I use to sum up: **the model produces data, the rules produce actions**. If an element of the process produces an action (assign, approve, change stage, send), it must be deterministic. If it produces data from text, it can be a model, with confidence and review.

## Different error handling and retries

Flow and the classification service fail in different ways, and must be handled differently. Confusing them is one of the most common causes of strange behaviour in production.

**Flow errors** (deterministic): an empty required field, a record locked by another process, a validation rule firing, a governor limit exceeded. They are handled with **fault paths**: log the error in a log object, notify the admin, and — where it makes sense — retry later with a scheduled job. Retrying a deterministic error immediately is pointless: it will fail again.

**Service errors** (probabilistic or infrastructural):

- **timeout or service unreachable**: retry, with backoff, a limited number of times; then the record goes to human review with the reason "classification unavailable";
- **invalid output** (malformed JSON, non-existent category): don't retry endlessly hoping for a better answer; at most a second attempt, then `other` with zero confidence and human review;
- **low confidence**: not an error, an outcome. The record goes to human review, and it's normal for that to happen.

The golden rule: **a service error must never block saving the record**. The Case must exist even if classification fails. That's why the callout sits on the asynchronous path and only writes `AI_*` fields: in the worst case, the record stays unclassified and ends up in the manual queue, exactly as before the model existed.

On idempotency: if the service is called twice for the same record (a retry, a record update that re-triggers the Flow), it must return the same result or at least not create double effects. Since it only writes classification fields, a double effect is harmless; but it's still wise to record the classification version and time on the record, and not reclassify if the text hasn't changed.

## Maintenance costs at 18 months

The "Flow or LLM" decision is almost always made looking at the build cost. The real cost lies in the following eighteen months. Here's what I've seen happen, with indicative estimates.

**Well-designed Flow:**

- build: from a few hours to a few days for an average process;
- maintenance: changes when business rules change, made by an admin, tested in a sandbox, released with the org's procedures;
- main risk: accumulation of overlapping, poorly documented Flows, which makes every change slow. Fought with naming conventions, one Flow per object and per moment (before/after save), minimal documentation;
- 18-month cost: predictable, tied to the number of rule changes.

**Classification service with LLM:**

- build: from a few days to two weeks for the first use case (service, prompt, schema, validations, integration, evaluation set);
- ongoing maintenance: model updates (which change behaviour even if the prompt doesn't), evaluation set review, analysis of human corrections, threshold adjustments, new categories when the business changes;
- main risk: **silent drift**. Behaviour slowly worsens (new kinds of emails, an updated model, a change in clients' templates) and nobody notices until corrections in the manual queue double;
- 18-month cost: less predictable, tied to the quality of monitoring. With an evaluation set and metrics on corrections, it's manageable; without, it's a growing debt.

| Item (estimate, 18 months) | Flow for rules | LLM classification service |
|---|---|---|
| Initial build | 1–5 days | 5–15 days |
| Recurring maintenance | 0.5–2 days/month, depending on rule changes | 1–3 days/month (evaluation, thresholds, drift) |
| Running cost | included in the licence | €20–200/month (self-hosted inference or EU API, depends on volume) |
| Skills required | Salesforce admin | admin + developer + someone who assesses quality |
| Main risk | accumulated complexity | silent drift |

The comparison doesn't say "Flow is better". It says the model should be used **where its cost is repaid by the manual work it removes**: sorting 300 emails a day by hand costs much more than a classification service, even with its maintenance. Calculating the renewal date with a model costs more than a formula and removes nothing.

## Governance: change sets vs prompts

A mature Salesforce org has governance for changes: sandbox, tests, release via change sets or a metadata-based pipeline, approval, release window. A Flow doesn't reach production without going through that.

An LLM service's prompt, in most projects I've seen, reaches production with an "I changed two words in the prompt, now it works better". No tests, no version, and nobody in the org knows the classification behaviour has changed.

The rule is simple: **the prompt is code, and follows the same process**. Concretely:

- prompt, output schema and thresholds live in a repository, versioned;
- every change goes through an **evaluation set** (a few hundred real anonymised texts with the correct classification) and is not released if accuracy on critical categories drops;
- prompt and model version are written on the Salesforce record together with the classification (`AI_Model_Version__c`), so you can always reconstruct who classified what and with which version;
- updating the underlying model is a change like any other, even if the prompt doesn't change;
- confidence thresholds are configuration (Custom Metadata in Salesforce, or service configuration), not constants in the prompt.

```yaml
# case-classifier/release.yaml — release gate
prompt_version: "2026-11-02"
model: case-classifier-v7
evaluation_set: eval/case-email-2026q3.jsonl   # 600 anonymised emails, hand-labelled
release_thresholds:
  min_overall_accuracy: 0.88
  min_per_category:
    delivery_complaint: 0.90
    quality_complaint: 0.90
    order: 0.93
  max_false_negatives_churn_risk: 0.05
routing_confidence_threshold: 0.80      # below: human review
approved_by: customer_care_manager
```

Building and maintaining an evaluation set is a topic in itself: measure task success and side effects, not chatbot-style text metrics.

## Choice matrix for 10 typical automations

Here are ten automations that appear in almost every org I've seen, with the choice I'd make and why.

| # | Automation | Choice | Why |
|---|---|---|---|
| 1 | Calculating amounts, VAT, list-price discounts | **Flow / formula** | Exact rule; a model only adds risk |
| 2 | Lead assignment by territory, industry, size | **Flow** | Rule table; must be verifiable and explainable |
| 3 | Renewal reminders at 60/30/7 days | **Scheduled Flow** | Structured dates and fields; no text to interpret |
| 4 | Sorting incoming emails (Email-to-Case) by request type | **Hybrid** | Free text → classification → deterministic routing with threshold |
| 5 | Extracting order number and amount from an attached PDF | **Hybrid** | The model extracts, validation checks against master data, Flow updates |
| 6 | Finding duplicate accounts with different names | **Hybrid, with review** | Rules for obvious cases (same VAT number), model for ambiguous ones, always human confirmation before merge |
| 7 | Moving opportunity to "Closed Won" when the contract is signed | **Flow** | Precise event (contract signed), economic effect; no ambiguity allowed |
| 8 | Summarising call notes with next steps | **LLM (assisted)** | Free text, output for the person; the salesperson confirms before it becomes a task |
| 9 | Approving a non-standard discount | **Flow / approval process** | A decision with accountability; the model at most prepares the summary for the approver |
| 10 | Flagging churn risk from emails and notes | **Hybrid** | The model flags with confidence, the rule decides escalation, a person contacts the client |

The pattern that emerges is clear. Where input is structured and output is an action, Flow. Where input is text and output is data, model, with validation. Where you need both, hybrid, with the model producing fields and Flow deciding. None of the ten rows requires an agent orchestrating Salesforce autonomously.

## Implementation path, step by step

1. **Inventory the manual queues.** Where, today, does a person read text and decide by hand? How many times a day? How much time per case? These are the candidates, not "the Flows we could replace".
2. **Pick a single case** with high volume and contained risk (typically sorting incoming emails).
3. **Build the evaluation set**: 300–600 real anonymised examples, labelled by those who do the work today.
4. **Define closed categories and fields** with the same manager. An "other" category is mandatory.
5. **Build the service** (self-hosted or EU endpoint), with output schema, domain validations and version.
6. **Measure on the evaluation set** before touching Salesforce. If accuracy on critical categories isn't sufficient, stop here.
7. **Create the `AI_*` fields** and permissions: only the integration user (or the Flow) writes them, users see them.
8. **Create the Flow** with asynchronous path, callout with Named Credential, fault path and field writes.
9. **Shadow phase** of 2–4 weeks: the classification is written but routing stays manual. People see the suggestion and confirm or correct it.
10. **Turn on automatic routing** above threshold, with a review queue below threshold.
11. **Monitor** corrections and per-category accuracy; review thresholds and prompts with the release gate.

## Typical failures and how to spot them in the logs

**Callout in the wrong transaction.**

```text
FLOW_ELEMENT_ERROR  Case_Classify_Email | HTTP_Classify
System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
```

The callout is on the synchronous path after a record update. Move it to the asynchronous path.

**Classifications always below threshold.**

```text
2026-11-13T09:12:44 classify record=500Qy… category=other confidence=0.00 result=invalid_schema
2026-11-13T09:12:51 classify record=500Qy… category=other confidence=0.00 result=invalid_schema
```

The model returns output that doesn't respect the schema: a model update, an untested prompt change, or texts longer than expected being truncated. The manual queue fills up: it's the system degrading safely, but it needs fixing.

**Slow drift.** No log line shows it: you see it in the weekly metric of human corrections. If the share of classifications corrected by hand goes from 6% to 14% in two months, something has changed in the inputs (a new template from a large client, new kinds of requests) or in the model.

**Cascading reclassifications.**

```text
2026-11-13T10:01:02 classify record=500Qy…AbC version=7 (trigger: update)
2026-11-13T10:01:09 classify record=500Qy…AbC version=7 (trigger: update)
2026-11-13T10:01:15 classify record=500Qy…AbC version=7 (trigger: update)
```

The Flow writes the `AI_*` fields, the update re-triggers the Flow, which calls the service again. You need an entry condition that excludes updates to classification fields only, or a "text unchanged" check.

**Invented extracted fields.** The extracted order number doesn't exist in master data. If you see `order_number_not_found` frequently in the log, the model is "completing" incomplete references: validation is stopping them, but the prompt deserves a review.

## When NOT to do it

- **When the manual queue is small.** Twenty emails a day to sort is ten minutes of a person's time. It doesn't justify a service, an evaluation set and monthly maintenance.
- **When the real problem is badly made rules.** If routing is wrong because rules are old or overlapping, fixing the Flow costs less and solves more.
- **When nobody labels.** Without an evaluation set built by those who know the work, you don't know whether the model works. And if you don't know, you shouldn't route anything automatically.
- **When the action has direct economic effects.** Prices, discounts, credits, invoices: there the model at most prepares a summary for a person.
- **When the texts contain data that cannot leave the org** and you don't have a self-hosted or EU inference option with adequate guarantees. Data question first, architecture second: the picture is in the piece on [GDPR, ChatGPT and CRM data]({{ '/en/blog/gdpr-chatgpt-crm/' | relative_url }}).

## Operational checklist

- [ ] The use case comes from a measured manual queue (volume, time per case), not from "let's add AI".
- [ ] Exact rules (calculations, assignments, stage transitions) stay in Flow, formula or Apex.
- [ ] The model produces only data in `AI_*` fields, never actions or business fields.
- [ ] Closed categories, with a mandatory "other"; output schema validated by the service.
- [ ] Domain validation on extracted fields (references checked against master data).
- [ ] Callout on the asynchronous path, with Named Credential and fault path.
- [ ] A service error never blocks saving the record.
- [ ] Confidence threshold as configuration; below threshold, human review queue.
- [ ] Model and prompt version written on the record.
- [ ] Evaluation set and release gate for every prompt or model change.
- [ ] Weekly metric of human corrections, per category.
- [ ] Flow entry conditions that prevent cascading reclassifications.
- [ ] Shadow phase completed with numbers before turning on automatic routing.

## The verdict

The question "Salesforce Flow or MCP agent?" is badly posed, because it pits two tools that do different things against each other. Flow is code with contracts: deterministic, versioned, verifiable, and *safer* than any model when the rule exists. The language model is the only reasonable tool when there's mess to read — free emails, notes, attachments — and turn into something the rules can use.

The architecture that holds over time puts them in sequence, not in opposition: the event in Salesforce, the Flow calling a classification service, the service returning data with a confidence, the Flow deciding with rules and thresholds, a person looking at the uncertain cases. The model produces data, the rules produce actions. Everything else — the LLM inside every Flow, the agent orchestrating the org, business rules hidden in a prompt — is technical debt with a nice demo.

If you're deciding where to put a language model in your CRM processes and want to do it without dismantling what already works, you'll find my background in the [biography]({{ site.main_site }}/biografia/) and the rest of my work on [antoniotrento.net]({{ site.main_site }}/). The other pieces on agents acting on real systems are collected in the guide on [agents that act]({{ '/en/pillar/agents-that-act/' | relative_url }}).

## FAQ

### When should you use Salesforce Flow instead of an AI agent?

When there is a rule that gives the right answer: calculations, territory assignments, stage transitions, date-based reminders, approvals according to a matrix. In these cases Flow is deterministic, versioned and verifiable, and a language model only adds cost, latency and the risk of unexplainable errors.

### When is an LLM really needed in Salesforce?

When the input is unstructured text and the question is interpretive: sorting free emails, extracting data from attachments, summarising call notes, flagging churn risk. In these cases the model turns the mess into structured fields, which the rules then use.

### What is the "classify → field → Flow" hybrid pattern?

It is an architecture in which a Flow, when a record arrives, calls an external classification service; the service returns category, extracted fields and confidence; the Flow writes them into dedicated fields and then applies deterministic rules, routing automatically above a confidence threshold and to human review below it.

### Why must Flow call the service and not the other way round?

Because orchestration must stay where there are transactions, versions, permissions and audit. If the service with the model decides which records to change and how, the process becomes hard to test, explain and stop. With Flow as orchestrator, the model is just a data provider.

### How do you handle a classification service error?

The callout goes on the asynchronous path, so an error never blocks saving the record. Timeouts and unavailability are retried with backoff a limited number of times; invalid outputs produce an "other" classification with zero confidence. In both cases the record ends up in the manual review queue, as before the model was introduced.

### Why shouldn't you put an LLM in every Flow?

Because every call adds latency, cost and an external dependency, and brings a prompt to version and test. Spreading model calls across all the org's Flows creates dozens of undocumented probabilistic behaviours. The model should be used only where it removes real manual work on unstructured text.

### How do you version prompts in a Salesforce org?

By treating them as code: prompt, schema and thresholds in a repository, every change evaluated on a set of labelled examples with minimum per-category accuracy thresholds, prompt and model version written on the classified record. Confidence thresholds live in configuration, not in the prompt text.

### How much does it cost to maintain an LLM classification service?

Roughly 5 to 15 days to build the first use case, one to three days a month of maintenance for evaluation, thresholds and drift, and from a few tens to a few hundred euros a month of inference depending on volume. It pays off when it removes substantial manual work, such as sorting hundreds of emails a day.

### Can an MCP agent replace Salesforce Flows?

Not as a process engine. An MCP agent is useful for person-assisted tasks, with minimal permissions and approvals, but it doesn't offer the determinism, verifiability and governance needed for automations that touch money, stages and assignments. For those, Flow remains the safer choice.

### How do you notice model drift?

By measuring every week the share of classifications corrected by hand, per category, and periodically repeating the evaluation on the reference set. A steady increase in corrections indicates that inputs or the model have changed, and that prompts or thresholds need review.
