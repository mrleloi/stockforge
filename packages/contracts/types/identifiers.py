"""BarId + PositionId — type-discipline aliases over str.

NewType makes mypy --strict reject passing a BarId where a PositionId is
expected (and vice versa), even though both are strings at runtime. This
catches a class of cross-BC argument-order bugs that plain `str` does not.

new_bar_id() / new_position_id() factories generate UUID4 strings — the
domain layer never depends on uuid module beyond construction (no version
check, no namespace). Construction is the only seam where the str-based
NewType is created.
"""

from __future__ import annotations

import uuid
from typing import NewType

__all__ = ["BarId", "PositionId", "new_bar_id", "new_position_id"]


BarId = NewType("BarId", str)
PositionId = NewType("PositionId", str)


def new_bar_id() -> BarId:
    """Generate a fresh BarId from a UUID4 string."""
    return BarId(str(uuid.uuid4()))


def new_position_id() -> PositionId:
    """Generate a fresh PositionId from a UUID4 string."""
    return PositionId(str(uuid.uuid4()))
