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
