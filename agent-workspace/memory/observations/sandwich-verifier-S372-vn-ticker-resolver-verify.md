---
observation_id: sandwich-verifier-S372-vn-ticker-resolver-verify
type: sandwich-verifier-audit
verifier_agent_id: aac653cd930e80258
created_at: 2026-05-17
plan_audited: agent-workspace/session-plans/completed/032-S370-phase-e4-vn-ticker-resolver.md
dev_session_audited: S371 (commit c8928e0)
verifier_has_no_Write: true (recovery pattern: main writes this file)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
defects: 0 CRITICAL / 0 IMPORTANT / 5 MINOR
phase_e_done_attestation_ready: YES
adr_d073_ratification: ACCEPTED (IMPL-tier auto-ratifies)
dd6_ambiguous_validated: YES (all 7 dispatch CRITICAL checks PASS)
rule17_pre_empted: YES (DD-6 design pre-empts charter escalation; LIKELY-VERY-LOW per plan-032 § M.1)
l_s345_1_n7_clear: NOT-CLEAR (F2 soft LOC drift 357→337 + 150→147; not fabrication)
l_s369_1_d073_drift: NO-DRIFT (D-073 has no empirical_close_verify field; vacuous-pass)
verifier_budget_actual: ~110K Opus (within recalibrated 80-180K)
---

# S372 sandwich-verifier — VN Ticker Resolver Verify (E.4 / Phase E DONE gate)

## Verdicts (8 gates)

- (a) Overall: PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES
- (b) ADR D-073 ratification: ACCEPTED (IMPL-tier auto-ratifies)
- **(c) PHASE E DONE attestation READY: YES** — all 4 sub-plans SHIPPED+VERIFIED chain validated
- (d) L-S345-1 CLEAR at n=7: **NOT CLEAR (F2 SOFT)** — 2 LOC discrepancies in dev observation (357→337, 150→147); dispatch+git+wc -l agree on 357+150; SOFT drift not fabrication
- (e) plan-032 mv pending → completed: AUTHORIZED
- (f) DD-6 AMBIGUOUS-explicit-surface empirically validated: YES (all 7 dispatch CRITICAL checks PASS + bonus probes)
- (g) Rule 17 charter escalation PRE-EMPTED: YES (DD-6 design covers v0)
- (h) L-S369-1 ADR drift check on D-073: NO-DRIFT (field absent; F3 carry-forward)

## V1-V9 Aggregate

- V1: 33/33 DoD PASS independently re-verified
- V2: D1-D5 all DELIVERED (alias table 30 tickers × 7.6 aliases avg)
- V3: DD-1..DD-8 all COMPLIANT
- V4: Charter/invariant ALL CLEAN
- V5: pytest 1112 PASS / 1 skip; ruff clean; mypy strict clean on new files
- V6: Integration smoke `r.resolve('Vinhomes')` → VHM/CASE_INSENSITIVE/1.0 ✓
- V7: DD-6 AMBIGUOUS empirical — `r.resolve('Ngan hang')` → AMBIGUOUS / candidates=['MBB','HDB'] / canonical=None / confidence=0.0 ✓
- V8: Alias table audit — 30 VN30 tickers / 227 aliases / 7.6 avg / markdown parseable
- V9: _build_claim back-compat preserved (TC-D4-1/2/3 PASS; default=None unchanged)

## DD-6 AMBIGUOUS empirical (CRITICAL — pre-empts Rule 17)

ALL 7 dispatch checks PASS:
1. ResolutionMethod.AMBIGUOUS enum exists (L90) + emitted when difflib ≥2 candidates ✓
2. canonical_ticker=None on AMBIGUOUS (L359) ✓
3. candidates populated with all matches (L364) ✓
4. confidence=0.0 on AMBIGUOUS (L361) ✓
5. TC8 covers AMBIGUOUS path empirically ✓
6. _build_claim treats AMBIGUOUS as skip via `!= ResolutionMethod.AMBIGUOUS` filter ✓
7. Live test: `r.resolve('Ngan hang')` → AMBIGUOUS ✓

Bonus probes: `r.resolve('Vingroups')` → FUZZY/VIC/0.941; `r.resolve('Vin')` → UNKNOWN (3-char too short for cutoff); `r.resolve('')` → UNKNOWN no exception.

## Defects (5 MINOR; 0 critical; 0 important)

**F1 MINOR**: Phase E DONE attestation should be in close commit (this turn handles).

**F2 MINOR (L-S345-1 SOFT DRIFT n=7)**: dev observation L82+L93 reports `337 + 147` for test+CLI; actual `357 + 150`. Dispatch+git diff+independent wc -l all confirm 357+150. SOFT drift (mid-edit snapshot likely), not fabrication. File content correct + tests pass. Track as M-S371-1 LOW; NOT promote-now per L-S345-1 intent (rule guards fabrication, not bookkeeping freshness).

**F3 MINOR**: D-073 lacks `empirical_close_verify` field. L-S369-1 PROMOTE-NOW target for ADR template enhancement (post-cool-down session); cannot drift from absent field.

**F4 MINOR**: TC-D4-3 name says "ambiguous" but input "ambiguous_xyz_zyx" resolves to UNKNOWN (not AMBIGUOUS). AMBIGUOUS branch in _build_claim NOT integration-tested empirically (only unit-tested at resolver). Test enhancement carry-forward (use "Ngan hang" for true AMBIGUOUS test).

**F5 MINOR**: CLI 150 LOC vs ~80 estimate (+87% over); estimate calibration data only.

## Promotion candidates

- **L-S371-1 (1st-instance HOLD)**: VN ticker resolver pattern (alias table + difflib + DI) reusable for sector resolver (BC-1) and persona resolver (BC-8). On 2nd recurrence → extract EntityResolver Protocol port (currently rejected per DD-2 AP-23 1st-instance HOLD).
- **L-S372-1 (1st-instance HOLD)**: Verifier should include AMBIGUOUS branch integration test in dispatch checklist (F4 surfaces gap). On 2nd recurrence → promote to dispatch template.

## Compliance attestation

AP-1 ✓ / 0 file writes / 0 commits / 0 charter / 0 constitution / VBW applied / Karpathy P1-P4 review COMPLETE

## PHASE E CUMULATIVE SHIPPING SUMMARY

| Sub-plan | Theme | ADR | SHIPPED | VERIFIED |
|---|---|---|---|---|
| 029 | E.1 VN Tokenization | D-070 | S362 | S363 ✓ |
| 030 | E.2 VN Sentiment Lexicon | D-071 | S365 | S366 ✓ |
| 031 | E.3 VN Claim Extraction Wrapper | D-072 | S368 | S369 ✓ |
| 032 | E.4 VN Ticker Resolver | D-073 | S371 | S372 (this) ✓ |

**Phase E DONE.** Phase F-prime master-plan dispatch UNBLOCKED per plan-028 § M.1 + plan-032 § N.2.

## Recommendations

MERGE at commit c8928e0 + (this close-bookkeeping). Phase E DONE attestation in close commit per F1. Dispatch S373 architect for Phase F-prime Theme H BC-8 multi-perspective PHASE-MASTER-PLAN (recommended 150-230K Opus PLAN per recalibrated CLAUDE.md; cold-start declared for task_class="multi-perspective-plan").
