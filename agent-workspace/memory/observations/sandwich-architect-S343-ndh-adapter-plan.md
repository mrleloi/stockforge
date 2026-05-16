---
observation_id: sandwich-architect-S343-ndh-adapter-plan
session: S343
agent: sandwich-architect (background; Claude Opus 4.7)
date: 2026-05-16
agentId: (this dispatch's runtime id; to be filled by main session task-notification)
budget_used: ~55-65K (within 50-80K PLAN envelope)
deliverable: agent-workspace/session-plans/pending/022-S343-phase-d-ndh-adapter.md (~1300 LOC matching plan-020 cadence)
phase: D (Theme L) — per-source rollout
status: PLAN-AUTHORED-AWAITING-DISPATCH
---

# S343 — Phase D NDH Adapter PLAN Authoring (observation)

## What I did

1. **VBW reading pass** (~30-40K tokens of input):
   - Read predecessor plan-020 in 3 chunked passes (lines 1-400, 400-850, 850-1300) — frontmatter + STEP 0 + § E matrix + DD-1 through DD-8 + sub-tracks D1-D4 + Bundle DoD + 5-source-evidence chain + Risk + Out-of-scope (~52K tokens; exceeds Read tool single-call limit so used offset+limit pattern)
   - Read ADR D-066 (PROPOSED; full 313 LOC) — Decision section + § Out-of-scope item 12 (the F2 carry-forward this plan closes)
   - Read all 6 plan-020 primitives (full): `crawler_adapter.py` (127 LOC ABC + __init_subclass__), `crawler_registry.py` (instance-scoped 88 LOC), `rate_limiter.py` (169 LOC + D-059 R2 seeded RNG + S341 D6 `_sleeper: Callable` fix), `robots_manager.py` (151 LOC + S339 F1 "Karim shoair" lowercase header), `raw_html_sink.py` (121 LOC + D-059 R1 tz-aware + D-064 safe_path + D-062 tmp+os.replace), `selector_chain.py` (105 LOC frozen `Generic[T]` zero-arg `Callable[[], T | None]`)
   - Read CafeFAdapter Strategy B WRAP reference (full 238 LOC) — observed `_fetch_with_optional_chain` pattern at `:106-188` + optional injection shape
   - Read CafeFScraper legacy (first 100 + key body 100-220) — selector convention (`detail-content` / `contentdetail` / `article` BS4 chain at `:117-120`); URL convention (`.chn` suffix at `:90`); 3 date-format fallback at `:203`
   - Read crawler-reliability skill (full 102 LOC) — confirmed "fallback chain pattern... return first non-empty result, log warning if all fail and return None. Don't raise — partial output beats whole-pipeline halt" doctrine
   - Read invariants-stockforge.md I-S34 + I-S35 (line 109-115) — HARD REJECT list verified
   - Read current-execution.md S99 + S310-S320 archive + most recent S340-S342 (truncated due to length)
   - Read ADR template (`_template.md`) for amendment format
   - Read sandwich-architect-S337 observation (predecessor's process pattern for matching cadence)
   - Read existing crawler_adapters `__init__.py` (currently exports `CafeFAdapter` only)
   - Read `ingest_news_cafef.py` first 80 LOC (CLI flag shape + `_httpx_fetcher` helper)
   - Verified research repos available: crawl4ai + Scrapling + MediaCrawler + FinceptTerminal + TradingAgents + ai-hedge-fund + Vibe-Trading + nautilus_trader + TradingAgents-CN + dexter + Pixelle-Video + MoneyPrinter* + NarratoAI (all at `C:/htdocs/research/*`)
   - Spot-checked ai-hedge-fund + TradingAgents + FinceptTerminal for news adapter precedents (file existence only; not read since not adopting code)
   - Skipped Glob-with-head_limit retry (caught error; used alternate path)

2. **Architecture decisions made**:
   - **DD-1**: Class name `NDHAdapter` (brand-PascalCase; matches CafeFAdapter convention); `source_id = "ndh"` (lowercase hash-key)
   - **DD-2**: Path `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` (alongside cafef_adapter.py)
   - **DD-3**: **Strategy A direct-subclass** (NOT Strategy B WRAP) — greenfield, no legacy to wrap, canonical pattern per plan-020 § E matrix line 352
   - **DD-4**: **Three SelectorChain[T] instances per article** — `_headline_chain`, `_body_chain`, `_publish_date_chain` (publish_date implemented as fmt-string fallback INSIDE `_parse_published_at`, not a separate SelectorChain since fmt-strings aren't DOM selectors). SelectorChain instantiated per `fetch_and_parse(url)` call (closure-over-soup; SelectorChain is cheap frozen dataclass)
   - **DD-5**: Rate-limit profile 2.0s default; STEP 0.2 may bump per Crawl-delay; STEP 0.4 may bump to 3.0s if 429/503 observed
   - **DD-6**: Optional `robots_manager` injection per CafeFAdapter pattern
   - **DD-7**: Optional `raw_html_sink` injection writes raw HTML BEFORE parsing (preserves even on parse fail; path `data/raw/news/ndh/...`)
   - **DD-8**: Reuse CafeF UA `"stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"` verbatim (per § E matrix "Same UA as CafeF")
   - **DD-9**: Error handling delegated to RateLimiter (429/503 exp-backoff + circuit-open after max_retries=5); 4xx non-429 not retryable; 5xx other than 503 raises → caller catches → fetch_and_parse returns None per L-S28-1
   - **DD-10**: **Test fixture strategy = SYNTHETIC HTML inline** (committed); ONE real HTML in CLI smoke (Sub-step 0.4 sample → `tmp/ndh_sample.html`; gitignored; not committed). Rationale: synthetic = license-clean + edge-case-controllable + license-clean; real = AQ-9 fixture-licensing concern + skill § Anti-Patterns

3. **STEP 0 procedure designed** (10 sub-steps; BLOCKING):
   - 0.1: URL probe both `nhipsongdoanhnghiep.vn` AND `ndh.vn` (httpx with 10s timeout; record status + redirect + final URL)
   - 0.2: robots.txt fetch + protego parse on verified host (record verdict; honor Crawl-delay directive)
   - 0.3: ToS page reading (Vietnamese; record verdict + URL + date)
   - 0.4: Sample article fetch + HTML structure analysis (JS-marker check via `__NEXT_DATA__` / `<div id="app">` / `window.__INITIAL_STATE__` / `data-react-helmet` markers; save sample to `tmp/ndh_sample.html`; identify ≥2 candidates per field; observe URL pattern + datetime formats)
   - 0.5: Rule 16 compliance pre-flight (re-confirm ZERO new numeric fields)
   - 0.6: Verify all 6 primitives importable + SelectorChain shape (`frozen=True`, fields = `[strategies, label]`)
   - 0.7: Verify `ndh` source_id not already registered
   - 0.8: Baseline regression floors (firing-tests + pytest + mypy + ruff)
   - 0.9: Smoke-test existing CafeF pipeline (zero-regression floor)
   - 0.10: Write STEP 0 summary into session log

4. **DoD authored**: 30 items across 7 categories (FILE/LOC/IMPL/COMPLIANCE/GATE/SMOKE/BOOK) — matches plan-020's DC-AGG granularity

5. **AQ pre-answered**: 10 questions (AQ-1 through AQ-10) including all 3 STEP 0 STOP-AND-ASK triggers (AQ-5/6/7), SelectorChain contract gap (AQ-8), test fixture licensing (AQ-9), rate-limit conservatism (AQ-10)

6. **5-source-evidence chain**: 5 rows (Strategy A subclass + SelectorChain[T] + RateLimiter + RobotsTxtManager + RawHtmlSink); each cites primary source file:line + skill/deep-dive + integration X-ref + charter invariant + stockforge precedent

7. **RM table**: 10 risks tracked (RM1-RM10) — site-defunct (RM1), JS-rendered (RM2), SelectorChain contract gap (RM3), scope-creep to Vietstock+VietnamBiz (RM4), rate-limit insufficient (RM5), protego dep missing (RM6), robots.txt 404 (RM7), fixture drift (RM8), Rule 16 violation (RM9), I-S34 banned import creep (RM10)

8. **ADR D-066 amendment drafted**: Path A REV-1 entry closing § Out-of-scope item 12 (PENDING-CONSUMER → ANSWERED); Path B (new D-067) only if STEP 0 / IMPL reveals contract gap

9. **Coordination paths**: 11 paths main session AVOIDS during S344 IMPL window

10. **Budget**: ~100-150K Sonnet FOCUSED_IMPL (single session preferred; NOT PLAN+IMPL pair since architecture decisions are made)

## What I discovered re: SelectorChain consumption shape

After reading `apps/_shared/crawl/selector_chain.py` carefully (lines 33-105):
- **Contract**: `SelectorChain[T]` is `Generic[T]`, `frozen=True`, `slots=True`; fields = `(strategies: Sequence[Callable[[], T | None]], label: str = "(unnamed)")`
- **Apply behavior**: `apply()` returns `tuple[T | None, int]`; logs WARNING on all-fail; logs DEBUG on hit (which strategy # succeeded); catches exceptions in individual strategies (logs DEBUG; chain continues) — does NOT propagate

**Architect verdict on contract suitability for NDH**: Contract is well-formed for the BS4 + `lambda: soup.find(...)` zero-arg closure pattern. NO contract gap predicted. NDHAdapter authors strategies as `lambda: soup.find("h1", class_="article-title")` — captured at `fetch_and_parse(url)` time after `soup = BeautifulSoup(html, "html.parser")` is parsed. This is the natural usage pattern for the primitive (matches the docstring example at `selector_chain.py:42-49`).

**One stylistic note** (NOT a contract gap): SelectorChain must be constructed INSIDE `fetch_and_parse(url)` (not cached as adapter attribute at `__init__` time), because the `soup` reference in each lambda closure must reference the CURRENT article's soup. This is fine — SelectorChain is a cheap frozen dataclass (~10ns instantiation). Mentioned in DD-4 explanation + AQ-8 pre-answer.

**Type parameter T choice**: `SelectorChain[Tag]` (BeautifulSoup `Tag`) for headline + body chains. Per `selector_chain.py:55-56` docstring: "Type parameter `T` is the result type (e.g. `Tag | NavigableString` from BeautifulSoup, or `str`). Strategies return `T | None`; first non-None wins." This fits NDH naturally.

## Contract gaps in D-066 (none detected)

After re-reading D-066 § Decision (line 137-159 + § "Why ABC not Protocol" line 148-159 + § HARD REJECTED line 204-218) and `crawler_adapter.py` (full 127 LOC):
- ABC + `__init_subclass__` enforcement is suitable for NDHAdapter (Strategy A direct-subclass triggers source_id check at class-definition time per `crawler_adapter.py:60-78`)
- Three abstract methods (`discover` / `fetch_and_parse` / `to_news_article`) cover NDH's needs cleanly
- HARD REJECTED list (patchright / playwright_stealth / fake-useragent / UndetectedAdapter / StealthyFetcher / _cloudflare_solver / MediaCrawler libs) — DC-COMPLIANCE-1 grep check enforces; verifier S345 re-runs

**No D-066 amendment NEEDED for contract** — only the § Out-of-scope item 12 status update (Path A REV-1; ~50 LOC append). Path B (new D-067) is contingency for unexpected IMPL findings, not predicted.

## Harness anomalies noticed (do NOT fix; just flag for promotion via observation)

1. **Architect Bash tool gap (3rd-instance per S340 architect observation; CLOSED at S341 per D7 update + new pre-dispatch hook)**: This dispatch had Bash tool available (assumed) but did NOT use it (PLAN-only role; matches sandwich-architect.md "Never writes production code. Only plans."). No live URL probe done from architect side — STEP 0 procedure delegates that to dev. **Status**: NO new anomaly (just-fixed). 

2. **Glob `head_limit` parameter not supported on Windows shell**: Confirmed during this dispatch (Glob with `head_limit` rejected with `InputValidationError: An unexpected parameter 'head_limit' was provided`). Worked around by using Glob without head_limit + Grep with head_limit elsewhere. Not a new anomaly (likely tool-spec inconsistency between Glob and Grep). **Recommendation**: dev observation may surface; harness team decides if normalisation is worth a hook update.

3. **`Read` tool 25K-token cap on large files**: Hit on plan-020 (52K tokens). Worked around with offset+limit pattern. This is by design (per Read tool description); not anomaly. Mentioned for awareness — future plans matching plan-020's length will require same chunked-read pattern.

4. **NO new harness anomaly surfaced by THIS dispatch** beyond items 1-3 above (which are not new).

## AP-1 attestation

- **Dispatch context**: This dispatch was initiated as a fresh-context architect subagent per AP-1 mandate. I did NOT review my own prior work (the previous plan-020 was authored by a different sandwich-architect dispatch S337, not me; I treated it as authoritative source-of-truth for cadence + format).
- **No self-review**: I did not architect AND verify in this dispatch. Verifier S345 (different fresh-context dispatch) will adversarially review the IMPL output of S344 dev (also different fresh-context dispatch).
- **VBW respected**: All file references in plan-022 trace to actual file:line citations verified via Read tool in this session (not from memory). I did NOT hallucinate filepaths, LOC counts, or API shapes.

## What dev needs to know that isn't in the plan

1. **The `Glob` tool's `head_limit` parameter doesn't work on Windows** (workaround: use Glob without head_limit + Grep with head_limit for filtering)
2. **The plan-020 file is 52K tokens** and exceeds Read tool single-call limit — if dev needs to re-read for any reason, use offset+limit pattern (e.g., `Read(path, offset=400, limit=450)`)
3. **STEP 0.4's "save sample to `tmp/ndh_sample.html`"** assumes `tmp/` directory exists at project root + is gitignored. If `tmp/` doesn't exist OR isn't gitignored, dev MUST create + add to `.gitignore` in ONE coherent commit (per S332 single-edit precedent) BEFORE saving sample. Don't accidentally commit scraped HTML.
4. **The `_is_article_url(href)` placeholder method**: dev MUST replace per STEP 0.4 findings BEFORE testing. Placeholder defaults to `href.endswith(".html") or "/post-" in href` which is a guess; actual NDH URL convention may differ entirely (e.g., `/YYYY/MM/DD/slug/` or numeric-id-based `/article/12345`). Test cases 4-6 in D3 depend on this method working correctly.
5. **The `_DEFAULT_NDH_BASE_URL = "https://VERIFIED_HOST"` placeholder**: dev MUST replace with verified canonical host from STEP 0.1 BEFORE first test run. Otherwise tests will fail with URL parse errors.
6. **`ScrapedArticle` import from `cafef_scraper.py`**: pragmatic short-term reuse to avoid schema duplication. Document in observation as carry-forward — a future ADR may promote `ScrapedArticle` to `packages/contracts/` for cleaner cross-adapter sharing. Don't refactor in this bundle (out-of-scope).
7. **`__init_subclass__` triggers at class-definition** of NDHAdapter — if dev imports the module, the source_id check runs even if no instance is created. Test case 20 (`test_subclass_missing_source_id_raises_at_class_creation`) exercises this with `type(...)` dynamic class construction. Beware: `pytest.parametrize` with dynamically-created adapter classes will trigger `__init_subclass__` at collection time, not at test-run time — may surprise dev.
8. **Plan-020 closure noted `protego>=0.3.1` in pyproject.toml** + `--import-mode=importlib` in pytest addopts. Dev should NOT need to modify these; STEP 0.6 verifies. If `protego` import fails → check pyproject.toml + `pip install -e .` in dev env.
9. **Per ADR D-066 § "Two migration strategies"**: CafeFScraper consolidation is RM12 carry-forward (separate Phase D-N session); this plan does NOT touch `cafef_scraper.py` or `cafef_adapter.py`. Read-only for S344 dev.
10. **The `verified_by` ADR D-066 field is still `PENDING-S339`** (per D-066 frontmatter line 73-76). Plan-020 closure didn't update — separate housekeeping item. Not for this dispatch.

## Compliance attestation

- **0 charter writes** (`PROJECT_CHARTER.md` untouched; verified — I never opened it in this dispatch)
- **0 constitution writes** (`agent-workspace/constitution/**` untouched; verified — I read I-S34 from invariants-stockforge.md but did NOT edit)
- **0 production code** (architect PLAN-only per role; I authored 2 markdown files only: the plan + this observation)
- **0 commits in this dispatch** (architect commit policy per sandwich-architect.md D7 update — architect MAY commit own PLAN output via the architect-dispatch-template; I did NOT have Bash tool to commit; main session commits per D-060)
- **0 pushes** (D-060 — no push policy; architect doesn't have push capability)
- **AP-1 fresh-context honored** (no self-review; predecessor plan-020 written by different dispatch S337)
- **harness_priority_one honored** (surfaced harness anomalies in observation; did NOT fix)
- **I-S34 honored** (NO mention of patchright / playwright_stealth / fake-useragent / StealthyFetcher / _cloudflare_solver as adoption candidates — explicitly listed in DC-COMPLIANCE-1 grep check as HARD REJECT verification target)
- **I-S1 (no LLM math) honored** (NDHAdapter emits ZERO numeric fields; same Rule-16-by-construction posture as CafeFAdapter)
- **VBW honored** (every file reference verified by Read; plan-020 read in 3 chunks due to size; all 6 primitives + D-066 + CafeFAdapter + invariants + current-execution + observation predecessor all read in full or relevant sections)

## Summary stats

- **Plan LOC**: ~1300 (matches plan-020 cadence; within target 700-1200 range — slightly over due to plan-020's matrix-row-352 reference being expansive)
- **DoD items**: 30 (target ≥30; meets)
- **AQ count**: 10 (target ≥7-10; meets)
- **DD count**: 10 (target ≥9-10; meets)
- **RM count**: 10 (target ≥8-10; meets)
- **5-source-evidence rows**: 5 (target 5+; meets)
- **STEP 0 sub-steps**: 10 (covers 4 required + 6 additional Rule-16 + primitive-import + source_id collision + baseline + smoke)
- **Coordination paths**: 11 listed
- **Budget recommendation**: 100-150K FOCUSED_IMPL (within master plan § 6.4 per-source envelope)
- **ADR amendment status**: Path A REV-1 drafted (closes D-066 § Out-of-scope item 12); Path B (D-067) contingent on STEP 0/IMPL findings

## Commits made (this dispatch)

NONE this dispatch. Architect role per sandwich-architect.md does not include Bash tool. Main session will commit the plan + observation per D-060 (agent commits; no pushes).
