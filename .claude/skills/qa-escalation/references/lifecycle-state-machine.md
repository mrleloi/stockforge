# Q&A Bundle — Lifecycle State Machine

> Companion to `qa-escalation/SKILL.md`. Defines the 4 states + valid transitions.

## States

| State | Filesystem location | Meaning |
|---|---|---|
| `pending` | `human-workspace/q-and-a/pending/<file>` | Agent has opened bundle; human has not yet replied. |
| `answered` | `human-workspace/q-and-a/answered/<file>` | Human moved file here with answers filled in. Agent must read on next session. |
| `stale` | `human-workspace/q-and-a/stale/<file>` | `expected_answer_by` exceeded; agent applies defaults. |
| `processed` | n/a (frontmatter `status: processed`) | Agent has consumed the answers and updated related decisions. File stays in `answered/`; status field changes. |

## Transitions

```
                       ┌────────────────────┐
   agent writes ──────►│      pending       │
                       └─────────┬──────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │ human moves      │ Track 5 hook      │ agent supersedes
              │ (with answers)   │ (timeout)         │ (writes new bundle)
              ▼                  ▼                   ▼
       ┌─────────────┐    ┌────────────┐     ┌────────────────┐
       │  answered   │    │   stale    │     │   superseded   │
       │ (status:    │    │            │     │  (kept in      │
       │  answered)  │    └─────┬──────┘     │   pending/ as  │
       └──────┬──────┘          │            │   archive)     │
              │                 │            └────────────────┘
              │ agent reads     │ agent applies
              │ + acts          │ defaults
              ▼                 ▼
       ┌─────────────┐    ┌────────────┐
       │  processed  │    │ defaulted  │
       │ (status:    │    │ (defer_    │
       │  processed) │    │  cycle++)  │
       └─────────────┘    └────────────┘
```

## Owner per state

| State | Who can act |
|---|---|
| `pending` (write file) | Agent (this skill) |
| `pending → answered` | Human (moves file manually, or via mobile claude.ai) |
| `pending → stale` | Track 5 hook (deterministic, no LLM) |
| `pending → superseded` | Agent (when bundle is replaced) |
| `answered → processed` | Agent (updates `status` frontmatter, no file move) |
| `stale → defaulted` | Agent (applies defaults; updates `defer_cycle`) |

## Edge cases

### Human edits in pending/ instead of moving

If agent finds a `pending/` file with answer-section filled but file location unchanged:
- Treat as accidental — file is still pending until moved.
- Optionally write a `human-workspace/notifications/N-<TS>-INFO-reminder.md` to remind: "move bundle to answered/ to trigger processing."
- DO NOT auto-move; that breaks the contract (only human moves into answered/).

### Bundle answered after stale move

Sequence:
1. Bundle in `pending/` past expected_answer_by → hook moves to `stale/`.
2. Agent applies defaults, processes.
3. Human later returns and writes answers into the `stale/` file.

This is a contract ambiguity. Resolution:
- If `defer_cycle` ≤ 3: agent re-opens by writing a fresh bundle in `pending/` with `supersedes: <stale-file>` and copies human's late answers as the seed.
- If `defer_cycle > 3`: agent escalates via notification — late answers cannot resurrect a >3-cycle deferred decision automatically; needs explicit user direction.

### Bundle superseded mid-flight

Sequence:
1. Agent writes Bundle A.
2. Charter changes mid-flight (new user prompt drops).
3. Bundle A is now obsolete.

Resolution:
- Agent writes Bundle B with `supersedes: A`.
- Bundle A's frontmatter updated: `status: superseded` and stays in `pending/` for audit (do not delete).
- Bundle A's `related_decisions` updated: `defer_cycles += 1`.

### Hook moves wrong file

If the timeout hook misjudges expected_answer_by (timezone bug, etc.):
- Agent on read can detect inconsistency (status field vs file location).
- Agent fixes by writing fresh bundle in `pending/` `supersedes: <misplaced-file>` and adds note in `agent-workspace/memory/drift-logs/<TS>-DR-HOOK.md`.

## Confidence Score (Track 8a) Coupling

Each state transition is a Confidence Score event:

| Transition | Effect on weights.yaml |
|---|---|
| `pending → answered` | `+0.5` to each `sync_category` listed in bundle (per Q&A A5 weight) |
| `pending → stale` | `-0.2` to `DECISION_ROUTING` (escalation cost incurred without resolution) |
| `pending → superseded` | `0` (bundle invalidated, neither sync nor cost) |
| `answered → processed` | `+0.5` additional after agent has actually consumed answers (proves the loop closed) |

These hooks fire when Track 8a is online (not yet — Track 8a is S6).

## Drift Signals

- DR-QA-1: `pending/` file ≥ 14 days old without move → human disengagement signal
- DR-QA-2: same `topic` opened in `pending/` ≥ 3 times within 30 days → bundle composition issue (questions unclear or premature)
- DR-QA-3: `defer_cycle > 3` on any decision → can-kicking; force resolution

These will be wired into Track 5 drift hooks when ready.
