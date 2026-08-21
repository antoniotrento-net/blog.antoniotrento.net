---
lang: it
permalink: /it/blog/rag-pgvector-fattura-elettronica/
alt_url: /en/blog/pgvector-rag-electronic-invoices/
title: "RAG su PostgreSQL con pgvector: interrogare 10.000 fatture elettroniche italiane senza Pinecone e senza cloud"
date: 2026-09-19 07:30:00 +0200
author: "Antonio Trento"
description: "Un chatbot sui PDF delle fatture allucina gli importi. Per interrogare le tue FatturaPA serve un RAG che rispetta la struttura XML: pgvector, hybrid search e citazioni al file sorgente. Tutto self-hosted."
keywords: ["rag pgvector fattura elettronica", "postgresql pgvector", "rag documenti italiani", "fatturaPA xml", "vector database self-hosted"]
image: /assets/images/posts/rag-pgvector-fattura-elettronica.jpg
pillar: rag-documenti
related: [/it/blog/ricerca-documenti-aziendali-pdf/, /it/blog/n8n-self-hosted-openai-privacy/]
---

## Il problema che nessun "chatbot sui PDF" risolve

Prendi 10.000 fatture elettroniche, le butti in uno di quei servizi "carica i tuoi PDF e fai domande", e chiedi "quanto ho pagato di IVA al fornitore Rossi nel secondo trimestre?". La risposta arriva sicura, formattata bene, e **sbagliata**. Non perché il modello sia scemo, ma perché un RAG generico sui PDF delle fatture **allucina i numeri** per costruzione: spezza i documenti in pezzi a caso, mescola l'importo di una riga con l'aliquota di un'altra, confonde il fornitore col cliente, e quando gli chiedi un totale te lo *inventa* pescando cifre sparse. Su un contenuto dove un numero sbagliato è un errore contabile, questo è inaccettabile.

Un RAG (retrieval-augmented generation) su fatture elettroniche italiane non è "document Q&A generico": è un problema **verticale italiano** che ha le sue regole — la struttura XML della FatturaPA, la partita IVA, i riepiloghi IVA per aliquota, la distinzione tra cedente e cessionario. Ignorare questa struttura è la ragione per cui i chatbot generici falliscono. In questo articolo costruiamo un RAG che la rispetta, tutto self-hosted: **pgvector** su PostgreSQL come vector database (zero Pinecone, zero cloud), chunking guidato dalla struttura FatturaPA, hybrid search BM25 + vettoriale, e — la parte non negoziabile — **citazioni obbligatorie**: ogni importo che il sistema riporta deve puntare al file e al punto esatto da cui viene. Con lo schema SQL, lo snippet di ingest, e la tabella degli errori tipici. Perché su una fattura, "più o meno" non esiste.

## Perché un chatbot sui PDF delle fatture allucina i numeri

Prima di costruire, capiamo perché il modo ingenuo fallisce — così non lo rifai. Il RAG generico fa tre cose, e tutte e tre sono sbagliate per le fatture.

**Uno: spezza il documento in chunk di lunghezza fissa.** Prende il testo estratto dal PDF e lo taglia ogni N caratteri (o N token), senza sapere cosa sta tagliando. Il risultato è che l'importo totale finisce in un chunk, l'aliquota IVA in un altro, il nome del fornitore in un terzo. Quando poi il modello deve rispondere, recupera chunk scollegati e li ricuce **a modo suo** — ed è lì che nasce l'allucinazione: cuce l'importo di una fattura con l'aliquota di un'altra perché sono finiti vicini nello spazio vettoriale.

**Due: tratta i numeri come testo semantico.** Gli embedding sono bravissimi col significato ("fattura", "fornitore", "pagamento") e **pessimi con i numeri esatti.** Nello spazio degli embedding, "1.220,00 €" e "1.202,00 €" sono quasi identici — ma contabilmente sono due cose diverse. Cercare un importo esatto con la sola similarità vettoriale è come cercare un indirizzo preciso chiedendo "una via che *suona* così".

**Tre: perde la struttura.** Una fattura non è prosa: è un documento strutturato con testata, righe di dettaglio e riepiloghi IVA, dove *la posizione di un numero ne determina il significato*. "22" nella colonna aliquota è una percentuale; "22" nella colonna importo sono euro. Il PDF appiattito perde questa struttura, e con essa il significato.

La conseguenza pratica è quella del [chatbot che promette tutto e produce output inaffidabili]({{ '/it/blog/prodotto-llm-vs-chatbot/' | relative_url }}): sembra funzionare nella demo, e sbaglia gli importi in produzione. La soluzione non è "un modello migliore": è **rispettare la struttura del documento** fin dall'ingest. E per le fatture italiane, la struttura è l'XML della FatturaPA.

## Anatomia di una FatturaPA: cosa chunkare e cosa non spezzare mai

La fortuna, con le fatture elettroniche italiane, è che **hai già l'XML strutturato** — il file che passa dallo SdI (Sistema di Interscambio). Non devi estrarre il testo da un PDF sperando di indovinare i campi: la struttura è esplicita. Le sezioni che contano:

- **La testata** (`FatturaElettronicaHeader`): chi emette e chi riceve. Qui vivono il **CedentePrestatore** (il fornitore, chi emette) e il **CessionarioCommittente** (il cliente, chi riceve), ciascuno con denominazione e **partita IVA/codice fiscale**. Confondere questi due è l'errore classico: "il fornitore Rossi" non è "il cliente Rossi".
- **I dati generali** (`DatiGeneraliDocumento`): numero fattura, data, tipo documento, e l'**ImportoTotaleDocumento**. Sono i metadati chiave per filtrare e citare.
- **Le righe di dettaglio** (`DettaglioLinee`): ogni riga con descrizione, quantità, prezzo unitario, aliquota IVA. Sono le voci vere della fattura.
- **I riepiloghi IVA** (`DatiRiepilogo`): per ogni aliquota, l'imponibile e l'imposta. **Questa è la sezione che il RAG generico distrugge**, ed è quella da cui vengono le domande fiscali ("quanto IVA al 22%?").

La regola d'oro del chunking è: **chunk per unità semantica strutturale, mai a lunghezza fissa.** In pratica:

- **Non spezzare mai** una riga di dettaglio a metà, né un riepilogo IVA. Sono unità atomiche: descrizione + quantità + prezzo + aliquota devono stare insieme, o il significato si perde.
- **Un chunk per la testata** (fornitore + cliente + numero + data + totale): è il "biglietto da visita" del documento, utile a quasi ogni domanda.
- **Un chunk per ogni riga** di dettaglio, con il riferimento al documento.
- **Un chunk per ogni riga di riepilogo IVA** (aliquota, imponibile, imposta).

E — dettaglio cruciale — **oltre agli embedding, tieni i numeri come dati veri** in colonne tipizzate del database (l'importo totale come `NUMERIC`, la data come `DATE`, l'aliquota come numero). Così le domande "esatte" (totali, somme, filtri per periodo o aliquota) si rispondono con **SQL vero sui numeri**, non con la similarità vettoriale che sui numeri mente. Il RAG serve a *trovare il documento e il contesto*; i conti li fa il database. Questa doppia natura — vettori per il significato, colonne tipizzate per i numeri — è tutto il segreto di un RAG sulle fatture che non allucina.

## Lo schema Postgres: documenti, chunks, embedding e tsvector italiano

Ecco lo schema di partenza. Usiamo `pgvector` per gli embedding e il full-text search nativo di Postgres (con dizionario **italiano**) per la parte lessicale. Tutto in un solo database — niente vector store separato da tenere allineato.

```sql
CREATE EXTENSION IF NOT EXISTS vector;

-- Un record per fattura, con i NUMERI come dati veri (non solo testo)
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
  hash           TEXT UNIQUE,          -- per deduplica (vedi ingest)
  created_at     TIMESTAMPTZ DEFAULT now()
);

-- I chunk, uno per unità strutturale, con puntamento alla fonte
CREATE TABLE chunks (
  id           BIGSERIAL PRIMARY KEY,
  documento_id BIGINT REFERENCES documenti(id) ON DELETE CASCADE,
  sezione      TEXT,                   -- 'testata' | 'linea' | 'riepilogo_iva'
  xpath        TEXT,                   -- IL puntamento alla fonte (citazione)
  contenuto    TEXT,                   -- testo leggibile del chunk
  imponibile   NUMERIC(14,2),          -- valorizzato dove ha senso
  imposta      NUMERIC(14,2),
  aliquota     NUMERIC(5,2),
  tsv          tsvector,               -- full-text italiano
  embedding    vector(768)             -- dimensione del tuo modello di embedding
);

-- Indice vettoriale (HNSW) per la similarità coseno
CREATE INDEX idx_chunks_embedding ON chunks
  USING hnsw (embedding vector_cosine_ops);

-- Indice full-text
CREATE INDEX idx_chunks_tsv ON chunks USING gin (tsv);

-- Popola il tsvector in italiano (trigger o in fase di insert)
UPDATE chunks SET tsv = to_tsvector('italian', contenuto);
```

Tre scelte che contano:

- **I numeri vivono in colonne tipizzate** (`importo_totale`, `imponibile`, `imposta`, `aliquota`), non solo dentro il testo del chunk. È ciò che permette di rispondere ai totali con `SUM()` invece che con l'AI.
- **`to_tsvector('italian', ...)`**: il dizionario italiano gestisce lo stemming ("fattura/fatture", "pagato/pagamento") per la parte lessicale. Fondamentale su contenuti in italiano.
- **`xpath`**: ogni chunk sa da *dove* viene nel file XML. È la base delle citazioni obbligatorie di cui parliamo più avanti — senza, non puoi provare un importo.

## La pipeline di ingest: XML dallo SdI, PDF scansionati, duplicati, revisioni

L'ingest è dove si vince o si perde, perché "spazzatura dentro, spazzatura fuori" vale doppio sulle fatture. Vediamo lo snippet Python che estrae i dati strutturati da una FatturaPA XML. Un avvertimento subito, perché è la trappola numero uno: **il namespace della FatturaPA varia** (a volte c'è il prefisso, a volte è stato strippato, a volte cambia versione). Usare xpath con namespace fissi rompe su metà dei file reali. La soluzione robusta è `local-name()`:

```python
from lxml import etree
from decimal import Decimal
import hashlib

def _t(nodes):
    return nodes[0].text.strip() if nodes and nodes[0].text else None

def parse_fattura(path: str) -> dict:
    tree = etree.parse(path)
    # local-name() ignora i namespace, che nelle FatturaPA reali variano
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
    # hash del contenuto per la deduplica (stesso file caricato due volte)
    doc["hash"] = hashlib.sha256(etree.tostring(tree.getroot())).hexdigest()
    return doc
```

E i casi reali che l'ingest **deve** gestire, o ti mordono in produzione:

1. **I PDF scansionati.** Non tutte le fatture arrivano come XML pulito: le vecchie, quelle estere, quelle allegate a mano sono PDF, magari scansioni. Per questi serve un OCR (locale, in ottica sovrana) per estrarre il testo, con la consapevolezza che la qualità cala e le citazioni diventano "pagina X" invece di "xpath". Tienili in una `tipo = 'pdf_scansionato'` distinta, perché sono meno affidabili.
2. **I duplicati.** La stessa fattura caricata due volte (dallo SdI e a mano, o in due cartelle). L'`hash` unico nello schema li blocca: se l'hash esiste già, salti. Senza deduplica, i totali raddoppiano — un errore contabile grave.
3. **Le revisioni e le note di credito.** Una fattura corretta, o una nota di credito che la storna. Non sono duplicati: sono documenti collegati che modificano il quadro. Vanno tracciati come tali (un riferimento al documento originale), o le somme sbagliano.

L'ordine dei passi dell'ingest, numerato:

1. **Rileva il tipo** (XML FatturaPA vs PDF) e instrada di conseguenza.
2. **Estrai i campi strutturati** (testata, righe, riepiloghi IVA) — con `local-name()` per l'XML, OCR per i PDF.
3. **Deduplica** sull'hash: se esiste, scarta o aggiorna.
4. **Scrivi il record `documenti`** con i numeri tipizzati.
5. **Genera i chunk** per unità strutturale (testata, ogni riga, ogni riepilogo IVA) con il loro `xpath`.
6. **Calcola gli embedding** di ogni chunk (con un modello locale — vedi costi) e popola `tsv`.
7. **Verifica di quadratura**: la somma delle righe + IVA deve tornare col totale dichiarato. Se non torna, segnala il documento invece di indicizzarlo a testa bassa.

Quel passo 7 è quello che distingue un ingest professionale: **controlli che i conti tornino all'ingresso**, così sai che i dati indicizzati sono coerenti.

## Hybrid search: BM25 + coseno, e come pesare i due punteggi

Qui si capisce perché il vector-only fallisce e l'hybrid vince. Abbiamo due modi di cercare, e servono entrambi:

- **La ricerca vettoriale (coseno su embedding)**: brava a trovare per *significato*. "Quanto ho speso per il trasporto?" trova chunk che parlano di spedizioni, logistica, corriere, anche senza la parola esatta.
- **La ricerca lessicale (BM25 / full-text)**: brava a trovare per *parola esatta*. Una partita IVA, un numero di fattura, il nome preciso di un fornitore — dove la corrispondenza esatta conta, il full-text batte il vettoriale.

La forza sta nel **combinarle** (hybrid search), pesando i due punteggi. Ecco una query che unisce coseno e BM25 in Postgres:

```sql
-- $1 = embedding della domanda (vector), $2 = testo della domanda
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

Come si pesano i due punteggi (lo `0.6` / `0.4` sopra)? Dipende dalla domanda, ed è una scelta da tarare sui tuoi dati:

- Per domande **fattuali precise** (un numero fattura, una P.IVA), alza il peso lessicale: la parola esatta conta più del significato.
- Per domande **concettuali** ("spese di marketing", "consulenze"), alza il peso vettoriale: il significato conta più della parola esatta.
- Un punto di partenza ragionevole è 60% vettoriale / 40% lessicale, poi si aggiusta guardando i risultati sul set di valutazione (più avanti).

Ma ricorda la regola d'oro: **per i totali e le somme, non usare né l'uno né l'altro — usa SQL sui numeri tipizzati.** L'hybrid search trova i *documenti giusti*; quando la domanda è "quanto in totale", la risposta è un `SUM(importo_totale)` con i filtri giusti, non una cucitura di chunk. Questa è la differenza tra un sistema che *stima* e uno che *calcola*.

## Citazioni obbligatorie: ogni importo punta al file e al punto esatto

Questa è la regola non negoziabile su un RAG di fatture, ed è ciò che lo rende utilizzabile in un contesto dove i numeri hanno conseguenze: **ogni cifra che il sistema riporta deve essere accompagnata dalla citazione della fonte** — quale file, e quale punto dentro il file (l'`xpath` per l'XML, la pagina per i PDF).

Perché è obbligatorio, non un vezzo:

- **Verificabilità.** Chi legge la risposta ("hai pagato 12.200 € di IVA al 22% al fornitore Rossi nel Q2") deve poter cliccare e vedere *da quali fatture* viene quel numero. Senza, è una cifra che devi credere sulla parola a un sistema che a volte allucina — inaccettabile in contabilità.
- **Debug.** Quando un numero è sbagliato (e capiterà), la citazione ti dice *dove* è l'errore: un documento mal parsato, un duplicato, una nota di credito non collegata. Senza citazione, cerchi al buio.
- **Fiducia.** Un sistema che cita le fonti dice all'utente "controlla pure": è l'opposto della scatola nera. È la stessa disciplina della [ricerca sui documenti aziendali che risponde citando la fonte invece di inventare]({{ '/it/blog/ricerca-documenti-aziendali-pdf/' | relative_url }}).

In pratica: ogni chunk porta il suo `xpath` (o pagina), e la risposta finale del sistema non è mai "il totale è X", ma "il totale è X, da: fattura n.123 del 12/04 (`//DatiRiepilogo[1]/Imposta`), fattura n.130...". Il modello linguistico compone la frase; **i numeri e le fonti vengono dal database**, non dalla sua fantasia. Se un sistema di RAG sulle fatture non ti dà le citazioni, non è pronto per la produzione: è una demo.

## Un esempio completo: dalla domanda alla risposta citata

Mettiamo insieme i pezzi su una domanda vera: *"Quanta IVA al 22% ho pagato al fornitore ACME nel secondo trimestre?"*. Ecco come il sistema risponde senza allucinare, passo per passo.

**Passo 1 — capire la domanda.** Il sistema (o un piccolo strato sopra) riconosce che è una domanda **aggregata su numeri**, con tre filtri: fornitore = ACME, aliquota = 22%, periodo = Q2. Questo *non* è un caso da similarità vettoriale: è un caso da SQL sui dati tipizzati.

**Passo 2 — risolvere il fornitore.** "ACME" va agganciato al fornitore vero. Qui l'hybrid search aiuta: il full-text trova il fornitore per nome esatto, e si recupera la sua partita IVA per non confonderlo con un cliente omonimo. Il fornitore risolto diventa un filtro `piva_fornitore = '...'`.

**Passo 3 — calcolare, non stimare.** La risposta si ottiene con SQL sui numeri, non cucendo chunk:

```sql
SELECT d.numero, d.data_doc, c.aliquota, c.imposta, c.xpath, d.file_path
FROM chunks c
JOIN documenti d ON d.id = c.documento_id
WHERE c.sezione = 'riepilogo_iva'
  AND c.aliquota = 22.00
  AND d.piva_fornitore = $1
  AND d.data_doc BETWEEN '2026-04-01' AND '2026-06-30';
-- il totale:
-- SELECT SUM(imposta) FROM (...la stessa query...) t;
```

**Passo 4 — comporre la risposta con le citazioni.** Il modello linguistico prende il risultato della query e scrive una frase leggibile — ma i numeri e le fonti vengono dalle righe restituite, non dalla sua testa: *"Hai pagato 3.410,00 € di IVA al 22% ad ACME nel Q2, da 4 fatture: n.123 del 12/04 (imposta 880,00 €), n.130 del 03/05 …"*, ognuna con il link al file e all'`xpath` del riepilogo IVA.

Nota cosa **non** è successo: nessun chunk di testo è stato "interpretato" per estrarre un importo, nessuna cifra è stata avvicinata semanticamente a un'altra, nessun totale è stato indovinato. Il retrieval ha trovato il *contesto* (quale fornitore, quali documenti), l'SQL ha fatto il *conto*, e le citazioni rendono tutto verificabile. È questo triplo passaggio — trova, calcola, cita — che separa un RAG di fatture affidabile da un chatbot che spara numeri.

## Cosa si rompe in produzione: la tabella degli errori

I due errori che vedrai di più, come li riconosci, e come li chiudi:

| Sintomo | Causa tipica | Come lo riconosci | Rimedio |
|---|---|---|---|
| **Importo sbagliato** | Chunk a lunghezza fissa che spezza righe/riepiloghi; numeri cercati col vettoriale | La risposta cita cifre che, sommate, non tornano col totale del documento | Chunk per unità strutturale; totali via SQL sui numeri tipizzati, non via embedding |
| **Fornitore confuso col cliente** | Testata mal parsata: Cedente e Cessionario mescolati | "Fornitore Rossi" quando Rossi è il cliente (cessionario) | Estrarre esplicitamente Cedente vs Cessionario; test dedicati |
| **Totali raddoppiati** | Duplicati non deduplicati (stesso file due volte) | Le somme sono il doppio del reale su alcuni fornitori | Hash unico all'ingest; blocco dei duplicati |
| **Nota di credito ignorata** | Documento di storno non collegato all'originale | Un totale più alto del dovuto perché lo storno non è sottratto | Tracciare note di credito e revisioni con riferimento all'originale |
| **Numero "quasi giusto"** | Ricerca vettoriale su importi (1.220 ≈ 1.202) | Cifre plausibili ma non esatte | Mai cercare importi col vettoriale; match esatto o SQL |
| **Domanda su periodo sbagliata** | Data non tipizzata, filtrata come testo | "Nel Q2" ritorna anche documenti di altri trimestri | `data_doc` come `DATE`, filtri SQL sul periodo |

Il filo di tutti questi errori è lo stesso: **succedono quando tratti la fattura come prosa invece che come dato strutturato.** Rispetta la struttura all'ingest e la metà di questi problemi non nasce.

## La valutazione: le 50 domande d'oro

Non puoi migliorare quello che non misuri, e su un RAG di fatture "sembra che funzioni" non basta — un errore è un errore contabile. Serve un **set di valutazione**: un insieme di domande di cui conosci la risposta esatta (calcolata a mano o con query verificate), da rilanciare a ogni modifica del sistema.

Costruisci ~50 "domande d'oro" che coprono i tipi reali:

- **Totali di documento**: "qual è l'importo totale della fattura n.123?" → risposta esatta nota.
- **Somme per fornitore/periodo**: "quanto ho pagato al fornitore X nel Q2?" → `SUM` verificata.
- **Aliquote e IVA**: "quanta IVA al 22% in totale a marzo?" → verificata sui riepiloghi.
- **Scadenze e date**: "quali fatture scadono a novembre?".
- **Domande a trabocchetto**: "quanto mi ha fatturato Rossi?" quando Rossi è cliente e non fornitore — per verificare che non confonda i ruoli.

Per ogni domanda misuri due cose: **la risposta è esatta?** e **la citazione punta alla fonte giusta?**. Un sistema che dà il numero giusto ma cita la fattura sbagliata è comunque rotto (hai avuto fortuna). Questo set diventa il tuo test di regressione: cambi il chunking, il modello di embedding, i pesi dell'hybrid search — e rilanci le 50 domande per vedere se è migliorato o peggiorato. È l'unico modo onesto di sapere se il sistema è pronto, invece di fidarsi di qualche demo fortunata.

## I costi: VRAM contro API di embedding, e quando bastano 8 GB

Il pezzo che spesso spaventa: "ma per gli embedding locali mi serve una GPU mostruosa?". No. Gli embedding sono molto più leggeri della generazione di testo. Ordini di grandezza, come stime dichiarate.

| Voce | Ordine di grandezza | Note |
|---|---|---|
| **Modello di embedding locale** | gira in **~2-6 GB VRAM** (o anche su CPU) | I modelli di embedding sono piccoli. Una GPU da **8 GB** basta e avanza per indicizzare e interrogare. |
| **Indicizzare 10.000 fatture** | minuti-poche ore, una tantum | Costo di calcolo trascurabile; è un batch che fai una volta e aggiorni in incrementale. |
| **Postgres + pgvector** | gira su un **VPS modesto** | Nessun servizio vector a pagamento: il vector DB è dentro Postgres che già avresti. |
| **API di embedding cloud (confronto)** | a token, + i dati escono | Comoda ma manda ogni chunk al vendor: su fatture con dati fiscali, è il problema del [recinto aperto]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}). |
| **Pinecone / vector DB gestito** | canone mensile + lock-in | Inutile: pgvector fa lo stesso lavoro dentro il DB che già gestisci. |

Il verdetto economico: per il RAG sulle fatture, **il locale non solo è più sicuro, spesso è anche più economico** — perché gli embedding sono leggeri (8 GB bastano), Postgres lo hai già, e ti risparmi sia il canone di un vector DB gestito sia il costo-a-token delle API di embedding. Il cloud qui non ha nemmeno il vantaggio del "è più potente": per gli embedding, i modelli locali sono ottimi. Mandare i dati delle fatture — che contengono P.IVA, importi, rapporti coi fornitori — a un'API esterna, quando puoi fare tutto in casa con 8 GB, è regalare dati senza nemmeno risparmiare.

## Quando NON farlo

Onestà, come sempre. Questo sistema **non ti serve se:**

- **Hai poche fatture e domande semplici.** Se gestisci decine di fatture, non migliaia, e le tue domande sono "quanto ho fatturato questo mese", il tuo gestionale o un foglio ben fatto rispondono già. Costruire un RAG sarebbe sovraingegneria.
- **Il tuo gestionale risponde già.** Molti gestionali fanno report su fatture, IVA e scadenze. Se i report che ti servono esistono già lì, usali. Il RAG serve per le domande *non previste*, esplorative, in linguaggio naturale, su volumi grandi ed eterogenei.
- **Non hai chi lo mantiene.** Come ogni stack self-hosted, va aggiornato (Postgres, pgvector, il modello di embedding) e monitorato. Senza manutenzione, si degrada.
- **Ti servono i totali ufficiali per il fisco.** Attenzione: questo è uno strumento di *interrogazione ed esplorazione*, non la fonte di verità contabile. I numeri ufficiali vengono dalla contabilità e dal commercialista. Il RAG ti aiuta a *trovare e capire*, non sostituisce il bilancio.

Il RAG sulle fatture brilla su **volumi grandi, domande esplorative, e la necessità di risalire al documento fonte**. Fuori da lì, spesso basta il gestionale — e dirlo fa parte del mestiere.

## Checklist operativa prima della produzione

- [ ] Chunking **per unità strutturale** (testata, righe, riepiloghi IVA), mai a lunghezza fissa.
- [ ] I **numeri** stanno in colonne tipizzate (`NUMERIC`, `DATE`), non solo nel testo dei chunk.
- [ ] I **totali e le somme** si rispondono con SQL, non con la similarità vettoriale.
- [ ] L'ingest usa **`local-name()`** per reggere i namespace variabili della FatturaPA.
- [ ] **Deduplica** attiva (hash unico); duplicati bloccati.
- [ ] **Note di credito e revisioni** collegate ai documenti originali.
- [ ] **Hybrid search** BM25 + coseno, con pesi tarati sui tuoi dati.
- [ ] Ogni risposta porta la **citazione** (file + xpath/pagina); i numeri vengono dal DB.
- [ ] **Controllo di quadratura** all'ingest (righe + IVA = totale).
- [ ] Set delle **50 domande d'oro** come test di regressione.
- [ ] Embedding **locali** (8 GB bastano); nessun dato di fattura verso API esterne.

## Il verdetto: struttura prima, modello dopo

Se un chatbot sui PDF delle tue fatture allucina i numeri, non è colpa del modello: è che lo stai usando contro la natura del documento. Una fattura elettronica è **dato strutturato** — XML FatturaPA, con testata, righe e riepiloghi IVA — e un RAG che la rispetta parte da lì: chunking per unità semantica, numeri in colonne tipizzate, totali via SQL, hybrid search per trovare, e citazioni obbligatorie per provare ogni cifra. Tutto dentro PostgreSQL con pgvector, senza Pinecone e senza mandare i dati fiscali a un cloud — perché gli embedding stanno in 8 GB e Postgres lo hai già. La sfida di un RAG su fattura elettronica non è "quale vector database": è **rispettare la struttura italiana del documento**, ed è esattamente ciò che i sistemi generici non fanno.

Questo è un mattone della [guida al RAG e ai documenti in casa]({{ '/it/pillar/rag-documenti/' | relative_url }}), dove i tuoi documenti diventano interrogabili senza uscire dal tuo recinto. Se vuoi vedere com'è fatto sui *tuoi* documenti e sulle *tue* fatture, parti da [chi sono e come lavoro]({{ site.main_site }}/biografia/) o scrivimi due righe in [contatti]({{ site.main_site }}/contatti/).

## FAQ

**1. Perché non uso Pinecone o un vector DB gestito?**
Perché pgvector fa lo stesso lavoro dentro il PostgreSQL che probabilmente hai già: un solo database da gestire, niente canone, niente lock-in, e i dati non escono. Per le fatture — che contengono dati fiscali — il self-hosted è più sicuro e spesso più economico. Un vector DB gestito qui è complessità e costo in più senza un vantaggio reale.

**2. Perché il RAG generico sbaglia gli importi?**
Perché spezza le fatture in chunk a lunghezza fissa (mescolando importi e aliquote di documenti diversi), tratta i numeri come testo semantico (dove 1.220 e 1.202 sono "quasi uguali"), e perde la struttura in cui la posizione di un numero ne determina il significato. Serve chunking strutturale e numeri tipizzati.

**3. Devo partire dall'XML o dal PDF?**
Dall'XML FatturaPA, sempre che ce l'hai: la struttura è esplicita e non devi indovinare i campi. I PDF (fatture vecchie, estere, scansionate) si gestiscono a parte con OCR, sapendo che sono meno affidabili e le citazioni diventano "pagina" invece di xpath.

**4. Come evito di confondere fornitore e cliente?**
Estraendo esplicitamente il **CedentePrestatore** (fornitore, chi emette) e il **CessionarioCommittente** (cliente, chi riceve) dalla testata, con test dedicati che verificano che i ruoli non si invertano. È l'errore classico e va presidiato con domande a trabocchetto nel set di valutazione.

**5. Perché serve l'hybrid search e non solo gli embedding?**
Perché gli embedding trovano per significato ma falliscono sulle corrispondenze esatte (P.IVA, numero fattura, nome preciso). Il full-text (BM25) trova per parola esatta. Combinarli, pesando i punteggi, copre entrambi i tipi di domanda. E per i totali non usi nessuno dei due: usi SQL sui numeri.

**6. Come faccio a fidarmi dei numeri che mi dà?**
Con le citazioni obbligatorie: ogni cifra punta al file e al punto esatto (xpath o pagina). I numeri vengono dal database, non dal modello linguistico, che si limita a comporre la frase. Se non puoi verificare da quali fatture viene un totale, il sistema non è pronto per la produzione.

**7. Quanta GPU mi serve davvero?**
Poca: i modelli di embedding girano in ~2-6 GB VRAM (o su CPU). Una scheda da 8 GB basta e avanza per indicizzare e interrogare migliaia di fatture. La generazione del testo di risposta è più esigente, ma per quella puoi usare un modello locale piccolo o gestire il fraseggio con logica semplice sopra i dati.

**8. Come gestisco duplicati e note di credito?**
I duplicati con un hash unico del contenuto all'ingest: se esiste già, lo scarti, altrimenti i totali raddoppiano. Le note di credito e le revisioni non sono duplicati: sono documenti collegati che stornano o correggono, e vanno tracciati con un riferimento all'originale, o le somme risultano più alte del reale.

**9. Posso interrogarlo in linguaggio naturale come un chatbot?**
Sì, ma con la disciplina giusta: la domanda in linguaggio naturale guida il retrieval (hybrid search) e i filtri (periodo, fornitore, aliquota), ma i numeri finali vengono calcolati con SQL sui dati tipizzati e presentati con le citazioni. Il "chatbot" è l'interfaccia; il motore che risponde non allucina perché non inventa cifre.

**10. È conforme al GDPR tenere le fatture in questo sistema?**
Il sistema gira interamente in casa tua (Postgres + embedding locali), quindi i dati non escono — il che è il punto di partenza per la conformità, molto meglio di mandarli a un'API cloud. Restano da gestire accessi, retention e le regole del tuo contesto (col consulente), ma il recinto è chiuso: è lo stesso principio dello stack sovrano su cui poggia tutta questa guida.
