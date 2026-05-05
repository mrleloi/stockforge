---
spec_id: SPEC-2026-04-23-005
tier: 2
status: approved
version: 1.0
created: 2026-04-23
authors: [project-owner]
bounded_contexts: [Analysis, Calibration, Market Data]
related_specs: [SPEC-2026-04-23-T1-001, SPEC-2026-04-23-004]
ubiquitous_language_terms: [Outer Loop, Editable Asset, Scalar Metric, Eval Set, Goodhart's Law, Ratchet, Simplicity Criterion, Meta-Optimization, Walk-Forward]
---

# SPEC: Karpathy Outer Loop — Pipeline Self-Optimization (Year 2)

> Applies the Karpathy autoresearch pattern to optimize signal weights, prompts, and rules over time.
> **This spec activates in Year 2.** Year 1 is calibration-data-accumulation; without sufficient data, outer loop has nothing to optimize against.

---

# PART A — BUSINESS SPECIFICATION

## A.1 Context

Karpathy's autoresearch loop: LLM agent edits an `editable_asset` repeatedly, each edit evaluated by a `scalar_metric`, within a `time_boxed_cycle`. Best results kept (ratchet), simpler solutions preferred (simplicity criterion).

Applied to StockForge: **we don't optimize investment decisions directly** (that's Goodhart trap — LLM would learn to hack whatever metric we use). We optimize the **pipeline** that produces investment theses.

**Editable assets**:
- Signal weights in confluence engine
- Prompt templates for perspective agents
- Pump phase classifier thresholds
- KOL credibility formula parameters
- Narrative phase transition rules
- Screening rules in watchlist

**Scalar metrics** (on HOLD-OUT set, not used for tuning):
- Thesis hit rate (primary)
- Alert precision/recall
- Pump detection precision/recall
- KOL calibration CI width

**Time-boxed cycle**: each "experiment" = re-run pipeline on historical period + measure metric, ~1-2 hours.

## A.2 Why Year 2 Activation

Karpathy loop requires **evaluation data**. StockForge generates evaluation data through:
- Thesis outcomes (3-12 month review cycle)
- KOL recommendation outcomes (1-12 month cycle)
- Pump detection outcomes (30-90 days post-detection)
- Narrative phase predictions vs actual phase evolution

**Minimum eval set sizes before outer loop meaningful**:
- 100+ completed thesis with outcomes
- 500+ KOL recommendations with outcomes
- 20+ labeled historical pumps with outcomes
- 10+ narratives through full lifecycle

These take ~12-18 months to accumulate. Running outer loop with insufficient data = overfit to noise, worse than doing nothing.

## A.3 The Goodhart Problem

The #1 risk: outer loop optimizes for the metric, not for real-world value. Mitigations:

**M-1 Hold-Out Test Set** — 30% of evaluation data never seen by outer loop. Final metric always computed on hold-out. If training metric improves but hold-out degrades: reject.

**M-2 Multi-Metric Composite** — never optimize single metric. Composite of thesis_hit_rate + alert_precision + calibration_accuracy + simplicity_penalty.

**M-3 Simplicity Ratchet** — if edit adds complexity (more rules, more parameters, longer prompt) but improves metric marginally (<5% lift), reject.

**M-4 Walk-Forward Validation** — each proposed change tested on 3 non-overlapping historical windows. Must improve in ≥2 of 3 to be accepted.

**M-5 Human Review of Proposed Changes** — outer loop proposes; human approves before production. Not autonomous in year 2.

**M-6 Eval Set Rotation** — eval set refreshes quarterly (new data added, oldest retired). Prevents pipeline from memorizing specific eval items.

## A.4 Three Loops Recap

**Outer loop (this spec, weekly cycle, Year 2+)** — meta-optimization: edit pipeline params + prompts + rules

**Middle loop (continuous, Phase 1+)** — ingestion: hourly news, daily KOL, scheduled reviews, live data

**Inner loop (per-query, Phase 1+)** — thesis validation: ticker → 6 perspectives → synthesis

Each loop has different cadence, different editable assets, different metrics.

## A.5 Core Use Cases

**UC-1 Weekly Optimization Run** — Every Sunday: outer loop picks one editable asset from candidate list, proposes N variations, runs each through eval pipeline, ranks by composite metric, produces report.

**UC-2 Human Review & Accept** — User reviews weekly report. Approves, rejects, or requests modification. Approved changes go to production next week.

**UC-3 Regression Alert** — If a change in production causes metric to drop >20% over 4 weeks, auto-rollback to prior version + flag for investigation.

**UC-4 Proposal Archive** — All proposed changes (accepted or rejected) archived with full rationale + results. Pattern: what tends to work, what tends to fail.

**UC-5 Manual Experiment Request** — User can propose specific experiment ("try reducing KOL weight 20%"), outer loop runs it through same eval pipeline.

## A.6 Business Rules

**BR-1 Never Auto-Deploy** — outer loop PROPOSES, human ACCEPTS. Year 2 at minimum. Maybe never fully autonomous.

**BR-2 Eval Set Never Used for Training** — strict separation. Eval set lives in `eval-sets/`; training data for prompt refinement lives elsewhere.

**BR-3 Multi-Metric Composite** — no single-metric optimization. Composite defined in `configs/outer-loop-metrics.yaml`.

**BR-4 Simplicity Preferred** — complexity penalty in composite. New rule adds score iff |improvement| > complexity_cost.

**BR-5 Walk-Forward Mandatory** — propose change → test on 3 non-overlapping windows → accept if 2+ improve.

**BR-6 Rollback Trigger Automated** — metric drops >20% in 4 weeks of production = automatic revert to previous version, manual re-review required.

**BR-7 Changes Versioned** — every pipeline version is a git tag. Rollback = git checkout.

**BR-8 Proposals Limited Per Week** — max 3 proposals per week to prevent noise. Forces thoughtful selection.

**BR-9 Prompt Changes Human-Reviewed First** — no automated prompt editing in year 2. All prompt changes reviewed line-by-line before testing.

**BR-10 Minimum Eval Set Enforced** — outer loop refuses to run if eval set below minimums (see A.2).

## A.7 Success Criteria (Year 2)

**Month 15** (activation + 3 months):
- Outer loop runs weekly, produces reports
- ≥5 proposals reviewed, ≥2 accepted
- Documented cases: metric improvement from specific changes

**Month 18**:
- Accepted changes show compounding improvement (metric lift from baseline)
- No auto-rollback triggered (changes were sound)
- Human review time <30 min/week

**Month 24**:
- Outer loop has produced ≥20 accepted changes
- Pipeline metric improved ≥30% vs baseline
- Changes in "pattern library" (what kinds of changes work)

**Qualitative**:
- I trust the proposals enough that review feels valuable, not performative
- Outer loop caught at least one case where my intuition was wrong
- Pipeline demonstrably smarter than when we started

## A.8 Out of Scope

- Autonomous code changes (outer loop proposes to config + prompts, not Python code)
- Optimizing individual perspective prompts (BR-9 restriction)
- Year 1 activation (insufficient data)
- Multi-user tenancy (single user Year 2)

---

# PART B — AGENT CONTRACT

## B.1 Editable Asset Registry

```yaml
# configs/outer-loop/editable-assets.yaml

editable_assets:
  - id: confluence_weights
    path: configs/signals/confluence-weights.yaml
    description: How much each tier contributes to confluence score
    mutation_types: [numeric_range, numeric_relative]
    safety: high  # changes immediately affect alerts

  - id: pump_classifier_thresholds
    path: configs/signals/pump-classifier.yaml
    description: Thresholds for pump phase classification
    mutation_types: [numeric_range]
    safety: high

  - id: kol_credibility_formula
    path: configs/calibration/kol-credibility.yaml
    description: Bayesian prior + decay + sector weighting
    mutation_types: [numeric_range, formula_variant]
    safety: medium  # affects scoring but calibration is statistical

  - id: narrative_phase_thresholds
    path: configs/signals/narrative-phases.yaml
    description: Thresholds for INCUBATION → EMERGING etc transitions
    mutation_types: [numeric_range]
    safety: medium

  - id: screening_rules
    path: configs/screeners/*.yaml
    description: Watchlist screening rule variants
    mutation_types: [rule_addition, rule_removal, threshold_change]
    safety: low  # easy to revert

  - id: synthesizer_prompt
    path: prompts/analysis/synthesizer.md
    description: System prompt for synthesizer
    mutation_types: [prompt_variant]
    safety: high  # affects all thesis output
    human_review_required: line_by_line

  - id: perspective_prompts
    path: prompts/analysis/perspectives/*.md
    description: System prompts for 6 perspective agents
    mutation_types: [prompt_variant]
    safety: high
    human_review_required: line_by_line
```

## B.2 Metrics Definition

```yaml
# configs/outer-loop/metrics.yaml

composite_metric:
  weights:
    thesis_hit_rate: 0.35         # primary
    thesis_excess_return: 0.20    # beats benchmark
    alert_precision: 0.15         # not crying wolf
    alert_recall: 0.10            # not missing opportunities
    pump_detection_f1: 0.10
    kol_calibration_convergence: 0.05
    simplicity_penalty: -0.05     # subtracted

  normalization:
    # Each sub-metric normalized to [0, 1] based on historical distribution

  simplicity_penalty:
    formula: |
      lines_of_rules_added * 0.01
      + prompt_tokens_added * 0.001
      + new_parameters * 0.05

metric_calculation:
  eval_periods:
    - start: 2023-01-01
      end: 2023-06-30
    - start: 2023-07-01
      end: 2023-12-31
    - start: 2024-01-01
      end: 2024-06-30
    - start: 2024-07-01
      end: 2024-12-31

  min_thesis_per_period: 20       # won't run if fewer
  min_kol_recs_per_period: 100
  min_pump_cases_per_period: 5
```

## B.3 Core Use Cases

### UC-1: Weekly Optimization Run

```python
# apps/analyst-agents/outer_loop/weekly_runner.py

class WeeklyOptimizationRunner:
    """Every Sunday: pick candidate → generate mutations → evaluate → report."""

    async def execute(self) -> OptimizationReport:
        # Step 0: Check minimum eval set sizes
        if not await self._eval_set_minimums_met():
            return OptimizationReport(status=SKIPPED, reason="insufficient_eval_data")

        # Step 1: Pick candidate editable asset (LLM-assisted)
        candidates = await self.asset_registry.get_candidates()
        # Prioritize: assets not recently modified, assets where metric drift observed
        candidate = await self.candidate_selector.select(candidates, self.recent_history)

        # Step 2: Generate mutations (3-5 variants)
        mutations = await self.mutation_generator.generate(
            asset=candidate,
            n_variants=4,
            constraint=candidate.safety_level,
        )

        # Step 3: Run each mutation through eval pipeline (walk-forward)
        results = []
        for mutation in [current_baseline] + mutations:
            for eval_period in self.config.eval_periods:
                result = await self.eval_runner.run(mutation, eval_period)
                results.append((mutation, eval_period, result))

        # Step 4: Aggregate walk-forward scores
        scores_by_mutation = {}
        for mutation, period, result in results:
            scores_by_mutation.setdefault(mutation.id, []).append(result)

        walk_forward_pass = []
        for mut_id, period_results in scores_by_mutation.items():
            # Must improve in ≥2 of 3 periods
            baseline = scores_by_mutation[CURRENT_BASELINE_ID]
            improvements = sum(
                1 for mut_res, base_res in zip(period_results, baseline)
                if mut_res.composite > base_res.composite
            )
            if improvements >= 2 and mut_id != CURRENT_BASELINE_ID:
                walk_forward_pass.append(mut_id)

        # Step 5: Apply simplicity ratchet
        ratchet_pass = []
        for mut_id in walk_forward_pass:
            mutation = next(m for m in mutations if m.id == mut_id)
            if mutation.complexity_delta < 0 or (
                self._avg_improvement(mut_id) > mutation.complexity_delta * 0.05
            ):
                ratchet_pass.append(mut_id)

        # Step 6: Generate report
        report = OptimizationReport(
            week=self.current_week,
            candidate_asset=candidate.id,
            baseline_score=self._score(CURRENT_BASELINE_ID),
            mutations_tested=len(mutations),
            walk_forward_passers=walk_forward_pass,
            simplicity_passers=ratchet_pass,
            recommended=ratchet_pass[0] if ratchet_pass else None,
            rationale=await self._generate_rationale(candidate, mutations, results),
        )
        await self.report_repo.save(report)
        await self._notify_user_for_review(report)
        return report
```

### UC-2: Evaluate Mutation on Historical Period

```python
class EvalRunner:
    """Run pipeline with mutation against historical period, compute metrics."""

    async def run(self, mutation: Mutation, period: EvalPeriod) -> EvalResult:
        # Temporary pipeline instance with mutation applied
        pipeline = self.pipeline_factory.create(config_override=mutation.config_diff)

        # Get eval thesis set for period (hold-out, not used for training)
        thesis_eval = await self.eval_set_repo.get_thesis_eval(period, holdout=True)
        kol_eval = await self.eval_set_repo.get_kol_eval(period, holdout=True)
        pump_eval = await self.eval_set_repo.get_pump_eval(period, holdout=True)

        # Run pipeline on eval inputs, compare to known outcomes
        thesis_scores = []
        for thesis_input in thesis_eval:
            predicted = await pipeline.validate_thesis(thesis_input.ticker, as_of=thesis_input.as_of)
            thesis_scores.append(self._score_thesis(predicted, thesis_input.known_outcome))

        # Similarly for alerts, pumps, KOL calibration...
        metrics = Metrics(
            thesis_hit_rate=mean([s.hit for s in thesis_scores]),
            thesis_excess_return=mean([s.excess_return for s in thesis_scores]),
            alert_precision=self._compute_alert_precision(pipeline, period, holdout=True),
            alert_recall=self._compute_alert_recall(pipeline, period, holdout=True),
            pump_detection_f1=self._compute_pump_f1(pipeline, pump_eval),
            kol_calibration_convergence=self._compute_kol_convergence(pipeline, kol_eval),
            simplicity_penalty=self._complexity_penalty(mutation),
        )

        composite = self._compute_composite(metrics)
        return EvalResult(
            mutation_id=mutation.id, period=period, metrics=metrics, composite=composite,
        )
```

### UC-3: Apply Approved Mutation to Production

```python
class ApproveAndDeployMutation:
    """Human has approved a proposed mutation. Apply to production config."""

    async def execute(self, report_id: str, mutation_id: str, human_approver: str) -> DeployedChange:
        report = await self.report_repo.get(report_id)
        mutation = next(m for m in report.mutations_tested if m.id == mutation_id)

        # Version current production
        current_version = await self.git_service.tag_current_state(
            tag=f"pipeline-v{self.current_version + 1}-pre-mutation"
        )

        # Apply mutation to config file
        await self.config_service.apply_mutation(mutation)

        # Tag new version
        new_version_tag = await self.git_service.tag_current_state(
            tag=f"pipeline-v{self.current_version + 2}"
        )

        deployed = DeployedChange(
            change_id=new_id(),
            report_id=report_id,
            mutation_id=mutation_id,
            approved_by=human_approver,
            deployed_at=datetime.utcnow(),
            pre_mutation_version=current_version,
            post_mutation_version=new_version_tag,
            monitoring_window_days=28,
            rollback_threshold_metric_drop=0.20,
        )
        await self.deployed_changes_repo.save(deployed)
        await self._start_monitoring(deployed)
        return deployed
```

### UC-4: Monitor & Auto-Rollback

```python
class RegressionMonitor:
    """Daily: check deployed changes for regression. Auto-rollback if >20% drop."""

    async def check_deployed_changes(self):
        active_changes = await self.deployed_changes_repo.get_active_monitoring()
        for change in active_changes:
            if (datetime.utcnow() - change.deployed_at).days > change.monitoring_window_days:
                change.status = MONITORING_COMPLETE
                await self.deployed_changes_repo.save(change)
                continue

            current_metric = await self.metrics_service.compute_recent(window_days=7)
            baseline = change.pre_mutation_baseline_metric
            drop_pct = (baseline - current_metric) / baseline

            if drop_pct > change.rollback_threshold_metric_drop:
                await self._auto_rollback(change, reason=f"metric_dropped_{drop_pct:.1%}")
                await self.event_bus.publish(ChangeRolledBack(change.change_id, drop_pct))
```

## B.4 Mutation Generator

The mutation generator is itself LLM-assisted. Claude proposes variants to an editable asset. Example:

```python
class MutationGenerator:
    """LLM-assisted mutation generation for editable assets."""

    async def generate(self, asset: EditableAsset, n_variants: int, constraint: str) -> list[Mutation]:
        if asset.mutation_types == ["numeric_range"]:
            # Simple: random perturbations within defined range
            return self._generate_numeric_variants(asset, n_variants)
        elif asset.mutation_types == ["prompt_variant"]:
            # Complex: LLM proposes prompt rewrites
            return await self._generate_prompt_variants(asset, n_variants)
        elif asset.mutation_types == ["rule_addition", "rule_removal"]:
            return await self._generate_rule_variants(asset, n_variants)
        # ...

    async def _generate_prompt_variants(self, asset: EditableAsset, n: int) -> list[Mutation]:
        """LLM proposes variations of a prompt, with rationale for each."""
        current_prompt = await self._read_asset(asset)
        recent_failures = await self._recent_failures_relevant_to(asset)

        prompt = f"""
You are proposing variants of this LLM system prompt for an investment analysis agent.

Current prompt:
{current_prompt}

Recent failure modes observed:
{recent_failures}

Generate {n} variants. Each variant:
- Must preserve core role/purpose
- Should address one specific observed failure mode
- Rationale must be explicit (why this change might improve quality)
- Minimize length change — unnecessary verbosity is penalized

Output JSON array of {{variant_id, new_prompt, rationale, expected_improvement_area}}.
"""
        response = await self.llm.complete(prompt)
        return self._parse_prompt_variants(response)
```

## B.5 Eval Set Management

```python
# eval-sets/ directory structure

eval-sets/
├── historical-theses/
│   ├── 2023-H1/
│   │   ├── holdout/         # 30% — NEVER used for training
│   │   │   ├── hpg-2023-02-15.json   # ticker, as_of_date, known_outcome
│   │   │   └── ...
│   │   └── training/        # 70% — can be used for prompt refinement
│   ├── 2023-H2/
│   └── ...
├── labeled-pumps/
│   ├── 2022-flc-cycle.yaml
│   ├── 2023-thep-rally.yaml
│   └── ...
├── labeled-kol-recommendations/
│   ├── calibration-set.json
│   └── holdout-set.json
├── known-value-traps/
└── known-winners/
```

Each eval item has:
- Input context (ticker, as_of_date)
- Known outcome (return at 3m/6m/12m, labels)
- Metadata (when labeled, by whom, confidence in label)

## B.6 Database Schema

```sql
-- db/migrations/009_outer_loop.sql

CREATE TABLE optimization_reports (
    report_id TEXT PRIMARY KEY,
    week_of DATE NOT NULL,
    candidate_asset TEXT NOT NULL,
    baseline_score REAL NOT NULL,
    mutations_tested JSONB NOT NULL,
    walk_forward_passers TEXT[],
    simplicity_passers TEXT[],
    recommended TEXT,
    rationale TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ,
    reviewer TEXT,
    review_decision TEXT,
    review_notes TEXT
);

CREATE TABLE deployed_changes (
    change_id TEXT PRIMARY KEY,
    report_id TEXT NOT NULL REFERENCES optimization_reports(report_id),
    mutation_id TEXT NOT NULL,
    approved_by TEXT NOT NULL,
    deployed_at TIMESTAMPTZ NOT NULL,
    pre_mutation_version TEXT NOT NULL,
    post_mutation_version TEXT NOT NULL,
    pre_mutation_baseline_metric REAL NOT NULL,
    monitoring_window_days INT NOT NULL,
    rollback_threshold_metric_drop REAL NOT NULL,
    status TEXT NOT NULL,            -- monitoring | complete | rolled_back
    rolled_back_at TIMESTAMPTZ,
    rollback_reason TEXT
);

CREATE TABLE eval_runs (
    run_id TEXT PRIMARY KEY,
    mutation_id TEXT NOT NULL,
    eval_period_start DATE NOT NULL,
    eval_period_end DATE NOT NULL,
    metrics JSONB NOT NULL,
    composite REAL NOT NULL,
    duration_ms INT NOT NULL,
    ran_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## B.7 Cadences

- **Weekly optimization run**: Sunday 02:00
- **User review of report**: within 7 days (or auto-expires, no action = reject)
- **Deployment of approved**: following Monday 06:00
- **Monitoring of deployed**: daily 23:00 for 28 days
- **Auto-rollback check**: daily 23:30 for any change in monitoring
- **Quarterly eval set refresh**: first Sunday of quarter

## B.8 Tasks (Year 2 Phase)

**Phase 1** (infrastructure, ~4 weeks):
- Editable asset registry + mutation framework
- Eval set loader + partitioner (train/holdout)
- Metric computation service
- Composite scoring formula

**Phase 2** (mutation generators, ~3 weeks):
- Numeric variant generator
- Prompt variant generator (LLM-assisted)
- Rule variant generator
- Validation of proposed mutations

**Phase 3** (evaluation, ~4 weeks):
- Walk-forward eval runner
- Historical pipeline replay
- Metric aggregation
- Report generation

**Phase 4** (deployment + monitoring, ~3 weeks):
- Git-tag-based versioning
- Approval workflow UI
- Regression monitor + auto-rollback
- Change archive browser

## B.9 Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Goodhart: optimize metric, harm real performance | HIGH | CRITICAL | Hold-out set, multi-metric, walk-forward, human review |
| Overfitting to historical regime | HIGH | HIGH | Walk-forward validation + quarterly eval refresh |
| LLM proposes broken mutations | MEDIUM | MEDIUM | Mutation validator + dry-run before full eval |
| User rubber-stamps approval | MEDIUM | HIGH | Reviewer must write rationale for accept; spot-checked by agent critic |
| Rollback triggers too often | LOW | MEDIUM | Threshold tunable; 20% is starting point |
| Accumulated changes make system incomprehensible | MEDIUM | HIGH | Simplicity penalty + quarterly "what's the current state?" review |

---

# PART C — PROVENANCE & REVIEW

## C.1 Why This Design

**Considered alternative: full autonomous pipeline evolution**
- Rejected: too dangerous without 2+ years of calibration. Goodhart risk too high.

**Considered alternative: no outer loop, manual iteration forever**
- Rejected: doesn't leverage the Karpathy insight; compounds slower than system should.

**Considered alternative: Year 1 activation with limited assets**
- Rejected: insufficient eval data leads to overfitting noise.

**Considered alternative: single composite metric**
- Accepted with modification: composite IS used, but computed from multi-metric basis, not single number.

## C.2 Open Questions

- Who should be trusted to approve changes? If project gains users, does each user have their own outer loop?
- How to handle market regime shifts (post-2024 regime may invalidate 2022 eval data)?
- Can outer loop propose changes to itself (meta-meta optimization)? Probably not Year 2.
- When does outer loop get to touch Python code (not just configs/prompts)?

## C.3 Reviews

| Date | Reviewer | Status | Notes |
|---|---|---|---|
| 2026-04-23 | project-owner | Approved | Initial |
