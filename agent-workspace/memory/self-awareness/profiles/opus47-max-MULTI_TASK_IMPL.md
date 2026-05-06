---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - MULTI_TASK_IMPL
samples_count: 6
status: BIASED-PRE-REBUILD-S65 (user 2026-05-06 flagged tracking gap; rebuild after cost-ledger.tsv accumulates ≥10 sessions)
sample_sessions: [S27, S33, S34, S20, S48m, S66]
last_updated: 2026-05-06T09:16:51+07:00
source: agent-workspace/memory/sessions-rollup.tsv (S18 row only) + manual session log review S20-S34 (S48 sequence had ZERO MULTI_TASK_IMPL — all S48b..h ran as FOCUSED_IMPL; observed S48 governance pattern fits FOCUSED_IMPL band)
---

# Profile — Opus 4.7 × max × MULTI_TASK_IMPL

## 1. Capabilities

- 4-10 task batching within 150-250K budget envelope reliably (S27 first-entities BC-1+BC-9 → 161 PASS; S33 VN30 universe expansion → 214 PASS; S34 BC-2 Fundamental aggregate + adapter + service + repo → 267 PASS; S20 Track 6 secondary closure 16 D1 violators).
- mypy --strict + ruff clean post-IMPL when test-first discipline applied.
- Cross-BC + framework + LLM-math creep grep checks ship clean per session when explicitly run.
- Mid-session refactor capable (S34 peer_service.py → ConstituentRecord Protocol injection without test regression).

## 2. Known limitations

- **B (boundary-violation)**: Cross-BC direct imports not auto-detected without import-linter independence contract (KI-S35-3; mitigated S35 D6).
- **D (deferral)**: Tendency to absorb cosmetic LOC overruns as IMPL-S{N}-* deviations (S33 had 6 deviations; S34 had 4) rather than strict ceiling discipline. Acceptable per L-S15-1 inline-document doctrine but compounds when ceiling drift becomes the norm.
- **A (assumption-without-verification)**: External-vendor API drift not detected pre-IMPL without empirical probe (S28 TCBS 404; S32 vnstock VCI-only). KI-S35-4. Mitigated via L-S32-1 doctrine; promote-pending hook.
- **T (token-budget-overrun)**: S34-extension self-track ~280K vs 250K hard_cap. Plan-fidelity bias finishes deliverables despite pressure. KI-S35-2; mitigated S35 D7.

## 3. Recommended task_class allocation

- **PRIMARY** for `MULTI_TASK_IMPL` 4-10 tasks at 150-250K. Track A/B/C closures benefit from session continuity (cross-task context).
- AVOID for `PLAN`-only sessions — overhead too high; prefer master-plan subagent dispatch (Sonnet/default).
- AVOID for VERIFY-only — fresh-context separate-agent gate per AP-1; verifier subagent (Opus or Sonnet) preferable.

## 4. Recent corrections + drift events

- M-S20-1 (permission-system bug; mid-session bash compound chain matcher)
- M-S26-1 (master-plan internal contradiction; fixed before IMPL)
- M-S28-1 (vendor-API drift TCBS 404)
- M-S33-1 / M-S34-1 (cross-BC import miss; refactor)
- M-S35-3 (self-track > hard_cap)
- M-S35-4 (4 dead meta-loops)
- **M-S48d-1 pipefail-bracket trap** (relevant to MULTI_TASK_IMPL hook authoring; if ≥3 hooks shipped per session, ERR-trap silent failures multiply; mitigation: `set +o pipefail` brackets around optional greps applied in S48d HH-C.3 + S48g HH-E.1 + S48h HH-E.2 hook authors).

## 5. Calibration

- Test-suite delta per session: S27 +9 / S33 +16 / S34 +53 (mean ~+26 per session). Test-PASS rate post-IMPL: 100% (0 regressions across 4 samples).
- Budget actual vs target: S27 unknown / S33 ~80-110K (favorable) / S34 ~120-160K (favorable; under target) / S20 ~292K (over hard_cap due to permission bug context inflation).
- Hit rate (deliverables shipped / planned): 4/4 = 1.00 with cosmetic deviations under D1 threshold (20%).
- IMPL-tier LOC ceiling adherence rate: 60% (cosmetic deviations under D1 in remaining 40%).

## 6. Notes

This profile is a manual back-fill from session-log review (S35 D3) — sessions-rollup.tsv only carries S18 smoke row because Stop-hook aggregator was deferred-wire S19 (IMPL-S19-1). Phase 1+ telemetry-analyst should auto-render this card from live aggregator data.
