---
plan_id: 022-S343-phase-d-ndh-adapter
target_session: S344
type: FOCUSED_IMPL
budget: 100-150K (proposed; ~20% reserve for STEP 0 findings adjusting scope)
phase: D (Theme L — NDH greenfield adapter; FIRST Strategy A direct-subclass adapter per plan-020 § E matrix; FIRST consumer of SelectorChain[T] primitive — closes plan-020 F2 carry-forward documented in ADR D-066 § Out-of-scope item 12)
track: Wave 1 Theme L (BC-5 News Stream per-source rollout; NDH = source #2 of 4 priority VN sources)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.7 + § 6.4.1
predecessor: 020-S337-phase-d-theme-l-crawling-adapter (Phase D Theme L first IMPL cycle CLOSED S339; CrawlerAdapter ABC + CrawlerRegistry + apps/_shared/crawl/ primitives + CafeFAdapter Strategy-B WRAP all SHIPPED + VERIFIED PASS-WITH-CONCERNS; F1+F2 remediated inline at commit 9eaeed1; plan moved pending→completed at S339 close)
successor: TBD-S345 sandwich-verifier (AP-1 fresh-context); then 023-S346 (VietstockFinance adapter — same matrix-row pattern) and 024-S347 (VietnamBiz adapter — bumped to 3.0s rate-limit per matrix)
architect: S343 sandwich-architect (background; this plan)
dispatched_by: main session orchestrating Phase D per-source rollout (Wave 1 Theme L continuation)
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S344; fresh-context; AP-1 verifier in S345)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook (per current-execution.md § INCIDENT + RECOVERY)"
  - "R3 daily-backup.sh Stop hook (per current-execution.md § INCIDENT + RECOVERY)"

depends_on:
  - "D-066 PROPOSED (CrawlerAdapter ABC contract; SHIPPED S338 IMPL; VERIFIED S339; this plan is the FIRST USE of the ABC + first Strategy A direct subclass per plan-020 § E matrix; this plan may amend D-066 if NDH usage reveals contract gaps — see § L ADR amendment plan)"
  - "D-061 (Wave-1 integration ratification — ACCEPTED 2026-05-15; § Decision item 4 enforces 'Scrapling Cloudflare-solver HARD REJECT + patchright DO NOT IMPORT + StealthyFetcher excluded as a class' — BINDING)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain are BINDING for every new file authored under this plan; rate_limiter.py already uses seeded RNG per D-059 R2)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for S344 dev commit boundary)"
  - "D-062 (atomic-write-doctrine — BINDING for any raw-HTML writes via RawHtmlSink; already enforced by W0-3 hook + RawHtmlSink uses tmp+os.replace)"
  - "D-064 (path-safety 5-invariant contract — BINDING for new file-path code; RawHtmlSink already uses safe_path)"
  - "D-065 (Theme G I-S1-1 Rule 16 binding; this plan introduces ZERO new LLM-numeric schema fields — same Rule-16-by-construction posture as plan-020)"
  - "Charter v1.1 Principle 4 (Proprietary data moat) + Principle 7 (Dogfood mandatory — CLI ingest_news_ndh shipping at S344) + Principle 8 (Calibration over confidence) + Principle 11 (companion firing-test mandate IF a hook is shipped — NO new hook this bundle, mirror plan-020)"
  - "I-S1 (NO LLM math) + I-S2 (citation discipline — source_url + as_of + extracted_at) + I-S22 (data lineage) + I-S34 (robots.txt + reasonable rate limits + identify user agent; HARD REJECT of patchright/playwright_stealth/fake-useragent/StealthyFetcher; permanent BAN per D-061 § item 4) + I-S35 (research-aid framing)"
  - "Rule 6 (LLM Output Provenance — adapter output ↦ NewsArticle ↦ ExtractedClaim path preserves) + Rule 7 (sentiment categorical) + Rule 8 (anti-look-ahead: published_at ≤ ingested_at carried through)"
  - "skill .claude/skills/crawler-reliability/SKILL.md (Selector Robustness fallback chain + Retry & Backoff tenacity recipe + Rate Limiting per-domain + VBW for Scrapers + Monitoring shape metrics + Anti-Patterns list)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (adapter/port/repository discipline)"

binding_decisions:
  - "D-066 § Decision (CrawlerAdapter ABC + source_id ClassVar enforcement via __init_subclass__; subclass MUST declare non-empty source_id; subclass MUST implement discover/fetch_and_parse/to_news_article; subclass MUST NOT import patchright/playwright_stealth/fake-useragent/StealthyFetcher/_cloudflare_solver per I-S34) — BINDING for NDHAdapter"
  - "D-061 § Decision item 4 (Scrapling Cloudflare-solver HARD REJECT) — BINDING for all crawler adapters under packages/infrastructure/news/crawler_adapters/**"
  - "D-065 Rule 16 (numeric-field discipline) — NDH crawler emits ZERO new LLM-numeric fields; Rule 16 satisfied by construction (mirror plan-020 § Schema discipline)"
  - "D-060 — agent MAY git commit (NOT push); S344 dev decides commit boundary per § J Coordination paths"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL)"
  - "no commits in THIS plan-session by architect (architect tool grant per sandwich-architect.md D7 update — architect MAY commit own PLAN output via the architect-dispatch-template; D-060 still applies — agent NEVER pushes)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no touching apps/cli/ingest_news_cafef.py — that's already migrated; this plan ships a NEW CLI ingest_news_ndh.py"
  - "no Vietstock/VietnamBiz adapter work — those are out-of-scope per § B and Phase D-N follow-up sessions"
  - "no harness/hook changes — this plan ships product substrate (NDH adapter); surface any harness gaps in observation; do NOT fix here"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 HARD REJECT: NDHAdapter MUST NOT import patchright, playwright_stealth, fake-useragent, StealthyFetcher, _cloudflare_solver, or any Scrapling Cloudflare-solver path — verifier AQ check grep-asserts this"
  - "If STEP 0 finds NDH site is JS-rendered (would require Playwright) → DEFER adapter; flag as harness gap; do NOT install patchright; do NOT silently bypass I-S34"
---

# S344 — Phase D NDH Adapter (greenfield Strategy A; first SelectorChain[T] consumer)

## A. Goal

Ship the **first greenfield Strategy A direct-subclass CrawlerAdapter** for Vietnamese financial news source NDH (`nhipsongdoanhnghiep.vn` or `ndh.vn` — STEP 0 verifies live), establishing the per-source rollout pattern that subsequent VN news sources (Vietstock, VietnamBiz) will mirror. NDHAdapter is also the **FIRST consumer of `SelectorChain[T]`** — closing plan-020 F2 carry-forward documented in ADR D-066 § Out-of-scope item 12 ("SelectorChain wiring into CafeFAdapter deferred to Phase D-N consolidation; SelectorChain ships as foundation primitive for NDH/Vietstock/VietnamBiz follow-on adapters").

**What this plan delivers**:
- `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` (NEW; ~250-300 LOC; subclasses `CrawlerAdapter` directly per Strategy A — no legacy code to wrap, unlike CafeF Strategy B)
- `packages/infrastructure/news/crawler_adapters/__init__.py` UPDATED to export `NDHAdapter` alongside existing `CafeFAdapter`
- `tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py` (NEW; ≥12 test cases; synthetic minimal HTML fixtures per AQ-9)
- `apps/cli/ingest_news_ndh.py` (NEW; ~250 LOC; mirrors `ingest_news_cafef.py` shape but dispatches NDHAdapter via fresh CrawlerRegistry)
- ADR amendment OR new ADR (depending on STEP 0 findings — see § L)
- Session log + observation file per CLAUDE.md § Session Protocol End steps
- ZERO charter / constitution / human-workspace writes
- ZERO new LLM-numeric schema fields (Rule 16 by construction)
- ZERO new hooks (mirror plan-020; product substrate not harness rule-enforcement)

## B. In-scope / Out-of-scope

### IN-scope (this bundle MUST ship)

- NDHAdapter class (greenfield; Strategy A direct subclass of CrawlerAdapter)
- `SelectorChain[T]` consumption in NDHAdapter's HTML parsing path (headline + body + publish_date are typical candidates; STEP 0.4 confirms which fields benefit most based on observed HTML structure)
- Unit tests with synthetic minimal HTML fixtures (≥12 cases)
- CLI smoke entry point at `apps/cli/ingest_news_ndh.py` mirroring CafeF CLI shape
- Registry wire: CLI constructs fresh `CrawlerRegistry()`, registers `NDHAdapter`, dispatches via `registry.get("ndh")`
- ADR amendment (D-066 § Out-of-scope item 12 closure) OR new D-067 if NDH usage surfaces contract gap
- Session log + observation file

### OUT-of-scope (DEFERRED — explicit non-goals)

- **Vietstock + VietnamBiz adapters** — deferred per plan-020 § E matrix to their own per-source FOCUSED_IMPL sessions (023-S346, 024-S347)
- **Harness/hook changes** — this is product substrate, NOT rule-enforcement; any harness anomalies surface in observation
- **Charter / constitution edits** — out of scope per CLAUDE.md hard rules
- **Async migration** — sync interface per D-066 § Async deferred to Phase 3 (unchanged)
- **R2 raw-HTML storage** — local filesystem under `data/raw/news/ndh/` (Phase 2 thin slice per D-066 § Storage)
- **Adaptive selector / Scrapling `Selector.relocate`** — deferred per plan-020 § Out-of-scope item 1 (long-term defense; SelectorChain fallback is short-term)
- **CafeFAdapter consolidation Strategy A migration** — RM12 carry-forward; separate future Phase D-N session
- **SelectorChain wiring into CafeFAdapter** — deferred per ADR D-066 § Out-of-scope item 12 (Strategy B WRAP preserves CafeFScraper BeautifulSoup parse path untouched; CafeF consolidation is its own session)
- **Live cafef.vn / ndh.vn HTTP smoke in CI** — fixture-driven tests only; one manual CLI smoke recorded in session log but not committed (per AQ-9 + skill § VBW)
- **`extract_claims` on CrawlerAdapter** — deferred to Theme I per D-066 § Out-of-scope item 8
- **Shape-metrics emit persistence** — deferred to Phase 3 calibration scaffolding per D-066 § Out-of-scope item 12
- **Promotion of `confidence_extracted` to mode #3 calibration-lookup wiring** — BC-6 KOL extractor work per D-066 § Out-of-scope item 13

---

## C. STEP 0 — VBW Live Verification (BLOCKING; mandatory)

The implementing session (S344) MUST run these sub-steps BEFORE writing any adapter code and write results into the session log. This plan was authored by a sandwich-architect subagent with Read/Glob/Grep/Write but NO Bash — STEP 0 is the empirical anchor that grounds plan recipes against the live NDH site.

**STOP-AND-ASK clause** (binding; see also § G AQ-5/AQ-6/AQ-7 for pre-answered escalation paths):
- If BOTH candidate URLs (`nhipsongdoanhnghiep.vn` AND `ndh.vn`) return 404 / DNS-no-resolve → STOP-AND-ASK (defer adapter; flag site-defunct; surface in mistake-log)
- If `/robots.txt` explicitly disallows crawl for `User-agent: *` or `User-agent: stockforge-research-bot` → STOP-AND-ASK (defer adapter; honor robots; flag in mistake-log per skill § Anti-Patterns)
- If ToS page (linked from site footer) forbids automated access → STOP-AND-ASK (defer adapter; flag in mistake-log)
- If site is fully JS-rendered (article body requires JavaScript execution to populate DOM) → STOP-AND-ASK (defer adapter; surface harness gap that I-S34 HARD REJECT of Playwright/patchright leaves us without a JS-rendering option; do NOT install patchright; do NOT silently bypass I-S34)
- If observed HTML structure is so different from expectation that the planned SelectorChain[T] shape cannot accommodate it → STOP-AND-REPLAN (surface as plan-022 finding; may require D-066 amendment for SelectorChain contract gap)

### Sub-step 0.1 — URL probe (verify which of two candidate hosts is canonical)

```bash
# Probe both candidate URLs (httpx with 10s timeout; record status code + redirect chain + final URL)
python -c "
import httpx
for host in ['nhipsongdoanhnghiep.vn', 'ndh.vn']:
    try:
        r = httpx.get(f'https://{host}', follow_redirects=True, timeout=10.0,
                      headers={'User-Agent': 'stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)'})
        print(f'{host}: status={r.status_code} final={r.url}')
    except Exception as e:
        print(f'{host}: ERROR {type(e).__name__}: {e}')
"
```

**Record in session log**: For each candidate URL, the observed (status code, final URL after redirects, response size in bytes). If exactly ONE URL is reachable, that's canonical. If BOTH reachable, pick the one with a more identifiable financial-news brand at the homepage (record decision rationale). If NEITHER reachable → STOP-AND-ASK.

### Sub-step 0.2 — robots.txt fetch + protego parse (BINDING per I-S34)

```bash
# On the verified host from Sub-step 0.1, fetch /robots.txt
python -c "
import httpx
from protego import Protego
url = 'https://VERIFIED_HOST/robots.txt'  # substitute from Sub-step 0.1
r = httpx.get(url, timeout=10.0)
print(f'status={r.status_code} bytes={len(r.text)}')
print('--- robots.txt body ---')
print(r.text[:2000])
print('--- protego rules for stockforge-research-bot ---')
parser = Protego.parse(r.text)
for path in ['/', '/news', '/article', '/thi-truong-chung-khoan']:
    print(f'  {path}: can_fetch={parser.can_fetch(path, \"stockforge-research-bot/0.0.1\")}')
print(f'crawl_delay for *: {parser.crawl_delay(\"*\")}')
"
```

**Record in session log**: robots.txt status code (200 = present; 404 = absent → per `RobotsTxtManager.can_fetch` default = permissive; per RM7); the verbatim disallow rules for `User-agent: *` and any specifically for `stockforge-research-bot`; the `Crawl-delay` directive if present (this may bump the planned 2.0s default to a higher value).

**Branch**:
- robots.txt present + User-agent: * is allowed root path → PROCEED (record in adapter docstring "robots.txt verified VERIFIED-DATE")
- robots.txt present + explicit disallow on relevant paths → STOP-AND-ASK
- robots.txt 404 (absent) → PROCEED per RobotsTxtManager default = permissive (RM7); still apply rate-limit + UA identification
- Crawl-delay > 2.0s → bump rate-limit to that value (mandatory; honor directive)

### Sub-step 0.3 — ToS page reading (qualitative; record verdict in session log)

Navigate from the verified site homepage to the footer; locate a "Terms of Service" / "Điều khoản sử dụng" / "Quyền tác giả" / "Pháp lý" link. Read the page (Vietnamese text; agent reads + translates inline). Look for clauses that explicitly prohibit:
- Automated access / scraping / bots
- Commercial use of content
- Bulk data extraction

**Record in session log**: ToS page URL + 1-paragraph summary of crawl-permissibility verdict + date of read. Per I-S34 charter line 110 ("News scrapers respect robots.txt + reasonable rate limits + identify user agent"), if ToS explicitly forbids automated access → STOP-AND-ASK (defer adapter; honor ToS even if robots.txt permits).

### Sub-step 0.4 — Sample article fetch + HTML structure analysis

```bash
# Fetch ONE sample article URL (find via homepage → click first headline → copy URL)
python -c "
import httpx
url = 'https://VERIFIED_HOST/SAMPLE_ARTICLE_URL'  # from manual navigation
r = httpx.get(url, timeout=10.0, headers={'User-Agent': 'stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)'})
print(f'status={r.status_code} bytes={len(r.text)} content-type={r.headers.get(\"content-type\")}')
# Check for JS-rendering markers
js_markers = ['<script type=\"application/json\" id=\"__NEXT_DATA__\"', '<div id=\"app\"></div>', 'window.__INITIAL_STATE__', 'data-react-helmet']
for m in js_markers:
    if m in r.text:
        print(f'  JS-marker DETECTED: {m}')
        break
else:
    print('  JS-marker check: PASS (static HTML — appears server-rendered)')
# Save sample for selector discovery
from pathlib import Path
Path('tmp/ndh_sample.html').write_text(r.text, encoding='utf-8')
print(f'sample saved to tmp/ndh_sample.html')
"
```

**Record in session log**: Status code, response size, JS-rendering markers detected (if any), content-type. Save sample HTML to a tmp/ location (NOT committed; for selector discovery only — recorded path in session log so reviewer can inspect).

**Then**, manually inspect the saved HTML to identify selector candidates for each field:
- **Headline (`title`)**: typical candidates — `<h1>`, `<h1 class="...">`, `<meta property="og:title">`, `<title>` (strip suffix); record ≥2 candidates in priority order
- **Body container**: typical candidates — `<div class="detail-content">`, `<div class="article-body">`, `<div class="content">`, `<article>`; record ≥3 candidates in priority order
- **Publish date**: typical candidates — `<meta property="article:published_time">`, `<meta name="pubdate">`, `<span class="date">`, `<time datetime="...">`; record ≥2 candidates + observed datetime format string
- **Author/byline** (optional; skip if not present): `<span class="author">`, `<meta name="author">`; record if found
- **Article URL pattern** (for `discover()`): observe what listing-page anchors look like; identify URL-suffix or path-prefix conventions (CafeF uses `.chn`; NDH likely differs)

**Branch**:
- Static HTML with identifiable selectors → PROCEED with SelectorChain[T] design per § D DD-4
- JS-marker detected + body container empty without JS → STOP-AND-ASK (per § G AQ-7 — I-S34 HARD REJECT of Playwright means we cannot proceed; surface harness gap; defer adapter)
- Mixed (some fields server-rendered, some require JS) → consider partial extraction: PROCEED only if title + body + URL are all server-rendered; defer publish_date to fallback (`datetime.now(UTC)` per existing CafeFScraper pattern at `cafef_scraper.py:126`)

### Sub-step 0.5 — Rule 16 compliance pre-flight (mirror plan-020 STEP 0.5)

```bash
# Confirm no new numeric fields are needed (NDHAdapter mirrors CafeFAdapter's Rule-16-by-construction posture)
grep -rn "float\|int\|Decimal" packages/contracts/events/news_article_ingested.py
grep -rn "float\|int\|Decimal" packages/domain/news/models/news_article.py
grep -rn "float\|int" packages/domain/news/value_objects/extractor_metadata.py
```

Expected: ZERO numeric fields on `NewsArticleIngested` (only str/datetime/tuple); ZERO numeric fields on `NewsArticle` (only str/datetime/tuple); `ExtractorMetadata.confidence_extracted: float` is the one numeric field — populated by LLM extractor downstream, NOT by crawler. NDHAdapter output = same `ScrapedArticle` dataclass + same `NewsArticle` promotion path — ZERO new numeric fields. Record in session log.

### Sub-step 0.6 — Verify primitives still consumable (mirror plan-020 STEP 0.4 spirit)

```bash
# Verify the 6 primitives shipped by plan-020 are still importable + bind correctly
python -c "
from packages.application.news.ports import CrawlerAdapter, CrawlerRegistry
from apps._shared.crawl.rate_limiter import RateLimiter, DomainState
from apps._shared.crawl.robots_manager import RobotsTxtManager
from apps._shared.crawl.raw_html_sink import RawHtmlSink
from apps._shared.crawl.selector_chain import SelectorChain
print('All 6 primitives importable')
# Verify SelectorChain[T] frozen-dataclass shape
import dataclasses
print(f'SelectorChain frozen={SelectorChain.__dataclass_params__.frozen}')
print(f'SelectorChain fields={[f.name for f in dataclasses.fields(SelectorChain)]}')
"
```

Expected: All imports succeed; SelectorChain is frozen; fields are `[strategies, label]`. If any import fails → STOP and reconcile against plan-020 close state.

### Sub-step 0.7 — Verify next-adapter source_id collision check

```bash
# Confirm 'ndh' source_id is not already registered (sanity check before authoring)
grep -rn "source_id" packages/infrastructure/news/crawler_adapters/
```

Expected: only `cafef_adapter.py` declares `source_id: ClassVar[str] = "cafef"`. No existing `ndh` registration. If a stray `ndh` source_id is found → STOP and reconcile.

### Sub-step 0.8 — Baseline regression floors (mirror plan-020 STEP 0.9)

```bash
bash scripts/hooks/firing-tests/run-all.sh 2>&1 | tail -5
bash scripts/hooks/bash-hook-lint.sh 2>&1 | tail -5
python -m pytest packages/ apps/ tests/ -q 2>&1 | tail -3
python -m mypy --strict packages/ apps/ 2>&1 | tail -5
python -m ruff check packages/ apps/ 2>&1 | tail -5
```

Write pre-IMPL pass/fail counts into session log. New modules + tests MUST add to (not regress) these baselines. Hooks already shipping (W0-2 through W0-5) cover the new modules automatically — STEP 0.8 records the baseline; DC-AGG-7 checks the delta.

### Sub-step 0.9 — Smoke-test the existing CafeF pipeline (regression floor)

```bash
# Confirm CafeFAdapter still works end-to-end with its fixture HTML (zero regression on plan-020 closure)
python -m pytest packages/infrastructure/news/crawler_adapters/test_cafef_adapter.py -q 2>&1 | tail -5
```

Expected: pre-existing CafeF test count passes. Record in session log as DC-AGG floor.

### Sub-step 0.10 — STEP 0 summary write into session log

After Sub-steps 0.1-0.9 complete, write a "STEP 0 Summary" section into the session log including:
- Canonical NDH host verified (from 0.1)
- robots.txt verdict (from 0.2)
- ToS verdict + URL + date (from 0.3)
- Identified selector candidates for headline/body/date (from 0.4)
- HTML structure assessment (static vs JS-rendered) (from 0.4)
- Final rate-limit decision (2.0s default OR bumped per Crawl-delay)
- Baseline regression counts (from 0.8)
- Any STOP-AND-ASK triggered: yes/no (if yes, halt and surface to main session)

---

## D. Architecture Decisions (DD-1 through DD-10)

### DD-1: Adapter class name = `NDHAdapter`

**Decision**: Class name `NDHAdapter` (capital N, capital D, capital H — matches "Nhịp Sống Doanh Nghiệp" / "Người Đồng Hành" Vietnamese brand initialism). Source_id = `"ndh"` (lowercase, consistent with `"cafef"`).

**Rationale**: Convention from CafeFAdapter at `packages/infrastructure/news/crawler_adapters/cafef_adapter.py:50-51`: `class CafeFAdapter(CrawlerAdapter): ... source_id: ClassVar[str] = "cafef"`. Class name uses brand-PascalCase; source_id is lowercase hash-key. No deviation justified.

**Adversarial alternate considered**: `NhipsongdoanhnghiepAdapter` (full name) → rejected (verbose; source_id `"nhipsongdoanhnghiep"` is unwieldy; future code-reference friction). `NhippsAdapter` (squashed) → rejected (ambiguous abbreviation).

### DD-2: Package path = `packages/infrastructure/news/crawler_adapters/ndh_adapter.py`

**Decision**: Live alongside `cafef_adapter.py` in the existing crawler_adapters subdirectory.

**Rationale**: Path convention established by plan-020 DD-1 + ADR D-066: "Concrete adapters live in packages/infrastructure/news/crawler_adapters/". Plan-020 closure left `__init__.py` exporting only `CafeFAdapter`; this plan extends export list with `NDHAdapter`.

### DD-3: Strategy A direct-subclass (NOT Strategy B WRAP)

**Decision**: NDHAdapter directly subclasses `CrawlerAdapter` (ABC) and implements `discover() / fetch_and_parse() / to_news_article()` from scratch. NO wrapping of any legacy class (there is no legacy NDH scraper to wrap — this is greenfield).

**Rationale**: Plan-020 § E matrix line 352 explicitly classifies NDH as "**A (crawl4ai-pattern; subclass `CrawlerAdapter` like CafeFAdapter)**". Strategy B WRAP was a CafeF-specific concession because `cafef_scraper.py` was pre-existing 213-LOC legacy code with proven date-parser; NDH has no such legacy. Strategy A is the canonical pattern for all future per-source adapters.

**Adversarial alternate considered**: Compose NDHAdapter from a fresh internal `_NDHScraper` helper class (mirror CafeF's wrap shape for symmetry) → rejected (unnecessary indirection; double-class maintenance from day 1; no behavioral benefit). Architect verdict: greenfield Strategy A = single coherent class.

### DD-4: SelectorChain[T] usage shape — three SelectorChain instances per article

**Decision**: NDHAdapter's `fetch_and_parse()` uses **three** `SelectorChain[Tag | None]` instances:
1. `_headline_chain` — extracts article headline (typical: `<h1>` → `<meta property="og:title">` → `<title>`)
2. `_body_chain` — extracts article body container (typical: `<div class="detail-content">` → `<div class="article-body">` → `<article>`)
3. `_publish_date_chain` — extracts publish date string for parsing (typical: `<meta property="article:published_time">` → `<meta name="pubdate">` → `<span class="date">`)

Plus the publish_date parsing itself uses a **fallback list of datetime format strings** mirroring `cafef_scraper.py:203` (`for fmt in ("%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%Y-%m-%d %H:%M:%S"): try strptime`). NOT a SelectorChain — that's a fmt-string chain inside the parser, not a DOM-selector chain. STEP 0.4 confirms NDH's observed format strings.

**Rationale**: Plan-020 F2 carry-forward + ADR D-066 § Out-of-scope item 12: "SelectorChain reserved for NDH/Vietstock/VietnamBiz follow-on adapters... Per S339 F2 finding (sandwich-verifier 2026-05-16)." This plan delivers that promise by making NDHAdapter the first consumer. Three chains cover the three text fields most prone to vendor drift; using SelectorChain (rather than CafeF's inline `or` chain at `cafef_scraper.py:117-120`) gains: (a) instrumentation — `apply()` returns `(result, num_strategies_tried)` for shape-metrics emit (deferred to Phase 3); (b) explicit `label` per chain for logging; (c) frozen dataclass = no accidental mutation.

**Contract verification** (from reading `apps/_shared/crawl/selector_chain.py:62-105`):
- `SelectorChain[T]` is `Generic[T]`, frozen, slots; fields = `(strategies: Sequence[Callable[[], T | None]], label: str = "(unnamed)")`
- `apply()` returns `tuple[T | None, int]`; logs WARNING if all strategies fail (skill doctrine: "partial output beats whole-pipeline halt")
- Strategies that raise are caught + debug-logged (do NOT propagate); chain continues to next strategy
- BeautifulSoup `Tag` is the typical T (since strategies often use `soup.find(...)` returning Tag | None)

**Selector strategy authoring**: each strategy is a `lambda: soup.find(...)` or `lambda: soup.select_one(...)` — captured at adapter `__post_init__` time after `soup = BeautifulSoup(html, "html.parser")` is parsed. NOTE: `SelectorChain` is constructed inside `fetch_and_parse(url)` per call (NOT cached on the adapter), because the `soup` reference inside each lambda closure must reference the current article's soup; SelectorChain itself is cheap (frozen dataclass with a Sequence + str).

**Adversarial alternate considered**: One SelectorChain per adapter declared at `__init__` time with selector strategies that take `soup` as an argument → rejected (SelectorChain's `Sequence[Callable[[], T | None]]` strategies are zero-arg by contract; reshaping to `Sequence[Callable[[BeautifulSoup], T | None]]` would require either D-066 amendment OR pre-currying with `functools.partial` per call — extra indirection without benefit). Architect verdict: construct SelectorChain inside `fetch_and_parse` with closure-over-soup; cheap (~10ns per dataclass instantiation per skill doctrine).

### DD-5: Rate-limit profile — 2.0s default; bump only if STEP 0.2 finds `Crawl-delay` > 2.0s

**Decision**: NDHAdapter constructs internal `RateLimiter(base_delay=2.0, max_delay=60.0, max_retries=5)` matching plan-020 § E matrix CafeF profile. **STEP 0.2 may override**: if robots.txt declares `Crawl-delay: N` where N > 2.0, dev bumps `base_delay=N` (mandatory; honor directive).

**Rationale**: Plan-020 § E matrix line 352 "Rate-limit (≥2s default)" + "2.0s default". RateLimiter primitive at `apps/_shared/crawl/rate_limiter.py:79-83` defaults `base_delay=2.0, max_delay=60.0, max_retries=5` — these are the recommended defaults. NDH is mainstream financial news (less aggressive than VietnamBiz which gets bumped to 3.0s per matrix line 354), so 2.0s is the prior.

**Adversarial alternate considered**: 3.0s conservative bump (mirror VietnamBiz proactively in case NDH has not been verified for ToS-leniency) → rejected for now (no evidence NDH is less lenient than CafeF; STEP 0 empirically verifies; if STEP 0 detects 429/503 during the sample fetch in Sub-step 0.4 → bump to 3.0s and flag for verifier). See RM5.

### DD-6: Robots-manager integration — optional injection with `can_fetch` check before each request

**Decision**: NDHAdapter accepts optional `robots_manager: object = None` constructor arg (mirror CafeFAdapter's pattern at `cafef_adapter.py:97-98`). When provided, the adapter's internal `rl_fetcher` / `plain_fetcher` calls `robots_manager.can_fetch(url)` BEFORE every HTTP fetch; on disallow → log WARNING + raise RuntimeError (so caller's loop logs + continues per L-S28-1 graceful-degrade doctrine).

**Rationale**: Mirror CafeFAdapter's proven pattern at `cafef_adapter.py:118-124, 162-166`. RobotsTxtManager primitive at `apps/_shared/crawl/robots_manager.py:119-136` provides `can_fetch(url) -> bool`; returns True on 404 (permissive default per RM7).

**Default behavior**: If `robots_manager=None`, adapter skips the check. CLI `ingest_news_ndh.py` wires a real RobotsTxtManager at construction time (mirror CLI pattern; production should always inject; tests may inject None for unit tests not concerned with robots).

### DD-7: RawHtmlSink integration — optional injection writes raw HTML BEFORE parsing

**Decision**: NDHAdapter accepts optional `raw_html_sink: object = None` constructor arg (mirror CafeFAdapter at `cafef_adapter.py:100-101`). When provided, adapter calls `raw_html_sink.write(source_id="ndh", url=url, html=html, fetched_at=self.clock())` BEFORE parsing (so raw HTML is preserved even if parse fails per skill § Storage doctrine).

**Rationale**: Mirror CafeFAdapter's pattern at `cafef_adapter.py:131-145` (rl_fetcher) and `:168-180` (plain_fetcher). RawHtmlSink primitive at `apps/_shared/crawl/raw_html_sink.py:69-121` enforces D-062 atomic write + D-064 path-safety + D-059 R1 tz-aware datetime requirement. Storage path = `data/raw/news/ndh/<YYYY-MM-DD>/<sha256(url)[:16]>.html` (sink derives from `source_id`).

**Default behavior**: If `raw_html_sink=None`, adapter skips write. CLI `ingest_news_ndh.py` wires a real RawHtmlSink at construction time.

### DD-8: User-agent string — reuse CafeF UA verbatim

**Decision**: Same UA as CafeF: `"stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"` (cited at `cafef_scraper.py:35-37` and the CLI fetcher at `apps/cli/ingest_news_cafef.py:60-62`).

**Rationale**: Plan-020 § E matrix line 352 explicitly says "Same UA as CafeF" for NDH. Charter I-S34 + skill § Anti-Patterns + skill § Do require "identify user agent" + reject "fake-useragent". The stockforge bot UA is the single canonical identity. Per-source UA differentiation has no benefit (the contact email is the operationally-useful field; identical UA across sources keeps the contact channel simple).

**Adversarial alternate considered**: Per-source UA differentiation `"stockforge-ndh-bot/0.0.1 ..."` → rejected (no benefit; identical-UA-with-shared-contact is operationally simpler). Per-source User-Agent string also leaks source-list to crawled sites (minor info-disclosure concern; the unified UA + contact email is plenty).

### DD-9: Error handling — retry budget = 5 attempts; circuit-open via RateLimiter; 429/503 retryable; other 4xx not retryable; 5xx retryable up to budget

**Decision**: Delegate retry + backoff to the injected `RateLimiter` per plan-020 DD-7. RateLimiter at `apps/_shared/crawl/rate_limiter.py:123-169` `report_response(domain, status_code)`:
- 429 or 503 → exponential backoff with jitter (×2 × random[0.75, 1.25], capped at max_delay); retries_so_far++; returns False (circuit-open) if `retries_so_far > max_retries`
- Any other code (including 5xx other than 503; including 200) → gradual decay (×0.75 toward base_delay); resets retries_so_far

**Other 4xx (400-499 except 429)**: NOT retryable (per skill § Retry & Backoff: "4xx other than 429 is NOT retryable (won't fix itself)"). Adapter's fetcher should let the underlying httpx `response.raise_for_status()` raise; the caller's per-URL loop catches + logs + continues (NDHAdapter's `fetch_and_parse` returns None on exception per L-S28-1; see `cafef_scraper.py:101-104, 107-110`).

**5xx other than 503**: per skill § Retry & Backoff retry-if `HTTPError, TimeoutException` is the canonical recipe; for this bundle, mirror CafeFAdapter's posture: let exceptions propagate from `fetcher`; per-URL `try/except` catches + logs + skips. (Tenacity decoration deferred to Phase 3 — see plan-020 DD-7 "Applied at the HTTP fetcher boundary"; this matches the current CafeFAdapter shape.)

**Circuit-open behavior**: If `RateLimiter.report_response` returns False, adapter MUST NOT continue fetching from that domain. CLI loop should detect this (via inspect of `rl.states[domain].retries_so_far > max_retries` OR a separate `circuit_open: bool` return path) and STOP the per-source loop for the rest of the session. For S344 thin slice: the simplest path is to log WARNING when fetcher reports failure + skip; circuit-open detection upgrade is a follow-up (mirror CafeFAdapter shape which currently doesn't surface circuit-open either — symmetric thin slice).

### DD-10: Test fixture strategy — SYNTHETIC minimal HTML committed to `tests/fixtures/ndh/`; ONE real HTML in CLI smoke recorded but NOT committed

**Decision**: Unit tests use SYNTHETIC minimal HTML strings (literal multi-line strings inline OR small `.html` files under `tests/fixtures/ndh/`). Production-realistic real HTML is fetched ONCE during CLI smoke (Sub-step 0.4 sample); recorded in session log but NOT committed to repo (per AQ-9 fixture-licensing rationale + skill § Anti-Patterns "Committing scraped data without source_url violates I-S2 citation rule").

**Rationale**:
- **Synthetic for unit tests**: per skill `.claude/skills/crawler-reliability/SKILL.md` § Anti-Patterns + per `test-pyramid-balance` skill (if exists; otherwise per DDD-tactical-patterns skill general guidance): unit tests use deterministic minimal fixtures to test parsing logic; fixtures should be small enough to fit in test file + cover edge cases (missing title; missing date; alternate body container class)
- **Re-distributing scraped HTML**: legal grey-zone per skill § Anti-Patterns ("Committing scraped data without `source_url` violates I-S2 citation rule"). Synthetic test HTML is ours to commit; real scraped HTML has unclear copyright posture. STEP 0.4 saves the real sample to `tmp/ndh_sample.html` (gitignored under `tmp/` if present, otherwise dev MUST add to local `.gitignore` and confirm in session log).
- **CLI smoke as the live-state verification**: one manual smoke (`python apps/cli/ingest_news_ndh.py --max-articles 1`) records: URL fetched, status code, bytes received, title extracted, body length, mentioned_tickers — recorded in session log as the empirical anchor. Verifier inspects + re-runs.

**Adversarial alternate considered**:
- All-real-HTML committed to `tests/fixtures/ndh/*.html` → rejected (fixture-licensing concern; fixtures drift as NDH redesigns site; harder to control edge cases)
- All-mocked httpx responses (use `pytest-httpx` or similar) → rejected (extra dep; over-engineered for what should be inline string fixtures; less readable than synthetic HTML)

---

## E. Sub-track decomposition (D1..D5)

### D1 — NDHAdapter implementation (greenfield Strategy A)

**Module**: `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` (NEW; ~250-300 LOC).

**Class shape** (architect-proposed; dev adjusts per STEP 0 findings):

```python
"""NDHAdapter — CrawlerAdapter implementation for NDH (Nhịp Sống Doanh Nghiệp / Người Đồng Hành).

Strategy A (direct-subclass) per plan-022 § DD-3.
First consumer of SelectorChain[T] per plan-022 § DD-4 (closes plan-020 F2 carry-forward
documented in ADR D-066 § Out-of-scope item 12).

I-S34 compliance:
    NO import or use of patchright, playwright_stealth, fake-useragent,
    StealthyFetcher, or any Scrapling Cloudflare-solver path.
    This adapter uses only httpx (via fetcher callable injection) — D-061 § item 4.

Rule 16 compliance:
    fetch_and_parse emits ScrapedArticle which has ZERO numeric fields
    (url/title/body_html/body_text/published_at — no float/Decimal beyond datetime).
    Rule 16 surface preserved by construction per plan-020 § Schema discipline.

Source: plan 022-S343-phase-d-ndh-adapter.md § Sub-track D1
        STEP 0 live verification recorded in session log session-344.md
        apps/_shared/crawl/selector_chain.py (SelectorChain[T] primitive)
        packages/infrastructure/news/crawler_adapters/cafef_adapter.py (sibling reference)
"""

from __future__ import annotations

import hashlib
import logging
from collections.abc import Callable, Iterable
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import ClassVar, cast

from apps._shared.crawl.selector_chain import SelectorChain
from packages.application.news.ports.crawler_adapter import CrawlerAdapter
from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle
# Reuse the existing ScrapedArticle dataclass from cafef_scraper to avoid schema duplication;
# rationale per plan-022 § D1 — both adapters emit the same shape; future ADR amendment
# may promote ScrapedArticle to a shared module (out-of-scope this bundle).
from packages.infrastructure.news.cafef_scraper import ScrapedArticle

__all__ = ["NDHAdapter"]

_log = logging.getLogger(__name__)

_DEFAULT_NDH_BASE_URL = "https://VERIFIED_HOST"  # FILLED by dev from STEP 0.1
_DEFAULT_USER_AGENT = (
    "stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"
)
_DEFAULT_RATE_LIMIT_SECONDS = 2.0  # STEP 0.2 may bump per Crawl-delay directive


@dataclass
class NDHAdapter(CrawlerAdapter):
    """CrawlerAdapter implementation for NDH (BC-5 News Stream).

    Strategy A (direct-subclass): implements discover / fetch_and_parse /
    to_news_article from scratch using SelectorChain[T] for body / title /
    date extraction. Uses BeautifulSoup for parsing (matches CafeFScraper).

    Greenfield — no legacy class to wrap.

    Default construction::

        adapter = NDHAdapter(fetcher=_httpx_fetcher)

    With full injections::

        adapter = NDHAdapter(
            fetcher=_httpx_fetcher,
            rate_limiter=RateLimiter(base_delay=2.0),
            robots_manager=RobotsTxtManager(fetcher=robots_fetcher),
            raw_html_sink=RawHtmlSink(base_dir=Path("data/raw/news")),
            clock=lambda: datetime.now(UTC),
        )
    """

    source_id: ClassVar[str] = "ndh"

    fetcher: Callable[[str], str]
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    rate_limiter: object = field(default=None)  # RateLimiter | None
    robots_manager: object = field(default=None)  # RobotsTxtManager | None
    raw_html_sink: object = field(default=None)  # RawHtmlSink | None
    base_url: str = _DEFAULT_NDH_BASE_URL
    rate_limit_seconds: float = _DEFAULT_RATE_LIMIT_SECONDS

    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from an NDH listing page.

        listing_path is e.g. ``/thi-truong-chung-khoan`` (STEP 0 confirms convention).
        Discovers anchors matching NDH URL pattern (STEP 0 confirms suffix/path);
        returns absolute URLs deduplicated, capped at max_articles.
        """
        from bs4 import BeautifulSoup

        html = self._fetch_with_optional_chain(self._absolute(listing_path))
        soup = BeautifulSoup(html, "html.parser")
        urls: list[str] = []
        seen: set[str] = set()
        for anchor in soup.find_all("a", href=True):
            href = cast(str, anchor["href"])
            # NDH URL pattern: STEP 0.4 confirms — FILLED by dev (e.g. ends with ".html"
            # or starts with "/post-" or has UUID in path). Defensive fallback: any
            # anchor under listing-page that points to same host + ends with ".html"
            # OR any link whose path matches NDH article convention.
            if not self._is_article_url(href):
                continue
            absolute = self._absolute(href)
            if absolute in seen:
                continue
            seen.add(absolute)
            urls.append(absolute)
            if len(urls) >= max_articles:
                break
        return urls

    def fetch_and_parse(self, url: str) -> ScrapedArticle | None:
        """Fetch + parse a single NDH article URL.

        Per L-S28-1 vendor-drift doctrine: returns None on parse failure (degrade gracefully).
        Raises on network failure (caller's per-URL try/except logs + continues).
        """
        from bs4 import BeautifulSoup, Tag

        try:
            html = self._fetch_with_optional_chain(url)
        except Exception:
            return None

        soup = BeautifulSoup(html, "html.parser")

        # SelectorChain[T] for headline (DD-4)
        headline_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("h1", class_="article-title"),  # STEP 0.4 confirms
                lambda: soup.find("h1"),  # generic fallback
                lambda: soup.find("meta", attrs={"property": "og:title"}),
            ],
            label="ndh_headline",
        )
        headline_tag, _ = headline_chain.apply()
        if headline_tag is None:
            _log.warning("ndh_adapter: no headline found for url=%r", url)
            return None
        title = (
            cast(str, headline_tag.get("content"))
            if isinstance(headline_tag, Tag) and headline_tag.name == "meta"
            else headline_tag.get_text(strip=True)
        )
        if not title:
            return None

        # SelectorChain[T] for body container (DD-4)
        body_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("div", class_="detail-content"),
                lambda: soup.find("div", class_="article-body"),
                lambda: soup.find("div", class_="content"),
                lambda: soup.find("article"),
            ],
            label="ndh_body_container",
        )
        body_container, _ = body_chain.apply()
        if body_container is None:
            return None
        body_text = body_container.get_text(separator="\n", strip=True)
        if not body_text:
            return None

        # SelectorChain[T] for publish_date container (DD-4) + fmt-string fallback list
        published_at = self._parse_published_at(soup) or self.clock()

        return ScrapedArticle(
            url=url,
            title=title,
            body_html=str(body_container),
            body_text=body_text,
            published_at=published_at,
        )

    def to_news_article(
        self,
        scraped: ScrapedArticle,
        ticker_universe: Iterable[Ticker],
        excerpt_chars: int = 4000,
    ) -> NewsArticle:
        """Promote ScrapedArticle to NewsArticle with coarse ticker mention scan.

        Mirrors CafeFScraper.to_news_article (cafef_scraper.py:135-160) — coarse
        case-sensitive symbol scan over title + body_text.
        """
        haystack = f"{scraped.title}\n{scraped.body_text}"
        mentioned = tuple(t for t in ticker_universe if t.symbol in haystack)
        article_id = hashlib.sha256(scraped.url.encode("utf-8")).hexdigest()[:16]
        return NewsArticle(
            article_id=article_id,
            source="ndh",
            source_url=scraped.url,
            title=scraped.title,
            body_excerpt=scraped.body_text[:excerpt_chars],
            published_at=scraped.published_at,
            ingested_at=self.clock(),
            mentioned_tickers=mentioned,
            language="vi",
        )

    # ------ Private helpers ------

    def _fetch_with_optional_chain(self, url: str) -> str:
        """Fetch with rate-limit + robots-check + raw-html-sink chain (all optional)."""
        rl = self.rate_limiter
        if rl is not None and hasattr(rl, "wait_if_needed"):
            rl.wait_if_needed(url)
        rm = self.robots_manager
        if rm is not None and hasattr(rm, "can_fetch") and not rm.can_fetch(url):
            _log.warning("ndh_adapter: robots.txt disallows url=%r — skipping", url)
            raise RuntimeError(f"robots.txt disallows {url!r}")
        html = self.fetcher(url)
        if rl is not None and hasattr(rl, "report_response"):
            rl.report_response(url, 200)
        rhs = self.raw_html_sink
        if rhs is not None and hasattr(rhs, "write"):
            try:
                rhs.write(
                    source_id=self.source_id,
                    url=url,
                    html=html,
                    fetched_at=self.clock(),
                )
            except Exception as exc:
                _log.warning(
                    "ndh_adapter: raw_html_sink.write failed for url=%r: %s",
                    url, exc,
                )
        return html

    def _absolute(self, href: str) -> str:
        if href.startswith("http://") or href.startswith("https://"):
            return href
        if href.startswith("/"):
            return f"{self.base_url}{href}"
        return f"{self.base_url}/{href}"

    @staticmethod
    def _is_article_url(href: str) -> bool:
        """STEP 0.4 confirms NDH article URL pattern; dev FILLS this method.

        Likely patterns (verify at STEP 0):
        - ends with ".html"
        - matches /YYYY/MM/DD/slug/
        - starts with /post-
        """
        # PLACEHOLDER — dev fills per STEP 0.4 observation
        return href.endswith(".html") or "/post-" in href

    def _parse_published_at(self, soup: object) -> datetime | None:
        """Best-effort publish-date parse using fmt-string fallback list (DD-4).

        Returns None when no recognized tag/format matches; caller falls back to clock().
        Mirror CafeFScraper._parse_published_at (cafef_scraper.py:178-208).
        """
        from bs4 import BeautifulSoup, Tag

        if not isinstance(soup, BeautifulSoup):
            return None
        # STEP 0.4 confirms NDH publish-date tag candidates; dev FILLS this list
        for tag_name, attr_key, attr_value in (
            ("meta", "property", "article:published_time"),
            ("meta", "name", "pubdate"),
            ("span", "class", "date"),
            ("time", "datetime", None),  # any <time datetime="..."> tag
        ):
            if attr_value is None:
                tag = soup.find(tag_name, attrs={attr_key: True})
            else:
                tag = soup.find(tag_name, {attr_key: attr_value})
            if not isinstance(tag, Tag):
                continue
            text = (
                cast(str, tag.get("content"))
                if tag.name == "meta"
                else cast(str, tag.get("datetime") or tag.get_text(strip=True))
            )
            if not text:
                continue
            # STEP 0.4 confirms NDH datetime formats; dev FILLS this list
            for fmt in (
                "%Y-%m-%dT%H:%M:%S%z",
                "%Y-%m-%dT%H:%M:%S",
                "%d-%m-%Y %H:%M:%S",
                "%d-%m-%Y %H:%M",
                "%Y-%m-%d %H:%M:%S",
            ):
                try:
                    parsed = datetime.strptime(text, fmt)
                    return parsed if parsed.tzinfo else parsed.replace(tzinfo=UTC)
                except ValueError:
                    continue
        return None
```

**Note on `ScrapedArticle` re-use**: The above imports `ScrapedArticle` from `packages.infrastructure.news.cafef_scraper`. This is a pragmatic choice — both adapters emit identical shape (`url, title, body_html, body_text, published_at`). A cleaner long-term path is to promote `ScrapedArticle` to `packages/contracts/scraped_article.py` (out-of-scope this bundle; document as carry-forward). Dev MAY surface this as a clean-up opportunity in observation; no code change required this bundle.

**Pattern statement**: Strategy A direct-subclass; uses `SelectorChain[T]` per chain × 3 (headline, body, publish_date) + fmt-string chain inside `_parse_published_at`; reuses `_fetch_with_optional_chain` pattern from CafeFAdapter `:113-146` for rate-limit + robots + raw-html-sink.

### D2 — HTML parser internals (selector authoring per STEP 0 findings)

After STEP 0.4 completes, dev fills in the actual selector lists at:
- `_headline_chain.strategies` — replace placeholder lambdas with verified selectors
- `_body_chain.strategies` — same
- `_publish_date_chain` (NOT a SelectorChain — embedded in `_parse_published_at` as fmt-string chain)
- `_is_article_url(href)` — replace placeholder with verified URL pattern
- `_DEFAULT_NDH_BASE_URL` — replace placeholder `"https://VERIFIED_HOST"` with verified canonical host
- format strings in `_parse_published_at` — replace placeholder list with verified NDH date formats

**Document each replacement in code comments**: `# STEP 0.4 verified 2026-05-XX: <observation>` — gives the verifier audit-trail.

### D3 — Unit tests (≥12 test cases)

**Module**: `tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py` (NEW; ~300-400 LOC).

**Test cases (target ≥12)**:

1. `test_ndh_adapter_declares_source_id` — `NDHAdapter.source_id == "ndh"`
2. `test_ndh_adapter_can_be_registered` — fresh `CrawlerRegistry()`; `registry.register(NDHAdapter(fetcher=lambda _: ""))` succeeds; `registry.get("ndh") is adapter`
3. `test_supports_source_id_positive` — `NDHAdapter.source_id` matches the registered ID per D-066 contract (sanity)
4. `test_discover_returns_expected_urls_from_fixture` — synthetic listing HTML with 3 known article anchors; `discover("/listing", max_articles=10)` returns those 3 absolute URLs in order (deduped)
5. `test_discover_respects_max_articles_cap` — synthetic listing with 10 anchors; `discover(..., max_articles=3)` returns exactly 3
6. `test_discover_dedupes_repeat_anchors` — synthetic listing with same URL appearing 5×; returns 1 entry
7. `test_fetch_and_parse_happy_path` — synthetic article HTML matching expected NDH structure; `fetch_and_parse(url)` returns `ScrapedArticle` with correct title + body + published_at
8. `test_fetch_and_parse_returns_none_on_missing_title` — synthetic HTML missing both `<h1>` and `<meta og:title>`; returns None
9. `test_fetch_and_parse_returns_none_on_missing_body_container` — synthetic HTML with title but no body container; returns None
10. `test_fetch_and_parse_falls_back_to_clock_when_no_published_date` — synthetic HTML with title + body but no date tag; published_at == frozen clock value
11. `test_fetch_and_parse_returns_none_on_http_error` — fetcher raises `httpx.HTTPError`; `fetch_and_parse` catches + returns None per L-S28-1
12. `test_fetch_and_parse_uses_selector_chain_fallback` — synthetic HTML where the FIRST headline strategy fails (no `<h1 class="article-title">`) but the SECOND succeeds (`<h1>`); `fetch_and_parse` returns article with correct title; verify warning logged for body chain test
13. `test_fetch_and_parse_returns_none_when_all_body_selectors_fail` — synthetic HTML with title but no recognized body container; verify SelectorChain WARNING is logged + returns None
14. `test_to_news_article_populates_mentioned_tickers` — `ScrapedArticle` with title mentioning "VHM" and body mentioning "FPT"; `to_news_article(scraped, [Ticker("VHM"), Ticker("FPT"), Ticker("HPG")])` returns `NewsArticle.mentioned_tickers == (Ticker("VHM"), Ticker("FPT"))`
15. `test_to_news_article_excerpt_caps_at_excerpt_chars` — `ScrapedArticle.body_text` = 10000 chars; result `body_excerpt` len == 4000 (default)
16. `test_adapter_uses_injected_rate_limiter` — Mock RateLimiter; assert `wait_if_needed` + `report_response` called once each per fetch
17. `test_adapter_skips_url_when_robots_disallows` — Mock RobotsTxtManager returning `can_fetch=False`; `fetch_and_parse(url)` raises RuntimeError (caught internally → returns None)
18. `test_adapter_writes_raw_html_when_sink_provided` — Mock RawHtmlSink; assert `.write()` called with correct args (source_id="ndh", url, html, fetched_at tz-aware)
19. `test_adapter_default_no_injections_still_works` — `NDHAdapter(fetcher=lambda _: SYNTHETIC_HTML)` — no rate_limiter/robots/sink; `fetch_and_parse` still returns ScrapedArticle
20. `test_subclass_missing_source_id_raises_at_class_creation` — sanity test that confirms D-066 contract enforcement; dynamically construct `type("BadAdapter", (CrawlerAdapter,), {"discover": ..., "fetch_and_parse": ..., "to_news_article": ...})` without source_id → expect TypeError per `__init_subclass__`

**Minimum acceptance**: ≥12 of the above 20 (architect proposes 12 as floor; dev may ship all 20 if budget permits).

**Synthetic fixture HTML** (architect proposes; dev refines per STEP 0.4):

```python
# tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py (fragment)
_SYNTHETIC_NDH_ARTICLE_HTML = """<!DOCTYPE html>
<html>
<head>
  <meta property="og:title" content="VHM dự kiến đạt lợi nhuận quý 1 ổn định" />
  <meta property="article:published_time" content="2026-05-15T10:30:00+0700" />
</head>
<body>
  <h1 class="article-title">VHM dự kiến đạt lợi nhuận quý 1 ổn định</h1>
  <div class="detail-content">
    <p>Công ty cổ phần Vinhomes (VHM) công bố kết quả kinh doanh quý 1...</p>
    <p>FPT cũng được kỳ vọng có tăng trưởng tích cực.</p>
  </div>
</body>
</html>
"""

_SYNTHETIC_NDH_LISTING_HTML = """<!DOCTYPE html>
<html><body>
  <a href="/vhm-loi-nhuan-quy-1.html">VHM Q1</a>
  <a href="/fpt-tang-truong.html">FPT growth</a>
  <a href="/hpg-quan-su.html">HPG news</a>
  <a href="/vhm-loi-nhuan-quy-1.html">VHM Q1 (duplicate)</a>
  <a href="/about-us">About</a>
</body></html>
"""
```

### D4 — Registry wire + CLI smoke

**Module 1**: `packages/infrastructure/news/crawler_adapters/__init__.py` UPDATED:

```python
"""BC-5 News infrastructure — per-source crawler adapters."""

from .cafef_adapter import CafeFAdapter
from .ndh_adapter import NDHAdapter

__all__ = ["CafeFAdapter", "NDHAdapter"]
```

**Module 2**: `apps/cli/ingest_news_ndh.py` (NEW; ~250 LOC). Mirror `apps/cli/ingest_news_cafef.py` structure:
- click CLI with same flags (`--tickers`, `--since`, `--max-articles`, `--listing`, `--output`, `--skip-llm`, `--summary`)
- `_httpx_fetcher` helper with same UA pattern
- `_robots_fetcher` helper for RobotsTxtManager
- `main()` constructs:
  - `httpx_fetcher = _httpx_fetcher` (closure)
  - `rate_limiter = RateLimiter(base_delay=DD-5-value, max_delay=60.0, max_retries=5)`
  - `robots = RobotsTxtManager(fetcher=_robots_fetcher)`
  - `sink = RawHtmlSink(base_dir=Path("data/raw/news"))`
  - `registry = CrawlerRegistry()`
  - `registry.register(NDHAdapter(fetcher=httpx_fetcher, rate_limiter=rate_limiter, robots_manager=robots, raw_html_sink=sink))`
  - `adapter = registry.get("ndh")`
  - per-URL loop: `for url in adapter.discover(listing): scraped = adapter.fetch_and_parse(url); article = adapter.to_news_article(scraped, universe); ...`
- Persist via existing `SqliteNewsRepository` + `SqliteClaimRepository`
- LLM extraction via existing `ClaudeLlmExtractor` + `ClaimExtractionService` (UNLESS `--skip-llm`)
- Emit `NewsArticleIngested` + `ExtractedClaimPublished` events (UNLESS `--skip-llm`)
- Exit code 0 on success; click `UsageError` on invalid input
- Summary markdown output (sentiment counts + first 5 articles)

**CLI smoke (live verification — manual; recorded in session log)**:

```bash
# Manual smoke — 1 article fetch with full chain (rate-limit + robots + raw-html-sink + parser)
python apps/cli/ingest_news_ndh.py \
  --tickers VHM,FPT,HPG \
  --max-articles 1 \
  --listing /thi-truong-chung-khoan \
  --output ./data/tmp-ndh-smoke.sqlite \
  --skip-llm \
  --summary 2>&1 | tee /tmp/ndh-smoke.log
```

Record in session log:
- Status codes observed (200 expected; any 4xx/5xx flagged)
- Bytes fetched per request
- Total wall-clock time (validates rate-limit honored)
- Number of articles successfully parsed
- Verify `data/raw/news/ndh/<date>/<hash>.html` exists with expected content
- Verify SQLite contains 1 NewsArticle row with source="ndh"
- Verify `--summary` output matches expected markdown shape

### D5 — Documentation (ADR amendment OR new ADR; session log; observation file)

**Two paths depending on STEP 0 findings**:

#### Path A — D-066 amendment only (preferred; expected default)

Add an **Amendments** section entry to `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md`:

```markdown
### REV-1 (2026-05-XX) — SelectorChain[T] consumption confirmed; § Out-of-scope item 12 CLOSED

- **Trigger**: plan-022-S343 ships NDHAdapter as first greenfield Strategy A subclass + first SelectorChain[T] consumer
- **Authorization**: plan-022 § L (architect-proposed) + S345 verifier acceptance
- **Source artifacts**:
  - agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md § DD-4 + § D1
  - packages/infrastructure/news/crawler_adapters/ndh_adapter.py (NEW; uses 3 SelectorChain[T] instances)
  - tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py (NEW; ≥12 test cases including SelectorChain fallback coverage)
- **Summary of changes**:
  - § Out-of-scope item 12: status updated from PENDING-CONSUMER to ANSWERED; first consumer = NDHAdapter (S344 IMPL)
  - SelectorChain[T] contract validated by production usage; no contract gap detected (architect verdict; subject to verifier S345 re-confirmation)
  - SelectorChain[T] wiring into CafeFAdapter remains DEFERRED to CafeFScraper consolidation (RM12); the primitive's status as "shipped un-consumed infra" (per S339 verifier F2) is now obsolete
```

#### Path B — New D-067 (only if NDH usage reveals contract gap)

If during D1 IMPL dev finds a contract issue with `SelectorChain[T]` (e.g., zero-arg `Callable[[], T | None]` shape is wrong for NDH layout; or `frozen=True` blocks a needed mutation; or per-call construction is too expensive empirically; or generic type T can't be inferred correctly across BS4 + str cases), DO NOT silently bypass. Instead:
1. STOP and write a `STOP-FINDING.md` in `agent-workspace/notifications/`
2. Author new ADR `agent-workspace/memory/decisions/067-selectorchain-contract-amendment.md` (PROPOSED at IMPL tier; mirror D-066 12-field schema)
3. Decide chosen amendment shape
4. Surface to verifier S345 for review
5. Continue IMPL with amended SelectorChain

**Architect prediction**: Path A is the expected default (the SelectorChain[T] contract is well-formed per architect review of `apps/_shared/crawl/selector_chain.py:33-105`; the closure-over-soup pattern in DD-4 fits the zero-arg `Callable[[], T | None]` contract cleanly).

**Session log**: `agent-workspace/memory/sessions/2026-05-XX-session-344.md` per CLAUDE.md § Session Protocol End — captures:
- STEP 0 sub-step results (canonical host, robots.txt verdict, ToS verdict, selector candidates, baseline regression counts)
- D1-D4 outcomes (LOC counts, test counts, smoke results)
- Strategy: Strategy A direct-subclass executed
- SelectorChain[T] consumption verified
- ADR path taken (A or B)
- Mistakes (if any) → M-S344-N entries OR explicit "no mistakes this session"
- Any harness gaps surfaced (do NOT fix; just flag)

**Observation file**: `agent-workspace/memory/observations/sandwich-dev-S344-ndh-adapter.md` — dev's return artifact per Track 6.

---

## F. DoD checklist (≥30 items)

Aggregated across all 5 sub-tracks; verifier S345 confirms each empirically:

### File-existence DC (DC-FILE-N)

- [ ] **DC-FILE-1** — `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` exists
- [ ] **DC-FILE-2** — `packages/infrastructure/news/crawler_adapters/__init__.py` exports `NDHAdapter` alongside `CafeFAdapter`
- [ ] **DC-FILE-3** — `tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py` exists OR `packages/infrastructure/news/crawler_adapters/test_ndh_adapter.py` (dev picks per existing test-layout convention; verify via `find . -name "test_ndh_adapter.py"`)
- [ ] **DC-FILE-4** — `apps/cli/ingest_news_ndh.py` exists
- [ ] **DC-FILE-5** — Either ADR D-066 § Amendments has new REV-1 entry (Path A) OR `agent-workspace/memory/decisions/067-selectorchain-contract-amendment.md` exists (Path B)
- [ ] **DC-FILE-6** — `agent-workspace/memory/sessions/2026-05-XX-session-344.md` exists
- [ ] **DC-FILE-7** — `agent-workspace/memory/observations/sandwich-dev-S344-ndh-adapter.md` exists
- [ ] **DC-FILE-8** — `data/raw/news/ndh/<YYYY-MM-DD>/<hash>.html` exists (proves CLI smoke wrote raw HTML; recorded in session log)

### LOC + structure DC (DC-LOC-N)

- [ ] **DC-LOC-1** — `ndh_adapter.py` LOC is between 200 and 350 (architect estimate; dev reports actual)
- [ ] **DC-LOC-2** — Test file LOC is between 250 and 500 (≥12 test cases per architect floor)
- [ ] **DC-LOC-3** — CLI LOC is between 200 and 350 (mirrors `ingest_news_cafef.py` 318 LOC)

### NDHAdapter contract DC (DC-IMPL-N)

- [ ] **DC-IMPL-1** — `NDHAdapter.source_id == "ndh"` (ClassVar; non-empty)
- [ ] **DC-IMPL-2** — `NDHAdapter` subclasses `CrawlerAdapter` (NOT wraps; Strategy A direct-subclass per DD-3)
- [ ] **DC-IMPL-3** — `NDHAdapter` implements all 3 abstract methods: `discover`, `fetch_and_parse`, `to_news_article`
- [ ] **DC-IMPL-4** — `NDHAdapter.fetch_and_parse` uses ≥2 `SelectorChain[T]` instances (DD-4; for headline + body at minimum; publish_date may use fmt-string fallback instead)
- [ ] **DC-IMPL-5** — `NDHAdapter` accepts optional injections: `rate_limiter`, `robots_manager`, `raw_html_sink` (all default None; mirrors CafeFAdapter shape)
- [ ] **DC-IMPL-6** — `NDHAdapter` uses verified UA `"stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"` (DD-8; via the injected fetcher; no hardcoded UA inside adapter)

### I-S34 + Rule 16 compliance DC (DC-COMPLIANCE-N)

- [ ] **DC-COMPLIANCE-1** — `grep -rE "patchright|playwright_stealth|playwright-stealth|fake[-_]useragent|UndetectedAdapter|StealthyFetcher|_cloudflare_solver" packages/infrastructure/news/crawler_adapters/ndh_adapter.py apps/cli/ingest_news_ndh.py tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py` returns ZERO matches (I-S34 HARD REJECT verification)
- [ ] **DC-COMPLIANCE-2** — `NDHAdapter.fetch_and_parse` emits `ScrapedArticle` with ZERO new numeric fields (Rule 16 by construction; mirror plan-020 § Schema discipline)
- [ ] **DC-COMPLIANCE-3** — robots.txt verdict from STEP 0.2 documented in session log; verifier re-runs the protego check
- [ ] **DC-COMPLIANCE-4** — Rate-limit profile (2.0s default OR bumped per Crawl-delay) documented in session log + reflected in CLI construction
- [ ] **DC-COMPLIANCE-5** — UA string verified verbatim in CLI fetcher (`_httpx_fetcher` header) AND in adapter docstring reference (no per-adapter UA override)

### Deterministic gates DC (DC-GATE-N)

- [ ] **DC-GATE-1** — `python -m mypy --strict packages/infrastructure/news/crawler_adapters/ apps/cli/ingest_news_ndh.py tests/infrastructure/news/crawler_adapters/` exits 0
- [ ] **DC-GATE-2** — `python -m ruff check packages/infrastructure/news/crawler_adapters/ apps/cli/ingest_news_ndh.py tests/infrastructure/news/crawler_adapters/` exits 0
- [ ] **DC-GATE-3** — `python -m pytest tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py -q` exits 0; ≥12 new test cases pass
- [ ] **DC-GATE-4** — `python -m pytest packages/ apps/ tests/ -q` exits 0; new test count = STEP 0.8 baseline + ≥12; ZERO regression on baseline
- [ ] **DC-GATE-5** — `bash scripts/hooks/firing-tests/run-all.sh` exits 0 (no firing-test regression; no new firing-tests this bundle per plan-020 precedent — product substrate not hook)
- [ ] **DC-GATE-6** — `bash scripts/hooks/python-determinism-check.sh </dev/null` exits 0 on NDH new modules (D-059 R1/R2/R4 compliance)
- [ ] **DC-GATE-7** — `bash scripts/hooks/atomic-write-check.sh </dev/null` exits 0 on NDH new modules (D-062 — only matters if NDH writes; RawHtmlSink already wraps atomic)
- [ ] **DC-GATE-8** — `bash scripts/hooks/path-safety-check.sh </dev/null` exits 0 on NDH new modules (D-064 — only matters if NDH paths; RawHtmlSink already uses safe_path)

### CLI smoke DC (DC-SMOKE-N)

- [ ] **DC-SMOKE-1** — Manual CLI smoke `python apps/cli/ingest_news_ndh.py --max-articles 1 --skip-llm --summary` executed; recorded in session log with timestamp + status code + bytes fetched + parsed-article count
- [ ] **DC-SMOKE-2** — Smoke produced ≥1 row in `data/tmp-ndh-smoke.sqlite` (or chosen output path) with `source="ndh"`
- [ ] **DC-SMOKE-3** — Raw HTML file exists at `data/raw/news/ndh/<YYYY-MM-DD>/<hash>.html` per DC-FILE-8
- [ ] **DC-SMOKE-4** — Wall-clock time of smoke ≥ rate_limit_seconds × N_requests (validates RateLimiter honored)

### Bookkeeping DC (DC-BOOK-N)

- [ ] **DC-BOOK-1** — Session log `2026-05-XX-session-344.md` written per CLAUDE.md § Session Protocol End
- [ ] **DC-BOOK-2** — `agent-workspace/memory/current-execution.md` updated: Phase D Theme L per-source rollout row reflects S344 NDH-adapter SHIPPED; next-action = S345 sandwich-verifier dispatch
- [ ] **DC-BOOK-3** — `agent-workspace/memory/mistake-log.md` either appended (M-S344-N if mistakes) OR session log explicitly states "no mistakes this session" (enforced by `session-end-checklist-linter.sh` Stop hook)
- [ ] **DC-BOOK-4** — Plan moved `pending/022-S343-phase-d-ndh-adapter.md` → `completed/022-S343-phase-d-ndh-adapter.md` at S345 close (NOT at S344 close — verifier acceptance gates the move)
- [ ] **DC-BOOK-5** — D-066 § Out-of-scope item 12 status updated (Path A REV-1 amendment) OR D-067 PROPOSED (Path B)
- [ ] **DC-BOOK-6** — Observation file `sandwich-dev-S344-ndh-adapter.md` written per Track 6 spec

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why Strategy A direct-subclass, not Strategy B WRAP?

**Answer**: No existing NDH scraper code exists to wrap. CafeFAdapter chose Strategy B because `cafef_scraper.py` was pre-existing 213-LOC legacy with proven date-parser; preserving that meant minimal-diff WRAP. NDH is greenfield — no legacy. Strategy A is the canonical pattern for greenfield adapters per plan-020 § E matrix line 352 ("subclass `CrawlerAdapter` like CafeFAdapter"). Architect verdict: greenfield Strategy A = single coherent class; future per-source adapters (Vietstock, VietnamBiz) follow same pattern.

### AQ-2 — Why SelectorChain[T] consumption now (vs deferring further)?

**Answer**: Plan-020 F2 carry-forward (sandwich-verifier S339 PASS-WITH-CONCERNS finding 2026-05-16) explicitly flagged SelectorChain as "shipped but un-consumed infra" and D-066 § Out-of-scope item 12 documented the deferral. The first greenfield adapter is the natural first consumer (no legacy `or` chain to migrate; clean canvas to use the primitive as designed). Deferring further leaves SelectorChain in limbo (shipped infra, no usage = dead code risk; D-066 § Out-of-scope reads "deferred to NDH/Vietstock/VietnamBiz follow-on adapters"). This plan delivers on that promise.

### AQ-3 — Why subclass not Protocol/ABC composition?

**Answer**: Per D-066 § Decision (line 137-159) — CrawlerAdapter is ABC; subclass enforces `__init_subclass__` guard that runs at class-definition time (verifying non-empty `source_id` ClassVar). Protocol can't enforce at definition time (static-only; doesn't fire on subclass creation). The ABC + `__init_subclass__` pattern fails fast at class-creation rather than at instantiation or first use. This is a documented convention exception (plan-020 DD-3 + ADR D-066 § "Why ABC not Protocol"). Architect verdict: NDHAdapter MUST subclass CrawlerAdapter directly to inherit the contract enforcement.

### AQ-4 — Why not also do Vietstock + VietnamBiz in same plan (one-shot all three)?

**Answer**: RM4 from plan-020 § Risk table (which traces to S4 catastrophic-mix-pattern). Each per-source adapter requires its own STEP 0 live verification (URL probe + robots.txt + ToS read + sample HTML structure analysis); bundling 3 sources triples STEP 0 work + adds 3 separate HTML-fixture authoring efforts + 3 separate CLI files + 3 separate ADR amendments. Per master plan § 6.4 per-source FOCUSED_IMPL budget envelope of 60-100K per source, 3 sources = 180-300K which exceeds 250K hard_cap. Architect verdict: SPLIT — one source per session. NDH first (this plan = 022); Vietstock = 023 (S346); VietnamBiz = 024 (S347).

### AQ-5 — STEP 0 finds both candidate URLs 404 — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Dev writes `STOP-FINDING-S344-ndh-urls-404.md` to `human-workspace/notifications/`. Defer NDH adapter; flag in mistake-log as `M-S344-N: NDH site defunct or moved`; surface in observation. Do NOT silently substitute alternate URL; main session decides next steps (user input may be needed for replacement source choice).

### AQ-6 — STEP 0 finds robots.txt disallows — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Honor robots.txt absolutely (I-S34 charter line 110 "News scrapers respect robots.txt"). Defer NDH adapter; flag in mistake-log as `M-S344-N: NDH robots.txt disallows; respecting`; surface in observation. Do NOT proceed with adapter even if technically the site is reachable. Main session may decide to abandon NDH as source or contact NDH for explicit consent.

### AQ-7 — STEP 0 finds site is JS-rendered (requires Playwright) — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Per I-S34 HARD BAN of patchright + playwright_stealth + StealthyFetcher (D-061 § Decision item 4; PERMANENTLY banned per ADR D-066 § HARD REJECTED list), we cannot install JS-rendering infrastructure. Defer NDH adapter; flag as **harness gap** ("BC-5 has no JS-rendering capability; cannot crawl JS-rendered sites — by design per I-S34"); surface in observation. Main session may decide to (a) abandon NDH, (b) seek alternate static news source that covers same domain, or (c) propose constitution amendment to allow scoped headless-Chrome usage (separate ADR; major lift).

### AQ-8 — SelectorChain[T] contract doesn't fit NDH layout — what then?

**Answer**: Surface as plan-022 finding; STOP and choose Path B (new D-067 ADR amendment per § D5 Path B). Do NOT silently bypass the contract (don't inline `or` chains the way CafeFScraper does; that defeats the entire purpose of the primitive). Common contract gaps that might surface:
- Zero-arg `Callable[[], T | None]` doesn't fit (NDH layout requires per-strategy soup re-parse with different parser config) → propose `Callable[[BeautifulSoup], T | None]` shape
- Generic T can't be inferred (mypy complains about `Tag | NavigableString | None` ambiguity) → propose `T = TypeVar("T", bound=...)` constraint
- `frozen=True` blocks needed mutation (e.g., add metric counters) → propose `frozen=False` with documented invariant

Architect prediction: NONE of these will surface; the contract is well-formed for NDH's likely static-HTML layout. If they do, ADR D-067 is the path.

### AQ-9 — Test fixture HTML licensing (re-distributing scraped HTML in tests) — OK?

**Answer**: Use SYNTHETIC minimal HTML for unit tests (per DD-10). Real HTML used ONLY for CLI smoke (Sub-step 0.4) recorded in session log but NOT committed (saved to `tmp/ndh_sample.html` which dev MUST ensure is gitignored — confirm in session log). Synthetic HTML is ours to commit + license-clean + edge-case-controllable. Real scraped HTML has unclear copyright posture + per skill § Anti-Patterns "Committing scraped data without source_url violates I-S2 citation rule". Verifier S345 grep-asserts: `grep -r "VERIFIED_NDH_TLD" tests/` returns ZERO real-URL leakage in test fixtures (verifier substitutes verified NDH TLD).

### AQ-10 — Rate-limit 2.0s — is it conservative enough?

**Answer**: 2.0s is the default per plan-020 § E matrix line 352. STEP 0.2 may override (mandatory bump if `Crawl-delay > 2.0`). STEP 0.4 empirical signal: if sample fetch (single request) returns 429/503 OR an unusually slow response (>5s) → consider bumping to 3.0s as conservative posture (NDH may be less lenient than CafeF; VietnamBiz already gets bumped to 3.0s per matrix line 354 on similar reasoning). If STEP 0.4 returns 200 cleanly within 1s → 2.0s is fine. Dev decides at IMPL time; flag rate-limit decision for verifier in session log.

---

## H. 5-source-evidence chain per adopted pattern (matches plan-020 § Section I shape)

Per L-S333-1 hook-sourced-empirical-quote discipline applied to architecture decisions, each adopted pattern MUST cite **5 sources**: (1) primary source file:line, (2) skill / deep-dive reference, (3) integration cross-reference, (4) charter invariant served, (5) stockforge codebase precedent.

| Adopted pattern | (1) Source file:line | (2) Skill / deep-dive | (3) Integration X-ref | (4) Charter invariant | (5) Stockforge precedent |
|---|---|---|---|---|---|
| **Strategy A direct-subclass of CrawlerAdapter** | `packages/application/news/ports/crawler_adapter.py:43-127` (ABC + 3 abstract methods + `__init_subclass__` enforcer) | ADR D-066 § Decision + § "Why ABC not Protocol" + plan-020 DD-3 + .claude/skills/ddd-tactical-patterns/SKILL.md (adapter/port discipline) | Plan-020 § E matrix line 352 "NDH ... A (crawl4ai-pattern; subclass CrawlerAdapter like CafeFAdapter)" + INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § L.3 "Port to apps/_shared/crawl/" | I-S2 (source_url + as_of preserved through ScrapedArticle → NewsArticle); I-S22 (data lineage via source_id ClassVar) | CafeFAdapter Strategy B WRAP at `packages/infrastructure/news/crawler_adapters/cafef_adapter.py:50-238` — same ABC subclass but wraps legacy; NDHAdapter is greenfield direct-implementation |
| **SelectorChain[T] consumption for headline/body** | `apps/_shared/crawl/selector_chain.py:33-105` (frozen dataclass; `apply()` returns `(result, num_tried)`; logs WARNING if all fail) | .claude/skills/crawler-reliability/SKILL.md § Selector Robustness ("Fallback chain pattern: try multiple strategies, return first non-empty result, log warning if all fail and return None. Don't raise — partial output beats whole-pipeline halt.") | ADR D-066 § Out-of-scope item 12 "SelectorChain reserved for NDH/Vietstock/VietnamBiz follow-on adapters" + plan-020 DD-7 | I-S34 (graceful degrade); I-S22 (label per chain for shape-metrics emit) | CafeFScraper at `packages/infrastructure/news/cafef_scraper.py:117-120` uses manual `soup.find(...) or soup.find(...) or soup.find(...)` chain — SelectorChain formalises + instruments this pattern |
| **RateLimiter primitive with seeded RNG** | `apps/_shared/crawl/rate_limiter.py:79-169` (DomainState + RateLimiter; `wait_if_needed` + `report_response` returning circuit-open bool) | crawl4ai `async_dispatcher.py:28-85` (RateLimiter source) + .claude/skills/crawler-reliability/SKILL.md § Rate Limiting | ADR D-066 § Foundation primitives table line "rate_limiter.py ... crawl4ai async_dispatcher.py:28-85 ... Apache-2.0 ... Sync port" + plan-020 DD-7 | I-S34 (≥2s/domain default; 429/503 backoff); D-059 R2 (seeded RNG Random(0) for deterministic tests) | CafeFAdapter at `cafef_adapter.py:106-188` (`__post_init__`) wires RateLimiter via rl_fetcher closure; NDHAdapter mirrors via `_fetch_with_optional_chain` helper |
| **RobotsTxtManager primitive with protego** | `apps/_shared/crawl/robots_manager.py:52-152` (sync port; lazy-import protego; in-memory cache; can_fetch + get_crawl_delay) | Scrapling `spiders/robotstxt.py:10-60` (source) + .claude/skills/crawler-reliability/SKILL.md § Anti-Patterns ("Ignoring status codes (500 != 200)" + "Fetching in tight loops without rate limiting (gets IP banned)") | ADR D-066 § Foundation primitives table line "robots_manager.py ... Scrapling spiders/robotstxt.py:10-60 ... BSD-3-Clause" + plan-020 DD-6 | I-S34 charter line 110 "News scrapers respect robots.txt + reasonable rate limits + identify user agent" | NEW — no robots.txt-aware crawler in stockforge before plan-020; CafeFAdapter wires RobotsTxtManager via optional injection at `cafef_adapter.py:97-98, 162-166`; NDHAdapter mirrors |
| **RawHtmlSink atomic write + path-safety** | `apps/_shared/crawl/raw_html_sink.py:40-121` (frozen dataclass; `write()` does tz-aware validation + sha256 url hash + tmp+os.replace atomic + safe_path sandbox) | ADR D-062 atomic-write doctrine + ADR D-064 path-safety 5-invariant + .claude/skills/crawler-reliability/SKILL.md § Storage | ADR D-066 § Foundation primitives table line "raw_html_sink.py ... fresh ... Atomic tmp+replace; safe_path containment; tz-aware datetime" + plan-020 DD-6 | I-S22 (raw HTML preserved for reprocessing); D-062 atomic; D-064 path-safety; D-059 R1 tz-aware datetime | CafeFAdapter at `cafef_adapter.py:131-145` wires RawHtmlSink via optional injection; NDHAdapter mirrors path `data/raw/news/ndh/...` |

---

## I. Risk-Mitigation table (RM1..RM10)

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| RM1 | **STEP 0 finds neither candidate URL works** (`nhipsongdoanhnghiep.vn` AND `ndh.vn` both 404 / DNS-fail) | Low (NDH is a known VN financial news brand; one of these hosts should resolve) | High (no adapter possible; defer entire bundle) | STOP-AND-ASK per § C STEP 0 STOP clause + § G AQ-5 pre-answered. Dev writes notification; main session decides replacement-source path or abandonment. |
| RM2 | **STEP 0 finds site is JS-rendered** (article body requires JavaScript to populate DOM) | Med (some modern VN news sites use Next.js / Vue / React) | High (I-S34 HARD REJECT of Playwright means we cannot crawl JS-rendered without harness amendment) | STOP-AND-ASK per § C STEP 0 STOP clause + § G AQ-7 pre-answered. Defer adapter; surface harness gap "BC-5 has no JS-rendering capability — by design per I-S34"; do NOT install patchright (PERMANENT BAN); do NOT bypass via curl_cffi (borderline per plan-020 § Charter compliance map line 339-341). |
| RM3 | **SelectorChain[T] primitive needs refinement** (zero-arg Callable shape unsuitable, generic T ambiguity, frozen=True blocks needed mutation) | Low (architect reviewed `selector_chain.py:33-105` against likely NDH layout; contract appears well-formed) | Med (delays adapter ship by 1 session; requires D-067 ADR) | Path B per § D5 — NEW D-067 ADR amendment with formal contract change; surface to verifier S345 for review. DO NOT silently bypass (no inline `or` chains masquerading as SelectorChain replacement). |
| RM4 | **Dev mistakenly attempts Vietstock/VietnamBiz too** (scope-creep; same anti-pattern as plan-020 RM4) | Low (plan explicitly scopes to NDH only + § B Out-of-scope item lists "Vietstock + VietnamBiz adapters" + AQ-4 pre-answers the question) | High (S4 catastrophic-mix-pattern recurrence; budget overrun ≥250K hard_cap) | Plan title + Goal + § B + AQ-4 EXPLICITLY scope to NDH only. If dev mistakenly attempts → STOP-AND-SPLIT: revert Vietstock/VietnamBiz work; queue follow-up plans 023/024 for those sources; bundle ships at NDH-only DoD. |
| RM5 | **Rate-limit 2.0s insufficient** (NDH returns 429/503 under default rate-limit) | Low-Med (no evidence NDH is less lenient than CafeF; STEP 0.4 empirically verifies via 1-fetch probe) | Med (transient failures; ToS-grey territory) | Fall back to 3.0s per DD-5 fallback + flag for verifier. RateLimiter's `report_response` handles 429/503 with exponential backoff automatically (`rate_limiter.py:144-160`); circuit-open after `max_retries=5`. Verifier re-runs sample fetch + confirms wall-clock matches expected. |
| RM6 | **protego dependency missing or version drift** (plan-020 added `protego>=0.3.1` to pyproject.toml; verify still present) | Low (plan-020 closure added; verify at STEP 0.6) | Low (lazy-import in RobotsTxtManager raises ImportError with install hint per `robots_manager.py:40-49`) | STEP 0.6 verifies all 6 primitives importable. If `from protego import Protego` fails → `pip install -e .` to ensure pyproject.toml deps installed in dev env. If `protego` was accidentally removed from pyproject.toml → STOP and re-add in ONE coherent edit per S332 single-edit-conflict-prevention precedent. |
| RM7 | **NDH publishes no robots.txt** (404 on `/robots.txt`) | Med (some VN sites historically don't publish robots.txt — same risk class as plan-020 RM14) | Low (allow-all on 404 is the conservative correct behavior per `robots_manager.py:119-136`; rate-limit + UA identification still applied) | Per RobotsTxtManager `can_fetch` returns True on 404 (semantically correct; standard interpretation = "allow all"). Skill § Anti-Patterns documents: absent robots.txt is NOT green light for unlimited fetching — rate-limit + UA still apply. Test case in D3 covers this scenario (mock fetcher returning None for robots.txt URL → `can_fetch` returns True). |
| RM8 | **Test fixture HTML drift** — committed synthetic fixture stops matching real NDH HTML over time | Low (synthetic fixtures decoupled from live; STEP 0.4 sample saved to tmp only) | Low (fixture tests still validate parsing logic; CLI smoke catches drift at next deploy) | Synthetic HTML per DD-10 + AQ-9. Real HTML in CLI smoke only (Sub-step 0.4 sample to `tmp/ndh_sample.html`; not committed). If CLI smoke fails post-deploy → trigger M-S<N>-N investigate-NDH-drift entry + selector update session. |
| RM9 | **NDHAdapter accidentally introduces new LLM-numeric field** (Rule 16 D-065 violation) | Low (audit + STEP 0.5 anchor) | High (charter Principle 9 violation) | § C STEP 0.5 empirically confirms ZERO new numeric fields; NDHAdapter emits SAME `ScrapedArticle` dataclass as CafeFAdapter (reuses import from `cafef_scraper.py:40-52` per § D1 Note). If dev encounters need for new numeric field → STOP-AND-ESCALATE per STEP 0 STOP-IF-AMBIGUOUS; add Rule 16 satisfaction-mode docstring per Rule 16 § "At amendment time". Verifier S345 DC-COMPLIANCE-2 is final gate. |
| RM10 | **I-S34 banned import creeps in** (patchright, playwright_stealth, fake-useragent, StealthyFetcher, _cloudflare_solver) | Low (CLAUDE.md hard rules + ADR D-066 § HARD REJECTED list + DC-COMPLIANCE-1 grep check) | Critical (charter-tier violation per D-061 § Decision item 4) | DC-COMPLIANCE-1 grep check at verifier S345; ALSO at architect's recommendation, dev SHOULD run `grep -rE "patchright\|playwright_stealth\|fake-useragent\|StealthyFetcher" packages/infrastructure/news/crawler_adapters/ndh_adapter.py` BEFORE first commit. Any match = HARD FAIL — STOP and remove. |

---

## J. Coordination paths (main session AVOIDS during S344 IMPL)

**Main session AVOIDS** during S344 IMPL window (cross-session edit conflict prevention; mirrors plan-020 § Coordination rules):

- `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` (NEW — D1)
- `packages/infrastructure/news/crawler_adapters/__init__.py` (MODIFIED — D4)
- `tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py` OR `packages/infrastructure/news/crawler_adapters/test_ndh_adapter.py` (NEW — D3; dev picks layout)
- `apps/cli/ingest_news_ndh.py` (NEW — D4)
- `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` (MODIFIED — Path A REV-1 amendment)
- OR `agent-workspace/memory/decisions/067-selectorchain-contract-amendment.md` (NEW — Path B only)
- `agent-workspace/memory/sessions/2026-05-XX-session-344.md` (NEW — authored by S344 dev at end)
- `agent-workspace/memory/observations/sandwich-dev-S344-ndh-adapter.md` (NEW — S344 dispatch observation file)
- `data/raw/news/ndh/**` (NEW — CLI smoke writes raw HTML here)
- `data/tmp-ndh-smoke.sqlite` (NEW — CLI smoke output; ephemeral; dev MAY delete after smoke)
- `tmp/ndh_sample.html` (NEW — STEP 0.4 sample HTML; ephemeral; gitignored)

**Main session MAY** continue work on (orthogonal):
- Any other `apps/cli/ingest_*.py` not `ingest_news_ndh.py` (e.g., `ingest_news_cafef.py`, `ingest_kol_channels.py`, etc.)
- Other ADRs in `agent-workspace/memory/decisions/` outside D-066 / D-067
- `agent-workspace/research/`, `agent-workspace/master-plans/`, `agent-workspace/proposals/`, `agent-workspace/calibration/`, `agent-workspace/thesis-log/`
- `packages/_shared/path_safety.py` is READ-ONLY for S344 dev (W0-5 dependency)
- `apps/_shared/crawl/**` is READ-ONLY for S344 dev (plan-020 closed primitives; no modification per § B Out-of-scope)
- `packages/application/news/ports/**` is READ-ONLY for S344 dev (CrawlerAdapter ABC frozen per D-066; modification = ADR D-066 amendment via Path B)
- `packages/infrastructure/news/cafef_scraper.py` + `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` are READ-ONLY for S344 dev (CafeF already migrated; consolidation is separate session per RM12)
- Other `packages/` BCs outside news (BC-1/2/3/4/6/7/8/9 unaffected)
- `agent-workspace/memory/current-execution.md` row pre-staging at S344 start — but NOT during IMPL window; dev finalises at IMPL close

**Commit boundary** (D-060 active): S344 dev MAY commit at IMPL close in a single coherent commit OR split per sub-track. Recommended message stems:

- Option A (single commit): `S344: Phase D NDH adapter — Strategy A direct-subclass + SelectorChain[T] first consumer + CLI + D-066 REV-1`
- Option B (3 commits):
  - `S344: D1 — NDHAdapter implementation (Strategy A direct-subclass; 3× SelectorChain[T] consumer)`
  - `S344: D3+D4 — NDH tests + CLI + registry wire`
  - `S344: D5 — ADR D-066 REV-1 amendment (item 12 closure)`

The dev picks based on whether all 5 sub-tracks reach DoD cleanly in one pass (Option A) or incrementally (Option B). Do NOT push.

---

## K. Budget recommendation

**Budget**: ~100-150K Sonnet FOCUSED_IMPL (per master plan § 6.4 per-source adapter envelope).

**Breakdown estimate**:
- STEP 0 verification (Sub-steps 0.1-0.10): ~15-20K (live URL probes + robots.txt parse + ToS read + sample HTML structure analysis + 6-primitive import check + baseline regression run)
- D1 NDHAdapter implementation: ~25-35K (~250-300 LOC adapter; mirror CafeFAdapter shape with Strategy A subclass; 3× SelectorChain instances)
- D2 HTML parser internals (selector authoring): ~10-15K (replacing 4-5 placeholder selectors with verified ones per STEP 0.4)
- D3 Unit tests: ~25-35K (~300-400 LOC tests; ≥12 cases; synthetic fixtures inline)
- D4 Registry wire + CLI: ~15-25K (~250 LOC CLI mirror of `ingest_news_cafef.py`; init export update)
- D5 ADR amendment Path A (preferred): ~5-10K (REV-1 entry; ~50 LOC)
  - Path B (only if contract gap): ~15-25K (new D-067 ADR; ~200 LOC)
- Session log + observation file: ~10-15K
- Reserve for STEP 0 findings adjusting scope: ~20% = 20-30K

**Total**: ~125-185K, fitting within FOCUSED_IMPL 100-150K envelope IF Path A taken AND STEP 0 finds no JS-rendering / no robots-block (the expected happy path). If Path B (D-067 ADR amendment) OR STEP 0 surfaces complications, may need MULTI_TASK_IMPL upgrade to 150-250K.

**Split recommendation**: Single FOCUSED_IMPL session is preferred. Architect verdict: do NOT split as PLAN+IMPL pair — the architectural decisions are already made in this plan (DD-1 through DD-10); dev executes against the recipe. PLAN+IMPL pair would be appropriate ONLY if STEP 0 reveals NDH has fundamentally different structure than predicted (e.g., requires non-trivial selector engineering, or DD-4 SelectorChain shape doesn't fit, triggering Path B).

---

## L. ADR D-066 amendment plan

**Plan-022 explicitly closes D-066 § Out-of-scope item 12 (SelectorChain unconsumed).**

At S344 completion (Path A — preferred), D-066 § Out-of-scope item 12 status updates from PENDING-CONSUMER to ANSWERED with NDHAdapter cited as the first consumer.

**Proposed amendment text** (architect-drafted; dev verifies + lands at S344 close):

```markdown
## Amendments (append-only)

### REV-1 (2026-05-XX) — SelectorChain[T] consumption confirmed; § Out-of-scope item 12 CLOSED

- **Trigger**: plan-022-S343 ships NDHAdapter as first greenfield Strategy A direct-subclass + first SelectorChain[T] consumer
- **Authorization**: plan-022 § L (architect-proposed) + S345 verifier acceptance (pending)
- **Source artifacts**:
  - agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md § DD-4 + § D1 + § H 5-source-evidence chain row 2
  - packages/infrastructure/news/crawler_adapters/ndh_adapter.py (NEW; uses 3 SelectorChain[T] instances for headline / body / publish_date fields)
  - tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py (NEW; ≥12 test cases including SelectorChain fallback coverage at test cases 12-13)
  - apps/cli/ingest_news_ndh.py (NEW; CLI dispatch via fresh CrawlerRegistry + NDHAdapter registration)
- **Summary of changes**:
  - § Out-of-scope item 12: status updated from PENDING-CONSUMER (per S339 F2) to ANSWERED; first consumer = NDHAdapter (S344 IMPL); item text updated to read: "SelectorChain wiring into CafeFAdapter — DEFERRED to Phase D-N CafeFScraper consolidation per RM12. Status: NDH adapter is the first consumer (plan-022-S343 S344 IMPL); Vietstock + VietnamBiz adapters will follow (plans 023 + 024). CafeFAdapter consolidation Strategy A migration remains future scope."
  - SelectorChain[T] contract validated by production usage; no contract gap detected at S344 (architect verdict; subject to verifier S345 re-confirmation per AQ-8)
  - SelectorChain[T] foundation primitive's status as "shipped but un-consumed infra" (per S339 verifier F2 finding) is now CLOSED
- **Verifier impact**: S345 spot-checks NDHAdapter's SelectorChain usage against the contract at `apps/_shared/crawl/selector_chain.py:33-105` — confirms zero-arg Callable shape used correctly + label per chain distinct + WARNING-on-all-fail behavior exercised by test case 13
```

**If Path B taken (NEW D-067 ADR amendment)**: D-066 still gets REV-1 entry pointing forward to D-067 for the contract amendment + Out-of-scope item 12 marked SUPERSEDED-BY-D-067. Path B narrative is documented in the new D-067 ADR per § D5 Path B.

---

## END OF PLAN

**Plan summary**:
- Pre-flight: STEP 0 has 10 sub-steps; BLOCKING (live URL verification + robots.txt + ToS + sample HTML analysis + primitive imports + baseline regression)
- Architecture decisions: DD-1 through DD-10 (10 decisions made + pre-answered)
- Sub-tracks: D1 (adapter), D2 (parser internals), D3 (tests ≥12), D4 (registry + CLI), D5 (ADR + session log + observation)
- DoD: 30 items across DC-FILE/LOC/IMPL/COMPLIANCE/GATE/SMOKE/BOOK categories
- Architecture questions: AQ-1 through AQ-10 (10 questions pre-answered)
- 5-source-evidence chain: 5 rows (Strategy A subclass + SelectorChain[T] + RateLimiter + RobotsTxtManager + RawHtmlSink)
- Risk-Mitigation: RM1 through RM10 (10 risks tracked with mitigations)
- Coordination: 11 paths main session AVOIDS during S344 IMPL
- Budget: 100-150K FOCUSED_IMPL (with 20% reserve)
- ADR amendment: Path A preferred (D-066 REV-1 closing § Out-of-scope item 12)
