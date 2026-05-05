---
name: try-n-approaches
description: Karpathy autoresearch outer-loop framing — given a task or signal, generate ≥3 distinct approaches (DEEPEN / BROADEN / ABANDON families), pick one per cheap-first ordering, attach a deterministic metric function (per L-S12-1), and write the experiment frame to learning-data/loop/. Use when an open question surfaces from drift / dogfood / sync-grilling and you need to commit a measurable next step. Pairs with decompose-work (deterministic-vs-LLM split per approach) + capability-map (model × effort grounding) + promote-rule (consumes outcomes).
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# Skill: try-n-approaches

## Purpose

Per D-003 § 5.5c.3 + UP-06 §3 (verbatim "kết hợp với idea của karpathy autoresearch") + S12 DSPy dogfood (`learning-data/dogfood/dspy.md`): when stockforge surfaces a question of the form "what should we do next about signal X?", DO NOT pick the first plausible approach. Instead generate ≥3 distinct approach families, evaluate via a deterministic metric, pick the cheapest competent one, and commit a falsifiable measurement plan.

The skill's deliverable is the FRAMING ARTIFACT (one markdown file at `learning-data/loop/<TS>-experiment-frame.md`). Execution of the picked approach happens AFTER framing — by the next session, by a dispatched subagent, or by a deterministic hook. Framing IS the work this skill does.

Consumer of S12 dogfood pattern: per L-S12-1, EVERY framing this skill emits MUST cite a deterministic metric function (formula + baseline + target + falsification clause). No metric → describe the experiment, do NOT claim improvement.

## When to Use

- Drift signal fires repeatedly + agent must decide whether to deepen the fix or pivot
- Dogfood insight surfaces a gap (e.g., S12 DSPy → metric-function gap in stockforge loop)
- Sync-grilling hook surfaces user-vs-current divergence + multiple resolution paths exist
- Capability-map shows ≥3 limit observations clustering on one task class — pick remediation
- Open question in current-execution.md "Current Work Items" tagged as exploratory

## When NOT to Use

- Task is single-path obvious (just do it; framing is overhead)
- Task is purely deterministic (script it; no metric needed)
- Already mid-execution and framing post-hoc would be a postmortem
- Budget-pressured session — framing is upstream work, skip if windowed for IMPL

## Inputs

| Arg | Required | Purpose |
|---|---|---|
| `question` | yes | The open question in 1-2 sentences. Quote verbatim from triggering signal. |
| `--inputs` | yes | Comma-separated paths to source artifacts (drift log / dogfood insight / categories file). Each becomes a `provenance` row. |
| `--n-approaches` | no | Cap on approaches generated. Default `3` (DEEPEN / BROADEN / ABANDON). Range [3,5]. |
| `--metric-function` | yes | Path or inline definition of the deterministic metric. Failing this argument = skill REFUSES per L-S12-1. |

## Process

1. **Parse question** — quote it verbatim. Don't paraphrase yet — paraphrase loses signal in DSPy-pattern terms.
2. **Read inputs** — every `--inputs` path becomes a row in the provenance table with as_of date. Cite source-of-truth not memory.
3. **Identify prior state** — what does the corpus / signal look like RIGHT NOW? Cite numbers from index/categories or last metric run, not from impression.
4. **Generate ≥3 approaches** in three families:
   - **DEEPEN** — instrument the rung that's currently null/under-measured; smallest unit of work that resolves the most caveats
   - **BROADEN** — grow the corpus / sample / coverage; bigger denominator
   - **ABANDON** — drop the bucket / signal / class; admit it's structurally absent
   - For each: action / cost (~tokens, sessions) / why-this / falsification path
5. **Pick one per cheap-first doctrine** (per `decompose-work` heuristic + capability-map L-1/L-2): smallest unit of work that resolves the most caveats AND has a deterministic falsification path. Document why the rejected options are rejected (anti-AP-1 echo chamber).
6. **Attach metric function** (BLOCKING per L-S12-1) — must be deterministic (Python or bash, no LLM judgment) + formula + baseline value with `n_samples` + as_of + target + falsification clause + calibration metadata.
7. **Adversarial bear case** — list ≥3 distinct risks in the picked direction. Apply charter P3 ("adversarial by design") at framing time, not at outcome time.
8. **State what the experiment is NOT** — bound the claim. Per S12 framing pattern: NOT a thesis, NOT a runtime change, NOT optimization, NOT a charter amendment.
9. **Write provenance log** — every cited fact maps to source URL/path + as_of + commit-or-snapshot.
10. **Outcome stub** — frontmatter has `outcome: pending`; later filled at next loop iteration with `decision_at_outcome_review: deepen-confirmed | broaden | abandon`.
11. **Write artifact** — `Write agent-workspace/learning-data/loop/<TS>-experiment-frame.md` per `references/output-template.md`.

## Validation Pre-Conditions

- `--metric-function` is non-empty (else REFUSE — per L-S12-1)
- ≥3 approaches present in DEEPEN / BROADEN / ABANDON families
- Picked direction has a falsification clause (charter P9 + P3)
- ≥3 distinct adversarial risks listed (charter P3)
- Provenance table covers ALL cited facts (charter P1 evidence-grounding)
- Frontmatter `metric_function:` field MATCHES the function in body §Measurement plan

## Best Practices

### L-S13-2 — Cumulative vs Windowed metric distinction

Every metric script MUST support BOTH cumulative (lifetime corpus) AND windowed (last-N events / last-N-sessions) modes. Reason: in the early phase of a corpus, cumulative numbers are dominated by the first few events (high variance per addition); in the steady-state phase, cumulative numbers smooth out but lose recency signal. Both modes are needed.

**Convention**: metric scripts accept `--window N` argument:
- `--window 0` (default) → cumulative since corpus inception
- `--window N` (positive int) → last N events / sessions

**Rationale**: `metric-failure-mode-rate.sh` shipped S13 with cumulative-only; S14 added `--window N` arg per L-S13-2 lesson — early-phase cumulative was misleading (60-event sample dominated by single sessions). Windowed gave usable signal at N=20-30; cumulative caught up at corpus ≥200 events.

**Anti-pattern**: claiming improvement based on cumulative metric movement when the window-shift is the actual cause (a few high-quality recent events drag cumulative up; the underlying generator hasn't improved).

## Anti-Patterns

- **Skipping the metric function** — without it, "self-learning" is vibes; per L-S12-1 the skill REFUSES.
- **Single-approach framing** — if you can only think of one approach, that's a 1-step plan, not a Karpathy loop. Drop the skill; just do the step.
- **Picking DEEPEN by default** — sometimes BROADEN is the right call (corpus too small to detect rare events) or ABANDON is right (signal genuinely absent). Cheap-first ordering MUST consider all three.
- **LLM-generated metric** — metric must be code (Python/bash); LLM proposing a "feel" metric violates I-S1 (no LLM math).
- **Outcome stub left blank** — frontmatter must have `outcome: pending` so the next loop iteration knows to revisit.
- **Confusing "framing" with "execution"** — this skill writes the plan; the plan is executed elsewhere. Don't conflate.
- **Re-doing framing on every signal fire** — once a frame is committed, the next loop iteration UPDATES the existing frame (writes outcome) before generating a new one. Otherwise loop history rots.

## Smoke Test (S13 first run)

Sample question: *"Given the corpus state at S12 close (60 events / 0 failure_mode populated / 5 promotion-candidate components) and the DSPy dogfood insight, what is the next experiment that maximizes information gain per token spent?"*

Expected framing shape (target):
- DEEPEN → wire failure_mode in component-telemetry.sh + author metric script (~100K, 1 session)
- BROADEN → wait 3-4 sessions for 200-event corpus, re-run L-1 (~36K)
- ABANDON → drop drift/retry/mistake-type buckets, simplify L-1 (~20K, 1 session)
- Picked: DEEPEN (3 independent signals converge; BROADEN requires DEEPEN first; ABANDON confuses uninstrumented with absent)
- Metric function: `failure_mode_populated_rate = count(events.failure_mode != null) / count(events)` (baseline 0/60=0%, target ≥8.3%)

This was the actual S12 framing artifact (`learning-data/loop/20260429T131608Z-experiment-frame.md`); the skill formalizes that pattern for future loops.

Pass criteria: skill produces a frame matching template; metric function field non-empty + cited in body; ≥3 approaches with cost-and-falsification; ≥3 bear-points; outcome=pending.

## Output Schema (frontmatter)

```yaml
---
experiment_id: loop-frame-<TS>
created_at: <ISO-8601>
session: S<N> (Track <T>)
framing_decision: DEEPEN | BROADEN | ABANDON
inputs:
  - <path-1>
  - <path-2>
as_of: <YYYY-MM-DD>
metric_function: <path-or-inline-name>     # BLOCKING per L-S12-1
outcome: pending                           # filled at next iteration
---
```

Body sections (mandatory order): Question / Prior state / Three options / Picked direction / Measurement plan / Risks / What this is NOT / Provenance / Outcome.

## See Also

- `agent-workspace/learning-data/dogfood/dspy.md` — pattern source (deterministic metric function as bridge)
- `agent-workspace/learning-data/loop/20260429T131608Z-experiment-frame.md` — first instance + template reference
- `agent-workspace/memory/agent-notes.md § L-S12-1` — metric_function-required rule (BINDING)
- `.claude/skills/decompose-work/SKILL.md` — sibling 5.5c.1; deterministic-vs-LLM split per approach
- `.claude/skills/promote-rule/SKILL.md` — sibling 5.5c.6; consumes loop outcomes for cluster promotion
- `agent-workspace/memory/capability-map.md` — strength/limit grounding for approach scoring
- `scripts/hooks/metric-failure-mode-rate.sh` — first deterministic metric (S13 first instance)
- D-003 § 5.5c.3 + UP-06 §3 — strategic rationale
- charter principles 1 (evidence) + 3 (adversarial) + 8 (calibration) + 9 (no LLM math)
