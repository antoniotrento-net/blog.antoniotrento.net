---
lang: en
permalink: /en/blog/salesforce-mcp-production-agent/
alt_url: /it/blog/mcp-salesforce-agente-produzione/
title: "MCP on Salesforce: why a chatbot on the CRM isn't enough, and how to let the agent execute without burning governor limits"
date: 2026-09-20 07:30:00 +0200
author: "Antonio Trento"
description: "A chatbot that 'reads opportunities' closes nothing. To execute actions on the CRM you need an MCP tool layer designed with idempotency, least privilege and respect for Salesforce governor limits."
keywords: ["salesforce mcp production agent", "model context protocol salesforce", "governor limits", "crm agent", "salesforce api jwt"]
image: /assets/images/posts/mcp-salesforce-agente-produzione.jpg
pillar: agenti-esecuzione
related: [/en/blog/llm-product-vs-chatbot/, /en/blog/self-hosted-n8n-openai-privacy/]
---

## The chatbot that "reads Opportunities" and closes nothing

You've seen the demo: a chatbot wired to Salesforce that answers "you have 14 open Opportunities for €340,000, the biggest one has been stuck for 20 days". Nice. Then you ask "move it to the next stage and create a follow-up task" and the chatbot answers... with a neat paragraph on *how you would* move it. It didn't move it. It didn't create anything. It **read** and it **chatted**, but it didn't **execute**. That's the structural limit of the chatbot on the CRM: it can read, it can't act — and a CRM where you close nothing is a CRM you look at, not one you use.

Making an agent *execute* actions on Salesforce in production is a completely different problem from making it chat, and it isn't an "AI for sales" problem: it's an **integration** problem. Protocol, quotas, permissions, idempotency, audit. That's where **MCP** (Model Context Protocol) comes in as an action layer: a standard way to give an agent *tools* — functions it performs on the CRM — with precise boundaries on what it can and cannot do. In this article we look at how you design an MCP agent on Salesforce that actually executes, without making a mess: which tools are safe and which are weapons, how not to burn governor limits, how to make every action idempotent and reversible, how to give the integration user least privilege, and what you should **never** let an LLM do. With the JSON example of a tool, the limits table, and the kill-switch. Because between "reading Opportunities" and "touching production data" there is a gulf, and it's all engineering.

## What MCP is in practice (tools, resources, auth) without the hype

MCP, stripped of the hype, is a **protocol for giving a model tools in a standard way**. Instead of stuffing the integration logic into the prompt or into scattered code, you expose an "MCP server" that declares three things:

- **Tools**: the actions the model can *ask* to execute. Each one has a name, a description, and a precise schema of the inputs (what's needed to call it). Example: `get_opportunity`, `update_opportunity_stage`, `create_task`. The model doesn't execute directly: it *asks* to execute a tool with certain parameters, and your server decides whether and how to do it.
- **Resources**: the data the model can *read* (read-only), exposed in a controlled way.
- **Auth**: how the server authenticates against the destination system (here, Salesforce) — and that's where security is actually played.

The important thing to understand, and what the hype hides, is this: **the model does not have direct access to Salesforce. It has access to the tools you decide to expose.** MCP is a layer in the middle that you control. If you don't expose a "delete Opportunity" tool, the model *cannot* delete Opportunities, however much the user asks it to or however much it "decides" it wants to. That flips the security problem: you don't have to trust the model, you have to design the tool layer well. The model proposes; **your MCP server disposes**, with the rules you put in it. It's the same logic as the [reliable product built around the LLM instead of the chatbot that promises everything]({{ '/en/blog/llm-product-vs-chatbot/' | relative_url }}): the value and the safety sit in the process around the model, not in the model.

## The tool map: safe, guarded, and weapons

The heart of the design is **classifying tools by how dangerous they are** and treating them accordingly. Not all tools are equal: some you can let the agent run, others need a guardian, others should never be exposed to an LLM.

- **Safe tools (read-only).** `get_opportunity`, `list_open_opportunities`, `get_account`. They read and that's it. The risk is at most exposing data to someone who shouldn't see it (handled by permissions), but they don't *break* anything. The agent can use them freely.
- **Guarded tools (targeted, reversible writes).** `create_task`, `add_note`, `update_single_field` with tight filters. They modify, but in a circumscribed and reversible way. They get exposed with guardrails: rigid schema, one record at a time, limited fields, and — as we'll see — idempotency.
- **Weapon tools (never autonomous).** `delete`, `mass_update` with no filter, `convertLead`, bulk deletions. These must **never** be given to an LLM running autonomously. A massive `delete` fired by a model that misunderstood a request is an irreversible disaster on production data. If they are really needed, they go through a **human approval queue** (later), never directly.

The design rule is: **expose the minimum indispensable, and for every tool ask yourself "what happens if the model calls it with the wrong parameters?".** If the answer is "reversible, circumscribed damage", ok. If it's "an irreversible disaster", that tool is not exposed to the agent — or it becomes a *proposal* a human approves. This tool map is the most important security document of the project, more than any configuration: it's where you decide, explicitly, what the agent **cannot** touch.

Here's what the definition of a guarded tool looks like, in JSON — note the rigid schema and the constraints:

```json
{
  "name": "update_opportunity_stage",
  "description": "Moves ONE Opportunity to a stage among those allowed. Does not close, does not delete, does not touch the amount.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "opportunity_id": {
        "type": "string",
        "pattern": "^006[A-Za-z0-9]{15}$",
        "description": "Salesforce ID of the Opportunity (prefix 006)"
      },
      "new_stage": {
        "type": "string",
        "enum": ["Qualification", "Proposal", "Negotiation"],
        "description": "Destination stage: intermediate advances only, not Closed"
      },
      "idempotency_key": {
        "type": "string",
        "description": "Unique key to avoid double execution on retry"
      }
    },
    "required": ["opportunity_id", "new_stage", "idempotency_key"],
    "additionalProperties": false
  }
}
```

Three defenses in this schema alone: the `pattern` on the ID (it doesn't accept malformed IDs or IDs of other objects), the `enum` on stages (it can't take it to "Closed Won" on its own — that's a human decision), and the mandatory `idempotency_key`. `additionalProperties: false` stops unexpected fields being slipped in. The schema *is* the security.

## Governor limits, concurrent API, bulk vs REST: the numbers that stop you

Here's the constraint people coming from the "AI" world don't know, and that blows up agents on Salesforce in production: **governor limits**. Salesforce is not an open database: it has rigid quotas on how many API calls you can make, how many in parallel, how large. An agent that *loops* — reads, reasons, calls, re-reads, calls again — multiplies the calls, and burns the daily quota fast.

The limits that matter for an agent (orders of magnitude — **always verify on your org**, they depend on edition and licenses):

| Limit | Order of magnitude | Impact on the agent |
|---|---|---|
| **API calls / 24h** | from thousands to millions (by edition + number of licenses) | An agent that loops over many records burns them: every "think and call again" is a call |
| **Concurrent long-running requests (>20s)** | ~25 in parallel | Heavy simultaneous queries block each other; the agent must be serialized or optimized |
| **Rows per SOQL query** | limits per query/transaction | On large sets you need pagination, not "fetch everything" |
| **Bulk API vs REST API** | Bulk for large volumes in batches; REST for single transactions | Massive import/update → Bulk (async, in batches); point actions → REST |
| **Short-term rate limit** | thresholds per time window | Bursts of close-together calls get rejected: you need throttling |

The strategies so you don't smash into these limits:

- **Batching instead of loops.** If you have to update 500 records, don't make 500 REST calls in an agent loop: use a single bulk or composite operation. A naive agent loops and burns 500 calls; a designed agent makes one.
- **Read once, reason locally.** Don't make the agent re-read the same data ten times during reasoning. Load the necessary context once, let it reason, then execute.
- **Serialize heavy operations.** Respect the concurrency limit: an ordered queue is better than twenty-five heavy queries throttling each other.
- **Monitor remaining quota.** Salesforce exposes how many calls you have left in the 24h. The agent (or the layer around it) must know that and **stop** before exhausting it, not discover it when calls start failing.

The point is that an agent on Salesforce lives inside a **finite call budget**, and designing it means spending that budget sparingly. Whoever ignores governor limits discovers in production that the agent has exhausted the API quota of the entire company by mid-morning, blocking *all* integrations — not just its own.

## Idempotency: idempotency key, dry-run, preview for the human

Agents get it wrong, retries happen, networks drop mid-operation. On a *read* system it isn't serious. On a system that *executes* actions on production data, it's the source of the most insidious damage: the action executed **twice**. A task created twice is a nuisance; a stage advanced twice, or an amount modified twice, is an error in the data. The defense is **idempotency**: making it so that executing the same action twice has the same effect as executing it once.

Three mechanisms, all necessary:

- **Idempotency key.** Every write action carries a unique key (you saw it in the tool schema). Your MCP server tracks keys already executed: if a call arrives with a key already seen (a retry), it doesn't re-execute it, it returns the previous result. That way a retry doesn't double the effect.
- **Dry-run (trial mode).** Before actually executing, the agent can call the tool in "dry-run" mode, which returns *what would happen* without doing it: "I would move Opportunity 006... from Proposal to Negotiation". Useful to let the agent reason about consequences and for tests.
- **Preview for the human.** For actions that weigh, the tool doesn't execute: it produces a **preview** a human approves before execution. "The agent proposes moving these 8 Opportunities: do you confirm?". It's the anteroom of the approval queue.

Idempotency isn't an optional to add "later": it's part of the tool design, like the mandatory `idempotency_key` in the schema. An agent that executes actions without idempotency is a time bomb: sooner or later a retry or a double submit makes a mess, and you spend hours figuring out why that record was modified twice. It's the same rigor on retries that makes a [node that fires without control in a workflow]({{ '/en/blog/self-hosted-n8n-openai-privacy/' | relative_url }}) dangerous: what repeats, if it isn't idempotent, does damage.

## JWT and the integration user: least privilege, never admin

How does the agent authenticate against Salesforce? With the **JWT bearer flow**: a Connected App configured for server-to-server authentication via a certificate, with no interactive password and no tokens that expire all the time. It's the standard for unattended integrations.

But authentication is half the story. The other half, more important, is: **with which permissions?** And that's where the worst damage is done, out of laziness. The temptation is to run the agent as **System Administrator** — "that way everything works and I don't have to think about it". It's security mistake number one: an admin agent can do *anything* on *any* data, and if it gets it wrong (or if someone compromises the integration) the damage is total.

The rule is **least privilege**:

- **Create a dedicated integration user**, don't reuse a human user or the admin. That way its actions are traceable and its permissions isolated.
- **Give it only the permissions it needs**, via a tight permission set: access to *only* the objects and fields its tools touch (Opportunity, Task, not the whole CRM), and only the operations required (read, create tasks, update certain fields — not delete).
- **No dangerous permissions.** No "Modify All Data", no access to sensitive objects that aren't needed, no mass-delete capability.

That way, even if the model "goes crazy" or is manipulated with a malicious prompt, **it cannot do more than what the integration user is permitted to do** — and that user has permissions cut to the bone. Security doesn't rest on the hope that the model behaves well: it rests on the fact that, by construction, it *cannot* do damage outside its perimeter. Least privilege on the integration user is the second line of defense after the tool map, and together they make the agent safe even when it gets it wrong.

## Observability: every tool call is an audit trail

An agent that executes actions on production data without leaving a trace is unmanageable and indefensible. When something goes wrong — and it will — you have to be able to answer: *what did the agent do, when, on which record, with which parameters, and what was the data before?* If you can't, you don't have an agent in production: you have a problem waiting to show up.

Every **tool call must be an audit event**, recorded with:

- **Who**: the integration user and, if the action comes from a human request, who asked for it.
- **What**: which tool, with which exact parameters.
- **When**: timestamp.
- **On what**: which record (ID).
- **Before/after**: the state of the data before and after, where it makes sense, so you can reconstruct and — if needed — undo.
- **Correlation ID**: an identifier that ties all the actions of the same agent "session", so you can follow its reasoning.

This audit trail serves three things: **debug** (when a datum changed, you know who and why), **security** (you detect anomalous agent behavior before it does systematic damage), and **compliance** (you demonstrate control over automatic actions on the data). It's also where you read the **typical failures**: from the tool-call logs you see if the agent is looping (too many close-together calls = governor-limits risk), if a tool fails repeatedly (wrong schema or missing permission), if a retry re-attempted an action (verify that idempotency held). An observable agent is a governable agent; an opaque one is an incident waiting.

## The kill-switch and the approval queue

Two safety mechanisms every agent in production must have, and that often are missing until the disaster happens.

**The kill-switch.** A switch that **instantly disables all write tools**. If you notice the agent is doing something wrong — it's looping, it's modifying records it shouldn't, a prompt has taken it off the road — you must be able to stop it *immediately*, without shutting down the whole system or waiting for a deploy. Concretely it's a flag (in a config, a variable, a database row) that the MCP server checks before every write action: if it's on, weapon tools and guarded tools refuse to execute and answer "system in read-only". Read tools keep working. It's the emergency brake: you hope you never use it, but without it you don't get in the car.

**The approval queue.** For actions that weigh — the ones you classified as guarded-important or as weapons — the agent doesn't execute: **it queues a proposal** a human approves or rejects. In practice:

1. The agent decides an action should be done (e.g. advancing 8 Opportunities).
2. Instead of executing it, it creates an **approval request** with the details (what, on which records, expected effect — the preview from earlier).
3. A human sees it, checks it, and **approves or rejects**.
4. Only if approved does the MCP server actually execute — with the idempotency key, the audit, and everything else.

The approval queue is what keeps the human in the loop on the decisions that matter, without giving up automation on the ones that don't. The agent does the reversible, low-risk things on its own (create a task, add a note); it proposes the risky ones to the human. It's the boundary I repeat throughout my work: **the machine prepares and executes the banal, the human decides what weighs.** An agent without an approval queue on heavy actions is an agent you've delegated decisions it shouldn't take on its own.

## What breaks in production (and how you read it from the logs)

Typical failures of an MCP agent on Salesforce aren't mysterious: they're almost always limits, permissions, or retries. Here's how you recognize them from the audit trail and the logs, before they become a serious problem.

- **`REQUEST_LIMIT_EXCEEDED`: API quota exhausted.** Symptom: from a certain moment *all* calls fail with this error, and not only for the agent — for all of the org's integrations. Cause: the agent looped and burned the daily quota. In the logs you see it as a spike of close-together tool calls just before the block. Fix: batching, throttling, and remaining-quota monitoring with a preventive stop.
- **`INSUFFICIENT_ACCESS` / `FIELD_INTEGRITY_EXCEPTION`: missing permission.** Symptom: a tool fails systematically on a certain operation or field. Cause: the integration user's permission set doesn't cover that object/field — it often shows up when you add a new tool. It's a *healthy* error: least privilege is working. Fix: grant the specific permission that's needed, not "Modify All".
- **Action applied twice.** Symptom: a record turns out modified twice (stage advanced two steps, two identical tasks). Cause: a retry without idempotency, or a double submit. In the audit you see it as two tool calls with identical parameters seconds apart. Fix: verify that the idempotency key is mandatory and tracked — if it happened, it wasn't really.
- **Concurrency throttled.** Symptom: heavy operations slow down or time out under load. Cause: too many long-running requests in parallel against the concurrency limit. Fix: serialize, or move volumes onto Bulk API.
- **The agent "decides badly" on an ambiguous case.** Symptom: in the audit you see a sequence of tool calls that doesn't make sense relative to the request. Cause: the model misunderstood. Fix: this is exactly why heavy actions go through the approval queue — the human intercepts the wrong proposal before it becomes a fact. If there was no queue, the kill-switch and the audit at least let you stop and reconstruct.

On the **cost** front (stated estimates): the LLM's token cost is often the smaller line. The two that actually matter are Salesforce's **API quota** — finite, and if you burn it you block the company: it's worth more than any token — and, if you run the model locally so CRM data doesn't leave, the **GPU** (an 8-14B model in ~8-24 GB VRAM, as for the sovereign stack). The honest bill for an agent isn't "how much the tokens cost", it's "how many API calls it spends and where the model runs".

## The implementation path, step by step

1. **Map the tools** you actually need, classifying them (safe / guarded / weapons). Start from the minimum: what must the agent *close*?
2. **Design the schemas** of the tools with rigid constraints (pattern on IDs, enum on values, `additionalProperties: false`, mandatory idempotency key).
3. **Create the dedicated integration user** and the least-privilege permission set (only the objects/fields/actions needed). Never admin.
4. **Configure the JWT bearer flow** with the Connected App and the certificate.
5. **Implement the MCP server** that exposes the tools, applies idempotency, checks the kill-switch, and writes the audit trail for every call.
6. **Add the approval queue** for guarded-important tools and weapons.
7. **Put the limits in place**: call throttling, remaining API quota check, serialization of heavy operations.
8. **Test in sandbox** with dry-run and with adverse scenarios (the agent that misunderstands, the retry, the malicious prompt) before touching production.
9. **Go to production with the kill-switch ready** and the audit under observation for the first days.

## A real session, step by step

Let's see the pieces together on a real request: a salesperson writes to the agent *"the Opportunities stuck for more than two weeks in Proposal, send them a reminder and move them to Negotiation if the client has replied"*. How a well-designed agent behaves.

1. **Reads** (safe tool): `list_open_opportunities` filtered by stage "Proposal" and last activity > 14 days. One call, with pagination if the set is large — not a loop.
2. **Reasons locally** on the loaded context: which have client replies, which don't. It doesn't re-read the same records ten times.
3. **For reversible, low-risk actions** (creating a reminder task): uses the guarded tool `create_task`, one per Opportunity, each with its own idempotency key. It does them on its own, and every call lands in the audit.
4. **For the action that weighs** (moving the stage): *it doesn't execute*. It produces a preview — "I would move these 5 Opportunities from Proposal to Negotiation" — and puts it in the **approval queue**.
5. **The salesperson approves** (or removes two Opportunities they know aren't ready). Only then does the MCP server execute the `update_opportunity_stage` calls, with idempotency key and audit.

Note the balance: the agent has *closed* something (the reminders went out, the stages updated) — unlike the chatbot that chats — but the decisions that weigh went through a human, the API calls were few and targeted, and every action is traced and reversible. If halfway through the salesperson had seen something odd, the kill-switch would have stopped writes instantly. This is "the agent that executes without making a mess": not a model left free on the CRM, but a model inside a fence of tools, permissions, and approvals.

## When to stay on Flow/Apex and not put the LLM in the middle

Technical honesty, the most important of this article: **often the LLM isn't needed at all.** Salesforce already has the tools to automate — **Flow** (declarative automation) and **Apex** (code) — and for a great many tasks they are the right answer, not an AI agent.

Stay on Flow/Apex, and don't put the LLM in the middle, when:

- **The logic is deterministic.** "When an Opportunity exceeds €50,000, create a task for the manager." This is a fixed rule: a Flow does it reliably, fast, for free, and without hallucinations. Putting an LLM on it adds cost, latency, and unpredictability for zero benefit.
- **The volume is high and repetitive.** Massive, regular processing is done with Apex and batch, which respect governor limits by design. An LLM agent that loops over large volumes is the worst and most expensive way to do it.
- **You don't need to interpret language or ambiguity.** The LLM makes sense when there's something unstructured to *interpret* — a natural-language request, text to understand, a decision with nuance. If the input is structured and the rule is clear, the LLM is over-engineering.

The LLM (via MCP) makes sense when there is **interpretation + action**: understanding an ambiguous natural-language request and translating it into a sequence of actions on the CRM, with judgment on unforeseen cases. Outside that, Flow and Apex win. Whoever puts an AI agent where a Flow would have been enough has added a jet engine to a bicycle: more expensive, more fragile, and it doesn't arrive first. Knowing how to say "here the LLM isn't needed" is part of the craft of whoever integrates for real.

## Operational checklist before production

- [ ] Tools **classified** (safe / guarded / weapons); weapons are not exposed to the agent.
- [ ] Tool schemas with **rigid constraints** (pattern, enum, `additionalProperties: false`).
- [ ] **Idempotency key** mandatory on every write; retries don't double the effect.
- [ ] Dedicated **integration user** with a **least-privilege** permission set; never admin.
- [ ] **JWT bearer flow** configured; no credentials in the clear.
- [ ] **Kill-switch** that instantly disables writes.
- [ ] **Approval queue** for heavy actions; the human in the loop where it counts.
- [ ] Complete **audit trail** for every tool call (who/what/when/record/before-after).
- [ ] **Governor limits** watched: throttling, remaining quota monitored, heavy operations serialized/bulk.
- [ ] Tested in **sandbox** with adverse scenarios before production.
- [ ] Verified that deterministic tasks sit on **Flow/Apex**, not on the LLM.

## The verdict: the agent is integration, not magic

A chatbot that reads Opportunities and closes nothing is a demo. An MCP agent on Salesforce in production is **integration engineering**: tools designed with rigid schemas, classified by how dangerous they are, with weapons never in the model's hands; idempotency on every write; an integration user at least privilege; governor limits watched; audit on every action; kill-switch and approval queue to keep the human on the decisions that weigh. The model proposes, your MCP layer disposes — and security doesn't rest on the hope that the LLM behaves well, but on the fact that, by construction, it cannot do damage outside its perimeter. And often, the most professional answer is "here a Flow is enough": knowing that is what distinguishes whoever integrates from whoever puts AI everywhere for fashion.

This is a brick of the [guide to agents that actually execute]({{ '/en/pillar/agents-that-act/' | relative_url }}), where automation touches production systems with judgment instead of enthusiasm. If you want to see what a safe agent looks like on *your* CRM and *your* processes, start from [who I am and how I work]({{ site.main_site }}/biografia/) or drop me a couple of lines in [contacts]({{ site.main_site }}/contatti/).

## FAQ

**1. Why isn't a chatbot on the CRM enough?**
Because it can read and chat, not execute. It tells you what you would do, but it doesn't move the Opportunity, doesn't create the task, doesn't update the record. Making it *execute* actions is an integration problem (protocol, permissions, idempotency, limits), not a conversation problem.

**2. What is MCP, in two words?**
A protocol for giving a model tools in a standard way, with precise input schemas and controlled authentication. The model doesn't touch Salesforce directly: it asks to execute a tool, and your MCP server decides whether and how. You control the layer in the middle.

**3. How do I stop the agent deleting or modifying everything?**
With two defenses combined: you don't expose weapon tools (`delete`, mass update with no filter, `convertLead`) to autonomous execution, and you give the integration user least privilege (tight permission set, never admin). That way, even if the model gets it wrong or is manipulated, it cannot do more than the little its user is permitted to do.

**4. What are governor limits and why do they concern me?**
They are Salesforce's rigid quotas on daily API calls, concurrent requests, query size. An agent that loops burns the quota fast, blocking all of the company's integrations. You watch them with batching instead of loops, a single read of the context, serialization of heavy operations, and remaining-quota monitoring.

**5. What is idempotency and why is it mandatory?**
It's the guarantee that executing the same action twice has the same effect as executing it once. You need it because retries and double submits happen: without idempotency, an action is applied twice and corrupts the data. You get it with an idempotency key tracked by the server, plus dry-run and preview for heavy actions.

**6. Should I run the agent as administrator?**
Absolutely not: it's security mistake number one. Create a dedicated integration user with a permission set that grants only the objects, fields, and operations its tools need. Least privilege is what limits the damage when (not if) something goes wrong.

**7. What is the kill-switch and when do I use it?**
A switch that instantly disables all of the agent's writes, leaving reads active. You use it when you notice the agent is getting it wrong — it loops, it modifies things it shouldn't, a prompt has taken it off the road. It's the emergency brake: without it, you shouldn't put an agent in production.

**8. How do I keep a human in the important decisions?**
With an approval queue: for actions that weigh, the agent doesn't execute but proposes (what, on which records, expected effect), and a human approves or rejects before execution. The agent does the reversible and low-risk on its own; it proposes the important. It's the boundary between useful automation and dangerous delegation.

**9. When should I NOT use an LLM agent on Salesforce?**
When the logic is deterministic (a fixed rule → Flow), when the volume is high and repetitive (→ Apex/batch), or when there's no natural language or ambiguity to interpret. The LLM only makes sense where you need to interpret the ambiguous and translate it into actions. Elsewhere it's cost, latency, and unpredictability for zero benefit.

**10. How much does it cost in practice?**
It depends on where the model runs (local or cloud) and on volumes, but the real cost to watch isn't only tokens: it's Salesforce's **API quota**, which is finite. A badly designed agent that loops can "cost" more in burned API calls (blocking the company) than in tokens. Designing to spend few calls is part of the budget, as much as choosing the model.
