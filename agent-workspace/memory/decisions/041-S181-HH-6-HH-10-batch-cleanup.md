---
id: D-041-S181-HH-6-HH-10-batch-cleanup
title: S181 HH-6 dispatch-pending sidecar sweep + HH-10 6 companion firing-tests batch ship
date: 2026-05-07
status: ACCEPTED-AND-SHIPPED
level: SCOPE
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/memory/checkpoints/latest.md
    quote: "S181 NEXT = HH-6 dispatch-pending JSONL stale=6 cleanup + HH-10 firing-test orphans=6 cleanup (mechanical ~30K main)"
  - path: scripts/hooks/harness-health-self-scan.sh
    section: "HH6_check (lines 122-142): files older than 2hr AND last-line `\"state\":\"pending\"` → MEDIUM at ≥1, HIGH at ≥3; HH10_check (lines 204-218): hooks_dir/*.sh without firing-tests/<name>-fire-test.sh → MEDIUM at >2 orphans"
  - path: scripts/hooks/dispatch-jsonl-recorder.sh
    section: "lines 109-111 per-session sidecar contract `.dispatch-pending-${PARENT_SID}.jsonl`; FIFO matching against dispatch.jsonl per HH-B.1 (S109)"
  - path: scripts/hooks/dispatch-jsonl-backfill.sh
    section: "lines 14-15 docstring `Usage: bash dispatch-jsonl-backfill.sh [--project-dir <dir>] [--dry-run]`; one-shot CLI utility recovering agent_type+model from sidecars + observation filenames + .claude/agents/<type>.md frontmatter"
  - path: agent-workspace/memory/observations/2026-05-07-S178-file-pattern-hook-compliance-audit.md
    section: "HH-10 orphan refinement: real count = 6 hooks without firing-test — diagnostic-pretooluse-stash + diagnostic-subagentstop-stash + redact-secrets + same-commit-rule + subagent-budget-classifier + dispatch-jsonl-backfill"
  - path: agent-workspace/memory/agent-notes.md
    section: "L-S176-1 BINDING (S176): file-pattern hooks MUST validate against real-state inventory + ship companion firing-test with REAL-STATE-DERIVED fixtures"
intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  affects_invariant: false
  urgency: NORMAL
  complexity_score: 25
context: |
  Two harness-health signals carried RED-2 state since S173 production smoke:
  HH-6 stale=6 (HIGH at ≥3) + HH-10 orphans=6 (MEDIUM at >2). S180 checkpoint
  ratified S181 PRIORITY 1 = "HH-6 dispatch-pending JSONL stale=6 cleanup +
  HH-10 firing-test orphans=6 cleanup (mechanical ~30K main)". Both signals
  block HH state from regressing to GREEN after Phase 3.5 T6 hook went live.

  HH-6 root cause: dispatch-jsonl-recorder.sh creates per-session sidecar
  `.dispatch-pending-${SID}.jsonl` at PreToolUse(Agent); SubagentStop FIFO-flips
  via dispatch.jsonl. When return hook misses (Windows quirk M-S49b-1, transcript
  parse error, or pre-S109 legacy), state="pending" never flips and sidecar
  outlives session. Empirically: 26 sidecar files on disk (Apr 29-May 6 mtimes;
  oldest 8 days; newest yesterday); 6 of those have last-line `"state":"pending"`
  → HH-6 stale=6.

  HH-10 root cause: 6 hooks shipped pre-Phase-3.5 without companion firing-tests.
  Phase 3.5 Hard Rule #2 (every hook ships with firing-test) was codified at
  Plan 010-S50; pre-existing hooks need retro-fit. S178 audit refined orphan
  count via set-difference between `scripts/hooks/*.sh` and
  `scripts/hooks/firing-tests/*-fire-test.sh`. None of the 6 orphan hooks are
  wired in `.claude/settings.json` (verified S181); they are utilities
  (redact-secrets), one-shot CLIs (dispatch-jsonl-backfill), pre-commit hooks
  (same-commit-rule), PostToolUse-meant-for (subagent-budget-classifier), or
  ephemeral diagnostic stash (2 stashes ported verbatim from orch v2.2.0).

decision: |
  MULTI-TASK IMPL S181 — ship BOTH:

  **Task A (HH-6 cleanup)**: Run `dispatch-jsonl-backfill.sh` (no --dry-run) to
  preserve agent_type/model recovery info → 18 of 213 dispatch.jsonl rows
  recovered (10% rate); .backfill-backup-20260507101244 written (59635 bytes).
  Then `rm agent-workspace/memory/.dispatch-pending-*.jsonl` (all 26 sidecars
  deleted; gitignored — no version control concern; per dispatch-jsonl-recorder
  per-session contract, all are dead-session leftovers). Empirical post-state:
  HH-6 stale=0 reproduced via inline watchdog logic.

  **Task B (HH-10 fix)**: Author 6 companion firing-tests REAL-STATE-DERIVED per
  L-S176-1, sandboxed via mktemp -d per L-S174-1 RC-pattern, exit 0 only on
  full PASS:
  - `diagnostic-pretooluse-stash-fire-test.sh` 4 TCs (empty-stdin no-op /
    stdin verbatim write / stdout passthrough / auto-mkdir)
  - `diagnostic-subagentstop-stash-fire-test.sh` 4 TCs (same template)
  - `redact-secrets-fire-test.sh` 10 TCs (anthropic / openai / google / aws /
    bearer / jwt / db-conn-redacted / db-original-removed / clean-text-unchanged
    + leaked-original assertions)
  - `same-commit-rule-fire-test.sh` 6 TCs (empty-staged no-op / charter-only OK
    / code-without-spec WARN / both-staged OK / strict-mode BLOCK / spec-only INFO)
  - `subagent-budget-classifier-fire-test.sh` 6 TCs (empty-prompt no-op /
    zero-tokens no-op / spec-frame within-env / pure-plan overshoot WARN /
    verifier-whole-phase / general-purpose default)
  - `dispatch-jsonl-backfill-fire-test.sh` 5 TCs (missing-dispatch INFO /
    empty-dispatch dryrun / sidecar-recovery dryrun / actual-run creates backup /
    model-resolution from agents/<type>.md frontmatter)

  Total NEW: 35 TCs across 6 files. Full firing-test suite 75 → 81 PASS
  (zero regression; elapsed 231s).

options_considered:
  - id: A
    summary: "Conservative — delete only 6 HH-6 stale sidecars; defer 20 leftover legacy + write only 3 high-value firing-tests"
    pros:
      - "Minimal scope per checkpoint phrasing 'stale=6 cleanup'"
      - "~30K main turn budget"
    cons:
      - "20 legacy-format sidecars (pre-S109; predate L-S108-1) remain as rot"
      - "HH-10 orphans=3 still triggers MEDIUM at >2 — only partially closes signal"
  - id: B
    summary: "Aggressive — delete all 26 sidecars without backfill + write all 6 firing-tests"
    pros:
      - "Both signals GREEN immediately"
      - "Single-session close"
    cons:
      - "Loses 18 recoverable dispatch.jsonl rows (sidecar→agent_type cross-ref) — never re-runnable"
  - id: C
    summary: "Run-backfill-then-clean-sweep + full 6 firing-tests (CHOSEN)"
    pros:
      - "Preserves recovery info via .backfill-backup file before deletion"
      - "Both HH-6 and HH-10 GREEN via canonical fix"
      - "Phase 3.5 Hard Rule #2 fully retro-fit for pre-existing hooks"
    cons:
      - "~60-90K main turn (MULTI-TASK IMPL envelope 150-250K; on-target low-mid)"
      - "Diagnostic stash hooks get firing-tests despite being on-demand-only utilities"
  - id: D
    summary: "Move 2 trivial diagnostic stashes to scripts/diagnostics/ + write 4 firing-tests"
    pros:
      - "Preserves utility while exiting HH-10 scan scope"
      - "Cleaner separation of production hooks vs on-demand diagnostics"
    cons:
      - "Requires dir restructure + .claude/settings.json reference updates if any"
      - "Future-fragility: any hook moved to diagnostics/ could be missed by audits"

chosen: C
chosen_rationale: |
  Option C optimizes signal-clearance + harness integrity. Backfill first
  preserves the 18-row recovery dataset (one-shot CLI never re-runnable post
  sidecar deletion). Full 6 firing-tests fully retro-fit Phase 3.5 Hard Rule #2
  even for trivial diagnostic stashes — establishes single discipline rule for
  future contributors (no carve-out exception). On-target budget for MULTI-TASK
  IMPL (~60-90K) acceptable per harness_priority_one preemption doctrine.
  Sacrifices: ~70 LOC × 2 = 140 LOC of test code for ~13-LOC stash hooks
  (test-to-code ratio 5x); accepted as discipline cost.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-07
    via: agent-workspace/memory/sessions/2026-05-07-session-181.md
  - actor: agent
    action: ACCEPTED-AND-SHIPPED
    at: 2026-05-07
    via: S180 checkpoint NEXT ACTION ratification (PRIORITY 1 mechanical cleanup; SCOPE-tier autonomous-full per autonomous_continue_no_self_pause)

verified_by:
  - mechanism: smoke-test
    at: 2026-05-07
    result: PASS
    detail: "HH-6 watchdog inline logic post-cleanup stale=0 (was 6); HH-10 watchdog inline logic post-fix orphans=0 (was 6); harness-health-self-scan run on real project state=RED-1 (HH-6+HH-10 both eliminated; remaining HH-2 USERPROMPT-NOT-FIRING + HH-9 MISTAKE-LOG-UNFRESH are pre-existing carry-overs)"
  - mechanism: firing-test
    at: 2026-05-07
    result: PASS
    detail: "6 NEW firing-tests 35/35 TCs PASS individually; full firing-test suite 81/81 PASS elapsed 231s (was 75; +6 new = 81; zero regression)"
  - mechanism: backfill-cli-recovery
    at: 2026-05-07
    result: PASS
    detail: ".backfill-backup-20260507101244 written 59635B; 18 of 186 candidates recovered (10% rate); dispatch.jsonl updated; sidecar deletion safe post-backup"

affects:
  charter: false
  spec_files: []
  code_paths:
    - scripts/hooks/firing-tests/diagnostic-pretooluse-stash-fire-test.sh
    - scripts/hooks/firing-tests/diagnostic-subagentstop-stash-fire-test.sh
    - scripts/hooks/firing-tests/redact-secrets-fire-test.sh
    - scripts/hooks/firing-tests/same-commit-rule-fire-test.sh
    - scripts/hooks/firing-tests/subagent-budget-classifier-fire-test.sh
    - scripts/hooks/firing-tests/dispatch-jsonl-backfill-fire-test.sh
  config_files: []
  data_files:
    - agent-workspace/memory/.dispatch-pending-*.jsonl  # 26 deleted
    - agent-workspace/memory/dispatch.jsonl  # 18 rows recovered
    - agent-workspace/memory/dispatch.jsonl.backfill-backup-20260507101244  # NEW backup
  other_decisions:
    - D-035-S173-T6-harness-health-self-scan  # signals HH-6 + HH-10 from this hook now flip GREEN
    - D-040-S180-renderer-trim-and-file-pattern-lint-ship  # Phase 3.5 Hard Rule #2 retro-fit pattern continued

depends_on:
  - D-035-S173-T6-harness-health-self-scan  # provides the HH-6/HH-10 watchdog logic this decision quiets

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A — ACCEPTED-AND-SHIPPED in single S181 turn.

tags: ["phase-3.5", "harness-health", "HH-6", "HH-10", "firing-test", "L-S176-1-retrofit", "cleanup", "mechanical"]
---

# Decision 041 — S181 HH-6 dispatch-pending sidecar sweep + HH-10 6 companion firing-tests batch ship

## Context

Per S180 checkpoint NEXT ACTION + S178 audit findings:

- HH-6 dispatch-pending JSONL signal RED-2 since S173 (stale=6 → HIGH severity per `harness-health-self-scan.sh:137-141`)
- HH-10 firing-test orphan signal MEDIUM since S173 (orphans=6 refined at S178 audit; threshold >2)

Both signals stem from gaps that pre-existed Phase 3.5 entry (S50). S180 deferred this PRIORITY 1 in favor of higher-leverage MULTI-TASK IMPL (boot-summary trim + lint hook ship). S181 closes both gaps.

## Analysis

**HH-6 dispatch-pending sidecars** — empirical inventory:

| Format | Count | Schema | Recovery |
|---|---|---|---|
| Pre-S109 legacy (pre-L-S108-1 fix) | ~18 | No `state` / `parent_session_id` fields | Sidecar→agent_type cross-ref via dispatch_id |
| Post-S109 modern | ~8 | Has `state="pending"` + `parent_session_id` + `ts_ms` | Same |
| **Total** | **26** | All gitignored | All from dead sessions (no current-session match) |

Of the 26 files, 6 had last-line `"state":"pending"` (matching HH-6 watchdog logic) — confirming the 6-stale count from S180 checkpoint. The other 20 are legacy or completed-but-unflipped (silent orphans).

**HH-10 orphan hooks** — set-difference scan:

| Hook | Wired in settings.json? | Scope | Recommendation |
|---|---|---|---|
| diagnostic-pretooluse-stash | NO | 16 LOC stdin passthrough; ephemeral diagnostic | Companion firing-test 4 TCs (writes file, echoes stdin, auto-mkdir) |
| diagnostic-subagentstop-stash | NO | 16 LOC stdin passthrough; ephemeral diagnostic | Same template 4 TCs |
| redact-secrets | NO (utility) | 60 LOC regex redactor; security-critical | 10 TCs (each pattern type + clean text + leak verification) |
| same-commit-rule | NO (pre-commit role) | 57 LOC spec↔code coupling gate | 6 TCs (no-op / charter / warn / both / strict / spec-only) |
| subagent-budget-classifier | NO (PostToolUse-meant) | 68 LOC token-budget warner | 6 TCs (each kind + overshoot WARN + no-op guards) |
| dispatch-jsonl-backfill | NO (one-shot CLI) | 212 LOC recovery utility | 5 TCs (missing / empty-dryrun / sidecar-recovery / actual-run-backup / model-resolve) |

**Recovery decision** — `dispatch-jsonl-backfill.sh` is a one-shot CLI that uses `.dispatch-pending-*.jsonl` files as a recovery source for `dispatch.jsonl` rows with `agent_type="unknown-agent"`. Dry-run preview: 18 of 186 candidates recoverable (10% rate). Deleting sidecars before running backfill loses recovery permanently → must run backfill first.

## Decision

Combined ship in single S181 turn (Option C):

1. Run `dispatch-jsonl-backfill.sh` (no --dry-run) → creates `.backfill-backup-20260507101244` + updates dispatch.jsonl (18 rows recovered)
2. `rm agent-workspace/memory/.dispatch-pending-*.jsonl` → all 26 sidecars deleted
3. Author 6 companion firing-tests sandboxed via mktemp -d, REAL-STATE-DERIVED per L-S176-1, exit 0 only on full PASS
4. Run full firing-test suite via `run-all.sh` → expect 75 → 81 PASS

### What this means concretely

- HH-6 watchdog signal flips MEDIUM/HIGH → GREEN at next harness-health-self-scan run (verified inline)
- HH-10 watchdog signal flips MEDIUM → GREEN at next harness-health-self-scan run (verified inline)
- Phase 3.5 Hard Rule #2 retro-fit COMPLETE for all 6 pre-existing orphan hooks
- 18 historical dispatch.jsonl rows now carry recovered agent_type/model (Plan 011 D2 outcome empirically validated)
- Etl-queue-producer-fire-test.sh remains as 1 reverse-orphan (firing-test without parent hook); NOT counted by HH-10 (which only checks hook→test direction); legitimate multi-hook integration test exercising 3 etl-queue producers

### What does NOT change

- No charter file edits (T8 cool-down honored ≥2026-05-09)
- No constitution writes (M-S173-1 deny holds)
- No git commits (CLAUDE.md hard rule)
- No new lessons (clean execution following L-S176-1 + L-S174-1 + Phase 3.5 §HH-G empirical-firing exemplar)
- No new mistakes (recurrence-class M-S171-1 + M-S176-1 already capture the doctrine; S181 = retro-fit application not new pattern)

## Why (Reasons)

1. **Charter Principle 8 (Calibration over confidence)** — empirical signal-clearance via watchdog inline logic + firing-test suite + harness-health-self-scan re-run; not narrative claim
2. **Phase 3.5 Hard Rule #2 (every hook ships with companion firing-test)** — retro-fit completes pre-existing gap surfaced by S178 audit
3. **L-S176-1 BINDING** — fixtures REAL-STATE-DERIVED (production schema for sidecar JSONL, real ADR/agent file structures, real dispatch.jsonl event format)
4. **harness_priority_one** — closing harness signals before product work
5. **autonomous_continue_no_self_pause** — Mode-D / SCOPE-tier autonomous-full applies; checkpoint ratifies PRIORITY 1; no AskUserQuestion required

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Backfill data loss (sidecar deletion before backup) | Low | Pre-deletion `.backfill-backup-20260507101244` written; 18 rows recovered + cross-verified in dispatch.jsonl |
| Diagnostic-stash firing-test bloat (test 5x of source LOC) | Realized | Accepted as discipline cost; retro-fit consistency over per-hook cost optimization |
| HH-10 reverse-orphan (etl-queue-producer-fire-test.sh) misclassified | None | HH-10 logic only checks hook→test; reverse direction is informal observation only; integration test legitimate |
| Future Hard Rule #2 violations | Low | `file-pattern-hook-pre-flight-lint.sh` (D-040) catches NEW hook file-pattern signatures pre-flight; Phase 3.5 Hard Rule #2 binding for new hooks |

## Acceptance Record

- 2026-05-07: PROPOSED + ACCEPTED-AND-SHIPPED by Claude Opus 4.7 via S180 checkpoint NEXT ACTION ratification (PRIORITY 1 mechanical cleanup; SCOPE-tier autonomous-full)

## end_of_adr (S181 IMPL outcomes)

- Pre-state: HH-6 stale=6 (HIGH); HH-10 orphans=6 (MEDIUM); harness state RED-2
- Post-state: HH-6 stale=0; HH-10 orphans=0; harness state RED-1 (HH-2 + HH-9 carry-overs only)
- 26 sidecars deleted; 18 of 213 dispatch.jsonl rows recovered (10% rate)
- 6 NEW firing-tests; 35/35 individual TCs PASS; full suite 81/81 PASS (was 75); zero regression
- TC fixture-vs-regex tightening: redact-secrets-fire-test TC1 (anthropic ≥80-char) + TC3 (google exactly-35-char) failed first run, fixed inline within TDD loop — doctrine application (L-S176-1 fixture-real-state extension), not new lesson
- ~60-90K main turn (MULTI-TASK IMPL envelope; on-target low-mid)
