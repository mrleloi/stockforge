# S197 — D-048 H-f Test Scaffold DEPLOYED (marker-file gate on stdout JSON emit)

**Date**: 2026-05-09
**Trigger**: Internal continuation post-S197 H-d.1 verdict (autonomous-full mode; same main turn as H-d.1 verdict observation)
**Hypothesis (H-f)**: Claude Code Windows UserPromptSubmit chain executor caps at stdout-emit byte/content threshold — distinct from H-a (D-046, REJECTED-FORMAL) which redirected stderr but kept emit; H-f deletes/silences the stdout emit entirely so no bytes flow regardless of stream.

## Why H-f after H-d.1 REJECTED

Hypothesis stack collapsed at S197 for H-d.1: registration-count is NOT cap mechanism. Per checkpoint cheapest-by-RISK ordering: **H-f** (~3-8 LOC; minimally destructive; reversible via marker delete) → **H-g** (~10-15 LOC chain restructure / instrumentation).

Note H-f tests OPPOSITE of D-044 H-c: D-044 added stdout JSON to TEST whether chain needed it for advancement (REJECTED at S189 — adding it didn't help). H-f silences that same line to TEST whether chain is HARMED by stdout output (potentially explains why advancement never occurred even after D-044 added emission).

## Scaffold construction (D-047 pattern match)

Per S192 D-047 H-d marker-file precedent (REVERSIBLE INSTRUMENTATION). Edit `scripts/hooks/hook-firing-counter.sh` lines 130-131:

```bash
# Original (line 130):
node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:''}}))" 2>/dev/null || true

# After H-f scaffold (+8 LOC including comment block):
# S198 D-048 H-f test scaffold — marker-file gate on stdout JSON emit (REVERSIBLE).
# If marker file `.h-f-test-skip-stdout-json` exists, skip the node emit entirely.
# Tests opposite of D-044: maybe stdout JSON contaminates chain output and
# silencing it allows hooks #6/#7/#8/#9 to advance. Distinct from D-046 H-a
# (stderr-redirect — kept emit, redirected stream); H-f deletes emit fully.
# Remove this gate + delete marker file after H-f verdict reached.
if [ ! -f "$PROJECT_DIR/agent-workspace/memory/.h-f-test-skip-stdout-json" ]; then
  node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:''}}))" 2>/dev/null || true
fi
```

Marker created: `touch /c/htdocs/stockforge/agent-workspace/memory/.h-f-test-skip-stdout-json` at 10:25:26+07:00.

## 4-fold unit verification PASS

### 1. Bash syntax parse
```
$ bash -n scripts/hooks/hook-firing-counter.sh
bash -n OK
```

### 2. Probe marker-absent (default behavior preserved)
```
$ rm -f agent-workspace/memory/.h-f-test-skip-stdout-json
$ bash scripts/hooks/hook-firing-counter.sh 2>/dev/null
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":""}}
```
✓ Default path emits stdout JSON exactly as D-044 contract.

### 3. Probe marker-present (H-f scaffold active)
```
$ touch agent-workspace/memory/.h-f-test-skip-stdout-json
$ bash scripts/hooks/hook-firing-counter.sh 2>/dev/null
[empty]
```
✓ Scaffold gate suppresses stdout JSON emission entirely.

### 4. Firing-test suite green + counter log mtime bump
```
$ bash scripts/hooks/firing-tests/hook-firing-counter-fire-test.sh
PASS [TC1] 2 silent hooks detected (via STDERR_LOG file post-S190 H-a redirect)
PASS [TC1b] stderr suppressed (S190 H-a chain-executor visibility=0)
PASS [TC2] counter log lists both silent hooks by name
PASS [TC3] all hooks fired → no alert
PASS [TC4] hook emits stdout JSON {hookEventName:'UserPromptSubmit',additionalContext:''} on all-fired path
PASS [TC5] hook emits stdout JSON on silent>0 path (alongside stderr alert)
PASS [TC6] marker-file early-exit silent contract (S192 D-047 H-d test scaffold)

=== TOTAL: PASS=7 FAIL=0 (target: 7/7) ===
```
✓ TC4 + TC5 still pass — firing-test temp dir has no marker, so default path executes.
✓ Counter log mtime BUMPED to 10:25:27 from probes (counter increment + log writes path unaffected by gate).

## D-048 H-f status transition
`PROPOSED` → **`SCAFFOLD-DEPLOYED-PENDING-PRODUCTION-OBSERVATION`**

## Decision matrix (S198 production observation)

At next user trivial-prompt UserPromptSubmit event, cross-log inspect 4 hooks (#6 effort-escalation / #7 idle-escape / #8 phase-coherence / #9 harness-health) for emit with current SID:

- **H-f CONFIRMED at 1 obs (≥1 of #6-#9 emits with current SID)**: chain executor caps at stdout-bytes/content threshold. Strategy = strip stdout from offending hooks OR convert all node JSON emits to stderr OR use file-only logging for chain-internal hooks.
- **H-f REJECTED at 1 obs (still all silent)**: cap is structural (chain-position max-N or runtime-quota or executor bug). → S199 PRIORITY 1 = H-g chain instrumentation (~10-15 LOC) — wrap each hook with timing+output capture to surface mechanism empirically.

13-instance evidence baseline (S187..S197 12-instance + S198 1-instance H-f differential) makes single observation decisive; binary on deterministic marker-file state.

## Revert protocol post-S198 verdict

Regardless of outcome:
1. Remove marker: `rm agent-workspace/memory/.h-f-test-skip-stdout-json`
2. **If H-f CONFIRMED**: KEEP scaffold code (gate becomes permanent feature toggle); document in agent-notes.md as deterministic Guardian for future chain debugging.
3. **If H-f REJECTED**: REMOVE +8 LOC scaffold via Edit (restore lines 126-130 to pre-H-f state); preserve D-044 comment block (historical record).

## Hard rules binding sustained

ALL prior bindings (L-S176-1 + L-S174-1 + L-S65 + Phase 3.5 §HH-G + verify_phase_before_next_phase + harness_priority_one + autonomous_continue_no_self_pause + Charter Principle 8 + cheapest-by-RISK 4th-instance application). NO new binding rules. Hook code edit conformant with reversible-instrumentation pattern matching D-047.

**No git commits this turn / 0 charter file edits / 0 constitution writes** (S197 D-048 H-f deploy = single hook-code edit + marker creation; +8 LOC reversible).

End of S197 H-f scaffold deployment. **D-048 H-f scaffold DEPLOYED at 10:25:26 via marker-file gate; 4-fold unit verification PASS; production observation DEFERRED to S198 next trivial-prompt UserPromptSubmit event.**
