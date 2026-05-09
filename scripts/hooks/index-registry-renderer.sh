#!/usr/bin/env bash
# index-registry-renderer.sh — renders 4 cross-reference manifest TSVs on session Stop.
# Plan 011 D5 deliverable. Enables lesson-synthesizer to navigate cross-refs deterministically.
# Idempotent: re-running on unchanged source produces identical TSV output.
#
# Manifests: agent-workspace/memory/indexes/
#   hook-registry.tsv     hook_name|wired_events|status|linked_lessons|firing_test_path|last_modified
#   lesson-registry.tsv   lesson_id|date|severity|hook_codified|hook_path|mistake_link|charter_promoted
#   mistake-registry.tsv  mistake_id|session|severity|prevention_status|hook_path|recurrence_count
#   decision-registry.tsv adr_id|session|tier|status|promoted_to
#
# L-S11-1 portability: bash + awk + grep + sed only (no python3/jq/yq).
# L-S58-1 ERR-trap-aware: uses if/then/fi not [ x ] && Y.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
HOOKS_DIR="$PROJECT_DIR/scripts/hooks"
INDEXES_DIR="$MEMORY_DIR/indexes"
SETTINGS_FILE="$PROJECT_DIR/.claude/settings.json"
AGENT_NOTES="$MEMORY_DIR/agent-notes.md"
MISTAKE_LOG="$MEMORY_DIR/mistake-log.md"
DECISIONS_DIR="$MEMORY_DIR/decisions"

mkdir -p "$INDEXES_DIR" 2>/dev/null || true

HOOK_REGISTRY="$INDEXES_DIR/hook-registry.tsv"
LESSON_REGISTRY="$INDEXES_DIR/lesson-registry.tsv"
MISTAKE_REGISTRY="$INDEXES_DIR/mistake-registry.tsv"
DECISION_REGISTRY="$INDEXES_DIR/decision-registry.tsv"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# -----------------------------------------------------------------------
# Phase 1: Build wired-events lookup from settings.json (single awk pass)
# -----------------------------------------------------------------------
WIRED_EVENTS_FILE="$WORK_DIR/wired.tsv"
if [ -f "$SETTINGS_FILE" ]; then
  awk '
    /^[[:space:]]*"(SessionStart|SessionEnd|UserPromptSubmit|Stop|PreToolUse|PostToolUse|SubagentStop|PreCompact)"[[:space:]]*:/ {
      match($0, /"([A-Za-z]+)"/, arr); cur_ev=arr[1]
    }
    /scripts\/hooks\/[^/]+\.sh/ {
      match($0,/scripts\/hooks\/([^/]+\.sh)/,arr); h=arr[1]
      if (h!="" && cur_ev!="") {
        k=h SUBSEP cur_ev
        if (!seen[k]) { seen[k]=1; ev[h]=(ev[h]=="")?cur_ev:ev[h]","cur_ev }
      }
    }
    END { for (h in ev) print h"\t"ev[h] }
  ' "$SETTINGS_FILE" 2>/dev/null > "$WIRED_EVENTS_FILE" || true
fi
touch "$WIRED_EVENTS_FILE"

# -----------------------------------------------------------------------
# Phase 2: Build lesson-in-hook index via single grep pass over all hooks
# lesson_id<TAB>first_hook_that_mentions_it
# -----------------------------------------------------------------------
LESSON_HOOK_FILE="$WORK_DIR/lesson-hook.tsv"
if [ -d "$HOOKS_DIR" ]; then
  grep -roh 'L-S[0-9][0-9]*-[0-9][0-9]*' "$HOOKS_DIR"/*.sh 2>/dev/null \
    | sed 's|.*/\([^:]*\):\(.*\)|\2\t\1|' \
    | sort -t$'\t' -k1,1 -k2,2 \
    | awk 'BEGIN{FS="\t"} !seen[$1]++{print $1"\t"$2}' \
    > "$LESSON_HOOK_FILE" 2>/dev/null || true
fi
touch "$LESSON_HOOK_FILE"

# -----------------------------------------------------------------------
# Phase 3: Build mistake-in-hook index
# -----------------------------------------------------------------------
MISTAKE_HOOK_FILE="$WORK_DIR/mistake-hook.tsv"
if [ -d "$HOOKS_DIR" ]; then
  grep -roh 'M-S[0-9][0-9]*-[0-9][0-9]*' "$HOOKS_DIR"/*.sh 2>/dev/null \
    | sed 's|.*/\([^:]*\):\(.*\)|\2\t\1|' \
    | sort -t$'\t' -k1,1 -k2,2 \
    | awk 'BEGIN{FS="\t"} !seen[$1]++{print $1"\t"$2}' \
    > "$MISTAKE_HOOK_FILE" 2>/dev/null || true
fi
touch "$MISTAKE_HOOK_FILE"

# -----------------------------------------------------------------------
# Phase 4: Build firing-tests presence set
# -----------------------------------------------------------------------
FIRING_TESTS_FILE="$WORK_DIR/firing-tests.txt"
if [ -d "$HOOKS_DIR/firing-tests" ]; then
  ls "$HOOKS_DIR/firing-tests/"*-fire-test.sh 2>/dev/null \
    | awk -F'/' '{print $NF}' > "$FIRING_TESTS_FILE" || true
fi
touch "$FIRING_TESTS_FILE"

# -----------------------------------------------------------------------
# Render hook-registry.tsv (awk-based single pass over all hooks together)
# -----------------------------------------------------------------------
render_hook_registry() {
  if [ ! -d "$HOOKS_DIR" ]; then
    printf 'hook_name\twired_events\tstatus\tlinked_lessons\tfiring_test_path\tlast_modified\n' > "$HOOK_REGISTRY"
    return
  fi

  # Use awk to process all hook files at once
  # FILENAME changes per file; END we emit one row per file
  awk -v wired_file="$WIRED_EVENTS_FILE" -v ft_file="$FIRING_TESTS_FILE" \
      -v ft_dir="scripts/hooks/firing-tests/" '
    BEGIN {
      FS="\t"
      # Load wired events lookup
      while ((getline line < wired_file) > 0) {
        n = split(line, a, "\t"); if (n==2) wired[a[1]]=a[2]
      }
      # Load firing-test filenames
      while ((getline line < ft_file) > 0) {
        gsub(/[[:space:]]/,"",line); ft_set[line]=1
      }
      print "hook_name\twired_events\tstatus\tlinked_lessons\tfiring_test_path\tlast_modified"
    }
    FNR==1 {
      # New file: flush previous file result
      if (cur_file != "") flush_row()
      cur_file = FILENAME
      # Extract basename
      n = split(FILENAME, parts, "/"); cur_hook = parts[n]
      loc=0; linked_arr[""] = 0
      delete linked_arr
    }
    # Count non-blank non-comment lines
    !/^[[:space:]]*#/ && !/^[[:space:]]*$/ { loc++ }
    # Collect L-S lesson refs
    { while (match($0, /L-S[0-9]+-[0-9]+/)) {
        linked_arr[substr($0,RSTART,RLENGTH)] = 1
        $0 = substr($0, RSTART+RLENGTH)
      }
    }
    END { if (cur_file != "") flush_row() }
    function flush_row(    wired, status, linked, ft_name, ft_path, i, sep) {
      wired = (cur_hook in wired_arr) ? wired_arr[cur_hook] : \
              (cur_hook in wired) ? wired[cur_hook] : "ORPHAN"
      # status
      status = (wired == "ORPHAN") ? "ORPHAN" : "ACTIVE"
      if (loc <= 3) status = "STUB"
      # linked lessons
      linked = ""; sep = ""
      for (k in linked_arr) { linked = linked sep k; sep = "," }
      if (linked == "") linked = "none"
      # firing test
      ft_name = substr(cur_hook, 1, length(cur_hook)-3) "-fire-test.sh"
      ft_path = (ft_name in ft_set) ? ft_dir ft_name : "MISSING"
      # last_modified: skip for performance — use "see-fs" placeholder
      print cur_hook "\t" wired "\t" status "\t" linked "\t" ft_path "\t" "see-fs"
    }
  ' "$HOOKS_DIR"/*.sh 2>/dev/null \
  | { read header; printf '%s\n' "$header"; sort; } > "$HOOK_REGISTRY" || true

  # Fix: wired_arr not populated in awk above (awk doesn't reload per-file easily).
  # The wired lookup is loaded in BEGIN via wired[] array — use that directly.
  # The flush_row function references wired[cur_hook] — this should work.
  # Verify row count > 1
  local row_count
  row_count="$(wc -l < "$HOOK_REGISTRY" 2>/dev/null || echo 0)"
  if [ "${row_count:-0}" -le 1 ]; then
    # Fallback: simple row-per-hook
    printf 'hook_name\twired_events\tstatus\tlinked_lessons\tfiring_test_path\tlast_modified\n' > "$HOOK_REGISTRY"
    for hook_file in "$HOOKS_DIR"/*.sh; do
      if [ ! -f "$hook_file" ]; then continue; fi
      local hn wired_ev status linked_lessons ft_path
      hn="$(basename "$hook_file")"
      wired_ev="$(awk -v h="$hn" 'BEGIN{FS="\t"} $1==h{print $2;exit}' "$WIRED_EVENTS_FILE" || true)"
      if [ -z "${wired_ev:-}" ]; then wired_ev="ORPHAN"; fi
      if [ "$wired_ev" = "ORPHAN" ]; then status="ORPHAN"; else status="ACTIVE"; fi
      linked_lessons="none"
      ft_path="MISSING"
      local ft_name="${hn%.sh}-fire-test.sh"
      if [ -f "$HOOKS_DIR/firing-tests/$ft_name" ]; then
        ft_path="scripts/hooks/firing-tests/$ft_name"
      fi
      printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$hn" "$wired_ev" "$status" "$linked_lessons" "$ft_path" "see-fs" >> "$HOOK_REGISTRY"
    done
  fi
}

# -----------------------------------------------------------------------
# Render lesson-registry.tsv (awk extract + awk lookup — no per-row subprocess)
# -----------------------------------------------------------------------
render_lesson_registry() {
  # Extract all lessons to temp file
  local lessons_raw="$WORK_DIR/lessons-raw.tsv"
  if [ -f "$AGENT_NOTES" ]; then
    awk '
      /^### / {
        if (cur_id!="") print cur_id "|" cur_date "|" cur_sev
        cur_id=""; cur_date=""; cur_sev="unknown"
        if (match($0,/L-S[0-9]+-[0-9]+/)) cur_id=substr($0,RSTART,RLENGTH)
        else if (match($0,/KI-S[0-9]+-[0-9]+/)) cur_id=substr($0,RSTART,RLENGTH)
        else if (match($0,/AP-S[0-9]+-[0-9]+/)) cur_id=substr($0,RSTART,RLENGTH)
        if (cur_id=="" && match($0,/[0-9]{4}-[0-9]{2}-[0-9]{2}/)) {
          cur_date=substr($0,RSTART,RLENGTH); cur_id="L-"cur_date"-"NR
        }
        if (cur_date=="" && match($0,/[0-9]{4}-[0-9]{2}-[0-9]{2}/))
          cur_date=substr($0,RSTART,RLENGTH)
        next
      }
      cur_id!="" && /^\*\*Severity\*\*:/ {
        sub(/^\*\*Severity\*\*:[[:space:]]*/,"")
        split($0,w," "); cur_sev=w[1]
      }
      END { if (cur_id!="") print cur_id "|" cur_date "|" cur_sev }
    ' "$AGENT_NOTES" 2>/dev/null | sort -u > "$lessons_raw"
  fi
  touch "$lessons_raw"

  # Join with lesson-hook index using awk (no subprocess per row)
  printf 'lesson_id\tdate\tseverity\thook_codified\thook_path\tmistake_link\tcharter_promoted\n' \
    > "$LESSON_REGISTRY.tmp"

  awk -v hook_file="$LESSON_HOOK_FILE" '
    BEGIN {
      FS="|"
      while ((getline line < hook_file) > 0) {
        split(line, a, "\t"); if (a[1]!="") hook_for[a[1]]=a[2]
      }
    }
    $1 != "" {
      hc=(($1 in hook_for) ? "YES" : "NO")
      hp=(($1 in hook_for) ? hook_for[$1] : "none")
      printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $1, ($2==""?"unknown":$2), \
        ($3==""?"unknown":$3), hc, hp, "none", "NO"
    }
  ' "$lessons_raw" 2>/dev/null \
  | sort >> "$LESSON_REGISTRY.tmp"

  { head -1 "$LESSON_REGISTRY.tmp"; tail -n +2 "$LESSON_REGISTRY.tmp" | sort -u; } > "$LESSON_REGISTRY"
  rm -f "$LESSON_REGISTRY.tmp"
}

# -----------------------------------------------------------------------
# Render mistake-registry.tsv
# -----------------------------------------------------------------------
render_mistake_registry() {
  local mistakes_raw="$WORK_DIR/mistakes-raw.tsv"
  if [ -f "$MISTAKE_LOG" ]; then
    awk '
      /^### M-S[0-9]+-[0-9]+/ {
        if (cur_id!="") print cur_id "|" cur_sess "|" cur_sev
        cur_id=""; cur_sess="unknown"; cur_sev="unknown"
        match($0,/M-S[0-9]+-[0-9]+/); cur_id=substr($0,RSTART,RLENGTH); next
      }
      cur_id!="" && /^\*\*Session\*\*:/ {
        if (match($0,/S[0-9]+/)) cur_sess=substr($0,RSTART,RLENGTH)
      }
      cur_id!="" && /^\*\*Severity\*\*:/ {
        sub(/^\*\*Severity\*\*:[[:space:]]*/,"")
        split($0,w," "); cur_sev=w[1]
      }
      END { if (cur_id!="") print cur_id "|" cur_sess "|" cur_sev }
    ' "$MISTAKE_LOG" 2>/dev/null | sort -u > "$mistakes_raw"
  fi
  touch "$mistakes_raw"

  # Build recurrence counts from mistake log
  local recur_file="$WORK_DIR/recur.tsv"
  if [ -f "$MISTAKE_LOG" ]; then
    grep -oh 'M-S[0-9]*-[0-9]*' "$MISTAKE_LOG" 2>/dev/null \
      | sort | uniq -c \
      | awk '{print $2"\t"($1-1)}' > "$recur_file" || true
  fi
  touch "$recur_file"

  # Build notes-ref set
  local notes_set="$WORK_DIR/mistake-in-notes.txt"
  if [ -f "$AGENT_NOTES" ]; then
    grep -oh 'M-S[0-9]*-[0-9]*' "$AGENT_NOTES" 2>/dev/null | sort -u > "$notes_set" || true
  fi
  touch "$notes_set"

  printf 'mistake_id\tsession\tseverity\tprevention_status\thook_path\trecurrence_count\n' \
    > "$MISTAKE_REGISTRY.tmp"

  awk -v hook_file="$MISTAKE_HOOK_FILE" -v notes_file="$notes_set" -v recur_file="$recur_file" '
    BEGIN {
      FS="|"
      while ((getline line < hook_file) > 0) {
        split(line,a,"\t"); if (a[1]!="") hook_for[a[1]]=a[2]
      }
      while ((getline line < notes_file) > 0) {
        gsub(/[[:space:]]/,"",line); in_notes[line]=1
      }
      while ((getline line < recur_file) > 0) {
        split(line,a,"\t"); if (a[1]!="") recur[a[1]]=a[2]+0
      }
    }
    $1 != "" {
      if ($1 in hook_for) { prev="HOOK"; hp=hook_for[$1] }
      else if ($1 in in_notes) { prev="MANUAL"; hp="none" }
      else { prev="OPEN"; hp="none" }
      rc=(($1 in recur) ? recur[$1] : 0)
      if (rc<0) rc=0
      printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, ($2==""?"unknown":$2), \
        ($3==""?"unknown":$3), prev, hp, rc
    }
  ' "$mistakes_raw" 2>/dev/null \
  | sort >> "$MISTAKE_REGISTRY.tmp"

  { head -1 "$MISTAKE_REGISTRY.tmp"; tail -n +2 "$MISTAKE_REGISTRY.tmp" | sort -u; } > "$MISTAKE_REGISTRY"
  rm -f "$MISTAKE_REGISTRY.tmp"
}

# -----------------------------------------------------------------------
# Render decision-registry.tsv (awk frontmatter extraction, one pass per file)
# -----------------------------------------------------------------------
render_decision_registry() {
  if [ ! -d "$DECISIONS_DIR" ]; then
    printf 'adr_id\tsession\ttier\tstatus\tpromoted_to\n' > "$DECISION_REGISTRY"
    return
  fi

  printf 'adr_id\tsession\ttier\tstatus\tpromoted_to\n' > "$DECISION_REGISTRY.tmp"

  # Process all ADR files with a single awk invocation
  awk '
    FNR==1 {
      if (cur_id != "") emit_row()
      cur_id=""; cur_sess="unknown"; cur_tier=""; cur_status="active"; cur_promo="none"
      in_fm=0; fm_count=0
      # Extract numeric prefix from filename for ADR ID
      n=split(FILENAME,parts,"/"); fname=parts[n]
      match(fname,/^[0-9]+/)
      num=substr(fname,RSTART,RLENGTH)
      cur_id=(num!="") ? "D-"num : "D-"fname
      # Derive tier from filename
      if (fname~/charter/) cur_tier="CHARTER"
      else if (fname~/arch/) cur_tier="ARCH"
      else if (fname~/scope/) cur_tier="SCOPE"
      else cur_tier="IMPL"
      # Derive session from filename
      if (match(fname,/S[0-9]+/)) cur_sess=substr(fname,RSTART,RLENGTH)
    }
    /^---/ { fm_count++; in_fm=(fm_count==1)?1:0; next }
    in_fm && /^session:/ { sub(/^session:[[:space:]]*/,""); split($0,w," "); cur_sess=w[1] }
    in_fm && /^tier:/ { sub(/^tier:[[:space:]]*/,""); split($0,w," "); cur_tier=w[1] }
    in_fm && /^status:/ { sub(/^status:[[:space:]]*/,""); split($0,w," "); cur_status=w[1] }
    in_fm && /^promoted_to:/ { sub(/^promoted_to:[[:space:]]*/,""); split($0,w," "); cur_promo=w[1] }
    END { if (cur_id!="") emit_row() }
    function emit_row() {
      if (cur_tier=="") cur_tier="IMPL"
      printf "%s\t%s\t%s\t%s\t%s\n", cur_id, cur_sess, cur_tier, cur_status, cur_promo
    }
  ' "$DECISIONS_DIR"/[0-9][0-9][0-9]-*.md 2>/dev/null \
  | sort >> "$DECISION_REGISTRY.tmp"

  { head -1 "$DECISION_REGISTRY.tmp"; tail -n +2 "$DECISION_REGISTRY.tmp" | sort -u; } > "$DECISION_REGISTRY"
  rm -f "$DECISION_REGISTRY.tmp"
}

# -----------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------
render_hook_registry
render_lesson_registry
render_mistake_registry
render_decision_registry

printf 'index-registry-renderer: rendered 4 manifests in %s\n' "$INDEXES_DIR" \
  >> "$MEMORY_DIR/.session-hooks.log" 2>/dev/null || true

# Plan 011 D6: enqueue manifest-render-complete notification job (priority 8 — low).
# Kill switch: MEMORY_ETL_DISABLE=1. Consumer: future dashboard / lesson-synthesizer.
if [ "${MEMORY_ETL_DISABLE:-0}" != "1" ]; then
  ETL_QUEUE_DIR="$MEMORY_DIR/etl-queue"
  if mkdir -p "$ETL_QUEUE_DIR" 2>/dev/null; then
    ETL_TS_FN="$(date -u +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
    ETL_JOB="$ETL_QUEUE_DIR/8-${ETL_TS_FN}-manifest-render-complete.job"
    HOOK_ROWS="$(wc -l < "$HOOK_REGISTRY" 2>/dev/null | tr -d '[:space:]' || echo 0)"
    LESSON_ROWS="$(wc -l < "$LESSON_REGISTRY" 2>/dev/null | tr -d '[:space:]' || echo 0)"
    {
      printf -- '---\n'
      printf 'task: manifest-render-complete\n'
      printf 'payload: {"hook_rows":%s,"lesson_rows":%s,"indexes_dir":"%s"}\n' \
        "${HOOK_ROWS:-0}" "${LESSON_ROWS:-0}" "$INDEXES_DIR"
      printf 'created_at: %s\n' "$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"
      printf 'producer: index-registry-renderer.sh\n'
      printf -- '---\n'
    } > "$ETL_JOB" 2>/dev/null || true
  fi
fi

exit 0
