---
layout: pillar
lang: it
permalink: /it/pillar/rag-documenti/
pillar_key: rag-documenti
section: stack-sovrano-ai
title: "RAG e documenti italiani"
description: "FatturaPA, contratti, OCR e vector DB: come interrogare 10.000 documenti italiani con citazioni corrette, senza Pinecone e senza cloud."
image: /assets/images/pillars/rag-documenti.jpg
alt_url: /en/pillar/rag-documents/
sitemap: false

---

Le aziende italiane sono fatte di documenti: fatture elettroniche XML, contratti con clausole che contano, DDT, ordini, moduli compilati a mano, PDF scansionati storti. Prima o poi qualcuno chiede di "farci domande con l'AI" o di "estrarre i dati in automatico". Funziona sempre nella demo, su dieci documenti scelti bene. Su diecimila documenti veri, in italiano, con le loro eccezioni, funziona solo se è progettato per farlo.

Questa guida raccoglie gli articoli su come si costruiscono **sistemi che leggono documenti italiani in modo affidabile**: ricerca con citazioni corrette, estrazione di campi misurata per campo e non a sensazione, identificativi validati da algoritmi e non dal modello, e un'infrastruttura che tiene i documenti in azienda.

## Il principio: la fonte vince sempre sul modello

Il filo che lega questi articoli è una gerarchia semplice. Se il dato esiste già **strutturato** (l'XML della fattura elettronica, un'anagrafica verificata, un campo del gestionale), si prende da lì e il modello non serve. Se il dato va **estratto** da un testo, il modello estrae, ma il risultato si verifica: contro il testo sorgente, contro un checksum, contro l'anagrafica. Se una risposta viene da una **ricerca**, deve citare il punto esatto del documento da cui viene, così chi legge può controllare.

Il secondo filo è che **l'italiano non è l'inglese**. Gli esempi dei tutorial sono in inglese, e molte scelte di default (come si spezza un testo, come si cerca una parola, quali modelli di embedding si usano) peggiorano sui contratti e sulle fatture italiane. "Articolo 18", "foro competente", "clausola vessatoria" sono stringhe che una ricerca solo semantica può perdere.

## I temi (e l'articolo che li affronta)

**Cercare nei documenti**

- **«Vogliamo interrogare diecimila fatture»** — RAG su PostgreSQL con pgvector, senza un vector database in cloud: [RAG con pgvector sulle fatture elettroniche]({{ '/it/blog/rag-pgvector-fattura-elettronica/' | relative_url }}).
- **«Quale vector DB scegliamo?»** — perché il lock-in del database vettoriale ti costa più degli embedding, con numeri: [pgvector vs Qdrant vs Pinecone]({{ '/it/blog/pgvector-vs-qdrant-vs-pinecone/' | relative_url }}).
- **«La ricerca semantica non trova "articolo 18"»** — ricerca ibrida lessicale più embedding sull'italiano, e come combinare i risultati: [hybrid search sull'italiano]({{ '/it/blog/hybrid-search-bm25-embedding-italiano/' | relative_url }}).
- **«Il RAG sui contratti salta le clausole»** — perché spezzare ogni 500 token fa perdere clausole vessatorie e fori competenti: [il chunking dei contratti italiani]({{ '/it/blog/chunking-contratti-italiani-rag/' | relative_url }}).

**Estrarre e misurare**

- **«L'OCR sulle fatture è al 95%»** — perché l'XML è la fonte e il PDF un fallback, e come si misura davvero: [OCR e fattura elettronica]({{ '/it/blog/ocr-fattura-elettronica-accuratezza/' | relative_url }}).
- **«Il fornitore dice 95% di accuratezza»** — metriche per campo, pesi per costo dell'errore, campioni e intervalli, e come scoprire che è un 60% sugli importi: [l'accuratezza dell'estrazione per campo]({{ '/it/blog/accuratezza-estrazione-documenti-campi/' | relative_url }}).
- **«Il modello ha completato un codice fiscale che non c'era»** — validatori deterministici di IBAN, codice fiscale e partita IVA davanti al modello, e la regola che vieta di inventare: [la validazione degli identificativi]({{ '/it/blog/validazione-iban-codice-fiscale-partita-iva/' | relative_url }}).

## Il pezzo che decide tutto: il gold set

In quasi tutti questi articoli c'è un oggetto che i progetti saltano e che decide se il sistema funziona: il **gold set**. Sono qualche centinaio di documenti veri, con le risposte giuste inserite da chi li conosce, cioè l'amministrazione o l'ufficio legale, non chi sviluppa. Senza gold set non sai se la ricerca trova la clausola giusta, se l'estrazione legge bene gli importi, se l'ultima modifica al prompt ha migliorato o peggiorato le cose. Con il gold set, ogni discussione sulla qualità diventa una tabella.

Costa qualche giorno di lavoro di persone che hanno altro da fare, ed è per questo che viene rimandato. È anche l'investimento con il ritorno più alto di tutto il progetto.

## Dove vivono i documenti

Contratti e fatture sono tra i dati più sensibili di un'azienda. Le architetture di questa guida partono tutte da un default: **documenti, indici e modelli su infrastruttura dell'azienda o in UE**, sotto il suo controllo. Per i conti tra modello locale e modello in cloud c'è la guida su [modelli, costi e privacy]({{ '/it/pillar/modelli-costi-privacy/' | relative_url }}). Per i documenti che arrivano via PEC o da gestionali vecchi, la guida su [integrazioni e dati legacy]({{ '/it/pillar/integrazioni-dati/' | relative_url }}).

## Come usare questa guida

Parti dal tuo tipo di documento e dalla tua domanda: devi *trovare* un'informazione (ricerca) o *portarla* in un altro sistema (estrazione)? Ogni articolo ha un'architettura di riferimento, un percorso a step, i fallimenti tipici con le righe di log che li rivelano, i costi in ordine di grandezza e una sezione su quando non serve un modello. Spesso, se c'è un XML, la risposta è leggere l'XML.

Se vuoi capire quanto valgono davvero i *tuoi* documenti per un sistema di ricerca o di estrazione, e come misurarlo prima di comprarlo, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi da [contatti]({{ site.main_site }}/contatti/).

Qui sotto trovi tutti gli articoli di questa guida.
