---
lang: it
permalink: /it/blog/chunking-contratti-italiani-rag/
title: "Chunking di contratti italiani: perché spezzare ogni 500 token ti fa perdere clausole vessatorie e fori competenti"
date: 2026-09-28 07:30:00 +0200
author: "Antonio Trento"
description: "Chunking di contratti italiani per RAG: perché lo split a lunghezza fissa distrugge rinvii, clausole vessatorie e foro competente, e come costruire uno splitter per articoli e commi con overlap e metadata che regge le query legali."
keywords: ["chunking contratti italiani rag", "clausole vessatorie nlp", "rag legale", "overlap chunk", "recursive split pdf", "nlp testi giuridici italiani"]
image: /assets/images/posts/chunking-contratti-italiani-rag.jpg
pillar: rag-documenti
related: [/it/blog/rag-pgvector-fattura-elettronica/, /it/blog/eu-ai-act-pmi-agenti-2026/]
---

## "Salvo quanto previsto all'art. 7" — e l'art. 7 è in un altro chunk

Ti mostro il modo più veloce per costruire un RAG legale che sembra funzionare in demo e ti tradisce in produzione: prendi i PDF dei contratti, li spezzi ogni 500 token con lo splitter di default, li embeddi, e chiedi al modello "qual è il foro competente?". In demo risponde. Poi arriva la query vera — *"posso recedere anticipatamente senza penale?"* — e il modello ti dà una risposta sicura e sbagliata, perché la clausola diceva *"il recesso è libero, salvo quanto previsto all'art. 7"*, e l'art. 7 (che impone una penale del 30%) è finito in un chunk diverso, mai recuperato. Il modello ha letto metà clausola e ha completato con fiducia. In un contratto, metà clausola è peggio di nessuna clausola.

Questo è il tema: il **chunking di contratti italiani per RAG** non è lo stesso problema del chunking di un blog o di una knowledge base. Un contratto ha una struttura rigida (articoli, commi, richiami incrociati, allegati) e un linguaggio dove una singola congiunzione — *"salvo", "fermo restando", "in deroga a"* — ribalta il senso. Spezzarlo a lunghezza fissa, come fa lo splitter naive, distrugge esattamente ciò che rende un contratto un contratto: i rinvii e i confini tra le norme.

Vediamo come si fa sul serio: splitter per articoli e commi, overlap intelligente, uno schema di metadata pensato per i testi giuridici, e la valutazione con un avvocato nel loop. E soprattutto — perché è la parte che quasi tutti saltano — **cosa non devi mai chiedere a questo sistema.**

**Disclaimer, subito e chiaro:** non sono un avvocato. Questo è un pezzo di ingegneria su come indicizzare e recuperare testi contrattuali, non su come interpretarli. Il RAG legale di cui parlo è uno strumento per *trovare e citare* clausole, non per *sostituire* un parere legale. Torno su questo confine più avanti, perché è dove si fanno i danni veri.

## Il contratto non è un blog post: struttura e rinvii

Un articolo di blog è lineare: lo leggi dall'alto in basso, ogni paragrafo si capisce quasi da solo. Un contratto no. Un contratto è un **grafo**, non un testo lineare. Le sue caratteristiche strutturali sono precise:

- **Gerarchia rigida:** Premesse → Articoli (Art. 1 – Oggetto, Art. 2 – Durata…) → commi (numerati o lettere) → capoversi → Allegati.
- **Rinvii incrociati continui:** *"ai sensi dell'art. 4", "fatto salvo quanto previsto al comma 3", "come da Allegato B", "in deroga all'art. 9"*. Una clausola spesso non ha senso senza quella a cui rimanda.
- **Linguaggio condizionale denso:** *"salvo che", "ferma restando", "a condizione che", "salvo il caso in cui"*. Il senso di una frase dipende da una subordinata che può stare 30 parole dopo.
- **Clausole a peso enorme e testo minimo:** la clausola sul foro competente è una riga. La clausola sulla penale è due righe. Ma pesano più di intere pagine di premesse.
- **Elementi para-testuali giuridicamente vincolanti:** data, firme, sigle su ogni pagina, e — cruciale in Italia — la **doppia sottoscrizione** delle clausole vessatorie ex art. 1341 comma 2 c.c.

Chi fa **NLP su testi giuridici italiani** deve trattare questa struttura come dato primario, non come rumore da appiattire. Il chunk giusto per un contratto non è "un blocco di N token": è **un'unità di senso giuridico** — tipicamente un articolo o un comma — con i suoi confini e i suoi rinvii preservati.

Questo è lo stesso principio con cui ho costruito l'ingest della fattura elettronica: rispettare la struttura del documento invece di trattarlo come testo piatto. Nel pezzo su come indicizzo il {{ '/it/blog/rag-pgvector-fattura-elettronica/' | relative_url }} il vincolo era l'XML FatturaPA; qui è la struttura articolo/comma. Cambia il formato, non il principio: **la struttura è informazione, buttarla è perdere qualità.**

## Gli errori dello splitter naive (e perché sembrano innocui)

Lo splitter di default — quello che trovi in ogni tutorial — fa una di queste due cose, entrambe sbagliate per un contratto.

**Errore 1: split a lunghezza fissa (500 token, 1000 caratteri).** Taglia il testo ogni N unità, ignorando i confini semantici. Risultato:

- Tronca clausole a metà. La subordinata *"salvo quanto previsto all'art. 7"* finisce in un chunk, la principale nell'altro.
- Separa il rinvio dal suo bersaglio. Il chunk che dice "in deroga all'art. 9" non contiene l'art. 9, e il retrieval potrebbe non recuperarlo.
- Mescola la fine di un articolo con l'inizio del successivo: un chunk che è metà "Durata" e metà "Recesso", che non risponde bene a nessuna delle due query.

**Errore 2: split su header markdown inesistenti.** Molti splitter "strutturali" cercano gli header markdown (`#`, `##`). Un PDF di contratto **non ha header markdown.** Ha "Art. 1", "Articolo 2 – Oggetto", "1.", "a)", numerazioni che il PDF rende come testo normale. Lo splitter markdown-aware, su un contratto, si comporta esattamente come quello a lunghezza fissa: non trova header, taglia a caso.

La cosa insidiosa è che **in demo non te ne accorgi.** Le query facili ("chi sono le parti?", "che oggetto ha il contratto?") pescano dalle premesse, che sono lineari e sopravvivono a qualsiasi split. È sulle query che contano — recesso, penale, foro, durata, deroghe — che il sistema crolla, perché quelle vivono in clausole precise, spesso con rinvii. E sono proprio le query per cui qualcuno userebbe un RAG legale.

Ecco un esempio concreto di **chunk cattivo vs buono** sulla stessa clausola.

**Chunk cattivo** (split a 500 token, tagliato a metà frase):

```
...la fornitura avrà durata di 24 (ventiquattro) mesi decorrenti
dalla data di sottoscrizione. Il Cliente ha facoltà di recedere
anticipatamente dandone comunicazione scritta con preavviso di
30 giorni, salvo quanto
--- FINE CHUNK ---
```

Il chunk successivo comincia con "previsto all'art. 7 in materia di penali...", ma nulla garantisce che venga recuperato insieme. Il modello legge "recesso libero con 30 giorni di preavviso" e risponde di conseguenza. Sbagliando.

**Chunk buono** (split per articolo, clausola intera + rinvio risolto nei metadata):

```
[Art. 5 – Durata e recesso]
La fornitura avrà durata di 24 (ventiquattro) mesi decorrenti dalla
data di sottoscrizione. Il Cliente ha facoltà di recedere
anticipatamente dandone comunicazione scritta con preavviso di 30
giorni, salvo quanto previsto all'art. 7 (Penali).
[rinvii: art. 7]
```

Il chunk è un'unità completa, il rinvio è esplicito nei metadata, e a runtime posso recuperare *anche* l'art. 7 perché so che serve. Questa è la differenza tra un RAG legale che aiuta e uno che mente.

## Splitter per articoli e commi, con overlap intelligente

La strategia è: **prima identifica la struttura, poi spezza sui confini strutturali**, non sulla lunghezza. Solo se un articolo è troppo lungo per l'embedding, lo suddividi ulteriormente per commi, mantenendo l'intestazione dell'articolo in ogni sotto-chunk.

Un parser strutturale minimo per contratti italiani:

```python
import re
from dataclasses import dataclass, field

# Riconosce "Art. 5", "Articolo 5", "ART. 5 -", "5. " a inizio riga
RE_ARTICOLO = re.compile(
    r"^\s*(?:art(?:icolo)?\.?\s*)(\d+)\s*[\.\-–—:]?\s*(.*)$",
    re.IGNORECASE | re.MULTILINE,
)
# Riconosce commi: "1.", "2)", "a)", "1-bis"
RE_COMMA = re.compile(r"^\s*(\d+(?:-bis|-ter)?[\.\)]|[a-z]\))\s+", re.MULTILINE)
# Rinvii incrociati da estrarre nei metadata
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
    """Spezza per articolo; ogni chunk è un'unità di senso, non 500 token."""
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
            if (a and int(a) != num) or b     # no auto-rinvio
        })
        chunks.append(Chunk(num, titolo, corpo, rinvii))
    return chunks
```

Poi, per gli articoli troppo lunghi, la suddivisione per commi con **overlap intelligente** — che non è "sovrapponi 50 token a caso", ma "ripeti l'intestazione dell'articolo e l'ultimo comma precedente":

```python
MAX_CHAR = 1800   # sotto il limite comodo per l'embedding

def split_lungo(chunk: Chunk) -> list[Chunk]:
    if len(chunk.testo) <= MAX_CHAR:
        return [chunk]
    commi = RE_COMMA.split(chunk.testo)
    intestazione = f"[Art. {chunk.articolo} – {chunk.titolo}]"
    out, buff = [], intestazione
    for pezzo in commi:
        if len(buff) + len(pezzo) > MAX_CHAR and buff != intestazione:
            out.append(Chunk(chunk.articolo, chunk.titolo, buff, chunk.rinvii))
            # overlap SEMANTICO: ogni sotto-chunk riparte dall'intestazione
            buff = intestazione + " " + pezzo
        else:
            buff += " " + pezzo
    out.append(Chunk(chunk.articolo, chunk.titolo, buff, chunk.rinvii))
    return out
```

Il punto sull'**overlap chunk**: nell'NLP generico l'overlap serve a non perdere frasi tagliate al confine. Nei contratti serve a qualcosa di più mirato — **non staccare mai un comma dalla sua intestazione di articolo**. Un comma che dice "il recesso non è ammesso" è inutile se non sai a quale articolo appartiene. L'intestazione ripetuta è l'overlap che conta. È mirato, non a lunghezza fissa: costa pochi token e salva il senso.

La differenza tra i due approcci, in tabella:

| Aspetto | Splitter naive (500 token) | Splitter strutturale |
|---------|---------------------------|----------------------|
| Confine di taglio | lunghezza fissa | articolo / comma |
| Clausole troncate | frequenti | mai (unità intere) |
| Rinvii preservati | no | sì, nei metadata |
| Intestazione articolo | persa nei sotto-blocchi | ripetuta (overlap) |
| Query su clausole precise | inaffidabile | affidabile |
| Costo di sviluppo | zero | qualche giornata |

## Metadata: parte, data, versione, firma, allegato

Il testo del chunk non basta. Nei contratti, il **contesto** è metà dell'informazione, e va nei metadata — sia per filtrare a runtime, sia per citare la fonte esatta. Lo schema che uso:

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

Perché ogni campo guadagna il suo posto:

- **`parti`, `data_stipula`, `versione`:** senza questi, un RAG con più versioni dello stesso contratto risponde citando la versione sbagliata. Il filtro per versione è obbligatorio, non opzionale.
- **`firmato`, `doppia_sottoscrizione_1341`:** in Italia una **clausola vessatoria** (foro esclusivo, limitazioni di responsabilità, recesso, penali) è inefficace se non specificamente approvata per iscritto ex art. 1341 c.c. Sapere se c'è la doppia firma cambia la risposta. È un dato di rilievo giuridico che il testo da solo non cattura.
- **`rinvii`:** permette il retrieval a due passi (recupero l'art. 5, vedo che rimanda all'art. 7, recupero anche quello).
- **`clausola_sensibile`:** etichette che permettono query mirate ("mostrami tutte le penali di questo contratto") e alzano la soglia di attenzione nella risposta.
- **`hash_documento`, `pagina`:** per la citazione verificabile — il RAG deve poter dire "art. 5, pag. 3 del documento X", così l'umano va a controllare la fonte.

La regola: **ogni risposta del RAG legale deve poter puntare all'articolo, alla pagina e alla versione esatta.** Un RAG che risponde senza citare la fonte precisa, in ambito contrattuale, è inutilizzabile — perché nessuno agirà su una clausola senza verificarla.

## L'architettura di riferimento

Ecco la pipeline completa, con i confini disegnati dove servono. Nota il vincolo di sovranità: contratti sono dati riservati, restano self-hosted o in UE sotto controllo del cliente, mai su un SaaS generico.

```
   PDF contratto ──▶ ┌──────────────────────────────────┐
                     │ 1. TRIAGE: digitale o scansito?    │
                     │    testo estraibile → via diretta  │
                     │    immagine → OCR                  │
                     └───────────────┬────────────────────┘
                                     ▼
                     ┌──────────────────────────────────┐
                     │ 2. PARSER STRUTTURALE              │
                     │    articoli, commi, allegati,      │
                     │    rinvii, firme, doppia sottoscr. │
                     └───────────────┬────────────────────┘
                                     ▼
                     ┌──────────────────────────────────┐
                     │ 3. CHUNKING per articolo/comma     │
                     │    + overlap intestazione          │
                     │    + metadata completi             │
                     └───────────────┬────────────────────┘
                                     ▼
                     ┌──────────────────────────────────┐
                     │ 4. EMBEDDING + pgvector (UE)       │
                     └───────────────┬────────────────────┘
                                     ▼
                     ┌──────────────────────────────────┐
                     │ 5. RETRIEVAL: query → chunk +      │
                     │    espansione rinvii (2 passi)     │
                     └───────────────┬────────────────────┘
                                     ▼
                     ┌──────────────────────────────────┐
                     │ 6. LLM: risponde SOLO citando i    │
                     │    chunk, con articolo/pag/versione│
                     └───────────────┬────────────────────┘
                                     ▼
                     ┌──────────────────────────────────┐
                     │ 7. AVVOCATO nel loop per decisioni │
                     └──────────────────────────────────┘
```

**Cosa NON fa mai il sistema** (i confini che scrivi in chiaro):

- Non dà **pareri legali**. Trova e cita clausole. L'interpretazione è dell'avvocato.
- Non **inventa** clausole assenti. Se non trova, dice "non trovato", non completa.
- Non **decide** (firmare, recedere, contestare). Propone dove guardare.
- Non fa uscire i contratti verso servizi esterni non controllati.

Questa impostazione — modello che recupera e cita, umano che interpreta e decide — è la stessa filosofia di sicurezza e conformità che ho descritto per il {{ '/it/blog/eu-ai-act-pmi-agenti-2026/' | relative_url }}: l'AI propone, l'esperto dispone. In ambito legale il confine è ancora più netto, perché un errore d'interpretazione ha conseguenze contrattuali reali.

## Percorso di implementazione, a step

1. **Raccogli un campione rappresentativo:** 20–30 contratti dei tipi che tratti (NDA, preliminari, SLA, forniture), sia digitali sia scansiti.
2. **Costruisci il triage digitale/OCR** e verificalo a mano su ogni tipo: l'OCR sui contratti scansiti è il punto più fragile (vedi sotto).
3. **Implementa il parser strutturale** e valida che riconosca articoli e commi su *tutti* i formati del campione. I contratti sono redatti da studi diversi: la numerazione varia ("Art. 1", "Articolo 1", "1."). Il parser deve reggere le varianti.
4. **Genera i chunk con metadata** e ispezionane un campione a occhio: cerca clausole troncate, rinvii persi, intestazioni mancanti.
5. **Embedda e indicizza** in pgvector, con i metadata come colonne filtrabili (versione, tipo, parti).
6. **Implementa il retrieval a due passi:** recupera i chunk per la query, poi espandi seguendo i `rinvii` dei chunk trovati.
7. **Vincola il prompt** a rispondere solo dai chunk recuperati, citando articolo/pagina/versione, e a dire "non trovato" quando manca.
8. **Costruisci il gold set con l'avvocato** (sotto) e misura prima di andare in produzione.

## Query tipiche e come reggono

Le query per cui un RAG legale esiste davvero, e cosa serve perché funzionino:

| Query tipica | Cosa deve recuperare | Rischio se il chunking è naive |
|--------------|----------------------|-------------------------------|
| "Posso recedere e con che preavviso?" | Art. recesso + rinvii a penali | Perde la penale rinviata |
| "Qual è il foro competente?" | Clausola foro + doppia firma 1341 | Non sa se è efficace |
| "C'è una penale? Di quanto?" | Art. penale + base di calcolo | Trova la % ma non la base |
| "Quanto dura l'NDA dopo la fine?" | Durata obblighi post-contrattuali | Confonde durata contratto e obblighi |
| "Ci sono limitazioni di responsabilità?" | Clausole limitative + 1341 | Le tratta come clausole normali |

Il filo comune: **le query legali toccano quasi sempre clausole con rinvii o con rilevanza vessatoria.** È esattamente ciò che lo splitter naive distrugge. Un RAG legale si giudica su queste query, non su "chi sono le parti".

## Una query reale, passo per passo: "posso recedere senza penale?"

Vediamo il retrieval a due passi al lavoro su una query insidiosa, perché è qui che il chunking strutturale ripaga o crolla. La domanda dell'utente: *"posso recedere anticipatamente e devo pagare qualcosa?"*.

**Passo 1 — retrieval sulla query.** La ricerca vettoriale pesca i chunk semanticamente vicini. Trova l'Art. 5 (Durata e recesso), che dice: *"Il Cliente ha facoltà di recedere con preavviso di 30 giorni, salvo quanto previsto all'art. 7"*. Uno splitter naive si fermerebbe qui, e il modello risponderebbe: *"Sì, può recedere con 30 giorni di preavviso"* — vero a metà, quindi falso.

**Passo 2 — espansione dei rinvii.** Il chunk dell'Art. 5 ha nei metadata `"rinvii": ["art.7"]`. Il sistema, prima di generare, recupera *anche* l'Art. 7, che recita: *"In caso di recesso anticipato è dovuta una penale pari al 30% del corrispettivo residuo"*. Ora il modello ha entrambi i pezzi in contesto.

**Passo 3 — generazione vincolata.** Il modello risponde citando le fonti: *"Il recesso anticipato è ammesso con preavviso di 30 giorni (Art. 5), ma comporta una penale del 30% del corrispettivo residuo (Art. 7, pag. 4, versione 2.1). Verificare con un legale."* Questa risposta è utile perché è **completa e citata**.

La lezione: senza il chunking strutturale non avresti avuto il rinvio nei metadata; senza il retrieval a due passi non avresti recuperato l'Art. 7; senza il vincolo di citazione non avresti saputo da dove viene la risposta. I tre pezzi lavorano insieme. Togline uno e il sistema torna a mentire con sicurezza — la modalità di errore peggiore, perché è la più convincente.

## Valutazione con l'avvocato nel loop: il gold set

Qui separo i progetti seri dai giocattoli. Un RAG legale **non si valuta a sensazione.** Si costruisce un *gold set*: un insieme di domande reali con la risposta corretta e la citazione esatta, verificate da un avvocato. Poi si misura il sistema contro quel gold set a ogni modifica (nuovo modello, nuovo splitter, nuovo prompt).

Come lo costruisco:

- 30–50 domande sui contratti campione, dalle più semplici alle più insidiose (quelle con rinvii e deroghe).
- Per ognuna, l'avvocato indica: la risposta corretta, l'articolo/i che la contengono, e se ci sono trappole (clausole vessatorie non firmate, rinvii che ribaltano il senso).
- Si misurano due cose: **retrieval** (il sistema ha recuperato i chunk giusti?) e **fedeltà** (la risposta si basa solo su quei chunk, senza inventare?).

```python
def valuta(gold, sistema):
    hit, faithful = 0, 0
    for caso in gold:
        recuperati = sistema.retrieve(caso["domanda"])
        ids = {c["chunk_id"] for c in recuperati}
        # retrieval: ho preso gli articoli attesi (rinvii inclusi)?
        if set(caso["chunk_attesi"]).issubset(ids):
            hit += 1
        risposta = sistema.answer(caso["domanda"], recuperati)
        # fedeltà: nessuna affermazione fuori dai chunk citati
        if risposta["citazioni"] and not risposta["inventato"]:
            faithful += 1
    n = len(gold)
    print(f"retrieval@k: {hit/n:.0%}  fedeltà: {faithful/n:.0%}")
```

La regola che consegno: **finché il retrieval sul gold set non supera una soglia alta (e le domande con rinvii sono quelle da guardare per prime), il sistema non va vicino a un utente.** E l'avvocato non è un revisore una tantum: è nel loop, perché è l'unico che sa se una risposta "plausibile" è giuridicamente giusta.

## Cosa NON chiedere mai al RAG legale

Questa sezione dovrebbe stare in cima, ma la metto qui perché ora hai il contesto per capirla. Il RAG legale è uno strumento di **retrieval assistito**, non un avvocato. Le cose che non deve mai fare:

- **Dare un parere legale sostitutivo.** *"Questo contratto mi conviene?"* non è una domanda da RAG. È interpretazione, valutazione del rischio, strategia — roba da avvocato. Il RAG può dirti *dove* sta scritto il recesso, non *se* ti conviene esercitarlo.
- **Decidere azioni.** *"Devo firmare?"* / *"Recedo?"* → no. Il RAG trova e cita; l'umano decide.
- **Interpretare clausole ambigue.** Quando una clausola è oscura, la risposta giusta è "questa clausola è ambigua, chiedi all'avvocato", non un'interpretazione inventata con tono sicuro.
- **Valutare la validità di clausole vessatorie.** Il RAG può segnalare "questa è una clausola potenzialmente vessatoria e non risulta la doppia sottoscrizione", il che è utilissimo — ma la conclusione sull'efficacia è dell'avvocato.
- **Confondere "non trovato" con "non esiste".** Se il sistema non recupera una clausola, deve dire "non ho trovato", non "non è previsto". In un contratto sono cose diverse e la seconda è pericolosa.

Il **disclaimer sul ruolo dell'AI** va scritto nell'interfaccia, non solo nella tua testa: *"Questo strumento aiuta a trovare e citare clausole nei contratti caricati. Non fornisce pareri legali. Le decisioni contrattuali richiedono la valutazione di un professionista."* Non è burocrazia: è la linea che impedisce a qualcuno di prendere una decisione da migliaia di euro fidandosi di un retrieval.

## Pipeline da PDF scansito (OCR) vs digitale

Metà dei contratti reali arriva come **PDF scansito** — la copia firmata, passata allo scanner. E l'OCR è dove il tuo bel parser strutturale muore in silenzio, se non stai attento.

Il triage è il primo passo: distingui PDF con testo estraibile da PDF-immagine.

```python
from pypdf import PdfReader

def serve_ocr(path: str, soglia_char_pagina: int = 100) -> bool:
    reader = PdfReader(path)
    tot = sum(len((p.extract_text() or "")) for p in reader.pages)
    media = tot / max(len(reader.pages), 1)
    # poche decine di caratteri a pagina = quasi certamente scansito
    return media < soglia_char_pagina
```

Se serve OCR, i vincoli specifici dei contratti italiani:

- **Usa un OCR self-hosted** (es. Tesseract con lingua `ita`, o motori più moderni in container). I contratti non salgono su un OCR cloud generico: sono dati riservati. Default sovrano, sempre.
- **L'OCR sbaglia numeri e articoli.** "Art. 7" diventa "Art. 1" o "Art. Z", i commi si confondono. Il parser strutturale, che si basa sulla numerazione, va in tilt. Serve un passo di **normalizzazione post-OCR** che ricostruisca la sequenza degli articoli (devono essere crescenti; un salto o un doppione è un errore OCR da correggere o segnalare).
- **La qualità della scansione è variabile.** Timbri, firme e sigle sovrapposte al testo confondono l'OCR. Questi punti — spesso proprio le clausole vessatorie con la doppia firma — sono i più delicati.
- **Segnala sempre l'origine** nei metadata (`"origine": "ocr"`). Una risposta basata su un chunk da OCR va marcata come "da verificare sull'originale", perché la fedeltà del testo non è garantita.

Regola operativa: **un contratto OCR non ha lo stesso grado di fiducia di uno digitale.** Se il documento firmato conta (e in un contenzioso conta sempre), la citazione del RAG deve rimandare all'originale scansito, e l'avvocato guarda quello, non il testo estratto.

## I fallimenti tipici e come li riconosci dai log

- **Retrieval che non recupera mai gli articoli-bersaglio dei rinvii.** Se logghi, per ogni query, i `chunk_id` recuperati e li confronti con i rinvii dei chunk trovati, vedi quando il sistema recupera l'art. 5 ma non l'art. 7 a cui rimanda. È il fallimento numero uno del RAG legale. Log: `query`, `chunk_recuperati`, `rinvii_non_seguiti`.
- **Risposte senza citazione.** Se una risposta non contiene articolo/pagina/versione, è per definizione inaffidabile. Logga la presenza/assenza di citazioni e allarma sulle assenze.
- **"Non previsto" al posto di "non trovato".** Cerca nei log le risposte che negano l'esistenza di una clausola: incrociale col gold set. Spesso è retrieval fallito travestito da risposta sicura.
- **Numerazione articoli non monotòna dopo l'OCR.** Se il parser produce articoli fuori sequenza (1, 2, 4, 3, 7…), hai un errore OCR o di parsing. Logga la sequenza estratta per documento e allarma sui salti.
- **Versione ambigua.** Se il retrieval pesca chunk di due versioni diverse dello stesso contratto per la stessa query, la risposta mescola testi incompatibili. Logga la `versione` dei chunk recuperati: devono essere coerenti.
- **Chunk troppo lunghi che superano il limite di embedding.** Un articolo enorme non suddiviso viene troncato dall'embedder e perde la coda. Logga la lunghezza dei chunk e la percentuale vicina al limite.

La regola vale come per ogni RAG: **logga il retrieval, non solo la risposta.** In ambito legale, il 90% dei problemi è "non ho recuperato la clausola giusta", e lo vedi solo se logghi cosa hai recuperato e cosa avresti dovuto.

## Costi: ordini di grandezza

Stime dichiarate, per un corpus di qualche migliaio di contratti (PMI, studio, ufficio legale interno).

- **Sviluppo pipeline** (parser strutturale + chunking + metadata + retrieval a due passi + OCR): come ordine di grandezza **1–3 settimane/uomo**, la parte OCR e la normalizzazione post-OCR sono le più costose se hai molti scansiti.
- **Embedding del corpus:** con un modello di embedding self-hosted, migliaia di contratti sono ore di calcolo su una GPU media, una tantum. Se usi un'API di embedding, qualche decina di euro per l'intero corpus (stima, dipende dal numero di token).
- **VRAM:** un buon modello di embedding gira in **8–16 GB**; il generativo per le risposte dipende dalle scelte (self-hosted 7–14B in 16–24 GB, o API). Ho confrontato le opzioni self-hosted per il servire in produzione nel pezzo su {{ '/it/pillar/modelli-costi-privacy/' | relative_url }}.
- **Costo per query:** retrieval è economico (query vettoriale su pgvector, millisecondi). Il costo è la generazione: qualche centesimo per risposta con un modello self-hosted, un po' di più con API cloud EU.
- **Costo del gold set:** il tempo dell'avvocato per costruire e validare 30–50 casi. È un investimento, non una spesa accessoria: senza gold set non sai se il sistema funziona.

Il confronto onesto: **il costo dominante non è il calcolo, è il tempo dell'avvocato per la validazione.** Ed è giusto così — è ciò che rende il sistema affidabile invece che pericoloso.

## Quando NON farlo

- **Se il volume di contratti è basso** (poche decine, letti raramente), un RAG legale è overkill. Una cartella ben organizzata e la ricerca full-text bastano. Automatizza quando il volume e la frequenza lo giustificano.
- **Se non hai un avvocato disponibile per il gold set e il loop**, non costruirlo per query decisionali. Un RAG legale senza validazione professionale è un generatore di false certezze.
- **Se i contratti sono quasi tutti scansiti di pessima qualità**, valuta prima un progetto di digitalizzazione: costruire un RAG su OCR inaffidabile significa costruire su sabbia.
- **Se l'obiettivo reale è "dare pareri automatici"**, fermati: non è un problema di chunking, è un confine che non va passato. Il RAG trova e cita; non sostituisce il giudizio legale.
- **Se non puoi garantire l'hosting sovrano**, ripensa il progetto: i contratti sono tra i dati più sensibili di un'azienda e non vanno su servizi non controllati.

## Checklist operativa prima di andare live

- [ ] **Triage digitale/OCR** funzionante e verificato su ogni tipo di contratto.
- [ ] **Parser strutturale** che riconosce articoli e commi su tutte le varianti di numerazione del campione.
- [ ] **Chunk per articolo/comma**, mai a lunghezza fissa; nessuna clausola troncata a campione ispezionato.
- [ ] **Overlap = intestazione articolo ripetuta** in ogni sotto-chunk.
- [ ] **Metadata completi:** parti, data, versione, firma, doppia sottoscrizione 1341, rinvii, pagina, origine.
- [ ] **Retrieval a due passi** che segue i rinvii incrociati.
- [ ] **Prompt vincolato** a citare articolo/pagina/versione e a dire "non trovato".
- [ ] **Gold set** validato dall'avvocato; retrieval sopra soglia sulle query con rinvii.
- [ ] **Disclaimer sul ruolo dell'AI** visibile nell'interfaccia.
- [ ] **Chunk da OCR marcati** come "da verificare sull'originale".
- [ ] **Hosting sovrano** (self-hosted / UE), contratti mai su servizi non controllati.
- [ ] **Log di retrieval** completi: query, chunk recuperati, rinvii non seguiti, versione.

## Il verdetto

Il **chunking di contratti italiani per RAG** è il punto dove si decide se costruisci uno strumento utile o una macchina per false certezze. Lo splitter a 500 token è comodo, gratis e sbagliato: taglia le clausole a metà, separa i rinvii dai loro bersagli, e produce un sistema che risponde con sicurezza a domande su cui ha letto solo metà del testo. In un blog è un fastidio. In un contratto è un rischio economico.

La strada giusta non è complicata, è solo *diversa*: rispetta la struttura. Spezza per articolo e comma, non per lunghezza. Tieni l'intestazione attaccata al comma. Metti i rinvii nei metadata e seguili a runtime. Registra parti, versione, firma e doppia sottoscrizione, perché in Italia una clausola vessatoria non firmata non vale, e il tuo sistema deve saperlo. Valuta con un avvocato e un gold set, non a sensazione. E marca sempre il confine: **il RAG legale trova e cita, non interpreta e non decide.**

Fatto così, è uno strumento che fa risparmiare ore a chi deve trovare la clausola giusta in cento contratti. Fatto con lo splitter di default, è un collega troppo sicuro di sé che ha letto metà pagina. La differenza non è il modello. È se hai trattato il contratto per quello che è: un grafo di norme con rinvii, non un blog post da spezzare a fette uguali.

Se stai costruendo un RAG sui tuoi contratti e vuoi che regga le query che contano — recesso, penale, foro, deroghe — senza inventare, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Ingegneria del retrieval, confini chiari, avvocato nel loop.

## FAQ

### Perché non posso semplicemente usare lo splitter di default con overlap alto?
Perché l'overlap a lunghezza fissa non risolve il problema strutturale: puoi comunque tagliare a metà una clausola e separarla dal rinvio. L'overlap che serve nei contratti è mirato — ripetere l'intestazione dell'articolo — non "sovrapponi 200 token". E nessun overlap recupera un rinvio all'art. 7 se l'art. 7 sta a dieci pagine di distanza: per quello serve il retrieval a due passi sui metadata.

### Quanto devono essere grandi i chunk per un contratto?
Non ragionare in token, ragiona in unità di senso. Il chunk ideale è **un articolo intero** se sta sotto il limite comodo dell'embedding (indicativamente ~1500–2000 caratteri). Se un articolo è più lungo, suddividilo per commi ripetendo l'intestazione. Meglio un chunk "grande ma completo" di due chunk piccoli che spezzano una clausola.

### Come gestisco i rinvii incrociati tipo "salvo quanto previsto all'art. 7"?
Li estrai con una regex al momento del chunking e li salvi nei metadata (`rinvii`). A runtime, dopo aver recuperato i chunk per la query, fai un secondo passo che recupera anche gli articoli citati nei rinvii dei chunk trovati. Così quando il modello legge "salvo quanto previsto all'art. 7", ha anche l'art. 7 in contesto.

### Il RAG legale può sostituire un avvocato?
No, e progettarlo per farlo è l'errore più pericoloso. È uno strumento di retrieval: trova e cita clausole nei contratti caricati. L'interpretazione, la valutazione del rischio e le decisioni restano del professionista. Il disclaimer sul ruolo dell'AI va scritto nell'interfaccia, non lasciato all'intuito dell'utente.

### Come tratto le clausole vessatorie?
Il sistema può *riconoscerle* per tipo (foro esclusivo, limitazioni di responsabilità, recesso, penali) ed *etichettarle* nei metadata, segnalando se risulta o meno la doppia sottoscrizione ex art. 1341 c.c. Ma la conclusione sull'efficacia è dell'avvocato. Un RAG che dichiara "questa clausola è nulla" ha passato il confine: deve dire "clausola potenzialmente vessatoria, doppia firma non rilevata, verificare".

### I PDF scansiti funzionano?
Funzionano, ma con meno affidabilità. Servono OCR self-hosted (per la riservatezza), normalizzazione post-OCR per correggere numeri e sequenze di articoli, e la marcatura dell'origine nei metadata. Una risposta basata su testo OCR va sempre rimandata all'originale scansito per la verifica, perché l'OCR può sbagliare proprio i numeri e le firme.

### Che embedding uso per l'italiano giuridico?
Un modello di embedding multilingue di buona qualità, self-hosted, gestisce bene l'italiano contrattuale. La cosa che conta più del modello è il chunking: un embedding eccellente su un chunk troncato dà comunque un risultato inaffidabile. Prima sistema la struttura, poi ottimizza l'embedding. Valuta sempre sul gold set, non sulle benchmark generiche.

### Come faccio a sapere se il mio chunking funziona davvero?
Con il gold set: 30–50 domande reali con risposta e citazione validate da un avvocato, e due metriche — retrieval (hai recuperato gli articoli giusti, rinvii inclusi?) e fedeltà (la risposta si basa solo sui chunk, senza inventare?). Guarda per prime le domande con rinvii e deroghe: se reggono quelle, il chunking è buono. Rimisura a ogni modifica di splitter, modello o prompt.

### Posso indicizzare contratti in più lingue insieme?
Sì, con un embedding multilingue e i metadata che marcano la lingua. Ma attenzione: la struttura (articoli/commi) e le regole giuridiche cambiano per ordinamento. Il parser strutturale e le regole sulle clausole vessatorie che ho descritto sono tarati sull'italiano. Per contratti di altri ordinamenti servono parser e conoscenze giuridiche specifiche — non dare per scontato che valgano le stesse regole.

### Quanto costa mettere in piedi un RAG legale sui nostri contratti?
Come ordine di grandezza, 1–3 settimane/uomo di sviluppo (di più se hai molti scansiti da OCR), più il costo del calcolo (contenuto: embedding una tantum, generazione a centesimi per query) e — la voce dominante — il tempo dell'avvocato per costruire e validare il gold set e stare nel loop. Se il volume di contratti è alto e le query sono frequenti, si ripaga in fretta in ore risparmiate. Se il volume è basso, probabilmente non ti serve.
