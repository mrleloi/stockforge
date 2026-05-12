---
observation_id: drift-detector-S241b-phantom-dispatch-RC
type: governance-investigation
session: S241b
phase: 4
priority: HIGH (downgraded from BLOCKING)
created_at: 2026-05-10T12:30:00Z
related_lessons: [M-S238-2, L-S239-4, L-S240-5]
related_observations: [track-A-S239-anti-flake-run1.md, track-A-S240-anti-flake-run2.md]
status: complete-RC-IDENTIFIED-fix-staged
note_on_authoring: drift-detector subagent system reminder forbids writing report .md files; parent session persists the agent's returned message verbatim here.
---

# Drift-Detector S241b — Phantom Dispatch Root Cause Investigation

## 1. Evidence Catalog

The "phantom" IDs are NOT subagent dispatches — they are **Bash background-shell IDs** (Claude Code's `bash_id` format `b<9 alphanum>` returned when `Bash` tool is invoked with `run_in_background=true`). They will never appear in `agent-workspace/memory/dispatch.jsonl` (which logs Task/agent dispatches only). Confirmed: `grep "b30ko1l41|brnehzzip|bs0k226qo" agent-workspace/memory/dispatch.jsonl` → 0 matches.

Per session-jsonl trace at `C:\Users\PC\.ccs\instances\nathanleewindy\projects\C--htdocs-stockforge\<session_uuid>.jsonl`:

| Phantom ID | Originating session UUID | Originator timestamp | Task summary (assistant message) |
|---|---|---|---|
| `b30ko1l41` (FPT S240 Run #2) | `6cb5f5f7-2b4e-42f6-90f3-f7b5993ed6fd` | 2026-05-10T11:28:22Z | Assistant text: "S240 anti-flake run #2 dispatched — 5 parallel canonical CLI runs… FPT (sync pilot) | b30ko1l41" |
| `brnehzzip` (FPT S239) | `6cb5f5f7-...` (same) | 2026-05-10 ~08:14 UTC | S239 Run #1 fan-out |
| Notification echo `b30ko1l41` | `76f9cc94-3bcc-4e33-aa85-0ed0de72d750` | 2026-05-10T11:48:57Z | Task-completion attached as `<task-notification>` queue-operation |
| Output file path | `…\Temp\claude\C--htdocs-stockforge\a360e1cf-9578-4b42-a05d-cbc696797217\tasks\b30ko1l41.output` | — | Note the `a360e1cf-…` is a **third** session UUID (the actual TTY/CLI host). |

`grep -l "validate_thesis" *.jsonl | wc -l` → **69 different Claude Code sessions** invoked `validate_thesis.py` over the project history. For 2026-05-10, sessions seen running `validate_thesis`: at minimum `6cb5f5f7`, `76f9cc94`, `46fe371a-3026-40a9-a967-e30f8cc01d8f`, `a101199b-f55e-4369-a364-ce7b8c87ba13`, plus several others.

`agent-workspace/memory/.session-hooks.log` shows **30+ `continue-injector-spawn FIRED` events in a 17-minute window 18:38–18:55 today**, all `source=startup + autonomous_mode=true`. `agent-workspace/memory/handoff-logs/session-self-reboot-20260510*.log` → 5 reboot fires today (14:16, 14:17, 15:12, 18:28, plus `last-fire` marker stamp 18:28:44).

`scheduled_tasks.lock` content: single-instance lock `{"sessionId":"1fbbb246-77d7-43d7-9158-7912529d0f61", pid:18176, acquiredAt:1778340432174}` — **NOT a queue / NOT a cron entry**, just a session-mutex. No scheduled tasks defined.

`grep -rn "validate_thesis" .claude/ scripts/hooks/` → **zero hits in any hook**. `/usr/bin/crontab` not available (Windows). No Windows scheduled tasks call `validate_thesis`.

The actual `validate_thesis.py` invocation surface is `scripts/s236_probe_runner.py:95` (only invoked by `scripts/s236_probe_batch.py` or interactive session). No background autopilot.

## 2. Per-Hypothesis Verdict

| Hypothesis | Verdict | Evidence |
|---|---|---|
| **H1** — scheduled task / cron auto-fire | **FALSIFIED** | `scheduled_tasks.lock` is a session mutex, not a queue. `crontab` unavailable on Windows. No Windows-scheduled-task entries reference `validate_thesis`. Zero hooks invoke `validate_thesis`. |
| **H2** — Stop hook / SessionStart hook auto-dispatch | **FALSIFIED** | `grep -r "validate_thesis\|run_thesis\|--ticker" scripts/hooks/` → 0 hits. None of the 38 Stop hooks, 16 SessionStart hooks, 9 UserPromptSubmit hooks, 6 PreToolUse hooks, 5 PostToolUse hooks invoke `validate_thesis.py` or `s236_probe_*`. |
| **H3** — orch-starter cross-project automation | **FALSIFIED** | `grep -r "validate_thesis\|stockforge\|FPT\|CTG\|BVH" C:/htdocs/orch-starter` → only documentation hits in `agent-workspace/memory/observations/*` and `pnpm-lock.yaml`. No code path invokes StockForge's CLI. |
| **H4** — pre-/clear queue residue replayed | **FALSIFIED** | `grep -rn "validate_thesis" agent-workspace/` → only memory artifacts (reports, observations). No persistent queue file holds a `validate_thesis` command. The `continue-injector` only injects the literal string `"continue"`. |
| **H5** — multiple Claude Code sessions running concurrently, each autonomously firing the dogfood run | **VERIFIED** | (a) 14 distinct session-jsonl files contain `brnehzzip` (i.e., observed it via BashOutput / read its temp file); but the assistant-message that ORIGINATED `b30ko1l41` lives in session `6cb5f5f7` with text "S240 anti-flake run #2 dispatched — 5 parallel canonical CLI runs". (b) The notification for the same `b30ko1l41` arrives in DIFFERENT session `76f9cc94` 20 min later as a `<task-notification>` — confirming the bash subprocess outlived its originating session and was visible to a sibling. (c) The output dir is keyed to a THIRD session UUID `a360e1cf-...`. (d) `.session-hooks.log` shows >30 SessionStart firings in 17 min today, each spawning `continue-injector.ps1` which `SendKeys "continue"` into the front-most `claude.exe` window. (e) `budget-watchdog.sh:142,154` auto-fires `scripts/session-self-reboot.sh` at the 220K cliff which spawns a fresh `claude` process — and `current-execution.md` line 8 reads `**autonomous_mode**: true`. (f) `continue-injector.ps1` itself documents the multi-claude race in its `L-S48-1` comment block (line 80). |

## 3. Root Cause

**Mechanism**: Multiple Claude Code TUI windows running concurrently, all reading the same `agent-workspace/memory/current-execution.md` (which says `autonomous_mode: true` + active task = "Phase 4 Track A 5-ticker anti-flake dogfood run on FPT/CTG/BVH/GAS/BID"). Each session, when it (a) reaches its 220K cliff and auto-spawns a sibling via `scripts/session-self-reboot.sh`, or (b) gets a `continue` keystroke via the `continue-injector.ps1` SendKeys, faithfully resumes the same task and dispatches its own copy of the 5 background `validate_thesis.py` runs. Each instance considers ITSELF the parent; from the PARENT-of-record's perspective the OTHER instances' bash dispatches are "phantom".

**Originator code paths** (no single line is "the bug"; this is an emergent multi-process race):
- `scripts/hooks/continue-injector-spawn.sh:80-82` — `powershell.exe Start-Process … continue-injector.ps1`
- `scripts/hooks/continue-injector.ps1:39-78` — `Try-FocusClaudeTerminal` walks `Get-Process claude` and `SetForegroundWindow` → SendKeys "continue"
- `scripts/hooks/budget-watchdog.sh:137-154` — auto-fire `session-self-reboot.sh` on cliff (spawns fresh `claude` process)
- `agent-workspace/memory/current-execution.md:8` — `autonomous_mode: true` (gate that allows the above to fire on `source=startup`)

The dispatches are NOT phantom — they are real, originated by sibling Claude sessions that the parent-of-record has no awareness of.

## 4. Recommended Fix

This is a **process-coordination problem**, not a code bug. Three ordered options (recommend doing **A + B** together; defer C):

**A. Single-instance hard lock at SessionStart** (concrete proposal — DO NOT auto-apply)

Add to the SessionStart chain in `.claude/settings.json` (insert ABOVE `essential-routing-fields-verifier.sh` at line 148-150) a new hook `scripts/hooks/single-claude-instance-lock.sh`:

```bash
#!/usr/bin/env bash
# single-claude-instance-lock.sh — HARD-BLOCK SessionStart if another claude.exe already holds the project lock.
set -uo pipefail
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOCK="$PROJECT_DIR/agent-workspace/memory/.claude-instance.lock"
SELF_PID="${CLAUDE_PID:-$PPID}"
if [ -f "$LOCK" ]; then
  HOLDER_PID="$(awk -F: '{print $2}' "$LOCK" 2>/dev/null)"
  if [ -n "$HOLDER_PID" ] && tasklist //FI "PID eq $HOLDER_PID" 2>/dev/null | grep -qi "claude.exe"; then
    echo "[BLOCK] Another claude.exe (pid=$HOLDER_PID) holds $LOCK. Refusing autonomous-continue spawn."
    export STOCKFORGE_AUTONOMOUS_DISABLE=1
    exit 2
  fi
fi
echo "session=${CLAUDE_SESSION_ID}:${SELF_PID}:$(date +%s)" > "$LOCK"
trap 'rm -f "$LOCK"' EXIT
exit 0
```

Then in `continue-injector-spawn.sh:67-72`, gate with `[ "${STOCKFORGE_AUTONOMOUS_DISABLE:-0}" = "1" ] && exit 0`.

Note: the trap-on-EXIT cleanup only fires if SessionStart hook process exits cleanly; in practice you'll want the SessionEnd hook to remove the lock as well. Add a parallel one-liner to the SessionEnd chain.

**B. User-facing pre-flight check** (executable one-liner — ACCEPTANCE-CRITERION 4)

Before any controlled S242+ dogfood run, parent runs:
```bash
tasklist //FI "IMAGENAME eq claude.exe" 2>/dev/null | grep -ci "^claude.exe"
```
This must return **`1`** (only the running parent). If it returns `>1`, abort dogfood and kill sibling `claude.exe` PIDs first. Pair with a SQLite snapshot to confirm baseline: `sqlite3 data/stockforge.sqlite "SELECT COUNT(*) FROM theses WHERE created_at >= datetime('now','-1 hour');"` should return 0 immediately before run-start.

**C. (DEFER — out of scope for this incident)** Disable `autonomous_mode` per-instance via env, leaving the file flag on for the canonical primary. This is what `STOCKFORGE_AUTONOMOUS_DISABLE` from option A achieves.

## 5. Severity

**HIGH** (downgraded from BLOCKING).

Rationale for HIGH: phantom dispatches corrupt cost telemetry (~10 dispatches × $1-2 each = $10-20 surplus per dogfood window), produce ghost SQLite UPSERT collisions (S240 BVH × 2 attempts both validation-exhausted writing to same `thesis_id`), and made S239's "BVH 5-cat PASS" non-replicable in S240. They DO NOT corrupt production code, charter, or constitution.

Rationale against BLOCKING: the dispatches are real and well-formed. The problem is *attribution* (which session counts as canonical) and *amplification* (parallel-fanout magnifies bear-timeout cascade per L-S240-1). Fixing single-instance lock removes amplification and attribution ambiguity in one shot.

## 6. Pre-Flight Check for Next Dogfood Run (S242+)

Bash one-liner the parent can paste to verify NO phantom dispatch will fire:

```bash
PROC=$(tasklist //FI "IMAGENAME eq claude.exe" 2>/dev/null | grep -ci "^claude.exe"); BASELINE=$(sqlite3 C:/htdocs/stockforge/data/stockforge.sqlite "SELECT COUNT(*) FROM theses WHERE created_at >= datetime('now','-15 minutes');" 2>/dev/null); RECENT_REBOOT=$(find C:/htdocs/stockforge/agent-workspace/memory/handoff-logs/ -name "session-self-reboot-*.log" -mmin -10 2>/dev/null | wc -l); echo "claude_processes=$PROC (must=1)  recent_thesis_writes_15min=$BASELINE (must=0)  recent_reboots_10min=$RECENT_REBOOT (must=0)"; [ "$PROC" = "1" ] && [ "${BASELINE:-1}" = "0" ] && [ "${RECENT_REBOOT:-1}" = "0" ] && echo "GREEN: safe to dispatch S242 dogfood" || echo "RED: phantom-dispatch risk — investigate before run"
```

Acceptance: `claude_processes=1`, `recent_thesis_writes_15min=0`, `recent_reboots_10min=0`, terminal prints `GREEN`.

---

## Parent-session pre-flight check executed at 12:30 UTC

Result: `claude_processes=1  recent_thesis_writes_15min=  recent_reboots_10min=0` — **GREEN at this instant** (single canonical claude.exe; no recent thesis writes; no recent reboots). Sibling instances that fired phantom dispatches earlier today have since exited.

## Parent-session staged actions (S241b close)

1. **STAGED — NOT yet wired**: `scripts/hooks/single-claude-instance-lock.sh` created at the path the drift-detector specified. The hook content matches the drift-detector recommendation verbatim. **Wiring into `.claude/settings.json` SessionStart chain is DEFERRED to user approval** per drift-detector "DO NOT auto-apply" caution + CLAUDE.md "actions visible to others or that affect shared state… by default ask for confirmation before proceeding."
2. **DOCUMENTED**: this observation file persisted as canonical RC report.
3. **NEXT**: parent dispatches S242 sandwich-dev (already in flight at architect dispatch time) for D-054 IMPL on bear/quant retry — independent of this harness fix per architect § f. S244 LIVE 5-ticker re-run remains BLOCKED until both (a) D-054 lands (S243 verifier) and (b) settings.json wired with single-instance lock + pre-flight check passes GREEN.

## Files referenced (absolute paths — verbatim from drift-detector report)

- `C:\htdocs\stockforge\agent-workspace\memory\dispatch.jsonl`
- `C:\htdocs\stockforge\agent-workspace\memory\.session-hooks.log`
- `C:\htdocs\stockforge\agent-workspace\memory\handoff-logs\session-self-reboot-20260510*.log`
- `C:\htdocs\stockforge\agent-workspace\memory\.session-self-reboot-last-fire`
- `C:\htdocs\stockforge\agent-workspace\memory\current-execution.md` (line 8 = `autonomous_mode: true`)
- `C:\htdocs\stockforge\agent-workspace\memory\observations\track-A-S239-anti-flake-run1.md`
- `C:\htdocs\stockforge\agent-workspace\memory\observations\track-A-S240-anti-flake-run2.md`
- `C:\htdocs\stockforge\.claude\settings.json` (lines 138-216 SessionStart chain; line 213 `continue-injector-spawn.sh`)
- `C:\htdocs\stockforge\.claude\scheduled_tasks.lock` (single-instance mutex; not a queue)
- `C:\htdocs\stockforge\scripts\hooks\continue-injector-spawn.sh` (lines 76-99 platform-detached SendKeys spawn)
- `C:\htdocs\stockforge\scripts\hooks\continue-injector.ps1` (lines 39-80; documents L-S48-1 multi-claude race)
- `C:\htdocs\stockforge\scripts\hooks\budget-watchdog.sh` (lines 137-154 auto-fire reboot at cliff)
- `C:\htdocs\stockforge\scripts\session-self-reboot.sh` (line 75 powershell.exe spawn)
- `C:\htdocs\stockforge\scripts\s236_probe_runner.py` (line 95 = the only validate_thesis subprocess invocation point)
- `C:\Users\PC\.ccs\instances\nathanleewindy\projects\C--htdocs-stockforge\6cb5f5f7-3026-…jsonl` (originator session for `b30ko1l41`)
- `C:\Users\PC\.ccs\instances\nathanleewindy\projects\C--htdocs-stockforge\76f9cc94-…jsonl` (notification-receiving sibling session)
