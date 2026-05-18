# Chapter 11 — Cookbook

> **Diataxis quadrant**: How-to (problem-solving)
> **Reading time**: ~45 minutes (or jump to the recipe you need)
> **Prerequisites**: Chapter 3 (Architecture) for layer context

This chapter is a collection of recipes. Each recipe is a complete procedure for a recurring task. Use this chapter when you have a specific job to do and want the shortest path from problem to solution.

Recipes assume you already understand the *concepts*; if not, follow the cross-references back to the relevant explanation chapter.

---

## Table of Recipes

- [Recipe 1 — Write a New Skill](#recipe-1--write-a-new-skill)
- [Recipe 2 — Write a New Slash Command](#recipe-2--write-a-new-slash-command)
- [Recipe 3 — Write a New Subagent](#recipe-3--write-a-new-subagent)
- [Recipe 4 — Write a New Hook](#recipe-4--write-a-new-hook)
- [Recipe 5 — Run a Sandwich Cycle](#recipe-5--run-a-sandwich-cycle)
- [Recipe 6 — Audit for Drift](#recipe-6--audit-for-drift)
- [Recipe 7 — Recover from an Incident](#recipe-7--recover-from-an-incident)
- [Recipe 8 — Dispatch Parallel Agents](#recipe-8--dispatch-parallel-agents)
- [Recipe 9 — Set Up Telegram Alerts](#recipe-9--set-up-telegram-alerts)
- [Recipe 10 — Promote a Rule](#recipe-10--promote-a-rule)
- [Recipe 11 — Run an ADR Through the Lifecycle](#recipe-11--run-an-adr-through-the-lifecycle)
- [Recipe 12 — Add a New Constitution Rule](#recipe-12--add-a-new-constitution-rule)
- [Recipe 13 — Archive an Old Session](#recipe-13--archive-an-old-session)
- [Recipe 14 — Debug a Silent Hook](#recipe-14--debug-a-silent-hook)
- [Recipe 15 — Run a THESIS Session](#recipe-15--run-a-thesis-session)

---

## Recipe 1 — Write a New Skill

**When to use**: You have identified a pattern that has appeared in 3+ sessions and you want to formalize it so future sessions auto-discover and apply it.

**Prerequisites**:
- The pattern is LLM-mediated (not deterministic enough for a hook)
- It is reusable (not a one-off)
- It is not already documented as a constitution rule

**Procedure**:

1. **Choose a kebab-case name** that captures the action. Examples: `evidence-extraction`, `try-n-approaches`, `crawler-reliability`.

2. **Create the directory**:
   ```bash
   mkdir -p .claude/skills/<name>/{examples,references}
   ```

3. **Author `SKILL.md`** with this structure:
   ```markdown
   ---
   name: <name>
   description: <one-line discovery match — lead with action verb + keywords>
   allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
   ---

   # Skill: <Title>

   ## Purpose
   <one paragraph>

   ## When to Use
   - Trigger 1
   - Trigger 2

   ## When NOT to Use
   - Non-trigger 1
   - Non-trigger 2

   ## Process / Content
   <the actual procedure — steps, examples>

   ## Anti-Patterns
   - 3+ concrete bad examples

   ## Related Skills
   - [[other-skill]]
   ```

4. **Target ≤120 LOC** (per L-S14-1). If content grows past that, extract to `references/<topic>.md`.

5. **Write the `description`** carefully — it is the discovery match. Lead with the core action verb. Include domain keywords. Example:
   - **Bad**: "Helps with X."
   - **Good**: "Extract structured claims from VN news articles with citation integrity. Use when ingesting CafeF / NDH / VietnamBiz content; enforces I-S1 no-LLM-math + I-S2 source+as_of date."

6. **Test trigger**: in a fresh session, mention something matching the description. Verify the skill becomes available.

7. **Document**: add to [Reference § Skills](../reference/inventory-skills.md) or run `/harness-docs sync`.

---

## Recipe 2 — Write a New Slash Command

**When to use**: The user wants a typed shortcut for a common action. The command should be a thin wrapper.

**Anti-pattern**: duplicating the procedure between a `<name>` skill and a `/<name>` command (L-S14-2). Pick one canonical implementation; the other invokes.

**Procedure**:

1. **Choose a kebab-case name**.

2. **Create the file** at `.claude/commands/<name>.md`.

3. **Use this template**:
   ```markdown
   # /<name> — <One-line purpose>

   > Optional aside.

   ## When to Use
   <concrete triggers>

   ## Input
   <optional $ARGUMENTS or stdin>

   ## Steps
   1. <numbered>
   2. ...

   ## Output Schema
   <what the user sees>

   ## Error Handling
   <how it fails gracefully>

   ## Anti-Patterns
   - 3+ concrete bad examples

   ## Related
   - <links to skill / subagent / other commands>
   ```

4. **Keep it ≤96 LOC** (D1 ceiling for commands).

5. **If delegating to a skill**: body says "delegates to `<skill-name>` skill" with minimal restatement.

6. **If dispatching a subagent**: body says "dispatches `<agent-name>` subagent" with the prompt template.

7. **Document**.

---

## Recipe 3 — Write a New Subagent

**When to use**: You need a persona that does work in **fresh context** (not inheriting the parent session's transcript). Common cases: adversarial review, planning, calibration analysis.

**Procedure**:

1. **Choose a kebab-case name**.

2. **Create the file** at `.claude/agents/<name>.md`.

3. **Frontmatter**:
   ```yaml
   ---
   name: <name>
   description: <one-line summary; matched against task at dispatch time>
   model: opus  # or sonnet / haiku
   tools: [Read, Glob, Grep, Write, Edit, Bash]  # minimal grant
   ---
   ```

4. **Body sections**:
   ```markdown
   # Subagent: <Title>

   ## Persona
   <who this agent is; mindset>

   ## Responsibility
   <what they own>

   ## Input
   <what the dispatch must provide>

   ## Process
   ### Phase 1: Comprehend
   ### Phase 2: ...

   ## Output Contract
   <structured return format>

   ## Anti-Patterns
   <what this agent must NOT do>
   ```

5. **Keep it ≤160 LOC** (D1 ceiling for agents).

6. **Minimal-grant tools**: only what the agent needs. Verifier should NOT have Write (per PCG-S401-4).

7. **Test by dispatching**: in a session, dispatch via `Agent(subagent_type='<name>', prompt='<test prompt>')` and verify the agent behaves per persona.

8. **Document**.

---

## Recipe 4 — Write a New Hook

**When to use**: You have a rule that is statically detectable (regex / grep / file-existence check), and the rule has appeared 2+ times (per AP-23 promotion threshold).

**Procedure**:

1. **Choose the right event**: SessionStart? Stop? PreToolUse? PostToolUse? UserPromptSubmit? See [Chapter 6 § 6.1](06-hooks.md#61--the-event-model).

2. **Create the script** at `scripts/hooks/<name>.sh`:
   ```bash
   #!/usr/bin/env bash
   # <name>.sh — <one-line purpose>
   # Trigger: <event> (per .claude/settings.json:<line>)
   # Origin: <lesson ID> / <ADR>
   # Severity: <info | warn | block (RC=2)>
   # <other meta>
   set -uo pipefail
   trap 'exit 0' ERR  # most hooks should not block on internal error

   PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
   SID="${CLAUDE_SESSION_ID:-unknown}"
   TS="$(date -Iseconds)"

   # <checks here>

   exit 0  # or non-zero if blocking
   ```

3. **Idempotency markers** (if Stop-tier): use hour-bucket or day-bucket markers to avoid duplicate work across rapid Stop fires.

4. **Same-session caching** (if UserPromptSubmit-tier): cache results in `.<hook>-cache-${SID}` with TTL.

5. **Honor `STOCKFORGE_HOOK_PROFILE`** env: warn-only by default; strict mode blocks.

6. **Write the firing-test** at `scripts/hooks/firing-tests/<name>-fire-test.sh`:
   ```bash
   #!/usr/bin/env bash
   # <name>-fire-test.sh — companion firing test
   # SPAWN-CONTEXT: positional  ← required if non-default arg form
   set -uo pipefail

   TEMPDIR=$(mktemp -d)
   trap "rm -rf $TEMPDIR" EXIT
   export CLAUDE_PROJECT_DIR="$TEMPDIR"

   # TC1: positive case
   # <setup synthetic stdin or files>
   echo '{"session_id":"test","tool_input":{"command":"safe"}}' | bash "$HOOK_PATH"
   rc=$?
   [ $rc -eq 0 ] || { echo "TC1 FAIL: expected RC=0, got $rc"; exit 1; }
   echo "TC1 PASS"

   # TC2: negative case (should block)
   echo '{"session_id":"test","tool_input":{"command":"rm -rf /"}}' | bash "$HOOK_PATH"
   rc=$?
   [ $rc -eq 2 ] || { echo "TC2 FAIL: expected RC=2, got $rc"; exit 1; }
   echo "TC2 PASS"

   # TC3..N: edge cases

   echo "ALL PASS"
   exit 0
   ```

7. **Wire in `.claude/settings.json`** at the right event + order:
   ```json
   "Stop": [
     {
       "hooks": [
         ...,
         {
           "type": "command",
           "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/<name>.sh\""
         },
         ...
       ]
     }
   ]
   ```
   Pay attention to order coupling (e.g., must run AFTER `severity-classifier.sh`).

8. **Verify**:
   ```bash
   bash scripts/hooks/firing-tests/<name>-fire-test.sh
   bash scripts/hooks/firing-tests/run-all.sh  # full regression
   ```

9. **Verify production firing** (Principle 11): in next real session, check `.session-hooks.log` shows the hook firing. Do NOT declare done until production evidence captured.

10. **Document**.

---

## Recipe 5 — Run a Sandwich Cycle

**When to use**: You have a feature or refactor that needs implementation. Sandwich pattern is canonical for non-trivial work (>30 LOC change, multiple files, requires planning).

**Procedure**:

### Session 1 — Master Plan (Optional)

If the work is multi-phase, run `/master-plan` first:

```
/master-plan <high-level goal>
```

This dispatches `master-planner` subagent. Output: `agent-workspace/session-plans/pending/NNN-S<sid>-<slug>.md`.

### Session 2 — Architect (PLAN session)

```
/session-start
```

Verify session type is PLAN. Then dispatch architect:

```
Dispatch sandwich-architect for plan-NNN
```

The architect reads the master plan, runs Phase 1b self-calibration if ≥3 sub-tracks, produces detailed sub-plan with D1..DN tasks, file scope, DoD, RM1..RMN.

End session. The sub-plan is now in `pending/`.

### Session 3 — Dev (FOCUSED_IMPL or MULTI_TASK_IMPL)

```
/session-start
```

Verify session type is FOCUSED_IMPL (1-3 tasks) or MULTI_TASK_IMPL (4-10 tasks). Dispatch dev:

```
Dispatch sandwich-dev for plan-NNN
```

Dev runs STEP 0 VBW re-verification, implements D1..DN, runs mypy/pytest/ruff, writes session log with verification block.

End session.

### Session 4 — Verifier (VERIFY session)

```
/session-start
```

Verify session type is VERIFY. Dispatch verifier:

```
Dispatch sandwich-verifier for plan-NNN (S<dev-sid> output)
```

Verifier runs V1..V12 grid in fresh context, returns verdict inline. Main session persists findings to `attestation-log.tsv` + observation.

If PASS or PASS-WITH-CONCERNS (merge-eligible): mv plan from `pending/` to `completed/`.

If FAIL: leave in pending/; dispatch new dev session with remediation D' tasks.

End session.

---

## Recipe 6 — Audit for Drift

**When to use**: You suspect harness or code has drifted from constitution; periodic discipline; post-incident audit.

**Procedure**:

1. **Run automatic drift catalog**:
   ```
   /drift-check
   ```
   This runs `drift-signals-D1-D9.sh` + dispatches `drift-detector` subagent for semantic DR7 + DR12.

2. **Run harness health self-scan** (in fresh session via SessionStart):
   ```bash
   tail -50 agent-workspace/memory/.harness-health.log
   ```
   Look for HH-N FAIL entries.

3. **Run sync-grilling** (if 38 sessions / 7 days elapsed):
   ```
   /sync-pull
   /grill-me  # if SELF-DECIDE-OK = false
   ```

4. **Phase coherence**:
   ```bash
   tail -30 agent-workspace/memory/.session-hooks.log | grep phase-status-coherence
   ```
   Look for RED HIGH entries.

5. **Audit constitution coherence**:
   ```
   /devils-advocate  # adversarial review of recent ADRs vs constitution
   ```

6. **Read drift rollups**:
   ```bash
   ls -la agent-workspace/memory/drift-logs/ | tail -10
   ```
   Read the most recent rollup.

7. **Take action**: each surfaced item → either fix (immediate), ADR (pending), or retire (if false positive).

---

## Recipe 7 — Recover from an Incident

**When to use**: Mass deletion, corrupted state, lost work, broken automation.

**Severity-based response**:

### Mass File Deletion

1. **Stop all sessions immediately** (close Claude).

2. **Check git state**:
   ```bash
   git status
   git log --oneline -20
   ```
   If files are uncommitted: hope they are in the daily-backup at `<project-parent>/stockforge-backups/`.

3. **Restore from backup**:
   ```bash
   ls <project-parent>/stockforge-backups/  # find most recent backup
   tar -xzf <project-parent>/stockforge-backups/<DATE>.tar.gz -C /tmp/restore/
   # compare /tmp/restore/ vs current; copy missing files back
   ```

4. **Restore from git**:
   ```bash
   git checkout HEAD -- <path>  # restore staged file
   git log --all --diff-filter=D -- <path>  # find when path was deleted
   git checkout <commit>^ -- <path>  # restore from before deletion
   ```

5. **Document the incident**:
   - Write `agent-workspace/post-mortems/YYYY-MM-DD-<incident-name>.md`
   - Update `mistake-log.md` with `M-S<N>-<M>` entry
   - If new prevention rules: write to `agent-notes.md`
   - If new hook proposed: queue for `promote-rule` cycle

### Corrupted `current-execution.md`

1. **Restore from checkpoint**:
   ```bash
   cat agent-workspace/memory/checkpoints/latest.md
   # If latest.md is also corrupted:
   ls agent-workspace/memory/checkpoints/ | tail -5
   # Restore from most recent valid timestamp file
   ```

2. **Run `/session-start`**:
   ```
   /session-start
   ```
   The bootstrap reads from `current-execution.md`; if restored correctly, session resumes.

### Broken Hook Causing False Block

1. **Check `urgent.md`**:
   ```bash
   cat human-workspace/notifications/urgent.md
   ```

2. **Identify the blocking hook**:
   ```bash
   tail -100 agent-workspace/memory/.session-hooks.log | grep -i block
   ```

3. **Verify with firing-test**:
   ```bash
   bash scripts/hooks/firing-tests/<hook>-fire-test.sh
   ```

4. **If hook is broken**: temporary unwire by commenting out in `.claude/settings.json`. Document as defer-cycle ADR. Fix in next session.

5. **Clear block**:
   ```
   /block clear
   ```
   Or manually: `rm agent-workspace/memory/.autonomous-BLOCKED`.

### Lost Subagent Work

1. **Check observation file**:
   ```bash
   ls -la agent-workspace/memory/observations/ | tail -10
   ```
   The subagent may have written an observation even if its message was lost.

2. **Check dispatch.jsonl**:
   ```bash
   tail -20 agent-workspace/memory/dispatch.jsonl
   ```
   Look for the COMPLETED row for the orphan.

3. **Check raw session export**:
   ```bash
   ls agent-workspace/raw-sessions/ | tail -5
   ```
   `session-export-raw.sh` archives transcripts; may have captured subagent IO.

---

## Recipe 8 — Dispatch Parallel Agents

**When to use**: You have multiple independent tasks. Parallel dispatch saves wall-clock time but requires coordination.

**Procedure**:

1. **Verify tasks are independent**: no shared file writes; no dependency on each other's output.

2. **Write coordination rules** to `current-execution.md`:
   ```markdown
   **Coordination rule (S<N> active)**: main session avoids
   `<files agent 1 touches>`,
   `<files agent 2 touches>`.
   ```

3. **Dispatch all agents in parallel** (single message, multiple Agent tool calls):
   ```python
   Agent(subagent_type='sandwich-dev', prompt='...', run_in_background=True)
   Agent(subagent_type='research-scanner', prompt='...', run_in_background=True)
   Agent(subagent_type='ul-auditor', prompt='...', run_in_background=True)
   ```

4. **Continue with other work** while agents run. The harness will notify you when each completes.

5. **On completion**: read each observation file. Persist findings. Move artifacts.

6. **Clear coordination rules** from `current-execution.md` once parallel cluster done.

---

## Recipe 9 — Set Up Telegram Alerts

**When to use**: You want CRITICAL/HIGH severity items pushed to your phone.

**Procedure**:

1. **Create Telegram bot**:
   - Open Telegram → message `@BotFather`
   - `/newbot` → name your bot
   - Copy the bot token

2. **Get your chat_id**:
   - Send a message to your bot
   - `curl https://api.telegram.org/bot<TOKEN>/getUpdates`
   - Find `"chat":{"id":<NUMBER>` in the response

3. **Set env vars** in `.claude/settings.local.json` (gitignored):
   ```json
   "env": {
     "STOCKFORGE_TELEGRAM_BOT_TOKEN": "<token>",
     "STOCKFORGE_TELEGRAM_CHAT_ID": "<chat_id>"
   }
   ```

4. **Test in DRY_RUN mode** first:
   ```bash
   STOCKFORGE_TELEGRAM_DRY_RUN=1 bash scripts/hooks/telegram-push.sh "TEST: harness alert"
   ```

5. **Test live**:
   ```bash
   bash scripts/hooks/telegram-push.sh "HIGH: live test from harness"
   ```

6. **Verify** the message arrived. Check `agent-workspace/memory/.session-hooks.log` for the push log line.

The pipeline now pushes CRITICAL + HIGH automatically via `escalation-engine.sh`.

---

## Recipe 10 — Promote a Rule

**When to use**: You see a rule (in `agent-notes.md`) that has appeared 2+ times and warrants promotion to hook/skill/constitution.

**Procedure**:

1. **Dispatch the `promote-rule` subagent**:
   ```
   Dispatch promote-rule for agent-notes cluster review
   ```

2. **Read the proposal** at `agent-workspace/memory/observations/promotion-proposals-<TS>.md`.

3. **For each candidate**, decide:
   - **HOOK**: rule is statically detectable. Ship as `scripts/hooks/<name>.sh` + firing-test.
   - **SKILL**: rule is a recurring procedure. Ship as `.claude/skills/<name>/SKILL.md`.
   - **CONSTITUTION**: rule rises to invariant. Write proposal to `agent-workspace/proposals/`.
   - **RETIRE**: rule is duplicate of existing charter / skill / hook. Document retirement in `agent-notes.md`.

4. **AskUserQuestion if charter-tier**: charter promotions require ratification.

5. **Implement** the chosen path (see Recipe 1, 4, or 12).

6. **Update `agent-notes.md`**: mark original entries as `PROMOTED-TO-<artifact>` to prevent re-promotion.

---

## Recipe 11 — Run an ADR Through the Lifecycle

**When to use**: You have a decision to record formally.

**Procedure**:

1. **Determine tier**: CHARTER / SCOPE / ARCH / IMPL. Per [`decision-discipline.md`](../../../agent-workspace/constitution/decision-discipline.md).

2. **Determine confidence**: read `agent-workspace/memory/sync-tracker/state.tsv` for relevant category. If below threshold, trigger `/grill-me` first.

3. **Get the next ADR number**:
   ```bash
   ls agent-workspace/memory/decisions/ | grep -E '^[0-9]{3}-' | sort | tail -1
   # next = max + 1
   ```

4. **Write the ADR** at `agent-workspace/memory/decisions/NNN-<slug>.md` using `_template.md`:
   ```yaml
   ---
   id: D-NNN
   title: <short title>
   date: YYYY-MM-DD
   status: PROPOSED
   level: CHARTER | SCOPE | ARCH | IMPL
   ...
   ---
   ```

5. **Cool-down**: per tier (CHARTER 48h, SCOPE 24h, ARCH 12h, IMPL 0h).

6. **Ratify**: if CHARTER/SCOPE, AskUserQuestion bundle. If ARCH/IMPL, self-decide above threshold.

7. **Flip status** PROPOSED → ACCEPTED in the ADR.

8. **Implement** the ADR (companion code / hook / skill ships).

9. **Verify**: sandwich-verifier run picks up the ADR's verification clause.

10. **Flip status** ACCEPTED → SHIPPED on verification pass.

11. **If superseded later**: original ADR `status: SUPERSEDED-BY-D-NNN`. Never delete.

---

## Recipe 12 — Add a New Constitution Rule

**When to use**: A rule has reached the charter tier — it is an invariant, not contextual.

**Procedure**:

1. **Write proposal** at `agent-workspace/proposals/<slug>.md`:
   ```markdown
   ---
   status: PROPOSED
   tier: CHARTER
   ratification_path: AskUserQuestion bundle
   cool_down_hours: 48
   target_file: agent-workspace/constitution/<file>.md
   ---

   # Proposal: <title>

   ## Background
   ## Proposed Rule
   ## Options Considered
   ## Recommendation
   ## Companion Artifacts
   ```

2. **Cool-down**: 48h minimum. `proposal-bundle-advisor.sh` SessionStart hook surfaces ready proposals.

3. **AskUserQuestion bundle**: present options + recommendation. Capture user pick.

4. **Author ADR** (per Recipe 11) ratifying the proposal.

5. **MV proposal to constitution**: this requires a one-time deny-lift because `agent-workspace/constitution/**` is in the deny list. Either:
   - Bundle the mv with an existing approved Edit
   - Temporarily lift the deny in `settings.json`, mv, restore deny

6. **Cross-reference update**: grep for `proposals/<slug>` across repo; update all to `constitution/<file>`.

7. **Update `project.md` Recent ADRs section** with link to the new ADR.

---

## Recipe 13 — Archive an Old Session

**When to use**: `current-execution.md` over the 5-session / 200-LOC cap. `tracking-retention.sh` should auto-migrate, but sometimes manual archive is needed.

**Procedure**:

1. **Identify the session range** to archive:
   ```bash
   head -200 agent-workspace/memory/current-execution.md
   # Find oldest section: "## S<N> — ..."
   ```

2. **Create archive file**:
   ```
   agent-workspace/memory/current-execution-archive-YYYY-MM-DD-S<from>-to-S<to>.md
   ```

3. **Cut + paste** the old session sections from `current-execution.md` into the archive.

4. **Verify** `current-execution.md` is now ≤200 LOC and has the most recent 5 sessions.

5. **Check cap**:
   ```bash
   wc -l agent-workspace/memory/current-execution.md
   ```

---

## Recipe 14 — Debug a Silent Hook

**When to use**: A hook is wired but `.session-hooks.log` shows zero entries from it.

**Procedure**:

1. **Verify wiring**:
   ```bash
   grep "<hook>" .claude/settings.json
   ```

2. **Verify script is executable**:
   ```bash
   ls -la scripts/hooks/<hook>.sh
   ```

3. **Run the firing-test**:
   ```bash
   bash scripts/hooks/firing-tests/<hook>-fire-test.sh
   ```

4. **If firing-test passes but production silent**: classic Principle 11 failure mode. Check:
   - **SPAWN-CONTEXT**: does the firing-test exercise the actual spawn topology Claude Code uses? Form-A (`VAR=val bash ...`) fails silently on Windows.
   - **PPID assumption**: hooks running as Claude Code subprocess often have `$PPID=1`, not the parent claude.exe PID.
   - **Environment variables**: `$CLAUDE_PROJECT_DIR` may differ between test and production.

5. **Use `lock-rc-probe.sh`** as diagnostic:
   ```bash
   bash scripts/hooks/lock-rc-probe.sh
   ```

6. **Check `firing-test-spawn-context-lint.sh`** output:
   ```bash
   bash scripts/hooks/firing-test-spawn-context-lint.sh
   ```

7. **Common fix**: change wiring from `VAR=val bash ...` to `env VAR=val bash ...`.

8. **Verify in next real session**: check `.session-hooks.log`.

---

## Recipe 15 — Run a THESIS Session

**When to use**: You want to do multi-perspective adversarial analysis on a stock.

**Procedure**:

1. **Open Claude in a NEW session** (so context is clean for analysis):
   ```bash
   claude
   ```

2. **Identify session type explicitly**:
   ```
   /session-start --type THESIS <ticker>
   ```

3. **The harness ensures**:
   - Read-only mode on code (no Edit/Write to `packages/`, `apps/`)
   - Output goes to `agent-workspace/memory/thesis-log/`
   - Charter Principle 3 (adversarial by design) applies — bear case mandatory
   - Charter Principle 9 (no LLM math) applies — all numbers from `vnstock` / SQLite

4. **Workflow**:
   - Read `agent-workspace/memory/thesis-log/` for prior thesis on this ticker
   - Read `obsidian-vault/wiki/entities/<ticker>.md` for prior research
   - Dispatch deterministic computations to Python tools (no LLM math)
   - Frame as research aid, not "buy/sell" (per I-S35)

5. **Output**: thesis entry at `thesis-log/<TS>-<ticker>.md`:
   ```yaml
   ---
   thesis_id: <hex>
   ticker: <TICKER>
   as_of: <YYYY-MM-DD>
   dogfood_session: S<N>
   ---

   # Thesis: <TICKER>

   ## Bull Case (≥3 specific points)
   ...

   ## Bear Case (≥3 specific points; I-S10 enforced)
   ...

   ## Quant Snapshot
   [from deterministic tools]

   ## Position Sizing Recommendation
   [per deterministic risk rules; LLM cannot override]

   ## Calibration
   [hit rate from prior thesis on this ticker]
   ```

6. **Verify**:
   - I-S10 bear case ≥3 points
   - I-S2 every claim has source + as-of
   - I-S35 framing: "thesis exploration", not "buy/sell recommendation"

7. **End session** normally. The thesis is now in the log.

---

## Where to Read Next

- **Why these patterns work** → [Chapter 12 — Internals](12-internals.md)
- **The full artifact inventory** → [Chapter 13 — Reference](13-reference.md)
- **Contributing to the harness** → [Chapter 14 — Contributing](14-contributing.md)
