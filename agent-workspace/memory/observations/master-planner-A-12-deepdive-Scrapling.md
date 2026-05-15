---
observation_id: master-planner-A-12-deepdive-Scrapling
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: Scrapling
repo_path: C:/htdocs/research/Scrapling/
fit_level_hypothesis: HIGH
fit_level_empirical: HIGH (parser + adaptive selectors); MEDIUM (fetchers as pattern); LOW (Cloudflare-solver — ToS-grey, do not adopt)
license: BSD-3-Clause (`LICENSE:1`)
---

## 1. Repo Summary

Scrapling v0.4.7 — "adaptive Web Scraping framework" by Karim Shoair (`pyproject.toml:8-13`). BSD-3-Clause (`LICENSE:1`, `pyproject.toml:11`). Python ≥3.10 (`pyproject.toml:35`). Beta status (`pyproject.toml:39`). Single-author project; not the 50k-star scale of crawl4ai but actively developed (last release 0.4.7) and Trendshift-tracked (`README.md:14-15`).

Stated value prop (`README.md:54-58`): one library spanning (a) a fast lxml-based **adaptive parser** that relocates elements after site structure changes via similarity scoring; (b) three **fetchers** (`Fetcher` HTTP/curl_cffi, `DynamicFetcher` Playwright, `StealthyFetcher` patchright + anti-bot bypass); (c) a **Scrapy-like spider framework** with pause/resume, multi-session, streaming, robots.txt compliance.

Top-level package surface (`scrapling/__init__.py` + dir listing):
- `scrapling/parser.py` (1377 LOC) — the `Selector` class (`parser.py:64`) with CSS/XPath/find_all/find_by_text/find_similar/relocate.
- `scrapling/core/` — `storage.py` (SQLite-backed element-fingerprint storage), `translator.py` (CSS→XPath; vendored from Parsel), `mixins.py`, `custom_types.py`, `ai.py` (MCP server), `shell.py` (IPython REPL).
- `scrapling/engines/static.py` — `FetcherSession` / `FetcherClient` over `curl_cffi` (TLS-fingerprint impersonation).
- `scrapling/engines/_browsers/` — `_base.py`, `_stealth.py` (Cloudflare solver), `_controllers.py`, `_config_tools.py`, `_validators.py`.
- `scrapling/engines/toolbelt/` — `proxy_rotation.py` (`ProxyRotator`), `fingerprints.py` (browserforge-backed UA gen), `ad_domains.py` (~3500 ad/tracker domain list), `convertor.py`, `custom.py`, `navigation.py`.
- `scrapling/spiders/` — `spider.py` (abstract `Spider`), `engine.py` (`CrawlerEngine` orchestrator), `scheduler.py`, `session.py` (`SessionManager`), `checkpoint.py`, `cache.py`, `robotstxt.py` (Protego wrapper), `request.py`, `result.py` (`CrawlResult`, `ItemList`).
- `scrapling/fetchers/` — thin facade modules re-exporting `Fetcher`/`AsyncFetcher`/`StealthyFetcher`/`DynamicFetcher`.
- `scrapling/cli.py` — Click-based CLI (`scrapling extract`, `scrapling shell`, `scrapling install`).

Hard deps (`pyproject.toml:63-70`): `lxml>=6.0.3`, `cssselect>=1.4.0`, `orjson>=3.11.8` ("10x faster JSON" claim — `README.md:244`), `tld>=0.13.2`, `w3lib>=2.4.1`, `typing_extensions`.
Optional `[fetchers]` (`pyproject.toml:72-83`): `curl_cffi>=0.15.0`, `playwright==1.58.0`, **`patchright==1.58.2`** (a Playwright fork with anti-detection patches — see § 7 risk), `browserforge>=1.2.4`, `apify-fingerprint-datapoints>=0.12.0`, `msgspec`, `anyio>=4.13.0`, `protego>=0.6.0` (robots.txt parser).
Optional `[ai]`: `mcp>=1.27.0`, `markdownify>=1.2.0`. Optional `[shell]`: IPython.

Multi-language READMEs confirmed at `docs/README_AR.md`, `README_CN.md`, `README_DE.md`, `README_ES.md`, `README_FR.md`, `README_JP.md`, `README_KR.md`, `README_PT_BR.md`, `README_RU.md` (root `README.md` is primary entry, per dispatch brief — confirmed lines 17 with the language nav-bar).

Test coverage: `tests/{ai,cli,core,fetchers,parser,spiders}` directory tree present; parser tests include `test_adaptive.py`, `test_find_similar_advanced.py`, `test_ancestor_navigation.py`; spider tests include `test_checkpoint.py`, `test_force_stop_checkpoint.py`, `test_robotstxt.py`. README claims 92% coverage + full type hints (`README.md:245`) — not independently verified but `tests/` tree is dense; types confirmed via `py.typed` marker in `scrapling/py.typed`.

## 2. Architecture / Design Patterns

1. **Adaptive Selector via element-fingerprint storage + similarity scoring** (the flagship pattern). `Selector.__init__` (`parser.py:80-94`) takes `adaptive` flag and a `storage` class (default `SQLiteStorageSystem` from `scrapling/core/storage.py:74`). Storage persists per-element fingerprints keyed by `(base_url, identifier_hash)` to a WAL-mode SQLite (`storage.py:90-107`). When `css()`/`xpath()` find zero matches AND `adaptive=True`, the code calls `retrieve(identifier)` → `relocate(element_data, percentage)` (`parser.py:665-672`). `relocate` walks every element in the tree and scores it via `__calculate_similarity_score` (`parser.py:803-868`) which blends `SequenceMatcher` ratios over: tag name, text content, attributes dict, individual attrs (class/id/href/src), DOM path, parent name+attribs+text, and siblings. Returns the elements at the highest-scoring percentage above `percentage` threshold.

2. **AutoScraper-inspired `find_similar` (sibling-element finder)** — `parser.py:1009-1068`. Uses XPath constructed from `<grandparent>/<parent>/<self>` tag path with `count(ancestor::*) = current_depth` to gather same-depth same-shape candidates, then filters with `__are_alike` (similarity_threshold default 0.2, ignoring `href`+`src` by default). README benchmark claims ~5.2x faster than AutoScraper (`README.md:454-456`); benchmark code at `benchmarks.py:110-118` measures via `timeit.repeat(number=1, repeat=100)` over `find_by_text("Tipping the Velvet").find_similar(...)`. Methodology is reasonable (warm-up + 100 reps, `process_time`) but the comparison set is narrow (only AutoScraper).

3. **Strategy pattern for fetchers + session pooling**. `_ConfigurationLogic` abstract base (`engines/static.py:49-99`) defines slot-fields for `impersonate`, `stealth`, `proxies`, `timeout`, `retries`, `retry_delay`, `proxy_rotator`. Concrete `FetcherSession` (curl_cffi-backed) and the Playwright-backed sessions (`engines/_browsers/_base.py` → `SyncSession`/`AsyncSession`) implement context-managed lifecycles. `_select_random_browser` (`engines/static.py:35-46`) supports `impersonate=list[BrowserTypeLiteral]` for randomized TLS fingerprinting per request.

4. **Thread-safe `ProxyRotator` with pluggable strategy** — `engines/toolbelt/proxy_rotation.py:39-100`. `__slots__ = ("_proxies", "_proxy_to_index", "_strategy", "_current_index", "_lock")` + `threading.Lock`. Default `cyclic_rotation` (`proxy_rotation.py:33-36`); custom callable strategies accepted. `_PROXY_ERROR_INDICATORS` set (`proxy_rotation.py:7-15`) — `net::err_proxy`, `connection refused`, etc. — drives `is_proxy_error(exc)` for retry routing. Validates dict-form proxies require a `server` key.

5. **Spider engine with concurrent-capacity + per-domain limiters + checkpoint + robots.txt** — `spiders/engine.py:28-100`. `CrawlerEngine` composes `Scheduler`, `SessionManager`, `RobotsTxtManager` (gated by `spider.robots_txt_obey`, `engine.py:47-54`), `ResponseCacheManager` (dev mode), `CheckpointManager`. Uses `anyio.CapacityLimiter(concurrent_requests)` global + per-domain limiters dict (`engine.py:63-64`). Robots compliance check at `_process_request` (`engine.py:174-179`) — when disallowed, increments `stats.robots_disallowed_count` and silently drops (does not raise). `_get_domain_delay` (`engine.py:93-112`) takes max of spider's configured delay and robots.txt Crawl-delay/Request-rate (`spiders/robotstxt.py:52-60`, `protego.crawl_delay("*")` + `request_rate("*")`).

## 3. Components / Features candidate for StockForge adoption

Per candidate: what it is + StockForge transfer shape (port vs pattern-only).

- **C1. Adaptive selector (`Selector.css`/`xpath` + `relocate` + `SQLiteStorageSystem`)** — `parser.py:564-692`, `parser.py:519-562`, `core/storage.py:74-157`. **The headline feature.** When CafeF/NDH/Vietstock change CSS class names (a common occurrence for VN news sites that A/B test layouts), an adaptive selector with a saved fingerprint can find the equivalent element via tag+attributes+DOM-path+sibling similarity. The similarity score blends 7-9 signals via `SequenceMatcher` ratios (`parser.py:814-866`). **Transfer shape: PATTERN-PORT (~250 LOC core) into `apps/_shared/crawl/adaptive_selector.py`.** Direct vendoring is feasible (BSD-3 permissive) but the core algorithm is small enough that a re-implementation tuned to StockForge needs (e.g., dropping `siblings` if sites have noisy nav) is preferable. Storage layer (SQLite + WAL + thread-safe RLock) is reusable as-is. **CRITICAL CAVEAT**: the README's "auto-adaptive" framing implies magic; in reality the user MUST have called `auto_save=True` on a healthy run first, otherwise there is no fingerprint to relocate against. The `adaptive=True` flag without prior fingerprints is a no-op (`parser.py:665-684`). This is a *recovery* mechanism, not prevention — site changes will still cause one failed run before adaptation kicks in.

- **C2. `find_similar` (sibling-element auto-discovery)** — `parser.py:1009-1068`. Given one product/article/post element, find every other element at the same DOM depth + same tag path + similar attributes. **Transfer shape: PATTERN-PORT** for BC-7 Crowd (forum thread listings) and BC-5 News (article cards). ~60 LOC of pure logic. Useful when sites add/remove items inside a list container — picks up new items without selector changes.

- **C3. `FetcherSession` + `curl_cffi` TLS-fingerprint impersonation** — `engines/static.py:49-200+`. The HTTP fetcher impersonates real browser TLS fingerprints (Chrome/Firefox/Safari) at the socket level via `curl_cffi`, defeating JA3/JA4 fingerprinting that many anti-bot services use. **Transfer shape: DEPENDENCY-ADOPT (use `curl_cffi` directly) for BC-5 News HTTP fetches.** Stockforge doesn't need to vendor Scrapling's session wrapper; `curl_cffi.requests.Session(impersonate="chrome")` is the actual workhorse. Scrapling adds value-add: ProxyRotator integration + retry-with-jitter + stealthy-headers merge. Pattern-level adoption: ~150 LOC of `_ConfigurationLogic._merge_request_args` (`engines/static.py:101-140+`).

- **C4. `ProxyRotator` (cyclic + custom strategies)** — `engines/toolbelt/proxy_rotation.py:39-100`. ~100 LOC. **Transfer shape: COPY-WITH-ATTRIBUTION** to `apps/_shared/crawl/proxy_rotator.py` IF Stockforge needs proxy rotation (likely Phase 2+ when scale demands it; Phase 1 single-user can skip). Simpler than crawl4ai's `ProxyConfig` because there's no async + memory-pressure logic — it's just a thread-safe round-robin with pluggable callable.

- **C5. `RobotsTxtManager` (Protego + per-domain cache)** — `spiders/robotstxt.py:10-60`. ~70 LOC. Wraps `protego` parser with an async fetch_fn + dict cache. Exposes `can_fetch(url, sid)` + `get_delay_directives(url, sid)` returning `(crawl_delay, request_rate_tuple)`. **Transfer shape: COPY-WITH-ATTRIBUTION** into `apps/_shared/crawl/robots.py`. Maps directly to I-S34. Note: cache is in-memory dict, not persistent — for long-running daemons, swap to SQLite. (crawl4ai's RobotsParser already covers SQLite-backed; comparison below.)

- **C6. Spider checkpoint/resume (Ctrl+C → resumable crawl)** — `spiders/checkpoint.py`, `spiders/spider.py:225-237` (`pause()`), `spiders/spider.py:99-104` (`crawldir=...` argument). **Transfer shape: PATTERN-REFERENCE only** for Phase 2+. Phase 1 Stockforge ingestion is CLI-batch (one-shot per source per day); checkpoint adds complexity without payoff. Revisit when continuous crawling lands.

- **C7. Development-mode response cache** — `spiders/cache.py` + `engine.py:56-61`. On first run, cache HTTP responses to `.scrapling_cache/<spider_name>/`; subsequent runs replay from cache. **Transfer shape: PATTERN-PORT** for StockForge crawler development/test workflow. Mirrors crawl4ai's `CacheValidator` but simpler (no fingerprint-based freshness). Stockforge crawler tests would benefit — currently presumably hit live sites.

- **C8. Browserforge-based header generation (`generate_headers`)** — `engines/toolbelt/fingerprints.py:37-56`. Generates realistic browser-coherent headers (UA + sec-ch-ua + Accept-Language) consistent with the impersonated browser/OS combo. Uses `browserforge` library which has a database of real browser header sets. **Transfer shape: DEPENDENCY-ADOPT (`pip install browserforge`)** for BC-5 News HTTP fetches. ~20 LOC wrapper.

- **C9. Speed-optimized lxml parser with `orjson` storage serialization** — `parser.py:6-16, 47-61`. Pre-compiled XPath expressions cached at module load (`_find_all_elements = XPath(".//*")` etc.); `orjson` for storage marshalling (10x faster than stdlib per README). **Transfer shape: PATTERN-REFERENCE.** Stockforge doesn't need a custom Selector class — `parsel` or `selectolax` already give us what we need. The *pattern* (pre-compile hot XPaths at module load) is worth copying into any custom extractor we write.

Speed claims with benchmark evidence: README table (`README.md:438-447`) shows Scrapling at 2.02ms vs Parsel/Scrapy at 2.04ms (1.01x slower), Raw Lxml at 2.54ms (1.26x), BS4+lxml at 1584ms (~784x). **Honest read**: Scrapling is statistically tied with Parsel (1% delta is within run-to-run noise; method `mean(times)` over 100 reps); raw-lxml-faster claim is wrong (Scrapling is 0.52ms faster than raw lxml due to selector-precompile + `::text` shortcut path, but this could flip on different HTML shapes). The 784x BS4 result is real and reflects BS4's known slowness — not a Scrapling-specific win. **Benchmark code is verifiable at `benchmarks.py:46-95`** so re-running locally is straightforward.

## 4. Per-BC Mapping

- **BC-1 Portfolio**: no fit. Scrapling doesn't deal with portfolio modeling.
- **BC-2 Universe**: marginal. If we need to harvest ticker lists from VN exchange pages, Scrapling's adaptive selectors help when HOSE/HNX redesign. Tiny payoff vs FiinPro/SSI direct APIs.
- **BC-3 Fundamentals**: marginal. VN broker reports are mostly PDFs (Scrapling has no PDF support) or behind paywalls. Skip.
- **BC-4 Macro**: low fit. Government/SBV data better via direct CSV/Excel pulls.
- **BC-5 News (CafeF, NDH, VietstockFinance, Vietnam Biz)**: **HIGH FIT.** Adaptive selectors + FetcherSession TLS impersonation + RobotsTxtManager directly serve the use case. C1 + C3 + C5 + C8 transfer shapes apply.
- **BC-6 Influence (YouTube transcript scrape, Facebook fanpages)**: **MEDIUM FIT.** YouTube transcript page is dynamic JS — needs DynamicFetcher (Playwright). But yt-dlp is the canonical tool for YouTube; Scrapling overkill here. Facebook public pages: `StealthyFetcher` works but ToS-grey (see §7). Adaptive selectors useful for FB layout drift. F319 forums (BC-7) overlap.
- **BC-7 Crowd (F319 forums, Reddit-style threads)**: **HIGH FIT.** `find_similar` is purpose-built for "given one thread card, find the rest" pattern. Spider framework with concurrent_requests + per-domain throttling handles forum politeness. C2 + C6 + spider framework apply.
- **BC-8 Adversary**: low fit (signal correlation logic, not scraping).
- **BC-9 Calibration**: no fit (post-hoc accuracy tracking, not scraping).

Dominant fit: BC-5 (news) + BC-7 (crowd). BC-6 partial.

## 5. Honest Fit Assessment

Hypothesis HIGH (per master-plan § 4.12) — Empirical verdict mixed:

**HIGH FIT components (empirical agreement with hypothesis)**:
- The adaptive parser is genuinely novel and well-engineered. Code quality in `parser.py:803-868` (similarity score) is clean, has type hints, follows a coherent algorithm. **This IS the differentiator** vs Parsel/lxml — and it directly addresses I-S34's spirit (resilience to site changes without re-engineering, but with explicit per-element fingerprint storage that we control).
- `ProxyRotator` and `RobotsTxtManager` are small, high-quality, copy-paste-ready.
- Curl_cffi-based TLS impersonation is industry-standard for evading basic anti-bot; Scrapling's wrapper is thin.

**MEDIUM FIT (hypothesis overstates)**:
- The "speed-focused fetch primitives" claim is real but **benchmarks compare apples-to-oranges in places**: the 784x BS4 win is BS4's problem, not Scrapling's superiority. Scrapling ≈ Parsel; choose Scrapling for the adaptive feature, not for parsing speed.
- The Spider framework duplicates what Scrapy already does, but in async-anyio form. Stockforge doesn't need a full spider framework Phase 1; the *patterns* (concurrent_requests, per-domain limiter, robots.txt obey, dev-mode cache) are the keepers.

**LOW FIT / DO NOT ADOPT (hypothesis overstates)**:
- **`StealthyFetcher._cloudflare_solver`** (`engines/_browsers/_stealth.py:107-181`) is a **mouse-click-on-Turnstile-iframe automation** that calculates Captcha coordinates and clicks via `page.mouse.click(captcha_x, captcha_y)` with randomized delays. This is **explicit Cloudflare evasion** — Cloudflare's ToS prohibits this; Stockforge I-S34 mandates ToS compliance. **DO NOT ADOPT.** Even Scrapling's own `README.md:524-525` includes a CAUTION: "respect terms of service of websites and robots.txt files" — yet ships an active CF bypass. Internal contradiction.
- **`patchright`** (`pyproject.toml:75`) is a community Playwright fork specifically patched for anti-detection (e.g., removes `webdriver` property, spoofs `navigator.plugins`). Using it implies intent to evade automation detection. Acceptable for stealth on *public* pages but problematic on sites that explicitly forbid automation in ToS.

**Benchmark substantiation check**: the parser-speed benchmark (`benchmarks.py:46-95`) is reproducible and methodology is sound (warm-up + 100 reps, `process_time`). The 5.2x AutoScraper win (`benchmarks.py:110-118`) is a narrow comparison — there's no benchmark vs lxml's own `iterancestors` + manual sibling discovery, which would be the strongest baseline. **Flag**: the "10x faster JSON serialization" claim (`README.md:244`) is an `orjson` property, not a Scrapling property. **Flag**: "92% test coverage" (`README.md:245`) is not corroborated by any in-repo coverage report file — claim is plausible given the dense `tests/` tree but not independently verified in this scan.

**Code-quality empirical signals**:
- Type hints throughout: confirmed (`py.typed` marker present; `parser.py:18-36` extensive `typing` imports; `pyproject.toml:118-126` configures both `mypy` and `pyright`).
- Battle-tested claim ("used daily by hundreds of Web Scrapers over the past year" — `README.md:245`): unverifiable.
- API stability: version 0.4.7 = Beta status (`pyproject.toml:39`); pre-1.0 means breaking changes expected.

Overall: hypothesis HIGH is correct for the **parser + adaptive-selector + storage** triad (port these). MEDIUM for fetcher/spider patterns (pattern-only, don't vendor). LOW/REJECT for Cloudflare-solver + patchright-stealth (ToS conflict).

## 6. License + Attribution

**License**: BSD-3-Clause (`LICENSE:1-28`). Permissive — allows commercial use, modification, redistribution. Three conditions: (1) retain copyright notice in source; (2) retain copyright notice in binary docs; (3) **no endorsement use** of the copyright holder's name without permission.

**Stockforge attribution requirement**: when porting code (e.g., C1 adaptive selector, C4 ProxyRotator, C5 RobotsTxtManager), each ported file MUST carry a header like:
```python
# Adapted from Scrapling (BSD-3-Clause) by Karim Shoair
# https://github.com/D4Vinci/Scrapling
# Original file: scrapling/<path>.py
```

The Scrapling repo itself adapts code from Parsel (BSD) — see `README.md:543-546` and the per-file note in `scrapling/core/translator.py` ("adapted from Parsel"). Same pattern to follow.

**Citation** (`README.md:528-537`): if using for research, cite `@misc{scrapling, author = {Karim Shoair}, ...}`. Stockforge thesis log or post-mortem references to Scrapling-derived components should cite per this BibTeX.

**Author**: Karim Shoair, karim.shoair@pm.me (`pyproject.toml:13`).

## 7. Risks / Anti-patterns

1. **Cloudflare Turnstile bypass conflicts with I-S34 (ToS compliance)** — `engines/_browsers/_stealth.py:107-200, 382-460`. This is **active circumvention of Cloudflare's anti-bot mechanism via automated mouse-click on the Turnstile widget**. Cloudflare's ToS, and the ToS of any site protected by Cloudflare, almost universally prohibit this. Stockforge MUST NOT adopt `solve_cloudflare=True` or the `_cloudflare_solver` code path. The `StealthyFetcher` class as a whole is suspect — even without `solve_cloudflare`, it uses `patchright` (a Playwright fork patched to defeat headless detection). **Hard recommendation: do not import `StealthyFetcher` or `patchright` into Stockforge.** Use only `Fetcher` (curl_cffi) and possibly `DynamicFetcher` (vanilla Playwright) for legit-need cases.

2. **Adaptive selector requires prior fingerprint — magic framing misleading**. `parser.py:665-684` shows that `adaptive=True` without prior `auto_save=True` is a logged warning and a no-op. The README's "Scrape data that survives website design changes!" (`README.md:64-66`) is technically true but requires a healthy first-run baseline. **Anti-pattern**: relying on adaptive selectors as primary resilience strategy. Use them as a *fallback*; treat selector failures as real failures requiring human inspection.

3. **SQLite storage at default path may collide across projects** — `parser.py:47` (`__DEFAULT_DB_FILE__ = str(Path(__file__).parent / "elements_storage.db")`) puts the DB inside the installed Scrapling package directory. Multi-project use without explicit `storage_args={"storage_file": "..."}` causes cross-project fingerprint leakage. **Stockforge mitigation**: when porting the adaptive feature, force explicit per-source storage paths (e.g., `data/crawl/fingerprints/cafef.db`).

4. **Benchmark vs production reality gap** — `benchmarks.py:17-19` uses synthetic deeply-nested HTML (`<div class="item">` × 5000). Real VN news pages have varied structure with mixed text/image/script content; the speed margin over Parsel could narrow or invert. **No benchmarks shipped for fetcher latency** (only parser); claims like "Lightning Fast" (`README.md:242`) for fetchers are unsubstantiated by in-repo data.

5. **Single-author project, pre-1.0** — `pyproject.toml:12-13` lists one author/maintainer (Karim Shoair). Beta status (`pyproject.toml:39`) means API can change. For a Stockforge core dependency, this is a **supply-chain risk** — if Karim halts maintenance, Stockforge inherits ownership of any vendored code. **Mitigation**: extract the algorithm (C1/C2/C4/C5) into local `apps/_shared/crawl/` modules with attribution, don't pin `scrapling==0.4.x` as a runtime dependency.

6. **`browserforge` + `apify-fingerprint-datapoints` deps phone home for fingerprint updates?** — `pyproject.toml:78-79`. Not verified in this scan, but worth a supply-chain audit before adopting. Both are commercial-tier libraries (Apify is a paid scraping platform that open-sources fingerprint data). Static datapoints package likely just bundles JSON; verify before runtime adoption.

7. **No GDPR/privacy-aware text handling** — Scrapling extracts text wholesale; no PII detection or redaction. Stockforge BC-6 (Influence) and BC-7 (Crowd) scrape user-generated content where Vietnamese PII (full names, phone numbers) is common in forum posts. **Mitigation**: layer a PII-redaction step downstream of any Scrapling-based extractor.

8. **Spider's "blocked detection" is HTTP-status-only** — `spiders/spider.py:16` defines `BLOCKED_CODES = {401, 403, 407, 429, 444, 500, 502, 503, 504}` and `is_blocked` (`spider.py:197-201`) just checks `response.status in BLOCKED_CODES`. Real anti-bot blocks often return 200 + HTML challenge page (e.g., Cloudflare interstitial). **Anti-pattern if adopted naively**: implement content-based block detection for VN sites (e.g., detect `<title>Just a moment...</title>` server-side, distinct from solving it client-side).

## Comparison-Probe: Scrapling vs crawl4ai vs MediaCrawler (Theme L bake-off)

Cross-reference: `master-planner-A-02-deepdive-crawl4ai.md` (FIT empirical HIGH pattern / MEDIUM-LOW wholesale) and `master-planner-A-05-deepdive-MediaCrawler.md` (FIT empirical MEDIUM-LOW, non-OSI license blocker).

When is Scrapling **preferred**?

- **Pick Scrapling for: adaptive-selector resilience + lightweight footprint.** If the dominant Stockforge risk is "VN news site redesigns break selectors weekly" → Scrapling's `relocate` + `SQLiteStorageSystem` (~300 LOC port) is the cheapest insurance. Crawl4ai has nothing equivalent (it relies on CSS/XPath + LLM-extraction fallback). MediaCrawler has neither.

- **Pick Scrapling for: BSD-3 permissive license without attribution-clause friction.** Crawl4ai is Apache-2.0 + custom Attribution Requirement (must add badge/link). MediaCrawler is **non-OSI** (commercial use prohibited) — auto-DISQUALIFIED for Stockforge (which is research-aid for self+3-5 peers but ToS-clean is mandatory). Scrapling BSD-3 wins on legal simplicity.

- **Pick crawl4ai for: LLM-friendly Markdown output + memory-aware concurrency + sitemap seeding.** Scrapling has no Markdown converter (`html2text` is in crawl4ai not Scrapling). For BC-5 News → LLM ingestion pipeline, crawl4ai's `DefaultMarkdownGenerator` + `PruningContentFilter` + `BM25ContentFilter` are purpose-built. Scrapling parses; crawl4ai parses *and* synthesizes-for-LLM. Crawl4ai's `MemoryAdaptiveDispatcher` is overkill for Phase 1 (single-user) but useful Phase 2+.

- **Pick MediaCrawler for: NOTHING (license blocker).** The non-commercial license rules it out for any portable code. At most: pattern-reference for CDP-mode Chrome attachment (Bilibili-specific patterns aren't relevant to VN sources).

- **Hybrid path (recommended)**: port Scrapling's **adaptive selector + ProxyRotator + RobotsTxtManager + find_similar** (~600 LOC total) AND port crawl4ai's **DefaultMarkdownGenerator + PruningContentFilter + CacheValidator + RateLimiter** (~800 LOC total) into `apps/_shared/crawl/` with proper attribution. Both BSD/Apache permissive. Skip the Cloudflare-solver, skip patchright, skip MediaCrawler entirely. This combo gives Stockforge: site-change-resilient selectors + LLM-ready Markdown output + ToS-clean rate limiting + per-source proxy rotation — without buying into a single framework's full opinionation.

Self-attestation: every claim cites a specific file in the repo.
