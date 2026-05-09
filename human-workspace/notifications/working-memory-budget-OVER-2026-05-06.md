# Working-memory budget exceeded — 2026-05-06T21:32:16+07:00

**Source**: clear
**Total**: 20484 bytes
**Ceiling**: 20480 bytes (20 KB)
**Over by**: 4 bytes (0%)

## Per-file breakdown

| File | Bytes | Sub-cap (KB) |
|---|---|---|
| boot-summary.md     | 1464 | ≤ 4 |
| checkpoints/latest.md | 12245 | ≤ 8 |
| routing-config.md   | 6775 | ≤ 8 |

## Action required
- Identify heaviest file and re-shape:
  - boot-summary.md → re-render via bootstrap-summary-renderer.sh
  - checkpoints/latest.md → trim non-essential prose; archive bulk to dated checkpoint
  - routing-config.md → split task-class entries to extension file
- Reference: `agent-workspace/proposals/memory-tiers.md` § Tier 1
