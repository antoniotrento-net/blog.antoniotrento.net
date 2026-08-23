---
lang: en
permalink: /en/blog/chunking-italian-contracts-rag/
alt_url: /it/blog/chunking-contratti-italiani-rag/
title: "Chunking Italian contracts: why splitting every 500 tokens makes you miss unfair clauses and competent courts"
date: 2026-09-28 07:30:00 +0200
author: "Antonio Trento"
description: "Chunking Italian contracts for RAG: why fixed-length splits destroy cross-references, unfair clauses and the competent court, and how to build a splitter for articles and paragraphs with overlap and metadata that holds legal queries."
keywords: ["chunking italian contracts rag", "unfair clauses nlp", "legal rag", "chunk overlap", "recursive split pdf", "italian legal text nlp"]
image: /assets/images/posts/chunking-contratti-italiani-rag.jpg
pillar: rag-documenti
related: [/en/blog/pgvector-rag-electronic-invoices/, /en/blog/eu-ai-act-sme-agents-2026/]
---

## "Salvo quanto previsto all'art. 7" — and art. 7 is in another chunk

I'll show you the fastest way to build a legal RAG that looks fine in the demo and betrays you in production: take the contract PDFs, split them every 500 tokens with the default splitter, embed them, and ask the model "qual è il *foro competente*?" — the competent court. In the demo it answers. Then the real query arrives — *"can I withdraw early without a penalty?"* — and the model gives you a confident, wrong answer, because the clause said *"il recesso è libero, salvo quanto previsto all'art. 7"* ("withdrawal is free, except as provided in art. 7"), and art. 7 (which imposes a 30% *penale*, penalty) landed in a different chunk, never retrieved. The model read half a clause and completed it with confidence. In a contract, half a clause is worse than no clause.

That is the topic: **chunking Italian contracts for RAG** is not the same problem as chunking a blog or a knowledge base. A contract has a rigid structure (*articoli*, *commi*, cross-references, annexes) and a language where a single conjunction — *"salvo"*, *"fermo restando"*, *"in deroga a"* — flips the meaning. Splitting it at a fixed length, as the naive splitter does, destroys exactly what makes a contract a contract: the cross-references and the boundaries between norms.

Let's do it properly: a splitter for *articoli* and *commi*, smart overlap, a metadata schema built for legal text, and evaluation with a lawyer in the loop. And above all — because this is the part almost everyone skips — **what you must never ask this system.**

**Disclaimer, now and clear:** I am not a lawyer. This is an engineering piece on how to index and retrieve contractual text, not on how to interpret it. The legal RAG I talk about is a tool to *find and cite* clauses, not to *replace* a legal opinion. I come back to that boundary later, because that is where the real damage happens.

## A contract is not a blog post: structure and cross-references

A blog article is linear: you read it top to bottom, each paragraph almost stands alone. A contract is not. A contract is a **graph**, not linear text. Its structural traits are precise:

- **Rigid hierarchy:** Recitals → *Articoli* (Art. 1 – Subject, Art. 2 – Term…) → *commi* (numbered paragraphs of an article, or letters) → sub-paragraphs → Annexes.
- **Constant cross-references:** *"ai sensi dell'art. 4"*, *"fatto salvo quanto previsto al comma 3"*, *"come da Allegato B"*, *"in deroga all'art. 9"*. A clause often has no meaning without the one it points to.
- **Dense conditional language:** *"salvo che"*, *"ferma restando"*, *"a condizione che"*, *"salvo il caso in cui"*. The sense of a sentence depends on a subordinate that may sit 30 words later.
- **Clauses with huge weight and almost no text:** the *foro competente* clause is one line. The *penale* clause is two lines. They weigh more than entire pages of recitals.
- **Para-textual elements that are legally binding:** date, signatures, initials on every page, and — crucial in Italy — the **doppia sottoscrizione** (double signature / specific written approval) of *clausole vessatorie* (unfair / onerous clauses) under art. 1341 *comma* 2 c.c. (Italian Civil Code).

Anyone doing **NLP on Italian legal text** has to treat this structure as primary data, not noise to flatten. The right chunk for a contract is not "a block of N tokens": it is a **unit of legal meaning** — typically an *articolo* or a *comma* — with its boundaries and its cross-references preserved.

This is the same principle I used for electronic-invoice ingest: respect the document structure instead of treating it as flat text. In the piece on how I index {{ '/en/blog/pgvector-rag-electronic-invoices/' | relative_url }} the constraint was FatturaPA XML; here it is the *articolo*/*comma* structure. The format changes, the principle does not: **structure is information; throwing it away is losing quality.**

## The naive splitter's mistakes (and why they look harmless)

The default splitter — the one in every tutorial — does one of two things, both wrong for a contract.

**Mistake 1: fixed-length split (500 tokens, 1000 characters).** It cuts the text every N units, ignoring semantic boundaries. Result:

- It truncates clauses in the middle. The subordinate *"salvo quanto previsto all'art. 7"* lands in one chunk, the main clause in the other.
- It separates the cross-reference from its target. The chunk that says "in deroga all'art. 9" does not contain art. 9, and retrieval may never fetch it.
- It mixes the end of one *articolo* with the start of the next: a chunk that is half "Term" and half "Withdrawal", which answers neither query well.

**Mistake 2: splitting on markdown headers that do not exist.** Many "structural" splitters look for markdown headers (`#`, `##`). A contract PDF **has no markdown headers.** It has "Art. 1", "Articolo 2 – Oggetto", "1.", "a)", numbering the PDF renders as ordinary text. The markdown-aware splitter, on a contract, behaves exactly like the fixed-length one: it finds no headers, and cuts at random.

The trap is that **in the demo you do not notice.** Easy queries ("who are the parties?", "what is the subject of the contract?") fish from the recitals, which are linear and survive any split. It is on the queries that matter — *recesso*, *penale*, *foro*, term, derogations — that the system collapses, because those live in precise clauses, often with cross-references. And those are exactly the queries someone would use a legal RAG for.

Here is a concrete **bad chunk vs good chunk** on the same clause.

**Bad chunk** (500-token split, cut mid-sentence):

```
...la fornitura avrà durata di 24 (ventiquattro) mesi decorrenti
dalla data di sottoscrizione. Il Cliente ha facoltà di recedere
anticipatamente dandone comunicazione scritta con preavviso di
30 giorni, salvo quanto
--- END OF CHUNK ---
```

The next chunk starts with "previsto all'art. 7 in materia di penali...", but nothing guarantees it is retrieved together. The model reads "free withdrawal with 30 days' notice" and answers accordingly. Wrong.

**Good chunk** (split by *articolo*, whole clause + cross-reference resolved in metadata):

```
[Art. 5 – Durata e recesso]
La fornitura avrà durata di 24 (ventiquattro) mesi decorrenti dalla
data di sottoscrizione. Il Cliente ha facoltà di recedere
anticipatamente dandone comunicazione scritta con preavviso di 30
giorni, salvo quanto previsto all'art. 7 (Penali).
[rinvii: art. 7]
```

The chunk is a complete unit, the cross-reference is explicit in the metadata, and at runtime I can retrieve *art. 7 as well* because I know it is needed. That is the difference between a legal RAG that helps and one that lies.

## A splitter for articoli and commi, with smart overlap

The strategy is: **identify the structure first, then split on structural boundaries**, not on length. Only if an *articolo* is too long for the embedding do you subdivide it further by *comma*, keeping the article heading in every sub-chunk.

A minimal structural parser for Italian contracts:

```python
import re
from dataclasses import dataclass, field

# Matches "Art. 5", "Articolo 5", "ART. 5 -", "5. " at line start
RE_ARTICOLO = re.compile(
    r"^\s*(?:art(?:icolo)?\.?\s*)(\d+)\s*[\.\-–—:]?\s*(.*)$",
    re.IGNORECASE | re.MULTILINE,
)
# Matches commi: "1.", "2)", "a)", "1-bis"
RE_COMMA = re.compile(r"^\s*(\d+(?:-bis|-ter)?[\.\)]|[a-z]\))\s+", re.MULTILINE)
# Cross-references to extract into metadata
RE_RINVIO = re.compile(
    r"art(?:icolo)?\.?\s*(\d+)|allegato\s+([A-Z0-9]+)", re.IGNORECASE
)

@dataclass
class Chunk:
    articolo: int
    titolo: str
    testo: str
    rinvii: list = field(default_factory=list)

def split_contratto(testo: str) -> list[Chunk]:
    """Split by articolo; each chunk is a unit of meaning, not 500 tokens."""
    matches = list(RE_ARTICOLO.finditer(testo))
    chunks = []
    for i, m in enumerate(matches):
        start = m.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(testo)
        corpo = testo[start:end].strip()
        num = int(m.group(1))
        titolo = (m.group(2) or "").strip()
        rinvii = sorted({
            f"art.{a}" if a else f"all.{b}"
            for a, b in RE_RINVIO.findall(corpo)
            if (a and int(a) != num) or b     # no self-reference
        })
        chunks.append(Chunk(num, titolo, corpo, rinvii))
    return chunks
```

Then, for *articoli* that are too long, the split by *commi* with **smart overlap** — which is not "overlap 50 tokens at random", but "repeat the article heading and the previous last *comma*":

```python
MAX_CHAR = 1800   # under a comfortable embedding limit

def split_lungo(chunk: Chunk) -> list[Chunk]:
    if len(chunk.testo) <= MAX_CHAR:
        return [chunk]
    commi = RE_COMMA.split(chunk.testo)
    intestazione = f"[Art. {chunk.articolo} – {chunk.titolo}]"
    out, buff = [], intestazione
    for pezzo in commi:
        if len(buff) + len(pezzo) > MAX_CHAR and buff != intestazione:
            out.append(Chunk(chunk.articolo, chunk.titolo, buff, chunk.rinvii))
            # SEMANTIC overlap: every sub-chunk restarts from the heading
            buff = intestazione + " " + pezzo
        else:
            buff += " " + pezzo
    out.append(Chunk(chunk.articolo, chunk.titolo, buff, chunk.rinvii))
    return out
```

The point about **chunk overlap**: in generic NLP, overlap exists so you do not lose sentences cut at the boundary. In contracts it does something more targeted — **never detach a *comma* from its article heading**. A *comma* that says "withdrawal is not allowed" is useless if you do not know which *articolo* it belongs to. The repeated heading is the overlap that counts. It is targeted, not fixed-length: it costs a few tokens and saves the meaning.

The difference between the two approaches, in a table:

| Aspect | Naive splitter (500 tokens) | Structural splitter |
|--------|-----------------------------|---------------------|
| Cut boundary | fixed length | *articolo* / *comma* |
| Truncated clauses | frequent | never (whole units) |
| Cross-references preserved | no | yes, in metadata |
| Article heading | lost in sub-blocks | repeated (overlap) |
| Queries on precise clauses | unreliable | reliable |
| Development cost | zero | a few days |

## Metadata: party, date, version, signature, annex

The chunk text is not enough. In contracts, **context** is half the information, and it goes in the metadata — both to filter at runtime and to cite the exact source. The schema I use:

```json
{
  "chunk_id": "c_2024_nda_acme_art5_0",
  "documento": {
    "titolo": "NDA reciproco ACME-Fornitore",
    "tipo": "nda",
    "parti": ["ACME S.r.l.", "Fornitore S.p.A."],
    "data_stipula": "2024-03-12",
    "versione": "2.1",
    "firmato": true,
    "doppia_sottoscrizione_1341": true,
    "origine": "digitale",
    "hash_documento": "sha256:9f2c..."
  },
  "posizione": {
    "articolo": 5,
    "titolo_articolo": "Durata e recesso",
    "commi": ["1", "2"],
    "pagina": 3,
    "allegato": null
  },
  "rinvii": ["art.7", "all.B"],
  "clausola_sensibile": ["recesso", "penale"],
  "testo": "[Art. 5 – Durata e recesso] La fornitura avrà durata..."
}
```

Why each field earns its place:

- **`parti`, `data_stipula`, `versione`:** without these, a RAG with several versions of the same contract answers by citing the wrong version. The version filter is mandatory, not optional.
- **`firmato`, `doppia_sottoscrizione_1341`:** in Italy a *clausola vessatoria* (exclusive *foro*, limitation of liability, *recesso*, *penali*) is ineffective if not specifically approved in writing under art. 1341 c.c. Knowing whether the double signature is there changes the answer. It is a legally material fact that the text alone does not capture.
- **`rinvii`:** enables two-step retrieval (I retrieve art. 5, see that it points to art. 7, retrieve that too).
- **`clausola_sensibile`:** labels that allow targeted queries ("show me every *penale* in this contract") and raise the attention threshold in the answer.
- **`hash_documento`, `pagina`:** for a verifiable citation — the RAG must be able to say "art. 5, p. 3 of document X", so a human can check the source.

The rule: **every answer from the legal RAG must be able to point to the *articolo*, the page and the exact version.** A RAG that answers without citing the precise source, in a contractual setting, is unusable — because nobody will act on a clause without checking it.

## The reference architecture

Here is the full pipeline, with the boundaries drawn where they belong. Note the sovereignty constraint: contracts are confidential data, they stay self-hosted or in the EU under the client's control, never on a generic SaaS.

```
   Contract PDF ──▶ ┌──────────────────────────────────┐
                    │ 1. TRIAGE: digital or scanned?    │
                    │    extractable text → direct path │
                    │    image → OCR                    │
                    └───────────────┬────────────────────┘
                                    ▼
                    ┌──────────────────────────────────┐
                    │ 2. STRUCTURAL PARSER              │
                    │    articoli, commi, annexes,      │
                    │    rinvii, signatures, double sig.│
                    └───────────────┬────────────────────┘
                                    ▼
                    ┌──────────────────────────────────┐
                    │ 3. CHUNKING by articolo/comma     │
                    │    + heading overlap              │
                    │    + full metadata                │
                    └───────────────┬────────────────────┘
                                    ▼
                    ┌──────────────────────────────────┐
                    │ 4. EMBEDDING + pgvector (EU)      │
                    └───────────────┬────────────────────┘
                                    ▼
                    ┌──────────────────────────────────┐
                    │ 5. RETRIEVAL: query → chunk +     │
                    │    rinvii expansion (2 steps)     │
                    └───────────────┬────────────────────┘
                                    ▼
                    ┌──────────────────────────────────┐
                    │ 6. LLM: answers ONLY by citing    │
                    │    chunks, with art./page/version │
                    └───────────────┬────────────────────┘
                                    ▼
                    ┌──────────────────────────────────┐
                    │ 7. LAWYER in the loop for decisions│
                    └──────────────────────────────────┘
```

**What the system NEVER does** (the boundaries you write in the open):

- It does not give **legal opinions**. It finds and cites clauses. Interpretation is the lawyer's.
- It does not **invent** missing clauses. If it does not find them, it says "not found", it does not complete.
- It does not **decide** (sign, withdraw, challenge). It proposes where to look.
- It does not send contracts out to uncontrolled external services.

This setup — a model that retrieves and cites, a human who interprets and decides — is the same security and compliance philosophy I described for the {{ '/en/blog/eu-ai-act-sme-agents-2026/' | relative_url }}: the AI proposes, the expert disposes. In a legal setting the boundary is even sharper, because an interpretation error has real contractual consequences.

## Implementation path, step by step

1. **Collect a representative sample:** 20–30 contracts of the types you handle (NDAs, preliminaries, SLAs, supply), both digital and scanned.
2. **Build the digital/OCR triage** and verify it by hand on every type: OCR on scanned contracts is the most fragile point (see below).
3. **Implement the structural parser** and validate that it recognises *articoli* and *commi* on *every* format in the sample. Contracts are drafted by different firms: numbering varies ("Art. 1", "Articolo 1", "1."). The parser has to hold the variants.
4. **Generate chunks with metadata** and inspect a sample by eye: look for truncated clauses, lost cross-references, missing headings.
5. **Embed and index** in pgvector, with metadata as filterable columns (version, type, parties).
6. **Implement two-step retrieval:** retrieve chunks for the query, then expand by following the `rinvii` of the chunks you found.
7. **Constrain the prompt** to answer only from retrieved chunks, citing *articolo*/page/version, and to say "not found" when it is missing.
8. **Build the gold set with the lawyer** (below) and measure before you go to production.

## Typical queries and how they hold

The queries a legal RAG actually exists for, and what they need in order to work:

| Typical query | What it must retrieve | Risk if chunking is naive |
|---------------|----------------------|---------------------------|
| "Can I withdraw, and with what notice?" | *Art. recesso* + *rinvii* to *penali* | Loses the referred *penale* |
| "What is the *foro competente*?" | *Foro* clause + double signature 1341 | Does not know if it is effective |
| "Is there a *penale*? How much?" | *Art. penale* + calculation base | Finds the % but not the base |
| "How long does the NDA last after the end?" | Duration of post-contractual duties | Confuses contract term and duties |
| "Are there limitations of liability?" | Limiting clauses + 1341 | Treats them as ordinary clauses |

The common thread: **legal queries almost always touch clauses with cross-references or with *vessatoria* relevance.** That is exactly what the naive splitter destroys. A legal RAG is judged on these queries, not on "who are the parties".

## A real query, step by step: "can I withdraw without a penalty?"

Let's put two-step retrieval to work on a treacherous query, because this is where structural chunking pays off or collapses. The user's question: *"can I withdraw early, and do I have to pay anything?"*.

**Step 1 — retrieval on the query.** Vector search fishes the semantically close chunks. It finds Art. 5 (Term and withdrawal), which says: *"Il Cliente ha facoltà di recedere con preavviso di 30 giorni, salvo quanto previsto all'art. 7"*. A naive splitter would stop here, and the model would answer: *"Yes, you can withdraw with 30 days' notice"* — half true, therefore false.

**Step 2 — expansion of the *rinvii*.** The Art. 5 chunk has `"rinvii": ["art.7"]` in its metadata. Before generating, the system also retrieves Art. 7, which reads: *"In caso di recesso anticipato è dovuta una penale pari al 30% del corrispettivo residuo"*. Now the model has both pieces in context.

**Step 3 — constrained generation.** The model answers citing the sources: *"Early withdrawal is allowed with 30 days' notice (Art. 5), but it carries a 30% penalty on the remaining consideration (Art. 7, p. 4, version 2.1). Verify with counsel."* This answer is useful because it is **complete and cited**.

The lesson: without structural chunking you would not have had the cross-reference in the metadata; without two-step retrieval you would not have retrieved Art. 7; without the citation constraint you would not have known where the answer came from. The three pieces work together. Remove one and the system goes back to lying with confidence — the worst failure mode, because it is the most convincing.

## Evaluation with the lawyer in the loop: the gold set

This is where I separate serious projects from toys. A legal RAG **is not evaluated by feel.** You build a *gold set*: a set of real questions with the correct answer and the exact citation, verified by a lawyer. Then you measure the system against that gold set on every change (new model, new splitter, new prompt).

How I build it:

- 30–50 questions on the sample contracts, from the simplest to the most treacherous (the ones with cross-references and derogations).
- For each, the lawyer indicates: the correct answer, the *articolo/i* that contain it, and whether there are traps (unsigned *clausole vessatorie*, *rinvii* that flip the meaning).
- You measure two things: **retrieval** (did the system retrieve the right chunks?) and **faithfulness** (does the answer rest only on those chunks, without inventing?).

```python
def valuta(gold, sistema):
    hit, faithful = 0, 0
    for caso in gold:
        recuperati = sistema.retrieve(caso["domanda"])
        ids = {c["chunk_id"] for c in recuperati}
        # retrieval: did I get the expected articoli (rinvii included)?
        if set(caso["chunk_attesi"]).issubset(ids):
            hit += 1
        risposta = sistema.answer(caso["domanda"], recuperati)
        # faithfulness: no claim outside the cited chunks
        if risposta["citazioni"] and not risposta["inventato"]:
            faithful += 1
    n = len(gold)
    print(f"retrieval@k: {hit/n:.0%}  faithfulness: {faithful/n:.0%}")
```

The rule I hand over: **until retrieval on the gold set clears a high bar (and the questions with *rinvii* are the ones to look at first), the system does not go near a user.** And the lawyer is not a one-off reviewer: they are in the loop, because they are the only ones who know whether a "plausible" answer is legally right.

## What you must NEVER ask the legal RAG

This section should sit at the top, but I put it here because now you have the context to understand it. The legal RAG is a tool for **assisted retrieval**, not a lawyer. The things it must never do:

- **Give a substitute legal opinion.** *"Is this contract in my interest?"* is not a RAG question. It is interpretation, risk assessment, strategy — lawyer work. The RAG can tell you *where* withdrawal is written, not *whether* you should exercise it.
- **Decide actions.** *"Should I sign?"* / *"Do I withdraw?"* → no. The RAG finds and cites; the human decides.
- **Interpret ambiguous clauses.** When a clause is obscure, the right answer is "this clause is ambiguous, ask the lawyer", not an invented interpretation in a confident tone.
- **Assess the validity of *clausole vessatorie*.** The RAG can flag "this is a potentially *vessatoria* clause and the *doppia sottoscrizione* does not appear", which is very useful — but the conclusion on effectiveness is the lawyer's.
- **Confuse "not found" with "does not exist".** If the system does not retrieve a clause, it must say "I did not find it", not "it is not provided". In a contract those are different things, and the second is dangerous.

The **disclaimer on the role of AI** goes in the interface, not only in your head: *"This tool helps find and cite clauses in the uploaded contracts. It does not provide legal opinions. Contractual decisions require a professional's assessment."* That is not bureaucracy: it is the line that stops someone from taking a multi-thousand-euro decision on the back of a retrieval.

## Pipeline from scanned PDF (OCR) vs digital

Half of real contracts arrive as a **scanned PDF** — the signed copy, put through the scanner. And OCR is where your nice structural parser dies in silence, if you are not careful.

Triage is the first step: distinguish PDFs with extractable text from image-PDFs.

```python
from pypdf import PdfReader

def serve_ocr(path: str, soglia_char_pagina: int = 100) -> bool:
    reader = PdfReader(path)
    tot = sum(len((p.extract_text() or "")) for p in reader.pages)
    media = tot / max(len(reader.pages), 1)
    # a few dozen characters per page = almost certainly scanned
    return media < soglia_char_pagina
```

If OCR is needed, the constraints specific to Italian contracts:

- **Use self-hosted OCR** (e.g. Tesseract with language `ita`, or more modern engines in a container). Contracts do not go up to a generic cloud OCR: they are confidential data. Sovereign default, always.
- **OCR gets numbers and *articoli* wrong.** "Art. 7" becomes "Art. 1" or "Art. Z", *commi* get mixed up. The structural parser, which relies on numbering, tilts. You need a **post-OCR normalisation** step that rebuilds the sequence of *articoli* (they must be increasing; a jump or a duplicate is an OCR error to correct or flag).
- **Scan quality is variable.** Stamps, signatures and initials overlaid on the text confuse OCR. These spots — often exactly the *clausole vessatorie* with the double signature — are the most delicate.
- **Always flag the origin** in the metadata (`"origine": "ocr"`). An answer based on an OCR chunk must be marked "verify against the original", because text fidelity is not guaranteed.

Operational rule: **an OCR contract does not have the same trust level as a digital one.** If the signed document counts (and in a dispute it always counts), the RAG citation must point back to the scanned original, and the lawyer looks at that, not at the extracted text.

## Typical failures and how you spot them in the logs

- **Retrieval that never fetches the target *articoli* of the *rinvii*.** If you log, for every query, the retrieved `chunk_id`s and compare them with the *rinvii* of the chunks you found, you see when the system retrieves art. 5 but not the art. 7 it points to. It is failure number one of legal RAG. Log: `query`, `chunk_recuperati`, `rinvii_non_seguiti`.
- **Answers without a citation.** If an answer does not contain *articolo*/page/version, it is by definition unreliable. Log the presence/absence of citations and alarm on absences.
- **"Not provided" instead of "not found".** Search the logs for answers that deny the existence of a clause: cross them with the gold set. Often it is failed retrieval dressed up as a confident answer.
- **Non-monotonic *articolo* numbering after OCR.** If the parser produces *articoli* out of sequence (1, 2, 4, 3, 7…), you have an OCR or parsing error. Log the extracted sequence per document and alarm on jumps.
- **Ambiguous version.** If retrieval fishes chunks from two different versions of the same contract for the same query, the answer mixes incompatible texts. Log the `versione` of retrieved chunks: they must be consistent.
- **Chunks too long that exceed the embedding limit.** A huge *articolo* that was not subdivided gets truncated by the embedder and loses the tail. Log chunk length and the share near the limit.

The rule is the same as for any RAG: **log the retrieval, not only the answer.** In a legal setting, 90% of the problems are "I did not retrieve the right clause", and you only see that if you log what you retrieved and what you should have.

## Costs: orders of magnitude

Stated estimates, for a corpus of a few thousand contracts (SME, firm, in-house legal office).

- **Pipeline development** (structural parser + chunking + metadata + two-step retrieval + OCR): as an order of magnitude **1–3 person-weeks**; the OCR part and post-OCR normalisation are the most expensive if you have many scans.
- **Corpus embedding:** with a self-hosted embedding model, thousands of contracts are hours of compute on a mid-range GPU, once. If you use an embedding API, a few tens of euros for the whole corpus (estimate, depends on token count).
- **VRAM:** a good embedding model runs in **8–16 GB**; the generative model for answers depends on the choices (self-hosted 7–14B in 16–24 GB, or API). I compared the self-hosted options for serving in production in the piece on {{ '/en/pillar/models-cost-privacy/' | relative_url }}.
- **Cost per query:** retrieval is cheap (vector query on pgvector, milliseconds). The cost is generation: a few cents per answer with a self-hosted model, a bit more with an EU cloud API.
- **Gold-set cost:** the lawyer's time to build and validate 30–50 cases. It is an investment, not an accessory expense: without a gold set you do not know whether the system works.

The honest comparison: **the dominant cost is not compute, it is the lawyer's time for validation.** And that is right — it is what makes the system reliable instead of dangerous.

## When NOT to do this

- **If the volume of contracts is low** (a few dozen, rarely read), a legal RAG is overkill. A well-organised folder and full-text search are enough. Automate when volume and frequency justify it.
- **If you do not have a lawyer available for the gold set and the loop**, do not build it for decision queries. A legal RAG without professional validation is a generator of false certainty.
- **If almost all contracts are terrible-quality scans**, evaluate a digitisation project first: building a RAG on unreliable OCR means building on sand.
- **If the real goal is "automatic legal opinions"**, stop: this is not a chunking problem, it is a boundary you do not cross. The RAG finds and cites; it does not replace legal judgment.
- **If you cannot guarantee sovereign hosting**, rethink the project: contracts are among a company's most sensitive data and they do not go on uncontrolled services.

## Operational checklist before going live

- [ ] **Digital/OCR triage** working and verified on every contract type.
- [ ] **Structural parser** that recognises *articoli* and *commi* on every numbering variant in the sample.
- [ ] **Chunks by *articolo*/*comma***, never by fixed length; no truncated clause in the inspected sample.
- [ ] **Overlap = article heading repeated** in every sub-chunk.
- [ ] **Full metadata:** parties, date, version, signature, *doppia sottoscrizione* 1341, *rinvii*, page, origin.
- [ ] **Two-step retrieval** that follows cross-references.
- [ ] **Constrained prompt** to cite *articolo*/page/version and to say "not found".
- [ ] **Gold set** validated by the lawyer; retrieval above threshold on queries with *rinvii*.
- [ ] **Disclaimer on the role of AI** visible in the interface.
- [ ] **OCR chunks marked** as "verify against the original".
- [ ] **Sovereign hosting** (self-hosted / EU), contracts never on uncontrolled services.
- [ ] **Complete retrieval logs:** query, retrieved chunks, *rinvii* not followed, version.

## The verdict

**Chunking Italian contracts for RAG** is the point where you decide whether you are building a useful tool or a machine for false certainty. The 500-token splitter is convenient, free and wrong: it cuts clauses in half, separates *rinvii* from their targets, and produces a system that answers with confidence questions on which it has read only half the text. In a blog that is a nuisance. In a contract it is an economic risk.

The right path is not complicated, it is just *different*: respect the structure. Split by *articolo* and *comma*, not by length. Keep the heading attached to the *comma*. Put the *rinvii* in the metadata and follow them at runtime. Record parties, version, signature and *doppia sottoscrizione*, because in Italy an unsigned *clausola vessatoria* does not hold, and your system has to know that. Evaluate with a lawyer and a gold set, not by feel. And always mark the boundary: **the legal RAG finds and cites, it does not interpret and it does not decide.**

Done this way, it is a tool that saves hours for anyone who has to find the right clause in a hundred contracts. Done with the default splitter, it is an overconfident colleague who has read half a page. The difference is not the model. It is whether you treated the contract as what it is: a graph of norms with *rinvii*, not a blog post to slice into equal pieces.

If you are building a RAG on your contracts and you want it to hold the queries that count — *recesso*, *penale*, *foro*, derogations — without inventing, you can see how I work on [antoniotrento.net]({{ site.main_site }}/biografia/) or write to me from the [contacts]({{ site.main_site }}/contatti/) page. Retrieval engineering, clear boundaries, lawyer in the loop.

## FAQ

### Why can't I just use the default splitter with high overlap?
Because fixed-length overlap does not solve the structural problem: you can still cut a clause in half and separate it from the *rinvio*. The overlap contracts need is targeted — repeat the article heading — not "overlap 200 tokens". And no overlap retrieves a *rinvio* to art. 7 if art. 7 sits ten pages away: for that you need two-step retrieval on the metadata.

### How large should chunks be for a contract?
Do not think in tokens, think in units of meaning. The ideal chunk is **a whole *articolo*** if it sits under a comfortable embedding limit (indicatively ~1500–2000 characters). If an *articolo* is longer, subdivide it by *commi* repeating the heading. Better one "large but complete" chunk than two small chunks that break a clause.

### How do I handle cross-references like "salvo quanto previsto all'art. 7"?
You extract them with a regex at chunking time and store them in the metadata (`rinvii`). At runtime, after retrieving chunks for the query, you take a second step that also retrieves the *articoli* cited in the *rinvii* of the chunks you found. That way when the model reads "salvo quanto previsto all'art. 7", it also has art. 7 in context.

### Can the legal RAG replace a lawyer?
No, and designing it to do so is the most dangerous mistake. It is a retrieval tool: it finds and cites clauses in the uploaded contracts. Interpretation, risk assessment and decisions stay with the professional. The disclaimer on the role of AI goes in the interface, not left to the user's intuition.

### How do I treat *clausole vessatorie*?
The system can *recognise* them by type (exclusive *foro*, limitations of liability, *recesso*, *penali*) and *label* them in the metadata, flagging whether the *doppia sottoscrizione* under art. 1341 c.c. appears or not. But the conclusion on effectiveness is the lawyer's. A RAG that declares "this clause is void" has crossed the boundary: it must say "potentially *vessatoria* clause, double signature not detected, verify".

### Do scanned PDFs work?
They work, but with less reliability. You need self-hosted OCR (for confidentiality), post-OCR normalisation to correct numbers and *articolo* sequences, and origin marking in the metadata. An answer based on OCR text must always be sent back to the scanned original for verification, because OCR can get exactly the numbers and the signatures wrong.

### Which embedding do I use for legal Italian?
A good-quality multilingual embedding model, self-hosted, handles contractual Italian well. What matters more than the model is the chunking: an excellent embedding on a truncated chunk still gives an unreliable result. Fix the structure first, then optimise the embedding. Always evaluate on the gold set, not on generic benchmarks.

### How do I know if my chunking actually works?
With the gold set: 30–50 real questions with answer and citation validated by a lawyer, and two metrics — retrieval (did you retrieve the right *articoli*, *rinvii* included?) and faithfulness (does the answer rest only on the chunks, without inventing?). Look first at the questions with *rinvii* and derogations: if those hold, the chunking is good. Remeasure on every change of splitter, model or prompt.

### Can I index contracts in several languages together?
Yes, with a multilingual embedding and metadata that mark the language. But watch this: the structure (*articoli*/*commi*) and the legal rules change by legal system. The structural parser and the rules on *clausole vessatorie* I described are tuned to Italian. For contracts under other systems you need specific parsers and legal knowledge — do not assume the same rules apply.

### How much does it cost to stand up a legal RAG on our contracts?
As an order of magnitude, 1–3 person-weeks of development (more if you have many scans to OCR), plus compute (contained: one-off embedding, generation at cents per query) and — the dominant line — the lawyer's time to build and validate the gold set and stay in the loop. If contract volume is high and queries are frequent, it pays back quickly in hours saved. If volume is low, you probably do not need it.
