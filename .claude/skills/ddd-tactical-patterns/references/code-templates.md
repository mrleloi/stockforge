# DDD Code Templates — Python / dataclasses

> Reference companion to `../SKILL.md`. Verbatim Python templates for the patterns the skill describes.

## Aggregate Root Template

```python
# packages/domain/analysis/models/thesis.py

from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum

from packages.domain.shared.aggregate_root import AggregateRoot
from packages.domain.shared.domain_event import DomainEvent
from packages.domain.analysis.value_objects.thesis_id import ThesisId
from packages.domain.analysis.value_objects.ticker import Ticker


class ThesisStatus(Enum):
    DRAFT = "draft"
    ACTIVE = "active"
    CLOSED = "closed"


@dataclass
class Thesis(AggregateRoot):
    id: ThesisId
    ticker: Ticker
    bull_case: BullCase
    bear_case: BearCase
    catalysts: list[Catalyst]
    confidence: ConfidenceScore
    status: ThesisStatus = ThesisStatus.DRAFT
    _events: list[DomainEvent] = field(default_factory=list, repr=False)

    def __post_init__(self) -> None:
        if not self.bear_case.is_substantive():
            raise InvariantViolation(
                "Thesis must include substantive bear case (charter principle 3)"
            )

    @classmethod
    def create(cls, ticker: Ticker, bull: BullCase, bear: BearCase) -> Thesis:
        thesis = cls(
            id=ThesisId.generate(),
            ticker=ticker,
            bull_case=bull,
            bear_case=bear,
            catalysts=[],
            confidence=ConfidenceScore.unknown(),
        )
        thesis._events.append(ThesisCreatedEvent(thesis.id, thesis.ticker, datetime.utcnow()))
        return thesis

    def add_catalyst(self, catalyst: Catalyst) -> None:
        if self.status != ThesisStatus.DRAFT:
            raise InvalidStateError(f"Cannot add catalyst when thesis is {self.status}")
        self.catalysts.append(catalyst)
        self._events.append(CatalystAddedEvent(self.id, catalyst.id))

    def submit(self) -> None:
        if self.status != ThesisStatus.DRAFT:
            raise InvalidStateError("Can only submit draft theses")
        if not self.bear_case.is_substantive():
            raise InvariantViolation("Bear case must be substantive before submitting")
        self.status = ThesisStatus.ACTIVE
        self._events.append(ThesisSubmittedEvent(self.id, self.ticker, datetime.utcnow()))

    def get_events(self) -> list[DomainEvent]:
        return list(self._events)

    def clear_events(self) -> None:
        self._events.clear()
```

## Value Object Template

```python
# packages/domain/shared/value_objects/ticker.py

from dataclasses import dataclass

@dataclass(frozen=True)
class Ticker:
    value: str

    def __post_init__(self) -> None:
        if not self.value or not self.value.isupper():
            raise ValueError(f"Ticker must be uppercase: {self.value!r}")
        if len(self.value) > 10:
            raise ValueError(f"Ticker too long: {self.value!r}")

    @classmethod
    def from_str(cls, value: str) -> "Ticker":
        return cls(value=value.strip().upper())

    def __str__(self) -> str:
        return self.value
```

## Repository Pattern (Protocol + Implementation)

Protocol in domain (pure typing), implementation in infrastructure:

```python
# packages/domain/analysis/repositories/thesis_repository.py

from typing import Protocol
from packages.domain.analysis.models.thesis import Thesis
from packages.domain.analysis.value_objects.thesis_id import ThesisId
from packages.domain.shared.value_objects.ticker import Ticker


class ThesisRepository(Protocol):
    async def save(self, thesis: Thesis) -> None: ...
    async def find_by_id(self, id: ThesisId) -> Thesis | None: ...
    async def find_by_ticker(self, ticker: Ticker) -> list[Thesis]: ...


# packages/infrastructure/analysis/persistence/thesis_postgres_repository.py

class ThesisPostgresRepository:
    def __init__(self, db: DatabaseClient) -> None:
        self._db = db

    async def save(self, thesis: Thesis) -> None:
        async with self._db.transaction() as tx:
            # Upsert thesis
            # Insert domain events
            pass

    async def find_by_id(self, id: ThesisId) -> Thesis | None:
        row = await self._db.fetch_one("SELECT ... FROM theses WHERE id = $1", str(id))
        if not row:
            return None
        return self._to_domain(row)
```

## Cross-BC Contract

```python
# packages/contracts/events/thesis_events.py
from dataclasses import dataclass

@dataclass(frozen=True)
class ThesisCreatedEventContract:
    thesis_id: str
    ticker: str
    created_at: str  # ISO timestamp

# In Analysis BC: publish ThesisCreatedEvent (uses contract shape)
# In Portfolio BC: subscribe to ThesisCreatedEventContract
#   → add to watchlist
```

## Anti-Corruption Layer (ACL)

```python
# packages/infrastructure/fundamental/external/vnstock_adapter.py

class VnstockAdapter:
    def to_financial_statement(self, raw: dict) -> FinancialStatement:
        # Validate required fields
        if not raw.get("symbol"):
            raise MissingFieldError("symbol")
        if not raw.get("year"):
            raise MissingFieldError("year")

        # Transform from external schema to domain
        return FinancialStatement(
            ticker=Ticker.from_str(raw["symbol"]),
            period_end=date(raw["year"], raw.get("quarter", 12), 31),
            filing_date=date.fromisoformat(raw.get("filing_date", raw["year"] + "-03-31")),
            revenue=Money.vnd(raw["revenue"]),
            # ... other fields
        )
```

## Anemic vs Rich Model

**Anti-pattern — Anemic Model** (logic lives in service, model is a data bag):

```python
# BAD
@dataclass
class Thesis:
    id: str
    status: str
    bear_case: str

class ThesisService:
    def submit(self, thesis: Thesis) -> None:
        if thesis.status != 'draft':
            raise Exception("...")
        thesis.status = 'active'  # direct mutation — wrong
```

**Correct — Rich Model** (logic in the model itself):

```python
# GOOD
@dataclass
class Thesis(AggregateRoot):
    def submit(self) -> None:
        if self.status != ThesisStatus.DRAFT:
            raise InvalidStateError(...)
        if not self.bear_case.is_substantive():
            raise InvariantViolation(...)
        self.status = ThesisStatus.ACTIVE
        self._events.append(ThesisSubmittedEvent(...))
```
