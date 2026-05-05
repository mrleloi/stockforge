# bash-hook-lint — Warnings

Per L-S11-1 + L-S13-1 + S16 D-IDENTITY (S15 close user correction): 41 violation(s) detected.

  - L-S11-1-PORTABILITY: autonomous-stop-watchdog.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: qa-pending-stale-mover.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: redact-secrets.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: session-export-raw.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: subagent-stop-logger.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S13-1-ORPHAN-LOG-VAR: autonomous-stop-watchdog.sh — variable $CHECKPOINT_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: autonomous-stop-watchdog.sh — variable $EXEC_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: autonomous-stop-watchdog.sh — variable $TRANSCRIPT_PATH declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: component-telemetry.sh — variable $HOOKS_LOG declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: component-telemetry.sh — variable $MEMORY_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: component-telemetry.sh — variable $MODE_C_LOG declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: component-telemetry.sh — variable $TOKENS_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: correction-rate-aggregator.sh — variable $LOG_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: correction-rate-tracker.sh — variable $TOKENS_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: dispatch-jsonl-recorder.sh — variable $MEMORY_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: drift-signals-D1-D9.sh — variable $DATA_FILES declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: drift-signals-D1-D9.sh — variable $SESSION_LOGS declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: learning-queue-sweeper.sh — variable $MAX_FILE_BYTES declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: loc-ceiling-check.sh — variable $FILE_PATH declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: metric-failure-mode-rate.sh — variable $TS_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: post-tool-citation-grep.sh — variable $FILE_PATH declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: precompact-thesis-state-dump.sh — variable $SNAPSHOT_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: qa-answered-detector.sh — variable $ANSWERED_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: qa-pending-stale-mover.sh — variable $NOTIFY_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: qa-pending-stale-mover.sh — variable $PENDING_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: qa-pending-stale-mover.sh — variable $STALE_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: session-export-raw.sh — variable $EXEC_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: session-export-raw.sh — variable $RAW_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: session-start-bootstrap.sh — variable $CHECKPOINT_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: session-start-bootstrap.sh — variable $EXEC_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: session-start-bootstrap.sh — variable $QUEUED_GRILL_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: stale-prompt-detector.sh — variable $DECISIONS_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: stale-prompt-detector.sh — variable $EXEC_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: stale-prompt-detector.sh — variable $INTAKE_LOG declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: stale-prompt-detector.sh — variable $SESSIONS_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: sync-grilling-trigger.sh — variable $SESSIONS_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: taskcompleted-audit.sh — variable $CHANGED_FILES declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: tool-call-first-lint.sh — variable $EXEC_FILE declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: tool-call-first-lint.sh — variable $LOG_DIR declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: tool-call-first-lint.sh — variable $TRANSCRIPT_PATH declared but never used as redirect target nor read source
  - L-S13-1-ORPHAN-LOG-VAR: tool-call-first-lint.sh — variable $TURN_OUTPUT declared but never used as redirect target nor read source

Fix:
