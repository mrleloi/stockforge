---
observation_id: phase-3.5-T7-deeper-audit-S72
type: audit-report
session: S72
date: 2026-05-06
author: main-session (Opus 4.7)
parent_track: 010-S50 Phase 3.5 T7
predecessor: S71 first-pass audit (verdict: SUBSTANTIALLY-DONE — 44 firing-tests; per-hook HH-* mapping not exhaustively re-audited)
verdict: PARTIAL-S72-AUDIT — 4 HH-A..HH-H specific gaps + 15 wider wired-without-test gaps
authoritative: true
---

# Phase 3.5 Track T7 — deeper audit (S72)

## Goal

Empirically map every HH-A..HH-H hook deliverable from `009-S48-harness-hardening-middle-phase.md` to its companion firing-test in `scripts/hooks/firing-tests/`, per the T7 spec ("Codify pattern 'every hook needs companion firing-test' by retrofitting Phase 2.5 deliverables"). Verify-Before-Write (VBW) protocol applied: hook list read from disk, settings.json wiring read from disk, firing-tests list globbed from disk; nothing inferred.

## Method

1. Globbed `scripts/hooks/firing-tests/*.sh` → 44 firing-tests on disk
2. Globbed `scripts/hooks/*.sh` → 68 hooks on disk
3. Cross-referenced each hook against `firing-tests/<hook>-fire-test.sh` existence
4. Read `.claude/settings.json` wiring to filter wired-only hooks
5. Read `009-S48-harness-hardening-middle-phase.md` HH-A..HH-H deliverables to map per-track scope
6. Tabulated gaps by HH-* track + by wired status

## HH-A..HH-H per-track mapping (T7 strict scope)

| Track | Deliv | Hook | Wired? | Firing-test? | Verdict |
|---|---|---|---|---|---|
| HH-A | A.1 | `vendor-api-probe.sh` | ✅ SessionStart | ❌ MISSING | **GAP-1** |
| HH-A | A.2 | `tier1-bloat-check.sh` | ✅ Stop | ✅ `tier1-bloat-check-fire-test.sh` | OK |
| HH-A | A.3-6 | (data/manifest, no hook) | n/a | n/a | n/a |
| HH-B | B.1 | `dispatch-jsonl-recorder.sh` | ✅ PreToolUse + PostToolUse + SubagentStop | ✅ `dispatch-jsonl-recorder-fire-test.sh` | OK |
| HH-B | B.2 (capture) | `subagent-stop-logger.sh` | ✅ SubagentStop | ❌ MISSING | **GAP-2** |
| HH-B | B.3 (failure_mode) | `metric-failure-mode-rate.sh` | ❌ NOT-WIRED (offline metric) | ✅ `metric-failure-mode-rate-fire-test.sh` | OK (offline) |
| HH-B | B.4 (DR audit) | `drift-signals-D1-D9.sh` | ✅ Stop | ✅ `drift-signals-D1-D9-fire-test.sh` | OK |
| HH-B | B.5 (sync-tracker) | `sync-tracker-auto-update.sh` | ✅ Stop | ✅ `sync-tracker-auto-update-fire-test.sh` | OK |
| HH-C | C.1 | `session-end-checklist-linter.sh` | ✅ Stop | ✅ `session-end-checklist-linter-fire-test.sh` | OK |
| HH-C | C.2 | `project-md-staleness-check.sh` | ✅ Stop | ✅ `project-md-staleness-check-fire-test.sh` | OK |
| HH-C | C.3 | `profile-template-auto-populate.sh` | ✅ Stop | ❌ MISSING | **GAP-3** |
| HH-C | C.4 | (CLAUDE.md doc, no hook) | n/a | n/a | n/a |
| HH-D | (charter rule + optional skill) | n/a | n/a | n/a | n/a |
| HH-E | E.1 | `qa-stale-urgent-escalator.sh` | ✅ Stop | ✅ `qa-stale-urgent-escalator-fire-test.sh` | OK |
| HH-E | E.2 (auto-mv) | `qa-pending-auto-mover.sh` | ✅ Stop | ✅ `qa-pending-auto-mover-fire-test.sh` | OK |
| HH-F | (ETL/data) | n/a | n/a | n/a | n/a |
| HH-G | (template) | n/a | n/a | n/a | n/a |
| HH-H | H.1 | `session-self-reboot.sh` | (script not hook) | n/a (script) | n/a |
| HH-H | H.2 | `pre-clear-handoff-guard.sh` | ✅ Stop | ✅ `pre-clear-handoff-guard-fire-test.sh` | OK |
| HH-H | H.3 | `continue-injector.ps1` | (script not hook) | n/a (script) | n/a |
| HH-H | H.4 | `auto-reboot-handoff-verify.sh` | ✅ Stop | ❌ MISSING | **GAP-4** |
| HH-H | H.5 | `budget-watchdog.sh` (idempotency) | ✅ Stop + PostToolUse | ✅ `budget-watchdog-fire-test.sh` | OK |

**HH-A..HH-H strict scope verdict**: 4 gaps + 11 OK + 8 n/a (non-hook deliverables).

## Specific gaps (HH-A..HH-H — priority for T7 follow-up)

| # | Hook | Wired event | Risk if untested |
|---|---|---|---|
| **GAP-1** | `vendor-api-probe.sh` | SessionStart (matcher `startup\|resume\|clear`) | Vendor connectivity drift undetected at session boot; downstream tier1 ingest may silently degrade |
| **GAP-2** | `subagent-stop-logger.sh` | SubagentStop | Subagent dispatch telemetry (tokens_real / failure_mode / duration_ms per HH-B.2) silently regresses; cost-ledger + dispatch.jsonl JOIN integrity at risk |
| **GAP-3** | `profile-template-auto-populate.sh` | Stop | HH-C.3 deliverable; per-session profile-card append silently fails → self-awareness rebuild trigger never fires correctly |
| **GAP-4** | `auto-reboot-handoff-verify.sh` | Stop | HH-H.4 deliverable; `.cliff-fired` / `.wind-down-fired` markers + checkpoint staleness gate untested → auto-reboot-without-handoff regression possible (the original Phase 2.5 incident root cause) |

## Wider wired-without-firing-test inventory (out of T7 strict scope; future follow-up)

15 additional production-wired hooks lack firing-tests beyond the HH-A..HH-H scope above:

**SessionStart-wired (6)**:
- `qa-pending-stale-mover.sh`
- `qa-answered-detector.sh`
- `sync-grilling-trigger.sh`
- `learning-queue-sweeper.sh`
- `ghost-work-audit.sh`
- `proposal-bundle-advisor.sh`
- `checkpoint-marker-cleanup-resume.sh`

**Stop-wired (8)**:
- `taskcompleted-audit.sh`
- `learning-index-rebuild.sh`
- `learning-loop-metric-check.sh`
- `research-scanner-output-validator.sh`
- `lesson-synthesis-watchdog.sh` (recently added S69 — recently-deployed watchdog should have test)
- `memory-routing-audit.sh`

**PostToolUse-wired (1)**:
- `checkpoint-write-marker.sh` (T4 deliverable per Phase 3.5 plan)

**PreCompact-wired (1)**:
- `precompact-thesis-state-dump.sh`

(7 hooks counted SessionStart includes the checkpoint-marker-cleanup-resume above; total wired-without-test = 19 = 4 HH-A..HH-H gaps + 15 non-HH-* gaps.)

## Hooks lacking firing-tests AND not wired (orphan/legacy — informational only)

7 unwired hooks:
- `subagent-budget-classifier.sh`
- `redact-secrets.sh`
- `diagnostic-pretooluse-stash.sh`
- `diagnostic-subagentstop-stash.sh`
- `same-commit-rule.sh`
- `sync-tracker-update.sh` (legacy variant; `sync-tracker-auto-update.sh` is the wired replacement)
- `dispatch-jsonl-backfill.sh` (one-off backfill script, not a continuous hook)

These do NOT block T7 since they aren't firing in production. Consider removal OR explicit "intentionally-unwired" annotation in a future cleanup pass.

## S71 audit revision

S71 verdict for T7 was "⚠ SUBSTANTIALLY-DONE — 44 firing-tests in `scripts/hooks/firing-tests/`; per-hook HH-* mapping not exhaustively re-audited this S71."

S72 deeper audit refines this:

- **HH-A..HH-H strict scope**: PARTIAL — 4/15 declared hook-deliverables UNTESTED (HH-A.1 + HH-B.2 + HH-C.3 + HH-H.4); 11/15 PASS; 8 n/a non-hook deliverables
- **L-S49b-4 charter principle ("every hook needs companion firing-test")**: 19/60 wired hooks UNTESTED across project (~32%) — meaningful coverage gap, but bulk of safety-critical Stop+PostToolUse hooks DO have tests

T7 cannot be marked DONE without filling at minimum the 4 HH-A..HH-H gaps. The wider 15 non-HH-* gaps are appropriate as a separate follow-up track (not in T7 strict scope).

## Recommended next session

**Track T7-followup-S<N>** (FOCUSED_IMPL, ~80-120K main):
1. Author 4 firing-tests for HH-A..HH-H gaps (priority order = risk order):
   - `auto-reboot-handoff-verify-fire-test.sh` (CRITICAL — H.4 was Phase 2.5 root-incident fix)
   - `subagent-stop-logger-fire-test.sh` (HIGH — telemetry foundation)
   - `vendor-api-probe-fire-test.sh` (MEDIUM — boot-time connectivity)
   - `profile-template-auto-populate-fire-test.sh` (MEDIUM — self-awareness aggregation)
2. Run all 4 + verify previous 44 still PASS (regression check)
3. Update T7 status to ✅ COMPLETE in plan frontmatter
4. (Optional same session OR separate) Author 15 non-HH-* firing-tests as L-S49b-4 charter-coverage push

Once T7 is COMPLETE + (T5+T6+T8 charter-tier track resolved via AskUserQuestion gate when user actively engages), 010-S50 can move to `session-plans/completed/`.

## Drift watch

- D1=0 sustained (read-only audit; no hook code modified)
- D9 charter md5 ALL UNCHANGED
- AP-1 same-agent self-review: NOT VIOLATED — empirical file-existence checks via Glob + grep (deterministic)
- AP-23 LLM-Guardian creep: ZERO (no LLM calls; deterministic mapping)

## Provenance

- Hook list: globbed `scripts/hooks/*.sh` 2026-05-06T11:35:05+07:00 (68 .sh files)
- Firing-test list: globbed `scripts/hooks/firing-tests/*.sh` 2026-05-06T11:35:05+07:00 (44 .sh files)
- Settings wiring: read `.claude/settings.json` 2026-05-06 (488 lines; SessionStart/SessionEnd/UserPromptSubmit/Stop/PreToolUse/PostToolUse/SubagentStop/PreCompact)
- HH-A..HH-H spec: read `agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md` lines 48-148

End of audit.
