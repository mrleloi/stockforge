---
name: sync-pull
description: On-demand confidence-score lookup before a SCOPE+/ARCH/IMPL decision. Reads agent-workspace/memory/sync-tracker/state.tsv + weights.yaml; surfaces the relevant category's score, tier, must-grill flag, and the decision-class threshold. Output drives "self-decide vs grill" choice. Use whenever an agent is about to commit a non-trivial decision and needs to ground confidence in historical hit rate per Charter Principle 8 (Calibration over confidence).
allowed-tools: [Read, Glob, Grep, Bash]
---

# Skill: sync-pull

## Purpose

Per Charter Principle 8 (Calibration over confidence) + D-006 (Track 8a Confidence Score System): every confidence claim must trace to historical hit rate, not to model "feeling certain". Before committing a SCOPE+/ARCH/IMPL decision, the agent invokes this skill to read the current per-category score from `agent-workspace/memory/sync-tracker/state.tsv` and decide whether to self-decide (above threshold) or grill (below threshold).

This skill is the runtime consumer side of Track 8a; the producer side is `scripts/hooks/sync-tracker-update.sh` which appends events as they happen.

## When to Use

- Pre-flight before authoring a decision file in `agent-workspace/memory/decisions/` (especially level: SCOPE / ARCH).
- Agent is about to choose between AskUserQuestion bundle and self-decide — score check disambiguates.
- Drift detector flags a category; sync-pull reads `must_grill_remaining` to confirm forced-grill state.
- Mid-session "should I keep going or open Q&A bundle?" — sync-pull anchors the call.

## When NOT to Use

- Routine IMPL-tier choice already in flight (overhead cost > value).
- Session is in PLAN mode and decisions are Q&A-driven by spec — sync-pull adds no signal.
- `_index.md` was just rendered same session — read it directly instead of re-invoking.

## Inputs

| Arg | Required | Purpose |
|---|---|---|
| `category` | yes | One of: LANGUAGE / DOMAIN_UBIQUITOUS / DESIGN_THINKING / SCOPE / DECISION_ROUTING |
| `decision_class` | no | One of: CHARTER / SCOPE / ARCH / IMPL. If provided, skill compares score vs that class's threshold and emits explicit "self-decide" or "grill" recommendation. |

## Process

1. **Read state row** — `awk -F'\t' '$1=="<CATEGORY>"' agent-workspace/memory/sync-tracker/state.tsv` returns the row with current_score / sample_count / last_updated_ts / must_grill_remaining.
2. **Read threshold** — if `decision_class` provided, `awk -F': *' '$1=="threshold_<CLASS>"' agent-workspace/memory/sync-tracker/weights.yaml` returns the threshold value.
3. **Apply tier mapping** — score → tier name via `weights.yaml` `tier_*` boundaries (HIGH ≥90 / MED_HIGH ≥70 / MED ≥50 / MED_LOW ≥30 / MUST_GRILL <30).
4. **Apply decision rule**:
   - If `must_grill_remaining > 0`: emit FORCE-GRILL (reversal protocol active per Q&A A6).
   - Else if `decision_class` given AND `current_score < threshold`: emit GRILL.
   - Else: emit SELF-DECIDE-OK with citation note.
5. **Output** — structured single-paragraph readout the agent can paste into its reasoning log.

## Output format

```
sync-pull <CATEGORY> [<DECISION_CLASS>]:
  current_score=<N>/100  (tier: <TIER_NAME>)
  sample_count=<K>  last_updated=<TS>
  must_grill_remaining=<M>
  threshold_<CLASS>=<T>  (for decision_class=<CLASS>)
  recommendation: <SELF-DECIDE-OK | GRILL | FORCE-GRILL>
  reasoning: <one sentence>
```

## Examples

**Example 1 — Pre-flight before SCOPE-tier decision (above threshold)**:
```
sync-pull SCOPE SCOPE
  current_score=92/100  (tier: HIGH-CONFIDENCE)
  sample_count=14  last_updated=2026-04-29T10:33:00Z
  must_grill_remaining=0
  threshold_SCOPE=90
  recommendation: SELF-DECIDE-OK
  reasoning: score 92 ≥ threshold 90; no must-grill flag; safe to self-decide with citation.
```

**Example 2 — Below threshold (grill required)**:
```
sync-pull DECISION_ROUTING ARCH
  current_score=72/100  (tier: MED-HIGH)
  sample_count=22  last_updated=2026-04-29T11:00:00Z
  must_grill_remaining=0
  threshold_ARCH=80
  recommendation: GRILL
  reasoning: score 72 < threshold 80; route via AskUserQuestion bundle.
```

**Example 3 — Reversal protocol active (force grill)**:
```
sync-pull DOMAIN_UBIQUITOUS IMPL
  current_score=48/100  (tier: MED-LOW)
  sample_count=8  last_updated=2026-04-29T12:15:00Z
  must_grill_remaining=4
  threshold_IMPL=50
  recommendation: FORCE-GRILL
  reasoning: must_grill_remaining=4 (reversal protocol active); grill regardless of score until counter reaches 0.
```

## Outputs

The skill writes nothing — it's a read-only lookup. Producer (`scripts/hooks/sync-tracker-update.sh`) is the writer.

If the agent acts on a SELF-DECIDE-OK and later proves wrong, the producer hook fires `decision_correction_-2` event; sync-pull on next invocation will reflect the dropped score.

## Source schema

- D-006 § Decision (canonical schema; bash+TSV substrate per IMPL-S17-1)
- `agent-workspace/memory/sync-tracker/README.md` (layer overview)
- `agent-workspace/memory/sync-tracker/weights.yaml` (tunable thresholds + tier boundaries)

## Anti-patterns

- **Citing "I'm 80% confident" without sync-pull** — Charter Principle 8 violation. Confidence claims must trace to state.tsv or `agent-workspace/calibration/<signal>.md` historical data.
- **Skipping sync-pull on SCOPE/ARCH** — invalidates the calibration loop; correction events will fire later but score won't have grounded the decision in advance.
- **Editing state.tsv by hand** — bypasses the producer hook's event-log discipline. Always emit events via `sync-tracker-update.sh` so the audit trail survives.
