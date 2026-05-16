---
name: crawler-reliability
description: Build reliable web crawlers for data gathering. Use when implementing scrapers for CafeF, NDH, VietnamBiz, YouTube (yt-dlp), Facebook fanpages, or any external data source. Covers Python/Playwright patterns, retry/backoff, selector robustness, rate limiting, monitoring.
---

# Skill: Crawler Reliability

## Purpose

Web scrapers have silent-break failure mode: selector looks right, passes tests, breaks in production when site updates. This skill minimizes that risk.

## Core Principles

1. **Verify selector against live DOM before committing** (VBW for scrapers)
2. **Retry with exponential backoff, but with budget cap**
3. **Monitor for silent break** (output shape changes session-over-session)
4. **Respect rate limits and robots.txt**
5. **Cache aggressively** — fetch once, parse many

## Stack

| Concern | Tool |
|---|---|
| Dynamic sites | Playwright (headless Chromium) |
| Static APIs | httpx / aiohttp |
| Retry logic | tenacity |
| Cache | Redis |
| YouTube transcript | yt-dlp |
| Raw content store | Cloudflare R2 |

## Selector Robustness

**Prefer (in order):** `data-testid` / `aria-label` / `itemprop` > nearby-text + relationship locator > class selector > nth-child positional. Positional selectors break on DOM reshuffle — never use them as primary.

**Fallback chain pattern**: try multiple strategies, return first non-empty result, log warning if all fail and return None. Don't raise — partial output beats whole-pipeline halt.

## VBW for Scrapers

Before writing any selector:

1. Fetch live HTML once: `curl URL > sample.html`
2. Open in browser, inspect actual DOM
3. Identify stable selectors (testid / aria / itemprop)
4. Write selector based on actual DOM, not assumed structure

This is VBW Protocol applied to scrapers. Critical — selectors written from memory are top failure mode.

## Retry & Backoff

Use `tenacity`: `stop_after_attempt(5)` + `wait_exponential(multiplier=1, min=1, max=30)` + `retry_if_exception_type((HTTPError, TimeoutException))`. Treat `429 Too Many Requests` as retryable; `4xx` other than 429 is NOT retryable (won't fix itself). Always cap total retry budget.

## Rate Limiting

Per-domain token bucket via `asyncio.Semaphore`. Default: 10 calls/min/domain. Adjust per site terms — CafeF is more lenient than VietnamBiz. Always sleep at least `60 / cpm` between calls. Wrap fetch in `polite_fetch(url)` that acquires semaphore first.

## Monitoring for Silent Break

Every crawler emits shape metrics per run:

- `article_count` (alert if 0 — likely DOM change)
- `with_title`, `with_url`, `with_published_at` (per-field success rate)
- Field success rate < 50% triggers warning log

Persist to `agent-workspace/calibration/crawler-shape/<source>.tsv` for session-over-session comparison.

## Caching Pattern

Key: `crawl:<sha256(url)>`. Use Redis `SETEX` with TTL:

| Content | TTL |
|---|---|
| News listings | 1-6 hours |
| Article detail | 24-72 hours |
| Static (about pages) | 7 days |
| Market data | 5-15 min OR don't cache |

## Storage

Raw HTML → Cloudflare R2 at `raw-crawl/<domain>/<date>/<sha256(url)>.html` with metadata: `url`, `fetched_at`, `status_code`. Parsed structure → Postgres. Raw preserved for reprocessing when extraction logic improves.

## Adapter Storage Discipline — discover-bypass-via-store_raw

**Promoted from L-S345-3 (n=3 instance threshold met: NDH retrofit S345 + Vietstock day-1 S354 + VietnamBiz day-1 S358).** This pattern is now MANDATORY for all CrawlerAdapter subclasses.

**Problem**: Listing-page HTML (e.g., `/chung-khoan`, `/thi-truong/`, hashtag/category pages) has different licensing surface than article-page HTML and is NOT the unit of reprocessing. Persisting listing pages to `data/raw/news/<source>/` pollutes the dataset and breaks downstream consumers that assume `data/raw/news/<source>/<date>/<hash>.html` = article HTML 1:1 with SQLite rows.

**Helper signature contract** (every CrawlerAdapter that wires RawHtmlSink MUST follow):

```python
def _fetch_with_optional_chain(
    self, url: str, *, store_raw: bool = True
) -> str:
    # ... rate-limit + robots-check ...
    html = self.fetcher(url)
    # ... report-response ...
    if store_raw:
        rhs = self.raw_html_sink
        if rhs is not None and hasattr(rhs, "write"):
            try:
                rhs.write(source_id=self.source_id, url=url, html=html, fetched_at=self.clock())
            except Exception as exc:
                _log.warning("...raw_html_sink.write failed for url=%r: %s", url, exc)
    return html
```

**Sextuple-guard checklist** (verify ALL 6 GREEN before merge for any new adapter):

1. **DC-IMPL-7 signature**: `_fetch_with_optional_chain(self, url: str, *, store_raw: bool = True)` — `store_raw` is keyword-only via `*`
2. **DC-IMPL-8 discover-call**: `discover()` body passes `store_raw=False` to `_fetch_with_optional_chain`
3. **DC-IMPL-9 sink-guard**: Sink-write inside `if store_raw:` block
4. **Test 7**: asserts `mock_sink.write.assert_not_called()` after `discover()` returns (proves listing-page bypass works)
5. **Test 19**: asserts `mock_sink.write.assert_called_once()` after `fetch_and_parse()` returns (proves article-page write works) with correct kwargs (source_id + url + html + fetched_at)
6. **DC-SMOKE-4 EMPIRICAL**: After CLI smoke run, `find data/raw/news/<source>/ -type f` returns ONLY article-hash files (count matches `articles_written` from CLI log); zero listing-page hashes

**Failure mode prevention**: NDH adapter shipped without `store_raw` parameter at S344; S345 verifier discovered post-smoke that `data/raw/news/ndh/` contained 2 .html files for a single 1-article smoke run (1 article + 1 listing). Required inline F2 fix at S345 main close. Vietstock (S354) + VietnamBiz (S357) shipped this pattern from day-one with sextuple-guard verified GREEN; zero retrofit needed.

**Promotion source**: `agent-workspace/memory/observations/sandwich-verifier-S358-vietnambiz-adapter-verify.md` § Section 13 (L-S345-3 PROMOTE-NOW). Original failure-mode evidence: `agent-workspace/memory/observations/sandwich-verifier-S345-ndh-adapter-verify.md` F2.

## Anti-Patterns

- Writing selectors from memory ("all CafeF pages have `.article-content`")
- Skipping retry ("it'll work, we tested it")
- Fetching in tight loops without rate limiting (gets IP banned)
- Ignoring status codes (500 != 200)
- Committing scraped data without `source_url` (violates I-S2 citation rule)

## Do

- Verify against live DOM via VBW
- Retry with exponential backoff + budget cap
- Rate limit per domain
- Monitor shape metrics over time
- Cache aggressively with reasonable TTL
- Preserve raw content in R2 for reprocessing

## Related

- `evidence-extraction` — parsing crawled content into claims
- `prompt-engineering` — LLM extraction from raw HTML
- `agent-workspace/constitution/financial-data-protocol.md` — citation rules (I-S2)
