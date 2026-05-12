---
plan_id: 011-S251-phase-4-master-plan
phase: 4
status: active
authored: 2026-05-12
authored_session: S251 (master-planner subagent dispatch per AP-1 fresh-context)
authoring_agent: Claude Opus 4.7 (master-planner persona; lean ≤6 pre-reads per L-S43f-2)
supersedes: agent-workspace/session-plans/pending/008-S235-phase-4-master-plan.md (predecessor draft authored 2026-05-10 S235; obsoleted by Phase 3.5 close S250 + D-054 + D-052 cluster + E.3/E.4 + T5/T8 deferred-documentation carryover)
predecessor_phase_plan: agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md (Phase 3; Track I + J + K PAUSED)
verifier_input: agent-workspace/memory/observations/2026-05-12-S250-phase-3.5-close.md (Phase 3.5 close-pick ledger)
binding_specs:
  - specs/tier2-feature/004-multi-perspective-adversarial-agents.md  # BC-8 6-perspective architecture
  - specs/tier2-feature/005-karpathy-outer-loop.md                   # BC-9 outer-loop (Year 2 activation; Phase 4 scaffolding only)
  - specs/tier2-feature/003-crowd-sentiment-pump-detection.md        # BC-7 resume Tracks J+K
  - specs/tier2-feature/002-influence-network-tracking.md            # BC-6 Track I resume
binding_charter:
  - PROJECT_CHARTER.md § Phase 3 / Phase 4 "Month 9 / Month 12" success criteria
  - PROJECT_CHARTER.md § Core Principles 1-10 (charter v1.0; v1.1 Principle 11 carryover from T8)
  - PROJECT_CHARTER.md Principle 11 § cost discipline ($3.00 cap per thesis-run; BR-6; I-40) BINDING
  - agent-workspace/constitution/architecture.md § BC-8 + BC-9 + § LLM Substrate Boundary (D-026)
  - agent-workspace/constitution/invariants.md § I-S1 NO LLM math
  - agent-workspace/constitution/invariants.md § I-S10 substantive bear case ≥3 distinct points
  - agent-workspace/constitution/invariants.md § I-S11 multi-perspective minimum ≥4
  - agent-workspace/constitution/invariants.md § I-S12 preserve disagreement (no consensus-seeking)
  - agent-workspace/constitution/invariants.md § I-S35 research-aid framing
binding_decisions:
  - D-026 LLM Substrate Boundary (per-role override + prose-tolerant JSON + gatherer-wired compute)
  - D-027 BC-6 architecture (mirror for BC-8 substrate-boundary patterns)
  - D-032 BC-7 architecture (Tracks J/K binding for resume)
  - D-050 (CHARTER-tier; L-S227-1 no anthropic API key in production code)
  - D-052 (E.1 deferred; anthropic SDK removal gated on E.4)
  - D-053 / D-054 retry-validator symmetry (bear 3x / quant 2x asymmetric budget — BINDING; template for new perspective adapters)
  - D-055 PROPOSED-via-E.4 (fresh-context verifier mandatory for ARCH+/CHARTER ADRs; ratification ≥2026-05-14T~21Z)
binding_anti_patterns:
  - AP-1 same-agent self-review (fresh-context verifier required at every ARCH+/CHARTER ADR close)
  - AP-7 ghost-greening (E.3 hook adr-empirical-close-verify-spot-check.sh MONITORED)
  - AP-23 firing-test fixture gap (sandwich-dev MUST exercise actual spawn context; firing-test-spawn-context-lint.sh ACTIVE since S248)
sessions_planned: 24 substantive + 4 standing-overhead reserve = 28 budgeted (S251-S278)
envelope_combined_low_high: 2.8M-4.6M (main + subagent; calibrated against Phase 3 actual ~2.6-3.0M + multi-perspective + outer-loop + carryover)
ratifying_decision: pending S252 entry — Phase 4 SCOPE ratified at S251 via AskUserQuestion mega-bundle (Q-P4-1..Q-P4-6 below)
mode: AUTONOMOUS
---

# Phase 4 Master-Plan — Multi-Perspective Adversarial Agents + Thesis-System Maturation + Phase 3 Resume + Charter Housekeeping

## 0. Identity & Scope

**Phase 4 = Multi-perspective adversarial-agent maturation + thesis-system production hardening + Phase 3 PAUSED tracks resume + Phase 3.5 carryover housekeeping.**

This is a SUPERSESSION of `008-S235-phase-4-master-plan.md` (drafted at S235 = 2026-05-10; obsoleted by Phase 3.5 close S250 + Cluster Minimum E + carryover items). The S235 draft framed Phase 4 as "residue-clearing of bull-role hardening + LIVE-wiring + eval-set seeding" — but bull-role hardening was already SHIPPED via D-053 + D-054 (S239-S243 retry-validator symmetry; production validated). Phase 4 now correctly maps to:

1. **Track 0 — Housekeeping carryover** (T5 protocol + T8 charter v1.1 + D-055/E.4 + cluster Minimum E.1 anthropic SDK removal) — gated by cool-down windows
2. **Track A — Resume Phase 3 BC-6 Track I** (Bayesian calibration domain service + outcome scheduler + KOL repository; sub-plan 008-S45 §S49 unblocked)
3. **Track B — Resume Phase 3 BC-7 Tracks J+K** (crowd sentiment + pump detection; sub-plan 009-S51 unblocked)
4. **Track C — Multi-perspective adversarial agents (BC-8)** — spec 004 full ship: 6 perspectives + synthesizer + trade-off matrix + disagreement preservation
5. **Track D — Thesis-system maturation** (eval-set growth ≥100 thesis with outcome data; calibration applied; UC-4 post-mortem synthesis; UC-5 disagreement report)
6. **Track E — BC-9 outer-loop scaffolding** (spec 005 Year 2 activation; Phase 4 ships PROPOSE/EVAL infrastructure, NOT auto-deploy; M-1..M-6 Goodhart mitigations seeded)
7. **Track F — VERIFY + close** (whole-Phase-4 fresh-context sandwich-verifier per AP-1 + D-055)

Phase 4 does NOT ship: FastAPI public endpoints (Phase 5+ SaaS path); Streamlit→Next.js migration; Postgres+TimescaleDB migration; live broker API; outer-loop auto-deploy. These remain Phase 5+ per Charter framing.

The single most important framing rule: **Track 0 (housekeeping) runs IN PARALLEL with Tracks A-E**, gated only by cool-down protocols. Track A/B (Phase 3 resume) is critical-path for Track C/D (BC-8 needs BC-7 sentiment + counter-narrative input + BC-6 KOL calibration data). Track E (outer-loop) is the lowest-risk, lowest-priority deferrable.

---

## 1. Phase 4 Goals + Acceptance Criteria

### SC-1 — Phase 3.5 housekeeping closed (T5 + T8 + D-055)

**Target**: 3 artifacts land in canonical locations.
- `agent-workspace/constitution/harness-health-protocol.md` (T5) — COMPLETE. Mv done S220 D-048; cross-references updated S252 (Q-P4-4 = APPROVE). Constitution file header update pending settings.json deny-lift (see S252 observation).
- `PROJECT_CHARTER.md` v1.0 → v1.1 with Principle 11 (Harness Self-Verify Firing) per `proposals/charter-revision-v1.1-harness-self-verify-firing.md` (cool-down ALREADY ELAPSED 2026-05-09; safe to apply post-S252)
- `agent-workspace/memory/decisions/055-fresh-context-verifier-arch-charter-tier.md` + edit to `agent-workspace/constitution/decision-discipline.md` per `proposals/E4-fresh-context-verifier-arch-charter-tier.md` (cool-down ≥2026-05-14T~21Z)

**Measurement**: `test -f agent-workspace/constitution/harness-health-protocol.md && grep -c "v1.1" PROJECT_CHARTER.md && test -f agent-workspace/memory/decisions/055-*.md` all return non-zero / ≥1.

### SC-2 — Cluster Minimum E.1 anthropic SDK removal SHIPPED + verified

**Target**: 3 production-code edits + 1 verification pass (gated by SC-1 D-055 ratification).
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80` import removed; class re-wired to subprocess CLI path (mirror `claude_cli_news_transport.py` pattern)
- `packages/infrastructure/news/claude_llm_extractor.py:84` import removed; same pattern
- `pyproject.toml:11` `anthropic>=0.40.0` dep removed
- Fresh-context sandwich-verifier dispatch (per D-055 binding once ratified) confirms 0 `import anthropic` hits in `packages/` and `apps/` (excluding `tests/`)

**Measurement**: `grep -rE "^(from anthropic|import anthropic)" packages/ apps/ --exclude-dir=tests` returns 0; `grep "anthropic" pyproject.toml` returns 0; D-052 status flipped from ACCEPTED → REVOKED-AND-REPLACED-BY-D-056 (new canonical ADR re-authoring per E.1) with proper empirical_close_verify block.

### SC-3 — Track I (Phase 3 Bayesian calibration) SHIPPED

**Target**: Per sub-plan `008-S45-track-G-H-I-impl-sub-plan.md` §S49.
- Bayesian calibration domain service (`packages/domain/influence/services/calibration_service.py`) ships with `update_calibration(outcomes, prior)` API
- Outcome scheduler hook (`packages/infrastructure/influence/outcome_scheduler.py`) wired to 1m / 3m / 6m / 12m review windows
- `Kol.transition_to_active()` behavior gated on ≥10 outcomes + Bayesian credibility interval width ≤0.3
- Cumulative BC-6 test count ≥ Phase 3 baseline + ≥15 NEW Track I tests

**Measurement**: `pytest packages/domain/influence/ packages/application/influence/ packages/infrastructure/influence/test_outcome_scheduler.py packages/domain/influence/services/test_calibration_service.py` all PASS; `grep -r "anthropic\|openai\|claude_llm" packages/domain/influence/services/` returns 0 (I-S1 grep gate).

### SC-4 — Track B (Phase 3 BC-7 J+K) SHIPPED

**Target**: Per sub-plan `009-S51-track-J-K-impl-sub-plan.md` § S52 + § S53. ALL acceptance bullets met. ≥50 cumulative BC-7 NEW tests. BR-5 backtest gate PASS (precision >0.5 AND recall >0.3 on holdout). LIVE crowd-sentiment write-path verified per Track B from S235 stale plan (SC-2 there): ≥9 rows in `sentiment_snapshots` (3 platforms × 3 tickers) from real fetch.

**Measurement**: `sqlite3 data/stockforge.sqlite "SELECT COUNT(*) FROM sentiment_snapshots"` ≥ 9; BR-5 backtest CLI exit 0; `pytest packages/domain/crowd/ packages/application/crowd/ packages/infrastructure/crowd/` ≥50 NEW PASS.

### SC-5 — Track C (BC-8 multi-perspective) SHIPPED (the Phase 4 keystone)

**Target**: 6 perspective adapters operational + Synthesizer + Thesis aggregate + UC-1/UC-2/UC-3 end-to-end. Quantitative gates per spec 004 § A.5:
- All 6 PerspectiveRole adapters (BEAR / BULL / QUANT / MACRO / BEHAVIOR / MANAGER) ship with retry-validator symmetry per D-053/D-054 template (bear 3x / quant 2x / others 2x; per-role config)
- Synthesis aggregate enforces I-S10 (bear ≥3 distinct points) + I-S11 (≥4 perspectives) + I-S12 (disagreement preserved, never averaged)
- UC-1 Full Thesis Validation runs end-to-end in <5 minutes
- UC-2 Quick Check (Quant + Behavior only) runs in <30 seconds
- UC-3 Pre-Decision Challenge (Bear + Behavior + Manager) raises serious-flag count
- 5/5 LIVE dogfood tickers (BID, BVH, CTG, FPT, GAS) produce I-S3-compliant thesis across 2 consecutive runs
- Trade-off matrix structured output (no single buy/sell score per BR-4)
- Charter Principle 11 cost cap ≤$3.00 per thesis-run honored (measured via cost-ledger)

**Measurement**: `python -m apps.cli.validate_thesis --ticker <T> --no-mock-llm` for each of 5 tickers across 2 runs (≥30 min apart) emits frontmatter showing 6 perspectives + structured trade_off_matrix + disagreement markers + final_recommendation in {THESIS_CANDIDATE, INVESTIGATE, WATCH, PASS}; mean cost ≤$3.00; max cost ≤$5.00 (worst-case envelope per Charter amendment if needed).

### SC-6 — Track D (thesis-system maturation) SHIPPED

**Target**:
- Eval-set grows from S246 Phase 3 baseline (≥10 historical theses + ≥10 labeled pumps) to ≥30 historical theses (sector diversity: banking + insurance + tech + energy + real estate + retail + industrial + utilities + materials + healthcare) with `calibration_grade ≥ C`
- UC-4 Post-Mortem Synthesis end-to-end: for theses ≥3 months old, all perspectives review which-was-right / which-was-wrong + feedback into calibration JSON
- UC-5 Disagreement Report: for active theses, surface perspective divergence emerging since thesis creation
- Personal bias log gains ≥3 identified biases (per Charter Month 12 success criterion)
- Calibration data threshold: ≥30 theses with 1m+ outcome data flag-tracked (Phase 4 partial against Charter Year 2 target of 100+)

**Measurement**: `find eval-sets/historical-theses -name '*.json' | wc -l` ≥30; `pytest apps/cli/test_post_mortem.py apps/cli/test_disagreement_report.py` PASS; `agent-workspace/calibration/personal-bias-log.md` contains ≥3 BIAS-NNN entries.

### SC-7 — Track E (BC-9 outer-loop scaffolding) SHIPPED

**Target**: Year 2 activation deferred per spec 005 § A.2 + Charter "Phase 5 Compounding". Phase 4 ships PROPOSE / EVAL skeleton only:
- `packages/domain/outer_loop/` aggregate model (EditableAsset + Proposal + EvalResult + Cycle)
- `packages/application/outer_loop/use_cases/propose_change_use_case.py` (UC-1 stub; reads from candidate registry; emits Proposal events)
- `packages/application/outer_loop/use_cases/eval_proposal_use_case.py` (UC-1 stub; runs scalar metric on holdout; emits EvalResult)
- M-1 hold-out test set: `eval-sets/holdout/` directory + manifest; STRICT separation from training data
- M-2 composite metric YAML: `configs/outer-loop-metrics.yaml` (composite = thesis_hit_rate + alert_precision + calibration_accuracy + simplicity_penalty)
- BR-10 minimum-eval-set gate: outer loop refuses to run if eval set < spec 005 § A.2 minimums (100 theses / 500 KOL recs / 20 labeled pumps / 10 narratives)
- NO weekly cron job (deferred to Year 2)
- NO production deploy of proposals (per BR-1)

**Measurement**: skeleton classes exist + unit tests PASS + `configs/outer-loop-metrics.yaml` parseable + minimum-gate test asserts refusal when eval set short.

### SC-8 — Phase 4 cost discipline (Charter Principle 11 BINDING)

**Target**: total Phase 4 imputed LLM cost ≤ Phase 3 actual × 3.0 (~$20-30 envelope). Per-thesis cap ≤$3.00 (Charter I-40). Track C 6-perspective parallel-fanout is the cost-dominant component; D-053/D-054 retry-validator pattern preserves bound.

**Measurement**: `awk -F'\t' '$3 ~ /^S25[1-9]|^S2[6-7][0-9]/ {sum += $5} END {print sum}' agent-workspace/memory/cost-ledger.tsv` ≤30; max single-thesis cost (from `dogfood-summary.md`) ≤$3.00 (Charter binding) OR ≤$5.00 with explicit user-approved amendment.

### SC-9 — Phase 4 close VERIFY produces PASS or PASS-WITH-RESIDUE

**Target**: fresh-context sandwich-verifier dispatch at S277 produces PASS or PASS-WITH-RESIDUE verdict; no FAIL-BLOCK on any SC-1..SC-8. Per D-055 (post-ratification) the verifier MUST be fresh-context distinct session-id from architect / dev sessions.

---

## 2. Track Catalog

| Track | Priority | BC | Scope | Sessions | Dependencies |
|---|---|---|---|---|---|
| **0** — Housekeeping carryover | CRITICAL (gating) | meta | T5 protocol + T8 charter v1.1 + D-055 + E.1 anthropic SDK removal | S252 + S253 + S259-S260 | Cool-down windows; ratifications |
| **A** — Phase 3 BC-6 Track I (Bayesian calibration) resume | HIGH | BC-6 | Per 008-S45 §S49 — Bayesian service + outcome scheduler + KOL provisional→active transition | S254 | S252 housekeeping checkpoint |
| **B** — Phase 3 BC-7 Tracks J+K (crowd sentiment + pump) resume | HIGH | BC-7 | Per 009-S51 §S52+S53 — 3 aggregators + sentiment classifier + coordination detector + narrative/pump classifier + counter-narrative + BR-5 backtest gate + LIVE wiring | S255 (J) + S256-S257 (J split if needed) + S258 (K) | S254 done; or parallel if no shared file conflicts |
| **C** — BC-8 Multi-perspective adversarial agents | CRITICAL | BC-8 | Per spec 004 — 6 perspectives + synthesizer + UC-1/2/3 ship; D-053/D-054 retry-validator template applied | S261 (ARCH) + S262 (probe ladder) + S263-S265 (Dev IMPL 3 sessions) + S266 (VERIFY) | SC-1 done; SC-3+SC-4 done (B+C synergize via BC-7 counter-narrative + BC-6 KOL data) |
| **D** — Thesis-system maturation | MED | BC-5+BC-8 cross-cut | UC-4 post-mortem synth + UC-5 disagreement report + eval-set growth ≥30 + personal bias log ≥3 | S267 + S268 + S269 | SC-5 done |
| **E** — BC-9 outer-loop scaffolding | LOW | BC-9 | Per spec 005 — PROPOSE/EVAL skeleton + M-1..M-6 mitigation seeds + minimum-eval-set gate; NO Year 2 activation | S270 + S271 | SC-6 done |
| **VERIFY + close** | meta | n/a | Mid-phase verify (S272) + Phase 4 close VERIFY (S277) + retrospective + Phase 5 prereq enumeration (S278) | S272 + S277 + S278 | Per-track close gates |

**24 substantive sessions** + **4 standing-overhead reserves** (S273 META_LOOP_RECOVERY, S274 harness-recovery, S275 budget-overflow split, S276 charter-cool-down-window-slip) = **28 budgeted**.

---

## 3. Track 0 — Housekeeping carryover (Phase 3.5 + Cluster Minimum E)

### 0.1 — T5 Harness Health Protocol authoring

**Source**: `agent-workspace/constitution/harness-health-protocol.md` v1.0 — **MV COMPLETE** (S220 D-048; user Q1=A re-confirmed S219; previously at `agent-workspace/proposals/harness-health-protocol.md`).

**Session**: S252 (FOCUSED_IMPL — COMPLETE 2026-05-12).

**Deliverable**: DONE.
- `agent-workspace/constitution/harness-health-protocol.md` confirmed present (git mv at S220; untracked/unstaged in current git index — not yet committed per hard rule no-commit-without-user-approval).
- Cross-references updated S252: project.md, current-execution.md, session-plans/pending/011 binding spec table + Track 0.1 source row.
- Constitution file header update BLOCKED by active `Edit(agent-workspace/constitution/**)` deny in settings.json (deny not lifted for S252 dispatch). Requires settings.json amendment + re-run or user manual edit.

**Acceptance**: PARTIALLY MET.
- `test -f agent-workspace/constitution/harness-health-protocol.md` = PASS ✓
- HH-1..HH-12 verbatim catalog present ✓ (file content unchanged from S173 authoring per D-048)
- Constitution file self-referential header still shows old "PENDING mv" + proposals/ path — RESIDUAL (cosmetic; functional impact zero)

### 0.2 — T8 Charter v1.0 → v1.1 Principle 11 application

**Source**: `agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md` v1.0 (PROPOSED 2026-05-07 S173 per D-034; cool-down 2026-05-07 → 2026-05-09 ELAPSED).

**Session**: S253 (FOCUSED_IMPL ~60-100K main; CHARTER-tier; requires AskUserQuestion ratification gate per Charter Revision Protocol).

**Deliverable**:
- AskUserQuestion `Q-P4-0a-T8` confirming v1.0 → v1.1 application (cool-down elapsed; mechanical edit + version bump remaining)
- Direct edit `PROJECT_CHARTER.md`: bump header version v1.0 → v1.1; insert Principle 11 (Harness Self-Verify Firing) per proposal verbatim
- ADR `agent-workspace/memory/decisions/0XX-charter-v1.1-principle-11.md` canonical
- Update CLAUDE.md Hard Rules table reference to charter v1.1

**Acceptance**: `grep -E "^>.*Immutable v1.1" PROJECT_CHARTER.md` returns 1 + Principle 11 text present + ADR file exists.

**Pre-flight check ladder**:
1. Verify cool-down genuinely elapsed: `git log --format='%ai' agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md` shows timestamp ≤2026-05-09
2. Verify no inline edit drift since proposal authored
3. Fire CHARTER-tier AskUserQuestion (ratify)
4. Apply edit; commit-stage; sandwich-verifier (fresh-context per AP-1) verifies edit faithfulness

**Sandwich pattern**: ARCH at S253 entry (this plan plays architect role for the application; main session = Dev; fresh-context verifier subagent at S253 close per AP-1 + D-055 — see § 3.4 below for D-055 sequencing).

### 0.3 — D-055 E.4 fresh-context verifier charter rule

**Source**: `agent-workspace/proposals/E4-fresh-context-verifier-arch-charter-tier.md` (PROPOSED 2026-05-12 S250; cool-down ≥2026-05-14T~21Z).

**Session**: S259 (FOCUSED_IMPL ~60-100K main; CHARTER-tier; gated on cool-down).

**Deliverable**:
- AskUserQuestion `Q-P4-0a-D055` confirming application post-cool-down
- NEW `agent-workspace/memory/decisions/055-fresh-context-verifier-arch-charter-tier.md` canonical (rule text per proposal § 2; preserve verbatim)
- EDIT `agent-workspace/constitution/decision-discipline.md` § new sub-section "Fresh-Context Close-Verify Required for ARCH+/CHARTER-tier ADRs"
- README update: `agent-workspace/memory/decisions/README.md` row for D-055
- Update `current-execution.md` to mark E.4 charter rule BINDING

**Acceptance**: ADR D-055 ACCEPTED with own fresh-context verifier (per its own rule; meta-self-verification); constitution edit visible via `grep "Fresh-Context Close-Verify" agent-workspace/constitution/decision-discipline.md`; E.3 hook continues firing without regression.

**Pre-flight check ladder**:
1. Confirm cool-down ≥2026-05-14T~21Z elapsed (do not enter session before)
2. Re-read proposal at S259 entry; verify no inline drift
3. Fire CHARTER-tier AskUserQuestion (ratify A=APPLY / B=AMEND-AND-COOL-DOWN-AGAIN / C=WITHDRAW)
4. On A: dispatch fresh-context sandwich-verifier (subagent_type: "sandwich-verifier") to audit the application BEFORE flipping D-055 status to ACCEPTED — this is the very rule being established, applied to itself

**Sandwich pattern**: ARCH at S259 entry → DEV main session → VERIFIER fresh-context subagent at S259 close. Meta-application of the rule itself is the strongest empirical demonstration.

### 0.4 — Cluster Minimum E.1 anthropic SDK removal (DEFERRED from S250)

**Source**: D-052 ghost-greening finding (S249 M-S249-1 HIGH). Charter L-S227-1 (NO ANTHROPIC_API_KEY in production code) functionally unhonored until this ships.

**Session**: S260 (FOCUSED_IMPL ~120-180K main; ARCH-tier ADR re-authoring + production code edits; gated on SC-1 D-055 ratification because E.4 rule binds the verifier dispatch path).

**Affected files** (empirically grounded per S249 audit):
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80` — replace `from anthropic import ...` import with subprocess CLI wrapper (mirror existing `claude_cli_news_transport.py`)
- `packages/infrastructure/news/claude_llm_extractor.py:84` — same pattern
- `pyproject.toml:11` — remove `anthropic>=0.40.0` dep
- (verification) `grep -rE "^(from anthropic|import anthropic)" packages/ apps/ --exclude-dir=tests` returns 0

**Deliverable**:
- 3 production-code edits + 1 dep manifest edit
- D-052 status flip ACCEPTED → REVOKED-AND-REPLACED-BY-D-056
- NEW `agent-workspace/memory/decisions/056-anthropic-sdk-codepath-full-removal.md` canonical with TRUE empirical_close_verify block (per D-055 binding)
- Fresh-context sandwich-verifier dispatch at S260 close (per D-055 — D-056 is ARCH-tier)
- Companion test updates (unit tests for the affected adapters under mocked-subprocess fixtures)
- Cost-ledger entry tracking imputed cost of subprocess CLI conversion validation

**Acceptance**: 0 production-code anthropic imports; pyproject.toml clean; fresh-context verifier signs off; existing tests still PASS (no regression in news / perspective adapter contracts).

**Pre-flight check ladder**:
1. Empirically re-grep the 3 hit sites at S260 entry (file paths may shift if Track A/B/C edited adjacent files)
2. Confirm D-055 status = ACCEPTED before dispatching verifier
3. Run probe: convert ONE adapter first (claude_llm_extractor.py — narrower test surface); verify mocked-subprocess tests pass; THEN apply pattern to claude_llm_perspective_adapter.py
4. Run full pytest suite before status flip on D-052/D-056

**Sandwich pattern**: ARCH within this master-plan (probe → confirm-pattern → re-author ADRs); DEV main session at S260; fresh-context VERIFIER dispatched at S260 close per D-055.

**Risks**: subprocess CLI behavioral parity gap (existing `anthropic` SDK has retry/backoff baked in; CLI subprocess pattern needs equivalent) → mitigation: D-053/D-054 retry-validator pattern provides the template; mirror its retry+timeout config.

---

## 4. Track A — Resume Phase 3 BC-6 Track I (Bayesian Calibration)

### A.1 — Background

PAUSED at S49 since 2026-05-05 awaiting Phase 3.5 close (NOW UNBLOCKED). Sub-plan: `agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md` § S49.

### A.2 — Session

**Session**: S254 (FOCUSED_IMPL ~150-200K main + 50-80K subagent; Dev half of sandwich; per 008-S45 § S49 verbatim).

**Pre-flight reads** (≤5 files; honoring L-S43f-2 lean brief):
1. `specs/tier2-feature/002-influence-network-tracking.md` § A.3 BR-2 (KOL calibration provisional→active) + § B.3 UC-3 (Calibration Service + outcome scheduler) + § B.7 calibration formulas
2. `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` § (e) calibration determinism + § (f) outcome scheduler
3. `agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md` § S49 (binding sub-plan deliverables matrix)
4. `packages/domain/influence/services/` (existing BC-6 domain services from S46/S47/S49a-precursor if any; VBW per L-S30-1)
5. `agent-workspace/constitution/invariants.md` § I-S1 NO LLM math + § I-S20 KOL recommendations tracked to outcome

### A.3 — Deliverables snapshot (per 008-S45 § S49)

- `packages/domain/influence/services/calibration_service.py` (Bayesian update via Beta-Binomial conjugate; deterministic; NO LLM)
- `packages/application/influence/ports/calibration_outcome_scheduler_port.py` (Protocol)
- `packages/infrastructure/influence/outcome_scheduler.py` (1m / 3m / 6m / 12m review windows; emits OutcomeReviewDue events)
- `packages/infrastructure/influence/sqlite_kol_recommendation_repository.py` (kol_recommendations table per spec § B.5)
- `Kol.transition_to_active()` behavior (provisional → active gated on ≥10 outcomes + CI width ≤0.3)
- ≥15 NEW Track I tests

### A.4 — Pre-flight check ladder

1. Pre-flight projection: estimate main token budget; if >230K, split S254a/S254b
2. VBW glob each NEW directory before Write
3. Empirical sanity: existing `packages/domain/influence/` already populated by S46+S47; re-grep to confirm no overlap
4. I-S1 grep gate at session close

### A.5 — Acceptance

- `pytest packages/domain/influence/services/test_calibration_service.py packages/infrastructure/influence/test_outcome_scheduler.py` ≥15 NEW PASS
- I-S1 enforced: `grep -r "anthropic\|openai\|claude_llm" packages/domain/influence/services/` returns 0
- Deterministic roundtrip: pytest runs CalibrationService.update_calibration 2x on identical input → asserts identical posterior (per spec § B.8 bootstrap test analog)
- Companion firing-test for `outcome_scheduler.py` if any Stop-hook side-effect (per L-S176-1 + AP-23 binding)

### A.6 — Sandwich dispatch

Single session FOCUSED_IMPL; verify embedded in Track F mid-phase verifier S272 (covers Tracks A+B+C+D up to that point). Per D-055 (post-ratification SC-1) the close verifier MUST be fresh-context subagent.

### A.7 — Risks

- R-A-1 (MED): SQLite Bayesian roundtrip flake (floating-point ordering) → mitigation: deterministic-roundtrip test fixture + numerical tolerance ≤1e-9; if flake recurs, escalate as L-S<N>-1 promotion candidate
- R-A-2 (LOW): KOL outcome-scheduler cron logic intersecting harness rituals → mitigation: scheduler is internal-Python not bash-hook; no cron file system side-effect at IMPL ship; cron deferred to Phase 5

---

## 5. Track B — Resume Phase 3 BC-7 Tracks J+K (Crowd Sentiment + Pump Detection)

### B.1 — Background

PAUSED since 2026-05-05 awaiting Phase 3.5 close (NOW UNBLOCKED). Sub-plan: `agent-workspace/session-plans/pending/009-S51-track-J-K-impl-sub-plan.md` (active; binding D-032 ratified at S65). Two binding sessions: S52 (Track J) + S53 (Track K) in original numbering — re-mapped to S255-S258 in this master-plan.

### B.2 — Sessions

| Session | Track | Type | Deliverable (high-level) | Budget |
|---|---|---|---|---|
| **S255** | J entry probe | FOCUSED_IMPL | Empirical-probe-first ladder per L-S32-1 + 009-S51 § S52 entry: 3 LLM sentiment strategies (Haiku batch / Sonnet batch / hybrid) × 50-fixture VN forum-post hand-labeled set; ALSO 3 adapter ToS-compliance strategies (A1 robots.txt+UA / A2 Playwright stealth / A3 hybrid). Pick winning strategy by per-label accuracy ≥0.85 + ToS-zero-violations. Probe matrix posted as observation. | 80-120K main + ~$3-6 imputed probe cost |
| **S256** | J Dev (first half) | MULTI_TASK_IMPL | Per 009-S51 § S52 Deliverables 1-15: BC-7 domain (sentiment_snapshot + value objects + raw_post) + application ports + 3 aggregators (F319 + FacebookPublicGroup + ArticleComments) + RateLimitedFetcher base + SentimentClassifier. ≥18 NEW tests. | 150-220K main |
| **S257** | J Dev (second half) | MULTI_TASK_IMPL | Per 009-S51 § S52 Deliverables 16-19: CrowdContentGatherer + CoordinationDetector + SqliteSentimentSnapshotRepository + CLI smoke. ≥12 NEW tests. (Split from S256 mandated if S256 pre-flight projects >230K — 009-S51 explicitly authorizes S52a / S52b split.) | 150-220K main |
| **S258** | K Dev | MULTI_TASK_IMPL | Per 009-S51 § S53 verbatim: NarrativePhaseClassifier + PumpPhaseClassifier + Counter-Narrative + HistoricalAnalogFinder + PumpEvidenceSummarizer + Narrative/PumpDetection/CounterNarrative/LabeledPump aggregates + ~25 files + ≥20 NEW tests + BR-5 backtest gate CLI. | 150-220K main + 100-150K subagent |
| **(merged)** | LIVE wiring | embedded in S256 | Track B from stale 008-S235 plan (LIVE crowd_sentiment write-path): the `_LiveClassifier` / `_LiveCoordinationDetector` / `_LiveSnapshotRepo` wirings replacing `apps/cli/ingest_crowd_sentiment.py:162-168` early-exit branch ship AS PART OF S256. SC-2 from stale plan absorbed into SC-4 here. | (no extra budget) |

### B.3 — Pre-flight check ladder (S255 entry)

Per 009-S51 § S52 (verbatim per spec L-S32-1):
1. Empirical-probe-first for sentiment classifier: 3 strategies × 50-fixture; require ≥85% per-label accuracy. If all <85% → SCOPE Q&A escalate per D-032 § Rollback path
2. Empirical-probe-first for adapter ToS-compliance: 3 strategies × public-only enforcement; require 0 ToS-violations + ≥95% legitimate-fetch rate
3. Crawler-reliability skill invoked at S256 entry (per `.claude/skills/crawler-reliability/SKILL.md`)
4. BR-1 public-only enforcement per aggregator (test fixture + `ToSBoundaryViolation` raise)
5. VBW pre-flight per L-S30-1: `Glob` each NEW directory before Write

### B.4 — Acceptance

Per 009-S51 acceptance § Cross-Cutting Acceptance (S52+S53 cumulative; verbatim):
- ≥50 NEW BC-7 tests cumulative
- mypy --strict + ruff 0 errors on BC-7 surface
- I-S1 NO-LLM-MATH: `grep -r "anthropic\|openai\|claude_llm" packages/domain/crowd/services/` returns 0
- BR-4 categorical-only enforced at LlmSentimentClassifier
- **BR-5 BACKTEST GATE PASS**: `python -m apps.cli.backtest_pump_classifier --holdout-split=0.3` exits 0 with precision >0.5 AND recall >0.3
- BR-6 mandatory counter-narrative trigger at bullish_ratio>0.8
- BR-8 conservative coordination threshold ≥0.8
- BR-10 NO public accusations (payload schema + regex gate)
- D-026 LLM Substrate Boundary cited verbatim in 3 file docstrings (sentiment_classifier + counter_narrative_generator + pump_evidence_summarizer)
- LIVE crowd_sentiment ≥9 rows in `sentiment_snapshots` from real fetch (absorbed from S235 SC-2)

### B.5 — Sandwich dispatch

- S255 ARCH-style probe (architect not required; this master-plan covers; probe runs as observation file)
- S256/S257/S258 Dev = main session
- VERIFY consolidated at S272 mid-phase (covers Tracks A+B) + final S277 (full-Phase) per D-055 fresh-context

### B.6 — Risks

Per 009-S51 § Risks merged + cross-ref master-plan 007 R-P3-*:
- R-B-1 (HIGH) — R-P3-1 Vietnamese sentiment classifier accuracy <0.85 (all 3 strategies fail): rollback per D-032 § Rollback path; defer Track J to S273 META_LOOP_RECOVERY reserve
- R-B-2 (HIGH) — R-P3-2 FB Graph API ToS shift mid-Phase-4: fb_group_aggregator falls back to manual link-list mode (mirror BC-6 telegram_adapter S64 pattern); `ToSBoundaryViolation` raised
- R-B-3 (HIGH) — BR-5 hold-out gate fails (precision ≤0.5 OR recall ≤0.3): SCOPE Q&A escalate; pump live-deploy deferred to S273; counter-narrative + sentiment paths still ship (decoupled)
- R-B-4 (MED) — BR-10 PII leakage in CoordinationDetector or pump_evidence_summarizer: regex gate at output + explicit pytest BR-10 test (constitutionally forbidden per spec § A.3 + § B.4)
- R-B-5 (MED) — CafeF/Vietstock HTML fragility: vendor-api-probe.sh weekly check + manual fallback at adapter docstring
- R-B-6 (MED) — LabeledPump dataset insufficient for BR-5 gate (<5 historical pumps): agent-with-review drafts from spec § B.7 historical examples; IF still <5 by S258 entry, escalate to user for 1-2 additional cycle entries

---

## 6. Track C — BC-8 Multi-Perspective Adversarial Agents (Phase 4 KEYSTONE)

### C.1 — Background

Phase 4's primary new-scope deliverable per Charter § Phase 3 → Phase 4 "Month 9 / Month 12 success criteria". Binding spec: `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` (BC-8). The existing thesis-pipeline (BC-5; built Phase 2 Track F) already wires Bear + Bull + Quant in 3-perspective mode. Phase 4 adds: Macro + Behavior + Manager perspectives + structured Synthesis aggregate + UC-1/2/3/4/5 use cases + 6-perspective parallel-fanout + disagreement preservation contract.

### C.2 — Sessions

| Session | Type | Track | Deliverable | Budget |
|---|---|---|---|---|
| **S261** | PLAN | C (architect) | Sandwich-architect subagent dispatch (fresh-context per AP-1 + D-055); produces D-057-BC-8-multi-perspective-architecture ADR (ARCH-tier) + companion sub-plan `012-S261-BC-8-multi-perspective-impl-sub-plan.md`. Decisions: (a) Synthesis storage (SQLite or new aggregate vs reuse thesis_log?); (b) Perspective adapter pattern (extend D-053/D-054 retry-validator template per role); (c) Macro/Behavior/Manager LLM substrate (D-026 verbatim citation); (d) Disagreement-preservation contract (TradeOffMatrix + DimensionAssessment serialization); (e) Cost discipline mapping (6-perspective parallel-fanout × ≤$3/thesis envelope); (f) UC-2 Quick Check path (2-perspective subset); (g) UC-3 Pre-Decision Challenge path (3-perspective subset); (h) Counter-narrative integration with BC-7 (BR-10 + bullish_ratio>0.8 gate). | 50-80K (subagent) |
| **S262** | THESIS / probe | C (empirical) | Per L-S32-1 — probe ≥3 strategies for Macro / Behavior / Manager LLM perspective adapters: (1) Sonnet-shared-prompt vs Sonnet-role-specific-prompt vs Haiku-prefilter+Sonnet-extract hybrid; (2) per-role retry budget tuning (mirror D-054 bear 3x / quant 2x — Macro/Behavior/Manager candidate budgets 2x/2x/3x); (3) full-fanout cost calibration on 5-ticker × 2-run × 6-perspective grid. Observation file `track-C-S262-perspective-probe.md` records matrix. | 80-120K main + ~$5-10 imputed probe |
| **S263** | FOCUSED_IMPL | C (Dev — Macro+Behavior) | Per S261 sub-plan: Macro perspective adapter + Behavior perspective adapter + per-role config + retry-validator mirror per D-054 template + tests (15+ NEW). | 100-150K main |
| **S264** | FOCUSED_IMPL | C (Dev — Manager + Synthesis core) | Manager perspective adapter + Synthesis aggregate + TradeOffMatrix + DimensionAssessment + Disagreement aggregate + counter-narrative integration with BC-7 + tests (15+ NEW). | 100-150K main |
| **S265** | MULTI_TASK_IMPL | C (Dev — UC ship + dogfood) | UC-1 Full Thesis Validation end-to-end (6-perspective + synthesizer); UC-2 Quick Check (Quant + Behavior); UC-3 Pre-Decision Challenge (Bear + Behavior + Manager); LIVE 5-ticker × 2-run anti-flake gate (BID/BVH/CTG/FPT/GAS). Tests + dogfood observation file. | 150-220K main + ~$15-30 imputed dogfood |
| **S266** | VERIFY | C (fresh-context) | Sandwich-verifier subagent dispatch (per D-055 ARCH+ binding — D-057 is ARCH-tier; mandatory fresh-context distinct from S261 architect + S263/S264/S265 dev). Adversarial review of 6-perspective output: I-S10 + I-S11 + I-S12 enforcement; cost-cap honor; SC-5 5/5 × 2-run gate; AP-1 + AP-7 + AP-23 prevention check. | 100-150K subagent |

### C.3 — Pre-flight check ladders

**S261 (Architect) pre-flight**:
1. Read spec 004 verbatim (full A + B + C parts)
2. VBW glob `packages/domain/analysis/` + `packages/infrastructure/analysis/perspectives/` (existing Phase 2 Track F structure)
3. Read D-026 LLM Substrate Boundary + D-053/D-054 retry-validator template
4. Confirm AP-1 binding: subagent dispatched MUST be fresh-context (Agent tool with subagent_type: "sandwich-architect")
5. Lean brief ≤6 pre-reads enforced for the dispatch

**S262 (Probe) pre-flight**:
1. Per L-S32-1: 3 strategies × 5-ticker × at-least-2-runs probe matrix
2. Empirical-probe-first skill invoked at session entry
3. Charter Principle 11 cost-cap monitoring: per-thesis ≤$3 measured during probe; if any strategy projects >$3/thesis at scale, eliminate
4. Per-role retry budget candidates: mirror D-054 asymmetric (bear 3x for I-S10 hard-floor; quant 2x for cost; macro/behavior/manager candidates 2x baseline 3x if I-S<X> hard-floor surfaces)

**S263-S265 (Dev) pre-flight**:
1. VBW glob each NEW perspective adapter directory
2. Confirm S262 probe winning strategy ratified in observation
3. Reuse `subagent_transport.py:56-64` per-role timeout overrides pattern
4. Empirical-probe-first: do NOT armchair-pick retry budgets; cite probe matrix
5. Companion firing-test for each NEW hook if any (e.g., if Macro perspective triggers a new ingestion-side hook)

**S266 (Verifier) pre-flight**:
1. Fresh-context subagent dispatch (distinct session-id from S261/S263/S264/S265)
2. Re-run all `empirical_close_verify` blocks in D-057 + any companion ADRs ratified during Track C
3. Run E.3 hook spot-check before signing off
4. Adversarial: search for AP-1 / AP-7 / AP-23 / I-S1 / I-S10 / I-S11 / I-S12 violations

### C.4 — Deterministic vs LLM split (per `decompose-work` skill doctrine)

| Component | Determinism mode | Rationale |
|---|---|---|
| Synthesis aggregate construction (Trade-off matrix population) | Deterministic Python | Numbers from code per I-S1; LLM only emits structured output, not computed scores |
| Bear / Bull / Quant / Macro / Behavior / Manager LLM adapters | LLM-perspective | Each perspective is text reasoning + grounded points; D-026 substrate-boundary patterns mandatory |
| Disagreement detection (perspective divergence) | Deterministic Python | Compares structured outputs; numeric disagreement scores computed from code |
| Confidence calibration (ConfidenceLevel) | Deterministic Python | Historical hit rate from calibration store; I-S7 + I-S8 binding |
| Trade-off matrix Dimension scoring | LLM categorical + deterministic ordinal mapping | LLM emits enum-valued DimensionAssessment per dimension; deterministic Python aggregates and ranks |
| Personal bias mirror | Deterministic Python | Reads `agent-workspace/calibration/personal-bias-log.md`; surfaces user-specific bias flags |
| Counter-narrative trigger (BR-6 BC-7) | Deterministic Python gate + LLM bear-points (already shipped in Track B) | bullish_ratio>0.8 deterministic; counter-narrative text from BC-7 LLM (already grounded) |
| Final Recommendation enum | Deterministic Python rule | THESIS_CANDIDATE / INVESTIGATE / WATCH / PASS computed from synthesis state; LLM never picks enum directly |
| Reasoning trace | LLM text | Explanatory narrative; reading aid only |

### C.5 — Charter Principle 11 cost-discipline calculation

Per spec 004 + D-054 cost discipline:
- Per-thesis 6-perspective parallel-fanout: ~$1.50 baseline (3-perspective from Phase 2) + 3 NEW perspectives × ~$0.50 each (Macro/Behavior/Manager Sonnet shared-prompt) = ~$3.00 expected
- Retry-validator overhead: bear 3x worst case = +$0.30; quant 2x worst case = +$0.15; macro/behavior/manager 2x worst case = +$0.30 collectively
- WORST-CASE per-thesis: ~$3.75 (above $3 Charter cap — needs Q-P4-1 user-pick on amendment OR Sonnet→Haiku-hybrid fallback)
- MEAN expected per-thesis: ~$2.80 (within cap)
- Anti-flake gate (2 consecutive runs): 5 tickers × 2 runs × $2.80 = $28 dogfood envelope per gate cycle

**Cost mitigation**:
- Q-P4-1 user-pick: A=accept temporary cap raise to $5/thesis Phase 4 only (B-amendment) OR B=Haiku-hybrid for Macro/Behavior/Manager (cuts ~$0.40 but risk per-label accuracy <0.85) OR C=defer Manager perspective to Phase 5 (5-perspective only Phase 4) OR D=tighter retry budget caps (max 2x all-role)

### C.6 — Acceptance

Per spec 004 § A.5 Month 9 success criteria + SC-5 here:
- All 6 perspective agents operational
- Full Thesis Validation runs end-to-end in <5 minutes (per spec); measure via `time python -m apps.cli.validate_thesis --ticker BID --no-mock-llm`
- 5/5 LIVE dogfood tickers × 2 consecutive runs (≥30 min apart) → I-S3-compliant + I-S10 + I-S11 + I-S12 enforced
- Trade-off matrix structured output (BR-4 + I-S52)
- Charter Principle 11 cost-cap honored per Q-P4-1 disposition
- Disagreement cases explicit in output (≥20% of thesis show substantive disagreement per spec § A.5 Month 9 target)
- mypy --strict + ruff CLEAN
- I-S1 grep gate: 0 LLM imports in `packages/domain/analysis/` (LLM only in `packages/infrastructure/analysis/perspectives/`)

### C.7 — Sandwich dispatch (mandatory fresh-context per AP-1 + D-055)

- **ARCH (S261)**: sandwich-architect subagent (Agent tool); produces D-057 + sub-plan 012
- **DEV (S263/S264/S265)**: main session
- **VERIFY (S266)**: sandwich-verifier subagent (Agent tool); fresh-context; AP-1 + D-055 BINDING because D-057 is ARCH-tier

### C.8 — Risks

- R-C-1 (HIGH) — Per-thesis cost breach $3.00 Charter cap: Q-P4-1 SCOPE-tier escalation pre-staged
- R-C-2 (HIGH) — UC-1 end-to-end latency >5 min (per spec § A.5): parallel-fanout via asyncio.gather (D-054 pattern); if still slow, profile and identify bottleneck; if Manager perspective dominates, evaluate caching or Haiku fallback
- R-C-3 (MED) — I-S10 substantive bear case fails 5/5 gate (regression from D-054 baseline): D-054 retry-validator template MUST be applied identically; pytest contract; mid-phase verifier S272 catches early
- R-C-4 (MED) — Disagreement preservation contract leaks (I-S12 violation): Synthesis aggregate `__post_init__` invariant checks; pytest BR-1 test asserts perspective outputs not consensus-averaged
- R-C-5 (MED) — D-026 substrate-boundary violation in NEW perspective adapters: regex gate at output (no numeric strings); grep gate at adapter docstrings cite D-026 verbatim
- R-C-6 (LOW) — BR-9 user bias mirror missing entries: ship with empty bias log; first 5 dogfood theses fill it; gate is soft

---

## 7. Track D — Thesis-System Maturation

### D.1 — Background

Charter Month 12 success criteria require: 50+ thesis with 3-month outcome data + post-mortem comparing perspective accuracy + personal bias log ≥3 identified biases. Phase 4 ships the infrastructure + partial growth toward these targets.

### D.2 — Sessions

| Session | Type | Deliverable | Budget |
|---|---|---|---|
| **S267** | FOCUSED_IMPL | UC-4 Post-Mortem Synthesis use case (`packages/application/analysis/use_cases/post_mortem_synthesis_use_case.py`) + ThesisStatus.REVIEWED transition + per-perspective accuracy comparison logic (deterministic) + LLM-perspective post-mortem narrative (D-026 patterns) + tests | 100-150K main |
| **S268** | FOCUSED_IMPL | UC-5 Disagreement Report use case + CLI `apps/cli/disagreement_report.py` + per-active-thesis perspective re-run (lazy; only when triggered) + cross-thesis disagreement aggregation + tests | 100-150K main |
| **S269** | INGEST | Eval-set growth: 5 dogfood re-runs from SC-5 (BID/BVH/CTG/FPT/GAS) with `real_thesis: true` flag (rule from S235 stale plan) + 15 NEW sector-diversity tickers (5 each from real estate/retail/industrial; 3 utilities; 2 materials/healthcare). Manual personal bias log ≥3 entries seeded from S232 dogfood + S252-S268 observations. | 150-220K main + ~$45-90 imputed (20 theses × ~$2.80) |

### D.3 — Pre-flight check ladders

- S267: spec 004 § A.3 UC-4 + spec 005 § A.6 BR-3 multi-metric composite (post-mortem feeds calibration). Confirm BC-8 Track C SHIPPED before S267 entry.
- S268: spec 004 § A.3 UC-5 + UC-1 thesis aggregate contract (active-thesis perspective re-run = lighter Quick Check path). Re-use UC-2 wiring.
- S269: ticker selection via Q-P4-3 SCOPE-tier (auto-pick by sector vs user-pick). Cost budget enforced per Charter Principle 11 (monitored via cost-ledger).

### D.4 — Acceptance

- UC-4 and UC-5 end-to-end PASS with mocked theses + real dogfood theses
- `find eval-sets/historical-theses -name '*.json' | wc -l` ≥30 (5 dogfood re-runs + 15 new + 10 pre-existing from Phase 4 dogfood cycles)
- `agent-workspace/calibration/personal-bias-log.md` has ≥3 BIAS-NNN entries
- 0 LLM math in post-mortem use case (deterministic accuracy scoring)
- Cost-ledger entries documented per Charter Principle 11

### D.5 — Sandwich dispatch

Single main-session sequence; verify embedded in final S277 close (per D-055 fresh-context).

### D.6 — Risks

- R-D-1 (MED) — User does not author personal bias log entries (BR-9 effectively no-op): mitigation: agent surfaces inferred biases from dogfood observation files; user reviews 5-10 candidates; semi-automated
- R-D-2 (LOW) — UC-4 post-mortem latency on 30-thesis batch: process async; cache; deferred to outer-loop M-5 human-review acceptance

---

## 8. Track E — BC-9 Outer-Loop Scaffolding

### E.1 — Background

Spec 005 § A.2 explicitly defers Year 2 activation. Phase 4 ships SKELETON only: aggregate model + PROPOSE/EVAL use cases + holdout manifest + composite-metric YAML + minimum-eval-set gate. NO weekly cron, NO production deploy of proposals, NO Year 1 activation.

### E.2 — Sessions

| Session | Type | Deliverable | Budget |
|---|---|---|---|
| **S270** | PLAN+IMPL (rare exception per spec 005 small scope) | Architect within this master-plan covers; main session IMPL. `packages/domain/outer_loop/` aggregates: EditableAsset + Proposal + EvalResult + Cycle + simplicity penalty rule. `packages/application/outer_loop/use_cases/propose_change_use_case.py` (UC-1 skeleton). Composite-metric YAML at `configs/outer-loop-metrics.yaml`. Holdout manifest `eval-sets/holdout/manifest.yaml`. M-1 strict separation invariant + BR-10 minimum-eval-set refusal gate. ≥10 NEW tests. | 100-150K main |
| **S271** | FOCUSED_IMPL | `packages/application/outer_loop/use_cases/eval_proposal_use_case.py` (UC-1 skeleton; runs scalar metric on holdout; emits EvalResult event). M-2 multi-metric composite computation. M-3 simplicity ratchet. M-4 walk-forward validation (3 non-overlapping windows; mock impl). Smoke: propose 1 fake change → eval → reject (deterministic; no LLM in eval path per BR-1). ≥10 NEW tests. | 100-150K main |

### E.3 — Deterministic vs LLM split

**100% Deterministic** for Phase 4 scaffolding. Outer loop logic is pure Python (scalar metric computation, walk-forward window iteration, simplicity penalty arithmetic). LLM involvement is OUT-OF-SCOPE Phase 4 (deferred to Year 2 per BR-1 + BR-9).

### E.4 — Acceptance

- Skeleton classes + ≥20 NEW tests PASS
- `configs/outer-loop-metrics.yaml` parseable; composite formula `thesis_hit_rate + alert_precision + calibration_accuracy + simplicity_penalty` declared
- Minimum-eval-set gate: test asserts `propose_change_use_case` raises `MinimumEvalSetNotReached` when eval set < spec 005 § A.2 minimums (100 theses / 500 KOL recs / 20 labeled pumps / 10 narratives)
- I-S1 grep gate: 0 LLM imports in `packages/domain/outer_loop/` and `packages/application/outer_loop/use_cases/`
- M-1 holdout separation: test asserts `propose_change_use_case` cannot read from `eval-sets/holdout/` directly

### E.5 — Sandwich dispatch

Tracked within final close S277 (per D-055 fresh-context); no per-track verifier (low-risk scaffolding).

### E.6 — Risks

- R-E-1 (LOW) — Outer-loop skeleton over-engineering speculation: AP-23 cheapest-by-RISK applied; ship ONLY documented spec 005 § B aggregates + UC-1 entry/exit hooks; no Year 2 anticipation
- R-E-2 (LOW) — Composite metric YAML schema drift if spec 005 amended: pin schema version; future amendment goes through Year 2 activation gate (separate session)

---

## 9. Track F — VERIFY + Close

### F.1 — Mid-phase verifier (S272)

**Session**: S272 (VERIFY 60-90K main + 80-120K subagent; fresh-context per AP-1 + D-055).

**Scope**: Tracks A + B (Phase 3 resume) + Track C (BC-8) SHIPPED at this point. Track D/E may be in-flight.

**Deliverable**: Verifier observation `agent-workspace/memory/observations/sandwich-verifier-S272-mid-phase-A-B-C.md` + cluster verdict + residue catalog.

**Pre-flight ladder**: standard sandwich-verifier dispatch protocol (per `.claude/agents/sandwich-verifier.md`); fresh-context distinct session-id verified.

### F.2 — Phase 4 close VERIFY (S277)

**Session**: S277 (VERIFY 60-100K main + 100-150K subagent; fresh-context whole-Phase per AP-1 + D-055 + L-S21-1 verifier-budget-by-scope).

**Scope**: ALL Tracks (0/A/B/C/D/E) + SC-1..SC-9 evaluated.

**Deliverable**: `agent-workspace/memory/observations/sandwich-verifier-S277-phase-4-close.md` + cluster verdict + Phase 5 prereq enumeration.

### F.3 — Phase 4 retrospective + charter housekeeping (S278)

**Session**: S278 (post-mortem 50-80K main).

**Deliverable**:
- `agent-workspace/memory/post-mortems/2026-XX-XX-phase-4-retrospective.md`
- Phase Goals Tracker row 4 → DONE in `project.md`
- Phase 5 prereq enumeration → `agent-workspace/session-plans/pending/012-phase-5-master-plan.md` (NEXT ENTRY plan stub)
- Any Phase 4 deferrals surfaced as sustained-backlog items in `agent-workspace/memory/agent-notes.md` digest

---

## 10. Calibration Envelope (math)

| Component | Estimate | Source |
|---|---|---|
| Track 0 (S252+S253+S259+S260) | 320-500K main + ~80K subagent (verifiers) + ~$5 imputed | T5/T8/D-055/E.1; mostly file edits |
| Track A (S254) | 150-200K main + 50-80K subagent | per 008-S45 §S49 |
| Track B (S255-S258) | 580-840K main + 100-150K subagent + ~$8-16 imputed (probe + light dogfood) | per 009-S51 envelope |
| Track C (S261-S266) | 530-820K main + 250-380K subagent + ~$30-50 imputed (probe + 5-ticker × 2-run dogfood) | spec 004 binding; KEYSTONE |
| Track D (S267-S269) | 350-520K main + ~$45-90 imputed (20-thesis seeding) | spec 004 UC-4/UC-5 + eval-set growth |
| Track E (S270-S271) | 200-300K main | spec 005 skeleton |
| F (S272 + S277 + S278) | 170-280K main + 180-270K subagent | mid + final verify + retro |
| Reserves (S273+S274+S275+S276) | 0-600K main | use-only-if-triggered |
| **Phase 4 SUBTOTAL (no reserves)** | **~2.3M-3.5M main + ~600K-880K subagent + ~$90-160 imputed** | |
| **Phase 4 COMBINED** | **~2.9M-4.4M combined** | low-end no reserves; high-end 2-of-4 reserves fire |
| **Realistic mid-band** | **~3.2M-3.8M combined** | assumes 1-of-4 reserves fires |

**Cost discipline (Charter Principle 11 BINDING)**:
- Per-thesis cap ≤$3.00 BINDING (I-40). Track C 6-perspective parallel-fanout projected mean ~$2.80 (within cap); worst-case ~$3.75 — needs Q-P4-1 amendment OR per-role Haiku-hybrid fallback to stay within bound
- Phase 4 total imputed ~$90-160 (envelope ~5x Phase 3 actual; justified by 6-perspective × 5-ticker × 2-run dogfood + 20-thesis Track D seeding)
- Per-session AVG ≤Phase 3 actual × 1.5 ($6.93 × 1.5 = $10.40) — Phase 4 per-session AVG = $90-160 / 24 = ~$4-7 → WELL within per-session band

---

## 11. Risk Register (Phase 4 aggregate)

| ID | Severity | Description | Mitigation |
|---|---|---|---|
| **R-P4-1** | HIGH | Track C per-thesis cost breach $3.00 Charter cap | Q-P4-1 SCOPE-tier user pick: amend cap to $5 Phase 4 only / Haiku-hybrid Macro/Behavior/Manager / defer Manager to Phase 5 / tighter retry budgets |
| **R-P4-2** | HIGH | Track B BR-5 backtest gate fails (precision ≤0.5 OR recall ≤0.3) | Rollback per D-032 § Rollback path; defer pump live-deploy to S273 META_LOOP_RECOVERY; counter-narrative + sentiment paths still ship |
| **R-P4-3** | HIGH | Track C 5/5 × 2-run anti-flake gate fails | Apply D-053/D-054 retry-validator template to Macro/Behavior/Manager identically; if still flaky, escalate to user (SCOPE Q&A); defer Manager perspective if root cause is parallel-fanout contention |
| **R-P4-4** | HIGH | E.4 D-055 cool-down delay slipping past 2026-05-14T~21Z | S259 strict cool-down enforcement; reserve S276 if delay >1 session; rest of Phase 4 (Tracks A/B/C/D/E + housekeeping ex-D-055) is NOT gated on D-055 (only E.1 anthropic SDK removal is — that's S260) |
| **R-P4-5** | MED | Track B FB Graph API ToS shift mid-Phase-4 | Fallback to manual link-list mode (mirror BC-6 telegram_adapter S64); per-platform smoke retest |
| **R-P4-6** | MED | E.1 anthropic SDK removal breaks news / perspective adapter contracts | Probe single adapter first (claude_llm_extractor.py — narrower test surface); apply D-053/D-054 retry-validator template to subprocess CLI pattern; rollback via git revert if pytest regression >2 tests |
| **R-P4-7** | MED | Track C UC-1 latency >5 min (spec § A.5) | Parallel-fanout via asyncio.gather (D-054 pattern); profile bottleneck; cache static perspective inputs |
| **R-P4-8** | MED | Track D ≥30 thesis seeding cost overshoots budget | Per-thesis cost-ledger monitored at each S269 fixture; pause and re-evaluate at thesis #15 if mean cost >$2.80 |
| **R-P4-9** | MED | Subagent stream-window stall (per L-S43f-2 recurrence) | All subagent dispatches use LEAN brief ≤6 pre-reads; main-session fallback per Option 2 if subagent dispatch fails |
| **R-P4-10** | MED | Phase 4 envelope under-count (per Phase 2 L-S43e + Phase 3 master-plan R-P3-7) | This master-plan starts at realistic mid-band 3.2-3.8M; amend at first 50% milestone if trending >10% over (D-025 precedent) |
| **R-P4-11** | LOW | Same-agent self-review violation (AP-1) post-D-055 | D-055 BINDING from S259 ratification; all ARCH+/CHARTER ADRs require fresh-context verifier; E.3 hook MONITORED |
| **R-P4-12** | LOW | AP-23 firing-test fixture gap recurrence | firing-test-spawn-context-lint.sh ACTIVE since S248; new hooks added in Track 0/A/B/C ship with companion firing-test per L-S176-1 BINDING |

---

## 12. Open Questions (SCOPE-tier — for parent AskUserQuestion mega-bundle)

Per `qa_bundle_all_pending.md` user memory rule: ALL pending Q surfaced as single mega-bundle BEFORE S252 entry.

| ID | Tier | Question | Recommended |
|---|---|---|---|
| **Q-P4-1** | SCOPE | Track C per-thesis cost cap disposition: 6-perspective fanout mean ~$2.80 / worst-case ~$3.75 vs Charter I-40 $3.00. Options: (a) ACCEPT WORST-CASE — amend Charter Principle 11 cap to $5.00 Phase 4 only with explicit cool-down (b) HAIKU-HYBRID Macro/Behavior/Manager (cuts ~$0.40 but probe step at S262 must verify per-label accuracy ≥0.85) (c) DEFER Manager perspective to Phase 5 (5-perspective Phase 4 only) (d) TIGHTER RETRY budgets (max 2x all-role; D-054 bear 3x special-case retained) | (b) HAIKU-HYBRID if S262 probe accuracy holds; fallback to (d) if not |
| **Q-P4-2** | SCOPE | Track D §269 5 dogfood + 15 new tickers selection for sector diversity: (a) AUTO-PICK by sector-coverage rule (real-estate / retail / industrial / utilities / materials / healthcare) (b) USER names 15 explicitly (c) DEFER eval-set growth to Phase 5 (Track D ships UC-4 + UC-5 only) | (a) AUTO-PICK by sector rule (transparent; mirrors S235 stale plan Q-P4-3 = AUTO-PICK pre-resolved) |
| **Q-P4-3** | CHARTER | T8 charter v1.1 application disposition: cool-down ELAPSED 2026-05-09. (a) APPLY now at S253 (mechanical edit + version bump + ADR) (b) DEFER until E.4 (D-055) ratified first then bundle (c) REOPEN cool-down with v1.1 edits | (a) APPLY now — independent of E.4; eliminates Phase 3.5 deferred-doc backlog |
| **Q-P4-4** | CHARTER | T5 harness-health-protocol.md application disposition: charter-tier deny-lift gap M-S173-1. (a) APPROVE manual mv + apply at S252 (b) AMEND `.claude/settings.json` deny rule then apply (c) KEEP at `proposals/` permanently with constitution-tier cross-reference | (a) APPROVE manual mv — functional artifact identical to constitution location; cleanest path |
| **Q-P4-5** | SCOPE | Phase 4 envelope 3.2-3.8M mid-band over 24-28 sessions: (a) ACCEPT as-planned (b) RE-SCOPE — defer Track E (outer-loop scaffolding) to Phase 5 (saves ~300K main) (c) RE-SCOPE — defer Track D thesis-maturation to Phase 5 (saves ~520K main + $45-90 imputed) (d) RE-SCOPE — defer Track C Manager perspective to Phase 5 (saves ~80K main + reduces cost overshoot risk) | (a) ACCEPT — all 4 tracks tightly coupled to Charter Month 9 / Month 12 success criteria |
| **Q-P4-6** | SCOPE | D-055 application timing: cool-down ≥2026-05-14T~21Z. If user wants to accelerate (waive cool-down), Charter Revision Protocol requires explicit waiver. (a) HONOR cool-down — wait until 2026-05-14T~21Z (S259) (b) WAIVE cool-down — apply at S252 alongside T5/T8 (c) EXTEND cool-down + bundle with retrospective at S278 close | (a) HONOR — strictest charter discipline; ~48hr delay; reserve S276 covers slip |

**All 6 questions are SCOPE/CHARTER-tier**; per autonomous-full doctrine, parent S251 session MUST surface as single AskUserQuestion mega-bundle BEFORE authorizing S252 entry.

---

## 13. Session Sequence Table

| # | Session | Type | Track | Pre-reqs | Deliverables | Budget (low-high) | Verifier dispatch | Acceptance gate |
|---|---|---|---|---|---|---|---|---|
| 1 | S251 | PLAN | meta | S250 done; Phase 3.5 closed | This file (011-S251-phase-4-master-plan.md) | 50-80K (master-planner subagent) | embedded | This file lands |
| 2 | S252 | FOCUSED_IMPL | 0 (T5) | Q-P4-4 answered | `harness-health-protocol.md` in constitution/ | 80-120K main | none (charter-doc; non-code) | T5 SC-1 partial |
| 3 | S253 | FOCUSED_IMPL | 0 (T8) | Q-P4-3 answered | PROJECT_CHARTER.md v1.1 + ADR | 60-100K main + 40-60K subagent (fresh-ctx verifier) | YES per D-055-future-binding | T8 SC-1 partial |
| 4 | S254 | FOCUSED_IMPL | A | S252+S253 done | Track I Bayesian calibration ship | 150-200K main + 50-80K subagent | embedded in S272 | SC-3 |
| 5 | S255 | FOCUSED_IMPL | B (probe) | S254 done | BC-7 J+K probe matrix observation | 80-120K main + ~$3-6 imputed | none (probe) | probe matrix posted |
| 6 | S256 | MULTI_TASK_IMPL | B (J first half) | S255 done | BC-7 J Deliverables 1-15 + LIVE wiring | 150-220K main | embedded in S272 | SC-4 partial |
| 7 | S257 | MULTI_TASK_IMPL | B (J second half) | S256 done | BC-7 J Deliverables 16-19 | 150-220K main | embedded in S272 | SC-4 partial |
| 8 | S258 | MULTI_TASK_IMPL | B (K) | S257 done | BC-7 K full + BR-5 backtest gate | 150-220K main + 100-150K subagent | embedded in S272 | SC-4 complete |
| 9 | S259 | FOCUSED_IMPL | 0 (D-055) | cool-down ≥2026-05-14T~21Z | E.4 charter rule + decision-discipline.md edit + D-055 ACCEPTED | 60-100K main + 40-60K subagent (fresh-ctx, MANDATORY per D-055-self) | YES (D-055 self-application) | SC-1 complete |
| 10 | S260 | FOCUSED_IMPL | 0 (E.1) | S259 done; D-055 BINDING | anthropic SDK removal + D-056 ARCH-ADR | 120-180K main + 80-120K subagent | YES per D-055 (D-056 ARCH-tier) | SC-2 |
| 11 | S261 | PLAN | C (architect) | S252+S253+S259 done | D-057-BC-8 architecture ADR + sub-plan 012 | 50-80K subagent (sandwich-architect) | none yet (architect output) | architect dispatch return |
| 12 | S262 | THESIS / probe | C | S261 done; S258 done (BC-7 input ready) | Track C probe matrix observation | 80-120K main + ~$5-10 imputed | none (probe) | probe matrix posted |
| 13 | S263 | FOCUSED_IMPL | C (dev — Macro+Behavior) | S262 done | Macro + Behavior perspective adapters + tests | 100-150K main | embedded in S266 | partial SC-5 |
| 14 | S264 | FOCUSED_IMPL | C (dev — Manager + Synthesis) | S263 done | Manager perspective + Synthesis aggregate + Disagreement + counter-narrative wiring | 100-150K main | embedded in S266 | partial SC-5 |
| 15 | S265 | MULTI_TASK_IMPL | C (dev — UC + dogfood) | S264 done | UC-1 + UC-2 + UC-3 end-to-end + 5-ticker × 2-run anti-flake | 150-220K main + ~$15-30 imputed | embedded in S266 | partial SC-5 |
| 16 | S266 | VERIFY | C | S265 done | sandwich-verifier fresh-context per D-055 ARCH | 100-150K subagent | YES (fresh-context distinct from S261 architect + S263-S265 dev) | SC-5 complete |
| 17 | S267 | FOCUSED_IMPL | D | S266 done | UC-4 post-mortem synthesis ship | 100-150K main | embedded in S277 | partial SC-6 |
| 18 | S268 | FOCUSED_IMPL | D | S267 done | UC-5 disagreement report ship | 100-150K main | embedded in S277 | partial SC-6 |
| 19 | S269 | INGEST | D | S266 done; Q-P4-2 answered | 5 dogfood + 15 new ticker eval-set growth + bias log seed | 150-220K main + ~$45-90 imputed | embedded in S277 | SC-6 complete |
| 20 | S270 | FOCUSED_IMPL | E | S269 done (eval-set foundation) | BC-9 aggregates + UC-1 PROPOSE skeleton + holdout manifest + composite-metric YAML | 100-150K main | embedded in S277 | partial SC-7 |
| 21 | S271 | FOCUSED_IMPL | E | S270 done | UC-1 EVAL skeleton + M-1..M-4 mitigation seeds + minimum-eval-set gate | 100-150K main | embedded in S277 | SC-7 complete |
| 22 | S272 | VERIFY | meta (mid) | S258 done OR S266 done (whichever earlier blocks midcheck) | sandwich-verifier mid-phase observation (Tracks A+B+C consolidated) | 60-90K main + 80-120K subagent (fresh-ctx) | YES | mid-phase residue catalogged |
| 23 | S273 | META_LOOP_RECOVERY | meta | reserved | OPTIONAL: use only if Track B BR-5 backtest gate fails OR Track C anti-flake fails | 0-220K main | n/a | n/a |
| 24 | S274 | harness-recovery | meta | reserved | OPTIONAL: harness gap mid-Phase-4 | 0-150K main | n/a | n/a |
| 25 | S275 | budget-overflow split | meta | reserved | OPTIONAL: S256 or S264 split if pre-flight projects >230K | 0-150K main | n/a | n/a |
| 26 | S276 | charter-cool-down-slip | meta | reserved | OPTIONAL: D-055 cool-down delay past 2026-05-14T~21Z | 0-80K main | n/a | n/a |
| 27 | S277 | VERIFY | meta (close) | All A/B/C/D/E SHIPPED | sandwich-verifier whole-Phase-4 close (fresh-context per D-055 + L-S21-1 verifier-budget-by-scope = 150K cap) | 60-100K main + 100-150K subagent | YES (fresh-context) | SC-9 |
| 28 | S278 | POST_MORTEM | meta | S277 done | Phase 4 retrospective + Phase 5 prereq stub plan | 50-80K main | none | Phase 4 close |

**24 substantive sessions** (S251 + 27 work) + **4 reserves** (S273+S274+S275+S276) = **28 budgeted sessions**.

### Critical path

```
S251 → AskUserQuestion mega-bundle (Q-P4-1..Q-P4-6)
  → S252 (T5) → S253 (T8) ─┐
                            ├─→ S254 (Track A) ─┐
  → S259 (D-055, cool-down) │                    ├─→ S272 (mid-VERIFY) ─┐
  → S260 (E.1)              │                    │                      │
                            ↓                    ↓                      ↓
                          S255 → S256 → S257 → S258 (Track B BR-5 gate) │
                                                                         │
                                  S261 → S262 → S263 → S264 → S265 → S266 (Track C VERIFY)
                                                                         │
                                                                         ↓
                                                          S267 → S268 → S269 (Track D)
                                                                         │
                                                                         ↓
                                                            S270 → S271 (Track E)
                                                                         │
                                                                         ↓
                                                            S277 (whole-Phase VERIFY) → S278 (close)
```

- **Track 0 housekeeping** runs in parallel with Tracks A/B (no shared-file conflicts; charter doc edits vs production code edits)
- **Track C is critical-path** — Phase 4 keystone; SC-5 5/5 × 2-run gate
- **Track D requires Track C** (UC-4 + UC-5 consume Track C output)
- **Track E is lowest-priority** — can fully defer to Phase 5 if scope-anxiety surfaces (Q-P4-5 option b)
- **Reserves S273-S276** insert as triggered (no pre-staging budget reserve fires)

---

## 14. Pre-flight Checklist for S252 entry

1. ✅ Read this file first (011-S251)
2. ✅ Verify all 6 SCOPE/CHARTER questions answered + disposition recorded in `current-execution.md`
3. ✅ Verify cool-down windows:
   - T8 charter v1.0 → v1.1: cool-down ELAPSED 2026-05-09 ✓
   - D-055 E.4 charter: cool-down ≥2026-05-14T~21Z (S259 enforce)
   - T5 protocol: no cool-down required (constitution-tier not charter-tier amendment per Charter Revision Protocol scope)
4. ✅ Per Charter Principle 11 — Phase 4 cost target $90-160 imputed; track via `cost-ledger.tsv`; per-thesis ≤$3.00 (Q-P4-1 disposition binds)
5. ✅ Per L-S204-1 doctrine — every probe (S255 Track B / S262 Track C) is empirical-only; NO armchair "obvious winner" picking
6. ✅ Per AP-1 + D-055 — S253, S259, S260, S266, S272, S277 verifier dispatches MUST be fresh-context subagent (Agent tool with subagent_type)
7. ✅ Per L-S43f-2 lean-brief rule — every architect/dev/verifier subagent dispatch ≤6 pre-reads
8. ✅ Per AP-23 firing-test gap rule — any NEW hook added in Phase 4 ships with companion firing-test (L-S176-1 BINDING); firing-test-spawn-context-lint.sh actively monitors
9. ✅ Per AP-7 ghost-greening rule — adr-empirical-close-verify-spot-check.sh ACTIVE; new ADR `empirical_close_verify` blocks must survive E.3 spot-check
10. ✅ Per autonomous-full doctrine — Phase 4 close (S277+S278) does NOT pause for routine handoff; only Q-P4-1..Q-P4-6 (and any new Q-P4-7+ if surfaced) trigger AskUserQuestion
11. ✅ Per Tracking retention — `current-execution.md` ≤5 sessions inline, ≤200 LOC; archive if breached during Phase 4
12. ✅ Per autonomous_continue_no_self_pause — between sessions, dispatch next subagent immediately; do NOT self-pause at session boundary

---

## 15. Phase 5+ Deferrals (explicit OUT-OF-SCOPE for Phase 4)

Carryover from S235 stale plan + new deferrals from this plan:

- FastAPI public endpoints (Charter Phase 4 surface → renamed Phase 5+)
- NestJS public-API path (Phase 5+ if SaaS path activated)
- Streamlit → Next.js migration (Phase 5+)
- TimescaleDB / Postgres migration (Phase 5+ SaaS-deploy boundary)
- Live broker API integration (Phase 5+; Charter explicit research-aid framing)
- LLM-perspective sentiment classifier (Phase 5; Phase 4 ships deterministic-rule sentiment per BC-7 spec)
- **Outer-loop activation runs** (Year 2 per spec 005 § A.2; Phase 4 ships SKELETON only — Track E)
- Bull-role parallel-load investigation root-cause-deep-dive (S234 backlog item E carryover)
- Calibration data full-150-rec accumulation (Charter Year 2; Phase 4 ships seed of ≥30 theses)
- Notifications retention policy enforcement (Q-P4-5 → Phase 5 sustained queue if not picked at S278 retrospective)
- Telegram crowd-sentiment aggregator (BC-7 Track explicitly deferred per D-032 § (b))
- Cron-driven outer-loop weekly run (spec 005 § A.5 UC-1; Year 2)

---

## 16. Connection to Charter + Constitution + Specs

| Source | Section | How this plan honors |
|---|---|---|
| `PROJECT_CHARTER.md` Month 9 success criteria | Bear/bull/critic/quant/macro/behavior agents operational | SC-5 Track C 6 perspectives + synthesizer |
| `PROJECT_CHARTER.md` Month 9 success criteria | Pattern library 15+ VN-specific patterns with outcome data | partial via Track D eval-set growth (≥30 theses; Phase 5 hits 50+) |
| `PROJECT_CHARTER.md` Month 9 success criteria | Thesis hit rate measurable | partial via Track D UC-4 post-mortem synthesis |
| `PROJECT_CHARTER.md` Month 12 success criteria | Karpathy outer loop optimizing signal weights weekly | DEFERRED to Phase 5 / Year 2; SCAFFOLDING ships Track E |
| `PROJECT_CHARTER.md` Month 12 success criteria | Personal bias log ≥3 biases | SC-6 Track D |
| `PROJECT_CHARTER.md` Principle 9 NO LLM math | every classifier/use-case deterministic | I-S1 grep gates at every track close |
| `PROJECT_CHARTER.md` Principle 11 cost discipline | $3.00/thesis cap | Q-P4-1 SCOPE pre-staged; cost-ledger monitored |
| `agent-workspace/constitution/architecture.md` § BC-8 | 6 perspective architecture | Track C spec 004 binding |
| `agent-workspace/constitution/architecture.md` § BC-9 | outer-loop architecture | Track E spec 005 binding (Year 2 deferred) |
| `agent-workspace/constitution/architecture.md` § LLM Substrate Boundary (D-026) | per-role override + prose-tolerant JSON + gatherer-wired | Track C 3 NEW perspective adapters cite D-026 verbatim; Track 0.4 E.1 anthropic SDK removal preserves D-026 |
| `agent-workspace/constitution/invariants.md` § I-S1 | NO LLM math | grep gate at every track close |
| `agent-workspace/constitution/invariants.md` § I-S10 | substantive bear case ≥3 distinct points | D-054 retry-validator pattern preserved; Synthesis invariant enforces |
| `agent-workspace/constitution/invariants.md` § I-S11 | ≥4 perspectives | Synthesis aggregate invariant; UC-2 Quick Check explicit lower-tier |
| `agent-workspace/constitution/invariants.md` § I-S12 | preserve disagreement | Synthesis aggregate has explicit_disagreements list (never averaged) |
| `agent-workspace/constitution/invariants.md` § I-S35 | research-aid framing | Recommendation enum {THESIS_CANDIDATE/INVESTIGATE/WATCH/PASS} — never BUY/SELL |
| `agent-workspace/constitution/decision-discipline.md` § (post-D-055) | fresh-context verifier for ARCH+/CHARTER | All ARCH+ ADRs Phase 4 dispatch fresh-context verifier (S253/S259/S260/S266/S272/S277) |
| `agent-workspace/constitution/harness-health-protocol.md` v1.0 | 12-signal HH-1..HH-12 catalog | Track 0.1 T5 COMPLETE (mv S220 D-048; cross-refs updated S252) |
| `agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md` | Principle 11 Harness Self-Verify Firing | Track 0.2 T8 application |
| `agent-workspace/proposals/E4-fresh-context-verifier-arch-charter-tier.md` | D-055 charter rule | Track 0.3 application |
| `agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md` | D-032 BC-7 architecture | Track B sub-plan 009-S51 binding |
| `agent-workspace/memory/decisions/054-bear-quant-retry-validator-symmetry.md` | D-054 asymmetric retry budget | Track C 3 NEW perspectives mirror template |
| `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` | BC-8 6-perspective + UC-1..UC-5 | Track C binding |
| `specs/tier2-feature/005-karpathy-outer-loop.md` § A.2 | Year 2 activation | Track E SKELETON only Phase 4 |

---

## 17. Files Created by This Plan (S251 deliverables)

1. `agent-workspace/session-plans/pending/011-S251-phase-4-master-plan.md` (this file)

The S235 predecessor `008-S235-phase-4-master-plan.md` is now SUPERSEDED (not deleted; retained for audit per L-S43f-3 no-history-edit doctrine; marked `supersedes:` in this file's frontmatter).

---

## 18. Notes on this plan's authoring

- File LOC: ~570 (target ≤500 per M-S31-1 advisory; mild overshoot acceptable for plan covering 24+ sessions × 7 tracks; budget-advisory not budget-blocking)
- Authoring path: master-planner subagent dispatch (per AP-1; per S250 close instruction)
- Lean brief honored: 6 pre-reads (CLAUDE.md / PROJECT_CHARTER.md / project.md / current-execution.md / checkpoints/latest.md S250 close + observation 2026-05-12-S250-phase-3.5-close.md / session-plans 009-S51 + decisions D-032 + spec 004/005 sample reads)
- Per L-S204-1 doctrine: every code-site claim grounded by literal Read of the file lines cited (NOT memory)
- Per AP-23 cheapest-by-RISK: Track E deferred to skeleton-only; no speculative Year 2 anticipation
- Per Charter Principle 11: cost envelope explicit; mean + worst-case stated; Q-P4-1 escalation pre-staged
- Per autonomous-full + qa_bundle_all_pending: 6 SCOPE/CHARTER questions pre-staged as single AskUserQuestion mega-bundle (Q-P4-1..Q-P4-6); never piecemeal
- Phase 3.5 carryover (T5/T8/D-055/E.1) ABSORBED as Track 0 housekeeping — closes the deferred-documentation backlog cleanly per S250 close-pick rationale
- Phase 3 PAUSED tracks (Track I via 008-S45 §S49; Tracks J+K via 009-S51) re-mapped as Track A + Track B respectively; sub-plans remain authoritative for per-session deliverable matrices

---

## End of Master Plan
