"""BC-5 News infrastructure — per-source crawler adapters."""

from .cafef_adapter import CafeFAdapter
from .ndh_adapter import NDHAdapter
from .vietstock_adapter import VietstockAdapter

__all__ = ["CafeFAdapter", "NDHAdapter", "VietstockAdapter"]
