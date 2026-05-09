---
observation_id: 2026-05-07-S176-HH-C2-misfire-root-cause
type: focused-audit
session: S176
phase: 3.5
created_at: 2026-05-07T08:25:00+07:00
related_decisions: D-038-PROPOSED
related_mistakes: M-S176-1
related_lessons: L-S176-1
status: COMPLETE
verdict: HOOK-IS-DOUBLE-BROKEN-NO-OP-SINCE-INCEPTION
severity: HIGH
---

# HH-C.2 Staleness Watchdog Misfire — Root-Cause Audit

> S175 checkpoint S176 NEXT ACTION PRIORITY 1: investigate why `project-md-staleness-check.sh` Stop hook existed but project.md still slipped 2 days × 5 ADRs pre-S172.

## Verdict (one-line)

**Hook is a double-broken no-op since 2026-05-06 inception (commit 13e5535)** — Check A regex never matches `current-execution.md` actual format + Check B file glob never matches actual ADR filenames. Zero WARN entries across 10836 log lines = expected behavior of a hook that always silently exits with `WARN_COUNT=0`.

## Hypotheses tested

S175 checkpoint enumerated four hypotheses (H1-H4). Audit added H5 after empirical inspection of file naming convention.

| ID | Hypothesis | Status | Evidence |
|---|---|---|---|
| H1 | Stop hook silent on Windows per M-S49b-1 | **REJECTED** | `.session-hooks.log` shows other Stop hooks firing today (S175 close 08:19:21+): `SessionEnd`, `session-export-raw`, `working-memory-budget-audit`. If Stop chain were Windows-silent, NO Stop hook would log. |
| H2 | Hour-bucket marker collision masked legitimate fires | **RESOLVED-POST-L-S108-1** | Current marker `agent-workspace/memory/.project-md-staleness-fired-20260507-08` shows hour-bucket format working as designed. Cleanup-stale-markers loop (lines 37-43) intact. L-S108-1 fix shipped at S109 prevented per-session-lockout. |
| H3 | Hook regex pattern too narrow (Check A) | **CONFIRMED** | Hook line 60-61: `grep -m1 -E '^\*\*Phase\*\*:[[:space:]]*[0-9]'` against `current-execution.md` returns NOTHING. Actual format uses section headers `## SNNN — Phase X.Y — ...` (e.g., `## S175 — Phase 3.5 — FOCUSED_IMPL-DONE: ...`). NO `**Phase**: N` line exists anywhere in the file. → `ACTIVE_PHASE=""` → entire Check A block (lines 63-97) silently skipped on every invocation. |
| H4 | project-md-staleness-check thresholds too lax | **IRRELEVANT** | Threshold `>2.0h` (line 115) is sane but never reached because Check B exits early via H5 (no NEWEST_ADR detected). |
| **H5 NEW** | **Check B file glob `D-*.md` doesn't match actual ADR naming `NNN-*.md`** | **CONFIRMED** | Hook line 104: `find "$DECISIONS_DIR" -maxdepth 1 -name 'D-*.md' -type f`. Empirical test returns EMPTY because actual filenames are `037-S175-M-S171-1-prevention-hooks.md`, NOT `D-037-...md`. The `D-NNN` IS the ADR ID inside file frontmatter + content + project.md table, but file PREFIX is bare `NNN-`. Confirmed by `ls agent-workspace/memory/decisions/` — all 38 files (001..037 + _template.md) start with digits, none with literal `D-`. → `NEWEST_ADR_TS=""` → entire Check B block (lines 109-122) silently skipped on every invocation. |

## Empirical evidence

### Test 1 — Stop hook chain DOES fire on Windows (rejects H1)

```
$ tail -30 agent-workspace/memory/.session-hooks.log
[2026-05-07T08:19:21+07:00] SessionEnd session=
[2026-05-07T08:19:22+07:00] session-export-raw: wrote .../2026-05-07-session-175.md
[2026-05-07T08:19:23+07:00] SessionStart session= cwd=/c/htdocs/stockforge
... (working-memory-budget-audit, sync-grilling-trigger, learning-queue-sweeper, etc.)
```

Stop chain ran at 08:19:21 (S175 close); SessionStart chain ran at 08:19:23. Both fire. project-md-staleness-check is in Stop chain (`.claude/settings.json` line 383) → it ran but produced WARN_COUNT=0 → no log line.

### Test 2 — Check A regex empirical (confirms H3)

```bash
$ grep -m1 -E '^\*\*Phase\*\*:' agent-workspace/memory/current-execution.md
(no output; exit 1)

$ grep -m1 -oE '## S[0-9]+ — Phase [0-9.]+' agent-workspace/memory/current-execution.md
## S175 — Phase 3.5
```

The hook's regex finds nothing; the alternate regex (matching actual format) extracts `Phase 3.5` correctly.

### Test 3 — Check B glob empirical (confirms H5)

```bash
$ find agent-workspace/memory/decisions -maxdepth 1 -name 'D-*.md' -type f -printf '%T@\t%f\n' | sort -rn | head -1
(empty; exit 1 from find)

$ ls agent-workspace/memory/decisions/ | head -10
_template.md
001-orch-vs-cc-native.md
002-phase-0-harness-bootstrap-design.md
...
037-S175-M-S171-1-prevention-hooks.md

$ find agent-workspace/memory/decisions -maxdepth 1 -regextype posix-extended -regex '.*/[0-9]+-.*\.md' -type f -printf '%T@\t%f\n' | sort -rn | head -1
1778116369.3867873000	037-S175-M-S171-1-prevention-hooks.md
```

The hook's `D-*.md` glob returns empty; corrected `[0-9]+-.*\.md` regex finds the newest ADR.

### Test 4 — Zero WARN entries across hook lifetime (corroborates double-broken)

```bash
$ wc -l agent-workspace/memory/.session-hooks.log
10836

$ grep -c "project-md-staleness-check" agent-workspace/memory/.session-hooks.log
5  # all 5 are L-S108-1 lint-scan metadata, not actual WARN entries

$ grep "project-md-staleness-check.*warns=" agent-workspace/memory/.session-hooks.log
(no output)
```

Hook only writes to log if `WARN_COUNT > 0` (line 125-127). Zero WARN entries across the full log = hook never produced WARN_COUNT > 0. This is consistent with both Check A and Check B silently skipping on every invocation.

### Test 5 — Counter-factual: would corrected hook have fired pre-S172?

Pre-S172 state (per S172 audit observation):
- project.md last update S48d 2026-05-05 (mtime ~2 days stale)
- D-029, D-030, D-031, D-032 all written between 2026-05-05 and 2026-05-06 (newer than project.md)

With CORRECTED Check B glob `[0-9]+-.*\.md`:
- `NEWEST_ADR_TS` would be D-032's mtime ≈ 2026-05-06
- `PROJECT_MTIME` would be 2026-05-05 (S48d update)
- `DELTA_HOURS` ≈ 24-30h
- `OVER` = 1 (>2.0h)
- WARN: "project.md mtime ~28h older than newest ADR (032-S65-...)" → WARN_COUNT=1 → log entry

**With corrected hook, the S148-S171 22-session × 2-day slip would have surfaced a Stop-hook WARN every session-end after the first ADR landed without project.md update.**

## Root cause analysis

### File-pattern mismatch class

Two distinct file-pattern bugs:
- **Check A**: regex written for a `**Phase**: N` text format that never existed in `current-execution.md`. The author appears to have assumed a key-value frontmatter style; actual file uses prose section headers.
- **Check B**: glob written for `D-*.md` filename prefix; actual convention is `NNN-*.md` with `D-NNN` as the ADR identifier inside file content (`id:` frontmatter + project.md table). The author conflated ADR identifier (D-NNN) with filename prefix.

Both bugs share a common root: **hook authored without empirical-firing test against real state**. The Phase 3.5 Hard Rule #2 (every hook ships with companion firing-test) was not in force when this hook was authored at 13e5535 (2026-05-06 09:22; pre-Phase 3.5 entry at S50 2026-05-05 — actually concurrent, but Hard Rule #2 codified later in plan 010-S50).

### Charter-Principle-8 violation latent

Charter Principle 8 (Calibration over confidence) demands deterministic over LLM-Guardian. The hook was designed deterministic — but determinism alone is insufficient if the deterministic logic doesn't match real state. **Verify-Before-Write Protocol** (CLAUDE.md hard rule) for hook authoring should include: (a) `ls` the directory the hook globs against; (b) `grep` the file the hook regex parses; (c) tail-test against known-good + known-bad state.

### Recurrence-class lesson

This is the SAME pattern as M-S171-1 (idle-loop heuristic too narrow). Both hooks shipped with regex/glob patterns that didn't match actual file inventory. **Lesson: file-pattern hooks MUST validate pattern against real-state inventory before shipping; companion firing-test surfaces this at authoring time.**

## Decision matrix for D-038

| Option | Description | Pros | Cons |
|---|---|---|---|
| A — FIX | Patch Check A regex to match `## SNNN — Phase X.Y`; patch Check B glob to `[0-9]+-.*\.md`; add companion firing-test; keep Stop cadence | Closes the bug verbatim; minimal scope; preserves existing wiring | Stop-only cadence misses real-time drift (which is why S175 phase-status-coherence shipped at UserPromptSubmit cadence) |
| B — MIGRATE | Move project-md-staleness-check.sh to UserPromptSubmit chain alongside phase-status-coherence; merge Check A into phase-status-coherence; keep Check B (mtime drift) at Stop only | Per-prompt phase coherence; Stop-cadence Check B catches end-session drift | More files churn; Stop hook still produces ADR-staleness warns |
| C — RETIRE | phase-status-coherence (S175) covers Check A scope; session-end-checklist-linter overlaps Check B scope. Retire HH-C.2 entirely. | Cleanest; reduces hook chain | Loses unique Check B (project.md mtime vs newest ADR) — no other hook does this exact comparison |
| D — HYBRID | Apply Option A fixes + add UserPromptSubmit cadence for Check A only (covered by phase-status-coherence anyway); keep Stop cadence for Check B (project.md mtime vs newest ADR) | Defense-in-depth; closes bug + matches Phase 3.5 §HH-G empirical-firing exemplar | Modest hook chain growth; Check A duplication with phase-status-coherence |
| E — RETIRE-CHECK-A-FIX-CHECK-B | Drop Check A from project-md-staleness-check.sh entirely (phase-status-coherence handles it at UserPromptSubmit cadence); fix Check B glob; rename hook to `project-md-adr-staleness.sh`; add companion firing-test | Single-purpose hook = clearer intent; no Check A duplication; companion firing-test satisfies Phase 3.5 Hard Rule #2 | Renames file (mtime + git history split); minor settings.json edit |

**Recommended (S176-AUDIT-PROPOSAL-ONLY)**: **E** — RETIRE-CHECK-A-FIX-CHECK-B + rename. Phase 3.5 §HH-G empirical-firing exemplar + harness_priority_one + Charter Principle 8 (deterministic + per-purpose hook). E delivers a single-purpose, empirically-verified ADR-staleness watchdog at Stop cadence that complements UserPromptSubmit phase-status-coherence; companion firing-test surfaces both bugs deliberately as RED-state assertions. Implementation deferred to S177 FOCUSED_IMPL.

**Defer-or-retire decision**: NOT retire entirely (Option C). Check B (project.md mtime vs newest ADR) is a unique signal — session-end-checklist-linter checks ritual completeness but not mtime-drift; phase-status-coherence checks per-prompt mismatch but not ADR-vs-project.md staleness. Charter-Principle-8 deterministic + defense-in-depth → keep + fix.

## New mistakes + lessons surfaced

- **M-S176-1 NEW (HIGH)**: project-md-staleness-check.sh shipped 2026-05-06 13e5535 as a double-broken no-op (Check A regex narrow + Check B glob mismatch). Silent failure for 22+ sessions; would NOT have caught S148-S171 22-session × 2-day project.md slip even if Stop chain were functioning perfectly. Same recurrence-class as M-S171-1 (file-pattern hook authored without empirical-firing test).
- **L-S176-1 NEW (HIGH)**: When authoring file-pattern-matching hooks, MUST validate pattern against real-state inventory (`ls` + `grep`) AND ship companion firing-test before declaring complete. Phase 3.5 Hard Rule #2 retroactively applies — pre-Phase-3.5 hooks (HH-C.2 was authored 2026-05-06 same day Phase 3.5 entered S50) need audit pass for Hard Rule #2 compliance.

## Counter-factual cost

If hook had fired correctly from 2026-05-06:
- D-029 (S48d 2026-05-05) lands → project.md updated S48d → no WARN
- D-030 (S48f 2026-05-05) lands → project.md NOT immediately updated → WARN at next Stop
- D-031 (S48h 2026-05-05) lands → WARN compounds
- D-032 (S65 2026-05-06) lands → 2-day cumulative drift → WARN with delta_hours ≈ 24+
- 22-session silent advance pre-S172 ⇒ 22 missed reconcile opportunities
- S172 reconcile cost ~32K main; if caught at first WARN → ~5K main per session × 22 = 110K saved (or single 5K reconcile turn at first WARN)

Same order-of-magnitude wasted main as M-S171-1 (~100K). Combined recurrence-class cost ≈ 200K main wasted by file-pattern hook bugs.

## Forward audit deliverable: scan ALL existing hooks for file-pattern compliance

S177+ should run a one-shot audit:
- For each hook in `scripts/hooks/*.sh`, identify file-glob and regex parsers against real state
- Test each pattern against actual file inventory
- Flag hooks without companion firing-test (Phase 3.5 Hard Rule #2 retro-fit)

Candidate retro-fit list (preliminary, from `scripts/hooks/firing-tests/` cross-check at S174):
- HH-2 USERPROMPT-NOT-FIRING (open at S173)
- HH-6 dispatch-pending JSONL stale=6 (open)
- HH-10 firing-test orphans=4 (open)
- HH-C.2 project-md-staleness-check (THIS investigation)

S178 FOCUSED_AUDIT could batch the file-pattern compliance scan.

## End of audit

Verdict: **CONFIRMED double-broken no-op**. D-038 PROPOSED with Option E recommendation. Implementation deferred to S177 FOCUSED_IMPL.
