# bash-hook-lint — Warnings

Per L-S11-1 + L-S13-1 + S16 D-IDENTITY (S15 close user correction): 8 violation(s) detected.

  - L-S11-1-PORTABILITY: atomic-write-check.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S11-1-PORTABILITY: path-safety-check.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm) — Phase 0 doctrine = bash + POSIX only
  - L-S43b-9-PRINTF-DASH: atomic-write-check.sh — printf format starts with '-' without '--' sentinel — use 'printf -- ...'
  - L-S48d-1-PIPEFAIL-BARE-GREP: block-control.sh — pipefail + ERR trap + grep without guard — silent fail risk (L-S48d-1; refined S58 to recognize compound-if + alt-guard echo/exit/return + pipefail-bracket + multi-line continuation)
  - L-S48d-1-PIPEFAIL-BARE-GREP: escalation-engine.sh — pipefail + ERR trap + grep without guard — silent fail risk (L-S48d-1; refined S58 to recognize compound-if + alt-guard echo/exit/return + pipefail-bracket + multi-line continuation)
  - L-S48d-1-PIPEFAIL-BARE-GREP: pending-queue-escalator.sh — pipefail + ERR trap + grep without guard — silent fail risk (L-S48d-1; refined S58 to recognize compound-if + alt-guard echo/exit/return + pipefail-bracket + multi-line continuation)
  - L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: dogfood-the-promotion.sh — VAR=$(grep -c ... || echo N) produces multi-line "0\nN" capture when grep finds 0 + exits 1 → breaks awk -v numeric coercion downstream (L-S80-2). Fix: if grep -qE ...; then VAR=1; else VAR=0; fi (clean integer).
  - L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP: html-separator-check.sh — VAR=$(grep -c ... || echo N) produces multi-line "0\nN" capture when grep finds 0 + exits 1 → breaks awk -v numeric coercion downstream (L-S80-2). Fix: if grep -qE ...; then VAR=1; else VAR=0; fi (clean integer).

Fix:
- L-S43b-9: replace `printf "-..."` or `printf "'-..."'` with `printf -- "-..."` to disambiguate format from option flag
