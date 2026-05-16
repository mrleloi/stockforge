---
id: D-065-theme-g-i-s1-1-ratification
title: Theme G I-S1-1 (Numeric-Field Discipline) ratification
date: 2026-05-16
status: ACCEPTED
level: CHARTER-adjacent (constitution-tier; documents Q-INT-2026-05-6 follow-through)

author:
  - "Claude Sonnet 4.6 (sandwich-dev S336)"

source_evidence:
  - path: "agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md"
    section: "§ 5.2 (Theme G intent + sub-rule hypothesis) + § 6.3 (Phase C charter/constitution decision) + § 7.8 (AP-23 red-flag refinement-of-rule check) + § 8 Q-INT-2026-05-3 (original ratification question)"
    quote: "Theme G: I-S1-1 sub-rule for schema-layer numeric discipline — promotes I-S1 to enforcement at type-system level"
  - path: "agent-workspace/memory/decisions/061-wave-1-integration-ratification.md"
    section: "§ Decision item 5 (I-S1-1 GENUINE-new CONFIRMED) + § Decision item 6 (Theme G recommended path = constitution write) + § Open Questions Q-INT-2026-05-6"
    quote: "Theme G recommended path = constitution write in agent-workspace/constitution/financial-data-protocol.md (path B per master plan Q-INT-2026-05-3 option B) — faster than charter v1.1 → v1.2 amendment; requires explicit human-approve gate per CLAUDE.md hard rule; AP-23 promote trigger satisfied."
  - path: "agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md"
    section: "§ G.1 Theme G intent + § G.2 5-row empirical confidence-field survey + § G.3 final architectural recommendation (Path B) + § G.4 Phase C IMPL slot + Phase F-prime sequencing dependency + § G.5 charter-compliance check + AP-23 trigger"
    quote: "5-row empirical survey confirms 3 anti-pattern instances (ai-hedge-fund, TradingAgents, TradingAgents-CN) + 2 counter-examples (FinceptTerminal NotifLevel, Vibe-Trading confidence=low)."
  - path: "agent-workspace/memory/observations/master-planner-A-{01,04,13,14,15}-deepdive-*.md"
    section: "A-01 (ai-hedge-fund) § 5 + § 7 R3 confidence-self-report anti-pattern; A-04 (FinceptTerminal) § 7.3 NotifLevel enum counterexample; A-13 (TradingAgents) § 7.4 entry_price/price_target audit point; A-14 (TradingAgents-CN) § 3.10 + § 7.5 mandatory-LLM-numeric-emit pattern; A-15 (Vibe-Trading) § 3 C5 deterministic confidence=low counterexample"
    quote: "TradingAgents-CN trader.py:68-80 — explicit 强制要求提供具体数值 mandating LLM-emitted confidence + risk score: most aggressive LLM-emit pattern found in Phase A."
  - path: "human-workspace/q-and-a/answered/qa-2026-05-15-wave-1-bis.md"
    section: "line 32: Q-INT-2026-05-6 answer"
    quote: "Q-INT-2026-05-6: A (constitution write in agent-workspace/constitution/financial-data-protocol.md extension; Phase C S333 PLAN + S334 human-approve gate)"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 30

options_considered:
  - id: A
    summary: "Charter amendment v1.1 → v1.2 (Path A per S335 proposal)"
    pros:
      - "Maximum visibility — every agent loads charter"
      - "Version-bump signals a meaningful change"
    cons:
      - "48h cool-down per Revision Protocol delays Phase F-prime IMPL"
      - "Over-engineering: sub-rule operationalizing existing Principle 9 doesn't warrant charter rev"
      - "D-056 precedent shows Path B is the lighter correct mechanism for rule-level additions"
  - id: B
    summary: "Constitution write in financial-data-protocol.md + companion I-S1-1 alias in invariants-stockforge.md (Path B per S335 proposal — RECOMMENDED)"
    pros:
      - "Faster: no cool-down (constitution-tier, not charter-tier)"
      - "Right specificity tier: rule-level prose belongs in financial-data-protocol.md alongside Rules 1-15"
      - "Companion I-S1-1 invariant alias ensures discoverability via invariants index"
      - "Precedent: D-019 (Rule 11), D-021 (Rules 12-15) both used this path without charter cool-down"
    cons:
      - "Less visible than charter; mitigated by I-S1-1 invariant alias + planned hook"
  - id: C
    summary: "Skip — don't codify I-S1-1 (Path C per S335 proposal)"
    pros: []
    cons:
      - "Discards Phase A empirical evidence (3 anti-pattern instances documented)"
      - "AP-23 retire-without-evidence: charter rule mandates promote-or-retire, not can-kick"
      - "Phase F-prime Theme H IMPL schemas inherit LLM-emit numeric fields with no rule guard"
  - id: D
    summary: "Re-architect — different scope or file home (Path D per S335 proposal)"
    pros:
      - "Option if the scope of I-S1-1 is considered wrong"
    cons:
      - "Burns session budget for re-PLAN with no new evidence"
      - "defer_cycles inflation toward R7 threshold"

chosen: B
chosen_rationale: |
  Path B is the correct specificity tier for a sub-rule operationalizing Charter Principle 9
  at the schema layer. D-021 and D-019 establish the precedent: rule-level additions to
  financial-data-protocol.md use the constitution-write path (explicit human approval gate
  without 48h cool-down). The companion I-S1-1 alias in invariants-stockforge.md provides
  discoverability. Path A's 48h cool-down would unnecessarily delay Phase F-prime.
  Path C violates AP-23 (2nd refinement-of-rule triggers promote-or-retire, not skip).

approval_chain:
  - actor: "Claude Opus 4.7 (master-planner subagent, S325)"
    action: PROPOSED (Q-INT-2026-05-6 queued)
    at: 2026-05-15
    via: "D-061 § Decision item 6 + § Open Questions Q-INT-2026-05-6"
  - actor: user
    action: ACCEPTED (Q-INT-2026-05-6 = A)
    at: 2026-05-15T15:30+07:00
    via: "chat blanket-A: 'approved all your recommendation for all pendings item' — recorded D-061 § approval_chain"
    picks: "Q-INT-2026-05-6=A (constitution write in financial-data-protocol.md; Phase C)"
  - actor: "Claude Sonnet 4.6 (sandwich-architect S335)"
    action: PROPOSED (4 paths + rule text drafted)
    at: 2026-05-16
    via: "agent-workspace/proposals/theme-g-i-s1-1-amendment-2026-05-16.md + session-plans/pending/019-S335-theme-g-constitution-write.md"
  - actor: user
    action: ACCEPTED (explicit Path B pick)
    at: 2026-05-16
    via: "AskUserQuestion in S336 main session: user pick 'Path B — Constitution write Rule 16 (Recommended)'"

verified_by:
  - mechanism: provenance-chain
    at: 2026-05-16
    result: PASS
    note: "All 5 source_evidence entries cite file:line; rule text extracted verbatim from proposal § 4.1"
  - mechanism: firing-test
    at: 2026-05-16
    result: PASS
    detail: "scripts/hooks/firing-tests/run-all.sh — verified post-edit"
  - mechanism: bash-hook-lint
    at: 2026-05-16
    result: PASS
    detail: "scripts/hooks/bash-hook-lint.sh — 0 violations"

affects:
  charter: false
  spec_files:
    - agent-workspace/constitution/financial-data-protocol.md
    - agent-workspace/constitution/invariants-stockforge.md
  code_paths: []
  config_files: []
  other_decisions:
    - "D-061 § Decision item 6 (cross-reference appended; follow-through record)"

depends_on:
  - "D-061 § Decision item 6 + Q-INT-2026-05-6=A prior ratification 2026-05-15T15:30+07:00 (blanket-A user approval)"
  - "D-056 (charter-tier amendment process precedent — establishes temp-deny-lift pattern for constitution writes)"

supersedes: ""
superseded_by: ""

cool_down: |
  Not applicable. Path B = constitution-write, NOT charter Revision Protocol.
  48h cool-down skipped per D-061 prior ratification provides the cool-down equivalent
  (user blanket-A 2026-05-15T15:30+07:00 + explicit path pick 2026-05-16).
  Precedent: D-019 (Rule 11) + D-021 (Rules 12-15) used same path with no cool-down.

defer_cycles: 0
re_attempt_prereq: "N/A"

tags: ["wave-1", "phase-c", "theme-g", "i-s1-1", "numeric-field-discipline", "constitution-write", "S336", "Q-INT-2026-05-6"]
---

# Decision 065 — Theme G I-S1-1 (Numeric-Field Discipline) Ratification

## Context

Phase C of Wave-1 research integration (per master plan § 6.3) is the "Theme G constitution
write" slot — the deliverable deferred from D-061 § Decision item 6 pending explicit human
ratification.

Phase A's 15 deep-dive observations (S323-S324) established that I-S1-1 is GENUINE-NEW (not
redundant with I-S1): Charter Principle 9 + I-S1 + I-S7 prohibit LLM-emitted numbers at the
prose/output layer, but do not constrain the **schema layer**. A Pydantic/dataclass field
typed as `confidence: float` is itself an invitation for the LLM to emit a numeric value,
which downstream code treats as data.

Empirical evidence from 3 candidate repos (per SUPPLEMENT § G.2):
- ai-hedge-fund `warren_buffett.py:13-16`: `confidence: int 0-100` (LLM self-reported)
- TradingAgents `schemas.py:127, :199`: `entry_price` + `price_target` Optional[float]
- TradingAgents-CN `trader.py:68-80`: explicit "强制要求提供具体数値" — most aggressive pattern

Counter-examples (correct shape):
- FinceptTerminal `NotifLevel` bounded enum (`NotificationService.h:15`)
- Vibe-Trading `confidence=low` deterministic categorical (`SKILL.md:138-139`)

This is the 2nd refinement-of-rule for I-S1 (D-059 Python-determinism was the 1st), which
triggers the AP-23 mandate: promote to dedicated rule, not inline accumulation.

D-061 § Decision item 6 queued Q-INT-2026-05-6. User answered A (constitution write) on
2026-05-15T15:30+07:00 via blanket-approval. S335 sandwich-architect drafted 4 paths +
literal Rule 16 text. S336 user explicitly picked Path B ("Constitution write Rule 16
(Recommended)") via AskUserQuestion in the main session.

## Decision

1. **Rule 16 ("Numeric-Field Discipline") added to `financial-data-protocol.md`** immediately
   after Rule 15 (FX VND-USD Point-in-Time Discipline), before the "Last modified" footer.
   The rule defines 4 satisfaction modes (categorical surrogate, deterministic-pipeline echo,
   calibration-database lookup, NULL surrogate), initial field inventory, schema-time and
   runtime enforcement expectations, and cross-references to sibling rules (6, 7, 9) and
   charter principles (8, 9).

2. **Companion `I-S1-1` alias added to `invariants-stockforge.md`** between I-S1 and I-S2,
   providing a concise 7-line discoverable entry pointing to full Rule 16 text.

3. **Quick Reference Table row** appended to `financial-data-protocol.md` Quick Reference
   Table: `| LLM emitting numeric field | I-S1-1, Rule 16 | EchoValidator + schema-discriminator hook |`.

4. **D-061 § Decision item 6 cross-reference** updated to note D-065 ACCEPTED + Rule 16 landed.

## Consequences

**Immediate**:
- Existing field `KolRecommendationExtracted.confidence_extracted: float` (architecture.md:300)
  is now formally subject to Rule 16 mode 3 (calibration-database lookup), deferred to Phase
  B/C BC-6 wiring per Rule 16 § Fields inventory.
- All future numeric-typed fields in `packages/contracts/events/**`, `packages/domain/**`,
  BC-6 + BC-8 schema modules must satisfy one of the 4 modes or be flagged as violation.
- Phase F-prime Theme H IMPL (debate-style multi-perspective, master plan § 6.4.3) MUST NOT
  emit `entry_price` / `price_target` as LLM-emitted floats; must use mode 1 (categorical)
  or mode 2 (deterministic-pipeline echo via BC-2 DCF pipeline).

**Downstream hooks** (planned, not authored by this session):
- `scripts/hooks/numeric-field-discipline-check.sh` to lint schema-time constraints.
- `EchoValidator.validate(llm_value, deterministic_value, tolerance=...)` to enforce
  deterministic-echo mode at runtime.

**No code changes this session** — Rule 16 is a CONTRACT rule only; IMPL is downstream per
Phase F-prime theme sequencing.

## Approval Chain Summary

| Date | Actor | Action |
|---|---|---|
| 2026-05-15T15:30+07:00 | User (project-owner) | Blanket-A on Q-INT-2026-05-6; answered "A (constitution write)" |
| 2026-05-15 | Claude Opus 4.7 (S325 master-planner) | D-061 § Decision item 6 queued pending user ratify |
| 2026-05-16 | Claude Sonnet 4.6 (S335 sandwich-architect) | Drafted proposal + 4 paths + literal Rule 16 text |
| 2026-05-16 | User (project-owner) | Explicit Path B pick via AskUserQuestion S336 main session |
| 2026-05-16 | Claude Sonnet 4.6 (S336 sandwich-dev) | Executed Path B: Rule 16 + I-S1-1 alias + D-065 ADR + D-061 cross-ref |

## Acceptance Record

- **2026-05-15T15:30+07:00**: Q-INT-2026-05-6=A ratified (user blanket-A, D-061 § approval_chain).
- **2026-05-16**: Path B explicitly picked by user via AskUserQuestion S336 main session.
- **2026-05-16**: S336 sandwich-dev executed: Rule 16 landed in `financial-data-protocol.md`;
  I-S1-1 alias landed in `invariants-stockforge.md`; this ADR authored; D-061 cross-ref updated.
  Status: ACCEPTED.
