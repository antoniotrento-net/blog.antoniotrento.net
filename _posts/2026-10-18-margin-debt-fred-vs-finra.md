---
lang: it
permalink: /it/blog/margin-debt-fred-vs-finra/
title: "Margin debt FRED vs FINRA: perché il tuo dashboard \"rischio contenuto\" è un bug di aggregazione (non un mercato safe)"
date: 2026-10-18 07:30:00 +0200
author: "Antonio Trento"
description: "Data engineering per indicatori di mercato: margin debt FINRA vs serie Z.1 su FRED, dati stale, YoY che esplodono, pesi che spengono un segnale estremo. Perché un aggregato può dire 'verde' con valutazioni al massimo, e come progettare assi separati con as_of in UI."
keywords: ["margin debt fred vs finra", "indicatore buffett household equity", "proxy z1", "dashboard rischio mercati", "dati stale cape", "data quality indicatori mercato"]
image: /assets/images/posts/margin-debt-fred-vs-finra.jpg
pillar: integrazioni-dati
related: [/it/blog/walk-forward-overfitting-trading-bot/, /it/blog/cloudflare-tunnel-raspberry-pi-n8n/]
---

## Il semaforo verde che non doveva esserci

Una mattina apri il tuo dashboard di rischio sul mercato azionario americano. Il punteggio composito dice **42/100: "rischio contenuto"**, pallino verde. Nello stesso momento, uno dei suoi componenti — il rapporto tra capitalizzazione di borsa e PIL, il cosiddetto indicatore di Buffett — è ai massimi storici. Com'è possibile che il cruscotto dica "tranquillo" mentre il suo indicatore più noto urla?

Non è il mercato a essere tranquillo. È il **dashboard ad avere un bug**, e non un bug di codice: un bug di **aggregazione**. Un indicatore di leva costruito con una serie trimestrale vecchia di mesi, un rapporto prezzo/utili fermo da settimane perché la fonte non si aggiorna, un calcolo di variazione annua applicato a dati riempiti in avanti, e una media pesata che diluisce il segnale estremo fino a farlo sparire. Ogni pezzo, da solo, sembra ragionevole. Insieme producono un verde che non significa niente.

Questo pezzo nasce da quel tipo di esperienza: costruendo un mio monitor di rischio di mercato — il progetto [SP500 AI Bubble Monitor]({{ site.main_site }}/portfolio/sp500-ai-bubble-monitor/), che misura fragilità e inneschi senza pretendere di prevedere nulla — ho scoperto che la parte difficile non è scegliere gli indicatori. È capire **cosa misurano davvero, quando sono stati misurati, e come non mescolarli male**. Il caso di scuola è il **margin debt: FRED vs FINRA**, due numeri che molti trattano come intercambiabili e che non lo sono.

Il disclaimer, chiaro: **questo non è un articolo di previsione né di consulenza finanziaria.** Non ti dico se il mercato scenderà. Ti parlo di **data quality per indicatori di mercato**: come si costruisce un cruscotto che non ti mente sul significato e sull'età dei suoi numeri. È un problema di data engineering, e vale per qualsiasi dashboard che aggrega fonti con cadenze e definizioni diverse — anche fuori dalla finanza.

## Due numeri che non misurano la stessa cosa

"Margin debt" sembra un concetto semplice: quanti soldi gli investitori hanno preso in prestito per comprare titoli. Leva alta, fragilità alta. Il problema è che esistono **più misure** chiamate più o meno così, pubblicate da enti diversi, con definizioni, perimetri e cadenze diverse.

Le due più usate:

- **Le statistiche sul margin di FINRA.** L'autorità di autoregolamentazione dei broker-dealer americani pubblica, con cadenza mensile, i saldi a debito nei conti di margin dei clienti delle società aderenti. È la serie che vedi citata negli articoli sul "margin debt record": mensile, riferita ai conti di margin dei clienti dei broker, pubblicata alcune settimane dopo la fine del mese.
- **Le serie dei conti finanziari della Federal Reserve (Z.1)**, molte delle quali sono consultabili su FRED, il database della Fed di St. Louis. Qui trovi grandezze come il credito titoli (*security credit*) per settore — famiglie, broker-dealer — che includono il margin ma **non coincidono** con la serie FINRA: il perimetro è definito per settore economico, le voci sono classificate secondo la contabilità nazionale, la cadenza è **trimestrale** e il dato arriva mesi dopo la fine del trimestre, con **revisioni** successive.

Detto in modo pratico: se prendi una serie Z.1 da FRED come "proxy del margin debt" e la metti accanto alla serie FINRA, stai confrontando **due fotografie diverse, scattate in momenti diversi, di oggetti parzialmente diversi**. Possono andare nella stessa direzione per anni e divergere proprio quando conta. E se nel tuo dashboard le usi come sostitute l'una dell'altra — "se FINRA non si scarica, uso FRED" — hai cambiato indicatore senza dirlo a nessuno.

La regola che ne ricavo è semplice: **ogni indicatore nel cruscotto ha una definizione scritta** (cosa misura, chi lo pubblica, perimetro, unità, frequenza), e due serie con definizioni diverse sono due indicatori diversi, anche se hanno lo stesso nome colloquiale. Lo stesso vale per il rapporto capitalizzazione/PIL (quale capitalizzazione? quale PIL, nominale, a quale data?) e per la quota di azioni nel patrimonio finanziario delle famiglie, un altro indicatore di fragilità costruito dai conti Z.1.

## FINRA vs Z.1: metodologia e ritardi

Il secondo problema è il **tempo**. Un dashboard mostra "oggi", ma ogni suo componente descrive un periodo diverso, e arriva con un ritardo diverso.

Ecco la mappa, con i ritardi come **ordini di grandezza** (verifica sempre il calendario di pubblicazione ufficiale di ciascuna fonte, che può cambiare):

| Indicatore | Fonte | Frequenza | Ritardo tipico di pubblicazione | Revisioni | Rischio "stale" |
|-----------|-------|-----------|----------------------------------|-----------|------------------|
| Margin debt (conti di margin clienti) | FINRA | mensile | alcune settimane dopo fine mese | rare | medio |
| Credito titoli per settore (proxy leva) | Fed Z.1 (via FRED) | trimestrale | circa 2–3 mesi dopo fine trimestre | sì, anche ampie | alto |
| Quota azioni nel patrimonio delle famiglie | Fed Z.1 (via FRED) | trimestrale | circa 2–3 mesi | sì | alto |
| PIL nominale (denominatore Buffett) | statistiche nazionali USA | trimestrale | stima anticipata ~1 mese, poi revisioni | sì | medio |
| Capitalizzazione di mercato | indici/provider di dati | giornaliera | quasi nullo | no | basso |
| CAPE (P/E corretto per il ciclo) | dataset pubblico di ricerca | mensile | variabile, dipende dal manutentore | talvolta | **molto alto** |
| Spread del credito corporate | indici di mercato (spesso via FRED) | giornaliera | 1 giorno | no | basso |
| Volatilità implicita | mercato | giornaliera | nullo | no | basso |

Leggila così: in un certo giorno di ottobre, il tuo dashboard può mettere insieme una capitalizzazione di **ieri**, uno spread di **ieri**, un margin debt FINRA di **fine agosto**, una leva Z.1 di **fine giugno** (se il dato di settembre non è ancora uscito) e un CAPE fermo a **luglio**. Tutto sullo stesso schermo, con la stessa grafica, senza una data accanto. Chi lo guarda pensa di vedere il mercato di oggi. Vede un collage di cinque momenti diversi.

C'è poi il tema delle **revisioni**: le serie trimestrali dei conti finanziari vengono riviste nelle pubblicazioni successive. Se il tuo sistema scarica e sovrascrive, il valore di "Q2" di oggi non è quello che avevi a agosto, e il tuo storico — su cui magari calcoli percentili — cambia sotto i piedi senza che tu lo sappia. La soluzione è salvare le **vintage**: ogni valore con la data a cui si riferisce (*as_of*), la data in cui l'hai scaricato (*fetched_at*) e l'eventuale numero di revisione.

## Stale: CAPE fermo, YoY che esplode o si azzera

Un dato **stale** (vecchio, non aggiornato) è il nemico più silenzioso di un dashboard. Non genera errori: il valore è lì, plausibile, e il grafico continua a disegnarsi. Tre modi in cui fa danni.

**1. La fonte smette di aggiornarsi.** Molti indicatori di valutazione di lungo periodo — il CAPE è il caso classico — vengono da dataset mantenuti da ricercatori o da siti di terze parti. Se il manutentore aggiorna in ritardo, o cambia formato del file, o il tuo scraper si rompe, il valore resta fermo sull'ultimo disponibile. Il dashboard continua a mostrare "CAPE 35" per settimane, mentre il mercato si è mosso del 10%.

**2. Il riempimento in avanti crea variazioni fantasma.** Per mettere insieme serie con frequenze diverse, la scorciatoia comune è portarle tutte a frequenza giornaliera e riempire i buchi con l'ultimo valore disponibile (*forward fill*). Poi calcoli la variazione su dodici mesi (**YoY**) sulla serie giornaliera. Risultato:

- Per tutti i giorni in cui il dato trimestrale è fermo, lo YoY confronta un valore piatto con un valore di un anno prima che magari si muoveva: la variazione deriva lentamente e non significa niente.
- Il giorno in cui esce il nuovo dato, lo YoY **salta** di colpo — a volte di decine di punti percentuali — e il tuo allarme "crescita anomala della leva" scatta per un artefatto di calcolo.
- Se il dato nuovo non arriva, e anche l'anno prima era riempito, lo YoY tende a **zero**: "leva stabile". Non è stabile: è ferma nel tuo database.

**3. Il denominatore si muove e il numeratore no.** Il rapporto capitalizzazione/PIL usa una capitalizzazione giornaliera e un PIL trimestrale. Se non gestisci l'allineamento, il rapporto oscilla ogni giorno per effetto del solo numeratore e fa uno scalino quando esce il nuovo PIL. Non è sbagliato in sé, ma va **mostrato per quello che è**: un rapporto tra un dato di oggi e uno di mesi fa.

Le regole che applico:

- **Calcola le variazioni nella frequenza nativa della serie.** Lo YoY di una serie trimestrale si calcola trimestre su trimestre dell'anno precedente, sui dati trimestrali, **prima** di qualsiasi allineamento.
- **Il forward fill serve solo per visualizzare, mai per calcolare.** E quando visualizzi un valore riempito, lo dici.
- **Ogni serie ha una cadenza attesa e una tolleranza.** Se una serie mensile non si aggiorna da 60 giorni, è stale: la marchi, non la usi nei calcoli come se fosse fresca.

Un registro delle fonti, scritto una volta, rende queste regole automatiche:

```yaml
# sources.yml — registro delle serie: cosa sono, quando arrivano, quando diventano stale
margin_debt_finra:
  source: FINRA
  definition: "saldi a debito nei conti di margin dei clienti dei broker-dealer aderenti"
  frequency: monthly
  expected_lag_days: 25          # stima: verifica sul calendario di pubblicazione
  stale_after_days: 70           # oltre questa età dall'as_of: marcato stale
  fetch: official_download       # file pubblicato dalla fonte, non scraping di pagine
  axis: fragility

security_credit_z1:
  source: "Federal Reserve Z.1 (via FRED API)"
  definition: "credito titoli per settore secondo i conti finanziari — NON equivalente a FINRA"
  frequency: quarterly
  expected_lag_days: 75
  stale_after_days: 190
  revisions: true                # salvare le vintage
  fetch: fred_api
  axis: fragility

cape:
  source: "dataset di ricerca pubblico"
  frequency: monthly
  expected_lag_days: 30
  stale_after_days: 60
  fetch: official_download
  axis: fragility

credit_spread_hy:
  source: "indice di mercato (via FRED API)"
  frequency: daily
  expected_lag_days: 1
  stale_after_days: 5
  fetch: fred_api
  axis: trigger
```

## Pesi: un proxy debole che spegne un segnale forte

Arriviamo al bug del titolo. Il punteggio composito è quasi sempre una **media pesata** di indicatori normalizzati: ogni indicatore viene trasformato in un percentile (dove si trova rispetto alla sua storia) o in uno z-score, e poi si fa la media. Sembra rigoroso. Ecco come produce un verde fuorviante.

Un **esempio di aggregato fuorviante**, costruito apposta per mostrare il meccanismo (numeri illustrativi, non dati reali):

| Indicatore | Percentile storico | Stato del dato | Peso |
|-----------|--------------------|----------------|------|
| Capitalizzazione/PIL (Buffett) | 98 | fresco | 0,25 |
| Leva — proxy Z.1 | 45 | fermo al trimestre di 6 mesi fa | 0,25 |
| CAPE | 60 | fermo da 2 mesi, percentile calcolato su finestra che nel frattempo è scivolata | 0,20 |
| Spread del credito (alto = rischio) | 10 | fresco, spread molto stretti | 0,20 |
| Volatilità implicita | 15 | fresco, volatilità bassa | 0,10 |

Media pesata: 0,25·98 + 0,25·45 + 0,20·60 + 0,20·10 + 0,10·15 = 24,5 + 11,25 + 12 + 2 + 1,5 = **51,25**. Arrotondi, applichi le soglie (verde sotto 55), e il cruscotto dice **"rischio contenuto"**.

Cosa è successo, metodologicamente:

1. **Il segnale estremo è stato diluito.** Un indicatore al 98° percentile — un valore raro nella storia — pesa come uno al 45°. La media, per costruzione, trasforma "un segnale fortissimo e quattro tiepidi" in "tutto nella norma".
2. **Un proxy debole e vecchio ha contato quanto uno forte e fresco.** La leva Z.1 non è la stessa grandezza del margin debt FINRA, ed era ferma a sei mesi prima. Ha pesato il 25% del punteggio.
3. **Un dato stale ha partecipato come se fosse fresco.** Il percentile del CAPE è stato calcolato su un valore fermo, confrontato con una finestra storica che nel frattempo si era spostata.
4. **Sono stati sommati misure di natura diversa.** Valutazioni e leva (che descrivono quanto il sistema è *fragile*) sono state mediate con spread e volatilità (che descrivono se qualcosa sta *scattando*). Spread stretti e volatilità bassa non rendono un mercato caro meno fragile: dicono solo che, per ora, nessuno sta vendendo.

Il punteggio unico ha preso una situazione "molto fragile, nessun innesco visibile" e l'ha trasformata in "rischio contenuto". È una frase **falsa** costruita con numeri veri.

Il calcolo che, nel codice, rende evidente il problema:

```python
import pandas as pd

def composito_ingenuo(ind: pd.DataFrame) -> float:
    """Media pesata dei percentili: il pattern che produce il falso verde."""
    return float((ind["percentile"] * ind["peso"]).sum() / ind["peso"].sum())

def valutazione_onesta(ind: pd.DataFrame, oggi: pd.Timestamp) -> dict:
    ind = ind.copy()
    ind["eta_giorni"] = (oggi - ind["as_of"]).dt.days
    ind["stale"] = ind["eta_giorni"] > ind["stale_after_days"]
    freschi = ind[~ind["stale"]]
    out = {}
    for asse in ["fragility", "trigger"]:
        a = freschi[freschi["axis"] == asse]
        out[asse] = {
            "max_percentile": a["percentile"].max() if len(a) else None,   # l'estremo non si diluisce
            "indicatori_estremi": a.loc[a["percentile"] >= 90, "nome"].tolist(),
            "as_of_piu_vecchio": a["as_of"].min() if len(a) else None,
            "copertura": f"{len(a)}/{(ind['axis'] == asse).sum()} indicatori freschi",
        }
    out["esclusi_stale"] = ind.loc[ind["stale"], ["nome", "as_of"]].to_dict("records")
    return out
```

La seconda funzione non produce un numero magico: produce una **descrizione** — su ciascun asse, l'indicatore più estremo, quali sono sopra il 90° percentile, quanto è vecchio il dato più vecchio usato, quanti indicatori sono effettivamente freschi, e cosa è stato escluso perché stale. È meno "elegante" di un punteggio, ed è molto più vera.

## Design: fragilità vs innesco, non un unico semaforo

La correzione non è trovare i pesi giusti. È **smettere di mettere tutto su un solo asse**.

Il modello che uso separa due domande:

- **Quanto è carica la molla? (fragilità)** Valutazioni, leva, concentrazione, esposizione delle famiglie. Sono grandezze **lente**, spesso trimestrali o mensili, che descrivono quanto un sistema è vulnerabile a uno shock. Possono restare estreme per anni.
- **C'è qualcosa che sta facendo scattare la molla? (innesco)** Spread del credito, volatilità, condizioni di liquidità, rotture di tendenza, eventi. Sono grandezze **veloci**, giornaliere, che dicono se lo stress si sta materializzando.

Le due dimensioni vanno **mostrate separate**, come due indicatori con due scale, non mediate. Le combinazioni hanno significati diversi:

- Fragilità bassa, innesco spento: condizioni ordinarie.
- Fragilità alta, innesco spento: **la situazione del nostro esempio**. Non "rischio contenuto": sistema vulnerabile, nessun segnale di rottura per ora. È una frase utile e onesta.
- Fragilità bassa, innesco acceso: stress che il sistema può assorbire più facilmente.
- Fragilità alta, innesco acceso: la combinazione che merita attenzione.

Dentro ciascun asse, evita la media semplice come unica sintesi: mostra l'indicatore più estremo, il numero di indicatori in zona estrema e la **copertura** (quanti dati freschi hai). Un asse "fragilità" calcolato con due indicatori freschi su cinque non vale quanto uno con cinque su cinque, e va detto.

È esattamente l'approccio del monitor che ho citato all'inizio: non prevedere il giorno del crollo, ma descrivere onestamente quanto è carica la molla e se lo scatto tipico è acceso o spento. Nessuna delle due cose, da sola, dice cosa farà il mercato domani.

## L'architettura di riferimento

```
 ┌───────────────┐  ┌───────────────┐  ┌──────────────────┐
 │ FINRA download│  │ FRED API (Z.1,│  │ dataset di ricerca│   fonti ufficiali,
 │ ufficiale     │  │ spread, ...)  │  │ (CAPE)            │   niente scraping
 └──────┬────────┘  └──────┬────────┘  └────────┬─────────┘   di pagine protette
        └──────────────────┼────────────────────┘
                           ▼
          ┌─────────────────────────────────────────┐
          │ RAW STORE con vintage                    │
          │ (serie, as_of, fetched_at, revisione)    │
          └────────────────────┬────────────────────┘
                               ▼
          ┌─────────────────────────────────────────┐
          │ FRESHNESS CHECK (registro fonti)         │
          │ cadenza attesa · stale_after · alert     │
          └────────────────────┬────────────────────┘
                               ▼
          ┌─────────────────────────────────────────┐
          │ INDICATORI (calcolo in frequenza nativa) │
          │ percentili su vintage coerenti           │
          └──────────┬──────────────────┬───────────┘
                     ▼                  ▼
            ASSE FRAGILITÀ        ASSE INNESCO
            (lento)               (veloce)
                     └────────┬─────────┘
                              ▼
          ┌─────────────────────────────────────────┐
          │ UI: ogni numero con as_of, fonte,         │
          │ frequenza, badge stale, copertura         │
          └─────────────────────────────────────────┘
```

**Cosa non tocca il sistema**: nessuna previsione ("il mercato scenderà"), nessun segnale operativo ("vendi"), nessuna sostituzione silenziosa di una fonte con un'altra, nessun dato stale nei calcoli senza marcatura. Il dashboard descrive; le decisioni restano di chi lo guarda, con le informazioni sull'età e la natura dei dati davanti.

## as_of e provenienza in UI

Un numero senza data, in un dashboard che aggrega fonti con cadenze diverse, è un'informazione incompleta che il lettore completerà con l'ipotesi sbagliata: "è di oggi". Le **regole di visualizzazione as_of** che applico:

1. **Ogni valore mostra il periodo a cui si riferisce**, non la data in cui l'hai scaricato. "Margin debt: agosto 2026", non "aggiornato il 20/10".
2. **La fonte è sempre visibile**, almeno al passaggio del mouse o in una nota: FINRA, Fed Z.1 via FRED, eccetera. Se è un proxy, c'è scritto "proxy" e di cosa.
3. **La frequenza e il prossimo aggiornamento atteso** sono indicati: "trimestrale, prossimo dato atteso a dicembre".
4. **Un badge "stale" compare automaticamente** quando l'età del dato supera la tolleranza della sua cadenza. Il valore resta visibile, ma grigio e fuori dai calcoli.
5. **Gli aggregati ereditano la data del componente più vecchio.** Se l'asse fragilità usa un dato di giugno, l'asse fragilità è "aggiornato a giugno", anche se gli altri componenti sono di ieri. Dichiarare "oggi" per un aggregato che contiene un dato di quattro mesi fa è una piccola bugia.
6. **La copertura è esplicita**: "4 indicatori su 5 freschi". Se scende troppo, l'asse mostra "dati insufficienti" invece di un valore.
7. **Le revisioni sono tracciate**: se un valore storico è stato rivisto, il grafico lo può mostrare, e i percentili usano vintage coerenti.
8. **"Dato non disponibile" è uno stato valido.** Meglio una casella vuota con una spiegazione che un valore inventato o riempito.

Nel codice della UI, la regola si riduce a non permettere di disegnare un numero senza i suoi metadati:

```typescript
type Valore = {
  nome: string; valore: number | null;
  as_of: string;        // periodo di riferimento, es. "2026-08"
  fetched_at: string;   // quando è stato scaricato
  fonte: string; frequenza: "daily" | "monthly" | "quarterly";
  stale: boolean; proxy_di?: string;
};

function etichetta(v: Valore): string {
  if (v.valore === null) return `${v.nome}: non disponibile`;
  const base = `${v.nome}: ${v.valore.toFixed(1)} · dato ${v.as_of} · ${v.fonte}`;
  const proxy = v.proxy_di ? ` · proxy di ${v.proxy_di}` : "";
  return v.stale ? `${base}${proxy} · ⚠ non aggiornato, escluso dai calcoli` : `${base}${proxy}`;
}
```

## Cosa non scrapare (403, termini d'uso, IP residenziale)

La tentazione, quando una fonte non ha un'API comoda, è scrivere uno scraper per la pagina web. Nel mondo dei dati finanziari è una pessima idea, per tre ragioni.

- **Termini d'uso.** Molti siti di dati finanziari vietano esplicitamente lo scraping o il riuso automatico, anche quando la pagina è pubblica. Il fatto che tu riesca a leggerla non significa che tu possa ripubblicarla o incorporarla in un prodotto.
- **Protezioni anti-bot.** Siti con protezioni rispondono con errori 403, challenge JavaScript o limiti di frequenza. Lo scraper funziona per una settimana, poi inizia a fallire in modo intermittente — e un dato che fallisce in silenzio diventa un dato stale.
- **IP residenziale.** Se lo scraper gira da casa o dall'ufficio, sul collegamento residenziale, gli errori ripetuti possono far finire il tuo IP in una lista nera, con effetti anche sulla navigazione normale. È la stessa lezione che ho raccontato parlando di come esporre servizi da un {{ '/it/blog/cloudflare-tunnel-raspberry-pi-n8n/' | relative_url }}: un IP residenziale non è un'infrastruttura per fare richieste automatiche a terzi.

Cosa fare invece:

- **Usa le API e i download ufficiali.** FRED offre un'API documentata con chiave gratuita; molte istituzioni pubblicano file scaricabili con calendario noto. Sono stabili, documentati, e i termini d'uso sono chiari.
- **Rispetta limiti e cache.** Un dato trimestrale non va scaricato ogni cinque minuti. Scaricalo secondo la sua cadenza, con una cache, e rispetta i limiti di frequenza dichiarati.
- **Cita la fonte** in UI e nella documentazione, come richiesto dai termini d'uso.
- **Se una fonte non ha una via lecita e stabile, rinuncia all'indicatore** o cerca un'alternativa ufficiale. Un indicatore che non puoi aggiornare in modo affidabile è, per definizione, un futuro dato stale.

## Come comunicare l'incertezza senza il giallo da televideo

Il semaforo rosso-giallo-verde è rassicurante e quasi sempre sbagliato per questo tipo di dati. Riduce una situazione a più dimensioni in un colore, e il giallo — il colore più frequente — diventa rumore di fondo che nessuno guarda più.

Alternative che uso:

- **Frasi descrittive invece di etichette.** "Valutazioni: 98° percentile storico (dato di ieri). Leva: ultimo dato disponibile di giugno, nella media. Inneschi: spread e volatilità bassi." Più lungo di "verde", molto più utile.
- **Posizione nella storia, non soglie arbitrarie.** Un grafico che mostra dove si trova il valore attuale rispetto alla distribuzione storica comunica "raro" o "normale" senza un colore che suggerisce un'azione.
- **Due assi, due visualizzazioni.** Fragilità e innesco affiancati, con le loro scale.
- **Copertura e freschezza sempre visibili.** L'incertezza non è solo "quanto è estremo il valore", ma anche "quanto è vecchio e affidabile il dato".
- **Nessun linguaggio predittivo.** Il dashboard non dice "rischio di crollo", dice "condizioni storicamente estreme su queste misure". La differenza non è stilistica: la prima è una previsione che il dashboard non può fare.
- **Il disclaimer nel prodotto, non solo in fondo alla pagina**: "Descrive condizioni, non prevede eventi. Non è consulenza finanziaria."

## Percorso di implementazione, a step

1. **Scrivi il registro delle fonti**: per ogni indicatore, definizione, fonte, perimetro, frequenza, ritardo atteso, tolleranza, modalità di download, asse.
2. **Elimina lo scraping di pagine** a favore di API e download ufficiali; rinuncia agli indicatori senza una fonte lecita e stabile.
3. **Salva le vintage**: ogni valore con as_of, fetched_at, revisione.
4. **Calcola le trasformazioni nella frequenza nativa** (YoY trimestrale sui trimestri), prima di qualsiasi allineamento.
5. **Implementa il controllo di freschezza** con allarme quando una serie supera la tolleranza.
6. **Separa gli assi** fragilità e innesco; niente media unica.
7. **Sostituisci il punteggio con una descrizione**: indicatore più estremo, indicatori oltre soglia, copertura, data del dato più vecchio.
8. **Rendi as_of e fonte obbligatori** in UI: nessun componente disegna un numero senza metadati.
9. **Scrivi i testi** che comunicano incertezza senza semafori e senza previsioni.
10. **Aggiungi test** che verificano i casi patologici: serie stale, dato mancante, revisione di un valore storico, uscita di un nuovo trimestre.

## Fallimenti tipici e come li riconosci dai log

- **Serie che non si aggiorna da settimane senza allarme.** Nei log: `fetched_at` recente ma `as_of` invariato da più cicli. Il download funziona, la fonte non ha pubblicato — o hai scaricato una pagina di errore scambiandola per dati.
- **Salto improvviso di una variazione annua il giorno di un rilascio.** Artefatto di forward fill: la variazione era calcolata sulla serie riempita. Verifica che lo YoY sia calcolato sulla frequenza nativa.
- **Percentili che cambiano per valori storici "fermi".** Le revisioni hanno modificato lo storico. Senza vintage, non puoi nemmeno accorgertene.
- **Errori 403 intermittenti.** Una fonte scrapata ha iniziato a bloccarti. Il dato diventerà stale: passa a una fonte ufficiale.
- **Composito stabile mentre un componente è estremo.** Il segnale del titolo: la media sta diluendo. Guarda la distribuzione dei componenti, non solo la media.
- **Cambio silenzioso di fonte.** Un fallback da una serie a un'altra ("se FINRA fallisce usa Z.1") lascia traccia nei log solo se lo logghi. Se lo fai, devi anche mostrarlo in UI; meglio ancora, non farlo.
- **File scaricato con formato cambiato.** La fonte cambia colonne o intestazioni, il parser legge la colonna sbagliata e produce numeri plausibili ma errati. Serve una validazione dello schema del file e dei range di valori plausibili.

## Costi: ordini di grandezza

Stime indicative.

- **Dati**: le fonti pubbliche citate (FRED, pubblicazioni ufficiali) sono **gratuite**; FRED richiede una chiave API gratuita. Dati di mercato giornalieri di qualità per alcune grandezze (per esempio la capitalizzazione aggregata) possono richiedere un provider a pagamento, da decine a centinaia di euro al mese a seconda delle licenze.
- **Infrastruttura**: un job giornaliero che scarica, verifica e ricalcola gira su un piccolo server o un container da **pochi euro al mese**; il carico è minimo.
- **Storage delle vintage**: poche centinaia di serie con storico e revisioni occupano **megabyte**, non gigabyte.
- **Energia**: trascurabile, frazioni di kWh al mese.
- **Il costo vero** è il lavoro di data engineering: scrivere il registro delle fonti, i controlli di freschezza, la gestione delle vintage e una UI che mostra i metadati. Settimane, non giorni — ed è la parte che distingue un cruscotto da un generatore di rassicurazioni.

## Quando NON farlo

- **Se vuoi un segnale operativo** ("quando vendere"), questo tipo di dashboard non te lo darà. Descrive condizioni, e le condizioni estreme possono durare anni.
- **Se non puoi mantenere le fonti**: un dashboard di indicatori macro senza manutenzione diventa, in pochi mesi, un museo di dati stale con l'aspetto di un cruscotto aggiornato. Peggio che non averlo.
- **Se l'obiettivo è pubblicare un numero unico** per comodità di comunicazione, sappi che stai scegliendo la chiarezza apparente contro la correttezza. Se proprio devi, pubblica anche i componenti e le date.
- **Se dipendi da fonti che puoi solo scrapare**, rinuncia a quegli indicatori. La fragilità della fonte diventa fragilità del prodotto.
- **Se lo usi per gestire denaro di altri**, entri in un altro mondo di responsabilità e regole: un dashboard fatto in casa non è uno strumento professionale di gestione del rischio.

## Checklist operativa

- [ ] Registro delle fonti con definizione, perimetro, frequenza, ritardo, tolleranza, asse.
- [ ] Nessuna serie usata come "sostituto" di un'altra con definizione diversa senza dichiararlo.
- [ ] Solo API e download ufficiali; nessuno scraping di pagine protette.
- [ ] Vintage salvate: as_of, fetched_at, revisione.
- [ ] Variazioni calcolate in frequenza nativa; forward fill solo per visualizzare.
- [ ] Controllo di freschezza con allarme e badge stale automatico.
- [ ] Dati stale esclusi dai calcoli, visibili in UI.
- [ ] Assi fragilità e innesco separati; nessuna media unica come verdetto.
- [ ] Sintesi descrittiva: estremi, copertura, data del dato più vecchio.
- [ ] Ogni numero in UI con as_of, fonte, frequenza; aggregati con la data del componente più vecchio.
- [ ] Testi senza semafori e senza previsioni; disclaimer dentro il prodotto.
- [ ] Test sui casi patologici: stale, mancante, revisione, nuovo rilascio, formato cambiato.

## Il verdetto

Un dashboard che dice **"rischio contenuto"** mentre il suo indicatore principale è ai massimi storici non ti sta dando un'informazione sul mercato: ti sta mostrando un **bug di aggregazione**. Serie con definizioni diverse trattate come intercambiabili (il margin debt FINRA non è una serie Z.1 su FRED), dati fermi da mesi usati come fossero di oggi, variazioni annue calcolate su serie riempite, e una media pesata che diluisce un segnale estremo fino a farlo sparire. Ogni scelta, da sola, sembra ragionevole; insieme producono un verde che non significa niente.

La soluzione non è trovare i pesi perfetti. È trattare gli indicatori di mercato come qualsiasi altro problema di data quality: definizioni scritte, fonti ufficiali, vintage, freschezza controllata, calcoli nella frequenza giusta, assi separati per ciò che rende il sistema fragile e ciò che lo fa scattare, e una UI che non disegna mai un numero senza la sua data e la sua provenienza. Il risultato è meno spettacolare di un semaforo, e molto più onesto. Resta, lo ripeto, uno strumento descrittivo: non prevede nulla e non è consulenza finanziaria.

Se costruisci dashboard che aggregano fonti con cadenze diverse — finanziarie, commerciali, operative — e vuoi che dicano la verità sui propri dati, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Il problema del "verde che non doveva esserci" è molto più comune fuori dalla finanza di quanto sembri.

## FAQ

### Qual è la differenza tra il margin debt di FINRA e le serie Z.1 su FRED?
Sono misure diverse. Le statistiche FINRA riportano, con cadenza mensile, i saldi a debito nei conti di margin dei clienti dei broker-dealer aderenti. Le serie dei conti finanziari della Federal Reserve (Z.1), molte consultabili su FRED, descrivono grandezze come il credito titoli per settore economico, con cadenza trimestrale, ritardi di mesi e revisioni. Possono muoversi in modo simile, ma perimetro, definizione e tempistica non coincidono: usarle come sostitute cambia l'indicatore senza dirlo.

### Perché un punteggio composito può dire "rischio basso" con valutazioni estreme?
Perché la media pesata diluisce i valori estremi: un indicatore al 98° percentile mediato con altri quattro nella norma produce un numero medio. Se poi alcuni componenti sono vecchi o sono proxy deboli, e se si mescolano misure di fragilità con misure di innesco, il risultato può essere un "verde" metodologicamente sbagliato. È un bug di aggregazione, non un'informazione sul mercato.

### Cosa significa che un dato è "stale"?
Che non è stato aggiornato entro il tempo atteso per la sua cadenza: una serie mensile ferma da due mesi, una trimestrale ferma oltre il rilascio successivo, un indicatore di valutazione che la fonte ha smesso di aggiornare. Il valore resta plausibile e il grafico continua a disegnarlo, ma descrive un momento passato. Va marcato in UI ed escluso dai calcoli che pretendono di descrivere il presente.

### Perché la variazione annua (YoY) "esplode" o si azzera?
Succede quando la si calcola su una serie a bassa frequenza (per esempio trimestrale) portata a frequenza giornaliera con il riempimento in avanti. Nei giorni in cui il dato è fermo, la variazione deriva senza significato; quando esce il nuovo dato, salta di colpo. Se il dato non arriva, tende a zero. La soluzione è calcolare le variazioni nella frequenza nativa della serie, e usare il riempimento solo per visualizzare.

### Cos'è l'as_of e perché va mostrato?
È la data o il periodo a cui un valore si riferisce: "agosto 2026" per un dato mensile, "Q2 2026" per uno trimestrale. In un dashboard che mette insieme dati giornalieri, mensili e trimestrali, senza as_of il lettore assume che tutto sia di oggi. Ogni valore deve mostrare as_of e fonte, e gli aggregati devono dichiarare la data del componente più vecchio che usano.

### Perché separare "fragilità" e "innesco"?
Perché descrivono cose diverse. La fragilità (valutazioni, leva, concentrazione) misura quanto un sistema è vulnerabile, cambia lentamente e può restare estrema per anni. L'innesco (spread del credito, volatilità, liquidità) misura se lo stress si sta materializzando e cambia velocemente. Mediare le due cose trasforma "molto fragile, nessun innesco" in "rischio medio", che è un'informazione falsa. Mostrandole separate, ogni combinazione ha un significato chiaro.

### Posso fare scraping dei siti di dati finanziari?
Spesso i termini d'uso lo vietano, e molti siti hanno protezioni che rispondono con errori 403 o limiti di frequenza: lo scraper smette di funzionare in modo intermittente e il dato diventa stale. Da un IP residenziale rischi anche blocchi più ampi. Usa API e download ufficiali (FRED offre un'API documentata con chiave gratuita), rispetta i limiti e cita le fonti. Se un indicatore non ha una fonte lecita e stabile, meglio rinunciarci.

### Come gestisco le revisioni dei dati trimestrali?
Salvando le vintage: ogni valore con la data di riferimento, la data di scaricamento e la revisione. Così puoi sapere quale valore era disponibile in un certo momento, calcolare percentili su dati coerenti e accorgerti quando lo storico viene rivisto. Sovrascrivere semplicemente i valori cancella questa informazione e rende i confronti nel tempo inaffidabili.

### Questo dashboard serve a prevedere un crollo di mercato?
No. Descrive condizioni: quanto sono estreme alcune misure rispetto alla loro storia, e se ci sono segnali di stress in corso. Le condizioni estreme possono durare a lungo senza eventi, e gli eventi possono arrivare senza segnali chiari. Non è uno strumento di previsione né di consulenza finanziaria, e va comunicato come tale anche dentro il prodotto.

### Queste regole valgono anche per dashboard non finanziari?
Sì, ed è forse l'aspetto più utile. Qualsiasi cruscotto che mette insieme fonti con cadenze diverse — vendite giornaliere, bilanci trimestrali, sondaggi mensili, dati di magazzino — rischia gli stessi errori: definizioni confuse, dati stale presentati come attuali, medie che nascondono estremi. Registro delle fonti, as_of visibile, controllo di freschezza e sintesi descrittive invece di un unico semaforo funzionano ovunque.
