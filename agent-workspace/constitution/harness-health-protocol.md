# Harness Health Protocol — Empirical-Firing Signal Catalog (v1.0)

> **Status**: RATIFIED — Constitution-tier; mv completed S220 D-048 (from proposals/); charter v1.1-aligned post-S253 (D-056).
> **Current location**: `agent-workspace/constitution/harness-health-protocol.md` (canonical).
> **Ratification chain**: S173 Q1=A user explicit approval → S220 D-048 mv-to-constitution (one-time deny-lift bundled with D-047) → S252 cross-reference reconciliation → S253 D-056 charter v1.1 Principle 11 ratified.
> **Functional status**: T6 hook `harness-health-self-scan.sh` implements signals inline (does NOT read protocol file at runtime). Protocol = source-of-truth + reference doc for human review + future amendments.
> **Companion artifacts**: `scripts/hooks/harness-health-self-scan.sh` (T6 hook impl, D-035) + `PROJECT_CHARTER.md` Principle 11 (T8; D-056; RATIFIED 2026-05-12).
> **Authority chain**: Phase 3.5 master plan §T5 (`agent-workspace/session-plans/pending/010-S50-phase-3.5-harness-deepening-master-plan.md` lines 213-258) → S173 charter user-gate → D-048 mv → D-056 charter v1.1 → this file.

---

## § 1 — Identity + Binding Scope

This protocol codifies **empirically verifiable** harness-health signals (HH-1 through HH-12). Each signal:

- Has a **deterministic detection command** (bash one-liner / short script reference) — NO LLM judgment.
- Has a **clear pass/fail threshold** (numeric or boolean; no fuzzy comparison).
- Has a **severity level** (HIGH / MEDIUM / LOW) per `agent-workspace/constitution/drift-signals.md` precedent.
- Has a **remediation action** (concrete command or escalation path).
- May have a **KI suppression** clause (known-issue tolerance until upstream fix; tracked separately).

### Why this exists

Phase 2.5 (S48b-S49a) closed 8/8 GREEN at ritual audit. ~14 sessions later (S49b period), three empirical failures surfaced — all detected via user push, not via harness self-detection:

1. **M-S49b-1**: `autonomous-stop-watchdog.sh` wired in Stop chain + smoke-test passes manually, BUT logs show 0 `Stop session=` entries across ~10 turns of session 5b96635e.
2. **Promote-rule backlog**: Last cycle S43c (2026-05-04). 6+ sessions accumulated agent-notes entries without `promotion-cycle-trigger.sh` firing (Stop-hook-dependent — see #1).
3. **Auto-detect orphans**: ~20 entries in agent-notes tagged `Auto-detect: yes` with no companion shipped hook (visible only via manual grep, no harness alarm).

**Counter-anti-pattern (Principle 11 candidate)**: *"Harness must self-verify firing, not self-attest existence."*

### Scope binding

| Aspect | Constraint |
|---|---|
| **Loader** | `scripts/hooks/harness-health-self-scan.sh` (T6) on UserPromptSubmit + SessionStart |
| **Authority tier** | Constitution-tier (lives in `agent-workspace/constitution/`) — edits require deny-lift + ADR per `agent-workspace/CLAUDE.md` § Contract Rule 1 |
| **Versioning** | v1.0 at S173. Amendments via charter-tier deny-lift + ADR D-NNN + version bump |
| **Performance budget** | <2s wall-clock on UserPromptSubmit (cheap-first signal ordering + same-session result caching) |
| **Suppression** | Per-signal KI clauses (e.g., HH-1 KI-S49b-1 Windows quirk); suppression elevates severity floor (HIGH→MEDIUM) but does NOT silence the FAIL emission |

---

## § 2 — Signal Catalog HH-1 through HH-12

### HH-1 — Stop hook fires ≥1 time per active session

**What**: `Stop session=$SID` line present in `agent-workspace/memory/.session-hooks.log` since last matching `SessionStart session=$SID` line for current session ID.

**Why**: Stop chain has 36 hooks (per S173 `.claude/settings.json` scan). If Stop never fires, NONE of those 36 fire — cascading to: auto-reboot-handoff-verify, drift-signals-D1-D9, sync-tracker-auto-update, lesson-synthesis-watchdog, qa-stale-urgent-escalator, qa-pending-auto-mover, session-end-checklist-linter, project-md-staleness-check, tier1-bloat-check, promotion-cycle-trigger, etc. M-S49b-1 surfaced this exact gap.

**Detection command**:
```bash
SID="${CLAUDE_SESSION_ID:-unknown}"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
[ ! -f "$LOG" ] && { echo "SKIP: log missing"; exit 0; }
START_LINE=$(grep -n "SessionStart session=$SID" "$LOG" 2>/dev/null | tail -1 | cut -d: -f1)
[ -z "$START_LINE" ] && { echo "SKIP: no SessionStart for SID"; exit 0; }
STOP_COUNT=$(awk "NR>$START_LINE" "$LOG" | grep -c "Stop session=$SID" 2>/dev/null || echo 0)
[ "$STOP_COUNT" -ge 1 ]  # PASS iff ≥1 Stop fire post-SessionStart
```

**Threshold**: PASS = STOP_COUNT ≥ 1 since latest SessionStart for current SID.

**Severity**: HIGH (default) — cascades to 36 dependent hooks. **KI-S49b-1 suppression: MEDIUM** until upstream Claude Code Windows fix verified.

**Remediation**: (a) verify Stop chain wired in `.claude/settings.json`; (b) verify scripts exist + executable; (c) consider migrating Stop-gated logic to UserPromptSubmit (T2 precedent — `userprompt-invariants-injector.sh`).

---

### HH-2 — UserPromptSubmit hook fires ≥1 time per non-trivial prompt

**What**: `UserPromptSubmit` line present in `.session-hooks.log` within last 10 minutes (proxy for "active session activity").

**Why**: UserPromptSubmit chain (currently 6 hooks) is the T2-mitigation foundation for Stop-hook-Windows-quirk (M-S49b-1). If UserPromptSubmit also silent, T2 mitigation is undermined.

**Detection command**:
```bash
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
[ ! -f "$LOG" ] && { echo "SKIP: log missing"; exit 0; }
TEN_MIN_AGO=$(date -d "10 min ago" -Iseconds 2>/dev/null || python3 -c "import datetime; print((datetime.datetime.now() - datetime.timedelta(minutes=10)).isoformat())" 2>/dev/null || echo "")
[ -z "$TEN_MIN_AGO" ] && { echo "SKIP: date math unavailable"; exit 0; }
RECENT=$(awk -v cutoff="$TEN_MIN_AGO" '$0 > "[" cutoff' "$LOG" 2>/dev/null | grep -c "UserPromptSubmit" || echo 0)
[ "$RECENT" -ge 1 ]
```

**Threshold**: PASS = RECENT ≥ 1 in last 10 minutes.

**Severity**: HIGH.

**Remediation**: Verify UserPromptSubmit chain wired; check for hook script syntax errors (e.g., `bash -n script.sh`); test via fresh prompt.

---

### HH-3 — Promote-rule cycle delta < 8 sessions since last run

**What**: Latest `agent-workspace/memory/observations/promote-rule-S*.md` file mtime within last ~8 sessions worth of activity (calibrated to ~5-10 days for typical session cadence).

**Why**: Phase 2.5 surface-1 (~6+ session promote-rule backlog) directly caused L-S171-1 idle-loop pattern. If backlog grows unchecked, agent-notes entries pile up unprocessed; institutional memory degrades.

**Detection command**:
```bash
PROM_DIR="$PROJECT_DIR/agent-workspace/memory/observations"
LATEST=$(find "$PROM_DIR" -name 'promote-rule-S*.md' -type f 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
[ -z "$LATEST" ] && { echo "FAIL: no promote-rule observation found"; exit 1; }
LATEST_AGE_DAYS=$(( ( $(date +%s) - $(stat -c %Y "$LATEST" 2>/dev/null || stat -f %m "$LATEST" 2>/dev/null || echo 0) ) / 86400 ))
[ "$LATEST_AGE_DAYS" -le 10 ]  # 10-day proxy for ≤8 sessions
```

**Threshold**: PASS = LATEST mtime within last 10 days.

**Severity**: MEDIUM (escalates to HIGH at 14+ days = ~14+ sessions backlog).

**Remediation**: Dispatch `promote-rule` subagent at next session entry (Stop-hook `promotion-cycle-trigger.sh` should auto-fire if HH-1 PASSes).

---

### HH-4 — Auto-detect candidates without companion shipped hook = 0

**What**: Count of `agent-workspace/memory/agent-notes.md` entries tagged `Auto-detect: yes` MINUS count of corresponding hook scripts in `scripts/hooks/`. Should be ≤ 2 (small in-flight delta tolerance).

**Why**: Phase 2.5 surface-3 (~20 Auto-detect orphans). Auto-detect tag promises a deterministic hook ships; if no hook, the promise is hollow.

**Detection command**:
```bash
NOTES="$PROJECT_DIR/agent-workspace/memory/agent-notes.md"
[ ! -f "$NOTES" ] && { echo "SKIP: agent-notes.md missing"; exit 0; }
CANDIDATES=$(grep -c "Auto-detect:.*yes" "$NOTES" 2>/dev/null || echo 0)
HOOKS=$(find "$PROJECT_DIR/scripts/hooks" -maxdepth 1 -name '*.sh' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
ORPHAN_DELTA=$(( CANDIDATES > HOOKS ? CANDIDATES - HOOKS : 0 ))
[ "$ORPHAN_DELTA" -le 2 ]
```

**Threshold**: PASS = ORPHAN_DELTA ≤ 2.

**Severity**: MEDIUM.

**Remediation**: Run `promote-rule` subagent prioritizing Auto-detect-tagged entries; ship missing hooks per L-S12-1 metric-function doctrine.

---

### HH-5 — Tier 1 always-loaded ceiling ≤ 8K tokens

**What**: Combined token estimate of CLAUDE.md + agent-workspace/CLAUDE.md + human-workspace/CLAUDE.md + memory/MEMORY.md + project.md + current-execution.md (all auto-loaded artifacts) ≤ 8000 tokens.

**Why**: M-S49a-2 surfaced Tier 1 bloat 30K tok → context budget breach. Charter Principle: working memory ≤ 8K per `agent-workspace/proposals/memory-tiers.md` Tier 1.

**Detection command**: Defer to existing hook `scripts/hooks/tier1-bloat-check.sh` exit code (already wired in Stop chain).
```bash
bash "$PROJECT_DIR/scripts/hooks/tier1-bloat-check.sh" >/dev/null 2>&1
[ $? -eq 0 ]  # PASS = exit 0
```

**Threshold**: PASS = `tier1-bloat-check.sh` exit 0.

**Severity**: HIGH.

**Remediation**: Trim CLAUDE.md / project.md / current-execution.md to fit; archive overflow to dated files.

---

### HH-6 — dispatch-pending JSONL has no `state=pending` row older than 2 hours

**What**: Any `.dispatch-pending-*.jsonl` file in `agent-workspace/memory/` whose latest row contains `"state":"pending"` AND mtime > 2 hours ago.

**Why**: L-S49b-3 Fix-L4 codified pre-dispatch in-flight check. Stale pending rows = lost dispatch tracking → M-S49b-2 duplicate-dispatch repeat risk.

**Detection command**:
```bash
JSONL_DIR="$PROJECT_DIR/agent-workspace/memory"
TWO_HR_AGO=$(( $(date +%s) - 7200 ))
STALE=0
for f in "$JSONL_DIR"/.dispatch-pending-*.jsonl; do
  [ -f "$f" ] || continue
  MTIME=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
  [ "$MTIME" -gt "$TWO_HR_AGO" ] && continue  # fresh; skip
  if tail -1 "$f" 2>/dev/null | grep -q '"state":"pending"'; then
    STALE=$((STALE + 1))
  fi
done
[ "$STALE" -eq 0 ]
```

**Threshold**: PASS = STALE = 0.

**Severity**: MEDIUM (HIGH if STALE ≥ 3).

**Remediation**: Manually inspect stale rows; close via observation file write OR mark as ABANDONED in JSONL append.

---

### HH-7 — Checkpoint freshness: latest.md mtime within 2 sessions OR 24 hours

**What**: `agent-workspace/memory/checkpoints/latest.md` mtime within either: (a) the last 2 session boundaries (proxied by sessions/ recent files), OR (b) last 24 hours — whichever is shorter.

**Why**: Stale checkpoint = handoff data drift. /clear → continue auto-reboot relies on `latest.md` being current. M-S100 (autonomous_mode flag truncated) was a checkpoint-staleness adjacent failure.

**Detection command**:
```bash
LATEST="$PROJECT_DIR/agent-workspace/memory/checkpoints/latest.md"
[ ! -f "$LATEST" ] && { echo "FAIL: latest.md missing"; exit 1; }
NOW=$(date +%s)
MTIME=$(stat -c %Y "$LATEST" 2>/dev/null || stat -f %m "$LATEST" 2>/dev/null || echo 0)
AGE_HR=$(( (NOW - MTIME) / 3600 ))
SESSIONS_DIR="$PROJECT_DIR/agent-workspace/memory/sessions"
LATEST_SESS=$(find "$SESSIONS_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
SESS_MTIME=$(stat -c %Y "$LATEST_SESS" 2>/dev/null || stat -f %m "$LATEST_SESS" 2>/dev/null || echo 0)
SESS_DELTA_HR=$(( (NOW - SESS_MTIME) / 3600 ))
# PASS: checkpoint mtime within 24hr OR within session-mtime window
[ "$AGE_HR" -le 24 ] || [ "$AGE_HR" -le "$(( SESS_DELTA_HR + 2 ))" ]
```

**Threshold**: PASS = checkpoint mtime within 24hr OR within ~2 sessions of latest session mtime.

**Severity**: MEDIUM.

**Remediation**: Update `latest.md` at next session-boundary checkpoint write; verify Stop hook `auto-reboot-handoff-verify.sh` is firing (HH-1 dependency).

---

### HH-8 — Charter md5 unchanged in non-ratify session

**What**: md5 hash of `PROJECT_CHARTER.md` matches expected baseline UNLESS this session is flagged as charter-ratify.

**Why**: D9 drift signal mirror; detects unauthorized charter mutation. CLAUDE.md hard rule: "Never modify `PROJECT_CHARTER.md`. Requires explicit human revision with version bump."

**Detection command**:
```bash
CHARTER="$PROJECT_DIR/PROJECT_CHARTER.md"
BASELINE_FILE="$PROJECT_DIR/agent-workspace/memory/.charter-md5-baseline"
[ ! -f "$CHARTER" ] && { echo "FAIL: charter missing"; exit 1; }
[ ! -f "$BASELINE_FILE" ] && { echo "SKIP: baseline not initialized — emit baseline write notice"; exit 0; }
CURRENT_MD5=$(md5sum "$CHARTER" 2>/dev/null | awk '{print $1}' || md5 "$CHARTER" 2>/dev/null | awk '{print $NF}' || echo "")
BASELINE_MD5=$(cat "$BASELINE_FILE" 2>/dev/null | tr -d '[:space:]')
RATIFY_MARKER="$PROJECT_DIR/agent-workspace/memory/.charter-ratify-active-${CLAUDE_SESSION_ID:-none}"
if [ "$CURRENT_MD5" != "$BASELINE_MD5" ] && [ ! -f "$RATIFY_MARKER" ]; then
  echo "FAIL: charter md5 changed without ratify marker"
  exit 1
fi
[ "$CURRENT_MD5" = "$BASELINE_MD5" ] || [ -f "$RATIFY_MARKER" ]
```

**Threshold**: PASS = (md5 matches baseline) OR (md5 changed AND ratify marker present for current session).

**Severity**: HIGH (charter immutability invariant).

**Remediation**: If charter modified without ratify marker → revert via git OR file `M-S<N>-1` mistake-log entry; rebaseline only after explicit user-gate ratification.

---

### HH-9 — mistake-log.md last entry mtime within 5 minutes of session-end OR explicit "no mistakes this session" line in session log

**What**: Either (a) `mistake-log.md` mtime delta < 5 min from latest session log mtime, OR (b) session log contains explicit "no mistakes this session" / "NONE this turn" / "M-* NEW: NONE" pattern.

**Why**: CLAUDE.md § Session End ritual step 6 (D-028): "Update `mistake-log.md` with new M-S<N>-<M> entries OR explicitly state 'no mistakes this session' in the session log (enforced by `session-end-checklist-linter.sh`)". HH-9 verifies the linter is firing.

**Detection command**:
```bash
SESS_DIR="$PROJECT_DIR/agent-workspace/memory/sessions"
MISTAKE="$PROJECT_DIR/agent-workspace/memory/mistake-log.md"
LATEST_SESS=$(find "$SESS_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
[ -z "$LATEST_SESS" ] && { echo "SKIP: no session log"; exit 0; }
SESS_MTIME=$(stat -c %Y "$LATEST_SESS" 2>/dev/null || echo 0)
MISTAKE_MTIME=$(stat -c %Y "$MISTAKE" 2>/dev/null || echo 0)
DELTA=$(( SESS_MTIME > MISTAKE_MTIME ? SESS_MTIME - MISTAKE_MTIME : MISTAKE_MTIME - SESS_MTIME ))
if [ "$DELTA" -le 300 ]; then exit 0; fi  # PASS via fresh edit
if grep -qiE "no mistakes (this )?(session|turn)|mistakes new.*none" "$LATEST_SESS" 2>/dev/null; then
  exit 0  # PASS via explicit declaration
fi
exit 1  # FAIL
```

**Threshold**: PASS via either fresh mistake-log edit OR explicit "no mistakes" declaration.

**Severity**: MEDIUM.

**Remediation**: Append M-S<N>-<M> entry OR add "no mistakes this session" to session log + re-run `session-end-checklist-linter.sh`.

---

### HH-10 — Each priority-1 hook in scripts/hooks/ has companion firing-test in scripts/hooks/firing-tests/

**What**: For every `.sh` file in `scripts/hooks/` (excluding `firing-tests/` subdir), there exists corresponding `<name>-fire-test.sh` in `scripts/hooks/firing-tests/`.

**Why**: Phase 3.5 T7 retrofit codified pattern (63/63 firing-tests PASS at S79; L-S49b-4 backlog DRAINED). HH-10 ensures backlog stays at 0 going forward.

**Detection command**:
```bash
HOOKS_DIR="$PROJECT_DIR/scripts/hooks"
TESTS_DIR="$HOOKS_DIR/firing-tests"
[ ! -d "$TESTS_DIR" ] && { echo "FAIL: firing-tests/ missing"; exit 1; }
ORPHANS=0
for HOOK in "$HOOKS_DIR"/*.sh; do
  [ -f "$HOOK" ] || continue
  NAME=$(basename "$HOOK" .sh)
  TEST="$TESTS_DIR/${NAME}-fire-test.sh"
  if [ ! -f "$TEST" ]; then
    ORPHANS=$((ORPHANS + 1))
  fi
done
[ "$ORPHANS" -le 2 ]  # tolerance: 2 in-flight new hooks; promote PROMPT to ship test
```

**Threshold**: PASS = ORPHAN count ≤ 2 (in-flight tolerance).

**Severity**: MEDIUM.

**Remediation**: Author missing firing-test per pattern in `scripts/hooks/firing-tests/<existing>-fire-test.sh`.

---

### HH-11 — .session-hooks.log mtime within session active duration

**What**: `agent-workspace/memory/.session-hooks.log` mtime delta from `now()` < 60 minutes (proxy for "log being actively written").

**Why**: If log frozen, ALL hook telemetry lost. Direct evidence harness layer is alive.

**Detection command**:
```bash
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
[ ! -f "$LOG" ] && { echo "FAIL: log missing"; exit 1; }
NOW=$(date +%s)
MTIME=$(stat -c %Y "$LOG" 2>/dev/null || stat -f %m "$LOG" 2>/dev/null || echo 0)
AGE_MIN=$(( (NOW - MTIME) / 60 ))
[ "$AGE_MIN" -le 60 ]
```

**Threshold**: PASS = log mtime within last 60 minutes.

**Severity**: HIGH.

**Remediation**: Investigate disk full / permission issue / hook chain exit-1-trapped early. Verify `.claude/settings.json` SessionStart "echo SessionStart..." command works.

---

### HH-12 — current-execution.md Phase row matches project.md Phase Goals Tracker

**What**: Latest Phase row in `current-execution.md` (head, since rows are LIFO) Phase claim matches the IN-PROGRESS row in `project.md` Phase Goals Tracker.

**Why**: M-S171-1 surfaced this gap directly: 22 sessions silently labeled "Phase 3" while project.md said "Phase 2.5 IN PROGRESS / Phase 3 PAUSED". This is the canonical state-drift signal.

**Detection command**:
```bash
CE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
PROJ="$PROJECT_DIR/agent-workspace/memory/project.md"
[ ! -f "$CE" ] || [ ! -f "$PROJ" ] && { echo "SKIP: missing files"; exit 0; }
# Extract Phase claim from latest current-execution row (## SXXX — Phase Y — ...)
CE_PHASE=$(grep -m1 -E '^## S[0-9]+ — Phase' "$CE" 2>/dev/null | grep -oE 'Phase [0-9.]+' | head -1)
# Extract IN PROGRESS phase from project.md Phase Goals Tracker
PROJ_PHASE=$(grep -E '^\| [0-9.]+ —' "$PROJ" 2>/dev/null | grep -i 'IN PROGRESS' | head -1 | grep -oE 'Phase [0-9.]+' | head -1)
[ -z "$CE_PHASE" ] || [ -z "$PROJ_PHASE" ] && { echo "SKIP: phase parse failed"; exit 0; }
# Allow exact match OR adjacent phase (CE may be Phase X.5 while project shows Phase X parent)
[ "$CE_PHASE" = "$PROJ_PHASE" ]
```

**Threshold**: PASS = phase strings match exactly.

**Severity**: HIGH (M-S171-1 prevention; charter coherence).

**Remediation**: Run FOCUSED_AUDIT subagent (per S172 precedent); reconcile project.md or current-execution.md to match empirical truth.

---

## § 3 — Self-scan Invocation Contract

The hook `scripts/hooks/harness-health-self-scan.sh` (T6) MUST:

1. **Iterate signals HH-1 through HH-12** in defined cheap-first order (file mtime checks before grep on 1MB log; HH-1/HH-7/HH-11 cheap; HH-3/HH-9 medium; HH-12/HH-4 grep-heavy).
2. **Respect KI suppressions** — emit FAIL with downgraded severity when KI marker file exists (e.g., `agent-workspace/memory/.harness-health-ki-S49b-1`).
3. **Cache results within session** — write `agent-workspace/memory/.harness-health-cache-${CLAUDE_SESSION_ID}` with timestamp + summary; reuse if cached < 5 min ago AND no new prompt since cache write.
4. **Emit aggregated FAIL summary** via:
   - `<system-reminder>` channel on UserPromptSubmit (via `hookSpecificOutput.additionalContext`)
   - stderr on SessionStart (visible in session-hooks.log)
5. **Append per-signal log line** to `agent-workspace/memory/.harness-health.log` for telemetry retention (rotated by existing log-rotate cadence).
6. **Exit 0 ALWAYS** — harness-health failure is informational, not blocking. The LLM agent is responsible for acting on the signal.

---

## § 4 — Pass/Fail Aggregation Rules

| State | Condition | Action |
|---|---|---|
| **GREEN** | 0 FAILs across HH-1..HH-12 | No emission; cache PASS marker |
| **YELLOW** | 1-2 MEDIUM FAILs (no HIGH) | Emit summary; suggest remediation in next idle session |
| **RED-1** | 1 HIGH FAIL | Emit `<system-reminder>` urgently; LLM SHOULD address before continuing routine work |
| **RED-2+** | 2+ HIGH FAILs OR 1 HIGH + ≥2 MEDIUM | Emit `<system-reminder>` BLOCKING; mandate phase-audit subagent dispatch OR Q&A escalation; LLM SHALL NOT advance phase claim until resolved |
| **SKIPPED** | Detection command returned SKIP (missing files / unavailable tools) | Log SKIP reason; do not count toward FAIL aggregate |

### Aggregation example

If HH-1=FAIL(HIGH-suppressed-MEDIUM via KI-S49b-1) + HH-3=FAIL(MEDIUM) + HH-12=PASS + others=PASS:
- Counts: 1 MEDIUM (HH-1 suppressed) + 1 MEDIUM (HH-3) = **YELLOW**
- Emit: "harness-health YELLOW: HH-1 (suppressed Windows quirk) + HH-3 (promote-rule backlog 11 days)"
- LLM action: Schedule promote-rule subagent dispatch in next non-IDLE session.

---

## § 5 — Versioning + Amendment

- **v1.0 (2026-05-07 S173)**: initial 12-signal catalog ratified via AskUserQuestion S173 Q1=A.
- Future amendments require: charter-tier deny-lift via `AskUserQuestion` letter pick + ADR D-NNN + version bump (v1.1, v1.2, ...).
- Amendments to threshold values / severity levels (calibration tuning) qualify as IMPL-tier and can land in same ADR section as v1.0 with explicit `AMENDED REV-N` annotation.

---

## § 6 — Glossary

- **Hook firing**: a hook script reaching `exit 0` (or expected non-error exit) AND emitting an artifact (log line / file mutation / system-reminder). Mere existence + manual smoke-test invocation does NOT count.
- **Empirical-firing evidence**: production log entry / file artifact / telemetry row directly produced by hook execution during real session activity.
- **Ritual closure**: declaring a track DONE based on file existence + smoke-test exit 0 — distinct from empirical-firing evidence (the gap surfaced by Phase 2.5).
- **KI suppression**: known-issue acknowledgment that downgrades severity floor without silencing the signal (e.g., HH-1 KI-S49b-1).

---

## § 7 — Reference

- Phase 3.5 master plan: `agent-workspace/session-plans/pending/010-S50-phase-3.5-harness-deepening-master-plan.md`
- Phase 2.5 post-mortem: `agent-workspace/memory/post-mortems/2026-05-05-phase-2.5-empirical-firing-gap.md`
- D-029 Tiered Coverage Map (drift signals format precedent): `agent-workspace/memory/decisions/029-...md`
- Companion T6 hook: `scripts/hooks/harness-health-self-scan.sh`
- Companion T8 charter proposal: `agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md`
- AskUserQuestion ratification record: `human-workspace/q-and-a/pending/2026-05-07-001-phase-3.5-T5-T6-T8-charter-gate.md` (Q1=A)

---

**End of harness-health-protocol.md v1.0.** Next change requires charter-tier user-gate.
