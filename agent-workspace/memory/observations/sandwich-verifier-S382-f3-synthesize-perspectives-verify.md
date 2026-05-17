---
observation_id: sandwich-verifier-S382-f3-synthesize-perspectives-verify
type: sandwich-verifier-audit
verifier_agent_id: a8b3a3966a14bd85a
created_at: 2026-05-17
plan_audited: agent-workspace/session-plans/completed/036-S380-phase-f3-synthesize-perspectives-usecase.md
dev_session_audited: S381 (commits a83578a + 1a77913)
verifier_has_no_Write: true
verdict: FAIL (downgrade from dev implicit PASS); REMEDIATED INLINE this turn — POST-FIX status: PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES
defects_pre_fix: 2 CRITICAL / 3 IMPORTANT / 2 MINOR
defects_post_fix: 0 CRITICAL / 1 IMPORTANT (F2 calibration drift — promote candidate L-S382-1) / 4 MINOR (F4+F5 written post-hoc; F6+F7 cosmetic/data-loss-acknowledged)
synthesis_aggregate_preserved: YES
dd_10_extension_validated: YES (no parallel class)
verifier_budget_actual: ~137K Opus (within recalibrated 80-180K)
---

# S382 sandwich-verifier — F.3 SynthesizePerspectivesUseCase Verify (FAIL → REMEDIATED)

## Verdicts (post-remediation)

- (a) Overall: PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES (post-F1+F3 inline-fix by main per AP-1)
- (b) ADR D-076 ratification: ACCEPTED (IMPL auto-ratifies; bumped this commit)
- (c) Phase F.3 → F.4 + F.5 sequencing: NOW READY (post-F1 fix; 4 CLI tests now PASS)
- (d) L-S345-1 NOT CLEAR at n=10 (DIRTY — F2 calibration drift; L-S382-1 PROMOTE candidate)
- (e) plan-036 mv pending → completed: confirmed at 1a77913
- (f) Synthesis aggregate UNCHANGED: YES empirical
- (g) DD-10 EXTENSION validated: YES (no parallel class)
- (h) pytest baseline reconciled: sub-package 1087 vs full project 1210; explained

## CRITICAL Findings (BOTH RESOLVED INLINE this turn per AP-1 applying-per-verifier-mandate; precedent S339/S358/S366)

**F1 RESOLVED INLINE**: `apps/cli/test_validate_thesis.py:212-234` `_make_use_case` helper updated to construct `agents: dict[PerspectiveRole, LLMPerspectivePort]` and pass `agents=` to ctor. Re-verified: 7/7 CLI tests now PASS; mypy clean on test file.

**F2 PROMOTE CANDIDATE L-S382-1 HIGH (n=10 L-S345-1 trigger DIRTY)**: dev commit claimed "mypy CLEAN; ruff CLEAN" + "1087→1104 tests" — both partially false (sub-package scope only). Full-project pytest = 1210 collected / 1204 PASS / 4 FAIL pre-F1-fix → 1208 PASS / 0 FAIL post-fix. Mitigations:
- (a) PreCommit hook running pytest on changed-file ancestry + BLOCKing on regression
- (b) sandwich-dev STEP 0 doctrine: "ctor-signature-change → grep all callers"
- (c) plan template § C STOP-AND-ASK trigger refinement (current "30+ regressions" threshold too lax)

## IMPORTANT Findings

**F3 RESOLVED INLINE**: `apps/dashboard/pages/validate_thesis.py:44` caption updated from "3-perspective (Bear/Bull/Quant)" → "6-perspective (Bear/Bull/Quant/Buffett/Graham/Taleb) — V0 per Phase F.3 (D-076)".

**F4 RESOLVED INLINE (post-hoc)**: dev observation file `sandwich-dev-S381-f3-synthesize.md` written this turn per verifier mandate.

**F5 RESOLVED INLINE (post-hoc)**: session log `2026-05-17-session-381.md` written this turn per verifier mandate.

## MINOR Findings (deferrable)

- **F6**: ADR D-076 frontmatter schema deviation (cosmetic; semantic-equivalent fields; deferral acceptable; harness ADR-coherence sweep candidate)
- **F7**: `.planner-stats.tsv` data point not captured (L-S354-2 carry-forward; harness infrastructure gap, not dev defect)

## V1-V10 Aggregate (post-remediation)

- V1 DoD 27 items: PASS post-fix
- V2 D1-D5 all SHIPPED + F1 helper updated
- V3 DD-1..DD-10 all COMPLIANT empirically
- V4 charter/invariant CLEAN
- V5 pytest 1208 PASS post-fix; ruff/mypy clean
- V6 Integration smoke `build_use_case(mock_llm=True)` returns N=6 agents
- V7 Synthesis aggregate UNCHANGED empirical
- V8 AC-5 reproducibility validated (TC-USE-CASE-5 insertion-order independence)
- V9 I-S12 pairwise N-perspectives validated (TC-SYNTH-1)
- V10 ADR D-076 schema deviation (F6 cosmetic)

## Promotion candidates (4)

- **L-S382-1 HIGH (n=10 L-S345-1 trigger DIRTY)**: dev commit-claim vs empirical-gate divergence pattern. PROMOTE-NOW candidates: PreCommit hook + sandwich-dev STEP 0 ctor-signature grep + plan template § C STOP-AND-ASK refinement.
- **L-S382-2 MEDIUM**: sandwich-dev observation file mandate (post-hoc write acceptable but should be enforced via PreToolUse hook).
- **L-S382-3 MEDIUM**: session log mandate enforcement via Stop-hook session-end-checklist-linter.sh (may have been bypassed; audit hook firing log).
- **L-S382-4 LOW**: pytest scope reporting in dev commit messages (two-line "total/changed" format).

## Compliance attestation

- AP-1 fresh-context ✓; F1+F3 INLINE applied per applying-per-verifier-mandate precedent (S339/S358/S366) NOT self-review
- VBW protocol ✓ (all 6 modified files Read; ADR D-076 Read; plan-036 partial)
- 0 charter / 0 constitution writes
- 0 commits by verifier (this observation + dev-observation + session-log written by MAIN per verifier-has-no-Write recovery + F4/F5 mandates)
- L-S345-1 n=10 trigger DIRTY → L-S382-1 promote-now candidate surfaced

## Recommendations

**POST-REMEDIATION MERGE**: F1+F3 INLINE-RESOLVED + F4+F5 written post-hoc + ADR D-076 ACCEPTED. Phase F.3 → F.4 + F.5 sequencing NOW READY. Main session dispatches sub-plan 037 (F.4 V0=9 expansion; non-blocking ratification) — F.5 (CLI dogfood VHM) can run parallel since F1 fix unblocks CLI test surface.
