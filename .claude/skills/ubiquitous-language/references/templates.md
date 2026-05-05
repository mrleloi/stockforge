# ubiquitous-language — Templates & Examples

Companion to `SKILL.md`. Detailed templates referenced from each step.

## Term Definition Schema

```markdown
### [Term Name]

**Bounded context**: [which of 9 BCs owns this term]

**Definition**: [Clear, specific definition — what it is, what it's for]

**Lifecycle**: [If applicable — state transitions]

**Not to confuse with**: [List of similar-but-different terms]

**Code**: [file path if implemented, or "not yet built"]

**Introduced**: [date, source conversation/spec]
```

## Term Definition Example (Thesis)

```markdown
### Thesis

**Bounded context**: BC-8 Analysis & Thesis

**Definition**: A structured multi-perspective investment analysis for a specific
stock (Ticker). Must include both BullAnalysis and BearAnalysis (adversarial by
design — see I-S10). Lifecycle ends in either PostMortem (if acted on) or
Abandoned (if not).

**Lifecycle**: Draft → Active → [Closed | Abandoned] → PostMortem (optional)

**Not to confuse with**:
- `ExtractedClaim` (a factual claim from a source — input to thesis, not the thesis itself)
- `KolRecommendation` (a KOL's recommendation — input to thesis)
- `Analysis` (generic term — our canonical term is `Thesis` for investment analyses)

**Code**: `packages/domain/analysis/models/thesis.py`

**Introduced**: 2026-04-20, spec SPEC-2026-04-001
```

## Drift Log Entry

```markdown
## YYYY-MM-DD — [Add | Rename | Deprecate | Clarify] — [term]

**Session**: [reference, e.g., S20]
**Change**: [what changed]
**Rationale**: [why]
**Impact**: [files affected, if any]
```

## Stop List Entry

In `glossary.md`:

```markdown
## Stop List — Do NOT Use

| Do NOT use | USE instead |
|---|---|
| Analysis | Thesis (for investment analyses) |
| Recommendation | KolRecommendation |
| Signal | ExtractedClaim | SentimentScore (be specific) |
```

## Extraction Output Template

```markdown
# Ubiquitous Language Extraction — [source]

## Date
YYYY-MM-DD

## Source
[conversation ID, spec path, or interview transcript]

## Candidate Terms Found ([N])

### Accepted ([M])

#### [Term 1]
[Full definition per schema above]

#### [Term 2]
[Full definition]

### Deferred ([K])
- [Term] — need more context from domain expert
- [Term] — overlap with existing, need clarification

### Rejected ([L])
- [Term] — too generic
- [Term] — technical infrastructure, not domain

## Conflicts Detected
- [Existing term] vs [candidate] — [resolution needed]

## Next Steps
1. Review accepted terms with domain expert
2. Update glossary.md with accepted definitions
3. Run /ul-audit to find code drift
4. For deferred terms, schedule /drill-me session
```

## Drift Detection Command

```bash
grep -rn "TermName\|term_name" packages/ apps/ --include="*.py"
```

Run for each glossary term. Flag if:
- Code uses different name for same concept
- Multiple names exist for what should be one term
- Term defined in glossary but not used in code
