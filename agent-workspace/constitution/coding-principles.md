# Coding Principles

> AI-first development principles for StockForge.
> Complement Karpathy principles with project-specific guidance.

## Base Philosophy

**Specs are source of truth. Code fulfills spec. Tests verify code matches spec.**

No code without spec.
No spec without glossary terms.
No glossary without `/drill-me`.

---

## Practical Principles

### 1. Boring Code Wins

Prefer boring, obvious code over clever code.

```python
# Clever (avoid)
result = {item.key: item for item in items}  # fine for short, bad when chained 5 deep

# Boring (prefer)
result: dict[str, Item] = {}
for item in items:
    result[item.key] = item
```

Why: Clever code is harder to debug, harder for agent to modify, harder for 6-months-future-you.

### 2. Explicit Over Implicit

```python
# Implicit (avoid)
async def process(data): ...

# Explicit (prefer)
async def process_thesis_validation_request(
    request: ThesisValidationRequest,
) -> ThesisValidationResult: ...
```

### 3. Types First

Write the type signatures before the implementation. If you can't type it, you don't understand the problem yet.

```python
# Start here
def validate_thesis(input: ThesisInput) -> ThesisValidationResult: ...

# Then think: what's ThesisInput? what's ThesisValidationResult?
# Types drive design.
```

Use `mypy --strict` from the start. `Any` in domain is a compilation error (see `invariants.md` I-12).

### 4. One Concept Per File

One class, one Protocol, one significant function per file.
Exception: closely related value objects can group (e.g., `ticker.py` can hold `Ticker` + `TickerList`).

### 5. Naming Matches Glossary

If glossary says "Thesis", code uses `Thesis`. Not `Analysis`, `Report`, or `Study`.

Synonyms in code = drift. Run `/ul-audit` periodically.

### 6. Fail Loud, Not Silent

```python
# Silent (bad)
if not input.ticker:
    return None

# Loud (good)
if not input.ticker:
    raise ValidationError("Ticker is required")
```

Silent failures hide bugs. Loud failures surface them.

### 7. Small Functions

Target: <30 lines per function.
If you need more, probably multiple concepts mixed.

### 8. Pure When Possible

Domain logic should be pure (no IO, no mutation of external state).
Side effects live in infrastructure.

Domain layer: `packages/domain/` — pure Python, stdlib only, dataclasses + enum.
Infrastructure layer: all IO, DB, external APIs, LLM calls.

### 9. Test Business Behavior, Not Implementation

```python
# Bad (tests implementation detail)
def test_calls_repository_save_twice():
    ...

# Good (tests domain behavior)
def test_marks_thesis_as_active_when_submitted_with_substantive_bear_case():
    ...
```

### 10. Prompt as Data, Not Code

LLM prompts live in `prompts/` directory, not embedded in business logic.
Load via `load_prompt(name)`. Version with git.

---

## Domain Layer Rules (Strict)

### D-1: Dataclasses in domain, Pydantic at edges only

```python
# Domain entity — pure dataclass
@dataclass
class Thesis:
    id: ThesisId
    ticker: Ticker
    bear_case: BearCase
    bull_case: BullCase
    status: ThesisStatus = ThesisStatus.DRAFT

    def submit(self) -> None:
        if not self.bear_case.is_substantive():
            raise InvariantViolation("Bear case required (I-S10)")
        self.status = ThesisStatus.ACTIVE
```

```python
# API layer DTO — Pydantic for validation + serialization
class ThesisCreateRequest(BaseModel):
    ticker: str
    bear_case_text: str
    bull_case_text: str
```

Never mix: no Pydantic `BaseModel` in `packages/domain/`.

### D-2: Invariants enforced in `__post_init__`

Every domain object validates at construction. Invalid state is unrepresentable.

```python
@dataclass
class Money:
    amount: Decimal
    currency: str = "VND"

    def __post_init__(self) -> None:
        if self.amount < 0:
            raise InvariantViolation("Money amount cannot be negative")
        if not self.currency:
            raise InvariantViolation("Currency required (I-S6)")
```

### D-3: Repositories are Protocols (interfaces), not implementations

```python
# Domain: define the contract
from typing import Protocol

class ThesisRepository(Protocol):
    def get_by_id(self, thesis_id: ThesisId) -> Thesis | None: ...
    def save(self, thesis: Thesis) -> None: ...

# Infrastructure: implement
class ThesisPostgresRepository:
    def get_by_id(self, thesis_id: ThesisId) -> Thesis | None:
        # actual SQL
        ...
```

### D-4: Dependency injection via constructor params

No IoC container magic. Pass dependencies explicitly.

```python
class ValidateThesisUseCase:
    def __init__(
        self,
        thesis_repo: ThesisRepository,
        critic_agent: CriticAgentPort,
        budget: BudgetConfig,
    ) -> None:
        self._thesis_repo = thesis_repo
        self._critic = critic_agent
        self._budget = budget
```

---

## AI-First Specific Principles

### 11. Evidence Before Inference

Domain logic that produces claims must have source evidence.

```python
# Bad — hallucination risk
def infer_market_regime(ticker: str) -> str:
    return "bull"  # LLM guessing

# Good — grounded
def classify_market_regime(
    price_series: PriceSeries,
    macro_indicators: list[MacroIndicator],
) -> MarketRegime:
    # deterministic computation from real data
    return _compute_regime(price_series, macro_indicators)
```

### 12. Budget Awareness

LLM calls wrapped with budget tracking.

```python
# Bad
response = client.messages.create(model=..., messages=...)

# Good
response = await with_budget(
    max_cost_usd=0.50,
    session_id=session_id,
    fn=lambda: client.messages.create(model=..., messages=...),
)
```

### 13. Observable by Default

Every LLM call logged with: `input_tokens`, `output_tokens`, `cost_usd`, `model`, `latency_ms`, `thesis_id` (if applicable).
Every pipeline stage emits metrics via structlog.

### 14. Caching is First-Class

Before LLM call, check cache. After LLM call, store result (if appropriate).
Prompt caching (Claude API cache_control) for stable prefixes.

### 15. Defensive About Hallucination

Every claim extraction has verifier step.
Every citation has source_url check.
Evidence is first-class, not afterthought.

### 16. No LLM Math (Stock-Specific)

LLM never returns a number as content. Numeric outputs always come from tool calls.

```python
# Wrong — LLM emitting number in content
# LLM output: "The P/E ratio is approximately 15.3"

# Right — LLM calls tool
# LLM tool_call: compute_pe_ratio(price=..., eps=...)
# Tool result: 15.27
# LLM content: "P/E ratio is 15.27 (FY2024, source: HOSE filing)"
```

See `invariants.md` I-S1.

---

## Testing Principles

### BDD for Behavior

User-facing flows described in Gherkin:
```gherkin
Feature: Validate stock thesis

  Scenario: Fresh thesis with bear case
    Given user submits thesis for ticker "VNM"
    When full adversarial analysis runs
    Then thesis completes with at least 3 bear case points
    And all claims have source_url
    And output includes both bull and bear perspectives
```

### Unit Tests for Domain Logic

Pure, fast, numerous. No mocks of own domain code.

```python
def test_thesis_cannot_be_submitted_without_substantive_bear_case() -> None:
    thesis = Thesis(
        id=ThesisId("t-1"),
        ticker=Ticker("VNM"),
        bear_case=BearCase(points=[]),  # empty
        bull_case=BullCase(points=["growth", "margin", "brand"]),
        status=ThesisStatus.DRAFT,
    )
    with pytest.raises(InvariantViolation, match="Bear case required"):
        thesis.submit()
```

### Integration Tests for Use Cases

Real DB (`pytest-docker` / `testcontainers`). Real events. Mock only external APIs.

### E2E Sparingly

Full-stack tests for critical flows only. Slow, expensive, flaky. Use judiciously.

### Backtest Tests

Replay historical data with fixed random seeds. Assert reproducibility.
See `invariants.md` I-S53.

---

## Documentation Principles

### Code Self-Documents

Good naming + clear structure = minimal comments.

Comments explain WHY, not WHAT.

```python
# Bad
# Increment counter
counter += 1

# Good
# Rate limit window resets every 60s; reset happens lazily on read
# to avoid requiring a background thread for reset management
if time.time() - last_reset_at > 60:
    counter = 0
    last_reset_at = time.time()
```

### Specs are the Real Documentation

Function docstrings fine. Inline comments fine. But the spec is where design lives.

### TODO with Owner and Date

```python
# TODO(lead, 2026-05): Extract to separate service once we have 3+ callers
```

Not:
```python
# TODO: fix this
```

---

## Refactoring Principles

### Only Refactor When Needed

Don't refactor "just because". Need justification:
- Preparing for a specific change
- Removing actual duplication (not superficial similarity)
- Fixing a proven bug

### Refactor in Micro-Commits

Small commits. Each refactoring step separately committable.
Enables easy revert if something breaks.

### Keep Tests Green Throughout

Never let tests fail during refactor. Red-green-refactor cycle.

### Don't Refactor and Add Feature in Same PR

Two separate concerns. Separate PRs. Reviewers can focus.

---

## Error Handling Principles

### Typed Errors in Domain

```python
# Not generic Exception
class InsufficientEvidenceError(DomainError):
    def __init__(self, thesis_id: str, claims_found: int) -> None:
        super().__init__(
            f"Thesis {thesis_id} has only {claims_found} claims (minimum 5)"
        )
```

### Fail Fast at Boundaries

Validate at API layer (Pydantic DTOs). If input is bad, reject immediately with clear message.

### Recover Gracefully in Pipelines

Long-running ingestion/analysis pipelines should degrade, not crash.
"1 of 5 data sources failed" → continue with warning, not stop.

### Log Errors with Context

```python
logger.error(
    "Failed to extract claims",
    thesis_id=thesis_id,
    source_url=source_url,
    error=str(err),
    exc_info=True,
)
```

---

## Performance Principles

### Measure Before Optimizing

Don't guess. Profile. Benchmark.
Premature optimization is evil.

### Optimize the Bottleneck

90/10 rule: 90% of time in 10% of code. Find it, fix it, move on.

### Cache Strategically

Cache expensive computations. Invalidate correctly.
Rule: if you cache, you must have invalidation strategy.

### Async for IO, Sync for Domain Logic

Python async helps with IO (DB, API calls, LLM). Domain logic should be synchronous pure functions.
For CPU-bound backtest: use DuckDB in-process or separate worker process.

---

## When These Conflict

Ordered by priority:
1. **Security** — never compromise
2. **Correctness** — working > fast
3. **Readability** — clear > clever
4. **Performance** — fast enough > fastest
5. **Conciseness** — short, when not sacrificing above

If fast and correct conflict: correct wins.
If clever and readable conflict: readable wins.
If terse and explicit conflict: explicit wins.
