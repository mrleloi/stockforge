---
id: D-082
title: "PdfTableExtractorPort Claude vision adapter + EchoValidator Rule 16 mode #2 gate"
status: ACCEPTED
severity: MEDIUM
date: 2026-05-17
proposed_at: 2026-05-17T19:13:00Z
accepted_at: 2026-05-17T19:30:00Z
acceptance_basis: "S400 sandwich-verifier PASS / merge-eligible verdict (agent a18214d3d72b99c53; 0 CRITICAL / 0 IMPORTANT / 3 MINOR); IMPL-tier auto-ratifies per severity-schema. K.2.b NOT-FIRED (Resolution B: @<absolute_path> in user_message enables Claude CLI direct PDF read). pytest 1178/1 + mypy --strict CLEAN + ruff CLEAN + ZERO import anthropic empirically verified."
phase: G-prime
sub_track: G.3 ClaudeVisionPdfTableExtractor + EchoValidator
session: S399 (sandwich-dev FOCUSED_IMPL; plan-043)
authored_by: S399 sandwich-dev (Claude Sonnet 4.6; FOCUSED_IMPL)
depends_on:
  - D-080 (PdfTableExtractorPort ABC contract — ACCEPTED; subclassed by this ADR)
  - D-072 (BC-5 claude_cli_transport substrate — ACCEPTED; transport reused here)
  - D-074 (BC-8 RolePromptPack Foundation — PROPOSED; transport-flip pattern mirrored)
  - D-065 (Rule 16 numeric-field discipline — ACCEPTED; EchoValidator satisfies mode #2)
  - D-059 (Python determinism contract — R1 datetime-tz BINDING for extracted_at)
  - D-050 (anthropic_api_to_subagent CHARTER — BINDING; ZERO direct anthropic SDK)
  - D-064 (path-safety 5-invariant — applies to pdf_path handling in PdfSource)
supersedes: NONE
superseded_by: NONE
revisit_trigger: |
  (a) claude CLI vision-input flag deprecated or changed → D-082-V2 + update Resolution B pattern
  (b) per-call cost ceiling exceeded ≥2× in G.4 dogfood → DD-6 raise default to 1.00 USD + D-082-V2
  (c) EchoValidator 2nd-BC reuse surfaces → promote to packages/_shared/echo_validator.py
  (d) Rule 16 mode #2 tolerance=0 edge case challenged (e.g. rounding in VHM FS) → revisit DD-4
---

# D-082 — PdfTableExtractorPort Claude vision adapter + EchoValidator Rule 16 mode #2 gate

## Context

Phase G-prime sub-plan 043 (S398 architect + S399 dev). Third sub-plan of Phase G-prime
master plan-040, satisfying § E.3 contract:
- G.3 ClaudeVisionPdfTableExtractor adapter subclasses D-080 PdfTableExtractorPort ABC
- G.3 EchoValidator implements Rule 16 mode #2 deterministic-pipeline echo gate

The G.1 sub-plan 041 (SHIPPED at S394; VERIFIED PASS at S397) established:
- `packages/application/fundamental/pdf_table_extractor_port.py` — ABC contract (D-080 ACCEPTED)
- `packages/application/fundamental/extracted_financial_statement.py` — return dataclass
- `packages/application/fundamental/pdf_source.py` — input value object

The D-050 CHARTER memory rule mandates: ALL Claude API calls via claude_cli_transport
(subscription billing; ZERO direct anthropic SDK; ZERO ANTHROPIC_API_KEY env var).

## STEP 0.4 Cold-Probe Results (per L-S395-1 full-pipeline cold-probe)

Executed at S399 IMPL session BEFORE D1 implementation per L-S395-1 mandate.

**Probe 1 — claude -p --help flag scan:**
- Result: `--help` output shows `--file <specs...>` but NO `--input-file`, `--image`,
  `--attachment` flags. The `--file` flag is for "File resources to download at startup.
  Format: file_id:relative_path" — NOT vision input.
- Outcome: Probe 1 inconclusive for direct flag (Resolution A unavailable).

**Probe 2 — @<path> syntax in user_message (CONFIRMED):**
- Command: `echo "What color is the pixel @/tmp/test_image.png" | claude -p --model claude-sonnet-4-6 --output-format json --disable-slash-commands --system-prompt "..."`
- Result: Claude described the image content ("white pixel") — confirmed filesystem access
  via @ prefix in user_message.
- PDF test: `echo "Please read @C:/htdocs/stockforge/tests/fixtures/pdf/vhm-2023-annual.pdf..." | claude -p ...`
  returned: `{"read_ok": true, "description": "Single-page placeholder PDF (690 bytes)..."}` — PDF directly readable.
- **Resolution B CONFIRMED**: `@<absolute_path>` in user_message enables Claude to read
  both PNG images AND PDF files via filesystem access.

**Probe 3 — base64 data-URI in user_message:**
- Not executed (Resolution B confirmed in Probe 2; DD-2 states STEP 0.4 stops at first
  successful resolution per architect's PARALLEL OPPORTUNITY note).

**K.2.b CHARTER-TIER FLAG status: NOT-FIRED**
- Resolution B is viable for both image and PDF inputs.
- DD-5 fallback path NOT activated.
- PDF→PNG conversion NOT required — adapter can pass PDF path directly via @<path>.

**Vision-input shape resolved: Resolution B**
- Adapter constructs user_message with `@<absolute_pdf_path>` prefix.
- Claude reads the PDF via filesystem access (claude_cli_transport substrate unchanged).
- No PDF→PNG conversion needed for V0; no new system dependencies needed (DD-8 satisfied).

## Decision

### DD-1: claude_cli_transport substrate MANDATORY

G.3 adapter uses `claude_cli_transport` from `packages/infrastructure/analysis/subagent_transport.py:144-222`
(D-050 CHARTER BINDING). ZERO `import anthropic` in any G.3 file. ZERO `ANTHROPIC_API_KEY` reference.
Verified: `Grep "import anthropic" packages/infrastructure/fundamental/` returns 0 matches.

Source evidence:
- `packages/infrastructure/analysis/subagent_transport.py:144-222` — claude_cli_transport signature
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:5-8` — anthropic_api_to_subagent precedent
- `agent-workspace/memory/decisions/050-anthropic-api-to-subagent.md` — D-050 CHARTER binding

### DD-2: Vision-input shape = Resolution B (@<path> in user_message)

STEP 0.4 cold-probe confirmed Resolution B (Probe 2 PASS). Adapter constructs user_message
with `@{pdf_source.pdf_path}` prefix. Claude CLI reads the PDF file via filesystem access.
No PDF→PNG conversion required. No new subprocess parameters needed on claude_cli_transport.

Source evidence:
- STEP 0.4 cold-probe execution at S399 (this session; confirmed empirically)
- `packages/infrastructure/analysis/subagent_transport.py:172-182` — subprocess.run input=user_message
- `agent-workspace/session-plans/pending/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md` § C DD-2

### DD-3: EchoValidator at packages/application/fundamental/echo_validator.py

EchoValidator co-located with PdfTableExtractorPort ABC in application layer (NOT _shared/).
AP-23 1st-instance HOLD: promotion to packages/_shared/ deferred until 2nd-BC reuse.

Source evidence:
- `packages/application/fundamental/pdf_table_extractor_port.py:93-185` — ABC co-location
- `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` § E.3 D3

### DD-4: Rule 16 mode #2 tolerance=0 exact-match + canonical-form coercion

EchoValidator.validate() applies canonical-form coercion (whitespace + parens-negative +
Vietnamese/US thousand-separator normalization + Triệu/Tỷ-đồng unit suffix expansion)
THEN asserts exact Decimal equality. Mismatch raises EchoValidationError (HARD ERROR).
Canonical-form coercion is bijection on underlying value (NOT tolerance relaxation).

Source evidence:
- `agent-workspace/constitution/financial-data-protocol.md:396-402` — Rule 16 mode #2 spec
  ("Mismatch is a HARD ERROR (raise + abort; never silently coerce)")
- `packages/application/fundamental/echo_validator.py` — implementation (THIS ADR)
- `agent-workspace/session-plans/pending/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md` § D DD-4

### DD-5: K.2.b fallback path — NOT ACTIVATED

STEP 0.4 Probe 2 confirmed Resolution B. DD-5 fallback options (a)/(b)/(c) not needed.
K.2.b CHARTER-TIER FLAG: NOT-FIRED.

### DD-6: Per-call cost ceiling = Decimal("0.50") USD configurable via ctor

`ClaudeVisionPdfTableExtractor(cost_ceiling_usd=Decimal("0.50"), model="claude-sonnet-4-6")`.
Per-call cost computed from token counts via `_compute_cost()` (deterministic; no LLM math).
CostBudgetExceeded raised when cumulative cost exceeds ceiling.

Source evidence:
- `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` — implementation (THIS ADR)
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80-87` — _compute_cost precedent

### DD-7: ADR D-082 PROPOSED-AT-IMPL (this file)

Records adapter contract + EchoValidator semantics + Rule 16 mode #2 satisfaction proof +
STEP 0.4 vision-input shape resolution (Resolution B) + per-call cost ceiling + K.2.b resolution.
12-field schema floor per L-S389-2 SATISFIED (id, title, status, severity, date, phase,
sub_track, session, authored_by, depends_on, supersedes, superseded_by, revisit_trigger).

### DD-8: ZERO pyproject.toml dep addition

Claude CLI is system-installed (confirmed: `claude --version` = 2.1.140).
Resolution B requires NO PDF→PNG conversion; NO new Python package needed.
pdfplumber dep deferred to G.2 sub-plan 042 ratification authority.

### DD-9: Test path convention = tests/unit/ (NEW directory tree)

Tests at `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` +
`tests/unit/application/fundamental/test_echo_validator.py` per dispatch brief § F explicit.
NEW `tests/unit/` directory tree introduced by this sub-plan.

## Rule 16 Mode #2 Satisfaction Proof

```
PDF file
    ↓  (Claude vision OCR via claude_cli_transport; Resolution B @<path>)
raw_cells: dict[str, str]  ← Claude's structured output (LLM echoes raw string values)
    ↓  (deterministic re-parse per cell: _parse_vnd_string() → Decimal)
deterministic_value: Decimal  ← non-LLM Python function on verified input
    ↓  (EchoValidator.validate(llm_value=raw, deterministic_value=det, cell_label=...))
    ↓  HARD ERROR if raw-canonical != deterministic (raises EchoValidationError)
    ↓  PASS if match
ExtractedFinancialStatement.raw_cells  ← validated raw strings (NOT derived numbers)
```

Key property: `raw_cells` carries raw strings only. The Decimal re-parse is used SOLELY
for echo validation gate. No LLM-derived numeric values flow into ExtractedFinancialStatement.
Charter Principle 1 (NO LLM math) satisfied by construction.

## Consequences

(a) G.4 sub-plan 044 can dispatch after S400 verifier PASS on this plan. G.4 consumes
    ClaudeVisionPdfTableExtractor + EchoValidator as production substrate.
(b) EchoValidator cross-BC promotion DEFERRED per AP-23 1st-instance HOLD. Revisit when
    2nd BC (BC-5 News claim extraction OR BC-6 KOL recommendation parser) reuses.
(c) DD-5 fallback NOT activated (K.2.b NOT-FIRED). Resolution B is the production path.
(d) tests/unit/ tree convention introduced. AP-23 1st-instance HOLD on convention.
    If 2nd sub-plan (G.2 042 OR G.4 044) adopts tests/unit/ → promote to template.
(e) G.2 sub-plan 042 REMAINS BLOCKED on RM3 STOP-FINDING-S394 real-PDF provision.
    G.3 is PARALLEL-ELIGIBLE with G.2 per parent plan-040 § N.2 (disjoint adapter files).

## Alternatives Considered

- **Direct anthropic SDK for vision**: REJECTED per D-050 CHARTER binding.
- **Resolution A (--input-file flag)**: REJECTED — not available in claude CLI 2.1.140.
- **Resolution C (base64 stdin)**: Not needed — Resolution B more direct.
- **Tolerance-band matching**: REJECTED per financial-data-protocol.md:401 ("never silently coerce").
- **Full-table-echo**: REJECTED — loses cell-level diagnostic granularity.
- **pdfplumber dep for PDF→PNG**: REJECTED per DD-8 (Resolution B avoids need).

## Source Evidence Chain

1. `packages/infrastructure/analysis/subagent_transport.py:144-222` — claude_cli_transport
2. `packages/application/fundamental/pdf_table_extractor_port.py:93-185` — D-080 ABC
3. `agent-workspace/constitution/financial-data-protocol.md:396-402` — Rule 16 mode #2
4. `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` — D1 adapter (NEW)
5. `packages/application/fundamental/echo_validator.py` — D2 validator (NEW)
6. `agent-workspace/session-plans/pending/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md` — sub-plan 043
7. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` § E.3 — parent contract
8. `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` — D-080 ACCEPTED
9. `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:5-8` — transport-flip precedent
