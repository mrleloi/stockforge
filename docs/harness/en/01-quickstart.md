# Chapter 1 — Quickstart

> **Diataxis quadrant**: Tutorial (learning-by-doing)
> **Reading time**: ~30 minutes hands-on
> **Prerequisites**: Claude Code installed, this repository cloned, Python 3.11+, shell access

This chapter takes you from "I have never seen this harness" to "I have run one full session through it". You will:

1. Bootstrap a session.
2. Watch the harness load context.
3. Dispatch a sandwich-pattern subagent.
4. Observe a hook fire.
5. Close the session cleanly.

If anything in the output surprises you, that is intentional — the goal is to *see* the harness, not just read about it.

---

## Step 1 — Open a Session

In a terminal at the project root:

```bash
cd /c/htdocs/stockforge
claude
```

Claude Code starts. Behind the scenes, the harness has already fired **22 SessionStart hooks** in sequence. You can verify by tailing the hook log:

```bash
tail -30 agent-workspace/memory/.session-hooks.log
```

You should see entries like:

```
[2026-05-19T01:05:12+07:00] SessionStart session=abc... cwd=/c/htdocs/stockforge profile=standard
[2026-05-19T01:05:12+07:00] single-claude-instance-lock: acquired lock pid=...
[2026-05-19T01:05:13+07:00] essential-routing-fields-verifier: OK current-execution.md autonomous_mode=true
[2026-05-19T01:05:13+07:00] working-memory-budget-audit: under-ceiling 17320B/20480B
[2026-05-19T01:05:13+07:00] session-start-bootstrap: latest checkpoint loaded
...
[2026-05-19T01:05:14+07:00] continue-injector-spawn: skipped (not /clear path)
```

Each of these lines is a hook reporting in. None of them blocked the session. If any had blocked, you would see an error context instead.

**What just happened**: the harness verified the workspace is in a known-good state, loaded the routing file (`agent-workspace/memory/current-execution.md`), measured the working-memory load, checked for stale Q&A bundles, scanned for in-flight subagents from a previous session, and audited 12 health signals. All before Claude said hello.

---

## Step 2 — Type `/session-start`

```
/session-start
```

This is a [slash command](05-skills-commands-agents.md#commands). It is a thin wrapper that does what you would otherwise have to do manually: load the routing file, identify the session type, estimate budget, look up matching plans, and produce a brief.

The output will look something like:

```markdown
# Session Brief — 2026-05-19 Session N

## Goal
[Inferred from current-execution.md active focus]

## Session Type
[PLAN | FOCUSED_IMPL | ... | THESIS] — chosen via decision tree in
agent-workspace/constitution/session-budgets.md

## Context Budget Estimate
- Fixed overhead: 12K / Variable: 25K / Working: 60K → Total: ~97K (of 250K cap)

## Status Check
- Active phase: Phase 4 — Multi-perspective (Wave 1 Phase D NDH adapter)
- Recent sessions (last 3):
  - S407 — plan-044 G.4 IMPL SHIPPED
  - S408 — plan-044 G.4 VERIFY PASS-WITH-CONCERNS
  - S409 — this one
- Pending from last session: none

## Files Loaded / Skills Relevant / Constraints Active
[Lists]

## Proposed Next Actions
1. ...
2. ...

Ready to proceed? Confirm or adjust.
```

**What just happened**: the agent loaded six memory files in priority order (per [Reading Priority](../../../agent-workspace/CLAUDE.md)), identified that you are in the middle of Phase 4, estimated how much context budget the session will consume, and produced a brief that *you* can sanity-check before any real work begins.

This is the harness pattern in microcosm: **deterministic loading + structured proposal + human confirmation gate**.

---

## Step 3 — Dispatch a Sandwich Architect

Suppose your goal is to add a small feature. The harness's discipline says: **never plan and implement in the same session**. Plan first, implement next.

Type:

```
/master-plan add support for VPB ticker to the thesis runner
```

The `/master-plan` command dispatches the [`master-planner`](05-skills-commands-agents.md#master-planner) subagent in a fresh context. You will see a notification like:

```
Async agent launched successfully.
agentId: ab7f3a9d...
```

The agent is now working in parallel. It reads:

- The charter (`PROJECT_CHARTER.md`)
- The active phase (`current-execution.md`)
- The relevant constitution files
- Existing plans in `session-plans/pending/`
- Similar past plans in `session-plans/completed/`

After ~2-5 minutes, you receive a completion notification:

```
<task-notification>
<status>completed</status>
<summary>Master plan written to session-plans/pending/NNN-S<sid>-vpb-thesis.md</summary>
</task-notification>
```

Read the new plan. It will be ~700-1100 lines, structured into sections A-N, with VBW step zero, sub-tracks, file scope, DoD, and risks. **The architect did not write any production code**. That is a separate session.

**What just happened**: you watched the [sandwich pattern](08-lifecycle.md#sandwich-pattern) begin. Step 1 of 3 (architect) is complete. Step 2 (dev) and Step 3 (verifier) follow in their own sessions, each with their own context.

---

## Step 4 — Observe a Hook Block You

Try to do something the harness does not allow:

```
git push origin main
```

You will get blocked. Output:

```
[BLOCK] git push is in the .claude/settings.json deny list.
Agents MAY commit; agents MUST NOT push.
See agent-workspace/CLAUDE.md § Contract Rule 6.
```

The block came from the [`destructive-command-guard.sh`](06-hooks.md#destructive-command-guard) PreToolUse hook reading the settings.json deny rule before the Bash tool ever ran.

Try another:

```
rm -rf agent-workspace/
```

Also blocked. This time the block comes from the same hook matching the `rm -rf` pattern. The hook was authored on 2026-05-14 in direct response to a **real mass-deletion incident** that lost ~2688 files. The post-mortem is at [`agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md`](../../../agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md).

**What just happened**: you experienced [defense-in-depth](06-hooks.md#defense-in-depth). The deny list catches *categories* of destructive command, not specific instances. There are 118 such guards layered across 9 hook events.

---

## Step 5 — Watch the Stop Chain Fire

End your session with `/session-end` or simply type `exit`. The harness fires its Stop chain — **over 50 hooks** in sequence:

```bash
tail -60 agent-workspace/memory/.session-hooks.log
```

You will see entries like:

```
[2026-05-19T01:35:42+07:00] Stop session=abc...
[2026-05-19T01:35:42+07:00] pre-clear-handoff-guard: OK
[2026-05-19T01:35:42+07:00] tracking-retention: current-execution.md=180 LOC (cap 200) PASS
[2026-05-19T01:35:42+07:00] budget-watchdog: tokens=97000 / 250000 (38%) — under wind-down threshold
[2026-05-19T01:35:43+07:00] charter-coherence-spot: 0 violations
[2026-05-19T01:35:43+07:00] adr-empirical-close-verify-spot-check: no new ADRs this session
[2026-05-19T01:35:43+07:00] drift-signals-D1-D9: PASS (0 high / 0 medium)
[2026-05-19T01:35:44+07:00] sync-tracker-auto-update: 1 event recorded
[2026-05-19T01:35:44+07:00] cost-ledger-recorder: 0.0247 USD ledgered
[2026-05-19T01:35:45+07:00] severity-classifier: 0 CRITICAL / 0 HIGH / 1 MEDIUM (stale-checkpoint)
[2026-05-19T01:35:45+07:00] escalation-engine: MEDIUM → digest only
[2026-05-19T01:35:45+07:00] session-end-checklist-linter: PASS
[2026-05-19T01:35:46+07:00] daily-backup: SKIP (already backed up today)
```

What you are watching is the harness's **end-of-session checklist** running deterministically. It:

- Verified you do not have un-handed-off work (`pre-clear-handoff-guard`)
- Rotated tracking files if over the cap (`tracking-retention`)
- Computed the dollar cost of your session (`cost-ledger-recorder`)
- Detected any drift signal violations (`drift-signals-D1-D9`)
- Classified severity of any pending items (`severity-classifier`)
- Decided whether to escalate to you (`escalation-engine`)
- Linted that you recorded mistakes or attested zero (`session-end-checklist-linter`)

If any check produced a CRITICAL or HIGH severity, you would have seen an `urgent.md` notification and (if configured) a Telegram message.

**What just happened**: the session closed cleanly. The harness has written everything to disk that the next session needs: an updated `current-execution.md`, a fresh session log at `agent-workspace/memory/sessions/2026-05-19-session-N.md`, a checkpoint at `agent-workspace/memory/checkpoints/latest.md`, and append-only telemetry.

---

## What You Just Saw

In 30 minutes, you observed:

| Layer | Example |
|---|---|
| **Hooks** | 22 SessionStart + 50+ Stop firing in order |
| **Commands** | `/session-start`, `/master-plan`, `/session-end` |
| **Subagents** | `master-planner` dispatched into a fresh context |
| **Memory** | `current-execution.md`, session log, checkpoint |
| **Constitution** | `boundaries.md` deny list (push, rm -rf) |
| **Severity system** | classifier → escalation engine → notification |
| **Cost tracking** | dollar amount logged per session |
| **Drift detection** | 9 signals run automatically on close |

This is the whole framework in miniature. Every chapter that follows is a deeper look at one of these layers.

---

## Where to Go Next

Pick based on what you want to do:

| If you want to... | Read |
|---|---|
| Understand *why* the harness is shaped this way | [Chapter 2 — Mental Model](02-mental-model.md) |
| See the system map at a glance | [Chapter 3 — Architecture](03-architecture.md) |
| Learn the immutable rules | [Chapter 4 — Constitution](04-constitution.md) |
| Add your own skill/command/subagent | [Chapter 11 — Cookbook](11-cookbook.md) |
| Audit the harness for drift | [Chapter 9 — Quality System](09-quality-system.md) |
| Read it cover to cover | Continue to [Chapter 2](02-mental-model.md) |

---

## Troubleshooting

If any of the steps above failed:

**`/session-start` says "current-execution.md missing"** — the harness is in a damaged state. See [Chapter 11 § Recovery](11-cookbook.md#recovery-from-incident).

**Hook log is empty** — hooks may not be wired. Check `.claude/settings.json` has the `hooks` block populated. If it does, run `bash scripts/hooks/firing-tests/run-all.sh` to verify hook scripts execute. (See [Chapter 6 § Firing-Tests](06-hooks.md#firing-tests).)

**`/master-plan` returns immediately with no plan written** — the subagent dispatch failed. Check `agent-workspace/memory/dispatch.jsonl` for the failure row. See [Chapter 6 § Telemetry](06-hooks.md#telemetry).

**You see `[BLOCK]` on every command** — the autonomous-block flag is set. Read `human-workspace/notifications/urgent.md` for the reason, resolve it, then `/block clear`.

For anything else, see the [Glossary](15-glossary.md) and [Reference](13-reference.md).
