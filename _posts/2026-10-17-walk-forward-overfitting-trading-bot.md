---
lang: it
permalink: /it/blog/walk-forward-overfitting-trading-bot/
title: "Il backtest del tuo bot di trading mente: walk-forward, overfitting e perché uno Sharpe 2.4 in sample è quasi sempre spazzatura"
date: 2026-10-17 07:30:00 +0200
author: "Antonio Trento"
description: "Metodo onesto per validare un bot di trading: look-ahead e survivorship bias, walk-forward con embargo, costi e slippage realistici, overfitting, protocollo di rischio con kill switch e cosa loggare in paper trading. Non è consulenza finanziaria."
keywords: ["walk forward overfitting trading bot", "validazione walk-forward", "backtest bias", "quantitative python", "kill switch trading", "sharpe ratio overfitting"]
image: /assets/images/posts/walk-forward-overfitting-trading-bot.jpg
pillar: integrazioni-dati
related: [/it/blog/kill-switch-agente-salesforce/, /it/blog/osservabilita-llm-produzione/]
---

## Disclaimer, e cosa questo articolo non è

Prima di tutto, chiarezza. **Questo non è un articolo di consulenza finanziaria**, non contiene segnali, strategie da copiare o promesse di rendimento, e non ti dice se e come investire. Il trading, manuale o automatico, comporta il rischio concreto di perdere il capitale, anche tutto. Se gestisci denaro di altre persone, in Italia e in Europa entri in attività riservate a soggetti autorizzati: un bot "per gli amici" non è un'eccezione.

Questo è un articolo di **metodo**: come si valida un sistema di trading automatico senza mentire a sé stessi. È ingegneria del dato e del software applicata a un dominio in cui l'autoinganno è la norma. Scrivo da system architect che ha costruito e smontato sistemi di questo tipo per curiosità e ricerca personale, non da gestore di fondi. Se cerchi il bot che "fa il 300% l'anno", qui troverai soprattutto i motivi per cui quel numero è quasi certamente falso.

## Perché il backtest mente (e perché ti piace crederci)

Il copione è sempre lo stesso. Scrivi una strategia in Python, la fai girare su tre anni di dati, e il grafico dell'equity sale in diagonale. Sharpe ratio **2.4**, drawdown massimo del 9%, profitto annuo a due cifre. Aggiungi un filtro, lo Sharpe sale a 2.7. Metti in produzione con capitale vero. Tre settimane dopo sei in perdita, e dopo tre mesi la curva reale assomiglia a una scala che scende.

Non hai avuto sfortuna. Il **backtest del tuo bot di trading ti ha mentito**, e tu lo hai aiutato. Un backtest non è una misura della strategia: è una misura di quanto bene la strategia si adatta *a quei dati specifici*, con *quelle ipotesi specifiche* su costi, esecuzione e informazioni disponibili. Ogni ipotesi ottimistica gonfia il risultato, e ogni variante che provi e scarti aumenta la probabilità di aver trovato un caso fortunato invece di un vantaggio reale.

Uno **Sharpe di 2.4 in sample** — cioè misurato sugli stessi dati su cui hai scelto la strategia — è, nella maggior parte dei casi, il risultato combinato di tre cose: errori nei dati (bias), costi sottostimati, e overfitting. La **validazione walk-forward**, i costi realistici e un protocollo di rischio servono a smontare queste tre illusioni prima che lo faccia il mercato, con i tuoi soldi.

## Look-ahead e survivorship: come ti freghi da solo

I bias di dati sono i più insidiosi perché non si vedono: il codice gira, i numeri escono, e sono sbagliati alla radice.

### Look-ahead bias: usare il futuro senza accorgersene

Il **look-ahead bias** è quando la strategia, in un certo istante del backtest, usa informazioni che in quell'istante non sarebbero state disponibili. Sembra un errore da principianti; è l'errore che commettono tutti, in forme sottili:

- **Decidere e eseguire sulla stessa candela.** Calcoli il segnale con il prezzo di chiusura della candela delle 10:00 e ipotizzi di comprare *a quel prezzo di chiusura*. Ma il prezzo di chiusura lo conosci solo quando la candela è chiusa: il primo prezzo a cui puoi davvero eseguire è l'apertura della candela successiva (o peggio). Differenza apparentemente piccola, effetto enorme sulle strategie a breve termine.
- **Normalizzare con statistiche dell'intero campione.** Standardizzi un indicatore sottraendo la media e dividendo per la deviazione standard calcolate su tutti i tre anni. A gennaio del primo anno stai usando la media di dati del terzo anno.
- **Resampling e allineamento.** Aggregare dati a 1 minuto in candele orarie con l'etichetta sbagliata (inizio vs fine intervallo), o unire due serie con fusi orari diversi, sposta i dati di un'ora: esattamente il margine che serve a una strategia per "prevedere" il passato.
- **`shift` dimenticati.** In pandas, il segnale deve essere calcolato su dati fino a `t-1` per agire in `t`. Uno `shift(1)` mancante è la forma più comune di look-ahead nel codice quantitativo scritto in Python.
- **Dati rivisti.** Alcuni dati (macroeconomici, fondamentali) vengono corretti dopo la pubblicazione. Se usi la versione finale, stai usando numeri che al momento della decisione non esistevano.

### Survivorship bias: guardare solo i sopravvissuti

Il **survivorship bias** è testare solo su ciò che esiste oggi. Scarichi la lista delle criptovalute scambiate oggi sul tuo exchange e testi la strategia su quelle, negli ultimi cinque anni. Ma le monete che sono crollate, sono state delistate o sono sparite non ci sono: il tuo universo di test è fatto di sopravvissuti, e una strategia "compra le monete in calo" su un universo di sopravvissuti sembra geniale. Lo stesso vale per le azioni di un indice testate con i *componenti attuali* invece di quelli storici.

### L'elenco dei bias da controllare

| Bias | Come si manifesta | Controllo pratico |
|------|-------------------|-------------------|
| Look-ahead | segnale ed esecuzione sullo stesso prezzo, normalizzazioni sul campione intero | esecuzione alla candela successiva, statistiche solo su dati passati, test "shift" |
| Survivorship | universo di asset che esistono oggi | dataset con asset delistati e composizioni storiche |
| Data snooping | provare centinaia di varianti e tenere la migliore | registro di tutti i tentativi, correzione per test multipli |
| Selection bias | scegliere il periodo di test che "funziona" | periodi fissati prima, inclusi regimi diversi |
| Regime bias | dati solo di un mercato in trend | test su rialzo, ribasso, laterale, alta volatilità |
| Costi omessi | fee, spread, funding, slippage ignorati | modello di costi esplicito e test di sensibilità |
| Liquidità | ipotesi di eseguire qualsiasi size al prezzo medio | limite di partecipazione al volume, profondità del book |
| Timestamp | orari di apertura vs chiusura, fusi orari | convenzione unica documentata, test di allineamento |
| Dati stale | feed fermi trattati come prezzi validi | controllo dell'età del dato a ogni decisione |

Un buon esercizio: prendi la tua strategia e **sposta tutti i segnali di una candela in avanti**. Se il rendimento crolla, la strategia viveva probabilmente di look-ahead o di microstruttura che non puoi catturare davvero.

## Walk-forward: finestre, embargo, rolling

La **validazione walk-forward** è il modo standard per stimare come si comporterebbe una strategia su dati che non ha mai visto, simulando il processo reale: decidi i parametri con i dati disponibili fino a oggi, li usi sul periodo successivo, poi ricalibri e vai avanti.

Lo schema:

```
Tempo ──────────────────────────────────────────────────────────────►

Fold 1: [====== TRAIN (ottimizza) ======][gap][== TEST ==]
Fold 2:         [====== TRAIN ======][gap][== TEST ==]
Fold 3:                 [====== TRAIN ======][gap][== TEST ==]
Fold 4:                         [====== TRAIN ======][gap][== TEST ==]
                                                               ...
                                                   [ HOLDOUT FINALE ]
                                                   (toccato una volta sola)

Curva out-of-sample = concatenazione dei soli segmenti TEST
gap = embargo: dati esclusi per evitare contaminazione tra train e test
```

Gli elementi che contano:

- **Finestra di train (in-sample)**: il periodo su cui scegli i parametri. Troppo corta e i parametri sono rumore; troppo lunga e includi regimi che non esistono più.
- **Finestra di test (out-of-sample)**: il periodo successivo, su cui applichi i parametri scelti *senza toccarli*. È l'unica parte dei risultati che conta.
- **Rolling vs anchored**: nella versione *rolling* la finestra di train scorre (lunghezza fissa); in quella *anchored* parte sempre dall'inizio e si allunga. Rolling si adatta ai cambi di regime, anchored usa più dati. Prova entrambe e guarda se le conclusioni cambiano.
- **Embargo (gap)**: se le tue etichette o i tuoi indicatori usano finestre temporali (per esempio "rendimento nei prossimi 5 giorni", o una media mobile a 20 periodi), le ultime osservazioni del train e le prime del test condividono informazione. Un periodo di esclusione tra le due finestre evita questa contaminazione. Il concetto, insieme alla rimozione delle osservazioni sovrapposte, è ben descritto nella letteratura di finanza quantitativa sul *purging* e sull'*embargo*.
- **Holdout finale**: un periodo recente che **non tocchi mai** durante lo sviluppo. Lo usi una volta sola, alla fine. Se lo guardi e poi modifichi la strategia, non è più un holdout: è diventato in-sample.

Un generatore di fold walk-forward con embargo, in Python:

```python
import pandas as pd

def walk_forward_splits(index: pd.DatetimeIndex, train: str, test: str,
                        embargo: str, anchored: bool = False):
    """Genera (train_idx, test_idx) senza sovrapposizioni né contaminazione."""
    start = index.min()
    train_td, test_td, emb_td = pd.Timedelta(train), pd.Timedelta(test), pd.Timedelta(embargo)
    t0 = start
    while True:
        train_end = t0 + train_td if not anchored else start + train_td + (t0 - start)
        train_start = start if anchored else t0
        test_start = train_end + emb_td            # embargo tra train e test
        test_end = test_start + test_td
        if test_end > index.max():
            break
        tr = index[(index >= train_start) & (index < train_end)]
        te = index[(index >= test_start) & (index < test_end)]
        yield tr, te
        t0 = t0 + test_td                          # rolling: avanza di una finestra di test

def valuta_walk_forward(prezzi, strategia, param_grid, **kw):
    risultati_oos = []
    for tr, te in walk_forward_splits(prezzi.index, **kw):
        migliori = max(param_grid, key=lambda p: strategia.score(prezzi.loc[tr], p))  # scelta SOLO su train
        risultati_oos.append(strategia.run(prezzi.loc[te], migliori))                   # applicata su test
    return pd.concat(risultati_oos)   # curva out-of-sample: l'unica che conta
```

Due cose da osservare nel risultato, più importanti dello Sharpe medio:

- **Stabilità dei parametri tra i fold.** Se il periodo ottimo della media mobile salta da 12 a 87 a 23 a 140, la strategia non ha trovato una regolarità: ha inseguito rumore.
- **Degrado da in-sample a out-of-sample.** È normale che l'out-of-sample sia peggiore. Se l'in-sample ha Sharpe 2.4 e l'out-of-sample 0.3, il 90% del risultato era adattamento ai dati.

## Costi: fee, funding, slippage realistico

Una strategia che guadagna lo 0,05% per operazione e fa venti operazioni al giorno sembra una macchina da soldi. Poi ci metti i costi, e scopri che stavi solo pagando l'exchange.

I costi da modellare esplicitamente:

- **Commissioni (fee).** Sugli exchange crypto, tipicamente dello stesso ordine dello 0,0x–0,1% per lato a seconda del volume e del tipo di ordine (maker o taker); sui broker tradizionali, strutture diverse. Ogni round trip le paga due volte.
- **Spread.** La differenza tra prezzo di acquisto e vendita: se compri al "prezzo" e vendi al "prezzo", stai ignorando che paghi l'ask e incassi il bid.
- **Funding.** Sui contratti perpetui, i pagamenti periodici di funding (tipicamente ogni poche ore) possono essere a tuo favore o contro, e su posizioni tenute a lungo pesano quanto le fee.
- **Slippage.** La differenza tra il prezzo a cui volevi eseguire e quello a cui esegui davvero. Dipende dalla dimensione dell'ordine rispetto alla profondità del book, dalla volatilità in quel momento, dalla latenza. Nei momenti in cui la strategia "vuole" entrare — spesso movimenti forti — lo slippage è peggiore della media.
- **Costi di finanziamento** per posizioni a leva o allo scoperto.
- **Latenza.** Il tempo tra il segnale e l'ordine eseguito: per strategie veloci, un secondo di ritardo è un costo.

Un modello di costo minimo, prudente, da applicare a ogni esecuzione simulata:

```python
from dataclasses import dataclass

@dataclass
class ModelloCosti:
    fee_taker: float = 0.0006       # 0,06% per lato: stima prudente, verifica sul tuo exchange
    spread_half: float = 0.0002     # metà spread tipico dell'asset
    slip_base: float = 0.0003       # slippage di base
    slip_impact: float = 0.10       # impatto proporzionale alla partecipazione al volume
    max_partecipazione: float = 0.01  # mai più dell'1% del volume della candela

    def prezzo_eseguito(self, prezzo_rif, lato, qta, volume_candela):
        partecipazione = min(qta / max(volume_candela, 1e-9), self.max_partecipazione)
        slip = self.slip_base + self.slip_impact * partecipazione
        segno = 1 if lato == "buy" else -1
        return prezzo_rif * (1 + segno * (self.spread_half + slip))

    def fee(self, controvalore):
        return controvalore * self.fee_taker
```

E la regola più utile di tutto il pezzo: il **test di sensibilità ai costi**. Rilancia il backtest walk-forward con i costi **raddoppiati**. Se il vantaggio scompare, non avevi un vantaggio: avevi un'ipotesi ottimistica sui costi. Le strategie robuste peggiorano ma sopravvivono; quelle fragili passano da profitto a perdita con un piccolo cambiamento.

## Overfitting: troppi parametri, troppi indicatori

L'overfitting è la ragione principale per cui lo Sharpe in sample è "quasi sempre spazzatura". Funziona così: più gradi di libertà dai alla strategia (parametri, indicatori, filtri, eccezioni), più facilmente trovi una combinazione che si adatta perfettamente al rumore del passato — e che non ha alcun potere sul futuro.

Il meccanismo che quasi nessuno considera è il **numero di tentativi**. Se provi cento varianti di una strategia su dati casuali, la migliore avrà comunque uno Sharpe notevole, per puro caso. La letteratura quantitativa ha formalizzato questa idea: esistono metriche come lo *Sharpe "deflazionato"*, che corregge lo Sharpe osservato per il numero di prove effettuate, e stime della *probabilità di overfitting del backtest* basate sulla combinazione di sottoperiodi. Non serve implementarle tutte per capirne il messaggio: **lo Sharpe della migliore di molte strategie non è lo Sharpe di una strategia.**

I segnali di overfitting che guardo:

- **Molti parametri rispetto alle operazioni.** Una strategia con 12 parametri e 80 operazioni nel backtest ha più manopole che prove. Una regola pratica: poche decine di operazioni per ogni parametro libero, come minimo.
- **Picchi invece di altipiani.** Fai variare un parametro attorno al valore ottimo. Se il risultato è buono solo in un punto preciso (media mobile a 17 sì, a 16 e 18 no), è un picco di rumore. Le strategie robuste mostrano un **altipiano**: funzionano, un po' meglio o un po' peggio, in un intervallo ampio di parametri.
- **Indicatori aggiunti per "sistemare" i periodi brutti.** Ogni filtro che aggiungi per eliminare un drawdown specifico è un adattamento a quel drawdown. Il prossimo drawdown sarà diverso.
- **Regole con eccezioni.** "Compra quando X, tranne il lunedì, tranne quando Y supera Z, tranne a dicembre". Ogni "tranne" è un parametro nascosto.
- **Il registro dei tentativi.** Tieni traccia di *tutte* le varianti provate, non solo di quella che tieni. Se hai provato 300 combinazioni, dovresti essere 300 volte più scettico sulla migliore.

La contromisura più efficace è la più noiosa: **strategie semplici**, pochi parametri con un razionale economico o di microstruttura (perché dovrebbe funzionare?), validazione walk-forward, e sensibilità ai parametri. Una strategia modesta e stabile vale più di una spettacolare e fragile.

## L'architettura di riferimento

Un sistema di trading automatico serio separa nettamente la ricerca, la simulazione e l'esecuzione, e soprattutto separa **chi decide** da **chi può fare danni**.

```
┌──────────────────────┐   ┌──────────────────────────────────────────┐
│ DATI                  │   │ RICERCA (offline)                         │
│ ingestion con         ├──►│ backtest engine · walk-forward · costi    │
│ timestamp + fonte     │   │ registro dei tentativi · holdout sigillato│
│ asset delistati incl. │   └──────────────────────┬───────────────────┘
└──────────┬───────────┘                           │ parametri congelati
           │ feed live                              ▼
           │                 ┌──────────────────────────────────────────┐
           └────────────────►│ STRATEGIA (produce SOLO intenzioni)       │
                             │ "vorrei comprare X, size S, motivo M"     │
                             └──────────────────────┬───────────────────┘
                                                    ▼
                             ┌──────────────────────────────────────────┐
                             │ RISK ENGINE (deterministico, separato)    │
                             │ cap posizione · perdita giornaliera ·     │
                             │ drawdown · esposizione · età dati         │
                             └──────────────────────┬───────────────────┘
                                                    ▼
                             ┌──────────────────────────────────────────┐
                             │ EXECUTION → exchange/broker               │
                             │ chiave API SENZA prelievi, IP allowlist,  │
                             │ subaccount dedicato                        │
                             └──────────────────────┬───────────────────┘
                                                    ▼
      WATCHDOG ESTERNO (kill switch) ◄── riconciliazione posizioni · log · allarmi
```

**Cosa non tocca la strategia**: gli ordini veri (produce intenzioni, non ordini), i limiti di rischio (li applica un modulo separato che la strategia non può modificare), le credenziali di prelievo (la chiave API non le ha proprio). È lo stesso principio che ho applicato agli agenti che scrivono su sistemi aziendali, con dry-run e coda di approvazione: il componente "intelligente" propone, un componente deterministico dispone. Ne ho parlato in dettaglio nel pezzo sul [kill switch per agenti che scrivono su Salesforce]({{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }}).

## Risk protocol: cap, kill switch, niente martingala

Un protocollo di rischio è un insieme di regole **scritte prima di andare live**, applicate da codice che la strategia non può aggirare, e che nessuno modifica a mercato aperto "perché questa volta è diverso".

Le regole minime:

- **Cap per operazione**: rischio massimo per singola operazione come frazione del capitale del conto (per esempio una piccola percentuale), calcolato sulla distanza dallo stop, non sulla size nominale.
- **Cap di esposizione totale**: somma delle posizioni aperte, per asset e complessiva, e numero massimo di posizioni.
- **Perdita giornaliera massima**: raggiunta, la strategia smette di aprire posizioni fino al giorno dopo.
- **Drawdown massimo**: raggiunto, **kill switch**: il sistema si ferma e richiede un intervento umano.
- **Niente martingala, niente medie al ribasso senza limite.** Raddoppiare la size dopo una perdita "per recuperare" trasforma una serie di perdite normali in una perdita catastrofica: è matematicamente la strada per azzerare il conto. Lo stesso vale per aggiungere a una posizione in perdita senza un limite rigido.
- **Leva sotto controllo**: la leva amplifica sia i rendimenti sia gli errori del backtest. Un bot che non ha dimostrato un vantaggio stabile senza leva non lo avrà con la leva.
- **Isolamento del capitale**: conto o subaccount dedicato con solo il capitale che il bot può usare. Il resto non deve essere raggiungibile.
- **Chiavi API minime**: permesso di trading, **mai di prelievo**, con allowlist degli IP del server.

### Il kill switch concettuale

Il **kill switch del trading** è un componente separato dalla strategia — idealmente un processo diverso, un "watchdog esterno", come quello che ho descritto per gli agenti che vanno in loop — che osserva il sistema e lo ferma quando qualcosa non torna. Concettualmente:

```python
class KillSwitch:
    """Processo separato: legge stato e metriche, non riceve ordini dalla strategia."""
    def __init__(self, cfg, broker, alert):
        self.cfg, self.broker, self.alert = cfg, broker, alert
        self.armato = True

    def controlla(self, stato):
        motivi = []
        if stato.drawdown > self.cfg.max_drawdown:              motivi.append("drawdown")
        if stato.perdita_oggi > self.cfg.max_perdita_giorno:    motivi.append("perdita_giornaliera")
        if stato.errori_api_consecutivi >= self.cfg.max_errori: motivi.append("errori_exchange")
        if stato.eta_ultimo_prezzo_s > self.cfg.max_eta_dato_s: motivi.append("dati_stale")
        if abs(stato.posizione_attesa - stato.posizione_reale) > self.cfg.tolleranza:
            motivi.append("riconciliazione")                     # il bot crede X, l'exchange dice Y
        if stato.slippage_medio_1h > self.cfg.max_slippage:     motivi.append("slippage_anomalo")
        if motivi:
            self.scatta(motivi)

    def scatta(self, motivi):
        self.broker.cancella_ordini_aperti()
        self.broker.blocca_nuove_aperture()
        if self.cfg.chiudi_posizioni_su_kill:      # decisione presa PRIMA, non durante il panico
            self.broker.chiudi_posizioni(tipo="controllato")
        self.alert.urgente(f"KILL SWITCH: {', '.join(motivi)}")
        self.armato = False                         # reset solo manuale, dopo analisi
```

Tre dettagli che fanno la differenza:

- **La riconciliazione** (posizione che il sistema *crede* di avere vs posizione che l'exchange *dice* che hai) è il controllo più sottovalutato. Ordini parzialmente eseguiti, risposte perse, riconnessioni: il bot può credere di essere flat mentre ha una posizione aperta. Quando divergono, ci si ferma.
- **Cosa fare con le posizioni aperte si decide prima.** Chiuderle subito può essere la scelta giusta o sbagliata a seconda della strategia e del mercato; deciderlo durante un incidente è sempre sbagliato.
- **Il reset è manuale.** Un kill switch che si riarma da solo dopo cinque minuti non è un kill switch.

## Cosa loggare in paper trading

Il **paper trading** — la strategia che gira in tempo reale sul mercato vero, ma con ordini simulati o su un ambiente di test — è il ponte tra backtest e soldi veri. Serve a una cosa sola: **verificare che le ipotesi del backtest reggano nella realtà**. Per farlo, devi loggare le cose giuste.

Per ogni decisione e ogni ordine:

- **Timestamp del segnale** e **timestamp del dato** su cui si basa (quanto era vecchio il prezzo quando hai deciso?).
- **Snapshot degli input** della decisione: i valori degli indicatori in quel momento, per poterla riprodurre.
- **Prezzo di riferimento** atteso (quello che il backtest avrebbe usato).
- **Timestamp di invio**, **timestamp di esecuzione**, **prezzo eseguito**, **quantità eseguita** (anche parziale).
- **Fee effettive**, **slippage effettivo** rispetto al prezzo di riferimento.
- **Posizione attesa vs posizione reale** dopo ogni evento.
- **Errori e retry** dell'API, disconnessioni, rate limit.

E ogni settimana il confronto che conta: **backtest vs paper sullo stesso periodo**. Fai girare il backtest esattamente sulle stesse settimane del paper trading e confronta operazione per operazione. Le differenze ti dicono dove il backtest mente: slippage reale più alto di quello modellato, segnali che in tempo reale arrivano tardi, dati che in diretta hanno buchi che lo storico non ha. Se paper e backtest divergono molto, non passare al live: correggi il modello.

Durata: abbastanza da vedere un numero sensato di operazioni e almeno un cambio di condizioni di mercato. Per una strategia che opera poche volte a settimana, significa **mesi**, non giorni. Sui principi di log e metriche (tracce, costo per esecuzione, allarmi su anomalie) vale quanto ho scritto sull'[osservabilità degli LLM in produzione]({{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}): cambia il dominio, non la disciplina.

## Percorso di implementazione, a step

1. **Scrivi l'ipotesi prima del codice**: perché questa strategia dovrebbe funzionare? Quale comportamento del mercato sfrutta? Se non sai rispondere, stai cercando pattern nel rumore.
2. **Costruisci un dataset pulito**: timestamp e fuso orario documentati, asset delistati inclusi, fonte tracciata, controlli sui buchi.
3. **Sigilla un holdout finale** e non guardarlo.
4. **Implementa il backtest con esecuzione alla candela successiva** e il modello di costi esplicito.
5. **Registra ogni tentativo** in un file o database: parametri, periodo, risultato.
6. **Valida con walk-forward ed embargo**, guardando stabilità dei parametri e degrado in/out-of-sample.
7. **Test di sensibilità**: costi raddoppiati, parametri vicini all'ottimo, un segnale in ritardo di una candela, regimi diversi.
8. **Usa l'holdout una volta.** Se fallisce, la strategia è morta: non "ritoccarla un po'".
9. **Implementa risk engine e kill switch** separati dalla strategia, con configurazione scritta.
10. **Paper trading per mesi**, con log completi e confronto settimanale backtest vs paper.
11. **Live con capitale minimo**, subaccount dedicato, chiavi senza prelievo, e gli stessi controlli del paper.

## Fallimenti tipici e come li riconosci dai log

- **Performance live molto peggiore del backtest dal primo giorno.** Quasi sempre look-ahead o costi sottostimati. Confronta i prezzi di esecuzione reali con quelli che il backtest avrebbe usato: se la differenza è sistematica, il backtest eseguiva a prezzi impossibili.
- **Slippage effettivo molto sopra il modello.** Nei log di esecuzione, differenza media tra prezzo di riferimento e prezzo eseguito superiore alle ipotesi. Spesso concentrata proprio nei momenti in cui la strategia entra: stai comprando movimento, e il movimento costa.
- **Operazioni in ritardo rispetto al segnale.** Età del dato alta al momento della decisione, o latenza di invio alta: il segnale che nel backtest era istantaneo in realtà arriva quando l'occasione è passata.
- **Posizione attesa ≠ posizione reale.** Ordini parziali o risposte perse. Se il log mostra divergenze anche piccole e ripetute, il problema è nel codice di esecuzione, ed è pericoloso.
- **Errori API a raffica, poi ordini duplicati.** Retry senza idempotenza: un ordine andato a buon fine ma con risposta persa viene reinviato. Usa identificativi client univoci per ordine.
- **Parametri che cambiano a ogni ricalibrazione.** In walk-forward o in produzione, se l'ottimo salta da un estremo all'altro, la strategia non ha un segnale stabile.
- **Dati fermi trattati come validi.** Il feed si blocca, l'ultimo prezzo resta uguale per minuti, la strategia continua a decidere su un mercato che non vede più. Il controllo sull'età del dato deve fermarla.

## Costi: ordini di grandezza

Stime indicative per chi costruisce un sistema personale o di ricerca.

- **Infrastruttura**: un server virtuale in un datacenter europeo per far girare strategia, risk engine e watchdog costa nell'ordine di **10–40 € al mese**. Serve affidabilità (uptime, riavvio automatico), non potenza.
- **Dati**: gli exchange crypto forniscono spesso dati storici e live tramite API; dati di qualità con asset delistati, book storici o mercati tradizionali possono richiedere abbonamenti da **decine a centinaia di euro al mese**.
- **Calcolo per i backtest**: un walk-forward con griglia di parametri su qualche anno di dati orari gira su una CPU normale in minuti o ore; l'energia è trascurabile (un PC da 100–200 W per qualche ora = pochi decimi di kWh).
- **Costi di trading**: il vero costo, e quello da modellare. Una strategia che fa molte operazioni con fee e slippage dello 0,1% per round trip paga una frazione rilevante del capitale ogni anno solo in esecuzione.
- **Tempo**: mesi di paper trading prima del live. È il costo che nessuno vuole pagare e quello che risparmia di più.

## Quando non automatizzare affatto

- **Quando il vantaggio non sopravvive ai costi raddoppiati.** Non hai un vantaggio.
- **Quando non puoi monitorare il sistema.** Un bot che gira mentre sei in ferie senza allarmi che ti raggiungano è un rischio, non un'automazione.
- **Quando il capitale è piccolo e le fee dominano.** Con importi ridotti, commissioni minime e spread mangiano qualsiasi vantaggio statistico.
- **Quando stai usando soldi che non puoi permetterti di perdere.** Nessun backtest giustifica questo.
- **Quando gestisci denaro di altri.** Oltre al rischio, entri in attività regolamentate: non è un progetto da weekend.
- **Quando la strategia è "l'AI capisce il mercato".** Un modello linguistico che legge notizie e decide acquisti non è una strategia validata: è un generatore di decisioni non testabili. Se non puoi fare un walk-forward, non puoi sapere se funziona.
- **Quando il vero obiettivo è l'emozione del trading.** Automatizzarlo toglie l'emozione e lascia solo le perdite.

## Checklist operativa prima di mettere capitale vero

- [ ] Ipotesi della strategia scritta, con un razionale economico o di microstruttura.
- [ ] Dataset con timestamp documentati, asset delistati inclusi, buchi controllati.
- [ ] Esecuzione simulata alla candela successiva; nessuna statistica calcolata su dati futuri.
- [ ] Modello di costi con fee, spread, funding, slippage e limite di partecipazione al volume.
- [ ] Registro di tutti i tentativi e delle varianti scartate.
- [ ] Walk-forward con embargo; parametri stabili tra i fold; degrado in/out-of-sample accettabile.
- [ ] Sensibilità: costi raddoppiati, parametri vicini, segnale ritardato, regimi diversi.
- [ ] Holdout finale usato una volta sola, con esito positivo.
- [ ] Risk engine separato: cap per operazione, esposizione, perdita giornaliera, drawdown.
- [ ] Kill switch esterno con riconciliazione, controllo età dati, reset solo manuale.
- [ ] Niente martingala, niente medie al ribasso illimitate, leva sotto controllo.
- [ ] Chiavi API senza prelievo, IP allowlist, subaccount dedicato.
- [ ] Mesi di paper trading con log completi e confronto settimanale col backtest.
- [ ] Allarmi che ti raggiungono davvero, anche fuori orario.

## Il verdetto

Uno **Sharpe 2.4 in sample** non dice quasi niente sulla tua strategia: dice quanto sei stato bravo a trovare una combinazione che si adatta al passato. Il **backtest del tuo bot di trading mente** ogni volta che usa informazioni che non avresti avuto, un universo di asset sopravvissuti, costi immaginari, o la migliore tra cento varianti provate. Non per cattiveria: perché ogni scorciatoia verso un risultato migliore è anche una scorciatoia verso l'autoinganno.

Il metodo onesto è noioso e funziona: ipotesi prima del codice, dati puliti, esecuzione realistica, costi raddoppiati per sicurezza, validazione walk-forward con embargo, un holdout sigillato, parametri stabili invece di picchi fortunati. E soprattutto un protocollo di rischio scritto prima, eseguito da un componente che la strategia non può aggirare, con un kill switch che si ferma quando i dati sono vecchi, le posizioni non tornano o le perdite superano il limite — e che si riarma solo dopo che una persona ha capito cosa è successo.

Se dopo tutto questo la strategia sopravvive con un vantaggio modesto e stabile, hai qualcosa su cui ragionare. Se non sopravvive, hai risparmiato i soldi che il mercato ti avrebbe tolto per insegnarti la stessa lezione. E ripeto: non è consulenza finanziaria, e nessun metodo elimina il rischio di perdere il capitale.

Se ti interessa il lato ingegneristico — pipeline di dati affidabili, backtest riproducibili, watchdog e kill switch per sistemi che agiscono da soli — trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Parliamo di architettura e controlli, non di segnali.

## FAQ

### Questo articolo mi dice quale strategia usare?
No. È un articolo di metodo sulla validazione dei sistemi di trading automatici: come evitare di ingannarsi con il backtest, come stimare costi realistici, come proteggere il capitale con controlli di rischio. Non contiene segnali, strategie consigliate o previsioni, e non costituisce consulenza finanziaria. Il trading comporta il rischio di perdere il capitale.

### Perché uno Sharpe alto in sample non è affidabile?
Perché è misurato sugli stessi dati su cui hai scelto la strategia e i parametri. Ogni variante provata aumenta la probabilità che la migliore sia buona per caso, e ogni bias nei dati o ipotesi ottimistica sui costi gonfia il risultato. Conta la performance out-of-sample, ottenuta con una validazione walk-forward su dati mai usati per le scelte, possibilmente confermata su un holdout toccato una volta sola.

### Cos'è la validazione walk-forward?
È una procedura che simula il processo reale: scegli i parametri su una finestra di dati passati (train), li applichi senza modificarli sulla finestra successiva (test), poi sposti le finestre in avanti e ripeti. La curva di rendimento si costruisce concatenando solo i periodi di test. Tra train e test si lascia un periodo di esclusione (embargo) per evitare che indicatori o etichette con finestre temporali condividano informazione.

### Cos'è il look-ahead bias e come lo trovo?
È quando il backtest usa informazioni che nel momento della decisione non erano disponibili: eseguire al prezzo di chiusura della stessa candela su cui calcoli il segnale, normalizzare con statistiche dell'intero periodo, allineare male serie con fusi orari diversi. Un test utile è ritardare tutti i segnali di una candela: se il rendimento crolla, la strategia probabilmente dipendeva da informazioni che non avresti avuto in tempo reale.

### Quanto pesano davvero i costi di trading?
Molto più di quanto si pensi, soprattutto per le strategie che operano spesso. Commissioni su entrambi i lati, spread, funding sui perpetui, slippage legato alla dimensione degli ordini e alla volatilità, latenza. Il test più utile è rilanciare il backtest con i costi raddoppiati: se il vantaggio scompare, era un'illusione creata da ipotesi ottimistiche.

### Come capisco se la mia strategia è in overfitting?
Guarda il numero di parametri rispetto al numero di operazioni, la stabilità dei parametri ottimi tra i fold del walk-forward, se il risultato forma un altipiano o un picco quando vari i parametri, e quanto degrada la performance da in-sample a out-of-sample. Tieni un registro di tutte le varianti provate: più tentativi hai fatto, più devi essere scettico sulla migliore.

### Cosa deve fare un kill switch per un bot di trading?
Fermare il sistema quando qualcosa non torna: drawdown o perdita giornaliera oltre il limite, errori ripetuti dell'API, dati di prezzo fermi da troppo tempo, differenza tra la posizione che il bot crede di avere e quella reale sull'exchange, slippage anomalo. Deve girare separato dalla strategia, cancellare gli ordini aperti, bloccare nuove aperture, gestire le posizioni secondo una regola decisa prima, allertare una persona e riarmarsi solo manualmente.

### Perché la martingala è così pericolosa?
Perché raddoppiare la size dopo ogni perdita per recuperare tutto con la prossima vincita trasforma una normale serie di perdite consecutive — che prima o poi arriva sempre — in una perdita enorme, spesso superiore al capitale disponibile. Lo stesso vale per aggiungere senza limite a una posizione in perdita. Un protocollo di rischio serio vieta entrambe le pratiche.

### Quanto deve durare il paper trading?
Abbastanza da accumulare un numero significativo di operazioni e da attraversare almeno un cambio di condizioni di mercato. Per una strategia che opera poche volte a settimana significa mesi, non giorni. Lo scopo non è "vedere se guadagna", ma verificare che prezzi di esecuzione, slippage, latenza e disponibilità dei dati corrispondano alle ipotesi del backtest.

### Posso usare un modello di AI che legge le notizie per decidere i trade?
Puoi sperimentarlo, ma è molto difficile validarlo con lo stesso rigore di una strategia quantitativa: i modelli cambiano, le loro risposte non sono deterministiche, e un backtest su notizie storiche rischia enormemente il look-ahead (il modello potrebbe "conoscere" eventi successivi dai suoi dati di addestramento). Se non puoi fare una validazione walk-forward credibile, non sai se funziona, e non dovresti affidargli capitale.
