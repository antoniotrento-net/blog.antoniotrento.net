---
lang: en
permalink: /en/blog/public-api-rate-limit-cache/
alt_url: /it/blog/rate-limit-api-pubbliche-cache/
title: "Public API rate limits (FRED, SEC, RSS): jitter, 24h caching and why --force in a loop from your home PC burns your IP"
date: 2026-11-11 07:30:00 +0200
author: "Antonio Trento"
description: "Data-pipeline etiquette for anyone consuming public APIs: FRED and SEC EDGAR limits, an honest user-agent, caching with ETag and TTL, backoff with jitter that respects Retry-After, spread-out cron jobs, the --force-from-a-laptop problem, when to stop scraping, seed vs live in the UI and a 429 runbook."
keywords: ["public api rate limit cache", "fred api rate limit", "polite sec edgar access", "cron jitter", "24h cache", "exponential backoff 429"]
image: /assets/images/posts/rate-limit-api-pubbliche-cache.jpg
pillar: stack-sovrano
related: [/en/blog/docker-sme-sovereign-stack/, /en/blog/self-hosted-n8n-openai-privacy/]
---

## The Monday the home router ended up on a blacklist

The script is always the same. Someone builds a small dashboard: rates, inflation, a few macro series from FRED, recent filings of some companies from SEC EDGAR, a couple of news RSS feeds. They build it on their own PC, because it is a personal project or because "it's a prototype for now". The script has a `--force` option that ignores the cache and re-downloads everything, handy during development. Then the prototype becomes useful, someone puts it in a cron every five minutes, and the `--force` stays there because "that way the data is always fresh".

One morning the dashboard is empty. The logs are full of `429 Too Many Requests` from one source and `403 Forbidden` from another. The problem is not just the script: it is the **IP address**. It is the home or office one, shared with everything else. For a few hours — sometimes a few days — that source no longer answers anyone on that network. If the IP belongs to a connection behind CGNAT, you may also have ruined the day of strangers who share your public address.

This piece is about **public API rate limits and caching**: how to consume public data in a civil way, without getting blocked and without treating a free service as if it were your own cluster. There is nothing exotic: an honest user-agent, caching with explicit rules, backoff with jitter that respects `Retry-After`, scheduled jobs that don't all start in the same second, and one rule that seems obvious until you break it: if a source answers 403 on HTML, stop and change source.

## Is this for you?

It is for you if:

- you have a pipeline (Python, n8n, cron, a job in Docker) that downloads data from public or semi-public APIs: statistics, prices, company filings, feeds, open data;
- you have seen it work for weeks and then break without the code changing;
- you are about to move a prototype from a laptop to a server and want to do it without bringing the bad habits along.

It is not for you if you consume a commercial API with a contract and an SLA: there the limits are written in the contract and etiquette is replaced by the invoice. It is also not for you if your problem is scraping sites that don't want to be read: here the answer is "don't", and this piece won't help you do it better.

## Public APIs are not your cluster

The first thing to drop is the idea that a public endpoint is an infinite resource. Behind FRED there is a team at the Federal Reserve Bank of St. Louis; behind EDGAR there are the SEC's servers; behind an RSS feed there is often a small publisher with ordinary hosting. They serve millions of users for free. They do it with access rules that are not whims: they are how they avoid having to shut the service for everyone because of a few.

Three principles govern everything else:

1. **You are a guest.** Declared limits are a ceiling, not a target. If FRED allows a certain number of requests per minute, your pipeline should sit comfortably below it, not dance around it.
2. **Public data changes slowly.** A monthly macro series updates once a month. An SEC filing, once published, does not change. A blog's RSS feed updates a few times a day. Re-downloading every five minutes data that changes once a month is not "freshness": it is noise you pay for (in blocks) and they pay for (in bandwidth).
3. **The caller's identity matters.** Serious sources want to know who you are, so they can contact you before blocking you. An anonymous or fake user-agent ("Mozilla/5.0…" from a Python script) is the fastest way to go from "user to warn" to "traffic to block".

The default I use for this kind of pipeline is simple: a **small collection service** in Docker on an EU VPS or an internal server, with a local cache (files or Postgres), which is the only process allowed to talk to external sources. Dashboards, notebooks, agents and n8n flows read from the cache, never directly from the source. This alone removes half the problems: there aren't ten clients downloading the same series, there is one that downloads it and ten that read it.

## FRED and the like: keys, limits, caching

FRED is a good example of a well-made public API: you register an account, get a free API key, every request carries the key, and the service applies per-key limits. The documentation declares a cap on requests per unit of time (in the order of a hundred or so per minute per key at the time of writing: always check the official page, because these numbers change). Above the cap you get a 429.

What this means in practice:

- **One key per application, not one per developer pasted everywhere.** The key identifies your application. If the same key is used by the production dashboard, a colleague's notebook and a CI test, the limit is shared and the first to overdo it blocks the others. The key lives in a secret, not in the repository.
- **Requests are batched.** Many statistical APIs let you request a whole series with a date range, instead of one observation at a time. One request per series per day is almost always enough.
- **Metadata tells you when it is worth re-downloading.** FRED exposes, for each series, its frequency and last update. If the series is monthly and the last update was ten days ago, there is no need to ask for it every hour. A light request for metadata, once a day, tells you whether the series has changed; only then do you download the observations.
- **Vintages and revisions.** Macro series get revised. If your use requires knowing *which version* of the data you had on a given day (backtests, historical reports), you must store versions, not overwrite. The reference date of the data and the date you downloaded it are two different columns.

### Caching policy

A cache is not "I save the response and reuse it until I remember to delete it". It is a written policy, per source and per data type, with a TTL, an invalidation criterion and a rule for when the source does not answer.

| Source / data type | Base TTL | Invalidation | If the source does not answer |
|---|---|---|---|
| FRED, daily series | 24 h | `last_updated` metadata changed | serve cache, mark "stale" after 48 h |
| FRED, monthly / quarterly series | 24 h on metadata, observations only if changed | `last_updated` changed | serve cache, no alert before 7 days |
| SEC EDGAR, filing index per company | 6–24 h | new filing in the index | serve cache, alert after 48 h |
| SEC EDGAR, a filing's document | forever (immutable) | never | serve cache |
| Publishers' RSS feeds | 1–6 h, with conditional request | `ETag` / `Last-Modified` | serve cache, no aggressive retry |
| Public-sector open data (published CSV/JSON) | 24 h – 7 days | `ETag` / publication date | serve cache |
| "Near-live" rates and quotes | minutes, only if truly needed | — | clearly show the data's age |

Two notes. First: a 24-hour TTL is a good default for almost anything statistical, and almost nobody really needs less. Second: the most important column is the last one. When the source is down, the pipeline must **serve the last good data with its age**, not empty the dashboard and not hammer the source trying to "catch up".

## SEC/RSS: respect and robust parsing

The SEC is the textbook case of a source that tells you the rules. EDGAR's fair access policy asks for two explicit things: a cap on requests per second (10 at the time of writing) and a **user-agent that declares who you are**, with a name and a contact email. Those who exceed the cap get throttled for a period; those who don't identify themselves risk being treated as anonymous automated traffic. The SEC also offers bulk archives and daily indexes designed precisely so that not everyone downloads everything one document at a time.

### An honest user-agent

The user-agent is one line, and it says a lot about you. The right one contains the application name, a version and a real contact:

```python
import httpx

USER_AGENT = "Macro-Dashboard/1.4 (contact: data@example-company.com)"

client = httpx.Client(
    headers={
        "User-Agent": USER_AGENT,
        "Accept-Encoding": "gzip, deflate",
    },
    timeout=httpx.Timeout(20.0, connect=5.0),
    follow_redirects=True,
)
```

What not to do: copy Chrome's user-agent to "look like a browser". You are not a browser, and whoever runs the source can tell in three seconds from how you request resources. Pretending to be one is the step that turns a quota problem into a trust problem. And the contact must be a mailbox someone reads: if the SEC or a publisher writes "you're overdoing it", you want to know before the block.

### RSS and conditional requests

For RSS and Atom feeds, etiquette has a precise technical name: **conditional requests**. The first time you download a feed, the server returns (if configured well) an `ETag` and/or `Last-Modified` header. Subsequent times you send them back with `If-None-Match` and `If-Modified-Since`. If the feed hasn't changed, the server answers `304 Not Modified` with an empty body: zero bandwidth, zero parsing, zero risk of looking like a crawler.

```python
def fetch_conditional(client, url, cache):
    entry = cache.get(url)  # dict with body, etag, last_modified, fetched_at
    headers = {}
    if entry:
        if entry.get("etag"):
            headers["If-None-Match"] = entry["etag"]
        if entry.get("last_modified"):
            headers["If-Modified-Since"] = entry["last_modified"]
    r = client.get(url, headers=headers)
    if r.status_code == 304 and entry:
        cache.touch(url)  # only updates fetched_at
        return entry["body"], "not_modified"
    r.raise_for_status()
    cache.put(url, body=r.text,
              etag=r.headers.get("ETag"),
              last_modified=r.headers.get("Last-Modified"))
    return r.text, "updated"
```

### Robust parsing

Respect is not only how much you ask: it is also what you do when the response is strange. RSS feeds are the realm of malformed XML, wrongly declared encodings, dates in creative formats. EDGAR has documents with different structures depending on era and filing type. Two rules:

- **A parsing error is not a reason to re-download.** If the document is malformed, downloading it ten times gives you ten times the same malformed document. Save the raw response, log the error, move on. Many "mysterious" retry loops are actually parsers failing and an `except` that retries the download.
- **Validate the minimum schema, not perfection.** For a feed, title, link and date are enough; for a filings index, identifier, type and date. The rest is optional and must not fail the whole batch.

## Jitter: not 50 jobs at 00:00:00

The second most common way to get noticed by a public source is punctual like a clock: literally. You write a `0 * * * *` cron for each series, you have fifty, and on the hour your machine fires fifty requests in the same second. Multiply by everyone who had the same idea, and you understand why many sources see traffic spikes at minute zero of every hour, and why they apply stricter limits exactly there.

The remedy is called **jitter**: a random delay that spreads executions.

- **Jitter on job start.** The job starts "around" the time, not exactly at it. With systemd it is a timer option; with cron you do it with a random `sleep`.
- **Jitter between requests inside the job.** The fifty series don't start in parallel: they run in sequence, with a base pause and some randomness.
- **Non-round times.** If the data updates in the morning, download at 06:47, not at 06:00.

With systemd:

```ini
# /etc/systemd/system/macro-collection.timer
[Unit]
Description=Macro series collection (once a day, spread out)

[Timer]
OnCalendar=*-*-* 06:40:00
RandomizedDelaySec=20min
Persistent=true

[Install]
WantedBy=timers.target
```

With cron, if you have no alternative:

```bash
# m h dom mon dow  command
47 6 * * * sleep $((RANDOM % 900)); /opt/collector/bin/collect --source fred >> /var/log/collector/fred.log 2>&1
```

And inside the job, between one request and the next, a pause that respects the limit with a margin:

```python
import random, time

def pause_between_requests(limit_per_second: float, margin: float = 0.5):
    """Stays below the declared limit with a margin, and adds randomness."""
    base = 1.0 / (limit_per_second * margin)   # e.g. 10 req/s, margin 0.5 → 0.2 s
    time.sleep(base + random.uniform(0, base))
```

If the pipeline runs in n8n, the same rules apply: no "Every hour" trigger on fifty separate workflows; rather one workflow that iterates with a wait node and a non-round time. If you run n8n in queue mode, remember that more workers mean more parallelism towards the outside: the limit must be applied per source, not per worker.

## --force and laptop loops

Back to `--force`. It is a legitimate option in development: you want to see what the source returns right now, without cache. It becomes a problem for three reasons that add up.

**1. A laptop is not a server.** It sleeps, wakes up, and cron catches up on all missed runs at once. It changes network (home, office, phone hotspot), and at every change the cache may look "old". If the script has logic like "if more than N hours have passed, re-download everything", on waking after a weekend it goes all in.

**2. A residential IP is shared and fragile.** Your home IP is shared with family, smart devices, maybe other customers of the provider (CGNAT). When a source blocks that IP, it blocks everyone. Conversely, many sources look with suspicion at automated traffic from residential IPs, because it is also the typical profile of botnets. A VPS with a fixed IP, a clear user-agent and low volumes is, paradoxically, a more respectable citizen than your PC.

**3. `--force` in a loop is an involuntary attack.** A debug script that retries "until it works", with `--force`, without a pause: in a minute you've made hundreds of requests. If the source answers 429, the loop retries immediately, and things get worse.

Rules I always apply:

- `--force` acts on **one** resource at a time (`--force --series DGS10`), never on everything.
- `--force` still respects the rate limiter. The cache is skipped; the limit is not.
- In production `--force` does not exist: the production job reads configuration, not command-line arguments.
- On the laptop, the pipeline reads from the **server's cache** (via an internal endpoint or a copy of the database), not from the source.

Moving collection to a small server is not a luxury: it is the step that makes the pipeline predictable. A container on the internal server or on a European VPS, like those described in the [Docker stack for SMEs]({{ '/en/blog/docker-sme-sovereign-stack/' | relative_url }}), costs a few euros a month and gets you out of the home-IP problem.

## Backoff: what to do when the source says "enough"

A 429 is a clear message: you asked too much, slow down. It often comes with a `Retry-After` header saying how many seconds to wait (or until when). A 503 during maintenance may carry the same header. The correct response has four elements:

1. **Respect `Retry-After`** if present. The source is telling you how long to wait: use it, even if it is longer than you'd like.
2. **Exponential backoff with jitter** if absent: wait 2, 4, 8, 16 seconds, but with a random component, so that a hundred clients blocked at the same moment don't all come back at the same moment.
3. **A maximum number of attempts**, after which you stop and serve the cache.
4. **A circuit breaker per source**: if a source has given repeated errors, the pipeline stops querying it for a period, instead of starting again at every job.

### Backoff example

```python
import random, time
from email.utils import parsedate_to_datetime
from datetime import datetime, timezone

RETRYABLE = {429, 500, 502, 503, 504}

def wait_from_retry_after(value: str | None) -> float | None:
    if not value:
        return None
    if value.isdigit():
        return float(value)
    try:
        when = parsedate_to_datetime(value)
        return max(0.0, (when - datetime.now(timezone.utc)).total_seconds())
    except (TypeError, ValueError):
        return None

def get_with_backoff(client, url, max_attempts=5, base=2.0, cap=300.0, **kw):
    for attempt in range(1, max_attempts + 1):
        r = client.get(url, **kw)
        if r.status_code not in RETRYABLE:
            return r
        wait = wait_from_retry_after(r.headers.get("Retry-After"))
        if wait is None:
            # "full jitter": random wait between 0 and the exponential cap
            wait = random.uniform(0, min(cap, base ** attempt))
        log.warning("source_throttled", extra={
            "url": url, "status": r.status_code,
            "attempt": attempt, "wait_s": round(wait, 1)})
        if attempt == max_attempts:
            break
        time.sleep(wait)
    raise SourceUnavailable(url)
```

The circuit breaker can be trivial: a row in a table with source, number of consecutive errors and "don't query until". The job checks that row before starting. If the source is paused, it skips and leaves the cache where it is.

### A mistake not to make: retrying 4xx

`400`, `401`, `403`, `404` are **not retried** automatically. A malformed request stays malformed, an expired key stays expired, a 404 stays a 404. Retrying them is the equivalent of knocking harder on a door you've been told is closed. The only exception is 429, which literally means "try again later".

## 403 on HTML: stop, change source

There is a recurring scene: a source has no API (or has a paid one), so someone downloads the HTML page and "parses" it. It works for a while. Then comes a 403, or an anti-bot check page, or a captcha. The instinctive reaction is to change user-agent, add browser headers, rotate IPs, use a headless browser.

Stop there. A 403 on an HTML page after a period in which it worked almost always means one thing: **the site owner has decided they don't want that kind of access**. Getting around it means:

- probably breaching the site's terms of use;
- entering an arms race you will lose (and that will cost you maintenance every week);
- exposing your organisation to complaints, because your IP or your honest user-agent identifies you;
- building a product on a source that may disappear tomorrow.

What to do instead:

1. **Look for the official API** or bulk datasets. Many sources that seem "HTML only" have a data endpoint, a downloadable CSV, a feed.
2. **Look for the primary source.** Often the page you are reading republishes data from another institution that distributes it openly.
3. **Consider a licence.** If the data has commercial value for you, paying a provider with a clear licence costs less than maintaining a scraper that breaks.
4. **Accept not having that data**, or having it less often, entered by hand by a person.

It is the boring choice, and it is the right one.

## Seed vs live: declare it in the UI

A civil pipeline accepts that sometimes it will not have fresh data. At that point the question becomes: what does the dashboard show? The wrong answer is "the last value, as if nothing happened". The right answer is to show **the origin and age of every number**.

I distinguish three states:

- **Live**: the data was downloaded from the source within the expected TTL.
- **Stale**: the data comes from the cache, older than expected because the source didn't answer or is paused. It is shown, with its age in plain sight.
- **Seed**: the data comes from a starting dataset (a manually loaded file, a historical export, sample data for development). It has never been verified against the live source.

The third state is the one that does most damage when not declared. It happens like this: a sample CSV is loaded to develop the dashboard; then the live pipeline never really starts because of a key problem; the dashboard keeps showing sample data for weeks, and nobody notices because "the numbers are there".

In practice, every value shown carries three pieces of metadata: `source`, `as_of` (the date the data refers to) and `fetched_at` (when you got it). The UI uses them:

```json
{
  "series": "DGS10",
  "value": 4.21,
  "as_of": "2026-11-06",
  "fetched_at": "2026-11-09T06:52:11+01:00",
  "source": "FRED",
  "state": "live",
  "note": null
}
```

Next to the number, in small type: "FRED, data as of 6 Nov, updated this morning". If the state is `stale`: "last successful update 3 days ago". If it is `seed`: a label that leaves no doubt, like "sample data, not live". It is the same discipline needed for any [owner dashboard that actually gets opened]({{ '/en/blog/owner-dashboard/' | relative_url }}): a number without a date is an opinion.

## Reference architecture

Let's put the picture together.

**Components:**

- **Collector** (Python container or dedicated n8n workflow) on an internal server or EU VPS: the only component that talks to external sources. It has a per-source rate limiter, backoff, circuit breaker, honest user-agent.
- **Source configuration** in a versioned file: for each source the base URL, the declared limit, the margin, the TTL, the invalidation policy, the contact.
- **Cache / store** in Postgres (or SQLite for small volumes): raw responses, normalised data, metadata (`etag`, `last_modified`, `as_of`, `fetched_at`, `state`), versions for data that gets revised.
- **Source status**: consecutive errors, circuit-breaker pause, last success.
- **Consumers** (dashboards, notebooks, agents, reports): read only from the store, never from the source.
- **Logs and metrics**: requests per source, responses per code, 304 vs 200, backoff waits, data age.

**What does not touch the external source:**

- developers' laptops (they work on a copy of the store);
- LLM agents (if an agent needs data, it asks the store through a tool; it does not have a "download URL" tool towards external sources);
- CI (tests use recorded fixtures, not live calls).

That last point deserves an extra line: a test suite that calls FRED on every push consumes the production key's quota and fails randomly when the source is slow. Responses are recorded once and reused.

```yaml
# sources.yaml — versioned, read by the collector
sources:
  fred:
    base_url: https://api.stlouisfed.org/fred
    requests_per_minute_limit: 100     # check on the official site
    margin: 0.4                        # we use 40% of the limit
    ttl_hours: 24
    invalidation: metadata_last_updated
    key_from_secret: fred_api_key
  sec_edgar:
    base_url: https://data.sec.gov
    requests_per_second_limit: 10      # fair access policy, check on the official site
    margin: 0.3
    ttl_hours: 12
    user_agent_required: true
  publisher_rss:
    ttl_hours: 3
    conditional_requests: true
    max_feeds_per_run: 40
user_agent_contact: "data@example-company.com"
circuit_breaker:
  consecutive_errors_to_pause: 5
  pause_minutes: 60
```

## Implementation path, step by step

1. **Inventory the sources.** For each: URL, terms of use, declared limits, real update frequency of the data, who uses it in the company.
2. **Read the terms of use.** Sounds obvious. Almost nobody does it. Many sources say explicitly what you can do, how often and with what identification.
3. **Choose where the collector runs.** Internal server or EU VPS with a fixed IP. Not the laptop, not the office PC that gets switched off in the evening.
4. **Write `sources.yaml`** with limits, margins, TTLs, invalidation.
5. **Implement the common client**: user-agent, timeouts, per-source rate limiter, conditional requests, backoff with `Retry-After`, circuit breaker. A single module, used by all collections.
6. **Implement the store** with state metadata (`live`, `stale`, `seed`) and versions where needed.
7. **Schedule with jitter**: one timer per source, non-round times, random delay.
8. **Move consumers to the store.** Dashboards, notebooks, agents: nobody calls the source directly any more.
9. **Show age and state** of every value in the UI.
10. **Add metrics and alerts**: 429 rate, paused sources, data stale beyond threshold.
11. **Record fixtures** for tests and remove live calls from CI.
12. **Write the 429 runbook** (below) and put it where whoever is on call can find it.

## 429 runbook

When a source starts answering 429 (or 403 after a period of 429s), the runbook is short and must be followed in order.

1. **Stop the jobs towards that source.** Put the circuit breaker in manual pause. Not "let's try once more".
2. **Check that consumers serve the cache** and that the UI shows the `stale` state. No empty dashboards.
3. **Look at the last 24 hours of logs**: how many requests towards that source, from which jobs, with what distribution over time. Look for minute-zero spikes, retry loops, duplicate jobs.
4. **Check where requests come from.** A single IP (the collector) or others too (laptops, CI, a forgotten old cron)? If the API key was used by others, rotate it.
5. **Read the source's response.** A `Retry-After`, a body with a message, an email to the contact in the user-agent. Sometimes the source tells you exactly what you did wrong.
6. **Fix the cause**, not the symptom: TTL too short, missing jitter, `--force` in production, duplicate jobs after a deploy.
7. **Restart slowly**: reactivate the source with a lower margin (e.g. from 40% to 20% of the limit) for a few days.
8. **If the block is on the IP and doesn't clear in 24–48 hours**, contact the source operator from the declared mailbox, explaining what happened and what you fixed. Don't change IP to get around the block.
9. **Log the incident**: cause, duration, fix. At the third incident on the same source, review the whole caching policy for that source.

## Typical failures and how to spot them in the logs

**Minute-zero spike.**

```text
2026-11-09T07:00:00.112 GET fred/series/observations?series_id=CPIAUCSL 200
2026-11-09T07:00:00.118 GET fred/series/observations?series_id=UNRATE 200
2026-11-09T07:00:00.121 GET fred/series/observations?series_id=DGS10 200
...
2026-11-09T07:00:01.004 GET fred/series/observations?series_id=M2SL 429
```

Dozens of requests in the same second: cron without jitter, parallel jobs. The 429 arrives at the end of the burst.

**Retry loop on the parser.**

```text
06:52:10 GET feed.example.it/rss 200 bytes=48211
06:52:10 parse_error feed.example.it/rss "not well-formed (invalid token): line 312"
06:52:11 GET feed.example.it/rss 200 bytes=48211
06:52:11 parse_error feed.example.it/rss "not well-formed (invalid token): line 312"
```

Same size, same error: the retry is on the download, but the problem is the content. Separate the two branches.

**No 304s.** If a feed is downloaded ten times a day and you never see a `304`, either you are not sending conditional headers or the server doesn't support them. In the second case, raise the TTL.

**Retrying 4xx.**

```text
GET data.sec.gov/... 403 attempt=1
GET data.sec.gov/... 403 attempt=2
GET data.sec.gov/... 403 attempt=3
```

A 403 retried three times is a 403 you've made worse. Often the cause is a missing or generic user-agent.

**Seed data in production.** No requests to the source in recent days, but the dashboard shows numbers. Look for `state=seed` in the store: if you find it on data that should be live, the pipeline never started.

**Runs caught up after wake-up.**

```text
2026-11-09T08:14:02 job=fred-collection start (caught up: 3 missed runs)
```

Classic on a laptop or with `Persistent=true` after a long shutdown. The job must notice and do **one** run, not three.

## Costs: orders of magnitude

Indicative estimates, to be checked against your case.

| Item | Order of magnitude (estimate) | Notes |
|---|---|---|
| EU VPS for the collector | €5–15/month | 2 vCPU, 4 GB RAM are enough for dozens of sources |
| Storage for cache and versions | negligible – a few €/month | Macro series and indexes take little; bulk EDGAR documents more |
| Common client + store + config | 4–8 person-days | Once, then reused for every source |
| Adding a new source | 0.5–2 person-days | If the common client exists |
| UI with data state and age | 1–3 person-days | Depends on the dashboard |
| Maintaining an HTML scraper | 0.5–2 days/month | The cost you avoid by changing source |
| Cost of a blocked IP | hours or days without data | Plus the time to understand what happened |

The most interesting comparison is the last one: a well-made client costs a week, once. A scraper fighting anti-bot defences costs days every month, forever, and always breaks at the worst moment.

## When NOT to do it

- **When you need truly real-time data with an SLA.** Real-time market prices, data for minute-by-minute operational decisions: there a free public source is the wrong choice regardless of etiquette. You need a provider with a contract.
- **When the data is little and static.** If you need five series updated once a month, a collector with a circuit breaker is oversized. A daily script with cache and user-agent is enough, or a manual download.
- **When the source forbids automated use.** If the terms of use exclude automated access, no architecture makes it acceptable.
- **When nobody will look at the alerts.** A pipeline with a circuit breaker and a `stale` state is useful only if someone notices that a source has been paused for two weeks. Otherwise you just have a more elegant way of showing old data.
- **When you are building a commercial product on data with an unclear licence.** Licence first, pipeline second.

## Operational checklist

- [ ] Every source has terms of use read, declared limits noted and a chosen margin.
- [ ] The collector runs on a server with a fixed IP, not on a laptop.
- [ ] The user-agent contains application name, version and a real, monitored contact.
- [ ] API keys are in a secret, one per application, never in the repository.
- [ ] There is a written caching policy per source, with TTL, invalidation and behaviour on error.
- [ ] Feeds use conditional requests and you see `304` in the logs.
- [ ] Jobs have jitter at start and pauses between requests; no round times.
- [ ] Backoff respects `Retry-After`, uses jitter and has a maximum number of attempts.
- [ ] 4xx (except 429) are not retried.
- [ ] There is a per-source circuit breaker, with queryable state.
- [ ] `--force` acts on one resource at a time and still respects the rate limiter; it doesn't exist in production.
- [ ] Consumers read only from the store; CI and laptops don't call the sources.
- [ ] The UI shows source, `as_of`, `fetched_at` and state (`live`, `stale`, `seed`).
- [ ] The 429 runbook is written and reachable.

## The verdict

Handling public API rate limits well with a serious cache is not a nicety for pedantic engineers: it is the difference between a pipeline that works for years and one that breaks every time the source gets tired of you. The rules are few and banal — ask yourself how often the data really changes, declare who you are, don't all start in the same second, listen to the 429, stop at the 403 — but they must be written in code and configuration, not left to the goodwill of whoever runs the script.

The reward is not just not being blocked. It is having a system in which every number has a provenance and an age, in which a source going down doesn't empty the dashboard, in which a developer's laptop can't burn the office IP. It is civil data engineering: respectful towards those who give you data for free, and honest towards those who read your numbers.

If you are taking data collection from prototype to stable service and want to set it up without depending on a laptop or a SaaS, you'll find my background in the [biography]({{ site.main_site }}/biografia/) and the rest of my work on [antoniotrento.net]({{ site.main_site }}/). The other pieces on self-hosted infrastructure are collected in the guide to the [sovereign stack]({{ '/en/pillar/sovereign-stack/' | relative_url }}).

## FAQ

### What is the FRED API rate limit?

FRED applies per-API-key limits, in the order of a hundred or so requests per minute at the time of writing, but the exact value must be checked in the official documentation because it can change. In practice, a well-built pipeline stays far below it: with a 24-hour cache and a check of update metadata, a few requests per series per day are enough.

### What does the SEC require for automated access to EDGAR?

The SEC's fair access policy asks you not to exceed a certain number of requests per second (10 at the time of writing) and to declare in the user-agent the name of the application or organisation and a contact email. Those who exceed the limits are temporarily throttled. For large volumes the SEC provides bulk archives and indexes.

### What is jitter and why does cron need it?

Jitter is a random delay added to the start of a job or between requests. It prevents many jobs from starting at the same instant, creating spikes that trigger the source's rate limits. With systemd you use `RandomizedDelaySec`, with cron a random `sleep` before the command.

### How long should the cache of public API data last?

It depends on how often the data changes. For daily or slower statistical series, 24 hours is a good default; for immutable documents, like an already published SEC filing, the cache can be permanent; for RSS feeds, a few hours with conditional requests. The rule is not to re-download more often than the data updates.

### How do you handle a 429 error?

You stop sending requests, respect the `Retry-After` header if present, otherwise apply exponential backoff with jitter and a maximum number of attempts. Meanwhile you serve the cache. If 429s repeat, you activate a circuit breaker for that source and look for the cause (spikes, retries, TTLs too short).

### Why shouldn't you retry a 403 error?

Because a 403 means access is denied, not that the server is momentarily overloaded. Retrying it doesn't change the outcome and can make things worse, making your traffic look hostile. On an HTML page, a 403 after a period in which it worked is often the sign that the operator doesn't want that kind of access: the right response is to look for an official API or another source.

### Is it a problem to run a data pipeline from a home PC?

Yes, for several reasons: the PC sleeps and catches up on missed runs all at once, the residential IP is shared with family or other customers of the provider, and many sources look with suspicion at automated traffic from home IPs. A small VPS in the EU or an internal server with a fixed IP makes the pipeline more predictable and your identity clearer.

### What are conditional requests with ETag?

They are requests in which the client sends the server back the identifiers of the version it already has (`If-None-Match` with the ETag, `If-Modified-Since` with the date). If the content hasn't changed, the server answers `304 Not Modified` with no body. For feeds and published files it is the most efficient and respectful way to check for updates.

### How do you show in a dashboard that data is out of date?

By attaching to every value the source, the date it refers to and the moment it was downloaded, and an explicit state: live, stale or seed. The UI shows this information next to the number, with different emphasis when the data is old or is sample data never verified against the source.

### What user-agent should a script that downloads data use?

One that tells the truth: application name, version and a real contact, for example `AppName/1.2 (contact: data@yourdomain.com)`. Don't use a browser's user-agent to blend in: sources notice, and a clear identity is what allows them to contact you before blocking you.
