---
observation_id: 2026-05-09-S192-h-d-test-scaffold-deployed
type: in-flight-test-scaffold
session: S192
created_at: 2026-05-09T09:45+07:00
related_decision: D-047 (S192 hook #5 marker-file early-exit scaffold for H-d test)
related_hypothesis: H-d (chain element-count limit triggers truncation at #5/#6 boundary)
status: SCAFFOLD-DEPLOYED-PENDING-PRODUCTION-OBSERVATION
predecessor_observations:
  - S187 D-043 stdout JSON fix (chain advanced #1→#5)
  - S189 D-044 H-c REJECTED at 1st production observation
  - S191 D-046 H-a REJECTED-FORMAL at 3/3 production observations
  - S191 H-e REJECTED-BY-INSPECTION (hook #5 always exits 0)
---

# S192 — H-d test scaffold deployed (chain element-count limit hypothesis)

## Hypothesis

**H-d**: Claude Code Windows UserPromptSubmit chain executor caps at N successful-emit elements regardless of stderr/stdout state. If hook #5 (hook-firing-counter) currently occupies the 5th emit slot and cap is 5, hooks #6-#9 are truncated by slot exhaustion not by stderr/stdout/exit-code mechanism.

Sub-variants:
- **H-d.1 (completion-count cap)**: chain caps at N elements that *complete* (exit), regardless of emission. Test would require removing hook #5 from settings.json entirely.
- **H-d.2 (emission-count cap)**: chain caps at N elements that *emit anything* (file write, stdout, stderr). Test = silently no-op hook #5 so it completes but emits nothing.

This S192 turn tests H-d.2 (cheaper, less risky). H-d.1 escalation deferred to S193 if H-d.2 rejects.

## Test scaffold deployed

**Code change** (`scripts/hooks/hook-firing-counter.sh` +9 LOC after STDERR_LOG declaration line 41):
```bash
# S192 D-047 H-d test scaffold — marker-file early-exit (REVERSIBLE INSTRUMENTATION)
# If marker file exists, hook silently no-ops with no emission anywhere (no
# counter log, no STDERR_LOG, no stdout JSON). Tests if Claude Code Windows
# UserPromptSubmit chain executor caps at N successful-emit elements (H-d
# hypothesis); freeing slot 5 by silencing hook #5 should advance hooks #6-#9
# at next trivial-prompt observation if H-d is correct. Remove this block +
# delete marker file after S192 H-d verdict reached.
[ -f "$PROJECT_DIR/agent-workspace/memory/.h-d-test-skip-hook5" ] && exit 0
```

**Marker file**: `agent-workspace/memory/.h-d-test-skip-hook5` (empty file, mtime 09:45+07:00).

**Companion firing-test extended** (`scripts/hooks/firing-tests/hook-firing-counter-fire-test.sh` +30 LOC NEW TC6):
- TC6 stages active-hook-only settings + creates marker file → asserts: STDOUT empty, STDERR empty, no counter log written, no STDERR_LOG written → silent contract
- Target updated 6/6 → 7/7

## Unit-level verification

- `bash -n scripts/hooks/hook-firing-counter.sh` → parse OK
- `bash -n scripts/hooks/firing-tests/hook-firing-counter-fire-test.sh` → parse OK
- Individual firing-test → 7/7 PASS (TC1-TC5 unchanged + TC6 NEW PASS)
- Full firing-test suite → **82/82 PASS elapsed 236s** zero regression vs S190 baseline (was 82/82 220s; +16s ~7% acceptable for +1 TC overhead)
- Production smoke check (CLAUDE_PROJECT_DIR=/c/htdocs/stockforge with marker file present): hook exits 0 with no stdout, no stderr, no STDERR_LOG mtime bump → **scaffold functional in production**

## Verification protocol (S193 entry — H-d verdict)

**Trigger**: next trivial-prompt UserPromptSubmit event (one or more user prompts).

**Cross-log inspection at trigger timestamp**:

| # | Hook | Log file | Expected if H-d.2 CONFIRMED | Expected if H-d.2 REJECTED |
|---|---|---|---|---|
| 1 | userprompt-invariants-injector | `.session-hooks.log` | EMIT (unchanged) | EMIT (unchanged) |
| 4 | in-flight-subagent-watcher | `.in-flight-subagent-watcher.log` | EMIT (unchanged) | EMIT (unchanged) |
| 5 | hook-firing-counter | `.hook-firing-counter.log` + STDERR_LOG | **NO MTIME UPDATE** (marker triggers silent no-op) | **NO MTIME UPDATE** |
| 6 | effort-escalation-detector | `.effort-escalation.log` | **CREATED OR APPEND** | MISSING |
| 7 | idle-escape-detector | `.idle-escape.log` | **CREATED OR APPEND** | MISSING |
| 8 | phase-status-coherence | `.phase-coherence.log` | **CREATED OR APPEND** | MISSING |
| 9 | harness-health-self-scan | `.harness-health.log` | **APPEND fresh entry with current SID** | STALE 09:14:37 firing-test SID |

**Decision matrix**:
- **H-d.2 CONFIRMED** (≥1 of #6-#9 emits): chain executor caps at emit-count; doctrine implication = no more than 4 emitting hooks ahead of #6/#7/#8/#9 in chain order. **S193 strategy**: hook consolidation OR no-op-buffer hook insertion strategy. Production scaffold REMAINS as marker-toggle for further investigation.
- **H-d.2 REJECTED** (still all silent): emit-count is not the cap. **S193 next test**: H-d.1 (completion-count cap) via settings.json hook #5 removal — destructive but only 1-line edit + revert; 1 observation cycle. If H-d.1 also rejects → escalate to H-f (stdin/JSON shape strictness).

**Restoration**: after verdict, `rm agent-workspace/memory/.h-d-test-skip-hook5` to restore production hook #5 emission. Revert hook-firing-counter.sh +9 LOC scaffold block (or PRESERVE with marker absent — cost is ~9 LOC dormant code; leave for future H-d retests if needed; cleanup at S194+ if no further use).

## Risk assessment

- **During test window (~5-50 min depending on user prompt cadence)**: hook #5 silent → silent-hook detection blackout (20/71 hooks ≥7d silent are not surfaced). Acceptable: detection runs daily Stop hook anyway; ~5-50 min gap is minor.
- **D-046 STDERR_LOG file**: stops receiving new entries during test window (file static at 09:34:22 obs#3 entry). On scaffold revert + marker file removal, emission resumes.
- **Counter log file**: similarly static during test window; resumes on revert.
- **Reversibility**: marker file deletion alone is sufficient to restore hook behavior; scaffold code is idempotent (no marker file → behavior unchanged from S190+S191 D-046 baseline). Highly reversible.

## AP-23 cheapest-by-RISK 3rd-instance application

Cheapest-by-RISK doctrine progression:
- **S188 D-044 (1st instance refinement)**: chose Option B (additive stdout JSON) over Option A (destructive H-a stderr suppression) per cheapest-test interpretation refined to RISK-minimal not LOC-minimal
- **S190 D-046 (2nd instance application)**: chose Option B (non-destructive stderr-redirect-to-file) over Option A (destructive comment-out) per same RISK-minimal interpretation
- **S192 D-047 (3rd instance application)**: chose marker-file scaffold (reversible instrumentation) over destructive script-edit-and-revert per same RISK-minimal interpretation

**3-instance count met → AP-23 promote-or-retire rule MANDATES** promotion of cheapest-by-RISK doctrine to formal lesson at S193+ promote-rule cycle. Promotion candidate L-S189+-1 RIPE-AND-MANDATE.

## Files this turn (S192-specific)

- EDITED `scripts/hooks/hook-firing-counter.sh` (+9 LOC marker-file early-exit scaffold + comment block)
- EDITED `scripts/hooks/firing-tests/hook-firing-counter-fire-test.sh` (+30 LOC NEW TC6 marker-file silent contract; target 6/6 → 7/7)
- NEW `agent-workspace/memory/.h-d-test-skip-hook5` (empty marker file)
- NEW `agent-workspace/memory/observations/2026-05-09-S192-h-d-test-scaffold-deployed.md` (this file)

## Quality gates S192

- M-S147-1 prevention check at entry ✓
- verify_phase_before_next_phase BINDING — H-a + H-e both empirically REJECTED before H-d test ✓
- L-S176-1 BINDING — TC6 fixture file-based, real-state-derived from production hook + scaffold contract ✓
- L-S174-1 BINDING — firing-test mktemp -d sandbox + trap cleanup preserved ✓
- Phase 3.5 §HH-G — behavior addition (marker-file path) ships with extended firing-test (TC6) before deployment ✓
- Phase 3.5 Hard Rule #2 — every hook ships with companion firing-test ✓
- UP-05 autonomous-mode skill-tool gating ✓ (Bash + Edit + Write only)
- 0 git commits ✓
- 0 charter file edits ✓
- 0 constitution writes ✓ (M-S173-1 deny holds)
- harness_priority_one APPLIED ✓
- autonomous_continue_no_self_pause APPLIED ✓
- Charter Principle 8 cheapest-by-RISK 3rd-instance application ✓
- AP-23 — promotion candidate L-S189+-1 RIPE-AND-MANDATE; promote-rule cycle SCHEDULED for S193+

## No mistakes this session

S192 = clean FOCUSED_IMPL execution following S191 close PRIORITY 1 verbatim with H-d cheapest-by-RISK test scaffold. No refinement-of-rule events.
