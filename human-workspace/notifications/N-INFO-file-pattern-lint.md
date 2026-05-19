# File-pattern-lint violations — 2026-05-19T01:30:53+07:00

Detected 1 file-pattern signature(s) with 0-match against real-state target.
Per L-S176-1: review each pattern; either fix to match real state OR add
`# pattern-lint-skip: <reason>` override on same/preceding line.

## Violations

  - FILE-PATTERN-A-find-name: severity-classifier.sh:34 — find -name '.severity-state.tsv.tmp.*' matches 0 files in /c/htdocs/stockforge/agent-workspace/memory (1852 files present); review pattern against real-state inventory or add '# pattern-lint-skip:' override
