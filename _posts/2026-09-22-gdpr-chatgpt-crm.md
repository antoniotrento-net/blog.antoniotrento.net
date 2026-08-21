---
lang: it
permalink: /it/blog/gdpr-chatgpt-crm/
alt_url: /en/blog/gdpr-chatgpt-crm/
title: "Mettere ChatGPT nel CRM è un data leak: cosa dice il GDPR (e l'AI Act) se i prompt contengono clienti italiani"
date: 2026-09-22 07:30:00 +0200
author: "Antonio Trento"
description: "Il commerciale incolla l'opportunity su ChatGPT per farsi scrivere una mail. In quel gesto ci sono dati di clienti italiani che escono dall'UE. Cosa dice davvero il GDPR, e la checklist da portare al tuo DPO."
keywords: ["gdpr chatgpt crm", "ai act pmi", "trasferimento dati openai", "dpa llm", "titolare responsabile trattamento"]
image: /assets/images/posts/gdpr-chatgpt-crm.jpg
pillar: modelli-costi-privacy
related: [/it/blog/n8n-self-hosted-openai-privacy/, /it/blog/vllm-vs-ollama-produzione/]
---

## Lo scenario che succede ogni giorno nella tua azienda

Il tuo commerciale ha una trattativa importante e deve scrivere una mail delicata. Apre ChatGPT e incolla: "scrivimi una mail per Mario Rossi di Acme Srl, P.IVA 01234567890, che ha un'opportunity da 45.000 € ferma perché ha detto che il nostro prezzo è troppo alto rispetto al concorrente X, e che l'anno scorso aveva già avuto un problema di consegna". Trenta secondi dopo ha la sua mail, ben scritta. È contento. E ha appena fatto uscire dall'azienda — verso un server negli Stati Uniti — nome, azienda, partita IVA, importo, strategia commerciale e storia di un cliente reale. Questo, dal punto di vista del GDPR, **è un trattamento di dati personali con trasferimento extra-UE**, fatto senza base giuridica, senza che tu lo sappia, decine di volte al giorno, da persone che pensano di star solo "usando l'AI per lavorare meglio".

Il tema `gdpr chatgpt crm` non è teorico: è quello che succede *ora* in migliaia di PMI italiane, ed è un data leak silenzioso che nessuno ha deciso ma che tutti stanno facendo. Prima di tutto un avviso onesto: **questo non è un parere legale.** Non sono un avvocato, sono un system architect. Questo è un articolo tecnico-procedurale per capire i confini del problema e — soprattutto — una **checklist da portare al tuo DPO o al tuo consulente**, che il parere formale te lo daranno loro. Vediamo chi è OpenAI nella tua filiera dei dati, perché "abbiamo attivato la regione UE" non chiude il tema, cosa deve finire nel registro dei trattamenti e nella DPIA, quali misure tecniche riducono il rischio, cosa cambia con l'AI Act, come si scrive una policy interna che i dipendenti seguano davvero, e qual è l'alternativa sovrana. Con la traccia di policy di una pagina, l'elenco dei dati che non devono **mai** entrare in un prompt cloud, e i riferimenti ai principi del GDPR da mettere sul tavolo del legale.

## Titolare, responsabile, sub-responsabile: chi è OpenAI nella tua filiera

Prima di tutto i ruoli, perché senza è impossibile ragionare. Il GDPR distingue:

- **Il titolare del trattamento** (data controller): chi decide *perché* e *come* si trattano i dati. Sei **tu**, l'azienda. La responsabilità principale è tua, sempre — anche quando usi strumenti di altri.
- **Il responsabile del trattamento** (data processor, art. 28): chi tratta i dati *per conto* del titolare, seguendo le sue istruzioni. Quando mandi dati a un fornitore di LLM cloud, quel fornitore agisce come responsabile. E l'art. 28 richiede un **accordo sul trattamento dei dati (DPA)** che regoli questa relazione: cosa può fare, per quanto, con quali garanzie.
- **I sub-responsabili** (sub-processor): i fornitori *del* tuo fornitore (l'infrastruttura cloud su cui gira, altri servizi a valle). Anche loro fanno parte della filiera, e le garanzie devono estendersi a loro.

Il punto che quasi nessuno interiorizza: **il titolare resti tu.** Usare ChatGPT non "trasferisce" la responsabilità a OpenAI. Se i dati dei tuoi clienti finiscono dove non dovevano, il primo a risponderne davanti al Garante sei tu, il titolare — non il fornitore dello strumento. La domanda operativa quindi è: *quando un mio dipendente incolla dati clienti in un LLM cloud, ho un rapporto da art. 28 con quel fornitore? Ho un DPA? So chi sono i sub-responsabili? Ho dato istruzioni documentate?* Se la risposta è "il commerciale usa il suo account personale di ChatGPT", allora **non hai niente di tutto questo**, e i dati stanno uscendo senza alcuna cornice giuridica. È lo stesso problema di confine dei dati che ho affrontato per i [workflow n8n che esfiltrano verso il cloud]({{ '/it/blog/n8n-self-hosted-openai-privacy/' | relative_url }}), qui visto dal lato della filiera delle responsabilità.

## "Ma abbiamo il toggle EU": perché non chiude il tema

La difesa che sento più spesso è: "tranquillo, abbiamo attivato l'opzione con i dati in Europa". È un passo utile, ma **non chiude il tema**, e credere che lo faccia è pericoloso. Ecco perché.

- **La residenza dei dati è una cosa, la relazione di trattamento un'altra.** Anche se i dati sono processati in regione UE, stai comunque affidando dati personali a un responsabile del trattamento. Ti serve comunque il DPA, le istruzioni documentate, la valutazione dei sub-responsabili. Il "dove" non elimina il "chi" e il "come".
- **La filiera può comunque toccare l'extra-UE.** Il fornitore può avere una casa madre o sub-responsabili soggetti a leggi extra-UE. La questione dei **trasferimenti verso paesi terzi** (il capo del GDPR sui trasferimenti, art. 44 e seguenti) non si spegne con un toggle: va valutata sulla filiera reale, e spesso richiede garanzie specifiche.
- **Il training e la retention.** Il punto che pesa davvero: i tuoi input vengono usati per addestrare i modelli? Restano loggati, e per quanto? Un piano consumer e un piano business con opt-out dal training sono mondi diversi. Il toggle sulla regione non dice nulla di questo.
- **Chi lo sta usando come?** Il toggle EU sull'account aziendale non serve a niente se i dipendenti usano i **loro account personali** di ChatGPT, dove nessuna di queste garanzie si applica. Ed è esattamente quello che succede quando non c'è una policy (più avanti).

La sintesi onesta: la regione UE è **necessaria ma non sufficiente**. È un ingrediente, non la ricetta. La ricetta completa — DPA, opt-out dal training, valutazione dei sub-responsabili e dei trasferimenti, istruzioni documentate, e il controllo su *chi* usa *cosa* — è quella che il tuo DPO deve verificare. Chi ti dice "abbiamo il toggle EU quindi siamo a posto" sta semplificando un tema che non si lascia semplificare.

## Cosa deve finire nel registro dei trattamenti e nella DPIA

Se usi (o lasci usare) LLM su dati di clienti, due documenti ti riguardano, e vanno preparati *con* il DPO — qui do la traccia operativa, il contenuto formale è loro.

**Il registro dei trattamenti.** Se l'uso di LLM su anagrafiche e opportunity è un trattamento sistematico, deve comparirci. In pratica devi poter descrivere: *quali* dati passano dall'LLM, *per quale finalità*, con *quale base giuridica*, verso *quale responsabile* (il fornitore), con *quali* garanzie sui trasferimenti, e per *quanto* i dati restano. Se non sai riempire queste caselle, non è che il registro è incompleto: è che il trattamento è fuori controllo.

**La DPIA (valutazione d'impatto).** Quando un trattamento presenta rischi elevati per i diritti delle persone, il GDPR richiede una valutazione d'impatto. Usare LLM cloud su grandi anagrafiche di clienti, con profilazione o decisioni, può ricadere in questo. Nella DPIA, con il DPO, andrà ragionato: *quali rischi* (esposizione dei dati, uso per training, decisioni automatizzate), *quali misure* per ridurli (le prossime), e *se il rischio residuo è accettabile*. La DPIA non è un modulo da compilare per dovere: è il posto dove decidi, nero su bianco, se questo uso dell'AI sta in piedi.

I principi del GDPR da tenere presenti mentre lo fai — da citare al legale, non da interpretare da soli:

- **Art. 5** — i principi generali: liceità, **minimizzazione** (non mandare più dati del necessario), limitazione delle finalità e della conservazione. La minimizzazione, da sola, taglia gran parte del problema: perché il prompt contiene la P.IVA se per scrivere la mail non serve?
- **Art. 28** — il rapporto col responsabile: serve il DPA.
- **Art. 32** — la **sicurezza** del trattamento: misure tecniche e organizzative adeguate (mascheramento, controllo accessi, log).
- **Art. 44 e seguenti** — i **trasferimenti** verso paesi terzi: le garanzie per far uscire i dati dall'UE.

Questi articoli sono le colonne su cui il DPO costruirà il parere. Il tuo compito, da titolare, è portargli un quadro tecnico chiaro di cosa succede davvero — ed è ciò che questo articolo ti aiuta a costruire.

## Le misure tecniche: mascheramento, opt-out training, tenant, log minimi

Il GDPR (art. 32) chiede misure tecniche adeguate. Ecco quelle che riducono davvero il rischio quando un LLM tocca dati di clienti, in ordine di efficacia.

**Il mascheramento (redaction) prima del prompt.** La misura più potente e la più sottovalutata: rimuovere i dati identificativi *prima* che il testo raggiunga il modello. Ecco un blocklist-filtro di esempio che intercetta i dati che non devono uscire, da mettere tra l'app e l'LLM cloud:

```python
import re

# Dati che NON devono entrare in un prompt cloud senza mascheramento.
# Blocca o maschera prima dell'invio.
VIETATI = {
    "CF":    re.compile(r"\b[A-Z]{6}\d{2}[A-EHLMPRST]\d{2}[A-Z]\d{3}[A-Z]\b"),
    "PIVA":  re.compile(r"\b\d{11}\b"),
    "IBAN":  re.compile(r"\bIT\d{2}[A-Z]\d{10}[0-9A-Z]{12}\b"),
    "EMAIL": re.compile(r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b"),
    "TEL":   re.compile(r"\b(?:\+39\s?)?3\d{2}[\s.\-]?\d{6,7}\b"),
}

def controlla_prompt(testo: str) -> tuple[bool, list, str]:
    trovati, mascherato = [], testo
    for tag, pat in VIETATI.items():
        if pat.search(mascherato):
            trovati.append(tag)
            mascherato = pat.sub(f"[{tag}]", mascherato)
    consentito = len(trovati) == 0
    return consentito, trovati, mascherato  # blocca o invia la versione mascherata
```

La logica: prima di ogni chiamata a un LLM cloud, il testo passa dal controllo. Se contiene dati vietati, o lo **blocchi** (con un messaggio all'utente) o invii la **versione mascherata**. Vale lo stesso avvertimento di sempre: i nomi propri sfuggono ai pattern, quindi il mascheramento riduce ma non azzera — per l'azzeramento serve il modello locale.

**L'opt-out dal training.** Assicurarsi, contrattualmente, che gli input non vengano usati per addestrare i modelli. È una clausola del DPA, non un'impostazione qualsiasi.

**Il tenant aziendale, non gli account personali.** Un'istanza aziendale con le garanzie configurate, non i profili personali dei dipendenti. È la differenza tra un uso governato e lo Shadow IT (più avanti).

**I log minimi e il controllo accessi.** Sapere chi ha mandato cosa, tenere il minimo necessario, cancellare secondo una retention definita. La sicurezza dell'art. 32 è anche questo.

Una tabella per confrontare le tre strade, sui criteri che contano:

| Criterio | LLM cloud US (account personale) | Vendor cloud con DPA + regione UE | Modello locale (sovrano) |
|---|---|---|---|
| **Dati escono dall'UE** | Sì, senza cornice | Ridotto, da valutare sulla filiera | No |
| **DPA / art. 28** | Assente | Presente (se fatto bene) | Non serve (nessun responsabile esterno) |
| **Uso per training** | Possibile | Escludibile per contratto | Escluso per costruzione |
| **Controllo del titolare** | Nullo | Parziale | Pieno |
| **Sforzo tecnico** | Zero (ed è il problema) | Medio | Alto |

## AI Act 2026: uso ad alto rischio contro produttività interna

Sopra il GDPR c'è ora l'**AI Act**, il regolamento europeo sull'intelligenza artificiale, che aggiunge un livello. Anche qui: non è consulenza legale, ma il quadro da conoscere per portarlo al DPO.

L'AI Act ragiona per **livelli di rischio**. Semplificando molto:

- **Uso di produttività interna** (farsi scrivere una mail, riassumere un testo, aiutare a redigere): in genere ricade nelle categorie a rischio limitato/minimo. Ci sono obblighi — soprattutto di **trasparenza** (le persone dovrebbero sapere quando interagiscono con l'AI, i contenuti generati vanno trattati come tali) — ma non è la fascia più pesante.
- **Uso ad alto rischio**: quando l'AI entra in decisioni che incidono significativamente sulle persone — selezione del personale, valutazione del merito creditizio, e altri ambiti definiti. Qui gli obblighi si fanno seri (documentazione, supervisione umana, gestione del rischio).

Il punto pratico per una PMI: *usare un LLM per aiutare a scrivere una mail* è diverso da *usare un LLM per decidere a chi concedere un fido o chi assumere*. Il primo è produttività; il secondo può essere ad alto rischio e richiede molto di più. La domanda da portare al legale è: **il mio uso dell'AI entra in decisioni che incidono sulle persone, o è solo assistenza alla produttività?** La risposta cambia gli obblighi. E attenzione: anche nell'uso "leggero", se ci finiscono dentro dati personali di clienti, il GDPR continua ad applicarsi in pieno — l'AI Act si aggiunge, non sostituisce. I due vanno letti insieme, con il DPO.

## Il contratto con i dipendenti: policy, sanzioni, Shadow IT

Qui sta la radice pratica del data leak: lo **Shadow IT**. I dipendenti usano ChatGPT (o altri) con i loro account personali, di nascosto o alla luce del sole, perché è comodo e nessuno ha detto loro di non farlo. Puoi avere il DPA più bello del mondo sull'istanza aziendale: se il commerciale incolla l'opportunity nel suo ChatGPT personale, non conta niente. Il controllo tecnico da solo non basta — serve la **governance delle persone**.

Servono tre cose:

1. **Una policy chiara** su cosa si può e non si può fare con gli strumenti AI, e con quali account. Non un tomo legale: una pagina che chiunque capisce (la traccia è qui sotto).
2. **La formazione.** I dipendenti spesso non sanno di star facendo qualcosa di rischioso — pensano di "usare l'AI per lavorare meglio". Vanno resi consapevoli del *perché*, non solo del divieto. Una persona che capisce il rischio collabora; una a cui vieti e basta trova il modo di aggirarti.
3. **Un'alternativa che funziona.** Il motivo numero uno dello Shadow IT è che lo strumento ufficiale manca o è scomodo. Se vieti ChatGPT ma non dai niente al suo posto, i dipendenti lo useranno lo stesso di nascosto. Dai loro un'alternativa **governata e comoda** (l'istanza aziendale con le garanzie, o il modello locale), e lo Shadow IT si sgonfia.

Ecco una **traccia di policy interna di una pagina** — da adattare col DPO, ma come punto di partenza operativo:

```text
POLICY USO STRUMENTI AI — [Azienda]  (v1, [data])

1. SCOPO. Regola l'uso di strumenti di intelligenza artificiale
   (ChatGPT, assistenti, LLM) nel lavoro, per proteggere i dati
   dei clienti e rispettare il GDPR.

2. STRUMENTI CONSENTITI. Solo gli strumenti forniti dall'azienda
   ([strumento/istanza aziendale] / [modello interno]). VIETATI gli
   account personali su strumenti AI per attività lavorative.

3. DATI VIETATI NEI PROMPT CLOUD. Non inserire mai in uno strumento
   AI cloud: nomi+cognomi di clienti, P.IVA/CF, IBAN, importi legati
   a nominativi, dati sanitari o giudiziari, credenziali, contratti
   riservati, strategie su clienti nominati. In caso di dubbio: non
   inserirlo, o usa lo strumento interno.

4. USO CONSENTITO. Testi generici, bozze senza dati personali,
   riassunti di materiale non riservato, aiuto alla redazione con
   dati mascherati/fittizi.

5. RESPONSABILITA'. L'uso improprio che espone dati di clienti è una
   violazione di questa policy e delle norme sulla protezione dei
   dati, con le conseguenze previste dal [regolamento/contratto].

6. DUBBI. In caso di dubbio, chiedi a [referente/DPO] PRIMA di agire.
```

Questa pagina, firmata e spiegata, vale più di dieci pagine di misure tecniche che nessuno conosce. Perché il data leak non lo fa la tecnologia: lo fanno le persone che non sanno.

## L'elenco: dati che non devono mai entrare in un prompt cloud

Da stampare e appendere. Questi dati **non entrano mai** in uno strumento AI cloud non governato:

- **Nome e cognome di clienti/persone reali** associati a informazioni.
- **Partita IVA e codice fiscale.**
- **IBAN e coordinate bancarie.**
- **Importi economici legati a nominativi** (fatturati, offerte, debiti di clienti nominati).
- **Dati sanitari, giudiziari, o comunque "particolari".**
- **Credenziali, password, chiavi, token.**
- **Contratti, offerte e documenti riservati.**
- **Strategie commerciali su clienti nominati** (prezzi, sconti, punti deboli).
- **Curriculum e dati di candidati/dipendenti.**
- **Qualsiasi cosa che, se finisse in un data breach del fornitore, ti metterebbe nei guai.**

La regola mentale semplice da dare ai dipendenti: *"se non lo scriveresti su una cartolina, non lo incollare in un prompt cloud."*

## L'alternativa sovrana: modello locale o vendor UE con DPA serio

Fin qui il problema. La soluzione strutturale, quella che toglie il rischio alla radice invece di gestirlo, è **non far uscire i dati.** Due strade, a seconda del caso.

- **Il modello locale (sovrano).** Un LLM che gira sulla tua infrastruttura (Ollama in piccolo, [vLLM per la produzione multi-utente]({{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }})): i dati dei clienti non lasciano il tuo recinto, quindi il problema del trasferimento e del responsabile esterno **non si pone**. È l'alternativa più solida per i dati sensibili e per l'uso continuo, ed è il cuore dello stack sovrano.
- **Il vendor UE con DPA serio.** Se ti serve la potenza di un modello cloud per certi task, scegli un fornitore che offra un DPA robusto, regione UE, opt-out dal training, e trasparenza sui sub-responsabili — e governalo con la policy, il mascheramento e i log. Non è "a rischio zero", ma è "a rischio governato e documentabile", il che è tutt'altro rispetto al commerciale col suo ChatGPT personale.

La scelta pragmatica, come per tutto lo stack sovrano: **default locale per i dati sensibili, cloud UE governato per i task che richiedono più potenza e non toccano i dati critici.** Il conto economico spesso sorprende: un modello locale per l'uso interno continuo si ripaga (come nel [confronto sui costi di GPU e runtime]({{ '/it/pillar/modelli-costi-privacy/' | relative_url }})), e in più elimina un rischio che, se si materializza in una sanzione, costa molto più di qualsiasi GPU.

## L'architettura di riferimento

Concretamente, come si mette in sicurezza il "AI nel CRM" senza vietarlo (che non funziona):

- **Un gateway AI interno** tra i dipendenti/le app e i modelli. Tutte le richieste passano di lì.
- **Il filtro di mascheramento** nel gateway (il blocklist visto sopra): blocca o maschera i dati vietati prima di qualunque invio.
- **Instradamento per sensibilità**: i task su dati sensibili vanno al **modello locale**; i task leggeri e non critici possono andare al **vendor UE governato**.
- **Log e audit** nel gateway: chi ha chiesto cosa, cosa è stato bloccato/mascherato, dove è andato.
- **Cosa il sistema NON fa mai**: mandare dati vietati non mascherati a un modello cloud, e usare account personali. Questi sono i confini invalicabili, imposti dal gateway, non lasciati alla buona volontà.

I passi per arrivarci:

1. **Mappa** dove i dipendenti usano già l'AI e su quali dati (l'audit dello Shadow IT).
2. **Scrivi la policy** e forma le persone.
3. **Metti il gateway** con il mascheramento e l'instradamento.
4. **Offri l'alternativa comoda** (locale + UE governato) così nessuno torni agli account personali.
5. **Documenta** registro e DPIA col DPO, citando le misure messe.
6. **Monitora** i log e aggiorna la blocklist sui casi reali.

## Lo stesso scenario, gestito bene: prima e dopo

Torniamo al commerciale della prima riga, quello che voleva la mail per Mario Rossi. Vediamo come lo stesso identico bisogno viene soddisfatto *senza* il data leak, con l'architettura sopra.

**Prima (il data leak).** Il commerciale apre ChatGPT personale e incolla: "mail per Mario Rossi, Acme Srl, P.IVA 01234567890, opportunity 45.000 € ferma sul prezzo vs concorrente X, storia di un problema di consegna". Tutto esce, senza cornice. Nessun DPA, nessun log, dati fuori dall'UE.

**Dopo (governato).** Il commerciale usa lo strumento aziendale. Scrive la stessa richiesta. Il **gateway** intercetta il prompt:

1. Il **filtro di mascheramento** rileva la P.IVA e la sostituisce con `[PIVA]`; segnala che c'è un nome cliente reale e un importo legato a un nominativo.
2. Il **router** vede che la richiesta contiene dati di un cliente identificabile: la instrada al **modello locale**, non al cloud. In alternativa, se il commerciale conferma di voler solo una bozza generica, il gateway invia al cloud UE governato *solo* la versione senza dati ("un cliente ha un'opportunity ferma per una questione di prezzo rispetto a un concorrente, con un precedente disservizio: scrivimi una mail per riaprire il dialogo").
3. Il modello produce la mail. Il commerciale reinserisce lui, in locale, il nome vero al posto del segnaposto.
4. Il **log** registra: chi, quando, cosa è stato mascherato, dove è andato.

Risultato: il commerciale ottiene la sua mail in trenta secondi — *stessa comodità di prima* — ma nessun dato identificabile del cliente è uscito senza cornice. Questo è il punto chiave: la sicurezza non si ottiene *vietando* l'AI (i dipendenti la userebbero di nascosto), ma dando la stessa comodità dentro un recinto. Vietare crea Shadow IT; incanalare lo elimina.

## Cosa si rompe (e come te ne accorgi)

- **Lo Shadow IT che ritorna.** Sintomo: cala l'uso del gateway ufficiale ma il lavoro "aiutato dall'AI" continua. Causa: lo strumento ufficiale è più scomodo del ChatGPT personale. Rimedio: rendi l'alternativa comoda, o la policy resta carta.
- **Il mascheramento che lascia passare nomi.** Sintomo: nei log del gateway vedi prompt con nomi propri non mascherati. Causa: i pattern prendono P.IVA e IBAN, non "Mario Rossi". Rimedio: per i dati davvero sensibili, instrada al modello locale invece di fidarti del solo mascheramento.
- **Il DPA che non c'è.** Sintomo: nessuno sa esibire il DPA col fornitore. Causa: si usa un piano senza le garanzie, o account personali. Rimedio: istanza aziendale con DPA, o locale.
- **La DPIA mai fatta su un uso ad alto rischio.** Sintomo: l'AI è entrata in decisioni su persone (assunzioni, fidi) senza valutazione. È il rischio più serio: fermati e coinvolgi il DPO prima di proseguire.

Sul fronte **costi** (stime): il gateway e il mascheramento sono lavoro di sviluppo contenuto; il modello locale ha il costo di GPU già discusso (una scheda da 24 GB usata ~800 € + elettricità per l'uso interno). Il costo da mettere davvero sul piatto è quello del **rischio non gestito**: una sanzione per trattamento illecito di dati di clienti pesa ordini di grandezza più di qualsiasi stack. Il conto onesto confronta il costo della soluzione con il costo dell'incidente, non con "zero".

## Quando NON serve tutto questo apparato

Onestà, come sempre. **Non ti serve costruire gateway e stack locale se:**

- **Non tratti dati personali di clienti con l'AI.** Se l'uso dell'AI in azienda è su contenuti generici, pubblici o sintetici, il problema GDPR è marginale: bastano una policy semplice e buon senso.
- **Sei piccolissimo e l'uso è occasionale.** Poche persone, uso sporadico su dati non sensibili: una policy chiara + il mascheramento manuale (non incollare P.IVA e nomi) possono bastare, senza infrastruttura.
- **Ti serve solo per bozze e testi.** Se l'AI serve per redigere testi che *non contengono* dati di clienti, insegna alle persone a lavorare con dati fittizi e sei a posto.

La proporzione conta: la soluzione va commisurata al rischio reale. Non serve un gateway aziendale per farsi scrivere due mail senza dati personali; serve eccome se decine di commerciali incollano opportunity vere ogni giorno. Sovradimensionare è spreco, sottovalutare è il data leak da cui siamo partiti.

## Checklist operativa da portare al DPO

- [ ] So **chi** usa strumenti AI in azienda e su **quali dati** (audit Shadow IT fatto).
- [ ] Ho una **policy** scritta di una pagina, firmata e spiegata ai dipendenti.
- [ ] Gli **account personali** su strumenti AI sono vietati per il lavoro; c'è un'istanza aziendale.
- [ ] C'è un **DPA (art. 28)** con ogni fornitore cloud che tratta dati per me.
- [ ] È **escluso l'uso per training** dei miei input (per contratto).
- [ ] Ho valutato **trasferimenti extra-UE** (art. 44) e sub-responsabili sulla filiera reale.
- [ ] C'è un **mascheramento** dei dati vietati prima dei prompt cloud (art. 32).
- [ ] I **dati sensibili** vanno al **modello locale**, non al cloud.
- [ ] L'uso dell'AI è nel **registro dei trattamenti**; c'è una **DPIA** se il rischio è elevato.
- [ ] Ho verificato col legale se qualche uso è **ad alto rischio** ai fini dell'**AI Act**.
- [ ] Ci sono **log minimi** e una **retention** definita.

## Il verdetto: il problema non è l'AI, è dove finiscono i dati

Mettere ChatGPT nel CRM diventa un data leak non perché l'AI sia il male, ma perché il gesto banale di incollare un'opportunity manda dati di clienti italiani fuori dall'UE, senza DPA, senza base giuridica, senza che il titolare — cioè tu — lo sappia. Il "toggle EU" è necessario ma non sufficiente; il vero controllo passa da chi è responsabile nella filiera, dalla minimizzazione, dal mascheramento, e soprattutto da una policy che governi le persone e da un'alternativa comoda che tolga lo Shadow IT alla radice. La soluzione più solida resta la più semplice concettualmente: **non far uscire i dati** — modello locale per il sensibile, vendor UE governato per il resto. E ricorda l'avvertenza da cui siamo partiti: questa è la checklist tecnica da portare al tuo DPO, non il suo parere. Il parere te lo danno loro; tu porti loro un quadro chiaro di cosa succede davvero — che ora ce l'hai.

Questo è un mattone della [guida a modelli, costi e privacy dell'AI in casa]({{ '/it/pillar/modelli-costi-privacy/' | relative_url }}). Se vuoi mettere in sicurezza l'uso dell'AI sui *tuoi* dati clienti — gateway, mascheramento, alternativa sovrana — parti da [chi sono e come lavoro]({{ site.main_site }}/biografia/) o scrivimi due righe in [contatti]({{ site.main_site }}/contatti/).

## FAQ

**1. Usare ChatGPT sui dati dei clienti è illegale?**
Non è "illegale" in assoluto, ma senza le giuste cornici (DPA, base giuridica, garanzie sui trasferimenti, minimizzazione) è un trattamento fuori controllo di cui rispondi tu come titolare. Il gesto del commerciale che incolla un'opportunity nel suo account personale, in particolare, è privo di qualsiasi cornice. La valutazione formale spetta al tuo DPO; questo articolo ti aiuta a portargli il quadro.

**2. Ma se attivo la regione UE non sono a posto?**
No: è un passo utile ma non chiude il tema. Resta il rapporto di responsabile del trattamento (serve il DPA), la valutazione di sub-responsabili e trasferimenti, l'opt-out dal training, e soprattutto il controllo su chi usa cosa. La residenza dei dati è necessaria, non sufficiente.

**3. Chi è responsabile se i dati escono, io o OpenAI?**
Il titolare del trattamento sei tu, l'azienda, e la responsabilità principale resta tua. Il fornitore agisce come responsabile (art. 28) *se* c'è un rapporto regolato da un DPA. Usare uno strumento di altri non trasferisce la tua responsabilità di titolare.

**4. Cosa non devo mai incollare in un prompt cloud?**
Nomi di clienti reali associati a informazioni, P.IVA/CF, IBAN, importi legati a nominativi, dati sanitari o giudiziari, credenziali, contratti riservati, strategie su clienti nominati, dati di candidati. Regola pratica: se non lo scriveresti su una cartolina, non lo incollare.

**5. Il mascheramento dei dati basta?**
Aiuta molto (intercetta P.IVA, IBAN, email, telefoni prima dell'invio) ma non basta da solo: i nomi propri sfuggono ai pattern. Per i dati davvero sensibili la difesa vera è instradare il task al modello locale, dove i dati non escono affatto.

**6. Cosa cambia con l'AI Act?**
Aggiunge obblighi in base al livello di rischio. L'uso per produttività interna (scrivere mail, riassumere) è in genere a rischio limitato, con obblighi soprattutto di trasparenza. L'uso in decisioni che incidono sulle persone (assunzioni, fidi) può essere ad alto rischio, con obblighi molto più pesanti. Il GDPR continua ad applicarsi in parallelo. Verifica col legale in quale caso sei.

**7. Come fermo i dipendenti che usano ChatGPT di nascosto?**
Non basta vietare: serve una policy chiara, formazione sul perché (non solo sul divieto), e soprattutto un'alternativa comoda e governata (istanza aziendale o modello locale). Lo Shadow IT nasce quando lo strumento ufficiale manca o è scomodo: togli quella causa e si sgonfia.

**8. Devo fare una DPIA?**
Se l'uso di LLM su dati di clienti presenta rischi elevati (grandi anagrafiche, profilazione, decisioni), probabilmente sì — ma è una valutazione da fare col DPO. La DPIA è dove decidi, documentandolo, se quell'uso dell'AI sta in piedi e con quali misure. Non è un modulo burocratico: è la decisione.

**9. Qual è l'alternativa concreta se non voglio rischiare?**
Non far uscire i dati: un modello locale (Ollama/vLLM) per i task su dati sensibili, così il trasferimento e il responsabile esterno non si pongono. Per i task leggeri che richiedono più potenza, un vendor UE con DPA serio, opt-out dal training e governato con policy e mascheramento. Default locale per il sensibile.

**10. Quanto mi costa mettermi in regola?**
Il lavoro tecnico (gateway, mascheramento) è contenuto; il modello locale ha il costo di una GPU (~800 € usata + elettricità per l'uso interno). Ma il confronto giusto non è con "zero": è con il costo del rischio non gestito. Una sanzione per trattamento illecito di dati di clienti pesa ordini di grandezza più della soluzione. Mettersi in regola è quasi sempre più economico dell'incidente.
