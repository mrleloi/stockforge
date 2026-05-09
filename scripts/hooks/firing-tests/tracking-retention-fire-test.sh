#!/usr/bin/env bash
# Firing-test for tracking-retention.sh (S99 RCA Layer 1; S100 firing-test backfill per T7 hard rule #2;
# S179 D-039 fixture rewrite — TC6/TC7 dropped per supplementary-check retirement; TCs renumbered).
#
# Hook purpose (Stop hook):
#   - reads cap thresholds for current-execution.md / agent-notes.md / mistake-log.md / component-telemetry.jsonl
#   - emits per-violation lines to .session-hooks.log + 1 notification when ≥1 violation
#   - exit 0 always (soft-warn; never blocks)
#
# Test cases (post-D-039):
#   TC1 — all files missing → 0 violations, summary line emitted, no notification
#   TC2 — all files clean (under caps) → 0 violations, no notification
#   TC3 — current-execution.md > 200 LOC → 1 violation
#   TC4 — current-execution.md > 5 sessions → 1 violation
#   TC5 — agent-notes.md > 700 LOC → 1 violation
#   TC6 — multiple violations (ce_loc + an_loc + ml_loc) → notification lists ≥3 lines
#   TC7 — telemetry > 10MB → 1 violation
#   TC8 — empirical regression: grep returning rc=1 (0 matches) does NOT silent-exit
#         (S100 PIPEFAIL fix verification — script reaches all 4 caps + emits all metrics in summary)
#   TC9 — S135 promotion: AUTO-MIGRATE happy path (LOC>200, ≥2 sessions, archive exists)
#   TC10 — S135 promotion: AUTO-MIGRATE skipped when only 1 inline session
#   TC11 — S135 promotion: AUTO-MIGRATE skipped when NO archive file exists
#   TC12 — S141 promotion: AUTO-MIGRATE on sessions-cap-only-breach (sessions>5 LOC≤200)
#
# D-039 RETIRED CASES (no longer applicable):
#   - Old TC6 (### L-S inline body → 1 violation) — supplementary AN_LESSONS check retired
#   - Old TC7 (### M-S inline body → 1 violation) — supplementary ML_MISTAKES check retired
# Reasoning per D-039: digest-format check was authored from FALSE PREMISE (assumed digest =
# table-rows-only); real-state shows agent-notes "Recent Rules (digest)" uses inline `###
# YYYY-MM-DD (S<N>): <Title> — L-S<N>-<M>` cards; mistake-log uses table rows. LOC cap is sole
# sound primary defense.
#
# Exit 0 = all pass. Exit 1 = any fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../tracking-retention.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir at $TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
NOTIF_DIR="$TEMPDIR/human-workspace/notifications"
LOG="$MEM_DIR/.session-hooks.log"
NOTIF_FILE="$NOTIF_DIR/tracking-retention-cap-breach.md"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$MEM_DIR" "$NOTIF_DIR"
}

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" >/dev/null 2>&1
}

assert_violations_eq() {
  local expected="$1" tag="$2"
  local got
  got=$(grep -oE "violations=[0-9]+" "$LOG" 2>/dev/null | tail -1 | sed 's/violations=//')
  if [ "${got:-MISSING}" != "$expected" ]; then
    echo "FAIL $tag: expected violations=$expected; got violations=${got:-MISSING}"
    [ -f "$LOG" ] && cat "$LOG"
    exit 1
  fi
}

# --- TC1: all files missing → 0 violations, summary emitted, no notification ---
clean_state
run_hook
assert_violations_eq 0 "TC1"
if [ -f "$NOTIF_FILE" ]; then
  echo "FAIL TC1: notification should NOT exist when 0 violations"
  exit 1
fi
echo "PASS TC1: missing files → 0 violations, no notification"

# --- TC2: clean state (small files, no inline bodies) → 0 violations ---
# REAL-STATE-DERIVED per D-039 / L-S176-1: agent-notes uses inline `### YYYY-MM-DD (S<N>): … — L-S<N>-<M>`
# cards (NOT a violation post-D-039); mistake-log uses table rows.
clean_state
printf '# Header\n\n## S99 — short row\n\nClean.\n' > "$MEM_DIR/current-execution.md"
{
  printf '# Notes\n\n'
  printf '## Recent Rules (digest)\n\n'
  printf '### 2026-05-07 (S99): Inline lesson card — L-S99-1\nbody (canonical digest format post-D-039).\n'
} > "$MEM_DIR/agent-notes.md"
{
  printf '# Mistakes\n\n## Mistake Digest Index\n\n'
  printf '| ID | Session | Severity | Summary |\n|---|---|---|---|\n'
  printf '| M-S99-1 | S99 | medium | digest summary |\n'
} > "$MEM_DIR/mistake-log.md"
: > "$MEM_DIR/component-telemetry.jsonl"
run_hook
assert_violations_eq 0 "TC2"
if [ -f "$NOTIF_FILE" ]; then
  echo "FAIL TC2: notification should NOT exist when clean (D-039: inline cards + table rows are canonical, not violations)"
  cat "$NOTIF_FILE"
  exit 1
fi
echo "PASS TC2: clean state with inline cards (canonical digest) → 0 violations"

# --- TC3: current-execution.md > 200 LOC → 1 violation ---
clean_state
{
  echo "# Header"
  for i in $(seq 1 250); do echo "line $i"; done
} > "$MEM_DIR/current-execution.md"
run_hook
assert_violations_eq 1 "TC3"
if ! grep -q "current-execution.md LOC=" "$LOG"; then
  echo "FAIL TC3: log should mention LOC violation"
  exit 1
fi
echo "PASS TC3: ce_loc > 200 → 1 violation"

# --- TC4: current-execution.md > 5 sessions → 1 violation ---
clean_state
{
  echo "# Header"
  for i in 1 2 3 4 5 6 7; do echo "## S$i — row"; done
} > "$MEM_DIR/current-execution.md"
run_hook
assert_violations_eq 1 "TC4"
if ! grep -q "ce_sessions=7" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: log should record ce_sessions=7"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: ce_sessions > 5 → 1 violation"

# --- TC5: agent-notes.md > 700 LOC → 1 violation ---
clean_state
{ for i in $(seq 1 800); do echo "line $i"; done; } > "$MEM_DIR/agent-notes.md"
run_hook
assert_violations_eq 1 "TC5"
if ! grep -q "agent-notes.md LOC=" "$LOG"; then
  echo "FAIL TC5: log should mention agent-notes LOC violation"
  exit 1
fi
echo "PASS TC5: an_loc > 700 → 1 violation"

# --- TC6 (D-039 RENUMBERED from TC8): multiple violations → notification lists all ---
# D-039: replaced ml_inline-body trigger with ml_loc>200 trigger to keep 3-violation count
# without depending on retired supplementary check.
clean_state
{ for i in $(seq 1 250); do echo "line $i"; done; } > "$MEM_DIR/current-execution.md"
{ for i in $(seq 1 800); do echo "line $i"; done; } > "$MEM_DIR/agent-notes.md"
{ for i in $(seq 1 250); do echo "ml line $i"; done; } > "$MEM_DIR/mistake-log.md"
run_hook
NOTIF_COUNT=$(grep -c "tracking-retention" "$NOTIF_FILE" 2>/dev/null || true)
NOTIF_COUNT="${NOTIF_COUNT:-0}"
if [ ! -f "$NOTIF_FILE" ]; then
  echo "FAIL TC6: notification file should exist"
  exit 1
fi
if [ "$NOTIF_COUNT" -lt 3 ]; then
  echo "FAIL TC6: notification should list ≥3 violation lines (got $NOTIF_COUNT)"
  cat "$NOTIF_FILE"
  exit 1
fi
echo "PASS TC6: multiple violations (ce_loc + an_loc + ml_loc) listed in notification"

# --- TC7 (D-039 RENUMBERED from TC9): telemetry > 10MB → 1 violation ---
clean_state
# Build 11MB file via dd-equivalent (POSIX yes/head); use head to capture exact size
head -c 11000000 /dev/zero > "$MEM_DIR/component-telemetry.jsonl" 2>/dev/null
run_hook
assert_violations_eq 1 "TC7"
if ! grep -q "tel_bytes=" "$LOG"; then
  echo "FAIL TC7: log should record tel_bytes"
  exit 1
fi
echo "PASS TC7: telemetry > 10MB → 1 violation"

# --- TC8 (D-039 RENUMBERED from TC10): PIPEFAIL regression — grep -c returning rc=1 (0 matches) does NOT silent-exit ---
# Setup state where ALL grep -c invocations return 0 matches (rc=1 each):
# - current-execution.md: NO `^## S[0-9]` lines + LOC 5 (under 200)
# - agent-notes.md: NO `^### L-S` lines + LOC 5 (under 700)
# - mistake-log.md: NO `^### M-S` lines + LOC 5 (under 200)
# - component-telemetry.jsonl: tiny
# Pre-S100 fix: script silent-exits at first grep -c (line 43 ce_sessions) before reaching telemetry.
# Post-S100 fix: script reaches all 4 caps, summary line shows all 4 metrics.
# D-039 sustains: AN_LESSONS + ML_MISTAKES diagnostic vars retained for forward-compat,
# emitted in summary (always 0 post-retire) so TC8 metric assertions still pass.
clean_state
printf '# Header\nNo session rows.\n' > "$MEM_DIR/current-execution.md"
printf '# Notes\nDigest only.\n' > "$MEM_DIR/agent-notes.md"
printf '# Mistakes\nDigest only.\n' > "$MEM_DIR/mistake-log.md"
: > "$MEM_DIR/component-telemetry.jsonl"
run_hook
SUMMARY=$(grep "tracking-retention: violations=" "$LOG" 2>/dev/null | tail -1)
if [ -z "$SUMMARY" ]; then
  echo "FAIL TC8: summary line missing — script silent-exited (PIPEFAIL regression)"
  cat "$LOG"
  exit 1
fi
# Summary must contain all 4 cap metrics (proves end-to-end reach)
for metric in "ce_loc=" "ce_sessions=" "an_loc=" "an_lessons=" "ml_loc=" "ml_mistakes=" "tel_bytes="; do
  if ! printf '%s' "$SUMMARY" | grep -q "$metric"; then
    echo "FAIL TC8: summary missing metric '$metric' — script did not reach all caps"
    echo "Summary: $SUMMARY"
    exit 1
  fi
done
echo "PASS TC8: PIPEFAIL fix verified — all 4 caps reached when grep -c returns 0 matches (D-039: diagnostic vars retained)"

# --- TC9 (D-039 RENUMBERED from TC11): S135 AUTO-MIGRATE happy path ---
# Setup: current-exec with 5 ## S blocks total LOC > 200; archive file with frontmatter.
# Expected: oldest ## S (lowest line-pos = highest line number) moves to archive; LOC
# drops below 200; 0 violations; archive frontmatter sessions_archived bumped.
clean_state
{
  printf '# Header\nautonomous_mode: true\n\n'
  for n in 134 133 132 131 130; do
    printf '## S%s — Phase 3 — sample row\n\n' "$n"
    # 40-line filler per session: 5 sessions × 45 lines/session + 3-line header = 228 LOC pre
    # (just over 200 cap); post-migrate (4 sessions remain) = 183 LOC (well under cap).
    for j in $(seq 1 40); do
      echo "filler line $j for session S$n with enough text to count toward LOC budget"
    done
    printf '\n---\n\n'
  done
} > "$MEM_DIR/current-execution.md"
PRE_CE_LOC=$(wc -l < "$MEM_DIR/current-execution.md")
# Sanity: pre-migration LOC must be > 200 (test premise)
if [ "$PRE_CE_LOC" -le 200 ]; then
  echo "FAIL TC9 setup: pre-migration LOC=$PRE_CE_LOC must be > 200; fixture too small"
  exit 1
fi
# Build archive file with realistic frontmatter
ARCH_FILE="$MEM_DIR/current-execution-archive-2026-05-06-test.md"
{
  printf -- '---\n'
  printf 'type: archive\n'
  printf 'source: agent-workspace/memory/current-execution.md\n'
  printf 'archived_at: 2026-05-06\n'
  printf 'sessions_archived: S129 → S49b (test fixture)\n'
  printf -- '---\n\n'
  printf '# Archive\n\n## S129 — older row\n\nold content.\n\n---\n'
} > "$ARCH_FILE"
PRE_ARCH_LOC=$(wc -l < "$ARCH_FILE")
run_hook
POST_CE_LOC=$(wc -l < "$MEM_DIR/current-execution.md")
POST_ARCH_LOC=$(wc -l < "$ARCH_FILE")
# Assert migration happened (CE LOC dropped, archive grew)
if [ "$POST_CE_LOC" -ge "$PRE_CE_LOC" ]; then
  echo "FAIL TC9: post-migrate CE LOC=$POST_CE_LOC should be < pre LOC=$PRE_CE_LOC"
  cat "$LOG"
  exit 1
fi
if [ "$POST_ARCH_LOC" -le "$PRE_ARCH_LOC" ]; then
  echo "FAIL TC9: post-migrate archive LOC=$POST_ARCH_LOC should be > pre LOC=$PRE_ARCH_LOC"
  exit 1
fi
# Assert MIGRATED flag in summary line
if ! grep -q "migrated=1" "$LOG"; then
  echo "FAIL TC9: log should record migrated=1"
  cat "$LOG"
  exit 1
fi
# Assert migrated_session=S130 (oldest inline was S130 — last ## S header in fixture)
if ! grep -q "migrated_session=S130" "$LOG"; then
  echo "FAIL TC9: log should record migrated_session=S130"
  cat "$LOG"
  exit 1
fi
# Assert archive frontmatter sessions_archived bumped from S129 to S130
if ! grep -q "^sessions_archived: S130 " "$ARCH_FILE"; then
  echo "FAIL TC9: archive frontmatter should have sessions_archived: S130 (was S129)"
  head -10 "$ARCH_FILE"
  exit 1
fi
# Assert post-migrate LOC under cap (no violations expected)
assert_violations_eq 0 "TC9"
echo "PASS TC9: AUTO-MIGRATE happy path — S130 migrated; LOC $PRE_CE_LOC→$POST_CE_LOC; archive frontmatter bumped"

# --- TC10 (D-039 RENUMBERED from TC12): AUTO-MIGRATE skipped when only 1 inline session ---
# Setup: current-exec with 1 ## S block but LOC>200 (long single-session narrative).
# Expected: no migration (sessions<2 guard); WARN still fires for LOC.
clean_state
{
  printf '# Header\nautonomous_mode: true\n\n## S134 — Phase 3 — single dense session\n\n'
  for j in $(seq 1 250); do
    echo "filler line $j with text to push LOC past 200"
  done
  printf '\n---\n'
} > "$MEM_DIR/current-execution.md"
ARCH_FILE="$MEM_DIR/current-execution-archive-2026-05-06-test.md"
printf -- '---\nsessions_archived: S100 → S49b (test)\n---\n' > "$ARCH_FILE"
PRE_CE_LOC=$(wc -l < "$MEM_DIR/current-execution.md")
run_hook
POST_CE_LOC=$(wc -l < "$MEM_DIR/current-execution.md")
# Assert NO migration (file unchanged)
if [ "$POST_CE_LOC" != "$PRE_CE_LOC" ]; then
  echo "FAIL TC10: CE LOC changed (pre=$PRE_CE_LOC post=$POST_CE_LOC); should NOT migrate when sessions<2"
  exit 1
fi
if ! grep -q "migrated=0" "$LOG"; then
  echo "FAIL TC10: log should record migrated=0"
  cat "$LOG"
  exit 1
fi
# Assert WARN still fires (LOC violation logged)
assert_violations_eq 1 "TC10"
echo "PASS TC10: AUTO-MIGRATE skipped when sessions<2; WARN fires for LOC"

# --- TC11 (D-039 RENUMBERED from TC13): AUTO-MIGRATE skipped when NO archive file ---
# Setup: current-exec with multiple ## S blocks LOC>200 BUT no archive file present.
# Expected: no migration (don't lose data); WARN still fires.
clean_state
{
  printf '# Header\nautonomous_mode: true\n\n'
  for n in 134 133 132; do
    printf '## S%s — sample\n\n' "$n"
    for j in $(seq 1 75); do echo "line $j"; done
    printf '\n---\n\n'
  done
} > "$MEM_DIR/current-execution.md"
# Deliberately NO archive file
PRE_CE_LOC=$(wc -l < "$MEM_DIR/current-execution.md")
run_hook
POST_CE_LOC=$(wc -l < "$MEM_DIR/current-execution.md")
if [ "$POST_CE_LOC" != "$PRE_CE_LOC" ]; then
  echo "FAIL TC11: CE LOC changed (pre=$PRE_CE_LOC post=$POST_CE_LOC); should NOT migrate when no archive"
  exit 1
fi
if ! grep -q "migrated=0" "$LOG"; then
  echo "FAIL TC11: log should record migrated=0"
  cat "$LOG"
  exit 1
fi
assert_violations_eq 1 "TC11"
echo "PASS TC11: AUTO-MIGRATE skipped when no archive file; WARN fires for LOC"

# --- TC12 (D-039 RENUMBERED from TC14): S141 promotion: AUTO-MIGRATE on sessions>5 even when LOC ≤ 200 ---
# Setup: current-exec with 6 short ## S blocks (LOC < 200 + sessions > 5).
# Expected: oldest ## S moves to archive; sessions drops to 5; 0 violations;
# log line records trigger=sessions>5 (NOT LOC>200) for provenance accuracy.
# Closes HOOK GAP surfaced at S140 close (sessions-cap-only-breach previously NO-OP'd).
clean_state
{
  printf '# Header\nautonomous_mode: true\n\n'
  for n in 141 140 139 138 137 136; do
    printf '## S%s — short row\n\nbrief.\n\n---\n\n' "$n"
  done
} > "$MEM_DIR/current-execution.md"
PRE_CE_LOC=$(wc -l < "$MEM_DIR/current-execution.md")
PRE_CE_SESSIONS=$(grep -c "^## S[0-9]" "$MEM_DIR/current-execution.md")
# Sanity: pre-migration LOC must be ≤ 200 AND sessions > 5 (test premise — sessions-cap-only-breach)
if [ "$PRE_CE_LOC" -gt 200 ]; then
  echo "FAIL TC12 setup: pre-migration LOC=$PRE_CE_LOC must be ≤ 200; fixture too large"
  exit 1
fi
if [ "$PRE_CE_SESSIONS" -le 5 ]; then
  echo "FAIL TC12 setup: pre-migration sessions=$PRE_CE_SESSIONS must be > 5; fixture too small"
  exit 1
fi
ARCH_FILE="$MEM_DIR/current-execution-archive-2026-05-06-test.md"
{
  printf -- '---\n'
  printf 'type: archive\n'
  printf 'source: agent-workspace/memory/current-execution.md\n'
  printf 'archived_at: 2026-05-06\n'
  printf 'sessions_archived: S135 → S49b (test fixture)\n'
  printf -- '---\n\n'
  printf '# Archive\n\n## S135 — older row\n\nold content.\n\n---\n'
} > "$ARCH_FILE"
PRE_ARCH_LOC=$(wc -l < "$ARCH_FILE")
run_hook
POST_CE_LOC=$(wc -l < "$MEM_DIR/current-execution.md")
POST_CE_SESSIONS=$(grep -c "^## S[0-9]" "$MEM_DIR/current-execution.md")
POST_ARCH_LOC=$(wc -l < "$ARCH_FILE")
# Assert migration happened (sessions count dropped, archive grew)
if [ "$POST_CE_SESSIONS" -ge "$PRE_CE_SESSIONS" ]; then
  echo "FAIL TC12: post-migrate sessions=$POST_CE_SESSIONS should be < pre sessions=$PRE_CE_SESSIONS"
  cat "$LOG"
  exit 1
fi
if [ "$POST_ARCH_LOC" -le "$PRE_ARCH_LOC" ]; then
  echo "FAIL TC12: post-migrate archive LOC=$POST_ARCH_LOC should be > pre LOC=$PRE_ARCH_LOC"
  exit 1
fi
# Assert MIGRATED flag in summary line
if ! grep -q "migrated=1" "$LOG"; then
  echo "FAIL TC12: log should record migrated=1"
  cat "$LOG"
  exit 1
fi
# Assert migrated_session=S136 (oldest inline was S136 — last ## S header in fixture)
if ! grep -q "migrated_session=S136" "$LOG"; then
  echo "FAIL TC12: log should record migrated_session=S136"
  cat "$LOG"
  exit 1
fi
# Assert trigger=sessions>5 in AUTO-MIGRATED log line (S141 provenance accuracy).
# CRITICAL: must be sessions>5 (NOT LOC>200, NOT both) — proves sessions-only path fired.
if ! grep -qE "trigger=sessions>5\b" "$LOG"; then
  echo "FAIL TC12: log should record trigger=sessions>5 (sessions-only-breach path)"
  grep "AUTO-MIGRATED" "$LOG" || cat "$LOG"
  exit 1
fi
# Assert archive frontmatter sessions_archived bumped from S135 to S136
if ! grep -q "^sessions_archived: S136 " "$ARCH_FILE"; then
  echo "FAIL TC12: archive frontmatter should have sessions_archived: S136 (was S135)"
  head -10 "$ARCH_FILE"
  exit 1
fi
# Assert post-migrate sessions=5 ≤ cap (no violations expected)
assert_violations_eq 0 "TC12"
echo "PASS TC12: AUTO-MIGRATE sessions>5-only-breach — S136 migrated; sessions $PRE_CE_SESSIONS→$POST_CE_SESSIONS; LOC ≤ 200 throughout; trigger=sessions>5"

echo "ALL PASS (12/12)"
exit 0
