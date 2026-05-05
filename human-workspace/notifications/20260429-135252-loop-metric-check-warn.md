# Learning-Loop Metric-Function Check — Warnings

Per L-S12-1 (agent-notes 2026-04-29): every Karpathy framing artifact MUST cite a deterministic metric function.

1 framing artifact(s) lack a usable `metric_function:` field:

  - 20260429T131608Z-experiment-frame.md: missing or placeholder metric_function field

Fix: edit each frame to add `metric_function: <path-or-inline-name>` in frontmatter; reference the metric script at `scripts/hooks/metric-failure-mode-rate.sh` or sibling.
