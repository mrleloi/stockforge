---
name: spec-dual-layer
description: Write specifications with dual-layer structure (business narrative + agent contract). Use when authoring new specs, refining existing specs, or understanding the spec template. Ensures both human stakeholder needs and agent execution needs are served.
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
---

# Skill: Dual-Layer Spec Authoring

## Purpose

Every feature spec serves two audiences:
- **Human stakeholder** needs narrative, context, rationale
- **AI agent** needs structure, unambiguous contracts, machine-verifiable

Dual-layer specs serve both without compromise — Part A is for humans, Part B is for agents.

## When to Use

- Writing any Tier 2 (feature) or Tier 3 (task) spec
- Refactoring existing spec to dual-layer format
- Reviewing a spec for completeness

## Reference Template

`/SPEC_TEMPLATE.md` at project root is canonical. Three parts:

| Part | Audience | Purpose |
|---|---|---|
| **Part A** — Business Specification | Stakeholder | Narrative — context, users, rules, success, decisions |
| **Part B** — Agent Contract | Agent | Structured — input/output, logic, data model, tests, constraints |
| **Part C** — Provenance & Review | Both | Living log — authoring history, review trail |

## Part A vs Part B — Decision Rule

| Content type | Goes in |
|---|---|
| WHY / WHAT / WHO / scenarios / business rules / scope / key decisions / risks / dependencies | Part A (A.1–A.9) |
| Exact dataclass / DTO / SQL / BC list / events / API routes / NFR / test plan / MUST-MUST-NOT / rollout / verification | Part B (B.1–B.13) |

If you can't derive Part B from Part A → Part A is incomplete; revise A first. See `references/section-checklists.md` for the full section-by-section content list.

## Stock-Specific Part B Rules

### B.3 — No LLM Math

Logic that produces a number MUST be deterministic code. The LLM only classifies pre-computed values.

```
# CORRECT
Step 1: Fetch financial statements (code)
Step 2: pe = compute_pe(price, eps)               # DETERMINISTIC
Step 3: LLM classifies pe vs sector range          # CLASSIFICATION ONLY
Step 4: Combine signal tiers (code aggregation)

# WRONG — VIOLATION (I-S1)
Step 2: "LLM computes PE ratio based on context"
```

### B.2 — Multi-Criteria Output, Never Single Score

```python
# CORRECT — multi-criteria
@dataclass
class ThesisOutput:
    ticker: Ticker
    bull_case: BullAnalysis
    bear_case: BearAnalysis              # MUST be substantive
    quant_signals: QuantSignals
    sentiment_signals: SentimentSignals
    recommendation_note: str             # framed as research aid
    as_of: datetime

# WRONG — single score (charter principle 2 violation)
@dataclass
class ThesisOutput:
    buy_confidence: float                # ← VIOLATION
```

## Tier Sizing

| Tier | Lines | Cadence |
|---|---|---|
| **Tier 1** Strategic | 100–300 | Rarely changes (e.g., "Four-Tier Signal Architecture") |
| **Tier 2** Feature | 200–500 | Per iteration. Split before shipping if > 500 |
| **Tier 3** Task | 50–150 | Per session |

## Deriving Part B from Part A — Process

For each section in Part A, ask:
1. What does this imply for input/output shape?
2. What data structures are needed?
3. What domain events should fire?
4. What can go wrong (edge cases)?
5. How will this be tested (pyramid layer)?
6. Does any number computation appear? → If yes, who computes it? **Must be code, never LLM.**

Work A → B section-by-section. Don't skip step 6.

## Validation Pre-Conditions (Quality Checklist)

- [ ] Every domain term appears in `agent-workspace/ubiquitous-language/glossary.md`
- [ ] Part A readable by non-engineer stakeholder (no implementation detail)
- [ ] Every Part B section derives from Part A content
- [ ] All MUST / MUST NOT constraints listed in B.10
- [ ] Rollback plan in B.12
- [ ] Test requirements concrete (not "write tests")
- [ ] Risks identified with mitigation in A.7
- [ ] Dependencies listed explicitly (A.8 + B.11)
- [ ] B.3 logic has NO LLM math (numbers come from code)
- [ ] B.2 output is multi-criteria (not single buy/sell score)
- [ ] Bear case present and substantive if thesis-related

## Sample Workflow

1. Run `/drill-me` if new domain terms expected (e.g., "KOL", "CredibilityScore")
2. Write Part A
3. Review Part A with user — does it capture intent?
4. Write Part B (derive from A; no LLM math; multi-criteria)
5. Review Part B section-by-section
6. Fill Part C initial authoring history
7. Save as `specs/tierN/NNN-feature-name.md`
8. Run `/spec-to-wiki` for Obsidian view
9. Schedule `/bdd-planner` for test plan
10. Schedule `/master-plan` for implementation breakdown

## Anti-Patterns

- **Part A too technical** ("system uses Dramatiq queue...") → implementation detail goes in B.3 / B.5
- **Part B too narrative** ("we'll probably use Pydantic for validation") → write the actual `@dataclass` shape
- **Mixing audiences in one section** — split into Part A explanation + Part B contract
- **Skipping Part C** — provenance log dies first; add at authoring, append at every review

See `references/section-checklists.md` for full wrong-vs-correct examples.

## See Also

- `references/section-checklists.md` — full Part A.1–A.9 + Part B.1–B.13 content lists + wrong/correct examples
- `/SPEC_TEMPLATE.md` — canonical template
- `ddd-tactical-patterns` SKILL.md — domain-model aspects
- `evidence-extraction` SKILL.md — for specs touching evidence
- `test-pyramid-balance` SKILL.md — for B.9 test requirements
