# Memory ETL Queue

> Append-only background job queue per S65 D6.

## File format
`<priority>-<YYYYMMDD-HHMMSS>-<task-name>.job`

Where priority = 1 (high) → 9 (low). Lexical sort = priority sort.

## Job content (YAML)
```yaml
---
task: <one-of: lesson-synthesize | profile-render | drift-rollup | sync-tracker-sweep>
payload: <inline JSON or path>
created_at: <ISO8601>
---
```

## Processor
`scripts/hooks/memory-etl-processor.sh` (Stop hook). Picks highest-priority pending job per Stop event; moves to `processed/<date>/` post-execution.

## Kill switch
`MEMORY_ETL_DISABLE=1`
