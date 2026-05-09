---
observation_id: 2026-05-07-S185-userprompt-chain-truncation-rc
type: focused-audit-log
session: S185
phase: 3.5
created_at: 2026-05-07
predecessor_observation: 2026-05-07-S184-harness-health-fire-restoration.md
status: ROOT-CAUSE-HYPOTHESIS-IDENTIFIED-PENDING-S186-IMPL-VERIFICATION
---

# S185 — UserPromptSubmit Chain Truncation Root-Cause Diagnosis

## Summary

S185 FOCUSED_AUDIT investigates S183 PRIORITY 2 carry-over: 0 production
emissions of last 6 UserPromptSubmit chain hooks (in-flight-subagent-watcher
through harness-health-self-scan) from 154+ fires on 2026-05-07. **Verdict:
STRONG HYPOTHESIS IDENTIFIED**. UserPromptSubmit chain truncation on Windows
correlates with hooks not emitting stdout JSON. Specifically: chain advances
exactly one hook past each hook that writes `hookSpecificOutput` JSON to
stdout via `process.stdout.write(JSON.stringify(...))`; truncates at the first
hook that emits no stdout. Same Claude-Code-Windows root-cause class as S183
SessionStart spawn truncation. **S186 PRIORITY 1 = empirical IMPL test of
Option D** (modify userprompt-invariants-injector trivial path to emit minimal
JSON; observe whether chain reaches hook #2 on subsequent trivial prompt).

## Empirical Evidence (5-fold)

### 1. All-time UserPromptSubmit chain emission counts (filtered to ISO-timestamp lines)

| Hook (chain order) | always-log? | Real emissions | Reach rate vs 157 fires |
|---|---|---|---|
| 1. userprompt-invariants-injector | YES (both SKIP + INJECTED log) | 157 | **100%** |
| 2. stale-prompt-detector | YES (clean + stale both log) | 29 | **18.5%** |
| 3. correction-rate-tracker | NO (conditional emit on match only) | 6 | indeterminate |
| 4. in-flight-subagent-watcher | conditional (stderr emission only when STALE_COUNT>0) | 0 | ~0% |
| 5. hook-firing-counter | TBD | 0 | likely ~0% |
| 6. effort-escalation-detector | TBD | 0 | likely ~0% |
| 7. idle-escape-detector | YES (always emits state=N line) | 2 (BOTH from SessionStart at 10:45:31) | **0%** in UserPromptSubmit |
| 8. phase-status-coherence | YES (always emits state=N line) | 2 (BOTH from SessionStart at 10:45:31) | **0%** in UserPromptSubmit |
| 9. harness-health-self-scan | YES (always emits state=N line) | 14 (mostly synthesized SIDs + 2 SessionStart real) | **0%** in UserPromptSubmit |

### 2. Hook #1 path bifurcation — stdout-JSON correlation

userprompt-invariants-injector code paths:

- **Trivial path** (`continue` / `ok` / `yes` / etc.): logs `UserPromptSubmit-injector: SKIP (trivial prompt detected)`, NO stdout output, exits 0
- **Non-trivial (INJECTED) path**: logs + writes `process.stdout.write(JSON.stringify({hookSpecificOutput: {hookEventName: 'UserPromptSubmit', additionalContext: REMINDER}}))`, exits 0

Production counts:
- SKIP path: 128 emissions
- INJECTED path: 29 emissions
- TOTAL: 157 emissions = 100% match with hook fires

**Stale-prompt-detector emissions (29) = INJECTED-path fires (29)** — exact 1:1 correspondence.

⇒ Chain advances to hook #2 ONLY when hook #1 emits stdout JSON. Trivial path (no stdout) → chain stops at #1.

### 3. Hook #2 onward — stdout-JSON requirement appears recursive

Inspecting `stale-prompt-detector.sh`:
- Always writes log line (`clean (no stale refs)` OR stale-detected variant)
- Emits stdout JSON `process.stdout.write(JSON.stringify({hookSpecificOutput: ...}))` ONLY on stale detection (line 127-128 conditional)

If hypothesis holds: when hook #2 emits stdout JSON (stale detected) → chain reaches #3. When hook #2 emits no stdout (clean) → chain stops at #2.

Empirical confirmation deferred — would need to count stale-detection events vs clean-only events; correction-rate-tracker emit count (6) is conditional itself so not useful as chain-reach probe.

### 4. Manual chain run confirms no bash-level issue

```bash
PROMPT='{"hook_event_name":"UserPromptSubmit","prompt":"please refactor the auth module..."}'
for HOOK in <all 9 hooks>; do
  printf '%s' "$PROMPT" | CLAUDE_HOOK_EVENT=UserPromptSubmit \
    CLAUDE_PROJECT_DIR=/c/htdocs/stockforge \
    CLAUDE_SESSION_ID=manual-S185-test bash "$HOOK"
  echo "rc=$?"
done
```

All 9 hooks: rc=0, total wall time ~3 seconds. No bash-level error or chain fault.

⇒ Truncation is NOT a bash issue. Same class as S183 SessionStart spawn truncation: Claude-Code-Windows-specific behavior in the hook-chain dispatcher.

### 5. Real-time S185 confirmation

This S185 turn's `/clear` + "continue" prompt fired UserPromptSubmit at 11:16:24:

```
[2026-05-07T11:16:24+07:00] UserPromptSubmit-injector: SKIP (trivial prompt detected)
```

Followed by silence until PostToolUse watchdog at 11:16:45 (21-second gap; only this turn's tool calls). NO stale-prompt-detector emission for the 11:16:24 prompt. Confirms truncation reproducibility on trivial prompts.

## Hypothesis Verdict

**CONFIRMED-PENDING-IMPL-VERIFICATION**: UserPromptSubmit hook chain on Windows requires each hook to emit `hookSpecificOutput` JSON to stdout for the chain to advance. Hooks that exit 0 with no stdout cause the chain to truncate at that point.

This contrasts with SessionStart chain pattern where (per S183 evidence #2) the source=empty case sees ALL 17 chain hooks emit despite most being log-only. **However**, SessionStart chain may have different chain-continuation semantics (multiple matchers `startup|resume|clear` + `.*`; SessionStart hooks may be invoked in parallel rather than strictly sequential like UserPromptSubmit). Empirical IMPL verification (Option D below) is needed before promoting this finding to a binding rule.

## Remediation Options

| Option | Approach | Pros | Cons | Recommended? |
|---|---|---|---|---|
| **A** | Make every UserPromptSubmit chain hook emit minimal `hookSpecificOutput` JSON on every code path | Defense-in-depth; uniform pattern | Touches 9 hooks; ~50 LOC × 9 = ~450 LOC change | After Option D confirms |
| **B** | Collapse 9 hooks into 1 monolithic UserPromptSubmit hook that does all checks + emits one JSON | Single point of stdout output | Loses modularity; hard to firing-test | NO |
| **C** | Reorder chain so stdout-emitting hooks come FIRST (but log-only hooks wouldn't reach if stdout-required) | Minimal change | Doesn't solve root cause | NO |
| **D** | **Empirical test**: modify userprompt-invariants-injector trivial path to emit minimal JSON; observe whether next trivial-prompt fire reaches hook #2 (stale-prompt-detector emits clean log) | Cheap; ~5 LOC change; confirms hypothesis | Single-hook change won't help downstream hooks 3-9 | **YES — S186 PRIORITY 1** |
| **E** | Defer fix; document workaround (avoid trivial prompts in critical-monitor sessions) | Zero code change | Doesn't actually fix harness signal coverage gap; AP-7 vacuous defer | NO |
| **F** | After Option D confirms hypothesis: apply Option A pattern (modify all 9 hooks to emit minimal JSON on every path) | Comprehensive fix | Larger scope; ~MULTI-TASK IMPL ~150-250K | After D confirmation |

**Recommended path**: D first (cheap empirical test) → A second (full fix if D confirms).

## Counter-factual recovery (post-hypothetical-fix)

If Option D + A combined SHIPPED post-S186:
- harness-health-self-scan UserPromptSubmit emissions: 0/154 → ~157 per turn
- idle-escape-detector + phase-status-coherence emissions same restoration
- Effective continuous self-correction signal coverage: 0% → ~100% per UserPromptSubmit event
- Combined with S184 D-042 SessionStart fix: full Phase 3.5 §HH-G empirical-firing-exemplar contract restored on Windows

## Hard rules upheld

- L-S176-1 BINDING (real-state-derived): all evidence cites real `.session-hooks.log` lines with timestamps + counts
- verify_phase_before_next_phase: empirical AUDIT (5-fold evidence catalog), not silent advance
- harness_priority_one: closing harness signal-coverage gap continuation from S184
- autonomous_continue_no_self_pause: picked + executed S184 PRIORITY 1 verbatim
- M-S147-1 prevention check at entry ✓

## Hard locks honored

- 0 git commits this turn
- 0 charter file edits (T8 cool-down ≥2026-05-09 active)
- 0 constitution file writes (M-S173-1 deny holds)
- 0 hook code edits (S185 = pure FOCUSED_AUDIT scope)
- Q-B2: 0 AskUserQuestion fired (S184 checkpoint PRIORITY 1 ratifies S185 audit)

## L-S80-2 promotion candidate (NEW S185 surfacing)

S185 production smoke surfaces L-S80-2 lint warnings on 4 hooks via bash-hook-lint emission (visible in `.session-hooks.log` recent tail):
- attach-portability-smoke.sh
- harness-health-self-scan.sh
- idle-escape-detector.sh
- phase-status-coherence.sh

All 4 violate `VAR=$(grep -c ... || echo N)` capture trap pattern (multi-line "0\nN" capture when grep finds 0 + exits 1). This is the SAME bug class I caught + fixed in S184 firing-test TC1+TC9 first-run failure. Codified L-S80-2 lint rule already exists. Promotion candidate: add lint-rule retro-fit task to S186+ priority 3+ (after D+A truncation fix) — fix the 4 production hooks that violate L-S80-2.

## Files this observation

- NEW `agent-workspace/memory/observations/2026-05-07-S185-userprompt-chain-truncation-rc.md` (this file)
- TO EDIT (next): `agent-workspace/memory/project.md` + `agent-workspace/memory/current-execution.md` + `agent-workspace/memory/checkpoints/latest.md` + `agent-workspace/memory/sessions/2026-05-07-session-185.md`
- NO hook code edits (FOCUSED_AUDIT scope)

## End of S185 observation

Status: ROOT-CAUSE-HYPOTHESIS-IDENTIFIED-PENDING-S186-IMPL-VERIFICATION. Empirical 5-fold evidence catalog. Chain-truncation correlates 1:1 with stdout-JSON-emission absence in UserPromptSubmit chain on Windows. S186 PRIORITY 1 = Option D cheap empirical test + observation at subsequent trivial prompt fire.
