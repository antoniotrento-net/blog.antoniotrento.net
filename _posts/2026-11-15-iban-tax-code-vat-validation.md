---
lang: en
permalink: /en/blog/iban-tax-code-vat-validation/
alt_url: /it/blog/validazione-iban-codice-fiscale-partita-iva/
title: "IBAN, tax code and VAT number: validators before the LLM (checksums, and the ban on \"completing\" a missing identifier)"
date: 2026-11-15 07:30:00 +0200
author: "Antonio Trento"
description: "An Italian validation library in front of the model: the tax code check character with omocodia, the VAT number check digit, IBAN with mod 97 and the Italian CIN. Pipeline order, no-invent policy, tests on a synthetic dataset, the UX of 'unreadable', logs without tax codes in clear and integration as an MCP tool or service for n8n."
keywords: ["iban tax code vat validation", "codice fiscale checksum", "italian vat number algorithm", "llm hallucinated identifiers", "python validators", "iban mod 97"]
image: /assets/images/posts/validazione-iban-codice-fiscale-partita-iva.jpg
pillar: rag-documenti
related: [/en/blog/document-extraction-field-accuracy/, /en/blog/imap-pec-invoice-agent/]
---

## The tax code nobody had written

The document was a crooked scan of a hand-filled form: a reimbursement request, with name, surname, date of birth, tax code (*codice fiscale*) and IBAN. The tax code was partly covered by a stamp: the first eleven characters were readable, then a smudge. The extraction pipeline — OCR plus a language model filling a JSON — returned a complete sixteen-character tax code. Perfect format. The final check character? Plausible. Nobody noticed, because the field was "full" and the UI showed it in green.

That tax code belonged to nobody. The model had written the last five positions: a "plausible" municipality code for the area of the document, a guessed check character. It went through because nobody had put between the model and the ERP the one thing that would certainly have stopped it: a deterministic validator. In another case, the same pattern produced an eleven-digit VAT number "completed" from nine readable ones, and an IBAN with two invented account digits. The IBAN, at least, was stopped by a mod-97 check on the bank's system. The rest wasn't.

This piece is about **validating IBANs, tax codes and VAT numbers before the LLM** — more precisely, *after* extraction and *before* the data enters any system. An Italian validation library, deterministic, tested, placed in front of the model as a goalkeeper. And a policy written in one line: **the system never completes a missing or unreadable identifier**. An unreadable field is useful information; an invented field is damage.

## Is this for you?

It is for you if:

- you extract personal or banking data from documents (forms, invoices, contracts, emails) with OCR, vision models or LLMs;
- you have agents or n8n flows that receive identifiers from free text and pass them to an ERP, a CRM or a bank;
- you've already seen a "plausible" identifier that didn't exist.

It is not for you if identifiers already reach you from structured, reliable sources (the e-invoice XML, verified master data, APIs of certified systems): validation is still useful there, but the problem of invention doesn't arise. And it is not a piece about verifying the *existence* of a party (which requires external databases): here we talk about verifying that an identifier is *well-formed and consistent*, the first, cheapest filter.

## Why the LLM fills gaps with plausible digits

A language model doesn't "read" a tax code: it generates the most likely next character given what it has seen. If it has seen "RSSMRA80A01H50" and then a smudge, the most likely continuation is a digit and a letter, because it has seen millions of tax codes with that shape. It has no notion of "I don't know" at single-character level, unless you give it explicitly as an option.

Three factors, almost always present in pipelines, make invention more likely:

**1. Required fields in the schema.** If the output JSON schema declares `tax_code` as a required sixteen-character string, and the model is constrained to respect it (strict mode, structured output), the only way to respect the schema when the data is missing is to invent it. The schema that was meant to protect you forced the error.

**2. Prompts that reward completeness.** "Extract all fields", "don't leave fields empty", "fill in the form": instructions that, to a model, mean "an empty field is a failure".

**3. Partial OCR.** OCR returns "RSSMRA80A01H5O1U" (with an O instead of a zero) or "RSSMRA80A01H5 1U" (with a space where there was a smudge). The model "corrects", and that's useful when the correction is obvious (O → 0 in a numeric position); it becomes dangerous when the correction is an invention (the space becomes a random digit).

The general problem — structured hallucination, which is worse than free-text hallucination because it looks like data — is the reason JSON Schema alone is not enough. Here I go into detail on the three most common Italian identifiers and how to build a library that checks them all, always, in the same way.

## Tax code and VAT checksums: use algorithms, not the model

The good news is that the Italian tax code and VAT number were designed, decades ago, with built-in error checking. The algorithms are public, documented in the decrees that established them, and implemented in dozens of libraries. There's no reason to ask a model whether a tax code "looks right".

### Tax code (codice fiscale)

The tax code of natural persons has sixteen characters:

- 3 letters from the surname, 3 from the first name;
- 2 digits for the year of birth;
- 1 letter for the month (A, B, C, D, E, H, L, M, P, R, S, T);
- 2 digits for the day of birth (for women the day is increased by 40);
- 4 characters for the municipality of birth or foreign state (one letter and three digits);
- 1 **check character**.

The check character is computed on the first fifteen characters: each character in an odd position (first, third, fifth…) gets a value from one table, each character in an even position a value from another table; they are summed, the remainder of division by 26 is taken, and converted into a letter (0 = A, 1 = B, …).

Then there's **omocodia**: when two people would have the same code, the tax authority replaces some digits with letters (0 = L, 1 = M, 2 = N, 3 = P, 4 = Q, 5 = R, 6 = S, 7 = T, 8 = U, 9 = V), starting from the right, and recomputes the check character. A validator that accepts only digits in numeric positions rejects real tax codes: a common mistake in validations done with a regex found online.

VAT numbers of legal entities also serve as their tax code (eleven digits): a "tax code" field in a company's master data can legitimately contain eleven digits. The validator must know that.

### VAT number (partita IVA)

The Italian VAT number has eleven digits:

- 7 digits of registration number;
- 3 digits of provincial office code;
- 1 **check digit**.

The check digit follows a Luhn-family algorithm: over the first ten digits, the digits in odd positions are summed as they are; those in even positions are doubled, and if the result exceeds 9, 9 is subtracted; the check digit is the one that brings the sum to the next multiple of 10.

### The library

Here is the heart of the library, reduced to what's needed. In production you can use a maintained library (for Python, `python-stdnum` implements the Italian tax code, VAT number and IBAN), but it pays to understand what it does — and to have your own version with tests, because behaviour on edge cases (omocodia, numeric tax codes, the "IT" prefix) must be what you expect.

```python
import re

_ODD = {**dict(zip("0123456789", [1, 0, 5, 7, 9, 13, 15, 17, 19, 21])),
        **dict(zip("ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                   [1, 0, 5, 7, 9, 13, 15, 17, 19, 21, 2, 4, 18, 20,
                    11, 3, 6, 8, 12, 14, 16, 10, 22, 25, 24, 23]))}
_EVEN = {**{str(d): d for d in range(10)},
         **{c: i for i, c in enumerate("ABCDEFGHIJKLMNOPQRSTUVWXYZ")}}
_OMOCODIA = dict(zip("LMNPQRSTUV", "0123456789"))
_CF_RE = re.compile(
    r"^[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST][0-9LMNPQRSTUV]{2}"
    r"[A-Z][0-9LMNPQRSTUV]{3}[A-Z]$")

def normalise(s: str) -> str:
    return re.sub(r"[\s\-\.]", "", s or "").upper()

def cf_check_char(first15: str) -> str:
    s = sum(_ODD[c] if i % 2 == 0 else _EVEN[c] for i, c in enumerate(first15))
    return chr(ord("A") + s % 26)

def cf_valid(cf: str) -> tuple[bool, str]:
    cf = normalise(cf)
    if len(cf) == 11:                       # numeric tax code of non-natural persons
        return vat_valid(cf)
    if len(cf) != 16:
        return False, "length"
    if not _CF_RE.match(cf):
        return False, "format"
    if cf_check_char(cf[:15]) != cf[15]:
        return False, "check_character"
    day = int("".join(_OMOCODIA.get(c, c) for c in cf[9:11]))
    if not (1 <= day <= 31 or 41 <= day <= 71):
        return False, "day"
    return True, "ok"

def vat_check_digit(first10: str) -> int:
    s = 0
    for i, c in enumerate(first10):
        n = int(c)
        if i % 2 == 1:
            n *= 2
            if n > 9:
                n -= 9
        s += n
    return (10 - s % 10) % 10

def vat_valid(vat: str) -> tuple[bool, str]:
    p = normalise(vat)
    if p.startswith("IT"):
        p = p[2:]
    if len(p) != 11 or not p.isdigit() or p == "0" * 11:
        return False, "format"
    if vat_check_digit(p[:10]) != int(p[10]):
        return False, "check_digit"
    return True, "ok"
```

Note the return type: not a simple `True/False`, but an outcome with a **reason**. The reason ends up in the logs and in the UI, and makes a big difference to whoever has to correct: "wrong check character" suggests a reading error on one character; "length" suggests a missing piece.

## IBAN: structure and mod 97

The IBAN (ISO 13616 standard) has a structure common to all countries:

- 2 letters of country code;
- 2 check digits;
- the BBAN, the national account number, with a fixed length and structure for each country.

The check digits are verified with the **mod 97** algorithm (ISO 7064, MOD 97-10): move the first four characters to the end, convert letters into numbers (A = 10, B = 11, …, Z = 35), and the resulting number, divided by 97, must leave remainder 1.

For Italy the BBAN has 23 characters, for a 27-character IBAN:

- 1 **CIN** letter (a national check);
- 5 digits of ABI (the bank);
- 5 digits of CAB (the branch);
- 12 characters of account number.

The Italian CIN is a second check, computed on ABI, CAB and account with the same odd/even tables as the tax code and the remainder of division by 26. A well-formed Italian IBAN therefore passes **two** independent checks.

```python
IBAN_LENGTHS = {"IT": 27, "SM": 27, "DE": 22, "FR": 27, "ES": 24,
                "AT": 20, "CH": 21, "NL": 18, "BE": 16}   # extend from the official IBAN registry

def iban_mod97(iban: str) -> int:
    r = iban[4:] + iban[:4]
    return int("".join(str(int(c, 36)) for c in r)) % 97

def it_cin(abi_cab_account: str) -> str:
    s = sum(_ODD[c] if i % 2 == 0 else _EVEN[c] for i, c in enumerate(abi_cab_account))
    return chr(ord("A") + s % 26)

def iban_valid(iban: str) -> tuple[bool, str]:
    s = normalise(iban)
    if not re.match(r"^[A-Z]{2}[0-9]{2}[A-Z0-9]{8,30}$", s):
        return False, "format"
    expected = IBAN_LENGTHS.get(s[:2])
    if expected is None:
        return False, "country_not_handled"
    if len(s) != expected:
        return False, "length"
    if iban_mod97(s) != 1:
        return False, "mod97"
    if s[:2] in ("IT", "SM"):
        if not re.match(r"^[A-Z][0-9]{10}[A-Z0-9]{12}$", s[4:]):
            return False, "bban_format"
        if it_cin(s[5:]) != s[4]:
            return False, "cin"
    return True, "ok"
```

Two things the library does **not** do, and that must be said clearly to whoever uses it:

- it doesn't verify that the account exists or belongs to that beneficiary: for that you need bank payee-verification services, which are another layer;
- `country_not_handled` doesn't mean "wrong IBAN": it means "I can't validate it". It must be treated as uncertainty, not as an error. The length table must be extended from the official IBAN registry for every country you work with.

### What these checks really catch

I measured the library on a synthetic dataset (how it's built is below): 20,000 valid identifiers per type, to which I applied two typical reading errors, substitution of one character and swap of two adjacent characters.

| Identifier | Check | Single-character substitution detected | Adjacent two-character swap detected |
|---|---|---|---|
| VAT number | check digit (Luhn) | 100% | ~97% (the 0↔9 swap slips through) |
| Tax code | mod 26 check character | 100% (within the same letter/digit class) | ~99.9% |
| Italian IBAN | mod 97 + CIN | 100% | 100% |

The known limit of the VAT number — swapping adjacent 0 and 9 doesn't change the sum — is a property of the algorithm, not a bug. But the table says something more important: **a value invented by a model**, which is not a small mutation of a real one but a plausible sequence, passes the check only by chance: about one time in ten for the VAT number, one in twenty-six for the tax code, much more rarely for an Italian IBAN. The validator stops almost everything, and for the rest you need the other layers (presence in source text, master data, a person).

## Pipeline: extract → validate → else human

The order of steps is the most important part. The same validator, placed at the wrong point, is of little use.

### Pipeline order

1. **Raw text extraction** (OCR or the document's native text). Kept as is, with coordinates if the document is a scan.
2. **Candidate extraction** by the model, with three possible states for each identifier: `read` (with the value and the text fragment it comes from), `unreadable` (the field is there but can't be read), `absent` (the field isn't in the document). The output schema **must** allow the `unreadable` and `absent` states: no identifier field is required as a string.
3. **Deterministic normalisation**: uppercase, removal of spaces and separators, OCR confusion fixes *only* where the position makes them unambiguous (an O in a tax-code position that can only be numeric becomes 0; an O in a position that can be a letter stays O).
4. **Presence check in the source**: the normalised value must appear in the normalised raw text (with the same unambiguous fixes). If the model returns a tax code that isn't in the text, it's an invention, even if it's valid.
5. **Format and checksum validation** with the library.
6. **Consistency checks**: is the tax code consistent with the date of birth and sex extracted from the same document? Does the supplier's VAT number match the one in master data for that company name? Is the IBAN the one already registered for that supplier or a new one?
7. **Decision**: if everything passes, the value proceeds; if something fails, the field goes to a person with the reason and the document crop. **Else, human** — never "else, ask the model again until it passes".

Step 7 deserves an extra line. Sending back to the model an identifier that failed the checksum, with the message "the check character is wrong, fix it", is the fastest way to get an invented identifier **that passes the checksum**. The model has no more information than before; it just has one more constraint to satisfy, and satisfies it by inventing better.

### No-invent policy

I write it like this, and it's the text I put in the prompt, in the process documentation and — above all — in the code:

> **The system does not complete, correct by deduction or reconstruct identifiers (tax code, VAT number, IBAN, document numbers) that are missing, partial or unreadable.** An identifier is accepted only if it is read in full in the source document and passes format, checksum and consistency checks. In every other case the field is marked as unreadable or absent and submitted to a person. Regenerating a rejected identifier by asking the model to correct it is not allowed.

In the prompt alone it isn't enough: the model can ignore it. It's the code that enforces it, with the presence-in-source check and the refusal of model retries.

```python
from dataclasses import dataclass

@dataclass
class Outcome:
    field: str
    state: str          # "valid" | "unreadable" | "absent" | "invalid" | "not_in_source" | "inconsistent"
    value: str | None
    reason: str | None

VALIDATORS = {"tax_code": cf_valid, "vat_number": vat_valid, "iban": iban_valid}

def check_identifier(field: str, candidate: dict, normalised_source_text: str) -> Outcome:
    state = candidate.get("state")
    if state in ("unreadable", "absent"):
        return Outcome(field, state, None, None)          # a gap stays a gap
    value = normalise(candidate.get("value", ""))
    if value not in normalised_source_text:
        return Outcome(field, "not_in_source", None, "value not present in the document")
    ok, reason = VALIDATORS[field](value)
    if not ok:
        return Outcome(field, "invalid", value, reason)    # no retry on the model
    return Outcome(field, "valid", value, None)
```

## Tests on a synthetic dataset (not real client data)

To test a validation library you need thousands of valid and invalid identifiers. The temptation is to take them from the ERP: "we have 40,000 clients, let's use those". It's a very bad idea: you're copying personal data into a test environment, perhaps into a repository, perhaps into CI on an external service, for a purpose you didn't collect it for.

You don't need to. Italian identifiers can be **generated** synthetically, valid by construction, because the algorithms are public:

- **VAT numbers**: ten random digits (with a plausible office code), plus the computed check digit;
- **tax codes**: random letters and digits in the right positions (month from the table, day within allowed ranges, municipality code in the right format), plus the computed check character; some with omocodia;
- **Italian IBANs**: random ABI, CAB and account, computed CIN, check digits computed with mod 97.

Then you generate the **mutations** that simulate real errors:

- single-character substitution (OCR reading error: 0/O, 1/I/L, 5/S, 8/B);
- adjacent two-character swap (typing error);
- truncation (a missing piece);
- extra characters (a dash, a space read as a character);
- entirely random "plausible" values with the right format (simulating invention).

And the **edge cases** to cover explicitly: omocodia, numeric tax codes of legal entities, VAT numbers with the "IT" prefix, IBANs written in groups of four with spaces, San Marino IBANs (same Italian structure), foreign IBANs from countries not handled.

```python
import random

def generate_vat(rng: random.Random) -> str:
    base = "".join(rng.choice("0123456789") for _ in range(7)) + rng.choice(["001", "015", "058", "088", "100"])
    return base + str(vat_check_digit(base))

def generate_it_iban(rng: random.Random) -> str:
    abi = f"{rng.randint(1000, 9999):05d}"
    cab = f"{rng.randint(1000, 99999):05d}"
    account = "".join(rng.choice("0123456789") for _ in range(12))
    bban = it_cin(abi + cab + account) + abi + cab + account
    check = 98 - int("".join(str(int(c, 36)) for c in bban + "IT00")) % 97
    return f"IT{check:02d}{bban}"

def test_vat_substitution_detected():
    rng = random.Random(7)
    for _ in range(5000):
        p = generate_vat(rng)
        i = rng.randrange(11)
        q = p[:i] + rng.choice([c for c in "0123456789" if c != p[i]]) + p[i + 1:]
        assert not vat_valid(q)[0]
```

The generator uses a fixed seed: tests are repeatable, and a failure reproduces. The synthetic dataset contains no real data, can live in the repository and run in any CI.

## UX: "unreadable field" ≠ "invented field"

Validation is of little use if the interface then treats a valid field, an unreadable field and an empty field the same way. The most common UX mistake is **pre-filling** the field with the model's guess and colouring it yellow: the operator, who sees fifty a day, confirms the yellow as they confirm the green.

The rules I use:

- **Valid**: the value is shown normally, with a discreet "verified" icon and the ability to see the document crop.
- **Unreadable**: the field is **empty**, labelled "unreadable in the document", with the crop of the area where it should be. The operator types it looking at the crop or the original. No pre-filled suggestion.
- **Absent**: the field is empty, labelled "not present in the document". Often that's correct information (a delivery note has no IBAN): the operator must be able to confirm "not needed".
- **Invalid**: the value read is shown **struck through** or in a separate area, with the reason in plain language ("the check character doesn't match: probably a reading error in one position"), and the input field is empty. You can see what was read, but to confirm it you have to retype it.
- **Not in source**: the sign of invention. The value must not be shown as a suggestion; at most, in a log for whoever maintains the system.

When the operator types the value, the same library validates it in real time, with the same message. A single implementation for pipeline and interface: if the library changes, both change.

## Logs: don't keep tax codes in clear longer than necessary

Tax codes and IBANs are personal data. A pipeline that validates them produces logs, and logs tend to live longer than the data itself, to be copied into observability tools, to end up in tickets and screenshots. Three precautions:

**1. Mask in application logs.** Validation logs don't need the full value. Type, outcome, reason and a document reference are enough. If you need to correlate several events on the same identifier, use an **HMAC** of the value with a key held in a secret: it lets you say "it's the same tax code as yesterday" without the log containing the tax code.

```json
{"event": "identifier_validation", "doc": "RIMB-2026-00871", "field": "tax_code",
 "outcome": "invalid", "reason": "check_character",
 "masked": "RSS***********U", "hmac": "3f9a1c…", "ts": "2026-11-15T10:12:44+01:00"}
```

**2. Never in debug prompts or LLM tracing in clear.** Model observability tools record prompts and answers; if the document contains identifiers, the trace contains them. Redaction before recording, short retention, restricted access.

**3. Proportionate retention.** Validation logs with masked references can live long; any logs with values in clear (needed to debug a specific case) have a short expiry and named access. The valid value lives in the destination system (the ERP), not in the pipeline.

## Integration into MCP/n8n tools

The library must be available **wherever** an identifier enters systems: extraction pipelines, agents, n8n flows, interfaces. The simplest way not to end up with three different implementations is to expose it as a small **internal HTTP service** (same code, tested once), and from there as a tool for agents.

### As an MCP tool

For an agent, validation is a read-only, safe tool that's worth always exposing. But it must be described so that the model uses it to check, not to "fix":

```json
{
  "name": "validate_identifier",
  "description": "Checks format and check digit of an Italian identifier (tax_code, vat_number, iban). Returns outcome and reason. Does NOT correct and does NOT suggest alternative values. If the outcome is negative, the field must be flagged to a person for verification: do not try to reconstruct the value.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "type": {"type": "string", "enum": ["tax_code", "vat_number", "iban"]},
      "value": {"type": "string", "maxLength": 40}
    },
    "required": ["type", "value"]
  }
}
```

Two rules on the MCP server side, which don't depend on the model:

- the tool returns only outcome and reason, never a "corrected" value;
- tools that **write** identifiers into systems (update a supplier's IBAN, record a tax code) internally call the same validation and reject invalid values, whatever the model said. The check lives in the write tool, not in the agent's goodwill.

### In n8n

In n8n the temptation is to copy the validation function into a Code node in every workflow. It works, but after six months you have six slightly different versions. Better:

- an HTTP Request node towards the internal validation service, with the identifier in the body;
- an IF node on the outcome: if valid it proceeds, otherwise the record goes into a review queue (a table, a task, a notification to the responsible person);
- never a branch that sends the text back to the model node "to fix it".

If the service is unreachable, the workflow must not consider the identifier valid by default: it must stop or send to review. It's the same fail-safe principle that applies to any control.

## Implementation path, step by step

1. **Inventory the entry points**: where tax codes, VAT numbers and IBANs enter your systems (document extraction, web forms, email, agents, file imports).
2. **Choose or write the library**, with outcomes and reasons, omocodia, numeric tax codes, prefixes, normalisation.
3. **Write the synthetic generator** and the test suite: valid values, mutations, edge cases. No real data.
4. **Expose the library as an internal service** and, for agents, as a read-only MCP tool.
5. **Change the extraction schema**: `read`, `unreadable`, `absent` states; no identifier required as a string.
6. **Add the presence-in-source check** and consistency checks (tax code vs date and sex, VAT number vs master data, IBAN vs known IBANs).
7. **Remove every retry towards the model** on rejected identifiers.
8. **Update the interface** with distinct states and real-time validation.
9. **Fix the logs**: masking, HMAC, redaction in tracing, retention.
10. **Add validation in write tools** (ERP, CRM, payments), as a final independent check.
11. **Measure**: how many identifiers rejected, by reason, by source; how many "not in source". It's your invention indicator.

## Typical failures and how to spot them in the logs

**Inventions caught by the presence check.**

```text
validate doc=RIMB-2026-00871 field=tax_code outcome=not_in_source checksum=ok
validate doc=RIMB-2026-00874 field=iban outcome=not_in_source checksum=ok
```

The value passes the checksum but doesn't appear in the document: the model reconstructed it. If the frequency rises, check the prompt (does it push for completeness?) and the schema (required fields?).

**Retries that "fix".**

```text
extract doc=FT-2026-3310 field=vat_number attempt=1 outcome=invalid reason=check_digit
extract doc=FT-2026-3310 field=vat_number attempt=2 outcome=valid
```

A second attempt on the same document that passes: the model changed a digit to make the check work. If this sequence exists in your flow, there's a retry to remove.

**Omocodia rejected.**

```text
validate field=tax_code outcome=invalid reason=format value=RSSMRA80A01H50MV
```

A tax code with letters in numeric positions rejected for format: the regex doesn't handle omocodia. A library bug, not a document problem.

**Country not handled treated as an error.** Many `country_not_handled` on foreign suppliers ending up in the queue as "wrong IBAN": it's a length-table or UX problem, not a data problem.

**Values in clear in the logs.** A search for a tax-code pattern in application logs or tracing that returns results. Treat it as a small incident: clean-up, fix the redaction, check where they were copied.

## Costs: orders of magnitude

Indicative estimates.

| Item | Order of magnitude (estimate) | Notes |
|---|---|---|
| Validation library with synthetic tests | 2–4 person-days | Less if you start from a maintained library |
| Internal HTTP service + MCP tool | 1–2 person-days | Minimal container, no LLM |
| Extraction schema change and source check | 2–5 person-days | Depends on the existing pipeline |
| UI with distinct states and real-time validation | 2–6 person-days | The real time is in testing with operators |
| Log masking and redaction | 1–3 person-days | More if there are many logging tools |
| Running cost | negligible | Microseconds per validation, no GPU |

The running cost is the most interesting detail: a deterministic validation costs practically nothing, and every model call you avoid (to "check" or "fix" an identifier) is pure saving in tokens and latency.

## When NOT to do it

More than "when not to do it", there are cases where the library isn't enough or isn't the problem:

- **When you need to know whether the party exists.** The checksum says a tax code is well-formed, not that it belongs to a real person or to that person. Existence checks need external databases and services, with their own access rules.
- **When you need to know whether the IBAN belongs to the beneficiary.** Mod 97 doesn't tell you. For payments, payee verification and checks on new or changed IBANs (confirmed through an independent channel) are another, essential layer.
- **When identifiers come from reliable structured sources.** Validating anyway costs little; but if you find yourself building presence-in-source checks on an XML, you're using the wrong tool: copy the field from the XML and that's it.
- **When volume is minimal.** Ten forms a month can be checked by a person; the library is still useful as form validation, but you don't need the full pipeline.

What has no exceptions is the no-invent policy: even with a single document a month, an identifier reconstructed by a model must not enter a system.

## Operational checklist

- [ ] There's a single validation library, used by pipelines, agents, n8n and interfaces.
- [ ] The library handles omocodia, numeric tax codes, the "IT" prefix, spaces and separators, and returns a reason.
- [ ] IBAN: mod 97, per-country length, CIN for Italy and San Marino; `country_not_handled` treated as uncertainty.
- [ ] Tests on a synthetic dataset generated with a fixed seed; no real data in tests.
- [ ] The extraction schema has `unreadable` and `absent` states; no identifier required as a string.
- [ ] Every accepted identifier is present in the source text.
- [ ] No retry towards the model to fix a rejected identifier.
- [ ] Consistency checks with other fields and with master data.
- [ ] The UI never pre-fills an unreadable or invalid identifier.
- [ ] Logs with masked or HMAC values; redaction in LLM tracing.
- [ ] Write tools validate independently of the agent.
- [ ] The no-invent policy is written in the prompt, in the documentation and — above all — in the code.

## The verdict

Validating IBANs, tax codes and VAT numbers is one of the rare points where engineering offers almost complete certainty at almost zero cost. The algorithms have been public for decades, are implemented in a hundred lines, are tested on synthetic data without touching real data, run in microseconds. Not putting them between the model and your systems is a choice nobody should make by distraction.

But the most important part isn't the checksum: it's the rule that comes with it. A language model, faced with a gap, tends to fill it with something plausible. The pipeline's job is to prevent it, structurally: schemas that allow "unreadable", a check that the value exists in the document, no retries to make the numbers work, an interface that doesn't pre-fill. An empty field labelled "unreadable" costs a person thirty seconds. An invented tax code can cost many people weeks.

If you're putting language models in contact with personal and banking data and want to set up the checks before an invented identifier reaches production, you'll find my background in the [biography]({{ site.main_site }}/biografia/) and the rest of my work on [antoniotrento.net]({{ site.main_site }}/). To measure how well your pipeline extracts the fields that matter, the companion piece is the one on [field-level document extraction accuracy]({{ '/en/blog/document-extraction-field-accuracy/' | relative_url }}); the others are collected in the guide on [RAG and documents]({{ '/en/pillar/rag-documents/' | relative_url }}).

## FAQ

### How do you check whether an Italian tax code is valid?

You check the length (16 characters for natural persons, 11 digits for other parties), the format of each position taking omocodia into account, the day of birth within allowed ranges (for women increased by 40), and the final check character, computed on the first fifteen characters with two value tables for odd and even positions and the remainder of division by 26. Formal validity doesn't prove the code belongs to a real person.

### What is the Italian VAT number check algorithm?

Over the first ten digits, the digits in odd positions are summed as they are and those in even positions are doubled (subtracting 9 if the double exceeds 9). The check digit is the one that brings the sum to the next multiple of 10. It's a Luhn-family algorithm: it catches every single-digit substitution and almost every swap of adjacent digits.

### How does the IBAN mod 97 check work?

You move the first four characters (country code and check digits) to the end, convert letters to numbers (A = 10 up to Z = 35) and compute the remainder of dividing the resulting number by 97: it must be 1. For Italian IBANs you also check the 27-character length and the CIN, a second national check character.

### Why does an LLM invent tax codes and IBANs?

Because it generates the most likely character given the context and has no native notion of "I don't know" for a single character. The risk increases when the output schema makes identifier fields required, when the prompt asks not to leave fields empty and when OCR returns partial values that the model "completes".

### Is the checksum enough to block an invented identifier?

It blocks the vast majority: a plausible but random value passes the check only by chance, about one time in ten for the VAT number, one in twenty-six for the tax code and much more rarely for an Italian IBAN. For the rest you need other layers: checking that the value appears in the source document, consistency checks with master data and human review.

### What does the no-invent policy mean?

That the system does not complete, reconstruct or correct by deduction identifiers that are missing, partial or unreadable. An identifier is accepted only if it is read in full in the document and passes format, checksum and consistency; otherwise the field is marked as unreadable or absent and passed to a person. Asking the model to correct a rejected value is forbidden.

### How do you test validators without using real client data?

By generating synthetic identifiers that are valid by construction, thanks to the public algorithms: random digits plus computed check digit for the VAT number, random positions plus check character for the tax code, random ABI, CAB and account with computed CIN and mod 97 for the IBAN. Then you apply mutations that simulate reading and typing errors and cover edge cases such as omocodia.

### How should an invalid identifier be shown to the operator?

By clearly distinguishing the states: valid, unreadable, absent, invalid. An unreadable field stays empty with the document crop; an invalid value is shown struck through with the reason, and the input field is empty, so the operator must retype it looking at the document. The model's guess is never pre-filled.

### Can tax codes and IBANs be stored in logs?

Not in clear, except for the strictly necessary time and with restricted access. Application logs only need type, outcome, reason and document reference; to correlate events on the same identifier you use an HMAC with a secret key. LLM tracing must also be redacted before recording.

### How do you integrate validation into an MCP agent or n8n?

By exposing a single library as an internal service and, for agents, as a read-only tool that returns outcome and reason without ever suggesting corrections. Tools that write identifiers into systems must validate independently. In n8n you call the service with an HTTP node and route to a review queue on a negative outcome, without sending the value back to the model.
