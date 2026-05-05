---
id: D-026
title: S43e charter-promote bundle — C1 architecture LLM substrate boundary + C2 decision-discipline Rule 4b
status: ACCEPTED
tier: CHARTER
date_proposed: 2026-05-04
date_ratified: 2026-05-05
ratified_by: Project owner — explicit AskUserQuestion ACCEPT picks (S43f autonomous-resume turn)
ratifying_session: S43f (S43e checkpoint handoff continuation; date rolled 2026-05-04 → 2026-05-05)
authoring_agent: Claude Opus 4.7
supersedes: none
superseded_by: none
source_evidence:
  - agent-workspace/proposals/architecture-amendment-C1-llm-substrate-boundary.md  # C1 draft (S43e continuation 4)
  - agent-workspace/proposals/decision-discipline-amendment-rule-4b.md  # C2 draft (S43e initial turn)
  - agent-workspace/memory/observations/promote-rule-S43c.md § Cluster C1 + Cluster C2
  - AskUserQuestion (S43f turn) — 4-question bundle; Q1=ACCEPT (C1), Q2=ACCEPT (C2)
  - agent-workspace/memory/self-awareness/known-issues.md § KI-S43b-1/2/3, KI-S35-5, KI-S43b-5
  - agent-workspace/memory/self-awareness/best-practices.md § BP-S43b-1/2/3, BP-S35-1, BP-S43b-4
  - agent-workspace/memory/agent-notes.md § L-S43b-7
  - agent-workspace/constitution/decision-discipline.md § Rule 1 (charter-tier explicit pick required, Q-B2)
options_considered:
  - A: ACCEPT both as bundled deny-lift cycle (chosen)
  - B: ACCEPT C1 only, REJECT C2 (rejected — would leave Stage 2 dormancy hot per L-S43b-7)
  - C: REJECT both (rejected — patterns continue rotting; KI-S43b-5 baseline 9-session dormancy reasserts)
chosen_option: A
---

# D-026 — S43e charter-promote bundle (C1 + C2)

## Summary

Two charter-tier amendments ratified in a single deny-lift cycle:

- **C1**: appended new "LLM Substrate Boundary" subsection to
  `agent-workspace/constitution/architecture.md` between current LLM block and
  Frontend block. ~24 LOC including header + 3 BP-S43b-* mitigation references
  + 3 KI-S43b-* failure-mode catalog cross-refs.
- **C2**: appended Rule 4b "Lesson-synthesis mandatory at session-end" to
  `agent-workspace/constitution/decision-discipline.md` § Rule 4 region (after
  Rule 4a, before Rule 5). 5 trigger gates (a-e) + paired hook upgrade flipping
  `scripts/hooks/lesson-synthesis-watchdog.sh` from advisory (exit 0) to strict
  (exit 2 on dormancy branch).

## Why bundled

Per C1 proposal "Bundling opportunity" + C2 sibling-cluster context: same
deny-lift cycle (single settings.json deny-rule lift + restore) covers both
charter file edits. Reduces ceremony cost from 2 cycles → 1. Q-B2 § "bundling
CHARTER with sub-charter" anti-pattern does NOT apply because both items are
themselves CHARTER-tier — there is no tier mixing.

## Ratification chain

1. Phase 2 close S43e identified C1 + C2 as charter-tier work needing user-gate
   (per L-S15-1: rules reshaping self-upgrade-loop identity / architectural
   substrate boundary are charter-tier; cannot self-decide).
2. S43e initial turn drafted C2 (`proposals/decision-discipline-amendment-rule-4b.md`).
3. S43e continuation 4 drafted C1 (`proposals/architecture-amendment-C1-llm-substrate-boundary.md`).
4. S43f (this turn, 2026-05-05) bundled both into single 4-question
   AskUserQuestion poll (Q1=C1, Q2=C2, Q3=Phase 3 SCOPE, Q4=DEFER-S43b-2).
5. User ACCEPT/ACCEPT for Q1+Q2 → this ADR authored as ratifying record.

## Implementation manifest

**Charter edits** (deny-lift required + restored same turn):
- `agent-workspace/constitution/architecture.md` — +25 LOC new subsection
  "LLM Substrate Boundary" + ratification footer pointing to D-026
- `agent-workspace/constitution/decision-discipline.md` — +33 LOC new Rule 4b
  + ratification footer pointing to D-026

**Hook upgrade** (already permission-allowed under Edit(scripts/**)):
- `scripts/hooks/lesson-synthesis-watchdog.sh` — header docstring updated to
  STRICT mode language; alert branch now `exit 2` (was fall-through `exit 0`);
  alert message references "STRICT-ALERT (D-026 Rule 4b)"

**Permission ceremony** (S38 deny-lift mechanism):
- `.claude/settings.json` deny rules `Write(agent-workspace/constitution/**)`
  and `Edit(agent-workspace/constitution/**)` were temporarily removed for the
  duration of the C1+C2 charter edits, then restored same-turn. Permission
  posture is unchanged net of this ratification (deny rules present pre-S43f
  and present post-S43f — only momentarily lifted for the audited edit window).

**Proposal closure** (status tracking):
- `agent-workspace/proposals/architecture-amendment-C1-llm-substrate-boundary.md`
  — frontmatter `status: PROPOSAL` → `status: ACCEPTED`; ratification record
  appended pointing to this ADR.
- `agent-workspace/proposals/decision-discipline-amendment-rule-4b.md` —
  frontmatter `status: PROPOSAL` → `status: ACCEPTED`; ratification record
  appended pointing to this ADR.

## Provenance citations

- **C1 mitigations** (BP-S43b-1/2/3 already shipped as production code):
  - `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:47` — role_model_overrides
  - `packages/infrastructure/analysis/subagent_transport.py:55-118` — 3-tier JSON extractor
  - `apps/_shared/use_case_builder.py::_build_subagent_agents` — gatherer-wired compute
- **C2 enforcement target** (lesson-synthesis-watchdog.sh) — Stop hook priority 2
  in `.claude/settings.json` Stop chain; deployed since S35.

## Trade-offs accepted

| Concern | Acceptance rationale |
|---|---|
| **architecture.md grows ~25 LOC** | Single canonical reference for substrate-boundary patterns is cheaper than discovery-via-grep across best-practices.md (long-lived append-only file). |
| **Rule 4b strict-mode hard-blocks Stop hook** | Loop is finite (≤1 per episode); next session writing any KI/BP/agent-notes entry within 24h clears the alert. |
| **Permission ceremony cost** | Bundled cycle = 1 lift+restore for both files; sets precedent for future bundled charter promotes (efficiency precedent). |

## Companion handoff

Phase 3 master-plan (next PLAN session per CLAUDE.md never-mix) MUST honor
both ratified rules:
- Architecture.md § "LLM Substrate Boundary" governs any future LLM-perspective
  adapter (KOL summarization, news classification, pump narrative detection).
- Rule 4b governs every Phase 3 session that produces any of the 5 trigger gates.

## Drift watch

- D9 charter md5: CHANGED (intentional; ratified). Update baseline to current.
- D-INTENT: ALIGNED (C1 + C2 are exact ACCEPTED options from user pick).
- DR-PROV: this ADR cites both proposals + KI/BP/L source evidence + hook reference.

---

## Ratification record

User explicit ACCEPT/ACCEPT via AskUserQuestion bundle (S43f turn 2026-05-05).
No amendments requested. Both proposals shipped verbatim.
