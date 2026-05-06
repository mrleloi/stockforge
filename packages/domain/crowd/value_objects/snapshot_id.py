"""SnapshotId — typed string wrapper for SentimentSnapshot identity.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1.
"""

from __future__ import annotations

__all__ = ["SnapshotId"]

# Thin typed alias — str subclass avoids introducing framework dependency
SnapshotId = str
