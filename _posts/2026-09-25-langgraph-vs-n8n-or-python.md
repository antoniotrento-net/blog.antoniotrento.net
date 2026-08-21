---
lang: en
permalink: /en/blog/langgraph-vs-n8n-vs-python/
alt_url: /it/blog/langgraph-vs-n8n-vs-python/
title: "LangGraph or n8n or a Python script: which orchestrator for an agent that actually has to execute (not chat)"
date: 2026-09-25 07:30:00 +0200
author: "Antonio Trento"
description: "It isn't a tool war: it's a decision framework. n8n, LangGraph and plain Python on the same real case (booking + CRM write), with the criteria that actually matter: state, retries, tests, and who maintains it in 12 months."
keywords: ["langgraph vs n8n vs python", "agent orchestration", "production tool calling", "n8n limits", "langgraph state"]
image: /assets/images/posts/langgraph-vs-n8n-vs-python.jpg
pillar: agenti-esecuzione
related: [/en/blog/salesforce-mcp-production-agent/, /en/blog/self-hosted-n8n-openai-privacy/]
---

## Executing isn't chatting: the definition that changes everything

Before choosing among `LangGraph vs n8n vs Python`, you have to be honest about what "an agent that executes" means. A chatbot that generates text has no consequences: if it gets a word wrong, you rewrite it. An agent that **executes** produces **side effects in the real world**: it books an appointment, writes a record in the CRM, sends a message, moves money. And side effects don't undo themselves when you rewrite: a double booking is a double booking, a record written twice is corrupted data. That's the difference that makes the orchestrator choice a serious decision, not a fashion whim.

Because when an agent executes, the orchestrator — the tool that coordinates the steps, calls the tools, manages state — has to hold things a chatbot never needs: **state** (how far I've got in the process), **retries** that don't double the side effects (idempotency), **observability** (what it did and why), **tests** (verify before you ship it to production), and — the criterion everyone forgets — **who will maintain it in 12 months**. In this article I'm not fighting a tool war: I'm building a **decision framework**. We put the same real case — a booking with a CRM write — through the three approaches (n8n, LangGraph, plain Python), look at the concrete pros and cons of each, and extract the criteria to pick yours. Because there is no "best": there is the right one for *your* case, *your* team and *your* maintenance.

## The test case: booking plus a CRM write

To compare seriously, you need one concrete case identical for all three. Ours: **an agent that receives a request ("book a consultation for client X on Thursday afternoon"), checks availability, creates the booking, and writes the activity in the CRM.** It has every ingredient that matters:

- **Real side effects**: it creates a booking and writes to the CRM. Getting it wrong has consequences.
- **Steps with dependencies**: you can't write to the CRM before the booking is confirmed.
- **Failure points**: availability can be missing, the CRM can refuse, the network can drop mid-way.
- **Need for idempotency**: if something goes wrong and you retry, it must not create two bookings.
- **A moment of judgment**: if the requested slot isn't free, the agent proposes alternatives (and maybe a human confirms).

We'll use this case as the yardstick. Every orchestrator can do it — but *how* it does it, and what it costs you in state, tests and maintenance, is where the difference shows. And it's also the case that shows why execution has to be designed with the safety nets of [agents that write to production systems]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}): idempotency, approval, audit.

## n8n: fast, visible, weak on long state and tests

n8n is the visual orchestrator: you build the flow by dragging nodes, you see it at a glance, it ships fast. For many agents it's a good choice, and that should be said without snobbery.

**Where n8n wins:**

- **Time to first run.** A flow "receive request → check availability → create booking → write CRM" you assemble in a few hours, with nodes already ready for common integrations.
- **Visibility for non-developers.** The flow is a diagram: an operations lead, not only a dev, understands what it does and where it stopped. That's a huge advantage for maintenance by mixed teams.
- **Ready-made integrations.** Nodes for hundreds of services, without writing the connection code.
- **Sovereign self-hosting.** It runs in your house, with the [local model instead of the cloud]({{ '/en/blog/self-hosted-n8n-openai-privacy/' | relative_url }}).

**Where n8n struggles:**

- **Long state.** An agent that has to keep complex context across many steps, with loops and branching decisions, strains the linear-visual model. n8n was born for workflows (A→B→C), not for agents that reason in loops.
- **Loops and complex decisions.** You can do them, but they become tangled diagrams, hard to read when the logic is rich. The visibility advantage dies when the flow is a maze.
- **Automated tests.** Testing a visual workflow automatically is awkward: you don't have the unit tests you have with code. You check "by hand", by running it. On an agent with real side effects, that's a serious weakness.
- **Versioning.** An n8n workflow is JSON. Putting it in git works, but the diffs are unreadable: understanding "what changed between two versions" by staring at JSON is painful. Real code review is hard.

n8n is ideal when the flow is **relatively linear, the integrations matter, and you want non-devs to see it and touch it.** It becomes awkward when the agent's logic gets complex, you need serious tests, or clean versioning matters.

## LangGraph: state, loops, checkpoints, and a debug curve

LangGraph is a (code) framework built **on purpose for agents with state**. It models the agent as a graph: nodes (the steps), edges (the transitions, including conditional ones), and state that flows through the graph. It's the philosophical opposite of n8n: not visual, but extremely powerful on complex logic.

**Where LangGraph wins:**

- **Explicit state.** The agent's state is a clear data structure that passes from node to node. You always know "what I know so far", and that's the right thing for agents that reason across multiple steps.
- **Loops.** An agent that tries, evaluates, retries, changes strategy: loops are native in the graph. "Decide → execute → back to decide" is natural, where in n8n it would be a tangle.
- **Checkpoints.** LangGraph can **save state** at every step and resume from there. That enables two golden things: resume after a crash without starting over, and **human-in-the-loop** — the agent stops, waits for a human's approval, and resumes. Perfect for the "confirm the booking" of our case.
- **It's code, so it's testable and versionable.** Real unit tests, readable git diffs, normal code review.

**Where LangGraph costs:**

- **The learning and debug curve.** It's a framework with its own concepts (state, nodes, conditional edges, checkpointer). Debugging it when the logic is complex requires understanding how the graph executes. It isn't "open and see" like n8n.
- **You need a dev who knows it.** It isn't for non-developers. And it isn't for any random dev on day one: there's a framework to learn.
- **Overhead for simple cases.** For a linear flow, LangGraph is over-engineering: all the power on state and loops is wasted if your agent does three steps in a row.

Here's the skeleton of our case in LangGraph style — note the state that flows, the loop and the checkpoint:

```python
from langgraph.graph import StateGraph, END

def decide(state):
    # the LLM chooses the next tool based on current state
    state["next_action"] = llm_choose_action(state)
    return state

def execute(state):
    # executes the tool with idempotency; no double bookings
    state = execute_tool(state, idempotency_key=state["key"])
    return state

def route(state):
    return "end" if state.get("completed") else "execute"

g = StateGraph(AgentState)
g.add_node("decide", decide)
g.add_node("execute", execute)
g.add_edge("execute", "decide")          # loop: after executing, it decides again
g.add_conditional_edges("decide", route, {"execute": "execute", "end": END})
g.set_entry_point("decide")

# checkpointer = save state → resume after crash + human-in-the-loop
app = g.compile(checkpointer=checkpointer)
```

LangGraph is the choice when the agent has **complex logic, long state, loops, or a need to pause for human approval** — and you have a dev who maintains it.

## Plain Python: maximum control, minimum theatre

The third road, often the most underestimated: **write it in plain Python**, with the model's library and nothing else, no orchestration framework. You write the loop, you manage the state, you call the tools.

**Where plain Python wins:**

- **Maximum control.** No framework magic: every line does what you see. When something goes wrong, you don't have to figure out what the framework is doing underneath — it's all yours.
- **Minimum theatre.** No heavy dependency, no abstract concept to learn. A Python dev reads the code and understands everything immediately.
- **Total testability.** It's normal code: unit tests on every piece, mocks of the tools, tests of the edge cases. On an agent with real side effects, being able to test everything is gold.
- **Clean versioning.** Code in git, readable diffs, real code review.
- **No framework lock-in.** You aren't tied to the evolution (or abandonment) of a third-party framework.

**Where plain Python costs:**

- **You build everything yourself.** State, retries, idempotency, observability: nobody gifts them to you. For complex cases, you risk reimplementing (worse) what LangGraph would already give you.
- **No UI.** No diagram for non-devs; it's code, period.
- **Discipline required.** With all the control comes all the responsibility: if you aren't disciplined on state and idempotency, you hurt yourself.

Here's our case in plain Python — simple, explicit, testable:

```python
MAX_STEP = 8

def run_agent(request, state):
    for _ in range(MAX_STEP):
        action = llm_choose_action(request, state)   # what to do now
        if action.type == "done":
            return state
        # idempotent execution: retry doesn't double the side effects
        result = execute_tool(action.tool, action.args,
                              idempotency_key=state.key)
        state = update_state(state, result)
        if action.requires_human:                      # human-in-the-loop
            return awaiting_approval(state)
    raise AgentTimeout(state)   # no infinite loops: stop and log
```

Note the `MAX_STEP`: an agent that decides on its own can enter a loop; the step ceiling is the safety net that, in plain Python, you put in explicitly. Plain Python is the choice when the **logic is clear, you want total control and testability, and you have a dev who holds it** — without the weight of a framework you don't need.

## The same case on the three stacks: pros and cons face to face

Let's put our case (booking + CRM write) on all three, face to face, on the criteria that actually matter:

| Criterion | n8n | LangGraph | Plain Python |
|---|---|---|---|
| **Time to first run** | High (hours) | Medium | Medium |
| **Visibility for non-devs** | High (visual) | Low | Low |
| **Long state / loops** | Weak | Strong (native) | Strong (you write it) |
| **Checkpoint / human-in-loop** | Limited | Native | Manual |
| **Automated tests** | Hard | Good | Full |
| **Git versioning** | Awkward (JSON) | Clean (code) | Clean (code) |
| **Ready-made integrations** | Loads | You write them | You write them |
| **Fine-grained control** | Medium | High | Maximum |
| **Who maintains it** | Non-devs too | Dev with the framework | Dev |

How to read this table to decide:

- **If the flow is linear, the integrations are many, and you want non-devs to see it** → n8n. Speed and visibility beat the weakness on tests, *if* the logic stays simple.
- **If the agent has complex logic, long state, loops, and you need human-in-the-loop** → LangGraph. The power on state pays back the learning curve, *if* you have the dev.
- **If the logic is clear, you want total control and tests, and you don't need the UI or the framework's complexity** → plain Python. Simplicity and testability beat the "convenience" of the framework, *if* you have the discipline.

No row of this table says "the best in absolute terms". It says "the best *for certain conditions*". And that's the point: choosing the orchestrator is a cross between your case, your team and your maintenance.

## The hard case: the requested slot isn't free

The linear case (the slot is free, you book, you write to the CRM) all three do well. The difference shows in the **hard case**, the one with the moment of judgment: *the requested slot isn't available.* Now the agent has to propose alternatives, and a human confirms the final choice. Let's see how the three react.

- **n8n.** You handle it with a conditional branch: "if not available → search alternatives → send a confirmation request → wait". The problem is the wait: n8n has to *suspend* the flow until the human replies, and resuming a flow paused for hours or days is not its strength. It becomes a flow with webhooks and external state — doable, but the diagram gets complicated and the "wait for the human" part is the most fragile.
- **LangGraph.** This is its terrain. The "check availability" node leads, with a conditional edge, either to the "book" node or to the "propose alternatives" node. The latter saves a **checkpoint** and stops: the human receives the alternatives, chooses, and the agent **resumes from the checkpoint** with the choice. The pause for approval, even a long one, is native. The hard case here is almost trivial.
- **Plain Python.** You handle it explicitly: the function returns an `awaiting_approval` state (persisted), and a second entry-point resumes when the human reply arrives. Maximum control, but the "save state and resume" logic you write yourself — which is exactly what LangGraph would already give you.

The hard case is the revealer: **if your agents often have wait-and-resume moments (human-in-the-loop, long processes), LangGraph gifts you what in the other two you have to build.** If instead your cases are mostly linear and waits are rare, that power is useless weight, and n8n or Python are enough. It's the real case, not the demo case, that tells you which tool you need — because it's the real case you'll have to maintain.

## Observability and replay: seeing what the agent did

Whatever orchestrator you pick, there is one non-negotiable capability for an agent that executes: **observability.** When an agent has real side effects, you have to be able to answer "what did it do, in what order, with which data, and why?" — both for debug (something went wrong) and for trust (proving what happened).

What you need:

- **The log of every step.** Every decision the agent made and every tool executed, with input and output. Not "the agent made the booking", but "at 10:32 it called `create_booking` with these parameters and received this result".
- **State at every step.** What the state looked like before and after every action. To reconstruct the reasoning.
- **Replay.** Being able to **re-run** an agent session (on the logs, or in a controlled way) to understand where it went wrong. That's agent debug: without it, you investigate in the dark.

How the three fare:

- **n8n** gives you a visual history of executions: handy to see where a flow stopped, less so to reconstruct the reasoning of a complex agent.
- **LangGraph**, having explicit state and checkpoints, is excellent for observability and replay: you can resume from a checkpoint and see the state at every node.
- **Plain Python** gives you the observability you build: if you log every step and state well, you have everything; if you don't, you have nothing. Maximum freedom, maximum responsibility.

The principle: **an agent that executes without observability is unmanageable.** The first day something goes wrong in production — and it will — the difference between "I see what it did and I fix it" and "I have no idea what happened" is all here. It's the same audit trail that makes [agents on the CRM]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}) governable.

## The criterion that decides everything: who maintains it in 12 months

Here's the criterion that weighs more than any feature, and that almost nobody puts at the centre of the choice: **who will maintain this system in twelve months?** Because an agent in production isn't "done and finished": it has to be updated, fixed, extended. And the right tool depends on *who* will do that work.

- **If a mixed team will maintain it, with non-devs who have to understand something** → n8n. Visual visibility is priceless when the person putting their hands on it isn't only a developer. A flow that an operations lead understands is maintained better than code only the author understands.
- **If a development team with complex-logic needs will maintain it** → LangGraph, *provided that* the team knows the framework. Watch out: choosing LangGraph and then having nobody who can maintain it is a lock-in on one person's knowledge.
- **If one or more devs who want control and tests, without depending on a framework, will maintain it** → plain Python. Simple, tested code is the easiest for a new dev to pick up, because they don't have to learn a framework first: they read Python and understand.

The most common trap is choosing the tool **for how convenient it is to build today**, not for how it will be to maintain tomorrow. n8n is extremely convenient to build, but if then the logic grows and the tests are missing, in a year it's a fragile maze. LangGraph is powerful, but if the only person who understood it leaves, you're stuck. Plain Python requires discipline today, but it's the easiest to pick up tomorrow *if* it's written well. The question "who maintains it in 12 months?" has to be asked **before** you choose, not after — it's the same lucidity on maintenance you need so you [don't end up hostage to software after go-live]({{ '/en/blog/software-maintenance-after-go-live/' | relative_url }}).

## The reference architecture (independent of the orchestrator)

Whichever of the three you pick, the architecture of an agent that executes has the same boundaries:

- **The orchestrator** (n8n / LangGraph / Python) coordinates the steps.
- **The model** (local, from the sovereign stack) decides the actions.
- **The tools** with idempotency: every action with a side effect has an idempotency key and doesn't double.
- **Persisted state**: how far the process has got, so you can resume after a crash.
- **Observability**: log of every step and state, for debug and replay.
- **Human-in-the-loop** on the actions that weigh: confirming the booking goes through a human.

**What the agent NEVER does**, on all three:

- **It doesn't execute side effects without idempotency** (no double bookings).
- **It doesn't enter infinite loops** (step ceiling).
- **It doesn't take the decisions that weigh on its own** (human-in-the-loop where it's needed).
- **It doesn't execute without leaving a trail** (observability always).

These boundaries are independent of the tool: they're what makes an agent *safe to put in production*, whether you write it in n8n, LangGraph or Python. The tool changes the convenience; the boundaries stay.

## What breaks in production (and how you read it from the logs)

- **Double side effect (n8n/Python without idempotency).** Symptom: two bookings, two CRM records. In the logs you see two executions of the same tool seconds apart. Cause: a retry without an idempotency key. Fix: mandatory idempotency on every action with a real effect.
- **Infinite loop (agent that never closes).** Symptom: the agent cycles, costs go up, it never finishes. In the logs, the same sequence of decisions repeating. Cause: no step ceiling, or an exit condition never reached. Fix: `MAX_STEP` and clear end conditions.
- **State lost after a crash.** Symptom: the agent restarts from zero and redoes things already done. Cause: state not persisted (in n8n or Python thrown together in a hurry). Fix: checkpoint (LangGraph) or explicit state persistence.
- **Unreadable n8n workflow.** Symptom: nobody understands what the flow does any more, changes scare people. Cause: complex logic forced into the visual. Signal that the case has outgrown n8n and should move to code.
- **Framework that changes under your feet (LangGraph).** Symptom: an update breaks the code. Cause: dependency on a fast-evolving framework. Fix: pin versions, update with tests.

The thread: **agent failures are almost always idempotency, loops, state and observability** — the same four, on all three stacks. Who guards them (with any tool) has stable agents; who ignores them gets hurt, however pretty the tool is.

## The costs

Orders of magnitude, declared estimates:

- **Build cost**: n8n the lowest (visual, fast); LangGraph and Python higher (code), but with tests that pay back in stability.
- **Maintenance cost**: depends on "who maintains it" — n8n low if the team is mixed but high if the logic grows without tests; Python/LangGraph predictable if the team is devs.
- **Runtime cost**: dominated by the model (local from the sovereign stack: the GPU already discussed; no per-token cost if local) and by calls to external systems (watch [Salesforce governor limits]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}) if you write there). The orchestrator itself weighs little: it runs on a modest server.
- **Hidden cost**: the time lost debugging an unobservable agent, or maintaining an unreadable workflow. It's the highest cost and the least visible — you cut it by choosing for maintenance, not for initial convenience.

## When NOT to use any of them (meaning: no agent)

The most important honesty: **often you don't need an agent at all.** Before choosing the orchestrator, ask yourself whether the problem really requires an LLM that decides, or whether it's deterministic logic in costume.

- **If the logic is a fixed sequence** ("when X arrives, always do Y and Z"), you don't need an agent: you need a normal automation (an n8n workflow *without* an LLM, or a script). Putting an LLM to "decide" what's already decided adds cost, latency and unpredictability for nothing.
- **If the rules are clear and finite**, normal code (or the rules of the management system) does them better: reliable, free, no hallucinations.
- **The agent only makes sense when there is real ambiguity to interpret**: a natural-language request, unforeseen cases, decisions with nuance. There the LLM adds value.

The upstream question is: *does this problem need an LLM that decides, or is it a rule I'm complicating?* If it's a rule, none of the three agent-orchestrators is the answer: a simple automation is. Knowing how to say "here you don't need an agent" is part of the craft of people who build for real — the same lucidity as [when to stay on a Flow instead of putting AI in the middle]({{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}).

## Operational checklist before production

- [ ] I verified that **an agent is actually needed** (real ambiguity), not a rule.
- [ ] I chose the orchestrator on **case + team + 12-month maintenance**, not on fashion.
- [ ] Every action with a **side effect is idempotent** (no double bookings).
- [ ] There is a **step ceiling**: no infinite loop.
- [ ] **State is persisted**: it resumes after a crash.
- [ ] There is complete **observability**: log of every step and state, replay possible.
- [ ] The **actions that weigh** go through a human (human-in-the-loop).
- [ ] The model runs **locally** (sovereign stack); data doesn't leave.
- [ ] I know **who will maintain it** and the tool fits that person/team.
- [ ] Versions **pinned** (especially with a fast-evolving framework); automated tests where possible.

## The verdict: the tool follows the case, not the other way around

`LangGraph vs n8n vs Python` isn't a war to win: it's a decision to take on the right criteria. n8n wins when the flow is linear, the integrations matter and non-devs have to see it; LangGraph when the agent has long state, loops and you need human-in-the-loop, and you have someone who maintains it; plain Python when you want total control and tests without the weight of a framework. But under any choice sit the same non-negotiable boundaries — idempotency, step ceiling, persisted state, observability, a human on the decisions that weigh — because "executing" means side effects in the real world, and side effects don't undo themselves when you rewrite. And the criterion that weighs more than all of them remains one: **who will maintain it in 12 months.** Choose for that, not for how convenient it is to build today.

This is a brick of the [guide to agents that actually execute]({{ '/en/pillar/agents-that-act/' | relative_url }}), where automation touches systems with judgment. If you want to pick the right orchestrator for *your* case and *your* team, start from [who I am and how I work]({{ site.main_site }}/biografia/) or drop me a couple of lines in [contacts]({{ site.main_site }}/contatti/).

## FAQ

**1. Which is best among LangGraph, n8n and Python?**
None in absolute terms. n8n for linear flows, integrations and visibility to non-devs; LangGraph for agents with long state, loops and human-in-the-loop (if you have someone who maintains it); plain Python for total control and tests without a framework. The "best" depends on your case, your team and who will maintain it.

**2. What does "execute" mean for an agent?**
Producing side effects in the real world: booking, writing to the CRM, sending messages, moving money. Unlike chatting (generating text), side effects don't undo themselves when you rewrite — a double booking stays. That's why an agent that executes needs state, idempotency and observability that a chatbot doesn't.

**3. Isn't n8n good for agents?**
It's perfectly fine for relatively linear flows with lots of integrations, and it has the big advantage of visibility for non-devs. It struggles when the logic gets complex (loops, long state), when you need automated tests, and on clean versioning (it's JSON). It becomes awkward if the agent outgrows the linear flow.

**4. When does LangGraph make sense?**
When the agent has complex logic, long state, loops, or you need human-in-the-loop (stop for an approval and resume), thanks to checkpoints. The cost is the learning curve and the need for a dev who knows the framework. For simple cases it's over-engineering.

**5. Why choose plain Python instead of a framework?**
For total control and testability, with no magic and no framework lock-in. You write the loop, the state, the retries: all yours, all testable, clean git diffs. The cost is that you build everything yourself (state, idempotency, observability) and you have no UI. Ideal when the logic is clear and you have the discipline.

**6. How do I avoid double bookings?**
With idempotency: every action with a side effect carries an idempotency key, and the system doesn't re-execute an action already done. It holds on all three stacks — it's a boundary independent of the orchestrator. Without it, a retry creates two bookings, and that's failure number one of agents that execute.

**7. How do I keep a human in the important decisions?**
With human-in-the-loop: the agent stops before an action that weighs (e.g. confirming the booking) and waits for approval. LangGraph does it natively with checkpoints; in Python and n8n you implement it (the agent waits and resumes after the ok). It's the boundary between useful automation and dangerous delegation.

**8. What's the most important criterion in the choice?**
Who will maintain the system in 12 months. A mixed team with non-devs → n8n (visibility). A development team with complex logic → LangGraph (if they know it). Devs who want control and tests → Python. Choosing for the convenience of building today, ignoring maintenance, is the most expensive mistake.

**9. And observability?**
Non-negotiable for an agent that executes: you have to be able to see what it did, in what order, with which data, and re-run (replay) for debug. n8n gives a visual history; LangGraph is excellent thanks to state and checkpoints; Python you build it yourself (if you log well, you have everything). An agent without observability is unmanageable at the first problem.

**10. And if I don't need an agent at all?**
It happens often: if the logic is a fixed sequence or clear rules, you don't need an LLM that decides — you need a normal automation (workflow without LLM, or a script). The agent only makes sense with real ambiguity to interpret. Putting an LLM where a rule is enough adds cost, latency and unpredictability for nothing.

**11. Can I combine the approaches instead of picking one?**
Yes, and it's often the wisest choice. A common pattern: **n8n for the external orchestration and the integrations** (it receives events, talks to systems, gives visibility to non-devs) which calls, for the piece of complex logic, a **Python or LangGraph service** where the agent's reasoning lives with state, tests and idempotency. That way you take n8n's visibility and ready-made integrations *and* the control and testability of code, each where it's strongest. The boundary between the two has to stay clean (n8n must not reimplement the agent's logic, and the Python service must not redo the integrations), but it's a hybrid that works well in production — and it reflects the underlying principle: the tool follows the piece of the problem, not the other way around.
