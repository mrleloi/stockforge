# /block — Human-Gate Control (status / clear / raise)

> Created 2026-05-14 (S317 post-incident) per user request: make block/unblock "as simple
> as possible, deterministic hook/script the agent can toggle easily — like /autonomous".
> Thin wrapper over `scripts/hooks/block-control.sh` — the single interface for the
> "agent hits a block / q&a / confirm / decision → notify human → human approves → resume" loop.

## The loop this supports

1. Agent hits something needing a human (block / Q&A / confirm / decision) →
   runs `block-control.sh raise` → writes the `.autonomous-BLOCKED` flag + **Telegram push**.
2. `autonomous-block-enforcer.sh` (PreToolUse) then blocks Edit/Write/MultiEdit/Agent + most
   Bash until the gate clears. Read/Glob/Grep + `block-control.sh` itself stay allowed.
3. Human reads the Telegram, sees the reason + recommendations.
4. Human **just replies** `approved` / `unblock` / `run autonomous` / `go ahead` / `tiep tuc` —
   `block-control.sh check-prompt` (UserPromptSubmit hook) auto-clears the gate. No file ops.
5. `clear` also writes a 30-min `.block-grace` marker so `escalation-engine.sh` won't instantly
   re-raise the same CRITICAL — giving the agent room to fix the root cause.

## Usage

| Form | Effect |
|---|---|
| `/block` | Same as `/block status` |
| `/block status` | Report gate state — BLOCKED (+ flag content) or CLEAR (+ grace remaining) |
| `/block clear` | Clear the gate now (flag + stale `.severity-state.tsv` + `.auto-reboot-PRE-BLOCKED-*` markers; writes `.block-grace`) |
| `/block raise <severity> <slug> -- <reason / recommendation>` | Manually raise a gate + Telegram push. `<severity>` = CRITICAL\|HIGH\|MEDIUM\|LOW |

## Agent execution instructions

This command is a thin pass-through. For ALL forms, run the script and report its stdout verbatim (1-3 lines):

- `/block` or `/block status` → `bash scripts/hooks/block-control.sh status`
- `/block clear` → `bash scripts/hooks/block-control.sh clear user-via-/block`
- `/block raise <sev> <slug> -- <reason>` → `bash scripts/hooks/block-control.sh raise <sev> <slug> -- <reason>`

`block-control.sh` is exempt from the `autonomous-block-enforcer.sh` Bash block (escape hatch),
so `/block status` and `/block clear` work **even while the gate is active**.

## How the agent should RAISE a gate (not via this command)

When the agent itself hits a block/Q&A/confirm/decision mid-task, it does NOT need this command —
it runs the script directly:

```bash
bash scripts/hooks/block-control.sh raise HIGH <short-slug> -- <one-paragraph reason + the recommendation the human should approve>
```

Then end the turn with a one-paragraph status. The human resumes by replying with an approval keyword.

## Relationship to /autonomous

- `/autonomous on|off` — toggles whether the autonomous loop runs at all (continue-injector + budget-watchdog).
- `/block` — a **pause on top of** the autonomous loop: "stop and wait for a human decision", then resume.

They are independent. A gate raised by `/block` (or by `block-control.sh raise`, or auto-raised by
`escalation-engine.sh` on a CRITICAL) pauses work regardless of `/autonomous` state; clearing it
resumes at whatever the `/autonomous` state is.

## Hard rules

- This command bypasses NO other safety gate (`destructive-command-guard.sh`, drift-signals,
  charter immutability, write-vs-edit-guard, etc. all still active).
- `clear` is decisive: it removes the flag + the stale severity cache + false-positive
  auto-reboot markers, and opens a grace window. It does NOT resolve the underlying root cause —
  if a real CRITICAL artifact persists past the 30-min grace, `escalation-engine.sh` re-raises.
- Approval-keyword auto-clear has a negation guard ("do not unblock", "keep blocked", etc. are
  ignored) — but it is still keyword-based; when in doubt, the human can run `/block clear` explicitly.
- Idempotent: `raise` will not overwrite an already-active gate; `clear` on an already-clear gate
  is a harmless no-op that just refreshes the grace window.

## Companion artifacts

- Script: `scripts/hooks/block-control.sh` (raise / clear / status / check-prompt)
- Enforcer: `scripts/hooks/autonomous-block-enforcer.sh` (PreToolUse gate + escape hatch)
- Auto-raiser: `scripts/hooks/escalation-engine.sh` (CRITICAL → raise; respects `.block-grace`)
- Firing-test: `scripts/hooks/firing-tests/block-control-fire-test.sh`
- Wired: `.claude/settings.json` — `block-control.sh check-prompt` is first in the UserPromptSubmit chain.
