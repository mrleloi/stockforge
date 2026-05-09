# bash-hook-lint — Warnings

Per L-S11-1 + L-S13-1 + S16 D-IDENTITY (S15 close user correction): 12 violation(s) detected.

  - L-S11-1-PORTABILITY: autonomous-stop-watchdog.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: post-dev-dispatch-attestation-check.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: qa-pending-stale-mover.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: redact-secrets.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: session-export-raw.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: subagent-stop-logger.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: vendor-api-probe.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: autonomous-stop-watchdog.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: promotion-cycle-trigger.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: session-start-bootstrap.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: stale-prompt-detector.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: sync-grilling-call.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)

Fix:
- L-S43b-9: replace `printf "-..."` or `printf "'-..."'` with `printf -- "-..."` to disambiguate format from option flag
