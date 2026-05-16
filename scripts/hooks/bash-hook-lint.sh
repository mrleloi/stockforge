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

# === D3: Content-hash early-exit cache (S346 plan-023 DD-4 option-a).
# Per-file SHA256 cache prevents re-running all 10 checks on unchanged hook files.
# Cache file: $MEM_DIR/.bhl-cache-{sha256}.ok (empty sentinel; created when file passes all checks).
# On file content change: old SHA → no cache hit → all 10 checks re-run → new cache written.
# Cleanup: stale cache files older than 2h auto-deleted by the hoisted find below.
# S346 plan-023: expected wall ~3-5s warm cache (most hooks unchanged session-to-session).
# IMPORTANT: SHAs pre-computed ONCE at startup (stored in associative array) to avoid
# re-running sha256sum × 10 checks × 108 files = 1080 subprocess calls per invocation.
BHL_CACHE_DIR="$PROJECT_DIR/agent-workspace/memory"
find "$BHL_CACHE_DIR" -maxdepth 1 -name '.bhl-cache-*.ok' -mmin +120 -delete 2>/dev/null || true

# Pre-compute SHAs for all hook files in ONE pass (sha256sum batch).
# Also pre-load existing cache keys into an in-memory set (avoids per-check filesystem stat).
declare -A _BHL_SHA_MAP
declare -A _BHL_CACHED_SET  # key = sha, value = "1" if .ok file exists
if [ -d "$HOOKS_DIR" ]; then
  while IFS=' ' read -r sha fpath; do
    bn_key="${fpath##*/}"  # basename via parameter substitution — no subprocess
    _BHL_SHA_MAP["$bn_key"]="$sha"
  done < <(sha256sum "$HOOKS_DIR"/*.sh 2>/dev/null | grep -v 'bash-hook-lint.sh' || true)
fi
# Load existing cache SHAs in one glob scan (avoids per-check [ -f ] calls).
for _ck in "${BHL_CACHE_DIR}"/.bhl-cache-*.ok; do
  [ -f "$_ck" ] || continue
  _csha="${_ck##*/.bhl-cache-}"
  _csha="${_csha%.ok}"
  _BHL_CACHED_SET["$_csha"]="1"
done

# Helper: check if a hook file has a valid content-hash cache entry (pure in-memory lookup).
# Uses bash parameter substitution (no subprocess) for maximum speed on Windows MSYS2.
bhl_is_cached() {
  local f="$1"
  local bn_key="${f##*/}"  # basename via parameter substitution — no subprocess
  local sha="${_BHL_SHA_MAP[$bn_key]:-}"
  [ -n "$sha" ] && [ "${_BHL_CACHED_SET[$sha]:-}" = "1" ]
}

# Helper: write cache entry for a file (call ONLY after all checks pass with 0 violations for that file).
bhl_write_cache() {
  local f="$1"
  local bn_key="${f##*/}"  # basename via parameter substitution — no subprocess
  local sha="${_BHL_SHA_MAP[$bn_key]:-}"
  [ -n "$sha" ] && touch "${BHL_CACHE_DIR}/.bhl-cache-${sha}.ok" 2>/dev/null || true
}

emit() {
  local code="$1" file="$2" detail="$3"
  VIOLATIONS=$(( VIOLATIONS + 1 ))
  VIOLATION_LIST="${VIOLATION_LIST}  - ${code}: ${file} — ${detail}"$'\n'
}

# === Check 1: L-S11-1 Phase 0 portability — no python/jq/yq/pip/npm in scripts/hooks ===
# Exempt: comments, strings, and explicit Phase-1+ stubs marked with "# PHASE-1+" guard comment.
# S319b lint-calibration: skip-marker support added. A file containing the line
#   # bash-hook-lint:allow L-S11-1 <reason>
# is explicitly ratified as a false-positive (graceful fallback / Phase-1+ tool) and is
# excluded from this check. This is the detector-side fix for confirmed FPs; genuine
# violations (no fallback, no rationale) must still add the skip-marker with a real reason.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    # Skip self.
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    # D3: content-hash cache early-exit — skip if file unchanged since last clean run.
    bhl_is_cached "$f" && continue
    # S319b lint-calibration: honour explicit skip-marker (ratified false-positive or Phase-1+).
    if grep -qE '^[[:space:]]*#[[:space:]]*bash-hook-lint:allow L-S11-1' "$f" 2>/dev/null; then continue; fi
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
# S322 calibration: added third filter to exclude `awk ... '{printf "-...'` lines — the
# `printf` there is AWK's builtin, not shell's, and does not need the `--` sentinel.
# Discriminating pattern: `\{printf` (awk-script opening brace before printf) distinguishes
# awk-context printf from shell printf. Dual-property TC in bash-hook-lint-fire-test.sh.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
    BAD="$(grep -nE "printf[[:space:]]+['\"]-" "$f" 2>/dev/null | grep -vE "printf[[:space:]]+--" | grep -vE "\{printf" || true)"
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
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
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
    # Allow if the line ALSO contains a denial marker OR a negation-form of the regression
    # pattern (i.e. file is documenting the prohibition, not violating it). L-S69-1: artifact-
    # verifier hooks must whitelist legitimate canonical phrasings of the rule they enforce.
    HITS="$(grep -nE "$REGRESSION_PATTERN" "$t" 2>/dev/null || true)"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      if printf '%s' "$line" | grep -qiE 'fabricated|deprecated|anti-pattern|never user-authorized|do NOT|MUST NOT|forbidden|not user-authorized|no[[:space:]]+["]?(SUPERVISED|until[[:space:]]+Track|human-in-the-loop|autonomous_mode)|D-IDENTITY|bash-hook-lint'; then
        continue
      fi
      emit "D-IDENTITY-AUTONOMOUS-REGRESSION" "$rel" "live-config line matches forbidden pattern: $(printf '%s' "$line" | cut -c1-100)"
      break
    done <<< "$HITS"
  fi
done

# === Check 5: M-S51-1 grep-on-imagined-format anti-pattern (Pattern A) ===
# Origin: S51 T3.1 — promotion-cycle-trigger.sh greped literal `^\*\*Session N\*\*:` against
# real `## SXX —` header format → 0 matches → silent broken hook for ~12hr.
# Detection: literal "Session N" (capital-N placeholder; never a real header) appearing
# inside any grep/sed/awk argument. Also catches the variant with escaped asterisks.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
    BAD_A="$(grep -nE "(grep|sed|awk)[[:space:]].*Session N([^a-zA-Z0-9]|$)" "$f" 2>/dev/null | grep -vE "^[[:space:]]*[0-9]+:[[:space:]]*#" || true)"
    if [ -n "$BAD_A" ]; then
      emit "M-S51-1-IMAGINED-FORMAT" "$bn" "literal 'Session N' placeholder in grep/sed/awk pattern — verify against real current-execution.md format (L-S51-1)"
    fi
  done
fi

# === Check 6: L-S48m-1 CLAUDE_SESSION_ID empty-on-Windows anti-pattern (Pattern B) ===
# Origin: S48m profile-template-auto-populate.sh — marker filename used $CLAUDE_SESSION_ID
# without :- fallback; on Windows the env var is empty → marker collides on every fire →
# silent skip after first fire. L-S48m-1 fix: use session-log basename instead.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
    BAD_B="$(grep -nE "[\"]?\\.[a-zA-Z0-9_-]+(-fired|-marker|-ran|-flag)-\\\$\\{?CLAUDE_SESSION_ID" "$f" 2>/dev/null | grep -vE "^[[:space:]]*[0-9]+:[[:space:]]*#" || true)"
    if [ -n "$BAD_B" ]; then
      emit "L-S48m-1-CLAUDE-SESSION-ID-MARKER" "$bn" "marker filename uses \$CLAUDE_SESSION_ID (empty on Windows; silent skip — L-S48m-1)"
    fi
  done
fi

# === Check 6b: L-S108-1 CLAUDE_SESSION_ID fallback-to-constant anti-pattern (Pattern B') ===
# Origin: S108 qa-pending-auto-mover.sh — SID="${CLAUDE_SESSION_ID:-main}" then
# MARKER="...-${SID}". CLAUDE_SESSION_ID empty on Windows → fallback "main" shared across
# ALL sessions → marker filename collides → permanent idempotency lockout (M-S108-1: bundle
# stuck in pending/ for 24+h). Check 6 only catches DIRECT $CLAUDE_SESSION_ID in marker;
# misses INDIRECT-via-VAR form. Fix: use date hour-bucket or session-log basename.
#
# Detection: file has BOTH (a) fallback-to-constant assignment AND (b) a marker filename
# pattern using the SAME session-ID-derived VAR (not date-bucket variables).
#
# S319b lint-calibration: narrowed (b) to exclude date-bucket variables (BUCKET/TODAY/DATE_HR
# and similar) that are CORRECTLY used for hour-bucketed idempotency. The original broad
# regex matched ANY uppercase variable, causing false-positives on files that already use
# the correct hour-bucket pattern alongside a benign ${CLAUDE_SESSION_ID:-unknown} for a
# performance-cache filename. The lock-out risk only exists when the MARKER uses a
# session-ID-derived variable (one whose name suggests session identity: SID/SESSION/SESS
# or the raw CLAUDE_SESSION_ID). Date-bucket vars are correctly keyed to time, not session.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
    # (a) Suspicious assignment: ${CLAUDE_SESSION_ID:-WORD} where WORD is alphabetic
    HAS_FALLBACK="$(grep -nE '\$\{CLAUDE_SESSION_ID:-[a-zA-Z][a-zA-Z0-9_-]*\}' "$f" 2>/dev/null | grep -vE "^[[:space:]]*[0-9]+:[[:space:]]*#" || true)"
    if [ -n "$HAS_FALLBACK" ]; then
      # (b) Marker filename using session-ID-derived variable (SID/SESSION/SESS/CLAUDE_SESSION_ID).
      # S319b: explicitly EXCLUDES date-bucket variables (BUCKET, TODAY, DATE_HR, DATE_BUCKET,
      # HOUR, TS_BUCKET) which are correctly keyed to time and do NOT cause cross-session collision.
      # S321 MINOR-2 fix: the trailing [^A-Z_] boundary defeated the SESSION arm because
      # SESSION_ID has underscore after SESSION, failing [^A-Z_]. Fix: allow (_ID)? before
      # the trailing boundary so SESSION_ID is matched, then require a non-uppercase char.
      HAS_MARKER="$(grep -nE '\.[a-zA-Z0-9_-]+-(fired|marker|ran|flag|written|pending)-\$\{?(SID|SESSION(_ID)?|SESS|CLAUDE_SESSION_ID)[^A-Z_]' "$f" 2>/dev/null | grep -vE "^[[:space:]]*[0-9]+:[[:space:]]*#" || true)"
      if [ -n "$HAS_MARKER" ]; then
        emit "L-S108-1-CLAUDE-SESSION-ID-FALLBACK-CONSTANT" "$bn" "fallback-to-constant \${CLAUDE_SESSION_ID:-WORD} + marker filename present (likely per-session lockout on Windows; use date hour-bucket or session-log basename — L-S108-1)"
      fi
    fi
  done
fi

# === Check 7: L-S48d-1 pipefail+ERR-trap+bare-grep anti-pattern (Pattern C) — REFINED S58 ===
# Origin: S48d profile-template-auto-populate.sh — set -uo pipefail + trap 'exit 0' ERR
# + bare `grep -m1 ...` returning nonzero on no-match → ERR trap fires silently → script
# exits 0 with NO log line → invisible failure. Fix: wrap each grep with `|| true` or
# convert to `if grep ...; then ... fi` form.
#
# S54 refinement: caught command-sub + pipeline forms (was bare-line only).
#
# S58 refinement (closes KI-S54-1): replaces the 3-pass grep filter with an awk script
# that tracks pipefail-bracket state + multi-line `\`-continuation joining + 4 NEW
# false-positive recognitions surfaced by S57 ratify-via-comment categorization sample:
#
#   NEW skip rules:
#     (1) Compound conditional `if X && grep`/`if X | grep`/`elif X && grep`/etc — line
#         starts with `if|while|until|elif` AND contains `grep` (cond exit consumed by `if`)
#     (2) Alt-guard `|| echo NN`/`|| echo ""`/`|| echo` end-of-pipeline (substitute
#         non-zero with echo output → command-sub/pipeline returns 0 → ERR trap exempt)
#     (3) Alt-guard `|| exit N`/`|| return N` (explicit exit handling)
#     (4) Pipefail-bracket `set +o pipefail; grep; set -o pipefail` (pipefail temporarily
#         disabled so grep no-match is safe; double-defense pattern)
#
# Plus existing skip rules (preserved):
#   - Comment lines (`^NN:#`)
#   - Direct conditional `if grep`/`while grep`/`until grep`/`elif grep`
#   - Already-guarded `|| true`/`|| :`
#
# Multi-line `\`-continuation: physical lines ending with `\` are joined with the next
# physical line before pattern testing (catches drift-signals-D1-D9.sh:178-180 form
# where alt-guard `|| echo 0` is on the LAST continuation line of a 3-line pipeline).
#
# Initial pipefail state: OFF (matches bash default; flips ON when first
# `set -[a-zA-Z]*o pipefail` seen; flips OFF when `set +o pipefail` seen).
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
    # Clean 0/1 (per L-S80-2: avoids "0\n0" multi-line from `grep -c ... || echo 0` race that breaks awk -v / [ test downstream)
    if grep -qE 'set [^#]*pipefail' "$f" 2>/dev/null; then HAS_PIPEFAIL=1; else HAS_PIPEFAIL=0; fi
    if grep -qE 'trap[[:space:]]+[^#]*ERR' "$f" 2>/dev/null; then HAS_ERR_TRAP=1; else HAS_ERR_TRAP=0; fi
    if [ "$HAS_PIPEFAIL" = 1 ] && [ "$HAS_ERR_TRAP" = 1 ]; then
      VIOLATION_LINE="$(awk '
BEGIN { pipefail_off = 1; carry = "" }
{
  line = $0
  # S319b lint-calibration: FIXED carry-line detection (was /\\$/ which matched
  # any line containing dollar-sign on Windows/GNU-awk 5.3.2, false-joining
  # variable lines and losing per-line if-guard context).
  # M-S80-1 family + S319a KEY FINDING: /\\$/ matches literal "$" on this platform.
  # Fix: substr last-char compare — unambiguous on all platforms.
  if (length(line) > 0 && substr(line, length(line)) == "\\") {
    sub(/\\$/, "", line)
    carry = (carry == "" ? line : carry " " line)
    next
  }
  full = (carry == "" ? line : carry " " line)
  carry = ""

  if (full ~ /^[[:space:]]*set[[:space:]]+\+o[[:space:]]+pipefail/) {
    pipefail_off = 1
    next
  }
  if (full ~ /^[[:space:]]*set[[:space:]]+-[a-zA-Z]*o[[:space:]]+pipefail/) {
    pipefail_off = 0
    next
  }
  if (pipefail_off) next
  if (full ~ /^[[:space:]]*#/) next
  if (full ~ /grep[[:space:]]/) {
    if (full ~ /^[[:space:]]*(if|while|until|elif)[[:space:]]/) next
    if (full ~ /grep[[:space:]].*[[:space:]](&&|\|\|)[[:space:]]/) next
    # S322 calibration: skip if the logical line (possibly multi-continuation joined) starts
    # with `(` — signals a `( ... ) || true` subshell-guard block. The grep(s) inside the
    # subshell are protected by the outer `|| true` on the matching `)` closing line.
    # Dual-property TC in bash-hook-lint-fire-test.sh: TC-C-subshell-guard (not flagged)
    # + TC-C-subshell-real (genuine bare-grep not inside subshell still flagged).
    if (full ~ /^[[:space:]]*\(/) next
    # S319b: skip if grep appears ONLY after a trailing inline comment marker.
    # Handles lines like `cmd   # grep foo` where grep is in the comment, not a command.
    # S321 MINOR-1 fix: tightened heuristic — only treat "#" as a comment start when it is
    # preceded by whitespace, ";" or "&" (i.e. a shell word-boundary). This prevents a "#"
    # inside a quoted string (e.g. echo "a#b") from suppressing a genuine grep that follows.
    # WRONG (S319b): hash_pos = index(full, "#")  — matches any "#" anywhere, incl. in strings.
    # RIGHT: match(full, /[[:space:];&#]/) then test char at that position is "#".
    comment_pos = 0
    n = split(full, chars, "")
    for (ci = 2; ci <= n; ci++) {
      prev = chars[ci-1]
      if (chars[ci] == "#" && (prev == " " || prev == "\t" || prev == ";" || prev == "&")) {
        comment_pos = ci; break
      }
    }
    grep_pos = index(full, "grep")
    if (comment_pos > 0 && comment_pos < grep_pos) next
    print NR ":" full
    exit
  }
}
' "$f" 2>/dev/null || true)"
      if [ -n "$VIOLATION_LINE" ]; then
        emit "L-S48d-1-PIPEFAIL-BARE-GREP" "$bn" "pipefail + ERR trap + grep without guard — silent fail risk (L-S48d-1; refined S58 to recognize compound-if + alt-guard echo/exit/return + pipefail-bracket + multi-line continuation)"
      fi
    fi
  done
fi

# === Check 8: L-S53-2 unanchored positional-marker grep (NEW Pattern D) — S54 ===
# Origin: S53 M-S53-2 — `session-export-raw.sh` Method 1 grep `'S[0-9]+[[:space:]]+NEXT'`
# without ^ anchor matched archive prose mid-line "S38/S42 NEXT branching gate" →
# returned false-positive 42 every export, silently corrupted ALL raw-session filenames.
# Detection: 2-pass — (a) find grep lines whose pattern contains routing-marker regex
# tokens (S[0-9]+, Track [0-9]+, Session N, Session [0-9]+, ## S[0-9]+); (b) exclude
# lines where the pattern body starts with `^` anchor (whitelist).
#
# S319b lint-calibration: skip-marker support added. A file containing the line
#   # bash-hook-lint:allow L-S53-2 <reason>
# is explicitly ratified as a false-positive (content-search context / basename token /
# free-form user-input where ^ anchor would be semantically wrong). Per L-S55-1: ratify
# via detector-side skip-marker, not via comment on the grep line itself (which does
# not silence the lint per the ratify-via-comment trap documented in § Risks & Gotchas).
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
    # S319b lint-calibration: honour explicit skip-marker (ratified false-positive).
    if grep -qE '^[[:space:]]*#[[:space:]]*bash-hook-lint:allow L-S53-2' "$f" 2>/dev/null; then continue; fi
    BAD_D="$(grep -nE "grep[[:space:]]+(-[a-zA-Z][a-zA-Z0-9]*[[:space:]]+)*['\"][^'\"]*(S\[0-9\]\+|Track[[:space:]]+\[0-9|Session[[:space:]]+(N|\[0-9)|## S\[0-9)" "$f" 2>/dev/null \
      | grep -vE "grep[[:space:]]+(-[a-zA-Z][a-zA-Z0-9]*[[:space:]]+)*['\"]\^" \
      | grep -vE '^[[:space:]]*[0-9]+:[[:space:]]*#' \
      || true)"
    if [ -n "$BAD_D" ]; then
      emit "L-S53-2-UNANCHORED-POSITIONAL-GREP" "$bn" "grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)"
    fi
  done
fi

# === Check 9: L-S68-2 family — find/ls on possibly-missing path under pipefail+ERR-trap (NEW S80) ===
# Origin: 4 instances across S68/S75/S76/S78. Family precondition: file has BOTH `set -*o pipefail`
# AND `trap ... ERR`. In that mode, `find $missing -mtime`/`ls $dir/*.glob` returns rc=1 silently
# if path missing or glob has no match → ERR trap fires → script silent-exits 0 BEFORE work runs.
#
# Variants (combined detector):
#   (a) Single-path `find $path -...` (literal var; no glob) — S68+S75
#   (b) `ls $dir/*.glob` (no-match returns rc=1 under pipefail) — S76
#   (c) Multi-path `find $a $b $c -...` (rc=1 if ANY arg missing) — S78
#
# Skip rules (all three variants):
#   - Comment lines (^NN: # )
#   - Line starts with `if|while|until|elif`
#   - Alt-guarded with `|| true|:|return|exit|echo`
#   - Errors silenced with `2>/dev/null`
#   - Pipefail bracket disabled (`set +o pipefail` in effect)
#   - File-test guard `[ -d ... ]` or `[ -f ... ]` on SAME line (catches `[ -d $X ] && find $X`)
#   - Variant (b) only: `shopt -s nullglob` set anywhere above (glob no-match → empty list, no rc=1)
#
# Multi-line `\`-continuation: physical lines joined with carry before pattern-matching, so multi-arg
# find spread across multiple lines is tested as one logical line (catches `2>/dev/null` on tail).
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
    # Clean 0/1 (per L-S80-2: avoids "0\n0" multi-line from `grep -c ... || echo 0` race that breaks awk -v / [ test downstream)
    if grep -qE 'set [^#]*pipefail' "$f" 2>/dev/null; then HAS_PIPEFAIL=1; else HAS_PIPEFAIL=0; fi
    if grep -qE 'trap[[:space:]]+[^#]*ERR' "$f" 2>/dev/null; then HAS_ERR_TRAP=1; else HAS_ERR_TRAP=0; fi
    if [ "$HAS_PIPEFAIL" = 1 ] && [ "$HAS_ERR_TRAP" = 1 ]; then
      # Clean 0/1 (avoids "0\n0" from `grep -c` exit-1 + `|| echo 0` race that breaks awk's numeric coercion)
      if grep -qE '^[[:space:]]*shopt[[:space:]]+-s[[:space:]]+nullglob' "$f" 2>/dev/null; then HAS_NULLGLOB=1; else HAS_NULLGLOB=0; fi
      VIOLATION_LINE_E="$(awk -v has_nullglob="$HAS_NULLGLOB" '
BEGIN { pipefail_off = 1; carry = "" }
{
  line = $0
  # S319b lint-calibration: FIXED carry-line detection (same fix as Check 7).
  # Was /\\$/ which on Windows/GNU-awk 5.3.2 matches any line containing "$"
  # (dollar sign), not lines ending with literal backslash. Using substr instead.
  if (length(line) > 0 && substr(line, length(line)) == "\\") {
    sub(/\\$/, "", line)
    carry = (carry == "" ? line : carry " " line)
    next
  }
  full = (carry == "" ? line : carry " " line)
  carry = ""

  if (full ~ /^[[:space:]]*set[[:space:]]+\+o[[:space:]]+pipefail/) { pipefail_off = 1; next }
  if (full ~ /^[[:space:]]*set[[:space:]]+-[a-zA-Z]*o[[:space:]]+pipefail/) { pipefail_off = 0; next }
  if (pipefail_off) next
  if (full ~ /^[[:space:]]*#/) next

  body = full
  sub(/^[[:space:]]+/, "", body)

  # Skip lines starting with conditional keywords
  if (body ~ /^(if|while|until|elif)[[:space:]]/) next

  # Skip alt-guarded with || true|:|return|exit|echo
  if (full ~ /\|\|[[:space:]]+(true|:|return|exit|echo)/) next

  # Skip if errors silenced
  if (full ~ /2>\/dev\/null/) next

  # Skip if same-line file-test guard (catches `[ -d $X ] && find $X`)
  if (full ~ /\[[[:space:]]+-[df][[:space:]]+/) next

  # === Variant (a) + (c): find <var/literal>... ===
  # Match `find` token followed by quoted/unquoted $var arg.
  if (body ~ /(^|[[:space:]`(|&;])find[[:space:]]+["]?\$/) {
    print NR ":(find-variant) " full
    exit
  }

  # === Variant (b): ls $dir/*.glob ===
  # Match `ls` token followed by arg(s) containing a `$var` AND a glob `*` somewhere after.
  # Permissive on intermediate chars (handles `ls "$DIR"/*.md`, `ls ${X}/*.tsv`, etc.).
  # Skip if shopt -s nullglob set in file (glob no-match → empty list, no rc=1).
  if (has_nullglob == 0 && body ~ /(^|[[:space:]`(|&;])ls[[:space:]]+[^|&;]*\$[^|&;]*\*/) {
    print NR ":(ls-glob-variant) " full
    exit
  }
}
' "$f" 2>/dev/null || true)"
      if [ -n "$VIOLATION_LINE_E" ]; then
        emit "L-S68-2-FIND-LS-MISSING-PATH" "$bn" "find/ls on possibly-missing path under pipefail+ERR-trap — silent exit risk if path missing (L-S68-2 family; 4 instances S68/S75/S76/S78). Use [ -d \$X ]/[ -f \$X ] guard, OR add 2>/dev/null + || true, OR conditional form."
      fi
    fi
  done
fi

# === Check 10: L-S80-2 grep-c-OR-echo capture trap (Pattern F, NEW S81) ===
# Origin: S80 T2 debug — bash-hook-lint.sh HAS_NULLGLOB extracted via
#   `HAS_NULLGLOB="$(grep -c ... 2>/dev/null || echo 0)"` produces multi-line "0\n0" when grep
# finds 0 + exits 1 (because grep -c always prints "0" THEN || fires → echo prints another "0"
# → captured stdout is "0\n0"). Passing to awk `-v var=...` then `var == 0` evaluates as
# string "0\n0" != numeric 0 → false-negative; nullglob detection skipped → ls-glob detector
# fires false-positive. Recovered S80 via if/then/fi clean-integer fix.
#
# Detection: VAR=$(... grep -c ... || echo <N> ...) with || INSIDE the $() (capture trap).
# The form is intrinsic to grep -c semantics + || short-circuit, regardless of pipefail/ERR-trap
# state — so no precondition check (unlike Check 7/9 family).
#
# Skip rules:
#   - Comment lines (^NN:#)
# NOTE: intermediate flattener pipes (`| head`, `| tr -d`, `| awk`) do NOT reliably mitigate
# under `set -o pipefail` — pipeline still propagates grep's non-zero exit → || still fires →
# echo appends its own newline → multi-line capture survives. Always-flag; only fix is if/then/fi.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    bhl_is_cached "$f" && continue
    VIOLATION_LINE_F="$(awk '
/^[[:space:]]*#/ { next }
{
  # Pattern F: =$( ... grep ... -c ... || echo <N> ... )  with || INSIDE the $()
  # `[^)]*` between `$(` and `)` rejects nested `)` (rare in practice; acceptable FN).
  # No flattener-pipe skip rule: under `set -o pipefail` the pipeline returns non-zero
  # when grep returns 1, so `|| echo N` fires regardless of intermediate `head`/`tr -d`/`awk`,
  # and echo appends its own newline → multi-line capture survives the flattener.
  # Only safe mitigation = if/then/fi clean-integer form.
  if ($0 !~ /=[[:space:]]*"?\$\([^)]*grep[^)]*[[:space:]]-c[A-Za-z]*[[:space:]][^)]*\|\|[[:space:]]*echo[[:space:]]+[0-9]/) next
  print NR ":" $0
  exit
}
' "$f" 2>/dev/null || true)"
    if [ -n "$VIOLATION_LINE_F" ]; then
      emit "L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP" "$bn" "VAR=\$(grep -c ... || echo N) produces multi-line \"0\\nN\" capture when grep finds 0 + exits 1 → breaks awk -v numeric coercion downstream (L-S80-2). Fix: if grep -qE ...; then VAR=1; else VAR=0; fi (clean integer)."
    fi
  done
fi

# === D3: Write content-hash cache for hook files with 0 violations (S346 plan-023 DD-4 option-a).
# Any file whose basename appears in VIOLATION_LIST is dirty → skip cache.
# All other hook files get a cache entry so future runs skip them on warm-cache.
if [ -d "$HOOKS_DIR" ]; then
  for f in "$HOOKS_DIR"/*.sh; do
    [ ! -f "$f" ] && continue
    bn="${f##*/}"
    [ "$bn" = "bash-hook-lint.sh" ] && continue
    # Skip if already cached (bhl_is_cached avoids redundant SHA computation).
    bhl_is_cached "$f" && continue
    # Skip if this file appeared in any violation (VIOLATION_LIST contains "  - CODE: bn — ...")
    if printf '%s' "$VIOLATION_LIST" | grep -qF ": $bn — " 2>/dev/null; then continue; fi
    bhl_write_cache "$f"
  done
fi

# === Emit results ===
# S318: fixed-name idempotent notification (per-fire timestamps caused 682-file spam); cleared when violations resolve. History stays in .session-hooks.log.
NOTIF_FILE="$NOTIF_DIR/bash-hook-lint-warn.md"
if [ "$VIOLATIONS" -gt 0 ]; then
  printf '[%s] bash-hook-lint WARN %d violation(s):\n%s' "$TS" "$VIOLATIONS" "$VIOLATION_LIST" >> "$LOG"
  if [ -d "$NOTIF_DIR" ]; then
    {
      printf '# bash-hook-lint — Warnings\n\n'
      printf 'Per L-S11-1 + L-S13-1 + S16 D-IDENTITY (S15 close user correction): %d violation(s) detected.\n\n' "$VIOLATIONS"
      printf '%s' "$VIOLATION_LIST"
      printf '\nFix:\n'
      printf '- L-S11-1: replace python/jq/yq/pip/npm with bash + POSIX equivalents (Phase 0 portability)\n'
      printf '- L-S13-1: ensure declared LOG/FILE/OUTPUT vars get used as `>> "$VAR"` or read source\n'
      printf '- D-IDENTITY: live config must NOT reference SUPERVISED mode / autonomous_mode=false / until-Track-7 framing\n'
      printf -- '- L-S43b-9: replace `printf "-..."` or `printf "\047-..."\047` with `printf -- "-..."` to disambiguate format from option flag\n'
      printf '- M-S51-1 (Pattern A): replace literal `Session N` placeholder in grep/sed/awk with real `## S[0-9]+` header pattern (verify against current-execution.md format)\n'
      printf '- L-S48m-1 (Pattern B): use session-log basename (NOT $CLAUDE_SESSION_ID empty-on-Windows) for marker filenames\n'
      printf '- L-S48d-1 (Pattern C): wrap grep usages with `|| true` (or `|| :`); use `if grep ...; then` form for conditionals; applies to bare-line + pipeline + command-substitution `$(grep ...)` forms (S54 refined)\n'
      printf '- L-S53-2 (Pattern D, NEW S54): anchor positional-marker grep patterns with `^` (e.g. `grep -E "^S[0-9]+ NEXT"` not `grep -E "S[0-9]+ NEXT"`) to prevent mid-line archive-prose false-positives\n'
      printf '- L-S68-2 (Pattern E, NEW S80): wrap `find $var ...` / `ls $dir/*.glob` with `2>/dev/null` + `|| true`, OR add `[ -d "$X" ] && find ...` same-line guard, OR `if find ...; then` conditional form. Three variants caught: (a) single-path find (S68+S75); (b) ls glob no-match (S76); (c) multi-path find (S78). Family precondition: file has both `set -*o pipefail` AND `trap ... ERR`.\n'
      printf '- L-S80-2 (Pattern F, NEW S81): replace `VAR=$(grep -c ... || echo N)` with `if grep -qE ...; then VAR=1; else VAR=0; fi` (clean integer). The antipattern produces multi-line "0\\nN" when grep finds 0 + exits 1 (grep -c always prints count THEN || fires → echo appends N) → breaks awk -v numeric coercion (`var == 0` evaluates as string mismatch) and `[ "$VAR" = 0 ]`/`-eq 0` becomes fragile. Under `set -o pipefail`, intermediate `| head`/`| tr -d`/`| awk` does NOT fully mitigate (pipeline still returns non-zero → || still fires → echo appends newline) — only if/then/fi clean-integer form is safe.\n'
    } > "$NOTIF_FILE" 2>/dev/null || true
  fi
else
  printf '[%s] bash-hook-lint OK (0 violations)\n' "$TS" >> "$LOG"
  rm -f "$NOTIF_FILE" 2>/dev/null || true
fi

exit 0
