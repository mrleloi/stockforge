# bash-hook-lint — Warnings

Per L-S11-1 + L-S13-1 + S16 D-IDENTITY (S15 close user correction): 26 violation(s) detected.

  - L-S11-1-PORTABILITY: attach-portability-smoke.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: autonomous-stop-watchdog.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: firing-test-spawn-context-lint.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: harness-health-self-scan.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: post-dev-dispatch-attestation-check.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: qa-pending-stale-mover.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: redact-secrets.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: session-export-raw.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: subagent-stop-logger.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: vendor-api-probe.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S108-1-CLAUDE-SESSION-ID-FALLBACK-CONSTANT: idle-escape-detector.sh — fallback-to-constant ${CLAUDE_SESSION_ID:-WORD} + marker filename present (likely per-session lockout on Windows; use date hour-bucket or session-log basename — L-S108-1)
  - L-S108-1-CLAUDE-SESSION-ID-FALLBACK-CONSTANT: phase-status-coherence.sh — fallback-to-constant ${CLAUDE_SESSION_ID:-WORD} + marker filename present (likely per-session lockout on Windows; use date hour-bucket or session-log basename — L-S108-1)
  - L-S108-1-CLAUDE-SESSION-ID-FALLBACK-CONSTANT: project-md-adr-staleness.sh — fallback-to-constant ${CLAUDE_SESSION_ID:-WORD} + marker filename present (likely per-session lockout on Windows; use date hour-bucket or session-log basename — L-S108-1)
  - L-S108-1-CLAUDE-SESSION-ID-FALLBACK-CONSTANT: sub-plan-completion-coherence.sh — fallback-to-constant ${CLAUDE_SESSION_ID:-WORD} + marker filename present (likely per-session lockout on Windows; use date hour-bucket or session-log basename — L-S108-1)
  - L-S48d-1-PIPEFAIL-BARE-GREP: adr-empirical-close-verify-spot-check.sh — pipefail + ERR trap + grep without guard — silent fail risk (L-S48d-1; refined S58 to recognize compound-if + alt-guard echo/exit/return + pipefail-bracket + multi-line continuation)
  - L-S48d-1-PIPEFAIL-BARE-GREP: bootstrap-summary-renderer.sh — pipefail + ERR trap + grep without guard — silent fail risk (L-S48d-1; refined S58 to recognize compound-if + alt-guard echo/exit/return + pipefail-bracket + multi-line continuation)
  - L-S48d-1-PIPEFAIL-BARE-GREP: harness-health-self-scan.sh — pipefail + ERR trap + grep without guard — silent fail risk (L-S48d-1; refined S58 to recognize compound-if + alt-guard echo/exit/return + pipefail-bracket + multi-line continuation)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: autonomous-stop-watchdog.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: promotion-cycle-trigger.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: session-start-bootstrap.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: stale-prompt-detector.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S53-2-UNANCHORED-POSITIONAL-GREP: sync-grilling-call.sh — grep with routing-marker pattern (S<N>/Track/Session/## S<N>) lacks '^' anchor — mid-line false-positive risk (L-S53-2)
  - L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: attach-portability-smoke.sh — VAR=$(grep -c ... || echo N) produces multi-line "0\nN" capture when grep finds 0 + exits 1 → breaks awk -v numeric coercion downstream (L-S80-2). Fix: if grep -qE ...; then VAR=1; else VAR=0; fi (clean integer).
  - L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: harness-health-self-scan.sh — VAR=$(grep -c ... || echo N) produces multi-line "0\nN" capture when grep finds 0 + exits 1 → breaks awk -v numeric coercion downstream (L-S80-2). Fix: if grep -qE ...; then VAR=1; else VAR=0; fi (clean integer).
  - L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: idle-escape-detector.sh — VAR=$(grep -c ... || echo N) produces multi-line "0\nN" capture when grep finds 0 + exits 1 → breaks awk -v numeric coercion downstream (L-S80-2). Fix: if grep -qE ...; then VAR=1; else VAR=0; fi (clean integer).
  - L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: phase-status-coherence.sh — VAR=$(grep -c ... || echo N) produces multi-line "0\nN" capture when grep finds 0 + exits 1 → breaks awk -v numeric coercion downstream (L-S80-2). Fix: if grep -qE ...; then VAR=1; else VAR=0; fi (clean integer).

Fix:
- L-S43b-9: replace `printf "-..."` or `printf "'-..."'` with `printf -- "-..."` to disambiguate format from option flag
