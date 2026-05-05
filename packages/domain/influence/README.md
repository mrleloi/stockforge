# BC-6: Influence Network ⭐ (the edge)

> Tier 3 (Influence Network) — KOL channels + per-KOL credibility calibration. Compounding moat over 12-24 months.

**Responsibility**: KOL channel monitoring, recommendation extraction, credibility scoring, calibration.

**Aggregates**: Kol, Channel, Recommendation, CredibilityScore, InfluenceCluster

**Storage**: Postgres for KOL profiles + recommendations + calibration; R2 for video/podcast transcripts.

**Sources** (Phase 1-2):
- YouTube channels — yt-dlp + Whisper transcription
- Facebook fanpages (public, ToS-respecting) — read-only
- Telegram public channels — read-only bot
- Podcasts — RSS + Whisper
- Personal blogs / Substack

**LLM role**:
- Extract recommendations (timestamp, intent: STRONG_BUY|BUY|WATCH|NEUTRAL|AVOID|STRONG_AVOID, conditions, timeframe)
- Detect coordinated messaging (same KOL, multiple stocks, pattern)
- Classify KOL style (FUNDAMENTAL | TECHNICAL | NARRATIVE | PUMPER | MIXED)
- Identify view-flips (was bullish, now bearish — flip-flop frequency)

**Calibration database**: per-KOL hit rate over time; sector-specific scores; Bayesian confidence interval. After 12 months → statistically meaningful per-KOL credibility.

See `specs/tier2-feature/002-influence-network-tracking.md` for full implementation.
