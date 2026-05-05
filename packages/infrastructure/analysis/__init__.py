"""BC-8 Analysis — infrastructure layer barrel export.

Contains concrete adapters implementing domain Protocols:
- BearPerspectiveAgent / BullPerspectiveAgent / QuantPerspectiveAgent
- ClaudeLLMPerspectiveAdapter (Anthropic SDK wrapper)
- Phase1Synthesizer (deterministic synthesis logic)
- Phase1DataGatherer (orchestrates BC-1 + BC-2 + BC-5 reads)
- SqliteThesisRepository (ThesisRepository Protocol impl)
- InProcessCostTracker (CostTrackerPort Protocol impl)

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.6.
"""

from __future__ import annotations
