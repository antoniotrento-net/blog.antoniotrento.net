# Mappa SEO — blog.antoniotrento.net

Fonte di verità. Non fidarti della memoria: se cambi una regola, aggiorna **questa** pagina.

Stato al 19 agosto 2026. Search Console **non** è ancora collegata (voluto).

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

Nuovo articolo: `date:` ≤ oggi. Se vuoi programmarlo, `date:` futura + `future: false` (resta fuori da sito e sitemap finché non passa il giorno **e** c’è un rebuild: GitHub Pages non pubblica da solo a mezzanotte, serve un push o un Action).

I **tre** CSV stanno in `antoniotrento-net.github.io/_piano_editoriale/` e sono tutti in `_data/editorial_plan.yml`. Prima era aggiornata solo la serie A.

| Serie | File | Pezzi | Finestra `date` | Online oggi |
|---|---|---|---|---|
| A clienti | `piano-editoriale-2026-clienti.csv` | 49 | 20 gen → 17 ago (live) + 19–23 ago (da scrivere) | 20 coppie IT+EN |
| B stack | `piano-editoriale-2026-livello2-stack.csv` | 49 | 21 gen → 1 ago, ogni 4 giorni | nessuno |
| C PMI ops | `piano-editoriale-2026-livello3-pmi-ops.csv` | 49 | 23 gen → 3 ago, ogni 4 giorni | nessuno |

B e C **non** vanno scaricati su questa settimana: 98 URL in 5 giorni è il caso da evitare (contenuto scalato). Le date CSV sono calendario; il giorno reale di `date:` nel markdown è il giorno in cui fai push.

`date_file` = prefisso del file markdown. Sui pezzi già online coincide con `date:`. Sui pezzi di questa settimana `date_file` = giorno di pubblicazione (19–23 agosto), da usare quando crei il file.

### Questa settimana (ancora da scrivere / pubblicare)

29 pezzi restanti della **serie A (clienti)**, in ordine di piano, 5–6 al giorno **nel calendario**. Non è un obbligo SEO: meglio `date:` = giorno in cui il pezzo va davvero online (anche 1–2 al giorno). Non pubblicare B o C in blocco insieme ad A.

| Giorno | Keyword |
|---|---|
| 2026-08-19 | lanciare prodotto ai white label; sito vetrina vs prodotto digitale; pipeline commerciale unica; poc intelligenza artificiale fallito; ridurre no show prenotazioni; riscrivere software gestionale legacy |
| 2026-08-20 | software gestione pratiche; mvp software 90 giorni; prodotto llm vs chatbot; sito lento errori utenti; ricerca documenti aziendali pdf; overbooking canali prenotazione |
| 2026-08-21 | limiti no code azienda; costo non digitalizzare processi; lead che non vengono lavorati; software rinnovi scadenze clienti; abbandono prenotazione carrello; calendario professionale multi operatore |
| 2026-08-22 | frontend per software house; prima di sviluppare un app; cosa include software su misura; manutenzione software dopo go live; dal preventivo alla fattura software; piattaforma formazione interna |
| 2026-08-23 | white label software agenzia; rfi software come rispondere; passare da consulenza a prodotto; feature promessa non esiste; software studio professionale completo |

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

## Più articoli nello stesso giorno

Google **non** vieta 2–3 URL lo stesso giorno su un sito piccolo. Il rischio non è una penalità automatica: è **contenuto scalato** (stesso scheletro, stesso tono, keyword vicine) che non sale. 5–6 pezzi A nello stesso giorno è packing del calendario, non una regola SEO. Data ogni articolo il giorno in cui lo pubblichi davvero. Non scaricare B+C su questa settimana.

---

## File da non toccare a caso

- Permalink dei post (URL pubblici).
- `CNAME`, `robots.txt`, `url:` in `_config.yml`.

Nome file `_posts/YYYY-MM-DD-slug.md`: deve coincidere con `date:`. Non è l’URL.
