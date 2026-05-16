---
plan_id: 024-S345-block-ask-gate-3-tier
target_session: S346
type: FOCUSED_IMPL
budget: 120-180K (Opus FOCUSED_IMPL — multi-file but well-scoped per DD-1..DD-12; Sonnet acceptable if 3-tier model still fresh-context after recent verifier dispatch)
phase: B/D-overlap (HARNESS — not product work; per `harness_priority_one` doctrine takes precedence over Phase D continuation Vietstock/VietnamBiz adapters + Phase E Theme I Vietnamese NLP until block-spam reduction ships)
track: Block/Ask-user Gate 3-Tier Redesign — replace current binary CRITICAL=BLOCK with HARD / PENDING / SOFT model + Telegram 6h escalator + 24h auto-archive
parent_master_plan: agent-workspace/proposals/harness-severity-escalation-system-2026-05-14.md
                    (Phase A-D shipped S310; this plan SUPERSEDES residual CRITICAL-tier behavior; PENDING is new tier between HIGH and CRITICAL)
predecessor: agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md (design proposal authored by main S344 turn; user ratified 2026-05-16 ~20:30 SEAST)
successor: S347 sandwich-verifier (AP-1 fresh-context, Opus, ~50-80K VERIFY budget)
architect: S345 sandwich-architect (this plan, background dispatch ac4c3d5560f90c553-class)
dispatched_by: S345-main turn (parent main session orchestrating Block/Ask-user-Gate PLAN-IMPL-VERIFY sandwich after S344 Phase D NDH adapter close)
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S346; fresh-context; AP-1 verifier in S347)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (post 2026-05-14 mass-deletion; per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING cadence + ROUTINE-IDLE close ritual SUSPENDED (carry-forward; do NOT recommend sync-grilling cadence as part of fixes)"
  - "BEHAVIORAL HOLD § (b) — Telegram E2E verified live to chat 891087440 'Lê Lợi'; creds in .claude/settings.local.json env block"

depends_on:
  - "D-060 (commit-policy-agent-may-commit — operational gate for S346 dev commit boundary; sandwich-dev commits own work, main commits architect-only outputs per dispatch-template-gap recovery pattern)"
  - "D-062 (atomic-write-doctrine — BINDING for all new .pending-queue.tsv writes per DD-11)"
  - "D-064 (path-safety 5-invariant contract — BINDING for archive move paths per DD-12; helpers from packages/_shared/path_safety.py if invoked by Python; bash use literal-anchor + basename guard)"
  - "Charter v1.1 Principle 11 (Harness must self-verify firing — D1-D7 ALL ship companion firing-tests + verification grids)"
  - "Charter v1.1 Principle 7 (Dogfood mandatory — fixes self-audited via the affected hook chains in same session)"
  - "I-S33 self-aware-agent invariant (harness reliability is the substrate for I-S33; reducing forced-pause friction protects it)"
  - "agent-workspace/CLAUDE.md Contract Rule 1 (constitution immutable absent explicit human approval — sandwich-dev cannot edit constitution/; new ADR D-068 lives in `memory/decisions/` not constitution per S345 brief)"
  - "CLAUDE.md `harness_priority_one` memory rule (harness/system improvement is always higher priority than product work)"
  - "CLAUDE.md `full_autonomous_no_supervised` memory rule (AskUserQuestion is for SCOPE/CHARTER only; this plan reduces non-SCOPE/CHARTER intervention friction)"
  - "AP-1 fresh-context discipline (architect ↔ dev ↔ verifier all in separate contexts)"
  - "AP-7 anti-vacuous-defer (every DEFER decision in this plan names prerequisites + revisit trigger)"
  - "AP-23 promote-or-retire (3-tier model PROMOTES the previously-distributed informal 'pending' notion to a 1st-class harness primitive — this IS the promotion event)"
  - "scripts/hooks/severity-classifier.sh (D1 primary target — reclassify 5 trigger types from CRITICAL→PENDING)"
  - "scripts/hooks/escalation-engine.sh (D2 routing-change target — HARD→flag, PENDING→queue, SOFT→unchanged)"
  - "scripts/hooks/block-control.sh (D4 ack subcommand + check-prompt regex extension target)"
  - "scripts/hooks/autonomous-block-enforcer.sh (NO CHANGE per observation § Implementation — already correctly keyed off .autonomous-BLOCKED flag)"
  - "scripts/hooks/telegram-push.sh (NO CHANGE — pending-queue-escalator calls it as a library; existing severity-tagged push body works)"
  - ".claude/settings.json (D6 wire-up of new pending-queue-escalator.sh in Stop chain)"
  - "agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md (PRIMARY source — design model + mapping table + Telegram payload sample + 5 fire-test categories)"
  - "agent-workspace/memory/checkpoints/latest.md § Harness anomalies (queue snapshot referencing block-spam frequency)"
  - "agent-workspace/proposals/harness-severity-escalation-system-2026-05-14.md (predecessor proposal that shipped Phase A-D)"

binding_decisions:
  - "D-060 — agent MAY git commit (NOT push); S346 dev decides commit boundary"
  - "Q-RD1 RATIFIED (user 'follow your recommendation' 2026-05-16 ~20:30 SEAST): archive/ for audit trail (not delete) — PENDING rows older than 24h mv to human-workspace/notifications/archive/ preserving full row + content"
  - "Q-RD2 RATIFIED: no special tier for Q&A >7d — sustained Telegram nag every 24h is enough; HARD reserved for active-danger PreToolUse cases not Q&A age"
  - "Q-RD3 RATIFIED: keep HARD triggers DISTRIBUTED across guards (destructive-command-guard + project-integrity-watchdog manage their own HARD); severity-classifier focuses on PENDING signals"
  - "Q-RD4 RATIFIED: `ack <slug>` single-token keyword for user to dismiss a PENDING row; multi-ack per prompt supported"
  - "AP-23 promote-or-retire — applied at the ENTIRE-redesign level: 3-tier model promotes the informal 'pending-or-not-really-blocking' notion (2nd+ instance distributed across 5 ad-hoc trigger types per observation Mapping table) into one 1st-class harness primitive"
  - "AP-7 anti-vacuous-defer — every DEFER decision in this plan names (a) prerequisites + (b) revisit trigger"
  - "Karpathy P3 surgical-changes — every recommendation in this plan traces to the observation file's Mapping table + 5 fire-test categories; NO invented harness work"
  - "VBW protocol mandatory — sandwich-dev MUST re-read the actual hook files at S346 IMPL start before editing (architect read at S345; dev fresh-context must re-verify before mutation)"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL; this plan is architect's; S346 is dev's)"
  - "no commits in THIS plan-session (sandwich-architect subagent has no Bash tool; main commits this plan output per D-060 + dispatch-template recovery pattern from S335/S337/S340/S343)"
  - "no charter / no constitution writes in THIS plan-session AND no charter / no constitution writes in S346 IMPL (0 charter / 0 constitution per S345 brief; D-068 PROPOSED at IMPL tier lives in `agent-workspace/memory/decisions/` NOT in `agent-workspace/constitution/`)"
  - "no production code outside scripts/hooks/ + .claude/settings.json + agent-workspace/memory/decisions/ + scripts/hooks/firing-tests/ + agent-workspace/memory/observations/ + agent-workspace/session-plans/"
  - "no human-workspace writes outside human-workspace/notifications/.pending-queue.tsv + human-workspace/notifications/archive/** (auto-archive destination per Q-RD1)"
  - "no AskUserQuestion gate in S345 plan-session or S346 IMPL (per `full_autonomous_no_supervised` AskUserQuestion is for SCOPE/CHARTER only; all 4 Q-RD already ratified)"
  - "Telegram smoke test at STEP 0.3 is ESSENTIAL (per S345 brief 'do not skip') — sandwich-dev MUST execute and capture the response code in session log"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual hook files re-read end-to-end via Read tool at S346 IMPL start, not memory (VBW protocol; architect's read at S345 does NOT substitute)"
  - "D-062 atomic-write doctrine MANDATORY for .pending-queue.tsv writes (tmp + mv -f + trap EXIT cleanup pattern; mirror severity-classifier.sh:33-41 S341 D2 fix)"
  - "D-064 path-safety 5-invariant contract MANDATORY for archive moves (basename whitelist + literal-anchor + no `..` + no symlink-follow + audit log)"
---

# S346 — Block/Ask-user Gate 3-Tier Redesign

## § A. Session metadata

| Field | Value |
|---|---|
| Plan ID | 024-S345-block-ask-gate-3-tier |
| Target session | S346 (sandwich-dev, FOCUSED_IMPL) |
| Verify session | S347 (sandwich-verifier, AP-1 fresh-context Opus) |
| Budget | 120-180K Opus (FOCUSED_IMPL; multi-file but well-scoped per DD-1..DD-12) |
| Phase | B/D-overlap (HARNESS — non-product) |
| Type | FOCUSED_IMPL |
| Wave / Theme | Wave-1 substrate-care; ships 3-tier escalation primitive |
| Coordination paths off-limits during S346 IMPL | See § J |
| Predecessor | agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md (design proposal; user ratified) |

## § B. Predecessor + invocation context

**Why this session now**: per CLAUDE.md `harness_priority_one` memory rule, harness/system improvement takes precedence over product work whenever surfaced as blocking or recurrence-pattern. The observation file at `agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md` (HIGH severity per frontmatter, ~13KB / 242 lines) documents:

1. **Empirical pain pattern**: every ~3rd autonomous turn requires user "approved" keyword to clear `.autonomous-BLOCKED` (per observation TL;DR); degrades autonomous-mode value proposition
2. **5 current CRITICAL trigger types** (per observation § Current CRITICAL triggers — verified at `scripts/hooks/severity-classifier.sh:64-144`):
   - Layer 1: `.auto-reboot-PRE-BLOCKED-stale-checkpoint` marker exists
   - Layer 1: `.charter-violation-detected` marker exists (M-S342-1 was test-fixture; LOSS SURFACE MEDIUM → LOW under new model per § AQ-12)
   - Layer 1: `.ghost-greening-confirmed` marker exists
   - Layer 2: Q&A pending bundle age ≥ 96h
   - Layer 3: PROPOSED ADR expired cool-down (charter-tier ≥24h)
3. **None of these meet the 'must stop now' bar** (per observation § Current CRITICAL triggers verdict column) — they're all soft signals the user could review at convenience; the real "must stop now" cases (rm -rf, git push --force, mass-deletion) are caught earlier by `destructive-command-guard.sh` (PreToolUse) + `project-integrity-watchdog.sh` (Stop) which already have their own gating logic and DON'T depend on the BLOCKED-flag flow

**User ratification chain**:
- 2026-05-16 ~14:00 SEAST: user_prompt 20260516_01.txt § 2 surfaces the problem ("a lot of time claude code stop, need user intervent")
- 2026-05-16 ~19:30 SEAST: main S344-close turn authors observation file with 3-tier proposal + 4 Q-RD questions
- 2026-05-16 ~20:30 SEAST: user "follow your recommendation" + "run full autonomous" → all 4 Q-RD ratified per architect recommendations
- 2026-05-16 ~21:00 SEAST: main S345 turn dispatches sandwich-architect (this plan) per AP-1 fresh-context

**Empirical investigation finding** (this architect's VBW pass — ~15 hooks read end-to-end):

The cascade for the M-S342-1-style false-block is:
1. `sandwich-verifier-S342.md` fire-test wrote `.charter-violation-detected` as a TEST FIXTURE to exercise `severity-classifier.sh:72` CRIT_MARKERS detection
2. Verifier exited without cleanup (no trap EXIT for fixture artifacts)
3. Next Stop hook fires `severity-classifier.sh:75-80` → file present → emit `CRITICAL\t<rel>\t0\tBLOCK\t<ts>`
4. `escalation-engine.sh:89-103` → CRIT_N > 0 + no `.block-grace` → writes `.autonomous-BLOCKED`
5. `autonomous-block-enforcer.sh:73-97` → next PreToolUse → Bash/Edit/Write blocked
6. User must reply "approved" → `block-control.sh:209` regex match → `cmd_clear` → flag deleted
7. Total cost: 1 forced user intervention + grace 1800s for legitimate test-fixture work

**Under proposed 3-tier model** (this architect's mental simulation per § AQ-12):
1. Same `.charter-violation-detected` fixture would emit `CRITICAL\t<rel>\t0\tBLOCK-PENDING\t<ts>\tPENDING` (NEW col6)
2. `escalation-engine.sh` (post D2 edit) → PENDING tier → write row to `.pending-queue.tsv` with `escalate_at = now + 6h`; DO NOT write `.autonomous-BLOCKED`
3. Agent continues other work
4. `pending-queue-escalator.sh` (NEW, Stop cadence) re-checks queue; at 6h boundary → Telegram fires once
5. By 24h boundary → if `.charter-violation-detected` artifact STILL exists (verifier never cleaned up) → auto-archive to `notifications/archive/`
6. User can reply "ack charter-violation" at any time → `block-control.sh check-prompt` (D4 extension) → row resolved
7. Total cost: 0 forced user interventions for the typical fixture-leak case

**This plan ships the 7 sub-tracks D1-D7 enumerated in § D. 0 deferred items** (per AP-7 — every design choice already resolved at PLAN tier per observation file + Q-RD ratification).

## § C. Charter compliance map

This plan ships **0 charter edits / 0 constitution writes**. Confirmation matrix:

| Boundary | Status | How protected |
|---|---|---|
| PROJECT_CHARTER.md | UNTOUCHED | not in any sub-track's file list |
| agent-workspace/constitution/** | UNTOUCHED | sandwich-dev cannot Write here (`.claude/settings.json` deny); ADR D-068 lives in `agent-workspace/memory/decisions/` per S345 brief |
| obsidian-vault/raw/** | UNTOUCHED | not in any sub-track's file list |
| Principle 11 (Harness self-verify firing) | UPHELD | D1-D4 + D6 sub-tracks ALL ship companion firing-test extensions; D3 new hook ships its OWN companion firing-test under `scripts/hooks/firing-tests/pending-queue-escalator-fire-test.sh` |
| Principle 7 (Dogfood) | UPHELD | D7 dogfoods full chain in same session (sandwich-dev triggers each of 5 trigger types end-to-end + verifies PENDING tier emission + ack flow) |
| I-S1 (No LLM math) | N/A | no LLM-emitted numerics in any sub-track |
| I-S2 (Source + as-of) | UPHELD | every architectural claim in this plan cites file:line; observation file cites M-S342-1 + project-owner directive |
| I-S22 (Data lineage) | UPHELD | telemetry-coverage maintained; `.severity-state.tsv` schema EXTENDED (back-compat) not replaced |
| I-S33 (Self-aware agent invariant) | UPHELD | escalation friction-reduction IS the substrate for I-S33 autonomy; D1-D4 fix protects it |
| I-S35 (Research-aid framing) | N/A | no thesis-output paths touched |
| D-060 commit-policy | UPHELD | sandwich-dev commits own work; main commits architect's plan output; 0 push |
| D-062 atomic-write-doctrine | UPHELD | DD-11 mandates atomic write for .pending-queue.tsv updates (tmp + mv -f + trap EXIT) |
| D-064 path-safety contract | UPHELD | DD-12 mandates 5-invariant safety for archive move paths |

## § D. Sub-track decomposition

Order optimized to minimize blast radius and enable incremental commits:
1. **D1 first** (severity-classifier reclass — single-file, additive col6, back-compat shim handles legacy rows)
2. **D2 second** (escalation-engine routing change — depends on D1 col6 being present)
3. **D3 third** (NEW pending-queue-escalator.sh — depends on D2 writing queue rows)
4. **D4 fourth** (block-control.sh ack extension — independent of D1-D3; can run parallel)
5. **D5 fifth** (migration shim — explicit comment in escalation-engine; pairs with D2)
6. **D6 sixth** (settings.json wire-up — must happen AFTER D3 hook exists to avoid broken Stop chain)
7. **D7 last** (12-15 fire-tests + Telegram smoke + observation file)

Each sub-track is independently committable per Karpathy P3.

---

### D1. severity-classifier.sh — reclassify 5 CRITICAL triggers to PENDING + add col6 `block_tier`

**Anomaly target**: observation § Mapping table rows 1-5 (auto-reboot stale-checkpoint, charter-violation-detected, ghost-greening-confirmed, Q&A age ≥96h, PROPOSED expired). All currently CRITICAL→BLOCK; all should be PENDING→queue.

**Files**:
- `scripts/hooks/severity-classifier.sh` (~30 LOC change)
- `scripts/hooks/firing-tests/severity-classifier-fire-test.sh` (extend with 3 new TCs)

**Concrete edits** (sandwich-dev MUST re-read severity-classifier.sh end-to-end before editing per VBW):

1. **Header (line 46) — schema doc**:
   - Add column 6 `block_tier` to the printf header line at line 46:
     ```
     printf '# columns: severity\\tartifact_path\\tage_hours\\tnext_action\\tclassified_at\\tblock_tier\n'
     printf '# block_tier: HARD | PENDING | SOFT  (NEW S346 — drives escalation-engine routing per ADR D-068)\n'
     ```

2. **emit_row helper (line 59-62) — extend signature**:
   - Change function signature to accept 5th argument `block_tier` (default SOFT for back-compat with any callers that don't pass it):
     ```bash
     emit_row() {
       local sev="$1" path="$2" age="$3" action="$4" tier="${5:-SOFT}"
       printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$sev" "$path" "$age" "$action" "$TS" "$tier" >> "$TMP"
     }
     ```

3. **Layer 1 (line 70-80) — 3 CRIT_MARKERS emit PENDING**:
   - Change `emit_row "CRITICAL" "$rel" "$age" "BLOCK"` to `emit_row "CRITICAL" "$rel" "$age" "BLOCK-PENDING" "PENDING"`
   - Rationale: keep severity=CRITICAL for telemetry continuity (Layer 4 mistake-log scan still grep-matches "critical"); only `block_tier=PENDING` drives the action change. action="BLOCK-PENDING" is the new mnemonic for "would-have-blocked-but-routed-to-queue" — preserves audit clarity vs ambiguous "BLOCK"

4. **Layer 2 (line 94-95) — Q&A age ≥96h emit PENDING**:
   - Change `emit_row "CRITICAL" "$rel" "$age" "BLOCK"` to `emit_row "CRITICAL" "$rel" "$age" "BLOCK-PENDING" "PENDING"`

5. **Layer 3 (line 137-142) — PROPOSED expired cool-down emit PENDING when sev_if_expired=HIGH**:
   - Insert new logic: if `sev_if_expired == "HIGH"` AND `level=CHARTER` → tier=PENDING; else tier=SOFT
   - Concrete edit: change `emit_row "$sev_if_expired" "$rel" "$age" "$action"` to:
     ```bash
     tier="SOFT"
     [ "$sev_if_expired" = "HIGH" ] && tier="PENDING"
     emit_row "$sev_if_expired" "$rel" "$age" "$action" "$tier"
     ```

6. **Layer 4 (line 157-158) — mistake-log critical/high emit PENDING for critical**:
   - Mistake-log CRITICAL → `emit_row "CRITICAL" "agent-workspace/memory/mistake-log.md" "0" "BLOCK-PENDING" "PENDING"` (PENDING because mistake-log scan is informational; user already aware via log)
   - Mistake-log HIGH → `emit_row "HIGH" "..." "0" "ESCALATE-ASKUSERQUESTION" "SOFT"` (unchanged behavior — existing escalation-engine HIGH path stays as-is)

7. **Layer 5 (line 201-218) — notifications: NO change to tier (all stay SOFT)**:
   - All notification severity emissions stay tier=SOFT (default per emit_row); existing behavior preserved
   - Rationale: notifications already route to digest/escalate; not the source of false-blocks per observation TL;DR

8. **HARD-tier placeholder comment block** (insert AFTER Layer 1 around line 81):
   ```bash
   # === HARD-tier reservation (NEW S346 per ADR D-068) ===
   # severity-classifier emits NO HARD-tier rows in the current 5-trigger taxonomy
   # (per Q-RD3 ratification — HARD stays DISTRIBUTED across destructive-command-guard.sh
   # PreToolUse + project-integrity-watchdog.sh Stop). This comment block reserves the
   # tier-emission path; future severity-classifier callers MAY emit HARD by passing
   # "HARD" as the 5th arg to emit_row. escalation-engine.sh handles HARD identically
   # to old-school CRITICAL → .autonomous-BLOCKED flag + immediate Telegram.
   ```

**Verification at S346 IMPL** (sandwich-dev MUST):
- Manually trigger each of the 5 reclassified scenarios via temp test fixtures:
  - `touch agent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint` → run severity-classifier → grep state.tsv for `PENDING` (col6) → cleanup fixture
  - Same for `.charter-violation-detected` + `.ghost-greening-confirmed`
  - Create Q&A bundle with mtime 100h old → grep PENDING + col6
  - Create PROPOSED CHARTER decision with mtime 25h old → grep PENDING + col6
- Confirm `.severity-state.tsv` ALL rows have 6 cols (no schema corruption)
- Confirm legacy CRITICAL rows (if any survive from pre-D1 state) read OK by D2 escalation-engine (back-compat shim handles missing col6 — see D5)

**Companion firing-test**: extend `scripts/hooks/firing-tests/severity-classifier-fire-test.sh` (if it exists; if NOT, create) with:
- TC-D1-1: stale-checkpoint marker present → emit row has `block_tier=PENDING` (col6 == "PENDING")
- TC-D1-2: charter-violation-detected marker present → emit row has block_tier=PENDING
- TC-D1-3: ghost-greening-confirmed marker present → emit row has block_tier=PENDING
- TC-D1-4: Q&A bundle age 100h → row has block_tier=PENDING
- TC-D1-5: PROPOSED CHARTER decision age 25h → row has block_tier=PENDING
- TC-D1-6: notification with level=WARN → row has block_tier=SOFT (default; tier column present)
- TC-D1-7: synthetic HARD emission via direct emit_row "CRITICAL" "..." "0" "BLOCK" "HARD" call from injected test stub → row has block_tier=HARD (proves reservation path)

LOC budget: ~30 LOC change in severity-classifier.sh + ~70 LOC fire-test extension.

---

### D2. escalation-engine.sh — routing change (HARD→flag, PENDING→queue, SOFT→unchanged)

**Anomaly target**: observation § Implementation step 2; current behavior writes `.autonomous-BLOCKED` for ANY CRITICAL row; new behavior writes flag ONLY for HARD tier; PENDING rows go to NEW `.pending-queue.tsv`.

**Files**:
- `scripts/hooks/escalation-engine.sh` (~25 LOC change + migration shim)
- `scripts/hooks/firing-tests/escalation-engine-fire-test.sh` (extend with 4 new TCs covering 3-tier routing)

**Concrete edits**:

1. **CRIT_ROWS collection (line 68) — split by block_tier**:
   - Current: `CRIT_ROWS=$(grep "^CRITICAL"$'\t' "$STATE_FILE" 2>/dev/null || true)`
   - Change to (cooperate with migration shim per D5):
     ```bash
     CRIT_ROWS=$(grep "^CRITICAL"$'\t' "$STATE_FILE" 2>/dev/null || true)
     # Split CRIT_ROWS by block_tier (col6, default PENDING per D5 migration shim window)
     HARD_ROWS=$(printf '%s\n' "$CRIT_ROWS" | awk -F'\t' '$6=="HARD" {print}' 2>/dev/null || true)
     PENDING_ROWS=$(printf '%s\n' "$CRIT_ROWS" | awk -F'\t' '$6=="PENDING" || $6=="" {print}' 2>/dev/null || true)
     # Note: $6=="" branch catches legacy rows during 30-day migration shim window (D5)
     # After 2026-06-15 (30 days post-deploy), the $6=="" clause SHOULD be removed; comment with removal date
     HARD_N=$([ -z "$HARD_ROWS" ] && echo 0 || printf '%s\n' "$HARD_ROWS" | wc -l | tr -d '[:space:]')
     PENDING_N=$([ -z "$PENDING_ROWS" ] && echo 0 || printf '%s\n' "$PENDING_ROWS" | wc -l | tr -d '[:space:]')
     ```

2. **Replace CRIT_N usage at line 89-107 — branch HARD vs PENDING**:
   - Current single block writes `.autonomous-BLOCKED` for any CRIT_N > 0
   - New structure: HARD block writes flag (existing logic, just keyed off HARD_N); PENDING block writes pending-queue rows
   - Concrete edit:
     ```bash
     # === HARD handling — write block flag (unchanged from legacy CRITICAL logic) ===
     # Suppressed while .block-grace is active (a human just cleared the gate)
     if [ "$HARD_N" -gt 0 ]; then
       if [ ! -f "$BLOCK_FLAG" ] && [ "$GRACE_ACTIVE" -eq 0 ]; then
         {
           printf 'BLOCKED at %s by escalation-engine.sh (event=%s tier=HARD)\n' "$TS" "$EVENT"
           printf 'HARD_COUNT=%s\n' "$HARD_N"
           printf 'Affected artifacts:\n'
           printf '%s\n' "$HARD_ROWS" | awk -F'\t' '{printf "  - %s (age=%sh, next=%s)\n", $2, $3, $4}'
           printf '\nTO RESUME (simplest first):\n'
           # ... (existing 5-line resume instructions unchanged)
         } > "$BLOCK_FLAG"
         echo "escalation-engine: $HARD_N HARD items detected; .autonomous-BLOCKED flag written" >&2
       elif [ "$GRACE_ACTIVE" -eq 1 ]; then
         printf '[%s] escalation-engine: %s HARD but .block-grace active — auto-raise suppressed\n' "$TS" "$HARD_N" >> "$LOG"
       fi
     fi

     # === PENDING handling — append to .pending-queue.tsv with escalate_at = now + 6h ===
     # Per ADR D-068; agent continues working; pending-queue-escalator.sh handles 6h Telegram + 24h auto-archive
     if [ "$PENDING_N" -gt 0 ]; then
       PENDING_QUEUE="$PROJECT_DIR/human-workspace/notifications/.pending-queue.tsv"
       mkdir -p "$(dirname "$PENDING_QUEUE")" 2>/dev/null || true
       ESCALATE_EPOCH=$(( $(date +%s 2>/dev/null || echo 0) + 21600 ))  # +6h
       # Ensure header exists (idempotent)
       if [ ! -f "$PENDING_QUEUE" ]; then
         {
           printf '# .pending-queue.tsv — generated by escalation-engine.sh per ADR D-068 (S346)\n'
           printf '# columns: pending_id\tblock_tier\tseverity\tartifact_path\tdetected_at\tescalate_at\ttelegram_pushed\tarchived_at\tresolve_reason\n'
         } > "$PENDING_QUEUE"
       fi
       printf '%s\n' "$PENDING_ROWS" | while IFS=$'\t' read -r sev path age action ts tier _; do
         [ -z "$sev" ] && continue
         # Skip rows already in queue (idempotent — check by artifact_path basename)
         SLUG="$(basename "$path" 2>/dev/null | tr -dc 'a-zA-Z0-9-_' | head -c 40 || echo unknown)"
         PENDING_ID="${SLUG}-$(date +%s 2>/dev/null || echo 0)"
         if ! grep -F -q $'\t'"$path"$'\t' "$PENDING_QUEUE" 2>/dev/null; then
           printf '%s\t%s\t%s\t%s\t%s\t%s\tfalse\t-\t-\n' "$PENDING_ID" "PENDING" "$sev" "$path" "$TS" "$ESCALATE_EPOCH" >> "$PENDING_QUEUE"
         fi
       done
       printf '[%s] escalation-engine: %s PENDING items appended to .pending-queue.tsv\n' "$TS" "$PENDING_N" >> "$LOG"
     fi
     ```

3. **UserPromptSubmit injection at line 161-168 — PENDING is silent**:
   - Per DD-10 (PENDING does NOT trigger UPS escalation): change line 162 from `if [ "$CRIT_N" -gt 0 ]; then ...` to `if [ "$HARD_N" -gt 0 ]; then ...`
   - PENDING rows DO NOT inject system-reminder on user prompts; only HARD does (per DD-10 + observation Mapping table)
   - Concrete edit:
     ```bash
     # === UserPromptSubmit cadence: inject additionalContext via JSON stdout ===
     # PENDING rows are SILENT on UPS per ADR D-068 + DD-10 (queue handles escalation; UPS noise just for HARD)
     if [ "$EVENT" = "UserPromptSubmit" ]; then
       if [ "$HARD_N" -gt 0 ]; then
         printf 'SEVERITY-ESCALATION HARD: %d item(s) require human resolution. .autonomous-BLOCKED flag is ACTIVE...' "$HARD_N" "$BLOCK_FLAG"
       elif [ "$HIGH_QA_N" -gt 0 ]; then
         # ... (unchanged HIGH Q&A injection)
       elif [ "$HIGH_N" -gt 0 ]; then
         # ... (unchanged HIGH notification injection)
       fi
       # NOTE: PENDING_N intentionally NOT mentioned here per DD-10
     fi
     ```

4. **Telegram push at line 172-177 — HARD only immediate; PENDING deferred to D3 escalator**:
   - Current: pushes for any CRIT_N or HIGH_N > 0
   - Change to:
     ```bash
     # HARD: immediate Telegram push (no 6h grace — this is the "truly stop now" tier)
     # PENDING: NOT pushed here; pending-queue-escalator.sh handles 6h-delayed push
     if [ -x "$TELEGRAM_HOOK" ] && { [ "$HARD_N" -gt 0 ] || [ "$HIGH_N" -gt 0 ]; }; then
       TG_SEV="HIGH"
       [ "$HARD_N" -gt 0 ] && TG_SEV="CRITICAL"
       TG_MSG="StockForge $EVENT: $HARD_N HARD + $HIGH_N HIGH items pending. See urgent.md."
       bash "$TELEGRAM_HOOK" "$TG_SEV" "$TG_MSG" 2>/dev/null || true
     fi
     ```

5. **Cleanup unused CRIT_N at line 72** — left in place; still used by Layer 4 telemetry. Just NOT used for action routing anymore (which is now HARD_N / PENDING_N driven).

**Verification at S346 IMPL**:
- Manually emit each tier via stub `.severity-state.tsv` file:
  - All-HARD rows → `.autonomous-BLOCKED` written; Telegram fires immediately
  - All-PENDING rows → `.pending-queue.tsv` populated; NO `.autonomous-BLOCKED` written; NO Telegram fires (deferred to D3 escalator)
  - All-SOFT rows → existing log-only behavior (unchanged)
  - Mixed HARD+PENDING → flag written for HARD; queue populated for PENDING; both Telegrams correct
- Confirm idempotency: same `.severity-state.tsv` re-run does NOT duplicate `.pending-queue.tsv` rows (grep -F idempotency check at line 18 above)

**Companion firing-test**: extend `scripts/hooks/firing-tests/escalation-engine-fire-test.sh` with:
- TC-D2-1: state.tsv row tier=HARD → `.autonomous-BLOCKED` written
- TC-D2-2: state.tsv row tier=PENDING → `.pending-queue.tsv` populated; NO block flag
- TC-D2-3: state.tsv row tier=PENDING → 2nd run does NOT duplicate queue row (idempotency)
- TC-D2-4: state.tsv mixed HARD+PENDING → both paths fire correctly

LOC budget: ~50 LOC change in escalation-engine.sh + ~80 LOC fire-test extension.

---

### D3. NEW scripts/hooks/pending-queue-escalator.sh (Stop cadence; ~80-120 LOC)

**Anomaly target**: observation § Implementation step 3 — NEW hook reading `.pending-queue.tsv`; 6h Telegram fire; 24h auto-archive; self-resolution check when artifact is GONE.

**Files**:
- `scripts/hooks/pending-queue-escalator.sh` (NEW, ~80-120 LOC)
- `scripts/hooks/firing-tests/pending-queue-escalator-fire-test.sh` (NEW, ~150 LOC for ~6 TCs)

**Concrete structure** (mirror pattern of `scripts/hooks/urgent-md-rotate.sh` + `scripts/hooks/severity-classifier.sh` for atomic write):

```bash
#!/usr/bin/env bash
# pending-queue-escalator.sh — Stop cadence (NEW S346 per ADR D-068)
#
# Reads human-workspace/notifications/.pending-queue.tsv (produced by escalation-engine.sh
# PENDING-tier routing per ADR D-068) and acts per row age + state:
#   - escalate_at <= now AND telegram_pushed=false → fire Telegram + set telegram_pushed=true
#   - row age > 24h AND no ack received → auto-archive to human-workspace/notifications/archive/
#   - underlying artifact_path GONE (deleted/resolved) → mark resolve_reason="artifact-gone" + archive
#
# Bash + POSIX only per L-S11-1. Best-effort: never fails Stop chain on its own errors (RC=0).
# SPAWN-CONTEXT: positional-arg (event optional via $1; reads .pending-queue.tsv either way)

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PENDING_QUEUE="$PROJECT_DIR/human-workspace/notifications/.pending-queue.tsv"
ARCHIVE_DIR="$PROJECT_DIR/human-workspace/notifications/archive"
LOG="$PROJECT_DIR/agent-workspace/memory/.pending-queue-escalator.log"
TELEGRAM_HOOK="$PROJECT_DIR/scripts/hooks/telegram-push.sh"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"
NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"
case "$NOW_EPOCH" in ''|*[!0-9]*) NOW_EPOCH=0 ;; esac

mkdir -p "$(dirname "$LOG")" "$ARCHIVE_DIR" 2>/dev/null || true

# No queue file → silent exit
[ -f "$PENDING_QUEUE" ] || exit 0

# Atomic rewrite per D-062
TMP="$PENDING_QUEUE.tmp.$$"
trap 'rm -f "$TMP" 2>/dev/null || true' EXIT

# Preserve header lines (#)
grep '^#' "$PENDING_QUEUE" 2>/dev/null > "$TMP" || true

ARCHIVED=0
TELEGRAM_FIRED=0
RESOLVED=0

# Read non-header rows
grep -v '^#' "$PENDING_QUEUE" 2>/dev/null | while IFS=$'\t' read -r pending_id block_tier severity artifact_path detected_at escalate_at telegram_pushed archived_at resolve_reason; do
  [ -z "$pending_id" ] && continue
  case "$pending_id" in '#'*) continue ;; esac

  # Age in seconds since detected_at (parse ISO 8601 via date -d; bash gnu-coreutils)
  DETECTED_EPOCH=$(date -d "$detected_at" +%s 2>/dev/null || echo "$NOW_EPOCH")
  case "$DETECTED_EPOCH" in ''|*[!0-9]*) DETECTED_EPOCH=$NOW_EPOCH ;; esac
  AGE_SECONDS=$(( NOW_EPOCH - DETECTED_EPOCH ))

  # === Self-resolution check: artifact GONE? ===
  if [ -n "$artifact_path" ] && [ ! -e "$PROJECT_DIR/$artifact_path" ]; then
    # Artifact resolved/deleted → archive with resolve_reason="artifact-gone"
    SLUG=$(basename "$artifact_path" 2>/dev/null | tr -dc 'a-zA-Z0-9-_' | head -c 40 || echo "unknown")
    ARCHIVE_FILE="$ARCHIVE_DIR/$(date +%Y%m%d-%H%M%S 2>/dev/null)-PENDING-${SLUG}.md"
    {
      printf '# PENDING resolved (artifact-gone) %s\n' "$TS"
      printf 'pending_id: %s\n' "$pending_id"
      printf 'block_tier: %s\n' "$block_tier"
      printf 'severity: %s\n' "$severity"
      printf 'artifact_path: %s\n' "$artifact_path"
      printf 'detected_at: %s\n' "$detected_at"
      printf 'archived_at: %s\n' "$TS"
      printf 'resolve_reason: artifact-gone\n'
    } > "$ARCHIVE_FILE" 2>/dev/null || true
    RESOLVED=$((RESOLVED+1))
    continue  # Skip writing to new TMP (effectively delete from queue)
  fi

  # === Auto-archive: age > 24h AND telegram_pushed=true AND no ack received ===
  if [ "$AGE_SECONDS" -gt 86400 ] && [ "$telegram_pushed" = "true" ]; then
    SLUG=$(basename "$artifact_path" 2>/dev/null | tr -dc 'a-zA-Z0-9-_' | head -c 40 || echo "unknown")
    ARCHIVE_FILE="$ARCHIVE_DIR/$(date +%Y%m%d-%H%M%S 2>/dev/null)-PENDING-${SLUG}.md"
    {
      printf '# PENDING auto-archived (24h-no-action) %s\n' "$TS"
      printf 'pending_id: %s\n' "$pending_id"
      printf 'block_tier: %s\n' "$block_tier"
      printf 'severity: %s\n' "$severity"
      printf 'artifact_path: %s\n' "$artifact_path"
      printf 'detected_at: %s\n' "$detected_at"
      printf 'archived_at: %s\n' "$TS"
      printf 'resolve_reason: auto-archive-24h-no-action\n'
    } > "$ARCHIVE_FILE" 2>/dev/null || true
    ARCHIVED=$((ARCHIVED+1))
    continue  # Skip writing to new TMP (remove from queue)
  fi

  # === Telegram escalation: escalate_at <= now AND telegram_pushed=false ===
  if [ "$telegram_pushed" = "false" ] && [ "$NOW_EPOCH" -ge "$escalate_at" ]; then
    if [ -x "$TELEGRAM_HOOK" ]; then
      SLUG=$(basename "$artifact_path" 2>/dev/null)
      AGE_HOURS=$(( AGE_SECONDS / 3600 ))
      TG_MSG=$(printf '[StockForge PENDING] severity=%s artifact=%s\nDetected %sh ago at %s. No human action yet — escalating.\nSuggested actions: (a) review marker + decide if resolved (b) reply "ack %s" to dismiss (c) reply "approved" to escalate to HARD.\nArchive in %sh if no action.' \
        "$severity" "$SLUG" "$AGE_HOURS" "$detected_at" "$SLUG" "$(( 24 - AGE_HOURS ))")
      bash "$TELEGRAM_HOOK" "HIGH" "$TG_MSG" 2>/dev/null || true
      telegram_pushed="true"
      TELEGRAM_FIRED=$((TELEGRAM_FIRED+1))
    fi
  fi

  # Keep row in queue (write to TMP)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$pending_id" "$block_tier" "$severity" "$artifact_path" "$detected_at" \
    "$escalate_at" "$telegram_pushed" "$archived_at" "$resolve_reason" >> "$TMP"
done

# Atomic install
mv -f "$TMP" "$PENDING_QUEUE" 2>/dev/null || { rm -f "$TMP"; exit 0; }

printf '[%s] pending-queue-escalator: archived=%s telegram_fired=%s resolved=%s\n' \
  "$TS" "$ARCHIVED" "$TELEGRAM_FIRED" "$RESOLVED" >> "$LOG"

exit 0
```

**Note on while-subshell variable scoping** (Bash gotcha — see `urgent-md-rotate.sh` for precedent): the `while IFS=... read ... do ... done` inside a pipe runs in a subshell; ARCHIVED/TELEGRAM_FIRED/RESOLVED counters won't propagate to parent. Per architect's preferred-pattern audit: either (a) use `while ... < <(grep ...)` process substitution (preferred — keeps counters in parent shell) or (b) write counts to temp files. Recommend (a) for sandwich-dev. Concrete change: replace `grep -v '^#' "$PENDING_QUEUE" 2>/dev/null | while ...` with `while IFS=$'\t' read ... done < <(grep -v '^#' "$PENDING_QUEUE" 2>/dev/null)`.

**Verification at S346 IMPL**:
- Stub `.pending-queue.tsv` with 4 rows representing:
  - Row 1: escalate_at in future, telegram_pushed=false → expect no Telegram fire; row preserved
  - Row 2: escalate_at in past, telegram_pushed=false → expect Telegram fire; telegram_pushed updated to true
  - Row 3: detected_at 25h ago, telegram_pushed=true → expect auto-archive; row removed from queue
  - Row 4: artifact_path points to NON-EXISTENT file → expect resolve archive; row removed
- Confirm `.pending-queue.tsv` header preserved + correct rows retained
- Confirm `notifications/archive/` populated with 2 new archive files (rows 3+4)
- Confirm log line emitted: `archived=1 telegram_fired=1 resolved=1`

**Companion firing-test**: NEW `scripts/hooks/firing-tests/pending-queue-escalator-fire-test.sh` with 6 TCs:
- TC-D3-1: empty queue file → silent RC=0; no archive writes
- TC-D3-2: escalate_at in future → no Telegram fire (DRY_RUN export); row preserved
- TC-D3-3: escalate_at in past + telegram_pushed=false → Telegram fires (DRY_RUN log entry); telegram_pushed updated
- TC-D3-4: age > 24h + telegram_pushed=true → auto-archive; queue row removed; archive file created
- TC-D3-5: artifact_path points to NON-EXISTENT file → resolve-archive (regardless of age); queue row removed
- TC-D3-6: idempotency — running TC-D3-3 twice → Telegram fires only ONCE (telegram_pushed=true after first run)

LOC budget: ~100 LOC new hook + ~150 LOC fire-test.

---

### D4. block-control.sh — add `ack <slug>` subcommand + check-prompt regex extension

**Anomaly target**: observation § Implementation step 4 — `ack <slug>` keyword for user to dismiss a PENDING row via prompt; multi-ack per prompt supported.

**Files**:
- `scripts/hooks/block-control.sh` (~30 LOC change + new subcommand + regex extension)
- `scripts/hooks/firing-tests/block-control-fire-test.sh` (extend with 3 new TCs)

**Concrete edits**:

1. **New subcommand `cmd_ack` (insert before dispatch case at line 226)**:
   ```bash
   # ---------------------------------------------------------------------------
   # ack <slug> [<slug2> ...]
   # ---------------------------------------------------------------------------
   cmd_ack() {
     local PENDING_QUEUE="$PROJECT_DIR/human-workspace/notifications/.pending-queue.tsv"
     local ARCHIVE_DIR="$PROJECT_DIR/human-workspace/notifications/archive"
     local slug result_count=0
     [ -f "$PENDING_QUEUE" ] || { printf 'BLOCK-CONTROL: no .pending-queue.tsv to ack against\n'; return 0; }
     mkdir -p "$ARCHIVE_DIR" 2>/dev/null || true

     for slug in "$@"; do
       [ -z "$slug" ] && continue
       # Validate slug — alphanumeric + dash + underscore only (path-safety per D-064)
       case "$slug" in
         *[!a-zA-Z0-9_-]*) printf 'BLOCK-CONTROL: invalid slug "%s" (must match [a-zA-Z0-9_-])\n' "$slug"; continue ;;
       esac

       # Match by basename-derived slug (case-sensitive)
       # Find the LATEST matching row (per AQ-6 disambiguation rule — multiple PENDING rows with same slug)
       local match_count
       match_count=$(grep -c $'\t'"$slug" "$PENDING_QUEUE" 2>/dev/null || echo 0)
       case "$match_count" in ''|*[!0-9]*) match_count=0 ;; esac

       if [ "$match_count" -eq 0 ]; then
         printf 'BLOCK-CONTROL: ack %s — no matching PENDING row (already resolved?)\n' "$slug"
         continue
       fi

       # Archive matched row(s) and remove from queue
       # Pattern: match basename in artifact_path (col4) OR exact pending_id (col1)
       local TMP="$PENDING_QUEUE.tmp.$$"
       trap 'rm -f "$TMP" 2>/dev/null || true' EXIT
       grep '^#' "$PENDING_QUEUE" > "$TMP" 2>/dev/null || true
       while IFS=$'\t' read -r pending_id block_tier severity artifact_path detected_at escalate_at telegram_pushed archived_at resolve_reason; do
         [ -z "$pending_id" ] && continue
         case "$pending_id" in '#'*) continue ;; esac
         # Check if this row matches the slug
         local row_slug
         row_slug=$(basename "$artifact_path" 2>/dev/null | tr -dc 'a-zA-Z0-9-_' | head -c 40 || echo "")
         if [ "$row_slug" = "$slug" ] || [ "$pending_id" = "$slug" ]; then
           # Archive
           local ARCHIVE_FILE="$ARCHIVE_DIR/$(date +%Y%m%d-%H%M%S 2>/dev/null)-PENDING-${slug}.md"
           {
             printf '# PENDING resolved (ack-by-user-prompt) %s\n' "$TS"
             printf 'pending_id: %s\n' "$pending_id"
             printf 'block_tier: %s\n' "$block_tier"
             printf 'severity: %s\n' "$severity"
             printf 'artifact_path: %s\n' "$artifact_path"
             printf 'detected_at: %s\n' "$detected_at"
             printf 'archived_at: %s\n' "$TS"
             printf 'resolve_reason: ack-by-user-prompt\n'
           } > "$ARCHIVE_FILE" 2>/dev/null || true
           result_count=$((result_count+1))
           continue  # Skip writing to TMP (effectively delete)
         fi
         # Keep row
         printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
           "$pending_id" "$block_tier" "$severity" "$artifact_path" "$detected_at" \
           "$escalate_at" "$telegram_pushed" "$archived_at" "$resolve_reason" >> "$TMP"
       done < <(grep -v '^#' "$PENDING_QUEUE" 2>/dev/null)
       mv -f "$TMP" "$PENDING_QUEUE" 2>/dev/null || { rm -f "$TMP"; }
     done

     log "ack subcommand resolved $result_count row(s)"
     printf 'BLOCK-CONTROL: ack resolved %s PENDING row(s)\n' "$result_count"
     return 0
   }
   ```

2. **Dispatch case extension (line 226)**:
   - Add `ack` case:
     ```bash
     ack)
       shift 2>/dev/null || true
       cmd_ack "$@"
       ;;
     ```

3. **check-prompt regex extension (line 207)**:
   - After existing approval-keyword regex match, add ack-slug detection:
     ```bash
     # === ack <slug> detection (NEW S346 per ADR D-068) ===
     # Match ^ack +<slug>$ on any line in prompt; multi-ack per prompt supported via grep -oE | while read
     ACK_RE='(^|\n)ack +([a-zA-Z0-9_-]+)([^a-zA-Z0-9_-]|$)'
     if printf '%s' "$user_prompt" | grep -qE "$ACK_RE" 2>/dev/null; then
       # Extract all slugs after "ack " keyword
       ACK_SLUGS=$(printf '%s' "$user_prompt" | grep -oE "ack +[a-zA-Z0-9_-]+" 2>/dev/null | awk '{print $2}' | tr '\n' ' ')
       if [ -n "$ACK_SLUGS" ]; then
         # shellcheck disable=SC2086
         ACK_RESULT=$(cmd_ack $ACK_SLUGS 2>&1 || true)
         log "check-prompt: ack-slug(s) detected: $ACK_SLUGS"
         printf 'BLOCK-CONTROL: ack keyword(s) detected — PENDING row(s) processed.\n%s\n' "$ACK_RESULT"
         # NOTE: ack does NOT clear .autonomous-BLOCKED (that's HARD-tier only via approval keyword path above)
       fi
     fi
     ```
   - Place this AFTER existing approval-keyword `cmd_clear` invocation but inside the same check-prompt path (do NOT short-circuit; both can fire in same prompt — user might type "approved, ack stale-checkpoint")

4. **Usage string at line 244** — add `ack <slug>` to the usage line:
   ```bash
   printf 'usage: block-control.sh {raise <severity> <slug> -- <reason> | clear [actor] [reason] | status | check-prompt | ack <slug> [<slug2> ...]}\n' >&2
   ```

**Verification at S346 IMPL**:
- Stub `.pending-queue.tsv` with 3 PENDING rows (slug=stale-checkpoint, slug=charter-violation, slug=ghost-greening)
- Run `bash scripts/hooks/block-control.sh ack stale-checkpoint` → confirm row removed + archive file created + remaining 2 rows preserved
- Run `echo '{"prompt":"ack charter-violation"}' | bash scripts/hooks/block-control.sh check-prompt` → confirm row removed via check-prompt path
- Run `echo '{"prompt":"ok thanks ack ghost-greening"}' | bash ...` → confirm match (whitespace-anchored not line-anchored)
- Run `echo '{"prompt":"please ack two: ack stale1 ack stale2"}' | bash ...` → confirm BOTH slugs matched + processed
- Run `echo '{"prompt":"hackathon project review"}' | bash ...` → confirm NO false-match (regex strict `^ack +<slug>` with whitespace anchor)

**Companion firing-test**: extend `scripts/hooks/firing-tests/block-control-fire-test.sh` with:
- TC-D4-1: `ack <slug>` subcommand archives matching row; removes from queue
- TC-D4-2: `ack <invalid-slug>` invalid chars rejected with error message
- TC-D4-3: `ack <no-match-slug>` reports "no matching PENDING row"
- TC-D4-4: check-prompt with "ack stale-checkpoint" auto-runs ack subcommand
- TC-D4-5: check-prompt with "hackathon project" does NOT false-match (strict `^ack +` regex)
- TC-D4-6: check-prompt with "ack X ack Y" matches BOTH slugs (multi-ack)

LOC budget: ~80 LOC change in block-control.sh + ~90 LOC fire-test extension.

---

### D5. Migration shim in escalation-engine.sh (30-day window for legacy CRITICAL rows without col6)

**Anomaly target**: backward-compatibility with existing `.severity-state.tsv` rows produced before D1 ships (rows have 5 cols, no `block_tier`).

**Files**:
- `scripts/hooks/escalation-engine.sh` (already touched by D2; just add CLEAR comment block + dated removal target)

**Concrete edit** (insert ABOVE the CRIT_ROWS split at D2 step 1):

```bash
# === MIGRATION SHIM — S346 D5 ===
# Legacy .severity-state.tsv rows (pre-D1) have 5 cols (no block_tier column).
# Per D5 (30-day window): treat legacy CRITICAL rows as PENDING tier (back-compat default).
# This preserves the LESS-aggressive behavior (no flag write) during rollout.
# REMOVAL TARGET: 2026-06-15 (30 days post-deploy of S346). After removal, $6=="" branch
# in the awk split below should be deleted, and any remaining 5-col rows will be IGNORED
# by the tier-split logic (silent fail-safe).
# Concrete removal step (sandwich-dev or follow-up architect): in the awk at $6=="PENDING" || $6==""
# delete the `|| $6==""` clause + this comment block + the test cases TC-D2-back-compat below.
# Tracking: queue this in `agent-workspace/memory/checkpoints/latest.md § PROMOTED-CANDIDATES`
# at the same commit as S346 close-bookkeeping with target removal session = S380-ish (30d).
```

**Verification at S346 IMPL** (sandwich-dev MUST):
- Manually craft a 5-col legacy `.severity-state.tsv` row (no col6); run escalation-engine; confirm row treated as PENDING (queue populated, no flag written)
- After D5 (30 days), this test case becomes obsolete and should be removed

**Companion firing-test**: extend D2's `escalation-engine-fire-test.sh` with:
- TC-D5-1: 5-col legacy CRITICAL row → treated as PENDING (queue populated, no flag written)
- TC-D5-2: 6-col CRITICAL+HARD row → flag written (proves shim doesn't over-suppress HARD)

LOC budget: ~15 LOC comment block + ~25 LOC test cases.

---

### D6. .claude/settings.json — wire-up pending-queue-escalator.sh in Stop chain

**Anomaly target**: NEW D3 hook needs Stop-chain registration; ordering MUST be AFTER `escalation-engine.sh` (which populates the queue) per observation § Settings.

**Files**:
- `.claude/settings.json` (1-line insert in Stop chain)

**Concrete edit**:
- Locate the existing `escalation-engine.sh` invocation at line 446-449 of `.claude/settings.json`:
  ```json
  {
    "type": "command",
    "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/escalation-engine.sh\" Stop"
  },
  ```
- Insert IMMEDIATELY AFTER this entry (so escalation-engine populates queue, THEN escalator processes it within same Stop cycle):
  ```json
  {
    "type": "command",
    "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/pending-queue-escalator.sh\" Stop"
  },
  ```
- Comma placement: existing entry already ends with `,` (followed by index-registry-renderer.sh); insertion fits cleanly

**SessionStart cadence**: per DD-AQ-11 (NO — Stop only). Do NOT wire pending-queue-escalator.sh on SessionStart; per architect rationale: SessionStart reads queue for display via continue-injector if needed, but that's a separate concern handled by `continue-injector.sh` (not in scope this plan).

**Verification at S346 IMPL**:
- After settings.json edit, restart Claude Code OR confirm hot-reload picks up Stop-chain change
- Trigger a Stop event → confirm pending-queue-escalator.sh log line appears in `.pending-queue-escalator.log`
- Confirm ordering: escalation-engine.sh log line precedes pending-queue-escalator.sh log line

**Companion firing-test**: no new fire-test needed (settings.json is config, not code); verification is empirical via running Stop chain

LOC budget: ~5 LOC config edit.

---

### D7. Fire-tests bundle + Telegram smoke + observation file + ADR D-068 PROPOSED

**Anomaly target**: per Charter Principle 11 (Harness must self-verify firing); per S345 brief mandatory deliverables.

**Files**:
- `scripts/hooks/firing-tests/severity-classifier-fire-test.sh` (extend per D1; +70 LOC)
- `scripts/hooks/firing-tests/escalation-engine-fire-test.sh` (extend per D2+D5; +100 LOC)
- `scripts/hooks/firing-tests/pending-queue-escalator-fire-test.sh` (NEW per D3; +150 LOC)
- `scripts/hooks/firing-tests/block-control-fire-test.sh` (extend per D4; +90 LOC)
- `agent-workspace/memory/decisions/068-block-ask-gate-3-tier-model.md` (NEW ADR PROPOSED at IMPL tier — no cool-down per IMPL-tier severity schema)
- `agent-workspace/memory/observations/sandwich-dev-S346-block-ask-gate-3-tier-impl.md` (NEW observation file per dispatch-template-recovery doctrine from S341 D7 + AP-23 promote-now)
- `agent-workspace/memory/sessions/2026-05-16-session-N.md` (NEW session log per CLAUDE.md § End)

**Concrete tasks**:

1. **Run extended fire-tests** (sandwich-dev at S346 IMPL):
   - `bash scripts/hooks/firing-tests/severity-classifier-fire-test.sh` → expect 100% PASS for all TC-D1-* added cases
   - `bash scripts/hooks/firing-tests/escalation-engine-fire-test.sh` → expect 100% PASS including new TC-D2-* + TC-D5-* (and existing TC1-TC7 unchanged-behavior preserved)
   - `bash scripts/hooks/firing-tests/pending-queue-escalator-fire-test.sh` → expect 100% PASS for all 6 new TC-D3-*
   - `bash scripts/hooks/firing-tests/block-control-fire-test.sh` → expect 100% PASS for new TC-D4-* + existing TC1-TC11 preserved
   - `bash scripts/hooks/firing-tests/run-all.sh` → expect 100% PASS aggregate (regression-check across all hooks)

2. **Telegram smoke test** (per S345 STEP 0.3 — sandwich-dev MUST execute):
   - `bash scripts/hooks/telegram-push.sh "HIGH" "[TEST S346] Block/Ask Gate 3-Tier Redesign IMPL smoke test from sandwich-dev"`
   - Capture HTTP response code + first 120 chars of Telegram API response into session log (`agent-workspace/memory/sessions/2026-05-16-session-N.md`) per BEHAVIORAL HOLD § (b) audit pattern
   - Expected: HTTP 200 with `{"ok":true,"result":{...}}` body confirming delivery to chat 891087440

3. **ADR D-068 PROPOSED** (NEW file `agent-workspace/memory/decisions/068-block-ask-gate-3-tier-model.md`):

   Per `agent-workspace/memory/decisions/_template.md` 12-field schema, content:

   ```yaml
   ---
   adr_id: 068
   title: Block/Ask-user Gate 3-Tier Model (HARD / PENDING / SOFT)
   status: PROPOSED
   level: IMPL
   cool_down_hours: 0  # IMPL-tier per severity-schema.md
   proposed_at: 2026-05-16T<TS> SEAST
   proposed_by: S346 sandwich-dev (per plan 024-S345 architect S345 + user ratification 2026-05-16 ~20:30 SEAST)
   supersedes: harness-severity-escalation-system-2026-05-14.md § residual CRITICAL=BLOCK behavior
   superseded_by: -
   ratified_at: -
   ratified_by: -
   provenance: agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md + user_prompt 20260516_01.txt § 2
   ---

   # ADR D-068 — Block/Ask-user Gate 3-Tier Model

   ## Context

   Per S342-S345 close-bookkeeping + M-S342-1 case study + project-owner directive
   (user_prompt 20260516_01.txt § 2 — "a lot of time claude code stop, need user
   intervent ... my idea ... except some especially blocking feature, that really
   need to stop and need human to intervent, then stop, otherwise, its will be
   pending, human can verify them later, and if more than 6 hours, the harness
   system trigger the telegram notification"), the existing binary CRITICAL=BLOCK
   model triggered ~1 forced user intervention per 3 autonomous turns. Empirical
   analysis (observation 2026-05-16) found NONE of the 5 current CRITICAL trigger
   types meet the "must stop now" bar — they're all soft signals user could review
   at convenience.

   ## Decision

   Introduce 3-tier `block_tier` column (col6) in `.severity-state.tsv`:

   | Tier | Action | Use case |
   |---|---|---|
   | HARD | `.autonomous-BLOCKED` flag + immediate Telegram + all tools blocked except Read/Glob/Grep + block-control.sh | Imminent destructive command (PreToolUse — destructive-command-guard.sh); confirmed mass deletion (Stop — project-integrity-watchdog.sh); unauthorized push attempt (D-060 prevention) |
   | PENDING | Append row to `.pending-queue.tsv` with `escalate_at = now + 6h`; agent continues; 6h → Telegram fires once; 24h → auto-archive to `notifications/archive/`; user can `ack <slug>` anytime | Stale-checkpoint markers; charter-violation-detected markers; ghost-greening-confirmed markers; Q&A age ≥ 96h; PROPOSED ADR expired cool-down |
   | SOFT | Existing log-only or digest behavior | All HIGH/MEDIUM/LOW from notification scans; HIGH from Q&A age ≥ 6h (legacy AskUserQuestion path preserved) |

   HARD triggers remain DISTRIBUTED across guards per Q-RD3 — each guard knows its
   own context. severity-classifier reserves the HARD-tier emission path
   (placeholder comment block) but in current 5-trigger taxonomy emits NO HARD rows.

   ## Consequences

   - Forced user interventions drop from ~1/3 turns to ~0-1/20 turns (estimated per
     observation; verify in S347 production cycle)
   - 5 trigger types reclassified CRITICAL→PENDING (severity=CRITICAL preserved for
     telemetry; block_tier=PENDING drives action)
   - Migration shim handles legacy 5-col rows for 30 days (target removal 2026-06-15)
   - M-S342-1 LOSS SURFACE drops MEDIUM → LOW (verifier fixture leak now auto-resolves
     via 24h archive without forced user intervention)

   ## Status: PROPOSED IMPL-tier (cool_down_hours=0; auto-ratifies on commit per
   severity-schema IMPL-tier rule)
   ```

4. **Sandwich-dev observation file** (NEW `agent-workspace/memory/observations/sandwich-dev-S346-block-ask-gate-3-tier-impl.md`):

   Cadence per S341 D7 dispatch-template improvement + AP-23 promote-now mandate (verifier observation already required since S339):
   - § What I did (file list + LOC counts + git diff stats)
   - § Architectural decisions (echo DD-1..DD-12 + any IMPL-tier deviations)
   - § Verification results (fire-test PASS/FAIL totals + Telegram smoke response)
   - § Risks surfaced (any NEW found during IMPL not in plan's RM1..RM12)
   - § Compliance attestation (charter / constitution / harness_priority_one / AP-1 / D-060)
   - § Handoff to verifier (5-7 verification items for S347 sandwich-verifier)

5. **Session log** per CLAUDE.md § End (NEW `agent-workspace/memory/sessions/2026-05-16-session-N.md`):
   - What happened (sub-tracks D1-D7 status)
   - Decisions made (DD-1..DD-12 echo)
   - Files touched (with LOC counts)
   - Mistakes (NEW M-S346-N entries if any; OR explicit "no mistakes this session" per session-end-checklist-linter.sh)

LOC budget: total ~360 LOC across all 5 deliverables (ADR ~80 + dev obs ~100 + session log ~70 + fire-test extensions counted in D1-D4).

---

## § E. Architecture Decisions (DD-1..DD-12)

| DD | Decision | Rationale | Alternates rejected |
|---|---|---|---|
| DD-1 | TSV col-add strategy: append `block_tier` as col6 to `.severity-state.tsv`; back-compat default SOFT for legacy rows (5-col rows) | Additive only; no breaking change; existing readers ignore unknown trailing cols | (a) Replace `severity` col (breaks Layer 4 grep); (b) New file `.block-tier.tsv` (state fragmentation; extra mv races); (c) JSON migration (over-engineering — TSV is bash-idiomatic) |
| DD-2 | `.pending-queue.tsv` schema: 9 columns `pending_id | block_tier | severity | artifact_path | detected_at | escalate_at | telegram_pushed | archived_at | resolve_reason` per observation Schema section | Self-documenting; allows row-level audit + reconstruction; aligns with severity-state.tsv tabular pattern | (a) JSON (over-engineering for bash); (b) Single line "key=value" entries (harder to grep) |
| DD-3 | `pending_id` format: `<slug>-<epoch_seconds>` (slug from `artifact_path` basename via `basename + tr -dc 'a-zA-Z0-9-_' + head -c 40`); deterministic + sortable + collision-resistant within 1 epoch second per RM7 | Mirrors L-S289-1 atomic-claim pattern; epoch suffix gives sub-second uniqueness; basename slug gives human readability for ack <slug> targeting | (a) UUID (loses readability); (b) Plain hash (loses sortability); (c) Sequential counter (state file required) |
| DD-4 | Telegram message format: multi-line UTF-8 with severity name + artifact basename + detected_at + suggested actions (no emoji per telegram-push.sh:55 ASCII-only constraint); single message per row (not batched per AQ-7) | Existing telegram-push.sh proven UTF-8 reliable post-S310; ASCII-only constraint matches platform | (a) Batched single message for ≥6 rows (defer per AQ-7 until rate-limit hit); (b) Emoji (rejected per telegram-push.sh:55 historical UTF-8 fail) |
| DD-5 | ack-keyword detection: `block-control.sh check-prompt` extended to look for `(^\|\n)ack +([a-zA-Z0-9_-]+)([^a-zA-Z0-9_-]\|$)` regex; multi-ack per prompt supported via grep -oE + for-loop | Line-start OR newline anchor prevents false-match in "hackathon" / "feedback" contexts; whitespace-anchor end allows trailing punctuation | (a) Free-text "dismiss <slug>" (verbose; user prefers terse); (b) Single-ack-per-prompt (loses utility for cleanup sessions) |
| DD-6 | Auto-archive policy: row age >24h AND `telegram_pushed=true` AND no `ack` received → mv to `notifications/archive/N-<ts>-PENDING-<slug>.md` (preserving content) per Q-RD1 ratification | User wants audit trail (not deletion); cheap disk; mirrors existing archive/ pattern (already populated with 100+ files since S100) | (a) Delete entirely (rejected per Q-RD1 user preference); (b) Move to dedicated `pending-archive/` (unnecessary fragmentation) |
| DD-7 | Self-resolution: if `artifact_path` GONE (e.g., verifier cleaned up `.charter-violation-detected`) → mark row `resolve_reason="artifact-gone"` + archive immediately (regardless of age) | Handles M-S342-1-style cases automatically; prevents perpetual queue rows for already-resolved artifacts | (a) Wait for 24h auto-archive regardless (slower closure); (b) Require explicit ack (user friction) |
| DD-8 | HARD-tier safety: for the rare case where severity-classifier WOULD emit HARD (currently 0 cases; placeholder per D1 comment block), retain immediate `.autonomous-BLOCKED` + immediate Telegram (no 6h grace) — matches existing CRITICAL behavior | HARD is the "truly stop now" tier; cannot wait 6h for active danger | None considered |
| DD-9 | Migration shim in escalation-engine.sh: for first 30 days (target removal 2026-06-15), treat `severity=CRITICAL block_tier=missing/empty` rows as PENDING (back-compat); after 2026-06-15, drop shim + remove `|| $6==""` clause from awk split | 30 days is conservative; allows any deferred Stop cycles to drain legacy rows; explicit removal date prevents indefinite shim accumulation | (a) Immediate cutover (risks orphaned legacy rows); (b) Indefinite shim (technical debt + AP-7 anti-vacuous-defer violation) |
| DD-10 | Coexistence with existing escalation-engine UserPromptSubmit cadence: PENDING rows DO NOT trigger UPS escalation (silent on prompt); only HARD does per § D2 step 3 | Per S345 brief — agent continues working on PENDING items; UPS noise reserved for HARD (truly-blocking) tier | (a) PENDING also emits UPS (defeats the entire "agent continues working" goal); (b) HIGH also emits UPS for PENDING parity (rejected — HIGH legacy Q&A AskUserQuestion path preserved) |
| DD-11 | Atomic write per D-062 for `.pending-queue.tsv` updates: tmp + mv -f + `trap EXIT cleanup` pattern; mirror `severity-classifier.sh:33-41` S341 D2 fix | D-062 binding doctrine; severity-classifier pattern proven in S341 | (a) Append-only sed (race-prone for multi-process Stop); (b) Lock file (over-engineering for single-writer Stop) |
| DD-12 | Path safety per D-064 for archive moves: basename whitelist (`tr -dc 'a-zA-Z0-9-_'`) + literal-anchor (no `..`) + no symlink-follow (default mv behavior on bash; explicit `-T` for safety if extension needed) + audit log entry | D-064 binding contract; basename sanitization prevents `slug=../../../etc/passwd` exploit | (a) Python `pathlib.resolve` (overkill for bash hook; D-064 helpers are Python but bash here can replicate via tr); (b) No sanitization (security risk) |

## § F. Sub-track summary + LOC budget

| Sub-track | Files touched | LOC delta | Fire-tests |
|---|---|---|---|
| D1 | severity-classifier.sh + severity-classifier-fire-test.sh | +30 / +70 | 7 new TCs |
| D2 | escalation-engine.sh + escalation-engine-fire-test.sh | +50 / +80 | 4 new TCs |
| D3 | pending-queue-escalator.sh (NEW) + pending-queue-escalator-fire-test.sh (NEW) | +100 / +150 | 6 TCs (NEW file) |
| D4 | block-control.sh + block-control-fire-test.sh | +80 / +90 | 6 new TCs |
| D5 | escalation-engine.sh (already in D2; comment block + 2 test cases) | +15 / +25 | 2 TCs (in D2 file) |
| D6 | .claude/settings.json | +5 | N/A (config) |
| D7 | ADR D-068 + dev obs + session log + Telegram smoke | +250 (docs) | N/A (smoke test executed) |
| **Total** | **8 code files + 4 docs** | **~530 LOC + 25 TCs** | **25 fire-test TCs** |

## § G. 5-source evidence chain (per I-S2 source citation discipline)

| Claim | Source 1 | Source 2 | Source 3 | Source 4 | Source 5 |
|---|---|---|---|---|---|
| 5 CRITICAL triggers all reclassify to PENDING | obs file § Mapping table | severity-classifier.sh:70-95 (CRIT_MARKERS) | severity-classifier.sh:94-95 (Q&A 96h) | severity-classifier.sh:137-142 (PROPOSED expired) | user_prompt 20260516_01.txt § 2 |
| HARD distributed across guards | obs § Current architecture (destructive-command-guard + project-integrity-watchdog) | destructive-command-guard.sh:1-50 | project-integrity-watchdog.sh (S341 D3 wire-up) | Q-RD3 ratification (architect recommendation) | observation § What I did NOT do (HARD reserved) |
| Telegram path live | obs § Status updates 09:55-10:00 SEAST (8 messages delivered) | .claude/settings.local.json:257-258 (creds) | telegram-push.sh:34-42 (no-op when creds absent) | BEHAVIORAL HOLD § (b) | current-execution.md:30 (Lê Lợi chat) |
| .pending-queue.tsv 9-col schema | obs § Schema: .pending-queue.tsv | DD-2 (this plan) | D3 hook header comment (NEW S346) | escalation-engine.sh D2 step 2 (writer side) | pending-queue-escalator.sh D3 (reader side) |
| ack <slug> single-token format | Q-RD4 ratification (architect recommendation) | obs § Open questions Q-RD4 | block-control.sh:207 existing approval-regex pattern (precedent) | DD-5 (this plan) | D4 firing-test TC-D4-5 (negative-match validation) |
| 30-day migration shim | obs § Migration step | DD-9 (this plan) | D5 sub-track (this plan) | severity-schema.md IMPL-tier cool-down rules | AP-7 anti-vacuous-defer (removal trigger named) |
| Atomic write doctrine | D-062 ratified ADR | severity-classifier.sh:33-41 (S341 D2 precedent) | DD-11 (this plan) | D3 hook structure | obs § Implementation step 3 (atomic write mention) |

## § H. DoD checklist (≥35 items)

### D1 — severity-classifier reclass
- [ ] DC-1: `scripts/hooks/severity-classifier.sh` header line 46 includes `block_tier` 6th column
- [ ] DC-2: emit_row helper accepts 5th argument with default SOFT
- [ ] DC-3: 3 CRIT_MARKERS at lines 70-80 emit tier=PENDING
- [ ] DC-4: Q&A age ≥96h at line 94 emits tier=PENDING
- [ ] DC-5: PROPOSED CHARTER expired at lines 137-142 emits tier=PENDING (charter-level only; others SOFT)
- [ ] DC-6: Mistake-log CRITICAL at line 157 emits tier=PENDING
- [ ] DC-7: HARD-tier placeholder comment block inserted after Layer 1
- [ ] DC-8: All Layer 5 notification emissions still tier=SOFT (default)
- [ ] DC-9: `.severity-state.tsv` after S346 IMPL has 6-col rows; 0 broken 5-col rows

### D2 — escalation-engine routing change
- [ ] DC-10: CRIT_ROWS split into HARD_ROWS + PENDING_ROWS via awk col6 check
- [ ] DC-11: HARD_N > 0 → `.autonomous-BLOCKED` flag written (existing logic preserved)
- [ ] DC-12: PENDING_N > 0 → `.pending-queue.tsv` populated with 9-col rows
- [ ] DC-13: Idempotency: re-run on same state.tsv does NOT duplicate queue rows
- [ ] DC-14: UserPromptSubmit injection at line 161 keyed off HARD_N only (PENDING silent per DD-10)
- [ ] DC-15: Telegram push at line 172 keyed off HARD_N (PENDING deferred to D3 escalator)

### D3 — pending-queue-escalator NEW
- [ ] DC-16: `scripts/hooks/pending-queue-escalator.sh` exists; +x mode; bash header `set -uo pipefail` + `trap 'exit 0' ERR`
- [ ] DC-17: Reads `.pending-queue.tsv`; preserves `#` header lines
- [ ] DC-18: escalate_at <= now + telegram_pushed=false → Telegram fires; telegram_pushed updates to true
- [ ] DC-19: age > 24h + telegram_pushed=true → archive file written to `notifications/archive/` + queue row removed
- [ ] DC-20: artifact_path GONE → resolve-archive (regardless of age) + queue row removed
- [ ] DC-21: Atomic write per DD-11 (TMP + mv -f + trap EXIT)
- [ ] DC-22: Log line emitted to `.pending-queue-escalator.log` with counters

### D4 — block-control ack subcommand
- [ ] DC-23: `cmd_ack` function defined; validates slug as `[a-zA-Z0-9_-]` only
- [ ] DC-24: `ack` case added to dispatch
- [ ] DC-25: check-prompt regex extended; multi-ack per prompt supported
- [ ] DC-26: Usage string at line 244 includes `ack <slug>`
- [ ] DC-27: ack NEVER clears `.autonomous-BLOCKED` (HARD-tier only via approval keyword path)

### D5 — migration shim
- [ ] DC-28: Comment block inserted with REMOVAL TARGET = 2026-06-15
- [ ] DC-29: awk split has `|| $6==""` clause for legacy 5-col rows
- [ ] DC-30: TC-D5-1 + TC-D5-2 fire-test cases added

### D6 — settings.json wire-up
- [ ] DC-31: `.claude/settings.json` Stop chain has pending-queue-escalator.sh AFTER escalation-engine.sh
- [ ] DC-32: Restart confirms Stop chain processes both hooks in correct order

### D7 — fire-tests + Telegram smoke + ADR + observation
- [ ] DC-33: All 25 new fire-test TCs PASS (run-all.sh aggregate)
- [ ] DC-34: Regression: all existing fire-test TCs preserve original PASS
- [ ] DC-35: Telegram smoke test executed; HTTP 200 + `{"ok":true,...}` in session log
- [ ] DC-36: ADR D-068 file exists at `agent-workspace/memory/decisions/068-block-ask-gate-3-tier-model.md`; 12-field schema compliant
- [ ] DC-37: Sandwich-dev observation file exists at `agent-workspace/memory/observations/sandwich-dev-S346-block-ask-gate-3-tier-impl.md`
- [ ] DC-38: Session log exists at `agent-workspace/memory/sessions/2026-05-16-session-N.md`
- [ ] DC-39: `bash scripts/hooks/bash-hook-lint.sh` clean (no new violations from new/edited hooks)
- [ ] DC-40: mypy/ruff/pytest 989/989 PASS (regression — must NOT break product code; this plan is HARNESS-only)

## § I. Verifier checks (V1..V12 for S347 sandwich-verifier)

V1: Re-read observation file 2026-05-16-block-ask-gate-redesign.md; confirm 3-tier model implemented matches design exactly (especially the Mapping table 5 trigger types)
V2: Run `bash scripts/hooks/firing-tests/run-all.sh` from FRESH context; report pass/fail aggregate (target: 100% PASS)
V3: Empirically trigger M-S342-1 scenario: create `.charter-violation-detected` test fixture; run Stop hook; confirm row goes to PENDING queue (NOT `.autonomous-BLOCKED`); confirm 6h Telegram not yet fired (escalate_at in future); cleanup fixture
V4: Empirically trigger HARD path: synthetic emit `CRITICAL\t...\tHARD` row to `.severity-state.tsv`; run escalation-engine; confirm `.autonomous-BLOCKED` written + Telegram fired immediately
V5: Test ack flow end-to-end: populate queue with 3 rows; run `bash scripts/hooks/block-control.sh ack <slug1>`; confirm 1 row archived + 2 remaining; run `echo '{"prompt":"ack <slug2>"}' | bash ...check-prompt`; confirm 2nd row archived
V6: Test 24h auto-archive: backdate detected_at in queue row to 25h ago + telegram_pushed=true; run pending-queue-escalator.sh; confirm row archived
V7: Test self-resolution: queue row with artifact_path pointing to non-existent file; run escalator; confirm row resolve-archived with `resolve_reason: artifact-gone`
V8: Confirm migration shim works: write a 5-col legacy CRITICAL row; run escalation-engine; confirm treated as PENDING (queue populated, no flag)
V9: Confirm DD-10 (UPS silence for PENDING): populate queue with PENDING row; run `bash scripts/hooks/escalation-engine.sh UserPromptSubmit`; confirm stdout does NOT mention "PENDING" or `.pending-queue.tsv`
V10: ADR D-068 compliance: confirm file exists + 12-field schema + status: PROPOSED + cool_down_hours: 0
V11: Compliance attestation: confirm 0 charter / 0 constitution edits; confirm only hooks + settings + decisions + observations + session-log + fire-tests touched
V12: Verify D-060 commit posture: sandwich-dev committed own work; main committed plan/ADR/observation; 0 push events in reflog (verifier may grep `git reflog | head -50` for `push` keyword across the session window)

## § J. Coordination paths off-limits during S346 IMPL (main session avoids these to prevent merge conflicts)

- `scripts/hooks/severity-classifier.sh` (D1 target)
- `scripts/hooks/escalation-engine.sh` (D2 target)
- `scripts/hooks/pending-queue-escalator.sh` (D3 NEW)
- `scripts/hooks/block-control.sh` (D4 target)
- `scripts/hooks/firing-tests/severity-classifier-fire-test.sh` (D1)
- `scripts/hooks/firing-tests/escalation-engine-fire-test.sh` (D2)
- `scripts/hooks/firing-tests/pending-queue-escalator-fire-test.sh` (D3 NEW)
- `scripts/hooks/firing-tests/block-control-fire-test.sh` (D4)
- `.claude/settings.json` (D6 Stop chain edit)
- `agent-workspace/memory/decisions/068-block-ask-gate-3-tier-model.md` (D7 NEW)
- `agent-workspace/memory/observations/sandwich-dev-S346-block-ask-gate-3-tier-impl.md` (D7 NEW)
- `agent-workspace/memory/sessions/2026-05-16-session-N.md` (D7 NEW)

S345-main may touch `agent-workspace/memory/current-execution.md` + `agent-workspace/memory/checkpoints/latest.md` + plan-024 mv (pending→completed) AFTER S346-dev returns and commits; these are close-bookkeeping coordination paths (NOT during IMPL window).

## § K. STEP 0 — Pre-flight verification (BLOCKING — sandwich-dev MUST execute before any D1-D7 edits)

This step is BLOCKING per S345 brief; sandwich-dev cannot proceed to D1 without successful STEP 0 + STOP-AND-ASK escalation if any blocker found.

### STEP 0.1 — Verify observation file path + content match current understanding
```bash
[ -f "$CLAUDE_PROJECT_DIR/agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md" ] || { echo "BLOCKER: observation file missing"; exit 1; }
wc -l "$CLAUDE_PROJECT_DIR/agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md"
# Expected: ~242 lines
```
- Read observation file + cross-check 3-tier model section + Mapping table; confirm matches plan-024 § D1-D2

### STEP 0.2 — Verify 5 current CRITICAL trigger types stable
```bash
grep -nE 'CRIT_MARKERS|emit_row "CRITICAL"' "$CLAUDE_PROJECT_DIR/scripts/hooks/severity-classifier.sh"
# Expected lines: 70-74 (CRIT_MARKERS array w/ 3 markers); 79 (Layer 1 emit); 95 (Layer 2 Q&A 96h emit); 141 (Layer 3 PROPOSED expired conditional); 157 (Layer 4 mistake-log emit); 201/211 (Layer 5 notification)
```
- If grep returns different line numbers or count, STOP-AND-ASK (architect's observation cited specific line numbers — drift here = observation stale, plan re-architect needed)

### STEP 0.3 — Verify Telegram path is live (mandatory smoke test per S345 brief)
```bash
bash "$CLAUDE_PROJECT_DIR/scripts/hooks/telegram-push.sh" "HIGH" "[TEST S346 STEP 0.3] Pre-flight smoke from sandwich-dev"
# Capture stdout/stderr + exit RC; expected:
#   RC=0 + log line in .telegram-push.log + Telegram bot delivers message to chat 891087440
# Verify by checking $CLAUDE_PROJECT_DIR/agent-workspace/memory/.telegram-push.log last 5 lines:
tail -5 "$CLAUDE_PROJECT_DIR/agent-workspace/memory/.telegram-push.log"
# Expected: "[<TS>] telegram-push: severity=HIGH resp_first120={"ok":true,...}"
```
- If RC != 0 OR log line missing OR resp does NOT contain `"ok":true`, STOP-AND-ASK (Telegram dead = D3 escalator can't function; defer entire plan or fix telegram-push first)

### STEP 0.4 — Verify no in-flight `.autonomous-BLOCKED` would interfere with migration
```bash
bash "$CLAUDE_PROJECT_DIR/scripts/hooks/block-control.sh" status
# Expected: "BLOCK-CONTROL STATUS: CLEAR" + grace status
```
- If status reports BLOCKED, STOP-AND-ASK (existing block must be cleared by human before migration; D1 reclass would change behavior for the in-flight block which may surprise the user; user "approved" or `bash scripts/hooks/block-control.sh clear` required first)

### STEP 0.5 — Backup current hooks (rollback safety)
```bash
SESSION_TAG="S346"  # adjust if session number differs
for f in severity-classifier.sh escalation-engine.sh block-control.sh; do
  cp "$CLAUDE_PROJECT_DIR/scripts/hooks/$f" "$CLAUDE_PROJECT_DIR/scripts/hooks/${f}.bak-${SESSION_TAG}"
done
ls -la "$CLAUDE_PROJECT_DIR/scripts/hooks/"*.bak-${SESSION_TAG}
# Expected: 3 .bak files alongside originals
```
- Per RM8 rollback path: if S347 verifier finds critical defects, sandwich-dev or main can `mv .bak-S346 → original` to revert
- These `.bak-S346` files are gitignored by default (no .gitignore needed; they're scratch); add to git ignore-list comment in session log if accidentally tracked

### STEP 0 STOP-AND-ASK triggers
- Observation file diverges from current state (STEP 0.1)
- 5 CRITICAL trigger types changed (STEP 0.2)
- Telegram dead (STEP 0.3)
- Existing `.autonomous-BLOCKED` requires user action (STEP 0.4)
- Backup creation fails (STEP 0.5 — likely permission issue requiring user)

## § L. Architecture Questions pre-answered (AQ-1..AQ-12)

| AQ | Question | Answer | Source |
|---|---|---|---|
| AQ-1 | What if `.severity-state.tsv` has BOTH CRITICAL+PENDING rows after migration? | HARD wins; CRITICAL+HARD → BLOCK; CRITICAL+PENDING → queue route; this won't happen post-migration (severity-classifier emits 0 HARD currently) but the shim window may show it if a HARD trigger is added later | DD-1 + § D2 step 1 awk split |
| AQ-2 | (Q-RD1 ratified) Auto-archive destination? | `notifications/archive/` per existing archive pattern; NOT deletion | Q-RD1 user ratification + DD-6 + existing 100+ archive files |
| AQ-3 | (Q-RD2 ratified) Special tier for Q&A >7d? | NO; sustained Telegram nag (every 24h re-fire after archive cycle re-detects same Q&A) is sufficient | Q-RD2 user ratification + DD-4 |
| AQ-4 | (Q-RD3 ratified) Centralize HARD in severity-classifier OR keep distributed? | Keep DISTRIBUTED across guards (destructive-command-guard + project-integrity-watchdog); severity-classifier focuses on PENDING signals | Q-RD3 user ratification + § C row "HARD distributed" |
| AQ-5 | (Q-RD4 ratified) `ack` syntax preference? | `ack <slug>` single-token; deterministic regex `(^\|\n)ack +<slug>([^a-zA-Z0-9_-]\|$)` | Q-RD4 user ratification + DD-5 |
| AQ-6 | ack slug ambiguity — multiple PENDING rows with same slug? | Latest takes priority (mv loop archives ALL matching rows; user can specify `ack <full-pending-id>` for disambiguation if needed) | § D4 cmd_ack implementation (matches by row_slug OR pending_id) |
| AQ-7 | Telegram rate-limit — pending-queue may fire ≥6 acks at once → batch? | 1 message per row OK for now (Telegram bot API: 30 msg/sec/chat soft limit; 6 messages well within); batch later if rate-limit hit (revisit trigger: any 429 response in `.telegram-push.log`) | DD-4 + telegram-push.sh:78-82 (curl with 10s timeout, ignores errors) |
| AQ-8 | Race between escalator + severity-classifier writing same TSV? | atomic write per D-062 (tmp + mv -f); both hooks follow it; mv is atomic on same filesystem; no race | DD-11 + severity-classifier.sh:33-41 + pending-queue-escalator.sh D3 atomic-write block |
| AQ-9 | Should ack history persist? | YES; archived row preserves `resolve_reason="ack-by-user-prompt"` in `notifications/archive/N-<ts>-PENDING-<slug>.md` | DD-6 + D4 cmd_ack archive block |
| AQ-10 | block-control.sh status output schema change? | YES; append PENDING count to status line; format `BLOCK-CONTROL STATUS: BLOCKED|CLEAR (pending=<N>)` | block-control.sh cmd_status extension (NEW per § D4 — implicit; sandwich-dev MUST add this) |
| AQ-11 | SessionStart cadence for escalator? | NO — Stop only; SessionStart reads queue for display in continue-injector if needed (separate concern, not in scope) | DD-AQ-11 + § D6 wire-up |
| AQ-12 | M-S342-1 `.charter-violation-detected` test-fixture case under new model? | Fixture would PENDING for 6h before any Telegram (plenty of time for verifier to clean up via trap EXIT); M-S342-1 LOSS SURFACE drops MEDIUM → LOW; mistake-log entry should be updated post-S346 to reflect new model | obs § What I did NOT do (M-S342-1 reference) + S342 verifier observation context + ADR D-068 § Consequences |

## § M. Risk-Mitigation table (RM1..RM12)

| RM | Risk | Mitigation | Trigger to revisit |
|---|---|---|---|
| RM1 | Migration shim drops too early (legacy 5-col rows ignored before reflux drains) | 30-day window per DD-9; explicit removal date 2026-06-15 in comment block; pre-removal grep confirms 0 legacy rows in production state file | If grep finds legacy rows on 2026-06-15, extend shim 7 days; if 3rd extension needed, AP-7 retire trigger (root-cause why classifier still emits 5-col rows) |
| RM2 | Auto-archive deletes something user wanted | archive/ destination per DD-6 (NOT deletion); user can grep `notifications/archive/*-PENDING-*.md` to recover any auto-archived row | If user requests recovery of auto-archived row, restore is `cat <archive-file>` and re-emit via severity-classifier next cycle |
| RM3 | `ack <slug>` false-positive matches in regular prompts (user types "ack" in conversation) | strict `(^\|\n)ack +<slug>([^a-zA-Z0-9_-]\|$)` regex per DD-5; whitespace anchor + line anchor + slug-char-only suffix; TC-D4-5 negative-match test ("hackathon" no-match) | If user reports false-match in real session, tighten regex to `^ack +<slug>$` (full-line anchor); document as M-S347-N if happens |
| RM4 | Telegram down (network failure / API change) | escalator logs failure to `.pending-queue-escalator.log`; retries next Stop cadence (telegram_pushed remains false until success) | If 3+ consecutive Stop cycles fail to push, AP-7 trigger to investigate; STOCKFORGE_TELEGRAM_DRY_RUN=1 env as bypass |
| RM5 | New hook adds 100-500ms to Stop chain (timing budget) | Acceptable per item-1 work removes ~5min cumulative human-intervention per turn; net huge win (estimated +200ms hook cost vs -5min user-input cost) | If Stop chain p95 exceeds 30s (3-sigma over baseline), profile via `time` wrapper |
| RM6 | HARD path never exercised (all triggers are PENDING) → bit-rot of HARD code path | TC-D2-1 + TC-D5-2 fire-tests exercise HARD path via synthetic injection; D1 comment block documents HARD as reserved | If HARD path TCs FAIL during normal regression, escalate to AP-7 (path drift means severity-classifier might be silently changed) |
| RM7 | `pending_id` collision — multiple severity-classifier runs within same second produce same `<slug>-<epoch>` | mitigated by epoch_seconds (sub-second collision rare in single-bash-Stop cadence); idempotency check at D2 step 2 (`grep -F -q $'\t'"$path"$'\t' "$PENDING_QUEUE"`) prevents duplicate insertion even if collision occurs | If collision observed in real session (2 rows with same pending_id), augment slug with `$$` PID per L-S289-1 atomic-claim pattern |
| RM8 | User reverts to old behavior | rollback path via `.bak-S346` backups (STEP 0.5); 30 second `mv .bak-S346 original` reverts D1+D2+D4 in one command; D3 + D6 require explicit removal | Documented in session log; rollback procedure explicit in plan-024 § STEP 0.5 |
| RM9 | Q&A 96h migration — old `.severity-state.tsv` rows already CRITICAL; new flow re-classifies via shim; existing `.autonomous-BLOCKED` cleared manually one time at deploy | sandwich-dev at S346 IMPL DOES one-time clear via `bash scripts/hooks/block-control.sh clear deploy "S346 D1 migration"` BEFORE D1 ships (per STEP 0.4); subsequent Stop cycles re-classify via new code | If 2nd `.autonomous-BLOCKED` raised within 30 days, investigate root-cause (might be a legitimate HARD that should remain) |
| RM10 | 3-tier complexity for users — confusion about what "PENDING" means vs "HARD" vs "SOFT" | clear docs in block-control.sh `--help` output (NEW — sandwich-dev MUST add); ADR D-068 § Decision table provides authoritative mapping | If user asks "what does PENDING mean?", expand docstrings; if 3+ asks within 30 days, promote to constitution/severity-schema.md update |
| RM11 | `.pending-queue.tsv` grows unbounded | auto-archive 24h ceiling per DD-6 + log-rotate compatible (queue file is line-oriented TSV; could be rotated via existing pattern); typical queue size <10 rows per observation (5 trigger types, each ages out in 24h) | If queue exceeds 100 rows, force-rotate via `mv .pending-queue.tsv .pending-queue.tsv.archive-<ts>`; document as M-S347-N |
| RM12 | Cross-platform Windows/WSL filename collision in slug (special chars from artifact_path basename) | mitigated by `tr -dc 'a-zA-Z0-9-_'` in slug derivation (D3 + D4 + DD-3) — drops ALL non-portable chars; head -c 40 caps length | If slug=empty after sanitization (artifact_path basename has only special chars), default to "unknown" sentinel per D3 hook |

## § N. Budget envelope + estimation

**Recommended budget**: 120-180K Opus FOCUSED_IMPL (per S345 brief)

**Token breakdown estimate**:
- VBW re-read of 5 hooks (severity-classifier + escalation-engine + block-control + autonomous-block-enforcer + telegram-push) end-to-end: ~12K
- VBW re-read of observation file (~13KB ÷ 4 chars/token ≈ 3K): ~3K
- VBW re-read of plan-024 (this file, ~30KB): ~7K
- Re-read of 4 existing fire-test files for cadence: ~5K
- Re-read of `.claude/settings.json` Stop chain (~230 LOC ÷ 4): ~1K
- D1 edits + verify: ~10K
- D2 edits + verify: ~12K
- D3 new hook authoring + verify: ~15K
- D4 edits + verify: ~10K
- D5 + D6 edits: ~5K
- D7 ADR + obs + session log + fire-test extensions: ~25K
- Telegram smoke test execution + parsing response: ~2K
- Final aggregation + git commit composition: ~3K
- Buffer for tool overhead + retries: ~30K
- **Total**: ~140K (within 120-180K envelope)

**LOC delta total**: ~530 LOC across 8 code files + 4 doc files

**Sonnet acceptability**: Sonnet is acceptable IF context window is fresh (no prior session bleed) AND sandwich-dev has Read tool to load observation file in-session. Opus preferred for the architectural-judgment-heavy DD-1..DD-12 decisions during ack flow design (D4 regex tradeoffs).

## § O. AP-23 attestation

This plan PROMOTES the previously-distributed informal "pending-or-not-really-blocking" notion into a 1st-class harness primitive (the PENDING tier). Per AP-23 ritual-demotion framework:

- **Instance counter for "informal pending" pattern**:
  - 1st instance: M-S342-1 (`.charter-violation-detected` test fixture treated as CRITICAL when it should have been informal)
  - 2nd instance: Q&A age ≥96h treated as CRITICAL when it should be soft (per observation TL;DR)
  - 3rd instance: stale-checkpoint marker treated as CRITICAL when it's bookkeeping (per observation Mapping table row 1)
  - 4th instance: ghost-greening-confirmed treated as CRITICAL when agent could continue (per observation Mapping table row 3)
  - 5th instance: PROPOSED expired cool-down treated as HIGH when architect/dev sandwich already handles it (per observation Mapping table row 6)

- **Verdict**: 5 distinct instances of the same anti-pattern (informal-pending escalated as CRITICAL+BLOCK) → AP-23 PROMOTE-NOW mandate satisfied. This plan ships the promotion (PENDING as 1st-class tier).

- **Anti-pattern AP-23 RED FLAG (refinement-of-rule, 2nd instance mandates promote)**: 1st refinement was S341 D1 (adding `level: WARN` frontmatter to source-hook warn notifications); this is the 2nd refinement (adding `block_tier` col to severity-state.tsv schema). Both refine the severity-classification model. PROMOTE-NOW (this plan IS the promotion).

## § P. Compliance attestation (sandwich-dev MUST sign at IMPL close)

| Rule | Status |
|---|---|
| 0 charter writes (PROJECT_CHARTER.md) | UPHELD (not touched) |
| 0 constitution writes (agent-workspace/constitution/**) | UPHELD (ADR D-068 lives in memory/decisions/) |
| 0 production code outside scripts/hooks/ + .claude/settings.json + memory/decisions/ + firing-tests/ + observations/ + session-plans/ | UPHELD per § C boundary table |
| harness_priority_one (harness > product) | UPHELD (this plan is HARNESS — no product code touched; mypy/ruff/pytest 989/989 PASS regression-only) |
| AP-1 fresh-context (architect ↔ dev ↔ verifier separated) | UPHELD (S345 architect, S346 dev, S347 verifier — 3 separate contexts) |
| D-060 commit policy (agent commits OK; agent pushes FORBIDDEN) | UPHELD (sandwich-dev commits at sub-track boundaries; main commits plan/ADR/observation outputs; 0 pushes — verifier may grep reflog) |
| AP-7 anti-vacuous-defer (every DEFER names prerequisites + revisit trigger) | UPHELD (RM table has explicit triggers for RM1+RM3+RM7+RM10+RM11) |
| AP-23 promote-or-retire (2nd instance promotes) | UPHELD (5 instances promoted to PENDING tier; § O attestation) |
| VBW protocol (re-read source before mutation) | UPHELD at IMPL (sandwich-dev MUST re-read 5 hooks per STEP 0.2) |
| Telegram smoke test executed | REQUIRED at STEP 0.3 (sandwich-dev signs log line) |
| D-062 atomic write doctrine | UPHELD (DD-11 + D3 hook implements tmp+mv+trap; severity-classifier.sh:33-41 pattern reused) |
| D-064 path safety contract | UPHELD (DD-12 + D3/D4 archive moves use basename whitelist) |

## § Q. Out-of-scope (with AP-7 revisit triggers)

| Item | Why excluded | Revisit trigger |
|---|---|---|
| PreToolUse HARD-tier guards (destructive-command-guard + project-integrity-watchdog) | Already exist; not in scope per Q-RD3 ratification + S345 brief OUT list | If a new HARD trigger class emerges (e.g., "rm -rf in subagent context"), add to existing guards (NOT to severity-classifier) |
| Telegram credential changes (rotation, multi-chat) | Already-live; not in scope per S345 brief OUT list | If creds compromised, rotate via `.claude/settings.local.json` env block; no code change needed |
| Unrelated escalation paths (e.g., new Layer 6 telemetry scan) | Out of scope per S345 brief; would inflate plan beyond 180K budget | Separate plan-025+ if needed; revisit when fire-test coverage for current 5 layers > 90% |
| Charter / constitution edits | Out of scope per S345 brief + agent-workspace/CLAUDE.md Contract Rule 1 | If ADR D-068 needs charter-tier elevation (e.g., severity-schema.md update), separate plan with explicit human approval per Contract Rule 1 |
| SessionStart cadence for escalator | Per DD-AQ-11 NO (Stop only) | If user wants SessionStart escalation (e.g., "tell me on session start if queue has rows"), wire pending-queue-escalator.sh as SessionStart hook + add display in continue-injector.sh |
| Batched Telegram messages | Per AQ-7 single-message-per-row OK initially; defer per AP-7 | If 429 response observed in `.telegram-push.log` (rate-limit hit), implement batching with deduplication |
| `ack <full-pending-id>` for disambiguation | Per AQ-6 implicit support (cmd_ack matches both row_slug OR pending_id); test case TC-D4-NEW could be added if user requests | If user reports ambiguity issue in real session, add TC + document |
| 30-day migration shim removal automation | Per DD-9 explicit manual removal date 2026-06-15 | Calendar reminder; or schedule a sweeper hook to flag at session start |

---

**END OF PLAN-024**
