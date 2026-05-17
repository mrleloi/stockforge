---
plan_id: 039-S387-harness-stabilization-sweep-N1
target_session: S388
type: MULTI_TASK_IMPL
budget: 150-220K (Opus FOCUSED_IMPL / MULTI_TASK_IMPL hybrid; D1+D2 dominate budget; D3-D7 surgical)
phase: B/D-overlap (HARNESS — not product work; harness_priority_one doctrine
       takes precedence over data-corpus ingestion + Phase G-prime until the
       9-candidate queue is drained AND promotion-cycle-trigger.sh HARD-BLOCK
       at next SessionStart is averted)
track: Harness Stabilization Sweep N+1 — close 9-candidate promotion queue
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md
                    (Phase F-prime CODE-DONE-DATA-PENDING at S386; harness
                    promotion-queue at HARD-BLOCK threshold per promotion-cycle-
                    trigger.sh — sweep MUST ship before next SessionStart)
predecessor: 021-S340-harness-stabilization-sweep (completed S342; 7 anomalies
             closed; F1-F5 inline-resolved; precedent for plan shape + sub-track
             decomposition)
successor: S389 sandwich-verifier (AP-1 fresh-context, Opus, ~80-140K VERIFY budget)
architect: S387 sandwich-architect (background; this plan)
dispatched_by: S386-main close-bookkeeping turn (parent main session orchestrating
               harness PLAN-IMPL-VERIFY sandwich after Phase F-prime close)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S388; fresh-context; Opus
                 per all-14-agents-on-Opus directive; AP-1 verifier in S389)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (post 2026-05-14 mass-deletion)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING cadence + ROUTINE-IDLE close ritual SUSPENDED (carry-forward; do NOT recommend sync-grilling cadence as part of fixes)"
  - "promotion-cycle-trigger.sh HARD-BLOCK pending at next SessionStart (≥8 new lessons since last promote-rule dispatch; current queue = 9 — sweep is BLOCKING)"

depends_on:
  - "D-060 (commit-policy-agent-may-commit — operational gate for S388 dev commit boundary; main commits architect-only outputs per dispatch-template-gap recovery pattern + pre-dispatch-architect-commit-guard.sh PreToolUse hook)"
  - "D-062 (atomic-write-doctrine — BINDING for any new state/marker writes introduced by D1+D5+D6)"
  - "D-064 (path-safety 5-invariant contract — BINDING for any new file-path code; uses helpers from packages/_shared/path_safety.py — applies to L-S371-1 resolver factor-out if INCLUDE)"
  - "D-066 ACCEPTED (Theme L adapter contract — referenced by resolver pattern L-S371-1 if INCLUDE)"
  - "Charter v1.1 Principle 11 (Harness must self-verify firing — D1/D2/D3 ALL ship companion firing-tests + verification grids)"
  - "Charter v1.1 Principle 7 (Dogfood mandatory — fixes self-audited via the affected hook chains in same session)"
  - "Charter v1.1 Principle 6 (Adversarial by default — L-S385-3 INCOMPLETE-corpus = system-working-correctly evidence; promote to template language)"
  - "Charter v1.1 Principle 8 (Calibration over confidence — L-S385-1 wc -l exact-at-end discipline reinforces; L-S385-2 CODE-DONE-DATA-PENDING attestation pattern reinforces)"
  - "I-S22 (Data lineage — L-S366-3 cultural-anchor provenance audit-trail reinforces invariant; L-S369-1 ADR empirical_close_verify drift detection protects it for ACCEPTED ADRs)"
  - "I-S33 self-aware-agent invariant (harness reliability is the substrate for I-S33; L-S382-1 PreCommit pytest regression hook protects it for dev commit boundary)"
  - "agent-workspace/CLAUDE.md Contract Rule 1 (constitution immutable absent explicit human approval — sandwich-dev cannot edit constitution/; if D2 PreCommit hook needs doctrine codification, lands as PROPOSED ADR D-079 at IMPL tier with no cool-down)"
  - "CLAUDE.md AP-23 ritual demotion: 'Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG: 2nd instance mandates promote-or-retire (not inline accumulation)' — applied per-candidate in § C verdict table"
  - "CLAUDE.md `harness_priority_one` memory rule (harness/system improvement is always higher priority than product work)"
  - "CLAUDE.md all_14_agents_on_opus rule (S388 dev + S389 verifier both Opus per user directive 2026-05-17)"
  - "scripts/hooks/promotion-cycle-trigger.sh (the hook that will HARD-BLOCK at next SessionStart unless this sweep ships)"
  - "scripts/hooks/planner-feedback-loop.sh (D2 primary investigation target for L-S354-2 9th-instance — currently header-only TSV, never populated)"
  - "scripts/hooks/adr-empirical-close-verify-spot-check.sh (D5 already-shipped substrate; L-S369-1 promotes wiring + cadence rules)"
  - "scripts/hooks/pre-dispatch-architect-commit-guard.sh (D3 PROMOTE-NOW precedent from S341 plan-021; PreToolUse pattern reference for new D2 hook)"
  - "scripts/hooks/destructive-command-guard.sh (D3+D6 PreToolUse hook pattern reference)"
  - "scripts/hooks/severity-classifier.sh (D5 ADR coherence drift detection consumer)"
  - ".claude/agents/sandwich-architect.md (D7 plan template subject; D8 dev-OBS-template subject)"
  - ".claude/agents/sandwich-dev.md (D1 template subject for wc -l exact-at-end; D7 template subject; D8 STEP 0 ctor-grep doctrine)"
  - ".claude/agents/sandwich-verifier.md (D7 template subject for CODE-DONE-DATA-PENDING attestation language; D6 INCOMPLETE-corpus framing language)"
  - "agent-workspace/session-plans/completed/021-S340-harness-stabilization-sweep.md (plan shape reference — Sections A-N template)"
  - "agent-workspace/memory/observations/sandwich-architect-S340-harness-stabilization-plan.md (observation format reference)"
  - "agent-workspace/memory/checkpoints/latest.md § 4 Promotion candidates + 5 carry-forward (the 9-item queue snapshot from S386 close)"
  - "agent-workspace/memory/observations/sandwich-verifier-S385-f5-vhm-dogfood-verify.md § SECTION 5 (L-S385-1..4 rationales)"
  - "agent-workspace/memory/observations/sandwich-verifier-S382-f3-synthesize-perspectives-verify.md § Promotion candidates (L-S382-1 cluster rationale)"
  - "agent-workspace/memory/observations/sandwich-verifier-S369-vn-claim-extraction-verify.md § Promotion candidates (L-S369-1 cluster with L-S363-2 = PROMOTE-NOW threshold MET)"
  - "agent-workspace/memory/observations/sandwich-verifier-S366-vn-sentiment-lexicon-verify.md § L-S366-3 (cultural-anchor frozenset audit-trail rationale)"
  - "apps/_shared/entities/vn_ticker_resolver.py (L-S371-1 evidence — the existing resolver pattern that L-S371-1 proposes to factor out)"

binding_decisions:
  - "D-060 — agent MAY git commit (NOT push); S388 dev decides commit boundary; main commits this plan output (architect has no Bash)"
  - "AP-23 promote-or-retire — applied per-candidate at § C verdict table; rationale documented per AP-7 anti-vacuous-defer"
  - "AP-7 anti-vacuous-defer — every DEFER + RETIRE decision in this plan names (a) prerequisites + (b) revisit trigger; no 'Out-of-scope item N with no follow-up'"
  - "Karpathy P1 — Think before planning: explicit RETIRE verdicts surfaced for L-S385-3 + L-S385-4 (anti-bundling discipline)"
  - "Karpathy P2 — Simplicity first: no speculative bundling; only the 9 candidates + their direct prerequisites; D-079 ADR draft ONLY if D2 NEW hook lands"
  - "Karpathy P3 — Surgical: every change traces to a named L-S<N>-<M> candidate; no invented harness work"
  - "VBW protocol mandatory — before recommending any hook change, READ the actual hook file; this plan cites file:line for every claim per I-S2"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL; this plan is architect's; S388 is dev's)"
  - "no commits in THIS plan-session (sandwich-architect subagent has no Bash tool; main commits this plan output per D-060 + pre-dispatch-architect-commit-guard.sh)"
  - "no charter / no constitution writes in THIS plan-session (0 charter / 0 constitution per S387 brief)"
  - "no AskUserQuestion gate this session (no charter/scope question; all decisions are IMPL-tier or template-tier; per `full_autonomous_no_supervised` AskUserQuestion is for SCOPE/CHARTER only)"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual hook files + observation files read end-to-end via Read tool, not memory (VBW protocol)"
---

# S388 — Harness Stabilization Sweep N+1 (close 9-candidate promotion queue)

## § A. Session metadata

| Field | Value |
|---|---|
| Plan ID | 039-S387-harness-stabilization-sweep-N1 |
| Target session | S388 (sandwich-dev, MULTI_TASK_IMPL hybrid) |
| Verify session | S389 (sandwich-verifier, AP-1 fresh-context Opus) |
| Budget (IMPL) | 150-220K Opus MULTI_TASK_IMPL (per recalibrated CLAUDE.md Opus column 200-330K; this plan trends low end because surgical scope) |
| Budget (VERIFY) | 80-140K Opus VERIFY (per recalibrated CLAUDE.md Opus column 80-180K) |
| Phase | B/D-overlap (HARNESS — non-product) |
| Type | MULTI_TASK_IMPL (7 INCLUDE sub-tracks D1-D7 across distinct file scopes) |
| Wave / Theme | Wave-1 substrate-care; closes 9-candidate promotion queue; prevents promotion-cycle-trigger HARD-BLOCK |
| Coordination paths off-limits during S388 IMPL | See § J |
| Predecessor | 021-S340 (S342 close; precedent shape) |

## § B. Why this sweep is needed NOW (binding triggers)

**Trigger 1 — `promotion-cycle-trigger.sh` HARD-BLOCK at next SessionStart**:
`scripts/hooks/promotion-cycle-trigger.sh` HARD-BLOCKs at next SessionStart when ≥8 new
lessons have accumulated since last `promote-rule` dispatch. The queue is currently AT
**9 candidates**. The next SessionStart will hard-block autonomous progress unless the
sweep ships first. Per CLAUDE.md § Session Protocol § 9: "(auto) Stop-hook
`promotion-cycle-trigger.sh` HARD-BLOCKs at next SessionStart if ≥8 new lessons
accumulated since last `promote-rule` dispatch — schedule a promote-rule subagent
dispatch in the next session if blocked".

**Trigger 2 — AP-23 ritual-demotion mandate**:
CLAUDE.md § Hard Rules: "Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG:
2nd instance mandates promote-or-retire (not inline accumulation)". Multiple candidates
are at PROMOTE-NOW threshold (L-S354-2 at 9th-instance is FAR past 2nd; L-S369-1 +
L-S363-2 cluster at PROMOTE-NOW per S369 verifier explicit; L-S382-1 at n=10 L-S345-1
trigger DIRTY).

**Trigger 3 — `harness_priority_one`**:
CLAUDE.md memory rule: "Harness/system improvement luôn ưu tiên hơn product work;
STOP product khi phát hiện harness gap, fix-then-resume autonomous". Data-corpus
ingestion (next-turn option a) + Phase G-prime (next-turn option b) MUST PAUSE until
this sweep ships.

**9-candidate queue source-of-truth** (per `checkpoints/latest.md:46-53` + S386 close-bookkeeping):

1. **L-S385-1 LOW** (1st-instance) — sandwich-dev wc -l exact-at-end discipline at n=12+ L-S345-1
2. **L-S385-2 MEDIUM** (1st-instance) — Phase closure attestation CODE-DONE-DATA-PENDING + Wave-N gate marker
3. **L-S385-3 LOW** (1st-instance) — INCOMPLETE-corpus dogfood = calibrated honesty signal per Charter Principle 6
4. **L-S385-4 LOW** (1st-instance) — bundled plan-mv at close-bookkeeping when parallel-eligible per master plan § E.4-5
5. **L-S382-1 HIGH** (n=10 L-S345-1 trigger DIRTY) — dev commit-claim vs empirical-gate divergence
6. **L-S354-2** (9TH instance) — planner-feedback-loop `.planner-stats.tsv` auto-population gap
7. **L-S369-1** — ADR `empirical_close_verify` drift detection (cluster with L-S363-2 = PROMOTE-NOW)
8. **L-S366-3** — cultural-anchor frozenset audit-trail for VN_CULTURAL_ANCHORS additions
9. **L-S371-1** — resolver pattern reusable for sector/persona/ticker resolution

## § C. Per-candidate verdict (Karpathy P1 explicit — INCLUDE / DEFER / RETIRE rationale)

Per dispatch brief: "Karpathy P1: think before planning; surface tradeoffs; if a candidate
should RETIRE rather than promote, say so explicitly with rationale".

| # | ID | Severity | Instance | Verdict | Rationale (1-paragraph) | Sub-track |
|---|---|---|---|---|---|---|
| 1 | L-S385-1 | LOW | 1st | **INCLUDE** | wc -l exact-at-end discipline is a 5-LOC `.claude/agents/sandwich-dev.md` template edit. Bundled with D7 template hardening because the cost is trivial AND the n=12+ trigger may fire before next sweep cycle if this one is deferred. AP-23 1st-instance HOLD is normally appropriate, but bundling-with-template-edits is surgical (Karpathy P3); the rule itself does not introduce new state OR new hooks — just one paragraph in the dev template. | D7 |
| 2 | L-S385-2 | MEDIUM | 1st | **INCLUDE** | CODE-DONE-DATA-PENDING attestation pattern is a Charter Principle 8 (calibration over confidence) reinforcement. M-S385-1 + 2 already cited it; future Phase closures (G-prime + H-prime + I-prime) will hit the same code-vs-data distinction. 5-LOC template edits to sandwich-architect.md + sandwich-verifier.md to standardize attestation vocabulary. Bundled with D7. | D7 |
| 3 | L-S385-3 | LOW | 1st | **RETIRE** | This is a FRAMING preference ("celebrate INCOMPLETE outcomes as system-working-correctly evidence"), not an actionable rule. The CHARTER Principle 6 (Adversarial by default) ALREADY mandates this; promoting to "template language" would just paraphrase existing charter text and add inline accumulation per AP-23 RED FLAG. **RETIRE with rationale**: rule is already enforced by Charter; no new artifact provides leverage beyond existing constitution. Documented in agent-notes.md as RETIRED-1ST-INSTANCE-DUPLICATE-OF-CHARTER per AP-23 retire-path. | (none — RETIRE) |
| 4 | L-S385-4 | LOW | 1st | **RETIRE** | Bundled-plan-mv-when-parallel-eligible was already executed at S386 (plan-037 + plan-038 mv together). The "rule" is just a 1-line dispatch heuristic that the next architect will follow if master plan § E.4-5 says parallel-eligible. **RETIRE with rationale**: rule is already informally observed (n=1 evidence S386); promoting to template would just paraphrase master plan § E.4-5; no leverage from new artifact. Documented in agent-notes.md as RETIRED-DUPLICATE-OF-MASTER-PLAN per AP-23 retire-path. AP-7 revisit trigger: if 2nd-instance fires where dev FAILS to bundle when parallel-eligible, then promote with explicit template language. | (none — RETIRE) |
| 5 | L-S382-1 | HIGH | n=10 L-S345-1 trigger DIRTY | **INCLUDE** | PROMOTE-NOW threshold MET. Cluster with M-S381-1/2 (ctor-signature-change not propagated; commit-claim vs empirical-gate divergence). Single PreCommit pytest hook protects dev commit boundary; AT MINIMUM the sandwich-dev STEP 0 doctrine update. **2-part fix**: (a) NEW `scripts/hooks/pre-commit-pytest-regression-guard.sh` PreToolUse hook on `Bash(git commit:*)` invocation; (b) sandwich-dev.md STEP 0 ctor-signature-grep doctrine. Most-leverage promotion in this sweep. | D2 (hook) + D7 (template) |
| 6 | L-S354-2 | 9th-instance | FAR past AP-23 threshold | **INCLUDE** | 9TH INSTANCE. Header-only `.planner-stats.tsv` empirically confirmed at S354/S357/S363/S366/S369/S371/S375/S378/S381 + this architect's Read at S387. Hook `planner-feedback-loop.sh` exists, fires Stop, but `find -mmin -5` plan-completion trigger never matches because plans get mv-ed at close-bookkeeping AFTER the dev session's Stop event (timing gap). **2-part fix**: (a) trigger logic change: hook should ALSO scan recently-modified completed/*.md files OR add explicit emit at plan-mv time; (b) populate `sessions-rollup.tsv` `plan_id` col9 reliably (currently absent from all rows per Read — schema-extended by plan-025 but writer never updated). Highest infrastructure-leverage fix in this sweep. | D1 |
| 7 | L-S369-1 | PROMOTE-NOW (n=2 cluster) | per S369 verifier explicit | **INCLUDE** | Cluster with L-S363-2 = PROMOTE-NOW threshold MET. `adr-empirical-close-verify-spot-check.sh` already exists (read at S387) but only random-samples ONE ADR per Stop event. **Promotion**: (a) extend to wire as Stop hook in settings.json (verify it's wired — Glob found script but didn't verify wiring); (b) on grep-claim divergence detection, write to severity-state.tsv as HIGH (the consumer of which is already in place). (c) optional: extend frequency from "random 1 per Stop" to "all ACCEPTED ADRs every 24h" via hour-bucket marker. | D5 |
| 8 | L-S366-3 | 1st-instance | HOLD normally; INCLUDE for bundle efficiency | **INCLUDE** | F1 root at S366 (sandwich-verifier inline-fixed `lai_co_phieu` added to VN_CULTURAL_ANCHORS frozenset with NO provenance log). VN_CULTURAL_ANCHORS is a `frozenset[str]` in `packages/application/news/text_processing/_vn_lexicon.py` (per S365 dev session log L160 evidence). The provenance gap is REAL (D-071 ADR doesn't list which anchors were added when by whom); a PRE/POST commit hook capturing additions with reasoning protects I-S22 data lineage invariant. **Compromise scope**: NOT a full hook this sweep — instead, ADR D-071 amendment to include a `## Anchor Provenance Log` section (append-only), + sandwich-dev.md template note "when modifying VN_CULTURAL_ANCHORS, append provenance row to D-071 § Anchor Provenance Log". Surgical 30-LOC ADR amendment + 3-line template note. | D6 |
| 9 | L-S371-1 | 1st-instance | RETIRE per Karpathy P2 simplicity | **RETIRE** | "Resolver pattern reusable for sector/persona/ticker resolution" — but ONLY VnTickerResolver exists (confirmed by Glob; `packages/application/_shared/resolver.py` does NOT exist; the resolver is at `apps/_shared/entities/vn_ticker_resolver.py`). Factor-out requires 2+ concrete consumers per Karpathy P2 "no abstractions for single-use code". Sector + persona resolvers do NOT yet exist as code — they're future hypothetical Phase G-prime + Phase F-prime extensions. **RETIRE with rationale**: speculative abstraction per Karpathy P2; would create empty Protocol with one implementation; promotion is anti-AP-23 (RED FLAG: "no abstractions for single-use code"). AP-7 revisit trigger: WHEN 2nd resolver concrete implementation lands (e.g. `VnSectorResolver` or `VnPersonaResolver`), THEN architect dispatches a refactor session to factor out common base AT THAT TIME (refactor-to-3, not predict-from-1). | (none — RETIRE) |

**Verdict summary**: 7 INCLUDE (D1+D2+D5+D6+D7 sub-tracks) / 3 RETIRE (L-S385-3 + L-S385-4 + L-S371-1) / 0 DEFER.

**Rationale for 3 RETIRES** (Karpathy P1 explicit pushback):
- L-S385-3 + L-S385-4: rules duplicate existing constitution/master-plan text; no leverage from new artifact
- L-S371-1: speculative abstraction; refactor-to-3 not predict-from-1

**Total promote count: 6** (L-S385-1+L-S385-2 bundled into D7; L-S382-1 = 2 sub-tracks; L-S354-2 + L-S369-1 + L-S366-3 = 1 each). This matches CLAUDE.md § Session Protocol § 9 promote-rule expectation: "schedule a promote-rule subagent dispatch in the next session if blocked" — promote-rule subagent dispatched IMPLICITLY via this plan's IMPL session.

## § D. STEP 0 5-trigger evaluation (per architect dispatch brief)

### STEP 0.1 — CHARTER-TIER GATE

**Trigger condition**: any sub-track requires PROJECT_CHARTER.md or agent-workspace/constitution/** edit.

**Evaluation**: DID NOT FIRE.
- D1 modifies hook + sessions-rollup writer → no charter
- D2 NEW hook + sandwich-dev.md template → no charter (`.claude/agents/**` is allow-listed per `.claude/settings.json:49`)
- D5 modifies existing hook + settings.json wire → no charter
- D6 ADR D-071 amendment in `memory/decisions/` → no constitution
- D7 sandwich-*.md template edits → no charter (per above)
- D8 if INCLUDE (bundled with D2) → no charter

**Verdict**: PROCEED. No AskUserQuestion charter gate needed.

### STEP 0.2 — LICENSE GATE

**Trigger condition**: any sub-track adds new third-party dependency or vendor code with license implications.

**Evaluation**: DID NOT FIRE. All sub-tracks use existing bash + awk + sed (per L-S11-1 portability discipline) OR existing python stdlib. No new dependencies.

**Verdict**: PROCEED.

### STEP 0.3 — LOC-BUDGET GATE

**Trigger condition**: estimated cumulative LOC delta > 1500 (per S341 precedent at 280-330 LOC for 7 sub-tracks; this plan has 6 sub-tracks of comparable scope).

**Evaluation**: per § K budget envelope, estimated 380-520 LOC delta total. Well under 1500.

**Verdict**: PROCEED.

### STEP 0.4 — SPLIT GATE

**Trigger condition**: cumulative IMPL budget estimate > 300K tokens OR estimated wall_min > 60.

**Evaluation**: per § K budget envelope, 150-220K Opus IMPL tokens estimated; wall_min ~30-45 min.

**Verdict**: PROCEED single-session.

### STEP 0.5 — STOP-AND-ASK GATE

**Trigger condition** (per L-S382-1 cluster refinement): ANY regression at downstream test surface OR estimated ctor-signature changes affecting 3+ files OR any architectural choice with multiple defensible options not explicitly disambiguated by the plan.

**Evaluation**:
- D1 (planner-feedback-loop fix): sessions-rollup writer schema is fixed at 14 cols per plan-025; ctor-change risk = LOW (extending an existing writer, not adding new ctor)
- D2 (pre-commit-pytest hook): NEW PreToolUse hook; no ctor changes; pattern precedent = `pre-dispatch-architect-commit-guard.sh`
- D5 (ADR drift detection wiring): existing hook + settings.json wire; no ctor changes
- D6 (D-071 § Anchor Provenance Log amendment): pure ADR doc edit; no ctor changes
- D7 (template edits): pure markdown edits; no code changes
- D8 (if INCLUDE bundled with D2): sandwich-dev.md STEP 0 ctor-grep doctrine = 5-LOC template addition

**Verdict**: PROCEED. No multi-defensible architectural options requiring user signal; all decisions are IMPL-tier within architect's authority.

## § E. Sub-track decomposition

**Order optimized to minimize blast radius**: D1 first (highest infrastructure leverage; planner-feedback-loop is consumed by sandwich-architect Phase 1b — every future architect dispatch benefits). D2 second (HIGH-severity PROMOTE-NOW protects dev commit boundary). D5 third (ADR drift detection — protects ALL future ACCEPTED ADRs). D6 fourth (surgical ADR + template). D7 fifth (template edits bundle). D8 = WITHIN D2 (STEP 0 ctor-grep doctrine paired with PreCommit hook).

**Per Phase 1b architect template** (from `.claude/agents/sandwich-architect.md:110-126`): each sub-track declares parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min.

---

### D1. planner-feedback-loop `.planner-stats.tsv` auto-population (L-S354-2 9TH instance — far past AP-23 threshold)

- **parallel_with**: [D5, D6, D7]    # all independent file scopes
- **blocks_on**: []
- **coordination_paths_exclusive**: [scripts/hooks/planner-feedback-loop.sh, scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh, agent-workspace/memory/.planner-stats.tsv, agent-workspace/memory/self-awareness/sessions-rollup.tsv, scripts/hooks/dispatch-jsonl-recorder.sh OR scripts/hooks/sessions-rollup-writer.sh (whichever writes sessions-rollup.tsv)]
- **estimated_wall_min**: 12

**Anomaly**: #6 in queue. **9TH instance** of the same pattern — `.planner-stats.tsv` remains header-only across 9 successive sweep cycles (S354→S357→S363→S366→S369→S371→S375→S378→S381→S387). FAR past AP-23 2nd-instance promote-or-retire mandate.

**Empirical investigation finding** (architect's VBW pass, S387):
- `scripts/hooks/planner-feedback-loop.sh:38-53` — VERIFY-DONE detection logic: `find "$PLANS_COMPLETED_DIR" -maxdepth 1 -name '*.md' -mmin -5`. This fires only if a plan file's mtime in `completed/` is within the LAST 5 minutes.
- `scripts/hooks/planner-feedback-loop.sh:78-79` — task_class derivation: `sed -E 's/^[0-9]+-S[0-9]+-//' | sed -E 's/-/ /g' | awk '{print $1"-"$2}'`. This derives task_class from plan_id slug.
- `scripts/hooks/planner-feedback-loop.sh:90-100` — sessions-rollup read: `tail -30 "$ROLLUP"` looks for 14-col rows where col9 = plan_id.
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv:1-5` — schema READ — current rows are 8-col legacy format (`session_n session_id ts_utc tokens_real tools_used subagents failure_codes wall_min`). **NO 14-col rows exist** — therefore `planner-feedback-loop.sh:93-100` `while IFS=$'\t' read -r _sn _sid _ts _tok _tools _subag _fcodes _wmin _pid _stc _par _west _wact _psav` fails on every line because `$_pid` (col9) is always empty / out-of-range.
- `agent-workspace/memory/.planner-stats.tsv:1-2` — file exists, contains ONLY the header line. Empirical confirmation of 9TH-instance gap.

**Root cause** (dual):
1. **Trigger gap (timing)**: plan-mv at close-bookkeeping happens BEFORE the Stop event that fires the hook, BUT only if the architect/dev session that completed the plan emits a Stop event AFTER the mv. If main session mv-s the plan AFTER dev session ends, the find `-mmin -5` won't catch it because main's own Stop is after the mv. **Mitigation**: extend find to `-mmin -30` OR add explicit emit at plan-mv time via a NEW companion script.
2. **Schema gap (writer)**: NO existing writer populates the 14-col format. plan-025 DD-7 introduced the schema extension but the writer was never updated. The hook is set up to CONSUME 14-col rows but the producer never emits them. **Mitigation**: identify the writer hook (likely `scripts/hooks/dispatch-jsonl-recorder.sh` OR `scripts/hooks/post-dev-dispatch-attestation-check.sh` OR a NEW hook) and extend it to emit 14-col rows AT minimum for sandwich-dev / sandwich-verifier dispatches (the per-session-type rollup row already exists in 8-col).

**Options considered**:

| Option | Mechanism | Pro | Con | Verdict |
|---|---|---|---|---|
| (a) Fix BOTH trigger + writer | Extend find to -mmin -30; identify writer; extend writer to emit 14-col rows | Closes root cause comprehensively | Bigger scope; touches 2 hooks | **PICK** |
| (b) Fix trigger only | Extend find to -mmin -30; leave writer at 8-col | Trigger works but reads no useful data | Performative; hook continues to silently no-op on the 14-col-data path | REJECT |
| (c) Fix writer only | Identify writer; extend to 14-col; leave find -mmin -5 | Writer emits rich data but hook still misses most plan-completion windows | Performative; data captured but never consumed | REJECT |
| (d) RETIRE planner-feedback-loop entirely | Delete hook + sessions-rollup schema extension; revert plan-025 DD-7 | Simplest | Loses entire architect Phase 1b calibration feature | REJECT (per Karpathy P1 — but DOCUMENT as the alternative for architect's record) |

**Recommendation = Option (a) — fix both**.

**Implementation** (sandwich-dev):
1. Edit `scripts/hooks/planner-feedback-loop.sh:48` change `-mmin -5` → `-mmin -30` (extend trigger window to catch close-bookkeeping mv-s).
2. Identify the sessions-rollup writer:
   - Grep `scripts/hooks/*.sh` for `sessions-rollup.tsv` writes
   - Likely candidates: `scripts/hooks/post-dev-dispatch-attestation-check.sh`, `scripts/hooks/dispatch-jsonl-recorder.sh`, or `scripts/hooks/self-awareness-aggregate.sh` (the existing aggregator)
3. Extend the writer to emit 14-col rows for sandwich-dev + sandwich-verifier dispatches. Extract plan_id from the dispatch prompt OR from companion `.planner-feedback-emitted-<plan_id>` marker. parallel_dispatched count from `dispatch.jsonl` (1 if single Agent call this session; N if parallel Agent calls).
4. Wall-min estimated = parse from plan frontmatter `budget:` field OR from architect observation. Wall-min actual = duration from dispatch.jsonl `duration_ms`.
5. parallel_savings_min = `(sub_track_count × avg_per_track_min) − wall_min_actual` per planner-feedback-loop.sh:6.
6. Smoke-test: dispatch a synthetic sandwich-dev dispatch, mv a fake plan to completed/, run hook, verify row appended to `.planner-stats.tsv`.

**Companion firing-test**: extend existing `scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` with:
- TC: VERIFY-DONE detected at -mmin -30 (was -5)
- TC: 14-col row in sessions-rollup correctly parsed
- TC: legacy 8-col row gracefully skipped (back-compat)
- TC: `.planner-stats.tsv` row appended with correct columns

**Verification at S388 IMPL**: dev confirms `.planner-stats.tsv` contains ≥1 non-header row AFTER mv-ing a synthetic plan to completed/. This is the empirical signal that the 9TH-instance gap is CLOSED.

---

### D2. PreCommit pytest regression guard + sandwich-dev STEP 0 ctor-grep doctrine (L-S382-1 HIGH PROMOTE-NOW + L-S385-1 LOW bundled)

- **parallel_with**: [D1, D5, D6]    # NEW hook file + template edit are disjoint from D1/D5/D6
- **blocks_on**: []
- **coordination_paths_exclusive**: [scripts/hooks/pre-commit-pytest-regression-guard.sh, scripts/hooks/firing-tests/pre-commit-pytest-regression-guard-fire-test.sh, .claude/agents/sandwich-dev.md, .claude/settings.json (PreToolUse section)]
- **estimated_wall_min**: 18

**Anomaly**: #5 in queue. PROMOTE-NOW threshold MET (n=10 L-S345-1 cluster). M-S381-1 (ctor-signature-change not propagated to test_validate_thesis.py) + M-S381-2 (commit-claim mypy/pytest scope mismatch) = same class. S382 verifier explicit recommendation: "(a) PreCommit hook running pytest on changed-file ancestry + BLOCKing on regression; (b) sandwich-dev STEP 0 doctrine 'ctor-signature-change → grep all callers'".

**Empirical investigation finding** (architect's VBW pass, S387):
- `.claude/settings.json:533` PreToolUse section exists with matcher `.*` at line 535-536. Pattern precedent: `pre-dispatch-architect-commit-guard.sh` shipped at S341.
- `.claude/agents/sandwich-dev.md` (Read at S340 precedent observation L65) — current template has no STEP 0 ctor-grep doctrine.
- Plan template § C STOP-AND-ASK trigger currently uses "30+ regressions" threshold per L-S382-1 cluster — too lax; should be "ANY regression at downstream test surface".

**2-part fix** (D2.A hook + D2.B template):

**D2.A — NEW `scripts/hooks/pre-commit-pytest-regression-guard.sh` PreToolUse hook**:

Logic (read from `pre-dispatch-architect-commit-guard.sh` pattern precedent):
1. Read stdin JSON for `tool_name == "Bash"`.
2. Parse `tool_input.command`. If does NOT contain `git commit`, exit 0 (allow).
3. Parse changed-file ancestry: `git diff --name-only --cached` (staged) + `git diff --name-only` (unstaged Python files).
4. For each `.py` changed file, find its corresponding test file(s) by convention (`test_<basename>` siblings + `tests/test_<module>.py`).
5. Run `pytest <test-files> -x --no-header -q` with 60-sec timeout.
6. If pytest EXIT != 0 → STDERR error block citing the failing test + exit RC=2 (block).
7. If timeout → STDERR warning; exit 0 (allow with WARN logged to severity-state.tsv as MEDIUM).
8. Override: `STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1` env bypass (mirrors pattern from `pre-dispatch-architect-commit-guard.sh:14`).
9. Cache: skip if same SHA of changed-file-set was recently green (hour-bucket marker at `agent-workspace/memory/.pre-commit-pytest-green-<sha>.last`).

**Scoping decision** (architect): the hook ONLY runs pytest on directly-related test files (changed file's siblings + tests/test_<module>.py), NOT full project pytest. Full-project pytest at every commit is too slow (~50K cache-read tokens at minimum); changed-file-ancestry is the surgical scope. The verifier (S389) catches full-project regressions via separate gate.

**Wire-up**: insert as a new hook entry in `.claude/settings.json` `"PreToolUse"` section AFTER `pre-dispatch-architect-commit-guard.sh`. One JSON entry; ~7 LOC.

**Companion firing-test**: NEW `scripts/hooks/firing-tests/pre-commit-pytest-regression-guard-fire-test.sh` with ≥7 TCs:
- TC1: Bash + `git commit` + no .py files changed → ALLOW (no pytest run)
- TC2: Bash + `git commit` + .py file with passing test → ALLOW
- TC3: Bash + `git commit` + .py file with failing test → BLOCK (RC=2)
- TC4: Bash + `git commit` + pytest timeout → WARN + ALLOW
- TC5: env STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1 + failing test → ALLOW (bypass)
- TC6: Bash + non-commit (e.g. `git log`) → ALLOW (not commit)
- TC7: cache hit (recent SHA-keyed green marker) → ALLOW (no pytest re-run)

**D2.B — sandwich-dev.md template ctor-grep doctrine + L-S385-1 wc -l exact-at-end discipline**:

Edit `.claude/agents/sandwich-dev.md` to add to STEP 0 section:

```markdown
### STEP 0.11 — Ctor-Signature Grep Discipline (L-S382-2 promoted)

When modifying ANY public ctor (`__init__`, `@dataclass`, factory-method) signature
(adding/removing/renaming param OR changing default), MUST:
1. `grep -rn "<ClassName>(" packages/ apps/ tests/` — list ALL call-sites
2. Update each call-site to match new signature
3. RE-RUN full-project pytest (not sub-package scope) BEFORE commit
4. Cite the grep result + count in your dev observation

Anti-example: M-S381-1 (ValidateThesisPhase1UseCase ctor changed; _make_use_case test
helper not updated; 4 pytest failures + 4 mypy errors slipped to verifier).
```

Edit `.claude/agents/sandwich-dev.md` to add to Phase 5 OBSERVATION FILE section:

```markdown
### STEP 5.4 — LOC self-report exact-at-end (L-S385-1 promoted)

At end of session, BEFORE writing observation file or commit message:
1. Run `wc -l <file>` for each modified/created file
2. Update observation table to use EXACT INTEGERS (NOT "~" prefix)
3. "~" approximation prefix is DEPRECATED at L-S345-1 n=12+ cycle
4. If file edits happened mid-authoring, RE-RUN wc -l final pass before commit

Anti-example: M-S385-1 (3 files >25 LOC off in dev self-report; caused L-S345-1
PASS-WITH-MINOR-DRIFT at n=11; caught by S385 verifier F1 IMPORTANT via independent
wc -l).
```

**Edit `agent-workspace/session-plans/_template.md` (if exists; check first via Glob)**: refine § C STOP-AND-ASK trigger:

```markdown
### STEP 0.5 — STOP-AND-ASK Trigger (L-S382-1 refinement)

Original threshold "30+ regressions" was TOO LAX. Updated:
- ANY regression at downstream test surface (1+ pytest failure) → STOP-AND-ASK
- ANY ctor-signature change touching 3+ files → STOP-AND-ASK (or document grep result inline)
- ANY mypy --strict regression on previously-clean file → STOP-AND-ASK
```

**Verification at S388 IMPL**: dev confirms hook fires on `git commit`-prefixed Bash call with synthetic test-failure scenario; confirms template edits present via grep.

---

### D5. ADR `empirical_close_verify` drift detection wiring (L-S369-1 PROMOTE-NOW n=2 cluster)

- **parallel_with**: [D1, D2, D6]    # disjoint scope (settings.json wire is shared with D2 but different section)
- **blocks_on**: []
- **coordination_paths_exclusive**: [scripts/hooks/adr-empirical-close-verify-spot-check.sh, .claude/settings.json (Stop chain section), scripts/hooks/firing-tests/adr-empirical-close-verify-spot-check-fire-test.sh (verify exists or NEW)]
- **estimated_wall_min**: 9

**Anomaly**: #7 in queue. **PROMOTE-NOW threshold MET** per S369 verifier explicit: "n=2 with L-S363-2; AP-23 PROMOTE-NOW threshold MET — ADR empirical_close_verify drift detection — recommend periodic harness check (`adr-empirical-close-verify-spot-check-fire-test.sh` already exists) re-validates `empirical_close_verify` grep-claims against current code state for ACCEPTED ADRs. PROMOTE-NOW per AP-23."

**Empirical investigation finding** (architect's VBW pass, S387):
- `scripts/hooks/adr-empirical-close-verify-spot-check.sh:1-50` READ — hook ALREADY exists, picks ONE random ACCEPTED ADR per fire (`shuf -n 1 || head -1` at line 43), parses `empirical_close_verify:` YAML list (line 47-54), re-runs grep claims, emits WARN on divergence.
- Hook coverage gap: only 1 of N ADRs sampled per fire — if N=10 ACCEPTED ADRs exist, average coverage per ADR = 1/10 of fires. With ~3 Stops per session × 10 sessions = 30 fires = each ADR sampled ~3 times in 10 sessions. SLOW.
- M-S237-1 + M-S249-1+2 + L-S363-2 + L-S369-1 cluster shows the gap fires often enough to matter.
- Wiring check (architect TODO at IMPL): grep `.claude/settings.json` for `adr-empirical-close-verify-spot-check` — if NOT wired, that's the root cause; if wired but firing infrequently, extend cadence.

**Options considered**:

| Option | Mechanism | Pro | Con | Verdict |
|---|---|---|---|---|
| (a) Wire hook if not already + ensure Stop cadence | settings.json add | Closes wiring gap | Doesn't extend coverage | INCLUDE (first step) |
| (b) Extend to sample N=3 per fire (not 1) | shuf -n 3 | 3x coverage | 3x grep cost; bounded 5s per `:18` timeout wrapper | INCLUDE (second step) |
| (c) Full sweep every 24h | hour-bucket marker | Comprehensive | High cost at marker reset | DEFER (revisit if PROMOTE-NOW recurs) |
| (d) Emit HIGH severity not WARN on divergence | severity-state.tsv HIGH row | Stronger consumer signal | May spam if multiple ADRs drift; mitigated by hour-bucket per-ADR | INCLUDE |

**Recommendation**: (a) wiring check + (b) sample N=3 + (d) HIGH severity on divergence.

**Implementation** (sandwich-dev):
1. Grep `.claude/settings.json` for `adr-empirical-close-verify-spot-check` — if absent, add to Stop chain entry after `severity-classifier.sh` (so divergence rows are captured by classifier same Stop cycle).
2. Edit `adr-empirical-close-verify-spot-check.sh:43` `shuf -n 1` → `shuf -n 3` (3x coverage per fire; still bounded by 5s timeout per `:18`).
3. On divergence detection (existing emit at hook ~line 60+; architect TODO at IMPL: locate exact emit line via Read), write to `agent-workspace/memory/.severity-state.tsv` as HIGH row with adr_id + claim + actual count (severity-classifier consumes this automatically).
4. Verify hook fires + writes severity row via synthetic divergence test (modify a known-divergent ADR's empirical_close_verify line; trigger Stop; confirm HIGH row appears).

**Companion firing-test**: extend existing `scripts/hooks/firing-tests/adr-empirical-close-verify-spot-check-fire-test.sh` (verify exists first via Glob; if not, NEW with ≥4 TCs):
- TC1: ACCEPTED ADR with all empirical_close_verify claims GREEN → no row emitted
- TC2: ACCEPTED ADR with 1 claim DIVERGED → HIGH row emitted with adr_id
- TC3: shuf -n 3 samples 3 ADRs (not 1) per fire
- TC4: no ACCEPTED ADRs in decisions/ → silent skip

**Verification at S388 IMPL**: dev confirms severity-state.tsv contains HIGH row after synthetic divergence injection.

---

### D6. Cultural-anchor frozenset audit-trail (L-S366-3 1st-instance INCLUDE for bundle efficiency)

- **parallel_with**: [D1, D2, D5]    # disjoint scope
- **blocks_on**: []
- **coordination_paths_exclusive**: [agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md, .claude/agents/sandwich-dev.md (Phase 5 section — bundled with D7)]
- **estimated_wall_min**: 5

**Anomaly**: #8 in queue. F1 root at S366 sandwich-verifier inline-fix added `lai_co_phieu` to VN_CULTURAL_ANCHORS frozenset with NO provenance log. Compromise scope: NOT a full hook this sweep (deferred per Karpathy P2); instead ADR D-071 amendment + template note.

**Empirical investigation finding** (architect's VBW pass, S387):
- S366 verifier observation `sandwich-verifier-S366-vn-sentiment-lexicon-verify.md:50` confirms: "lai_co_phieu -0.6 was in lexicon dict but NOT in VN_CULTURAL_ANCHORS frozenset. Fix: added single line at frozenset ASCII-forms section with disambiguation comment. Frozenset now 8 ASCII + 7 unicode = 15 distinct strings."
- D-071 ADR (per Grep: agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md) — architect TODO at IMPL: Read to identify current sections; append `## Anchor Provenance Log` section.
- I-S22 invariant (Data lineage) — any change to VN_CULTURAL_ANCHORS frozenset SHOULD have provenance because consumer (claim extraction wrapper) uses it for I-S22 compliance.

**Implementation** (sandwich-dev):
1. Read `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` END-TO-END.
2. Append new section `## Anchor Provenance Log` with table header:
   ```markdown
   | Anchor | Added (S<N>) | Added by | Rationale | Source corpus |
   |---|---|---|---|---|
   | (initial 8) | S365 | sandwich-dev a8b3a3966a14bd85a | plan-030 D2 forward-design | n=36 corpus (RM7) |
   | lai_co_phieu | S366 | sandwich-verifier inline-fix | F1 root: dict-vs-frozenset mismatch | inherited from initial 8 |
   | đội_lái + 6 other unicode forms | S365 | sandwich-dev | dual-tokenizer coverage | (existing) |
   ```
3. Edit `.claude/agents/sandwich-dev.md` Phase 5 section (bundled with D7) to add:
   ```markdown
   ### STEP 5.5 — VN_CULTURAL_ANCHORS frozenset provenance (L-S366-3 promoted)

   When modifying packages/application/news/text_processing/_vn_lexicon.py
   `VN_CULTURAL_ANCHORS` frozenset, MUST append a row to
   `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` § Anchor
   Provenance Log with: anchor string + session ID + agent ID + rationale +
   source corpus.

   Anti-example: S366 F1 inline-fix added "lai_co_phieu" with no provenance log.
   I-S22 data-lineage invariant requires audit trail for cultural-anchor decisions.
   ```

**Verification at S388 IMPL**: grep `Anchor Provenance Log` `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` ≥ 1; grep `STEP 5.5\|VN_CULTURAL_ANCHORS frozenset provenance` `.claude/agents/sandwich-dev.md` ≥ 1.

**No companion firing-test** (template + ADR edits are meta-doc; not hook-testable).

---

### D7. sandwich-* template hardening bundle (L-S385-1 wc -l + L-S385-2 attestation language + L-S382-1 STEP 0.5 refinement)

- **parallel_with**: [D1, D5, D6]    # template-file edits disjoint from hook scope
- **blocks_on**: []
- **coordination_paths_exclusive**: [.claude/agents/sandwich-dev.md, .claude/agents/sandwich-architect.md, .claude/agents/sandwich-verifier.md, agent-workspace/session-plans/_template.md (if exists)]
- **estimated_wall_min**: 7

**Anomaly bundle**: #1 (L-S385-1 wc -l exact-at-end — bundled INTO sandwich-dev.md Phase 5 STEP 5.4) + #2 (L-S385-2 CODE-DONE-DATA-PENDING — bundled INTO sandwich-architect.md + sandwich-verifier.md attestation language) + #5 (L-S382-1 STEP 0.5 refinement — bundled INTO plan template).

**Note**: D2.B already covers STEP 0.11 ctor-grep + STEP 5.4 wc -l (paired with PreCommit hook); D6 covers STEP 5.5 anchor provenance. THIS sub-track D7 is the **REMAINING** template work:

**D7.A — `.claude/agents/sandwich-architect.md` attestation language (L-S385-2)**:

Edit § Phase 2 Architecture Decisions OR new § "Phase Closure Attestation Vocabulary" sub-section:

```markdown
### Phase Closure Attestation Vocabulary (L-S385-2 promoted)

When authoring plans that span CODE + DATA substrates (e.g. Phase F-prime + future
G-prime), the plan's § Phase F.* DONE attestation surface MUST use one of:

- **DONE**: code + data substrates both ready; full Wave-N gate green
- **CODE-DONE-DATA-PENDING**: code substrate ready; data substrate pending; Wave-N
  gate marked CODE-READY-DATA-PENDING; data-corpus track named as next-step
- **DATA-DONE-CODE-PENDING**: rare; data substrate ready but code not wired
- **PENDING**: neither substrate ready

Flat "DONE" attestation when data is PENDING = anti-pattern (Charter Principle 8
calibration over confidence violation). M-S385-2 evidence: Phase F-prime closed as
CODE-DONE-DATA-PENDING explicitly + Wave 1 MVP gate as CODE-READY-DATA-PENDING.
```

**D7.B — `.claude/agents/sandwich-verifier.md` attestation language**:

Edit § Phase 9 Deliver Report OR new § "Attestation Vocabulary":

```markdown
### Attestation Vocabulary (L-S385-2 promoted)

When verdict involves CODE + DATA substrate distinction, use the same vocabulary
as sandwich-architect:

- PASS-WITH-CONCERNS + CODE-DONE-DATA-PENDING phase attestation: appropriate when
  code substrate verified empirically but data substrate operationally pending
- PASS-WITH-CONCERNS + ⏸ PFP-DONE-7+8 PENDING (named-trigger): explicit honesty
  signal per Charter Principle 6 + Principle 8

Avoid flat "DONE" when downstream data-corpus ingestion is gated on user-authorization
or budget commitment. Name the trigger explicitly.
```

**D7.C — Plan template `agent-workspace/session-plans/_template.md` STEP 0.5 refinement** (verify file exists first via Glob; if NOT exists, skip this sub-sub-track + document):

```markdown
### STEP 0.5 — STOP-AND-ASK Trigger (L-S382-1 refinement)

Original threshold "30+ regressions" was TOO LAX. Updated:
- ANY regression at downstream test surface (1+ pytest failure) → STOP-AND-ASK
- ANY ctor-signature change touching 3+ files → STOP-AND-ASK (or document grep result inline)
- ANY mypy --strict regression on previously-clean file → STOP-AND-ASK
- ANY .planner-stats.tsv schema change → STOP-AND-ASK (architect coordination required)
```

**Note**: If plan template does not exist, document explicitly in S388 dev session log; the rule still applies as architect/dev oral tradition pending template creation in separate session.

**Verification at S388 IMPL**: grep for attestation vocabulary entries in all 3 sandwich-*.md files.

---

## § DD. Design Decisions (DD-1..DD-8)

**DD-1**: D1 fixes BOTH trigger gap AND writer gap (not trigger-only or writer-only). Rationale: any single-side fix is performative (hook fires but no data, or data captured but never consumed); 9TH-instance carry-forward proves single-side fixes don't work. Karpathy P3 surgical applies AT-WITHIN-SCOPE (don't go bigger than 2-hook fix), but does NOT mean "fix only half".

**DD-2**: D2 PreCommit hook scopes pytest to CHANGED-FILE ANCESTRY (not full project). Rationale: full-project pytest is too slow at every commit (~5K cache-read tokens minimum; would gate dev commit speed unacceptably). Changed-file ancestry catches the M-S381-1 class (ctor-signature-change not propagated to related tests). S389 verifier catches full-project regressions via separate gate (S388→S389 dispatch boundary).

**DD-3**: D2 hook fires on Bash `git commit` matcher (NOT on every Bash call). Rationale: per-commit triggering is the minimum-coverage point to catch commit-claim vs empirical-gate divergence; per-tool-call triggering would 10x the cost.

**DD-4**: D2 hook respects `STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1` env bypass + SHA-keyed green cache. Rationale: same-changeset re-commit (e.g. after `git commit --amend`) should not re-run pytest; mirrors `pre-dispatch-architect-commit-guard.sh:14` override pattern.

**DD-5**: D5 wires hook + extends sample N=1 → N=3 (NOT full-sweep every 24h). Rationale: bounded by 5s timeout per `:18`; sample N=3 keeps cost-per-fire low; full-sweep 24h would cause cost spike at marker reset which is a worse failure mode than slow coverage.

**DD-6**: D6 ADR D-071 amendment + sandwich-dev.md template note (NOT a NEW hook). Rationale: cultural-anchor additions are rare (1 instance per ~20 sessions); HOOK enforcement is over-engineering per Karpathy P2. Template + ADR amendment IS the leverage point — next dev modifying VN_CULTURAL_ANCHORS reads sandwich-dev.md template at dispatch time + sees the STEP 5.5 rule. AP-7 revisit trigger: if 2nd instance of missing-provenance fires post-D6, promote to deterministic PreCommit hook checking ADR delta vs frozenset delta.

**DD-7**: 3 RETIRES (L-S385-3 + L-S385-4 + L-S371-1) per Karpathy P1 + P2 + AP-23. Rationale: explicit RETIRE prevents inline accumulation (AP-23 RED FLAG); RETIRE-with-named-trigger preserves AP-7 anti-vacuous-defer discipline; documenting AS RETIRED in agent-notes.md is the artifact (NOT silent skip).

**DD-8**: No D-079 ADR draft unless D2 NEW hook lands (it WILL — high-confidence). If lands, ADR D-079 PROPOSED at IMPL-tier no-cool-down per severity-schema. Schema follows D-062 template + cross-refs D-052 + D-060.

## § F. DoD criteria (32 total — split across PLAN-tier + IMPL-tier + VERIFY-tier)

### PLAN-tier (architect = S387; THIS plan)

**DC-PLAN-1**: This plan file written at `agent-workspace/session-plans/pending/039-S387-harness-stabilization-sweep-N1.md`
**DC-PLAN-2**: Architect observation written at `agent-workspace/memory/observations/sandwich-architect-S387-harness-sweep-N1-plan.md` (~150-250 LOC)
**DC-PLAN-3**: § C verdict table covers all 9 candidates (INCLUDE / DEFER / RETIRE)
**DC-PLAN-4**: § DD design decisions documented (≥7 DDs)
**DC-PLAN-5**: § E sub-track decomposition includes parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per template DD-3
**DC-PLAN-6**: § F DoD ≥25 criteria split across 3 tiers
**DC-PLAN-7**: § L AP-23 attestation table (per-candidate instance count + outcome)
**DC-PLAN-8**: § M close-bookkeeping protocol documented

### IMPL-tier (sandwich-dev = S388)

**DC-IMPL-1 (D1)**: `scripts/hooks/planner-feedback-loop.sh:48` find-mmin extended from -5 → -30
**DC-IMPL-2 (D1)**: sessions-rollup writer identified + extended to emit 14-col rows for sandwich-dev + sandwich-verifier dispatches
**DC-IMPL-3 (D1)**: `.planner-stats.tsv` contains ≥1 non-header row after synthetic plan-mv test
**DC-IMPL-4 (D1)**: companion firing-test `planner-feedback-loop-fire-test.sh` extended with ≥4 TCs (per § D D1); all PASS
**DC-IMPL-5 (D2)**: NEW `scripts/hooks/pre-commit-pytest-regression-guard.sh` exists; shape mirrors `pre-dispatch-architect-commit-guard.sh`; `bash -n` clean; bash-hook-lint clean
**DC-IMPL-6 (D2)**: wired in `.claude/settings.json` PreToolUse section after `pre-dispatch-architect-commit-guard.sh`
**DC-IMPL-7 (D2)**: NEW `scripts/hooks/firing-tests/pre-commit-pytest-regression-guard-fire-test.sh` exists with ≥7 TCs (per § D D2.A); all PASS
**DC-IMPL-8 (D2.B)**: `.claude/agents/sandwich-dev.md` contains STEP 0.11 ctor-grep doctrine (grep "STEP 0.11" returns line)
**DC-IMPL-9 (D2.B)**: `.claude/agents/sandwich-dev.md` contains STEP 5.4 wc -l exact-at-end discipline (grep "STEP 5.4" returns line)
**DC-IMPL-10 (D5)**: `adr-empirical-close-verify-spot-check.sh` wired in `.claude/settings.json` Stop chain (verify via grep; if not wired, add)
**DC-IMPL-11 (D5)**: hook line 43 extended from `shuf -n 1` → `shuf -n 3`
**DC-IMPL-12 (D5)**: divergence detection emits HIGH row to `.severity-state.tsv`; verified via synthetic divergence injection
**DC-IMPL-13 (D5)**: companion firing-test extended with ≥4 TCs (per § D D5); all PASS
**DC-IMPL-14 (D6)**: ADR D-071 contains new `## Anchor Provenance Log` section with ≥3 initial rows
**DC-IMPL-15 (D6)**: `.claude/agents/sandwich-dev.md` STEP 5.5 anchor-provenance discipline added
**DC-IMPL-16 (D7.A)**: `.claude/agents/sandwich-architect.md` contains Phase Closure Attestation Vocabulary section
**DC-IMPL-17 (D7.B)**: `.claude/agents/sandwich-verifier.md` contains Attestation Vocabulary section
**DC-IMPL-18 (D7.C)**: plan template (if exists) STEP 0.5 refinement OR documented as "deferred — template not yet authored"
**DC-IMPL-19 (RETIRE)**: agent-notes.md updated with RETIRE rationale for L-S385-3 + L-S385-4 + L-S371-1 (per AP-23 RETIRE artifact discipline)
**DC-IMPL-20 (bundle aggregate)**: total LOC delta ≤ 600 (Karpathy P3 surgical-changes budget; estimate 380-520)
**DC-IMPL-21 (bundle aggregate)**: bash-hook-lint clean across all modified hooks; `bash -n` clean
**DC-IMPL-22 (bundle aggregate)**: all existing firing-tests still PASS (regression check)
**DC-IMPL-23 (bundle aggregate)**: all existing pytest still PASS (1216 baseline + any new from D2 firing-test)
**DC-IMPL-24 (bundle aggregate)**: 0 charter / 0 constitution writes
**DC-IMPL-25 (bundle aggregate)**: S388 dev observation written at `agent-workspace/memory/observations/sandwich-dev-S388-harness-stabilization-sweep-N1.md` with wc -l EXACT integers per STEP 5.4 doctrine (dogfood the rule)
**DC-IMPL-26 (bundle aggregate)**: S388 dev session log written at `agent-workspace/memory/sessions/2026-05-17-session-388.md` with STEP 0.10 baseline captures verbatim for all modified hooks

### VERIFY-tier (sandwich-verifier = S389)

**DC-VERIFY-1**: Read each modified/created hook end-to-end via VBW
**DC-VERIFY-2**: Run synthetic firing-test for each modified hook; verify PASS independently
**DC-VERIFY-3**: Verify `.planner-stats.tsv` contains ≥1 non-header row (DC-IMPL-3 empirical re-check)
**DC-VERIFY-4**: Verify PreCommit hook fires + blocks on synthetic test-failure (DC-IMPL-5 empirical re-check)
**DC-VERIFY-5**: Verify ADR drift detection emits HIGH severity row on synthetic injection (DC-IMPL-12 empirical re-check)
**DC-VERIFY-6**: Charter compliance grid: 0 charter / 0 constitution edits
**DC-VERIFY-7**: AP-23 attestation grid (§ L) cross-checked against actual sub-track outcomes

## § G. RM risk-mitigation (10 entries)

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| RM1 | D1 sessions-rollup writer identification ambiguous — multiple candidate scripts may write to rollup; dev picks wrong one | MEDIUM | MEDIUM | § D D1 lists 3 candidates with priority order; dev must Read each end-to-end + grep for `sessions-rollup.tsv` write pattern; document choice in dev observation with file:line citation. If still ambiguous after 15 min, STOP-AND-ASK via main session before committing. |
| RM2 | D2 PreCommit hook adds latency to every `git commit` (target: <3s warm) | MEDIUM | LOW | SHA-keyed green cache (DD-4) skips re-run on same changeset; scope is changed-file ancestry NOT full project (DD-2); 60-sec timeout (D2.A step 5) prevents pathological hangs. Measure warm path in DC-IMPL-7 TC2 (passing test scenario). |
| RM3 | D2 PreCommit hook false-positive blocks legitimate commit (e.g. WIP commit with intentional test gap) | MEDIUM | MEDIUM | `STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1` env bypass (DD-4); also: WIP commits often touch files without companion tests (no test file found → no pytest run → ALLOW per D2.A step 4). |
| RM4 | D5 grep claim re-execution false-positive flags ADR as divergent due to code-search syntax differences | LOW | MEDIUM | Existing hook substrate (read at S387) already handles this — `adr-empirical-close-verify-spot-check.sh:48-50` parses YAML list of grep claims as-written; if grep returns 0 hits while ADR claimed >0 (or vice versa), flag. False-positive risk = LOW per existing hook track record (4-of-5 ghost-greening RCA from S249 used this same logic). |
| RM5 | D5 shuf -n 3 sampling timeout exceeds 5s | LOW | LOW | Existing 5s timeout wrapper (`adr-empirical-close-verify-spot-check.sh:18`) bounds the entire hook execution; 3x sample × ~1s/grep = ~3s realistic; well within budget. Firing-test TC measures actual wall time. |
| RM6 | D6 ADR D-071 amendment conflicts with concurrent D-071 edit (e.g. lexicon expansion ADR work) | LOW | LOW | D-071 ACCEPTED (per Glob); no in-flight lexicon work this session. § J coordination paths lock D-071 to D6 scope. |
| RM7 | D7 template edits land on next subagent dispatch (not in-flight S388 dev itself) | LOW | LOW | Template-dispatch read happens AT dispatch time; in-flight edits do NOT change the current dev session's contract. Next dev/architect/verifier dispatch sees updates. AC-7 verifies post-fact. |
| RM8 | RETIRE decisions for L-S385-3 + L-S385-4 + L-S371-1 surface AS regret if 2nd-instance fires soon after | MEDIUM | LOW | AP-7 revisit triggers explicitly named in § C verdict table for each RETIRE; agent-notes.md RETIRE rows include trigger conditions. If 2nd-instance fires within next 5 sessions, promote-rule cycle picks up automatically. |
| RM9 | D1 writer extension breaks back-compat for legacy 8-col rows | LOW | MEDIUM | `planner-feedback-loop.sh:90` already `grep -v '^session_n'` skips header + line 92-100 only consumes rows with NF >= 14 (per existing code). Legacy rows skipped silently. Verify back-compat via TC in DC-IMPL-4. |
| RM10 | D2 hook spawn topology fails on Windows (per L-S246-B firing-test discipline) | MEDIUM | MEDIUM | Pattern reference = `pre-dispatch-architect-commit-guard.sh` which works on Windows. Companion firing-test includes `# SPAWN-CONTEXT: stdin-json (PreToolUse)` marker per L-S247-1 lint discipline (firing-test-spawn-context-lint.sh). DC-IMPL-7 TC1-TC7 exercise both clean + blocked paths. |

## § H. Source-evidence grid (per L-S333-1 hook-sourced-empirical-quote discipline)

| Decision | Source 1 (file:line) | Source 2 (file:line) | Source 3 (file:line) | Source 4 (precedent) | Source 5 (CLAUDE.md / charter) |
|---|---|---|---|---|---|
| § C verdict table | `checkpoints/latest.md:46-53` (9-candidate queue) | `observations/sandwich-verifier-S385-f5-vhm-dogfood-verify.md:148-151` (L-S385-1..4) | `observations/sandwich-verifier-S382-f3-synthesize-perspectives-verify.md:67-70` (L-S382-1 cluster) | `observations/sandwich-verifier-S369-vn-claim-extraction-verify.md:66` (L-S369-1 PROMOTE-NOW) | CLAUDE.md AP-23 ritual-demotion |
| D1 trigger gap root | `scripts/hooks/planner-feedback-loop.sh:48` find -mmin -5 | timing: plan-mv at close-bookkeeping AFTER dev Stop | `.planner-stats.tsv` header-only state (Read at S387) | 9TH-instance carry-forward (S354/.../S381 + S387) | CLAUDE.md harness_priority_one |
| D1 writer gap root | `sessions-rollup.tsv:1-5` 8-col format (Read at S387) | `planner-feedback-loop.sh:92-100` while-read 14-col fails on 8-col rows | plan-025 DD-7 schema extension (un-implemented in writer) | observation `2026-05-16-planner-upgrade-proposal.md:125-141` (writer-spec authored S346 never executed) | Karpathy P3 surgical |
| D2 fix architecture | S382 verifier `observations/sandwich-verifier-S382-f3-synthesize-perspectives-verify.md:67` "(a) PreCommit hook running pytest" | `pre-dispatch-architect-commit-guard.sh` (pattern precedent) | `.claude/settings.json:533` PreToolUse section | M-S381-1 ctor-signature-change root | CLAUDE.md AP-23 PROMOTE-NOW (n=10 L-S345-1 cluster) |
| D2 changed-file ancestry scope | `git diff --name-only --cached` POSIX | architect DD-2 decision | Karpathy P2 simplicity (no full-project gate per commit) | precedent: existing hook chain favors changed-file-narrowing | I-S33 self-aware agent |
| D5 wiring + sample N=3 | `adr-empirical-close-verify-spot-check.sh:43` shuf -n 1 (Read at S387) | hook `:18` 5s timeout | S369 verifier `observations/sandwich-verifier-S369-vn-claim-extraction-verify.md:66` PROMOTE-NOW threshold MET | M-S237-1 + M-S249-1+2 cluster | CLAUDE.md AP-23 |
| D6 ADR amendment + template note | `observations/sandwich-verifier-S366-vn-sentiment-lexicon-verify.md:50` F1 INLINE-RESOLVED | `decisions/071-vn-sentiment-lexicon.md` (architect TODO at IMPL Read) | `_vn_lexicon.py:VN_CULTURAL_ANCHORS` consumer | I-S22 invariant (Data lineage) | Karpathy P2 (no over-engineered hook for 1-instance rule) |
| D7 attestation vocabulary | S385 verifier `observations/sandwich-verifier-S385-f5-vhm-dogfood-verify.md:36-37` CODE-DONE-DATA-PENDING introduced | `current-execution.md:133-159` Phase F-prime CODE-DONE-DATA-PENDING captured | `checkpoints/latest.md:1` S386 CLOSE handoff | M-S385-2 attestation precision lesson | Charter Principle 8 calibration over confidence |
| RETIRE L-S385-3 | Charter Principle 6 (Adversarial by default) explicit text | L-S385-3 = paraphrase of existing charter | AP-23 inline-accumulation RED FLAG | Karpathy P1 explicit pushback discipline | AP-23 RETIRE artifact precedent |
| RETIRE L-S371-1 | apps/_shared/entities/vn_ticker_resolver.py (only resolver in repo) | Glob: `packages/application/_shared/resolver.py` does NOT exist | Karpathy P2 "no abstractions for single-use code" | refactor-to-3 not predict-from-1 doctrine | Karpathy P2 explicit |

## § J. Coordination rule (S388 IMPL)

Main session AVOIDS edits to these paths during S388 dev execution to prevent trampling:

**Hook files (sandwich-dev's primary work):**
- `scripts/hooks/planner-feedback-loop.sh` (D1 primary; main avoids)
- `scripts/hooks/pre-commit-pytest-regression-guard.sh` (D2 NEW; main avoids)
- `scripts/hooks/adr-empirical-close-verify-spot-check.sh` (D5 primary; main avoids)
- `scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh` (D1 extended; main avoids)
- `scripts/hooks/firing-tests/pre-commit-pytest-regression-guard-fire-test.sh` (D2 NEW; main avoids)
- `scripts/hooks/firing-tests/adr-empirical-close-verify-spot-check-fire-test.sh` (D5 extended; main avoids)
- The sessions-rollup writer (D1; whichever hook is identified — likely `scripts/hooks/dispatch-jsonl-recorder.sh` OR `scripts/hooks/self-awareness-aggregate.sh` OR `scripts/hooks/post-dev-dispatch-attestation-check.sh`; main avoids ALL THREE until D1 identifies actual target)

**State files (touched by hooks under modification):**
- `agent-workspace/memory/.planner-stats.tsv` (D1 target)
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (D1 secondary target)
- `agent-workspace/memory/.severity-state.tsv` (D5 secondary; main reads OK during S388)
- `agent-workspace/memory/.pre-commit-pytest-green-*` (D2 NEW marker family)

**Settings + agent template files:**
- `.claude/settings.json` (D2 + D5 hook wiring; main avoids)
- `.claude/agents/sandwich-dev.md` (D2.B + D6 + D7 edit target)
- `.claude/agents/sandwich-architect.md` (D7.A edit target)
- `.claude/agents/sandwich-verifier.md` (D7.B edit target)
- `agent-workspace/session-plans/_template.md` (D7.C edit target if exists)

**Decision files:**
- `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` (D6 amendment target)
- `agent-workspace/memory/decisions/079-pre-commit-pytest-regression-guard.md` (NEW if D2 hook lands; ADR PROPOSED IMPL-tier)
- `agent-workspace/memory/agent-notes.md` (DC-IMPL-19 RETIRE rows append)

**Session logs (S388 dev's authoring scope):**
- `agent-workspace/memory/sessions/2026-05-17-session-388.md`
- `agent-workspace/memory/observations/sandwich-dev-S388-harness-stabilization-sweep-N1.md`

Main session may continue routine work on other paths during S388 IMPL. Main's main risks during S388:
- Do NOT trigger `git commit` from main while D2 hook is in-flight (would race on the PreToolUse hook being added)
- Do NOT modify `.planner-stats.tsv` while D1 writer extension is in-flight
- Do NOT dispatch parallel sandwich-architect/sandwich-dev while S388 dev is running (until D2 hook lands fully wired)

## § K. Budget envelope

| Sub-track | Estimated LOC | Estimated tokens | Risk-of-blowout |
|---|---|---|---|
| D1 (planner-feedback-loop trigger + writer identification + extension + firing-test) | ~100 LOC (50 hook edits + 50 writer extension + 20 firing-test) | ~40K Opus | MEDIUM (writer identification ambiguous per RM1) |
| D2 (NEW PreCommit hook + firing-test + sandwich-dev.md STEP 0.11+5.4 + settings.json wire) | ~150 LOC (80 hook + 50 firing-test + 20 template) | ~50K Opus | LOW (precedent = `pre-dispatch-architect-commit-guard.sh`) |
| D5 (settings.json wire + shuf -n 3 + HIGH severity emit + firing-test extension) | ~50 LOC | ~20K Opus | LOW |
| D6 (D-071 amendment + sandwich-dev.md STEP 5.5) | ~40 LOC | ~10K Opus | LOW |
| D7 (sandwich-architect.md + sandwich-verifier.md + _template.md edits) | ~50 LOC | ~15K Opus | LOW |
| DC-IMPL-19 RETIRE rows in agent-notes.md | ~20 LOC | ~5K Opus | LOW |
| Verification + commit + session log + observation | n/a | ~30K Opus | n/a |
| **Total** | **~410-520 LOC** | **~170-200K Opus** | **fits MULTI_TASK_IMPL Opus 200-330K** |

**Recommendation**: **MULTI_TASK_IMPL Opus, budget 150-220K** (per recalibrated CLAUDE.md Opus column — sandwich-dev shows under-budget actuals on Opus per § Session Types † note "file-bounded work resists token inflation"; S349=98K / S354=34K / S357=45K precedent for dev on Opus). Conservative envelope = 220K; expect actuals ~150K based on precedent.

**S389 verifier budget**: 80-140K Opus VERIFY (per recalibrated CLAUDE.md Opus column 80-180K; this is a 6-sub-track verify with substantial new hook surface to exercise; 7 verify checks DC-VERIFY-1..7).

## § L. AP-23 attestation per candidate

| # | Candidate | Pre-S387 instance count | Post-S388 outcome |
|---|---|---|---|
| 1 | L-S385-1 wc -l exact-at-end | 1st instance (LOW) | **CLOSED via D7 (bundled with sandwich-dev.md STEP 5.4)** |
| 2 | L-S385-2 CODE-DONE-DATA-PENDING attestation | 1st instance (MEDIUM) | **CLOSED via D7 (sandwich-architect.md + sandwich-verifier.md vocabulary)** |
| 3 | L-S385-3 INCOMPLETE-corpus = honesty signal | 1st instance (LOW) | **RETIRED per Karpathy P1 + AP-23** (paraphrase of Charter Principle 6; no new artifact leverage) |
| 4 | L-S385-4 bundled plan-mv parallel-eligible | 1st instance (LOW) | **RETIRED per Karpathy P1 + AP-23** (already informally observed n=1 S386; no new artifact leverage) |
| 5 | L-S382-1 commit-claim vs empirical-gate divergence | n=10 L-S345-1 trigger DIRTY (HIGH PROMOTE-NOW) | **CLOSED via D2 (NEW PreCommit hook + sandwich-dev.md STEP 0.11 ctor-grep)** |
| 6 | L-S354-2 planner-feedback-loop .planner-stats.tsv | 9TH instance — far past 2nd | **CLOSED via D1 (trigger gap + writer gap both fixed)** |
| 7 | L-S369-1 ADR empirical_close_verify drift | n=2 cluster with L-S363-2 (PROMOTE-NOW) | **CLOSED via D5 (wiring + sample N=3 + HIGH severity emit)** |
| 8 | L-S366-3 cultural-anchor frozenset audit-trail | 1st instance | **CLOSED via D6 (ADR D-071 § Anchor Provenance Log + sandwich-dev.md STEP 5.5)** |
| 9 | L-S371-1 resolver pattern reusable | 1st instance | **RETIRED per Karpathy P2 + AP-23** (speculative abstraction; refactor-to-3 not predict-from-1) |

**Net AP-23 outcome**: 6 CLOSED via promotion to hook OR template OR ADR amendment; 3 RETIRED with named AP-7 revisit triggers. 3 PROMOTE-NOW honored (L-S382-1 + L-S354-2 9th-instance + L-S369-1 n=2 cluster). promotion-cycle-trigger.sh HARD-BLOCK at next SessionStart will be AVERTED (queue drained from 9 → 0 active candidates post-S388 commit).

## § M. Plan close-bookkeeping protocol (DC-CLOSE-1..7)

S389 verifier PASS triggers S390 main close-bookkeeping. Required steps:

**DC-CLOSE-1**: Persist S389 verifier observation at `agent-workspace/memory/observations/sandwich-verifier-S389-harness-sweep-N1-verify.md` (verifier-has-no-Write recovery pattern; main writes per S312/S314/S321/S333/S339/S342/S385 precedent)
**DC-CLOSE-2**: mv plan-039 `pending/` → `completed/` via `git mv`
**DC-CLOSE-3**: Prepend S387-S389 row to `current-execution.md` with sub-track-by-sub-track summary + Phase B/D-overlap status + Wave 1 progress update (data-corpus ingestion track UNBLOCKED per `harness_priority_one` discharge)
**DC-CLOSE-4**: Rewrite `checkpoints/latest.md` as S389 CLOSE handoff with 9-candidate-queue DRAINED status + next-turn options
**DC-CLOSE-5**: Update `mistake-log.md` digest with M-S388-* entries (if any) OR explicitly state "no mistakes this session" in session log
**DC-CLOSE-6**: ADR D-079 PROPOSED → ACCEPTED auto-ratification on commit (IMPL-tier; severity-schema no cool-down)
**DC-CLOSE-7**: Manually invoke `promote-rule` subagent if `promotion-cycle-trigger.sh` still shows ≥8 lessons pending (defensive — sweep should have drained the queue but safety check)

## § N. Compliance attestation

| Attestation | Status | Evidence |
|---|---|---|
| harness_priority_one | ✓ | Plan IS the harness work; data-corpus + Phase G-prime explicitly paused per CLAUDE.md rule until this plan lands; promotion-cycle-trigger.sh HARD-BLOCK aversion is binding trigger |
| AP-1 same-agent self-review avoidance | ✓ | Architect = S387 (this); Dev = S388 (fresh-context Opus); Verifier = S389 (fresh-context Opus); all 3 distinct sandwich-* personas |
| dont_self_pause_at_session_boundary | ✓ | Main dispatches S388 immediately after committing this plan; main dispatches S389 verifier immediately after S388 dev returns |
| autonomous_continue_no_self_pause | ✓ | No AskUserQuestion in this plan; no charter/scope question requires user; all decisions IMPL-tier |
| stop_offering_routing_branches | ✓ | Plan does not enumerate (a)/(b)/(c) "next" options for user — autonomous main picks based on this plan + § L AP-23 attestation |
| D-060 commit policy | ✓ | Sandwich-dev commits own S388 work; main commits THIS plan (architect has no Bash) + commits architect-only outputs going forward |
| verify_phase_before_next_phase | ✓ | This plan empirically VERIFIED 6 of 9 candidate root causes via VBW pass (3 RETIRED based on architectural review rather than verified — that's the appropriate response for paraphrase-of-charter + speculative-abstraction) |
| all_14_agents_on_opus | ✓ | S388 dev + S389 verifier both Opus per user directive 2026-05-17; budget cited from CLAUDE.md Opus column per M-S365-1 prevention rule |
| 0 charter | ✓ | PROJECT_CHARTER.md not in any sub-track's file list |
| 0 constitution | ✓ | agent-workspace/constitution/** not in any sub-track's file list; ADR D-079 PROPOSED if D2 NEW hook lands (memory/decisions/, not constitution/) |
| SYNC-GRILLING not fired | ✓ | BEHAVIORAL HOLD § (1) suspends cadence; not recommended in any sub-track |
| Karpathy P1 (Think before coding) | ✓ | Each sub-track has explicit Options-considered table; 3 RETIRE verdicts explicit per architect pushback |
| Karpathy P2 (Simplicity first) | ✓ | L-S371-1 RETIRED explicitly per "no abstractions for single-use code"; L-S385-3 + L-S385-4 RETIRED per "no paraphrase rules" |
| Karpathy P3 (Surgical changes) | ✓ | Every recommendation traces to a named L-S<N>-<M> candidate from § C; total LOC delta capped at ~520 |
| Karpathy P4 (Goal-driven) | ✓ | 32 DoD criteria split across 3 tiers; each empirically falsifiable; 7 verifier checks |
| AP-7 anti-vacuous-defer | ✓ | 3 RETIREs have named revisit triggers in § C verdict table; AP-7 trigger conditions explicit |
| AP-17 identity drift | ✓ | This is harness work for VN stock advisory; not generic framework work |
| AP-23 ritual-demotion | ✓ | 6 promoted (L-S385-1+2+L-S354-2+L-S369-1+L-S366-3+L-S382-1); 3 RETIRED with rationale; per-candidate verdict in § L AP-23 attestation |
| `full_autonomous_no_supervised` | ✓ | No AskUserQuestion; autonomous-full continues |
| L-S345-1 honesty discipline at n=11+ | ✓ | THIS plan itself uses exact integers where citing wc -l (no "~" prefix); dogfoods D7 STEP 5.4 rule pre-promotion |
| L-S382-1 ctor-grep discipline pre-promotion | ✓ | THIS plan adds no new ctors; sub-tracks D2-D7 use only existing classes / pure functions / templates |
| I-S22 data lineage | ✓ | D6 ADR D-071 § Anchor Provenance Log reinforces invariant; D5 ADR drift detection protects ACCEPTED ADR provenance |
| I-S33 self-aware-agent | ✓ | D1 + D2 + D5 all protect harness reliability substrate |

---

End of plan-039. S388 sandwich-dev MULTI_TASK_IMPL begins on dispatch (main commits
this plan first per D-060 + pre-dispatch-architect-commit-guard.sh PreToolUse hook).
