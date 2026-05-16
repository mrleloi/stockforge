---
adr_id: 068
title: Block/Ask-user Gate 3-Tier Model (HARD / PENDING / SOFT)
status: PROPOSED
level: IMPL
cool_down_hours: 0
proposed_at: 2026-05-16T20:06:00+07:00 SEAST
proposed_by: S348 sandwich-dev (per plan 024-S345 architect S345 + user ratification 2026-05-16 ~20:30 SEAST)
supersedes: harness-severity-escalation-system-2026-05-14.md § residual CRITICAL=BLOCK behavior
superseded_by: -
ratified_at: -
ratified_by: -
provenance: agent-workspace/memory/observations/2026-05-16-block-ask-gate-redesign.md + user_prompt 20260516_01.txt § 2 + plan 024-S345-block-ask-gate-3-tier.md
---

# ADR D-068 — Block/Ask-user Gate 3-Tier Model

## Context

Per S342-S345 close-bookkeeping + M-S342-1 case study + project-owner directive
(user_prompt 20260516_01.txt § 2 — "a lot of time claude code stop, need user
intervent ... my idea ... except some especially blocking feature, that really
need to stop and need human to intervent, then stop, otherwise, its will be
pending, human can verify them later, and if more than 6 hours, the harness
system trigger the telegram notification"), the existing binary CRITICAL=BLOCK
model triggered ~1 forced user intervention per 3 autonomous turns. Empirical
analysis (observation 2026-05-16) found NONE of the 5 current CRITICAL trigger
types meet the "must stop now" bar — they're all soft signals user could review
at convenience.

Empirical cascade for the M-S342-1-style false-block:
1. sandwich-verifier-S342.md fire-test wrote `.charter-violation-detected` as a
   TEST FIXTURE to exercise severity-classifier.sh CRIT_MARKERS detection
2. Verifier exited without cleanup (no trap EXIT for fixture artifacts)
3. Next Stop hook fires severity-classifier.sh -> file present -> emit CRITICAL/BLOCK
4. escalation-engine.sh -> CRIT_N > 0 + no .block-grace -> writes .autonomous-BLOCKED
5. autonomous-block-enforcer.sh -> next PreToolUse -> Bash/Edit/Write blocked
6. User must reply "approved" -> block-control.sh:check-prompt -> cmd_clear -> flag deleted
7. Total cost: 1 forced user intervention

## Decision

Introduce 3-tier `block_tier` column (col6) in `.severity-state.tsv`:

| Tier | Action | Use case |
|---|---|---|
| HARD | `.autonomous-BLOCKED` flag + immediate Telegram + all tools blocked except Read/Glob/Grep + block-control.sh | Imminent destructive command (PreToolUse — destructive-command-guard.sh); confirmed mass deletion (Stop — project-integrity-watchdog.sh); unauthorized push attempt (D-060 prevention) |
| PENDING | Append row to `.pending-queue.tsv` with `escalate_at = now + 6h`; agent continues; 6h -> Telegram fires once; 24h -> auto-archive to `notifications/archive/`; user can `ack <slug>` anytime | Stale-checkpoint markers; charter-violation-detected markers; ghost-greening-confirmed markers; Q&A age >= 96h; PROPOSED ADR expired cool-down |
| SOFT | Existing log-only or digest behavior | All HIGH/MEDIUM/LOW from notification scans; HIGH from Q&A age >= 6h (legacy AskUserQuestion path preserved) |

HARD triggers remain DISTRIBUTED across guards per Q-RD3 — each guard knows its
own context. severity-classifier reserves the HARD-tier emission path
(placeholder comment block) but in current 5-trigger taxonomy emits NO HARD rows.

### Implementation sub-tracks (S348)

- D1: severity-classifier.sh — added `block_tier` as col6 to `.severity-state.tsv`; 5 CRITICAL trigger types reclassified to PENDING; `emit_row()` signature extended with 5th arg (default SOFT)
- D2: escalation-engine.sh — CRIT_ROWS split into HARD_ROWS + PENDING_ROWS via awk col6; HARD tier writes `.autonomous-BLOCKED`; PENDING tier writes `.pending-queue.tsv` rows; UserPromptSubmit injection keyed off HARD_N only per DD-10
- D3: NEW `scripts/hooks/pending-queue-escalator.sh` — Stop cadence; reads `.pending-queue.tsv`; 6h Telegram escalation; 24h auto-archive; self-resolution on artifact-gone
- D4: block-control.sh — NEW `ack <slug>` subcommand + check-prompt ack-regex extension; multi-ack per prompt supported
- D5: Migration shim in escalation-engine.sh — 30-day window (removal target 2026-06-15); legacy 5-col CRITICAL rows treated as PENDING during rollout
- D6: DEFERRED — .claude/settings.json wire-up pending-queue-escalator.sh in Stop chain; deferred to main session post-dispatch to avoid conflict with concurrent plan-025 dev
- D7: 25 new fire-test TCs + Telegram smoke + this ADR + session log + dev observation

### Binding design decisions (DD-1..DD-12)

- DD-1: TSV col-add (additive col6; back-compat default SOFT for legacy rows)
- DD-2: `.pending-queue.tsv` 9-col schema
- DD-3: `pending_id` format: `<slug>-<epoch_seconds>`
- DD-4: Telegram message format: multi-line UTF-8, ASCII-only per telegram-push.sh constraint
- DD-5: `ack <slug>` regex: `(^|[^a-zA-Z0-9_-])ack +([a-zA-Z0-9_-]+)` with word-boundary
- DD-6: Auto-archive to `notifications/archive/` (not deletion) per Q-RD1 user preference
- DD-7: Self-resolution: artifact GONE -> archive immediately with resolve_reason="artifact-gone"
- DD-8: HARD tier immediate block (no 6h grace) — for "truly stop now" events
- DD-9: Migration shim 30-day window; removal target 2026-06-15
- DD-10: PENDING rows silent on UserPromptSubmit per user's "agent continues working" intent
- DD-11: Atomic write per D-062 (tmp + mv -f + trap EXIT) for `.pending-queue.tsv`
- DD-12: Path safety per D-064 (basename whitelist + no `..` + audit log)

## Consequences

- Forced user interventions drop from ~1/3 turns to ~0-1/20 turns (estimated per
  observation; verify in S349 production cycle)
- 5 trigger types reclassified CRITICAL -> PENDING (severity=CRITICAL preserved for
  telemetry; block_tier=PENDING drives action)
- Migration shim handles legacy 5-col rows for 30 days (target removal 2026-06-15)
- M-S342-1 LOSS SURFACE drops MEDIUM -> LOW (verifier fixture leak now auto-resolves
  via 24h archive without forced user intervention)
- NEW hook pending-queue-escalator.sh adds ~100-500ms to Stop chain (acceptable;
  net huge win vs ~5min human-intervention cost)

## Status: PROPOSED IMPL-tier (cool_down_hours=0; auto-ratifies on commit per
severity-schema IMPL-tier rule)

## Out-of-scope / Deferred

- D6 settings.json wire-up: deferred to main session post-dispatch (plan-025 coordination)
- PreToolUse HARD guards: already exist in destructive-command-guard.sh (not in scope per Q-RD3)
- Batched Telegram messages: per AQ-7, 1-per-row OK initially; revisit on 429 rate-limit hit
- SessionStart cadence for escalator: per DD-AQ-11 NO; Stop only
