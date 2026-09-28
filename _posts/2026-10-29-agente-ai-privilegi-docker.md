---
lang: it
permalink: /it/blog/agente-ai-privilegi-docker/
title: "L'agente non deve avere root sul server: user namespace, reti Docker interne e il giorno in cui un tool `rm` non è uno scherzo"
date: 2026-10-29 07:30:00 +0200
author: "Antonio Trento"
description: "Hardening dei container per agenti AI che eseguono comandi: threat model prompt-tool-shell, perché docker.sock è la fine del gioco, utente non-root, filesystem read-only, reti interne, allowlist di comandi, seccomp e AppArmor, log delle exec, test di fuga e audit prima del go-live."
keywords: ["agente ai privilegi docker", "least privilege llm", "docker user namespace", "sandbox tool", "comando rm agente", "hardening container agente"]
image: /assets/images/posts/agente-ai-privilegi-docker.jpg
pillar: stack-sovrano
related: [/it/blog/docker-pmi-stack-sovrano/, /it/blog/prompt-injection-documenti-aziendali/]
---

## Un LLM che può usare la shell è un ransomware con una bella interfaccia

L'agente doveva fare una cosa sola: aiutare il team a gestire file e report sul server interno. "Converti questi CSV in Excel", "comprimi la cartella dei report di settembre", "trova i PDF più grandi di 50 MB". Per renderlo flessibile, gli sviluppatori gli hanno dato uno strumento generico: `esegui_comando(cmd)`, che passa una stringa alla shell del container. Il container, per comodità, gira come root, monta la cartella condivisa dell'ufficio in lettura e scrittura, e — per permettere all'agente di "riavviare il servizio dei report" — ha accesso al socket di Docker.

Un giorno un utente chiede di "fare pulizia dei file temporanei nella cartella dei report". L'agente costruisce un comando di cancellazione con un percorso sbagliato di un livello. Oppure — scenario peggiore e non meno realistico — un documento caricato contiene istruzioni nascoste che l'agente legge come parte del compito, e il comando che esegue non è un errore, ma esattamente ciò che l'autore del documento voleva. In entrambi i casi, il processo che esegue il comando ha i permessi di root nel container, la cartella condivisa montata in scrittura e, attraverso il socket di Docker, il controllo dell'intero server.

Il giorno in cui un tool `rm` non è uno scherzo arriva sempre. La domanda è solo quanto danno può fare quando arriva. Questo pezzo parla di **container security per agenti**: come isolare un agente AI che esegue comandi in modo che un errore o una manipolazione restino confinati. Partiamo dal modello delle minacce, vediamo perché `docker.sock` è la fine del gioco, come configurare utente non-root, filesystem in sola lettura e tmpfs, reti interne, allowlist di comandi, seccomp e AppArmor, cosa registrare di ogni esecuzione, come fare i **test di fuga** e l'audit prima del go-live.

## Threat model: prompt → tool → shell

Il modello delle minacce di un agente che esegue comandi ha una catena semplice:

```
input (utente, documento, email, pagina web, output di un altro tool)
   │  può contenere istruzioni ostili o essere semplicemente ambiguo
   ▼
LLM  ──decide──►  chiamata a tool  ──►  comando in shell / filesystem / rete
                                          │
                                          ▼
                                 effetti con i PRIVILEGI DEL PROCESSO
```

Tre osservazioni che cambiano il modo di progettare:

**1. Il modello non è un confine di sicurezza.** Istruzioni nel prompt di sistema come "non eseguire mai comandi distruttivi" riducono la probabilità di un errore, ma non la azzerano, e una prompt injection ben costruita può aggirarle. Ogni testo che l'agente legge — un file, un'email, una pagina web, l'output di un comando precedente — è un potenziale canale di istruzioni. L'ho descritto in dettaglio nel pezzo sulla [prompt injection nei documenti aziendali]({{ '/it/blog/prompt-injection-documenti-aziendali/' | relative_url }}). La conseguenza pratica: **devi progettare come se il modello potesse, prima o poi, eseguire qualsiasi comando che gli strumenti gli permettono**.

**2. Il danno massimo è definito dai privilegi, non dalle intenzioni.** Se il processo che esegue i comandi può cancellare la cartella condivisa, prima o poi un comando la cancellerà. Se può leggere le variabili d'ambiente con le password, prima o poi un output le conterrà. Se può raggiungere Internet, prima o poi invierà dati fuori. La domanda di progetto non è "l'agente lo farà?", ma "**se lo facesse, cosa succederebbe?**".

**3. Gli obiettivi di un attaccante sono prevedibili.** Esfiltrare dati (leggere file, variabili d'ambiente, database e inviarli fuori), distruggere o cifrare dati (il ransomware), ottenere persistenza (installare qualcosa che resti), muoversi lateralmente (raggiungere altri servizi della rete interna), prendere il controllo dell'host (uscire dal container). L'hardening del container serve a rendere ciascuno di questi obiettivi impossibile o molto difficile.

Il principio che guida tutto il resto è il **minimo privilegio**: il processo che esegue le azioni dell'agente deve avere esattamente i permessi necessari per i compiti previsti, e niente di più. Non "root perché è comodo". Non "accesso a tutta la cartella perché non si sa mai".

## docker.sock: la fine del gioco

Cominciamo dalla regola più importante, perché un solo errore qui annulla tutto il resto: **non montare mai `/var/run/docker.sock` nel container di un agente**.

Il socket di Docker è l'interfaccia con cui si comanda il demone Docker, che sull'host gira normalmente con i privilegi di root. Chi può parlare con il socket può chiedere al demone di avviare un nuovo container **privilegiato**, con il filesystem dell'host montato al suo interno. In pratica: accesso al socket di Docker equivale a **root sull'host**, senza bisogno di alcuna vulnerabilità. Non importa quanto sia blindato il container dell'agente — utente non-root, filesystem in sola lettura, capability rimosse — se il socket è montato, l'agente (o chi lo manipola) può semplicemente chiedere a Docker un container senza nessuna di queste restrizioni.

Il socket finisce nei container per ragioni comprensibili: permettere all'agente di riavviare un servizio, di leggere i log di altri container, di avviare job "usa e getta". Le alternative:

- **Per riavviare servizi o leggere log**: un piccolo servizio intermedio con un'API ristretta a quelle operazioni specifiche (riavvia *questo* container, leggi le ultime 200 righe di log di *questi* container), con autenticazione. L'agente chiama l'API, non il socket.
- **Se serve proprio parlare con Docker**: un proxy del socket che filtra le chiamate consentite (esistono progetti open source costruiti per questo), configurato per permettere solo operazioni di lettura o un insieme ristrettissimo di azioni. È un compromesso, non una soluzione ideale.
- **Per job isolati**: un sistema di code che esegue i job in un ambiente separato, dove l'agente sottomette la richiesta e non crea direttamente container.

Lo stesso ragionamento vale per altri "equivalenti di root": montare il filesystem dell'host (`/` o `/etc`), eseguire il container con `--privileged`, condividere il namespace dei processi o della rete dell'host (`--pid=host`, `--network=host`), dare la capability `SYS_ADMIN`. Ognuna di queste opzioni apre una via verso l'host.

## User non-root, read-only, tmpfs

Una volta chiuso l'accesso a Docker, si riduce ciò che il processo può fare **dentro** il container. Ecco un `docker-compose.yml` di esempio per il servizio che esegue i tool di un agente, con le opzioni di sicurezza commentate:

```yaml
services:
  agent-tools:
    image: registry.interno/agent-tools:1.4.2@sha256:...   # versione fissata, immagine minimale
    user: "10001:10001"                 # utente non-root, UID senza corrispondenze sull'host
    read_only: true                     # root filesystem in sola lettura
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=256m     # area di lavoro temporanea, non eseguibile
    volumes:
      - reports_in:/data/in:ro          # input in sola lettura
      - reports_out:/data/out:rw        # UNICA directory scrivibile persistente
    cap_drop: [ALL]                     # nessuna capability Linux
    security_opt:
      - no-new-privileges:true          # niente escalation via setuid/setgid
      - seccomp=./seccomp-agent.json    # profilo seccomp (il default di Docker è già buono)
      - apparmor=agent-tools            # profilo AppArmor caricato sull'host (se disponibile)
    pids_limit: 128                     # niente fork bomb
    mem_limit: 1g
    cpus: 1.0
    ulimits:
      nofile: { soft: 1024, hard: 1024 }
    environment:
      - TOOLS_ALLOWLIST=/etc/agent/allowlist.yaml   # nessuna password qui
    networks: [tools_net]               # rete interna, senza uscita (vedi sotto)
    restart: unless-stopped

networks:
  tools_net:
    internal: true                      # nessun accesso a Internet

volumes:
  reports_in:
  reports_out:
```

Cosa ottiene ciascuna opzione:

- **`user`**: il processo non è root nel container. Molti attacchi di fuga dal container e molte azioni dannose richiedono root. Scegli un UID alto che non corrisponda a utenti reali dell'host.
- **`read_only`**: il filesystem dell'immagine non si può modificare. Niente binari sostituiti, niente persistenza, niente configurazioni alterate. Le aree scrivibili sono dichiarate esplicitamente.
- **`tmpfs` con `noexec`**: l'area temporanea esiste in memoria, sparisce al riavvio, e i file lì dentro **non si possono eseguire**. Un attaccante che scarica o scrive uno script non può lanciarlo da `/tmp`.
- **Volumi con `:ro`**: l'input si legge, non si modifica. Solo l'output è scrivibile, ed è una directory dedicata, non la cartella condivisa dell'ufficio.
- **`cap_drop: [ALL]`**: le capability Linux sono i "pezzi" in cui è diviso il potere di root. Toglierle tutte e aggiungere solo quelle indispensabili (quasi mai necessario per un servizio di tool) chiude molte strade.
- **`no-new-privileges`**: impedisce che un programma setuid dia al processo più privilegi di quelli con cui è partito.
- **Limiti di risorse**: un agente in loop, o un comando malevolo, non deve poter esaurire memoria, CPU o processi dell'host.

**User namespace.** Un ulteriore livello: con il **remapping degli user namespace** del demone Docker (opzione `userns-remap`) o con **Docker rootless**, anche l'utente root *dentro* il container corrisponde a un utente senza privilegi *sull'host*. Se un attaccante riuscisse a diventare root nel container e a uscire, si troverebbe con i permessi di un utente qualunque. È una configurazione del demone, non del singolo container, e ha alcune incompatibilità da verificare (con certi volumi e certe opzioni di rete), ma per un host dedicato ad agenti che eseguono comandi vale lo sforzo.

**Immagine minimale.** Meno binari ci sono nell'immagine, meno strumenti ha a disposizione un attaccante. Un'immagine con solo l'interprete e le librerie necessarie non contiene `curl`, `wget`, `nc`, compilatori, gestori di pacchetti. Se il tool dell'agente deve convertire CSV in Excel, l'immagine deve contenere quello, non una distribuzione completa.

## Reti: l'agente non vede Postgres in chiaro

Un container isolato sul filesystem ma con accesso libero alla rete è ancora pericoloso: può leggere dati dai servizi interni e inviarli fuori. Due direzioni da chiudere.

**Verso l'esterno (egress).** Il container dei tool, di norma, **non deve raggiungere Internet**. Con Docker Compose una rete dichiarata `internal: true` non ha uscita. Se alcuni tool hanno bisogno di chiamare servizi esterni specifici (un'API di conversione, un servizio pubblico), l'uscita passa da un **proxy con allowlist di domini**, che registra ogni richiesta e rifiuta il resto. Lo stesso principio che applico agli agenti che navigano il web, descritto nel pezzo sull'[agente browser con Playwright e allowlist]({{ '/it/blog/playwright-agente-browser-allowlist/' | relative_url }}).

**Verso l'interno (movimento laterale).** Il container dei tool non deve stare sulla stessa rete di Postgres, di n8n, del pannello di amministrazione. In uno stack Docker tipico, è facile mettere tutto sulla rete di default del progetto, dove ogni servizio vede ogni altro servizio per nome. Per un agente che esegue comandi è un errore: se l'agente ha accesso alla rete del database, un comando può provare a connettersi, e se trova credenziali nelle variabili d'ambiente o in un file, può leggere tutto.

La struttura corretta separa le reti:

```
  Internet
     │  (solo via proxy con allowlist, se serve)
┌────┴─────────┐
│ egress-proxy │◄────────── tools_net (internal) ──────────► agent-tools
└──────────────┘                                                 ▲
                                                                 │ API ristretta (HTTP, auth)
  data_net (internal)                                            │
  ┌──────────┐     ┌──────────────┐                        ┌─────┴──────┐
  │ postgres │◄───►│ data-api     │◄─────── agent_net ────►│ agente/LLM │
  └──────────┘     │ (query       │                        │ orchestr.  │
                   │  predefinite)│                        └────────────┘
                   └──────────────┘
```

L'agente non parla con Postgres: chiama un servizio intermedio (`data-api`) che espone **operazioni predefinite** (cerca cliente per codice, elenca fatture di un mese) con i propri permessi minimi sul database. Il container che esegue comandi non vede né il database né l'API dei dati: vede solo il proprio input e output e, se serve, il proxy di uscita. Ogni salto tra reti è una decisione esplicita.

E le **credenziali** non stanno nelle variabili d'ambiente del container dei tool: se un comando può leggere `/proc/self/environ` o eseguire `env`, può leggere ogni password passata così. Le credenziali servono ai servizi che parlano con i sistemi (la `data-api`), non al sandbox che esegue comandi. Sulla gestione dei segreti per gli agenti ho scritto un pezzo dedicato: [secrets per agenti LLM e vault]({{ '/it/blog/secrets-agenti-llm-vault/' | relative_url }}).

## Allowlist comandi vs "bash libero"

Anche nel container più blindato, uno strumento `esegui_comando(cmd: str)` che passa una stringa a `bash -c` è una scelta da evitare. La shell interpreta pipe, redirezioni, sostituzioni di comando, variabili: la superficie è enorme e impossibile da controllare con filtri sulla stringa.

L'alternativa è una **allowlist**: l'agente non esegue comandi arbitrari, ma chiama **strumenti specifici** con parametri tipizzati, che il codice traduce in un'esecuzione controllata, **senza shell**.

```python
import subprocess, shlex
from pathlib import Path

BASE_IN, BASE_OUT = Path("/data/in"), Path("/data/out")

def _dentro(base: Path, p: str) -> Path:
    q = (base / p).resolve()
    if not q.is_relative_to(base):                 # blocca ../ e link simbolici verso l'esterno
        raise PermissionError(f"percorso fuori da {base}: {p}")
    return q

TOOLS = {
    # nome: (eseguibile ASSOLUTO, costruttore degli argomenti, timeout)
    "csv_to_xlsx": ("/usr/local/bin/csv2xlsx",
                    lambda a: [str(_dentro(BASE_IN, a["src"])), str(_dentro(BASE_OUT, a["dst"]))], 60),
    "comprimi":    ("/usr/bin/zip",
                    lambda a: ["-r", "-q", str(_dentro(BASE_OUT, a["archivio"])), str(_dentro(BASE_IN, a["cartella"]))], 300),
    "file_grandi": ("/usr/bin/find",
                    lambda a: [str(_dentro(BASE_IN, a.get("cartella", "."))), "-type", "f",
                               "-size", f"+{int(a['mb'])}M"], 30),
}

def esegui_tool(nome: str, args: dict, audit) -> dict:
    if nome not in TOOLS:
        raise PermissionError(f"tool non consentito: {nome}")
    exe, build, timeout = TOOLS[nome]
    argv = [exe, *build(args)]
    audit.inizio(nome, argv)                       # log PRIMA dell'esecuzione
    r = subprocess.run(argv, shell=False, capture_output=True, text=True, timeout=timeout,
                       env={"PATH": "/usr/bin:/usr/local/bin", "LANG": "C.UTF-8"})   # ambiente pulito
    audit.fine(nome, r.returncode, r.stdout[-4000:], r.stderr[-2000:])
    return {"exit": r.returncode, "out": r.stdout[-4000:]}
```

Le proprietà da notare:

- **Nessuna shell** (`shell=False`): gli argomenti sono una lista, non una stringa da interpretare. Punti e virgola, pipe e sostituzioni non hanno effetto.
- **Eseguibili con percorso assoluto** e scelti dal codice, non dal modello.
- **Percorsi confinati**: ogni percorso passato dal modello viene risolto e verificato contro la directory consentita, contro `../` e contro i link simbolici che puntano fuori.
- **Ambiente pulito**: il processo figlio non eredita variabili d'ambiente con segreti.
- **Timeout** per ogni tool.
- **Audit prima e dopo** l'esecuzione.

Il tool `cancella` merita un discorso a sé. Se serve davvero, non deve essere un `rm` generico: deve **spostare** in un cestino con conservazione (così un errore è recuperabile), limitarsi alla directory di output, rifiutare percorsi con caratteri jolly, avere un limite al numero di file per chiamata e, oltre una soglia, passare da un'approvazione umana. Lo stesso principio del [kill switch per agenti che scrivono sui sistemi]({{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }}): le azioni distruttive hanno un percorso più stretto delle altre.

### La deny list, e perché da sola non basta

Una **deny list** — un elenco di comandi e pattern vietati — è la prima cosa che viene in mente, e da sola è una difesa debole: i modi di ottenere lo stesso effetto sono infiniti (un comando vietato può essere richiamato con un altro nome, codificato, costruito da un linguaggio di scripting). Ha però senso come **secondo livello**, sopra l'allowlist, e come fonte di allarmi: se il modello *tenta* uno di questi comandi, è un segnale da investigare anche se l'allowlist lo avrebbe comunque bloccato.

Una deny list di esempio, da usare per allarmi e blocco aggiuntivo:

| Categoria | Pattern (esempi) | Perché |
|-----------|------------------|--------|
| Distruzione | `rm -rf`, `rm` con `/` o `*`, `mkfs`, `dd of=`, `shred`, `truncate` | cancellazione o sovrascrittura di dati |
| Esecuzione remota | `curl … \| sh`, `wget … \| bash`, `python -c`, `perl -e`, `eval` | esecuzione di codice arbitrario |
| Rete e esfiltrazione | `nc`, `ncat`, `socat`, `ssh`, `scp`, `ftp`, `/dev/tcp/` | canali di uscita dei dati |
| Privilegi | `sudo`, `su`, `chmod +s`, `chown root`, `setcap`, `nsenter`, `unshare` | escalation |
| Controllo host | `docker`, `ctr`, `kubectl`, `mount`, `modprobe`, `sysctl` | uscita dal container |
| Persistenza | `crontab`, `systemctl`, scritture in `/etc/`, `~/.ssh/`, `~/.bashrc` | restare nel sistema |
| Segreti | `env`, `printenv`, `/proc/*/environ`, `cat` su `.env`, `id_rsa`, `*.pem` | lettura di credenziali |
| Offuscamento | `base64 -d`, `xxd -r`, stringhe esadecimali lunghe | nascondere il comando reale |

Ripeto il punto: questa tabella è un **allarme**, non il confine. Il confine è l'allowlist più il container.

## seccomp / AppArmor: cenni operativi

Sotto il livello dei comandi, il kernel Linux offre due meccanismi per limitare ciò che un processo può fare, indipendentemente da ciò che il processo "decide".

**seccomp** filtra le **chiamate di sistema** che un processo può invocare. Docker applica per default un profilo seccomp che blocca alcune decine di chiamate pericolose (per esempio quelle per caricare moduli del kernel o manipolare namespace), ed è già una buona base. Due indicazioni operative:

- **Non disattivarlo mai** (`seccomp=unconfined`) per "far funzionare" qualcosa: se un tool non funziona con il profilo di default, il problema è il tool.
- **Restringerlo** è possibile scrivendo un profilo personalizzato a partire da quello di default e rimuovendo le chiamate che il servizio non usa. Si ottiene registrando le chiamate effettive durante i test (con strumenti di tracciamento) e costruendo un profilo su misura. Richiede lavoro e test di regressione; conviene per i servizi più esposti.

**AppArmor** (su Ubuntu e Debian; su distribuzioni della famiglia Red Hat il ruolo è svolto da **SELinux**) limita l'accesso a **file, capability e rete** in base a un profilo. Docker applica un profilo AppArmor di default ai container, se AppArmor è attivo sull'host. Un profilo personalizzato può, per esempio, vietare la scrittura ovunque tranne `/data/out` e `/tmp`, e l'esecuzione di qualsiasi binario tranne quelli dell'allowlist: una seconda barriera, applicata dal kernel, sotto quella del codice.

Per chi ha bisogno di un isolamento ancora più forte — agenti che eseguono codice arbitrario generato dal modello, per esempio — esistono runtime che interpongono un kernel applicativo o una micro-VM tra il container e l'host (come gVisor o soluzioni basate su micro-VM). Riducono drasticamente la superficie del kernel esposta, al prezzo di qualche limitazione di compatibilità e di prestazioni. Per un agente che esegue un insieme chiuso di strumenti, i controlli descritti finora sono di solito sufficienti; per un agente che scrive ed esegue codice, vale la pena considerarli.

## Cosa loggare delle exec

Ogni esecuzione di uno strumento da parte dell'agente deve lasciare una traccia che permetta di rispondere, dopo un incidente, a tre domande: **cosa è stato eseguito, perché, con quale effetto**.

Per ogni esecuzione:

- **identificativo della richiesta e della conversazione** (per risalire all'input che l'ha provocata);
- **utente o processo** per conto del quale l'agente agiva;
- **nome del tool e argomenti** effettivi (la lista `argv`, dopo la validazione);
- **il testo che ha motivato la chiamata**, o almeno un riferimento alla traccia del modello;
- **esito**: codice di uscita, durata, dimensione dell'output, estratto dell'output e degli errori (troncato e con i segreti mascherati);
- **tentativi bloccati**: chiamate a tool non consentiti, percorsi fuori dal confine, pattern della deny list. Sono le righe più importanti.

I log vanno **fuori dal container** (che è in sola lettura e può essere ricreato) e fuori dalla portata dell'agente: inviati a un sistema centrale, non scritti in una directory che l'agente può modificare. Sul livello dell'host, un sistema di audit del kernel può registrare anche le esecuzioni di processi nel container, come verifica indipendente.

Gli allarmi da configurare subito: qualsiasi tentativo bloccato dalla deny list o dal confine dei percorsi; picchi di esecuzioni in poco tempo (un loop); un numero anomalo di file scritti o cancellati; qualsiasi tentativo di connessione in uscita rifiutato dal proxy. Il quadro generale — tracce, metriche e allarmi per sistemi basati su LLM — è quello del pezzo sull'[osservabilità degli LLM in produzione]({{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}).

## Lo stesso incidente, con il container giusto

Torniamo all'agente dell'introduzione e rigiochiamo i due scenari con la configurazione descritta finora.

**Scenario 1: la pulizia con il percorso sbagliato.** L'utente chiede di eliminare i file temporanei dei report. Non esiste un tool `esegui_comando`: esiste un tool `sposta_nel_cestino(percorso)`, confinato alla directory di output. Il modello costruisce un percorso sbagliato di un livello, che punta alla radice dei dati condivisi. La validazione risolve il percorso, verifica che sia fuori da `/data/out` e rifiuta la chiamata. Anche se il percorso fosse stato dentro il confine, il tool avrebbe spostato i file in un cestino con conservazione, non cancellati, e oltre una certa quantità di file avrebbe chiesto una conferma umana. Il log registra un tentativo bloccato; l'utente riceve un messaggio di errore; nessun dato è perso.

**Scenario 2: il documento con istruzioni nascoste.** Un PDF caricato contiene, in testo invisibile, l'istruzione di "eseguire la manutenzione" leggendo le variabili d'ambiente e inviandole a un indirizzo esterno. Il modello, nel peggiore dei casi, prova a seguirla. Non trova un tool per leggere l'ambiente; se tentasse di usare un tool di conversione con argomenti costruiti ad arte, la validazione dei percorsi bloccherebbe `/proc/self/environ`; l'ambiente del processo figlio è comunque pulito; e anche se riuscisse a produrre un output con dati sensibili, il container non ha uscita verso Internet, e il proxy rifiuterebbe un dominio non in allowlist. Ogni passaggio fallito lascia una riga di log e, con gli allarmi configurati, una notifica.

**Il terzo scenario, quello del socket.** Nella configurazione originale, l'agente poteva "riavviare il servizio dei report" parlando con Docker. Nella nuova, chiama un'API che sa riavviare **quel** container e nient'altro. Non esiste una sequenza di comandi, per quanto ingegnosa, che trasformi quella chiamata in root sull'host.

In nessuno dei tre casi il modello è diventato più affidabile. È cambiato il perimetro: gli errori e le manipolazioni ci sono ancora, ma finiscono contro pareti che non dipendono da ciò che il modello decide.

## Test di fuga

Un hardening non verificato è una configurazione sperata. Prima del go-live, e a ogni modifica dell'immagine o del compose, si esegue una batteria di **test di fuga**: dall'interno del container, si prova a fare ciò che non dovrebbe essere possibile, e si verifica che fallisca.

```bash
#!/bin/sh
# escape-tests.sh — eseguito DENTRO il container agent-tools; ogni test deve FALLIRE (=OK)
t() { if sh -c "$2" >/dev/null 2>&1; then echo "KO  $1"; FAIL=1; else echo "ok  $1"; fi; }
FAIL=0
t "non root"                     '[ "$(id -u)" = "0" ]'
t "docker.sock assente"          '[ -S /var/run/docker.sock ]'
t "rootfs read-only"             'touch /usr/local/bin/x'
t "/tmp non eseguibile"          'cp /bin/true /tmp/t && /tmp/t'
t "input read-only"              'touch /data/in/x'
t "niente capability"            'grep -q "CapEff:.*[1-9a-f]" /proc/self/status'
t "no escalation setuid"         'grep -q "NoNewPrivs:[[:space:]]*0" /proc/self/status'
t "niente Internet"              'wget -q -T 5 -O- https://example.com'
t "Postgres non raggiungibile"   'nc -z -w 3 postgres 5432'
t "n8n non raggiungibile"        'nc -z -w 3 n8n 5678'
t "niente segreti in env"        'env | grep -Eiq "pass|secret|token|key="'
t "mount vietato"                'mount -t tmpfs none /mnt'
t "fork bomb limitata"           'for i in $(seq 1 500); do sleep 5 & done'   # la shell deve fallire il fork
exit $FAIL
```

(Alcuni test presuppongono strumenti presenti nell'immagine, come `wget` o `nc`, che in un'immagine minimale correttamente mancano: in quel caso il test si esegue da un container di prova agganciato alla stessa rete, con la stessa configurazione. L'importante è verificare la **rete**, non la presenza del binario.)

Oltre ai test di sistema, servono i **test dal lato del modello**: una batteria di richieste e documenti ostili — istruzioni nascoste in un file, richieste di "pulizia" ambigue, tentativi di farsi mostrare le variabili d'ambiente, di leggere file fuori dalla directory, di contattare indirizzi esterni — e la verifica che ogni tentativo venga bloccato dal tool layer e registrato. Sono gli stessi scenari "da non fare" che uso nella [valutazione degli agenti in produzione]({{ '/it/blog/valutazione-agenti-llm-produzione/' | relative_url }}).

## Audit prima del go-live

Prima di mettere in produzione un agente che esegue comandi, una revisione in forma di checklist. Non è burocrazia: è il momento in cui si scoprono il socket montato "solo per il debug" e la variabile d'ambiente con la password dimenticata.

1. **Inventario delle capacità**: elenco dei tool, per ciascuno cosa può leggere, scrivere, eseguire, raggiungere in rete.
2. **Nessun equivalente di root**: niente `docker.sock`, `--privileged`, host network/PID, mount dell'host, `SYS_ADMIN`.
3. **Container**: utente non-root, rootfs in sola lettura, tmpfs `noexec`, `cap_drop: ALL`, `no-new-privileges`, limiti di risorse, immagine minimale con versione fissata.
4. **Rete**: rete interna senza uscita; proxy con allowlist se servono domini esterni; nessun accesso diretto a database e servizi interni.
5. **Segreti**: nessuna credenziale nell'ambiente o nel filesystem del sandbox.
6. **Tool layer**: allowlist, nessuna shell, percorsi confinati, ambiente pulito, timeout; azioni distruttive con cestino e soglie.
7. **Kernel**: seccomp e AppArmor/SELinux attivi (mai `unconfined`); valutazione di user namespace remapping o rootless.
8. **Log e allarmi**: exec registrate fuori dal container, allarmi sui tentativi bloccati.
9. **Test di fuga e test ostili dal modello**: tutti superati, integrati in CI.
10. **Piano di risposta**: come si ferma l'agente (kill switch), come si isola il container, chi viene avvisato.

## Fallimenti tipici e come li riconosci

- **Il socket di Docker "temporaneo".** Montato per un test e mai rimosso: lo trova il test di fuga, o un attaccante.
- **Root "perché altrimenti non funziona".** Un tool che richiede root di solito richiede solo permessi su una directory: si risolve con la proprietà dei volumi, non con root.
- **`seccomp=unconfined` o `--privileged` per risolvere un errore.** Il sintomo di un problema non capito, che diventa una porta aperta.
- **Rete di default condivisa.** Il container dei tool risolve per nome `postgres` e `n8n`: tutto su una rete. Si vede dal test di raggiungibilità.
- **Password nell'ambiente.** Un output dell'agente contiene una stringa che somiglia a un token: il sandbox aveva segreti nelle variabili d'ambiente.
- **Percorsi che escono dalla directory.** File letti o scritti fuori da `/data`: validazione assente o basata su stringhe invece che su percorsi risolti.
- **Nessun log dei tentativi bloccati.** Dopo un incidente non si sa se era il primo tentativo o il centesimo.

## Quando NON farlo

- **Se l'agente non ha bisogno di eseguire comandi**, non dargli uno strumento che lo fa. La maggior parte dei compiti aziendali si risolve con tool specifici che chiamano API, senza shell e senza filesystem. La miglior sandbox è quella che non serve.
- **Se il compito richiede di eseguire codice arbitrario generato dal modello**, i controlli di questo articolo non bastano da soli: serve un runtime con isolamento più forte (kernel applicativo o micro-VM), ambienti effimeri distrutti dopo ogni esecuzione, e nessun dato sensibile nell'ambiente.
- **Non esporre l'agente con capacità di esecuzione a input non fidati** (email esterne, documenti di terzi, pagine web) senza separare i ruoli: l'agente che legge input esterni non deve essere lo stesso che esegue comandi.
- **Non considerare l'hardening un sostituto dell'approvazione umana** per le azioni irreversibili importanti: le due cose si sommano.

## Checklist operativa

- [ ] Nessun `docker.sock`, `--privileged`, host network/PID, mount dell'host o `SYS_ADMIN`.
- [ ] Utente non-root con UID dedicato; valutati user namespace remapping o Docker rootless.
- [ ] Root filesystem in sola lettura; tmpfs con `noexec,nosuid,nodev`.
- [ ] Input montati in sola lettura; una sola directory di output scrivibile.
- [ ] `cap_drop: ALL`, `no-new-privileges`, limiti di PID, memoria e CPU.
- [ ] Immagine minimale con versione e digest fissati.
- [ ] Rete interna senza uscita; proxy con allowlist per i domini necessari.
- [ ] Nessun accesso diretto a database e servizi interni; API intermedia con operazioni predefinite.
- [ ] Nessun segreto nell'ambiente o nel filesystem del sandbox.
- [ ] Allowlist di tool, niente shell, percorsi confinati, timeout, ambiente pulito.
- [ ] Deny list come allarme; azioni distruttive con cestino, soglie e approvazione.
- [ ] seccomp e AppArmor/SELinux attivi, mai `unconfined`.
- [ ] Exec e tentativi bloccati registrati fuori dal container, con allarmi.
- [ ] Test di fuga e test ostili in CI; audit completato prima del go-live.

## Il verdetto

Un agente che può eseguire comandi sul server è, dal punto di vista della sicurezza, un programma che esegue istruzioni ricevute da testi che non controlli. Trattarlo come un assistente fidato perché "il prompt dice di non fare danni" significa affidare il server a una frase. Il giorno in cui un tool `rm` non è uno scherzo — per un errore o per una manipolazione — il danno sarà esattamente quello che i privilegi del processo permettono.

La risposta è la stessa che si dà a qualsiasi codice non fidato, applicata con rigore: **niente root, niente socket di Docker**, filesystem in sola lettura con una sola area di scrittura, nessuna capability, rete interna senza uscita e senza accesso diretto ai dati, nessun segreto nell'ambiente, **tool in allowlist senza shell**, seccomp e AppArmor attivi, ogni esecuzione registrata e ogni tentativo bloccato allarmato. E poi la verifica: test di fuga e test ostili prima del go-live e a ogni modifica.

Nessuna di queste misure rende l'agente più intelligente. Lo rendono **contenuto**: quando sbaglia, sbaglia dentro una scatola che hai progettato tu.

Se stai per dare a un agente la possibilità di agire su file e sistemi e vuoi farlo senza consegnargli il server, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Si parte dall'inventario di ciò che l'agente può davvero toccare.

## FAQ

### Perché un agente AI non dovrebbe girare come root?
Perché il danno che può fare un comando sbagliato o manipolato dipende dai privilegi del processo che lo esegue. Il modello non è un confine di sicurezza: una prompt injection o un errore possono portarlo a eseguire comandi indesiderati. Con un utente non-root, filesystem in sola lettura e nessuna capability, lo stesso comando fallisce o resta confinato.

### Cosa c'è di male nel montare docker.sock nel container dell'agente?
Chi può comunicare con il socket di Docker può chiedere al demone di avviare un container privilegiato con il filesystem dell'host montato: equivale ad avere root sull'host. Qualsiasi altro hardening del container diventa irrilevante. Per riavviare servizi o leggere log si usa un'API intermedia ristretta a quelle operazioni.

### Quali opzioni Docker usare per isolare un agente?
Utente non-root, read_only per il filesystem, tmpfs con noexec per l'area temporanea, volumi di input in sola lettura e una sola directory di output scrivibile, cap_drop ALL, no-new-privileges, profili seccomp e AppArmor attivi, limiti di PID, memoria e CPU, immagine minimale con versione fissata e rete interna senza uscita.

### Cosa sono gli user namespace in Docker e servono davvero?
Con il remapping degli user namespace o con Docker rootless, l'utente root dentro il container corrisponde a un utente senza privilegi sull'host. Se un attaccante riuscisse a uscire dal container, non avrebbe i privilegi di root sull'host. È una configurazione del demone con alcune incompatibilità da verificare, ma è un livello di difesa utile per host dedicati ad agenti che eseguono comandi.

### Basta una deny list di comandi pericolosi?
No. I modi per ottenere lo stesso effetto di un comando vietato sono innumerevoli: alias, codifiche, linguaggi di scripting. La difesa principale è un'allowlist di strumenti specifici eseguiti senza shell, con argomenti validati. La deny list è utile come secondo livello e soprattutto come fonte di allarmi sui tentativi sospetti.

### Perché non dare all'agente una shell bash libera?
Perché la shell interpreta pipe, redirezioni, sostituzioni di comando e variabili, e la superficie è impossibile da controllare filtrando la stringa. Meglio strumenti tipizzati che il codice traduce in esecuzioni senza shell, con eseguibili a percorso assoluto, percorsi confinati, ambiente pulito e timeout.

### Come si impedisce all'agente di accedere al database?
Mettendo il container che esegue i tool su una rete interna separata da quella del database, e facendo passare l'accesso ai dati da un servizio intermedio che espone solo operazioni predefinite con permessi minimi. Le credenziali del database stanno in quel servizio, non nell'ambiente del sandbox.

### Cosa bisogna registrare delle esecuzioni dell'agente?
Identificativo della richiesta e della conversazione, utente per conto del quale agiva, nome del tool e argomenti effettivi, riferimento al ragionamento del modello, codice di uscita, durata, estratto dell'output con i segreti mascherati e soprattutto i tentativi bloccati. I log vanno inviati fuori dal container, fuori dalla portata dell'agente, con allarmi sui tentativi anomali.

### Cosa sono i test di fuga?
Sono controlli eseguiti dall'interno del container per verificare che ciò che non dovrebbe essere possibile fallisca davvero: scrivere sul filesystem di sistema, eseguire file da /tmp, raggiungere Internet o il database, trovare segreti nell'ambiente, accedere al socket di Docker, montare filesystem, generare processi senza limite. Vanno eseguiti prima del go-live e a ogni modifica dell'immagine o della configurazione.

### Serve gVisor o una micro-VM per un agente?
Per un agente che usa un insieme chiuso di strumenti, i controlli standard di Docker ben configurati sono di solito sufficienti. Se l'agente deve eseguire codice arbitrario generato dal modello, conviene un isolamento più forte come un kernel applicativo o una micro-VM, con ambienti effimeri distrutti dopo ogni esecuzione e nessun dato sensibile al loro interno.
