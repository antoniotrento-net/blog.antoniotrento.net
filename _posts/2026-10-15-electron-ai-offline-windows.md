---
lang: it
permalink: /it/blog/electron-ai-offline-windows/
title: "App desktop AI offline su Windows (Electron): come distribuire un modello locale senza che l'antivirus e il path da 260 caratteri ti distruggano il lancio"
date: 2026-10-15 07:30:00 +0200
author: "Antonio Trento"
description: "Distribuire un'app desktop AI offline su Windows con Electron: architettura a processi, modello scaricato o incluso, MAX_PATH e utenti non admin, GPU con fallback CPU, firma e SmartScreen, aggiornamenti, zero telemetria e crash report senza dati dell'utente."
keywords: ["electron ai offline windows", "whisper.cpp windows", "installer electron", "path MAX_PATH", "runtime llm desktop", "app desktop ai offline"]
image: /assets/images/posts/electron-ai-offline-windows.jpg
pillar: integrazioni-dati
related: [/it/blog/trascrizione-audio-offline-windows/, /it/blog/vllm-vs-ollama-produzione/]
---

## "Apri questo notebook" non è un prodotto

Il prototipo funziona. Sul tuo portatile, con Python installato, CUDA configurata, la cartella del progetto in `C:\dev\x`, il modello già scaricato e tu seduto davanti. Poi lo mandi al primo cliente: un ufficio di otto persone, PC Windows gestiti dall'IT esterno, utenti senza diritti di amministratore, un antivirus aziendale, nomi utente come `Maria Grazia D'Alessandro` e la cartella Documenti sincronizzata su OneDrive. Il primo messaggio che ricevi è uno screenshot di Windows Defender. Il secondo è "si è installato ma non parte". Il terzo non arriva, perché hanno disinstallato.

Questo pezzo parla di un mestiere che il mondo delle demo AI sottovaluta sistematicamente: **distribuire un'app desktop AI offline su Windows** — con **Electron** come guscio e un modello locale (trascrizione con whisper.cpp, un LLM con llama.cpp, un OCR) che gira sul PC dell'utente, senza mandare niente in cloud. È il modo più sovrano che esista di usare l'AI: il dato non esce dalla macchina. Ed è anche il modo più ostile da spedire, perché Windows sul campo non è la tua macchina di sviluppo.

L'angolo è dichiarato: **shipping, non demo Colab.** Vediamo cosa mettere nel processo Electron e cosa in un processo nativo separato, se il modello va incluso nell'installer o scaricato al primo avvio, le trappole di Windows che nessuno ti dice (il limite di 260 caratteri, gli spazi e gli accenti nei percorsi, gli utenti non amministratori, OneDrive), GPU NVIDIA con fallback CPU, firma del codice e SmartScreen, la policy di aggiornamento, e le due regole di privacy che separano un'app offline seria da una che finge di esserlo: **niente telemetria di default** e **crash report che non spediscono i file dell'utente**.

Se vieni dal pezzo sulla {{ '/it/blog/trascrizione-audio-offline-windows/' | relative_url }}, questo è il passo successivo: là facevamo girare faster-whisper su un PC Windows configurato da noi; qui lo mettiamo in mano a qualcuno che non sa cosa sia CUDA e non deve saperlo.

## Perché il prototipo non sopravvive al primo cliente

Un prototipo AI da riga di comando dà per scontate una serie di cose che sulle macchine degli utenti sono false. Vale la pena elencarle, perché ognuna diventa un requisito di prodotto:

- **"Python è installato."** Non lo è, e se lo è, è la versione sbagliata, o c'è Anaconda che si prende il PATH. Il prodotto deve portarsi dietro il suo runtime, oppure non usare Python affatto a runtime.
- **"L'utente è amministratore."** Negli uffici gestiti quasi mai. Niente scrittura in `Program Files`, niente servizi Windows, niente driver, niente modifiche al registro di sistema.
- **"La GPU c'è ed è NVIDIA con i driver giusti."** Sul campo trovi grafiche integrate Intel, portatili AMD, NVIDIA con driver di tre anni fa, e desktop da ufficio senza GPU dedicata.
- **"Il percorso è corto e in ASCII."** `C:\Users\Maria Grazia D'Alessandro\OneDrive - Studio Associato\Documenti\Registrazioni riunioni 2026\` è un percorso perfettamente normale per un utente e un incubo per metà delle librerie C.
- **"La rete c'è."** L'app è offline per scelta, ma il primo download del modello avviene dietro un proxy aziendale che ispeziona il TLS, o in uno studio con una linea da 20 Mbit condivisa.
- **"L'antivirus è d'accordo."** Un eseguibile nuovo, non firmato, che scarica altri eseguibili e carica DLL da una cartella utente è esattamente il profilo di comportamento che gli antivirus sono pagati per bloccare.

Ognuno di questi punti è un ticket di supporto che arriverà. Il lavoro di shipping è prevederli, e costruire l'app in modo che sopravviva a tutti.

## L'architettura dei processi: cosa va in Electron, cosa nel nativo

L'errore più comune è far girare l'inferenza dentro Electron: caricare un modulo nativo Node nel processo principale, o peggio usare una libreria di inferenza in JavaScript nel renderer. Funziona in demo, poi al primo file lungo l'interfaccia si congela, la memoria esplode, e se il modulo nativo va in crash si porta giù tutta l'app.

L'architettura che regge è a **tre livelli di processo**, ciascuno con un compito e un confine:

```
┌────────────────────────────────────────────────────────────┐
│  RENDERER (Chromium)                                        │
│  - UI: React/Vue/HTML                                        │
│  - sandbox: true, contextIsolation: true, nodeIntegration:no │
│  - NESSUN accesso a filesystem, rete o modelli               │
│  - parla solo con le API esposte dal preload (contextBridge) │
└──────────────────────┬─────────────────────────────────────┘
                       │ IPC (invoke/handle), messaggi validati
┌──────────────────────▼─────────────────────────────────────┐
│  MAIN (Node.js)                                              │
│  - finestre, menu, dialog file, permessi (microfono)        │
│  - avvia/monitora/riavvia il sidecar                        │
│  - download e verifica modelli, aggiornamenti, log locali   │
│  - NON fa inferenza                                          │
└──────────────────────┬─────────────────────────────────────┘
                       │ HTTP su 127.0.0.1:porta_casuale + token
┌──────────────────────▼─────────────────────────────────────┐
│  SIDECAR NATIVO (whisper.cpp / llama.cpp server, .exe)      │
│  - inferenza su GPU (CUDA/Vulkan) o CPU                      │
│  - legge SOLO i file che main gli passa                      │
│  - se va in crash: main lo riavvia, la UI resta viva         │
└────────────────────────────────────────────────────────────┘
```

Perché questa divisione:

- **Il renderer è la parte più esposta** (esegue HTML e JavaScript, magari mostra contenuti dei documenti dell'utente). Con `sandbox`, `contextIsolation` e senza `nodeIntegration`, anche un bug nell'interfaccia non può leggere file o lanciare processi. Espone solo un'API minima dal preload: "trascrivi questo file", "annulla", "stato".
- **Il main orchestra, non calcola.** Tiene la UI reattiva perché non fa mai lavoro pesante. Gestisce il ciclo di vita del sidecar: lo avvia, controlla che risponda, lo riavvia se cade.
- **Il sidecar è sostituibile e isolato.** È un eseguibile nativo (le build di whisper.cpp e llama.cpp includono un server HTTP), che puoi aggiornare, cambiare backend GPU, o far crashare senza portare giù l'app. È anche la parte più facile da testare fuori da Electron.

**Cosa NON tocca nessuno dei processi:** la rete esterna durante l'uso normale. Il sidecar ascolta solo su `127.0.0.1` — mai su `0.0.0.0`, sia per sicurezza (nessun altro PC della LAN deve poter chiamare il tuo modello) sia per un motivo molto pratico: legarsi a tutte le interfacce fa comparire il prompt del **Windows Firewall**, che un utente non admin non può nemmeno accettare, e un utente admin accetterà "per sbaglio" aprendo la porta a tutta la rete.

Ecco lo scheletro del main che avvia il sidecar in modo robusto — porta casuale, token, health check, fallback GPU → CPU:

```javascript
// main/sidecar.js — avvio robusto del motore di inferenza nativo
const { spawn } = require('node:child_process');
const crypto = require('node:crypto');
const net = require('node:net');
const path = require('node:path');

function portaLibera() {
  return new Promise((ok) => {
    const s = net.createServer().listen(0, '127.0.0.1', () => {
      const { port } = s.address(); s.close(() => ok(port));
    });
  });
}

async function avviaSidecar({ binDir, modelloPath, backend }) {
  const port = await portaLibera();
  const token = crypto.randomBytes(24).toString('hex');   // solo main e sidecar lo conoscono
  const exe = path.join(binDir, backend, 'server.exe');    // es. bin/cuda, bin/vulkan, bin/cpu
  const proc = spawn(exe, [
    '--host', '127.0.0.1', '--port', String(port),         // MAI 0.0.0.0
    '--model', modelloPath, '--api-key', token,
  ], { windowsHide: true, cwd: binDir });                  // cwd corto, niente console visibile

  proc.stderr.on('data', (d) => logLocale('sidecar', d.toString()));
  const pronto = await healthCheck(`http://127.0.0.1:${port}/health`, token, 30_000);
  if (!pronto) { proc.kill(); throw new Error(`backend ${backend} non partito`); }
  return { proc, port, token, backend };
}

async function avviaConFallback(opts) {
  for (const backend of ordineBackend()) {                // es. ['cuda','vulkan','cpu']
    try { return await avviaSidecar({ ...opts, backend }); }
    catch (e) { logLocale('fallback', `${backend}: ${e.message}`); }
  }
  throw new Error('Nessun backend di inferenza disponibile');
}
```

Nota `windowsHide: true` (niente finestra nera di console che compare e spaventa l'utente) e `cwd` impostato sulla cartella dei binari (le DLL del backend vengono cercate lì, e il percorso resta corto).

## Modelli: download al primo avvio o incluso nell'installer?

È la domanda che decide l'esperienza di installazione, e non ha una risposta unica. Un modello di trascrizione "large" pesa 1,5–3 GB, un LLM piccolo quantizzato 2–5 GB. Le opzioni:

**Incluso nell'installer (bundle).**
- *Pro:* funziona davvero offline dal primo secondo; nessun proxy da attraversare; installazione ripetibile.
- *Contro:* installer enorme (e alcuni sistemi di distribuzione hanno limiti per singolo file: le release di GitHub, per esempio, accettano asset fino a 2 GB); ogni aggiornamento dell'app ridistribuisce anche il modello se non separi i pacchetti; NSIS e simili su pacchetti molto grandi diventano lenti e fragili.

**Download al primo avvio.**
- *Pro:* installer leggero (decine di MB), il modello si aggiorna indipendentemente dall'app, puoi offrire modelli diversi (piccolo/veloce, grande/preciso).
- *Contro:* il primo avvio richiede rete, e la rete aziendale è ostile: proxy, ispezione TLS, firewall che bloccano domini sconosciuti.

La soluzione che uso in pratica è un **ibrido**:

1. **Installer leggero** con app e sidecar.
2. **Download al primo avvio** del modello, con barra di avanzamento vera, **ripresa** in caso di interruzione (richieste HTTP con `Range`) e **verifica dell'hash SHA-256** prima di usarlo.
3. **Pacchetto modello offline separato** (un file `.zip` o un secondo installer) per gli ambienti senza internet o con proxy impossibili: l'IT lo copia via chiavetta o share di rete, l'app lo importa e verifica l'hash.
4. **Rispetto del proxy di sistema**: le librerie HTTP di Node non usano automaticamente il proxy di Windows; Electron invece può usare la rete di Chromium (`net` di Electron), che rispetta le impostazioni di sistema. Usala per i download.

Dove salvare il modello è una scelta meno ovvia di quanto sembri: **`%LOCALAPPDATA%\TuaApp\models`**, non `%APPDATA%` (che è la cartella *Roaming*: in molte aziende viene sincronizzata con il profilo di rete, e sincronizzare 3 GB di modello a ogni login è un modo eccellente per farsi odiare dall'IT), e **mai** in `Documenti` (spesso rediretta su OneDrive, dove i file diventano segnaposto e vengono scaricati e bloccati a caso dal client di sincronizzazione).

La verifica del modello scaricato, in main:

```javascript
// main/modelli.js — verifica integrità prima dell'uso
const fs = require('node:fs');
const crypto = require('node:crypto');

function sha256File(p) {
  return new Promise((ok, ko) => {
    const h = crypto.createHash('sha256');
    fs.createReadStream(p).on('data', (c) => h.update(c)).on('end', () => ok(h.digest('hex'))).on('error', ko);
  });
}

async function modelloPronto(manifest, cartella) {
  const p = require('node:path').join(cartella, manifest.file);
  if (!fs.existsSync(p)) return { ok: false, motivo: 'assente' };
  if (fs.statSync(p).size !== manifest.size) return { ok: false, motivo: 'incompleto' };   // ripresa download
  if (await sha256File(p) !== manifest.sha256) return { ok: false, motivo: 'corrotto' };    // riscaricare
  return { ok: true, path: p };
}
```

L'hash non è pignoleria: un download interrotto da un proxy che chiude la connessione produce un file della dimensione quasi giusta che il motore di inferenza carica e poi fa crashare in modo misterioso. Senza verifica, quel crash diventa un ticket "l'app si chiude da sola" impossibile da diagnosticare.

## Le trappole di Windows: MAX_PATH, spazi, accenti, utenti non admin

Questa è la sezione che vale da sola il pezzo, perché sono problemi che non vedi mai sulla tua macchina e che uccidono il lancio.

### Il limite dei 260 caratteri

Storicamente le API Windows limitano un percorso a **260 caratteri** (`MAX_PATH`). Windows 10 e 11 possono superarlo, ma solo se **due** condizioni sono vere: l'impostazione di sistema `LongPathsEnabled` è attiva (richiede amministratore, spesso gestita da criteri di gruppo) **e** l'applicazione dichiara nel manifest di essere "long path aware". Sul PC di un utente qualunque non puoi contare sulla prima, e molte librerie native e strumenti che porti dentro non rispettano comunque la seconda.

Dove si sfora il limite senza accorgersene:

- La cartella di installazione per utente è già lunga: `C:\Users\Maria Grazia D'Alessandro\AppData\Local\Programs\nome-app-lungo\resources\app.asar.unpacked\node_modules\...` arriva a 150 caratteri prima di cominciare.
- Le dipendenze native annidate in `node_modules` hanno percorsi profondi.
- I file dell'utente: la registrazione in `OneDrive - Nome Studio Associato\Documenti\Clienti 2026\...` è già lunga di suo, e tu magari crei accanto un file `...trascrizione.txt` o una cartella temporanea.

Contromisure concrete: tieni i binari nativi in una cartella **corta e piatta** (`resources\bin\cuda\`), non dentro `node_modules`; usa nomi di prodotto brevi per le cartelle; per i file di lavoro usa una cartella temporanea **tua e corta** (`%LOCALAPPDATA%\TuaApp\w\`) invece di lavorare accanto al file originale; e scrivi un test automatico che installa e fa girare l'app sotto un utente con nome lungo.

### Spazi, apostrofi e accenti nei percorsi

Molte librerie C/C++ aprono i file con API che usano la **codepage ANSI** del sistema, non Unicode. Risultato: un percorso con `à`, `è`, `ì` o caratteri fuori codepage (un nome utente con un carattere cirillico, un file con un'emoji nel nome) viene storpiato e il file "non esiste". Gli spazi e gli apostrofi rompono invece gli argomenti passati su riga di comando se qualcuno costruisce la stringa a mano.

Contromisure: passa sempre gli argomenti al sidecar come **array** (`spawn(exe, [args])`), mai concatenando stringhe; verifica che il motore nativo usi API "wide" (UTF-16) o accetti UTF-8 esplicitamente; e se non puoi controllarlo, **copia il file di input in una cartella temporanea con nome ASCII** prima di passarlo al motore. È brutto, costa qualche secondo, e ti evita il 90% dei ticket "file non trovato".

### Utenti non amministratori

L'installer deve funzionare **per utente, senza privilegi elevati**: installazione in `%LOCALAPPDATA%\Programs`, collegamenti nel menu Start dell'utente, niente servizi di sistema, niente scrittura in `HKEY_LOCAL_MACHINE`. Se l'installer chiede i diritti di amministratore, in un ufficio gestito si ferma lì: l'utente apre un ticket all'IT e il tuo lancio aspetta una settimana.

### OneDrive e le cartelle "note"

Con la funzione di spostamento delle cartelle note, Desktop e Documenti vivono dentro OneDrive. I file possono essere **segnaposto** (solo online): aprirli li fa scaricare, a volte lentamente, e il client di sincronizzazione può bloccarli mentre li leggi o li scrivi. Non salvare mai modelli, cache o file temporanei lì; per i file dell'utente, gestisci con grazia l'errore di file bloccato e riprova.

Riassunto in tabella:

| Trappola | Sintomo sul campo | Contromisura |
|----------|-------------------|--------------|
| MAX_PATH 260 | "file non trovato", crash in librerie native | binari in cartelle corte e piatte, temp corta, test con username lungo |
| Accenti / non-ASCII | file "inesistenti" nel motore nativo | API wide/UTF-8, oppure copia in temp con nome ASCII |
| Spazi e apostrofi | argomenti spezzati | `spawn` con array di argomenti, mai stringhe concatenate |
| Utente non admin | installer bloccato | installazione per utente in `%LOCALAPPDATA%\Programs` |
| Profilo Roaming | login lentissimi, profili enormi | modelli in `%LOCALAPPDATA%`, mai in `%APPDATA%` |
| OneDrive / cartelle note | file bloccati o segnaposto | niente cache lì, retry su file bloccati |
| Bind su 0.0.0.0 | prompt del Firewall | ascoltare solo su `127.0.0.1` |
| Binari dentro `app.asar` | l'eseguibile nativo non parte | `asarUnpack` o `extraResources` |

L'ultima riga merita una nota: Electron impacchetta il codice in un archivio `app.asar`, ma **un eseguibile o una DLL non possono essere lanciati da dentro un archivio asar**. I binari del sidecar vanno esclusi dall'archivio. Con electron-builder, per esempio:

```yaml
# electron-builder.yml — installer per utente, binari fuori da asar
appId: it.esempio.trascrittore
productName: Trascrittore        # nome corto = percorsi più corti
directories:
  output: dist
asar: true
asarUnpack:
  - "**/*.node"                  # moduli nativi Node fuori dall'archivio
extraResources:
  - from: bin/                   # sidecar: resources/bin/{cuda,vulkan,cpu}/server.exe
    to: bin
win:
  target: nsis
  signingHashAlgorithms: [sha256]
nsis:
  oneClick: false
  perMachine: false              # installazione per utente, niente admin
  allowElevation: false
  allowToChangeInstallationDirectory: false
publish:
  provider: generic
  url: https://download.esempio.it/trascrittore/   # server tuo, in UE
```

## GPU NVIDIA vs fallback su CPU

Sul campo la GPU è una variabile, non una costante. La strategia che funziona è **rilevare a runtime e degradare con grazia**, non chiedere all'utente di scegliere.

- **CUDA** dà le prestazioni migliori sulle schede NVIDIA, ma ha un prezzo: le librerie runtime di CUDA (in particolare cuBLAS) pesano **centinaia di MB**, richiedono un driver NVIDIA sufficientemente recente, e su PC senza NVIDIA sono peso morto. Includerle in ogni installer gonfia il pacchetto per tutti.
- **Vulkan** è il compromesso interessante: sia whisper.cpp sia llama.cpp hanno backend Vulkan, che funzionano su schede NVIDIA, AMD e anche su molte grafiche integrate Intel, senza le DLL enormi di CUDA. Le prestazioni sono in genere inferiori a CUDA su NVIDIA, ma superiori alla CPU.
- **CPU** è il fallback universale. Serve un build che rilevi le istruzioni disponibili (AVX2 su quasi tutto l'hardware recente; un build di base per le macchine più vecchie) e un modello più piccolo, altrimenti l'attesa diventa inaccettabile.

La sequenza che uso: all'avvio, prova il backend migliore (CUDA se c'è una NVIDIA con driver adeguato), fai un **test di inferenza minuscolo** (un secondo di silenzio, un prompt di tre token); se fallisce o va in timeout, scendi a Vulkan, poi a CPU. Salva il risultato per i prossimi avvii, e **mostralo all'utente** in modo onesto: "Accelerazione: GPU NVIDIA" oppure "Modalità CPU: la trascrizione di un'ora richiede circa 20 minuti". Aspettative chiare prima, non lamentele dopo.

Sui tempi, stime indicative per trascrivere **un'ora di audio** con un modello Whisper di taglia media-grande:

| Hardware | Tempo indicativo | Esperienza |
|----------|------------------|------------|
| GPU NVIDIA recente (CUDA) | 2–6 minuti | ottima |
| GPU tramite Vulkan (NVIDIA/AMD) | 4–12 minuti | buona |
| Grafica integrata (Vulkan) | 10–30 minuti | accettabile per batch |
| Solo CPU moderna (AVX2), modello piccolo | 10–40 minuti | usabile in background |

Sono ordini di grandezza da misurare sul tuo modello e sui PC dei clienti, ma la tabella serve a una cosa precisa: decidere **quale modello di default** proporre a seconda dell'hardware rilevato. Dare il modello grande a un portatile senza GPU è il modo più rapido per convincere un utente che "l'AI locale non funziona".

## Antivirus, firma del codice e SmartScreen

Qui si perdono più lanci che su qualsiasi problema tecnico. Il profilo della tua app, visto da un antivirus, è sospetto per costruzione: un eseguibile nuovo, con pochissima reputazione, che avvia un altro eseguibile, scarica gigabyte di dati, carica DLL da una cartella utente, apre una porta locale. Le conseguenze tipiche:

- **SmartScreen** mostra "Windows ha protetto il PC" all'apertura dell'installer. Molti utenti si fermano lì. Altri cliccano "Ulteriori informazioni → Esegui comunque", ma in azienda i criteri possono impedirlo.
- **Windows Defender o l'antivirus aziendale** mettono in quarantena il sidecar (falso positivo), a volte *dopo* l'installazione: l'app si apre e il motore "sparisce".

Le contromisure:

1. **Firma tutto il codice.** Non solo l'installer: ogni `.exe` e ogni `.dll` che porti, sidecar e librerie GPU compresi. Serve un certificato di firma del codice da un'autorità riconosciuta; dal 2023 le chiavi private devono stare su hardware dedicato (token o HSM) o su un servizio di firma in cloud, quindi pianifica come firmerai dalla tua pipeline di build.
2. **Non aspettarti miracoli dalla firma.** SmartScreen ragiona per **reputazione**, che si accumula nel tempo con i download puliti. Anche un certificato valido non elimina subito l'avviso per un'app nuova; la firma rende però la reputazione *accumulabile* e legata al tuo editore invece che al singolo file.
3. **Segnala i falsi positivi.** Microsoft e i principali vendor antivirus hanno moduli per inviare file erroneamente rilevati. Fallo *prima* del lancio, con la versione definitiva firmata.
4. **Riduci i comportamenti sospetti:** niente eseguibili scaricati a runtime (scarichi dati — il modello — non codice), niente scrittura di eseguibili in cartelle temporanee, niente esecuzione da `%TEMP%`.
5. **Dai all'IT dei clienti un pacchetto per l'allowlist:** editore del certificato, hash dei binari, percorsi di installazione. L'IT aziendale non ama le sorprese, ma ama le istruzioni chiare.

Per gli ambienti aziendali più rigidi, valuta anche di offrire un pacchetto **MSI o MSIX** distribuibile dall'IT con i suoi strumenti: l'installazione gestita centralmente elimina il problema SmartScreen per gli utenti finali.

## Aggiornamenti: la policy prima dello strumento

Un'app desktop che non si aggiorna accumula bug e vulnerabilità (Electron porta con sé Chromium, che riceve patch di sicurezza di continuo). Un'app che si aggiorna male rompe il lavoro dell'utente nel momento sbagliato. Prima di scegliere lo strumento (electron-updater, Squirrel, un sistema tuo), scrivi la **policy di aggiornamento**:

- **L'app si aggiorna, il modello no — o almeno non insieme.** Aggiornamenti dell'applicazione piccoli e frequenti; aggiornamenti del modello rari, annunciati, facoltativi, e con il vecchio modello mantenuto finché il nuovo non è verificato. Un modello nuovo può cambiare i risultati: l'utente deve saperlo.
- **Mai durante il lavoro.** Nessun riavvio forzato mentre una trascrizione o un'elaborazione è in corso. Scarichi in background, installi alla chiusura, o chiedi.
- **Solo aggiornamenti firmati.** Il client di aggiornamento verifica la firma del pacchetto; un aggiornamento non firmato o con hash sbagliato viene scartato. Il server di aggiornamento è un vettore di attacco: trattalo come tale.
- **Canali.** Un canale "stabile" e uno "anteprima" per i clienti che vogliono provare prima. Il canale anteprima è anche il tuo test sul campo.
- **Rilascio graduale.** Una percentuale di utenti prima, poi tutti. Se qualcosa si rompe, lo scopri su pochi.
- **Rollback.** Tieni la versione precedente disponibile e un modo documentato per tornarci.
- **Ambienti offline.** Per i clienti che non possono (o non vogliono) connettersi al tuo server, un pacchetto di aggiornamento manuale, firmato, installabile dall'IT.
- **Server in UE, sotto il tuo controllo.** Il controllo degli aggiornamenti rivela quali clienti usano quale versione e quando: è un dato, anche se minimo. Tienilo tuo, e non aggiungerci identificativi personali.

Un'app offline con un sistema di aggiornamento che contatta il server a ogni avvio non è completamente offline: dillo nella documentazione, e offri l'opzione per disattivare il controllo automatico.

## Privacy: niente telemetria di default

Il valore di un'app AI offline è la promessa che **i dati non escono dal PC**. Quella promessa si rompe in modi insospettabili:

- Un SDK di analytics incluso "per capire come la usano".
- Un framework UI che carica font o script da una CDN esterna.
- Un sistema di crash reporting che spedisce dump di memoria contenenti il testo trascritto.
- Un controllo licenze che invia l'hash del file aperto.

Regole che applico e che puoi verificare:

- **Telemetria disattivata di default.** Se proprio vuoi dati d'uso, sono **opt-in**, aggregati, senza contenuti e senza identificativi personali, e l'utente vede esattamente cosa viene inviato.
- **Nessuna risorsa esterna nel renderer.** Font, icone, script: tutti inclusi nel pacchetto. Una **Content Security Policy** restrittiva nel renderer (niente `connect-src` verso l'esterno) fa sì che anche un errore di sviluppo non possa chiamare fuori.
- **Promessa verificabile.** Documenta quali connessioni l'app fa (download del modello, controllo aggiornamenti) e quando. Un cliente attento — o il suo IT — deve poter verificare con un monitor di rete che, durante l'uso, l'app non contatta nessuno. Se il tuo "offline" non regge a dieci minuti di osservazione del traffico, non è offline.
- **Dati dell'utente dove l'utente sa che sono.** Output e file di lavoro in cartelle scelte o chiaramente indicate; cache temporanee cancellate a fine elaborazione.

## Crash reporting senza mandare il file dell'utente

Senza crash report sei cieco: gli utenti non mandano i log, descrivono il problema come "si chiude". Con il crash report sbagliato, tradisci la promessa di privacy. Il caso classico: Electron include un `crashReporter` che può caricare **minidump** su un server. Un minidump contiene porzioni della memoria del processo — e la memoria di un processo che sta trascrivendo una riunione contiene la trascrizione.

La strategia che rispetta entrambe le esigenze:

1. **Raccolta locale, invio mai automatico.** I crash vengono registrati su disco, nella cartella dell'app, con rotazione (non crescono all'infinito).
2. **Report minimale per default.** Versione dell'app, versione del sidecar, backend GPU usato, modello, sistema operativo, **firma dello stack** (dove è crashato), codice di errore. Nessun contenuto, nessun percorso di file (che contiene il nome utente: è un dato personale), nessun nome di file dell'utente.
3. **Pulsante "Esporta diagnostica".** Produce un archivio che l'utente può **aprire e ispezionare** prima di mandartelo. I percorsi vengono normalizzati (`C:\Users\<utente>\...`), i contenuti esclusi.
4. **Minidump completi solo su richiesta esplicita**, caso per caso, con spiegazione di cosa contengono.
5. **Log del sidecar separati e senza testo trascritto.** Il motore logga tempi, errori, uso memoria: mai i segmenti riconosciuti.

Esempio di record di crash accettabile:

```json
{
  "app": "1.4.2", "sidecar": "whisper-srv 1.7.1", "backend": "vulkan",
  "modello": "medium-it-q5", "os": "Windows 11 23H2",
  "evento": "sidecar_exit", "codice": "0xC0000005",
  "stack_sig": "ggml_vk_compute+0x1a3",
  "memoria_mb": 5812, "durata_input_s": 3740,
  "percorso_input": "<escluso>", "testo": "<escluso>"
}
```

Con quel record capisci già moltissimo (crash di memoria nel backend Vulkan su un file di un'ora: forse la VRAM della grafica integrata non basta per quel modello), senza aver visto nemmeno una parola dell'utente.

## Il permesso del microfono

Se l'app registra direttamente (dettatura, registrazione di riunioni), c'è un'ultima trappola: su Windows il microfono è governato dalle impostazioni di privacy di sistema, con un interruttore specifico per le **app desktop**. Se è spento, l'app riceve silenzio o un errore generico, e l'utente pensa che sia rotta. In Electron gestisci esplicitamente le richieste di permesso dal renderer e, se l'accesso fallisce, **mostra all'utente dove attivarlo** invece di un messaggio d'errore criptico. E registra solo quando l'utente lo chiede, con un indicatore visibile: un'app che ascolta in silenzio è un'app che nessun IT approverà.

## Percorso di implementazione, a step

1. **Separa i processi** fin dal primo giorno: renderer sandboxato, main orchestratore, sidecar nativo su `127.0.0.1` con token.
2. **Scegli i backend** e costruisci i binari del sidecar per CUDA, Vulkan e CPU; implementa rilevamento, test di inferenza e fallback.
3. **Definisci la strategia modelli**: installer leggero, download al primo avvio con ripresa e SHA-256, pacchetto offline per l'IT.
4. **Configura l'installer per utente**, senza elevazione, con binari fuori da asar e nome prodotto corto.
5. **Blinda i percorsi**: argomenti come array, temp corta e ASCII, test con nome utente lungo e accentato, test con Documenti su OneDrive.
6. **Firma tutto** nella pipeline di build e prepara il pacchetto per l'allowlist dei clienti; invia la versione finale ai vendor antivirus per la verifica.
7. **Scrivi la policy di aggiornamento** e solo dopo configura lo strumento; server in UE, pacchetti firmati, canali, rollback.
8. **Azzera la telemetria**: nessun SDK esterno, CSP restrittiva, connessioni documentate.
9. **Implementa crash e diagnostica locali** con esportazione ispezionabile.
10. **Testa su macchine vere**: un PC da ufficio senza GPU, un portatile con grafica integrata, un utente non admin, un antivirus aziendale, un proxy. Prima del cliente, non con il cliente.

## Fallimenti tipici e come li riconosci dai log

- **Sidecar che non parte con codice di uscita immediato.** Nel log di main: processo terminato in meno di un secondo. Cause tipiche: DLL mancante (build CUDA su PC senza driver NVIDIA), eseguibile messo in quarantena dall'antivirus, percorso con caratteri non gestiti. Se il file `server.exe` non esiste più su disco, è l'antivirus.
- **Health check in timeout.** Il processo è vivo ma non risponde: modello troppo grande per la RAM/VRAM, caricamento lentissimo da disco lento, o porta bloccata da un software di sicurezza. Guarda la memoria del processo e la durata del caricamento.
- **Crash `0xC0000005` (violazione di accesso) nel backend GPU.** Driver vecchio o VRAM insufficiente per il modello scelto. Scendi di backend o di modello, e registra la combinazione per non riproporla.
- **"File non trovato" su file che esistono.** Percorso con caratteri non ASCII o oltre `MAX_PATH`. Nei log: il percorso passato al sidecar è storpiato o lungo più di 250 caratteri.
- **Download del modello bloccato al 99% o hash errato.** Proxy aziendale che interrompe o altera la connessione. Nei log: dimensione finale diversa, SHA-256 non corrispondente. Soluzione: pacchetto offline.
- **Login lentissimi segnalati dall'IT.** Hai scritto il modello in `%APPDATA%` (Roaming). Spostalo.
- **Trascrizioni vuote con microfono.** Permesso microfono disattivato per le app desktop. Nei log: stream audio aperto ma livello sempre a zero, o errore di permesso.
- **Aggiornamento che rompe tutto a una parte degli utenti.** Il rilascio graduale lo fa emergere su pochi; il rollback lo risolve. Senza entrambi, lo scopri da tutti insieme.

## Costi: ordini di grandezza

Stime indicative, da verificare con i fornitori.

- **Certificato di firma del codice:** nell'ordine di **qualche centinaio di euro l'anno**, più eventuale token hardware; i servizi di firma in cloud hanno abbonamenti mensili contenuti. È una spesa obbligatoria, non opzionale.
- **Banda per i modelli:** se il modello pesa 2 GB e hai 1.000 installazioni, sono circa **2 TB** di trasferimento, più gli aggiornamenti del modello. Su un object storage o una CDN europea, **decine di euro** per un rilascio del genere; con un server tuo, attenzione ai limiti di traffico del piano.
- **Build multi-backend:** mantenere tre varianti del sidecar (CUDA, Vulkan, CPU) costa tempo di CI e di test, non licenze.
- **Energia lato utente:** trascrivere un'ora di audio con una GPU da 150–250 W per 5 minuti consuma meno di **0,03 kWh**; in modalità CPU per 30 minuti, qualche centesimo di kWh in più. Trascurabile rispetto al valore del dato che resta in casa.
- **Il costo vero è il test su macchine reali**: un pomeriggio con un PC da ufficio vecchio, un portatile senza GPU e un utente non admin vale più di una settimana di sviluppo su una workstation da gaming.

## Quando NON farlo

- **Se i tuoi utenti sono tutti su macchine gestite da te**, un'applicazione web interna che gira su un server in azienda può essere più semplice: un solo posto da aggiornare, niente antivirus da convincere su cento PC.
- **Se il modello richiede più di quanto l'hardware dei clienti può dare**, non fingere: un LLM grande su un portatile senza GPU è un'esperienza pessima. Meglio un server locale in ufficio che serve i client.
- **Se non puoi permetterti un certificato di firma e un minimo di infrastruttura di aggiornamento**, non distribuire un eseguibile a clienti paganti. Uno strumento interno, forse; un prodotto, no.
- **Se la tua proposta di valore non dipende dall'essere offline**, valuta se Electron e i modelli locali valgono il costo di manutenzione. Offline ha senso quando il dato *non deve* uscire, non come vezzo tecnico.
- **Se non hai tempo di testare su Windows veri**, rimanda il lancio. Le trappole di questo pezzo non si trovano in teoria.

## Checklist operativa prima del lancio

- [ ] Renderer con `sandbox`, `contextIsolation`, senza `nodeIntegration`; API minima via preload.
- [ ] Inferenza in un sidecar nativo, su `127.0.0.1`, porta casuale e token; riavvio automatico se cade.
- [ ] Rilevamento backend con test reale e fallback CUDA → Vulkan → CPU; modello di default adeguato all'hardware.
- [ ] Modello scaricato con ripresa e SHA-256, salvato in `%LOCALAPPDATA%`; pacchetto offline per l'IT.
- [ ] Installer per utente, senza elevazione, binari fuori da `app.asar`, nome prodotto corto.
- [ ] Test con nome utente lungo, con spazi, apostrofi e accenti; Documenti su OneDrive; utente non admin.
- [ ] Argomenti al sidecar come array; temp corta e ASCII per i file di input problematici.
- [ ] Tutti gli `.exe` e `.dll` firmati; falsi positivi segnalati prima del lancio; pacchetto allowlist per l'IT.
- [ ] Policy di aggiornamento scritta: firmati, mai durante il lavoro, canali, rilascio graduale, rollback, pacchetto offline.
- [ ] Zero telemetria di default; nessuna risorsa esterna nel renderer; CSP restrittiva; connessioni documentate.
- [ ] Crash report locali e minimali, esportazione ispezionabile, nessun contenuto né percorso utente.
- [ ] Gestione esplicita del permesso microfono, con istruzioni all'utente.
- [ ] Prova completa su almeno un PC da ufficio senza GPU e un portatile con grafica integrata.

## Il verdetto

Un'**app desktop AI offline su Windows** è, oggi, il modo più sovrano di mettere un modello nelle mani di un professionista: il file audio del cliente, il contratto riservato, la cartella clinica non lasciano mai il PC. Ma la distanza tra "funziona sul mio portatile" e "funziona sui PC dei clienti" è fatta di cose che nessun tutorial di Colab ti mostra: 260 caratteri, un apostrofo nel nome utente, un antivirus che non ti conosce, una grafica integrata al posto della GPU, una cartella Documenti che vive su OneDrive.

La ricetta non è complicata, è solo disciplinata: Electron per l'interfaccia, un sidecar nativo per il calcolo, tre backend con fallback, modello scaricato e verificato nel posto giusto, installazione per utente, tutto firmato, aggiornamenti con una policy prima che con uno strumento, e una promessa di privacy che regge a un monitor di rete — compresi i crash report. Fatto così, il cliente installa, apre, usa, e non ti scrive più. Che per un software desktop è il complimento più alto.

Se stai portando un prototipo AI verso un prodotto desktop per i tuoi clienti e vuoi evitare il lancio che muore su Windows Defender, puoi leggere il mio percorso nella [biografia]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Partiamo da un PC da ufficio vero, non dalla tua workstation.

## FAQ

### Perché non far girare il modello direttamente dentro Electron?
Perché l'inferenza è pesante e fragile. Se gira nel processo principale blocca l'interfaccia; se gira nel renderer apri un problema di sicurezza; se un modulo nativo va in crash si porta giù tutta l'app. Un sidecar nativo separato (per esempio il server incluso in whisper.cpp o llama.cpp) isola il calcolo: se cade, il processo principale lo riavvia e l'utente vede un messaggio, non una finestra che sparisce.

### Il modello va incluso nell'installer o scaricato dopo?
Nella maggior parte dei casi conviene un ibrido: installer leggero, download del modello al primo avvio con ripresa e verifica SHA-256, e un pacchetto modello separato per gli ambienti senza internet o dietro proxy difficili. Includere tutto nell'installer ha senso solo se i clienti sono prevalentemente offline e accetti pacchetti da diversi gigabyte a ogni aggiornamento.

### Come gestisco il limite di 260 caratteri dei percorsi Windows?
Non contare sul fatto che i percorsi lunghi siano abilitati: richiede un'impostazione di sistema da amministratore e il supporto di tutte le librerie che usi. Tieni i binari in cartelle corte e piatte, usa un nome di prodotto breve, lavora in una cartella temporanea tua e corta invece che accanto ai file dell'utente, e testa l'app sotto un utente con un nome lungo e accentato prima di distribuirla.

### Serve per forza una GPU NVIDIA?
No. CUDA dà le prestazioni migliori su NVIDIA, ma il backend Vulkan di whisper.cpp e llama.cpp funziona anche su schede AMD e su molte grafiche integrate, e la CPU resta il fallback universale con un modello più piccolo. La strategia giusta è rilevare l'hardware all'avvio, fare un piccolo test di inferenza, scegliere il backend che funziona e dire all'utente onestamente quanto ci metterà.

### Come evito che Windows Defender blocchi l'app?
Firma ogni eseguibile e ogni DLL, compresi il sidecar e le librerie GPU; evita di scaricare codice a runtime (scarica dati, non eseguibili); non eseguire nulla da cartelle temporanee; invia la versione finale firmata ai vendor antivirus per la verifica dei falsi positivi prima del lancio; e fornisci all'IT dei clienti le informazioni per l'allowlist. La reputazione di SmartScreen cresce col tempo: la firma è necessaria ma non elimina subito l'avviso.

### La firma del codice fa sparire l'avviso di SmartScreen?
Non immediatamente. SmartScreen si basa sulla reputazione accumulata dall'editore e dai file nel tempo. La firma rende quella reputazione possibile e legata alla tua identità, e protegge dalla manomissione, ma un'app nuova può ancora mostrare l'avviso finché non accumula download puliti. Per i clienti aziendali, un pacchetto MSI distribuito dall'IT evita il problema agli utenti finali.

### Dove devo salvare il modello sul PC dell'utente?
In `%LOCALAPPDATA%\NomeApp\models`. Non in `%APPDATA%`, che è la cartella Roaming e in molte aziende viene sincronizzata con il profilo di rete (login lentissimi), e non in Documenti o sul Desktop, che spesso sono dentro OneDrive, dove i file possono essere segnaposto o bloccati dalla sincronizzazione.

### Come aggiorno l'app senza disturbare l'utente?
Con una policy chiara: aggiornamenti dell'app piccoli e firmati, scaricati in background e installati alla chiusura; mai riavvii durante un'elaborazione; modello aggiornato separatamente, raramente e con consenso; canali stabile e anteprima; rilascio graduale e rollback. Per i clienti offline, un pacchetto di aggiornamento manuale firmato che l'IT può distribuire.

### Posso avere crash report senza violare la privacy?
Sì, se li progetti apposta. Raccogli i crash localmente, con un report minimale che contiene versioni, backend, modello, codice di errore e firma dello stack, ma nessun contenuto e nessun percorso di file (che include il nome utente). Offri un pulsante di esportazione diagnostica che l'utente può aprire e controllare prima di inviartelo. I minidump completi, che possono contenere la memoria del processo e quindi i dati trattati, vanno chiesti solo caso per caso.

### Come dimostro al cliente che l'app è davvero offline?
Documenta esattamente quali connessioni fa l'app (download del modello, eventuale controllo aggiornamenti disattivabile) e invitalo a verificarlo: durante l'uso normale un monitor di rete non deve vedere traffico in uscita. Tecnicamente, niente SDK di analytics, nessuna risorsa caricata da CDN nel renderer, una Content Security Policy che blocca le connessioni esterne e il sidecar in ascolto solo su `127.0.0.1`.
