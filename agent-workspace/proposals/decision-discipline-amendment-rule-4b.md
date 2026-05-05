---
proposal_id: decision-discipline-amendment-rule-4b
title: Decision-discipline Rule 4b — Lesson-synthesis mandatory at session-end (charter-tier amendment draft)
status: ACCEPTED
draft_date: 2026-05-04
draft_session: S43e
authoring_agent: Claude Opus 4.7
target_charter_file: agent-workspace/constitution/decision-discipline.md
gating: USER-EXPLICIT-PICK-REQUIRED (per Q-B2 charter-tier rule + L-S15-1)
provenance:
  promote_rule_observation: agent-workspace/memory/observations/promote-rule-S43c.md § Cluster C2
  source_rules:
    - KI-S35-5  # 15-session promote-skip
    - BP-S35-1  # 5-session-or-phase-boundary
    - KI-S43b-5  # 9-session lesson-synthesis dormancy
    - BP-S43b-4  # lesson-synthesis mandatory
    - L-S43b-7   # Lesson-Synthesis Stage 2 Of Self-Upgrade Loop Has No Agent
  related_hooks_already_deployed:
    - scripts/hooks/lesson-synthesis-watchdog.sh  # advisory mode (HR-1)
    - scripts/hooks/promotion-cycle-trigger.sh    # delta-since-last hard-block at 5+
    - scripts/hooks/harness-recovery-dod-watchdog.sh  # premature-stop sentinel
    - scripts/hooks/memory-routing-audit.sh        # HR-4 routing-tree
    - scripts/hooks/pre-clear-handoff-guard.sh     # HR-2 / HR-7
---

# Proposal: Decision-discipline Rule 4b — Lesson-synthesis mandatory at session-end

> **Status**: DRAFT — proposed for charter ratification at user discretion.
> **Tier**: CHARTER (per L-S15-1: any rule reshaping self-upgrade-loop identity is charter-tier).
> **Required action**: User explicit letter pick per Q-B2 closure (charter/SCOPE-tier MUST require explicit accept; default-acceptance prohibited).

## Why this rule exists

The self-upgrade loop (Karpathy outer-loop / decision-discipline § Rule 4) requires
that lessons learned in real sessions feed back into KI-* / BP-* / agent-notes
entries, which then promote up to hooks / skills / charter via Rule 4 (5-session OR
phase-boundary). Empirically, Stage 2 (the *write-the-lesson-down* step itself) has
been the dormancy hotspot:

- **S20 → S35**: 15 sessions elapsed before promote-rule fired (KI-S35-5).
- **S26 → S43b**: 9 sessions elapsed before lesson-synthesizer ran (KI-S43b-5).
- **L-S43b-7**: cataloged the failure mode — "Stage 2 of Self-Upgrade Loop Has No Agent".

Stage 1 (rule-discovery during work) is implicit in good engineering. Stage 2
(rule-recording) is the bottleneck. Without a deterministic rule forcing it,
sessions complete without synthesizing learnings, the corpus stagnates, and
promote-rule cycles surface a thin set of stale candidates.

## Proposed amendment text

Append to `agent-workspace/constitution/decision-discipline.md` § Rule 4 region:

```markdown
### Rule 4b — Lesson-synthesis mandatory at session-end

Every session whose work produces ANY of the following triggers MUST append at
least one new entry to `agent-workspace/memory/self-awareness/known-issues.md`
OR `agent-workspace/memory/self-awareness/best-practices.md` OR
`agent-workspace/memory/agent-notes.md` BEFORE the checkpoint `latest.md` is
written:

  (a) ≥1 user correction (verbatim or paraphrased)
  (b) ≥1 deferred-fix item (R-N / DEFER-S*-N)
  (c) ≥1 substrate gap discovered (hook missing, contract unenforced, etc.)
  (d) ≥1 charter-tier or SCOPE-tier decision authored
  (e) ≥1 META_LOOP recovery action

The entry MUST cite at minimum: (i) verbatim trigger evidence; (ii) the rule it
codifies; (iii) anti-example (what the rule prevents); (iv) auto-detect path
(hook / skill / charter). Sessions producing zero triggers (e.g., rote refactor
sessions) are exempt and SHOULD record `lesson_synthesis: NA-no-triggers` in
their session log.

**Enforcement** (paired hook upgrade):
  - `scripts/hooks/lesson-synthesis-watchdog.sh` is promoted from advisory
    (current default) to STRICT mode (exit 2 on dormancy detection).
  - Strict mode auto-clears once the next session writes a qualifying entry.
  - Loop is finite: ≤1 hard-block per dormancy episode.

**Cross-references**: KI-S35-5, BP-S35-1, KI-S43b-5, BP-S43b-4, L-S43b-7.
**Supersedes**: nothing (additive to Rule 4).
**Companion**: Rule 4 promote-rule cadence remains 5-session OR phase-boundary;
this rule shortens the *upstream* feedback latency that feeds Rule 4.
```

## Why charter-tier (not skill, not just hook)

Per Q-E3 promotion priority (closed S15) — hook FIRST, skill SECOND, charter LAST.
This proposal lands at charter because:

1. **The hook already exists** (`lesson-synthesis-watchdog.sh`) but is advisory-only.
   Promoting it to strict-mode requires a charter-tier rule to cite as authority.
2. **The pattern reshapes self-upgrade-loop identity** — it codifies *that* the loop
   has a Stage 2 obligation, not merely *how* to enforce it. That's identity-level
   (per L-S15-1 charter-split rule).
3. **Skill insufficient** — this is a discipline rule, not a procedure. There is no
   sequence of LLM-judgment-required steps; the rule is "write or be blocked".

## Trade-offs

| Concern | Mitigation |
|---|---|
| **False-positive blocks on rote sessions** | Exemption clause `lesson_synthesis: NA-no-triggers` + 5 explicit trigger gates (a)-(e); rote refactor sessions self-attest exemption. |
| **Verbose KI/BP corpus growth** | Rule 4 promote-rule cadence (5-session OR phase-boundary) prunes via cluster-and-promote; growth pressure is already balanced by demote pressure. |
| **Strict-mode hard-block surprise** | Loop is finite (≤1 per episode); exit 2 surfaces stderr to assistant transcript per HR-7 pattern; agent writes entry → next Stop auto-clears. |
| **Watchdog itself dormant** | Hook is in `.claude/settings.json` Stop chain priority 12 (already deployed); strict-mode upgrade is a 1-line change in the script. |

## Failure modes if NOT ratified

- Recurrence: 6+ sessions of dormancy expected within next phase based on KI-S43b-5
  empirical baseline.
- Compounding: stale promote-rule candidate pool → low-quality cluster proposals →
  stale charter → meta-loop trust loss (per L-S43b-10 premature-stop family).

## What ratification looks like (for the user)

If the user picks "ACCEPT":
1. Agent moves this file to `agent-workspace/constitution/decision-discipline.md` via
   the S38 deny-lift mechanism (charter-edit gate).
2. Agent appends the amendment text verbatim under § Rule 4 region.
3. Agent flips `lesson-synthesis-watchdog.sh` from advisory to strict (1-line edit:
   `exit 0` → `exit 2` on dormancy branch).
4. Agent authors `D-NNN-decision-discipline-rule-4b-ratified.md` ADR with
   approval_chain pointing to the user pick.

If the user picks "REJECT":
1. Mark this proposal `status: REJECTED` with reason.
2. Continue advisory-mode watchdog indefinitely.
3. Re-propose only if BP-S43b-4 violation recurs ≥3× within next phase.

If the user picks "AMEND":
1. User specifies which clause to change.
2. Agent revises this proposal; re-presents.

## Related open proposals (sibling-cluster context)

- `proposals/architecture-amendment.md` — adjacent self-upgrade-loop articulation.
- `proposals/session-budgets-amendment.md` — sibling discipline rule on token budgets.

## Ratification record

**ACCEPTED** 2026-05-05 (S43f turn) via AskUserQuestion bundle Q2=ACCEPT.
Charter edit applied to `agent-workspace/constitution/decision-discipline.md`
§ Rule 4 region (after Rule 4a, before Rule 5). Paired hook
`scripts/hooks/lesson-synthesis-watchdog.sh` flipped advisory→strict same turn.
Bundled with C1 in single deny-lift cycle.
Ratifying ADR: `agent-workspace/memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md`.
