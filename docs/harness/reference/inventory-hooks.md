# Reference — Hooks Inventory

> **Audited**: 2026-05-19
> **Source**: `scripts/hooks/*.sh` (113 scripts as of audit; live count fluctuates) + `.claude/settings.json:138-682` (wiring) + 3 `.bak-S348` legacy backups
> **Companion**: `scripts/hooks/firing-tests/*.sh` (~114 firing-tests + run-all.sh)
> **Maintainer**: Run `/harness-docs sync hooks` to regenerate
> **Note**: Chapter prose may cite slightly different counts (e.g., "118") from research-audit snapshot 2026-05-19 morning; the live system is the authority. Run `/harness-docs drift` to detect.

For deep-dives and the firing matrix, see [Chapter 6 — Hooks](../en/06-hooks.md). This is the alphabetical inventory.

---

## Event Firing Matrix (Summary)

| Event | Wired count |
|---|---|
| SessionStart | 22 |
| SessionEnd | 3 |
| UserPromptSubmit | 13 |
| PreToolUse | 9 |
| PostToolUse | 10 |
| Stop | 50+ |
| SubagentStop | 5 |
| PreCompact | 1 |
| Notification | 0 (intentional) |

Total wired-invocation count: ~113 (hooks fire on multiple events).
Total physical scripts: 118.

---

## Alphabetical Inventory

| Hook | Event(s) | Category | Severity | Notes |
|---|---|---|---|---|
| `adr-empirical-close-verify-spot-check.sh` | Stop | Drift Detection | warn | D-052 ghost-greening prevention |
| `atomic-write-check.sh` | PostToolUse(Edit\|Write\|MultiEdit) + Stop | Determinism | warn (HIGH .severity) | AW-R1-R4 atomic temp-replace pattern |
| `attach-portability-smoke.sh` | (unwired) | Diagnostic | — | `attach` skill portability smoke test |
| `auto-reboot-handoff-verify.sh` | Stop | Continuity | warn | HH-H.4 outer fence |
| `autonomous-block-enforcer.sh` | UserPromptSubmit + PreToolUse | Governance / Severity | BLOCK (RC=2) | Phase C of severity pipeline |
| `autonomous-stop-watchdog.sh` | Stop | Continuity | warn | Mode A/B/C/D detector |
| `bash-hook-lint.sh` | Stop | Lint | warn | L-S11-1 Phase 0 portability + producer-consumer integrity |
| `block-control.sh check-prompt` | UserPromptSubmit | Q&A Lifecycle | warn | Auto-clear on "approved" reply |
| `block-control.sh` (CLI: raise/clear/status) | — | CLI | — | Wrapper for `.autonomous-BLOCKED` flag |
| `bootstrap-summary-renderer.sh` | Stop | Bootstrap-summary | warn | Renders boot-summary.md ~2K |
| `budget-watchdog.sh` | PostToolUse + Stop | Budget | BLOCK at cliff | 180K wind-down / 220K cliff per D-004 |
| `charter-coherence-spot.sh` | Stop | Coherence | warn | I-S35 framing check |
| `checkpoint-marker-cleanup-resume.sh` | SessionStart | Continuity | warn | Clears markers; surfaces next_action |
| `checkpoint-write-end-turn-watchdog.sh` | PreToolUse | Continuity / Governance | BLOCK (RC=2) | L-S49b-4 enforcement |
| `checkpoint-write-marker.sh` | PostToolUse | Continuity | warn | Marks .checkpoint-written-<sid> |
| `component-telemetry.sh` | SessionStart (.*) + PostToolUse + SubagentStop | Telemetry | none (RC=0) | Per-tool JSONL |
| `continue-injector-spawn.sh` | SessionStart (LAST in chain) | Spawn / Cross-Process | warn | S184 D-042 chain-truncation workaround |
| `continue-injector.ps1` | (called by continue-injector-spawn.sh) | Spawn / Cross-Process | — | PowerShell SendKeys |
| `correction-rate-aggregator.sh` | Stop | Telemetry | warn | D-004 instrumentation rollup |
| `correction-rate-tracker.sh` | UserPromptSubmit | Telemetry | warn | Counts user corrections per turn |
| `cost-ledger-recorder.sh` | Stop + SubagentStop | Telemetry | none | USD pricing table (Anthropic public rates) |
| `daily-backup.sh` | Stop | Rotation | none | R3 of mass-deletion prevention; 14-day OUT-OF-TREE backups |
| `destructive-command-guard.sh` | PreToolUse | Governance | BLOCK (RC=2) | R1 of mass-deletion prevention |
| `diagnostic-pretooluse-stash.sh` | (unwired) | Diagnostic | — | Forensic stdin capture |
| `diagnostic-subagentstop-stash.sh` | (unwired) | Diagnostic | — | Forensic stdin capture |
| `dispatch-jsonl-backfill.sh` | (unwired CLI) | Diagnostic | — | One-shot CLI utility |
| `dispatch-jsonl-recorder.sh` | PreToolUse + SubagentStop + PostToolUse | Telemetry | none | D-023 v2 schema; FIFO-matched tool_use_id |
| `dispatch-pending-rotation.sh` | Stop | Rotation | warn | 12h archive of pending dispatch rows |
| `dogfood-the-promotion.sh` | Stop | Watchdog | warn | Catches missing dogfood for promoted rules |
| `drift-rollup-daily.sh` | Stop | Drift Detection | warn | Idempotent per day |
| `drift-signals-D1-D9.sh` | Stop | Drift Detection | warn (HIGH severity in .severity) | Composite D1-D9 + D-A1-A5 |
| `drift-signals-log-rotate.sh` | Stop (MUST run after drift-rollup-daily) | Rotation | warn | Weekly rotate |
| `effort-escalation-detector.sh` | UserPromptSubmit + PreToolUse | Lint / Budget | warn | Recommend /effort ladder |
| `escalation-engine.sh` | Stop + SessionStart + UserPromptSubmit | Severity | warn (writes BLOCK flag) | Phase B of severity pipeline |
| `essential-routing-fields-verifier.sh` | SessionStart | Bootstrap | warn | Validates current-execution.md |
| `file-pattern-hook-pre-flight-lint.sh` | Stop | Lint | warn | L-S176-1 |
| `firing-test-spawn-context-lint.sh` | Stop | Lint | warn | AP-23 + L-S247-1 |
| `ghost-work-audit.sh` | SessionStart | Watchdog | warn | In-flight subagent orphan check |
| `guardian-output-inspect-first.sh` | (consumer hook; called by others) | Lint | — | Globbing on rotated notification slugs |
| `harness-health-self-scan.sh` | SessionStart + UserPromptSubmit | Watchdog / Drift | info (always RC=0) | HH-1..HH-12 catalog |
| `harness-recovery-dod-watchdog.sh` | Stop | Watchdog | warn | Catches stuck plans |
| `hook-firing-counter.sh` | UserPromptSubmit | Telemetry | warn | Tally per-turn fires; H-c JSON contract |
| `hook-log-path-canonical-detector.sh` | (consumer) | Lint | — | L-S214-1 |
| `html-separator-check.sh` | PostToolUse(Edit\|Write\|MultiEdit) + Stop | Determinism | warn | TradingAgents HTML entry separator |
| `idle-escape-detector.sh` | SessionStart + UserPromptSubmit | Drift | warn | M-S171-1 prevention #3 |
| `idle-state-advisory.sh` | SessionStart + UserPromptSubmit | Bootstrap-summary | warn | Aggregator |
| `in-flight-subagent-watcher.sh` | SessionStart + UserPromptSubmit | Watchdog | warn | Unattended dispatch check |
| `index-registry-renderer.sh` | Stop | Bootstrap-summary | warn | 4 manifest TSVs |
| `learning-index-rebuild.sh` | Stop | Learning Loop | warn | Rebuild learning index |
| `learning-loop-metric-check.sh` | Stop | Learning Loop | warn | L-S12-1 |
| `learning-queue-sweeper.sh` | SessionStart | Learning Loop | warn | Promote pending lessons |
| `lesson-synthesis-watchdog.sh` | Stop | Learning Loop | warn (strict mode: BLOCK) | Stage 1 of self-upgrade |
| `loc-ceiling-check.sh` | PostToolUse | Lint | warn | D1 LOC per category |
| `lock-rc-probe.sh` | (unwired CLI) | Diagnostic | — | S246-A RC investigation |
| `memory-etl-processor.sh` | Stop | Telemetry | warn | Drain etl-queue/ |
| `memory-routing-audit.sh` | Stop | Coherence | warn | DRAFT — not wired (pending HR-4) |
| `metric-failure-mode-rate.sh` | (unwired) | Telemetry | — | S12 Karpathy framing |
| `no-anthropic-sdk-d10.sh` | (D10 wired inside drift-signals-D1-D9.sh) | Drift | warn | D10 |
| `observation-orphan-detector.sh` | Stop | Watchdog | warn | Catches subagent COMPLETED without observation |
| `path-safety-check.sh` | PostToolUse(Edit\|Write\|MultiEdit) + Stop | Determinism | warn | Vibe-Trading P1-P5 sandbox/UNC/zone |
| `pending-queue-escalator.sh` | Stop | Severity | warn | D-068 PENDING-tier |
| `phase-status-coherence.sh` | UserPromptSubmit + Stop | Coherence | warn | HH-12 enhancement |
| `planner-feedback-loop.sh` | Stop | Telemetry | warn | Architect calibration data |
| `post-dev-dispatch-attestation-check.sh` | SubagentStop (.*) | Watchdog | warn | Sandwich-dev attestation |
| `post-tool-citation-grep.sh` | PostToolUse | Determinism | warn | I-S2 enforcement |
| `pre-checkpoint-close-verifier.sh` | Stop | Continuity / Drift | warn | M-S67-3 pattern |
| `pre-clear-handoff-guard.sh` | Stop | Governance | warn (strict mode: BLOCK) | Un-handed-off work check |
| `pre-commit-pytest-regression-guard.sh` | PreToolUse | Governance | warn | Tests pass before commit |
| `pre-dispatch-adr-number-check.sh` | PreToolUse | Governance | warn | ADR number collision prevention |
| `pre-dispatch-architect-commit-guard.sh` | PreToolUse | Governance | warn | No auto-commit by architect |
| `precompact-thesis-state-dump.sh` | PreCompact | Continuity | warn | Dump thesis state before compact |
| `profile-template-auto-populate.sh` | Stop | Telemetry / Bootstrap-summary | warn | HH-C.3 self-awareness cards |
| `project-integrity-watchdog.sh` | Stop | Governance / Watchdog | BLOCK (writes flag directly) | R2 of mass-deletion prevention |
| `project-md-adr-staleness.sh` | Stop | Coherence | warn | project.md ↔ ADRs cross-check |
| `promotion-cycle-trigger.sh` | Stop | Learning Loop | warn (HARD-BLOCK at ≥8 lessons) | ≥5 sessions OR phase boundary |
| `proposal-bundle-advisor.sh` | SessionStart | Lint | warn | 48h cool-down ready check |
| `python-determinism-check.sh` | PostToolUse(Edit\|Write\|MultiEdit) + Stop | Determinism | warn (HIGH .severity) | R1-R4 banned patterns; ADR D-059 |
| `qa-answered-detector.sh` | SessionStart | Q&A Lifecycle | warn | Re-classify status= changes |
| `qa-pending-auto-mover.sh` | Stop (after qa-stale-urgent-escalator) | Q&A Lifecycle | warn | D-031 ratified auto-mv |
| `qa-pending-stale-mover.sh` | SessionStart | Q&A Lifecycle | warn | Past-wait_until mover |
| `qa-stale-urgent-escalator.sh` | Stop | Q&A Lifecycle / Severity | warn | >48h URGENT |
| `redact-secrets.sh` | (called by session-export-raw.sh) | Spawn / Cross-Process | — | Regex chain |
| `research-scanner-output-validator.sh` | Stop | Lint | warn | Provenance + repo URL/SHA |
| `same-commit-rule.sh` | (pre-commit git hook; not Claude Code hook) | — | — | Same-commit discipline |
| `scheduled-drift-detector-trigger.sh` | Stop | Drift Detection | warn | Schedule periodic full drift run |
| `self-awareness-aggregate.sh` | Stop | Telemetry | warn | sessions-rollup.tsv |
| `session-end-checklist-linter.sh` | Stop | Lint | warn (strict mode: BLOCK) | HH-C.1 mistake-log discipline |
| `session-export-raw.sh` | SessionEnd | Bootstrap | warn | Archive raw transcript |
| `session-hooks-log-rotate.sh` | Stop | Rotation | warn | Weekly rotate |
| `session-start-bootstrap.sh` | SessionStart | Bootstrap | warn | Emit checkpoint additionalContext |
| `session-start-scan-unattested-observations.sh` | SessionStart | Watchdog | warn | Orphan observation check |
| `settings-inline-env-prefix-detector.sh` | (consumer / lint) | Lint | warn | L-S208-1 Windows env-prefix gotcha |
| `severity-classifier.sh` | Stop (late-chain, after lesson-synthesis-watchdog) | Watchdog / Severity | warn (no exit code) | Phase A of severity pipeline |
| `single-claude-instance-lock.sh` | SessionStart | Governance | BLOCK | Phantom-dispatch race prevention |
| `stale-prompt-detector.sh` | UserPromptSubmit | Lint | warn | Flag >24h old references |
| `stop-finding-frontmatter-validator.sh` | Stop | Lint | warn | Stop-finding frontmatter discipline |
| `sub-plan-completion-coherence.sh` | Stop | Coherence | warn | S224/S235 wiring |
| `subagent-budget-classifier.sh` | (called by hooks) | Budget | — | Architect/Verifier envelope warn |
| `subagent-stop-logger.sh` | SubagentStop | Telemetry | warn | Per-subagent log row |
| `sync-grilling-call.sh` | (CLI wrapper) | Sync-Tracker | — | S129 5-arg contract |
| `sync-grilling-trigger.sh` | SessionStart | Sync-Tracker | warn | 38-session / 7-day cadence (DEMOTED per L-S310-1) |
| `sync-tracker-auto-update.sh` | Stop | Sync-Tracker | warn | HH-B.5 wrapper |
| `sync-tracker-render.sh` | (consumer) | Sync-Tracker | — | Render _index.md |
| `sync-tracker-update.sh` | (consumer) | Sync-Tracker | — | Append events.tsv |
| `taskcompleted-audit.sh` | Stop | Determinism / Watchdog | warn | I-S1 + I-S2 sweep |
| `telegram-push.sh` | (called by escalation-engine + block-control) | Severity | — | Phase D of severity pipeline |
| `telemetry-rotate.sh` | Stop | Rotation | warn | Weekly TSV rotation |
| `tier1-bloat-check.sh` | Stop | Lint | warn (HH-5) | Tier 1 ≤8K enforcement |
| `tool-call-first-lint.sh` | Stop (strict-profile only) | Lint | warn | Mode-A |
| `tracking-retention.sh` | Stop | Rotation | warn (auto-migrate) | S99 RCA Layer 1 caps |
| `urgent-md-rotate.sh` | Stop | Rotation | warn | Size-triggered 4KB |
| `userprompt-invariants-injector.sh` | UserPromptSubmit | Bootstrap | warn | I-S1/I-S2/I-S35 reminders |
| `vendor-api-probe.sh` | SessionStart | Bootstrap | warn | Check Anthropic API reachable |
| `working-memory-budget-audit.sh` | SessionStart | Bootstrap | warn | Tier-1 ≤8K check |
| `write-vs-edit-guard.sh` | PreToolUse | Governance | BLOCK (RC=2) | L-S45-2 append-only memory protection |

---

## The Severity Pipeline Cascade

```
Detectors → severity-classifier.sh (A) → escalation-engine.sh (B) → autonomous-block-enforcer.sh (C) → telegram-push.sh (D)
```

See [Chapter 6 § The Severity Pipeline](../en/06-hooks.md#66--the-severity-pipeline).

---

## The 3-Prong Mass-Deletion Defense

- R1 = `destructive-command-guard.sh` (prevention)
- R2 = `project-integrity-watchdog.sh` (detection)
- R3 = `daily-backup.sh` (recovery)

See [Chapter 6 § 6.8](../en/06-hooks.md#68--the-3-prong-mass-deletion-defense).

---

## Order Coupling (Critical)

- `drift-signals-log-rotate.sh` MUST run AFTER `drift-rollup-daily.sh`
- `qa-pending-auto-mover.sh` MUST run AFTER `qa-stale-urgent-escalator.sh`
- `severity-classifier.sh` MUST run BEFORE `escalation-engine.sh`
- `lesson-synthesis-watchdog.sh` MUST run BEFORE `promotion-cycle-trigger.sh`
- `continue-injector-spawn.sh` MUST be LAST in SessionStart chain (Windows truncation workaround)

---

## Firing-Test Discipline

`scripts/hooks/firing-tests/` contains 115 `*-fire-test.sh` files + `run-all.sh`.

Per `harness-health-self-scan.sh` HH-10: every hook should have a companion firing-test. Tolerance: orphans > 2 = MEDIUM severity. Current state: 3 missing (HH-10 fires at HH-10-FIRING-TEST-ORPHAN MEDIUM).

See [Chapter 6 § 6.9](../en/06-hooks.md#69--the-firing-test-discipline-principle-11).

---

## Unwired CLI Utilities (Reused by Wired Hooks)

| Utility | Called by |
|---|---|
| `redact-secrets.sh` | `session-export-raw.sh` |
| `telegram-push.sh` | `escalation-engine.sh`, `block-control.sh` |
| `sync-tracker-update.sh`, `sync-tracker-render.sh` | `sync-tracker-auto-update.sh`, `sync-grilling-call.sh` |
| `continue-injector.ps1` | `continue-injector-spawn.sh` |
| `block-control.sh raise/clear/status` | CLI interface |

Removing any silently breaks the wired hook that calls it.

---

## See Also

- [Chapter 6 — Hooks](../en/06-hooks.md) (full deep-dives)
- [Chapter 11 § Recipe 4 — Write a New Hook](../en/11-cookbook.md#recipe-4--write-a-new-hook)
- [Chapter 11 § Recipe 14 — Debug a Silent Hook](../en/11-cookbook.md#recipe-14--debug-a-silent-hook)
