"""EvalPartition — strict separation between holdout and training data (BR-2).

Per spec 005 § A.3 M-1 + BR-2: 30% of evaluation data is HOLDOUT (never used for
training / prompt-refinement). The outer loop's final composite metric is ALWAYS
computed on HOLDOUT. TRAINING items can feed prompt-refinement experiments but
NEVER the eval pipeline.

EvalSetStore enforces BR-2 by exposing distinct `iter_holdout` and `iter_training`
methods — there is no public method that mixes the two.
"""

from __future__ import annotations

from enum import Enum

__all__ = ["EvalPartition"]


class EvalPartition(str, Enum):
    HOLDOUT = "holdout"
    TRAINING = "training"
