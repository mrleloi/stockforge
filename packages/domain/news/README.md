# BC-5: News Stream

> Tier 2 (Official Narrative) — mainstream news + broker reports + government disclosures.

**Responsibility**: Mainstream financial news ingestion, claim extraction, sentiment, contradiction detection.

**Aggregates**: NewsArticle, ExtractedClaim, NewsCluster, NewsSentimentScore

**Storage**: Postgres for metadata + extracted claims; R2 for full article text; pgvector for semantic search.

**Sources** (Phase 1):
- CafeF (cafef.vn) — most popular VN financial news
- Vietstock News (vietstock.vn) — second most popular
- NDH (nhipcaudautu.vn) — quality analysis
- VietnamBiz, Đầu Tư Chứng Khoán
- Broker reports: SSI, HSC, VCSC, VND, FPTS public summaries

**LLM role**:
- Extract structured claims from unstructured news
- Classify sentiment categorically (STRONGLY_BULLISH | BULLISH | NEUTRAL | BEARISH | STRONGLY_BEARISH) — NEVER numeric
- Identify mentioned entities (tickers, sectors, people)
- Detect contradictions between sources
- Cluster related stories

**Update cadence**: news polling every 10 min; broker reports daily 18:00; regulatory every 4 hours.
