# Mappa SEO — blog.antoniotrento.net

Fonte di verità. Non fidarti della memoria: se cambi una regola, aggiorna **questa** pagina.

Stato al 19 agosto 2026. Search Console **non** è ancora collegata (voluto).

---

## Perché le date sono nel passato (e non su tutto il 2026)

Oggi è **19 agosto 2026**. Mettere i post a settembre–dicembre 2026 li lascerebbe di nuovo **nel futuro**. La finestra onesta è gennaio → metà agosto 2026.

- **Nome file** = piano editoriale (non toccare, è il calendario).
- **Front matter `date:`** = data visibile / sitemap / JSON-LD.

IT e EN dello stesso pezzo hanno la **stessa** data pubblicata.

| Piano (nome file) | Pubblicato | Slug IT |
|---|---|---|
| 2026-08-18 | 2026-01-20 | cruscotto-aziendale-titolare |
| 2026-08-20 | 2026-01-31 | report-vendite-in-ritardo |
| 2026-09-01 | 2026-02-11 | app-interna-aziendale-copia-incolla |
| 2026-09-03 | 2026-02-22 | portale-b2b-clienti |
| 2026-09-17 | 2026-03-05 | listini-personalizzati-b2b-software |
| 2026-09-24 | 2026-03-16 | app-tecnici-sul-campo |
| 2026-10-06 | 2026-03-27 | data-analyst-non-basta |
| 2026-10-15 | 2026-04-07 | quanto-abbiamo-venduto-ieri |
| 2026-10-20 | 2026-04-18 | giacenze-magazzino-disallineate |
| 2026-10-22 | 2026-04-29 | app-ferie-turni-pmi |
| 2026-10-27 | 2026-05-10 | customer-care-ticket-ripetuti |
| 2026-11-05 | 2026-05-21 | ordini-produzione-digitale-pmi |
| 2026-11-10 | 2026-06-01 | area-riservata-clienti-su-misura |
| 2026-11-19 | 2026-06-12 | pubblicare-annunci-immobiliari-automatico |
| 2026-11-26 | 2026-06-23 | kpi-sbagliati-azienda |
| 2026-12-17 | 2026-07-04 | cruscotto-multi-sede |
| 2026-12-29 | 2026-07-15 | portale-dossier-credito |
| 2026-12-31 | 2026-07-26 | software-locale-ristorazione-magazzino |
| 2027-01-05 | 2026-08-06 | gestione-soci-associazione-software |
| 2027-02-02 | 2026-08-17 | dashboard-che-non-si-usano |

Nuovo articolo: `date:` ≤ oggi. Se vuoi programmarlo, `date:` futura + `future: false` (resta fuori da sito e sitemap finché non passa il giorno **e** c’è un rebuild: GitHub Pages non pubblica da solo a mezzanotte, serve un push o un Action).

CSV piano (`piano-editoriale-2026-clienti.csv`) e `_data/editorial_plan.yml` (serie A) usano le **stesse** date `date:`.

`date_file` sui pezzi già online resta il nome file originale (`2026-08-18-…`). Sui pezzi di questa settimana `date_file` = giorno di pubblicazione (19–23 agosto), da usare quando crei il file.

### Questa settimana (ancora da scrivere / pubblicare)

29 pezzi restanti della serie clienti, in ordine di piano, 5–6 al giorno. Quando li pubblichi, `date:` nel post = questa data (non oltre il 23 agosto).

| Giorno | Keyword |
|---|---|
| 2026-08-19 | lanciare prodotto ai white label; sito vetrina vs prodotto digitale; pipeline commerciale unica; poc intelligenza artificiale fallito; ridurre no show prenotazioni; riscrivere software gestionale legacy |
| 2026-08-20 | software gestione pratiche; mvp software 90 giorni; prodotto llm vs chatbot; sito lento errori utenti; ricerca documenti aziendali pdf; overbooking canali prenotazione |
| 2026-08-21 | limiti no code azienda; costo non digitalizzare processi; lead che non vengono lavorati; software rinnovi scadenze clienti; abbandono prenotazione carrello; calendario professionale multi operatore |
| 2026-08-22 | frontend per software house; prima di sviluppare un app; cosa include software su misura; manutenzione software dopo go live; dal preventivo alla fattura software; piattaforma formazione interna |
| 2026-08-23 | white label software agenzia; rfi software come rispondere; passare da consulenza a prodotto; feature promessa non esiste; software studio professionale completo |

Serie B (stack) e C (PMI ops) nei CSV livello 2/3 **non** sono state toccate: non sono i post già online.

---

## Accorgimenti (fatti / aperti)

### Fatti nel blog

| # | Cosa | Dove |
|---|---|---|
| 1 | Date nel passato, ordine del piano conservato | `_posts/*.md` `date:` |
| 2 | `future: false` | `_config.yml` |
| 3 | Homepage e hero contano solo post `date <= oggi` | `_layouts/home.html`, `_includes/home-hero.html` |
| 4 | Stub pillar (`image:` assente) fuori sitemap | `sitemap: false` nei file `it/pillar/` e `en/pillar/` |
| 5 | Stub pillar `noindex, follow` | `_includes/seo.html` |
| 6 | hreflang solo se `alt_url` esiste come pagina/post | `_includes/seo.html` |
| 7 | JSON-LD `BlogPosting` + `BreadcrumbList` sui post; `CollectionPage` sulle guide vive; `WebSite` su home/indice | `_includes/seo.html` |
| 8 | Canonical, og, twitter, x-default `/it/` | già c’era, restano |
| 9 | Root `/` `noindex` + redirect | `index.html` |

### Fatti sul sito principale

| # | Cosa | Dove |
|---|---|---|
| 10 | Nav **Blog** → `https://blog.antoniotrento.net/it/` | `_config.yml` `navigation` |
| 11 | Footer Blog stesso URL | `_includes/antigravity_footer.html` |
| 12 | «Vedi tutti gli articoli» in home | `index.html` sezione `#blog` |
| 13 | `relative_url` non spezza gli URL `https://` | `_includes/antigravity_nav.html` |

`/blog/` sul principale **resta online** (archivio vecchio). Non cancellarlo: ha URL già in giro. La nav non ci punta più.

### Aperti (quando sei pronto)

| # | Cosa | Perché non è automatico |
|---|---|---|
| A | Search Console + sitemap `https://blog.antoniotrento.net/sitemap.xml` | Lo fai tu, dopo che Pages ha buildato queste date |
| B | Ispezione 4 URL: `/it/`, `/it/guide/`, un pillar vivo, un post | Non bombardare «richiedi indicizzazione» su 80 URL |
| C | Teaser home del principale: ancora loop `site.posts limit:3` verso l’archivio `/blog/` | Piano i18n fase 1: sostituire con 3 card fisse del blog nuovo |
| D | FAQPage JSON-LD | Serve `faq:` in front matter, non si estrae dal markdown in modo sicuro |
| E | Rebuild goccia-a-goccia | Action cron se vorrai date future vere |
| F | Copertina + corpo su uno stub → togliere `sitemap: false` e l’assenza di `image:` lo fa indicizzare | Checklist sotto |

---

## Quando una guida stub diventa indicizzabile

1. Scrivi il corpo (non un paragrafo).
2. Metti `image: /assets/images/pillars/<slug>.jpg`.
3. **Togli** `sitemap: false` dal front matter.
4. Push. `seo.html` toglie il `noindex` da solo se c’è `image:`.

---

## hreflang

- Obbligatorio `alt_url:` verso il twin **che esiste**.
- Se manca il twin: niente alternate sull’altra lingua (niente 404 in Search Console).
- `x-default` = `/it/`.

---

## AI / spam

Non è un accorgimento tecnico. Regola: un problema, numeri, «è per te / non è per te», link interni alla pillar. Non aprire GSC il giorno in cui pubblichi 40 URL se le date fossero ancora future (ora non lo sono).

---

## File da non toccare a caso

- Permalink dei post (URL pubblici).
- Nome file `_posts/YYYY-MM-DD-slug.md` (è il piano).
- `CNAME`, `robots.txt`, `url:` in `_config.yml`.
