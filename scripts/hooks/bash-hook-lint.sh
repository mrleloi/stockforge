#!/usr/bin/env bash
# bash-hook-lint.sh — composite static-lint for scripts/hooks/*.sh (Phase 0 portability +
# producer-consumer integrity) AND a fabricated-default drift scanner for stockforge LIVE
# config. Implements L-S11-1 (Phase 0 hook portability), L-S13-1 (producer-consumer log
# path mismatch), and S16 success criterion #10 (drift signal D11 / D-IDENTITY extension
# scanning for fabricated SUPERVISED-mode regression in autonomous_mode=true ONLY-mode
# stockforge).
#
# Wires: Stop hook in .claude/settings.json. Soft-warn only (exit 0 always; never blocks).
# Output: per-violation lines to .session-hooks.log + (if violations >0) one notification
# file in human-workspace/notifications/.
#
# Per Q-E2 (closed S15 Batch 1): promotion frequency = phase-boundary; this hook detects
# drift continuously but does NOT auto-promote. Surface to agent who triages next turn.
# Per Q-E3 (closed S15 Batch 1): promotion priority = hook FIRST, skill SECOND, charter LAST.
# Phase 0 portability: bash + POSIX only. L-S10-1: if/then/fi only; split-local.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HOOKS_DIR="$PROJECT_DIR/scripts/hooks"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

VIOLATIONS=0
VIOLATION_LIST=""

emit() {
  local code="$1" file="$2" detail="$3"
  VIOLATIONS=$(( VIOLATIONS + 1 ))
  VIOLATION_LIST="${VIOLATION_LIST}  - ${code}: ${file} — ${detail}"$'\n'
}

# === Check 1: L-S11-1 Phase 0 portability — no python/jq/yq/pip/npm in scripts/hooks ===
# Exempt: comments, strings, and explicit Phase-1+ stubs marked with "# PHASE-1+" guard comment.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="$(basename "$f")"
    # Skip self.
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    # Strip comments + heredocs roughly: scan only "executable" lines (not # comments).
    NON_COMMENT="$(grep -vE '^[[:space:]]*#' "$f" 2>/dev/null || true)"
    # Look for forbidden tooling invocations as command tokens.
    if printf '%s' "$NON_COMMENT" | grep -qE '(^|[[:space:]`(|&;])(python3?|jq|yq|pip|pip3|npm|pnpm)([[:space:]]|$)'; then
      emit "L-S11-1-PORTABILITY" "$bn" "non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only"
    fi
  done
fi

# === Check 4: L-S43b-9 printf format-string starting with `-` needs `--` sentinel ===
# `printf '-foo'` interprets `-foo` as an option flag, not as the format string. Fix is
# `printf -- '-foo'`. Encountered 2x during HR-3 deploy per L-S43b-9. False-positive-safe:
# matches only lines where printf is followed by a literal quoted dash, AND the same line
# does NOT also contain `printf --` (which means the sentinel is already present).
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="$(basename "$f")"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    BAD="$(grep -nE "printf[[:space:]]+['\"]-" "$f" 2>/dev/null | grep -vE "printf[[:space:]]+--" || true)"
    if [ -n "$BAD" ]; then
      emit "L-S43b-9-PRINTF-DASH" "$bn" "printf format starts with '-' without '--' sentinel — use 'printf -- ...'"
    fi
  done
fi

# === Check 2: L-S13-1 producer-consumer log path mismatch (silent telemetry brick) ===
# Heuristic: declared LOG-like variable but never used as redirect target within same file.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="$(basename "$f")"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    # Extract variable names matching *LOG*|*FILE*|*OUTPUT*|*PATH* pattern that get assigned a path-looking value.
    DECL_VARS="$(grep -oE '^[A-Z_]+(LOG|FILE|OUTPUT|PATH|DIR)[A-Z_]*=' "$f" 2>/dev/null | sed 's/=$//' | sort -u || true)"
    for v in $DECL_VARS; do
      [ -z "$v" ] && continue
      # Skip universally-known env vars that are inputs not outputs.
      case "$v" in
        PROJECT_DIR|HOOKS_DIR|CLAUDE_PROJECT_DIR|HOOK_LOG|LOOP_DIR|DOGFOOD_DIR|NOTIF_DIR|EVENTS_DIR|INDEX_DIR|ARCHIVE_DIR) continue ;;
      esac
      # Check for "$VAR" or ${VAR} appearing on right side of >> or > redirect, OR as `tee $VAR`.
      if ! grep -qE "(>>?|tee[[:space:]]+(-a[[:space:]]+)?)[[:space:]]*[\"]?\\\$\\{?${v}\\}?" "$f" 2>/dev/null; then
        # Also accept if VAR is read FROM, or is a path argument to common command (find/cd/test/ls/mkdir/cp/mv/echo/printf/...)
        if ! grep -qE "[\"]?\\\$\\{?${v}\\}?" "$f" 2>/dev/null | grep -qvE "^[A-Z_]+="; then
          # Final fallback: any non-assignment line referencing the var counts as "used".
          if ! grep -vE "^[[:space:]]*${v}=" "$f" 2>/dev/null | grep -qE "[\"]?\\\$\\{?${v}\\}?[\"]?"; then
            emit "L-S13-1-ORPHAN-LOG-VAR" "$bn" "variable \$${v} declared but never referenced after assignment"
          fi
        fi
      fi
    done
  done
fi

# === Check 3: D-IDENTITY S16 #10 — fabricated SUPERVISED-mode regression in LIVE config ===
# Per S15-close user correction (CHARTER-tier): full autonomous is the ONLY mode; "SUPERVISED"
# was a fabricated default-until-Track-7 framing that was never user-authorized. Scan LIVE
# config files; flag any `SUPERVISED|autonomous_mode:\s*false|until Track 7` regression.
# Exempt historical session/checkpoint/decision/Q&A files (they record past state legitimately).
LIVE_TARGETS=(
  "$PROJECT_DIR/.claude/settings.json"
  "$PROJECT_DIR/agent-workspace/memory/current-execution.md"
  "$PROJECT_DIR/agent-workspace/memory/project.md"
  "$PROJECT_DIR/CLAUDE.md"
  "$PROJECT_DIR/AGENT_OPERATING_MANUAL.md"
)
# Live constitution + proposals (excluding archived/superseded versions).
if [ -d "$PROJECT_DIR/agent-workspace/constitution" ]; then
  while IFS= read -r -d '' p; do LIVE_TARGETS+=("$p"); done < <(find "$PROJECT_DIR/agent-workspace/constitution" -maxdepth 1 -name '*.md' -type f -print0 2>/dev/null)
fi
if [ -d "$PROJECT_DIR/agent-workspace/proposals" ]; then
  while IFS= read -r -d '' p; do LIVE_TARGETS+=("$p"); done < <(find "$PROJECT_DIR/agent-workspace/proposals" -maxdepth 1 -name '*.md' -type f -print0 2>/dev/null)
fi

REGRESSION_PATTERN='SUPERVISED[[:space:]]*mode|autonomous_mode:[[:space:]]*false|until[[:space:]]+Track[[:space:]]+7|SUPERVISED-only'
for t in "${LIVE_TARGETS[@]}"; do
  [ ! -f "$t" ] && continue
  rel="${t#$PROJECT_DIR/}"
  # Scan; deny pattern matches but allow file to legitimately quote/document the rule itself.
  if grep -qE "$REGRESSION_PATTERN" "$t" 2>/dev/null; then
    # Allow if the line ALSO contains "fabricated|deprecated|anti-pattern|never user-authorized"
    # (i.e. file is documenting the prohibition, not violating it).
    HITS="$(grep -nE "$REGRESSION_PATTERN" "$t" 2>/dev/null || true)"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      if printf '%s' "$line" | grep -qiE 'fabricated|deprecated|anti-pattern|never user-authorized|do NOT|MUST NOT|forbidden|not user-authorized'; then
        continue
      fi
      emit "D-IDENTITY-AUTONOMOUS-REGRESSION" "$rel" "live-config line matches forbidden pattern: $(printf '%s' "$line" | cut -c1-100)"
      break
    done <<< "$HITS"
  fi
done

# === Emit results ===
if [ "$VIOLATIONS" -gt 0 ]; then
  printf '[%s] bash-hook-lint WARN %d violation(s):\n%s' "$TS" "$VIOLATIONS" "$VIOLATION_LIST" >> "$LOG"
  if [ -d "$NOTIF_DIR" ]; then
    TS_FILE="$(date -u +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
    NOTIF_FILE="$NOTIF_DIR/$TS_FILE-bash-hook-lint-warn.md"
    {
      printf '# bash-hook-lint — Warnings\n\n'
      printf 'Per L-S11-1 + L-S13-1 + S16 D-IDENTITY (S15 close user correction): %d violation(s) detected.\n\n' "$VIOLATIONS"
      printf '%s' "$VIOLATION_LIST"
      printf '\nFix:\n'
      printf '- L-S11-1: replace python/jq/yq/pip/npm with bash + POSIX equivalents (Phase 0 portability)\n'
      printf '- L-S13-1: ensure declared LOG/FILE/OUTPUT vars get used as `>> "$VAR"` or read source\n'
      printf '- D-IDENTITY: live config must NOT reference SUPERVISED mode / autonomous_mode=false / until-Track-7 framing\n'
      printf -- '- L-S43b-9: replace `printf "-..."` or `printf "\047-..."\047` with `printf -- "-..."` to disambiguate format from option flag\n'
    } > "$NOTIF_FILE" 2>/dev/null || true
  fi
else
  printf '[%s] bash-hook-lint OK (0 violations)\n' "$TS" >> "$LOG"
fi

exit 0
