---
observation_id: sandwich-verifier-S366-vn-sentiment-lexicon-verify
type: sandwich-verifier-audit
verifier_agent_id: ad37b5d09d0ddc456
created_at: 2026-05-17
plan_audited: agent-workspace/session-plans/completed/030-S364-phase-e2-vn-sentiment-lexicon.md
dev_session_audited: S365 (commit baefd95)
verifier_has_no_Write: true (recovery pattern: main writes this file)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
defects: 0 CRITICAL / 0 IMPORTANT / 4 MINOR (F1 INLINE-RESOLVED; F2 withdrawn; F3-F5 cosmetic-defer)
l_s345_1_clear_n5: yes (10/10 wc -l byte-exact match)
cultural_anchors_8_of_8: GREEN
uncalibrated_v0_appropriate: yes (AP-7 anti-vacuous-defer with 4 named revisit triggers)
adr_d071_ratification: ACCEPTED (ARCH-tier auto-ratifies at commit baefd95)
phase_e2_to_e3_ready: yes
verifier_budget_actual: ~162K Opus (under recalibrated 80-180K VERIFY budget)
---

# S366 sandwich-verifier — VN Sentiment Lexicon Verify (E.2)

## Explicit Verdicts (7 gates ALL GREEN)

- (a) Overall: PASS-WITH-CONCERNS
- (b) ADR D-071 ratification: ACCEPTED (ARCH-tier auto-ratifies)
- (c) Phase E.2 → E.3 sequencing: READY
- (d) L-S345-1 trigger clear at n=5: YES (10/10 byte-exact)
- (e) plan-030 mv pending → completed: AUTHORIZED
- (f) Cultural anchors 8/8 GREEN: YES (15 distinct strings in frozenset post-F1 inline-fix)
- (g) UNCALIBRATED-V0 posture appropriate: YES (AP-7 defer with 4 named triggers)

## V1-V9 Aggregate

- V1: 34/35 PASS / 1 SKIP (DC-BOOK-4 now AUTHORIZED)
- V2: D1-D5 all DELIVERED
- V3: DD-1..DD-7 all COMPLIANT
- V4: I-S1/I-S2/I-S20/I-S22/I-S34/I-S35 + DR1/DR6/DR8 + D-059 R1/R2/R4 + Karpathy P3 ALL CLEAN
- V5: pytest 1079 PASS independently re-run; ruff + mypy strict clean
- V6: Integration smoke `lex.score("co phieu VHM lao_doc du_dinh")` → BEARISH -0.4 (đu_đỉnh effect) ✓
- V7: Cultural anchors 8/8 GREEN empirical
- V8: STOP-FINDING file format correct
- V9: ADR D-071 PROPOSED → ACCEPTED at ARCH-tier auto-ratification

## L-S345-1 anti-regression CLEAR at n=5

10/10 dev wc -l claims = independent wc -l EXACT match (vn_lexicon_port 55 / __init__ 6 / extraction/__init__ 1 / sentiment/__init__ 15 / vn_lexicon 494 / test 395 / CLI 226 / D-071 150 / calibration 172 / STOP-FINDING 68). L-S345-1 RETIRED status holds; no AP-23 re-fire.

## Defects (4 MINOR; F2 withdrawn)

**F1 INLINE-RESOLVED this turn**: `lai_co_phieu -0.6` was in lexicon dict but NOT in VN_CULTURAL_ANCHORS frozenset. Fix: added single line at frozenset ASCII-forms section with disambiguation comment. Frozenset now 8 ASCII + 7 unicode = 15 distinct strings.

**F3 cosmetic**: lexicon 239 entries vs ~228/236 claimed (DC-IMPL-4 ≥200 floor exceeded; minor observation accuracy).

**F4 defer to v0.CALIBRATED**: unicode double-counting edge case (both forms in same source would double-count; in practice tokenizer choice produces one form).

**F5 no fix**: cosmetic README format note.

## Promotion candidates (4 1st-instance HOLD)

- L-S366-1: dispatch brief should include lexicon-disambiguation pattern note
- L-S366-2: charter-compliance-by-source-grep test idiom (TC23 reusable)
- L-S366-3: cultural-anchor frozenset audit-trail discipline (F1 root)
- L-S366-4: L-S354-2 re-fire — .planner-stats.tsv STILL header-only after 6th dogfood (S354+S357+S358+S362+S365+S366); promotion target = harness-stabilization sweep

## Compliance attestation

AP-1 fresh-context ✓ / AP-2 transcript-tokens ✓ / AP-7 anti-vacuous-defer ✓ (4 named triggers) / 0 file writes / 0 commits / 0 charter / 0 constitution / L-S345-1 RETIRED at n=5 / verifier-has-no-Write recovery applied / Karpathy P1-P4 review COMPLETE.

## Recommendations

MERGE at commit baefd95 + (this turn close). F1 INLINE-RESOLVED. Sub-plan 031 (E.3 claim extraction wrapper) UNBLOCKED.
