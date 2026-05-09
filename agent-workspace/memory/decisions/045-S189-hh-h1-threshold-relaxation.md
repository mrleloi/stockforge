---
id: D-045-S189-hh-h1-threshold-relaxation
title: S189 HH-H.1 stale-checkpoint guard threshold relaxation 300s→1800s — autonomous-loop revival after S188 close BLOCKED for 26+ hours
date: 2026-05-08
status: ACCEPTED-AND-SHIPPED
level: SCOPE
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/memory/.auto-reboot-BLOCKED-stale-checkpoint
    quote: |
      AUTO-REBOOT BLOCKED at 2026-05-07T12:25:23+07:00
      Reason: checkpoints/latest.md mtime is 709s old (>300s threshold; HH-H.1 guard).
      Action: write a fresh checkpoint via /handoff-prep before reboot fires.
      Override: set STOCKFORGE_FORCE_REBOOT=1 to bypass.
  - path: scripts/session-self-reboot.sh
    section: "lines 15-39 pre-S189 — HH-H.1 stale-checkpoint guard with 300s threshold (5min strict). Logic: if checkpoints/latest.md mtime > 300s old, write BLOCKED marker + exit 2; budget-watchdog.sh sees no spawn occurred → autonomous loop dies"
  - path: agent-workspace/memory/.session-hooks.log
    quote: "[2026-05-07T12:25:23+07:00] WIND_DOWN auto-reboot firing on Stop tokens=207318 ; (NO subsequent spawn entries — chain truncated by HH-H.1 guard at session-self-reboot.sh) ; [2026-05-08T14:55:44+07:00] UserPromptSubmit-injector: invariants reminder injected (prompt_len=55) — first user prompt after 26+h dead window"
  - path: scripts/hooks/auto-reboot-handoff-verify.sh
    section: "comment lines 8-10 — HH-H.4 outer fence (2h=7200s threshold; soft-warn before watchdog spawns); HH-H.1 inner fence in session-self-reboot.sh originally 300s. Defense-in-depth design assumed inner fence would catch real staleness near reboot moment, outer fence as backstop. S189 finding: inner fence too aggressive — fires false-positive on every >5min IMPL turn"
  - path: agent-workspace/memory/sessions/2026-05-07-session-188.md
    section: "S188 turn ~22min total: 12:03:01 UserPromptSubmit → 12:14 latest.md slim rewrite Edit → 12:24 last memory artifact edit → 12:25:23 Stop fire. At Stop time, latest.md mtime ~660s old > 300s threshold → BLOCKED"
intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  affects_invariant: false
  urgency: HIGH
  complexity_score: 8
context: |
  S188 closed at 2026-05-07T12:25:23+07:00 with successful FOCUSED_IMPL ship of
  D-044 (H-c additive stdout JSON fix). Stop hook fired auto-reboot path at
  WIND_DOWN crossing (207318 tokens > 180000 threshold). Auto-reboot path
  invoked `scripts/session-self-reboot.sh` which checks HH-H.1 stale-checkpoint
  guard before sending /new keystroke to TUI.

  HH-H.1 guard logic (pre-S189): if checkpoints/latest.md mtime > 300s old,
  write `.auto-reboot-BLOCKED-stale-checkpoint` marker + exit 2 (no keystroke
  send → autonomous loop dies). Designed to prevent reboot from losing pending
  work when agent hasn't yet handed off state.

  Empirical fail mode (S188 close): agent wrote latest.md at ~12:14 (during
  slim rewrite Edit step early in turn), then continued IMPL work (D-044 ADR
  ~12:15-17, observation ~12:18-20, project.md edit ~12:22, session log ~12:24).
  At Stop fire 12:25:23, latest.md mtime was ~660s (11 min) old — BEYOND the
  300s threshold. Guard fired → BLOCKED marker written → reboot aborted →
  autonomous loop silently died. User had to manually re-prompt 26+ hours
  later at 2026-05-08T14:55:44+07:00 with "sao không autonomous run tiếp.
  lỗi harness à. fix".

  Severity HIGH per user-stated complaint + evidence: 26+ hour dead window
  is the longest single-block since autonomous mode was enabled (S48). Pre-S189
  the threshold was systematically too aggressive — any FOCUSED_IMPL turn
  (typical 10-25min) where checkpoint is written early and Stop fires late
  hits the BLOCK. MULTI_TASK_IMPL turns (typical 25-60min) ALWAYS BLOCK under
  the 300s threshold.

  Counter-factual: had this design been used in autonomous loop S48-S187, the
  loop would have intermittently died on every multi-edit IMPL turn. Why didn't
  this surface earlier? Hypothesis: most prior IMPL turns (S130-S180 era) were
  shorter than 5 min OR wrote checkpoint LAST in the turn (close to Stop fire).
  S188 was an outlier in writing checkpoint early during slim-rewrite (per
  S188 trim work to fix working-memory budget overflow at S188 entry).

decision: |
  FOCUSED_IMPL S189 — relax HH-H.1 stale-checkpoint guard threshold 300s→1800s
  with environment override:

  **Step 1**: Modify `scripts/session-self-reboot.sh` HH-H.1 guard section
  (lines 15-39 pre-S189). Replace hardcoded `300` with parameterized
  `HH_H1_THRESHOLD_S` variable defaulting to 1800 (30 min); allow tuning via
  `STOCKFORGE_HH_H1_THRESHOLD_S` env var:

  ```bash
  HH_H1_THRESHOLD_S="${STOCKFORGE_HH_H1_THRESHOLD_S:-1800}"
  ...
  if [ "$CHECKPOINT_AGE" -gt "$HH_H1_THRESHOLD_S" ]; then
    ...BLOCKED marker + exit 2
  fi
  ```

  Update inline comment to reflect new threshold + S189 root-cause rationale.
  Update BLOCKED marker text to cite the actual configured threshold (not
  hardcoded 300s) so future diagnostics match runtime behavior.

  Net production code change: ~10 LOC (1 new variable declaration + 4 modified
  conditions/printf strings + 5 LOC of expanded inline comment with S189 D-045
  rationale).

  **Step 2**: NO companion firing-test added. Justification (skip rationale):
  - `session-self-reboot.sh` is NOT a hook in `.claude/settings.json` event-
    chain sense — it's a regular script invoked BY a hook (budget-watchdog.sh
    auto-reboot path). Phase 3.5 §HH-G "every hook ships with companion firing-
    test" applies to Claude Code event hooks, not invoked scripts.
  - Sibling guard pattern (HH-H.4 outer fence in `auto-reboot-handoff-verify.sh`)
    HAS a companion firing-test at `scripts/hooks/firing-tests/auto-reboot-
    handoff-verify-fire-test.sh` covering the same threshold-vs-mtime pattern.
    Adding a duplicate test for HH-H.1 inner fence offers diminishing return.
  - The keystroke-sender at lines 61-99 resists safe automated testing
    (would actually send /new to TUI; disrupts session). Adding a new env-
    gate STOCKFORGE_GUARD_DRY_RUN=1 to short-circuit before keystroke send is
    feasible (~4 LOC) but represents production-code pollution for a single-
    line threshold change.
  - Empirical verification at next auto-reboot fire (S190+ when budget hits
    WIND_DOWN/CLIFF) is more authentic than firing-test mock — guard either
    fires or doesn't on real Claude Code Stop event.

  **Step 3**: Recovery. Remove existing `.auto-reboot-BLOCKED-stale-checkpoint`
  marker from S188 close (was inhibiting next reboot). Write fresh
  `checkpoints/latest.md` with current S189 entry state (mtime bumped to
  current time; well within new 1800s threshold).

  **Step 4**: Verification. `bash -n scripts/session-self-reboot.sh` PARSE OK
  ✓; grep verification of HH_H1_THRESHOLD_S=1800 default + env override
  pattern ✓; checkpoint mtime fresh (81s age at verification step) ✓.
  Production validation deferred to next auto-reboot fire when current
  session crosses WIND_DOWN/CLIFF threshold.

options_considered:
  - id: A
    summary: "Relax threshold 300s → 1800s with env override (CHOSEN)"
    pros:
      - "Surgical (~10 LOC change in single guard block)"
      - "Accommodates typical FOCUSED_IMPL turn duration (10-25min)"
      - "Defense-in-depth preserved: HH-H.4 outer fence 7200s catches truly-stale states"
      - "Tunable via STOCKFORGE_HH_H1_THRESHOLD_S env (e.g., set to 600 for tighter check during SCOPE-tier work)"
      - "Backward compatible: existing FORCE_REBOOT=1 override preserved"
    cons:
      - "1800s = 30min may still BLOCK on long MULTI_TASK_IMPL turns (25-60min) → may need further relaxation S190+"
      - "Original 300s design intent (force fresh checkpoint near reboot moment) is weakened"
  - id: B
    summary: "Auto-touch latest.md at Stop hook before reboot fires"
    pros:
      - "Solves staleness without changing threshold (preserves design intent)"
      - "Stop hook bumps mtime → guard always sees fresh"
    cons:
      - "False-fresh signal if checkpoint contents are stale (mtime updated but content not refreshed)"
      - "Requires new Stop hook OR modification to existing Stop chain"
      - "Phase 3.5 Hard Rule #2 requires companion firing-test → broader scope creep"
      - "Couples auto-reboot path to Stop hook ordering — fragile"
  - id: C
    summary: "Content-based check — verify latest.md contains current session ID"
    pros:
      - "Robust to mtime games — semantic freshness check"
      - "Aligns with what 'fresh checkpoint' actually means"
    cons:
      - "Requires session-ID parsing logic (fragile across format variations)"
      - "Larger scope (~30+ LOC + parser tests)"
      - "Session ID may not be in checkpoint markdown directly (vs frontmatter)"
  - id: D
    summary: "Hybrid: relax threshold + add explicit reminder to write fresh checkpoint at Stop"
    pros:
      - "Defense-in-depth — agent knows to write checkpoint, hook also relaxed"
    cons:
      - "Reminder is LLM-instruction-class (per CLAUDE.md doctrine, not deterministic)"
      - "Adds work to Stop hook chain (already 30+ hooks)"
  - id: E
    summary: "Eliminate HH-H.1 entirely; rely solely on HH-H.4 outer fence (7200s)"
    pros:
      - "Simplest; fewer fences to maintain"
    cons:
      - "Loses near-reboot-moment freshness check entirely"
      - "If user genuinely hasn't checkpoint'd in 1+ hour, reboot may carry stale state"
  - id: F
    summary: "Defer fix; document HH-H.1 fragility in observation; force_reboot=1 manually each session"
    pros:
      - "Zero production code change"
    cons:
      - "Manual override every session is friction (violates autonomous-full goal)"
      - "AP-7 vacuous defer pattern"
      - "User explicitly requested fix"

chosen: A
chosen_rationale: |
  Option A is the surgical minimum-viable fix. The 300s threshold was empirically
  too aggressive for typical IMPL turn duration (Charter Principle 8: cheapest-
  first probe — observe failure mode, choose smallest correction). 1800s
  (30 min) accommodates FOCUSED_IMPL turns; HH-H.4 outer fence at 7200s (2h)
  remains as defense-in-depth backstop for genuinely-stale states.

  Env override `STOCKFORGE_HH_H1_THRESHOLD_S` provides escape hatch: if 1800s
  proves too lax (e.g., user wants tighter check during SCOPE-tier work) or
  too strict (MULTI_TASK_IMPL turns 25-60min), tune without code edit.

  Option B (auto-touch) was tempting but introduces FALSE-FRESH risk —
  decoupling mtime from content updates is exactly what HH-H.1 was designed
  to PREVENT. Option C (content-based) is more robust but requires fragile
  session-ID parser; scope creep.

  Option D (hybrid) adds LLM-instruction reminder which is non-deterministic
  per CLAUDE.md doctrine. Option E (eliminate inner fence) loses the value of
  near-reboot freshness check. Option F (defer) violates user's explicit fix
  request + AP-7.

  Phase 3.5 §HH-G companion-firing-test doctrine intentionally skipped per
  Step 2 rationale: session-self-reboot.sh is invoked-script not hook;
  sibling guard pattern already firing-tested; keystroke-sender resists safe
  isolated testing without env-gate pollution; empirical at next auto-reboot
  fire.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-08
    via: agent-workspace/memory/checkpoints/latest.md (S189 entry findings + S190 NEXT ACTION)
  - actor: agent
    action: ACCEPTED-AND-SHIPPED
    at: 2026-05-08
    via: User prompt "sao không autonomous run tiếp. lỗi harness à. fix" — explicit fix request authorizes harness modification + autonomous_continue_no_self_pause + harness_priority_one (autonomous loop dead = harness gap > product work)

verified_by:
  - mechanism: bash-parse-check
    at: 2026-05-08
    result: PASS
    detail: "`bash -n scripts/session-self-reboot.sh` returns 0 — syntax OK after threshold relaxation edit"
  - mechanism: grep-verification
    at: 2026-05-08
    result: PASS
    detail: "Verified `HH_H1_THRESHOLD_S=\"${STOCKFORGE_HH_H1_THRESHOLD_S:-1800}\"` declaration + condition `if [ \"$CHECKPOINT_AGE\" -gt \"$HH_H1_THRESHOLD_S\" ]` + BLOCKED marker text references `%ss threshold` runtime-formatted (not hardcoded 300s)"
  - mechanism: checkpoint-freshness
    at: 2026-05-08
    result: PASS
    detail: "After fresh latest.md write at S189 entry, `stat -c %Y` confirms mtime current; checkpoint age 81s = well within new 1800s threshold AND within OLD 300s threshold (would-have-passed both)"
  - mechanism: production-validation
    at: deferred-S189+
    result: PENDING
    detail: |
      Production verification deferred to next auto-reboot fire when current S189
      session crosses WIND_DOWN (180000 tokens) or CLIFF (220000 tokens) at Stop
      hook. Verification protocol:

      1. At Stop fire post-WIND_DOWN crossing, observe `.session-hooks.log` for
         `WIND_DOWN auto-reboot firing on Stop tokens=N` line followed by
         continuation (NO `BLOCKED` marker in `agent-workspace/memory/`).
      2. If reboot fires successfully → next /new SessionStart triggers chain
         normally; agent observes new session via SessionStart hook injection.
      3. If still BLOCKED → check `.auto-reboot-BLOCKED-stale-checkpoint` content;
         if "mtime is Ns old (>1800s threshold)" message → checkpoint actually
         was 30+ min stale at Stop (legitimate block, agent should write fresh
         checkpoint mid-IMPL). If "missing" → checkpoint deleted (separate bug).

      Outcome thresholds:
      - **CONFIRMED**: ≥1 successful auto-reboot post-S189 in next 3 sessions →
        threshold relaxation works.
      - **PARTIAL**: 1 successful + 1 BLOCKED in 3 sessions → 1800s still too
        tight for MULTI_TASK_IMPL; consider further relaxation to 3600s in
        S191+.
      - **REJECTED**: 0 successful auto-reboot in 3 sessions → root cause is
        deeper than threshold; investigate alternative mechanisms (e.g.,
        budget-watchdog.sh marker race, RATE_LIMIT marker leak from prior
        sessions, BLOCKED marker carry-over).

risks: |
  R1 (low-medium): 1800s is still too tight for MULTI_TASK_IMPL turns (25-60min
  typical). If MULTI_TASK_IMPL session writes checkpoint at minute 5 then
  continues until minute 35+, guard fires again. Mitigation: env override
  STOCKFORGE_HH_H1_THRESHOLD_S=3600 for MULTI_TASK_IMPL sessions; OR S191+
  consider further relaxation. Counter-evidence: HH-H.4 outer fence at 7200s
  (2h) provides robust backstop for genuinely-stale states.

  R2 (low): Original 300s design intent (force fresh checkpoint near reboot
  moment) is weakened. Now agent has 30 min to write checkpoint before Stop
  hook fires reboot. If agent doesn't write checkpoint at all in a turn,
  reboot may carry stale state. Mitigation: typical IMPL turns DO write
  checkpoint as standard practice (Phase 3.5 §HH-G + autonomous-protocol).
  HH-H.4 outer fence catches if agent is genuinely AFK for >2h.

  R3 (negligible): Env var name conflict. STOCKFORGE_HH_H1_THRESHOLD_S is
  a new variable; no prior usage. Verified via `grep -r STOCKFORGE_HH_H1`
  before commit (would catch any conflicts). Backward compatible: default
  1800 preserves new behavior; setting env to 300 reverts to old behavior.

  R4 (low): No companion firing-test means future regressions in this guard
  go undetected until production failure. Mitigation: Step 2 rationale —
  sibling auto-reboot-handoff-verify-fire-test.sh covers the same
  threshold-vs-mtime pattern; adding duplicate test for HH-H.1 offers
  diminishing return. Acceptance criteria for "Phase 3.5 §HH-G applies":
  invoked-script not hook → exempt from "every hook ships with companion
  firing-test" rule. If a 2nd HH-H.1-class regression surfaces in S190+,
  add firing-test as remediation (promotion candidate L-S189+-1).

  R5 (low): D-044 H-c REJECTED at production verification (separate finding
  in same S189 turn). Hooks #7-#9 still silent at 14:55:44 UserPromptSubmit
  cadence post-D-044 ship. S190 NEXT ACTION queues H-a test. NOT addressed
  by D-045; documented for completeness (D-045 = autonomous-loop revival;
  H-c REJECTED = chain-stop discrimination follow-up).

end_of_adr: |
  S189 D-045 SHIPPED 2026-05-08 at unit level. scripts/session-self-reboot.sh
  +10 LOC (HH-H.1 threshold parameterized + env override + comment expansion).
  NO firing-test added (Step 2 skip rationale documented). NO other production
  code changes.

  Recovery completed:
  - rm `.auto-reboot-BLOCKED-stale-checkpoint` marker (was from S188 12:25:23
    yesterday)
  - Write fresh `checkpoints/latest.md` with S189 entry state (mtime current
    81s age at verification step)

  M-S189-1 NEW HIGH: HH-H.1 stale-checkpoint guard 300s threshold blocks
  autonomous loop on every IMPL turn >5min between checkpoint-write and Stop-
  fire. Severity HIGH (26+ hour dead window at S188 close → S189 manual
  recovery required). Prevention: D-045 threshold relaxation 300s → 1800s +
  env override. Same recurrence-class as M-S171-1 (idle-escape pattern) +
  M-S176-1 (file-pattern hook fail-silent class) — harness design-time
  threshold tuning has bitten StockForge multiple times; promotion candidate
  L-S189+-1 IF a 2nd instance of harness-guard-too-strict surfaces (1st
  instance 300s being too tight; promotion if e.g. another guard threshold
  later proves too strict in S190+).

  D-044 H-c REJECTED at S189 production verification (1st observation at
  14:55:44 UserPromptSubmit non-trivial INJECTED prompt): hooks #4 + #5 emit
  ✓ (consistent with S187 + S188 reproduction); hooks #7 (.idle-escape.log
  MISSING) + #8 (.phase-coherence.log MISSING) + #9 (.harness-health.log last
  12:16:38 yesterday firing-test SID) ALL SILENT — adding stdout JSON to
  hook #5 did NOT advance chain past #5/#6 boundary. Per D-044 verified_by
  step 5: S190 escalates to H-a (suppress hook #5 stderr) test. Considering
  non-destructive variant for S190: redirect stderr write to
  `.hook-firing-counter-stderr.log` instead of >&2 (preserves silent-hook
  alert content; tests if stderr-emission specifically triggers chain
  truncation independent of content destination).

  Phase 3.5 IN-PROGRESS-PARTIAL-S173 unchanged. T8 charter cool-down opens
  ≥2026-05-09 ~05:30 ICT (≈14h from S189 entry); S190 may include T8 charter
  edit if cool-down crosses by then.
