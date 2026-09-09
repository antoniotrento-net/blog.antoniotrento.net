---
lang: it
permalink: /it/blog/trascrizione-audio-offline-windows/
title: "Whisper API vs Parakeet/NeMo offline su Windows: quando la trascrizione in cloud ti costa più della GPU (e ti porta via le riunioni)"
date: 2026-10-01 07:30:00 +0200
author: "Antonio Trento"
description: "Trascrizione audio offline su Windows: Whisper API vs faster-whisper e Parakeet/NeMo self-hosted. Costi reali per 20 ore al mese, diarizzazione in italiano, WER onesto, pipeline e policy GDPR per non mandare le riunioni del CdA a un vendor USA."
keywords: ["trascrizione audio offline windows", "whisper api costo", "nvidia parakeet", "meeting transcription gdpr", "asr self-hosted", "faster-whisper italiano"]
image: /assets/images/posts/trascrizione-audio-offline-windows.jpg
pillar: integrazioni-dati
related: [/it/blog/agente-imap-pec-fatture/, /it/blog/vllm-vs-ollama-produzione/]
---

## Le riunioni del CdA non devono finire su un server americano

Facciamo il conto che nessun venditore di SaaS ti fa. Registri le riunioni — CdA, commerciale, tecniche — e le mandi a un servizio di trascrizione in cloud. Comodo: carichi il file, torna il testo. Poi qualcuno chiede: *"dove vanno questi audio?"*. La risposta onesta è "su un server, spesso negli Stati Uniti, di un fornitore che li conserva per un tempo che non controlli". E dentro quegli audio ci sono i numeri del budget, la strategia sul concorrente, i nomi dei clienti, le valutazioni sul personale. Roba che non manderesti mai per email in chiaro, e che invece stai spedendo a un terzo perché "la trascrizione automatica è comoda".

La **trascrizione audio offline su Windows** risolve questo alla radice: l'audio non lascia mai la tua macchina. Il modello gira in locale, sulla GPU che probabilmente hai già, e il testo resta dentro il tuo perimetro. Non è un downgrade di qualità — sull'italiano, il miglior modello offline è competitivo con il cloud — ed è spesso più economico di quanto pensi. Ma va fatto con criterio, perché ci sono trappole vere: il modello sbagliato per l'italiano, la diarizzazione che crolla sul parlato sovrapposto, e il riassunto LLM che ti inventa una delibera mai presa.

In questo pezzo confronto **Whisper API vs le opzioni offline** (faster-whisper, Whisper.cpp, e i modelli NVIDIA Parakeet/NeMo), con costi reali per 20 ore al mese, la pipeline file → testo → riassunto → archivio, i vincoli di Windows come runtime, un metodo onesto per misurare la qualità (WER, non magia), e la policy GDPR su consenso e cancellazione. È il pezzo di **ASR self-hosted** che avrei voluto leggere prima di montarne uno.

## Cosa c'è davvero in una registrazione: PII, strategia, numeri

Prima di parlare di modelli, mettiamo a fuoco *cosa* stai processando, perché è questo che decide l'architettura. Una registrazione di riunione non è un file audio neutro. Contiene:

- **Dati personali (PII):** nomi, ruoli, opinioni su persone, valutazioni, a volte dati particolari (salute, se si parla di un dipendente in malattia). Trattarli attiva il GDPR in pieno.
- **Strategia e segreti industriali:** piani commerciali, prezzi, trattative, roadmap. Il tipo di informazione che un concorrente pagherebbe per avere.
- **Numeri riservati:** budget, fatturato, margini, valutazioni. In un CdA, deliberazioni che hanno valore legale.

Mandare tutto questo a un vendor esterno non è "usare un tool": è un **trasferimento di dati** verso un terzo, spesso extra-UE, con tutte le implicazioni di riservatezza e compliance. E la comodità non compensa il rischio quando il rischio è "la strategia dell'azienda in mano a un fornitore fuori dal tuo controllo".

Il principio che applico, e che è il cuore di questo blog: **i dati sensibili restano dove li controlli tu.** Per l'audio delle riunioni questo significa trascrizione in locale, sul tuo hardware, in UE, senza che un byte esca. Non per ideologia: per la stessa ragione per cui non pubblichi il budget su Twitter. È lo stesso ragionamento che ho fatto costruendo l'{{ '/it/blog/agente-imap-pec-fatture/' | relative_url }}: i documenti fiscali e le riunioni sono dati che non escono, punto.

## Whisper API: prezzo per ora, retry e retention

Partiamo dal cloud, onestamente, perché "self-hosted sempre" senza numeri è ideologia, non ingegneria.

Il **costo della Whisper API** è basso in euro: come ordine di grandezza siamo intorno a pochi centesimi di dollaro al minuto, cioè circa 0,30–0,40 $ per ora di audio. Per 20 ore al mese parliamo di **7–8 € al mese**. Detta così, sembra una non-questione. Ed è vero: se il tuo unico criterio è il costo in euro a basso volume, il cloud è economico. Chi ti dice "self-hosted per risparmiare" a 20 ore al mese ti sta mentendo sui numeri.

Ma il costo vero non è (solo) quello:

- **Retention e controllo.** Dove finisce l'audio, per quanto, chi può accedervi? Anche con policy di non-training, stai affidando materiale riservato a un terzo. Per una PMI italiana con dati sensibili, questo è il costo che conta, e non si misura in euro al minuto.
- **Retry e ri-elaborazioni.** Un file lungo che fallisce va rimandato. Una trascrizione da rifare con parametri diversi raddoppia il costo. La diarizzazione (chi ha parlato) spesso è un servizio a parte, a prezzo maggiore. Il "7 € al mese" cresce quando il caso d'uso è reale.
- **SaaS per riunioni, non API pura.** Molti non usano l'API grezza ma un prodotto (tipo assistente-riunioni) a prezzo *per utente al mese*: 10–20 € a testa, che su un team diventano centinaia di euro l'anno, con i dati che restano dal fornitore. Lì il conto economico cambia del tutto.
- **Lock-in.** Più integri il vendor nei tuoi flussi, più diventa costoso uscirne. Il prezzo basso di oggi è l'aggancio per il prezzo di domani.

La sintesi onesta: **il cloud vince sul costo in euro a basso volume, e perde sulla riservatezza e sul controllo — sempre.** Se le tue registrazioni sono chiacchiere senza segreti, il cloud va benissimo. Se contengono la strategia dell'azienda, la domanda non è "quanto costa": è "sono disposto a farle uscire?". Per il CdA la risposta è no, a qualsiasi prezzo.

## Offline: faster-whisper, Whisper.cpp, e i modelli NVIDIA

Sul lato self-hosted ci sono famiglie diverse, e sceglierle a caso è il primo errore. Chiariamo, con l'onestà tecnica che serve.

### Whisper (OpenAI) e le sue implementazioni offline

Il modello Whisper è open e scaricabile: puoi eseguirlo **in locale**, senza API. Le implementazioni che contano:

- **faster-whisper:** reimplementazione basata su CTranslate2, molto più veloce e leggera dell'originale. Supporta quantizzazione **int8** e **float16**, gira su GPU NVIDIA con CUDA e anche su CPU. È la mia scelta di default su Windows: veloce, buona qualità sull'italiano con `large-v3`, VRAM contenuta.
- **Whisper.cpp:** port in C/C++ ottimizzato, con modelli quantizzati (GGUF). Eccellente su CPU e su hardware modesto, build native per Windows. La scelta se non hai una GPU o vuoi il minimo di dipendenze.
- **WhisperX:** costruito su faster-whisper, aggiunge allineamento a livello di parola e diarizzazione (via pyannote). La scelta quando ti serve "chi ha detto cosa" con timestamp precisi.

Sull'**italiano**, il modello `large-v3` di Whisper è oggi il riferimento offline: qualità alta, gestione decente della punteggiatura, robustezza sul lessico aziendale. I modelli più piccoli (`small`, `medium`) sono più veloci ma sbagliano di più su termini tecnici e nomi propri italiani.

### NVIDIA Parakeet e NeMo: veloci, ma attento alla lingua

Qui il punto onesto che quasi nessun articolo ti dice. **NVIDIA Parakeet** è un modello ASR straordinariamente veloce e accurato — ma è **principalmente inglese**. Se lo punti su una riunione in italiano, i risultati sono deludenti. Non è "meglio di Whisper" in assoluto: è meglio *sull'inglese*.

I modelli multilingue della famiglia NVIDIA NeMo (tipo Canary) coprono alcune lingue europee, ma la copertura dell'italiano è più debole rispetto a Whisper `large-v3`, che è stato addestrato su un mix multilingue ampio con molto italiano.

Conclusione pratica per una PMI italiana: **per trascrivere l'italiano, la famiglia Whisper (faster-whisper large-v3) è la scelta giusta.** Parakeet/NeMo entrano in gioco se il tuo audio è prevalentemente inglese, o se hai bisogno della loro velocità estrema su hardware NVIDIA dedicato e accetti la lingua inglese. Sceglierli "perché NVIDIA fa figo" e poi lamentarsi della qualità sull'italiano è l'errore che vedo fare.

### VRAM e hardware

Numeri come ordine di grandezza, dichiarati come stime:

| Modello / setup | VRAM | Note |
|-----------------|------|------|
| faster-whisper large-v3 int8 | ~3–5 GB | gira su GPU consumer 8–12 GB |
| faster-whisper large-v3 float16 | ~8–10 GB | qualità piena, GPU da 12 GB+ |
| Whisper.cpp (quantizzato) | CPU / poca VRAM | lento su CPU, ok su hardware modesto |
| Parakeet/NeMo | dipende dal modello | pensati per GPU NVIDIA, inglese |

Una GPU consumer con 12 GB (una scheda di fascia media, anche usata) copre tranquillamente `large-v3` in int8 con margine per la diarizzazione. Non serve un data center. Serve la GPU che probabilmente hai già in una workstation, o che compri usata a poche centinaia di euro. Sul dimensionamento GPU per il self-hosting ho scritto in dettaglio confrontando {{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }}: gli stessi principi di VRAM e quantizzazione valgono qui.

## Diarizzazione e parlato sovrapposto in italiano

"Trascrivi l'audio" è metà del lavoro. L'altra metà, spesso la più utile, è **la diarizzazione**: sapere *chi* ha detto cosa. Senza, hai un muro di testo; con, hai un verbale.

Lo standard offline è **pyannote.audio**, di solito orchestrato via WhisperX: prima si trascrive (faster-whisper), poi si allineano le parole ai tempi, poi si assegnano gli speaker ai segmenti. Funziona, ma con vincoli onesti da mettere in conto:

- **Il parlato sovrapposto è il nemico.** Nelle riunioni italiane si parla sopra, ci si interrompe, si accavallano le voci. La diarizzazione fatica esattamente lì: due persone che parlano insieme diventano un segmento confuso o attribuito a uno solo. Nessun sistema, cloud o offline, risolve bene questo. Chi promette diarizzazione perfetta su una riunione vivace mente.
- **Il numero di speaker.** Se lo conosci in anticipo (CdA di 5 persone), passalo come vincolo: migliora l'assegnazione. Se lo lasci stimare, su audio difficili sbaglia.
- **La qualità del microfono domina tutto.** Un mic ambientale in una sala grande dà risultati molto peggiori di microfoni individuali o di una buona conferenza. Prima di dare la colpa al modello, guarda com'è registrato l'audio: il 70% dei problemi di diarizzazione sono problemi di acquisizione.
- **pyannote richiede l'accettazione delle condizioni dei modelli** (via Hugging Face) e il download dei pesi: fallo una volta, poi gira tutto in locale. Nessun audio esce per diarizzare.

Aspettativa realistica: su audio pulito con microfoni decenti e speaker che si rispettano, la diarizzazione è buona e ti fa risparmiare ore di lavoro. Su una riunione caotica registrata col microfono del portatile a tre metri, aspettati di dover correggere a mano. È uno strumento che assiste, non un miracolo.

## L'architettura di riferimento: file → testo → riassunto → archivio

Ecco la pipeline completa. Il confine è netto e non negoziabile: **l'audio non lascia mai la macchina.**

```
   File audio ──▶ ┌─────────────────────────────────────┐
   (recorder,     │ 1. INGEST: cartella "sorvegliata"    │
    mic, meet)    │    watched folder in ingresso        │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ 2. ASR OFFLINE (faster-whisper       │
                  │    large-v3, int8, CUDA su Windows)  │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ 3. DIARIZZAZIONE (opzionale, WhisperX│
                  │    + pyannote): chi ha parlato       │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ 4. OUTPUT: transcript .txt + .srt    │
                  │    con timestamp e speaker           │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ 5. RIASSUNTO LLM LOCALE (opzionale,  │
                  │    Ollama) — marcato come LOSSY      │
                  └───────────────┬─────────────────────┘
                                  ▼
                  ┌─────────────────────────────────────┐
                  │ 6. ARCHIVIO strutturato + retention  │
                  └─────────────────────────────────────┘

   Confine: NIENTE esce dalla macchina/rete. Nessun vendor esterno.
```

**Cosa NON fa mai questo sistema:**

- Non invia l'audio o il testo a un servizio esterno. Tutto in locale/UE.
- Non tratta il **riassunto LLM come verità**: il transcript è la fonte, il riassunto è un comodo derivato fallibile (ci torno, è importante).
- Non conserva le registrazioni oltre la retention definita.

Il transcript grezzo (`.txt` + `.srt`) è l'artefatto primario. Il riassunto è un extra, e va trattato come tale — non come il verbale ufficiale.

## Windows come runtime (non solo Linux server)

Quasi tutti i tutorial ASR assumono Linux. Ma in una PMI italiana la macchina con la GPU è spesso una **workstation Windows**, e va bene così — con qualche accortezza onesta.

- **faster-whisper e Whisper.cpp girano nativamente su Windows.** faster-whisper con CUDA richiede driver NVIDIA aggiornati e le librerie cuDNN/CUDA runtime corrette: una volta configurate, vola. Whisper.cpp ha build Windows pronte, anche solo-CPU.
- **NeMo (Parakeet/Canary) è Linux-first e doloroso su Windows nativo.** Se proprio ti serve, usalo via **WSL2** (il sottosistema Linux di Windows) o in Docker con supporto GPU. Non combattere per farlo girare nativo: non ne vale la pena.
- **Percorsi e permessi Windows:** attenzione ai path con spazi e ai permessi delle cartelle sorvegliate. Usa percorsi assoluti e servizi/scheduler Windows per l'automazione (Task Scheduler o un servizio) invece dei cron di Linux.
- **ffmpeg è la dipendenza nascosta.** Serve per convertire i formati audio (m4a, mp4, ecc.) in wav 16 kHz mono che i modelli vogliono. Installalo e mettilo nel PATH: metà dei "non funziona" su Windows sono ffmpeg mancante.

Uno script di trascrizione base con faster-whisper, su Windows, in italiano:

```python
# transcribe.py — faster-whisper, italiano, GPU con fallback CPU
from faster_whisper import WhisperModel
from pathlib import Path

# int8_float16 = qualità/velocità ottima su GPU consumer
model = WhisperModel("large-v3", device="cuda", compute_type="int8_float16")

def trascrivi(path_audio: str) -> None:
    segments, info = model.transcribe(
        path_audio,
        language="it",              # forza l'italiano, non far indovinare
        vad_filter=True,            # taglia i silenzi: più veloce, meno errori
        beam_size=5,
    )
    base = Path(path_audio).with_suffix("")
    with open(f"{base}.txt", "w", encoding="utf-8") as ftxt, \
         open(f"{base}.srt", "w", encoding="utf-8") as fsrt:
        for i, seg in enumerate(segments, 1):
            ftxt.write(seg.text.strip() + "\n")
            fsrt.write(f"{i}\n{_ts(seg.start)} --> {_ts(seg.end)}\n"
                       f"{seg.text.strip()}\n\n")
    print(f"OK: {base}.txt / .srt  (lingua rilevata: {info.language})")

def _ts(s: float) -> str:
    h, r = divmod(int(s), 3600); m, sec = divmod(r, 60)
    ms = int((s - int(s)) * 1000)
    return f"{h:02}:{m:02}:{sec:02},{ms:03}"

if __name__ == "__main__":
    import sys
    trascrivi(sys.argv[1])
```

Due dettagli che fanno la differenza sull'italiano: `language="it"` (non lasciare che il modello indovini la lingua: sui primi secondi sbaglia e trascrive in un misto), e `vad_filter=True` (il Voice Activity Detection taglia i silenzi, velocizza e riduce le "allucinazioni da silenzio" tipiche di Whisper).

## Benchmark su 30 minuti di riunione reale: il WER, dichiarato come metodo

Adesso la parte che separa l'ingegneria dal marketing. Come fai a sapere se la qualità è accettabile? Non fidandoti dei benchmark del vendor, che girano su audio pulito in inglese da studio. **Misuri sul TUO audio.**

La metrica standard è il **WER (Word Error Rate)**: la percentuale di parole sbagliate rispetto a un riferimento corretto. WER = (Sostituzioni + Cancellazioni + Inserimenti) / Numero parole di riferimento. Un WER del 10% significa una parola sbagliata ogni dieci.

Il metodo onesto — e sottolineo *metodo*, perché il numero senza metodo è fuffa:

1. Prendi **30 minuti di una riunione reale tua** (italiano, il tuo lessico, le tue condizioni di registrazione), non un audio demo.
2. Fai trascrivere il tratto da un umano con cura: è il tuo **riferimento** (ground truth).
3. Fai trascrivere lo stesso audio dai vari sistemi (faster-whisper large-v3, un modello più piccolo, eventualmente il cloud).
4. Calcola il WER di ciascuno contro il riferimento, dopo aver normalizzato (minuscole, via la punteggiatura, numeri in cifre coerenti).

```python
# wer.py — WER onesto, con normalizzazione dichiarata
import jiwer   # pip install jiwer

def normalizza(t: str) -> str:
    import re
    t = t.lower()
    t = re.sub(r"[^\w\s]", " ", t)        # via punteggiatura
    t = re.sub(r"\s+", " ", t).strip()
    return t

def calcola_wer(riferimento_path: str, ipotesi_path: str) -> float:
    rif = normalizza(open(riferimento_path, encoding="utf-8").read())
    ipo = normalizza(open(ipotesi_path, encoding="utf-8").read())
    wer = jiwer.wer(rif, ipo)
    print(f"WER = {wer:.1%}  (riferimento: {len(rif.split())} parole)")
    return wer
```

Cosa aspettarsi, come ordine di grandezza dichiarato come stima (dipende MOLTO dall'audio): su una riunione italiana pulita, `large-v3` offline dà un WER competitivo con il cloud, spesso indistinguibile nell'uso pratico. Su audio difficile (mic lontano, accavallamenti, dialetto), il WER peggiora per tutti — cloud incluso. Il punto: **la differenza cloud vs offline sull'italiano, misurata sul tuo audio, è di solito piccola. La differenza sulla privacy è enorme.** Ecco perché il confronto va fatto sui tuoi file, non sulle slide di nessuno.

E attenzione: il WER conta le parole, non l'importanza. Un WER del 5% che però sbaglia sistematicamente i nomi propri e i numeri è peggio, per un verbale, di un WER del 8% che sbaglia parole di riempimento. Guarda *dove* sbaglia, non solo quanto.

## Costi reali: la tabella per 20 ore al mese

Mettiamo i numeri sul tavolo, come stime dichiarate, per 20 ore di audio al mese.

| Voce | Cloud (Whisper API) | Offline (self-hosted) |
|------|--------------------|-----------------------|
| Costo per ora | ~0,30–0,40 $ | elettricità: pochi centesimi |
| 20 ore/mese | ~7–8 € | ~0,50–1 € di corrente |
| Hardware | nessuno | GPU (anche usata): ~200–400 € una tantum |
| GPU ammortizzata (3 anni) | — | ~6–11 €/mese |
| Diarizzazione | spesso extra a pagamento | inclusa (pyannote), CPU/GPU |
| Privacy / controllo | dati da un terzo | dati tuoi, in UE |
| Lock-in | crescente | nessuno |

Lettura onesta:

- **In pura cassa, a 20 ore al mese, cloud e offline si equivalgono** (~7 € vs GPU ammortizzata + spiccioli). Chi ti dice "risparmi un sacco self-hosting a basso volume" esagera.
- **La GPU si ripaga in controllo da subito**, e in euro quando il volume sale (100+ ore/mese, o SaaS a seggiola che costano decine di euro a testa). A volumi alti, l'offline vince anche in cassa, nettamente.
- **L'elettricità è trascurabile:** trascrivere 20 ore di audio richiede poche ore di GPU, meno di 1 kWh, pochi centesimi. Il consumo non è un argomento contro il self-hosting.
- **Il costo che non è in tabella** — la riservatezza delle riunioni — è quello che per il CdA vale più di tutti gli altri messi insieme.

Quindi: se il tuo audio è banale e a basso volume, il cloud è legittimo e non ti sto vendendo hardware inutile. Se contiene segreti o il volume è alto, l'offline è la scelta ovvia, e non ti costa di più.

## Architettura delle cartelle e retention

Un sistema di trascrizione senza una struttura d'archivio e una retention è un modo per accumulare registrazioni riservate a tempo indefinito — cioè un problema GDPR che cresce da solo. Ecco lo schema che uso.

```
trascrizioni/
├─ 00_ingest/                      # file audio in arrivo (sorvegliata)
├─ 01_in_lavorazione/              # spostati qui durante il processing
├─ 02_output/
│   └─ 2026/10/
│       └─ 2026-10-01_cda/
│           ├─ audio.m4a           # originale (retention breve!)
│           ├─ transcript.txt      # fonte di verità
│           ├─ transcript.srt      # con timestamp
│           └─ riassunto.md        # LOSSY — non è il verbale
├─ 03_archivio/                    # transcript conservati, audio rimossi
└─ _log/
    └─ pipeline.log                # cosa è stato processato, quando
```

Le regole di retention, che sono la parte che quasi tutti dimenticano:

- **L'audio originale ha la retention più breve.** È il dato più sensibile e più pesante. Una volta ottenuto e verificato il transcript, l'audio va cancellato secondo una politica definita (es. dopo 30 giorni, o subito dopo l'approvazione del verbale). Conservare gli audio per sempre è un rischio senza beneficio.
- **Il transcript si conserva secondo la finalità** (un verbale di CdA ha obblighi di conservazione diversi da una call informale). Definisci la durata per tipo.
- **Tutto è cancellabile su richiesta.** Il GDPR dà diritto alla cancellazione: la struttura deve permettere di trovare ed eliminare tutto ciò che riguarda una persona o una riunione. Cartelle per data e tipo rendono questo possibile; un mucchio di file no.
- **Accesso ristretto.** Le cartelle con dati di riunione hanno permessi stretti: non tutta l'azienda accede al transcript del CdA.

## Consenso alla registrazione e cancellazione: la policy

Trascrivere presuppone registrare, e registrare persone ha regole. Non sono un avvocato — questo è il punto di vista di chi costruisce il sistema, non un parere legale — ma i principi operativi sono chiari.

- **Consenso / informativa.** Le persone in riunione devono sapere che si registra. In molti contesti serve il consenso, in altri basta l'informativa con una base giuridica adeguata; in ambito lavorativo ci sono tutele specifiche (il controllo dei lavoratori ha vincoli precisi). Regola pratica: **dichiara sempre, all'inizio, che la riunione viene registrata e a quale scopo.** Il "lo registro di nascosto" è dove nascono i problemi.
- **Finalità dichiarata.** Registri *per fare il verbale*, non "per ogni evenienza". La finalità limita cosa puoi fare col dato e per quanto lo tieni.
- **Minimizzazione.** Registra e conserva solo ciò che serve. Se il verbale approvato basta, l'audio va cancellato.
- **Diritto di cancellazione.** Un partecipante può chiedere la cancellazione dei propri dati: il sistema deve poterlo fare. Ecco perché l'archivio è strutturato.
- **Sicurezza.** Dati riservati = accesso ristretto, cifratura del disco dove serve, niente copie sparse su chiavette e email.

Il vantaggio nascosto del self-hosting qui è enorme: **con la trascrizione offline, tutta questa policy la applichi tu, sui tuoi dischi.** Con il cloud, parte del trattamento è in mano al fornitore, e devi fidarti (e documentare) le sue garanzie. La sovranità non è solo tecnica: è la capacità di applicare la tua policy senza intermediari. Sul quadro compliance più ampio degli usi AI in azienda ho scritto separatamente; qui basti dire che la trascrizione offline *semplifica* la conformità invece di complicarla.

## L'avvertenza che vale più di tutte: il riassunto LLM non è il verbale

Questa sezione è quella che ti evita un guaio serio. Dopo il transcript, è tentante passarlo a un LLM locale (Ollama) e farsi generare il riassunto: decisioni, action item, punti chiave. Comodissimo. E pericoloso, se lo tratti male.

Il riassunto LLM è **lossy e fallibile**:

- **Comprime, quindi perde.** Un riassunto per definizione butta via informazione. Va bene per un promemoria, non per un atto.
- **Può allucinare.** Un LLM può inventare una decisione mai presa, attribuire una frase alla persona sbagliata, o "arrotondare" un numero. Su un verbale di CdA, una delibera inventata è un problema legale, non un refuso.
- **Amplifica gli errori del transcript.** Se l'ASR ha sbagliato un numero (2,5 milioni → 25 milioni), il riassunto propaga l'errore con tono sicuro.

Le regole non negoziabili:

1. **La fonte di verità è il transcript, non il riassunto.** Il verbale ufficiale si redige (da un umano) a partire dal transcript verificato, non dal riassunto AI.
2. **Il riassunto è un derivato marcato come tale.** Nel file lo scrivi in cima: *"Riassunto generato automaticamente, non verificato, non costituisce verbale."*
3. **I numeri e le decisioni si verificano sempre sul transcript.** Mai fidarsi del riassunto per una cifra o una delibera.
4. **Il riassunto LLM gira in locale** (Ollama), come tutto il resto: non mandi il transcript a un servizio esterno per riassumerlo, vanificando la privacy dell'ASR offline.

Detto brutalmente: **il riassunto AI è un post-it, non un atto notarile.** Usalo per ricordarti di cosa si è parlato, non per decidere chi ha deliberato cosa. Chi confonde i due si prepara una brutta sorpresa il giorno in cui qualcuno contesta il verbale.

## Percorso di implementazione, a step

1. **Verifica l'hardware:** GPU NVIDIA con ≥8 GB (meglio 12) per `large-v3` in int8; altrimenti Whisper.cpp su CPU.
2. **Installa le dipendenze:** driver NVIDIA + CUDA runtime, Python, faster-whisper, e **ffmpeg nel PATH**.
3. **Testa la trascrizione base** su un file breve con `language="it"` e verifica la qualità a occhio.
4. **Misura il WER** su 30 minuti di audio reale con riferimento umano: decidi se la qualità ti basta.
5. **Aggiungi la diarizzazione** (WhisperX + pyannote) se ti serve "chi ha parlato"; accetta le condizioni dei modelli una volta.
6. **Costruisci la pipeline a cartelle sorvegliate:** ingest → processing → output → archivio, con log.
7. **Aggiungi il riassunto LLM locale** (Ollama), marcato come lossy, se utile.
8. **Definisci la retention** e automatizza la cancellazione degli audio scaduti.
9. **Scrivi la policy** di consenso/informativa e comunicala a chi partecipa alle riunioni.
10. **Documenta** dove stanno i dati, chi accede, come si cancella.

## I fallimenti tipici e come li riconosci dai log

- **Allucinazioni da silenzio.** Whisper, su tratti di silenzio o rumore, a volte "inventa" testo ripetuto (una frase che si ripete all'infinito). Nei log/output lo vedi come ripetizioni anomale. Fix: `vad_filter=True`. Se persiste, controlla la qualità dell'audio.
- **Lingua sbagliata sui primi secondi.** Se non forzi `language="it"`, il modello a volte parte in un'altra lingua e trascrive un misto. Sintomo: le prime righe sono in "itanglese" o spagnolo. Fix: forza la lingua.
- **ffmpeg mancante.** Errore all'apertura del file (formato non supportato). Metà dei problemi su Windows. Fix: installa ffmpeg, verificalo nel PATH.
- **CUDA/cuDNN non trovati.** faster-whisper cade su CPU (lentissimo) o dà errore di libreria. Nei log vedi il fallback o l'errore cuDNN. Fix: allinea versioni driver/CUDA/cuDNN.
- **Diarizzazione che collassa gli speaker.** Tutti i segmenti attribuiti a uno o due speaker su una riunione di cinque persone: audio con mic lontano o parlato sovrapposto. Fix: migliora l'acquisizione, passa il numero di speaker atteso.
- **Numeri e nomi sbagliati sistematici.** Il WER può essere basso ma sbagliare sempre i nomi propri: aggiungi un glossario/prompt con i termini ricorrenti (nomi dell'azienda, prodotti) per aiutare il modello, e verifica sempre i numeri a mano.
- **OOM sulla GPU** con audio lunghissimi o float16 su schede piccole: passa a int8 o processa a segmenti.

La regola: **logga cosa è stato processato, con quale modello e con quali parametri.** Quando un transcript viene male, devi sapere se era l'audio, il modello o la config — e i log te lo dicono.

## Quando NON farlo

- **Se l'audio non è riservato e il volume è basso**, il cloud va benissimo: non montare hardware per trascrivere le note vocali della lista della spesa. Il self-hosting ha senso quando c'è riservatezza o volume.
- **Se non hai una GPU e l'audio è tanto**, Whisper.cpp su CPU è lento: valuta se il tempo di elaborazione ti sta bene, o procurati una GPU. Non forzare una CPU a fare il lavoro di una GPU su volumi seri.
- **Se ti serve l'inglese perfetto in tempo reale**, Parakeet/NeMo su Linux/GPU dedicata sono ottimi — ma è un altro caso d'uso, non la riunione italiana.
- **Se non puoi garantire la policy** (consenso, retention, accesso ristretto), fermati sul processo prima che sulla tecnologia: trascrivere di nascosto o conservare senza regole è un problema, offline o cloud che sia.
- **Se pensi di usare il riassunto AI come verbale ufficiale**, non farlo: quello non è un limite tecnico da aggirare, è un confine da rispettare.

## Checklist operativa prima di andare live

- [ ] GPU verificata (VRAM sufficiente per `large-v3` int8) o piano CPU con Whisper.cpp.
- [ ] Driver NVIDIA + CUDA/cuDNN allineati; **ffmpeg nel PATH**.
- [ ] Trascrizione con `language="it"` e `vad_filter=True` testata su audio reale.
- [ ] **WER misurato** su 30 min di riunione reale con riferimento umano.
- [ ] Diarizzazione configurata (se serve), con numero speaker atteso quando noto.
- [ ] Pipeline a cartelle sorvegliate: ingest → output → archivio, con log.
- [ ] **Nessun dato esce dalla macchina/rete:** verificato che ASR e riassunto sono locali.
- [ ] Riassunto LLM locale, marcato come lossy e non-verbale.
- [ ] **Retention definita:** audio a vita breve, transcript per finalità, cancellazione automatica.
- [ ] Policy di consenso/informativa scritta e comunicata ai partecipanti.
- [ ] Accesso alle cartelle ristretto; disco cifrato dove serve.
- [ ] Procedura di cancellazione su richiesta testata.

## Il verdetto

La **trascrizione audio offline su Windows** non è un ripiego per risparmiare qualche euro: è il modo per non spedire le riunioni riservate della tua azienda a un fornitore che non controlli. Sull'italiano, faster-whisper con `large-v3` è competitivo con il cloud — e la differenza di qualità, misurata sul *tuo* audio con un WER onesto, è di solito piccola. La differenza sulla riservatezza, invece, è totale: i tuoi dati restano tuoi, la policy la applichi tu, il diritto alla cancellazione lo garantisci tu.

Sui costi, sii onesto con te stesso: a 20 ore al mese il cloud costa quanto la GPU ammortizzata, quindi il vero motivo per andare offline non è il prezzo ma il controllo — e il prezzo diventa un argomento a favore solo quando il volume sale o quando paghi un SaaS a seggiola. Scegli il modello giusto per la lingua (Whisper per l'italiano, Parakeet/NeMo per l'inglese), tratta la diarizzazione come un aiuto e non un miracolo, e — soprattutto — non confondere mai il riassunto dell'AI con il verbale. Il transcript è la fonte di verità; il riassunto è un post-it.

Fatto così, hai un sistema di **ASR self-hosted** che ti fa risparmiare ore, tiene i segreti dentro casa, e regge un controllo GDPR senza sudare. Fatto male — cloud per tutto, riassunto AI come atto, audio conservati per sempre — è una comodità che un giorno ti presenta il conto. La differenza non è il modello. È dove tieni i dati e come tratti ciò che l'AI ti restituisce.

Se vuoi montare una trascrizione offline sul tuo hardware, scegliere il modello giusto per l'italiano e mettere in piedi la pipeline con retention e policy a norma, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Ingegneria e privacy, non slide.

## FAQ

### La qualità offline sull'italiano è davvero paragonabile al cloud?
Sì, se usi il modello giusto: faster-whisper con `large-v3` è competitivo con la Whisper API sull'italiano, perché è lo stesso modello di base, eseguito in locale. La differenza pratica su audio normale è piccola. Il modo per esserne certi è misurare il WER sul tuo audio reale, con un riferimento umano, invece di fidarti dei benchmark di chiunque.

### Perché non usare NVIDIA Parakeet, che dicono sia il più veloce?
Perché Parakeet è principalmente un modello inglese. È velocissimo e accurato sull'inglese, ma sull'italiano i risultati sono deludenti rispetto a Whisper `large-v3`. Se il tuo audio è italiano, usa la famiglia Whisper. Parakeet/NeMo hanno senso se lavori prevalentemente in inglese e vuoi la loro velocità su hardware NVIDIA dedicato.

### Che GPU mi serve?
Per `large-v3` in int8 basta una GPU NVIDIA consumer con 8–12 GB di VRAM, anche di fascia media o usata (poche centinaia di euro). Con 12 GB hai margine per la diarizzazione. Se non hai GPU, Whisper.cpp gira su CPU, ma è lento: accettabile per pochi file, faticoso su volumi seri.

### Quanto costa davvero rispetto al cloud?
A 20 ore al mese, il cloud costa ~7–8 € e l'offline costa la GPU ammortizzata (~6–11 €/mese su 3 anni) più centesimi di elettricità: si equivalgono. L'offline vince nettamente in euro solo a volumi alti o quando paghi un SaaS per riunioni a costo per utente. A qualsiasi volume, l'offline vince sulla riservatezza. Se i dati non sono sensibili e il volume è basso, il cloud è legittimo.

### Funziona su Windows o mi serve Linux?
faster-whisper e Whisper.cpp girano nativamente su Windows: sono la scelta pragmatica. Serve configurare CUDA/cuDNN e avere ffmpeg nel PATH. NeMo (Parakeet/Canary) è invece Linux-first e scomodo su Windows nativo: se ti serve, usalo via WSL2 o Docker. Per l'italiano su Windows, faster-whisper è la strada giusta.

### La diarizzazione funziona bene sulle riunioni italiane?
Funziona bene su audio pulito con microfoni decenti e speaker che non si sovrappongono troppo. Sul parlato accavallato — tipico delle riunioni vivaci — fatica, come tutti i sistemi, cloud inclusi. Migliora molto la qualità dell'acquisizione (microfoni vicini) e passa il numero di speaker atteso quando lo conosci. Aspettati di correggere a mano gli audio difficili.

### Posso fidarmi del riassunto generato dall'AI?
Come promemoria sì, come verbale no. Il riassunto LLM comprime, quindi perde informazione, e può allucinare decisioni o numeri mai detti. La fonte di verità è sempre il transcript verificato; il verbale ufficiale lo redige un umano da lì. Marca sempre il riassunto come "generato automaticamente, non verificato". Su un CdA, una delibera inventata dal riassunto è un problema legale.

### Cosa devo fare per essere a posto con il GDPR?
Non è un parere legale, ma i principi: informa/ottieni consenso per la registrazione, dichiara la finalità, minimizza (conserva solo ciò che serve), definisci una retention (audio a vita breve, transcript per finalità), garantisci l'accesso ristretto e la cancellazione su richiesta. Il self-hosting semplifica tutto questo, perché applichi la policy sui tuoi dischi senza dipendere dalle garanzie di un fornitore esterno.

### Quanto è veloce trascrivere un'ora di audio offline?
Dipende da GPU e modello, ma come ordine di grandezza `large-v3` in int8 su una GPU consumer trascrive più veloce del tempo reale (un'ora di audio in una frazione d'ora), con il VAD attivo che salta i silenzi. Su CPU con Whisper.cpp è molto più lento, spesso più lungo del tempo reale. Per 20 ore di audio al mese, la GPU se ne libera in poche ore complessive.

### Come gestisco i formati audio diversi (m4a, mp4, telefono)?
Con ffmpeg, che converte qualsiasi formato nel wav 16 kHz mono che i modelli preferiscono. È la dipendenza che tutti dimenticano su Windows: installala e mettila nel PATH. La pipeline dovrebbe convertire automaticamente in ingresso, così accetti qualsiasi sorgente (registratore, telefono, sistema di conferenza) senza pensarci.
