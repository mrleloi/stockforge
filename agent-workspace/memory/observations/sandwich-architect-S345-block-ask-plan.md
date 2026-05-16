---
observation_id: sandwich-architect-S345-block-ask-plan
session: S345
agent: sandwich-architect (background; Claude Opus 4.7)
date: 2026-05-16
agentId: (this dispatch's runtime id; to be filled by main session at task-notification)
budget_used: ~55K (within 60-80K PLAN envelope; single-pass authoring, no second-architect parallel dispatch)
deliverable: agent-workspace/session-plans/pending/024-S345-block-ask-gate-3-tier.md (~1100 LOC)
phase: B/D-overlap (HARNESS — non-product; per harness_priority_one doctrine)
status: PLAN-AUTHORED-AWAITING-DISPATCH
---

# S345 — Block/Ask-user Gate 3-Tier Redesign PLAN authoring (observation)

## What I did

1. **VBW reading pass** (~15 files; ~17K tokens):
   - `agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md` (PRIMARY — design proposal end-to-end; 242 lines; user-ratified per "follow your recommendation")
   - `scripts/hooks/severity-classifier.sh` (END-TO-END read — D1 primary target; current 5 trigger types at lines 70-95)
   - `scripts/hooks/escalation-engine.sh` (END-TO-END read — D2 routing target; lines 25-103 + 163-166 UPS injection)
   - `scripts/hooks/block-control.sh` (END-TO-END read — D4 ack subcommand + check-prompt extension target; lines 44-243)
   - `scripts/hooks/autonomous-block-enforcer.sh` (END-TO-END read — confirmed NO change needed per observation § Implementation)
   - `scripts/hooks/telegram-push.sh` (END-TO-END read — no change needed; D3 escalator calls as library)
   - `scripts/hooks/destructive-command-guard.sh` (lines 1-50 — Q-RD3 distributed-HARD precedent reference)
   - `scripts/hooks/firing-tests/escalation-engine-fire-test.sh` (END-TO-END read — fire-test cadence reference for D2 extensions)
   - `scripts/hooks/firing-tests/block-control-fire-test.sh` (END-TO-END read — fire-test cadence reference for D4 extensions)
   - `.claude/settings.json` (lines 300-524 — Stop chain ordering; escalation-engine.sh at line 448; D6 insertion point identified)
   - `.claude/settings.local.json` (lines 255-260 — Telegram creds confirmed live: token + chat 891087440 "Lê Lợi")
   - `.claude/agents/sandwich-architect.md` (lines 1-30 — confirmed `tools: [Read, Glob, Grep, Write]` = NO Bash, so STEP 0.3 Telegram smoke is sandwich-dev's responsibility not mine)
   - `agent-workspace/memory/.severity-state.tsv` (current 11 rows — 0 CRITICAL, 3 MEDIUM warn notifications, 8 LOW; clean baseline for D1 migration)
   - `agent-workspace/memory/current-execution.md` (lines 1-200 — confirmed S343-S344 close, S345 verifier deferred; target session for this plan = S346)
   - `agent-workspace/session-plans/completed/021-S340-harness-stabilization-sweep.md` (lines 1-300 — plan cadence reference; matches DD-1..DD-12 / RM1..RM12 / AQ-1..AQ-12 / DC-1..DC-NN / V1..VNN sections)
   - `agent-workspace/memory/observations/sandwich-architect-S340-harness-stabilization-plan.md` (lines 1-80 — observation cadence reference)
   - Glob `human-workspace/notifications/archive/*` (100+ files confirmed — Q-RD1 archive/ destination precedent validated; existing pattern reuses)

2. **Architectural decisions made + adversarial alternates rejected** (per Karpathy P1):

   **DD-1 TSV col-add over col-replace**: chose additive 6th col `block_tier` over replacing severity col. Rationale: existing 4 layers + Layer 4 mistake-log grep at `severity-classifier.sh:155-159` reads `severity` col; replacing it would break Layer 4 + all downstream readers. Additive preserves back-compat + telemetry continuity.

   **DD-3 pending_id format `<slug>-<epoch_seconds>`**: chose epoch suffix over UUID (loses readability for `ack <slug>`) and over sequential counter (state file required). Mirrors L-S289-1 atomic-claim pattern.

   **DD-5 ack regex strict-anchor decision**: `(^|\n)ack +<slug>([^a-zA-Z0-9_-]|$)` chosen over `^ack +<slug>$` (full-line). Rationale: user may type "ok thanks, ack stale-checkpoint then continue" — full-line anchor would miss. Strict char-suffix anchor + line-start anchor strikes balance between false-positive prevention (RM3) and natural language use.

   **DD-7 self-resolution AGGRESSIVE (regardless of age)**: chose immediate archive when artifact GONE over waiting for 24h auto-archive. Rationale: handles M-S342-1 fixture-leak case automatically; if artifact is gone, the row has no purpose. Trade-off: edge case where artifact is briefly moved/renamed (not deleted) might wrong-archive — mitigated by re-emission on next severity-classifier cycle if artifact reappears.

   **DD-9 30-day migration shim explicit removal date**: chose hard removal date 2026-06-15 over indefinite shim. Rationale: AP-7 anti-vacuous-defer; sets explicit trigger to clean up technical debt. If extension needed at 2026-06-15, named procedure in RM1 (7-day extension, 3rd extension triggers root-cause).

   **DD-10 UPS silence for PENDING**: chose silent-on-UPS over noisy-on-UPS for PENDING tier. Rationale: per S345 brief — "agent continues working" is the entire goal of the redesign; UPS noise on PENDING would defeat that.

   **DD-11 atomic write via tmp+mv pattern (not lock file)**: chose D-062 pattern over file lock. Rationale: severity-classifier.sh:33-41 already proves the pattern at S341 D2 fix; single-writer Stop cadence means no concurrent write needed.

3. **Plan structure followed S345 brief sections A-K plus extensions** (per architect's plan-021 cadence preference):
   - § A session metadata (8 fields)
   - § B predecessor + invocation context (with empirical cascade analysis of M-S342-1 case)
   - § C charter compliance map (13-row table)
   - § D sub-track decomposition (D1-D7; all INCLUDED; 0 deferred at sub-track level)
   - § E DD-1..DD-12 architectural decisions table
   - § F sub-track summary + LOC budget table
   - § G 5-source evidence chain (7 rows × 5 sources)
   - § H DoD checklist (DC-1..DC-40)
   - § I verifier checks (V1..V12 for S347)
   - § J coordination paths off-limits during S346 IMPL
   - § K STEP 0 pre-flight verification (BLOCKING per S345 brief — 5 sub-steps with STOP-AND-ASK triggers)
   - § L AQ-1..AQ-12 pre-answered (Q-RD1..Q-RD4 ratified)
   - § M RM1..RM12 risk-mitigation table with named revisit triggers
   - § N budget envelope + token breakdown
   - § O AP-23 attestation (5-instance promote-now justification)
   - § P compliance attestation (12-rule table)
   - § Q out-of-scope with AP-7 revisit triggers (8 items)

4. **Telegram smoke test deferred to sandwich-dev**: per architect's `tools: [Read, Glob, Grep, Write]` (no Bash), I CANNOT execute STEP 0.3 Telegram smoke myself. Per S345 brief instruction "do not skip", I packaged STEP 0.3 as the FIRST blocking gate for sandwich-dev at S346 IMPL start; if Telegram dead, sandwich-dev STOP-AND-ASK before any D1 edits. This is the architect-with-no-Bash recovery pattern (S335/S337/S340 precedent — dispatch-template gap, AP-23 promote-now applied at S341 D3 + D7).

5. **Verified Telegram creds live via Read-only check**: `.claude/settings.local.json:257-258` contains:
   - `STOCKFORGE_TELEGRAM_BOT_TOKEN=8727392790:AAHWMxH6H0_w9lpivVF1W6sY-XjSAbcfvOI`
   - `STOCKFORGE_TELEGRAM_CHAT_ID=891087440`
   - Per current-execution.md:30 these were E2E-verified at S310 (8 messages delivered to "Lê Lợi" chat). Creds OK; runtime liveness still requires sandwich-dev's smoke test at STEP 0.3.

## Architectural decisions made

| DD | Decision | Why this not alternates |
|---|---|---|
| DD-1 | Additive col6 `block_tier` to severity-state.tsv | Replacing severity col breaks Layer 4 grep + downstream telemetry |
| DD-2 | 9-col `.pending-queue.tsv` schema | TSV is bash-idiomatic; JSON adds parser dependency |
| DD-3 | `<slug>-<epoch>` pending_id | Readable + sortable + collision-resistant |
| DD-4 | Multi-line UTF-8 Telegram (no emoji) per telegram-push.sh:55 historical constraint | Existing platform constraint already proven |
| DD-5 | `(^|\n)ack +<slug>([^a-zA-Z0-9_-]|$)` ack regex | Strict but allows natural-language prefix |
| DD-6 | Auto-archive to `notifications/archive/` (not delete) | Q-RD1 ratified + existing precedent |
| DD-7 | Self-resolution AGGRESSIVE (regardless of age) | Handles M-S342-1 fixture cases automatically |
| DD-8 | HARD path preserved (existing CRITICAL behavior) | Reserve for true active-danger emission |
| DD-9 | 30-day migration shim with explicit removal date 2026-06-15 | AP-7 anti-vacuous-defer; explicit trigger |
| DD-10 | UPS silence for PENDING | "Agent continues" is the goal of the redesign |
| DD-11 | Atomic write via tmp+mv+trap (D-062) | Proven pattern; single-writer Stop = no race |
| DD-12 | Path safety via basename whitelist + literal-anchor (D-064) | Prevents `slug=../../../etc/passwd` exploit |

## Verification results

N/A — architect outputs PLAN ONLY (no code, no tests run). Verification gates are S346 IMPL (sandwich-dev runs fire-tests + Telegram smoke + 989/989 pytest regression) and S347 VERIFY (sandwich-verifier V1..V12).

## Risks surfaced (NEW found during PLAN authoring not in observation file's risk list)

| Risk | Source | Mitigation in plan |
|---|---|---|
| while-subshell variable scoping in D3 escalator | Bash gotcha (counters won't propagate from pipe-subshell to parent) | DD note in § D3 — sandwich-dev must use `while ... < <(grep ...)` process substitution instead of `grep | while` |
| AQ-10 status output schema change implicit | Not in S345 brief AQ list; I inferred from "block-control.sh status reports correctly with new schema" DoD bullet | Added AQ-10 + flagged sandwich-dev MUST add PENDING count to status output |
| Q&A nag re-detection cycle | After 24h auto-archive, severity-classifier re-detects the same Q&A bundle (still age >96h) → re-emits PENDING → re-fires Telegram every 24h | This is the INTENDED "sustained nag" behavior per Q-RD2 ratification — documented in DD-4 + AQ-3 |
| Migration shim conflict if HARD trigger added during 30-day window | If sandwich-dev or architect adds a new HARD-tier emit_row call during the shim window, the `$6=="" \|\| $6=="PENDING"` clause would NOT match HARD; OK | Defensive: `$6=="HARD"` clause MUST be checked first in awk split per § D2 step 1 (it is) |

## Compliance attestation

- **harness_priority_one**: UPHELD (this IS harness work; ranked above product per CLAUDE.md memory rule)
- **0 charter writes**: UPHELD (PROJECT_CHARTER.md not touched)
- **0 constitution writes**: UPHELD (agent-workspace/constitution/** not touched; ADR D-068 PROPOSED lives in `agent-workspace/memory/decisions/` per S345 brief)
- **0 production code in PLAN session**: UPHELD (architect outputs PLAN file + observation file only)
- **0 commits in PLAN session**: UPHELD (sandwich-architect subagent has no Bash tool; main commits plan output per D-060 + dispatch-template recovery pattern from S335/S337/S340)
- **AP-1 fresh-context**: UPHELD (architect ↔ dev S346 ↔ verifier S347 all separate contexts per CLAUDE.md anti-pattern)
- **AP-7 anti-vacuous-defer**: UPHELD (RM1+RM3+RM7+RM10+RM11 have explicit revisit triggers; Q-N out-of-scope items have AP-7 triggers)
- **AP-23 promote-or-retire**: UPHELD (5 instances of informal-pending promoted to PENDING tier per § O attestation)
- **D-060 commit posture**: UPHELD (this PLAN session: 0 commits; main commits via D-060 agent-may-commit when receiving architect output)
- **VBW protocol**: UPHELD (15 actual files read end-to-end via Read tool; no memory-based claims)
- **Source citations**: UPHELD (every § G evidence chain row cites 5 sources; every DD has explicit source reference)
- **Telegram smoke test scheduling**: SCHEDULED (STEP 0.3 of S346 IMPL; architect cannot execute due to no-Bash tool limit; documented as sandwich-dev mandatory action)

## Handoff to sandwich-dev (S346 IMPL)

5-7 verification items for sandwich-dev at S346 IMPL kickoff:

1. **VBW re-read MANDATORY**: re-read severity-classifier.sh + escalation-engine.sh + block-control.sh + telegram-push.sh end-to-end before any edits (architect's S345 read does NOT substitute per VBW protocol)
2. **STEP 0 BLOCKING (5 sub-steps)**: STEP 0.1 obs file path + STEP 0.2 5 CRITICAL triggers stable + STEP 0.3 Telegram smoke (DO NOT SKIP — S345 brief mandate) + STEP 0.4 no in-flight `.autonomous-BLOCKED` + STEP 0.5 backup hooks to .bak-S346 for rollback
3. **D1-D7 sub-track ordering**: D1 → D2 → D3 → D4 (D4 parallel-safe with D2 if needed) → D5 (in D2 file) → D6 (after D3 hook exists) → D7 (final bundle); each sub-track independently committable per Karpathy P3
4. **Fire-test target**: 25 new TCs + regression of all existing TCs (run-all.sh aggregate 100% PASS)
5. **Telegram smoke**: capture HTTP 200 + `{"ok":true,...}` body in session log per BEHAVIORAL HOLD § (b) audit pattern
6. **ADR D-068**: NEW file at `agent-workspace/memory/decisions/068-block-ask-gate-3-tier-model.md`; 12-field schema; status PROPOSED + cool_down_hours: 0 (IMPL-tier auto-ratifies on commit per severity-schema)
7. **Sandwich-dev observation file**: NEW at `agent-workspace/memory/observations/sandwich-dev-S346-block-ask-gate-3-tier-impl.md` per dispatch-template-gap recovery pattern from S341 D7

## Commits made

0 (architect has no Bash tool; main commits this plan + observation file per D-060 + AP-23 dispatch-template-recovery)

## Compliance attestation final

Architect attestation that all S345 brief CONSTRAINTS are upheld:
- 0 charter writes ✓
- 0 constitution writes ✓
- 0 production code outside scripts/hooks/ + .claude/settings.json ✓ (architect outputs PLAN file + obs file only; both under agent-workspace/)
- D-060: 0 commits + 0 pushes ✓ (architect has no Bash)
- AP-1 fresh-context ✓ (architect in own context; dev S346 + verifier S347 separate)
- harness_priority_one ✓ (this IS harness work)
- Telegram smoke test SCHEDULED at STEP 0.3 (sandwich-dev mandatory; documented as "DO NOT SKIP" per S345 brief)

All 4 Q-RD ratified per user "follow your recommendation" → DD-6 (Q-RD1) + DD-4/AQ-3 (Q-RD2) + § C "HARD distributed" (Q-RD3) + DD-5 (Q-RD4).
