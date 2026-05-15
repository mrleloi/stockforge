# bash-hook-lint — Warnings

Per L-S11-1 + L-S13-1 + S16 D-IDENTITY (S15 close user correction): 14 violation(s) detected.

  - L-S11-1-PORTABILITY: autonomous-stop-watchdog.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: post-dev-dispatch-attestation-check.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: qa-pending-stale-mover.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: redact-secrets.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: session-export-raw.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: subagent-stop-logger.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: vendor-api-probe.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - D-IDENTITY-AUTONOMOUS-REGRESSION: agent-workspace/memory/current-execution.md — live-config line matches forbidden pattern: 15:- Decision: AUTO-TIER refresher per "Full autonomous, no SUPERVISED mode" user binding — no Ask
  - D-IDENTITY-AUTONOMOUS-REGRESSION: agent-workspace/constitution/autonomous-protocol.md — live-config line matches forbidden pattern: 30:`autonomous_mode = true` is the steady state. There is **no SUPERVISED bifurcation, no human-in-t
  - L-S48d-1-PIPEFAIL-BARE-GREP: pre-dispatch-adr-number-check.sh — pipefail + ERR trap + grep without guard — silent fail risk (L-S48d-1; refined S58 to recognize compound-if + alt-guard echo/exit/return + pipefail-bracket + multi-line continuation)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: autonomous-stop-watchdog.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: promotion-cycle-trigger.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: session-start-bootstrap.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: stale-prompt-detector.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)

Fix:
- L-S43b-9: replace `printf "-..."` or `printf "'-..."'` with `printf -- "-..."` to disambiguate format from option flag
