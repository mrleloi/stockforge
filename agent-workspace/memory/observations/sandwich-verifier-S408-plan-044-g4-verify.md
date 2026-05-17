---
type: sandwich-verifier-observation
session: S408
dispatched_by: main session at S407 close turn
agent_id: a6a53e1826fb7a16b
plan_verified: agent-workspace/session-plans/completed/044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration.md
predecessor_dev: a39037e9cb5f9c710 (S407 sandwich-dev; commit 6a67bee)
predecessor_architect: a6c35ae64db9443fc (S406 sandwich-architect retry; commit 02acb42 after S405 crash)
verdict: PASS-WITH-CONCERNS
merge_eligible: true
critical_count: 0
important_count: 3
minor_count: 5
promotion_candidates: 3
authored_at: 2026-05-17T23:50:00+07:00
note: |
  Content sourced verbatim from S408 verifier task-notification result text.
  Verifier honored D4.A persona override (CANONICAL per S403 commit 6d206c3 sandwich-verifier.md lines 10-34).
  Main session inline-persisted per M-S397-1 standard. Verifier appended attestation-log row (TSV bookkeeping persona-allowed).
---

# S408 Sandwich-Verifier Return — Plan-044 G.4 VHM PDF Dogfood + BC-2 Integration

## Overall Verdict: **PASS-WITH-CONCERNS** — merge-eligible

All artifacts ship; all PASS criteria (PASS-1..PASS-8) met empirically; D-050 + DD-3 + Karpathy P3 file-scope preserved. Concerns are LOC-discrepancy reporting drift (dev cited under-counts in observation), NOT correctness/charter violations.

## V1-V12 Grid Empirical Outcomes (summary)

- V1 D1 _vnd_money_parser.py DRY-delegate: PASS (actual 64 LOC vs cited 58)
- V2 D2 _pdf_cell_mapper.py 36 entries + ≥3 variants/key: PASS (Python introspect verified)
- V3 D3 ingest_pdf_fundamentals.py: PASS (5 exit codes — dev cited 4; RatioService at :268; ZERO import anthropic; actual 431 LOC vs cited 280 = +54% under-report)
- V4 D4 thesis-log TEMPLATE-V0: PASS (sections 1-7 + I-S35 disclaimer)
- V5 D5 7 integration tests: PASS (7/7 PASS independently re-run; 26 total assertions far exceeds ≥3 floor; actual 365 LOC vs cited 215 = +70% under-report)
- V6 D6 ADR D-083: PASS (13 frontmatter fields ≥12 floor; status PROPOSED-AT-IMPL; K.2.c NOT-FIRED documented)
- V7 MODIFIED __init__.py ADDITIVE: PASS (+3 LOC additive; ZERO deletions/replacements)
- V8 PCG-V404-1 pytest full-scope: PASS (1185 passed + 1 skipped EXACT match dev claim; 1st-instance compliance)
- V9 D-050 ZERO import anthropic: PASS (Grep entire repo)
- V10 K.2.c ADDITIVE-ONLY-DEFAULT: PASS (zero schema mods to financial_statement.py + sqlite_fundamental_repository.py)
- V11 STEP 0.4 cold-probe handling: PASS-WITH-CONCERN (live LLM call mocked per budget; plan semantics ambiguous — should be explicit OPTIONAL)
- V12 close-loop + Karpathy P3: PASS-WITH-CONCERN (file scope surgical perfect; LOC discrepancies + ceiling breach in dev observation)

## Findings

### CRITICAL: 0

### IMPORTANT (3)

**I1 L-S389-1 exact-integer LOC discipline violation in dev observation**: Dev cited 58/191/280/215/136/185 vs actual `wc -l` 64/190/431/365/136/185. 4 of 6 LOC citations wrong. Subverts L-S389-1 close-loop attestation contract. Main inline-persisted incorrect LOC into commit message + project tracking. **2nd-instance pattern** per AP-23 (1st was M-S388-1 caught at S389; this is recurrence in different mechanism — wrong-integer vs "~" prefix). Triggers PROMOTE-NOW for PC-1 hook.

**I2 L-S397-1 per-category LOC ceiling breach (substantial, undeclared)**: Plan-044 § G.1 ceilings: core ≤500/tests ≤200/total ≤1050. Actuals: core=688 (+38%), tests=367 (+84%), total=1376 (+31%). Dev cited "1067 within 1050; 17 LOC overage" — actual is +326 (19x larger than claimed). Recommendation: accept overage with ADR amendment OR trim defensive code. Promote candidate PC-3 for per-category LOC ceiling calibration for integration-test sub-plans.

**I3 STEP 0.4 cold-probe semantics ambiguous in plan (deviation acceptable but plan should clarify)**: Plan-044 § C STEP 0.4 describes mandatory-looking cold-probe; § B Out-of-scope marks "Live-LLM dogfood execution OPTIONAL per dispatch budget" — transitively justifies but not explicit. Future verifier might flag mocked-only smoke as critical skip. Fix: plan amendment (or post-hoc ADR note) marking STEP 0.x cold-probes OPTIONAL-when-live-LLM-budget-not-authorized. Promote candidate PC-2.

### MINOR (5)

- M1: Dev cited "4 exit codes" but CLI implements 5 (0/1/2/3/4). Cosmetic.
- M2: Dev cited __init__.py delta +2 LOC; actual git diff +3 LOC. Off-by-one.
- M3: `tests/integration/cli/` subdirectory NOT created (dev placed tests directly in `tests/integration/`). Plan § F line 286 mentioned subdirectory; deviation explicitly documented; AP-23 1st-instance HOLD acceptable.
- M4: EchoValidator gate FAIL-path test actually tests `VisionExtractionError` (empty cells) NOT `EchoValidationError` per Rule 16 mode #2 mismatch. Test docstring acknowledges; assertion (d2) asserts `EchoValidationError` is `ValueError` subclass without triggering it. Acceptable V0 smoke; promote-candidate for dedicated mismatch fixture test.
- M5: D-083 frontmatter `severity: LOW` — verifier-only observation; plan-044 § DD-7 doesn't specify; LOW seems reasonable for ADDITIVE-ONLY-default.

## Spec Alignment + Constitution Check

ALL PASS: DR1/DR6/DR8 / I-S1 NO LLM math / I-S2 source+as_of / I-S20 calibration / I-S35 research aid / D-050 / D-059 / D-064 / K.2.c NOT-FIRED / Karpathy P1+P2+P3 (file-scope PASS; LOC concern per I2).

## Promotion Candidates Surfaced

- **PC-1**: `dev-close-loop-loc-attestor.sh` hook to mirror `dogfood-the-promotion.sh` pattern (catches L-S389-1 violations BEFORE main inline-persist). Trigger: 2nd-instance L-S389-1 LOC-citation drift confirmed this session = **PROMOTE-NOW per AP-23**.
- **PC-2**: Plan-template patch to mark STEP 0.x cold-probe sub-steps explicitly MANDATORY-vs-OPTIONAL-when-budget-not-authorized (closes V11 ambiguity).
- **PC-3**: Per-category LOC ceiling calibration for integration-test sub-plans (current 200 LOC too tight when integration tests carry helpers + docstrings; consider 400-500 ceiling). Trigger: 2nd-instance ceiling breach.

## Close-loop file-existence per L-S397-3 + D4.A constraint citation

Per D4.A persona override, verifier FORBIDDEN from writing observation/session-log/.md report files. L-S397-3 close-loop attestation executed via main-session inline-persist per canonical M-S397-1 pattern.

Attestation row APPENDED at `agent-workspace/memory/attestation-log.tsv`:
`2026-05-17T23:50:00+07:00\tsandwich-verifier-S408-plan-044-g4-verify\tNA\tNA\tNA\tPASS-WITH-CONCERNS`

## Recommendation: MERGE-ELIGIBLE

Specific next actions for main session:
1. Commit verifier observation + session-log inline-persistence
2. Flip D-083 PROPOSED-AT-IMPL → ACCEPTED per parent plan-040 § DD-8 IMPL-tier auto-ratify
3. M-S407-1 (LOC drift) + M-S407-2 (ceiling breach) + M-S408-NONE mistake-log entries
4. Promotion queue: PC-1 PROMOTE-NOW for L-S389-1 2nd-instance + PC-2/PC-3 HOLD 1st-instance
5. Phase G-prime ROADMAP attestation: G.1+G.3+G.4 SHIPPED+VERIFIED; G.2 BLOCKED on RM3 carry-forward
