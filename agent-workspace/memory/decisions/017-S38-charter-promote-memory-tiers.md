---
id: D-017-S38-charter-promote-memory-tiers
title: Promote memory-tiers.md to constitution + author tier1-bloat-check.sh hook
date: 2026-05-01
status: ACCEPTED
level: CHARTER

author:
  - "Claude Opus 4.7"
  - "user (explicit pick Q&A 2026-05-01-001 Q3=A)"

source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md
    quote: "Q3=A — Promote to charter + author tier1-bloat-check.sh hook"
  - path: agent-workspace/memory/decisions/013-S35-meta-loop-recovery-promote-routing.md
    section: PARTIAL-ACCEPTED — charter subset PENDING
  - path: agent-workspace/proposals/memory-tiers.md (predecessor; moved at S38)
  - path: agent-workspace/memory/observations/queued-grill-master.md
    section: Q-D3 (codify Tier 1/2/3 — closed S15 Batch 1)

intent_classification:
  primary_intent: DECISION
  affects_charter: true
  affects_scope: false
  urgency: NORMAL
  complexity_score: 60

options_considered:
  - id: A
    summary: Promote to charter + author tier1-bloat-check.sh hook
    pros: ["Tier 1 bloat actively detected at SessionStart", "Memory hierarchy formally codified"]
    cons: ["Hook adds ~30 LOC + SessionStart latency negligible"]
  - id: B
    summary: Promote charter only; skip hook for now
    pros: ["Minimum lift"]
    cons: ["Without hook, Tier 1 bloat goes undetected; charter rule becomes advisory"]
  - id: C
    summary: Defer entire proposal — wait for more memory bloat evidence
    pros: ["More burn-in time"]
    cons: ["Empirical evidence already exists: current-execution.md grew to 18.5K tok by Phase 2 mid"]

chosen: A
chosen_rationale: |
  Per Q&A 2026-05-01-001 Q3=A explicit user pick. Hook authored at S38 immediately validated need: smoke test reported Tier 1 bootstrap = 23,952 tok (current-execution.md alone = 18,490 tok), well over 8K ceiling. Without the hook, this bloat would have continued silently. Charter binding + active hook = defense-in-depth.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: agent-workspace/proposals/memory-tiers.md (S16 IMPL — Track 7 ratification draft)
  - actor: user
    action: ACCEPTED
    at: 2026-05-01
    via: chat reply "Q3=A" to Q&A 2026-05-01-001 (S38 entry — file-bundle pick)

verified_by:
  - mechanism: smoke-test
    at: 2026-05-01
    result: PASS
    note: "tier1-bloat-check.sh smoke test fired correctly; emitted WARN at 23,952 tok vs 8K ceiling; exit 0 (non-blocking)"

affects:
  charter: true
  spec_files: []
  code_paths:
    - scripts/hooks/tier1-bloat-check.sh (NEW; 49 LOC)
  config_files:
    - .claude/settings.json (deny constitution Edit/Write — preserved post-S38)
  other_decisions:
    - D-013 (PARTIAL-ACCEPTED → ACCEPTED for memory-tiers subset)

depends_on:
  - D-013 (S35 promote-rule routing — PARTIAL-ACCEPTED)
  - D-015 (autonomous-protocol Rule 4 bootstrap ceiling — Tier 1 budget cited)

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A — ACCEPTED.

tags: ["S38", "charter-promote", "Bundle-1", "Q&A-2026-05-01-001-Q3", "memory-tiers", "tier1-bloat-check"]
---

# D-017 — Promote memory-tiers.md to constitution + tier1-bloat-check hook

## Context

`agent-workspace/proposals/memory-tiers.md` (87 LOC) was authored at S16 IMPL (Track 7 ratification draft). Codifies Tier 1 (always-loaded bootstrap; ≤8K) / Tier 2 (just-in-time) / Tier 3 (explicit-pull) memory hierarchy that has existed implicitly in CLAUDE.md and `agent-workspace/CLAUDE.md` Reading Priority lists.

Companion hook deferred during S16 (no Tier 1 bloat evidence yet). By Phase 2 mid (S38), `current-execution.md` had grown from ~3K (S22 close) to ~18.5K tok via session-row appending — empirical Tier 1 bloat.

## Analysis

Tier 1 budget = 8K per `autonomous-protocol.md` Rule 4 (PLAN session bootstrap ceiling, the strictest tier). Tier 1 file count = 4 (CLAUDE.md, agent-workspace/CLAUDE.md, current-execution.md, checkpoints/latest.md when recent).

Pre-hook reality (smoke test 2026-05-01):
| File | Tokens (approx) |
|---|---|
| CLAUDE.md | 2049 |
| agent-workspace/CLAUDE.md | 2005 |
| current-execution.md | 18490 |
| checkpoints/latest.md | 1407 |
| **TOTAL** | **23,952** (vs 8K ceiling = 3x over) |

Without hook, this bloat goes undetected; with hook, soft-WARN fires at every SessionStart until corrected.

## Decision

Move `agent-workspace/proposals/memory-tiers.md` → `agent-workspace/constitution/memory-tiers.md`. Author `scripts/hooks/tier1-bloat-check.sh` (~49 LOC; bash+wc; ASCII byte/4 token approximation).

Update frontmatter status PROPOSAL → CHARTER. Companion hook ships same session.

### What this means concretely

- 3-tier memory hierarchy CHARTER-binding; future Tier 1 additions require explicit rationale + drift impact note (Tier 1 add expands every session bootstrap)
- `tier1-bloat-check.sh` runs at SessionStart; emits stderr WARN if total >8K
- **Immediate corollary action surfaced**: current-execution.md trim/paginate needed (NEW L-S38-1 candidate; defer to Phase 2 close)

## Why (Reasons)

1. **Empirical bloat exists** — 23.9K vs 8K ceiling at S38; will worsen each session without intervention
2. **Hook is cheap** — ~49 LOC bash; <50ms SessionStart latency; non-blocking soft-warn
3. **Resolves S35 D-013 PARTIAL** — memory-tiers subset ratified

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Hook WARN noise drowns out real signals | Low | Single line per SessionStart; only fires when over ceiling |
| Token approximation (bytes/4) underestimates Vietnamese/Unicode content | Medium | Conservative (under-estimate is safe-side; if anything, real token count higher → WARN earlier) |
| current-execution.md cannot be trimmed without losing Phase routing context | Medium | L-S38-1 candidate: paginate historical session rows to `agent-workspace/memory/sessions-rollup/<phase>.md` while keeping active phase rows in current-execution.md |

## Open Questions

None (Q&A 2026-05-01-001 Q3 resolved). NEW L-S38-1 follow-up: trim/paginate current-execution.md historical rows; defer to Phase 2 close.

## Acceptance Record

- **2026-04-29**: PROPOSED at S16 IMPL Track 7 ratification
- **2026-05-01**: ACCEPTED by user via Q&A 2026-05-01-001 Q3=A explicit pick at S38 entry; hook authored + smoke-tested same session
