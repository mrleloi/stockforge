"""Money — VN-domain monetary value object with currency discipline.

Phase 1 scope: VND only (per spec 000 § A.5 "Multi-currency portfolio: VND
only"). Cross-currency arithmetic raises CurrencyMismatchError per Rule 5
+ I-S6, even though Phase 1 has no FX path — discipline ships now to prevent
silent type confusion when Phase 2 introduces USD comparables.

Per agent-workspace/constitution/financial-data-protocol.md § Rule 5 +
constitution/invariants.md § I-S6 "Currency Always Specified": every Money
value carries currency; default VND for domestic data.
"""

from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal
from enum import StrEnum

__all__ = ["Currency", "Money", "CurrencyMismatchError"]


class Currency(StrEnum):
    """ISO 4217 currency codes. Phase 1 uses VND only.

    `StrEnum` for transparent JSON / TSV serialization (matches state_machine
    HookEventState pattern in packages/observability/state_machine.py).
    """

    VND = "VND"
    USD = "USD"


class CurrencyMismatchError(ValueError):
    """Raised when arithmetic mixes Money values of different currencies."""

    def __init__(self, left: Currency, right: Currency) -> None:
        super().__init__(
            f"cannot operate on Money({left.value}) with Money({right.value}); "
            f"explicit convert(target_currency, as_of_rate) required per Rule 5"
        )
        self.left = left
        self.right = right


@dataclass(frozen=True, slots=True)
class Money:
    """Immutable monetary amount with currency tag.

    Decimal precision avoids float-pennies issues common in finance code.
    Arithmetic enforces matching currency — silent VND+USD addition would
    corrupt portfolio valuation; explicit FX conversion is mandatory.
    """

    amount: Decimal
    currency: Currency = Currency.VND

    def __post_init__(self) -> None:
        if not isinstance(self.amount, Decimal):
            object.__setattr__(self, "amount", Decimal(str(self.amount)))
        if not isinstance(self.currency, Currency):
            raise TypeError(
                f"Money.currency must be Currency enum, got {type(self.currency).__name__}"
            )

    def __add__(self, other: Money) -> Money:
        if not isinstance(other, Money):
            return NotImplemented
        if self.currency != other.currency:
            raise CurrencyMismatchError(self.currency, other.currency)
        return Money(self.amount + other.amount, self.currency)

    def __sub__(self, other: Money) -> Money:
        if not isinstance(other, Money):
            return NotImplemented
        if self.currency != other.currency:
            raise CurrencyMismatchError(self.currency, other.currency)
        return Money(self.amount - other.amount, self.currency)

    def __mul__(self, scalar: int | Decimal) -> Money:
        if isinstance(scalar, (int, Decimal)):
            return Money(self.amount * Decimal(str(scalar)), self.currency)
        return NotImplemented

    def __rmul__(self, scalar: int | Decimal) -> Money:
        return self.__mul__(scalar)

    def __str__(self) -> str:
        return f"{self.amount} {self.currency.value}"
