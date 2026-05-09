#!/usr/bin/env bash
# bootstrap-summary-renderer-fire-test.sh — companion firing-test per L-S51-1
# Tests externally-observable: boot-summary.md created with expected sections + content extracted.
# S179 D-039 fixture rewrite — REAL-STATE-DERIVED per L-S176-1:
#   - TC3 uses real `**S<N> NEXT ACTION priority**` format (Bug #2 fix coverage)
#   - TC3b NEW backward-compat: legacy `**Next action**` format still works
#   - TC5 uses real `| M-S<N>-<M> | ... |` table-row digest (Bug #3 fix coverage)
set -uo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available" >&2; exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/bootstrap-summary-renderer.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
OUTPUT="$MEM_DIR/boot-summary.md"
mkdir -p "$MEM_DIR/decisions" "$MEM_DIR/checkpoints"

# Seed current-execution.md with top section + REAL `**S<N> NEXT ACTION priority**` format
# (per D-039 Bug #2 fix; matches actual current-execution.md format)
cat > "$MEM_DIR/current-execution.md" <<'EOF'
# Current Execution

## S65 — Phase 3 entry — BC-7 PLAN architect (2026-05-06) PLAN ✅

**Scope**: BC-7 architect dispatch.

**S65 NEXT ACTION priority** per S64 close + Phase 3 entry:
1. **PRIORITY 1**: S66 entry — recommend MULTI_TASK_IMPL Track J.

---

## S64 — older row
EOF

# Seed 6 ADRs (NNN-*.md naming per real-state)
for n in 027 028 029 030 031 032; do
  echo "test ADR $n" > "$MEM_DIR/decisions/${n}-test-adr.md"
done

# Seed mistake-log with REAL table-row digest format (per D-039 Bug #3 fix; matches RCA-2026-05-06 Layer 1)
cat > "$MEM_DIR/mistake-log.md" <<'EOF'
# Mistake Log

## Mistake Digest Index

| ID | Session | Severity | Summary | Archive line |
|---|---|---|---|---|
| M-S62-1 | S62 | medium | old mistake digest | 100 |
| M-S63-1 | S63 | medium | another digest | 200 |
| M-S64-1 | S64 | high | dispatch duplicate digest | 300 |
| M-S65-1 | S65 | high | ADR collision digest | 400 |
EOF

# Seed checkpoint with in_flight YAML
cat > "$MEM_DIR/checkpoints/latest.md" <<'EOF'
# Checkpoint

```yaml
in_flight_subagent_dispatch:
  - dispatch_label: S65-architect-BC-7
    status: returned
    consumed_at: 2026-05-06
```
EOF

PASS=0
FAIL=0

# TC1: Stop event → boot-summary.md created
PAYLOAD_TC1='{"hook_event_name":"Stop","session_id":"test"}'
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
if [ -f "$OUTPUT" ]; then
  echo "  TC TC1-file-created: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC1-file-created: FAIL — $OUTPUT not created"; FAIL=$((FAIL+1))
fi

# TC2: Active section header captured
if grep -q "S65 — Phase 3 entry — BC-7 PLAN architect" "$OUTPUT"; then
  echo "  TC TC2-active-header: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-active-header: FAIL"; FAIL=$((FAIL+1))
fi

# TC3 (D-039 PRIMARY REAL-STATE): Real `**S<N> NEXT ACTION priority**` format captured
# Pre-D-039 hook awk anchor `^**Next action**` matched 0 lines on real file → silent empty.
# Post-D-039 awk also matches `^**S<N> NEXT ACTION` → captures correctly.
if grep -q "S65 NEXT ACTION priority" "$OUTPUT"; then
  echo "  TC TC3-next-action-real-format (D-039 PRIMARY): PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-next-action-real-format (D-039 PRIMARY): FAIL — `**S<N> NEXT ACTION priority**` not extracted"
  echo "Output snippet:"
  head -25 "$OUTPUT"
  FAIL=$((FAIL+1))
fi

# TC3b (D-039 BACKWARD-COMPAT): Legacy `**Next action**` format still works
# Re-run hook with fixture using only legacy format
cat > "$MEM_DIR/current-execution.md" <<'EOF'
# Current Execution

## S99 — Phase 2 — legacy fixture (2026-04-30)

**Scope**: legacy NEXT_ACTION format.

**Next action**: legacy fallback fixture for backward-compat coverage.

---

## S98 — older
EOF
rm -f "$OUTPUT"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
if grep -q "legacy fallback fixture" "$OUTPUT"; then
  echo "  TC TC3b-next-action-legacy (D-039 BACKWARD-COMPAT): PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3b-next-action-legacy (D-039 BACKWARD-COMPAT): FAIL — legacy `**Next action**` format not extracted"
  echo "Output snippet:"
  head -25 "$OUTPUT"
  FAIL=$((FAIL+1))
fi

# Restore primary fixture for remaining TCs
cat > "$MEM_DIR/current-execution.md" <<'EOF'
# Current Execution

## S65 — Phase 3 entry — BC-7 PLAN architect (2026-05-06) PLAN ✅

**Scope**: BC-7 architect dispatch.

**S65 NEXT ACTION priority** per S64 close + Phase 3 entry:
1. **PRIORITY 1**: S66 entry — recommend MULTI_TASK_IMPL Track J.

---

## S64 — older row
EOF
rm -f "$OUTPUT"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true

# TC4: Last 5 ADRs (032 newest, 027 not in list since only 5 fit)
if grep -q "032-test-adr.md" "$OUTPUT" && grep -q "028-test-adr.md" "$OUTPUT"; then
  ADR_COUNT=$(grep -cE '^[0-9]{3}-test-adr\.md$' "$OUTPUT" || true)
  if [ "$ADR_COUNT" = "5" ]; then
    echo "  TC TC4-last-5-adrs: PASS (count=5)"; PASS=$((PASS+1))
  else
    echo "  TC TC4-last-5-adrs: FAIL — expected 5 ADRs, got $ADR_COUNT"; FAIL=$((FAIL+1))
  fi
else
  echo "  TC TC4-last-5-adrs: FAIL — 032 or 028 not in summary"; FAIL=$((FAIL+1))
fi

# TC5 (D-039 BUG #3 FIX REAL-STATE): Last 3 mistakes captured from REAL table-row digest
# Pre-D-039 hook anchor `^### M-S<N>-<M>:` matched 0 lines on real file → silent empty.
# Post-D-039 anchor `^| M-S[0-9]+` matches table-row digest → captures last 3 correctly.
if grep -q "M-S65-1" "$OUTPUT" && grep -q "M-S64-1" "$OUTPUT" && grep -q "M-S63-1" "$OUTPUT" && ! grep -q "M-S62-1" "$OUTPUT"; then
  echo "  TC TC5-last-3-mistakes-table-rows (D-039 BUG #3): PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-last-3-mistakes-table-rows (D-039 BUG #3): FAIL"
  echo "Output mistake section:"
  awk '/Recent mistakes/,/In-flight subagent/' "$OUTPUT"
  FAIL=$((FAIL+1))
fi

# TC6: In-flight YAML block included
if grep -q "in_flight_subagent_dispatch:" "$OUTPUT" && grep -q "S65-architect-BC-7" "$OUTPUT"; then
  echo "  TC TC6-in-flight-yaml: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC6-in-flight-yaml: FAIL"; FAIL=$((FAIL+1))
fi

# TC7: Frontmatter rendered_at + cache_ttl_hours present
if head -10 "$OUTPUT" | grep -q "rendered_at:" && head -10 "$OUTPUT" | grep -q "cache_ttl_hours: 1"; then
  echo "  TC TC7-frontmatter-rendered: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC7-frontmatter-rendered: FAIL"; FAIL=$((FAIL+1))
fi

# TC8: Idempotent — second run overwrites cleanly (no append accumulation)
LINES_FIRST=$(wc -l < "$OUTPUT")
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
LINES_SECOND=$(wc -l < "$OUTPUT")
if [ "$LINES_FIRST" = "$LINES_SECOND" ]; then
  echo "  TC TC8-idempotent: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC8-idempotent: FAIL — lines $LINES_FIRST → $LINES_SECOND (should overwrite)"; FAIL=$((FAIL+1))
fi

# TC9: Output size compact (<3.5KB target ~2KB)
SIZE=$(wc -c < "$OUTPUT")
if [ "$SIZE" -lt 3500 ]; then
  echo "  TC TC9-compact-size: PASS ($SIZE bytes)"; PASS=$((PASS+1))
else
  echo "  TC TC9-compact-size: FAIL — $SIZE bytes (>3500)"; FAIL=$((FAIL+1))
fi

# TC10: Non-Stop event → no execution (use a Read event)
PAYLOAD_TC10='{"hook_event_name":"PreToolUse","tool_name":"Read"}'
rm -f "$OUTPUT"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC10" 2>&1 || true
if [ ! -f "$OUTPUT" ]; then
  echo "  TC TC10-non-stop-skip: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC10-non-stop-skip: FAIL — file created on non-Stop event"; FAIL=$((FAIL+1))
fi

# TC11 (S180 D-039-followup): Long ACTIVE_HEADER truncated
# Real-state observation: current-execution.md `## SXXX — ...` section headers can be >2KB single-line
# crammed summaries; renderer must cap to MAX_HEADER_LEN with "(truncated)" marker.
LONG_HEADER_BODY="$(printf 'A%.0s' $(seq 1 400))"  # 400-char A-string
cat > "$MEM_DIR/current-execution.md" <<EOF
# Current Execution

## S180 — Phase 3.5 — long header fixture for truncation TC: $LONG_HEADER_BODY

**S180 NEXT ACTION priority**: TC fixture.

---

## S179 — older row
EOF
rm -f "$OUTPUT"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
HEADER_LINE="$(grep -m 1 '^## S180' "$OUTPUT" 2>/dev/null || true)"
if [ -n "$HEADER_LINE" ] && [ "${#HEADER_LINE}" -lt 350 ] && grep -qF "(truncated; see current-execution.md)" "$OUTPUT"; then
  echo "  TC TC11-active-header-truncation (S180): PASS (header line ${#HEADER_LINE} bytes)"; PASS=$((PASS+1))
else
  echo "  TC TC11-active-header-truncation (S180): FAIL — line=${#HEADER_LINE} bytes; expected <350 + marker"
  echo "Output snippet:"
  head -15 "$OUTPUT"
  FAIL=$((FAIL+1))
fi

# TC12 (S180 D-039-followup): Long RECENT_MISTAKES row truncated
# Real-state observation: post-D-039 Bug #3 fix correctly extracts table-rows but real entries
# (e.g., M-S171-1) can be >2KB single-cell prose. Renderer must cap each row to MAX_MISTAKE_LEN.
LONG_PROSE="$(printf 'B%.0s' $(seq 1 400))"
cat > "$MEM_DIR/current-execution.md" <<'EOF'
# Current Execution

## S65 — restored

**S65 NEXT ACTION priority**: restored.
EOF
cat > "$MEM_DIR/mistake-log.md" <<EOF
# Mistake Log

## Mistake Digest Index

| ID | Session | Severity | Summary | Archive line |
|---|---|---|---|---|
| M-S60-1 | S60 | low | short prior digest | 50 |
| M-S61-1 | S61 | medium | another short digest | 60 |
| M-S180-LONG | S180 | high | $LONG_PROSE | inline-test |
EOF
rm -f "$OUTPUT"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
LONG_ROW="$(grep '^| M-S180-LONG' "$OUTPUT" 2>/dev/null || true)"
if [ -n "$LONG_ROW" ] && [ "${#LONG_ROW}" -lt 350 ] && grep -qF "(truncated; see mistake-log.md)" "$OUTPUT"; then
  echo "  TC TC12-mistake-row-truncation (S180): PASS (long row ${#LONG_ROW} bytes)"; PASS=$((PASS+1))
else
  echo "  TC TC12-mistake-row-truncation (S180): FAIL — row=${#LONG_ROW} bytes; expected <350 + marker"
  echo "Output mistake section:"
  awk '/Recent mistakes/,/In-flight subagent/' "$OUTPUT"
  FAIL=$((FAIL+1))
fi

echo
echo "=== Results: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
