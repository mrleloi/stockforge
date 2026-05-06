#!/usr/bin/env bash
# bootstrap-summary-renderer-fire-test.sh — companion firing-test per L-S51-1
# Tests externally-observable: boot-summary.md created with expected sections + content extracted
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

# Seed current-execution.md with top section + Next action
cat > "$MEM_DIR/current-execution.md" <<'EOF'
# Current Execution

## S65 — Phase 3 entry — BC-7 PLAN architect (2026-05-06) PLAN ✅

**Scope**: BC-7 architect dispatch.

**Next action**: S66 entry — recommend MULTI_TASK_IMPL Track J.

---

## S64 — older row
EOF

# Seed 6 ADRs
for n in 027 028 029 030 031 032; do
  echo "test ADR $n" > "$MEM_DIR/decisions/${n}-test-adr.md"
done

# Seed mistake-log with 4 M entries
cat > "$MEM_DIR/mistake-log.md" <<'EOF'
# Mistake Log

### M-S62-1: old mistake
body

### M-S63-1: another
body

### M-S64-1: dispatch duplicate
body

### M-S65-1: ADR collision
body
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

# TC3: Next action line captured
if grep -q "S66 entry" "$OUTPUT"; then
  echo "  TC TC3-next-action: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-next-action: FAIL"; FAIL=$((FAIL+1))
fi

# TC4: Last 5 ADRs (032 newest, 027 not in list since only 5 fit)
if grep -q "032-test-adr.md" "$OUTPUT" && grep -q "028-test-adr.md" "$OUTPUT"; then
  ADR_COUNT=$(grep -cE '^[0-9]{3}-test-adr\.md$' "$OUTPUT" || echo 0)
  if [ "$ADR_COUNT" = "5" ]; then
    echo "  TC TC4-last-5-adrs: PASS (count=5)"; PASS=$((PASS+1))
  else
    echo "  TC TC4-last-5-adrs: FAIL — expected 5 ADRs, got $ADR_COUNT"; FAIL=$((FAIL+1))
  fi
else
  echo "  TC TC4-last-5-adrs: FAIL — 032 or 028 not in summary"; FAIL=$((FAIL+1))
fi

# TC5: Last 3 mistakes captured (M-S63, S64, S65)
if grep -q "M-S65-1" "$OUTPUT" && grep -q "M-S64-1" "$OUTPUT" && grep -q "M-S63-1" "$OUTPUT" && ! grep -q "M-S62-1" "$OUTPUT"; then
  echo "  TC TC5-last-3-mistakes: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-last-3-mistakes: FAIL"; FAIL=$((FAIL+1))
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

# TC9: Output size compact (<3KB target ~2KB)
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

echo
echo "=== Results: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
