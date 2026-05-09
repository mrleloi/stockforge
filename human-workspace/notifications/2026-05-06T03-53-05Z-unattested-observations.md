# Unattested sandwich-dev observations (L-S68-1 mitigation)

**Detected at**: 2026-05-06T03:53:05Z (SessionStart scan)
**Session**: dogfood-S69
**Source**: resume

## Files lacking BOTH attestation marker AND attestation-log row

- `sandwich-dev-S66-BC-7-track-J`

## Recommended action

Per L-S68-1: when /clear (or other event) killed the SubagentStop chain,
the post-dev-dispatch-attestation-check.sh hook never fired. Manual fallback:

1. Read each observation frontmatter; cross-check claimed metrics empirically
   (pytest + git-status)
2. If empirical state matches → manually `touch` the marker file:
   `agent-workspace/memory/.attestation-checked-<basename>`
3. If divergence → treat as M-S67-3 / M-S66-1 pattern; catalog in mistake-log

Registry log: `agent-workspace/memory/.unattested-observations.tsv`
