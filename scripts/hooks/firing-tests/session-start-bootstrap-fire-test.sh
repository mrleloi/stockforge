#!/usr/bin/env bash
# Firing-test for session-start-bootstrap.sh (Phase 3.5 T3.4-followup; S53 fix for M-S52-1).
#
# Validates ACTIVE_SESSION extraction logic post-fix. Prior bug (M-S52-1):
#   awked for `^**Session N**` literal which never appears in real current-execution.md
#   → ACTIVE_SESSION silently empty → queued-grill awk matcher (~line 75) `sess != ""`
#   branch never executed → session-token fire_when entries (e.g. "S20+", "S52",
#   "S5 Track 7") silently never fired. Track-based matching kept working independently.
#
# Test strategy: stage temp PROJECT_DIR with current-execution.md (with `## S<N>` headers)
# + queued-grill-master.md (with fire_when containing known session-token); invoke hook;
# assert .queued-grill-fired.log contains the matched entry id (proves session-token branch fired).
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../session-start-bootstrap.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

mkdir -p "$TEMPDIR/agent-workspace/memory" \
         "$TEMPDIR/agent-workspace/memory/observations" \
         "$TEMPDIR/agent-workspace/memory/checkpoints"

# Hook requires latest.md exists else early-exits before queued-grill scan (line ~30).
touch "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"

run_hook() {
  local source_val="${1:-startup}"
  local payload
  payload=$(printf '{"source":"%s"}' "$source_val")
  # Run hook; suppress stdout/stderr (hook emits JSON + diagnostic on stdout).
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<< "$payload" >/dev/null 2>&1 || true
}

LOG="$TEMPDIR/agent-workspace/memory/.queued-grill-fired.log"

# --- TC1: ACTIVE_SESSION extracts LARGEST `## S<N>` → fire_when 'S52' matches ---
rm -f "$LOG"
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 3.5

## S52 — latest row
## S51 — older
EOF

cat > "$TEMPDIR/agent-workspace/memory/observations/queued-grill-master.md" <<EOF
# Queued Grill — Master Index

### Q-TC1 — Test entry

- **fire_when**: example trigger references S52 active
- **status**: open
EOF

run_hook "startup"

if [ ! -f "$LOG" ] || ! grep -q "Q-TC1" "$LOG"; then
  echo "FAIL TC1: expected Q-TC1 fire log entry; ACTIVE_SESSION extraction broken or matcher silent"
  echo "Log content:"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC1: ACTIVE_SESSION=S52 extracted from '## S52' header → matched fire_when 'S52'"

# --- TC2: subordinate formats (S50-pre, S49a, S49b) → ACTIVE_SESSION = S<largest-numeric> ---
rm -f "$LOG"
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 3.5

## S50 — main
## S50-pre — incident
## S49b — sweep
## S49a — audit
EOF

cat > "$TEMPDIR/agent-workspace/memory/observations/queued-grill-master.md" <<EOF
# Queued Grill — Master Index

### Q-TC2-pos — Should match S50

- **fire_when**: trigger when S50 active
- **status**: open

### Q-TC2-neg — Should NOT match S52 (not active)

- **fire_when**: trigger when S52 active
- **status**: open
EOF

run_hook "startup"

if ! grep -q "Q-TC2-pos" "$LOG"; then
  echo "FAIL TC2: expected Q-TC2-pos to fire (S50 should match)"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
if grep -q "Q-TC2-neg" "$LOG"; then
  echo "FAIL TC2: Q-TC2-neg should NOT fire (S52 not in active execution)"
  cat "$LOG" 2>&1
  exit 1
fi
echo "PASS TC2: subordinate formats handled — S50 active; selective fire_when match works"

# --- TC3: regression — phantom `**Session N**:` literal alone yields no session-token match ---
rm -f "$LOG"
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 3.5

**Session N**: S99 (phantom format that never existed in real file pre-fix)
EOF

cat > "$TEMPDIR/agent-workspace/memory/observations/queued-grill-master.md" <<EOF
# Queued Grill — Master Index

### Q-TC3 — Should NOT match (no '## S<N>' header in fixture)

- **fire_when**: trigger when S99 active
- **status**: open
EOF

run_hook "startup"

if [ -f "$LOG" ] && grep -q "Q-TC3" "$LOG"; then
  echo "FAIL TC3: phantom **Session N**: literal accidentally matched by new pattern; regression"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: phantom **Session N**: literal NOT matched (no '## S<N>' headers → no session-token match)"

# --- TC4: ACTIVE_TRACK matcher path works independently of ACTIVE_SESSION ---
# Updated post-KI-S56-1 fix (S57): ACTIVE_TRACK now only extracted from
# `## Active Focus Track` section. Fixture places Track 7 inside that section.
rm -f "$LOG"
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution

**Phase**: 3.5

## S52 — latest session

Some session row prose.

---

## Active Focus Track

**Active Track**: Track 7

---

## Routing Table

(noise)
EOF

cat > "$TEMPDIR/agent-workspace/memory/observations/queued-grill-master.md" <<'EOF'
# Queued Grill — Master Index

### Q-TC4 — Should match via Track 7 token (fire_when has no S<N> token)

- **fire_when**: trigger when Track 7 active
- **status**: open
EOF

run_hook "startup"

if ! grep -q "Q-TC4" "$LOG"; then
  echo "FAIL TC4: ACTIVE_TRACK matcher path broken — Track 7 should match"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC4: ACTIVE_TRACK matcher (independent of ACTIVE_SESSION) still works"

# --- TC5: KI-S56-1 fix (S57) — Track ref in Active Focus Track section MATCHES (positive) ---
rm -f "$LOG"
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution

**Phase**: 3.5

## S99 — archive prose mentions Track 5 (false-positive bait)

This row references Track 5 mid-narrative (archive prose).

---

## Active Focus Track

**Phase**: 3.5
**Active Track**: Track 7 (current)
**Active plan**: 010-foo

---

## Routing Table

(noise)
EOF

cat > "$TEMPDIR/agent-workspace/memory/observations/queued-grill-master.md" <<'EOF'
# Queued Grill — Master Index

### Q-TC5 — Should match Track 7 (Active Focus Track section)

- **fire_when**: trigger when Track 7 active
- **status**: open
EOF

run_hook "startup"

if ! grep -q "Q-TC5" "$LOG"; then
  echo "FAIL TC5: KI-S56-1 fix broken — Track 7 (in Active Focus Track section) should match"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC5: KI-S56-1 fix — Track ref extracted from Active Focus Track section (not archive prose)"

# --- TC6: KI-S56-1 fix (S57) — Archive-prose Track ref does NOT MATCH (negative) ---
rm -f "$LOG"
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution

**Phase**: 3.5

## S99 — archive prose mentions Track 5 (false-positive bait)

This row references Track 5 mid-narrative (archive prose).

---

## Active Focus Track

**Phase**: 3.5
**Active Track**: T1 / T7 (Phase 3.5 uses T-prefix shorthand, no numeric Track here)
**Active plan**: 010-foo

---

## Routing Table

(noise)
EOF

cat > "$TEMPDIR/agent-workspace/memory/observations/queued-grill-master.md" <<'EOF'
# Queued Grill — Master Index

### Q-TC6 — Should NOT match Track 5 (archive prose only, NOT in Active Focus Track section)

- **fire_when**: trigger when Track 5 active
- **status**: open
EOF

run_hook "startup"

if grep -q "Q-TC6" "$LOG"; then
  echo "FAIL TC6: KI-S56-1 fix broken — Track 5 (archive prose only) should NOT match (it's outside Active Focus Track section)"
  cat "$LOG"
  exit 1
fi
echo "PASS TC6: KI-S56-1 fix — Archive-prose Track ref correctly EXCLUDED from match (ACTIVE_TRACK=empty)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "session-start-bootstrap.sh M-S52-1 + KI-S56-1 fixes verified empirically."
exit 0
