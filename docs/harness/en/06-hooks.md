# Chapter 6 — Hooks

> **Diataxis quadrant**: Reference + Explanation + How-to
> **Reading time**: ~60 minutes
> **Prerequisites**: Chapter 3 (Architecture) for layer context; Chapter 4 (Constitution) for rule context

Hooks are the deterministic enforcement layer of the harness. They are shell scripts that fire on Claude Code lifecycle events and **execute non-LLM logic** — checks, audits, blocks, escalations, telemetry.

This is the largest chapter in the book because hooks are the largest component. **118 hook scripts** + **115 companion firing-tests** + **9 wired events**. They are what makes the harness *enforce* rather than *suggest*.

If you read only one section of this chapter, read [§ 6.6 — The Severity Pipeline](#66--the-severity-pipeline). It is the load-bearing cascade.

---

## 6.1 — The Event Model

Claude Code fires hook events at well-defined moments. The harness wires hook scripts to these events via `.claude/settings.json`:

| Event | Wired hook count | Fired when |
|---|---|---|
| **SessionStart** | 22 | New session begins (`claude` launched, `/clear`, or resume) |
| **SessionEnd** | 3 | Session terminates |
| **UserPromptSubmit** | 13 | User submits a prompt (after every Enter) |
| **PreToolUse** | 9 | Before any tool call (Bash, Read, Write, Edit, Agent, etc.) |
| **PostToolUse** | 10 | After any tool call |
| **Stop** | 50+ | LLM completes a turn (the end of every assistant response) |
| **SubagentStop** | 5 | A dispatched subagent completes |
| **PreCompact** | 1 | Before automatic context compaction |
| **Notification** | 0 (intentionally empty) | Reserved for future use |

Total wired-invocation count: **~113** (some hooks fire on multiple events).
Total physical scripts: **118** (some are CLI utilities reused by wired hooks).

### What Hooks Can Do

A hook is a shell script that receives stdin JSON (the tool call context) and returns:

- **stdout** → injected as additional context into the LLM's next turn (`hookSpecificOutput.additionalContext`)
- **stderr** → logged but not seen by LLM
- **exit code 0** → success; let the tool proceed
- **exit code 2** → DENY the tool call (PreToolUse only)
- **exit code non-zero (other)** → typically logged as warning

This contract is small but powerful. With it, you can:

- Block destructive operations
- Inject reminders into the LLM's context
- Audit and rotate state files
- Compute and store telemetry
- Trigger external services (Telegram, etc.)

---

## 6.2 — The 17 Hook Categories

The 118 hooks split into 17 categories by purpose:

| # | Category | Count | Purpose |
|---|---|---|---|
| 1 | Bootstrap / Session Lifecycle | ~8 | Session entry/exit setup |
| 2 | Governance / Hard-Block | ~12 | PreToolUse guards (RC=2 deny) |
| 3 | Determinism / Financial-Data Integrity | ~7 | Stock-domain invariants |
| 4 | Watchdog / Severity & Escalation | ~8 | Severity pipeline (D-058) |
| 5 | Telemetry / Recording | ~10 | Append-only event logs |
| 6 | Drift Detection | ~7 | Pattern-match regression catchers |
| 7 | Rotation / Housekeeping | ~9 | Daily/weekly archival |
| 8 | Lint / Quality | ~8 | Static-lint scanners |
| 9 | Q&A Lifecycle | ~5 | Pending → answered → stale |
| 10 | Sync-Tracker (Confidence Score) | ~5 | Track 8a per-category confidence |
| 11 | Learning Loop | ~5 | Karpathy autoresearch outer-loop |
| 12 | Checkpoint / Handoff Continuity | ~6 | /clear boundary continuity |
| 13 | Budget / Context Management | ~5 | Real-token tracking |
| 14 | Coherence / Integrity | ~6 | Cross-file invariant checks |
| 15 | Bootstrap-summary / Index Render | ~4 | Aggregate into cheap-load summaries |
| 16 | Spawn / Cross-Process | ~3 | Detached Windows processes |
| 17 | Diagnostic (Unwired) | ~4 | Forensic / one-shot RC investigation |

Total: ~118. Some hooks span categories (e.g., `harness-health-self-scan.sh` is both Watchdog and Drift; `effort-escalation-detector.sh` is both Budget and Lint).

---

## 6.3 — The Stop Chain (50+ Hooks)

The Stop event fires when the LLM completes a turn. The Stop chain is the largest chain in the harness because end-of-turn is when most rituals happen: log rotation, drift detection, severity classification, cost ledgering, retention enforcement.

The chain (in execution order, condensed):

```
1.  Inline echo to .session-hooks.log
2.  pre-clear-handoff-guard.sh          ← block if un-handed-off work
3.  tracking-retention.sh                ← cap enforcement + auto-archive
4.  telemetry-rotate.sh                  ← weekly TSV rotation
5.  session-hooks-log-rotate.sh
6.  urgent-md-rotate.sh                  ← size-triggered (4KB)
7.  dispatch-pending-rotation.sh         ← 12h archive
8.  auto-reboot-handoff-verify.sh        ← HH-H.4 outer fence
9.  budget-watchdog.sh                   ← final tally
10. autonomous-stop-watchdog.sh          ← Mode A/B/C/D detector
11. pre-checkpoint-close-verifier.sh     ← M-S67-3 pattern
12. taskcompleted-audit.sh               ← I-S1 + I-S2 sweep
13. charter-coherence-spot.sh            ← I-S35 framing check
14. adr-empirical-close-verify-spot-check.sh
15. drift-signals-D1-D9.sh               ← run drift catalog
16. sync-tracker-auto-update.sh          ← HH-B.5 Stop wrapper
17. correction-rate-aggregator.sh
18. learning-index-rebuild.sh
19. bash-hook-lint.sh                    ← producer-consumer integrity
20. file-pattern-hook-pre-flight-lint.sh
21. learning-loop-metric-check.sh        ← L-S12-1
22. research-scanner-output-validator.sh
23. self-awareness-aggregate.sh          ← sessions-rollup.tsv
24. profile-template-auto-populate.sh    ← HH-C.3
25. planner-feedback-loop.sh
26. lesson-synthesis-watchdog.sh         ← Stage 1 self-upgrade
27. severity-classifier.sh               ← PHASE A of severity pipeline
28. dogfood-the-promotion.sh
29. stop-finding-frontmatter-validator.sh
30. project-integrity-watchdog.sh        ← R2 mass-deletion
31. python-determinism-check.sh
32. atomic-write-check.sh
33. html-separator-check.sh
34. path-safety-check.sh
35. observation-orphan-detector.sh
36. escalation-engine.sh                 ← PHASE B of severity pipeline
37. pending-queue-escalator.sh
38. index-registry-renderer.sh
39. qa-stale-urgent-escalator.sh
40. qa-pending-auto-mover.sh             ← D-031 auto-mv
41. session-end-checklist-linter.sh      ← HH-C.1 mistake-log discipline
42. memory-routing-audit.sh
43. project-md-adr-staleness.sh
44. tier1-bloat-check.sh                 ← HH-5 ≤8K enforcement
45. promotion-cycle-trigger.sh           ← ≥8 lessons HARD-BLOCK
46. harness-recovery-dod-watchdog.sh
47. drift-rollup-daily.sh                ← idempotent per day
48. drift-signals-log-rotate.sh          ← MUST run AFTER rollup
49. cost-ledger-recorder.sh              ← USD tally
50. bootstrap-summary-renderer.sh        ← boot-summary.md ~2K
51. scheduled-drift-detector-trigger.sh
52. memory-etl-processor.sh
53. tool-call-first-lint.sh              ← strict-profile only
54. firing-test-spawn-context-lint.sh    ← AP-23 + L-S247-1
55. daily-backup.sh                      ← R3 mass-deletion recovery
```

### Order Coupling

Several hooks depend on others running first. Most critical:

- **`drift-signals-log-rotate.sh` MUST run AFTER `drift-rollup-daily.sh`** — same-day rotate-before-rollup would zero today's rollup file.
- **`qa-pending-auto-mover.sh` MUST run AFTER `qa-stale-urgent-escalator.sh`** — escalate the stale bundles first; only then auto-mv the answered/closed ones.
- **`severity-classifier.sh` MUST run BEFORE `escalation-engine.sh`** — escalation reads classifier's output.
- **`lesson-synthesis-watchdog.sh` MUST run BEFORE `promotion-cycle-trigger.sh`** — promotion check reads synthesis state.

The wiring order in `.claude/settings.json` reflects this. Manual reordering breaks the cascades.

---

## 6.4 — The SessionStart Chain (22 Hooks)

The SessionStart event fires when Claude Code starts a new session. The chain establishes session prerequisites:

```
1. inline mkdir + echo SessionStart row
2. single-claude-instance-lock.sh           ← prevent phantom-dispatch race
3. essential-routing-fields-verifier.sh     ← validate current-execution.md
4. working-memory-budget-audit.sh           ← Tier-1 ≤8K check
5. session-start-bootstrap.sh               ← emit checkpoint additionalContext
6. vendor-api-probe.sh                       ← check Anthropic API reachable
7. qa-pending-stale-mover.sh                ← move >48h Q&A bundles
8. qa-answered-detector.sh                  ← re-classify status= changes
9. sync-grilling-trigger.sh                 ← check 38-session / 7-day threshold
10. learning-queue-sweeper.sh                ← promote pending lessons
11. ghost-work-audit.sh                     ← in-flight subagent orphan check
12. proposal-bundle-advisor.sh              ← 48h cool-down ready check
13. checkpoint-marker-cleanup-resume.sh     ← surface next_action
14. in-flight-subagent-watcher.sh           ← unattended dispatch check
15. session-start-scan-unattested-observations.sh
16. idle-escape-detector.sh SessionStart    ← routine-idle pattern
17. phase-status-coherence.sh SessionStart  ← project.md ↔ current-execution.md
18. harness-health-self-scan.sh SessionStart ← HH-1..HH-12 catalog
19. idle-state-advisory.sh SessionStart
20. escalation-engine.sh SessionStart       ← act on .severity-state.tsv
21. continue-injector-spawn.sh              ← dispatch /clear continue (last in chain)
22. component-telemetry.sh                  ← inline .* matcher
```

### The `continue-injector-spawn.sh` Last-Position Rule

This hook is wired **last** in the SessionStart chain because it spawns a detached PowerShell process via `Start-Process`. Empirically on Windows, this spawn truncates the rest of the SessionStart chain. Placing it last means the truncation no longer suppresses downstream hooks.

This is one of many Windows-portability scars in the harness; see [§ 6.10 — Windows Portability](#610--windows-portability-scars).

---

## 6.5 — The UserPromptSubmit Chain (13 Hooks)

Fires on every user prompt:

```
1.  block-control.sh check-prompt           ← auto-clear on "approved" reply
2.  autonomous-block-enforcer.sh            ← BLOCKED flag enforcement
3.  escalation-engine.sh UserPromptSubmit   ← re-act on severity state
4.  userprompt-invariants-injector.sh       ← inject I-S1/I-S2/I-S35 reminders
5.  stale-prompt-detector.sh                ← flag >24h old references
6.  correction-rate-tracker.sh              ← count user corrections per turn
7.  in-flight-subagent-watcher.sh           ← orphan check
8.  hook-firing-counter.sh                  ← tally per-turn fires
9.  effort-escalation-detector.sh           ← recommend /effort ladder
10. idle-escape-detector.sh UserPromptSubmit
11. phase-status-coherence.sh UserPromptSubmit
12. harness-health-self-scan.sh UserPromptSubmit (cached if <5min)
13. idle-state-advisory.sh UserPromptSubmit
```

The Stop chain runs after every assistant turn ends; the UserPromptSubmit chain runs after every user turn ends. Together they bracket every turn.

---

## 6.6 — The Severity Pipeline (D-058)

The severity pipeline is the harness's central nervous system. Four phases, fanning out across events:

```
┌──────────────────────────────────────────────────────────────────┐
│ DETECTORS (drift, dogfood, frontmatter, orphan, etc.)            │
│   ↓ append to .session-hooks.log + .drift-signals.log            │
│                                                                  │
│ PHASE A — severity-classifier.sh (Stop, late-chain)              │
│   ↓ scans across artifact types                                  │
│   ↓ emits normalized rows to .severity-state.tsv                 │
│   ↓ levels: CRITICAL / HIGH / MEDIUM / LOW                       │
│                                                                  │
│ PHASE B — escalation-engine.sh (Stop + SessionStart +            │
│           UserPromptSubmit; multi-cadence)                        │
│   ↓ reads .severity-state.tsv                                    │
│   ↓ CRITICAL → write .autonomous-BLOCKED + URGENT + Telegram     │
│   ↓ HIGH → URGENT + UserPromptSubmit context + Telegram          │
│   ↓ MEDIUM → weekly digest                                       │
│   ↓ LOW → log only                                               │
│                                                                  │
│ PHASE C — autonomous-block-enforcer.sh (PreToolUse +             │
│           UserPromptSubmit; FIRST in chain)                       │
│   ↓ reads .autonomous-BLOCKED flag                               │
│   ↓ PreToolUse: deny Edit/Write/Bash/MultiEdit/Agent (RC=2)      │
│   ↓ Read/Glob/Grep allowed for diagnostic                        │
│   ↓ UserPromptSubmit: loud BLOCKED context via stdout            │
│   ↓ Override: STOCKFORGE_FORCE_AUTONOMOUS=1 (logged)             │
│                                                                  │
│ PHASE D — telegram-push.sh (called by escalation-engine for       │
│           CRITICAL/HIGH only)                                     │
│   ↓ reads $STOCKFORGE_TELEGRAM_BOT_TOKEN +                       │
│     $STOCKFORGE_TELEGRAM_CHAT_ID from settings.local.json        │
│   ↓ idempotency: SHA-keyed per-hour marker                       │
│   ↓ DRY_RUN mode for testing                                     │
└──────────────────────────────────────────────────────────────────┘
```

### What Happens If You Remove One Phase

The cascade is fragile. Removing any phase opens a gap:

- **Remove `severity-classifier.sh`**: escalation-engine sees empty state → no escalation → silent regression of every drift class. The auto-block path goes dark.
- **Remove `escalation-engine.sh`**: severity rows accumulate but never escalate; `.autonomous-BLOCKED` never gets written → main session keeps running through what should be hard-blocks.
- **Remove `autonomous-block-enforcer.sh`**: the BLOCKED flag is set but tool calls are not denied — the gate becomes advisory only. The S316 deadlock mode (manual `rm` required) returns.
- **Remove `telegram-push.sh`**: blocks still work; user just doesn't get push notifications. (Lowest-impact removal.)

### Severity Schema (D-058 / S310 Ratification)

| Level | Triggers | Action |
|---|---|---|
| **CRITICAL** | Stale-checkpoint marker, Q&A age ≥96h, charter-violation marker, ghost-greening marker, mistake-log severity=critical | Write `.autonomous-BLOCKED` flag; URGENT entry to `urgent.md`; Telegram push |
| **HIGH** | Q&A age ≥6h pending, charter-tier ADR PROPOSED age ≥24h, mistake-log severity=high, notification ALERT-URGENT keyword | URGENT entry; UserPromptSubmit additionalContext demanding `AskUserQuestion`; Telegram push |
| **MEDIUM** | ARCH/SCOPE PROPOSED age ≥12h, notification WARN | Weekly `digest-<YYYY-Www>.md` |
| **LOW** | Below thresholds | Log only |

**Filters** (skip these even if pattern matches):
- Bundles with status `answered/closed/resolved`
- Files named `_template.md`, `README.md`, `TEMPLATE.md`, `index.md`
- `urgent.md`, `digest-*.md` (self-loop prevention)

---

## 6.7 — Representative Hook Deep-Dives

The most important hooks, explained.

### `single-claude-instance-lock.sh` — Governance / SessionStart

**Purpose**: Prevent the **phantom-dispatch race condition** when multiple concurrent `claude.exe` instances share `current-execution.md` and each dispatches the same active task.

**Origin**: M-S238-2, L-S239-4, L-S240-5 cluster — 4 instances of "two parents both ran autonomous-mode, both dispatched sandwich-verifier, composite observation file with redundant content".

**Mechanism**: Lock file `.claude-instance.lock` format `claude_pids=<csv>:created=<epoch>:session_id=<sid_or_unknown>`. Block conditions are **both**:
1. Staleness floor: `now - created < 7200s`
2. Liveness: any stored PID still alive in current `tasklist` AND not the sole `claude.exe`

Cleaned by inline SessionEnd `rm -f` (settings.json:248).

**Empirical RC discovery** (lock-rc-probe.sh): `$PPID == 1` in spawned hook context (strategy `c` ancestor-walk fails); `session_id` from stdin JSON IS reliable.

**Severity**: BLOCK (exit non-zero).

### `destructive-command-guard.sh` — Governance / PreToolUse

**Purpose**: Block destructive command CLASSES at PreToolUse, applies to BOTH main session AND every subagent.

**Origin**: 2026-05-14 mass-deletion incident — ~2688 files destroyed by a `find -newer` / git operation during a subagent execution window; 0-byte transcripts left exact command unrecoverable.

**Mechanism**: Reads Bash command from stdin JSON `tool_input.command`, matches against destructive patterns, narrow safe-allowlist. Override: `STOCKFORGE_ALLOW_DESTRUCTIVE=1` (logged to mistake-log).

**Paired with**: `daily-backup.sh` (R3) and `project-integrity-watchdog.sh` (R2) as the three-prong mass-deletion prevention.

**Severity**: HARD BLOCK (exit RC=2).

### `write-vs-edit-guard.sh` — Governance / PreToolUse

**Purpose**: Enforce **L-S45-2 doctrine** born from the 2026-05-05 sandwich-architect data-loss.

**Origin**: A subagent called `Write` on `agent-workspace/memory/agent-notes.md` instead of `Edit`, destructively overwriting ~470 LOC of accumulated learned rules with a ~40 LOC stub (~140 lines permanently lost).

**Mechanism**: For files under `agent-workspace/memory/{agent-notes,project,mistake-log}.md` and `agent-workspace/{constitution,proposals,session-plans}/**/*.md`, append/insert via `Edit` ONLY. `Write` reserved for genuinely new files (existence-check via `Glob` first).

**Severity**: HARD BLOCK (exit RC=2).

### `budget-watchdog.sh` — Watchdog / PostToolUse + Stop

**Purpose**: Track real token consumption from transcript JSONL; auto-trigger reboot at cliff.

**Mechanism**: Reads transcript JSONL via `node`, sums real token usage from `usage` records, auto-triggers `session-self-reboot.sh` at thresholds.

**Defaults** (per D-004 — UP-07 Opus 4.7 recalibration):
- `STOCKFORGE_WIND_DOWN_TOKENS=180000`
- `STOCKFORGE_CLIFF_TOKENS=220000`
- `STOCKFORGE_HARD_CAP=250000`

ORCH_* legacy fallback envs preserved for migration.

**Mode-C guard** (Stop-only): blocks premature turn-end when LLM cites budget pressure but real tokens well under threshold — emits decision JSON to stdout.

**Atomic noclobber markers**: `.cliff-fired`, `.wind-down`.

**Defense-in-depth**: honors `.auto-reboot-PRE-BLOCKED-stale-checkpoint` marker from `auto-reboot-handoff-verify.sh`.

**Severity**: BLOCK at cliff; warn at wind-down.

### `harness-health-self-scan.sh` — Watchdog / SessionStart + UserPromptSubmit

**Purpose**: Continuous harness-health verification (Charter Principle 11).

**Mechanism**: Runs the 12-signal HH-1..HH-12 catalog codified in [`harness-health-protocol.md`](../../../agent-workspace/constitution/harness-health-protocol.md).

**Cheap-first signal ordering**:
1. HH-7 (checkpoint mtime)
2. HH-11 (log mtime)
3. HH-8 (md5)
4. HH-1 (Stop fires ≥1/session)
5. HH-2 (UserPromptSubmit ≤10min)
6. HH-9 (mistake-log freshness)
7. HH-3 (promote-rule ≤10d)
8. HH-6 (multi-file mtime + tail)
9. HH-4 (auto-detect orphans ≤2)
10. HH-10 (firing-test orphans ≤2)
11. HH-5 (delegated hook)
12. HH-12 (project.md Phase == current-execution.md Phase)

**Caching**: 5-min same-session cache via `.harness-health-cache-${SID}`.

**KI suppression**: KI-S49b-1 downgrades HH-1 HIGH→MEDIUM on Windows Stop-not-firing quirk.

**Aggregation states**: GREEN / YELLOW / RED-1 / RED-2.

**Severity**: info; always RC=0 (informational).

### `escalation-engine.sh` — Severity / Stop + SessionStart + UserPromptSubmit

**Purpose**: Phase B of the unified severity/escalation system.

**Mechanism**: Reads `.severity-state.tsv` (produced by `severity-classifier.sh`) and acts per severity row.

**Multi-cadence design**: severity surfaces at three different windows (turn end, new session, prompt arrival) so even if the user dismisses one prompt, the next event re-fires.

**Severity**: writes `.autonomous-BLOCKED` flag (separate from exit code).

### `dispatch-jsonl-recorder.sh` — Telemetry / PreToolUse + SubagentStop + PostToolUse

**Purpose**: Per-Agent-call telemetry recording.

**Origin**: D-023 v2 schema + HH-B.1/B.2 telemetry.

**Mechanism**:
- `PreToolUse(Agent)` writes `DISPATCHED` row + sidecar keyed by `tool_use_id`.
- `SubagentStop` writes `COMPLETED` row with **FIFO-matched** `tool_use_id` (HH-B.1 replaced broken `agentId: <hex>` regex; filter by `parent_session_id`, find oldest `DISPATCHED` without matching `COMPLETED`) and reads `transcript_path` to populate `tokens_real` + `duration_ms` + `failure_mode` (HH-B.2).

Ported from orch v2.2.0 with stockforge subagent_type→model map.

**Severity**: telemetry-only (RC=0).

### `python-determinism-check.sh` — Determinism / PostToolUse + Stop

**Purpose**: Enforce 4 banned non-determinism patterns in Python production code.

**Origin**: Ported from `nautilus_trader` DST doctrine (SHA `dd49f70`, ADR D-059).

**Banned patterns** in `packages/**/*.py` + `apps/**/*.py`:
- **R1**: `datetime.now()` without timezone arg → ERR
- **R2**: `random.random()/randint()/secrets.token_*()` outside `__main__` or `test_*.py` → ERR
- **R3**: Dict iteration order assumption heuristic → WARN
- **R4**: `time.time()` in `packages/domain/**` → ERR

**Companion ports in same cadence**:
- `atomic-write-check.sh` (TradingAgents AW-R1..R4 atomic temp-replace)
- `html-separator-check.sh` (TradingAgents HTML entry separator)
- `path-safety-check.sh` (Vibe-Trading P1-P5 sandbox/UNC/zone)

All four enforce **Charter Principle 11** on the Python-primary stack. Violations land in `.severity-state.tsv` as HIGH.

### `drift-signals-D1-D9.sh` — Drift / Stop

**Purpose**: Composite drift detector running 9 grep-based signals.

**Tier-A signals**: DR-A1 LOC ceiling overrun (PRIMARY per Q-A2), DR-A2 self-attestation contradicting actual file content, DR-A3 Charter/SCOPE bundled with sub-charter items, DR-A4 confidence claim without calibration metadata, DR-A5 runtime-path-leak into write-only learning-data tree, DR1 domain layer imports framework, DR3 LLM call without retry/budget wrapper, DR6 `Any` type in domain package, DR8 cross-BC direct import.

**D9** = runtime-path-leak. **D10** = no `import anthropic` / `ANTHROPIC_API_KEY` (ported to `no-anthropic-sdk-d10.sh`).

**Output**: Append violations to `.drift-signals.log`, then `drift-rollup-daily.sh` promotes them to `drift-logs/YYYY-MM-DD-rollup.md` (idempotent per day), then `drift-signals-log-rotate.sh` rotates weekly.

### `tracking-retention.sh` — Rotation / Stop

**Purpose**: Enforce retention caps on tracking files; auto-migrate over-cap rows.

**Origin**: S99 RCA Layer 1 retention guard (Q-RCA-1 = A).

**Caps**:
- `current-execution.md` ≤ 5 sessions / ≤ 200 LOC (AUTO-MIGRATES oldest session row to archive)
- `agent-notes.md` digest only / ≤ 700 LOC
- `mistake-log.md` digest only / ≤ 200 LOC
- `component-telemetry.jsonl` ≤ 10 MB (handled by `telemetry-rotate.sh`)

Empirically validated S132/S133/S134 manual instances. WARN-only (RC=0); auto-migrate branch is the deterministic mechanism, not a block.

### `cost-ledger-recorder.sh` — Telemetry / Stop + SubagentStop

**Purpose**: Append-only USD cost ledger per session + subagent dispatch.

**Origin**: S65 user request "tracking cost real not estimate" + I-S1 NO LLM math (awk computes, not LLM).

**Schema** (TSV):
```
timestamp \t session_id \t actor \t model \t tokens_in \t tokens_out \t cache_read \t cache_create \t cost_usd \t hook_event
```

**Pricing table** (Anthropic public 2025-2026):
- opus: $15 / $75 per MTok in/out
- sonnet: $3 / $15
- haiku: $0.80 / $4
- cache_read = 10% input
- cache_create = 125% input

**Severity**: telemetry-only (RC=0).

### `checkpoint-write-end-turn-watchdog.sh` + `checkpoint-write-marker.sh` — Continuity Pair

**Purpose**: Enforce **L-S49b-4 rule** — "checkpoint write = end turn".

**Origin**: M-S49b-2 — LLM continued executing actions AFTER writing checkpoint, causing duplicate dispatch across `/clear` boundary + lost subagent work.

**Mechanism**:
- `checkpoint-write-marker.sh` (PostToolUse) fires after any Edit/Write/MultiEdit; if file is `checkpoints/latest.md`, writes session-scoped marker `.checkpoint-written-<session_id>` (and also `.fresh-resume-pending-<session_id>` if `autonomous_mode=true`).
- `checkpoint-write-end-turn-watchdog.sh` (PreToolUse) reads the marker; if set, denies any subsequent non-exempt tool call with RC=2.
- Marker cleared on SessionStart by `checkpoint-marker-cleanup-resume.sh`, which also surfaces the autonomous-resume `next_action` to the new session's LLM via system-reminder.

**Replaces** the revoked Mode-D SendKeys "continue" mechanism.

**Severity**: HARD BLOCK (exit RC=2).

### `daily-backup.sh` — Rotation / Stop

**Purpose**: R3 of 2026-05-14 mass-deletion prevention.

**Mechanism**: Once per calendar day, compresses critical directories to `$STOCKFORGE_BACKUP_DIR` (default `<project-parent>/stockforge-backups/`) **out-of-tree**.

**Retention**: 14 days.

**Includes**: `agent-workspace/`, `scripts/`, `.claude/`, `packages/`, `bdd/`, `specs/`, root `*.md`.

**Excludes**: `.git`, `node_modules`, `__pycache__`, `.*_cache`, forensic dirs, the backup dir itself.

**Idempotency**: per-day marker.

**Severity**: RC=0 always.

---

## 6.8 — The 3-Prong Mass-Deletion Defense

On 2026-05-14, a recency-based mass deletion (S316 verifier window) destroyed ~2688 files. Recovery required `git clone` + `git checkout HEAD --`. The harness's response was a 3-prong defense:

| Prong | Role | Hook |
|---|---|---|
| **R1 — Prevention** | Block destructive commands at PreToolUse | `destructive-command-guard.sh` |
| **R2 — Detection** | Detect mass-deletion-in-progress at Stop; write `.autonomous-BLOCKED` directly | `project-integrity-watchdog.sh` |
| **R3 — Recovery** | Out-of-tree 14-day backup, daily idempotent | `daily-backup.sh` |

Removing any prong reopens the failure mode at a different layer (R1 = prevention, R2 = detection, R3 = recovery).

---

## 6.9 — The Firing-Test Discipline (Principle 11)

Per Charter Principle 11: **every hook ships with a companion firing-test**.

### Convention

`scripts/hooks/firing-tests/` contains **115 `*-fire-test.sh` files** plus `run-all.sh`.

**Naming rule** (enforced by `harness-health-self-scan.sh` HH-10): for every `scripts/hooks/<name>.sh` there must be a companion `scripts/hooks/firing-tests/<name>-fire-test.sh`.

**Tolerance**: HH-10 fires only when **orphans > 2** (current state: 118 hooks − 115 fire-tests = 3 missing; HH-10 fires at HH-10-FIRING-TEST-ORPHAN MEDIUM).

### Firing-Test Structure

Each fire-test:

```bash
#!/usr/bin/env bash
# <hook-name>-fire-test.sh
# SPAWN-CONTEXT: <form>  ← required for bash-c / stdin-redirect / env-wrap-B hooks
set -uo pipefail

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT
export CLAUDE_PROJECT_DIR="$TEMPDIR"

# Pipe synthetic stdin JSON simulating the hook event payload
echo '{"session_id":"test-sid", ...}' | bash "$HOOK_PATH" PreToolUse

# Assert observable state changes
[ -f "$TEMPDIR/expected-marker" ] || { echo "FAIL"; exit 1; }
grep -q "expected log entry" "$TEMPDIR/.session-hooks.log" || { echo "FAIL"; exit 1; }

echo "PASS"
exit 0
```

### `SPAWN-CONTEXT` Marker

`firing-test-spawn-context-lint.sh` (per AP-23 + L-S247-1) requires each fire-test to declare `# SPAWN-CONTEXT: <form>` so the lint knows whether non-default arg-passing forms shipped with a companion test.

- **Form-A** (env-prefix `VAR=val bash ...`): broken on Windows; deprecated
- **Form-B** (env-wrap `env VAR=val bash ...`): requires marker
- **Form-C** (positional-arg `bash hook.sh ARG1`): exempt
- **bash-c** (`bash -c "..."`): requires marker
- **stdin-redirect** (`... < file`): requires marker

### `run-all.sh` Orchestrator

```bash
PER_TEST_TIMEOUT="${FIRING_TEST_TIMEOUT:-30}"
for test in "$SCRIPT_DIR"/*-fire-test.sh; do
  timeout "$PER_TEST_TIMEOUT" bash "$test" >/dev/null 2>&1
  rc=$?
  ...
done
echo "=== firing-test suite: ${PASS}/${TOTAL} PASS (elapsed ${ELAPSED}s) ==="
```

**NOT** auto-wired to Stop hook (would slow every turn). Run manually post-hook-edit or via `bash scripts/hooks/firing-tests/run-all.sh`. Returns 0 only if ALL pass; detected timeouts (`rc=124`) listed separately.

### Why HH-10 Counts Presence, Not Pass

HH-10 catches **hook-without-fire-test** anti-patterns; `run-all.sh` catches **fire-test-fails** during edit cycles. They are complementary, not redundant.

---

## 6.10 — Windows Portability Scars

The hooks layer carries substantial Windows-compatibility surface area:

- **`single-claude-instance-lock.sh`** PID resolution: `$PPID == 1` in spawned hook context; uses `tasklist //V` instead of `ps`.
- **`continue-injector-spawn.sh`** extracted as last-of-chain to dodge PowerShell `Start-Process` truncation of SessionStart (S183/S184 incidents).
- **`settings-inline-env-prefix-detector.sh`** catches `VAR=val cmd` patterns that fail silently in Claude Code's Windows hook runtime (S208 → 2-day production dormancy of HH-1/idle-escape/phase-status-coherence).
- **`bash-hook-lint.sh`** enforces L-S11-1 (Phase 0 bash + POSIX only; no python/jq/yq).
- **`firing-test-spawn-context-lint.sh`** catches Form-A/B env-wrap defects that pass on Linux but fail on Windows executor.
- **KI-S49b-1 suppression** in `harness-health-self-scan.sh` HH-1 downgrades HIGH→MEDIUM when Stop hook empirically doesn't fire on Windows quirks.

These scars are why bash hooks must follow strict portability rules — see [`portability.md`](../../../agent-workspace/constitution/portability.md).

---

## 6.11 — Unwired CLI Utilities

Several scripts in `scripts/hooks/` are not Claude Code event hooks but utilities reused by wired hooks:

| Utility | Called by |
|---|---|
| `redact-secrets.sh` | `session-export-raw.sh` |
| `telegram-push.sh` | `escalation-engine.sh`, `block-control.sh` |
| `sync-tracker-update.sh`, `sync-tracker-render.sh` | `sync-tracker-auto-update.sh`, `sync-grilling-call.sh` |
| `continue-injector.ps1` | `continue-injector-spawn.sh` |
| `block-control.sh raise/clear/status/check-prompt` | CLI subcommand interface |
| `dispatch-jsonl-backfill.sh` | One-shot CLI utility (S180 backfill task) |
| `lock-rc-probe.sh` | Unwired; kept for future RC investigation |
| `diagnostic-pretooluse-stash.sh`, `diagnostic-subagentstop-stash.sh` | Forensic stdin capture (unwired) |
| `metric-failure-mode-rate.sh` | Unwired; computes failure-mode rate (S12 framing) |

Removing any of these silently breaks the wired-hook that calls them.

---

## 6.12 — Hook Authoring Checklist

When adding a new hook:

- [ ] Choose the right event (SessionStart? Stop? PreToolUse?)
- [ ] Write the script under `scripts/hooks/<name>.sh`
- [ ] Header comment: purpose, trigger, severity, origin (ADR / lesson ID)
- [ ] `set -uo pipefail` + `trap 'exit 0' ERR` (most hooks should not block)
- [ ] Cheap-first ordering for multi-check hooks
- [ ] Idempotency markers if Stop-tier (hour-bucket / day-bucket)
- [ ] Same-session caching if UserPromptSubmit-tier
- [ ] Honor `STOCKFORGE_HOOK_PROFILE=strict` for warn-vs-block
- [ ] Write companion firing-test at `scripts/hooks/firing-tests/<name>-fire-test.sh`
- [ ] `SPAWN-CONTEXT:` marker if non-default arg form
- [ ] ≥3 test cases covering positive + negative + edge
- [ ] Wire in `.claude/settings.json` (correct event, correct order vs dependencies)
- [ ] Run `bash scripts/hooks/firing-tests/<name>-fire-test.sh` — must PASS
- [ ] Run `bash scripts/hooks/firing-tests/run-all.sh` — must show no regressions
- [ ] Document in [Reference § Hooks](../reference/inventory-hooks.md) (or run `/harness-docs sync`)
- [ ] Verify production firing in `.session-hooks.log` in next real session (Principle 11)

---

## 6.13 — Where to Read Next

- **The memory artifacts** hooks read and write → [Chapter 7 — Memory System](07-memory-system.md)
- **The lifecycle events** hooks govern → [Chapter 8 — Lifecycle](08-lifecycle.md)
- **The quality checks** hooks enforce → [Chapter 9 — Quality System](09-quality-system.md)
- **How rules become hooks** → [Chapter 10 — Self-Improvement](10-self-improvement.md)
- **Writing your own hook** → [Chapter 11 § Write a Hook](11-cookbook.md#write-a-hook)
- **Full hook inventory** → [Reference § Hooks](../reference/inventory-hooks.md)
