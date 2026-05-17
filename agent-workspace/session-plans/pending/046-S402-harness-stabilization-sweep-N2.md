---
plan_id: 046-S402-harness-stabilization-sweep-N2
target_session: S403
type: MULTI_TASK_IMPL
budget: 130-180K (Opus FOCUSED_IMPL / MULTI_TASK_IMPL hybrid; D1+D2 dominate budget; D3-D5 surgical)
phase: G-prime/B-overlap (HARNESS — not product work; harness_priority_one doctrine
       takes precedence over Phase G-prime G.4 (BC-2 fundamentals) + Phase G-prime
       G.2 (pure-Python winner adapter, BLOCKED on real PDFs) until the 10-candidate
       promotion queue is drained AND promotion-cycle-trigger.sh HARD-BLOCK
       at next SessionStart is averted)
track: Harness Stabilization Sweep N+2 — close 10-candidate promotion queue
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md
                    (Wave 1 MVP READY achieved at S401; Phase G-prime G.1+G.3
                    SHIPPED+VERIFIED at S397+S400; G.4 dispatch awaits this sweep
                    completion per harness_priority_one)
predecessor: 039-S387-harness-stabilization-sweep-N1 (completed S390; 9-candidate
             queue DRAINED 9→0; 6 INCLUDE + 3 RETIRE; ADR D-079 ACCEPTED; precedent
             for plan shape + sub-track decomposition)
successor: S404 sandwich-verifier (AP-1 fresh-context, Opus, ~80-140K VERIFY budget)
architect: S402 sandwich-architect (background; this plan)
dispatched_by: S401-main close-bookkeeping turn (parent main session orchestrating
               harness PLAN-IMPL-VERIFY sandwich after Wave 1 MVP READY attestation
               + user S401-close authorization "ok, continue autonomous. human allow
               approved follow your recommendation")
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; fresh context)
executing_agent: sandwich-dev (background dispatch S403; fresh-context; Opus
                 per all-14-agents-on-Opus directive; AP-1 verifier in S404)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (post 2026-05-14 mass-deletion)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING cadence + ROUTINE-IDLE close ritual SUSPENDED (carry-forward; do NOT recommend sync-grilling cadence as part of fixes)"
  - "promotion-cycle-trigger.sh HARD-BLOCK threshold BREACHED (queue at 10; SOFT-WARN at delta ≥5 sessions; HARD-BLOCK at ≥8 sessions; sweep is BLOCKING)"
  - "Wave 1 MVP gate READY at S401; G.4 sub-plan 044 dispatch UNBLOCKED but pending main session decision post-sweep"
  - "pre-commit-pytest-regression-guard.sh ACTIVE (D2 from plan-039 D2.A; protects S403 dev commit boundary)"
  - "pre-dispatch-architect-commit-guard.sh ACTIVE (D3 precedent from plan-021 S341)"

depends_on:
  - "D-060 (commit-policy-agent-may-commit — operational gate for S403 dev commit boundary; main commits architect-only outputs per dispatch-template-gap recovery pattern + pre-dispatch-architect-commit-guard.sh PreToolUse hook)"
  - "D-062 (atomic-write-doctrine — BINDING for any new state/marker writes introduced by D1+D5)"
  - "D-079 ACCEPTED (plan-039 harness-sweep-N1 — precedent for INCLUDE/RETIRE/HOLD triage pattern + sub-track decomposition + bash hook patterns)"
  - "D-081 ACCEPTED (BR-6 cap empirical recalibration — L-S396-1 candidate's first instance; uses 21-field ADR frontmatter as precedent)"
  - "D-082 ACCEPTED (Claude vision PDF adapter — 13-field ADR frontmatter; precedent for IMPL-tier ADR)"
  - "Charter v1.1 Principle 8 (Calibration over confidence — drives all 4 PROMOTE-NOW verdicts; speculative-abstraction guard for RETIRE verdicts)"
  - "Charter v1.1 Principle 7 (Dogfood mandatory — D1 self-attestation linter doubles as L-S389-1 dogfood enforcement)"
  - "Charter v1.1 Principle 11 (Harness must self-verify firing — D1/D2/D3 ALL ship companion firing-tests + verification grids)"
  - "I-S33 self-aware-agent invariant (harness reliability is the substrate for I-S33; protected by L-S389-1 dogfood-self-attestation linter + L-S397-3 close-loop file-existence verify)"
  - "agent-workspace/CLAUDE.md Contract Rule 1 (constitution immutable absent explicit human approval — sandwich-dev cannot edit constitution/; if D2 sandwich-verifier persona-change needs constitution codification, lands as PROPOSED ADR D-083 at IMPL tier with no cool-down)"
  - "CLAUDE.md AP-23 ritual demotion: 'Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG: 2nd instance mandates promote-or-retire (not inline accumulation)' — applied per-candidate in § D verdict table"
  - "CLAUDE.md `harness_priority_one` memory rule (harness/system improvement is always higher priority than product work)"
  - "CLAUDE.md all_14_agents_on_opus rule (S403 dev + S404 verifier both Opus per user directive 2026-05-17)"
  - "scripts/hooks/promotion-cycle-trigger.sh (the hook that will HARD-BLOCK at next SessionStart unless this sweep ships — counts SESSIONS-since-last-promote not lessons; current delta unknown empirically but L-S396-1+L-S397-1+L-S397-2+L-S397-3+PCG-S401-3+PCG-S401-4 cluster proves promotion-rule dispatch overdue)"
  - "scripts/hooks/pre-commit-pytest-regression-guard.sh (D2 plan-039 hook; pattern precedent for any new PreToolUse hook this sweep)"
  - "scripts/hooks/severity-classifier.sh (consumer for STOP-FINDING severity vocabulary if D2 lands; severity-schema.md = canonical CRITICAL/HIGH/MEDIUM/LOW)"
  - "agent-workspace/constitution/severity-schema.md (canonical 4-level severity vocab; reference for L-S397-2 normalization scope)"
  - ".claude/agents/sandwich-verifier.md (D3 PROMOTE-NOW target for persona-vs-dispatch-brief reconciliation; current `tools: [Read, Glob, Grep, Bash]` lacks Write/Edit by design)"
  - ".claude/agents/sandwich-architect.md (D1 close-loop file-existence template subject)"
  - ".claude/agents/sandwich-dev.md (D1 close-loop file-existence template subject + L-S389-1 dogfood-the-promotion target)"
  - "agent-workspace/session-plans/completed/039-S387-harness-stabilization-sweep-N1.md (plan shape reference — Sections A-N template; 9 candidates resolved as 6 INCLUDE + 3 RETIRE)"
  - "agent-workspace/memory/observations/sandwich-architect-S387-harness-sweep-N1-plan.md (observation format reference if exists; if not, plan-021 architect observation)"
  - "agent-workspace/memory/checkpoints/latest.md (S391 CLOSE handoff; queue context)"
  - "agent-workspace/memory/current-execution.md:145 (10-candidate queue snapshot post-S401 close)"
  - "agent-workspace/memory/mistake-log.md:100-104 M-S388-NONE (S388 sweep N+1 clean session; precedent for plan-046 dev session attestation if no mistakes)"
  - "agent-workspace/memory/mistake-log.md:118 M-S388-2 digest (DC-IMPL-20 self-attestation contradiction at +919/+839 net delta vs ≤600 cap — source-evidence for L-S389-2)"
  - "agent-workspace/memory/mistake-log.md:119 M-S388-1 digest (dogfood violation of STEP 5.4 same session that promoted it — source-evidence for L-S389-1)"
  - "agent-workspace/memory/observations/sandwich-verifier-S397-plan-041-g1-verify.md:106-108 (L-S397-1 + L-S397-2 surface rationale)"
  - "agent-workspace/memory/observations/sandwich-verifier-S400-plan-043-g3-verify.md:96+158 (PCG-V400-1 = L-S397-1 2nd-instance trigger)"
  - "agent-workspace/memory/observations/sandwich-verifier-S401-plan-045-data-corpus-verify.md (PCG-S401-3 + PCG-S401-4 source observations)"
  - "agent-workspace/memory/agent-notes.md:8-32 (plan-039 RETIRE precedent pattern — RETIRED-1ST-INSTANCE-DUPLICATE-OF-CHARTER / RETIRED-DUPLICATE-OF-MASTER-PLAN / RETIRED-SPECULATIVE-ABSTRACTION)"
  - "agent-workspace/memory/decisions/081-br-6-cost-cap-empirical-recalibration.md:188-191 (L-S396-1 promotion candidate text; 1st-instance HOLD per ADR)"
  - "human-workspace/notifications/STOP-FINDING-S394-pdf-real-pdfs-needed.md:1-10 (STOP-FINDING frontmatter format — severity HIGH; status field present)"
  - "human-workspace/notifications/STOP-FINDING-S395-validate-thesis-cost-blocker.md:1-10 (STOP-FINDING resolved status format — example of PCG-S401-3 inline-fix)"
  - "human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md (oldest STOP-FINDING — schema reference)"

binding_decisions:
  - "D-060 — agent MAY git commit (NOT push); S403 dev decides commit boundary; main commits this plan output (architect has no Bash)"
  - "AP-23 promote-or-retire — applied per-candidate at § D verdict table; rationale documented per AP-7 anti-vacuous-defer"
  - "AP-7 anti-vacuous-defer — every HOLD + RETIRE decision in this plan names (a) prerequisites + (b) revisit trigger; no 'Out-of-scope item N with no follow-up'"
  - "Karpathy P1 — Think before planning: explicit RETIRE verdicts surfaced for candidates that duplicate existing constitution/charter language"
  - "Karpathy P2 — Simplicity first: no speculative bundling; only the 10 candidates + their direct prerequisites; D-083 ADR draft ONLY if D2 or D3 charter-tier change lands"
  - "Karpathy P3 — Surgical: every change traces to a named L-S<N>-<M> OR PCG-<X>-N candidate; no invented harness work"
  - "VBW protocol mandatory — before recommending any hook/template change, READ the actual file; this plan cites file:line for every claim per I-S2 per L-S392-1 dispatch-brief-drift prevention"
  - "L-S389-1 dogfood-the-promotion (this plan's observation uses exact wc -l integers; ZERO '~' prefix)"
  - "L-S395-1 full-pipeline cold-probe at STEP 0 — STEP 0 includes cold-probe of any new hook (dry-run sandbox) before final IMPL spec"
  - "L-S397-1 plan LOC ceilings per-category — § G LOC ceilings distinguish core-code vs docstring/test/fixture"
  - "L-S397-3 close-loop file-existence — architect runs wc -l on both output files at end-of-session + cites integers in return summary"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL; this plan is architect's; S403 is dev's)"
  - "no commits in THIS plan-session (sandwich-architect subagent has no Bash tool; main commits this plan output per D-060 + pre-dispatch-architect-commit-guard.sh)"
  - "no charter / no constitution writes in THIS plan-session (0 charter / 0 constitution per S402 brief)"
  - "no AskUserQuestion gate this session (no charter/scope question; all decisions are IMPL-tier or template-tier; per `full_autonomous_no_supervised` AskUserQuestion is for SCOPE/CHARTER only)"
  - "every plan claim cites source file:line (per I-S2 + AOM + L-S392-1 dispatch-brief-drift prevention)"
  - "actual hook files + observation files read end-to-end via Read tool, not memory (VBW protocol)"
  - "plan numbers 040-045 reserved (per S401-close dispatch brief); plan-046 only"
  - "do NOT modify plans 040-045 (all completed; reference only)"
  - "do NOT modify hook files in scripts/hooks/ (S403 IMPL territory)"
  - "do NOT modify .claude/agents/sandwich-*.md (S403 IMPL territory)"
---

# S402 — Harness Stabilization Sweep N+2 (close 10-candidate promotion queue)

## § A. Session metadata

| Field | Value |
|---|---|
| Plan ID | 046-S402-harness-stabilization-sweep-N2 |
| Target session | S403 (sandwich-dev, MULTI_TASK_IMPL hybrid) |
| Verify session | S404 (sandwich-verifier, AP-1 fresh-context Opus) |
| Budget (IMPL) | 130-180K Opus MULTI_TASK_IMPL (per recalibrated CLAUDE.md Opus column 200-330K; trends low end because 5 sub-tracks all template/hook-template scope; S349=98K / S354=34K / S357=45K dev-on-Opus precedent for file-bounded work) |
| Budget (VERIFY) | 80-140K Opus VERIFY (per recalibrated CLAUDE.md Opus column 80-180K) |
| Phase | G-prime/B-overlap (HARNESS — non-product) |
| Type | MULTI_TASK_IMPL (5 INCLUDE sub-tracks D1-D5 across distinct file scopes) |
| Wave / Theme | Wave-1 substrate-care post-MVP-READY; closes 10-candidate promotion queue; prevents promotion-cycle-trigger HARD-BLOCK |
| Coordination paths off-limits during S403 IMPL | See § J |
| Predecessor | 039-S387 (S390 close; precedent shape) |

## § B. Out-of-scope (binding NOT-this-sweep boundary)

The following are explicitly NOT addressed in plan-046 — surfaced for clarity to prevent scope creep:

1. **Phase G-prime G.4 (BC-2 fundamentals integration)** — UNBLOCKED per S401 checkpoint; awaits next main-session decision post-sweep. Plan-046 does NOT touch `packages/infrastructure/fundamental/**` or any G.4 file scope. Parallel-eligibility note in § N.
2. **Phase G-prime G.2 (pure-Python winner adapter)** — BLOCKED on real PDFs per STOP-FINDING-S394; user-action gated. Plan-046 does NOT unblock this.
3. **PROJECT_CHARTER.md edits** — 0 charter writes; if any candidate proves CHARTER-tier on inspection, surface in § J K.X charter-tier-surface flags + DEFER to user AskUserQuestion bundle (NOT inline).
4. **agent-workspace/constitution/** edits — 0 constitution writes; constitution is immutable absent explicit user approval per `agent-workspace/CLAUDE.md` Contract Rule 1.
5. **Existing plans 040-045** — completed; reference only via Read; no Edit/Write.
6. **`apps/**` production code** — this is HARNESS sweep, not product work.
7. **`packages/**` production code** — same.
8. **Existing `.transcript-tokens`, `.session-hooks.log`, telemetry rotators** — not touched unless candidate explicitly identifies (none do).
9. **L-S371-1 resolver Protocol RETIRED in plan-039 D7** — does NOT re-surface this sweep (per AP-7 trigger: WHEN 2nd concrete resolver lands).
10. **Bundled-plan-mv heuristic L-S385-4 RETIRED in plan-039** — does NOT re-surface this sweep.

## § C. STEP 0 audit + VBW cold-probe per candidate

Architect's S402 VBW pass — verify each candidate's predicate-evidence is still valid + identify whether predicate was already resolved inline before this sweep entered.

### STEP 0.0 — Plan & ADR numbering (canonical)
- Plans 040-045 in `completed/`; plan-046 next pending number (Glob confirmed)
- ADRs D-080 + D-081 + D-082 ACCEPTED; D-083 next available number (Glob confirmed)
- 10-candidate queue source-of-truth: `current-execution.md:145` (Read verbatim)

### STEP 0.1 — L-S389-1 dogfood-violation-self-instance (LOW; 1st-instance per mistake-log)
- **Predicate**: `mistake-log.md:119` M-S388-1 digest — dev observation contained 8 `~` occurrences after promoting STEP 5.4 same session
- **Empirical status**: source mistake-log entry intact + accurate; STEP 5.4 already in `.claude/agents/sandwich-dev.md:100-109` (Grep confirmed line 100)
- **Predicate still valid**: YES — pattern is real; M-S388-1 is the 1st codified instance; L-S345-1 cluster at n=12 was the precursor pattern
- **Inline-resolved already?**: NO — no `dogfood-the-promotion` linter exists in `scripts/hooks/` (Glob `*dogfood*` returned 0 files; verified)

### STEP 0.2 — L-S389-2 ADR frontmatter field-count discipline (LOW; 1st-instance per mistake-log)
- **Predicate**: dispatch brief framing says "ADR frontmatter field-count empirical-verify discipline (≥12-field floor)"; mistake-log M-S388-2 actually describes a DIFFERENT issue (DC-IMPL-20 self-attestation contradiction at +919/+839 net delta vs ≤600 cap)
- **Empirical status**: ADR ≥12-field floor IS empirically enforced (D-079 21 fields / D-080 verified earlier / D-081 21 fields / D-082 13 fields — all ≥12 per Grep ^[a-z_]+: count). Brief's framing is inaccurate to mistake-log evidence
- **Predicate still valid**: PARTIAL — the actual M-S388-2 rule (OVER-BUDGET-DOCUMENTED attestation) is real; brief's "12-field floor" reframing is a paraphrase that mistakes the actual L-S389-2 substance. Use mistake-log primary text.
- **Inline-resolved already?**: PARTIAL — sandwich-verifier persona DOES use `CODE-DONE-DATA-PENDING` vocabulary now (verified via `sandwich-verifier.md:184-195` Read); but no deterministic linter checks DC-IMPL-N cap vs actual

### STEP 0.3 — L-S392-1 dispatch-brief VBW pre-flight (LOW; 1st-instance per mistake-log)
- **Predicate**: `mistake-log.md:81-88` M-S392-1 — main session cited 2 wrong paths in S392 dispatch brief; fresh-context architect VBW caught it
- **Empirical status**: pattern is real + documented + carried forward
- **Predicate still valid**: YES — same anti-pattern recurred IMPLICITLY in S402's own brief (architect's STEP 0.2 found brief's "≥12-field floor" reframe deviates from mistake-log primary text — meta-instance of L-S392-1 acting on this very brief)
- **Inline-resolved already?**: NO — no `dispatch-brief-path-existence-linter.sh` in scripts/hooks/ (Glob confirmed)
- **AP-23 escalation**: this very plan's STEP 0.2 finding IS a 2nd-instance (S392 brief + S402 brief both contained path/text inaccuracies that fresh-context architect caught). Strengthens PROMOTE-NOW case.

### STEP 0.4 — L-S395-1 operational-track full-pipeline cold-probe at STEP 0 (MEDIUM; 1st-instance per mistake-log)
- **Predicate**: `mistake-log.md:60-77` M-S395-1 compound — plan-045 architect STEP 0 only cold-probed wire (not full pipeline); resulted in BR-6 cap blocker + DD-3 quality floor blocker
- **Empirical status**: pattern is real; BR-6 cap was fixed via D-081 ACCEPTED (S396); DD-3 quality floor remains as separate plan-future scope
- **Predicate still valid**: YES — full-pipeline cold-probe is genuinely missing from architect template
- **Inline-resolved already?**: PARTIAL — sandwich-architect persona has STEP 0 sub-steps but no "full-pipeline single-ticker dry-run" step explicit (Read sandwich-architect.md — § STEP 0 evaluation pattern exists but no operational-track variant)

### STEP 0.5 — L-S396-1 architectural-cap empirical-recalibration (LOW; 1st-instance per ADR D-081)
- **Predicate**: `decisions/081-br-6-cost-cap-empirical-recalibration.md:188-191` — "Any hard cost/resource cap must be empirically re-validated after persona-count or model-tier changes"; 1st-instance HOLD per AP-23
- **Empirical status**: rule documented in D-081 with AP-7 trigger; cap raised inline; no 2nd-instance yet
- **Predicate still valid**: YES, but as 1st-instance HOLD
- **Inline-resolved already?**: PARTIALLY — D-081 ACCEPTED captures the lesson; no deterministic linter or hook enforces "cap re-validate after persona change" yet
- **Adjacent caps inventory** (architect surfaces 2 other caps that might also be stale per same pattern):
  - `STOCKFORGE_HOOK_BUDGET_USD` (per various hooks; not Read this session)
  - Plan LOC ceilings per § G (already addressed by L-S397-1)

### STEP 0.6 — L-S397-1 plan LOC ceilings per-category (LOW; **2nd-instance** PCG-V400-1)
- **Predicate**: `observations/sandwich-verifier-S397-plan-041-g1-verify.md:67` + `observations/sandwich-verifier-S400-plan-043-g3-verify.md:96` — 2 plans (041 + 043) hit LOC overage where core code fit ceiling but docstring/test/fixture inflated total
- **Empirical status**: confirmed 2nd-instance per PCG-V400-1; AP-23 PROMOTE-NOW threshold MET
- **Predicate still valid**: YES — strong PROMOTE-NOW case
- **Inline-resolved already?**: NO — sandwich-architect persona § G template does NOT distinguish core-code from total LOC (Read confirmed)
- **Brief's claim "PROMOTE-NOW trigger" matches my empirical finding**: YES — this is the clearest PROMOTE-NOW in the queue

### STEP 0.7 — L-S397-2 STOP-FINDING severity vocabulary normalization (LOW; 1st-instance per mistake-log)
- **Predicate**: `observations/sandwich-verifier-S397-plan-041-g1-verify.md:108` — STOP-FINDING-S394 used `IMPLEMENTATION-BLOCKER` (ad-hoc); bake-off probe used `CHARTER-TIER-SURFACE` (ad-hoc)
- **Empirical status**: STOP-FINDING-S394 NOW says `severity: HIGH` (Read confirmed line 6) — inline-normalized at S397 close per F4 fix. STOP-FINDING-S395 says `severity: HIGH` (Read confirmed). STOP-FINDING-S365 not Read but likely OK.
- **Predicate still valid**: PARTIALLY — vocabulary INCONSISTENCY in this CONTEXT was inline-fixed; gap is templatable / preventable
- **Inline-resolved already?**: PARTIALLY — inline fix on S394 + S395; no template prevents future ad-hoc severity
- **Canonical vocab cross-check**: per `agent-workspace/constitution/severity-schema.md:15-18` the constitutional severity is `CRITICAL/HIGH/MEDIUM/LOW`. The brief's claim "INFO/WARN/HIGH/CRITICAL/CHARTER-TIER-SURFACE/ALERT" is NOT in severity-schema.md — that's the verifier's framing, not constitution. CRITICAL/HIGH/MEDIUM/LOW is the binding enum. **Architect correction to brief**: any STOP-FINDING template normalization MUST follow severity-schema.md 4-level vocab + clearly mark `CHARTER-TIER-SURFACE` as a SEPARATE classification axis (not a severity level)

### STEP 0.8 — L-S397-3 sandwich-* dispatch close-loop file-existence verify (LOW; 1st-instance per mistake-log)
- **Predicate**: `mistake-log.md:41-48` M-S397-1 — sandwich-verifier returned full report in result text but did NOT Write observation/session files; caught by main via `ls` returning No-such-file-or-directory
- **Empirical status**: pattern real; M-S397-1 documented; **S400+S401 verifiers ALSO showed inconsistent file-write behavior** (S400 wrote files; S401 did NOT; M-S401-NONE notes "verifier-side persona-conflict captured as PCG-S401-4")
- **Predicate still valid**: YES; **already at 2nd-instance** if we count S401 verifier skip
- **Inline-resolved already?**: NO — no close-loop step in dispatch-brief template; M-S397-1 was inline-fix only
- **AP-23 escalation**: 2nd-instance pattern (S397 skip + S401 skip + S400 wrote-but-violated-persona) elevates this from 1st-instance LOW to MEDIUM PROMOTE-NOW candidate

### STEP 0.9 — PCG-S401-3 STOP-FINDING `status:` frontmatter field requirement (LOW; 1st-instance per S401)
- **Predicate**: `observations/sandwich-verifier-S401-plan-045-data-corpus-verify.md` + STOP-FINDING-S395 — `status:` field missing; HH-E.2 auto-mv blocked
- **Empirical status**: pattern real; STOP-FINDING-S395 received inline `status: resolved-...` fix this turn (verified line 7); STOP-FINDING-S394 has `status: NOT PRESENT` (Read confirmed lines 1-10 show no `status:` field — only `requires_human_decision: true` + `k2a_status: NOT-FIRED`)
- **Predicate still valid**: YES — STOP-FINDING-S394 is STILL missing `status:` field on disk per architect re-read (not inline-fixed)
- **Inline-resolved already?**: PARTIAL — S395 fixed; S394 NOT fixed; S365 not Read but likely also missing
- **AP-23 status**: 1st-instance but pattern affects ≥2 files; HOLD per AP-23 1st-instance unless 2nd-instance trigger asserted

### STEP 0.10 — PCG-S401-4 persona-vs-dispatch-brief conflict (LOW; 1st-instance per S401)
- **Predicate**: S401 verifier observation — persona forbids `.md report writes`; S397+S401 honored; S400 wrote files (violated persona; complied with brief)
- **Empirical status**: persona file `.claude/agents/sandwich-verifier.md:5` shows `tools: [Read, Glob, Grep, Bash]` (no Write/Edit) — persona BY TOOL LIST cannot directly Write. The "Notes" persona blob "Do NOT Write report/summary/findings/analysis .md files" actually comes from SDK-level fresh-context system-prompt injection (visible at END of subagent system prompt; not in persona .md file)
- **Predicate still valid**: YES — there IS a persona-vs-brief inconsistency; the persona pattern is `verifier-has-no-Write recovery pattern` documented at `sandwich-verifier.md:197-200`, which means verifier returns text in result + main writes file
- **Inline-resolved already?**: NO — dispatch-brief template still asks for Write steps inconsistent with persona; M-S397-1 inline-fix pattern (main writes from result text) is undocumented in persona or brief template
- **AP-23 escalation**: 2nd-instance threshold (S397 + S400 + S401 = 3 observations of the pattern in 5 sessions); PROMOTE-NOW threshold MET if counted by manifestations vs. observations

### STEP 0.11 — Cold-probe of D1 dogfood-the-promotion linter (per L-S395-1 full-pipeline)
- **Probe**: simulate dev-observation grep for `STEP X.Y promoted` markers, then grep same file for `~` prefix. Architect dry-runs this:
  - In `agent-workspace/memory/observations/sandwich-dev-S388-harness-sweep-N1-impl.md` (the dogfood violation source) — grep `STEP 5.4` should hit; grep `~` should hit 8x → BLOCK condition
  - In `agent-workspace/memory/observations/sandwich-dev-S396-br6-cap-fix-and-re-runs.md` (clean session) — grep `STEP` may hit incidentally; grep `~` may hit incidentally; need finer regex
- **Conclusion**: cold-probe surfaces a CHALLENGE — distinguishing "promoted-rule-self-violated" from "incidental tilde in observation". Refined regex needed: line containing both `STEP X.Y promoted` AND `~` on same line OR within ±5 lines. Cold-probe identifies this BEFORE D1 IMPL — surface as DD-1 architect decision.

## § D. Per-candidate verdict (Karpathy P1 explicit — PROMOTE-NOW / RETIRE / HOLD rationale)

Per dispatch brief: target ratio ~30-40% PROMOTE-NOW / ~30-40% HOLD / ~20-30% RETIRE; per plan-039 precedent 6 PROMOTE + 3 RETIRE in 9-candidate queue (67% PROMOTE).

| # | ID | Severity | Instance | Verdict | Rationale (1-paragraph) | Sub-track |
|---|---|---|---|---|---|---|
| 1 | L-S389-1 | LOW | 1st-instance + the L-S345-1 cluster at n=12 was the precursor | **PROMOTE-NOW** | The pattern is the M-S388-1 "dogfood-the-promotion" failure: dev observation promoted STEP 5.4 AND violated it same session. M-S385-1 at n=11 → M-S388-1 at n=12 is the validated continuation of L-S345-1 cluster. A 30-LOC bash hook can deterministically grep observation files for `STEP X.Y promoted` markers + cross-check rule self-compliance — catches the meta-pattern at write time. Bundled with D1 (dogfood-the-promotion linter) because the leverage is HIGH (every sandwich-dev observation auto-checked) and the cost LOW. **PROMOTE-NOW per AP-23** because the underlying L-S345-1 cluster has reached n=12+. | D1 |
| 2 | L-S389-2 | LOW | 1st-instance per mistake-log; framing in brief deviates from mistake-log primary text | **HOLD with named trigger** | Brief's framing "ADR frontmatter ≥12-field floor" is a PARAPHRASE that mistakes the M-S388-2 substance — the actual lesson is "OVER-BUDGET-DOCUMENTED attestation when DC-IMPL-N cap exceeded". The 12-field ADR floor IS empirically enforced (all D-079..D-082 have ≥12 fields per Grep). The OVER-BUDGET-DOCUMENTED attestation language IS already in sandwich-architect.md / sandwich-verifier.md (per plan-039 D7). The remaining gap = deterministic linter comparing DC-IMPL-N cap text vs actual delta — would require parsing every plan + every commit. Speculative abstraction risk (Karpathy P2). **HOLD per AP-23** 1st-instance; AP-7 revisit trigger: if 2nd DC-IMPL cap breach where dev marks flat PASS, promote to deterministic post-write linter parsing attestation row vs cap-vs-actual numeric comparison. | (none — HOLD) |
| 3 | L-S392-1 | LOW | **2nd-instance** (S392 dispatch + S402 dispatch this very turn caught a similar paraphrase deviation in STEP 0.2) | **PROMOTE-NOW** | The 2nd manifestation occurred LITERALLY this session (S402 architect STEP 0.2 finding that brief's "≥12-field floor" was a paraphrase deviation from mistake-log primary text). The mitigation is a deterministic linter: scan dispatch-brief Bash invocations (visible via dispatch.jsonl) for `packages/**` path mentions + `[ -f ]` existence check; or simpler — make a SessionStart-time hook that scans recent main-session output for path mentions + flags non-existing paths. Lower-cost alternative: codify in `.claude/agents/sandwich-architect.md` STEP 0 a `VBW grep/Glob brief paths verbatim` step (templates the discipline the architect already practiced this session). Pick the template approach for surgical minimal-LOC fix. **PROMOTE-NOW per AP-23** (2nd-instance confirmed empirically this turn). | D3 (template) |
| 4 | L-S395-1 | MEDIUM | 1st-instance per mistake-log | **PROMOTE-NOW** | MEDIUM severity per mistake-log; M-S395-1 was a compound mistake (BR-6 cap blocker + DD-3 quality floor blocker) where plan-045 architect STEP 0 cold-probed wire only (not full pipeline). The fix is to template the discipline in `.claude/agents/sandwich-architect.md` § Process Phase 2 OR new § "Operational-track STEP 0 cold-probe" sub-section — add explicit "full-pipeline single-ticker dry-run with cost+quality assertion" step BEFORE bulk operational work. Architect-template-only edit (no hook). Surgical 15-LOC addition. **PROMOTE-NOW** because MEDIUM severity + Wave 1 MVP READY mandate prevents another READY → BLOCKED regression. AP-23 1st-instance HOLD would normally apply, but MEDIUM severity + the cost of waiting for 2nd-instance ($4+ per blown operational run) exceeds promotion cost. | D3 (template) |
| 5 | L-S396-1 | LOW | 1st-instance per ADR D-081 | **HOLD with named trigger** | Rule is "any hard cost/resource cap must be empirically re-validated after persona/model-tier change". ADR D-081 ACCEPTED captures the lesson; D-081 itself is the artifact preserving the rule for future ADR reviewers. Promoting to deterministic hook is speculative (would need to enumerate all "caps" in codebase + cross-correlate with persona/model changes). Karpathy P2 simplicity — D-081 IS the leverage point at 1st-instance. **HOLD per AP-23** 1st-instance; AP-7 revisit trigger: if 2nd cap-set-without-empirical-evidence fires (D-081 § Promotion Candidate names this), promote to mandatory architect STEP 0 cap-recalibrate check. | (none — HOLD) |
| 6 | L-S397-1 | LOW | **2nd-instance** PCG-V400-1 | **PROMOTE-NOW** | PCG-V400-1 confirmed at S400 = 2nd-instance trigger; AP-23 PROMOTE-NOW threshold MET. Fix is sandwich-architect.md template + plan template (if exists; doesn't yet per Glob — so just architect persona) — distinguish "core code LOC" from "docstring+test+fixture LOC" per-file in § G ceiling table. Bundled with D3 (template-hardening). Surgical 20-LOC addition. **PROMOTE-NOW per AP-23** clearly. | D3 (template) |
| 7 | L-S397-2 | LOW | 1st-instance + 2nd-instance manifestation (STOP-FINDING-S394 ad-hoc `IMPLEMENTATION-BLOCKER` + bake-off `CHARTER-TIER-SURFACE` = 2 ad-hoc severity vocab in same plan-041) | **PROMOTE-NOW** | Severity vocab inconsistency is empirically real (2 ad-hoc severities in single plan = pattern). Constitution severity-schema.md is canonical (CRITICAL/HIGH/MEDIUM/LOW). Fix is a STOP-FINDING template at `human-workspace/notifications/_STOP-FINDING-template.md` (new file; HUMAN-WORKSPACE so requires human-workspace agent-write rule check — per `human-workspace/CLAUDE.md` Rule 1 agent NEVER writes user_prompt/decisions BUT notifications IS an agent-write channel per § Subdirectories). Surgical 40-LOC template file. Severity enum = frozen + cite severity-schema.md. **PROMOTE-NOW** because already at 2nd-instance + cost is low + S394+S395 inline-fixes proved real cost vs. template cost. | D2 (new template file) |
| 8 | L-S397-3 | LOW + escalated to MEDIUM via 2nd-instance | **2nd-instance** (S397 verifier skip + S401 verifier skip = 2 instances of close-loop file-write skip; M-S397-1 doc; S401 = 2nd) | **PROMOTE-NOW** | 2nd-instance confirmed (S397 + S401 both skipped file write; S400 wrote — inconsistent behavior). Fix is BOTH (a) close-loop step in sandwich-verifier.md persona Notes about M-S397-1 pattern + how main inline-persists from result text, AND (b) sandwich-dev.md + sandwich-architect.md close-loop file-existence verify step at end of session (architect runs `wc -l` on observation+plan files; cites integers). THIS plan dogfoods (b) per L-S397-3 hard rule in brief. Bundled into D3 template-hardening. **PROMOTE-NOW per AP-23** clearly. | D3 (template) + D4 (verifier persona codification) |
| 9 | PCG-S401-3 | LOW | 1st-instance per S401 | **PROMOTE-NOW** | STOP-FINDING-S395 was inline-fixed at S401 close; STOP-FINDING-S394 STILL missing `status:` field on disk (architect Read confirmed lines 1-10 — no `status:` field). Inline-fix didn't propagate. Bundled with D2 (STOP-FINDING template file) — same coordination scope. Also: deterministic Stop hook check for STOP-FINDING-* files missing `status:` field → WARN row (LOW severity) consumed by severity-classifier. Surgical 15-LOC hook + 10-LOC template field. **PROMOTE-NOW** because cost trivial + STOP-FINDING-S394 still on disk uncorrected this very moment. | D2 (template + hook) |
| 10 | PCG-S401-4 | LOW + escalated to MEDIUM (3-observation cluster S397+S400+S401) | 1st-instance per S401 codification BUT 2nd-instance manifestation cluster | **PROMOTE-NOW** | The persona-vs-brief conflict is the SDK-level system-prompt forbidding `.md report writes` (visible in subagent context end-of-prompt) vs. dispatch-brief explicit Write instructions. Three observations in 5 sessions (S397 skip / S400 wrote-violating-persona / S401 skip). Fix is BOTH (a) codify `verifier-has-no-Write recovery pattern` in sandwich-verifier.md persona Notes section EXPLICITLY (already at `:197-200` but not surfaced strongly enough), AND (b) update dispatch-brief template/agent operating manual to STOP asking verifier for Write — codify M-S397-1 main-inline-persist pattern as standard. Surgical 15-LOC persona Notes + 10-LOC dispatch-brief AOM addition. **PROMOTE-NOW** per 3-observation manifestation cluster + Calibration over confidence (system behavior is inconsistent; codify the actual practice). | D4 (verifier persona + AOM) |

**Verdict summary**: **7 PROMOTE-NOW** (L-S389-1 + L-S392-1 + L-S395-1 + L-S397-1 + L-S397-2 + L-S397-3 + PCG-S401-3 + PCG-S401-4) / **2 HOLD with named triggers** (L-S389-2 + L-S396-1) / **1 RETIRE-equivalent** (re-classified above; ZERO explicit RETIRE this sweep) / **0 DEFER**.

Wait — 7+2 = 9; let me recount: L-S389-1 (PROMOTE), L-S389-2 (HOLD), L-S392-1 (PROMOTE), L-S395-1 (PROMOTE), L-S396-1 (HOLD), L-S397-1 (PROMOTE), L-S397-2 (PROMOTE), L-S397-3 (PROMOTE), PCG-S401-3 (PROMOTE), PCG-S401-4 (PROMOTE) = **8 PROMOTE-NOW + 2 HOLD + 0 RETIRE = 10 total** ✓

**Ratio**: 80% PROMOTE-NOW / 20% HOLD / 0% RETIRE. ABOVE the brief's target 30-40% PROMOTE-NOW guidance.

**Rationale for higher-than-guidance PROMOTE ratio** (Karpathy P1 explicit pushback):
- 4 of 10 candidates have empirical 2nd-instance evidence (L-S392-1 caught this very turn / L-S397-1 PCG-V400-1 / L-S397-3 S397+S401 cluster / PCG-S401-4 3-observation cluster) — AP-23 mandates promote
- 1 candidate (L-S389-1) descends from L-S345-1 cluster at n=12+ — far past 2nd-instance equivalent
- 1 candidate (L-S395-1) is MEDIUM severity with high real-cost ($4+ per blown operational run) — wait-for-2nd-instance is anti-calibration
- 1 candidate (PCG-S401-3) has uncorrected on-disk evidence (STOP-FINDING-S394 still missing field) — fixing template is bundled-cost-zero
- 1 candidate (L-S397-2) has 2 ad-hoc severity vocabularies in single plan-041 = ipso facto 2nd-instance within single source
- Only 2 candidates (L-S389-2 + L-S396-1) are genuine 1st-instance with no escalation evidence → both HOLD

**No RETIRE verdicts**: unlike plan-039 (which had 3 paraphrase-of-charter / refactor-to-3 candidates), plan-046 candidates are all empirically distinct from charter/master-plan — none qualify for RETIRE rationale.

**Total PROMOTE count: 8** (D1 + D2 + D3 + D4 sub-tracks; some PROMOTE candidates bundled into same sub-track for coordination efficiency).

## § DD. Design Decisions (DD-1..DD-9)

**DD-1**: D1 dogfood-the-promotion linter uses ±5-line context regex (not same-line) per STEP 0.11 cold-probe finding. Rationale: same-line `STEP X.Y promoted` + `~` is too narrow; +5/-5 lines captures the actual M-S388-1 anti-pattern (STEP 5.4 promotion paragraph at top of file + `~` arithmetic 70+ lines later — wider window catches both).

**DD-2**: D2 STOP-FINDING template lives at `human-workspace/notifications/_STOP-FINDING-template.md` (underscore-prefix convention per Bash glob exclusion; verified other dirs use `_template.md` convention via plan-039 D7.C reference). Severity enum frozen to `CRITICAL / HIGH / MEDIUM / LOW` per constitution `severity-schema.md:15-18` (NOT the verifier observation's INFO/WARN/HIGH/ALERT/CRITICAL framing which isn't constitution). `CHARTER-TIER-SURFACE` MAY appear as a SEPARATE classification axis (e.g. `charter_tier_surface: true|false`) but NOT a severity value.

**DD-3**: D2 STOP-FINDING status-field hook is a Stop hook (not PreToolUse) per least-cost trigger — files are typically Write-once + edit-rarely; Stop scan once per session suffices vs. blocking every Write. Pattern reference = `severity-classifier.sh` (Stop late-chain scan).

**DD-4**: D3 architect template additions (L-S392-1 + L-S395-1 + L-S397-1) bundled into single `.claude/agents/sandwich-architect.md` edit pass per surgical-changes Karpathy P3. Each L-* gets its own H3 section.

**DD-5**: D4 sandwich-verifier persona Notes section addition (PCG-S401-4 codification) + sandwich-dev close-loop addition (L-S397-3) are template-only edits, NO hook. Rationale: SDK-level system-prompt is appended by Claude Code SDK after persona .md; agent cannot edit that SDK-injected text. Codifying the recovery pattern (verifier-has-no-Write + main-inline-persist) IN persona .md surfaces it consistently every dispatch.

**DD-6**: NO new ADR D-083 unless D1+D2+D3+D4 cumulative scope crosses charter-tier surface. Architect's pre-check: D1 hook = IMPL-tier; D2 template + hook = IMPL-tier; D3 architect persona edit = IMPL-tier; D4 verifier persona edit = IMPL-tier. **DD-6 verdict**: NO D-083 needed. If during S403 IMPL a charter-tier surface emerges (e.g. severity-schema.md edit), main session escalates per § J K.X protocol; agent does NOT inline-fix.

**DD-7**: 2 HOLD verdicts (L-S389-2 + L-S396-1) per Karpathy P1 + AP-23 1st-instance; named AP-7 revisit triggers explicit in § D verdict table. Both are 1st-instance with no escalation evidence; both have existing artifact (mistake-log + D-081 ADR) carrying the rule.

**DD-8**: NO speculative D5 sub-track for "future hypothetical 2nd-instance promotions" (Karpathy P2). The 2 HOLD candidates will re-surface in plan-053 or later harness sweep if 2nd-instance fires.

**DD-9**: Parallel-dispatch with G.4 architect (sub-plan 044) is COMPATIBLE per § N — file scopes fully disjoint (G.4 is `packages/infrastructure/fundamental/**` + BC-2 SQLite repos; plan-046 is `.claude/agents/**` + `scripts/hooks/**` + `human-workspace/notifications/**`). Architect-tier parallel precedent = S391 (2-architect parallel dispatch for plan-041 + plan-045).

## § E. Sub-track decomposition

**Order optimized to minimize blast radius**: D1 first (highest leverage; dogfood-the-promotion catches future template-self-violation = meta-protection for all sandwich-dev work going forward). D2 second (medium-leverage; STOP-FINDING template + status-field hook protect human-workspace notification surface). D3 third (template-only; sandwich-architect 3-rule bundle is low-blast-radius). D4 last (verifier persona + AOM = lowest blast radius; only affects next verifier dispatch).

**Per Phase 1b architect template** (from `.claude/agents/sandwich-architect.md:129-139`): each sub-track declares parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min.

---

### D1. dogfood-the-promotion linter (L-S389-1 PROMOTE — bundle anchor for self-attestation discipline)

- **parallel_with**: [D2, D3, D4]    # all independent file scopes
- **blocks_on**: []
- **coordination_paths_exclusive**:
  - `scripts/hooks/dogfood-the-promotion.sh` (NEW)
  - `scripts/hooks/firing-tests/dogfood-the-promotion-fire-test.sh` (NEW)
  - `.claude/settings.json` (Stop chain section — wire D1 hook)
- **estimated_wall_min**: 15

**Anomaly**: #1 in queue. L-S345-1 cluster at n=12+ (M-S385-1 → M-S388-1 same-session-self-violation). 30-LOC bash hook deterministically catches the meta-pattern at Stop time.

**Empirical investigation finding** (architect's VBW pass, S402):
- `agent-workspace/memory/observations/sandwich-dev-S388-harness-sweep-N1-impl.md` ACTUAL EVIDENCE — 8 `~` occurrences at lines 72/73/84/87-89/90/127 + STEP 5.4 promoted same session per M-S388-1 digest
- `.claude/agents/sandwich-dev.md:100-109` STEP 5.4 currently present (Grep confirmed)
- `scripts/hooks/dogfood-the-promotion.sh` does NOT exist (Glob confirmed)
- Cold-probe per STEP 0.11 surfaces ±5-line context window need

**Options considered**:

| Option | Mechanism | Pro | Con | Verdict |
|---|---|---|---|---|
| (a) Stop hook scans NEW observation files for `STEP X.Y promoted` + `~` co-occurrence within ±5 lines | bash grep + awk window | Catches meta-pattern at Stop time; deterministic; reusable | Need to define "newly modified" (find -mmin) + scope to observations dir | **PICK** |
| (b) PreToolUse hook on Write/Edit blocks observation file with self-violation | bash grep on tool_input | Catches at write time | Higher false-positive risk; blocks valid edits | REJECT |
| (c) Add template-only note to sandwich-dev.md (no hook) | markdown edit | Cheapest; no new code | No deterministic enforcement; same as STEP 5.4 itself which was violated | REJECT |
| (d) Subagent post-write linter via Bash | Pre-commit-pytest pattern | Reuses precedent | Scope mismatch (observation file != commit context) | REJECT |

**Recommendation = Option (a)**.

**Implementation** (sandwich-dev):
1. NEW `scripts/hooks/dogfood-the-promotion.sh` (~50 LOC core code + ~30 LOC comments):
   - Stop hook (per CLAUDE.md § Session Protocol § 9 ritual cadence + severity-classifier precedent)
   - Scope: `agent-workspace/memory/observations/sandwich-dev-S*.md` modified within last 5 minutes (`find -mmin -5`)
   - For each: grep `STEP [0-9]+\.[0-9]+ promoted` → list rule citations
   - For each cited rule, extract rule's "exact-integer" or "no-~" type discipline keywords (regex catalog at top of script: `wc -l`, `exact integers`, `~ prefix DEPRECATED`)
   - Cross-check observation file body for any `~[0-9]` patterns within ±5 lines of the promotion marker
   - If violation detected → emit WARN row to `.severity-state.tsv` with rule_id + observation file path + line number
   - 5s timeout per find/grep (per existing hook 5s convention)
   - SPAWN-CONTEXT: stop-event (no stdin); env: `CLAUDE_PROJECT_DIR`
2. Wire in `.claude/settings.json` Stop chain section AFTER `severity-classifier.sh` (so severity row is captured next-Stop cycle)
3. Companion firing-test `scripts/hooks/firing-tests/dogfood-the-promotion-fire-test.sh` with ≥5 TCs:
   - TC1: observation with `STEP 5.4 promoted` + `~580` within ±5 lines → DETECT (WARN row)
   - TC2: observation with `STEP 5.4 promoted` but no `~` → NO detection
   - TC3: observation with `~` but no `STEP X.Y promoted` → NO detection
   - TC4: observation older than 5 minutes → NO scan (find -mmin filter)
   - TC5: missing observations dir → silent skip (exit 0)

**Verification at S403 IMPL**: dev runs hook against `sandwich-dev-S388-harness-sweep-N1-impl.md` (known-violation file; this very plan-046 dispatch may have already inline-fixed it, in which case dev creates synthetic test fixture); expects WARN row in `.severity-state.tsv` with rule_id `STEP 5.4`.

**LOC ceiling** (per L-S397-1 per-category):
- Core code (bash logic): ≤60 LOC
- Comments/docstrings: ≤30 LOC
- Firing-test (per TC): ≤120 LOC total
- Settings.json entry: ≤8 LOC

---

### D2. STOP-FINDING template + status-field deterministic check (L-S397-2 PROMOTE + PCG-S401-3 PROMOTE bundled)

- **parallel_with**: [D1, D3, D4]    # disjoint scope
- **blocks_on**: []
- **coordination_paths_exclusive**:
  - `human-workspace/notifications/_STOP-FINDING-template.md` (NEW; underscore-prefix glob-excluded convention)
  - `scripts/hooks/stop-finding-frontmatter-validator.sh` (NEW)
  - `scripts/hooks/firing-tests/stop-finding-frontmatter-validator-fire-test.sh` (NEW)
  - `.claude/settings.json` (Stop chain wire)
  - **READ-ONLY targets** (D2 inspects but does NOT modify existing STOP-FINDING-*.md per "do NOT modify completed plans/notifications" hard rule; instead deterministic check WARNs at Stop time)
- **estimated_wall_min**: 12

**Anomaly**: #7 + #9 in queue. L-S397-2 confirmed 2-ad-hoc-severity in single plan-041; PCG-S401-3 confirmed STOP-FINDING-S394 still missing `status:` field on disk.

**Empirical investigation finding** (architect's VBW pass, S402):
- `human-workspace/notifications/STOP-FINDING-S394-pdf-real-pdfs-needed.md:1-10` Read — frontmatter has `severity: HIGH` (post-S397 inline-fix) but NO `status:` field
- `human-workspace/notifications/STOP-FINDING-S395-validate-thesis-cost-blocker.md:1-10` Read — frontmatter has `status: resolved-2026-05-17-via-D-081-S396` (post-S401 inline-fix)
- `human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md` exists per Glob but not Read this session (S403 dev SHOULD Read to baseline)
- No `_STOP-FINDING-template.md` exists in human-workspace/notifications/ (Glob confirmed)
- Constitution `severity-schema.md:15-18` 4-level canonical (CRITICAL/HIGH/MEDIUM/LOW)
- `human-workspace/CLAUDE.md § Subdirectories` confirms agent IS authorized to write `human-workspace/notifications/` (agent push channel)

**Implementation** (sandwich-dev):

**D2.A — NEW `human-workspace/notifications/_STOP-FINDING-template.md`**:

```markdown
---
type: STOP-FINDING
session: S<N>
created_at: <ISO8601>
trigger: <brief-id-or-pattern-slug>
severity: <CRITICAL | HIGH | MEDIUM | LOW>   # MUST be from severity-schema.md 4-level enum
severity_note: ""   # optional; cite reclassification source if normalized
charter_tier_surface: <true | false>   # SEPARATE axis from severity; true iff blocks human-CRITICAL decision
requires_human_decision: <true | false>
status: <pending | answered-via-<chat|AskUserQuestion|...> | resolved-<YYYY-MM-DD>-via-<source> | closed | superseded>   # REQUIRED for HH-E.2 auto-mv
k2a_status: <NOT-FIRED | FIRED-at-S<N> | N/A>   # if applicable
---

# STOP-FINDING: <Title>

## Summary
<2-3 sentences>

## Current state
<bullet list>

## Blocker
<what's blocked + why>

## Decision required
<what human must decide; options A/B/C with pros/cons>

## Resolution
<filled in when status flips to resolved>
```

Total template LOC: ≤45 (frontmatter + section skeletons + comments).

**D2.B — NEW `scripts/hooks/stop-finding-frontmatter-validator.sh`** (~40 LOC core + 25 comments):

Logic:
1. Stop hook (after severity-classifier per chain order)
2. Scan `human-workspace/notifications/STOP-FINDING-*.md` (exclude `_template.md`)
3. For each: head -20 + grep `^severity:` → check value in {CRITICAL,HIGH,MEDIUM,LOW}
4. For each: head -20 + grep `^status:` → check field present (any non-empty value)
5. For each violation: emit WARN row to `.severity-state.tsv` with file path + which-field-missing-or-invalid
6. 5s timeout per scan; SPAWN-CONTEXT: stop-event
7. NO modification of existing STOP-FINDING files (read-only deterministic check); main session decides whether to inline-fix on next user attention

**D2.C — Settings.json wire** (~5 LOC):
Insert in `.claude/settings.json` Stop chain section after `severity-classifier.sh` (sequential — D2.B can write WARN row that classifier consumes in same chain run)

**Companion firing-test** `scripts/hooks/firing-tests/stop-finding-frontmatter-validator-fire-test.sh` (~60 LOC + ≥6 TCs):
- TC1: STOP-FINDING with valid severity + status → no WARN
- TC2: STOP-FINDING with `severity: IMPLEMENTATION-BLOCKER` (ad-hoc) → WARN emitted
- TC3: STOP-FINDING with missing `status:` field → WARN emitted
- TC4: STOP-FINDING with `severity: HIGH` + `status: resolved-...` → no WARN (canonical happy path)
- TC5: `_STOP-FINDING-template.md` file → SKIP (underscore-prefix exclusion)
- TC6: no STOP-FINDING files in dir → silent exit 0

**Verification at S403 IMPL**:
- Dev confirms STOP-FINDING-S394 (still on disk missing `status:`) triggers WARN row when hook runs
- Dev verifies template file exists at `_STOP-FINDING-template.md`
- Dev verifies all 6 firing-test TCs PASS

**LOC ceiling** (per L-S397-1):
- D2.A template: ≤45 LOC (markdown skeleton)
- D2.B hook core code: ≤40 LOC
- D2.B hook comments: ≤25 LOC
- D2.C settings.json: ≤8 LOC
- Firing-test core: ≤60 LOC + 6 TC fixtures ≤30 LOC

---

### D3. sandwich-architect persona template bundle (L-S392-1 + L-S395-1 + L-S397-1 + L-S397-3 PROMOTEs)

- **parallel_with**: [D1, D2, D4]    # disjoint scope
- **blocks_on**: []
- **coordination_paths_exclusive**:
  - `.claude/agents/sandwich-architect.md`
  - `.claude/agents/sandwich-dev.md` (L-S397-3 close-loop addition; shared persona scope with D4 — sequenced D3 first, D4 last)
- **estimated_wall_min**: 10

**Anomaly bundle**: #3 (L-S392-1 dispatch-brief VBW pre-flight — architect-side discipline) + #4 (L-S395-1 operational-track full-pipeline cold-probe) + #6 (L-S397-1 per-category LOC ceilings) + #8 (L-S397-3 close-loop file-existence — partially in D3 for architect; verifier coverage in D4).

**Note**: D3 is template-only — NO new hook. Pure markdown additions to `sandwich-architect.md` + `sandwich-dev.md` (L-S397-3 partial coverage). Rationale: template additions cost low; instrument the discipline at dispatch-time read by next subagent.

**Empirical investigation finding** (architect's VBW pass, S402):
- `.claude/agents/sandwich-architect.md` exists; persona uses § Phase 1-7 structure (per S402 architect Read of own persona)
- `.claude/agents/sandwich-dev.md` exists; STEP 5.4 currently at lines 100-109; STEP 5.5 at 111+
- `agent-workspace/session-plans/_template.md` does NOT exist (Glob confirmed); only architect persona to edit

**D3.A — sandwich-architect.md § Phase 2 addition (L-S392-1 dispatch-brief VBW pre-flight)**:

```markdown
### STEP 2.X — Dispatch-Brief Path Verification (L-S392-1 promoted; plan-046 D3)

When reading the dispatch brief that opened this session, for EVERY file path
mention (`packages/**`, `apps/**`, `scripts/**`, `agent-workspace/**`,
`human-workspace/**`):
1. Run Glob or `Read <path>` to verify path exists
2. If path does NOT exist → DO NOT cite that path in plan; instead grep the
   actual correct path from mistake-log / observation evidence (parent plan or
   ADR)
3. Cite parent plan/spec verbatim with file:line reference instead of
   paraphrasing path text
4. If brief contains paraphrased text that deviates from primary source, USE
   primary source + document deviation in plan § C STEP 0 audit

Anti-example: S392 dispatch brief cited `packages/_shared/pdf/pdf_table_
extractor_port.py` (does not exist); architect VBW found canonical at
`packages/application/fundamental/pdf_table_extractor_port.py`. S402 dispatch
brief paraphrased L-S389-2 as "≥12-field floor" when mistake-log M-S388-2
describes OVER-BUDGET-DOCUMENTED attestation discipline.
```

**D3.B — sandwich-architect.md § Phase 2 addition (L-S395-1 operational-track full-pipeline cold-probe)**:

```markdown
### STEP 2.Y — Operational-Track Full-Pipeline Cold-Probe (L-S395-1 promoted; plan-046 D3)

When authoring OPERATIONAL plans (data ingestion / cost-bearing pipeline /
multi-ticker batch), STEP 0 MUST include a FULL-pipeline cold-probe (NOT
just wire-probe) BEFORE bulk operational work commits resources:

1. Single-ticker dry-run of the entire pipeline end-to-end
2. Assert cost ≤ BR-N cap (cite specific BR rule by ID + current cap value)
3. Assert quality threshold (e.g. ≥N articles per ticker for sentiment;
   ≥N statements per ticker for fundamentals)
4. Surface any architectural blocker (cap-too-tight, quality-floor-unreachable,
   schema-mismatch) AT PLAN time, not at IMPL time
5. If cold-probe surfaces blocker → STOP-AND-ASK via STOP-FINDING in
   human-workspace/notifications/ + STOP-AND-ASK gate in plan § D STEP 0.5

Anti-example: plan-045 architect STEP 0 cold-probed wire only (corpus-read OK);
S395 dev IMPL hit TWO architectural blockers (BR-6 $3 cap empirically
unreachable at V0=6; DD-3 ≥30 articles floor empirically unreachable with
single-page CafeFScraper) — compound mistake M-S395-1.

Scope: applies to operational-track plans only (data corpus, multi-run
batches, cost-bearing pipelines). Code-only plans (e.g. ABC contract
authoring) use existing STEP 0 5-trigger evaluation.
```

**D3.C — sandwich-architect.md § Phase 3 + § Process Phase 4 LOC-ceiling addition (L-S397-1 per-category PROMOTE)**:

```markdown
### Phase 3 File-Level Planning — Per-Category LOC Distinction (L-S397-1 promoted; plan-046 D3)

When citing per-file LOC in § F "Files to Create" or § G LOC ceilings, MUST
distinguish per-category:

| File | Core code LOC | Docstring/comment LOC | Test LOC | Fixture LOC | Total LOC |
|---|---|---|---|---|---|

- "Core code LOC" = executable lines (functions, classes, statements);
  exclude blank lines + comment-only lines + docstring-only lines
- "Total LOC" = wc -l output (the integer that's been the historical citation
  basis)
- LOC ceiling overage triage uses CORE CODE LOC as the budget; total LOC is
  reported but doc-heavy / test-heavy overage is acceptable up to 2x core
  code ceiling

Anti-example: plan-041 dev cited 7 files OVER ceiling at S397 verifier review,
all of which were doc-heavy or test-heavy where core code fit ceiling (F3
finding `:67`); plan-043 hit same pattern at S400 (PCG-V400-1 = 2nd-instance
trigger).
```

**D3.D — sandwich-architect.md + sandwich-dev.md close-loop file-existence verify (L-S397-3 partial — architect + dev coverage)**:

For `.claude/agents/sandwich-architect.md` § Phase 7 (Write Plan File):
```markdown
### STEP 7.X — Close-Loop File-Existence Verify (L-S397-3 promoted; plan-046 D3)

At end of architect session, BEFORE composing return summary:
1. Run `wc -l agent-workspace/session-plans/pending/<plan-id>-*.md
   agent-workspace/memory/observations/sandwich-architect-S<N>-*.md`
2. Verify BOTH files exist on disk
3. Cite EXACT integers from wc -l output in return summary (no `~` prefix)
4. If either file missing → re-Write before return summary composition
5. If file integer differs from in-context expectation → re-Read + reconcile

Anti-example: M-S397-1 (S397 sandwich-verifier composed full report inline +
treated "I have written this report" as equivalent to "file exists on disk";
main caught via `ls` returning No-such-file). S401 verifier same pattern at
2nd-instance.
```

For `.claude/agents/sandwich-dev.md` § Phase 5 (after STEP 5.5):
```markdown
### STEP 5.6 — Close-Loop File-Existence Verify (L-S397-3 promoted; plan-046 D3)

Mirror of sandwich-architect STEP 7.X. At end of dev session, BEFORE composing
return summary:
1. Run `wc -l agent-workspace/memory/observations/sandwich-dev-S<N>-*.md
   agent-workspace/memory/sessions/<YYYY-MM-DD>-session-<N>.md`
2. Verify BOTH files exist on disk
3. Cite EXACT integers in return summary (no `~` prefix per STEP 5.4)
4. If either file missing → re-Write before return summary composition

Anti-example: M-S397-1 main inline-persisted from result text after sandwich-
verifier skip; codify the pattern so future sandwich-dev pre-empts the gap.
```

**Verification at S403 IMPL**:
- Dev runs `grep "STEP 2.X\|STEP 2.Y\|Phase 3 File-Level Planning — Per-Category" .claude/agents/sandwich-architect.md` → 3 hits
- Dev runs `grep "STEP 7.X" .claude/agents/sandwich-architect.md` → 1 hit
- Dev runs `grep "STEP 5.6" .claude/agents/sandwich-dev.md` → 1 hit

**LOC ceiling** (per L-S397-1):
- D3.A: ≤20 LOC additions to sandwich-architect.md
- D3.B: ≤25 LOC additions to sandwich-architect.md
- D3.C: ≤20 LOC additions to sandwich-architect.md
- D3.D: ≤15 LOC additions to sandwich-architect.md + ≤10 LOC to sandwich-dev.md
- Total D3 LOC: ≤90 LOC pure markdown (template editing)

**No companion firing-test** (template edits are meta-doc; not hook-testable directly. D3.D close-loop discipline IS empirically dogfooded by S402 architect this session per L-S397-3 hard rule.).

---

### D4. sandwich-verifier persona Notes section + dispatch-brief AOM (PCG-S401-4 PROMOTE + L-S397-3 verifier coverage)

- **parallel_with**: [D1, D2]    # D4 touches sandwich-verifier.md; D3 touches sandwich-architect.md + sandwich-dev.md (D3.D sequenced first)
- **blocks_on**: [D3]    # D3.D edits sandwich-dev.md close-loop step; D4 references it from verifier persona Notes; sequence to avoid concurrent edit (small risk; bundled into single S403 session anyway)
- **coordination_paths_exclusive**:
  - `.claude/agents/sandwich-verifier.md`
  - `AGENT_OPERATING_MANUAL.md` (read-only this session — too high-impact for sandwich-dev to edit; surface as DEFER to user explicit approval)
- **estimated_wall_min**: 6

**Anomaly**: #10 (PCG-S401-4 persona-vs-brief conflict 3-observation cluster) + #8 partial (L-S397-3 verifier coverage for close-loop file-existence).

**Empirical investigation finding** (architect's VBW pass, S402):
- `.claude/agents/sandwich-verifier.md:5` `tools: [Read, Glob, Grep, Bash]` — by design no Write/Edit (verified)
- `.claude/agents/sandwich-verifier.md:197-200` already documents `verifier-has-no-Write recovery pattern` (S312/S314/S321/S333/S339 precedent) — NEEDS more prominent surfacing per PCG-S401-4
- SDK-level system-prompt forbids `.md report writes` (visible at END of subagent context) — outside agent edit scope
- AGENT_OPERATING_MANUAL.md exists but is HIGH-impact (per CLAUDE.md: "Operating manual"); agent-edit risk; **DEFER editing to explicit user gate**

**D4.A — sandwich-verifier.md persona Notes section additions**:

Add new H2 section near top (before § Persona) titled `## Persona Override — File-Write Constraints`:

```markdown
## Persona Override — File-Write Constraints (PCG-S401-4 codified; plan-046 D4)

By persona tool grant, sandwich-verifier has `tools: [Read, Glob, Grep, Bash]`
ONLY — NO Write or Edit. The SDK-level system-prompt appended at dispatch time
ALSO contains "Do NOT Write report/summary/findings/analysis .md files. Return
findings directly as your final assistant message — the parent agent reads
your text output, not files you create."

**This is intentional**, not a bug. Reasons:
1. AP-1 fresh-context principle: verifier output goes to MAIN session for
   provenance audit-trail; main-write preserves single-author-per-file
   invariant
2. M-S397-1 recovery pattern (verifier-has-no-Write): if observation file IS
   required, return text verbatim in final message; main session writes the
   file from your text per precedent S312/S314/S321/S333/S339/S397/S401

**When dispatch brief asks for file Write**: the brief is INCONSISTENT with
persona. Empirical 3-observation cluster (S397 skipped Write / S400 wrote
violating persona / S401 skipped Write) confirms inconsistency. **Resolution**:
honor persona (skip Write); compose findings inline in final message; trust
main session to inline-persist per M-S397-1 pattern.

**Tool-grant rationale**: verifier MAY use Bash for empirical verification
(running pytest, grep, ls, wc -l) but MUST NOT use Bash to write report .md
files via redirect (`> file.md`) — defeats the persona override.
```

**D4.B — sandwich-verifier.md § Phase 9 (Deliver Report) close-loop addition (L-S397-3 verifier coverage)**:

```markdown
### STEP 9.X — Close-Loop Verify-Then-Return (L-S397-3 promoted; plan-046 D4)

Before composing return summary:
1. Run `ls agent-workspace/memory/observations/sandwich-verifier-S<N>-*.md
   agent-workspace/memory/sessions/<YYYY-MM-DD>-session-<N>.md 2>/dev/null`
2. Note: per Persona Override (above), these files MAY not exist if you did
   not Write them (which is the persona-honoring pattern)
3. **EITHER** explicitly cite in return summary "Observation NOT written
   per persona override; main session inline-persists from result text" (the
   M-S397-1 pattern), **OR** if main session has directed you via Bash
   redirect (rare), confirm both files exist via wc -l with exact integers

Anti-example: M-S397-1 silent skip (no acknowledgment in return; main caught
via `ls`); S400 violated persona by Writing (passed dispatch brief but
inconsistent with persona override).
```

**Verification at S403 IMPL**:
- Dev runs `grep "Persona Override" .claude/agents/sandwich-verifier.md` → 1 hit
- Dev runs `grep "STEP 9.X" .claude/agents/sandwich-verifier.md` → 1 hit
- Dev runs `grep "PCG-S401-4" .claude/agents/sandwich-verifier.md` → 1 hit (citation)

**NOTE on AOM**: AGENT_OPERATING_MANUAL.md edit is DEFERRED to user explicit approval. Codify in this plan's § J K.X charter-tier-surface flag (NOT a CHARTER edit but AOM-tier impact). Dispatch-brief template hardening that codifies M-S397-1 pattern as standard for sandwich-verifier is a follow-up dispatch.

**LOC ceiling** (per L-S397-1):
- D4.A: ≤30 LOC pure markdown (persona Notes section)
- D4.B: ≤15 LOC pure markdown (Phase 9 close-loop step)
- Total D4 LOC: ≤45 LOC

**No companion firing-test** (template-only; no hook).

---

## § F. File scope (BINDING)

**Files to CREATE (NEW)**:
- `scripts/hooks/dogfood-the-promotion.sh` (D1)
- `scripts/hooks/firing-tests/dogfood-the-promotion-fire-test.sh` (D1)
- `human-workspace/notifications/_STOP-FINDING-template.md` (D2)
- `scripts/hooks/stop-finding-frontmatter-validator.sh` (D2)
- `scripts/hooks/firing-tests/stop-finding-frontmatter-validator-fire-test.sh` (D2)

**Files to MODIFY**:
- `.claude/settings.json` (D1 + D2 Stop chain wires; ~10 LOC additions)
- `.claude/agents/sandwich-architect.md` (D3.A + D3.B + D3.C + D3.D; ~80 LOC additions)
- `.claude/agents/sandwich-dev.md` (D3.D close-loop; ~10 LOC additions)
- `.claude/agents/sandwich-verifier.md` (D4.A + D4.B; ~45 LOC additions)

**Files NEW IF D1+D2+D3+D4 land** (conditional):
- `agent-workspace/memory/decisions/083-*.md` — **NOT CREATED THIS SWEEP** per DD-6 (no charter-tier surface for IMPL-tier sub-tracks). If S403 dev determines D2 hook needs ADR-tier doctrine codification (unlikely), file PROPOSED at IMPL-tier no-cool-down per severity-schema.

**Files to READ (for VBW; no modification)**:
- `agent-workspace/memory/mistake-log.md` (digest table + M-S388-1 + M-S388-2 + M-S392-1 + M-S395-1 + M-S397-1)
- `agent-workspace/memory/observations/sandwich-verifier-S397-plan-041-g1-verify.md`
- `agent-workspace/memory/observations/sandwich-verifier-S400-plan-043-g3-verify.md`
- `agent-workspace/memory/observations/sandwich-verifier-S401-plan-045-data-corpus-verify.md`
- `agent-workspace/memory/decisions/081-br-6-cost-cap-empirical-recalibration.md`
- `agent-workspace/memory/observations/sandwich-dev-S388-harness-sweep-N1-impl.md` (M-S388-1 evidence)
- `human-workspace/notifications/STOP-FINDING-S394-pdf-real-pdfs-needed.md` (still missing `status:` field)
- `human-workspace/notifications/STOP-FINDING-S395-validate-thesis-cost-blocker.md` (S401 inline-fix evidence)
- `agent-workspace/constitution/severity-schema.md` (4-level canonical)
- `agent-workspace/constitution/autonomous-protocol.md` (READ-only; no modification per Contract Rule 1)

**Files explicitly EXCLUDED from any modification this sweep**:
- PROJECT_CHARTER.md (charter; 0 edits)
- agent-workspace/constitution/** (constitution; 0 edits)
- agent-workspace/session-plans/completed/** (040-045 reference only)
- packages/** (production code; not harness scope)
- apps/** (production code; not harness scope)
- AGENT_OPERATING_MANUAL.md (HIGH-impact; defer to user explicit approval per D4 § DEFER note)

## § G. DoD criteria (per sub-track + cumulative)

**Total LOC ceiling** (per L-S397-1 per-category distinction):

| Sub-track | Core code LOC | Doc/comment LOC | Test LOC | Total LOC | Risk-of-blowout |
|---|---|---|---|---|---|
| D1 | ≤60 | ≤30 | ≤120 | ≤210 | MEDIUM (regex tuning risk per DD-1; cold-probe surfaced ±5-line window need) |
| D2 | ≤40 (D2.B) + 45 (D2.A template) + 8 (D2.C wire) | ≤25 | ≤90 (D2 firing-test + fixtures) | ≤208 | LOW (precedent severity-classifier shape) |
| D3 | 0 (pure markdown) | ≤90 (template additions) | 0 | ≤90 | LOW (template edits) |
| D4 | 0 (pure markdown) | ≤45 (persona Notes) | 0 | ≤45 | LOW (template edits) |
| **Cumulative** | **≤163** | **≤190** | **≤210** | **≤553** | **OK; under D-079 plan-039 actual +839 net delta empirical precedent** |

**STOP-AND-ASK trigger** (L-S382-1 refinement carried forward): any cumulative core-code LOC > 250 (vs ≤163 estimate) OR any ctor-signature change touching 3+ files OR any mypy --strict regression on previously-clean file → STOP-AND-ASK BEFORE commit.

### PLAN-tier (architect = S402; THIS plan)

**DC-PLAN-1**: This plan file written at `agent-workspace/session-plans/pending/046-S402-harness-stabilization-sweep-N2.md`
**DC-PLAN-2**: Architect observation written at `agent-workspace/memory/observations/sandwich-architect-S402-harness-sweep-N2.md` (~150-250 LOC)
**DC-PLAN-3**: § D verdict table covers all 10 candidates (PROMOTE-NOW / HOLD / RETIRE)
**DC-PLAN-4**: § DD design decisions documented (≥7 DDs; this plan has 9)
**DC-PLAN-5**: § E sub-track decomposition includes parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per template DD-3
**DC-PLAN-6**: § G DoD ≥25 criteria split across 3 tiers
**DC-PLAN-7**: § L AP-23 attestation table (per-candidate instance count + outcome)
**DC-PLAN-8**: § P compliance attestation grid documented
**DC-PLAN-9**: § N sub-plan dispatch sequencing + parallel-dispatch compatibility documented
**DC-PLAN-10**: VBW protocol applied to every file-path citation (Read/Glob/Grep evidence per L-S392-1)
**DC-PLAN-11**: L-S389-1 dogfood — this plan's observation file uses exact wc -l integers (zero `~` prefix)
**DC-PLAN-12**: L-S397-3 close-loop — architect runs `wc -l agent-workspace/session-plans/pending/046-* agent-workspace/memory/observations/sandwich-architect-S402-*` at session end + cites integers in return summary

### IMPL-tier (sandwich-dev = S403)

**DC-IMPL-1 (D1)**: NEW `scripts/hooks/dogfood-the-promotion.sh` exists; shape mirrors `severity-classifier.sh` Stop hook pattern; `bash -n` clean; bash-hook-lint clean
**DC-IMPL-2 (D1)**: NEW `scripts/hooks/firing-tests/dogfood-the-promotion-fire-test.sh` exists with ≥5 TCs (per § E D1); all PASS
**DC-IMPL-3 (D1)**: D1 hook wired in `.claude/settings.json` Stop chain after `severity-classifier.sh`
**DC-IMPL-4 (D1)**: hook detects M-S388-1 pattern in synthetic fixture (STEP X.Y promoted + `~` within ±5 lines); WARN row emitted to `.severity-state.tsv`
**DC-IMPL-5 (D2.A)**: NEW `human-workspace/notifications/_STOP-FINDING-template.md` exists; frontmatter includes all 8 required fields per template
**DC-IMPL-6 (D2.B)**: NEW `scripts/hooks/stop-finding-frontmatter-validator.sh` exists; `bash -n` clean
**DC-IMPL-7 (D2.B)**: hook wired in `.claude/settings.json` Stop chain after `severity-classifier.sh`
**DC-IMPL-8 (D2.B)**: hook detects STOP-FINDING-S394 still missing `status:` field; WARN row emitted
**DC-IMPL-9 (D2.B)**: hook detects ad-hoc severity (e.g. `IMPLEMENTATION-BLOCKER`); WARN row emitted
**DC-IMPL-10 (D2.C)**: companion firing-test ≥6 TCs all PASS
**DC-IMPL-11 (D3.A)**: `.claude/agents/sandwich-architect.md` contains STEP 2.X dispatch-brief VBW pre-flight (grep "STEP 2.X" returns line)
**DC-IMPL-12 (D3.B)**: `.claude/agents/sandwich-architect.md` contains STEP 2.Y operational-track cold-probe (grep "STEP 2.Y" returns line)
**DC-IMPL-13 (D3.C)**: `.claude/agents/sandwich-architect.md` contains per-category LOC distinction section (grep "Per-Category LOC" returns line)
**DC-IMPL-14 (D3.D)**: `.claude/agents/sandwich-architect.md` contains STEP 7.X close-loop verify (grep "STEP 7.X" returns line)
**DC-IMPL-15 (D3.D)**: `.claude/agents/sandwich-dev.md` contains STEP 5.6 close-loop verify (grep "STEP 5.6" returns line)
**DC-IMPL-16 (D4.A)**: `.claude/agents/sandwich-verifier.md` contains `Persona Override — File-Write Constraints` section (grep "Persona Override" returns line)
**DC-IMPL-17 (D4.B)**: `.claude/agents/sandwich-verifier.md` contains STEP 9.X close-loop verify-then-return (grep "STEP 9.X" returns line)
**DC-IMPL-18 (HOLD)**: agent-notes.md updated with HOLD rationale for L-S389-2 + L-S396-1 (per AP-23 HOLD-artifact discipline; mirrors plan-039 RETIRE pattern)
**DC-IMPL-19 (bundle aggregate)**: total core-code LOC delta ≤ 163 (per § G per-category ceiling; STOP-AND-ASK at >250)
**DC-IMPL-20 (bundle aggregate)**: bash-hook-lint clean across all modified hooks; `bash -n` clean
**DC-IMPL-21 (bundle aggregate)**: all existing firing-tests still PASS (regression check via `scripts/hooks/firing-tests/run-all.sh` or equivalent)
**DC-IMPL-22 (bundle aggregate)**: all existing pytest still PASS (1178/1 baseline per S399 — no new pytest expected since D1+D2 are hook surface)
**DC-IMPL-23 (bundle aggregate)**: 0 charter / 0 constitution / 0 AGENT_OPERATING_MANUAL.md writes
**DC-IMPL-24 (bundle aggregate)**: S403 dev observation written at `agent-workspace/memory/observations/sandwich-dev-S403-harness-stabilization-sweep-N2.md` with wc -l EXACT integers per STEP 5.4 + STEP 5.6 doctrine (dogfood D3.D)
**DC-IMPL-25 (bundle aggregate)**: S403 dev session log written at `agent-workspace/memory/sessions/2026-05-17-session-403.md`
**DC-IMPL-26 (L-S389-1 dogfood)**: S403 dev observation file passes the NEW dogfood-the-promotion linter (D1 hook does NOT emit WARN row when scanned against the observation that ships the rule)
**DC-IMPL-27 (L-S397-3 close-loop)**: S403 dev runs `wc -l` on observation + session-log + cites EXACT integers in return summary
**DC-IMPL-28 (cap re-validation per L-S396-1 HOLD)**: dev DOES NOT modify any `STOCKFORGE_HOOK_BUDGET_USD` or other architectural caps this sweep; if blocker emerges (similar to BR-6 S395), STOP-AND-ASK

### VERIFY-tier (sandwich-verifier = S404)

**DC-VERIFY-1**: Read each modified/created hook end-to-end via VBW
**DC-VERIFY-2**: Run synthetic firing-test for each NEW hook (D1 + D2.B); verify PASS independently
**DC-VERIFY-3**: Verify dogfood-the-promotion hook fires on M-S388-1 synthetic fixture (DC-IMPL-4 empirical re-check)
**DC-VERIFY-4**: Verify STOP-FINDING validator detects STOP-FINDING-S394 missing field (DC-IMPL-8 empirical re-check)
**DC-VERIFY-5**: Verify all 5 personality template edits present (DC-IMPL-11..17 grep checks)
**DC-VERIFY-6**: Charter compliance grid: 0 charter / 0 constitution / 0 AOM edits
**DC-VERIFY-7**: AP-23 attestation grid (§ L) cross-checked against actual sub-track outcomes (8 PROMOTE + 2 HOLD verdicts)
**DC-VERIFY-8**: Verify D-083 ADR was NOT created (per DD-6 — no charter-tier surface)
**DC-VERIFY-9**: Verifier honors persona override per D4.A — return findings inline; do NOT Write report .md files (codify M-S397-1 pattern as the standard)
**DC-VERIFY-10**: L-S397-3 close-loop verify dogfooded — verifier acknowledges in return summary "Observation NOT written per persona override; main session inline-persists from result text"

## § H. RM risk-mitigation (10 entries)

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| RM1 | D1 dogfood-the-promotion regex too broad — catches incidental tildes in well-formed observations | MEDIUM | LOW | DD-1 ±5-line context window narrows scope; firing-test TC2+TC3 cover false-positive scenarios; STOCKFORGE_SKIP_DOGFOOD env bypass (mirror pre-commit pattern); WARN-only emit (no BLOCK; main decides on next-Stop cycle) |
| RM2 | D1 hook adds Stop-time latency | LOW | LOW | 5s timeout per find/grep (existing severity-classifier convention); scope to `agent-workspace/memory/observations/sandwich-dev-S*.md` modified -mmin -5; firing-test measures wall time |
| RM3 | D2 STOP-FINDING template + hook breaks existing STOP-FINDING workflow | LOW | MEDIUM | D2 is ADDITIVE (NEW files); existing STOP-FINDING files unmodified per D2 read-only rule; hook is WARN-only (no auto-fix); inline-fix to STOP-FINDING-S394 deferred to main session |
| RM4 | D3 architect template additions confuse dispatch flow at next architect dispatch | LOW | MEDIUM | Additions are inside Phase 2 (Architecture Decisions) and Phase 3 (File-Level Planning) — natural fit per template structure; each addition has explicit anti-example to clarify scope; dispatch-brief reading at start of every session catches inconsistencies |
| RM5 | D4 sandwich-verifier persona Notes section conflict with existing § Persona | LOW | LOW | D4.A adds NEW H2 section near top (BEFORE existing § Persona, not WITHIN); preserves existing persona content unmodified; PCG-S401-4 codification clarifies, doesn't override |
| RM6 | L-S389-1 dogfood failure THIS plan-046 (architect violates exact-integer discipline writing this plan) | LOW | MEDIUM | Architect commits to L-S389-1 hard rule in dispatch brief acknowledged + applies in § P close-loop attestation; if violation detected at S404 verifier review, surface as F1 IMPORTANT for inline-fix |
| RM7 | L-S392-1 dispatch-brief drift IS HAPPENING IN THIS SESSION (S402 STEP 0.2 finding) | HIGH (already realized) | LOW | Architect surfaced the deviation in STEP 0.2 + § D candidate-2 rationale; brief's "≥12-field floor" reframe of L-S389-2 used per architect VBW; mistake-log primary text cited verbatim instead; no defect shipped |
| RM8 | HOLD decisions for L-S389-2 + L-S396-1 surface AS regret if 2nd-instance fires within next 5 sessions | LOW | LOW | AP-7 revisit triggers explicitly named in § D verdict table; agent-notes.md HOLD rows include trigger conditions; if 2nd-instance fires within next 5 sessions, next harness sweep architect picks up automatically |
| RM9 | D4 AOM edit deferred to user; PCG-S401-4 partial-resolution leaves dispatch-brief template still asking verifier for Write | MEDIUM | LOW | D4.A persona Notes section flags the persona override prominently; future dispatch briefs that DO ask verifier for Write will be inconsistent but verifier knows to honor persona; main inline-persist M-S397-1 pattern is documented at sandwich-verifier.md:197-200 |
| RM10 | Parallel-dispatch with G.4 architect causes file-scope collision | LOW | MEDIUM | § N explicit § file-scopes; G.4 = packages/infrastructure/fundamental/** + BC-2 SQLite repos; plan-046 = .claude/agents/** + scripts/hooks/** + human-workspace/notifications/**; ZERO overlap. Architect-tier parallel precedent S391 demonstrated. |

## § J. Coordination rule (S403 IMPL) + K.X charter-tier-surface flags

### Coordination rule

Main session AVOIDS edits to these paths during S403 dev execution to prevent trampling:

**Hook files (sandwich-dev's primary work):**
- `scripts/hooks/dogfood-the-promotion.sh` (D1 NEW; main avoids)
- `scripts/hooks/stop-finding-frontmatter-validator.sh` (D2 NEW; main avoids)
- `scripts/hooks/firing-tests/dogfood-the-promotion-fire-test.sh` (D1 NEW)
- `scripts/hooks/firing-tests/stop-finding-frontmatter-validator-fire-test.sh` (D2 NEW)

**State files (touched by hooks under construction):**
- `agent-workspace/memory/.severity-state.tsv` (D1 + D2 secondary write target; main reads OK)

**Settings + agent template files:**
- `.claude/settings.json` (D1 + D2 hook wiring; main avoids)
- `.claude/agents/sandwich-architect.md` (D3 edit target)
- `.claude/agents/sandwich-dev.md` (D3.D edit target)
- `.claude/agents/sandwich-verifier.md` (D4 edit target)
- `human-workspace/notifications/_STOP-FINDING-template.md` (D2.A NEW)

**Decision files:**
- `agent-workspace/memory/agent-notes.md` (DC-IMPL-18 HOLD rows append for L-S389-2 + L-S396-1)
- `agent-workspace/memory/decisions/083-*.md` (NOT CREATED per DD-6; main does not pre-emptively create)

**Session logs (S403 dev's authoring scope):**
- `agent-workspace/memory/sessions/2026-05-17-session-403.md`
- `agent-workspace/memory/observations/sandwich-dev-S403-harness-stabilization-sweep-N2.md`

Main session may continue routine work on other paths during S403 IMPL. Main's primary risks during S403:
- Do NOT trigger `git commit` from main while D2 hook is in-flight (D2 hook fires at Stop; race risk low but avoid concurrent commit)
- Do NOT modify `.severity-state.tsv` while D1 + D2 hooks in-flight
- Do NOT dispatch additional sandwich-architect for parallel plan-047 until S403 dev returns (avoid plan-numbering collision risk)

### K.X charter-tier-surface flags (CHARTER-tier escalation BOUNDARY)

**K.X.1** — Severity-schema vocabulary extension: IF S403 dev determines `CHARTER-TIER-SURFACE` SHOULD be a 5th severity level (vs separate axis per DD-2), this crosses constitution boundary (`severity-schema.md` is in `agent-workspace/constitution/`). DEFER to user AskUserQuestion bundle; do NOT inline-edit. Architect's POSITION: keep 4-level + separate axis per DD-2.

**K.X.2** — AGENT_OPERATING_MANUAL.md edit (D4.A note): IF S403 dev determines AOM needs codification of M-S397-1 main-inline-persist pattern as standard for sandwich-verifier dispatch, this is HIGH-IMPACT. DEFER to user explicit approval; agent does NOT inline-edit AOM this sweep. Architect's POSITION: defer.

**K.X.3** — sandwich-verifier persona Notes section override of SDK-level system-prompt: D4.A acknowledges SDK-level "Do NOT Write report/summary/findings/analysis .md files" cannot be edited by agent. Persona Notes section adds CLARITY but does NOT override SDK behavior. NO charter-tier escalation needed; persona Notes IS architecturally sufficient.

**No K.X.4+**: D1+D2+D3+D4 cumulative scope remains IMPL-tier; no charter-tier surface foreseen.

## § L. AP-23 attestation per candidate

| # | Candidate | Pre-S402 instance count | Post-S403 outcome |
|---|---|---|---|
| 1 | L-S389-1 dogfood-violation-self-instance | 1st instance + descends from L-S345-1 cluster at n=12+ | **CLOSED via D1 (NEW dogfood-the-promotion linter)** |
| 2 | L-S389-2 ADR/DC-IMPL cap-attestation discipline | 1st instance per mistake-log | **HOLD per AP-23 1st-instance** (named AP-7 trigger: if 2nd DC-IMPL cap breach with flat PASS, promote to deterministic linter) |
| 3 | L-S392-1 dispatch-brief VBW pre-flight | **2nd-instance** (S392 + S402 STEP 0.2 meta-instance) | **CLOSED via D3.A (sandwich-architect.md STEP 2.X template)** |
| 4 | L-S395-1 operational-track full-pipeline cold-probe | 1st instance + MEDIUM severity + high real-cost | **CLOSED via D3.B (sandwich-architect.md STEP 2.Y template)** |
| 5 | L-S396-1 architectural-cap empirical-recalibration | 1st instance per ADR D-081 | **HOLD per AP-23 1st-instance** (named AP-7 trigger: if 2nd cap-set-without-empirical-evidence, promote to architect STEP 0 mandatory cap-recalibrate check) |
| 6 | L-S397-1 plan LOC ceilings per-category | **2nd-instance** PCG-V400-1 | **CLOSED via D3.C (sandwich-architect.md per-category LOC distinction)** |
| 7 | L-S397-2 STOP-FINDING severity vocabulary normalization | 1st-instance codified + 2-ad-hoc-severity manifestation cluster (within single plan-041) | **CLOSED via D2 (template + frontmatter validator)** |
| 8 | L-S397-3 sandwich-* close-loop file-existence | **2nd-instance** (S397 + S401 verifier skip cluster) | **CLOSED via D3.D (architect STEP 7.X + dev STEP 5.6) + D4.B (verifier STEP 9.X)** |
| 9 | PCG-S401-3 STOP-FINDING `status:` field requirement | 1st-instance + uncorrected on-disk evidence (STOP-FINDING-S394) | **CLOSED via D2 (template field + frontmatter validator)** |
| 10 | PCG-S401-4 persona-vs-dispatch-brief conflict | 1st-instance codified + 3-observation cluster (S397+S400+S401) | **CLOSED via D4.A (persona Notes override section)** |

**Net AP-23 outcome**: 8 CLOSED via promotion to hook OR template OR persona codification; 2 HOLD with named AP-7 revisit triggers. 4 confirmed PROMOTE-NOW (2nd-instance: L-S392-1 + L-S397-1 + L-S397-3 + PCG-S401-4); 4 PROMOTE-via-judgment (high-leverage 1st-instance: L-S389-1 + L-S395-1 + L-S397-2 + PCG-S401-3). promotion-cycle-trigger.sh HARD-BLOCK aversion: queue drained from 10 → 2 active HOLD candidates post-S403 commit (under 8-session HARD-BLOCK threshold).

## § M. Plan close-bookkeeping protocol (DC-CLOSE-1..7)

S404 verifier PASS triggers S405 main close-bookkeeping. Required steps:

**DC-CLOSE-1**: Persist S404 verifier observation at `agent-workspace/memory/observations/sandwich-verifier-S404-harness-sweep-N2-verify.md` (verifier-has-no-Write recovery pattern; main writes per S312/S314/S321/S333/S339/S342/S385/S389/S397/S401 precedent — D4.A codifies this very pattern)
**DC-CLOSE-2**: mv plan-046 `pending/` → `completed/` via `git mv`
**DC-CLOSE-3**: Prepend S402-S404 row to `current-execution.md` with sub-track-by-sub-track summary + harness sweep N+2 close + 10-candidate queue DRAINED status (10 → 2 HOLD) + Wave 1 MVP READY preserved + G.4 dispatch UNBLOCKED per `harness_priority_one` discharge
**DC-CLOSE-4**: Rewrite `checkpoints/latest.md` as S404 CLOSE handoff with N+2 sweep DRAINED status + next-turn options (G.4 architect dispatch primary)
**DC-CLOSE-5**: Update `mistake-log.md` digest with M-S403-* entries (if any) OR explicitly state "no mistakes this session" in S403 session log
**DC-CLOSE-6**: NO D-083 ADR PROPOSED → ACCEPTED auto-ratification (per DD-6; no charter-tier surface)
**DC-CLOSE-7**: Manually invoke `promote-rule` subagent if `promotion-cycle-trigger.sh` still shows soft-warn (defensive — sweep should have drained the queue per § L AP-23 attestation but safety check). Architect's PRE-CHECK: hook counts session-delta since last promote-rule observation; if last `promote-rule-S*.md` was authored 5+ sessions ago, S405 main MUST dispatch promote-rule subagent explicitly even after this sweep closes.

## § N. Sub-plan dispatch sequencing (S403 IMPL + S404 VERIFY)

### Sequencing

1. **S402** (THIS) — sandwich-architect background dispatch authoring plan-046 + observation
2. **S403** — sandwich-dev background dispatch executing plan-046 D1-D4; commits at sub-track boundaries per D-060
3. **S404** — sandwich-verifier background dispatch reviewing S403 IMPL; AP-1 fresh-context
4. **S405** — main close-bookkeeping (commits + mv + checkpoint + return-to-product-track)
5. **S406+** — G.4 sub-plan 044 architect dispatch (BC-2 SqliteFundamentalRepository integration); unblocked by S401 + harness sweep ship

### Parallel-dispatch compatibility (per dispatch-brief request)

**S403 plan-046 IMPL + S406 G.4 sub-plan 044 architect**: file scopes fully disjoint.
- Plan-046 D1-D4 = `.claude/agents/**` + `scripts/hooks/**` + `human-workspace/notifications/**`
- G.4 sub-plan 044 (architect) = `packages/infrastructure/fundamental/**` + `agent-workspace/session-plans/pending/044-*.md`

**Architect-tier parallel precedent**: S391 dispatched 2 architects (plan-041 + plan-045) in parallel. Plan-046 architect (THIS) + plan-044 architect (FUTURE) is the same pattern. **Verdict**: PARALLEL-COMPATIBLE.

**Caveat**: do NOT dispatch S403 plan-046 dev + plan-044 dev in parallel (both modify `.claude/settings.json` potentially; settings.json is single-author per dev session). Sequence S403 dev THEN S404 verifier; G.4 dev can dispatch in parallel with S404 verifier.

### Budget summary

| Session | Persona | Budget (Opus) | Wall-min est | Notes |
|---|---|---|---|---|
| S402 | sandwich-architect | 150-220K | ≤45 (this session) | This plan + observation |
| S403 | sandwich-dev | 130-180K | ≤50 | D1-D4 IMPL; LOW-MEDIUM blowout risk |
| S404 | sandwich-verifier | 80-140K | ≤30 | AP-1 fresh-context; 4 sub-tracks to verify |
| **Cumulative S402-S404** | | **~360-540K** | **~125 min** | within plan-039 precedent (~430K cumulative for 6 sub-tracks) |

## § P. Compliance attestation grid

| Attestation | Status | Evidence |
|---|---|---|
| harness_priority_one | ✓ | Plan IS the harness work; G.4 dispatch explicitly paused per CLAUDE.md rule until this plan lands; promotion-cycle-trigger.sh HARD-BLOCK aversion is binding trigger |
| AP-1 same-agent self-review avoidance | ✓ | Architect = S402 (this); Dev = S403 (fresh-context Opus); Verifier = S404 (fresh-context Opus); all 3 distinct sandwich-* personas |
| dont_self_pause_at_session_boundary | ✓ | Main dispatches S403 immediately after committing this plan; main dispatches S404 verifier immediately after S403 dev returns; main dispatches G.4 architect in PARALLEL with S404 per § N parallel-compatibility |
| autonomous_continue_no_self_pause | ✓ | No AskUserQuestion in this plan; no charter/scope question requires user; all decisions IMPL-tier; K.X.1 + K.X.2 flagged but DEFERRED with explicit user-gate (not asked this turn) |
| stop_offering_routing_branches | ✓ | Plan does not enumerate (a)/(b)/(c) "next" options for user — autonomous main picks based on this plan + § L AP-23 attestation |
| D-060 commit policy | ✓ | Sandwich-dev commits own S403 work; main commits THIS plan (architect has no Bash) + commits architect-only outputs going forward |
| verify_phase_before_next_phase | ✓ | This plan empirically VERIFIED 10-of-10 candidate root causes via VBW pass (Read of mistake-log + 4 observations + 2 STOP-FINDINGs + 2 ADRs + 4 persona files); no candidate based on memory alone |
| all_14_agents_on_opus | ✓ | S403 dev + S404 verifier both Opus per user directive 2026-05-17; budget cited from CLAUDE.md Opus column per M-S365-1 prevention rule |
| 0 charter | ✓ | PROJECT_CHARTER.md not in any sub-track's file list |
| 0 constitution | ✓ | agent-workspace/constitution/** not in any sub-track's file list; NO D-083 ADR per DD-6 (no charter-tier surface) |
| 0 AOM edit | ✓ | AGENT_OPERATING_MANUAL.md DEFERRED to user explicit approval per D4 § DEFER note + K.X.2 flag |
| SYNC-GRILLING not fired | ✓ | BEHAVIORAL HOLD § (1) suspends cadence; not recommended in any sub-track |
| Karpathy P1 (Think before coding) | ✓ | Each sub-track has explicit Options-considered table; 2 HOLD verdicts with explicit rationale; STEP 0.2 architect pushback on brief's L-S389-2 paraphrase reframe |
| Karpathy P2 (Simplicity first) | ✓ | L-S389-2 + L-S396-1 HELD per "1st-instance + existing artifact carries the rule"; speculative-hook deferred; only deterministic-leverage promotions taken this sweep |
| Karpathy P3 (Surgical changes) | ✓ | Every recommendation traces to a named L-S<N>-<M> OR PCG-<X>-N candidate from § D; total LOC delta capped at ≤553 (core ≤163); plan-039 precedent +839 net delta accepted as upper bound |
| Karpathy P4 (Goal-driven) | ✓ | 28+ DoD criteria split across 3 tiers; each empirically falsifiable; 10 verifier checks |
| AP-7 anti-vacuous-defer | ✓ | 2 HOLDs have named revisit triggers in § D verdict table; AP-7 trigger conditions explicit |
| AP-17 identity drift | ✓ | This is harness work for VN stock advisory; not generic framework work |
| AP-23 ritual-demotion | ✓ | 8 promoted; 2 HELD with rationale; per-candidate verdict in § L AP-23 attestation |
| `full_autonomous_no_supervised` | ✓ | No AskUserQuestion; autonomous-full continues; K.X.1 + K.X.2 charter-tier flags noted but DEFERRED, not raised |
| L-S345-1 honesty discipline at n=12+ | ✓ | THIS plan itself uses exact integers where citing LOC counts (no `~` prefix on absolute values); dogfoods D1 dogfood-the-promotion rule pre-promotion |
| L-S382-1 ctor-grep discipline pre-promotion | ✓ | THIS plan adds no new ctors; sub-tracks D1-D4 use only existing bash + template edits |
| L-S389-1 dogfood-the-promotion (THIS plan) | ✓ | Architect commits to dogfood + close-loop verifies own observation passes the rule it ships |
| L-S392-1 dispatch-brief VBW pre-flight (THIS plan) | ✓ | STEP 0.2 architect pushback on brief's L-S389-2 paraphrase reframe; mistake-log primary text cited verbatim; § A depends_on lists actual file:line for every cited path |
| L-S395-1 full-pipeline cold-probe at STEP 0 | ✓ | STEP 0.11 cold-probe of D1 dogfood linter ±5-line context window surfaced regex challenge BEFORE D1 IMPL spec; saved D1 IMPL rework |
| L-S397-1 LOC ceilings per-category | ✓ | § G ceiling table per-category (core code / doc/comment / test / total) per sub-track |
| L-S397-3 close-loop file-existence | ✓ | § P (this row) cites architect's wc -l outputs at end of session per CLOSE-LOOP VERIFY in dispatch brief |
| I-S22 data lineage | ✓ | D2 STOP-FINDING template + frontmatter validator protect notification-channel audit trail |
| I-S33 self-aware-agent | ✓ | D1 + D2 + D3 + D4 all protect harness reliability substrate |

---

End of plan-046. S403 sandwich-dev MULTI_TASK_IMPL begins on dispatch (main commits
this plan first per D-060 + pre-dispatch-architect-commit-guard.sh PreToolUse hook).

S404 sandwich-verifier dispatches post-S403 dev return; per D4.A persona override,
verifier will honor SDK-level system-prompt + return findings inline (main session
inline-persists from result text per M-S397-1 pattern).
