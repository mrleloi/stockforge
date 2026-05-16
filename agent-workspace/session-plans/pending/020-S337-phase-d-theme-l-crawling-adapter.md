---
plan_id: 020-S337-phase-d-theme-l-crawling-adapter
target_session: S338
type: MULTI_TASK_IMPL
budget: 100-150K (proposed)
phase: D (Theme L — Crawling adapter shape; Phase D's first IMPL sandwich cycle)
track: Wave 1 Theme L (BC-5 News Stream crawler adapter foundation + first concrete CafeF migration)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.7 + § 6.4.1
parent_synthesis: agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § L (L.3 hybrid winner + L.4 IMPL slot + L.5 charter-compliance flags)
predecessor: 019-S335-phase-c-theme-g-i-s1-1-amendment (Phase C closed S335-S336; Rule 16 ACCEPTED 2026-05-16 via D-065; constitution write to financial-data-protocol.md landed; binding for THIS plan via § Schema discipline below)
successor: TBD-S339 sandwich-verifier (AP-1 fresh-context); then Phase E Theme I per master plan § 6.4.2 (depends on Phase D crawler output)
architect: S337 sandwich-architect (background; this plan)
dispatched_by: S328-main (parent orchestrating Phase D PLAN-IMPL-VERIFY sandwich)
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S338; fresh-context; AP-1 verifier in S339)
status: pending-execution

depends_on:
  - "D-061 (Wave-1 integration ratification — ACCEPTED 2026-05-15T15:30+07:00 blanket-A; § Decision item 3 enforces 'Theme L hybrid winner = crawl4ai (Apache-2.0 + NOTICE; ~800 LOC) + Scrapling-core (BSD-3; ~600 LOC)'; § Decision item 4 enforces 'Scrapling Cloudflare-solver HARD REJECT + patchright DO NOT IMPORT + StealthyFetcher excluded as a class')"
  - "D-065 (Theme G I-S1-1 ratification — ACCEPTED 2026-05-16; financial-data-protocol.md Rule 16 binding; any crawler-emitted numeric field this plan introduces or migrates MUST satisfy Rule 16 mode #1/#2/#3/#4)"
  - "D-059 (Python determinism contract — ACCEPTED; R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain are BINDING for every new file authored under this plan)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for S338 dev commit boundary)"
  - "D-062 (atomic-write-doctrine — BINDING for any new raw-HTML/cache/state writes introduced here)"
  - "D-064 (path-safety 5-invariant contract — BINDING for new file-path code; uses helpers from packages/_shared/path_safety.py per W0-5)"
  - "Charter v1.1 Principle 4 (Proprietary data moat — every news ingested compounds the edge; adapter MUST be self-use ready in Phase 1) + Principle 7 (Dogfood mandatory) + Principle 8 (Calibration over confidence — extends to shape-metrics emit per crawler-reliability skill) + Principle 11 (Harness must self-verify firing)"
  - "I-S1 (NO LLM math) + I-S1-1/Rule 16 (numeric-field discipline) + I-S2 (citation discipline — source_url + as_of + extracted_at) + I-S22 (data lineage — every output references the script + version that produced it) + I-S34 (public sources only + ToS compliance — Scrapling Cloudflare-solver HARD REJECT) + I-S35 (research-aid framing)"
  - "Rule 6 (LLM Output Provenance — already enforced via ExtractorMetadata; adapter output ↦ ExtractedClaim path preserves) + Rule 7 (sentiment categorical) + Rule 8 (anti-look-ahead in news — published_at + ingested_at + scored_at carried through)"
  - "observations/master-planner-A-02-deepdive-crawl4ai.md (PRIMARY adopt — § 2 patterns 1-5 + § 3 C1/C2/C4/C5/C7/C8 candidate components + § 6 license attribution requirements + § 7 risk flags)"
  - "observations/master-planner-A-12-deepdive-Scrapling.md (SECONDARY hybrid — § 2 patterns 1+2+4+5 + § 3 C1/C2/C4/C5 components + § 7 #1 Cloudflare-solver HARD REJECT + § 'Comparison-Probe' hybrid argument)"
  - "observations/master-planner-A-05-deepdive-MediaCrawler.md (PATTERN-REFERENCE ONLY — § 5 license blocks LOC port; § 7 #3 CDP-connect-existing-Chrome consent-mode permitted as future Facebook-fanpage path; this plan ships ZERO MediaCrawler-derived LOC)"
  - ".claude/skills/crawler-reliability/SKILL.md (operational doctrine — Selector Robustness fallback chain + Retry & Backoff tenacity recipe + Rate Limiting per-domain semaphore + Monitoring shape metrics emit + Caching TTL table + Storage R2 layout + Anti-Patterns list)"
  - "agent-workspace/session-plans/completed/018-S331-wave-0-W0-3-4-5-bundle.md (TEMPLATE — frontmatter + STEP 0 pre-flight + sub-track DoD + Bundle DoD aggregate + Coordination rules + Risk + Mitigation + Verifier checklist + Out-of-scope; this plan mirrors that shape)"
  - "agent-workspace/memory/decisions/059-python-determinism-contract.md (TEMPLATE — ADR 12-field schema + WARN→BLOCKING ratchet + Charter alignment language; this plan's D-066 mirrors)"
  - "packages/infrastructure/news/cafef_scraper.py (MIGRATION TARGET — current shape: 213 LOC; httpx-fetcher callable + BeautifulSoup parse + rate-limited fetch + ScrapedArticle→NewsArticle promotion; this plan WRAPS not REWRITES, preserving fixture-driven test surface)"
  - "apps/cli/ingest_news_cafef.py (MIGRATION SITE — current shape: 318 LOC; click CLI orchestrating CafeFScraper + SqliteNewsRepository + SqliteClaimRepository + ClaimExtractionService; this plan adds adapter-shape dispatch WITHOUT breaking the CLI contract — preserve all flags + exit codes)"
  - "packages/domain/news/__init__.py + packages/domain/news/models/news_article.py + packages/domain/news/services/claim_extraction_service.py (BC-5 domain layer — already exists; this plan does NOT introduce new domain entities, only application-layer port + infrastructure-layer adapter implementations)"
  - "packages/contracts/events/news_article_ingested.py (event contract — already exists, frozen-slots dataclass with article_id + source + source_url + published_at + ingested_at + mentioned_tickers + emitted_at; this plan's adapter output feeds this event UNCHANGED)"
  - "packages/_shared/path_safety.py (W0-5 helpers — ANY new raw-HTML write or cache-file path uses safe_run_dir / safe_path helpers from this module; binding per D-064)"

binding_decisions:
  - "D-061 § Decision item 3 (Theme L hybrid winner) + § Decision item 4 (Scrapling Cloudflare-solver HARD REJECT)"
  - "D-065 Rule 16 (numeric-field discipline) — crawler-emitted fields MUST satisfy mode #1/#2/#3/#4"
  - "Charter Principle 11 (companion firing-test mandate IF a hook is shipped — see § Out-of-scope for why this plan does NOT ship a hook)"
  - "I-S1 + I-S2 + I-S22 + I-S34 + I-S35 (all binding; cited per sub-track DoD)"
  - "Rule 6 + Rule 8 + Rule 16 (financial-data-protocol; this plan's adapter output preserves Rule 6 provenance and Rule 8 anti-look-ahead; Rule 16 satisfied by NOT introducing new LLM-numeric paths in this bundle — see § Schema discipline)"
  - "D-060 — agent MAY git commit (NOT push); S338 dev decides commit boundary per § Coordination"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL)"
  - "no commits in THIS plan-session (sandwich-architect subagent instructions; no Bash tool granted)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no touching apps/cli/ingest_news_*.py — those are S338 dev's migration targets, not architect's"
  - "no master-plan edits — D-061 already ratifies Theme L hybrid winner; this plan executes within"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "Scrapling Cloudflare-solver + patchright + StealthyFetcher: HARD REJECT — do NOT appear anywhere in the adapter design even as fallback (per D-061 + A-12 § 7 #1 + I-S34)"
  - "MediaCrawler: ZERO LITERAL LOC — pattern-reference only; CDP-consented-mode is FUTURE scope (Facebook fanpages, not this bundle)"
---

# S338 — Phase D Theme L Crawling Adapter Shape (BC-5 foundation + CafeF migration)

## Goal

Ship the abstract **CrawlerAdapter port** for stockforge BC-5 News Stream, the first concrete
**Crawl4aiBaseAdapter** (PATTERN-ADOPT from `crawl4ai` `BaseCrawler` + `CrawlerHub` shape;
~150-200 LOC; Apache-2.0 + NOTICE attribution), and migrate the existing
`packages/infrastructure/news/cafef_scraper.py` (S36 Track D legacy; 213 LOC; preserved as
adapter implementation) onto the new port. The migration MUST preserve the
`apps/cli/ingest_news_cafef.py` CLI contract (all flags + exit codes + summary output
unchanged at the user-visible surface).

Foundation primitives in `apps/_shared/crawl/`: `RateLimiter` (~60 LOC port from crawl4ai
`async_dispatcher.py:28-85` with attribution) + `RobotsTxtManager` (~70 LOC port from
Scrapling `spiders/robotstxt.py:10-60` with attribution) + minimal selector-fallback helper
(`SelectorChain`, ~40 LOC fresh — applies crawler-reliability skill § Selector Robustness
fallback chain without porting Scrapling's adaptive `relocate` SQLite storage in this
session — that's deferred to a follow-up D-N session per § Out-of-scope).

The bundle ships: 3 modules + tests + 1 NOTICE file (repo root; Apache-2.0 attribution per
crawl4ai LICENSE:54-67) + 1 ADR D-066 (PROPOSED at IMPL tier; ≥7 source_evidence cites) +
session log + observation. **NO hook is shipped this bundle** (rationale: this is product
substrate, not banned-pattern enforcement; if a static-analysis rule emerges, it's a
follow-up plan per § Out-of-scope item 7).

**Out-of-scope cleanup** of NDH/VietnamBiz/VHM crawlers + the deferred Scrapling adaptive
selector + the Facebook-fanpage CDP path are explicitly deferred per § Out-of-scope.

## Context — why this shape, not the alternatives

Three honest design decisions, each with an adversarial alternate kept on shelf:

1. **One concrete source (CafeF), not four.** Master plan § 5.7 lists 4 priority VN sources
   (CafeF, NDH, VietstockFinance, VietnamBiz). The bundle ships only the CafeF migration
   because (a) it's the only source with shipping code (`cafef_scraper.py` + recorded HTML
   test fixtures via `_httpx_fetcher` callable injection), (b) RM4 budget envelope risk —
   migrating 4 sources in one session is the failure pattern that destroyed S4 per
   CLAUDE.md "Never mix PLAN and IMPL in same session" precedent (also see W0-2 → W0-2.1
   split-when-touching-production-code precedent at plan 014 line 92), (c) the adapter
   *port + first implementation* validates the shape; subsequent sources (NDH/Vietstock/
   VietnamBiz) become per-source FOCUSED_IMPL sessions in Phase D-N. Adversarial alternate:
   ship all 4 in one session; rejected because per-source HTML-shape discovery (recorded
   sample HTML + selector identification) is itself a 2-4K-token line item per source and
   would push the bundle past 200K (R-2 splits-if->10-tasks trigger).

2. **PATTERN-ADOPT crawl4ai `BaseCrawler`/`CrawlerHub` shape, NOT pip-install crawl4ai.**
   Per A-02 § 5 + § 7 (3K-line `utils.py` god-module risk + `unclecode-litellm` fork
   bus-factor + LLM-extraction strategies sit in same package as deterministic strategies
   risk + `fake-useragent`/`playwright-stealth` ToS-grey defaults). The port is ~150-200
   LOC of the architectural shape (ABC + instance-scoped registry; refactored per A-02 § 7
   "Hub auto-discovery is global mutable state" anti-pattern fix). Adversarial alternate:
   pip-install crawl4ai; rejected because it pulls 12-13 heavy deps (per `pyproject.toml:15-50`
   inventory in A-02 § 1) for what we need ~600 LOC of pattern. ALSO REJECTED: blocks
   I-S34 compliance — `playwright-stealth` is a transitive default we'd have to explicitly
   disable.

3. **ABC (abstract base class), NOT Protocol.** The stockforge convention per
   `packages/application/news/ports/llm_extractor_port.py` is `Protocol` for ports; BUT
   crawl4ai uses `BaseCrawler(ABC)` with `__init_subclass__` typecheck (`hub.py:24-35`) to
   enforce async-`run` signature at subclass definition time. The architect picks ABC
   because (a) the source pattern is ABC, deviation introduces translation friction at
   port-time, (b) `__init_subclass__` typecheck is a runtime-enforced contract that
   Protocol cannot replicate (Protocol = static duck-typing; doesn't validate at subclass
   time). Adversarial alternate: use Protocol for surface consistency with
   `LlmExtractorProtocol`; rejected because of the `__init_subclass__` lever. Mitigation
   for the inconsistency: ADR D-066 § "Why ABC not Protocol" section documents the
   exception explicitly so the convention surface remains explainable.

**Async vs sync model**: SYNC for this bundle. crawl4ai is async-first
(`AsyncWebCrawler`) but the existing `CafeFScraper` is sync (line 70 `sleeper:
Callable[[float], None] = time.sleep`) and the entire BC-5 pipeline downstream is sync
(`ClaudeLlmExtractor`, `SqliteNewsRepository`, etc.). Introducing async into ONE adapter
breaks the per-source loop pattern at `apps/cli/ingest_news_cafef.py:217-224` (synchronous
`for url in all_urls: scraped = scraper.fetch_article(url)`). Adversarial alternate: ship
the adapter async-first; rejected — async migration is a separate concern (charter
Phase 3+ when concurrent multi-source ingestion lands), and mixing async+sync in a single
bundle is the textbook async-leak anti-pattern. Document the deferral in ADR D-066
§ "Async deferred to Phase 3" subsection.

**HTTP-only vs browser-driven**: HTTP-only for this bundle. Per A-02 § 5 (browser layer is
out-of-scope for our single-tenant scale) + I-S34 ToS-compliance (the default httpx fetcher
identifies as `stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)`,
verified at `cafef_scraper.py:36-37`). Browser-driven Playwright is a future plan when
JS-heavy sources (Facebook fanpages, YouTube transcript page if not yt-dlp) become
required. CDP-consented-mode (per A-05 § 7 #3) is the future Facebook path; NOT this
bundle.

**Output schema**: NO NEW SCHEMA fields introduced. The adapter's `fetch_and_parse`
returns the existing `ScrapedArticle` dataclass + `to_news_article` promotion to
`NewsArticle` (current `cafef_scraper.py:135-160`). Rule 16 compliance is via **mode #4
(NULL/unknown surrogate)** for the only candidate numeric field — `confidence_extracted`
on `ExtractorMetadata` (already exists at
`packages/domain/news/value_objects/extractor_metadata.py:43`; populated by the LLM
extractor downstream, NOT by the crawler). The crawler emits ZERO numeric fields; thus
Rule 16 surface is preserved by construction. See § Schema discipline below for the
explicit per-field audit.

---

## STEP 0 — Mandatory pre-flight (do this BEFORE writing any code)

The implementing session (S338) MUST run these first and write results into the session
log. This plan was authored by a sandwich-architect subagent with Read/Glob/Grep/Write but
NO Bash — STEP 0 is the empirical anchor that grounds plan recipes against live filesystem.

**STOP-IF-AMBIGUOUS clause**: if any STEP 0 expected count/file/pattern differs from the
inventory below, STOP and escalate via observation file + `human-workspace/notifications/
phase-d-theme-l-step0-ALERT.md`. Do NOT write any module in a divergent state.

1. **Verify Phase B closure state + Phase C closure state**:
   ```bash
   grep -n "WAVE 0 SUBSTRATE: FULLY SEALED" agent-workspace/memory/current-execution.md
   grep -n "D-065" agent-workspace/memory/current-execution.md
   ls agent-workspace/memory/decisions/065-theme-g-i-s1-1-ratification.md
   grep -n "Rule 16" agent-workspace/constitution/financial-data-protocol.md | head -5
   ```
   Expected: WAVE 0 marker present; D-065 referenced; Rule 16 visible in
   financial-data-protocol.md (line ~358+ per plan-authoring read). If any differ → STOP.

2. **Verify upstream repo presence + license headers** (the 2 contributing repos):
   ```bash
   ls C:/htdocs/research/crawl4ai/LICENSE
   head -67 C:/htdocs/research/crawl4ai/LICENSE   # expected: Apache-2.0 + custom Attribution Requirement at :54-67
   ls C:/htdocs/research/crawl4ai/crawl4ai/hub.py
   sed -n '24,69p' C:/htdocs/research/crawl4ai/crawl4ai/hub.py   # BaseCrawler __init_subclass__ + CrawlerHub registry
   ls C:/htdocs/research/crawl4ai/crawl4ai/async_dispatcher.py
   sed -n '28,85p' C:/htdocs/research/crawl4ai/crawl4ai/async_dispatcher.py   # RateLimiter source
   ls C:/htdocs/research/Scrapling/LICENSE
   head -28 C:/htdocs/research/Scrapling/LICENSE   # expected: BSD 3-Clause License + copyright 2026 Karim Shoair
   ls C:/htdocs/research/Scrapling/scrapling/spiders/robotstxt.py
   sed -n '10,60p' C:/htdocs/research/Scrapling/scrapling/spiders/robotstxt.py   # RobotsTxtManager
   ```
   If repos absent or licenses changed → STOP. (License compatibility per D-061 § Decision
   item 1: Apache + BSD → LOC port permitted with attribution per-file header + NOTICE root.)

3. **Verify the source-evidence file:line citations** still match the deep-dives:
   ```bash
   # crawl4ai - BaseCrawler/CrawlerHub pattern (A-02 § 3 C8 + § 2 pattern 6)
   grep -n "BaseCrawler" C:/htdocs/research/crawl4ai/crawl4ai/hub.py
   grep -n "_crawlers" C:/htdocs/research/crawl4ai/crawl4ai/hub.py
   # crawl4ai - RateLimiter (A-02 § 3 C2)
   grep -n "class RateLimiter" C:/htdocs/research/crawl4ai/crawl4ai/async_dispatcher.py
   grep -n "DomainState" C:/htdocs/research/crawl4ai/crawl4ai/async_dispatcher.py | head -5
   # Scrapling - RobotsTxtManager (A-12 § 3 C5)
   grep -n "class RobotsTxtManager\|protego\|crawl_delay" C:/htdocs/research/Scrapling/scrapling/spiders/robotstxt.py
   ```
   Expected output matches the quoted text in
   `master-planner-A-02-deepdive-crawl4ai.md § 2/§ 3` and
   `master-planner-A-12-deepdive-Scrapling.md § 3 C5`. If patterns shifted (upstream
   commits since 2026-05-15) → STOP and update plan recipes before proceeding.

4. **Verify the migration target's current shape** (live state before authoring port):
   ```bash
   wc -l packages/infrastructure/news/cafef_scraper.py   # expected ~213
   wc -l apps/cli/ingest_news_cafef.py   # expected ~318
   grep -n "class CafeFScraper\|def fetch_article\|def discover\|def to_news_article" \
     packages/infrastructure/news/cafef_scraper.py
   grep -n "scraper.discover\|scraper.fetch_article\|scraper.to_news_article" \
     apps/cli/ingest_news_cafef.py
   ```
   Expected: `CafeFScraper.discover`, `fetch_article`, `to_news_article` methods present;
   CLI calls them at `apps/cli/ingest_news_cafef.py:205, 218, 223`. If method signatures
   shifted → STOP and adjust port recipe.

5. **Verify Rule 16 (I-S1-1) compliance surface for the crawler path**:
   ```bash
   grep -rn "float\|int\|Decimal" packages/contracts/events/news_article_ingested.py
   grep -rn "float\|int\|Decimal" packages/domain/news/models/news_article.py
   grep -rn "float\|int" packages/domain/news/value_objects/extractor_metadata.py
   ```
   Expected: `NewsArticleIngested` event = ZERO numeric fields (only str/datetime/tuple);
   `NewsArticle` entity = ZERO numeric fields (only str/datetime/tuple); `ExtractorMetadata.
   confidence_extracted: float` is the one numeric field. Rule 16 satisfaction mode for
   `confidence_extracted`: ALREADY mode #3 (calibration-database lookup target — keyed on
   extractor_version + signal_type) per Rule 16 § "Fields explicitly subject to this rule"
   first bullet; wired downstream by LLM extractor, NOT by crawler. Crawler surface = ZERO
   new numeric fields → Rule 16 satisfied by construction. Record the per-field audit in
   session log.

6. **Verify next-ADR number is still D-066** (no concurrent ADR writes since plan-authoring):
   ```bash
   ls agent-workspace/memory/decisions/ | grep -E '^[0-9]{3}-' | sort | tail -3
   ```
   Expected: latest landed = `065-theme-g-i-s1-1-ratification.md`. If `066-*` already
   exists → main session created an ADR in between; renumber this bundle's ADR to next
   available (likely 067).

7. **Verify license file absence** (NOTICE file is new — must be at repo root after this
   bundle):
   ```bash
   ls NOTICE 2>/dev/null   # expected: NOT present (will be created by S338 dev)
   ls LICENSE 2>/dev/null  # if present, read to understand stockforge's own license posture
   ```
   If NOTICE already exists with content → STOP; reconcile with the new attribution
   block proposed in § Sub-track D4 below.

8. **Read upstream source files completely** (Read tool, full file) before authoring port:
   - `C:/htdocs/research/crawl4ai/crawl4ai/hub.py` (~70 LOC; complete read)
   - `C:/htdocs/research/crawl4ai/crawl4ai/async_dispatcher.py` (~470 LOC; focus
     lines 28-85 RateLimiter + 1-30 imports)
   - `C:/htdocs/research/Scrapling/scrapling/spiders/robotstxt.py` (~80 LOC; complete read)
   - `C:/htdocs/research/crawl4ai/LICENSE` (full 67 lines; verify Apache-2.0 +
     Attribution-Requirement clause exact text for NOTICE file)
   - `C:/htdocs/research/Scrapling/LICENSE` (full 28 lines; verify BSD-3-Clause exact
     copyright string for per-file header)
   Per VBW protocol: verify actual current state of upstream, not plan's stale snapshot.

9. **Baseline regression floors** — establish before-state:
   ```bash
   bash scripts/hooks/firing-tests/run-all.sh 2>&1 | tail -5
   bash scripts/hooks/bash-hook-lint.sh 2>&1 | tail -5
   python -m pytest packages/ apps/ -q 2>&1 | tail -3
   python -m mypy --strict packages/ apps/ 2>&1 | tail -5
   python -m ruff check packages/ apps/ 2>&1 | tail -5
   ```
   Write pre-IMPL pass/fail counts into session log. New modules + tests MUST add to
   (not regress) these baselines. Hooks already shipping (W0-2 through W0-5) cover the
   new modules automatically — STEP 0.9 records the baseline; DC-AGG checks the delta.

10. **Smoke-test the existing CLI end-to-end with fixture HTML** (no live cafef.vn hits):
    ```bash
    # If a recorded-HTML fixture exists per the L-S28-1 vendor-drift doctrine
    # (per cafef_scraper.py docstring "tests inject recorded HTML via the `fetcher`
    # callable so CI never hits cafef.vn"):
    python -m pytest packages/infrastructure/news/test_adapters.py -q 2>&1 | tail -5
    # Expected: tests pass; recorded HTML in test fixture; CafeFScraper behavior baseline.
    ```
    Capture pre-migration test count + pass count. After migration, post-IMPL test count
    MUST be ≥ pre-count + (new tests added) AND pre-existing tests MUST still pass with
    ZERO behavioral drift at the CafeFScraper surface.

---

## Design decisions (architect's analysis — read before authoring code)

### DD-1: CrawlerAdapter port location — application layer

**Decision**: port (ABC) lives at `packages/application/news/ports/crawler_adapter.py`
(NEW). Concrete adapters live at `packages/infrastructure/news/crawler_adapters/<name>_
adapter.py`.

**Rationale**: The application-layer port pattern is established at
`packages/application/news/ports/llm_extractor_port.py` (LlmExtractorProtocol). Stockforge
convention per `agent-workspace/constitution/architecture.md` § BC-5: domain layer is pure
(no I/O); application layer declares ports; infrastructure layer implements them. The
adapter is HTTP I/O therefore infrastructure; the contract is application.

**Adversarial alternate considered**: Put the port in `packages/domain/news/ports/`.
Rejected — domain has ZERO framework dependency (CLAUDE.md hard rule); even a
Path/datetime return type pulls types that crawl downstream would prefer concrete.
Application layer is the contract surface for cross-layer I/O.

### DD-2: Async vs sync — SYNC (deferred async to Phase 3)

**Decision**: sync interface. ABC method signature is `def fetch_and_parse(self, url: str)
-> ScrapedArticle | None` (sync — mirrors existing `cafef_scraper.py:101` shape exactly).

**Rationale**: per § Context decision 3 above. Async migration is a Phase 3 concern; mixing
in one bundle breaks the existing CLI sync loop.

**Adversarial alternate**: `async def fetch_and_parse(...)`. Rejected because the entire
downstream BC-5 chain (`SqliteNewsRepository.save_many`, `ClaimExtractionService.process`,
`apps/cli/ingest_news_cafef.py:217-224`) is sync; adding async to ONE adapter requires
either (a) `asyncio.run()` at every CLI call site (anti-pattern) or (b) full chain
migration (out-of-scope).

### DD-3: ABC vs Protocol — ABC

**Decision**: `class CrawlerAdapter(ABC)` with abstract methods + `__init_subclass__`
runtime contract check.

**Rationale**: per § Context decision 4 above. ABC matches the source pattern (crawl4ai
`BaseCrawler` at `hub.py:24-35`) and provides runtime enforcement that Protocol cannot.

**Adversarial alternate**: `class CrawlerAdapter(Protocol)`. Rejected because Protocol is
static-only; subclass contract violation manifests only when first instance is constructed
or when type-checker runs — not at definition time. ABC + `__init_subclass__` fails fast.

### DD-4: Source-specific subclasses vs configuration-driven

**Decision**: Source-specific subclasses (1 class per source). `CafeFAdapter` subclasses
`CrawlerAdapter`; future `NDHAdapter`, `VietstockFinanceAdapter`, `VietnamBizAdapter` each
subclass independently.

**Rationale**: VN news sites have profoundly different HTML structures (CafeF uses
`.detail-content` / `.contentdetail` containers per `cafef_scraper.py:117-118`; NDH has its
own conventions; VietstockFinance same). A config-driven adapter ("here's the selectors as
JSON") would need an Eval/Selector DSL or string-evaluated CSS expressions — both increase
test surface + couple sources to a config schema. One-class-per-source preserves
DDD-style ACL anti-corruption layer per source (per A-02 § 3 C8 rationale).

**Adversarial alternate**: A `ConfigurableAdapter(CrawlerAdapter)` with a JSON-loaded
selector chain. Rejected because (a) selector-as-string is an injection surface (mitigation
adds complexity), (b) source-specific edge cases (CafeF's published_at parser at
`cafef_scraper.py:178-208` covering 3 date formats; CafeF's `.chn` URL discovery convention
at `cafef_scraper.py:90`) need Python expressivity, not config. Defer config-driven to
Phase 4+ if/when 10+ sources demand it.

### DD-5: CrawlerHub registry pattern — instance-scoped, NOT global

**Decision**: `CrawlerRegistry` is an instance class (one per CLI run), NOT global. Pass
the registry into the use case explicitly.

**Rationale**: A-02 § 7 anti-pattern flag: "Hub auto-discovery is global mutable state...
in tests, this leaks between cases." The crawl4ai `CrawlerHub._crawlers: Dict` at
`hub.py:38` is class-level — this leak risk crosses test boundaries. Refactor to
instance-scoped on port.

**Adversarial alternate**: Module-level singleton with explicit `register()` call (no
auto-discovery). Acceptable middle ground; rejected only because instance-scoped
generalises better — tests can construct fresh registries per case without monkey-patching
module state.

### DD-6: Storage layer — raw HTML to `data/raw/news/<source>/<date>/<url-hash>.html` +
parsed `NewsArticle` to existing `SqliteNewsRepository`

**Decision**: introduce optional raw-HTML preservation hook on `CrawlerAdapter` (a
`raw_html_sink: RawHtmlSink | None = None` constructor arg; if set, adapter saves verbatim
HTML at `data/raw/news/<source>/<YYYY-MM-DD>/<sha256(url)[:16]>.html` via
`safe_run_dir()` from `packages/_shared/path_safety.py` per W0-5 D-064 binding). Parsed
output continues through the existing `SqliteNewsRepository` path unchanged.

**Rationale**: per crawler-reliability skill § Storage: "Raw HTML → Cloudflare R2 at
`raw-crawl/<domain>/<date>/<sha256(url)>.html` with metadata: `url`, `fetched_at`,
`status_code`. Parsed structure → Postgres. Raw preserved for reprocessing when extraction
logic improves." Phase 2 thin slice: local filesystem path under `data/raw/news/` instead
of R2 (matches existing `data/vn30-news.sqlite` convention at `apps/cli/ingest_news_cafef.
py:95`); R2 wiring is Phase 3.

**Atomic write**: every raw-HTML write uses `tmp + os.replace()` per D-062 binding (per
S338 dev: use `Path(tmp_path).write_text(html, encoding="utf-8");
Path(tmp_path).replace(final_path)` per the atomic-write doctrine).

**Adversarial alternate**: skip raw-HTML preservation entirely. Rejected because the
crawler-reliability skill explicitly mandates it for reprocessing — without it, every
improvement to selector/parser logic requires re-fetching (rate-limited + ToS-concerning).
Preservation is cheap (KB per article) and unlocks re-extraction at zero ToS cost.

### DD-7: Retry / backoff / rate-limit / selector — adopt from crawl4ai + Scrapling per skill

**Retry**: tenacity per skill § Retry & Backoff. Recipe: `stop_after_attempt(5)` +
`wait_exponential(multiplier=1, min=1, max=30)` + `retry_if_exception_type((httpx.
HTTPError, httpx.TimeoutException))`. 429 is retryable; 4xx others are not. Total retry
budget cap = 5 attempts per URL. Applied at the HTTP fetcher boundary, NOT at the
adapter-method level (preserves the existing `fetcher: Callable[[str], str]` injection
shape at `cafef_scraper.py:64`).

**Rate-limit**: `apps/_shared/crawl/rate_limiter.py` (NEW; ported from crawl4ai
`async_dispatcher.py:28-85` with attribution; ~60 LOC; sync version of the per-domain
`DomainState` + exponential backoff + jitter). The existing `cafef_scraper.py:33`
`_RATE_LIMIT_SECONDS = 2.0` becomes the `DomainState.base_delay` for cafef.vn.

**Selector robustness**: `apps/_shared/crawl/selector_chain.py` (NEW; ~40 LOC fresh; applies
skill § Selector Robustness fallback chain — try multiple strategies, return first
non-empty, log warning if all fail, return None). The existing `cafef_scraper.py:117-120`
already implements this pattern manually (`soup.find("div", class_="detail-content") or
soup.find("div", class_="contentdetail") or soup.find("article")`); the helper formalises
+ instruments the pattern. Migration: refactor `CafeFAdapter._extract_body_container` to
use `SelectorChain([(...), (...), (...)])`.

**Adaptive selector**: DEFERRED. Scrapling's `Selector` + `relocate` + `SQLiteStorageSystem`
(per A-12 § 3 C1; ~250 LOC) is the "selectors that survive site redesign" feature. NOT
in this bundle because (a) it requires a healthy first-run baseline to relocate against
(per A-12 § 7 #2 "fallback recovery, NOT prevention"), (b) ~250 LOC + SQLite storage adds
substantial complexity, (c) crawler-reliability skill § Selector Robustness recommends
the fallback-chain pattern (DD-7 above) as the primary defense — adaptive is the
secondary layer. Deferred to follow-up plan D-N per § Out-of-scope item 1.

### DD-8: License attribution — NOTICE root + per-file headers

**Decision**: create `NOTICE` file at stockforge repo root (NEW); add per-file attribution
header on every file that ports or pattern-adopts from crawl4ai or Scrapling.

**Rationale**: per A-02 § 6 (Apache-2.0 + custom Attribution Requirement clause at crawl4ai
LICENSE:54-67 — "must be displayed in a prominent and easily accessible location"); per
A-12 § 6 (BSD-3-Clause requires retain copyright notice in source). Stockforge stays
private (3-5 peers) but attribution applies even to internal redistribution. Cheapest
compliant path: NOTICE file + per-file header.

**Exact per-file header templates**:
- For crawl4ai-derived files:
  ```python
  # Portions adapted from Crawl4AI (https://github.com/unclecode/crawl4ai),
  # Apache-2.0 + Attribution Requirement; see NOTICE at repo root for full text.
  ```
- For Scrapling-derived files:
  ```python
  # Portions adapted from Scrapling (https://github.com/D4Vinci/Scrapling),
  # BSD-3-Clause by Karim Shoair; see NOTICE at repo root for full text.
  ```

**Out-of-scope LOC**: any file that's pure stockforge fresh code (e.g., the
`CrawlerAdapter` ABC itself, with only the *concept* of `BaseCrawler` adopted) does NOT
need a header — the *port* needs the header. Architect verdict: header where there's
≥1 line of LOC-or-near-LOC port; no header for pure-pattern/concept adoption. ADR D-066
documents the boundary.

---

## Schema discipline — Rule 16 (I-S1-1) compliance audit

Per D-065 binding (just-landed Phase C), every numeric field in any new/modified schema
in this bundle MUST satisfy one of Rule 16's four satisfaction modes. The audit:

| Field | Type | Where | Mode | Justification |
|---|---|---|---|---|
| (none introduced by this plan) | — | — | — | This bundle adds adapter port + concrete CafeFAdapter + foundation primitives — ZERO new schema fields. All output flows through existing `ScrapedArticle` → `NewsArticle` → `NewsArticleIngested` event; current numeric inventory unchanged. |
| `ExtractorMetadata.confidence_extracted: float` | float | `packages/domain/news/value_objects/extractor_metadata.py:43` (EXISTING; NOT modified) | **#3 calibration lookup target** | Already cited in Rule 16 § "Fields explicitly subject to this rule" first bullet as target for mode #3 wiring; the wiring itself is BC-6 KOL extractor work per Rule 16 first bullet rationale, NOT this plan's scope. This crawler does NOT emit `confidence_extracted` — the LLM extractor downstream does (existing path: `apps/cli/ingest_news_cafef.py:155-159` constructs `ClaudeLlmExtractor()` → `ClaimExtractionService.process` → which populates metadata). The crawler surface remains numeric-free. |
| `apps/_shared/crawl/rate_limiter.py` `DomainState.current_delay: float` | float | NEW infrastructure module | N/A — not LLM-call-site | Internal timing state computed by deterministic code (exponential backoff + jitter formula from crawl4ai `async_dispatcher.py:28-85`); never LLM-emit; never schema field on a domain/event. Rule 16 scope per its own enforcement subsection: "schemas that participate in an LLM call site". Pure infra timing state is out-of-scope. Document in ADR D-066 § "Rule 16 audit" for completeness. |
| `SelectorChain` ranking / count fields | int | NEW infrastructure module | N/A — not LLM-call-site | Deterministic selector-match-count; never LLM-emit. Same out-of-scope rationale as above. |

**Per Rule 16 § "At amendment time"**: when this bundle's IMPL session adds a new
dataclass / TypedDict field whose type is numeric, the change-author MUST specify which
of 4 satisfaction modes applies, recorded in the field docstring. This audit empirically
confirms ZERO such fields are added; STEP 0.5 re-confirms at IMPL time. Any deviation =
STOP-AND-ESCALATE per § STEP 0 STOP-IF-AMBIGUOUS.

---

## Sub-track D1 — CrawlerAdapter ABC port + CrawlerRegistry foundation

### Pattern statement

**Pattern adopted**: crawl4ai `BaseCrawler(ABC)` + `CrawlerHub` registry (per
`C:/htdocs/research/crawl4ai/crawl4ai/hub.py:24-69`). Refactored to instance-scoped
registry per A-02 § 7 anti-pattern fix.

**Method shape**:
```python
class CrawlerAdapter(ABC):
    """Port for per-source crawlers in BC-5 News Stream.

    Concrete adapters live in packages/infrastructure/news/crawler_adapters/.
    The CLI dispatches via CrawlerRegistry.get(source_id).
    """

    source_id: ClassVar[str]   # e.g. "cafef" — enforced non-empty via __init_subclass__

    @abstractmethod
    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from a listing page (sync; rate-limited internally)."""

    @abstractmethod
    def fetch_and_parse(self, url: str) -> ScrapedArticle | None:
        """Fetch + parse a single article. Returns None on graceful failure
        (vendor drift L-S28-1 doctrine). On structural failure, raises.
        """

    @abstractmethod
    def to_news_article(
        self,
        scraped: ScrapedArticle,
        ticker_universe: Iterable[Ticker],
    ) -> NewsArticle:
        """Promote ScrapedArticle to NewsArticle (coarse-scan ticker mentions)."""

    def __init_subclass__(cls, **kwargs: object) -> None:
        """Enforce non-empty source_id at subclass definition time
        (per crawl4ai hub.py:24-35 typecheck pattern)."""
        super().__init_subclass__(**kwargs)
        if not getattr(cls, "source_id", "").strip():
            raise TypeError(
                f"{cls.__name__} must declare non-empty source_id ClassVar"
            )
```

### File location

- Port ABC: `packages/application/news/ports/crawler_adapter.py` (NEW; ~80 LOC).
- Registry: `packages/application/news/ports/crawler_registry.py` (NEW; ~60 LOC;
  instance-scoped `CrawlerRegistry` with `register(adapter)` + `get(source_id)` +
  `list_sources()`).
- Update `packages/application/news/ports/__init__.py` to export both.
- Update `packages/application/news/__init__.py` accordingly.

### Method/contract details

- `fetch_and_parse(url)` returns None on parse failure (per existing
  `cafef_scraper.py:101-104` L-S28-1 vendor-drift doctrine — degrade gracefully).
- `discover(listing_path, max_articles)` returns at most `max_articles` URLs deduplicated.
- `to_news_article(scraped, ticker_universe)` is sync, deterministic, no I/O.
- `source_id: ClassVar[str]` enforced non-empty at subclass-definition time via
  `__init_subclass__` (per DD-3).

**`extract_claims(article)` method**: DEFERRED to Theme I (Phase E per master plan § 6.4.2).
The current pipeline at `apps/cli/ingest_news_cafef.py:155-159` constructs a separate
`ClaudeLlmExtractor` + `ClaimExtractionService` for claim extraction; preserving that
separation keeps Theme I free to redesign per Theme I deep-dives. CrawlerAdapter is
intentionally narrow.

### D1 DoD criteria

- [ ] **DC-D1-1** — `packages/application/news/ports/crawler_adapter.py` exists; ABC
  defined; `__init_subclass__` enforces non-empty `source_id`; 3 abstract methods
  declared with correct sync signatures.
- [ ] **DC-D1-2** — `packages/application/news/ports/crawler_registry.py` exists;
  instance-scoped `CrawlerRegistry` with `register` + `get` + `list_sources` methods;
  `get` raises `KeyError(source_id)` on unknown; `register` raises if `source_id` already
  registered (no silent override).
- [ ] **DC-D1-3** — `packages/application/news/ports/__init__.py` exports
  `CrawlerAdapter` + `CrawlerRegistry` alongside existing `LlmExtractorProtocol`.
- [ ] **DC-D1-4** — Unit tests at `packages/application/news/ports/test_crawler_adapter.
  py` (NEW; ≥8 test cases):
  1. Abstract methods cannot be instantiated directly.
  2. Subclass missing `source_id` raises TypeError at class-creation time.
  3. Subclass with empty `source_id` raises TypeError.
  4. Subclass with valid `source_id` instantiates.
  5. Registry `register` accepts adapter, `get` returns it by `source_id`.
  6. Registry `get` unknown raises KeyError.
  7. Registry `register` duplicate `source_id` raises.
  8. Registry `list_sources` returns sorted list.
- [ ] **DC-D1-5** — `mypy --strict packages/application/news/ports/` exits 0.
- [ ] **DC-D1-6** — `ruff check packages/application/news/ports/` exits 0.
- [ ] **DC-D1-7** — Per-file header on `crawler_adapter.py` cites crawl4ai source per
  DD-8 template (only this file is a port; `crawler_registry.py` is fresh-derived per
  the instance-scoped refactor and gets no header).

---

## Sub-track D2 — Crawl4ai foundation primitives in `apps/_shared/crawl/`

### Modules to author

| Module | LOC | Source | License | Header required? |
|---|---|---|---|---|
| `apps/_shared/crawl/rate_limiter.py` | ~80 (60 ported + 20 sync adapter) | crawl4ai `async_dispatcher.py:28-85` | Apache-2.0 + Attribution | YES |
| `apps/_shared/crawl/robots_manager.py` | ~80 (70 ported + 10 sync adapter) | Scrapling `spiders/robotstxt.py:10-60` | BSD-3-Clause | YES |
| `apps/_shared/crawl/selector_chain.py` | ~40 (fresh) | crawler-reliability skill § Selector Robustness | — | NO (fresh) |
| `apps/_shared/crawl/raw_html_sink.py` | ~50 (fresh) | DD-6 + D-062 + D-064 binding | — | NO (fresh) |
| `apps/_shared/crawl/__init__.py` | ~10 | — | — | NO |

### Rate-limiter port shape

```python
# Portions adapted from Crawl4AI (https://github.com/unclecode/crawl4ai),
# Apache-2.0 + Attribution Requirement; see NOTICE at repo root for full text.

from dataclasses import dataclass, field
from time import monotonic, sleep
from random import Random

@dataclass
class DomainState:
    base_delay: float
    current_delay: float
    max_delay: float
    retries_so_far: int = 0
    last_fetched_at: float = 0.0

@dataclass
class RateLimiter:
    """Per-domain rate limiter with exponential backoff + jitter.

    Sync port of crawl4ai async_dispatcher.RateLimiter (async_dispatcher.py:28-85).
    Sync is intentional — see plan 020 DD-2 (async deferred to Phase 3).

    `random_factor` is seedable for D-059 R2 compliance (deterministic tests).
    """

    base_delay: float = 2.0
    max_delay: float = 60.0
    max_retries: int = 3
    states: dict[str, DomainState] = field(default_factory=dict)
    rng: Random = field(default_factory=lambda: Random(0))   # seeded; D-059 R2

    def wait_if_needed(self, domain: str) -> None:
        """Sleep enough to honor base_delay since last fetch on this domain."""
        ...

    def report_response(self, domain: str, status_code: int) -> bool:
        """On 429/503: double delay with jitter. On success: decay toward base.
        Returns False after max_retries (caller treats as circuit-open).
        """
        ...
```

### Robots-manager port shape

```python
# Portions adapted from Scrapling (https://github.com/D4Vinci/Scrapling),
# BSD-3-Clause by Karim Shoair; see NOTICE at repo root for full text.

from dataclasses import dataclass, field
from urllib.parse import urlsplit

@dataclass
class RobotsTxtManager:
    """Per-domain robots.txt cache + can_fetch check (synchronous).

    Uses protego under the hood (`pip install protego` — already a Scrapling
    optional dep; verify availability before adding to stockforge pyproject.toml).
    Cache is in-memory dict; rebuild on process start. Per A-12 § 3 C5 caveat:
    swap to SQLite cache for long-running daemons (Phase 3+).
    """

    fetcher: Callable[[str], str | None]   # returns robots.txt body or None on 404
    user_agent: str = "stockforge-research-bot/0.0.1"
    cache: dict[str, "Protego"] = field(default_factory=dict)

    def can_fetch(self, url: str) -> bool: ...
    def get_crawl_delay(self, url: str) -> float | None: ...
```

**Dependency note for STEP 0**: `protego` MAY not yet be in stockforge's `pyproject.toml`.
If `python -c "import protego"` fails at STEP 0, dev adds `protego` to dependencies in
ONE coherent edit (per S332 single-edit-conflict-prevention precedent at plan 018).

### SelectorChain shape (fresh)

```python
"""SelectorChain — fallback-chain helper per crawler-reliability skill.

No port — fresh implementation of the pattern documented in
.claude/skills/crawler-reliability/SKILL.md § Selector Robustness:
"try multiple strategies, return first non-empty result, log warning if all
fail and return None. Don't raise — partial output beats whole-pipeline halt."
"""

from collections.abc import Callable, Sequence
from typing import TypeVar

T = TypeVar("T")

@dataclass(frozen=True, slots=True)
class SelectorChain[T]:
    """Apply each strategy in order; return first non-None result.

    Counts strategy attempts for shape-metrics emit (D-067 candidate for
    Phase 3 calibration data, currently logged only).
    """

    strategies: Sequence[Callable[[], T | None]]
    label: str = "(unnamed)"

    def apply(self) -> tuple[T | None, int]:
        """Returns (result, num_strategies_tried). Logs warning if all fail."""
        ...
```

### RawHtmlSink shape (fresh)

```python
"""RawHtmlSink — atomic raw-HTML preservation per DD-6 + D-062 + D-064.

Saves to data/raw/news/<source>/<YYYY-MM-DD>/<sha256(url)[:16]>.html via
safe_run_dir() from packages/_shared/path_safety.py (W0-5 binding).
Atomic write via tmp + os.replace() (D-062 binding).
"""

from packages._shared.path_safety import safe_run_dir
from packages._shared.path_safety import safe_path

@dataclass(frozen=True, slots=True)
class RawHtmlSink:
    """Persist verbatim HTML to local filesystem for reprocessing.

    Phase 2 thin slice: local filesystem under data/raw/news/. Phase 3 promotes
    to Cloudflare R2 per crawler-reliability skill § Storage.
    """

    base_dir: Path   # validated via safe_path; default = Path("data/raw/news")

    def write(self, source_id: str, url: str, html: str, fetched_at: datetime) -> Path:
        """Returns the path written. Atomic write per D-062."""
        ...
```

### D2 DoD criteria

- [ ] **DC-D2-1** — All 5 modules exist under `apps/_shared/crawl/`; bash-valid + Python
  valid (`python -m py_compile <each>` PASS).
- [ ] **DC-D2-2** — Per-file attribution headers present on `rate_limiter.py` (crawl4ai
  Apache-2.0) + `robots_manager.py` (Scrapling BSD-3) per DD-8 templates EXACTLY.
- [ ] **DC-D2-3** — Unit tests at `apps/_shared/crawl/test_rate_limiter.py`,
  `test_robots_manager.py`, `test_selector_chain.py`, `test_raw_html_sink.py` (NEW;
  ≥6 test cases each = ≥24 total):
  - Rate limiter: base case wait, exponential backoff on 429, decay on success,
    circuit-open after max_retries, seeded jitter is deterministic, per-domain isolation.
  - Robots manager: allow when no robots.txt (404 → None), disallow per rule, crawl_delay
    extraction, cache hit on second call, per-domain isolation, user-agent honored.
  - SelectorChain: first strategy hit, fallback through chain, all-fail returns None +
    logs warning, counter is accurate, label is recorded, empty chain → None.
  - RawHtmlSink: writes to expected path under `data/raw/news/<source>/<date>/<hash>.html`;
    sub-dirs created via safe_run_dir; atomic write (verify tmp file disappears on success);
    unicode HTML round-trips; sha256 hash truncation matches existing
    `cafef_scraper.py:212`.
- [ ] **DC-D2-4** — `mypy --strict apps/_shared/crawl/` exits 0.
- [ ] **DC-D2-5** — `ruff check apps/_shared/crawl/` exits 0.
- [ ] **DC-D2-6** — `bash scripts/hooks/python-determinism-check.sh </dev/null` reports 0
  new violations against new modules (D-059 R1/R2/R4 compliance: rate_limiter uses seeded
  RNG; no `datetime.now()` without tz; no `time.time()` in domain — these are infrastructure
  modules so R4 N/A but R1+R2 BINDING).
- [ ] **DC-D2-7** — `bash scripts/hooks/path-safety-check.sh </dev/null` reports 0 new
  violations against new modules (W0-5 D-064 compliance: RawHtmlSink uses `safe_run_dir`
  + `safe_path`; no UNC; no `..` traversal).
- [ ] **DC-D2-8** — `bash scripts/hooks/atomic-write-check.sh </dev/null` reports 0
  violations against new modules (D-062 compliance: RawHtmlSink uses tmp + os.replace).
- [ ] **DC-D2-9** — If `protego` was added to `pyproject.toml`, the dependency add lands
  in ONE coherent edit; `pip install -e .` succeeds; recorded in session log.

---

## Sub-track D3 — CafeFAdapter migration + CLI wiring (preserve contract)

### Migration recipe

1. **Create new concrete adapter** at
   `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` (NEW; ~250 LOC).
2. **Migrate logic** from existing `packages/infrastructure/news/cafef_scraper.py` (213
   LOC; KEEP as-is for back-compat; the new adapter WRAPS or REPLACES selectively per dev
   judgment — see § "Two migration strategies" below).
3. **Refactor body-container selection** at `cafef_scraper.py:117-120` to use
   `SelectorChain([(...), (...), (...)])` from `apps/_shared/crawl/selector_chain.py`
   (per DD-7 selector robustness).
4. **Inject `RateLimiter`** from `apps/_shared/crawl/rate_limiter.py` to replace the
   inline `_RATE_LIMIT_SECONDS = 2.0` + `time.monotonic()` arithmetic at
   `cafef_scraper.py:33, 162-169`.
5. **Inject optional `RobotsTxtManager`** from `apps/_shared/crawl/robots_manager.py` —
   if provided, adapter calls `can_fetch(url)` BEFORE every fetch; return None + log
   warning if disallowed.
6. **Inject optional `RawHtmlSink`** from `apps/_shared/crawl/raw_html_sink.py` — if
   provided, adapter saves verbatim `html` BEFORE parsing (so even if parse fails, raw
   HTML is preserved for reprocessing per skill § Storage).
7. **CLI wiring** at `apps/cli/ingest_news_cafef.py` — add a `CrawlerRegistry`
   construction step in `main()`; register `CafeFAdapter`; dispatch via
   `registry.get("cafef")` instead of direct `CafeFScraper()` instantiation. CLI flags
   + exit codes + summary output stay IDENTICAL (this is the migration's hard contract).

### Two migration strategies (dev picks)

**Strategy A (REPLACE)**: `CafeFAdapter` replaces `CafeFScraper` entirely; `CafeFScraper`
class deprecated (kept as thin wrapper that forwards to `CafeFAdapter` for any external
caller). Pros: clean single source of truth. Cons: larger diff; risk of behavioral drift.

**Strategy B (WRAP)**: `CafeFAdapter` wraps `CafeFScraper` (composes it as `_legacy`),
delegating `discover`/`fetch_article`/`to_news_article` while exposing the new ABC
surface. Pros: minimal diff; provable zero-drift via wrapping. Cons: 2 classes coexist;
future maintenance picks one.

**Architect recommendation**: **Strategy B (WRAP)** for this bundle because (a) zero
behavioral risk to the existing 318-LOC CLI, (b) `cafef_scraper.py:178-208` published_at
parser is non-trivial and proven — wrapping preserves it untouched, (c) future Phase D-N
session can collapse to Strategy A if/when justified. Architect verdict: dev picks at
IMPL time based on STEP 0.4 + 0.10 diff inspection; record choice in session log + ADR.

### CLI contract preservation (HARD CONSTRAINT)

The CLI surface at `apps/cli/ingest_news_cafef.py` MUST remain byte-identical at the
user-visible level:
- All click flags (`--tickers`, `--since`, `--max-articles`, `--listing`, `--output`,
  `--skip-llm`, `--summary`) UNCHANGED defaults + UNCHANGED help text.
- Exit code 0 on success; exit code from click `UsageError` on invalid input.
- All `click.echo(...)` lines UNCHANGED in format and order (so any scraper of CLI
  output for analytics keeps working).
- The summary markdown output at `apps/cli/ingest_news_cafef.py:266-309` (sentiment
  counts + first 5 articles) UNCHANGED in shape.

Internal refactors (CrawlerRegistry construction; CrawlerAdapter dispatch instead of
direct CafeFScraper) are invisible to the CLI consumer. Verifier S339 will exercise
the CLI end-to-end with fixture HTML and diff the output against baseline.

### D3 DoD criteria

- [ ] **DC-D3-1** — `packages/infrastructure/news/crawler_adapters/cafef_adapter.py`
  exists; subclasses `CrawlerAdapter`; declares `source_id = "cafef"`; per-file
  attribution header per DD-8 templates IF Strategy A (replaces port logic verbatim
  from crawl4ai shape).
- [ ] **DC-D3-2** — `packages/infrastructure/news/crawler_adapters/__init__.py` (NEW)
  exports `CafeFAdapter`.
- [ ] **DC-D3-3** — `packages/infrastructure/news/__init__.py` UPDATED to also export
  `CafeFAdapter` (alongside legacy `CafeFScraper` for back-compat).
- [ ] **DC-D3-4** — Pre-existing tests at `packages/infrastructure/news/test_adapters.py`
  ALL PASS (zero behavioral regression at CafeFScraper surface — proves wrap correctness
  if Strategy B; proves replacement correctness if Strategy A).
- [ ] **DC-D3-5** — New tests at `packages/infrastructure/news/crawler_adapters/
  test_cafef_adapter.py` (NEW; ≥10 test cases):
  1. Adapter declares `source_id = "cafef"`.
  2. Adapter can be registered to a fresh `CrawlerRegistry`.
  3. `discover` returns expected URLs from fixture HTML (mirror existing
     test_adapters.py fixture or load same recorded HTML).
  4. `fetch_and_parse` returns ScrapedArticle from fixture URL.
  5. `fetch_and_parse` returns None on parse failure (degrade gracefully).
  6. `to_news_article` populates `mentioned_tickers` correctly given a universe.
  7. Adapter uses injected RateLimiter (verify via mock — `wait_if_needed` called).
  8. Adapter uses injected RobotsTxtManager when provided (skip URL if disallowed).
  9. Adapter saves to injected RawHtmlSink when provided (verify file written).
  10. Adapter works WITHOUT optional injections (sink=None, robots=None) — default
      behavior matches existing CafeFScraper.
- [ ] **DC-D3-6** — `apps/cli/ingest_news_cafef.py` MODIFIED with CrawlerRegistry
  construction + dispatch; CLI contract preserved per § "CLI contract preservation".
- [ ] **DC-D3-7** — CLI end-to-end smoke test with fixture HTML — manual or
  test-driven; bytes-identical stdout vs baseline (recorded at STEP 0.10).
- [ ] **DC-D3-8** — `mypy --strict packages/infrastructure/news/ apps/cli/
  ingest_news_cafef.py` exits 0.
- [ ] **DC-D3-9** — `ruff check packages/infrastructure/news/ apps/cli/
  ingest_news_cafef.py` exits 0.
- [ ] **DC-D3-10** — `python -m pytest packages/infrastructure/news/` exits 0; new test
  count = pre + ≥10.

---

## Sub-track D4 — NOTICE file + ADR D-066

### NOTICE file (NEW at repo root)

**Path**: `NOTICE` (repo root; NEW).

**Content template** (architect-proposed; dev refines after STEP 0.2 read of LICENSE
files):

```text
StockForge

This product includes software developed by third parties as listed below.

================================================================================
Crawl4AI
================================================================================
Portions of this product include software developed by UncleCode
(https://x.com/unclecode) as part of the Crawl4AI project
(https://github.com/unclecode/crawl4ai).

Licensed under the Apache License, Version 2.0 with custom Attribution Requirement.
See https://github.com/unclecode/crawl4ai/blob/main/LICENSE for full text.

Files in this repository that adopt patterns or port code from Crawl4AI:
- apps/_shared/crawl/rate_limiter.py (pattern + LOC port of async_dispatcher.RateLimiter)
- packages/application/news/ports/crawler_adapter.py (architectural shape — BaseCrawler ABC)

================================================================================
Scrapling
================================================================================
Portions of this product include software developed by Karim Shoair
(https://github.com/D4Vinci/Scrapling).

Licensed under the BSD-3-Clause License. Copyright (c) 2026 Karim Shoair.
See https://github.com/D4Vinci/Scrapling/blob/main/LICENSE for full text.

Files in this repository that adopt patterns or port code from Scrapling:
- apps/_shared/crawl/robots_manager.py (pattern + LOC port of spiders/robotstxt.py)

================================================================================
```

**Dev MUST verify** at IMPL time that the exact Crawl4AI Attribution Requirement string
(LICENSE:54-67) is reproduced verbatim per A-02 § 6 ("This attribution must be displayed
in a prominent and easily accessible location"). The template above is a structural
guide; verify exact wording.

### ADR D-066 — BC-5 CrawlerAdapter contract

**Path**: `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` (NEW;
IMPL tier).

**Required source_evidence cites** (target ≥7):

1. `observations/master-planner-A-02-deepdive-crawl4ai.md § 2 + § 3 C1/C2/C4/C5/C7/C8 +
   § 5 + § 6 + § 7` (PRIMARY pattern source + license + risk flags).
2. `observations/master-planner-A-12-deepdive-Scrapling.md § 3 C5 + § 6 + § 7 #1
   (Cloudflare-solver HARD REJECT confirmation)` (SECONDARY hybrid contributor).
3. `observations/master-planner-A-05-deepdive-MediaCrawler.md § 5 + § 7 #1 (license
   blocker; CDP-mode reference for future Facebook path)` (REFERENCE ONLY).
4. `D-061 § Decision item 3 (Theme L hybrid winner) + § Decision item 4 (Scrapling
   Cloudflare-solver HARD REJECT)`.
5. `D-065 + financial-data-protocol.md Rule 16` (Rule 16 compliance audit — Schema
   discipline section above).
6. `.claude/skills/crawler-reliability/SKILL.md` (operational doctrine for selector
   robustness + retry/backoff + rate limit + monitoring + storage + anti-patterns).
7. `C:/htdocs/research/crawl4ai/crawl4ai/hub.py:24-69` (BaseCrawler + CrawlerHub source).
8. `C:/htdocs/research/crawl4ai/crawl4ai/async_dispatcher.py:28-85` (RateLimiter source).
9. `C:/htdocs/research/crawl4ai/LICENSE:54-67` (Attribution Requirement clause).
10. `C:/htdocs/research/Scrapling/scrapling/spiders/robotstxt.py:10-60` (RobotsTxtManager).
11. `C:/htdocs/research/Scrapling/LICENSE:1-28` (BSD-3-Clause copyright).
12. `agent-workspace/constitution/architecture.md § BC-5` (layer boundaries — application
    layer port + infrastructure layer adapter).
13. `agent-workspace/constitution/invariants-stockforge.md § I-S34 + § I-S35`
    (ToS-compliance + research-aid framing).
14. `packages/infrastructure/news/cafef_scraper.py` (migration source — current shape).

**Content sections** (mirror D-059/D-062/D-064 shape):
- Context (Wave 1 Theme L; BC-5 News Stream substrate; charter Phase 1 critical-path).
- The CrawlerAdapter port + CrawlerRegistry — method shape + sync rationale + ABC vs
  Protocol decision (per DD-3) + instance-scoped vs global registry refactor (per DD-5).
- Foundation primitives — RateLimiter + RobotsTxtManager + SelectorChain + RawHtmlSink;
  per-module source + license header requirement.
- Hybrid adoption strategy — what's adopted from crawl4ai (Apache-2.0 + Attribution),
  what's adopted from Scrapling (BSD-3), what's REJECTED (Cloudflare-solver + patchright
  + StealthyFetcher + MediaCrawler LOC).
- Rule 16 audit (Schema discipline section verbatim).
- Async deferred to Phase 3 (DD-2 rationale).
- Storage — local filesystem `data/raw/news/` Phase 2; Cloudflare R2 Phase 3.
- Compliance enforcement: ports + adapters use existing W0-2 (D-059) + W0-3 (D-062) +
  W0-5 (D-064) hooks; no new hook this bundle.
- Charter alignment: Principle 4 (data moat — raw HTML preserved for reprocessing) +
  Principle 7 (dogfood mandatory — CLI shipping at S338) + Principle 8 (calibration over
  confidence — shape-metrics emit per skill) + Principle 11 (firing-test mandate — N/A
  no new hook).
- Out-of-scope (deferred to follow-up plans — list mirror of § Out-of-scope below).
- Attribution: "Patterns adapted from Crawl4AI v0.8.6 (Apache-2.0 + Attribution
  Requirement) and Scrapling v0.4.7 (BSD-3-Clause); see NOTICE at repo root."

### D4 DoD criteria

- [ ] **DC-D4-1** — `NOTICE` exists at repo root; lists Crawl4AI + Scrapling attribution
  per template above; Crawl4AI Attribution Requirement string verbatim.
- [ ] **DC-D4-2** — ADR D-066 PROPOSED at IMPL tier with ≥7 source_evidence cites; 12-field
  schema valid (`decisions/_template.md` compliance).
- [ ] **DC-D4-3** — ADR D-066 § "Rule 16 audit" section present, lists the per-field
  audit table from this plan's § Schema discipline.
- [ ] **DC-D4-4** — ADR D-066 § "Why ABC not Protocol" section present documenting the
  convention exception per DD-3.
- [ ] **DC-D4-5** — ADR D-066 § "Out-of-scope" section enumerates deferred items per
  this plan's § Out-of-scope.

---

## Bundle DoD aggregate — DC-AGG-1 through DC-AGG-15

Aggregated across all 4 sub-tracks; verifier S339 confirms each empirically:

- [ ] **DC-AGG-1** — All new module paths exist:
  - `packages/application/news/ports/crawler_adapter.py`
  - `packages/application/news/ports/crawler_registry.py`
  - `packages/application/news/ports/test_crawler_adapter.py`
  - `apps/_shared/crawl/__init__.py`
  - `apps/_shared/crawl/rate_limiter.py` + `test_rate_limiter.py`
  - `apps/_shared/crawl/robots_manager.py` + `test_robots_manager.py`
  - `apps/_shared/crawl/selector_chain.py` + `test_selector_chain.py`
  - `apps/_shared/crawl/raw_html_sink.py` + `test_raw_html_sink.py`
  - `packages/infrastructure/news/crawler_adapters/__init__.py`
  - `packages/infrastructure/news/crawler_adapters/cafef_adapter.py`
  - `packages/infrastructure/news/crawler_adapters/test_cafef_adapter.py`
  - `NOTICE` (repo root)
  - `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md`
- [ ] **DC-AGG-2** — All new test files: ≥8 + ≥6×4 + ≥10 = ≥42 new test cases; ALL PASS.
- [ ] **DC-AGG-3** — `bash scripts/hooks/bash-hook-lint.sh` exits 0 (no shell changes
  this bundle — but verify clean as regression floor).
- [ ] **DC-AGG-4** — `bash scripts/hooks/firing-tests/run-all.sh` exits 0; firing-test
  PASS count UNCHANGED from STEP 0.9 baseline (no new firing-tests this bundle — DC-AGG-3
  is regression check).
- [ ] **DC-AGG-5** — `python -m mypy --strict packages/ apps/` exits 0 across the new
  modules + modified files (per-module breakdown per DC-D1-5 / DC-D2-4 / DC-D3-8).
- [ ] **DC-AGG-6** — `python -m ruff check packages/ apps/` exits 0 across the new
  modules + modified files (per-module breakdown per DC-D1-6 / DC-D2-5 / DC-D3-9).
- [ ] **DC-AGG-7** — `python -m pytest packages/ apps/ -q` exits 0; new test count = pre
  + ≥42 (per DC-AGG-2). NO REGRESSION on baseline (STEP 0.9).
- [ ] **DC-AGG-8** — All 5 W0-substrate hooks fire clean on the new modules:
  - `bash scripts/hooks/python-determinism-check.sh </dev/null` — 0 new violations.
  - `bash scripts/hooks/atomic-write-check.sh </dev/null` — 0 new violations.
  - `bash scripts/hooks/html-separator-check.sh </dev/null` — 0 new violations (no new
    markdown in audited zones — ADR is in `decisions/` which is excluded).
  - `bash scripts/hooks/path-safety-check.sh </dev/null` — 0 new violations.
- [ ] **DC-AGG-9** — **Rule 16 audit** documented in session log AND in D-066 §
  "Rule 16 audit"; per-field table matches this plan's § Schema discipline. Zero new
  LLM-numeric fields introduced.
- [ ] **DC-AGG-10** — License attribution verified:
  - `NOTICE` at repo root present with Crawl4AI + Scrapling sections per DD-8.
  - Per-file headers on `apps/_shared/crawl/rate_limiter.py` (crawl4ai) +
    `apps/_shared/crawl/robots_manager.py` (Scrapling) per DD-8 templates EXACTLY.
- [ ] **DC-AGG-11** — CLI contract preserved at `apps/cli/ingest_news_cafef.py`:
  bytes-identical user-visible output vs baseline (STEP 0.10 capture). All flags +
  defaults + exit codes + summary shape unchanged. Verifier re-runs end-to-end.
- [ ] **DC-AGG-12** — `packages/infrastructure/news/cafef_scraper.py` preserved as-is OR
  deprecated as thin wrapper per § "Two migration strategies" choice; either way the
  decision recorded in D-066 + session log.
- [ ] **DC-AGG-13** — Session log written to
  `agent-workspace/memory/sessions/2026-05-XX-session-338.md` per CLAUDE.md § Session
  Protocol "End" steps, summarising the bundle outcome + ADR D-066 PROPOSED + 8 new
  modules shipped + CafeF migration + STEP 0 evidence captures.
- [ ] **DC-AGG-14** — `agent-workspace/memory/current-execution.md` updated: Phase D
  Theme L status → first IMPL session SHIPPED; next-action → S339 sandwich-verifier
  dispatch (with sub-row per CLAUDE.md retention rules — ≤ 5 sessions inline / ≤ 200 LOC).
- [ ] **DC-AGG-15** — `agent-workspace/memory/mistake-log.md` either appended (M-S338-N
  if any mistakes) or session log explicitly states "no mistakes this session" (enforced
  by `session-end-checklist-linter.sh` Stop hook per CLAUDE.md § Session Protocol "End"
  step 6).

---

## Coordination rules during dev (S338 active)

**Main session AVOIDS** during S338 IMPL window (cross-session edit conflict prevention):

- `packages/application/news/ports/crawler_adapter.py` + `crawler_registry.py` +
  `test_crawler_adapter.py` (D1)
- `packages/application/news/ports/__init__.py` (D1 export update)
- `packages/application/news/__init__.py` (D1 export update)
- `apps/_shared/crawl/**` — entire new package directory (D2)
- `packages/infrastructure/news/crawler_adapters/**` — entire new package directory (D3)
- `packages/infrastructure/news/__init__.py` (D3 export update)
- `packages/infrastructure/news/cafef_scraper.py` (D3 — Strategy A modifies; Strategy B
  leaves untouched; either way main avoids)
- `apps/cli/ingest_news_cafef.py` (D3 — CLI wiring edit at IMPL close)
- `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` (D4)
- `NOTICE` at repo root (D4)
- `pyproject.toml` (D2 — IF `protego` dep needs adding; ONE coherent edit at IMPL close
  per S332 precedent)
- `agent-workspace/memory/sessions/2026-05-XX-session-338.md` (authored by S338 dev at end)
- `agent-workspace/memory/observations/sandwich-dev-S338-phase-d-theme-l-crawling-
  adapter.md` (S338 dispatch observation file)

**Main session MAY** continue work on (orthogonal):
- Any other `apps/cli/ingest_*.py` not `ingest_news_cafef.py` (e.g.,
  `ingest_kol_channels.py`, `ingest_crowd_sentiment.py`, etc.).
- Other ADRs in `agent-workspace/memory/decisions/` outside D-066.
- `agent-workspace/research/`, `agent-workspace/master-plans/`,
  `agent-workspace/proposals/`, `agent-workspace/calibration/`,
  `agent-workspace/thesis-log/`.
- `packages/_shared/path_safety.py` is READ-ONLY for S338 dev (it's a W0-5 dependency,
  not a target).
- Other `packages/` BCs outside news (BC-1/2/3/4/6/7/8/9 unaffected).
- `agent-workspace/memory/current-execution.md` row pre-staging at S338 start — but NOT
  during IMPL window; dev finalises at IMPL close.

**Commit boundary** (D-060 active): the S338 dev MAY commit at IMPL close in a single
coherent commit OR split per sub-track (4 commits — one per D1/D2/D3/D4). Recommended
message stems:

- Option A (single commit): `S338: Phase D Theme L — CrawlerAdapter port + foundation + CafeF migration + D-066 + NOTICE`
- Option B (4 commits):
  - `S338: D1 — CrawlerAdapter ABC port + CrawlerRegistry`
  - `S338: D2 — apps/_shared/crawl/ foundation (rate-limiter + robots-manager + selector-chain + raw-html-sink)`
  - `S338: D3 — CafeFAdapter migration + CLI wiring (preserve contract)`
  - `S338: D4 — NOTICE file + ADR D-066`

The dev picks based on whether all 4 sub-tracks reach DoD cleanly in one pass (Option A)
or incrementally (Option B). Do NOT push.

---

## Risk + Mitigation

| # | Risk | Likelihood | Mitigation |
|---|------|-----------|------------|
| RM1 | **Selector breakage** — CafeF redesigns site between plan-authoring and dev IMPL; recorded HTML fixtures no longer match live HTML | Low (fixtures decoupled from live) | Existing `cafef_scraper.py` test surface uses recorded fixtures (per `cafef_scraper.py:8-11` docstring) — fixture-based tests immune to live redesign. Live smoke test is OUT-OF-SCOPE for CI (only manual verification at deploy time per skill § Monitoring). If STEP 0.10 fixture replay diverges → STOP and revisit before D3 migration. |
| RM2 | **Rate-limit violations against cafef.vn** — accidentally hitting live URL during dev/test (e.g., test that bypasses `fetcher` injection) | Low (injection pattern proven; existing tests don't hit live) | Audit all new tests for absence of bare `httpx.get` / `requests.get` / `urllib` calls outside injected fetcher; bash-hook-lint or grep before commit. RateLimiter port itself does NOT touch network — pure timing state. RobotsTxtManager port uses injected fetcher (per D2 spec). |
| RM3 | **LLM-output sneaks past Rule 16** — a new schema field (e.g., on RawHtmlSink metadata, or in selector-chain telemetry) added in the heat of IMPL without Rule 16 satisfaction-mode declaration | Low (audit + STEP 0.5 anchor) | § Schema discipline empirically confirms ZERO new LLM-numeric fields; STEP 0.5 re-confirms at IMPL time. Any new numeric field MUST add satisfaction-mode docstring per Rule 16 § "At amendment time"; DC-AGG-9 verifier check is the final gate. If dev encounters need for new field → STOP-AND-ESCALATE per § STEP 0 STOP-IF-AMBIGUOUS. |
| RM4 | **Budget overrun** — bundling all 4 sub-tracks (D1+D2+D3+D4) + 4 source crawlers' migrations would breach budget; dev mistakenly attempts NDH/Vietstock/VietnamBiz migration in this session | Low (plan explicitly scopes to CafeF only) | Plan title + Goal + § Context decision 1 + § Out-of-scope item 4 EXPLICITLY scope to CafeF only. NDH/Vietstock/VietnamBiz migrations are EXPLICITLY out-of-scope; if dev mistakenly attempts → STOP-AND-SPLIT: revert NDH/Vietstock/VietnamBiz work; queue follow-up plan 021 for those sources; bundle ships at CafeF-only DoD. |
| RM5 | **crawl4ai upstream changes break adapter contract** — if dev pulls fresh-shot crawl4ai code in dev environment (rather than pattern-port), upstream commits since 2026-05-15 could ship adapter-incompatible APIs | N/A — no pip-install | Plan explicitly REJECTS pip-install crawl4ai (per § Context decision 2). Ports are pattern-LOC adaptation at fixed source citations; once ported, upstream movement does NOT affect stockforge. STEP 0.2 + 0.3 re-verifies source-file:line citations one time before authoring; after that, the port is frozen. |
| RM6 | **`protego` dependency not present in `pyproject.toml`** | Med | STEP 0.8 verifies presence; DC-D2-9 documents the add. ONE coherent dep-edit at IMPL close per S332 precedent. If `protego` install fails (e.g., upstream removed) → fall back to a fresh `RobotsTxt` parser using stdlib `urllib.robotparser` (≥Python 3.10 stdlib; ~30 LOC adapter to keep RobotsTxtManager interface). |
| RM7 | **CLI behavioral drift** — Strategy A (REPLACE) accidentally breaks one of the click flags or summary output | Low (Strategy B WRAP recommended) | Architect recommends Strategy B (WRAP) per § "Two migration strategies"; bytes-identical output is provable via STEP 0.10 baseline + post-IMPL diff per DC-AGG-11. If dev picks Strategy A, MUST capture pre-migration `python apps/cli/ingest_news_cafef.py --help` + smoke output verbatim and diff post-IMPL. |
| RM8 | **License-attribution drift** — NOTICE template above uses architect-proposed wording; actual Crawl4AI LICENSE:54-67 may have slightly different text → attribution incomplete | Low (STEP 0.2 + 0.8 enforce verbatim verification) | STEP 0.2 + STEP 0.8 mandate reading actual LICENSE files; dev refines NOTICE text after read; per-file headers per DD-8 templates are stable. DC-AGG-10 verifies. |
| RM9 | **`__init_subclass__` hook in ABC pollutes test surface** — subclass enforcement at class-creation time can complicate test scenarios (e.g., dynamically-created test adapter classes) | Low | Test design at DC-D1-4 anticipates: tests 2/3 explicitly construct invalid subclasses and assert TypeError; tests 4 onward construct valid subclasses. Pytest fixtures can use `type(...)` to dynamically construct classes — this works as expected because `__init_subclass__` fires on dynamic construction too. |
| RM10 | **AP-23 second-rule-about-rule trigger** — introducing D-066 on top of D-061 + D-062 + D-063 + D-064 + D-065 may trip CLAUDE.md AP-23 red flag ("Refinement-of-rule lesson-about-lesson") | Low (D-066 is a first-instance product-substrate doctrine, NOT a refinement of any prior ADR) | D-066 is the BC-5 CrawlerAdapter contract — a first-instance architectural doctrine for product substrate, NOT a refinement of any prior rule. D-062/063/064 are harness substrate hook doctrines; D-066 is product substrate. D-061 is a meta-ratification ADR; D-065 ratifies a constitution amendment. D-066 references but does not refine any of them. Architect verdict: NOT an AP-23 trigger; verify by reading D-066's framing — if it reads "Extending D-XXX with..." or "Refinement of D-YYY for...", flag for promote-or-retire; the proposed shape is standalone. |
| RM11 | **`raw_html` writes accidentally bypass safe_run_dir** — dev forgets to wire path-safety helpers per W0-5 D-064 binding | Low (DC-D2-7 + DC-AGG-8 catch) | Plan explicitly cites `packages/_shared/path_safety.py` in DD-6 + D2 RawHtmlSink spec; DC-D2-7 verifies; DC-AGG-8 second check via path-safety-check.sh hook. If hook fires on new module → STOP and fix before commit. |
| RM12 | **Strategy B (WRAP) creates dead code on long-term** — `CafeFScraper` class wraps `CafeFAdapter` indefinitely; no consolidation path | Med | Documented in D-066 § "Strategy choice" + recorded in session log; carry-forward note "consolidate CafeFScraper into CafeFAdapter in follow-up D-N session" added to `agent-workspace/memory/agent-notes.md` per CLAUDE.md § Session Protocol "End" step 4 IF Strategy B chosen. |
| RM13 | **Async-leak temptation** — dev sees crawl4ai is async-first and adds `async def` somewhere on the path | Low (plan explicit + DD-2 + ADR D-066 § "Async deferred") | Plan § Context decision 3 + DD-2 + ADR D-066 § "Async deferred to Phase 3" + CLI is sync = strong scaffolding. If dev mistakenly adds async signature → STOP via mypy (sync caller fails type-check) + pytest red. |

---

## Out-of-scope explicit list

These items are explicitly OUT of this bundle's scope:

1. **Scrapling adaptive selector + SQLiteStorageSystem** (A-12 § 3 C1; ~250 LOC + SQLite
   storage + `relocate` algorithm) → DEFERRED to follow-up plan D-N (likely 022) once
   live-site brittleness is empirically observed; per DD-7 the fallback-chain pattern is
   the primary defense for this bundle.
2. **Scrapling `find_similar` sibling-element finder** (A-12 § 3 C2; ~60 LOC) → DEFERRED;
   not required for CafeF article structure; revisit when listing-page items need
   auto-discovery (BC-7 Crowd forum threads more likely candidate).
3. **NDH / VietstockFinance / VietnamBiz crawler migrations** → DEFERRED to per-source
   FOCUSED_IMPL sessions in Phase D-N (one per source; budget 60-100K each per
   session-budgets.md FOCUSED_IMPL envelope). Each session: subclass `CrawlerAdapter`,
   add recorded-HTML test fixtures, wire CLI. The adapter shape this bundle ships is the
   inflection — subsequent sources should each be a 1-day session.
4. **Vietnam Biz crawler** specifically — same as above, plus the source URL convention
   is unknown at plan-authoring time; STEP 0 of the Vietnam-Biz-specific session will
   need to do live-DOM VBW per crawler-reliability skill before writing selectors.
5. **YouTube transcript path** → master plan § 5.7 + L.3 settle: "official Data API v3 +
   yt-dlp canonical; no crawler needed". NOT this plan's scope — direct API integration is
   BC-6 (Influence) work that happens via `apps/cli/ingest_kol_channels.py` (already
   present) extension; orthogonal to CrawlerAdapter.
6. **Facebook fanpage path (CDP-consented mode)** → MediaCrawler-pattern adoption per L.3
   "Login-walled sources → MediaCrawler-pattern CDP-connect-existing-Chrome consent flow
   (clean-room re-derive); user opt-in via `chrome://inspect/#remote-debugging`". NOT this
   plan's scope; requires browser-driven adapter variant + consent UX flow — separate
   future plan once user has Facebook-fanpage list to subscribe to.
7. **Banned-pattern hook for CrawlerAdapter contract** — NO new hook this bundle. The
   adapter is product substrate, not harness rule-enforcement. If a static-analysis rule
   emerges (e.g., "every concrete adapter MUST inherit CrawlerAdapter, not freestanding"),
   that's a follow-up plan per harness-health-protocol § HH-10. Architect verdict: not
   warranted at this scale; ABC + mypy + reviewer covers it.
8. **`extract_claims` method on CrawlerAdapter** → DEFERRED to Theme I (Phase E); the
   current pipeline at `apps/cli/ingest_news_cafef.py:155-159` separately constructs
   `ClaudeLlmExtractor` + `ClaimExtractionService` — keep that boundary clean for Theme I
   to redesign.
9. **Backtest validation of crawler-emitted data quality** → Theme N (Charter Month-12;
   per D-061 § Decision item 7 deferred to Wave 2+).
10. **CrawlerHub auto-discovery via filesystem scan** (per crawl4ai `hub.py:37-69`
    `_discover_crawlers`) → REJECTED per DD-5 + A-02 § 7 anti-pattern; instance-scoped
    registry with explicit `register()` is the chosen shape.
11. **R2 (Cloudflare) raw-HTML storage** → DEFERRED to Phase 3 per crawler-reliability
    skill § Storage; Phase 2 thin slice = local `data/raw/news/`.
12. **Shape-metrics emit + persistence** (per skill § Monitoring "article_count,
    with_title, with_url, with_published_at per-field success rate; persist to
    `agent-workspace/calibration/crawler-shape/<source>.tsv`") → DEFERRED to Phase 3.
    This bundle's SelectorChain counts strategy attempts internally + logs warnings; the
    `.tsv` persistence is the follow-up calibration scaffolding.
13. **Promotion of `confidence_extracted` to mode #3 calibration-lookup wiring** → BC-6
    KOL extractor work (per Rule 16 first bullet rationale); NOT this plan's scope.
14. **CrawlerAdapter contract documentation in `agent-workspace/ubiquitous-language/
    glossary.md`** → suggested follow-up but NOT required by DoD; if dev has spare cycles
    in session, append a "CrawlerAdapter / CrawlerRegistry / source_id" entry per UL
    convention.

---

## Verifier checklist (S339 sandwich-verifier MUST re-check empirically)

Per AP-1 fresh-context; mirror plan 018's verifier checklist shape.

### V1 — Acceptance (per DC-AGG-1 through DC-AGG-15)

- [ ] V1.1 — Empirically `ls` each new file in DC-AGG-1; `python -m py_compile <each>`
  PASS for Python; `cat NOTICE | head -20` shows Crawl4AI + Scrapling attribution.
- [ ] V1.2 — `python -m pytest packages/application/news/ports/test_crawler_adapter.py
  -q` exits 0 with ≥8 PASS.
- [ ] V1.3 — `python -m pytest apps/_shared/crawl/ -q` exits 0 with ≥24 PASS.
- [ ] V1.4 — `python -m pytest packages/infrastructure/news/crawler_adapters/ -q` exits 0
  with ≥10 PASS.
- [ ] V1.5 — `python -m pytest packages/infrastructure/news/test_adapters.py -q` exits 0
  with ZERO regression vs STEP 0.10 baseline (pre-migration test count = post-migration
  test count for this specific test file).
- [ ] V1.6 — `python -m mypy --strict packages/application/news/ packages/infrastructure/
  news/ apps/_shared/crawl/ apps/cli/ingest_news_cafef.py` exits 0.
- [ ] V1.7 — `python -m ruff check packages/application/news/ packages/infrastructure/
  news/ apps/_shared/crawl/ apps/cli/ingest_news_cafef.py` exits 0.
- [ ] V1.8 — `bash scripts/hooks/python-determinism-check.sh </dev/null` reports 0 new
  violations.
- [ ] V1.9 — `bash scripts/hooks/atomic-write-check.sh </dev/null` reports 0 new
  violations.
- [ ] V1.10 — `bash scripts/hooks/path-safety-check.sh </dev/null` reports 0 new
  violations.
- [ ] V1.11 — `bash scripts/hooks/firing-tests/run-all.sh` exits 0; firing-test PASS
  count UNCHANGED from STEP 0.9 baseline.
- [ ] V1.12 — `bash scripts/hooks/bash-hook-lint.sh` exits 0.
- [ ] V1.13 — `head -50 agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md`
  shows valid 12-field frontmatter; `grep -c "^- path:" agent-workspace/memory/decisions/
  066-*.md` ≥ 7 (source_evidence cites count).
- [ ] V1.14 — `head -20 NOTICE` shows Crawl4AI + Scrapling sections per DC-D4-1; verify
  no PII / no LLM-generated boilerplate.

### V2 — Schema discipline (Rule 16 audit re-verification)

- [ ] V2.1 — Grep all new modules for new numeric-field declarations:
  ```bash
  grep -rn "float\|int\b\|Decimal" packages/application/news/ports/crawler_adapter.py \
    packages/application/news/ports/crawler_registry.py \
    packages/infrastructure/news/crawler_adapters/cafef_adapter.py \
    apps/_shared/crawl/
  ```
  Each match is either (a) infra-internal timing/counter (RateLimiter `current_delay` /
  SelectorChain counter) — Rule 16 N/A per § Schema discipline, OR (b) preserved-existing
  field (`ExtractorMetadata.confidence_extracted` if surfaced — mode #3 lookup target).
  Document V2.1 audit in verifier observation.
- [ ] V2.2 — `grep -rn "confidence_extracted\|price_target\|entry_price" packages/
  application/news/ packages/infrastructure/news/ apps/_shared/crawl/` returns ZERO
  matches for fields newly assigned by adapter code paths (Rule 16 surface preserved).
- [ ] V2.3 — Cross-check D-066 § "Rule 16 audit" section matches V2.1 + V2.2 empirical
  findings.

### V3 — CLI contract preservation

- [ ] V3.1 — `python apps/cli/ingest_news_cafef.py --help` output bytes-identical vs
  STEP 0.10 baseline (modulo deterministic timestamps if any). Verifier diff-tools.
- [ ] V3.2 — Smoke run with fixture HTML (if test_adapters.py fixture is replayable):
  CLI exits 0; summary output matches baseline.
- [ ] V3.3 — All click flags (`--tickers`, `--since`, `--max-articles`, `--listing`,
  `--output`, `--skip-llm`, `--summary`) accept SAME inputs; produce SAME side-effects
  (file written at `--output` path, summary written at `--summary` path).

### V4 — License attribution

- [ ] V4.1 — `NOTICE` file at repo root; Crawl4AI Attribution Requirement string
  reproduced VERBATIM from `C:/htdocs/research/crawl4ai/LICENSE:54-67`. Verifier
  cross-checks LICENSE file at upstream commit pinned in D-066.
- [ ] V4.2 — Per-file headers on `apps/_shared/crawl/rate_limiter.py` (crawl4ai
  Apache-2.0) + `apps/_shared/crawl/robots_manager.py` (Scrapling BSD-3) match DD-8
  templates EXACTLY.
- [ ] V4.3 — No header missing on any port file; no header on pure-fresh files
  (`selector_chain.py`, `raw_html_sink.py`, `crawler_adapter.py`).

### V5 — Charter compliance

- [ ] V5.1 — No charter edits (verify: `git diff HEAD~N HEAD PROJECT_CHARTER.md` empty).
- [ ] V5.2 — No constitution edits (verify:
  `git diff HEAD~N HEAD agent-workspace/constitution/ | wc -l` = 0).
- [ ] V5.3 — Compliance Attestation block in session log includes: I-S1 ✓ / I-S2 ✓ /
  I-S22 ✓ / I-S34 ✓ / I-S35 ✓ / Rule 6 ✓ / Rule 8 ✓ / Rule 16 ✓ / Charter Principle 4 ✓ /
  Charter Principle 7 ✓ / Charter Principle 11 N/A (no new hook) / D-060 (commit count +
  0 push) / 0 charter / 0 constitution / 0 human-workspace / AP-1 honored (S339
  fresh-context).

### V6 — Regression + integration smoke

- [ ] V6.1 — `python -m pytest packages/ apps/ -q` exits 0; new test count = pre + ≥42;
  no baseline regression.
- [ ] V6.2 — `bash scripts/hooks/firing-tests/run-all.sh` exits 0; pass count unchanged
  from STEP 0.9 baseline.
- [ ] V6.3 — Integration smoke: synthesize a `CrawlerRegistry()`, register a fresh
  `CafeFAdapter()` with stub fetcher returning recorded fixture HTML; call
  `registry.get("cafef").fetch_and_parse(url)`; assert ScrapedArticle returned with
  title + body + published_at populated. (This validates the end-to-end port + registry
  contract.)
- [ ] V6.4 — Re-run `python apps/cli/ingest_news_cafef.py --tickers VHM --skip-llm
  --max-articles 1` (or equivalent fixture-mode invocation if the CLI accepts a fixture
  flag — if not, mock at click-runner level via pytest); confirm zero exception + summary
  generated.

---

## Compliance Attestation (this PLAN session — S337)

- [x] no production code written (this is a PLAN session per CLAUDE.md § Session Types)
- [x] no commits (no Bash tool granted to sandwich-architect)
- [x] no charter edits
- [x] no constitution writes (Rule 16 already landed via D-065 — this plan respects, does
  NOT modify)
- [x] no human-workspace writes
- [x] no edits to `apps/cli/ingest_news_*.py` (migration targets — S338 dev's scope)
- [x] no master-plan edits (D-061 already ratifies Theme L hybrid winner)
- [x] every claim source-cited per I-S2 (deep-dives + financial-data-protocol + skill +
  existing code)
- [x] I-S34 ToS compliance honored — Scrapling Cloudflare-solver + patchright +
  StealthyFetcher HARD REJECT confirmed in every section
- [x] I-S35 research-aid framing preserved — adapter is data-ingestion substrate; output
  framing is downstream concern (existing summary in CLI uses framing-neutral structure)
- [x] Rule 16 (D-065) audit performed — § Schema discipline confirms ZERO new LLM-numeric
  fields introduced
- [x] R-1 no-mix PLAN+IMPL honored (PLAN-only session; S338 is the IMPL session)
- [x] R-2 split-if->10-tasks evaluated — bundle contains 4 sub-tracks × (2-4 tasks each)
  ≈ 14-15 tasks; budget envelope 100-150K target stays within MULTI_TASK_IMPL band per
  session-budgets.md
- [x] AP-1 fresh-context honored — S339 verifier dispatched fresh-context per § Verifier
  checklist
- [x] AP-23 not triggered (D-066 is first-instance product substrate, not refinement) —
  RM10 documents the check
- [x] VBW protocol applied — all upstream-repo claims grounded by Read tool on actual files
  (`crawl4ai/hub.py:24-69`, `crawl4ai/async_dispatcher.py:28-85`,
  `Scrapling/spiders/robotstxt.py:10-60`, `crawl4ai/LICENSE:1-67`,
  `Scrapling/LICENSE:1-28`, etc.); existing-code claims grounded by Read tool on
  `cafef_scraper.py` (213 LOC), `ingest_news_cafef.py` (318 LOC),
  `news_article.py`, `extractor_metadata.py`, `crawler-reliability/SKILL.md`,
  `financial-data-protocol.md` Rule 16

End of plan 020-S337-phase-d-theme-l-crawling-adapter.md.
