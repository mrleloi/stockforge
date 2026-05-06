---
post_mortem_id: 2026-05-05-S45-agent-notes-data-loss
session: S45
date: 2026-05-05
severity: CRITICAL
classification: substrate-tier — actual data loss + recovery gap
related_lessons: L-S45-1 / L-S45-2 / L-S44-1 (self-pause recurrence)
related_decisions: D-026 (Rule 4b mandates this synthesis)
---

# Post-Mortem — S45 sandwich-architect destroyed agent-notes.md

## What happened

The S45 sandwich-architect subagent (`agent-abee75e2518d36e62`, dispatched
2026-05-05 ~07:40 +07:00 from the main session) called `Write` on
`agent-workspace/memory/agent-notes.md` at tool-event L72 (1570-char payload)
and L84 (5131-char payload), destructively overwriting ~470 LOC of accumulated
learned rules with: first a ~40 LOC stub (L72), then a self-authored
"RECOVERY NOTICE" (L84) that incorrectly assumed git-tracked rollback was
available.

Recovery via `git checkout HEAD -- <file>` was **impossible**: the repo had
no git history at all (`git status` reported "no commits yet"). User had
been operating per S43c instruction "git thì không cần release, bỏ qua"
(skip releases) — never staged or committed.

Forensic transcript-mining of CCS instance JSONL caches yielded:
- Lines 1..314 (verbatim) from `31a5f363-a178-41f8-b688-67b1b4cb7e41.jsonl:L33`
  — largest cached pre-incident Read
- Lines 455..470 (verbatim) from `agent-abee75e2518d36e62.jsonl:L67`
  — S45 subagent's own partial Read at offset=455 BEFORE the destructive Write
- Lines 315..454 (~140 lines / ~30K chars) — **PERMANENTLY UNRECOVERABLE**

Recovered file = 409 LOC vs original ~470 LOC; gap marker explicitly inserted
listing the lesson IDs known to have lived in the gap (per checkpoints/
sessions/current-execution.md provenance).

## Root cause (4-layer analysis)

**L1 — surface (LLM tool-choice error)**: Subagent decided to "add an entry
to agent-notes.md per Rule 4b" and chose `Write(file_path, content=<just
the new entry>)` instead of `Edit(file_path, old_string=<anchor>,
new_string=<anchor>+<new entry>)`. This is a basic tool-semantics mistake:
`Write` overwrites; `Edit` performs surgical insertion. Pure LLM judgment
error.

**L2 — tool-safety bypass**: Anthropic's tool-level Read-before-Write safety
blocker only fires when the file has not been Read at all in the current
session. The subagent had performed PARTIAL Reads (limit=40 at L56,
offset=455 at L66, offset=468 at L69) BEFORE the destructive Write at L72.
The safety blocker considered the file "Read" and permitted the Write.
Partial-Read does NOT equal full-Read for safety purposes — but the blocker
treats them identically. **Harness gap**: no PreToolUse hook was guarding
the Write tool against append-only file paths.

**L3 — substrate fragility (no git baseline)**: The repo had zero commits.
S43c carry-forward "git thì không cần release, bỏ qua" was interpreted as
"never commit at all" rather than "don't push releases". Result: no
rollback path for any file mutation. A single destructive Write was
unrecoverable except via cache forensics. **User-process gap**: even an
initial `git init && git commit` baseline would have made `git checkout
HEAD --` recovery trivial.

**L4 — session protocol fragility (Rule 4b cascade)**: The subagent was
trying to OBEY just-ratified Rule 4b ("lesson-synthesis mandatory at
session-end") which mandates appending to agent-notes.md when triggers fire.
The mandate accelerated the path-to-tool-error: subagent felt urgency to
ship the L-S45-1 entry → reached for Write impulsively → destruction.
Rule 4b is correct in policy but did not specify the tool to use.
**Documentation gap**: Rule 4b in `decision-discipline.md` should explicitly
require Edit (not Write) for the agent-notes.md append.

## Prevention rules

- **(a) MECHANICAL — PreToolUse HARD-BLOCK** ✅ SHIPPED same-turn:
  `scripts/hooks/write-vs-edit-guard.sh` (~85 LOC; bash + POSIX per L-S11-1).
  Blocks `Write` calls targeting `agent-workspace/memory/{agent-notes,
  project,mistake-log,current-execution}.md` + `agent-workspace/{constitution,
  proposals}/**`. Allows first-creation when file absent. Allows all `Edit`
  calls. Wired into `.claude/settings.json` PreToolUse chain after
  `dispatch-jsonl-recorder.sh`. 4/4 smoke-test cases green.

- **(b) PROCESS — git baseline** ✅ DONE this turn (user ran):
  `git init && git add -A && git commit -m "baseline before further work"`.
  Future destructive incidents become recoverable via `git checkout HEAD --`.
  Recommend periodic baseline commits at phase boundaries.

- **(c) DOCTRINE — agent-notes.md self-protection**: Rule L-S45-2 codifies
  "Edit not Write for append-only files" as agent-side doctrine. Promotion
  priority per Q-E3:
    - HOOK = ✅ DONE (this turn — write-vs-edit-guard.sh)
    - SKILL = not warranted (mechanical rule, no LLM judgment)
    - CHARTER = pending IF L-S45-2-violation recurs ≥3 times Phase 3
      (would warrant adding "use Edit not Write for agent-notes.md" to
      decision-discipline.md § Rule 4b body)

- **(d) RECOVERY — cache forensics playbook**: For future similar incidents,
  the recovery path is documented in `scripts/recover-agent-notes.py` (this
  turn). Pattern: scan `~/.ccs/instances/<user>/projects/<project>/**/*.jsonl`
  for `Agent Notes` (or analogous header) in tool_result content; rank by
  size; extract verbatim text from largest-cached snapshot; apply line-number
  prefix stripping; merge with explicit gap markers. NEVER fabricate
  body-text reconstruction.

## Where applied (S45 ship)

- `scripts/hooks/write-vs-edit-guard.sh` (NEW; PreToolUse HARD-BLOCK)
- `.claude/settings.json` (EDIT; +1 hook entry in PreToolUse chain)
- `scripts/hooks/autonomous-stop-watchdog.sh` (EDIT; SELF_PAUSE detector
  regex extended to catch "wait for your call" / "deferring to you" /
  "standing by" — L-S44-1 recurrence prevention)
- `scripts/recover-agent-notes.py` (NEW; one-shot recovery executed)
- `agent-workspace/memory/agent-notes.md` (RECOVERED; 409 LOC; gap marker
  for lines 315..454; +L-S45-1 + L-S45-2 entries)
- `agent-workspace/memory/current-execution.md` (EDIT; S45 incident row)
- `agent-workspace/memory/mistake-log.md` (EDIT; +M-S45-1 entry — see
  companion file)

## Companion incident in same turn

Mid-turn the main session (this assistant) ALSO produced a Mode-E self-pause
("I'll wait for your call") when surfacing the incident, which the user
caught with "why not autonomous run?". This is a RECURRENCE of L-S44-1 —
same family of failure (deterministic detector missing visibility on a known
LLM failure pattern). The autonomous-stop-watchdog.sh detector regex was
already extended this turn (per § (d) above) to catch the new phrasing.

This is a 2-incident-same-turn cluster: substrate-tier data loss
(sandwich-architect) + session-protocol self-pause (main session). Both
classified as harness/deterministic gaps NOT pure LLM unreliability — the
LLM did make tool-choice errors, but the harness allowed destructive
outcomes that mechanical guards could have prevented. Both gaps now closed
mechanically same-turn.
