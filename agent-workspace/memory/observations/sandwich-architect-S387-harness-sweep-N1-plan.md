---
observation_id: sandwich-architect-S387-harness-sweep-N1-plan
session: S387
agent: sandwich-architect (background; Claude Opus 4.7)
date: 2026-05-17
budget_used: ~85K Opus (within recalibrated CLAUDE.md Opus column 150-230K PLAN envelope; single-pass authoring)
deliverable: agent-workspace/session-plans/pending/039-S387-harness-stabilization-sweep-N1.md (~720 LOC)
phase: B/D-overlap (HARNESS — non-product; per harness_priority_one + promotion-cycle-trigger HARD-BLOCK aversion)
status: PLAN-AUTHORED-AWAITING-DISPATCH
---

# S387 — Harness Stabilization Sweep N+1 PLAN authoring (observation)

## What I did

1. **VBW reading pass** (~25 files; ~35K tokens):
   - `agent-workspace/memory/current-execution.md` (S383-S386 row + Phase F-prime CODE-DONE-DATA-PENDING + S347 perf quick-wins + S375 Phase F.1 context)
   - `agent-workspace/memory/checkpoints/latest.md` (S386 CLOSE — 9-candidate promotion queue + Next-turn options a/b/c)
   - `agent-workspace/memory/observations/sandwich-verifier-S385-f5-vhm-dogfood-verify.md` (END-TO-END — L-S385-1..4 rationales)
   - `agent-workspace/memory/observations/sandwich-verifier-S382-f3-synthesize-perspectives-verify.md` (END-TO-END — L-S382-1 cluster rationale)
   - `agent-workspace/memory/observations/sandwich-verifier-S369-vn-claim-extraction-verify.md` (L-S369-1 PROMOTE-NOW evidence)
   - `agent-workspace/memory/observations/sandwich-verifier-S366-vn-sentiment-lexicon-verify.md` (L-S366-3 F1 inline-fix root)
   - `agent-workspace/memory/agent-notes.md` (first 200 LOC + grepped for L-S354/L-S369/L-S366/L-S371/L-S345/L-S382)
   - `agent-workspace/memory/mistake-log.md` (digest first 80 LOC + M-S385-1 entry + grepped for L-S382-1 cluster M-S381-1/2)
   - `agent-workspace/constitution/karpathy-principles.md` (P1+P2+P3+P4 + conflict resolution)
   - `agent-workspace/session-plans/completed/021-S340-harness-stabilization-sweep.md` (END-TO-END — plan shape template for Sections A-N)
   - `agent-workspace/memory/observations/sandwich-architect-S340-harness-stabilization-plan.md` (observation format template)
   - `scripts/hooks/planner-feedback-loop.sh` (END-TO-END — D1 primary target investigation)
   - `agent-workspace/memory/.planner-stats.tsv` (D1 evidence — header-only state empirically confirmed)
   - `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (D1 evidence — 8-col legacy format; no 14-col rows ever written)
   - `scripts/hooks/adr-empirical-close-verify-spot-check.sh` (D5 substrate Read; already-shipped; needs wiring + sample N=3 promotion)
   - `scripts/hooks/pre-dispatch-architect-commit-guard.sh` (D2 pattern precedent — PreToolUse hook shape)
   - `apps/_shared/entities/vn_ticker_resolver.py` (L-S371-1 RETIRE rationale evidence — only resolver in repo)
   - `.claude/agents/sandwich-architect.md` (D7 template subject + dispatch-template Phase 1b discipline reference)
   - `.claude/settings.json` partial (PreToolUse section line 533; Stop chain line 230)
   - `agent-workspace/memory/observations/sandwich-architect-S367-phase-e3-extraction-plan.md` (cross-reference for L-S354-2 + L-S366-4 carry-forward)
   - `agent-workspace/memory/observations/2026-05-16-planner-upgrade-proposal.md` (D1 writer-spec original authoring at S346 never executed)
   - `agent-workspace/memory/sessions/2026-05-16-session-354.md` (L-S354-2 first-instance evidence)
   - `agent-workspace/memory/sessions/2026-05-17-session-365.md` (L-S366-3 VN_CULTURAL_ANCHORS modification evidence)
   - `agent-workspace/memory/sessions/2026-05-17-session-371.md` (L-S371-1 VnTickerResolver scope evidence)

2. **Architectural decisions made + adversarial alternates rejected** (per Karpathy P1):

   **D1 dual-root architectural decision**: trigger-only fix OR writer-only fix would be performative per Karpathy P1 (the 9TH instance proves single-side fixes don't work). PICKED BOTH per DD-1. Cost = ~100 LOC delta; benefit = closes 9-instance pattern definitively.

   **D2 PreCommit hook scope decision**: PICKED changed-file-ancestry scope per DD-2 (NOT full-project pytest per commit). Rationale: full-project pytest at every commit is too slow; the M-S381-1 ctor-class is catchable via changed-file scope; S389 verifier catches full-project regressions via separate gate.

   **D5 wiring + sample N=3 decision**: PICKED options (a) + (b) + (d) per DD-5. REJECTED option (c) full-sweep every 24h because cost-spike at marker reset is worse failure mode than slow coverage.

   **D6 ADR amendment + template note (NOT hook)**: PICKED template+ADR per DD-6. Karpathy P2: cultural-anchor additions are rare (~1 per 20 sessions); HOOK enforcement is over-engineering. AP-7 revisit trigger named for 2nd instance promote-to-hook.

   **3 RETIRE decisions (L-S385-3 + L-S385-4 + L-S371-1)**: PICKED RETIRE per DD-7. Karpathy P1 explicit pushback:
   - L-S385-3 paraphrases Charter Principle 6 (Adversarial by default); promoting = inline accumulation per AP-23 RED FLAG
   - L-S385-4 paraphrases master plan § E.4-5; promoting = no new artifact leverage
   - L-S371-1 = speculative abstraction; only ONE resolver exists; refactor-to-3 not predict-from-1 per Karpathy P2 "no abstractions for single-use code"
   All 3 RETIREs documented in agent-notes.md per DC-IMPL-19 + AP-7 revisit triggers named in § C verdict table.

3. **Plan structure followed S340 plan-021 template + dispatch brief sections A-M**:
   - § A session metadata (Opus budget per recalibrated CLAUDE.md column)
   - § B why-this-sweep-NOW (3 binding triggers + 9-candidate queue source-of-truth)
   - § C per-candidate verdict table (Karpathy P1 explicit INCLUDE/DEFER/RETIRE)
   - § D STEP 0 5-trigger evaluation (CHARTER-TIER + LICENSE + LOC-BUDGET + SPLIT + STOP-AND-ASK)
   - § E sub-track decomposition (D1+D2+D5+D6+D7 — 6 INCLUDE / 3 RETIRE)
   - § DD design decisions (DD-1..DD-8)
   - § F DoD criteria (32 split across PLAN+IMPL+VERIFY tiers)
   - § G RM risk-mitigation (10 entries)
   - § H source-evidence grid (10 rows × 5 sources per row = ≥5-cite discipline)
   - § J coordination rule (paths off-limits during S388 IMPL)
   - § K budget envelope (Opus MULTI_TASK_IMPL 150-220K; 410-520 LOC delta)
   - § L AP-23 attestation per-candidate
   - § M close-bookkeeping protocol (DC-CLOSE-1..7)
   - § N compliance attestation (24-row table — all hard rules + memory rules + lessons)

## Decisions I made + why

### Key decision matrix

| Sub-track / Candidate | Decision | Rationale |
|---|---|---|
| L-S385-1 wc -l exact-at-end | INCLUDE in D7 | 5-LOC template edit; bundle-with-template-edits is surgical |
| L-S385-2 CODE-DONE-DATA-PENDING attestation | INCLUDE in D7 | Charter Principle 8 reinforcement; future Phase G-prime/H-prime/I-prime will hit same code-vs-data distinction |
| L-S385-3 INCOMPLETE-corpus framing | **RETIRE** | Paraphrase of Charter Principle 6 (Adversarial by default); promote = inline accumulation per AP-23 |
| L-S385-4 bundled plan-mv | **RETIRE** | Paraphrase of master plan § E.4-5; n=1 evidence S386 already shows rule informally observed |
| L-S382-1 PreCommit pytest + ctor-grep | INCLUDE D2 | PROMOTE-NOW threshold MET (n=10 L-S345-1 cluster); 2-part fix |
| L-S354-2 planner-feedback-loop | INCLUDE D1 | 9TH INSTANCE far past AP-23 2nd-instance; dual-root fix (trigger + writer); highest infrastructure leverage |
| L-S369-1 ADR drift detection | INCLUDE D5 | n=2 cluster with L-S363-2 = PROMOTE-NOW explicit per S369 verifier |
| L-S366-3 cultural-anchor provenance | INCLUDE D6 | ADR amendment + template note (NOT hook per Karpathy P2 — 1-instance rule) |
| L-S371-1 resolver pattern | **RETIRE** | Speculative abstraction; only 1 resolver exists; refactor-to-3 doctrine |
| D2 scope = changed-file ancestry | DD-2 architect decision | Full-project pytest per commit too slow; S389 verifier catches full-project regressions |
| D2 hook fires on `git commit` matcher | DD-3 architect decision | Per-commit triggering is minimum-coverage to catch commit-claim divergence |
| D5 wiring + sample N=3 (NOT 24h sweep) | DD-5 architect decision | Bounded by 5s timeout; sample N=3 keeps cost-per-fire low |
| D6 ADR + template (NOT NEW hook) | DD-6 architect decision | Rare event class; HOOK = over-engineering per Karpathy P2 |
| ADR D-079 OPTIONAL — only if D2 hook lands | DD-8 architect decision | D2 hook WILL land (high-confidence) so D-079 will land too; if D2 deferred, no ADR |

### Alternative I rejected after consideration

1. **Bundle D2 + D5 INTO single PreCommit hook**: rejected. D2 = pytest regression; D5 = ADR claim drift. Different concerns; single-responsibility per existing hook pattern.

2. **Skip L-S366-3 entirely (1st-instance HOLD)**: considered but rejected. F1 was inline-resolved at S366 — the gap exists empirically. Bundling-with-D7 efficiency outweighs AP-23 1st-instance strict HOLD; the cost is 5-LOC template note + 20-LOC ADR section, not a new hook.

3. **Include L-S371-1 with "lightweight Protocol scaffold"**: considered + rejected. Karpathy P2 explicit: "no abstractions for single-use code". Even a Protocol with no implementation is over-engineering when only 1 concrete implementation exists. Refactor-to-3, not predict-from-1.

4. **Make D2 scope full-project pytest**: considered + rejected. Cost-per-commit = ~50K cache-read minimum; would 10x dev commit speed. M-S381-1 is changed-file-class so scope matches root cause.

5. **Make D5 sample ALL ACCEPTED ADRs per fire**: considered + rejected per DD-5. Cost would exceed 5s timeout; full-sweep at marker-reset is worse failure mode than slow coverage.

## Recommended IMPL session size

**Budget**: 150-220K Opus MULTI_TASK_IMPL (per recalibrated CLAUDE.md Opus column).
**Expected actuals**: ~150K based on Sonnet→Opus dev under-budget precedent (S349=98K / S354=34K / S357=45K). Conservative envelope = 220K.

**Verifier (S389) budget**: 80-140K Opus VERIFY (per recalibrated 80-180K Opus column; 6-sub-track verify with substantial NEW hook surface to exercise + 7 DC-VERIFY-1..7 checks).

## Top 3 RMs (per dispatch brief)

1. **RM1 (D1 writer identification ambiguous)** — MEDIUM × MEDIUM. Sessions-rollup writer could be `dispatch-jsonl-recorder.sh` OR `self-awareness-aggregate.sh` OR `post-dev-dispatch-attestation-check.sh`. Dev must Read each end-to-end + grep for `sessions-rollup.tsv` write pattern + document choice with file:line. If still ambiguous after 15 min, STOP-AND-ASK via main.

2. **RM3 (D2 PreCommit hook false-positive blocks legitimate commit)** — MEDIUM × MEDIUM. WIP commits with intentional test gap. Mitigations: STOCKFORGE_SKIP_PRECOMMIT_PYTEST env bypass; WIP commits often touch files without test siblings (no pytest run → ALLOW).

3. **RM10 (D2 hook spawn topology fails on Windows)** — MEDIUM × MEDIUM. Pattern reference `pre-dispatch-architect-commit-guard.sh` proven on Windows; companion firing-test includes `# SPAWN-CONTEXT: stdin-json (PreToolUse)` marker per L-S247-1 lint discipline; TC1-TC7 exercise both clean + blocked paths.

## ADR drafts proposed

**ADR D-079** — `agent-workspace/memory/decisions/079-pre-commit-pytest-regression-guard.md` PROPOSED at IMPL-tier no-cool-down. Conditional on D2 NEW hook landing (high-confidence). Schema follows D-062 template; cross-refs D-052 + D-060 + D-064. Captures: (a) changed-file-ancestry scope rationale; (b) SHA-keyed cache decision; (c) env-bypass pattern; (d) firing-test discipline per L-S247-1. Not drafted in THIS plan-session — dev authors at IMPL-time per architect's DD-8 directive.

**ADR D-071 amendment** — append-only `## Anchor Provenance Log` section to existing ACCEPTED ADR. NOT a new ADR (no version bump per IMPL-tier append-only pattern); just structural extension to existing doc. Dev authors at IMPL-time per D6 sub-track spec.

## Karpathy P1 explicit pushback summary

The dispatch brief listed 9 candidates AS IF all 9 needed action. Karpathy P1 ("Think before coding; push back when warranted; if a candidate should RETIRE rather than promote, say so explicitly with rationale") was applied:

- 6 INCLUDE (genuine leverage from promotion)
- 3 RETIRE (paraphrase-of-existing-rule OR speculative-abstraction)

This is the explicit pushback. The 3 RETIRE artifacts go into agent-notes.md per DC-IMPL-19 (NOT silent skip) so the rule decisions are audited.

## Cost-benefit summary

| Item | Cost (LOC + tokens) | Benefit | Verdict |
|---|---|---|---|
| D1 dual-root planner-feedback fix | 100 LOC / 40K | Closes 9-instance pattern; unlocks architect Phase 1b calibration | HIGH leverage; INCLUDE |
| D2 PreCommit hook + ctor-grep doctrine | 150 LOC / 50K | Protects ALL future dev commit boundaries; closes L-S345-1 n=10 cluster | HIGH leverage; INCLUDE |
| D5 ADR drift wiring + sample N=3 | 50 LOC / 20K | Protects all ACCEPTED ADRs from ghost-greening recurrence | MEDIUM leverage; INCLUDE |
| D6 cultural-anchor provenance | 40 LOC / 10K | Closes 1-instance gap; deferred to template+ADR (no new hook) | LOW leverage; INCLUDE for bundle efficiency |
| D7 template hardening (3 files) | 50 LOC / 15K | Standardizes attestation vocabulary; bundled L-S385-1+2 + L-S382-1 STEP 0.5 | LOW-MEDIUM leverage; INCLUDE |
| RETIRE 3 candidates | 20 LOC agent-notes.md | Prevents inline accumulation per AP-23 RED FLAG | DISCIPLINE leverage; RETIRE-with-rationale |

**Total**: 410 LOC / 135K + verification overhead 30K = ~165K Opus IMPL. Within budget envelope.

## Compliance attestation

- 0 file writes by architect outside plan + this observation
- 0 commits by architect (D-060 + architect-has-no-Bash)
- 0 charter / 0 constitution writes
- AP-1 honored (architect = S387; dev = S388; verifier = S389 — all distinct fresh-context dispatches)
- AP-7 honored (3 RETIREs have named revisit triggers; no vacuous defer)
- AP-23 honored (per-candidate verdict in § L; 6 promoted; 3 RETIRED with rationale)
- Karpathy P1 explicit pushback (3 RETIRE verdicts)
- Karpathy P2 (no speculative abstraction — L-S371-1 RETIRED)
- Karpathy P3 (every change traces to named candidate; LOC delta capped)
- VBW protocol (25 files Read end-to-end OR partial; every claim cites file:line per I-S2)
- harness_priority_one (this plan IS the harness work; product paused)
- promotion-cycle-trigger HARD-BLOCK aversion (queue drained 9 → 0 active post-S388 commit)
- all_14_agents_on_opus (S388 dev + S389 verifier both Opus per user directive; budgets cited from CLAUDE.md Opus column per M-S365-1 prevention)

**END SANDWICH-ARCHITECT OBSERVATION S387**
