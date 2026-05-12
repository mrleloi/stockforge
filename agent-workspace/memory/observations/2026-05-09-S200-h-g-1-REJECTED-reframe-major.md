# S200 — D-049 H-g.1 REJECTED + MAJOR HYPOTHESIS REFRAME: NOT chain truncation; 4 silent hooks have INDEPENDENT internal early-exit bugs

**Date**: 2026-05-09
**Trigger**: User trivial-prompt "continue" at 2026-05-09T10:40:06+07:00 (~4.5 min after S199 H-g.1 deploy at 10:35+)
**Session**: S200 (VERIFY+IMPL hybrid + INVESTIGATIVE; verdict + reframe + revert)
**Predecessor**: S199 — D-049 H-g.1 settings.json hook swap deployed (slot 5 ↔ slot 6)

## Empirical Evidence (5-fold)

### 1. Hook chain post-swap firing pattern at 10:40:06
| Slot | Hook | Log file | mtime/state |
|---|---|---|---|
| 1 | userprompt-invariants-injector | `.session-hooks.log` echo | `[10:40:06] UserPromptSubmit-injector: SKIP (trivial prompt detected)` ✓ |
| 2 | stale-prompt-detector | (designed silent on trivial) | silent ✓ |
| 3 | correction-rate-tracker | (designed silent on trivial) | silent ✓ |
| 4 | in-flight-subagent-watcher | `.in-flight-subagent-watcher.log` | mtime 10:40:06 BUMPED ✓ |
| 5 | **effort-escalation-detector** (post-swap) | `.effort-escalation.log` | **MISSING** — silent |
| 6 | **hook-firing-counter** (post-swap) | `.hook-firing-counter.log` | mtime **10:40:07 BUMPED** ✓ |
| 7 | idle-escape-detector | `.idle-escape.log` | MISSING — silent |
| 8 | phase-status-coherence | `.phase-coherence.log` | MISSING — silent |
| 9 | harness-health-self-scan | `.harness-health.log` | mtime 09:43:25 UNCHANGED — silent |

### 2. Critical observation: chain ADVANCED past slot 5 silent → slot 6 fired
Slot 5 (effort-escalation) silent + Slot 6 (hook-firing-counter) FIRED → **chain executor did NOT truncate at slot 5**. Slot 5 ran to completion (early-exited internally) and slot 6 then ran. This contradicts the entire S187..S199 "chain truncation at #5/#6 boundary" hypothesis.

### 3. Hook identity vs slot position
| Hook | At slot 5 (default) | At slot 6 (post-swap) | Pattern |
|---|---|---|---|
| hook-firing-counter | FIRED | FIRED | Always fires regardless of slot |
| effort-escalation-detector | SILENT (S199 baseline) | SILENT (S200) | Never fires regardless of slot |

→ Cap (if any) is on HOOK IDENTITY, not POSITION.

### 4. Each "silent" hook has internal early-exit logic — discovered S200 grep pass

**effort-escalation-detector.sh** (line 34):
```
{ [ "${HOOK_EVENT:-}" = "PreToolUse" ] && [ "${TOOL_NAME:-}" = "Agent" ]; } || exit 0
```
Hook is designed for **PreToolUse + Agent tool** events. Registered as UserPromptSubmit hook in `.claude/settings.json` → ALWAYS early-exits at line 34 because HOOK_EVENT != "PreToolUse". **MIS-WIRED at settings.json level**.

**idle-escape-detector.sh** + **phase-status-coherence.sh**:
- Line 2 comment: "UserPromptSubmit + SessionStart hook" — wiring intent correct.
- Line 26/30: `EVENT="${CLAUDE_HOOK_EVENT:-UserPromptSubmit}"` — env-driven (settings.json passes `CLAUDE_HOOK_EVENT=UserPromptSubmit`).
- Multiple internal early-exit points (lines 50, 66, 82, 148, 156 in idle-escape; lines 51, 67, 80, 193, 198 in phase-coherence).
- Bash-hook-lint flagged **L-S108-1**: `${CLAUDE_SESSION_ID:-WORD} fallback-to-constant + marker filename present (likely per-session lockout on Windows)`. Marker file from prior session (with empty CLAUDE_SESSION_ID → constant fallback name) persists, and all subsequent sessions detect "their own" marker and early-exit as already-processed.

**harness-health-self-scan.sh** (line 56-57):
```
start_line=$(grep -n "SessionStart session=$SID" "$HOOK_LOG" 2>/dev/null | tail -1 | cut -d: -f1)
[ -z "$start_line" ] && { emit_skip "HH-1" "no-SessionStart-for-SID"; return; }
```
Line 5 comment says hook fires on UserPromptSubmit + SessionStart. But $SID = CLAUDE_SESSION_ID — for real-prod UserPromptSubmit triggers, `.session-hooks.log` shows `[10:16:56] SessionStart session=` (EMPTY field; no SID). So `grep "SessionStart session="` finds entries but $SID is empty too → match fails on real-prod context (only matches the firing-test smoke runs which use `firing-test-smoke-8584` SID). HH-1 early-exit at line 57. emit_skip writes to log... but log mtime UNCHANGED at 10:40 → either emit_skip not running OR not flushing.

### 5. Bash-hook-lint signal was screaming since at least S195 — we missed it
`.session-hooks.log` from S195+ Stop runs contains:
```
- L-S108-1-CLAUDE-SESSION-ID-FALLBACK-CONSTANT: idle-escape-detector.sh — fallback-to-constant ${CLAUDE_SESSION_ID:-WORD} + marker filename present (likely per-session lockout on Windows; use date hour-bucket or session-log basename — L-S108-1)
- L-S108-1-CLAUDE-SESSION-ID-FALLBACK-CONSTANT: phase-status-coherence.sh — same
- L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: idle-escape-detector.sh — same
- L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: phase-status-coherence.sh — same
- L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: harness-health-self-scan.sh — same
```
Lint hook explicitly named per-session lockout as ROOT CAUSE hypothesis with FIX SUGGESTION. **The agent ran 13 hypothesis tests across S187..S199 chasing chain-truncation while the actual root cause was annotated in working memory at every Stop-hook cycle.** AP-23 anti-pattern: missed deterministic Guardian signal in favor of LLM-driven hypothesis exploration.

## Verdict: D-049 H-g.1 REJECTED + Hypothesis stack RETIRED

**D-049 H-g.1 status**: `SCAFFOLD-DEPLOYED-PENDING-PRODUCTION-OBSERVATION` → **`SHIPPED-1ST-PRODUCTION-OBSERVATION-REJECTED-1-OF-1-BINARY-DECISIVE`**.

**ENTIRE hypothesis stack RETIRED with prejudice** — H-c + H-a + H-e + H-d.2 + H-d.1 + H-f + H-g.1 all REJECTED but the FRAMING was wrong from the start. There is no "cap mechanism" or "chain truncation". There are 3 distinct hook bug classes:

**Bug Class 1 (effort-escalation)**: Hook MIS-WIRED in settings.json — designed for PreToolUse+Agent, registered as UserPromptSubmit. Fix: Either remove entry from UserPromptSubmit array OR change hook guard at line 34 to allow UserPromptSubmit. Cheapest: remove from UserPromptSubmit; relocate to PreToolUse if needed.

**Bug Class 2 (idle-escape, phase-coherence)**: L-S108-1 per-session lockout markers. Fix per lint suggestion: use date-hour-bucket OR session-log basename instead of `${CLAUDE_SESSION_ID:-WORD}` fallback constant.

**Bug Class 3 (harness-health)**: HH-1 SID matching fails when CLAUDE_SESSION_ID env empty. Fix: detect-empty-SID + use latest-SessionStart-line OR adopt date-hour-bucket like fix for Bug Class 2.

## Revert protocol executed (S200 IMPL)

Edit `.claude/settings.json` to restore slot 5 = hook-firing-counter, slot 6 = effort-escalation. 3-fold post-revert verification: JSON parse OK + UserPromptSubmit hook count 9 unchanged + slot 4-6 ordering = in-flight-subagent-watcher / hook-firing-counter / effort-escalation-detector ✓.

## D-049 H-g.1 swap reverted; settings.json restored to default ordering.

## S201 NEXT ACTION (REFRAMED)

**PRIORITY 1 (REFRAMED)**: Fix Bug Class 1 first (cheapest, surgical). Either:
- **1.a**: Remove effort-escalation-detector entry from UserPromptSubmit in `.claude/settings.json` (~3 LOC; aligns hook with its design event).
- **1.b**: Move effort-escalation entry from UserPromptSubmit to PreToolUse hook array (~5 LOC; keeps hook active in correct event).

**PRIORITY 1B**: Fix Bug Class 2 — refactor `${CLAUDE_SESSION_ID:-WORD}` fallback in idle-escape + phase-coherence per L-S108-1 lint suggestion (use date-hour-bucket).

**PRIORITY 1C**: Fix Bug Class 3 — harness-health HH-1 early-exit guard handle empty SID.

**PRIORITY 1D**: After all 3 bug classes fixed → re-observe at next trivial-prompt; expect all 9 hooks (or 8 if Bug 1 fixed via removal) to fire on UserPromptSubmit.

**PRIORITY 2 (NEW)**: Document AP-24 candidate — "deterministic-Guardian signal missed; LLM hypothesis exploration ran 13 cycles while bash-hook-lint output named root cause every Stop". Promote to charter / agent-notes.

## AP-23 cheapest-by-RISK doctrine: 7-instance count REMAINS VERIFIED

But the doctrine is ratified WHILE the underlying investigation was misframed. AP-23 remains valid (cheapest-first sequence saved time vs full instrumentation); the failure mode was AP-24 (missed lint output).

## Hard rules binding sustained (S200)

ALL prior bindings. NEW LESSON CANDIDATE **L-S200-1**: "When deterministic Guardian (bash-hook-lint, drift-signals, etc.) emits hypothesized root cause for a recurring symptom, agent MUST inspect Guardian output before launching ≥2nd hypothesis cycle. Why: S187..S199 ran 13 tests for an issue with explicit lint annotation. How to apply: at Stop-hook bash-hook-lint output, if any flag matches active investigation symptom, prioritize lint-flagged file inspection."

**No git commits / 0 charter file edits / 0 constitution writes** (S200 = settings.json revert + observation/lesson documentation only).

End of S200 H-g.1 verdict + MAJOR REFRAME. **D-049 REJECTED; chain-truncation framing RETIRED with prejudice; 3 distinct hook bug classes identified with fixes; bash-hook-lint missed-signal AP-24 candidate; S201 NEXT = Bug Class 1 effort-escalation removal/relocate, Bug Class 2 L-S108-1 marker refactor, Bug Class 3 harness-health HH-1 fix, then re-observe.**
