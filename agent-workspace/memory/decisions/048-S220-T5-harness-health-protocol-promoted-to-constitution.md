---
decision_id: D-048
title: harness-health-protocol.md promoted from agent-workspace/proposals/ to agent-workspace/constitution/
status: ratified
created_at: 2026-05-09
created_via: S220 main-session opus47-max bundled deny-lift cycle
ratification_basis:
  - D-033 (S173 T5 protocol authored in proposals/ via M-S173-1 deny workaround; Q1=A user approval same turn)
  - S219 AskUserQuestion re-confirmation Q1=A (no semantic delta; protocol content unchanged from S173 authoring)
  - S220 deny-lift mode A approved
related_decisions:
  - D-033 (T5 protocol initial authoring — this promotes to canonical location)
  - D-035 (T6 hook impl — references this protocol's signal set inline)
  - D-047 (charter v1.1 Principle 11 — references this protocol file path)
artifacts_modified:
  - mv agent-workspace/proposals/harness-health-protocol.md → agent-workspace/constitution/harness-health-protocol.md (file content unchanged; 426 LOC + 23 KB)
---

## Why ratified

D-033 codified harness-health-protocol.md as Phase 3.5 T5 deliverable but landed it in `proposals/` per M-S173-1 deny on direct constitution writes. The protocol has been the canonical reference for HH-1..HH-12 signal catalog operationalized by `scripts/hooks/harness-health-self-scan.sh` (D-035) for ~46 sessions of real production use without amendment. Q1=A user approval re-confirmed at S219; S220 deny-lift cycle authorized agent to land it in canonical location.

## Mechanism (S220 turn)

- `git mv agent-workspace/proposals/harness-health-protocol.md agent-workspace/constitution/harness-health-protocol.md` — preserves git history.
- File content UNCHANGED post-mv (no edits to protocol body; only filesystem location changed).
- `.claude/settings.json` deny block temp-lifted via `_S220_TEMP_LIFTED_` prefix per D-047 mechanism; restored same-turn.

## Empirical close-verify

- `ls -la agent-workspace/constitution/harness-health-protocol.md` = 23388 bytes ✓
- `git status agent-workspace/proposals/harness-health-protocol.md` = D (deleted) ✓
- `git status agent-workspace/constitution/harness-health-protocol.md` = R (renamed/added) ✓
- Hook header reference `agent-workspace/{proposals,constitution}/harness-health-protocol.md` (line 3 of harness-health-self-scan.sh) — both paths still acknowledged; canonical now constitution/ ✓

## Consequences

- T5 Phase 3.5 deliverable COMPLETE in canonical location.
- Hook header comment in `scripts/hooks/harness-health-self-scan.sh:3` can be updated next opportunistic edit to remove `proposals/` reference (cosmetic; not blocking).
- M-S173-1 deny continues to bind for FUTURE constitution writes (one-time bundled deny-lift consumed).
