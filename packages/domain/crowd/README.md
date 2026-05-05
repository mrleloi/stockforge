# BC-7: Crowd Sentiment ⭐ (the edge)

> Tier 4 (Crowd Sentiment & Pump Detection) — forums + groups + comments. Typically lags price (exhaustion signal).

**Responsibility**: Forum/group/comment sentiment, pump pattern detection, narrative lifecycle tracking.

**Aggregates**: SentimentSnapshot, PumpDetection, Narrative, NarrativePhase, CoordinationCluster

**Storage**: TimescaleDB for sentiment time-series; Postgres for narratives + pump detections; R2 for raw posts (sample only, 90-day retention unless flagged).

**Sources** (Phase 2):
- F319 (forum cổ phiếu)
- VFPress
- Comments on CafeF/Vietstock articles
- Public Facebook groups (read-only, never private)
- Public Telegram broadcast channels
- VN finance Twitter/X

**LLM role**:
- Classify Vietnamese sentiment categorically — NEVER numeric scores
- Detect coordinated posting (template detection, timing clustering)
- Identify narrative themes
- Extract pump signatures (specific language patterns)
- Compare to historical labeled pump cases

**Pump phases**: PRE_PUMP | PUMP | DISTRIBUTION | DUMP | UNCERTAIN. Each detection cites contributing signals + historical similar cases.

**Narrative phases**: INCUBATION | EMERGING | MAINSTREAM | SATURATION | EXHAUSTION | REVERSAL.

See `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` for full implementation.
