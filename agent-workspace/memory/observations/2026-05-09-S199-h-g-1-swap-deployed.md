# S199 — D-049 H-g.1 Settings.json Hook Swap DEPLOYED (slot 5 ↔ slot 6)

**Date**: 2026-05-09
**Trigger**: User trivial-prompt "continue" at 2026-05-09T10:35:32+07:00 (~5.6 min after S198 H-f revert)
**Hypothesis (H-g.1)**: Cap is POSITIONAL — chain executor stops at slot N regardless of which hook lives there. Distinct from H-d.1 (which removed hook #5 entry entirely; REJECTED-1OF1-BINARY at S197). H-g.1 swaps positions while keeping all 9 hooks registered.

## Why H-g after H-f REJECTED

ALL 6 cheap-candidates EXHAUSTED at S198. Only structural class (H-g) remains. Per checkpoint cheapest-by-RISK: H-g.1 (~3 LOC settings swap) cheapest.

## S199 entry baseline (pre-swap, default state)

At 10:35:32 trigger BEFORE edit:
- Hook #1 fired (`UserPromptSubmit-injector: SKIP`)
- Hook #4 fired (`.in-flight-subagent-watcher.log` mtime 10:35:32)
- Hook #5 (hook-firing-counter at default slot 5) fired (`.hook-firing-counter.log` mtime 10:35:34 — counter increment + log writes; node JSON stdout emit re-armed post-S198 revert)
- Hooks #6/#7/#8/#9 STILL ALL SILENT (`.effort-escalation`/`.idle-escape`/`.phase-coherence` MISSING + `.harness-health` 09:43:25 firing-test-smoke-8584 SID UNCHANGED)

→ **14th consecutive #5/#6 boundary reproduction** in default settings.json state.

## Swap deployment

Edit `.claude/settings.json` UserPromptSubmit array — swapped slot 5 ↔ slot 6 entries:
- BEFORE: slot 5 = hook-firing-counter, slot 6 = effort-escalation-detector
- AFTER: slot 5 = effort-escalation-detector, slot 6 = hook-firing-counter

Slots 1-4 and 7-9 unchanged.

## 3-fold post-swap verification PASS

```
$ python -m json.tool .claude/settings.json > /dev/null
JSON parse OK
$ python -c "..."  # script reading nested array slots
UserPromptSubmit hook count: 9
  slot 1: ...userprompt-invariants-injector.sh
  slot 2: ...stale-prompt-detector.sh
  slot 3: ...correction-rate-tracker.sh
  slot 4: ...in-flight-subagent-watcher.sh
  slot 5: ...effort-escalation-detector.sh   ← SWAPPED (was hook-firing-counter)
  slot 6: ...hook-firing-counter.sh           ← SWAPPED (was effort-escalation)
  slot 7: ...idle-escape-detector.sh
  slot 8: ...phase-status-coherence.sh
  slot 9: ...harness-health-self-scan.sh
```

## Decision matrix (S200 production observation)

At next user trivial-prompt UserPromptSubmit event:

| Outcome | Slot 5 (effort-escalation) | Slot 6 (hook-firing-counter) | Slots 7-9 | Verdict |
|---|---|---|---|---|
| POSITIONAL cap | FIRES (`.effort-escalation.log` CREATED) | SILENT (mtime UNCHANGED at 10:35:34) | SILENT | H-g.1 CONFIRMED — cap is POSITIONAL slot-N |
| STRUCTURAL on hook | SILENT (still NO log) | FIRES (mtime BUMPED) | SILENT | H-g.1 REJECTED — cap is on SPECIFIC HOOK identity (hook-firing-counter triggers cap regardless of slot) |
| Both fire | FIRES | FIRES | SILENT | H-g.1 PARTIAL — cap at slot 7+; neither swapped hook is trigger |
| All silent | SILENT | SILENT | SILENT | H-g.1 ANOMALY — chain stopped earlier somehow |

13-instance evidence + S199 baseline (14th instance default-state reproduction) + 1 H-g.1 differential = decisive.

## D-049 H-g.1 status transition
`PROPOSED` → **`SCAFFOLD-DEPLOYED-PENDING-PRODUCTION-OBSERVATION`**

## Revert protocol post-S200 verdict

Regardless of outcome:
1. Edit `.claude/settings.json` to swap slot 5 ↔ slot 6 BACK to original ordering (slot 5 = hook-firing-counter, slot 6 = effort-escalation).
2. 3-fold verify post-revert (JSON parse OK + slot 5 = hook-firing-counter + slot 6 = effort-escalation).

If H-g.1 CONFIRMED (POSITIONAL): Strategy at S201 = hook chain reduction (consolidate to ≤4 UserPromptSubmit hooks; migrate non-critical observers to Stop-hook).
If H-g.1 REJECTED (STRUCTURAL on hook-firing-counter): Investigate runtime cost / specific stdout pattern of that hook.
If H-g.1 PARTIAL: cap at slot 7+; H-g.2 next (no-op shim test).
If H-g.1 ANOMALY: H-g.3 full chain instrumentation.

## Hard rules binding sustained

ALL prior bindings (L-S176-1 + L-S174-1 + L-S65 + Phase 3.5 §HH-G + verify_phase_before_next_phase + harness_priority_one + autonomous_continue_no_self_pause + Charter Principle 8 + cheapest-by-RISK 7-instance application). NO new binding rules.

**No git commits / 0 charter file edits / 0 constitution writes / 0 hook code edits** (S199 = settings.json swap only; ~3 LOC reversible).

End of S199 H-g.1 swap deployment. **D-049 H-g.1 scaffold DEPLOYED at 10:35+ via slot 5 ↔ slot 6 swap; 3-fold verification PASS; production observation DEFERRED to S200 next trivial-prompt UserPromptSubmit event.**
