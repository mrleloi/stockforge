---
plan_id: S246-lock-pid-secondary-fix
type: PLAN
created_at: 2026-05-10
created_by: sandwich-architect (S245 fresh-context)
target_session: S246 (FOCUSED IMPL)
phase: 3.5 (harness hardening)
priority: HIGH (phantom-dispatch protection still functionally broken post-S244)
related: 
  - agent-workspace/memory/observations/2026-05-10-S245-lock-pid-secondary-defect.md
  - agent-workspace/memory/observations/sandwich-dev-S244-lock-trap-fix.md
  - agent-workspace/memory/observations/2026-05-10-S243-parallel-finding-lock-trap-bug.md
status: PENDING
---

# S246 — single-claude-instance-lock secondary defect (holder PID = 1, session = unknown) — fix plan

> Author note: this is a PLAN. S246 sandwich-dev executes it. No code is written here.

---

## 1. Root-cause restatement (empirical)

### 1.1 What the post-S244 hook actually wrote at runtime

`agent-workspace/memory/.claude-instance.lock` (live file, captured at 21:32+07:00 by S245 — see observation `2026-05-10-S245-lock-pid-secondary-defect.md` lines 17-18):

```
session=unknown:1:1778421770
```

Format per `scripts/hooks/single-claude-instance-lock.sh:31`:
```bash
echo "session=${CLAUDE_SESSION_ID:-unknown}:${SELF_PID}:$(date +%s)" > "$LOCK"
```

Thus empirically:
- `CLAUDE_SESSION_ID` env var → empty → fallback `unknown` fired.
- `SELF_PID = ${CLAUDE_PID:-$PPID}` (line 20) → resolved to `1`. Therefore both `CLAUDE_PID` was empty AND `$PPID` of the bash hook script was `1`.

### 1.2 Why this defeats BLOCK detection

`scripts/hooks/single-claude-instance-lock.sh:22-28`:
```bash
if [ -f "$LOCK" ]; then
  HOLDER_PID="$(awk -F: '{print $2}' "$LOCK" 2>/dev/null)"
  if [ -n "$HOLDER_PID" ] && tasklist //FI "PID eq $HOLDER_PID" 2>/dev/null | grep -qi "claude.exe"; then
    echo "[BLOCK] ..."
    export STOCKFORGE_AUTONOMOUS_DISABLE=1
    exit 2
  fi
fi
```

With `HOLDER_PID=1`:
- `tasklist //FI "PID eq 1"` returns Windows kernel processes (System Idle Process / System), never `claude.exe`.
- `grep -qi "claude.exe"` → false → BLOCK does NOT fire.
- Subsequent claude.exe overwrites lock at line 31, proceeds. Phantom-dispatch protection bypassed.

### 1.3 Provenance for "CLAUDE_SESSION_ID empty on Windows"

This is NOT a guess — it is established with explicit evidence in three places:

- `scripts/hooks/profile-template-auto-populate.sh:38` (comment): "$CLAUDE_SESSION_ID env (which is empty in **174/174 SessionStart events** on Windows Claude Code 4.x; auto-populate residue investigation finding)."
- `agent-workspace/memory/agent-notes.md:547` — L-S48m-1 ACTIVE: "Per-session-marker hooks NOT use $CLAUDE_SESSION_ID env on Windows" (HIGH severity).
- `agent-workspace/memory/agent-notes.md:591` — L-S108-1 ACTIVE: "${CLAUDE_SESSION_ID:-WORD} → empty on Windows → fallback 'WORD' shared across all sessions → permanent idempotency lockout."
- `scripts/hooks/dispatch-jsonl-recorder.sh:104-110` — explicitly documents this and uses **stdin JSON `SESSION_ID`** instead. This is the canonical workaround pattern in this repo.
- Live evidence: `agent-workspace/memory/.session-hooks.log:26` shows `Stop session=` (empty value) — direct empirical reproduction.

### 1.4 What is NOT yet established

- WHY `$PPID == 1` inside the bash hook subprocess — three plausible RC paths (S245 observation lines 47-50):
  - (a) Claude Code TUI on Windows spawns hook bash with `setsid` / `nohup` style detach.
  - (b) Claude Code uses a Windows job-object pattern that orphans the bash subprocess.
  - (c) The intermediary launcher (e.g. git-bash → bash.exe wrapper) re-parents to PID 1 (init / systemd-equivalent / git-bash session leader).
  - **Without knowing which**, any "use `$PPID`" or "walk parent chain" mitigation is speculative.

This uncertainty is why **Section 2 (Investigation) MUST run before Section 5 (Implementation).**

---

## 2. Investigation step (BEFORE fix) — probe script

### 2.1 Goal

Empirically determine, on real Claude Code on Windows, what process-tree state the hook subprocess actually has access to. Output is a written artifact that captures:

| Signal | Source | Why it matters |
|---|---|---|
| `$$` | bash hook | The hook's own PID |
| `$PPID` | bash hook | What S245 saw as `1` — confirm |
| `ps -ef` snapshot | git-bash builtin | Walk upward to find a `claude.exe` ancestor (if any) |
| `tasklist //V` (no filter) | Windows | Authoritative live `claude.exe` PID(s) and command line(s) |
| `wmic process where "name='claude.exe'" get ProcessId,ParentProcessId,CommandLine` | Windows fallback | Parent-of-claude.exe (may be `cmd.exe` or VS Code terminal) |
| All env vars matching `CLAUDE_*` / `STOCKFORGE_*` / `SESSION*` | bash hook | Discover any populated identity var the TUI does export |
| stdin JSON payload (full) | bash hook | `dispatch-jsonl-recorder.sh:109` already proves `SESSION_ID` is reliably in stdin JSON; want to confirm `pid`/`ppid`/`hook_event_name` fields too |

### 2.2 Probe deliverable (NOT a fix — diagnostic only)

**File**: `scripts/hooks/lock-rc-probe.sh` (NEW, temporary diagnostic).

**Behavior**: Runs identically to `single-claude-instance-lock.sh` but writes a richer diagnostic file to `agent-workspace/memory/observations/lock-rc-probe-<timestamp>.txt` containing all signals from §2.1 above. Does NOT touch the real lock file.

**Wiring**: temporarily added as a SessionStart hook line in `.claude/settings.json` IMMEDIATELY BEFORE the existing `single-claude-instance-lock.sh` line (line 148).

**Trigger run**: User opens 2 claude.exe windows in the same project. Each will fire SessionStart. Two diagnostic files appear (one per window). Compare.

### 2.3 Decision rule from probe output

| Probe finding | Implication for fix |
|---|---|
| `ps -ef` reveals a `claude.exe` ancestor (any depth) | Mitigation (c) — walk ps -ef upward — is viable + cheap |
| stdin JSON contains a usable `pid` / `parent_pid` / `process` field | Best signal; use stdin (cheapest, most reliable, no Windows-shell dep) |
| Neither — only `tasklist` shows claude.exe but no parent linkage from hook context | Fall back to mitigation (a): record ALL claude.exe PIDs in lock; BLOCK if any of them is alive other than self |
| `$PPID` actually != 1 in fresh-window case but == 1 in subagent-spawn case | Confirms RC = subagent_transport `subprocess.run(["claude","-p",...])` detach; spawn-context probe path needed |

### 2.4 Probe budget

~30 LOC bash + 1 settings.json edit (additive line). Manual revert of settings.json once probe data captured. **MUST be reverted before S246 PRIORITY 1 hook fix lands** to avoid noisy production hook chain.

---

## 3. Mitigation strategies evaluated

The S245 observation listed 4 candidates (a)-(d). I add (e), (f), (g) below derived from the probe targets and existing repo patterns.

### 3.1 Strategy (a) — record ALL claude.exe PIDs at lock-create; check ANY-alive-other-than-self at lock-read

**Mechanism**:
- Lock-create writes `claude_pids=<csv>:created=<epoch>:session=<sid_or_unknown>` where csv comes from `tasklist //FI "IMAGENAME eq claude.exe" //NH //FO CSV` parsed for PID column.
- Lock-read parses the csv. Compares against current live `tasklist`. If ANY listed PID is still alive AND that PID is not the only/current claude.exe, BLOCK.
- "Self" is identified as: the most-recently-created claude.exe (max start-time from tasklist `//V` output) — since each new SessionStart implies a new claude.exe was just spawned.

**Cost**: ~25 LOC additional (tasklist parse + csv compare).

**Reliability vs Windows quirks**:
- (+) Does NOT depend on `$PPID` or `CLAUDE_PID` env (both proven unreliable).
- (+) Does NOT depend on `CLAUDE_SESSION_ID` env (proven empty).
- (+) `tasklist //NH //FO CSV` is stable on Windows 10+ (used elsewhere in repo, e.g. `single-claude-instance-lock.sh:24`).
- (-) Race window: two claude.exe spawned within the same `tasklist` polling tick both see each other AND both fail to identify "self". Mitigation: include `$$` (bash hook PID) + start time as tiebreaker; or use `wmic` for sub-second start time.
- (-) `tasklist` cost ~150-300ms on Windows — acceptable for SessionStart (one-shot).

**Test fixture**:
- TC3-replacement: in firing-test, mock `tasklist` via PATH override to a stub script that returns synthesized CSV with two PIDs. Stub script is created in sandbox, prepended to PATH only for the hook invocation. Removes the "REQUIRES_TASKLIST" pending status of S244 TC3.

**Acceptance criteria**:
- Two-window manual smoke: 2nd window's SessionStart prints `[BLOCK] ...` + exit 2. Lock content is parseable as csv.
- TC3 (synthesized): hook with mocked tasklist returning 2 PIDs in lock + 2 PIDs in current tasklist → BLOCK fires.
- TC5 (NEW): hook with mocked tasklist returning 2 PIDs in lock + only 1 PID in current tasklist (older one died) → no BLOCK; lock overwritten.

### 3.2 Strategy (b) — alternate identity signal (ETW / job object / persistent UUID)

**Mechanism**: At first SessionStart of a TUI install, generate a persistent `<install-uuid>` and embed it as an env var via shell rc / Claude config. Hook compares incoming uuid vs lock-stored uuid.

**Cost**: ~50 LOC + a separate config-write hook + risk of polluting user shell rc.

**Reliability**: HIGH if it works, but requires user-side config that we don't control. If user wipes shell rc, system breaks silently.

**Test fixture**: very hard — requires multi-shell-rc fixture.

**Acceptance**: REJECTED. Too invasive; relies on user-side persistence we cannot guarantee.

### 3.3 Strategy (c) — `ps -ef` ancestor walk to find claude.exe parent

**Mechanism**: From the bash hook, run `ps -ef` (git-bash builtin). Walk parent-PID chain upward. If any ancestor's CMD column contains `claude.exe`, use that ancestor's PID as `SELF_PID`. Else fallback to `tasklist` lookup.

**Cost**: ~15 LOC.

**Reliability vs Windows quirks**:
- (+) `ps -ef` is portable across git-bash + WSL.
- (?) Conditional on probe §2.3 showing `claude.exe` actually appears as ancestor in the hook process tree. **If `$PPID == 1` because Windows job-object detach, then ps -ef chain ALSO terminates at 1** — strategy fails silently.
- (-) Subagent-spawn case (claude --print called from subagent_transport.py at `packages/infrastructure/analysis/subagent_transport.py:12`) likely detaches the spawned claude.exe to be its own session leader — chain to ancestor parent claude.exe may not exist.

**Test fixture**: probe-dependent. Cannot author firing-test until §2 confirms ps -ef actually surfaces claude.exe.

**Acceptance**: CONDITIONAL on probe results. Use ONLY if §2.3 shows ancestry exists.

### 3.4 Strategy (d) — staleness via timestamp instead of liveness check

**Mechanism**: Lock has epoch timestamp (already does, field 3). On lock-read, if `now - lock_epoch < THRESHOLD_SECONDS` (e.g. 7200 = 2h), BLOCK regardless of whether holder PID is verifiable. Otherwise treat as stale + overwrite.

**Cost**: ~10 LOC.

**Reliability**:
- (+) ZERO Windows-specific deps. Pure POSIX `date +%s` + arithmetic.
- (+) Works in spawned/detached contexts identically.
- (-) **False BLOCK risk**: legitimate fresh window opened 30 min after first session ended (without going through SessionEnd cleanup, e.g. crash) gets BLOCKED until threshold expires. Annoying but recoverable (user deletes lock manually).
- (-) Threshold tuning is hand-wavy: too short → false negatives (real phantom dispatch slips through); too long → user friction on crash recovery.
- (+) `SessionEnd` hook at `.claude/settings.json:239` already deletes lock on clean shutdown — staleness only matters for crash paths.

**Test fixture**: trivial. Pre-write lock with epoch = now-100 (TC: BLOCK fires), epoch = now-9000 (TC: stale → overwrite).

**Acceptance**: STRONG candidate as PRIMARY guard or as DEFENSE-IN-DEPTH alongside (a).

### 3.5 Strategy (e) — stdin JSON `SESSION_ID` + `pid` (NEW — derived from existing repo pattern)

**Mechanism**: Mirror what `scripts/hooks/dispatch-jsonl-recorder.sh:104-111` already does for the dispatch sidecar:
- Read stdin JSON (Claude Code passes JSON to hooks via stdin; documented behavior).
- Extract `SESSION_ID` and any `pid` / `process_id` field that's reliably present.
- Use those as lock identity.

**Cost**: ~10 LOC (stdin read + JSON parse — repo already has node-based parser pattern at `dispatch-jsonl-recorder.sh:103,135`).

**Reliability**:
- (+) `dispatch-jsonl-recorder.sh:107` (comment) explicitly says: "JSON payload reliably populates session_id for Agent / SubagentStop hooks". This is the canonical workaround pattern in this codebase.
- (?) Unknown whether SessionStart payload (vs SubagentStop payload) contains `pid`. **Probe §2.1 must confirm.**
- (+) If confirmed, this is the cleanest fix — uses TUI's own authoritative state.

**Test fixture**: feed synthesized JSON `{"session_id":"abc","pid":99999}` via stdin to firing-test. Trivial.

**Acceptance**: STRONG candidate IF probe confirms `pid` is in stdin. Minimal LOC; aligns with existing L-S108-1 mitigation pattern.

### 3.6 Strategy (f) — write-side enrichment + read-side liveness via tasklist by IMAGENAME (NEW)

**Mechanism**: Combine (a) + (d):
- WRITE: lock = `claude_pids=<all-claude-pids-csv>:created=<epoch>`.
- READ: if `now - created < THRESHOLD` AND any `tasklist //FI "IMAGENAME eq claude.exe"` row exists with PID different from current bash-hook-window's claude (identified by max-start-time tiebreaker), BLOCK.

**Cost**: ~30 LOC.

**Reliability**: HIGHEST — combines liveness signal (tasklist) with staleness floor (timestamp). Defense in depth: even if tiebreaker fails, threshold catches.

**Test fixture**: tasklist mock + epoch-controlled fixture. ~100 LOC firing-test additions across 5-6 TCs.

**Acceptance**: RECOMMENDED PRIMARY (see §4).

### 3.7 Strategy (g) — file-locking primitive (POSIX `flock` on git-bash) (NEW)

**Mechanism**: Use `flock -n -x <lockfd>` to acquire an exclusive non-blocking lock on the file. If acquisition fails, BLOCK. Lock auto-releases on process exit (kernel-managed).

**Cost**: ~5 LOC.

**Reliability**:
- (+) Kernel-managed; NO PID/SID semantics needed.
- (-) **`flock` does NOT exist in git-bash on Windows** by default. Verified absence: `flock` is a util-linux binary, not bundled with msys/git-bash. Would require user to install procps/util-linux-msys.
- (-) Even if installed, behavior on Windows file system semantics is unreliable (NTFS file locks vs POSIX advisory locks are different beasts).

**Acceptance**: REJECTED. Not portable to the deployment platform.

---

## 4. Recommended strategy + counter-arguments

### 4.1 Recommendation

**Primary**: Strategy (f) — composite of (a) write all claude.exe PIDs + (d) timestamp-staleness floor.

**Conditional override**: If probe §2.3 confirms stdin JSON contains a usable `pid` field for SessionStart events, **upgrade to Strategy (e)** as primary (use stdin pid for self-identification; still write all-PIDs csv for sibling detection).

**Reject**: (b), (c)-unconditional, (g).

### 4.2 Why (f) over (a)-alone or (d)-alone

| Failure mode | (a) alone | (d) alone | (f) composite |
|---|---|---|---|
| `tasklist` returns stale info during race window | False negative possible | Caught by threshold | Caught by threshold |
| Threshold tuning wrong (too long) | n/a | False BLOCK on legit fresh window | Mitigated: tasklist confirms no live sibling → no BLOCK |
| Threshold tuning wrong (too short) | n/a | False negative on real phantom | Mitigated: tasklist liveness still catches |
| `tasklist` unavailable (e.g. user disabled WMI) | Total failure | Still works | Degrades gracefully to (d) |

(f) is strictly more robust at the cost of ~15 extra LOC over (a).

### 4.3 Counter-arguments — when (f) is wrong

1. **If probe shows stdin pid IS reliable** → (e) is simpler, more authoritative, ~20 LOC saved. Override.
2. **If user runs in environment without `tasklist` (e.g. WSL-only)** → (d) alone is the right call. Add `command -v tasklist >/dev/null || THRESHOLD_ONLY_MODE=1` branch.
3. **If two-window concurrency is decided to be supported (not blocked)** → entire hook concept is wrong; rip it out. Per `agent-workspace/memory/observations/2026-05-10-S243-parallel-finding-lock-trap-bug.md` AMENDMENT (line 67-78), the design intent IS to block. So this counter-argument does not apply currently.
4. **If `tasklist //FI "IMAGENAME eq claude.exe"` returns the spawned `claude -p` subagent process** (which IS a claude.exe instance) → spurious BLOCK on every subagent dispatch. **Critical**: must filter by command-line containing `-p` / `--print` to exclude subagent spawns from sibling-detection. This filtering requires `tasklist //V` (verbose) and is a TC in §6.

### 4.4 Threshold value

Initial proposal: `LOCK_STALE_THRESHOLD_SECONDS=7200` (2h). Rationale:
- Typical session: 30-90 min.
- Wind-down at 180K tokens / cliff at 220K (per CLAUDE.md context-threshold band) → cap on session length is ~3h hard.
- 2h covers normal session + crash-recovery grace; below 3h hard cap so user doesn't sit-and-wait on legitimate fresh window after crash.
- Tunable via env var `STOCKFORGE_LOCK_STALE_SEC` (default 7200) — follows the `STOCKFORGE_*` env-var convention at `.claude/settings.json:127-135`.

---

## 5. Implementation tasks for S246 sandwich-dev (atomic, ≤5)

### Task 1 — Run probe (Section 2)

**Inputs**: none.

**Actions**:
1.1 Write `scripts/hooks/lock-rc-probe.sh` (~30 LOC) that captures the §2.1 signal table to `agent-workspace/memory/observations/lock-rc-probe-<epoch>.txt`. Read stdin JSON with same node-extract pattern as `dispatch-jsonl-recorder.sh:135-145`.
1.2 Add to `.claude/settings.json` SessionStart chain at line 147 (BEFORE single-claude-instance-lock.sh) — additive, single new entry block.
1.3 Output a short README at the probe artifact path documenting "ran S246 probe; revert settings.json after manual 2-window run".
1.4 Wait for user to run 2-window manual reproduction and confirm probe artifact landed.

**Verify**: probe artifact file exists and contains all §2.1 signals; user confirms 2 distinct files (one per window) captured.

**Deliverable**: at minimum, a written confirmation in the eventual S246 session log of which strategy ((e) or (f)) is selected based on probe data.

**Commit boundary**: COMMIT 1 = probe addition (revertible).

### Task 2 — Revert probe wiring

**Actions**:
2.1 Remove the line added to `.claude/settings.json` in Task 1.2.
2.2 Leave `lock-rc-probe.sh` in place at `scripts/hooks/lock-rc-probe.sh` for future reference but unwired.
2.3 Add comment block to `lock-rc-probe.sh` documenting "diagnostic only, NOT wired by default; re-wire only for RC investigation".

**Verify**: settings.json hash matches pre-Task-1 state for that section (mod the probe line removal); SessionStart chain length restored.

**Commit boundary**: COMMIT 2 = revert probe wiring.

### Task 3 — Implement chosen mitigation in `single-claude-instance-lock.sh`

**Inputs**: probe artifact from Task 1.

**Actions** (assuming Strategy (f) primary; if (e), substitute stdin parse for tasklist write):
3.1 Replace `single-claude-instance-lock.sh` lines 18-31 with:
   - Read `claude.exe` PIDs via `tasklist //NH //FO CSV //FI "IMAGENAME eq claude.exe"` (or stdin pid if (e)).
   - Filter out claude subagent spawns (rows where command-line contains `-p` / `--print` — requires `//V`). **ONLY if probe confirms tasklist //V output is parseable.**
   - On lock present:
     - Parse `claude_pids` csv from lock. Parse `created` epoch.
     - If `now - created > STOCKFORGE_LOCK_STALE_SEC` → treat as stale; overwrite + exit 0.
     - Else compute current_live_pids ∩ lock_claude_pids minus self_pid. If non-empty → BLOCK + exit 2.
     - Else (lock holder PIDs are all dead OR only self) → overwrite + exit 0.
   - On lock absent: write fresh.
3.2 New lock format: `claude_pids=<csv>:created=<epoch>:session=<sid_or_unknown>`. Note: schema CHANGE — old locks (S244 format) won't parse cleanly. Add backward-compat: if `awk -F: '{print $2}' "$LOCK"` returns a single integer (S244-format) instead of csv, treat as STALE (force overwrite). Document in comment block.
3.3 Update header comment block:
   - WIRING STATUS: WIRED (unchanged).
   - Add S246 fix-record line: "Fixed S246: holder-pid was unreliable (PPID=1 in spawned context, CLAUDE_PID/SESSION_ID empty on Windows per L-S48m-1/L-S108-1). Replaced with all-claude-pids csv + epoch staleness floor."
   - Add explicit Do-NOT list: "Do NOT use $PPID — unreliable in spawn paths. Do NOT use $CLAUDE_SESSION_ID without empty-fallback handling — empty in 174/174 SessionStart events on Windows per L-S48m-1."

**Verify**: 
- ShellCheck clean on the modified file (per repo norm; bash-hook-lint.sh runs in CI).
- `bash-hook-lint.sh` passes (no L-S48m-1 / L-S108-1 / L-S53-2 violations).
- Hook exit status = 0 on first-run (no lock); = 2 on stale-but-fresh-sibling-alive; = 0 on truly-stale.

**Commit boundary**: COMMIT 3 = hook fix.

### Task 4 — Update firing-test to exercise BLOCK path with mock `tasklist`

**Inputs**: `scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh` (existing, S244 vintage, 139 LOC).

**Actions**:
4.1 Add helper at top of firing-test: `mock_tasklist <output_csv>` — writes a stub `tasklist` script in `$SANDBOX/bin/`, prepends `$SANDBOX/bin` to PATH for the hook invocation. Stub script reads its args and emits the supplied CSV on stdout. **This unblocks TC3 from "REQUIRES_TASKLIST PENDING" (S244 firing-test line 140).**
4.2 Replace TC3 PENDING with TC3 EXECUTABLE: pre-write lock with csv `12345,67890`; mock_tasklist returns CSV containing PID 12345 alive; assert hook exits 2 with `[BLOCK]` message.
4.3 Add TC5: stale-lock-by-time. Pre-write lock with `created = now - 10000` (older than 7200 default threshold); mock_tasklist still returns those PIDs alive; assert hook overwrites lock + exits 0 (staleness wins).
4.4 Add TC6: backward-compat. Pre-write lock in S244 format `session=abc:1:1234567890`. Mock tasklist returns no claude.exe rows. Assert hook treats as stale + overwrites with new csv-format + exits 0.
4.5 Add TC7: subagent-spawn-not-counted. Mock tasklist `//V` returns 2 claude.exe rows where one has `-p` in command-line (= subagent dispatch); other does not. Lock holds the non-`-p` PID. Hook should BLOCK on the parent claude.exe but ignore the `-p` subagent.
4.6 Update summary footer to count PASS/FAIL across 6 non-PENDING TCs (TC1-2-3-4-5-6-7); REMOVE the "PENDING=1 (TC3)" line.

**Verify**: firing-test exits 0 with `PASS=7 FAIL=0`. Full firing-test suite regression: 88+1 = should remain 88 with TC3 promoted from PENDING to PASS = same total file count, +N test cases passing.

**Commit boundary**: COMMIT 4 = firing-test enhancement.

### Task 5 — End-to-end smoke + handoff

**Actions**:
5.1 Run individual firing-test: `bash scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh`. Expect PASS=7 FAIL=0.
5.2 Run full firing-test suite: expect 88/88 PASS (or 89/89 if TC3-promotion adds a count).
5.3 Run `bash-hook-lint.sh`: expect no NEW violations introduced. (Pre-existing violations from `agent-workspace/memory/.session-hooks.log:1-12` are baseline.)
5.4 Manual 2-window smoke (asks user to run): open second claude.exe in same project, observe `[BLOCK] ...` printed, confirm exit code via `echo $?` in 2nd hook log.
5.5 Write S246 dev observation `agent-workspace/memory/observations/sandwich-dev-S246-lock-pid-fix.md` documenting:
   - Strategy chosen ((e) or (f)) and probe-data justification.
   - Files modified + LOC delta.
   - Test results (firing-test, full suite, bash-hook-lint).
   - Manual smoke result (or PENDING-USER if user not yet run).
   - Schema migration impact (any pre-existing live `.claude-instance.lock` from S244 format → first SessionStart after S246 deploys auto-overwrites, no manual intervention required).

**Commit boundary**: COMMIT 5 = observation + any cleanup.

**No commit by agent unless user explicitly requests** (per CLAUDE.md hard rule).

---

## 6. Firing-test plan (consolidated)

### 6.1 TC matrix (post-S246)

| TC | Path | Source format | Mock tasklist returns | Expected exit | Expected lock state |
|----|------|--------------|----------------------|---------------|---------------------|
| TC1 | first-run | (no lock) | irrelevant | 0 | new lock written, csv format |
| TC2 | stale-lock-non-existent-pid | csv with PID 99999999 | empty (no claude.exe) | 0 | lock overwritten |
| TC3 | live-sibling-blocked | csv with PID `12345,67890`, fresh epoch | claude.exe at PID 12345 alive | 2 | lock UNCHANGED, `[BLOCK]` printed |
| TC4 | SessionEnd cleanup | (lock present) | n/a | n/a (not hook; cleanup cmd) | lock removed |
| TC5 | stale-by-time | csv with live PIDs, epoch=now-10000 | those PIDs alive | 0 | lock overwritten (time wins) |
| TC6 | S244-format backward-compat | `session=abc:1:1234567890` | empty | 0 | lock overwritten in csv format |
| TC7 | subagent-spawn-not-counted | csv with parent PID | 2 rows: parent + `-p` subagent | 2 (parent alive blocks) | lock UNCHANGED |

### 6.2 Mock-tasklist mechanism (key innovation over S244 firing-test)

S244 firing-test marked TC3 as `REQUIRES_TASKLIST` PENDING because: "no POSIX equivalent; impossible to synthesize without spawning real claude.exe" (`scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh:127-138`).

**S246 unblocks this** by PATH-shadowing `tasklist`:
```bash
mock_tasklist() {
  local output_csv="$1"
  mkdir -p "$SANDBOX/bin"
  cat > "$SANDBOX/bin/tasklist" <<'STUB'
#!/usr/bin/env bash
# Args ignored; echo fixture verbatim.
cat "$MOCK_TASKLIST_OUT"
STUB
  chmod +x "$SANDBOX/bin/tasklist"
  echo "$output_csv" > "$SANDBOX/.tasklist-mock-out"
  export MOCK_TASKLIST_OUT="$SANDBOX/.tasklist-mock-out"
  export PATH="$SANDBOX/bin:$PATH"
}
```

This works ONLY if hook invokes plain `tasklist` (not `/c/Windows/System32/tasklist.exe` absolute path). Verify hook does not absolute-path tasklist (current source line 24 uses bare `tasklist` — OK).

### 6.3 Spawned-claude-context TC (L-S245+-1 promotion candidate)

The S245 observation lines 65-71 propose lesson L-S245+-1: "harness firing-tests must run in spawned-claude-context not dev-shell-context to catch env-var/process-tree defects."

This plan **does not** ship that meta-lesson promotion. Reasoning:
- Promote-rule requires AP-23 instance threshold (3+ same-class instances). The S245 observation says threshold is MET for the parent class (harness-design-time-defect-surfaces-at-runtime).
- A separate promote-rule subagent dispatch is the proper venue, not the S246 dev session. Per CLAUDE.md Session Protocol § Start, promote-rule cycles run on their own dispatch chain.
- This plan documents the candidate; S246+1 / S247 may pick it up if promote-rule confirms.

What this plan DOES address: by introducing PATH-shadowed `tasklist` mocking (§6.2), TC3 now exercises the BLOCK path in dev-shell-context with synthesized data. This is a partial answer to L-S245+-1: the firing-test now CAN simulate the multi-claude state that previously required spawned-context to surface. Full L-S245+-1 (run firing-tests under a real spawned claude --print) remains out of scope.

---

## 7. Risk assessment

### 7.1 What could break

| Risk | Likelihood | Severity | Mitigation |
|---|---|---|---|
| Mock-tasklist PATH override not picked up by hook subprocess (different bash invocation) | LOW | MEDIUM | Verify in TC1 sanity probe before relying on it for TC3 |
| Lock schema change breaks any other consumer reading `.claude-instance.lock` | LOW | LOW | Only `single-claude-instance-lock.sh` writes it; SessionEnd cleanup at `.claude/settings.json:239` does plain `rm -f` (schema-agnostic). Grep confirmed: no other reader (one-shot grep before commit) |
| Threshold value 7200s wrong for some users | MEDIUM | LOW | Tunable via `STOCKFORGE_LOCK_STALE_SEC` env var |
| `tasklist //V` parse breaks on locale-specific Windows (e.g. JA-JP) | LOW | MEDIUM | TC parses CSV column-by-position, not by header text; LOCALE-independent |
| Subagent-spawn `claude -p` filtering produces false positive (production claude with `-p` in path) | LOW | MEDIUM | Match command-line for ` -p ` (whitespace bracketed) or ` --print ` to reduce collision |
| Two-window manual smoke fails (e.g. user opens windows too fast and tasklist sees only one) | LOW | LOW | Hook is SessionStart; race window << polling latency |

### 7.2 Rollback path

Each task is a standalone commit. To roll back:
- Revert COMMIT 3 (hook fix) → restores S244 trap-fixed but holder-PID-broken behavior. Phantom-dispatch protection regresses to broken-but-known state.
- Revert COMMIT 4 (firing-test) → TC3 re-marks PENDING.
- COMMITS 1-2 (probe) are already self-revert (Task 2 reverts Task 1's wiring; only the unwired script remains).

No data migration; no DB; no API. Pure script rollback.

### 7.3 Smoke plan (non-firing-test)

After Task 5:
1. Verify lock file content matches new csv format on first SessionStart of fresh claude.exe: `cat agent-workspace/memory/.claude-instance.lock` should read `claude_pids=<n>:created=<epoch>:session=<sid_or_unknown>`.
2. Verify SessionEnd still cleans the lock: trigger `/quit`; check lock file gone.
3. Verify subagent dispatch (e.g. validate_thesis spawning bear/bull/quant via `subagent_transport.py`) does NOT produce false BLOCK in spawned claude.exe SessionStart logs (`agent-workspace/memory/.session-hooks.log` Stop entry should not show `[BLOCK]`).

### 7.4 Out-of-scope (explicitly)

- IN-SESSION parallel subagent dispatch race (S243 AMENDMENT lines 78-80, F-Operational-1). Different mechanism (canonical observation-path collision); separate fix needed (per-subagent-dispatch unique observation paths). NOT addressed by this plan. Tracked as S246+ harness queue item.
- L-S240-5 promote-rule cycle (already in flight per S243 AMENDMENT line 84 + S245 observation line 75).
- 5-ticker LIVE re-run gating. The lock fix is a precondition; LIVE re-run itself runs in a later session.

---

## 8. Budget envelope estimate for S246 IMPL session

| Component | Tokens | Rationale |
|---|---|---|
| Reading this plan | ~7K | ~30 KB plan file |
| Reading existing hook + firing-test source | ~3K | ~6 KB source |
| Reading S243/S244/S245 observations | ~6K | ~12 KB total |
| Probe artifact analysis (§2 outcome) | ~2K | small txt artifact |
| Authoring lock-rc-probe.sh + settings.json edit (Task 1) | ~5K | ~30 LOC + 1 line edit |
| Authoring hook fix (Task 3) | ~10K | ~80 LOC rewrite + comment block |
| Authoring firing-test enhancements (Task 4) | ~12K | ~80 LOC additions across 4 new TCs |
| Running tests + observing output (Task 5) | ~5K | bash output |
| Writing dev observation file | ~5K | structured ~3 KB |
| Buffer (debug iterations, lint fixes) | ~15K | typical 2-3 retry per quality gate |
| **TOTAL** | **~70K** | well within FOCUSED IMPL budget (100-150K) |

**Recommended session type**: FOCUSED IMPL (3 tasks ≤). 

**Note**: Tasks 1+2 (probe + revert) require manual user 2-window run between them. **This means S246 is naturally split into two phases**:
- S246-A: Tasks 1 + 2 (probe deploy + capture). ~30K tokens. SessionEnd hands off to user.
- S246-B: Tasks 3 + 4 + 5 (fix + tests + observation). ~50K tokens. After user confirms probe artifact ready.

If user prefers single-session, Task 1 deploys probe + waits for user prompt resumption with probe data attached. Acceptable; budget unchanged.

---

## 9. Provenance summary (key citations)

Every assertion in this plan ties to a file:line. Master citation table:

| Claim | Source |
|---|---|
| Lock content was `session=unknown:1:1778421770` | `agent-workspace/memory/observations/2026-05-10-S245-lock-pid-secondary-defect.md:17-18` |
| Hook line 31 format string | `scripts/hooks/single-claude-instance-lock.sh:31` |
| Hook BLOCK condition | `scripts/hooks/single-claude-instance-lock.sh:22-28` |
| `CLAUDE_SESSION_ID` empty in 174/174 SessionStart on Windows | `scripts/hooks/profile-template-auto-populate.sh:38` |
| L-S48m-1 ACTIVE (high severity) | `agent-workspace/memory/agent-notes.md:547` |
| L-S108-1 ACTIVE (canonical fallback-to-constant pitfall) | `agent-workspace/memory/agent-notes.md:591` |
| Existing repo workaround pattern (stdin JSON SESSION_ID) | `scripts/hooks/dispatch-jsonl-recorder.sh:104-111` |
| SessionEnd cleanup wired correctly | `.claude/settings.json:239` |
| SessionStart hook wiring | `.claude/settings.json:148` |
| S244 fix evidence (trap removed; firing-test created) | `agent-workspace/memory/observations/sandwich-dev-S244-lock-trap-fix.md:14-72` |
| S243 trap-fix RC | `agent-workspace/memory/observations/2026-05-10-S243-parallel-finding-lock-trap-bug.md:21-30` |
| S243 IN-SESSION amendment + 4th-instance promotion | `agent-workspace/memory/observations/2026-05-10-S243-parallel-finding-lock-trap-bug.md:65-86` |
| TC3 PENDING reason | `scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh:127-140` |
| Subagent transport spawn vector (subprocess.run claude -p) | `packages/infrastructure/analysis/subagent_transport.py:11-18` |
| Empirical CLAUDE_SESSION_ID empty in session log | `agent-workspace/memory/.session-hooks.log:26` (`Stop session=`) |
| Architecture layer rules (informs why probe goes in scripts/hooks not packages/) | `agent-workspace/constitution/architecture.md:7-25` |

---

## 10. Done-criteria for this plan's execution

S246 sandwich-dev session is COMPLETE when:

- [ ] Probe ran; artifact at `agent-workspace/memory/observations/lock-rc-probe-*.txt` exists (Task 1).
- [ ] Probe wiring reverted; settings.json restored (Task 2).
- [ ] Hook rewritten with chosen strategy ((e) or (f)); comment block updated; bash-hook-lint clean (Task 3).
- [ ] Firing-test has 7 PASS / 0 FAIL / 0 PENDING; full firing-test suite regression-clean (Task 4).
- [ ] Manual 2-window smoke confirmed BLOCK fires (Task 5; may PEND-USER).
- [ ] Dev observation written.
- [ ] No production code touched (this is harness-only).
- [ ] No commit made unless user explicitly requested.

---

*Plan authored S245 sandwich-architect. Hand off to S246 sandwich-dev when fresh-context dispatch fires.*
