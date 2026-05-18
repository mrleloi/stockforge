---
title: StockForge Hooks Layer Inventory
audited_at: 2026-05-19
audited_by: research subagent
scope: 118 hook scripts at scripts/hooks/*.sh + wiring at .claude/settings.json:138-682
mode: read-only
---

# StockForge Hooks Layer Inventory

## 1. Hook-Event Firing Matrix

Wiring source: `C:\htdocs\stockforge\.claude\settings.json` lines 138-682. Each row counts distinct hook invocations wired against that event (a script that fires on two events counts once per event).

| Event | Invocations | Matcher | Representative hooks |
|---|---|---|---|
| **SessionStart** | 22 | `startup\|resume\|clear` + `.*` | `single-claude-instance-lock.sh`, `essential-routing-fields-verifier.sh`, `working-memory-budget-audit.sh`, `session-start-bootstrap.sh`, `vendor-api-probe.sh`, `qa-pending-stale-mover.sh`, `qa-answered-detector.sh`, `sync-grilling-trigger.sh`, `learning-queue-sweeper.sh`, `ghost-work-audit.sh`, `proposal-bundle-advisor.sh`, `checkpoint-marker-cleanup-resume.sh`, `in-flight-subagent-watcher.sh`, `session-start-scan-unattested-observations.sh`, `idle-escape-detector.sh`, `phase-status-coherence.sh`, `harness-health-self-scan.sh`, `idle-state-advisory.sh`, `escalation-engine.sh`, `continue-injector-spawn.sh` (last, per S184 D-042), `component-telemetry.sh` (`.*` matcher) |
| **SessionEnd** | 3 | (no matcher) | `session-export-raw.sh` + 2 inline (session-log append + lock-file cleanup) |
| **UserPromptSubmit** | 13 | (no matcher) | `block-control.sh check-prompt`, `autonomous-block-enforcer.sh UserPromptSubmit`, `escalation-engine.sh UserPromptSubmit`, `userprompt-invariants-injector.sh`, `stale-prompt-detector.sh`, `correction-rate-tracker.sh`, `in-flight-subagent-watcher.sh`, `hook-firing-counter.sh`, `effort-escalation-detector.sh`, `idle-escape-detector.sh UserPromptSubmit`, `phase-status-coherence.sh UserPromptSubmit`, `harness-health-self-scan.sh UserPromptSubmit`, `idle-state-advisory.sh UserPromptSubmit` |
| **Stop** | 50+ | (no matcher) | `pre-clear-handoff-guard.sh`, `tracking-retention.sh`, `telemetry-rotate.sh`, `session-hooks-log-rotate.sh`, `urgent-md-rotate.sh`, `dispatch-pending-rotation.sh`, `auto-reboot-handoff-verify.sh`, `budget-watchdog.sh`, `autonomous-stop-watchdog.sh`, `pre-checkpoint-close-verifier.sh`, `taskcompleted-audit.sh`, `charter-coherence-spot.sh`, `adr-empirical-close-verify-spot-check.sh`, `drift-signals-D1-D9.sh`, `sync-tracker-auto-update.sh`, `correction-rate-aggregator.sh`, `learning-index-rebuild.sh`, `bash-hook-lint.sh`, `file-pattern-hook-pre-flight-lint.sh`, `learning-loop-metric-check.sh`, `research-scanner-output-validator.sh`, `self-awareness-aggregate.sh`, `profile-template-auto-populate.sh`, `planner-feedback-loop.sh`, `lesson-synthesis-watchdog.sh`, `severity-classifier.sh`, `dogfood-the-promotion.sh`, `stop-finding-frontmatter-validator.sh`, `project-integrity-watchdog.sh Stop`, `python-determinism-check.sh`, `atomic-write-check.sh`, `html-separator-check.sh`, `path-safety-check.sh`, `observation-orphan-detector.sh`, `escalation-engine.sh Stop`, `pending-queue-escalator.sh`, `index-registry-renderer.sh`, `qa-stale-urgent-escalator.sh`, `qa-pending-auto-mover.sh`, `session-end-checklist-linter.sh`, `memory-routing-audit.sh`, `project-md-adr-staleness.sh`, `tier1-bloat-check.sh`, `promotion-cycle-trigger.sh`, `harness-recovery-dod-watchdog.sh`, `drift-rollup-daily.sh`, `drift-signals-log-rotate.sh`, `cost-ledger-recorder.sh`, `bootstrap-summary-renderer.sh`, `scheduled-drift-detector-trigger.sh`, `memory-etl-processor.sh`, `tool-call-first-lint.sh` (strict-profile only), `firing-test-spawn-context-lint.sh`, `daily-backup.sh Stop` |
| **PreToolUse** | 9 | `.*` | `destructive-command-guard.sh PreToolUse`, `pre-dispatch-architect-commit-guard.sh`, `pre-commit-pytest-regression-guard.sh`, `autonomous-block-enforcer.sh PreToolUse`, `dispatch-jsonl-recorder.sh`, `write-vs-edit-guard.sh`, `checkpoint-write-end-turn-watchdog.sh`, `pre-dispatch-adr-number-check.sh`, `effort-escalation-detector.sh` |
| **PostToolUse** | 10 | `.*`, `Edit\|Write\|MultiEdit`, fall-through | `budget-watchdog.sh` (`.*`); `python-determinism-check.sh`, `atomic-write-check.sh`, `html-separator-check.sh`, `path-safety-check.sh` (Edit/Write/MultiEdit); `dispatch-jsonl-recorder.sh`, `component-telemetry.sh`, `post-tool-citation-grep.sh`, `loc-ceiling-check.sh`, `checkpoint-write-marker.sh` (`.*`) |
| **SubagentStop** | 5 | (no matcher) + `.*` | `subagent-stop-logger.sh`; `post-dev-dispatch-attestation-check.sh`, `component-telemetry.sh`, `dispatch-jsonl-recorder.sh`, `cost-ledger-recorder.sh` (`.*`) |
| **PreCompact** | 1 | (no matcher) | `precompact-thesis-state-dump.sh` |
| **Notification** | 0 wired | — | None (Notification event handler intentionally empty) |

Total wired-invocation count: ~113 (some hooks fire on multiple events). Total physical scripts: 118. Unwired diagnostic/CLI scripts: `lock-rc-probe.sh`, `dispatch-jsonl-backfill.sh`, `diagnostic-pretooluse-stash.sh`, `diagnostic-subagentstop-stash.sh`, `metric-failure-mode-rate.sh`, `attach-portability-smoke.sh`, `sync-grilling-call.sh` (CLI wrapper), `sync-tracker-update.sh` / `sync-tracker-render.sh` (called by other hooks), `redact-secrets.sh` (called by `session-export-raw.sh`), `telegram-push.sh` (called by `escalation-engine.sh` / `block-control.sh`), `memory-routing-audit.sh` (DRAFT not yet wired), `same-commit-rule.sh` (pre-commit git hook, not Claude Code hook), `sub-plan-completion-coherence.sh` (recently wired via S224/S235), `no-anthropic-sdk-d10.sh` (D10 wired inside `drift-signals-D1-D9.sh`), `block-control.sh` (CLI subcommand interface), `continue-injector.ps1` (PowerShell spawned by `continue-injector-spawn.sh`).

---

## 2. Category Breakdown

| Category | Count | Purpose | Representative scripts |
|---|---|---|---|
| **Bootstrap / Session Lifecycle** | ~8 | Session entry/exit setup, fresh-resume surfacing, raw transcript export, working-memory shape checks | `session-start-bootstrap.sh`, `essential-routing-fields-verifier.sh`, `working-memory-budget-audit.sh`, `continue-injector-spawn.sh`, `session-export-raw.sh`, `checkpoint-marker-cleanup-resume.sh`, `tier1-bloat-check.sh`, `single-claude-instance-lock.sh` |
| **Governance / Hard-Block** | ~12 | PreToolUse guards that exit RC=2 to deny tool calls or block dispatch | `destructive-command-guard.sh` (mass-deletion class), `write-vs-edit-guard.sh` (L-S45-2), `checkpoint-write-end-turn-watchdog.sh` (L-S49b-4), `autonomous-block-enforcer.sh` (BLOCKED-flag enforcement), `pre-commit-pytest-regression-guard.sh`, `pre-dispatch-architect-commit-guard.sh`, `pre-dispatch-adr-number-check.sh`, `block-control.sh`, `lesson-synthesis-watchdog.sh` (strict mode RC=2), `pre-clear-handoff-guard.sh` (strict mode RC=2) |
| **Determinism / Financial-Data Integrity** | ~7 | Stock-domain invariants (I-S1 no LLM math, I-S2 citations, I-S35 framing) plus borrowed deterministic patterns | `python-determinism-check.sh` (R1-R4 banned patterns), `atomic-write-check.sh` (AW-R1-R4 atomic temp-replace), `html-separator-check.sh` (memory-zone separator), `path-safety-check.sh` (P1-P5 sandbox/UNC/zone), `post-tool-citation-grep.sh` (I-S2), `taskcompleted-audit.sh` (I-S1 + I-S2 sweep), `charter-coherence-spot.sh` (I-S35 framing), `no-anthropic-sdk-d10.sh` |
| **Watchdog / Severity & Escalation** | ~8 | Multi-layer severity pipeline (D-058 + L-S310-1 unified system) — classify, escalate, push, block | `severity-classifier.sh` (Phase A), `escalation-engine.sh` (Phase B; multi-cadence Stop+SessionStart+UserPromptSubmit), `autonomous-block-enforcer.sh` (Phase C; PreToolUse + UserPromptSubmit), `telegram-push.sh` (Phase D), `pending-queue-escalator.sh` (D-068 PENDING-tier), `project-integrity-watchdog.sh` (R2 mass-deletion early warning), `qa-stale-urgent-escalator.sh`, `harness-recovery-dod-watchdog.sh` |
| **Telemetry / Recording** | ~10 | Append-only event logs; deterministic count/aggregate — never blocks | `component-telemetry.sh` (per-tool JSONL), `dispatch-jsonl-recorder.sh` (PreToolUse + SubagentStop FIFO match, D-023 v2), `cost-ledger-recorder.sh` (USD pricing table, Anthropic public rates), `correction-rate-tracker.sh` + `correction-rate-aggregator.sh` (D-004 instrumentation), `subagent-stop-logger.sh`, `hook-firing-counter.sh`, `self-awareness-aggregate.sh` (sessions-rollup.tsv), `planner-feedback-loop.sh`, `metric-failure-mode-rate.sh` (S12 Karpathy framing) |
| **Drift Detection** | ~7 | Pattern-match-based regression catchers; emit to `.drift-signals.log` | `drift-signals-D1-D9.sh` (composite D1-D9), `no-anthropic-sdk-d10.sh` (D10), `harness-health-self-scan.sh` (12-signal HH-1..HH-12), `phase-status-coherence.sh` (HH-12 enhancement), `idle-escape-detector.sh` (M-S171-1 prevention #3), `adr-empirical-close-verify-spot-check.sh` (D-052 ghost-greening), `pre-checkpoint-close-verifier.sh` (M-S67-3 pattern) |
| **Rotation / Housekeeping** | ~9 | Weekly/daily rotation, archival, retention; idempotent week-bucket markers | `tracking-retention.sh` (S99 Layer 1 caps + AUTO-MIGRATE), `telemetry-rotate.sh`, `session-hooks-log-rotate.sh`, `urgent-md-rotate.sh` (size-triggered 4KB), `dispatch-pending-rotation.sh` (12h archive), `drift-signals-log-rotate.sh`, `drift-rollup-daily.sh`, `learning-queue-sweeper.sh`, `daily-backup.sh` (R3 mass-deletion recovery; 14-day OUT-OF-TREE backups) |
| **Lint / Quality** | ~8 | Static-lint deterministic scanners on hooks, observations, frontmatter, hook portability | `bash-hook-lint.sh` (L-S11-1 Phase 0 portability + producer-consumer integrity), `file-pattern-hook-pre-flight-lint.sh` (L-S176-1), `settings-inline-env-prefix-detector.sh` (L-S208-1 Windows env-prefix gotcha), `hook-log-path-canonical-detector.sh` (L-S214-1), `firing-test-spawn-context-lint.sh` (AP-23 + L-S247-1), `tool-call-first-lint.sh` (Mode-A), `stop-finding-frontmatter-validator.sh`, `session-end-checklist-linter.sh` (HH-C.1 mistake-log discipline) |
| **Q&A Lifecycle** | ~5 | Pending → answered → stale → urgent escalation pipeline | `qa-pending-stale-mover.sh` (SessionStart past-deadline mover), `qa-answered-detector.sh`, `qa-stale-urgent-escalator.sh` (>48h URGENT), `qa-pending-auto-mover.sh` (D-031 ratified auto-mv), `block-control.sh check-prompt` (auto-clear on "approved" reply) |
| **Sync-Tracker (Confidence Score)** | ~5 | Track 8a confidence-score per category — events.tsv → state.tsv → _index.md | `sync-tracker-update.sh`, `sync-tracker-render.sh`, `sync-tracker-auto-update.sh` (Stop wrapper for HH-B.5), `sync-grilling-trigger.sh` (SessionStart due-notification), `sync-grilling-call.sh` (S129 wrapper with 5-arg contract) |
| **Learning Loop** | ~5 | Karpathy autoresearch outer-loop instrumentation; observation→lesson→hook promotion | `learning-queue-sweeper.sh`, `learning-index-rebuild.sh`, `learning-loop-metric-check.sh` (L-S12-1), `promotion-cycle-trigger.sh` (≥5 sessions OR phase boundary), `lesson-synthesis-watchdog.sh` (Stage 2 self-upgrade) |
| **Checkpoint / Handoff Continuity** | ~6 | Continuity across /clear boundary; in-flight subagent surveillance | `checkpoint-write-marker.sh` + `checkpoint-write-end-turn-watchdog.sh` (PostToolUse↔PreToolUse pair, L-S49b-4), `checkpoint-marker-cleanup-resume.sh` (autonomous-resume surfacing replaces Mode-D SendKeys), `auto-reboot-handoff-verify.sh` (HH-H.4 outer fence), `pre-checkpoint-close-verifier.sh`, `in-flight-subagent-watcher.sh`, `post-dev-dispatch-attestation-check.sh` |
| **Budget / Context Management** | ~5 | Real-token budget tracking via transcript JSONL; auto-reboot at cliff | `budget-watchdog.sh` (180K wind-down / 220K cliff per D-004), `autonomous-stop-watchdog.sh` (Mode A/B/C/D loop-break detector + Mode-D clean-handoff), `auto-reboot-handoff-verify.sh`, `effort-escalation-detector.sh` (ladder recommend), `subagent-budget-classifier.sh` (Architect/Verifier envelope warn) |
| **Coherence / Integrity** | ~6 | Cross-file invariant checks (project.md ↔ current-execution.md ↔ ADRs ↔ checkpoints) | `phase-status-coherence.sh`, `project-md-adr-staleness.sh`, `sub-plan-completion-coherence.sh`, `charter-coherence-spot.sh`, `observation-orphan-detector.sh`, `ghost-work-audit.sh` |
| **Bootstrap-summary / Index Render** | ~4 | Aggregate dense state into cheap-load summary files for next-session reboot | `bootstrap-summary-renderer.sh` (boot-summary.md ~2K), `index-registry-renderer.sh` (4 manifest TSVs), `profile-template-auto-populate.sh` (HH-C.3 self-awareness cards), `idle-state-advisory.sh` (aggregator) |
| **Spawn / Cross-Process** | ~3 | Detached Windows process spawning; secret redaction; backup | `continue-injector-spawn.sh` (PowerShell Start-Process spawn, S184 chain-truncation workaround), `redact-secrets.sh` (regex chain), `daily-backup.sh` |
| **Diagnostic (Unwired)** | ~4 | Forensic stdin capture or one-shot RC investigation | `diagnostic-pretooluse-stash.sh`, `diagnostic-subagentstop-stash.sh`, `lock-rc-probe.sh` (S246-A used), `dispatch-jsonl-backfill.sh` (one-shot CLI) |

(A few hooks span multiple categories — `harness-health-self-scan.sh` is both Watchdog and Drift Detection; `effort-escalation-detector.sh` is both Budget and Lint; `escalation-engine.sh` is both Watchdog and Severity.)

---

## 3. Representative Deep-Dives (15 hooks)

### 3.1 `single-claude-instance-lock.sh` — Governance / SessionStart
Prevents the **phantom-dispatch race condition** when multiple concurrent `claude.exe` instances share `current-execution.md` and each dispatches the same active task (M-S238-2, L-S239-4, L-S240-5). Lock file `.claude-instance.lock` format: `claude_pids=<csv>:created=<epoch>:session_id=<sid_or_unknown>`. Block conditions are **both**: (a) staleness floor `now - created < 7200s` and (b) liveness — any stored PID still alive in current `tasklist` AND not the sole `claude.exe`. Cleaned by inline SessionEnd `rm -f` (settings.json:248). Empirical RC probe at `lock-rc-probe.sh` confirmed `$PPID == 1` in spawned hook context (strategy `c` ancestor-walk fails); `session_id` from stdin JSON IS reliable. **Severity: BLOCK** (exit non-zero).

### 3.2 `session-start-bootstrap.sh` — Bootstrap / SessionStart
Reads payload, emits `hookSpecificOutput.additionalContext` pointing the model at `agent-workspace/memory/checkpoints/latest.md`. Adapted from orch v2.2.0. S184 D-042 extracted the continue-injector spawn out into `continue-injector-spawn.sh` because the nested PowerShell `Start-Process` empirically truncated the SessionStart chain on Windows after the spawning hook completed — placing the spawn LAST means truncation no longer suppresses downstream hooks. **Severity: info** (additionalContext only).

### 3.3 `budget-watchdog.sh` — Watchdog / PostToolUse + Stop
Reads transcript JSONL via `node`, sums real token usage from `usage` records, auto-triggers `session-self-reboot.sh` at thresholds. Defaults per D-004 (UP-07 Opus 4.7 recalibration): `STOCKFORGE_WIND_DOWN_TOKENS=180000`, `STOCKFORGE_CLIFF_TOKENS=220000`. ORCH_* legacy fallback envs preserved for migration. Mode-C guard (Stop-only) blocks premature turn-end when LLM cites budget pressure but real tokens well under threshold — emits decision JSON to stdout. Atomic noclobber markers (`.cliff-fired`, `.wind-down`). Honors `.auto-reboot-PRE-BLOCKED-stale-checkpoint` marker from `auto-reboot-handoff-verify.sh` (defense-in-depth pair). **Severity: BLOCK at cliff; warn at wind-down**.

### 3.4 `harness-health-self-scan.sh` — Watchdog / SessionStart + UserPromptSubmit
The **12-signal HH-1..HH-12 catalog** codified in `agent-workspace/{proposals,constitution}/harness-health-protocol.md`. Cheap-first ordering: HH-7 (checkpoint mtime), HH-11 (log mtime), HH-8 (md5), HH-1 (Stop fires ≥1/session), HH-2 (UserPromptSubmit ≤10min), HH-9 (mistake-log freshness), HH-3 (promote-rule ≤10d), HH-6 (multi-file mtime + tail), HH-4 (auto-detect orphans ≤2), HH-10 (firing-test orphans ≤2), HH-5 (delegated hook), HH-12 (project.md Phase == current-execution.md Phase). 5-min same-session cache via `.harness-health-cache-${SID}`. KI-S49b-1 suppression downgrades HH-1 HIGH→MEDIUM on Windows Stop-not-firing quirk. State aggregated to GREEN / YELLOW / RED-1 / RED-2. **Severity: info; always RC=0** (informational).

### 3.5 `destructive-command-guard.sh` — Governance / PreToolUse
Born from the **2026-05-14 mass-deletion incident** (~2688 files destroyed by a `find -newer` / git operation during a subagent execution window; 0-byte transcripts left exact command unrecoverable). Deny-list defense-in-depth: blocks destructive command CLASSES at PreToolUse, applies to BOTH main session AND every subagent. Reads Bash command from stdin JSON `tool_input.command`, matches against destructive patterns, narrow safe-allowlist. Override: `STOCKFORGE_ALLOW_DESTRUCTIVE=1` (logged to mistake-log). Paired with `daily-backup.sh` (R3) and `project-integrity-watchdog.sh` (R2) as the three-prong mass-deletion prevention. **Severity: HARD BLOCK (exit RC=2)**.

### 3.6 `write-vs-edit-guard.sh` — Governance / PreToolUse
Enforces **L-S45-2 doctrine** born from the 2026-05-05 sandwich-architect data-loss: a subagent called `Write` on `agent-workspace/memory/agent-notes.md` instead of `Edit`, destructively overwriting ~470 LOC of accumulated learned rules with a ~40 LOC stub (~140 lines permanently lost). For files under `agent-workspace/memory/{agent-notes,project,mistake-log}.md` and `agent-workspace/{constitution,proposals,session-plans}/**/*.md`, append/insert via `Edit` ONLY. `Write` reserved for genuinely new files (existence-check via `Glob` first). **Severity: HARD BLOCK (exit RC=2)**.

### 3.7 `escalation-engine.sh` — Severity / Stop + SessionStart + UserPromptSubmit
**Phase B of the unified severity/escalation system** (D-058 + L-S310-1 + proposal §2 Layer 3). Reads `.severity-state.tsv` (produced by `severity-classifier.sh`) and acts per severity row: CRITICAL → write `.autonomous-BLOCKED` flag + URGENT entry + Telegram push; HIGH → URGENT + `UserPromptSubmit` `additionalContext` for `AskUserQuestion` + Telegram push; MEDIUM → weekly digest; LOW → log only. Multi-cadence design means severity surfaces at three different windows (turn end, new session, prompt arrival). **Severity: writes `.autonomous-BLOCKED` flag (separate from exit code)**.

### 3.8 `severity-classifier.sh` — Watchdog / Stop
**Phase A** of the unified system. Late-Stop chain (after `lesson-synthesis-watchdog.sh`). Scans across artifact types (drift logs, mistake log, observation orphans, dogfood violations, frontmatter issues) and emits normalized `.severity-state.tsv` rows per `agent-workspace/constitution/severity-schema.md`. CRITICAL = block autonomous immediately; HIGH = escalate at 6h pending; MEDIUM = digest at 168h; LOW = log only. RC=0 always (best-effort).

### 3.9 `dispatch-jsonl-recorder.sh` — Telemetry / PreToolUse + SubagentStop + PostToolUse
**D-023 v2 schema + HH-B.1/B.2 telemetry**. `PreToolUse(Agent)` writes `DISPATCHED` row + sidecar keyed by `tool_use_id`. `SubagentStop` writes `COMPLETED` row with **FIFO-matched** `tool_use_id` (HH-B.1 replaced broken `agentId: <hex>` regex; filter by `parent_session_id`, find oldest `DISPATCHED` without matching `COMPLETED`) and reads `transcript_path` to populate `tokens_real` + `duration_ms` + `failure_mode` (HH-B.2). Ported from orch v2.2.0 with stockforge subagent_type→model map. **Severity: telemetry-only (RC=0)**.

### 3.10 `python-determinism-check.sh` — Determinism / PostToolUse(Edit|Write|MultiEdit) + Stop
Ported from `nautilus_trader` DST doctrine (SHA `dd49f70`, ADR D-059). Bans 4 non-determinism patterns in `packages/**/*.py` + `apps/**/*.py`:
- **R1** `datetime.now()` without timezone arg → ERR
- **R2** `random.random()/randint()/secrets.token_*()` outside `__main__` or `test_*.py` → ERR
- **R3** Dict iteration order assumption heuristic → WARN
- **R4** `time.time()` in `packages/domain/**` → ERR

Companion ports in same cadence: `atomic-write-check.sh` (TradingAgents AW-R1..R4 atomic temp-replace), `html-separator-check.sh` (TradingAgents HTML entry separator), `path-safety-check.sh` (Vibe-Trading P1-P5 sandbox/UNC/zone). All four enforce **Charter Principle 11** (deterministic enforcement) on the Python-primary stack. Violations land in `.severity-state.tsv` as HIGH.

### 3.11 `drift-signals-D1-D9.sh` — Drift / Stop
Composite drift detector running 9 grep-based signals plus D9 runtime-path-leak into write-only `learning-data/{events,archive}/` tree. D1 = LOC ceiling overrun (PRIMARY per Q-A2; highest empirical firing rate at S2). D10 = no `import anthropic` / `ANTHROPIC_API_KEY` (ported to `no-anthropic-sdk-d10.sh`). Append violations to `.drift-signals.log`, then `drift-rollup-daily.sh` promotes them to `drift-logs/YYYY-MM-DD-rollup.md` (idempotent per day), then `drift-signals-log-rotate.sh` rotates weekly (must run AFTER rollup so same-day rotate doesn't zero today's rollup).

### 3.12 `tracking-retention.sh` — Rotation / Stop
**S99 RCA Layer 1** retention guard (Q-RCA-1 = A). Warns when tracking files exceed caps: `current-execution.md` ≤5 sessions / ≤200 LOC (AUTO-MIGRATES oldest session row to archive when LOC>200 OR sessions>5 per S135 + S141 promotion); `agent-notes.md` digest only / ≤700 LOC; `mistake-log.md` digest only / ≤200 LOC; `component-telemetry.jsonl` ≤10 MB (handled by `telemetry-rotate.sh`). Empirically validated S132/S133/S134 manual instances. Cost ~30sec × every dense session = real toil per L-S65-2 harness-priority-1. WARN-only (RC=0); auto-migrate branch is the deterministic mechanism, not a block.

### 3.13 `cost-ledger-recorder.sh` — Telemetry / Stop + SubagentStop
**Append-only USD cost ledger** per session + subagent dispatch. Per S65 user request "tracking cost real not estimate" and I-S1 NO LLM math (awk computes, not LLM). Schema: `timestamp \t session_id \t actor \t model \t tokens_in \t tokens_out \t cache_read \t cache_create \t cost_usd \t hook_event`. Pricing table (Anthropic public 2025-2026): opus $15/$75, sonnet $3/$15, haiku $0.80/$4 per MTok; cache_read = 10% input; cache_create = 125% input. **Severity: telemetry-only (RC=0)**.

### 3.14 `checkpoint-write-end-turn-watchdog.sh` + `checkpoint-write-marker.sh` — Continuity Pair
**L-S49b-4 enforcement pair**. `checkpoint-write-marker.sh` (PostToolUse) fires after any Edit/Write/MultiEdit; if the file path is `agent-workspace/memory/checkpoints/latest.md`, writes session-scoped marker `.checkpoint-written-<session_id>` (and also `.fresh-resume-pending-<session_id>` if `autonomous_mode=true`). `checkpoint-write-end-turn-watchdog.sh` (PreToolUse) reads the marker; if set, denies any subsequent non-exempt tool call with RC=2 + stderr message. Marker cleared on SessionStart by `checkpoint-marker-cleanup-resume.sh`, which also surfaces the autonomous-resume `next_action` to the new session's LLM via system-reminder (replacing the revoked Mode-D SendKeys "continue" mechanism). Origin: M-S49b-2 — LLM continued executing actions AFTER writing checkpoint, causing duplicate dispatch across `/clear` boundary + lost subagent work. **Severity: HARD BLOCK (exit RC=2)**.

### 3.15 `daily-backup.sh` — Rotation / Stop
**R3 of 2026-05-14 mass-deletion prevention** (R1 = `destructive-command-guard.sh`, R2 = `project-integrity-watchdog.sh`). Once per calendar day, compresses critical directories to `$STOCKFORGE_BACKUP_DIR` (default `<project-parent>/stockforge-backups/`) **out-of-tree**. Retention 14 days; includes `agent-workspace/`, `scripts/`, `.claude/`, `packages/`, `bdd/`, `specs/`, root `*.md`; excludes `.git`, `node_modules`, `__pycache__`, `.*_cache`, forensic dirs, the backup dir itself. Origin: post-mortems/2026-05-14-mass-deletion-recovery.md §5 R3. RC=0 always.

---

## 4. Firing-Test Mechanism

### 4.1 Convention

`scripts/hooks/firing-tests/` contains 115 `*-fire-test.sh` files plus a `run-all.sh` orchestrator. **Naming rule** (enforced by `harness-health-self-scan.sh` HH-10): for every `scripts/hooks/<name>.sh` there must be a companion `scripts/hooks/firing-tests/<name>-fire-test.sh`. Tolerance: HH-10 fires only when **orphans > 2** (current state: 118 hooks − 115 fire-tests = 3 missing; HH-10 fires at HH-10-FIRING-TEST-ORPHAN MEDIUM). Each fire-test:
- Stages temp `PROJECT_DIR` via `mktemp -d` + `trap "rm -rf $TEMPDIR" EXIT`
- Pipes synthetic stdin JSON simulating the hook event payload
- Sets `CLAUDE_PROJECT_DIR=$TEMPDIR` so writes land in the sandbox
- Asserts observable state changes (markers, log entries, decision JSON to stdout)
- Exits 0 on all-pass, 1 on any-fail
- Authored S121 (2026-05-06) per Charter Principle 8 (Calibration over confidence) to close S120 unverifiable "69/69 PASS" claim

**Spawn-context markers** (per `firing-test-spawn-context-lint.sh` AP-23 + L-S247-1): each fire-test declares `SPAWN-CONTEXT: <form>` so the lint knows whether non-default arg-passing forms (bash-c, stdin-redirect, env-wrap-B) shipped with a companion test. Form-C (positional-arg) is exempt; Form-A/B/bash-c/stdin-redirect must have the marker.

### 4.2 `run-all.sh` orchestrator

```bash
PER_TEST_TIMEOUT="${FIRING_TEST_TIMEOUT:-30}"
for test in "$SCRIPT_DIR"/*-fire-test.sh; do
  timeout "$PER_TEST_TIMEOUT" bash "$test" >/dev/null 2>&1
  rc=$?
  ...
done
echo "=== firing-test suite: ${PASS}/${TOTAL} PASS (elapsed ${ELAPSED}s) ==="
```

NOT auto-wired to Stop hook (would slow every turn). Run manually post-hook-edit or via `bash scripts/hooks/firing-tests/run-all.sh`. Returns 0 only if ALL pass; detected timeouts (`rc=124`) listed separately.

### 4.3 `harness-health-self-scan.sh` consumption

HH-10 iterates `for hook in "$hooks_dir"/*.sh; do test="$tests_dir/${name}-fire-test.sh"; [ ! -f "$test" ] && orphans=$((orphans + 1)); done`. The hook does NOT execute the fire-tests — it only counts presence. Emission of fire-test PASS/FAIL outcomes is the job of `run-all.sh`, which is a manual / CI gate. This means: HH-10 catches **hook-without-fire-test** anti-patterns; `run-all.sh` catches **fire-test-fails** during edit cycles.

---

## 5. Cross-Cutting Observations

### 5.1 Severity pipeline cascade

The unified severity system (Phases A-D per D-058 + L-S310-1) is a 4-stage pipeline that fans out across event boundaries:

```
Hook detectors (drift, dogfood, frontmatter, orphan, etc.)
   ↓ append to .session-hooks.log + .drift-signals.log
severity-classifier.sh (Stop)
   ↓ emits .severity-state.tsv rows
escalation-engine.sh (Stop + SessionStart + UserPromptSubmit)
   ↓ writes .autonomous-BLOCKED + urgent.md + queues Telegram
autonomous-block-enforcer.sh (PreToolUse + UserPromptSubmit)
   ↓ reads .autonomous-BLOCKED, denies tools (RC=2) or injects loud context
telegram-push.sh (callee from escalation-engine + block-control)
   ↓ HTTP POST to Telegram bot (skeleton; STOCKFORGE_TELEGRAM_* envs required)
```

**If `severity-classifier.sh` is removed**: escalation-engine sees empty state → no CRITICAL/HIGH escalation → silent regression of every drift class. The auto-block path goes dark.

**If `escalation-engine.sh` is removed**: severity rows accumulate but never escalate; `.autonomous-BLOCKED` never gets written → main session keeps running through what should be hard-blocks.

**If `autonomous-block-enforcer.sh` is removed**: the BLOCKED flag is set but tool calls are not denied — the gate becomes advisory only. The S316 deadlock mode (manual `rm` required) returns.

### 5.2 The Checkpoint↔Resume choreography

`checkpoint-write-marker.sh` (PostToolUse) → `checkpoint-write-end-turn-watchdog.sh` (PreToolUse) → `checkpoint-marker-cleanup-resume.sh` (SessionStart) is a **3-hook continuity machine** enforcing the L-S49b-4 rule "checkpoint write = end turn". Remove any of these three and the M-S49b-2 duplicate-dispatch-across-/clear class re-opens. The trio also replaces the revoked Mode-D SendKeys "continue" mechanism (per user memory `autonomous_continue_no_self_pause.md` Rule 2).

### 5.3 Mass-deletion defense-in-depth (3-prong)

R1 `destructive-command-guard.sh` (PreToolUse hard-block deny-list) + R2 `project-integrity-watchdog.sh` (Stop hard-block early-warning that writes `.autonomous-BLOCKED` directly) + R3 `daily-backup.sh` (Stop out-of-tree 14-day backup). All three were authored in direct response to the 2026-05-14 mass-deletion incident (~2688 files destroyed; recoverable only because a git remote existed). Removing any prong reopens the failure mode at a different layer (R1 = prevention, R2 = detection, R3 = recovery).

### 5.4 Windows portability scars

The hooks layer carries a substantial Windows-compatibility surface area:
- `single-claude-instance-lock.sh` PID resolution (`$PPID == 1` in spawned hook; uses `tasklist //V` instead of `ps`)
- `continue-injector-spawn.sh` extracted as last-of-chain to dodge PowerShell `Start-Process` truncation of SessionStart (S183/S184)
- `settings-inline-env-prefix-detector.sh` catches `VAR=val cmd` patterns that fail silently in Claude Code's Windows hook runtime (S208 → 2-day production dormancy of HH-1/idle-escape/phase-status-coherence)
- `bash-hook-lint.sh` enforces `L-S11-1` (Phase 0 bash + POSIX only; no python/jq/yq)
- `firing-test-spawn-context-lint.sh` catches Form-A/B env-wrap defects that pass on Linux but fail on Windows executor
- KI-S49b-1 suppression in `harness-health-self-scan.sh` HH-1 downgrades HIGH→MEDIUM when Stop hook empirically doesn't fire on Windows quirks

### 5.5 Rotation order coupling

`drift-signals-log-rotate.sh` MUST run AFTER `drift-rollup-daily.sh` in the Stop chain — same-day rotate-before-rollup would zero today's rollup (file is the input). The settings.json Stop ordering matters: `drift-rollup-daily` → `drift-signals-log-rotate`. Similarly, `qa-pending-auto-mover.sh` MUST run AFTER `qa-stale-urgent-escalator.sh` (escalate the stale bundles first; only then auto-mv the answered/closed ones).

### 5.6 Unwired CLI utilities reused by wired hooks

Several scripts in `scripts/hooks/` are not Claude Code hooks but utilities reused by wired hooks: `redact-secrets.sh` (called by `session-export-raw.sh`), `telegram-push.sh` (called by `escalation-engine.sh` + `block-control.sh`), `sync-tracker-update.sh` + `sync-tracker-render.sh` (called by `sync-tracker-auto-update.sh` + `sync-grilling-call.sh`), `continue-injector.ps1` (PowerShell spawned by `continue-injector-spawn.sh`), `block-control.sh raise/clear/status/check-prompt` (CLI subcommand interface). Removing any of these silently breaks the wired-hook that calls them.

### 5.7 What's missing / DRAFT

- `memory-routing-audit.sh` is DRAFT — NOT wired pending HR-4 charter proposal ratification.
- `lock-rc-probe.sh` is unwired — kept for future RC investigation; S246-A captured the data, strategy `f` selected.
- 3 hooks lack companion fire-tests (HH-10 currently fires at MEDIUM); newest hooks (`dogfood-the-promotion.sh`, `stop-finding-frontmatter-validator.sh`, possibly one more) need fire-tests.
- `Notification` event has 0 wired hooks (intentionally empty).
- 3 `.bak-S348` files (`block-control.sh.bak-S348`, `escalation-engine.sh.bak-S348`, `severity-classifier.sh.bak-S348`) preserve pre-D-068 state; not loaded.

### 5.8 Idempotency markers everywhere

Many hooks use marker files to ensure single-fire-per-window semantics:
- Hour-bucket markers (per L-S108-1 — `CLAUDE_SESSION_ID` empty on Windows so date hour-bucket substitutes): `harness-health-self-scan`, `idle-escape-detector`, `phase-status-coherence`, `qa-pending-auto-mover`
- Week-bucket markers: `telemetry-rotate`, `session-hooks-log-rotate`, `drift-signals-log-rotate`
- Day-bucket markers: `daily-backup`, `drift-rollup-daily`
- Per-session markers: `sync-tracker-auto-update`, `checkpoint-write-marker`, `continue-injector-spawn`
- Per-PLAN_ID markers: `planner-feedback-loop`

This idempotency layer is invisible at the wiring-level but critical for keeping turn-cost flat as the Stop chain grew from ~10 to 50+ hooks.

---

## 6. Sources

- `C:\htdocs\stockforge\.claude\settings.json` lines 138-682 (wiring)
- `C:\htdocs\stockforge\scripts\hooks\*.sh` (118 scripts)
- `C:\htdocs\stockforge\scripts\hooks\firing-tests\*-fire-test.sh` (115 companions + `run-all.sh`)
- `C:\htdocs\stockforge\scripts\hooks\harness-health-self-scan.sh` (HH-1..HH-12 consumer of fire-test orphans)
- `C:\htdocs\stockforge\CLAUDE.md` (hooks referenced by hard-rules)
