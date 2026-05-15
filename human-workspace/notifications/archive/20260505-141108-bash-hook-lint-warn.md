# bash-hook-lint — Warnings

Per L-S11-1 + L-S13-1 + S16 D-IDENTITY (S15 close user correction): 38 violation(s) detected.

  - L-S11-1-PORTABILITY: autonomous-stop-watchdog.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: qa-pending-stale-mover.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: redact-secrets.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: session-export-raw.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: subagent-stop-logger.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: vendor-api-probe.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - D-IDENTITY-AUTONOMOUS-REGRESSION: agent-workspace/constitution/autonomous-protocol.md — live-config line matches forbidden pattern: 30:`autonomous_mode = true` is the steady state. There is **no SUPERVISED bifurcation, no human-in-t
  - L-S48d-1-PIPEFAIL-BARE-GREP: budget-watchdog.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: checkpoint-marker-cleanup-resume.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: checkpoint-write-marker.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: component-telemetry.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: correction-rate-tracker.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: drift-rollup-daily.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: drift-signals-D1-D9.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: ghost-work-audit.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: hook-firing-counter.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: in-flight-subagent-watcher.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: memory-routing-audit.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: post-tool-citation-grep.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: pre-clear-handoff-guard.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: project-md-staleness-check.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: promotion-cycle-trigger.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: proposal-bundle-advisor.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: qa-pending-auto-mover.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: qa-stale-urgent-escalator.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: research-scanner-output-validator.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: session-export-raw.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: session-start-bootstrap.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: stale-prompt-detector.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: subagent-budget-classifier.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: sync-grilling-trigger.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: sync-tracker-auto-update.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: userprompt-invariants-injector.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S48d-1-PIPEFAIL-BARE-GREP: vendor-api-probe.sh — pipefail + ERR trap + grep without '|| true' guard — silent fail risk (L-S48d-1; refined S54 to catch command-sub + pipelines)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: autonomous-stop-watchdog.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: promotion-cycle-trigger.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: session-start-bootstrap.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: stale-prompt-detector.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)

Fix:
- L-S43b-9: replace `printf "-..."` or `printf "'-..."'` with `printf -- "-..."` to disambiguate format from option flag
