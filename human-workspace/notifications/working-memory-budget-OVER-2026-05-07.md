# Working-memory budget exceeded — 2026-05-07T12:02:57+07:00

**Source**: clear
**Total**: 21170 bytes
**Ceiling**: 20480 bytes (20 KB)
**Over by**: 690 bytes (3%)

## Per-file breakdown

| File | Bytes | Sub-cap (KB) |
|---|---|---|
| boot-summary.md     | 2255 | ≤ 4 |
| checkpoints/latest.md | 12140 | ≤ 8 |
| routing-config.md   | 6775 | ≤ 8 |

## Action required
- Identify heaviest file and re-shape:
  - boot-summary.md → re-render via bootstrap-summary-renderer.sh
  - checkpoints/latest.md → trim non-essential prose; archive bulk to dated checkpoint
  - routing-config.md → split task-class entries to extension file
- Reference: `agent-workspace/proposals/memory-tiers.md` § Tier 1
