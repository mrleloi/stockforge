# Working-memory budget exceeded — 2026-05-10T23:57:16+07:00

**Source**: startup
**Total**: 24226 bytes
**Ceiling**: 20480 bytes (20 KB)
**Over by**: 3746 bytes (18%)

## Per-file breakdown

| File | Bytes | Sub-cap (KB) |
|---|---|---|
| boot-summary.md     | 2401 | ≤ 4 |
| checkpoints/latest.md | 15050 | ≤ 8 |
| routing-config.md   | 6775 | ≤ 8 |

## Action required
- Identify heaviest file and re-shape:
  - boot-summary.md → re-render via bootstrap-summary-renderer.sh
  - checkpoints/latest.md → trim non-essential prose; archive bulk to dated checkpoint
  - routing-config.md → split task-class entries to extension file
- Reference: `agent-workspace/proposals/memory-tiers.md` § Tier 1
