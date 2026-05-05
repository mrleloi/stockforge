---
id: D-023-S43c-charter-amend-autonomous-protocol-cost-substrate
title: Amend constitution/autonomous-protocol.md with NEW Rule 9 — Cost Substrate (subagent-first, $0 marginal)
date: 2026-05-04
status: ACCEPTED
level: CHARTER
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md
    quote: "Q6=A — Amend charter (Recommended) — Edit autonomous-protocol.md + ADR D-023 ratifies; effective immediately; binds future 'needs API key' framing"
  - path: agent-workspace/memory/agent-notes.md
    section: L-S38-2 (subagent-as-LLM-substrate; user verbatim 2026-05-01 mid-S38)
  - path: agent-workspace/memory/sessions/
    section: 2026-05-01 S38 chat — user "sao lại cần key api? tìm cách chạy free đi. ví dụ dùng claude code, tạo subagent chạy."
intent_classification:
  primary_intent: SCOPE
  affects_charter: true
  affects_scope: true
  urgency: NORMAL
  complexity_score: 50
options_considered:
  - id: A
    summary: Amend charter (autonomous-protocol.md NEW Rule 9 — Cost Substrate)
    pros: ["Identity-touching reframe — belongs in charter", "Binds future deferred-on-cost paths to subagent-first", "Closes loop on ANTHROPIC_API_KEY dependency creep concern"]
    cons: ["Charter file grows ~30 LOC"]
  - id: B
    summary: Author as separate skill cost-substrate-pivot/SKILL.md
    pros: ["Per Rule 3 hook-skill-charter cheapest-first; subagent-pivot is procedural"]
    cons: ["Misses identity framing; user verbatim signals charter-tier authorization"]
  - id: C
    summary: Defer — apply ad-hoc per session without charter binding
    pros: ["Zero churn"]
    cons: ["Pattern drifts; future sessions revert to API-key default"]
chosen: A
chosen_rationale: |
  User verbatim "sao lại cần key api? tìm cách chạy free đi" is identity-tier framing — StockForge
  is single-person self-funded; ANTHROPIC_API_KEY direct = dependency creep that conflicts with that
  identity. Charter binding ensures every "blocked-on-cost" framing is auto-reframed to subagent-first.
  HR-6 lesson-synthesizer dispatch (this turn) validated the substrate works in practice (60K tokens
  in subagent run — zero marginal $).
approval_chain:
  - actor: user
    action: SURFACED
    at: 2026-05-01
    via: chat verbatim "sao lại cần key api? tìm cách chạy free đi. ví dụ dùng claude code, tạo subagent chạy."
  - actor: agent
    action: PROPOSED
    at: 2026-05-01
    via: human-workspace/q-and-a/pending/2026-05-01-003 Q6
  - actor: user
    action: ACCEPTED
    at: 2026-05-04
    via: chat reply at S43c entry — "tôi accept toàn bộ q&a recommend của agent"
verified_by:
  - mechanism: smoke-test
    at: 2026-05-04
    result: PASS
    notes: "grep confirmed 'Rule 9 — Cost Substrate' appended to autonomous-protocol.md; HR-6 lesson-synthesizer subagent dispatch this turn validated the substrate end-to-end at 60K tokens / zero marginal $"
affects:
  charter: true
  spec_files: ["specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.10 cost profile (Q9 amendment downstream)"]
  code_paths: ["apps/_shared/use_case_builder.py (future SubagentLLMPerspectiveAdapter — Q7=a deferred to next session)"]
  config_files: []
  other_decisions: ["D-015"]
depends_on: ["D-015"]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A
tags: ["charter-amend", "S43c", "autonomous-protocol", "cost-substrate", "subagent-first"]
---

# Decision 023 — S43c Charter Amend: Cost Substrate (subagent-first)

## Decision

Append `## Rule 9 — Cost Substrate (D-023, ratified 2026-05-04)` to `agent-workspace/constitution/autonomous-protocol.md`. New rule:

- Any deferred-on-cost LLM path MUST first attempt subagent-dispatch substrate (Claude Code Agent tool) before allocating `ANTHROPIC_API_KEY` budget
- Subagent dispatch billed against Claude Code subscription = zero marginal cost beyond subscription
- Decision tree: (1) Try subagent first; (2) If not feasible, escalate to user with explicit cost estimate; (3) Hard-block silent API-key defaults

## Why (Reasons)

1. Identity preservation — StockForge is single-person self-funded research aid (per Charter); ANTHROPIC_API_KEY direct creates dependency creep that conflicts
2. Calibration data — HR-6 lesson-synthesizer subagent dispatch this turn (2026-05-04) validated end-to-end at 60K tokens / zero marginal $
3. User verbatim authorization at charter tier ("sao lại cần key api? tìm cách chạy free đi")

## Acceptance Record

- **2026-05-01**: SURFACED by user (mid-S38 chat)
- **2026-05-01**: PROPOSED by agent (Q&A 2026-05-01-003 Q6)
- **2026-05-04**: ACCEPTED by user at S43c entry
