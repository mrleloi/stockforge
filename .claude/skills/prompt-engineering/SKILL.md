---
name: prompt-engineering
description: Design and optimize LLM prompts for StockForge pipeline stages. Use when writing or refining prompts for claim extraction, KOL recommendation extraction, sentiment analysis, thesis synthesis. Covers context assembly, prompt caching strategy, budget-aware prompts, structured output. Enforces no-LLM-math constraint.
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
---

# Skill: Prompt Engineering

## Purpose

LLM prompts are data, not code. Treat them with the same rigor as schemas — versioned, reviewed, A/B tested.

**Critical constraint** (charter principle 9 / I-S1): LLM prompts NEVER ask the LLM to compute numbers. LLM classifies, extracts, reasons. Deterministic code computes.

## When to Use

- Authoring a new extractor (claim, KOL recommendation, sentiment)
- Refining an existing prompt for cost / accuracy
- Adding a new analysis agent (bear / bull / critic / quant / behavior)
- Synthesizing a thesis with multi-source context
- Investigating an output schema violation or hallucinated number

## Where Prompts Live

`prompts/` directory — NOT inline in Python (DR4 hook flags violations):

```
prompts/{extraction,analysis,synthesis,_shared}/
```

## Mandatory Frontmatter

Every `prompts/**/*.md` MUST include:

```yaml
---
version: 1.0
owner: <team>
purpose: <one line>
input_schema: <DTO>
output_schema: <DTO>
model: claude-sonnet-4-6   # or opus for synthesis
expected_input_tokens: ~N
expected_output_tokens: ~N
no_llm_math: true          # BLOCKING — drift hook scans for it
---
```

Missing `no_llm_math: true` = HIGH severity drift violation.

## No-LLM-Math Pattern (load-bearing)

**Wrong** — LLM computes a number:
> "Given the financial data below, compute the P/E ratio and assess..."

**Correct** — code computes, LLM only classifies the already-computed number:

```
P/E ratio is 12.3 (computed by `compute_pe(price, eps)`).
Classify as: undervalued | fair_value | overvalued | cannot_assess
Historical sector range: 8.5 - 18.2. Do not recompute.
```

Numbers flow IN as facts; the LLM never produces a number absent from its input. See `references/prompt-templates.md` § No-LLM-Math for full wrong/correct code blocks.

## Caching

Anthropic prompt cache — 10× cost reduction + cached content sits at context head (highest attention).

| Cache (stable) | Don't cache (per-call) |
|---|---|
| System instructions | Article content / transcript |
| Output schemas | Current timestamp |
| Few-shot examples | Ticker-specific data |
| Domain glossary excerpt | Pre-computed signals |

Mark with `cache_control: {"type": "ephemeral"}`. See `references/prompt-templates.md` § Caching.

## Budget + Validation

- Every LLM call wraps via `with_budget(max_cost_usd=..., session_id=..., purpose=...)` (throws BEFORE call if cost projection exceeds cap)
- Every LLM output validates via Pydantic DTO at infrastructure boundary (NOT in domain). Retry on parse error, max 2; then degrade.

Code in `references/prompt-templates.md` § Budget + § Pydantic.

## Failure Modes

| Symptom | Action |
|---|---|
| Output not valid JSON | Retry with stricter format reminder; max 2; mark failed |
| LLM produced number not in input | Flag I-S1 violation; reject output |
| Budget exceeded mid-batch | Graceful degrade; return partial; schedule continuation |
| Output `confidence > 1.0` | Field validator rejects; do NOT clamp silently |

## Validation Pre-Conditions

- File lives under `prompts/**/*.md` (DR4 enforces)
- Frontmatter has `no_llm_math: true`
- Prompt does NOT contain "compute" / "calculate" / "what is X%" near a number request
- Output schema has matching DTO under `packages/infrastructure/llm/dtos/`
- Stable sections marked `cache_control`

## Anti-Patterns

**Don't**:
- Hardcode prompts in `.py` (DR4 catches)
- Skip output schema validation
- Forget `cache_control` on stable sections (10× wasted cost)
- Trust LLM output as ground truth without source-quote check
- Ask LLM for ratios, percentages, prices, ranks (I-S1)
- Ask LLM for a single "buy/sell/hold" score (must be multi-criteria — charter principle 2)

**Do**:
- Version prompts in git
- A/B test variants against an eval set
- Cache stable content aggressively
- Log tokens + cost per call to `agent-workspace/calibration/`
- Pre-compute every number in Python; feed as fact for classification only

## Smoke Test

For "extract claims from a CafeF article":

Expected:
- File at `prompts/extraction/claim-from-article.md`
- Frontmatter has `no_llm_math: true`, `output_schema: ClaimListDTO`
- System prompt: "Use direct quotes", "NEVER compute ratios — extract numbers verbatim"
- `{{article_content}}` placeholder; output schema cached
- Python wrapper uses `with_budget(...)` + `ClaimListDTO.model_validate_json(...)`

If proposal asks LLM to "calculate" or "estimate" a number → reject.

## See Also

- `references/prompt-templates.md` — full frontmatter + no-llm-math + caching + budget + Pydantic + context-assembly checklist
- `evidence-extraction` SKILL.md — consumes these prompts
- `agent-workspace/constitution/drift-signals.md` — DR3 / DR4
- `agent-workspace/constitution/invariants.md` — I-S1 authoritative spec
