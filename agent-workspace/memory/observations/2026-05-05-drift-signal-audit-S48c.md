---
observation_id: 2026-05-05-drift-signal-audit-S48c
type: substrate-audit
created_at: 2026-05-05
session: S48c (HH-B.4)
related_session_plan: agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md § HH-B.4
status: AUDIT-COMPLETE — 1 proposal queued (drift-signals-reconciliation.md)
---

# Drift Signal Audit — DR1-DR12 vs drift-signals-D1-D9.sh

## Scope

HH-B.4 deliverable per S48 Phase 2.5 plan: reconcile **doctrine names** (`drift-signals.md` DR1..DR12 + DR-S1, DR-S2) against **hook implementation** (`scripts/hooks/drift-signals-D1-D9.sh` D1..D9). Plan claim: "8 signals never fire — retire dead OR fix detector." Verify and propose remediation.

## Method

1. Read `agent-workspace/constitution/drift-signals.md` (charter doctrine; immutable absent user gate).
2. Read `scripts/hooks/drift-signals-D1-D9.sh` (Stop hook, runs every session-end).
3. Build gap matrix.
4. Categorize each DR-N: **covered** (matching D-N grep) / **partial** (related D-N) / **unimplemented** (no automated detector).
5. Categorize each D-N: **codified in doctrine** (matches DR-N) / **emergent-only** (Q-A2 / D-005 origin, not in doctrine).

## Gap Matrix — Doctrine DR-N → Hook D-N coverage

| DR-N (doctrine) | Severity | Hook coverage | Status |
|---|---|---|---|
| DR1 — Domain layer imports framework | HIGH | NOT in hook | **unimplemented** (grep-feasible — should add) |
| DR2 — Evidence without citation | HIGH | partial via D5 (numeric+citation grep) | **partial** (D5 only checks files with numbers; misses claims w/o numbers) |
| DR3 — LLM call without retry/budget | MEDIUM | NOT in hook | **unimplemented** (grep-feasible) |
| DR4 — Hardcoded prompt outside prompts/ | MEDIUM | NOT in hook | **unimplemented** (heuristic 500+ char strings; grep-feasible) |
| DR5 — Claim stored without required metadata | HIGH | partial via D5 | **partial** (DB query needed for full coverage; grep is best-effort) |
| DR6 — `Any` type in domain package | HIGH | NOT in hook | **unimplemented** (grep-feasible) |
| DR7 — UL term drift | HIGH | NOT in hook | **deferred-to-/ul-audit** (semantic; not grep-able) |
| DR8 — Cross-BC direct import | HIGH | NOT in hook | **unimplemented** (grep-feasible per BC) |
| DR9 — Synthesis output without verifier | HIGH | NOT in hook | **deferred-to-DB-query** (requires SQL) |
| DR10 — Spec referenced doesn't exist | MEDIUM | partial via D4 (spec dangling ref) | **partial** (D4 checks .py refs; doesn't check spec-IDs) |
| DR11 — Stale session-handoff | LOW | NOT in hook | **deferred-to-DB-query** (git log + grep cross-ref) |
| DR12 — Anti-pattern from agent-notes.md | LOW | NOT in hook | **deferred-to-semantic** (requires LLM judgment) |
| DR-S1 — LLM emitted number without tool call | HIGH (stock-specific) | covered by D6 (LLM-math anti-pattern words) | **covered** |
| DR-S2 — Thesis output without bear case | HIGH (stock-specific) | covered by D7 (bear case missing) | **covered** |

**Summary**:
- **2/14 covered** (DR-S1, DR-S2)
- **3/14 partial** (DR2, DR5, DR10)
- **5/14 unimplemented but grep-feasible** (DR1, DR3, DR4, DR6, DR8) — 4 of these "fix detector" candidates
- **4/14 deferred** (DR7 to /ul-audit, DR9/DR11 to DB query, DR12 to semantic) — these are doctrine entries acknowledging non-grep coverage

## Gap Matrix — Hook D-N → Doctrine

| D-N (hook) | Severity | Doctrine codification | Status |
|---|---|---|---|
| D1 — LOC ceiling overrun | HIGH @ ≥20% | NOT in doctrine | **emergent-only** (Q-A2 origin 2026-04-29) |
| D2 — Self-attestation contradicting | MEDIUM | NOT in doctrine | **emergent-only** |
| D3 — Charter/SCOPE bundle | HIGH | NOT in doctrine | **emergent-only** (Q-B2 origin) |
| D4 — Spec dangling reference | LOW | partial DR10 | **partial-overlap** |
| D5 — Numeric value w/o source | HIGH | partial DR2 + DR5 | **partial-overlap** |
| D6 — LLM-math anti-pattern words | HIGH | covers DR-S1 | **renumber DR-S1** |
| D7 — Bear case missing | MEDIUM | covers DR-S2 | **renumber DR-S2** |
| D8 — Confidence w/o calibration | HIGH | NOT in doctrine | **emergent-only** (I-S20 origin) |
| D9 — Runtime-path-leak | HIGH | NOT in doctrine | **emergent-only** (D-005 Track 5.5d.1) |

**Summary**: 4/9 hook signals are emergent-only (D1/D2/D3/D8/D9) — they need to be added to doctrine. 4/9 partially overlap or rename existing doctrine. The numbering schemes (D1-D9 vs DR1-DR12) collide and confuse.

## Recommended Remediation (proposal queued)

1. **Rename**: doctrine to use `DR1-DR12` for canonical signals; hook implements detector subset. Cross-reference each hook D-N to its DR-N source in script comments.
2. **Doctrine additions** (emergent-only D-N → new DR entries):
   - DR-A1: LOC ceiling overrun (PRIMARY) — currently D1
   - DR-A2: Self-attestation contradicting — currently D2
   - DR-A3: Charter/SCOPE bundling silent absorption — currently D3
   - DR-A4: Confidence claim without calibration — currently D8
   - DR-A5: Runtime-path-leak into write-only tree — currently D9
3. **Hook extensions** (4 grep-feasible "fix detector" candidates):
   - DR1: Domain layer imports framework
   - DR3: LLM call without retry/budget wrapper
   - DR6: `Any` type in domain package
   - DR8: Cross-BC direct import
4. **Mark "deferred" explicitly** in doctrine for DR7/DR9/DR11/DR12 (not failures of detector — semantic-tier checks).

## Constitution-edit gate

`drift-signals.md` is in `agent-workspace/constitution/**` → Edit denied per `.claude/settings.json` line 105. Per S38 deny-lift mechanism + Q-B2 charter-tier rule:
- Cannot directly Edit doctrine without user gate.
- Proposal authored at `agent-workspace/proposals/drift-signals-reconciliation.md` (next deliverable in this session).
- User ratification required before constitution amendment applies.

Hook script (`scripts/hooks/drift-signals-D1-D9.sh`) is NOT in constitution; can be extended with 4 new grep-feasible detectors **without** charter gate. This is the "fix detector" path the deliverable allows.

## What this audit does NOT do (deferred)

- **Live false-positive/negative validation**: D1 surfaces 24 violations historically (per Q-A2 smoke test); D5/D6 fire counts not measured this session.
- **DR2 + DR5 DB-query coverage**: requires Postgres connection; out of scope for substrate-only audit.
- **/ul-audit + /drift-check command alignment**: separate substrate; check next session.

## References

- Doctrine: `agent-workspace/constitution/drift-signals.md` (lines 1-225)
- Hook: `scripts/hooks/drift-signals-D1-D9.sh` (lines 1-165)
- Q-A2 origin: `agent-workspace/memory/observations/queued-grill-master.md` § Q-A2 (drift leading-indicator answer)
- D-005 Track 5.5d.1: `agent-workspace/memory/decisions/005-*.md` (D9 path-leak origin)
- HH-B.4 plan: `agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md` § HH-B.4

## Closure

Audit complete. Proposal queued. Hook extension can ship same-session (no charter gate). Doctrine reconciliation gated on user approval at next AskUserQuestion bundle.
