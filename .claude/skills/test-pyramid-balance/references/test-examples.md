# Test Examples — Templates by Layer

> Reference companion to `../SKILL.md`. Verbatim pytest + gherkin templates.

## Unit Test (Domain Logic)

```python
# packages/domain/analysis/tests/test_thesis.py
import pytest
from packages.domain.analysis.models.thesis import Thesis, ThesisStatus
from packages.domain.analysis.errors import InvariantViolation, InvalidStateError

def test_thesis_requires_substantive_bear_case() -> None:
    """Charter principle: adversarial by design — bear case mandatory."""
    with pytest.raises(InvariantViolation, match="bear case"):
        Thesis.create(
            ticker=Ticker.from_str("VCB"),
            bull_case=BullCase("Strong earnings growth..."),
            bear_case=BearCase(""),  # empty — must fail
        )

def test_thesis_cannot_add_catalyst_when_active() -> None:
    thesis = make_active_thesis()
    with pytest.raises(InvalidStateError):
        thesis.add_catalyst(make_catalyst())
```

## Integration Test (Use Case + Real DB)

```python
# apps/api/tests/test_validate_thesis_integration.py
import pytest
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope="session")
def postgres():
    with PostgresContainer("postgres:16") as pg:
        yield pg

async def test_validate_thesis_persists_and_emits_event(postgres, event_bus_mock):
    repo = ThesisPostgresRepository(db=make_db(postgres))
    use_case = ValidateThesisUseCase(thesis_repo=repo, event_bus=event_bus_mock)

    result = await use_case.execute(
        ticker="VCB",
        bull_case="Strong earnings growth driven by retail expansion...",
        bear_case="Rising NPL ratio may compress margins and trigger provision surge...",
    )

    # Verify persistence
    from_db = await repo.find_by_id(result.id)
    assert from_db is not None
    assert from_db.status == ThesisStatus.ACTIVE

    # Verify event emitted
    assert event_bus_mock.published_events[-1].type == "ThesisCreated"
```

## BDD Scenario

```gherkin
# bdd/features/validate_investment_thesis.feature
Feature: Validate Investment Thesis

  Scenario: User submits thesis with both bull and bear case
    Given user is authenticated
    When user submits thesis for ticker "VCB"
      And bull case is "Strong earnings growth..."
      And bear case is "Rising NPL ratio may compress margins..."
    Then thesis status is "active"
    And thesis has non-empty bear case
    And ThesisCreated event is emitted
```

## LLM Extractor Snapshot Test

```python
# tests/snapshots/test_claim_extraction.py
def test_claim_extraction_vcb_article() -> None:
    """Snapshot test — input text → expected structured output.

    We test that EVERY claim has the required structural fields.
    We do NOT assert on specific LLM phrasing or numbers — that would
    violate I-S1 (no LLM math) and produce a fragile test.
    """
    with open("tests/snapshots/vcb_q1_2026_article.txt") as f:
        article = f.read()

    result = extract_claims_from_article(article, use_cache=True)

    assert all(c.source_url for c in result.claims)            # I-S1: source pointer
    assert all(c.extracted_at for c in result.claims)          # I-S2: as-of date
    assert all(0 <= c.confidence <= 1 for c in result.claims)  # bounded score
    # Numbers in claims came from source text quotes, not LLM computation
```

## Calibration Test

```python
# tests/calibration/test_kol_credibility.py
def test_credibility_score_converges_with_outcome_data() -> None:
    """Given 10 past recommendations with known outcomes, score should be ~0.7."""
    kol = make_kol()
    outcomes = [True, True, False, True, True, False, True, True, True, False]

    for i, hit in enumerate(outcomes):
        kol.record_recommendation_outcome(make_recommendation(i), hit)

    score = kol.credibility_score
    assert 0.65 <= score.value <= 0.75, f"Expected ~0.7, got {score.value}"
```

## Anti-Pattern Examples

### Bad — asserting on LLM-generated text

```python
def test_bear_case_mentions_risk():
    result = llm_analyze_thesis(ticker="VCB")
    assert "NPL" in result.bear_case  # LLM might phrase it differently
```

### Good — test domain invariant

```python
def test_thesis_has_substantive_bear_case():
    thesis = Thesis.create(ticker, bull, bear)
    assert thesis.bear_case.is_substantive()  # domain method, not LLM assertion
```

### Bad — testing LLM math (charter violation)

```python
def test_llm_computes_pe_ratio():
    result = llm.analyze(ticker="VCB")
    assert result.pe_ratio == 12.5  # WRONG: LLM should not compute ratios
```

### Good — code computes, test verifies code

```python
def test_pe_ratio_computation():
    pe = compute_pe(price=Money.vnd(50_000), eps=Money.vnd(4_000))
    assert pe == pytest.approx(12.5, rel=0.01)
```
