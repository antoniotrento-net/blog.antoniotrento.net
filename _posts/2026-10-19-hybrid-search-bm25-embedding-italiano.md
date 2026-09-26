---
lang: it
permalink: /it/blog/hybrid-search-bm25-embedding-italiano/
title: "Hybrid search BM25 + embedding sull'italiano: come non far vincere sempre il cosine (e perdere \"articolo 18\")"
date: 2026-10-19 07:30:00 +0200
author: "Antonio Trento"
description: "Ricerca ibrida lessicale + vettoriale su documenti italiani: perché l'embedding fallisce su query corte e numeriche, i limiti del tsvector italian, RRF vs somma pesata, filtri prima dell'ANN, eval nDCG su query reali e l'implementazione in Postgres."
keywords: ["hybrid search bm25 embedding italiano", "postgresql full text italiano", "rrf fusion", "ricerca ibrida rag", "tsvector italian", "ricerca giuridica italiano"]
image: /assets/images/posts/hybrid-search-bm25-embedding-italiano.jpg
pillar: rag-documenti
related: [/it/blog/pgvector-vs-qdrant-vs-pinecone/, /it/blog/chunking-contratti-italiani-rag/]
---

## Query corte e numeriche: l'embedding da solo fallisce

Un consulente del lavoro scrive nel motore di ricerca interno dello studio: **"articolo 18"**. Il sistema RAG, basato solo su embedding, restituisce come primo risultato un documento sull'articolo 19 dello Statuto dei lavoratori, poi una circolare sui licenziamenti collettivi, poi un parere che cita l'articolo 81 di un altro decreto. Tutti "semanticamente vicini": parlano di diritto del lavoro, di articoli di legge, di licenziamenti. Nessuno è quello che cercava. Il documento giusto — che contiene letteralmente la stringa "art. 18" — è al quattordicesimo posto.

Non è un bug del modello di embedding: è il suo funzionamento normale. Un embedding comprime il significato di un testo in un vettore, e in quello spazio "articolo 18" e "articolo 19" sono quasi identici: stessa struttura, stesso dominio, numeri che il modello tratta come dettagli. Il **cosine vince sempre**, perché misura la somiglianza di argomento, non l'identità di un riferimento. E nei documenti giuridici, fiscali e tecnici italiani, il riferimento esatto — un numero di articolo, un decreto, un numero di fattura, un codice prodotto — è spesso *tutta* la domanda.

Questo pezzo è sulla **hybrid search, BM25 più embedding, sull'italiano**: combinare una ricerca lessicale (che trova le parole e i numeri esatti) con una ricerca vettoriale (che trova il significato), in modo che nessuna delle due domini l'altra. Nel pezzo sul [confronto pgvector vs Qdrant vs Pinecone]({{ '/it/blog/pgvector-vs-qdrant-vs-pinecone/' | relative_url }}) ho mostrato la versione base di una fusione in Postgres; qui entriamo nei dettagli che fanno la differenza sull'italiano: i limiti dello stemmer, le stopword che cancellano la negazione, gli apostrofi, le abbreviazioni come "art." e "n.", i numeri con la barra, e soprattutto come **misurare** se la ricerca funziona invece di giudicarla a sensazione.

Le query che mettono in crisi gli embedding hanno tratti precisi:

- **Sono corte**: due o tre parole ("art. 18", "fattura 1234", "D.Lgs. 81"). Un vettore costruito su due token ha poco significato da catturare.
- **Contengono identificativi**: numeri di articolo, commi, decreti, date, numeri di documento, codici fiscali, codici prodotto. Per l'embedding sono rumore; per l'utente sono la domanda.
- **Contengono sigle**: "CCNL", "TFR", "DURC", "SCIA". I modelli multilingue le conoscono a volte, e a volte le confondono.
- **Richiedono esattezza**: "penale del 10%" non è "penale del 20%". Un vettore non ha buone ragioni per distinguerle.

La ricerca lessicale fa l'opposto: è eccellente sugli identificativi e pessima sulle parafrasi ("recesso anticipato" non trova "disdetta prima della scadenza"). La ricerca ibrida esiste perché i due fallimenti sono complementari.

## Una precisazione onesta: Postgres full-text non è BM25

Prima di andare avanti, una distinzione che molti articoli saltano. "BM25" è una funzione di ranking specifica, usata dai motori di ricerca classici, che pesa la frequenza di un termine nel documento, la sua rarità nel corpus e la lunghezza del documento. **La ricerca full-text di PostgreSQL non usa BM25**: le funzioni `ts_rank` e `ts_rank_cd` hanno logiche di ranking proprie (frequenza e prossimità dei termini, con normalizzazioni opzionali per lunghezza), senza la componente di rarità nel corpus che caratterizza BM25.

In pratica, per la ricerca ibrida questo conta meno di quanto sembri, per due motivi: con la fusione basata sui **ranghi** (RRF, che vediamo tra poco) non usi i punteggi assoluti ma solo l'ordine dei risultati; e sulle query con identificativi il lavoro vero lo fa il *match* (il documento contiene o non contiene "18"), non la sfumatura del punteggio. Se ti serve un BM25 vero dentro Postgres, esistono estensioni che lo implementano, oppure motori dedicati (OpenSearch, Elasticsearch, Tantivy) affiancati al database. Per la maggior parte dei RAG aziendali italiani, il full-text nativo ben configurato più una buona fusione è sufficiente — ma chiamiamolo col suo nome: ricerca lessicale, non BM25.

## tsvector italian e i limiti dello stemmer

La configurazione `italian` di PostgreSQL fa tre cose: divide il testo in token con il parser di default, elimina le **stopword** italiane, e riduce le parole alla loro radice con uno **stemmer** (basato sull'algoritmo Snowball per l'italiano). Così "contratti", "contratto" e "contrattuale" possono condividere una radice e trovarsi a vicenda. Utile. Ma ha limiti precisi, che su documenti professionali italiani emergono in fretta.

**1. Le stopword cancellano parole che contano.** La lista di stopword italiana include parole funzionali come articoli, preposizioni, congiunzioni — e anche **"non"**. In un testo generico va bene. In un documento fiscale o legale, "operazione **non** soggetta a IVA" e "operazione soggetta a IVA" diventano, per la ricerca lessicale, lo stesso insieme di token. La negazione sparisce.

**2. Lo stemmer fonde parole diverse.** Le radici sono euristiche: cognomi, nomi propri e termini tecnici possono essere ridotti alla stessa radice di parole comuni. Un cognome come "Rossi" e l'aggettivo "rosso" rischiano di collidere; sigle e nomi di prodotti vengono troncati in modi imprevedibili. Per i documenti in cui i nomi propri contano (anagrafiche, fatture, contratti con controparti) lo stemming è un rischio.

**3. Il parser ha opinioni sui simboli.** Il parser di default classifica i token per tipo (parole, numeri, URL, percorsi di file, email…). Una stringa come "81/2008" può essere riconosciuta come qualcosa di diverso da due numeri separati; "D.Lgs." si spezza in modi che dipendono dai punti; gli apostrofi separano le elisioni ("l'articolo", "dell'IVA") in modi che conviene verificare. Il comando da conoscere è `ts_debug`, che mostra esattamente come il testo viene tokenizzato:

```sql
-- Vedi come Postgres tokenizza i riferimenti tipici: non indovinare, controlla
SELECT alias, token, lexemes
FROM ts_debug('italian', 'Ai sensi dell''art. 18 della L. 300/1970, n. 12 comma 1-bis');
```

La lezione pratica: **non affidare gli identificativi allo stemmer.** La soluzione che uso è avere **due rappresentazioni lessicali** dello stesso testo: una `italian` (con stemming e stopword, per le parole) e una `simple` (senza stemming né stopword, per numeri, sigle, nomi propri e negazioni). La query lessicale cerca in entrambe.

## Accenti, maiuscole, "n." e "art.": gli errori tipici italiani

L'italiano scritto nei documenti aziendali è pieno di varianti che la ricerca deve riconciliare. Gli errori tipici che vedo:

| Problema | Esempio | Effetto | Contromisura |
|----------|---------|---------|--------------|
| Accenti e apostrofi al posto degli accenti | "perché" / "perche'" / "perchè" | parole diverse per il motore | estensione `unaccent` in indicizzazione e in query |
| Maiuscole | "IVA" / "iva" / "Iva" | di solito gestito, ma non nelle sigle composte | normalizzazione minuscola coerente |
| Abbreviazioni di riferimento | "art." / "articolo" / "artt." | l'utente scrive "articolo 18", il testo dice "art. 18" | normalizzazione e sinonimi mirati |
| Numero | "n." / "nr." / "num." / "N°" | "fattura n. 1234" non trova "fattura nr 1234" | normalizzazione dei marcatori prima dell'indicizzazione |
| Numeri con barra | "81/2008", "1234/2025" | tokenizzazione imprevedibile | indicizzare anche le parti separate nella rappresentazione `simple` |
| Commi e suffissi | "1-bis", "comma 3 ter" | suffissi separati o fusi | tokenizzazione controllata, varianti in indice |
| Sigle di fonti | "D.Lgs.", "DPR", "L.", "c.c." | punti che spezzano i token | dizionario di sinonimi per le fonti principali |
| Negazione | "non soggetto", "non dovuto" | "non" rimosso come stopword | rappresentazione `simple` che lo conserva |
| Elisioni | "dell'imposta", "l'IVA" | token con o senza articolo | verifica con `ts_debug`, normalizzazione |
| Nomi propri | "Rossi", "Ferrari" | stemming che collide con parole comuni | ricerca sulla rappresentazione `simple` |

Due regole:

- **La stessa normalizzazione in indicizzazione e in query.** Se tolgo gli accenti ai documenti ma non alla query, ho peggiorato le cose.
- **I sinonimi sono pochi e mirati.** Una lista breve per le abbreviazioni di riferimento ("art." ↔ "articolo", "c.c." ↔ "codice civile", "D.Lgs." ↔ "decreto legislativo") fa molto; un dizionario di sinonimi generico fa più danni che altro, perché allarga le query in modi che l'utente non ha chiesto.

## RRF vs somma pesata

Hai due liste di risultati: una dalla ricerca lessicale, una dalla ricerca vettoriale. Come le unisci?

**La somma pesata dei punteggi** è la prima idea: `score = α · punteggio_lessicale + (1−α) · similarità_coseno`. Il problema è che i due punteggi vivono su **scale diverse**: `ts_rank` può assumere valori piccoli o grandi a seconda della lunghezza del documento e delle opzioni di normalizzazione; la similarità coseno sta tipicamente in un intervallo stretto e dipende dal modello. Per sommarli devi normalizzarli (min-max per query, z-score…), e ogni normalizzazione introduce comportamenti strani: una query con un solo risultato lessicale forte e molti deboli si comporta diversamente da una con tanti risultati simili. Il peso α diventa una manopola sensibilissima che funziona per alcune query e rompe le altre.

**La Reciprocal Rank Fusion (RRF)** ignora i punteggi e usa solo le **posizioni**: ogni documento riceve, per ogni lista in cui compare, un contributo `1 / (k + rango)`, e i contributi si sommano. Il parametro `k` (tipicamente intorno a 60) attenua il peso delle prime posizioni. Pregi:

- **Nessuna normalizzazione**: le scale dei punteggi non contano.
- **Robustezza**: un documento che è in cima a una lista e assente nell'altra ottiene comunque un buon punteggio; uno che è a metà in entrambe anche.
- **Pochi parametri**: `k` e, se vuoi, un peso per lista (RRF pesata). Meno parametri significa meno overfitting.

Per il caso "articolo 18" la RRF è decisiva: il documento con "art. 18" è primo nella lista lessicale. Anche se è quattordicesimo in quella vettoriale, il suo contributo lessicale lo porta in cima o molto vicino. Il cosine non può più vincere da solo.

Il mio default è **RRF con k=60 e pesi uguali**, da cambiare solo se la valutazione (più sotto) lo giustifica. Un'eccezione utile: quando la query contiene identificativi riconoscibili (un numero di articolo, un numero di documento), puoi dare un peso maggiore alla lista lessicale. È una regola esplicita e spiegabile, non una manopola tarata a caso.

## Filtri (anno, società, tipo documento) prima dell'ANN

Nei RAG aziendali quasi ogni ricerca ha dei **filtri**: solo i documenti di una società del gruppo, solo i contratti, solo gli atti dal 2023, solo i documenti che l'utente ha il permesso di vedere. Il modo in cui applichi i filtri cambia radicalmente la qualità dei risultati vettoriali.

Gli indici approssimati per la ricerca vettoriale (come HNSW in pgvector) trovano velocemente i vicini più simili esplorando un grafo, e restituiscono un certo numero di candidati. Se il filtro viene applicato **dopo** — "prendo i 40 più vicini, poi tengo quelli della società X" — e la società X rappresenta il 5% dei documenti, dei 40 candidati ne sopravvivono due o tre, o nessuno. L'utente vede pochissimi risultati, o risultati peggiori di quelli che esistono davvero.

Le strategie per evitarlo:

- **Versioni recenti di pgvector** hanno introdotto scansioni iterative dell'indice, che continuano a esplorare finché non trovano abbastanza risultati che rispettano il filtro. Se usi pgvector, verifica la versione e le opzioni disponibili: fanno la differenza sui filtri selettivi.
- **Indici parziali** per i filtri più frequenti e selettivi (per esempio un indice HNSW per tipo di documento, se i tipi sono pochi e stabili).
- **Partizionamento** per tenant o per società quando il volume lo giustifica: ogni partizione ha il suo indice, e il filtro diventa la scelta della partizione.
- **Aumentare il numero di candidati** esplorati (parametri come `ef_search`) per le query con filtri selettivi, accettando un po' di latenza in più.
- **Filtri identici sui due rami**: la ricerca lessicale e quella vettoriale devono applicare **gli stessi filtri**, altrimenti la fusione mescola documenti che l'utente non doveva vedere o che non rispettano il perimetro richiesto.

I filtri di **permesso** meritano una nota a parte: non sono un'ottimizzazione, sono sicurezza. Un documento che l'utente non può vedere non deve entrare nella lista dei candidati, in nessuno dei due rami. È lo stesso principio che applico nel chunking dei contratti: la struttura e i metadati si decidono in indicizzazione, non si rattoppano in risposta — ne ho parlato nel pezzo sul [chunking dei contratti italiani per il RAG]({{ '/it/blog/chunking-contratti-italiani-rag/' | relative_url }}).

## L'architettura di riferimento

```
  Query utente ("art. 18 statuto lavoratori, società Alfa")
        │
        ▼
  ┌──────────────────────────────────────────────┐
  │ NORMALIZZATORE                                │
  │ unaccent · minuscole · "art."/"n." normalizzati│
  │ estrazione identificativi (regex: art, n., /) │
  │ filtri espliciti (società, tipo, anno, ACL)   │
  └───────────────┬──────────────────────────────┘
                  │ stessi filtri su entrambi i rami
      ┌───────────┴─────────────┐
      ▼                         ▼
 ┌───────────────────┐   ┌──────────────────────────┐
 │ LESSICALE          │   │ VETTORIALE (HNSW)         │
 │ tsvector italian + │   │ embedding multilingue     │
 │ tsvector simple    │   │ filtri prima/durante ANN  │
 │ (identificativi)   │   │                            │
 └─────────┬─────────┘   └────────────┬─────────────┘
           └──────────┬───────────────┘
                      ▼
            ┌──────────────────────┐
            │ RRF (k=60, pesi)      │ ← peso lessicale ↑ se ci sono identificativi
            └──────────┬───────────┘
                       ▼
            ┌──────────────────────┐
            │ (opz.) reranker        │
            └──────────┬───────────┘
                       ▼
          top-k chunk → LLM con citazioni
```

**Cosa non tocca il sistema**: il modello linguistico non riscrive gli identificativi della query (se l'utente scrive "art. 18", nessuna "espansione" può trasformarlo in "art. 19"); i filtri di permesso non sono mai opzionali; l'LLM riceve i chunk con la loro provenienza e cita la fonte, non inventa riferimenti che non ha visto.

## Implementazione Postgres

Mettiamo insieme i pezzi in Postgres con pgvector. Il costo di tenere tutto nello stesso database è basso, e il vantaggio è enorme: filtri, permessi e ricerca vivono nella stessa transazione.

Prima la configurazione testuale italiana senza accenti:

```sql
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS vector;

-- Configurazione italiana che toglie gli accenti prima dello stemming
CREATE TEXT SEARCH CONFIGURATION it_unaccent ( COPY = italian );
ALTER TEXT SEARCH CONFIGURATION it_unaccent
  ALTER MAPPING FOR hword, hword_part, word
  WITH unaccent, italian_stem;

-- unaccent() non è IMMUTABLE: wrapper per poterlo usare in colonne generate
CREATE OR REPLACE FUNCTION f_unaccent(text) RETURNS text
  LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
  AS $$ SELECT public.unaccent('public.unaccent', $1) $$;

-- Normalizzazione dei marcatori tipici italiani (applicata anche alla query)
CREATE OR REPLACE FUNCTION f_norm_it(t text) RETURNS text
  LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS $$
  SELECT regexp_replace(
           regexp_replace(
             regexp_replace(lower(f_unaccent(t)),
               '\m(nr|num|n°|n\.)\s*', 'numero ', 'g'),
             '\m(artt?\.)\s*', 'articolo ', 'g'),
           '(\d+)/(\d+)', '\1 \2 \1/\2', 'g')     -- "81/2008" -> "81 2008 81/2008"
$$;

CREATE TABLE chunks (
  id          bigserial PRIMARY KEY,
  doc_id      text NOT NULL,
  societa     text NOT NULL,
  tipo_doc    text NOT NULL,
  anno        int,
  acl_group   text NOT NULL,
  testo       text NOT NULL,
  embedding   vector(1024),
  tsv_it      tsvector GENERATED ALWAYS AS (to_tsvector('it_unaccent', f_norm_it(testo))) STORED,
  tsv_simple  tsvector GENERATED ALWAYS AS (to_tsvector('simple',      f_norm_it(testo))) STORED
);

CREATE INDEX ON chunks USING gin (tsv_it);
CREATE INDEX ON chunks USING gin (tsv_simple);
CREATE INDEX ON chunks USING hnsw (embedding vector_cosine_ops);
CREATE INDEX ON chunks (societa, tipo_doc, anno);
```

La normalizzazione `f_norm_it` è deliberatamente semplice e va adattata ai tuoi documenti: trasforma i marcatori di numero e di articolo in parole piene e duplica i numeri con la barra nelle loro parti, così "81/2008" è trovabile sia come "81/2008" sia come "81" e "2008". La stessa funzione si applica alla query.

Poi la query ibrida, con gli stessi filtri su entrambi i rami e la fusione RRF:

```sql
-- Parametri: :q (testo query), :qvec (embedding della query), :societa, :acl, :k_lex, :w_lex
WITH filtro AS (
  SELECT id FROM chunks
  WHERE societa = :societa AND acl_group = ANY(:acl) AND anno >= 2020
),
lessicale AS (
  SELECT c.id,
         row_number() OVER (ORDER BY
           ts_rank_cd(c.tsv_simple, plainto_tsquery('simple',      f_norm_it(:q))) * 2
         + ts_rank_cd(c.tsv_it,     plainto_tsquery('it_unaccent', f_norm_it(:q))) DESC) AS r
  FROM chunks c JOIN filtro f USING (id)
  WHERE c.tsv_simple @@ plainto_tsquery('simple',      f_norm_it(:q))
     OR c.tsv_it     @@ plainto_tsquery('it_unaccent', f_norm_it(:q))
  LIMIT 50
),
vettoriale AS (
  SELECT c.id, row_number() OVER (ORDER BY c.embedding <=> :qvec) AS r
  FROM chunks c JOIN filtro f USING (id)
  ORDER BY c.embedding <=> :qvec
  LIMIT 50
)
SELECT c.id, c.doc_id, c.testo,
       coalesce(:w_lex / (60.0 + l.r), 0) + coalesce(1.0 / (60.0 + v.r), 0) AS rrf
FROM chunks c
LEFT JOIN lessicale  l ON l.id = c.id
LEFT JOIN vettoriale v ON v.id = c.id
WHERE l.id IS NOT NULL OR v.id IS NOT NULL
ORDER BY rrf DESC
LIMIT 10;
```

Tre note di implementazione:

- Il ramo lessicale **pesa di più la rappresentazione `simple`** (il fattore 2 nel ranking), perché lì stanno i match esatti di numeri e nomi. È una scelta da validare con la valutazione, non un dogma.
- `plainto_tsquery` richiede che tutti i termini siano presenti (AND): per query lunghe e discorsive può essere troppo restrittivo; `websearch_to_tsquery` permette sintassi più flessibili. Anche questa è una scelta da misurare.
- Il parametro `:w_lex` è il peso della lista lessicale nella RRF: 1 di default, più alto quando il normalizzatore ha trovato identificativi nella query.

## Eval: nDCG su 30 query reali

Tutto quello che ho scritto finora è un'ipotesi finché non lo misuri. La valutazione di un sistema di ricerca si fa con un **gold set**: un insieme di query reali, ciascuna con i documenti che dovrebbero comparire, e una metrica che confronta la classifica del sistema con quella ideale.

La metrica che uso è **nDCG@10** (Normalized Discounted Cumulative Gain sui primi 10 risultati): premia i documenti rilevanti in alto più di quelli in basso, accetta rilevanza graduata (molto rilevante, parzialmente rilevante), e restituisce un valore tra 0 e 1 confrontabile tra configurazioni diverse. Affianco sempre il **Recall@20** (quanti dei documenti rilevanti compaiono tra i primi 20): se il documento giusto non è tra i candidati, nessun reranker o LLM potrà recuperarlo.

Trenta query sono poche per una statistica fine, ma sufficienti per vedere differenze grandi e per non ingannarsi. La regola è che siano **query reali**: prese dai log di ricerca, dalle domande dei colleghi, dai ticket. Non inventate da chi ha costruito il sistema, che inconsciamente scrive query "facili" per il suo sistema.

La **lista di query d'oro** che uso come modello per uno studio professionale o un ufficio amministrativo, bilanciata tra tipi diversi:

| # | Query | Tipo | Cosa deve trovare |
|---|-------|------|-------------------|
| 1 | art. 18 statuto lavoratori | identificativo + fonte | documenti che citano l'art. 18 della L. 300/1970 |
| 2 | articolo 2087 codice civile | identificativo | sicurezza e tutela del lavoratore |
| 3 | D.Lgs. 81/2008 sorveglianza sanitaria | identificativo + tema | testi sul decreto, sezione sorveglianza |
| 4 | art. 1341 c.c. doppia firma | identificativo + tema | clausole vessatorie e approvazione specifica |
| 5 | fattura n. 1234/2025 | identificativo puro | quella fattura, non le altre del 2025 |
| 6 | recesso anticipato senza penale | semantica | anche testi che dicono "disdetta prima della scadenza" |
| 7 | operazione non soggetta a IVA | negazione | non i documenti su operazioni soggette |
| 8 | preavviso dimissioni CCNL commercio | sigla + tema | contratto collettivo corretto |
| 9 | videosorveglianza dipendenti privacy | semantica | anche testi su "controllo a distanza" |
| 10 | IBAN fornitore Rossi | nome proprio | il fornitore Rossi, non documenti "rossi" |
| 11 | penale per ritardata consegna | semantica | clausole penali, anche con parafrasi |
| 12 | comma 1-bis articolo 5 | identificativo con suffisso | quel comma specifico |
| 13 | DURC irregolare cosa fare | sigla + procedura | procedura interna |
| 14 | TFR anticipo requisiti | sigla + tema | anche "trattamento di fine rapporto" |
| 15 | perché scade la garanzia | accenti | indipendente da "perche"/"perchè" |

…e così via fino a trenta, con una proporzione ragionevole di query con identificativi, query semantiche, sigle, negazioni e nomi propri. Per ogni query, chi conosce i documenti indica i risultati rilevanti con due livelli (2 = esattamente quello che serve, 1 = utile).

Il calcolo, semplice e trasparente:

```python
import math

def dcg(rilevanze):
    return sum((2**r - 1) / math.log2(i + 2) for i, r in enumerate(rilevanze))

def ndcg_at_k(risultati, gold, k=10):
    """risultati: lista di doc_id ordinati; gold: {doc_id: rilevanza 1..2}"""
    ottenute = [gold.get(d, 0) for d in risultati[:k]]
    ideali = sorted(gold.values(), reverse=True)[:k]
    return dcg(ottenute) / dcg(ideali) if ideali else 0.0

def valuta(cerca, gold_set, k=10):
    righe = []
    for q in gold_set:
        ris = cerca(q["query"], **q.get("filtri", {}))
        righe.append({"query": q["query"], "tipo": q["tipo"],
                      "ndcg": ndcg_at_k(ris, q["rilevanti"], k),
                      "recall20": len(set(ris[:20]) & set(q["rilevanti"])) / len(q["rilevanti"])})
    return righe   # guarda la media, ma soprattutto i risultati PER TIPO di query
```

La cosa più utile non è la media: è il risultato **per tipo di query**. Tipicamente vedrai che la ricerca solo vettoriale va bene sulle query semantiche e crolla su identificativi, negazioni e nomi propri; quella solo lessicale fa il contrario; l'ibrida con RRF è la più equilibrata. Se l'ibrida peggiora un tipo di query rispetto a una delle due componenti, hai trovato dove lavorare.

## Tuning dei pesi senza overfit

La tentazione, una volta che hai un gold set, è ottimizzare ogni parametro finché il numero sale: `k` della RRF, peso lessicale, peso della rappresentazione `simple`, soglie, sinonimi. Con trenta query e sei parametri, puoi portare l'nDCG dove vuoi — e ottenere un sistema tarato su quelle trenta query, che peggiora sulle altre. È lo stesso problema dell'overfitting dei backtest che ho descritto parlando di trading: più manopole giri su pochi dati, più misuri la tua capacità di adattarti al campione.

Le regole che applico:

- **Pochi parametri**, con un significato: `k` fisso a 60, un peso lessicale che vale 1 di default e un valore maggiore solo quando la query contiene identificativi (regola esplicita), il fattore della rappresentazione `simple`. Stop.
- **Dividi il gold set**: una parte per decidere, una parte per verificare. Se una modifica migliora la prima e peggiora la seconda, stai adattando rumore.
- **Guarda la stabilità**: un parametro che funziona bene su un intervallo di valori è più affidabile di uno che funziona solo su un valore preciso.
- **Preferisci regole a pesi**: "se la query contiene un numero di articolo, dai priorità al match esatto" è comprensibile, testabile e resiste ai cambiamenti del corpus; "peso lessicale 0,37" no.
- **Fai crescere il gold set**: ogni settimana aggiungi dai log reali le query che hanno funzionato male. Il gold set di sei mesi dopo è la tua difesa migliore contro le regressioni.

## Percorso di implementazione, a step

1. **Raccogli 30 query reali** e fai indicare a chi conosce i documenti i risultati rilevanti. È il primo passo, non l'ultimo.
2. **Misura la baseline**: solo vettoriale, solo lessicale. Guarda i risultati per tipo di query.
3. **Configura il full-text italiano** con `unaccent`, e verifica la tokenizzazione dei tuoi riferimenti tipici con `ts_debug`.
4. **Aggiungi la rappresentazione `simple`** per identificativi, nomi propri e negazioni.
5. **Scrivi la normalizzazione** dei marcatori italiani ("art.", "n.", numeri con barra), identica per documenti e query.
6. **Implementa la fusione RRF** con gli stessi filtri su entrambi i rami.
7. **Sistema i filtri** prima o durante l'ANN: versione di pgvector, indici parziali o partizioni, candidati sufficienti.
8. **Rimisura** con nDCG@10 e Recall@20, per tipo di query.
9. **Aggiungi una regola** per le query con identificativi (peso lessicale maggiore) solo se la valutazione lo conferma.
10. **Valuta un reranker** solo se, dopo tutto questo, il Recall@20 è buono ma l'ordine dei primi risultati no.
11. **Monitora** le query senza risultati e quelle con clic sul decimo risultato: sono le candidate per il gold set.

## Fallimenti tipici e come li riconosci dai log

- **Query corte con identificativo che restituiscono documenti "vicini ma sbagliati".** Nei log: query con numeri e primo risultato che non contiene quel numero. Il ramo lessicale non sta trovando il match (tokenizzazione) o pesa troppo poco nella fusione.
- **Zero risultati lessicali su query ovvie.** `plainto_tsquery` richiede tutti i termini e uno di essi è stato normalizzato diversamente nel documento. Verifica con `ts_debug` query e testo.
- **Negazioni ignorate.** L'utente cerca "non soggetto" e ottiene documenti su "soggetto": la stopword "non" è stata rimossa. Serve la rappresentazione `simple`.
- **Pochi risultati con filtri selettivi.** Nei log: query filtrate su una società piccola con 1–3 risultati vettoriali. Post-filtering sull'indice ANN: rivedi strategia di filtro e numero di candidati.
- **Risultati di un'altra società o fuori permesso.** Filtri non identici tra i due rami: grave, perché è un problema di accesso ai dati, non di qualità.
- **Nomi propri confusi con parole comuni.** Ricerche di fornitori o persone che restituiscono documenti con l'aggettivo omonimo: stemming. La rappresentazione `simple` deve pesare di più per queste query.
- **nDCG che sale sul gold set e lamentele che aumentano.** Overfitting dei parametri sul gold set: dividilo, riduci i parametri, allarga con query nuove.

## Costi: ordini di grandezza

Stime indicative.

- **Infrastruttura**: tutto in Postgres. Gli indici GIN sulle due rappresentazioni testuali aggiungono spazio disco nell'ordine di una frazione della dimensione del testo; l'indice HNSW dipende dal numero di chunk e dalla dimensione dei vettori (per un milione di chunk a 1024 dimensioni, diversi GB). Nessun servizio in più da gestire.
- **Latenza**: la ricerca lessicale con indice GIN e quella vettoriale con HNSW su qualche milione di chunk stanno tipicamente nell'ordine di decine di millisecondi ciascuna su un server adeguato; la fusione è trascurabile. Un reranker aggiunge da decine a centinaia di millisecondi, a seconda del modello e della GPU.
- **Embedding**: invariato rispetto a un RAG solo vettoriale.
- **Reranker (opzionale)**: un modello multilingue di reranking su GPU costa un server con GPU o parte di uno esistente; su CPU è spesso troppo lento per l'uso interattivo.
- **Energia**: marginale rispetto a quella del database già esistente.
- **Il costo vero è il gold set**: qualche ora di una persona che conosce i documenti per le prime trenta query, e mezz'ora a settimana per farlo crescere. È anche l'investimento che rende difendibile ogni scelta successiva.

## Quando NON farlo

- **Se le query sono sempre lunghe e discorsive** ("come gestiamo un reso di un cliente estero con merce danneggiata?") e i documenti non contengono identificativi rilevanti, la ricerca vettoriale da sola può bastare. Misuralo prima di complicare.
- **Se le query sono quasi sempre identificativi** (ricerca di fatture, ordini, codici), non ti serve un RAG semantico: una buona ricerca lessicale, o una query SQL sui campi strutturati, è più precisa e più semplice.
- **Se i dati sono già strutturati** (numero documento, data, controparte in colonne), cerca lì, non nel testo. La ricerca ibrida serve per il testo libero.
- **Se non hai tempo di costruire un gold set**, non ottimizzare pesi e parametri: resta sui default (RRF, k=60, pesi uguali), che sono ragionevoli, e investi il tempo nel gold set appena puoi.
- **Se il corpus è minuscolo** (qualche centinaio di documenti), la differenza tra configurazioni sarà difficile da misurare e il valore aggiunto modesto.

## Checklist operativa

- [ ] Gold set di almeno 30 query reali, con rilevanza graduata, bilanciato per tipo.
- [ ] Baseline misurata: solo vettoriale e solo lessicale, per tipo di query.
- [ ] Configurazione italiana con `unaccent`; tokenizzazione dei riferimenti verificata con `ts_debug`.
- [ ] Rappresentazione `simple` per identificativi, nomi propri e negazioni.
- [ ] Normalizzazione di "art.", "n.", numeri con barra, identica in indicizzazione e query.
- [ ] Fusione RRF con k=60; peso lessicale maggiore solo per query con identificativi, se validato.
- [ ] Stessi filtri (inclusi i permessi) su entrambi i rami.
- [ ] Strategia per i filtri selettivi sull'ANN (versione pgvector, indici parziali o partizioni).
- [ ] nDCG@10 e Recall@20 per tipo di query, prima e dopo ogni modifica.
- [ ] Gold set diviso per scelta e verifica; pochi parametri; regole spiegabili.
- [ ] Log di query senza risultati e con risultati "vicini ma sbagliati" per far crescere il gold set.

## Il verdetto

Sull'italiano dei documenti aziendali — contratti, normative, fatture, procedure — la ricerca solo vettoriale ha un punto cieco preciso: le query corte, gli identificativi, le negazioni, i nomi propri. Il **cosine vince sempre** perché misura l'argomento, e "articolo 18" e "articolo 19" parlano della stessa cosa. Per l'utente, però, sono due documenti diversi, e trovare quello sbagliato con sicurezza è peggio che non trovare niente.

La **hybrid search BM25 + embedding sull'italiano** — o, più onestamente in Postgres, ricerca lessicale più vettoriale — risolve il punto cieco a patto di curare i dettagli: due rappresentazioni testuali (una con stemming, una esatta), normalizzazione degli accenti e dei marcatori italiani, fusione per ranghi invece che per punteggi, filtri e permessi identici su entrambi i rami e applicati prima che l'indice approssimato scarti i candidati giusti. E soprattutto una valutazione su query reali, per tipo, con pochi parametri e regole spiegabili, invece di manopole tarate finché il numero sale.

Il risultato non è spettacolare in una demo. È un sistema che, quando il consulente scrive "art. 18", gli dà l'articolo 18 — e quando scrive "recesso senza penale", gli trova anche il contratto che dice "disdetta anticipata". È esattamente quello che serve.

Se il tuo RAG aziendale trova "documenti simili" invece di quelli giusti, possiamo partire dal gold set e misurare dove si perde. Trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/).

## FAQ

### Perché la ricerca con embedding sbaglia "articolo 18"?
Perché un embedding rappresenta il significato complessivo di un testo, e in quello spazio "articolo 18" e "articolo 19" sono quasi indistinguibili: stesso dominio, stessa struttura, numeri trattati come dettagli. Per le query corte con identificativi (articoli, decreti, numeri di documento) serve una ricerca lessicale che trovi la stringa esatta, combinata con quella vettoriale.

### PostgreSQL full-text usa BM25?
No. Le funzioni di ranking `ts_rank` e `ts_rank_cd` usano logiche proprie basate su frequenza e prossimità dei termini, senza la componente di rarità nel corpus tipica di BM25. Per la ricerca ibrida con fusione per ranghi (RRF) conta poco, perché si usano le posizioni e non i punteggi. Se ti serve BM25 vero, esistono estensioni per Postgres o motori di ricerca dedicati da affiancare al database.

### Cos'è la Reciprocal Rank Fusion e perché preferirla alla somma pesata?
La RRF unisce più liste di risultati usando solo le posizioni: ogni documento riceve `1/(k + rango)` per ogni lista in cui compare, e i contributi si sommano. Non richiede di normalizzare punteggi con scale diverse, ha pochi parametri (tipicamente k=60) ed è robusta: un documento primo in una lista e assente nell'altra risale comunque. La somma pesata richiede normalizzazioni e pesi molto sensibili, facili da sovra-adattare.

### Quali problemi ha la configurazione "italian" di Postgres?
Tre principali: elimina le stopword, tra cui "non", perdendo le negazioni; lo stemmer può fondere nomi propri e parole comuni; il parser tratta in modi specifici punti, barre e apostrofi, quindi riferimenti come "D.Lgs. 81/2008" o "dell'art." vanno verificati con `ts_debug`. La soluzione pratica è affiancare una rappresentazione `simple` (senza stemming né stopword) per identificativi, nomi e negazioni, e togliere gli accenti con `unaccent`.

### Come gestisco "art.", "n." e i numeri con la barra?
Con una normalizzazione esplicita applicata sia ai documenti sia alla query: trasformare "art.", "artt.", "n.", "nr." in forme uniformi, e indicizzare i numeri con la barra anche nelle loro parti ("81/2008" diventa trovabile anche come "81" e "2008"). Una breve lista di sinonimi per le fonti principali ("c.c." e "codice civile", "D.Lgs." e "decreto legislativo") è utile; un dizionario di sinonimi generico tende a peggiorare i risultati.

### Perché i filtri vanno applicati prima dell'indice vettoriale?
Perché gli indici approssimati come HNSW restituiscono un numero limitato di candidati; se il filtro (società, tipo documento, permessi) viene applicato dopo e seleziona una piccola parte del corpus, restano pochissimi risultati o quelli sbagliati. Le versioni recenti di pgvector offrono scansioni iterative che continuano a cercare finché trovano abbastanza risultati filtrati; in alternativa si usano indici parziali, partizioni o più candidati. I filtri di permesso devono essere identici su entrambi i rami della ricerca.

### Come valuto se la ricerca ibrida funziona davvero?
Con un gold set di query reali, almeno trenta, ciascuna con i documenti rilevanti indicati da chi li conosce, e metriche come nDCG@10 e Recall@20. La cosa più utile è guardare i risultati per tipo di query: identificativi, semantiche, sigle, negazioni, nomi propri. Così vedi dove ciascuna componente fallisce e se l'ibrida migliora davvero tutti i tipi.

### Quante query servono nel gold set?
Trenta query reali bastano per vedere differenze grandi tra configurazioni e per non ingannarsi a sensazione; non bastano per ottimizzare molti parametri. Per questo conviene usare pochi parametri, dividere il gold set tra una parte per decidere e una per verificare, e farlo crescere nel tempo con le query che dai log risultano problematiche.

### Serve un reranker?
Non sempre. Se il Recall@20 è buono (il documento giusto è tra i primi venti) ma l'ordine dei primi risultati no, un reranker multilingue può migliorare molto la qualità, al costo di latenza e di una GPU. Se il documento giusto non è nemmeno tra i candidati, il reranker non può recuperarlo: il problema è nella ricerca lessicale, nella normalizzazione o nei filtri.

### Quando basta la sola ricerca vettoriale?
Quando le query sono lunghe e descrittive e i documenti non contengono identificativi determinanti: domande in linguaggio naturale su procedure, manuali, FAQ. Anche in quel caso conviene misurarlo su un gold set; e se i dati da cercare sono già in campi strutturati (numero documento, data, controparte), la risposta migliore è una query su quei campi, non una ricerca nel testo.
