---
plan_id: 025-S346-planner-upgrade
target_session: S347 (or next active sandwich-dev session id at dispatch time; plan_id is the binding identifier — session-id is informational)
type: FOCUSED_IMPL (multi-file but bounded; planner template edits + 1 NEW hook + schema extension + new TSV)
budget: 100-150K Opus FOCUSED_IMPL
phase: harness-substrate (HARNESS not product; per `harness_priority_one` doctrine
       supersedes Phase 4 Wave-1 NDH-VERIFY (S345) + next-source rollout (Vietstock/VietnamBiz)
       until plan-025 ships planner self-calibration + parallel-dispatch upgrades)
track: Planner Subagent Upgrade — E1-E4 from observation
       `2026-05-16-planner-upgrade-proposal.md` (4 enhancements: tracking-log self-calibration
       + explicit `parallel_with` field + concurrent dev dispatch + throughput metric)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md
                    (planner-upgrade is a Wave-1-adjacent harness investment with payoff across
                    all subsequent IMPL sessions; not a Wave node itself)
predecessor: 022-S343-phase-d-ndh-adapter (S343-S344 PASS per dev self-report; S345 verifier
             user-paused per 2026-05-16T~19:00 directive; verifier dispatch deferred until
             user re-authorizes; not blocking this plan because planner-upgrade is harness-tier
             and per `harness_priority_one` precedes product-tier work)
successor: TBD-S348 sandwich-verifier (AP-1 fresh-context, Opus, ~50K VERIFY budget; verifier
             walks the 5 agent templates + 1 new hook + schema delta + new TSV; runs
             fire-tests; spot-checks first feedback-loop emission post-deployment)
architect: S346 sandwich-architect (background; this plan)
dispatched_by: main session orchestrating planner-upgrade per user 2026-05-16T~20:30 SEAST
               directive "follow your recommendation" + "run full autonomous" on proposal
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S347; fresh-context; AP-1 verifier in S348)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward; do NOT recommend sync-grilling cadence as part of fixes)"

depends_on:
  - "D-060 (commit-policy-agent-may-commit — operational gate for S347 dev commit boundary)"
  - "D-062 (atomic-write-doctrine — BINDING for any new state/TSV writes; .planner-stats.tsv + sessions-rollup.tsv append paths must use tmp+os.replace OR `mv -f tmp final` per existing self-awareness-aggregate.sh pattern)"
  - "D-064 (path-safety 5-invariant contract — BINDING for any new file-path code in planner-feedback-loop.sh)"
  - "Charter v1.1 Principle 11 (Harness must self-verify firing — planner-feedback-loop.sh ships with companion firing-test ≥10 TC)"
  - "Charter v1.1 Principle 7 (Dogfood mandatory — once plan-025 lands, NEXT plan authored by sandwich-architect MUST consume Phase 1b calibration + emit `parallel_with` fields)"
  - "Charter v1.1 Principle 8 (Calibration over confidence — Phase 1b architect calibration grounds budget estimates in actual past durations, not LLM guess)"
  - "agent-workspace/CLAUDE.md Contract Rule 1 (constitution immutable absent explicit human approval — ADR D-069 lives in `agent-workspace/memory/decisions/` per IMPL-tier severity-schema, NOT in constitution/)"
  - "CLAUDE.md AP-23 ritual demotion: lessons-about-lessons go RED FLAG at 2nd instance — applies to Phase 1b read-budget if architect over-reads tracking logs (`L-S346-N` candidate)"
  - "CLAUDE.md `harness_priority_one` memory rule"
  - "observations/2026-05-16-planner-upgrade-proposal.md (THIS plan's design source; ratified by user 2026-05-16T~20:30 SEAST)"
  - ".claude/agents/sandwich-architect.md (D1 target; 183 LOC; Phase 1 currently spec+constitution; add Phase 1b)"
  - ".claude/agents/master-planner.md (D2 target; 168 LOC; Phase 5 'Identify parallel opportunities' currently vague; add explicit `parallel_with` field + Phase 1b)"
  - ".claude/agents/sandwich-dev.md (D3 target; ~163 LOC current; add Parallelism Discipline section + opus model declared this turn)"
  - ".claude/agents/action-guide-planner.md (D3 cross-ref; 178 LOC; minor edit)"
  - ".claude/agents/bdd-planner.md (D3 cross-ref; 163 LOC; minor edit)"
  - "scripts/hooks/self-awareness-aggregate.sh (D5 reference — existing TSV-append pattern to mirror; current schema = session_n session_id ts_utc tokens_real tools_used subagents failure_codes wall_min; D5 extends with appended cols)"
  - "agent-workspace/memory/dispatch.jsonl (Phase 1b read source; 530 rows; JSON-per-line with event/dispatch_id/agent_type/duration_ms/outcome/tokens_used)"
  - "agent-workspace/memory/component-telemetry.jsonl (Phase 1b read source; 3666 rows; per-tool + per-agent telemetry)"
  - "agent-workspace/memory/self-awareness/sessions-rollup.tsv (Phase 1b read source AND D5 schema-extension target; current 8-col schema; 623 rows)"

binding_decisions:
  - "Q-PL1 RATIFIED — max 3 parallel dev ceiling INITIALLY; revisit-to-4 only after observation of 10+ successful 3-parallel runs without rate-limit / file-collision incidents"
  - "Q-PL2 RATIFIED — Phase 1b MANDATORY for plans with ≥3 sub-tracks; SKIPPABLE for FOCUSED_IMPL with 1-2 sub-tracks (skip-decision must be explicit in plan output line — empty-skip not allowed)"
  - "Q-PL3 RATIFIED — APPEND new columns to sessions-rollup.tsv (back-compat — legacy rows OK without new column values; reader treats absent values as default per col schema)"
  - "Q-PL4 RATIFIED — Stop cadence for `planner-feedback-loop.sh` WITH debounce per plan_id (hook skips runs where no plan transitioned VERIFY-DONE this Stop; marker pattern mirrors existing `.escalation-fired-${EVENT}-${BUCKET}` from escalation-engine.sh:56)"
  - "D-060 — agent MAY git commit (NOT push); S347 dev decides commit boundary"
  - "AP-23 promote-or-retire — applied to first-instance ADR D-069: PROPOSED at IMPL tier with `Empirical-Tuning-Window: 30 days` clause; revisit after 10+ plans consume Phase 1b calibration"
  - "AP-7 anti-vacuous-defer — every DEFER decision in this plan names (a) prerequisites + (b) revisit trigger; no 'Out-of-scope item N with no follow-up'"
  - "Karpathy P3 surgical-changes — every recommendation traces to E1-E4 in observation; NO invented enhancements (E5+ explicitly STOP-AND-SPLIT)"
  - "VBW protocol mandatory — before recommending any agent-template edit, READ the actual template file; this plan cites file:line for every claim"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL; this plan is architect's; S347 is dev's)"
  - "no commits in THIS plan-session (sandwich-architect subagent has no Bash tool; main commits this plan output per D-060 + the pre-dispatch-architect-commit-guard.sh hook recovery pattern from S335/S337×2/S340)"
  - "no charter / no constitution writes in THIS plan-session (0 charter / 0 constitution per S346 brief; ADR D-069 lives in `decisions/` not `constitution/`)"
  - "no human-workspace writes (this plan's targets are all in `.claude/agents/`, `scripts/hooks/`, `agent-workspace/memory/.planner-stats.tsv`, `agent-workspace/memory/self-awareness/sessions-rollup.tsv`)"
  - "no AskUserQuestion gate this session (no charter/scope question; all 4 minor design Qs already ratified per binding_decisions above; per `full_autonomous_no_supervised` AskUserQuestion reserved for SCOPE/CHARTER only)"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read end-to-end via Read tool, not memory (VBW protocol)"
  - "no PRODUCT-tier parallel-dispatch in this plan (the plan ENABLES it via E1-E4; first PRODUCT consumer is post-S348 NEXT plan authored by sandwich-architect; out-of-scope here)"
---

# S347 — Planner Subagent Upgrade (E1-E4: tracking-log self-calibration + explicit parallel-dispatch + concurrent dev agents + throughput metric)

## § A. Session metadata

| Field | Value |
|---|---|
| Plan ID | 025-S346-planner-upgrade |
| Target session | S347 (sandwich-dev, FOCUSED_IMPL) — session-id binding informational; plan_id authoritative |
| Verify session | S348 (sandwich-verifier, AP-1 fresh-context Opus) |
| Budget | 100-150K Opus FOCUSED_IMPL (multi-file but bounded; agent template edits are bounded surgery; 1 NEW hook ~150 LOC; schema extension; new TSV format spec) |
| Phase | harness-substrate (non-product; per `harness_priority_one`) |
| Type | FOCUSED_IMPL |
| Wave / Theme | harness investment Wave-1-adjacent; payoff across ALL subsequent IMPL sessions (S349+) via better calibration + parallel-dispatch capacity |
| Coordination paths off-limits during S347 IMPL | See § J |
| Predecessor | 022-S343 (NDH adapter dev complete; S345 verifier user-paused; planner-upgrade harness-tier supersedes product-tier per harness_priority_one) |

## § B. Predecessor + invocation context

**Why this session now**: user reviewed `observations/2026-05-16-planner-upgrade-proposal.md` (4 minor design Qs Q-PL1..Q-PL4 with recommended answers) and ratified at 2026-05-16T~20:30 SEAST with explicit directives "follow your recommendation" + "run full autonomous" + "i need the planner to be more wiser, it can see the tracking log to learn, improve it self, to decide the more effective plan, more subagent running in parralel without causing any error or wrong direction, the planner make claudecode run faster to achieve the goals". This plan packages the 4 ratified enhancements (E1-E4) as executable FOCUSED_IMPL.

**Empirical state surfaced by observation** (architect verified this VBW pass):
1. **Planner templates have ZERO tracking-log refs**: confirmed via Grep `parallel_with|parallel-dispatch|concurrent` on `.claude/agents/` returns 0 matches; observation table § "Current state — empirical audit" cites sandwich-architect.md (183 LOC, 0 refs to tracking logs, 1 vague parallel mention at line 96), master-planner.md (168 LOC, 0/0/1 vague at line 74), action-guide-planner.md (178/0/0), bdd-planner.md (163/0/0). **Total: 692 LOC of planner contracts, 0 concrete parallel-dispatch directives, 0 references to dispatch.jsonl / component-telemetry.jsonl / sessions-rollup.tsv.**

2. **3 rich tracking logs sit UNUSED by planners**: dispatch.jsonl (530 rows; per-Agent-call telemetry incl. agent_type/duration_ms/outcome/tokens_used) + component-telemetry.jsonl (3666 rows; per-hook + per-agent) + self-awareness/sessions-rollup.tsv (623 rows; per-session rollup with tokens_real/wall_min/failure_codes). Currently consumed only by: `correction-rate-aggregator.sh` (dispatch.jsonl rollup), `self-awareness-aggregate.sh` (sessions-rollup writer), `profile-template-auto-populate.sh` (profile-card writer). **Planners never read these even though they ARE the natural calibration corpus.**

3. **Sandwich pattern is strictly sequential in practice**: recent multi-sub-track plans (plan-020 S337 Theme L 4 sub-tracks; plan-021 S341 Harness Sweep 6 sub-tracks; plan-022 S343 NDH 5 sub-tracks) all dispatched 1 dev sequential per sub-track. Claude Code Agent tool supports parallel-dispatch in single message; **capacity dormant.**

4. **User-stated bottleneck**: "number of task, number of agent/subagent that can run at once time ... is not much". The throughput ceiling is NOT model speed — it's plan format (no `parallel_with` directive) + plan-blind-to-history (no calibration ⇒ pessimistic conservative sequential default).

**What the upgrades fix**:
- E1 (Phase 1b self-calibration): architect reads last 30 rows of dispatch.jsonl + sessions-rollup.tsv + mistake-log digest → extracts task_class-similar metrics → grounds budget + RM in real durations + failure modes (not LLM guess)
- E2 (explicit `parallel_with` field): plan format gains required `parallel_with: [D2,D3]` / `blocks_on: [D1]` / `coordination_paths_exclusive: [...]` per sub-track; lint-validates disjoint paths + cycle-free DAG + max-3-parallel
- E3 (concurrent dev dispatch): main session (orchestrator) reads `parallel_with` and dispatches up to 3 dev subagents in single Agent-tool message
- E4 (throughput metric): post-VERIFY Stop hook writes per-plan stats to `.planner-stats.tsv`; architect Phase 1b reads → calibration loop closes

**Concrete projection** (per observation § Concrete examples): hypothetical plan-022-prime would reduce wall time from ~29 min sequential to ~20 min parallel = 31% improvement. Conservative across 5 recent multi-track sessions: 25% wall-time reduction; aggressive: 50% for 3-5 independent-sub-track sessions.

## § C. Charter compliance map

This plan ships **0 charter edits / 0 constitution writes / 0 production code outside agents+hooks+tracking-log schema**.

| Boundary | Status | How protected |
|---|---|---|
| PROJECT_CHARTER.md | UNTOUCHED | not in any sub-track's file list |
| agent-workspace/constitution/** | UNTOUCHED | sandwich-dev cannot Write here (.claude/settings.json line 97 deny); ADR D-069 lands in `agent-workspace/memory/decisions/069-*.md` at IMPL tier per severity-schema |
| obsidian-vault/raw/** | UNTOUCHED | not in any sub-track's file list |
| Principle 11 (Harness self-verify firing) | UPHELD | D4 ships companion firing-test `scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` ≥10 TC |
| Principle 7 (Dogfood) | UPHELD via post-deployment dogfood | next architect-authored plan after S348 verify MUST consume Phase 1b calibration + emit `parallel_with` fields; verifier S348 spot-checks first dogfood cycle if available |
| Principle 8 (Calibration over confidence) | UPHELD | Phase 1b grounds architect budget in past actual durations, not "approximately 100K Opus" LLM guess |
| I-S1 (No LLM math) | N/A | no LLM-emitted numerics in any sub-track output; metrics computed by code (bash + awk per L-S11-1 portability discipline) |
| I-S2 (Source + as-of) | UPHELD | every architectural claim cites file:line; Phase 1b calibration summary in architect plan output MUST cite (task_class, sample_size, ts_window) source |
| I-S22 (Data lineage) | UPHELD | sessions-rollup append-only; legacy rows preserved; new cols backward-compat read |
| I-S33 (Self-aware agent invariant) | UPHELD | the WHOLE plan IS a self-awareness step — planner learns from past plans |
| I-S34 / I-S35 | N/A | no crawler / no thesis-output paths touched |

## § D. Architecture Decisions (DD-1..DD-12)

### DD-1 — Phase 1b position in sandwich-architect.md

**Decision**: insert NEW Phase 1b "Self-Calibration from Tracking Logs" AFTER current Phase 1 (Comprehend; lines 32-40) and BEFORE current Phase 2 (Architecture Decisions; lines 42-52).

**Rationale**: Phase 1 reads spec + constitution + code (target-side). Phase 1b reads past-execution telemetry (history-side). Both feed Phase 2 architectural decisions. Inserting between maintains the "read-everything-first then decide" cadence; placing AFTER Phase 1 means the architect already knows what task_class to query telemetry for.

**Rejected alternative**: merge into Phase 1 — REJECTED because (a) tracking-log reads are conceptually different (telemetry vs spec); (b) Q-PL2 ratified Phase 1b as SKIPPABLE for 1-2 sub-track FOCUSED_IMPL but Phase 1 is always mandatory; (c) separate phase makes skip-decision auditable in plan output.

**Implementation hint**: edit `.claude/agents/sandwich-architect.md` line 41 (end of Phase 1) — insert "### Phase 1b: Self-Calibration from Tracking Logs (MANDATORY if plan has ≥3 sub-tracks; SKIPPABLE for 1-2 sub-track FOCUSED_IMPL — skip-decision MUST be explicit in plan output § Calibration summary line)" + read block + extract block + use block per observation § E1.

### DD-2 — Tracking-log read budget — cap at last 30 rows per file per Phase 1b invocation

**Decision**: architect reads `tail -30 dispatch.jsonl` + `tail -30 self-awareness/sessions-rollup.tsv` + last 200 LOC of `mistake-log.md`. NO full-log scan.

**Rationale**: 30 rows × 3 files = ~90 rows total ≈ 5sec read budget; covers ~last 5-10 sessions; sufficient for task_class similarity matching; bounded against context bloat (observation RM5: "Phase 1b read budget overruns → cap last 30 rows per log").

**Rejected alternative**: full-log scan with grep filter by task_class — REJECTED because (a) 530+3666+623 = ~5000-row reads inflate context; (b) older data weighted lower per DD-10 age decay anyway.

**Implementation hint**: architect uses Read tool with `offset` + `limit` parameters; example for sessions-rollup.tsv (623 rows): `Read(file_path=.../sessions-rollup.tsv, offset=593, limit=30)` reads rows 594-623.

### DD-3 — `parallel_with: []` field placement in plan template — under each sub-track header; required field

**Decision**: each sub-track in plan's § D Sub-track decomposition gains 3 NEW required fields:
- `parallel_with: [D2, D3]` (list of sub-track IDs that may run in parallel; `[]` if none — empty list REQUIRED, not absent)
- `blocks_on: [D1]` (list of sub-track IDs that MUST complete before this one starts; `[]` if root)
- `coordination_paths_exclusive: [path1, path2]` (per-sub-track scope; lint validates disjointness across `parallel_with` siblings)

**Rationale**: required-not-optional eliminates ambiguity ("did architect mean parallel or sequential?"); explicit `[]` proves architect considered + chose sequential; coordination_paths_exclusive is the file-collision guard.

**Rejected alternative**: only emit field when parallel — REJECTED because (a) absent-field reads ambiguous (forgotten? not applicable? sequential-only?); (b) required-field forces architect to consider parallelism for every sub-track.

**Implementation hint**: edit `.claude/agents/sandwich-architect.md` § Phase 3 File-Level Planning (lines 54-83) — add example sub-track template with the 3 new fields under each `## Sub-track DN: <title>` header.

### DD-4 — Coordination-paths-exclusive validation — lint asserts disjoint sets across `parallel_with` siblings; refuse plan otherwise

**Decision**: D4's `planner-feedback-loop.sh` exits 0 on dogfood path; a SEPARATE lint OR a clause in `bash-hook-lint.sh` validates plan format (disjointness + max-3 + cycle-free DAG). If a plan with `parallel_with: [D2]` declares D1 coordination_paths overlap D2 coordination_paths → main session REFUSES to dispatch parallel + falls back sequential + records M-S<N>-N entry.

**Rationale**: file-collision is the PRIMARY risk of parallel-dispatch (observation RM3: "Architect over-parallelizes; causes file-collision conflict"); detect at dispatch-time not runtime; runtime collision = corrupted state.

**Rejected alternative**: trust architect to never overlap — REJECTED per Karpathy P1 (think before coding; humans/LLMs make mistakes; lint is cheap insurance).

**Implementation hint**: lint logic goes in D4 hook OR adjacent new linter `plan-format-lint.sh`. Pseudocode:
```
for sub_track in plan.D*:
  for sibling in sub_track.parallel_with:
    if sub_track.coordination_paths ∩ sibling.coordination_paths != ∅:
      EXIT 1 with REFUSE message
```

### DD-5 — Q-PL1 RATIFIED: 3-parallel ceiling initially; comment in agent template noting future raise-to-4

**Decision**: `.claude/agents/sandwich-dev.md` Parallelism Discipline section (D3) explicitly states "**Max ceiling**: 3 parallel dev subagents per plan (matches harness profile; raise to 4 only after 10+ successful 3-parallel runs without rate-limit / file-collision incident — see ADR D-069 § Empirical-Tuning-Window for revisit trigger)".

**Rationale**: Q-PL1 user-ratified conservative initial cap; revisit trigger named per AP-7 anti-vacuous-defer.

**Rejected alternative**: start at 4 — REJECTED per observation RM1 (rate-limit risk + context-window fragmentation; better to prove 3-parallel stable first).

### DD-6 — Q-PL2 RATIFIED: Phase 1b mandatory ≥3 sub-tracks; skip threshold = 2 sub-tracks (FOCUSED_IMPL pattern); skip-decision MUST be explicit in plan output

**Decision**: architect template requires Phase 1b for plans with ≥3 sub-tracks; for FOCUSED_IMPL plans with 1-2 sub-tracks, Phase 1b may be SKIPPED — but the plan output § Calibration summary line MUST explicitly read either:
- "Phase 1b CONSUMED: task_class=<X>, sample_size=<N>, avg_wall_min=<M>, parallel_hit_rate=<P>" (mandatory case)
- "Phase 1b SKIPPED: 1-2 sub-track FOCUSED_IMPL per DD-6; budget estimated from boilerplate" (explicit skip case)

NO empty-skip allowed (silent omission = lint refuses plan).

**Rationale**: explicit-skip is auditable; silent-skip looks identical to architect-forgot.

**Implementation hint**: edit `.claude/agents/sandwich-architect.md` § Output (lines 157-163) — add requirement "plan output § Calibration summary line MUST appear (either CONSUMED or SKIPPED variant)".

### DD-7 — Q-PL3 RATIFIED: schema extension via append; legacy rows have no values in new cols (back-compat read)

**Decision**: extend `sessions-rollup.tsv` from current 8-col schema to 14-col by APPENDING (not reordering):

```
Current (8): session_n  session_id  ts_utc  tokens_real  tools_used  subagents  failure_codes  wall_min
NEW (14):    session_n  session_id  ts_utc  tokens_real  tools_used  subagents  failure_codes  wall_min  plan_id  sub_track_count  parallel_dispatched  wall_min_estimated  wall_min_actual  parallel_savings_min
```

Legacy rows (623 existing) remain 8-col. Readers (D4 hook, architect Phase 1b) MUST tolerate variable col count via:
```awk
NF >= 14 ? $14 : ""   # parallel_savings_min field
```

**Rationale**: append preserves back-compat (existing readers read first 8 cols unchanged); reorder would break `correction-rate-aggregator.sh` + `profile-template-auto-populate.sh` which read positional fields.

**Rejected alternative**: full re-design with versioned header line — REJECTED because (a) 1-line schema change vs N-tool migration overhead; (b) Karpathy P3 surgical (minimum disruption).

**Implementation hint**: edit `scripts/hooks/self-awareness-aggregate.sh` lines 14-17 (the schema header comment) + the awk emit block (architect should find via Grep `sessions-rollup` in script) — extend header line + emit-block to write 14 fields when D4-feedback data available, fall back to 8 fields when not. D4 hook writes the new 6 fields via a SEPARATE append path (NOT amending self-awareness-aggregate.sh's existing emit — D4 is a back-fill on a per-plan basis).

**STOP-AND-ASK**: if D5 implementation finds the existing `awk` schema-emit in self-awareness-aggregate.sh is more entangled than expected (e.g., the rollup is rewritten not appended), STOP-AND-REPLAN — surface as plan-025 finding.

### DD-8 — Q-PL4 RATIFIED: Stop cadence with debounce keyed on plan_id+VERIFY-DONE marker

**Decision**: `planner-feedback-loop.sh` wires to Stop hook (after `self-awareness-aggregate.sh` in chain order, so per-session row already exists). Debounce mechanism:

```bash
MARKER=".planner-feedback-emitted-${PLAN_ID}"
if [ -f "$MARKER" ]; then exit 0; fi   # already processed this plan_id
# detect VERIFY-DONE for any plan_id by scanning recent commits / current-execution
# OR check if a plan moved pending → completed this session
# Skip silently if no VERIFY-DONE transition this Stop
```

Marker pattern mirrors existing `escalation-engine.sh:56` hour-bucket marker but keyed on plan_id (not time-bucket). Markers live under `agent-workspace/memory/.planner-feedback-emitted-*` (same dir as other dot-prefixed state files).

**Rationale**: Stop-every-cycle would compute the same metric repeatedly; debounce per-plan is the correct granularity (each plan completes once).

**Rejected alternative**: weekly cron / per-batch — REJECTED per Q-PL4 (Stop is the natural cadence; cron requires separate infra; per-batch loses freshness).

**Implementation hint**: hook detects VERIFY-DONE via either (a) `git log --oneline -10 | grep -E 'S[0-9]+ close.*VERIFY|verify.*DONE'` heuristic, OR (b) checking if a plan-NNN file moved into `agent-workspace/session-plans/completed/` this Stop window (mtime within last 5min). Architect leaves the detection-mechanism choice to dev; either is acceptable per AP-7 (both have named revisit triggers for refinement).

### DD-9 — `.planner-stats.tsv` schema

**Decision**: new file `agent-workspace/memory/.planner-stats.tsv` with this schema (tab-separated, header on first row):

```
task_class	sample_size	avg_wall_min	parallel_hit_rate	parallel_savings_avg	last_updated
```

Where:
- `task_class` = derived from plan-id stem heuristic (e.g., `harness-sweep`, `adapter-impl`, `ndh-adapter`, `theme-l`); D4 hook uses `awk` regex on plan_id to extract canonical class
- `sample_size` = count of plans observed for this class within retention window (per DD-10)
- `avg_wall_min` = weighted average of `wall_min_actual` from sessions-rollup last-30 + age-decay weighting
- `parallel_hit_rate` = fraction of plans for this class where `parallel_dispatched > 0`
- `parallel_savings_avg` = average `parallel_savings_min` for plans where parallel_dispatched > 0
- `last_updated` = ISO-8601 timestamp of last refresh

**Rationale**: per-task_class aggregation lets architect Phase 1b query "for plans like THIS one, what's the typical wall time?" — cheap lookup, no recomputation per architect dispatch.

**Implementation hint**: D4 hook rewrites this TSV atomically (tmp + mv per D-062) on every VERIFY-DONE trigger.

### DD-10 — Age decay for sample weighting — rows >30 days half-weighted; rows >90 days dropped

**Decision**: when D4 hook aggregates sessions-rollup rows for `.planner-stats.tsv` refresh:
- rows with `ts_utc` within last 30 days → weight 1.0
- rows with `ts_utc` 30-90 days → weight 0.5
- rows with `ts_utc` >90 days → weight 0 (effectively dropped)

**Rationale**: per observation RM2 ("Stale calibration data biases planner") and per `harness_priority_one` continuous-improvement assumption (older sessions reflect prior tool versions / harness profile). Per ADR D-069 § Empirical-Tuning-Window, the 30/90 thresholds themselves are tunable.

**Rejected alternative**: hard 30-day cutoff (drop everything beyond) — REJECTED because (a) loses signal in low-volume task_classes; (b) gradual decay smoother than cliff.

**Implementation hint**: awk computes `weight = (age_days <= 30) ? 1.0 : (age_days <= 90) ? 0.5 : 0.0` per row; weighted sum / weighted count = avg.

### DD-11 — Phase 1b output format — architect's plan output includes 1-paragraph "calibration summary" citing the past task_class metrics consumed

**Decision**: architect plan template's § A. or § B. (TBD by dev — recommendation: end of § B Predecessor + invocation context, before § C) gains a sub-section `### Calibration summary (Phase 1b)`:

```markdown
### Calibration summary (Phase 1b)
Source: agent-workspace/memory/.planner-stats.tsv (last_updated=<TS>)
- task_class: <X>
- sample_size: <N> (window: last 30 days, age-decayed per DD-10)
- avg_wall_min observed for class: <M>
- parallel_hit_rate: <P>% (of past plans for this class that dispatched parallel)
- parallel_savings_avg: <S> minutes (when parallel was dispatched)
- Adjustment to default 100-150K budget: <±X K based on observed tokens_real>
- Cold-start? <YES/NO — if sample_size<3, this row marked cold-start per AQ-5>
```

If Phase 1b SKIPPED per DD-6, this section reads single line: "Phase 1b SKIPPED per DD-6: 1-2 sub-track FOCUSED_IMPL; budget=<X> estimated from boilerplate".

**Rationale**: makes calibration auditable; verifier S348 can spot-check "did architect actually consume Phase 1b or fake it?"

**Implementation hint**: edit `.claude/agents/sandwich-architect.md` § Output (around line 157) — add requirement for `### Calibration summary` sub-section in plan output.

### DD-12 — ADR D-069 NEW PROPOSED at IMPL tier — Planner Self-Calibration Protocol

**Decision**: D6 sub-track ships ADR `agent-workspace/memory/decisions/069-planner-self-calibration-protocol.md` (~150 LOC) using the 12-field schema in `_template.md`. Status: `PROPOSED`. Level: `IMPL` (no cool-down per severity-schema). Key clauses:
- § Decision: Phase 1b + parallel_with field + feedback-loop hook = canonical planner-calibration protocol
- § Empirical-Tuning-Window: 30 days post-deployment for revisit of (DD-2 read budget cap / DD-5 parallel ceiling / DD-10 age-decay thresholds)
- § Revisit triggers (per AP-7): (a) 10+ plans consumed Phase 1b → re-evaluate cold-start gate; (b) 10+ successful 3-parallel runs → consider 4-parallel raise; (c) M-S<N>-N file-collision incident → tighten DD-4 lint
- § Supersedes: nothing (NEW)

**Rationale**: planner-calibration is a NEW architectural pattern; ADR codifies the decisions for future audit + AP-23 ritual-demotion lookback.

**Implementation hint**: dev copies `agent-workspace/memory/decisions/_template.md` → `069-planner-self-calibration-protocol.md`; fills 12 fields; cites this plan-025 + observation `2026-05-16-planner-upgrade-proposal.md` as source_evidence.

## § E. Sub-track decomposition (D1-D6)

Order optimized to minimize blast radius: D1 (architect template — central) → D2 (master-planner sibling) → D3 (dev + 2 cross-refs) → D4 (NEW hook + firing-test) → D5 (schema extension + new TSV format spec) → D6 (ADR + settings.json wire).

Each sub-track declares the 3 NEW fields per DD-3 (which themselves illustrate the field-format for dev to mirror in production plan output).

---

### D1 — sandwich-architect.md Phase 1b addition + sub-track template with `parallel_with`/`blocks_on`/`coordination_paths_exclusive` fields

- **parallel_with**: []  (D1 must complete before D2 sibling can mirror the same pattern; sequential)
- **blocks_on**: []
- **coordination_paths_exclusive**: [.claude/agents/sandwich-architect.md]
- **estimated_wall_min**: 8 (per Phase 1b cold-start; no historical task_class=agent-template-edit data available yet)

**Files modified**: `.claude/agents/sandwich-architect.md`

**LOC delta**: ~+80 LOC

**Specific edits**:
1. After line 41 (end of Phase 1: Comprehend), INSERT new Phase 1b block (~40 LOC):
   ```markdown
   ### Phase 1b: Self-Calibration from Tracking Logs

   **MANDATORY** if plan has ≥3 sub-tracks. **SKIPPABLE** for 1-2 sub-track FOCUSED_IMPL.
   Skip-decision MUST be explicit in plan output § Calibration summary line.

   Read (cap last 30 rows each per DD-2):
   - `agent-workspace/memory/dispatch.jsonl` (per-Agent-call telemetry; agent_type/duration_ms/outcome/tokens_used)
   - `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (per-session rollup; tokens_real/wall_min/failure_codes)
   - `agent-workspace/memory/.planner-stats.tsv` (per-task_class aggregated metrics maintained by planner-feedback-loop.sh)
   - `agent-workspace/memory/mistake-log.md` (last 200 LOC digest; failure pattern lookup)

   Extract:
   - For task_class similar to current target: average duration_ms + outcome distribution + failure_mode frequency
   - For model+effort similar to current dispatch context: average tokens_real vs estimated
   - For coordination-rule pattern similar: any file-collision incidents recorded
   - For sandwich pattern: was there parallel dispatch? Did it succeed?

   Use to:
   - Set REALISTIC budget per sub-track (not boilerplate; ground in actual durations)
   - Flag sub-tracks with historically-high failure_mode → add specific RM entry
   - Identify safe parallelization opportunities → mark sub-tracks `parallel_with: [D2, D3]`

   Cold-start (per AQ-5): if `.planner-stats.tsv` sample_size<3 for current task_class, Phase 1b gracefully degrades to default 100-150K budget; flag in calibration summary as "cold-start".
   ```

2. After line 83 (Phase 3 File-Level Planning closing fence), INSERT new sub-section showing parallel_with field template (~30 LOC):
   ```markdown
   ### Sub-track template (REQUIRED 3 fields per sub-track per DD-3)

   Each sub-track in § D Sub-track decomposition MUST declare:

   ```markdown
   ### DN: <Sub-track title>
   - **parallel_with**: [D2, D3]    # list of sibling sub-track IDs that may run in parallel; [] if none
   - **blocks_on**: [D1]              # list of sub-track IDs that MUST complete before this one starts; [] if root
   - **coordination_paths_exclusive**: [path/to/file1, path/to/file2]   # per-sub-track file scope; lint validates disjointness across parallel_with siblings
   - **estimated_wall_min**: 12       # per Phase 1b calibration; cold-start = boilerplate estimate
   ```

   **Lint contract** (enforced at dispatch-time per DD-4):
   - `coordination_paths_exclusive` sets MUST be disjoint across all sub-tracks listed in `parallel_with`
   - Total `parallel_with` cardinality MUST NOT exceed 3 per dispatch wave (per DD-5; raise to 4 trigger documented in ADR D-069)
   - `blocks_on` MUST form a cycle-free DAG with `parallel_with`
   ```

3. After line 163 (§ Output), INSERT requirement for `### Calibration summary` sub-section per DD-11 (~15 LOC):
   ```markdown
   ## Calibration summary (Phase 1b — MANDATORY in plan output)

   Plan output MUST include a `### Calibration summary (Phase 1b)` sub-section near the end of § B (Predecessor + invocation context) reading either:

   **CONSUMED variant** (≥3 sub-tracks):
   ```
   ### Calibration summary (Phase 1b)
   Source: agent-workspace/memory/.planner-stats.tsv (last_updated=<TS>)
   - task_class: <X>
   - sample_size: <N> (window: last 30 days, age-decayed per DD-10)
   - avg_wall_min observed: <M>
   - parallel_hit_rate: <P>%
   - parallel_savings_avg: <S> min
   - Adjustment to default budget: <±X K based on observed tokens_real>
   - Cold-start? <YES/NO>
   ```

   **SKIPPED variant** (1-2 sub-track FOCUSED_IMPL):
   ```
   ### Calibration summary (Phase 1b)
   Phase 1b SKIPPED per DD-6: 1-2 sub-track FOCUSED_IMPL; budget=<X> estimated from boilerplate.
   ```

   Empty-skip (silent omission) is REFUSED — lint exits 1.
   ```

**Verification at task end**: bash-hook-lint.sh + `wc -l .claude/agents/sandwich-architect.md` confirms new LOC range; grep confirms "Phase 1b" + "parallel_with" + "Calibration summary" all present.

---

### D2 — master-planner.md Phase 1b + plan format alignment

- **parallel_with**: [D3]   (D2 independent of D3 cross-ref edits; both touch separate files)
- **blocks_on**: [D1]        (mirror Phase 1b shape from D1 for consistency)
- **coordination_paths_exclusive**: [.claude/agents/master-planner.md]
- **estimated_wall_min**: 6

**Files modified**: `.claude/agents/master-planner.md`

**LOC delta**: ~+50 LOC

**Specific edits**:
1. After line 47 (end of Phase 1: Understand), INSERT mirror Phase 1b block (~25 LOC; same shape as D1 but adapted for master-planner's higher-level decomposition):
   ```markdown
   ### Phase 1b: Self-Calibration from Tracking Logs (mirror sandwich-architect.md DD-1)

   For master-plans with ≥3 sessions: read tracking logs same as sandwich-architect.md Phase 1b.
   For master-plans with 1-2 sessions: skip per DD-6.

   Additional master-planner-specific extracts:
   - For phase similar to current target: average session count + cumulative wall time
   - For sandwich pattern at this scale: total parallel-dispatched sessions vs sequential
   ```

2. After line 80 (Phase 6 Write Plans format-per-session-plan), INSERT requirement for per-session-plan sub-tracks to declare 3 new fields per DD-3 + cross-ref to sandwich-architect.md § Phase 3 template.

3. Update line 74 (current vague "Identify parallel opportunities") to explicit reference: "Identify parallel opportunities — emit `parallel_with: [...]` per sub-track per DD-3 contract".

**Verification at task end**: bash-hook-lint.sh + grep confirms "Phase 1b" + "parallel_with" present.

---

### D3 — sandwich-dev.md Parallelism Discipline section + action-guide-planner.md + bdd-planner.md cross-refs

- **parallel_with**: [D2]   (D3 independent of D2; both touch separate files; D1 must precede both for template-shape reference)
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [.claude/agents/sandwich-dev.md, .claude/agents/action-guide-planner.md, .claude/agents/bdd-planner.md]
- **estimated_wall_min**: 5

**Files modified**: `.claude/agents/sandwich-dev.md` + `.claude/agents/action-guide-planner.md` + `.claude/agents/bdd-planner.md`

**LOC delta**: ~+40 LOC (sandwich-dev) + ~+10 LOC (action-guide-planner cross-ref) + ~+10 LOC (bdd-planner cross-ref)

**Specific edits**:

**sandwich-dev.md** — after line 135 (end of Constraints section), INSERT new Parallelism Discipline section:

```markdown
## Parallelism Discipline

If plan declares `parallel_with: [D2, D3]` for sub-track D1, main session (orchestrator) MAY dispatch up to 3 dev subagents in single Agent-tool message (parallel background).

**Rules** (per DD-3 + DD-4 + DD-5):
- Each dev gets a NARROWED plan slice: only its own sub-track + shared context (Charter, constitution, target spec)
- Each dev's `coordination_paths_exclusive` list is enforced: violation = STOP-AND-FLAG, do NOT silently widen scope
- Devs do NOT cross-coordinate; main session integrates returns
- If any parallel dev fails → main session preserves successes + queues sequential retry for failed slice (per observation E3)

**Max ceiling**: 3 parallel dev subagents per plan (per DD-5; raise to 4 only after 10+ successful 3-parallel runs without rate-limit / file-collision incident — see ADR D-069 § Empirical-Tuning-Window).

**Self-check for dev**: before any file write, confirm target path is IN your sub-track's `coordination_paths_exclusive` list. If NOT, STOP-AND-FLAG — escalate to main session per Escalate When section.
```

**action-guide-planner.md** — after line 88 (Execution Sequence Pre-flight), INSERT 1 paragraph:
```markdown
**Parallelism awareness**: if session plan declares sub-tracks with non-empty `parallel_with`, action-guide MUST partition its file-load list per sub-track + recommend main session dispatch parallel devs per `.claude/agents/sandwich-dev.md` § Parallelism Discipline.
```

**bdd-planner.md** — after line 73 (Phase 5 Output Test Plan), INSERT 1 paragraph:
```markdown
**Parallel sub-track awareness**: if implementation plan declares parallel sub-tracks, test plan MAY scope test files per sub-track to preserve `coordination_paths_exclusive` discipline (e.g., D1 test file in `tests/x/`, D3 test file in `tests/y/`, no cross-import).
```

**Verification at task end**: bash-hook-lint.sh + grep "Parallelism Discipline" present in sandwich-dev.md + grep "parallel_with" present in action-guide-planner.md + bdd-planner.md.

---

### D4 — NEW `scripts/hooks/planner-feedback-loop.sh` (~150 LOC; Stop cadence; debounce + per-task_class aggregation)

- **parallel_with**: []   (D4 depends on D5 schema being defined; sequential after D5)
- **blocks_on**: [D5]
- **coordination_paths_exclusive**: [scripts/hooks/planner-feedback-loop.sh, scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh]
- **estimated_wall_min**: 12

**Files created**:
1. `scripts/hooks/planner-feedback-loop.sh` (~150 LOC)
2. `scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` (~180 LOC; ≥10 TC)

**Hook design**:

```bash
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
# Trigger: Stop hook (after self-awareness-aggregate.sh; chain position TBD by D6 wire).
set -uo pipefail
[skeleton — dev fills in]

# (1) Detect VERIFY-DONE: any plan-NNN-*.md with mtime <5min in completed/
PLANS_DONE=$(find "$PLANS_COMPLETED_DIR" -name 'plan-*.md' -mmin -5 ... )
[ -z "$PLANS_DONE" ] && exit 0   # no VERIFY-DONE this Stop → silent skip

# (2) For each plan_id, check debounce marker
for plan_md in $PLANS_DONE; do
  PLAN_ID=$(basename "$plan_md" .md | sed -E 's/^plan-//; s/^[0-9]+-//')
  MARKER="$MEM_DIR/.planner-feedback-emitted-$PLAN_ID"
  [ -f "$MARKER" ] && continue   # already processed
  ...
done

# (3) For each new VERIFY-DONE plan, read sessions-rollup last-30 rows filtered to this plan_id
# (4) Compute wall_min_actual sum + parallel_savings_min
# (5) Derive task_class from plan_id stem
# (6) Update .planner-stats.tsv (read old → recompute aggregate per DD-10 age-decay → atomic write tmp+mv)
# (7) Touch marker for debounce

exit 0
```

**Firing-test design** (≥10 TC):
- TC1: no plans completed this Stop → exit 0 silent
- TC2: 1 plan VERIFY-DONE first time → `.planner-stats.tsv` row appears + marker created
- TC3: same plan VERIFY-DONE again next Stop → marker prevents re-process (idempotent)
- TC4: 2 plans VERIFY-DONE same Stop → both processed
- TC5: sessions-rollup.tsv missing → graceful skip (log warning, exit 0)
- TC6: sessions-rollup.tsv has new 14-col rows for plan_id → metrics computed correctly
- TC7: sessions-rollup.tsv has legacy 8-col rows for plan_id → metrics fall back to 0 + cold-start flag
- TC8: age-decay applied per DD-10 (synthetic rows: 5d / 60d / 100d → weights 1.0/0.5/0.0)
- TC9: atomic-write verified (tmp file present DURING write; final file appears only on completion)
- TC10: malformed plan_id → skip silently + emit one-line warning

**Verification at task end**: `bash scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` returns "10/10 PASS"; `bash -n scripts/hooks/planner-feedback-loop.sh` clean.

---

### D5 — sessions-rollup.tsv schema extension (back-compat appender) + new .planner-stats.tsv schema documentation

- **parallel_with**: []   (D5 is the schema foundation D4 depends on; must complete first)
- **blocks_on**: []
- **coordination_paths_exclusive**: [scripts/hooks/self-awareness-aggregate.sh, agent-workspace/memory/.planner-stats.tsv (NEW FILE — initially empty + header), agent-workspace/memory/self-awareness/_index.md (if exists)]
- **estimated_wall_min**: 8

**Files modified**:
1. `scripts/hooks/self-awareness-aggregate.sh` (~+15 LOC; extend schema awareness)

**Files created**:
1. `agent-workspace/memory/.planner-stats.tsv` (header-only initial; populated by D4 hook on first VERIFY-DONE)

**Specific edits**:

**self-awareness-aggregate.sh**:
- Update header comment lines 14-17 to document new 14-col schema (append cols documented)
- Update awk emit block (dev finds via `grep -n 'sessions-rollup' self-awareness-aggregate.sh`) to write 14 fields when D4-feedback data is available, OR fall back to 8 fields when no plan_id context (back-compat preserved for sessions that don't tie to a plan)
- **CRITICAL** (per DD-7 STOP-AND-ASK): if the existing emit is more entangled (e.g., the rollup is REWRITTEN not appended), dev STOPS-AND-FLAGS the architect

**.planner-stats.tsv** initial header:
```
task_class	sample_size	avg_wall_min	parallel_hit_rate	parallel_savings_avg	last_updated
```

**Documentation**: if `agent-workspace/memory/self-awareness/_index.md` exists, append schema note (verifier S348 spot-checks); if NOT exist, no new doc file (per Karpathy P2 simplicity).

**Verification at task end**: `head -1 .planner-stats.tsv` shows 6-col header; `head -1 sessions-rollup.tsv` shows extended schema (or original 8-col + comment noting extension is opt-in); awk `NF >= 14` test passes on a synthetic new-format row.

---

### D6 — 10-12 fire-tests + ADR D-069 PROPOSED + settings.json wire-up + plan-025 move pending → completed (dev task at end-of-session)

- **parallel_with**: []
- **blocks_on**: [D4, D5]
- **coordination_paths_exclusive**: [agent-workspace/memory/decisions/069-planner-self-calibration-protocol.md, .claude/settings.json (Stop chain section ~lines 400-450), agent-workspace/session-plans/pending/025-S346-planner-upgrade.md (mv to completed/)]
- **estimated_wall_min**: 6

**Files created**:
1. `agent-workspace/memory/decisions/069-planner-self-calibration-protocol.md` (~150 LOC; uses 12-field schema per `_template.md`)

**Files modified**:
1. `.claude/settings.json` (Stop chain section; insert `planner-feedback-loop.sh` AFTER `self-awareness-aggregate.sh` line ~408 + AFTER `profile-template-auto-populate.sh` line ~412 — chain ordering matters per § J)

**Specific edits to settings.json**:
- Find Stop block (lines 315-523)
- After `profile-template-auto-populate.sh` entry (~line 412), insert:
  ```json
  {
    "type": "command",
    "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/planner-feedback-loop.sh\""
  },
  ```

**ADR D-069 outline** (12-field per `_template.md`):
```
id: D-069-planner-self-calibration-protocol
title: Planner Self-Calibration Protocol — Phase 1b + parallel_with field + feedback-loop hook
date: 2026-05-16
status: PROPOSED
level: IMPL

author:
  - "Claude Opus 4.7"   # sandwich-dev S347 (executing plan-025 from architect S346)

source_evidence:
  - path: agent-workspace/session-plans/pending/025-S346-planner-upgrade.md
    section: "Whole plan — DD-1..DD-12 ratification"
  - path: agent-workspace/memory/observations/2026-05-16-planner-upgrade-proposal.md
    section: "E1-E4 enhancements + Concrete examples + Implementation plan"
  - path: .claude/agents/sandwich-architect.md
    section: "Phase 1b insertion at line 41"
  - path: .claude/agents/master-planner.md
    section: "Phase 1b mirror at line 47"
  - path: .claude/agents/sandwich-dev.md
    section: "Parallelism Discipline section new"
  - path: scripts/hooks/planner-feedback-loop.sh
    section: "Whole NEW hook"
  - path: agent-workspace/memory/self-awareness/sessions-rollup.tsv
    section: "8→14 col schema extension"

decision:
  Planner subagents (sandwich-architect, master-planner) MUST consume tracking-log
  telemetry in Phase 1b to ground budget + parallelism decisions in past actuals,
  not LLM guesses. Plan format gains required `parallel_with`/`blocks_on`/`coordination_paths_exclusive`
  fields per sub-track. Stop-cadence hook `planner-feedback-loop.sh` closes the
  feedback loop by aggregating per-plan throughput metrics to `.planner-stats.tsv`.

empirical_tuning_window: 30 days post-deployment

revisit_triggers:
  - 10+ plans consumed Phase 1b → re-evaluate cold-start gate threshold
  - 10+ successful 3-parallel runs → consider Q-PL1 4-parallel raise
  - any M-S<N>-N file-collision incident → tighten DD-4 lint
  - any plan formatted without `parallel_with` field → either back-fill OR mark deprecated-plan-format

supersedes: none (NEW)
superseded_by: none yet
```

**Verification at task end**: `bash scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` 10/10 PASS; `bash -n` clean on all 5 modified `.sh`/`.json` files; ADR D-069 file present with required frontmatter fields.

## § F. DoD checklist (≥30 items)

### File / LOC group (FILE-1..FILE-9)
- FILE-1: `.claude/agents/sandwich-architect.md` LOC delta within 75-90 (target +80) — actual measured via `git diff HEAD~ -- .claude/agents/sandwich-architect.md | grep -c ^+`
- FILE-2: `.claude/agents/master-planner.md` LOC delta within 45-60 (target +50)
- FILE-3: `.claude/agents/sandwich-dev.md` LOC delta within 35-50 (target +40)
- FILE-4: `.claude/agents/action-guide-planner.md` LOC delta within 8-15 (target +10)
- FILE-5: `.claude/agents/bdd-planner.md` LOC delta within 8-15 (target +10)
- FILE-6: NEW `scripts/hooks/planner-feedback-loop.sh` exists + ~150 LOC
- FILE-7: NEW `scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` exists + ~180 LOC
- FILE-8: NEW `agent-workspace/memory/.planner-stats.tsv` exists + header-only
- FILE-9: NEW `agent-workspace/memory/decisions/069-planner-self-calibration-protocol.md` exists + 12-field schema complete

### Agent template group (AGENT-1..AGENT-5)
- AGENT-1: grep `Phase 1b` in sandwich-architect.md → ≥1 match
- AGENT-2: grep `parallel_with` in sandwich-architect.md → ≥3 matches (declaration + template + lint)
- AGENT-3: grep `Phase 1b` in master-planner.md → ≥1 match
- AGENT-4: grep `Parallelism Discipline` in sandwich-dev.md → 1 match
- AGENT-5: grep `Calibration summary` in sandwich-architect.md → ≥2 matches (Phase 1b ref + Output ref)

### Hook group (HOOK-1..HOOK-3)
- HOOK-1: `bash -n scripts/hooks/planner-feedback-loop.sh` exits 0 (syntax clean)
- HOOK-2: `bash scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` → "10/10 PASS" (≥10 TC)
- HOOK-3: `.claude/settings.json` Stop chain grep `planner-feedback-loop.sh` → 1 match; chain position AFTER `self-awareness-aggregate.sh` AND AFTER `profile-template-auto-populate.sh` (verified by JSON parse + array index check)

### Schema / TSV group (SCHEMA-1..SCHEMA-3)
- SCHEMA-1: `head -1 agent-workspace/memory/self-awareness/sessions-rollup.tsv` shows extended 14-col schema OR original 8-col + documented extension path (per DD-7 STOP-AND-ASK clause if entanglement found)
- SCHEMA-2: legacy 8-col rows in sessions-rollup.tsv still readable by `self-awareness-aggregate.sh` re-run smoke (no parse errors)
- SCHEMA-3: `head -1 agent-workspace/memory/.planner-stats.tsv` shows 6-col header `task_class<TAB>sample_size<TAB>avg_wall_min<TAB>parallel_hit_rate<TAB>parallel_savings_avg<TAB>last_updated`

### Parallel-discipline group (PARALLEL-1..PARALLEL-3)
- PARALLEL-1: synthetic plan with `parallel_with: [D2]` + disjoint `coordination_paths_exclusive` passes lint check (lint tool can be inline awk in D4 hook for now)
- PARALLEL-2: synthetic plan with `parallel_with: [D2,D3]` + OVERLAPPING `coordination_paths_exclusive` FAILS lint check (refuse + exit non-zero)
- PARALLEL-3: synthetic plan with `parallel_with: [D2,D3,D4,D5]` (4 parallel) FAILS lint check (exceeds DD-5 max-3 ceiling)

### Calibration loop group (CALIB-1..CALIB-2)
- CALIB-1: simulate `planner-feedback-loop.sh` run with synthetic VERIFY-DONE plan → `.planner-stats.tsv` row appears for derived task_class
- CALIB-2: synthetic 2nd dispatch of sandwich-architect for similar task_class → architect's plan output § Calibration summary cites the past task_class metric from `.planner-stats.tsv`

### ADR group (ADR-1)
- ADR-1: `agent-workspace/memory/decisions/069-planner-self-calibration-protocol.md` PROPOSED + 12-field schema complete + cites this plan-025 + observation as source_evidence + `empirical_tuning_window: 30 days` clause present

### Compliance group (COMPLIANCE-1..COMPLIANCE-5)
- COMPLIANCE-1: `git diff HEAD~ -- PROJECT_CHARTER.md` → empty (0 charter writes)
- COMPLIANCE-2: `git diff HEAD~ -- agent-workspace/constitution/` → empty (0 constitution writes)
- COMPLIANCE-3: `git diff HEAD~ -- packages/ apps/` → empty (0 production code writes)
- COMPLIANCE-4: `git log --oneline -5` shows S347 dev commits per D-060; `git push` audit shows 0 agent pushes
- COMPLIANCE-5: VBW protocol applied — dev session log lines cite file:line for every edit decision

### Smoke / regression group (SMOKE-1..SMOKE-3)
- SMOKE-1: `bash scripts/hooks/firing-tests/run-all.sh` shows ≥0 NEW regressions vs baseline (planner-feedback-loop-fire-test added but doesn't break existing suite)
- SMOKE-2: `bash scripts/hooks/self-awareness-aggregate.sh` runs clean (no parse errors against extended schema)
- SMOKE-3: synthetic /clear cycle on a 1-commit branch confirms `planner-feedback-loop.sh` Stop-hook invocation doesn't slow Stop chain >5sec

### Bookkeeping group (BOOK-1..BOOK-3)
- BOOK-1: `agent-workspace/memory/sessions/session-347.md` exists with VBW dev log + Compliance attestation + Deviations from plan section
- BOOK-2: `agent-workspace/memory/observations/sandwich-dev-S347-planner-upgrade.md` written (~150-250 LOC summary)
- BOOK-3: plan-025 moved `pending/` → `completed/` via `git mv` at end of dev session (per S339+S342 close-bookkeeping pattern)

**Total: 30 DoD criteria (FILE×9 + AGENT×5 + HOOK×3 + SCHEMA×3 + PARALLEL×3 + CALIB×2 + ADR×1 + COMPLIANCE×5 + SMOKE×3 + BOOK×3 = 37 — exceeds ≥30 target).**

## § G. Architecture Questions (AQ-1..AQ-10) — pre-answered

- **AQ-1**: Max parallel dev ceiling? → **3 INITIALLY** per Q-PL1 ratification; revisit at 10+ successful 3-parallel runs (DD-5)
- **AQ-2**: Phase 1b mandatory or opt-in? → **MANDATORY for ≥3 sub-tracks; SKIPPABLE for 1-2 FOCUSED_IMPL** per Q-PL2 ratification (DD-6); skip-decision MUST be explicit
- **AQ-3**: Schema extension breaking? → **APPEND (back-compat)** per Q-PL3 ratification (DD-7); legacy 8-col rows preserved + tolerated by readers via `NF >= 14 ? $14 : ""` pattern
- **AQ-4**: Feedback-loop hook cadence? → **Stop with debounce per plan_id** per Q-PL4 ratification (DD-8); marker `.planner-feedback-emitted-<PLAN_ID>` prevents re-process
- **AQ-5**: First-run cold-start — `.planner-stats.tsv` empty; how does architect calibrate? → **Phase 1b gracefully degrades to default 100-150K budget when sample_size<3**; flag in calibration summary as "cold-start"; DO NOT block plan authoring on cold-start (Karpathy P2 simplicity)
- **AQ-6**: Plan format change breaks existing in-flight plans? → **NO** — pending/ plans grandfathered; new fields apply to NEW plans authored after plan-025 ships; documented in this plan-025 § migration note (this section); lint checks ONLY new plans (detection: `parallel_with` field appears anywhere in plan; if absent, treat as legacy + skip lint)
- **AQ-7**: Parallel dev coordination_paths violation — what then? → **lint refuses dispatch before parallel** (DD-4); architect re-plans; if dispatch slipped past lint (bug) and runtime collision occurred → M-S<N>-N entry recorded + verifier S348 audits + emergency single-thread fallback engaged by main session
- **AQ-8**: `planner-feedback-loop.sh` competing with `self-awareness-aggregate.sh`? → **Separate concern; co-exist** — self-awareness aggregates per-session profile cards (model × effort × thinking); planner-feedback aggregates per-plan task_class stats; both Stop-chain; planner-feedback runs AFTER self-awareness-aggregate (chain position per DD-12 + § J coordination)
- **AQ-9**: Rate-limit on parallel devs at Claude Code layer? → **Cap at 3 initially mitigates** per DD-5; observe + raise to 4 after 10+ successful runs; observation RM1 cites "Cap at 3 concurrent; fall back to sequential on rate-limit error" as mitigation
- **AQ-10**: Should main session also use parallel-dispatch for non-sandwich workflows? → **OUT-OF-SCOPE for plan-025** — covered by E2/E3 in observation for sandwich pattern; main session already exercising 4-parallel agents this turn (research deep-dives) as live test; productizing main-session parallel-dispatch = separate future plan

## § H. 5-source evidence chain (per I-S2)

| Claim | Sources (≥5) |
|---|---|
| Planners currently zero references to tracking logs | (1) Grep `parallel_with\|parallel-dispatch\|concurrent` on `.claude/agents/` = 0 matches (this architect's VBW); (2) `.claude/agents/sandwich-architect.md:32-40` Phase 1 reads spec+constitution+code only; (3) `.claude/agents/master-planner.md:40-47` Phase 1 reads PROJECT_CHARTER+specs+constraints only; (4) observation `2026-05-16-planner-upgrade-proposal.md` § Current state — empirical audit table; (5) observation § "Total parallel-dispatch directives across 692 LOC of planner contracts: 2 vague mentions, 0 concrete instructions" |
| Tracking logs sit unused | (1) `agent-workspace/memory/dispatch.jsonl` 530 rows readable (read 3 head lines this VBW; format = JSON-per-line with event/dispatch_id/agent_type/duration_ms/outcome/tokens_used); (2) `component-telemetry.jsonl` 3666 rows readable (read 3 head); (3) `self-awareness/sessions-rollup.tsv` 623 rows readable (read 5 head; schema = session_n session_id ts_utc tokens_real tools_used subagents failure_codes wall_min); (4) Grep `dispatch.jsonl\|sessions-rollup` in `.claude/agents/` = 0 matches; (5) consumers ARE: `scripts/hooks/correction-rate-aggregator.sh` + `self-awareness-aggregate.sh` + `profile-template-auto-populate.sh` (verified via Grep on `scripts/hooks/`) |
| Claude Code Agent tool supports parallel-dispatch | (1) main session DID dispatch 4 parallel research subagents this turn (per current-execution.md § S343-S344 row "Harness analysis observations written this turn"); (2) Claude Code Agent tool docs (observation cites "Claude Code parallel-dispatch convention"); (3) dispatch.jsonl row spacing analysis (observation § "The Claude Code Agent tool supports up to 3-4 parallel background dispatches per the harness profile"); (4) recent plan-020 S337 had 4 independent sub-tracks but used 1 sequential dev (observation table § Sandwich-pattern parallelism); (5) recent plan-021 S341 had 6 independent sub-tracks but used 1 sequential dev (same source) |
| Plan format example showing improvement | (1) observation § "Concrete examples (what plan-022 would have looked like with these upgrades)" with NDH adapter as worked example; (2) plan-022 actual sequential dispatch took ~31 min (S344 dev returned per current-execution.md); (3) projected parallel: D1 sequential 12 min + parallel max(D3=8,D4=6,D5=3)=8 min = 20 min total = 35% saving; (4) projection conservative across 4 recent multi-track sessions = 25% average; (5) `agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md` D1-D5 sub-track decomposition is the live reference |
| Feedback-loop hook precedent | (1) `scripts/hooks/self-awareness-aggregate.sh` is similar Stop-cadence aggregator (mirror pattern); (2) `scripts/hooks/correction-rate-aggregator.sh` is another Stop-cadence rollup; (3) `scripts/hooks/profile-template-auto-populate.sh` writes per-model card; (4) `scripts/hooks/escalation-engine.sh:56` debounce-marker pattern reference; (5) `scripts/hooks/firing-tests/self-awareness-aggregate-fire-test.sh` is fire-test pattern reference |

## § I. Risk-Mitigation (RM1..RM10)

| # | Risk | Probability | Impact | Mitigation |
|---|---|---|---|---|
| RM1 | Parallel devs hit Claude Code rate-limit | Medium | Medium | Cap at 3 initially (DD-5); fall back to sequential on rate-limit error; AQ-9 mitigates |
| RM2 | Stale calibration data biases planner | Medium | Medium | Age-decay per DD-10 (30d half / 90d drop); ADR D-069 § Empirical-Tuning-Window 30 days revisit |
| RM3 | Architect over-parallelizes; file-collision | Medium | High (corrupted state) | Lint validates `coordination_paths_exclusive` disjoint across `parallel_with` siblings (DD-4); refuse dispatch otherwise; M-S<N>-N recorded if slip past lint |
| RM4 | feedback-loop hook adds 5-10sec to Stop chain | Low | Low | Debounce per plan_id (DD-8); only fires when VERIFY-DONE detected this Stop window; baseline Stop chain ~5min anyway per Item-1 observation |
| RM5 | Phase 1b read budget overruns context | Low | Medium | Cap last 30 rows per log per DD-2; total ~90 rows = ~5sec budget = ~5K tokens worst-case |
| RM6 | Schema extension breaks downstream readers | Low | Medium | Append-only per DD-7; back-compat read via `NF >= 14 ? $14 : ""`; SCHEMA-2 DoD verifies; STOP-AND-ASK clause if entanglement found at D5 |
| RM7 | ADR D-069 churn — early calibration data unreliable | Medium | Low | ADR PROPOSED at IMPL tier (no cool-down per severity-schema); `empirical_tuning_window: 30 days` clause invites revisit; AP-7 anti-vacuous-defer satisfied |
| RM8 | Dev attempts E5+ scope creep (advanced parallelism, auto-tuning) | Low | High (budget blow-up) | This plan binds E1-E4 explicitly; ANY E5+ scope = STOP-AND-SPLIT per § B; verifier S348 audits commit count + LOC delta vs plan |
| RM9 | Calibration summary in plan output becomes noisy | Low | Low | Cap at 1 paragraph per DD-11; explicit format template; AGENT-5 DoD verifies grep match |
| RM10 | New TSV `.planner-stats.tsv` collides with existing file | Low | Low | Grep `agent-workspace/memory/.planner-stats*` confirms namespace clear (this architect's VBW pass — 0 matches); SCHEMA-3 DoD verifies header-only initial state |

## § J. Coordination paths (main session avoids during S347 IMPL window)

Per S341/S344 coordination-rule pattern, main session avoids these paths during S347 dev dispatch + S348 verifier dispatch:

- `.claude/agents/sandwich-architect.md` (D1)
- `.claude/agents/master-planner.md` (D2)
- `.claude/agents/sandwich-dev.md` (D3)
- `.claude/agents/action-guide-planner.md` (D3)
- `.claude/agents/bdd-planner.md` (D3)
- `scripts/hooks/planner-feedback-loop.sh` (D4 new)
- `scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` (D4 new)
- `scripts/hooks/self-awareness-aggregate.sh` (D5)
- `agent-workspace/memory/.planner-stats.tsv` (D5 new)
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (D5 schema-extension target)
- `agent-workspace/memory/self-awareness/_index.md` (D5 optional doc cross-ref, if exists)
- `.claude/settings.json` (D6 wire-up; lines 315-523 Stop chain only)
- `agent-workspace/memory/decisions/069-planner-self-calibration-protocol.md` (D6 new ADR)
- `agent-workspace/session-plans/pending/025-S346-planner-upgrade.md` (D6 mv target at end-of-session)
- `agent-workspace/memory/sessions/session-347.md` (D6 dev session log)
- `agent-workspace/memory/observations/sandwich-dev-S347-planner-upgrade.md` (D6 dev observation file)
- `agent-workspace/memory/observations/sandwich-verifier-S348-planner-upgrade-verify.md` (S348 verifier window; verifier-has-no-Write recovery — main writes per S312/S314/S321/S333/S339/S342 precedent)

Within IMPL window, main session may still consume tracking-log telemetry files for read-only inspection (dispatch.jsonl, component-telemetry.jsonl, sessions-rollup.tsv) since D5's schema-extension is append-only — no row reorder + no header rewrite for existing rows.

## § K. Budget envelope

**Recommended**: 100-150K Opus FOCUSED_IMPL.

Breakdown (per Phase 1b architect cold-start estimate — no prior task_class=planner-template-upgrade data):
- D1 (sandwich-architect.md edit): ~10K (target file 183 LOC + ~80 LOC delta; bounded surgery)
- D2 (master-planner.md edit): ~8K (target 168 LOC + ~50 LOC delta)
- D3 (sandwich-dev.md + 2 cross-refs): ~12K (3 files; ~60 LOC total)
- D4 (NEW hook + firing-test): ~40K (architect-grade hook design + ≥10 TC; iterative TC-by-TC)
- D5 (schema extension + new TSV): ~15K (1 hook edit + 1 new file header; STOP-AND-ASK contingency reserve)
- D6 (ADR + settings.json wire + bookkeeping): ~15K (ADR ~150 LOC + JSON edit + session log + observation + plan mv)
- VBW reads + buffer: ~30K

**Total**: ~130K central estimate (within 100-150K envelope; ~15% reserve for cold-start surprises in D4/D5).

Cold-start declaration per DD-11: this plan's budget = 100-150K is **NOT** Phase 1b consumed (no `.planner-stats.tsv` data exists yet — bootstrap session); estimated from boilerplate + architect VBW + sub-track estimate sums above. ADR D-069 § Empirical-Tuning-Window revisits this estimate at the 10+ Phase-1b-consumed plans mark.

## § L. AP-23 attestation

| Issue | Instance count | AP-23 decision | Rationale |
|---|---|---|---|
| Planner subagent telemetry-blindness | 1st | INCLUDE (this plan E1) | User-stated bottleneck; 4-Q ratified design; not a refinement-of-rule (this IS the rule) |
| Parallel-dispatch dormancy | 1st | INCLUDE (E2+E3) | Capacity exists in Claude Code; user explicitly asked; not refinement |
| Throughput metric absence | 1st | INCLUDE (E4) | Calibration loop closure; Charter Principle 8 alignment |
| Q-PL1..Q-PL4 design questions | 1st each | RATIFIED per user 2026-05-16T~20:30 SEAST | No 2nd instance reached |
| Phase 1b read-budget cap (DD-2) | 1st (in this plan) | INCLUDE | If 2nd instance arises (architect over-reading) → ADR D-069 § Empirical-Tuning-Window revisits |
| `.planner-stats.tsv` schema (DD-9) | 1st | INCLUDE | If 2nd instance arises (cols missing) → ADR D-069 schema_version field |
| Age-decay thresholds (DD-10) | 1st | INCLUDE | ADR D-069 § Empirical-Tuning-Window 30 days revisit named (AP-7) |

## § M. Compliance attestation

| Rule | Status | How upheld |
|---|---|---|
| harness_priority_one | ✓ | this plan IS harness investment; supersedes Phase 4 product work per user 2026-05-16 directive |
| AP-1 fresh-context | ✓ this PLAN; ✓ planned for S347 dev + S348 verifier | architect S346 ran fresh-context per architect_dispatch_template; S347 dev planned fresh-context; S348 verifier MUST fresh-context |
| dont_self_pause_at_session_boundary | ✓ | main session orchestrates architect → dev → verifier in continuous turn; this plan output is dispatch-ready |
| autonomous_continue_no_self_pause | ✓ | no AskUserQuestion in this plan; Q-PL1-4 already ratified; SCOPE/CHARTER untouched |
| stop_offering_routing_branches | ✓ | this plan does NOT enumerate (a)/(b)/(c)/(d) next-options at end |
| verify_phase_before_next_phase | ✓ planned | verifier S348 will empirically audit S347 dev outputs (10/10 firing-test + 30/30 DoD + ADR D-069 present + lint pass) |
| full_autonomous_no_supervised | ✓ | AskUserQuestion only for SCOPE/CHARTER; this is IMPL-tier; ratified |
| D-060 commit-policy | ✓ | architect commits this plan (per pre-dispatch-architect-commit-guard.sh recovery + D-060); dev commits own IMPL (per D-060); 0 pushes |
| D-062 atomic-write-doctrine | ✓ planned | D4 hook + D5 TSV all use tmp+mv per existing self-awareness-aggregate.sh pattern |
| D-064 path-safety | ✓ planned | D4 hook uses safe path patterns from packages/_shared/path_safety.py (architect VBW confirmed module exists) |
| 0 charter writes | ✓ | PROJECT_CHARTER.md not in any sub-track |
| 0 constitution writes | ✓ | agent-workspace/constitution/** not in any sub-track; ADR D-069 lives in `decisions/` |
| 0 production code | ✓ | packages/ + apps/ not in any sub-track |
| 0 human-workspace writes | ✓ | human-workspace/ not in any sub-track |
| VBW protocol | ✓ | architect read all 5 agent templates + 3 tracking-log heads + 3 hook references + ADR template + recent plan-021 + recent ADR D-066 end-to-end |
| Karpathy P1-P4 | ✓ | P1 think-first (4 Qs ratified before plan); P2 simplicity (no E5+ creep); P3 surgical (3 fields per sub-track + 1 hook + 1 ADR); P4 goal-driven (every DoD has measurable verification) |
| dispatch-templates-via-pre-dispatch-architect-commit-guard.sh | ✓ | this plan output committed by main per S341 D3 hook landing; architect-can-commit-own-plan allowed via STOCKFORGE_ALLOW_ARCHITECT_COMMIT env var per S341 D3 |

## § N. Out-of-scope (with explicit AP-7 revisit triggers)

1. **E5+ advanced parallelism (4+ devs, dynamic load balancing, parallel verifiers)** — DEFERRED; revisit trigger: 10+ successful 3-parallel runs without incident (per Q-PL1 + DD-5 + ADR D-069)
2. **Main-session parallel-dispatch productization (non-sandwich workflows)** — DEFERRED per AQ-10; revisit trigger: 5+ informal main-session parallel dispatches with measured savings
3. **Cross-plan calibration (multi-plan composite metrics)** — DEFERRED; revisit trigger: `.planner-stats.tsv` has ≥20 plans across 5+ task_classes
4. **Backfill of historical sessions-rollup rows with plan_id metadata** — DEFERRED per § B implementation plan note "going forward; no backfill needed for first cycle"; revisit trigger: architect requests historical comparison ≥3 times
5. **GUI / dashboard for `.planner-stats.tsv`** — OUT-OF-SCOPE (no GUI work per Streamlit-only-when-product per CLAUDE.md identity); revisit trigger: user requests dashboard
6. **Auto-tuning of DD-2 read budget / DD-10 age-decay / DD-5 parallel ceiling** — DEFERRED; revisit trigger: ADR D-069 § Empirical-Tuning-Window 30 days post-deployment
7. **`bdd-planner.md` Phase 1b mirror (full upgrade)** — DEFERRED to a future planner-upgrade-phase-2 plan; revisit trigger: 5+ BDD-planner dispatches showing benefit from Phase 1b would gain
8. **Cross-task_class transfer learning (e.g., adapter-impl experience informing harness-fix budget)** — DEFERRED; revisit trigger: 3+ cases where transfer would have helped + sample_size insufficient
9. **Hook performance optimization for `planner-feedback-loop.sh`** — DEFERRED if Stop chain delta <5sec; revisit trigger: SMOKE-3 fails OR Item-1 Stop performance audit re-runs

---

## Recommendations for sandwich-dev S347

1. **Read plan-025 end-to-end before any edit** (VBW per Phase 1 of sandwich-dev.md). 
2. **Execute D1 → D2 → D3 in sequence** (mirror Phase 1b shape from D1 to D2; cross-refs in D3 reference the Parallelism Discipline section that lands in same sub-track).
3. **Execute D5 BEFORE D4** (per blocks_on chain — schema must exist before hook reads it).
4. **STOP-AND-ASK if D5 finds self-awareness-aggregate.sh entanglement is worse than expected** (per DD-7 STOP-AND-ASK clause).
5. **STOP-AND-SPLIT if scope creep tempts E5+** (per RM8).
6. **For D4 firing-tests, mirror `scripts/hooks/firing-tests/self-awareness-aggregate-fire-test.sh` structure** (PER_TEST_TIMEOUT default, run_hook helper, clean_state pattern, TEMPDIR + trap cleanup).
7. **Commit boundary**: per D-060, dev decides; recommended = 1 commit per sub-track (D1-D6 = 6 commits) OR 1 fat commit per IMPL session boundary. Either acceptable; dev's call.
8. **Observation file**: per S339 F5 finding, sandwich-dev MUST write `agent-workspace/memory/observations/sandwich-dev-S347-planner-upgrade.md` (~150-250 LOC; format mirrors `sandwich-architect-S337-phase-d-theme-l-plan.md`).
9. **At end-of-session**: `git mv agent-workspace/session-plans/pending/025-S346-planner-upgrade.md agent-workspace/session-plans/completed/` per BOOK-3 DoD.
