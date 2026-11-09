# Mappa SEO — blog.antoniotrento.net

Fonte di verità SEO. Produzione articoli (date + **Drip publish**): **`COME-SCRIVERE-I-POST.md`** in questa cartella. Claude e gli altri agenti partono da lì.

Stato SEO tecnico: 19 agosto 2026. **GSC blog nuovo, 12 ott 2026:** sitemap ok; 10 in index; 100+ rilevate; 19 esterni da antoniotrento.net. Probe chiuso. **Aspettare.** Niente altre richieste di indicizzazione, niente dump di link. Rilettura Pagine tra 2–4 settimane. Dettaglio sez. 1 / 1b / 1c.

---

## Azioni tue (non le fa il codice)

Farle in quest’ordine. Spuntale qui quando sono fatte. Copia anche in `README.md` (indice Claude).

### 1. Search Console — blog nuovo (subito, dopo il deploy Pages)

- [x] Aggiungi la proprietà **Prefisso URL** `https://blog.antoniotrento.net/`
- [x] Verifica (DNS o file HTML, come preferisci)
- [x] Invia la sitemap: `https://blog.antoniotrento.net/sitemap.xml` — **inviata correttamente** (Antonio, 12 ott 2026). Google ha rilevato **100 e passa** URL dalla sitemap.
- [x] Ispeziona **solo 4 URL**, non 80: `https://blog.antoniotrento.net/it/` · `/it/guide/` · un pillar vivo (`/it/pillar/prodotti-dati/` o app-interne o portali-b2b) · un post (es. `/it/blog/dashboard-che-non-si-usano/`)
- [x] Se l’ispezione dice «trovato ma non indicizzato», «richiedi indicizzazione» su quelle 4. Stop.

**Esito 12 ott 2026 (GSC proprietà `https://blog.antoniotrento.net/`):**

| Cosa | Stato |
|---|---|
| Sitemap `sitemap.xml` | Inviata, ok |
| URL rilevate dalla sitemap | 100+ (ordine di grandezza atteso: home IT/EN, guide, pillar vive, post drip già usciti, twin) |
| Pagine **indicizzate** (snapshot 9 ott) | **10** — tabella sotto |
| Pagine **rilevate ma non indicizzate** | **100+** — Google le conosce, non le ha ancora messe in index. Normale su proprietà nuova. **Non** è un errore di sitemap. |
| Probe 4 URL | **4/4 in index.** Altre 6 scoperte da Google senza richiesta. |

Le 4 del test ci sono tutte. **Non** chiedere indicizzazione di massa sulle 100+. Quota GSC + dominio nuovo: sembra spam di crawl, non SEO.

| URL | Ultima scansione | Note |
|---|---|---|
| `/it/` | 28 set 2026 | seed del test |
| `/it/guide/` | 19 ago 2026 | seed del test |
| `/it/pillar/prodotti-dati/` | 19 ago 2026 | seed del test; unica pillar in index |
| `/it/blog/dashboard-che-non-si-usano/` | 15 set 2026 | seed del test |
| `/en/guides/` | 23 ago 2026 | twin del seed, non richiesto |
| `/en/blog/dashboards-nobody-uses/` | 15 set 2026 | twin del seed, non richiesto |
| `/it/blog/rag-pgvector-fattura-elettronica/` | 26 set 2026 | scoperta, non seed |
| `/it/blog/mcp-salesforce-agente-produzione/` | 26 set 2026 | scoperta, non seed |
| `/it/blog/agente-imap-pec-fatture/` | 26 set 2026 | scoperta, non seed |
| `/it/blog/langgraph-vs-n8n-vs-python/` | 26 set 2026 | scoperta, non seed |

Fuori da queste 10 (e quindi **non** da richiedere a raffica): home `/en/`, le altre pillar vive Sez. 1, quasi tutta la serie A gennaio–agosto, il resto del drip.

#### 1b. Next step GSC (blog nuovo) — da qui in poi

Ordine. Niente altro «Richiedi indicizzazione» a raffica.

1. **Pagine → Perché le pagine non sono indicizzate.** Apri i bucket, non le 100 URL una a una.
   - **Rilevata / scoperta, attualmente non indicizzata** = atteso (le 100+). Google ha la sitemap, non ha dato crawl. Aspettare.
   - **Scansionata, attualmente non indicizzata** = ha visto la pagina e l’ha scartata. Annota quanti e 2–3 esempi. Se esplode, allora si guarda qualità/duplicati, non si richiede di nuovo.
   - **Esclusa dal tag noindex** = ok per stub pillar, root `/`, post con `date` futura (non devono stare in sitemap). Se un post **già uscito** è qui, è un bug in `seo.html`.
   - **Pagina duplicata / canonica scelta da Google**, **soft 404**, **errore 404**, **reindirizzamento**: se compaiono, 2–3 URL di esempio e si sistema nel codice. Non si richiede index.
2. **Performance** — prossimo giro GSC (ultime 3 mesi). Impressioni/click/query sulle 10 già in index. Zero o quasi, all’inizio, è normale. Serve come baseline.
3. **Link** → [x] fatto 12 ott 2026. Snapshot sez. **1c**. `antoniotrento.net` è agganciato. Non aggiungere 100 link dal sito principale.
4. **Facoltativo, massimo 1–2 URL, non questa settimana e non 100.** Solo se un hub vivo resta «rilevata» per **molte settimane** dopo i seed: es. `/en/` o un’altra pillar Sez. 1 già in index (`app-interne`, `portali-b2b`). Una ispezione; richiedi **solo** se dice «trovata ma non indicizzata». Poi stop di nuovo.
5. **Rilettura GSC ogni 2–4 settimane**, stesso report Pagine. Segno buono: le 10 salgono piano (20, 30…) senza richieste. Segno cattivo: le 10 ferme **e** cresce «scansionata non indicizzata». Allora se ne riparla. Non a ogni articolo.
6. **Non fare in GSC:** richiedere le 100+; ispezionare il piano intero; chiedere URL con data futura (non sono live); Removals sul blog nuovo; dump di link dal sito principale verso ogni post.

Cosa fa salire «rilevata» → «indicizzata» **fuori** da GSC: drip; link interni dalle 10 già in index; i 19 link da antoniotrento.net (già visti); pillar stub **non** in sitemap. Il tasto «Richiedi» non scala un dominio nuovo.

#### 1c. Link GSC (12 ott 2026)

**Esterni — totale 19, tutti da `antoniotrento.net`.** Google ha agganciato il sito principale al blog. Ok.

| Destinazione | Link | Cosa è nel codice |
|---|---|---|
| `/it/` | 18 | nav «Blog», footer, CTA «Vedi tutti gli articoli», banner sui post vecchi («Gli articoli nuovi sono sul blog») |
| `/it/blog/dashboard-che-non-si-usano/` | 1 | card homepage sito principale |

Anchor più frequenti: «gli articoli nuovi sono sul blog» · «blog» · il teaser dashboard («hai i dati…»).

Le altre due card in home (`gestione-soci-associazione-software`, `software-locale-ristorazione-magazzino`) **ci sono nel HTML** ma GSC non le ha ancora contate come destinazione. È il recrawl della home del principale, non un buco da tappettare con «Richiedi». **Non** spargere link dal principale verso le 100+ URL (sembra doorway, e l’archivio vecchio è noindex).

**Interni — totale 13** (sottografo che Google ha già visto, non il grafo vero del sito):

| Destinazione | Link interni visti da Google |
|---|---|
| `/it/` | 8 |
| `/it/blog/dashboard-che-non-si-usano/` | 2 |
| `/it/blog/mcp-salesforce-agente-produzione/` | 2 |
| `/it/blog/rag-pgvector-fattura-elettronica/` | 1 |

Nav, related, back-to-pillar esistono già. GSC ne vede 13 perché conta i link **tra pagine che ha già scansionato**. Quando le 10 salgono, questo numero sale da solo. Non è un «mancano i link interni».

Lettura: i 19 esterni spiegano perché `/it/` e il post dashboard sono in index. Le 100+ restano «rilevate» perché la sitemap le ha dette e i link (per ora) no. Aspettare. Prossimo dato utile in GSC: **Performance**, non altri link.

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

I **tre** CSV stanno in **`_piano_editoriale/` di questo repo** (blog), non nel sito principale. Calendario id/date: `_data/editorial_plan.yml`.

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
| A | GSC blog: proprietà, verifica, sitemap | Fatto 12 ott 2026. Sitemap ok. 100+ rilevate, 10 in index |
| B | Probe 4 URL + Link GSC | Fatto 4/4. 19 esterni da antoniotrento.net (sez. **1c**). Next: **Performance**; rilettura Pagine 2–4 sett. |
| D | FAQPage JSON-LD | Serve `faq:` in front matter, non si estrae dal markdown in modo sicuro |
| E | Rebuild goccia-a-goccia | Fatto: Action `drip-publish.yml`. Lanciala a mano una volta. |
| F | Copertina + corpo su uno stub → togliere `sitemap: false` e l’assenza di `image:` lo fa indicizzare | Checklist sotto |

---

## Quando una guida stub diventa indicizzabile

**Non aspettare che te lo chiedano.** Drip non accende le pillar. Dopo ogni lotto di post (e a fine cluster) apri `it/pillar/{chiave}` e il twin EN: ha `image:`? ha ancora `sitemap: false`? Il corpo è una guida o un paragrafo? Procedura, “quando sì / quando no” e **coda date Sezione 1**: playbook **sezione 9**.

1. Scrivi il corpo (non un paragrafo).
2. Metti `image: /assets/images/pillars/<slug>.jpg`.
3. **Togli** `sitemap: false` dal front matter **solo quando il cluster è tutto live** (altrimenti l’hub in index punta a 404). Finché c’è `sitemap: false`, `seo.html` tiene `noindex, follow` anche con copertina.
4. Push.

Coda già scritta, da accendere alle date del playbook sez. 9: documenti-flussi 12 set 2026, web-prodotto 13 set, comprare-software 16 set, prenotazioni-agenda 17 set.

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
