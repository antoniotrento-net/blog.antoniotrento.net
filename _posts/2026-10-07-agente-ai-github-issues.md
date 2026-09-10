---
lang: it
permalink: /it/blog/agente-ai-github-issues/
title: "Smetti di seppellire i task dell'agente in ChatGPT: come far scrivere GitHub Issues (o GitLab) senza gh CLI e senza copincolla"
date: 2026-10-07 07:30:00 +0200
author: "Antonio Trento"
description: "Far scrivere Issue GitHub/GitLab a un agente AI via API, senza gh CLI e senza copincolla: issue come contratto, token fine-grained a privilegio minimo, template dal contesto, idempotenza anti-duplicato e triage umano. Il backlog in chat è debito."
keywords: ["agente ai github issues", "github api issues automazione", "backlog agenti", "tracker vs chat", "fine-grained token github", "idempotenza issue"]
image: /assets/images/posts/agente-ai-github-issues.jpg
pillar: agenti-esecuzione
related: [/it/blog/mcp-salesforce-agente-produzione/, /it/blog/tool-calling-loop-infinito/]
---

## Il backlog dentro una chat è debito che non vedi

Hai un agente che analizza i log, trova un bug, propone un fix. Oppure un assistente che, mentre lavori, sputa fuori "cose da fare": aggiungi un test, aggiorna la dipendenza, sistema quel campo. E dove finiscono questi task? Sepolti dentro una conversazione di ChatGPT, in mezzo a mille altri messaggi, senza stato, senza responsabile, senza scadenza. Due giorni dopo non li ritrovi. Due settimane dopo non esistono più. Hai trasformato lavoro reale in messaggi effimeri, e ti sei costruito un **backlog invisibile** che è puro debito.

La soluzione non è "un prompt migliore": è mettere i task dove i task vivono, cioè in un **tracker**. Questo pezzo è su come far scrivere all'**agente AI le Issue di GitHub** (o GitLab) via API — con un template serio, i label giusti, un corpo riproducibile e l'idempotenza sul titolo — **senza dipendere dalla `gh` CLI installata e senza copincolla manuale.** L'angolo è process engineering: non "l'AI che fa magie", ma l'AI che alimenta il tuo processo di lavoro invece di seppellirlo in una chat.

La tesi in una riga: **la chat non ha stato, assignee e SLA; l'issue sì.** Un task che conta va in un sistema che ha un ciclo di vita, non in un flusso di messaggi che scorre via. Vediamo come costruirlo, con i confini giusti — perché un agente che apre issue è, a tutti gli effetti, un agente che esegue azioni, con i rischi che ne derivano.

È lo stesso principio di controllo che ho descritto mettendo {{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}: l'agente scrive su un sistema esterno tramite API, con privilegi minimi e idempotenza. Cambia il sistema (un tracker invece di un CRM), non la disciplina.

## La chat non ha stato, assignee, SLA

Partiamo dal perché il tracker batte la chat, concretamente, perché è la base di tutto. Un task ha bisogno di proprietà che una conversazione non ha e non può avere:

- **Stato.** Un'issue è aperta o chiusa, in lavorazione o in attesa. Una riga in una chat è… una riga in una chat. Non sai se è fatta, presa in carico, o dimenticata.
- **Assignee.** Un'issue ha un responsabile. In chat, "qualcuno dovrebbe sistemare X" non è assegnato a nessuno, quindi non lo fa nessuno.
- **Label e priorità.** Bug, feature, urgente, `needs-triage`: un'issue si classifica e si filtra. In chat, tutto ha lo stesso peso visivo, cioè nessuno.
- **SLA e scadenze.** Un tracker può avere milestone, date, escalation. La chat no.
- **Ricercabilità e storico.** Cerchi un'issue per titolo, label, autore, stato. Cerchi in una chat lunga sei mesi… buona fortuna.
- **Notifiche e integrazioni.** Un'issue notifica gli interessati, si collega ai commit, alle PR, alle pipeline. La chat è un'isola.

Il **tracker vs chat** non è una preferenza estetica: è la differenza tra un task che *esiste come oggetto gestibile* e un task che *è solo testo passato*. Ogni volta che un output azionabile dell'agente resta in chat, hai perso un pezzo di lavoro. La chat è ottima per pensare e conversare; è pessima come sistema di gestione del lavoro. Confonderle è il debito silenzioso di cui parla il titolo.

Quindi la mossa: l'agente non "ti dice" cosa fare in chat. **Apre un'issue.** Con un corpo fatto bene, un label, e senza duplicati. Il resto dell'articolo è come farlo con criterio.

## Issue come contratto: riproduzione, accettazione, log

Un'issue aperta male è quasi inutile quanto un messaggio in chat. "Fixare il bug del login" non è un task: è un promemoria vago. Un'issue è un **contratto**: dice cosa c'è che non va, come riprodurlo, e come si capisce che è risolto. Un agente che apre issue deve produrre contratti, non promemoria.

Gli elementi di un'issue-contratto:

- **Contesto riproducibile:** in quale repo, quale file, quale ambiente, con quali passi si manifesta il problema. Un bug senza riproduzione è un'ipotesi, non un task.
- **Log ed evidenze:** l'errore reale, l'estratto di log rilevante (redatto della PII, come sempre), il comportamento osservato vs atteso.
- **Criterio di accettazione:** come si capisce che è fatto. "Il login funziona" è vago; "l'utente con 2FA attivo completa il login senza errore 500, verificato con il test X" è un contratto.
- **Riferimenti:** il commit, la PR, il documento, l'altro issue collegato.

Un esempio di **body markdown** che l'agente genera dal contesto — copiabile come template:

```markdown
## Problema
Errore 500 al login per utenti con 2FA attivo, a partire dal deploy `a1b2c3d`.

## Contesto
- Repo: `azienda/portale`
- File sospetto: `auth/twofactor.py:87`
- Ambiente: produzione (anche staging dopo il deploy citato)

## Riproduzione
1. Utente con 2FA attivo
2. Login con credenziali valide
3. Inserimento codice OTP corretto
4. → risposta 500 invece del redirect alla dashboard

## Log (estratto, redatto)
```
[ERROR] twofactor.py:87 KeyError: 'totp_window' — utente [ID_REDATTO]
```

## Comportamento atteso
Redirect alla dashboard dopo OTP corretto.

## Criterio di accettazione
- [ ] Login con 2FA completa senza 500
- [ ] Test di regressione aggiunto per il caso `totp_window` mancante

## Riferimenti
- Deploy sospetto: commit `a1b2c3d`
- Metrica osservabilità: picco 500 su `/auth/verify` dalle 14:32

<!-- agent-key: 2fa-login-500-a1b2c3d -->
```

Nota il commento finale `agent-key`: è la **chiave di idempotenza** (ci torno). E nota che tutto il corpo è generato *dal contesto reale* — repo, file, log, metrica — non inventato. Un agente che apre issue con questo livello di dettaglio produce lavoro utilizzabile; uno che apre "c'è un problema al login" produce solo rumore da triage.

## Auth: token fine-grained, privilegio minimo, mai un PAT da admin

Qui si gioca la sicurezza, ed è la parte che chi improvvisa sbaglia di più. Per far scrivere issue all'agente serve un'autenticazione verso GitHub/GitLab. La regola è una sola e non negoziabile: **privilegio minimo.**

Cosa NON fare, mai: dare all'agente un **Personal Access Token classico con scope pieno** (`repo`, o peggio permessi da amministratore). Quel token può leggere e scrivere *tutto* il codice, cancellare repo, modificare impostazioni. Se finisce nei log, in un prompt injection, o in un errore, hai regalato le chiavi dell'intero account. Un agente che deve solo aprire issue non ha alcun bisogno di toccare il codice.

Cosa fare invece:

- **GitHub: fine-grained personal access token** (o, meglio ancora in team, una **GitHub App**) limitato ai **repo specifici** e con il **solo permesso Issues: Read and write**. Niente contenuti, niente amministrazione, niente altro.
- **GitLab: project access token** con scope minimo (tipicamente `api` limitato al progetto, o i permessi più stretti che consentono la creazione di issue), sul singolo progetto, non a livello di gruppo/istanza.
- **Scadenza breve** sul token, rotazione periodica, e archiviazione in un vault/secret manager — mai hardcoded nel codice o nel compose.

La tabella dei permessi minimi:

| Piattaforma | Credenziale | Ambito | Permesso |
|-------------|-------------|--------|----------|
| GitHub | Fine-grained PAT / GitHub App | Solo i repo interessati | **Issues: write** (nient'altro) |
| GitHub | ~~PAT classico `repo`~~ | ~~tutto l'account~~ | ❌ troppo ampio |
| GitLab | Project access token | Singolo progetto | scope minimo per creare issue |
| GitLab | ~~PAT personale admin~~ | ~~tutta l'istanza~~ | ❌ mai |

Il principio: **il token dell'agente deve poter fare solo la cosa che l'agente fa.** Aprire issue su repo X = permesso "issues write" su repo X. Se un giorno quel token trapela, il danno massimo è "qualcuno può aprire issue su un repo", non "qualcuno controlla il mio codice". È la differenza tra un graffio e una catastrofe, e costa solo scegliere il token giusto. Lo stesso ragionamento di least-privilege che vale per ogni agente che tocca un sistema esterno.

## Niente dipendenza dalla gh CLI: usa l'API REST

Un errore pratico diffuso: costruire l'automazione sopra la **`gh` CLI** (o `glab`). Funziona sulla tua macchina, dove `gh` è installato e autenticato. Poi la sposti su un altro PC, su un container, su una macchina Windows senza `gh`, su un server headless — e si rompe, perché dipende da un binario esterno e da un'autenticazione interattiva che lì non c'è.

La strada robusta e portabile: **chiamare direttamente l'API REST.** È solo HTTP con un token nell'header. Funziona identica su Windows, macOS, Linux, in un container, ovunque ci sia rete — **senza `gh` installato, senza copincolla.**

Creare un'issue via API, in Python con `requests` (nessuna dipendenza da CLI):

```python
import requests, os

def crea_issue(repo: str, titolo: str, body: str, labels: list[str]) -> dict:
    """Crea una issue GitHub via REST. Nessuna gh CLI, gira ovunque."""
    token = os.environ["GH_ISSUES_TOKEN"]      # fine-grained, solo issues:write
    r = requests.post(
        f"https://api.github.com/repos/{repo}/issues",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        json={"title": titolo, "body": body, "labels": labels},
        timeout=15,
    )
    r.raise_for_status()
    return r.json()
```

Per GitLab è lo stesso schema, con l'endpoint `POST /projects/:id/issues` e il token in header. Il punto architetturale: **l'integrazione col tracker è una chiamata HTTP, non un wrapper attorno a un binario.** Così è testabile, portabile, e non ti si rompe il giorno che gira su una macchina "pulita". La `gh` CLI è comoda per l'uso interattivo umano; per l'automazione, l'API diretta è la scelta da ingegnere.

## Idempotenza: non aprire 12 issue uguali

Questo è il fallimento che rende un agente-che-apre-issue un incubo invece di un aiuto. L'agente rileva lo stesso problema a ogni esecuzione — ogni ora, ogni run — e apre **una issue nuova ogni volta.** In un giorno hai dodici issue identiche per lo stesso bug, e il triage diventa impossibile. L'automazione ben intenzionata è diventata spam.

La difesa è l'**idempotenza sul contenuto**: prima di creare un'issue, controlla se ne esiste già una per lo *stesso problema*, e in quel caso non crearne un'altra — al massimo aggiungi un commento o aggiorni. La chiave è un identificatore **stabile e deterministico** del problema, non il testo variabile.

Il pattern che uso: una **chiave d'agente** (`agent-key`) derivata dal problema, inserita nel corpo (o in un'etichetta), e una ricerca prima della creazione.

```python
import hashlib

def agent_key(repo: str, tipo: str, firma: str) -> str:
    """Chiave stabile del problema: stesso problema => stessa chiave."""
    raw = f"{repo}|{tipo}|{firma}"           # es. firma = file+errore normalizzati
    return "ak-" + hashlib.sha256(raw.encode()).hexdigest()[:12]

def apri_o_aggiorna(repo: str, titolo: str, body: str, labels: list[str],
                    key: str) -> dict:
    token = os.environ["GH_ISSUES_TOKEN"]
    h = {"Authorization": f"Bearer {token}",
         "Accept": "application/vnd.github+json"}
    # 1. cerca una issue APERTA con la stessa chiave nel corpo
    q = f'repo:{repo} is:issue is:open in:body "{key}"'
    found = requests.get("https://api.github.com/search/issues",
                         headers=h, params={"q": q}, timeout=15).json()
    if found.get("total_count", 0) > 0:
        num = found["items"][0]["number"]
        # esiste già: commenta invece di duplicare
        requests.post(f"https://api.github.com/repos/{repo}/issues/{num}/comments",
                      headers=h, json={"body": "Rilevato di nuovo. (auto)"},
                      timeout=15)
        return {"stato": "duplicato_evitato", "numero": num}
    # 2. non esiste: crea, con la chiave nel corpo
    body_con_key = f"{body}\n\n<!-- agent-key: {key} -->"
    return crea_issue(repo, titolo, body_con_key, labels)
```

La **regola anti-duplicato**: la chiave è derivata dagli elementi *stabili* del problema (repo, tipo, firma dell'errore normalizzata: file + tipo di eccezione), non da elementi variabili (timestamp, ID di run, numeri che cambiano). Così lo stesso bug produce sempre la stessa chiave, la ricerca lo trova, e non nasce un doppione. Se cambia davvero qualcosa di sostanziale, cambia la chiave e nasce una issue nuova — che è corretto.

L'idempotenza qui è la stessa idea che protegge dai doppi side effect altrove: un'azione con effetto esterno (creare un'issue) deve essere sicura da ripetere. Ne ho parlato per le scritture su CRM e per i retry: ripetere non deve moltiplicare.

## L'architettura di riferimento

Ecco come dispongo il flusso, con i confini. Nota che l'agente **propone** issue, non gestisce il progetto.

```
   Agente rileva task/bug ──▶ ┌──────────────────────────────────┐
                              │ COSTRUZIONE ISSUE                  │
                              │ template + labels + contesto reale │
                              │ + agent-key (idempotenza)          │
                              └───────────────┬────────────────────┘
                                              ▼
                              ┌──────────────────────────────────┐
                              │ IDEMPOTENZA: cerca issue aperta    │
                              │ con la stessa agent-key            │
                              └──────┬──────────────────┬──────────┘
                                esiste│           non esiste
                                     ▼                  ▼
                        ┌──────────────────┐  ┌────────────────────────┐
                        │ commenta/aggiorna │  │ CREA via REST API       │
                        │ (no duplicato)    │  │ token fine-grained      │
                        └──────────────────┘  │ issues:write, label      │
                                              │ needs-triage             │
                                              └───────────┬──────────────┘
                                                          ▼
                              ┌──────────────────────────────────┐
                              │ TRIAGE UMANO (needs-triage)        │
                              │ accetta nel backlog / chiude       │
                              └──────────────────────────────────┘

   Metriche: aperte / chiuse / duplicate evitate / chiuse-come-invalide
```

**Cosa NON fa mai l'agente (i confini):**

- Non tocca il **codice**: il token può solo scrivere issue, non contenuti né impostazioni.
- Non **assegna, chiude, prioritizza** al posto dell'umano: apre e mette `needs-triage`. Il ciclo di vita lo governa una persona.
- Non apre **duplicati**: l'idempotenza lo impedisce.
- Non fa entrare le sue issue direttamente nel backlog "vero": restano `needs-triage` finché un umano non le accetta.

Questa separazione — l'agente propone un'issue, l'umano la accetta nel lavoro — è la stessa filosofia "AI propone, umano dispone" del controllo dei side effect: l'issue creata dall'agente è una *proposta di task*, non un task già approvato.

## Review umana: il label needs-triage

Il rischio di un agente che apre issue è inondare il backlog di task non verificati, alcuni ottimi, altri rumore. La soluzione non è fidarsi ciecamente né bloccare tutto: è il **triage**. Ogni issue creata dall'agente nasce con il label **`needs-triage`**, che significa: "questa è una proposta automatica, un umano deve validarla prima che diventi lavoro".

Il flusso di triage:

- L'agente apre l'issue con `needs-triage` (e magari `bot-created`, per distinguerla).
- Un umano, nel suo giro di triage, la guarda: è un problema vero? È già noto? È azionabile? 
- Se sì: toglie `needs-triage`, aggiunge i label reali (priorità, area), eventualmente assegna. Ora è lavoro accettato.
- Se no: la chiude (come `invalid`, `duplicate`, `wontfix`). È un segnale che l'agente ha prodotto rumore, da usare per tararlo.

Perché `needs-triage` è essenziale: **tiene separato ciò che l'agente propone da ciò che il team ha deciso di fare.** Senza, il backlog si riempie di roba automatica indistinguibile da quella decisa dagli umani, e nessuno si fida più del backlog. Con, le proposte dell'agente sono chiaramente marcate e passano da un cancello umano. È il minimo di governo che rende sostenibile avere un agente che scrive nel tracker.

## Un secondo caso: dal feedback del cliente all'issue tracciata

Il pattern non serve solo per i bug tecnici. Funziona identico — ed è forse ancora più utile — per trasformare input non strutturati in lavoro tracciato. Prendi il feedback dei clienti: arriva via email, chat di supporto, form. Oggi si perde negli stessi buchi neri della chat. Un agente può leggerlo, capire se contiene una richiesta azionabile (un bug segnalato, una feature richiesta, un problema ricorrente) e aprire un'issue-contratto con lo stesso rigore.

La differenza rispetto al caso-bug è nella **firma** che genera la `agent-key`: non file+errore, ma il *tema* del feedback normalizzato. Così dieci clienti che segnalano lo stesso problema di UX non generano dieci issue, ma **una issue con dieci conferme** (i commenti che l'idempotenza aggiunge invece di duplicare). Questo è oro per il prodotto: vedi *quante* persone chiedono la stessa cosa, non un elenco di doppioni indistinguibili. L'idempotenza qui non evita solo lo spam: aggrega il segnale.

Il resto della disciplina è identico: token a privilegio minimo, corpo-contratto (cosa chiede il cliente, contesto, criterio di accettazione), label `needs-triage` più magari `da-feedback`, redaction dei dati personali del cliente (nome, email non vanno nel corpo dell'issue in chiaro — un riferimento all'ID ticket sì). Un secondo dominio, stessa architettura.

### Aprire un'issue ≠ risolverla: il confine da tenere

Un chiarimento che evita il malinteso più pericoloso. Far *aprire* issue all'agente è un'operazione a basso rischio: la peggiore conseguenza di un errore è un'issue sbagliata che un umano chiude in triage. Tutt'altra cosa è far *risolvere* le issue all'agente — auto-commit, auto-PR, auto-merge. Quello è un agente che tocca il codice, con rischi di un altro ordine di grandezza, e richiede tutti i controlli dei side effect pesanti: revisione obbligatoria, test, approvazione umana sulla PR, mai merge automatico su rami protetti.

Tienili separati, anche nei permessi: il token che *apre* issue ha `Issues: write` e nient'altro. Un eventuale agente che *propone fix* ha una credenziale diversa, con permessi diversi (aprire PR, mai mergere), e passa da un flusso di review completo. Confondere i due — dare all'agente-issue anche la capacità di scrivere codice "già che c'è" — è esattamente il tipo di privilegio ampio che questo pezzo ti dice di evitare. L'agente che alimenta il backlog e l'agente che scrive codice sono due mestieri diversi, con due livelli di rischio diversi, e due token diversi.

## Percorso di implementazione, a step

1. **Crea la credenziale a privilegio minimo:** fine-grained PAT o GitHub App con solo `Issues: write` sui repo interessati (o project access token GitLab minimo). In un vault, non hardcoded.
2. **Implementa la creazione via API REST**, non via `gh` CLI, così gira ovunque.
3. **Definisci il template** dell'issue-contratto: problema, contesto, riproduzione, log redatti, criterio di accettazione, riferimenti.
4. **Genera il corpo dal contesto reale** (repo, file, errore, metrica), mai da testo inventato.
5. **Aggiungi l'idempotenza:** una `agent-key` stabile derivata dagli elementi invarianti del problema, con ricerca prima della creazione.
6. **Metti `needs-triage`** (e `bot-created`) su ogni issue creata dall'agente.
7. **Redigi la PII** nei log e nel corpo prima di scrivere l'issue (le issue sono spesso pubbliche o viste da molti).
8. **Traccia le metriche:** aperte, chiuse, duplicate evitate, chiuse-come-invalide.
9. **Definisci il giro di triage** umano e chi lo fa.
10. **Testa** con problemi ripetuti (deve evitare i duplicati) e con la macchina "pulita" senza `gh` (deve funzionare comunque).

## Le metriche: aperte vs chiuse vs duplicate

Un agente che apre issue va misurato, o non sai se aiuta o inquina. Le metriche che contano:

- **Issue aperte dall'agente** (per periodo): il volume di proposte.
- **Chiuse come valide / risolte:** le proposte che sono diventate lavoro utile. È il segnale di qualità positivo.
- **Chiuse come invalide / wontfix / duplicate:** il rumore. Se questa quota è alta, l'agente propone male e va tarato (o il template è troppo permissivo).
- **Duplicate evitate dall'idempotenza:** quante volte la `agent-key` ha impedito un doppione. Un numero alto qui è *positivo*: significa che il meccanismo lavora (e che senza, avresti avuto spam).
- **Tempo in `needs-triage`:** quanto restano le proposte prima di essere validate. Se crescono, il triage non regge il ritmo dell'agente.

```sql
-- Salute dell'agente-issue (da un log locale delle creazioni)
SELECT
  date_trunc('week', creata_il) AS settimana,
  COUNT(*)                                          AS aperte,
  COUNT(*) FILTER (WHERE esito='risolta')           AS risolte,
  COUNT(*) FILTER (WHERE esito IN ('invalid','wontfix','duplicate')) AS rumore,
  SUM(duplicate_evitate)                            AS dedup
FROM agent_issues
GROUP BY 1 ORDER BY 1 DESC;
```

La lettura: **un agente-issue sano ha molte risolte, poco rumore, e un buon numero di duplicate evitate.** Se il rumore cresce, il problema non è "l'AI è scema": è che il template o i criteri di apertura sono troppo larghi. Le metriche ti dicono dove tarare, invece di litigare con l'agente a colpi di prompt.

## I fallimenti tipici e come li riconosci dai log

- **Spam di duplicati.** Molte issue identiche per lo stesso problema: l'idempotenza non funziona o la `agent-key` include elementi variabili (un timestamp, un run-id). Controlla che la chiave sia derivata solo da elementi stabili.
- **Issue vaghe, tutte chiuse come invalid.** Alta quota di `invalid`/`wontfix`: il template è troppo permissivo o l'agente apre su segnali deboli. Stringi i criteri di apertura e arricchisci il contratto (riproduzione, accettazione).
- **403 / permission denied dall'API.** Il token non ha il permesso giusto sul repo, o è scaduto. Nei log vedi il 403: verifica scope e scadenza del fine-grained token.
- **429 rate limit.** L'agente chiama l'API troppo spesso (magari cerca duplicati a ogni micro-evento): applica backoff e batch. GitHub/GitLab hanno limiti; rispettali.
- **Dipendenza da `gh` che si rompe altrove.** "Funziona sul mio PC" ma non in container/Windows: è la CLI mancante. Il passaggio all'API REST elimina la classe.
- **PII nel corpo dell'issue.** Un'issue può essere vista da molti (o essere pubblica): se il corpo contiene dati personali dai log, è un problema. Redigi prima di scrivere. Audita un campione di issue create.
- **`needs-triage` che si accumula.** Se la coda di triage cresce senza fine, l'agente apre più di quanto il team validi: alza i criteri di apertura o riduci la frequenza.

La regola: **traccia le creazioni in un log locale** (con esito, chiave, duplicate evitate). Così le metriche e la diagnosi non dipendono dal recuperare tutto a posteriori dall'API del tracker.

## Ripulire dopo un incident di duplicati

Prevenire è meglio, ma può capitare di ereditare (o causare) il disastro: l'agente è girato senza idempotenza per un giorno e ha aperto duecento issue quasi identiche. Il backlog è illeggibile e chiuderle a mano è improponibile. Ecco come si esce, in ordine.

1. **Ferma l'agente, prima di tutto.** Disattiva il job che apre issue. Finché gira senza idempotenza, ogni ora peggiora. È l'equivalente del kill switch: spegni la sorgente prima di pulire.
2. **Identifica i duplicati per un tratto comune.** Le issue-spam hanno di solito un pattern riconoscibile: lo stesso label `bot-created`, un titolo che si ripete, una frase nel corpo. Usa la ricerca dell'API per elencarle tutte con un filtro (`is:issue is:open label:bot-created created:>=DATA`).
3. **Scegli la "canonica" e chiudi le altre.** Tieni aperta una issue rappresentativa (la più completa), e chiudi le altre in massa via API con un commento che rimanda alla canonica (`duplicato di #N`). Un ciclo sull'elenco filtrato lo fa in pochi secondi, senza toccarle a mano.
4. **Applica l'idempotenza retroattivamente.** Prima di riaccendere l'agente, aggiungi la `agent-key` alla issue canonica (nel corpo), così quando l'agente riparte trova quella e non ne apre un'altra. Hai "adottato" il duplicato sopravvissuto come issue ufficiale del problema.
5. **Riaccendi con l'idempotenza attiva** e verifica su un problema noto che ora commenti invece di duplicare.
6. **Postmortem breve:** l'idempotenza mancava, o la chiave includeva un elemento variabile? Aggiungi il caso al test, così non si ripete.

La chiusura di massa via API, in pratica:

```python
# Chiudi in massa i duplicati, lasciando la canonica aperta
def chiudi_duplicati(repo: str, canonica: int, numeri: list[int]):
    token = os.environ["GH_ISSUES_TOKEN"]
    h = {"Authorization": f"Bearer {token}",
         "Accept": "application/vnd.github+json"}
    for n in numeri:
        if n == canonica:
            continue
        requests.post(f"https://api.github.com/repos/{repo}/issues/{n}/comments",
                      headers=h, json={"body": f"Duplicato di #{canonica}. (cleanup)"},
                      timeout=15)
        requests.patch(f"https://api.github.com/repos/{repo}/issues/{n}",
                       headers=h, json={"state": "closed",
                                        "state_reason": "not_planned"}, timeout=15)
```

La lezione dell'incident: **l'idempotenza non è un'ottimizzazione, è un requisito.** Un agente che scrive in un sistema condiviso senza idempotenza è una macchina per generare rumore, e ripulire costa molto più che progettarla dall'inizio. Ma se è già successo, la via d'uscita è metodica, non manuale: filtra, chiudi in massa, adotta la canonica, riaccendi protetto.

## Costi: ordini di grandezza

Stime dichiarate.

- **API del tracker:** creare issue via API GitHub/GitLab è **gratuito** nei piani normali (rientra nei limiti di rate). Nessun costo per chiamata; il vincolo è il rate limit, non l'euro.
- **Token LLM per generare il corpo:** l'agente usa il modello per formattare il problema nel template. Come ordine di grandezza, frazioni di centesimo per issue con un modello self-hosted, poco più con un'API cloud. Trascurabile per volumi normali.
- **Sviluppo:** template, chiamata API, idempotenza, metriche e triage, come ordine di grandezza **una-due giornate/uomo**. Investimento una tantum.
- **Il risparmio vero:** il tempo *non* perso a ripescare task dalle chat, e i task che *non* vengono dimenticati. Difficile da quantificare in euro, enorme in pratica: un task perso è lavoro rifatto o un bug che torna. L'automazione qui ripaga in disciplina di processo, non in bolletta.
- **Costo del non farlo:** il backlog invisibile in chat — lavoro che evapora, bug che ricompaiono, nessuna tracciabilità. È debito che si accumula in silenzio.

## Quando NON farlo

- **Se l'agente apre issue vaghe o su segnali deboli**, non attivarlo finché il template non produce contratti veri: un backlog pieno di rumore è peggio di nessun backlog automatico. Meglio poche issue ottime che tante inutili.
- **Se non puoi dare un token a privilegio minimo** (solo issue, solo quei repo), fermati: non dare mai a un agente un PAT ampio "per comodità". Il privilegio minimo è la precondizione, non un optional.
- **Se non c'è nessuno che fa triage**, le proposte dell'agente si accumulano senza diventare lavoro. Serve un cancello umano; se non c'è la capacità di triage, riduci la frequenza o non attivare.
- **Se il task è una cosa da fare subito, in autonomia, da te** — non ogni pensiero merita un'issue. L'agente-issue serve per i task che *devono sopravvivere alla conversazione*, non per la lista della spesa del minuto.
- **Se il tracker non è il posto giusto** (task personali, note fugaci): usa lo strumento adatto. L'issue è per il lavoro condiviso e tracciabile, non per tutto.

## Checklist operativa prima di andare live

- [ ] **Token a privilegio minimo:** fine-grained PAT / GitHub App con solo `Issues: write` sui repo giusti (o project token GitLab minimo), in un vault.
- [ ] **Creazione via API REST**, non `gh` CLI: gira su Windows/macOS/Linux/container.
- [ ] **Template issue-contratto:** problema, contesto, riproduzione, log redatti, criterio di accettazione, riferimenti.
- [ ] **Corpo generato dal contesto reale**, mai inventato.
- [ ] **Idempotenza** con `agent-key` stabile (solo elementi invarianti) e ricerca prima della creazione.
- [ ] **`needs-triage`** (e `bot-created`) su ogni issue dell'agente.
- [ ] **PII redatta** nel corpo e nei log prima della scrittura.
- [ ] **Backoff e rispetto del rate limit** dell'API.
- [ ] **Metriche:** aperte, risolte, rumore, duplicate evitate, tempo in triage.
- [ ] **Giro di triage** umano definito, con un responsabile.
- [ ] **Test** con problema ripetuto (no duplicati) e su macchina senza `gh` (funziona comunque).

## Il verdetto

Seppellire i task dell'agente in una chat è il modo più elegante per perderli. La chat non ha stato, non ha assignee, non ha SLA, non ha storia ricercabile: è ottima per pensare, pessima per gestire il lavoro. I task che contano vanno dove i task vivono — in un tracker — e far scrivere all'**agente AI le Issue di GitHub** o GitLab via API è il modo per alimentare il tuo processo invece di seppellirlo in un flusso di messaggi.

Ma va fatto da ingegnere, non da entusiasta. L'issue è un contratto: problema, riproduzione, criterio di accettazione, non un promemoria vago. L'autenticazione è a privilegio minimo — un token che può *solo* aprire issue su *quei* repo, mai un PAT ampio che regala il codice. L'integrazione è via API REST, non via `gh` CLI, così gira ovunque senza copincolla. L'idempotenza, con una chiave stabile, impedisce i dodici duplicati che trasformano l'aiuto in spam. E il label `needs-triage` tiene separato ciò che l'agente propone da ciò che il team ha deciso di fare: l'AI propone il task, l'umano lo accetta.

Fatto così, hai un agente che trasforma i suoi output in lavoro tracciabile, senza inondare il backlog e senza toccare il codice. Fatto male — task in chat, o un bot con un token da admin che apre duplicati a raffica — hai barattato un debito invisibile con uno visibile e rumoroso. La differenza non è l'AI. È se hai trattato l'issue per quello che è: un contratto in un sistema con un ciclo di vita, non un messaggio in una conversazione che scorre via.

Se hai agenti che producono task e vuoi che finiscano in un tracker come si deve — con privilegi minimi, idempotenza e triage — invece che sepolti in una chat, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Process engineering, non slide.

## FAQ

### Perché non lasciare i task dell'agente in chat, se poi li leggo io?
Perché la chat non ha stato, assignee, priorità, scadenze né ricercabilità: un task lì è solo testo che scorre via. Due giorni dopo non lo ritrovi, e nessuno sa se è stato fatto. Un tracker dà al task un ciclo di vita (aperto/chiuso/assegnato) e lo rende un oggetto gestibile. I task che contano devono sopravvivere alla conversazione, e la chat non lo garantisce.

### Che token uso per far aprire issue all'agente?
Un token a privilegio minimo: su GitHub un fine-grained PAT (o una GitHub App) limitato ai repo interessati con il solo permesso `Issues: write`; su GitLab un project access token con lo scope minimo sul singolo progetto. Mai un PAT classico con scope `repo` pieno o permessi da admin: un token del genere, se trapela, dà accesso a tutto il codice. L'agente che apre issue non deve poter toccare altro.

### Perché non usare la gh CLI, che è comoda?
Perché crea una dipendenza da un binario esterno e da un'autenticazione interattiva che non esistono su un'altra macchina, su Windows senza `gh`, o in un container headless. "Funziona sul mio PC" e si rompe altrove. L'API REST è solo HTTP con un token: gira identica ovunque, è testabile e portabile. La `gh` CLI va benissimo per l'uso umano interattivo; per l'automazione, l'API diretta è più robusta.

### Come evito che l'agente apra dodici issue uguali?
Con l'idempotenza: prima di creare, cerchi se esiste già un'issue aperta per lo stesso problema, usando una chiave stabile (`agent-key`) derivata dagli elementi invarianti (repo, tipo, firma dell'errore normalizzata), non da timestamp o run-id. Se la trovi, commenti o aggiorni invece di duplicare. Così lo stesso problema produce sempre la stessa chiave e un solo issue, mentre un problema davvero nuovo genera una chiave diversa.

### Cosa metto nel corpo di un'issue generata dall'agente?
Un contratto, non un promemoria: descrizione del problema, contesto riproducibile (repo, file, ambiente), passi di riproduzione, log ed evidenze (redatti della PII), comportamento atteso, criterio di accettazione (come si capisce che è risolto) e riferimenti (commit, PR, metrica). Tutto generato dal contesto reale, non inventato. Un'issue così è azionabile; un "c'è un problema al login" è solo rumore da triage.

### Il label needs-triage a cosa serve?
A separare ciò che l'agente propone da ciò che il team ha deciso di fare. Ogni issue creata dall'agente nasce `needs-triage`: un umano la valida (è vera? azionabile? non è un duplicato?) prima che diventi lavoro accettato. Senza questo cancello, il backlog si riempie di proposte automatiche indistinguibili da quelle umane, e nessuno si fida più del backlog. È il minimo di governo per avere un agente che scrive nel tracker.

### Come faccio a sapere se l'agente-issue aiuta o inquina?
Con le metriche: issue aperte, chiuse come risolte (valore), chiuse come invalid/wontfix/duplicate (rumore), duplicate evitate dall'idempotenza, e tempo in triage. Un agente sano ha molte risolte, poco rumore e un buon numero di duplicate evitate. Se il rumore cresce, il template o i criteri di apertura sono troppo larghi: tari quelli, invece di litigare col prompt.

### E se l'issue contiene dati personali presi dai log?
Vanno redatti prima di scrivere l'issue, esattamente come per l'osservabilità. Un'issue può essere vista da molte persone o essere in un repo pubblico: infilarci dati personali dai log è un problema. Redigi email, IBAN, codici fiscali e simili nel corpo prima della creazione, e audita periodicamente un campione delle issue create per verificare che la redaction copra i casi reali.

### Vale anche per GitLab o solo GitHub?
Vale identico per GitLab (e per altri tracker con API). Cambia l'endpoint (`POST /projects/:id/issues`) e il tipo di token (project access token con scope minimo), ma il pattern è lo stesso: API REST invece della CLI, privilegio minimo, template-contratto, idempotenza con chiave stabile, label `needs-triage`, metriche. Il principio "process engineering, non copincolla" non dipende dalla piattaforma.

### Ogni output dell'agente dovrebbe diventare un'issue?
No. L'issue è per i task che devono sopravvivere alla conversazione ed essere tracciati e condivisi: bug, lavori da fare, follow-up. Non per ogni pensiero o nota fugace. Se apri un'issue per tutto, inondi il backlog e vanifichi il senso del tracker. Il criterio è: "questo task deve esistere come oggetto gestibile domani?" Se sì, issue; se è una cosa del momento, no.
