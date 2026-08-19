# blog.antoniotrento.net

Blog multilingua (IT/EN) di [antoniotrento.net](https://antoniotrento.net), su Jekyll + GitHub Pages.
Grafica ereditata dal sito principale (palette Google-brand, Inter); architettura multilingua nello stile di qwibo.

## Struttura

```
_config.yml            Config + testi marketing (popup, CTA) per lingua
_data/
  navigation_it.yml    Voci nav IT (l'ultima, main:true, punta al sito principale)
  navigation_en.yml    Voci nav EN
  site_links.yml       Destinazioni sul sito principale (portfolio, contatti, bio) → link building
  pillars.yml          Hub tematici (cluster) per lingua → link building
_layouts/
  default.html         Shell: <head>, grafica, nav, footer, JS
  home.html            Home/listing blog per lingua (/it/, /en/)
  post.html            Articolo + link interni + CTA + correlati + popup
  pillar.html          Pagina pillar (hub di un cluster)
_includes/
  seo.html             Meta + Open Graph + hreflang (IT/EN + x-default)
  antigravity_nav.html Nav (design sito principale + switcher lingua)
  antigravity_footer.html
  internal-links.html  Link building data-driven (pillar + servizi), tutto opzionale
  related-posts.html   Correlati filtrati per lingua/cluster
  popup-down.html      Popup marketing → sito principale
  post-cta.html        CTA fine articolo → sito principale
assets/                antigravity.js, loghi, css
it/  en/               Pagine per lingua (index = home, pillar/)
_posts/                Articoli: YYYY-MM-DD-slug.md con `lang: it|en`
```

## Come si scrive un articolo

**Playbook obbligatorio (date, Drip publish, front matter, qualità):** [`_piano_editoriale/COME-SCRIVERE-I-POST.md`](_piano_editoriale/COME-SCRIVERE-I-POST.md)

Non usare la data di oggi sui pezzi del piano futuro. Riassunto front matter:

```yaml
---
lang: it                                   # OBBLIGATORIO: it | en
permalink: /it/blog/<slug>/                # OBBLIGATORIO: deve contenere /it/ o /en/
alt_url: /en/blog/<slug-en>/               # link alla versione nell'altra lingua (switcher + hreflang)
title: "..."
date: 2026-08-20 07:30:00 +0200            # = date_file del piano, NON oggi
description: "..."                          # usata in card, meta, og
keywords: ["...", "..."]
image: /assets/images/posts/<file>.jpg     # opzionale (copertina)
pillar: prodotti-dati                      # opzionale: chiave in _data/pillars.yml
services: [portfolio, contatti]            # opzionale: chiavi in _data/site_links.yml
related: [/it/blog/altro/]                 # opzionale: override correlati
---
```

### Link building (modello misto, tutto opzionale)
- `pillar:` → mostra il box "Fa parte della guida" e collega la pagina pillar del cluster.
- `services:` → bottoni verso pagine del sito principale (portfolio, contatti, bio…).
- `related:` → correlati manuali; altrimenti automatici per lingua/cluster.
Se un campo manca, il relativo blocco semplicemente non compare.

## Sviluppo locale

```bash
bundle install
bundle exec jekyll serve
# http://localhost:4000/it/
```

## Aggiungere una lingua
1. `_data/navigation_<lang>.yml`
2. `<lang>/index.html` (layout: home) + eventuali pillar
3. blocco `<lang>` in `pillars.yml` e `site_links.yml`
4. aggiorna `languages:` in `_config.yml` e i rami lingua negli include
