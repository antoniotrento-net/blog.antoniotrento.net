# Mappa SEO — blog.antoniotrento.net

Fonte di verità. Non fidarti della memoria: se cambi una regola, aggiorna **questa** pagina.

Stato al 19 agosto 2026.

---

## Azioni tue (non le fa il codice)

Farle in quest’ordine. Spuntale qui quando sono fatte.

### 1. Search Console — blog nuovo (subito, dopo il deploy Pages)

- [ ] Aggiungi la proprietà **Prefisso URL** `https://blog.antoniotrento.net/`
- [ ] Verifica (DNS o file HTML, come preferisci)
- [ ] Invia la sitemap: `https://blog.antoniotrento.net/sitemap.xml`
- [ ] Ispeziona **solo 4 URL**, non 80: `https://blog.antoniotrento.net/it/` · `/it/guide/` · un pillar vivo (`/it/pillar/prodotti-dati/` o app-interne o portali-b2b) · un post (es. `/it/blog/dashboard-che-non-si-usano/`)
- [ ] Se l’ispezione dice «trovato ma non indicizzato», «richiedi indicizzazione» su quelle 4. Stop.

### 2. Search Console — sito principale (stesso giro)

- [ ] Proprietà `https://antoniotrento.net/`
- [ ] Re-invia `https://antoniotrento.net/sitemap.xml` (ora **senza** i 256 post)
- [ ] Non chiedere l’indicizzazione delle URL vecchie. Il `noindex` si prende da solo, in settimane
- [ ] Non cancellare `/blog/` e non fare 301 di massa verso home o verso il blog nuovo

### 3. Come pubblichi da ora (goccia-a-goccia)

Questa settimana **prepari i file**. Non devono andare tutti online. `future: false` + Action `drip-publish.yml` (rebuild ogni mattina): Google vede **una coppia IT+EN al giorno**, non 127 URL in un crawl.

- Nome file `_posts/YYYY-MM-DD-slug.md` = `date:` = `date_file` nel piano (non il giorno in cui scrivi)
- 1 pezzo al giorno nel calendario (IT+EN stessa data). Non 5–6
- Serie A restante: 20 ago → 17 set 2026. Poi B (stack) 18 set → 5 nov. Poi C (PMI) 6 nov → 24 dic
- Se il file non esiste ancora, quel giorno non esce niente. Nessun buco SEO: meglio un giorno vuoto che un pezzo-fattoria
- `alt_url` solo se il twin esiste già
- Guida stub → indicizzabile solo con corpo + `image:` + togliere `sitemap: false`
- Dopo il primo push dell’Action: GitHub → Actions → **Drip publish** → Run workflow (una volta, per verificare)

### 4. Non toccare

Permalink dei post, `CNAME`, `robots.txt`, `url:` in `_config.yml`. Non `Disallow` l’archivio vecchio in robots.txt (Google deve leggere il noindex).

---

## Perché le date sono nel passato (e non su tutto il 2026)

Oggi è **19 agosto 2026**. Mettere i post a settembre–dicembre 2026 li lascerebbe di nuovo **nel futuro**. La finestra onesta è gennaio → metà agosto 2026.

- **Nome file** `_posts/YYYY-MM-DD-slug.md` e front matter `date:` devono coincidere.
- **Permalink** = URL pubblico (non toccare: `/it/blog/slug/`). Jekyll non mette la data nell’URL.

IT e EN dello stesso pezzo hanno la **stessa** data.

| Data (file + `date:`) | Slug IT |
|---|---|
| 2026-01-20 | cruscotto-aziendale-titolare |
| 2026-01-31 | report-vendite-in-ritardo |
| 2026-02-11 | app-interna-aziendale-copia-incolla |
| 2026-02-22 | portale-b2b-clienti |
| 2026-03-05 | listini-personalizzati-b2b-software |
| 2026-03-16 | app-tecnici-sul-campo |
| 2026-03-27 | data-analyst-non-basta |
| 2026-04-07 | quanto-abbiamo-venduto-ieri |
| 2026-04-18 | giacenze-magazzino-disallineate |
| 2026-04-29 | app-ferie-turni-pmi |
| 2026-05-10 | customer-care-ticket-ripetuti |
| 2026-05-21 | ordini-produzione-digitale-pmi |
| 2026-06-01 | area-riservata-clienti-su-misura |
| 2026-06-12 | pubblicare-annunci-immobiliari-automatico |
| 2026-06-23 | kpi-sbagliati-azienda |
| 2026-07-04 | cruscotto-multi-sede |
| 2026-07-15 | portale-dossier-credito |
| 2026-07-26 | software-locale-ristorazione-magazzino |
| 2026-08-06 | gestione-soci-associazione-software |
| 2026-08-17 | dashboard-che-non-si-usano |

I pezzi **già online** restano nel passato (tabella sopra). Quelli **ancora da scrivere** hanno date **future**: un pezzo al giorno, 20 agosto → 24 dicembre 2026. File in `_posts/` con data futura non vanno in sitemap (`future: false`). L’Action `.github/workflows/drip-publish.yml` ricostruisce il sito ogni mattina.

I **tre** CSV stanno in `antoniotrento-net.github.io/_piano_editoriale/` e in `_data/editorial_plan.yml`.

| Serie | File | Pezzi | Finestra `date` | Online oggi |
|---|---|---|---|---|
| A clienti | `piano-editoriale-2026-clienti.csv` | 49 | 20 live nel passato; 29 drip 20 ago → 17 set | 20 coppie IT+EN |
| B stack | `piano-editoriale-2026-livello2-stack.csv` | 49 | 18 set → 5 nov, 1 al giorno | nessuno |
| C PMI ops | `piano-editoriale-2026-livello3-pmi-ops.csv` | 49 | 6 nov → 24 dic, 1 al giorno | nessuno |

Questa settimana: **scrivi** i file. `date:` e nome file = data del piano (futura), non oggi. Se usi la data di oggi su 30 file, escono tutti al prossimo build.

`date_file` nel YAML è il prefisso da usare quando crei il markdown. Calendario keyword per keyword: `_data/editorial_plan.yml` (`status: planned`).

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
| 16 | Rebuild mattutino per i post datati nel futuro | `.github/workflows/drip-publish.yml` |

### Fatti sul sito principale

| # | Cosa | Dove |
|---|---|---|
| 10 | Nav **Blog** → `https://blog.antoniotrento.net/it/` | `_config.yml` `navigation` |
| 11 | Footer Blog stesso URL | `_includes/antigravity_footer.html` |
| 12 | «Vedi tutti gli articoli» in home | `index.html` sezione `#blog` |
| 13 | `relative_url` non spezza gli URL `https://` | `_includes/antigravity_nav.html` |
| 14 | Home: 3 card fisse del blog nuovo (niente loop `site.posts`) | `antoniotrento-net.github.io/index.html` |
| 15 | Archivio vecchio `noindex, follow` + fuori sitemap | post layout, `/blog/`, `sitemap.xml` |

`/blog/` sul principale **resta online** (archivio). `noindex, follow`. Non cancellarlo: ha URL già in giro. La nav non ci punta più.

### Aperti (quando sei pronto)

| # | Cosa | Perché non è automatico |
|---|---|---|
| A | Search Console + sitemap `https://blog.antoniotrento.net/sitemap.xml` | Lo fai tu, dopo che Pages ha buildato queste date |
| B | Ispezione 4 URL: `/it/`, `/it/guide/`, un pillar vivo, un post | Non bombardare «richiedi indicizzazione» su 80 URL |
| D | FAQPage JSON-LD | Serve `faq:` in front matter, non si estrae dal markdown in modo sicuro |
| E | Rebuild goccia-a-goccia | Fatto: Action `drip-publish.yml`. Lanciala a mano una volta. |
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

## Più articoli nello stesso giorno

Google **non** vieta 2 URL lo stesso giorno se sono IT+EN dello stesso pezzo (hreflang). Il rischio è **contenuto scalato**: 30 scheletri identici scritti in un weekend e datati tutti oggi. Preparare i file in blocco va bene. Farli uscire in blocco no. Un giorno senza pezzo è meglio di un pezzo-fattoria.

---

## File da non toccare a caso

- Permalink dei post (URL pubblici).
- `CNAME`, `robots.txt`, `url:` in `_config.yml`.

Nome file `_posts/YYYY-MM-DD-slug.md`: deve coincidere con `date:`. Non è l’URL.
