---
lang: it
permalink: /it/blog/ocr-fattura-elettronica-accuratezza/
title: "Fattura elettronica XML + vision OCR: come arrivare al 95% di campi giusti (e come misurarlo, non come raccontarlo)"
date: 2026-10-02 07:30:00 +0200
author: "Antonio Trento"
description: "Accuratezza dell'estrazione dati dalle fatture: perché l'XML FatturaPA è la fonte e il PDF un fallback sporco, come costruire un gold set, misurare l'accuratezza per campo con checksum e bilanci, e mandare in revisione umana solo l'incerto."
keywords: ["ocr fattura elettronica accuratezza", "xml fatturapa vs pdf", "ai vision documenti", "evaluation estrazione dati", "estrazione dati fatture", "gold set fatture"]
image: /assets/images/posts/ocr-fattura-elettronica-accuratezza.jpg
pillar: rag-documenti
related: [/it/blog/rag-pgvector-fattura-elettronica/, /it/blog/chunking-contratti-italiani-rag/]
---

## "La nostra AI è al 99%" — su quali campi, misurati come?

Ogni volta che un fornitore mi dice "la nostra AI estrae i dati dalle fatture con il 99% di accuratezza", faccio due domande che chiudono la conversazione: **il 99% su quali campi, e misurato contro cosa?** Perché "99% di accuratezza" senza specificare il campo e il metodo è un numero da slide, non da produzione. Un sistema può essere al 99% sul totale documento e al 70% sulla partita IVA del cedente — e se sbaglia la partita IVA, la registrazione contabile è da rifare a mano, quel 99% non ti serve a niente.

Questo pezzo è sull'**accuratezza dell'OCR sulla fattura elettronica**, ma soprattutto è su come *misurarla* invece di raccontarla. Accuracy engineering, non marketing. E parte da una verità che quasi nessuno dice: per la fattura elettronica italiana, **l'OCR spesso non ti serve affatto**, perché il dato è già lì, strutturato, nell'XML FatturaPA. Fare OCR sul PDF quando hai l'XML è come ridisegnare a mano una mappa che hai già in formato digitale: introduci errori dove non ce n'erano.

Vediamo il metodo completo: perché l'**XML FatturaPA batte il PDF**, quali campi fanno danni se sbagliati, come costruire un gold set serio con 200 documenti e l'accordo tra annotatori, quali metriche usare davvero (exact match, bilanci, checksum della partita IVA), quando la **AI vision sui documenti** è giustificata e quando no, e come mandare in revisione umana solo ciò che è incerto. Con il codice per farlo.

È il complemento naturale del pezzo su come ho costruito il [RAG con pgvector sulla fattura elettronica]({{ '/it/blog/rag-pgvector-fattura-elettronica/' | relative_url }}): lì il tema era recuperare e interrogare le fatture, qui è estrarne i dati con accuratezza misurata. Stesso formato, stessa fonte, obiettivo diverso.

## L'XML è la fonte; il PDF è un fallback sporco

Partiamo dalla cosa che ribalta metà dei progetti che vedo. La fattura elettronica verso PA e B2B in Italia **è un file XML** (tracciato FatturaPA). Non è un PDF con sopra un OCR: è un documento strutturato, con i campi etichettati, leggibile da una macchina in modo deterministico. Il "PDF della fattura" che vedi è solo una *resa grafica* dell'XML (tramite un foglio di stile). Il dato vero, esatto, è nell'XML.

Cosa significa in pratica:

- **Per i campi presenti nell'XML, l'accuratezza è del 100%,** perché non stai "estraendo" niente: stai *leggendo* un valore etichettato. La partita IVA del cedente sta in `<IdCodice>` dentro `<IdFiscaleIVA>`. Il totale sta in `<ImportoTotaleDocumento>`. Non c'è interpretazione, non c'è OCR, non c'è AI. C'è un parser.
- **Fare OCR/vision sul PDF quando hai l'XML è un autogol.** Prendi un dato esatto, lo trasformi in immagine, e poi provi a ri-estrarlo con un modello che sbaglia. Introduci un tasso di errore su un dato che era perfetto. È la definizione di lavoro contro sé stessi.

Quindi la regola numero uno, la strategia **XML-first**: **se c'è l'XML, leggi l'XML.** L'OCR e la vision servono solo per i documenti che l'XML non ce l'hanno:

- **Scansioni di fatture cartacee** (fornitori che mandano ancora carta, o vecchie fatture).
- **Fatture estere**, che non seguono il tracciato FatturaPA.
- **Documenti non fiscali** (ordini, DDT, preventivi) che arrivano come PDF o scansione.

Su questi, il PDF è un "fallback sporco": ci lavori perché devi, sapendo che l'accuratezza sarà inferiore e che serve misura e revisione. Il **95% del titolo è l'obiettivo su questi casi difficili**, non sull'XML dove sei già al 100%.

Un parser XML-first sui campi critici, con lxml e `local-name()` per ignorare i namespace (che nel FatturaPA cambiano e fanno impazzire gli xpath ingenui):

```python
from lxml import etree

def parse_fatturapa(path_xml: str) -> dict:
    """Estrae i campi critici dall'XML: deterministico, 100% sui campi presenti."""
    tree = etree.parse(path_xml)

    def x1(expr: str) -> str | None:
        # local-name() = robusto ai namespace del tracciato FatturaPA
        r = tree.xpath(f"string({expr})")
        return r.strip() if r and r.strip() else None

    piva_cedente = x1("//*[local-name()='CedentePrestatore']"
                      "//*[local-name()='IdFiscaleIVA']"
                      "//*[local-name()='IdCodice']")
    return {
        "piva_cedente": piva_cedente,
        "numero": x1("//*[local-name()='DatiGeneraliDocumento']"
                     "//*[local-name()='Numero']"),
        "data": x1("//*[local-name()='DatiGeneraliDocumento']"
                   "//*[local-name()='Data']"),
        "totale": x1("//*[local-name()='ImportoTotaleDocumento']"),
        "imponibile": x1("//*[local-name()='DatiRiepilogo']"
                         "//*[local-name()='ImponibileImporto']"),
        "imposta": x1("//*[local-name()='DatiRiepilogo']"
                      "//*[local-name()='Imposta']"),
    }
```

Nota: nessun modello, nessuna GPU, nessun costo per token. Un parser che gira in millisecondi e non sbaglia. Questa è la base su cui poggia tutto il resto — e il motivo per cui diffido di chi propone "AI per le fatture elettroniche" senza prima chiederti se hai l'XML.

## I campi che fanno danni se sbagliati

Non tutti i campi hanno lo stesso peso. "Accuratezza del 95%" media su tutti i campi è inutile: quello che conta è l'accuratezza sui campi che, se sbagliati, ti costano. Ecco la gerarchia del danno:

- **Partita IVA / Codice Fiscale del cedente.** Se sbagli questo, associ la fattura al fornitore sbagliato, o non la associ affatto. Danno: registrazione errata, riconciliazione rotta, potenziale problema in dichiarazione. **Campo critico assoluto.** Per fortuna ha un checksum (sotto), quindi un errore è spesso rilevabile.
- **Importo totale, imponibile, imposta (IVA).** Sbagliare un importo significa contabilità sbagliata. Un errore anche di un centesimo rompe la quadratura (ci torno, è l'esempio che il titolo promette). **Campi critici.**
- **Numero e data documento.** Servono per l'identificazione univoca e per la competenza temporale. Un numero sbagliato può causare doppioni o registrazioni mancanti. **Campi importanti.**
- **Aliquota IVA.** Sbagliarla cambia il calcolo dell'imposta e la classificazione fiscale. **Campo importante.**
- **Descrizioni, note, riferimenti d'ordine.** Utili, ma un errore qui raramente è catastrofico. **Campi tolleranti.**

La lezione: **definisci l'accuratezza per campo, con un peso legato al danno.** Un sistema al 99% sulle descrizioni e al 90% sulla partita IVA è peggio di uno al 95% sulle descrizioni ma al 99,9% sulla partita IVA. Il numero unico "accuratezza" nasconde esattamente ciò che devi guardare.

### L'esempio dell'errore da un centesimo

Ecco perché "tolleranza sui centesimi" è una trappola se applicata male. Immagina una fattura con imponibile 1.000,00 €, IVA 22% = 220,00 €, totale 1.220,00 €. Un OCR legge l'imposta come 220,01 € (un artefatto di lettura, un pixel storto). Un centesimo, dirai. Ma ora:

- Il bilancio non torna: imponibile + imposta = 1.220,01 ≠ totale letto 1.220,00.
- La registrazione contabile ha una discrepanza di un centesimo che il gestionale rifiuta o segnala.
- Qualcuno deve aprire la fattura, capire dov'è il centesimo, correggerlo a mano.

Quel centesimo costa dieci minuti di un contabile, moltiplicati per ogni fattura che sbaglia così. **Su un importo, un centesimo di errore non è "quasi giusto": è sbagliato.** Ecco perché per i campi monetari la metrica non è "tolleranza", ma **quadratura**: imponibile + imposta deve fare esattamente il totale. Se non quadra, è un errore, punto — e il bello è che questo controllo lo fai in automatico, senza gold set, perché la matematica della fattura la conosci.

## Gold set: 200 documenti, chi etichetta, accordo tra annotatori

Adesso il cuore dell'accuracy engineering. Non puoi migliorare ciò che non misuri, e non puoi misurare senza un **gold set**: un insieme di documenti reali con i valori corretti, verificati da umani. È il metro. Senza, ogni "95%" è un'opinione.

Come lo costruisco, con i vincoli veri:

- **Dimensione: ~200 documenti** per iniziare, rappresentativi dei tuoi casi reali (fornitori diversi, layout diversi, XML e scansioni, italiani ed esteri). 200 è abbastanza per avere numeri sensati sui campi critici; troppo pochi (20) danno stime instabili, troppi (2000) costano etichettatura senza aggiungere segnale nella fase iniziale.
- **Chi etichetta: qualcuno che conosce le fatture,** cioè un amministrativo, non un ingegnere. L'ingegnere non sa a colpo d'occhio se quell'IVA è al 22% o al 10% agevolato. L'accuratezza del gold set dipende dalla competenza di chi etichetta.
- **Accordo tra annotatori (inter-annotator agreement).** Fai etichettare una parte dei documenti a **due** persone indipendenti e confronta. Se non sono d'accordo, o il campo è ambiguo o le istruzioni non sono chiare. Un gold set costruito da una persona sola, senza controllo, eredita i suoi errori e le sue interpretazioni. L'accordo tra annotatori è la misura di quanto ti puoi fidare del tuo stesso metro.
- **Congela il gold set e versionalo.** È un artefatto stabile contro cui misuri a ogni modifica. Se lo cambi, sai che i numeri prima/dopo non sono confrontabili.

Il gold set è un investimento di tempo di persone che conoscono il dominio. È la voce di costo dominante di un progetto di estrazione serio, ed è giusto così: **è ciò che trasforma "secondo me funziona" in "misurato sul nostro gold set, l'accuratezza sulla partita IVA è 99,4%".** La stessa logica del gold set legale che ho descritto per il [chunking dei contratti italiani per il RAG]({{ '/it/blog/chunking-contratti-italiani-rag/' | relative_url }}): cambia il dominio, non il principio.

## Metriche: exact match, quadratura, checksum

"Accuratezza" non è una metrica sola. Per ogni campo scegli la metrica giusta:

- **Exact match** per i campi identificativi: numero documento, partita IVA. O è identico al gold set, o è sbagliato. Nessuna tolleranza.
- **Quadratura** per i campi monetari: non confronti solo col gold set, verifichi la coerenza interna (imponibile + imposta = totale). Un errore rompe la quadratura ed è auto-rilevabile.
- **Checksum** per partita IVA e codice fiscale: hanno cifre di controllo. Un valore che non supera il checksum è certamente errato, indipendentemente dal gold set.
- **Normalizzazione prima del confronto:** date in formato coerente (ISO), importi con lo stesso separatore decimale, partite IVA senza prefisso "IT" o spazi. Molti "errori" sono solo formati diversi dello stesso valore: normalizza prima di giudicare.

La **definizione di accuratezza per campo** che uso, esplicita:

> Accuratezza del campo *C* = (numero di documenti in cui il valore estratto per *C*, normalizzato, corrisponde al gold set) / (numero totale di documenti in cui *C* è presente nel gold set).

Semplice, ma con due sottigliezze che cambiano i numeri: si normalizza prima di confrontare, e si conta solo sui documenti dove il campo *esiste* (non penalizzi il sistema per non aver estratto un campo assente).

Il checksum della partita IVA italiana (11 cifre, algoritmo tipo Luhn) è il tuo miglior amico: valida gratis, senza gold set.

```python
def piva_valida(piva: str) -> bool:
    """Checksum partita IVA italiana (11 cifre)."""
    p = piva.strip().removeprefix("IT")
    if len(p) != 11 or not p.isdigit():
        return False
    somma = 0
    for i, ch in enumerate(p[:10]):
        n = int(ch)
        if i % 2 == 1:              # posizioni pari (1-based): raddoppia
            n *= 2
            if n > 9:
                n -= 9
        somma += n
    controllo = (10 - somma % 10) % 10
    return controllo == int(p[10])

# uso: se piva_valida() è False, il valore è certamente sbagliato
# -> non serve il gold set per saperlo, va in revisione a prescindere.
```

E la valutazione per campo contro il gold set:

```python
def accuratezza_per_campo(gold: list[dict], estratti: list[dict],
                          campi: list[str]) -> dict:
    def norm(v):
        if v is None: return None
        return str(v).replace("IT", "").replace(" ", "").replace(",", ".").strip().lower()

    risultato = {}
    for c in campi:
        presenti = [(g, e) for g, e in zip(gold, estratti) if g.get(c) is not None]
        if not presenti:
            risultato[c] = None; continue
        ok = sum(1 for g, e in presenti if norm(g[c]) == norm(e.get(c)))
        risultato[c] = ok / len(presenti)
    return risultato

# output esempio: {"piva_cedente": 0.994, "totale": 0.981, "data": 0.999, ...}
```

Nota che il report è **per campo**, non un numero unico. Così sai dove sei forte e dove no, e dove concentrare il lavoro. Questa è la differenza tra "evaluation dell'estrazione dati" fatta sul serio e uno screenshot con scritto "99%".

Una tabella tipo di accuratezza per campo (numeri illustrativi, dichiarati come esempio di *forma* del report):

| Campo | Metrica | Accuratezza | Danno se sbagliato |
|-------|---------|-------------|--------------------|
| P.IVA cedente | exact + checksum | 99,4% | Critico |
| Totale documento | quadratura | 98,1% | Critico |
| Imponibile | quadratura | 98,3% | Critico |
| Imposta (IVA) | quadratura | 98,0% | Critico |
| Numero documento | exact match | 97,2% | Importante |
| Data | exact (norm.) | 99,1% | Importante |
| Aliquota IVA | exact match | 96,5% | Importante |
| Descrizioni | similarità | 92,0% | Tollerante |

Da XML questi sarebbero tutti al 100%. I numeri sotto il 100% sono il mondo delle scansioni e dell'estero — il fallback sporco.

## L'architettura di riferimento: XML-first con fallback vision

Ecco come si dispone il tutto. Il confine è il triage: XML da una parte (deterministico), vision dall'altra (probabilistico, misurato, con revisione).

```
   Documento ──▶ ┌────────────────────────────────────┐
   in ingresso   │ TRIAGE: è FatturaPA XML?            │
                 └──────────┬──────────────┬────────────┘
                       SÌ   │              │  NO (scansione, estero, non-PA)
                            ▼              ▼
            ┌───────────────────┐   ┌─────────────────────────┐
            │ PARSER XML (xpath) │   │ VISION/OCR + estrazione  │
            │ 100% campi presenti│   │ campi (probabilistico)   │
            └─────────┬──────────┘   └────────────┬─────────────┘
                      │                           │
                      ▼                           ▼
            ┌────────────────────────────────────────────────┐
            │ VALIDAZIONE: checksum P.IVA, quadratura importi,│
            │ formati, confidence per campo                   │
            └───────────────┬─────────────────┬───────────────┘
                    valido & confidente        incerto / validazione KO
                            ▼                     ▼
                   ┌────────────────┐    ┌─────────────────────┐
                   │ AUTO in gestion.│    │ REVISIONE UMANA     │
                   └────────────────┘    └─────────────────────┘

   Gold set + metriche per campo + report settimanale + drift monitor
```

**Cosa NON fa mai il sistema (i confini):**

- Non fa OCR sull'XML. Se c'è l'XML, lo legge. L'OCR è solo per ciò che l'XML non copre.
- Non manda in contabilità un valore che **fallisce la validazione** (checksum o quadratura) senza revisione umana.
- Non "decide" un importo a bassa confidenza da solo: sotto soglia, va all'umano.
- Non altera i dati fiscali: estrae e propone, la registrazione la conferma il gestionale/l'operatore.

## Quando usare la vision (e quando no)

La **AI vision sui documenti** — modelli multimodali o pipeline OCR — è potente ma va usata dove serve, non ovunque. Il default resta self-hosted/UE, come per ogni dato fiscale.

**Usa la vision quando:**

- Il documento è una **scansione o foto** senza XML (fatture cartacee, vecchie fatture).
- È una **fattura estera** fuori dal tracciato FatturaPA.
- È un **documento non fiscale** (DDT, ordine, preventivo) che arriva come immagine/PDF.

**NON usare la vision quando:**

- Hai l'XML. Ripeto perché è l'errore più costoso e più comune: leggere l'XML, non "vederlo".
- Il documento è un PDF *nativo digitale* con testo estraibile: prima prova l'estrazione testo diretta (pdf con layer di testo), che è più affidabile della vision su un rendering.

Sul lato modelli, per restare sovrani: OCR self-hosted (motori open) o modelli multimodali eseguiti in locale, con i vincoli di VRAM che ho discusso confrontando le opzioni self-hosted. I servizi cloud di document AI sono comodi ma mandano i tuoi documenti fiscali a un terzo — lo stesso problema di riservatezza di sempre. Se devi usarli, che sia una scelta consapevole e limitata, non il default.

## Human review sopra la soglia di incertezza

Il 95% significa che il 5% è sbagliato. La domanda giusta non è "come arrivo al 100%" (non ci arrivi), ma "**come faccio a sapere quale 5% mandare a un umano**". La risposta è la **confidence per campo** più le validazioni.

Un documento va in revisione umana quando:

- **Una validazione fallisce:** checksum P.IVA KO, oppure la quadratura non torna. Certezza di errore → umano.
- **La confidence del modello è sotto soglia** su un campo critico. I modelli OCR/vision danno un punteggio di confidenza: sotto una soglia (che tari sul tuo rischio), non ti fidi.
- **Il documento è di un tipo nuovo** (fornitore mai visto, layout mai visto): lo tratti come incerto finché non hai fiducia.

```python
def instrada(campi: dict, confidence: dict, soglia: float = 0.90) -> str:
    critici = ["piva_cedente", "totale", "imponibile", "imposta"]
    # 1. validazioni deterministiche
    if campi.get("piva_cedente") and not piva_valida(campi["piva_cedente"]):
        return "REVISIONE_UMANA"
    if not quadra(campi):                       # imponibile+imposta==totale
        return "REVISIONE_UMANA"
    # 2. confidenza sui campi critici
    if any(confidence.get(c, 1.0) < soglia for c in critici):
        return "REVISIONE_UMANA"
    return "AUTO"

def quadra(c: dict, tol_centesimi: int = 0) -> bool:
    try:
        from decimal import Decimal
        imp = Decimal(str(c["imponibile"]))
        iva = Decimal(str(c["imposta"]))
        tot = Decimal(str(c["totale"]))
        return abs((imp + iva) - tot) <= Decimal(tol_centesimi) / 100
    except Exception:
        return False
```

Il punto chiave dell'accuracy engineering: **non insegui il 100% di estrazione automatica. Insegui il 100% di correttezza dei dati che entrano in contabilità**, ottenuto mandando a revisione l'incerto. Un sistema che estrae il 90% in automatico con precisione altissima e manda il 10% incerto a un umano è infinitamente più utile di uno che estrae il 100% ma ci infila errori silenziosi. La soglia di incertezza è il quadrante che regoli: più è alta, più mandi all'umano ma più sei sicuro; più è bassa, più automatizzi ma più rischi. La tari sul costo dell'errore.

## Drift: nuovi tracciati, nuovo fornitore, nuovo layout

Un sistema di estrazione non è "finito" al lancio. Il mondo cambia sotto di lui, ed è il **drift** — il degrado silenzioso dell'accuratezza — a fregarti mesi dopo, quando nessuno guarda più i numeri.

Le fonti di drift specifiche delle fatture:

- **Nuove versioni del tracciato FatturaPA.** Il formato XML evolve. Un campo che cambia posizione o nome può rompere gli xpath. Sintomo: campi che tornano vuoti da una certa data. Il parser va aggiornato e ri-testato sul gold set.
- **Nuovo fornitore con layout diverso** (sul lato scansioni/estero): il modello vision non l'ha mai visto e sbaglia. Sintomo: picco di revisioni umane per un mittente specifico.
- **Cambio di layout di un fornitore esistente:** ha rifatto la sua fattura, e l'estrazione che funzionava ora sbaglia. Subdolo perché il fornitore è "noto".
- **Deriva del modello:** se cambi il modello vision o la sua versione, l'accuratezza cambia — in meglio o in peggio. Ri-misura sul gold set prima di mettere in produzione un modello nuovo.

Come lo tieni sotto controllo: **misuri l'accuratezza nel tempo, non solo al lancio.** Un campione dei documenti processati va confrontato periodicamente con la verità (o passa comunque da revisione umana, che è a sua volta un segnale). Se l'accuratezza su un campo critico scende, o le revisioni per un fornitore aumentano, il monitor lo segnala. Il drift non annunciato è il modo in cui un sistema "che funzionava" comincia a inquinare la contabilità senza che nessuno se ne accorga.

## Percorso di implementazione, a step

1. **Triage XML vs resto:** implementa il riconoscimento FatturaPA e il parser XML-first. Questo copre la maggior parte del volume B2B/PA al 100%.
2. **Validazioni deterministiche:** checksum P.IVA/CF e quadratura importi. Girano su tutto, XML e vision.
3. **Costruisci il gold set:** ~200 documenti reali etichettati da chi conosce le fatture, con accordo tra annotatori su un sottoinsieme.
4. **Definisci le metriche per campo** (exact/quadratura/checksum) e misura la baseline.
5. **Aggiungi la vision** solo per scansioni/estero/non-PA, con modello self-hosted, e misura la sua accuratezza sul gold set.
6. **Implementa l'instradamento a revisione** su validazione fallita o confidence bassa.
7. **Costruisci il report settimanale** (sotto) e il monitor di drift.
8. **Definisci le soglie** di confidence sul tuo rischio e taratele con i dati reali.
9. **Documenta** cosa è automatico, cosa va a revisione, e come si aggiorna il parser quando cambia il tracciato.

## Il report settimanale che un amministrativo capisce

L'ultima parte dell'outline, e la più sottovalutata. Le metriche per campo servono a te, ingegnere. Ma chi convive col sistema è l'amministrativo, e lui deve poter rispondere a una domanda: **"posso fidarmi dei dati di questa settimana?"**. Il report settimanale glielo dice, in linguaggio suo.

Cosa contiene, senza gergo:

- **Quante fatture processate**, di cui quante da XML (esatte) e quante da scansione/estero (stimate).
- **Quante andate in automatico e quante in revisione**, e perché (checksum, quadratura, incertezza).
- **Gli errori trovati in revisione**, con il fornitore e il campo: così emerge se un fornitore specifico dà problemi ricorrenti.
- **Un semaforo:** verde se l'accuratezza sui campi critici è sopra soglia, giallo se in calo, rosso se sotto. Senza numeri astrusi: "questa settimana i dati sono affidabili" oppure "attenzione, il fornitore X sta dando errori".
- **Il trend:** sta migliorando o peggiorando rispetto alle settimane scorse? È il rilevatore di drift tradotto in una freccia su/giù.

Un report che un contabile capisce ha un effetto secondario prezioso: **rende il sistema affidabile agli occhi di chi lo usa.** Un sistema di cui l'amministrativo si fida (perché vede i numeri e sa quando non fidarsi) viene usato; uno percepito come "scatola nera magica" viene aggirato o ignorato. La trasparenza sull'accuratezza non è cosmetica: è ciò che fa adottare lo strumento.

## I fallimenti tipici e come li riconosci dai log

- **Campi vuoti da una certa data.** Se un campo che era sempre popolato torna `null` da un certo giorno, è un cambio di tracciato o di layout. Logga il tasso di "campo assente" per campo nel tempo: un salto è drift.
- **Checksum P.IVA che falliscono a raffica.** O il parser prende il campo sbagliato (magari la P.IVA del cessionario invece del cedente), o la vision sbaglia le cifre. Logga i checksum KO con il valore estratto: capisci subito quale dei due.
- **Quadrature che non tornano per un fornitore.** Se le fatture di un mittente specifico non quadrano, è il suo layout/tracciato. Logga la quadratura per fornitore.
- **Confidence alta ma valore sbagliato** (falsi negativi della revisione). Il caso peggiore: il modello è sicuro e sbaglia. Lo scopri solo confrontando col gold set periodicamente. Se succede spesso su un campo, la soglia di confidence non è affidabile per quel campo: abbassala o aggiungi una validazione.
- **OCR lanciato su documenti che avevano l'XML.** Se nei log vedi la vision girare su documenti FatturaPA, il triage è rotto: stai sprecando calcolo e introducendo errori su dati che erano esatti. Allarme.
- **Picco di revisioni umane.** Un aumento improvviso significa qualcosa è cambiato (fornitore, layout, modello). È il campanello del drift.

La regola: **logga per campo e per fornitore, non solo il totale.** Il totale nasconde. "Accuratezza scesa dal 97 al 95%" non dice niente; "le fatture del fornitore X non quadrano più da lunedì" dice tutto.

## Costi: ordini di grandezza

Stime dichiarate.

- **Parser XML-first:** costo di sviluppo di qualche giornata, costo di esecuzione **zero rilevante** (nessun modello, gira in millisecondi su CPU). È la parte più economica e più accurata: sfruttala il più possibile.
- **Gold set:** la voce dominante. Il tempo di un amministrativo per etichettare ~200 documenti con cura, più la doppia etichettatura di un sottoinsieme. Come ordine di grandezza, qualche giornata-persona. È un investimento, non un costo accessorio.
- **Vision/OCR self-hosted:** una GPU consumer copre l'inferenza per volumi di PMI; VRAM da 8–16 GB a seconda del modello. Costo elettrico trascurabile (centesimi per documento). GPU ammortizzata: pochi euro/mese.
- **Vision cloud (se proprio):** prezzo per pagina/documento, che a volumi alti cresce, oltre al problema di riservatezza. Da valutare solo consapevolmente.
- **Manutenzione:** poche ore al mese per aggiornare il parser sui nuovi tracciati e ri-misurare sul gold set.
- **Costo del non misurare:** errori silenziosi in contabilità, riconciliazioni rotte, ore di correzione manuale, e nel caso fiscale rischi ben più cari. Un gold set e un report settimanale costano molto meno di un mese di dati sporchi scoperti troppo tardi.

## Quando NON farlo

- **Se hai l'XML e vuoi comunque fare OCR "per uniformità"**, fermati: è lavoro contro te stesso. Leggi l'XML, usa la vision solo per ciò che l'XML non copre.
- **Se non puoi costruire un gold set**, non promettere accuratezza: senza metro, ogni numero è inventato. Almeno un gold set piccolo sui campi critici è il minimo per prendere sul serio il progetto.
- **Se il volume di scansioni/estero è minimo**, forse non ti serve un pipeline vision: l'inserimento manuale di pochi documenti al mese costa meno di costruire e mantenere l'estrazione. Automatizza dove il volume lo giustifica.
- **Se non puoi mandare l'incerto a un umano**, non mettere l'estrazione automatica in un flusso che tocca la contabilità: il 5% di errore senza revisione entra nei tuoi conti.
- **Se non puoi mantenere il monitoraggio del drift**, sappi che l'accuratezza degraderà in silenzio. Un sistema di estrazione non monitorato è una fonte di errori che cresce.

## Checklist operativa prima di andare live

- [ ] **Triage XML-first** attivo: se c'è l'XML, si legge l'XML (nessun OCR).
- [ ] **Parser XML** robusto ai namespace (`local-name()`), testato sui tracciati reali.
- [ ] **Checksum P.IVA/CF** e **quadratura importi** su tutti i documenti.
- [ ] **Gold set** di ~200 documenti reali, etichettato da chi conosce le fatture, con accordo tra annotatori.
- [ ] **Metriche per campo** definite (exact/quadratura/checksum), con baseline misurata.
- [ ] **Vision self-hosted** solo per scansioni/estero/non-PA, misurata sul gold set.
- [ ] **Instradamento a revisione** su validazione fallita o confidence sotto soglia.
- [ ] **Soglie di confidence** tarate sul rischio con dati reali.
- [ ] **Report settimanale** comprensibile a un amministrativo, con semaforo e trend.
- [ ] **Monitor di drift:** accuratezza per campo e revisioni per fornitore nel tempo.
- [ ] **Dati fiscali self-hosted/UE:** nessun documento a vendor esterni non consapevoli.
- [ ] Procedura di **aggiornamento parser** quando cambia il tracciato.

## Il verdetto

L'**accuratezza dell'OCR sulla fattura elettronica** è, prima di tutto, una domanda mal posta — perché per la fattura elettronica italiana l'OCR spesso non serve: c'è l'XML, ed è esatto. La strategia XML-first ti porta al 100% sui campi che contano senza toccare un modello. La vision e l'OCR restano il fallback sporco per scansioni, estero e documenti non fiscali, ed è lì che il "95%" ha senso — misurato, non raccontato.

E "misurato" è la parola chiave. Definisci l'accuratezza **per campo**, con la metrica giusta (exact match per gli identificativi, quadratura per gli importi, checksum per la partita IVA). Costruisci un gold set serio con chi conosce le fatture e controlla l'accordo tra annotatori. Manda a revisione umana solo l'incerto, guidato da validazioni deterministiche e soglie di confidence. Sorveglia il drift, perché il tracciato e i fornitori cambiano. E dai all'amministrativo un report che capisce, perché la fiducia nel sistema vale quanto la sua accuratezza.

Fatto così, hai un sistema che estrae i dati con una qualità che sai dimostrare, che sbaglia solo dove ammette di non essere sicuro, e che tiene i documenti fiscali dentro casa. Fatto con lo slogan "la nostra AI è al 99%" e nessun gold set, hai un generatore di errori silenziosi che un giorno ti presenta il conto in sede di riconciliazione. La differenza non è il modello. È se hai il coraggio di misurare invece di raccontare.

Se vuoi un'estrazione dati dalle fatture che parta dall'XML, misuri l'accuratezza sul serio e mandi in revisione solo l'incerto, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Accuracy engineering, non slide col 99%.

## FAQ

### Perché non usare direttamente l'OCR su tutte le fatture, per uniformità?
Perché la fattura elettronica italiana è un XML strutturato: i campi sono già lì, esatti. Fare OCR sul PDF quando hai l'XML significa trasformare un dato perfetto in un'immagine e ri-estrarlo con un modello che sbaglia — introduci errori dove non ce n'erano. La strategia corretta è XML-first: leggi l'XML, e usa l'OCR solo per ciò che l'XML non copre (scansioni, estero, non fiscali).

### Cosa significa davvero "accuratezza del 95%"?
Da solo, quasi niente. Serve sapere *su quali campi* e *misurata come*. Un sistema al 95% medio può essere al 99,5% sulle descrizioni e all'88% sulla partita IVA — pessimo, perché la partita IVA è critica. L'accuratezza va definita per campo, con la metrica adatta a quel campo, e misurata contro un gold set. Il numero unico nasconde ciò che devi guardare.

### Come costruisco un gold set senza impazzire?
Prendi ~200 documenti reali e rappresentativi (fornitori, layout e tipi diversi), falli etichettare da qualcuno che conosce le fatture — un amministrativo, non un ingegnere — e fai controllare un sottoinsieme da una seconda persona per misurare l'accordo. Congela e versiona il risultato. È un investimento di tempo di persone del dominio, ed è ciò che rende i tuoi numeri credibili invece che opinioni.

### Perché un errore di un centesimo è un problema?
Perché su un importo un centesimo rompe la quadratura: imponibile + imposta non fa più il totale, e il gestionale segnala o rifiuta la registrazione. Qualcuno deve aprire la fattura e correggere a mano. Per i campi monetari la metrica giusta non è "tolleranza sui centesimi", ma la quadratura esatta: se non torna, è un errore, e il bello è che lo rilevi in automatico conoscendo la matematica della fattura.

### Come faccio a sapere quali documenti mandare a un umano?
Con le validazioni deterministiche e la confidence. Vanno in revisione: i documenti dove il checksum della partita IVA fallisce, dove la quadratura degli importi non torna, o dove il modello ha una confidenza bassa su un campo critico. Non insegui il 100% di automazione: insegui il 100% di correttezza dei dati che entrano in contabilità, mandando l'incerto a una persona.

### Il checksum della partita IVA serve davvero?
Moltissimo, ed è gratis. La partita IVA italiana ha una cifra di controllo calcolata dalle altre: un valore che non supera il checksum è certamente errato, senza bisogno del gold set. È il tuo primo filtro: se il checksum fallisce, il documento va in revisione a prescindere. Lo stesso vale per il codice fiscale, che ha il suo algoritmo di controllo.

### Quando è giustificato usare un modello vision?
Quando non hai l'XML: scansioni di fatture cartacee, fatture estere fuori dal tracciato FatturaPA, documenti non fiscali (DDT, ordini) come immagine. Su questi la vision è l'unica strada, ma va misurata sul gold set e affiancata alla revisione umana. Preferisci modelli self-hosted per non mandare documenti fiscali a un vendor esterno; se usi un cloud, che sia una scelta consapevole e limitata.

### Come mi accorgo che l'accuratezza sta peggiorando nel tempo?
Monitorando l'accuratezza per campo e le revisioni per fornitore nel tempo, non solo al lancio. Segnali di drift: campi che tornano vuoti da una certa data (cambio tracciato/layout), picchi di checksum falliti o di quadrature che non tornano, aumento delle revisioni per un mittente specifico. Un report periodico e un monitor rendono visibile il degrado prima che inquini la contabilità.

### Che report dovrei dare a chi usa il sistema?
Uno settimanale in linguaggio non tecnico: quante fatture processate (da XML esatte, da scansione stimate), quante automatiche e quante in revisione e perché, gli errori trovati con fornitore e campo, un semaforo verde/giallo/rosso sull'affidabilità e il trend rispetto alle settimane precedenti. Un amministrativo deve poter rispondere a "posso fidarmi dei dati di questa settimana?" senza leggere metriche astratte.

### Quanto costa mettere in piedi un'estrazione seria?
Il parser XML-first costa pochi giorni di sviluppo e ha costo di esecuzione trascurabile. La voce dominante è il gold set: il tempo di persone del dominio per etichettare ~200 documenti. La vision self-hosted richiede una GPU consumer (ammortizzata, pochi euro/mese) e poca elettricità. La manutenzione è qualche ora al mese per aggiornare il parser e ri-misurare. Confrontato con il costo di dati sbagliati in contabilità scoperti tardi, è un investimento che rientra in fretta.
