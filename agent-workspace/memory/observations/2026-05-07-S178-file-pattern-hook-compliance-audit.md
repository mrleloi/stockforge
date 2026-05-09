---
observation_id: 2026-05-07-S178-file-pattern-hook-compliance-audit
type: audit-finding
session: S178
phase: 3.5
created_at: 2026-05-07
related_lessons: L-S176-1 (binding retro-fit scope)
related_mistakes: M-S171-1, M-S176-1 (recurrence-class — file-pattern hook authored without real-state validation)
audit_scope: scripts/hooks/*.sh (79 hooks) + scripts/hooks/firing-tests/*.sh (74 fire-tests)
verdict: 5 bugs confirmed silently no-op (1 HIGH + 4 MEDIUM); 2 already-documented graceful fallback; HH-10 orphans count under-reported by 2
---

# S178 File-Pattern Hook Compliance Audit — L-S176-1 Retro-Fit

> **Trigger**: L-S176-1 binding rule (S176 NEW HIGH) — file-pattern hooks MUST validate against real-state inventory + ship companion firing-test. S177 checkpoint NEXT ACTION PRIORITY 1.
>
> **Scope**: scan all `scripts/hooks/*.sh` for file-pattern parsers (regex on file content OR glob on directory); verify each pattern against real-state target file/directory; flag silent no-ops.

## Method

1. Enumerate all 79 hooks in `scripts/hooks/*.sh` (glob).
2. Parallel grep for file-pattern signatures:
   - `awk '/^pattern/...' file` (anchored regex on file content)
   - `grep -E '^pattern'` (anchored regex against file)
   - `find <dir> -name '<glob>'` (filename glob)
   - `for f in dir/*.ext` (shell glob)
3. For each candidate, empirically count matches against real-state target via `grep -c` or `find ... | wc -l`.
4. Cross-reference with firing-test directory (74 fire-tests) for orphan compliance (HH-10 carry-over).

## Findings — 5 BUGS CONFIRMED (Same Recurrence-Class as M-S176-1)

### Bug #1 (HIGH) — `sync-tracker-auto-update.sh:61` glob `D-*.md`

```bash
ADR_COUNT="$(find "$DECISIONS_DIR" -maxdepth 1 -name 'D-*.md' -mmin -360 2>/dev/null | wc -l ...)"
```

**Real-state empirical proof**:
```
find agent-workspace/memory/decisions/ -maxdepth 1 -name 'D-*.md' | wc -l           = 0
find agent-workspace/memory/decisions/ -maxdepth 1 -name '[0-9][0-9][0-9]-*.md' | wc -l = 38
```

**Effect**: Event 1 "new ADRs authored this session (mtime <6h)" **never fires**. Sync-tracker SCOPE confidence score never auto-updates on new ADR creation despite the hook being authorized.

**Counter-factual impact**: This Phase 3.5 series alone (D-033 through D-038, 5 ADRs in 1 day at S173-S176) would have triggered ~5 SCOPE auto-updates each at +delta. SCOPE drifted to 57.7 (sample 65) per current-execution gates without auto-correction; if auto-update had fired, score might have been higher (or surfaced calibration delta).

**Recurrence-class**: identical pattern as M-S176-1 HH-C.2 Check B (`D-*.md` glob authored from assumed naming convention). Pre-dates D-038 fix because hook was not in retro-fit scope.

**Severity**: **HIGH** — direct hit on Charter Principle 8 (Calibration over confidence) — sync-tracker is THE confidence-score substrate; broken auto-update means calibration data drifts uncaptured.

**Companion firing-test**: `sync-tracker-auto-update-fire-test.sh` EXISTS but did not catch the bug — fixture likely synthesized with assumed `D-*.md` naming, not real-state-derived per L-S176-1. Retro-fit needs fixture rewrite.

### Bug #2 (MEDIUM) — `bootstrap-summary-renderer.sh:44` awk `^**Next action**`

```bash
NEXT_ACTION="$(awk '/^## /{c++; if (c==2) exit} /^\*\*Next action\*\*/{print; exit}' "$MEMORY_DIR/current-execution.md" ...)"
```

**Real-state empirical proof**:
```
grep -c '^\*\*Next action\*\*' current-execution.md = 0
grep -nE '\*\*.*NEXT ACTION' current-execution.md   → finds **S178 NEXT ACTION priority**, **S177 NEXT ACTION priority**, etc.
```

**Effect**: `NEXT_ACTION` always empty in bootstrap output (purpose: `compact-bootstrap-context-for-reboot`). Auto-reboot handoff context loses next-action surface.

**Severity**: MEDIUM — degraded handoff context; not user-impacting today (manual `next_action` reading from checkpoint still works) but defeats the bootstrap-summary purpose during automatic reboot.

**Companion firing-test**: EXISTS — needs fixture rewrite per L-S176-1.

### Bug #3 (MEDIUM) — `bootstrap-summary-renderer.sh:56` grep `^### M-S[0-9]+...:'`

```bash
RECENT_MISTAKES="$(grep -E '^### M-S[0-9]+(-[0-9]+|[a-z]-[0-9]+):' "$MEMORY_DIR/mistake-log.md" 2>/dev/null | tail -3 || true)"
```

**Real-state empirical proof**:
```
grep -cE '^### M-S' mistake-log.md = 0
```
Real digest format uses **table rows** (`| M-S<N>-<M> | session | severity | summary |`) per RCA-2026-05-06 Layer 1 (digest-only policy; full bodies archived). The `### M-S<N>-<M>:` header format only exists in `mistake-log-archive-2026-05-06.md`, not the live file.

**Effect**: `RECENT_MISTAKES` always empty in bootstrap output.

**Severity**: MEDIUM — same as Bug #2 (degraded handoff).

**Companion firing-test**: EXISTS — needs fixture rewrite.

### Bug #4 (MEDIUM) — `tracking-retention.sh:163` grep `^### L-S`

```bash
AN_LESSONS=$(grep -c "^### L-S" "$AN_FILE" 2>/dev/null || true)
```

**Real-state empirical proof**:
```
grep -cE '^### L-S' agent-notes.md = 0
grep -cE 'L-S[0-9]+-[0-9]+' agent-notes.md = 86  (mid-line L-S<N>-<M> references)
```
Real format: `### YYYY-MM-DD (S<N>): <Title> — L-S<N>-<M>` (date-anchored title, lesson ID at end after em-dash).

**Effect**: `AN_LESSONS` always 0. Secondary "digest-only policy violated" WARN at line 171-175 **never fires** even if a future agent did paste a `### L-S<N>` body inline. LOC cap 700 (line 165-168) still works as primary defense (real LOC=593 < 700 ✓).

**Severity**: MEDIUM — primary cap intact; secondary enforcement broken silently.

**Companion firing-test**: `tracking-retention-fire-test.sh` EXISTS — likely doesn't exercise the digest-only policy violation branch with real-state header format.

### Bug #5 (MEDIUM) — `tracking-retention.sh:183` grep `^### M-S`

```bash
ML_MISTAKES=$(grep -c "^### M-S" "$ML_FILE" 2>/dev/null || true)
```

**Real-state empirical proof**: same as Bug #3 — main mistake-log.md uses table-row digest; `### M-S` headers only in archive file.

**Effect**: `ML_MISTAKES` always 0. Secondary "digest-only policy violated" WARN at line 190-193 never fires. LOC cap 200 (line 185-188) still works (real LOC=92 < 200 ✓).

**Severity**: MEDIUM — same recurrence-class as Bug #4.

**Companion firing-test**: same observation.

## Already-Documented (LOW Severity, Graceful Fallback)

### `session-start-bootstrap.sh:65` awk `^**Phase**:`

Same pattern as fixed HH-C.2 Check A. ACTIVE_PHASE silently empty. **Hook lines 67-72 implement working `^## S[0-9]+` matcher for ACTIVE_SESSION_NUM** as compensating logic. ACTIVE_PHASE passed to awk at line 88 but NOT used in match logic (lines 93-94 only check sess + track). Net effect: degraded but harmless. Comment block lines 73-84 acknowledges design.

### `session-start-bootstrap.sh:85` awk `## Active Focus Track`

current-execution.md has no `## Active Focus Track` section. Hook comments lines 73-84 explicitly document this and accept ACTIVE_TRACK="" gracefully (`track != ""` guard at awk line 94 prevents spurious match). Already accounted for per L-S56-1 typology.

## HH-10 Orphan Refinement (Cross-Reference per S177 Carry-Over)

S177 checkpoint carry-over: "HH-10 firing-test orphans=4". Real-state diff:

**Hooks without companion firing-test (6, not 4)**:
1. `diagnostic-pretooluse-stash.sh`
2. `diagnostic-subagentstop-stash.sh`
3. `redact-secrets.sh`
4. `same-commit-rule.sh`
5. `subagent-budget-classifier.sh`
6. `dispatch-jsonl-backfill.sh`

**Orphan firing-test (no parent hook)**: 1
- `etl-queue-producer-fire-test.sh` (parent hook absent — possibly retired or never shipped)

**HH-10 detection logic likely undercounts because**:
- It uses `Auto-detect:.*yes` count vs hook count delta heuristic (harness-health-self-scan.sh:103-110), not direct firing-test orphan diff.
- True orphan diff requires set-difference between `*.sh` and `firing-tests/*-fire-test.sh` — a different signal.

**None of the 5 confirmed file-pattern bugs are in orphan hooks** — all 4 affected hooks (`sync-tracker-auto-update`, `bootstrap-summary-renderer`, `tracking-retention`, plus already-documented `session-start-bootstrap`) DO have firing-tests. The bugs persisted because **firing-test fixtures were authored from same assumed-format premise**, not real-state-derived.

This validates L-S176-1's **two-part rule** (real-state validation + companion firing-test): companion firing-test alone is insufficient if its fixtures are also synthesized from assumed format. The "REAL-STATE-DERIVED fixtures" clause (per L-S176-1 (1)+(2)) is load-bearing.

## Recurrence-Class Pattern (M-S171-1 ↔ M-S176-1 ↔ S178 finding)

| Mistake | Hook | Pattern bug | Detection |
|---|---|---|---|
| M-S171-1 | various idle-loop heuristics | Idle-loop too narrow → 22-session silent advance | S172 audit |
| M-S176-1 | project-md-staleness-check.sh | Check A regex `^**Phase**:` + Check B glob `D-*.md` | S176 audit (D-038) |
| S178 finding (M-S178-1?) | sync-tracker-auto-update.sh + 4 others | Same `D-*.md` glob + 4 anchor-mismatch regexes | S178 audit (this) |

**Common root cause**: file-pattern hooks authored from assumed format (key-value `**Phase**:` style, `D-NNN-*.md` ADR convention, `### L-S` header convention) without empirical validation against real-state. Companion firing-tests exist but synthesize fixtures matching the assumed format, so they pass without exercising real-state.

**Charter Principle 8 implication**: Determinism is necessary but insufficient — deterministic logic must match real state. Verify-Before-Write applies to hook authoring same as code.

## Promote-Rule Candidate (S179+ IMPL)

**Proposed new hook**: `scripts/hooks/file-pattern-hook-pre-flight-lint.sh` (Tier-3 promotion target per Q-E3=D priority "hook FIRST, skill SECOND, charter LAST" — already-charter at L-S176-1).

**Operation**: Pre-commit OR UserPromptSubmit cadence. For each `*.sh` in `scripts/hooks/`:
1. Parse for file-pattern signatures: `awk '/^[\^\*]'`, `grep -E '^[\^]'`, `find ... -name '<glob>'`, `for f in <dir>/*.<ext>`.
2. For each pattern, attempt empirical evaluation against the cited target file/directory:
   - `awk '/^pattern/' file` → `grep -c '^pattern' file`; if 0, suggest pre-flight inspection.
   - `find <dir> -name '<glob>'` → re-run `find` with the glob; if 0 matches but directory non-empty, WARN.
3. Emit WARN with `system-reminder` if any zero-match found AND no override comment is present.

**Override mechanism**: `# pattern-lint-skip: <reason>` comment near the pattern allows bypass for legitimate cases (e.g., glob targets a generated cache directory expected to be empty initially).

**Companion firing-test (mandatory per Phase 3.5 Hard Rule #2)**: must include REAL-STATE-DERIVED fixtures per L-S176-1 (1)+(2)+(3) — TC for each of `sync-tracker-auto-update` glob, `bootstrap-summary-renderer` regex, `tracking-retention` regex.

**Alternative path**: extend `bash-hook-lint.sh` with new "Pattern E — File-Pattern Compliance" check rather than new standalone hook. Decision: standalone preferred (single-purpose intent + per L-S139-1 LOC discipline + bash-hook-lint already handles `set -e`/marker discipline focus).

## S179 Recommendations (FOCUSED_IMPL)

**PRIORITY 1**: Ship D-039 ADR — batch fix the 5 confirmed bugs (FOCUSED_IMPL ~50-80K main):
1. `sync-tracker-auto-update.sh:61` glob `D-*.md` → `\( -name '[0-9][0-9][0-9]-*.md' -o -name 'D-*.md' \)` (mirror D-038 backward-compat pattern)
2. `bootstrap-summary-renderer.sh:44` awk → match real `**S<N> NEXT ACTION priority**` OR `**SNNN NEXT ACTION` flexible
3. `bootstrap-summary-renderer.sh:56` grep → match real table-row digest (`^| M-S[0-9]+`)
4. `tracking-retention.sh:163` AN_LESSONS counter → match real `### YYYY-MM-DD (S<N>):.* — L-S<N>-<M>` OR retire as redundant (LOC cap is primary defense)
5. `tracking-retention.sh:183` ML_MISTAKES counter → similar fix or retire
6. Companion firing-tests for all 4 affected hooks: REAL-STATE-DERIVED fixtures per L-S176-1
7. Smoke runs + full firing-test suite regression

**PRIORITY 2** (pair with PRIORITY 1 OR S180+): Ship `file-pattern-hook-pre-flight-lint.sh` per L-S176-1 promote-rule candidate clause. Wire into bash-hook-lint chain or as standalone pre-commit Stop hook.

**Alternative ordering** (if PRIORITY 1 blocks on cool-down or scope concern): ship lint hook FIRST so it surfaces the 5 bugs again with REAL-STATE proof + suggested fixes; then PRIORITY 1 addresses surfaced WARNs.

## Bookkeeping

- **No new mistake entry** added to mistake-log.md this turn — S178 audit findings ARE the L-S176-1 retro-fit scope; documenting as M-S178-1 would double-count the recurrence-class. M-S171-1 + M-S176-1 already capture the pattern. If S179 IMPL ships and a NEW recurrence emerges post-fix, that warrants a new mistake.
- **No new lesson** — L-S176-1 is the binding rule; this audit is the empirical retro-fit it called for.
- **No git commits this turn** (hard rule + T8 cool-down).
- **No charter file edits** (T8 cool-down ≥2026-05-09).
- **No constitution writes** (M-S173-1 deny holds).

End of S178 audit observation.
