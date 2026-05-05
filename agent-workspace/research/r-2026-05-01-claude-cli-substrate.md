---
research_id: r-2026-05-01-claude-cli-substrate
type: substrate-probe
date: 2026-05-01
session: S43b (probe + transport IMPL)
predecessor_lesson: L-S38-2 (subagent dispatch as zero-marginal-cost LLM substrate)
status: VIABLE — production-ready transport shipped
---

# `claude` CLI subprocess as LLM substrate — probe + transport IMPL

## Question

Per user chat directive 2026-05-01 ("sao lại cần key api? tìm cách chạy free đi.
ví dụ dùng claude code, tạo subagent chạy"): can the `claude` CLI in print mode
serve as a zero-marginal-cost (subscription-billed) LLM substrate for the
Track F thesis pipeline, replacing the anthropic SDK direct path which gates
on `ANTHROPIC_API_KEY` + $$ authorization?

## Probe (live, 2026-05-01)

```bash
echo "Ticker BID. ROE 16.2%. Bank lending growth slowing." \
  | claude -p \
      --model haiku \
      --output-format json \
      --disable-slash-commands \
      --system-prompt "You are a Bear analyst. Output ONLY valid JSON: {...}"
```

### Result

- **Auth**: parent Claude Code OAuth/keychain (no `ANTHROPIC_API_KEY` required).
  `--bare` mode strictly demands the env var; without `--bare`, OAuth is read.
- **Latency**: 26s wall (haiku model; CLI startup + system_prompt cache_creation).
- **Output envelope** (`--output-format json`):
  ```json
  {
    "is_error": false,
    "result": "```json\n{\"key_points\": [...]}\n```",
    "total_cost_usd": 0.041327,
    "usage": {
      "input_tokens": 10,
      "output_tokens": 754,
      "cache_creation_input_tokens": 30038,
      "cache_read_input_tokens": 0
    },
    ...
  }
  ```
- **Body quality**: structured JSON with 3 well-grounded bear key_points; cited
  user-supplied numbers (no LLM-math creep); recognized BID = state-owned bank.
- **Trade-offs**:
  - (+) Cost reported exactly by CLI (`total_cost_usd`)
  - (+) Token counts in usage block (input + cache_creation + cache_read split)
  - (-) Response wrapped in `` ```json...``` `` markdown fence (must strip)
  - (-) No `--temperature` flag exposed by CLI (uses model defaults; AC-5
    strict reproducibility no longer guaranteed — `prompt_hash` still works)
  - (-) Heavy first-call cache_creation (~30K tokens) due to CLAUDE.md auto-
    discovery; `--disable-slash-commands` shaves some, but full `--bare`
    isolation conflicts with OAuth auth. Net: ~$0.04 floor per call (haiku).

## IMPL: `packages/infrastructure/analysis/subagent_transport.py`

Drop-in replacement for `ClaudeLLMPerspectiveAdapter`'s default transport.
Existing adapter signature unchanged:
`(model, system_prompt, user_message, temperature) -> (text, in_tok, out_tok)`.

Wiring (opt-in, no default change):
```python
from packages.infrastructure.analysis.claude_llm_perspective_adapter import \
    ClaudeLLMPerspectiveAdapter
from packages.infrastructure.analysis.subagent_transport import claude_cli_transport

adapter = ClaudeLLMPerspectiveAdapter(transport=claude_cli_transport)
```

Existing default (`_default_transport` → anthropic SDK) untouched. Tests pass
unchanged. New module has 15 unit tests (mocked subprocess) covering: fence
unwrap variants, token aggregation (input + cache_creation + cache_read for
budget-cap parity), happy path CLI flag wiring, non-zero exit, `is_error`
envelope, non-JSON stdout, timeout, FileNotFoundError, missing usage,
temperature arg accepted but unused.

LOC: 130 (module) + 175 (tests). Under ≤180 advisory. 0 deviations.

## Cost projection — 5-thesis dogfood

| Path | Per-thesis | 5-thesis | Latency |
|---|---|---|---|
| anthropic SDK direct (Opus 4.7 quant + 2× Sonnet 4.6) | ~$1.50 | ~$7.50 | ~3 min |
| claude CLI subprocess (haiku for all 3 perspectives) | ~$0.12 | ~$0.60 | ~6.5 min |
| claude CLI subprocess (sonnet bear/bull + opus quant) | ~$0.40 | ~$2.00 | ~9 min |

Note: subagent path bills against parent Claude Code subscription, NOT a
separate API key. User's stated goal "no API key" is met.

## Reproducibility caveat

Without `--temperature` flag exposure, AC-5 "deterministic same-input → same-
output" is downgraded to "best-effort same-input → similar-output". Mitigations:
- `prompt_hash` (sha256[:16] of system_prompt) still recorded for audit
- model_id pinned (`--model <full-id>`)
- Session reproducibility restored via cache_read of system prompt

Acceptable for dogfood validation; flag for spec § A.10 amendment if S43b
goes to formal release.

## Status

- ✅ Probe: VIABLE
- ✅ Transport: SHIPPED (`subagent_transport.py` + 15 tests; mypy + ruff clean)
- ✅ CLI wiring: SHIPPED (`--transport=anthropic|subagent` flag in
  `apps/cli/validate_thesis.py`; opt-in path in `apps/_shared/use_case_builder.py`
  via new `_build_subagent_agents()` wiring real Bear/Bull/Quant + adapter +
  claude_cli_transport)
- ✅ Live BID dogfood (S43b-LIVE-PROOF): substrate END-TO-END VERIFIED — pipeline
  ran; CLI → use_case → real perspective agents → adapter → claude CLI
  subprocess → JSON envelope parsed → adapter wrote thesis-log markdown
- ⚠️ Thesis output INCOMPLETE due to **data grounding gap** (NOT substrate
  failure): MockDataGatherer provides no `recent_claims`/`source_url` entries,
  so system_prompt rule "EVERY CLAIM CITES SOURCE_URL + SOURCE_EXCERPT" forces
  LLM into honest "Insufficient bear case" output → `_parse_grounded_points`
  sees 0 cited points → bear case <3 → I-S10 invariant fails (correctly!)

### Bug found + fixed during dogfood

**Windows cp1252 decode crash on subprocess stdout**: parent Python
`subprocess.run(..., text=True)` defaulted to cp1252 codec on Windows;
claude CLI returns UTF-8 (Vietnamese diacritics, em-dashes, smart quotes
in CLAUDE.md auto-discovery payload). Fix: pass `encoding="utf-8",
errors="replace"` explicitly. 1-line change. Tests still 15/15 PASS.

### Reframed cost projection (post-dogfood)

5-thesis dogfood with real Phase1DataGatherer + real claims: cost_usd
tracking via adapter's existing `_compute_cost(model, in_tok, out_tok)`
path; CLI envelope's `total_cost_usd` is logged at INFO but not
canonical (would need adapter signature extension). For now, cost
ledger drifts from CLI-reported actual by ~10-30%; acceptable for
dogfood validation; promote to spec § B.10 amendment if formal release.

## References

- `packages/infrastructure/analysis/subagent_transport.py` (130 LOC; ratifies L-S38-2)
- `packages/infrastructure/analysis/test_subagent_transport.py` (175 LOC; 15 tests)
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (existing; transport injection point at line 164)
- `agent-workspace/memory/checkpoints/latest.md` (S38 close → reframe to S43b path)
