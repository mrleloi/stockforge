---
plan_id: 026-S353-phase-d-vietstock-adapter
target_session: S354
type: FOCUSED_IMPL
budget: 100-150K Opus FOCUSED_IMPL (Phase 1b calibrated against NDH S344 actuals; see § Calibration summary)
phase: D (Theme L — Vietstock greenfield adapter; SECOND Strategy A direct-subclass adapter per plan-020 § E matrix; SECOND consumer of SelectorChain[T] primitive — NDH was first via plan-022 S344)
track: Wave 1 Theme L (BC-5 News Stream per-source rollout; Vietstock = source #3 of 4 priority VN sources after CafeF + NDH)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.7 + § 6.4.1
predecessor: 022-S343-phase-d-ndh-adapter (NDH adapter shipped + verified S344-S345; F2-store_raw fix applied inline at S345 close; plan moved pending→completed); plan-025-S346 planner-upgrade (Phase 1b self-calibration + parallel_with field MANDATORY per ≥3 sub-track plans; this plan is FIRST DOGFOOD CONSUMER of the planner upgrade)
successor: TBD-S355 sandwich-verifier (AP-1 fresh-context); then 027-S356 (VietnamBiz adapter — same matrix-row pattern with 3.0s rate-limit bump)
architect: S353 sandwich-architect (background; this plan)
dispatched_by: main session orchestrating Phase D per-source rollout (Wave 1 Theme L continuation; FIRST DOGFOOD of the planner-upgrade landed in S349)
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b consumed per plan-025 DD-11 mandate)
executing_agent: sandwich-dev (background dispatch S354; fresh-context; AP-1 verifier in S355)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook (per current-execution.md § INCIDENT + RECOVERY)"
  - "R3 daily-backup.sh Stop hook (per current-execution.md § INCIDENT + RECOVERY)"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310; do NOT recommend sync-grilling as part of close ritual)"

depends_on:
  - "D-066 + REV-1 (CrawlerAdapter ABC contract; NDH cited as 1st consumer in REV-1 amendment; Vietstock will be cited as 2nd consumer in REV-2 amendment authored at this plan close per § L)"
  - "D-061 (Wave-1 integration ratification — § Decision item 4 enforces 'Scrapling Cloudflare-solver HARD REJECT + patchright DO NOT IMPORT + StealthyFetcher excluded as a class' — BINDING)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain are BINDING for every new file authored under this plan)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for S354 dev commit boundary)"
  - "D-062 (atomic-write-doctrine — BINDING for any raw-HTML writes via RawHtmlSink; already enforced by W0-3 hook + RawHtmlSink uses tmp+os.replace)"
  - "D-064 (path-safety 5-invariant contract — BINDING for new file-path code; RawHtmlSink already uses safe_path)"
  - "D-065 (Theme G I-S1-1 Rule 16 binding; this plan introduces ZERO new LLM-numeric schema fields — same Rule-16-by-construction posture as plan-020/022)"
  - "D-069 PROPOSED-AT-IMPL (planner-upgrade ADR; Phase 1b mandate for ≥3 sub-tracks; this plan SATISFIES the dogfood condition)"
  - "Charter v1.1 Principle 4 (Proprietary data moat) + Principle 7 (Dogfood mandatory — CLI ingest_news_vietstock shipping at S354; Phase 1b dogfood — this plan first consumer of planner-upgrade) + Principle 8 (Calibration over confidence — Phase 1b grounds budget in NDH-S344 actuals not LLM guess) + Principle 11 (companion firing-test mandate IF a hook is shipped — NO new hook this bundle)"
  - "I-S1 (NO LLM math) + I-S2 (citation discipline — source_url + as_of + extracted_at) + I-S22 (data lineage) + I-S34 (robots.txt + reasonable rate limits + identify user agent; HARD REJECT of patchright/playwright_stealth/fake-useragent/StealthyFetcher) + I-S35 (research-aid framing)"
  - "Rule 6 (LLM Output Provenance — adapter output ↦ NewsArticle ↦ ExtractedClaim path preserved) + Rule 7 (sentiment categorical) + Rule 8 (anti-look-ahead: published_at ≤ ingested_at carried through)"
  - "skill .claude/skills/crawler-reliability/SKILL.md (Selector Robustness fallback chain + Retry & Backoff tenacity recipe + Rate Limiting per-domain + VBW for Scrapers + Monitoring shape metrics + Anti-Patterns list)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (adapter/port/repository discipline)"

binding_decisions:
  - "D-066 § Decision (CrawlerAdapter ABC + source_id ClassVar enforcement via __init_subclass__; subclass MUST declare non-empty source_id; subclass MUST implement discover/fetch_and_parse/to_news_article; subclass MUST NOT import patchright/playwright_stealth/fake-useragent/StealthyFetcher/_cloudflare_solver per I-S34) — BINDING for VietstockAdapter"
  - "D-061 § Decision item 4 (Scrapling Cloudflare-solver HARD REJECT) — BINDING for all crawler adapters under packages/infrastructure/news/crawler_adapters/**"
  - "D-065 Rule 16 (numeric-field discipline) — Vietstock crawler emits ZERO new LLM-numeric fields; Rule 16 satisfied by construction (mirror plan-020/022 § Schema discipline)"
  - "D-060 — agent MAY git commit (NOT push); S354 dev decides commit boundary per § J Coordination paths"
  - "S345 verifier F2 lesson PROMOTED — `_fetch_with_optional_chain(url, *, store_raw: bool = True)` parameter with discover() passing False MUST be architected from day-1 (NOT post-S345 retrofit; see DD-7); this is the SECOND consumer following NDH's post-fix shape"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL)"
  - "no commits in THIS plan-session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no touching apps/cli/ingest_news_cafef.py NOR apps/cli/ingest_news_ndh.py — those are shipped; this plan ships a NEW CLI ingest_news_vietstock.py"
  - "no NDH adapter modifications — Vietstock plan does NOT amend NDHAdapter; cross-adapter consolidation deferred per RM12 carry-forward"
  - "no VietnamBiz adapter work — deferred to plan-027 (S356); 3rd of 4 sources"
  - "no harness/hook changes — this plan ships product substrate (Vietstock adapter); surface any harness gaps in observation; do NOT fix here"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 HARD REJECT: VietstockAdapter MUST NOT import patchright, playwright_stealth, fake-useragent, StealthyFetcher, _cloudflare_solver, or any Scrapling Cloudflare-solver path — verifier AQ check grep-asserts this"
  - "If STEP 0 finds Vietstock is JS-rendered (would require Playwright) → DEFER adapter; flag as harness gap; do NOT install patchright; do NOT silently bypass I-S34"
---

# S354 — Phase D Vietstock Adapter (greenfield Strategy A; second SelectorChain[T] consumer)

## A. Goal

Ship the **second greenfield Strategy A direct-subclass CrawlerAdapter** for Vietnamese financial news source Vietstock (`vietstock.vn` or `finance.vietstock.vn` — STEP 0 verifies live), mirroring the NDH pattern shipped at S344 (plan-022). VietstockAdapter is the **second consumer of `SelectorChain[T]`** primitive after NDH, validating the contract across two distinct VN financial sites.

**What this plan delivers**:
- `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py` (NEW; ~250-300 LOC; subclasses `CrawlerAdapter` directly per Strategy A — no legacy code to wrap)
- `packages/infrastructure/news/crawler_adapters/__init__.py` UPDATED to export `VietstockAdapter` alongside existing `CafeFAdapter` + `NDHAdapter`
- `packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py` (NEW; ≥12 test cases; synthetic minimal HTML fixtures)
- `apps/cli/ingest_news_vietstock.py` (NEW; ~300 LOC; mirrors `ingest_news_ndh.py` shape but dispatches VietstockAdapter)
- ADR D-066 REV-2 amendment (Vietstock cited as 2nd consumer; reinforces SelectorChain[T] contract maturity)
- Session log + observation file per CLAUDE.md § Session Protocol End
- ZERO charter / constitution / human-workspace writes
- ZERO new LLM-numeric schema fields (Rule 16 by construction)
- ZERO new hooks (mirror plan-020/022; product substrate not harness rule-enforcement)

## B. In-scope / Out-of-scope

### IN-scope (this bundle MUST ship)

- VietstockAdapter class (greenfield; Strategy A direct subclass of CrawlerAdapter)
- `SelectorChain[T]` consumption in VietstockAdapter's HTML parsing path (headline + body + optional publish_date; STEP 0.4 confirms exact selectors)
- Unit tests with synthetic minimal HTML fixtures (≥12 cases)
- CLI smoke entry point at `apps/cli/ingest_news_vietstock.py` mirroring NDH CLI shape
- Registry wire: CLI constructs fresh `CrawlerRegistry()`, registers `VietstockAdapter`, dispatches via `registry.get("vietstock")`
- ADR D-066 REV-2 amendment (Vietstock cited as 2nd consumer; SelectorChain[T] contract maturity from 1 → 2 consumers)
- Session log + observation file
- F2-aware design from day 1: `_fetch_with_optional_chain(url, *, store_raw: bool = True)` with discover() passing False (per S345 verifier post-S345 fix promoted into NDH; Vietstock ships with the correct shape natively)

### OUT-of-scope (DEFERRED — explicit non-goals)

- **VietnamBiz adapter** — deferred to plan-027 (S356) per plan-020 § E matrix; rate-limit bumped to 3.0s
- **Harness/hook changes** — this is product substrate, NOT rule-enforcement; any harness anomalies surface in observation
- **Charter / constitution edits** — out of scope per CLAUDE.md hard rules
- **Async migration** — sync interface per D-066 § Async deferred to Phase 3 (unchanged)
- **R2 raw-HTML storage** — local filesystem under `data/raw/news/vietstock/` (Phase 2 thin slice per D-066 § Storage)
- **Adaptive selector / Scrapling `Selector.relocate`** — deferred per plan-020 § Out-of-scope item 1 (long-term defense; SelectorChain fallback is short-term)
- **CafeFAdapter consolidation Strategy A migration** — RM12 carry-forward; separate future Phase D-N session
- **SelectorChain wiring into CafeFAdapter** — deferred per ADR D-066 § Out-of-scope item 12 (Strategy B WRAP preserves CafeFScraper BeautifulSoup parse path untouched)
- **Live vietstock.vn HTTP smoke in CI** — fixture-driven tests only; one manual CLI smoke recorded in session log but not committed
- **`extract_claims` on CrawlerAdapter** — deferred to Theme I per D-066 § Out-of-scope item 8
- **NDHAdapter / CafeFAdapter modifications** — Vietstock plan ships in isolation; no cross-adapter touch
- **AJAX/JSON API consumption (Vietstock may have public report-listing AJAX endpoints)** — DEFERRED to dedicated AJAX-aware future plan; Strategy A targets static HTML article pages only

### Calibration summary (Phase 1b)

Source: agent-workspace/memory/.planner-stats.tsv (last_updated=N/A; header-only — first real plan to consume)
agent-workspace/memory/self-awareness/sessions-rollup.tsv (last 30 rows read; rows 593-633)
agent-workspace/memory/dispatch.jsonl (last 30 rows read; rows 490-539)
agent-workspace/memory/mistake-log.md (last 200 LOC digest read; recent: M-S347-NONE, M-S342-1, M-S341-1)

- task_class: crawler-adapter-impl (Strategy A greenfield direct-subclass of CrawlerAdapter; SelectorChain consumer; +CLI shim)
- sample_size: 1 (NDH at S344 — single direct observation of the task class)
- avg_wall_min observed: NDH S344 dev dispatch duration_ms=57687777 ≈ 96 min total billed (real focused dev work ~31 min per dispatch event b/w 11:43-12:17 + bookkeeping tail); sessions-rollup row 627 shows S344 token delta 266338→375571 = ~109K real tokens spent (Sonnet); session boundary close at S344 end captured 110K range
- parallel_hit_rate: 0% observed (NDH S344 ran sequential D1→D3→D4→D5; planner-upgrade `parallel_with` field landed AFTER NDH IMPL)
- parallel_savings_avg: N/A (no historical parallel-dispatch observations yet; this plan is the first to declare `parallel_with`)
- Adjustment to default budget: NONE (Phase 1b would recommend ~109K Sonnet IF S354 used Sonnet; architect upgrades to Opus per plan-025 architect-template-update because Phase 1b consumer + first-dogfood-of-parallel = higher-cognition task warrants Opus; budget set at 100-150K Opus FOCUSED_IMPL — slightly above NDH-actual to absorb Phase 1b consumption overhead + Opus rate)
- Cold-start? YES on .planner-stats.tsv (header-only); PARTIAL on sessions-rollup (1 NDH observation only — n=1 statistically weak but directionally informative)

PLAN BUDGET DERIVATION:
- Mirror NDH actual (~109K Sonnet real for full ship): 100-150K Opus FOCUSED_IMPL is conservative-bounded (Opus ~30-40% tokens-per-line more than Sonnet on similar surgical task; +Phase 1b dogfood overhead +new `parallel_with` field authoring)
- Cold-start ADJUST: minimal — sample_size=1 isn't enough to revise from default; Phase 1b confirms order-of-magnitude not precise estimate
- Final recommendation: **100-150K Opus FOCUSED_IMPL with 20% reserve** for STEP 0 findings or RM3 Path B (SelectorChain contract gap surfacing)

PARALLEL OPPORTUNITY (first observed instance):
- D3 (tests) + D4 (registry wire + CLI) + D5 (ADR amendment) can run parallel post-D1 per coordination_paths_exclusive (3 disjoint file sets per § E)
- D1 (adapter impl) must serialize as foundation; D2 (HTML parser internals) merges into D1 (selector filling depends on STEP 0.4)
- Recommended dispatch: D1 sequential (~12-18 min wall) → then D3+D4+D5 parallel via single Agent-tool multi-call (max(8, 8, 3) = ~8 min)
- Total wall: ~20-26 min vs sequential ~31-37 min = ~30% reduction (matches plan-025 § DD-1 projection 25-50%)
- **However**: max-3 parallel ceiling per Q-PL1 RATIFIED; this plan declares 3 parallel children (D3+D4+D5) = at-ceiling; no `parallel_with` overflow risk

## C. STEP 0 — VBW Live Verification (BLOCKING; mandatory)

The implementing session (S354) MUST run these sub-steps BEFORE writing any adapter code and write results into the session log. This plan was authored by a sandwich-architect subagent with Read/Glob/Grep/Write but NO Bash — STEP 0 is the empirical anchor that grounds plan recipes against the live Vietstock site.

**STOP-AND-ASK clause** (binding; see also § G AQ-5/AQ-6/AQ-7 for pre-answered escalation paths):
- If BOTH candidate URLs (`vietstock.vn` AND `finance.vietstock.vn`) return 404 / DNS-no-resolve → STOP-AND-ASK (defer adapter; flag site-defunct; surface in mistake-log)
- If `/robots.txt` explicitly disallows crawl for `User-agent: *` or `User-agent: stockforge-research-bot` → STOP-AND-ASK (defer adapter; honor robots; flag in mistake-log per skill § Anti-Patterns)
- If ToS page (linked from site footer) forbids automated access → STOP-AND-ASK (defer adapter; flag in mistake-log)
- If site is fully JS-rendered (article body requires JavaScript execution to populate DOM) → STOP-AND-ASK (defer adapter; surface harness gap that I-S34 HARD REJECT of Playwright/patchright leaves us without a JS-rendering option; do NOT install patchright; do NOT silently bypass I-S34)
- If observed HTML structure is so different from expectation that the planned SelectorChain[T] shape cannot accommodate it → STOP-AND-REPLAN (surface as plan-026 finding; may require D-066 amendment for SelectorChain contract gap — see § D5 Path B)

### Sub-step 0.1 — URL probe (verify which of two candidate hosts is canonical)

```bash
# Probe both candidate URLs (httpx with 10s timeout; record status code + redirect chain + final URL)
python -c "
import httpx
for host in ['vietstock.vn', 'finance.vietstock.vn']:
    try:
        r = httpx.get(f'https://{host}', follow_redirects=True, timeout=10.0,
                      headers={'User-Agent': 'stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)'})
        print(f'{host}: status={r.status_code} final={r.url}')
    except Exception as e:
        print(f'{host}: ERROR {type(e).__name__}: {e}')
"
```

**Record in session log**: For each candidate URL, the observed (status code, final URL after redirects, response size in bytes). If exactly ONE URL is reachable, that's canonical. If BOTH reachable, prefer the more identifiable financial-news-content homepage (record decision rationale). If NEITHER reachable → STOP-AND-ASK.

**Architect prediction**: `vietstock.vn` is the canonical landing page; `finance.vietstock.vn` may exist as a subdomain. Master plan line 353 hypothesizes "static HTML for article pages; AJAX for some report listings"; STEP 0.4 confirms.

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
for path in ['/', '/news', '/chung-khoan', '/tai-chinh', '/article']:
    print(f'  {path}: can_fetch={parser.can_fetch(path, \"stockforge-research-bot/0.0.1\")}')
print(f'crawl_delay for *: {parser.crawl_delay(\"*\")}')
"
```

**Record in session log**: robots.txt status code (200 = present; 404 = absent → per `RobotsTxtManager.can_fetch` default = permissive); the verbatim disallow rules for `User-agent: *` and any specifically for `stockforge-research-bot`; the `Crawl-delay` directive if present (this may bump the planned 2.0s default to a higher value).

**Branch**:
- robots.txt present + User-agent: * is allowed root path → PROCEED (record in adapter docstring "robots.txt verified VERIFIED-DATE")
- robots.txt present + explicit disallow on relevant paths → STOP-AND-ASK
- robots.txt 404 (absent) → PROCEED per RobotsTxtManager default = permissive; still apply rate-limit + UA identification
- Crawl-delay > 2.0s → bump rate-limit to that value (mandatory; honor directive)

### Sub-step 0.3 — ToS page reading (qualitative; record verdict in session log)

Navigate from the verified site homepage to the footer; locate a "Terms of Service" / "Điều khoản sử dụng" / "Quyền tác giả" / "Pháp lý" / "Chính sách" link. Read the page (Vietnamese text; agent reads + translates inline). Look for clauses that explicitly prohibit:
- Automated access / scraping / bots
- Commercial use of content
- Bulk data extraction

**Record in session log**: ToS page URL + 1-paragraph summary of crawl-permissibility verdict + date of read. Per I-S34 charter line 110, if ToS explicitly forbids automated access → STOP-AND-ASK (defer adapter; honor ToS even if robots.txt permits).

### Sub-step 0.4 — Sample article fetch + HTML structure analysis

```bash
# Fetch ONE sample article URL (find via homepage → click first headline → copy URL)
python -c "
import httpx
url = 'https://VERIFIED_HOST/SAMPLE_ARTICLE_URL'  # from manual navigation
r = httpx.get(url, timeout=10.0, headers={'User-Agent': 'stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)'})
print(f'status={r.status_code} bytes={len(r.text)} content-type={r.headers.get(\"content-type\")}')
# Check for JS-rendering markers
js_markers = ['<script type=\"application/json\" id=\"__NEXT_DATA__\"', '<div id=\"app\"></div>', 'window.__INITIAL_STATE__', 'data-react-helmet', 'ng-app=', 'data-vue-app']
for m in js_markers:
    if m in r.text:
        print(f'  JS-marker DETECTED: {m}')
        break
else:
    print('  JS-marker check: PASS (static HTML — appears server-rendered)')
# Save sample for selector discovery
from pathlib import Path
Path('tmp/vietstock_sample.html').write_text(r.text, encoding='utf-8')
print(f'sample saved to tmp/vietstock_sample.html')
"
```

**Record in session log**: Status code, response size, JS-rendering markers detected (if any), content-type. Save sample HTML to a tmp/ location (NOT committed; for selector discovery only — recorded path in session log so reviewer can inspect).

**Then**, manually inspect the saved HTML to identify selector candidates for each field:
- **Headline (`title`)**: typical candidates — `<h1>`, `<h1 class="...">`, `<meta property="og:title">`, `<title>` (strip suffix). Vietstock has been historically observed with `<h1 class="title-line">` or `<h1 class="article-title">`; record ≥2 candidates in priority order
- **Body container**: typical candidates — `<div class="single-content">`, `<div class="content-detail">`, `<div class="article-body">`, `<article>`; record ≥3 candidates in priority order
- **Publish date**: typical candidates — `<meta property="article:published_time">`, `<meta name="pubdate">`, `<time datetime="...">`, `<span class="date">`. Vietstock often uses Vietnamese-locale strings like "16/05/2026 14:30"; record ≥2 candidates + observed datetime format string
- **Author/byline** (optional; skip if not present): `<span class="author">`, `<meta name="author">`; record if found
- **Article URL pattern** (for `discover()`): observe what listing-page anchors look like; Vietstock historically uses paths like `/<category>/<slug>-<numeric_id>.htm` or `/<category>/<slug>.html`; identify URL-suffix or path-prefix conventions

**Branch**:
- Static HTML with identifiable selectors → PROCEED with SelectorChain[T] design per § D DD-4
- JS-marker detected + body container empty without JS → STOP-AND-ASK (per § G AQ-7; I-S34 HARD REJECT of Playwright)
- Mixed (some fields server-rendered, some require JS) → consider partial extraction: PROCEED only if title + body + URL are all server-rendered; defer publish_date to fallback (`self.clock()` per NDH `_parse_published_at` final-fallback pattern at `ndh_adapter.py:255`)
- AJAX-only listings (per master plan line 353 hypothesis): the SUFFIX article-page fetch is the primary path; if discover() listing-page is AJAX-rendered but article pages are static → PROCEED with fixed seed URLs OR HTML listing URL fallback (record in session log; may need RM-AJAX entry)

### Sub-step 0.5 — Rule 16 compliance pre-flight (mirror plan-020/022 STEP 0.5)

```bash
# Confirm no new numeric fields are needed (VietstockAdapter mirrors NDHAdapter's Rule-16-by-construction posture)
grep -rn "float\|int\|Decimal" packages/contracts/events/news_article_ingested.py
grep -rn "float\|int\|Decimal" packages/domain/news/models/news_article.py
grep -rn "float\|int" packages/domain/news/value_objects/extractor_metadata.py
```

Expected: ZERO numeric fields on `NewsArticleIngested` (only str/datetime/tuple); ZERO numeric fields on `NewsArticle` (only str/datetime/tuple); `ExtractorMetadata.confidence_extracted: float` is the one numeric field — populated by LLM extractor downstream, NOT by crawler. VietstockAdapter output = same `ScrapedArticle` dataclass + same `NewsArticle` promotion path — ZERO new numeric fields. Record in session log.

### Sub-step 0.6 — Verify primitives still consumable (mirror plan-020/022)

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
# Verify NDHAdapter still importable (sibling reference for shape mimicry)
from packages.infrastructure.news.crawler_adapters import NDHAdapter, CafeFAdapter
print(f'NDHAdapter.source_id={NDHAdapter.source_id}; CafeFAdapter.source_id={CafeFAdapter.source_id}')
"
```

Expected: All imports succeed; SelectorChain is frozen; fields are `[strategies, label]`; both NDHAdapter and CafeFAdapter export cleanly. If any import fails → STOP and reconcile against plan-022 close state.

### Sub-step 0.7 — Verify next-adapter source_id collision check

```bash
# Confirm 'vietstock' source_id is not already registered (sanity check before authoring)
grep -rn "source_id" packages/infrastructure/news/crawler_adapters/
```

Expected: only `cafef_adapter.py` declares `source_id: ClassVar[str] = "cafef"` and `ndh_adapter.py` declares `source_id: ClassVar[str] = "ndh"`. No existing `vietstock` registration. If a stray `vietstock` source_id is found → STOP and reconcile.

### Sub-step 0.8 — Baseline regression floors (mirror plan-022 STEP 0.8; updated for post-S345 floor)

```bash
bash scripts/hooks/firing-tests/run-all.sh 2>&1 | tail -5
bash scripts/hooks/bash-hook-lint.sh 2>&1 | tail -5
python -m pytest packages/ apps/ tests/ -q 2>&1 | tail -3
python -m mypy --strict packages/ apps/ 2>&1 | tail -5
python -m ruff check packages/ apps/ 2>&1 | tail -5
```

Write pre-IMPL pass/fail counts into session log. New modules + tests MUST add to (not regress) these baselines. **Expected pytest floor ≥ 990** (per S354 brief; was 978 before NDH, +12 NDH tests at S344). New Vietstock tests add ≥12 cases per D3 floor.

### Sub-step 0.9 — Smoke-test the existing CafeF + NDH pipelines (zero-regression floor)

```bash
# Confirm CafeFAdapter still works end-to-end with its fixture HTML (zero regression on plan-020 closure)
python -m pytest packages/infrastructure/news/crawler_adapters/test_cafef_adapter.py -q 2>&1 | tail -5
# Confirm NDHAdapter still works end-to-end (zero regression on plan-022 closure including post-S345 store_raw fix)
python -m pytest packages/infrastructure/news/crawler_adapters/test_ndh_adapter.py -q 2>&1 | tail -5
```

Expected: pre-existing CafeF + NDH test counts pass. Record in session log as DC-AGG floor.

### Sub-step 0.10 — STEP 0 summary write into session log

After Sub-steps 0.1-0.9 complete, write a "STEP 0 Summary" section into the session log including:
- Canonical Vietstock host verified (from 0.1)
- robots.txt verdict (from 0.2)
- ToS verdict + URL + date (from 0.3)
- Identified selector candidates for headline/body/date + observed datetime format (from 0.4)
- HTML structure assessment (static vs JS-rendered) (from 0.4)
- Final rate-limit decision (2.0s default OR bumped per Crawl-delay)
- Baseline regression counts (from 0.8)
- CafeF + NDH zero-regression confirmation (from 0.9)
- Any STOP-AND-ASK triggered: yes/no (if yes, halt and surface to main session)

---

## D. Architecture Decisions (DD-1 through DD-10)

### DD-1: Adapter class name = `VietstockAdapter`

**Decision**: Class name `VietstockAdapter` (capital V, capital A — matches Vietstock brand). Source_id = `"vietstock"` (lowercase, consistent with `"cafef"` and `"ndh"`).

**Rationale**: Convention from CafeFAdapter at `packages/infrastructure/news/crawler_adapters/cafef_adapter.py:50-51` and NDHAdapter at `packages/infrastructure/news/crawler_adapters/ndh_adapter.py:116`: class name uses brand-PascalCase; source_id is lowercase hash-key. No deviation justified.

**Adversarial alternate considered**: `VietstockFinanceAdapter` (full-name; matches plan-020 § E matrix line 353 column 1 label "VietstockFinance") → rejected (verbose; subdomain `finance.vietstock.vn` is the same property as `vietstock.vn`; source_id `"vietstockfinance"` adds noise; future code-reference friction). Master plan and plan-020 § E matrix uses "VietstockFinance" as the LABEL but the brand is "Vietstock"; the class name `VietstockAdapter` aligns with parent brand.

### DD-2: Package path = `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py`

**Decision**: Live alongside `cafef_adapter.py` and `ndh_adapter.py` in the existing crawler_adapters subdirectory.

**Rationale**: Path convention established by plan-020 DD-1 + plan-022 DD-2 + ADR D-066: "Concrete adapters live in packages/infrastructure/news/crawler_adapters/". The `__init__.py` currently exports `CafeFAdapter` + `NDHAdapter` (per `packages/infrastructure/news/crawler_adapters/__init__.py:3-6`); this plan extends export list with `VietstockAdapter`.

### DD-3: Strategy A direct-subclass (NOT Strategy B WRAP)

**Decision**: VietstockAdapter directly subclasses `CrawlerAdapter` (ABC) and implements `discover() / fetch_and_parse() / to_news_article()` from scratch. NO wrapping of any legacy class (there is no legacy Vietstock scraper to wrap — this is greenfield).

**Rationale**: Plan-020 § E matrix line 353 explicitly classifies Vietstock as "**A primary + B (Scrapling adaptive fallback) candidate if listing AJAX**". Strategy A is the canonical pattern for all greenfield adapters per plan-022 DD-3 precedent. The "B fallback if listing AJAX" hint is addressed via STEP 0.4 detection branch: if listing-page is AJAX-only but article pages are static, dev passes a fixed `listing_path` of an HTML index page (e.g. `/chung-khoan`) or sitemap URL, NOT the AJAX listing endpoint. Strategy A direct-subclass works for the article-page parse path; AJAX-listing handling is OUT-OF-SCOPE per § B (separate dedicated plan if needed).

**Adversarial alternate considered**: Compose VietstockAdapter from a fresh internal `_VietstockScraper` helper class (mirror CafeF's wrap shape for symmetry) → rejected (per plan-022 DD-3: unnecessary indirection; double-class maintenance from day 1; no behavioral benefit).

### DD-4: SelectorChain[T] usage shape — two-or-three SelectorChain instances per article

**Decision**: VietstockAdapter's `fetch_and_parse()` uses **two SelectorChain[Tag] instances minimum** (matching NDH's post-S344 actual shape at `ndh_adapter.py:206-244`):
1. `headline_chain` — extracts article headline (typical: `<h1 class="title-line">` → `<h1>` → `<meta property="og:title">`)
2. `body_chain` — extracts article body container (typical: `<div class="single-content">` → `<div class="content-detail">` → `<article>`)

Optionally a third for publish_date (only if STEP 0.4 reveals enough DOM-locator variance to warrant it; otherwise use fmt-string fallback inside `_parse_published_at`).

Plus the publish_date parsing itself uses a **fallback list of datetime format strings** mirroring NDH's `_parse_published_at` (`ndh_adapter.py:_parse_published_at` — fmt-string chain for ISO-8601 + Vietnamese locale formats like "%d/%m/%Y %H:%M" — STEP 0.4 confirms Vietstock's actual formats).

**Rationale**: NDH precedent at `ndh_adapter.py:206-244` ships with 2 SelectorChain instances + 1 fmt-string chain. Vietstock follows the same pattern. Using SelectorChain (rather than CafeF's inline `or` chain at `cafef_scraper.py:117-120`) gains: (a) instrumentation — `apply()` returns `(result, num_strategies_tried)` for shape-metrics emit (deferred to Phase 3); (b) explicit `label` per chain for logging; (c) frozen dataclass = no accidental mutation.

**Contract verification** (from reading `apps/_shared/crawl/selector_chain.py:33-105`):
- `SelectorChain[T]` is `Generic[T]`, frozen, slots; fields = `(strategies: Sequence[Callable[[], T | None]], label: str = "(unnamed)")`
- `apply()` returns `tuple[T | None, int]`; logs WARNING if all strategies fail (skill doctrine: "partial output beats whole-pipeline halt")
- Strategies that raise are caught + debug-logged (do NOT propagate); chain continues to next strategy
- BeautifulSoup `Tag` is the typical T

**Selector strategy authoring**: each strategy is a `lambda: soup.find(...)` or `lambda: soup.select_one(...)` — captured at adapter `__post_init__` time after `soup = BeautifulSoup(html, "html.parser")` is parsed. SelectorChain is constructed inside `fetch_and_parse(url)` per call (NOT cached on the adapter), because the `soup` reference inside each lambda closure must reference the current article's soup; SelectorChain itself is cheap (frozen dataclass with a Sequence + str).

**Adversarial alternate considered**: SelectorChain per adapter declared at `__init__` time with selector strategies that take `soup` as an argument → rejected per plan-022 DD-4 (architect verdict: zero-arg Callable contract is correct; closure-over-soup pattern is cheap).

### DD-5: Rate-limit profile — 2.0s default; bump only if STEP 0.2 finds `Crawl-delay` > 2.0s

**Decision**: VietstockAdapter constructs internal `RateLimiter(base_delay=2.0, max_delay=60.0, max_retries=5)` matching plan-020 § E matrix Vietstock profile. **STEP 0.2 may override**: if robots.txt declares `Crawl-delay: N` where N > 2.0, dev bumps `base_delay=N` (mandatory; honor directive).

**Rationale**: Plan-020 § E matrix line 353 "Vietstock ... 2.0s default" (compare line 354 "VietnamBiz ... 3.0s default — skill § Rate Limiting flags VietnamBiz as less lenient"). Vietstock is mainstream VN financial portal; 2.0s prior is reasonable. STEP 0.4 empirical signal: if sample fetch returns 429/503 OR an unusually slow response (>5s) → consider bumping to 3.0s as conservative posture; flag for verifier.

**Adversarial alternate considered**: 1.5s aggressive (Vietstock is high-traffic portal with CDN; assumed lenient) → rejected (no evidence; defer to empirical observation; 2.0s is the prior). 3.0s preemptive (mirror VietnamBiz conservative) → rejected (matrix line 353 doesn't flag Vietstock as less lenient than CafeF/NDH; preemptive bump = over-engineering).

### DD-6: Robots-manager integration — optional injection with `can_fetch` check before each request

**Decision**: VietstockAdapter accepts optional `robots_manager: object = None` constructor arg (mirror CafeFAdapter and NDHAdapter pattern at `cafef_adapter.py:97-98` + `ndh_adapter.py:129`). When provided, the adapter's internal `_fetch_with_optional_chain` calls `robots_manager.can_fetch(url)` BEFORE every HTTP fetch; on disallow → log WARNING + raise RuntimeError (so caller's loop logs + continues per L-S28-1 graceful-degrade doctrine).

**Rationale**: Mirror NDH's proven pattern. RobotsTxtManager primitive at `apps/_shared/crawl/robots_manager.py:119-136` provides `can_fetch(url) -> bool`; returns True on 404 (permissive default per RM7).

**Default behavior**: If `robots_manager=None`, adapter skips the check. CLI `ingest_news_vietstock.py` wires a real RobotsTxtManager at construction time.

### DD-7: F2-AWARE `_fetch_with_optional_chain(url, *, store_raw: bool = True)` from DAY ONE

**Decision**: VietstockAdapter's `_fetch_with_optional_chain` private helper takes a **keyword-only** `store_raw: bool = True` parameter. `discover()` passes `store_raw=False` to avoid persisting listing-page HTML to `data/raw/news/vietstock/` (listing pages are not articles; their raw HTML pollutes the data lake). `fetch_and_parse()` uses the default `store_raw=True`.

**Rationale**: **S345 verifier F2 lesson PROMOTED** — NDH adapter shipped at S344 without the `store_raw` parameter; verifier S345 caught the discover()-also-stores-raw bug as F2 IMPORTANT defect; fix applied inline at S345 close as `ndh_adapter.py:159-160` `_fetch_with_optional_chain(self._absolute(listing_path), store_raw=False)`. Vietstock plan architects this from day 1 — DO NOT repeat the NDH pre-S345 contamination bug.

**Verifier S355 grep-asserts**: `grep -n "store_raw=False" packages/infrastructure/news/crawler_adapters/vietstock_adapter.py` MUST return ≥1 hit in the `discover()` body; `grep -n "def _fetch_with_optional_chain" packages/infrastructure/news/crawler_adapters/vietstock_adapter.py` MUST show the parameter signature `(url, *, store_raw: bool = True)` (keyword-only via `*` per Python idiom for default-bool flags).

**Adversarial alternate considered**: Two separate methods `_fetch_for_article` + `_fetch_for_listing` (no shared helper; simpler call sites) → rejected (code duplication on rate-limit + robots-check + sink-write chain; single helper with kw-only flag is the DRY path NDH adopted post-S345; consistency across adapters per L-S345-3 promotion candidate).

### DD-8: User-agent string — reuse CafeF/NDH UA verbatim

**Decision**: Same UA as CafeF and NDH: `"stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"` (cited at `cafef_scraper.py:35-37`, `ndh_adapter.py:77-79`, and the CLI fetcher at `apps/cli/ingest_news_cafef.py:60-62`).

**Rationale**: Plan-020 § E matrix line 353 explicitly says "Same UA" for Vietstock. Charter I-S34 + skill § Anti-Patterns + skill § Do require "identify user agent" + reject "fake-useragent". The stockforge bot UA is the single canonical identity. Per-source UA differentiation has no benefit (the contact email is the operationally-useful field; identical UA across sources keeps the contact channel simple).

### DD-9: Error handling — mirror NDH shape (return None on parse fail; raise propagates on network fail)

**Decision**: Delegate retry + backoff to the injected `RateLimiter` per plan-020/022 DD-9. `fetch_and_parse()` catches all exceptions during fetch + parse + returns None (per L-S28-1 vendor-drift doctrine); `discover()` lets fetch exceptions propagate (caller's per-listing loop handles).

**Rationale**: Mirror NDH at `ndh_adapter.py:193-198`: `try: html = self._fetch_with_optional_chain(url) except Exception as exc: _log.warning(...); return None`. RateLimiter at `apps/_shared/crawl/rate_limiter.py:123-169` handles 429/503 backoff; 4xx-other-than-429 raises through.

**Circuit-open behavior**: If `RateLimiter.report_response` returns False (circuit-open after max_retries), adapter MUST NOT continue fetching from that domain. For S354 thin slice: mirror NDH posture — log WARNING + skip; circuit-open detection upgrade is a follow-up RM12 carry-forward.

### DD-10: Test fixture strategy — SYNTHETIC minimal HTML inline + ONE real HTML in CLI smoke recorded but NOT committed

**Decision**: Unit tests use SYNTHETIC minimal HTML strings (literal multi-line strings inline within `test_vietstock_adapter.py`). Production-realistic real HTML is fetched ONCE during CLI smoke (Sub-step 0.4 sample); recorded in session log but NOT committed to repo.

**Rationale**:
- **Synthetic for unit tests**: per skill `.claude/skills/crawler-reliability/SKILL.md` § Anti-Patterns: unit tests use deterministic minimal fixtures to test parsing logic
- **Re-distributing scraped HTML**: legal grey-zone per skill § Anti-Patterns ("Committing scraped data without `source_url` violates I-S2 citation rule")
- **CLI smoke as the live-state verification**: one manual smoke records URL/status/bytes/title/body-length/mentioned_tickers

**Adversarial alternate considered**:
- All-real-HTML committed to `tests/fixtures/vietstock/*.html` → rejected (per plan-022 DD-10: fixture-licensing concern; fixtures drift as Vietstock redesigns site)
- All-mocked httpx responses via pytest-httpx → rejected (extra dep; over-engineered)

---

## E. Sub-track decomposition (D1..D5; NEW parallel_with field per plan-025 DD-3)

### D1 — VietstockAdapter implementation (greenfield Strategy A; F2-aware `_fetch_with_optional_chain` from day 1)

- **parallel_with**: []
- **blocks_on**: []
- **coordination_paths_exclusive**: [packages/infrastructure/news/crawler_adapters/vietstock_adapter.py]
- **estimated_wall_min**: 14 (per Phase 1b NDH-actual mirror; D1 in NDH took ~12-15 min wall)

**Module**: `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py` (NEW; ~250-300 LOC).

**Class shape** (architect-proposed; dev adjusts per STEP 0 findings; mirror NDHAdapter `ndh_adapter.py` lines 90-345):

```python
"""VietstockAdapter — CrawlerAdapter implementation for Vietstock (vietstock.vn or finance.vietstock.vn).

Strategy A (direct-subclass) per plan-026 § DD-3.
Second consumer of SelectorChain[T] per plan-026 § DD-4 (after NDH at S344).

Site: vietstock.vn (canonical as of 2026-05-XX; finance.vietstock.vn may be subdomain — STEP 0.1 verifies).

STEP 0 live verification (2026-05-XX S354):
- Canonical host: [STEP 0.1 fills]
- robots.txt: [STEP 0.2 fills]
- ToS: [STEP 0.3 fills]
- JS-rendering: [STEP 0.4 fills] PASS / DEFER
- Article URL pattern: [STEP 0.4 fills]
- Headline: [STEP 0.4 fills]
- Body: [STEP 0.4 fills]
- Date: [STEP 0.4 fills observed format(s)]

I-S34 compliance:
    NO import or use of patchright, playwright_stealth, fake-useragent,
    StealthyFetcher, or any Scrapling Cloudflare-solver path.
    Uses only httpx (via fetcher callable injection) -- D-061 item 4.

Rule 16 compliance:
    fetch_and_parse emits ScrapedArticle with ZERO numeric fields
    (url/title/body_html/body_text/published_at -- no float/Decimal beyond
    datetime). Rule 16 surface preserved by construction (plan-020/022/026
    Schema discipline).

D-059 compliance:
    R1 (datetime-no-tz): clock() returns tz-aware datetime; _parse_published_at
    always attaches tzinfo=UTC when absent.
    R2 (unseeded RNG): no RNG usage.
    R4 (time.time-in-domain): no time.time; clock injectable.

S345 F2-aware design (PROMOTED FROM NDH POST-FIX):
    _fetch_with_optional_chain accepts keyword-only store_raw: bool = True;
    discover() passes store_raw=False to avoid listing-page HTML contamination
    of data/raw/news/vietstock/ (architected from day 1; NOT post-S345 retrofit).

Source: plan 026-S353-phase-d-vietstock-adapter.md Sub-track D1
        STEP 0 live verification recorded in session log 2026-05-XX-session-354.md
        apps/_shared/crawl/selector_chain.py (SelectorChain[T] primitive)
        packages/infrastructure/news/crawler_adapters/ndh_adapter.py (sibling reference — same Strategy A shape; F2 fix already applied)
"""

from __future__ import annotations

import hashlib
import logging
import re
from collections.abc import Callable, Iterable
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import TYPE_CHECKING, ClassVar, cast

from apps._shared.crawl.selector_chain import SelectorChain
from packages.application.news.ports.crawler_adapter import CrawlerAdapter
from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle

if TYPE_CHECKING:
    from bs4 import Tag

# Reuse ScrapedArticle from cafef_scraper (same shape NDH reuses)
from packages.infrastructure.news.cafef_scraper import ScrapedArticle

__all__ = ["VietstockAdapter"]

_log = logging.getLogger(__name__)

# STEP 0.1 verified [DATE]: vietstock.vn is the canonical host. [or finance subdomain]
_DEFAULT_VIETSTOCK_BASE_URL = "https://VERIFIED_HOST"  # FILLED by dev from STEP 0.1
_DEFAULT_USER_AGENT = (
    "stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"
)
# STEP 0.2 verified [DATE]: no Crawl-delay directive in robots.txt; default 2.0s applies
_DEFAULT_RATE_LIMIT_SECONDS = 2.0

# STEP 0.4 verified [DATE]: article URL pattern (e.g. /<category>/<slug>-<id>.htm)
_ARTICLE_URL_RE = re.compile(r"PLACEHOLDER")  # FILLED by dev


@dataclass
class VietstockAdapter(CrawlerAdapter):
    """CrawlerAdapter for vietstock.vn (BC-5 News Stream).

    Strategy A (direct-subclass): implements discover / fetch_and_parse /
    to_news_article from scratch using SelectorChain[T] for headline + body
    extraction. Date extraction uses a fmt-string fallback chain inside
    _parse_published_at. Uses BeautifulSoup for HTML parsing.

    Greenfield — no legacy class to wrap (Strategy A per plan-026 DD-3).
    Second consumer of SelectorChain[T] after NDH (plan-022 S344).

    Default construction::

        adapter = VietstockAdapter(fetcher=_httpx_fetcher)

    With full injections::

        adapter = VietstockAdapter(
            fetcher=_httpx_fetcher,
            rate_limiter=RateLimiter(base_delay=2.0),
            robots_manager=RobotsTxtManager(fetcher=robots_fetcher),
            raw_html_sink=RawHtmlSink(base_dir=Path("data/raw/news")),
            clock=lambda: datetime.now(UTC),
        )
    """

    source_id: ClassVar[str] = "vietstock"

    fetcher: Callable[[str], str]
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    rate_limiter: object = field(default=None)  # RateLimiter | None
    robots_manager: object = field(default=None)  # RobotsTxtManager | None
    raw_html_sink: object = field(default=None)  # RawHtmlSink | None
    base_url: str = _DEFAULT_VIETSTOCK_BASE_URL
    rate_limit_seconds: float = _DEFAULT_RATE_LIMIT_SECONDS

    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from a Vietstock listing page.

        Note: per DD-7 F2-aware design, listing-page HTML is NOT persisted
        (store_raw=False) — avoids contamination of data/raw/news/vietstock/.
        """
        from bs4 import BeautifulSoup

        html = self._fetch_with_optional_chain(
            self._absolute(listing_path), store_raw=False  # DD-7 F2-aware
        )
        soup = BeautifulSoup(html, "html.parser")
        urls: list[str] = []
        seen: set[str] = set()
        for anchor in soup.find_all("a", href=True):
            href = cast(str, anchor["href"])
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
        """Fetch + parse a single Vietstock article URL.

        Mirror NDHAdapter.fetch_and_parse shape (ndh_adapter.py:178-263).
        SelectorChain[T] for headline + body; fmt-string chain for date.
        """
        from bs4 import BeautifulSoup, Tag

        try:
            html = self._fetch_with_optional_chain(url)  # default store_raw=True
        except Exception as exc:
            _log.warning("vietstock_adapter: fetch failed for url=%r: %s", url, exc)
            return None

        soup = BeautifulSoup(html, "html.parser")

        # ---- Headline chain (DD-4 / STEP 0.4 verified [DATE]) ----
        headline_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("h1", class_="PLACEHOLDER_HEADLINE_CLASS"),
                lambda: soup.find("h1"),
                lambda: soup.find("meta", attrs={"property": "og:title"}),
            ],
            label="vietstock_headline",
        )
        headline_tag, _ = headline_chain.apply()
        if headline_tag is None:
            return None
        # (extract text per NDH ndh_adapter.py:224-230 pattern)
        ...

        # ---- Body chain (DD-4 / STEP 0.4 verified [DATE]) ----
        body_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("div", class_="PLACEHOLDER_BODY_CLASS_1"),
                lambda: soup.find("div", class_="PLACEHOLDER_BODY_CLASS_2"),
                lambda: soup.find("article"),
            ],
            label="vietstock_body_container",
        )
        body_container, _ = body_chain.apply()
        if body_container is None:
            return None
        body_text = body_container.get_text(separator="\n", strip=True)
        if not body_text:
            return None

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
        """Promote ScrapedArticle to NewsArticle (mirror NDH ndh_adapter.py:265-300)."""
        haystack = f"{scraped.title}\n{scraped.body_text}"
        mentioned = tuple(t for t in ticker_universe if t.symbol in haystack)
        article_id = hashlib.sha256(scraped.url.encode()).hexdigest()[:16]
        return NewsArticle(
            article_id=article_id,
            source="vietstock",
            source_url=scraped.url,
            title=scraped.title,
            body_excerpt=scraped.body_text[:excerpt_chars],
            published_at=scraped.published_at,
            ingested_at=self.clock(),
            mentioned_tickers=mentioned,
            language="vi",
        )

    # ------ Private helpers ------

    def _fetch_with_optional_chain(self, url: str, *, store_raw: bool = True) -> str:
        """Fetch with rate-limit + robots-check + raw-html-sink chain (all optional).

        DD-7 F2-aware: keyword-only store_raw param; discover() passes False to
        avoid listing-page HTML contamination of data/raw/news/vietstock/.
        Mirror NDHAdapter._fetch_with_optional_chain at ndh_adapter.py:306-345
        (post-S345 fix shape).
        """
        rl = self.rate_limiter
        if rl is not None and hasattr(rl, "wait_if_needed"):
            rl.wait_if_needed(url)
        rm = self.robots_manager
        if rm is not None and hasattr(rm, "can_fetch") and not rm.can_fetch(url):
            _log.warning("vietstock_adapter: robots.txt disallows url=%r — skipping", url)
            raise RuntimeError(f"robots.txt disallows {url!r}")
        html = self.fetcher(url)
        if rl is not None and hasattr(rl, "report_response"):
            rl.report_response(url, 200)
        if store_raw:  # DD-7: only article-fetch path persists raw HTML
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
                        "vietstock_adapter: raw_html_sink.write failed for url=%r: %s",
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
        """STEP 0.4 confirms Vietstock article URL pattern; dev FILLS this method."""
        return bool(_ARTICLE_URL_RE.search(href))

    def _parse_published_at(self, soup: object) -> datetime | None:
        """Best-effort publish-date parse (mirror NDH ndh_adapter.py _parse_published_at).

        STEP 0.4 confirms Vietstock's actual datetime tag candidates + format strings.
        Vietstock historically uses Vietnamese locale '%d/%m/%Y %H:%M' in addition
        to ISO-8601 — dev FILLS the actual list.
        """
        from bs4 import BeautifulSoup, Tag
        if not isinstance(soup, BeautifulSoup):
            return None
        # STEP 0.4 fills tag candidates + format strings
        ...
```

**Note on `ScrapedArticle` re-use**: Imports `ScrapedArticle` from `packages.infrastructure.news.cafef_scraper` (same pragmatic choice NDH made at `ndh_adapter.py:68`). Cleaner long-term path: promote `ScrapedArticle` to `packages/contracts/scraped_article.py` (out-of-scope this bundle; document as carry-forward).

**Pattern statement**: Strategy A direct-subclass; uses `SelectorChain[T]` per chain × 2 (headline, body) + fmt-string chain inside `_parse_published_at`; reuses `_fetch_with_optional_chain(*, store_raw)` pattern from NDH post-S345 fix.

### D2 — HTML parser internals (selector authoring per STEP 0 findings) — merged into D1

D2 is conceptually distinct (selector filling vs adapter scaffolding) but operationally merged into D1: dev fills placeholders in the D1 module body using STEP 0.4 findings. No separate file; no separate sub-track-level commit. Documented here for verifier clarity.

Specifically dev fills:
- `_headline_chain.strategies` — replace placeholder lambdas with verified selectors
- `_body_chain.strategies` — same
- `_is_article_url(href)` — replace placeholder regex with verified URL pattern
- `_DEFAULT_VIETSTOCK_BASE_URL` — replace `"https://VERIFIED_HOST"` with verified canonical host
- `_ARTICLE_URL_RE` — replace `re.compile(r"PLACEHOLDER")` with verified regex
- format strings in `_parse_published_at` — replace placeholder list with verified Vietstock date formats

**Document each replacement in code comments**: `# STEP 0.4 verified 2026-05-XX: <observation>` — gives the verifier audit-trail.

### D3 — Unit tests (≥12 test cases)

- **parallel_with**: [D4, D5]
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py]
- **estimated_wall_min**: 8

**Module**: `packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py` (NEW; ~300-400 LOC).

**Test cases (target ≥12)**:

1. `test_vietstock_adapter_declares_source_id` — `VietstockAdapter.source_id == "vietstock"`
2. `test_vietstock_adapter_can_be_registered` — fresh `CrawlerRegistry()`; `registry.register(VietstockAdapter(fetcher=lambda _: ""))` succeeds; `registry.get("vietstock") is adapter`
3. `test_supports_source_id_positive` — `VietstockAdapter.source_id` matches the registered ID per D-066 contract
4. `test_discover_returns_expected_urls_from_fixture` — synthetic listing HTML with 3 known article anchors; `discover("/listing", max_articles=10)` returns those 3 absolute URLs in order (deduped)
5. `test_discover_respects_max_articles_cap` — synthetic listing with 10 anchors; `discover(..., max_articles=3)` returns exactly 3
6. `test_discover_dedupes_repeat_anchors` — synthetic listing with same URL 5×; returns 1 entry
7. **`test_discover_does_not_persist_raw_html_via_sink`** — Mock RawHtmlSink; assert `sink.write` NOT called when `discover()` runs (DD-7 F2-aware verification — KEY ARCHITECTURAL TEST)
8. `test_fetch_and_parse_happy_path` — synthetic article HTML matching expected Vietstock structure; returns `ScrapedArticle` with correct title + body + published_at
9. `test_fetch_and_parse_returns_none_on_missing_title` — synthetic HTML missing both `<h1>` and `<meta og:title>`; returns None
10. `test_fetch_and_parse_returns_none_on_missing_body_container` — synthetic HTML with title but no body container; returns None
11. `test_fetch_and_parse_falls_back_to_clock_when_no_published_date` — synthetic HTML with title + body but no date tag; published_at == frozen clock value
12. `test_fetch_and_parse_returns_none_on_http_error` — fetcher raises `httpx.HTTPError`; `fetch_and_parse` catches + returns None per L-S28-1
13. `test_fetch_and_parse_uses_selector_chain_fallback` — synthetic HTML where the FIRST headline strategy fails but the SECOND succeeds; returns article with correct title
14. `test_fetch_and_parse_returns_none_when_all_body_selectors_fail` — synthetic HTML with title but no recognized body container; SelectorChain WARNING logged + returns None
15. `test_to_news_article_populates_mentioned_tickers` — `ScrapedArticle` with title mentioning "VHM" and body mentioning "FPT"; `to_news_article(scraped, [Ticker("VHM"), Ticker("FPT"), Ticker("HPG")])` returns `NewsArticle.mentioned_tickers == (Ticker("VHM"), Ticker("FPT"))`
16. `test_to_news_article_excerpt_caps_at_excerpt_chars` — body_text=10000 chars; result body_excerpt len == 4000
17. `test_adapter_uses_injected_rate_limiter` — Mock RateLimiter; assert `wait_if_needed` + `report_response` called once each per fetch
18. `test_adapter_skips_url_when_robots_disallows` — Mock RobotsTxtManager returning `can_fetch=False`; `fetch_and_parse(url)` returns None (RuntimeError caught internally)
19. **`test_fetch_and_parse_writes_raw_html_via_sink`** — Mock RawHtmlSink; assert `.write()` called with correct args (source_id="vietstock", url, html, fetched_at tz-aware) — companion to test 7
20. `test_adapter_default_no_injections_still_works` — `VietstockAdapter(fetcher=lambda _: SYNTHETIC_HTML)` no injections; `fetch_and_parse` still returns ScrapedArticle

**Minimum acceptance**: ≥12 of the above 20 (architect proposes 12 as floor; tests 7 + 19 are MANDATORY — they validate DD-7 F2-aware design).

**Synthetic fixture HTML** (architect proposes; dev refines per STEP 0.4):

```python
_SYNTHETIC_VIETSTOCK_ARTICLE_HTML = """<!DOCTYPE html>
<html>
<head>
  <meta property="og:title" content="VHM dự kiến đạt lợi nhuận quý 1 ổn định" />
  <meta property="article:published_time" content="2026-05-15T10:30:00+0700" />
</head>
<body>
  <h1 class="PLACEHOLDER_HEADLINE_CLASS">VHM dự kiến đạt lợi nhuận quý 1 ổn định</h1>
  <div class="PLACEHOLDER_BODY_CLASS_1">
    <p>Công ty cổ phần Vinhomes (VHM) công bố kết quả kinh doanh quý 1...</p>
    <p>FPT cũng được kỳ vọng có tăng trưởng tích cực.</p>
  </div>
</body>
</html>
"""

_SYNTHETIC_VIETSTOCK_LISTING_HTML = """<!DOCTYPE html>
<html><body>
  <a href="/co-phieu/vhm-loi-nhuan-quy-1-12345.htm">VHM Q1</a>
  <a href="/co-phieu/fpt-tang-truong-12346.htm">FPT growth</a>
  <a href="/co-phieu/hpg-quan-su-12347.htm">HPG news</a>
  <a href="/co-phieu/vhm-loi-nhuan-quy-1-12345.htm">VHM Q1 (duplicate)</a>
  <a href="/about-us">About</a>
</body></html>
"""
```

### D4 — Registry wire + CLI smoke

- **parallel_with**: [D3, D5]
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [packages/infrastructure/news/crawler_adapters/__init__.py, apps/cli/ingest_news_vietstock.py]
- **estimated_wall_min**: 8

**Module 1**: `packages/infrastructure/news/crawler_adapters/__init__.py` UPDATED:

```python
"""BC-5 News infrastructure — per-source crawler adapters."""

from .cafef_adapter import CafeFAdapter
from .ndh_adapter import NDHAdapter
from .vietstock_adapter import VietstockAdapter

__all__ = ["CafeFAdapter", "NDHAdapter", "VietstockAdapter"]
```

**Module 2**: `apps/cli/ingest_news_vietstock.py` (NEW; ~300 LOC). Mirror `apps/cli/ingest_news_ndh.py` structure exactly:
- click CLI with same flags (`--tickers`, `--since`, `--max-articles`, `--listing`, `--output`, `--skip-llm`, `--summary`)
- `_httpx_fetcher` helper with same UA pattern
- `_robots_fetcher` helper for RobotsTxtManager
- `main()` constructs:
  - `httpx_fetcher = _httpx_fetcher` (closure)
  - `rate_limiter = RateLimiter(base_delay=DD-5-value, max_delay=60.0, max_retries=5)`
  - `robots = RobotsTxtManager(fetcher=_robots_fetcher)`
  - `sink = RawHtmlSink(base_dir=Path("data/raw/news"))`
  - `registry = CrawlerRegistry()`
  - `registry.register(VietstockAdapter(fetcher=httpx_fetcher, rate_limiter=rate_limiter, robots_manager=robots, raw_html_sink=sink))`
  - `adapter = registry.get("vietstock")`
  - per-URL loop mirroring NDH CLI
- Persist via existing `SqliteNewsRepository` + `SqliteClaimRepository`
- LLM extraction via existing `ClaudeLlmExtractor` + `ClaimExtractionService` (UNLESS `--skip-llm`)
- Emit `NewsArticleIngested` + `ExtractedClaimPublished` events (UNLESS `--skip-llm`)
- Exit code 0 on success; click `UsageError` on invalid input
- Summary markdown output (sentiment counts + first 5 articles)

**CLI smoke (live verification — manual; recorded in session log)**:

```bash
python apps/cli/ingest_news_vietstock.py \
  --tickers VHM,FPT,HPG \
  --max-articles 1 \
  --listing /chung-khoan \
  --output ./data/tmp-vietstock-smoke.sqlite \
  --skip-llm \
  --summary 2>&1 | tee /tmp/vietstock-smoke.log
```

Record in session log:
- Status codes observed (200 expected; any 4xx/5xx flagged)
- Bytes fetched per request
- Total wall-clock time (validates rate-limit honored)
- Number of articles successfully parsed
- Verify `data/raw/news/vietstock/<date>/<hash>.html` exists with expected content
- Verify NO `data/raw/news/vietstock/.../<listing-page-hash>.html` exists (DD-7 F2-aware verification — listing-page raw HTML MUST NOT be persisted)
- Verify SQLite contains 1 NewsArticle row with source="vietstock"
- Verify `--summary` output matches expected markdown shape

### D5 — ADR D-066 REV-2 amendment (Vietstock cited as 2nd consumer)

- **parallel_with**: [D3, D4]
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md]
- **estimated_wall_min**: 3

Add an **Amendments** entry to `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` § Amendments (append-only). REV-1 already exists from S345 close per plan-022 § L (NDH = 1st consumer); REV-2 documents Vietstock = 2nd consumer.

**Proposed amendment text** (architect-drafted; dev verifies + lands at S354 close):

```markdown
### REV-2 (2026-05-XX) — Vietstock adapter shipped as 2nd Strategy A consumer; SelectorChain[T] contract maturity 1 → 2 consumers

- **Trigger**: plan-026-S353 ships VietstockAdapter as second greenfield Strategy A direct-subclass + second SelectorChain[T] consumer (after NDH at S344)
- **Authorization**: plan-026 § L (architect-proposed) + S355 verifier acceptance (pending)
- **Source artifacts**:
  - agent-workspace/session-plans/completed/026-S353-phase-d-vietstock-adapter.md § DD-4 + § D1 + § H 5-source-evidence chain row 2
  - packages/infrastructure/news/crawler_adapters/vietstock_adapter.py (NEW; uses 2 SelectorChain[T] instances for headline + body fields; fmt-string chain for date)
  - packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py (NEW; ≥12 test cases including SelectorChain fallback coverage AND DD-7 F2-aware test 7 + 19)
  - apps/cli/ingest_news_vietstock.py (NEW; CLI dispatch via fresh CrawlerRegistry + VietstockAdapter registration)
- **Summary of changes**:
  - CrawlerAdapter ABC contract validated across 2 distinct greenfield consumers (NDH + Vietstock); contract maturity strengthens — no contract gap surfaced (subject to verifier S355 re-confirmation per AQ-8)
  - SelectorChain[T] contract validated across 2 distinct VN financial sites; primitive proven production-ready
  - DD-7 F2-aware design `_fetch_with_optional_chain(*, store_raw)` shipped from day 1 in Vietstock — promotion of S345 verifier F2 lesson into upstream design discipline (L-S345-3 candidate)
- **Verifier impact**: S355 spot-checks VietstockAdapter's SelectorChain usage + DD-7 F2-aware design empirically (grep for `store_raw=False` in discover() body; CLI smoke verifies no listing-page HTML in data/raw/)
- **Next consumer**: VietnamBiz adapter (plan-027 S356) — 3rd of 4 priority sources; rate-limit bumped to 3.0s per plan-020 § E matrix line 354
```

**Session log**: `agent-workspace/memory/sessions/2026-05-XX-session-354.md` per CLAUDE.md § Session Protocol End — captures STEP 0 sub-step results + D1-D5 outcomes + DD-7 F2-aware verification + ADR REV-2 amendment + mistakes (if any) + harness gaps surfaced.

**Observation file**: `agent-workspace/memory/observations/sandwich-dev-S354-vietstock-adapter.md` — dev's return artifact per Track 6.

---

## F. DoD checklist (≥30 items)

Aggregated across all 5 sub-tracks; verifier S355 confirms each empirically:

### File-existence DC (DC-FILE-N)

- [ ] **DC-FILE-1** — `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py` exists
- [ ] **DC-FILE-2** — `packages/infrastructure/news/crawler_adapters/__init__.py` exports `VietstockAdapter` alongside `CafeFAdapter` + `NDHAdapter`
- [ ] **DC-FILE-3** — `packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py` exists (mirrors NDH test-file path convention)
- [ ] **DC-FILE-4** — `apps/cli/ingest_news_vietstock.py` exists
- [ ] **DC-FILE-5** — ADR D-066 § Amendments has new REV-2 entry per § D5
- [ ] **DC-FILE-6** — `agent-workspace/memory/sessions/2026-05-XX-session-354.md` exists
- [ ] **DC-FILE-7** — `agent-workspace/memory/observations/sandwich-dev-S354-vietstock-adapter.md` exists
- [ ] **DC-FILE-8** — `data/raw/news/vietstock/<YYYY-MM-DD>/<hash>.html` exists (proves CLI smoke wrote raw HTML for article path)
- [ ] **DC-FILE-9** — NO listing-page HTML persisted under `data/raw/news/vietstock/` (DD-7 F2-aware verification; KEY — verifies discover() did NOT call sink.write)

### LOC + structure DC (DC-LOC-N)

- [ ] **DC-LOC-1** — `vietstock_adapter.py` LOC is between 200 and 350 (architect estimate; dev reports actual; mirror NDH `ndh_adapter.py` ~349 LOC)
- [ ] **DC-LOC-2** — Test file LOC is between 250 and 500 (≥12 test cases per architect floor)
- [ ] **DC-LOC-3** — CLI LOC is between 250 and 400 (mirrors `ingest_news_ndh.py` per existing layout)

### VietstockAdapter contract DC (DC-IMPL-N)

- [ ] **DC-IMPL-1** — `VietstockAdapter.source_id == "vietstock"` (ClassVar; non-empty)
- [ ] **DC-IMPL-2** — `VietstockAdapter` subclasses `CrawlerAdapter` (NOT wraps; Strategy A direct-subclass per DD-3)
- [ ] **DC-IMPL-3** — `VietstockAdapter` implements all 3 abstract methods: `discover`, `fetch_and_parse`, `to_news_article`
- [ ] **DC-IMPL-4** — `VietstockAdapter.fetch_and_parse` uses ≥2 `SelectorChain[T]` instances (DD-4)
- [ ] **DC-IMPL-5** — `VietstockAdapter` accepts optional injections: `rate_limiter`, `robots_manager`, `raw_html_sink` (all default None; mirrors NDH shape)
- [ ] **DC-IMPL-6** — `VietstockAdapter` uses verified UA `"stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"` (DD-8)
- [ ] **DC-IMPL-7** — `VietstockAdapter._fetch_with_optional_chain` signature is `(url: str, *, store_raw: bool = True) -> str` (DD-7 F2-aware; keyword-only via `*`)
- [ ] **DC-IMPL-8** — `VietstockAdapter.discover` body contains `store_raw=False` literal (DD-7 F2-aware; verifier grep-asserts)

### I-S34 + Rule 16 compliance DC (DC-COMPLIANCE-N)

- [ ] **DC-COMPLIANCE-1** — `grep -rE "patchright|playwright_stealth|playwright-stealth|fake[-_]useragent|UndetectedAdapter|StealthyFetcher|_cloudflare_solver" packages/infrastructure/news/crawler_adapters/vietstock_adapter.py apps/cli/ingest_news_vietstock.py packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py` returns ZERO matches (I-S34 HARD REJECT verification)
- [ ] **DC-COMPLIANCE-2** — `VietstockAdapter.fetch_and_parse` emits `ScrapedArticle` with ZERO new numeric fields (Rule 16 by construction)
- [ ] **DC-COMPLIANCE-3** — robots.txt verdict from STEP 0.2 documented in session log; verifier re-runs protego check
- [ ] **DC-COMPLIANCE-4** — Rate-limit profile (2.0s default OR bumped per Crawl-delay) documented in session log + reflected in CLI construction
- [ ] **DC-COMPLIANCE-5** — UA string verified verbatim in CLI fetcher AND in adapter docstring reference

### Deterministic gates DC (DC-GATE-N)

- [ ] **DC-GATE-1** — `python -m mypy --strict packages/infrastructure/news/crawler_adapters/ apps/cli/ingest_news_vietstock.py` exits 0
- [ ] **DC-GATE-2** — `python -m ruff check packages/infrastructure/news/crawler_adapters/ apps/cli/ingest_news_vietstock.py` exits 0
- [ ] **DC-GATE-3** — `python -m pytest packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py -q` exits 0; ≥12 new test cases pass (mandatory: tests 7 + 19)
- [ ] **DC-GATE-4** — `python -m pytest packages/ apps/ tests/ -q` exits 0; new test count = STEP 0.8 baseline + ≥12; ZERO regression on baseline
- [ ] **DC-GATE-5** — `bash scripts/hooks/firing-tests/run-all.sh` exits 0 (no firing-test regression)
- [ ] **DC-GATE-6** — `bash scripts/hooks/python-determinism-check.sh </dev/null` exits 0 on Vietstock new modules (D-059 R1/R2/R4 compliance)
- [ ] **DC-GATE-7** — `bash scripts/hooks/atomic-write-check.sh </dev/null` exits 0 on Vietstock new modules (D-062 — RawHtmlSink already wraps atomic)
- [ ] **DC-GATE-8** — `bash scripts/hooks/path-safety-check.sh </dev/null` exits 0 on Vietstock new modules (D-064 — RawHtmlSink already uses safe_path)

### CLI smoke DC (DC-SMOKE-N)

- [ ] **DC-SMOKE-1** — Manual CLI smoke executed; recorded in session log with timestamp + status code + bytes fetched + parsed-article count
- [ ] **DC-SMOKE-2** — Smoke produced ≥1 row in `data/tmp-vietstock-smoke.sqlite` with `source="vietstock"`
- [ ] **DC-SMOKE-3** — Raw HTML file for ARTICLE exists at `data/raw/news/vietstock/<YYYY-MM-DD>/<hash>.html` per DC-FILE-8
- [ ] **DC-SMOKE-4** — NO listing-page HTML under `data/raw/news/vietstock/` per DC-FILE-9 (DD-7 F2-aware empirical verification — `find data/raw/news/vietstock -newer <smoke-start>` returns only article-page hashes; verifier re-runs)
- [ ] **DC-SMOKE-5** — Wall-clock time of smoke ≥ rate_limit_seconds × N_requests (validates RateLimiter honored)

### Bookkeeping DC (DC-BOOK-N)

- [ ] **DC-BOOK-1** — Session log `2026-05-XX-session-354.md` written per CLAUDE.md § Session Protocol End
- [ ] **DC-BOOK-2** — `agent-workspace/memory/current-execution.md` updated: Phase D Theme L row reflects S354 Vietstock-adapter SHIPPED; next-action = S355 sandwich-verifier dispatch
- [ ] **DC-BOOK-3** — `agent-workspace/memory/mistake-log.md` either appended (M-S354-N if mistakes) OR session log explicitly states "no mistakes this session" (enforced by `session-end-checklist-linter.sh` Stop hook)
- [ ] **DC-BOOK-4** — Plan moved `pending/026-S353-phase-d-vietstock-adapter.md` → `completed/026-S353-phase-d-vietstock-adapter.md` at S355 close (NOT at S354 close — verifier acceptance gates the move)
- [ ] **DC-BOOK-5** — D-066 § Amendments REV-2 added per § D5

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why Strategy A direct-subclass, not Strategy B WRAP?

**Answer**: No existing Vietstock scraper code exists to wrap. Same rationale as plan-022 AQ-1 for NDH. Vietstock is greenfield — no legacy. Strategy A is the canonical pattern for greenfield adapters per plan-020 § E matrix line 353 and plan-022 DD-3 precedent.

### AQ-2 — Why SelectorChain[T] consumption now (2nd consumer)?

**Answer**: NDH was the 1st consumer at S344; Vietstock is the 2nd. Multiple consumers validate the primitive's contract maturity (plan-026 § L REV-2 amendment formalises this). Two-consumer threshold = "production-ready primitive" by L-S256-1 + AP-7 promote-or-retire calculus.

### AQ-3 — Why subclass not Protocol/ABC composition?

**Answer**: Per D-066 § Decision — CrawlerAdapter is ABC; subclass enforces `__init_subclass__` guard that runs at class-definition time (verifying non-empty `source_id` ClassVar). Protocol can't enforce at definition time. Same rationale as plan-022 AQ-3.

### AQ-4 — Why not also do VietnamBiz in same plan (bundle two adapters)?

**Answer**: RM4 from plan-020/022 § Risk table (S4 catastrophic-mix-pattern). Each per-source adapter requires its own STEP 0 live verification; bundling 2 sources doubles STEP 0 work + adds 2 separate HTML-fixture authoring efforts + 2 separate CLI files + 2 separate ADR amendments. Per master plan § 6.4 per-source FOCUSED_IMPL budget envelope; 2 sources = potential 250K cap risk. Architect verdict: SPLIT — one source per session. Vietstock first (this plan = 026); VietnamBiz = 027 (S356).

### AQ-5 — STEP 0 finds both candidate URLs 404 — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Dev writes `STOP-FINDING-S354-vietstock-urls-404.md` to `human-workspace/notifications/`. Defer Vietstock adapter; flag in mistake-log as `M-S354-N: Vietstock site defunct or moved`; surface in observation.

### AQ-6 — STEP 0 finds robots.txt disallows — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Honor robots.txt absolutely (I-S34 charter line 110). Defer Vietstock adapter; flag in mistake-log; main session may decide to abandon Vietstock as source or contact for explicit consent.

### AQ-7 — STEP 0 finds site is JS-rendered (requires Playwright) — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Per I-S34 HARD BAN of patchright + playwright_stealth + StealthyFetcher (D-061 § Decision item 4), cannot install JS-rendering infrastructure. Defer Vietstock adapter; flag as harness gap. Per master plan line 353 "AJAX for some report listings (hypothesis; verify)" — if ARTICLE pages are JS-rendered → DEFER; if only LISTING is AJAX but article pages are static → PROCEED with static-listing alternative (sitemap URL OR `/chung-khoan` HTML index path).

### AQ-8 — SelectorChain[T] contract doesn't fit Vietstock layout — what then?

**Answer**: Surface as plan-026 finding; STOP and choose Path B (new D-067 ADR amendment per § D5 Path B mirror from plan-022). Do NOT silently bypass the contract. Architect prediction: contract is well-formed; NDH validated it; Vietstock should validate it too (n=2 maturity).

### AQ-9 — Test fixture HTML licensing (re-distributing scraped HTML in tests) — OK?

**Answer**: Use SYNTHETIC minimal HTML for unit tests (per DD-10). Real HTML used ONLY for CLI smoke recorded in session log but NOT committed (saved to `tmp/vietstock_sample.html` which dev MUST ensure is gitignored). Verifier S355 grep-asserts: `grep -rE "vietstock\.vn" packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py` returns ZERO real-URL leakage in test fixtures (synthetic-only).

### AQ-10 — Rate-limit 2.0s — is it conservative enough?

**Answer**: 2.0s is the default per plan-020 § E matrix line 353. STEP 0.2 may override (mandatory bump if `Crawl-delay > 2.0`). STEP 0.4 empirical signal: if sample fetch returns 429/503 OR an unusually slow response (>5s) → consider bumping to 3.0s. If STEP 0.4 returns 200 cleanly within 1s → 2.0s is fine. Dev decides at IMPL time; flag rate-limit decision for verifier in session log.

---

## H. 5-source-evidence chain per adopted pattern (matches plan-020/022 § H shape)

| Adopted pattern | (1) Source file:line | (2) Skill / deep-dive | (3) Integration X-ref | (4) Charter invariant | (5) Stockforge codebase precedent |
|---|---|---|---|---|---|
| **Strategy A direct-subclass of CrawlerAdapter** | `packages/application/news/ports/crawler_adapter.py:43-127` (ABC + 3 abstract methods + `__init_subclass__` enforcer) | ADR D-066 § Decision + .claude/skills/ddd-tactical-patterns/SKILL.md (adapter/port discipline) | Plan-020 § E matrix line 353 "Vietstock ... A primary + B (Scrapling adaptive fallback) candidate if listing AJAX" + plan-022 DD-3 NDH precedent | I-S2 (source_url + as_of preserved); I-S22 (data lineage via source_id ClassVar) | **NDHAdapter at `packages/infrastructure/news/crawler_adapters/ndh_adapter.py:90-345` — 1st greenfield Strategy A direct-subclass; Vietstock = 2nd, validates pattern at n=2** |
| **SelectorChain[T] consumption for headline/body (2nd consumer)** | `apps/_shared/crawl/selector_chain.py:33-105` (frozen dataclass; `apply()` returns `(result, num_tried)`; logs WARNING if all fail) | .claude/skills/crawler-reliability/SKILL.md § Selector Robustness | ADR D-066 § REV-1 closed item 12 (NDH 1st consumer; this plan REV-2 adds Vietstock 2nd consumer per § L) + plan-022 DD-4 | I-S34 (graceful degrade); I-S22 (label per chain for shape-metrics emit) | NDHAdapter at `ndh_adapter.py:206-244` — 2 SelectorChain instances (headline + body); Vietstock mirrors with same shape |
| **F2-aware `_fetch_with_optional_chain(*, store_raw)` from day 1** | `packages/infrastructure/news/crawler_adapters/ndh_adapter.py:306-345` (post-S345 fix shape) | S345 verifier observation F2 IMPORTANT finding + L-S345-3 promotion candidate | This plan DD-7 (promotes the post-fix shape into upstream design discipline) | I-S22 (raw HTML preserved for reprocessing — but ONLY for ARTICLE pages; listing pages would pollute the lake) | NDH adapter pre-S345 was missing store_raw param; post-S345 fix at `ndh_adapter.py:159-160` (discover passes store_raw=False) + `ndh_adapter.py:336` (sink.write gated on store_raw); Vietstock adopts post-fix shape from day 1 |
| **RateLimiter primitive with seeded RNG** | `apps/_shared/crawl/rate_limiter.py:79-169` (DomainState + RateLimiter; `wait_if_needed` + `report_response` returning circuit-open bool) | crawl4ai `async_dispatcher.py:28-85` (RateLimiter source) + .claude/skills/crawler-reliability/SKILL.md § Rate Limiting | ADR D-066 § Foundation primitives table + plan-020 DD-7 | I-S34 (≥2s/domain default; 429/503 backoff); D-059 R2 (seeded RNG Random(0)) | CafeFAdapter + NDHAdapter both wire RateLimiter via `_fetch_with_optional_chain` helper; Vietstock mirrors |
| **RobotsTxtManager primitive with protego** | `apps/_shared/crawl/robots_manager.py:52-152` (sync port; lazy-import protego; in-memory cache) | Scrapling `spiders/robotstxt.py:10-60` (source) + .claude/skills/crawler-reliability/SKILL.md § Anti-Patterns | ADR D-066 § Foundation primitives table + plan-020 DD-6 | I-S34 charter line 110 "News scrapers respect robots.txt + reasonable rate limits + identify user agent" | CafeFAdapter + NDHAdapter both wire RobotsTxtManager via optional injection; Vietstock mirrors |

---

## I. Risk-Mitigation table (RM1..RM11)

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| RM1 | **STEP 0 finds neither candidate URL works** (`vietstock.vn` AND `finance.vietstock.vn` both 404 / DNS-fail) | Very Low (Vietstock is a major VN financial portal; one of these should resolve) | High (no adapter possible; defer entire bundle) | STOP-AND-ASK per § C STEP 0 STOP clause + § G AQ-5 pre-answered. |
| RM2 | **STEP 0 finds site is JS-rendered** (article body requires JavaScript to populate DOM) | Med (modern VN news sites sometimes use Next.js / Vue / React; Vietstock has historical reputation for AJAX-heavy report pages but article pages tend static) | High (I-S34 HARD REJECT of Playwright) | STOP-AND-ASK per § C STEP 0 STOP clause + § G AQ-7 pre-answered. **AJAX-listing carve-out**: if ONLY listing-page is AJAX (article pages static), use alternative static listing path (sitemap or HTML category index); flag for verifier. |
| RM3 | **SelectorChain[T] primitive needs refinement** | Very Low (n=1 NDH validation; architect predicts n=2 Vietstock will validate further) | Med (delays adapter ship by 1 session; requires D-067 ADR) | Path B per § D5 (mirror plan-022 § D5 Path B). Surface to verifier S355 for review. |
| RM4 | **Dev mistakenly attempts VietnamBiz too** (scope-creep; same anti-pattern as plan-020/022 RM4) | Low (plan explicitly scopes to Vietstock only + § B Out-of-scope item + AQ-4 pre-answers) | High (S4 catastrophic-mix-pattern recurrence; budget overrun) | Plan title + Goal + § B + AQ-4 EXPLICITLY scope to Vietstock only. |
| RM5 | **Rate-limit 2.0s insufficient** (Vietstock returns 429/503 under default rate-limit) | Low-Med (no evidence Vietstock is less lenient than CafeF/NDH; STEP 0.4 empirically verifies) | Med (transient failures; ToS-grey territory) | Fall back to 3.0s per DD-5 fallback + flag for verifier. RateLimiter `report_response` handles 429/503 with exponential backoff automatically. |
| RM6 | **protego dependency missing or version drift** | Low (plan-020 closure added; verify at STEP 0.6) | Low (lazy-import in RobotsTxtManager raises ImportError with install hint) | STEP 0.6 verifies all 6 primitives importable + sibling NDH + CafeF adapters import. If protego import fails → `pip install -e .` to ensure pyproject.toml deps installed. |
| RM7 | **Vietstock publishes no robots.txt** (404 on `/robots.txt`) | Low (Vietstock is a professional portal; robots.txt expected) | Low (allow-all on 404 is the conservative correct behavior per `robots_manager.py:119-136`) | Per RobotsTxtManager `can_fetch` returns True on 404 (semantically correct). Skill § Anti-Patterns documents: absent robots.txt is NOT green light for unlimited fetching — rate-limit + UA still apply. |
| RM8 | **Test fixture HTML drift** | Low (synthetic fixtures decoupled from live; STEP 0.4 sample saved to tmp only) | Low (fixture tests still validate parsing logic; CLI smoke catches drift at next deploy) | Synthetic HTML per DD-10 + AQ-9. Real HTML in CLI smoke only. If CLI smoke fails post-deploy → trigger M-S<N>-N investigate-Vietstock-drift entry. |
| RM9 | **VietstockAdapter accidentally introduces new LLM-numeric field** (Rule 16 D-065 violation) | Low (audit + STEP 0.5 anchor) | High (charter Principle 9 violation) | § C STEP 0.5 empirically confirms ZERO new numeric fields; VietstockAdapter emits SAME `ScrapedArticle` dataclass as NDH/CafeF. Verifier S355 DC-COMPLIANCE-2 is final gate. |
| RM10 | **I-S34 banned import creeps in** (patchright, playwright_stealth, fake-useragent, StealthyFetcher, _cloudflare_solver) | Very Low (CLAUDE.md hard rules + ADR D-066 § HARD REJECTED list + DC-COMPLIANCE-1 grep check) | Critical (charter-tier violation per D-061 § Decision item 4) | DC-COMPLIANCE-1 grep check at verifier S355; architect recommends dev SHOULD run grep BEFORE first commit. Any match = HARD FAIL — STOP and remove. |
| **RM11** | **DD-7 F2-aware regression: dev forgets `store_raw=False` in discover()** (recreates NDH pre-S345 listing-page contamination bug) | **Low** (architected from day 1 in this plan vs NDH retrofit; explicit DC-IMPL-7 + DC-IMPL-8 + tests 7 + 19 + DC-SMOKE-4 + DC-FILE-9 quintuple-guard the regression) | **High** (data lake corruption — listing-page HTML pollutes article-data tier; if undetected for many sources, requires cleanup pass) | **DC-IMPL-7** verifies method signature has `*, store_raw: bool = True`. **DC-IMPL-8** grep-asserts `store_raw=False` literal in discover() body. **Test 7** asserts sink.write NOT called during discover(). **Test 19** asserts sink.write IS called during fetch_and_parse(). **DC-SMOKE-4** empirically verifies post-smoke filesystem state. **DC-FILE-9** baseline cross-check. **No silent regression possible.** |

---

## J. Coordination paths (main session AVOIDS during S354 IMPL)

**Main session AVOIDS** during S354 IMPL window (cross-session edit conflict prevention; mirror plan-022 § J; NEW per plan-025 — `coordination_paths_exclusive` sets per sub-track for parallel-dispatch safety):

- `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py` (NEW — D1)
- `packages/infrastructure/news/crawler_adapters/__init__.py` (MODIFIED — D4)
- `packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py` (NEW — D3)
- `apps/cli/ingest_news_vietstock.py` (NEW — D4)
- `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` (MODIFIED — D5 REV-2 amendment)
- `agent-workspace/memory/sessions/2026-05-XX-session-354.md` (NEW — authored by S354 dev at end)
- `agent-workspace/memory/observations/sandwich-dev-S354-vietstock-adapter.md` (NEW — S354 dispatch observation file)
- `data/raw/news/vietstock/**` (NEW — CLI smoke writes raw HTML here)
- `data/tmp-vietstock-smoke.sqlite` (NEW — CLI smoke output; ephemeral)
- `tmp/vietstock_sample.html` (NEW — STEP 0.4 sample HTML; ephemeral; gitignored)

**Coordination-paths-exclusive disjointness (per plan-025 DD-4 lint contract)**:
- D1 set: {vietstock_adapter.py} — disjoint from D3 + D4 + D5
- D3 set: {test_vietstock_adapter.py} — disjoint from D4 + D5 (and D1)
- D4 set: {__init__.py, ingest_news_vietstock.py} — disjoint from D3 + D5 (and D1)
- D5 set: {066-bc5-crawler-adapter-contract.md} — disjoint from D3 + D4 (and D1)
- All 4 parallel sets are disjoint ✓ — lint passes; parallel-dispatch SAFE
- Max-3-parallel ceiling per Q-PL1: D3 + D4 + D5 = 3 ✓ at ceiling not over

**Main session MAY** continue work on (orthogonal):
- Any other `apps/cli/ingest_*.py` not `ingest_news_vietstock.py`
- Other ADRs in `agent-workspace/memory/decisions/` outside D-066
- `agent-workspace/research/`, `agent-workspace/master-plans/`, `agent-workspace/proposals/`, `agent-workspace/calibration/`, `agent-workspace/thesis-log/`
- `packages/_shared/path_safety.py` is READ-ONLY for S354 dev (W0-5 dependency)
- `apps/_shared/crawl/**` is READ-ONLY for S354 dev (plan-020 closed primitives; no modification per § B Out-of-scope)
- `packages/application/news/ports/**` is READ-ONLY for S354 dev (CrawlerAdapter ABC frozen per D-066)
- `packages/infrastructure/news/cafef_scraper.py` + `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` + `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` are READ-ONLY for S354 dev (CafeF + NDH shipped; no modification per § Hard rules)
- Other `packages/` BCs outside news (BC-1/2/3/4/6/7/8/9 unaffected)

**Commit boundary** (D-060 active): S354 dev MAY commit at IMPL close in a single coherent commit OR split per sub-track. Recommended message stems:

- Option A (single commit): `S354: Phase D Vietstock adapter — Strategy A direct-subclass + SelectorChain[T] 2nd consumer + DD-7 F2-aware day-1 + CLI + D-066 REV-2`
- Option B (3 commits — if parallel D3+D4+D5 dispatch + each child commits):
  - `S354: D1 — VietstockAdapter implementation (Strategy A direct-subclass; SelectorChain[T] 2nd consumer; DD-7 F2-aware from day 1)`
  - `S354: D3+D4 — Vietstock tests + CLI + registry wire`
  - `S354: D5 — ADR D-066 REV-2 amendment (Vietstock = 2nd consumer)`

Do NOT push.

---

## K. Budget recommendation

**Budget**: ~100-150K Opus FOCUSED_IMPL (per Phase 1b calibration mirror of NDH S344 + Opus rate adjustment).

**Breakdown estimate** (Phase 1b calibrated):
- STEP 0 verification (Sub-steps 0.1-0.10): ~15-20K (live URL probes + robots.txt parse + ToS read + sample HTML structure analysis + 6-primitive import check + baseline regression run)
- D1 VietstockAdapter implementation: ~25-35K (~250-300 LOC adapter; mirror NDH `ndh_adapter.py` shape with DD-7 F2-aware day-1; 2× SelectorChain instances)
- D2 HTML parser internals (selector authoring): ~10-15K (replacing 4-5 placeholder selectors with verified ones per STEP 0.4) — merged operationally into D1
- D3 Unit tests: ~25-35K (~300-400 LOC tests; ≥12 cases including mandatory tests 7 + 19; synthetic fixtures inline)
- D4 Registry wire + CLI: ~15-25K (~300 LOC CLI mirror of `ingest_news_ndh.py`; init export update)
- D5 ADR REV-2 amendment: ~5-10K (REV-2 entry; ~50 LOC)
- Session log + observation file: ~10-15K
- Reserve for STEP 0 findings adjusting scope: ~20% = 20-30K

**Total**: ~125-185K, fitting within FOCUSED_IMPL 100-150K envelope IF STEP 0 finds no JS-rendering / no robots-block (the expected happy path). If STEP 0 surfaces complications (RM3 SelectorChain gap → Path B D-067), may need MULTI_TASK_IMPL upgrade.

**Split recommendation**: Single FOCUSED_IMPL session is preferred. Architect verdict: do NOT split as PLAN+IMPL pair — architectural decisions are already made in this plan (DD-1 through DD-10); dev executes against the recipe.

**Parallel-dispatch projection** (Phase 1b NEW directive per plan-025):
- Sequential baseline (NDH actual): ~31 min wall (full dev cycle)
- Parallel-dispatch projected (D3+D4+D5 post-D1): D1 (~14 min) + parallel(D3=8, D4=8, D5=3) → max=8 min → total ~22 min wall = ~29% reduction
- **This is the FIRST PRODUCT-tier plan with parallel-dispatch declaration** — observation captures actual wall-time at S355 verifier close; calibration corpus expands

---

## L. ADR D-066 amendment plan (REV-2)

**Plan-026 explicitly extends D-066 § Amendments with REV-2 documenting Vietstock = 2nd consumer.**

At S354 completion, D-066 § Amendments gains REV-2 entry (architect-drafted in § D5 above; dev verifies + lands at S354 close as part of D5 sub-track).

The REV-2 entry SUSTAINS NDH-REV-1 (does NOT supersede) — REV-2 is additive contract-maturity attestation, not contract change. The CrawlerAdapter ABC + SelectorChain[T] contracts remain UNCHANGED.

**Side-effect promotion candidate L-S345-3** (DD-7 F2-aware day-1 design): once Vietstock ships with `store_raw` parameter from day 1 (vs NDH's post-S345 retrofit), the pattern is REUSABLE for VietnamBiz (plan-027) + any future adapter. The promotion candidate is: "Strategy A adapter template MUST declare `_fetch_with_optional_chain(*, store_raw: bool = True)` from day 1" — promote to crawler-reliability SKILL once VietnamBiz also adopts day-1 (n=2 instances of avoiding-the-retrofit). Architect surfaces this; verifier S355 considers ADR promotion path.

---

## END OF PLAN

**Plan summary**:
- Pre-flight: STEP 0 has 10 sub-steps; BLOCKING (live URL verification + robots.txt + ToS + sample HTML analysis + primitive imports + baseline regression + CafeF/NDH zero-regression)
- Architecture decisions: DD-1 through DD-10 (10 decisions made + pre-answered)
- Sub-tracks: D1 (adapter; serial root), D2 (parser internals; merged into D1), D3 (tests ≥12; parallel with D4+D5), D4 (registry + CLI; parallel with D3+D5), D5 (ADR REV-2; parallel with D3+D4)
- **NEW per plan-025**: every sub-track declares `parallel_with` + `blocks_on` + `coordination_paths_exclusive` + `estimated_wall_min`; lint-validates disjoint paths + max-3-parallel ceiling + cycle-free DAG
- DoD: 35 items across DC-FILE/LOC/IMPL/COMPLIANCE/GATE/SMOKE/BOOK categories (incl. DD-7 F2-aware-specific DC-IMPL-7/8 + DC-FILE-9 + DC-SMOKE-4)
- Architecture questions: AQ-1 through AQ-10 (10 questions pre-answered)
- 5-source-evidence chain: 5 rows (Strategy A subclass + SelectorChain[T] 2nd consumer + DD-7 F2-aware day-1 + RateLimiter + RobotsTxtManager)
- Risk-Mitigation: RM1 through **RM11** (11 risks tracked with mitigations; **NEW RM11** = DD-7 F2-aware regression guard)
- Coordination: 10 paths main session AVOIDS during S354 IMPL; disjointness validated for parallel-dispatch
- Budget: 100-150K Opus FOCUSED_IMPL (Phase 1b calibrated from NDH S344 actual)
- ADR amendment: D-066 REV-2 (Vietstock = 2nd consumer; contract maturity attestation)
- Parallel projection: ~29% wall-time reduction vs sequential (D3+D4+D5 parallel post-D1)
- **DOGFOOD CONTEXT**: First architect plan post-plan-025 IMPL; first to CONSUME Phase 1b self-calibration + first to DECLARE `parallel_with` fields per sub-track per DD-3 contract
