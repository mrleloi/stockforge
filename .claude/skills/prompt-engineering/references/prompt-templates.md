# Prompt Templates — Full Examples

> Reference companion to `../SKILL.md`. Verbatim templates and code blocks.

## Full Prompt File Template

```markdown
---
version: 1.0
owner: analysis-team
purpose: Extract claims from single news article
input_schema: ArticleContent
output_schema: ClaimList
model: claude-sonnet-4-6
expected_input_tokens: ~3000
expected_output_tokens: ~500
no_llm_math: true  # REQUIRED
---

# [System Prompt]

You are a claim extraction specialist for Vietnamese financial news. Your job is
to identify factual claims in the provided article and output them in structured
format.

## Rules
1. Every claim must be supported by explicit text in the article
2. Do not infer, interpret, or paraphrase heavily
3. Use direct quotes when possible
4. Assign confidence based on source clarity
5. **NEVER compute financial ratios or percentages yourself** — extract numbers
   verbatim from source text only. If a number is in the article, copy it.
   Do not calculate.

## Output Format
Return JSON matching this schema:
{
  "claims": [
    {
      "text": "...",
      "source_excerpt": "...",
      "confidence": 0.0-1.0,
      "type": "revenue_growth | profit | market_share | ..."
    }
  ]
}

# [User Message Template]

Article content:
{{article_content}}

Extract claims.
```

## No-LLM-Math — Wrong vs Correct

**Wrong**:

```markdown
# System
Given the financial data below, compute the P/E ratio and assess if it's attractive.
```

**Correct** (code computes, LLM classifies):

```python
# Step 1: Code computes P/E
pe_ratio = compute_pe(price=stock.price, eps=fundamentals.eps)

# Step 2: LLM only classifies the already-computed number
prompt = f"""
Given P/E ratio of {pe_ratio:.1f} for {ticker} in the {sector} sector,
classify as: undervalued | fair_value | overvalued | cannot_assess

Historical sector P/E range: {sector_pe_5th:.1f} - {sector_pe_95th:.1f}
Current market P/E: {market_pe:.1f}

Return classification only. Do not recompute the ratio.
"""
```

## Caching — Stable vs Dynamic Split

```python
# What to cache (stable):
cached_section = [
    system_instructions,
    output_schemas,
    few_shot_examples,
    domain_context,  # Vietnamese stock glossary excerpt
]

# What NOT to cache (varies per call):
dynamic_section = [
    article_content,
    current_timestamp,
    ticker_specific_data,
]

response = await claude.messages.create(
    model="claude-sonnet-4-6",
    system=[
        {
            "type": "text",
            "text": section,
            "cache_control": {"type": "ephemeral"},
        }
        for section in cached_section
    ],
    messages=[{
        "role": "user",
        "content": "\n".join(dynamic_section),
    }],
)
```

## Budget Wrapper

```python
from packages.infrastructure.llm.budget import with_budget

result = await with_budget(
    max_cost_usd=0.50,
    session_id=context.session_id,
    purpose="claim-extraction",
)(claude.messages.create)(model="claude-sonnet-4-6", ...)
```

If projected cost would exceed cap, function throws BEFORE the call.

## Structured Output — Pydantic DTO

```python
from pydantic import BaseModel, field_validator

class ExtractedClaimDTO(BaseModel):
    text: str
    source_excerpt: str
    confidence: float
    claim_type: str

    @field_validator("confidence")
    @classmethod
    def validate_confidence(cls, v: float) -> float:
        if not 0 <= v <= 1:
            raise ValueError(f"Confidence must be 0-1, got {v}")
        return v

class ClaimListDTO(BaseModel):
    claims: list[ExtractedClaimDTO]

# After LLM returns:
try:
    parsed = ClaimListDTO.model_validate_json(response.content[0].text)
except Exception as e:
    # Retry with error feedback, or log and move on
    logger.warning("LLM output parse failed", error=str(e))
```

## Context Assembly Checklist (Thesis Synthesis)

For complex analysis prompts, assemble in this order:

1. **Core instruction** (stable, cached) — adversarial-by-default, no LLM math
2. **Domain context** (glossary excerpt, Vietnam market context — cached if stable)
3. **Pre-computed signals** (from deterministic code — NOT asked from LLM)
4. **Task-specific data** (dynamic — thesis claims, KOL recs, sentiment scores)
5. **Output schema** (cached)

The LLM sees: stable cached content first → dynamic input → must produce structured output. This ordering matches Anthropic's attention-first cache placement.
