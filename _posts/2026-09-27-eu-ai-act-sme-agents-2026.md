---
lang: en
permalink: /en/blog/eu-ai-act-sme-agents-2026/
alt_url: /it/blog/eu-ai-act-pmi-agenti-2026/
title: "EU AI Act for whoever ships agents in SMEs in 2026: are you high-risk or just automating the inbox?"
date: 2026-09-27 07:30:00 +0200
author: "Antonio Trento"
description: "Operational guide to the EU AI Act for SMEs shipping agents in 2026: high-risk yes/no decision tree, minimum dossier, AI use register and human oversight. No LinkedIn panic, just practical classification."
keywords: ["eu ai act sme agents 2026", "ai act risk classification", "internal gpt obligations", "llm transparency", "ai use register", "human oversight ai"]
image: /assets/images/posts/eu-ai-act-pmi-agenti-2026.jpg
pillar: modelli-costi-privacy
related: [/en/blog/gdpr-chatgpt-crm/, /en/blog/salesforce-mcp-production-agent/]
---

## First things first: you are probably not high-risk (but you have to prove it)

On LinkedIn the EU AI Act is told in two ways, both wrong. The first: "nothing changes, it's big-tech stuff". The second: "€35 million fines, shut everything down". The operational truth for whoever ships agents in an Italian SME in 2026 sits in the middle, and it is much more boring: **almost always your agent is not "high-risk", but you have to be able to prove it with a minimum of documentation, and a couple of obligations fire anyway even for the most banal automation.**

This piece is a practical guide to the **EU AI Act for SMEs that ship agents in 2026**: how to classify what you have built, what to document, what is actually "high-risk" and what is not, and how to keep an AI-use register an auditor can read in ten minutes. Stated angle: classification + minimum dossier, not panic.

**A serious disclaimer, not a fig leaf:** I am not a lawyer and **this is not legal advice**. It is the view of someone who puts agents, RAG and integrations into production and has to make them defensible. For the formal classification, the contracts and the borderline decisions, bring in a lawyer who knows Regulation (EU) 2024/1689 and a DPO. What I give you here is the map so you arrive at their desk with a clear head, not with anxiety.

## What is in force in 2026 for an Italian deployer

First thing to get straight: **what role you have.** The AI Act distinguishes mainly between who *produces* an AI system (provider) and who *uses* it in their own activity (deployer). The vast majority of SMEs that ship agents are **deployers**: you take a model (via API or self-hosted), you wire it to n8n, to the CRM, to the inbox, and you use it. You did not train a foundation model. That changes everything, because the heavy obligations on general-purpose models fall on whoever produces them, not on you.

Watch the boundary: **you can become a provider without noticing** if you put your brand on a high-risk system, if you modify it substantially, or if you destine it to a high-risk purpose different from the intended one. For a normal internal use (automation, assistance, document RAG) you stay a deployer. But if you resell an agent to your clients as a product, the conversation changes: there you become a provider and the obligations multiply.

The timeline that matters, in order of application:

| Date | What applies | Does it concern you? |
|------|-----------------|--------------|
| 2 Feb 2025 | Ban on prohibited practices + AI literacy obligation (staff) | **Yes**, always |
| 2 Aug 2025 | Obligations for general-purpose models (GPAI) + governance + sanctions | GPAI concerns the model providers, not you |
| 2 Aug 2026 | Obligations for **high-risk** systems (Annex III) | **Yes, if you are high-risk** |
| 2 Aug 2027 | High-risk tied to products (Annex I) + tail | Normally no for a software SME |

We are in September 2026. That means, as of today: **prohibited practices** have been illegal for over a year, the **AI literacy** obligation for staff is live, and for a few weeks the **obligations for high-risk systems** have been in force. So the question "am I high-risk?" is no longer theoretical: if you are, the obligations apply to you *now*.

Two obligations apply to (almost) everyone, even if your agent is banal:

1. **AI literacy (Art. 4).** Whoever operates the systems must have sufficient competence on what the AI does, its limits and the risks. For an SME that is realistic: an internal policy, a short documented training, and the awareness that the model can be wrong. You do not need a master's degree; you need a written trail that people know what they are using.
2. **Transparency toward whoever interacts with a bot (Art. 50).** If a client chats with your agent, they must know they are talking to a machine. I get to that in a moment.

## The test: high-risk vs internal productivity use

This is the heart. Most of the agents I ship for SMEs are **internal productivity** tools: they read documents, prepare drafts, route the inbox, enrich CRM records, propose replies. These **are not high-risk** under the AI Act. High-risk is defined fairly precisely (Annex III), and it concerns uses that affect people's rights and opportunities.

The Annex III categories an SME can actually hit:

- **Employment and workers' management:** systems used for *recruitment* (CV screening, selection), for *decisions* on promotions/dismissals, to assign tasks or to *monitor and evaluate* people at work. → **High-risk.**
- **Access to essential private and public services:** **creditworthiness** assessment / scoring for granting credit (fraud detection excluded). → **High-risk.**
- Other categories (biometrics, critical infrastructure, education, justice, migration, law enforcement): they rarely touch a software SME.

The point I always repeat: **it is the use that is high-risk, not the technology.** The exact same LLM agent that routes email is low-risk; if you point it at "read the CVs and discard the candidates", it becomes high-risk. The code does not change. The purpose changes, and who suffers the consequences.

### Decision tree: high-risk yes / no

This is the tree I use for a first classification. It does not replace legal advice, but it tells you immediately whether you are in the quiet zone or whether you have to call the lawyer.

```
1. Is the system a "prohibited practice"? (subliminal manipulation,
   social scoring, exploitation of vulnerabilities, mass scraping of
   faces, emotion recognition at work/school…)
   ├─ YES → STOP. You don't do it. It is banned, period.
   └─ NO  → go to 2

2. Does the system's output affect a person in one of these areas?
   - recruitment / selection / employee evaluation
   - creditworthiness / access to credit
   - access to essential services, education, healthcare, justice
   ├─ YES → probable HIGH-RISK → go to 3
   └─ NO  → low risk / limited risk → go to 4

3. Is it only a narrow accessory task (it does not decide, does not
   profile, does not replace the human assessment)?
   ├─ YES → possible exemption, but DOCUMENT the why → lawyer
   └─ NO  → HIGH-RISK: full deployer obligations → lawyer + DPO

4. Does the system interact directly with people (chatbot) or generate
   synthetic content?
   ├─ YES → TRANSPARENCY obligations (Art. 50) + register
   └─ NO  → minimal risk: register + literacy, carry on
```

The golden rule behind the tree: **if you automate internal processes and no external person suffers an automated decision on work, credit or essential services, you are almost certainly outside high-risk.** But "almost certainly" has to be written down, not thought. That is why you need the dossier.

## Transparency obligations if the user talks to a bot

This fires even for the most innocent agent, and it is easy to comply with — but it has to be done. Art. 50 imposes **LLM transparency** in three situations typical for an SME:

- **Chatbot / conversational agent:** the person must know they are interacting with an AI system, unless it is obviously obvious. In practice: a clear line at the start of the conversation. Not buried in the terms of service.
- **Generated or manipulated content (synthetic images, audio, video):** they have to be marked as artificial.
- **AI-generated text intended to inform the public** on matters of public interest: they have to be declared (with exceptions for content under human editorial review).

For an agent on inbox or WhatsApp Business, transparency is a sentence, not a project:

```python
BOT_DISCLAIMER = (
    "Hi, I am [Company]'s virtual assistant. "
    "I reply automatically; to reach a human operator write "
    "«operator» or call the number in the signature."
)

def open_conversation(channel: str) -> str:
    # Transparency has to be given at the start, visibly,
    # and logged (date/time, text version) so you can prove it.
    log_event("disclaimer_shown", channel=channel,
              version="v1", ts=now_iso())
    return BOT_DISCLAIMER
```

Note the `log_event`: it is not enough to give the transparency, you have to be able to **prove** you gave it. A log with timestamp and disclaimer version is the proof that, on date X, whoever wrote knew they were talking to a bot. It looks pedantic; it is exactly what an auditor asks for.

If your agent writes into the CRM or handles personal data, AI Act transparency stacks on top of GDPR obligations — notice, legal basis, minimisation. I covered that side in {{ '/en/blog/gdpr-chatgpt-crm/' | relative_url }}: the two regulations do not replace each other, they add up, and they have to be tackled together.

## Reference architecture of a "defensible" agent

The AI Act does not ask you for a particular technical stack. It asks you to be able to say, with paper in hand, **what the agent does, what it decides, what it does NOT touch, and who oversees.** Here is the architecture that makes a deployment defensible — it works for an inbox agent as for one on the CRM.

```
                        ┌───────────────────────────────────┐
   Input (email,    ──▶ │  LLM AGENT                         │
   documents, CRM)      │  - reads, classifies, proposes     │
                        │  - does NOT decide on people       │
                        │  - does NOT execute irreversible   │
                        │    actions                         │
                        └───────────────┬───────────────────┘
                                        │ PROPOSAL (structured + log)
                                        ▼
                        ┌───────────────────────────────────┐
                        │  HUMAN OVERSIGHT                   │
                        │  - sees input, output, rationale   │
                        │  - can correct / refuse            │
                        │  - decides in cases that affect    │
                        │    people (HR, credit)             │
                        └───────────────┬───────────────────┘
                                        ▼
                        ┌───────────────────────────────────┐
                        │  ACTION + DECISION LOG             │
                        │  who/what/when/why, traced         │
                        └───────────────────────────────────┘
```

The boundaries that make the system defensible, and that you write in the dossier:

- **What the agent does:** reads, classifies, summarises, proposes. Verbs that do not decide destinies.
- **What the agent NEVER touches:** decisions on people (hiring, dismissal, granting credit), irreversible actions without confirmation, modification of its own rules. Those stay with a human or with deterministic code.
- **Who oversees:** a named human role, with real power to correct and stop — not a "supervisor" who clicks "approve" with their eyes closed.

This split between "the AI proposes, the human disposes" is the same one I use for the operational safety of agents: kill switch, approval queue, decision logs. I described it in {{ '/en/blog/salesforce-mcp-production-agent/' | relative_url }}, and that is not an accident: **what makes an agent safe is also what makes it compliant.** Human oversight is not a bureaucratic add-on stuck on top; it is architecture.

## Minimum technical documentation an auditor can understand

If you are not high-risk, you do not need the formal technical documentation of Annex IV. But you still need a **minimum dossier** — DPIA-like in spirit: purpose, risk, data, oversight, residual risk, written down — that proves the classification and the control. If you are high-risk, this dossier is the starting point of the real one (which you will curate with the lawyer).

The mistake not to make: technical documents written for other engineers. The auditor is not an engineer. They want to understand in ten pages what the system does and why it is under control.

### Index of a 10-page dossier

1. **System sheet** (1 p): name, version, purpose in two lines, who is provider and who is deployer, go-live date.
2. **Risk classification** (1 p): the decision tree filled in, the outcome, and *why*. If you claim an exemption, motivate it here.
3. **Architecture and boundaries** (1–2 p): the diagram above, what the agent does and what it does NOT touch, where human oversight sits.
4. **Data** (1 p): which data go in, where they are hosted (self-hosted / EU), GDPR legal basis, retention. No training data of yours if you use a third-party model: say so explicitly.
5. **Human oversight** (1 p): named role, what they see, what they can do, in which cases the decision is always human.
6. **Transparency** (1 p): where and how you tell users it is an AI, with a screenshot of the disclaimer.
7. **Logs and monitoring** (1 p): what you log, for how long, how you detect malfunctions.
8. **Incident management** (1 p): what you do if the agent gets it wrong, who you notify, timelines.
9. **AI-use register** (1 p): the table (below), kept up to date.
10. **Literacy** (1 p): who was trained, when, on what.

Ten pages, not three hundred. If your system is low-risk and you cannot describe it in ten pages, the problem is not the documentation: it is that you have not understood what you put into production.

## Training-data quality vs RAG: you do not have your own foundation model

A misunderstanding that generates useless panic: the AI Act obligations on **training-data quality and governance** concern whoever *trains* the model. If you use GPT via API, or a self-hosted Llama/Mistral, or Claude, **you trained nothing.** The obligations on the training dataset fall on the foundation-model provider. You are a deployer who uses a pre-trained model.

What do you do, instead? **RAG.** You retrieve your documents and you give them to the model as context. That is not "training": it is retrieval at runtime. But watch it — a practical constraint stays yours:

- **RAG quality is your responsibility.** If your index contains wrong, stale or discriminatory data, the answers will be too. It is not "training-data quality" within the meaning of Annex IV, but it is still part of your duty to make the system work correctly and not harmfully.
- **Personal data in the RAG** are subject to GDPR: minimisation, legal basis, right to erasure (which must be able to remove a document from the index). I covered that building the {{ '/en/pillar/models-cost-privacy/' | relative_url }} on the privacy side: RAG retains, and what it retains has to be governed.

The distinction to put in the dossier (point 4): *"We do not train or fine-tune models. We use model [X] via [API/self-hosted]. Our data are used only at runtime via RAG, not for training, and they do not leave the [EU/self-hosted] infrastructure."* A sentence like that closes half of an auditor's questions.

## Human oversight: it is not a checkbox

The most common mistake, and the most dangerous in case of a check: putting a "nominal" human who approves everything without looking. It is called *automation bias* — the tendency to trust the machine blindly — and it is exactly what the AI Act wants to avoid. Human oversight (Art. 14 for high-risk, but good practice everywhere) has to be **effective**:

- The person **sees** the input, the output and — where possible — the why (the sources cited by the RAG, the rationale).
- The person **can** correct, refuse, stop. They have the real power, not just the button.
- The person **has the time and the competence** to do it. If they have to approve 500 proposals in an hour, they are not overseeing: they are stamping.
- In cases that affect people (HR, credit), the **final decision is human**, not a theoretical "override" of the automatic.

How do you make it real, not fake? With thresholds and targeted friction:

```python
def route(proposal) -> str:
    """
    Human oversight calibrated to the risk of the decision,
    not the same for everything (or the human habituates and stamps).
    """
    if proposal.affects_person:          # HR, credit, services
        return "HUMAN_DECISION"          # the human decides, does not approve
    if proposal.irreversible:            # outbound send, payment
        return "HUMAN_CONFIRM"
    if proposal.confidence < 0.75:       # the model is uncertain
        return "HUMAN_REVIEW"
    return "AUTO_WITH_LOG"               # low risk, traced
```

The secret is **not to ask for oversight on everything.** If every single thing requires a human click, the human stops looking. Concentrate attention where the risk is real, and let the banal stuff flow automatically (but logged). Selective and real oversight beats total and fake oversight.

## Typical failures and how you spot them in the logs

The AI Act does not fine you because the model hallucinated. It puts you in trouble if you **cannot prove** what happened and that you had control. Here is what I look for in the logs to understand whether a deployment is defensible or a time bomb.

- **Human approvals that are too fast.** If the average time between "proposal shown" and "approved" is two seconds on decisions that affect people, the oversight is fake. Log the approval `delta_t`: it is the proof (for or against) that someone was actually looking.
- **Missing disclaimer in the conversation logs.** If you open a chat log and you cannot find the `disclaimer_shown` event, you have a documented transparency violation. Look for its *absence*.
- **Decisions with no traced rationale.** An action that affects a person without a record of input+output+who decided is indefensible. In case of a complaint, you cannot reconstruct anything.
- **"Out-of-purpose" use.** An agent born to route email that someone starts using to evaluate candidates. In the logs you see it as a pattern change: new input types, new outputs. That is the moment a low-risk system becomes high-risk *without anyone having updated the dossier*.
- **No versioning.** If you change prompt or model and you do not log it, you cannot say which version was live when something happened. Always log `model`, `prompt_version`, `ts` on every call.

The rule: **the log is not only for debug, it is for defensibility.** A system that logs input, output, who decided, when and with which version is a system that, in case of a check, tells a coherent story. A system that does not log is guilty by default, because it cannot prove its own innocence.

## Sanctions: orders of magnitude and what happens first

This is where LinkedIn panic is born: the maximum numbers, quoted with no context. Let's put them in order (Art. 99), as estimates of the orders of magnitude:

| Violation | Cap | Who actually risks it |
|-----------|-------|---------------------|
| Prohibited practices | up to €35m or 7% of worldwide turnover | whoever does banned things (not you, one hopes) |
| High-risk / transparency obligations | up to €15m or 3% of turnover | negligent high-risk deployers |
| False/misleading info to the authorities | up to €7.5m or 1% of turnover | whoever lies to the check |

Two things the panic omits:

1. **For SMEs, the lower cap applies** between the fixed amount and the percentage, and sanctions have to be proportionate. The "€35 million" is not the fine for the SME that forgot the disclaimer on the chatbot.
2. **Before the sanction there is a path.** The market surveillance authority does not show up with the maximum fine on the first error. Typically there is: request for information, contestation, **formal notice** with a request for corrective measures, time to comply, and only in case of serious or repeated violations the heavy pecuniary sanction. If you are in good faith, you have a dossier and you comply when asked, the realistic scenario is "fix your house", not "bankruptcy".

This is not an invitation to ignore the rules. It is an invitation **not to spend on panic** what you have to spend on preparation. An honest minimum dossier protects you much more than a consultant who sells terror.

## Template for the company AI-use register

This is the most useful and most neglected document. The **AI-use register** is the inventory of all the AI systems you use, with their classification. It serves you (to know what you have), the auditor (to verify), and the lawyer (to reason). Keep it as a versioned file, not on a stray spreadsheet.

Tabular format, for human reading:

| ID | System | Purpose | Role | Risk class | Oversight | Data / hosting |
|----|---------|----------|-------|----------------|--------------|----------------|
| AI-01 | Inbox agent | Routes and drafts email replies | Deployer | Minimal | Human on outbound send | EU self-hosted |
| AI-02 | Document RAG | Q&A on internal manuals | Deployer | Minimal | No decision | EU self-hosted |
| AI-03 | CRM assistant | Enriches records, proposes notes | Deployer | Limited (no decision) | Sample review | EU |

And the same in machine format, to keep it updated via code/CI and generate page 9 of the dossier:

```yaml
# ai-use-register.yml — versioned in git, one entry per system
- id: AI-01
  system: "Inbox agent"
  purpose: "Routing and draft replies for internal/client email"
  role: deployer          # deployer | provider
  risk_class: minimal     # prohibited | high | limited | minimal
  affects_people: false
  transparency: "bot disclaimer v1 at conversation start"
  oversight: "human confirmation on outbound send"
  model: "llama-3.x self-hosted"
  own_training: false     # we use the model, we do not train it
  data: "email; no special-category data; EU self-hosted"
  gdpr_legal_basis: "legitimate interest / performance of contract"
  go_live_date: "2026-03-01"
  owner: "IT manager"
  last_review: "2026-09-01"
```

Practical rule: **every new agent that goes to production adds a row here, before go-live.** If it is not in the register, it does not go to production. It is the cheapest discipline that exists and it saves you when someone asks "how many AI systems do you use?" and the honest answer, without a register, would be "I don't know for sure".

## What NOT to do: wild HR scraping and the like

The list of things that actually get you in trouble, not for bureaucracy:

- **Mass candidate screening with automatic discard.** An agent that reads CVs and *decides* who passes is high-risk, and if you do it without real oversight, legal basis and transparency toward the candidates, you are in the sights of both the AI Act and GDPR. Assisting a human recruiter is one thing; replacing their decision is another.
- **Wild scraping of personal data** (social profiles, faces) to feed the system. Indiscriminate collection of facial images is among the prohibited practices. Don't do it, not even "just for a test".
- **Emotion recognition in the workplace.** Analysing employees' emotions (voice tone, expressions) is among the prohibited practices in work and school settings. Banned, not "risky".
- **DIY credit scoring** with an LLM that decides who deserves credit without the required safeguards. Full high-risk.
- **Using the agent "out of purpose"** without updating the classification. The system born for the inbox that starts evaluating people has changed risk class: if you do not re-classify it, you are exposed.
- **Hiding that it is a bot.** Making a client believe they are talking to a person when they are talking to the AI violates transparency. It costs one sentence to avoid it.

## A borderline case: the agent that "helps" the recruiter

The theory is clear, the boundary is not. The place where almost everyone gets it wrong is HR, so let's work it with a concrete case. An SME wants an agent that handles applications. There are three versions of the same tool, and they fall into three different risk classes — with the exact same model underneath.

**Version A — the assistant.** The agent reads the CVs, extracts a structured summary (years of experience, skills, languages), and presents them to the recruiter in an ordered list. It discards nobody, it assigns no decisive scores, it hides no candidates. The recruiter sees *all* the CVs and decides themselves. → **Limited/minimal risk.** The agent is a telescope, not a judge. Internal transparency and the register are enough.

**Version B — the filter with override.** The agent assigns a score and "recommends" discarding the below-threshold ones, but the recruiter can see them all and reverse. Dangerous grey zone: if in practice the recruiter only looks at the "recommended" and ignores the discarded, the override is theoretical and the decision is in fact the machine's. → **Treat it as high-risk** until you prove, with the logs, that the discarded ones are actually re-examined. The review `delta_t` on the discarded is the proof: if it is zero, it is the machine that decides.

**Version C — automatic discard.** The agent eliminates below-threshold candidates before a human sees them. → **Full high-risk.** Effective human oversight, transparency toward the candidates, GDPR legal basis, impact assessment all fire. Here you do not go to production without a lawyer and a DPO.

The operational moral: **the code is the same, the risk class is decided by who sees what and who actually decides.** In the dossier you do not write "we use AI for HR": you write *which* of the three versions you built, and you prove it with the logs of who looked and decided. The difference between Version A and Version C is not technical. It is where you put the human being.

## When NOT to do it (automating the thing itself)

Honesty, again against my own interest. There are cases where the right answer is "do not automate this thing with AI", or "not yet":

- **If the use is clearly high-risk and you cannot afford real human oversight**, don't do it. Automated credit scoring or HR screening without the safeguards is a legal and reputational risk that no time saving justifies for an SME.
- **If you cannot keep the register and the logs over time**, you are building a compliance debt. Better fewer agents, well documented, than ten untraced ones.
- **If the purpose keeps changing** and you cannot pin down what the system does, it is not ready for production: a system you cannot describe you cannot classify either.
- **If you are automating a decision that, if wrong, does serious harm to a person**, keep the human at the centre. The AI proposes, the human decides. Always, in these cases.

Automating well, inside the right perimeter, is legitimate and convenient. Automating where you affect people's rights without safeguards is the fastest way to turn an efficiency project into a legal problem.

## Costs: what being compliant actually costs

Orders of magnitude, declared as estimates, for non-high-risk deployer SMEs.

- **Classification + minimum dossier (10 pages):** one-off work, as an order of magnitude **2–5 days** between whoever knows the system and a targeted legal review. It is not a months-long project if the system is low-risk.
- **Staff AI literacy:** a short internal training + written policy, **1 day** of preparation + one hour per person. Recurring in a light form (updates).
- **Logs and register:** marginal engineering cost if you integrate them from the start; a few days if you have to add them after the fact. Computational cost negligible: they are metadata.
- **Legal/DPO review:** if you are low-risk, a targeted consultation to validate the classification. If you are high-risk, a serious and ongoing commitment — but at that point it is the cost of doing that business, not an option.
- **Cost of not doing it:** a formal notice that forces you to stop a system in production, the time to redo everything under pressure, and in serious cases the sanction. Compared with 2–5 days of preparation, there is no contest.

The synthesis: **for the average SME, being compliant with the AI Act on low-risk agents costs days, not months.** The cost explodes only if you are truly high-risk — and in that case it is the right price for an activity that affects people's lives.

## Operational checklist before going live

- [ ] **Role defined:** are you deployer or provider? (If you resell the agent, you are provider — everything changes.)
- [ ] **Decision tree filled in** and attached to the dossier, with a motivated outcome.
- [ ] If **high-risk** (HR, credit): stop and bring in lawyer + DPO before go-live.
- [ ] **Transparency live:** bot disclaimer visible and **logged** (with version and timestamp).
- [ ] **Real human oversight** where it is needed: who, what they see, what they can do — and they do not stamp.
- [ ] **AI-use register** up to date: one row per system, before go-live.
- [ ] **Minimum dossier** (10 pages) ready and readable by a non-engineer.
- [ ] **Complete decision logs:** input, output, who decides, approval `delta_t`, model, prompt version.
- [ ] **No own training** declared explicitly (you use RAG, not training).
- [ ] **Data in the EU / self-hosted**, clear GDPR legal basis, defined retention.
- [ ] **AI literacy** of staff done and documented.
- [ ] **No prohibited practice** (face scraping, emotion recognition at work, etc.).

## The verdict

The **EU AI Act for SMEs that ship agents in 2026** is not the apocalypse LinkedIn tells, and it is not the "it doesn't concern us" of the optimists either. It is a regulation that rewards whoever can explain what they built and prove they have control of it. If you automate internal processes — inbox, RAG, assistance, CRM enrichment — you are almost certainly low-risk, and compliance is a matter of discipline: classify, document in ten pages, keep the register, log the decisions, train the people, and be transparent when a user talks to a bot.

It becomes serious only when the agent affects **people** in sensitive areas: work, credit, essential services. There, human oversight is not a checkbox, the final decision stays human, and you need a lawyer. In every other case, the good news is that **what makes an agent safe — clear boundaries, the human in the right place, complete logs — is exactly what makes it compliant.** You are not doing two jobs. You are doing one well.

Do not spend on panic what you have to spend on preparation. An honest dossier beats a consultant who sells terror.

If you are putting agents into production in an SME and you want to classify them properly, draw the right boundaries and arrive at your lawyer with a dossier already ready instead of with anxiety, you can see how I work on [antoniotrento.net]({{ site.main_site }}/biografia/) or write to me from the [contacts]({{ site.main_site }}/contatti/) page. Architecture and boundaries, not slides on the AI Act.

## FAQ

### My SME uses ChatGPT to write emails: am I subject to the AI Act?
As a deployer yes, but with minimum obligations: staff literacy and, if the AI talks to clients, transparency. You are not high-risk if you automate internal productivity and no automated decision affects a person's work, credit or essential services. Document the classification in the register and carry on.

### Am I a "provider" or a "deployer"?
If you use an AI system in your activity, you are a deployer. You become a provider if you develop it, put your brand on it to resell it, modify it substantially or destine it to a high-risk purpose. Most SMEs that ship agents for internal use are deployers. If you resell the agent to clients as a product, you are a provider and the obligations grow.

### Is a chatbot on my site high-risk?
Almost never. An assistance chatbot is typically limited-risk: the only relevant obligation is transparency (saying it is an AI). It becomes high-risk only if used for an Annex III purpose, for example if it decides access to an essential service. A bot that answers questions or takes appointments is not.

### I use GPT via API: do I have to worry about the training-data obligations?
No. Those obligations fall on the foundation-model provider, not on you who use it. You do RAG, i.e. you provide documents at runtime: that is not training. Declare it in the dossier ("we do not train models, we use model X via API/self-hosted"). What stays yours is responsibility for RAG quality and GDPR compliance on the data you index.

### What is "human oversight" concretely?
A real person who sees input and output, understands what the agent did, and has the power to correct, refuse or stop. In cases that affect people, they decide, they do not just "approve". The risk to avoid is automation bias: a human who stamps everything in two seconds is not oversight, and it is visible in the logs from the approval time.

### What happens if I get the classification wrong?
The maximum fine does not arrive on the first error. The typical path is: request for information, contestation, formal notice with corrective measures and time to comply. If you are in good faith, you have a dossier and you comply, the realistic scenario is the correction, not the heavy sanction. That is why having a dossier — even an imperfect one — is worth more than panic.

### Do I have to keep an AI-use register by law?
The formal register is a full obligation for high-risk systems. For the others it is strongly recommended as good practice and as proof of control. In practice: keep it anyway. A versioned table with one row per system costs very little and saves you every time someone asks "how many AI systems do you use and how are they classified?".

### Can I use AI to screen CVs?
Assisting a human recruiter (summarising, ordering) is one thing; letting the AI *decide* who to discard is full high-risk, with oversight, transparency toward the candidates, legal basis and impact-assessment obligations. If you want to automate HR, keep the human decision and bring in a lawyer before you start. Automatic discard without safeguards is the classic error that gets you in trouble.

### How much does getting compliant cost?
For a low-risk deployer SME, as an order of magnitude 2–5 days one-off for classification and dossier, plus literacy training and light maintenance of register and logs. It becomes a serious commitment only if you are truly high-risk. The cost of not doing it — a formal notice that stops a system in production — is almost always higher.

### Where do I start if I already have five agents in production with none of this?
In this order: (1) do the inventory and fill the register, one row per agent; (2) run each one through the decision tree and mark the risk class; (3) for the low-risk ones, add disclaimer and logs where they are missing; (4) for any high-risk, stop and call lawyer + DPO; (5) write the ten-page dossier for each; (6) train the staff. The first two steps are done in a day and give you the map of where you are actually exposed.
