---
observation_id: sandwich-dev-S246-B-strategy-f-fix
type: dev-delivery
created_at: 2026-05-10
session: S246-B
severity: INFO
status: DELIVERED
related:
  - agent-workspace/session-plans/pending/S246-lock-pid-secondary-fix-plan.md
  - agent-workspace/memory/observations/sandwich-dev-S246-A-probe-ship.md
  - agent-workspace/memory/observations/lock-rc-probe-20260510-221147-1058996.txt
  - scripts/hooks/single-claude-instance-lock.sh
  - scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh
---

# S246-B — Strategy (f) implementation: single-claude-instance-lock.sh fix

## Strategy selected: (f) — composite

**Evidence from probe (lock-rc-probe-20260510-221147-1058996.txt, fired during actual SessionStart):**

- Line 8: `hook_ppid=1` — confirmed PPID=1 in real spawned context. Strategy (c) ancestor-walk FAILS.
- Lines 10-55: `ps -ef` shows all hook bash scripts with PPID=1; no claude.exe in ancestor chain. Strategy (c) definitively dead.
- Lines 91-98: stdin JSON parsed fields — `pid=""`, `ppid=""`, `parent_pid=""`, `process_id=""`. No pid field at all. Strategy (e) stdin-pid FAILS for self-identification.
- Line 91: `session_id="f912562b-4e48-4818-96ec-65ff4f19a08b"` — session_id IS reliable in stdin JSON.
- Lines 61-64: `tasklist //V` lists 4 live claude.exe PIDs (18176, 37136, 11540, 21048). Strategy (f) tasklist-based PID collection VIABLE.
- `ALL_KEYS=["session_id","transcript_path","cwd","hook_event_name","source"]` — confirmed: no pid/ppid key in SessionStart JSON payload.

**Conclusion**: Strategy (f) selected as planned. Session_id extracted from stdin JSON (partially implementing Strategy (e) for the identity field only).

## Tasks completed

- [x] TASK 1 — Probe wiring reverted from .claude/settings.json
- [x] TASK 1 — lock-rc-probe.sh header updated: "DIAGNOSTIC ONLY — not wired by default"
- [x] TASK 1 — settings.json JSON validity confirmed: `python -c "import json; json.load(open('.claude/settings.json')); print('JSON valid')"` → `JSON valid`
- [x] TASK 2 — Strategy (f) implemented in scripts/hooks/single-claude-instance-lock.sh
- [x] TASK 3 — Firing-test extended: TC1-TC8 all PASS; PENDING TC3 promoted to EXECUTABLE
- [x] TASK 4 — Manual smoke: exit 0, lock in new format confirmed
- [x] TASK 5 — This observation file

## Files modified

| File | Change |
|---|---|
| `scripts/hooks/single-claude-instance-lock.sh` | Full rewrite of lines 15-33 (hook logic). Header comment block updated. ~145 LOC (was 33 LOC). |
| `scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh` | Full rewrite. 8 TCs (was 3 PASS + 1 PENDING). ~250 LOC (was 175 LOC). |
| `.claude/settings.json` | Removed probe hook entry (4-line block). Restored to pre-S246-A state. |
| `scripts/hooks/lock-rc-probe.sh` | Header comment block updated only (lines 1-22). No behavioral change. |
| `agent-workspace/memory/observations/sandwich-dev-S246-B-strategy-f-fix.md` | This file (new). |

## Test results

### Single-hook firing-test
```
=== single-claude-instance-lock-fire-test: PASS=8 FAIL=0 ===
    TCs: 8/8
    TC coverage: TC1(first-run) TC2(stale-csv) TC3(live-sibling-BLOCK) TC4(cleanup) TC5(stale-by-time) TC6(S244-compat) TC7(stdin-session_id) TC8(partial-die)
```

TC count: was 3 PASS + 1 PENDING → now 8 PASS + 0 PENDING. Net +5 new TCs.

### Full suite regression
```
=== firing-test suite: 88/88 PASS (elapsed 233s) ===
```

Zero regression across all 88 firing-tests (the +8 TCs in single-claude-instance-lock-fire-test count was already in the 88 baseline — the existing script was 1 file that counted as 1 test in run-all.sh, still 1 file now).

### bash-hook-lint
Exit: 0 (clean — no new L-S48m-1 / L-S108-1 / L-S53-2 violations)

## Manual smoke evidence

Command: `CLAUDE_PROJECT_DIR=/c/htdocs/stockforge bash scripts/hooks/single-claude-instance-lock.sh < /dev/null`

Exit code: `0`

Lock file content: `claude_pids=18176:created=1778426682:session_id=unknown`

Structure confirmed: 3 colon-separated fields matching format `claude_pids=<csv>:created=<epoch>:session_id=<sid>`.

`session_id=unknown` expected: dev-shell invocation has no stdin JSON. In real SessionStart, session_id will be populated from stdin JSON (confirmed by TC7: `session_id=abc-123` with synthetic JSON input).

`claude_pids=18176` — one live claude.exe in this dev-shell context (the running Claude Code TUI). In real multi-window scenario, all live claude.exe PIDs would appear (confirmed by probe lines 61-64 showing 4 PIDs).

Note: exit 0 here is correct. BLOCK fires only when `|current_pids| > |stored_pids|` (new claude.exe spawned after lock was written). The single-window smoke cannot produce BLOCK by definition — a second real claude.exe window would be needed to trigger it.

## Lock format change (S244 → S246)

| Field | S244 format | S246 format |
|---|---|---|
| Key prefix | `session=` | `claude_pids=` |
| PID storage | single PID (proven unreliable: was always 1) | CSV of all live claude.exe PIDs at lock-create time |
| Epoch | field 3 (`:`) | `created=<epoch>` |
| Session identity | field 1 (CLAUDE_SESSION_ID — empty on Windows) | `session_id=<from-stdin-JSON>` |

## Backward-compat note for existing S244-format locks on disk

Any `.claude-instance.lock` written by the S244-era hook (format: `session=X:Y:Z`) will be auto-detected and treated as stale on next SessionStart. Detection: lock content does NOT start with `claude_pids=`. The hook overwrites without BLOCK. No manual intervention required. This is the correct behavior: S244-format locks cannot be trusted (PID was always 1 = useless for liveness check), so treating them as stale is strictly safer than blocking on them.

## Block mechanism validation

TC3 confirms BLOCK fires correctly:
- Stored lock: `claude_pids=12345,67890:created=<60s ago>:session_id=stored-session`
- Mock tasklist returns 3 PIDs: 12345, 67890, 88888
- `current_count(3) > stored_count(2)` → new claude.exe is us; stored PIDs 12345+67890 are live siblings → BLOCK
- Stderr: `[BLOCK] live claude.exe holder(s)=12345,67890 in lock; created 60s ago. Refusing autonomous-continue spawn.`
- Exit: 2

## Handoff notes

### Queued work (not in this session's scope)
1. **RUN2 anti-flake re-run**: 5-ticker LIVE re-run gating. The lock fix is a precondition (now landed). Actual re-run should be queued for next appropriate IMPL session.
2. **Promote-rule cycle for L-S245+-2/3**: per agent-notes.md line 24, these lesson candidates need a promote-rule subagent dispatch. The S246 plan §6.3 explicitly deferred this. Still outstanding.
3. **In-session parallel subagent dispatch race**: plan §7.4 out-of-scope item — per-subagent unique observation paths. Separate fix tracked as S246+ harness queue item.
4. **Two-window live smoke**: manual BLOCK verification requires user to open a second claude.exe in the same project and observe `[BLOCK] ...` in the second window's SessionStart hook output. This is the PEND-USER acceptance criterion from plan §5 Task 5.4. TC3 mock-based verification is the automated proxy.

### No production code touched
This session modified harness-only files (scripts/hooks/, .claude/settings.json, agent-workspace/memory/). No packages/ or application code modified.

### Session plan status
Plan `S246-lock-pid-secondary-fix-plan.md` is fully executed:
- [x] Probe ran; artifact at observations/lock-rc-probe-20260510-221147-1058996.txt (Task 1 — S246-A)
- [x] Probe wiring reverted; settings.json restored (Task 2 — this session)
- [x] Hook rewritten with Strategy (f); comment block updated; bash-hook-lint clean (Task 3 — this session)
- [x] Firing-test has 8 PASS / 0 FAIL / 0 PENDING; full suite regression-clean (Task 4 — this session)
- [~] Manual 2-window smoke confirmed BLOCK fires (Task 5 — PEND-USER; TC3 is automated proxy)
- [x] Dev observation written (Task 5 — this file)
- [x] No production code touched
- [x] No commit made
