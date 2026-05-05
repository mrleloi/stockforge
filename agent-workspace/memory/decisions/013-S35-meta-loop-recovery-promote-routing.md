---
id: D-013-S35-meta-loop-recovery-promote-routing
title: S35 META_LOOP_RECOVERY — Promote-rule routing outcomes (3 charter PENDING-USER-GATE; 4 hooks APPLIED; 1 skill ext; 4 deferred)
date: 2026-05-01
status: ACCEPTED (charter subset ratified at S38 via Q&A 2026-05-01-001 → D-015/D-016/D-017; hook+skill items APPLIED at S35; deferred subset still per original D-013 § Decision)
level: SCOPE-tier (3 charter promotes) + IMPL-tier (hook/skill items)

author:
  - "Claude Opus 4.7"
  - session: S35 (META_LOOP_RECOVERY)

source_evidence:
  - path: agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md
    section: "Promotion candidates from this post-mortem"
    quote: "Stop hook detects ≥3 lesson candidates batched OR ≥10 sessions since last promotion → fires promote-rule subagent dispatch automatically."
  - path: agent-workspace/memory/observations/promote-rule-S35.md
    section: "Implementation Recommendations for Main Session"
    quote: "Estimated LOC budget for main session implementation ... Total ~650 LOC ... Suggest splitting across 2 IMPL sessions if S35 budget tight: S35-A = charter promotes + ADRs (user-gated batch); S35-B = hooks + skill + cross-references."
  - path: agent-workspace/session-plans/pending/006-S35-meta-loop-recovery.md
    section: "D4 Promotion cycle execution"
    quote: "Expected outcome: ≥2 proposals promoted (likely promotion candidates: provenance-protocol, autonomous-protocol both have practical use already); ≥3 lessons → hook (e.g., L-S34-1 → importlinter independence contract)."
  - path: agent-workspace/memory/observations/queued-grill-master.md
    section: "Q-E3 Promotion Target Priority"
    quote: "Hook FIRST, skill SECOND, charter LAST"
  - path: agent-workspace/memory/observations/queued-grill-master.md
    section: "Q-B2 Hard Block Default for Charter/SCOPE-tier"
    quote: "charter/SCOPE-tier MUST require explicit letter pick"
  - path: pyproject.toml
    section: "[[tool.importlinter.contracts]] Bounded contexts are independent"
    quote: "S35 D6 — promotes L-S34-1 cross-BC import-detection lesson"

related_user_prompt: SessionStart hook auto-resume + user "continue" 2026-05-01 (S35 entry per checkpoint S34-extension-close + post-mortem 2026-05-01)

approval_chain:
  - "S35 main session (Opus 4.7 × max × FOCUSED_IMPL META_LOOP_RECOVERY): IMPL-tier hook+skill items self-decided per Q-E3 hook-first doctrine + autonomous_mode=true"
  - "promote-rule subagent (general-purpose; agent ID a3f2723447bbfb6de; ~5 min wall; ~127K tokens): produced routing observation"
  - "S35 main session: synthesizes routing into this single ADR; charter-tier subset escalated via Q&A bundle for SCOPE-tier user-gate"
  - "human (PENDING for charter promotes only)"

affects_charter: true (3 charter promotes pending user-gate)
affects_scope: false (charter promotes are formalization of practical-applied patterns, not new scope)
binding_phase: 2 (effective S36+; charter promotes effective post user-gate)

---

# D-013 — S35 Promote-Rule Routing

## Decision

S35 META_LOOP_RECOVERY ran the dead promote-cycle on 9 proposals + 7 lesson candidates. Routing observation `agent-workspace/memory/observations/promote-rule-S35.md` is the canonical record. This ADR ratifies the routing outcomes:

### Charter promotes (3 — PENDING SCOPE-tier user-gate)

1. **autonomous-protocol** → constitution/autonomous-protocol.md (Rule 1 charter-tier S15 user-correction; 13 sessions of de-facto enforcement)
2. **decision-discipline** → constitution/decision-discipline.md (+ NEW Rule 2 sub-clause for L-S26-1 master-plan contradiction + NEW Rule 4a phase-boundary trigger sub-clause)
3. **memory-tiers** → constitution/memory-tiers.md (paired with autonomous-protocol Rule 4 bootstrap ceiling)

User-gate channel: Q&A bundle `human-workspace/q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md` (this session D4-output). Each promote requires explicit letter pick per Q-B2.

### Hook/skill APPLIED this session (4 hooks + 1 skill ext)

| ID | Artifact | LOC | Status |
|---|---|---|---|
| L-S34-1 | `pyproject.toml [[tool.importlinter.contracts]] independence` (S35 D6) | 13 | ✅ APPLIED + verified 0 production violations |
| L-S25-1 | `scripts/hooks/subagent-budget-classifier.sh` | ~30 | ✅ APPLIED |
| L-S28-1 + L-S32-1 | `scripts/hooks/vendor-api-probe.sh` | ~75 | ✅ APPLIED |
| Meta-fix (Rule 4a) | `scripts/hooks/promotion-cycle-trigger.sh` | ~40 | ✅ APPLIED — THIS IS THE DEAD-LOOP FIX |
| L-S30-1 | `.claude/skills/decompose-work/SKILL.md` § Pre-Flight | ~10 | ✅ APPLIED |

### Practical-applied (3 — no new artifact this session beyond 1-line cross-references)

- provenance-protocol (12 D-NNN files cite source_evidence; wait Phase 3 thesis ramp)
- financial-data-protocol-amendment (S16 hook portability; lives in `bash-hook-lint.sh`)
- session-budgets-amendment (Mode A/B/C/D in `autonomous-stop-watchdog.sh` + `budget-watchdog.sh`)

### Deferred (4 with re-trigger conditions)

- financial-data-protocol-amendment-VN — Phase 2 close + ForeignOwnership/FX BC entities exist
- invariants-amendment-VN — paired with above
- architecture-amendment (sections 2-4) — D-DUPL hook fires ≥3×
- provenance-protocol formal charter — Phase 3 first thesis ships

## Why (Reasons)

1. **Per Q-E3** — hook-first cheapest enforcement; 4 of 7 lessons promoted to hook this session.
2. **Per Q-B2** — charter-tier MUST get explicit letter pick; cannot self-decide. Q&A bundle `2026-05-01-001-S35-charter-promote-batch.md` is the user-gate channel.
3. **Per Rule 4a (the META-fix)** — 15 sessions of skipped promotion cycle proves "promote at phase close" Q-E2 doctrine is necessary-but-insufficient; need N-cap (≥5 sessions OR phase boundary). `promotion-cycle-trigger.sh` enforces.
4. **Per L-S15-1 charter-tier-split-rule** — bundle 3 charter promotes in single user batch but 3 explicit-pick questions (not multi-default).
5. **Karpathy P3 (Surgical changes)** — defer 4 proposals with explicit re-trigger conditions; charter-promote ONLY proposals already practical-applied 5+ times.

## Options Considered

- **Option A (chosen)**: Bifurcate — hooks/skills APPLIED inline (deterministic; no user-gate); charter promotes ESCALATED to user via Q&A bundle (explicit-pick). Routing observation is canonical.
- **Option B**: Apply ALL items inline (hooks + charter file moves). REJECTED — charter is in deny-list per `harness_bootstrap_permission_override.md` post-Track 7 + Q-B2 explicit-pick required.
- **Option C**: Defer all to S35-B/S36 split session. REJECTED — meta-fix hook (promotion-cycle-trigger.sh) is the closure for the dead-loop; deferring perpetuates the gap.

## Risk

- Charter promotes pending — if user does not approve, dead-loop risk recurs around Rule 4a. Mitigation: meta-fix hook already shipped (deterministic enforcement); charter formalization is documentation upgrade, not enforcement.
- vendor-api-probe.sh runs at IMPL-session entry — if vendor API endpoints unavailable, hook emits warning not failure (non-blocking).
- subagent-budget-classifier.sh classifies via prompt-keyword grep — false-positive risk on edge cases; soft-warn only.

## Re-attempt prerequisites (for charter promotes)

- User pick on each of 3 questions in Q&A bundle 2026-05-01-001
- After approval: ADRs D-014/D-015/D-016 written; constitution files materialized (deny-list lift required by user OR file moves via designated mechanism)

## Open questions

- Charter file moves require lifting `Edit/Write` deny-list on `agent-workspace/constitution/**`. After user approves, what is the lift mechanism — user manually edits `.claude/settings.json` or one-time `harness_bootstrap_permission_override` extension? Surface in Q&A bundle.
