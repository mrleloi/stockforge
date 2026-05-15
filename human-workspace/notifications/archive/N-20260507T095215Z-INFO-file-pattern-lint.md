# File-pattern-lint violations — 2026-05-07T09:52:01+07:00

Detected 1 file-pattern signature(s) with 0-match against real-state target.
Per L-S176-1: review each pattern; either fix to match real state OR add
`# pattern-lint-skip: <reason>` override on same/preceding line.

## Violations

  - FILE-PATTERN-A-find-name: sync-tracker-auto-update.sh:63 — find -name 'D-*.md' matches 0 files in ./agent-workspace/memory/decisions (41 files present); review pattern against real-state inventory or add '# pattern-lint-skip:' override
