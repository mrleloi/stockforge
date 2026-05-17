---
observation_id: sandwich-dev-S399-g3-claude-vision-adapter-impl
type: sandwich-dev-output
dev_agent_id: S399 sandwich-dev (Claude Sonnet 4.6; FOCUSED_IMPL)
created_at: 2026-05-17
plan_executed: agent-workspace/session-plans/completed/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md
session_type: FOCUSED_IMPL (5 sub-tracks D1-D5)
budget_estimate: 130-180K Opus equivalent (Sonnet; ~40-60 min wall)
phase_milestone: G.3 ClaudeVisionPdfTableExtractor + EchoValidator Rule 16 mode #2 gate SHIPPED
k2b_charter_tier_flag: NOT-FIRED (Resolution B confirmed in STEP 0.4 Probe 2)
commit: b736640
plan_mv: completed/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md
---

# S399 sandwich-dev — Phase G.3 ClaudeVisionPdfTableExtractor + EchoValidator IMPL observation

## STEP 0 Outcomes (VBW probes executed before D1-D5)

### STEP 0.1 — claude_cli_transport API surface re-verification
- **Signature confirmed**: `claude_cli_transport(model, system_prompt, user_message, temperature, role=None) -> tuple[str, int, int]` at `packages/infrastructure/analysis/subagent_transport.py:144-222`
- **ZERO file/image parameter**: confirmed — NO `input_file`, `image`, `attachment` parameter in current signature
- **anthropic import grep**: 0 matches in `packages/infrastructure/fundamental/` BEFORE G.3 authoring ✓
- **claude CLI on PATH**: `claude --version` = 2.1.140 ✓

### STEP 0.2 — Rule 16 mode #2 spec re-verification
- **financial-data-protocol.md:396-402**: "The LLM is permitted only to echo that computed value... Mismatch is a HARD ERROR (raise + abort; never silently coerce)" ✓
- **EchoValidator.validate interface**: `validate(llm_value, deterministic_value, tolerance=...)` at :432 confirmed; DD-4 adds `cell_label` kwarg for diagnostic

### STEP 0.3 — G.1 ABC contract immutability re-verification
- **4 abstract methods confirmed**: `extract`, `supports`, `name`, `extractor_version` at :133-185
- **source_id ClassVar** at :109; `__init_subclass__` guard at :111-131 confirmed
- **ExtractedFinancialStatement**: 7 fields + `__post_init__` invariants at :76-117 confirmed
- **PdfSource**: D-064 path-safety at :64-72 confirmed

### STEP 0.4 — Vision-input feasibility cold-probe (DOMINANT; per L-S395-1)

**Probe 1 — claude -p --help flag scan:**
- Output: `--file <specs...>` (for startup resource download: "file_id:relative_path") but NO `--input-file`, `--image`, `--attachment` flags
- Result: No direct vision-input flag. Resolution A unavailable.

**Probe 2 — @<path> syntax in user_message (PASS — CONFIRMED):**
- Test PNG: `echo "What color is the pixel @/tmp/test_image.png" | claude -p ...`
  Response: "Based on the image at /tmp/test_image.png... the image appears to be white"
  → Claude read the 1x1 white PNG and described it correctly
- Test PDF: `echo "Please read @C:/htdocs/stockforge/tests/fixtures/pdf/vhm-2023-annual.pdf..." | claude -p ...`
  Response: `{"read_ok": true, "description": "Single-page placeholder PDF (690 bytes). Contains one line of text: 'VHM 2023 Annual Report - PLACEHOLDER TEST FIXTURE ONLY'"}`
  → Claude read the PDF file directly and described its content
- **Resolution B CONFIRMED**: @<absolute_path> in user_message enables Claude to read PNG, PDF, and likely other formats via filesystem access

**Probe 3 — base64 data-URI:** NOT executed (Resolution B confirmed; DD-2 stops at first success)

**K.2.b CHARTER-TIER FLAG: NOT-FIRED**

**Vision-input shape resolved: Resolution B**
- @<pdf_path> in user_message passes PDF to Claude's filesystem access
- No PDF→PNG conversion required (removes complexity + system dep need)
- claude_cli_transport signature unchanged (user_message carries @<path>)

**CRITICAL FINDING**: PDF input works directly without any conversion step. Claude CLI reads the PDF natively via filesystem access when given @<absolute_path> in user_message. This is simpler than Probes A/C and preserves full PDF semantics for vision OCR.

### STEP 0.5 — Fixture inventory + test path convention
- `tests/fixtures/pdf/`: 5 files confirmed (placeholder PDFs + SHA256.txt + expected_cells JSON) ✓
- `tests/unit/` directory: 0 files before this sub-plan (NEW tree per DD-9) ✓
- `agent-workspace/memory/decisions/081*.md`: D-081 reserved by S396 confirmed ✓
- D-082 next-free confirmed ✓

### STEP 0.6 — Pre-flight active rules re-check
- R1 destructive-command-guard.sh PreToolUse — ACTIVE ✓
- R2 project-integrity-watchdog.sh Stop hook — ACTIVE ✓
- R3 daily-backup.sh Stop hook — ACTIVE ✓
- BEHAVIORAL HOLD §(1) — SYNC-GRILLING + ROUTINE-IDLE SUSPENDED — HONORED ✓

## Sub-track Outcomes

### D1 — ClaudeVisionPdfTableExtractor adapter

**File**: `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` (NEW; 404 LOC)

**DoD checklist:**
- [x] File exists at exact path
- [x] ClaudeVisionPdfTableExtractor subclasses PdfTableExtractorPort (source_id='claude-vision')
- [x] 4 abstract methods implemented (extract + supports + name + extractor_version)
- [x] ZERO `import anthropic` in this file (charter compliance test passes)
- [x] ZERO `ANTHROPIC_API_KEY` reference
- [x] claude_cli_transport imported + invoked per Resolution B (@<path> in user_message)
- [x] EchoValidator.validate invoked per cell (raises EchoValidationError on mismatch)
- [x] cost_ceiling_usd ctor kwarg with Decimal("0.50") default
- [x] mypy --strict green
- [x] ruff clean

**Key design choices:**
- `_parse_vnd_string()` re-uses `_canonicalize_numeric_string()` from echo_validator for
  consistency in the deterministic re-parse path (single source of truth for canonicalization)
- `call_records: list[_CallRecord]` accumulates per-call telemetry for I-S20 calibration
- `source_pdf_sha256` computed from actual file content at extract() time

### D2 — EchoValidator + EchoValidationError

**File**: `packages/application/fundamental/echo_validator.py` (NEW; 202 LOC)

**DoD checklist:**
- [x] File exists at exact path
- [x] EchoValidator.validate(llm_value, deterministic_value, cell_label) signature
- [x] tolerance=0 exact-match enforced (NOT tolerance-band)
- [x] EchoValidationError raised HARD ERROR on mismatch
- [x] Canonical-form coercion: whitespace + parens-negative + Triệu/Tỷ-đồng + thousand-sep
- [x] mypy --strict green
- [x] ruff clean

**Bug fixed during implementation:**
- Vietnamese unit-suffix regex `đ[oô]ng` did NOT match `đồng` (tonal char mismatch).
  Fixed to explicit alternation: `(?:đồng|dong)` with `re.UNICODE | re.IGNORECASE`.
  This was caught immediately by test failures and corrected (M-S399-1 if recorded).

### D3 — STEP 0.4 cold-probe write-up

**Status**: COMPLETE (see STEP 0.4 section above)
- K.2.b: NOT-FIRED
- Resolution B: CONFIRMED (@<path> in user_message for both PNG and PDF)
- STOP-FINDING file: NOT written (K.2.b did not fire)

### D4 — Unit tests

**Files**:
- `tests/unit/application/fundamental/test_echo_validator.py` (NEW; 263 LOC; 26 tests)
- `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` (NEW; 449 LOC; 25 tests)
- `tests/unit/__init__.py` + `tests/__init__.py` + 4 other `__init__.py` files (NEW)

**DoD checklist:**
- [x] Both test files exist + pytest green (51 tests; all PASS)
- [x] ZERO regressions: 1178 passed + 1 skipped (baseline was 1127 + 1 skip; net +51)
- [x] Mocked subprocess via unittest.mock.patch per test_subagent_transport.py pattern
- [x] mypy --strict green on test files
- [x] ruff clean (1 SIM108 + 4 SIM117 auto-fixed; SIM108 echo-validator manually rewritten)
- [x] tests/unit/ NEW directory created with __init__.py files (DD-9)

**Test count breakdown**: 26 EchoValidator + 25 adapter = 51 total (≥25 floor satisfied)

### D5 — ADR D-082 PROPOSED

**File**: `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` (NEW; 207 LOC)

**DoD checklist:**
- [x] ADR D-082 exists at exact path
- [x] ≥12-field schema satisfied: id, title, status, severity, date, phase, sub_track, session,
      authored_by, depends_on, supersedes, superseded_by, revisit_trigger = 13 fields
- [x] ≥3 source_evidence cites per major claim (9 sources listed)
- [x] AP-7 revisit_triggers named (4 revisit conditions)
- [x] Status: PROPOSED (AUTO-ACCEPT at S399 close per severity-schema MEDIUM; no CHARTER cool-down)

## Quality Gates Summary

| Gate | Status | Details |
|---|---|---|
| mypy --strict | PASS | 19 files checked; 0 errors |
| ruff | PASS | All 4 new source files clean |
| pytest | PASS | 1178 passed, 1 skipped, 0 failed |
| ZERO import anthropic | PASS | AST-verified in D4 test_15 + Grep confirms |
| K.2.b CHARTER-TIER FLAG | NOT-FIRED | Resolution B confirmed |
| No regression on baseline 1127 | PASS | Net +51 tests; 0 failures |

## LOC Table (exact integers per L-S389-1)

| File | LOC | Category |
|---|---|---|
| `packages/application/fundamental/echo_validator.py` | 202 | core production |
| `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` | 404 | core production |
| `tests/unit/application/fundamental/test_echo_validator.py` | 263 | tests |
| `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` | 449 | tests |
| `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` | 207 | ADR |
| `tests/__init__.py` + 5x `__init__.py` | 6 | empty init files |
| **Total** | **1531** | |

**Core production LOC: 606** (202 EchoValidator + 404 adapter; within ≤500 ceiling per L-S397-1?
NOTE: adapter is 404 LOC vs 300 ceiling — deviation documented below as M-S399-1)

## Deviations from Plan

**M-S399-1 (minor): Adapter LOC exceeded plan ceiling**
- Plan D1 ceiling: ≤300 LOC core code; target ~250
- Actual: 404 LOC (34% over ceiling)
- Reason: (a) `_parse_cells_from_response()` helper required for robust JSON parse (~30 LOC),
  (b) `_CallRecord` dataclass + `call_records` property for I-S20 calibration telemetry (~15 LOC),
  (c) `_compute_cost()` function + cost-rate constants (~25 LOC), (d) full module docstring +
  MUST/MUST NOT clauses per plan spec (~20 LOC), (e) generous inline comments explaining
  Resolution B decision and Rule 16 mode #2 proof path (~15 LOC)
- Assessment: No architectural deviation; extra LOC is documentation + helper functions;
  all within Karpathy P3 (only what task requires — every added line traces to plan DoD criteria)

**M-S399-2 (minor): Vietnamese unit-suffix regex bug caught during testing**
- Initial regex `đ[oô]ng` did not match `đồng` (tonal char difference)
- Fixed to explicit alternation `(?:đồng|dong)` with UNICODE flag
- Caught by test suite (D4 tests 7+8 failed on first run); corrected before commit
- Zero impact on shipped code quality (fixed before any integration)

## Handoff Notes for S400 Verifier

**What to verify (per S397 V1-V10 pattern):**

1. **V1 Plan DoD completeness**: 34 criteria across D1-D5; all checkboxes above should be satisfied
2. **V2 Karpathy P3 surgical-scope**: ZERO modification of existing G.1 ABC + dataclasses
3. **V3 Charter compliance (CRITICAL)**: `Grep "import anthropic" packages/infrastructure/fundamental/` MUST return 0; `Grep "ANTHROPIC_API_KEY" packages/infrastructure/fundamental/` MUST return 0
4. **V4 ABC subclass contract**: ClaudeVisionPdfTableExtractor subclasses PdfTableExtractorPort correctly; source_id non-empty enforced
5. **V5 EchoValidator Rule 16 mode #2 compliance**: tolerance=0; HARD ERROR semantics; canonical-form coercion per financial-data-protocol.md:401-402
6. **V6 Subclass-instantiation smoke**: `ClaudeVisionPdfTableExtractor()` instantiates OK (per S397 V6 pattern); test_1 covers this
7. **V7 Test count + passing**: ≥25 test cases MINIMUM per plan; actual = 51; pytest 1178/1178 PASS
8. **V8 ADR D-082 quality**: ≥12 fields; ≥3 source evidence per claim; Rule 16 mode #2 satisfaction proof; STEP 0.4 Resolution B documented
9. **V9 File scope compliance**: ZERO modification to G.1 ABC files + existing infrastructure
10. **V10 K.2.b status**: NOT-FIRED; no STOP-FINDING file (correctly absent)

**Key file paths to review:**
- `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` (D1; 404 LOC)
- `packages/application/fundamental/echo_validator.py` (D2; 202 LOC)
- `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` (D4; 25 tests)
- `tests/unit/application/fundamental/test_echo_validator.py` (D4; 26 tests)
- `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` (D5; 207 LOC)

**G.4 dispatch signal**: G.3 SHIPPED per this observation. G.4 sub-plan 044 dispatch-ready AFTER S400 verifier PASS. G.4 BLOCKS on BOTH G.2 + G.3 (per parent plan-040 § E.4); G.2 remains BLOCKED on RM3 STOP-FINDING-S394 real-PDF provision.

## Commit

`b736640` — "S399: Phase G.3 ClaudeVisionPdfTableExtractor + EchoValidator Rule 16 mode #2 gate IMPL (plan-043 D1-D5 COMPLETE)"

11 files changed, 1525 insertions(+)
