---
id: D-043-S186-userprompt-stdout-fix
title: S186 UserPromptSubmit hook chain truncation Option D empirical-test fix — minimal stdout JSON on SKIP path restores chain continuation on Windows
date: 2026-05-07
status: ACCEPTED-AND-SHIPPED
level: SCOPE
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/memory/checkpoints/latest.md
    quote: "S186 PRIORITY 1 = Option D empirical test (FOCUSED_IMPL ~30-50K main): Modify scripts/hooks/userprompt-invariants-injector.sh trivial path: insert node -e 'process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:\"UserPromptSubmit\",additionalContext:\"\"}}))' before exit 0 (~5 LOC)"
  - path: agent-workspace/memory/observations/2026-05-07-S185-userprompt-chain-truncation-rc.md
    section: "5-fold empirical evidence catalog — hook #1 path bifurcation: 128 SKIP-path emissions (NO stdout) + 29 INJECTED-path emissions (stdout JSON via node -e). stale-prompt-detector emissions (29) = INJECTED-path-fires (29) exact 1:1 match. Hypothesis: UserPromptSubmit hook chain on Windows requires each hook to emit hookSpecificOutput JSON to stdout for chain to advance"
  - path: scripts/hooks/userprompt-invariants-injector.sh
    section: "S185 lines 22-26 trivial-path SKIP block — exits 0 with NO stdout output when prompt matches TRIVIAL_REGEX (continue|ok|yes|tiếp|...); S185 same source emits node -e JSON with reminder content on INJECTED path lines 37-45"
  - path: scripts/hooks/firing-tests/userprompt-invariants-injector-fire-test.sh
    section: "S61 original 6-TC firing-test — TC1-TC3 asserted SKIP-path stdout has NO 'additionalContext' string (incompatible with S186 fix; updated to assert valid JSON with empty additionalContext value via file-based node parse)"
  - path: agent-workspace/memory/decisions/042-S184-continue-injector-spawn-extraction.md
    section: "D-042 SessionStart spawn truncation fix — same Claude-Code-Windows class root-cause; D-042 was SessionStart-side fix, D-043 is UserPromptSubmit-side fix. Companion: D-035 12-signal harness-health-self-scan emits per UserPromptSubmit; non-emission means RED-N states go undetected at every prompt boundary"
  - path: agent-workspace/memory/agent-notes.md
    section: "L-S176-1 BINDING (file-pattern hooks MUST validate against real-state inventory + ship companion firing-test with REAL-STATE-DERIVED fixtures); L-S174-1 RC-pattern (mktemp -d + trap cleanup); Phase 3.5 Hard Rule #2 (every hook ships with companion firing-test); harness_priority_one"
intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  affects_invariant: false
  urgency: HIGH
  complexity_score: 15
context: |
  S185 FOCUSED_AUDIT identified UserPromptSubmit hook chain truncation as a
  separate Claude-Code-Windows-specific root cause from the S183 SessionStart
  spawn truncation (which D-042 closed). 5-fold empirical evidence converged on
  a single mechanism:

  - Hook #1 (`userprompt-invariants-injector.sh`) emissions: 157/157 fires of
    its log entry — both SKIP path (128 fires; no stdout) and INJECTED path
    (29 fires; emits `process.stdout.write(JSON.stringify({hookSpecificOutput:
    {hookEventName: 'UserPromptSubmit', additionalContext: reminder}}))`).
  - Hook #2 (`stale-prompt-detector.sh`) emissions: 29/157 = exactly 18.5%.
    1:1 match with hook #1 INJECTED-path fires. When hook #1 takes the SKIP
    path (no stdout), hook #2 never executes.
  - Hook #2 itself emits stdout JSON only on stale-detected; predicts chain
    stops at #2 when state is clean. Recursive pattern.
  - Manual chain run (all 9 hooks invoked sequentially via bash) completes in
    ~3 seconds, all rc=0. NOT a bash issue. Truncation is upstream
    Claude-Code-Windows-specific.
  - Real-time S185 confirmation: this turn's `/clear`+`continue` prompt at
    11:16:24 emitted ONLY `UserPromptSubmit-injector: SKIP (trivial prompt
    detected)` then 21+ second silence — no stale-prompt-detector or
    downstream emission.

  Hypothesis: UserPromptSubmit hook chain on Windows requires each hook to
  emit `hookSpecificOutput` JSON to stdout for chain to advance to the next
  hook. Hooks that exit 0 with no stdout cause chain truncation at that
  point. Same Claude-Code-Windows root-cause class as S183 SessionStart spawn
  truncation (D-042 closed).

  Counter-factual impact: ~6 fires of hook #3 (correction-rate-tracker;
  conditional emit) + 0 fires of hooks #4-#9 (in-flight-subagent-watcher /
  hook-firing-counter / effort-escalation-detector / idle-escape-detector /
  phase-status-coherence / harness-health-self-scan) from 154 UserPromptSubmit
  events. Severity HIGH — same as D-042: 12-signal continuous self-scan
  effectively never runs in production for UserPromptSubmit cadence.

  Severity HIGH per checkpoint S185 close — `/clear`+continue cycles in
  full-autonomous mode are the dominant prompt cadence, and the 6 missing
  chain hooks include the M-S171-1 prevention pair (idle-escape-detector +
  phase-status-coherence) and harness-health-self-scan. The intended Phase
  3.5 §HH-G empirical-firing-exemplar contract requires per-prompt scan; D-043
  restores that contract for the trivial-prompt path.

decision: |
  FOCUSED_IMPL S186 — apply Option D empirical-test fix:

  **Step 1**: Modify `scripts/hooks/userprompt-invariants-injector.sh` trivial
  SKIP path (lines 23-26 pre-S186). Insert minimal stdout JSON emission
  before `exit 0`:

  ```bash
  if [ -n "$PROMPT_HEAD" ] && printf '%s' "$PROMPT_HEAD" | grep -qE "$TRIVIAL_REGEX"; then
    echo "[$(date -Iseconds)] UserPromptSubmit-injector: SKIP (trivial prompt detected)" >> "$HOOK_LOG"
    # S186 D-043 — emit minimal hookSpecificOutput JSON on SKIP path so Windows
    # UserPromptSubmit hook chain advances past this hook (S185 hypothesis: stdout
    # JSON emission is required for chain continuation on Claude Code Windows).
    node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:''}}))" 2>/dev/null || true
    exit 0
  fi
  ```

  Net production code: +5 LOC (3 LOC node command + 2 LOC explanatory
  comment). The empty-string `additionalContext` is intentional: it satisfies
  the chain-continuation requirement without adding any per-prompt context to
  the LLM transcript (the SKIP path's whole purpose was context-budget
  conservation; D-043 preserves that goal).

  **Step 2**: Update companion firing-test
  `scripts/hooks/firing-tests/userprompt-invariants-injector-fire-test.sh`.
  Pre-S186 TC1-TC3 asserted absence of "additionalContext" string in stdout —
  incompatible with the S186 fix because the new emission contains that field
  name (with empty value). Replace with explicit JSON-shape assertions:

  - SKIP-path TCs (TC1=`continue`, TC2=`ok`, TC3=`tiếp`): assert OUT is
    valid JSON, `hookSpecificOutput.hookEventName === 'UserPromptSubmit'`,
    `hookSpecificOutput.additionalContext === ''` (exact empty string), AND
    OUT does NOT contain "STOCKFORGE INVARIANTS REMINDER" content.
  - Add NEW TC7 explicitly verifying the S186 chain-continuation contract:
    exact JSON shape `{hookSpecificOutput:{hookEventName:"UserPromptSubmit",
    additionalContext:""}}` with no extra keys. If TC7 ever regresses, the
    S186 fix is broken and downstream hooks will stop firing in production.
  - Preserve TC4-TC6 unchanged (non-trivial path, empty path, long path).

  Use file-based fixture for `node` JSON parse (write OUT to `$TEMPDIR/_assert_in.json`,
  pass path as argv) to avoid shell-escape pitfalls of inline `node -e
  's=\"...\"'` (refinement of L-S176-1 fixture-real-state doctrine; same
  class as L-S181-1 fixture-vs-regex-quantifier — caught + fixed in TDD loop
  on first run). Net firing-test code: +130 LOC (was 147, now 277).

  **Step 3**: Run individual firing-test → expect 7/7 PASS. Run full
  firing-test suite → expect 82/82 PASS (zero regression vs S184 baseline).

  **Step 4**: Production verification — observe at next real `/clear` event
  whether `stale-prompt-detector: clean (no stale refs)` line appears in
  `.session-hooks.log` for trivial prompt fires. If observed → hypothesis
  CONFIRMED → queue Option A full retro-fit S187+ (modify all 9 UserPromptSubmit
  chain hooks + SessionStart chain hooks if needed to emit minimal JSON on
  every code path). If multiple turns pass with NO stale-prompt-detector
  emissions → hypothesis REJECTED, escalate to alternative root cause
  investigation.

options_considered:
  - id: A
    summary: "Full retro-fit ALL 9 UserPromptSubmit chain hooks immediately (~50 LOC × 9 = ~450 LOC)"
    pros:
      - "Closes the entire chain truncation gap in one ADR"
      - "Maximum production-emission recovery on first ship"
    cons:
      - "Hypothesis CONFIRMED-PENDING-IMPL-VERIFICATION at S185; large blast radius before empirical chain-advance proven"
      - "MULTI-TASK IMPL ~150-250K main vs FOCUSED_IMPL ~30-50K for D"
      - "If hypothesis is wrong (alternative mechanism), 450 LOC of dead-code emissions"
      - "Violates 'cheapest-first probe' doctrine (Charter Principle 8)"
  - id: B
    summary: "Disable trivial SKIP path entirely — always emit full invariants reminder"
    pros:
      - "Minimal code change (delete 5 lines)"
      - "Chain advance trivially preserved (always INJECTED path)"
    cons:
      - "Defeats SKIP-path's whole purpose: context-budget conservation per trivial prompt"
      - "Bloats every continue/ok prompt with ~600-byte invariants reminder"
      - "Estimated +30K tokens per ~50 trivial prompts in autonomous-loop mode (~10x overhead)"
  - id: C
    summary: "Add chain-keepalive sidecar hook (NEW hook always emits empty-additionalContext JSON; placed before each conditional-emission hook)"
    pros:
      - "Clean separation of concern — keepalive hook does ONE thing"
      - "No modifications to existing hooks"
    cons:
      - "Doubles chain length (9 hooks → 18 hooks = ~3-4s latency added per UserPromptSubmit)"
      - "Hypothesis says EACH hook needs to emit, not 'sidecar emits on its behalf' — keepalive hook BEFORE original hook means chain advances to original hook, but original hook's no-stdout still truncates downstream"
      - "Requires ordering analysis per chain entry"
  - id: D
    summary: "Single-hook empirical test (CHOSEN) — modify only userprompt-invariants-injector.sh SKIP path; observe hook #2 (stale-prompt-detector) emits on subsequent trivial prompt"
    pros:
      - "Minimum-viable test of the hypothesis — falsifiable in single observation"
      - "FOCUSED_IMPL ~30-50K main; small blast radius"
      - "If CONFIRMED → queue Option A retro-fit for S187+ with empirical evidence"
      - "If REJECTED → alternative root cause investigation triggered without 450 LOC sunk cost"
      - "Aligns with Charter Principle 8 (Calibration over confidence — cheapest-first probe)"
    cons:
      - "Defers full fix one session"
      - "5 of 9 chain hooks remain truncation-prone until S187+ ships Option A"
      - "Production verification only at next real `/clear` event (not synthesizable from agent context)"
  - id: E
    summary: "Add stdout-emit pattern to tier-1 chain only (hooks #1-#3) — partial retro-fit"
    pros:
      - "Bounded scope vs full Option A"
      - "Restores critical-path emissions (M-S171-1 prevention pair)"
    cons:
      - "Mid-tier IMPL ~80-120K main"
      - "Still leaves 6 chain hooks truncation-prone"
      - "If hypothesis wrong, 3 hooks of dead-code emissions"
  - id: F
    summary: "File-tail-based diagnostic — add monitor process that watches .session-hooks.log for missing-emission patterns and posts notification"
    pros:
      - "Non-invasive — no hook code changes"
      - "Captures production data for diagnosis"
    cons:
      - "Diagnostic-only — does NOT fix the truncation"
      - "Monitor process lifetime/ownership ambiguity (same class as Option B in D-042)"
      - "Adds complexity without solving root cause"

chosen: D
chosen_rationale: |
  Option D is the surgical minimum-viable empirical test. The S185 hypothesis
  is CONFIRMED-PENDING-IMPL-VERIFICATION; before committing 450 LOC to Option
  A, the cheapest empirical proof is to modify ONE hook and observe whether
  hook #2 (stale-prompt-detector) starts emitting on subsequent trivial
  prompt fires. The observation cost is zero (passive log inspection at next
  `/clear` event); the impl cost is ~5 LOC.

  This matches Charter Principle 8 (Calibration over confidence — cheapest-first
  probe) and the empirical-probe-first skill's doctrine (probe ALL viable
  strategies before committing to one). The 5-fold S185 evidence catalog
  identifies the mechanism, but converting hypothesis to confirmation requires
  one production-cadence observation that this fix is the right shape.

  Option A (full retro-fit) is queued for S187+ contingent on Option D's
  empirical confirmation. Option B regresses context-budget per Phase 3.5
  §HH-G goal. Option C double-counts chain length without solving the
  per-hook-emission requirement. Option E partial-retro-fit gambles on
  hypothesis accuracy with 3x more sunk cost than D. Option F is
  diagnostic-only, not a fix.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-07
    via: agent-workspace/memory/checkpoints/latest.md (S185 close, "S186 PRIORITY 1: Option D empirical test")
  - actor: agent
    action: ACCEPTED-AND-SHIPPED
    at: 2026-05-07
    via: S186 ratified S185 PRIORITY 1 verbatim + autonomous_continue_no_self_pause + harness_priority_one (UserPromptSubmit chain coverage gap > product work) + Charter Principle 8 (cheapest-first empirical probe before committing to full retro-fit)

verified_by:
  - mechanism: smoke-test
    at: 2026-05-07
    result: PASS
    detail: "Direct hook invocation with payload {\"prompt\":\"continue\"} via test harness emits exactly {\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":\"\"}} to stdout AND writes 'SKIP (trivial prompt detected)' to .session-hooks.log. With payload containing non-trivial prompt, emits full invariants reminder JSON (preserved INJECTED path behavior)."
  - mechanism: firing-test
    at: 2026-05-07
    result: PASS
    detail: "userprompt-invariants-injector-fire-test.sh 7/7 TCs PASS individually (TC1=continue → minimal JSON + SKIP log; TC2=ok → minimal JSON + SKIP log; TC3=Vietnamese 'tiếp' → minimal JSON + SKIP log; TC4=non-trivial → JSON with I-S1 invariants reminder; TC5=empty prompt → graceful rc=0; TC6=long non-trivial → injection + prompt_len logged; TC7=S186 chain-continuation contract — exact JSON shape {hookSpecificOutput:{hookEventName:\"UserPromptSubmit\",additionalContext:\"\"}} with no extra keys). Full firing-test suite 82/82 PASS elapsed 223-224s (was 82 from S184; zero regression baseline preserved)."
  - mechanism: production-validation
    at: 2026-05-07T11:50:22+07:00 (S187 1st observation)
    result: PARTIAL-CONFIRMED
    detail: |
      User submitted trivial "continue" prompt at 11:50:22 — first real `/clear`+trivial UserPromptSubmit event post-D-043 ship. Empirical observation via cross-log inspection (.session-hooks.log + .hook-firing-counter.log + .in-flight-subagent-watcher.log + .harness-health.log + standalone .{hook}.log files):
      - Hook #1 userprompt-invariants-injector: emitted SKIP log at 11:50:22 ✓
      - Hook #2 stale-prompt-detector: SILENT (trivial-path early-exit at line 26; no log emission expected; chain advance to #4-#5 IMPLIES chain passed through #2)
      - Hook #3 correction-rate-tracker: SILENT (no-match path)
      - Hook #4 in-flight-subagent-watcher: emitted "clean (0 stale pending dispatch)" at 11:50:21 ✓ **NEW — was 0/154 pre-fix**
      - Hook #5 hook-firing-counter: emitted "20/71 declared hook(s) silent ≥7d" at 11:50:21 ✓ **NEW — was 0/154 pre-fix**
      - Hooks #6-#9 (effort-escalation-detector / idle-escape-detector / phase-status-coherence / harness-health-self-scan): NO emission at 11:50; chain still truncates between hook #5 and hook #6.

      Verdict: D-043 hypothesis CONFIRMED-DIRECTIONALLY at hook #1 → chain advanced from 0/9 reach pre-fix to 5/9 reach post-fix (hook #1 + indirect #2-#3 + direct #4-#5). Refinement required: original S185 single-rule "stdout JSON required at every hook" insufficient — hook #5 hook-firing-counter does NOT emit stdout JSON yet chain advanced past it. New truncation point at #5/#6 boundary.

      S188+ investigation queued: discriminate among H-a (stderr-write triggers truncation; hook #5 emits to >&2 stderr conditionally) / H-b (hook #5 execution time exceeds chain executor soft-timeout; ~71 grep calls × 1.3MB log = ~700-3500ms) / H-c (chain executor segment-boundary requires stdout-JSON re-emission at specific hook positions).

      Counter-factual recovery: 2 hooks (#4 + #5) recovered from 0% to 100% emission rate; ~4 hooks (#6-#9) remain at 0% pending S188+ refined fix. Phase 3.5 §HH-G empirical-firing-exemplar contract restored 2/9 = 22% of UserPromptSubmit chain; partial win.

risks: |
  R1 (low): Hypothesis is wrong — chain truncation has alternative mechanism
  unrelated to stdout emission. Mitigation: Option D is empirical-test scope;
  if S187+ observation shows no stale-prompt-detector emission for trivial
  prompts, alternative root causes are explored (e.g., chain element-count
  limit, exit-code semantic dependency, JSON-shape strictness beyond the
  basic `hookSpecificOutput` envelope). Cost of incorrect hypothesis is
  bounded to ~5 LOC + ~130 LOC test code (deletable in 1 commit if needed).

  R2 (low): The minimal-empty-JSON pattern itself triggers some unintended
  Claude Code behavior (e.g., LLM transcript pollution, additionalContext=""
  parsed as null elsewhere). Mitigation: empty-string additionalContext is
  the documented contract (Anthropic docs explicitly support
  `additionalContext: ""`). Smoke-test confirms hook output is well-formed
  JSON with valid hookEventName.

  R3 (negligible): Refactor accidentally breaks INJECTED path. Firing-test
  TC4 + TC6 explicitly cover the INJECTED path; both PASS post-S186.

  R4 (deferred): Other 8 UserPromptSubmit chain hooks remain truncation-prone
  until Option A retro-fit ships in S187+. During S186→S187 window, only
  hook #2 (stale-prompt-detector) gains chain-continuation; hooks #3-#9 still
  blocked behind hook #2's no-stdout-on-clean-state pattern. Production
  emission rate post-S186 expected: hook #2 → 100% (was 18.5%); hook #3
  → 100% on match path (was 100% on match path); hooks #4-#9 → 0% (unchanged
  pending Option A). Full restoration deferred S187+.

end_of_adr: |
  S186 D-043 SHIPPED 2026-05-07. Hook +5 LOC; firing-test +130 LOC (TC7 NEW
  + TC1-TC3 assertions rewritten for file-based JSON parse). Net production
  code +5 LOC. Test code +130 LOC. Test-to-code ratio 26x — high but
  defensible: the test encodes the exact chain-continuation contract that
  must not regress, and refactor of TC1-TC3 was forced by the
  field-presence-vs-value-shape semantic shift.

  S187 production verification PARTIAL-CONFIRMED (1st observation post-fix
  at 2026-05-07T11:50:22+07:00 via real user "continue" trivial prompt):
  hooks #4 (in-flight-subagent-watcher) + #5 (hook-firing-counter)
  empirically recovered from 0/154 pre-fix to 1/1 post-fix emissions. Hooks
  #6-#9 still at 0% — chain truncates at new #5/#6 boundary. Full Option A
  retro-fit deferred S188+ pending root-cause discrimination at new
  truncation point (3 candidate hypotheses: stderr-write-triggers /
  execution-time-threshold / segment-boundary-emission). UserPromptSubmit
  chain truncation root cause same class as D-042 SessionStart spawn
  truncation (Claude-Code-Windows-specific upstream quirk; both fixes work
  around without requiring upstream patches).

  S187 verification protocol refinement (NOT 2nd-instance promotion per
  AP-23 1st-instance rule): original protocol expected
  `stale-prompt-detector: clean (no stale refs)` log line as
  chain-advance signal — WRONG, that hook silent-exits on trivial prompts.
  Correct verification target is hook #4 (`.in-flight-subagent-watcher.log`
  always-logs) or hook #5 (`.hook-firing-counter.log` always-logs).
  Refinement captured in observation file, not promoted to formal lesson
  (same class as L-S181-1 fixture-vs-quantifier and S186
  fixture-delivery-mechanism — all AP-23 1st-instance refinements of
  L-S176-1 fixture-real-state doctrine).
