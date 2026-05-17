#!/usr/bin/env bash
# planner-feedback-loop.sh — Stop hook; per-plan throughput metric aggregator.
#
# Purpose (per plan-025 DD-8 + DD-9 + DD-10): when a plan transitions VERIFY-DONE
# this Stop window, read sessions-rollup.tsv last-30 rows for the plan_id, compute
# parallel_savings_min + per-task_class avg, write/refresh .planner-stats.tsv.
#
# Sources:
#   agent-workspace/memory/self-awareness/sessions-rollup.tsv (read; new 14-col schema per DD-7)
#   agent-workspace/session-plans/completed/*.md (detect VERIFY-DONE — mtime within last 5min)
#
# Output:
#   agent-workspace/memory/.planner-stats.tsv (refresh atomically per D-062)
#   agent-workspace/memory/.planner-feedback-emitted-<PLAN_ID> (debounce marker per DD-8)
#
# Bash + awk ONLY (no python/jq) per L-S11-1 portability discipline.
# Best-effort: errors suppressed via `|| true` — never blocks Stop pipeline.
#
# Trigger: Stop hook (after self-awareness-aggregate.sh in chain; plan-025 D6 wire-up
#          deferred — main session adds to settings.json post-dispatch).
#
# Schema (plan-025 DD-9):
#   task_class  sample_size  avg_wall_min  parallel_hit_rate  parallel_savings_avg  last_updated
#
# Age-decay (DD-10): weight=1.0 if <=30d; 0.5 if 30-90d; 0.0 if >90d.
# Back-compat: legacy 8-col sessions-rollup rows treated as cold-start (no plan_id).

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
MEM_DIR="$ROOT_DIR/agent-workspace/memory"
SA_DIR="$MEM_DIR/self-awareness"
ROLLUP="$SA_DIR/sessions-rollup.tsv"
PLANNER_STATS="$MEM_DIR/.planner-stats.tsv"
PLANS_COMPLETED_DIR="$ROOT_DIR/agent-workspace/session-plans/completed"
LOG="$ROOT_DIR/.session-hooks.log"

# Detect VERIFY-DONE: any plan-NNN-*.md moved to completed/ with mtime <5min
# Best-effort: if completed/ does not exist, exit silently.
if [[ ! -d "$PLANS_COMPLETED_DIR" ]]; then
    exit 0
fi

PLANS_DONE=""
# Use find with -mmin -30 for plans completed in last 30 minutes.
# Rationale (L-S354-2 D1 9th-instance fix): close-bookkeeping plan-mv happens
# AFTER the dev session's Stop event; -mmin -5 missed the mv window.
# Extended to -mmin -30 to catch async close-bookkeeping mv-s.
while IFS= read -r f; do
    PLANS_DONE="${PLANS_DONE}${f}"$'\n'
done < <(find "$PLANS_COMPLETED_DIR" -maxdepth 1 -name '*.md' -mmin -30 2>/dev/null || true)

if [[ -z "${PLANS_DONE// /}" ]]; then
    # No VERIFY-DONE this Stop window — silent skip.
    exit 0
fi

# Ensure planner-stats TSV exists with header.
if [[ ! -f "$PLANNER_STATS" ]]; then
    printf 'task_class\tsample_size\tavg_wall_min\tparallel_hit_rate\tparallel_savings_avg\tlast_updated\n' \
        > "$PLANNER_STATS" || true
fi

# Process each newly-completed plan.
while IFS= read -r plan_md; do
    [[ -z "$plan_md" ]] && continue
    [[ ! -f "$plan_md" ]] && continue

    # Extract plan_id from filename: e.g. "025-S346-planner-upgrade.md" → "025-S346-planner-upgrade"
    PLAN_BASENAME="$(basename "$plan_md" .md)"
    PLAN_ID="$PLAN_BASENAME"

    # Debounce: skip if already processed this plan_id.
    MARKER="$MEM_DIR/.planner-feedback-emitted-${PLAN_ID}"
    if [[ -f "$MARKER" ]]; then
        continue
    fi

    # Derive task_class from plan_id stem heuristic.
    # Strip leading NNN- session prefix; keep descriptive slug; canonicalize.
    TASK_CLASS="$(echo "$PLAN_ID" | sed -E 's/^[0-9]+-S[0-9]+-//' | sed -E 's/-/ /g' | awk '{print $1"-"$2}' | tr '[:upper:]' '[:lower:]')"
    [[ -z "$TASK_CLASS" ]] && TASK_CLASS="unknown"

    # Read sessions-rollup last-30 rows for rows matching this plan_id (col 9 = plan_id in 14-col rows).
    # Legacy 8-col rows have no plan_id field — skip for this plan's computation.
    wall_min_actual=0
    parallel_dispatched=0
    wall_min_estimated=0
    parallel_savings_min=0

    if [[ -r "$ROLLUP" ]]; then
        # Extract last 30 rows (skip header if present).
        RECENT_ROWS="$(tail -30 "$ROLLUP" 2>/dev/null | grep -v '^session_n' || true)"

        # Parse 14-col rows matching this plan_id (col 9).
        while IFS=$'\t' read -r _sn _sid _ts _tok _tools _subag _fcodes _wmin _pid _stc _par _west _wact _psav; do
            [[ "$_pid" == "$PLAN_ID" ]] || continue
            # Accumulate latest values (last matching row wins for actuals).
            [[ "$_par" =~ ^[0-9]+$ ]] && parallel_dispatched="$_par"
            [[ "$_west" =~ ^[0-9]+(\.[0-9]+)?$ ]] && wall_min_estimated="$_west"
            [[ "$_wact" =~ ^[0-9]+(\.[0-9]+)?$ ]] && wall_min_actual="$_wact"
            [[ "$_psav" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] && parallel_savings_min="$_psav"
        done <<< "$RECENT_ROWS" || true
    fi

    # Compute age-decay weighted average for this task_class from ALL rollup rows (last 30).
    # Weight = 1.0 (<=30d), 0.5 (30-90d), 0.0 (>90d). Compute in awk.
    NOW_EPOCH="$(date -u +%s 2>/dev/null || echo 0)"

    NEW_STATS="$(awk -v task_class="$TASK_CLASS" \
                     -v plan_id="$PLAN_ID" \
                     -v wall_actual="$wall_min_actual" \
                     -v par_dispatched="$parallel_dispatched" \
                     -v par_savings="$parallel_savings_min" \
                     -v now_epoch="$NOW_EPOCH" \
                     -v ts_updated="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        'BEGIN {
            sum_wall = 0; sum_weight = 0;
            par_count = 0; par_savings_sum = 0;
            # Include current plan_id row in computation.
            if (wall_actual + 0 > 0) {
                sum_wall += wall_actual * 1.0;
                sum_weight += 1.0;
            }
            if (par_dispatched + 0 > 0) {
                par_count++;
                par_savings_sum += par_savings + 0;
            }
            sample = (wall_actual + 0 > 0) ? 1 : 0;
        }
        /^session_n/ { next }
        NF >= 14 {
            # col 9 = plan_id, col 3 = ts_utc, col 8 = wall_min, col 11 = parallel_dispatched, col 14 = parallel_savings_min
            row_pid = $9; row_ts = $3; row_wmin = $8 + 0; row_par = $11 + 0; row_psav = $14 + 0;
            # Only rows for same task_class pattern — use plan_id prefix heuristic.
            split(row_pid, parts, "-");
            row_slug = (length(parts) >= 3) ? parts[3]"-"parts[4] : "unknown";
            if (row_slug != task_class) next;
            if (row_pid == plan_id) next;  # already counted above
            # Age decay: parse ts_utc → epoch (simple awk date parse best-effort).
            # Format: YYYY-MM-DDTHH:MM:SSZ → use date command not available in awk.
            # Fallback: treat all historical rows as 30d weight=0.5 (conservative).
            weight = 0.5;
            if (row_wmin > 0) {
                sum_wall += row_wmin * weight;
                sum_weight += weight;
                sample++;
            }
            if (row_par > 0) {
                par_count++;
                par_savings_sum += row_psav;
            }
        }
        END {
            avg_wall = (sum_weight > 0) ? sum_wall / sum_weight : 0;
            par_hit_rate = (sample > 0) ? int(par_count * 100 / sample) : 0;
            par_savings_avg = (par_count > 0) ? par_savings_sum / par_count : 0;
            printf "%s\t%d\t%.1f\t%d\t%.1f\t%s\n",
                task_class, sample, avg_wall, par_hit_rate, par_savings_avg, ts_updated;
        }' "$ROLLUP" 2>/dev/null || true)"

    if [[ -z "$NEW_STATS" ]]; then
        # Fallback: emit minimal row for this task_class from current plan only.
        NEW_STATS="${TASK_CLASS}	1	${wall_min_actual}	0	0.0	$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    fi

    # Atomic update of .planner-stats.tsv (D-062 tmp+mv pattern).
    STATS_TMP="$(mktemp "${PLANNER_STATS}.tmp.XXXXXX" 2>/dev/null || echo "${PLANNER_STATS}.tmp.$$")"

    # Rebuild stats file: keep header + all rows EXCEPT existing row for this task_class + append new row.
    {
        head -1 "$PLANNER_STATS" 2>/dev/null || \
            printf 'task_class\tsample_size\tavg_wall_min\tparallel_hit_rate\tparallel_savings_avg\tlast_updated\n'
        if [[ -r "$PLANNER_STATS" ]]; then
            tail -n +2 "$PLANNER_STATS" 2>/dev/null | grep -v "^${TASK_CLASS}	" || true
        fi
        printf '%s\n' "$NEW_STATS"
    } > "$STATS_TMP" 2>/dev/null || true

    mv -f "$STATS_TMP" "$PLANNER_STATS" 2>/dev/null || true

    # Touch debounce marker.
    touch "$MARKER" 2>/dev/null || true

    echo "[$(date -u +%FT%TZ)] planner-feedback-loop: processed plan_id=$PLAN_ID task_class=$TASK_CLASS wall_min_actual=$wall_min_actual parallel_dispatched=$parallel_dispatched" \
        >> "$LOG" 2>/dev/null || true

done <<< "$PLANS_DONE"

exit 0
