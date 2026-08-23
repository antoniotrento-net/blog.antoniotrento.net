---
lang: en
permalink: /en/blog/salesforce-agent-kill-switch/
alt_url: /it/blog/kill-switch-agente-salesforce/
title: "Kill switch for agents that write to Salesforce: dry-run, approval queue, and why \"confirm in chat\" is not a control"
date: 2026-09-29 07:30:00 +0200
author: "Antonio Trento"
description: "How to design a kill switch for agents that write to Salesforce: payload dry-run, approval queue with signed links, thresholds, global freeze and rollback. Why 'yes in chat' is not a security control."
keywords: ["salesforce agent kill switch", "human in the loop crm", "llm dry-run", "tool call approval", "production agent security", "agent approval queue"]
image: /assets/images/posts/kill-switch-agente-salesforce.jpg
pillar: agenti-esecuzione
related: [/en/blog/salesforce-mcp-production-agent/, /en/blog/prompt-injection-company-documents/]
---

## "Yes in chat" is not a control, it's theater

The pattern I see most often, and that most often blows up: an agent about to write to Salesforce asks in chat *"Confirm updating 340 opportunities to 'Closed Lost'? (reply YES)"*, someone types YES, and the agent executes. It looks like a human control. It isn't. It's security theater — the appearance of control without the substance.

Why isn't it a control? Because the "YES" arrives **on the same untrusted channel** the agent operates in. A document with a [prompt injection]({{ '/en/blog/prompt-injection-company-documents/' | relative_url }}) can produce the confirmation string on its own, or manipulate *what* is shown to the human before the YES. There is no separate audit log, no separation of duties, no guarantee that the executed payload is the one that was shown, no expiry. It's a button that looks red but isn't wired to anything.

This piece is about the **kill switch for agents that write to Salesforce**, and the viewpoint is precise: **control theory applied to side effects, not bot UX.** I don't care how pretty the conversation is. I care that every write toward the CRM goes through a *real* control — a control that holds even when the model is tricked, even when someone types YES without looking, even when you have to stop everything at three in the morning.

Let's build it piece by piece: dry-run, approval queue with signed links, thresholds, global freeze, rollback where possible, separation of duties, and — the part almost everyone forgets — how to **test** that the kill switch actually works. This article is the operational follow-up to [how I put an MCP agent on Salesforce in production]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}): there the general architecture, here the control mechanism in detail.

## Side effect: chat is not an audit log

Start from the underlying principle. An agent that reasons, summarizes, or proposes is low risk: if it gets it wrong, you have a wrong text. An agent that **writes** — creates records, updates fields, changes owner, closes opportunities — produces **side effects**: persistent state changes in the real world. And side effects are what you control, not the words.

Chat is a terrible control point for three structural reasons:

- **It is not an audit log.** An audit log is immutable, separate, with who/what/when/why. A conversation is ephemeral, mixed with noise, and nobody will use it as evidence in a post-mortem.
- **It is the same channel as the attacker.** If the agent reads external content (email, documents, records), that content sits in the same window as the "confirmation". A payload can fabricate the confirmation or alter the preview.
- **It does not guarantee what gets executed.** Between "the agent shows a summary" and "the agent executes" there is no constraint that the two coincide. The summary says "I update 3 records", the execution touches 340. Chat does not stop that.

The rule I apply: **the control must sit on the side effect, not on the conversation.** Meaning: the agent never calls Salesforce's write API directly. It produces a *write proposal* — a precise data object — that goes through a deterministic control system before it touches the CRM. The rest of the article is how that system is built.

## Dry-run: the agent proposes, the system serializes the PATCH

The first brick is the **dry-run**. The agent does not execute: it produces an exact description of *what* it would do, which the system serializes into a structured, verifiable payload. No natural language, no "I update overdue opportunities": a concrete PATCH, record by record, field by field.

A well-made dry-run payload contains: the Salesforce object, the exact record IDs, the fields to change with *previous* value and *new* value, and a count. The previous value is crucial: you need it for the human preview and for rollback.

```json
{
  "action_id": "act_2026_09_29_a1b2c3",
  "agent": "opp-hygiene-bot",
  "object": "Opportunity",
  "operation": "update",
  "records": [
    {
      "id": "0065g00000ABcDeEAA",
      "changes": {
        "StageName": {"old": "Negotiation", "new": "Closed Lost"},
        "Loss_Reason__c": {"old": null, "new": "No response 90d"}
      }
    }
  ],
  "count": 340,
  "reason": "Opportunities with no activity for 90+ days",
  "created_at": "2026-09-29T09:12:04+02:00",
  "expires_at": "2026-09-29T10:12:04+02:00"
}
```

Note that `records` shows the structure but `count` says 340: in the human preview you show the first N in full *and* the total, so a mass update cannot hide behind an innocent example. That's the difference between "I update one opportunity" and "I update 340": the dry-run makes it impossible to mask.

**LLM dry-run** has a second advantage: you can actually run it "empty" against a Salesforce sandbox, verifying that the PATCH is valid (existing fields, values allowed by picklists, permissions) *before* a human sees it. A payload that would fail anyway never even reaches the queue: you waste less human time and cut errors.

The boundary is sharp: **the agent produces the payload, it does not execute it.** Between the proposal and the execution sits the entire control system. This separation — a brain that proposes, hands that execute under rules — is the same one I use for injection security: the model's output is untrusted until a deterministic control validates it.

## The approval queue: signed links, not "reply YES"

The dry-run payload enters an **approval queue**. This queue is the heart of the system, and it is a deterministic, persistent component with an immutable log. Here is the queue schema:

| Field | Type | Description |
|-------|------|-------------|
| `action_id` | string | Unique ID of the proposed action |
| `agent` | string | Which agent proposed it |
| `object` / `operation` | string | E.g. Opportunity / update |
| `payload` | json | The full PATCH (dry-run) |
| `payload_hash` | string | SHA-256 of the payload: guarantees integrity |
| `count` | int | Number of records impacted |
| `risk` | enum | low / medium / high (from the policy engine) |
| `status` | enum | pending / approved / rejected / expired / executed / failed |
| `approver` | string | Who approved (role + identity) |
| `approved_at` | ts | When |
| `expires_at` | ts | Expiry: after this, it is no longer executable |
| `executed_at` | ts | When executed |
| `result` | json | Outcome + any errors |
| `snapshot_ref` | string | Reference to previous state (rollback) |

Approval happens **out of band**: not in the agent's chat, but via a notification (Slack, email) that leads to a **minimum UI** where the approver sees the exact diff and clicks Approve/Reject. The link is **signed**, not a "reply YES".

Why the signed link and not "reply YES"? Because:

- **"Reply YES" is on the untrusted channel** and can be fabricated by an injection. The signed link leads to a separate, authenticated system the attacker does not control.
- **The signed link binds the approval to the exact payload** via the hash. If the payload changes between preview and execution, the signature doesn't match and execution stops. "Reply YES" binds nothing: you approve an idea, not a payload.
- **The signed link has an identity and a role.** You know *who* approved, in what capacity. "Reply YES" in a shared channel tells you nothing legally or operationally useful.

Here is how you sign the payload, so the queue and the executor can verify that nothing has been tampered with:

```python
import hmac, hashlib, json, time

SECRET = load_secret("APPROVAL_HMAC_KEY")   # in vault, not in code

def sign_payload(payload: dict) -> str:
    """Canonical payload signature: binds approval to execution."""
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hmac.new(SECRET, canonical.encode(), hashlib.sha256).hexdigest()

def approval_link(action_id: str, payload: dict) -> str:
    sig = sign_payload(payload)
    exp = int(time.time()) + 3600            # 1h expiry
    return f"https://approvals.internal.local/a/{action_id}?exp={exp}&sig={sig}"

def verify(action_id: str, payload: dict, exp: int, sig: str) -> bool:
    if time.time() > exp:
        return False                          # expired
    expected = sign_payload(payload)
    return hmac.compare_digest(expected, sig)  # constant-time compare
```

This is **tool call approval** done right: you approve a signed, verifiable payload that expires after an hour, not a sentence in a chat. It is real **human in the loop CRM**, not decorative.

## The minimum approval UI: what the human must see

The signed link leads to a page. If that page is badly designed, you have rebuilt "reply YES" with extra steps: the approver clicks without understanding. The preview is where approval becomes real or stays fake, and it has to be designed with the same care as the rest.

What it must show, in order of importance:

- **The count, large and at the top.** "You are about to modify **340 opportunities**". Not hidden, not at the bottom. The number is the first defense against an accidental mass update.
- **The fields touched, with protected ones highlighted.** If among the fields there is `OwnerId` or `Amount`, they go in red: the approver must know they are authorizing something sensitive, not a routine update.
- **The old → new diff, on a real sample.** Not an invented example: the first 5–10 real rows of the payload, previous value and new value side by side. And a link to see the full list of impacted IDs.
- **The agent's reason.** Why is it proposing this? "Opportunities with no activity for 90+ days". Helps judge whether it makes sense.
- **The expiry, visible.** "This approval expires in 47 minutes". It communicates that this is a decision, not an eternal stamp.
- **Two distinct, asymmetric buttons:** Approve and Reject, with Approve maybe requiring a second confirmation click on high-risk actions. Friction is dosed to the risk, not removed entirely.

What the preview must **not** do: show only a natural-language summary generated by the agent. That summary is untrusted text, and it may not match the payload. The preview shows the **serialized payload**, the source of truth, not its paraphrase. The human approves what will be executed, not what the agent *says* will be executed.

The measure of success for this UI is brutal but honest: **an approver who, looking at it for three seconds, notices that "340" is too much and clicks Reject.** If your preview doesn't allow that at-a-glance rejection, you are not doing human in the loop, you are doing decoration.

## Thresholds: amount, record count, protected fields

Not everything deserves the same friction. If every single note requires human approval, the approver habituates and rubber-stamps everything — and you are back to theater. The policy engine calibrates the control level to the **risk of the side effect**, deterministically.

The risk dimensions I use for Salesforce:

- **Number of records.** An update on 1 record is routine; on 340 it is a mass operation that can wreck the forecast. Above a threshold (e.g. 10 records) → mandatory approval; above a second threshold (e.g. 100) → approval by a senior role.
- **Protected fields.** Some fields are never touched automatically, ever: `OwnerId` (ownership change = commission redistribution), `Amount`, `StageName` toward closed states, IBAN/payment data, fields that trigger downstream automations. A change to a protected field → always approval, at any count.
- **Economic amount.** If the update touches `Amount` or fields that move money/forecast, the euro threshold raises the level.
- **Irreversibility.** Operations that trigger emails to customers, flows, external syncs → always approval, because rollback is impossible (see below).

```python
PROTECTED_FIELDS = {"OwnerId", "Amount", "IBAN__c", "StageName"}
RECORD_THRESHOLD = 10
SENIOR_RECORD_THRESHOLD = 100

def assess_risk(payload: dict) -> str:
    fields = {c for r in payload["records"] for c in r["changes"]}
    n = payload["count"]

    if fields & PROTECTED_FIELDS:
        return "high"                    # protected field: always human
    if n > SENIOR_RECORD_THRESHOLD:
        return "high"                    # large mass: senior role
    if n > RECORD_THRESHOLD:
        return "medium"                  # small mass: approval
    return "low"                         # routine: auto (logged)
```

The logic: **the decision whether a human is needed is never taken by the model.** It is taken by the code, looking at count and fields. Even if the payload "screams" that it is urgent and already approved, the policy engine reads only the numbers and the field names. The agent's persuasive text (or an injection's) is irrelevant to the security decision.

## Global freeze: the real kill switch

Thresholds regulate the normal flow. The **global freeze** is the emergency brake: a switch that stops *all* writes, immediately, with no deploy. That is the definition of a kill switch, and it is surprisingly often missing in the systems I see.

Requirements of a freeze that works:

- **Immediate and with no deploy.** A flag in a place that is fast to change (a table, a Redis key, a config record), which the executor checks **before every single write**. Not a redeploy that takes 10 minutes while the agent keeps writing.
- **Fine-grained.** Global freeze (everything), per agent (only `opp-hygiene-bot`), per object (only Opportunity). So you can stop the culprit without shutting everything down.
- **Time-based.** Automatic writes happen only during business hours, when someone can notice a problem. Outside hours → queue, not execution.
- **Protected.** Anyone who notices a problem must be able to activate the freeze (it's a brake: a false alarm is better than a disaster). Deactivating it must require an authorized role — otherwise the agent itself, or an injection, could "unblock" itself.

The executor checks the freeze first, always:

```python
def execute(action) -> dict:
    # 1. FREEZE: before EVERYTHING, on every write, no exceptions.
    state = read_freeze()               # fast: redis/table
    if state.active(agent=action.agent, obj=action.object):
        log_audit("blocked_by_freeze", action_id=action.action_id)
        return {"status": "blocked", "reason": "freeze active"}

    # 2. Allowed hours?
    if not in_operating_hours():
        return {"status": "deferred", "reason": "outside hours"}

    # 3. Signature still valid? (payload not tampered)
    if not verify(action.action_id, action.payload,
                    action.exp, action.sig):
        log_audit("blocked_bad_signature", action_id=action.action_id)
        return {"status": "blocked", "reason": "invalid signature"}

    # 4. Idempotency: already executed? (no duplicates on replay)
    if already_executed(action.action_id):
        return {"status": "skipped", "reason": "already executed"}

    # 5. Snapshot for rollback, then execution.
    snapshot = save_previous_state(action)
    return apply_to_salesforce(action, snapshot_ref=snapshot.ref)
```

This `execute` is deterministic, versioned, and tested. It is the mandatory bottleneck of every write. If it doesn't pass through here, it doesn't touch Salesforce.

### Freeze runbook

A kill switch without a runbook is a button nobody knows how to use under stress. The runbook I deliver, written and rehearsed:

1. **Symptom:** anomalous updates, forecast gone crazy, alerts from the logs (see below), or a user report.
2. **Activate the global freeze:** `POST /admin/freeze {"scope":"global"}` or from the panel. Anyone on the ops team can do it. Immediate effect.
3. **Verify:** check that the logs show `blocked_by_freeze` for new actions. If writes continue, the freeze doesn't work → escalation.
4. **Diagnose:** from the logs identify the responsible agent, action, payload.
5. **Contain:** if rollback is needed, use the snapshots (see the rollback section). Assess what is reversible and what isn't.
6. **Unblock at fine grain:** re-enable healthy agents first (`scope: agent`), keep the culprit frozen until it's fixed. Unblocking requires an authorized role.
7. **Post-mortem:** what got through, which threshold was missing, which test to add.

## The reference architecture

Let's put the pieces together. Note the boundary: the agent never has Salesforce write credentials. Only the executor does.

```
   LLM agent ──▶ ┌─────────────────────────────────────┐
   (proposes)     │ DRY-RUN: serialize the PATCH        │
                  │ (sandbox validation)                │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ POLICY ENGINE: risk from count,     │
                  │ protected fields, amount, hours     │
                  └───────┬───────────────────┬──────────┘
                     low  │              medium/high
                          ▼                   ▼
              ┌──────────────────┐  ┌──────────────────────────┐
              │ (auto, logged)   │  │ QUEUE + signed link       │
              │                  │  │ out-of-band approval      │
              └────────┬─────────┘  └───────────┬──────────────┘
                       │                        │ approved (role)
                       └───────────┬────────────┘
                                   ▼
                  ┌─────────────────────────────────────┐
                  │ EXECUTOR (only one with credentials):│
                  │ 1.freeze? 2.hours? 3.sig? 4.idemp.  │
                  │ 5.snapshot → 6.Salesforce write     │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ Immutable AUDIT LOG + snapshot      │
                  └─────────────────────────────────────┘
```

**What the agent NEVER touches:**

- Salesforce write credentials (only the executor has them).
- The freeze flag (it cannot unblock itself).
- Protected fields without approval.
- Its own configuration (thresholds, protected fields, roles).

This is what **production agent security** means: not a "clever" model, but a deterministic perimeter around a model you assume is fallible.

## Replay and rollback on Salesforce (not always possible)

Rollback is where optimism meets the reality of a CRM. You can restore field values thanks to the snapshots (`old` in the payload), but **not everything is reversible.**

What you can undo:

- **Direct field changes:** you have the `old` values, you write them back. Simple, if no other automation has intervened in the meantime.

What you **cannot** undo easily, or at all:

- **Downstream automations triggered by the write:** Flow, triggers, Process Builder that on a `StageName` change sent emails, created tasks, notified customers. Rewriting the field does not "recall" the email that already went out.
- **External syncs:** if a change propagated to a connected system (ERP, marketing automation), rollback on Salesforce does not touch the other system.
- **Deleted records:** recoverable from the Recycle Bin for a limited period, then no. Delete operations always deserve the maximum threshold.

From this, two principles:

1. **Idempotency always.** Every action has an `action_id`; the executor refuses to execute the same ID twice. So a replay (after a crash, a retry) does not double the side effects. It is the only way to make retry safe.
2. **The snapshot before the write, always.** Even if rollback will not always be possible, the previous state is what you need to understand what changed and to restore what is restorable. It costs little space, it is worth a lot in an incident.

And the Salesforce technical constraint not to ignore: **governor limits** and the Bulk API. An update on 340 records is not done with 340 single calls (you burn the limits and you are slow): you use the Bulk API in batches. But the Bulk API makes rollback more complex, because a batch can fail partially. The executor must handle per-record results and know exactly which writes succeeded, for a coherent snapshot. I covered this among the constraints of [agents that actually execute]({{ '/en/pillar/agents-that-act/' | relative_url }}): platform limits are not a detail, they are part of the design.

## Who approves: separation of duties

A control where the person who builds the agent is also the person who approves its writes is not a control: it is a conflict of interest. **Separation of duties** is an old and valid security principle.

- **Whoever configures the agent** (the integrator, IT) defines thresholds, protected fields, flows. They do not approve individual writes.
- **Whoever approves the writes** is a business role with authority over the data: the sales manager approves changes on opportunities, finance approves changes on payment data.
- **Whoever can lift the freeze** is a defined role, distinct from the agent and from whoever built it.

Why it matters: if an injection compromises the agent and the agent could also approve, you would have no defense. Separation guarantees that a *different* human, with a *different* interest, looks at the payload before it becomes reality. And in an audit, you know who approved what, in what role — information that "reply YES" in a shared channel never gives you.

An operational detail almost everyone discovers the hard way: **what happens when the approver is away?** The sales manager goes on holiday, and the queue fills with pending actions that expire without execution. Two opposite mistakes to avoid. The first: no substitute, and work stops until they return — the thresholds were calibrated on a single person. The second, worse: an omnipotent "backup approver" who accepts everything to unblock the queue, voiding the separation. The sane solution is an **explicit, temporary delegation**: a named substitute for the absence period, with the same role and the same limits, traced in the log (who delegated to whom, from when to when). Delegation is audit information, not a shortcut. If you don't design it, you will discover it as a hole on the first Monday in August.

## Testing the kill switch: chaos, not trust

Here is the part that separates real systems from toys, and that almost nobody does: **testing that the kill switch works.** A freeze you have never tried is, statistically, a broken freeze. Under stress you will discover that the flag wasn't being read, or the executor ignored it on one path, or nobody knew how to activate it.

The test is chaos-style: **you deliberately introduce an agent that behaves badly and verify that the system stops it.**

```python
def test_freeze_stops_writes():
    activate_freeze(scope="global")
    action = build_test_action(object="Opportunity", count=5)
    result = execute(action)
    assert result["status"] == "blocked", "FREEZE DOES NOT WORK"
    assert count_salesforce_sandbox_writes() == 0

def test_rogue_agent_ignores_freeze():
    """Simulates an agent that TRIES to write during the freeze."""
    activate_freeze(scope="global")
    result = malicious_agent_tries_direct_write()
    # must fail: the agent has no credentials, only the executor does.
    assert result["status"] in ("blocked", "unauthorized")

def test_tampered_payload_does_not_execute():
    action = valid_approved_action()
    action.payload["count"] = 9999          # post-signature tampering
    result = execute(action)
    assert result["status"] == "blocked"     # signature doesn't match
```

The tests to have, at a minimum:

- **The freeze actually blocks** every kind of write (update, create, delete, bulk).
- **An agent cannot write directly** (it has no credentials): the separation holds.
- **A payload tampered after the signature does not execute** (hash/signature don't match).
- **An expired action does not execute** (`expires_at` respected).
- **A replay does not double** (idempotency).
- **Outside hours writes are deferred**, not executed.

And above all: **a periodic production drill**, like a fire drill. Once a quarter, someone activates the real freeze, verifies from the logs that writes stop, and deactivates it. If you don't try it, you don't know you have it.

## Implementation path, step by step

1. **Take write credentials away from the agent.** Only the executor has them. This alone eliminates the class of attacks "the agent writes directly".
2. **Implement the dry-run:** the agent produces the structured PATCH, it does not execute.
3. **Build the queue** with the schema above, immutable log, payload hash.
4. **Add the policy engine:** thresholds for count, protected fields, amount, hours.
5. **Implement out-of-band approval** with signed links and a minimum diff UI.
6. **Put in the global freeze** read by the executor before every write, fine-grained.
7. **Add snapshot and idempotency** for rollback and safe replay.
8. **Define separation of duties:** who configures, who approves, who unblocks.
9. **Write the freeze runbook** and the chaos test suite.
10. **Do the fire drill** in production before you raise volumes.

## Typical failures and how you spot them in the logs

- **Writes with no `action_id` in the queue.** If you see changes on Salesforce that have no matching `action_id` in the queue, the agent is writing outside the control system. Red alarm: someone gave the agent the credentials.
- **Approvals that are too fast.** Log the `delta_t` between notification and approval. Two seconds on a 300-record update = the approver stamped without looking. The oversight is fake.
- **`blocked_bad_signature` rising.** Someone (or something) is trying to execute tampered payloads. Investigate the source.
- **Unexpected bulk updates.** A spike in the average `count` of actions. An agent that usually touches 1–2 records and suddenly proposes 300 → either a bug or an injection. Log the count distribution.
- **Actions executed after `expires_at`.** Should never happen; if it does, the executor is ignoring the expiry — critical bug.
- **Freeze active but writes continuing.** The worst: the kill switch doesn't work. There must be a dedicated alert that compares "freeze active" with "writes happened" and screams if they coexist.

The standing rule: **log the decision, not only the action.** Not "updated 340 records", but "updated 340 records, action act_..., risk high, approved by [role] at 09:15, signature valid, freeze inactive". When something goes wrong, this chain is the difference between understanding in five minutes and never understanding.

## Costs: orders of magnitude

Stated estimates, for an agent that writes to Salesforce in an SME.

- **Development of the control system** (dry-run, queue, policy, freeze, signed approval, snapshot, chaos test): as an order of magnitude **1–2 person-weeks** on an agent integration that already exists. It is deterministic engineering work, you don't need a GPU.
- **Recurring compute cost:** negligible. The queue, the policy engine and the freeze are millisecond CPU operations. No relevant extra token cost: the dry-run is the same output the agent would produce anyway, just not executed.
- **Salesforce governor limits:** the Bulk API has daily limits; for high volumes check your edition. It is not a direct euro cost, but a throughput constraint you have to design for.
- **Human cost of approval:** the approvers' time. Calibrate it with the thresholds: if they approve too much, the system is badly tuned. A few targeted approvals a day, not hundreds.
- **Cost of not doing it:** a wrong mass update on hundreds of opportunities can falsify the forecast, require days of manual cleanup, and undermine trust in the data. A wrong owner change touches commissions. The bill of one incident far exceeds the two weeks of development.

## When NOT to do it

- **If the agent only has to read and propose**, you don't need all of this: with no side effect there is nothing to control. The control system kicks in when the agent *writes*.
- **If you cannot take write credentials away from the agent**, stop: that is the first brick. An agent with direct write credentials is not controllable, period.
- **If you don't have someone who actually approves** (with time and authority), don't enable high-risk writes. Better an agent that prepares and a human who executes in Salesforce, than a fake approval.
- **If the use case requires massive real-time writes with no possible supervision**, rethink the automation: maybe that process is not suited to an agent, or it needs to be broken into smaller, more reversible steps.
- **If you cannot maintain and test the kill switch over time**, know that it will degrade. An untested freeze is a broken freeze: better to know that before the incident.

## Operational checklist before going live

- [ ] The agent **does not have Salesforce write credentials** (only the executor).
- [ ] **Dry-run** active: the agent proposes a serialized PATCH, it does not execute.
- [ ] **Approval queue** with immutable log, payload + hash.
- [ ] **Out-of-band approval** with signed links and a diff UI — never "reply YES".
- [ ] **Thresholds** for record count, protected fields, amount, hours.
- [ ] **Global freeze** read before every write, fine-grained, immediate with no deploy.
- [ ] **Snapshot** of previous state before every write.
- [ ] **Idempotency** on `action_id`: no duplicates on replay.
- [ ] **Separation of duties:** who configures ≠ who approves ≠ who unblocks.
- [ ] **Freeze runbook** written and accessible.
- [ ] **Chaos test** of the kill switch in the suite + periodic production fire drill.
- [ ] Complete **decision logs** and an alert on "freeze active + write happened".

## The verdict

The **kill switch for agents that write to Salesforce** is not a button you add at the end. It is a way of thinking about the entire pipeline: side effects are what you control, and the control must sit in the deterministic code around the model, not in the conversation. "Yes in chat" fails because it is on the same untrusted channel, it doesn't bind the approval to the payload, it leaves no audit, and it cannot be stopped. It is theater.

The real control has a precise shape: the agent proposes (dry-run), the system serializes the PATCH, the policy engine measures risk from count and protected fields, approval happens out of band on a signed, expired payload, the executor checks the freeze before every write, and every action leaves a snapshot and an immutable log. Whoever approves is a different role from whoever builds. And the kill switch is tested, like a fire drill, because one you have never tried is one you don't have.

Done this way, an agent that writes to the CRM saves you hours and reduces human error, staying under control even when the model is tricked. Done with "reply YES", it is an over-enthusiastic colleague with the database keys and nobody watching. The difference is not how smart the agent is. It is where you put the brakes, and whether you verified they work.

If you are about to give an agent the write keys to your CRM and you want the brakes to actually be there before the first mass update, you can see how I work on [antoniotrento.net]({{ site.main_site }}/biografia/) or write to me from the [contacts]({{ site.main_site }}/contatti/) page. Control theory on side effects, not bot UX.

## FAQ

### Why is "confirm in chat" not enough?
Because the confirmation arrives on the same untrusted channel the agent operates in: a prompt injection can fabricate it or alter the preview shown before the yes. It also does not bind the approval to the exact payload, does not leave a separate audit, has no expiry, and does not identify the role of whoever approves. It looks like a control, but it does not hold when you actually need it.

### What is dry-run in this context?
It is the mode in which the agent produces an exact, structured description of what it would do — object, record IDs, fields, old and new values, count — without executing it. The system serializes this PATCH, validates it (including against a sandbox) and puts it in the queue. Nothing touches Salesforce until there is a valid approval. It makes it impossible to mask a mass update behind an innocent example.

### How does the signed link protect me?
The link leads to a separate, authenticated approval system, outside the agent's channel, so it cannot be fabricated by an injection. The HMAC signature binds the approval to the exact payload: if the payload changes between preview and execution, the signature doesn't match and the executor blocks. It also has an expiry, so an old approval does not stay executable indefinitely.

### Which fields should I always protect?
At a minimum: OwnerId (ownership change and commissions), Amount and the fields that move the forecast, StageName toward closed states, any payment data (IBAN), and the fields that trigger downstream automations or communications to customers. Changes to these fields should always require human approval, regardless of the number of records.

### Is rollback on Salesforce always possible?
No. You can restore field values thanks to the snapshots, but you cannot undo the side effects triggered by the write: emails already sent, Flow and triggers already executed, syncs toward external systems. That is why irreversible operations always deserve the maximum approval threshold, and it is worth designing actions to be as reversible as possible.

### How do I handle mass updates without burning governor limits?
With the Bulk API in batches, not with single calls per record. Watch out though: a batch can fail partially, so the executor must handle per-record results and know exactly which writes succeeded, to keep a coherent snapshot and allow rollback of what is restorable. Platform limits have to be designed for, not discovered in production.

### Who should approve the agent's actions?
A business role with authority over the data, different from whoever built the agent. The sales manager for opportunities, finance for payment data. Separation of duties guarantees that a human with a different interest looks at the payload, and that a compromise of the agent cannot also self-approve. In an audit, you know who approved what and in what capacity.

### How do I test that the kill switch actually works?
With chaos-style tests: you activate the freeze and verify that writes are blocked, you simulate an agent that tries to write during the freeze, you try tampered payloads and expired actions. And you do a periodic "fire drill" in production: someone activates the real freeze, checks from the logs that writes stop, then deactivates it. A kill switch never tried is statistically broken.

### Does this only apply to Salesforce?
No, the principle applies to any agent that produces side effects: writes to an ERP, sending payments, changes to a database, calls to external APIs that change state. Salesforce has specifics (governor limits, downstream automations, Bulk API), but the pattern — dry-run, queue, thresholds, freeze, snapshot, separation of duties, kill-switch testing — is general. The target changes, not the control theory.

### Where do I start if I already have an agent writing with no controls?
In this order: (1) immediately take write credentials away from the agent and put them only in an executor; (2) add the global freeze read before every write; (3) introduce dry-run and the queue; (4) define thresholds and protected fields; (5) move approval out of band with signed links; (6) add snapshot, idempotency and chaos tests. The first two steps take little time and cover most of the immediate risk.
