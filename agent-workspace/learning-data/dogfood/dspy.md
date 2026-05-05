---
artifact_id: dogfood-dspy-20260429
created_at: 2026-04-29
session: S12 (Track 5.5d.3)
tool_studied: stanfordnlp/dspy
tool_sha: db83e5ad7154ee2e31f2cdd4f13351ded47a23d3
tool_as_of: 2026-04-29
license: MIT
upstream_url: https://github.com/stanfordnlp/dspy
research_report_ref: agent-workspace/learning-data/dogfood/agent-pick-1-research-report-20260429T131201Z.md
---

# Dogfood Insight — DSPy → StockForge Self-Learning Loop

> Pattern-level extraction (NOT integration). Phase-0 harness is bash + NDJSON; DSPy is Python module framework. The dogfood signal is structural mapping, not execution. Per D-005 § 5.5d.3 + research-scanner agent-pick-1 pick (sha `db83e5ad`, as-of 2026-04-29).

## Setup (what was actually done)

- Survey: 6 candidates scanned by `research-scanner` subagent (S12 dispatch, sonnet, ~50K tokens, 213s wall-clock). DSPy picked over openevals (runner-up); 4 disqualifications. See `agent-pick-1-research-report-20260429T131201Z.md` for full provenance.
- Source-read (this artifact): README header (`stanfordnlp/dspy@db83e5ad/README.md`) + paper title (`DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines`, 2023-10) + scoring matrix in research report. Did NOT clone repo; did NOT pip install; did NOT execute optimizer.

## The one insight (≥1 measurable)

**StockForge's self-learning loop is missing the deterministic metric function that DSPy treats as the load-bearing bridge between signal and improvement.** S11's L-1 classifier (sonnet/medium) produced bucket distributions (0/0/0/49/11) — but emitted **no metric**. Without a metric, no version of the pipeline can be said to be "better" than another. The compile-loop framing collapses without it.

DSPy's pattern (verbatim from research-report § 1):
> "DSPy optimizer requires a `metric` function that returns a score from deterministic code — the LLM does not score itself."

Mapped onto StockForge's loop:

| DSPy concept | StockForge counterpart | Status today |
|---|---|---|
| `dspy.Module` (LLM-call wrapper) | Hook script + LLM dispatch + telemetry emit | EXISTS (component-telemetry.sh + Agent dispatches) |
| Labeled examples | Sessions × (action taken, retrospective verdict) | PARTIAL (sessions logs exist; verdicts tagged informally in agent-notes) |
| **Metric function (deterministic)** | **MISSING — S11 L-1 has buckets but no scalar/categorical "this run was better than last"** | **GAP** |
| Optimizer (BootstrapFewShot, MIPROv2, COPRO) | promote-rule skill + future try-n-approaches | PARTIAL (promote-rule ships; try-n-approaches S13) |
| Compiled improved pipeline | Updated capability-map + new hook/skill/charter rule | PARTIAL (cap-map updates manual today) |

**The measurable consequence**: until a metric exists, the Karpathy outer-loop framing artifact (also S12 deliverable) cannot answer "was this experiment better than the prior baseline?" — it can only describe what was tried, not what was earned.

### Concrete metric candidates for StockForge (≥1 must be picked at S13)

Per DSPy's discipline that the metric function is **deterministic Python** (no LLM math), candidate metrics for StockForge's loop:

1. **failure_mode population rate** (deterministic): `count(events where failure_mode != null) / count(events total)`. Today: 0/60 = 0% (per S11 L-1 categories file). After fix to `correlate_failure_mode()` wire-in: target ≥ 5% on next 60-event corpus. Falsifiable, code-computed, no LLM judgment.

2. **drift signal precision** (deterministic, requires labels): for each D1-D9 fire, was a corrective action taken in the next 3 sessions? `count(D-fire with subsequent fix) / count(D-fire total)`. Requires lightweight labeling protocol (1 sentence per D-fire in session log).

3. **Promotion-candidate hit rate** (deterministic, longitudinal): of the 5 components flagged promotion-candidate at S11 (Read, Bash, TaskUpdate, Edit, Write), how many become formally promoted to skill/hook within 3 sessions? `count(promoted) / count(flagged)`. Today: 0/5 = 0% (none promoted yet). Target after S15 (Track 7): ≥ 1.

4. **Re-classification stability** (deterministic, regression metric): re-run L-1 on the same 60-event corpus with the next-month classifier. Compare bucket distribution. Drift > 10% across runs = classifier regression signal.

These are the kind of metrics DSPy's pattern enforces: the metric function returns a number from code, the LLM never grades itself.

## What was rejected from DSPy

Per research report adversarial bear point #4 ("LLM-as-judge risk in optimizer"): **adopt DSPy's metric-function pattern only; reject MIPRO-style LLM-instruction-generation optimizers for now.** MIPRO uses an LLM to propose candidate instructions inside the optimization loop — that re-introduces LLM math into a path the charter (P9) explicitly forbids. StockForge's first dogfood adoption is structural (the pattern of a deterministic bridge between signal and improvement), not infrastructural (running DSPy modules in the harness).

## Bear-case awareness for downstream sessions

From research report adversarial section, ≥3 risks transfer to dogfood adoption:

- **Frontier-model substitution (6-12 months)**: as Claude 5/Sonnet 5 generalize from minimal examples natively, prompt-optimization patterns may shrink in marginal value. Re-evaluate metric-function adoption value at next major model bump. Not blocking now.
- **Abstraction mismatch (current)**: bash + NDJSON ≠ Python `dspy.Module`. Translation tax is real. Mitigation here: extract pattern (deterministic metric function), not infrastructure (DSPy package itself).
- **Stanford research governance**: DSPy is Stanford Future Data Systems lab; PhD-driven, not production-feedback-driven. Last 5 commits are docs/CI (per research report). If lab graduates → fork/maintenance risk. Mitigation: stockforge depends on the *idea* (metric function), which is portable across any future framework.

## Decision (S12 closes with this)

**Adopt**: DSPy's deterministic-metric-function pattern as the missing piece between L-1 classification (S11 ship) and try-n-approaches outer loop (S13 plan).

**Defer**: Direct DSPy infrastructure adoption. No `pip install dspy`. No `dspy.Module` wrappers. No MIPRO. Phase 0 harness stays bash + NDJSON.

**Surface to capability-map**: NEW task_class candidate `tool-survey` (proven by this S12 first dogfood — research-scanner agent + ≤5-page report + adversarial bear case + provenance log = repeatable pattern).

**Surface to agent-notes**: NEW rule on metric-function-required-before-loop-claims (see § Promotion path below).

## Promotion path (closes loop per D-005 § 5.5d.3 success criterion #4)

This dogfood produces ≥1 promotable rule:

> **Rule candidate**: Any "self-learning" or "Karpathy outer-loop" claim made by stockforge (now or future) MUST be backed by a deterministic metric function (Python or bash, no LLM judgment) before the claim counts as substantiated. If no metric → describe the experiment, do NOT claim improvement.

Promotion target priority (per Q-E3 queued-grill answer template hook>skill>charter, cheapest first):
- **Hook**: `scripts/hooks/learning-loop-metric-check.sh` — scans `learning-data/loop/*-experiment-frame.md` for missing `metric_function:` frontmatter field; soft-warn at Stop hook. Cheapest enforcement.
- **Skill**: extend `try-n-approaches` (S13) to require metric-function arg before allowing deepen/broaden/abandon framing.
- **Charter**: amend `agent-workspace/constitution/financial-data-protocol.md` § Calibration with explicit "no metric → no improvement claim" line. Most expensive; reserve for if hook+skill insufficient.

Final promotion target chosen by S13 promote-rule pass once corpus has ≥3 supporting instances. Today: 1 instance (this dogfood); below promotion threshold; queue + observe.

## Provenance

| Source | URL / Path | SHA / TS | as-of |
|---|---|---|---|
| DSPy README header | https://github.com/stanfordnlp/dspy/blob/main/README.md | `db83e5ad` | 2026-04-29 |
| DSPy paper title | DSPy README references paper "DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines" (2023-10) | n/a | 2026-04-29 |
| Research report (sibling artifact) | agent-workspace/learning-data/dogfood/agent-pick-1-research-report-20260429T131201Z.md | n/a | 2026-04-29 |
| S11 L-1 categories (input data) | agent-workspace/learning-data/index/categories-20260429T123210Z.md | n/a | 2026-04-29 |
| D-005 § 5.5d.3 (deliverable spec) | agent-workspace/memory/decisions/005-up08-track-5.5d-self-learning-pipeline.md | n/a | 2026-04-29 |

## What this insight is NOT

- NOT a recommendation to adopt DSPy as a runtime dependency.
- NOT a measurement of stockforge's current loop quality (no metric exists yet — that IS the insight).
- NOT a license assessment for production use (MIT acceptable for pattern extraction; for code copy-paste, license-header propagation required).
- NOT a stock thesis or financial output. Pure harness-engineering artifact.
