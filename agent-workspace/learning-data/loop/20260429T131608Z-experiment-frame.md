---
experiment_id: loop-frame-20260429T131608Z
created_at: 2026-04-29T13:16:08Z
session: S12 (Track 5.5d.3)
framing_decision: DEEPEN
inputs:
  - agent-workspace/learning-data/index/categories-20260429T123210Z.md  # S11 L-1 first classification (60 events; 0/0/0/49/11 distribution)
  - agent-workspace/learning-data/dogfood/dspy.md                       # S12 DSPy pattern insight (metric-function gap)
  - agent-workspace/learning-data/dogfood/agent-pick-1-research-report-20260429T131201Z.md  # S12 research-scanner survey
as_of: 2026-04-29
metric_function: scripts/hooks/metric-failure-mode-rate.sh  # authored S13 (Track 5.5c.3 wire-in); first-pass result documented in agent-workspace/learning-data/index/metrics-<TS>.json
---

# Karpathy Outer-Loop Frame — Experiment #1

> First Karpathy autoresearch framing for stockforge harness self-learning. Per D-005 § 5.5d.3
> Phase 7 + UP-08 verbatim "kết hợp với idea của karpathy autoresearch". Pattern from
> `.claude/skills/decompose-work/SKILL.md` (try-n-approaches not yet shipped — S13).

## Question

Given the corpus state at S12 close (60 events / all-ok / no failure_mode populated / 5 promotion-candidate components) and the DSPy dogfood insight (deterministic metric function is the missing bridge), what is the next experiment that maximizes information gain per token spent?

## Prior state — what S11 + S12 produced

**S11 (Track 5.5d.2)**: First L-1 classification dispatch. 60 events. Distribution `0/0/0/49/11` (drift / retry / mistake-type / promotion-candidate / uncategorized). Six adversarial caveats documented; two are load-bearing for this framing:

- Caveat #1: drift bucket may be structurally undercount — `component-telemetry.sh` may not emit on denied tool calls.
- Caveat #2: `failure_mode` field is null on 60/60 events — possibly uninstrumented, not falsified.

**S12 (Track 5.5d.3)**: Agent-pick-1 dogfood. DSPy picked. Pattern insight: stockforge has a self-learning loop with no metric function — without a deterministic scalar/categorical comparing run N+1 to run N, no version of the pipeline can be claimed "better than" another.

## Three options on the table

### Option A — DEEPEN (instrument the missing rungs)

**Action**: Wire `failure_mode` field population in `component-telemetry.sh` from `correlate_failure_mode()` already drafted in `.autonomous-stop-watchdog.log` reads. Then author **one** deterministic metric function (the `failure_mode population rate` from dogfood/dspy.md § metric candidates) and re-run L-1 on a fresh ≥60-event corpus to compare.

**What it costs**: ~1 hook-edit session (~30-50K). One metric script (~30 LOC bash or python). One re-dispatch of L-1 classifier (~36K, observed cost from S11). Estimated total: 1 session ≤100K. Fits S13/S14 alongside try-n-approaches ship.

**Why this option**: Two highest-confidence caveats from S11 (drift undercount + failure_mode null) both resolve via the same fix path. The DSPy dogfood ALSO points to the same gap (metric function). Three independent signals (S11 caveat #1, caveat #2, DSPy insight) converging on one fix = strong deepen prior.

**What we measure** (explicit, falsifiable):
- Metric: `failure_mode_populated = count(events where failure_mode != null) / count(events total)`
- Baseline (S11): 0/60 = 0.0%
- Target (S12+1): ≥ 5/60 = 8.3% on next 60-event corpus
- Falsification: if after instrumentation, the rate is still 0% AND no failures occurred = harness too stable to instrument; loop signal exhausted; PIVOT to Option B (broaden corpus to find rare events). If rate ≥ 8.3% = instrumentation works; advance to second metric (drift signal precision).

### Option B — BROADEN (grow the corpus)

**Action**: Increase corpus from 60 events to 200+ before next L-1 dispatch. Currently events accumulate naturally per session (~30-60 events per major session per S11 observation). Wait 3-4 sessions and re-run L-1.

**What it costs**: 0 token cost in new sessions (events emit free); 1 re-dispatch (~36K).

**Why this option might be tempting**: bigger corpus = more statistical power for rare-event detection (the <5% pattern blind-spot from S11 caveat #5).

**Why this option is wrong now**: at 0% failure_mode population, broadening to 200 events still yields 0/200 — adding null data doesn't improve signal. Broaden is the right move AFTER instrumentation fix; before fix, it just delays the same problem.

### Option C — ABANDON (delete the zero-signal buckets)

**Action**: Delete drift / retry / mistake-type categories from L-1 spec; keep only promotion-candidate + uncategorized. Acknowledge harness is too clean to have negative signal worth tracking at Phase 0 scale.

**Why this option might be tempting**: simpler classifier; no instrumentation work needed.

**Why this option is wrong**: it confuses "field uninstrumented" with "signal absent". S11 caveat #2 explicitly noted: "`mistake-type` and `drift` buckets are not falsified — they are simply uninstrumented." Abandoning a bucket because the field hasn't been wired = closing the loop on negative information that may exist. Charter principle 3 (adversarial by design) prefers asking "is the absence real" over "assume absence is real".

## Picked direction — DEEPEN (Option A)

Rationale: convergence of 3 independent signals on the same fix; Option B requires Option A first; Option C confuses uninstrumented with absent (charter P3 violation).

Cheap-first ordering doctrine satisfied: A is the smallest unit of work that resolves the most caveats per token spent.

## Measurement plan (explicit; this is the metric function S13 will codify)

```
metric: failure_mode_populated_rate
formula: count(events where failure_mode IS NOT null) / count(events total)
implementation: bash + python3 oneliner in scripts/hooks/learning-index-rebuild.sh
                (extend existing hook; do NOT add new infra)
baseline:    0.0% (S11 corpus, n=60, observed 2026-04-29)
target:      >= 8.3% (S12+1 corpus, n>=60, observed at first L-1 re-dispatch)
falsification: if rate < 8.3% AND no failures occurred in the corpus window
               (deterministically: count(.autonomous-stop-watchdog.log entries) > 0
                vs count(events with failure_mode != null) — if log shows failures
                but events show null, instrumentation fix was incomplete)
calibration:   record n_samples + lookback_window in result; per charter P8
```

This metric is **deterministic** (counts, no LLM judgment), **falsifiable** (specific threshold), **calibration-aware** (records sample size + lookback per L-2), and **cheap** (extends an existing hook; no new dependency). Matches DSPy's metric-function pattern as adapted in dogfood/dspy.md.

## Risks (≥3 distinct, per charter P3 adversarial)

1. **Failure mode classifier drift**: if `correlate_failure_mode()` is buggy (e.g., over-classifies stop-watchdog entries as failures), the rate will jump artificially. Mitigation: smoke-test the function with `LEARNING_INDEX_FORCE=1` on known events before declaring the metric trusted.

2. **Corpus window mismatch**: 60 next events may span a heavily-IMPL session (high tool counts, mostly ok) or a heavily-PLAN session (lower tool counts, more decision points). Distribution variance vs prior corpus could swamp the instrumentation signal. Mitigation: log session_type per event in next telemetry pass; segment corpus by type at L-1 time.

3. **Premature optimization**: focusing on metric authoring before second L-1 baseline run could lead to over-fitting to S11's specific blind spots. Mitigation: don't promote the metric function to charter (Track 7) until ≥3 corpus runs confirm the rate trends in interpretable directions.

4. **Frontier-model substitution risk on classifier**: by S13, sonnet-4.6 may be replaced by sonnet-5; classifier output distribution may shift even on the same corpus. Mitigation: lock classifier model + effort in `categories-<TS>.md` frontmatter (S11 already does this — `classifier_model: sonnet`, `classifier_effort: medium`). Compare runs at same model version; flag cross-version comparisons explicitly.

## What the next experiment is NOT

- NOT a thesis on stocks. Pure harness-engineering loop.
- NOT a request to ship a new skill or hook this session — the framing IS the artifact; the wiring + metric function is S13's work (per current-execution.md sequence).
- NOT a claim that DSPy itself will be adopted. Only its metric-function pattern is borrowed.
- NOT optimization of any frontend / runtime path. Background analysis loop only.

## Provenance

| Source | Path | as-of |
|---|---|---|
| S11 L-1 first classification | agent-workspace/learning-data/index/categories-20260429T123210Z.md | 2026-04-29 |
| S11 session log (caveats #1+#2 origin) | agent-workspace/memory/sessions/2026-04-29-session-11.md § L-1 dispatch | 2026-04-29 |
| S12 DSPy dogfood insight | agent-workspace/learning-data/dogfood/dspy.md | 2026-04-29 |
| S12 research-scanner report | agent-workspace/learning-data/dogfood/agent-pick-1-research-report-20260429T131201Z.md | 2026-04-29 |
| D-005 § 5.5d.3 | agent-workspace/memory/decisions/005-up08-track-5.5d-self-learning-pipeline.md | 2026-04-29 |
| Charter principles 1, 3, 8, 9 | PROJECT_CHARTER.md | 2026-04-29 |
| Capability-map L-1 (no LLM math) + L-2 (calibration metadata) | agent-workspace/memory/capability-map.md | 2026-04-29 |

## Outcome (filled S13 close — partial verdict)

- next_dispatch_target: S13 ✅ (Track 5.5c.3+4+5 shipped 2026-04-29)
- expected_corpus_at_next_l1: 100-150 events → ACTUAL: 100 sample / 337 cumulative at S13 close
- L1_re_dispatch_artifact: agent-workspace/learning-data/index/categories-20260429T135205Z.md (S13 first re-classification)
- bucket_distribution_observed: drift=1, retry=1, mistake-type=0, promotion-candidate=93, uncategorized=5 (vs S11 baseline 0/0/0/49/11=60)
- failure_mode_populated_rate_observed:
    cumulative: 2/337 = 0.59%
    sample-windowed: 2/100 = 2.0%
    natural-corpus: 0/98 = 0.0% (per L-1 dispatcher: both populated events are S13 smoke-test injections; tokens_real=0+duration_ms=0 fingerprint discriminates synthetic from natural)
- decision_at_outcome_review: **DEEPEN-confirmed-structurally** (wire-in works; failure_mode populates from null when conditions met). **MEASUREMENT-deferred** (target ≥8.3% awaits natural failure accumulation; smoke synthetics excluded per L-S13-2 — see agent-notes 2026-04-29 § L-S13-2). Re-measure at S14+ with `--window N` for windowed comparison vs S11 baseline 0/60.
- falsification_status: PARTIAL FIRE — instrumentation no longer deterministically zero (smoke confirms wire-in); BUT natural failure rate is still effectively zero. Per S12 framing § Risks point #1 the discriminator works, so the metric is uncontaminated for natural-failure measurement when natural failures accumulate.
- next_loop_iteration: S14 close re-measure with --window N=60 over post-wire-in natural events ONLY (filter `tokens_real != 0` to exclude smokes); compare to baseline 0/60.

---

*Generated S12 closing. Author: claude-opus-4-7. Per UP-08 directive 'thêm sớm' (early instrumentation enables later measurement).*
