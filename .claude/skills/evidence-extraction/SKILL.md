---
name: evidence-extraction
description: Extract structured claims from unstructured sources with citation integrity. Use when building extraction pipelines, parsing news articles or KOL transcripts, or anywhere claims are created from raw data. Ensures every claim has source_url, extracted_at, confidence, and verified attribution. Enforces no-LLM-math invariant (I-S1).
---

# Skill: Evidence Extraction

## Purpose

Turn raw data (news articles, KOL transcripts, broker reports) into structured `ExtractedClaim` or `KolRecommendation` objects that satisfy the citation integrity invariant (I-1, I-2, I-S1).

## Core Invariant

Every extracted item MUST have:
- `source_url` (where from)
- `extracted_at` (when extracted)
- `confidence` (0-1, our assessment of extraction quality)
- `text` (the claim in words)
- `type` (claim type enum)

**No LLM math**: If LLM output contains a number (e.g., "ROE is approximately 18%"), that number MUST trace to a deterministic code call, not LLM free-form output. LLM may only extract/classify — not compute.

Claim without metadata = bug, blocks merge (DR5).

## Process

### 1. Fetch Source
```python
source = await source_fetcher.fetch(url)
# source has: url, fetched_at, content, content_type
```

### 2. Parse for Candidate Claims
LLM call with extraction prompt:
- Input: source content + claim schema
- Output: list of candidate claims (text and type only — no numbers computed by LLM)
- If numbers are needed: LLM extracts the raw text, deterministic code parses the number

### 3. Verify Each Claim
For each candidate:
- Does the claim actually appear in source?
- Does it match source wording or is it paraphrased?
- Could a reasonable person disagree with this claim given the source?

### 4. Assign Confidence
- 0.9+ : exact quote from authoritative source
- 0.7-0.9 : reasonable paraphrase from good source
- 0.5-0.7 : inference from source content
- <0.5 : reject (not evidence, it's opinion)

### 5. Store with Metadata

```python
from packages.domain.news.models.extracted_claim import ExtractedClaim
from packages.domain.news.value_objects.claim_type import ClaimType

claim = ExtractedClaim.create(
    text="Ngân hàng VCB báo lợi nhuận quý 1/2026 tăng 18% so với cùng kỳ",
    source_url="https://cafef.vn/vcb-q1-2026-profit.html",
    extracted_at=datetime.utcnow(),
    confidence=0.90,
    claim_type=ClaimType.EARNINGS_GROWTH,
    source_excerpt="Ngân hàng TMCP Ngoại thương Việt Nam (VCB) công bố lợi nhuận trước thuế quý 1/2026 đạt X nghìn tỷ, tăng 18% so với cùng kỳ năm 2025...",
    extractor_version="v1.2",
)
# NOTE: The "18%" here was extracted from source text, not computed by LLM.
# If LLM had said "growth is approximately 18%", that would be I-S1 violation.
```

## KOL Recommendation Extraction

KOL recommendations have stricter requirements — they feed the calibration database:

```python
from packages.domain.influence.models.kol_recommendation import KolRecommendation
from packages.domain.influence.value_objects.direction import Direction

rec = KolRecommendation.create(
    kol_id=kol.id,
    ticker=Ticker.from_str("VCB"),
    direction=Direction.BUY,
    timeframe=Timeframe.THREE_MONTHS,
    confidence_extracted=0.85,  # how sure LLM is about extraction quality
    # NOT a recommendation strength — that's for users to judge
    source_url="https://youtube.com/watch?v=abc123&t=1234",
    source_type=SourceType.YOUTUBE_VIDEO,
    published_at=datetime(2026, 4, 20),
    extracted_at=datetime.utcnow(),
)
```

## Anti-Patterns

**Don't**:
- Generate claims from general knowledge (hallucination)
- Let LLM output numbers it computed (I-S1 violation — no LLM math)
- Paraphrase so much that it's no longer from source
- Skip verification "because the source is trustworthy"
- Store claims without `source_url`
- Confuse `confidence_extracted` (quality of extraction) with recommendation strength

**Do**:
- Quote directly when possible (preserve source excerpt)
- Verify extraction by re-reading source
- Flag uncertainty with low confidence rather than rejecting
- Prefer specific claims over vague ones
- Run deterministic parsing code for numbers; LLM classifies/extracts text only

## Related

- `prompt-engineering` — for extraction prompt design
- `crawler-reliability` — for source fetching
- `constitution/invariants.md` — I-1 through I-S5
