#!/usr/bin/env bash
# post-dev-dispatch-attestation-check.sh — SubagentStop guard for sandwich-dev observations.
# Reads latest sandwich-dev observation, parses claimed test counts, empirically re-runs
# pytest on BC paths found in observation, diffs. Emits JSON decision:block on divergence.
# L-S66-1 codification. L-S58-1 ERR-trap-aware: uses if/then/fi not [ x ] && Y.
# L-S11-1 portability: bash + awk + grep + sed only (no python3/jq/yq).
#
# Wired: SubagentStop (after subagent-stop-logger.sh, before cost-ledger-recorder.sh)
# Kill switch: STOCKFORGE_ATTESTATION_DISABLE=1
# Strict mode: STOCKFORGE_ATTESTATION_STRICT=1 → block on warn-only conditions
# bash-hook-lint:allow L-S11-1 python (not python3) used as fallback for pytest; guarded by `command -v python` check; WARN-only if unavailable.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
OBS_DIR="$MEMORY_DIR/observations"
ATTEST_LOG="$MEMORY_DIR/attestation-log.tsv"
ATTEST_MARKER_DIR="$MEMORY_DIR"

# Kill switch
if [ "${STOCKFORGE_ATTESTATION_DISABLE:-0}" = "1" ]; then
  exit 0
fi

PAYLOAD="$(cat)"
if [ -z "$PAYLOAD" ]; then
  exit 0
fi

# Parse hook event — grep exits 1 if not found; use || true
HOOK_EVENT="$(printf '%s' "$PAYLOAD" | grep -o '"hook_event_name":"[^"]*"' 2>/dev/null | head -1 | sed 's/"hook_event_name":"//;s/"//' || true)"
if [ "$HOOK_EVENT" != "SubagentStop" ]; then
  exit 0
fi

# Find latest sandwich-dev observation file (newest mtime)
if [ ! -d "$OBS_DIR" ]; then
  exit 0
fi

LATEST_OBS=""
LATEST_TS=0
for f in "$OBS_DIR"/sandwich-dev-*.md; do
  if [ -f "$f" ]; then
    FILE_TS="$(stat -c%Y "$f" 2>/dev/null || stat -f%m "$f" 2>/dev/null || echo 0)"
    if [ "$FILE_TS" -gt "$LATEST_TS" ]; then
      LATEST_TS="$FILE_TS"
      LATEST_OBS="$f"
    fi
  fi
done

if [ -z "$LATEST_OBS" ]; then
  exit 0
fi

# Check if already processed
OBS_BASENAME="$(basename "$LATEST_OBS" .md)"
MARKER_FILE="$ATTEST_MARKER_DIR/.attestation-checked-${OBS_BASENAME}"
if [ -f "$MARKER_FILE" ]; then
  exit 0
fi

# TC6: Check for structured frontmatter at file start (line 1 must be ---)
# Use awk so empty/missing file collapses to 0 cleanly; grep -c || echo 0 emits "0\n0" on no-match.
HAS_FRONTMATTER="$(awk 'NR==1{if($0=="---") print 1; else print 0; exit}' "$LATEST_OBS" 2>/dev/null || printf '0')"
if [ -z "$HAS_FRONTMATTER" ]; then HAS_FRONTMATTER=0; fi
if [ "$HAS_FRONTMATTER" -lt 1 ] 2>/dev/null; then
  printf 'WARN: observation %s has no frontmatter — legacy format. Upgrade to structured schema per L-S66-1.\n' "$OBS_BASENAME" >&2
  if [ "${STOCKFORGE_ATTESTATION_STRICT:-0}" = "1" ]; then
    printf '{"decision":"block","reason":"legacy-observation-format","observation_file":"%s"}\n' "$OBS_BASENAME"
    exit 2
  fi
  exit 0
fi

# Extract frontmatter block (between first two --- lines)
FRONTMATTER="$(awk '/^---/{c++;if(c==2)exit;next}c==1{print}' "$LATEST_OBS" 2>/dev/null || true)"
if [ -z "$FRONTMATTER" ]; then
  printf 'WARN: observation %s frontmatter empty — legacy format. Upgrade per L-S66-1.\n' "$OBS_BASENAME" >&2
  if [ "${STOCKFORGE_ATTESTATION_STRICT:-0}" = "1" ]; then
    printf '{"decision":"block","reason":"empty-frontmatter","observation_file":"%s"}\n' "$OBS_BASENAME"
    exit 2
  fi
  exit 0
fi

# Extract observation_id using awk (avoids grep exit-1 on no match)
OBS_ID="$(printf '%s' "$FRONTMATTER" | awk '/^observation_id:/{sub(/^observation_id:[[:space:]]*/,"");print;exit}' || true)"
DISPATCH_ID="${OBS_ID:-${OBS_BASENAME}}"

# TC7: check dispatch_id mismatch
SESSION_ID="$(printf '%s' "$PAYLOAD" | grep -o '"session_id":"[^"]*"' 2>/dev/null | head -1 | sed 's/"session_id":"//;s/"//' || true)"
if [ -n "${SESSION_ID:-}" ]; then
  SIDECAR="$MEMORY_DIR/.dispatch-pending-${SESSION_ID}.jsonl"
  if [ -f "$SIDECAR" ]; then
    SIDECAR_DID="$(tail -1 "$SIDECAR" 2>/dev/null | grep -o '"dispatch_id":"[^"]*"' 2>/dev/null | head -1 | sed 's/"dispatch_id":"//;s/"//' || true)"
    if [ -n "${SIDECAR_DID:-}" ] && [ "$SIDECAR_DID" != "$DISPATCH_ID" ]; then
      exit 0
    fi
  fi
fi

# Parse claimed test counts using awk (no grep exit-1 risk)
# Try bc6_pytest_passed + bc7_pytest_passed first; fall back to tests_passed
CLAIMED_PASSED="$(printf '%s' "$FRONTMATTER" | awk '
  /^bc6_pytest_passed:/ { split($0,a,":"); sum+=a[2]+0 }
  /^bc7_pytest_passed:/ { split($0,a,":"); sum+=a[2]+0 }
  END { print sum+0 }
' || true)"
if [ -z "${CLAIMED_PASSED:-}" ]; then
  CLAIMED_PASSED=0
fi

# If no bc6/bc7 fields (sum=0), fall back to tests_passed
if [ "${CLAIMED_PASSED}" -eq 0 ] 2>/dev/null; then
  CLAIMED_PASSED="$(printf '%s' "$FRONTMATTER" | awk '/^tests_passed:/{split($0,a,":");v=a[2]+0;if(v>0)print v;exit}' || true)"
  if [ -z "${CLAIMED_PASSED:-}" ]; then
    CLAIMED_PASSED=0
  fi
fi

CLAIMED_FAILED="$(printf '%s' "$FRONTMATTER" | awk '/^tests_failed:/{split($0,a,":");print a[2]+0;exit}' || true)"
if [ -z "${CLAIMED_FAILED:-}" ]; then
  CLAIMED_FAILED=0
fi

# Parse file counts
FILES_CREATED="$(printf '%s' "$FRONTMATTER" | awk '/^files_created:/{split($0,a,":");v=a[2]+0;print v;exit}' || true)"
FILES_MODIFIED="$(printf '%s' "$FRONTMATTER" | awk '/^files_modified:/{split($0,a,":");v=a[2]+0;print v;exit}' || true)"
if [ -z "${FILES_CREATED:-}" ]; then FILES_CREATED=0; fi
if [ -z "${FILES_MODIFIED:-}" ]; then FILES_MODIFIED=0; fi
CLAIMED_FILE_COUNT=$(( FILES_CREATED + FILES_MODIFIED ))

TS="$(date -u +%FT%T.%3NZ 2>/dev/null || date -u +%FT%TZ 2>/dev/null || true)"

# TC5: check pytest availability
PYTEST_BIN=""
if command -v pytest >/dev/null 2>&1; then
  PYTEST_BIN="pytest"
elif command -v python >/dev/null 2>&1 && python -m pytest --version >/dev/null 2>&1; then
  PYTEST_BIN="python -m pytest"
fi

append_log_row() {
  local row_ts="$1" row_did="$2" row_claim="$3" row_empirical="$4" row_div="$5" row_verdict="$6"
  if [ ! -f "$ATTEST_LOG" ]; then
    mkdir -p "$(dirname "$ATTEST_LOG")"
    printf 'ts\tdispatch_id\tobservation_passed\tempirical_passed\tdivergence\tverdict\n' > "$ATTEST_LOG"
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$row_ts" "$row_did" "$row_claim" "$row_empirical" "$row_div" "$row_verdict" >> "$ATTEST_LOG"
}

if [ -z "$PYTEST_BIN" ]; then
  printf 'WARN: pytest not found — skipping empirical attestation check for %s\n' "$OBS_BASENAME" >&2
  append_log_row "$TS" "$DISPATCH_ID" "$CLAIMED_PASSED" "SKIP" "SKIP" "WARN-NO-PYTEST"
  touch "$MARKER_FILE"
  if [ "${STOCKFORGE_ATTESTATION_STRICT:-0}" = "1" ]; then
    printf '{"decision":"block","reason":"pytest-unavailable","observation_file":"%s"}\n' "$OBS_BASENAME"
    exit 2
  fi
  exit 0
fi

# Default BC paths for stockforge sandwich-dev (BC-6 + BC-7)
# BC-6 = Influence (KOL + telegram_adapter); BC-7 = Crowd (sentiment + pump detection).
BC6_PATHS="packages/domain/influence packages/application/influence packages/infrastructure/influence"
BC7_PATHS="packages/domain/crowd packages/application/crowd packages/infrastructure/crowd"

# Build pytest paths that actually exist
PYTEST_PATHS=""
for p in $BC6_PATHS $BC7_PATHS; do
  FULL_P="$PROJECT_DIR/$p"
  if [ -d "$FULL_P" ]; then
    PYTEST_PATHS="$PYTEST_PATHS $FULL_P"
  fi
done

EMPIRICAL_PASSED=0
if [ -n "$PYTEST_PATHS" ]; then
  PYTEST_CMD="$PYTEST_BIN --tb=no -q"
  # Run pytest; allow failure (tests may fail); capture output
  PYTEST_OUT="$(eval "$PYTEST_CMD $PYTEST_PATHS" 2>&1 || true)"
  # Extract pass count using awk on summary line (e.g. "172 passed, 0 failed")
  EMPIRICAL_PASSED="$(printf '%s' "$PYTEST_OUT" | awk '/[0-9]+ passed/{match($0,/([0-9]+) passed/,a);if(a[1]+0>0){print a[1]+0;exit}}' || true)"
  if [ -z "${EMPIRICAL_PASSED:-}" ]; then
    # Fallback: look for just digits at start of line (pytest -q summary)
    EMPIRICAL_PASSED="$(printf '%s' "$PYTEST_OUT" | awk '/^[0-9]+ passed/{print $1+0;exit}' || true)"
  fi
  if [ -z "${EMPIRICAL_PASSED:-}" ]; then
    EMPIRICAL_PASSED=0
  fi
fi

# Count Python files in BC paths
EMPIRICAL_FILE_COUNT=0
for p in $BC6_PATHS $BC7_PATHS; do
  FULL_P="$PROJECT_DIR/$p"
  if [ -d "$FULL_P" ]; then
    CNT="$(find "$FULL_P" -name '*.py' -not -path '*/__pycache__/*' 2>/dev/null | wc -l || echo 0)"
    EMPIRICAL_FILE_COUNT=$(( EMPIRICAL_FILE_COUNT + CNT ))
  fi
done

# Compute divergences
TEST_DIVERGENCE=$(( EMPIRICAL_PASSED - CLAIMED_PASSED ))
if [ "$TEST_DIVERGENCE" -lt 0 ]; then
  TEST_DIVERGENCE=$(( -TEST_DIVERGENCE ))
fi

FILE_DIVERGENCE=0
if [ "$CLAIMED_FILE_COUNT" -gt 0 ]; then
  FILE_DIVERGENCE=$(( EMPIRICAL_FILE_COUNT - CLAIMED_FILE_COUNT ))
  if [ "$FILE_DIVERGENCE" -lt 0 ]; then
    FILE_DIVERGENCE=$(( -FILE_DIVERGENCE ))
  fi
fi

VERDICT="PASS"
BLOCK_REASON=""

# TC2: test count divergence >= 1 → block
if [ "$TEST_DIVERGENCE" -ge 1 ]; then
  VERDICT="BLOCK"
  BLOCK_REASON="test_count_divergence:${TEST_DIVERGENCE}(claimed=${CLAIMED_PASSED},empirical=${EMPIRICAL_PASSED})"
fi

# TC3: file count divergence >= 3 → block
if [ "$FILE_DIVERGENCE" -ge 3 ]; then
  VERDICT="BLOCK"
  if [ -n "$BLOCK_REASON" ]; then
    BLOCK_REASON="${BLOCK_REASON}|file_count_divergence:${FILE_DIVERGENCE}"
  else
    BLOCK_REASON="file_count_divergence:${FILE_DIVERGENCE}(empirical_total=${EMPIRICAL_FILE_COUNT},claimed_delta=${CLAIMED_FILE_COUNT})"
  fi
fi

append_log_row "$TS" "$DISPATCH_ID" "$CLAIMED_PASSED" "$EMPIRICAL_PASSED" "$TEST_DIVERGENCE" "$VERDICT"
touch "$MARKER_FILE"

if [ "$VERDICT" = "BLOCK" ]; then
  printf '{"decision":"block","reason":"%s","observation_file":"%s","claimed_passed":%s,"empirical_passed":%s,"test_divergence":%s,"file_divergence":%s}\n' \
    "$BLOCK_REASON" "$OBS_BASENAME" "$CLAIMED_PASSED" "$EMPIRICAL_PASSED" "$TEST_DIVERGENCE" "$FILE_DIVERGENCE"
  exit 2
fi

exit 0
