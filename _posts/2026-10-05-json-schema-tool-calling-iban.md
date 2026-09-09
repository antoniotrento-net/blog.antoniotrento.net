---
lang: it
permalink: /it/blog/json-schema-tool-calling-iban/
title: "JSON Schema e tool calling: come impedire all'LLM di inventare un IBAN \"perché sembrava plausibile\""
date: 2026-10-05 07:30:00 +0200
author: "Antonio Trento"
description: "Data contract tra LLM e tool: perché lo structured output vincola la forma ma non la correttezza, come validare IBAN, codice fiscale e partita IVA con i checksum, e perché su un campo critico l'LLM non deve nemmeno generarlo se ce l'hai già nell'XML."
keywords: ["json schema tool calling iban", "structured output llm", "validazione iban", "function calling affidabile", "pydantic agente", "data contract llm"]
image: /assets/images/posts/json-schema-tool-calling-iban.jpg
pillar: agenti-esecuzione
related: [/it/blog/kill-switch-agente-salesforce/, /it/blog/ocr-fattura-elettronica-accuratezza/]
---

## Un IBAN sbagliato che passa tutti i controlli formali

Ti mostro il modo più subdolo in cui un agente ti fa un danno. Chiedi all'LLM di estrarre l'IBAN da un documento e passarlo al tool che prepara il bonifico. Il modello risponde con un JSON perfetto: `{"iban": "IT60X0542811101000000123456", "importo": 1220.00}`. Struttura valida, tipi giusti, campo presente. Il tuo codice lo accetta e va avanti. Peccato che quell'IBAN il modello se lo sia *inventato* — o abbia mischiato le cifre di due IBAN diversi — "perché sembrava plausibile". Formalmente è un IBAN. Nella realtà, i soldi vanno nel vuoto o, peggio, su un conto sbagliato.

Questa è l'**allucinazione strutturata**, ed è più pericolosa del testo libero. Se l'LLM ti risponde in prosa "l'IBAN dovrebbe essere circa...", te ne accorgi: è ovviamente inaffidabile. Ma un JSON pulito, con un campo `iban` che *sembra* un IBAN, scivola attraverso i controlli ingenui proprio perché ha la forma giusta. Lo **structured output** ti ha dato la forma, e ti ha illuso che fosse anche sostanza.

Il tema di oggi è il **data contract tra LLM e tool**, con l'esempio dell'**IBAN nel JSON Schema del tool calling**: come impedire al modello di infilare un valore plausibile-ma-sbagliato in un campo critico. La tesi in una riga: **lo schema vincola la forma, non la correttezza — e su forma e correttezza servono due strati diversi.** Più un terzo principio, il più importante: su un identificativo critico che *hai già* in una fonte affidabile, l'LLM non deve nemmeno generarlo.

Vediamo tutto, con lo schema, i validatori di dominio (IBAN, codice fiscale, partita IVA, BIC), la policy di abort, e il modo giusto di testarli. È il pezzo che chiude il cerchio con il {{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }} (il controllo dei side effect) e con l'{{ '/it/blog/ocr-fattura-elettronica-accuratezza/' | relative_url }} (i checksum come rete di sicurezza).

## Allucinazione strutturata: perché è peggio del testo libero

Fermiamoci su questo, perché è controintuitivo e decide tutto il resto. Verrebbe da pensare: "se il modello risponde in JSON strutturato invece che in testo libero, è più affidabile". Sbagliato. È più *comodo da processare*, non più *corretto*. E la comodità nasconde il rischio.

Il testo libero è **onestamente inaffidabile**: quando un modello scrive "l'IBAN è più o meno IT60...", nessuno costruisce un bonifico automatico su quella frase. La sua inaffidabilità è visibile, quindi la tratti con cautela.

Il JSON strutturato è **ingannevolmente affidabile**: `{"iban": "IT60X0542811101000000123456"}` ha la forma di un dato certo. Passa un controllo `is not null`, passa un controllo "è una stringa", magari passa persino un controllo regex "inizia con due lettere e ha la lunghezza giusta". E allora il tuo codice si fida, e agisce. Ma nessuno di quei controlli verifica che l'IBAN sia *quello vero del fornitore*: verificano solo che *assomigli* a un IBAN.

Il modello, per come funziona, è una macchina che produce la sequenza *plausibile*. Se gli chiedi un IBAN e nel contesto quello vero è ambiguo o assente, lui non dice "non lo so": ne genera uno che *sembra giusto*, con la struttura corretta e cifre verosimili. È il suo mestiere completare in modo plausibile — ed è esattamente ciò che lo rende pericoloso sui dati critici. L'allucinazione strutturata è un'allucinazione vestita da dato certo.

La conseguenza operativa: **la conformità allo schema non è correttezza.** Un JSON valido secondo lo schema può contenere un valore falso. Ti servono due strati distinti — la forma (schema) e la sostanza (validazione di dominio) — e per i campi più critici, una regola in più: non farlo generare affatto dal modello se ce l'hai già.

## JSON Schema e Pydantic come recinto (il primo strato)

Il primo strato è comunque necessario: definire il **contratto strutturale**. Il modello non deve poter restituire qualsiasi cosa; deve restituire esattamente la forma che il tuo tool si aspetta. Questo si fa con un JSON Schema (nel function calling) e/o con un modello **Pydantic** lato codice.

Cosa vincola questo strato:

- **I campi presenti e obbligatori:** `iban`, `importo`, `beneficiario` devono esserci.
- **I tipi:** `importo` è un numero, non una stringa "milleduecento".
- **I formati di base:** `iban` è una stringa che rispetta un pattern (due lettere, due cifre, poi alfanumerici, lunghezza plausibile).
- **Gli enum:** `valuta` è "EUR", non testo libero.

Un JSON Schema di esempio per il tool "prepara bonifico":

```json
{
  "name": "prepara_bonifico",
  "parameters": {
    "type": "object",
    "additionalProperties": false,
    "required": ["iban", "importo", "beneficiario", "valuta"],
    "properties": {
      "iban": {
        "type": "string",
        "pattern": "^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$"
      },
      "importo":     { "type": "number", "exclusiveMinimum": 0 },
      "beneficiario":{ "type": "string", "minLength": 2 },
      "valuta":      { "type": "string", "enum": ["EUR"] }
    }
  }
}
```

E lo stesso contratto come modello **Pydantic**, lato codice, dove poi aggancerò la validazione di dominio:

```python
from pydantic import BaseModel, field_validator
from decimal import Decimal

class Bonifico(BaseModel):
    iban: str
    importo: Decimal
    beneficiario: str
    valuta: str = "EUR"

    @field_validator("iban")
    @classmethod
    def formato_iban(cls, v: str) -> str:
        import re
        if not re.match(r"^[A-Z]{2}\d{2}[A-Z0-9]{11,30}$", v.replace(" ", "")):
            raise ValueError("IBAN: formato non valido")
        return v.replace(" ", "")
```

Attenzione: `additionalProperties: false` e il `pattern` sull'IBAN sono utili ma **fermano solo la forma sbagliata.** Il pattern accetta qualsiasi stringa che *assomigli* a un IBAN, incluso un IBAN inventato con le cifre giuste ma il checksum sbagliato. Il recinto strutturale tiene fuori i mostri evidenti (un `importo` che è testo, un IBAN lungo 4 caratteri), non l'allucinazione ben fatta. Per quella serve il secondo strato.

Il **function calling affidabile** parte da qui — un contratto esplicito — ma non finisce qui. Chi si ferma allo schema ha costruito un recinto con il cancello aperto sul lato che conta.

## Validatori di dominio: IBAN, CF, P.IVA, BIC (il secondo strato)

Il secondo strato è dove separi il dato vero dal plausibile: i **validatori di dominio**. Sono controlli deterministici che sfruttano la struttura matematica degli identificativi. Molti dati critici italiani ed europei hanno cifre di controllo (checksum) proprio per rilevare errori: usale.

### IBAN: il mod-97 (ISO 13616 / ISO 7064)

L'IBAN ha un checksum robusto: le due cifre dopo il codice paese sono un controllo calcolato sul resto. L'algoritmo (mod-97-10): sposti i primi 4 caratteri in fondo, converti le lettere in numeri (A=10, B=11, …, Z=35), interpreti il tutto come un intero gigante, e il resto della divisione per 97 **deve essere 1**. Se non è 1, l'IBAN è certamente sbagliato — che l'abbia inventato un LLM o sbagliato a digitare un umano.

```python
def iban_valido(iban: str) -> bool:
    """Checksum IBAN mod-97 (ISO 13616). Semplificato ma corretto nel metodo."""
    s = iban.replace(" ", "").upper()
    if len(s) < 15 or not s[:2].isalpha() or not s[2:4].isdigit():
        return False
    # sposta i primi 4 caratteri in fondo
    riarrangiato = s[4:] + s[:4]
    # converte lettere in numeri: A=10 ... Z=35
    numerico = "".join(str(ord(c) - 55) if c.isalpha() else c
                        for c in riarrangiato)
    return int(numerico) % 97 == 1

# La validazione IBAN è deterministica: nessun modello, nessun dubbio.
# Un IBAN inventato "plausibile" quasi sempre fallisce questo controllo.
```

Un IBAN allucinato dal modello, con cifre verosimili ma casuali, fallisce il mod-97 nella stragrande maggioranza dei casi. Questo singolo controllo intercetta la maggior parte delle allucinazioni strutturate sull'IBAN. È il motivo per cui la **validazione dell'IBAN** non è un optional: è la rete sotto il trapezio.

### Codice fiscale, partita IVA, BIC

Gli altri identificativi critici hanno le loro difese:

- **Partita IVA italiana:** 11 cifre con checksum tipo Luhn (l'ho descritta nel pezzo sull'accuratezza delle fatture). Un valore che non supera il controllo è sbagliato.
- **Codice fiscale:** 16 caratteri con un carattere di controllo finale calcolato da tabelle su posizioni pari/dispari. Anche qui: se il carattere di controllo non torna, il CF è errato.
- **BIC/SWIFT:** formato rigido (8 o 11 caratteri: 4 banca + 2 paese + 2 località + 3 opzionali di filiale). Non ha un checksum matematico come l'IBAN, ma il formato e la coerenza del codice paese con l'IBAN sono verificabili.

La tabella dei due strati, per chiarezza:

| Strato | Cosa verifica | Esempio | Ferma... |
|--------|---------------|---------|----------|
| Strutturale (JSON Schema / Pydantic) | forma, tipi, pattern | "iban è stringa lunga X" | mostri evidenti |
| Dominio (checksum/formato) | validità del valore | "iban supera il mod-97" | allucinazioni plausibili |

Nota il punto: **serve tutti e due.** Lo schema da solo lascia passare l'IBAN inventato; il validatore di dominio da solo non basta se il modello ti restituisce prosa invece di JSON. Insieme, chiudono forma e sostanza.

## Cosa fare se la validazione fallisce: retry, human, abort

Hai i due strati. Ora la domanda che quasi tutti sbagliano: **cosa fai quando un valore non passa?** La risposta ingenua — "ritento finché non passa" — è, sui campi critici, la più pericolosa di tutte.

Le tre opzioni, e quando usarle:

- **Retry (limitato).** Rimandi al modello l'errore ("l'IBAN fornito non supera il checksum, ricontrolla il documento") e lo fai riprovare, **ma con un tetto** (2-3 tentativi) e **solo se ha senso** che riprovando trovi il valore giusto. Va bene per errori di forma o quando il dato è chiaramente nel contesto e il modello l'ha letto male.
- **Human.** Sopra un certo rischio (un IBAN per un bonifico, un cambio di dati di pagamento), un fallimento di validazione manda a un umano, che verifica sulla fonte. Non è un ripiego: è la scelta corretta quando il costo di sbagliare è alto.
- **Abort.** Fermi tutto e segnali. Quando il dato non c'è, o quando ritentare significherebbe solo generare un altro valore plausibile.

Il pericolo del **retry-finché-passa** su un campo critico: se ritenti dieci volte, prima o poi il modello genera un IBAN che *per caso* supera il mod-97 (un IBAN sintatticamente valido ma comunque non quello giusto). Hai "risolto" l'errore di validazione producendo un dato validato e falso. È il peggior risultato possibile: un valore sbagliato che ora passa i controlli. **Sui campi critici, la validazione fallita non è un invito a riprovare finché non passa: è un segnale di stop.**

La **policy di abort** che consegno:

```python
class ValidazioneFallita(Exception): ...

CAMPI_CRITICI = {"iban", "codice_fiscale", "partita_iva"}

def gestisci_validazione(campo: str, valido: bool, tentativo: int,
                         max_retry: int = 2) -> str:
    if valido:
        return "OK"
    # Campo critico: NON ritentare all'infinito. Umano o abort.
    if campo in CAMPI_CRITICI:
        if tentativo == 0:
            return "RETRY_UNA_VOLTA"     # una chance, poi basta
        return "HUMAN"                    # non generare un altro plausibile
    # Campo non critico: retry limitato, poi abort.
    if tentativo < max_retry:
        return "RETRY"
    return "ABORT"
```

La logica: i campi non critici possono ritentare qualche volta; i campi critici hanno **una** chance di correzione, poi vanno all'umano — mai il loop infinito che finisce per fabbricare un valido-e-falso.

## Strict mode vs "il modello che comunque chiacchiera"

Un problema pratico del tool calling: alcuni modelli, invece di restituire solo il JSON, lo avvolgono in prosa ("Ecco il JSON che hai chiesto:") o in un blocco markdown, o aggiungono un commento dopo. Il tuo parser si aspetta JSON puro e trova spazzatura attorno. È il classico "parse-and-pray".

La difesa è lo **strict mode** (o constrained decoding / grammar-constrained generation): il modello è *vincolato* a produrre output che rispetta la grammatica JSON dello schema, token per token. Non può "chiacchierare": la decodifica stessa impedisce di uscire dallo schema. Dove disponibile (molte API e molti runtime self-hosted lo supportano), è il modo giusto per garantire la forma.

Ma — onestà — **lo strict mode garantisce la forma, non la sostanza.** Ti dà JSON valido secondo lo schema; non ti dà un IBAN corretto. È il primo strato reso solido, non il secondo. Quindi:

- **Usa lo strict mode** per non dover fare parsing difensivo di prosa attorno al JSON. Elimina un'intera classe di problemi (JSON malformato, testo extra).
- **Ma non confondere "JSON valido garantito" con "dato giusto garantito".** Lo strict mode ti dà un IBAN che *ha la forma* di un IBAN. Il mod-97 ti dice se *è* un IBAN valido. E la fonte affidabile ti dice se è *quello giusto*.

Se il tuo modello o runtime non ha lo strict mode, allora servono parsing difensivo (estrai il JSON dal testo, gestisci le fence markdown) più la validazione a due strati. Con lo strict mode, salti il parsing difensivo ma la validazione di dominio resta obbligatoria. In nessuno scenario lo schema, da solo, ti mette al sicuro.

## L'architettura di riferimento: il data contract

Ecco come dispongo il contratto tra modello e tool. Il confine chiave: **un valore che non supera entrambi gli strati non raggiunge mai il tool, e un identificativo critico presente in una fonte affidabile non lo genera l'LLM.**

```
   LLM ──▶ ┌─────────────────────────────────────────┐
   (tool   │ STRICT / CONSTRAINED OUTPUT              │
    call)  │ JSON che rispetta la grammatica dello    │
           │ schema (forma garantita)                 │
           └───────────────┬─────────────────────────┘
                           ▼
           ┌─────────────────────────────────────────┐
           │ STRATO 1 — STRUTTURALE (Pydantic/Schema) │
           │ tipi, required, pattern, enum            │
           └───────────────┬─────────────────────────┘
                    fallisce│  passa
                     ┌──────┘
                     ▼
           ┌─────────────────────────────────────────┐
           │ STRATO 2 — DOMINIO                        │
           │ IBAN mod-97, CF/P.IVA checksum, BIC       │
           └───────────────┬─────────────────────────┘
                    fallisce│  passa
             ┌──────────────┘
             ▼
   ┌──────────────────────┐        ┌──────────────────────────────┐
   │ POLICY reject:        │        │ Campo critico presente in     │
   │ retry(bounded)/human/ │        │ FONTE AFFIDABILE (XML già      │
   │ abort                 │        │ parsato)? → COPIA, non generare│
   └──────────────────────┘        └───────────────┬──────────────┘
                                                    ▼
                                        ┌──────────────────────┐
                                        │ TOOL (bonifico, ecc.) │
                                        └──────────────────────┘
```

**Cosa NON fa mai il sistema (i confini):**

- Non passa al tool un valore che fallisce lo strato strutturale **o** quello di dominio.
- Non ritenta all'infinito su un campo critico: una chance, poi umano/abort.
- **Non fa generare all'LLM un identificativo critico che esiste già in una fonte affidabile:** lo copia da lì.

Questo è il legame diretto con il controllo dei side effect: il payload che arriva al tool di scrittura o pagamento — quello che nel {{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }} finisce in coda di approvazione — deve prima aver superato il data contract. Schema e validazione sono il primo cancello; la coda di approvazione è il secondo. Difesa a strati.

## Quando NON usare l'LLM: copia dall'XML già parsato

Questo è il principio che risolve il problema alla radice, ed è quello che i progetti "AI-first" dimenticano. **Se il dato critico esiste già in una fonte strutturata affidabile, non chiedere all'LLM di estrarlo: copialo.**

L'esempio è la fattura elettronica. L'IBAN, la partita IVA, il totale stanno **nell'XML FatturaPA**, in campi etichettati, esatti. Se il tuo agente deve preparare un bonifico da una fattura elettronica, l'IBAN lo prende dal parser XML (deterministico, 100% corretto), **non** lo fa "estrarre" all'LLM dal PDF renderizzato. Far generare all'LLM un IBAN che hai già esatto nell'XML è creare un rischio di allucinazione su un dato che era certo. È l'autogol che ho descritto parlando dell'{{ '/it/blog/ocr-fattura-elettronica-accuratezza/' | relative_url }}: leggere l'XML, non "vederlo".

La gerarchia di fiducia per un campo critico, dall'alto in basso:

1. **Fonte strutturata affidabile** (XML FatturaPA, anagrafica verificata, database): copia il valore. Nessun LLM.
2. **Fonte semi-strutturata** (documento con testo estraibile): estrazione mirata + validazione di dominio.
3. **Fonte non strutturata** (scansione, testo libero): estrazione LLM/vision + validazione + **conferma umana**, perché qui il rischio è massimo.

La regola: **l'LLM è l'ultima risorsa per i dati critici, non la prima.** È bravissimo a capire linguaggio, a riassumere, a decidere quale tool chiamare. È inaffidabile come *sorgente* di un identificativo esatto. Usa il modello per orchestrare e comprendere, non per generare l'IBAN che potresti copiare da una fonte certa. Questo, più di ogni validazione, è ciò che elimina l'allucinazione strutturata: **non chiedere al modello ciò che già sai.**

## Test: 100 IBAN veri, 100 finti (dataset sintetico)

I validatori vanno testati, e la cosa bella è che li testi **senza il modello**. Un validatore di dominio è codice deterministico: gli dai input noti e verifichi l'output. Il modo giusto è un **dataset sintetico**.

- **100 IBAN validi** (generati rispettando il mod-97, o presi da elenchi di IBAN di test pubblici): il validatore deve accettarli tutti. Un falso negativo (rifiuta un IBAN valido) è un bug che blocca lavoro legittimo.
- **100 IBAN finti** (stringhe della forma giusta ma con checksum sbagliato — cioè esattamente il tipo di allucinazione che il modello produce): il validatore deve rifiutarli tutti. Un falso positivo (accetta un IBAN finto) è il bug che ti fa passare l'allucinazione.

```python
import random

def genera_iban_valido() -> str:
    """Genera un IBAN italiano sintetico con checksum corretto (per test)."""
    bban = "".join(random.choices("0123456789", k=23))
    resto = "IT00" + bban
    numerico = "".join(str(ord(c)-55) if c.isalpha() else c
                       for c in (bban + "IT00"))
    check = 98 - (int(numerico) % 97)
    return f"IT{check:02d}{bban}"

def test_validatore():
    validi = [genera_iban_valido() for _ in range(100)]
    # finti: prendo un valido e cambio una cifra (rompe il checksum)
    finti = []
    for v in validi:
        pos = random.randint(4, len(v)-1)
        nuova = str((int(v[pos]) + 1) % 10)
        finti.append(v[:pos] + nuova + v[pos+1:])

    assert all(iban_valido(v) for v in validi), "FALSO NEGATIVO: rifiuta validi"
    assert not any(iban_valido(f) for f in finti), "FALSO POSITIVO: accetta finti"
    print("OK: 100 validi accettati, 100 finti rifiutati")
```

Il punto metodologico: **testi il validatore, non il modello.** Il modello allucinerà — è nella sua natura, non lo "aggiusti" con un test. Ciò che puoi garantire è che il tuo *filtro* catturi le allucinazioni. Il dataset sintetico di finti è la simulazione di ciò che il modello ti tirerà addosso, e il test dimostra che il filtro tiene. Questo test gira a ogni deploy: se un domani qualcuno "ottimizza" il validatore e introduce un falso positivo, il test lo becca prima della produzione.

## Log del reject senza salvare l'IBAN in chiaro

Quando una validazione fallisce, lo logghi — ti serve per capire quanto spesso il modello sbaglia e su cosa. Ma attenzione: **un IBAN, un codice fiscale, una partita IVA sono dati personali/sensibili.** Loggarli in chiaro a ogni reject crea un archivio di dati che non dovresti avere, con i problemi GDPR che ne derivano (come per l'osservabilità: la PII si redige prima dello storage).

Come logghi un reject in modo utile ma sicuro:

- **Non salvare il valore grezzo.** Salvi il *fatto* (validazione IBAN fallita), il *tipo* di errore (checksum vs formato), e al massimo una versione **mascherata** o un hash, mai le cifre in chiaro.
- **Salvi il contesto utile** per il debug: quale agente, quale run, quale tentativo, quale fonte del dato — senza il dato stesso.

```python
import hashlib

def log_reject(store, run_id: str, campo: str, valore: str, motivo: str):
    """Logga il fallimento SENZA salvare l'identificativo in chiaro."""
    mascherato = (valore[:4] + "…" + valore[-2:]) if len(valore) > 6 else "…"
    store.save({
        "run_id": run_id,
        "campo": campo,
        "esito": "reject",
        "motivo": motivo,                      # es. "checksum_iban_fallito"
        "valore_mascherato": mascherato,       # IT60…56, mai tutto
        "valore_hash": hashlib.sha256(valore.encode()).hexdigest()[:16],
    })
    # con l'hash puoi contare "quante volte lo stesso valore errato" senza
    # conservarlo; con la maschera hai un aggancio per il debug.
```

Così ottieni la metrica che ti serve — "quanti reject IBAN questa settimana, per checksum" — senza costruire un elenco di IBAN reali nei log. La maschera (`IT60…56`) basta per il debug incrociato con la fonte; l'hash permette di contare le ripetizioni senza conservare il valore. È osservabilità utile e conforme insieme.

## Percorso di implementazione, a step

1. **Definisci il data contract:** JSON Schema per il tool + modello Pydantic lato codice, con tipi, required, pattern, enum.
2. **Attiva lo strict mode / constrained decoding** dove il modello lo supporta, per garantire la forma senza parsing difensivo.
3. **Implementa i validatori di dominio:** IBAN (mod-97), CF, P.IVA, BIC. Deterministici, senza modello.
4. **Aggancia i validatori** ai campi critici del modello Pydantic, così la validazione è parte del contratto.
5. **Definisci la gerarchia di fiducia:** per ogni campo critico, decidi se copiarlo da una fonte affidabile o farlo estrarre (e con quale livello di conferma).
6. **Scrivi la policy di reject:** retry limitato per i non critici, una-chance-poi-umano per i critici, abort quando ritentare non ha senso.
7. **Costruisci il dataset sintetico** (validi + finti) e i test dei validatori, da eseguire a ogni deploy.
8. **Logga i reject** in modo redatto (maschera + hash), mai valori critici in chiaro.
9. **Collega al controllo dei side effect:** il payload validato entra nel flusso di approvazione/kill switch prima dell'azione reale.

## I fallimenti tipici e come li riconosci dai log

- **IBAN che passano lo schema ma falliscono il mod-97.** Se logghi i reject per motivo, un tasso alto di `checksum_iban_fallito` significa che il modello sta allucinando IBAN. Se quel tasso è alto, quasi certamente stai chiedendo all'LLM un dato che dovresti copiare da una fonte affidabile.
- **Loop di retry sui campi critici.** Se vedi lo stesso `run_id` ritentare più volte un IBAN, la policy di reject è sbagliata: sta ritentando finché non passa, col rischio di fabbricare un valido-e-falso. Deve fermarsi a una chance.
- **JSON con prosa attorno.** Errori di parsing perché il modello ha aggiunto testo: manca lo strict mode, o va aggiunto il parsing difensivo. Logga i fallimenti di parse distinti dai fallimenti di validazione.
- **Falsi positivi del validatore.** Se un IBAN valido reale viene rifiutato, hai un bug nel validatore (o normalizzi male gli spazi/maiuscole). Il dataset sintetico dovrebbe averlo preso; se sfugge in produzione, aggiungi il caso al test.
- **Valori critici in chiaro nei log.** Se apri i log dei reject e vedi IBAN interi, la redaction non è attiva su quel percorso. Audita.
- **Schema che "si rompe" dopo un cambio di modello.** Un nuovo modello può cambiare il modo in cui rispetta lo schema: un picco di reject strutturali dopo un cambio è una regressione (lo stesso allarme "schema JSON rotto" dell'osservabilità).

La regola: **logga il motivo del reject, non il valore.** Il motivo (`checksum_iban_fallito`, `formato_cf`, `parse_error`) ti dice *cosa* migliorare; il valore in chiaro ti dà solo un problema GDPR.

## Costi: ordini di grandezza

Stime dichiarate.

- **Validatori di dominio:** codice deterministico, costo di sviluppo di poche ore (IBAN, CF, P.IVA, BIC sono algoritmi noti), costo di esecuzione **nullo rilevante** (girano in microsecondi su CPU). Nessun token, nessuna GPU.
- **Strict mode:** dove supportato, non aggiunge costo apprezzabile; anzi, riducendo i retry da JSON malformato, spesso *risparmia* token.
- **Costo dei retry evitati:** ogni retry è una chiamata al modello in più, cioè token e latenza. Una policy di reject sensata (niente loop) e la copia dei dati dalla fonte affidabile (niente estrazione inutile) **riducono** i token spesi.
- **Costo di sviluppo del data contract:** schema + Pydantic + validatori + dataset di test, come ordine di grandezza **una-due giornate/uomo** per un set di tool. Investimento una tantum.
- **Costo del non farlo:** un IBAN allucinato che diventa un bonifico verso il conto sbagliato. Perdita economica diretta, spesso non recuperabile, più il tempo di bonifica. Confrontato con un giorno di sviluppo di validatori, il conto è impietoso.

## Quando NON farlo (o farlo diversamente)

- **Se il dato critico è in una fonte affidabile, non farlo generare all'LLM affatto:** copialo. Non ti serve un validatore per un valore che hai già esatto — ti serve non chiederlo al modello. Il validatore è per quando *devi* estrarre da fonti incerte.
- **Se un campo non è critico** (una descrizione, una nota), non appesantirlo con validazione di dominio: lo schema strutturale basta. La validazione pesante si concentra dove il danno è reale.
- **Se ti trovi a ritentare all'infinito per far passare la validazione**, fermati: stai risolvendo il sintomo (validazione fallita) creando il problema (valido-e-falso). Meglio un umano.
- **Se non puoi redigere i valori nei log**, non loggare i valori critici: logga solo il motivo. Un archivio di IBAN nei log di debug è un problema che si crea da solo.
- **Se il caso non tocca dati critici** (un agente che riassume, che classifica testo), il data contract può essere leggero: lo schema per la forma basta, senza l'apparato di validazione di dominio pensato per identificativi finanziari.

## Checklist operativa prima di andare live

- [ ] **Data contract definito:** JSON Schema + modello Pydantic con tipi, required, pattern, enum.
- [ ] **Strict mode / constrained decoding** attivo dove supportato; altrimenti parsing difensivo.
- [ ] **Validatori di dominio** per IBAN (mod-97), CF, P.IVA, BIC, agganciati ai campi critici.
- [ ] **Gerarchia di fiducia** definita: campi critici copiati dalla fonte affidabile quando esiste.
- [ ] **Policy di reject** scritta: retry limitato per i non critici, una-chance-poi-umano per i critici, abort dove serve.
- [ ] **Nessun retry infinito** sui campi critici (niente valido-e-falso).
- [ ] **Dataset sintetico** (100 validi + 100 finti) e test dei validatori a ogni deploy.
- [ ] **Log dei reject redatti:** motivo + maschera + hash, mai valori critici in chiaro.
- [ ] **Collegamento al controllo dei side effect:** il payload validato entra nel flusso di approvazione/kill switch.
- [ ] **Allarme su picchi di reject** (indica allucinazione crescente o cambio modello).

## Il verdetto

Il **JSON Schema nel tool calling** è necessario ma non sufficiente, e credere il contrario è il modo più elegante per farsi inventare un IBAN. Lo structured output ti dà la forma — un JSON pulito, tipi giusti, campi presenti — e ti illude che sia anche sostanza. Non lo è. Un modello, sui dati critici, produce ciò che *sembra* plausibile, e un IBAN plausibile-ma-falso, vestito da JSON valido, è più pericoloso di qualsiasi testo libero, perché scivola attraverso i controlli ingenui.

La difesa è a strati e ha una gerarchia chiara. Lo schema (con strict mode) garantisce la forma. I validatori di dominio — IBAN col mod-97, CF e partita IVA col loro checksum — garantiscono che il valore sia *un* valore valido. La policy di reject impedisce il loop che fabbrica un valido-e-falso: sui campi critici, una chance e poi un umano, mai il retry all'infinito. E sopra tutto, il principio che risolve il problema alla fonte: **su un identificativo critico che hai già in una fonte affidabile — l'XML della fattura, l'anagrafica — l'LLM non deve nemmeno generarlo. Copialo.** Il modello orchestra e comprende; non è la sorgente dei tuoi IBAN.

Fatto così, hai un agente che chiama i tool con dati di cui ti puoi fidare, e che si ferma invece di indovinare quando il dato non torna. Fatto fidandosi dello schema, hai un generatore di valori plausibili che un giorno manda un bonifico nel posto sbagliato. La differenza non è quanto è "intelligente" il modello. È se hai messo il recinto sul lato che conta — la correttezza — e non solo su quello comodo, la forma.

Se stai dando a un agente la capacità di chiamare tool che toccano IBAN, pagamenti o anagrafiche, e vuoi un data contract che regga davvero, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Data contracts e validazione, non fiducia cieca nello schema.

## FAQ

### Lo structured output non garantisce già che il dato sia corretto?
No. Garantisce la *forma*: che l'output sia un JSON valido secondo lo schema, con i tipi e i campi giusti. Non garantisce la *correttezza del valore*: un IBAN con la forma giusta ma inventato passa lo schema. Servono due strati distinti — quello strutturale (schema) e quello di dominio (checksum) — perché la conformità allo schema e la validità del dato sono due cose diverse.

### Perché un IBAN inventato è più pericoloso di una risposta in testo libero?
Perché il testo libero è onestamente inaffidabile — nessuno costruisce un bonifico su "l'IBAN dovrebbe essere circa..." — mentre un JSON pulito con un campo `iban` sembra un dato certo e passa i controlli ingenui. L'allucinazione strutturata è ingannevole proprio perché ha la forma giusta: scivola nei sistemi che si fidano dello schema. Ecco perché serve il validatore di dominio.

### Come valido un IBAN in modo affidabile?
Con il checksum mod-97 (ISO 13616): sposti i primi quattro caratteri in fondo, converti le lettere in numeri (A=10…Z=35), interpreti il tutto come intero e verifichi che il resto della divisione per 97 sia 1. È deterministico e cattura la stragrande maggioranza degli IBAN inventati o digitati male. È un controllo di poche righe che intercetta l'allucinazione più costosa.

### Cosa faccio quando la validazione di un campo critico fallisce?
Non ritenti all'infinito. Sui campi critici (IBAN, CF, P.IVA) dai al massimo una chance di correzione, poi mandi a un umano o abortisci. Il retry-finché-passa è pericoloso: ritentando abbastanza, il modello può generare un valore che per caso supera il checksum ma resta sbagliato — hai prodotto un valido-e-falso, il peggior risultato. La validazione fallita su un campo critico è un segnale di stop, non un invito a riprovare.

### Cos'è lo strict mode e mi mette al sicuro?
È il constrained decoding: il modello è vincolato a produrre output che rispetta la grammatica dello schema, token per token, così non può avvolgere il JSON in prosa o markdown. Elimina i problemi di parsing, ma garantisce solo la *forma*, non la *sostanza*: ti dà un IBAN ben formato, non un IBAN corretto. Usalo per evitare il parsing difensivo, ma tieni comunque la validazione di dominio.

### Devo far estrarre l'IBAN all'LLM dalla fattura?
Se hai l'XML FatturaPA, no: l'IBAN è lì, in un campo etichettato, esatto. Lo copi dal parser XML, non lo fai "estrarre" all'LLM dal PDF. Far generare al modello un dato che hai già certo introduce un rischio di allucinazione su un valore che era sicuro. L'LLM è l'ultima risorsa per i dati critici, non la prima: usalo dove il dato è davvero solo in testo non strutturato, e lì con validazione e conferma umana.

### Come testo i validatori senza dipendere dal modello?
Con un dataset sintetico: 100 IBAN validi (che il validatore deve accettare tutti) e 100 finti con checksum rotto (che deve rifiutare tutti). Testi il *filtro*, non il modello: il modello allucinerà comunque, ciò che garantisci è che il tuo validatore catturi le allucinazioni. Il test gira a ogni deploy, così una modifica che introduce un falso positivo viene bloccata prima della produzione.

### Come logghi i fallimenti senza violare la privacy?
Non salvi il valore in chiaro. Salvi il fatto (validazione fallita), il motivo (checksum vs formato), una versione mascherata (IT60…56) e/o un hash. Così ottieni le metriche utili — quanti reject IBAN, per quale motivo — senza costruire un archivio di IBAN reali nei log, che sarebbe un problema GDPR. L'hash ti permette anche di contare le ripetizioni dello stesso valore errato senza conservarlo.

### Pydantic o JSON Schema puro?
Si completano. Il JSON Schema definisce il contratto verso il modello nel function calling (cosa deve restituire). Pydantic lo applica lato codice e — soprattutto — ti permette di agganciare i validatori di dominio come `field_validator`, così la validazione di IBAN e checksum è parte integrante del modello di dati, non un controllo sparso. In pratica: schema per il contratto col modello, Pydantic per validare e far rispettare il contratto nel tuo codice.

### Questo vale solo per l'IBAN?
No, l'IBAN è l'esempio più costoso, ma il principio vale per ogni identificativo critico: codice fiscale, partita IVA, BIC, codici prodotto, numeri di contratto. Ogni volta che un campo ha una struttura verificabile (checksum, formato rigido) e un costo alto se sbagliato, applichi i due strati e la gerarchia di fiducia: copia dalla fonte affidabile se esiste, altrimenti estrai e valida, e sui casi ad alto rischio aggiungi la conferma umana.
