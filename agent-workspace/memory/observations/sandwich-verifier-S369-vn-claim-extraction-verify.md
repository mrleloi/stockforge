---
observation_id: sandwich-verifier-S369-vn-claim-extraction-verify
type: sandwich-verifier-audit
verifier_agent_id: a5c17c08a87fedaba
created_at: 2026-05-17
plan_audited: agent-workspace/session-plans/completed/031-S367-phase-e3-claim-extraction-wrapper.md
dev_session_audited: S368 (commit b6b3877)
verifier_has_no_Write: true (recovery pattern: main writes this file)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
defects: 0 CRITICAL / 0 IMPORTANT / 5 MINOR
l_s345_1_clear_n6: yes (5/5 wc -l byte-exact match)
transport_flip_validated: YES (4 grep checks ALL GREEN; news-side)
rule_16_mode2_anti_drift_validated: YES (pure-function + system prompt + defense-in-depth)
d050_d051_d052_migration_executed_in_code: PARTIAL (news-side YES; analysis-side NO — D-052 ADR has false empirical_close_verify claim)
adr_d072_ratification: ACCEPTED (IMPL-tier auto-ratifies)
phase_e3_to_e4_ready: yes
verifier_budget_actual: ~119K Opus (within recalibrated 80-180K)
---

# S369 sandwich-verifier — VN Claim Extraction Wrapper Verify (E.3 + transport flip)

## Verdicts (8 gates)

- (a) Overall: PASS-WITH-CONCERNS
- (b) ADR D-072 ratification: ACCEPTED (IMPL-tier auto-ratifies)
- (c) Phase E.3 → E.4 sequencing: READY
- (d) L-S345-1 CLEAR at n=6: YES (5/5 wc -l byte-exact)
- (e) plan-031 mv pending → completed: AUTHORIZED
- (f) Transport flip empirically validated: FULLY VALIDATED (4 grep checks ALL GREEN)
- (g) DD-4 Rule 16 mode-2 anti-drift: FULLY VALIDATED
- (h) D-050/D-051/D-052 migration in code: **PARTIAL** (news YES; analysis NO — pre-existing D-052 false-attestation)

## V1-V9 Aggregate

- V1: 32/33 PASS + 1 N/A (DC-GATE-5 firing-tests pre-existing TIMEOUT)
- V2: D1-D5 all SHIPPED
- V3: DD-1..DD-7 all PASS
- V4: 0 charter / 0 constitution / I-S1 ✓ / I-S2 ✓ / I-S20 ✓ / I-S34 ✓
- V5: pytest 1085 PASS + 1 skip independently re-run
- V6: Integration smoke clean (ClaudeLlmExtractor instantiates with default factory)
- V7: Transport flip 4 grep checks ALL GREEN (zero anthropic imports + zero _default_transport refs + factory wired + tests assert invariants)
- V8: Rule 16 mode-2 anti-drift validated (pure-function _compute_lexicon_artifacts + system prompt "DO NOT include" clause + defense-in-depth field parsing)
- V9: D-052 PARTIAL — 2/4 items shipped (news side); items 1+3 (analysis adapter + pyproject dep) DEFERRED per plan-031 § A.3 scope

## Critical Finding F3 — D-052 ADR false-attestation

D-052 § empirical_close_verify line 4 claims "Production-code grep `^[ \t]*(?:import\s+anthropic|from\s+anthropic\b)` in apps/+packages/ = 0 hits". **VERIFIER REPRODUCED: 1 hit at `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80`**. ADR claim is FALSE — current code has anthropic import; ADR was filed ACCEPTED 2026-05-09 with no actual file edit.

Pattern: **2nd instance of "ADR-accepted but code-deferred"** (1st was S363 F2 pyproject pin operator). AP-23 PROMOTE-NOW threshold met for L-S363-2 + L-S369-1 cluster.

## L-S345-1 anti-regression CLEAR at n=6

5/5 dev wc -l claims match independent wc -l: extracted_claim.py 106 / claude_llm_extractor.py 289 / test_adapters.py 590 / extract_vn_claims.py 318 / D-072 133. RETIRED status holds.

## Defects (5 MINOR)

- **F1**: documentation drift in session log filename reference (cosmetic)
- **F2**: DC-GATE-1 mypy fails on plan-spec multi-directory invocation due to duplicate-module-name (pre-existing infra; modified files individually pass)
- **F3**: D-052 incomplete — analysis adapter `import anthropic` still at line 80 + pyproject.toml dep not removed (pre-existing D-052 false empirical_close_verify; NOT introduced by S368)
- **F4**: 3 firing-tests TIMEOUT (atomic-write/path-safety/python-determinism pre-existing per git log S347/S341/S332)
- **F5**: TC D3-4 cosmetic comment drift

## Promotion candidates (3 1st-instance HOLD)

- **L-S369-1 (n=2 with L-S363-2; AP-23 PROMOTE-NOW threshold MET)**: ADR empirical_close_verify drift detection — recommend periodic harness check (`adr-empirical-close-verify-spot-check-fire-test.sh` already exists) re-validates `empirical_close_verify` grep-claims against current code state for ACCEPTED ADRs. PROMOTE-NOW per AP-23.
- **L-S369-2**: Plan DC-GATE specifies multi-dir mypy that fails on pre-existing config. Architect template update to require `--explicit-package-bases` clause OR `mypy.ini` config-as-source-of-truth.
- **L-S369-3**: Verifier template — for chained-ADR migration questions, extend critical-grep scope to entire chained-ADR file domain (not just current session files).

## Dev handoff (carry-forward)

1. **D-052 § Decision items 1 + 3 STILL DEFERRED** — separate session (S370+ harness sweep) to delete `_default_transport` in analysis adapter + remove `anthropic>=0.40.0` from pyproject.toml + update D-052 empirical_close_verify
2. mypy duplicate-module-name infra (harness session)
3. Firing tests 3 TIMEOUTs (pre-existing)
4. Lexicon real-corpus coverage unknown (RM7 + D-072 revisit trigger 3)
5. Sub-plan 032 E.4 ticker resolver READY to dispatch

## Compliance attestation

AP-1 ✓ / 0 file writes / 0 commits / 0 charter / 0 constitution / harness_priority_one ✓ (3 harness gaps surfaced + tracked as L-S369-N candidates)

## Recommendation

**MERGE** at commit b6b3877 + (this turn close). News-side transport flip is fully shipped + validated; D-052 final cleanup (analysis-side) needs separate session. Sub-plan 032 (E.4) dispatch unblocked.
