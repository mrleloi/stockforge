# Working-memory budget exceeded — 2026-05-15T15:54:12+07:00

**Source**: clear
**Total**: 22238 bytes
**Ceiling**: 20480 bytes (20 KB)
**Over by**: 1758 bytes (8%)

## Per-file breakdown

| File | Bytes | Sub-cap (KB) |
|---|---|---|
| boot-summary.md     | 2118 | ≤ 4 |
| checkpoints/latest.md | 13223 | ≤ 8 |
| routing-config.md   | 6897 | ≤ 8 |

## Action required
- Identify heaviest file and re-shape:
  - boot-summary.md → re-render via bootstrap-summary-renderer.sh
  - checkpoints/latest.md → trim non-essential prose; archive bulk to dated checkpoint
  - routing-config.md → split task-class entries to extension file
- Reference: `agent-workspace/proposals/memory-tiers.md` § Tier 1
