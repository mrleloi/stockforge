---
id: D-038-S176-HH-C2-staleness-watchdog-misfire-fix-proposal
title: HH-C.2 staleness watchdog misfire fix — Option E (retire Check A, fix Check B glob, rename, add firing-test)
date: 2026-05-07
status: ACCEPTED-AND-SHIPPED
level: SCOPE
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/memory/observations/2026-05-07-S176-HH-C2-misfire-root-cause.md
    quote: "Hook is a double-broken no-op since 2026-05-06 inception (commit 13e5535) — Check A regex never matches current-execution.md actual format + Check B file glob never matches actual ADR filenames. Zero WARN entries across 10836 log lines."
  - path: scripts/hooks/project-md-staleness-check.sh
    section: "lines 60-61 Check A regex; lines 102-122 Check B glob"
  - path: agent-workspace/memory/checkpoints/latest.md
    quote: "S176 PRIORITY 1 = HH-C.2 staleness watchdog misfire investigation (FOCUSED_AUDIT ~30-50K main); Fix proposal D-038 PROPOSED (FOCUSED_AUDIT outputs proposal; FOCUSED_IMPL S177+ executes if deemed worthwhile)"
  - path: agent-workspace/memory/mistake-log.md
    section: "M-S176-1 NEW HIGH: project-md-staleness-check.sh double-broken no-op since inception"
  - path: agent-workspace/session-plans/pending/010-S50-phase-3.5-harness-deepening-master-plan.md
    section: "§ Hard rules during Phase 3.5 — Hard Rule #2 every hook ships with companion firing-test"
  - path: scripts/hooks/phase-status-coherence.sh
    section: "S175 D-037: per-prompt phase-mismatch detection at UserPromptSubmit cadence (covers Check A scope)"
intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 25
options_considered:
  - id: A
    summary: |
      FIX in-place: patch Check A regex to capture `## SNNN — Phase X.Y` section header;
      patch Check B glob from `D-*.md` to `[0-9]+-.*\.md` (POSIX extended); add companion
      firing-test; keep Stop cadence + existing hook filename.
    pros:
      - "Closes both bugs verbatim; minimal scope"
      - "Preserves existing settings.json wiring (no rename)"
      - "Single hook performs both checks"
    cons:
      - "Stop-only cadence misses real-time drift (which is why phase-status-coherence shipped at UserPromptSubmit cadence at S175)"
      - "Check A overlaps phase-status-coherence — duplicate detection across two cadences"
  - id: B
    summary: |
      MIGRATE: move project-md-staleness-check.sh to UserPromptSubmit chain alongside
      phase-status-coherence; merge Check A into phase-status-coherence; keep Check B at Stop only.
    pros:
      - "Per-prompt phase coherence at UserPromptSubmit cadence"
      - "Check B (mtime drift) at end-session Stop"
    cons:
      - "More files churn; harder to track which hook does what"
      - "Splits a single-file responsibility across two hooks"
  - id: C
    summary: |
      RETIRE entirely: phase-status-coherence (S175) covers Check A; session-end-checklist-linter
      overlaps Check B; remove project-md-staleness-check.sh.
    pros:
      - "Cleanest; reduces hook chain"
    cons:
      - "Loses unique Check B (project.md mtime vs newest ADR) — no other hook does this exact comparison"
      - "Defense-in-depth weakened"
  - id: D
    summary: |
      HYBRID: apply Option A fixes + also wire to UserPromptSubmit chain for Check A;
      keep Stop cadence for Check B.
    pros:
      - "Defense-in-depth; closes bug + matches Phase 3.5 §HH-G empirical-firing exemplar"
    cons:
      - "Modest hook chain growth; Check A duplicates phase-status-coherence"
  - id: E
    summary: |
      RETIRE-CHECK-A-FIX-CHECK-B + rename. Drop Check A from project-md-staleness-check.sh
      (phase-status-coherence handles it at UserPromptSubmit cadence with stronger semantics);
      fix Check B glob to `[0-9]+-.*\.md`; rename file to `project-md-adr-staleness.sh` to
      reflect single-purpose intent; add companion firing-test
      `firing-tests/project-md-adr-staleness-fire-test.sh`; update settings.json wiring;
      keep Stop cadence (project.md mtime vs newest ADR is end-of-session validation).
    pros:
      - "Single-purpose hook = clearer intent; no Check A duplication"
      - "Phase 3.5 Hard Rule #2 satisfied via companion firing-test"
      - "Stop cadence appropriate for end-session ADR-staleness check"
      - "Charter Principle 8 deterministic per-purpose hook"
      - "Companion firing-test surfaces both bugs deliberately as RED-state assertions (regex bug + glob bug fixtures)"
    cons:
      - "Renames file (mtime + git history split via `git mv`)"
      - "Requires settings.json command path update"
      - "Modest LOC delta vs Option A (~+40 LOC for firing-test + rename overhead)"
chosen: E
chosen_rationale: |
  Option E aligns with Phase 3.5 §HH-G empirical-firing exemplar + harness_priority_one
  + Charter Principle 8. Single-purpose hook (project.md mtime vs newest ADR) is clearer
  than dual-purpose Check A+B. Check A retirement is justified by S175 phase-status-coherence
  shipping at UserPromptSubmit cadence — stronger semantics (3 sub-checks: A/B/C with
  match=1 binary signal) at higher cadence (per-prompt vs Stop). Check B uniquely covers
  ADR-vs-project.md mtime drift; no other hook does this exact comparison; retain at
  Stop cadence as end-session validation. Companion firing-test asserts:
    (1) GREEN-state when project.md mtime ≥ newest ADR mtime;
    (2) GREEN-state when delta_hours ≤ 2.0 (within tolerance);
    (3) RED-state WARN when delta_hours > 2.0 (over tolerance);
    (4) GREEN-state silent-skip when decisions/ directory empty;
    (5) hour-bucket idempotency cache hit on 2nd invocation.
  Counter-factual: had Option E been in place at 2026-05-06 hook inception, the S148-S171
  22-session × 2-day project.md slip would have surfaced WARN every session-end after the
  first ADR landed without project.md update. Cost saved: ~100-200K main (M-S176-1 +
  M-S171-1 combined recurrence-class).

  E DEFERS implementation to S177 FOCUSED_IMPL — D-038 ratifies the design decision; S177
  ships the rename + bug fix + firing-test under autonomous-full mode (no AskUserQuestion
  needed because Q-B2 ratification scope = SCOPE-tier audit + impl path; no charter delta).

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-07
    via: |
      S176 FOCUSED_AUDIT — empirical evidence at observations/2026-05-07-S176-HH-C2-misfire-root-cause.md
      verdict CONFIRMED double-broken no-op + decision matrix § E recommended
  - actor: agent
    action: TO-BE-IMPLEMENTED
    at: S177 (next session)
    via: |
      FOCUSED_IMPL ~40-60K main:
        (1) git mv scripts/hooks/project-md-staleness-check.sh scripts/hooks/project-md-adr-staleness.sh
        (2) Edit hook: drop Check A (lines 56-97); fix Check B glob to `[0-9]+-.*\.md`;
            rename internal references; preserve hour-bucket idempotency + L-S108-1 marker pattern
        (3) Author scripts/hooks/firing-tests/project-md-adr-staleness-fire-test.sh (~150 LOC; 5 TCs)
        (4) Update .claude/settings.json Stop chain command path
        (5) Run companion firing-test → require 5/5 PASS
        (6) Run full firing-test suite regression → require zero regression vs S175 baseline 74/74
        (7) Production smoke against current state → expect GREEN (project.md just updated S175)
        (8) Document in D-038 status flip ACCEPTED-AND-SHIPPED + amendment trail

intent_classification_notes: |
  SCOPE-tier (not CHARTER) because:
  - No charter file edit (T8 cool-down still active)
  - No constitution write (M-S173-1 deny holds)
  - No invariant change
  - Pure hook bug-fix + rename + firing-test; matches existing Phase 3.5 §HH-G/§HH-C pattern
  Q-B2 ratification: S175 checkpoint NEXT ACTION explicitly authorized "Fix proposal D-038
  PROPOSED" as S176 deliverable. S177 IMPL is execution under that scope. No new SCOPE/CHARTER
  ambiguity surfaces; autonomous-full mode applies; AskUserQuestion NOT required.

risks:
  - risk: "git mv loses blame chain at file boundary"
    mitigation: "git mv preserves history via --follow; document rename in commit message; not committing this turn (T8 cool-down) so risk deferred to next user-explicit commit"
  - risk: "settings.json path update could mistype and unwire the hook"
    mitigation: "S177 IMPL must run firing-test post-edit + verify hook fires in next .session-hooks.log"
  - risk: "Companion firing-test on RED-state could create stale marker that masks real Stop fires"
    mitigation: "firing-test uses isolated $TMPDIR fixtures + cleans up; never touches real agent-workspace/memory/. Pattern proven across 74/74 firing-test suite."
  - risk: "Retiring Check A loses the phase-mismatch signal at Stop cadence"
    mitigation: "phase-status-coherence covers same scope at UserPromptSubmit cadence (per-prompt) with stronger 3-sub-check semantics. Stronger replacement, not regression."

verification:
  pre_impl:
    - "Read S175 D-037 to confirm phase-status-coherence Check A coverage"
    - "Read S171 M-S171-1 to confirm prevention-rule-3 escape doctrine codified"
    - "Read Phase 3.5 plan §T7 firing-test pattern + §HH-G empirical-firing exemplar"
  post_impl:
    - "5/5 companion firing-test PASS"
    - "Full firing-test suite regression PASS (≥75/75 = 74 baseline + 1 new for project-md-adr-staleness)"
    - "Production smoke against current state → expected GREEN (project.md fresh post-S175)"
    - "Old hook filename absent from .claude/settings.json"
    - "New hook filename present in Stop chain"
    - ".session-hooks.log next Stop event shows new hook firing (or silent if WARN_COUNT=0)"

related_decisions:
  - D-037 (S175 M-S171-1 prevention hooks — phase-status-coherence covers Check A scope)
  - D-035 (S173 T6 harness-health-self-scan — HH-12 phase-drift signal at Stop+SessionStart cadence; complementary)
  - D-028 (S48d HH-C.4 CLAUDE.md § Session End ritual extension — context for HH-C.2 origin)
related_mistakes:
  - M-S176-1 NEW HIGH (this hook double-broken no-op)
  - M-S171-1 (sibling recurrence-class; file-pattern hook narrowness)
related_lessons:
  - L-S176-1 NEW HIGH (file-pattern hooks MUST validate against real-state inventory + ship firing-test)

end_of_adr: |
  Status flipped PROPOSED → ACCEPTED-AND-SHIPPED at S177 (2026-05-07).
  S177 IMPL outcomes:
    - git mv scripts/hooks/project-md-staleness-check.sh → project-md-adr-staleness.sh DONE (preserves history)
    - git mv scripts/hooks/firing-tests/project-md-staleness-check-fire-test.sh → project-md-adr-staleness-fire-test.sh DONE
    - Hook content rewritten: Check A dropped; Check B glob fixed to `[0-9][0-9][0-9]-*.md` primary + `D-*.md` backward-compat; cache file added for testability; cleanup-stale-markers loop extended to also drop legacy `.project-md-staleness-fired-*` markers
    - Companion firing-test rewritten: 7 TCs / 18 assertions; per L-S176-1 uses REAL-STATE-DERIVED fixtures (NNN-*.md primary in TC4 + D-*.md backward-compat in TC5)
    - Companion firing-test 18/18 PASS
    - Full firing-test suite regression 75/75 PASS (74 baseline + 1 new for project-md-adr-staleness)
    - .claude/settings.json Stop chain command path updated
    - CLAUDE.md line 57 reference updated: `project-md-staleness-check.sh` → `phase-status-coherence.sh` (UserPromptSubmit cadence) + `project-md-adr-staleness.sh` (Stop cadence; D-038 retired Check A from latter)
    - Production smoke real-state: state=GREEN delta_hours=0.0 newest_adr=038-S176-HH-C2-...md (REAL NNN-*.md detected)
  No charter file edit (T8 cool-down). No constitution write (M-S173-1 deny). No git commits.
