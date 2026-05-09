#!/usr/bin/env bash
# drift-signals-D1-D9.sh — composite drift detector running 9 grep-based signals.
# D1 = LOC ceiling overrun (PRIMARY per Q-A2 answer 2026-04-29: highest empirical firing
# rate at S2). D2-D8 = secondary checks. D9 = runtime-path-leak into write-only
# learning-data/(events|archive)/ tree (Track 5.5d.1 D-5 deliverable per D-005).
# Append violations to .drift-signals.log.
# Decision 002 § Track 5 REV-2 § B + Decision 005 § 5.5d.1.
set -uo pipefail
trap 'exit 0' ERR

# === L-S48d-1 lint flag — S57 retrofit (1 real fix + KI-S54-1 ratify) ===
# bash-hook-lint Check 7 flags this file. Categorization:
#   FIXED S57: D4-loop bare-grep `REFS="$(grep -oE ... | sort -u | head -5)"`
#     was unguarded — no-match returned 1 → pipefail propagated → ERR-trap
#     `exit 0` silently aborted spec scanning. Added `|| true` end-of-pipeline.
#     REAL bug, not alt-guard form (only one in this file).
#   Many `if grep -qE ...; then` and `if ! grep -qiE ...; then` forms — exit
#     consumed by `if` → ERR-trap exempt per bash spec ✓
#   Many `VAR="$(grep ... | wc -l | tr -d '...' || echo 0)"` — alt-guard
#     `|| echo 0` end-of-pipeline ✓ (KI-S54-1 recognition)
#   `if [ X = "1" ] && grep -q ...; then` (line ~202) — `&&`-chain in `if` ✓
# Per-file Check 7 design keeps flag (alt-guards not normalized to `|| true`).
# Lint refinement deferred per KI-S54-1.

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
# S118 narrowed scan window 1440 → 60 min: session logs are write-once historical
# records; re-flagging the same archived log on every SessionStart added 396/day MEDIUM
# emissions with 0 actionable catch-rate (see drift-rollup 2026-05-06). Active-work window
# captures fresh-write at session-end ritual; archived logs fall out cleanly. CLAUDE.md S99
# ritual demotion (catch-rate=0 ⇒ demote-to-passive) + L-S69-1 family (artifact-verifier
# hooks must scope to active target, not historical archive).
SESSION_LOGS="$(find "$PROJECT_DIR/agent-workspace/memory/sessions" -name '*.md' -mmin -60 2>/dev/null || true)"
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
  REFS="$(grep -oE 'packages/[a-z_/-]+\.py|apps/[a-z_/-]+\.py' "$s" 2>/dev/null | sort -u | head -5 || true)"
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
# Track 5.5d.1 boundary discipline (D-005). Whitelist: hooks that legitimately write/admin events
# OR legitimately read events for metric-computation per Phase 0 Karpathy-loop framing (L-S12).
LEARNING_WRITE_HOOKS="component-telemetry|learning-queue-sweeper|learning-index-rebuild|drift-signals-D1-D9|metric-failure-mode-rate"
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

# === DR1 (HH-B.4 extension): Domain layer imports framework (HIGH) ===
# Doctrine-codified per agent-workspace/constitution/drift-signals.md DR1.
if [ -d "$PROJECT_DIR/packages/domain" ]; then
  DR1_HITS="$(grep -rn "from fastapi\|from pydantic\|from sqlalchemy\|import psycopg\|from redis" \
    "$PROJECT_DIR/packages/domain/" --include="*.py" 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)"
  [[ "$DR1_HITS" =~ ^[0-9]+$ ]] || DR1_HITS=0
  if [ "$DR1_HITS" -gt 0 ]; then
    emit "DR1-DOMAIN-FRAMEWORK" "HIGH" "count=$DR1_HITS scope=packages/domain/**"
  fi
fi

# === DR3 (HH-B.4 extension): LLM call without retry/budget wrapper (MEDIUM) ===
if [ -d "$PROJECT_DIR/packages/infrastructure" ]; then
  DR3_HITS="$(grep -rn "anthropic\.Anthropic\|client\.messages\.create" \
    "$PROJECT_DIR/packages/infrastructure/" --include="*.py" 2>/dev/null \
    | grep -v "with_budget\|with_retry\|budget_aware" | wc -l | tr -d '[:space:]' || echo 0)"
  [[ "$DR3_HITS" =~ ^[0-9]+$ ]] || DR3_HITS=0
  if [ "$DR3_HITS" -gt 0 ]; then
    emit "DR3-LLM-NO-RETRY" "MEDIUM" "count=$DR3_HITS scope=packages/infrastructure/**"
  fi
fi

# === DR6 (HH-B.4 extension): Any type in domain package (HIGH) ===
if [ -d "$PROJECT_DIR/packages/domain" ]; then
  DR6_HITS="$(grep -rn ": Any\|cast(Any\|-> Any" "$PROJECT_DIR/packages/domain/" --include="*.py" 2>/dev/null \
    | grep -v "test_\|_test\.py" | wc -l | tr -d '[:space:]' || echo 0)"
  [[ "$DR6_HITS" =~ ^[0-9]+$ ]] || DR6_HITS=0
  if [ "$DR6_HITS" -gt 0 ]; then
    emit "DR6-DOMAIN-ANY-TYPE" "HIGH" "count=$DR6_HITS scope=packages/domain/**"
  fi
fi

# === DR8 (HH-B.4 extension): Cross-BC direct import (HIGH) ===
if [ -d "$PROJECT_DIR/packages/domain" ]; then
  DR8_TOTAL=0
  for BC in market_data fundamental company_intelligence macro news influence crowd analysis portfolio; do
    [ -d "$PROJECT_DIR/packages/domain/$BC" ] || continue
    bc_hits="$(grep -rn "from packages\.domain\." "$PROJECT_DIR/packages/domain/$BC/" --include="*.py" 2>/dev/null \
      | grep -v "packages/domain/$BC/" | wc -l | tr -d '[:space:]' || echo 0)"
    [[ "$bc_hits" =~ ^[0-9]+$ ]] && DR8_TOTAL=$(( DR8_TOTAL + bc_hits ))
  done
  if [ "$DR8_TOTAL" -gt 0 ]; then
    emit "DR8-CROSS-BC-IMPORT" "HIGH" "count=$DR8_TOTAL scope=packages/domain/<BC>/**"
  fi
fi

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "[$TS] drift-signals-D1-D9: $VIOLATIONS violation(s) — see $LOG" >> "$HOOK_LOG"
fi

# Exit code: always 0 unless STOCKFORGE_DRIFT_STRICT=1 + any HIGH violation.
if [ "${STOCKFORGE_DRIFT_STRICT:-0}" = "1" ] && grep -q 'severity=HIGH' "$LOG" 2>/dev/null; then
  HIGH_COUNT="$(grep -c "severity=HIGH" "$LOG" 2>/dev/null || true)"
  if [ "$HIGH_COUNT" -gt 0 ]; then
    printf '[drift-signals] BLOCKING: %d HIGH-severity drift(s) detected with STOCKFORGE_DRIFT_STRICT=1\n' "$HIGH_COUNT" >&2
    exit 2
  fi
fi

exit 0
