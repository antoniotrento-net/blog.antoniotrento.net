---
layout: pillar
lang: it
permalink: /it/pillar/agenti-esecuzione/
pillar_key: agenti-esecuzione
section: stack-sovrano-ai
title: "Agenti che eseguono (MCP, tool, guardrail)"
description: "MCP, tool calling, kill switch, human-in-the-loop ed eval: agenti che non chiacchierano ma eseguono, con confini chiari e niente disastri."
image: /assets/images/pillars/agenti-esecuzione.jpg
alt_url: /en/pillar/agents-that-act/
sitemap: false

---

Un chatbot che risponde male fa perdere tempo. Un agente che **esegue** male fa perdere soldi: aggiorna il record sbagliato sul CRM, paga una fattura due volte, clicca "Elimina" su un portale, gira in loop per tre ore consumando token. La differenza tra i due non sta nel modello. Sta in quello che gli lasci toccare, in come lo fermi e in come dimostri cosa ha fatto.

Questa guida raccoglie gli articoli su come si costruiscono **agenti che agiscono su sistemi reali** senza diventare un rischio: protocolli e tool, confini e permessi, code di approvazione, interruttori d'emergenza e un modo serio di misurare se funzionano.

## Il principio: il modello propone, il sistema dispone

Il filo che lega questi articoli è una separazione netta. Il **modello** legge, interpreta, propone un'azione con i suoi parametri. Il **sistema** intorno al modello decide se quell'azione si può fare: valida i parametri con regole deterministiche, controlla i permessi, chiede l'approvazione di una persona quando l'effetto è irreversibile, registra tutto, e può fermare l'agente in qualsiasi momento. Un agente sicuro non è un modello più intelligente. È un modello dentro una scatola progettata bene.

Il secondo filo è **l'anti-hype**. Non tutto ha bisogno di un agente. Un processo con regole chiare si automatizza meglio con un flusso deterministico; il modello serve dove c'è testo disordinato da interpretare. Più agenti non vuol dire più intelligenza; spesso vuol dire più contraddizioni. Diversi articoli di questa guida servono proprio a togliere il modello da dove non serve.

## I temi (e l'articolo che li affronta)

**Protocolli, tool e orchestrazione**

- **«Cos'è davvero MCP?»** — tool, resources e autenticazione senza slogan, e perché non è una presa universale se il server è scritto male: [Model Context Protocol spiegato]({{ '/it/blog/model-context-protocol-spiegato/' | relative_url }}).
- **«Il chatbot legge il CRM ma non conclude niente»** — un agente MCP su Salesforce che esegue senza bruciare i governor limit: [MCP su Salesforce in produzione]({{ '/it/blog/mcp-salesforce-agente-produzione/' | relative_url }}).
- **«Sostituiamo i Flow con un agente»** — quando il Flow deterministico è più sicuro e quando serve davvero un modello per leggere il disordine: [Salesforce Flow vs agente MCP]({{ '/it/blog/salesforce-flow-vs-agente-mcp/' | relative_url }}).
- **«LangGraph, n8n o uno script?»** — quale orchestratore per un agente che deve eseguire, non chiacchierare: [LangGraph vs n8n vs Python]({{ '/it/blog/langgraph-vs-n8n-vs-python/' | relative_url }}).
- **«I task dell'agente finiscono sepolti in una chat»** — far scrivere all'agente issue tracciabili su GitHub o GitLab: [l'agente che apre le issue]({{ '/it/blog/agente-ai-github-issues/' | relative_url }}).

**Confini, input ostili e dati inventati**

- **«Una fattura PDF ha dato istruzioni all'agente»** — la prompt injection nei documenti aziendali e come la blocchi con l'architettura, non con il prompt: [prompt injection nei documenti]({{ '/it/blog/prompt-injection-documenti-aziendali/' | relative_url }}).
- **«L'agente ha inventato un IBAN plausibile»** — JSON Schema, validatori di dominio e cosa fare quando la validazione fallisce: [JSON Schema e tool calling]({{ '/it/blog/json-schema-tool-calling-iban/' | relative_url }}).
- **«L'agente browser ha cliccato dove non doveva»** — allowlist di URL, snapshot e budget per un agente con Playwright: [l'agente browser con allowlist]({{ '/it/blog/playwright-agente-browser-allowlist/' | relative_url }}).

**Fermarlo, approvarlo, misurarlo**

- **«Basta scrivere OK in chat»** — perché non è un controllo, e come si costruisce una coda di approvazione prima che l'agente spedisca una PEC o un bonifico: [human-in-the-loop per PEC e SEPA]({{ '/it/blog/human-in-the-loop-pec-sepa/' | relative_url }}).
- **«Come lo fermiamo se scrive male sul CRM?»** — dry-run, coda e interruttore per agenti che scrivono su Salesforce: [il kill switch dell'agente]({{ '/it/blog/kill-switch-agente-salesforce/' | relative_url }}).
- **«L'agente gira in tondo sulle tool call»** — riconoscere il loop dai log e spezzarlo senza spegnere tutto: [il loop infinito del tool calling]({{ '/it/blog/tool-calling-loop-infinito/' | relative_url }}).
- **«Abbiamo messo tre agenti e si contraddicono»** — orchestratore, blackboard e un solo writer: [multi-agente e contraddizioni]({{ '/it/blog/multi-agente-contraddizione-orchestratore/' | relative_url }}).
- **«Come sappiamo se l'agente funziona?»** — task success, side-effect score e perché le metriche da chatbot non servono: [la valutazione degli agenti in produzione]({{ '/it/blog/valutazione-agenti-llm-produzione/' | relative_url }}).

## Il pezzo che decide tutto: la mappa dei tool

In tutti questi articoli la prima decisione è la stessa, e viene prima del modello: **quali tool dai all'agente, e di che tipo**. Conviene dividerli in tre gruppi:

- **tool sicuri**: leggono, cercano, calcolano. Si possono chiamare liberamente, con un limite di frequenza;
- **tool sorvegliati**: scrivono in punti precisi e reversibili (una bozza, un campo di classificazione, un'issue). Si chiamano con validazione e traccia;
- **tool armati**: spediscono, pagano, cancellano, cambiano permessi. Non li chiama mai l'agente da solo: passano da una coda di approvazione legata a ciò che la persona ha visto.

Quando la mappa è chiara, metà dei rischi spariscono prima di scrivere il prompt. Quando non c'è, nessun prompt la sostituisce.

## Dove girano gli agenti

Un agente che esegue comandi o tocca sistemi è, dal punto di vista della sicurezza, codice che esegue istruzioni lette da testi che non controlli. Per questo i container senza root, le reti interne e i segreti fuori dal contesto del modello non sono dettagli: sono la metà della sicurezza. Il riferimento è la guida allo [stack sovrano]({{ '/it/pillar/stack-sovrano/' | relative_url }}). Per collegare gli agenti a PEC, CRM e gestionali senza consegnare le password a un servizio esterno, c'è la guida su [integrazioni e dati legacy]({{ '/it/pillar/integrazioni-dati/' | relative_url }}).

## Come usare questa guida

Parti dall'incidente che temi di più, o da quello che ti è già capitato. Ogni articolo ha un'architettura di riferimento con quello che l'agente **non** tocca, un percorso a step, i fallimenti tipici con le righe di log che li rivelano, i costi in ordine di grandezza e una sezione su quando non mettere un agente affatto.

Se stai per dare a un agente la possibilità di agire sui tuoi sistemi e vuoi decidere prima i confini, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi da [contatti]({{ site.main_site }}/contatti/).

Qui sotto trovi tutti gli articoli di questa guida.
