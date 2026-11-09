---
lang: it
permalink: /it/blog/validazione-iban-codice-fiscale-partita-iva/
title: "IBAN, codice fiscale e partita IVA: validatori prima dell'LLM (checksum, e il divieto di \"completare\" un identificativo mancante)"
date: 2026-11-15 07:30:00 +0200
author: "Antonio Trento"
description: "Una libreria di validazione italiana davanti al modello: carattere di controllo del codice fiscale con omocodia, cifra di controllo della partita IVA, IBAN con modulo 97 e CIN italiano. Ordine della pipeline, policy no-invent, test su dataset sintetico, UX dell'illeggibile, log senza CF in chiaro e integrazione come tool MCP o servizio per n8n."
keywords: ["validazione iban codice fiscale partita iva", "checksum codice fiscale", "partita iva algoritmo", "llm allucinazione identificativi", "validatori python", "iban mod 97"]
image: /assets/images/posts/validazione-iban-codice-fiscale-partita-iva.jpg
pillar: rag-documenti
related: [/it/blog/json-schema-tool-calling-iban/, /it/blog/accuratezza-estrazione-documenti-campi/]
---

## Il codice fiscale che nessuno aveva scritto

Il documento era una scansione storta di un modulo compilato a mano: una richiesta di rimborso, con nome, cognome, data di nascita, codice fiscale e IBAN. Il codice fiscale era parzialmente coperto da un timbro: si leggevano i primi undici caratteri, poi una macchia. La pipeline di estrazione — OCR più un modello linguistico che riempie un JSON — ha restituito un codice fiscale completo di sedici caratteri. Formato perfetto. Il carattere di controllo finale? Plausibile. Nessuno se n'è accorto, perché il campo era "pieno" e la UI lo mostrava in verde.

Quel codice fiscale non apparteneva a nessuno. Le ultime cinque posizioni le aveva scritte il modello: codice del comune "verosimile" per la zona del documento, carattere di controllo indovinato. È passato perché nessuno aveva messo tra il modello e il gestionale l'unica cosa che lo avrebbe fermato con certezza: un validatore deterministico. In un altro caso, lo stesso schema ha prodotto una partita IVA di undici cifre "completata" a partire da nove leggibili, e un IBAN con due cifre del conto inventate. L'IBAN, almeno, è stato fermato da un controllo del modulo 97 sul gestionale della banca. Il resto no.

Questo pezzo è sulla **validazione di IBAN, codice fiscale e partita IVA prima dell'LLM** — più precisamente, *dopo* l'estrazione e *prima* che il dato entri in qualsiasi sistema. Una libreria di validazione italiana, deterministica, testata, messa davanti al modello come un portiere. E una policy scritta in una riga: **il sistema non completa mai un identificativo mancante o illeggibile**. Un campo illeggibile è un'informazione utile; un campo inventato è un danno.

## È per te / non è per te

È per te se:

- estrai dati anagrafici o bancari da documenti (moduli, fatture, contratti, email) con OCR, modelli vision o LLM;
- hai agenti o flussi n8n che ricevono identificativi da testo libero e li passano a un gestionale, a un CRM o a una banca;
- hai già visto un identificativo "plausibile" che non esisteva.

Non è per te se gli identificativi ti arrivano già da fonti strutturate e affidabili (XML della fattura elettronica, anagrafiche verificate, API di sistemi certificati): lì la validazione serve comunque, ma il problema dell'invenzione non si pone. E non è un pezzo sulla verifica dell'*esistenza* di un soggetto (che richiede banche dati esterne): qui parliamo di verificare che un identificativo sia *ben formato e coerente*, il primo filtro, il più economico.

## Perché l'LLM completa i buchi con cifre plausibili

Un modello linguistico non "legge" un codice fiscale: genera il carattere successivo più probabile dato quello che ha visto. Se ha visto "RSSMRA80A01H50" e poi una macchia, la continuazione più probabile è una cifra e una lettera, perché ha visto milioni di codici fiscali con quella forma. Non ha un concetto di "non lo so" a livello di singolo carattere, a meno che tu non glielo dia esplicitamente come opzione.

Tre fattori, quasi sempre presenti nelle pipeline, rendono l'invenzione più probabile:

**1. Campi obbligatori nello schema.** Se lo schema JSON dell'output dichiara `codice_fiscale` come stringa obbligatoria di sedici caratteri, e il modello è vincolato a rispettarlo (strict mode, output strutturato), l'unico modo di rispettare lo schema quando il dato manca è inventarlo. Lo schema che doveva proteggerti ti ha costretto all'errore.

**2. Prompt che premiano la completezza.** "Estrai tutti i campi", "non lasciare campi vuoti", "compila il modulo": istruzioni che, per un modello, significano "un campo vuoto è un fallimento".

**3. OCR parziale.** L'OCR restituisce "RSSMRA80A01H5O1U" (con una O al posto dello zero) o "RSSMRA80A01H5 1U" (con uno spazio dove c'era una macchia). Il modello "corregge", ed è utile quando la correzione è ovvia (O → 0 in una posizione numerica); diventa pericoloso quando la correzione è un'invenzione (lo spazio diventa una cifra a caso).

Ho descritto il problema generale — l'allucinazione strutturata, che è peggio di quella in testo libero perché ha l'aspetto di un dato — nel pezzo su [JSON Schema e tool calling con gli IBAN]({{ '/it/blog/json-schema-tool-calling-iban/' | relative_url }}). Qui scendo nel dettaglio dei tre identificativi italiani più comuni e di come costruire una libreria che li controlli tutti, sempre, nello stesso modo.

## Checksum CF e P.IVA: usa algoritmi, non il modello

La buona notizia è che codice fiscale e partita IVA sono stati progettati, decenni fa, con un controllo d'errore incorporato. Gli algoritmi sono pubblici, documentati nei decreti che hanno istituito il codice fiscale e la partita IVA, e implementati in decine di librerie. Non c'è nessun motivo per chiedere a un modello se un codice fiscale "sembra giusto".

### Codice fiscale

Il codice fiscale delle persone fisiche ha sedici caratteri:

- 3 lettere dal cognome, 3 dal nome;
- 2 cifre per l'anno di nascita;
- 1 lettera per il mese (A, B, C, D, E, H, L, M, P, R, S, T);
- 2 cifre per il giorno di nascita (per le donne il giorno è aumentato di 40);
- 4 caratteri per il comune di nascita o lo Stato estero (una lettera e tre cifre);
- 1 **carattere di controllo**.

Il carattere di controllo si calcola sui primi quindici caratteri: a ogni carattere in posizione dispari (prima, terza, quinta…) si assegna un valore da una tabella, a ogni carattere in posizione pari un valore da un'altra tabella; si sommano, si prende il resto della divisione per 26, e lo si converte in una lettera (0 = A, 1 = B, …).

C'è poi l'**omocodia**: quando due persone avrebbero lo stesso codice, l'Agenzia delle Entrate sostituisce alcune cifre con lettere (0 = L, 1 = M, 2 = N, 3 = P, 4 = Q, 5 = R, 6 = S, 7 = T, 8 = U, 9 = V), partendo da destra, e ricalcola il carattere di controllo. Un validatore che accetta solo cifre nelle posizioni numeriche rifiuta codici fiscali veri: è un errore comune nelle validazioni fatte con una regex trovata online.

Le partite IVA delle persone giuridiche fungono anche da codice fiscale (undici cifre): un campo "codice fiscale" in un'anagrafica aziendale può legittimamente contenere undici cifre. Il validatore deve saperlo.

### Partita IVA

La partita IVA italiana ha undici cifre:

- 7 cifre di numero di matricola;
- 3 cifre di codice dell'ufficio provinciale;
- 1 **cifra di controllo**.

La cifra di controllo segue un algoritmo della famiglia Luhn: sulle prime dieci cifre si sommano quelle in posizione dispari così come sono; quelle in posizione pari si raddoppiano, e se il risultato supera 9 si sottrae 9; la cifra di controllo è quella che porta la somma al multiplo di 10 successivo.

### La libreria

Ecco il cuore della libreria, ridotto a ciò che serve. In produzione puoi usare una libreria mantenuta (per Python, `python-stdnum` implementa codice fiscale, partita IVA e IBAN), ma conviene capire cosa fa — e averne una versione tua con i test, perché il comportamento sugli edge case (omocodia, CF numerici, prefisso "IT") deve essere quello che ti aspetti.

```python
import re

_DISPARI = {**dict(zip("0123456789", [1, 0, 5, 7, 9, 13, 15, 17, 19, 21])),
            **dict(zip("ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                       [1, 0, 5, 7, 9, 13, 15, 17, 19, 21, 2, 4, 18, 20,
                        11, 3, 6, 8, 12, 14, 16, 10, 22, 25, 24, 23]))}
_PARI = {**{str(d): d for d in range(10)},
         **{c: i for i, c in enumerate("ABCDEFGHIJKLMNOPQRSTUVWXYZ")}}
_OMOCODIA = dict(zip("LMNPQRSTUV", "0123456789"))
_CF_RE = re.compile(
    r"^[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST][0-9LMNPQRSTUV]{2}"
    r"[A-Z][0-9LMNPQRSTUV]{3}[A-Z]$")

def normalizza(s: str) -> str:
    return re.sub(r"[\s\-\.]", "", s or "").upper()

def cf_carattere_controllo(primi15: str) -> str:
    s = sum(_DISPARI[c] if i % 2 == 0 else _PARI[c] for i, c in enumerate(primi15))
    return chr(ord("A") + s % 26)

def cf_valido(cf: str) -> tuple[bool, str]:
    cf = normalizza(cf)
    if len(cf) == 11:                       # CF numerico di soggetti diversi dalle persone fisiche
        return piva_valida(cf)
    if len(cf) != 16:
        return False, "lunghezza"
    if not _CF_RE.match(cf):
        return False, "formato"
    if cf_carattere_controllo(cf[:15]) != cf[15]:
        return False, "carattere_controllo"
    giorno = int("".join(_OMOCODIA.get(c, c) for c in cf[9:11]))
    if not (1 <= giorno <= 31 or 41 <= giorno <= 71):
        return False, "giorno"
    return True, "ok"

def piva_cifra_controllo(prime10: str) -> int:
    s = 0
    for i, c in enumerate(prime10):
        n = int(c)
        if i % 2 == 1:
            n *= 2
            if n > 9:
                n -= 9
        s += n
    return (10 - s % 10) % 10

def piva_valida(piva: str) -> tuple[bool, str]:
    p = normalizza(piva)
    if p.startswith("IT"):
        p = p[2:]
    if len(p) != 11 or not p.isdigit() or p == "0" * 11:
        return False, "formato"
    if piva_cifra_controllo(p[:10]) != int(p[10]):
        return False, "cifra_controllo"
    return True, "ok"
```

Nota il tipo di ritorno: non un semplice `True/False`, ma un esito con un **motivo**. Il motivo finisce nei log e nella UI, e fa una grande differenza per chi deve correggere: "carattere di controllo errato" suggerisce un errore di lettura su un carattere; "lunghezza" suggerisce un pezzo mancante.

## IBAN: struttura e modulo 97

L'IBAN (standard ISO 13616) ha una struttura comune a tutti i paesi:

- 2 lettere di codice paese;
- 2 cifre di controllo;
- il BBAN, il numero di conto nazionale, con lunghezza e struttura fisse per ogni paese.

Le cifre di controllo si verificano con l'algoritmo **modulo 97** (ISO 7064, MOD 97-10): si spostano i primi quattro caratteri in fondo, si convertono le lettere in numeri (A = 10, B = 11, …, Z = 35), e il numero risultante, diviso per 97, deve dare resto 1.

Per l'Italia il BBAN ha 23 caratteri, per un IBAN di 27:

- 1 lettera di **CIN** (un controllo nazionale);
- 5 cifre di ABI (la banca);
- 5 cifre di CAB (la filiale);
- 12 caratteri di numero di conto.

Il CIN italiano è un secondo controllo, calcolato su ABI, CAB e conto con le stesse tabelle dispari/pari del codice fiscale e il resto della divisione per 26. Un IBAN italiano ben formato supera quindi **due** controlli indipendenti.

```python
IBAN_LUNGHEZZE = {"IT": 27, "SM": 27, "DE": 22, "FR": 27, "ES": 24,
                  "AT": 20, "CH": 21, "NL": 18, "BE": 16}   # estendi dal registro IBAN ufficiale

def iban_mod97(iban: str) -> int:
    r = iban[4:] + iban[:4]
    return int("".join(str(int(c, 36)) for c in r)) % 97

def it_cin(abi_cab_conto: str) -> str:
    s = sum(_DISPARI[c] if i % 2 == 0 else _PARI[c] for i, c in enumerate(abi_cab_conto))
    return chr(ord("A") + s % 26)

def iban_valido(iban: str) -> tuple[bool, str]:
    s = normalizza(iban)
    if not re.match(r"^[A-Z]{2}[0-9]{2}[A-Z0-9]{8,30}$", s):
        return False, "formato"
    attesa = IBAN_LUNGHEZZE.get(s[:2])
    if attesa is None:
        return False, "paese_non_gestito"
    if len(s) != attesa:
        return False, "lunghezza"
    if iban_mod97(s) != 1:
        return False, "mod97"
    if s[:2] in ("IT", "SM"):
        if not re.match(r"^[A-Z][0-9]{10}[A-Z0-9]{12}$", s[4:]):
            return False, "bban_formato"
        if it_cin(s[5:]) != s[4]:
            return False, "cin"
    return True, "ok"
```

Due cose che la libreria **non** fa, e che vanno dette chiaramente a chi la usa:

- non verifica che il conto esista o che appartenga a quel beneficiario: per quello servono servizi bancari di verifica del beneficiario, che sono un altro livello;
- `paese_non_gestito` non significa "IBAN sbagliato": significa "non so validarlo". Va trattato come incertezza, non come errore. La tabella delle lunghezze va estesa dal registro IBAN ufficiale per tutti i paesi con cui lavori.

### Cosa intercettano davvero questi controlli

Ho misurato la libreria su un dataset sintetico (più sotto come è costruito): 20.000 identificativi validi per tipo, a cui ho applicato due tipi di errore tipici della lettura, la sostituzione di un carattere e lo scambio di due caratteri adiacenti.

| Identificativo | Controllo | Sostituzione di un carattere rilevata | Scambio di due caratteri adiacenti rilevato |
|---|---|---|---|
| Partita IVA | cifra di controllo (Luhn) | 100% | ~97% (sfugge lo scambio 0↔9) |
| Codice fiscale | carattere di controllo mod 26 | 100% (nella stessa classe lettera/cifra) | ~99,9% |
| IBAN italiano | mod 97 + CIN | 100% | 100% |

Il limite noto della partita IVA — lo scambio tra 0 e 9 adiacenti non cambia la somma — è una proprietà dell'algoritmo, non un bug. Ma la tabella dice una cosa più importante: **un valore inventato da un modello**, che non è una piccola mutazione di uno vero ma una sequenza plausibile, supera il controllo solo per caso: circa una volta su dieci per la partita IVA, una su ventisei per il codice fiscale, molto più raramente per un IBAN italiano. Il validatore ferma quasi tutto, e per il resto servono gli altri strati (verifica nel testo sorgente, anagrafica, persona).

## Pipeline: extract → validate → else human

L'ordine dei passaggi è la parte più importante. Lo stesso validatore, messo nel punto sbagliato, serve a poco.

### Ordine della pipeline

1. **Estrazione grezza** del testo (OCR o testo nativo del documento). Si conserva com'è, con le coordinate se il documento è una scansione.
2. **Estrazione dei candidati** da parte del modello, con tre stati possibili per ogni identificativo: `letto` (con il valore e il frammento di testo da cui viene), `illeggibile` (il campo c'è ma non si legge), `assente` (il campo non c'è nel documento). Lo schema dell'output **deve** permettere gli stati `illeggibile` e `assente`: nessun campo identificativo è obbligatorio come stringa.
3. **Normalizzazione deterministica**: maiuscole, rimozione di spazi e separatori, correzioni di confusione OCR *solo* dove la posizione lo rende univoco (una O in una posizione che nel codice fiscale può essere solo numerica diventa 0; una O in una posizione che può essere lettera resta O).
4. **Verifica di presenza nel sorgente**: il valore normalizzato deve comparire nel testo grezzo normalizzato (con le stesse correzioni univoche). Se il modello restituisce un codice fiscale che non c'è nel testo, è un'invenzione, anche se è valido.
5. **Validazione di formato e checksum** con la libreria.
6. **Controlli di coerenza**: il codice fiscale è coerente con data di nascita e sesso estratti dallo stesso documento? La partita IVA del fornitore corrisponde a quella in anagrafica per quella ragione sociale? L'IBAN è quello già registrato per quel fornitore o è nuovo?
7. **Decisione**: se tutto passa, il valore prosegue; se qualcosa fallisce, il campo va a una persona con il motivo e il ritaglio del documento. **Altrimenti, umano** — mai "altrimenti, chiedi di nuovo al modello finché non passa".

Il punto 7 merita una riga in più. Rimandare al modello un identificativo che non ha superato il checksum, con il messaggio "il carattere di controllo è errato, correggilo", è il modo più rapido per ottenere un identificativo inventato **che supera il checksum**. Il modello non ha più informazioni di prima; ha solo un vincolo in più da soddisfare, e lo soddisfa inventando meglio.

### Policy no-invent

La scrivo così, ed è il testo che metto sia nel prompt sia nella documentazione del processo, sia — soprattutto — nel codice:

> **Il sistema non completa, non corregge per deduzione e non ricostruisce identificativi (codice fiscale, partita IVA, IBAN, numeri di documento) mancanti, parziali o illeggibili.** Un identificativo viene accettato solo se è letto per intero nel documento sorgente e supera i controlli di formato, checksum e coerenza. In ogni altro caso il campo è marcato come illeggibile o assente e viene sottoposto a una persona. Non è consentito rigenerare un identificativo respinto chiedendo al modello di correggerlo.

Nel prompt da sola non basta: il modello può ignorarla. È il codice che la fa rispettare, con la verifica di presenza nel sorgente e il rifiuto dei retry sul modello.

```python
from dataclasses import dataclass

@dataclass
class Esito:
    campo: str
    stato: str          # "valido" | "illeggibile" | "assente" | "non_valido" | "non_nel_sorgente" | "incoerente"
    valore: str | None
    motivo: str | None

VALIDATORI = {"codice_fiscale": cf_valido, "partita_iva": piva_valida, "iban": iban_valido}

def verifica_identificativo(campo: str, candidato: dict, testo_sorgente_norm: str) -> Esito:
    stato = candidato.get("stato")
    if stato in ("illeggibile", "assente"):
        return Esito(campo, stato, None, None)          # un buco resta un buco
    valore = normalizza(candidato.get("valore", ""))
    if valore not in testo_sorgente_norm:
        return Esito(campo, "non_nel_sorgente", None, "valore non presente nel documento")
    ok, motivo = VALIDATORI[campo](valore)
    if not ok:
        return Esito(campo, "non_valido", valore, motivo)  # niente retry sul modello
    return Esito(campo, "valido", valore, None)
```

## Test su dataset sintetico (non dati veri di clienti)

Per testare una libreria di validazione servono migliaia di identificativi validi e non validi. La tentazione è prenderli dal gestionale: "abbiamo 40.000 clienti, usiamo quelli". È una pessima idea: stai copiando dati personali in un ambiente di test, magari in un repository, magari in una CI su un servizio esterno, per uno scopo per cui non li hai raccolti.

Non serve. Gli identificativi italiani si possono **generare** in modo sintetico, validi per costruzione, perché gli algoritmi sono pubblici:

- **partite IVA**: dieci cifre casuali (con un codice ufficio plausibile), più la cifra di controllo calcolata;
- **codici fiscali**: lettere e cifre casuali nelle posizioni giuste (mese da tabella, giorno nei range ammessi, codice comune di formato corretto), più il carattere di controllo calcolato; alcuni con omocodia;
- **IBAN italiani**: ABI, CAB e conto casuali, CIN calcolato, cifre di controllo calcolate con il modulo 97.

Poi si generano le **mutazioni** che simulano gli errori reali:

- sostituzione di un carattere (errore di lettura OCR: 0/O, 1/I/L, 5/S, 8/B);
- scambio di due caratteri adiacenti (errore di digitazione);
- troncamento (un pezzo mancante);
- caratteri in più (un trattino, uno spazio letto come carattere);
- valori "plausibili" interamente casuali con il formato giusto (la simulazione dell'invenzione).

E i **casi limite** da coprire esplicitamente: omocodia, codici fiscali numerici di persone giuridiche, partite IVA con prefisso "IT", IBAN scritti a gruppi di quattro con spazi, IBAN di San Marino (stessa struttura italiana), IBAN esteri di paesi non gestiti.

```python
import random

def genera_piva(rng: random.Random) -> str:
    base = "".join(rng.choice("0123456789") for _ in range(7)) + rng.choice(["001", "015", "058", "088", "100"])
    return base + str(piva_cifra_controllo(base))

def genera_iban_it(rng: random.Random) -> str:
    abi = f"{rng.randint(1000, 9999):05d}"
    cab = f"{rng.randint(1000, 99999):05d}"
    conto = "".join(rng.choice("0123456789") for _ in range(12))
    bban = it_cin(abi + cab + conto) + abi + cab + conto
    controllo = 98 - int("".join(str(int(c, 36)) for c in bban + "IT00")) % 97
    return f"IT{controllo:02d}{bban}"

def test_sostituzione_piva_rilevata():
    rng = random.Random(7)
    for _ in range(5000):
        p = genera_piva(rng)
        i = rng.randrange(11)
        q = p[:i] + rng.choice([c for c in "0123456789" if c != p[i]]) + p[i + 1:]
        assert not piva_valida(q)[0]
```

Il generatore usa un seme fisso: i test sono ripetibili, e un fallimento si riproduce. Il dataset sintetico non contiene nessun dato reale, può stare nel repository e girare in qualsiasi CI. È lo stesso approccio — cento valori veri e cento finti, ma tutti generati — che descrivo nel pezzo sul tool calling.

## UX: "campo illeggibile" ≠ "campo inventato"

La validazione serve a poco se l'interfaccia poi tratta allo stesso modo un campo valido, un campo illeggibile e un campo vuoto. L'errore UX più comune è **pre-compilare** il campo con l'ipotesi del modello e colorarlo di giallo: l'operatore, che ne vede cinquanta al giorno, conferma il giallo come conferma il verde.

Le regole che uso:

- **Valido**: il valore è mostrato normalmente, con un'icona discreta di "verificato" e la possibilità di vedere il ritaglio del documento.
- **Illeggibile**: il campo è **vuoto**, con l'etichetta "illeggibile nel documento" e il ritaglio dell'area in cui dovrebbe essere. L'operatore lo digita guardando il ritaglio o il documento originale. Nessun suggerimento pre-compilato.
- **Assente**: il campo è vuoto con l'etichetta "non presente nel documento". Spesso è un'informazione corretta (un DDT non ha l'IBAN): l'operatore deve poter confermare "non serve".
- **Non valido**: il valore letto è mostrato **barrato** o in un'area separata, con il motivo in italiano ("il carattere di controllo non corrisponde: probabile errore di lettura in una posizione"), e il campo di inserimento è vuoto. Si vede cosa è stato letto, ma per confermarlo bisogna riscriverlo.
- **Non nel sorgente**: è il segnale dell'invenzione. Il valore non va mostrato come suggerimento; al massimo, in un log per chi mantiene il sistema.

Quando l'operatore digita il valore, la stessa libreria lo valida in tempo reale, con lo stesso messaggio. Una sola implementazione per pipeline e interfaccia: se la libreria cambia, cambiano entrambe.

## Log: non conservare CF in chiaro più del necessario

Codici fiscali e IBAN sono dati personali. Una pipeline che li valida produce log, e i log tendono a vivere più a lungo dei dati stessi, a essere copiati in strumenti di osservabilità, a finire in ticket e screenshot. Tre accorgimenti:

**1. Mascherare nei log applicativi.** Nei log di validazione non serve il valore completo. Basta il tipo, l'esito, il motivo e un riferimento al documento. Se serve correlare più eventi sullo stesso identificativo, si usa un **HMAC** del valore con una chiave tenuta in un segreto: permette di dire "è lo stesso codice fiscale di ieri" senza che il log contenga il codice fiscale.

```json
{"evento": "validazione_identificativo", "doc": "RIMB-2026-00871", "campo": "codice_fiscale",
 "esito": "non_valido", "motivo": "carattere_controllo",
 "mascherato": "RSS***********U", "hmac": "3f9a1c…", "ts": "2026-11-15T10:12:44+01:00"}
```

**2. Mai nei prompt di debug e nel tracing degli LLM in chiaro.** Gli strumenti di osservabilità dei modelli registrano prompt e risposte; se il documento contiene identificativi, il trace li contiene. Redaction prima della registrazione, conservazione breve, accesso ristretto: è il tema del pezzo sull'[osservabilità degli LLM in produzione]({{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}).

**3. Conservazione proporzionata.** I log di validazione con riferimenti mascherati possono vivere a lungo; eventuali log con valori in chiaro (necessari per il debug di un caso specifico) hanno una scadenza breve e un accesso nominativo. Il valore valido vive nel sistema di destinazione (il gestionale), non nella pipeline.

## Integrazione nei tool MCP/n8n

La libreria va resa disponibile **ovunque** un identificativo entri nei sistemi: pipeline di estrazione, agenti, flussi n8n, interfacce. Il modo più semplice per non avere tre implementazioni diverse è esporla come un piccolo **servizio HTTP interno** (stesso codice, testato una volta), e da lì come tool per gli agenti.

### Come tool MCP

Per un agente, la validazione è un tool di sola lettura, sicuro, che conviene esporre sempre. Ma va descritto in modo che il modello lo usi per controllare, non per "aggiustare":

```json
{
  "name": "valida_identificativo",
  "description": "Verifica formato e codice di controllo di un identificativo italiano (codice_fiscale, partita_iva, iban). Restituisce esito e motivo. NON corregge e NON suggerisce valori alternativi. Se l'esito è negativo, il campo va segnalato come da verificare a una persona: non tentare di ricostruire il valore.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "tipo": {"type": "string", "enum": ["codice_fiscale", "partita_iva", "iban"]},
      "valore": {"type": "string", "maxLength": 40}
    },
    "required": ["tipo", "valore"]
  }
}
```

Due regole lato server MCP, che non dipendono dal modello:

- il tool restituisce solo esito e motivo, mai un valore "corretto";
- i tool che **scrivono** identificativi nei sistemi (aggiornare l'IBAN di un fornitore, registrare un codice fiscale) chiamano internamente la stessa validazione e rifiutano valori non validi, qualunque cosa abbia detto il modello. Il controllo vive nel tool di scrittura, non nella buona volontà dell'agente. Il quadro generale dei tool MCP è nel pezzo su [Model Context Protocol spiegato]({{ '/it/blog/model-context-protocol-spiegato/' | relative_url }}).

### In n8n

In n8n la tentazione è copiare la funzione di validazione in un nodo Code in ogni workflow. Funziona, ma dopo sei mesi hai sei versioni leggermente diverse. Meglio:

- un nodo HTTP Request verso il servizio di validazione interno, con l'identificativo nel corpo;
- un nodo IF sull'esito: se valido prosegue, altrimenti il record va in una coda di revisione (una tabella, un task, una notifica alla persona responsabile);
- mai un ramo che rimanda il testo al nodo del modello "per correggere".

Se il servizio è irraggiungibile, il workflow non deve considerare l'identificativo valido per default: deve fermarsi o mandare in revisione. È lo stesso principio del fallire in modo sicuro che vale per qualsiasi controllo.

## Percorso di implementazione, a step

1. **Inventario dei punti di ingresso**: dove entrano codici fiscali, partite IVA e IBAN nei tuoi sistemi (estrazione documenti, form web, email, agenti, import da file).
2. **Scegli o scrivi la libreria**, con esiti e motivi, omocodia, CF numerici, prefissi, normalizzazione.
3. **Scrivi il generatore sintetico** e la suite di test: validi, mutazioni, casi limite. Nessun dato reale.
4. **Esponi la libreria come servizio interno** e, per gli agenti, come tool MCP di sola lettura.
5. **Modifica lo schema di estrazione**: stati `letto`, `illeggibile`, `assente`; nessun identificativo obbligatorio come stringa.
6. **Aggiungi la verifica di presenza nel sorgente** e i controlli di coerenza (CF con data e sesso, P.IVA con anagrafica, IBAN con IBAN già noti).
7. **Togli ogni retry verso il modello** su identificativi respinti.
8. **Aggiorna l'interfaccia** con gli stati distinti e la validazione in tempo reale.
9. **Sistema i log**: mascheramento, HMAC, redaction nel tracing, conservazione.
10. **Aggiungi la validazione nei tool di scrittura** (gestionale, CRM, pagamenti), come ultimo controllo indipendente.
11. **Misura**: quanti identificativi respinti, per motivo, per fonte; quanti "non nel sorgente". È il tuo indicatore di invenzione.

## Fallimenti tipici e come li riconosci dai log

**Invenzioni intercettate dalla presenza nel sorgente.**

```text
validate doc=RIMB-2026-00871 campo=codice_fiscale esito=non_nel_sorgente checksum=ok
validate doc=RIMB-2026-00874 campo=iban esito=non_nel_sorgente checksum=ok
```

Il valore supera il checksum ma non compare nel documento: il modello l'ha ricostruito. Se la frequenza sale, controlla il prompt (spinge alla completezza?) e lo schema (campi obbligatori?).

**Retry che "aggiustano".**

```text
extract doc=FT-2026-3310 campo=partita_iva tentativo=1 esito=non_valido motivo=cifra_controllo
extract doc=FT-2026-3310 campo=partita_iva tentativo=2 esito=valido
```

Un secondo tentativo sullo stesso documento che passa: il modello ha cambiato una cifra per far tornare il controllo. Se nel tuo flusso esiste questa sequenza, c'è un retry da togliere.

**Omocodia rifiutata.**

```text
validate campo=codice_fiscale esito=non_valido motivo=formato valore=RSSMRA80A01H50MV
```

Un codice fiscale con lettere in posizioni numeriche respinto per formato: la regex non gestisce l'omocodia. Errore della libreria, non del documento.

**Paese non gestito trattato come errore.** Molti `paese_non_gestito` su fornitori esteri che finiscono in coda come "IBAN errato": è un problema di tabella delle lunghezze o di UX, non di dati.

**Valori in chiaro nei log.** Una ricerca di un pattern da codice fiscale nei log applicativi o nel tracing che restituisce risultati. Va trattato come un piccolo incidente: pulizia, correzione della redaction, verifica di dove sono stati copiati.

## Costi: ordini di grandezza

Stime indicative.

| Voce | Ordine di grandezza (stima) | Note |
|---|---|---|
| Libreria di validazione con test sintetici | 2–4 giorni/uomo | Meno se si parte da una libreria mantenuta |
| Servizio HTTP interno + tool MCP | 1–2 giorni/uomo | Container minimo, nessun LLM |
| Modifica schema di estrazione e verifica nel sorgente | 2–5 giorni/uomo | Dipende dalla pipeline esistente |
| UI con stati distinti e validazione in tempo reale | 2–6 giorni/uomo | Il tempo vero è nel test con gli operatori |
| Mascheramento e redaction dei log | 1–3 giorni/uomo | Più se ci sono molti strumenti di logging |
| Costo di esecuzione | trascurabile | Microsecondi per validazione, nessuna GPU |

Il costo di esecuzione è il dettaglio più interessante: una validazione deterministica costa praticamente zero, e ogni chiamata al modello che eviti (per "verificare" o "correggere" un identificativo) è risparmio puro di token e latenza.

## Quando NON farlo

Più che "quando non farlo", ci sono casi in cui la libreria non basta o non è il problema:

- **Quando ti serve sapere se il soggetto esiste.** Il checksum dice che un codice fiscale è ben formato, non che appartiene a una persona reale o a quella persona. Per verifiche di esistenza servono banche dati e servizi esterni, con le loro regole d'accesso.
- **Quando ti serve sapere se l'IBAN è del beneficiario.** Il modulo 97 non lo dice. Per i pagamenti, la verifica del beneficiario e il controllo sugli IBAN nuovi o cambiati (con conferma da un canale indipendente) sono un altro strato, irrinunciabile.
- **Quando gli identificativi arrivano da fonti strutturate affidabili.** Validare comunque costa poco; ma se ti trovi a costruire verifiche di presenza nel sorgente su un XML, stai usando lo strumento sbagliato: copia il campo dall'XML e basta.
- **Quando il volume è minimo.** Dieci moduli al mese li controlla una persona; la libreria resta utile come validazione del form, ma non serve la pipeline completa.

Quello che non ha eccezioni è la policy no-invent: anche con un solo documento al mese, un identificativo ricostruito da un modello non deve entrare in un sistema.

## Checklist operativa

- [ ] Esiste una sola libreria di validazione, usata da pipeline, agenti, n8n e interfacce.
- [ ] La libreria gestisce omocodia, CF numerici, prefisso "IT", spazi e separatori, e restituisce un motivo.
- [ ] IBAN: modulo 97, lunghezza per paese, CIN per Italia e San Marino; `paese_non_gestito` trattato come incertezza.
- [ ] Test su dataset sintetico generato con seme fisso; nessun dato reale nei test.
- [ ] Lo schema di estrazione prevede gli stati `illeggibile` e `assente`; nessun identificativo obbligatorio come stringa.
- [ ] Ogni identificativo accettato è presente nel testo sorgente.
- [ ] Nessun retry verso il modello per correggere un identificativo respinto.
- [ ] Controlli di coerenza con altri campi e con l'anagrafica.
- [ ] La UI non pre-compila mai un identificativo illeggibile o non valido.
- [ ] Log con valori mascherati o HMAC; redaction nel tracing degli LLM.
- [ ] I tool di scrittura validano in modo indipendente dall'agente.
- [ ] La policy no-invent è scritta nel prompt, nella documentazione e — soprattutto — nel codice.

## Il verdetto

La validazione di IBAN, codice fiscale e partita IVA è uno dei rari punti in cui l'ingegneria offre una certezza quasi completa a costo quasi nullo. Gli algoritmi sono pubblici da decenni, si implementano in cento righe, si testano su dati sintetici senza toccare un dato reale, girano in microsecondi. Non metterli tra il modello e i tuoi sistemi è una scelta che nessuno dovrebbe fare per distrazione.

Ma la parte più importante non è il checksum: è la regola che lo accompagna. Un modello linguistico, posto davanti a un buco, tende a riempirlo con qualcosa di plausibile. Il compito della pipeline è impedirglielo, in modo strutturale: schemi che ammettono "illeggibile", verifica che il valore esista nel documento, niente retry per far tornare i conti, un'interfaccia che non pre-compila. Un campo vuoto con scritto "illeggibile" fa perdere trenta secondi a una persona. Un codice fiscale inventato può far perdere settimane a molte.

Se stai mettendo modelli linguistici a contatto con dati anagrafici e bancari e vuoi impostare i controlli prima che un identificativo inventato arrivi in produzione, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e il resto del lavoro su [antoniotrento.net]({{ site.main_site }}/). Per misurare quanto la tua pipeline estrae bene i campi che contano, il pezzo complementare è quello sull'[accuratezza nell'estrazione documenti per campo]({{ '/it/blog/accuratezza-estrazione-documenti-campi/' | relative_url }}); gli altri sono raccolti nella guida su [RAG e documenti]({{ '/it/pillar/rag-documenti/' | relative_url }}).

## FAQ

### Come si verifica se un codice fiscale è valido?

Si controlla la lunghezza (16 caratteri per le persone fisiche, 11 cifre per altri soggetti), il formato di ogni posizione considerando l'omocodia, il giorno di nascita nei range ammessi (per le donne aumentato di 40), e il carattere di controllo finale, calcolato sui primi quindici caratteri con due tabelle di valori per posizioni dispari e pari e il resto della divisione per 26. La validità formale non dimostra che il codice appartenga a una persona reale.

### Qual è l'algoritmo di controllo della partita IVA?

Sulle prime dieci cifre si sommano quelle in posizione dispari così come sono e quelle in posizione pari raddoppiate (sottraendo 9 se il doppio supera 9). La cifra di controllo è quella che porta la somma al multiplo di 10 successivo. È un algoritmo della famiglia Luhn: intercetta tutte le sostituzioni di una cifra e quasi tutti gli scambi di cifre adiacenti.

### Come funziona il controllo modulo 97 dell'IBAN?

Si spostano i primi quattro caratteri (codice paese e cifre di controllo) in fondo, si convertono le lettere in numeri (A = 10 fino a Z = 35) e si calcola il resto della divisione per 97 del numero risultante: deve essere 1. Per gli IBAN italiani si verifica anche la lunghezza di 27 caratteri e il CIN, un secondo carattere di controllo nazionale.

### Perché un LLM inventa codici fiscali e IBAN?

Perché genera il carattere più probabile dato il contesto e non ha un concetto nativo di "non lo so" su un singolo carattere. Il rischio aumenta quando lo schema di output rende obbligatori i campi identificativi, quando il prompt chiede di non lasciare campi vuoti e quando l'OCR restituisce valori parziali che il modello "completa".

### Basta il checksum per bloccare un identificativo inventato?

Blocca la grande maggioranza: un valore plausibile ma casuale supera il controllo solo per caso, circa una volta su dieci per la partita IVA, una su ventisei per il codice fiscale e molto più raramente per un IBAN italiano. Per il resto servono altri strati: la verifica che il valore compaia nel documento sorgente, i controlli di coerenza con l'anagrafica e la revisione umana.

### Cosa significa la policy no-invent?

Che il sistema non completa, non ricostruisce e non corregge per deduzione identificativi mancanti, parziali o illeggibili. Un identificativo viene accettato solo se è letto per intero nel documento e supera formato, checksum e coerenza; altrimenti il campo viene marcato come illeggibile o assente e passato a una persona. È vietato chiedere al modello di correggere un valore respinto.

### Come si testano i validatori senza usare dati reali dei clienti?

Generando identificativi sintetici validi per costruzione, grazie agli algoritmi pubblici: cifre casuali più cifra di controllo calcolata per la partita IVA, posizioni casuali più carattere di controllo per il codice fiscale, ABI, CAB e conto casuali con CIN e modulo 97 calcolati per l'IBAN. Poi si applicano mutazioni che simulano errori di lettura e di digitazione e si coprono i casi limite come l'omocodia.

### Come si mostra all'operatore un identificativo non valido?

Distinguendo chiaramente gli stati: valido, illeggibile, assente, non valido. Un campo illeggibile resta vuoto con il ritaglio del documento; un valore non valido viene mostrato barrato con il motivo, e il campo di inserimento è vuoto, così l'operatore deve riscriverlo guardando il documento. Non si pre-compila mai un'ipotesi del modello.

### Si possono salvare codici fiscali e IBAN nei log?

Non in chiaro, se non per il tempo strettamente necessario e con accesso ristretto. Nei log applicativi bastano tipo, esito, motivo e riferimento al documento; per correlare eventi sullo stesso identificativo si usa un HMAC con una chiave segreta. Anche il tracing dei modelli linguistici va sottoposto a redaction prima della registrazione.

### Come si integra la validazione in un agente MCP o in n8n?

Esponendo una sola libreria come servizio interno e, per gli agenti, come tool di sola lettura che restituisce esito e motivo senza mai suggerire correzioni. I tool che scrivono identificativi nei sistemi devono validare in modo indipendente. In n8n si chiama il servizio con un nodo HTTP e si instrada verso una coda di revisione in caso di esito negativo, senza rimandare il valore al modello.
