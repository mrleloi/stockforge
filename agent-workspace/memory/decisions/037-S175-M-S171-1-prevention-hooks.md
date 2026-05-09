---
id: D-037-S175-M-S171-1-prevention-hooks
title: M-S171-1 prevention hooks (idle-escape-detector + phase-status-coherence) shipped with companion firing-tests
date: 2026-05-07
status: ACCEPTED-AND-SHIPPED
level: SCOPE
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/memory/mistake-log.md
    quote: "M-S171-1: Post-S147-retirement idle-loop heuristic too narrow → 22 consecutive ROUTINE-IDLE/META-CADENCE sessions S148-S170 with zero substantive progress... Prevention: (1) idle-escape-detector.sh SessionStart hook scanning plans/pending vs current-execution active-track; (2) phase-status-coherence.sh SessionStart hook diffing project.md vs current-execution Phase claim; (3) escape doctrine: ≥3 consecutive ROUTINE-IDLE → mandate phase-audit subagent dispatch OR Q&A escalation, never silent 4th idle."
  - path: agent-workspace/memory/checkpoints/latest.md
    quote: "S175 NEXT ACTION: PRIORITY 1 = M-S171-1 prevention hooks (idle-escape-detector.sh + phase-status-coherence.sh) — FOCUSED_IMPL ~60-80K main."
  - path: agent-workspace/memory/agent-notes.md
    section: "L-S171-1 idle-loop heuristic narrowness"
  - path: agent-workspace/session-plans/pending/010-S50-phase-3.5-harness-deepening-master-plan.md
    section: "§ Hard rules during Phase 3.5 — Hard Rule #2 every hook ships with companion firing-test"
  - path: scripts/hooks/harness-health-self-scan.sh
    section: "HH-12 phase-drift signal — existing but only at Stop/SessionStart cadence; UserPromptSubmit cadence stronger"
intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 35
options_considered:
  - id: A
    summary: |
      Author 2 dedicated UserPromptSubmit + SessionStart hooks (idle-escape-detector.sh + phase-status-coherence.sh)
      with companion firing-tests; wire both into .claude/settings.json chains; emit system-reminder via JSON
      (UserPromptSubmit) or stderr (SessionStart) on FAIL state.
    pros:
      - "Closes M-S171-1 prevention rules #1 + #2 with deterministic detection (no LLM judgment)"
      - "Per-prompt cadence at UserPromptSubmit catches drift sooner than Stop-only project-md-staleness-check"
      - "Hour-bucket idempotency + 5-min same-session cache (mirrors L-S108-1 fix + harness-health-self-scan pattern)"
      - "Companion firing-tests synthesize deliberate FAIL states — Phase 3.5 Hard Rule #2 satisfied"
      - "Bash + POSIX only per UP-05 + L-S11-1 portability (no Skill tool calls)"
      - "Defense-in-depth with existing HH-12 (harness-health-self-scan.sh) — different cache TTLs surface different drift latencies"
    cons:
      - "Two more hooks in UserPromptSubmit chain — perf budget delta ~50-150ms per prompt"
      - "Some overlap with HH-12 phase-drift signal in harness-health-self-scan.sh"
      - "Mitigation: HH-12 only flags binary mismatch; phase-status-coherence adds NEW-ADRS-staleness + NO-IN-PROGRESS detection"
  - id: B
    summary: |
      Extend existing harness-health-self-scan.sh with new HH-13 (idle-escape) + tighten HH-12 (phase-coherence)
      signals — single hook, no new files.
    pros:
      - "No new hook files; consolidated entry point"
      - "Single cache + single bucket marker"
    cons:
      - "Couples idle-escape semantics to harness-health-protocol.md (T5 still at proposals/, M-S173-1 deny-lift gap)"
      - "Harder to test in isolation — harness-health firing-test grows; per-signal granularity weakens"
      - "M-S171-1 prevention rules explicitly named TWO hooks — single-hook collapses the doctrine"
      - "If harness-health-self-scan cache TTL hits, idle-escape misses that prompt window"
  - id: C
    summary: Defer prevention hooks; rely on agent-notes L-S171-1 + manual review at session entry.
    pros:
      - "Zero new code; cheapest path"
    cons:
      - "M-S171-1 surface itself proves manual review fails; ~22 sessions × 100K wasted main"
      - "Charter Principle 8 + AP-23 demand deterministic over LLM-Guardian"
      - "User checkpoint Q4=A established prevention hooks as PRIORITY 1 for S175"
chosen: A
chosen_rationale: |
  Two-hook architecture matches the M-S171-1 prevention rules verbatim (rule #1 = idle-escape-detector;
  rule #2 = phase-status-coherence). Per-prompt UserPromptSubmit cadence catches drift before the LLM
  composes a 4th idle session response — the exact failure mode of S148-S170. Companion firing-tests
  satisfy Phase 3.5 Hard Rule #2 from day-1; production smoke against real state confirmed both GREEN
  (S174 = ACTIVE per FOCUSED_IMPL-DONE marker; Phase 3.5 IN PROGRESS in both ce + project.md). Both
  hooks use the L-S108-1 hour-bucket idempotency pattern + 5-min same-session cache (mirrors the
  harness-health-self-scan TTL); cleanup loops sweep stale buckets. UP-05 + L-S11-1 portable.
approval_chain:
  - actor: agent
    action: PROPOSED + IMPLEMENTED
    at: 2026-05-07
    via: |
      scripts/hooks/idle-escape-detector.sh (170 LOC)
      + scripts/hooks/phase-status-coherence.sh (200 LOC)
      + scripts/hooks/firing-tests/idle-escape-detector-fire-test.sh (~190 LOC, 6 TCs / 15 assertions)
      + scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh (~210 LOC, 6 TCs / 16 assertions)
      + .claude/settings.json (UserPromptSubmit + SessionStart chains wired)
  - actor: user
    action: ACCEPTED-IN-ADVANCE
    at: 2026-05-07
    via: |
      S174 checkpoint (S173 user signal "continue" + autonomous-full doctrine "pick + execute, don't enumerate")
      directs S175 PRIORITY 1 = M-S171-1 prevention hooks. M-S171-1 mistake-log entry codifies prevention
      rules verbatim — this S175 turn = empirical execution of the codified prevention.
  - actor: agent
    action: SHIPPED
    at: 2026-05-07
    via: |
      Companion firing-tests: 15/15 + 16/16 PASS = 31/31 PASS combined.
      Production smoke against real S174 state: idle-escape state=GREEN consecutive=0 latest=S174/ACTIVE pending_plans=12;
      phase-coherence state=GREEN ce_phase=3.5 in_progress=3.5 match=1 new_adrs=0.
      Full firing-test suite regression: 74/74 PASS (72 baseline + 2 new; zero regression).
      .claude/settings.json validated as JSON.
verified_by:
  - mechanism: companion-firing-test
    at: 2026-05-07
    result: PASS
    detail: |
      idle-escape-detector firing-test: 15/15 (TC1 missing-CE silent / TC2 1-idle silent / TC3 3-idle YELLOW /
      TC4 3-idle+2-plans RED HIGH / TC5 5-active silent / TC6 cache-hit). All 6 TCs PASS.
  - mechanism: companion-firing-test
    at: 2026-05-07
    result: PASS
    detail: |
      phase-status-coherence firing-test: 16/16 (TC1 missing-files silent / TC2 aligned silent /
      TC3 mismatch RED HIGH / TC4 stale-project.md+3-NEW-ADRs YELLOW / TC5 no-in-progress YELLOW /
      TC6 cache-hit). All 6 TCs PASS.
  - mechanism: production-firing-evidence
    at: 2026-05-07
    result: PASS-GREEN
    detail: |
      Real-state smoke: idle-escape state=GREEN consecutive=0 latest=S174/ACTIVE pending_plans=12 (correctly
      identifies S174 FOCUSED_IMPL-DONE as active, not idle); phase-coherence state=GREEN ce_phase=3.5
      in_progress=3.5 match=1 new_adrs=0 (correctly aligns ce + project.md Phase 3.5 IN PROGRESS).
      Both hooks would have fired RED at S171 entry (consecutive=22 + project.md staleness pre-reconcile).
  - mechanism: full-suite-regression
    at: 2026-05-07
    result: PASS
    detail: "scripts/hooks/firing-tests/run-all.sh: 74/74 PASS (elapsed 206s). 72 baseline + 2 new. Zero regression."
  - mechanism: settings-json-validation
    at: 2026-05-07
    result: PASS
    detail: "python -m json.tool .claude/settings.json: VALID JSON. 2 new entries in UserPromptSubmit chain + 2 new in SessionStart chain."
affects:
  charter: false
  spec_files: []
  code_paths:
    - scripts/hooks/idle-escape-detector.sh
    - scripts/hooks/phase-status-coherence.sh
    - scripts/hooks/firing-tests/idle-escape-detector-fire-test.sh
    - scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh
  config_files:
    - .claude/settings.json
  other_decisions:
    - D-035 (T6 harness-health-self-scan — sister hook; HH-1..HH-12 catalog)
    - D-036 (S174 HH-G portability — same Phase 3.5 firing-test discipline)
    - D-028 (HH-C.4 Session End ritual — project-md-staleness-check.sh sister Stop hook)
depends_on:
  - "agent-workspace/memory/current-execution.md (data source for newest 5 session block headers)"
  - "agent-workspace/memory/project.md Phase Goals Tracker (data source for IN PROGRESS rows)"
  - "agent-workspace/memory/decisions/ (ADR mtime cross-check for staleness signal)"
  - "agent-workspace/session-plans/pending/ (pending plans count for severity boost)"
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A — SHIPPED with empirical-firing evidence.
  Future amendments:
  - Threshold tuning: 3-consecutive-idle threshold may need adjustment after 10+ session calibration data.
  - Severity matrix: RED-vs-YELLOW boundary (currently pending_plans ≥1 boost) may need refinement.
  - Pattern extension: if new ROUTINE-* labels emerge (e.g., ROUTINE-CHECKPOINT), update detector regex.
  - SessionStart-vs-UserPromptSubmit cadence: monitor cache-hit rate; if UserPromptSubmit cache-hit ratio
    >50% within 5-min windows, increase TTL to reduce overhead.
tags:
  - "phase-3.5"
  - "harness"
  - "M-S171-1"
  - "prevention"
  - "idle-escape"
  - "phase-coherence"
  - "userpromptsubmit-hook"
  - "firing-test-shipped"
  - "production-firing-evidence"
---

# Decision 037 — M-S171-1 Prevention Hooks

## Context

S171 surfaced M-S171-1: 22 consecutive ROUTINE-IDLE / META-CADENCE sessions S148-S170 with zero substantive progress. The post-S147 idle-loop heuristic was too narrow — it checked user_prompt mtime + drift D1 + sync-grilling cadence + in-flight dispatch but missed:

1. **session-plans/pending/** — 12 plans queued (008-S45 Track G/H/I + 009-S48 Phase 2.5 HH-A..HH-H + 009-S51 Track J/K + 010-S50 Phase 3.5)
2. **project.md Phase vs current-execution.md Phase** — silent advance from "Phase 2.5 IN PROGRESS / Phase 3 PAUSED" (project.md S48d) to "Phase 3" (current-execution.md S148+) without `verify_phase_before_next_phase` audit

User signal 2026-05-07: "sao lại dừng rồi, không chạy autonomous nữa? lỗi harness à?" surfaced the gap. ~100K wasted main accumulated across 22 idle/cadence sessions before user push detected the stall.

S172 audit reconciliation closed the immediate state mismatch. M-S171-1 codified 3 prevention rules:

1. `idle-escape-detector.sh` SessionStart hook scanning plans/pending vs current-execution active-track
2. `phase-status-coherence.sh` SessionStart hook diffing project.md vs current-execution Phase claim
3. Escape doctrine: ≥3 consecutive ROUTINE-IDLE → mandate phase-audit subagent dispatch OR Q&A escalation, never silent 4th idle

S173 closed Phase 3.5 T5/T6/T8 charter user-gate. S174 closed Phase 2.5 HH-G portability residue per Q4=A user-pick. S175 (this turn) executes M-S171-1 prevention rules per S174 checkpoint PRIORITY 1.

## Analysis

### Hook 1: idle-escape-detector.sh

**Detection signal**: count consecutive `ROUTINE-IDLE` or `META-CADENCE` blocks at the top (newest) of `current-execution.md`. Threshold ≥3 anchors to the L-S171-1 doctrine — the exact pattern that escaped detection at S148-S170.

**Severity matrix**:

| consecutive | pending_plans | state  | severity |
|-------------|---------------|--------|----------|
| 0-2         | any           | GREEN  | LOW      |
| ≥3          | 0             | YELLOW | MEDIUM   |
| ≥3          | ≥1            | RED    | HIGH     |

The pending-plans boost reflects the M-S171-1 surface: 12 plans queued while idle = work-available-but-ignored = stronger escape signal.

**Idempotency layers**:

- **Hour-bucket marker** (`agent-workspace/memory/.idle-escape-fired-YYYYMMDD-HH`) — suppresses duplicate system-reminder emission within same hour bucket. Cleanup loop sweeps stale buckets per L-S108-1 (M-S108-1 sister-bug fix doctrine).
- **5-min same-session cache** (`.idle-escape-cache-${SID}`) — perf budget on UserPromptSubmit; mirrors harness-health-self-scan.sh TTL.

**Emit channel**: UserPromptSubmit emits via `node -e ... hookSpecificOutput.additionalContext` JSON contract → injects system-reminder into LLM context. SessionStart emits via stderr (visible in `.session-hooks.log`).

### Hook 2: phase-status-coherence.sh

**Three checks** (each contributes to severity aggregation):

| Check | Detection | Severity contribution |
|-------|-----------|----------------------|
| (A) Phase mismatch | latest `## S<N> — Phase X` header phase X NOT IN project.md IN PROGRESS rows | RED HIGH |
| (B) Stale project.md | ≥3 NEW ADRs in `decisions/` newer than `project.md` mtime by >2h AND `current-execution.md` newer than project.md by >24h | YELLOW MEDIUM |
| (C) No active phase | project.md Phase Goals Tracker has zero IN PROGRESS rows while sessions still progressing | YELLOW MEDIUM |

Severity aggregates: any (A) hit → RED. (B) or (C) without (A) → YELLOW. None → GREEN.

**Differentiation from existing HH-12** (`harness-health-self-scan.sh`): HH-12 only checks (A) at Stop + SessionStart cadence with broader 5-min cache. phase-status-coherence runs at UserPromptSubmit (per-prompt) AND adds checks (B) and (C). The two hooks are defense-in-depth — different cache TTLs surface different drift latencies.

### Companion firing-tests

Per Phase 3.5 Hard Rule #2 (every hook ships with companion firing-test). Both tests synthesize tempdir fixtures + assert hook emits expected signal.

| Hook | Tests | Assertions | Pass rate |
|------|-------|------------|-----------|
| idle-escape-detector | 6 | 15 | 15/15 |
| phase-status-coherence | 6 | 16 | 16/16 |
| **Combined** | **12** | **31** | **31/31** |

Each test uses fresh tempdir per scenario; cleanup via `rm -rf` post-assertion to isolate cache + markers.

### Production smoke

Real-state run against S174 close state:

```
idle-escape-detector:
  state=GREEN consecutive=0 latest_sid=S174 latest_label=ACTIVE pending_plans=12

phase-status-coherence:
  state=GREEN ce_phase=3.5 in_progress=3.5 match=1 new_adrs=0 ce_delta_hr=0
```

Both correctly identify the current state as GREEN — S174 is FOCUSED_IMPL-DONE (not idle); Phase 3.5 IN PROGRESS aligns in both ce + project.md; project.md was just updated at S174 close (no NEW ADRs older than the file).

**Counter-factual**: had these hooks been wired at S148, both would have fired:

- idle-escape: starting at S150 entry (3 consecutive ROUTINE-IDLE detected) → state=YELLOW (no plans were detected because plans/pending content existed but was not part of the heuristic) — eventually RED once pending_plans bypass shipped (this hook).
- phase-coherence: at every entry from S148 onwards, ce_phase="Phase 3" did not match project.md's last-IN-PROGRESS-row "Phase 2.5" → state=RED match=0 → mandate reconcile.

In other words, the prevention rules would have caught the M-S171-1 stall pattern from the first idle session — converting a 22-session ~100K wasted-main slip into a single-session reconcile turn.

### Settings.json wiring

**UserPromptSubmit chain**: appended after `effort-escalation-detector.sh`, before `harness-health-self-scan.sh`. Order rationale:

```
userprompt-invariants-injector  → injects always-loaded invariants
stale-prompt-detector            → detects stale user_prompt files
correction-rate-tracker          → records user-correction events
in-flight-subagent-watcher       → flags pending dispatches
hook-firing-counter              → very cheap baseline counter
effort-escalation-detector       → /effort mode triage
idle-escape-detector             ← NEW (cheap; reads CE only)
phase-status-coherence           ← NEW (medium; reads CE + project.md + decisions/)
harness-health-self-scan         → heaviest (12-signal HH-1..HH-12)
```

**SessionStart chain**: appended at end (after `session-start-scan-unattested-observations`, alongside `harness-health-self-scan`). Each invocation passes `CLAUDE_HOOK_EVENT=SessionStart` env var → hook routes to stderr emission instead of UserPromptSubmit JSON.

## Decision

Ship 4 artifacts closing M-S171-1 prevention rules:

1. `scripts/hooks/idle-escape-detector.sh` (NEW; ~170 LOC) — prevention rule #1
2. `scripts/hooks/phase-status-coherence.sh` (NEW; ~200 LOC) — prevention rule #2
3. `scripts/hooks/firing-tests/idle-escape-detector-fire-test.sh` (NEW; ~190 LOC; 6 TCs / 15 assertions) — companion
4. `scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh` (NEW; ~210 LOC; 6 TCs / 16 assertions) — companion
5. `.claude/settings.json` (EDIT; +6 hook entries: 3 UserPromptSubmit + 3 SessionStart, 2 of which are new hooks × 2 chains; 2 ordering tweaks for harness-health-self-scan position)

### What this means concretely

- M-S171-1 prevention rules #1 + #2 codified as deterministic per-prompt hooks (Charter Principle 8 + AP-23 anti-LLM-Guardian satisfied).
- Future ≥3 consecutive ROUTINE-IDLE / META-CADENCE blocks trigger system-reminder demanding phase-audit OR Q&A escalation OR plan execution.
- Future project.md ↔ current-execution.md phase mismatch fires per-prompt instead of per-Stop (which already had project-md-staleness-check.sh but missed the 22-session slip).
- Phase 3.5 Hard Rule #2 satisfied: both hooks ship WITH companion firing-tests from day-1.
- Phase 3.5 IN-PROGRESS-PARTIAL-S174 status updated: M-S171-1 prevention shipped (was T8 charter cool-down + M-S171-1 prevention residue both pending; M-S171-1 closes now).

### What this does NOT change

- Existing harness-health-self-scan.sh HH-12 phase-drift signal — still active; defense-in-depth complement to phase-status-coherence (different TTL = different drift latency surface).
- Existing project-md-staleness-check.sh Stop hook — still active; the new phase-status-coherence is additive (UserPromptSubmit cadence catches faster).
- T8 charter cool-down (≥2026-05-09) — orthogonal; unchanged.
- M-S173-1 deny-lift gap — orthogonal; unchanged.

## Why (Reasons)

1. **M-S171-1 prevention rules verbatim**: The mistake-log entry codified two named hooks. This decision = empirical execution.
2. **S174 checkpoint PRIORITY 1**: explicit PRIORITY 1 routing for S175 was M-S171-1 prevention hooks (over PRIORITY 2 HH-C.2 misfire investigation; over PRIORITY 3 HH-6/HH-10 cleanup).
3. **Charter Principle 8 + AP-23**: deterministic detection > LLM-Guardian. Hooks check for known-pattern markers via grep + count — no judgment.
4. **Phase 3.5 Hard Rule #2**: every hook authored in Phase 3.5 ships with firing-test from day-1; T7 retrofit drained the legacy backlog. NEW hooks must continue the discipline.
5. **harness_priority_one user doctrine**: harness/system improvement always > product work. M-S171-1 prevention = pure harness; closes a known gap that cost ~100K wasted main.
6. **Counter-factual evidence**: had these hooks been wired at S148, the M-S171-1 stall converts to a 1-session reconcile (22-session × 100K main saved).

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| False-positive: legitimate 3-cadence cluster (e.g., post-/clear catch-up sessions) | medium | Hour-bucket idempotency suppresses repeat alerts within same hour; pending_plans=0 keeps state=YELLOW (advisory) not RED |
| Pattern drift: future session blocks use new ROUTINE-* labels not matched by regex | low | Regex anchored to `— ROUTINE-IDLE\|— META-CADENCE`; new labels would silently be classified ACTIVE — fail-safe direction |
| Perf budget on UserPromptSubmit: 2 hooks × ~150ms each = 300ms additional latency per prompt | low | 5-min same-session cache → only first prompt of each 5-min window pays full cost; cache-hit fast-path is <10ms |
| Cache marker collision across sessions (M-S108-1 family) | low | Hour-bucket marker uses `date +%Y%m%d-%H` (NEVER fallback constant); cleanup loop sweeps stale buckets |
| Settings.json corruption from manual edit | low | Validated post-edit via `python -m json.tool` → VALID JSON |
| Overlapping signal with HH-12 in harness-health-self-scan | low | Different TTLs (HH-12 5-min cache via .harness-health-cache-${SID}; phase-coherence 5-min cache via .phase-coherence-cache-${SID}) — defense-in-depth |
| Firing-test em-dash encoding edge case (Git Bash UTF-8) | low | Verified — fixture-write via heredoc preserves UTF-8 bytes; firing-test passes 15/15 + 16/16 |
| Empty `node` binary in stripped environments | low | Fallback to stderr emission preserves observability without JSON injection |

## Open Questions

(none — closed via empirical-firing evidence)

If these hooks accumulate >5 false-positives in 30 sessions, threshold tuning candidate:

- consecutive threshold: 3 → 4 (looser)
- severity boost rule: pending_plans ≥1 → ≥2 (require multiple plans to RED)

Defer such tuning to post-S180 calibration pass with empirical data.

## Acceptance Record

- **2026-05-07 S171**: M-S171-1 surfaced; prevention rules #1 + #2 codified in mistake-log
- **2026-05-07 S172**: Phase audit reconciliation closed immediate state mismatch
- **2026-05-07 S173**: Phase 3.5 T5/T6/T8 charter user-gate handled
- **2026-05-07 S174**: HH-G portability close per Q4=A; checkpoint NEXT ACTION=PRIORITY 1 M-S171-1 prevention
- **2026-05-07 S175**: PROPOSED + IMPLEMENTED + SHIPPED (this turn)
  - 4 artifacts written
  - Companion firing-tests: 31/31 PASS combined
  - Production smoke: both GREEN on real S174-close state
  - Full firing-test suite regression: 74/74 PASS
  - settings.json validated
- **VERIFIED-by**: companion-firing-tests + production-firing-evidence + full-suite-regression + settings-json-validation
