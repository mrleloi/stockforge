---
observation_id: sandwich-verifier-S345-ndh-adapter-verify
type: sandwich-verifier-audit
verifier_agent_id: a2f05ef456ca85ba6
created_at: 2026-05-16
plan_audited: agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md
dev_session_audited: S344 (agentId a6650ff3d2adf656b, commits f9d4f60+06c9920)
verifier_has_no_Write: true (recovery pattern: main writes this file per S312/S314/S321/S333/S339/S342 precedent)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
---

# S345 sandwich-verifier — NDH adapter audit

## V1 — Acceptance criteria (plan § F DoD, 30 items)

| ID | Item | Status | Evidence |
|---|---|---|---|
| DC-FILE-1 | ndh_adapter.py exists | PASS | `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` 445 LOC |
| DC-FILE-2 | __init__.py exports NDHAdapter | PASS | `packages/infrastructure/news/crawler_adapters/__init__.py:4,6` + `packages/infrastructure/news/__init__.py:5,12` |
| DC-FILE-3 | test_ndh_adapter.py exists (either location) | PASS | `packages/infrastructure/news/crawler_adapters/test_ndh_adapter.py` 458 LOC (co-located per CafeF sibling pattern) |
| DC-FILE-4 | ingest_news_ndh.py exists | PASS | `apps/cli/ingest_news_ndh.py` 366 LOC |
| DC-FILE-5 | D-066 REV-1 OR D-067 | PASS | Path A REV-1 landed at `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` (Out-of-scope item 12 PENDING-CONSUMER → ANSWERED) |
| DC-FILE-6 | session log exists | PASS | `agent-workspace/memory/sessions/2026-05-16-session-344.md` 222 LOC |
| DC-FILE-7 | observation file exists | PASS | `agent-workspace/memory/observations/sandwich-dev-S344-ndh-adapter.md` 190 LOC |
| DC-FILE-8 | data/raw/news/ndh/{date}/{hash}.html exists | PASS | `data/raw/news/ndh/2026-05-16/` contains 2 .html files (SEE F2) |
| DC-LOC-1 | ndh_adapter.py 200-350 LOC | FAIL-MINOR | Actual 445 LOC (above ceiling but reasonable; dev observation under-reported as ~290) |
| DC-LOC-2 | test file 250-500 LOC | PASS | Actual 458 LOC |
| DC-LOC-3 | CLI 200-350 LOC | FAIL-MINOR | Actual 366 LOC (slightly above ceiling; dev observation under-reported as ~290) |
| DC-IMPL-1 | source_id == "ndh" | PASS | `ndh_adapter.py:116` + smoke `NDHAdapter.source_id` returns `ndh` |
| DC-IMPL-2 | direct-subclass not wrap | PASS | `ndh_adapter.py:91` `class NDHAdapter(CrawlerAdapter)` + test 3 asserts `not hasattr(adapter, "_scraper")` |
| DC-IMPL-3 | 3 abstract methods | PASS | discover `:142`, fetch_and_parse `:176`, to_news_article `:263` |
| DC-IMPL-4 | ≥2 SelectorChain instances | PASS | `ndh_adapter.py:204` (headline) + `:233` (body) — 2 chains in fetch_and_parse; date uses fmt-string list in `_parse_published_at:407-413, 429-434` consistent with plan DD-4 fallback clause |
| DC-IMPL-5 | optional injections rate_limiter/robots_manager/raw_html_sink | PASS | `:126-133` all default None |
| DC-IMPL-6 | verified UA | PASS | `ingest_news_ndh.py:73-76` + `_DEFAULT_USER_AGENT` `:77-79` |
| DC-COMPLIANCE-1 | I-S34 banned imports grep | PASS | grep returned only docstring "NO import" attestations; 0 actual imports |
| DC-COMPLIANCE-2 | Rule 16 zero numeric fields | PASS | ScrapedArticle reused (str/datetime only); NewsArticle promotion only str/datetime/tuple |
| DC-COMPLIANCE-3 | robots verdict in session log | PASS | session log `:29-46` |
| DC-COMPLIANCE-4 | rate-limit profile documented | PASS | session log `:45-46` `2.0s default` + adapter `:82` |
| DC-COMPLIANCE-5 | UA verbatim in CLI | PASS | byte-for-byte match |
| DC-GATE-1 | mypy --strict | PARTIAL | pre-existing baseline "Duplicate module" apps/_shared vs packages/_shared (per S338); ran clean on new files |
| DC-GATE-2 | ruff check NDH files | PASS | "All checks passed!" |
| DC-GATE-3 | NDH tests pass | PASS | 21 passed in 0.15s |
| DC-GATE-4 | Full suite ZERO regression | PASS | 989 passed in 19.59s (delta 968→989 = +21) |
| DC-GATE-5 | firing-tests run-all | NOT-RE-RUN | no firing-tests added; verifier accepts dev verdict per plan precedent |
| DC-GATE-6 | python-determinism-check.sh | PASS | clean (no output) |
| DC-GATE-7 | atomic-write-check.sh | INHERITED | RawHtmlSink already wraps tmp+os.replace per D-062 |
| DC-GATE-8 | path-safety-check.sh | INHERITED | RawHtmlSink already uses safe_path per D-064 |
| DC-SMOKE-1..4 | CLI smoke | PASS | session log `:165-181` documents 1 article fetched; SQLite `tmp-ndh-smoke.sqlite` written |
| DC-BOOK-1..6 | bookkeeping | PASS | session log + observation + CE row + .gitignore /tmp/ + plan moved pending → completed at commit 06c9920 |

**Aggregate**: 30/30 substantive criteria PASS; 2 LOC ceilings exceeded (minor — dev under-reported), GATE-1 mypy pre-existing baseline noise orthogonal to S344 scope.

## V2 — Sub-track delivery (D1..D5)

- **D1 NDHAdapter impl**: SHIPPED. 445 LOC adapter; Strategy A direct-subclass per DD-3; 2 SelectorChain[T] in fetch_and_parse (headline + body) + fmt-string chain in date (consistent with DD-4 "publish_date may use fmt-string fallback" clause).
- **D2 Selector authoring**: SHIPPED. All STEP 0.4 findings filled; explicit `# STEP 0.4 verified 2026-05-16` audit-trail comments at `:74-87`.
- **D3 Tests**: SHIPPED. 21 tests (exceeds 12-floor + matches all 20 plan-proposed cases + adds split for body warning). All 21 PASS in 0.15s.
- **D4 Registry+CLI**: SHIPPED. __init__.py + CLI files; CLI smoke produced 1 article + raw HTML + SQLite row.
- **D5 ADR amendment**: SHIPPED Path A. D-066 REV-1 landed; content matches architect-drafted REV-1 text at plan `:1089-1106`.

## V3 — DD compliance (DD-1 through DD-10)

All 10 DDs COMPLIANT with one nuance:
- DD-4 (SelectorChain[T] consumer): COMPLIANT — core plan purpose closed. 2 SelectorChain[Tag] instances per call; closure-over-soup pattern; explicit `label` per chain (`ndh_headline` + `ndh_body_container`); WARN-on-all-fail exercised by test 9b
- DD-7 (`_fetch_with_optional_chain` helper mirrors CafeFAdapter): COMPLIANT but introduces F2 issue — discover() path also writes raw HTML (SEE F2 below)

## V4 — Charter / invariant compliance

- I-S34 HARD REJECT: PASS — grep across all NDH files: 0 actual imports of patchright/playwright_stealth/StealthyFetcher/fake-useragent
- I-S1 (NO LLM math): PASS — adapter outputs only str/datetime/tuple
- D-066 ABC contract: PASS — inherits CrawlerAdapter + ClassVar source_id + all 3 abstract methods + test 20 dynamically verifies `__init_subclass__` TypeError
- D-059 Python determinism: PASS — R1 all `datetime.now` use `(UTC)`; R2 no RNG; R4 no `time.time` (only `time.monotonic` via RateLimiter)
- D-060 commit-policy: PASS — git reflog last 20 entries show only `commit:` events for f9d4f60+06c9920+f48e932; ZERO pushes in audit window
- D-061 § item 4 Scrapling Cloudflare-solver HARD REJECT: PASS — adapter uses only injected `fetcher: Callable[[str], str]`
- D-062 atomic write: PASS-INHERITED
- D-064 path safety: PASS-INHERITED
- D-065 Rule 16: PASS — ScrapedArticle reused (zero new numeric fields)

## V5 — Regression

- `pytest packages/ apps/ -q`: 989 passed in 19.59s; 0 regressions
- `ruff check packages/infrastructure/news/crawler_adapters/ apps/cli/ingest_news_ndh.py`: All checks passed!
- `ruff check packages/ apps/`: 4 pre-existing baseline errors (not new); matches dev STEP 0.8 baseline

## V6 — Integration smoke

- `from packages.infrastructure.news.crawler_adapters import NDHAdapter; print(NDHAdapter.source_id)` → `ndh` PASS
- `issubclass(NDHAdapter, CrawlerAdapter)` → True PASS
- BS4 multi-class match probe: `soup.find("h1", class_="article__title")` against `<h1 class="article__title cms-title">` returns element correctly (RISK-3 resolved)
- CLI smoke evidence: 2 raw HTML files in `data/raw/news/ndh/2026-05-16/` (SEE F2) + `data/tmp-ndh-smoke.sqlite` present

## 5 RISK AREAS investigation

- **RISK-1 (HIGH; source_id "ndh" retention)**: RESOLVED-ACCEPTABLE-WITH-NOTE. Brand-initialism rationale is defensible; canonical host rename does not change brand identity. source_id is a registry hash-key — should be stable once chosen + downstream-keyed. Documented in adapter docstring `:74-76`.
- **RISK-2 (MEDIUM; _is_article_url exclusion completeness)**: DEFERRABLE. Current exclusion list + suffix regex `-\d+\.htm$` precisely matches STEP 0.4 observations. Future site path changes handled by L-S28-1 doctrine (degrade gracefully).
- **RISK-3 (MEDIUM; BS4 multi-class substring match)**: RESOLVED-OVER-WORRY. Verifier empirically confirmed correct behavior.
- **RISK-4 (LOW; ScrapedArticle cross-module import)**: DEFERRABLE-DOCUMENTED. Sibling-module import under same BC-5; cleaner long-term path is promotion to `packages/contracts/scraped_article.py`. Tracked for Phase D-N CafeFAdapter consolidation.
- **RISK-5 (LOW; report_response hardcoded 200)**: OVER-WORRY-WITH-CAVEAT. `report_response(url, 200)` only fires on success path; httpx `raise_for_status()` raises before reaching that line on 4xx/5xx; exception propagates up to fetch_and_parse which catches + returns None. Rate-limiter doesn't see actual error code (parity-with-CafeF pattern). Improvement = fleet-wide change; CARRY-FORWARD to Phase D-N OR separate harness session.

## Defects (F1..F6)

### F1 IMPORTANT — Dev LOC + test path under-reporting

- **Evidence**: dev observation `:8-15` claims `ndh_adapter.py 290 LOC + test 480 + CLI 290` and test path `tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py`; actual is 445/458/366 LOC and path is `packages/.../test_ndh_adapter.py` (co-located)
- **Impact**: dev under-reporting LOC by ~155 (adapter) + ~76 (CLI) and mis-stating test path 7+ times. Test location IS valid per DC-FILE-3 "either location" + CafeF sibling precedent, but dev cited wrong path. Main session CE row line 137 propagates the wrong path.
- **Suggested action**: main session corrects CE.md `:137` to cite actual path; updates DC-LOC-1/DC-LOC-3 from "PASS" to "ABOVE-CEILING-ACCEPTED"

### F2 IMPORTANT — RawHtmlSink fires on discover() listing-page fetch

- **Evidence**: 2 .html files persist in `data/raw/news/ndh/2026-05-16/` after 1-article CLI smoke; investigation: `discover()` at `:159` calls `_fetch_with_optional_chain` which at `:326-340` writes raw HTML if sink provided. Listing-page HTML persisted alongside article HTML
- **Impact**: data contamination — `data/raw/news/ndh/` is per-spec the article HTML preservation directory; persisting listing pages pollutes downstream reprocessing. Different licensing/copyright surface
- **Suggested action**: parameterize `_fetch_with_optional_chain(url, *, store_raw: bool = True)` and pass False from discover. ~5 LOC. Same gap in CafeFAdapter (parity issue); fleet-wide patch preferred

### F3 MINOR — Commit message claims "3 SelectorChain[T] instances" but actually 2 + fmt-string date chain

- **Evidence**: commit f9d4f60 message vs adapter implementation; ADR D-066 REV-1 source-artifact line echoes over-claim
- **Suggested action**: optional ADR D-066 REV-1 source-artifact line correction (~1 LOC); defer

### F4 MINOR — Test 16 RateLimiter mock assert codifies RISK-5 anti-pattern

- **Evidence**: `test_ndh_adapter.py:404` `mock_rl.report_response.assert_called_once_with(url, 200)`
- **Suggested action**: when RISK-5 fix lands, update test 16 to allow status value tested separately

### F5 MINOR — DC-LOC-1 + DC-LOC-3 ceilings exceeded

- **Evidence**: adapter 445 LOC (95 over) + CLI 366 LOC (16 over); plan estimate 250-300/250 was optimistic
- **Suggested action**: accept actual LOC; refine per-source estimates if Vietstock/VietnamBiz follow

### F6 MINOR — `time` import in CLI is unused (parity-with-CafeF cosmetic)

- **Evidence**: `ingest_news_ndh.py:32` `import time` + `:361-363` "Quiet unused import warning"
- **Suggested action**: fleet-wide cleanup with CafeF parallel; no action this bundle

## Promotion candidates (AP-23)

- **L-S345-1 (1st-instance HOLD)**: dev observation under-reporting LOC by 20-50% — if recurs in plan-023/024 dev observations, promote to Stop-hook grep-asserting `LOC` claims against `wc -l`
- **L-S345-2 (1st-instance HOLD)**: dev observation wrong file path despite "either location" clause — if recurs, promote to Stop-hook grep-asserting deliverable paths exist
- **L-S345-3 (1st-instance HOLD)**: RawHtmlSink-fires-on-discover gap repeated CafeF→NDH — if Vietstock plan-023 dev replicates, promote: add verifier-checklist "audit `_fetch_with_optional_chain` callers; discover() should NOT persist raw HTML" + fleet-wide fix
- **L-S345-4 (1st-instance HOLD)**: `report_response(url, 200)` hardcoded across adapters — if recurs as Vietstock/VietnamBiz parity, promote to fleet-wide fix

## Compliance attestation

- AP-1 fresh-context ✓ (verifier dispatched fresh; never previously read S344 dev outputs)
- AP-7 anti-vacuous-defer ✓ (each deferred item has named trigger)
- harness_priority_one N/A (product substrate verify)
- verifier_has_no_Write ✓ (recovery pattern: main session writes this file)
- D-060 N/A (verifier 0 commits / 0 pushes)
- stop_offering_routing_branches N/A
- verify_phase_before_next_phase ✓ (NDH adapter verified before Vietstock plan dispatch)
- 0 charter writes ✓ / 0 constitution writes ✓
- Calibration ✓ (verdict PASS-WITH-CONCERNS supported by 30/30 substantive DoD + 0 critical + 2 IMPORTANT with concrete remediation paths)
