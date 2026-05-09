---
observation_id: 2026-05-07-S186-userprompt-stdout-fix-validation
type: empirical-impl-verification
session: S186 (creation) + S187 (production-verification append)
phase: 3.5
predecessor_observation: 2026-05-07-S185-userprompt-chain-truncation-rc.md
created_at: 2026-05-07T11:30:00+07:00
last_updated: 2026-05-07T11:55:00+07:00 (S187 PARTIAL-CONFIRMED append)
status: IMPL-SHIPPED-PARTIAL-CONFIRMED-S187
related_adr: D-043-S186-userprompt-stdout-fix
---

# S186 — Option D empirical-test fix shipped — UserPromptSubmit chain truncation hypothesis impl-verified

## Headline

S186 FOCUSED_IMPL applied D-043 Option D fix — modified `userprompt-invariants-injector.sh`
trivial SKIP path to emit minimal `hookSpecificOutput` JSON
(`additionalContext: ""`) before `exit 0`. Companion firing-test refactored
to assert empty-string contract via file-based JSON parse (TC1-TC3 rewritten;
TC7 NEW). Individual test 7/7 PASS; full firing-test suite 82/82 PASS zero
regression. Chain-internal correctness empirically verified at unit level;
production chain-advance verification (whether `stale-prompt-detector` emits
on subsequent trivial-prompt UserPromptSubmit event) deferred to next real
`/clear` event in S187+.

## What was changed

### Hook (production code)

`scripts/hooks/userprompt-invariants-injector.sh` — trivial-prompt SKIP path
augmented with minimal stdout JSON emission:

```bash
# Before S186 (5 LOC; chain truncates here on Windows per S185 hypothesis):
if [ -n "$PROMPT_HEAD" ] && printf '%s' "$PROMPT_HEAD" | grep -qE "$TRIVIAL_REGEX"; then
  echo "[$(date -Iseconds)] UserPromptSubmit-injector: SKIP (trivial prompt detected)" >> "$HOOK_LOG"
  exit 0
fi

# After S186 (10 LOC; emits empty-additionalContext JSON to keep chain alive):
if [ -n "$PROMPT_HEAD" ] && printf '%s' "$PROMPT_HEAD" | grep -qE "$TRIVIAL_REGEX"; then
  echo "[$(date -Iseconds)] UserPromptSubmit-injector: SKIP (trivial prompt detected)" >> "$HOOK_LOG"
  # S186 D-043 — emit minimal hookSpecificOutput JSON on SKIP path so Windows
  # UserPromptSubmit hook chain advances past this hook (S185 hypothesis: stdout
  # JSON emission is required for chain continuation on Claude Code Windows).
  node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:''}}))" 2>/dev/null || true
  exit 0
fi
```

Net production code change: +5 LOC.

### Firing-test (verification code)

`scripts/hooks/firing-tests/userprompt-invariants-injector-fire-test.sh` —
TC1-TC3 rewritten + TC7 NEW + helper `assert_skip_path_json` introduced:

| TC | Pre-S186 assertion | Post-S186 assertion |
|----|--------------------|---------------------|
| TC1 (`continue`) | OUT NOT contain "additionalContext" | OUT is JSON; `hookSpecificOutput.additionalContext === ""`; OUT NOT contain "STOCKFORGE INVARIANTS REMINDER" |
| TC2 (`ok`) | (same as TC1) | (same as TC1) |
| TC3 (`tiếp`) | (same as TC1) | (same as TC1) |
| TC4 (non-trivial) | OUT contains "additionalContext" + "I-S1" | (unchanged) |
| TC5 (empty) | rc=0 | (unchanged) |
| TC6 (long non-trivial) | OUT contains "additionalContext" + log "prompt_len=N" | (unchanged) |
| TC7 (S186 contract; NEW) | — | OUT exact JSON shape `{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:""}}` with no extra keys |

Helper uses file-based fixture (`printf '%s' "$out" > "$out_file"`; `node -e
"const s=fs.readFileSync(process.argv[1],'utf8');"`) instead of inline node
`-e "let s='$(...sed escape...)'"` to avoid shell-escape pitfalls. Refinement
of L-S176-1 fixture-real-state doctrine (NOT 2nd-instance promotion per
AP-23 1st-instance rule; refinement-of-rule observation).

Net firing-test code change: +130 LOC (147 → 277).

## Verification stack (4-fold empirical evidence S186)

### (1) JSON output shape verification (smoke-test)

```bash
$ printf '{"prompt":"continue"}' | bash scripts/hooks/userprompt-invariants-injector.sh
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":""}}
```

Verified: hook emits exactly the contract JSON on trivial path.

### (2) Log entry preserved

`.session-hooks.log` (test sandbox) post-fire:

```
[2026-05-07T11:25:00+07:00] UserPromptSubmit-injector: SKIP (trivial prompt detected)
```

Verified: SKIP-path log entry unchanged (existing observability preserved).

### (3) Companion firing-test 7/7 PASS

```
PASS TC1: trivial 'continue' → minimal JSON (additionalContext="") + SKIP log
PASS TC2: trivial 'ok' → minimal JSON + SKIP log
PASS TC3: Vietnamese 'tiếp' → minimal JSON + SKIP log
PASS TC4: non-trivial prompt → JSON + invariants reminder
PASS TC5: empty prompt → graceful (no error)
PASS TC6: long non-trivial prompt → injection + length logged
PASS TC7: S186 chain-continuation contract — exact JSON shape on SKIP path

=== ALL FIRING-TESTS PASSED (7/7) ===
```

Verified: externally-observable hook behavior matches D-043 contract.

### (4) Full firing-test suite 82/82 PASS

```
=== firing-test suite: 82/82 PASS (elapsed 223s) ===
```

Same count as S184 baseline (82/82). Zero regression — no other hook's
firing-test broke from this change.

## Test fixture refinement caught + fixed within TDD loop

First-run failure on TC1: shell-escape error in inline node assertion:

```
sed: -e expression #1, char 1: unknown command: `"'
FAIL TC1: SKIP-path JSON expected additionalContext="" (empty); got marker=__PARSE_ERR__
  raw output: {"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":""}}
```

Critical detail: the raw output line confirms the production hook IS emitting
the correct JSON. The failure was in the test harness — `node -e "let
s='$(printf ... | sed \"s/'/\\\\\\\\'/g\")';"` was mangling escapes for the
embedded single-quote substitution.

Fix: replace inline shell-escaped node arg with file-based fixture (write OUT
to temp file; pass file path as argv; `node` reads via
`fs.readFileSync(process.argv[1])`). Rerun: 7/7 PASS.

This is a refinement of L-S176-1 fixture-real-state doctrine: not just
"fixtures match real state" but also "fixtures DELIVERY mechanism must
preserve byte-exactness through shell layers." Captured here as observation,
NOT promoted to 2nd-instance lesson per AP-23 1st-instance rule (same class
as L-S181-1 fixture-vs-regex-quantifier from S181 D-041 — both are
refinement-of-L-S176-1 instances; first refinement was quantifier bounds,
this is delivery-mechanism, both deferred from formal lesson promotion until
3rd instance surfaces).

## Hypothesis state

**Pre-S186**: HYPOTHESIS IDENTIFIED (S185) — UserPromptSubmit hook chain on
Windows requires each hook to emit `hookSpecificOutput` JSON to stdout for
chain to advance. Confirmed via 5-fold S185 evidence catalog (chain emission
counts + path bifurcation + source code inspection + manual chain run +
real-time confirmation). Status: CONFIRMED-PENDING-IMPL-VERIFICATION.

**Post-S186**: IMPL SHIPPED + UNIT-VERIFIED. Production-cadence
verification deferred to S187+ via passive observation:

- Trigger: next `/clear` event followed by trivial prompt (continue/ok/yes/...)
- Expected: `.session-hooks.log` emits `[<timestamp>] UserPromptSubmit-injector:
  SKIP (trivial prompt detected)` AS BEFORE, AND `[<timestamp>]
  stale-prompt-detector: clean (no stale refs)` line appears (was missing
  S185 → 0/128 trivial fires).
- If observed → hypothesis CONFIRMED → queue Option A full retro-fit S187+
  (modify all 9 UserPromptSubmit chain hooks + verify against SessionStart
  chain hooks).
- If 3+ consecutive trivial-prompt events show no `stale-prompt-detector`
  emission → hypothesis REJECTED → escalate to alternative root cause
  investigation (chain element-count limit, JSON-shape strictness, exit-code
  semantic dependency).

## Counter-factual recovery (post-confirmation)

If hypothesis CONFIRMED in S187+:

| Hook | Pre-S186 emission rate (UserPromptSubmit) | Post-S186 expected | Post-S187+ Option A expected |
|------|-------------------------------------------|---------------------|--------------------------------|
| #1 userprompt-invariants-injector | 157/157 = 100% (always-logs both paths) | (unchanged) | (unchanged) |
| #2 stale-prompt-detector | 29/157 = 18.5% (INJECTED-path only) | ~100% (chain advances on SKIP path; hook fires + logs "clean") | ~100% |
| #3 correction-rate-tracker | 6/157 = 3.8% (conditional emit on match) | ~3.8% on match path (chain reaches; emit conditional on `mistake/error/sai/fix` keywords) | ~3.8% on match path |
| #4 in-flight-subagent-watcher | 0/157 | 0/157 (no stdout emit on no-in-flight; chain truncates here pending #4 fix) | ~100% (post Option A) |
| #5 hook-firing-counter | 0/157 | 0/157 | ~100% (post Option A) |
| #6 effort-escalation-detector | 0/157 | 0/157 | ~100% (post Option A) |
| #7 idle-escape-detector | 0/157 (UserPromptSubmit ctx) | 0/157 | ~100% (post Option A) |
| #8 phase-status-coherence | 0/157 (UserPromptSubmit ctx) | 0/157 | ~100% (post Option A) |
| #9 harness-health-self-scan | 0/157 (UserPromptSubmit ctx) | 0/157 | ~100% (post Option A) |

S186 closes 1 of 9 UserPromptSubmit-chain emission gaps (hook #2 alone). The
remaining 6 gaps (hooks #4-#9) require Option A retro-fit per-hook in S187+.
Hook #3 already at intended emission rate (its conditional-emit pattern is
correct; the issue is upstream gating from hook #2 truncation).

## Hard rules binding (S186 IMPL)

- **L-S176-1 BINDING** — fixtures REAL-STATE-DERIVED (TC1-TC3 fixtures
  literally are the production-emission contract; TC7 fixture is the exact
  expected JSON shape including key-count). Refinement-of-rule observation
  on fixture-delivery-mechanism captured in this observation, NOT promoted.
- **L-S174-1 RC-pattern** — firing-test mktemp -d sandbox + trap cleanup
  (preserved unchanged from S61 baseline).
- **Phase 3.5 §HH-G empirical-firing exemplar** — hook ships with companion
  firing-test before activation; this S186 is a behavior modification of an
  existing wired hook, so test update is mandatory not new-hook authoring.
- **Phase 3.5 Hard Rule #2** — every hook ships with companion firing-test
  (preserved; firing-test exists, updated per behavior change).
- **harness_priority_one** — closing harness signal coverage gap (1/9
  recovered; 8/9 deferred S187+) takes priority over product work.
- **autonomous_continue_no_self_pause** — picked + executed S185 PRIORITY 1
  verbatim without self-pause; FOCUSED_IMPL ~30-40K main turn (within
  envelope ~30-50K).
- **verify_phase_before_next_phase** — empirical IMPL not silent advance;
  4-fold verification stack (smoke-test JSON shape + log entry + 7/7
  individual + 82/82 full suite).

## Hard locks honored (S186 IMPL)

- **NO git commits** (CLAUDE.md hard rule + autonomous_no-commit policy)
- **NO charter file edits** (T8 cool-down active until 2026-05-09)
- **NO constitution writes** (M-S173-1 deny holds)
- **NO new firing-tests authored** (existing firing-test refactored per
  behavior change; not authoring NEW test files this session)
- **NO new hooks authored** (modified existing hook; not authoring NEW hook
  files this session)

## Files this turn (S186-specific)

NEW:
- `agent-workspace/memory/decisions/043-S186-userprompt-stdout-fix.md` (D-043 full 12-field, ~280 LOC)
- `agent-workspace/memory/observations/2026-05-07-S186-userprompt-stdout-fix-validation.md` (this file)
- `agent-workspace/memory/sessions/2026-05-07-session-186.md`

EDITED:
- `scripts/hooks/userprompt-invariants-injector.sh` (+5 LOC trivial-path JSON emission)
- `scripts/hooks/firing-tests/userprompt-invariants-injector-fire-test.sh` (+130 LOC; TC1-TC3 assertion rewrite + TC7 NEW + assert_skip_path_json helper + file-based fixture pattern)
- `agent-workspace/memory/project.md` (Updated header + Active TODO S186 PRIORITY 1 marked done + S187 PRIORITY 1 Option A retro-fit conditional queued + Recent ADRs prepend D-043)
- `agent-workspace/memory/current-execution.md` (S186 row prepend)
- `agent-workspace/memory/checkpoints/latest.md` (S186→S187 handoff replacing S185→S186)

## Next session recommendations (S187 NEXT ACTION priority)

1. **PRIORITY 1**: Production verification of D-043 — passive observation at
   next real `/clear` event of `stale-prompt-detector: clean (no stale refs)`
   line in `.session-hooks.log` for trivial prompt fires. If observed → hypothesis
   CONFIRMED → trigger PRIORITY 1B; if absent for 3+ consecutive trivial-prompt
   events → escalate to alternative root cause investigation. ~5K main passive
   read; ~10-20K main if hypothesis CONFIRMED + ADR update.

2. **PRIORITY 1B (CONFIRMED-only)**: Option A full retro-fit. Modify
   remaining 8 UserPromptSubmit chain hooks (in-flight-subagent-watcher /
   hook-firing-counter / effort-escalation-detector / idle-escape-detector /
   phase-status-coherence / harness-health-self-scan + verify
   stale-prompt-detector + correction-rate-tracker patterns) to emit minimal
   `hookSpecificOutput` JSON on every code path. ~50 LOC × 8 = ~400 LOC
   modification + 8 firing-test updates. MULTI-TASK IMPL ~150-250K main.

3. **PRIORITY 2** (L-S80-2 retro-fit per S185 close): 4 production hooks
   violate `VAR=$(grep -c ... || echo N)` capture trap pattern —
   attach-portability-smoke + harness-health-self-scan + idle-escape-detector
   + phase-status-coherence. Replace with `if grep -qE ...; then VAR=1; else
   VAR=0; fi` clean integer pattern. ~10 LOC × 4 = ~40 LOC FOCUSED_IMPL.

4. **PRIORITY 3**: Production verification of D-042 SessionStart fix —
   observe `harness-health-self-scan: state=...` emission at next real
   `/clear` event (passive observation; no agent action needed unless absent
   ≥3 consecutive `/clear` events post-S184).

5. **PRIORITY 4** (HH-2 remediation if noise persists): Option A
   skip-on-synthesized-SID; defer if no recurrence since S182 verify.

6. **PRIORITY 5** (M-S173-1 resolution): out-of-band agent action.

7. **PRIORITY 6** (T8 charter edit): ≥2026-05-09 post-cool-down — D-034 § 5.

8. **PRIORITY 7** (exit-Phase-3.5 prep): Phase 3 Track I + Tracks J+K PAUSED
   awaiting Phase 3.5 T8 close.

End of S186 observation. **IMPL-SHIPPED-PENDING-PRODUCTION-VERIFICATION** —
Option D applied at unit level; ready for next-cadence empirical confirmation.

---

## S187 Append — PRODUCTION VERIFICATION PARTIAL-CONFIRMED

**Triggered**: User submitted "continue" trivial prompt at 2026-05-07T11:50:22+07:00
(first real `/clear`+trivial prompt UserPromptSubmit event after S186 D-043
ship). Empirical observation conducted within same agent turn ~3-5 minutes
post-trigger via `.session-hooks.log` + `.hook-firing-counter.log` +
`.in-flight-subagent-watcher.log` + `.harness-health.log` cross-log inspection.

### Hook chain advance evidence (UserPromptSubmit @ 11:50:22)

UserPromptSubmit chain order (per `.claude/settings.json:240-281`):

| # | Hook | Pre-S186 emission rate | S187 11:50 fire? | Log file | Evidence |
|---|------|------------------------|------------------|----------|----------|
| 1 | userprompt-invariants-injector | 100% (always-logs) | YES | `.session-hooks.log` | `[2026-05-07T11:50:22+07:00] UserPromptSubmit-injector: SKIP (trivial prompt detected)` |
| 2 | stale-prompt-detector | 18.5% (INJECTED-only) | EXPECTED-SILENT | n/a | trivial-path early-exit at line 26 (no log emission for trivial prompts; cannot directly observe but chain advances DESPITE silent exit per hooks #4-#5 evidence) |
| 3 | correction-rate-tracker | 3.8% (conditional) | EXPECTED-SILENT | `.correction-rate.log` | no-match path silent emit (no log; cannot directly observe; chain advances per #4-#5) |
| 4 | in-flight-subagent-watcher | 0% | **YES (NEW)** | `.in-flight-subagent-watcher.log` | `[2026-05-07T11:50:21+07:00] in-flight-subagent-watcher: clean (0 stale pending dispatch)` |
| 5 | hook-firing-counter | 0% | **YES (NEW)** | `.hook-firing-counter.log` | `[2026-05-07T11:50:21+07:00] hook-firing-counter: 20/71 declared hook(s) silent ≥7d` |
| 6 | effort-escalation-detector | 0% | NO | n/a (no standalone log) | absent — chain stops here OR earlier (hook source has no .log path; emits to stderr only when escalation detected) |
| 7 | idle-escape-detector | 0% (UserPromptSubmit ctx) | NO | `.session-hooks.log` (HOOK_LOG var) | absent — would emit to .session-hooks.log per source but no entry at 11:50 |
| 8 | phase-status-coherence | 0% (UserPromptSubmit ctx) | NO | `.session-hooks.log` (HOOK_LOG var) | absent — would emit to .session-hooks.log per source but no entry at 11:50 |
| 9 | harness-health-self-scan | 0% (UserPromptSubmit ctx) | NO | `.harness-health.log` | absent — last entry at 11:36:30 (firing-test-smoke-8372), no 11:50 entry |

### Verdict — D-043 PARTIAL-CONFIRMED

**Hypothesis CONFIRMED-DIRECTIONALLY**: D-043 emit-stdout-JSON-on-SKIP-path
fix DID restore chain advance for trivial prompts. Hooks #4 and #5
empirically transitioned from 0/154 emissions pre-fix to 1/1 emission on
this S187 verification trial.

**Hypothesis REQUIRES REFINEMENT**: original S185 single-rule formulation
("each hook must emit `hookSpecificOutput` JSON to stdout for chain to
advance") does NOT fully explain the observed chain stop. Hook #5
hook-firing-counter does NOT emit `hookSpecificOutput` JSON anywhere in its
source (lines 96-104 use `>&2` stderr printf or file append only) — yet
chain advanced past hook #1 → #4 → #5. If original hypothesis were
strictly correct, chain should stop at hook #5. But it advanced FROM #5 to
#6 (well, partially — we observe #5 firing but #6 not emitting; chain
truncation actually occurs AT #5 boundary or AT #6 entry).

**Three competing hypotheses for the #5→#6 chain stop**:

H-a: **Stderr write triggers truncation**: hook #5 writes to `>&2` stderr
(line 100-101) when SILENT_COUNT > 0. If Claude Code's chain executor
treats stderr emission as a "block-and-show" signal (similar to permission
prompts), the chain may truncate post-stderr-write. Test: modify hook #5
to suppress stderr (only write to log file) on next iteration; observe if
hooks #6-#9 emit.

H-b: **Hook execution time threshold**: hook #5 does ~71 grep calls on a
1.3MB log file (line 79: `grep -F -c "$base" "$HOOKS_LOG"`); per-call
~10-50ms × 71 = ~700-3500ms total. If chain executor has a 1-3 second
soft-timeout, hook #5 may exceed it. Test: time hook #5 standalone; if
>1.5s, retry with reduced grep load.

H-c: **Hook stdout-JSON-emission requirement is per-segment, not per-hook**:
chain may execute hooks in segments (groups of N) with stdout JSON
required only at segment boundaries, not every hook. Hook #5 may be a
segment boundary requiring emission. Test: examine settings.json structure
for segment boundaries; modify chain order to test.

**Counter-factual recovery (S187 PARTIAL-CONFIRMED)**:

| Hook | Pre-S186 (S185 evidence) | Post-S186 D-043 (S187 1st observation) | Recovery |
|------|--------------------------|----------------------------------------|----------|
| #1 userprompt-invariants-injector | 100% | 100% | (no change; always-fired) |
| #2 stale-prompt-detector | 18.5% (INJECTED only) | EXPECTED-SILENT-on-trivial (cannot directly verify; chain advance to #4-#5 IMPLIES chain advanced through #2) | INDIRECT EVIDENCE |
| #3 correction-rate-tracker | 3.8% (no-match silent) | EXPECTED-SILENT (same) | INDIRECT EVIDENCE |
| #4 in-flight-subagent-watcher | 0% | 100% (this trial) | **RECOVERED** |
| #5 hook-firing-counter | 0% | 100% (this trial) | **RECOVERED** |
| #6 effort-escalation-detector | 0% | 0% (this trial) | NOT RECOVERED |
| #7 idle-escape-detector | 0% | 0% (this trial) | NOT RECOVERED |
| #8 phase-status-coherence | 0% | 0% (this trial) | NOT RECOVERED |
| #9 harness-health-self-scan | 0% | 0% (this trial) | NOT RECOVERED |

S186 D-043 closes 2 (or 4 with indirect-#2-#3) of 9 UserPromptSubmit chain
emission gaps. Remaining 4 gaps (hooks #6-#9) require S188+ investigation
of the new truncation point at #5/#6 boundary.

### Refined hypothesis state for S188+

**S185 hypothesis (original)**: stdout `hookSpecificOutput` JSON required at
EVERY hook for chain advance.

**S187 refinement**: stdout JSON appears required at hook #1 (the entry
point) — D-043 fix at hook #1 alone restored chain advance through hook #5.
Truncation mechanism at hook #5/#6 boundary is SEPARATE and unknown
(candidate hypotheses H-a / H-b / H-c above).

**Test plan S188+**:
1. Reproduce S187 observation in 1-2 additional trivial-prompt UserPromptSubmit
   events (confirm 100% emission rate is stable, not 1-trial fluke).
2. Investigate H-a (stderr suppression test): modify hook-firing-counter to
   write only to log file (no stderr); observe if hooks #6-#9 emit on next
   trivial-prompt event.
3. If H-a fails, investigate H-b (timing test): time hook-firing-counter
   standalone; if >1.5s, reduce grep load via batched single-pass grep.
4. If H-b fails, investigate H-c (segment-boundary): trace chain execution
   wall-time per hook; identify if there's a "checkpoint" hook position
   where stdout-JSON re-emission resets chain.

### Lessons + refinements captured (S187)

**Refinement-of-rule (NOT 2nd-instance promotion per AP-23)**: original
S185 hypothesis "stdout JSON required at every hook" was a useful
DIRECTIONAL hypothesis but NOT the full mechanism. S187 1-trial empirical
confirms direction but reveals additional factor at #5/#6 boundary.
Promotion of refined hypothesis to formal lesson deferred until S188+
narrows mechanism (H-a/H-b/H-c discriminated).

**Verification protocol refinement (NOT 2nd-instance promotion per AP-23)**:
S186 verification protocol expected `stale-prompt-detector: clean (no
stale refs)` log line as confirmation signal. WRONG — stale-prompt-detector
trivial-path silent-exits at line 26 with no log. Correct verification
target for trivial-prompt chain advance is hook #4 (in-flight-subagent-watcher)
which always-logs to standalone .log file, OR hook #5 (hook-firing-counter)
likewise. This refinement of "what to look for" is captured here, NOT
promoted to lesson — same class as S181 fixture-vs-regex-quantifier and
S186 fixture-delivery-mechanism (both AP-23 1st-instance refinements of
L-S176-1).

End of S187 verification append. **D-043 PARTIAL-CONFIRMED — chain advance
restored for hooks #1→#5; hooks #6-#9 truncation persists at new
boundary; root cause for #5/#6 chain stop queued S188+ PRIORITY 1
investigation per H-a/H-b/H-c hypothesis stack.**
