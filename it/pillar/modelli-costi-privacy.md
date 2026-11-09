---
layout: pillar
lang: it
permalink: /it/pillar/modelli-costi-privacy/
pillar_key: modelli-costi-privacy
section: stack-sovrano-ai
title: "Modelli, costi e privacy"
description: "vLLM vs Ollama, TCO reale, GDPR e AI Act: quando il cloud LLM ti costa i clienti e quando conviene comunque, con numeri."
image: /assets/images/pillars/modelli-costi-privacy.jpg
alt_url: /en/pillar/models-cost-privacy/
sitemap: false

---

La domanda arriva in tre forme diverse, ma è sempre la stessa. Il titolare chiede "quanto ci costa?". Il DPO chiede "dove vanno i dati?". Chi deve far funzionare il sistema chiede "regge se lo usano in trenta?". Le tre risposte sono legate. Un modello in cloud costa poco al primo mese e manda i prompt fuori dall'azienda. Uno self-hosted tiene i dati in casa e ti lascia la GPU, la bolletta e la manutenzione. Un servizio pensato per una persona sola crolla al quindicesimo utente.

Questa guida raccoglie gli articoli che fanno **i conti veri**: su euro, token, VRAM e kilowattora, su cosa dicono GDPR e AI Act quando i prompt contengono clienti italiani, e su come scegliere tra cloud e self-hosted senza ideologia, con numeri.

## Il principio: il prezzo per token non è il costo

Il filo che lega questi articoli è che **il listino non è il conto**. Il prezzo per milione di token dice quanto paghi il modello, non quanto ti costa il sistema. Nel costo vero ci sono il volume reale (che è sempre più alto di quello stimato), i retry, le persone che controllano le risposte, i dati che non puoi mandare fuori e devi trattare a parte, la dipendenza da un fornitore che cambia prezzi e modelli quando vuole. Dall'altra parte, il self-hosted ha costi che non compaiono nella demo: l'hardware, l'energia, chi aggiorna, chi si accorge quando la GPU va in throttling.

Il secondo filo è che **privacy e costo non sono in conflitto**, se il sistema è progettato bene. Una cache fatta male risparmia token e serve la risposta di un cliente a un altro. Un modello locale ben dimensionato tiene i dati in azienda e costa meno di un abbonamento per utente. La scelta giusta dipende dal volume, dai dati e dalle competenze che hai, non da una preferenza.

## I temi (e l'articolo che li affronta)

**Dove girano i modelli**

- **«Ollama funziona benissimo sul mio PC»** — perché smette di funzionare con quindici utenti, e quando serve un server con batching come vLLM: [vLLM vs Ollama in produzione]({{ '/it/blog/vllm-vs-ollama-produzione/' | relative_url }}).
- **«Abbiamo vietato ChatGPT e lo usano dal telefono»** — una chat interna su due GPU usate, dietro SSO, con una policy di dieci regole al posto del divieto: [il ChatGPT privato per la PMI]({{ '/it/blog/chatgpt-privato-self-hosted-pmi/' | relative_url }}).

**Quanto costa davvero**

- **«Il cloud costa pochi centesimi a documento»** — il TCO completo su 100.000 documenti al mese, con elettricità, persone e sensibilità: [GPT-4o vs LLM self-hosted]({{ '/it/blog/tco-gpt-4o-vs-llm-self-hosted/' | relative_url }}).
- **«Mettiamo una cache e risparmiamo il 40%»** — quando la cache semantica risparmia davvero e quando serve la risposta sbagliata al cliente sbagliato: [la cache semantica sulle chiamate LLM]({{ '/it/blog/cache-semantica-llm/' | relative_url }}).
- **«Addestriamo il modello sulle nostre FAQ»** — quando il fine-tuning è uno spreco e il retrieval basta, e quando invece no: [fine-tuning vs RAG sulle FAQ italiane]({{ '/it/blog/fine-tuning-vs-rag-faq-italiane/' | relative_url }}).

**Regole e controllo**

- **«Mettiamo ChatGPT nel CRM»** — cosa dicono GDPR e AI Act quando i prompt contengono i dati dei clienti: [GDPR e ChatGPT nel CRM]({{ '/it/blog/gdpr-chatgpt-crm/' | relative_url }}).
- **«Con l'AI Act siamo ad alto rischio?»** — come capire se il tuo agente è un sistema ad alto rischio o se stai solo automatizzando l'inbox: [l'AI Act per le PMI che usano agenti]({{ '/it/blog/eu-ai-act-pmi-agenti-2026/' | relative_url }}).
- **«Per sapere se funziona guardiamo la chat»** — tracce, costo per esecuzione, retry e redaction, cioè come si sorveglia un LLM in produzione: [l'osservabilità degli LLM]({{ '/it/blog/osservabilita-llm-produzione/' | relative_url }}).

## Il pezzo che decide tutto: il dimensionamento onesto

In quasi tutti questi articoli la decisione si gioca su una tabella che nessuno vuole compilare: **quanti utenti contemporanei, quanti documenti al mese, quanti token per richiesta, che qualità minima serve, quali dati non possono uscire**. Con quei cinque numeri la scelta diventa quasi meccanica. Senza, si sceglie in base all'ultima demo vista.

Due errori tornano spesso. Il primo è dimensionare sulla media invece che sul picco: il servizio regge il martedì pomeriggio e crolla il lunedì mattina, quando tutti aprono la chat insieme. Il secondo è confrontare un modello di frontiera in cloud con un modello locale su compiti che il modello locale non deve fare. Per scrivere, riassumere e classificare in italiano, un modello open-weight ben scelto basta quasi sempre. Per il ragionamento complesso, a volte no. Va detto per nome, caso per caso.

## Privacy: dove finisce il prompt

L'altro asse di questa guida è una domanda semplice: **dove finisce il testo che scrivi?** In un servizio cloud, sui server del fornitore, con le condizioni del contratto che hai firmato (o che non hai letto). In un modello self-hosted, sui tuoi server, ma anche nei log, nei trace di osservabilità, nella cache, nei backup. Proteggere i dati non è solo scegliere dove gira il modello. È sapere ogni posto in cui il testo viene copiato e quanto ci resta.

Per le architetture che fanno girare questi modelli in casa — container, reti interne, segreti, backup — il riferimento è la guida allo [stack sovrano]({{ '/it/pillar/stack-sovrano/' | relative_url }}). Per i modelli che non solo rispondono ma agiscono sui sistemi, c'è la guida sugli [agenti che eseguono]({{ '/it/pillar/agenti-esecuzione/' | relative_url }}).

## Come usare questa guida

Parti dalla domanda che ti stanno facendo adesso: quella del titolare sul costo, quella del DPO sui dati o quella di chi gestisce il server sulla tenuta. Ogni articolo ha numeri dichiarati come stime, un'architettura di riferimento, i fallimenti tipici riconoscibili dai log e una sezione su quando **non** conviene la strada che descrive. A volte un servizio cloud con un buon contratto è la scelta giusta, e va detto.

Se vuoi fare i conti sul *tuo* volume e sui *tuoi* dati prima di comprare GPU o firmare un abbonamento, trovi il mio percorso nella [biografia]({{ site.main_site }}/biografia/) e puoi scrivermi da [contatti]({{ site.main_site }}/contatti/).

Qui sotto trovi tutti gli articoli di questa guida.
