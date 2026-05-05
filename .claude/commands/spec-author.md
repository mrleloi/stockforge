# /spec-author — Create Dual-Layer Specification

> Invokes `spec-author` subagent (Business Analyst + DDD Designer persona) to produce Tier 2 feature spec following `SPEC_TEMPLATE.md`. Body delegates dual-layer discipline to the `spec-dual-layer` skill.

## When to Use

- Before implementing any non-trivial feature
- When converting a requirement into a formal spec
- When refactoring requires updated spec

## Input

`$ARGUMENTS` — feature name or brief description (e.g., `KOL recommendation extraction pipeline`, `thesis validation workflow`).

## Process

1. **Pre-flight check** — relevant BC exists in glossary? If new domain terms emerging, suggest `/drill-me` first. Check if a similar spec already exists (avoid duplication).

2. **Gather context** — read `SPEC_TEMPLATE.md` (template), relevant `agent-workspace/ubiquitous-language/glossary.md` sections, related specs, and constraints from `agent-workspace/constitution/invariants.md` + `architecture.md`.

3. **Dispatch `spec-author` subagent** (run_in_background) with the context bundle. Subagent budget: up to 50K tokens. Persona: BA + DDD Designer. Task: produce dual-layer spec for `$ARGUMENTS`.

4. **Subagent produces three parts** per `spec-dual-layer` skill:
   - **Part A (Business Specification)** — context narrative; use cases with acceptance scenarios; business rules in ubiquitous language; decisions + tradeoffs (A.6); risks (A.7, including finance-specific); dependencies (A.8). Readable by non-engineer stakeholder.
   - **Part B (Agent Contract)** — input/output contracts (dataclasses for domain, Pydantic for interfaces only); core logic at algorithm level — **NO LLM math** (numbers come from deterministic code per I-S1); data model changes; affected BCs; domain events; API surface (Phase 2+); NFRs; test requirements (B.9); MUST/MUST-NOT/SHOULD constraints; rollback (B.12); verification checklist (B.13). Output **must be multi-criteria, never single buy/sell score**.
   - **Part C (Provenance)** — authoring history, review slot (reviewer fills), decision provenance refs.

5. **Subagent writes** to `specs/tier2-feature/NNN-feature-name.md` per template.

6. **Review prompt** — output: spec_id + path / 2-3 sentence summary from Part A / Key Decisions Made (D-N list) / Open Questions for human (Q-N list) / Glossary Status (existing terms used + new terms proposed) / **StockForge compliance check**: no-LLM-math in B.3 ✅; output multi-criteria ✅; source citation in output contract per I-S2 ✅; bear case required if thesis-related per I-S10 ✅ / Next Steps (`/spec-to-wiki [path]` then `/bdd-planner [spec-id]`).

7. **Iteration** — minor edits in place, bump version 1.0 → 1.1; major changes re-run `/spec-author` with refined input.

8. **Sign-off when approved** — add to `current-execution.md` as active spec; schedule `/bdd-planner` for test planning + `/master-plan` for implementation breakdown.

## Anti-Patterns

- Writing spec without checking glossary first
- Combining multiple features in one Tier 2 spec (split)
- Skipping Part C provenance (decision history matters)
- Writing Part B without reviewing Part A first
- Spec >500 LOC in Tier 2 → split
- LLM math in B.3 pseudocode (e.g., `LLM computes P/E ratio` — charter violation per I-S1)
- Single buy/sell confidence score as output (use trade-off matrix per I-S35)

## Do

- Use dual-layer format religiously (per `spec-dual-layer` skill)
- Flag ambiguities explicitly in open questions
- Reference existing patterns from `agent-workspace/memory/patterns-discovered/`
- Keep Tier 2 spec to 200-500 LOC
- Make Part A readable by non-engineer
- Ensure all numbers in B.3 trace to deterministic code

## Quality Check

Before finalizing: every domain term in glossary; Part A narrative + Part B structured; B.13 complete; A.7 risks identified; A.6 decisions documented; A.8 dependencies listed; B.9 tests specified; B.12 rollback present; no LLM math in B.3; multi-criteria output. Full check list: `SPEC_TEMPLATE.md` checklist section.

## Related

- `spec-dual-layer` skill — canonical dual-layer discipline (substance)
- `SPEC_TEMPLATE.md` — template + checklist
- `/drill-me` — pre-spec glossary extraction
- `/spec-to-wiki` — natural follow-up after sign-off
- `agent-workspace/constitution/invariants.md` — I-S1 / I-S2 / I-S10 / I-S35 enforced in Part B
