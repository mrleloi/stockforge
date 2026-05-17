---
agent: sandwich-architect
session: S406
plan_id: 044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration
type: PLAN-authoring observation
authored: 2026-05-17
re_dispatch_after: S405 (crashed at 64K output cap per M-S405-1; this observation tracks compliance with prevention rule L-S405-1)
---

# Sandwich-Architect S406 — Phase G-prime G.4 plan authoring observation

## (a) Plan LOC + STEP count

- Plan file: `agent-workspace/session-plans/pending/044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration.md`
- Plan LOC: see § (g) close-loop wc -l attestation below
- STEP 0 sub-steps: 5 (G.3 contract VBW + SQLite repo VBW + FinancialStatement VBW + Claude CLI vision cold-probe + SQLite write cold-probe)
- DDs: 7 (single-adapter / SourceProvider / schema-migration default / mapper location / parser DRY reuse / cost-budget / ADR landing)
- Sub-tracks: 6 (D1 parser / D2 mapper / D3 CLI / D4 thesis-log artifact / D5 integration tests / D6 ADR)
- RMs: 5 (vision regression / fixture missing / label drift / cost runaway / repo round-trip)
- File-scope: 6 NEW + 1 MODIFIED (additive-only __init__ delta)

## (b) 3 key DDs ONE-LINE each

- **DD-1 single-adapter G.3-only V0** (G.2 BLOCKED per RM3; per-adapter comparison deferred to G.4-V2)
- **DD-3 ADDITIVE-ONLY-DEFAULT schema posture** (K.2.c CHARTER-TIER FLAG NOT-FIRED V0; ZERO FinancialStatement migration; provenance lives in thesis-log artifact)
- **DD-5 VND-parser DELEGATES to EchoValidator._canonicalize_numeric_string** (DRY reuse with G.3 adapter; ONE canonical parser, not two)

## (c) RM count

5 RMs (RM-G4-1 vision regression / RM-G4-2 fixture missing / RM-G4-3 label drift / RM-G4-4 cost runaway / RM-G4-5 repo round-trip).

## (d) Source-evidence chain (file:line VBW-confirmed; 10 cites)

1. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` § E.4 + § N.2 (parent contract + sequencing) — Read offsets 1-825
2. `packages/application/fundamental/pdf_table_extractor_port.py:134` — extract() ABC signature
3. `packages/application/fundamental/extracted_financial_statement.py:43-74` — ExtractedFinancialStatement dataclass + raw_cells field
4. `packages/application/fundamental/echo_validator.py:78-202` — EchoValidator + _canonicalize_numeric_string (DD-5 delegation target)
5. `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:147-325` — ClaudeVisionPdfTableExtractor class + call_records property (DD-6)
6. `packages/infrastructure/fundamental/sqlite_fundamental_repository.py:32-83` — schema + save_many (DD-3 NO-MIGRATION basis)
7. `packages/domain/fundamental/models/financial_statement.py:42-88` — FinancialStatement aggregate + invariants
8. `packages/domain/fundamental/value_objects/line_item.py:24-63` — LineItemKey + line_item_required_for_ratio (D2 mapper basis)
9. `packages/contracts/types/adjustment_type.py:36-51` — SourceProvider.SCRAPED_OTHER (DD-2 enum choice)
10. `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md:1-211` — D-082 ACCEPTED context (DD-1 G.3 dependency)

Additional VBW (counted in margin, not cited above): apps/cli/validate_thesis.py:1-100 + apps/cli/ingest_fundamentals_vn30.py:1-100 + packages/infrastructure/fundamental/__init__.py + tests/fixtures/pdf/* Glob + tests/unit/application/fundamental/test_echo_validator.py + packages/domain/fundamental/services/ratio_service.py:1-60 + human-workspace/notifications/_STOP-FINDING-template.md + agent-workspace/session-plans/completed/043-S398-*.md (parent for G.3 lineage).

## (e) Parallel-dispatch compatibility

- G.4 plan is SEQUENTIAL POST-G.3 SHIP per parent plan-040 § N.2 (G.3 ALREADY SHIPPED S399+S400; G.4 is final Phase G-prime sub-track)
- Within G.4 IMPL: D1+D2+D6 are file-disjoint (parser / mapper / ADR) — sub-track-internal parallel-eligible if dev chooses
- Cross-phase: G.4 IMPL parallel-eligible with Phase F-prime data-corpus ingestion (disjoint BC: BC-2 fundamental vs BC-5 news / BC-8 personas)
- G.2 unblock work is independent dispatch path (NOT blocked by G.4)

## (f) S407 IMPL budget estimate

- Per parent plan-040 § E.4 + recalibrated CLAUDE.md Opus FOCUSED_IMPL column: **100-150K Opus**
- Justification: 6-deliverable scope; file-bounded (no novel external library); 5 NEW files + 1 ADDITIVE modification; ~970 LOC total per § G.1 ceilings; STEP 0 cold-probes add ~10-20K Opus overhead per L-S395-1 mandate
- Cold-start on task_class="pdf-dogfood-bc2-integration-impl" — directional confidence MEDIUM at n=1 per-analog × 3 analogs (validate_thesis F.5 IMPL S385 / ingest_fundamentals_vn30 S33-ish / G.3 IMPL S399)
- VERIFY S408 budget: 80-180K Opus per CLAUDE.md VERIFY-Opus column (fresh-context AP-1 review)

## (g) K.X flag status

- K.2.a (pymupdf license escalation OR no-clear-winner pivot): N/A this sub-plan (G.2 territory)
- K.2.b (Claude CLI vision-input feasibility): NOT-FIRED — RESOLVED at S399 D-082 STEP 0.4 Resolution B confirmed; G.4 STEP 0.4 cold-probe RE-CONFIRMS at S407 entry
- K.2.c (FinancialStatement schema migration): DEFAULT ADDITIVE-ONLY-DEFAULT applies = NO MIGRATION V0 per DD-3; NON-BLOCKING; main session reviews IMPL output (NOT AskUserQuestion gate per parent plan-040 § K.2.c "NO AskUserQuestion needed")
- **Overall: ZERO NEW charter-tier flags this sub-plan**

## (h) Close-loop file-existence verification (per L-S397-3 + L-S405-1 — to be filled in return summary)

Architect closes loop by running wc -l on both output files BEFORE composing return summary. Integers cited verbatim in return summary (no ~ prefix per L-S389-1).
