---
observation_id: sandwich-verifier-S363-vn-tokenizer-verify
type: sandwich-verifier-audit
verifier_agent_id: ac94ead88bb573cd9
created_at: 2026-05-17
plan_audited: agent-workspace/session-plans/completed/029-S361-phase-e1-vn-tokenization.md
dev_session_audited: S362 (commits 19e18af + 5a7a42f)
verifier_has_no_Write: true (recovery pattern: main writes this file)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
defects: 0 CRITICAL / 0 IMPORTANT / 3 MINOR (F1+F2 INLINE-RESOLVED; F3 deferred)
charter_tier_gate_fired: NO (underthesea=Apache-2.0 finding overrode stale plan-029 GPL-3.0 assumption)
l_s345_1_trigger_clear_n4: YES (dev LOC 50/147/235/186 = wc -l exact match; 4 consecutive clean sessions)
phase_e1_to_e2_ready: YES
adr_d070_ratification_recommended: YES (auto-ratifies on commit per ARCH-tier severity-schema)
plan_029_mv_authorized: YES
verifier_budget_actual: ~125K Opus (under recalibrated 80-180K VERIFY budget per CLAUDE.md M-S360-2 update)
---

# S363 sandwich-verifier — VN Tokenization Verify (E.1)

## Explicit Verdicts (5 gates ALL GREEN)

- **(a) Overall**: PASS-WITH-CONCERNS
- **(b) ADR D-070 ratification**: RECOMMENDED (auto-ratifies on commit per ARCH-tier)
- **(c) Phase E.1 → E.2 sequencing**: READY (port + adapter shipped behind Protocol; sub-plan 030 sentiment-lexicon may dispatch)
- **(d) L-S345-1 trigger CLEAR at n=4**: YES (4 consecutive truthful LOC sessions S345/S354/S357/S363; promote-not-needed)
- **(e) plan-029 mv pending → completed**: AUTHORIZED (DC-BOOK-4 verifier-acceptance gate satisfied)

## V1 — DoD 33-item adherence

32/33 PASS (DC-BOOK-4 correctly deferred to S363 per protocol). All DC-FILE-N + DC-IMPL-N + DC-STEP0-N + DC-GATE-N + DC-SMOKE-N verified.

## V2 — Sub-track D1-D4 delivery

- D1 ports: 3 files (50+5+11 LOC) ✓
- D2 adapter: 147 LOC ✓
- D3 tests: 19 cases × 235 LOC (exceeds DoD ≥10 floor by 2x) ✓
- D4 CLI: 186 LOC (exceeds plan ~80 LOC ceiling by 2.3x; scope grew naturally)

## V3 — DD compliance DD-1..DD-6

All 6 DDs PASS. DD-2 CONDITIONAL selection correctly traces to STEP 0.5 empirical scorecard (not pre-decided).

## V4 — Charter / invariant compliance

0 charter / 0 constitution. I-S1 ✓ (no LLM in tokenizer; grep `import anthropic|openai` ZERO matches). I-S34 ✓ (pip show pyvi transitive deps = sklearn-only; ZERO patchright/StealthyFetcher). D-059 ✓ (no datetime/RNG/time.time in NLP). DR1 + DR8 ✓ (no cross-layer leakage).

## V5 — Regression (deterministic gates re-run)

- ruff PASS
- mypy --strict --explicit-package-bases on 5 files: Success
- pytest test_vn_tokenizer.py: 19/19 PASS (2 pyvi DeprecationWarnings non-fatal)
- Full suite: 1053 passed in 18.25s (baseline 1034 + 19 new; zero regressions)

## V6 — Integration smoke (independent reproduce)

`VnTokenizer().tokenize("cổ phiếu VHM tăng 5%")` → `['cổ_phiếu', 'VHM', 'tăng', '5', '%']` ✓ (compound preserved). Determinism re-run TRUE.

## V7 — Empirical eval reproduce

Corpus count 36 ✓. Per-source discrepancy: actual NDH=14 not 12 (F1 below). CafeF=0 confirmed via no directory. Quality scores 75.7%/81.8%/0.0% trust-but-cite-able (verifier env doesn't have underthesea; gap < 10% architect rule satisfied).

## V8 — License classification (independent verify)

- pyvi==0.1.1: MIT ✓ (independently re-verified via `pip show`)
- underthesea Apache-2.0: trust-but-not-reproducible (not installed on verifier env); CHARTER-TIER GATE assertion operationally safe because SELECTED library (pyvi) is independently MIT

## V9 — STEP 0 STOP-AND-ASK trigger audit

- (a) CHARTER-TIER GATE — correctly NOT fired (selected = MIT) ✓
- (b) all-fail-quality — NOT fired (both libs > 30%) ✓
- (c) corpus-too-small — NOT fired but BORDERLINE (gap 6.1% margin 1.1% above ±5% threshold; F3 below)
- (d) I-S34 HARD REJECT — NOT fired (empty) ✓
- (e) non-determinism — NOT fired (True) ✓
- (f) corpus-expansion-failed — NOT fired (36 ≥ 30 floor) ✓

## Defects

### IMPORTANT (RESOLVED INLINE this turn)

None.

### MINOR

**F1 INLINE-RESOLVED**: per-source corpus attribution NDH=12 (actual NDH=14). Fix: 1-line correction in `vn_tokenizer_eval_v0.md:11` (NDH=12 → NDH=14 + correction note). Total 36 unchanged.

**F2 INLINE-RESOLVED**: ADR D-070 RM2 "exact version pinned" overstates (`pyproject.toml:38` had `pyvi>=0.1.1` not `==0.1.1`). Fix: tighten to `==0.1.1` matching RM2 promise.

**F3 (DEFERRED to sub-plan 030)**: STEP 0.3 trigger (c) ±5% threshold borderline (gap 6.1% margin 1.1%). Sub-plan 030 expanded-corpus re-eval may shift relative ranking.

## Promotion candidates

- **L-S363-1 (1st-instance HOLD)**: per-source corpus attribution should auto-derive from `find / wc -l` not hand-curate (F1 root). AP-23 promote-on-2nd-instance.
- **L-S363-2 (3rd-instance CARRY-FORWARD candidate)**: ADR risk-mitigation text must match target file content (F2 = 3rd doc-vs-source-drift instance after S358 BSD-3 case + S341 LOC-overstate). Recommend lesson-synthesizer review at next promote-rule dispatch — may justify PreToolUse hook that grep-asserts every ADR § Risks claim "pinned in X" matches X's actual content.

## Verifier-emergent score-criteria

- (a) Corpus large enough: YES (36 ≥ 30 floor)
- (b) Reference financial-term list appropriate: YES (5-category coverage)
- (c) pyvi security: UNKNOWN (no pip-audit run; defer to next harness sweep)

## Compliance attestation

- AP-1 fresh-context ✓
- VBW ✓ (Read all production files + Bash for empirical reproduce + cite file:line for every claim)
- 0 file writes / 0 commits
- Adversarial mindset ✓ (3 minor findings + 2 promotion candidates surfaced)
- Verifier budget: ~125K Opus (under recalibrated 80-180K per M-S360-2 CLAUDE.md update; first dispatch under recalibrated table)

## Recommendations

MERGE at commits 19e18af + 5a7a42f + (this turn's close-bookkeeping). F1+F2 INLINE-RESOLVED. Promote L-S363-1 + L-S363-2 in next harness session. Dispatch sub-plan 030 architect for E.2 sentiment lexicon next.
