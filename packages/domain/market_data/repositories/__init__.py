"""BC-1 Market Data — repository Protocols (interfaces only; impls live in
packages/infrastructure/market_data/ per architecture.md § Layer Hierarchy).
"""

from .bar_repository import BarRepository

__all__ = ["BarRepository"]
