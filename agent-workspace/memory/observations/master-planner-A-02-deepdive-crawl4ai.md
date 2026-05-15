---
observation_id: master-planner-A-02-deepdive-crawl4ai
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: crawl4ai
repo_path: C:/htdocs/research/crawl4ai/
fit_level_hypothesis: HIGH
fit_level_empirical: HIGH (pattern adoption); MEDIUM-LOW (wholesale port)
license: Apache-2.0 + custom Attribution Requirement (`LICENSE:54-67`)
---

## 1. Repo Summary

Crawl4AI v0.8.6 — "open-source LLM-friendly web crawler & scraper" by Unclecode. Apache-2.0 (`pyproject.toml:11`). Python ≥3.10 (`pyproject.toml:9`). Three product faces (per `docs/onboarding/01-PROJECT-CHARTER.md:5-6`): (a) async Python library, (b) Docker REST/FastAPI server, (c) CLI `crwl` + MCP bridge.

Stated goals (README + `MISSION.md`): turn web into clean LLM-ready Markdown, "no API key" friction, anti-bot resilient, async-first, fully controllable (sessions/proxies/cookies/hooks). Out-of-scope (`docs/onboarding/02-HLD.md:167-172`): vector DB, agent framework, hosted LLM, native non-HTML (PDF partial only). 50k+ GitHub stars; ~86 contributors; v0.8.6 is HEAD security hotfix replacing `litellm` → `unclecode-litellm==1.81.13` (`pyproject.toml:21`, supply-chain compromise per README header).

Top-level package surface (`crawl4ai/__init__.py:1-80`): `AsyncWebCrawler`, configs (`BrowserConfig`, `CrawlerRunConfig`, `SeedingConfig`), strategies (`Extraction`, `Markdown`, `Content Filter`, `Chunking`, `Table`, `Proxy`), `MemoryAdaptiveDispatcher`, `RateLimiter`, `BFS/DFS/BestFirstCrawlingStrategy`, `AsyncUrlSeeder`, `CrawlerHub`, `PDFContentScrapingStrategy`.

Hard deps (`pyproject.toml:15-50`): playwright + patchright + playwright-stealth (browser triple-stack), httpx[http2], aiohttp, BeautifulSoup4 + lxml + cssselect, rank-bm25, snowballstemmer, xxhash, fake-useragent, pydantic≥2.10, unclecode-litellm.

## 2. Architecture / Design Patterns

Top patterns with empirical cites (cross-validated from `docs/onboarding/02-HLD.md:101-114` against source):

1. **Strategy + Facade**. `AsyncWebCrawler` is the single facade; every functional axis (browser, scraping, markdown, extraction, chunking, content-filter, proxy, deep-crawl, table) is an ABC strategy swappable via config. Cite: `markdown_generation_strategy.py:26-52` (`MarkdownGenerationStrategy(ABC)` + abstract `generate_markdown`); `content_filter_strategy.py:33-52` (`RelevantContentFilter(ABC)`); `extraction_strategy.py:87-100` (`ExtractionStrategy(ABC)` with input_format selector); `table_extraction.py:21-56` (`TableExtractionStrategy(ABC)`); `deep_crawling/base_strategy.py:45-80` (`DeepCrawlStrategy(ABC)`).

2. **Memory-aware adaptive semaphore (Dispatcher)**. `MemoryAdaptiveDispatcher` (`async_dispatcher.py:148-216`) runs a background `_memory_monitor_task` using `psutil` true-memory %, enters/exits "memory pressure mode" at configurable thresholds (90% threshold / 95% critical / 85% recovery), and reschedules tasks through `asyncio.PriorityQueue` with fairness-timeout boost (`async_dispatcher.py:170-225, 374-469`). Critical-pressure path re-queues a task with bumped retry+priority instead of blocking the loop (`async_dispatcher.py:289-317`).

3. **Per-domain RateLimiter with exponential backoff + jitter**. `RateLimiter` (`async_dispatcher.py:28-85`) keeps `Dict[str, DomainState]`, sleeps the per-domain `current_delay` before request, on 429/503 doubles the delay with `random.uniform(0.75, 1.25)` jitter capped at `max_delay`, on success decays back toward base. Returns `False` after `max_retries` (3 default) — caller treats as circuit-open.

4. **Filter/Scorer chain for deep crawl URL admission**. `deep_crawling/filters.py:40-140` defines `URLFilter(ABC)` + `FilterChain` (immutable tuple of filters, awaitable apply, `FilterStats` array-backed counters). `deep_crawling/scorers.py:63-80` defines `URLScorer(ABC)` with weighted `_calculate_score`. The pattern: composable URL admission gates (`URLPatternFilter`, `DomainFilter`, `ContentTypeFilter`, `SEOFilter`, `ContentRelevanceFilter`) plus scorers (`KeywordRelevanceScorer`, `DomainAuthorityScorer`, `FreshnessScorer`, `PathDepthScorer`, `CompositeScorer`) — exported in `__init__.py:60-78`.

5. **Cache freshness via HTTP conditional + head fingerprint**. `cache_validator.py:42-100` runs HEAD with `If-None-Match`/`If-Modified-Since`; on 200 it fetches `<head>` and compares an xxhash fingerprint over title + selected meta tags (`utils.py:2885-2943` `compute_head_fingerprint` over og:*, article:modified_time, last-modified, description). Cheap pre-recrawl check; falls back to STALE/ERROR on uncertainty. `CacheMode` enum centralizes ENABLED/DISABLED/READ_ONLY/WRITE_ONLY/BYPASS (`cache_context.py:4-93`).

Bonus pattern: **Hub registry** (`hub.py:37-69`) discovers `crawl4ai/crawlers/<name>/crawler.py` modules at runtime; each subclasses `BaseCrawler(ABC)` with an enforced async `run(url, **kwargs) -> str` signature (`hub.py:24-35` uses `__init_subclass__` to typecheck). Two reference adapters ship: `amazon_product/` and `google_search/` (`crawl4ai/crawlers/` ls).

## 3. Components / Features candidate for StockForge adoption

Per candidate: what it is + StockForge transfer shape (port vs pattern-only).

- **C1. `DefaultMarkdownGenerator` + `PruningContentFilter` + `BM25ContentFilter`** — `markdown_generation_strategy.py:55-260`, `content_filter_strategy.py:33-280, 541-700`. HTML→cleaned-HTML→`CustomHTML2Text` (vendored `html2text`)→raw markdown→link-to-citation `⟨N⟩` rewrite→optional content-filter to `fit_markdown`. PruningContentFilter scores chunks by text-density / link-density / tag-importance with `tag_importance` dict (`content_filter_strategy.py:587-610`) and `metric_weights` blend. **Transfer shape: PATTERN-PORT (~150-300 LOC) into StockForge BC-5 News ingestion as `apps/ingestion/news/markdown_converter.py` + `pruning_filter.py`.** Reason to not vendor whole package: deep coupling to `AsyncLogger`, `models.py` Pydantic types, and a 3000-line `utils.py`.

- **C2. `RateLimiter` + per-domain `DomainState`** — `async_dispatcher.py:28-85`. ~60 LOC of pure logic. **Transfer shape: COPY-WITH-ATTRIBUTION into `apps/_shared/crawl/rate_limiter.py`.** Directly maps to I-S34 ToS-compliance ("rate limits per source"). Replace `[429, 503]` with VN-source-tuned codes if needed; preserve jitter + decay semantics.

- **C3. `MemoryAdaptiveDispatcher` priority-queue + memory monitor** — `async_dispatcher.py:148-469`. ~320 LOC. **Transfer shape: PATTERN-PORT, not direct copy.** Stockforge ingestion CLIs (`apps/cli/ingest_news_cafef.py` family) are single-host bounded-fanout (3-5 trusted peers); we likely don't need full memory-aware reschedule. Take the *idea* (background memory check + PriorityQueue + fairness timeout) but a simpler `asyncio.Semaphore + RateLimiter` adapter suffices for Phase 1.

- **C4. `CacheValidator` (HEAD + If-None-Match + head-fingerprint)** — `cache_validator.py:42-200` + `utils.compute_head_fingerprint:2885-2943`. **Transfer shape: COPY-WITH-ATTRIBUTION** as `apps/_shared/crawl/cache_validator.py`. Maps cleanly to BC-5 News stream dedup + BC-6 Influence content-change detection. Pairs with `xxhash` (already a lightweight dep). No LLM involved — fully deterministic.

- **C5. `RobotsParser` (SQLite-backed, WAL, 7-day TTL)** — `utils.py:252-280+`. ~120 LOC. **Transfer shape: PATTERN-PORT.** I-S34 mandates ToS compliance; per-domain `robots.txt` honor is the minimum-viable form. Stockforge can use `aiosqlite` (already in crawl4ai deps) or just an in-memory dict — depends on whether ingestion is one-shot CLI or long-running worker.

- **C6. `AsyncUrlSeeder` (sitemap.xml + Common Crawl seeding)** — `async_url_seeder.py:1-100`. Sitemap chain walking (.gz + nested indexes), per-domain CDX cache, optional HEAD liveness, optional `<head>` meta parse, global hits-per-second `asyncio.Semaphore`. **Transfer shape: PATTERN-PORT for BC-5/BC-6** — sitemap parsing is generic; Common Crawl seeding may not be needed for VN sources (most are CDN-fronted local domains). Sitemap parsing pattern + lastmod extraction is the keeper (`async_url_seeder.py:81-93`).

- **C7. `URLFilter` + `FilterChain` + `URLScorer` composables** — `deep_crawling/filters.py:40-140`, `deep_crawling/scorers.py:26-80`. **Transfer shape: PATTERN-PORT** for BC-7 Crowd (forum thread filtering, sub-forum scoping) and BC-6 Influence (channel/playlist filtering). Slot-based `__slots__ = ("name", "stats", "_logger_ref")` micro-optimization isn't load-bearing for StockForge — drop it.

- **C8. `CrawlerHub` registry pattern** — `hub.py:37-69` + `BaseCrawler.__init_subclass__` typecheck (`hub.py:24-35`). **Transfer shape: PATTERN-PORT** as the "crawling adapter shape" (master-plan Theme L). Each VN source (CafeF, NDH, VietstockFinance, Vietnam Biz, YouTube channels, Facebook fanpages) becomes a `BaseCrawler` subclass under `apps/ingestion/sources/<name>/crawler.py` with enforced async signature. Excellent fit with DDD per-source ACL anti-corruption layer pattern.

- **C9. `PDFContentScrapingStrategy` + `NaivePDFProcessorStrategy`** — `crawl4ai/processors/pdf/processor.py:1-100`. Strategy ABC + `pypdf`-based naive implementation producing `PDFProcessResult(metadata, pages, processing_time)` with per-page `raw_text + markdown + html + images + links`. **Transfer shape: PATTERN-REFERENCE for BC-3 Reports/PDF.** Naive implementation is too naive for VN broker reports — likely need a more robust extractor (e.g., pdfplumber or a vision-OCR pipeline). But the *strategy shape* (Strategy ABC, optional-import gate at construction, structured `PDFPage`) is reusable.

## 4. Per-BC Mapping

| Candidate | BC | Mapping rationale |
|---|---|---|
| C1 Markdown + Pruning/BM25 Filter | **BC-5 News Stream** | CafeF/NDH/VietstockFinance/Vietnam Biz articles → fit_markdown for downstream claim extraction (I-S1 no-LLM-math: filter strips noise, LLM only interprets) |
| C1 (same) | **BC-6 Influence** | YouTube transcript HTML → markdown; KOL blog posts → markdown |
| C1 (same) | **BC-7 Crowd** | Forum threads / Facebook group posts → markdown |
| C2 RateLimiter | **BC-5, BC-6, BC-7** (all crawling BCs) | I-S34 ToS-compliance enforcement layer |
| C3 MemoryAdaptiveDispatcher | (pattern only) **harness/_shared** | Optional; not required for Phase 1 single-host scale |
| C4 CacheValidator + head-fingerprint | **BC-5, BC-6** | Content-fingerprint dedup per master-plan § 4.2 hypothesis — confirmed |
| C5 RobotsParser | **BC-5, BC-6, BC-7** | I-S34 compliance minimum |
| C6 AsyncUrlSeeder (sitemap) | **BC-5** mainly | News-site sitemap discovery (CafeF/NDH publish sitemaps) |
| C7 FilterChain + URLScorer | **BC-7** (forum sub-area scoping), **BC-6** (channel selection) | URL admission gate; pairs well with DDD value-objects |
| C8 CrawlerHub registry | **harness** + **BC-5/6/7** | "Crawling adapter shape" Theme L — strongest single architectural win |
| C9 PDFContentScrapingStrategy | **BC-3 Reports/PDF** | Strategy shape only; concrete impl needs upgrade (VN broker PDFs are scanned/complex) |
| **out-of-scope**: AsyncWebCrawler facade, browser_manager, deep_crawling BFS/DFS, hooks, MCP bridge, Docker server, C4A Script DSL | — | Wholesale framework — violates Wave-1 "pattern adoption not wholesale-port" constraint |

## 5. Honest Fit Assessment

**Empirical FIT vs hypothesis HIGH:**

- **HIGH for pattern adoption (confirms hypothesis).** The three components named in the master-plan hypothesis (LLM-friendly markdown converter, async crawler scheduling with rate-limits, content-fingerprint dedup) all exist as identifiable, well-bounded modules in the codebase, with deterministic logic and minimal cross-cutting deps inside their own files. C1 + C2 + C4 are a tight cluster that delivers exactly the master-plan § 4.2 hypothesis with ~600-900 LOC of code-port + attribution.

- **MEDIUM-LOW for wholesale framework port (rejects naive port path).** The `AsyncWebCrawler` facade pulls in `playwright + patchright + playwright-stealth + aiohttp + httpx + bs4 + lxml + cssselect + rank-bm25 + snowballstemmer + fake-useragent + unclecode-litellm` (`pyproject.toml:15-50`). For StockForge's single-tenant 3-5 peer scale, this is overkill. Many sub-systems (browser pool tiers, MCP bridge, JWT auth, Docker server, hub auto-discovery of LLM-driven adaptive crawler) are orthogonal to BC-5/6/7 needs.

- **Theme L (crawling adapter shape) recommendation: C8 + C2 + C4 + selective C1.** Adopt the `BaseCrawler(ABC)` + `CrawlerHub` registry shape (single biggest architectural win because it cleanly maps to per-source ACL anti-corruption layer in DDD), copy `RateLimiter` (60 LOC) and `CacheValidator` (~200 LOC) verbatim with attribution, port `DefaultMarkdownGenerator` + `PruningContentFilter` patterns (not the whole strategy hierarchy). Defer browser layer / deep-crawl / dispatcher until empirically required.

- **vs Scrapling + MediaCrawler (cannot ground here — no read access in this dispatch):** decision will need the parallel A-01/A-03 observation files. Crawl4AI's strengths over MediaCrawler are general (any-site markdown) and over Scrapling are scale-ergonomics (memory-aware dispatcher, rate-limiter, cache validator). MediaCrawler likely wins on Facebook/Douyin/Xiaohongshu specifics; Crawl4AI loses on those (no first-party social adapters — only Amazon + Google Search shipped).

- **Risk flag:** sole maintainer (bus factor 1 per `01-PROJECT-CHARTER.md:80`) + recent supply-chain hotfix (`unclecode-litellm` fork) indicates fragility. Pattern-port is safer than dep-vendor.

## 6. License + Attribution

License: **Apache-2.0** (`LICENSE:1-51`) + **custom Attribution Requirement** appendix (`LICENSE:54-67`):

> "All distributions, publications, or public uses of this software, or derivative works based on this software, must include the following attribution: 'This product includes software developed by UncleCode (https://x.com/unclecode) as part of the Crawl4AI project (https://github.com/unclecode/crawl4ai).' This attribution must be displayed in a prominent and easily accessible location, such as: For software distributions: In a NOTICE file, README file, or equivalent documentation. ..."

**Compatibility with stockforge proprietary-default:** ✅ compatible. Apache-2.0 is permissive and explicitly grants derivative-work redistribution under our own license terms (`LICENSE:39`). Our proprietary code that *uses* Apache-2.0 code does not become Apache-2.0 (no copyleft).

**Required actions if we port code from this repo:**

1. Add `NOTICE` file at stockforge repo root listing Crawl4AI attribution string verbatim.
2. In each ported source file, add header comment: `# Portions adapted from Crawl4AI (https://github.com/unclecode/crawl4ai), Apache-2.0`.
3. Retain original copyright headers in any verbatim files copied.
4. Optional: link Crawl4AI in any future about/credits page.

Stockforge stays single-tenant private for now (3-5 peers), but attribution applies even to internal-only redistribution if we treat peers as redistribution. Cheapest path: NOTICE file + per-file header — no friction.

## 7. Risks / Anti-patterns to avoid

- **VN-source selector gap.** Crawl4AI ships only `crawlers/amazon_product/` and `crawlers/google_search/`. No CafeF, no NDH, no VietstockFinance, no Vietnam Biz adapter. Every VN source will be a from-scratch `BaseCrawler` subclass under our codebase. Hypothesis-confirmed in master-plan: we need our own selector library; Crawl4AI buys us the *shape*, not the *content*.

- **`fake-useragent` rotation = ToS-grey.** `pyproject.toml:42` pulls `fake-useragent>=2.0.3` and `playwright-stealth>=2.0.0` (`pyproject.toml:29`). These are *anti-detection* tools. I-S34 ToS compliance + "no insider information" / "public sources only" Charter rule means: **disable stealth-mode features by default in StockForge port.** Use real, stable user-agent strings; honor robots.txt strictly via C5 RobotsParser; rate-limit conservatively (>=2s between requests per domain default). Do not port `UndetectedAdapter` or any `patchright` integration.

- **LLM-extraction strategies sit in same package as deterministic strategies.** `LLMExtractionStrategy`, `LLMContentFilter`, `LLMTableExtraction` (`__init__.py:23, 37, 42`) all exist alongside the deterministic ones. Stockforge I-S1 "NO LLM math" is non-negotiable — when porting, **whitelist deterministic strategies only**: `DefaultMarkdownGenerator`, `PruningContentFilter`, `BM25ContentFilter`, `JsonCssExtractionStrategy`, `JsonXPathExtractionStrategy`, `RegexExtractionStrategy`, `DefaultTableExtraction`. Blacklist the LLM-* variants from the port surface. Numbers/extractions go through deterministic code only; LLM only interprets prose.

- **`unclecode-litellm` fork bus-factor.** Replacing `litellm` with a maintainer-personal fork after supply-chain compromise (`pyproject.toml:21` + README v0.8.6 note) means the dep stream is fragile. If we port code, **do not pull `unclecode-litellm` transitively** — confirm every ported file's import graph and stub-out any `llm_config` paths.

- **Cache freshness false-negatives.** `CacheValidator` head-fingerprint only hashes title + meta tags (`utils.py:2911-2924`). News articles where the body changes but title/meta don't (corrections, updates, comment additions) would be classified FRESH incorrectly. For BC-5 News, layer a body-fingerprint over `cleaned_html` as a second pass before accepting cache-hit — Crawl4AI's mechanism is necessary-but-not-sufficient for our use case.

- **Hub auto-discovery is global mutable state.** `CrawlerHub._crawlers: Dict` is class-level (`hub.py:38`) and populated by `_discover_crawlers` on first `get()`. In tests, this leaks between cases. If we port the registry pattern, refactor to instance-scoped with an explicit `register()` call rather than disk auto-scan.

- **Vendored `html2text` is GPL-adjacent territory.** `crawl4ai/html2text/` is a vendored fork of Aaron Swartz's html2text (originally GPL); the upstream project relicensed to GPL-3.0 then to MIT in various forks. Verify the vendored subdirectory's license before porting — if we port `CustomHTML2Text` (`markdown_generation_strategy.py:3` imports from `.html2text`), check `crawl4ai/html2text/__init__.py` header for the actual license claim. **Do not assume Apache-2.0 covers vendored html2text.** Action item for IMPL: read `crawl4ai/html2text/__init__.py` license header before any port of that module.

- **3K-line `utils.py` is a god-module.** `utils.py:1-3300+` mixes hashing, HTML sanitization, LLM-completion-with-backoff, robots parsing, head fingerprinting, content extraction. Direct imports from it pull a huge dependency surface. Re-implement the 30-50 LOC we actually need (compute_head_fingerprint, RobotsParser shape) rather than import.

---

Self-attestation: every claim cites a specific file in the repo.
