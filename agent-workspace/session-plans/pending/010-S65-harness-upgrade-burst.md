---
plan_id: 010-S65-harness-upgrade-burst
phase: 3
parent_plan: agent-workspace/memory/routing-config.md
sessions_covered: S65 autonomous burst (in-session)
ratifying_session: S65
status: COMPLETE
completed_at: 2026-05-06 (S65 close)
deliverables_shipped: 7/7 (D1-D7)
firing_tests_pass: 52/52
bc6_regression: 150/150 PASS UNCHANGED
bash_hook_lint: clean (no NEW violations)
priority: P0 — harness upgrade > product work (user directive 2026-05-06)
---

# Plan 010 — Harness Upgrade Burst

> Autonomous burst per user directive: "harness upgrade luôn là ưu tiên số một, quan trọng hơn cả dự án".
> Triggered by S65 cost-tracking audit revealing 7 harness gaps.
> DoD: all hooks shipped + firing-tests PASS + bash-hook-lint clean + 150/150 pytest preserved + memory close.

## Scope

7 harness deliverables priority-ordered. Implement → firing-test → bash-hook-lint → integration smoke → memory close → resume S65 BC-7 wrap.

## Deliverables (priority order — implement in this sequence)

### D1 — Pre-dispatch ADR-number availability check (M-S65-1 prevention)
**Why**: Architect created `028-S51-...` colliding with existing `028-S48d-...`; renumbered manually 028→032 cost ~10K main tokens fix-cycle.
**Hook**: `scripts/hooks/pre-dispatch-adr-number-check.sh` (PreToolUse on Agent calls)
**Logic**: When prompt mentions "D-NNN" or "ADR" + new file path `agent-workspace/memory/decisions/NNN-*`, scan existing `decisions/` for highest NNN+1; if proposed number collides → emit JSON block with corrected number suggestion.
**LOC budget**: ≤80 LOC + ≤6 TC firing-test
**Saving**: 1-time M-S65-1-class collision prevented (~5-15K/recurrence × N)

### D2 — Cost ledger telemetry foundation
**Why**: User question "cho tôi con số budget đã track" — answered with estimates only. Foundation for all future cost decisions.
**Files**:
- `scripts/hooks/cost-ledger-recorder.sh` (PostToolUse + SubagentStop hooks)
- `agent-workspace/memory/cost-ledger.tsv` (append-only TSV; columns: timestamp / session_id / actor[main|sub] / model / tool / input_tokens / output_tokens / cost_usd_estimated)
- Pricing table embedded in script: opus 15/75, sonnet 3/15, haiku 0.80/4
**Logic**: Read tool-result token deltas (claude-code provides via env vars); compute USD; append row.
**LOC budget**: ≤180 LOC + ≤8 TC firing-test
**Saving**: Foundation; enables Action #7 + monthly cost reports.

### D3 — Reboot summary pre-compute (BIGGEST saving)
**Why**: Reboot bootstrap reads ~$15-50/phase (estimated). Pre-computing a compact summary cuts to ~$2-5/phase.
**Files**:
- `scripts/hooks/bootstrap-summary-renderer.sh` (Stop hook; renders `boot-summary.md`)
- `agent-workspace/memory/boot-summary.md` (append/replace; ≤2K target = ~10× cheaper than reading 8 files)
- `scripts/hooks/session-start-bootstrap.sh` enhancement: prefer `boot-summary.md` if mtime < 1h, else fall back to existing reads
**Logic** (renderer): extract last 5 ratified ADRs + active phase/track from current-execution top row + 3 most recent M-S<N>-<M> + in-flight subagent dispatch + 1-line context.
**LOC budget**: ≤140 LOC renderer + ≤30 LOC bootstrap-enhance + ≤8 TC firing-test
**Saving**: ~$15-45/phase reboot cost reduction

### D4 — Effort-escalation detector
**Why**: User directive: tận dụng full effort ladder (low→max). Need deterministic signal-detection để main session auto-bump effort.
**Files**:
- `scripts/hooks/effort-escalation-detector.sh` (UserPromptSubmit + PreToolUse on Agent)
- Output: stderr `effort_recommendation: <level>` + reason + JSON suggested config
**Logic**:
- low → medium: default for any decision
- medium → high: regex match on prompt ("ambiguous|unclear|stuck|debug|cross-BC|spec gap"); >2 alternatives in current turn
- high → xhigh: novel pattern detected (no mirror precedent grep); cross-system reasoning
- xhigh → max: multi-perspective adversarial > 3 viewpoints; recurring M-S<N>-<M>
**LOC budget**: ≤120 LOC + ≤8 TC firing-test
**Saving**: Quality improvement (escalation when truly needed) + cost discipline (don't max default)

### D5 — Scheduled drift-detector via CronCreate
**Why**: Drift currently caught at session/phase boundary; mid-session drift compounds.
**Action**: CronCreate routine `drift-detector` every 6h; fresh-context Opus dispatch.
**Output**: `agent-workspace/memory/drift-logs/scheduled-YYYY-MM-DD-HH.md`
**LOC**: 0 hook (uses existing scripts/hooks/drift-signals-D1-D9.sh + drift-detector subagent)
**Saving**: Quality improvement (mid-phase drift catches earlier)

### D6 — Memory ETL background queue
**Why**: Heavy memory consolidation (lesson-synthesizer, profile-card render) blocks main turn.
**Files**:
- `agent-workspace/memory/etl-queue/` directory (job files)
- `scripts/hooks/memory-etl-processor.sh` (Stop hook; processes queue in background)
- Job format: `<timestamp>-<task>.job` with YAML payload
**Logic**: Stop hook scans queue/ for unprocessed jobs; runs processor on each (background mode); marks done.
**LOC budget**: ≤200 LOC + ≤8 TC firing-test
**Saving**: ~$5-15/phase + UX (don't block turns)

### D7 — Profile cards mark BIASED-PRE-REBUILD + rebuild trigger
**Why**: User correctly flagged tracking gap → existing cards biased; need honest rebuild plan.
**Action**:
- Edit 6 profile cards: status field → `BIASED-PRE-REBUILD-S65`
- Document rebuild trigger in `routing-config.md § 6`: "Rebuild after 10+ sessions with cost-ledger active"
- Actual rebuild defer to S75+ (post-cost-ledger-data-accumulation)
**LOC**: trivial (frontmatter edits)
**Saving**: Foundation; honest tracking enables N+ future routing decisions

## Verification (DoD)

Per deliverable:
- [ ] Hook script written + bash-syntax-check (`bash -n`)
- [ ] Companion firing-test (≥6 TC) ≥1 positive + ≥3 negative cases
- [ ] firing-test 100% PASS first iteration OR fix-cycle within same session per L-S52-3
- [ ] bash-hook-lint clean (no NEW violations vs baseline 11)

Integration:
- [ ] Production smoke: full hook chain fires on synthetic test session
- [ ] Tier 1 gate: pytest 150/150 (no regression to BC-6 suite)
- [ ] mypy --strict + ruff: unchanged

Memory close (after burst):
- [ ] `routing-config.md` updated: `harness_burst_complete: 2026-05-06 § D1..D7`
- [ ] M-S65-1 cataloged in mistake-log with full multi-layer root cause
- [ ] L-S65-1 codified in agent-notes (deterministic ADR-number-check rule)
- [ ] L-S65-2 codified: harness-priority-one rule (cross-ref user memory)
- [ ] current-execution.md prepend S65 row noting harness burst + BC-7 PLAN both shipped
- [ ] session log 2026-05-06-session-65.md written
- [ ] S66 checkpoint with in_flight: empty + harness_burst_complete: true

## Rollback paths

- D1 firing-test fails → defer codification, document M-S65-1 in mistake-log only
- D2 cost-ledger compute breaks → fall back to estimates; ledger captures partial data
- D3 reboot summary stale → bootstrap falls back to existing read chain (env var `BOOT_SUMMARY_DISABLE=1`)
- D4 false-positive escalation → kill-switch `EFFORT_DETECTOR_DISABLE=1`
- D5 cron stalls → CronDelete + manual schedule
- D6 background queue corrupts → ETL queue reset (clear queue/, processor halt)
- D7 N/A (frontmatter edit only)

## Provenance

- User directive 2026-05-06 (S65 turn): "harness upgrade luôn là ưu tiên số một"
- S65 cost-tracking audit (chat) — 7 gaps identified
- M-S65-1 collision-fix S65 turn (D-028 vs D-032 renumber)
- routing-config.md § 4 effort auto-escalation (proposed → now codify D4)
- L-S43f-2 lean brief mandate (subagent stream-window) — applied to D5 cron + D6 queue
- L-S51-1 every new hook ships with companion firing-test — applied to D1+D2+D3+D4+D6
