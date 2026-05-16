---
plan_id: 023-S346-stop-hook-perf-quick-wins
target_session: S346
type: FOCUSED_IMPL
budget: 80-120K (Opus FOCUSED_IMPL; Sonnet acceptable if STEP 0.3 bash-hook-lint root cause is shallow + DD-4 picks Option (a) or (c) over (b) parallelization. Bump to MULTI_TASK if STEP 0.4 phase-status regex fix requires a letter-to-numeric mapping table that grows the diff)
phase: B/D-overlap (HARNESS — non-product; per `harness_priority_one` doctrine outranks Phase D continuation Vietstock/VietnamBiz adapters + S345 NDH verifier dispatch deferral until the 5.3-min Stop chain is fixed)
track: Stop Hook Performance Quick Wins — P1 (hoist marker-cleanup) × 4 hooks + P2 (Stop-mode cool-down) × 4 hooks + P3 (bash-hook-lint root-cause + minimum fix) + phase-status-coherence regex fix
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md
                    (no master-plan parent; this is the Item-1 harness deliverable from
                    `observations/2026-05-16-stop-hook-performance-audit.md`; deferred
                    A1-A4 architectural items become plan-027a..e successors)
predecessor: 2026-05-16 Stop hook performance audit observation (agent-workspace/memory/observations/2026-05-16-stop-hook-performance-audit.md) — empirical diagnostic written this turn by main session Opus 4.7 max-effort per user_prompt 20260516_01.txt § 1 ratification "follow your recommendation" + "run full autonomous" 2026-05-16T~20:30 SEAST. Also S343-S344 row of current-execution.md:135 documents the surgical "Phase 4 —" prefix workaround applied to S343-S344 header to satisfy phase-status-coherence.sh:84 regex limitation — that workaround is replaced by the proper fix in D4.
successor: S347 sandwich-verifier (AP-1 fresh-context, Opus, ~30-50K VERIFY budget); then plan-024+ harness work as remaining backlog items dictate. Architectural follow-ups DEFERRED to plan-027a..e (see § L).
architect: S345 sandwich-architect (this plan; background dispatch per `sandwich-architect.md` D7 update — architect MAY commit own PLAN output)
dispatched_by: main session orchestrating harness PLAN-IMPL-VERIFY sandwich after S343-S344 NDH adapter cycle + Item 1-4 harness deep-dives. User ratification at 2026-05-16T~20:30 SEAST: "follow your recommendation" + "run full autonomous".
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S346; fresh-context; AP-1 verifier in S347)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING cadence + ROUTINE-IDLE close ritual SUSPENDED (carry-forward; do NOT recommend sync-grilling cadence as part of fixes)"

depends_on:
  - "D-060 (commit-policy-agent-may-commit — operational gate for S346 dev commit boundary; sandwich-dev commits own work; D-060 terminal status UNCHANGED per S343-S344 row attestation)"
  - "D-062 (atomic-write-doctrine — BINDING for the cool-down marker file writes introduced by D2; markers MUST be `tmp + os.replace`-equivalent OR atomic noclobber OR plain `touch` — see § D DD-2)"
  - "D-064 (path-safety 5-invariant contract — N/A for this plan; all marker writes stay in $MEM_DIR which is already audited as allow-zone)"
  - "Charter v1.1 Principle 11 (Harness must self-verify firing — every hook touched MUST have its companion firing-test re-run green; 5 NEW fire-tests authored as table-stakes for the cool-down + hoist changes)"
  - "Charter v1.1 Principle 7 (Dogfood mandatory — fixes self-audited via the affected hook chains in same session; D6 empirical re-measurement is the dogfood checkpoint)"
  - "I-S33 self-aware-agent invariant (harness reliability is the substrate for I-S33; reducing Stop chain wall time directly improves session-cycle throughput)"
  - "CLAUDE.md `harness_priority_one` memory rule (this IS harness work; product Phase D continuation + S345 NDH verifier dispatch DEFERRED until S346 lands)"
  - "scripts/hooks/atomic-write-check.sh (D1+D2 primary target)"
  - "scripts/hooks/python-determinism-check.sh (D1+D2 primary target)"
  - "scripts/hooks/path-safety-check.sh (D1+D2 primary target)"
  - "scripts/hooks/html-separator-check.sh (D1+D2 primary target)"
  - "scripts/hooks/bash-hook-lint.sh (D3 primary target)"
  - "scripts/hooks/phase-status-coherence.sh (D4 primary target)"
  - "scripts/hooks/firing-tests/atomic-write-check-fire-test.sh (D5 target — extend with TC-COOLDOWN + TC-HOISTED)"
  - "scripts/hooks/firing-tests/python-determinism-check-fire-test.sh (D5 target — extend)"
  - "scripts/hooks/firing-tests/path-safety-check-fire-test.sh (D5 target — extend)"
  - "scripts/hooks/firing-tests/html-separator-check-fire-test.sh (D5 target — extend)"
  - "scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh (D5 target — extend if D3 changes lint logic)"
  - "scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh (D5 target — NEW fixture; this fire-test does NOT exist today per Glob 2026-05-16; D4 must create both the fix and its companion fire-test per Charter v1.1 Principle 11)"
  - "agent-workspace/memory/observations/2026-05-16-stop-hook-performance-audit.md (predecessor diagnostic — STEP 0 verifies it is still current)"
  - ".claude/agents/sandwich-architect.md (D7-template architect-may-commit + plan-021/022 cadence reference)"
  - ".claude/agents/sandwich-dev.md (STEP 0.10 baseline-capture requirement; observation-file required per D7-template carry-forward)"
  - "agent-workspace/session-plans/completed/021-S340-harness-stabilization-sweep.md (plan shape reference; D1-D7 sub-track decomposition pattern)"
  - "agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md (plan shape reference; STEP 0 BLOCKING pattern)"

binding_decisions:
  - "D-060 — agent MAY git commit (NOT push); S346 dev decides commit boundary per § J Coordination paths"
  - "AP-23 promote-or-retire — N/A this plan (no ritual demotion candidates; quick-win patches are 1st-instance harness fixes, not refinement-of-rule)"
  - "AP-7 anti-vacuous-defer — every DEFER decision in this plan names (a) prerequisites + (b) revisit trigger; A1-A4 deferrals at § L cite plan-027a..e successor IDs with named triggers"
  - "Karpathy P3 surgical-changes — every recommendation traces to observation file empirical findings + the phase-status-coherence regex limitation surfaced at S343-S344 row; NO invented harness work"
  - "VBW protocol mandatory — before recommending any hook change, READ the actual hook file; this plan cites file:line for every claim per I-S2; architect Read all 6 affected hooks end-to-end before plan finalization"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL; this plan is architect's; S346 is dev's)"
  - "no commits in THIS plan-session by main session (architect MAY commit own PLAN output per sandwich-architect.md D7 update; D-060 still applies — agent NEVER pushes)"
  - "no charter / no constitution writes in THIS plan-session (0 charter / 0 constitution per S346 brief)"
  - "no human-workspace writes in THIS plan-session (S346 dev MAY touch human-workspace/notifications/* via existing allow-list when verifying P2 cool-down behavior; ONLY for empirical D6 dogfood, NOT as part of the patch itself)"
  - "no AskUserQuestion gate this session (no charter/scope question; all decisions are IMPL-tier; per `full_autonomous_no_supervised` AskUserQuestion is for SCOPE/CHARTER only)"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual hook files Read end-to-end via Read tool, not memory (VBW protocol verified for atomic-write-check.sh:1-301 + python-determinism-check.sh:1-253 + path-safety-check.sh:1-333 + html-separator-check.sh:1-258 + bash-hook-lint.sh:1-523 + phase-status-coherence.sh:1-239)"
  - "no touching the Stop chain ordering in .claude/settings.json:315-524 — that's A4 deferred to plan-027e; if dev finds an ordering bug surface in observation, do NOT fix here"
  - "no consolidating any of the 4 .py-scan hooks (atomic-write/python-determinism/path-safety/html-separator) into a single batch hook — that's A1 deferred to plan-027b; if dev finds the patches converge on identical logic that begs for extraction, surface in observation"
---

# S346 — Stop Hook Performance Quick Wins (P1 hoist + P2 cool-down + P3 bash-hook-lint + D4 phase-status regex)

## § A. Session metadata

| Field | Value |
|---|---|
| Plan ID | 023-S346-stop-hook-perf-quick-wins |
| Target session | S346 (sandwich-dev, FOCUSED_IMPL) |
| Verify session | S347 (sandwich-verifier, AP-1 fresh-context Opus) |
| Budget | 80-120K (Opus FOCUSED_IMPL; bump to MULTI_TASK only if STEP 0 surfaces wider scope) |
| Phase | B/D-overlap (HARNESS — non-product) |
| Type | FOCUSED_IMPL |
| Wave / Theme | Wave-1 substrate-care; closes Item-1 from Stop hook performance audit |
| Coordination paths off-limits during S346 IMPL | See § J |
| Predecessor | 2026-05-16 Stop hook performance audit observation; S343-S344 current-execution row (regex workaround applied) |

---

## § B. Goal

Ship the **P1+P2+P3+phase-status regex-fix quick-win bundle** that reduces Stop hook chain wall time from the current empirical ~5.3 minutes/cycle to ≤30s/cycle, AND silences the silent false-positive RED HIGH that phase-status-coherence.sh has been emitting for ~25 sessions (S323-S342) on every Wave 1 letter-phase header.

In one sentence: **the per-file `find` scan on 1289-entry $MEM_DIR is hoisted out of the per-file loop in 4 hooks, a 10-min cool-down marker lets Stop-mode early-exit if the last full sweep was recent, bash-hook-lint's timeout cause is empirically diagnosed in STEP 0 then minimum-fixed, and phase-status-coherence's numeric-only Phase regex is extended to accept letter-phase headers via an explicit letter→numeric mapping table.**

What this plan delivers:
- **D1**: Hoist `find ... -delete` marker-cleanup out of `claim_file_slot` per-file loop in 4 hooks. Expected ~190s → ~10s saved (4 hooks × ~50s each).
- **D2**: Add Stop-mode `.{name}-last-full-sweep` cool-down marker (600s) + early-exit branch in the same 4 hooks. Skips redundant full-tree sweeps within a 10-min window.
- **D3**: STEP 0.3 diagnoses bash-hook-lint's >60s timeout root cause; ship minimum-fix (parallelization, early-exit, or cron-migration documented in D3 finding).
- **D4**: Fix `phase-status-coherence.sh:84` regex to accept `Phase ([0-9]+(\.[0-9]+)?|[A-Z](-prime)?)` AND introduce a letter→numeric mapping table (A/B/C/D/E/F-prime/G-prime/H-prime → Phase 4 sub-decomposition) so IN PROGRESS row matching works for both schemes; remove the "Phase 4 —" surgical workaround currently inlined at S343-S344 header.
- **D5**: 5 NEW fire-tests authored (1 NEW phase-status-coherence-fire-test.sh + 4 extensions to existing fire-tests covering TC-HOISTED + TC-COOLDOWN).
- **D6**: Empirical D6 re-measurement post-patch (Stop chain wall time before vs after; target ≤30s vs current ~5.3min for the full chain, with the 4 affected hooks combined ≤10s vs current 215s).
- ZERO charter / constitution / human-workspace writes (verify-only writes to human-workspace/notifications/* during D6 dogfood are excluded from this rule).
- ZERO new hooks (D4 ships its companion fire-test only; the hook itself is a regex extension to an existing file).
- ZERO new ADRs (this is patch-tier work per § G AQ-8; comment in code suffices).

---

## § C. In-scope / Out-of-scope

### IN-scope (this bundle MUST ship)

- **D1 hoist marker-cleanup** in 4 hooks: `atomic-write-check.sh` + `python-determinism-check.sh` + `path-safety-check.sh` + `html-separator-check.sh`
- **D2 Stop-mode cool-down marker** + early-exit branch in the same 4 hooks
- **D3 bash-hook-lint root-cause diagnosis + minimum fix** (per STEP 0.3 finding; scope adaptive per AQ-1)
- **D4 phase-status-coherence regex fix** + letter→numeric mapping table + companion fire-test
- **D5 5 NEW fire-tests**: 1 NEW `phase-status-coherence-fire-test.sh` + 4 extensions to existing fire-tests (TC-HOISTED + TC-COOLDOWN per hook)
- **D6 empirical re-measurement** of Stop chain wall time pre- and post-patch (recorded in session log + observation)
- **Cleanup of S343-S344 header surgical workaround** — once D4 lands, edit S343-S344 row of current-execution.md:135 to remove the "(harness regex compatibility): header explicitly prefixed 'Phase 4 —' so scripts/hooks/phase-status-coherence.sh:84 regex extracts '4'" naming note since it's no longer needed (Phase D is the canonical header form, and the regex now handles it natively)
- Session log + observation file per CLAUDE.md § Session Protocol End steps

### OUT-of-scope (DEFERRED — explicit non-goals; named successors)

- **A1 4-hook consolidation** into single `python-quality-batch.sh` (single file-walk, all 4 rule sets) → plan-027b; revisit trigger: D1+D2 ship + a 2nd independent perf complaint surfaces OR a 5th .py-scan hook gets added (forcing the question)
- **A2 5-log-rotate hook merge** into single `log-rotate-batch.sh` → plan-027c; revisit trigger: any rotate hook needs schema change OR a 6th rotate hook is added
- **A3 audit-cron migration** of 6 heavy audit hooks (bash-hook-lint + file-pattern-hook-pre-flight-lint + taskcompleted-audit + ghost-work-audit + memory-routing-audit + tier1-bloat-check) → plan-027d; revisit trigger: D3 root-cause finding identifies bash-hook-lint as cron-eligible OR Stop chain still >30s after D1+D2+D3
- **A4 Stop chain cap at 20 hooks** via consolidation + cron migration → plan-027e; revisit trigger: A1+A2+A3 all ship
- **Stop chain re-ordering** (sequence change in `.claude/settings.json:315-524`) — NOT touched here per `hard_rules_acknowledged`; if dev finds an ordering bug, SURFACE in observation, do NOT fix
- **Charter / constitution edits** — out of scope per CLAUDE.md hard rules
- **ADR D-067 atomic-write-cleanup-doctrine** — explicitly NOT created (AQ-8: this is patch-tier; comment in code suffices)
- **NEW hooks** — D4 ships its fire-test but the hook is an existing-file regex extension; no new Stop-chain entries
- **Migration of existing 363 .aw-marker-* / 363 .pydet-marker-* / 363 .psafety-marker-* / 161 .htmlsep-marker-* files** — AQ-5: keep, hour-bucket aging will retire them naturally within 2hrs (the existing 120-min cleanup window unchanged)
- **bash-hook-lint full parallelization with `xargs -P 4`** — gated on STEP 0.3 finding; if root cause IS the multi-pattern regex × 108 hooks, surface as plan-027a successor; do NOT ship full parallelization here unless STEP 0.3 confirms it's the smallest fix
- **project.md letter-phase row addition** — AQ-6: no; mapping table in hook resolves D→Phase 4; project.md unchanged
- **.severity-state.tsv schema migration** — out of scope (that's plan-024 territory if ever)
- **`pre-dispatch-architect-commit-guard.sh` PreToolUse hook** (introduced in S341 D3) — UNCHANGED; this plan does NOT alter dispatch guards

---

## § D. STEP 0 — Pre-flight verification (BLOCKING)

The implementing session (S346) MUST run these sub-steps BEFORE writing any patch code and write results into the session log. This plan was authored by a sandwich-architect subagent with Read/Glob/Grep/Write but NO Bash — STEP 0 is the empirical anchor that grounds plan recipes against the live hook state at S346 dispatch time.

**STOP-AND-ASK clause** (binding):
- If STEP 0.1 finds the observation file path no longer exists OR the empirical findings diverge from a fresh timing run (someone may have patched in parallel) → STOP-AND-ASK (defer patches; reconcile what's already been done; do NOT re-patch already-patched hooks)
- If STEP 0.3 finds bash-hook-lint times out for a different reason than file-walk (e.g., a regex catastrophic-backtrack or a deadlock on a tempfile mutex) → SURFACE in observation, ship the smallest fix that gets it under 30s; flag root cause for plan-027a successor; do NOT attempt full parallelization or root-cause exhaustion in this session
- If STEP 0.4 finds the phase-status regex hook is actually slow for a reason ORTHOGONAL to the regex (e.g., the 5-min cache fails to write, or the stat call on .phase-coherence-fired-* marker proliferates) → SURFACE in observation, ship the regex fix anyway (D4 scope), DEFER any perf side-fixes to plan-027 backlog

### Sub-step 0.1 — Verify observation file path + empirical baseline

```bash
# Confirm observation file still exists and content matches the diagnosis
ls -la "$PROJECT_DIR/agent-workspace/memory/observations/2026-05-16-stop-hook-performance-audit.md"
head -50 "$PROJECT_DIR/agent-workspace/memory/observations/2026-05-16-stop-hook-performance-audit.md"

# Re-time a representative hook (atomic-write-check.sh) once empirically.
# Compare against the observation's 54.9s baseline.
cd "$PROJECT_DIR"
TS_START=$(date +%s%N)
bash scripts/hooks/atomic-write-check.sh < /dev/null > /dev/null 2>&1
TS_END=$(date +%s%N)
WALL_MS=$(( (TS_END - TS_START) / 1000000 ))
echo "atomic-write-check.sh STEP-0.1 baseline: ${WALL_MS}ms (observation reported 54900ms)"
```

**Record in session log**: Baseline wall ms for atomic-write-check.sh. If wall < 5000ms (5s), the file has already been patched somehow — STOP-AND-ASK. If wall ≥ 30000ms (30s), the baseline matches observation, proceed.

### Sub-step 0.2 — Verify all 4 .py-scan hooks share the `claim_file_slot` pattern

```bash
# Grep-verify all 4 hooks have the per-file find+delete inside claim_file_slot
cd "$PROJECT_DIR"
for h in atomic-write-check python-determinism-check path-safety-check html-separator-check; do
  echo "--- $h ---"
  grep -n "claim_file_slot()" "scripts/hooks/${h}.sh" | head -3
  grep -n "find.*MEM_DIR.*-delete" "scripts/hooks/${h}.sh" | head -3
done
```

**Expected**: each hook has exactly ONE `claim_file_slot()` definition + ONE `find $MEM_DIR ... -delete` line nested inside it. Marker prefixes per hook:
- `atomic-write-check.sh:149` — `.aw-marker-*`
- `python-determinism-check.sh:69` — `.pydet-marker-*`
- `path-safety-check.sh:165` — `.psafety-marker-*`
- `html-separator-check.sh:86` — `.htmlsep-marker-*`

**Branch**:
- All 4 match → PROCEED with D1 hoist plan as written
- Any 1 hook has a DIFFERENT marker name → record + use the discovered name (do not break compat); proceed
- Any 1 hook has NO `find ... -delete` inside `claim_file_slot` → that hook was pre-patched; SKIP D1 for that hook; record + still apply D2 cool-down (independent)

### Sub-step 0.3 — Diagnose bash-hook-lint root cause via single empirical timing

```bash
# Time the hook AND profile the slow-loop
cd "$PROJECT_DIR"
TS_START=$(date +%s%N)
timeout 90 bash scripts/hooks/bash-hook-lint.sh < /dev/null > /tmp/bhl-stdout.log 2>/tmp/bhl-stderr.log
RC=$?
TS_END=$(date +%s%N)
WALL_MS=$(( (TS_END - TS_START) / 1000000 ))
echo "bash-hook-lint.sh STEP-0.3: ${WALL_MS}ms rc=${RC}"

# If wall > 60000ms, run it with bash -x for one of the inner loops to find the hot loop:
if [ "$WALL_MS" -gt 60000 ]; then
  echo "--- Counting hooks scanned ---"
  ls "scripts/hooks/"*.sh | wc -l   # Expected ~108 per observation

  # Time individual checks by counting iterations + measuring per-check elapsed
  for check_num in 1 4 2 5 6 6b 7 8 9 10; do
    echo "--- Check ${check_num} approximate timing (per-hook iteration) ---"
    # Run with -x and tail the last 20 lines to see which check dominates
  done
fi
```

**Record in session log**:
- Total wall ms
- Number of hooks scanned (108 expected per observation)
- If wall > 60000ms: which `for f in "$HOOKS_DIR"/*.sh` loop dominates (Check 1 / 2 / 3 / 4 / 5 / 6 / 6b / 7 / 8 / 9 / 10 per bash-hook-lint.sh:44-491)
- If wall < 30000ms: STOP-AND-ASK (someone patched bash-hook-lint already)

**Branch — DD-4 picked based on STEP 0.3 finding** (architect's expectation in priority order):
- **Expected most likely** (per observation hypothesis): multi-pattern grep × 108 hooks dominates → DD-4 PICK = **add a per-file content-hash early-exit** (compute sha256 of hook file content; cache in `agent-workspace/memory/.bhl-cache-{sha256}.ok`; skip the 10 checks if cached). Adds ~30 LOC + ~5 LOC per check; preserves all existing behavior; full re-scan only on file content change. Expected wall: ~3-5s on warm cache (most hooks unchanged session-to-session).
- **Possible**: ONE specific Check (e.g., Check 7 or 9 awk script) catastrophic-backtracks on a specific hook file → DD-4 PICK = **isolate the offending check + offending file; ship a minimal regex tightening OR add a per-file skip-marker for the false-positive trigger**; defer broader perf work
- **Less likely**: temp file or mutex deadlock → DD-4 PICK = **xargs -P 4 parallelization of the per-hook loop body**; ~50 LOC delta; gated on STEP 0 confirmation
- **Least likely** (gated on AQ-4 escalation): root cause needs longer than 30 min STEP 0.3 budget → DD-4 PICK = **add a 60s wall-budget kill switch + cron-migration documentation**; defer real fix to plan-027a

### Sub-step 0.4 — Verify phase-status-coherence regex limitation empirically

```bash
# Source the regex parsing logic with both numeric and letter sample headers
cd "$PROJECT_DIR"

# Numeric phase (current header form per S343-S344 workaround)
echo '## S343-S344 — Phase 4 — NDH adapter PLAN+IMPL DONE' | \
  sed -E 's/^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase[[:space:]]+([0-9]+(\.[0-9]+)?).*/\1/'
# Expected: "4"

# Letter phase (the Wave 1 canonical form that was silently failing)
echo '## S343 — Phase D — Wave 1 Phase D NDH adapter PLAN dispatched' | \
  sed -E 's/^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase[[:space:]]+([0-9]+(\.[0-9]+)?).*/\1/'
# Expected: full header echoed back (regex no-match leaves line unchanged)
# THIS confirms the bug — letter phases are NOT captured

# Letter phase with -prime suffix (Wave 1 secondary phases per project.md row 4)
echo '## S400 — Phase F-prime — Theme H placeholder' | \
  sed -E 's/^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase[[:space:]]+([0-9]+(\.[0-9]+)?).*/\1/'
# Expected: full header echoed back (also fails)
```

**Record in session log**: All 3 sed invocations output, verbatim. Confirms which patterns hit + which miss.

### Sub-step 0.5 — Inventory existing markers (decide D1 migration concern)

```bash
# Count existing markers per prefix
cd "$PROJECT_DIR/agent-workspace/memory"
for prefix in aw pydet psafety htmlsep; do
  n=$(find . -maxdepth 1 -name ".${prefix}-marker-*" -type f 2>/dev/null | wc -l)
  echo "${prefix}-marker count: ${n}"
done
# Expected per observation: 363 aw + 363 pydet + 363 psafety + 161 htmlsep ≈ 1250
```

**Decision per AQ-5**: keep existing markers; the 120-min `find -mmin +120 -delete` in the hoisted branch will retire them naturally. If D1 hoist is correctly implemented, the 120-min cleanup runs ONCE per hook invocation (not 364 times), so the same existing markers get cleaned up at hour boundaries with no change in semantics — only ~190s of wasted CPU saved per Stop event.

### Sub-step 0.6 — Capture STEP 0.10 baseline (mirror plan-021 + plan-022 sandwich-dev template)

```bash
# Record commit SHA + git status + key file SHAs as immutable baseline
cd "$PROJECT_DIR"
git rev-parse HEAD
git status --short | head -20
for f in scripts/hooks/atomic-write-check.sh \
         scripts/hooks/python-determinism-check.sh \
         scripts/hooks/path-safety-check.sh \
         scripts/hooks/html-separator-check.sh \
         scripts/hooks/bash-hook-lint.sh \
         scripts/hooks/phase-status-coherence.sh; do
  sha=$(sha256sum "$f" 2>/dev/null | cut -d' ' -f1)
  echo "$f: $sha"
done
```

**Record in session log**: All SHAs + commit SHA. F4 carry-forward from plan-021 dispatch-template-improvement — sandwich-dev MUST capture STEP 0.10 verbatim per S341 D7 template update.

---

## § E. Architecture Decisions (DD-1 through DD-7)

### DD-1: Hoist-vs-batch — single hoisted `find ... -delete` per hook init? Or pre-build a marker-cache hash and lookup?

**PICK**: Hoist single `find ... -delete` per hook init (matches observation's P1 directly).

**Rationale**: Simplest possible fix that captures the full ~190s savings. Pre-building a marker-cache hash with file-path keys would shave another ~50ms per hook but adds ~30 LOC of cache-management code; not worth it at quick-win-tier. Reserve cache-based approaches for plan-027b (A1 4-hook consolidation; if 4 hooks merge into 1, ONE cache serves all).

**Implementation pattern** (sandwich-dev applies to all 4 hooks — verify per-hook marker prefix per STEP 0.2 finding):

```bash
# REMOVE from claim_file_slot() body:
#   find "$MEM_DIR" -maxdepth 1 -name '.${prefix}-marker-*' -mmin +120 -delete 2>/dev/null || true

# ADD before the SCAN_FILES loop (after STDIN_PAYLOAD parse, before the `for f in "${SCAN_FILES[@]}"; do scan_file "$f"; done` block):
# === D1: Hoisted marker cleanup (S346 plan-023 P1) — runs ONCE per hook invocation
# instead of ONCE per scanned file. Observation 2026-05-16 § Root cause: with 364 files
# × 1289 entries = ~469K dir entry checks per hook per Stop event; hoisting reduces to
# 1289 entries × 1 invocation. ~50s → ~1-2s per hook.
find "$MEM_DIR" -maxdepth 1 -name '.${prefix}-marker-*' -mmin +120 -delete 2>/dev/null || true
```

Then `claim_file_slot()` body becomes just the atomic noclobber claim (lines 151-155 in atomic-write-check.sh, analogous in others).

### DD-2: Cool-down marker name — per-hook OR shared?

**PICK**: Per-hook marker names (no cross-hook coupling).

**Rationale**: Safer; if one hook is patched/changed/disabled in isolation, its cool-down marker doesn't accidentally suppress sibling hooks. Cross-hook coupling violates Karpathy P3 (surgical changes — each hook owns its own state).

**Per-hook marker filenames**:
- `atomic-write-check.sh` → `$MEM_DIR/.aw-last-full-sweep`
- `python-determinism-check.sh` → `$MEM_DIR/.pydet-last-full-sweep`
- `path-safety-check.sh` → `$MEM_DIR/.psafety-last-full-sweep`
- `html-separator-check.sh` → `$MEM_DIR/.htmlsep-last-full-sweep`

Each marker is a plain `touch`-able file; D-062 atomic-write-doctrine compliance via the existing noclobber pattern OR a `touch` call (touch is intrinsically atomic in POSIX; mtime-update is the only operation needed for cool-down read; no content matters).

### DD-3: Cool-down duration — 600s (10min) fixed OR adaptive?

**PICK**: 600s fixed (debounce-friendly; matches observation P2 recommendation).

**Rationale**: Adaptive cool-down (e.g., back off if sweep recently triggered violations, shorten if it didn't) introduces second-order complexity for marginal benefit. 600s is conservative — covers typical autonomous-mode rapid-cycling burst (multiple Stop events within 5-min keep-alive window) while ensuring violations surface within 10 min of being introduced. Acceptable per AQ-7: PostToolUse path remains active for per-file violations introduced mid-cool-down (the Stop-mode cool-down only suppresses the redundant full-tree audit; not the per-file PostToolUse audit).

**Implementation pattern** (sandwich-dev applies to all 4 hooks, AFTER the hoisted marker-cleanup from DD-1, BEFORE the SCAN_FILES population block):

```bash
# === D2: Stop-mode cool-down (S346 plan-023 P2) — early-exit if last full sweep ≤ 600s ago.
# Only applies when SCAN_FILES is empty after STDIN_PAYLOAD parse (i.e., Stop-mode full-tree audit).
# PostToolUse single-file audits are unaffected (SCAN_FILES already populated from EDITED_FILE).
COOLDOWN_MARKER="$MEM_DIR/.${prefix}-last-full-sweep"
COOLDOWN_S=600
# Detect Stop-mode = STDIN_PAYLOAD empty AND no EDITED_FILE captured from JSON parse
if [ -z "${EDITED_FILE:-}" ] && [ -f "$COOLDOWN_MARKER" ]; then
  age_s=$(( $(date +%s) - $(stat -c %Y "$COOLDOWN_MARKER" 2>/dev/null || stat -f %m "$COOLDOWN_MARKER" 2>/dev/null || echo 0) ))
  if [ "$age_s" -lt "$COOLDOWN_S" ]; then
    printf '[%s] %s-check: SKIP-COOLDOWN (last full sweep %ds ago, threshold %ds)\n' \
      "$TS" "${prefix}" "$age_s" "$COOLDOWN_S" >> "$LOG"
    exit 0
  fi
fi
# (then SCAN_FILES population block runs; at end-of-scan, touch the cool-down marker)
# At end-of-script (right before `exit 0`), add:
if [ "${#SCAN_FILES[@]}" -gt 100 ]; then
  # Heuristic: full-tree sweep populates SCAN_FILES with 100+ files
  touch "$COOLDOWN_MARKER" 2>/dev/null || true
fi
```

The `>100 files` heuristic distinguishes "full-tree Stop sweep" (touches marker) from "PostToolUse 1-file edit" (doesn't touch marker; preserves cool-down for legitimate full sweep). Threshold chosen because typical edited-file Stop event passes 1-3 files via stdin; full-tree sweep passes 300+.

### DD-4: bash-hook-lint fix — parallelize OR early-exit OR cron-migration?

**PICK**: STEP 0.3 finding dictates. Architect's expected pick (priority order, based on observation hypothesis): **per-file content-hash early-exit (cache by sha256)**.

**Rationale** (gated on STEP 0.3):

| Option | Mechanism | Expected wall | Pro | Con | Verdict gate |
|---|---|---:|---|---|---|
| (a) **Content-hash early-exit** (cache by sha256 per hook file) | At top of each `for f in "$HOOKS_DIR"/*.sh; do` loop, compute sha256 of $f content; if cached as `.bhl-cache-{sha256}.ok`, `continue` | ~3-5s warm-cache | Surgical; preserves all 10 checks' semantics; only re-scans changed hooks | Adds ~30 LOC; cache dir grows but is hour-bucket-cleanable | **PICK if STEP 0.3 shows multi-pattern × 108 hooks is the bottleneck (architect expectation)** |
| (b) **xargs -P 4 parallelization** of the 10 per-hook checks | Wrap each `for f in "$HOOKS_DIR"/*.sh` block with `printf '%s\n' "$HOOKS_DIR"/*.sh \| xargs -P 4 -I{} bash -c '...'` | ~15-20s | Cheap on cores; minimal logic change | Introduces non-deterministic test order; emit logging may interleave; harder to debug | DEFER to plan-027a unless (a) infeasible |
| (c) **Single-check isolation + tightening** | If STEP 0.3 identifies ONE specific check (e.g., Check 7 or 9 awk catastrophic-backtrack), tighten THAT check's regex | ~30s (other 9 checks unchanged) | Surgical at root cause | May miss if multiple checks contribute | PICK if STEP 0.3 finds single-check root cause |
| (d) **Wall-budget kill switch + cron migration documentation** | Add `timeout 30s` wrapper to bash-hook-lint; document A3 cron-migration as plan-027d trigger | ~30s capped | Worst-case safe | Doesn't actually fix; surfaces problem to user via incomplete results | LAST RESORT if (a)+(b)+(c) all infeasible within budget |

**Companion**: D3 ALWAYS surfaces (in observation) any hook file that consistently triggers a specific check; that file is a candidate for plan-027a deeper investigation.

### DD-5: phase-status-coherence regex — extend regex only OR extend regex + letter→numeric mapping?

**PICK**: Extend regex AND add letter→numeric mapping table.

**Rationale**: Regex-only extension would capture "D" or "F-prime" but Check (A) at lines 107-111 currently compares against IN_PROGRESS_PHASES (numeric list from project.md row 4). Without a mapping table, the comparison `echo "$IN_PROGRESS_PHASES" | grep -qE "^${LATEST_PHASE}$"` would fail for `LATEST_PHASE=D` (because project.md doesn't have a row `| D — ...`). The mapping table resolves D→4 (since Phase D is a Wave 1 sub-decomposition of Phase 4 per project.md row 4 + current-execution.md narrative).

**Implementation pattern** (D4 sub-track; sandwich-dev applies to `phase-status-coherence.sh`):

```bash
# REPLACE line 84:
# OLD: LATEST_PHASE=$(echo "$LATEST_HEADER" | sed -E 's/^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase[[:space:]]+([0-9]+(\.[0-9]+)?).*/\1/')
# NEW (regex extension):
LATEST_PHASE=$(echo "$LATEST_HEADER" | sed -E 's/^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase[[:space:]]+([0-9]+(\.[0-9]+)?|[A-Z](-prime)?).*/\1/')

# ADD after line 84 (mapping table — resolves letter phases to their parent numeric Phase row):
# === D4: Wave 1 letter-phase → numeric mapping (per project.md row 4 sub-decomposition)
# Phase A/B/C/D/E/F-prime/G-prime/H-prime are Wave 1 themes within project.md Phase 4
# IN PROGRESS row. Map them so the IN_PROGRESS_PHASES grep at line 108 matches.
# If new letter phases are added to Wave 1 OR Wave 2 introduces a new scheme,
# extend this table OR consider a more general per-project.md letter-row schema.
case "$LATEST_PHASE" in
  A|B|C|D|E) LATEST_PHASE_RESOLVED=4 ;;
  F-prime|G-prime|H-prime) LATEST_PHASE_RESOLVED=4 ;;
  *) LATEST_PHASE_RESOLVED="$LATEST_PHASE" ;;  # numeric phases pass through
esac

# Then REPLACE the comparison at line 108:
# OLD: if echo "$IN_PROGRESS_PHASES" | grep -qE "^${LATEST_PHASE}$"; then
# NEW (uses resolved):
if echo "$IN_PROGRESS_PHASES" | grep -qE "^${LATEST_PHASE_RESOLVED}$"; then
```

The mapping is conservative: only known Wave 1 letter phases map to Phase 4. Future Wave 2 (e.g., Phase X/Y/Z under Phase 5 Compounding) would extend the case. AP-7 follow-up trigger: when first Wave 2 letter-phase header lands, edit the case statement to add the new mapping (this is acceptable maintenance debt per RM8).

**Cleanup of S343-S344 surgical workaround**: Once D4 lands and is green, sandwich-dev edits `current-execution.md:135` to remove the "Naming note (harness regex compatibility): header explicitly prefixed 'Phase 4 —' so ..." parenthetical (Phase D is now the canonical header form; the regex handles it natively).

### DD-6: Migration of legacy .severity-state.tsv columns

**N/A this plan**. This plan does NOT touch .severity-state.tsv schema; that's plan-024 territory if ever pursued. Architect explicitly excludes this from scope per § C.

### DD-7: Fire-test strategy — per-hook OR shared?

**PICK**: Per-hook fire-tests (for clarity); 5 NEW fire-tests at minimum.

**Rationale**: Each affected hook's existing fire-test grows by 2 TCs (TC-HOISTED-AND-NO-FIND-IN-LOOP + TC-COOLDOWN-SKIPS-IF-RECENT-SWEEP). Plus 1 NEW fire-test for phase-status-coherence (it doesn't have one today per Glob 2026-05-16). Total: 4 fire-test extensions + 1 NEW = 5 fire-test deliverables.

**Per-hook TC-HOISTED test pattern** (sandwich-dev applies to all 4):
- Create a sandbox with 50 stale `.{prefix}-marker-*` files older than 120 min (use `touch -t YYYYMMDDhhmm` to backdate)
- Run hook with 1 fake .py file in SCAN_FILES
- Assert: ALL 50 stale markers gone after run (hoisted cleanup ran ONCE for all 50)
- Assert: the 1-file scan still produced its marker (claim_file_slot still works)
- Assert: `find ... -delete` does NOT appear in the per-file `claim_file_slot()` body (grep the hook source — meta-test)

**Per-hook TC-COOLDOWN test pattern**:
- Create `.{prefix}-last-full-sweep` marker with current mtime
- Run hook with empty stdin (Stop mode) + 0 EDITED_FILE
- Assert: hook RC=0 + log line "SKIP-COOLDOWN" emitted
- Touch marker to 700s ago + re-run
- Assert: hook performs full sweep (no SKIP-COOLDOWN log line; sweep evidence in log)

**NEW phase-status-coherence fire-test pattern** (~150 LOC):
- TC01: numeric phase header "## S100 — Phase 4 — ..." + project.md has Phase 4 IN PROGRESS → match
- TC02: letter phase header "## S343 — Phase D — ..." + project.md has Phase 4 IN PROGRESS → match (via mapping)
- TC03: letter phase header "## S400 — Phase F-prime — ..." → match (mapping covers -prime suffix)
- TC04: unknown letter "## S500 — Phase Z — ..." → no match (default branch); STATE remains GREEN or transitions per Check C
- TC05: project.md has 0 IN PROGRESS rows → STATE YELLOW (Check C)
- TC06: 3 new ADRs in decisions/ + CE_PROJ_DELTA_HR > 24 → STATE YELLOW (Check B)
- TC07: 2nd fire within cache window (5 min) → CACHE-HIT, no re-process

---

## § F. Sub-track decomposition (D1..D6)

Order optimized to minimize blast radius: D4 first (smallest blast; standalone regex fix; can ship even if D1+D2 stall), D1+D2 paired (must ship together — D2's `>100 files` heuristic depends on D1's hoisted cleanup running first so `SCAN_FILES` is fully populated), D3 third (largest unknown; STEP 0.3 dictates scope), D5+D6 last (fire-tests + dogfood verification).

### D1. Hoist marker-cleanup in 4 .py-scan hooks

**Files modified**: `scripts/hooks/atomic-write-check.sh` + `scripts/hooks/python-determinism-check.sh` + `scripts/hooks/path-safety-check.sh` + `scripts/hooks/html-separator-check.sh`

**LOC delta**: ~ -4 LOC × 4 hooks (delete from claim_file_slot) + ~3 LOC × 4 hooks (hoisted block before scan loop) = ~ -4 LOC net per hook (minor cleanup-comment expansion offsets).

**Per-hook diff target locations** (from STEP 0.2 verification):
- `atomic-write-check.sh:149` (DELETE find inside claim_file_slot) + insert hoisted block before line 194 (BEFORE `if [ "${#SCAN_FILES[@]}" -eq 0 ]; then` for clarity, OR right after STDIN_PAYLOAD parse at line 163)
- `python-determinism-check.sh:69` (DELETE find) + insert hoisted block before line 110
- `path-safety-check.sh:165` (DELETE find) + insert hoisted block before line 200
- `html-separator-check.sh:86` (DELETE find) + insert hoisted block before line 134

**Verification at S346 IMPL** (sandwich-dev MUST):
- Re-time each hook empirically (mirror STEP 0.1 pattern). Target: ≤5s per hook (was ~50s for 3 of them; 22s for html-separator).
- Run companion fire-tests: TC-HOISTED + TC-COOLDOWN + existing regression TCs (atomic-write-check has 15 TCs; python-determinism has 12; path-safety has [TBD via STEP 0]; html-separator has [TBD via STEP 0]).
- Verify markers behavior: full-tree sweep still creates per-file markers (claim_file_slot atomic noclobber unchanged); stale markers >120 min still get deleted (hoisted find runs ONCE per invocation).

### D2. Stop-mode cool-down marker + early-exit

**Files modified**: SAME 4 hooks as D1 (paired-commit recommended — cool-down logic depends on hoisted-cleanup placement to share the `SCAN_FILES` population timing).

**LOC delta**: ~ +10 LOC per hook (cool-down check block before SCAN_FILES population + touch at end-of-script gated on >100 files) = ~40 LOC total.

**Per-hook diff target locations**:
- Insert cool-down check block AFTER `STDIN_PAYLOAD="$(cat 2>/dev/null || true)"` + EDITED_FILE parse (so we know if it's PostToolUse vs Stop), BEFORE the `if [ "${#SCAN_FILES[@]}" -eq 0 ]; then` block (which populates SCAN_FILES for Stop mode)
- Insert `touch "$COOLDOWN_MARKER"` AT END of script, gated on `[ "${#SCAN_FILES[@]}" -gt 100 ]` heuristic, just before `exit 0`

**Verification at S346 IMPL**:
- Run hook with empty stdin twice in succession (≤10s apart). Assert second run logs SKIP-COOLDOWN.
- Wait 700s (or `touch -d '11 min ago'` the cool-down marker). Re-run; assert full sweep runs (no SKIP-COOLDOWN).
- Run hook with PostToolUse JSON stdin (EDITED_FILE captured) with cool-down marker fresh. Assert: PostToolUse single-file audit still runs (not suppressed).

### D3. bash-hook-lint diagnose + minimum fix

**Files modified**: `scripts/hooks/bash-hook-lint.sh` (per STEP 0.3 finding; scope adaptive per DD-4).

**LOC delta**: STEP 0.3 finding dictates. Architect expectation: ~30-50 LOC (content-hash early-exit block at top of each `for f in "$HOOKS_DIR"/*.sh; do` loop + cache cleanup at hour-bucket boundaries).

**STEP 0.3 finding-dependent action**:
- If multi-pattern × 108 hooks dominates (DD-4 PICK = a): add content-hash early-exit to each of 10 checks
- If single-check catastrophic-backtrack (DD-4 PICK = c): tighten THAT specific regex
- If mutex/deadlock (DD-4 PICK = b): xargs -P 4 parallelization
- If unsolved (DD-4 PICK = d): wall-budget kill switch + plan-027a documentation

**Verification at S346 IMPL**:
- Re-time bash-hook-lint empirically. Target: ≤30s (was >60s).
- Run companion fire-test (16 existing TCs per S322 calibration). Target: 16/16 still PASS.
- If content-hash early-exit picked: verify cache dir doesn't grow unboundedly (hour-bucket cleanup invocation).

### D4. phase-status-coherence regex fix

**Files modified**: `scripts/hooks/phase-status-coherence.sh` (~10 LOC change) + `current-execution.md:135` (1-paragraph removal of surgical workaround note).

**Files created**: `scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh` (NEW; ~150 LOC; 7 TCs per DD-7).

**LOC delta**: +10 LOC in hook + 150 LOC NEW fire-test + -1 paragraph in current-execution.md = ~160 LOC net.

**Per-line diff target locations**:
- `phase-status-coherence.sh:84` REPLACE with extended regex (per DD-5 implementation pattern)
- `phase-status-coherence.sh:84+` INSERT case-mapping block (per DD-5 implementation pattern)
- `phase-status-coherence.sh:108` REPLACE comparison to use `$LATEST_PHASE_RESOLVED`
- `current-execution.md:135` REMOVE the parenthetical "Naming note (harness regex compatibility): header explicitly prefixed 'Phase 4 —' ..."

**Verification at S346 IMPL**:
- Run new fire-test (7 TCs). Target: 7/7 PASS.
- Manual sanity: run hook against current-execution.md as-is + project.md. Assert STATE=GREEN (no false-positive RED HIGH for the most recent S343-S344 row).
- Manual sanity: forge a temp current-execution.md with the OLD bare "Phase D —" header (no surgical prefix) + run hook. Assert STATE=GREEN (the bug is now fixed; bare Phase D matches).

### D5. Fire-tests (5 NEW + existing regression verification)

**Files modified**: `scripts/hooks/firing-tests/atomic-write-check-fire-test.sh` (extend with TC-HOISTED + TC-COOLDOWN; +60 LOC), `scripts/hooks/firing-tests/python-determinism-check-fire-test.sh` (same; +60 LOC), `scripts/hooks/firing-tests/path-safety-check-fire-test.sh` (same; +60 LOC), `scripts/hooks/firing-tests/html-separator-check-fire-test.sh` (same; +60 LOC), `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` (extend if D3 changed logic; +30-50 LOC).

**Files created**: `scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh` (NEW from D4 above; ~150 LOC; 7 TCs).

**LOC delta**: ~+280 LOC (4 × +60 + 1 × +40 + 1 × +0 if D3 was content-hash early-exit and doesn't need new TC).

**Per-fire-test extension pattern** (sandwich-dev MUST):
- Use existing `pass_tc` + `fail_tc` + sandbox-tmpdir scaffold (per atomic-write-check-fire-test.sh pattern; see fire-test file referenced in `depends_on`)
- TC-HOISTED tests: stage 50 stale markers, run hook, assert all 50 gone + sandbox marker present + per-file `claim_file_slot` no longer contains find
- TC-COOLDOWN tests: stage cool-down marker, run hook, assert SKIP-COOLDOWN log line; backdate marker, re-run, assert full sweep

**Verification at S346 IMPL**:
- Run all 5 affected fire-tests. Target: ALL PASS.
- Run remaining ~45 fire-tests in `scripts/hooks/firing-tests/`. Target: ALL still PASS (regression floor; ≥80 TCs combined).

### D6. Empirical re-measurement (dogfood verification)

**Files modified**: NONE (read-only audit + observation write).

**LOC delta**: 0 (no patches; only measurement).

**Methodology**:
1. Pre-patch baseline (captured in STEP 0.1 for atomic-write-check + STEP 0.3 for bash-hook-lint; capture remaining 3 of the 4 .py-scan hooks + 2-3 sample non-affected hooks for sanity)
2. Apply D1+D2+D3+D4 patches; commit; run `bash scripts/hooks/firing-tests/*-fire-test.sh` regression
3. Post-patch re-measurement (single Stop simulation; record per-hook wall ms; sum to compute total chain wall)
4. Pre-vs-post comparison table written into observation file + session log

**Target metrics** (per DC-PERF section of § H):
- DC-PERF-1: total Stop chain wall ≤ 30s (vs ~5.3min current; 90% reduction)
- DC-PERF-2: bash-hook-lint runs to completion within 30s (vs >60s timeout)
- DC-PERF-3: 4 .py-scan hooks each <5s wall (vs 22-55s each currently)
- Additional: phase-status-coherence STATE=GREEN for current S343-S344 row (vs silent false-positive RED HIGH per pre-patch behavior)

---

## § G. Architecture Questions (AQ-1..AQ-8) — pre-answered

### AQ-1: If STEP 0.3 finds bash-hook-lint timeout is regex-driven not file-walk-driven → what then?

**Answer**: Surface root cause in observation; recommend `xargs -P 4 parallelization` as plan-027a successor candidate; ship the SMALLEST fix in this session that gets bash-hook-lint under 30s (likely content-hash early-exit per DD-4 (a) — surgical even if root cause is regex-bound; cached hooks SKIP the regex check). Document in DC-CARRY-1 the deferred work. DO NOT attempt full parallelization in this session — that's plan-027a scope.

### AQ-2: If STEP 0.4 finds phase-status hook is actually doing something else slow → what then?

**Answer**: Scope-creep guard. Surface the orthogonal slowness in observation as a NEW harness anomaly candidate; ship the D4 regex fix ANYWAY (it's correct + low-risk + closes the false-positive RED HIGH); defer the orthogonal perf side-fixes to plan-024+ harness backlog.

### AQ-3: If cool-down marker collides with something at same path → what?

**Answer**: Architect verified the 4 chosen marker names (`.aw-last-full-sweep`, `.pydet-last-full-sweep`, `.psafety-last-full-sweep`, `.htmlsep-last-full-sweep`) do not collide with any existing file under `agent-workspace/memory/` (Glob-check done before plan finalization; STEP 0.5 reconfirms at IMPL time). If sandwich-dev discovers a collision: rename per-hook marker with a `-S346` suffix (e.g., `.aw-last-full-sweep-S346`), document in DC-CARRY-2, flag for AP-23 1st instance.

### AQ-4: After patch, Stop chain still >30s due to a 6th unsuspected hook → what?

**Answer**: Re-time + name the suspect in observation; that's a plan-027 candidate (likely plan-027f if all of A1-A4 don't cover it). NOT blocking this plan's ship — the Goal is "≤30s Stop chain" so if D1+D2+D3 reduce the 4-hook + bash-hook-lint cost from ~275s to ~10s as expected, the remaining 47 hooks contributing 30-60s collectively become the bottleneck (and per observation those are "fine to keep but consolidate redundant pairs" — A2/A4 work). Document the gap; this plan's DC-PERF-1 ≤30s target is still met IF those 47 hooks total <20s; if not, the gap is the next plan's scope.

### AQ-5: Migration concern — existing .aw-marker-* files 363 entries: keep or pre-clean?

**Answer**: Keep — hour-bucket aging will retire them in 2hrs naturally via the SAME 120-min `-mmin +120 -delete` rule that's being hoisted. The hoisted location runs the same logic, just ONCE per hook invocation instead of 364 times. Existing markers continue to be cleaned at hour boundaries. No migration work needed.

### AQ-6: project.md needs letter-phase rows for full regex coverage?

**Answer**: No. The mapping table in `phase-status-coherence.sh` resolves D→4 (since Phase D is a Wave 1 sub-decomposition of Phase 4 per project.md row 4 + current-execution.md narrative). project.md `Phase Goals Tracker` table stays numeric (its semantics are "top-level phases"). Adding letter rows would conflate "top-level Phase tracker" with "Wave sub-decomposition state" — those belong in current-execution.md narrative, not project.md tracker.

### AQ-7: Tests/regression — any chance the cool-down skips a real violation?

**Answer**: Yes, for ≤10min repeat-Stop bursts the Stop-mode full-tree audit IS suppressed. This is ACCEPTABLE because:
1. PostToolUse path (per-file edit) remains active — every Edit/Write/MultiEdit operation triggers single-file audit (NOT cool-down-gated; SCAN_FILES populated from EDITED_FILE → cool-down check doesn't activate)
2. The full-tree Stop sweep is INFORMATIONAL (it just refreshes the notification file); violations introduced during cool-down still surface within 10 min when next full sweep runs
3. The 600s window aligns with autonomous-mode keep-alive cadence (multiple Stop events typically cluster within 5-10 min) — exactly the case the cool-down should suppress

**Risk mitigation** (per RM1): document this behavior in hook header comments + fire-test asserts PostToolUse path bypasses cool-down.

### AQ-8: Should I propose ADR D-067?

**Answer**: NO. This is patch-tier work (perf optimization on existing hooks), not architectural decision (no new contract, no new file, no boundary change). Comment in code suffices (header docstring updated per DD-1/DD-2 patterns above). If sandwich-dev disagrees at IMPL time, surface rationale in observation; main session can decide ADR D-067 PROPOSED at next close if dev case is strong.

---

## § H. DoD checklist (28 items minimum; covers FILE/LOC/IMPL/PERF/COMPLIANCE/SMOKE/BOOK groups)

### Files (DC-FILE-*)

- **DC-FILE-1**: `scripts/hooks/atomic-write-check.sh` modified — find-delete moved out of `claim_file_slot()` body; hoisted block added before SCAN_FILES population; cool-down check + touch added
- **DC-FILE-2**: `scripts/hooks/python-determinism-check.sh` modified — same pattern as DC-FILE-1
- **DC-FILE-3**: `scripts/hooks/path-safety-check.sh` modified — same pattern as DC-FILE-1
- **DC-FILE-4**: `scripts/hooks/html-separator-check.sh` modified — same pattern as DC-FILE-1
- **DC-FILE-5**: `scripts/hooks/bash-hook-lint.sh` modified — D3 fix per STEP 0.3 finding (DD-4 PICK)
- **DC-FILE-6**: `scripts/hooks/phase-status-coherence.sh` modified — regex extended + mapping table added
- **DC-FILE-7**: `scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh` CREATED — 7 TCs per DD-7
- **DC-FILE-8**: 4 existing fire-tests extended (atomic-write/python-determinism/path-safety/html-separator) with TC-HOISTED + TC-COOLDOWN
- **DC-FILE-9**: `agent-workspace/memory/current-execution.md:135` modified — surgical workaround note removed
- **DC-FILE-10**: `agent-workspace/memory/sessions/session-S346.md` CREATED per CLAUDE.md § Session Protocol End
- **DC-FILE-11**: `agent-workspace/memory/observations/sandwich-dev-S346-stop-hook-perf.md` CREATED per S341 D7 + plan-021 § F findings (sandwich-dev observation file required; ~150-200 LOC)

### Lines of code (DC-LOC-*)

- **DC-LOC-1**: D1 net delta -4 LOC × 4 hooks = -16 LOC (hoist net cleanup)
- **DC-LOC-2**: D2 net delta +10 LOC × 4 hooks = +40 LOC (cool-down logic)
- **DC-LOC-3**: D3 net delta per DD-4 PICK (architect expectation +30-50 LOC for content-hash early-exit)
- **DC-LOC-4**: D4 net delta +10 LOC in hook + 150 LOC NEW fire-test + -1 paragraph current-execution.md = ~160 LOC
- **DC-LOC-5**: D5 net delta ~+280 LOC across 4 existing fire-tests + ~+30-50 LOC bash-hook-lint fire-test if D3 changed logic
- **DC-LOC-TOTAL**: ~+500-550 LOC across 11 files (most in NEW fire-test files)

### Implementation correctness (DC-IMPL-*)

- **DC-IMPL-1**: Per-file `claim_file_slot()` body in 4 hooks no longer contains `find ... -delete` (grep verification)
- **DC-IMPL-2**: Hoisted `find ... -delete` runs ONCE per hook invocation (grep verification — count of find-delete instances = 1)
- **DC-IMPL-3**: Cool-down marker write gated on `[ "${#SCAN_FILES[@]}" -gt 100 ]` (NOT touched on PostToolUse 1-file audits)
- **DC-IMPL-4**: Cool-down check skipped when SCAN_FILES has EDITED_FILE from stdin (PostToolUse path always active)
- **DC-IMPL-5**: bash-hook-lint fix (per DD-4 PICK) preserves all 10 checks' semantics — output identical for dirty fixtures
- **DC-IMPL-6**: phase-status-coherence regex extension captures both numeric (`4`, `3.5`) AND letter (`D`, `F-prime`) forms
- **DC-IMPL-7**: phase-status-coherence mapping table resolves D|A|B|C|E → 4; F-prime|G-prime|H-prime → 4; numeric pass-through unchanged
- **DC-IMPL-8**: S343-S344 row in current-execution.md no longer contains the "(harness regex compatibility)" parenthetical
- **DC-IMPL-9**: All inserted comments cite "S346 plan-023" provenance per I-S2 source-citation discipline

### Performance (DC-PERF-*)

- **DC-PERF-1**: Empirical post-patch Stop chain wall ≤ 30s (vs current ~5.3min — 90% reduction)
- **DC-PERF-2**: bash-hook-lint runs to completion within 30s (vs >60s timeout currently)
- **DC-PERF-3**: 4 .py-scan hooks each <5s wall in steady state (warm-cool-down OR no-violation scenarios)
- **DC-PERF-4**: 4 .py-scan hooks combined ≤10s wall on first-run-after-cool-down expiry (vs ~190s currently)
- **DC-PERF-5**: phase-status-coherence STATE=GREEN for current S343-S344 row post-patch (was silently false-positive RED HIGH pre-patch)

### Compliance (DC-COMPLIANCE-*)

- **DC-COMPLIANCE-1**: 0 charter writes (PROJECT_CHARTER.md untouched — grep-verify diff)
- **DC-COMPLIANCE-2**: 0 constitution writes (`agent-workspace/constitution/**` untouched — grep-verify diff)
- **DC-COMPLIANCE-3**: 0 human-workspace writes outside of legitimate D6 dogfood (notifications/* may be regenerated by hook execution during verification; this is the hook's existing behavior, NOT a plan-introduced write)
- **DC-COMPLIANCE-4**: D-060 honored — sandwich-dev commits own work; 0 git pushes
- **DC-COMPLIANCE-5**: Karpathy P3 surgical — every diff line traces to D1/D2/D3/D4/D5/D6 sub-track scope (grep-verify dev's diff against this plan's coordination paths § J)
- **DC-COMPLIANCE-6**: I-S2 source-citation discipline — every plan claim cites file:line (this plan has done so; sandwich-dev preserves comments in code)

### Smoke + regression (DC-SMOKE-*)

- **DC-SMOKE-1**: All 5 affected fire-tests PASS (5 NEW or extended) — recorded as TC counts in session log
- **DC-SMOKE-2**: Remaining ~45 fire-tests in `scripts/hooks/firing-tests/` ALL still PASS (regression floor; baseline established via `bash scripts/hooks/firing-tests/*-fire-test.sh` pre-patch + post-patch comparison)
- **DC-SMOKE-3**: Full pytest suite still green (no Python test introduces — this is hook-tier work; pytest delta = 0)
- **DC-SMOKE-4**: mypy --strict still passes (no Python file changed)
- **DC-SMOKE-5**: ruff still passes (no Python file changed)
- **DC-SMOKE-6**: bash-hook-lint.sh runs against own modifications with 0 violations (dogfood meta-check)

### Bookkeeping (DC-BOOK-*)

- **DC-BOOK-1**: Plan moved `pending/` → `completed/` via `git mv` post-IMPL + verifier sign-off
- **DC-BOOK-2**: current-execution.md S346 row prepended with PLAN-IMPL-VERIFY narrative + STEP 0 findings + D1-D6 status
- **DC-BOOK-3**: latest.md rewritten as S346 CLOSE handoff
- **DC-BOOK-4**: agent-notes.md digest extended with any new learned rule (e.g., "Per-file find scans on large $MEM_DIR are Windows-punitive; hoist before per-file loop or use content-hash early-exit")
- **DC-BOOK-5**: mistake-log.md updated with M-S346-* entries OR explicit "no mistakes this session" per session-end-checklist-linter
- **DC-BOOK-6**: Observation file at `agent-workspace/memory/observations/sandwich-dev-S346-stop-hook-perf.md` created (~150-200 LOC; mirrors plan-020/021/022 dev observation cadence)

---

## § I. 5-source-evidence chain

The empirical patches are at root the observation file's empirical timing. Architect did not introduce new source-evidence; this plan stands on the observation's chain. The observation cited:
1. `.claude/settings.json:315-524` (51-hook Stop chain composition)
2. `scripts/hooks/atomic-write-check.sh:146-156` (representative claim_file_slot pattern)
3. `scripts/hooks/python-determinism-check.sh:66-76` (peer pattern)
4. `scripts/hooks/path-safety-check.sh:163-171` (peer pattern)
5. `scripts/hooks/html-separator-check.sh:84-92` (peer pattern)
6. `scripts/hooks/bash-hook-lint.sh:44-491` (10-check structure for D3 root-cause investigation)
7. `agent-workspace/memory/.aw-marker-*` directory state at 2026-05-16T18:50 (1289-entry baseline)

For D4 regex fix, this plan adds:
8. `scripts/hooks/phase-status-coherence.sh:84` (numeric-only regex per architect VBW Read 2026-05-16)
9. `agent-workspace/memory/current-execution.md:135` (S343-S344 surgical workaround documenting the limitation — natural-language evidence of the silent false-positive over S323-S342)

External / Windows file-system performance docs are NOT cited; they're not load-bearing. The empirical 469K-dir-check finding from observation suffices.

---

## § J. Coordination paths (S346 dev coordination boundary)

### Files sandwich-dev MAY modify (in-scope for this plan)

- `scripts/hooks/atomic-write-check.sh`
- `scripts/hooks/python-determinism-check.sh`
- `scripts/hooks/path-safety-check.sh`
- `scripts/hooks/html-separator-check.sh`
- `scripts/hooks/bash-hook-lint.sh`
- `scripts/hooks/phase-status-coherence.sh`
- `scripts/hooks/firing-tests/atomic-write-check-fire-test.sh`
- `scripts/hooks/firing-tests/python-determinism-check-fire-test.sh`
- `scripts/hooks/firing-tests/path-safety-check-fire-test.sh`
- `scripts/hooks/firing-tests/html-separator-check-fire-test.sh`
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` (only if D3 changes lint logic)
- `scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh` (NEW)
- `agent-workspace/memory/current-execution.md` (S346 row + remove S343-S344 surgical workaround note)
- `agent-workspace/memory/sessions/session-S346.md` (NEW)
- `agent-workspace/memory/observations/sandwich-dev-S346-stop-hook-perf.md` (NEW)
- `agent-workspace/memory/agent-notes.md` (digest extension if new learned rule)
- `agent-workspace/memory/mistake-log.md` (M-S346-* entries OR "no mistakes" attestation)
- `agent-workspace/memory/checkpoints/latest.md` (S346 close handoff)
- `agent-workspace/session-plans/pending/023-S346-stop-hook-perf-quick-wins.md` → `completed/` via git mv at close

### Files sandwich-dev MUST NOT modify (off-limits — out-of-scope)

- `.claude/settings.json` (Stop chain ordering = A4 deferred to plan-027e)
- `PROJECT_CHARTER.md` (charter immutable per CLAUDE.md hard rules)
- `agent-workspace/constitution/**` (constitution immutable absent explicit human approval)
- `agent-workspace/memory/project.md` (no Phase Goals Tracker schema change per AQ-6)
- Any of the other 47 Stop chain hooks not listed above (not in scope; ship D1+D2+D3+D4 only)
- Any Python file under `packages/` or `apps/` (this is hook-tier work)
- `obsidian-vault/raw/**` (immutable)
- `human-workspace/notifications/**` (writes during D6 dogfood happen NATURALLY via the hook running — sandwich-dev MUST NOT explicitly write here as part of the patch itself; only the hook's existing notification-regen behavior is permitted)

---

## § K. Budget recommendation

**Recommended**: 80-120K Opus FOCUSED_IMPL (single dev session).

**Rationale**:
- Patch surgery is bounded (~500-550 LOC across 11 files; most in NEW fire-test code which is mechanical scaffold)
- 6 sub-tracks (D1..D6) but only 3 are non-mechanical (D1+D2+D3); D4 is regex extension + table; D5+D6 are scaffold + measurement
- STEP 0 has 6 sub-steps but most are grep + sed verification (fast); STEP 0.3 is the only one with empirical wallclock cost
- D3's scope is adaptive per DD-4; if STEP 0.3 surfaces deeper root cause, sandwich-dev pauses + flags → bumps to MULTI_TASK budget (150-250K)
- D4's fire-test creation is the largest chunk (~150 LOC NEW); routine bash scaffold

**Sonnet acceptability**:
- Sonnet acceptable IF: STEP 0.3 picks DD-4 (a) content-hash early-exit (simplest case) AND D4 mapping table stays small (≤8 letters covered) AND no STEP 0 STOP-AND-ASK trigger fires
- Opus recommended for: STEP 0.3 ambiguous OR D3 needs awk debugging OR D4 mapping needs more thoughtful structure (Wave 2 forward-compat)

**MULTI_TASK escalation triggers**:
- STEP 0.3 reveals root cause requires plan-027a-equivalent depth (sandwich-dev splits this session via STOP-AND-SPLIT per RM6)
- D4 mapping table grows beyond ~10 letters (suggests project.md schema redesign needed; SURFACE in observation, defer to plan-024+)
- 5 NEW fire-tests reveal latent bugs in the hooks BEYOND the patches (sandwich-dev DOES NOT chase those bugs in this session — surface in observation, defer)

---

## § L. Predecessor + Successor catalog

### Predecessor

- `agent-workspace/memory/observations/2026-05-16-stop-hook-performance-audit.md` — empirical Stop chain ~5.3min diagnostic + P1-P3 quick-win recommendations + A1-A4 architectural deferral; this turn's main session output per user_prompt 20260516_01.txt § 1
- `agent-workspace/memory/current-execution.md:135` — S343-S344 row documenting the surgical "Phase 4 —" prefix workaround applied because phase-status-coherence.sh:84 regex was numeric-only

### Successors (DEFERRED — explicit AP-7 named triggers)

- **plan-027a**: `bash-hook-lint full parallelization` — gated trigger: STEP 0.3 of THIS plan reveals root cause is broader than content-hash early-exit can fix (e.g., catastrophic-backtrack in multiple checks simultaneously). Architect note: if (a) is sufficient, plan-027a stays unscheduled. Successor budget: ~50-80K FOCUSED_IMPL.
- **plan-027b**: `A1 4-hook consolidation` into single `python-quality-batch.sh` — gated trigger: (i) D1+D2 of THIS plan ship green AND (ii) a 2nd independent perf complaint surfaces on the 4-hook chain OR (iii) a 5th .py-scan hook gets added (forcing the question). Successor budget: ~100-150K MULTI_TASK_IMPL (architect+dev sandwich).
- **plan-027c**: `A2 5-log-rotate hook merge` into single `log-rotate-batch.sh` with table-driven config — gated trigger: any rotate hook needs schema change OR a 6th rotate hook is added. Successor budget: ~80-120K FOCUSED_IMPL.
- **plan-027d**: `A3 audit-cron migration` for 6 heavy audit hooks — gated trigger: (i) D3 root-cause finding from THIS plan identifies bash-hook-lint as cron-eligible OR (ii) Stop chain still >30s after D1+D2+D3 ship (i.e., DC-PERF-1 missed). Successor budget: ~100-150K (architect+dev sandwich).
- **plan-027e**: `A4 Stop chain cap at 20 hooks` via consolidation + cron migration — gated trigger: plan-027b + plan-027c + plan-027d all ship. Successor budget: ~50-80K FOCUSED_IMPL (mostly settings.json + ordering review).
- **plan-027f** (contingent): `6th unsuspected slow hook` per AQ-4 — gated trigger: post-S346 re-measurement reveals a hook NOT in this plan's scope is now the bottleneck. Naming follows whichever hook ends up being the suspect.

---

## § M. Risk-Mitigation (RM1..RM8)

### RM1: Cool-down skips real violation

**Risk**: A new violation introduced via a non-Edit/Write tool (e.g., Bash `echo > file.py`) between Stop events within the 10-min cool-down window would NOT trigger a full-tree sweep until next Stop after cool-down expires.

**Likelihood**: LOW — autonomous sessions rarely introduce production .py files via Bash redirect; Edit/Write/MultiEdit are the dominant paths and they ALL trigger PostToolUse single-file audit (which is unaffected by Stop-mode cool-down).

**Mitigation**: PostToolUse per-file path remains active for ALL Edit/Write/MultiEdit invocations. Bash-redirect-to-file is an anti-pattern flagged elsewhere; not a common case. Per AQ-7: 10-min latency is acceptable for the full-tree informational sweep.

**Verification**: Fire-test TC asserts PostToolUse path bypasses cool-down (sandwich-dev MUST include this TC in D5 extension).

### RM2: Hoisted marker-cleanup runs even when no files to scan

**Risk**: If SCAN_FILES is empty after parse (no .py files anywhere), the hoisted `find ... -delete` still runs once — ~50ms wasted.

**Likelihood**: LOW — packages/ and apps/ both have .py files in normal repo state; SCAN_FILES will populate.

**Mitigation**: Acceptable; 50ms is < 1% of saved 200s wall time. No code added to skip the cleanup; simplicity wins per Karpathy P2.

### RM3: bash-hook-lint fix introduces parallelism race

**Risk**: If DD-4 PICK = (b) xargs -P 4 parallelization (low-likelihood per architect expectation but possible per STEP 0.3 finding), per-violation `emit` calls could interleave; counter increment race.

**Likelihood**: LOW per architect expectation (DD-4 default = (a) content-hash; (b) is contingency). If (b) gets picked, race is real.

**Mitigation** (if (b) picked): use `flock` on $LOG when emitting violations, OR collect per-process violation files + concatenate post-xargs. Fire-test asserts deterministic output across 5 consecutive runs.

### RM4: Phase-status regex over-matches (false-positive on literal "Phase X" in markdown text)

**Risk**: Extended regex `Phase ([0-9]+|[A-Z](-prime)?)` could match prose like "Phase 1 was Foundation" or "Phase D will start tomorrow" mid-paragraph.

**Likelihood**: LOW — regex is anchored to `^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase` which requires the start-of-session-header pattern (`## SN — `); prose paragraphs don't start with that.

**Mitigation**: Anchor preservation in DD-5 implementation pattern (the `^## S[0-9]+[a-z]?` prefix in the regex IS preserved). Fire-test TC04 ("unknown letter Z") asserts the case statement defaults gracefully (no false-positive STATE transition).

### RM5: Existing markers conflict with cool-down marker names

**Risk**: One of `.aw-last-full-sweep`, `.pydet-last-full-sweep`, `.psafety-last-full-sweep`, `.htmlsep-last-full-sweep` collides with an existing file.

**Likelihood**: NONE per architect Glob-check (STEP 0.5 reconfirms at IMPL time).

**Mitigation**: Per AQ-3 — rename with `-S346` suffix if collision; flag for AP-23 1st instance.

### RM6: Dev mistakenly attempts A1-A4 during this session

**Risk**: Sandwich-dev sees the 4 hooks share a pattern and proposes consolidation MID-SESSION (scope creep into plan-027b territory).

**Likelihood**: MEDIUM — the temptation is real; the 4 hooks DO share structure.

**Mitigation** (mirror plan-020 RM4 STOP-AND-SPLIT pattern): if dev finds D1 hoist pattern converges into "this should be one function" → SURFACE in observation as plan-027b prerequisite + STOP (do not start consolidation mid-session). Per hard_rules_acknowledged: "no consolidating any of the 4 .py-scan hooks ... into a single batch hook — that's A1 deferred to plan-027b".

### RM7: Empirical re-measurement varies wildly Windows vs WSL

**Risk**: D6 post-patch measurement run on Windows native shell vs WSL gives different wall times; comparison invalid.

**Likelihood**: LOW — STEP 0 baseline captured pre-patch in the SAME env; post-patch measurement uses SAME env per DC-PERF-* methodology.

**Mitigation**: Sandwich-dev records env identifier (output of `uname -a` + bash version) in session log alongside both pre + post measurements. If env shifts mid-session, re-run baseline.

### RM8: Letter-phase mapping table goes stale as new phases added

**Risk**: When Wave 2 introduces new letter phases (e.g., Phase X/Y/Z under Phase 5 Compounding) OR Wave 1 adds a new letter, the mapping table at `phase-status-coherence.sh` DD-5 doesn't recognize them.

**Likelihood**: MEDIUM-LONG-TERM — Wave 1 letters A-H-prime are the current set; Wave 2+ is months away.

**Mitigation** (per DD-5 implementation pattern): inline comment explaining maintenance ("If new letter phases are added to Wave 1 OR Wave 2 introduces a new scheme, extend this table OR consider a more general per-project.md letter-row schema."). Item-3 planner-upgrade observation (from this turn's main session deliverable) recommends a planner that auto-syncs against project.md schema; that's the long-term right answer.

**Named follow-up trigger**: when a new letter-phase header lands and hits the `*) LATEST_PHASE_RESOLVED="$LATEST_PHASE" ;;` default branch + the hook STATE goes RED (because resolved-phase doesn't match any IN_PROGRESS row), main session adds the new mapping entry within the same session (this is acceptable maintenance debt per architect AP-7 framing).

---

## § N. Charter compliance map

This plan ships **0 charter edits / 0 constitution writes**. Confirmation matrix:

| Boundary | Status | How protected |
|---|---|---|
| PROJECT_CHARTER.md | UNTOUCHED | not in any sub-track's file list (§ J) |
| agent-workspace/constitution/** | UNTOUCHED | not in any sub-track's file list; sandwich-dev cannot Write here (.claude/settings.json deny) |
| obsidian-vault/raw/** | UNTOUCHED | not in any sub-track's file list |
| Principle 11 (Harness self-verify firing) | UPHELD | D5 ships 5 NEW or extended firing-tests covering D1+D2+D3+D4 |
| Principle 7 (Dogfood) | UPHELD | D6 dogfoods the patched hooks in same session (re-measurement is the dogfood verification) |
| Principle 8 (Calibration over confidence) | UPHELD | All claims of "expected savings" / "expected wall" are recorded as observations not assertions; D6 calibrates against actual |
| I-S1 (No LLM math) | N/A | no LLM-emitted numerics anywhere |
| I-S2 (Source + as-of) | UPHELD | every architectural claim cites file:line; STEP 0 captures fresh baselines per VBW |
| I-S22 (Data lineage) | N/A | no thesis-output paths touched |
| I-S33 (Self-aware agent invariant) | UPHELD | reducing Stop chain wall directly improves session throughput → I-S33 substrate |
| I-S35 (Research-aid framing) | N/A | no thesis-output paths touched |
| D-060 (commit-policy) | HONORED | sandwich-dev commits own work; 0 pushes |
| D-062 (atomic-write-doctrine) | HONORED | cool-down markers via `touch` (POSIX atomic) OR noclobber idiom; existing per-file markers UNTOUCHED |
| D-064 (path-safety) | N/A | no new file-path code; all writes stay in audited zones |
| Karpathy P3 (surgical changes) | UPHELD | every diff line traces to D1/D2/D3/D4/D5/D6 scope; § J coordination paths enforces |
| AP-23 (ritual demotion) | N/A this plan | no refinement-of-rule pattern (1st-instance quick-win patches) |
| AP-7 (anti-vacuous-defer) | UPHELD | every DEFER (A1-A4) names successor plan-027a..e + revisit trigger |
| AP-1 (fresh-context verifier) | UPHELD | S347 verifier dispatched in fresh context per CLAUDE.md § Session Types |

---

## § O. Expected commits (sandwich-dev planning aid)

Sandwich-dev decides commit boundaries per D-060. Architect's recommended commit shape:

1. **Commit A (D4 standalone)**: `S346 D4: phase-status-coherence regex extension + letter-phase mapping (closes ~25-session silent false-positive RED HIGH per S343-S344 surgical workaround)` — 10 LOC hook + 150 LOC fire-test + 1 paragraph removal from current-execution.md. Standalone shippable; smallest blast radius.
2. **Commit B (D1+D2 paired)**: `S346 D1+D2: hoist marker-cleanup + Stop-mode cool-down in 4 .py-scan hooks (atomic-write/python-determinism/path-safety/html-separator); expected ~190s → ~10s Stop chain savings` — ~+25 LOC across 4 hooks + 240 LOC fire-test extensions. Paired because D2's heuristic depends on D1's structure.
3. **Commit C (D3)**: `S346 D3: bash-hook-lint <DD-4 PICK from STEP 0.3>; expected >60s → <30s wall` — LOC delta per DD-4 PICK + fire-test extensions if logic changed. Standalone shippable.
4. **Commit D (D6 dogfood + bookkeeping)**: `S346 close: D6 empirical re-measurement (Stop chain wall <pre> → <post>) + session log + observation file + plan mv pending→completed + latest.md S346 close handoff` — no LOC; bookkeeping.

If verifier S347 returns PASS-WITH-CONCERNS requiring inline remediation (mirror plan-020 F1+F2 pattern, plan-021 F1 pattern), main session may add Commit E.

---

## § P. Session log template (sandwich-dev fills at IMPL)

```markdown
# Session S346 — Stop Hook Performance Quick Wins IMPL

## STEP 0 findings (BLOCKING — populated before any patches)

### 0.1 Observation file + empirical baseline
- Observation path: [verified | NOT-FOUND]
- atomic-write-check.sh baseline: [WALL_MS]ms (target: ≥30000ms to confirm baseline; else STOP-AND-ASK)

### 0.2 Per-hook claim_file_slot pattern verification
- atomic-write-check.sh: [PATTERN-PRESENT | PATTERN-ABSENT-SKIP-D1]
- python-determinism-check.sh: [PATTERN-PRESENT | PATTERN-ABSENT-SKIP-D1]
- path-safety-check.sh: [PATTERN-PRESENT | PATTERN-ABSENT-SKIP-D1]
- html-separator-check.sh: [PATTERN-PRESENT | PATTERN-ABSENT-SKIP-D1]

### 0.3 bash-hook-lint root cause + DD-4 PICK
- Total wall: [WALL_MS]ms (rc=[RC])
- Number of hooks scanned: [N]
- Dominant check (if WALL_MS>60000): [Check N]
- DD-4 PICK: [(a)content-hash | (b)xargs-P4 | (c)single-check-tighten | (d)wall-budget-killswitch]
- Rationale: [...]

### 0.4 phase-status regex empirical confirmation
- Numeric "Phase 4" → captures: [OK | FAIL — output: ...]
- Letter "Phase D" → captures: [FAIL (confirms bug) | OK (pre-patched STOP-AND-ASK)]
- Letter "Phase F-prime" → captures: [FAIL (confirms bug) | OK (pre-patched STOP-AND-ASK)]

### 0.5 Existing marker inventory
- aw-marker count: [N]
- pydet-marker count: [N]
- psafety-marker count: [N]
- htmlsep-marker count: [N]

### 0.6 STEP 0.10 baseline (immutable)
- Commit SHA: [SHA]
- File SHAs:
  - atomic-write-check.sh: [SHA]
  - python-determinism-check.sh: [SHA]
  - path-safety-check.sh: [SHA]
  - html-separator-check.sh: [SHA]
  - bash-hook-lint.sh: [SHA]
  - phase-status-coherence.sh: [SHA]

## D1+D2 IMPL (commit B)
- [diff stats per hook]
- [TC-HOISTED + TC-COOLDOWN fire-test results]

## D3 IMPL (commit C)
- [DD-4 PICK rationale]
- [diff stats]
- [bash-hook-lint fire-test results pre vs post]

## D4 IMPL (commit A — standalone)
- [regex + mapping diff stats]
- [phase-status-coherence-fire-test.sh 7/7 TCs]
- [current-execution.md surgical workaround removed]

## D5 fire-test summary
- atomic-write: [pre-TC + post-TC counts]
- python-determinism: [...]
- path-safety: [...]
- html-separator: [...]
- bash-hook-lint: [...]
- phase-status-coherence: 7/7 NEW

## D6 empirical re-measurement (DOGFOOD)
| Hook | Pre-patch ms | Post-patch ms | Delta |
|---|---:|---:|---:|
| bash-hook-lint | >60000 (timeout) | [N] | [Δ%] |
| atomic-write-check | 54900 | [N] | [Δ%] |
| python-determinism-check | 50700 | [N] | [Δ%] |
| path-safety-check | 50400 | [N] | [Δ%] |
| html-separator-check | 22700 | [N] | [Δ%] |
| (others sampled) | <500 each | [N] | [Δ%] |
| **TOTAL Stop chain** | ~5.3min | [Ns] | [Δ%] |

## DoD attestation (28 items)
[populate DC-* line by line]

## 5 risk areas surfaced for verifier
[per plan-022 § handoff-note pattern]

## Compliance attestation
[per plan-022 § compliance attestation pattern]
```

---

## § Q. Final architect sanity checklist (this plan)

- [x] VBW protocol: all 6 affected hooks Read end-to-end before plan finalization
- [x] STEP 0 has 6 sub-steps with explicit STOP-AND-ASK triggers
- [x] DD-1..DD-7 each have PICK + rationale + alternatives considered
- [x] D1..D6 sub-tracks each have files/LOC/verification
- [x] AQ-1..AQ-8 pre-answered (no architecture questions pending at dispatch)
- [x] DoD has ≥28 items across FILE/LOC/IMPL/PERF/COMPLIANCE/SMOKE/BOOK groups
- [x] RM1..RM8 each cite likelihood + mitigation + verification path
- [x] § J coordination paths explicit (in-scope + off-limits)
- [x] § L predecessor + 5 successors named with AP-7 triggers
- [x] § N charter compliance matrix complete
- [x] Budget recommendation + Sonnet acceptability + MULTI_TASK escalation triggers documented
- [x] Session log template (§ P) provided for sandwich-dev fill-in
- [x] Architect's commit shape (§ O) recommended (4 commits; standalone D4 first)
- [x] 0 charter / 0 constitution / 0 production code in THIS plan-session (architect-only)
