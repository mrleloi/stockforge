# Spec Section Checklists — Part A & Part B

> Reference companion to `../SKILL.md`. Full content lists per section.

## Part A — Business Specification

### A.1 Context
- Why this exists
- What problem it solves
- Narrative framing for non-engineer reader

### A.2 User & Use Cases
- Who uses this (persona / role)
- Concrete scenarios
- Acceptance narratives ("when X happens, user expects Y")

### A.3 Business Rules
- Domain invariants in ubiquitous-language terms
- Reference glossary entries

### A.4 Success Criteria
- Quantitative measures (e.g., "extraction precision ≥ 80% on eval set N=200")
- Qualitative measures (e.g., "thesis output frames as research aid, not advice")

### A.5 Scope
- In: explicit feature list
- Out: explicit non-features with rationale (prevents scope creep)

### A.6 Key Decisions
- Options considered
- Choice rationale
- Tradeoffs accepted

### A.7 Risks & Mitigations
Tabular:

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|

### A.8 Dependencies
- Upstream (what feeds this)
- Downstream (what consumes this)
- External (third-party services / data sources)

### A.9 Glossary Check
- Every domain term used in this spec → verified in `agent-workspace/ubiquitous-language/glossary.md`

### What does NOT belong in Part A

- Implementation details
- Code structure
- Database schema
- API endpoints
- Algorithm specifics

(Those go in Part B.)

---

## Part B — Agent Contract

Goal: agent can execute this section without re-reading Part A.

### B.1 Input Contract
Exact shape — Python dataclass for domain, Pydantic for interfaces:

```python
@dataclass
class ExtractKolRecommendationCommand:
    kol_id: KolId
    source_url: str  # YouTube video URL
    published_at: datetime

# Validation rules:
# - source_url must be valid YouTube URL
# - published_at must be in past
```

### B.2 Output Contract
Exact shape with guarantees. Multi-criteria, never single score.

### B.3 Core Logic Specification
Algorithm or flow as pseudocode. NO LLM math — all numbers from deterministic code; LLM only classifies.

### B.4 Data Model Changes
SQL migrations, schema changes (see `postgres-pgvector` skill for shape).

### B.5 Affected Bounded Contexts
List which of the 9 BCs are impacted (see `agent-workspace/constitution/architecture.md`).

### B.6 Domain Events Emitted
Each event with payload shape.

### B.7 API Surface
HTTP endpoints (Phase 2+ only). Request / response schemas.

### B.8 Non-Functional Requirements
Performance (p95 latency), cost (cents/call), reliability (error budget), observability (metrics, logs).

### B.9 Test Requirements
Test pyramid allocation per `test-pyramid-balance` skill. BDD scenarios for top user flows.

### B.10 Implementation Constraints
MUST / MUST NOT / SHOULD lists. These become acceptance gates.

### B.11 Dependencies on Skills / Subagents
Which `.claude/skills/` and `.claude/agents/` to use for execution.

### B.12 Rollout Plan
Feature flag, migration order, rollback procedure.

### B.13 Verification Checklist
Pre-merge checks. Each item enforceable by hook or human review.

---

## Relationship: B Derives From A

Example:
- **Part A**: "Thesis output must present both bull and bear perspectives with citations"
- **Part B (derived)**:

```python
@dataclass
class ThesisSynthesis:
    bull_case: BullAnalysis
    bear_case: BearAnalysis    # MUST NOT be None or empty
    catalysts: list[Catalyst]
    risks: list[Risk]
    signal_tier_summary: SignalTierSummary  # Tier 1/2/3/4 agreement levels

# Invariant: bear_case.is_substantive() must be True
```

If you can't derive B from A → A is incomplete.

---

## Common Mistakes — Wrong vs Correct

### Part A too technical

**Wrong**:
```markdown
## A.1 Context
The system uses Dramatiq queue to dispatch extraction jobs to Python workers
which call Claude API with prompt caching enabled...
```

**Correct**:
```markdown
## A.1 Context
KOL influencers on YouTube and Facebook measurably move VN stock prices.
Today we have no systematic way to track which KOLs recommend which stocks
and whether those recommendations turn out to be correct. This feature
ingests KOL content and extracts recommendations for calibration...
```

### Part B too narrative

**Wrong**:
```markdown
## B.1 Input Contract
The user provides a YouTube URL and the system extracts the recommendation.
We'll probably use Pydantic for validation...
```

**Correct**:
```python
## B.1 Input Contract

@dataclass
class ExtractKolRecommendationCommand:
    kol_id: KolId
    source_url: str  # YouTube video URL
    published_at: datetime

# Validation rules:
# - source_url must be valid YouTube URL
# - published_at must be in past
```
