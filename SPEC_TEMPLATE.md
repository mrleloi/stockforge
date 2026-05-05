# SPEC TEMPLATE
## Dual-Layer Specification Structure

> **Status**: Template v1.0
> **Purpose**: Reference format for all feature specs in StockForge
> **Tier**: Applies to Tier 2 (Feature) and Tier 3 (Task) specs

---

## Philosophy

A spec serves two audiences with different needs:
- **Human stakeholder**: wants narrative, context, rationale — Business Analyst perspective
- **AI agent executor**: wants structure, unambiguous contracts, machine-readable

**Solution**: Dual-layer spec. Single file, two parts, both first-class.

When business understanding changes → edit Part A first, then regenerate Part B.
When implementation details change → edit Part B, verify consistency with Part A.
Both parts in git history for provenance.

---

## Size Guidelines (from Phase2 research)

| Tier | Size | Purpose |
|---|---|---|
| Tier 1 Strategic | 100-300 lines | One per major initiative |
| Tier 2 Feature | 200-500 lines | One per capability |
| Tier 3 Task | 50-150 lines | One per implementable task |

If Tier 2 exceeds 500 lines → split before shipping.
Each tier has different loading strategy and cache policy.

---

## TEMPLATE

Copy the structure below, fill in content. Delete template comments.

For a real-world example of this template in use, see:
`specs/tier2-feature/001-validate-investment-thesis.md`

---

```markdown
---
spec_id: SPEC-YYYY-MM-DD-NNN-short-kebab
tier: 2
status: draft | review | approved | implemented | deprecated
version: 1.0
created: YYYY-MM-DD
last_reviewed: YYYY-MM-DD
authors: [list]
bounded_contexts: [list of affected BCs — use exact names from architecture.md]
related_specs: [list of related spec_ids]
ubiquitous_language_terms: [list of key terms]
produces_thesis_output: true | false   # if true, Adversarial Check (A.10) is required
---

# SPEC: [Feature Name]

<!-- 
  STRUCTURE RULE:
  - Part A: Business Specification (narrative, for humans + context for agents)
  - Part B: Agent Contract (structured, for agents to execute against)
  - Part C: Provenance & Review (living log)
  
  Both A and B are first-class. Neither is "summary" of other.
  A explains WHY and WHAT. B specifies HOW agent should execute.
-->

---

# PART A — BUSINESS SPECIFICATION

## A.1 Context

<!-- 
  The story: why this spec exists.
  3-5 paragraphs.
  Answer: what problem does this solve? What's the current gap?
  Link to user need, charter goal, or strategic driver.
  Cross-reference: PROJECT_CHARTER.md, specs/tier1-strategic/001-four-tier-signal-architecture.md
-->

[Narrative about why this matters. What situation prompts this feature.
What the user or system currently can't do. Why now.]

## A.2 User & Use Cases

### Primary User
[Who this is for. For StockForge: project owner + 3-5 trusted peers in Vietnamese investing community.]

### Use Cases
**UC-1: [Name]**
As a [user], I want to [capability], so that [outcome].

Acceptance narrative:
[Concrete scenario. What triggers it. What success looks like. What failure looks like.]

**UC-2: [Name]**
[...]

## A.3 Business Rules

<!-- 
  Domain invariants. The rules that must always hold.
  Written in ubiquitous language from glossary.
  Reference relevant I-S* invariants where applicable.
-->

### BR-1: [Rule Name]
[Statement of invariant. Reference to ubiquitous language term.]

Example: A Thesis always includes a substantive BearCase with ≥3 distinct points (I-S10).

### BR-2: [Rule Name]
[...]

## A.4 Success Criteria

### Qualitative
- [Outcome that matters strategically]
- [User experience expectation]

### Quantitative
- [Measurable metric with target]
- [Performance expectation]

### Acceptance Signals
How we know this is working in production:
- [Signal 1]
- [Signal 2]

## A.5 Scope

### In Scope
- [Thing this spec covers]
- [Boundary include]

### Explicitly Out of Scope
- [Thing this spec does NOT cover — with brief why]
- [Boundary exclude]

### Deferred to Future Spec
- [Thing we'll do later, spec TBD]

## A.6 Key Decisions & Tradeoffs

### Decision D-1: [Name]
**Options considered**: [A, B, C]
**Chosen**: [B]
**Rationale**: [Why]
**Tradeoff**: [What we gave up]
**Revisit if**: [Conditions that would change this]

### Decision D-2: [Name]
[...]

## A.7 Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| [Risk description] | HIGH/MED/LOW | [Mitigation approach] |

## A.8 Dependencies

### Upstream (this spec depends on)
- [Spec, system, or decision this relies on]

### Downstream (depends on this spec)
- [What will be built on top]

### External
- [Third-party services, APIs, libraries — e.g., vnstock, FiinPro, Claude API]

## A.9 Glossary Check

<!--
  Before writing Part B, verify all domain terms used in Part A are in 
  ubiquitous-language/glossary.md. New terms? Run /drill-me to add them.
-->

Terms used in this spec:
- [Term] → defined in glossary.md
- [Term] → defined in glossary.md
- [NEW Term] → NEEDS /drill-me session before implementation

## A.10 Data Provenance

<!--
  Required for ANY spec that references a number, rate, ratio, price, or metric.
  Every number that appears in this spec must have a source and an as-of date.
  Consistent with I-1 (source_url required) and I-S1 (no LLM math).
  
  If this spec produces NO numeric claims, state "N/A — no numeric claims in this spec."
-->

| Number / Metric | Value | Source URL | As-Of Date | Notes |
|---|---|---|---|---|
| [e.g., P/E threshold used in BR-2] | [e.g., < 15x] | [URL to source] | [YYYY-MM-DD] | [e.g., industry average from FiinPro] |
| [e.g., sentiment threshold in AC-3] | [e.g., >80% bullish] | [URL] | [YYYY-MM-DD] | |

Invariant reminder: LLM never generates the numbers in this table. Numbers come from data queries in deterministic code, then cited here with provenance.

## A.11 Adversarial Check

<!--
  Required when `produces_thesis_output: true` in frontmatter.
  Required for any feature that produces signals, alerts, or investment-relevant output.
  Omit (or state N/A) for pure infrastructure / data pipeline features.
  
  Purpose: force explicit bear case contract into the spec itself, not just the implementation.
  Consistent with I-S10 (thesis must include bear case), I-S12 (disagreement surfaced).
-->

### Bear Case Contract
[Define what a substantive bear case looks like for output produced by this feature.]

Example: For thesis validation output, bear case must contain ≥3 distinct risk factors, each with:
- Specific evidence (not boilerplate)
- Source URL + as-of date (Data Provenance applies)
- Distinct from each other (not rephrasing the same risk)

### Disagreement Handling
[How does this feature handle conflicting perspectives?]

Example: If Bull and Bear perspectives reach opposite conclusions, output surfaces DISAGREEMENT explicitly. System does not vote-average to a neutral score.

### Confidence Framing
[How is confidence communicated in output?]

Example: Any "confidence" claim in output must trace to historical hit rate from `agent-workspace/calibration/`. LLM "model confidence" is not used.

### Output Framing
[Confirm disclaimer presence.]

All output includes "research aid, not financial advice" disclaimer per I-S35.

---

# PART B — AGENT CONTRACT

<!--
  Everything agent needs to execute without re-reading Part A.
  Structured, unambiguous, machine-verifiable where possible.
  
  Part B derives from Part A but is NOT a copy. It's the executable slice.
  If Part A and Part B conflict — stop and reconcile. Part A wins on meaning,
  Part B wins on technical specifics.
-->

## B.1 Input Contract

```python
# Exact shape of input. Use dataclass for domain; Pydantic for HTTP layer.
from dataclasses import dataclass
from typing import Optional
from datetime import date

@dataclass(frozen=True)
class FeatureInput:
    field: str          # description, constraints
    as_of: date         # point-in-time reference for any data queries
    # ...
```

**Validation rules**:
- [Rule 1]
- [Rule 2]

**Examples**:
```python
# Valid
FeatureInput(field="HPG", as_of=date(2026, 4, 23))

# Invalid — field empty
FeatureInput(field="", as_of=date(2026, 4, 23))
# raises: ValueError("field must not be empty")
```

## B.2 Output Contract

```python
@dataclass(frozen=True)
class FeatureOutput:
    field: str
    as_of: date                 # always present — when data was queried
    source_url: str             # always present — I-1
    # ...
```

**Guarantees**:
- [Invariant that output always satisfies — e.g., "source_url is never empty (I-1)"]
- [Invariant — e.g., "numeric fields trace to tool call results, not LLM text (I-S1)"]

**Examples**:
```python
# Happy path output
FeatureOutput(field="...", as_of=date(2026, 4, 23), source_url="https://...")

# Degraded output (when data source unavailable)
FeatureOutput(field="...", as_of=date(2026, 4, 23), source_url="...", warnings=["vnstock unavailable, used cached data"])
```

## B.3 Core Logic Specification

<!--
  Algorithm or flow in precise terms.
  Not code, but unambiguous.
  All numeric computations happen in deterministic Python functions — never in LLM output.
-->

```
PROCEDURE validate_thesis(input: FeatureInput) -> FeatureOutput:
  PRE:
    - input.ticker is valid VN stock ticker (format check)
    - input.as_of <= today (no future-dated queries)
  
  STEPS:
    1. Fetch Tier 1 data (deterministic — no LLM)
       a. get_quotes_adjusted(ticker, range) → price history
       b. fundamental_repo.get_as_of(ticker, as_of) → financials (point-in-time)
       c. compute_ratios(financials) → P/E, P/B, ROE, etc. [Python, not LLM]
    2. Fetch Tier 2 data
       a. news_repo.get_known_as_of(ticker, as_of) → recent articles
       b. LLM extracts claims → each claim has source_url + extracted_at
    3. Run multi-perspective analysis
       - Bear agent: reads data, produces ≥3 distinct bear points
       - Bull agent: reads data, produces catalysts + opportunity framing
       - Quant agent: reads code-computed ratios, interprets (does NOT compute)
    4. Synthesize trade-off matrix (structured output, not scalar score)
    5. Check: bear case substantive? → if not, raise BearCaseInvariantError
    6. Apply disclaimer footer (I-S35)
  
  POST:
    - output.bear_case has >= 3 distinct points
    - every claim in output has source_url + as_of
    - no number in output was generated by LLM text (all from tool calls)
    - output includes disclaimer
```

## B.4 Data Model Changes

### New Tables / Columns
```sql
CREATE TABLE IF NOT EXISTS <table_name> (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticker VARCHAR(10) NOT NULL,
  as_of_date DATE NOT NULL,
  source_url TEXT NOT NULL,          -- I-1: required
  source_provider VARCHAR(50) NOT NULL,  -- I-S5
  extracted_at TIMESTAMPTZ NOT NULL, -- I-2
  -- ...
);
```

### Modified Tables
```sql
ALTER TABLE <table> ADD COLUMN <col> <type>;
```

### Migration Notes
- [Data backfill required?]
- [Reversible?]

## B.5 Affected Bounded Contexts

Use exact BC names from architecture.md:

- **BC-1 Market Data**: [what changes]
- **BC-2 Fundamental**: [what changes]
- **BC-5 News Stream**: [what changes]
- **BC-8 Analysis & Thesis**: [what changes]

## B.6 Domain Events Emitted

```python
# From architecture.md patterns — use frozen dataclasses

@dataclass(frozen=True)
class ThesisCreated:
    thesis_id: ThesisId
    ticker: Ticker
    as_of: date
    created_at: datetime

# Additional events as needed...
```

## B.7 API Surface

```
# FastAPI (Phase 2+) or Streamlit trigger (Phase 1)

POST /api/v1/thesis
  Request: FeatureInput (B.1 as Pydantic DTO)
  Response 200: { thesis_id: UUID, status: "processing" }
  Response 400: { error: str, field: str }
  Response 429: { error: "rate_limited", retry_after_seconds: int }

GET /api/v1/thesis/{thesis_id}
  Response 200: FeatureOutput (B.2 as Pydantic DTO)
  Response 404: { error: "not_found" }
```

## B.8 Non-Functional Requirements

### Performance
- [Expected latency p95 — e.g., "thesis card rendered in ≤5 minutes p95"]

### Cost
- Per-operation LLM budget: < $X (escalate on breach — I-40)
- Daily cap: see I-42

### Reliability
- Idempotent: same ticker + as_of → same thesis (with same model + prompt hash)
- Retry-safe: partial failures re-runnable from last checkpoint
- Graceful degradation: if one data source down, continue with others + warning

### Observability
- Emit metrics: operation_count, operation_duration_ms, operation_cost_usd, operation_status
- Structured logs (structlog) with operation_id correlation
- Sentry capture on failures

## B.9 Test Requirements

### Test Pyramid for This Feature
| Level | Coverage target | Location |
|---|---|---|
| Unit | Pure domain logic 100% | `packages/domain/*/test_*.py` |
| Integration | Use cases 80% | `apps/*/tests/` |
| E2E (BDD) | Critical flows | `bdd/features/<feature>.feature` |
| LLM snapshot | Extractor outputs | `tests/snapshots/` |
| Backtest | Historical replay (if applicable) | `tests/backtest/` |

### Critical Test Cases
1. **Happy path**: valid ticker → complete output with claims + citations
2. **Bear case enforcement**: output without ≥3 bear points → BearCaseInvariantError raised
3. **No LLM math**: verify every number in output traces to tool call result
4. **Source URL present**: every claim has source_url — I-1 enforced
5. **Point-in-time integrity**: backtest query uses `get_as_of()`, not `get_latest()`
6. **Disclaimer present**: output footer contains research-aid disclaimer — I-S35
7. **Degraded mode**: data source fails → continue with warning in output

### BDD Scenarios
```gherkin
Feature: [Feature Name]

  Scenario: Happy path
    Given [setup]
    When [action]
    Then [outcome with citation check]
    And [disclaimer present]

  Scenario: Bear case enforced
    Given a thesis analysis completes without substantive bear case
    When output is produced
    Then system raises BearCaseInvariantError
    And thesis is not persisted

  Scenario: No LLM math
    Given market data is available for ticker
    When ratios are computed
    Then all numeric values in output trace to deterministic Python tool calls
    And no numeric value appears only in LLM free-text output
```

## B.10 Implementation Constraints

### MUST (hard constraints)
- Every claim in output has `source_url`, `extracted_at`, `source_provider`
- Domain layer (`packages/domain/`) has no framework imports — dataclasses + stdlib only
- Cross-BC calls via `packages/contracts/` only
- VBW protocol applied before writing any new method
- All numeric output from deterministic Python code, not LLM text (I-S1)
- Thesis output requires ≥3 substantive bear points (I-S10)
- Output includes "research aid" disclaimer (I-S35)

### MUST NOT (anti-patterns)
- LLM call without budget cap
- Claim stored without `source_url` citation
- Number in output not traceable to tool call result
- Single scalar score as output (always multi-dimensional)
- Disagree and collapse to consensus (surface DISAGREEMENT instead)

### SHOULD (preferences)
- Use prompt caching for stable context parts
- Prefer Sonnet for extraction, Opus for thesis synthesis
- Extract patterns to skills when pattern emerges 3+ times

## B.11 Dependencies on Skills / Subagents

Required skills:
- `evidence-extraction`
- `prompt-engineering`
- `postgres-pgvector`
- `ddd-tactical-patterns`

Required subagents (if complex):
- `sandwich-architect` for initial planning
- `sandwich-verifier` for implementation review

## B.12 Rollout Plan

### Feature Flag
`FF_<FEATURE_NAME>` — default off until dogfood phase

### Migration Steps
1. Deploy code (flag off)
2. Run DB migrations
3. Backfill any required historical data (if any)
4. Enable flag for self-use only
5. Validate with 3-5 real operations
6. Enable for trusted peers

### Rollback Plan
- Flag off immediately
- No destructive migrations — all reversible
- Previous data remains readable

## B.13 Verification Checklist

<!-- This gets checked at Tier 2 quality gate -->

- [ ] Part A reviewed by human
- [ ] All glossary terms defined
- [ ] Data Provenance (A.10) filled for all numeric claims
- [ ] Adversarial Check (A.11) completed if produces_thesis_output: true
- [ ] VBW protocol ran before implementation
- [ ] Unit tests green (`pytest packages/domain/`)
- [ ] Integration tests green
- [ ] BDD scenarios green
- [ ] LLM snapshot tests green (if applicable)
- [ ] Drift signals DR1-DR9 pass (`/drift-check HIGH`)
- [ ] Eval regression check passes
- [ ] I-S1 verified: no LLM-generated numbers in output
- [ ] I-S10 verified: bear case has ≥3 distinct points (if thesis output)
- [ ] I-S35 verified: disclaimer present in output
- [ ] Cost per operation measured and within budget
- [ ] Observability metrics emitting
- [ ] Rollback plan tested in staging

---

# PART C — PROVENANCE & REVIEW

## C.1 Authoring History

| Date | Author | Change | Rationale |
|---|---|---|---|
| YYYY-MM-DD | [name] | Initial draft | Initial spec |

## C.2 Review Log

| Date | Reviewer | Decision | Comments |
|---|---|---|---|
| YYYY-MM-DD | [name] | REQUEST CHANGES | [what] |
| YYYY-MM-DD | [name] | APPROVED | [notes] |

## C.3 Decision Provenance

For each major decision in A.6, link to:
- Discussion log (if any)
- Evidence used (research, code analysis, business input)
- Approval chain

## C.4 Implementation Sessions

As implementation proceeds, append:

| Session | Date | Tasks | Outcome | Notes |
|---|---|---|---|---|
| N | YYYY-MM-DD | [task ids] | [complete/blocked] | [notes] |

## C.5 Post-Implementation Retrospective

[After implementation, fill in]

### What went well
- 

### What was harder than expected
- 

### Learned rules added to agent-notes.md
- 

### Spec revision needed?
- [ ] No
- [ ] Minor — updated in place
- [ ] Major — new version required
```

---

## Notes for Using This Template

### Part A: Write First
- Start every spec with Part A
- Write as Business Analyst, not engineer
- Focus on WHY and WHAT
- Review with stakeholder before Part B
- Fill A.10 (Data Provenance) for any spec referencing numbers
- Fill A.11 (Adversarial Check) for any spec producing thesis/signal output

### Part B: Derive From A
- Only write Part B after Part A reviewed
- If you can't derive B from A, A is incomplete
- B is where agent contracts live
- Must be unambiguous and verifiable
- Use Python dataclass / type hints, not TypeScript interfaces

### Part C: Fill In Over Time
- Starts empty
- Grows with review history
- Captures decision provenance for audit

### When Specs Change
- Minor edit: bump version (1.0 → 1.1), append to C.1
- Major edit: new spec_id with link to previous
- Always preserve history — never silent edits

### Common Mistakes to Avoid

1. **Part A too technical** — should be readable by non-engineer stakeholder
2. **Part B too narrative** — should be structured and scannable
3. **Part A and B drift** — run /spec-drift-check to catch
4. **Terms not in glossary** — run /drill-me first
5. **Missing verification checklist** — don't skip B.13
6. **No provenance in Part C** — decision history is gold
7. **Missing Data Provenance (A.10)** — every number needs source + as-of date
8. **Missing Adversarial Check (A.11)** — required for all thesis/signal features; bear case must be explicit in spec, not just implied in code
9. **Output type signatures as TypeScript** — use Python dataclasses in Part B

### Obsidian Wiki Version

After spec approved, run `/spec-to-wiki` to generate Obsidian version:
- Wikilinks to entities, concepts, related specs
- Frontmatter with tags
- Added to `/wiki/specs/tier2-feature/`
- Entry in `/wiki/_index.md`
- Entry in `/wiki/_log.md`

Raw spec remains source of truth. Wiki version is navigable view.
