---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - FOCUSED_IMPL
samples_count: 23
sample_sessions: [S26, S28, S30, S32, S35, S47, S48b, S48c, S48d, S48f, S48g, S48h, S48l, S49, S55, S56, S57, S58, S59, S60, S61, S62, S63]
last_updated: 2026-05-05T23:42:28+07:00
status: BIASED-PRE-REBUILD-S65 (user 2026-05-06 flagged tracking gap; rebuild after cost-ledger.tsv accumulates ≥10 sessions)
source: manual session log review (S48i HH-F.1 ETL backfill — auto-populate hook gap S48e..S48h investigation deferred S48j)
---

# Profile — Opus 4.7 × max × FOCUSED_IMPL

## 1. Capabilities

- 1-3 task focus within 100-150K budget envelope (S26 VN-domain proposals; S28 Tier 1 ingestion adapter; S30 Phase 1 closure; S32 Track A R2 closure; S35 meta-loop recovery).
- Cosmetic cleanup + refactor + deferred-residue resolution single-pass.
- Live-smoke + reconciliation discipline (S28 248 VHM bars; S32 248 vnstock + 248 SSI = 496 rows reconciled; S30 VHM exemplar thesis with 15 deterministic SQL queries).
- IMPL-tier decision file authoring per L-S15-1 inline doctrine when needed (D-006, D-007, D-008, D-012).
- **NEW S48 governance cluster (Phase 2.5 harness hardening)**: Hook authoring + smoke testing in single sessions (S48b HH-A 6/6; S48c HH-B 5/5 telemetry repair; S48d HH-C 4/4 watchdog hooks + D-028+D-029 ratify; S48f HH-D.2 + D-030 charter promote autonomous-protocol Rule 10; S48g HH-E.1 stale URGENT escalator + HH-E.2 proposal author; S48h HH-E.2 ratify + D-031 + qa-pending-auto-mover.sh ship + smoke 4/4 GREEN). Direct-edit pattern when target NOT in `agent-workspace/constitution/**` deny list (S48h CLAUDE.md edit; distinct from D-018..D-030 deny-lift cycle).
- **Bundled deny-lift cycle** competence (S48d D-029 drift-signals reconciliation + S48f D-030 autonomous-protocol Rule 10 — both via `Edit(agent-workspace/constitution/**)` deny temporary lift + restore same-turn + D9 zero-residue verify).
- **Companion ADR provenance authoring** (12-field schema): D-028..D-031 all under L-S15-1 inline doctrine. ~150-190 LOC each; provenance chain + trade-offs + drift-watch + companion handoff sections consistently shipped.

## 2. Known limitations

- Subagent overrun risk when nested under FOCUSED_IMPL — S25 architect subagent ~220K vs 150-180K envelope (M-S25-1; L-S25-1 calibrated).
- Self-track closer to budget ceiling than MULTI_TASK_IMPL (S20 292K; S35 ~ pending close).
- DR-DEFER soft-flagged residue tends to accumulate; 5 lessons batched without promotion across S25-S30.

## 3. Recommended task_class allocation

- **PRIMARY** for FOCUSED_IMPL 1-3 tasks at 100-150K — explicit single-track scope.
- ALSO for short META_LOOP_RECOVERY (S35 type) when cleanup spans multiple deterministic edits + 2 subagent dispatches.
- AVOID for >3-track wiring → upgrade to MULTI_TASK_IMPL.

## 4. Recent corrections + drift events

- M-S25-1 subagent budget overrun
- M-S28-1 vendor-API drift
- M-S29-1 verifier residue R1-R4 (S30 fixed R1)
- M-S31-1 master-plan LOC over advisory cap
- M-S35-1..5 cognitive failures (S35 META_LOOP_RECOVERY)
- **M-S45-1 substrate data-loss** (sandwich-architect Write vs Edit on agent-notes.md; ~140 lines unrecoverable; L-S45-2 mechanical guard `write-vs-edit-guard.sh` shipped same-turn)
- **M-S45-2 + M-S47-1 Mode-E recurrence** (3rd L-S44-1 family; D-030 charter Rule 10 promotion S48f)
- **M-S48d-1 pipefail-bracket trap** (set -uo pipefail + grep-no-match silently tips ERR trap; mitigation: `set +o pipefail` brackets around optional greps OR `{ grep ...; } || true` subshell wrapper). Applied in S48g/S48h hook authoring.
- **M-S48e-1 garbled keystroke-injection** (`//nneeww` SendKeys double-keystroke; root cause TOCTOU between Stop + PostToolUse budget-watchdog firing session-self-reboot; HH-H.5 fix sub-deliverable scoped S48k)

## 5. Calibration

- Budget actual: S26 ~? / S28 ~110-140K / S30 ~85-110K / S32 ~80-110K (all favorable); S20 ~292K (over).
- Hit rate: 5/5 deliverables shipped; 100% test-PASS (0 regressions).
- Decision-file LOC adherence: D-012 +46% over advisory; D-007 +? — IMPL-tier doc-density bias accepted.

## 6. Notes

S35 is a META_LOOP_RECOVERY variant of FOCUSED_IMPL — added to test if recovery sessions need a separate type or fit under FOCUSED_IMPL. Recommend keeping under FOCUSED_IMPL with `META_LOOP_RECOVERY` tag.
