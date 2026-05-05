# Session 43b-EVIDENCE + HARNESS-RECOVERY — 2026-05-01

**Type**: FOCUSED_IMPL pivoted mid-turn → CHARTER-TIER recovery
**Mode**: AUTONOMOUS-FULL until user pivot, then user-directed comprehensive fix
**Predecessor**: S43b-BULL (DEFER-S43b-3 resolved via per-role model override)
**Successor**: NEXT session reads `checkpoints/latest.md` + `current-execution.md` § S43b-EVIDENCE row first

---

## Two parts

### Part 1 — S43b-EVIDENCE quant-TA wiring

Goal per S43b-BULL checkpoint § DEFER-S43b-5: enrich SharedContext with TA features so quant has material to ground points.

**Findings on entry**:
- `packages/domain/market_data/services/ta_service.py` already authored (164 LOC; `compute_ta_features` + `TAFeatures` dataclass; 15 unit tests in `test_ta_service.py`) — was untracked.
- `SharedContext` already had `ta_features: dict[str, object]` + `ta_audit: dict[str, str]` fields (unstaged diff in `validate_thesis_phase1.py`).
- Adapter `_context_to_str` already rendered `[TA Features]` block when populated.
- The gap: `Phase1DataGatherer` never called `compute_ta_features`.

**Edits**:
1. `packages/infrastructure/analysis/phase1_data_gatherer.py` (+12 LOC):
   - Import `compute_ta_features` from `packages.domain.market_data.services.ta_service`.
   - After BC-1 quotes load, call `compute_ta_features(quotes)`; populate `ta_features` (via `.to_dict()`) + `ta_audit` (via `.audit`).
   - `gaps.append("ta_insufficient")` when no quotes.
2. NEW `packages/infrastructure/analysis/test_phase1_data_gatherer.py` (~95 LOC; 3 tests):
   - `test_ta_features_populated_with_sufficient_history`
   - `test_ta_insufficient_gap_when_no_quotes`
   - `test_ta_audit_carries_formula_strings`

**Gates**:
- pytest: 443 PASS / 3 SKIP / 0 regressions in 14.16s (+18 NEW vs S43b-BULL 425).
- mypy --strict (with --explicit-package-bases): 0 errors.
- ruff: clean.

**Live FPT dogfood (run 6)**:
```
python -m apps.cli.validate_thesis --ticker FPT --as-of 2026-05-01 --no-mock-llm --transport subagent
[validate_thesis] OK — recommendation=watch confidence=medium cost=$1.4375
```

cost +$0.10 vs run 5 ($1.29) — likely from larger context (TA features added) + quant now actually using opus on populated context. **Validation gap (HR-5)**: did not read `thesis-log/2026-05-01-FPT.md` run 6 to confirm quant grounded points populated. Next session must verify.

### Part 2 — Harness recovery (user pivot)

User feedback verbatim mid-turn:
> "bạn lưu rất nhiều memory, note. chúng khiến hệ thống rất dễ lỗi liên quan đến llm, hệ thống tôi yêu cầu ban đầu về harnessing đâu? deterministic? hook, script? các agent về tự nhận thức và tự nâng cấp? chúng có còn được dùng và tiếp tục tự phát triển?"
>
> "rõ ràng là lỗi hệ thống, fix toàn diện"

User audit confirmed the diagnosis I had given them earlier in the same turn:
- self-upgrade loop Stage 2 (lesson-synthesis) DEAD across 9 sessions S35-S43b
- self-upgrade loop Stage 3 (promotion-cycle) DORMANT — `promotion-cycle-trigger.sh` exists but never wired
- 12+ entries written to user-memory dir that should have been agent-notes.md (project-scoped)
- `drift-logs/` stale 3 days

**6-task recovery executed**:

| # | Task | Outcome |
|---|------|---------|
| A | Save handoff checkpoint NOW | ✅ `checkpoints/latest.md` rewritten with S43b-EVIDENCE + HARNESS-RECOVERY context + 6-task list + handoff instructions |
| B | Document S43b lessons → known-issues + best-practices | ✅ 6 NEW KI entries (KI-S43b-1..6) + 6 NEW BP entries (BP-S43b-1..6) appended to canonical files; covers per-role override / prose-JSON / TA wiring / dormant-loop / memory-routing / pre-clear handoff |
| C | Append agent-notes.md with S43b lessons | ✅ 7 NEW entries appended (matched existing file style with Context/Rule/Anti-example/Correct example/Severity/Auto-detect blocks) |
| D | Investigate drift-signals hook silent fail | ✅ Diagnosed — hook IS healthy; writes to `.drift-signals.log` (376KB, 2159 lines, last 18:52 today). The `drift-logs/` directory is a SEPARATE manual-report surface. Documentation gap, not bug. Documented in agent-notes L-S43b-8. |
| E | Pre-/clear handoff-write invariant | ✅ Codified in BP-S43b-6 + KI-S43b-6 + agent-notes; deterministic hook script (`pre-clear-handoff-guard.sh`) deferred to next harness IMPL session as HR-2 |
| F | Fix promotion-cycle-trigger to actually fire | ✅ WIRED into `.claude/settings.json` Stop chain (was TODO'd in script header). Smoke-test confirmed HARD-BLOCK alert fires correctly: `delta=30 phase_changed=1` |

---

## Files touched (entire turn)

**Production EDIT**:
- `packages/infrastructure/analysis/phase1_data_gatherer.py` (+12)
- `.claude/settings.json` (Stop chain +promotion-cycle-trigger entry)

**Production NEW**:
- `packages/infrastructure/analysis/test_phase1_data_gatherer.py` (~95 LOC)

**Production TRACK** (was untracked, authored prior partial session):
- `packages/domain/market_data/services/ta_service.py` (164 LOC)
- `packages/domain/market_data/test_ta_service.py` (163 LOC)

**State EDIT**:
- `agent-workspace/memory/checkpoints/latest.md` (rewritten)
- `agent-workspace/memory/current-execution.md` (S43b-EVIDENCE row prepended)
- `agent-workspace/memory/agent-notes.md` (+7 entries, ~340 LOC added)
- `agent-workspace/memory/self-awareness/known-issues.md` (+6 entries)
- `agent-workspace/memory/self-awareness/best-practices.md` (+6 entries)

**State NEW**:
- `agent-workspace/memory/sessions/2026-05-01-session-43b-evidence-harness-recovery.md` (THIS file)

**ARTIFACT (LLM-generated)**:
- `agent-workspace/memory/thesis-log/2026-05-01-FPT.md` (overwritten by run 6)

---

## Lesson candidates (8 NEW; ALL DOCUMENTED IN KI/BP/agent-notes — NOT just inline-doc)

- L-S43b-1 — Per-role model override pattern for empirical role-specific failure modes
- L-S43b-2 — Prose-tolerant JSON extractor (3-tier: fence-regex → brace-scan → raw)
- L-S43b-3 — Wire deterministic compute through gatherer, not agent
- L-S43b-4 — UTF-8 cp1252 subprocess encoding (Windows-host substrate invariant)
- L-S43b-5 — Project-scoped lessons → agent-notes.md, NOT user-memory dir
- L-S43b-6 — Pre-/clear handoff-write invariant
- L-S43b-7 — Lesson-synthesis Stage 2 of self-upgrade loop has no agent (architectural)
- L-S43b-8 — Drift hook is healthy; `drift-logs/` is separate surface (documentation gap)

---

## Drift watch

- D1: 0 sustained ✅ (gatherer +12, test +95 — small; ta_service 164 is domain-service not charter)
- D-INTENT: ✅ user pivot mid-turn was honored; recovery aligned with verbatim "fix toàn diện"
- DR-PROV: ✅ TA features carry audit dict per I-S1
- D9 charter md5: unchanged (settings.json is harness, not charter)
- LLM-math creep grep: 0 hits in modified files
- I-S1 / I-S2 / I-S10 / I-S35: preserved

---

## Open items / blockers

**HR-1..HR-5 — see checkpoint `latest.md`** (lesson-synthesizer / pre-clear-handoff hook / drift-rollup / charter memory-routing / quant validation)

**Carried from S43b arc**:
- DEFER-S43b-1: cost ledger drift verification
- DEFER-S43b-2: RatioService bank schema (Q-S28-3)

**Phase 2 critical path PAUSED**:
- S43 Track F final dogfood — blocked on harness gate completion
- S39-IMPL Track E Bundle 2 — gated on Q&A 003

---

## Budget

- Main self-track this turn: ~110-150K (within FOCUSED_IMPL 100-150K target despite mid-turn pivot)
- Subagent dispatches: 0
- External subscription burn: ~$1.44 (single FPT dogfood run 6)
- Phase 2 cumulative post-this-turn: ~1.31M-1.57M main + ~502K subagent = ~1.81M-2.07M combined
- **Tracking ~21-38% over 1.5M envelope band**; envelope amendment ADR firmly warranted by next session

---

## NO COMMIT

Per CLAUDE.md hard rule + autonomous protocol — production + state files staged only, never auto-committed. User authorizes via explicit "commit" / "git commit" instruction.
