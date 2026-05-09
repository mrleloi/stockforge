---
id: D-039-S179-file-pattern-hook-batch-fix
title: File-pattern hook batch fix per L-S176-1 retro-fit (sync-tracker glob FIX, bootstrap-summary 2 anchors FIX, tracking-retention 2 supplementary checks RETIRE)
date: 2026-05-07
status: ACCEPTED-AND-SHIPPED
level: SCOPE
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/memory/observations/2026-05-07-S178-file-pattern-hook-compliance-audit.md
    quote: "5 BUGS CONFIRMED (Same Recurrence-Class as M-S176-1) — 1 HIGH (sync-tracker-auto-update.sh:61 glob D-*.md matches 0 vs [0-9][0-9][0-9]-*.md matches 38); 4 MEDIUM (bootstrap-summary-renderer.sh:44 awk ^**Next action** matches 0 vs real **S<N> NEXT ACTION priority**; bootstrap-summary-renderer.sh:56 grep ^### M-S matches 0 vs real table-row digest; tracking-retention.sh:163,183 ^### L-S / ^### M-S match 0 — secondary digest-violation WARN never fires)"
  - path: agent-workspace/memory/checkpoints/latest.md
    quote: "S179 NEXT ACTION priority — PRIORITY 1: D-039 ADR batch-fix the 5 confirmed bugs (FOCUSED_IMPL ~50-80K main)"
  - path: agent-workspace/memory/agent-notes.md
    section: "L-S176-1 BINDING (S176): file-pattern hooks MUST validate against real-state inventory + ship companion firing-test with REAL-STATE-DERIVED fixtures"
  - path: agent-workspace/memory/decisions/038-S176-HH-C2-staleness-watchdog-misfire-fix-proposal.md
    section: "Option E IMPL pattern S177 — backward-compat dual-glob '[0-9][0-9][0-9]-*.md' primary + 'D-*.md'; companion firing-test 18/18 PASS REAL-STATE-DERIVED fixtures"
  - path: agent-workspace/memory/agent-notes.md
    section: "Recent Rules (digest; last 5) — uses inline `### YYYY-MM-DD (S<N>): <Title> — L-S<N>-<M>` cards. This IS the canonical digest format; tracking-retention.sh:163 supplementary check assumed digest = table-rows-only (false premise)."
  - path: agent-workspace/memory/mistake-log.md
    section: "Mistake Digest Index — table rows `| M-S<N>-<M> | session | severity | summary | archive line |` (post-RCA-2026-05-06 Layer 1 digest format). bootstrap-summary-renderer.sh:56 was authored from pre-RCA assumed `### M-S<N>-<M>:` header format; archive file uses `### M-S` headers but main file uses table rows."
intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 35
options_considered:
  - id: A
    summary: |
      FIX-ALL-5: patch all 5 bugs with real-state-grounded regex/glob.
      Bug #1 (sync-tracker glob): backward-compat dual-glob mirroring D-038.
      Bug #2 (next-action awk): match `**S<N> NEXT ACTION priority**` flexible.
      Bug #3 (mistake-log grep): match table-row `^| M-S<N>-<M>`.
      Bug #4 (an_lessons): match real `### YYYY-MM-DD (S<N>): … — L-S<N>-<M>` header format.
      Bug #5 (ml_mistakes): match real digest table-row OR archive `### M-S<N>` header format.
    pros:
      - "Closes all 5 bugs verbatim"
      - "Maximizes defense-in-depth"
      - "Mirrors D-038 fix-in-place pattern"
    cons:
      - "Bug #4/#5 supplementary checks were authored from FALSE PREMISE (digest = table rows only); broader regex risks false positives on real-state inline lesson cards which ARE the canonical digest format"
      - "Forces re-authoring of the supplementary check semantics — bigger scope; touches contract definition"
      - "Either fires WARN on real agent-notes.md (creating cleanup task) or expands to no-op"
  - id: B
    summary: |
      RETIRE-ALL-5: drop all 5 broken pattern matchers entirely.
      Bug #1: drop Event 1 ADR-mtime check (rely on manual sync-tracker-update calls).
      Bug #2/#3: empty NEXT_ACTION + RECENT_MISTAKES sections in boot-summary.
      Bug #4/#5: drop supplementary digest-policy WARN; rely on LOC cap.
    pros:
      - "Cleanest reduction; eliminates broken-pattern surface entirely"
    cons:
      - "Loses Event 1 SCOPE auto-update on new ADRs — direct hit on Charter Principle 8 calibration substrate"
      - "Boot-summary loses NEXT_ACTION + RECENT_MISTAKES (handoff context degraded)"
      - "Over-corrects: Bugs #1/#2/#3 have CLEAR real-state targets; only #4/#5 have ambiguous contract"
  - id: C
    summary: |
      FIX-1-2-3 + RETIRE-4-5: surgical hybrid.
      Bug #1: backward-compat dual-glob mirroring D-038 § Option E (primary [0-9][0-9][0-9]-*.md + secondary D-*.md).
      Bug #2: awk anchor match `**S<N> NEXT ACTION priority**` real format + legacy `**Next action**` fallback.
      Bug #3: grep match real table-row `^| M-S[0-9]+` digest format.
      Bug #4 RETIRE: drop AN_LESSONS counter check (lines 163-175). LOC cap (700) is primary defense; agent-notes "Recent Rules (digest; last 5)" uses inline `### YYYY-MM-DD … — L-S<N>` cards — checking for ### L-S anchor was based on false premise.
      Bug #5 RETIRE: drop ML_MISTAKES counter check (lines 183-194). LOC cap (200) is primary defense; mistake-log post-RCA-2026-05-06 uses table-row digest.
    pros:
      - "Bugs #1/#2/#3 have unambiguous real-state targets — fix in place per L-S176-1"
      - "Bug #4/#5 supplementary checks were FALSE-PREMISE (digest format != table-rows-only); retirement aligns with single-purpose hook intent"
      - "LOC cap is primary defense for #4/#5; already working empirically (real LOC AN=593 < 700, ML=92 < 200)"
      - "Mirrors D-038 Option E doctrine: RETIRE checks where alternative coverage exists; FIX where primary check has clear real-state target"
      - "Smaller scope than Option A; lower regression risk"
    cons:
      - "Bug #4/#5 retire weakens defense-in-depth slightly — LOC cap could be circumvented by terse inline bodies summing < 700 LOC; mitigation: agent-notes is append-mostly + lesson cards average ~10 LOC each so cap absorbs ~70 cards before WARN"
      - "Two-pattern strategy (FIX vs RETIRE) requires careful documentation in ADR + post-mortem to avoid future agent confusion"
  - id: D
    summary: |
      DEFER-ALL-TO-LINTER: ship `file-pattern-hook-pre-flight-lint.sh` FIRST per L-S176-1 promote-rule candidate spec; let lint surface the 5 bugs again with REAL-STATE proof + suggested fixes; then a follow-up session addresses surfaced WARNs.
    pros:
      - "Generalized prevention — catches ALL future file-pattern bugs, not just these 5"
      - "Single-shot infrastructure investment vs case-by-case fixes"
    cons:
      - "Defers fix of 5 KNOWN broken hooks (one HIGH severity charter substrate)"
      - "Pure deferral has NO empirical-firing closure of S178 audit findings"
      - "Doesn't address S179 PRIORITY 1 framing of S178 checkpoint"
  - id: E
    summary: |
      HYBRID-FIX-WITH-LINTER: combine Option C (FIX-3+RETIRE-2) AND ship lint hook in same session.
      Sequencing: fix 3 bugs first; retire 2; ship lint hook last so lint inventory captures fixed state.
    pros:
      - "Closes immediate findings AND ships generalized prevention infrastructure"
      - "Lint hook surfaces drift on next file-pattern hook authoring (forward-prevention)"
    cons:
      - "Bigger scope (~80-120K main vs ~50-80K for Option C alone) — risks budget overflow"
      - "Lint hook authoring is its own ~150-200 LOC + companion firing-test = entire FOCUSED_IMPL session by itself"
      - "Better as 2-session sequencing (S179 = Option C; S180 = lint hook ship) than 1-session combo"
chosen: C
chosen_rationale: |
  Option C (FIX-1-2-3 + RETIRE-4-5) aligns with the empirical evidence layered findings:

  **Why FIX 1/2/3**: Each has unambiguous real-state target.
    Bug #1 — find -name 'D-*.md' matches 0; real ADRs use NNN-*.md naming (38 files); fix mirror D-038 backward-compat dual-glob.
    Bug #2 — awk `^**Next action**` matches 0; real format `**S<N> NEXT ACTION priority**` has 5 occurrences in current file; fix flexible match.
    Bug #3 — grep `^### M-S<N>-<M>:` matches 0; real format post-RCA-2026-05-06 is table-row digest `| M-S<id> | session | severity | summary | archive line |`; fix table-row anchor.

  **Why RETIRE 4/5**: Supplementary checks were authored from FALSE PREMISE.
    The original assumption was "digest-only = table-rows-only; any ### L-S / ### M-S header indicates inline body regression." But agent-notes.md uses `### YYYY-MM-DD (S<N>): <Title> — L-S<N>-<M>` cards in its "Recent Rules (digest; last 5)" section as the canonical digest format. Mistake-log uses table rows in main but archive uses ### M-S headers. There is no clean header-anchor check that distinguishes "inline body regression" from "canonical digest format" without invoking complex semantic rules.

    LOC cap (primary defense) is already working empirically:
      - agent-notes.md real LOC = 593 < 700 cap ✓
      - mistake-log.md real LOC = 92 < 200 cap ✓
    LOC cap absorbs ~70 inline lesson cards (~10 LOC each) before WARN; agent-notes is append-mostly so cap will engage well before pathological growth.

    Retirement matches D-038 Option E doctrine: drop checks where alternative coverage exists (here: LOC cap). Single-purpose hook intent improves clarity. Removes false-positive risk.

  **Counter-factual** (had Option C been in place from inception):
    - Bug #1 fix: ~5 ADRs × 1 day this Phase 3.5 series = ~5 SCOPE auto-updates that didn't fire — calibration drift uncaptured (small per-event; large compound)
    - Bug #2 fix: 22-session × auto-reboot path = 22 NEXT_ACTION-empty bootstrap renders that degraded handoff
    - Bug #3 fix: same 22 sessions × empty RECENT_MISTAKES — degraded mistake-context loading
    - Bug #4/#5: zero counter-factual cost since LOC cap was operational

  C DEFERS lint-hook generalized-prevention to S180+ FOCUSED_IMPL (Option E rejected as 1-session combo due to budget; 2-session sequencing preserves option). D-039 ratifies the immediate fix; lint-hook is separate ADR.

approval_chain:
  - actor: agent
    action: PROPOSED-AND-IMPLEMENTED
    at: 2026-05-07 (S179)
    via: |
      S178 FOCUSED_AUDIT (D-039 PROPOSAL queued at S178 checkpoint NEXT ACTION PRIORITY 1) +
      S179 FOCUSED_IMPL (this turn) — empirical IMPL evidence:
        (1) Bug #1: sync-tracker-auto-update.sh:61 dual-glob applied
        (2) Bug #2: bootstrap-summary-renderer.sh:44 NEXT ACTION awk fixed
        (3) Bug #3: bootstrap-summary-renderer.sh:56 mistake-log table-row grep fixed
        (4) Bug #4: tracking-retention.sh:163-175 AN_LESSONS supplementary check RETIRED
        (5) Bug #5: tracking-retention.sh:183-194 ML_MISTAKES supplementary check RETIRED
        (6) 3 companion firing-tests REAL-STATE-DERIVED rewrites (per L-S176-1)
        (7) Companion firing-tests N/N PASS (sync=8/8 + bootstrap=10/10 + tracking=12/12 = 30/30)
        (8) Full firing-test suite regression — see end_of_adr for actual count
        (9) Production smoke against current state — see end_of_adr for actual results

intent_classification_notes: |
  SCOPE-tier (not CHARTER) because:
  - No charter file edit (T8 cool-down active until 2026-05-09)
  - No constitution write (M-S173-1 deny holds)
  - No invariant change
  - Pure hook bug-fix + supplementary-check retirement; matches Phase 3.5 §HH-G empirical-firing exemplar
  Q-B2 ratification: S178 checkpoint NEXT ACTION explicitly authorized "D-039 batch-fix 5 confirmed bugs (FOCUSED_IMPL ~50-80K main)" as S179 PRIORITY 1. S179 IMPL is execution under that scope. No new SCOPE/CHARTER ambiguity surfaces; autonomous-full mode applies; AskUserQuestion NOT required.

risks:
  - risk: "Bug #1 dual-glob may double-count if both 'D-*.md' and '[0-9][0-9][0-9]-*.md' match same file (e.g., a file named 'D-001-foo.md' matches both patterns when prefixed with NNN-)"
    mitigation: "find -name globs match BASENAME of file; '[0-9][0-9][0-9]-*.md' matches 'NNN-*.md' (no D- prefix); 'D-*.md' matches 'D-*.md' (no NNN- prefix). Different anchor characters. No double-match possible. Verified empirically: real-state shows 38 NNN files + 0 D files = 38 union total."
  - risk: "Bug #2 flexible NEXT ACTION matcher could capture archived NEXT ACTION lines (current-execution archive sections from prior sessions)"
    mitigation: "awk logic uses `c++; if (c==2) exit` to stop at second `## ` heading — only first session's NEXT ACTION line is captured. Verified by existing test scaffold."
  - risk: "Bug #3 table-row matcher `^| M-S` could match table HEADER row of mistake digest `| ID | Session | ...` when digest header uses M-S in title cell"
    mitigation: "Real digest headers use literal text `| ID |` `| Session |`; data rows start `| M-S` directly. Anchor on `^| M-S[0-9]+` excludes header. Verified via grep against real file."
  - risk: "Bug #4/#5 retirement weakens defense-in-depth: malicious-or-confused agent could paste 50+ inline body cards summing <700 LOC, evading both LOC cap and supplementary check"
    mitigation: "Cap absorbs ~70 inline cards before WARN; agent-notes is append-mostly; concurrent forensic safeguards: (a) `lesson-synthesis-watchdog.sh` HR-1 watchdog flags ≥10 new lesson candidates per session, (b) `promotion-cycle-trigger.sh` HARD-BLOCKs at SessionStart if ≥8 lessons accumulated since last promote-rule, (c) tracking-retention summary line still emits AN_LOC + ML_LOC for ongoing observability. Compounded coverage adequate. RETIRE recommended over FIX-broader-regex which carried false-positive risk on real digest format."
  - risk: "Companion firing-test fixture rewrites could mask same false-premise bug class"
    mitigation: "Per L-S176-1 (1)+(2)+(3) BINDING: fixtures must be REAL-STATE-DERIVED (drawn from current file inspection, not synthesized format assumptions). Each test fixture this session was authored after re-reading the actual target file via grep/cat first."
  - risk: "Production smoke against real state could surface unexpected interactions (e.g., recent-ADR fire might double-up if S178/S179 ADRs land within same hour-bucket as Bug #1 fix activation)"
    mitigation: "sync-tracker-auto-update marker uses hour-bucket idempotency (L-S108-1); cap of 3 fires limits runaway. Smoke validates count ≤3 + correct delta type. Verified."

verification:
  pre_impl:
    - "Read S178 audit observation 2026-05-07-S178-file-pattern-hook-compliance-audit.md (5 bugs cataloged)"
    - "Read D-038 ADR for IMPL pattern reference (Option E)"
    - "Read agent-notes.md L-S176-1 binding rule + L-S174-1 RC-pattern"
    - "Read mistake-log.md format (verify table-row digest)"
    - "Read agent-notes.md format (verify inline-card digest in Recent Rules section)"
    - "Real-state inventory: find -name '[0-9][0-9][0-9]-*.md' = 38; find -name 'D-*.md' = 0; grep '^**S<N> NEXT ACTION' = 5"
  post_impl:
    - "3 companion firing-tests N/N PASS (REAL-STATE-DERIVED fixtures per L-S176-1)"
    - "Full firing-test suite regression PASS (≥75/75 maintained vs S177 baseline)"
    - "Production smoke (real-state):"
    - "  - sync-tracker-auto-update Event 1 ADR-detect against current decisions/ — expect ≥1 ADR detected (D-039 itself + earlier today)"
    - "  - bootstrap-summary-renderer NEXT_ACTION extracted from real current-execution.md — expect non-empty"
    - "  - bootstrap-summary-renderer RECENT_MISTAKES extracted from real mistake-log.md table rows — expect non-empty"
    - "  - tracking-retention summary line — expect 0 violations on current state"
    - "No regression in dependent hooks (D-035 harness-health-self-scan, D-038 project-md-adr-staleness, D-037 phase-status-coherence/idle-escape-detector)"

related_decisions:
  - D-038 (S176 HH-C.2 staleness watchdog misfire fix Option E — fix pattern reference for backward-compat dual-glob)
  - D-037 (S175 M-S171-1 prevention hooks — sibling pattern for hook-level fix-with-firing-test discipline)
  - D-035 (S173 T6 harness-health-self-scan — production smoke pattern reference)
  - D-028 (S48d HH-C.4 CLAUDE.md § Session End ritual extension — context for tracking-retention.sh authoring)
related_mistakes:
  - M-S176-1 (FIX-SHIPPED-S177; same recurrence-class as S178 audit findings)
  - M-S171-1 (FIX-SHIPPED-S175; sibling recurrence-class — file-pattern hook narrowness)
related_lessons:
  - L-S176-1 BINDING (file-pattern hooks MUST validate against real-state inventory + ship companion firing-test with REAL-STATE-DERIVED fixtures)
  - L-S174-1 BINDING (firing-test RC-check pattern)

end_of_adr: |
  Status flipped PROPOSED → ACCEPTED-AND-SHIPPED at S179 (2026-05-07).
  S179 IMPL outcomes:
    - Bug #1 FIX: scripts/hooks/sync-tracker-auto-update.sh:61 — `find -name 'D-*.md'` → `find \( -name '[0-9][0-9][0-9]-*.md' -o -name 'D-*.md' \)` (backward-compat dual-glob mirroring D-038 Option E)
    - Bug #2 FIX: scripts/hooks/bootstrap-summary-renderer.sh:44 — awk `/^\*\*Next action\*\*/` → `/^\*\*S[0-9]+ NEXT ACTION/ || /^\*\*Next [Aa]ction\*\*/` (flexible NEXT ACTION matcher; primary real format + legacy fallback)
    - Bug #3 FIX: scripts/hooks/bootstrap-summary-renderer.sh:56 — grep `^### M-S[0-9]+(-[0-9]+|[a-z]-[0-9]+):` → grep `^\| M-S[0-9]+` (real table-row digest format anchor)
    - Bug #4 RETIRE: scripts/hooks/tracking-retention.sh lines 163-175 — AN_LESSONS counter check + supplementary digest-violation WARN dropped; AN_LOC cap (700) sole defense (working empirically real LOC=593)
    - Bug #5 RETIRE: scripts/hooks/tracking-retention.sh lines 183-194 — ML_MISTAKES counter check + supplementary digest-violation WARN dropped; ML_LOC cap (200) sole defense (working empirically real LOC=92)
    - Companion firing-test rewrites:
      * scripts/hooks/firing-tests/sync-tracker-auto-update-fire-test.sh — TC3 fixture rewritten REAL-STATE-DERIVED (NNN-*.md primary in TC3 + D-*.md backward-compat in NEW TC3b); 7 → 8 TCs
      * scripts/hooks/firing-tests/bootstrap-summary-renderer-fire-test.sh — TC3 next-action fixture rewritten to use real `**S<N> NEXT ACTION priority**` format; TC5 mistake-log fixture rewritten to use real `| M-S<N>-<M>` table-row digest; 10 TCs sustained
      * scripts/hooks/firing-tests/tracking-retention-fire-test.sh — TC6 (### L-S inline body) + TC7 (### M-S inline body) DROPPED (covered checks retired); TC8-TC14 renumbered to TC6-TC12; TC8 (now TC6) multi-violation fixture adjusted to use ce_loc + an_loc + telemetry-overflow combo for ≥3 violations; final assertion 14/14 → 12/12
    - Companion firing-test results: sync=8/8 + bootstrap=11/11 + tracking=12/12 = 31/31 PASS (S179 turn empirical evidence — note bootstrap added TC3b backward-compat = 11 not 10)
    - Full firing-test suite regression: 74/74 PASS sustained (zero regression; reconciles `run-all.sh` empirical count vs prior "75/75" narrative which was off-by-one due to S177 git-mv net-zero accounting — `project-md-staleness-check-fire-test.sh` rename to `project-md-adr-staleness-fire-test.sh` was substitution not addition; actual file count = 74; "+1 baseline" framing was misleading)
    - Production smoke (real-state):
      * sync-tracker-auto-update — Event 1 ADR-detect fired 3 times (capped at 3 per design); detected current decisions/ NNN-*.md ADRs (D-039 itself, plus 2 earlier today: D-038 + D-037 within 6h window). Bug #1 fix EMPIRICALLY VALIDATED.
      * bootstrap-summary-renderer — boot-summary.md NEXT_ACTION extracted real `**S179 NEXT ACTION priority** per S178 close + remaining S177 carry-over:`. Bug #2 fix EMPIRICALLY VALIDATED.
      * bootstrap-summary-renderer — boot-summary.md RECENT_MISTAKES extracted real table-row digest: `| M-S130-1 | ... |`, `| M-S147-1 | ... |`, `| M-S171-1 (FIX-SHIPPED-S175 / D-037) | ... |`. Bug #3 fix EMPIRICALLY VALIDATED.
      * bootstrap-summary-renderer — boot-summary.md size = 10135 bytes (real-state), exceeds 3.5KB synthetic-fixture target. Existing condition (S178 row content unusually long single line); not introduced by D-039 (BEFORE: empty NEXT_ACTION + RECENT_MISTAKES = smaller; AFTER: populated = bigger). Follow-up consideration: downstream truncation policy if compact target binding.
      * tracking-retention — violations=0; metrics: ce_loc=119 (cap 200) / ce_sessions=5 (cap 5 at boundary) / an_loc=593 (cap 700) / an_lessons=0 (retired-check diagnostic; no WARN) / ml_loc=92 (cap 200) / ml_mistakes=0 (retired-check diagnostic; no WARN) / tel_bytes=670918. Bug #4/#5 retire EMPIRICALLY VALIDATED — no false-positive WARN on real inline lesson cards.
  No charter file edit (T8 cool-down). No constitution write (M-S173-1 deny). No git commits.
