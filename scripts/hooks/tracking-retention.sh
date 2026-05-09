#!/usr/bin/env bash
# tracking-retention.sh — Stop-hook retention guard for tracking files (S99 RCA Layer 1;
# S135 PROMOTION: current-execution.md gains AUTO-MIGRATE branch on LOC>200; S141 PROMOTION:
# AUTO-MIGRATE pre-condition extended to (LOC>200 OR sessions>5) — closes HOOK GAP surfaced
# at S140 close where sessions-cap-only-breach NO-OP'd despite Charter "both caps must hold")
#
# Purpose: warn (and emit notification) when tracking files exceed their cap thresholds.
# Per RCA-2026-05-06-S98 user pick Q-RCA-1 = A. WARN-ONLY for agent-notes/mistake-log/telemetry.
# Per S135 promote-or-retire decision (3rd-instance mid-session migration pattern at
# S132/S133/S134 closes): current-execution.md cap-breach now AUTO-MIGRATES the oldest
# inline session row to the latest archive file, then re-reads LOC for downstream WARN logic.
# Empirically validated: 3 manual instances at S132/S133/S134 each followed identical
# mechanical steps (find oldest ## S, append to archive, trim from current-exec, bump
# frontmatter sessions_archived). Manual cost ~30sec × every dense session = real toil
# per L-S65-2 harness-priority-1 + Charter Principle 8 (calibration over confidence).
# Per S141 HOOK GAP closure (sessions-cap-only-breach observed at S140-Stop): trigger now
# fires on EITHER cap, matching CLAUDE.md "both caps must hold" rule semantics.
#
# Wires: Stop hook in .claude/settings.json. Soft-warn only (exit 0 always; never blocks).
# Output: per-violation lines to .session-hooks.log + 1 notification when ≥1 violation.
# AUTO-MIGRATE side-effect: appends to archive file + truncates current-execution.md when
#   (LOC > 200 OR sessions > 5) AND sessions >= 2 AND latest archive file exists.
#   Records migration line in log with trigger-reason (LOC>200 / sessions>5 / both).
#
# Cap thresholds (per Q-RCA-1 = A acceptance):
#   - current-execution.md: ≤ 5 active session rows (## S<N> headers); ≤ 200 LOC total
#       — BOTH caps NOW AUTO-RESOLVED via migration (S135 LOC promotion + S141 sessions promotion);
#         WARN paths retained for residual post-fire breach (e.g., sessions=7 pre-fire → 6 post-fire).
#   - agent-notes.md: ≤ 700 LOC total (charter rules ~485 + digest ~50 + safety margin)
#   - mistake-log.md: ≤ 200 LOC total
#   - component-telemetry.jsonl: ≤ 10 MB (rotated weekly by telemetry-rotate.sh — separate hook)
#
# Per L-S10-1: split-local; if/then/fi only.
# Per L-S80-1: empirical regex pre-test passed.
# Per L-S80-2: no `grep -c ... || echo 0` multi-line capture trap.
# Per L-S69-1: artifact-verifier whitelist — this hook is a verifier; main agent-notes/mistake-log/current-execution
#   are its targets; no self-reference.
# Per M-S130-1 family: writer/reader contracts validated (LOC counts derived from same wc -l semantics).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

VIOLATIONS=0
VIOLATION_LINES=""

# Cap 1: current-execution.md ≤ 5 session rows + ≤ 200 LOC
CE_FILE="$MEM_DIR/current-execution.md"
MIGRATED=0
MIGRATED_SESSION=""
if [ -f "$CE_FILE" ]; then
  CE_LOC=$(wc -l < "$CE_FILE" 2>/dev/null || true)
  CE_LOC="${CE_LOC:-0}"
  CE_SESSIONS=$(grep -c "^## S[0-9]" "$CE_FILE" 2>/dev/null || true)
  CE_SESSIONS="${CE_SESSIONS:-0}"

  # S135+S141 promotion: AUTO-MIGRATE oldest inline session if EITHER cap breached.
  # Conditions: (LOC>200 OR sessions>5) AND sessions>=2 (don't drain to 0) AND archive exists.
  # S141 fix: SHOULD_MIGRATE flag composes the OR while preserving L-S10-1 split-local idiom.
  SHOULD_MIGRATE=0
  if [ "$CE_LOC" -gt 200 ]; then
    SHOULD_MIGRATE=1
  fi
  if [ "$CE_SESSIONS" -gt 5 ]; then
    SHOULD_MIGRATE=1
  fi
  if [ "$SHOULD_MIGRATE" -eq 1 ] && [ "$CE_SESSIONS" -ge 2 ]; then
    # Find newest dated archive file (current-execution-archive-YYYY-MM-DD-*.md preferred).
    # Falls back to bare current-execution-archive.md if dated form absent.
    ARCH_FILE=""
    for cand in $(ls -t "$MEM_DIR"/current-execution-archive-*.md 2>/dev/null); do
      ARCH_FILE="$cand"
      break
    done
    if [ -z "$ARCH_FILE" ] && [ -f "$MEM_DIR/current-execution-archive.md" ]; then
      ARCH_FILE="$MEM_DIR/current-execution-archive.md"
    fi
    if [ -n "$ARCH_FILE" ] && [ -f "$ARCH_FILE" ]; then
      # Locate OLDEST inline session block: last `^## S<N>` header (highest line number).
      # Guards (per L-S48d-1): `|| true` ensures pipefail+ERR-trap doesn't silent-exit.
      # Pre-condition CE_SESSIONS>=2 already guarantees grep finds matches in practice.
      LAST_HEADER_LINE=$(grep -n "^## S[0-9]" "$CE_FILE" 2>/dev/null | tail -1 | cut -d: -f1 || true)
      TOP_HEADER_LINE=$(grep -n "^## S[0-9]" "$CE_FILE" 2>/dev/null | head -1 | cut -d: -f1 || true)
      if [ -n "$LAST_HEADER_LINE" ] && [ -n "$TOP_HEADER_LINE" ] && [ "$LAST_HEADER_LINE" != "$TOP_HEADER_LINE" ]; then
        OLDEST_NUM=$(awk "NR==$LAST_HEADER_LINE" "$CE_FILE" | sed -E 's/^## S([0-9]+).*/\1/')
        CURRENT_NUM=$(awk "NR==$TOP_HEADER_LINE" "$CE_FILE" | sed -E 's/^## S([0-9]+).*/\1/')
        if [ -n "$OLDEST_NUM" ] && [ -n "$CURRENT_NUM" ]; then
          # Extract block (LAST_HEADER_LINE..EOF) → append to archive with provenance line.
          # Trim block from current-exec → keep lines 1..(LAST_HEADER_LINE-1).
          TRIM_LINE=$((LAST_HEADER_LINE - 1))
          TMP_BLOCK=$(mktemp 2>/dev/null) || TMP_BLOCK="$MEM_DIR/.auto-migrate-block.tmp"
          TMP_NEW_CE=$(mktemp 2>/dev/null) || TMP_NEW_CE="$MEM_DIR/.auto-migrate-ce.tmp"
          tail -n +"$LAST_HEADER_LINE" "$CE_FILE" > "$TMP_BLOCK" 2>/dev/null
          head -n "$TRIM_LINE" "$CE_FILE" > "$TMP_NEW_CE" 2>/dev/null
          if [ -s "$TMP_BLOCK" ] && [ -s "$TMP_NEW_CE" ]; then
            # Compute trigger reason for provenance accuracy (S141 promotion: either-cap fire).
            TRIGGER_REASON=""
            if [ "$CE_LOC" -gt 200 ]; then
              TRIGGER_REASON="LOC>200"
            fi
            if [ "$CE_SESSIONS" -gt 5 ]; then
              if [ -n "$TRIGGER_REASON" ]; then
                TRIGGER_REASON="$TRIGGER_REASON+sessions>5"
              else
                TRIGGER_REASON="sessions>5"
              fi
            fi
            # Strip trailing `\n---\n+` from extracted block (will be re-emitted via printf for cleanliness).
            # Append to archive with separating blank line + migration provenance footer.
            {
              printf '\n'
              cat "$TMP_BLOCK"
              printf '\n**Migrated to archive at S%s (auto-migrate via tracking-retention.sh; %s; S135+S141 promotions).**\n' "$CURRENT_NUM" "$TRIGGER_REASON"
            } >> "$ARCH_FILE" 2>/dev/null
            # Replace current-exec with trimmed version.
            cp "$TMP_NEW_CE" "$CE_FILE" 2>/dev/null
            # Update archive frontmatter `sessions_archived: S<old> →` → `sessions_archived: S<new> →`.
            # In-place via sed; backup deleted.
            sed -i.bak -E "s/^sessions_archived: S[0-9]+ /sessions_archived: S$OLDEST_NUM /" "$ARCH_FILE" 2>/dev/null
            rm -f "$ARCH_FILE.bak" 2>/dev/null
            MIGRATED=1
            MIGRATED_SESSION="S$OLDEST_NUM"
            # Re-read CE_LOC + CE_SESSIONS so downstream WARN sees post-migrate state.
            CE_LOC=$(wc -l < "$CE_FILE" 2>/dev/null || true)
            CE_LOC="${CE_LOC:-0}"
            CE_SESSIONS=$(grep -c "^## S[0-9]" "$CE_FILE" 2>/dev/null || true)
            CE_SESSIONS="${CE_SESSIONS:-0}"
            # Log migration event (S141: trigger reason added for diagnostics).
            printf '[%s] tracking-retention: AUTO-MIGRATED %s from current-execution.md → %s (trigger=%s post-migrate LOC=%s sessions=%s)\n' \
              "$TS" "$MIGRATED_SESSION" "$(basename "$ARCH_FILE")" "$TRIGGER_REASON" "$CE_LOC" "$CE_SESSIONS" >> "$LOG" 2>/dev/null
          fi
          rm -f "$TMP_BLOCK" "$TMP_NEW_CE" 2>/dev/null
        fi
      fi
    fi
  fi

  # Cap-check (post-migration if it ran). LOC cap should now be satisfied; sessions cap still WARN.
  if [ "$CE_LOC" -gt 200 ]; then
    VIOLATIONS=$((VIOLATIONS + 1))
    VIOLATION_LINES="$VIOLATION_LINES
[$TS] tracking-retention: current-execution.md LOC=$CE_LOC > cap 200 (auto-migrate skipped or failed; suggest manual archive)"
  fi
  if [ "$CE_SESSIONS" -gt 5 ]; then
    VIOLATIONS=$((VIOLATIONS + 1))
    VIOLATION_LINES="$VIOLATION_LINES
[$TS] tracking-retention: current-execution.md sessions=$CE_SESSIONS > cap 5 (archive oldest sessions to current-execution-archive-YYYY-MM-DD-S<from>-to-S<to>.md)"
  fi
fi

# Cap 2: agent-notes.md ≤ 700 LOC. Primary defense = LOC cap.
# D-039 Bug #4 RETIRE: AN_LESSONS supplementary digest-violation WARN dropped — was authored from
# false premise (digest = table-rows-only). Real-state shows agent-notes "Recent Rules (digest;
# last 5)" uses inline `### YYYY-MM-DD (S<N>): <Title> — L-S<N>-<M>` cards as canonical digest.
# AN_LESSONS diagnostic var retained in summary for forward-compat / observability.
AN_FILE="$MEM_DIR/agent-notes.md"
if [ -f "$AN_FILE" ]; then
  AN_LOC=$(wc -l < "$AN_FILE" 2>/dev/null || true)
  AN_LOC="${AN_LOC:-0}"
  # pattern-lint-skip: D-039 Bug #4 RETIRE — counter retained for forward-compat observability;
  # 0-match against real agent-notes.md is by-design (real format = inline cards, not ### headers)
  AN_LESSONS=$(grep -c "^### L-S" "$AN_FILE" 2>/dev/null || true)
  AN_LESSONS="${AN_LESSONS:-0}"
  if [ "$AN_LOC" -gt 700 ]; then
    VIOLATIONS=$((VIOLATIONS + 1))
    VIOLATION_LINES="$VIOLATION_LINES
[$TS] tracking-retention: agent-notes.md LOC=$AN_LOC > cap 700 (digest section grew; consider sub-archive)"
  fi
fi

# Cap 3: mistake-log.md ≤ 200 LOC. Primary defense = LOC cap.
# D-039 Bug #5 RETIRE: ML_MISTAKES supplementary digest-violation WARN dropped — same false premise
# as Bug #4. Real-state digest format post-RCA-2026-05-06 = table rows `| M-S<N>-<M> | ... |`.
# ML_MISTAKES diagnostic var retained in summary for forward-compat / observability.
ML_FILE="$MEM_DIR/mistake-log.md"
if [ -f "$ML_FILE" ]; then
  ML_LOC=$(wc -l < "$ML_FILE" 2>/dev/null || true)
  ML_LOC="${ML_LOC:-0}"
  # pattern-lint-skip: D-039 Bug #5 RETIRE — counter retained for forward-compat observability;
  # 0-match against real mistake-log.md is by-design (real format = table-row digest, not ### headers)
  ML_MISTAKES=$(grep -c "^### M-S" "$ML_FILE" 2>/dev/null || true)
  ML_MISTAKES="${ML_MISTAKES:-0}"
  if [ "$ML_LOC" -gt 200 ]; then
    VIOLATIONS=$((VIOLATIONS + 1))
    VIOLATION_LINES="$VIOLATION_LINES
[$TS] tracking-retention: mistake-log.md LOC=$ML_LOC > cap 200 (digest grew; archive bodies)"
  fi
fi

# Cap 4: component-telemetry.jsonl ≤ 10 MB (weekly rotate handled by telemetry-rotate.sh)
TEL_FILE="$MEM_DIR/component-telemetry.jsonl"
if [ -f "$TEL_FILE" ]; then
  TEL_BYTES=$(stat -c %s "$TEL_FILE" 2>/dev/null || stat -f %z "$TEL_FILE" 2>/dev/null)
  TEL_BYTES="${TEL_BYTES:-0}"
  if [ "$TEL_BYTES" -gt 10485760 ]; then
    VIOLATIONS=$((VIOLATIONS + 1))
    VIOLATION_LINES="$VIOLATION_LINES
[$TS] tracking-retention: component-telemetry.jsonl size=$TEL_BYTES bytes > cap 10485760 (10 MB); ensure telemetry-rotate.sh weekly is scheduled"
  fi
fi

# Log
if [ "$VIOLATIONS" -gt 0 ]; then
  printf '%s' "$VIOLATION_LINES" >> "$LOG" 2>/dev/null
  printf '\n' >> "$LOG" 2>/dev/null
fi

# Notification (single file, overwrite-style; latest only)
if [ "$VIOLATIONS" -gt 0 ]; then
  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  NOTIF_FILE="$NOTIF_DIR/tracking-retention-cap-breach.md"
  {
    printf '# Tracking Retention Cap Breach — %s\n\n' "$TS"
    printf 'Per RCA-2026-05-06-S98 Layer 1 retention rule, %d violation(s) detected:\n' "$VIOLATIONS"
    printf '%s\n\n' "$VIOLATION_LINES"
    printf 'Manual archive playbook: see CLAUDE.md § Tracking retention. Auto-archive deferred for safety (Q-RCA-1 = A first version).\n'
  } > "$NOTIF_FILE" 2>/dev/null || true
fi

# Summary line for diagnostics (includes auto-migrate flag for S135 promotion observability).
printf '[%s] tracking-retention: violations=%d migrated=%d migrated_session=%s ce_loc=%s ce_sessions=%s an_loc=%s an_lessons=%s ml_loc=%s ml_mistakes=%s tel_bytes=%s\n' \
  "$TS" "$VIOLATIONS" "$MIGRATED" "${MIGRATED_SESSION:-none}" "${CE_LOC:-na}" "${CE_SESSIONS:-na}" "${AN_LOC:-na}" "${AN_LESSONS:-na}" "${ML_LOC:-na}" "${ML_MISTAKES:-na}" "${TEL_BYTES:-na}" >> "$LOG" 2>/dev/null

exit 0
