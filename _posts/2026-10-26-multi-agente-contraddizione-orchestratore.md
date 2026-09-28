---
lang: it
permalink: /it/blog/multi-agente-contraddizione-orchestratore/
title: "Multi-agente che si contraddice: orchestratore, blackboard e perché “più agenti” non è più intelligenza"
date: 2026-10-26 07:30:00 +0200
author: "Antonio Trento"
description: "Sistemi multi-agente in produzione: perché si contraddicono, due writer sullo stesso record, blackboard versionata, orchestratore semplice, handoff con contratto, timeout e ownership, quando un solo grafo batte lo swarm e come testare le contraddizioni."
keywords: ["multi agente contraddizione orchestratore", "multi agent orchestration", "blackboard pattern", "agent handoff", "conflitto tool", "architettura multi agente"]
image: /assets/images/posts/multi-agente-contraddizione-orchestratore.jpg
pillar: agenti-esecuzione
related: [/it/blog/langgraph-vs-n8n-vs-python/, /it/blog/kill-switch-agente-salesforce/]
---

## Il demo con 7 agenti e zero responsabilità

La presentazione è spettacolare. Sullo schermo, sette agenti con nomi e ruoli: il *Commerciale*, l'*Analista del credito*, il *Responsabile logistica*, il *Customer care*, il *Revisore*, il *Pianificatore* e un *Supervisore* che li coordina. Arriva un ordine; gli agenti si scambiano messaggi, discutono, si correggono, e alla fine l'ordine è confermato, la spedizione pianificata, il cliente informato. Il pubblico applaude. Qualcuno chiede: "Quanto ci vuole a metterlo in produzione sul nostro CRM?"

La domanda giusta sarebbe un'altra: **chi è responsabile di cosa?** Se il Commerciale concede uno sconto e l'Analista del credito blocca il cliente nello stesso momento, quale decisione vale? Se il Customer care comunica una data di consegna e la Logistica la cambia un minuto dopo, cosa è stato promesso al cliente? Se due agenti decidono indipendentemente di emettere una nota di credito, se ne emettono due? Nella demo queste domande non emergono, perché la demo ha un solo percorso, scelto perché funziona. In produzione emergono il primo giorno.

I sistemi **multi-agente** sono di moda, e l'idea ha un fascino evidente: dividere un problema complesso tra specialisti, come in un'azienda. Ma un'azienda funziona perché ha **responsabilità assegnate, procedure e un registro condiviso** di ciò che è stato deciso — non perché ha tanti dipendenti intelligenti. Senza quella struttura, più agenti significano più punti di decisione, più occasioni di contraddirsi e più difficoltà a capire chi ha fatto cosa.

Questo pezzo è un pezzo di **architettura**, con una buona dose di scetticismo verso l'entusiasmo per gli "sciami" di agenti. Vediamo come nascono le contraddizioni, perché due writer sullo stesso record sono il problema centrale, cosa sono una blackboard e uno stato condiviso versionato, perché un orchestratore semplice batte cinque agenti brillanti, come fare handoff con un contratto, come gestire timeout e ownership, quando un solo grafo è la scelta migliore e come testare le contraddizioni prima che le scopra un cliente.

## Perché "più agenti" non è più intelligenza

Prima di entrare nei dettagli, vale la pena smontare l'intuizione di fondo. L'idea che più agenti producano più intelligenza si basa su un'analogia con i gruppi umani, dove la divisione del lavoro e il confronto migliorano le decisioni. Con gli agenti LLM l'analogia regge poco, per tre ragioni.

**Gli agenti spesso non sono davvero diversi.** Sette agenti con sette prompt di ruolo che usano lo stesso modello condividono gli stessi punti ciechi. Il "Revisore" che controlla il lavoro del "Commerciale" ha le stesse tendenze, gli stessi errori sistematici, la stessa propensione a essere d'accordo con un testo ben scritto. La diversità di prospettive, che nei gruppi umani è il vero valore del confronto, qui è in gran parte di facciata.

**Ogni passaggio perde informazione.** Quando un agente passa il lavoro a un altro, lo fa con un messaggio: un riassunto di ciò che sa. Ciò che non entra nel riassunto è perso. Più passaggi, più perdita. Un singolo agente con tutto il contesto sotto mano spesso decide meglio di una catena di agenti che si passano riassunti.

**Gli errori si compongono.** Se ciascun passaggio ha una piccola probabilità di sbagliare, una catena lunga ha una probabilità alta che almeno un passaggio sbagli. E gli errori di un agente diventano l'input del successivo, che raramente li mette in discussione.

Questo non significa che più agenti siano sempre sbagliati. Ci sono casi in cui la separazione ha senso: permessi diversi (un agente legge dati sensibili, un altro no), modelli diversi (uno piccolo e veloce per smistare, uno grande per ragionare), contesti che non entrano in una sola finestra, lavori paralleli davvero indipendenti. Ma la separazione va giustificata da una di queste ragioni, non dall'idea che la conversazione tra agenti produca intelligenza.

## Conflitti: due writer sullo stesso record

Il fallimento più concreto e più costoso dei sistemi multi-agente non è filosofico: è un classico problema di **concorrenza**. Due agenti leggono lo stesso record, decidono ciascuno qualcosa, e scrivono. Il secondo sovrascrive il primo, o entrambi eseguono un'azione che doveva essere eseguita una volta sola.

Ecco un esempio di conflitto, ricostruito dai log di un sistema di gestione ordini con quattro agenti su un CRM:

```
09:14:02 [commerciale]  legge Account A-2201: fido=5000, stato=attivo, sconto=0
09:14:02 [credito]      legge Account A-2201: fido=5000, stato=attivo, esposizione=6200
09:14:09 [credito]      decide: esposizione > fido -> blocca cliente
09:14:10 [credito]      scrive Account A-2201: stato=bloccato_credito
09:14:11 [commerciale]  decide: cliente strategico -> sconto 8%, conferma ordine O-7781
09:14:12 [commerciale]  scrive Account A-2201: stato=attivo, sconto=8      <- sovrascrive il blocco
09:14:12 [commerciale]  scrive Ordine O-7781: stato=confermato
09:14:15 [customer]     legge Ordine O-7781: confermato -> invia conferma al cliente
09:14:31 [logistica]    legge Ordine O-7781: confermato -> pianifica spedizione
```

Il blocco per credito è stato cancellato senza che nessuno lo decidesse: il Commerciale ha scritto l'intero record con i valori letti prima del blocco, riportando lo stato ad "attivo". L'ordine è partito verso un cliente oltre il fido. Nessuno degli agenti ha "sbagliato" secondo il proprio ruolo; il sistema, nel complesso, ha preso una decisione che nessuno ha preso.

Varianti dello stesso problema:

- **Double spend.** Due agenti, su due richieste del cliente arrivate da canali diversi (email e chat), emettono ciascuno una nota di credito per lo stesso reso.
- **Promesse incoerenti.** Il Customer care comunica "consegna giovedì" leggendo una stima; la Logistica ripianifica a lunedì. Il cliente ha una promessa che il sistema non mantiene.
- **Policy diverse.** L'agente dei resi applica "rimborso entro 30 giorni", l'agente del customer care, con un prompt aggiornato in un momento diverso, dice "entro 14 giorni". Il cliente riceve due risposte diverse dallo stesso fornitore.
- **Ping-pong.** Un agente imposta un campo, un altro lo corregge secondo la propria regola, il primo lo reimposta: un loop tra agenti, parente stretto dei [loop sulle tool call di un singolo agente]({{ '/it/blog/tool-calling-loop-infinito/' | relative_url }}).

La soluzione non sta nel rendere gli agenti più intelligenti. Sta in due regole di architettura: **un solo writer per ogni tipo di dato** e **uno stato condiviso versionato**.

## La regola del writer unico

La regola è semplice da enunciare:

> **Per ogni entità e per ogni campo che conta, esiste uno e un solo agente (o componente) autorizzato a scriverlo. Tutti gli altri possono leggerlo e proporre modifiche, mai scriverlo.**

Nell'esempio: lo **stato di credito** del cliente lo scrive solo l'agente del credito. Lo **sconto** e la **conferma dell'ordine** li scrive solo il commerciale, ma la conferma è subordinata a una condizione che legge lo stato di credito. La **data di consegna** la scrive solo la logistica; il customer care la legge e la comunica, e non ne inventa una. La **nota di credito** la emette solo un componente, che controlla se per quel reso ne esiste già una.

La regola si applica con i permessi, non con il prompt. Se l'agente commerciale ha uno strumento che scrive l'intero record dell'Account, prima o poi sovrascriverà un campo che non è suo. Gli strumenti vanno disegnati **stretti**: `imposta_sconto(account, percentuale)` invece di `aggiorna_account(record)`. Il principio è lo stesso dei permessi minimi che descrivo nella [costituzione dell'agente in YAML]({{ '/it/blog/yaml-costituzione-agente-ai/' | relative_url }}), esteso da un agente a un sistema di agenti.

### Il diagramma di ownership

Prima di scrivere una riga di codice, disegna chi possiede cosa. Per l'esempio della gestione ordini:

```
                         ┌─────────────────────────────────────────┐
                         │           ORCHESTRATORE (codice)         │
                         │  instrada · applica precedenze · timeout │
                         └───────┬──────────┬──────────┬───────────┘
                                 │          │          │
        ┌────────────────────────┼──────────┼──────────┼──────────────────────┐
        ▼                        ▼          ▼          ▼                      ▼
 ┌─────────────┐        ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
 │ COMMERCIALE │        │   CREDITO   │ │  LOGISTICA  │ │  CUSTOMER   │ │  RESI/NC    │
 └──────┬──────┘        └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
 SCRIVE │                SCRIVE│         SCRIVE│         SCRIVE│         SCRIVE│
 sconto │           stato_credito│  data_consegna│   messaggi_cliente│   note_credito│
 ordine.stato*                 │   spedizione  │   (solo testo)    │   (idempotenti)│
        │                      │               │                   │               │
 LEGGE: stato_credito    LEGGE: esposizione  LEGGE: ordine.stato  LEGGE: tutto   LEGGE: resi, NC
        ordini                 ordini                               (sola lettura)

 * ordine.stato=confermato ammesso SOLO se stato_credito=ok (vincolo verificato dall'orchestratore
   e dal vincolo sul dato, non dal prompt del commerciale)
```

Ogni campo che conta ha **una sola freccia "scrive"**. Se nel diagramma un campo ha due frecce, hai trovato un conflitto futuro: o si sceglie un proprietario, o si introduce un componente che decide (l'orchestratore, o un umano).

## Blackboard / stato condiviso versionato

Il secondo pilastro è il modo in cui gli agenti condividono ciò che sanno. Nei sistemi multi-agente "conversazionali", gli agenti si parlano con messaggi: lo stato del lavoro è sparso in una chat tra agenti, e ricostruire cosa è stato deciso significa rileggere la conversazione. È fragile e difficile da verificare.

L'alternativa è un pattern classico dell'intelligenza artificiale, precedente agli LLM di decenni: la **blackboard**. Una lavagna condivisa, cioè uno **stato strutturato** su cui ogni agente legge ciò che gli serve e scrive i propri contributi nei campi di sua competenza. Gli agenti non si parlano direttamente: guardano la lavagna, lavorano, aggiornano la lavagna. L'orchestratore decide chi deve lavorare in base allo stato della lavagna.

Per funzionare in produzione, la blackboard deve essere:

- **Strutturata**: campi con tipo e significato, non testo libero.
- **Partizionata per proprietario**: ogni sezione ha un writer, secondo il diagramma di ownership.
- **Versionata**: ogni scrittura incrementa una versione, e una scrittura basata su una versione vecchia viene **rifiutata** (concorrenza ottimistica).
- **Storicizzata**: ogni modifica è registrata con autore, versione di partenza, motivo.

La concorrenza ottimistica è la difesa diretta contro l'esempio di prima: il Commerciale ha letto la versione 12 del caso; nel frattempo il Credito ha scritto la versione 13; quando il Commerciale prova a scrivere "partendo dalla 12", la scrittura fallisce, e il Commerciale deve rileggere, vedere il blocco e ridecidere.

```python
import json
from dataclasses import dataclass

PROPRIETARI = {                               # il diagramma di ownership, in codice
    "credito.stato": "credito",
    "commerciale.sconto": "commerciale",
    "ordine.stato": "commerciale",
    "logistica.data_consegna": "logistica",
    "nc.emesse": "resi",
}

class ConflittoVersione(Exception): ...
class ScritturaNonAutorizzata(Exception): ...

@dataclass
class Scrittura:
    agente: str
    campo: str
    valore: object
    versione_letta: int
    motivo: str

def scrivi(db, caso_id: str, s: Scrittura) -> int:
    if PROPRIETARI.get(s.campo) != s.agente:
        raise ScritturaNonAutorizzata(f"{s.agente} non possiede {s.campo}")
    with db.transaction():
        cur = db.execute("SELECT versione, stato FROM blackboard WHERE caso_id=%s FOR UPDATE", (caso_id,))
        versione, stato = cur.fetchone()
        if versione != s.versione_letta:
            raise ConflittoVersione(f"letto v{s.versione_letta}, attuale v{versione}: rileggi e ridecidi")
        stato = json.loads(stato)
        stato[s.campo] = s.valore
        if s.campo == "ordine.stato" and s.valore == "confermato" and stato.get("credito.stato") != "ok":
            raise ScritturaNonAutorizzata("conferma ordine senza credito ok")      # vincolo sul dato
        db.execute("UPDATE blackboard SET stato=%s, versione=versione+1 WHERE caso_id=%s",
                   (json.dumps(stato), caso_id))
        db.execute("INSERT INTO blackboard_storia(caso_id, versione, agente, campo, valore, motivo) "
                   "VALUES (%s,%s,%s,%s,%s,%s)",
                   (caso_id, versione + 1, s.agente, s.campo, json.dumps(s.valore), s.motivo))
    return versione + 1
```

Tre cose da notare. La **proprietà dei campi** è verificata dal codice, non dal prompt. Il **conflitto di versione** costringe a rileggere invece di sovrascrivere. I **vincoli tra campi** (niente conferma senza credito ok) stanno vicino al dato, dove nessun agente può aggirarli.

Quando la blackboard riflette un sistema esterno come un CRM, la stessa logica si applica alle scritture verso quel sistema: un solo componente scrive nel CRM, prendendo le decisioni dalla blackboard, con controlli sulla versione del record dove il sistema lo consente (molti CRM espongono una data di ultima modifica o un identificativo di versione da confrontare prima di scrivere).

## Un orchestratore stupido è meglio di 5 geni

Nei sistemi multi-agente alla moda, il coordinamento è a sua volta affidato a un agente LLM: un "supervisore" che decide chi deve parlare, legge le risposte e sceglie il passo successivo. Sembra naturale. In produzione è spesso la parte più fragile del sistema.

Un supervisore LLM:

- **non è deterministico**: lo stesso caso può essere instradato in modo diverso in due esecuzioni;
- **può dimenticare passaggi**: saltare il controllo del credito perché "sembrava evidente";
- **aggiunge costo e latenza** a ogni passo;
- **è difficile da testare**: la logica di coordinamento è implicita in un prompt.

L'alternativa che consiglio è un **orchestratore "stupido"**: codice ordinario, o un grafo esplicito, che instrada in base allo stato della blackboard con regole leggibili. "Se c'è un nuovo ordine e il credito non è ancora valutato, chiama l'agente del credito. Se il credito è ok e lo sconto non è deciso, chiama il commerciale. Se l'ordine è confermato, chiama la logistica; poi il customer care." Non c'è niente di intelligente, ed è esattamente il punto: il coordinamento è **prevedibile, verificabile e testabile**. L'intelligenza la mettono gli agenti nei singoli passi, dove serve giudizio: leggere un'email ambigua, valutare una richiesta di sconto, scrivere un messaggio al cliente.

Le **precedenze** tra decisioni sono parte dell'orchestratore, scritte in chiaro: il blocco per credito prevale sullo sconto; una decisione umana prevale su quella di qualsiasi agente; in caso di conflitto non risolvibile, si ferma e si chiede a una persona.

Framework come LangGraph permettono di esprimere questo tipo di coordinamento come grafo di stati esplicito; ma anche un motore di workflow come n8n o poche centinaia di righe di Python vanno benissimo. Ho confrontato le tre strade nel pezzo su [LangGraph, n8n o Python]({{ '/it/blog/langgraph-vs-n8n-vs-python/' | relative_url }}); qui conta il principio: **il coordinamento è codice, il giudizio è modello**.

## Handoff con contratto (schema)

Quando un agente passa il lavoro a un altro — o all'orchestratore — il passaggio deve avvenire con un **contratto**: una struttura dati con campi definiti, validata, non un messaggio in linguaggio naturale. Il motivo è lo stesso per cui si usano schemi rigidi per le chiamate agli strumenti: il testo libero perde informazioni, introduce ambiguità e non si può validare.

Un contratto di handoff per la valutazione del credito:

```python
from pydantic import BaseModel, Field
from typing import Literal
from datetime import datetime

class EsitoCredito(BaseModel):
    """Output dell'agente credito verso la blackboard. Nessun altro campo è accettato."""
    caso_id: str
    versione_letta: int
    account_id: str = Field(pattern=r"^A-\d{4,}$")
    decisione: Literal["ok", "bloccato", "serve_umano"]
    esposizione_eur: float = Field(ge=0)
    fido_eur: float = Field(ge=0)
    motivazione: str = Field(max_length=500)
    fonti: list[str] = Field(min_length=1)          # id dei documenti/estratti consultati
    confidenza: Literal["alta", "media", "bassa"]
    scade_il: datetime                             # dopo questa data la valutazione va rifatta

    model_config = {"extra": "forbid"}
```

Il contratto ottiene diversi risultati insieme:

- l'orchestratore può **validare** l'output e rifiutarlo se malformato, invece di propagare un errore;
- la **decisione** è un valore chiuso, non una frase da interpretare ("direi che si può procedere, con cautela" non esiste);
- esiste un'uscita esplicita per **chiedere a un umano** (`serve_umano`), invece di costringere l'agente a decidere;
- la **scadenza** evita che una valutazione vecchia venga usata per una decisione nuova;
- le **fonti** permettono di ricostruire il ragionamento in un audit.

La tecnica per ottenere output conformi dai modelli — output strutturato, validazione, ritentativi limitati — è la stessa che descrivo per gli [schemi JSON nel tool calling]({{ '/it/blog/json-schema-tool-calling-iban/' | relative_url }}).

## Timeout e ownership

In un sistema con più agenti, qualcosa prima o poi si blocca: un agente che attende una risposta da un sistema esterno, un modello lento, un passaggio che nessuno raccoglie. Senza regole, il caso resta sospeso, e nessuno se ne accorge finché il cliente non chiama.

Due meccanismi:

**Ownership del caso.** In ogni momento, ogni caso ha **un proprietario** — un agente, l'orchestratore o una persona — scritto sulla blackboard. Il proprietario è responsabile di farlo avanzare. Quando passa il lavoro, l'ownership passa esplicitamente, con il contratto di handoff. Un caso senza proprietario è un errore di sistema, non uno stato possibile.

**Lease con timeout.** L'ownership di un agente è un **lease**: vale per un tempo definito. Se l'agente non completa il suo passo entro la scadenza, l'orchestratore riprende il caso e decide: ritentare, passare a un'alternativa, o **scalare a una persona**. Nessun caso resta in mano a un agente bloccato.

```
caso O-7781
  v14  owner=credito     lease_fino=09:16:00   (valutazione in corso)
  09:16:00 lease scaduto -> orchestratore: ritento 1/2
  v15  owner=credito     lease_fino=09:18:00
  09:18:00 lease scaduto -> orchestratore: scalo
  v16  owner=umano:ufficio_crediti   motivo="credito: 2 timeout, esposizione > fido"
```

Il valore dei timeout va scelto per tipo di passo: secondi per un passo di classificazione, minuti per uno che interroga sistemi lenti, ore o giorni per un'approvazione umana. E ogni scalata a una persona passa per una **coda di approvazione** con il contesto completo, come quella descritta nel pezzo sull'[human-in-the-loop su PEC e SEPA]({{ '/it/blog/human-in-the-loop-pec-sepa/' | relative_url }}).

## Idempotenza: l'antidoto al double spend

Una nota a parte per le azioni che non devono essere ripetute: emettere una nota di credito, disporre un pagamento, inviare una comunicazione formale. Con più agenti, più canali e ritentativi automatici, una stessa azione può essere richiesta più volte. La difesa è l'**idempotenza**: ogni azione ha una **chiave** che la identifica in modo univoco (per esempio `nc:reso:R-3312`), e il componente che la esegue verifica se esiste già un'azione con quella chiave prima di eseguirla. Se esiste, restituisce l'esito precedente invece di ripeterla.

La chiave non deve dipendere dall'agente che chiede o dal canale: deve dipendere dall'**oggetto di business** (il reso, la fattura, il pagamento). Così due agenti che chiedono la nota di credito per lo stesso reso ottengono la stessa nota, non due. E il **kill switch** globale, che ho descritto per gli [agenti che scrivono su Salesforce]({{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }}), resta valido anche qui: un solo interruttore che ferma le scritture di tutti gli agenti, non uno per agente.

## Quando un solo grafo batte lo swarm

Prima di progettare un sistema multi-agente, conviene chiedersi se non basta **un solo agente dentro un grafo di passi espliciti**: un flusso con nodi definiti (classifica, recupera dati, valuta credito, decidi sconto, pianifica, comunica), dove alcuni nodi chiamano un modello e altri sono codice. È "multi-passo", non "multi-agente", ed è la scelta migliore nella maggioranza dei processi aziendali.

| Criterio | Un grafo con passi espliciti | Più agenti autonomi |
|----------|------------------------------|---------------------|
| Prevedibilità | alta: percorso definito | bassa: percorso emergente |
| Test | per nodo e per percorso | difficili, combinatorie |
| Debug | si segue il grafo | si ricostruiscono conversazioni |
| Costo | chiamate solo dove serve | chiamate di coordinamento aggiuntive |
| Contraddizioni | rare: uno stato, un flusso | frequenti senza blackboard e ownership |
| Flessibilità su casi imprevisti | limitata ai rami previsti | maggiore, a prezzo di imprevedibilità |
| Quando conviene | processi con passi noti | permessi, modelli o contesti davvero separati |

Separare in più agenti ha senso quando:

- **i permessi devono essere diversi**: l'agente che legge le email dei clienti (input non fidato) non deve avere accesso agli strumenti di pagamento, secondo la logica di isolamento che serve contro la prompt injection;
- **i modelli devono essere diversi**: un modello piccolo e locale per classificare dati sensibili, uno più capace per compiti di ragionamento su dati non sensibili;
- **il contesto non entra**: compiti che richiedono grandi quantità di documenti diversi, meglio gestiti da agenti con contesti separati che producono sintesi strutturate;
- **il lavoro è davvero parallelo e indipendente**: analizzare dieci documenti diversi senza che le analisi si influenzino.

In tutti questi casi, comunque, gli agenti restano **nodi di un grafo coordinato da codice**, con blackboard, ownership e contratti. Lo "sciame" autonomo in cui gli agenti si organizzano da soli è un'idea interessante per la ricerca; per un processo che scrive nei sistemi di un'azienda, è un rischio senza un beneficio che lo giustifichi.

## Dalla demo a un sistema: cosa resta dei sette agenti

Proviamo ad applicare tutto questo ai sette agenti della demo iniziale. È un esercizio che faccio spesso quando un progetto nasce da una dimostrazione, e il risultato è quasi sempre simile.

- **Supervisore**: sostituito da un orchestratore in codice. Le regole di instradamento stavano in un prompt di una pagina; diventano una ventina di righe leggibili e una tabella di precedenze.
- **Pianificatore**: eliminato. Il suo lavoro era decidere l'ordine dei passi, che in un processo di gestione ordini è noto in anticipo ed è ora nel grafo.
- **Revisore**: trasformato da agente a **controlli deterministici** (vincoli sui dati, validazione dei contratti, confronto tra messaggio al cliente e stato finale) più una coda di revisione umana per i casi segnalati. Un secondo modello che rilegge il lavoro del primo aggiungeva costo e poca sicurezza.
- **Credito**: resta un passo separato, con un proprio agente, perché legge dati finanziari che gli altri non devono vedere. Ha una ragione di permessi.
- **Customer care**: resta, perché legge le email dei clienti, cioè input non fidato, e per questo **non** ha strumenti di scrittura sul CRM: produce solo testi e proposte strutturate. Ha una ragione di isolamento.
- **Commerciale e Logistica**: diventano nodi del grafo con strumenti stretti. Il giudizio del modello serve per valutare richieste di sconto non standard e per interpretare vincoli di consegna scritti in linguaggio libero; il resto è codice.

Risultato: da sette agenti a tre punti in cui un modello esprime un giudizio, un orchestratore deterministico, una blackboard e due code umane. Meno chiamate al modello per caso, quindi costi e latenza più bassi; un percorso che si può testare; e, soprattutto, un diagramma di ownership in cui ogni campo ha un solo proprietario. La demo era più spettacolare. Il sistema si può mettere in produzione.

## Test di contraddizione

Un sistema multi-agente va testato anche per ciò che è specifico dei sistemi multi-agente: le contraddizioni. Non basta verificare che ogni agente, da solo, faccia bene il suo lavoro. Servono scenari costruiti per provocare conflitti:

- **Scritture concorrenti**: due agenti ricevono nello stesso momento input che li portano a scrivere sullo stesso caso. Il test verifica che una delle due scritture fallisca per conflitto di versione e che l'esito finale sia coerente con le precedenze.
- **Richieste duplicate**: la stessa richiesta arriva da due canali. Il test verifica che l'azione irreversibile venga eseguita una volta sola (idempotenza).
- **Policy disallineate**: due agenti che consultano la stessa regola devono dare la stessa risposta. Il test pone la stessa domanda a entrambi e confronta le risposte, e verifica che la regola venga da **una fonte unica** (un documento, una tabella), non da due prompt scritti in momenti diversi.
- **Promesse incoerenti**: dopo ogni esecuzione, si confronta ciò che è stato comunicato al cliente con lo stato finale dei dati. "Hai detto giovedì, la spedizione è pianificata lunedì" è un fallimento.
- **Timeout**: un agente viene fatto bloccare di proposito; il test verifica che il lease scada, che il caso venga ripreso e che, dopo i ritentativi, arrivi a una persona.
- **Campi senza proprietario**: un test statico verifica che ogni strumento di scrittura tocchi solo campi di cui l'agente è proprietario secondo il diagramma, e che nessun campo abbia due proprietari.

Questi scenari entrano nella batteria di valutazione e nel gate di rilascio come quelli dei singoli agenti. La metodologia — stato atteso, perimetro protetto, side-effect score — è quella descritta nel pezzo su [come valutare un agente in produzione]({{ '/it/blog/valutazione-agenti-llm-produzione/' | relative_url }}), con un'aggiunta: lo stato atteso riguarda anche la **coerenza tra agenti**.

## Percorso di implementazione, a step

1. **Parti da un grafo con un solo agente** e passi espliciti. Aggiungi agenti solo quando una delle ragioni valide (permessi, modelli, contesto, parallelismo) lo richiede.
2. **Disegna il diagramma di ownership**: ogni campo che conta con un solo writer.
3. **Progetta la blackboard**: stato strutturato, partizionato per proprietario, versionato, storicizzato.
4. **Scrivi gli strumenti stretti**: ogni strumento scrive solo i campi del proprio agente.
5. **Implementa l'orchestratore in codice**, con precedenze esplicite e un'uscita verso le persone.
6. **Definisci i contratti di handoff** con schemi validati e decisioni a valori chiusi.
7. **Aggiungi ownership e lease** con timeout per tipo di passo e scalata.
8. **Rendi idempotenti** le azioni irreversibili, con chiavi legate agli oggetti di business.
9. **Centralizza le policy** in una fonte unica consultata da tutti gli agenti.
10. **Scrivi i test di contraddizione** e mettili nel gate di rilascio.

## Fallimenti tipici e come li riconosci

- **Decisioni che "spariscono".** Un blocco, un'approvazione, una nota che nessuno ha annullato risulta annullata: nella storia della blackboard (o nei log del CRM) una scrittura successiva ha riportato il campo al valore precedente. Due writer, o strumenti che scrivono l'intero record.
- **Azioni doppie.** Due note di credito, due email, due pagamenti per lo stesso oggetto: manca l'idempotenza o la chiave dipende dal canale.
- **Casi fermi.** Casi senza avanzamento da ore, con un proprietario che non risponde: mancano i lease o la scalata.
- **Risposte diverse alla stessa domanda.** Reclami del tipo "mi avete detto due cose diverse": policy duplicate nei prompt invece che in una fonte unica.
- **Costi che crescono più del volume.** Molte chiamate di coordinamento, conversazioni tra agenti che si allungano: un supervisore LLM che "discute" invece di instradare.
- **Debug impossibile.** Per capire perché un ordine è stato confermato bisogna leggere cento messaggi tra agenti: manca uno stato strutturato con storia.

## Quando NON farlo

- **Se il processo ha passi noti**, non costruire un sistema multi-agente: un grafo con passi espliciti e un solo agente dove serve giudizio è più semplice, più economico e più affidabile.
- **Se la motivazione è la demo**, fermati: il fascino di vedere agenti che "parlano tra loro" non è un requisito di business.
- **Se non puoi assegnare un proprietario a ogni campo**, non introdurre un altro agente che scrive: prima risolvi chi decide.
- **Se non hai tracciamento e storia dello stato**, non aggiungere agenti: ogni agente in più moltiplica la difficoltà di capire cosa è successo.
- **Se gli agenti userebbero lo stesso modello, gli stessi permessi e lo stesso contesto**, probabilmente sono un solo agente con più prompt: trattali come passi di un grafo.

## Checklist operativa

- [ ] Ragione esplicita per ogni agente separato (permessi, modello, contesto, parallelismo).
- [ ] Diagramma di ownership con un solo writer per ogni campo che conta.
- [ ] Strumenti di scrittura stretti, limitati ai campi del proprietario.
- [ ] Blackboard strutturata, versionata, con concorrenza ottimistica e storia.
- [ ] Vincoli tra campi verificati vicino al dato, non nei prompt.
- [ ] Orchestratore in codice o grafo esplicito, con precedenze scritte.
- [ ] Contratti di handoff con schemi validati e un'uscita "serve umano".
- [ ] Ownership del caso sempre definita; lease con timeout e scalata.
- [ ] Azioni irreversibili idempotenti, con chiavi legate agli oggetti di business.
- [ ] Policy in una fonte unica.
- [ ] Kill switch unico per tutte le scritture.
- [ ] Test di contraddizione nel gate di rilascio.

## Il verdetto

Più agenti non significa più intelligenza. Significa più punti di decisione, più passaggi in cui l'informazione si perde e più occasioni di contraddirsi. Nella demo con sette agenti tutto funziona perché il percorso è uno; in produzione, dove i percorsi sono migliaia e gli eventi arrivano insieme, un **sistema multi-agente** senza struttura produce decisioni che nessuno ha preso: blocchi cancellati, azioni doppie, promesse incoerenti.

La struttura che serve non è nuova. È quella di qualsiasi sistema concorrente ben progettato, e di qualsiasi organizzazione che funziona: **un solo writer per ogni dato**, uno **stato condiviso versionato** su cui si lavora invece di una chat tra agenti, un **orchestratore semplice** che instrada con regole leggibili, **handoff con contratto**, **ownership e timeout** perché nessun caso resti sospeso, **idempotenza** sulle azioni irreversibili, e **test** costruiti apposta per provocare le contraddizioni.

Con questa struttura, gli agenti diventano ciò che dovrebbero essere: componenti con un giudizio limitato a un compito, dentro un sistema che resta prevedibile. E spesso si scopre che ne bastano meno di quanti ne prevedeva la demo — a volte uno solo, dentro un buon grafo.

Se stai valutando un'architettura multi-agente per i tuoi processi, o ne hai una che si contraddice, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Si parte dal diagramma di ownership: chi scrive cosa.

## FAQ

### Perché un sistema multi-agente si contraddice?
Perché più agenti prendono decisioni indipendenti sugli stessi dati, spesso leggendo stati diversi in momenti diversi e con regole scritte in prompt diversi. Senza un proprietario unico per ogni dato, uno stato condiviso versionato e un coordinamento esplicito, le decisioni si sovrascrivono o si duplicano, e il risultato finale non corrisponde a nessuna decisione consapevole.

### Più agenti rendono il sistema più intelligente?
Di norma no. Agenti che usano lo stesso modello condividono gli stessi punti ciechi, ogni passaggio tra agenti perde informazione e gli errori si compongono lungo la catena. La separazione in più agenti ha senso per ragioni concrete — permessi diversi, modelli diversi, contesti che non entrano in una finestra, lavori paralleli indipendenti — non come fonte di intelligenza.

### Cos'è la regola del writer unico?
Per ogni entità e campo rilevante esiste un solo agente o componente autorizzato a scriverlo; gli altri possono leggerlo o proporre modifiche. Si applica con i permessi e con strumenti di scrittura stretti, limitati ai campi di competenza, non con le istruzioni nel prompt.

### Cos'è il pattern blackboard?
È un pattern in cui gli agenti non si parlano direttamente, ma leggono e scrivono su uno stato condiviso strutturato, la "lavagna". Un coordinatore decide chi deve lavorare in base allo stato. In produzione la blackboard deve essere strutturata, partizionata per proprietario, versionata con concorrenza ottimistica e storicizzata, così ogni decisione è tracciabile.

### Come si evita che due agenti sovrascrivano lo stesso record?
Con la concorrenza ottimistica: ogni scrittura dichiara la versione dello stato da cui è partita, e viene rifiutata se nel frattempo lo stato è cambiato. L'agente deve rileggere e ridecidere. A questo si aggiungono la regola del writer unico e strumenti che scrivono singoli campi invece dell'intero record.

### Meglio un supervisore LLM o un orchestratore in codice?
Per processi aziendali, un orchestratore in codice o un grafo esplicito: è prevedibile, testabile e costa meno. Un supervisore LLM può instradare in modo diverso lo stesso caso, saltare passaggi e aggiunge chiamate. Il giudizio del modello va usato dentro i singoli passi dove serve, non per decidere l'ordine dei passi.

### Cos'è un handoff con contratto?
È il passaggio di lavoro tra agenti attraverso una struttura dati definita e validata — per esempio con Pydantic o JSON Schema — invece che con un messaggio in linguaggio naturale. Il contratto fissa campi, tipi, decisioni a valori chiusi, fonti, scadenza e un'uscita esplicita per chiedere l'intervento di una persona.

### Come si gestiscono i casi bloccati?
Assegnando sempre un proprietario al caso e dando a ogni agente un lease con timeout: se il passo non si completa entro la scadenza, l'orchestratore riprende il caso, ritenta un numero limitato di volte e poi lo scala a una persona tramite una coda di approvazione con il contesto completo.

### Come si evita il double spend tra agenti?
Rendendo idempotenti le azioni irreversibili: ogni azione ha una chiave legata all'oggetto di business (il reso, la fattura, il pagamento), e il componente che la esegue verifica se esiste già un'azione con quella chiave prima di procedere. Due richieste per lo stesso oggetto producono una sola azione.

### Come si testano le contraddizioni in un sistema multi-agente?
Con scenari costruiti per provocarle: scritture concorrenti sullo stesso caso, richieste duplicate da canali diversi, la stessa domanda posta a agenti diversi, confronto tra ciò che è stato comunicato al cliente e lo stato finale, blocchi simulati per verificare timeout e scalata, e controlli statici che nessun campo abbia due proprietari. Questi test entrano nel gate di rilascio.
