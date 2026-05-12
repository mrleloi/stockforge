---
observation_id: harness-diagnostics-S235-post-cliff
type: harness-gap-catalog
created_at: 2026-05-10
parent_session: S235
severity: HIGH
status: pending-fresh-context-implementation
---

# Harness Gap Catalog — S235 Post-Cliff Diagnostics

User directive 2026-05-10: "gặp rất nhiều lỗi harness trong các phiên trước. nhất là sau khi end và 'continue'. kiểm tra và fix lại."

Parent at ~225K (cliff crossed) — actual fix-implementation must happen in fresh-context per Charter D-004 mandatory-split. This file enumerates root causes for next session's STOP-product harness fix.

## Gap 1 (CRITICAL) — HH-1 Stop hook not firing on Windows (M-S49b-1)

**Symptom**: `harness-health-self-scan` reports `state=RED-1 (high=1) HH-1-STOP-NOT-FIRING=HIGH(stop_count=0)` repeatedly.
**Impact**: All Stop-event hooks silent — no auto-reboot at cliff (Mode-D fails); no cost-ledger updates; no telemetry rollups; no auto-mv qa-pending; no drift-rollup-daily; no learning-index-rebuild. Cumulative harness state corrupts.
**Root cause**: Windows PowerShell hook runtime quirk (M-S49b-1 documented S49b). Investigation history in `agent-workspace/memory/decisions/` (search for D-039+ Windows hook investigations).
**Fix path**: `scripts/hooks/continue-injector-spawn.sh:77-84` MINGW branch already uses PowerShell `Start-Process -WindowStyle Hidden`. Possibly Stop event needs same pattern OR Claude Code Windows runtime drops Stop events entirely. Empirical investigation needed: probe Stop hook fire-rate via `.session-hooks.log` post-explicit-Stop event.
**Severity**: CRITICAL — blocks all autonomous-cliff-recovery; user must /clear manually.

## Gap 2 (HIGH) — Stale-prompt detector false positives

**Symptom**: At every UserPromptSubmit, hook re-fires warnings about CLOSED items the agent never proposed re-opening:
- "D-050 already in terminal status (ACCEPTED)" — when agent CITED D-050 for compliance reference, NOT re-deciding.
- "S3 has a session log (closed)" — fired on bare "continue" prompts that don't reference S3 at all.

**Impact**: Per-turn token tax (~200-500 tokens); cognitive noise; LLM-side false-action risk.
**Root cause**: `scripts/hooks/stale-prompt-detector.sh` detection logic likely uses substring match without context-aware "is the user PROPOSING change vs CITING reference" disambiguation. The "S3" misfire probably matches the literal substring `S3` in any prompt (e.g., session counter `S235` contains `S3`).
**Fix path**: Tighten detection to require action verbs ("redo D-NNN", "re-open S<N>", "amend") not just substring presence; OR add allow-list for citation contexts.
**Severity**: HIGH — recurring noise per-turn at autonomous cadence; multiplicative cost.

## Gap 3 (HIGH) — Endless-continue noise amplification

**Symptom**: Each bare "continue" prompt triggers ALL UserPromptSubmit hooks (invariants reminder + harness-health + stale-prompt + idle-escape + phase-coherence + correction-rate-tracker). When user keep-alive-pings 30+ times, ~30× hook fires × N hooks = 100s of context-noise injections.

**Impact**: Parent context bloats faster than substantive work warrants; cliff arrives prematurely.
**Root cause**: No "trivial-prompt" detection at UserPromptSubmit. `userprompt-invariants-injector.sh` has SKIP path for trivial detection (per S185+S186 D-043 work) but other hooks unconditionally fire.
**Fix path**: Add a shared "is-trivial-prompt" detection helper; gate harness-health-self-scan + stale-prompt-detector + idle-escape-detector to skip on trivial-continue prompts (preserve substantive prompt firing).
**Severity**: HIGH — root cause of accelerated cliff approach during keep-alive sessions.

## Gap 4 (MEDIUM) — Self-pause anti-pattern (M-S235-1, L-S235-1)

**Symptom**: Agent ends turn after writing checkpoint S<N>→S<N+1> instead of dispatching S<N+1> sandwich-dev — "harness handles boundary advance" misread.
**Impact**: Idle-loop at session boundaries; user-frustration ("sao lại stop run autonomous tiếp?").
**Status**: Memory rule LANDED S235; deterministic hook DEFERRED per AP-23 1st-instance.
**Fix path** (when 2nd instance observed): Stop-hook detect "ScheduleWakeup with `<<autonomous-loop-dynamic>>` sentinel + zero in-flight subagent + parent-tokens < wind_down + checkpoint just written this turn" → BLOCK + ALERT.
**Severity**: MEDIUM — single-instance caught + memory-rule-fixed; promote-to-hook on 2nd recurrence.

## Gap 5 (MEDIUM) — Continue-injector spawn doesn't account for cliff state

**Symptom**: `scripts/hooks/continue-injector-spawn.sh` spawns at SessionStart based only on `autonomous_mode=true`. Does not check parent-token state.
**Impact**: When user `/clear`s post-cliff to free context, injector immediately fires "continue" — re-launching autonomous loop in fresh context. That's CORRECT for normal flow. But if user wants quiet session (e.g., manual debug post-cliff), they must override `STOCKFORGE_FORCE_CONTINUE_ON_CLEAR=0` + `autonomous_mode=false`.
**Fix path**: Add cliff-emergency-pause: if previous session's last `cost-ledger-recorder` row shows tokens crossed cliff (220K+), inject ONE-SHOT advisory "previous session cliff-crossed; manual /clear performed; AUTONOMOUS LOOP PAUSED — type 'resume' to re-arm" instead of unconditional "continue".
**Severity**: MEDIUM — UX papercut; not blocking.

## Recommended fix-session sequence (post-/clear fresh-context)

1. **Session F1** (FOCUSED_IMPL ~80-100K): Gap 3 fix (trivial-continue gate on harness-health + stale-prompt + idle-escape + phase-coherence). Single shared helper. ~30-50 LOC + firing-test ~80 LOC.
2. **Session F2** (FOCUSED_IMPL ~80-100K): Gap 2 fix (stale-prompt-detector allow-list + action-verb gating). ~20-30 LOC + firing-test extension.
3. **Session F3** (RECOVERY ~150K): Gap 1 investigation (HH-1 Stop hook Windows quirk — empirical probe + possibly task-runtime substitution). Higher risk; may require Claude Code Windows runtime quirk acceptance + workaround layer.
4. **Session F4** (~30K): Gap 5 cliff-aware injector (defer if F1-F3 deliver enough quiet).

Each fix is a separate session per CLAUDE.md "never mix PLAN+IMPL"; F1 and F2 are independent and parallelizable.

## Cross-references

- L-S235-1 (self-pause memory rule) at `agent-workspace/memory/agent-notes.md`
- L-S235-2 (master-plan staleness hook) at `scripts/hooks/sub-plan-completion-coherence.sh`
- M-S49b-1 (Windows Stop quirk) at `agent-workspace/memory/mistake-log-archive-2026-05-06.md` (search `M-S49b-1`)
- D-043 (trivial-prompt SKIP path; analogous pattern for Gap 3) at `agent-workspace/memory/decisions/043-...`
- HH-12 (phase-coherence hook) — relevant cousin for Gap 3 trivial-gate refactor

## Critical insight

The 5 gaps form a cascade: HH-1 broken (Gap 1) → no auto-reboot at cliff → endless-continue (Gap 3) becomes possible → stale-prompt false-positives (Gap 2) compound noise → self-pause anti-pattern (Gap 4) emerges from misread of "harness handles boundary" → injector noise (Gap 5) at fresh-session entry.

**Root-fix priority = Gap 1 (HH-1)**. If Stop hook fires reliably, auto-reboot kicks in at 220K, preventing endless-continue at user-side. Gaps 2/3/4/5 are noise-tax mitigation; Gap 1 is structural-recovery.
