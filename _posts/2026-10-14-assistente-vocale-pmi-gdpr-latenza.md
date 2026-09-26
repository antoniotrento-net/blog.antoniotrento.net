---
lang: it
permalink: /it/blog/assistente-vocale-pmi-gdpr-latenza/
title: "Assistente vocale in PMI: latenza, barge-in e GDPR (perché Vapi/Retell non sono \"un centralino più furbo\" se l'audio va in USA)"
date: 2026-10-14 07:30:00 +0200
author: "Antonio Trento"
description: "Assistente vocale per PMI fatto sul serio: budget di latenza STT→LLM→TTS, barge-in, dove transita l'audio, prenotazione come macchina a stati, fallback umano e informativa sulla chiamata. Perché un voice agent non è un centralino più furbo."
keywords: ["assistente vocale pmi gdpr latenza", "barge-in voice ai", "vapi self-hosted", "stt tts privacy", "centralino ai italiano", "voice agent prenotazioni"]
image: /assets/images/posts/assistente-vocale-pmi-gdpr-latenza.jpg
pillar: integrazioni-dati
related: [/it/blog/trascrizione-audio-offline-windows/, /it/blog/tool-calling-loop-infinito/]
---

## Il silenzio di due secondi che fa riagganciare

Un cliente chiama lo studio per spostare un appuntamento. L'assistente vocale risponde, il cliente dice "vorrei spostare la visita di giovedì", e poi… niente. Un secondo. Un secondo e mezzo. Due secondi di silenzio. Il cliente dice "pronto?", proprio mentre la voce sintetica parte con "Certo, posso aiutarla…", le due voci si sovrappongono, l'assistente non capisce, ricomincia da capo. Al terzo giro il cliente riaggancia e chiama il cellulare del titolare, che è in riunione e ora è anche irritato.

Questa scena è il motivo per cui un **assistente vocale in PMI** vive o muore su tre cose che le demo non mostrano: **latenza**, **barge-in** (la gestione dell'interruzione) e — in Italia e in Europa — **dove finisce l'audio** e cosa dici a chi chiama. Tre problemi che hanno poco a che fare con quanto è "intelligente" il modello e molto a che fare con l'ingegneria della catena e con il GDPR.

Le piattaforme ospitate come Vapi o Retell hanno reso facilissimo fare una demo: colleghi un numero, scrivi un prompt, e in un'ora hai un agente che parla. Ma un agente vocale non è "un centralino più furbo": è un sistema in tempo reale che trasporta la voce dei tuoi clienti — dato personale, a volte dato sanitario — attraverso tre o quattro servizi, spesso fuori dall'UE, e che deve reagire in meno di un secondo o il cliente se ne va. Se non sai dove passa l'audio, per quanto viene conservato e quanto millisecondi perdi a ogni anello, non hai un centralino: hai un rischio che risponde al telefono.

In questo pezzo smontiamo la catena da ingegneri: dove si perdono i millisecondi tra STT, LLM e TTS (con un budget di latenza in tabella), cosa spegnere quando l'umano interrompe, dove transita l'audio e con quali regioni e retention, perché una prenotazione va modellata come **macchina a stati** e non lasciata all'improvvisazione di un agente, il fallback umano, gli obblighi di informativa sulla chiamata, e l'MVP onesto che ha senso mettere in produzione: FAQ + prenotazioni, niente diagnosi.

È il seguito naturale del lavoro sulla voce offline che ho descritto per la [trascrizione audio offline su Windows]({{ '/it/blog/trascrizione-audio-offline-windows/' | relative_url }}): là si trascriveva un file registrato, con tutto il tempo del mondo; qui si trascrive una persona che sta aspettando una risposta. Cambia tutto.

## Catena STT → LLM → TTS: dove perdi i millisecondi

Un agente vocale è una staffetta. La voce del cliente arriva dalla rete telefonica, qualcuno deve capire quando ha finito di parlare, la voce va trascritta (STT, speech-to-text), il testo va al modello linguistico (LLM) che decide cosa rispondere e magari chiama uno strumento (il calendario), la risposta va sintetizzata in voce (TTS, text-to-speech) e rimandata indietro sulla linea. Ogni anello aggiunge ritardo, e i ritardi si sommano.

Il riferimento umano è brutale: in una conversazione tra persone, la pausa tra un turno e l'altro è tipicamente di **200–300 millisecondi**. Sopra il secondo la conversazione suona innaturale; sopra i due secondi la gente dice "pronto?" o riaggancia. Il tuo obiettivo realistico, con una catena ben fatta, è stare **sotto il secondo** tra la fine della frase del cliente e l'inizio della risposta, accettando picchi occasionali più alti quando c'è una chiamata a uno strumento.

Ecco dove finisce il tempo, anello per anello. Sono **stime di ordine di grandezza**, dipendono da hardware, rete e scelte di modello, ma ti danno la mappa:

| Anello | Cosa succede | Range tipico | Leva principale |
|--------|--------------|--------------|-----------------|
| Rete telefonica (andata) | SIP/RTP dal cliente al tuo server | 30–150 ms | trunk e server in Italia/UE |
| Endpointing (VAD) | capire che il cliente ha finito | 200–600 ms | soglia di silenzio, modello di turn-detection |
| STT finale | trascrizione dell'ultima frase | 100–400 ms | STT in streaming, modello e GPU |
| LLM (primo token) | il modello inizia a rispondere | 150–800 ms | modello piccolo, prompt corto, server vicino |
| Tool call (se c'è) | es. lettura calendario | 50–500 ms | API locale, cache, timeout |
| TTS primo audio | il primo pezzo di voce è pronto | 80–400 ms | TTS in streaming, frasi corte |
| Rete telefonica (ritorno) | audio verso il cliente | 30–150 ms | come sopra |
| **Totale percepito** | fine frase → inizio risposta | **~700–2.500 ms** | ottimizzare *tutti* gli anelli |

Tre osservazioni che cambiano il modo in cui progetti:

**1. L'endpointing è il ladro silenzioso.** Molti ottimizzano il modello e dimenticano che il sistema deve prima *decidere* che il cliente ha finito. Se aspetti 800 ms di silenzio per essere sicuro, hai già bruciato quasi tutto il budget prima di fare qualsiasi cosa. Se aspetti 150 ms, interrompi il cliente a metà frase ogni volta che prende fiato ("vorrei spostare… la visita di giovedì"). Il compromesso di solito sta tra 300 e 500 ms, meglio se affiancato da un modello di *turn detection* che guarda anche il contenuto (una frase che finisce con "e…" non è finita).

**2. Tutto deve essere in streaming.** Se aspetti la trascrizione completa, poi la risposta completa del modello, poi la sintesi completa dell'audio, sommi i tempi pieni. Con lo streaming, il TTS inizia a parlare appena il modello ha prodotto la prima frase, mentre il resto viene ancora generato. È la differenza tra 3 secondi e 900 millisecondi. Questo implica anche **frasi brevi**: una prima frase di cinque parole ("Certo, controllo subito.") esce e suona mentre il sistema lavora sul resto.

**3. La geografia conta più di quanto pensi.** Se il cliente chiama un numero italiano, l'audio passa per un server negli Stati Uniti, il modello gira in un'altra regione e il TTS in un'altra ancora, ogni salto oceanico aggiunge decine di millisecondi, e ne fai diversi per turno. Tenere trunk, STT, LLM e TTS nello stesso datacenter (o sullo stesso server) è insieme una scelta di latenza e — lo vediamo dopo — di privacy. Stesso problema, stessa soluzione.

## L'architettura di riferimento

Ecco la catena che monto quando serve un agente vocale serio per una PMI, con i confini disegnati. Il default è self-hosted in UE; le piattaforme ospitate le discutiamo tra poco.

```
  Cliente al telefono
        │ (rete telefonica)
        ▼
  ┌─────────────────────┐
  │ Trunk SIP operatore │  numero italiano, operatore IT/UE
  └──────────┬──────────┘
             ▼
  ┌──────────────────────────────────────────────────────────┐
  │ SERVER VOCE (Italia/UE, self-hosted)                      │
  │  PBX (Asterisk/FreeSWITCH) ─► orchestratore real-time      │
  │     VAD + turn detection  ─► STT streaming                 │
  │     LLM (piccolo, locale) ─► TTS streaming                 │
  │     BARGE-IN: se il cliente parla → stop TTS, stop LLM    │
  └──────┬──────────────────────────────┬─────────────────────┘
         │ tool call (solo whitelist)   │ trasferimento
         ▼                              ▼
  ┌──────────────────┐        ┌────────────────────────┐
  │ Macchina a stati │        │ Operatore umano / coda │
  │ PRENOTAZIONE     │        │ (orari, fallback)      │
  │ → API calendario │        └────────────────────────┘
  └──────────────────┘
         │
         ▼
  ┌──────────────────────────────────────────┐
  │ Log minimi: esito, durata, stato finale   │
  │ Audio NON conservato di default           │
  └──────────────────────────────────────────┘
```

**Cosa NON tocca l'agente vocale**, e va scritto nero su bianco prima di andare live:

- **Non decide nulla di clinico, legale o contrattuale.** Non dà diagnosi, non interpreta sintomi, non conferma coperture assicurative, non promette prezzi fuori listino.
- **Non scrive nel calendario senza passare dalla macchina a stati**, che valida slot, durata e conferma esplicita.
- **Non accede ai dati sanitari o storici del cliente.** Per prenotare servono nome, recapito, tipo di servizio e slot. Stop.
- **Non conserva l'audio per default.** Se serve registrare, lo fai con informativa, finalità e retention decise prima.
- **Non trattiene chi vuole un umano.** "Voglio parlare con una persona" è un'uscita sempre disponibile.

Questa delimitazione non è burocrazia: è il motivo per cui l'agente è gestibile. Un agente vocale con accesso a tutto e nessun confine è un agente che un giorno risponderà a una domanda che non doveva sentire.

## Barge-in: cosa spegnere quando l'umano parla

Il barge-in è la capacità del sistema di **accorgersi che il cliente sta parlando mentre l'agente parla**, e di cedergli la parola. Le persone lo fanno di continuo: interrompono per correggere ("no, giovedì, non martedì"), per anticipare ("sì sì, va bene"), per chiedere ("scusi, quanto costa?"). Un agente che non gestisce il barge-in continua a leggere la sua frase come un risponditore degli anni '90, e il cliente si sente ignorato.

Implementarlo bene significa coordinare **quattro spegnimenti**, nell'ordine giusto:

1. **Stop del playback TTS**, subito. L'audio che sta uscendo va interrotto entro 100–200 ms dal momento in cui il VAD rileva voce del cliente. Se aspetti la fine della frase, non è barge-in.
2. **Flush del buffer audio in uscita.** Il TTS in streaming ha già generato pezzi di audio non ancora riprodotti: vanno buttati, altrimenti riprendono a suonare dopo l'interruzione.
3. **Cancellazione della generazione LLM in corso.** Se il modello sta ancora producendo la risposta, va fermato: sta rispondendo a una situazione che non esiste più.
4. **Troncamento della memoria di conversazione.** Questo è il punto che quasi tutti sbagliano. Nella storia del dialogo, il messaggio dell'agente va **troncato a ciò che è stato effettivamente pronunciato**, non a ciò che era stato generato. Se il modello aveva generato "Ho trovato uno slot giovedì alle 10, oppure venerdì alle 15, quale preferisce?" ma il cliente ha interrotto dopo "giovedì alle 10", nella memoria deve risultare solo quella parte. Altrimenti il modello crede di aver proposto anche venerdì, e il cliente non l'ha mai sentito.

In pseudo-codice, il gestore del barge-in:

```python
class BargeIn:
    def __init__(self, tts, llm, memoria, soglia_ms=150):
        self.tts, self.llm, self.memoria = tts, llm, memoria
        self.soglia_ms = soglia_ms  # voce continua minima per considerarla interruzione

    def on_voce_cliente(self, durata_ms: int, energia: float):
        # Evita falsi positivi: colpi di tosse, rumori, "mh"
        if durata_ms < self.soglia_ms or energia < 0.3:
            return
        if not self.tts.sta_parlando():
            return
        pronunciato = self.tts.testo_gia_riprodotto()  # solo ciò che il cliente ha sentito
        self.tts.stop()               # 1. stop playback
        self.tts.svuota_buffer()      # 2. flush audio non ancora riprodotto
        self.llm.cancella_generazione()  # 3. stop generazione in corso
        self.memoria.tronca_ultimo_turno_agente(pronunciato)  # 4. memoria = realtà
        log.info("barge_in", pronunciato=len(pronunciato), durata_ms=durata_ms)
```

Due problemi pratici da mettere in conto:

- **L'eco.** Se il sistema sente la propria voce (per eco sulla linea o perché il cliente è in vivavoce), il VAD pensa che il cliente stia parlando e l'agente si interrompe da solo. Serve **cancellazione d'eco** (AEC) a monte del VAD, e una soglia minima di durata e energia per non reagire a ogni sospiro.
- **Il falso barge-in.** "Mh", "sì", "ok" detti mentre l'agente parla sono spesso *conferme*, non interruzioni. Un buon sistema distingue un backchannel ("mh-mh") da una vera presa di turno ("no, aspetti"). Se non lo fai, l'agente si ferma ogni volta che il cliente annuisce a voce, ed è quasi peggio di non avere barge-in.

## Audio in transito: vendor, regioni, retention

Ed eccoci al punto del titolo. La voce di una persona è un **dato personale**. Se la chiamata riguarda uno studio medico, un odontoiatra, un fisioterapista, la voce e il contenuto possono toccare **dati relativi alla salute**, che il GDPR tratta come categoria particolare (art. 9). Non è un dettaglio da rimandare a dopo il lancio.

Quando usi una piattaforma ospitata di voice agent, la catena reale spesso è questa: il tuo numero → il provider telefonico della piattaforma → i server della piattaforma → un provider STT → un provider LLM → un provider TTS → ritorno. Ogni freccia è un **trasferimento di dati a un responsabile o sub-responsabile del trattamento**. Le domande da fare, per ciascuno, sono sempre le stesse:

- **In che regione gira?** Stati Uniti, UE, "dipende dal piano"? Se l'audio lascia lo Spazio Economico Europeo, serve una base per il trasferimento (decisione di adeguatezza, clausole contrattuali standard) e una valutazione dei rischi.
- **Chi sono i sub-processor?** Una piattaforma che orchestra tre fornitori diversi ti sta portando in casa tre catene di sub-processor. Il DPA (Data Processing Agreement) li deve elencare.
- **Per quanto tempo conservano audio e trascrizioni?** Molte piattaforme registrano le chiamate per default "per migliorare il servizio" o per la tua dashboard. Retention di 30 giorni, 90, indefinita? Chi può ascoltarle?
- **Usano i dati per addestrare modelli?** Serve un "no" contrattuale, non una FAQ sul sito.
- **Possono garantirti la cancellazione?** Se un cliente esercita il diritto di cancellazione, devi poterlo onorare su tutta la catena.

Non sto dicendo che le piattaforme ospitate siano illegali: alcune offrono regioni europee, DPA seri, retention configurabile. Sto dicendo che **"funziona in un'ora" non è un'analisi di conformità**, e che il cliente al telefono non ha idea che la sua voce stia facendo il giro del mondo. Per uno studio professionale, la domanda da porsi è semplice: *posso spiegare a un mio paziente, in una frase, dove va la sua voce e quando viene cancellata?* Se la risposta è "non lo so", non sei pronto.

L'alternativa è tenere la catena in casa: trunk SIP di un operatore italiano, PBX open source (Asterisk o FreeSWITCH), un orchestratore real-time self-hostable (framework come Pipecat o LiveKit Agents si installano sui tuoi server), STT in streaming su GPU locale, un LLM piccolo servito localmente, TTS locale. È più lavoro, ma ha due effetti in un colpo solo: **meno latenza** (tutto nello stesso datacenter) e **nessun trasferimento extra-UE**. Una nota onesta sui modelli TTS open: verifica sempre la **licenza** del modello vocale (alcuni modelli di clonazione vocale di alta qualità hanno licenze non commerciali). Una voce bellissima con una licenza sbagliata è un problema legale che non vedi finché non arriva.

Come configurazione di massima, una catena self-hosted si descrive così:

```yaml
# voice-agent.yml — catena self-hosted, tutto in UE
telefonia:
  trunk: "operatore-sip-italiano"      # numero geografico IT
  pbx: freeswitch
  codec: g711a                          # standard sulla rete fissa europea
turn_detection:
  vad_silenzio_ms: 400                  # endpointing: compromesso tra latenza e interruzioni
  vad_voce_minima_ms: 150               # sotto questa soglia non è barge-in
  aec: true                             # cancellazione eco prima del VAD
stt:
  modello: whisper-streaming-it         # streaming, lingua fissata a 'it'
  device: cuda
llm:
  endpoint: "http://llm.interno:8000"   # servito in locale (vLLM/Ollama)
  max_tokens_risposta: 120              # risposte brevi = TTS che parte prima
  timeout_ms: 1500
tts:
  modello: voce-it-licenza-commerciale  # verifica la licenza!
  streaming: true
privacy:
  registrazione_audio: false            # default: nessuna registrazione
  conserva_trascrizione_giorni: 0       # solo esito strutturato
  log: [esito, durata, stato_finale, trasferito_a_umano]
fallback:
  orari_operatore: "lun-ven 09:00-13:00,15:00-18:00"
  fuori_orario: "prenota-richiamata"
```

## Script vs agente: la prenotazione è una macchina a stati

Qui c'è l'errore di design più costoso che vedo nei voice agent: lasciare che il modello *improvvisi* il flusso di prenotazione. Il prompt dice "sei l'assistente dello studio, aiuta i clienti a prenotare", il modello chiama il tool del calendario quando gli sembra il momento, e nella maggior parte delle chiamate funziona. Nelle altre, prenota lo slot sbagliato, dimentica di chiedere il cognome, conferma un appuntamento che il cliente non ha confermato, o prenota due volte perché il cliente ha ripetuto la richiesta.

Una prenotazione **non è una conversazione aperta**. È un processo con passaggi obbligati, dati da raccogliere e una conferma esplicita. Si modella come **macchina a stati**: il modello linguistico serve a *capire* cosa dice il cliente in ogni stato (estrarre la data da "giovedì prossimo in mattinata", capire che "sì, va bene" è una conferma), ma **il flusso lo governa il codice**, non il modello.

Il flusso di stato della prenotazione:

```
  SALUTO
    │
    ▼
  INTENTO ──(non è prenotazione)──► FAQ / TRASFERIMENTO
    │ prenotare | spostare | disdire
    ▼
  IDENTIFICAZIONE  (nome e cognome, recapito)
    │
    ▼
  SERVIZIO  (quale prestazione → durata nota)
    │
    ▼
  PREFERENZA  (giorno / fascia oraria)
    │
    ▼
  PROPOSTA SLOT  (max 2 opzioni reali dal calendario)
    │  ◄──(rifiuta)── nuova preferenza (max 3 giri, poi umano)
    ▼
  RIEPILOGO  ("Quindi: pulizia dentale, giovedì 16 alle 10, a nome Rossi. Confermo?")
    │  ◄──(correzione)── torna allo stato giusto
    ▼
  CONFERMA ESPLICITA ("sì" riconosciuto)
    │
    ▼
  SCRITTURA CALENDARIO  (idempotente, con chiave di prenotazione)
    │
    ▼
  CHIUSURA  (conferma via SMS/email, saluto)
```

E un'implementazione minima, in Python, dove il modello è usato solo per estrarre dati e riconoscere conferme:

```python
from enum import Enum, auto

class S(Enum):
    INTENTO = auto(); IDENTITA = auto(); SERVIZIO = auto()
    PREFERENZA = auto(); PROPOSTA = auto(); RIEPILOGO = auto()
    SCRITTURA = auto(); UMANO = auto(); FINE = auto()

class Prenotazione:
    MAX_GIRI_SLOT = 3

    def __init__(self, calendario, nlu):
        self.stato, self.dati, self.giri = S.INTENTO, {}, 0
        self.cal, self.nlu = calendario, nlu  # nlu = LLM usato SOLO per estrarre

    def turno(self, testo: str) -> str:
        if self.nlu.vuole_umano(testo):
            self.stato = S.UMANO
            return "La metto in contatto con la segreteria."

        if self.stato == S.INTENTO:
            self.dati["azione"] = self.nlu.intento(testo)  # prenota/sposta/disdici
            self.stato = S.IDENTITA
            return "Mi dice nome e cognome, per favore?"

        if self.stato == S.IDENTITA:
            nome = self.nlu.estrai_nome(testo)
            if not nome:
                return "Non ho capito il nome, può ripeterlo?"
            self.dati["nome"], self.stato = nome, S.SERVIZIO
            return "Per quale prestazione?"

        if self.stato == S.SERVIZIO:
            servizio = self.nlu.estrai_servizio(testo, self.cal.servizi())  # solo da listino
            if not servizio:
                return "Posso prenotare visita, pulizia o controllo. Quale le serve?"
            self.dati["servizio"], self.stato = servizio, S.PREFERENZA
            return "Ha una preferenza di giorno o di orario?"

        if self.stato in (S.PREFERENZA, S.PROPOSTA):
            pref = self.nlu.estrai_preferenza(testo)
            slots = self.cal.slot_liberi(self.dati["servizio"], pref, limite=2)
            self.giri += 1
            if not slots or self.giri > self.MAX_GIRI_SLOT:
                self.stato = S.UMANO
                return "Non trovo uno slot adatto, la passo alla segreteria."
            self.dati["opzioni"], self.stato = slots, S.RIEPILOGO
            return f"Ho {slots[0].parlato()}" + (f" oppure {slots[1].parlato()}" if len(slots) > 1 else "") + ". Quale preferisce?"

        if self.stato == S.RIEPILOGO:
            scelta = self.nlu.scegli_opzione(testo, self.dati["opzioni"])
            if scelta is None:
                self.stato = S.PROPOSTA
                return "Nessun problema, mi dica un altro giorno o orario."
            self.dati["slot"] = scelta
            self.stato = S.SCRITTURA
            return f"Riepilogo: {self.dati['servizio']}, {scelta.parlato()}, a nome {self.dati['nome']}. Confermo?"

        if self.stato == S.SCRITTURA:
            if not self.nlu.e_conferma(testo):
                self.stato = S.PROPOSTA
                return "Va bene, cambiamo. Che giorno preferisce?"
            chiave = f"{self.dati['nome']}|{self.dati['slot'].id}"   # idempotenza
            self.cal.prenota(self.dati["slot"], self.dati, chiave_idempotenza=chiave)
            self.stato = S.FINE
            return "Fatto, riceverà una conferma per SMS. Arrivederci."
```

Perché questa struttura vince sull'agente libero:

- **Nessuna scrittura senza conferma esplicita.** Il calendario si tocca in un solo stato, dopo il riepilogo e un "sì" riconosciuto.
- **Il modello non inventa servizi o slot.** Estrae da una lista chiusa (il listino) e propone solo slot che il calendario ha restituito davvero.
- **Idempotenza.** Se la chiamata cade e il cliente richiama, o ripete "confermo" due volte, la chiave di prenotazione impedisce il doppio appuntamento. È lo stesso principio che applico a ogni tool con effetti collaterali.
- **Limiti espliciti.** Tre giri di proposte e poi umano: niente loop infiniti di "e venerdì? e sabato?". Il tema dei loop negli agenti lo tratto in dettaglio nel pezzo sugli [agenti che girano in loop sulle tool call]({{ '/it/blog/tool-calling-loop-infinito/' | relative_url }}), e al telefono è ancora più grave perché il cliente è lì, in linea, ad aspettare.
- **È testabile.** Puoi scrivere test per ogni transizione. Un prompt libero lo puoi solo "provare e sperare".

Se lo studio usa un calendario con più operatori, sale e risorse, la complessità vera sta nel motore di disponibilità, non nella voce: ne ho parlato nel pezzo sul [calendario professionale multi-operatore]({{ '/it/blog/calendario-professionale-multi-operatore/' | relative_url }}). L'agente vocale è solo un'altra interfaccia su quel motore — e non deve mai reinventarlo.

## Percorso di implementazione, a step

1. **Definisci il perimetro in una pagina**: cosa l'agente fa (FAQ da un elenco chiuso, prenotazioni, spostamenti, disdette), cosa non fa (tutto il resto), quando passa all'umano.
2. **Scegli dove gira l'audio** prima di scegliere la tecnologia: self-hosted in UE, oppure piattaforma con regione UE, DPA firmato, retention configurata e no-training contrattuale.
3. **Metti in piedi la telefonia**: trunk SIP di un operatore italiano, PBX, numero dedicato. Testa la qualità audio reale (codec, rumore, cellulari).
4. **Misura il budget di latenza a vuoto**: un "eco bot" che ripete quello che dici, per misurare rete + VAD + STT + TTS senza LLM. Se sei già a 1,5 secondi, il modello non ti salverà.
5. **Aggiungi l'LLM con risposte corte** e streaming verso il TTS. Misura il tempo al primo audio, non il tempo totale.
6. **Implementa il barge-in** con i quattro spegnimenti e la cancellazione d'eco. Testalo con persone vere che interrompono, non con script.
7. **Codifica la prenotazione come macchina a stati**, con il modello usato solo per estrarre e riconoscere conferme. Test automatici per ogni transizione.
8. **Configura il fallback umano**: trasferimento in orario, richiamata fuori orario, uscita "voglio una persona" sempre attiva.
9. **Scrivi l'informativa** della chiamata e il messaggio iniziale (vedi sotto), con il consulente privacy.
10. **Pilota con una sola linea e un solo servizio** per due settimane, ascoltando gli esiti (non le registrazioni, se non le fai) e misurando i riagganci.

## Fallimenti tipici e come li riconosci dai log

Un agente vocale fallisce in modi specifici, e ogni modo lascia un'impronta riconoscibile nei log — a patto di loggare le cose giuste (tempi per anello, stato della macchina, eventi di barge-in, esito).

- **Riaggancio entro 10 secondi dall'inizio.** Nei log: chiamate con durata < 10 s e stato finale `SALUTO` o `INTENTO`. Causa tipica: messaggio iniziale troppo lungo o latenza sul primo turno. Il cliente non ha pazienza per un'introduzione di 20 secondi.
- **"Pronto?" ricorrenti.** Nelle trascrizioni compaiono "pronto", "c'è?", "mi sente?". È il segno che il tempo al primo audio supera stabilmente 1,5–2 secondi. Guarda il p95 della latenza fine-frase → primo-audio.
- **Barge-in a raffica senza voce reale del cliente.** Molti eventi `barge_in` con testo trascritto vuoto o rumore: l'eco o il rumore di fondo fanno scattare il VAD. Serve AEC e soglia di durata/energia più alta.
- **Agente che si interrompe da solo a metà frase in vivavoce.** Stesso problema di eco, concentrato sulle chiamate da auto o vivavoce.
- **Loop sullo stato PROPOSTA.** Contatore giri che arriva al massimo spesso: il calendario ha pochi slot o il modello non capisce le preferenze ("dopo pranzo", "verso fine mese"). Guarda quali frasi precedono il fallimento.
- **Doppie prenotazioni.** Due scritture con la stessa persona e slot vicini: manca l'idempotenza o la chiave è mal costruita. Non deve succedere mai; se succede, è un bug di codice, non di modello.
- **Trasferimenti all'umano fuori orario.** Il cliente viene "passato" a un interno che non risponde. Il fallback non rispetta il calendario operatore: deve proporre la richiamata.
- **Nomi storpiati.** L'STT trascrive "Esposito" come "è posito". Nei log: stato `IDENTITA` ripetuto più volte. Soluzione: spelling assistito ("può compitarlo?") e conferma nel riepilogo, non ostinazione.

## Obblighi di informativa sulla chiamata

Prima di tutto, una premessa onesta: **non sono un avvocato, e questo non è un parere legale.** Le regole esatte dipendono dal tuo settore, dal tipo di dati trattati e da come configuri il sistema; per uno studio sanitario, in particolare, il confronto con il DPO o un consulente privacy non è opzionale. Detto questo, i principi operativi che applico sono chiari.

**1. Chi chiama deve sapere che parla con una macchina.** Oltre al buon senso, va nella direzione degli obblighi di trasparenza previsti dall'AI Act per i sistemi che interagiscono con le persone. La prima frase dell'agente lo dice, senza giri di parole.

**2. Informativa sul trattamento (art. 13 GDPR).** Chi è il titolare, per quali finalità tratti i dati della chiamata, su quale base giuridica, chi sono i responsabili (inclusa la piattaforma, se usata), se ci sono trasferimenti extra-UE, per quanto conservi, quali diritti ha l'interessato. Al telefono non la leggi tutta: dai l'essenziale e rimandi all'informativa completa (sito, SMS).

**3. Se registri, dillo prima.** La registrazione della chiamata è un trattamento ulteriore, con una sua finalità e una sua retention. Se non ti serve, non registrare: è la scelta più semplice da difendere.

**4. Dati particolari: minimizza.** L'agente non deve chiedere sintomi o motivi clinici. Per prenotare "una visita" basta il tipo di prestazione. Se il cliente inizia a raccontare, l'agente riporta gentilmente la conversazione sulla prenotazione.

Un messaggio iniziale tipo, da adattare con il consulente:

> "Buongiorno, studio Rossi. Sono l'assistente virtuale e posso aiutarla a prenotare, spostare o disdire un appuntamento. La chiamata non viene registrata; l'informativa privacy è sul nostro sito. Se preferisce parlare con la segreteria, lo dica in qualsiasi momento."

Sono dodici secondi circa. Di più, e il cliente ha già riagganciato.

### Checklist informativa

- [ ] L'agente dichiara di essere un **assistente virtuale** nella prima frase.
- [ ] Il messaggio indica il **titolare** (nome dello studio/azienda).
- [ ] È chiaro **se la chiamata è registrata** (default consigliato: no).
- [ ] C'è un rimando all'**informativa completa** (sito, o SMS di conferma).
- [ ] L'**uscita verso un umano** è annunciata e sempre disponibile.
- [ ] Il **DPA** con ogni fornitore (telefonia, piattaforma, STT/LLM/TTS se esterni) è firmato.
- [ ] Sono documentati **regioni di trattamento** e **eventuali trasferimenti extra-UE**.
- [ ] La **retention** di audio, trascrizioni ed esiti è definita e configurata davvero.
- [ ] Il fornitore esclude per contratto l'**uso dei dati per addestramento**.
- [ ] L'agente **non raccoglie dati sanitari** oltre al tipo di prestazione.
- [ ] Il registro dei trattamenti è aggiornato con il nuovo trattamento.

## Fallback umano e orari

Un agente vocale senza uscita verso una persona è una trappola. Il fallback non è un'ammissione di sconfitta: è una funzione di prodotto, e va progettata con la stessa cura del resto.

- **"Voglio parlare con una persona" è un comando globale.** In qualsiasi stato, riconosciuto e onorato subito, senza "prima mi dica il suo nome". Niente è più irritante di un bot che ti trattiene.
- **Il trasferimento dipende dall'orario.** In orario di segreteria: trasferimento alla linea o alla coda. Fuori orario: proposta di richiamata ("Posso farla richiamare domani mattina, a questo numero?") con creazione di un task per la segreteria.
- **Trasferimento con contesto.** Quando passi la chiamata, passa anche lo stato: "Rossi, voleva spostare la pulizia di giovedì, non trovava slot il pomeriggio". La segreteria non deve ricominciare da zero.
- **Soglie automatiche.** Tre incomprensioni consecutive, tre giri di slot senza successo, un'emozione forte riconosciuta (rabbia, urgenza): si passa all'umano senza aspettare che lo chieda.
- **Urgenze.** Se lo studio è sanitario e il cliente descrive un'urgenza, l'agente non valuta nulla: dà l'indicazione predefinita (il numero dello studio per le urgenze, o i servizi di emergenza) e chiude o trasferisce. Questa frase la scrive il titolare, non il modello.

## Costi: ordini di grandezza

Stime indicative, da verificare sui listini e sui volumi reali. Prendiamo una PMI con **1.000 minuti di chiamate al mese** (circa 500 chiamate da 2 minuti).

**Piattaforma ospitata.** Il costo tipico si esprime in centesimi al minuto, sommando piattaforma, telefonia, STT, LLM e TTS: nell'ordine di **0,05–0,20 € al minuto** tutto incluso, cioè **50–200 € al mese** per 1.000 minuti. Veloce da avviare, costi che crescono linearmente con il traffico, e i temi di regione e retention da gestire contrattualmente.

**Self-hosted in UE.** Costo fisso più che variabile:

- **Server con GPU** per STT e LLM piccolo (una GPU consumer o datacenter di fascia media, 16–24 GB di VRAM, sufficiente per qualche chiamata concorrente): a noleggio in un datacenter europeo **150–600 € al mese** a seconda della GPU; in casa, l'acquisto una tantum più l'energia. Una GPU da ~300 W accesa h24 consuma circa **220 kWh al mese**, cioè **50–70 € di energia** a tariffe business italiane indicative.
- **Trunk SIP e numero**: canone più traffico, tipicamente **pochi euro al mese più qualche centesimo al minuto** per le chiamate in ingresso da rete mobile, a seconda dell'operatore.
- **Setup**: il costo vero. Telefonia, orchestrazione, barge-in, macchina a stati, test con persone reali: **settimane di lavoro**, non giorni.

La regola pratica: sotto qualche migliaio di minuti al mese, il self-hosted **non conviene per il costo del minuto** — conviene per il **controllo del dato** e per la latenza. Se i tuoi clienti sono pazienti, se registri, se l'audio tocca la salute, il controllo del dato vale più del risparmio. Se sono richieste di orari di apertura, una piattaforma con regione UE e contratto serio può bastare.

## MVP onesto: FAQ + prenotazioni, niente diagnosi

Il primo agente vocale da mettere in produzione in una PMI è piccolo, e va bene così. Il perimetro che consiglio:

- **FAQ chiuse**: orari, indirizzo, parcheggio, documenti da portare, costi da listino pubblico. Risposte scritte dal titolare, recuperate da un elenco, non generate liberamente.
- **Prenotazione, spostamento, disdetta** tramite la macchina a stati.
- **Trasferimento e richiamata** come uscita sempre disponibile.

E cosa **non** mettere nell'MVP, anche se la demo lo fa sembrare facile:

- **Niente diagnosi, triage o consigli clinici.** Mai. Non è una questione di accuratezza del modello: è una questione di responsabilità e di categoria di rischio.
- **Niente preventivi personalizzati** o sconti: il modello non negozia per te.
- **Niente accesso allo storico del cliente** ("com'è andata l'ultima visita?"): dati in più, rischio in più, valore marginale.
- **Niente chiamate in uscita** automatiche nella prima fase: telemarketing, registro delle opposizioni e aspettative del cliente sono un altro progetto.

Un MVP così risolve il problema vero della PMI — le chiamate perse mentre la segreteria è occupata e le prenotazioni fuori orario — senza esporti a rischi che non sai ancora misurare.

## Quando NON farlo

- **Se ricevi poche chiamate al giorno**: la segreteria le gestisce, e un buon sistema di prenotazione online con SMS di promemoria risolve più no-show di qualsiasi agente vocale.
- **Se le chiamate sono prevalentemente complesse** (reclami, trattative, situazioni emotive): un agente vocale peggiora l'esperienza e il cliente se ne ricorda.
- **Se non puoi garantire dove va l'audio** e tratti dati sanitari: meglio non partire che partire con un trasferimento dati che non sai spiegare.
- **Se il calendario è gestito "a memoria" o su carta**: l'agente non ha niente su cui scrivere. Prima si digitalizza la disponibilità, poi si parla con la voce.
- **Se nessuno ascolterà gli esiti**: un agente vocale senza qualcuno che guardi riagganci, fallimenti e trasferimenti ogni settimana degrada in silenzio.
- **Se l'obiettivo è "togliere la segreteria"**: l'agente assorbe il ripetitivo, non sostituisce la persona che gestisce le eccezioni. Chi lo vende così, vende un problema.

## Checklist operativa prima di andare live

- [ ] Perimetro scritto: cosa fa, cosa non fa, quando passa all'umano.
- [ ] Mappa dei flussi audio: ogni fornitore, regione, retention, sub-processor.
- [ ] DPA firmati e no-training contrattuale con ogni fornitore esterno.
- [ ] Latenza misurata: p50 e p95 fine-frase → primo audio, obiettivo p95 < 1,5 s.
- [ ] Endpointing tarato su chiamate reali (non su voce registrata in studio).
- [ ] Barge-in con i quattro spegnimenti e troncamento della memoria.
- [ ] Cancellazione d'eco attiva, testata con vivavoce e auto.
- [ ] Prenotazione come macchina a stati, con test automatici per ogni transizione.
- [ ] Scrittura calendario idempotente, solo dopo conferma esplicita.
- [ ] Limite di giri sulle proposte e uscita verso l'umano.
- [ ] Fallback legato agli orari reali della segreteria, con richiamata fuori orario.
- [ ] Messaggio iniziale con dichiarazione AI, titolare, registrazione sì/no, rimando all'informativa.
- [ ] Log minimi: tempi per anello, stato finale, barge-in, trasferimenti. Audio non conservato di default.
- [ ] Pilota su una linea e un servizio, con revisione settimanale degli esiti.

## Il verdetto

Un **assistente vocale in PMI** funziona quando smetti di trattarlo come un chatbot che parla e inizi a trattarlo per quello che è: un sistema in tempo reale che trasporta dati personali. La differenza tra un agente che i clienti usano e uno da cui riagganciano non sta nel modello più potente: sta nei 400 millisecondi di endpointing tarati bene, nel TTS in streaming, nel barge-in che spegne le quattro cose giuste, nella prenotazione governata da una macchina a stati invece che dall'improvvisazione.

E sta nella domanda che le demo non fanno mai: dove va la voce del mio cliente? Vapi, Retell e simili sono ottimi per provare un'idea in un pomeriggio. Ma "un centralino più furbo" che manda l'audio di un paziente attraverso tre fornitori in un altro continente, con retention che non conosci, non è un centralino: è un trattamento di dati che dovrai spiegare. Tenere la catena in UE — meglio ancora sui tuoi server — risolve insieme privacy e latenza, perché sono lo stesso problema visto da due lati.

Parti piccolo: FAQ chiuse e prenotazioni, fallback umano sempre aperto, niente diagnosi. Misura riagganci e latenze ogni settimana. Allarga solo quando i numeri ti dicono che la base regge.

Se stai valutando un agente vocale per il tuo studio o la tua azienda e vuoi capire se ha senso — e dove far passare l'audio — puoi leggere di più su di me nella [biografia]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Ne parliamo con i numeri delle tue chiamate davanti, non con una demo.

## FAQ

### Quanta latenza è accettabile per un assistente vocale al telefono?
Come riferimento, tra persone la pausa di turno è di 200–300 millisecondi. Un agente vocale ben fatto sta sotto il secondo tra la fine della frase del cliente e l'inizio della risposta, con un p95 sotto 1,5 secondi. Oltre i due secondi di silenzio le persone iniziano a dire "pronto?" o riagganciano. Misura il tempo al *primo audio*, non il tempo per generare tutta la risposta: con lo streaming il cliente sente la prima frase mentre il resto viene ancora prodotto.

### Cos'è il barge-in e perché è così importante?
È la capacità dell'agente di fermarsi quando il cliente parla sopra di lui. Le persone interrompono di continuo per correggere o anticipare, e un agente che continua a parlare sembra sordo. Farlo bene significa fermare il playback, svuotare il buffer audio, cancellare la generazione in corso e — il passaggio più trascurato — troncare la memoria della conversazione a ciò che il cliente ha effettivamente sentito. Serve anche la cancellazione d'eco, altrimenti l'agente si interrompe da solo sentendo la propria voce.

### Posso usare Vapi o Retell per uno studio medico in Italia?
Dipende da come li configuri e da cosa contrattualizzi. La domanda non è "la piattaforma è legale?" ma: in che regione transita e viene elaborato l'audio, chi sono i sub-processor, per quanto vengono conservate registrazioni e trascrizioni, se i dati vengono usati per addestrare modelli, e se hai un DPA che copre tutto. Con dati che possono toccare la salute serve una valutazione seria con il DPO. Se non riesci a spiegare a un paziente dove va la sua voce, non sei pronto.

### Serve registrare le chiamate?
Non per far funzionare l'agente. La registrazione è un trattamento ulteriore, con finalità, retention e informativa propri. Per la maggior parte dei casi basta un log strutturato dell'esito (servizio prenotato, slot, trasferimento sì/no, durata), senza audio né trascrizione integrale. Se decidi di registrare, dillo all'inizio della chiamata e definisci prima per quanto tempo conservi e chi può ascoltare.

### Perché modellare la prenotazione come macchina a stati invece di lasciar fare all'agente?
Perché una prenotazione è un processo con passaggi obbligati: identità, servizio, slot reale, riepilogo, conferma esplicita, scrittura idempotente. Un agente libero funziona "quasi sempre", e le eccezioni sono appuntamenti sbagliati, doppie prenotazioni o conferme mai date. Con la macchina a stati il modello serve a capire le frasi del cliente, ma il flusso e la scrittura nel calendario li governa il codice, testabile transizione per transizione.

### Quale STT e TTS usare in italiano, in self-hosted?
Per lo STT, modelli della famiglia Whisper in versione streaming con lingua fissata sull'italiano danno buoni risultati su GPU. Per il TTS esistono modelli open con voci italiane decenti, ma verifica sempre la licenza: alcuni modelli di clonazione vocale di alta qualità hanno licenze non commerciali. Qualunque scelta, misurala su chiamate reali — rete mobile, rumore, accenti regionali — non su audio registrato in studio.

### Cosa succede se il cliente chiede di parlare con una persona?
Deve succedere subito, in qualsiasi punto della conversazione. È un comando globale, non un'opzione da menu. In orario, trasferimento alla segreteria passando il contesto già raccolto; fuori orario, proposta di richiamata con un task creato per lo staff. Oltre alla richiesta esplicita, conviene passare all'umano automaticamente dopo tre incomprensioni o tre proposte di slot rifiutate.

### Quanto costa un assistente vocale per una PMI?
Con una piattaforma ospitata, indicativamente 0,05–0,20 € al minuto tutto incluso: per 1.000 minuti al mese, 50–200 €. In self-hosted il costo è più fisso: un server con GPU in un datacenter europeo nell'ordine di 150–600 € al mese, più telefonia, più il lavoro di setup, che è la voce più pesante. Per volumi bassi il self-hosted non conviene sul costo al minuto, ma conviene sul controllo del dato e sulla latenza.

### Che cosa deve dire l'agente all'inizio della chiamata?
Che è un assistente virtuale, per conto di chi risponde, cosa può fare, se la chiamata è registrata, dove trovare l'informativa completa e che si può chiedere una persona in qualsiasi momento. Il tutto in una decina di secondi. Il testo esatto va definito con il consulente privacy in base al tuo settore: queste sono indicazioni operative, non un parere legale.

### Un assistente vocale può sostituire la segreteria?
No, e chi lo promette crea un problema. L'agente assorbe le chiamate ripetitive — orari, prenotazioni, spostamenti, disdette — soprattutto nei momenti in cui la segreteria è occupata o chiusa. Le eccezioni, i reclami, le situazioni delicate restano umane. Il risultato buono è una segreteria che smette di rispondere dieci volte al giorno "a che ora aprite?" e si dedica ai casi che contano.
