---
lang: en
permalink: /en/blog/pgvector-rag-electronic-invoices/
alt_url: /it/blog/rag-pgvector-fattura-elettronica/
title: "RAG on PostgreSQL with pgvector: query 10,000 Italian e-invoices without Pinecone and without the cloud"
date: 2026-09-19 07:30:00 +0200
author: "Antonio Trento"
description: "A chatbot on invoice PDFs hallucinates amounts. To query your FatturaPA you need a RAG that respects the XML structure: pgvector, hybrid search and citations back to the source file. All self-hosted."
keywords: ["pgvector rag electronic invoice", "postgresql pgvector", "italian documents rag", "fatturaPA xml", "self-hosted vector database"]
image: /assets/images/posts/rag-pgvector-fattura-elettronica.jpg
pillar: rag-documenti
related: [/en/blog/company-pdf-search/, /en/blog/self-hosted-n8n-openai-privacy/]
---

## The problem no "chatbot on PDFs" solves

Take 10,000 electronic invoices, dump them into one of those "upload your PDFs and ask questions" services, and ask "how much VAT (IVA) did I pay supplier Rossi in the second quarter?". The answer comes back confident, well formatted, and **wrong**. Not because the model is stupid, but because a generic RAG on invoice PDFs **hallucinates the numbers by design**: it splits documents into random pieces, mixes the amount from one line with the rate from another, confuses the supplier with the customer, and when you ask for a total it *invents* one by fishing scattered figures. On content where a wrong number is an accounting error, that is unacceptable.

A RAG (retrieval-augmented generation) on Italian electronic invoices is not "generic document Q&A": it is a **vertical Italian** problem with its own rules — the XML structure of FatturaPA, the VAT number, the VAT summaries by rate, the distinction between cedente and cessionario. Ignoring that structure is why generic chatbots fail. In this article we build a RAG that respects it, fully self-hosted: **pgvector** on PostgreSQL as the vector database (zero Pinecone, zero cloud), chunking driven by the FatturaPA structure, hybrid search BM25 + vector, and — the non-negotiable part — **mandatory citations**: every amount the system reports must point to the file and the exact spot it came from. With the SQL schema, the ingest snippet, and the table of typical errors. Because on an invoice, "more or less" does not exist.

## Why a chatbot on invoice PDFs hallucinates the numbers

Before we build, let's understand why the naive way fails — so you don't do it again. Generic RAG does three things, and all three are wrong for invoices.

**One: it splits the document into fixed-length chunks.** It takes the text extracted from the PDF and cuts it every N characters (or N tokens), with no idea what it is cutting. The result is that the total amount lands in one chunk, the VAT rate in another, the supplier name in a third. When the model then has to answer, it retrieves disconnected chunks and stitches them **its own way** — and that is where the hallucination is born: it stitches the amount from one invoice to the rate from another because they ended up close in vector space.

**Two: it treats numbers as semantic text.** Embeddings are excellent with meaning ("invoice", "supplier", "payment") and **terrible with exact numbers.** In embedding space, "€1,220.00" and "€1,202.00" are almost identical — but in accounting they are two different things. Searching for an exact amount with vector similarity alone is like looking for a precise address by asking for "a street that *sounds* like that".

**Three: it loses the structure.** An invoice is not prose: it is a structured document with a header, line items and VAT summaries, where *the position of a number determines its meaning*. "22" in the rate column is a percentage; "22" in the amount column is euros. The flattened PDF loses that structure, and with it the meaning.

The practical consequence is the one of the [chatbot that promises everything and produces unreliable output]({{ '/en/blog/llm-product-vs-chatbot/' | relative_url }}): it looks like it works in the demo, and it gets the amounts wrong in production. The fix is not "a better model": it is **respecting the document structure** from ingest onwards. And for Italian invoices, the structure is FatturaPA XML.

## Anatomy of a FatturaPA: what to chunk and what never to split

The luck, with Italian electronic invoices, is that **you already have the structured XML** — the file that goes through the SdI (Sistema di Interscambio). You don't have to extract text from a PDF hoping to guess the fields: the structure is explicit. The sections that matter:

- **The header** (`FatturaElettronicaHeader`): who issues and who receives. This is where **CedentePrestatore** (the supplier, who issues) and **CessionarioCommittente** (the customer, who receives) live, each with a name and a **VAT number / codice fiscale**. Confusing these two is the classic error: "supplier Rossi" is not "customer Rossi".
- **The general data** (`DatiGeneraliDocumento`): invoice number, date, document type, and **ImportoTotaleDocumento**. These are the key metadata for filtering and citing.
- **The line items** (`DettaglioLinee`): each line with description, quantity, unit price, VAT rate. These are the real items on the invoice.
- **The VAT summaries** (`DatiRiepilogo`): for each rate, the taxable amount and the tax. **This is the section generic RAG destroys**, and it is the one fiscal questions come from ("how much VAT at 22%?").

The golden rule of chunking is: **chunk by structural semantic unit, never by fixed length.** In practice:

- **Never split** a line item in half, nor a VAT summary. They are atomic units: description + quantity + price + rate must stay together, or the meaning is lost.
- **One chunk for the header** (supplier + customer + number + date + total): it is the document's "business card", useful for almost every question.
- **One chunk per line** item, with a reference to the document.
- **One chunk per VAT summary row** (rate, taxable amount, tax).

And — crucial detail — **beyond the embeddings, keep the numbers as real data** in typed database columns (the total amount as `NUMERIC`, the date as `DATE`, the rate as a number). That way "exact" questions (totals, sums, filters by period or rate) are answered with **real SQL on the numbers**, not with vector similarity that lies about numbers. RAG is there to *find the document and the context*; the sums are done by the database. This dual nature — vectors for meaning, typed columns for numbers — is the whole secret of a RAG on invoices that does not hallucinate.

## The Postgres schema: documents, chunks, embeddings and Italian tsvector

Here is the starting schema. We use `pgvector` for embeddings and Postgres native full-text search (with an **Italian** dictionary) for the lexical part. Everything in one database — no separate vector store to keep in sync.

```sql
CREATE EXTENSION IF NOT EXISTS vector;

-- One record per invoice, with NUMBERS as real data (not text only)
CREATE TABLE documenti (
  id             BIGSERIAL PRIMARY KEY,
  file_path      TEXT NOT NULL,
  tipo           TEXT,                 -- 'fatturaPA_xml' | 'pdf_scansionato'
  numero         TEXT,
  data_doc       DATE,
  fornitore      TEXT,
  piva_fornitore TEXT,
  cliente        TEXT,
  piva_cliente   TEXT,
  importo_totale NUMERIC(14,2),
  hash           TEXT UNIQUE,          -- for dedup (see ingest)
  created_at     TIMESTAMPTZ DEFAULT now()
);

-- The chunks, one per structural unit, pointing at the source
CREATE TABLE chunks (
  id           BIGSERIAL PRIMARY KEY,
  documento_id BIGINT REFERENCES documenti(id) ON DELETE CASCADE,
  sezione      TEXT,                   -- 'testata' | 'linea' | 'riepilogo_iva'
  xpath        TEXT,                   -- THE pointer to the source (citation)
  contenuto    TEXT,                   -- readable text of the chunk
  imponibile   NUMERIC(14,2),          -- populated where it makes sense
  imposta      NUMERIC(14,2),
  aliquota     NUMERIC(5,2),
  tsv          tsvector,               -- Italian full-text
  embedding    vector(768)             -- dimension of your embedding model
);

-- Vector index (HNSW) for cosine similarity
CREATE INDEX idx_chunks_embedding ON chunks
  USING hnsw (embedding vector_cosine_ops);

-- Full-text index
CREATE INDEX idx_chunks_tsv ON chunks USING gin (tsv);

-- Populate the tsvector in Italian (trigger or at insert time)
UPDATE chunks SET tsv = to_tsvector('italian', contenuto);
```

Three choices that matter:

- **The numbers live in typed columns** (`importo_totale`, `imponibile`, `imposta`, `aliquota`), not only inside the chunk text. That is what lets you answer totals with `SUM()` instead of with the AI.
- **`to_tsvector('italian', ...)`**: the Italian dictionary handles stemming ("fattura/fatture", "pagato/pagamento") for the lexical part. Essential on Italian content.
- **`xpath`**: every chunk knows *where* it comes from in the XML file. It is the basis of the mandatory citations we talk about later — without it, you cannot prove an amount.

## The ingest pipeline: XML from the SdI, scanned PDFs, duplicates, revisions

Ingest is where you win or lose, because "garbage in, garbage out" counts twice on invoices. Here is the Python snippet that extracts structured data from a FatturaPA XML. A warning up front, because it is trap number one: **the FatturaPA namespace varies** (sometimes there is a prefix, sometimes it has been stripped, sometimes the version changes). Using xpath with fixed namespaces breaks on half of the real files. The robust solution is `local-name()`:

```python
from lxml import etree
from decimal import Decimal
import hashlib

def _t(nodes):
    return nodes[0].text.strip() if nodes and nodes[0].text else None

def parse_fattura(path: str) -> dict:
    tree = etree.parse(path)
    # local-name() ignores namespaces, which vary in real FatturaPA files
    def field(tag, parent=""):
        expr = f"//*[local-name()='{parent}']//*[local-name()='{tag}']" if parent \
               else f"//*[local-name()='{tag}']"
        return _t(tree.xpath(expr))

    doc = {
        "numero":         field("Numero", "DatiGeneraliDocumento"),
        "data_doc":       field("Data", "DatiGeneraliDocumento"),
        "importo_totale": field("ImportoTotaleDocumento", "DatiGeneraliDocumento"),
        "fornitore":      field("Denominazione", "CedentePrestatore")
                          or field("Cognome", "CedentePrestatore"),
        "piva_fornitore": field("IdCodice", "CedentePrestatore"),
        "cliente":        field("Denominazione", "CessionarioCommittente")
                          or field("Cognome", "CessionarioCommittente"),
    }
    # content hash for dedup (same file uploaded twice)
    doc["hash"] = hashlib.sha256(etree.tostring(tree.getroot())).hexdigest()
    return doc
```

And the real cases ingest **must** handle, or they bite you in production:

1. **Scanned PDFs.** Not every invoice arrives as clean XML: the old ones, the foreign ones, the ones attached by hand are PDFs, maybe scans. For these you need OCR (local, in a sovereign setup) to extract the text, knowing that quality drops and citations become "page X" instead of "xpath". Keep them in a distinct `tipo = 'pdf_scansionato'`, because they are less reliable.
2. **Duplicates.** The same invoice loaded twice (from the SdI and by hand, or in two folders). The unique `hash` in the schema blocks them: if the hash already exists, you skip. Without dedup, totals double — a serious accounting error.
3. **Revisions and credit notes.** A corrected invoice, or a credit note that reverses it. They are not duplicates: they are linked documents that change the picture. They have to be tracked as such (a reference to the original document), or the sums are wrong.

The ingest steps, numbered:

1. **Detect the type** (FatturaPA XML vs PDF) and route accordingly.
2. **Extract the structured fields** (header, lines, VAT summaries) — with `local-name()` for XML, OCR for PDFs.
3. **Deduplicate** on the hash: if it exists, discard or update.
4. **Write the `documenti` record** with the typed numbers.
5. **Generate the chunks** by structural unit (header, each line, each VAT summary) with their `xpath`.
6. **Compute the embeddings** of every chunk (with a local model — see costs) and populate `tsv`.
7. **Reconciliation check**: the sum of the lines + VAT must match the declared total. If it doesn't, flag the document instead of indexing it blindly.

That step 7 is what distinguishes professional ingest: **you check that the numbers add up at the door**, so you know the indexed data is consistent.

## Hybrid search: BM25 + cosine, and how to weight the two scores

This is where you see why vector-only fails and hybrid wins. We have two ways to search, and you need both:

- **Vector search (cosine on embeddings)**: good at finding by *meaning*. "How much did I spend on transport?" finds chunks that talk about shipping, logistics, courier, even without the exact word.
- **Lexical search (BM25 / full-text)**: good at finding by *exact word*. A VAT number, an invoice number, the precise name of a supplier — where exact match counts, full-text beats vector.

The power is in **combining them** (hybrid search), weighting the two scores. Here is a query that joins cosine and BM25 in Postgres:

```sql
-- $1 = question embedding (vector), $2 = question text
WITH vettoriale AS (
  SELECT id, 1 - (embedding <=> $1) AS score_vec
  FROM chunks
  ORDER BY embedding <=> $1
  LIMIT 50
),
lessicale AS (
  SELECT id, ts_rank(tsv, plainto_tsquery('italian', $2)) AS score_bm25
  FROM chunks
  WHERE tsv @@ plainto_tsquery('italian', $2)
  LIMIT 50
)
SELECT c.id, c.contenuto, c.xpath, c.documento_id,
       COALESCE(v.score_vec, 0)  * 0.6 +
       COALESCE(l.score_bm25, 0) * 0.4 AS score_finale
FROM chunks c
LEFT JOIN vettoriale v ON v.id = c.id
LEFT JOIN lessicale  l ON l.id = c.id
WHERE v.id IS NOT NULL OR l.id IS NOT NULL
ORDER BY score_finale DESC
LIMIT 10;
```

How do you weight the two scores (the `0.6` / `0.4` above)? It depends on the question, and it is a choice to tune on your data:

- For **precise factual** questions (an invoice number, a VAT number), raise the lexical weight: the exact word counts more than the meaning.
- For **conceptual** questions ("marketing spend", "consulting"), raise the vector weight: meaning counts more than the exact word.
- A reasonable starting point is 60% vector / 40% lexical, then you adjust by looking at results on the evaluation set (later).

But remember the golden rule: **for totals and sums, use neither — use SQL on the typed numbers.** Hybrid search finds the *right documents*; when the question is "how much in total", the answer is a `SUM(importo_totale)` with the right filters, not a stitch of chunks. That is the difference between a system that *estimates* and one that *calculates*.

## Mandatory citations: every amount points to the file and the exact spot

This is the non-negotiable rule on an invoice RAG, and it is what makes it usable in a context where numbers have consequences: **every figure the system reports must come with a citation of the source** — which file, and which point inside the file (the `xpath` for XML, the page for PDFs).

Why it is mandatory, not a flourish:

- **Verifiability.** Whoever reads the answer ("you paid €12,200 of VAT at 22% to supplier Rossi in Q2") must be able to click and see *which invoices* that number comes from. Without that, it is a figure you have to take on trust from a system that sometimes hallucinates — unacceptable in accounting.
- **Debug.** When a number is wrong (and it will happen), the citation tells you *where* the error is: a badly parsed document, a duplicate, an unlinked credit note. Without a citation, you search in the dark.
- **Trust.** A system that cites sources tells the user "go ahead and check": it is the opposite of a black box. It is the same discipline as [searching company documents that answers by citing the source instead of inventing]({{ '/en/blog/company-pdf-search/' | relative_url }}).

In practice: every chunk carries its `xpath` (or page), and the system's final answer is never "the total is X", but "the total is X, from: invoice no. 123 of 12/04 (`//DatiRiepilogo[1]/Imposta`), invoice no. 130...". The language model composes the sentence; **the numbers and the sources come from the database**, not from its imagination. If an invoice RAG does not give you citations, it is not ready for production: it is a demo.

## A complete example: from question to cited answer

Let's put the pieces together on a real question: *"How much VAT at 22% did I pay supplier ACME in the second quarter?"*. Here is how the system answers without hallucinating, step by step.

**Step 1 — understand the question.** The system (or a thin layer on top) recognises that this is an **aggregated question on numbers**, with three filters: supplier = ACME, rate = 22%, period = Q2. This is *not* a vector-similarity case: it is a SQL-on-typed-data case.

**Step 2 — resolve the supplier.** "ACME" has to be hooked to the real supplier. Here hybrid search helps: full-text finds the supplier by exact name, and you retrieve their VAT number so you don't confuse them with a customer of the same name. The resolved supplier becomes a `piva_fornitore = '...'` filter.

**Step 3 — calculate, don't estimate.** The answer comes from SQL on the numbers, not from stitching chunks:

```sql
SELECT d.numero, d.data_doc, c.aliquota, c.imposta, c.xpath, d.file_path
FROM chunks c
JOIN documenti d ON d.id = c.documento_id
WHERE c.sezione = 'riepilogo_iva'
  AND c.aliquota = 22.00
  AND d.piva_fornitore = $1
  AND d.data_doc BETWEEN '2026-04-01' AND '2026-06-30';
-- the total:
-- SELECT SUM(imposta) FROM (...the same query...) t;
```

**Step 4 — compose the answer with citations.** The language model takes the query result and writes a readable sentence — but the numbers and the sources come from the returned rows, not from its head: *"You paid €3,410.00 of VAT at 22% to ACME in Q2, from 4 invoices: no. 123 of 12/04 (tax €880.00), no. 130 of 03/05 …"*, each with the link to the file and to the `xpath` of the VAT summary.

Note what **did not** happen: no text chunk was "interpreted" to extract an amount, no figure was brought semantically close to another, no total was guessed. Retrieval found the *context* (which supplier, which documents), SQL did the *sum*, and citations make everything verifiable. It is this triple pass — find, calculate, cite — that separates a reliable invoice RAG from a chatbot that fires numbers.

## What breaks in production: the error table

The two errors you will see most, how you recognise them, and how you close them:

| Symptom | Typical cause | How you recognise it | Fix |
|---|---|---|---|
| **Wrong amount** | Fixed-length chunks that split lines/summaries; numbers searched with the vector | The answer cites figures that, added up, don't match the document total | Chunk by structural unit; totals via SQL on typed numbers, not via embeddings |
| **Supplier confused with customer** | Badly parsed header: Cedente and Cessionario mixed | "Supplier Rossi" when Rossi is the customer (cessionario) | Extract Cedente vs Cessionario explicitly; dedicated tests |
| **Doubled totals** | Duplicates not deduplicated (same file twice) | Sums are twice the real figure on some suppliers | Unique hash at ingest; block duplicates |
| **Credit note ignored** | Reversal document not linked to the original | A total higher than due because the reversal is not subtracted | Track credit notes and revisions with a reference to the original |
| **"Almost right" number** | Vector search on amounts (€1,220 ≈ €1,202) | Plausible but inexact figures | Never search amounts with the vector; exact match or SQL |
| **Wrong period question** | Date not typed, filtered as text | "In Q2" also returns documents from other quarters | `data_doc` as `DATE`, SQL filters on the period |

The thread through all these errors is the same: **they happen when you treat the invoice as prose instead of as structured data.** Respect the structure at ingest and half of these problems never start.

## Evaluation: the 50 gold questions

You cannot improve what you don't measure, and on an invoice RAG "it seems to work" is not enough — an error is an accounting error. You need an **evaluation set**: a set of questions whose exact answer you know (calculated by hand or with verified queries), to re-run on every change to the system.

Build ~50 "gold questions" that cover the real types:

- **Document totals**: "what is the total amount of invoice no. 123?" → known exact answer.
- **Sums by supplier/period**: "how much did I pay supplier X in Q2?" → verified `SUM`.
- **Rates and VAT**: "how much VAT at 22% in total in March?" → verified on the summaries.
- **Due dates and dates**: "which invoices fall due in November?".
- **Trap questions**: "how much did Rossi invoice me?" when Rossi is a customer and not a supplier — to check it doesn't mix up the roles.

For every question you measure two things: **is the answer exact?** and **does the citation point to the right source?**. A system that gives the right number but cites the wrong invoice is still broken (you got lucky). This set becomes your regression test: you change the chunking, the embedding model, the hybrid-search weights — and you re-run the 50 questions to see if it got better or worse. It is the only honest way to know whether the system is ready, instead of trusting a few lucky demos.

## Costs: VRAM versus embedding APIs, and when 8 GB is enough

The bit that often scares people: "but for local embeddings do I need a monstrous GPU?". No. Embeddings are much lighter than text generation. Orders of magnitude, as stated estimates.

| Item | Order of magnitude | Notes |
|---|---|---|
| **Local embedding model** | runs in **~2–6 GB VRAM** (or even on CPU) | Embedding models are small. An **8 GB** GPU is more than enough to index and query. |
| **Indexing 10,000 invoices** | minutes–a few hours, one-off | Compute cost negligible; it is a batch you do once and then update incrementally. |
| **Postgres + pgvector** | runs on a **modest VPS** | No paid vector service: the vector DB is inside the Postgres you would already have. |
| **Cloud embedding APIs (comparison)** | per token, + the data leaves | Convenient but sends every chunk to the vendor: on invoices with fiscal data, it is the [open-fence problem]({{ '/en/blog/self-hosted-n8n-openai-privacy/' | relative_url }}). |
| **Pinecone / managed vector DB** | monthly fee + lock-in | Useless: pgvector does the same job inside the DB you already run. |

The economic verdict: for RAG on invoices, **local is not only safer, it is often cheaper too** — because embeddings are light (8 GB is enough), you already have Postgres, and you skip both the fee of a managed vector DB and the per-token cost of embedding APIs. The cloud here doesn't even have the "it's more powerful" advantage: for embeddings, local models are excellent. Sending invoice data — which contains VAT numbers, amounts, supplier relationships — to an external API, when you can do it all in-house with 8 GB, is giving data away without even saving money.

## When NOT to do it

Honesty, as always. You **don't need this system if:**

- **You have few invoices and simple questions.** If you handle dozens of invoices, not thousands, and your questions are "how much did I invoice this month", your gestionale or a well-made spreadsheet already answers. Building a RAG would be over-engineering.
- **Your gestionale already answers.** Many management systems report on invoices, VAT and due dates. If the reports you need already exist there, use them. RAG is for *unforeseen*, exploratory questions, in natural language, on large and heterogeneous volumes.
- **You have nobody to maintain it.** Like any self-hosted stack, it has to be updated (Postgres, pgvector, the embedding model) and monitored. Without maintenance, it degrades.
- **You need official totals for the tax office.** Careful: this is a *query and exploration* tool, not the source of accounting truth. Official numbers come from the books and the accountant. RAG helps you *find and understand*, it does not replace the balance sheet.

RAG on invoices shines on **large volumes, exploratory questions, and the need to go back to the source document**. Outside that, the gestionale is often enough — and saying so is part of the job.

## Operational checklist before production

- [ ] Chunking **by structural unit** (header, lines, VAT summaries), never by fixed length.
- [ ] The **numbers** live in typed columns (`NUMERIC`, `DATE`), not only in the chunk text.
- [ ] **Totals and sums** are answered with SQL, not with vector similarity.
- [ ] Ingest uses **`local-name()`** to survive the variable FatturaPA namespaces.
- [ ] **Dedup** is on (unique hash); duplicates blocked.
- [ ] **Credit notes and revisions** linked to the original documents.
- [ ] **Hybrid search** BM25 + cosine, with weights tuned on your data.
- [ ] Every answer carries the **citation** (file + xpath/page); numbers come from the DB.
- [ ] **Reconciliation check** at ingest (lines + VAT = total).
- [ ] Set of **50 gold questions** as a regression test.
- [ ] **Local** embeddings (8 GB is enough); no invoice data to external APIs.

## The verdict: structure first, model later

If a chatbot on your invoice PDFs hallucinates the numbers, it is not the model's fault: you are using it against the nature of the document. An electronic invoice is **structured data** — FatturaPA XML, with header, lines and VAT summaries — and a RAG that respects it starts from there: chunking by semantic unit, numbers in typed columns, totals via SQL, hybrid search to find, and mandatory citations to prove every figure. All inside PostgreSQL with pgvector, without Pinecone and without sending fiscal data to a cloud — because embeddings fit in 8 GB and you already have Postgres. The challenge of a RAG on electronic invoices is not "which vector database": it is **respecting the Italian structure of the document**, and that is exactly what generic systems do not do.

This is a brick of the [guide to RAG and documents in-house]({{ '/en/pillar/rag-documents/' | relative_url }}), where your documents become queryable without leaving your fence. If you want to see how it looks on *your* documents and *your* invoices, start from [who I am and how I work]({{ site.main_site }}/biografia/) or drop me a line at [contacts]({{ site.main_site }}/contatti/).

## FAQ

**1. Why don't I use Pinecone or a managed vector DB?**
Because pgvector does the same job inside the PostgreSQL you probably already have: one database to run, no fee, no lock-in, and the data doesn't leave. For invoices — which contain fiscal data — self-hosted is safer and often cheaper. A managed vector DB here is extra complexity and cost with no real advantage.

**2. Why does generic RAG get the amounts wrong?**
Because it splits invoices into fixed-length chunks (mixing amounts and rates from different documents), treats numbers as semantic text (where 1,220 and 1,202 are "almost equal"), and loses the structure in which the position of a number determines its meaning. You need structural chunking and typed numbers.

**3. Should I start from the XML or from the PDF?**
From FatturaPA XML, whenever you have it: the structure is explicit and you don't have to guess the fields. PDFs (old invoices, foreign, scanned) are handled separately with OCR, knowing they are less reliable and citations become "page" instead of xpath.

**4. How do I avoid confusing supplier and customer?**
By extracting **CedentePrestatore** (supplier, who issues) and **CessionarioCommittente** (customer, who receives) from the header explicitly, with dedicated tests that check the roles don't flip. It is the classic error and it has to be guarded with trap questions in the evaluation set.

**5. Why do I need hybrid search and not embeddings alone?**
Because embeddings find by meaning but fail on exact matches (VAT number, invoice number, precise name). Full-text (BM25) finds by exact word. Combining them, weighting the scores, covers both types of question. And for totals you use neither: you use SQL on the numbers.

**6. How do I trust the numbers it gives me?**
With mandatory citations: every figure points to the file and the exact spot (xpath or page). The numbers come from the database, not from the language model, which only composes the sentence. If you cannot verify which invoices a total comes from, the system is not ready for production.

**7. How much GPU do I actually need?**
Little: embedding models run in ~2–6 GB VRAM (or on CPU). An 8 GB card is more than enough to index and query thousands of invoices. Generating the answer text is more demanding, but for that you can use a small local model or handle the phrasing with simple logic on top of the data.

**8. How do I handle duplicates and credit notes?**
Duplicates with a unique content hash at ingest: if it already exists, you discard it, otherwise totals double. Credit notes and revisions are not duplicates: they are linked documents that reverse or correct, and they have to be tracked with a reference to the original, or the sums come out higher than reality.

**9. Can I query it in natural language like a chatbot?**
Yes, but with the right discipline: the natural-language question drives retrieval (hybrid search) and the filters (period, supplier, rate), but the final numbers are calculated with SQL on the typed data and presented with citations. The "chatbot" is the interface; the engine that answers does not hallucinate because it does not invent figures.

**10. Is it GDPR-compliant to keep invoices in this system?**
The system runs entirely in your house (Postgres + local embeddings), so the data doesn't leave — which is the starting point for compliance, much better than sending it to a cloud API. You still have to handle access, retention and the rules of your context (with your advisor), but the fence is closed: it is the same principle of the sovereign stack this whole guide sits on.
