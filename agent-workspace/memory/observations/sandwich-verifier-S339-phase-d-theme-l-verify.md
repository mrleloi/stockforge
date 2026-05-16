---
observation_id: sandwich-verifier-S339-phase-d-theme-l-verify
session: S339
agent: sandwich-verifier
date: 2026-05-16
type: verifier-return-persistence
agent_id: a089e34b4bd828da6
related_plan: agent-workspace/session-plans/pending/020-S337-phase-d-theme-l-crawling-adapter.md
related_dev_session: agent-workspace/memory/sessions/2026-05-16-session-338.md
related_dev_commit: 74a0d4f
related_adr: agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md
persisted_by: main-session (verifier-has-no-Write recovery pattern per S312/S314/S321/S333 precedent)
total_tokens: 200773
duration_ms: 1112318
---

# S339 VERIFY — Adversarial Review (sandwich-verifier return)

**VERDICT**: PASS-WITH-CONCERNS
**MERGE-ELIGIBLE**: YES (after F1+F2 attribution fix; F3-F4 are non-blocking)

The dev's S338 IMPL is **substantively correct**: all 14 plan-listed file paths exist with
content matching DoD; 54/54 new tests + 968/968 full pytest suite pass empirically; all 3
named W0-substrate hooks (D-059 + D-062 + D-064) + html-separator + bash-hook-lint exit 0;
I-S34 banned-string grep returns 0; charter + constitution untouched in S338 only
(HEAD~1..HEAD = 0 lines diff); CLI smoke ends exit 0. The architectural shape is what the
plan called for. However there are 4 concrete defects (none blocking shipping but 2 worth
fixing inline before plan-020 mv to completed/) plus the mypy strict situation deserves
explicit documentation.

## V1 — DoD coverage (15 aggregate DCs)

All 15 DC-AGG-* PASS except: DC-AGG-5 CONCERN F4 (mypy strict regression — 12 new
unused-type-ignore + 1 attr-defined; pre-existing `_shared` dual-naming blocks
end-to-end mypy run); DC-AGG-10 CONCERN F1 (Karim attribution spelling drift between
NOTICE/D-066 and per-file header).

## V2 — Tests (re-run independently by verifier; verbatim outputs)

```
pytest packages/application/news/ports/test_crawler_adapter.py apps/_shared/crawl/ packages/infrastructure/news/crawler_adapters/ -q
→ 54 passed in 0.28s

pytest packages/ apps/ -q
→ 968 passed in 17.83s

pytest packages/infrastructure/news/test_adapters.py -q (pre-existing CafeFScraper tests)
→ 27 passed in 0.45s
```

Dev's 968/968 claim independently verified.

## V3 — Charter compliance hooks (re-run; verbatim exit codes)

| Hook | Exit |
|---|---|
| python-determinism-check.sh | 0 |
| atomic-write-check.sh | 0 |
| path-safety-check.sh | 0 |
| html-separator-check.sh | 0 |
| bash-hook-lint.sh | 0 |
| firing-tests/run-all.sh | 0 (107/107 PASS elapsed 358s) |

## V4 — I-S34 banned-string grep

```
grep -rEn "^(import|from).*\b(patchright|playwright_stealth|fake_useragent|UndetectedAdapter|StealthyFetcher|_cloudflare_solver)\b" **/*.py
→ No matches found

grep -rEn "patchright|playwright_stealth|..." packages/infrastructure/news/crawler_adapters
→ 2 matches (both in cafef_adapter.py:74-75 DOCSTRING negative-list — HARD-REJECT documentation references; acceptable)
```

PASS. No actual imports of banned tech anywhere in new modules.

## V5 — NOTICE attribution

- NOTICE file 35 LOC at repo root: Crawl4AI (NOTICE:5-21) + Scrapling (NOTICE:22-33) sections both present
- Apache-2.0 + custom Attribution Requirement clause from `crawl4ai/LICENSE:54-67` substantively reproduced
- "Karim shoair" (lowercase) at NOTICE:25,29 matches `C:/htdocs/research/Scrapling/LICENSE:3` verbatim
- Per-file header on rate_limiter.py: PASS
- Per-file header on robots_manager.py: **CONCERN F1** (capital "Shoair" — drifts from lowercase truth source)
- No header on selector_chain.py + raw_html_sink.py (pure-fresh; correct per DD-8 boundary)
- crawler_adapter.py includes Crawl4AI header (defensible; `__init_subclass__` typecheck is near-LOC adaptation)
- RM16 — no Parsel-derived code: PASS (grep returns no matches)

## V6 — CLI contract

- `python -m apps.cli.ingest_news_cafef --help` exit 0; 7 click flags + defaults + help text match plan AQ-6 expectation
- `python apps/cli/ingest_news_cafef.py --help` fails ModuleNotFoundError — pre-existing (no sys.path shim; canonical invocation is `python -m`). NOT a regression.
- Pre-existing `test_adapters.py` 27 tests PASS unchanged → byte-identical scraper-level behavior proven

## Plan AQ-1..AQ-10

10/10 PASS or PASS-with-MINOR-caveat:
- AQ-1 (I-S34 absence) PASS
- AQ-2 (license attribution) PASS
- AQ-3 (firing-tests + pytest) PASS (107/107 + 968/968)
- AQ-4 (4 W0-substrate hooks) PASS
- AQ-5 (robots.txt live smoke) NOT EXERCISED — network avoidance; fixture-based tests cover logic
- AQ-6 (CLI bytes-identical) PASS substantively; STEP 0.10 baseline missing (F4)
- AQ-7 (Rule 16 audit) PASS — 0 new LLM-numeric schema fields
- AQ-8 (per-file header DD-8) CONCERN F1
- AQ-9 (ADR D-066 ≥7 source_evidence) PASS (14 cites; ≥7 target met)
- AQ-10 (charter + constitution untouched) PASS (git diff HEAD~1..HEAD = 0 lines)

## 7 dev handoff items investigated

1. TYPE_CHECKING guard runtime behavior — PASS (frozenset abstract methods present at runtime; from __future__ annotations defers string evaluation)
2. Instance-scoped registry isolation — PASS (id(r1._adapters)!=id(r2._adapters); crawl4ai global-state anti-pattern correctly avoided)
3. Protego lazy import ImportError path — PASS (monkey-patched __import__ raises helpful error message)
4. safe_path workdir in RawHtmlSink — PASS (uses safe_path() with explicit workdir per D-064)
5. Strategy B coupling (RM12) — PASS but coupling is real (3 CafeFScraper public methods touched; RM12 carry-forward justified)
6. NOTICE verbatim "Karim shoair" lowercase — INVESTIGATED → F1 (per-file header drifted)
7. importlib pytest mode regression — PASS (968 passed; no regressions)

## Defects found

### F1 (IMPORTANT) — Per-file Karim attribution drift
- Evidence: `apps/_shared/crawl/robots_manager.py:2` uses "Karim Shoair" (capital S); NOTICE:25,29 + D-066:33 + `Scrapling/LICENSE:3` all use "Karim shoair" (lowercase)
- Severity: IMPORTANT (BSD-3-Clause § 1 verbatim retention)
- **REMEDIATED**: commit `9eaeed1` (main session inline fix per verifier mandate)

### F2 (IMPORTANT) — SelectorChain shipped without production consumer
- Evidence: `grep -rn "SelectorChain" apps/ packages/` returns only definition + tests + __init__ export; ZERO call sites in cafef_adapter.py OR cafef_scraper.py. DD-7 Strategy B (WRAP) preserved CafeFScraper untouched by design, so plan-020 § Sub-track D3 step 3 selector-refactor was skipped.
- Severity: IMPORTANT (plan deviation; gap requires open documentation per AP-7)
- **REMEDIATED**: commit `9eaeed1` (ADR D-066 § Out-of-scope item 12 appended)

### F3 (MINOR) — `object`-typed DI fields produce mypy unused-ignore noise
- Evidence: 12 unused-type-ignore + 1 attr-defined across cafef_adapter.py + rate_limiter.py + robots_manager.py
- Severity: MINOR (defensive `hasattr` works at runtime; pre-existing `_shared` dual-naming blocks end-to-end mypy)
- Recommended fix: replace `object = field(default=None)` with `<Type> | None = field(default=None)` + TYPE_CHECKING guard
- **CARRY-FORWARD** to next Theme D plan / next refactor session

### F4 (MINOR) — STEP 0.10 baseline `--help` not captured
- Evidence: dev session log shows STEP 0 inherited from compacted summary; AQ-6 baseline file not created
- Severity: MINOR (post-IMPL `--help` works; click signature inspection proves contract preservation)
- Recommended fix: future plans require STEP 0 evidence captures land in session log verbatim (L-S333-1 extension)
- **CARRY-FORWARD**

### F5 (MINOR) — Dev observation file not written
- Evidence: `agent-workspace/memory/observations/sandwich-dev-S338-*` does not exist; session log + ADR D-066 cover the same ground
- Severity: MINOR (duplicative for this dispatch shape; compacted-summary continuation likely lost dispatch-instruction expectation)
- Recommended fix: future dispatch templates make observation-file expectation explicit
- **CARRY-FORWARD**

## Promotion candidates (queued; AP-23 1st-instance HOLD)

- **L-S339-1**: license attribution string-matching discipline — both NOTICE and per-file headers must reference LICENSE byte-stream as source of truth, not plan template (which may carry typos). 1st instance; 2nd triggers promote-or-retire.
- **L-S339-2**: foundation-primitive consumption tracking — plan-shipped primitive replaced by alternate strategy (Strategy B over A) creates "shipped but un-consumed" gap; must be explicitly documented in ADR § Out-of-scope. 1st instance.
- **L-S339-3**: `object`-typed DI fields produce mypy noise — pattern recommendation = define small Protocol per injected dependency. 1st instance.

## Compliance attestation (verifier S339)

- AP-1 ✓ Fresh context; did NOT consult dev's session log claims as truth; every claim re-derived empirically
- VBW ✓ 28+ files Read with line citations (plan-020 full 1631 LOC, session-338, ADR D-066, all 14 commit files, LICENSE upstreams)
- D-060 ✓ 0 commits (verifier is read-only on code; only Read/Glob/Grep/Bash)
- AP-23 ✓ All 3 promotion candidates marked 1st-instance HOLD (not promoted by this verifier)
- L-S333-1 ✓ Every empirical count quoted verbatim from re-run (not from dev session log)
- Hard-rule honored: no destructive ops; no charter/constitution/human-workspace writes; no production code changes

## Recommendation

**MERGE-ELIGIBLE: YES.**

1. ~~Inline fix F1 (1-min)~~ → DONE commit `9eaeed1`
2. ~~Inline fix F2 documentation (5-min)~~ → DONE commit `9eaeed1`
3. Track F3 + F4 + F5 as carry-forward in next session log; consider RM-list for next Theme D plan
4. After 1+2 land (DONE): move plan-020 pending→completed; close Phase D Theme L first IMPL cycle (THIS COMMIT)
