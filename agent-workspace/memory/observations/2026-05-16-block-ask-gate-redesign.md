---
observation_id: 2026-05-16-block-ask-gate-redesign
type: harness-design-proposal
created_at: 2026-05-16T~19:30 SEAST
author: main session (Opus 4.7 max effort)
trigger: user_prompt 20260516_01.txt § 2 — "block/ask user for approved ... a lot of time claude code stop, need user intervent ... my idea ... except some especially blocking feature, that really need to stop and need human to intervent, then stop, otherwise, its will be pending, human can verify them later, and if more than 6 hours, the harness system trigger the telegram notification"
scope: redesign severity/escalation/block tier model to reduce unnecessary human intervention
severity: HIGH (currently every ~3rd autonomous turn requires user "approved" keyword; degrades autonomous-mode value proposition)
---

# Block/Ask-User Gate Redesign — 2026-05-16

## TL;DR

**Problem**: current severity-classifier treats 3 distinct file markers + Q&A >=96h + PROPOSED expired cool-down as CRITICAL → all trigger `.autonomous-BLOCKED` → all require user keyword ("approved" / "unblock" / "tiep tuc") to clear. Most of these are NOT actual dangers — they're bookkeeping signals or test-fixture leftovers (e.g., M-S342-1 was a sandwich-verifier V1.5 fixture).

**User's redesign intent**: only TRULY-dangerous events should HARD-BLOCK; everything else routes to a pending queue with a 6-hour Telegram escalation timer, and 24-hour auto-archive to prevent perpetual nag.

**Proposed**: 3-tier model (HARD / PENDING / SOFT) replacing the current binary (CRITICAL=BLOCK vs HIGH/MEDIUM/LOW=LOG-or-digest). 99% of current `CRITICAL` trigger conditions reclassify to PENDING.

**Implementation cost**: ~2 sessions (PLAN + IMPL+VERIFY sandwich). 4 hooks edited + 1 new hook + new TSV schema for pending queue.

---

## Current architecture (empirically verified at `.claude/settings.json` + 4 hooks)

```
┌─────────────────────────────────┐
│ severity-classifier.sh (Stop)   │  ← scans markers + Q&A + decisions + mistake-log
│ Emits .severity-state.tsv rows: │
│   CRITICAL / HIGH / MEDIUM / LOW│
└──────────────┬──────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│ escalation-engine.sh                          │  ← Stop, UserPromptSubmit, SessionStart
│   IF any CRITICAL row → write                 │
│     .autonomous-BLOCKED flag                  │
│     + URGENT entry in notifications/urgent.md │
│     + Telegram push                           │
│   ELSE → log to .escalation.log               │
└──────────────┬───────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│ autonomous-block-enforcer.sh                  │  ← UserPromptSubmit + PreToolUse
│   IF .autonomous-BLOCKED exists:              │
│     - inject loud BLOCKED context (UPS)       │
│     - block all tools except Read/Glob/Grep   │
│       + the block-control.sh escape hatch     │
└──────────────┬───────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│ block-control.sh check-prompt                 │  ← UserPromptSubmit
│   Scans user's prompt for: "approved" /       │
│   "unblock" / "run autonomous" / "tiep tuc"   │
│   → removes .autonomous-BLOCKED               │
│   → grace 60s applied                         │
└──────────────────────────────────────────────┘
```

### Current CRITICAL triggers (severity-classifier.sh:64-144)

| Layer | Trigger | Verdict on actual danger |
|---|---|---|
| 1 | `.auto-reboot-PRE-BLOCKED-stale-checkpoint` exists | NOT dangerous — bookkeeping signal that auto-reboot would have been blocked |
| 1 | `.charter-violation-detected` exists | SOMETIMES — could be real violation OR test fixture (M-S342-1 case) |
| 1 | `.ghost-greening-confirmed` exists | SOMETIMES — needs human verify but agent can continue other work |
| 2 | Q&A pending bundle age ≥ 96h | NOT dangerous — human just hasn't responded; not an emergency |
| 2 | (Q&A age ≥ 6h becomes HIGH, escalate via AskUser) | OK as-is — but should also age-cap into Telegram |

**None of these meet the bar of "truly blocking, must stop and ask human now"** — they're all signals the user could review at their convenience.

The real "must stop now" cases are caught earlier in the chain by:
- `destructive-command-guard.sh` (PreToolUse) — `rm -rf /`, `git push --force main`, `git reset --hard`, etc.
- `project-integrity-watchdog.sh` (Stop) — mass-deletion / unauthorized file removal detected

These already have their own gating logic and don't depend on the BLOCKED-flag flow. **The BLOCKED-flag flow only fires for the soft signals above.**

---

## Proposed 3-tier model

```
┌────────────────────────────────────────────────────────────────┐
│ severity-classifier.sh emits .severity-state.tsv with NEW col: │
│   block_tier: HARD | PENDING | SOFT                            │
└──────────────────────────────┬─────────────────────────────────┘
                               │
            ┌──────────────────┼──────────────────┐
            ▼                  ▼                  ▼
┌──────────────────┐  ┌────────────────────┐  ┌──────────┐
│ HARD             │  │ PENDING            │  │ SOFT     │
│ (true gate)      │  │ (notify + 6h)      │  │ (log)    │
├──────────────────┤  ├────────────────────┤  ├──────────┤
│ • Imminent       │  │ • stale-checkpoint │  │ Existing │
│   destructive    │  │ • charter-viol     │  │ HIGH/MED │
│   command        │  │ • ghost-greening   │  │ /LOW     │
│ • Confirmed mass │  │ • Q&A age ≥ 96h    │  │ behavior │
│   deletion       │  │ • PROPOSED expired │  │ (digest, │
│ • Unauthorized   │  │   cool-down        │  │  log)    │
│   push attempt   │  │                    │  │          │
├──────────────────┤  ├────────────────────┤  └──────────┘
│ Action:          │  │ Action:            │
│  → .autonomous-  │  │  → notifications/  │
│    BLOCKED       │  │    N-<ts>-ALERT-*  │
│  → Immediate     │  │  → pending-queue   │
│    Telegram      │  │    .tsv row with   │
│  → All tools     │  │    escalate_at =   │
│    blocked       │  │    now + 6h        │
│  → User keyword  │  │  → Agent continues │
│    required to   │  │  → 6h → Telegram   │
│    clear         │  │  → 24h → archive   │
└──────────────────┘  └────────────────────┘
```

### Mapping: current → proposed

| Current trigger | Current tier | Proposed tier | Rationale |
|---|---|---|---|
| `.auto-reboot-PRE-BLOCKED-stale-checkpoint` exists | CRITICAL (BLOCK) | PENDING | Bookkeeping signal; agent can continue other work; user reviews later |
| `.charter-violation-detected` exists | CRITICAL (BLOCK) | PENDING | Could be test fixture (M-S342-1); needs human verify but not emergency |
| `.ghost-greening-confirmed` exists | CRITICAL (BLOCK) | PENDING | Needs human verify; agent can continue non-conflicting work |
| Q&A pending bundle age ≥ 96h | CRITICAL (BLOCK) | PENDING (with NAG flag — Telegram every 24h until answered) | Not an emergency; sustained Telegram nag accomplishes the same goal without halting work |
| Q&A pending bundle age ≥ 6h | HIGH (ESCALATE-ASKUSERQUESTION) | PENDING | Existing behavior already routes via AskUserQuestion; add Telegram on first 6h hit |
| PROPOSED ADR expired cool-down (charter ≥24h) | HIGH | PENDING | Architect/dev sandwich handles this; not blocking |
| Imminent destructive command at PreToolUse | (handled separately by destructive-command-guard) | HARD (unchanged) | This IS the true block case |
| Unauthorized push attempt | (D-060 prevention) | HARD (unchanged) | Per project owner directive |

**Net effect**: ~0 HARD blocks per typical session (vs ~1 per 3 turns currently). Routine bookkeeping signals route to a pending queue user reviews at convenience.

---

## Implementation plan

### Files to modify

1. **`scripts/hooks/severity-classifier.sh`** (~30 LOC change)
   - Add 5th TSV column `block_tier` (back-compat default = SOFT for legacy rows on read)
   - Emit `block_tier=PENDING` for the 3 markers + Q&A ≥96h + PROPOSED expired
   - Reserve `block_tier=HARD` for cases not currently emitted (future-proof; comment that destructive-command-guard handles the actual HARD cases at PreToolUse layer)
   - All current `severity=CRITICAL` rows become `severity=CRITICAL block_tier=PENDING` (severity column kept for telemetry; block_tier drives action)

2. **`scripts/hooks/escalation-engine.sh`** (~25 LOC change)
   - Only `block_tier=HARD` rows write `.autonomous-BLOCKED` flag
   - `block_tier=PENDING` rows append to NEW `human-workspace/notifications/.pending-queue.tsv` with `escalate_at` column
   - `block_tier=SOFT` rows stay in existing log-only path
   - Preserve immediate Telegram for HARD; defer Telegram to escalator hook for PENDING

3. **`scripts/hooks/pending-queue-escalator.sh`** (NEW, ~80 LOC) — Stop cadence
   - Read `human-workspace/notifications/.pending-queue.tsv`
   - For each row: if `escalate_at < now` AND `telegram_pushed=false` → push Telegram + set `telegram_pushed=true`
   - For each row: if `age > 24h` AND status still unactioned → move to `notifications/archive/` (auto-archive; prevent perpetual nag)
   - For each row: if underlying artifact GONE (e.g., user resolved the stale-checkpoint OR `.charter-violation-detected` cleaned up by next severity-classifier run) → mark row resolved + archive

4. **`scripts/hooks/block-control.sh`** (~10 LOC change)
   - No structural change; the "approved" keyword path stays for cases where HARD was raised
   - Add new subcommand `block-control.sh ack <pending-id>` for user to dismiss a PENDING row via prompt (e.g., "ack stale-checkpoint" in chat)

5. **`scripts/hooks/autonomous-block-enforcer.sh`** (no change needed) — already correctly keyed off `.autonomous-BLOCKED` existence

### Schema: `.pending-queue.tsv`

```
# columns: pending_id | block_tier | severity | artifact_path | detected_at | escalate_at | telegram_pushed | archived_at | resolve_reason
sleep-checkpoint-1736040000   PENDING  HIGH    agent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint  2026-05-16T19:00Z  2026-05-17T01:00Z  false  -  -
```

Atomic write per D-062 (tmp+os.replace); path-safety per D-064.

### Telegram payload (per row)

```
[StockForge PENDING] severity=HIGH artifact=.auto-reboot-PRE-BLOCKED-stale-checkpoint
Detected 6h ago at 2026-05-16T19:00Z. No human action yet — escalating.
Suggested actions: (a) review marker + decide if resolved (b) reply "ack stale-checkpoint" to dismiss (c) reply "approved" to escalate to HARD.
Archive in 18h if no action.
```

### Migration

- Existing `.severity-state.tsv` rows without block_tier column: classifier reads col5 (classified_at) as before; new col6 (block_tier) defaults to SOFT on legacy rows; escalation-engine treats missing col6 as PENDING for the 5 legacy CRITICAL trigger types (back-compat shim removable after 30 days)
- Existing `.autonomous-BLOCKED` flag at deployment time: leave alone; user clears via "approved" once; new flow takes over thereafter
- Telegram message format change opt-out via `STOCKFORGE_TELEGRAM_LEGACY_FORMAT=1` env (default new format)

### Fire-tests required

- Each of the 5 legacy CRITICAL trigger types: assert NEW behavior emits PENDING row, NOT `.autonomous-BLOCKED`
- HARD path remains exercisable: synthetic destructive-command-guard fire → assert `.autonomous-BLOCKED` still written
- pending-queue-escalator: row with escalate_at < now → Telegram fired exactly once
- pending-queue-escalator: row age > 24h → archived
- pending-queue-escalator: artifact GONE → row resolved + archived

Target: 12-15 firing-test cases.

### Verification (sandwich-verifier S<X+1>)

- All current "approved"-keyword interventions over last 10 sessions: re-classify per new tiers; expect 0-1 actual HARD vs 9-10 PENDING
- 1 production cycle with new flow: count human interventions per N autonomous turns (target: ≤1 per 20 turns vs current ~1 per 3)

---

## Effort + sequencing

| Phase | Effort | Owner |
|---|---|---|
| PLAN-022b (architect) — refine this proposal into plan + AQ + RM | 60-80K Opus | sandwich-architect |
| IMPL-S<X> (dev) — 4 hook edits + 1 new hook + schema + fire-tests | 120-180K Opus (per current model edict) OR 80-120K Sonnet (post-restore) | sandwich-dev |
| VERIFY-S<X+1> (verifier) — fresh-context audit | 50-80K Opus | sandwich-verifier |
| Total | ~2.5 sessions | — |

---

## Open questions for user (defer until Item-3 + Item-4 close)

1. **Q-RD1**: For PENDING queue 24h auto-archive — should "archived" rows be deleted entirely OR moved to `notifications/archive/` for audit trail? (Recommend: archive/ for audit; cheap disk.)
2. **Q-RD2**: For Q&A pending ≥96h — currently CRITICAL; under new model PENDING with 24h Telegram nag. Is this acceptable, OR do you want a special "force-ASK" tier for Q&A older than say 7 days that DOES halt agent? (Recommend: no special tier; sustained nag is enough.)
3. **Q-RD3**: For new HARD additions later — should we centralize ALL HARD triggers in `severity-classifier.sh` block_tier=HARD output (single source of truth) OR keep them distributed across `destructive-command-guard.sh` + `project-integrity-watchdog.sh`? (Recommend: keep distributed; each guard knows its own context best; severity-classifier focuses on PENDING signals.)
4. **Q-RD4**: For "ack" keyword — what's the syntax preference? Single-word ack <slug> OR more verbose "dismiss stale-checkpoint" OR allow free-text "ok, ignore this"? (Recommend: ack <slug> single-token; deterministic detection.)

---

## What I did NOT do (deferred per scope discipline)

- **Did not implement patches** — proposal stage; needs PLAN session + sandwich pattern
- **Did not modify any hooks** — pure observation file
- **Did not write fire-tests** — listed in implementation plan
- **Did not propose ADR yet** — D-067 candidate (3-tier escalation model); appropriate at IMPL tier post-architect refinement
- **Did not interact with currently-running S344 dev** — running in background; orthogonal to this work

## Compliance attestation

- harness_priority_one ✓ (this IS harness work; ranked above product per doctrine)
- 0 charter / 0 constitution writes
- 0 production code changes
- 0 commits
- AP-1 N/A (no fresh-context dispatch yet; user reviews proposal first)
- D-060 N/A (no commit / push)
- Observation persisted at `agent-workspace/memory/observations/` per Track 6
- Source citations: `scripts/hooks/{severity-classifier,escalation-engine,autonomous-block-enforcer,block-control}.sh` + `.claude/settings.json:139-524` + M-S342-1 case study + recent mistake-log + project-owner directive in user_prompt 20260516_01.txt
