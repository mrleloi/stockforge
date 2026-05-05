# Session Budgets

> Measured data from 51+ real agent sessions. Quality cliff at 250K tokens is real.

## The Quality Cliff

```
Token usage         Tasks/100K tokens     Quality observation
─────────────────────────────────────────────────────────────
50-80K              ~1.0                  Focused output
80-150K             ~1.2                  Guided execution
150-250K            ~1.0                  OK if chunked
250K+               <0.5                  Quality degrades sharply
300K+ mixed role    0.0                   FAILED (Session 4 case)
```

**Root cause**: Transformer attention is O(n²). Past 250K, "lost in the middle" effect dominates. Agent forgets rules in middle of conversation. Output quality drops non-linearly.

**Rule**: If projected session > 250K tokens → MANDATORY SPLIT.

---

## Session Types

### PLAN (Architect Subagent)
- **Budget**: 50-80K tokens
- **Purpose**: Plan work, produce detailed task breakdown
- **Agent**: `sandwich-architect` subagent
- **Output**: Session plan file in `session-plans/pending/`
- **Never**: Writes production code. Never implements.

### FOCUSED_IMPL (Main session)
- **Budget**: 100-150K tokens
- **Purpose**: Implement 1-3 tasks from existing plan
- **Agent**: Main Claude Code session
- **Output**: Code + tests + doc updates
- **Requires**: Pre-existing plan. Never re-plans.

### MULTI_TASK_IMPL (Main session)
- **Budget**: 150-250K tokens
- **Purpose**: Implement 4-10 tasks from existing plan
- **Agent**: Main Claude Code session
- **Output**: Code + tests + doc updates
- **Constraints**: Hard 250K cap. Must split if plan has >10 tasks.

### VERIFY (Verifier Subagent)
- **Budget**: 30-60K tokens
- **Purpose**: Adversarial review of previous implementation
- **Agent**: `sandwich-verifier` subagent (separate context)
- **Output**: Findings, violations, spec alignment report
- **Critical**: Must be separate agent. Same-agent review = echo chamber.

### RECOVERY (Main session)
- **Budget**: 80-150K tokens
- **Purpose**: Revert failed approach, re-plan
- **Trigger**: Previous session failed, created broken state
- **Output**: Clean working state + new plan
- **Pattern**: Revert first, diagnose, plan alternative

### THESIS (Main session)
- **Budget**: 60-100K tokens
- **Purpose**: Multi-perspective adversarial analysis on a stock ticker
- **Agent**: Main Claude Code session
- **Output**: Thesis entry in `agent-workspace/memory/thesis-log/`
- **Critical**: Read-only on code. Never modifies domain logic. Bear case mandatory. See `invariants.md` I-S10.

### INGEST (Main session)
- **Budget**: 40-80K tokens
- **Purpose**: Process new data sources into knowledge base (news scraper, KOL transcript, macro doc)
- **Agent**: Main Claude Code session
- **Output**: Structured records in DB + raw files in appropriate store
- **Critical**: Every ingested item must have `source_url` + `extracted_at`. No LLM math on ingested numbers.

### POST_MORTEM (Main session)
- **Budget**: 30-50K tokens
- **Purpose**: Review thesis outcomes, update calibration data, log learnings
- **Agent**: Main Claude Code session
- **Output**: Post-mortem entry in `agent-workspace/memory/thesis-log/` + calibration updates
- **Trigger**: Thesis older than 6 months (cron alert) or explicit user request. See `invariants.md` I-S26.

---

## Decision Tree (used by `/plan-next-session`)

```
START
│
├─ Q1: Detailed plan already exists?
│   ├─ NO  → Type: PLAN
│   │       Agent: sandwich-architect
│   │       Budget: 50-80K
│   │       DONE.
│   │
│   └─ YES → Go to Q2
│
├─ Q2: How many tasks in plan?
│   ├─ 1-3 small → Type: FOCUSED_IMPL
│   │            Budget: 100-150K
│   │            Go to Q3
│   │
│   ├─ 4-10 → Type: MULTI_TASK_IMPL
│   │       Budget: 150-250K
│   │       Go to Q3
│   │
│   └─ >10 → SPLIT plan into 2+ sessions
│            Return to Q1 for each slice
│
├─ Q3: Previous session failed or left broken state?
│   ├─ YES → Type: RECOVERY (prepend)
│   │       Budget: 80-150K
│   │       Do recovery first, then planned work
│   │
│   └─ NO  → Proceed as planned
│
└─ Q4: Does previous session output need verification?
    ├─ YES → Schedule VERIFY after current work
    │       Budget: 30-60K for verifier
    │
    └─ NO  → Proceed
```

---

## Context Budget Estimation

When planning a session, estimate:

```
Fixed overhead (loaded every session):
├─ CLAUDE.md ............................... ~2.5K
├─ Constitution (all files) ................ ~3.0K
├─ project.md .............................. ~1.5K
├─ current-execution.md .................... ~0.5K
├─ Last 3 session logs ..................... ~3.0K
├─ Loaded skill definitions ................ ~1.5K
──────────────────────────────────────────────────
Total fixed ................................ ~12.0K

Variable (depends on work):
├─ Per bounded context loaded .............. ~5K  (glossary + mapping)
├─ Per Tier 2 spec loaded .................. ~4K
├─ Per Tier 3 spec loaded .................. ~2K
├─ Per code file likely to read ............ ~2K  (~500 LOC avg)
├─ Per code file likely to write ........... ~2K  (pre-write read)
├─ Extra skill/playbook ..................... ~1.5K each
└─ Working space for output ................. ~30% of total

If estimated > 250K → SPLIT required.
```

### Example Estimation

Session goal: "Implement vnstock price ingestion worker"

```
Fixed:                                   12K
+ Market Data BC context:                 5K
+ Ingest skill:                           2K
+ vnstock adapter pattern:                2K
+ Python worker pattern skill:            2K
+ vnstock API docs (web fetch):           5K
+ Files to write (~6 files @ 2K):        12K
+ Output working space (~30%):           12K
─────────────────────────────────────────────
Estimated total:                         52K  ✓ Well under 150K budget
```

---

## Budget Tracking During Session

### `/budget-check` command
Reports current session consumption. Use at:
- After loading major context
- Every 30 minutes during long sessions
- Before starting major new subtask

### Thresholds during session
- **<50% of budget**: normal, proceed
- **50-70%**: caution, avoid loading large new files unnecessarily
- **70-85%**: finalize current task, prepare handoff
- **>85%**: immediate handoff + session end
- **>250K hard cap**: stop immediately, emergency handoff

---

## Hard Rules

### R-1: Never mix PLAN + IMPL in same session
Session 4 in Phase2 project failed catastrophically doing this. 300K+ tokens, 0 tasks completed.

Causes:
- Plan thinking and implement thinking require different mental modes
- Context loads different files for each
- Agent "forgets" plan in middle of implement
- No clear checkpoint to stop and reassess

Always: separate sessions, separate subagents, fresh context.

### R-2: If plan has >10 tasks, SPLIT
- Plans with >10 tasks don't fit in 250K-token execution
- Quality drops after task 8-10 even if context allows
- Better to have 2 sessions of 5-6 tasks than 1 session of 12 tasks

### R-3: Recovery sessions revert first, then plan
Don't try to "fix" a broken state by adding more code. Revert to last known good, diagnose, plan alternative approach.

### R-4: Verify budget before loading
Before running a large context assembly operation, check projected size. If over budget, either:
- Reduce scope
- Split session
- Escalate to human

### R-5: Budget is wall-clock inclusive
Counting: input tokens + output tokens + tool use tokens. Not just messages.

### R-6: THESIS sessions are read-only on code
THESIS sessions produce thesis-log entries only. No production code changes in a THESIS session.
If a thesis reveals a code bug, log it in agent-notes.md for a future IMPL session.

---

## Mode A/B/C/D — Cliff vs Injector Dispatch (D-020, ratified 2026-05-04)

Per Opus 4.7 thresholds (D-004): wind-down at 180K / cliff at 220K / hard cap at 250K. The autonomous loop's handoff mechanism depends on which threshold the session crossed.

### Mode A — Stop without budget alert
`autonomous-stop-watchdog.sh` writes a minimal continue prompt; user's terminal pulls via `continue-injector.ps1` to resume mid-session. Same context window continues.

### Mode B — Cliff reached (≥220K), session must reboot
`budget-watchdog.sh` triggers `session-self-reboot.sh`. Fresh context window starts; new session reads `checkpoints/latest.md` to resume. Past 220K, transformer attention degrades ("lost in the middle"); fresh context is cheaper than degraded output.

### Mode C — Premature wind-down before cliff
`budget-watchdog.sh` flags mode-C event in JSONL telemetry (`failure_mode: C` per D-003 § 5.5c.5 REV-4); handoff prep proceeds; user resumes via continue-injector.

### Mode D — Clean handoff (S14 addition, L-S14-4)
`autonomous-stop-watchdog.sh` recognizes intentional close — checkpoint mtime ≤ 60 seconds AND no A/B/C alert fired. JSONL `failure_mode: D` (NOT a failure; "D = clean handoff").

### Dispatch Rule (deterministic — not per agent judgment)

```
budget < 180K + checkpoint fresh                     → Mode D (clean)
budget < 180K + no checkpoint                        → Mode A (continue-injector mid-session)
180K ≤ budget < 220K                                  → Mode C (wind-down; handoff prep)
budget ≥ 220K                                        → Mode B (cliff; session-self-reboot fresh ctx)
```

Cross-references `constitution/autonomous-protocol.md` Rule 2 (charter per D-015).

### Verifier Budget by Scope (L-S21-1)

| Scope | Token cap | Use case |
|---|---|---|
| Single-track (1-3 sessions, 1 decision) | 60-80K | Per-track close verification |
| Multi-track (5-10 sessions, 2-3 decisions) | 100-120K | Mid-phase checkpoint review |
| Whole-Phase (≥15 sessions, ≥5 decisions, full artifact set) | **150K** | Phase-boundary final verifier |

Pre-dispatch: estimate artifact LOC + count files; if ≥10K LOC + ≥30 files, target whole-Phase budget (150K). Mid-dispatch: if verifier returns "partial", accept if verdict + all 10 dimensions covered; do NOT re-dispatch for marginal completeness gain.

---

## When to Escalate

Budget-related escalations:
- Cannot fit planned work even with maximum budget → human decides: split, simplify, or defer
- Projected to exceed 250K despite compression → split is mandatory, but decide where
- Recovery session ballooning past 150K → stop, may need new approach entirely

Output format:
```
BUDGET ESCALATION

Session type: MULTI_TASK_IMPL
Planned tasks: 8
Estimated budget: 340K tokens (exceeds 250K limit)

Options:
1. Split into 2 sessions of 4 tasks each
2. Reduce scope — defer tasks 7-8 to next session
3. Different approach — [alternative]

Recommendation: Option 1 (clean split at task 4/5 boundary — natural break).

Awaiting decision.
```
