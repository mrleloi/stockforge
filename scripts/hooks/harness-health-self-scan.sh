#!/usr/bin/env bash
# harness-health-self-scan.sh — continuous harness-health verification.
# Implements 12-signal catalog HH-1..HH-12 codified in agent-workspace/{proposals,constitution}/harness-health-protocol.md
# (currently at proposals/; mv to constitution/ pending M-S173-1 deny-lift workaround).
# Triggers: UserPromptSubmit (every prompt; same-session caching) + SessionStart (each session entry).
# Phase 3.5 T6 deliverable; D-035 ratified S173 via AskUserQuestion Q3=A.
# <2s perf budget on UserPromptSubmit. Exit 0 ALWAYS (informational, not blocking).
# bash-hook-lint:allow L-S11-1 python3 is ONLY a fallback for `date -d` math (date -d ... || python3 ...); primary is bash-builtin date; graceful degradation.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SID="${CLAUDE_SESSION_ID:-unknown}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
HEALTH_LOG="$PROJECT_DIR/agent-workspace/memory/.harness-health.log"
CACHE="$PROJECT_DIR/agent-workspace/memory/.harness-health-cache-${SID}"
TS="$(date -Iseconds)"

# === Same-session cache check (5-min TTL) ===
if [ -f "$CACHE" ]; then
  CACHE_MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null || echo 0)
  AGE=$(( $(date +%s) - CACHE_MTIME ))
  if [ "$AGE" -lt 300 ]; then
    echo "[$TS] harness-health-self-scan: CACHE-HIT age=${AGE}s session=$SID" >> "$HOOK_LOG"
    exit 0
  fi
fi

# === Aggregation counters ===
HIGH=0
MEDIUM=0
LOW=0
SKIP=0
FAIL_DETAILS=""

emit_fail() {
  local signal="$1" sev="$2" detail="$3"
  case "$sev" in
    HIGH) HIGH=$((HIGH + 1)) ;;
    MEDIUM) MEDIUM=$((MEDIUM + 1)) ;;
    LOW) LOW=$((LOW + 1)) ;;
  esac
  FAIL_DETAILS="${FAIL_DETAILS}${signal}=${sev}(${detail});"
  printf '[%s] %s sev=%s detail=%s session=%s\n' "$TS" "$signal" "$sev" "$detail" "$SID" >> "$HEALTH_LOG"
}

emit_skip() {
  SKIP=$((SKIP + 1))
  printf '[%s] %s SKIP=%s session=%s\n' "$TS" "$1" "$2" "$SID" >> "$HEALTH_LOG"
}

# === HH-1: Stop hook fires ≥1/session (KI-S49b-1 suppress: HIGH→MEDIUM) ===
HH1_check() {
  [ ! -f "$HOOK_LOG" ] && { emit_skip "HH-1" "log-missing"; return; }
  local start_line stop_count
  # S319b L-S48d-1: add || true so grep no-match (rc=1) does not tip ERR trap.
  start_line=$(grep -n "SessionStart session=$SID" "$HOOK_LOG" 2>/dev/null | tail -1 | cut -d: -f1 || true)
  [ -z "$start_line" ] && { emit_skip "HH-1" "no-SessionStart-for-SID"; return; }
  # L-S80-2: avoid VAR=$(... grep -c ... || echo 0) multi-line capture trap.
  if awk "NR>$start_line" "$HOOK_LOG" 2>/dev/null | grep -q "Stop session=$SID"; then stop_count=1; else stop_count=0; fi
  if [ "$stop_count" -lt 1 ]; then
    # KI-S49b-1 suppression check
    local sev="HIGH"
    [ -f "$PROJECT_DIR/agent-workspace/memory/.harness-health-ki-S49b-1" ] && sev="MEDIUM"
    emit_fail "HH-1-STOP-NOT-FIRING" "$sev" "stop_count=0 (Windows quirk M-S49b-1)"
  fi
}

# === HH-2: UserPromptSubmit ≥1 fire in last 10 min ===
HH2_check() {
  [ ! -f "$HOOK_LOG" ] && { emit_skip "HH-2" "log-missing"; return; }
  local cutoff recent
  cutoff=$(date -d "10 min ago" -Iseconds 2>/dev/null || python3 -c "import datetime; print((datetime.datetime.now()-datetime.timedelta(minutes=10)).isoformat())" 2>/dev/null || echo "")
  [ -z "$cutoff" ] && { emit_skip "HH-2" "date-math-unavail"; return; }
  # L-S80-2: avoid VAR=$(... grep -c ... || echo 0) multi-line capture trap.
  if awk -v cutoff="[$cutoff" '$0 > cutoff' "$HOOK_LOG" 2>/dev/null | grep -q "UserPromptSubmit"; then recent=1; else recent=0; fi
  if [ "$recent" -lt 1 ]; then
    emit_fail "HH-2-USERPROMPT-NOT-FIRING" "HIGH" "recent_10min=0"
  fi
}

# === HH-3: Promote-rule cycle delta < 10 days ===
HH3_check() {
  local prom_dir="$PROJECT_DIR/agent-workspace/memory/observations"
  [ ! -d "$prom_dir" ] && { emit_skip "HH-3" "obs-dir-missing"; return; }
  local latest age_days
  latest=$(find "$prom_dir" -maxdepth 1 -name 'promote-rule-S*.md' -type f 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
  [ -z "$latest" ] && { emit_fail "HH-3-PROMOTE-RULE-MISSING" "MEDIUM" "no-promote-rule-observation-found"; return; }
  local mtime
  mtime=$(stat -c %Y "$latest" 2>/dev/null || stat -f %m "$latest" 2>/dev/null || echo 0)
  age_days=$(( ( $(date +%s) - mtime ) / 86400 ))
  if [ "$age_days" -gt 14 ]; then
    emit_fail "HH-3-PROMOTE-RULE-STALE" "HIGH" "age_days=$age_days"
  elif [ "$age_days" -gt 10 ]; then
    emit_fail "HH-3-PROMOTE-RULE-STALE" "MEDIUM" "age_days=$age_days"
  fi
}

# === HH-4: Auto-detect orphans ≤ 2 ===
HH4_check() {
  local notes="$PROJECT_DIR/agent-workspace/memory/agent-notes.md"
  [ ! -f "$notes" ] && { emit_skip "HH-4" "agent-notes-missing"; return; }
  local candidates hooks orphan_delta
  # L-S80-2: preserve actual count (used in orphan_delta arithmetic) — remove || echo 0
  # to avoid "0\n0" multi-line capture; the existing [[ ]] || candidates=0 guard handles empty.
  candidates=$(grep -c "Auto-detect:.*yes" "$notes" 2>/dev/null || true)
  hooks=$(find "$PROJECT_DIR/scripts/hooks" -maxdepth 1 -name '*.sh' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
  [[ "$candidates" =~ ^[0-9]+$ ]] || candidates=0
  [[ "$hooks" =~ ^[0-9]+$ ]] || hooks=0
  orphan_delta=$(( candidates > hooks ? candidates - hooks : 0 ))
  if [ "$orphan_delta" -gt 2 ]; then
    emit_fail "HH-4-AUTO-DETECT-ORPHAN" "MEDIUM" "delta=$orphan_delta candidates=$candidates hooks=$hooks"
  fi
}

# === HH-5: Tier 1 bloat (defer to existing hook) ===
HH5_check() {
  local hook="$PROJECT_DIR/scripts/hooks/tier1-bloat-check.sh"
  [ ! -f "$hook" ] && { emit_skip "HH-5" "tier1-bloat-check-missing"; return; }
  if ! bash "$hook" >/dev/null 2>&1; then
    emit_fail "HH-5-TIER1-BLOAT" "HIGH" "tier1-bloat-check-rc-nonzero"
  fi
}

# === HH-6: dispatch-pending JSONL no stale `state=pending` > 2hr ===
HH6_check() {
  local jsonl_dir="$PROJECT_DIR/agent-workspace/memory"
  local two_hr_ago
  two_hr_ago=$(( $(date +%s) - 7200 ))
  local stale=0
  for f in "$jsonl_dir"/.dispatch-pending-*.jsonl; do
    [ -f "$f" ] || continue
    local mtime
    mtime=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
    [ "$mtime" -gt "$two_hr_ago" ] && continue
    if tail -1 "$f" 2>/dev/null | grep -q '"state":"pending"'; then
      stale=$((stale + 1))
    fi
  done
  if [ "$stale" -ge 3 ]; then
    emit_fail "HH-6-DISPATCH-STALE" "HIGH" "stale=$stale"
  elif [ "$stale" -ge 1 ]; then
    emit_fail "HH-6-DISPATCH-STALE" "MEDIUM" "stale=$stale"
  fi
}

# === HH-7: Checkpoint freshness ===
HH7_check() {
  local latest="$PROJECT_DIR/agent-workspace/memory/checkpoints/latest.md"
  [ ! -f "$latest" ] && { emit_fail "HH-7-CHECKPOINT-MISSING" "MEDIUM" "latest.md-not-found"; return; }
  local now mtime age_hr
  now=$(date +%s)
  mtime=$(stat -c %Y "$latest" 2>/dev/null || stat -f %m "$latest" 2>/dev/null || echo 0)
  age_hr=$(( (now - mtime) / 3600 ))
  local sess_dir="$PROJECT_DIR/agent-workspace/memory/sessions"
  local latest_sess sess_mtime sess_delta_hr
  latest_sess=$(find "$sess_dir" -maxdepth 1 -name '*.md' -type f 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
  if [ -n "$latest_sess" ]; then
    sess_mtime=$(stat -c %Y "$latest_sess" 2>/dev/null || stat -f %m "$latest_sess" 2>/dev/null || echo 0)
    sess_delta_hr=$(( (now - sess_mtime) / 3600 ))
  else
    sess_delta_hr=0
  fi
  # PASS: checkpoint within 24hr OR within session-mtime + 2hr window
  if [ "$age_hr" -gt 24 ] && [ "$age_hr" -gt "$(( sess_delta_hr + 2 ))" ]; then
    emit_fail "HH-7-CHECKPOINT-STALE" "MEDIUM" "age_hr=$age_hr sess_delta_hr=$sess_delta_hr"
  fi
}

# === HH-8: Charter md5 unchanged in non-ratify session ===
HH8_check() {
  local charter="$PROJECT_DIR/PROJECT_CHARTER.md"
  local baseline_file="$PROJECT_DIR/agent-workspace/memory/.charter-md5-baseline"
  [ ! -f "$charter" ] && { emit_fail "HH-8-CHARTER-MISSING" "HIGH" "charter-not-found"; return; }
  if [ ! -f "$baseline_file" ]; then
    # First-run: write baseline + skip
    md5sum "$charter" 2>/dev/null | awk '{print $1}' > "$baseline_file" 2>/dev/null || \
      md5 "$charter" 2>/dev/null | awk '{print $NF}' > "$baseline_file" 2>/dev/null || true
    emit_skip "HH-8" "baseline-initialized"
    return
  fi
  local current_md5 baseline_md5 ratify_marker
  current_md5=$(md5sum "$charter" 2>/dev/null | awk '{print $1}' || md5 "$charter" 2>/dev/null | awk '{print $NF}' || echo "")
  baseline_md5=$(cat "$baseline_file" 2>/dev/null | tr -d '[:space:]')
  ratify_marker="$PROJECT_DIR/agent-workspace/memory/.charter-ratify-active-${SID}"
  if [ "$current_md5" != "$baseline_md5" ] && [ ! -f "$ratify_marker" ]; then
    emit_fail "HH-8-CHARTER-DRIFT" "HIGH" "md5-changed-without-ratify-marker"
  fi
}

# === HH-9: mistake-log freshness OR explicit "no mistakes" ===
HH9_check() {
  local sess_dir="$PROJECT_DIR/agent-workspace/memory/sessions"
  local mistake="$PROJECT_DIR/agent-workspace/memory/mistake-log.md"
  local latest_sess sess_mtime mistake_mtime delta
  latest_sess=$(find "$sess_dir" -maxdepth 1 -name '*.md' -type f 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
  [ -z "$latest_sess" ] && { emit_skip "HH-9" "no-session-log"; return; }
  sess_mtime=$(stat -c %Y "$latest_sess" 2>/dev/null || stat -f %m "$latest_sess" 2>/dev/null || echo 0)
  mistake_mtime=$(stat -c %Y "$mistake" 2>/dev/null || stat -f %m "$mistake" 2>/dev/null || echo 0)
  delta=$(( sess_mtime > mistake_mtime ? sess_mtime - mistake_mtime : mistake_mtime - sess_mtime ))
  if [ "$delta" -le 300 ]; then return; fi
  if grep -qiE "no mistakes (this )?(session|turn)|mistakes new.*none" "$latest_sess" 2>/dev/null; then return; fi
  emit_fail "HH-9-MISTAKE-LOG-UNFRESH" "MEDIUM" "delta_sec=$delta no-explicit-declaration"
}

# === HH-10: Firing-test orphans ≤ 2 ===
HH10_check() {
  local hooks_dir="$PROJECT_DIR/scripts/hooks"
  local tests_dir="$hooks_dir/firing-tests"
  [ ! -d "$tests_dir" ] && { emit_fail "HH-10-FIRING-TESTS-DIR-MISSING" "MEDIUM" "no-firing-tests-dir"; return; }
  local orphans=0 hook name test
  for hook in "$hooks_dir"/*.sh; do
    [ -f "$hook" ] || continue
    name=$(basename "$hook" .sh)
    test="$tests_dir/${name}-fire-test.sh"
    [ ! -f "$test" ] && orphans=$((orphans + 1))
  done
  if [ "$orphans" -gt 2 ]; then
    emit_fail "HH-10-FIRING-TEST-ORPHAN" "MEDIUM" "orphans=$orphans"
  fi
}

# === HH-11: .session-hooks.log mtime < 60 min ===
HH11_check() {
  [ ! -f "$HOOK_LOG" ] && { emit_fail "HH-11-LOG-MISSING" "HIGH" "session-hooks-log-not-found"; return; }
  local now mtime age_min
  now=$(date +%s)
  mtime=$(stat -c %Y "$HOOK_LOG" 2>/dev/null || stat -f %m "$HOOK_LOG" 2>/dev/null || echo 0)
  age_min=$(( (now - mtime) / 60 ))
  if [ "$age_min" -gt 60 ]; then
    emit_fail "HH-11-LOG-FROZEN" "HIGH" "age_min=$age_min"
  fi
}

# === HH-12: current-execution.md Phase = project.md Phase ===
HH12_check() {
  local ce="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
  local proj="$PROJECT_DIR/agent-workspace/memory/project.md"
  if [ ! -f "$ce" ] || [ ! -f "$proj" ]; then
    emit_skip "HH-12" "missing-files"
    return
  fi
  local ce_phase proj_phase
  # S319b L-S48d-1: || true guards prevent ERR-trap on grep no-match.
  ce_phase=$(grep -m1 -E '^## S[0-9]+ — Phase' "$ce" 2>/dev/null | grep -oE 'Phase [0-9.]+' | head -1 || true)
  proj_phase=$(grep -E '^\| [0-9.]+ —' "$proj" 2>/dev/null | grep -i 'IN PROGRESS' | head -1 | grep -oE 'Phase [0-9.]+' | head -1 || true)
  if [ -z "$ce_phase" ] || [ -z "$proj_phase" ]; then
    emit_skip "HH-12" "phase-parse-failed"
    return
  fi
  if [ "$ce_phase" != "$proj_phase" ]; then
    emit_fail "HH-12-PHASE-DRIFT" "HIGH" "ce=$ce_phase proj=$proj_phase"
  fi
}

# === Run all signals (cheap-first ordering) ===
HH7_check   # checkpoint mtime — very cheap
HH11_check  # log mtime — very cheap
HH8_check   # md5 — cheap
HH1_check   # grep log — cheap-medium
HH2_check   # awk + grep — medium
HH9_check   # mtime + grep session log — medium
HH3_check   # find + xargs ls — medium
HH6_check   # multi-file mtime + tail — medium
HH4_check   # grep agent-notes — medium
HH10_check  # find loop — medium
HH5_check   # delegate to existing hook — medium-heavy
HH12_check  # multi-file grep — heavy

# === Aggregation + emission ===
TOTAL=$(( HIGH + MEDIUM + LOW ))
STATE="GREEN"
if [ "$HIGH" -ge 2 ] || { [ "$HIGH" -ge 1 ] && [ "$MEDIUM" -ge 2 ]; }; then
  STATE="RED-2"
elif [ "$HIGH" -ge 1 ]; then
  STATE="RED-1"
elif [ "$MEDIUM" -ge 1 ]; then
  STATE="YELLOW"
fi

# Cache the result
{
  printf 'session=%s ts=%s state=%s high=%d medium=%d low=%d skip=%d details=%s\n' \
    "$SID" "$TS" "$STATE" "$HIGH" "$MEDIUM" "$LOW" "$SKIP" "$FAIL_DETAILS"
} > "$CACHE"

# Emit summary to hook log
echo "[$TS] harness-health-self-scan: state=$STATE high=$HIGH medium=$MEDIUM low=$LOW skip=$SKIP session=$SID" >> "$HOOK_LOG"

# Emit system-reminder ONLY if non-GREEN AND running under UserPromptSubmit (CLAUDE_HOOK_EVENT env or similar)
# We detect UserPromptSubmit by checking if stdin is a JSON payload (UserPromptSubmit feeds JSON).
EVENT="${1:-${CLAUDE_HOOK_EVENT:-unknown}}"
if [ "$STATE" != "GREEN" ] && [ "$EVENT" = "UserPromptSubmit" ]; then
  REMINDER="HARNESS-HEALTH-SELF-SCAN: state=$STATE (high=$HIGH medium=$MEDIUM)
Failures: $FAIL_DETAILS
Action: review FAILs in agent-workspace/memory/.harness-health.log; remediate per harness-health-protocol.md § Pass/Fail Aggregation Rules. Exit code 0 (informational)."
  node -e "
process.stdout.write(JSON.stringify({
  hookSpecificOutput: {
    hookEventName: 'UserPromptSubmit',
    additionalContext: process.argv[1]
  }
}));
" "$REMINDER" 2>/dev/null || true
fi

# SessionStart: emit to stderr (visible in session-hooks.log per existing convention)
if [ "$STATE" != "GREEN" ] && [ "$EVENT" = "SessionStart" ]; then
  echo "[harness-health] state=$STATE high=$HIGH medium=$MEDIUM details=$FAIL_DETAILS" >&2
fi

exit 0
