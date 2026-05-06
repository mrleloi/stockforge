---
proposal_id: drift-signals-reconciliation
created: 2026-05-05
session: S48c (HH-B.4)
type: charter-amendment + hook-extension
target: agent-workspace/constitution/drift-signals.md + scripts/hooks/drift-signals-D1-D9.sh
status: ACCEPTED
ratified_at: 2026-05-05
ratified_via: AskUserQuestion S48d 4-Q bundle Q2=ACCEPT
ratifying_adr: D-029
deny_lift_required: yes (`.claude/settings.json` line 105 blocks Edit on agent-workspace/constitution/**)
related_observation: agent-workspace/memory/observations/2026-05-05-drift-signal-audit-S48c.md
---

# Proposal — Drift Signal Doctrine ↔ Implementation Reconciliation

## Why this proposal exists

Audit finding (S48c HH-B.4): the doctrine `drift-signals.md` defines 14 signals (DR1-DR12 + DR-S1, DR-S2). The hook `drift-signals-D1-D9.sh` implements 9 signals (D1-D9). Coverage is **2/14 covered**, **3/14 partial**, **5/14 unimplemented but grep-feasible**, **4/14 deferred-to-other-tier**. Worse: the numbering schemes (D vs DR) collide, leaving readers confused about which signal fires when.

The S48 plan calls this "8 signals never fire" and asks for "retire dead OR fix detector". This proposal addresses both paths.

## Proposed amendments

### Part A — Doctrine reorganization (constitution/drift-signals.md)

**Add** new section "## Tiered Coverage Map" right after `## How to Use` (before the existing severity-ordered list):

```markdown
## Tiered Coverage Map

Drift signals are detected at three tiers depending on what's grep-able vs. what requires deeper checks:

**Tier-A — Automated detector** (Stop-hook `drift-signals-D1-D9.sh`; runs every session-end):
- DR-A1 — LOC ceiling overrun (PRIMARY per Q-A2)
- DR-A2 — Self-attestation contradicting actual file content
- DR-A3 — Charter/SCOPE bundled with sub-charter items
- DR-A4 — Confidence claim without calibration metadata
- DR-A5 — Runtime-path-leak into write-only learning-data tree (D-005)
- DR1 — Domain layer imports framework  ← (NEW: extended from doctrine, prev. unimplemented)
- DR3 — LLM call without retry/budget wrapper  ← (NEW)
- DR6 — `Any` type in domain package  ← (NEW)
- DR8 — Cross-BC direct import  ← (NEW)
- DR-S1 — LLM emitted number without tool call (covered by D6 LLM-math)
- DR-S2 — Thesis output without bear case (covered by D7)
- DR2 — Evidence without citation (partial via D5 numeric+citation grep)
- DR5 — Claim without metadata (partial via D5)
- DR10 — Spec dangling reference (partial via D4)

**Tier-B — Manual /drift-check command** (semantic checks; requires LLM judgment):
- DR4 — Hardcoded prompt outside prompts/
- DR7 — UL term drift (also via /ul-audit)
- DR12 — Anti-pattern from agent-notes.md

**Tier-C — DB-query check** (requires Postgres connection; not run on every session):
- DR9 — Synthesis output without verifier step
- DR11 — Stale session-handoff (also git-log diff-able)
```

**Rename existing detectors** in script comments + doctrine:
- D1 → DR-A1 (LOC ceiling)
- D2 → DR-A2 (self-attestation)
- D3 → DR-A3 (charter/SCOPE bundle)
- D8 → DR-A4 (confidence no-calibration)
- D9 → DR-A5 (path-leak)
- D6 → DR-S1 (LLM-math) — already DR-stock-specific
- D7 → DR-S2 (no bear case) — already DR-stock-specific

This eliminates the D vs DR numbering collision. Hook script can keep filename `drift-signals-D1-D9.sh` for path stability but internal labels emit `DR-A1` etc.

### Part B — Hook extensions (scripts/hooks/drift-signals-D1-D9.sh)

Add 4 new grep-feasible detectors (no charter gate; script is freely editable):

```bash
# DR1: Domain layer imports framework (HIGH)
DR1_VIOLATIONS=$(grep -rn "from fastapi\|from pydantic\|from sqlalchemy\|import psycopg\|from redis" \
  "$PROJECT_DIR/packages/domain/" --include="*.py" 2>/dev/null | wc -l | tr -d '[:space:]')
[[ "$DR1_VIOLATIONS" =~ ^[0-9]+$ ]] && [ "$DR1_VIOLATIONS" -gt 0 ] && \
  emit "DR1-DOMAIN-FRAMEWORK" "HIGH" "count=$DR1_VIOLATIONS files=packages/domain/**"

# DR3: LLM call without retry/budget wrapper (MEDIUM)
DR3_VIOLATIONS=$(grep -rn "anthropic.Anthropic\|client.messages.create" \
  "$PROJECT_DIR/packages/infrastructure/" --include="*.py" 2>/dev/null \
  | grep -v "with_budget\|with_retry\|budget_aware" | wc -l | tr -d '[:space:]')
[[ "$DR3_VIOLATIONS" =~ ^[0-9]+$ ]] && [ "$DR3_VIOLATIONS" -gt 0 ] && \
  emit "DR3-LLM-NO-RETRY" "MEDIUM" "count=$DR3_VIOLATIONS"

# DR6: Any type in domain (HIGH)
DR6_VIOLATIONS=$(grep -rn ": Any\|cast(Any\|-> Any" "$PROJECT_DIR/packages/domain/" \
  --include="*.py" 2>/dev/null | grep -v "test_\|_test.py" | wc -l | tr -d '[:space:]')
[[ "$DR6_VIOLATIONS" =~ ^[0-9]+$ ]] && [ "$DR6_VIOLATIONS" -gt 0 ] && \
  emit "DR6-DOMAIN-ANY-TYPE" "HIGH" "count=$DR6_VIOLATIONS"

# DR8: Cross-BC direct import (HIGH)
DR8_VIOLATIONS=0
for BC in market_data fundamental company_intelligence macro news influence crowd analysis portfolio; do
  [ -d "$PROJECT_DIR/packages/domain/$BC" ] || continue
  cnt=$(grep -rn "from packages\.domain\." "$PROJECT_DIR/packages/domain/$BC/" \
    --include="*.py" 2>/dev/null | grep -v "packages/domain/$BC/" | wc -l | tr -d '[:space:]')
  [[ "$cnt" =~ ^[0-9]+$ ]] && DR8_VIOLATIONS=$(( DR8_VIOLATIONS + cnt ))
done
[ "$DR8_VIOLATIONS" -gt 0 ] && \
  emit "DR8-CROSS-BC-IMPORT" "HIGH" "count=$DR8_VIOLATIONS"
```

These 4 detectors run only when `packages/domain/` and `packages/infrastructure/` exist (Phase 1+ post-VHM). They're low-overhead grep-only — no DB, no LLM.

## Ratification paths

**Path A — ACCEPT (recommended)**: User answers "A" → agent applies via deny-lift cycle:
1. Edit `.claude/settings.json` line 105 to remove `agent-workspace/constitution/**` from deny list.
2. Apply Part A doctrine amendment to `drift-signals.md`.
3. Restore deny line.
4. Verify zero-residue (D9 charter-md5 unchanged outside the amended file).
5. Apply Part B hook extension (no gate needed).
6. Smoke test the new D1/3/6/8 detectors against current repo state.
7. Author D-NNN ADR.

**Path B — AMEND**: User answers "B" → re-author with user-suggested changes; re-fire bundle.

**Path C — REJECT**: User answers "C" → close proposal; status → REJECTED. Hook extension Part B alone may still ship if user wants partial.

## What if not ratified

If user defers indefinitely:
- Doctrine remains misaligned with hook implementation (current state).
- Hook still works correctly under D1-D9 labels, just under-documented.
- Reader confusion persists between DR-N (doctrine) and D-N (hook).
- 4 grep-feasible DR-N (DR1/3/6/8) remain unimplemented in hook — Part B can ship standalone if user separately agrees.

## Bundle opportunity

Per L-S43f-1 bundled-deny-lift doctrine: this proposal can pair with any other queued constitution amendment (none currently queued; check `proposals/` directory at next charter-promote cycle).

## Diff size estimate

- Part A doctrine amendment: +35 LOC to `drift-signals.md` (under D1 200-LOC ceiling at +35/+225 = 16% delta — within target).
- Part B hook extension: +30 LOC to `drift-signals-D1-D9.sh` (currently 165 LOC → ~195 LOC; under D1 200-LOC ceiling — within target).
