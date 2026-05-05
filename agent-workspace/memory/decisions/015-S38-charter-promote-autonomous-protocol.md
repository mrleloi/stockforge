---
id: D-015-S38-charter-promote-autonomous-protocol
title: Promote autonomous-protocol.md from proposal to constitution (CHARTER ratification)
date: 2026-05-01
status: ACCEPTED
level: CHARTER

author:
  - "Claude Opus 4.7"
  - "user (explicit pick Q&A 2026-05-01-001 Q1=A)"

source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md
    quote: "Q1=A — Promote autonomous-protocol → constitution"
  - path: agent-workspace/memory/decisions/013-S35-meta-loop-recovery-promote-routing.md
    section: PARTIAL-ACCEPTED — charter subset PENDING (now resolved by D-015/D-016/D-017)
  - path: agent-workspace/proposals/autonomous-protocol.md (predecessor; moved at S38)
  - path: ~/.ccs/instances/.../memory/full_autonomous_no_supervised.md
    quote: "CHARTER-tier user correction — autonomous = ONLY mode"

intent_classification:
  primary_intent: DECISION
  affects_charter: true
  affects_scope: true
  urgency: NORMAL
  complexity_score: 70

options_considered:
  - id: A
    summary: Promote to charter as-is (file move + ADR ratification; effective immediately)
    pros: ["Codifies practical-applied behavior", "Makes drift signal D-IDENTITY enforceable", "Resolves S35 D-013 PARTIAL"]
    cons: ["Constitution edits now require explicit user prompt + Q&A"]
  - id: B
    summary: Defer to Phase 3 — wait for more empirical data
    pros: ["More burn-in time"]
    cons: ["S35 META-skip pattern recurs", "Practical-applied evidence already 5+ decision-points"]
  - id: C
    summary: Reject — keep as proposal indefinitely
    pros: ["Maximum flexibility"]
    cons: ["Charter-tier rules with no charter binding = drift risk"]

chosen: A
chosen_rationale: |
  Per Q&A 2026-05-01-001 Q1=A explicit user pick. autonomous-protocol.md is practical-applied at every checkpoint S14+ (Rule 1 autonomous_mode=true), Mode-D shipped in autonomous-stop-watchdog.sh (Rule 2), bootstrap budgets enforced empirically S25 calibration (Rule 4), Rule 8 violation drove S15 user correction. Promotion formalizes what is already de facto binding.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: agent-workspace/proposals/autonomous-protocol.md (S16 IMPL — Track 7 ratification draft)
  - actor: user
    action: ACCEPTED
    at: 2026-05-01
    via: chat reply "Q1=A" to Q&A 2026-05-01-001 (S38 entry AskUserQuestion equivalent — file-bundle pick)

verified_by:
  - mechanism: smoke-test
    at: 2026-05-01
    result: PASS
    note: "drift-signals-D1-D9.sh D-IDENTITY scan continues to pass post-promotion (no SUPERVISED|until Track 7 regression)"

affects:
  charter: true
  spec_files: []
  code_paths: []
  config_files:
    - .claude/settings.json (deny constitution Edit/Write — preserved post-S38; lifted only during S38 file-move via Q4=B mechanism)
  other_decisions:
    - D-013 (PARTIAL-ACCEPTED → ACCEPTED for autonomous-protocol subset)

depends_on:
  - D-013 (S35 promote-rule routing — PARTIAL-ACCEPTED carries autonomous-protocol as charter-pending)

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A — ACCEPTED.

tags: ["S38", "charter-promote", "Bundle-1", "Q&A-2026-05-01-001-Q1", "autonomous-protocol"]
---

# D-015 — Promote autonomous-protocol.md to constitution

## Context

`agent-workspace/proposals/autonomous-protocol.md` (127 LOC) was authored at S16 IMPL (Track 7 ratification draft). 8 rules covering full-autonomous-only mode, Mode A/B/C/D handoff, hybrid context auto-loader, bootstrap budgets per session-type, Skill-tool gating, drift self-detection, drift recovery flow, AskUserQuestion scope.

Rule 1 codifies S15 user correction (charter-tier explicit authorization that autonomous_mode=true is the ONLY mode; no SUPERVISED bifurcation). All 8 rules are practical-applied across 5+ decision-points S14+.

S35 META_LOOP_RECOVERY routed promotion via D-013 PARTIAL-ACCEPTED (charter subset PENDING). Q&A 2026-05-01-001 Q1 fired at S38 entry; user picked Option A.

## Analysis

Per `agent-workspace/constitution/decision-discipline.md` Rule 3 (Promotion Target Priority — cheapest first: Hook FIRST, Skill SECOND, Charter LAST), charter promotion is heaviest lift and requires user explicit approve. autonomous-protocol qualifies for charter (vs hook/skill) because it shapes project identity (Rule 1 = single operating mode, charter-tier per S15).

Empirical evidence already in production:
- Rule 1: cited at every checkpoint S14+
- Rule 2: shipped in `scripts/hooks/autonomous-stop-watchdog.sh` per L-S14-4
- Rule 4: bootstrap budgets enforced empirically (S25 architect 192K overshoot → L-S25-1 calibration)
- Rule 8: violated by S15 close pre-correction → led to S15 user correction (the very correction that became Rule 1)

## Decision

Move `agent-workspace/proposals/autonomous-protocol.md` → `agent-workspace/constitution/autonomous-protocol.md`. Update frontmatter status PROPOSAL → CHARTER. Charter-tier binding effective S38+.

### What this means concretely

- All 8 rules in autonomous-protocol.md become CHARTER-tier binding (edit requires explicit user prompt + Q&A per `agent-workspace/CLAUDE.md` constitution-amendment process)
- `.claude/settings.json` deny re-instated post-S38 (lifted only for the move itself via Q4=B mechanism)
- Future promotions to constitution follow the same Q4=B mechanism: settings.json deny temporarily lifted; agent moves files; deny restored

## Why (Reasons)

1. **Codifies de facto behavior** — practical-applied at 5+ decision-points; charter status removes ambiguity about whether the rules bind
2. **Resolves S35 D-013 PARTIAL** — charter subset of routing now ratified
3. **Enforces D-IDENTITY drift signal** — bash-hook-lint.sh D-IDENTITY scan can now cite charter (not proposal) when flagging `SUPERVISED|until Track 7` regression

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Constitution-amendment friction for future autonomous-protocol edits | Medium | Document amendment process in `agent-workspace/CLAUDE.md`; charter-tier edits expected to be rare (~once per Phase) |
| File-move mechanism (Q4=B settings.json deny lift) misused for non-charter writes | Low | This ADR documents the mechanism is one-time per S38; restore step verified post-move (settings.json contains constitution deny again) |

## Open Questions

None (Q&A 2026-05-01-001 Q1 resolved).

## Acceptance Record

- **2026-04-29**: PROPOSED at S16 IMPL Track 7 ratification (proposal file authored)
- **2026-05-01**: ACCEPTED by user via Q&A 2026-05-01-001 Q1=A explicit pick at S38 entry
