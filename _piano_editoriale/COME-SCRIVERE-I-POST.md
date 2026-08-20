# Come scrivere i post — playbook per Claude (e qualsiasi agente)

Leggi **questo file per intero** prima di creare o modificare un markdown in `_posts/`.
Non improvvisare date, permalink o “pubblico tutto oggi”.

SEO di contesto (Search Console, noindex archivio vecchio): `_piano_editoriale/seo-mappa.md`.
Questo file è il **manuale di produzione**.

Le pillar **non** si accendono da sole. Dopo un lotto di post (e a fine cluster) **controlla** se quella guida è ancora stub o va messa in index: sezione 9.

Repo: `blog.antoniotrento.net`. Sito live: `https://blog.antoniotrento.net`.
Oggi, quando è stato scritto il playbook: **19 agosto 2026**.

---

## 0. La regola che se sbagli rovina la SEO

**Scrivere i file ≠ farli uscire su Google.**

Puoi (e devi, se i tempi sono stretti) preparare molti `.md` in una settimana.
**Non** devono comparire tutti in sitemap lo stesso giorno.

Se metti `date:` = oggi (o una data già passata) su 20 file e fai push, al prossimo build di GitHub Pages **tutti** vanno online. È la stessa dinamica della fattoria 2025–2026 su `antoniotrento.net` (256 pezzi a stampo, impression azzerate nel 2026). Non ripeterla.

Date **future** + `future: false` nel `_config.yml` = il file sta nel repo, **non** nel sito, **non** nella sitemap, finché non arriva quel giorno **e** GitHub Pages ricostruisce.

---

## 1. Cos’è Drip publish (non “drift”)

Nome workflow GitHub Actions: **`Drip publish`**.
File: `.github/workflows/drip-publish.yml`.

Non è un CMS. Non scrive articoli. Non sceglie i titoli. Non fa commit dei post.

È una **sveglia mattutina** sul repo del blog:

| Cosa | Dettaglio |
|---|---|
| Quando | Ogni giorno ~07:30 ora Italia estate (`cron: "30 5 * * *"` = 05:30 UTC) |
| Cosa fa | Chiama l’API GitHub Pages: “ricostruisci il sito adesso” |
| Effetto | Jekyll ricalcola `site.time`. I post con `date:` ≤ quel momento **entrano**. Gli altri restano invisibili |
| Cosa non fa | Non crea file in `_posts/`. Se il `.md` di oggi non esiste, quel giorno non esce niente (va bene) |
| Keep-alive | Il 1° del mese: commit vuoto, altrimenti GitHub spegne i cron dopo ~60 giorni senza attività nel repo |
| Test già fatto | 19 ago 2026: run manuale #1 OK. **Non** serve rilanciarlo ogni giorno |

Nella tab Actions vedrai due cose diverse:

- **Drip publish** — la sveglia (~10 secondi).
- **pages-build-deployment** — il vero deploy Pages (parte dopo la sveglia o dopo un push su `main`).

URL: https://github.com/antoniotrento-net/blog.antoniotrento.net/actions/workflows/drip-publish.yml

L’agente **non** deve lanciare Drip publish a ogni articolo. Un push su `main` basta già a ricostruire Pages; la sveglia serve per i giorni **senza** push (Antonio al lavoro).

### Cosa fa l’agente vs cosa fa Drip

```
Agente:  crea 2026-09-18-slug.md  con date: 2026-09-18  →  push
         Oggi è il 19 agosto. Il file NON è sul sito. Google non lo vede.

Drip:    il 18 settembre alle 07:30 chiede un rebuild.
         Jekyll vede date <= 18 set → il post esce in sitemap e in home.
```

---

## 2. Dove sta il calendario (fonte date)

**Non inventare la data.** Prendila dal piano.

| Cosa | Dove |
|---|---|
| Calendario operativo (id, slug, date, date_file, status, pillar) | `_data/editorial_plan.yml` |
| Prompt lunghi / keyword / immagine (CSV) **in questo repo** | `_piano_editoriale/*.csv` |
| Serie A clienti | `_piano_editoriale/piano-editoriale-2026-clienti.csv` |
| Serie B stack | `_piano_editoriale/piano-editoriale-2026-livello2-stack.csv` |
| Serie C PMI ops | `_piano_editoriale/piano-editoriale-2026-livello3-pmi-ops.csv` |

Indice per Claude (Search Console, dove sono le guide): `README.md` in root.

CSV: delimiter `;`, keyword in colonna `keyword_principale`. Il YAML è allineato al CSV. Non usare i CSV nel repo padre `antoniotrento-net.github.io`.

### Campi YAML che ti servono

```yaml
id: A03
keyword: "lanciare prodotto ai white label"
title: "..."          # titolo piano (puoi accorciare in front matter se troppo lungo, tieni l’intento)
slug: lanciare-prodotto-ai-white-label
date: "2026-08-20 07:30"     # data di USCITA pubblica
date_file: "2026-08-20"      # prefisso del NOME FILE
pillar: web-prodotto
status: planned | written
```

- `status: written` → il post (almeno IT) esiste già. **Non** duplicarlo. Non cambiarne il permalink.
- `status: planned` → da scrivere. Usa **esattamente** `date_file` e `slug`.

### Finestra drip (impostata il 19 ago 2026)

I 20 pezzi già online restano nel **passato** (gen–17 ago 2026). Non ritoccarli le date.

I 127 `planned` escono **uno al giorno**:

| Serie | Id | Uscita |
|---|---|---|
| A restante | 29 pezzi `planned` in ordine di piano | 20 ago 2026 → 17 set 2026 |
| B stack | B01–B49 | 18 set 2026 → 5 nov 2026 |
| C PMI ops | C01–C49 | 6 nov 2026 → 24 dic 2026 |

IT e EN dello **stesso** pezzo: **stessa** `date:` e stesso prefisso file (`date_file`). Due URL lo stesso giorno vanno bene (hreflang). Due pezzi **diversi** lo stesso giorno no.

---

## 3. Come si chiama il file

```
_posts/{date_file}-{slug}.md          # italiano
_posts/{date_file}-{slug-en}.md       # inglese
```

Esempio A03 (uscita 20 agosto 2026, anche se lo scrivi il 19):

```
_posts/2026-08-20-lanciare-prodotto-ai-white-label.md
_posts/2026-08-20-<slug-inglese>.md
```

Obbligatorio:

- Prefisso file = giorno in `date:` = `date_file` del YAML.
- **Non** usare la data di oggi “perché lo sto scrivendo ora”.
- **Non** usare date del CSV vecchio (ago 2026–feb 2027 del piano originale).
- Lo slug nel nome file IT = campo `slug` del YAML. Permalink IT = `/it/blog/{slug}/`.
- Lo slug EN lo scegli tu (inglese, kebab-case). Permalink EN = `/en/blog/{slug-en}/`.
- L’URL pubblico **non** contiene la data. Il permalink è esplicito. Se sbagli il permalink, rompi l’URL per sempre: non “sistemarlo dopo”.

Jekyll: se manca `date:` nel front matter, usa il prefisso del filename. Devono coincidere comunque.

---

## 4. Front matter — copia questo stampo

### Italiano

```yaml
---
lang: it
permalink: /it/blog/{slug}/
alt_url: /en/blog/{slug-en}/
title: "..."
date: {date_file} 07:30:00 +0200
author: "Antonio Trento"
description: "..."
keywords: ["keyword principale", "secondaria 1", "secondaria 2", "secondaria 3", "secondaria 4"]
image: /assets/images/posts/{slug}.jpg
pillar: {pillar dal YAML}
related: [/it/blog/{slug-correlato-1}/, /it/blog/{slug-correlato-2}/]
---
```

`date:` esempio reale: `2026-08-20 07:30:00 +0200`

### Inglese

```yaml
---
lang: en
permalink: /en/blog/{slug-en}/
alt_url: /it/blog/{slug}/
title: "..."
date: {stesso date_file} 07:30:00 +0200
author: "Antonio Trento"
description: "..."
keywords: ["..."]
image: /assets/images/posts/{slug}.jpg
pillar: {stessa chiave del YAML IT, es. prodotti-dati}
related: [/en/blog/{slug-en-correlato-1}/, /en/blog/{slug-en-correlato-2}/]
---
```

Regole:

- `lang` obbligatorio (`it` o `en`). Senza, i filtri home/nav si rompono.
- `permalink` obbligatorio e deve contenere `/it/` o `/en/`.
- `alt_url` **solo se il twin esiste nello stesso commit** (o esiste già). Se pubblichi solo IT, **ometti** `alt_url`. Non puntare a un EN 404: Search Console si riempie di errori hreflang.
- `image:` stesso path IT e EN. Un solo JPG, slug **italiano**.
- `pillar:` chiave in `_data/pillars.yml` (è nel YAML del pezzo). Anche se la guida pillar è ancora stub.
- `related:` permalink che **esistono già** (o che stai creando nello stesso commit). Max 2. Stessa lingua.
- Non inventare `sitemap: false` sui post buoni. I post normali devono essere indicizzabili **quando la data è arrivata**.
- Non mettere date nel futuro **e** `sitemap: false`: `future: false` basta.

---

## 5. Copertina

- Path: `assets/images/posts/{slug-it}.jpg`
- Formato: JPG, ~1536×1024, qualità ~82.
- Stile: editoriale fotorealistico, non mockup SaaS generico, non testo enorme nell’immagine.
- IT e EN **condividono** lo stesso file.
- Senza `image:` la card in home/guide è più povera; sui post live ce l’abbiamo sempre. Mettila.
- Non dichiarare `image:` se il file non è nel repo.

---

## 6. Corpo del pezzo (qualità — qui è morto il blog vecchio)

Identità: **Antonio Trento**, System Architect & AI Integrator. Sito: https://antoniotrento.net.
Parli a titolari, founder, responsabili di PMI italiane. Non a un corso di data science.

Il CSV ha `prompt_articolo`: usalo come brief, non copiare uno scheletro identico su 30 pezzi.

Obbligatorio nel pezzo:

1. Un **problema concreto** (soldi, tempo, clienti, rischio) nelle prime righe.
2. Qualche **numero** o stima onesta (costo, giorni, persone), non “l’AI rivoluziona”.
3. **È per te / non è per te** (chi deve chiudere il tab).
4. Link interno alla **pillar** e a 1–2 post correlati già online (o `related:`).
5. Tono diretto, un po’ pungente, concreto. Niente magazine, niente tutorial astratto.

Vietato (è la fattoria deindicizzata su antoniotrento.net):

- Titoli a stampo: «Sviluppo di agenti AI per la gestione di X».
- Copione fisso: Cos’è → Come funziona → Vantaggi e sfide → FAQ → Conclusione.
- Enciclopedia da 1200 parole che non cambia una decisione.
- Keyword stuffing della keyword in ogni H2.
- Promettere un prodotto che il resto del sito non sostiene.

Lunghezza: i pezzi live sono sostanziosi (spesso 1500–2500 parole equivalenti), ma **pieni**. Corto e vero batte lungo e vuoto.

EN: traduzione fedele dell’IT (stessa struttura, stesso pezzo), non un articolo diverso. Stesso `date`, stessa copertina, `related` verso gli slug EN.

Dopo il corpo: il layout aggiunge da solo back-link, correlati, CTA, popup. Non duplicare un mega-CTA nel markdown.

---

## 7. Checklist prima del commit (ogni pezzo)

1. Ho aperto `editorial_plan.yml`, trovato l’`id`, copiato `date_file`, `slug`, `pillar`.
2. Nome file = `{date_file}-{slug}.md` (IT) e `{date_file}-{slug-en}.md` (EN).
3. `date:` nel front matter = `{date_file} 07:30:00 +0200`. **Non oggi**, se il piano è futuro.
4. Permalink IT/EN corretti; `alt_url` reciproci **solo** se entrambi i file ci sono.
5. JPG copertina nel path dichiarato.
6. `related:` punti a URL che esistono.
7. Non ho toccato permalink, date o slug dei 20 post `status: written`.
8. Non ho datato un lotto di pezzi diversi tutti a oggi.
9. Aggiorno nel YAML `status: written` su quell’`id` quando IT (e EN) sono nel repo.
10. Commit mirato (`git add` dei file del pezzo + copertina + riga YAML). **Non** `git add -A` se un altro agente sta scrivendo in parallelo.
11. Ho aperto `it/pillar/{pillar_key}` (e twin EN): è stub o viva? Se il cluster ha abbastanza pezzi scritti, non lasciare la guida noindex “per dopo” — vedi sezione 9.

Push su `main` → Pages build. Se `date:` è futura, il post **non** compare comunque fino al giorno + drip (o un build in quel giorno).

---

## 8. Cosa non toccare

- Permalink dei post già online.
- `CNAME`, `robots.txt`, `url:` / `baseurl:` in `_config.yml`.
- `future: false` (se lo togli, i file futuri escono tutti).
- `.github/workflows/drip-publish.yml` (a meno di un bug chiaro).
- I 256 post e la sitemap del **sito principale** (`antoniotrento-net.github.io`): archivio `noindex`. Non 301 verso il blog nuovo. Non rianimare quella fattoria.
- Guide pillar stub: niente `image:` + togliere `sitemap: false` se il corpo è ancora un paragrafo. Vedi seo-mappa.

---

## 9. Guide pillar — controllale, o ci perdiamo

I post escono a goccia. Le pillar **no**. Drip publish ricostruisce Pages, **non** accende una guida. Se nessuno le rivede, restano `noindex` per mesi anche quando il cluster è pieno di articoli buoni: spreco di hub, non penalità. **Non aspettare** che Antonio dica “accendi questa guida”.

### Cosa fare dopo ogni lotto (e a fine serie di un cluster)

Apri il file della pillar del pezzo che hai appena scritto (IT **e** twin EN):

| File | Esempio |
|---|---|
| IT | `it/pillar/{pillar_key}.md` o `.html` |
| EN | permalink in `alt_url:` / `_data/pillars.yml` |

Due stati, basta il front matter:

| | Stub (fuori index) | Viva (in index) |
|---|---|---|
| Copertina | **niente** `image:` | `image: /assets/images/pillars/{slug-it}.jpg` |
| Sitemap | `sitemap: false` | riga **tolta** |
| Google | `noindex, follow` (`seo.html` se manca `image:`) | indicizzabile |
| Corpo | un paragrafo / “in arrivo” | guida vera + link agli articoli del cluster |

Live in index oggi (hanno `image:` **e** niente `sitemap: false`): `prodotti-dati`, `app-interne`, `portali-b2b` (+ twin EN).

### Coda accensione — Sezione 1 (tracciata, non a memoria)

Quattro hub hanno **già** corpo + copertina + twin EN. Restano `sitemap: false` **di proposito**: i body linkano articoli ancora in drip, e un hub in index verso URL non uscite è un 404. `seo.html` emette `noindex, follow` se `sitemap: false` (anche con `image:`).

**L’agente che tocca il blog in un giorno ≥ la data sotto DEVE togliere `sitemap: false` da IT e EN di quell’hub, nello stesso commit, e pushare.** Non aspettare Antonio. Spunta la riga quando è fatto.

| Hub IT (`it/pillar/`) | Twin EN (`en/pillar/`) | Togli `sitemap: false` dal (cluster tutto live) | Fatto? |
|---|---|---|---|
| `documenti-flussi.md` | `documents-workflows.md` | **2026-09-12** (dopo A43) | [ ] |
| `web-prodotto.md` | `web-ux-product.md` | **2026-09-13** (dopo A44) | [ ] |
| `comprare-software.md` | `buying-custom-software.md` | **2026-09-16** (dopo A47) | [ ] |
| `prenotazioni-agenda.md` | `booking-scheduling.md` | **2026-09-17** (dopo A48) | [ ] |

Le altre coppie sono stub (niente `image:`).

### Quando metterla in index

- **Non** al primo post del cluster. Lo stub va bene: i pezzi si indicizzano da soli, la pagina “Prossimamente” non deve stare in Google.
- **Sì** quando in quel cluster hai abbastanza articoli `written` (o la serie di quella pillar è chiusa) da poter scrivere una guida che **cambia una decisione**, con link interni ai post — non un placeholder. Per i quattro hub sopra la data è già fissata: non “quando ti ricordi”.
- Accendere = corpo vero (IT+EN) + copertina JPG + **togliere** `sitemap: false` + push. Finché c’è `sitemap: false`, `seo.html` tiene il noindex anche se c’è `image:`.
- **Non** mettere `image:` su uno stub da un paragrafo: quella è la leva che la fa comparire come mappa viva in `/it/guide/`.

Un post può (e deve) avere `pillar: web-prodotto` anche se quella guida è ancora stub. I back-link nel layout restano; l’URL della guida non cambia quando la accendi.

---

## 10. Errori frequenti (non farli)

| Errore | Cosa succede |
|---|---|
| `date:` = oggi su 15 file planned | 15 URL in sitemap al prossimo build = scaled content |
| Nome file `2026-08-19-...` e `date: 2026-09-18` | Incoerenza Jekyll; l’agente successivo si confonde |
| `alt_url` verso uno slug EN non ancora creato | hreflang → 404 in Search Console |
| Copertina IT e EN file diversi | spreco; il path è uno, slug IT |
| Riscrivere un post `written` cambiando permalink | rompi URL già eventualmente in giro |
| Lanciare Drip publish 40 volte | inutile; non accelera Google |
| Disallow in robots.txt sull’archivio vecchio | Google non rilegge il noindex |
| Copiare lo stesso H2 su tutta la serie B | classificato di nuovo come fattoria, stavolta su questo dominio |

---

## 11. Mini esempio (A03)

Dal YAML (planned al 19 ago 2026):

- `date_file: 2026-08-20`
- `slug: lanciare-prodotto-ai-white-label`
- `pillar: web-prodotto`

File: `_posts/2026-08-20-lanciare-prodotto-ai-white-label.md`

```yaml
date: 2026-08-20 07:30:00 +0200
permalink: /it/blog/lanciare-prodotto-ai-white-label/
image: /assets/images/posts/lanciare-prodotto-ai-white-label.jpg
```

Scritto il 19 agosto, pushato il 19 agosto → **non** è in home né in sitemap fino al rebuild del **20** agosto (Drip ~07:30, o un push quel giorno).
