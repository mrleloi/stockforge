---
id: D-066-bc5-crawler-adapter-contract
title: BC-5 CrawlerAdapter Port Contract — Crawl4AI + Scrapling Hybrid Adoption
date: 2026-05-16
status: PROPOSED
level: IMPL

author:
  - "Claude Sonnet 4.6"   # sandwich-dev S338 (executing plan-020 from architect S337)

source_evidence:
  - path: agent-workspace/observations/master-planner-A-02-deepdive-crawl4ai.md
    section: "§ 2 patterns 1-5 + § 3 C1/C2/C4/C5/C7/C8 + § 5 (async vs sync) + § 6 (license attribution) + § 7 (risk flags: global mutable state, fake-useragent, playwright-stealth)"
  - path: agent-workspace/observations/master-planner-A-12-deepdive-Scrapling.md
    section: "§ 3 C5 (RobotsTxtManager) + § 6 (BSD-3-Clause) + § 7 #1 (Cloudflare-solver HARD REJECT + patchright DO NOT IMPORT + StealthyFetcher excluded)"
  - path: agent-workspace/observations/master-planner-A-05-deepdive-MediaCrawler.md
    section: "§ 5 (Non-Commercial Learning License 1.1 — ZERO literal LOC port permitted) + § 7 #3 (CDP-connect-existing-Chrome consent-mode reference only, future Facebook fanpages)"
  - path: agent-workspace/memory/decisions/061-wave-1-integration-ratification.md
    section: "§ Decision item 3 (Theme L hybrid winner = crawl4ai Apache-2.0 + Scrapling BSD-3) + § Decision item 4 (Scrapling Cloudflare-solver HARD REJECT)"
  - path: agent-workspace/constitution/financial-data-protocol.md
    section: "Rule 16 (Numeric-Field Discipline) — schema discipline audit per D-065"
  - path: .claude/skills/crawler-reliability/SKILL.md
    section: "§ Selector Robustness fallback chain + § Retry & Backoff tenacity recipe + § Rate Limiting per-domain semaphore + § Storage R2 layout + § Monitoring shape metrics + § Anti-Patterns list"
  - path: C:/htdocs/research/crawl4ai/crawl4ai/hub.py
    section: "lines 24-35 (BaseCrawler.__init_subclass__ typecheck) + lines 37-69 (CrawlerHub registry — global-state anti-pattern refactored to instance-scoped)"
  - path: C:/htdocs/research/crawl4ai/crawl4ai/async_dispatcher.py
    section: "lines 28-85 (RateLimiter + DomainState — sync port adapted)"
  - path: C:/htdocs/research/crawl4ai/LICENSE
    section: "lines 54-67 (Attribution Requirement clause — verbatim in NOTICE file)"
  - path: C:/htdocs/research/Scrapling/scrapling/spiders/robotstxt.py
    section: "lines 10-60 (RobotsTxtManager — sync port adapted)"
  - path: C:/htdocs/research/Scrapling/LICENSE
    section: "lines 1-28 (BSD-3-Clause copyright — Karim shoair 2024)"
  - path: agent-workspace/constitution/architecture.md
    section: "§ BC-5 (domain = pure, application = ports, infrastructure = adapters; cross-BC via contracts only)"
  - path: agent-workspace/constitution/invariants-stockforge.md
    section: "§ I-S34 (ToS compliance — Scrapling Cloudflare-solver HARD REJECT) + § I-S35 (research-aid framing)"
  - path: packages/infrastructure/news/cafef_scraper.py
    section: "full file (213 LOC — Strategy B WRAP migration source)"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 45

options_considered:
  - id: A
    summary: "REPLACE — CafeFAdapter replaces CafeFScraper entirely; old class deprecated"
    pros: ["clean single source of truth", "no dual-class maintenance"]
    cons: ["larger diff", "behavioral risk on proven date-parser logic (cafef_scraper.py:178-208)"]
  - id: B
    summary: "WRAP — CafeFAdapter wraps CafeFScraper; delegates discover/fetch_article/to_news_article"
    pros: ["zero behavioral risk", "preserves fixture-driven test surface", "minimal diff"]
    cons: ["dual-class coexistence", "future consolidation needed (RM12 carry-forward)"]

chosen: B
chosen_rationale: |
  Strategy B (WRAP) chosen for zero behavioral-risk migration. The CafeFScraper's
  published_at parser (cafef_scraper.py:178-208) covers 3 VN date formats and is proven
  by fixture tests. Wrapping preserves it untouched while exposing the new CrawlerAdapter
  ABC surface. The CLI dispatch (ingest_news_cafef.py) migrates from CafeFScraper() to
  registry.get("cafef") while maintaining byte-identical user-visible output. A follow-up
  Phase D-N session may consolidate to Strategy A if maintenance friction accumulates.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-16
    via: "session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md (plan-020 dev execution S338)"

verified_by:
  - mechanism: sandwich-verifier
    at: TBD-S339
    result: PENDING

affects:
  charter: false
  spec_files: []
  code_paths:
    - packages/application/news/ports/crawler_adapter.py
    - packages/application/news/ports/crawler_registry.py
    - packages/application/news/ports/__init__.py
    - apps/_shared/crawl/rate_limiter.py
    - apps/_shared/crawl/robots_manager.py
    - apps/_shared/crawl/selector_chain.py
    - apps/_shared/crawl/raw_html_sink.py
    - packages/infrastructure/news/crawler_adapters/cafef_adapter.py
    - packages/infrastructure/news/__init__.py
    - apps/cli/ingest_news_cafef.py
    - NOTICE
    - pyproject.toml
  config_files:
    - pyproject.toml
  other_decisions:
    - D-061
    - D-062
    - D-064
    - D-065

depends_on:
  - D-061
  - D-062
  - D-064
  - D-065

supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: N/A

tags: ["bc-5", "crawler", "wave-1", "phase-d", "theme-l", "crawl4ai", "scrapling", "news-stream"]
---

# Decision 066 — BC-5 CrawlerAdapter Port Contract

## Context

Wave 1 Phase D (Theme L) introduces the crawling adapter foundation for BC-5 News Stream.
The master plan (§ 6.4.1) identified four priority Vietnamese news sources (CafeF, NDH,
VietstockFinance, VietnamBiz) and three research repos (crawl4ai, Scrapling, MediaCrawler)
via D-061 Wave 1 ratification. This ADR records the architectural decisions for the first
Phase D IMPL session (S338): port shape, hybrid library adoption, migration strategy, and
compliance audit.

## The CrawlerAdapter Port + CrawlerRegistry

### Port location

The `CrawlerAdapter(ABC)` lives at `packages/application/news/ports/crawler_adapter.py`
(application layer) per BC-5 layer boundaries. Domain is pure (no I/O); application declares
ports; infrastructure implements them. The `CrawlerRegistry` (instance-scoped) lives alongside
at `packages/application/news/ports/crawler_registry.py`.

### Method shape

```python
class CrawlerAdapter(ABC):
    source_id: ClassVar[str]  # enforced non-empty via __init_subclass__

    def discover(listing_path, max_articles) -> list[str]: ...
    def fetch_and_parse(url) -> ScrapedArticle | None: ...
    def to_news_article(scraped, ticker_universe) -> NewsArticle: ...
```

### Why ABC, not Protocol (DD-3 exception to stockforge convention)

The stockforge convention (per `LlmExtractorProtocol`) is to use `typing.Protocol` for
ports. This plan uses `ABC` for the following reason: crawl4ai `hub.py:24-35` uses
`BaseCrawler(ABC)` with `__init_subclass__` to validate the `run()` method signature at
class-definition time. ABC + `__init_subclass__` provides runtime-enforced contracts that
Protocol cannot replicate — Protocol is static-only (mypy), doesn't validate at subclass
definition time. The `source_id: ClassVar[str]` enforcement fires at class-definition,
ensuring registry keying is safe before any instance is created.

**Convention exception**: this is the only port in BC-5 that uses ABC. The inconsistency is
documented here and in CLAUDE.md as an explicit exception. Future ports default to Protocol
unless `__init_subclass__` runtime enforcement is needed.

### Why instance-scoped registry (DD-5)

The crawl4ai `CrawlerHub._crawlers` dict is class-level — a global mutable state that leaks
between test cases (A-02 § 7 anti-pattern). This implementation is instance-scoped: each
CLI run or test constructs a fresh `CrawlerRegistry()`. No monkey-patching needed in tests.

### Async deferred to Phase 3 (DD-2)

The adapter interface is synchronous (`def fetch_and_parse`, not `async def`). The entire
BC-5 downstream pipeline is sync (`CafeFScraper`, `SqliteNewsRepository`,
`ClaimExtractionService`, CLI loop). Introducing async to ONE adapter would require
`asyncio.run()` at every CLI call site (anti-pattern) or full chain migration (out-of-scope
Phase 3). The crawl4ai `AsyncWebCrawler` is async-first, but our PATTERN-ADOPT shape
(not pip-install) means we own the sync/async decision.

## Foundation Primitives — `apps/_shared/crawl/`

| Module | Source | License | Pattern |
|---|---|---|---|
| `rate_limiter.py` | crawl4ai `async_dispatcher.py:28-85` | Apache-2.0 | Sync port of RateLimiter + DomainState; seeded RNG (D-059 R2) |
| `robots_manager.py` | Scrapling `spiders/robotstxt.py:10-60` | BSD-3-Clause | Sync port of RobotsTxtManager; protego library |
| `selector_chain.py` | crawler-reliability skill § Selector Robustness | (fresh) | First-non-None fallback chain; logs warning on all-fail |
| `raw_html_sink.py` | DD-6 + D-062 + D-064 | (fresh) | Atomic tmp+replace; safe_path containment; tz-aware datetime |

## Hybrid Adoption Strategy

### Adopted from crawl4ai (Apache-2.0 + Attribution)

- `BaseCrawler(ABC)` + `__init_subclass__` typecheck pattern → `CrawlerAdapter` ABC
- `RateLimiter` + `DomainState` rate-limiting primitives → `apps/_shared/crawl/rate_limiter.py`
- `CrawlerHub` instance-scoped refactor (anti-pattern fix) → `CrawlerRegistry`

Attribution: "This product includes software developed by UncleCode
(https://x.com/unclecode) as part of the Crawl4AI project
(https://github.com/unclecode/crawl4ai)." — reproduced verbatim in `NOTICE` at repo root
as required by the Apache-2.0 + Attribution Requirement clause (crawl4ai/LICENSE:54-67).

### Adopted from Scrapling (BSD-3-Clause)

- `RobotsTxtManager` robots.txt cache + can_fetch pattern → `apps/_shared/crawl/robots_manager.py`

Copyright preserved in file header and `NOTICE` per BSD-3-Clause terms.

### HARD REJECTED (I-S34 / D-061 § Decision item 4)

The following are PERMANENTLY banned from all stockforge crawler code:
- `patchright` (Scrapling Cloudflare-solver dependency)
- `playwright_stealth` / `playwright-stealth`
- `fake-useragent`
- `StealthyFetcher` (Scrapling class)
- `_stealth.py` / `_browsers/` (Scrapling internal paths)
- Any Scrapling Cloudflare-solver path
- Any MediaCrawler literal LOC (Non-Commercial Learning License 1.1 blocks commercial use)

### MediaCrawler (Pattern Reference Only)

MediaCrawler CDP-connect-existing-Chrome consent mode (A-05 § 7 #3) is referenced as the
future Facebook-fanpage path. ZERO literal LOC ported (license blocker).

## CafeF Migration (Strategy B — WRAP)

The `CafeFAdapter` wraps `CafeFScraper` and delegates all three methods:
- `discover` → `CafeFScraper.discover`
- `fetch_and_parse` → `CafeFScraper.fetch_article`
- `to_news_article` → `CafeFScraper.to_news_article`

The CLI `ingest_news_cafef.py` now dispatches via `CrawlerRegistry`:
```python
registry = CrawlerRegistry()
registry.register(CafeFAdapter(fetcher=_httpx_fetcher))
scraper = registry.get("cafef")
```

The `_scrape_articles` function updated to call `scraper.fetch_and_parse(url)` (adapter method)
instead of `scraper.fetch_article(url)` (legacy CafeFScraper method). All user-visible CLI
flags, echo lines, exit codes, and summary output remain byte-identical.

**RM12 carry-forward**: a follow-up Phase D-N session should consolidate `CafeFScraper` and
`CafeFAdapter` into a single class once the adapter shape is proven stable.

## Rule 16 Audit (D-065 Binding)

Per plan 020 § Schema discipline, this bundle introduces ZERO new LLM-emitted numeric fields:

| Field | Type | Where | Rule 16 Mode | Notes |
|---|---|---|---|---|
| (none new) | — | — | — | Adapter output flows through existing ScrapedArticle → NewsArticle → NewsArticleIngested; current numeric inventory unchanged |
| `DomainState.current_delay` | float | `apps/_shared/crawl/rate_limiter.py` | N/A — infra-internal | Deterministic timing state; never LLM-emitted; never schema field on domain/event |
| `SelectorChain` tried counter | int | `apps/_shared/crawl/selector_chain.py` | N/A — infra-internal | Deterministic selector-match count; never LLM-emitted |
| `ExtractorMetadata.confidence_extracted` | float | (EXISTING; not modified) | Mode #3 | Calibration-database lookup target; populated by LLM extractor downstream, NOT by crawler |

Zero new Rule 16 surface introduced. Rule 16 compliance satisfied by construction.

## Storage — Local Filesystem Phase 2, R2 Phase 3

`RawHtmlSink` saves to `data/raw/news/<source>/<YYYY-MM-DD>/<sha256(url)[:16]>.html`.
Phase 3 will promote to Cloudflare R2 per crawler-reliability skill § Storage. Local path
uses `safe_path()` (D-064 P1 sandbox containment) + atomic tmp+replace (D-062).

## pyproject.toml Changes

- Added `"protego>=0.3.1"` dependency (RM6 — absent from pyproject.toml pre-S338)
- Added `--import-mode=importlib` to pytest `addopts` (resolves `packages/_shared` vs
  `apps/_shared` module naming collision when collecting all tests together)

## Compliance Enforcement

Ports and adapters use existing W0-substrate hooks automatically:
- `python-determinism-check.sh` (D-059) — rate_limiter.py uses seeded Random(0) + monotonic()
- `atomic-write-check.sh` (D-062) — raw_html_sink.py uses tmp + os.replace()
- `path-safety-check.sh` (D-064) — raw_html_sink.py uses safe_path()
- `bash-hook-lint.sh` — no new hooks in this bundle
- No new hook shipped (rationale: product substrate; static-analysis rule deferred to
  follow-up plan per § Out-of-scope item 7)

## Charter Alignment

- **Principle 4** (Data moat): raw HTML preserved for reprocessing without re-fetching.
- **Principle 7** (Dogfood): CafeF migration ships usable in CLI at S338.
- **Principle 8** (Calibration over confidence): SelectorChain counts strategy attempts;
  shape-metrics emit deferred to Phase 3 calibration scaffolding.
- **Principle 11** (Companion firing-test): N/A — no new hook in this bundle.

## Out-of-scope (Deferred to Follow-up Plans)

1. Scrapling adaptive selector + SQLiteStorageSystem (A-12 § 3 C1) → Plan D-N
2. Scrapling `find_similar` sibling-element finder → Plan D-N
3. NDH / VietstockFinance / VietnamBiz adapter migrations → per-source FOCUSED_IMPL sessions
4. CrawlerAdapter contract in ubiquitous-language glossary → suggested follow-up
5. Shape-metrics emit persistence (calibration `.tsv`) → Phase 3
6. R2 (Cloudflare) raw-HTML storage → Phase 3
7. Banned-pattern hook for CrawlerAdapter contract → follow-up plan if/when warranted
8. `extract_claims` on CrawlerAdapter → Theme I (Phase E)
9. Async migration → Phase 3 (concurrent multi-source ingestion)
10. CrawlerHub filesystem auto-discovery → REJECTED (global-state anti-pattern per DD-5)
11. CafeFScraper + CafeFAdapter consolidation → Phase D-N (RM12)
12. SelectorChain wiring into CafeFAdapter → deferred to Phase D-N consolidation (RM12). Strategy B (WRAP) preserves CafeFScraper's BeautifulSoup parse path untouched; SelectorChain ships as foundation primitive for NDH/Vietstock/VietnamBiz follow-on adapters + the eventual CafeFScraper consolidation. Per S339 F2 finding (sandwich-verifier 2026-05-16).

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| I-S34 banned import creeps in | Low | plan-020 grep check before commit; verifier S339 V5 checks |
| CafeFScraper dual-class maintenance | Med | RM12 carry-forward note; consolidation is follow-up Phase D-N |
| async-leak temptation | Low | Plan DD-2 + this ADR + mypy sync-caller type check |
| protego version incompatibility | Low | Pin `>=0.3.1`; stdlib `urllib.robotparser` fallback documented |

## Acceptance Record

- **2026-05-16**: PROPOSED by Claude Sonnet 4.6 (sandwich-dev S338) executing plan-020 from
  architect S337 (background subagent `aeb7f20e57d53b29c`)
- **Pending**: ACCEPTED by verifier S339 (AP-1 fresh-context sandwich-verifier)
