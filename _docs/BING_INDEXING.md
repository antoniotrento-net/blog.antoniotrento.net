# Bing / IndexNow — piano di indicizzazione per blog Jekyll su GitHub Pages

Sito target: `https://blog.antoniotrento.net`

## Obiettivo

Fare in modo che il blog:

1. sia correttamente registrato in Bing Webmaster Tools;
2. esponga una sitemap XML completa;
3. notifichi automaticamente a Bing i nuovi/aggiornati URL tramite **IndexNow**;
4. possa fare un **bootstrap iniziale** di tutti gli URL già pubblicati;
5. permetta di verificare in Bing Webmaster Tools cosa è stato ricevuto, scansionato e indicizzato.

> **Importante:** IndexNow notifica a Bing che una pagina è nuova, modificata o rimossa. Non garantisce l'indicizzazione, ma evita di dipendere soltanto dalla scoperta tramite crawler.

---

# 1. Setup una tantum in Bing Webmaster Tools

Aprire Bing Webmaster Tools:

https://www.bing.com/webmasters/

Aggiungere/importare:

`https://blog.antoniotrento.net`

Se possibile, importare la proprietà da Google Search Console.

Poi verificare che in **Sitemaps** sia presente:

`https://blog.antoniotrento.net/sitemap.xml`

Bing raccomanda oggi di usare insieme:

- **Sitemap** per la copertura completa del sito;
- **IndexNow** per notificare rapidamente URL nuovi, aggiornati o rimossi.

---

# 2. Sitemap Jekyll

Se il sito espone già:

`https://blog.antoniotrento.net/sitemap.xml`

non modificare nulla.

Altrimenti, con Jekyll si può usare `jekyll-sitemap`.

In `_config.yml`:

```yaml
plugins:
  - jekyll-sitemap
```

Se il progetto gestisce le gem direttamente, nel `Gemfile`:

```ruby
gem "jekyll-sitemap"
```

Dopo il deploy verificare:

```bash
curl -I https://blog.antoniotrento.net/sitemap.xml
```

Atteso:

```text
HTTP/2 200
```

La sitemap deve contenere solo URL pubblici/canonici che si vuole rendere indicizzabili.

---

# 3. robots.txt

Nel repository deve esserci un `robots.txt` raggiungibile come:

`https://blog.antoniotrento.net/robots.txt`

Configurazione minima:

```text
User-agent: *
Allow: /

Sitemap: https://blog.antoniotrento.net/sitemap.xml
```

Non aggiungere regole Bing-specifiche se non servono.

---

# 4. IndexNow: generare e pubblicare la chiave

Generare una chiave dal setup ufficiale IndexNow:

https://www.bing.com/indexnow/getstarted

Nel repository creare:

```text
indexnow-key.txt
```

contenente **solo** la chiave:

```text
LA_TUA_CHIAVE_INDEXNOW
```

Con GitHub Pages il file statico deve poi risultare raggiungibile qui:

`https://blog.antoniotrento.net/indexnow-key.txt`

Verifica:

```bash
curl https://blog.antoniotrento.net/indexnow-key.txt
```

La risposta deve essere esattamente la chiave.

> La chiave IndexNow non va trattata come una password: per protocollo deve essere verificabile pubblicamente sul sito.

---

# 5. Script automatico

Nel progetto aggiungere:

`scripts/indexnow_submit.py`

Lo script incluso in questo kit:

- scarica la sitemap live;
- estrae tutti gli URL;
- accetta anche sitemap index;
- filtra gli URL mantenendo solo `blog.antoniotrento.net`;
- elimina duplicati;
- invia gli URL a `https://api.indexnow.org/IndexNow`;
- usa come verifica `https://blog.antoniotrento.net/indexnow-key.txt`;
- divide automaticamente richieste molto grandi in batch.

## Variabili

Lo script usa:

```text
INDEXNOW_HOST=blog.antoniotrento.net
INDEXNOW_KEY_FILE=indexnow-key.txt
INDEXNOW_SITEMAP=https://blog.antoniotrento.net/sitemap.xml
INDEXNOW_KEY_LOCATION=https://blog.antoniotrento.net/indexnow-key.txt
```

In condizioni normali non serve cambiare nulla.

---

# 6. Primo bootstrap: notificare tutti gli URL esistenti

Dopo avere pubblicato la chiave e verificato che sitemap e key file rispondano `200`:

```bash
python scripts/indexnow_submit.py --all
```

Questo invia a IndexNow tutti gli URL presenti nella sitemap.

Per un blog di circa un centinaio di URL va benissimo come **bootstrap iniziale**.

Non è necessario ripetere continuamente il bootstrap completo.

---

# 7. Automazione GitHub Actions

File:

`.github/workflows/indexnow.yml`

La versione inclusa nel kit può essere avviata:

- manualmente da GitHub Actions;
- automaticamente quando vengono modificati contenuti del blog.

Per evitare notifiche inutili, il workflow viene attivato solo da modifiche tipicamente editoriali:

```yaml
paths:
  - "_posts/**"
  - "_pages/**"
  - "it/**"
  - "en/**"
  - "*.md"
  - "*.html"
  - "_data/**"
  - "_includes/**"
  - "_layouts/**"
  - "_config.yml"
```

### Strategia

Per questo blog la strategia iniziale è volutamente semplice:

```text
nuovo commit editoriale
        ↓
GitHub Pages pubblica
        ↓
workflow IndexNow
        ↓
scarica sitemap live
        ↓
invia URL a IndexNow
        ↓
Bing riceve la notifica
```

Il workflow attende prima che il sito live sia raggiungibile.

### Perché inizialmente si invia l'intera sitemap

Il blog è piccolo (~100 URL).

Questo rende il sistema:

- semplice;
- deterministico;
- indipendente dal formato dei permalink Jekyll;
- indipendente dal fatto che un articolo sia IT/EN;
- robusto rispetto a front matter e categorie.

Quando il blog crescerà molto, conviene passare alla modalità incrementale descritta più avanti.

---

# 8. Workflow consigliato

Il file incluso è:

```text
.github/workflows/indexnow.yml
```

Per testarlo:

1. fare commit dei file;
2. attendere il deploy GitHub Pages;
3. aprire **Actions → IndexNow → Run workflow**;
4. controllare il log;
5. verificare Bing Webmaster Tools → **IndexNow**.

Risultato atteso nel log:

```text
IndexNow: 200
Submitted: 111 URLs
```

`200` significa che la richiesta è stata accettata.

---

# 9. Verifica in Bing Webmaster Tools

Dopo la prima submission:

**Bing Webmaster Tools → IndexNow**

Controllare:

- URLs Submitted;
- Submission Time;
- Submission Source;
- Crawl Status;
- Index Status;
- First Indexed Time.

Per una singola pagina usare **URL Inspection**.

Il punto importante è distinguere:

```text
submitted
↓
crawled
↓
indexed
```

Sono tre stati diversi.

---

# 10. Modalità operativa consigliata per questo blog

## Una tantum

- [ ] aggiungere `blog.antoniotrento.net` a Bing Webmaster Tools;
- [ ] registrare la sitemap;
- [ ] generare chiave IndexNow;
- [ ] pubblicare `indexnow-key.txt`;
- [ ] verificare key file;
- [ ] eseguire `python scripts/indexnow_submit.py --all`;
- [ ] verificare IndexNow dashboard.

## A ogni nuova pubblicazione

L'automazione GitHub Action notifica IndexNow.

Non è necessario entrare manualmente in Bing.

## Ogni tanto

Controllare Bing Webmaster Tools:

- Site Explorer;
- IndexNow;
- URL Inspection;
- Sitemaps;
- Search Performance;
- Site Scan.

---

# 11. Modalità incrementale futura

Quando il blog diventerà molto più grande, non conviene inviare tutta la sitemap a ogni deploy.

L'evoluzione consigliata è:

```text
git diff
   ↓
identifica _posts / pagine modificate
   ↓
risolvi permalink Jekyll
   ↓
invia soltanto URL:
  - nuovi
  - aggiornati
  - rimossi
```

Per ora non è necessario: con ~100 URL la soluzione basata sulla sitemap è molto più semplice da mantenere.

---

# 12. Cosa NON fare

Non usare vecchi endpoint anonimi tipo:

```text
bing.com/ping?sitemap=...
```

Bing li ha dismessi.

Non usare come metodo principale la vecchia Bing URL Submission API: Microsoft continua a supportarla, ma oggi raccomanda **IndexNow** come meccanismo principale.

Non notificare URL:

- `noindex`;
- redirect;
- pagine private;
- URL duplicati;
- URL con canonical verso un'altra pagina;
- pagine di test/staging.

---

# 13. Controllo rapido da terminale

```bash
curl -I https://blog.antoniotrento.net/
curl -I https://blog.antoniotrento.net/sitemap.xml
curl -I https://blog.antoniotrento.net/robots.txt
curl https://blog.antoniotrento.net/indexnow-key.txt
```

Devono risultare raggiungibili pubblicamente.

Poi:

```bash
python scripts/indexnow_submit.py --all
```

---

# 14. Nota su Google

IndexNow **non sostituisce Google Search Console**.

Questa automazione è pensata per Bing e gli altri motori partecipanti a IndexNow.

Per Google continuano a essere importanti:

- sitemap;
- crawlability;
- canonical;
- internal linking;
- Search Console;
- richiesta manuale di indicizzazione quando serve.

---

# 15. Riferimenti ufficiali

IndexNow / Bing:

https://www.bing.com/indexnow/getstarted

Bing Webmaster Tools — URL Submission:

https://www.bing.com/webmasters/help/url-submission-62f2860b

Bing Webmaster Tools — Sitemaps:

https://www.bing.com/webmasters/help/sitemaps-3b5cf6ed

Bing Webmaster Tools — IndexNow:

https://www.bing.com/webmasters/help/indexnow-0z209wby
