# blog.antoniotrento.net

Blog multilingua (IT/EN) di [antoniotrento.net](https://antoniotrento.net). Jekyll + GitHub Pages.
Palette Google-brand, Inter; cartelle `/it/` e `/en/`.

**Claude / agenti: parti da questa pagina.** I dettagli lunghi stanno nei file linkati, non duplicarli a memoria. La cartella `_piano_editoriale/` è in `exclude` di Jekyll: è documentazione nel repo, **non** pagine pubbliche.

---

## Indice per Claude (dove sta ogni cosa)

| Cosa | File | Quando leggerlo |
|---|---|---|
| **Questo indice + Search Console** | `README.md` (qui) | Sempre, all’inizio della chat |
| **Come scrivere un post** (date, Drip publish, front matter, qualità, checklist) | [`_piano_editoriale/COME-SCRIVERE-I-POST.md`](_piano_editoriale/COME-SCRIVERE-I-POST.md) | Prima di creare/modificare `_posts/` |
| **Pillar stub vs index** (non si accendono da sole) | stesso playbook, **sezione 9** | Dopo ogni lotto di post e a fine cluster: ha corpo? va in sitemap? |
| **Mappa SEO** (regole tecniche, stub pillar, hreflang) | [`_piano_editoriale/seo-mappa.md`](_piano_editoriale/seo-mappa.md) | SEO, date live, come si accende uno stub |
| Calendario id / slug / `date_file` / status | [`_data/editorial_plan.yml`](_data/editorial_plan.yml) | Scegliere il prossimo pezzo `planned` |
| Piano A — clienti (prompt, keyword, copertina) | [`_piano_editoriale/piano-editoriale-2026-clienti.csv`](_piano_editoriale/piano-editoriale-2026-clienti.csv) | Scrivere un pezzo serie A |
| Piano B — stack sovrano | [`_piano_editoriale/piano-editoriale-2026-livello2-stack.csv`](_piano_editoriale/piano-editoriale-2026-livello2-stack.csv) | Serie B |
| Piano C — PMI ops | [`_piano_editoriale/piano-editoriale-2026-livello3-pmi-ops.csv`](_piano_editoriale/piano-editoriale-2026-livello3-pmi-ops.csv) | Serie C |
| Puntatore automatico Claude Code | [`CLAUDE.md`](CLAUDE.md) | Letto da solo |
| Puntatore altri agenti | [`AGENTS.md`](AGENTS.md) | Letto da solo |
| Sveglia Pages (Drip publish) | [`.github/workflows/drip-publish.yml`](.github/workflows/drip-publish.yml) | Non lanciarla a ogni articolo |
| Sitemap del blog | **Non è un file nel repo.** Plugin `jekyll-sitemap` in `_config.yml`. URL live: `https://blog.antoniotrento.net/sitemap.xml` | Search Console. Non copiare il `sitemap.xml` del sito principale |
| Post live e in coda | `_posts/YYYY-MM-DD-slug.md` | `date:` futura = non ancora sul sito |

CSV: delimiter `;`. Colonne: `titolo`, `keyword_principale`, `keyword_secondarie`, `descrizione`, `prompt_articolo`, `prompt_immagine`, dimensioni, `data_pubblicazione`. Allineati a `editorial_plan.yml`. **Fonte in questo repo**, non in `antoniotrento-net.github.io`.

---

## Azioni Search Console (le fa Antonio, non il codice)

Spuntale in [`_piano_editoriale/seo-mappa.md`](_piano_editoriale/seo-mappa.md) quando sono fatte. Qui il riassunto così non si perdono.

### A. Blog nuovo — `https://blog.antoniotrento.net/`

1. Aggiungi proprietà **Prefisso URL** `https://blog.antoniotrento.net/`
2. Verifica (DNS o file HTML)
3. Invia sitemap: `https://blog.antoniotrento.net/sitemap.xml` (generata al build, **non** c’è nel repo)
4. Ispeziona **solo 4 URL**, non 80 e non tutto il piano:
   - `https://blog.antoniotrento.net/it/`
   - `https://blog.antoniotrento.net/it/guide/`
   - un pillar vivo, es. `https://blog.antoniotrento.net/it/pillar/prodotti-dati/`
   - un post, es. `https://blog.antoniotrento.net/it/blog/dashboard-che-non-si-usano/`
5. Se un’ispezione dice «trovato ma non indicizzato», **Richiedi indicizzazione** su quelle 4. Stop.
6. I post con data futura **non** sono in sitemap: non chiedere l’indicizzazione di URL che Drip non ha ancora pubblicato.
7. Non bombardare «richiedi indicizzazione» su 29 o 127 URL il giorno in cui Claude scrive i file.

### B. Fattoria vecchia — `https://antoniotrento.net/` (delistare)

Già fatto nel codice (repo `antoniotrento-net.github.io`): i ~256 post hanno `noindex, follow`; non sono in sitemap; `/blog/` è archivio noindex; la home non li teaser più.

Cosa resta da fare **in Search Console** sulla proprietà `https://antoniotrento.net/`:

1. Re-invia la sitemap `https://antoniotrento.net/sitemap.xml` (ora **senza** i 256 post).
2. **Non** usare «Richiedi indicizzazione» sulle URL vecchie: le faresti rivedere come se volessi che salgano.
3. **Non** cancellare i file e **non** fare 301 di massa verso `/` o verso `blog.antoniotrento.net` (doorway / soft 404).
4. Non `Disallow` in `robots.txt` quei post: Google deve poterli **rileggere** per vedere il `noindex`.
5. Aspetta settimane. Il noindex toglie dai risultati dopo il recrawl, non in un’ora.
6. Opzionale, se vuoi nasconderle prima: Search Console → **Removals** (rimozioni temporanee, ~6 mesi). I post **non** stanno tutti sotto `/blog/` (permalink `/:title/`), quindi non basta un prefisso `/blog/`. Meglio lasciare il noindex. Removals non sostituisce il noindex.
7. Controlla **Pagine** (indicizzazione): col tempo le URL vecchie devono passare a «Esclusa / esclusa dal tag noindex». Non serve ispezionarle tutte.

---

## Drip publish (sveglia, non “drift”)

GitHub Pages **non** ricostruisce a mezzanotte. `future: false` nasconde i post con `date:` futura, ma senza un build nel giorno nuovo non escono da soli.

- Workflow: **Drip publish** — ogni mattina ~07:30 Italia chiede un rebuild Pages.
- Test manuale già OK (19 ago 2026). **Non** va rilanciato ogni giorno.
- Non scrive articoli. Se manca il `.md` di quel giorno, non esce niente (va bene).
- Dettaglio per chi scrive i file: [`COME-SCRIVERE-I-POST.md`](_piano_editoriale/COME-SCRIVERE-I-POST.md) sezioni 0–1.

Calendario drip (1 pezzo/giorno, IT+EN stessa data):

| Serie | Uscita |
|---|---|
| 20 A già online | date nel passato (gen–17 ago 2026) — non ritoccare |
| 29 A `planned` | 20 ago → 17 set 2026 |
| 49 B stack | 18 set → 5 nov 2026 |
| 49 C PMI | 6 nov → 24 dic 2026 |

`date:` e nome file = `date_file` nel YAML, **non** il giorno in cui Claude scrive.

---

## Come si scrive un articolo

Obbligatorio: [`_piano_editoriale/COME-SCRIVERE-I-POST.md`](_piano_editoriale/COME-SCRIVERE-I-POST.md)

1. Apri `editorial_plan.yml` → id `planned` → copia `date_file`, `slug`, `pillar`.
2. Apri il CSV della serie → riga `keyword_principale` → usa `prompt_articolo`.
3. Crea `_posts/{date_file}-{slug}.md` + twin EN con **la stessa** data.
4. Copertina `assets/images/posts/{slug-it}.jpg` (un file per IT e EN).
5. `alt_url` solo se il twin esiste. Non datare un lotto di pezzi diversi a oggi.
6. YAML: `status: written`. `git add` solo i file di quel pezzo. Non `git add -A` in parallelo.

Front matter (riassunto; lo stampo completo è nel playbook):

```yaml
---
lang: it
permalink: /it/blog/<slug>/
alt_url: /en/blog/<slug-en>/
title: "..."
date: 2026-08-20 07:30:00 +0200
author: "Antonio Trento"
description: "..."
keywords: ["..."]
image: /assets/images/posts/<slug-it>.jpg
pillar: prodotti-dati
related: [/it/blog/altro/]
---
```

Qualità: problema concreto, numeri, è-per-te / non-è-per-te, link alla pillar. Vietato lo stampo «Sviluppo di agenti AI per X» / Cos’è / Vantaggi / FAQ (è la fattoria deindicizzata sul sito principale).

---

## Struttura del sito (codice)

```
_config.yml            url, future: false, testi marketing per lingua
_data/
  editorial_plan.yml   calendario A/B/C
  navigation_it.yml / navigation_en.yml
  pillars.yml          cluster; in index: prodotti-dati, app-interne, portali-b2b. Hubs scritti + cover, ancora sitemap:false: comprare-software, web-prodotto, documenti-flussi, prenotazioni-agenda
  site_links.yml
_layouts/              default, home, post, pillar, guides
_includes/             seo.html (noindex stub + hreflang se twin esiste)
_posts/                YYYY-MM-DD-slug.md  lang: it|en
it/  en/               home, guide, pillar
_piano_editoriale/     guide + CSV (exclude Jekyll)
.github/workflows/drip-publish.yml
```

`future: false`: post con data futura fuori da sito e sitemap finché non passa il giorno **e** c’è un rebuild (push o Drip).

---

## Sviluppo locale

Antonio di solito **non** previewa in locale: commit + push su `main` → GitHub Pages.

```bash
bundle install
bundle exec jekyll serve
# http://localhost:4000/it/
```
