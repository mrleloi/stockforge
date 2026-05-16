---
plan_id: 027-S356-phase-d-vietnambiz-adapter
target_session: S357
type: FOCUSED_IMPL
budget: 100-150K Opus FOCUSED_IMPL (Phase 1b CALIBRATED from n=2 baseline NDH S344 + Vietstock S354; see § Calibration summary)
phase: D (Theme L — VietnamBiz greenfield adapter; THIRD and FINAL Strategy A direct-subclass adapter per plan-020 § E matrix; THIRD consumer of SelectorChain[T] primitive — after NDH S344 + Vietstock S354)
track: Wave 1 Theme L (BC-5 News Stream per-source rollout; VietnamBiz = source #4 of 4 priority VN sources after CafeF + NDH + Vietstock; FINAL adapter — completes Phase D Theme L; Phase E Theme I Vietnamese NLP unlocks post-S358 close)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.7 + § 6.4.1
predecessor: 026-S353-phase-d-vietstock-adapter (Vietstock adapter shipped + verified S354-S355; F2-store_raw quintuple-guard ARCHITECTED FROM DAY ONE — NOT post-S345 retrofit; plan moved pending→completed; ADR D-066 REV-2 landed); plan-025-S346 planner-upgrade (Phase 1b self-calibration + parallel_with field MANDATORY per ≥3 sub-track plans; this plan is SECOND DOGFOOD CONSUMER of the planner upgrade after plan-026 — IMPL session S354)
successor: TBD-S358 sandwich-verifier (AP-1 fresh-context); then Phase D Theme L CLOSED → Phase E Theme I Vietnamese NLP entry plan-028 (S359 or later)
architect: S356 sandwich-architect (background; this plan)
dispatched_by: main session orchestrating Phase D per-source rollout (Wave 1 Theme L final adapter; SECOND DOGFOOD of the planner-upgrade landed in S349; first dogfood was plan-026)
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b consumed per plan-025 DD-11 mandate; n=2 baseline)
executing_agent: sandwich-dev (background dispatch S357; fresh-context; AP-1 verifier in S358)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook (per current-execution.md § INCIDENT + RECOVERY)"
  - "R3 daily-backup.sh Stop hook (per current-execution.md § INCIDENT + RECOVERY)"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310; do NOT recommend sync-grilling as part of close ritual)"

depends_on:
  - "D-066 + REV-1 + REV-2 (CrawlerAdapter ABC contract; NDH cited as 1st consumer in REV-1; Vietstock cited as 2nd consumer in REV-2 amendment; VietnamBiz will be cited as 3rd consumer in REV-3 amendment authored at this plan close per § L)"
  - "D-061 (Wave-1 integration ratification — § Decision item 4 enforces 'Scrapling Cloudflare-solver HARD REJECT + patchright DO NOT IMPORT + StealthyFetcher excluded as a class' — BINDING)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain are BINDING for every new file authored under this plan)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for S357 dev commit boundary)"
  - "D-062 (atomic-write-doctrine — BINDING for any raw-HTML writes via RawHtmlSink; already enforced by W0-3 hook + RawHtmlSink uses tmp+os.replace)"
  - "D-064 (path-safety 5-invariant contract — BINDING for new file-path code; RawHtmlSink already uses safe_path)"
  - "D-065 (Theme G I-S1-1 Rule 16 binding; this plan introduces ZERO new LLM-numeric schema fields — same Rule-16-by-construction posture as plan-020/022/026)"
  - "D-069 PROPOSED-AT-IMPL (planner-upgrade ADR; Phase 1b mandate for ≥3 sub-tracks; this plan SATISFIES the dogfood condition for 2nd time)"
  - "Charter v1.1 Principle 4 (Proprietary data moat — VietnamBiz = 4th of 4 priority VN financial-news sources; Phase D Theme L per-source set CLOSES) + Principle 7 (Dogfood mandatory — CLI ingest_news_vietnambiz shipping at S357; Phase 1b dogfood — this plan SECOND consumer of planner-upgrade) + Principle 8 (Calibration over confidence — Phase 1b grounds budget in NDH-S344 + Vietstock-S354 actuals not LLM guess; n=2) + Principle 11 (companion firing-test mandate IF a hook is shipped — NO new hook this bundle)"
  - "I-S1 (NO LLM math) + I-S2 (citation discipline — source_url + as_of + extracted_at) + I-S22 (data lineage) + I-S34 (robots.txt + reasonable rate limits + identify user agent; HARD REJECT of patchright/playwright_stealth/fake-useragent/StealthyFetcher) + I-S35 (research-aid framing)"
  - "Rule 6 (LLM Output Provenance — adapter output ↦ NewsArticle ↦ ExtractedClaim path preserved) + Rule 7 (sentiment categorical) + Rule 8 (anti-look-ahead: published_at ≤ ingested_at carried through)"
  - "skill .claude/skills/crawler-reliability/SKILL.md (Selector Robustness fallback chain + Retry & Backoff tenacity recipe + Rate Limiting per-domain — explicitly flags VietnamBiz as less lenient than CafeF; VBW for Scrapers + Monitoring shape metrics + Anti-Patterns list)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (adapter/port/repository discipline)"

binding_decisions:
  - "D-066 § Decision (CrawlerAdapter ABC + source_id ClassVar enforcement via __init_subclass__; subclass MUST declare non-empty source_id; subclass MUST implement discover/fetch_and_parse/to_news_article; subclass MUST NOT import patchright/playwright_stealth/fake-useragent/StealthyFetcher/_cloudflare_solver per I-S34) — BINDING for VietnamBizAdapter"
  - "D-061 § Decision item 4 (Scrapling Cloudflare-solver HARD REJECT) — BINDING for all crawler adapters under packages/infrastructure/news/crawler_adapters/**"
  - "D-065 Rule 16 (numeric-field discipline) — VietnamBiz crawler emits ZERO new LLM-numeric fields; Rule 16 satisfied by construction (mirror plan-020/022/026 § Schema discipline)"
  - "D-060 — agent MAY git commit (NOT push); S357 dev decides commit boundary per § J Coordination paths"
  - "S345 verifier F2 lesson PROMOTED (n=2 day-one confirmed at Vietstock S354) — `_fetch_with_optional_chain(url, *, store_raw: bool = True)` parameter with discover() passing False MUST be architected from day-1 (NOT post-S345 retrofit; see DD-7); this is the THIRD consumer + THIRD day-one ship (NDH was retrofit; Vietstock was 1st day-one; VietnamBiz = 2nd day-one). L-S345-3 PROMOTE-NOW trigger fires upon S358 verifier confirmation"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL)"
  - "no commits in THIS plan-session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no touching apps/cli/ingest_news_cafef.py NOR apps/cli/ingest_news_ndh.py NOR apps/cli/ingest_news_vietstock.py — those are shipped; this plan ships a NEW CLI ingest_news_vietnambiz.py"
  - "no CafeF/NDH/Vietstock adapter modifications — VietnamBiz plan does NOT amend prior adapters; cross-adapter consolidation deferred per RM12 carry-forward (L-S354-1 1st-instance HOLD for Protocol-typed injection refactor)"
  - "no Phase E entry — VietnamBiz is FINAL Phase D Theme L adapter; Phase E Theme I Vietnamese NLP unlocks ONLY post-S358 verifier acceptance (CLAUDE.md Phase boundary discipline)"
  - "no harness/hook changes — this plan ships product substrate (VietnamBiz adapter); surface any harness gaps in observation; do NOT fix here. L-S354-2 (.planner-stats.tsv auto-population gap) belongs to next harness-stabilization sweep, NOT this product session"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 HARD REJECT: VietnamBizAdapter MUST NOT import patchright, playwright_stealth, fake-useragent, StealthyFetcher, _cloudflare_solver, or any Scrapling Cloudflare-solver path — verifier AQ check grep-asserts this"
  - "If STEP 0 finds VietnamBiz is JS-rendered (would require Playwright) → DEFER adapter; flag as harness gap; do NOT install patchright; do NOT silently bypass I-S34"
  - "Master plan + plan-020 § E matrix line 354 listed URL as `vietstockfinance.vn` — THIS IS A TYPO. Correct URL is `vietnambiz.vn`. STEP 0.1 empirically verifies."
---

# S357 — Phase D VietnamBiz Adapter (greenfield Strategy A; third + FINAL SelectorChain[T] consumer; Phase D Theme L CLOSE)

## A. Goal

Ship the **third and FINAL greenfield Strategy A direct-subclass CrawlerAdapter** for Vietnamese financial news source VietnamBiz (`vietnambiz.vn` — STEP 0 verifies live), mirroring NDH (S344) + Vietstock (S354) patterns. VietnamBizAdapter is the **third consumer of `SelectorChain[T]`** primitive, validating the contract across THREE distinct VN financial sites (n=3 maturity threshold per AP-23 stability calculus).

**What this plan delivers**:
- `packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` (NEW; ~250-350 LOC; subclasses `CrawlerAdapter` directly per Strategy A — no legacy code to wrap)
- `packages/infrastructure/news/crawler_adapters/__init__.py` UPDATED to export `VietnamBizAdapter` alongside existing `CafeFAdapter` + `NDHAdapter` + `VietstockAdapter`
- `packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py` (NEW; ≥12 test cases; synthetic minimal HTML fixtures)
- `apps/cli/ingest_news_vietnambiz.py` (NEW; ~300 LOC; mirrors `ingest_news_vietstock.py` shape but dispatches VietnamBizAdapter; **rate-limit 3.0s NOT 2.0s** per plan-020 § E matrix line 354 + skill § Rate Limiting "VietnamBiz less lenient")
- ADR D-066 REV-3 amendment (VietnamBiz cited as 3rd consumer; SelectorChain[T] contract maturity 1→2→3 consumers; closes Phase D Theme L per-source rollout)
- Skill `.claude/skills/crawler-reliability/SKILL.md` UPDATED per L-S345-3 PROMOTE-NOW (CONDITIONAL — fires only after S358 verifier confirms DD-7 F2-aware day-one quintuple-guard ALL GREEN; see § L)
- Session log + observation file per CLAUDE.md § Session Protocol End
- ZERO charter / constitution / human-workspace writes (skill update is .claude/skills/, NOT constitution)
- ZERO new LLM-numeric schema fields (Rule 16 by construction)
- ZERO new hooks (mirror plan-020/022/026; product substrate not harness rule-enforcement)

## B. In-scope / Out-of-scope

### IN-scope (this bundle MUST ship)

- VietnamBizAdapter class (greenfield; Strategy A direct subclass of CrawlerAdapter)
- `SelectorChain[T]` consumption in VietnamBizAdapter's HTML parsing path (headline + body + optional publish_date; STEP 0.4 confirms exact selectors)
- Unit tests with synthetic minimal HTML fixtures (≥12 cases; tests 7 + 19 MANDATORY — DD-7 F2-aware quintuple-guard verification mirror plan-026)
- CLI smoke entry point at `apps/cli/ingest_news_vietnambiz.py` mirroring Vietstock CLI shape but with `RateLimiter(base_delay=3.0, ...)` per DD-5
- Registry wire: CLI constructs fresh `CrawlerRegistry()`, registers `VietnamBizAdapter`, dispatches via `registry.get("vietnambiz")`
- ADR D-066 REV-3 amendment (VietnamBiz cited as 3rd consumer; SelectorChain[T] contract maturity 1 → 2 → 3 consumers)
- F2-aware design from day 1: `_fetch_with_optional_chain(url, *, store_raw: bool = True)` with discover() passing False (per S345 verifier post-S345 fix promoted into NDH; Vietstock 1st day-one; VietnamBiz = 2nd day-one ship)
- **CONDITIONAL Skill update** at `.claude/skills/crawler-reliability/SKILL.md` per § L L-S345-3 PROMOTE-NOW: append "Strategy A adapter template MUST declare `_fetch_with_optional_chain(*, store_raw: bool = True)` from day 1 — discover-bypass-via-store_raw pattern (3-instance precedent: NDH-retrofit / Vietstock-day-one / VietnamBiz-day-one)" — **fires ONLY if S358 verifier confirms all 6 quintuple-guard items GREEN**
- Session log + observation file

### OUT-of-scope (DEFERRED — explicit non-goals)

- **Phase E Theme I Vietnamese NLP** — DEFERRED until S358 verifier acceptance closes Phase D Theme L
- **YouTube transcripts (KOL channels)** — separate BC-6 work via existing `apps/cli/ingest_kol_channels.py`; NOT CrawlerAdapter-shaped per plan-020 § E matrix line 355
- **Facebook public fanpages** — Phase 4+ candidate; needs CDP-consent UX per plan-020 § E matrix line 356
- **Harness/hook changes** — this is product substrate, NOT rule-enforcement; any harness anomalies surface in observation (L-S354-2 .planner-stats.tsv auto-population gap belongs to harness-stabilization sweep)
- **Charter / constitution edits** — out of scope per CLAUDE.md hard rules
- **Async migration** — sync interface per D-066 § Async deferred to Phase 3 (unchanged)
- **R2 raw-HTML storage** — local filesystem under `data/raw/news/vietnambiz/` (Phase 2 thin slice per D-066 § Storage)
- **Adaptive selector / Scrapling `Selector.relocate`** — deferred per plan-020 § Out-of-scope item 1 (long-term defense; SelectorChain fallback is short-term)
- **CafeFAdapter consolidation Strategy A migration** — RM12 carry-forward; separate future Phase D-N session
- **SelectorChain wiring into CafeFAdapter** — deferred per ADR D-066 § Out-of-scope item 12
- **Protocol-typed optional injections** — L-S354-1 1st-instance HOLD (would eliminate 19 cumulative unused type:ignore across 4 BC-5 adapters; cross-adapter refactor; separate harness session)
- **`report_response(url, 200)` hardcoded fix** — L-S345-4 carry-forward (fetcher contract returns (html, status) tuple; cross-adapter refactor)
- **Live vietnambiz.vn HTTP smoke in CI** — fixture-driven tests only; one manual CLI smoke recorded in session log but not committed
- **`extract_claims` on CrawlerAdapter** — deferred to Theme I per D-066 § Out-of-scope item 8
- **CafeFAdapter / NDHAdapter / VietstockAdapter modifications** — VietnamBiz plan ships in isolation; no cross-adapter touch
- **AJAX/JSON API consumption** — DEFERRED; Strategy A targets static HTML article pages only

### Calibration summary (Phase 1b — CONSUMED variant per plan-025 DD-11 mandate)

**Source files read** (VBW empirical):
- agent-workspace/memory/.planner-stats.tsv (last_updated=N/A — STILL header-only at S356 entry; L-S354-2 HARNESS GAP from S355 verifier — planner-feedback-loop.sh did NOT auto-populate after S354 first-dogfood; cold-start declared)
- agent-workspace/memory/self-awareness/sessions-rollup.tsv (read last 30 rows window; no `task_class` column in schema — observation: rollup schema is `session_n,session_id,ts_utc,tokens_real,tools_used,subagents,failure_codes,wall_min`; task_class derivation requires cross-reference with session logs)
- agent-workspace/memory/dispatch.jsonl (grep for S344+S345+S354+S355 dispatches; jsonl format)
- agent-workspace/memory/mistake-log.md (last 80 LOC digest read; M-S354-NONE clean / M-S342-1 medium verifier-fixture-cleanup / M-S341-1 low LOC-overstate / M-S347-NONE clean)
- agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md (NDH plan; 1124 LOC reference)
- agent-workspace/session-plans/completed/026-S353-phase-d-vietstock-adapter.md (Vietstock plan; 1148 LOC reference; first plan with parallel_with declaration)
- agent-workspace/memory/observations/sandwich-verifier-S355-vietstock-adapter-verify.md (Vietstock verify; cites L-S345-3 strengthening + L-S354-1 1st-instance HOLD + L-S354-2 1st-instance harness gap)
- packages/infrastructure/news/crawler_adapters/vietstock_adapter.py (476 LOC actual; mirror reference)

**Calibration parameters extracted**:
- **task_class**: crawler-adapter-impl (Strategy A greenfield direct-subclass of CrawlerAdapter; SelectorChain consumer; +CLI shim)
- **sample_size**: 2 (NDH S344 + Vietstock S354 — n=2 empirical baseline; statistically still weak but directionally robust per Karpathy P1 "calibration over confidence")
- **avg_wall_min observed**: NDH S344 dev ~31min focused work / Vietstock S354 dev ~36min (per S355 verifier observation); **avg = 33.5 min** sequential baseline. Variance: ±2.5 min (~7%) — tight envelope (low variance over n=2 = confidence to ship FOCUSED_IMPL not MULTI_TASK_IMPL)
- **avg tokens_real**: NDH ~116K Sonnet observed (per dev observation cited in plan-026 § Calibration); Vietstock ~34K Opus (per S355 verifier); **wide variance — Opus is ~30-40% MORE token-efficient on surgical adapter tasks vs Sonnet** (smaller token bills despite higher per-token cost); architect-verdict: Opus appropriate for VietnamBiz S357 (consistency with S354 + Phase 1b second-dogfood overhead absorbs more efficiently)
- **parallel_hit_rate observed**: Vietstock S354 dev's parallel_with declaration shipped; actual parallel-dispatch behavior at IMPL not measured (no .planner-stats.tsv population). **Phase 1b grounds at n=1 parallel-declaration; n=0 parallel-empirical**. Cold-start partial.
- **parallel_savings_avg**: N/A (no .planner-stats empirical; declaration-only at n=1)
- **failure_mode frequency**: NDH had F2 IMPORTANT (store_raw retrofit; fixed S345); Vietstock had F1 IMPORTANT INLINE-RESOLVED + 4 MINOR deferred (S355 verdict PASS-WITH-CONCERNS MERGE-ELIGIBLE). **Failure pattern**: IMPORTANT defects = 1 per dev cycle (n=2); both INLINE-RESOLVABLE (no rollback). **Adjusted budget reserve**: 15-20% for inline F1-equivalent fix
- **Adjustment to default budget**: -10K from default 100-150K Opus envelope per Vietstock-actual efficiency observation (Vietstock S354 finished within ~34K — well under 100K envelope; conservative bound to allow STEP 0 surprises + 15% F1 inline-resolution reserve)
- **Cold-start?**: PARTIAL — .planner-stats.tsv still header-only (L-S354-2 harness gap); sessions-rollup lacks task_class column (cannot key cleanly); n=2 mistake-log digest empirically informative. Calibration is **DIRECTIONAL-CONFIDENT (n=2 same-class observations)**, NOT statistically rigorous. Honor Karpathy P1 "calibration over confidence" by stating estimate explicitly: **90-130K Opus FOCUSED_IMPL with 20% reserve** for STEP 0 findings + L-S345-3 PROMOTE-NOW skill update (additional ~5K) + DD-5 3.0s-rate-limit CLI smoke wall-time inflation (additional ~3 min CLI smoke vs Vietstock 2.0s)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail):
- Vietstock S354 actual (~34K Opus full ship): under-envelope; suggests adapter-impl task class is well-bounded at ~30-50K Opus per ship
- NDH S344 actual (~116K Sonnet full ship): wider envelope; partially attributable to (a) Sonnet token-density vs Opus + (b) F2 retrofit overhead post-S345 verifier
- VietnamBiz S357 projection: ~50-80K Opus FOCUSED_IMPL ideal range; reserve 20% (~16K) for surprises = **66-96K target; 100-130K conservative ceiling**; FINAL Phase D Theme L = no follow-on adapter so no carry-over budget risk
- L-S345-3 PROMOTE-NOW (skill update, conditional): +~5K if fires
- DD-5 3.0s rate-limit CLI smoke: +~3 min wall (per-fetch +1s × N fetches); fits within session budget
- **Final recommendation: 100-150K Opus FOCUSED_IMPL with 20% reserve** (consistent with plan-026; small upward bias on Vietstock-actual to absorb DD-5 rate-bump CLI smoke + L-S345-3 skill update conditional ship)

**PARALLEL OPPORTUNITY** (n=1 declaration baseline; first plan to declare parallel_with was plan-026):
- D3 (tests) + D4 (registry wire + CLI) + D5 (ADR amendment) can run parallel post-D1 per coordination_paths_exclusive (3 disjoint file sets per § E)
- D1 (adapter impl) must serialize as foundation; D2 (HTML parser internals) merges into D1 (selector filling depends on STEP 0.4)
- Recommended dispatch: D1 sequential (~13-15 min wall — slightly faster than Vietstock due to n=2 confidence reducing exploration overhead) → then D3+D4+D5 parallel via single Agent-tool multi-call (max(8, 9, 4) = ~9 min — D4 slightly heavier due to L-S345-3 skill-update sub-task IF triggered)
- **L-S345-3 PROMOTE-NOW CONDITIONAL ADD**: if dev attempts skill-update WITHIN S357, that's a NEW skill-update sub-track requiring separate parallel-with declaration — architect's recommendation: defer skill-update to main session post-S358 verifier-confirm (cleanly separates product-tier IMPL from skill-tier amendment; reduces S357 parallel-dispatch cardinality risk)
- Total wall projected: ~22-27 min vs sequential ~33-37 min = ~25-30% reduction (matches plan-025 § DD-1 projection 25-50%; consistent with plan-026 projection)
- Max-3 parallel ceiling per Q-PL1 RATIFIED; this plan declares 3 parallel children (D3+D4+D5) = at-ceiling

## C. STEP 0 — VBW Live Verification (BLOCKING; mandatory)

The implementing session (S357) MUST run these sub-steps BEFORE writing any adapter code and write results into the session log. This plan was authored by a sandwich-architect subagent with Read/Glob/Grep/Write but NO Bash — STEP 0 is the empirical anchor that grounds plan recipes against the live VietnamBiz site.

**STOP-AND-ASK clause** (binding; see also § G AQ-5/AQ-6/AQ-7 for pre-answered escalation paths):
- If `vietnambiz.vn` returns 404 / DNS-no-resolve → STOP-AND-ASK (defer adapter; flag site-defunct; surface in mistake-log)
- If `/robots.txt` explicitly disallows crawl for `User-agent: *` or `User-agent: stockforge-research-bot` → STOP-AND-ASK (defer adapter; honor robots; flag in mistake-log per skill § Anti-Patterns)
- If ToS page (linked from site footer) forbids automated access → STOP-AND-ASK (defer adapter; flag in mistake-log)
- If site is fully JS-rendered (article body requires JavaScript execution to populate DOM) → STOP-AND-ASK (defer adapter; surface harness gap that I-S34 HARD REJECT of Playwright/patchright leaves us without a JS-rendering option; do NOT install patchright; do NOT silently bypass I-S34)
- If observed HTML structure is so different from expectation that the planned SelectorChain[T] shape cannot accommodate it → STOP-AND-REPLAN (surface as plan-027 finding; may require D-066 amendment for SelectorChain contract gap — see § D5 Path B)

### Sub-step 0.1 — URL probe (verify canonical host; plan-020 § E matrix line 354 had typo "vietstockfinance.vn" — correct is "vietnambiz.vn")

```bash
# Probe canonical URL (httpx with 10s timeout; record status code + redirect chain + final URL)
python -c "
import httpx
for host in ['vietnambiz.vn', 'www.vietnambiz.vn']:
    try:
        r = httpx.get(f'https://{host}', follow_redirects=True, timeout=10.0,
                      headers={'User-Agent': 'stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)'})
        print(f'{host}: status={r.status_code} final={r.url}')
    except Exception as e:
        print(f'{host}: ERROR {type(e).__name__}: {e}')
"
```

**Record in session log**: For each candidate URL, the observed (status code, final URL after redirects, response size in bytes). Master plan + plan-020 § E matrix line 354 listed URL as `vietstockfinance.vn` which was a typo (line 353 Vietstock already uses `vietstock.vn`). Correct URL is `vietnambiz.vn`. Prefer the canonical-host variant (apex or www.) as observed via redirect chain. If NEITHER reachable → STOP-AND-ASK.

**Architect prediction**: `vietnambiz.vn` is the canonical landing page; `www.vietnambiz.vn` may redirect (or vice versa). Plan-020 § E matrix line 354 hypothesizes "Static HTML hypothesis"; STEP 0.4 confirms. Skill .claude/skills/crawler-reliability/SKILL.md § Rate Limiting explicitly flags VietnamBiz as "less lenient than CafeF" — historical context informs DD-5 conservative 3.0s default.

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
for path in ['/', '/news', '/chung-khoan', '/tai-chinh', '/article', '/co-phieu']:
    print(f'  {path}: can_fetch={parser.can_fetch(path, \"stockforge-research-bot/0.0.1\")}')
print(f'crawl_delay for *: {parser.crawl_delay(\"*\")}')
"
```

**Record in session log**: robots.txt status code (200 = present; 404 = absent → per `RobotsTxtManager.can_fetch` default = permissive); the verbatim disallow rules for `User-agent: *` and any specifically for `stockforge-research-bot`; the `Crawl-delay` directive if present (this may bump the planned 3.0s default to a higher value — VietnamBiz historically less lenient; bump is more likely than for Vietstock).

**Branch**:
- robots.txt present + User-agent: * is allowed root path → PROCEED (record in adapter docstring "robots.txt verified VERIFIED-DATE")
- robots.txt present + explicit disallow on relevant paths → STOP-AND-ASK
- robots.txt 404 (absent) → PROCEED per RobotsTxtManager default = permissive; still apply rate-limit + UA identification
- Crawl-delay > 3.0s → bump rate-limit to that value (mandatory; honor directive). Crawl-delay ≤ 3.0s → 3.0s default (DD-5 conservative posture stands; skill flag justifies the bump)

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
Path('tmp/vietnambiz_sample.html').write_text(r.text, encoding='utf-8')
print(f'sample saved to tmp/vietnambiz_sample.html')
"
```

**Record in session log**: Status code, response size, JS-rendering markers detected (if any), content-type. Save sample HTML to a tmp/ location (NOT committed; for selector discovery only — recorded path in session log so reviewer can inspect).

**Then**, manually inspect the saved HTML to identify selector candidates for each field:
- **Headline (`title`)**: typical candidates — `<h1>`, `<h1 class="...">`, `<meta property="og:title">`, `<title>` (strip suffix). VietnamBiz commonly uses `<h1 class="article-title">` or `<h1 class="title-detail">`; record ≥2 candidates in priority order
- **Body container**: typical candidates — `<div class="article-body">`, `<div class="content-detail">`, `<div class="article-content">`, `<article>`, `<div itemprop="articleBody">`; record ≥3 candidates in priority order
- **Publish date**: typical candidates — `<meta property="article:published_time">`, `<meta name="pubdate">`, `<time datetime="...">`, `<span class="date">`. VietnamBiz often uses Vietnamese-locale strings like "16/05/2026 14:30" OR ISO-8601 with +07:00 offset; record ≥2 candidates + observed datetime format string
- **Author/byline** (optional; skip if not present): `<span class="author">`, `<meta name="author">`; record if found
- **Article URL pattern** (for `discover()`): observe what listing-page anchors look like; VietnamBiz historically uses paths like `/<category>/<slug>-<numeric_id>.htm` or `/<slug>-<id>.html`; identify URL-suffix or path-prefix conventions

**Branch**:
- Static HTML with identifiable selectors → PROCEED with SelectorChain[T] design per § D DD-4
- JS-marker detected + body container empty without JS → STOP-AND-ASK (per § G AQ-7; I-S34 HARD REJECT of Playwright)
- Mixed (some fields server-rendered, some require JS) → consider partial extraction: PROCEED only if title + body + URL are all server-rendered; defer publish_date to fallback (`self.clock()` per Vietstock `_parse_published_at` final-fallback pattern at `vietstock_adapter.py:271`)

### Sub-step 0.5 — Rule 16 compliance pre-flight (mirror plan-020/022/026 STEP 0.5)

```bash
# Confirm no new numeric fields are needed (VietnamBizAdapter mirrors NDH/Vietstock Rule-16-by-construction posture)
grep -rn "float\|int\|Decimal" packages/contracts/events/news_article_ingested.py
grep -rn "float\|int\|Decimal" packages/domain/news/models/news_article.py
grep -rn "float\|int" packages/domain/news/value_objects/extractor_metadata.py
```

Expected: ZERO numeric fields on `NewsArticleIngested` (only str/datetime/tuple); ZERO numeric fields on `NewsArticle` (only str/datetime/tuple); `ExtractorMetadata.confidence_extracted: float` is the one numeric field — populated by LLM extractor downstream, NOT by crawler. VietnamBizAdapter output = same `ScrapedArticle` dataclass + same `NewsArticle` promotion path — ZERO new numeric fields. Record in session log.

### Sub-step 0.6 — Verify primitives still consumable (mirror plan-020/022/026)

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
# Verify all 3 sibling adapters still importable
from packages.infrastructure.news.crawler_adapters import NDHAdapter, CafeFAdapter, VietstockAdapter
print(f'NDHAdapter.source_id={NDHAdapter.source_id}; CafeFAdapter.source_id={CafeFAdapter.source_id}; VietstockAdapter.source_id={VietstockAdapter.source_id}')
"
```

Expected: All imports succeed; SelectorChain is frozen; fields are `[strategies, label]`; all 3 sibling adapters (CafeF, NDH, Vietstock) export cleanly. If any import fails → STOP and reconcile against plan-026 close state.

### Sub-step 0.7 — Verify next-adapter source_id collision check

```bash
# Confirm 'vietnambiz' source_id is not already registered (sanity check before authoring)
grep -rn "source_id" packages/infrastructure/news/crawler_adapters/
```

Expected: `cafef_adapter.py` declares `"cafef"`, `ndh_adapter.py` declares `"ndh"`, `vietstock_adapter.py` declares `"vietstock"`. No existing `vietnambiz` registration. If a stray `vietnambiz` source_id is found → STOP and reconcile.

### Sub-step 0.8 — Baseline regression floors (mirror plan-026 STEP 0.8; updated for post-S355 floor)

```bash
bash scripts/hooks/firing-tests/run-all.sh 2>&1 | tail -5
bash scripts/hooks/bash-hook-lint.sh 2>&1 | tail -5
python -m pytest packages/ apps/ tests/ -q 2>&1 | tail -3
python -m mypy --strict packages/ apps/ 2>&1 | tail -5
python -m ruff check packages/ apps/ 2>&1 | tail -5
```

Write pre-IMPL pass/fail counts into session log. New modules + tests MUST add to (not regress) these baselines. **Expected pytest floor ≥ 1013** (per S355 verifier; was 990 before Vietstock, +23 Vietstock tests at S354). New VietnamBiz tests add ≥12 cases per D3 floor → expected post-IMPL floor ≥ 1025.

### Sub-step 0.9 — Smoke-test existing CafeF + NDH + Vietstock pipelines (zero-regression floor)

```bash
# Confirm CafeFAdapter still works end-to-end (zero regression on plan-020 closure)
python -m pytest packages/infrastructure/news/crawler_adapters/test_cafef_adapter.py -q 2>&1 | tail -5
# Confirm NDHAdapter still works end-to-end (zero regression on plan-022 closure including post-S345 store_raw fix)
python -m pytest packages/infrastructure/news/crawler_adapters/test_ndh_adapter.py -q 2>&1 | tail -5
# Confirm VietstockAdapter still works end-to-end (zero regression on plan-026 closure)
python -m pytest packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py -q 2>&1 | tail -5
```

Expected: pre-existing CafeF + NDH + Vietstock test counts pass (12 + 22 + 23 = 57 sibling-adapter tests floor; per S355 verifier "CafeF + NDH zero-regression: 34/34 unchanged (12 CafeF + 22 NDH)" + Vietstock +23 = 57). Record in session log as DC-AGG floor.

### Sub-step 0.10 — STEP 0 summary write into session log

After Sub-steps 0.1-0.9 complete, write a "STEP 0 Summary" section into the session log including:
- Canonical VietnamBiz host verified (from 0.1)
- robots.txt verdict (from 0.2)
- ToS verdict + URL + date (from 0.3)
- Identified selector candidates for headline/body/date + observed datetime format (from 0.4)
- HTML structure assessment (static vs JS-rendered) (from 0.4)
- Final rate-limit decision (3.0s default per DD-5 OR bumped per Crawl-delay)
- Baseline regression counts (from 0.8)
- CafeF + NDH + Vietstock zero-regression confirmation (from 0.9)
- Any STOP-AND-ASK triggered: yes/no (if yes, halt and surface to main session)

---

## D. Architecture Decisions (DD-1 through DD-10)

### DD-1: Adapter class name = `VietnamBizAdapter`

**Decision**: Class name `VietnamBizAdapter` (capital V, capital B, capital A — matches VietnamBiz brand which is consistently spelled as one word with internal capital B in plan-020 § E matrix + skill SKILL.md). Source_id = `"vietnambiz"` (lowercase, consistent with `"cafef"`, `"ndh"`, `"vietstock"`).

**Rationale**: Convention from CafeFAdapter at `packages/infrastructure/news/crawler_adapters/cafef_adapter.py:50-51`, NDHAdapter at `packages/infrastructure/news/crawler_adapters/ndh_adapter.py:116`, and VietstockAdapter at `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py:130`: class name uses brand-PascalCase; source_id is lowercase hash-key. No deviation justified. **Capitalization note**: plan-020 § E matrix line 354 uses "VietnamBiz" (capital B); skill SKILL.md line 3 + line 54 same. Architect confirms PascalCase per brand convention.

**Adversarial alternate considered**: `VnBizAdapter` (abbreviated; matches some Vietnamese fintech conventions) → rejected (no precedent in plan-020 matrix; brand name is "VietnamBiz" not "VnBiz"; source_id collision risk if future "VietnamBusinessForum" or similar appears). `VietNamBizAdapter` (Vietnamese-spelling "Việt Nam" two words) → rejected (English convention in codebase + canonical brand single-word "VietnamBiz").

### DD-2: Package path = `packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py`

**Decision**: Live alongside `cafef_adapter.py` + `ndh_adapter.py` + `vietstock_adapter.py` in the existing crawler_adapters subdirectory.

**Rationale**: Path convention established by plan-020 DD-1 + plan-022 DD-2 + plan-026 DD-2 + ADR D-066: "Concrete adapters live in packages/infrastructure/news/crawler_adapters/". The `__init__.py` currently exports `CafeFAdapter` + `NDHAdapter` + `VietstockAdapter` (per `packages/infrastructure/news/crawler_adapters/__init__.py:3-5` verified); this plan extends export list with `VietnamBizAdapter`.

### DD-3: Strategy A direct-subclass (NOT Strategy B WRAP)

**Decision**: VietnamBizAdapter directly subclasses `CrawlerAdapter` (ABC) and implements `discover() / fetch_and_parse() / to_news_article()` from scratch. NO wrapping of any legacy class (there is no legacy VietnamBiz scraper to wrap — this is greenfield).

**Rationale**: Plan-020 § E matrix line 354 explicitly classifies VietnamBiz as "A" (Strategy A primary). Strategy A is the canonical pattern for all greenfield adapters per plan-022 DD-3 + plan-026 DD-3 precedent (now n=2 precedent). No mixed-Strategy hint for VietnamBiz (unlike Vietstock matrix-row "A primary + B fallback if listing AJAX").

**Adversarial alternate considered**: Compose VietnamBizAdapter from a fresh internal `_VietnamBizScraper` helper class (mirror CafeF's wrap shape for symmetry) → rejected (per plan-022/026 DD-3: unnecessary indirection; double-class maintenance from day 1; no behavioral benefit). Strategy A at n=2 (NDH + Vietstock) is the validated greenfield pattern.

### DD-4: SelectorChain[T] usage shape — two-or-three SelectorChain instances per article

**Decision**: VietnamBizAdapter's `fetch_and_parse()` uses **two SelectorChain[Tag] instances minimum** (matching NDH + Vietstock shape at `ndh_adapter.py:206-244` + `vietstock_adapter.py:224-260`):
1. `headline_chain` — extracts article headline (typical: `<h1 class="title-detail">` → `<h1>` → `<meta property="og:title">`)
2. `body_chain` — extracts article body container (typical: `<div class="article-content">` → `<div class="content-detail">` → `<article>`)

Optionally a third for publish_date (only if STEP 0.4 reveals enough DOM-locator variance to warrant it; otherwise use fmt-string fallback inside `_parse_published_at`).

Plus the publish_date parsing itself uses a **fallback list of datetime format strings** mirroring Vietstock's `_parse_published_at` (`vietstock_adapter.py:397-476` — fmt-string chain for ISO-8601 + Vietnamese locale formats like "%d/%m/%Y %H:%M" + "%d-%m-%Y %H:%M:%S%z" — STEP 0.4 confirms VietnamBiz's actual formats).

**Rationale**: NDH + Vietstock precedent at n=2: both ship with 2 SelectorChain instances + 1 fmt-string chain. VietnamBiz follows the same pattern. Using SelectorChain (rather than CafeF's inline `or` chain at `cafef_scraper.py:117-120`) gains: (a) instrumentation — `apply()` returns `(result, num_strategies_tried)` for shape-metrics emit (deferred to Phase 3); (b) explicit `label` per chain for logging; (c) frozen dataclass = no accidental mutation.

**Contract verification** (from reading `apps/_shared/crawl/selector_chain.py:33-105` per plan-026 DD-4):
- `SelectorChain[T]` is `Generic[T]`, frozen, slots; fields = `(strategies: Sequence[Callable[[], T | None]], label: str = "(unnamed)")`
- `apply()` returns `tuple[T | None, int]`; logs WARNING if all strategies fail (skill doctrine: "partial output beats whole-pipeline halt")
- Strategies that raise are caught + debug-logged (do NOT propagate); chain continues to next strategy
- BeautifulSoup `Tag` is the typical T

**Selector strategy authoring**: each strategy is a `lambda: soup.find(...)` or `lambda: soup.select_one(...)` — captured at adapter `fetch_and_parse()` time after `soup = BeautifulSoup(html, "html.parser")` is parsed. SelectorChain is constructed inside `fetch_and_parse(url)` per call (NOT cached on the adapter), because the `soup` reference inside each lambda closure must reference the current article's soup; SelectorChain itself is cheap (frozen dataclass with a Sequence + str).

**Adversarial alternate considered**: SelectorChain per adapter declared at `__init__` time with selector strategies that take `soup` as an argument → rejected per plan-022/026 DD-4 (architect verdict: zero-arg Callable contract is correct; closure-over-soup pattern is cheap).

### DD-5: Rate-limit profile — **3.0s default** per plan-020 § E matrix line 354 + skill flag

**Decision**: VietnamBizAdapter constructs internal `RateLimiter(base_delay=3.0, max_delay=60.0, max_retries=5)` matching plan-020 § E matrix line 354 VietnamBiz profile. **STEP 0.2 may override**: if robots.txt declares `Crawl-delay: N` where N > 3.0, dev bumps `base_delay=N` (mandatory; honor directive). **Crawl-delay ≤ 3.0s → 3.0s stands** (skill flag justifies conservative posture).

**Rationale**: Plan-020 § E matrix line 354 explicitly says "VietnamBiz ... **3.0s default** — skill § Rate Limiting flags VietnamBiz as less lenient than CafeF; conservative bump". Skill `.claude/skills/crawler-reliability/SKILL.md` line 54 confirms: "Default: 10 calls/min/domain. Adjust per site terms — CafeF is more lenient than VietnamBiz". 10 calls/min = 6s/call minimum upper bound; 3.0s = midpoint between CafeF's 2.0s lenient and 6s strict-cap. **Conservative posture is BINDING for this adapter** — no aggressive override allowed without empirical evidence.

**Adversarial alternate considered**: 2.0s default (mirror CafeF/NDH/Vietstock for consistency) → REJECTED (skill flag is explicit; plan-020 matrix is explicit; charter Principle 8 calibration over confidence requires honoring the historical signal). 5.0s preemptive (mirror most conservative possible posture) → rejected (no evidence VietnamBiz needs 5s; 3.0s is the documented prior per skill). Bump to 4.0s if STEP 0.4 reveals 429/503 under 3.0s → architect-acceptable empirical-driven bump documented in session log.

### DD-6: Robots-manager integration — optional injection with `can_fetch` check before each request

**Decision**: VietnamBizAdapter accepts optional `robots_manager: object = None` constructor arg (mirror CafeFAdapter + NDHAdapter + VietstockAdapter pattern at `cafef_adapter.py:97-98` + `ndh_adapter.py:129` + `vietstock_adapter.py:143-144`). When provided, the adapter's internal `_fetch_with_optional_chain` calls `robots_manager.can_fetch(url)` BEFORE every HTTP fetch; on disallow → log WARNING + raise RuntimeError (so caller's loop logs + continues per L-S28-1 graceful-degrade doctrine).

**Rationale**: Mirror Vietstock's proven pattern (now n=2 via NDH + Vietstock). RobotsTxtManager primitive at `apps/_shared/crawl/robots_manager.py:119-136` provides `can_fetch(url) -> bool`; returns True on 404 (permissive default per RM7).

**Default behavior**: If `robots_manager=None`, adapter skips the check. CLI `ingest_news_vietnambiz.py` wires a real RobotsTxtManager at construction time.

### DD-7: F2-AWARE `_fetch_with_optional_chain(url, *, store_raw: bool = True)` from DAY ONE (n=2 day-one precedent — Vietstock S354 first)

**Decision**: VietnamBizAdapter's `_fetch_with_optional_chain` private helper takes a **keyword-only** `store_raw: bool = True` parameter. `discover()` passes `store_raw=False` to avoid persisting listing-page HTML to `data/raw/news/vietnambiz/` (listing pages are not articles; their raw HTML pollutes the data lake). `fetch_and_parse()` uses the default `store_raw=True`.

**Rationale**: **S345 verifier F2 lesson PROMOTED TO STANDARD AT n=2** — NDH adapter shipped at S344 without the `store_raw` parameter (post-S345 retrofit at `ndh_adapter.py:336`); Vietstock adapter at S354 shipped WITH the parameter from day 1 (`vietstock_adapter.py:322` verified). VietnamBiz plan continues the day-1 discipline (now n=3 instances of `store_raw` presence; n=2 day-one ships). **L-S345-3 PROMOTE-NOW TRIGGER**: if S358 verifier confirms VietnamBiz also ships day-1 with quintuple-guard ALL GREEN, the pattern becomes a SKILL-tier mandate per AP-23 promote-or-retire calculus (3-instance ratification standard). See § L for promotion plan.

**Verifier S358 grep-asserts** (mirror plan-026 DC-IMPL-7/8 quintuple-guard):
1. `grep -n "def _fetch_with_optional_chain" packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` MUST show the parameter signature `(url, *, store_raw: bool = True)` (keyword-only via `*` per Python idiom for default-bool flags)
2. `grep -n "store_raw=False" packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` MUST return ≥1 hit in the `discover()` body
3. `grep -n "if store_raw" packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` MUST show sink-write guard
4. `test_vietnambiz_adapter.py` MUST have `test_discover_does_not_persist_raw_html_via_sink` (mock sink; assert sink.write NOT called during discover())
5. `test_vietnambiz_adapter.py` MUST have `test_fetch_and_parse_writes_raw_html_via_sink` (mock sink; assert sink.write called with correct args during fetch_and_parse())
6. Empirical CLI smoke: `find data/raw/news/vietnambiz -type f` MUST show only ARTICLE-hash files; ZERO listing-page hashes

**Adversarial alternate considered**: Two separate methods `_fetch_for_article` + `_fetch_for_listing` (no shared helper; simpler call sites) → rejected (per plan-022/026 DD-7: code duplication on rate-limit + robots-check + sink-write chain; single helper with kw-only flag is the DRY path Vietstock + NDH both adopted; consistency across adapters per L-S345-3 promotion candidate now at 3rd-instance candidate).

### DD-8: User-agent string — reuse CafeF/NDH/Vietstock UA verbatim

**Decision**: Same UA as CafeF + NDH + Vietstock: `"stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"` (cited at `cafef_scraper.py:35-37`, `ndh_adapter.py:77-79`, `vietstock_adapter.py:88-90`, and the CLI fetcher at `apps/cli/ingest_news_cafef.py:60-62`).

**Rationale**: Plan-020 § E matrix line 354 explicitly says "Same UA" for VietnamBiz. Charter I-S34 + skill § Anti-Patterns + skill § Do require "identify user agent" + reject "fake-useragent". The stockforge bot UA is the single canonical identity at n=3 (CafeF + NDH + Vietstock) — per-source UA differentiation has no benefit. The contact email is the operationally-useful field; identical UA across sources keeps the contact channel simple.

### DD-9: Error handling — mirror Vietstock shape (return None on parse fail; raise propagates on network fail)

**Decision**: Delegate retry + backoff to the injected `RateLimiter` per plan-020/022/026 DD-9. `fetch_and_parse()` catches all exceptions during fetch + parse + returns None (per L-S28-1 vendor-drift doctrine); `discover()` lets fetch exceptions propagate (caller's per-listing loop handles).

**Rationale**: Mirror Vietstock at `vietstock_adapter.py:212-216`: `try: html = self._fetch_with_optional_chain(url) except Exception as exc: _log.warning(...); return None`. RateLimiter at `apps/_shared/crawl/rate_limiter.py:123-169` handles 429/503 backoff; 4xx-other-than-429 raises through.

**Circuit-open behavior**: If `RateLimiter.report_response` returns False (circuit-open after max_retries), adapter MUST NOT continue fetching from that domain. For S357 thin slice: mirror Vietstock posture — log WARNING + skip; circuit-open detection upgrade is a follow-up RM12 carry-forward.

### DD-10: Test fixture strategy — SYNTHETIC minimal HTML inline + ONE real HTML in CLI smoke recorded but NOT committed

**Decision**: Unit tests use SYNTHETIC minimal HTML strings (literal multi-line strings inline within `test_vietnambiz_adapter.py`). Production-realistic real HTML is fetched ONCE during CLI smoke (Sub-step 0.4 sample); recorded in session log but NOT committed to repo.

**Rationale** (mirror plan-026 DD-10):
- **Synthetic for unit tests**: per skill `.claude/skills/crawler-reliability/SKILL.md` § Anti-Patterns: unit tests use deterministic minimal fixtures to test parsing logic
- **Re-distributing scraped HTML**: legal grey-zone per skill § Anti-Patterns ("Committing scraped data without `source_url` violates I-S2 citation rule")
- **CLI smoke as the live-state verification**: one manual smoke records URL/status/bytes/title/body-length/mentioned_tickers

**Adversarial alternate considered**:
- All-real-HTML committed to `tests/fixtures/vietnambiz/*.html` → rejected (per plan-022/026 DD-10: fixture-licensing concern; fixtures drift as VietnamBiz redesigns site)
- All-mocked httpx responses via pytest-httpx → rejected (extra dep; over-engineered; pattern not adopted by sibling adapters)

---

## E. Sub-track decomposition (D1..D5; parallel_with field per plan-025 DD-3)

### D1 — VietnamBizAdapter implementation (greenfield Strategy A; F2-aware `_fetch_with_optional_chain` from day 1)

- **parallel_with**: []
- **blocks_on**: []
- **coordination_paths_exclusive**: [packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py]
- **estimated_wall_min**: 13 (Phase 1b n=2 calibrated: Vietstock D1 ~14 min wall; VietnamBiz benefits from n=2 confidence reducing exploration overhead, estimated -1 min)

**Module**: `packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` (NEW; ~250-350 LOC).

**Class shape** (architect-proposed; dev adjusts per STEP 0 findings; mirror VietstockAdapter `vietstock_adapter.py` lines 1-476):

```python
"""VietnamBizAdapter — CrawlerAdapter implementation for VietnamBiz (vietnambiz.vn).

Strategy A (direct-subclass) per plan-027 § DD-3.
Third + FINAL consumer of SelectorChain[T] per plan-027 § DD-4
(after NDH at S344 + Vietstock at S354).

Site: vietnambiz.vn (canonical as of 2026-05-XX; STEP 0.1 verifies).
Note: plan-020 § E matrix line 354 listed URL as "vietstockfinance.vn" which
was a typo; correct URL is vietnambiz.vn per plan-027 STEP 0.1 verification.

STEP 0 live verification (2026-05-XX S357):
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
    datetime). Rule 16 surface preserved by construction (plan-020/022/026/027
    Schema discipline).

D-059 compliance:
    R1 (datetime-no-tz): clock() returns tz-aware datetime; _parse_published_at
    always attaches tzinfo=UTC when absent.
    R2 (unseeded RNG): no RNG usage.
    R4 (time.time-in-domain): no time.time; clock injectable.

S345 F2-aware design (PROMOTED — n=2 day-one precedent established at Vietstock):
    _fetch_with_optional_chain accepts keyword-only store_raw: bool = True;
    discover() passes store_raw=False to avoid listing-page HTML contamination
    of data/raw/news/vietnambiz/ (architected from day 1; n=3 store_raw
    presence; n=2 day-one ship; L-S345-3 PROMOTE-NOW trigger condition).

Rate-limit posture (DD-5):
    base_delay = 3.0s default per plan-020 § E matrix line 354 + skill
    .claude/skills/crawler-reliability/SKILL.md § Rate Limiting
    "VietnamBiz less lenient than CafeF" — conservative bump from
    CafeF/NDH/Vietstock 2.0s default.

Source: plan 027-S356-phase-d-vietnambiz-adapter.md Sub-track D1
        STEP 0 live verification recorded in session log 2026-05-XX-session-357.md
        apps/_shared/crawl/selector_chain.py (SelectorChain[T] primitive)
        packages/infrastructure/news/crawler_adapters/vietstock_adapter.py
        (sibling reference -- 2nd Strategy A; F2-day-one shape already proven)
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

# Reuse ScrapedArticle from cafef_scraper (same pragmatic choice NDH/Vietstock made)
from packages.infrastructure.news.cafef_scraper import ScrapedArticle

__all__ = ["VietnamBizAdapter"]

_log = logging.getLogger(__name__)

# STEP 0.1 verified [DATE]: vietnambiz.vn is the canonical host.
_DEFAULT_VIETNAMBIZ_BASE_URL = "https://VERIFIED_HOST"  # FILLED by dev from STEP 0.1
_DEFAULT_USER_AGENT = (
    "stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"
)
# STEP 0.2 verified [DATE]: no Crawl-delay directive in robots.txt;
# default 3.0 s applies per plan-027 DD-5 (skill flag VietnamBiz less lenient).
_DEFAULT_RATE_LIMIT_SECONDS = 3.0

# STEP 0.4 verified [DATE]: article URL pattern
_ARTICLE_URL_RE = re.compile(r"PLACEHOLDER")  # FILLED by dev


@dataclass
class VietnamBizAdapter(CrawlerAdapter):
    """CrawlerAdapter for vietnambiz.vn (BC-5 News Stream).

    Strategy A (direct-subclass): implements discover / fetch_and_parse /
    to_news_article from scratch using SelectorChain[T] for headline + body
    extraction. Date extraction uses a fmt-string fallback chain inside
    _parse_published_at. Uses BeautifulSoup for HTML parsing.

    Greenfield -- no legacy class to wrap (Strategy A per plan-027 DD-3).
    Third + FINAL consumer of SelectorChain[T] (Phase D Theme L per-source
    rollout closes after this adapter).

    Default construction::

        adapter = VietnamBizAdapter(fetcher=_httpx_fetcher)

    With full injections::

        adapter = VietnamBizAdapter(
            fetcher=_httpx_fetcher,
            rate_limiter=RateLimiter(base_delay=3.0),  # DD-5 conservative
            robots_manager=RobotsTxtManager(fetcher=robots_fetcher),
            raw_html_sink=RawHtmlSink(base_dir=Path("data/raw/news")),
            clock=lambda: datetime.now(UTC),
        )
    """

    source_id: ClassVar[str] = "vietnambiz"

    fetcher: Callable[[str], str]
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    rate_limiter: object = field(default=None)  # RateLimiter | None
    robots_manager: object = field(default=None)  # RobotsTxtManager | None
    raw_html_sink: object = field(default=None)  # RawHtmlSink | None
    base_url: str = _DEFAULT_VIETNAMBIZ_BASE_URL
    rate_limit_seconds: float = _DEFAULT_RATE_LIMIT_SECONDS

    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from a VietnamBiz listing page.

        Note: per DD-7 F2-aware design, listing-page HTML is NOT persisted
        (store_raw=False) -- avoids contamination of data/raw/news/vietnambiz/.
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
        """Fetch + parse a single VietnamBiz article URL.

        Mirror VietstockAdapter.fetch_and_parse shape (vietstock_adapter.py:196-279).
        SelectorChain[T] for headline + body; fmt-string chain for date.
        """
        from bs4 import BeautifulSoup, Tag

        try:
            html = self._fetch_with_optional_chain(url)  # default store_raw=True
        except Exception as exc:
            _log.warning("vietnambiz_adapter: fetch failed for url=%r: %s", url, exc)
            return None

        soup = BeautifulSoup(html, "html.parser")

        # ---- Headline chain (DD-4 / STEP 0.4 verified [DATE]) ----
        headline_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("h1", class_="PLACEHOLDER_HEADLINE_CLASS"),
                lambda: soup.find("h1"),
                lambda: soup.find("meta", attrs={"property": "og:title"}),
            ],
            label="vietnambiz_headline",
        )
        headline_tag, _ = headline_chain.apply()
        if headline_tag is None:
            return None
        # (extract text per Vietstock vietstock_adapter.py:238-246 pattern)
        ...

        # ---- Body chain (DD-4 / STEP 0.4 verified [DATE]) ----
        body_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("div", class_="PLACEHOLDER_BODY_CLASS_1"),
                lambda: soup.find("div", class_="PLACEHOLDER_BODY_CLASS_2"),
                lambda: soup.find("article"),
            ],
            label="vietnambiz_body_container",
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
        """Promote ScrapedArticle to NewsArticle (mirror Vietstock vietstock_adapter.py:281-316)."""
        haystack = f"{scraped.title}\n{scraped.body_text}"
        mentioned = tuple(t for t in ticker_universe if t.symbol in haystack)
        article_id = hashlib.sha256(scraped.url.encode()).hexdigest()[:16]
        return NewsArticle(
            article_id=article_id,
            source="vietnambiz",
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
        avoid listing-page HTML contamination of data/raw/news/vietnambiz/.
        Mirror VietstockAdapter._fetch_with_optional_chain at
        vietstock_adapter.py:322-369 (day-one shape; not retrofit).
        """
        rl = self.rate_limiter
        if rl is not None and hasattr(rl, "wait_if_needed"):
            rl.wait_if_needed(url)
        rm = self.robots_manager
        if rm is not None and hasattr(rm, "can_fetch") and not rm.can_fetch(url):
            _log.warning("vietnambiz_adapter: robots.txt disallows url=%r -- skipping", url)
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
                        "vietnambiz_adapter: raw_html_sink.write failed for url=%r: %s",
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
        """STEP 0.4 confirms VietnamBiz article URL pattern; dev FILLS this method."""
        return bool(_ARTICLE_URL_RE.search(href))

    def _parse_published_at(self, soup: object) -> datetime | None:
        """Best-effort publish-date parse (mirror Vietstock vietstock_adapter.py:397-476).

        STEP 0.4 confirms VietnamBiz's actual datetime tag candidates + format strings.
        VietnamBiz commonly uses Vietnamese locale '%d/%m/%Y %H:%M' in addition
        to ISO-8601 — dev FILLS the actual list.
        """
        from bs4 import BeautifulSoup, Tag
        if not isinstance(soup, BeautifulSoup):
            return None
        # STEP 0.4 fills tag candidates + format strings
        ...
```

**Note on `ScrapedArticle` re-use**: Imports `ScrapedArticle` from `packages.infrastructure.news.cafef_scraper` (same pragmatic choice NDH + Vietstock made at `ndh_adapter.py:68` + `vietstock_adapter.py:78`). Cleaner long-term path: promote `ScrapedArticle` to `packages/contracts/scraped_article.py` (out-of-scope this bundle; document as carry-forward — at n=3 the case for promotion strengthens but architect verdict still defers per RM12).

**Pattern statement**: Strategy A direct-subclass; uses `SelectorChain[T]` per chain × 2 (headline, body) + fmt-string chain inside `_parse_published_at`; reuses `_fetch_with_optional_chain(*, store_raw)` pattern from Vietstock day-one shape.

### D2 — HTML parser internals (selector authoring per STEP 0 findings) — merged into D1

D2 is conceptually distinct (selector filling vs adapter scaffolding) but operationally merged into D1: dev fills placeholders in the D1 module body using STEP 0.4 findings. No separate file; no separate sub-track-level commit. Documented here for verifier clarity (mirror plan-026 D2 note).

Specifically dev fills:
- `_headline_chain.strategies` — replace placeholder lambdas with verified selectors
- `_body_chain.strategies` — same
- `_is_article_url(href)` — replace placeholder regex with verified URL pattern
- `_DEFAULT_VIETNAMBIZ_BASE_URL` — replace `"https://VERIFIED_HOST"` with verified canonical host
- `_ARTICLE_URL_RE` — replace `re.compile(r"PLACEHOLDER")` with verified regex
- format strings in `_parse_published_at` — replace placeholder list with verified VietnamBiz date formats

**Document each replacement in code comments**: `# STEP 0.4 verified 2026-05-XX: <observation>` — gives the verifier audit-trail (mirror Vietstock pattern at `vietstock_adapter.py:84-100`).

### D3 — Unit tests (≥12 test cases; tests 7 + 19 MANDATORY for DD-7 F2-aware quintuple-guard)

- **parallel_with**: [D4, D5]
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py]
- **estimated_wall_min**: 8 (Phase 1b n=2 calibrated: Vietstock D3 ~8 min)

**Module**: `packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py` (NEW; ~300-450 LOC).

**Test cases (target ≥12; numbering mirrors plan-026 for verifier-symmetry)**:

1. `test_vietnambiz_adapter_declares_source_id` — `VietnamBizAdapter.source_id == "vietnambiz"`
2. `test_vietnambiz_adapter_can_be_registered` — fresh `CrawlerRegistry()`; `registry.register(VietnamBizAdapter(fetcher=lambda _: ""))` succeeds; `registry.get("vietnambiz") is adapter`
3. `test_supports_source_id_positive` — `VietnamBizAdapter.source_id` matches the registered ID per D-066 contract
4. `test_discover_returns_expected_urls_from_fixture` — synthetic listing HTML with 3 known article anchors; `discover("/listing", max_articles=10)` returns those 3 absolute URLs in order (deduped)
5. `test_discover_respects_max_articles_cap` — synthetic listing with 10 anchors; `discover(..., max_articles=3)` returns exactly 3
6. `test_discover_dedupes_repeat_anchors` — synthetic listing with same URL 5×; returns 1 entry
7. **`test_discover_does_not_persist_raw_html_via_sink`** — Mock RawHtmlSink; assert `sink.write` NOT called when `discover()` runs (DD-7 F2-aware verification — KEY ARCHITECTURAL TEST; quintuple-guard item 4)
8. `test_fetch_and_parse_happy_path` — synthetic article HTML matching expected VietnamBiz structure; returns `ScrapedArticle` with correct title + body + published_at
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
19. **`test_fetch_and_parse_writes_raw_html_via_sink`** — Mock RawHtmlSink; assert `.write()` called with correct args (source_id="vietnambiz", url, html, fetched_at tz-aware) — companion to test 7; DD-7 F2-aware quintuple-guard item 5
20. `test_adapter_default_no_injections_still_works` — `VietnamBizAdapter(fetcher=lambda _: SYNTHETIC_HTML)` no injections; `fetch_and_parse` still returns ScrapedArticle
21. `test_vietnambiz_adapter_rate_limit_default_is_3_seconds` — `VietnamBizAdapter(fetcher=...).rate_limit_seconds == 3.0` (DD-5 verification — distinct from CafeF/NDH/Vietstock 2.0s)

**Minimum acceptance**: ≥12 of the above 21 (architect proposes 12 as floor; tests 7 + 19 + 21 are MANDATORY — they validate DD-7 F2-aware design AND DD-5 conservative rate-limit posture).

**Synthetic fixture HTML** (architect proposes; dev refines per STEP 0.4):

```python
_SYNTHETIC_VIETNAMBIZ_ARTICLE_HTML = """<!DOCTYPE html>
<html>
<head>
  <meta property="og:title" content="VHM báo cáo kết quả kinh doanh quý 1 tăng trưởng" />
  <meta property="article:published_time" content="2026-05-15T10:30:00+07:00" />
</head>
<body>
  <h1 class="PLACEHOLDER_HEADLINE_CLASS">VHM báo cáo kết quả kinh doanh quý 1 tăng trưởng</h1>
  <div class="PLACEHOLDER_BODY_CLASS_1">
    <p>Công ty cổ phần Vinhomes (VHM) công bố kết quả kinh doanh quý 1...</p>
    <p>FPT cũng được kỳ vọng có tăng trưởng tích cực trong quý 2.</p>
  </div>
</body>
</html>
"""

_SYNTHETIC_VIETNAMBIZ_LISTING_HTML = """<!DOCTYPE html>
<html><body>
  <a href="/co-phieu/vhm-loi-nhuan-quy-1-12345.html">VHM Q1</a>
  <a href="/co-phieu/fpt-tang-truong-12346.html">FPT growth</a>
  <a href="/co-phieu/hpg-quan-su-12347.html">HPG news</a>
  <a href="/co-phieu/vhm-loi-nhuan-quy-1-12345.html">VHM Q1 (duplicate)</a>
  <a href="/about-us">About</a>
</body></html>
"""
```

### D4 — Registry wire + CLI smoke

- **parallel_with**: [D3, D5]
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [packages/infrastructure/news/crawler_adapters/__init__.py, apps/cli/ingest_news_vietnambiz.py]
- **estimated_wall_min**: 9 (Phase 1b n=2 calibrated: Vietstock D4 ~8 min; VietnamBiz +1 min for 3.0s rate-limit CLI smoke wall-time inflation per Calibration § parallel_savings note)

**Module 1**: `packages/infrastructure/news/crawler_adapters/__init__.py` UPDATED:

```python
"""BC-5 News infrastructure — per-source crawler adapters."""

from .cafef_adapter import CafeFAdapter
from .ndh_adapter import NDHAdapter
from .vietnambiz_adapter import VietnamBizAdapter
from .vietstock_adapter import VietstockAdapter

__all__ = ["CafeFAdapter", "NDHAdapter", "VietnamBizAdapter", "VietstockAdapter"]
```

**Module 2**: `apps/cli/ingest_news_vietnambiz.py` (NEW; ~300 LOC). Mirror `apps/cli/ingest_news_vietstock.py` structure exactly:
- click CLI with same flags (`--tickers`, `--since`, `--max-articles`, `--listing`, `--output`, `--skip-llm`, `--summary`)
- `_httpx_fetcher` helper with same UA pattern
- `_robots_fetcher` helper for RobotsTxtManager
- `main()` constructs:
  - `httpx_fetcher = _httpx_fetcher` (closure)
  - **`rate_limiter = RateLimiter(base_delay=3.0, max_delay=60.0, max_retries=5)`** ← DD-5 conservative 3.0s default (NOT 2.0s like CafeF/NDH/Vietstock)
  - `robots = RobotsTxtManager(fetcher=_robots_fetcher)`
  - `sink = RawHtmlSink(base_dir=Path("data/raw/news"))`
  - `registry = CrawlerRegistry()`
  - `registry.register(VietnamBizAdapter(fetcher=httpx_fetcher, rate_limiter=rate_limiter, robots_manager=robots, raw_html_sink=sink))`
  - `adapter = registry.get("vietnambiz")`
  - per-URL loop mirroring Vietstock CLI
- Persist via existing `SqliteNewsRepository` + `SqliteClaimRepository`
- LLM extraction via existing `ClaudeLlmExtractor` + `ClaimExtractionService` (UNLESS `--skip-llm`)
- Emit `NewsArticleIngested` + `ExtractedClaimPublished` events (UNLESS `--skip-llm`)
- Exit code 0 on success; click `UsageError` on invalid input
- Summary markdown output (sentiment counts + first 5 articles)

**CLI smoke (live verification — manual; recorded in session log)**:

```bash
python apps/cli/ingest_news_vietnambiz.py \
  --tickers VHM,FPT,HPG \
  --max-articles 1 \
  --listing /chung-khoan \
  --output ./data/tmp-vietnambiz-smoke.sqlite \
  --skip-llm \
  --summary 2>&1 | tee /tmp/vietnambiz-smoke.log
```

Record in session log:
- Status codes observed (200 expected; any 4xx/5xx flagged)
- Bytes fetched per request
- Total wall-clock time (validates 3.0s rate-limit honored — should be ≥ 3.0s × N_requests)
- Number of articles successfully parsed
- Verify `data/raw/news/vietnambiz/<date>/<hash>.html` exists with expected content
- Verify NO `data/raw/news/vietnambiz/.../<listing-page-hash>.html` exists (DD-7 F2-aware verification — listing-page raw HTML MUST NOT be persisted; quintuple-guard item 6)
- Verify SQLite contains 1 NewsArticle row with source="vietnambiz"
- Verify `--summary` output matches expected markdown shape

### D5 — ADR D-066 REV-3 amendment (VietnamBiz cited as 3rd consumer; closes Phase D Theme L per-source rollout)

- **parallel_with**: [D3, D4]
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md]
- **estimated_wall_min**: 4 (Phase 1b n=2 calibrated: Vietstock D5 ~3 min; +1 min for Phase-D-close attestation language)

Add an **Amendments** entry to `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` § Amendments (append-only). REV-1 already exists from S345 close per plan-022 § L (NDH = 1st consumer); REV-2 added at S354 close per plan-026 § L (Vietstock = 2nd consumer); REV-3 documents VietnamBiz = 3rd + FINAL consumer + closes Phase D Theme L per-source rollout.

**Proposed amendment text** (architect-drafted; dev verifies + lands at S357 close):

```markdown
### REV-3 (2026-05-XX) — VietnamBiz adapter shipped as 3rd + FINAL Strategy A consumer; SelectorChain[T] contract maturity 1 -> 2 -> 3 consumers; Phase D Theme L per-source rollout CLOSED

- **Trigger**: plan-027-S356 ships VietnamBizAdapter as third + FINAL greenfield Strategy A direct-subclass + third SelectorChain[T] consumer (after NDH at S344 + Vietstock at S354)
- **Authorization**: plan-027 § L (architect-proposed) + S358 verifier acceptance (pending)
- **Source artifacts**:
  - agent-workspace/session-plans/completed/027-S356-phase-d-vietnambiz-adapter.md § DD-4 + § D1 + § H 5-source-evidence chain row 2
  - packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py (NEW; uses 2 SelectorChain[T] instances for headline + body fields; fmt-string chain for date)
  - packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py (NEW; ≥12 test cases including SelectorChain fallback coverage AND DD-7 F2-aware test 7 + 19 + DD-5 rate-limit test 21)
  - apps/cli/ingest_news_vietnambiz.py (NEW; CLI dispatch via fresh CrawlerRegistry + VietnamBizAdapter registration; rate-limit 3.0s per DD-5)
- **Summary of changes**:
  - CrawlerAdapter ABC contract validated across 3 distinct greenfield consumers (NDH + Vietstock + VietnamBiz); contract maturity strengthens to n=3 — no contract gap surfaced (subject to verifier S358 re-confirmation per AQ-8)
  - SelectorChain[T] contract validated across 3 distinct VN financial sites; primitive proven production-ready at n=3 maturity threshold
  - DD-7 F2-aware design `_fetch_with_optional_chain(*, store_raw)` shipped from day 1 in VietnamBiz — n=2 day-one ship (Vietstock 1st day-one; VietnamBiz 2nd day-one); n=3 store_raw presence overall — promotion of S345 verifier F2 lesson into upstream design discipline (L-S345-3 PROMOTE-NOW TRIGGER FIRES per § L if S358 confirms quintuple-guard ALL GREEN)
  - DD-5 conservative 3.0s rate-limit posture established per plan-020 § E matrix line 354 + skill .claude/skills/crawler-reliability/SKILL.md § Rate Limiting "VietnamBiz less lenient"; first per-source rate-bump in BC-5 adapter suite (CafeF/NDH/Vietstock all 2.0s)
- **Phase D Theme L per-source rollout CLOSED**: all 4 priority VN financial-news sources (CafeF Strategy B WRAP + NDH/Vietstock/VietnamBiz Strategy A direct-subclass) shipped. Master plan § 5.7 + § 6.4.1 closure milestone achieved. Phase E Theme I Vietnamese NLP entry unblocked.
- **Verifier impact**: S358 spot-checks VietnamBizAdapter's SelectorChain usage + DD-7 F2-aware design empirically (grep for `store_raw=False` in discover() body; CLI smoke verifies no listing-page HTML in data/raw/; rate-limit-3.0s test 21 confirms DD-5 binding)
- **Next consumer**: NONE for Strategy A direct-subclass pattern. Future Phase D-N consolidation candidates (RM12 carry-forward): CafeFAdapter Strategy B → Strategy A migration + ScrapedArticle promotion to packages/contracts/ + L-S354-1 Protocol-typed injection refactor. Phase E entry takes priority.
```

**Session log**: `agent-workspace/memory/sessions/2026-05-XX-session-357.md` per CLAUDE.md § Session Protocol End — captures STEP 0 sub-step results + D1-D5 outcomes + DD-7 F2-aware verification + DD-5 rate-limit verification + ADR REV-3 amendment + Phase D Theme L closure note + mistakes (if any) + harness gaps surfaced.

**Observation file**: `agent-workspace/memory/observations/sandwich-dev-S357-vietnambiz-adapter.md` — dev's return artifact per Track 6.

---

## F. DoD checklist (≥30 items — target 35 per plan-026 cadence)

Aggregated across all 5 sub-tracks; verifier S358 confirms each empirically:

### File-existence DC (DC-FILE-N)

- [ ] **DC-FILE-1** — `packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` exists
- [ ] **DC-FILE-2** — `packages/infrastructure/news/crawler_adapters/__init__.py` exports `VietnamBizAdapter` alongside `CafeFAdapter` + `NDHAdapter` + `VietstockAdapter`
- [ ] **DC-FILE-3** — `packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py` exists (mirrors Vietstock test-file path convention)
- [ ] **DC-FILE-4** — `apps/cli/ingest_news_vietnambiz.py` exists
- [ ] **DC-FILE-5** — ADR D-066 § Amendments has new REV-3 entry per § D5
- [ ] **DC-FILE-6** — `agent-workspace/memory/sessions/2026-05-XX-session-357.md` exists
- [ ] **DC-FILE-7** — `agent-workspace/memory/observations/sandwich-dev-S357-vietnambiz-adapter.md` exists
- [ ] **DC-FILE-8** — `data/raw/news/vietnambiz/<YYYY-MM-DD>/<hash>.html` exists (proves CLI smoke wrote raw HTML for article path)
- [ ] **DC-FILE-9** — NO listing-page HTML persisted under `data/raw/news/vietnambiz/` (DD-7 F2-aware verification; KEY quintuple-guard item 6 — verifies discover() did NOT call sink.write)

### LOC + structure DC (DC-LOC-N)

- [ ] **DC-LOC-1** — `vietnambiz_adapter.py` LOC is between 200 and 400 (architect estimate; dev reports actual; mirror Vietstock `vietstock_adapter.py` ~476 LOC — Vietstock above-ceiling-accepted per S355; same content-driven leeway extends)
- [ ] **DC-LOC-2** — Test file LOC is between 250 and 550 (≥12 test cases per architect floor; +1 case for DD-5 verification test 21 vs Vietstock 23 tests)
- [ ] **DC-LOC-3** — CLI LOC is between 250 and 400 (mirrors `ingest_news_vietstock.py` per existing layout)

### VietnamBizAdapter contract DC (DC-IMPL-N)

- [ ] **DC-IMPL-1** — `VietnamBizAdapter.source_id == "vietnambiz"` (ClassVar; non-empty)
- [ ] **DC-IMPL-2** — `VietnamBizAdapter` subclasses `CrawlerAdapter` (NOT wraps; Strategy A direct-subclass per DD-3)
- [ ] **DC-IMPL-3** — `VietnamBizAdapter` implements all 3 abstract methods: `discover`, `fetch_and_parse`, `to_news_article`
- [ ] **DC-IMPL-4** — `VietnamBizAdapter.fetch_and_parse` uses ≥2 `SelectorChain[T]` instances (DD-4)
- [ ] **DC-IMPL-5** — `VietnamBizAdapter` accepts optional injections: `rate_limiter`, `robots_manager`, `raw_html_sink` (all default None; mirrors Vietstock shape)
- [ ] **DC-IMPL-6** — `VietnamBizAdapter` uses verified UA `"stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"` (DD-8)
- [ ] **DC-IMPL-7** — `VietnamBizAdapter._fetch_with_optional_chain` signature is `(url: str, *, store_raw: bool = True) -> str` (DD-7 F2-aware quintuple-guard item 1; keyword-only via `*`)
- [ ] **DC-IMPL-8** — `VietnamBizAdapter.discover` body contains `store_raw=False` literal (DD-7 F2-aware quintuple-guard item 2; verifier grep-asserts)
- [ ] **DC-IMPL-9** — `VietnamBizAdapter._fetch_with_optional_chain` body contains `if store_raw:` sink-write guard (DD-7 F2-aware quintuple-guard item 3)
- [ ] **DC-IMPL-10** — `VietnamBizAdapter.rate_limit_seconds == 3.0` default (DD-5; distinct from CafeF/NDH/Vietstock 2.0s); test 21 covers

### I-S34 + Rule 16 compliance DC (DC-COMPLIANCE-N)

- [ ] **DC-COMPLIANCE-1** — `grep -rE "patchright|playwright_stealth|playwright-stealth|fake[-_]useragent|UndetectedAdapter|StealthyFetcher|_cloudflare_solver" packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py apps/cli/ingest_news_vietnambiz.py packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py` returns ZERO matches in IMPORT statements (docstring attestation hits acceptable per Vietstock S355 precedent)
- [ ] **DC-COMPLIANCE-2** — `VietnamBizAdapter.fetch_and_parse` emits `ScrapedArticle` with ZERO new numeric fields (Rule 16 by construction)
- [ ] **DC-COMPLIANCE-3** — robots.txt verdict from STEP 0.2 documented in session log; verifier re-runs protego check
- [ ] **DC-COMPLIANCE-4** — Rate-limit profile (3.0s default per DD-5 OR bumped per Crawl-delay) documented in session log + reflected in CLI construction
- [ ] **DC-COMPLIANCE-5** — UA string verified verbatim in CLI fetcher AND in adapter docstring reference

### Deterministic gates DC (DC-GATE-N)

- [ ] **DC-GATE-1** — `python -m mypy --strict packages/infrastructure/news/crawler_adapters/ apps/cli/ingest_news_vietnambiz.py` exits 0 (4-5 unused `type: ignore[union-attr]` acceptable per L-S354-1 1st-instance HOLD pattern from Vietstock S355; F2 carry-forward not regression)
- [ ] **DC-GATE-2** — `python -m ruff check packages/infrastructure/news/crawler_adapters/ apps/cli/ingest_news_vietnambiz.py` exits 0
- [ ] **DC-GATE-3** — `python -m pytest packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py -q` exits 0; ≥12 new test cases pass (mandatory: tests 7 + 19 + 21)
- [ ] **DC-GATE-4** — `python -m pytest packages/ apps/ tests/ -q` exits 0; new test count = STEP 0.8 baseline + ≥12 (target ≥1025); ZERO regression on baseline
- [ ] **DC-GATE-5** — `bash scripts/hooks/firing-tests/run-all.sh` exits 0 (no firing-test regression)
- [ ] **DC-GATE-6** — `bash scripts/hooks/python-determinism-check.sh </dev/null` exits 0 on VietnamBiz new modules (D-059 R1/R2/R4 compliance)
- [ ] **DC-GATE-7** — `bash scripts/hooks/atomic-write-check.sh </dev/null` exits 0 on VietnamBiz new modules (D-062 — RawHtmlSink already wraps atomic)
- [ ] **DC-GATE-8** — `bash scripts/hooks/path-safety-check.sh </dev/null` exits 0 on VietnamBiz new modules (D-064 — RawHtmlSink already uses safe_path)

### CLI smoke DC (DC-SMOKE-N)

- [ ] **DC-SMOKE-1** — Manual CLI smoke executed; recorded in session log with timestamp + status code + bytes fetched + parsed-article count
- [ ] **DC-SMOKE-2** — Smoke produced ≥1 row in `data/tmp-vietnambiz-smoke.sqlite` with `source="vietnambiz"`
- [ ] **DC-SMOKE-3** — Raw HTML file for ARTICLE exists at `data/raw/news/vietnambiz/<YYYY-MM-DD>/<hash>.html` per DC-FILE-8
- [ ] **DC-SMOKE-4** — NO listing-page HTML under `data/raw/news/vietnambiz/` per DC-FILE-9 (DD-7 F2-aware empirical verification; quintuple-guard item 6 — `find data/raw/news/vietnambiz -newer <smoke-start>` returns only article-page hashes; verifier re-runs)
- [ ] **DC-SMOKE-5** — Wall-clock time of smoke ≥ 3.0s × N_requests (validates DD-5 RateLimiter honored — 3.0s NOT 2.0s)

### Bookkeeping DC (DC-BOOK-N)

- [ ] **DC-BOOK-1** — Session log `2026-05-XX-session-357.md` written per CLAUDE.md § Session Protocol End
- [ ] **DC-BOOK-2** — `agent-workspace/memory/current-execution.md` updated: Phase D Theme L row reflects S357 VietnamBiz-adapter SHIPPED + Phase D Theme L CLOSED; next-action = S358 sandwich-verifier dispatch; post-S358 next-Phase = E Theme I Vietnamese NLP entry
- [ ] **DC-BOOK-3** — `agent-workspace/memory/mistake-log.md` either appended (M-S357-N if mistakes) OR session log explicitly states "no mistakes this session" (enforced by `session-end-checklist-linter.sh` Stop hook)
- [ ] **DC-BOOK-4** — Plan moved `pending/027-S356-phase-d-vietnambiz-adapter.md` → `completed/027-S356-phase-d-vietnambiz-adapter.md` at S358 close (NOT at S357 close — verifier acceptance gates the move)
- [ ] **DC-BOOK-5** — D-066 § Amendments REV-3 added per § D5
- [ ] **DC-BOOK-6** — `agent-workspace/memory/project.md` Phase Goals Tracker updated: Phase D Theme L row marked CLOSED; Phase E Theme I row marked UNBLOCKED (per CLAUDE.md § End rule 7 + `phase-status-coherence.sh` UserPromptSubmit cadence + `project-md-adr-staleness.sh` Stop cadence)

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why Strategy A direct-subclass, not Strategy B WRAP?

**Answer**: No existing VietnamBiz scraper code exists to wrap. Same rationale as plan-022/026 AQ-1 for NDH/Vietstock. VietnamBiz is greenfield — no legacy. Strategy A is the canonical pattern for greenfield adapters per plan-020 § E matrix line 354 and plan-022/026 DD-3 precedent (now n=2 ratification, becoming n=3 with VietnamBiz).

### AQ-2 — Why SelectorChain[T] consumption now (3rd + FINAL consumer)?

**Answer**: NDH was the 1st consumer at S344; Vietstock 2nd at S354; VietnamBiz is the 3rd + FINAL. Three consumers validate the primitive's contract maturity at the AP-23 promotion threshold (3-instance standard for confident promotion to "production-ready primitive"). Plan-027 § L REV-3 amendment formalises this — the closure paragraph.

### AQ-3 — Why subclass not Protocol/ABC composition?

**Answer**: Per D-066 § Decision — CrawlerAdapter is ABC; subclass enforces `__init_subclass__` guard that runs at class-definition time (verifying non-empty `source_id` ClassVar). Protocol can't enforce at definition time. Same rationale as plan-022/026 AQ-3.

### AQ-4 — Why not bundle Phase E entry into this plan (one mega-session)?

**Answer**: RM4 from plan-020/022/026 § Risk table (S4 catastrophic-mix-pattern). Phase E Theme I Vietnamese NLP is a distinct BC-5/BC-6 boundary surface (token classification + sentiment classification primitives) — entirely different scope from BC-5 News Stream adapter ship. Bundling would: (a) require Phase E entry STEP 0 separately + (b) double the IMPL scope + (c) violate "never mix PLAN and IMPL" (Phase E entry needs its own PLAN session). Architect verdict: SPLIT — Phase E entry plan-028 (S359 or later) as separate PLAN session post-S358 verifier-accept of VietnamBiz.

### AQ-5 — STEP 0 finds `vietnambiz.vn` 404 — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Dev writes `STOP-FINDING-S357-vietnambiz-url-404.md` to `human-workspace/notifications/`. Defer VietnamBiz adapter; flag in mistake-log as `M-S357-N: VietnamBiz site defunct or moved`; surface in observation. Note: plan-020 § E matrix line 354 listed URL as `vietstockfinance.vn` (TYPO); correct URL is `vietnambiz.vn` — STEP 0.1 explicitly verifies.

### AQ-6 — STEP 0 finds robots.txt disallows — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Honor robots.txt absolutely (I-S34 charter line 110). Defer VietnamBiz adapter; flag in mistake-log; main session may decide to abandon VietnamBiz as source or contact for explicit consent. Note: VietnamBiz historically less lenient per skill flag — robots.txt disallow more likely than for CafeF/NDH/Vietstock.

### AQ-7 — STEP 0 finds site is JS-rendered (requires Playwright) — what then?

**Answer**: STOP-AND-ASK per STEP 0 STOP clause. Per I-S34 HARD BAN of patchright + playwright_stealth + StealthyFetcher (D-061 § Decision item 4), cannot install JS-rendering infrastructure. Defer VietnamBiz adapter; flag as harness gap. Note: plan-020 § E matrix line 354 "Static HTML hypothesis" — JS-rendering would invalidate the hypothesis + require master plan amendment.

### AQ-8 — SelectorChain[T] contract doesn't fit VietnamBiz layout — what then?

**Answer**: Surface as plan-027 finding; STOP and choose Path B (new D-067 ADR amendment per § D5 Path B mirror from plan-022/026). Do NOT silently bypass the contract. Architect prediction: contract is well-formed at n=2; VietnamBiz should validate at n=3 confirming production-ready maturity. If gap surfaces, it's a SIGNIFICANT contract issue (n=2 didn't catch it) — escalate to architect re-plan.

### AQ-9 — Test fixture HTML licensing (re-distributing scraped HTML in tests) — OK?

**Answer**: Use SYNTHETIC minimal HTML for unit tests (per DD-10). Real HTML used ONLY for CLI smoke recorded in session log but NOT committed (saved to `tmp/vietnambiz_sample.html` which dev MUST ensure is gitignored). Verifier S358 grep-asserts: `grep -rE "vietnambiz\.vn" packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py` returns ZERO real-URL leakage in test fixtures (synthetic-only).

### AQ-10 — Rate-limit 3.0s — is it conservative enough?

**Answer**: 3.0s is the default per plan-020 § E matrix line 354 + skill `.claude/skills/crawler-reliability/SKILL.md` § Rate Limiting "VietnamBiz less lenient than CafeF". STEP 0.2 may override (mandatory bump if `Crawl-delay > 3.0`). STEP 0.4 empirical signal: if sample fetch returns 429/503 OR an unusually slow response (>5s) → consider bumping to 4.0s. If STEP 0.4 returns 200 cleanly within 1s → 3.0s is fine per skill prior. Dev decides at IMPL time; flag rate-limit decision for verifier in session log. **DO NOT downgrade to 2.0s** without empirical evidence countering the skill prior (charter Principle 8 calibration-over-confidence binding).

---

## H. 5-source-evidence chain per adopted pattern (matches plan-020/022/026 § H shape)

| Adopted pattern | (1) Source file:line | (2) Skill / deep-dive | (3) Integration X-ref | (4) Charter invariant | (5) Stockforge codebase precedent |
|---|---|---|---|---|---|
| **Strategy A direct-subclass of CrawlerAdapter** | `packages/application/news/ports/crawler_adapter.py:43-127` (ABC + 3 abstract methods + `__init_subclass__` enforcer) | ADR D-066 § Decision + .claude/skills/ddd-tactical-patterns/SKILL.md (adapter/port discipline) | Plan-020 § E matrix line 354 "VietnamBiz ... A" + plan-026 DD-3 Vietstock precedent (n=2) | I-S2 (source_url + as_of preserved); I-S22 (data lineage via source_id ClassVar) | **NDHAdapter at `ndh_adapter.py:90-345` (1st greenfield) + VietstockAdapter at `vietstock_adapter.py:103-477` (2nd greenfield); VietnamBiz = 3rd + FINAL, validates pattern at n=3 — AP-23 promotion threshold** |
| **SelectorChain[T] consumption for headline/body (3rd consumer)** | `apps/_shared/crawl/selector_chain.py:33-105` (frozen dataclass; `apply()` returns `(result, num_tried)`; logs WARNING if all fail) | .claude/skills/crawler-reliability/SKILL.md § Selector Robustness | ADR D-066 § REV-1 + REV-2 closed (NDH 1st + Vietstock 2nd consumer); this plan REV-3 closes 3rd consumer per § L | I-S34 (graceful degrade); I-S22 (label per chain for shape-metrics emit) | NDHAdapter at `ndh_adapter.py:206-244` + VietstockAdapter at `vietstock_adapter.py:224-260` — 2 SelectorChain instances each (headline + body); VietnamBiz mirrors with same shape; n=3 consumer maturity |
| **F2-aware `_fetch_with_optional_chain(*, store_raw)` from day 1 (n=2 day-one ship; n=3 store_raw presence)** | `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py:322-369` (day-one shape; not retrofit) | S345 verifier observation F2 IMPORTANT finding + S355 Vietstock verifier "L-S345-3 STRENGTHENED at n=2" + L-S345-3 PROMOTE-NOW candidate | This plan DD-7 (continues the day-one design; § L PROMOTE-NOW trigger if S358 confirms) | I-S22 (raw HTML preserved for reprocessing — but ONLY for ARTICLE pages; listing pages would pollute the lake) | NDH adapter pre-S345 was missing store_raw param; post-S345 fix at `ndh_adapter.py:159-160` + `ndh_adapter.py:336`; Vietstock at `vietstock_adapter.py:178` + `vietstock_adapter.py:352` (day-one); VietnamBiz adopts day-one shape (2nd day-one) |
| **RateLimiter primitive with seeded RNG — DD-5 3.0s CONSERVATIVE for VietnamBiz** | `apps/_shared/crawl/rate_limiter.py:79-169` (DomainState + RateLimiter; `wait_if_needed` + `report_response` returning circuit-open bool) | crawl4ai `async_dispatcher.py:28-85` (RateLimiter source) + **.claude/skills/crawler-reliability/SKILL.md § Rate Limiting line 54 — "CafeF is more lenient than VietnamBiz"** | ADR D-066 § Foundation primitives table + plan-020 DD-7 + **plan-020 § E matrix line 354 "VietnamBiz ... 3.0s default — skill § Rate Limiting flags VietnamBiz as less lenient than CafeF; conservative bump"** | I-S34 (≥2s/domain default; 429/503 backoff; per-source bumps); D-059 R2 (seeded RNG Random(0)); Charter Principle 8 (calibration over confidence — honor skill prior) | CafeFAdapter + NDHAdapter + VietstockAdapter all wire RateLimiter via `_fetch_with_optional_chain` helper with 2.0s default; **VietnamBiz is FIRST adapter with bumped 3.0s default** — per-source differentiation precedent |
| **RobotsTxtManager primitive with protego** | `apps/_shared/crawl/robots_manager.py:52-152` (sync port; lazy-import protego; in-memory cache) | Scrapling `spiders/robotstxt.py:10-60` (source) + .claude/skills/crawler-reliability/SKILL.md § Anti-Patterns | ADR D-066 § Foundation primitives table + plan-020 DD-6 | I-S34 charter line 110 "News scrapers respect robots.txt + reasonable rate limits + identify user agent" | CafeFAdapter + NDHAdapter + VietstockAdapter all wire RobotsTxtManager via optional injection; VietnamBiz mirrors |

---

## I. Risk-Mitigation table (RM1..RM11)

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| RM1 | **STEP 0 finds `vietnambiz.vn` 404** (DNS-fail or site moved) | Very Low (VietnamBiz is a established VN financial portal; should resolve) | High (no adapter possible; defer entire bundle) | STOP-AND-ASK per § C STEP 0 STOP clause + § G AQ-5 pre-answered. |
| RM2 | **STEP 0 finds site is JS-rendered** (article body requires JavaScript to populate DOM) | Low-Med (plan-020 § E matrix line 354 hypothesizes "Static HTML"; but VN portal sites occasionally redesign with Next.js / Vue; recent VietnamBiz may have shifted) | High (I-S34 HARD REJECT of Playwright) | STOP-AND-ASK per § C STEP 0 STOP clause + § G AQ-7 pre-answered. |
| RM3 | **SelectorChain[T] primitive needs refinement at n=3** | Very Low (validated at n=2; n=3 confirms production-ready per AP-23 standard) | Med (delays adapter ship by 1 session; requires D-067 ADR) | Path B per § D5 (mirror plan-022/026 § D5 Path B). Surface to verifier S358 for review. n=3 gap surfacing = SIGNIFICANT contract issue (escalate). |
| RM4 | **Dev mistakenly bundles Phase E entry too** (scope-creep; same anti-pattern as plan-020/022/026 RM4) | Low (plan explicitly scopes to VietnamBiz only + § B Out-of-scope item + AQ-4 pre-answers) | High (S4 catastrophic-mix-pattern recurrence; budget overrun; Phase E entry needs own PLAN session) | Plan title + Goal + § B + AQ-4 EXPLICITLY scope to VietnamBiz only + Phase E entry plan-028 deferred. |
| RM5 | **Rate-limit 3.0s insufficient** (VietnamBiz returns 429/503 under 3.0s — more conservative needed) | Low-Med (skill flag "less lenient" already informs 3.0s posture; STEP 0.4 empirically verifies) | Med (transient failures; ToS-grey territory) | Fall back to 4.0s per DD-5 fallback + flag for verifier. RateLimiter `report_response` handles 429/503 with exponential backoff automatically. STEP 0.4 sample fetch monitors response time + status. |
| RM6 | **protego dependency missing or version drift** | Low (plan-020 closure added; verify at STEP 0.6) | Low (lazy-import in RobotsTxtManager raises ImportError with install hint) | STEP 0.6 verifies all 6 primitives importable + sibling 3 adapters import. If protego import fails → `pip install -e .` to ensure pyproject.toml deps installed. |
| RM7 | **VietnamBiz publishes no robots.txt** (404 on `/robots.txt`) | Low (VietnamBiz is a professional portal; robots.txt expected) | Low (allow-all on 404 is the conservative correct behavior per `robots_manager.py:119-136`) | Per RobotsTxtManager `can_fetch` returns True on 404 (semantically correct). Skill § Anti-Patterns documents: absent robots.txt is NOT green light for unlimited fetching — rate-limit + UA still apply. **3.0s rate-limit posture is MORE conservative compensation for 404 robots.txt.** |
| RM8 | **Test fixture HTML drift** | Low (synthetic fixtures decoupled from live; STEP 0.4 sample saved to tmp only) | Low (fixture tests still validate parsing logic; CLI smoke catches drift at next deploy) | Synthetic HTML per DD-10 + AQ-9. Real HTML in CLI smoke only. If CLI smoke fails post-deploy → trigger M-S<N>-N investigate-VietnamBiz-drift entry. |
| RM9 | **VietnamBizAdapter accidentally introduces new LLM-numeric field** (Rule 16 D-065 violation) | Low (audit + STEP 0.5 anchor) | High (charter Principle 9 violation) | § C STEP 0.5 empirically confirms ZERO new numeric fields; VietnamBizAdapter emits SAME `ScrapedArticle` dataclass as NDH/CafeF/Vietstock. Verifier S358 DC-COMPLIANCE-2 is final gate. |
| RM10 | **I-S34 banned import creeps in** (patchright, playwright_stealth, fake-useragent, StealthyFetcher, _cloudflare_solver) | Very Low (CLAUDE.md hard rules + ADR D-066 § HARD REJECTED list + DC-COMPLIANCE-1 grep check + n=3 sibling-precedent reinforces) | Critical (charter-tier violation per D-061 § Decision item 4) | DC-COMPLIANCE-1 grep check at verifier S358; architect recommends dev SHOULD run grep BEFORE first commit. Any match = HARD FAIL — STOP and remove. Note: docstring attestation hits (e.g. "NO import of patchright") ACCEPTABLE per Vietstock S355 verifier precedent (`I-S34 grep: 2 hits both inside docstring`) — only import statements are violations. |
| **RM11** | **DD-7 F2-aware regression: dev forgets `store_raw=False` in discover()** (recreates NDH pre-S345 listing-page contamination bug) | **Very Low** (n=2 day-one precedent established at Vietstock S354; quintuple-guard pattern proven; DD-7 mandate from day 1 in this plan vs NDH retrofit; explicit DC-IMPL-7 + DC-IMPL-8 + DC-IMPL-9 + tests 7 + 19 + DC-SMOKE-4 + DC-FILE-9 = SEXTUPLE-GUARD the regression) | **High** (data lake corruption — listing-page HTML pollutes article-data tier; if undetected for many sources, requires cleanup pass) | **DC-IMPL-7** verifies method signature has `*, store_raw: bool = True`. **DC-IMPL-8** grep-asserts `store_raw=False` literal in discover() body. **DC-IMPL-9** grep-asserts `if store_raw:` sink-write guard. **Test 7** asserts sink.write NOT called during discover(). **Test 19** asserts sink.write IS called during fetch_and_parse(). **DC-SMOKE-4** empirically verifies post-smoke filesystem state. **DC-FILE-9** baseline cross-check. **6-layer sextuple-guard = no silent regression possible.** This RM is the **L-S345-3 PROMOTE-NOW VALIDATION POINT** — sextuple-guard ALL GREEN at S358 triggers SKILL update per § L. |

---

## J. Coordination paths (main session AVOIDS during S357 IMPL)

**Main session AVOIDS** during S357 IMPL window (cross-session edit conflict prevention; mirror plan-022/026 § J — `coordination_paths_exclusive` sets per sub-track for parallel-dispatch safety):

- `packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` (NEW — D1)
- `packages/infrastructure/news/crawler_adapters/__init__.py` (MODIFIED — D4)
- `packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py` (NEW — D3)
- `apps/cli/ingest_news_vietnambiz.py` (NEW — D4)
- `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` (MODIFIED — D5 REV-3 amendment)
- `agent-workspace/memory/sessions/2026-05-XX-session-357.md` (NEW — authored by S357 dev at end)
- `agent-workspace/memory/observations/sandwich-dev-S357-vietnambiz-adapter.md` (NEW — S357 dispatch observation file)
- `data/raw/news/vietnambiz/**` (NEW — CLI smoke writes raw HTML here)
- `data/tmp-vietnambiz-smoke.sqlite` (NEW — CLI smoke output; ephemeral)
- `tmp/vietnambiz_sample.html` (NEW — STEP 0.4 sample HTML; ephemeral; gitignored)

**Coordination-paths-exclusive disjointness (per plan-025 DD-4 lint contract)**:
- D1 set: {vietnambiz_adapter.py} — disjoint from D3 + D4 + D5
- D3 set: {test_vietnambiz_adapter.py} — disjoint from D4 + D5 (and D1)
- D4 set: {__init__.py, ingest_news_vietnambiz.py} — disjoint from D3 + D5 (and D1)
- D5 set: {066-bc5-crawler-adapter-contract.md} — disjoint from D3 + D4 (and D1)
- All 4 parallel sets are disjoint ✓ — lint passes; parallel-dispatch SAFE
- Max-3-parallel ceiling per Q-PL1: D3 + D4 + D5 = 3 ✓ at ceiling not over

**Main session MAY** continue work on (orthogonal):
- Any other `apps/cli/ingest_*.py` not `ingest_news_vietnambiz.py`
- Other ADRs in `agent-workspace/memory/decisions/` outside D-066
- `agent-workspace/research/`, `agent-workspace/master-plans/`, `agent-workspace/proposals/`, `agent-workspace/calibration/`, `agent-workspace/thesis-log/`
- `packages/_shared/path_safety.py` is READ-ONLY for S357 dev (W0-5 dependency)
- `apps/_shared/crawl/**` is READ-ONLY for S357 dev (plan-020 closed primitives; no modification per § B Out-of-scope)
- `packages/application/news/ports/**` is READ-ONLY for S357 dev (CrawlerAdapter ABC frozen per D-066)
- `packages/infrastructure/news/cafef_scraper.py` + `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` + `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` + `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py` are READ-ONLY for S357 dev (3 sibling adapters shipped; no modification per § Hard rules)
- Other `packages/` BCs outside news (BC-1/2/3/4/6/7/8/9 unaffected)
- `.claude/skills/crawler-reliability/SKILL.md` is READ-ONLY for S357 dev (skill update is § L L-S345-3 PROMOTE-NOW post-S358 verifier-confirm; main session writes it, NOT dev session)

**Commit boundary** (D-060 active): S357 dev MAY commit at IMPL close in a single coherent commit OR split per sub-track. Recommended message stems:

- Option A (single commit): `S357: Phase D Theme L FINAL — VietnamBiz adapter — Strategy A direct-subclass + SelectorChain[T] 3rd consumer + DD-7 F2-aware day-1 + DD-5 3.0s rate + CLI + D-066 REV-3`
- Option B (3 commits — if parallel D3+D4+D5 dispatch + each child commits):
  - `S357: D1 — VietnamBizAdapter implementation (Strategy A direct-subclass; SelectorChain[T] 3rd consumer; DD-7 F2-aware day-1; DD-5 3.0s rate-limit)`
  - `S357: D3+D4 — VietnamBiz tests + CLI + registry wire (3.0s rate-limit verified via test 21)`
  - `S357: D5 — ADR D-066 REV-3 amendment (VietnamBiz = 3rd + FINAL consumer; Phase D Theme L CLOSED)`

Do NOT push.

---

## K. Budget recommendation

**Budget**: ~100-150K Opus FOCUSED_IMPL (Phase 1b CALIBRATED from n=2 baseline — NDH S344 + Vietstock S354).

**Breakdown estimate** (Phase 1b n=2 calibrated; see § Calibration summary for derivation):
- STEP 0 verification (Sub-steps 0.1-0.10): ~15-20K (live URL probes + robots.txt parse + ToS read + sample HTML structure analysis + 6-primitive import check + baseline regression run; +1-2 min wall vs Vietstock due to plan-020 § E line 354 URL typo correction)
- D1 VietnamBizAdapter implementation: ~25-35K (~250-350 LOC adapter; mirror Vietstock `vietstock_adapter.py` shape with DD-7 F2-aware day-1; 2× SelectorChain instances; n=2 confidence reduces exploration overhead)
- D2 HTML parser internals (selector authoring): ~10-15K (replacing 4-5 placeholder selectors with verified ones per STEP 0.4) — merged operationally into D1
- D3 Unit tests: ~25-35K (~300-450 LOC tests; ≥12 cases including mandatory tests 7 + 19 + 21 for DD-5; synthetic fixtures inline)
- D4 Registry wire + CLI: ~15-25K (~300 LOC CLI mirror of `ingest_news_vietstock.py`; init export update; **+~3 min wall for 3.0s CLI smoke vs Vietstock 2.0s**)
- D5 ADR REV-3 amendment: ~5-10K (REV-3 entry; ~60 LOC; +Phase-D-close attestation paragraph)
- Session log + observation file: ~10-15K
- Reserve for STEP 0 findings adjusting scope: ~15-20% = 15-30K

**Total**: ~120-180K, fitting within FOCUSED_IMPL 100-150K envelope IF STEP 0 finds no JS-rendering / no robots-block (the expected happy path per plan-020 § E "Static HTML hypothesis"). If STEP 0 surfaces complications (RM3 SelectorChain gap → Path B D-067), may need MULTI_TASK_IMPL upgrade.

**Split recommendation**: Single FOCUSED_IMPL session is preferred. Architect verdict: do NOT split as PLAN+IMPL pair — architectural decisions are already made in this plan (DD-1 through DD-10); dev executes against the recipe. **L-S345-3 PROMOTE-NOW skill update is deferred to main session post-S358** (NOT S357 dev session) — cleanly separates product-tier IMPL from skill-tier amendment.

**Parallel-dispatch projection** (Phase 1b n=2 calibrated):
- Sequential baseline (Vietstock actual): ~36 min wall (full dev cycle per S355 verifier)
- Parallel-dispatch projected (D3+D4+D5 post-D1): D1 (~13 min) + parallel(D3=8, D4=9, D5=4) → max=9 min → total ~22 min wall = ~39% reduction
- **This is the SECOND PRODUCT-tier plan with parallel-dispatch declaration** — observation captures actual wall-time at S358 verifier close; calibration corpus expands to n=2 parallel-declaration baseline
- L-S354-2 HARNESS GAP carry-forward: planner-feedback-loop.sh should auto-populate `.planner-stats.tsv` from S357 dispatch metrics post-IMPL; if it still doesn't, the gap promotes to 2nd-instance HOLD = next harness-stabilization sweep priority

---

## L. ADR D-066 amendment plan (REV-3) + L-S345-3 PROMOTE-NOW skill update path

**Plan-027 explicitly extends D-066 § Amendments with REV-3 documenting VietnamBiz = 3rd + FINAL consumer + Phase D Theme L closure.**

At S357 completion, D-066 § Amendments gains REV-3 entry (architect-drafted in § D5 above; dev verifies + lands at S357 close as part of D5 sub-track).

The REV-3 entry SUSTAINS NDH-REV-1 + Vietstock-REV-2 (does NOT supersede) — REV-3 is additive contract-maturity attestation + Phase D Theme L closure milestone, not contract change. The CrawlerAdapter ABC + SelectorChain[T] contracts remain UNCHANGED.

### L-S345-3 PROMOTE-NOW SKILL UPDATE PATH (CONDITIONAL — fires at S358 verifier-confirm)

**Trigger condition**: At S358 verifier close, IF ALL SIX DD-7 F2-aware quintuple-guard items GREEN (DC-IMPL-7 + DC-IMPL-8 + DC-IMPL-9 + Test 7 + Test 19 + DC-SMOKE-4) for VietnamBiz adapter, THEN:

- **n=3 store_raw presence** (NDH retrofit + Vietstock day-1 + VietnamBiz day-1)
- **n=2 day-one ship** (Vietstock 1st + VietnamBiz 2nd)
- **n=3 quintuple-guard validation** (Vietstock confirmed S355; VietnamBiz pending S358)
- **AP-23 promote-or-retire calculus**: 3-instance threshold for confident promotion to SKILL-tier mandate (per S355 verifier "VietnamBiz at S356 = pivotal moment for L-S345-3 PROMOTE-NOW decision")

**Skill update spec** (main session writes at S358 close; NOT S357 dev):

File: `.claude/skills/crawler-reliability/SKILL.md`

Append a new section (or extend existing § Anti-Patterns / § Storage section):

```markdown
## Adapter Storage Discipline — discover-bypass-via-store_raw

**MANDATORY for Strategy A direct-subclass CrawlerAdapter implementations** (n=3 precedent: NDH-retrofit at S345 + Vietstock-day-one at S354 + VietnamBiz-day-one at S357):

Helper signature contract:
```python
def _fetch_with_optional_chain(self, url: str, *, store_raw: bool = True) -> str:
    ...
    if store_raw:  # discover() passes False; fetch_and_parse() uses default True
        rhs = self.raw_html_sink
        if rhs is not None and hasattr(rhs, "write"):
            rhs.write(...)
    return html
```

`discover()` MUST pass `store_raw=False` to avoid listing-page HTML contamination of `data/raw/news/<source>/`. `fetch_and_parse()` uses default `store_raw=True` to persist article HTML for reprocessing.

**Quintuple-guard verification** (verifier MUST check):
1. Method signature has `*, store_raw: bool = True`
2. `discover()` body contains `store_raw=False` literal
3. Helper body contains `if store_raw:` sink-write guard
4. Test asserting `sink.write` NOT called during `discover()`
5. Test asserting `sink.write` called during `fetch_and_parse()`
6. Empirical CLI smoke: `find data/raw/news/<source> -type f` shows only ARTICLE hashes (zero listing-page hashes)

**Why**: Listing-page raw HTML is not the unit of reprocessing — persisting it pollutes the article-data tier of the data lake. F2 IMPORTANT defect history: NDH-S344 shipped without this discipline; S345 verifier caught contamination; retrofit fixed it. Vietstock-S354 + VietnamBiz-S357 shipped day-one with the discipline (n=2 day-one ship; AP-23 ratification).

**Authority**: ADR D-066 § Amendments REV-1 + REV-2 + REV-3 (NDH + Vietstock + VietnamBiz consumers); plan-022 + plan-026 + plan-027 DD-7.
```

**Promotion deferral rationale**: If even ONE of the 6 quintuple-guard items FAILS at S358 verify, promotion is DEFERRED to next adapter ship (likely a CafeFAdapter Strategy B → Strategy A consolidation in Phase D-N) — n=3 precedent doesn't hold with a regression at the 3rd instance. Karpathy P1 + Charter Principle 8 binding.

**Side-effect promotion candidate L-S354-1** (Protocol-typed injection refactor): NOT promoted by this plan. Vietstock S355 verifier noted L-S354-1 1st-instance HOLD ("19 cumulative unused type:ignore across 3 BC-5 adapters"). VietnamBiz adds ~4-5 more unused type:ignore (n=4 adapters; ~23-24 cumulative). Architect verdict: defer Protocol-typed refactor to dedicated harness-cross-cutting session (separate Phase D-N consolidation plan); do NOT mix product ship + cross-adapter refactor (RM4 catastrophic-mix-pattern).

**Side-effect harness gap carry-forward L-S354-2** (planner-feedback-loop.sh): NOT remediated by this plan. Belongs to next harness-stabilization sweep priority. If `.planner-stats.tsv` still header-only after S357 dispatch (architect prediction: yes, it will be — hook gap independent of product session), L-S354-2 promotes to 2nd-instance HOLD = mandatory next-harness-session inclusion.

---

## END OF PLAN

**Plan summary**:
- Pre-flight: STEP 0 has 10 sub-steps; BLOCKING (live URL verification + robots.txt + ToS + sample HTML analysis + primitive imports + baseline regression + CafeF/NDH/Vietstock zero-regression)
- Architecture decisions: DD-1 through DD-10 (10 decisions made + pre-answered)
- Sub-tracks: D1 (adapter; serial root), D2 (parser internals; merged into D1), D3 (tests ≥12; parallel with D4+D5), D4 (registry + CLI; parallel with D3+D5), D5 (ADR REV-3; parallel with D3+D4)
- **Per plan-025**: every sub-track declares `parallel_with` + `blocks_on` + `coordination_paths_exclusive` + `estimated_wall_min`; lint-validates disjoint paths + max-3-parallel ceiling + cycle-free DAG (n=2 dogfood of plan-025 contract)
- DoD: 36 items across DC-FILE/LOC/IMPL/COMPLIANCE/GATE/SMOKE/BOOK categories (incl. DD-7 F2-aware sextuple-guard DC-IMPL-7/8/9 + DC-FILE-9 + DC-SMOKE-4 + tests 7 + 19, plus DD-5 rate-limit test 21)
- Architecture questions: AQ-1 through AQ-10 (10 questions pre-answered)
- 5-source-evidence chain: 5 rows (Strategy A subclass + SelectorChain[T] 3rd consumer + DD-7 F2-aware day-1 + RateLimiter 3.0s CONSERVATIVE + RobotsTxtManager)
- Risk-Mitigation: RM1 through **RM11** (11 risks tracked with mitigations; **RM11 = sextuple-guard regression defense AND L-S345-3 PROMOTE-NOW validation point**)
- Coordination: 10 paths main session AVOIDS during S357 IMPL; disjointness validated for parallel-dispatch
- Budget: 100-150K Opus FOCUSED_IMPL (Phase 1b CALIBRATED from n=2 baseline NDH S344 + Vietstock S354)
- ADR amendment: D-066 REV-3 (VietnamBiz = 3rd + FINAL consumer; Phase D Theme L per-source rollout CLOSED)
- L-S345-3 PROMOTE-NOW: CONDITIONAL skill update path documented in § L; fires at S358 verifier-confirm of all 6 quintuple-guard items GREEN
- Parallel projection: ~39% wall-time reduction vs sequential (D3+D4+D5 parallel post-D1; n=2 calibrated estimate)
- **DOGFOOD CONTEXT**: Second architect plan post-plan-025 IMPL; second to CONSUME Phase 1b self-calibration (n=2 baseline); second to DECLARE `parallel_with` fields per sub-track per DD-3 contract
- **PHASE D THEME L CLOSURE**: This is the FINAL Phase D Theme L adapter. Post-S358 verifier acceptance → Phase E Theme I Vietnamese NLP entry plan-028 (S359 or later) unblocked. Master plan § 5.7 + § 6.4.1 closure milestone.
