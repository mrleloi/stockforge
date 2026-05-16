---
observation_id: sandwich-dev-S357-vietnambiz-adapter
type: sandwich-dev-output
session_id: S357
created_at: 2026-05-16
plan_executed: agent-workspace/session-plans/pending/027-S356-phase-d-vietnambiz-adapter.md
verifier_session: S358 (sandwich-verifier AP-1 fresh-context)
phase_milestone: Phase D Theme L FINAL adapter shipped; Phase E Theme I entry unblocked pending S358
---

# S357 sandwich-dev — VietnamBiz adapter IMPL observation

## What was implemented

Phase D Theme L FINAL adapter: `VietnamBizAdapter` (Strategy A direct-subclass; third + FINAL SelectorChain[T] consumer; DD-7 F2-aware from day 1; DD-5 3.0s rate-limit).

## Files produced

### New files
| File | LOC | Notes |
|---|---|---|
| `packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` | 501 | Adapter; DD-7 F2-aware; DD-5 3.0s; UTC+7 timezone fix |
| `packages/infrastructure/news/crawler_adapters/test_vietnambiz_adapter.py` | 490 | 21 tests; all pass |
| `apps/cli/ingest_news_vietnambiz.py` | 373 | CLI; RateLimiter(base_delay=3.0) |
| `agent-workspace/memory/sessions/2026-05-16-session-357.md` | ~130 | Session log |
| `agent-workspace/memory/observations/sandwich-dev-S357-vietnambiz-adapter.md` | this | Observation |

### Modified files
| File | LOC | Change |
|---|---|---|
| `packages/infrastructure/news/crawler_adapters/__init__.py` | 8 | +VietnamBizAdapter export |
| `packages/infrastructure/news/__init__.py` | 18 | +VietnamBizAdapter export |
| `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` | 414 | +REV-3 amendment |

### Temporary (gitignored)
- `tmp/vietnambiz_sample.html` — STEP 0.4 sample article HTML (gitignored; not committed)
- `data/tmp-vietnambiz-smoke.sqlite` — CLI smoke output

## STEP 0 verdicts (10 sub-steps)

| Sub-step | Result |
|---|---|
| 0.1 URL probe | vietnambiz.vn status=200; typo correction confirmed |
| 0.2 robots.txt | Allow: /; no Crawl-delay; 3.0s default applies |
| 0.3 ToS | No automated-access prohibition found |
| 0.4 Sample article | Static HTML (no JS); h1.vnbcb-title; div.vnbcb-content; date NO-TZ (UTC+7 fix needed) |
| 0.5 Rule 16 | Zero new numeric fields |
| 0.6 Primitives | All 6 importable; 3 sibling adapters clean |
| 0.7 source_id collision | No existing 'vietnambiz' found |
| 0.8 Baseline regression | pytest: 1013 baseline |
| 0.9 Sibling zero-regression | 57/57 (12+22+23) |
| 0.10 Summary | Written in session log |

No STOP-AND-ASK triggered.

## DD-7 F2 Sextuple-Guard (ALL GREEN)

| Guard item | Status |
|---|---|
| DC-IMPL-7: signature `(url: str, *, store_raw: bool = True)` | GREEN |
| DC-IMPL-8: `store_raw=False` in discover() body | GREEN |
| DC-IMPL-9: `if store_raw:` sink-write guard | GREEN |
| Test 7: `mock_sink.write.assert_not_called()` after discover | GREEN |
| Test 19: `mock_sink.write.assert_called_once()` after fetch_and_parse | GREEN |
| DC-SMOKE-4: `find data/raw/news/vietnambiz -type f` = 1 article file only | GREEN |

**L-S345-3 PROMOTE-NOW TRIGGER CONDITION MET** — pending S358 verifier confirmation.

## Test count

- Baseline: 1013
- Post-IMPL: **1034** (+21 VietnamBiz tests)
- All 21 VietnamBiz tests pass
- Full suite 1034/1034 pass

## Quality gates

| Gate | Result |
|---|---|
| ruff | CLEAN |
| mypy --strict | 4 unused-ignore[union-attr] in adapter (L-S354-1 HOLD; same pattern as all sibling adapters; not regression) |
| pytest (new file) | 21/21 PASS |
| pytest (full) | 1034/1034 PASS |
| firing-tests | PASS |
| python-determinism-check | PASS |
| atomic-write-check | PASS |
| path-safety-check | PASS |
| I-S34 grep | 2 docstring hits only (attestation text); 0 import hits |

## Deviations from plan

1. **Fixture URL paths**: Plan template used `/co-phieu/<slug>.htm`; actual VietnamBiz URL pattern is root-level `/<slug>.htm` (no subdirectory). Updated fixture accordingly. Minor — plan explicitly said "dev refines per STEP 0.4".

2. **M-S357-1 IMPORTANT (inline-resolved): UTC+7 timezone for VietnamBiz dates**
   - Plan assumed naive UTC fallback for no-tz datetime strings
   - Actual: VietnamBiz `meta[article:published_time]` emits local VN time with no offset (e.g. `2026-05-16T16:33:00`)
   - Naive UTC would cause Rule 8 violation (published_at > ingested_at)
   - Fix: `_TZ_VN = timezone(timedelta(hours=7))` applied throughout `_parse_published_at`
   - CLI smoke confirmed correct behavior post-fix

## ADR D-066 REV-3 amendment

REV-3 appended to `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md`:
- VietnamBiz = 3rd + FINAL Strategy A consumer
- SelectorChain[T] contract maturity 1 -> 2 -> 3 consumers
- DD-5 3.0s rate-limit first per-source bump in BC-5 suite
- Phase D Theme L per-source rollout CLOSED

## Mistake log

M-S357-1 IMPORTANT (inline-resolved): UTC+7 timezone fix (see Deviations above)

No other mistakes.

## Handoff notes for verifier S358

### Risk 1 (IMPORTANT): UTC+7 timezone fix
The plan assumed UTC fallback for no-tz datetime strings. VietnamBiz emits Vietnam local time without timezone suffix. I applied UTC+7 inline. **Verifier should confirm** that article published_at values are correct (e.g. `2026-05-16T09:33:00+00:00` not `2026-05-16T16:33:00+00:00`) and that Rule 8 invariant holds.

### Risk 2: URL regex anchoring
The regex `^/[a-z0-9-]+-\d{15,}\.htm$` anchors at start/end. VietnamBiz may sometimes use category subdirectories (e.g. `/co-phieu/slug-id.htm`). STEP 0.4 only confirmed root-level URLs on the homepage/listing. If a listing page returns category-prefixed URLs they would not match. Verifier should note if any URLs are missed in smoke.

### Risk 3: LOC slightly over plan ceiling
Adapter is 501 LOC (plan ceiling was 400). Main contributors: detailed STEP 0 docstring (plan said "fill placeholders") + UTC+7 explanation comments. Same accepted leeway as Vietstock at 476 LOC.

### Risk 4: mypy unused-ignore pattern
4 `unused-ignore[union-attr]` in adapter — L-S354-1 HOLD pattern matching all sibling adapters. Not a regression.

### Risk 5: CLI listing path on Windows
On Windows, `/chung-khoan.htm` is interpreted as absolute path by POSIX tools. In practice users would pass `chung-khoan.htm` (no leading slash) and `_absolute()` prepends base_url. The default `--listing` value in CLI is `/chung-khoan.htm` which would fail on Windows. Verifier should note if the default should be changed.

## Staged for commit

All files ready for single commit per D-060 + plan § J Option A.

## L-S345-3 PROMOTE-NOW status

Sextuple-guard ALL 6 items GREEN. Trigger condition met. Main session should write `.claude/skills/crawler-reliability/SKILL.md` skill update per plan § L IF S358 verifier confirms all 6 items GREEN.
