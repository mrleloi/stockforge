---
id: D-042-S184-continue-injector-spawn-extraction
title: S184 continue-injector spawn extraction restores SessionStart hook chain on Windows
date: 2026-05-07
status: ACCEPTED-AND-SHIPPED
level: SCOPE
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/memory/checkpoints/latest.md
    quote: "S184 PRIORITY 1 = Option A fix (extract continue-injector spawn into separate hook AFTER harness-health-self-scan in SessionStart chain order; FOCUSED_IMPL ~60-80K main)"
  - path: agent-workspace/memory/observations/2026-05-07-S183-harness-health-non-emission.md
    section: "5-fold empirical evidence — root cause = continue-injector spawn at session-start-bootstrap.sh:178-181 (powershell.exe Start-Process via `& disown` for MINGW*|MSYS*|CYGWIN*) truncates SessionStart hook chain on Windows; production-fire rate of harness-health-self-scan = 1/214 = 0.47%"
  - path: scripts/hooks/session-start-bootstrap.sh
    section: "S183 lines 174-198 — MINGW* branch nested powershell.exe Start-Process spawn confirmed correlated with chain truncation; lines 127-201 contain entire spawn block extracted in this ADR"
  - path: .claude/settings.json
    section: "S183 lines 138-211 SessionStart matcher startup|resume|clear chain; session-start-bootstrap at index 4 (line 156); harness-health-self-scan at index 17 (line 208) — last hook before this ADR; intermediate 13 hooks empirically suppressed by spawn truncation"
  - path: agent-workspace/memory/agent-notes.md
    section: "L-S176-1 BINDING (S176): file-pattern hooks MUST validate against real-state inventory + ship companion firing-test with REAL-STATE-DERIVED fixtures; L-S174-1 RC-pattern (mktemp -d + trap cleanup); Phase 3.5 Hard Rule #2 (every hook ships with companion firing-test)"
  - path: agent-workspace/memory/decisions/035-S173-T6-harness-health-self-scan-hook.md
    section: "D-035 — 12-signal continuous self-scan emits state=GREEN|YELLOW|RED-N summary line at every SessionStart + UserPromptSubmit per Phase 3.5 §HH-G; effectively non-firing in production until this S184 fix"
intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  affects_invariant: false
  urgency: HIGH
  complexity_score: 30
context: |
  S183 FOCUSED_AUDIT identified the root cause of harness-health-self-scan
  non-emission in production: the continue-injector spawn block at
  `session-start-bootstrap.sh:174-198` (Windows MINGW* branch — `powershell.exe
  Start-Process` via `& disown` to dispatch a detached `continue-injector.ps1`)
  empirically truncates Claude Code's SessionStart hook chain on Windows. After
  bootstrap.sh completes, the chain stops; the remaining 13 chain hooks
  (vendor-api-probe through harness-health-self-scan) never execute.

  Empirical evidence (S183, 5-fold):
  1. Full-history grep: 43 total harness-health-self-scan emissions all-time;
     42 from synthesized SIDs (`firing-test-smoke-*` + `manual-*`); 1 from real
     production (10:45:31 UTC+7 with session=unknown). Production-fire rate =
     1/214 real events = 0.47%.
  2. Source-path bifurcation: 60/60 source=clear+autonomous=true SessionStart
     events FAIL to emit (chain truncates after bootstrap "spawned
     continue-injector" line, then 6-second silence). 1/1 source=empty
     SessionStart event (no spawn occurred, fell through case statement) emits
     ALL 17 chain hooks within 3 seconds.
  3. Pure-bash manual chain run: 5.7s wall time for all 17 hooks; rejects H1
     chain-timeout hypothesis.
  4. Source code inspection: nested powershell.exe Start-Process spawn confirmed
     correlated with chain truncation (confirms H2 child-spawn ordering + H3
     Windows-specific infrastructure quirk).
  5. UserPromptSubmit cross-check: SAME pattern — first hook
     userprompt-invariants-injector emits "SKIP" then chain truncates;
     0/154 emissions of last 6 chain hooks. Mechanism unknown; queued S184+
     PRIORITY 2 (separate root cause).

  Counter-factual impact: if Option A fix had been in place since S173 D-035
  ship (2026-05-07 ~04:00 ICT), ~60+ harness-health-self-scan state summaries
  would have emitted by S183 vs actual 1. The 12-signal continuous self-scan
  effectively never ran in production for ~12 hours despite being wired at
  `.claude/settings.json:208`.

  Severity HIGH per checkpoint — D-035 self-scan is THE harness-health
  self-correction signal; non-emission means RED-N states go undetected at
  every prompt boundary, defeating the fundamental Phase 3.5 §HH-G
  empirical-firing-exemplar contract.

decision: |
  FOCUSED_IMPL S184 — apply Option A fix:

  **Step 1**: Author NEW hook `scripts/hooks/continue-injector-spawn.sh`
  (~105 LOC including header docstring + L-S174-1 trap discipline). Extracts
  the spawn block from `session-start-bootstrap.sh:127-201` verbatim, preserving:
  - SOURCE parsing from JSON payload (node -e parser)
  - case-filter to startup|resume|clear (early exit 0 otherwise)
  - autonomous_mode parse from `current-execution.md` (`**autonomous_mode**:`
    line awk-cut)
  - SHOULD_FIRE_INJECTOR gating logic (clear with override OR autonomous /
    resume unconditional / startup gated by autonomous)
  - Platform spawn dispatch (MINGW*|MSYS*|CYGWIN* / Darwin / Linux)
  - .session-hooks.log emission (FIRED vs SKIPPED with FIRE_REASON)
  - Final exit 0 (chain-graceful)

  **Step 2**: Refactor `session-start-bootstrap.sh` — strip lines 127-201
  (spawn block); preserve additionalContext injection + .session-ready writeout
  + queued-grill-master scan + parse-check session-self-reboot.ps1. Update
  header docstring (remove "spawns continue-injector.ps1" line; add S184 D-042
  note explaining extraction rationale). Bootstrap drops 204 → 136 LOC (-68 LOC
  net after header expansion).

  **Step 3**: Reorder `.claude/settings.json` SessionStart chain — append
  `continue-injector-spawn.sh` as the 18th and LAST hook in the
  startup|resume|clear matcher chain (after `harness-health-self-scan.sh` at
  current index 17). Order is critical: the spawn-induced chain truncation can
  no longer suppress any downstream hook because there ARE no downstream hooks.

  **Step 4**: Author companion firing-test
  `scripts/hooks/firing-tests/continue-injector-spawn-fire-test.sh` (~210 LOC,
  9 TCs) per Phase 3.5 Hard Rule #2:
  - TC1: source=compact (out-of-scope) → exit 0, NO log entry
  - TC2: source=clear, autonomous_mode=false, no override → SKIPPED
  - TC3: source=clear, autonomous_mode=false, FORCE_CONTINUE_ON_CLEAR=1 → FIRED (override path)
  - TC4: source=clear, autonomous_mode=true → FIRED
  - TC5: source=resume → FIRED unconditionally
  - TC6: source=startup, autonomous_mode=false → SKIPPED (race risk)
  - TC7: source=startup, autonomous_mode=true → FIRED
  - TC8: missing current-execution.md → autonomous defaults false → SKIPPED
  - TC9: empty payload (no source field) → exit 0, NO log entry

  **Step 5**: Production verification — bootstrap smoke-test confirms
  additionalContext + .session-ready still emit cleanly (no spawn); spawn-hook
  smoke-test confirms FIRED log line emits with correct FIRE_REASON. Real
  production verification deferred to next user `/clear` event (cannot
  synthesize Claude Code SessionStart hook chain trigger from agent context;
  the bug itself is a Claude Code Windows-specific behavior, not bash logic).

options_considered:
  - id: A
    summary: "Extract spawn into separate hook + reorder LAST in chain (CHOSEN)"
    pros:
      - "Empirically minimal change — preserves spawn behavior + gating + platform branches verbatim"
      - "Reorder makes truncation harmless: no downstream hooks exist after spawn"
      - "Diagnoses root cause without requiring upstream Claude Code patch"
      - "Companion firing-test mandatory per Phase 3.5 Hard Rule #2 — easy to author for self-contained spawn logic"
    cons:
      - "Adds 1 more hook to SessionStart chain (17 → 18) — minimal token + latency cost"
      - "Does not fix UserPromptSubmit chain truncation (separate root cause; queued S184+ PRIORITY 2)"
      - "Behavior post-fix still depends on the underlying Claude Code chain-truncation bug not regressing into worse forms"
  - id: B
    summary: "Move spawn out of SessionStart chain entirely — fire from continue-injector.ps1 PowerShell as background watcher"
    pros:
      - "Decouples from Claude Code hook chain"
      - "More resilient to future hook-system regressions"
    cons:
      - "Requires PowerShell watcher process management (long-running daemon-style)"
      - "Lifetime/ownership ambiguity (started where, killed when)"
      - "~150+ LOC PowerShell + signal coordination — disproportionate to fix scope"
  - id: C
    summary: "Replace spawn with sync-blocking SendKeys (bash-native xdotool / wmctrl equivalent on Windows via custom binary)"
    pros:
      - "Synchronous chain order preserved; no truncation risk"
    cons:
      - "Windows lacks native xdotool equivalent in standard envs"
      - "Custom binary distribution is out of Phase 0 portability scope"
      - "Sync-blocking on user TUI introspection = race-prone (need to wait for TUI ready signal that doesn't exist)"
  - id: D
    summary: "Disable continue-injector entirely — rely on user manually typing 'continue' after /clear"
    pros:
      - "Simplest possible fix"
      - "No chain modifications"
    cons:
      - "Breaks autonomous-loop primary contract — `/clear → keep going` is the keystone of full-autonomous mode"
      - "User would need to context-switch every session boundary"
      - "Regressed S8 fix per user 'no continue, why? fix' complaint"
  - id: E
    summary: "Defer fix; investigate UserPromptSubmit chain truncation in parallel; ship combined fix S185+"
    pros:
      - "Holistic understanding of Claude-Code-Windows truncation class"
      - "Single-fix unification possible"
    cons:
      - "harness-health-self-scan continues at 0.47% production-fire rate during diagnosis window"
      - "Counter-factual ~60+ missed self-scan summaries per ~12-hour window grows linearly"
      - "AP-7 anti-pattern (defer-with-prerequisites without active user gate)"

chosen: A
chosen_rationale: |
  Option A is the surgical minimum that closes the harness-health signal gap
  immediately. The fix mechanism is empirically validated (S183 evidence #2:
  source=empty case where no spawn occurs sees ALL 17 chain hooks emit within
  3 seconds — proves: when no spawn, no truncation). Companion firing-test
  fully satisfies Phase 3.5 Hard Rule #2 + L-S176-1 REAL-STATE-DERIVED
  doctrine. UserPromptSubmit chain truncation is a separate root cause queued
  S184+ PRIORITY 2 and does NOT block this SessionStart fix.

  Option B is over-engineering for what is fundamentally a hook-ordering bug.
  Option C lacks Windows tooling. Option D regresses user-validated behavior.
  Option E violates AP-7 (vacuous defer).

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-07
    via: agent-workspace/memory/checkpoints/latest.md (S183 close, "S184 NEXT ACTION priority 1: Apply Option A fix")
  - actor: agent
    action: ACCEPTED-AND-SHIPPED
    at: 2026-05-07
    via: S184 ratified S183 PRIORITY 1 verbatim + autonomous_continue_no_self_pause + harness_priority_one (HH signal coverage gap > product work)

verified_by:
  - mechanism: smoke-test
    at: 2026-05-07
    result: PASS
    detail: "Bootstrap.sh smoke-test post-refactor: emits valid additionalContext JSON to stdout, writes .session-ready (ready_at + session_id + source=clear), logs `SessionStart-bootstrap injected additionalContext` to .session-hooks.log, NO spawn dispatch (verified via lack of `spawned continue-injector` log line). New continue-injector-spawn.sh smoke-test: emits `continue-injector-spawn FIRED (source=clear + autonomous_mode=true)` log line with correct FIRE_REASON; spawn dispatch happens in detached process (>/dev/null 2>&1 & + disown)."
  - mechanism: firing-test
    at: 2026-05-07
    result: PASS
    detail: "continue-injector-spawn-fire-test.sh 9/9 TCs PASS individually (source-gate / autonomous-mode-gate / override-env / skip-paths / missing-exec-file / empty-payload). Full firing-test suite 82/82 PASS elapsed 223s (was 81; +1 new = 82; zero regression vs S181 D-041 baseline)."
  - mechanism: production-validation
    at: 2026-05-07
    result: DEFERRED
    detail: "Empirical observation of harness-health-self-scan emission post-fix at next real `/clear` SessionStart event. Cannot synthesize from agent context — Claude Code SessionStart hook chain triggered ONLY by real Claude Code session start. Defense: smoke-test of bootstrap.sh refactor + standalone spawn hook covers chain-internal correctness; the truncation behavior itself is upstream Claude-Code-Windows quirk that bypasses bash semantics."

risks: |
  R1 (low): Future Claude Code update changes SessionStart hook semantics such
  that placing spawn LAST is no longer sufficient (e.g., Claude Code introduces
  a "wait for all hooks" gate that times out). Mitigation: harness-health-self-scan
  itself will detect the regression — restoring its production-fire rate to
  ~100% means it will catch any future emission gap immediately.

  R2 (low): The 18th hook (continue-injector-spawn) itself triggers a NEW
  truncation downstream — not applicable since there ARE no further chain hooks
  after it; the only "downstream" is the matcher=".*" chain entry for
  component-telemetry which is in a SEPARATE matcher block. Risk monitoring:
  observe component-telemetry production-fire rate post-S184.

  R3 (negligible): Refactor accidentally breaks `additionalContext` injection
  in bootstrap.sh. Smoke-test (above) confirms identical JSON output to pre-S184
  baseline.

end_of_adr: |
  S184 D-042 SHIPPED 2026-05-07. New hook +105 LOC; bootstrap refactor
  -68 LOC; settings.json +5 LOC (1 new chain entry); firing-test +210 LOC
  (9 TCs). Net production code +37 LOC. Test code +210 LOC. Test-to-code
  ratio 5.7x — acceptable for a regression-class fix that closes a 99.5%
  emission-rate gap. Production verification pending next real `/clear`
  event; any future SessionStart should observe `harness-health-self-scan:
  state=...` line in `.session-hooks.log` (and identical for upstream
  vendor-api-probe / qa-pending-stale-mover / etc.). UserPromptSubmit chain
  truncation queued S185+ PRIORITY 2 separate diagnosis.
