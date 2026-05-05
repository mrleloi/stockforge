---
proposal_id: architecture-amendment-C1-llm-substrate-boundary
title: Architecture amendment C1 — append "LLM substrate boundary" cross-ref section to architecture.md
status: ACCEPTED
draft_date: 2026-05-04
draft_session: S43e (continuation 4)
authoring_agent: Claude Opus 4.7
target_charter_file: agent-workspace/constitution/architecture.md
gating: USER-EXPLICIT-PICK-REQUIRED (charter-edit deny-lift cycle per S38 mechanism)
provenance:
  promote_rule_observation: agent-workspace/memory/observations/promote-rule-S43c.md § Cluster C1 + § Routing Plan row 4
  source_rules:
    - KI-S43b-1  # Bull sonnet prompt pairing reproduces 300s subprocess timeout
    - KI-S43b-2  # LLM JSON wrapped in prose preamble breaks naive json.loads
    - KI-S43b-3  # Windows cp1252 default encoding crashes claude CLI subprocess
    - BP-S43b-1  # Per-role model override pattern for LLM-perspective adapters
    - BP-S43b-2  # Prose-tolerant JSON extractor for LLM structured output
    - BP-S43b-3  # Wire deterministic compute services through gatherer, not agent
  promotion_priority: charter (per Q-E3 hook FIRST → skill SECOND → charter LAST; this cluster's hook+code mitigations already shipped at S43b; charter cross-ref makes the canonical reference durable)
  related_existing_artifacts:
    - packages/infrastructure/analysis/claude_llm_perspective_adapter.py  # role_model_overrides field (BP-S43b-1)
    - packages/infrastructure/analysis/subagent_transport.py:55-118       # 3-tier JSON extractor (BP-S43b-2)
    - apps/_shared/use_case_builder.py::_build_subagent_agents             # gatherer-wired compute (BP-S43b-3)
---

# Proposal: Architecture amendment C1 — LLM substrate boundary cross-ref

> **Status**: DRAFT — proposed for charter ratification at user discretion.
> **Tier**: CHARTER (architecture.md is constitution-tier; edit requires deny-lift cycle per S38 mechanism — same channel that ratified D-015..D-024 Phase 2 charter promotes).
> **Required action**: User explicit letter pick per Q-B2 closure (charter-tier MUST require explicit accept; default-acceptance prohibited).
> **Bundling opportunity**: Pair with C2 `proposals/decision-discipline-amendment-rule-4b.md` for a single-batch deny-lift cycle covering both Phase 2 close charter promotes.

## Why this amendment exists

S43b harness recovery (sandwich-dev + verifier across 5 sub-sessions) surfaced 3 known-issues + 3 best-practices specifically about the LLM substrate seam — the boundary where deterministic Python code meets the non-deterministic LLM call. All three best-practices have already shipped as production code (citations in frontmatter). What is missing is the **canonical pointer**: when a future BC adds an LLM-perspective adapter (BC-8 already shipped; future BCs may add their own — KOL summarization, news classification, pump narrative detection), where does the agent look to find these patterns?

Without a charter cross-ref, the patterns live only in `self-awareness/best-practices.md` (a long, append-only file) and in the production code itself. Discovery is grep-dependent, not architecture-document-driven.

## Proposed amendment text

Append a new subsection to `agent-workspace/constitution/architecture.md` immediately after § "LLM" (currently lines 124-131, between "OSS fallback" line and "### Frontend" line):

```markdown
### LLM Substrate Boundary

The boundary where deterministic Python code calls into a non-deterministic LLM
is a **failure-prone seam** — Phase 2 (S43b) surfaced 3 distinct failure modes
and shipped 3 mitigation patterns. Future LLM-perspective adapters (BC-8 today;
any BC tomorrow that adds LLM extraction or classification) MUST adopt these
patterns:

- **Per-role model override** (BP-S43b-1): adapters expose `role_model_overrides`
  so cost/latency-sensitive roles (e.g., Bull perspective) can downgrade Opus → Haiku
  without touching call sites. Reference: `claude_llm_perspective_adapter.py`.
- **Prose-tolerant JSON extractor** (BP-S43b-2): never call naive `json.loads`
  on LLM output; use the 3-tier extractor (fenced block → first-`{` heuristic →
  best-effort recovery). Reference: `subagent_transport.py:55-118`.
- **Gatherer-wired deterministic compute** (BP-S43b-3): numbers come from code
  (Charter Principle 9 / I-S1) — wire deterministic services (RatioService,
  TaService, etc.) through the gatherer that prepares LLM context, not through
  the LLM agent itself.

Known failure modes catalogued: KI-S43b-1 (sonnet pairing 300s subprocess timeout),
KI-S43b-2 (LLM JSON in prose preamble), KI-S43b-3 (Windows cp1252 encoding crash).
See `agent-workspace/memory/self-awareness/{known-issues,best-practices}.md`.
```

Total: ~22 LOC including header + bullets + references. Promote-rule estimate of "~6 LOC" understated the cite density required for the cross-ref to be navigable; this draft errs on the side of completeness.

## Why charter-tier (not skill, not just hook)

Per Q-E3 promotion priority — hook FIRST, skill SECOND, charter LAST. This cluster lands at charter because:

1. **Hook tier already DONE implicitly**: the 3 mitigations are baked into production code paths; no separate hook needed because the patterns ARE the code.
2. **Skill tier inappropriate**: this is not a procedure (no LLM-judgment-required steps); it's a structural reference for "where do I look when adding an LLM-perspective adapter". That's architecture-document territory.
3. **Charter cross-ref is the durable form**: future-Claude reading architecture.md gets the pointer; future-Claude reading only `best-practices.md` may not realize these patterns are *required* for new LLM-perspective adapters, treating them as optional advice instead.

## Trade-offs

| Concern | Mitigation |
|---|---|
| **architecture.md grows over time as more substrate boundaries get cross-refs** | Acceptable; architecture.md is the canonical structural reference and IS supposed to enumerate substrate boundaries. The grow-rate is bounded by number of distinct failure-mode clusters surfaced (Phase 2 = 1 cluster; expect ~1 per phase). |
| **Cross-ref text could go stale if BP-S43b-* IDs renumber** | Renumbering is forbidden by self-awareness append-only contract. IDs are stable for life of the project. |
| **Future BCs may add patterns the cross-ref doesn't cover** | Each future cluster gets its own append at the same § "LLM Substrate Boundary" location; no rewrite of existing cite. |
| **Charter-edit ceremony cost (deny-lift cycle)** | Bundle with C2 (Rule 4b) per "Bundling opportunity" above; 1 deny-lift cycle for both. |

## Failure modes if NOT ratified

- **Pattern rot**: future LLM-perspective adapters re-derive (or worse, omit) per-role override, prose-tolerant extractor, gatherer-wired compute. Each omission re-creates a KI-S43b-* class incident.
- **Documentation fragmentation**: best-practices.md becomes the only source-of-truth pointer; agents consulting architecture.md get a wrong picture (LLM section says "use Claude API" but doesn't warn about the substrate failure modes).

## What ratification looks like (for the user)

If the user picks "ACCEPT":
1. Agent moves the amendment text from this proposal to `agent-workspace/constitution/architecture.md` via the S38 deny-lift mechanism (charter-edit gate).
2. Insertion point: between current line 131 ("OSS fallback (Phase 4+): Llama 3.3 70B via Ollama for cost reduction") and current line 133 ("### Frontend").
3. Agent authors `D-NNN-S43e-charter-promote-architecture-llm-substrate-boundary.md` ADR with approval_chain pointing to the user pick.

If the user picks "REJECT":
1. Mark this proposal `status: REJECTED` with reason.
2. Patterns continue to live only in `best-practices.md`; agent-notes.md retains the cluster.

If the user picks "AMEND":
1. User specifies which clause to change (most likely candidate: shorten the amendment back toward the original "~6 LOC" target).
2. Agent revises this proposal; re-presents.

## Related open proposals (sibling-cluster context)

- `proposals/decision-discipline-amendment-rule-4b.md` (C2 — drafted S43e; same deny-lift batch candidate).
- 7 Phase 2 charter promotes already shipped via deny-lift (D-015..D-024); same channel applies here.

## Ratification record

**ACCEPTED** 2026-05-05 (S43f turn) via AskUserQuestion bundle Q1=ACCEPT.
Charter edit applied to `agent-workspace/constitution/architecture.md` between
LLM section and Frontend section. Bundled with C2 in single deny-lift cycle.
Ratifying ADR: `agent-workspace/memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md`.
