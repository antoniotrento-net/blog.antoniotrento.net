---
lang: en
permalink: /en/blog/gdpr-chatgpt-crm/
alt_url: /it/blog/gdpr-chatgpt-crm/
title: "Putting ChatGPT in the CRM is a data leak: what GDPR (and the AI Act) say if prompts contain Italian clients"
date: 2026-09-22 07:30:00 +0200
author: "Antonio Trento"
description: "Sales pastes the opportunity into ChatGPT to get a draft email. In that gesture, Italian client data leaves the EU. What GDPR actually says, and the checklist to take to your DPO."
keywords: ["gdpr chatgpt crm", "ai act sme", "openai data transfer", "llm dpa", "controller processor"]
image: /assets/images/posts/gdpr-chatgpt-crm.jpg
pillar: modelli-costi-privacy
related: [/en/blog/self-hosted-n8n-openai-privacy/, /en/blog/vllm-vs-ollama-in-production/]
---

## The scenario that happens every day in your company

Your salesperson has an important deal and needs to write a delicate email. They open ChatGPT and paste: "write me an email for Mario Rossi at Acme Srl, VAT 01234567890, who has a €45,000 opportunity stuck because he said our price is too high compared to competitor X, and last year he already had a delivery problem". Thirty seconds later they have their email, well written. They're happy. And they have just sent out of the company — to a server in the United States — name, company, VAT number, amount, commercial strategy and history of a real client. From a GDPR point of view, **this is processing of personal data with an extra-EU transfer**, done without a legal basis, without you knowing, dozens of times a day, by people who think they're just "using AI to work better".

The `gdpr chatgpt crm` topic is not theoretical: it is what happens *now* in thousands of Italian SMEs, and it is a silent data leak that nobody decided and everybody is doing. First, an honest warning: **this is not legal advice.** I am not a lawyer, I am a system architect. This is a technical-procedural article to understand the boundaries of the problem and — above all — a **checklist to take to your DPO or your advisor**, who will give you the formal opinion. We'll see who OpenAI is in your data chain, why "we turned on the EU region" does not close the issue, what has to go in the records of processing and the DPIA, which technical measures reduce the risk, what changes with the AI Act, how you write an internal policy employees actually follow, and what the sovereign alternative is. With the one-page policy outline, the list of data that must **never** enter a cloud prompt, and the GDPR principles to put on the lawyer's table.

## Controller, processor, sub-processor: who OpenAI is in your chain

Roles first, because without them you cannot reason. GDPR distinguishes:

- **The controller** (titolare del trattamento): who decides *why* and *how* data are processed. That is **you**, the company. The main responsibility is yours, always — even when you use other people's tools.
- **The processor** (responsabile del trattamento, Art. 28): who processes data *on behalf of* the controller, following their instructions. When you send data to a cloud LLM vendor, that vendor acts as processor. And Art. 28 requires a **data processing agreement (DPA)** that governs this relationship: what they can do, for how long, with which safeguards.
- **Sub-processors** (sub-responsabili): your vendor's vendors (the cloud infrastructure they run on, other downstream services). They are part of the chain too, and the safeguards have to extend to them.

The point almost nobody internalises: **you remain the controller.** Using ChatGPT does not "transfer" responsibility to OpenAI. If your clients' data ends up where it shouldn't, the first one to answer to the Garante is you, the controller — not the tool vendor. The operational question is therefore: *when an employee of mine pastes client data into a cloud LLM, do I have an Art. 28 relationship with that vendor? Do I have a DPA? Do I know who the sub-processors are? Have I given documented instructions?* If the answer is "sales uses their personal ChatGPT account", then **you have none of this**, and the data is leaving with no legal frame at all. It is the same data-boundary problem I tackled for [n8n workflows that exfiltrate to the cloud]({{ '/en/blog/self-hosted-n8n-openai-privacy/' | relative_url }}), seen here from the responsibility-chain side.

## "But we have the EU toggle": why it doesn't close the issue

The defence I hear most often is: "relax, we turned on the option with data in Europe". It is a useful step, but **it does not close the issue**, and believing it does is dangerous. Here's why.

- **Data residency is one thing, the processing relationship is another.** Even if data are processed in an EU region, you are still handing personal data to a processor. You still need the DPA, documented instructions, the assessment of sub-processors. The "where" does not eliminate the "who" and the "how".
- **The chain can still touch extra-EU.** The vendor may have a parent company or sub-processors subject to extra-EU laws. The question of **transfers to third countries** (the GDPR chapter on transfers, Art. 44 and following) does not switch off with a toggle: it has to be assessed on the real chain, and often requires specific safeguards.
- **Training and retention.** The point that actually weighs: are your inputs used to train the models? Do they stay logged, and for how long? A consumer plan and a business plan with training opt-out are different worlds. The region toggle says nothing about this.
- **Who is using it how?** The EU toggle on the company account is worthless if employees use **their personal ChatGPT accounts**, where none of these safeguards apply. And that is exactly what happens when there is no policy (more on that below).

The honest summary: the EU region is **necessary but not sufficient**. It is an ingredient, not the recipe. The full recipe — DPA, training opt-out, assessment of sub-processors and transfers, documented instructions, and control over *who* uses *what* — is what your DPO has to verify. Anyone who tells you "we have the EU toggle so we're fine" is simplifying a topic that does not let itself be simplified.

## What has to go in the records of processing and the DPIA

If you use (or let people use) LLMs on client data, two documents concern you, and they have to be prepared *with* the DPO — here I give the operational outline, the formal content is theirs.

**The records of processing activities.** If using LLMs on contact records and opportunities is systematic processing, it has to appear there. In practice you have to be able to describe: *which* data pass through the LLM, *for which purpose*, with *which legal basis*, toward *which processor* (the vendor), with *which* transfer safeguards, and *how long* the data stay. If you cannot fill these boxes, it isn't that the register is incomplete: it's that the processing is out of control.

**The DPIA (data protection impact assessment).** When processing presents high risks to people's rights, GDPR requires an impact assessment. Using cloud LLMs on large client databases, with profiling or decisions, can fall here. In the DPIA, with the DPO, you will have to reason: *which risks* (data exposure, use for training, automated decisions), *which measures* to reduce them (the next ones), and *whether the residual risk is acceptable*. The DPIA is not a form to fill out for duty: it is the place where you decide, in black and white, whether this use of AI stands up.

The GDPR principles to keep in mind while you do it — to cite to the lawyer, not to interpret on your own:

- **Art. 5** — the general principles: lawfulness, **minimisation** (don't send more data than necessary), purpose limitation and storage limitation. Minimisation, on its own, cuts most of the problem: why does the prompt contain the VAT number if you don't need it to write the email?
- **Art. 28** — the relationship with the processor: you need the DPA.
- **Art. 32** — **security** of processing: appropriate technical and organisational measures (masking, access control, logs).
- **Art. 44 and following** — **transfers** to third countries: the safeguards for sending data out of the EU.

These articles are the columns on which the DPO will build the opinion. Your job, as controller, is to bring them a clear technical picture of what actually happens — and that is what this article helps you build.

## The technical measures: masking, training opt-out, tenant, minimal logs

GDPR (Art. 32) asks for appropriate technical measures. Here are the ones that actually reduce the risk when an LLM touches client data, in order of effectiveness.

**Masking (redaction) before the prompt.** The most powerful measure and the most underestimated: remove identifying data *before* the text reaches the model. Here is a sample blocklist-filter that intercepts data that must not leave, to put between the app and the cloud LLM:

```python
import re

# Data that MUST NOT enter a cloud prompt without masking.
# Block or mask before sending.
FORBIDDEN = {
    "CF":    re.compile(r"\b[A-Z]{6}\d{2}[A-EHLMPRST]\d{2}[A-Z]\d{3}[A-Z]\b"),
    "PIVA":  re.compile(r"\b\d{11}\b"),
    "IBAN":  re.compile(r"\bIT\d{2}[A-Z]\d{10}[0-9A-Z]{12}\b"),
    "EMAIL": re.compile(r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b"),
    "TEL":   re.compile(r"\b(?:\+39\s?)?3\d{2}[\s.\-]?\d{6,7}\b"),
}

def check_prompt(text: str) -> tuple[bool, list, str]:
    found, masked = [], text
    for tag, pat in FORBIDDEN.items():
        if pat.search(masked):
            found.append(tag)
            masked = pat.sub(f"[{tag}]", masked)
    allowed = len(found) == 0
    return allowed, found, masked  # block or send the masked version
```

The logic: before every call to a cloud LLM, the text goes through the check. If it contains forbidden data, you either **block** it (with a message to the user) or send the **masked version**. Same warning as always: proper names slip through patterns, so masking reduces but does not zero the risk — for zeroing you need the local model.

**Training opt-out.** Making sure, contractually, that inputs are not used to train the models. It is a DPA clause, not some random setting.

**The company tenant, not personal accounts.** A company instance with the safeguards configured, not employees' personal profiles. That is the difference between governed use and Shadow IT (more below).

**Minimal logs and access control.** Knowing who sent what, keeping the minimum necessary, deleting according to a defined retention. Art. 32 security is this too.

A table to compare the three roads, on the criteria that matter:

| Criterion | Cloud LLM US (personal account) | Cloud vendor with DPA + EU region | Local model (sovereign) |
|---|---|---|---|
| **Data leave the EU** | Yes, with no frame | Reduced, to be assessed on the chain | No |
| **DPA / Art. 28** | Absent | Present (if done properly) | Not needed (no external processor) |
| **Use for training** | Possible | Excludable by contract | Excluded by construction |
| **Controller's control** | None | Partial | Full |
| **Technical effort** | Zero (and that is the problem) | Medium | High |

## AI Act 2026: high-risk use versus internal productivity

Above GDPR there is now the **AI Act**, the European regulation on artificial intelligence, which adds a layer. Again: this is not legal advice, but the frame you need to know so you can take it to the DPO.

The AI Act reasons in **risk levels**. Simplifying a lot:

- **Internal productivity use** (getting an email written, summarising a text, help drafting): generally falls in limited/minimal risk categories. There are obligations — especially **transparency** (people should know when they interact with AI, generated content should be treated as such) — but it is not the heaviest band.
- **High-risk use**: when AI enters decisions that significantly affect people — staff selection, creditworthiness assessment, and other defined areas. Here the obligations get serious (documentation, human oversight, risk management).

The practical point for an SME: *using an LLM to help write an email* is different from *using an LLM to decide who gets a credit line or who to hire*. The first is productivity; the second can be high-risk and requires much more. The question to take to the lawyer is: **does my use of AI enter decisions that affect people, or is it only productivity assistance?** The answer changes the obligations. And watch out: even in "light" use, if personal data of clients go in, GDPR continues to apply in full — the AI Act adds, it does not replace. The two have to be read together, with the DPO.

## The contract with employees: policy, sanctions, Shadow IT

Here is the practical root of the data leak: **Shadow IT**. Employees use ChatGPT (or others) with their personal accounts, in secret or in the open, because it is convenient and nobody told them not to. You can have the most beautiful DPA in the world on the company instance: if sales pastes the opportunity into their personal ChatGPT, it counts for nothing. Technical control alone is not enough — you need **people governance**.

You need three things:

1. **A clear policy** on what you can and cannot do with AI tools, and with which accounts. Not a legal tome: a page anyone understands (the outline is below).
2. **Training.** Employees often don't know they're doing something risky — they think they're "using AI to work better". They have to be made aware of the *why*, not only of the ban. A person who understands the risk cooperates; a person you only forbid finds a way around you.
3. **An alternative that works.** The number-one reason for Shadow IT is that the official tool is missing or inconvenient. If you ban ChatGPT and give nothing in its place, employees will use it in secret anyway. Give them a **governed and convenient** alternative (the company instance with the safeguards, or the local model), and Shadow IT deflates.

Here is a **one-page internal policy outline** — to adapt with the DPO, but as an operational starting point:

```text
AI TOOLS USE POLICY — [Company]  (v1, [date])

1. PURPOSE. Governs the use of artificial intelligence tools
   (ChatGPT, assistants, LLMs) at work, to protect client
   data and comply with GDPR.

2. ALLOWED TOOLS. Only tools provided by the company
   ([company tool/instance] / [internal model]). Personal
   accounts on AI tools are FORBIDDEN for work activity.

3. DATA FORBIDDEN IN CLOUD PROMPTS. Never enter in a cloud
   AI tool: first+last names of clients, VAT/tax code, IBAN,
   amounts tied to named people, health or judicial data,
   credentials, confidential contracts, strategies on named
   clients. If in doubt: do not enter it, or use the internal
   tool.

4. ALLOWED USE. Generic texts, drafts without personal data,
   summaries of non-confidential material, drafting help with
   masked/fictitious data.

5. RESPONSIBILITY. Improper use that exposes client data is a
   violation of this policy and of data-protection rules, with
   the consequences set out in the [regulation/contract].

6. DOUBTS. If in doubt, ask [contact/DPO] BEFORE acting.
```

This page, signed and explained, is worth more than ten pages of technical measures nobody knows. Because the data leak is not done by technology: it is done by people who don't know.

## The list: data that must never enter a cloud prompt

Print it and pin it up. These data **never enter** an ungoverned cloud AI tool:

- **First and last name of real clients/people** associated with information.
- **VAT number and tax code (codice fiscale).**
- **IBAN and bank details.**
- **Economic amounts tied to named people** (revenues, offers, debts of named clients).
- **Health, judicial, or otherwise "special category" data.**
- **Credentials, passwords, keys, tokens.**
- **Contracts, offers and confidential documents.**
- **Commercial strategies on named clients** (prices, discounts, weak points).
- **CVs and data of candidates/employees.**
- **Anything that, if it ended up in a vendor data breach, would get you in trouble.**

The simple mental rule to give employees: *"if you wouldn't write it on a postcard, don't paste it into a cloud prompt."*

## The sovereign alternative: local model or EU vendor with a serious DPA

So far the problem. The structural solution, the one that removes the risk at the root instead of managing it, is **not letting the data leave.** Two roads, depending on the case.

- **The local (sovereign) model.** An LLM that runs on your infrastructure (Ollama at small scale, [vLLM for multi-user production]({{ '/en/blog/vllm-vs-ollama-in-production/' | relative_url }})): client data never leave your fence, so the transfer problem and the external processor **do not arise**. It is the most solid alternative for sensitive data and for continuous use, and it is the heart of the sovereign stack.
- **The EU vendor with a serious DPA.** If you need the power of a cloud model for certain tasks, pick a vendor that offers a robust DPA, EU region, training opt-out, and transparency on sub-processors — and govern it with the policy, the masking and the logs. It is not "zero risk", but it is "governed and documentable risk", which is a different universe from the salesperson with their personal ChatGPT.

The pragmatic choice, as for the whole sovereign stack: **local default for sensitive data, governed EU cloud for tasks that need more power and do not touch critical data.** The economics often surprise: a local model for continuous internal use pays for itself (as in the [comparison of GPU and runtime costs]({{ '/en/pillar/models-cost-privacy/' | relative_url }})), and on top it eliminates a risk that, if it materialises in a fine, costs far more than any GPU.

## The reference architecture

Concretely, how you secure "AI in the CRM" without banning it (which doesn't work):

- **An internal AI gateway** between employees/apps and the models. All requests go through there.
- **The masking filter** in the gateway (the blocklist above): blocks or masks forbidden data before any send.
- **Routing by sensitivity**: tasks on sensitive data go to the **local model**; light, non-critical tasks can go to the **governed EU vendor**.
- **Logs and audit** in the gateway: who asked what, what was blocked/masked, where it went.
- **What the system NEVER does**: send unmasked forbidden data to a cloud model, and use personal accounts. These are the inviolable boundaries, imposed by the gateway, not left to goodwill.

The steps to get there:

1. **Map** where employees already use AI and on which data (the Shadow IT audit).
2. **Write the policy** and train people.
3. **Put the gateway** in with masking and routing.
4. **Offer the convenient alternative** (local + governed EU) so nobody goes back to personal accounts.
5. **Document** the records of processing and the DPIA with the DPO, citing the measures you put in.
6. **Monitor** the logs and update the blocklist on real cases.

## The same scenario, handled well: before and after

Back to the salesperson of the first line, the one who wanted the email for Mario Rossi. Let's see how the exact same need is satisfied *without* the data leak, with the architecture above.

**Before (the data leak).** Sales opens personal ChatGPT and pastes: "email for Mario Rossi, Acme Srl, VAT 01234567890, €45,000 opportunity stuck on price vs competitor X, history of a delivery problem". Everything leaves, with no frame. No DPA, no log, data out of the EU.

**After (governed).** Sales uses the company tool. They write the same request. The **gateway** intercepts the prompt:

1. The **masking filter** detects the VAT number and replaces it with `[PIVA]`; it flags that there is a real client name and an amount tied to a named person.
2. The **router** sees that the request contains data of an identifiable client: it routes it to the **local model**, not the cloud. Alternatively, if sales confirms they only want a generic draft, the gateway sends to the governed EU cloud *only* the version without data ("a client has an opportunity stuck on a price issue versus a competitor, with a previous service failure: write me an email to reopen the conversation").
3. The model produces the email. Sales themselves reinsert, locally, the real name in place of the placeholder.
4. The **log** records: who, when, what was masked, where it went.

Result: sales gets their email in thirty seconds — *same convenience as before* — but no identifiable client data has left without a frame. This is the key point: security is not obtained by *banning* AI (employees would use it in secret), but by giving the same convenience inside a fence. Banning creates Shadow IT; channelling eliminates it.

## What breaks (and how you notice)

- **Shadow IT that comes back.** Symptom: use of the official gateway drops but "AI-helped" work continues. Cause: the official tool is less convenient than personal ChatGPT. Fix: make the alternative convenient, or the policy stays paper.
- **Masking that lets names through.** Symptom: in the gateway logs you see prompts with unmasked proper names. Cause: the patterns catch VAT numbers and IBANs, not "Mario Rossi". Fix: for truly sensitive data, route to the local model instead of trusting masking alone.
- **The DPA that isn't there.** Symptom: nobody can produce the DPA with the vendor. Cause: you use a plan without the safeguards, or personal accounts. Fix: company instance with DPA, or local.
- **The DPIA never done on a high-risk use.** Symptom: AI has entered decisions about people (hiring, credit) without an assessment. This is the most serious risk: stop and involve the DPO before going further.

On the **cost** front (estimates): the gateway and masking are contained development work; the local model has the GPU cost already discussed (a used 24 GB card ~€800 + electricity for internal use). The cost that actually belongs on the table is that of **unmanaged risk**: a fine for unlawful processing of client data weighs orders of magnitude more than any stack. The honest account compares the cost of the solution with the cost of the incident, not with "zero".

## When you DON'T need this whole apparatus

Honesty, as always. **You don't need to build a gateway and a local stack if:**

- **You don't process client personal data with AI.** If company AI use is on generic, public or synthetic content, the GDPR problem is marginal: a simple policy and common sense are enough.
- **You're very small and use is occasional.** Few people, sporadic use on non-sensitive data: a clear policy + manual masking (don't paste VAT numbers and names) can be enough, without infrastructure.
- **You only need it for drafts and texts.** If AI is for drafting texts that *do not contain* client data, teach people to work with fictitious data and you're fine.

Proportion matters: the solution has to be commensurate with the real risk. You don't need a company gateway to get two emails written without personal data; you very much do if dozens of salespeople paste real opportunities every day. Overbuilding is waste, underestimating is the data leak we started from.

## Operational checklist to take to your DPO

- [ ] I know **who** uses AI tools in the company and on **which data** (Shadow IT audit done).
- [ ] I have a written one-page **policy**, signed and explained to employees.
- [ ] **Personal accounts** on AI tools are forbidden for work; there is a company instance.
- [ ] There is a **DPA (Art. 28)** with every cloud vendor that processes data for me.
- [ ] **Use for training** of my inputs is excluded (by contract).
- [ ] I have assessed **extra-EU transfers** (Art. 44) and sub-processors on the real chain.
- [ ] There is **masking** of forbidden data before cloud prompts (Art. 32).
- [ ] **Sensitive data** go to the **local model**, not the cloud.
- [ ] AI use is in the **records of processing**; there is a **DPIA** if the risk is high.
- [ ] I have checked with counsel whether any use is **high-risk** under the **AI Act**.
- [ ] There are **minimal logs** and a defined **retention**.

## The verdict: the problem isn't the AI, it's where the data ends up

Putting ChatGPT in the CRM becomes a data leak not because AI is evil, but because the banal gesture of pasting an opportunity sends Italian client data out of the EU, without a DPA, without a legal basis, without the controller — that's you — knowing. The "EU toggle" is necessary but not sufficient; real control goes through who is responsible in the chain, through minimisation, through masking, and above all through a policy that governs people and a convenient alternative that removes Shadow IT at the root. The most solid solution remains the simplest conceptually: **don't let the data leave** — local model for the sensitive, governed EU vendor for the rest. And remember the warning we started from: this is the technical checklist to take to your DPO, not their opinion. They give you the opinion; you bring them a clear picture of what actually happens — which you now have.

This is a brick of the [guide to models, costs and privacy of AI in-house]({{ '/en/pillar/models-cost-privacy/' | relative_url }}). If you want to secure AI use on *your* client data — gateway, masking, sovereign alternative — start from [who I am and how I work]({{ site.main_site }}/biografia/) or drop me a line at [contacts]({{ site.main_site }}/contatti/).

## FAQ

**1. Is using ChatGPT on client data illegal?**
It is not "illegal" in the absolute, but without the right frames (DPA, legal basis, transfer safeguards, minimisation) it is out-of-control processing for which you answer as controller. The salesperson's gesture of pasting an opportunity into their personal account, in particular, has no frame at all. The formal assessment belongs to your DPO; this article helps you bring them the picture.

**2. But if I turn on the EU region, aren't I fine?**
No: it is a useful step but it does not close the issue. You still have the processor relationship (you need the DPA), the assessment of sub-processors and transfers, the training opt-out, and above all control over who uses what. Data residency is necessary, not sufficient.

**3. Who is responsible if the data leave, me or OpenAI?**
The controller is you, the company, and the main responsibility remains yours. The vendor acts as processor (Art. 28) *if* there is a relationship governed by a DPA. Using someone else's tool does not transfer your responsibility as controller.

**4. What must I never paste into a cloud prompt?**
Names of real clients associated with information, VAT/tax code, IBAN, amounts tied to named people, health or judicial data, credentials, confidential contracts, strategies on named clients, candidate data. Practical rule: if you wouldn't write it on a postcard, don't paste it.

**5. Is data masking enough?**
It helps a lot (it intercepts VAT numbers, IBANs, emails, phones before sending) but it is not enough on its own: proper names slip through patterns. For truly sensitive data the real defence is routing the task to the local model, where data don't leave at all.

**6. What changes with the AI Act?**
It adds obligations based on risk level. Use for internal productivity (writing emails, summarising) is generally limited risk, with obligations especially of transparency. Use in decisions that affect people (hiring, credit) can be high-risk, with much heavier obligations. GDPR continues to apply in parallel. Check with counsel which case you're in.

**7. How do I stop employees who use ChatGPT in secret?**
Banning isn't enough: you need a clear policy, training on the why (not only the ban), and above all a convenient, governed alternative (company instance or local model). Shadow IT is born when the official tool is missing or inconvenient: remove that cause and it deflates.

**8. Do I have to do a DPIA?**
If using LLMs on client data presents high risks (large databases, profiling, decisions), probably yes — but it is an assessment to do with the DPO. The DPIA is where you decide, documenting it, whether that use of AI stands up and with which measures. It is not a bureaucratic form: it is the decision.

**9. What is the concrete alternative if I don't want to take the risk?**
Don't let the data leave: a local model (Ollama/vLLM) for tasks on sensitive data, so the transfer and the external processor do not arise. For light tasks that need more power, an EU vendor with a serious DPA, training opt-out, governed with policy and masking. Local default for the sensitive.

**10. How much does it cost me to get compliant?**
The technical work (gateway, masking) is contained; the local model has the cost of a GPU (~€800 used + electricity for internal use). But the right comparison is not with "zero": it is with the cost of unmanaged risk. A fine for unlawful processing of client data weighs orders of magnitude more than the solution. Getting compliant is almost always cheaper than the incident.
