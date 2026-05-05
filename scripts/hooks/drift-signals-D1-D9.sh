#!/usr/bin/env bash
# drift-signals-D1-D9.sh — composite drift detector running 9 grep-based signals.
# D1 = LOC ceiling overrun (PRIMARY per Q-A2 answer 2026-04-29: highest empirical firing
# rate at S2). D2-D8 = secondary checks. D9 = runtime-path-leak into write-only
# learning-data/(events|archive)/ tree (Track 5.5d.1 D-5 deliverable per D-005).
# Append violations to .drift-signals.log.
# Decision 002 § Track 5 REV-2 § B + Decision 005 § 5.5d.1.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
LOG="$PROJECT_DIR/agent-workspace/memory/.drift-signals.log"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds)"

VIOLATIONS=0

emit() {
  local signal="$1" severity="$2" detail="$3"
  printf '[%s] %s severity=%s %s\n' "$TS" "$signal" "$severity" "$detail" >> "$LOG"
  VIOLATIONS=$(( VIOLATIONS + 1 ))
}

# === D1: LOC ceiling overrun (PRIMARY) — agents 200, skills 150, commands 120 ===
check_loc() {
  local file="$1" ceiling="$2" archetype="$3"
  [ ! -f "$file" ] && return
  local lines
  lines="$(wc -l < "$file" 2>/dev/null | tr -d '[:space:]')"
  [[ "$lines" =~ ^[0-9]+$ ]] || return
  local overrun_pct=$(( (lines - ceiling) * 100 / ceiling ))
  if [ "$lines" -gt "$ceiling" ]; then
    if [ "$overrun_pct" -ge 20 ]; then
      emit "D1-LOC-CEILING" "HIGH" "file=$file archetype=$archetype lines=$lines ceiling=$ceiling overrun_pct=$overrun_pct"
    else
      emit "D1-LOC-CEILING" "MEDIUM" "file=$file archetype=$archetype lines=$lines ceiling=$ceiling overrun_pct=$overrun_pct"
    fi
  fi
}

for f in "$PROJECT_DIR"/.claude/agents/*.md; do
  check_loc "$f" 200 "agent"
done
for f in "$PROJECT_DIR"/.claude/skills/*/SKILL.md; do
  check_loc "$f" 150 "skill"
done
for f in "$PROJECT_DIR"/.claude/commands/*.md; do
  check_loc "$f" 120 "command"
done

# === D2: Self-attestation contradicting actual (text claims X LOC but file is Y) ===
# Heuristic grep: session logs claiming "within target" or "<150 LOC" without wc -l command nearby.
SESSION_LOGS="$(find "$PROJECT_DIR/agent-workspace/memory/sessions" -name '*.md' -mmin -1440 2>/dev/null || true)"
for s in $SESSION_LOGS; do
  [ ! -f "$s" ] && continue
  if grep -qE '(LOC|line count|bodies are.*LOC|within target)' "$s" 2>/dev/null; then
    if ! grep -qE 'wc -l' "$s" 2>/dev/null; then
      emit "D2-SELF-ATTEST" "MEDIUM" "file=$s claim=LOC-within-target without-wc-l-verification"
    fi
  fi
done

# === D3: Charter-tier item bundled with sub-charter-tier (silent absorption risk) ===
QA_BUNDLES="$(find "$PROJECT_DIR/human-workspace/q-and-a/pending" \
                   "$PROJECT_DIR/human-workspace/q-and-a/answered" \
              -name '*.md' -mmin -1440 2>/dev/null || true)"
for b in $QA_BUNDLES; do
  [ ! -f "$b" ] && continue
  CHARTER_HIT=$(grep -cE 'level:\s*CHARTER' "$b" 2>/dev/null || true)
  SCOPE_HIT=$(grep -cE 'level:\s*(SCOPE|DECISION_ROUTING|SUB)' "$b" 2>/dev/null || true)
  [[ "$CHARTER_HIT" =~ ^[0-9]+$ ]] || CHARTER_HIT=0
  [[ "$SCOPE_HIT"   =~ ^[0-9]+$ ]] || SCOPE_HIT=0
  if [ "$CHARTER_HIT" -ge 1 ] && [ "$SCOPE_HIT" -ge 1 ]; then
    emit "D3-CHARTER-MIXED-BUNDLE" "HIGH" "file=$b charter_count=$CHARTER_HIT scope_count=$SCOPE_HIT"
  fi
done

# === D4: Spec-as-source butterfly (spec ↔ code mismatch) — handled by same-commit-rule.sh ===
# Lightweight check here: spec referenced but no matching code path exists.
SPECS="$(find "$PROJECT_DIR/specs" -name '*.md' -mmin -1440 2>/dev/null || true)"
for s in $SPECS; do
  [ ! -f "$s" ] && continue
  REFS="$(grep -oE 'packages/[a-z_/-]+\.py|apps/[a-z_/-]+\.py' "$s" 2>/dev/null | sort -u | head -5)"
  for ref in $REFS; do
    if [ ! -f "$PROJECT_DIR/$ref" ]; then
      emit "D4-SPEC-DANGLING-REF" "LOW" "spec=$s missing_ref=$ref"
    fi
  done
done

# === D5: Numeric values without source/as_of in agent-output files (I-S2 broad sweep) ===
DATA_FILES="$(find "$PROJECT_DIR/agent-workspace/memory/thesis-log" \
                   "$PROJECT_DIR/agent-workspace/calibration" \
              -name '*.md' -mmin -1440 2>/dev/null || true)"
for f in $DATA_FILES; do
  [ ! -f "$f" ] && continue
  if grep -qE '[0-9]{2,}\.?[0-9]*\s*(%|VND|tỷ|billion)' "$f" 2>/dev/null; then
    if ! grep -qE '(source:|as[_ ]of:)' "$f" 2>/dev/null; then
      emit "D5-MISSING-CITATION" "HIGH" "file=$f"
    fi
  fi
done

# === D6: LLM-math anti-pattern words ===
for f in $DATA_FILES; do
  [ ! -f "$f" ] && continue
  if grep -qiE '(approximately|roughly|around|circa)\s+[0-9]' "$f" 2>/dev/null; then
    emit "D6-LLM-MATH" "HIGH" "file=$f"
  fi
done

# === D7: Bear case missing in thesis ===
for f in "$PROJECT_DIR"/agent-workspace/memory/thesis-log/*.md; do
  [ ! -f "$f" ] && continue
  if ! grep -qiE '(bear[_ ]case|risks?|downside)' "$f" 2>/dev/null; then
    emit "D7-NO-BEAR-CASE" "MEDIUM" "file=$f"
  fi
done

# === D8: Confidence claims without calibration metadata ===
for f in $DATA_FILES; do
  [ ! -f "$f" ] && continue
  if grep -qiE '[0-9]+%\s*confidence|high confidence|medium confidence|low confidence' "$f" 2>/dev/null; then
    if ! grep -qiE '(n_samples|hit_rate|lookback)' "$f" 2>/dev/null; then
      emit "D8-CONFIDENCE-NO-CALIB" "HIGH" "file=$f"
    fi
  fi
done

# === D9: Runtime-path-leak into write-only learning-data/(events|archive)/ tree ===
# Track 5.5d.1 boundary discipline (D-005). Whitelist: hooks that legitimately write/admin events.
LEARNING_WRITE_HOOKS="component-telemetry|learning-queue-sweeper|learning-index-rebuild|drift-signals-D1-D9"
for f in "$PROJECT_DIR"/.claude/skills/*/SKILL.md \
         "$PROJECT_DIR"/.claude/agents/*.md \
         "$PROJECT_DIR"/.claude/commands/*.md; do
  [ ! -f "$f" ] && continue
  if grep -qE 'learning-data/(events|archive)' "$f" 2>/dev/null; then
    emit "D9-LEARNING-PATH-LEAK" "HIGH" "file=$f category=read-path refs-write-only-tree"
  fi
done
for f in "$PROJECT_DIR"/scripts/hooks/*.sh; do
  [ ! -f "$f" ] && continue
  bn="$(basename "$f" .sh)"
  if printf '%s' "$bn" | grep -qE "^($LEARNING_WRITE_HOOKS)$"; then continue; fi
  if grep -qE 'learning-data/(events|archive)' "$f" 2>/dev/null; then
    emit "D9-LEARNING-PATH-LEAK" "HIGH" "file=$f category=non-whitelist-hook refs-write-only-tree"
  fi
done

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "[$TS] drift-signals-D1-D9: $VIOLATIONS violation(s) — see $LOG" >> "$HOOK_LOG"
fi

# Exit code: always 0 unless STOCKFORGE_DRIFT_STRICT=1 + any HIGH violation.
if [ "${STOCKFORGE_DRIFT_STRICT:-0}" = "1" ] && grep -q 'severity=HIGH' "$LOG" 2>/dev/null; then
  HIGH_COUNT="$(grep -c "severity=HIGH" "$LOG" 2>/dev/null || echo 0)"
  if [ "$HIGH_COUNT" -gt 0 ]; then
    printf '[drift-signals] BLOCKING: %d HIGH-severity drift(s) detected with STOCKFORGE_DRIFT_STRICT=1\n' "$HIGH_COUNT" >&2
    exit 2
  fi
fi

exit 0
