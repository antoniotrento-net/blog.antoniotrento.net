---
lang: it
permalink: /it/blog/pgvector-vs-qdrant-vs-pinecone/
title: "pgvector vs Qdrant vs Pinecone: il lock-in del vector DB ti costa più degli embedding (con numeri)"
date: 2026-10-03 07:30:00 +0200
author: "Antonio Trento"
description: "pgvector vs Qdrant vs Pinecone per il RAG di una PMI sovrana: cosa stai davvero comprando, TCO a 12 mesi su 1M chunk, filtri metadata, hybrid search in italiano, e come non restare ostaggio del vendor. Procurement e ops, non benchmark da tweet."
keywords: ["pgvector vs qdrant vs pinecone", "vector database lock-in", "self-hosted qdrant", "postgresql embedding", "costo pinecone", "vector db pmi"]
image: /assets/images/posts/pgvector-vs-qdrant-vs-pinecone.jpg
pillar: rag-documenti
related: [/it/blog/rag-pgvector-fattura-elettronica/, /it/blog/vllm-vs-ollama-produzione/]
---

## Il conto che nessuno ti fa: il DB costa più degli embedding

Quando parte un progetto RAG, tutti guardano il costo degli embedding: "quanto mi costa vettorializzare un milione di documenti?". Domanda legittima, ma è la domanda sbagliata come prima domanda. Perché gli embedding sono un **costo una tantum** — li calcoli una volta e sono fatti — mentre il **vector database è un costo ricorrente** che paghi ogni mese, per anni. E su un orizzonte di dodici mesi, per una PMI, la bolletta del database gestito supera spesso, e di parecchio, il costo di aver calcolato gli embedding. Il **lock-in del vector DB** ti costa più degli embedding: ecco la tesi, e sotto la dimostro con i numeri.

Questo pezzo è un confronto **pgvector vs Qdrant vs Pinecone** dal punto di vista che conta davvero per chi deve decidere: **procurement e operations, non benchmark da tweet**. Non mi interessa chi fa 2 millisecondi in meno su un dataset finto. Mi interessa: cosa stai comprando, quanto ti costa in dodici mesi, quanto è doloroso uscirne, e quale scegliere per una PMI che vuole restare sovrana sui propri dati.

Anticipo il verdetto, perché non amo tenerti sulle spine: **per la maggior parte delle PMI, la risposta è Postgres con pgvector.** Non perché sia il più veloce in assoluto, ma perché è un sistema in meno da gestire, i backup li fai già, i dati restano tuoi, e copre bene la scala reale. Qdrant self-hosted entra quando il carico di query esplode davvero. Pinecone, per una PMI sovrana, è quasi sempre un anti-pattern. Vediamo perché, con onestà.

Questo è il seguito naturale di come ho costruito il [RAG con pgvector sulla fattura elettronica]({{ '/it/blog/rag-pgvector-fattura-elettronica/' | relative_url }}): lì il "come" tecnico su pgvector, qui il "quale scegliere e perché" dal lato costi e lock-in.

## Cosa stai comprando davvero: ANN, filtri, SLA, dati

Prima dei nomi, chiariamo cosa fa un vector database, così sai cosa stai confrontando. Non stai comprando "magia AI". Stai comprando quattro cose:

- **Ricerca ANN (Approximate Nearest Neighbor).** Il cuore: dato un vettore query, trovare i vettori più simili tra milioni, in fretta. "Approssimata" perché la ricerca esatta su milioni di vettori è troppo lenta: si usa un indice (tipicamente **HNSW**, un grafo navigabile, o IVFFlat, a cluster) che trova quasi sempre i risultati giusti, molto più veloce. Il compromesso è tra *recall* (quanti dei veri vicini trovi) e *latenza*. Chi ti vende "ricerca istantanea" ti sta vendendo un compromesso non dichiarato.
- **Filtri sui metadata.** Nel mondo reale non cerchi "il vettore più simile" in astratto: cerchi "il chunk più simile, di questo cliente, di quest'anno, di tipo contratto". Il filtraggio per metadata è ciò che rende il RAG utile, e la sua qualità varia moltissimo tra i sistemi.
- **SLA e operazioni.** Backup, ripristino, replica, aggiornamenti, monitoraggio. La parte noiosa che decide se il sistema regge in produzione o ti tiene sveglio la notte.
- **I tuoi dati.** Dove stanno fisicamente, chi vi accede, quanto è facile portarli via. Per una PMI italiana con dati sensibili, questa è la voce che pesa più di tutte, e quella che i confronti tecnici ignorano.

Tieni a mente queste quattro dimensioni: è su queste che si gioca la scelta, non sui microsecondi di un benchmark.

## Postgres + pgvector: un sistema in meno, i backup li fai già

Comincio da qui perché è la risposta giusta per la maggioranza, e il motivo è **operativo**, non prestazionale.

**pgvector** è un'estensione di PostgreSQL che aggiunge il tipo `vector` e la ricerca per similarità (coseno, L2, prodotto interno), con indici HNSW e IVFFlat. Detto semplice: trasforma il Postgres che (quasi certamente) hai già in un vector database, senza aggiungere un sistema nuovo.

I vantaggi, dal lato ops e procurement:

- **Un sistema in meno.** Non installi, monitori, aggiorni e metti in sicurezza un database separato. Usi quello che già gestisci. In una PMI dove l'IT è poche persone (o una), "un sistema in meno" vale più di qualsiasi benchmark.
- **I backup li fai già.** Il tuo Postgres ha già backup, replica, procedure di ripristino. I vettori ci entrano dentro e sono coperti dalle stesse procedure. Con un vector DB separato, backup e ripristino sono un problema nuovo tutto da costruire.
- **Filtri con SQL, cioè il massimo.** Il filtraggio per metadata è una `WHERE` di SQL: potente, familiare, componibile con join, date, condizioni complesse. Nessun linguaggio di query proprietario da imparare.
- **Transazioni e coerenza.** Inserisci il documento, i suoi metadata e il suo vettore nella stessa transazione. Niente disallineamenti tra "il testo è nel DB ma il vettore no".
- **Sovranità piena.** È il tuo Postgres, sui tuoi dischi, in UE. I dati non vanno da nessuna parte.

Lo schema e la query con filtro metadata, che è l'operazione che farai mille volte al giorno:

```sql
-- Estensione + tabella con vettore e metadata
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE chunks (
    id          bigserial PRIMARY KEY,
    doc_id      text        NOT NULL,      -- ID canonico TUO (anti lock-in)
    cliente     text,
    tipo        text,
    anno        int,
    contenuto   text        NOT NULL,
    embedding   vector(1024)               -- dimensione del tuo modello
);

-- Indice HNSW per la ricerca ANN (coseno)
CREATE INDEX ON chunks USING hnsw (embedding vector_cosine_ops);

-- Ricerca con FILTRO metadata: è qui che il RAG diventa utile
SELECT doc_id, contenuto,
       1 - (embedding <=> :query_vec) AS similarita
FROM chunks
WHERE cliente = :cliente          -- filtro
  AND tipo = 'contratto'          -- filtro
  AND anno >= 2024                -- filtro
ORDER BY embedding <=> :query_vec  -- <=> = distanza coseno
LIMIT 10;
```

Nota `doc_id`: un **ID canonico tuo**, non generato dal DB. È la prima difesa contro il lock-in (ci torno). E nota quanto è naturale il filtro: è SQL, lo conosci già.

**I limiti onesti di pgvector**, perché non è la risposta a tutto:

- A **scala molto grande** (decine di milioni di vettori) e con **QPS alti** (tante query al secondo simultanee), un vector DB dedicato può gestire meglio memoria e concorrenza. Postgres non è nato per essere un motore ANN ad altissimo carico.
- La **costruzione dell'indice HNSW** su molti milioni di vettori consuma RAM e tempo. Va dimensionata.
- La messa a punto (parametri HNSW, `work_mem`) richiede di sapere cosa si fa, come per ogni tuning di Postgres.

Ma — e questo è il punto — **la scala reale della maggior parte delle PMI sta comodamente dentro pgvector.** Un milione di chunk, qualche query al secondo: pgvector li fa senza problemi su hardware modesto. Il "ma a scala Google..." è vero e irrilevante per te, se non sei a scala Google.

## Qdrant self-hosted: quando il carico di query esplode davvero

**Qdrant** è un vector database dedicato, scritto in Rust, progettato per una cosa sola: ricerca vettoriale veloce e filtrata, a scala. È **self-hostable** (Docker, tuo server), quindi resta compatibile con uno stack sovrano — a differenza di Pinecone.

Quando ha senso passare a **Qdrant self-hosted**:

- **Il carico di query esplode:** molte query al secondo, in parallelo, con latenze da tenere basse sotto pressione. Qdrant è ottimizzato per questo in modo che Postgres non è.
- **Il conteggio dei vettori cresce** oltre i comodi limiti di pgvector (molti milioni), con filtri complessi da applicare in modo efficiente.
- **Ti servono funzioni vettoriali avanzate:** quantizzazione dei vettori (scalar/product) per ridurre la RAM, gestione fine di payload e filtri, sharding.

Un setup Qdrant in Docker, sovrano, con un filtro metadata equivalente:

```yaml
# docker-compose.yml — Qdrant self-hosted
services:
  qdrant:
    image: qdrant/qdrant:latest
    restart: unless-stopped
    volumes:
      - ./qdrant_storage:/qdrant/storage   # i dati sui TUOI dischi
    # esporre solo sulla rete interna, mai pubblico
    networks: [internal]
networks:
  internal:
    internal: true
```

```python
# ricerca con filtro metadata su Qdrant
from qdrant_client import QdrantClient
from qdrant_client.models import Filter, FieldCondition, MatchValue

client = QdrantClient(url="http://qdrant:6333")

risultati = client.search(
    collection_name="chunks",
    query_vector=query_vec,
    query_filter=Filter(must=[
        FieldCondition(key="cliente", match=MatchValue(value=cliente)),
        FieldCondition(key="tipo", match=MatchValue(value="contratto")),
    ]),
    limit=10,
)
```

Il punto onesto: **Qdrant è eccellente, ma è un sistema in più.** Un altro servizio da installare, monitorare, backuppare, aggiornare, mettere in sicurezza. Quel costo operativo si giustifica *quando la scala lo richiede*, non "perché è un vector DB vero e Postgres no". Passare a Qdrant prima di averne bisogno è complessità gratuita — il classico errore di chi progetta per una scala che non arriverà.

La regola: **parti da pgvector, passa a Qdrant self-hosted quando i numeri (QPS, latenza sotto carico, milioni di vettori) dicono che pgvector non ce la fa.** E lo saprai dai log, non dalle sensazioni.

## Pinecone: parti in fretta, paghi a unità, esci col sangue

**Pinecone** è un vector database completamente gestito (SaaS). Carichi i vettori via API, e loro gestiscono tutto. Il vantaggio è reale: **velocità di partenza.** Zero installazione, zero ops, scala gestita da loro. Per un prototipo o una startup americana in corsa, ha senso.

Per una **PMI italiana sovrana**, è quasi sempre un anti-pattern, e lo dico con i motivi:

- **I dati vanno da un vendor, tipicamente extra-UE.** I tuoi vettori — che spesso permettono di ricostruire informazione sui documenti originali — stanno su un servizio che non controlli, fuori dal tuo perimetro. Per dati sensibili è il problema di sempre.
- **Non è self-hostable.** È proprietario. Non puoi prenderlo e farlo girare su un tuo server. Sei legato al servizio, punto.
- **Il prezzo è a unità/pod e cresce.** Parti economico, ma man mano che crescono vettori, dimensioni e query, la bolletta sale. E non hai la via d'uscita "lo sposto sul mio hardware".
- **L'uscita è dolorosa.** Ci torno nella sezione migrazione, ma anticipo: l'API è proprietaria, e se non hai conservato i vettori grezzi da un'altra parte, uscire significa ri-embeddare tutto. Il **costo di Pinecone** non è solo il canone: è il costo di andarsene.

Non sto dicendo che Pinecone sia un cattivo prodotto — tecnicamente è solido. Sto dicendo che il suo modello (SaaS proprietario, dati fuori, lock-in) è **strutturalmente incompatibile** con l'obiettivo di una PMI sovrana. Scegliere Pinecone "perché è quello famoso" e poi accorgersi che i dati sono fuori e che uscirne costa è l'errore che questo pezzo vuole evitarti.

## Il confronto, sulle dimensioni che contano

| Dimensione | pgvector | Qdrant (self-host) | Pinecone |
|-----------|----------|--------------------|----------|
| Sistema aggiuntivo | No (usi Postgres) | Sì | Sì (SaaS) |
| Self-hosted / sovrano | Sì | Sì | **No** |
| Backup | Quelli di Postgres | Da costruire | Del vendor |
| Filtri metadata | SQL (potente) | Ottimi | Buoni |
| Scala altissima / QPS | Limiti a scala estrema | Eccellente | Eccellente (gestito) |
| Dati dove | Tuoi, UE | Tuoi, UE | Vendor, spesso USA |
| Lock-in | Minimo | Basso | **Alto** |
| Costo | Marginale (già hai PG) | Server self-host | Canone crescente |
| Ops | Nessuna extra | Sì | Zero (per te) |

Leggilo così: se togli la colonna "scala altissima", pgvector vince su tutto ciò che conta per una PMI. E la scala altissima, per la maggior parte, non arriva. Quando arriva, Qdrant self-hosted è la risposta sovrana. Pinecone perde sulla riga che per te pesa di più — dove stanno i dati — e su quella del lock-in.

## Hybrid search e la lingua italiana

Un tema che decide la qualità del retrieval e che i confronti "puramente vettoriali" ignorano: la **hybrid search**. La ricerca vettoriale (dense) è brava a cogliere il significato, ma sbaglia sui match esatti — codici prodotto, sigle, nomi propri, numeri di legge. La ricerca testuale classica (sparse, tipo BM25) è brava esattamente lì. La hybrid le combina: prendi il meglio di entrambe.

Perché conta per l'italiano in particolare:

- I documenti italiani sono pieni di **termini esatti che l'embedding "annacqua"**: "art. 1341 c.c.", "IT-1234", "DPR 633/72". La ricerca testuale li trova precisi; quella vettoriale li avvicina ma può mancarli.
- La ricerca testuale in italiano ha bisogno di **tokenizzazione e stemming corretti**: Postgres ha la configurazione `italian` per il full-text (gestisce stopword e radici delle parole), ed è il modo pulito per fare la parte sparse dentro lo stesso DB.

Con pgvector fai hybrid **dentro Postgres**, senza sistemi aggiuntivi, combinando il full-text italiano e la similarità vettoriale, tipicamente con una fusione dei ranking (Reciprocal Rank Fusion):

```sql
-- Hybrid: unione di full-text italiano (sparse) e vettoriale (dense),
-- fuse con Reciprocal Rank Fusion (RRF).
WITH testuale AS (
    SELECT id, row_number() OVER (
             ORDER BY ts_rank(to_tsvector('italian', contenuto),
                              plainto_tsquery('italian', :q)) DESC) AS rank
    FROM chunks
    WHERE to_tsvector('italian', contenuto) @@ plainto_tsquery('italian', :q)
    LIMIT 50
),
vettoriale AS (
    SELECT id, row_number() OVER (
             ORDER BY embedding <=> :query_vec) AS rank
    FROM chunks
    ORDER BY embedding <=> :query_vec
    LIMIT 50
)
SELECT c.doc_id, c.contenuto,
       COALESCE(1.0/(60+t.rank),0) + COALESCE(1.0/(60+v.rank),0) AS score
FROM chunks c
LEFT JOIN testuale t   ON t.id = c.id
LEFT JOIN vettoriale v ON v.id = c.id
WHERE t.id IS NOT NULL OR v.id IS NOT NULL
ORDER BY score DESC
LIMIT 10;
```

Qdrant supporta anch'esso la hybrid (vettori sparse + dense). Pinecone ha le sue funzioni. Ma il punto per una PMI: **con pgvector la hybrid in italiano la fai nello stesso sistema che già hai, con la configurazione `italian` di Postgres**, senza orchestrare due motori. Un altro punto per "un sistema in meno".

## L'architettura di riferimento: il DB dietro un'interfaccia

Ecco come dispongo il livello di retrieval, e il confine che ti salva dal lock-in: **il vector DB sta dietro un'interfaccia di retrieval, l'applicazione non lo conosce.**

```
   App / Agente ──▶ ┌────────────────────────────────────┐
                    │ INTERFACCIA DI RETRIEVAL            │
                    │ retrieve(query, filtri) -> chunks   │
                    │ (l'app conosce SOLO questa)         │
                    └───────────────┬────────────────────┘
                                    ▼
             ┌──────────────────────────────────────────────┐
             │ IMPLEMENTAZIONE (sostituibile):               │
             │   pgvector  |  Qdrant  |  (Pinecone)          │
             └───────────────┬──────────────────────────────┘
                             ▼
             ┌──────────────────────────────────────────────┐
             │ FONTE DI VERITÀ (TUA, sempre):                │
             │  chunk + metadata + doc_id canonici           │
             │  + vettori grezzi archiviati                  │
             └──────────────────────────────────────────────┘
```

**Cosa NON deve fare l'applicazione (i confini):**

- Non deve chiamare direttamente l'API del vendor sparsa nel codice. Parla solo con `retrieve(query, filtri)`. Così cambiare vector DB è cambiare un'implementazione, non riscrivere l'app.
- Non deve dipendere dagli **ID generati dal vendor**: usa i tuoi `doc_id` canonici.
- Non deve trattare il vector DB come **fonte di verità**: la verità (chunk, metadata, vettori grezzi) sta in un sistema che controlli tu, così l'indice è ricostruibile.

Una semplice interfaccia in Python che rende il DB sostituibile:

```python
from typing import Protocol

class Retriever(Protocol):
    def retrieve(self, query: str, filtri: dict, k: int = 10) -> list[dict]:
        ...

class PgVectorRetriever:   # implementazione 1
    def retrieve(self, query, filtri, k=10): ...

class QdrantRetriever:     # implementazione 2, stessa interfaccia
    def retrieve(self, query, filtri, k=10): ...

# L'app usa Retriever, non sa quale c'è sotto. Migrare = cambiare una riga.
```

Questa astrazione costa poco e vale tantissimo: è la differenza tra "cambiare vector DB in un pomeriggio" e "riscrivere mezza applicazione".

## TCO a 12 mesi su 1 milione di chunk

Adesso i numeri, che è ciò che il titolo promette. Scenario: **1 milione di chunk**, embedding a 1024 dimensioni, carico da PMI (qualche query al secondo di picco). Stime dichiarate come ordini di grandezza — i prezzi cambiano, la *proporzione* no.

Prima, il costo una tantum degli **embedding** (per contestualizzare la tesi):

- 1M chunk × ~500 token = ~500M token da vettorializzare, una volta sola.
- Con un modello di embedding **self-hosted**: qualche ora di GPU, costo elettrico in euro trascurabile.
- Con un'**API di embedding**: come ordine di grandezza qualche decina di euro, **una tantum**.

Ora il costo **ricorrente** del vector DB, su 12 mesi:

| Opzione | Costo mensile (stima) | 12 mesi | Note |
|---------|----------------------|---------|------|
| **pgvector** | marginale (Postgres già presente) o piccolo VPS ~10–20 € | **~0–240 €** | i vettori stanno nel DB che hai già |
| **Qdrant self-host** | VPS/server con RAM adeguata ~20–50 € | **~240–600 €** | un server dedicato, sotto tuo controllo |
| **Pinecone** | canone gestito, ~70–100 € come stima | **~840–1.200 €** | dati fuori, cresce con scala/QPS |

Storage: 1M × 1024 dim × 4 byte ≈ 4 GB di vettori grezzi, più l'overhead dell'indice HNSW (indicativamente 2–3×). Sono numeri che stanno comodi su hardware modesto: la RAM per l'indice è la variabile da dimensionare, non un problema di costo esotico.

La lettura che dà il titolo: **gli embedding li paghi una volta (decine di euro), il vector DB gestito lo paghi ogni mese (centinaia di euro l'anno).** Su 12 mesi, il canone di Pinecone supera abbondantemente il costo una tantum degli embedding, e continua l'anno dopo, e quello dopo ancora. pgvector, che sfrutta un sistema che già paghi, azzera quasi quella voce. Ecco perché **il lock-in del vector DB costa più degli embedding**: non è una battuta, è aritmetica su 12 mesi.

E attenzione: la tabella non conta il costo *nascosto* più grande di Pinecone — il costo di uscirne. Che vediamo ora.

## Migrazione: come non restare ostaggio degli ID

Il lock-in di un vector DB non è (solo) tecnico, è di **dati e di identificatori**. Ecco come non diventare ostaggio, indipendentemente da cosa scegli oggi.

I tre principi anti-lock-in:

1. **Possiedi la fonte di verità.** Chunk, metadata e — cruciale — i **vettori grezzi** vanno archiviati in un sistema che controlli tu (fosse anche una tabella Postgres o file su disco). Se hai i vettori, migrare a un altro DB è *ricaricarli*, non *ri-calcolarli*. Se li hai solo dentro Pinecone e li cancelli localmente, per uscire devi ri-embeddare tutto: tempo e costo.
2. **Usa ID canonici tuoi.** Il `doc_id` che colleghi a ogni chunk deve essere un tuo identificatore stabile (l'ID del documento nel tuo sistema), non l'ID auto-generato dal vector DB. Così, quando migri, le relazioni con il resto della tua applicazione non si rompono: non sei "ostaggio degli ID" del vendor.
3. **Isola dietro l'interfaccia.** Come sopra: l'app parla con `retrieve()`, non con l'API del vendor. La migrazione tocca una classe, non tutto il codice.

I **criteri di uscita** — quando è ora di migrare, e la checklist per farlo senza dramma:

- **Da Pinecone verso self-hosted:** quando la bolletta cresce, o quando la sovranità dei dati diventa un requisito (spesso arriva con il primo cliente serio che chiede dove stanno i dati). Migrazione: se hai i vettori grezzi, li carichi in pgvector/Qdrant; rimappi via `doc_id`; cambi l'implementazione dietro l'interfaccia; verifichi il recall sul tuo gold set di query.
- **Da pgvector verso Qdrant:** quando i log dicono che pgvector è al limite (latenze che salgono sotto carico, QPS che non regge). Stessa procedura: rileggi i vettori dalla fonte di verità, li carichi in Qdrant, sposti l'implementazione.
- **In tutti i casi:** valida dopo la migrazione con un **set di query di riferimento** e confronta i risultati prima/dopo. Una migrazione "riuscita" che peggiora il recall non è riuscita.

Il messaggio: **la portabilità la costruisci il primo giorno, non quando vuoi migrare.** Vettori grezzi tuoi + ID canonici + interfaccia. Chi non lo fa scopre il lock-in nel momento peggiore: quando vuole andarsene e non può.

## Percorso di implementazione, a step

1. **Parti da Postgres + pgvector** se hai già Postgres (quasi sempre sì). Un'estensione, non un sistema nuovo.
2. **Archivia la fonte di verità:** chunk, metadata, `doc_id` canonici e **vettori grezzi**, sotto il tuo controllo.
3. **Metti tutto dietro un'interfaccia `retrieve()`**: l'app non conosce il vector DB.
4. **Crea l'indice HNSW** e taras i parametri sul tuo recall/latenza reali.
5. **Implementa i filtri metadata** (SQL) e, se serve precisione sui termini esatti, la **hybrid search** con la config `italian`.
6. **Misura su query reali:** costruisci un piccolo set di query di riferimento e verifica il recall.
7. **Monitora latenza e QPS** in produzione: sono i numeri che ti diranno *se e quando* serve Qdrant.
8. **Passa a Qdrant self-hosted solo se i numeri lo impongono**, riusando la fonte di verità e l'interfaccia.
9. **Evita Pinecone** salvo motivi specifici e consapevoli; se lo usi, tieni comunque i vettori grezzi fuori per non restare ostaggio.

## I fallimenti tipici e come li riconosci dai log

- **Latenza di query che sale con la crescita dei dati.** Su pgvector, se i tempi di risposta peggiorano oltre soglia man mano che i vettori crescono, è il segnale che ti avvicini al limite o che l'indice/parametri vanno rivisti. Logga la latenza per percentile (p95, p99), non la media: la media nasconde i picchi che l'utente sente.
- **Recall basso silenzioso.** Il sistema risponde veloce ma recupera i chunk sbagliati: l'indice ANN sta "approssimando" troppo. Non lo vedi dai tempi, lo vedi solo con un set di query di riferimento. Se le risposte peggiorano senza errori, sospetta il recall.
- **RAM esaurita durante la build dell'indice HNSW.** Su molti milioni di vettori, la costruzione dell'indice può saturare la memoria. Nei log di Postgres vedi errori di memoria o build lentissime. Dimensiona `maintenance_work_mem` e la RAM.
- **Disallineamento testo/vettore.** Chunk presenti senza vettore o viceversa: quasi sempre un inserimento non transazionale. Con pgvector lo eviti mettendo testo e vettore nella stessa transazione. Logga i conteggi e allarma sulle discrepanze.
- **Filtri metadata lenti.** Se le query filtrate sono lente, mancano gli indici sulle colonne di filtro (non solo su `embedding`). Un `EXPLAIN ANALYZE` te lo dice subito.
- **Costo Pinecone che sale senza che nessuno se ne accorga.** Se sei su un gestito, la bolletta cresce con i dati e le query. Monitorala come una metrica di sistema, non scoprirla a fine trimestre.

La regola: **logga latenza per percentile e recall su query di riferimento.** I tempi medi e "sembra andare bene" non ti dicono quando stai per sbattere contro un limite. I percentili e il recall sì.

## Costi: ordini di grandezza (oltre la tabella TCO)

Stime dichiarate, a complemento del TCO sopra.

- **pgvector:** costo marginale se Postgres c'è già; altrimenti un piccolo VPS in UE (pochi/decine di euro al mese). L'indice vive in RAM: dimensiona la memoria sul numero di vettori. Elettricità/calcolo trascurabili per una PMI.
- **Qdrant self-host:** un server/VPS con RAM adeguata all'indice (per 1M vettori bastano pochi GB; cresce con scala e quantizzazione che la riduce). Decine di euro al mese, sotto il tuo controllo.
- **Pinecone:** canone a unità che parte contenuto e cresce con vettori, dimensioni e QPS. Il costo vero però è il **lock-in**: la stima di uscita (ri-embedding + re-integrazione) va messa nel conto fin dall'inizio.
- **Embedding (una tantum):** self-hosted = ore di GPU, spiccioli di corrente; via API = decine di euro per 1M chunk, una volta. Sul dimensionamento GPU per i modelli self-hosted vale quanto ho scritto confrontando [vLLM vs Ollama in produzione]({{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }}).
- **Costo del non pianificare l'uscita:** se scegli un gestito proprietario senza tenere i vettori grezzi, il giorno che devi migrare paghi il ri-embedding di tutto e la riscrittura dell'integrazione. Molto più caro di aver fatto le cose portabili dal giorno uno.

## Quando NON farlo (in ciascuna direzione)

- **Non partire da Qdrant "perché è un vero vector DB"** se sei una PMI con un milione di chunk e poche query al secondo: aggiungi un sistema da gestire senza bisogno. pgvector ti basta, e Qdrant lo aggiungi quando i numeri lo chiedono.
- **Non scegliere Pinecone per un progetto sovrano** solo perché è veloce da avviare: la comodità iniziale la paghi in dati fuori e lock-in. Se ti serve partire in un pomeriggio per un prototipo usa e getta, ok; per la produzione con dati veri, no.
- **Non restare su pgvector per orgoglio** se i log dicono che sei al limite (latenze p99 che sfondano sotto carico, QPS che non regge): a quel punto Qdrant self-hosted è la scelta giusta, e insistere è masochismo.
- **Non montare un vector DB per niente:** se i documenti sono poche migliaia e le query rare, a volte una buona ricerca full-text (anche solo Postgres senza vettori) basta. Il RAG vettoriale ha senso quando la ricerca semantica serve davvero.
- **Non scegliere senza misurare sul tuo dominio:** i benchmark pubblici girano su dataset inglesi standard. Il tuo recall sull'italiano, con i tuoi filtri, misuralo tu.

## Checklist operativa prima di scegliere

- [ ] **Postgres già presente?** Se sì, valuta pgvector per primo: è un sistema in meno.
- [ ] **Fonte di verità tua:** chunk, metadata, `doc_id` canonici e **vettori grezzi** archiviati sotto il tuo controllo.
- [ ] **Interfaccia `retrieve()`** tra app e vector DB: nessuna chiamata diretta al vendor nel codice.
- [ ] **ID canonici tuoi**, mai gli ID generati dal vendor come chiave.
- [ ] **Filtri metadata** implementati e indicizzati (non solo l'indice sul vettore).
- [ ] **Hybrid search** con config `italian` se hai molti termini esatti (codici, sigle, leggi).
- [ ] **Set di query di riferimento** per misurare il recall, ora e dopo ogni migrazione.
- [ ] **Monitoraggio latenza per percentile (p95/p99) e QPS**: i numeri che dicono se serve Qdrant.
- [ ] **Dati in UE / self-hosted**; se valuti un gestito, sai dove finiscono i dati.
- [ ] **Piano di uscita** scritto: hai i vettori grezzi e sai come ricaricarli altrove.
- [ ] **TCO a 12 mesi** calcolato, canone ricorrente incluso, non solo il costo degli embedding.

## Il verdetto

Il confronto **pgvector vs Qdrant vs Pinecone**, guardato da procurement e ops invece che da un benchmark su Twitter, dà una risposta chiara per la PMI sovrana. **Parti da Postgres con pgvector:** è un sistema in meno, i backup li fai già, i filtri sono SQL, la hybrid in italiano la fai nello stesso posto, i dati restano tuoi, e copre la scala reale della quasi totalità dei casi. Il costo è marginale perché sfrutta ciò che già gestisci.

**Passa a Qdrant self-hosted quando — e solo quando — i numeri lo impongono:** milioni di vettori, query al secondo elevate, latenze da tenere sotto controllo sotto carico. È eccellente e resta sovrano, ma è un sistema in più: aggiungilo per necessità misurata, non per moda.

**Pinecone, per una PMI sovrana, è quasi sempre l'anti-pattern:** dati fuori dal tuo perimetro, proprietario, lock-in alto, e un canone che su 12 mesi supera di gran lunga il costo una tantum degli embedding — senza contare il costo, spesso ignorato, di uscirne. La velocità di partenza non vale la dipendenza.

E qualunque cosa tu scelga, costruisci la portabilità il primo giorno: vettori grezzi tuoi, ID canonici tuoi, tutto dietro un'interfaccia. Perché il lock-in non si sente quando entri, si sente quando vuoi uscire — ed è allora che scopri quanto costa davvero il vector DB, molto più degli embedding.

Se stai progettando il livello di retrieval del tuo RAG e vuoi scegliere il vector DB giusto per la tua scala reale, restando sovrano e senza legarti le mani, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Procurement e ops, non slide.

## FAQ

### pgvector è "meno serio" di un vector DB dedicato?
No, è diverso. pgvector fa ricerca vettoriale dentro Postgres con indici HNSW/IVFFlat: per la scala della maggior parte delle PMI (fino a molti milioni di vettori con carico moderato) è più che adeguato, e ti risparmia un sistema intero da gestire. Un vector DB dedicato come Qdrant serve quando il carico di query o la scala superano ciò che Postgres gestisce comodamente. "Serio" dipende dai tuoi numeri, non dall'etichetta.

### Quando devo davvero passare a Qdrant?
Quando i log te lo dicono: latenze ai percentili alti (p95/p99) che salgono sotto carico, molte query al secondo in parallelo, decine di milioni di vettori, filtri complessi da applicare in modo efficiente. Non prima. Passare a Qdrant "in anticipo" aggiunge un sistema da gestire senza beneficio. Misura, e migra quando i numeri lo impongono.

### Perché Pinecone è un problema per una PMI italiana?
Perché i tuoi vettori finiscono su un servizio gestito, tipicamente extra-UE, che non puoi self-hostare: è proprietario. Per dati sensibili è un problema di sovranità, il canone cresce con la scala, e uscirne è doloroso (API proprietaria, ri-embedding se non hai i vettori grezzi). Tecnicamente è valido, ma il suo modello è incompatibile con l'obiettivo "dati sotto il mio controllo".

### Gli embedding sono il costo principale del RAG?
No, ed è l'equivoco che il titolo smonta. Gli embedding sono un costo una tantum (decine di euro per un milione di chunk via API, spiccioli se self-hosted): li calcoli una volta. Il vector database gestito è un costo ricorrente che paghi ogni mese. Su 12 mesi, il canone di un gestito supera abbondantemente il costo degli embedding. È lì che devi guardare, non solo alla vettorializzazione.

### Cos'è la hybrid search e perché mi serve in italiano?
È la combinazione di ricerca vettoriale (coglie il significato) e ricerca testuale classica tipo BM25 (coglie i match esatti: codici, sigle, riferimenti di legge). Serve in italiano perché i documenti sono pieni di termini esatti che l'embedding "annacqua" ("art. 1341 c.c.", codici prodotto). Con pgvector la fai dentro Postgres usando la configurazione full-text `italian`, senza aggiungere un secondo motore.

### Come evito il lock-in qualunque DB scelga?
Tre mosse dal primo giorno: possiedi la fonte di verità (chunk, metadata e soprattutto i vettori grezzi in un sistema tuo, così migrare è ricaricare non ri-calcolare); usa ID canonici tuoi, non quelli generati dal vendor; metti il vector DB dietro un'interfaccia `retrieve()` così l'app non è accoppiata all'API del vendor. Con questi, cambiare DB è un pomeriggio, non un progetto.

### Quanto costa in RAM tenere un milione di vettori?
Come ordine di grandezza, 1M vettori a 1024 dimensioni sono ~4 GB grezzi, più l'overhead dell'indice HNSW (indicativamente 2–3×). Sta comodo su hardware modesto. La RAM è la variabile da dimensionare perché l'indice HNSW vive in memoria; la quantizzazione (in Qdrant) la riduce ulteriormente. Non è un costo esotico per la scala PMI.

### Posso fare tutto con pgvector e non pensarci più?
Per moltissime PMI, sì: pgvector copre la scala reale, fa filtri e hybrid, resta sovrano. "Non pensarci più" dipende dalla crescita: monitora latenza ai percentili e QPS, e se un giorno sfondano, allora valuti Qdrant. Ma partire da pgvector e restarci finché i numeri reggono è la scelta pragmatica giusta per la maggioranza.

### I benchmark pubblici mi aiutano a scegliere?
Poco. Girano su dataset standard (spesso inglesi) e misurano microsecondi che raramente sono il tuo collo di bottiglia. Ciò che conta per te è il recall sul tuo dominio in italiano, con i tuoi filtri, e la latenza sotto il tuo carico reale. Costruisci un piccolo set di query di riferimento e misura sul tuo caso: quel numero vale più di qualsiasi classifica online.

### Se parto con Pinecone per un prototipo, poi come esco?
Se hai conservato i vettori grezzi e usato ID canonici tuoi, l'uscita è: ricarichi i vettori in pgvector o Qdrant, rimappi via i tuoi ID, sposti l'implementazione dietro l'interfaccia, e validi il recall con le query di riferimento. Se invece hai lasciato tutto solo dentro Pinecone senza copia locale, devi ri-embeddare l'intero corpus: costo e tempo. Per questo la copia dei vettori grezzi va fatta dal primo giorno, anche in prototipo.
