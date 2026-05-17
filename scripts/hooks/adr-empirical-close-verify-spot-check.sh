#!/usr/bin/env bash
# adr-empirical-close-verify-spot-check.sh — random-samples a recently-ACCEPTED ADR's
# empirical_close_verify field, re-runs any "grep ... = 0 hits" claim against the
# working tree, and flags divergence.
#
# Surfaced by: D-052 ghost-greening RCA (S249 sandwich-verifier `a0522171e2f84c5bb`
#   CRITICAL — 4-of-4 self-reviewed ARCH+/CHARTER ADRs diverged from working tree).
# Ratified by: S250 AskUserQuestion Q1=Minimum E (E.3 hook authorization).
# Companion artifact: agent-workspace/proposals/E4-fresh-context-verifier-arch-charter-tier.md
#
# Hook behavior:
# - Pick ONE random ACCEPTED ADR mtime <= 30 days from agent-workspace/memory/decisions/
# - Parse its empirical_close_verify: block for lines matching ` = 0 hits` (and variants)
# - Extract the grep PATTERN between backticks on the same line
# - Re-run grep against packages/ + apps/
# - If actual hit count > 0 → emit WARN to log + system-reminder for agent visibility
#
# Operates as Stop hook; non-blocking (set -o pipefail traps to exit 0).
# Bounded budget: max 5s execution (timeout wrapper on grep).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
LOG="$PROJECT_DIR/agent-workspace/memory/.adr-empirical-spot-check.log"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
DECISIONS_DIR="$PROJECT_DIR/agent-workspace/memory/decisions"

[ ! -d "$DECISIONS_DIR" ] && exit 0

# Candidate pool: ACCEPTED ADRs (any age) that have an empirical_close_verify field.
# Why no -mtime filter: only a minority of ADRs use empirical_close_verify, and only those
# are worth probing. Filtering by field membership is the actual cost-bounder.
CANDIDATES="$( { find "$DECISIONS_DIR" -maxdepth 1 -type f -name '[0-9][0-9][0-9]-*.md' 2>/dev/null \
  | xargs -I{} grep -l '^empirical_close_verify:' {} 2>/dev/null \
  | xargs -I{} grep -l '^status:[[:space:]]*ACCEPTED' {} 2>/dev/null || true; } \
  | head -50 || true)"

[ -z "$CANDIDATES" ] && exit 0

# Random pick: 3 samples per fire for 3x coverage vs prior n=1 (L-S369-1 D5 plan-039).
# Still bounded by 5s timeout per `:18`; sample N=3 keeps cost-per-fire predictable.
# Each ADR in a 10-ADR pool now gets sampled ~3 times per 10 sessions (vs ~1x before).
PICKS="$(echo "$CANDIDATES" | { shuf -n 3 2>/dev/null || head -3; } || true)"
[ -z "$PICKS" ] && exit 0

SCAN_TARGETS="$PROJECT_DIR/packages $PROJECT_DIR/apps"
SEVERITY_STATE="$PROJECT_DIR/agent-workspace/memory/.severity-state.tsv"
TOTAL_DIVERGENCES=0

# Process each sampled ADR (N=3 per fire; L-S369-1 D5 plan-039 promotion).
while IFS= read -r PICK; do
  [ -z "$PICK" ] || [ ! -f "$PICK" ] && continue

  # Extract empirical_close_verify block (YAML-list under top-level key).
  # Lines look like:  - "Production-code grep `import anthropic` in apps/+packages/ = 0 hits"
  VERIFY_BLOCK="$(awk '
    /^empirical_close_verify:/ {capture=1; next}
    capture && /^[a-z_]+:/ && !/^[[:space:]]*-/ {capture=0}
    capture {print}
  ' "$PICK")"

  [ -z "$VERIFY_BLOCK" ] && continue

  # Look for "= 0 hits" style claims.
  ZERO_CLAIMS="$(echo "$VERIFY_BLOCK" | grep -E '=[[:space:]]*0[[:space:]]+(hits?|results?|matches?)' || true)"
  [ -z "$ZERO_CLAIMS" ] && continue

  ADR_ID="$(basename "$PICK" .md)"
  DIVERGENCE_COUNT=0

  while IFS= read -r claim_line; do
    [ -z "$claim_line" ] && continue
    # Extract pattern between first pair of backticks on the claim line.
    PATTERN="$(echo "$claim_line" | sed -n 's/.*`\([^`]*\)`.*/\1/p' | head -1)"
    [ -z "$PATTERN" ] && continue

    # Skip patterns that look like pytest output rather than greppable code patterns.
    case "$PATTERN" in
      *PASS*|*pytest*|*py_compile*) continue ;;
    esac

    # Probe strategy: ADR claim patterns often contain YAML-escaped regex (e.g. `\\s`, `\\b`,
    # `(?:...)`) that don't survive shell var expansion cleanly. Use longest-literal-token
    # heuristic: extract the longest unbroken alphabetic substring (>=5 chars) and probe for
    # it as a fixed string. Lossy but reliably catches gross AP-7 ghost-greening cases
    # (e.g. "anthropic" claimed 0-hits but actually present).
    PROBE_TOKEN="$(echo "$PATTERN" | { grep -oE '[A-Za-z_]{5,}' 2>/dev/null || true; } | awk '{ if (length($0) > max) { max=length($0); tok=$0 } } END { print tok }')"
    [ -z "$PROBE_TOKEN" ] && continue

    ACTUAL_HITS=0
    for target in $SCAN_TARGETS; do
      [ ! -d "$target" ] && continue
      H="$( { timeout 5 grep -rF "$PROBE_TOKEN" "$target" \
          --include='*.py' --include='*.toml' \
          --exclude-dir='__pycache__' --exclude-dir='.pytest_cache' \
          --exclude='test_*.py' --exclude='*_test.py' 2>/dev/null || true; } | wc -l)"
      ACTUAL_HITS=$(( ACTUAL_HITS + H ))
    done

    if [ "$ACTUAL_HITS" -gt 0 ]; then
      DIVERGENCE_COUNT=$(( DIVERGENCE_COUNT + 1 ))
      printf '[%s] DIVERGENCE adr=%s claim="%s" probe_token=%s actual_hits=%d\n' \
        "$(date -Iseconds 2>/dev/null || date)" "$ADR_ID" "$(echo "$claim_line" | tr -d '\n' | head -c 200)" "$PROBE_TOKEN" "$ACTUAL_HITS" >> "$LOG"
    fi
  done <<< "$ZERO_CLAIMS"

  if [ "$DIVERGENCE_COUNT" -gt 0 ]; then
    TOTAL_DIVERGENCES=$(( TOTAL_DIVERGENCES + DIVERGENCE_COUNT ))
    echo "[$(date -Iseconds 2>/dev/null || date)] adr-empirical-spot-check: $DIVERGENCE_COUNT divergence(s) in $ADR_ID — see $LOG" >> "$HOOK_LOG"

    # Emit HIGH severity row to .severity-state.tsv (L-S369-1 D5 plan-039 promotion).
    # Consumer: severity-classifier.sh reads this at next Stop event.
    SEVER_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u)"
    if [ -f "$SEVERITY_STATE" ] || touch "$SEVERITY_STATE" 2>/dev/null; then
      printf '%s\tHIGH\tadr-empirical-spot-check\tadr_id=%s divergences=%d empirical_close_verify claims diverge from working tree\n' \
        "$SEVER_TS" "$ADR_ID" "$DIVERGENCE_COUNT" >> "$SEVERITY_STATE" 2>/dev/null || true
    fi

    # Emit agent-visible WARN. Stop hooks have NO `hookSpecificOutput` variant in the
    # Claude Code hook schema (only PreToolUse/UserPromptSubmit/PostToolUse/PostToolBatch
    # do) — only top-level fields are valid for Stop. The old form emitted
    # {"hookEventName":"Stop","hookSpecificOutput":{...}} which failed schema validation
    # ("hookSpecificOutput missing required field hookEventName"). Use top-level
    # `systemMessage` instead — valid for any hook event. JSON-encode via node when
    # available (safe escaping), else fall back to plain stderr WARN.
    MSG="adr-empirical-spot-check: $DIVERGENCE_COUNT divergence(s) in $ADR_ID — empirical_close_verify claims diverge from working tree. HIGH severity row written to .severity-state.tsv. See $LOG for details. Consider fresh-context sandwich-verifier dispatch (E.4 charter rule, post-cool-down)."
    if command -v node >/dev/null 2>&1; then
      node -e "process.stdout.write(JSON.stringify({systemMessage:process.argv[1]}))" "$MSG" 2>/dev/null \
        || printf '[adr-empirical-spot-check] WARN: %s\n' "$MSG" >&2
    else
      printf '[adr-empirical-spot-check] WARN: %s\n' "$MSG" >&2
    fi
  else
    echo "[$(date -Iseconds 2>/dev/null || date)] adr-empirical-spot-check: ${ADR_ID} clean (probed $(echo "$ZERO_CLAIMS" | wc -l | tr -d '[:space:]') claim(s))" >> "$HOOK_LOG"
  fi
done <<< "$PICKS"

exit 0
