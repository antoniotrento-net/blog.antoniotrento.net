---
lang: it
permalink: /it/blog/accuratezza-estrazione-documenti-campi/
alt_url: /en/blog/document-extraction-field-accuracy/
title: "Come misuri il 95% di accuratezza sull'estrazione documenti (e come ti accorgi che è un 95% sugli header e un 60% sugli importi)"
date: 2026-11-14 07:30:00 +0200
author: "Antonio Trento"
description: "Perché l'accuratezza globale sull'estrazione dati da documenti mente: metriche per campo, micro e macro, pesi per costo dell'errore, tolleranze, campione vs popolazione con intervalli di confidenza, confusione tra fornitori simili, soglia di incertezza e coda umana, report settimanale e cosa scrivere nel contratto con chi fornisce il modello."
keywords: ["accuratezza estrazione documenti campi", "field level accuracy ocr", "gold set fatture", "confusion importi", "human review soglia", "score pesato estrazione"]
image: /assets/images/posts/accuratezza-estrazione-documenti-campi.jpg
pillar: rag-documenti
related: [/it/blog/ocr-fattura-elettronica-accuratezza/, /it/blog/json-schema-tool-calling-iban/]
---

## "Siamo al 95%": il numero che chiude la demo e apre i problemi

La demo finisce con una slide: "Accuratezza di estrazione: 95%". Il fornitore — esterno, oppure il team interno che ha costruito la pipeline — l'ha misurata su qualche centinaio di documenti: fatture passive in PDF, DDT, ordini, conferme d'ordine. In sala annuiscono. Il 95% sembra un ottimo voto: diciannove documenti su venti giusti, si pensa.

Tre mesi dopo, l'amministrazione ha smesso di fidarsi. Non perché la pipeline sbagli spesso, ma perché sbaglia **dove fa male**: gli importi totali non tornano in un documento su tre o quattro, gli IBAN dei fornitori nuovi vengono letti male, due fornitori con nomi simili vengono confusi. Intanto numero documento, data e ragione sociale sono quasi sempre perfetti. Il 95% era vero. Era solo la media sbagliata.

Questo pezzo parla di **accuratezza nell'estrazione di campi dai documenti**: come si misura in modo che il numero dica qualcosa di utile a chi deve decidere se fidarsi. Metriche per campo invece del voto globale, pesi legati al costo dell'errore, tolleranze esplicite, campione contro popolazione con intervalli di confidenza, la confusione tra anagrafiche simili, la soglia di incertezza che manda i casi dubbi a una persona, un report che un responsabile amministrativo legge in due minuti, e le clausole da scrivere nel contratto con chi fornisce il modello.

Se il tuo caso sono le fatture elettroniche italiane, la prima regola è un'altra e l'ho già scritta: l'XML della fattura elettronica è la fonte, il PDF è un fallback. Il ragionamento completo è nel pezzo sull'[accuratezza dell'OCR sulle fatture elettroniche]({{ '/it/blog/ocr-fattura-elettronica-accuratezza/' | relative_url }}). Qui parliamo di tutto il resto — DDT, ordini, conferme, documenti esteri, scansioni — e soprattutto di **come si misura**.

## È per te / non è per te

È per te se:

- hai una pipeline di estrazione da documenti (OCR + regole, modello vision, LLM, servizio esterno) in produzione o in valutazione;
- ti è stato presentato un numero di accuratezza e non sai come verificarlo;
- devi decidere quanti documenti possono passare in automatico e quanti devono essere controllati da una persona.

Non è per te se i tuoi documenti arrivano già strutturati (XML, EDI, API del fornitore): lì non c'è niente da estrarre, c'è da fare un buon parsing. E non è per te se cerchi un confronto tra motori OCR: qui il motore è irrilevante, conta il metro con cui lo misuri.

## Accuracy globale vs per campo

Partiamo dal numero della slide. Come si arriva a un 95% che nasconde un 60%?

Prendiamo un documento tipico — una fattura passiva estera o un DDT con valori — con dodici campi di testata e, in media, sette righe di dettaglio con quattro campi ciascuna (descrizione, quantità, prezzo unitario, importo di riga): ventotto campi di riga. Quaranta campi per documento.

Ecco l'accuratezza misurata sui campi di testata, su un campione di 200 documenti:

| Campo | Accuratezza |
|---|---|
| Numero documento | 99% |
| Data documento | 99% |
| Ragione sociale fornitore | 99% |
| Partita IVA fornitore | 98% |
| Indirizzo | 98% |
| CAP | 99% |
| IBAN | 90% |
| Imponibile | 70% |
| IVA | 75% |
| Totale documento | 60% |
| Scadenza pagamento | 95% |
| Riferimento ordine | 92% |

E le righe di dettaglio sono estratte bene: 98,5% in media, perché sono testo ripetitivo in tabelle regolari.

Ora i tre modi di fare la media:

- **Micro-media** (tutti i campi di tutti i documenti contati insieme): (12 × 89,5% + 28 × 98,5%) / 40 ≈ **96%**. È il numero della slide. Le righe di dettaglio, numerose e facili, schiacciano la testata.
- **Macro-media sui campi di testata** (media semplice delle accuratezze per campo): **89,5%**. Già meno rassicurante.
- **Accuratezza a livello documento** sui campi critici (percentuale di documenti in cui *tutti* i campi critici sono giusti): se il totale è giusto solo nel 60% dei casi, questo numero è **al massimo 60%**, e in pratica meno.

Tre numeri, tutti "veri", per lo stesso sistema. Il primo è quello che fa vincere la gara. L'ultimo è quello che dice all'amministrazione quanti documenti può registrare senza guardarli.

### Quale metrica serve a chi

- **Accuratezza per campo**: serve a chi sviluppa e mantiene la pipeline. Ti dice *dove* intervenire.
- **Score pesato** (sotto): serve a confrontare versioni del sistema o fornitori diversi con un numero solo, che tenga conto di cosa costa sbagliare.
- **Straight-through rate** (percentuale di documenti che possono passare in automatico con un errore residuo accettabile): serve a chi gestisce il processo. Ti dice quanto lavoro manuale resta.
- **Tasso di errore tra i documenti passati in automatico**: serve a chi risponde degli errori. Ti dice quanto rischio stai accettando.

Una regola semplice: **non accettare mai un singolo numero di accuratezza** senza sapere su quali campi, con quale media, su quali documenti e con quale tolleranza.

## Pesi: IBAN > indirizzo > CAP

Non tutti gli errori costano uguale. Un CAP sbagliato su una fattura passiva non costa quasi niente: il documento si registra comunque, il pagamento parte comunque. Un IBAN sbagliato può mandare un bonifico a qualcun altro. Un totale sbagliato rompe la quadratura, la registrazione contabile, a volte il pagamento.

Il modo per incorporare questa asimmetria nella misura è **pesare i campi per costo dell'errore**. I pesi non li decide chi sviluppa: li decide chi subisce l'errore, cioè l'amministrazione, con una conversazione di mezz'ora.

### Tabella campi e pesi

| Campo | Peso | Perché | Tolleranza |
|---|---|---|---|
| IBAN | 10 | Errore = pagamento al beneficiario sbagliato | Esatto (dopo normalizzazione spazi/maiuscole) |
| Totale documento | 10 | Quadratura, registrazione, pagamento | Esatto al centesimo |
| Imponibile | 8 | Registrazione IVA | Esatto al centesimo |
| Partita IVA fornitore | 8 | Associazione all'anagrafica, adempimenti | Esatto |
| IVA | 6 | Registrazione IVA, liquidazione | Esatto al centesimo |
| Scadenza pagamento | 5 | Pagamenti in ritardo o anticipati | Esatto al giorno |
| Riferimento ordine | 4 | Abbinamento ordine-fattura | Esatto dopo normalizzazione |
| Data documento | 3 | Competenza, registri | Esatto al giorno |
| Numero documento | 2 | Identificazione, duplicati | Esatto dopo normalizzazione |
| Ragione sociale | 2 | Leggibilità (l'anagrafica la dà la P.IVA) | Corrispondenza normalizzata |
| Indirizzo | 1 | Raramente usato nel processo | Somiglianza ≥ 0,9 |
| CAP | 1 | Raramente usato nel processo | Esatto |

Con questi pesi e le accuratezze di prima, lo **score pesato** della testata scende all'84%. Non è un numero più "severo" per partito preso: è un numero che misura il sistema dal punto di vista di chi lo usa.

### Formula di score pesato

Definiamo, per ogni campo *f*:

- *w_f* = peso del campo;
- *n_f* = numero di documenti del campione in cui il campo è presente nel gold set;
- *c_f* = numero di documenti in cui il valore estratto coincide con il gold, secondo la tolleranza del campo.

Accuratezza del campo: *a_f = c_f / n_f*.

Score pesato:

**S = Σ_f ( w_f · a_f ) / Σ_f w_f**

Due precisazioni importanti, che nella pratica fanno la differenza:

1. **Un campo presente nel gold ma non estratto conta come errore**; un campo assente nel gold ma "estratto" (il modello ha inventato un IBAN che il documento non contiene) **conta come errore** anch'esso, e va tracciato a parte, perché è il tipo di errore più pericoloso.
2. **I campi rari vanno misurati sui documenti dove sono presenti**, ma lo score deve riportare anche *n_f*: un'accuratezza del 100% su cinque IBAN non vale quanto un 97% su cinquecento.

In codice:

```python
from dataclasses import dataclass
from decimal import Decimal
from difflib import SequenceMatcher
import re

@dataclass
class RegolaCampo:
    peso: float
    tolleranza: str          # "esatto", "centesimo", "giorno", "normalizzato", "simile"
    soglia_simile: float = 0.9

def normalizza(s: str) -> str:
    return re.sub(r"[\s\.\-_/]", "", s or "").upper()

def coincide(estratto, gold, regola: RegolaCampo) -> bool:
    if gold is None:
        return estratto is None                 # inventare un valore è un errore
    if estratto is None:
        return False
    if regola.tolleranza == "centesimo":
        return abs(Decimal(str(estratto)) - Decimal(str(gold))) < Decimal("0.005")
    if regola.tolleranza in ("esatto", "giorno"):
        return str(estratto) == str(gold)
    if regola.tolleranza == "normalizzato":
        return normalizza(estratto) == normalizza(gold)
    if regola.tolleranza == "simile":
        return SequenceMatcher(None, normalizza(estratto), normalizza(gold)).ratio() >= regola.soglia_simile
    raise ValueError(regola.tolleranza)

def valuta(coppie, regole: dict[str, RegolaCampo]):
    """coppie: lista di (estratto: dict, gold: dict) per documento."""
    stat = {f: {"n": 0, "ok": 0, "inventati": 0} for f in regole}
    for estratto, gold in coppie:
        for f, r in regole.items():
            g, e = gold.get(f), estratto.get(f)
            if g is None and e is not None:
                stat[f]["inventati"] += 1
            if g is None and e is None:
                continue                        # campo non applicabile al documento
            stat[f]["n"] += 1
            stat[f]["ok"] += coincide(e, g, r)
    acc = {f: (s["ok"] / s["n"] if s["n"] else None) for f, s in stat.items()}
    pesi = {f: regole[f].peso for f in regole if acc[f] is not None}
    score = sum(pesi[f] * acc[f] for f in pesi) / sum(pesi.values())
    return score, acc, stat
```

Il codice è volutamente semplice. Non serve una libreria di metriche: serve che ogni regola di confronto sia esplicita e discussa, e che il gold set sia affidabile.

## Intervalli di tolleranza

La tolleranza è la parte più sottovalutata della misura, perché sembra un dettaglio tecnico. Invece decide il risultato. Lo stesso sistema può essere al 99% o all'85% sull'indirizzo a seconda che "Via G. Verdi 12" e "Via Giuseppe Verdi, 12" siano considerati uguali o diversi.

Le regole che uso:

- **Importi: esatti al centesimo.** Nessuna tolleranza "percentuale". Un totale sbagliato di 10 centesimi rompe la quadratura esattamente come uno sbagliato di 1.000 euro; anzi, è più subdolo, perché nessuno lo nota a occhio. La normalizzazione (virgola o punto decimale, separatori delle migliaia, simbolo di valuta) si fa *prima* del confronto, e va testata a parte: "1.234,50" e "1,234.50" devono diventare lo stesso numero, e "1.234" deve essere interpretato secondo la convenzione del documento, non indovinato.
- **Identificativi (IBAN, P.IVA, codice fiscale, numero documento): esatti dopo normalizzazione** di spazi, punti, trattini e maiuscole. Nient'altro. Un carattere diverso è un identificativo diverso.
- **Date: esatte al giorno**, dopo aver normalizzato il formato. Attenzione ai documenti esteri con formato mese/giorno: "03/04/2026" è il 3 aprile o il 4 marzo? La tolleranza non risolve l'ambiguità: la deve risolvere la pipeline, con una regola per paese o per fornitore.
- **Testo descrittivo (ragione sociale, indirizzo, descrizioni di riga): somiglianza** con una soglia dichiarata, dopo normalizzazione. La soglia va scelta guardando esempi veri di "quasi uguale" e "diverso", non a sentimento.
- **Quantità: esatte**, con attenzione alle unità di misura (pezzi, kg, metri): una quantità giusta con l'unità sbagliata è un errore.

Le tolleranze vanno scritte in un file di configurazione versionato insieme al gold set. Se cambi una tolleranza, cambi la misura: lo score di prima e quello di dopo non sono più confrontabili.

```yaml
# valutazione/campi.yaml — versionato con il gold set
versione: 2026-11-01
campi:
  iban:              {peso: 10, tolleranza: normalizzato, critico: true}
  totale:            {peso: 10, tolleranza: centesimo,    critico: true}
  imponibile:        {peso: 8,  tolleranza: centesimo,    critico: true}
  partita_iva:       {peso: 8,  tolleranza: normalizzato, critico: true}
  iva:               {peso: 6,  tolleranza: centesimo,    critico: true}
  scadenza:          {peso: 5,  tolleranza: giorno,       critico: true}
  riferimento_ordine:{peso: 4,  tolleranza: normalizzato, critico: false}
  data_documento:    {peso: 3,  tolleranza: giorno,       critico: false}
  numero_documento:  {peso: 2,  tolleranza: normalizzato, critico: false}
  ragione_sociale:   {peso: 2,  tolleranza: simile, soglia_simile: 0.92, critico: false}
  indirizzo:         {peso: 1,  tolleranza: simile, soglia_simile: 0.90, critico: false}
  cap:               {peso: 1,  tolleranza: esatto,       critico: false}
straight_through:
  richiede_campi_critici_tutti_con_confidenza_sopra_soglia: true
```

## Campione vs popolazione

Il 95% della slide era misurato su un campione. Due domande da fare sempre: **quanto è grande** e **quanto somiglia ai documenti veri**.

### Quanto è grande: l'intervallo di confidenza

Un'accuratezza misurata su un campione è una stima, con un margine di incertezza. Con 200 documenti e 190 corretti (95%), l'intervallo di confidenza al 95% (metodo di Wilson) va da circa **91,0% a 97,3%**. Con 500 documenti e 475 corretti, si stringe a **92,7%–96,6%**.

Il problema diventa serio sui campi rari. Se l'IBAN è presente solo in 40 dei 200 documenti e 36 sono corretti, l'accuratezza è 90%, ma l'intervallo va da **76,9% a 96,0%**. Stai decidendo se mandare in automatico i pagamenti con un numero che potrebbe essere 77% o 96%. Con 10 esempi e 9 corretti, l'intervallo va da circa 60% a 98%: in pratica non sai niente.

Conseguenze pratiche:

- riporta sempre *n* accanto a ogni accuratezza;
- per i campi critici rari, **arricchisci il gold set** di proposito con documenti che li contengono, fino ad avere almeno qualche centinaio di esempi;
- non confrontare due versioni del sistema se gli intervalli si sovrappongono quasi del tutto: la differenza potrebbe essere rumore.

### Quanto somiglia: il campione stratificato

Il campione della demo è spesso fatto dei documenti "comodi": i fornitori principali, i layout più frequenti, le scansioni buone. La popolazione reale è diversa: c'è la coda lunga di fornitori con un documento all'anno, le scansioni storte, i documenti in inglese o tedesco, i fax (sì, ancora), le note di credito con importi negativi.

Il campione va **stratificato** secondo le dimensioni che contano:

- per **fornitore** (i primi dieci fornitori per volume, poi la coda lunga);
- per **tipo di documento** (fattura, nota di credito, DDT, ordine, conferma);
- per **origine** (PDF nativo, scansione, foto, documento estero);
- per **periodo** (documenti recenti, perché i layout cambiano).

E l'accuratezza va riportata **per strato**, oltre che complessiva. Il caso tipico: 98% sui PDF nativi dei grandi fornitori, 70% sulle scansioni della coda lunga. Se la popolazione reale è fatta per il 30% di scansioni, la media "vera" è molto più bassa di quella misurata su un campione che ne conteneva il 5%.

### Il gold set, in breve

Il gold set — i documenti con i valori corretti inseriti da una persona — è la base di tutto. Tre regole che non ripeto in dettaglio perché le ho già trattate nel pezzo sulle fatture:

- lo etichetta chi conosce i documenti (l'amministrazione), non chi sviluppa;
- una parte viene etichettata due volte da persone diverse, per misurare l'accordo tra annotatori: se due persone non sono d'accordo sul valore di un campo, quel campo è ambiguo anche per il modello;
- il gold set si aggiorna, con nuovi documenti ogni mese, e le versioni si conservano.

## Confusion: fornitore A vs B con nomi simili

C'è una classe di errori che la misura per campo non vede bene: **l'associazione all'anagrafica sbagliata**. La pipeline estrae "Rossi Impianti S.r.l." e la associa al fornitore "Rossi S.r.l." già presente in anagrafica. Tutti i campi estratti possono essere perfetti; ma il documento finisce sulla scheda del fornitore sbagliato, con il suo IBAN, le sue condizioni di pagamento, il suo conto contabile.

Succede più spesso di quanto si pensi, perché i nomi delle aziende italiane si somigliano: famiglie con più società, gruppi con ragioni sociali quasi identiche, "Unipersonale", "S.r.l.s.", "& C.", abbreviazioni. E succede soprattutto quando la pipeline usa la ragione sociale per l'associazione invece della partita IVA, o quando la partita IVA non è leggibile e il sistema "ripiega" sul nome.

Come si misura:

- nel gold set c'è anche l'**ID del fornitore corretto** in anagrafica;
- si costruisce una **matrice di confusione** dell'associazione: per ogni fornitore reale, a quale fornitore il sistema ha associato i documenti;
- si guardano le celle fuori diagonale: ogni coppia ricorrente (A confuso con B) è un problema specifico, quasi sempre risolvibile.

| Fornitore reale ↓ / associato → | Rossi S.r.l. | Rossi Impianti S.r.l. | Rossi & Figli S.n.c. | Nessuno (revisione) |
|---|---|---|---|---|
| Rossi S.r.l. | 46 | 2 | 0 | 1 |
| Rossi Impianti S.r.l. | 7 | 18 | 0 | 2 |
| Rossi & Figli S.n.c. | 1 | 0 | 9 | 1 |

Sette documenti di Rossi Impianti su ventisette finiti su Rossi S.r.l.: un errore del 26% su quel fornitore, invisibile nella media globale.

Le contromisure sono deterministiche:

- **associazione per partita IVA**, mai per nome; il nome è solo una verifica;
- se la partita IVA estratta non supera il controllo di validità o non esiste in anagrafica, **niente associazione**: revisione umana;
- per le coppie note di fornitori simili, una regola esplicita che richiede la conferma umana;
- per i fornitori nuovi, mai la creazione automatica dell'anagrafica da un documento.

La validazione degli identificativi con algoritmi invece che con il modello è il secondo strato del recinto che descrivo nel pezzo su [JSON Schema e tool calling con gli IBAN]({{ '/it/blog/json-schema-tool-calling-iban/' | relative_url }}): lo schema controlla la forma, i validatori di dominio il contenuto.

## Soglia di incertezza e coda umana

Nessun sistema di estrazione è perfetto, quindi la domanda operativa non è "quanto è accurato" ma "**quali documenti posso far passare senza guardarli, e con quale rischio**". La risposta passa da una soglia di incertezza.

Quasi tutte le pipeline producono una qualche misura di confidenza per campo: la confidenza dell'OCR sui caratteri, la probabilità del modello, l'esito di controlli deterministici (checksum validi, quadratura imponibile + IVA = totale, partita IVA presente in anagrafica). La confidenza "grezza" del modello da sola è poco affidabile: i modelli sono spesso sicuri anche quando sbagliano. I controlli deterministici, invece, sono oro: se imponibile + IVA ≠ totale, almeno uno dei tre campi è sbagliato, a prescindere dalla confidenza.

La regola di instradamento che uso combina le due cose:

- un documento passa in automatico **solo se** tutti i campi critici superano la soglia di confidenza **e** tutti i controlli deterministici passano;
- altrimenti va in coda di revisione, con evidenziati i campi che hanno causato l'invio.

### Come si sceglie la soglia

La soglia non si sceglie "a 0,8 perché sembra un buon numero". Si sceglie sul gold set, guardando due curve: la percentuale di documenti che passano in automatico e il tasso di errore tra quelli che passano.

| Soglia di confidenza (campi critici) | Documenti in automatico | Errori tra i documenti in automatico |
|---|---|---|
| 0,50 | 88% | 6,1% |
| 0,70 | 79% | 2,8% |
| 0,80 | 71% | 1,2% |
| 0,90 | 58% | 0,4% |
| 0,95 | 41% | 0,2% |

(Numeri di esempio, da rifare sul tuo gold set.)

La scelta è una decisione di business, non tecnica: quanto lavoro manuale vuoi togliere e quanto errore residuo accetti. Con la tabella davanti, l'amministrazione può dire "accetto l'1% di errori sui documenti automatici se tolgo il 70% del lavoro" — oppure "sui pagamenti voglio sotto lo 0,5%, quindi soglia a 0,9". Possono anche esserci soglie diverse per campo: più alta sull'IBAN, più bassa sulla data.

Un dettaglio che conta: l'errore residuo va **rimisurato in produzione**, con un controllo a campione sui documenti passati in automatico (per esempio il 2–5% scelto a caso ogni settimana). Senza questo controllo, il tasso di errore dei documenti automatici diventa invisibile per definizione: nessuno li guarda.

## Report che non è un F1 da paper

Le metriche accademiche — precision, recall, F1 — sono utili a chi sviluppa, e inutili a chi deve decidere. Un responsabile amministrativo non sa cosa farsene di "F1 macro 0,87". Sa cosa farsene di "questa settimana 312 documenti, 228 registrati in automatico, 2 errori trovati nel controllo a campione, entrambi su importi di un fornitore estero".

### Esempio di report settimanale

> **Estrazione documenti — settimana 45 (3–9 novembre)**
>
> **Volume:** 312 documenti (fatture estere 96, DDT 141, ordini 52, note di credito 23).
>
> **In automatico:** 228 (73%) — settimana scorsa 70%.
> **In revisione:** 84 (27%). Motivi principali: totale non quadra (31), IBAN non valido o assente in anagrafica (18), fornitore non associato (14), scansione illeggibile (12), altro (9).
>
> **Controllo a campione sui documenti automatici:** 12 controllati, 0 errori. Ultime 4 settimane: 47 controllati, 1 errore (importo IVA su nota di credito).
>
> **Correzioni fatte in revisione:** 84 documenti, 61 campi corretti. Campi più corretti: totale (19), imponibile (14), scadenza (9).
>
> **Da guardare:** il fornitore "Muller GmbH" ha 9 documenti su 11 in revisione per formato data ambiguo — proposta: regola di formato per fornitore.
>
> **Stato:** 🟢 affidabile sui campi critici (score pesato 0,93 su gold set di ottobre, n = 600; settimana precedente 0,92).

Il report risponde a quattro domande, nell'ordine in cui le fa chi lo legge: quanto lavoro è stato tolto, quanto rischio c'è, cosa è andato storto, cosa bisogna fare. I numeri tecnici (score pesato, *n*) stanno in fondo, per chi li vuole.

Il report si genera da una query sul database della pipeline e sui registri della revisione: non deve essere scritto a mano, altrimenti dopo tre settimane smette di esistere.

## Contratto con il fornitore AI interno/esterno

Che la pipeline la costruisca un fornitore esterno o un team interno, serve un **accordo scritto su come si misura**. Altrimenti ogni discussione sulla qualità diventa uno scontro di impressioni. Le clausole che metto sempre:

1. **Metriche per campo**, non un'accuratezza globale. Elenco dei campi critici, con tolleranze e pesi allegati.
2. **Gold set di proprietà del cliente**, costruito dal cliente (o insieme, con revisione del cliente), mai condiviso per addestrare modelli di terzi senza consenso esplicito. Una parte del gold set resta **riservata** e non viene mai mostrata al fornitore, per evitare che il sistema venga ottimizzato sul test.
3. **Soglie minime per campo critico**, con l'intervallo di confidenza: "accuratezza sull'IBAN ≥ 98% misurata su almeno 300 esempi".
4. **Tasso di errore massimo sui documenti passati in automatico**, misurato con controllo a campione in produzione.
5. **Notifica preventiva di ogni cambio di modello o di versione** che possa modificare il comportamento, con rivalutazione sul gold set prima del rilascio.
6. **Diritto di rivalutazione** periodica (per esempio trimestrale) e su richiesta in caso di peggioramento percepito.
7. **Gestione dei campi inventati**: un valore estratto per un campo assente nel documento è un errore grave, misurato a parte, con soglia propria vicino allo zero.
8. **Residenza e trattamento dei dati**: dove vengono elaborati i documenti, chi li vede, quanto vengono conservati. Il default che consiglio è elaborazione su infrastruttura del cliente o in UE con nomina a responsabile del trattamento.
9. **Rimedi**: cosa succede se le soglie non sono rispettate (correzione entro un tempo, sconto, diritto di recesso).

Se il fornitore non accetta di essere misurato per campo su un gold set del cliente, ti sta dicendo qualcosa sul suo 95%.

## Percorso di implementazione, a step

1. **Elenca i campi** che servono al processo e, con l'amministrazione, assegna pesi e tolleranze. Distingui i campi critici.
2. **Costruisci il gold set**: 300–600 documenti stratificati per fornitore, tipo, origine e periodo, con i campi critici rari arricchiti di proposito. Doppia etichettatura su un 10–20%.
3. **Scrivi il valutatore** (come quello sopra) e la configurazione dei campi versionata.
4. **Misura il sistema attuale** (anche se è manuale: quanto sbagliano le persone?) e i candidati, per campo, per strato, con intervalli di confidenza.
5. **Aggiungi i controlli deterministici**: checksum degli identificativi, quadratura degli importi, esistenza in anagrafica, associazione per partita IVA.
6. **Scegli la soglia** sulla tabella automatico/errori, con l'amministrazione.
7. **Attiva la coda di revisione** con i campi problematici evidenziati e la registrazione delle correzioni.
8. **Attiva il controllo a campione** sui documenti automatici.
9. **Genera il report settimanale** in automatico.
10. **Rivaluta ogni mese** sul gold set aggiornato, e prima di ogni cambio di modello, prompt o regola.

## Fallimenti tipici e come li riconosci dai log

**Il numero globale sale, quello pesato scende.**

```text
eval 2026-11-01 micro=0.961 macro_testata=0.902 score_pesato=0.861 n_doc=600
eval 2026-11-08 micro=0.966 macro_testata=0.899 score_pesato=0.842 n_doc=600
```

Una modifica ha migliorato i campi facili e peggiorato quelli critici. Se guardi solo il micro, la rilasci.

**Campi inventati.**

```text
extract doc=DDT-88123 field=iban value=IT60X054281110100000012345 gold=null status=INVENTED
extract doc=DDT-88140 field=iban value=IT02A030690960610000004567 gold=null status=INVENTED
```

Il modello "completa" un IBAN su documenti che non ne contengono (un DDT, per esempio). Gravissimo: se quell'IBAN supera il checksum per caso o viene associato all'anagrafica, il pagamento parte verso un conto mai esistito nel documento.

**Quadrature che falliscono in serie.**

```text
validate doc=FT-EXT-4471 check=quadratura imponibile=1250.00 iva=275.00 totale=1252.75 result=FAIL
```

Il totale è stato letto con un separatore sbagliato o è stato preso il valore di un'altra riga. Se succede su un fornitore specifico, è un layout; se succede ovunque, è una regressione.

**Coda di revisione che cresce senza volume in più.** La percentuale in revisione passa dal 25% al 40% in due settimane a parità di documenti: un fornitore grande ha cambiato layout, o è cambiato il modello. Il report settimanale lo mostra; il log mostra quale motivo di revisione è cresciuto.

**Controllo a campione che non trova mai niente.** Zero errori per dodici settimane su pochissimi documenti controllati non significa errore zero: con 10 controlli a settimana, un errore reale dell'1% passa spesso inosservato. Aumenta il campione o concentralo sui campi critici.

## Costi: ordini di grandezza

Stime indicative per una pipeline da qualche centinaio a qualche migliaio di documenti al mese.

| Voce | Ordine di grandezza (stima) | Note |
|---|---|---|
| Definizione campi, pesi, tolleranze | 1–2 giorni | Con l'amministrazione, non da soli |
| Costruzione gold set (500 documenti) | 5–10 giorni/persona | Dipende dai campi; è il costo più alto e più utile |
| Valutatore e configurazione | 2–4 giorni/uomo | Una volta, poi si riusa |
| Controlli deterministici | 2–5 giorni/uomo | Checksum, quadrature, anagrafica |
| Coda di revisione con evidenze | 3–8 giorni/uomo | Se non esiste già nel gestionale |
| Report settimanale automatico | 1–3 giorni/uomo | Query + invio |
| Manutenzione | 1–2 giorni/mese | Aggiornamento gold set, rivalutazioni |
| Controllo a campione | 30–60 minuti/settimana | Di una persona dell'amministrazione |

Il gold set sembra caro. Confrontalo con il costo di un solo bonifico all'IBAN sbagliato, o di un trimestre di registrazioni IVA da correggere.

## Quando NON farlo

- **Quando i documenti sono pochi.** Con 50 documenti al mese, una persona li registra in meno tempo di quanto serva per costruire il gold set. Usa l'estrazione come suggerimento, senza instradamento automatico.
- **Quando i dati esistono già strutturati.** Fatture elettroniche XML, EDI, portali fornitori con export: prima di misurare l'accuratezza dell'estrazione, chiediti perché stai estraendo.
- **Quando nessuno farà la revisione.** Una soglia di incertezza senza persone che guardano la coda è un modo elegante di accumulare documenti non registrati.
- **Quando il fornitore non accetta di essere misurato per campo.** Non è un dettaglio contrattuale: è il segnale che la qualità non è verificabile.
- **Quando l'errore costa troppo e il volume è basso**: per contratti, atti, documenti legali rari, l'estrazione automatica al massimo prepara una scheda per chi legge, e la misura che conta è "quanto tempo fa risparmiare a chi controlla", non l'accuratezza.

## Checklist operativa

- [ ] Ogni accuratezza è riportata per campo, con *n* e intervallo di confidenza.
- [ ] Pesi e tolleranze per campo sono decisi con l'amministrazione e versionati.
- [ ] Lo score pesato è il numero principale per confrontare versioni e fornitori.
- [ ] I campi inventati (valore estratto, campo assente) sono misurati a parte.
- [ ] Il gold set è stratificato per fornitore, tipo, origine e periodo; i campi critici rari sono arricchiti.
- [ ] Una parte del gold set è doppiamente etichettata e una parte è riservata.
- [ ] L'associazione all'anagrafica avviene per partita IVA, con matrice di confusione monitorata.
- [ ] I controlli deterministici (checksum, quadratura, esistenza in anagrafica) bloccano il passaggio in automatico.
- [ ] La soglia è scelta sulla tabella automatico/errori, con una decisione esplicita di chi risponde degli errori.
- [ ] C'è un controllo a campione settimanale sui documenti passati in automatico.
- [ ] Il report settimanale è generato in automatico e letto dall'amministrazione.
- [ ] Il contratto con il fornitore contiene metriche per campo, gold set del cliente, notifica dei cambi di modello.

## Il verdetto

L'accuratezza nell'estrazione di campi dai documenti non è un voto: è una tabella. Un singolo numero, per quanto alto, fa la media tra campi che non valgono niente se sbagliati e campi che valgono un bonifico, tra documenti facili e documenti difficili, tra un campione comodo e una popolazione disordinata. Il 95% sugli header e il 60% sugli importi possono convivere nello stesso numero, ed è il numero che ti mostrano.

Misurare bene costa poco rispetto a ciò che protegge: campi con pesi decisi da chi subisce l'errore, tolleranze scritte, campioni abbastanza grandi e somiglianti alla realtà, controlli deterministici che non si fanno convincere, una soglia scelta guardando il rischio residuo, una persona che controlla a campione anche ciò che passa in automatico. E un report che dice all'amministrazione, ogni settimana, se può fidarsi.

Se stai valutando una pipeline di estrazione — tua o di un fornitore — e vuoi sapere quanto vale davvero sui campi che contano, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e il resto del lavoro su [antoniotrento.net]({{ site.main_site }}/). Gli altri pezzi su documenti, RAG ed estrazione sono raccolti nella guida su [RAG e documenti]({{ '/it/pillar/rag-documenti/' | relative_url }}).

## FAQ

### Perché l'accuratezza globale dell'estrazione documenti è fuorviante?

Perché fa la media tra campi con importanza e difficoltà molto diverse. I campi numerosi e facili, come le righe di dettaglio o la data, alzano la media e nascondono gli errori sui campi critici e difficili, come importi e IBAN. Un sistema può avere il 96% di accuratezza complessiva e il 60% sul totale del documento.

### Cosa sono micro-media e macro-media nell'accuratezza per campo?

La micro-media conta insieme tutti i campi di tutti i documenti, quindi pesa di più i campi più numerosi. La macro-media calcola prima l'accuratezza di ogni campo e poi ne fa la media semplice, dando a ogni campo lo stesso peso. Nessuna delle due tiene conto del costo dell'errore: per questo serve uno score pesato.

### Come si calcola uno score pesato di accuratezza?

Si assegna a ogni campo un peso proporzionale al costo dell'errore, si calcola l'accuratezza di ogni campo sul gold set con la sua tolleranza, e si fa la media ponderata: somma di peso per accuratezza, divisa per la somma dei pesi. I pesi li decide chi subisce l'errore, tipicamente l'amministrazione.

### Che tolleranza usare per importi e identificativi?

Per gli importi, esattezza al centesimo dopo aver normalizzato separatori e simboli di valuta. Per identificativi come IBAN, partita IVA e codice fiscale, esattezza dopo aver normalizzato spazi, punti e maiuscole. Per testi descrittivi come indirizzi e ragioni sociali, una soglia di somiglianza dichiarata e scelta guardando esempi reali.

### Quanti documenti servono per misurare l'accuratezza in modo affidabile?

Dipende dal campo. Per i campi presenti in tutti i documenti, alcune centinaia di documenti danno intervalli di confidenza di qualche punto percentuale. Per i campi rari, come l'IBAN presente solo in una parte dei documenti, servono centinaia di esempi di quel campo: con 40 esempi un 90% misurato può corrispondere a un valore reale tra circa 77% e 96%.

### Cos'è un gold set e chi deve costruirlo?

È un insieme di documenti reali con i valori corretti di ogni campo inseriti da una persona. Deve costruirlo chi conosce i documenti, come l'amministrazione, con una parte etichettata due volte per misurare l'accordo tra annotatori e una parte riservata che il fornitore del sistema non vede.

### Come si evita di confondere fornitori con nomi simili?

Associando i documenti all'anagrafica tramite partita IVA validata, mai tramite la ragione sociale. Se la partita IVA non è leggibile o non esiste in anagrafica, il documento va in revisione. Una matrice di confusione dell'associazione, aggiornata periodicamente, mostra le coppie di fornitori che il sistema confonde.

### Come si sceglie la soglia di confidenza per la revisione umana?

Sul gold set, costruendo una tabella che per ogni soglia mostra la percentuale di documenti che passerebbero in automatico e il tasso di errore tra quelli. La scelta spetta a chi risponde degli errori: quanto lavoro manuale togliere e quanto errore residuo accettare. In produzione, il tasso di errore va rimisurato con controlli a campione.

### Cosa deve contenere un report sull'accuratezza per l'amministrazione?

Volume dei documenti, quanti sono passati in automatico e quanti in revisione con i motivi, errori trovati nei controlli a campione, campi più corretti in revisione, segnalazioni su fornitori problematici e uno stato complessivo di affidabilità. Le metriche tecniche possono stare in fondo per chi le vuole.

### Cosa scrivere nel contratto con un fornitore di estrazione documenti?

Metriche per campo con tolleranze e pesi, gold set di proprietà del cliente con una parte riservata, soglie minime per i campi critici con dimensione del campione, tasso massimo di errore sui documenti automatici, notifica preventiva dei cambi di modello, gestione dei valori inventati, residenza dei dati e rimedi in caso di mancato rispetto delle soglie.
